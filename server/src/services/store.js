import mongoose from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// Durable store for bans, warnings, notifications and security incidents.
//
// Data is kept in memory for fast synchronous reads (the auth middleware and
// admin routes rely on it), and every mutation is ALSO written through to
// MongoDB so that nothing is lost when the server restarts.
//
// If MongoDB is unreachable the store degrades gracefully to in-memory-only
// mode (same behaviour as before), so the API keeps working.
// ─────────────────────────────────────────────────────────────────────────────

export const bannedUsers = new Map();   // key: email (lowercase)  -> ban
export const bannedDevices = new Map(); // key: deviceId           -> ban
export const bannedIPs = new Map();     // key: ip                 -> ban
export const warnings = new Map();      // key: `${type}:${value}` -> warning
export const notifications = [];        // newest first, capped at 200
export const securityIncidentsLog = []; // newest first, capped at 100

let mongoEnabled = false;
let storeReady = false;

let Ban;
let Warning;
let Notification;
let Incident;

// ── Models ───────────────────────────────────────────────────────────────────
function defineModels() {
  const banSchema = new mongoose.Schema({
    _key: { type: String, required: true, unique: true },
    value: String,
    type: String,
    reason: String,
    warningMessage: String,
    bannedAt: String,
    bannedBy: String,
    expiresAt: String,
  }, { versionKey: false });

  const warningSchema = new mongoose.Schema({
    _key: { type: String, required: true, unique: true },
    value: String,
    type: String,
    message: String,
    createdAt: String,
    expiresAt: String,
    dismissed: Boolean,
  }, { versionKey: false });

  const notificationSchema = new mongoose.Schema({
    _key: { type: String, required: true, unique: true },
    title: String,
    body: String,
    targetEmail: String,
    targetDeviceId: String,
    createdAt: String,
    readBy: [String],
    sentBy: String,
  }, { versionKey: false });

  const incidentSchema = new mongoose.Schema({
    _key: { type: String, required: true, unique: true },
    timestamp: String,
    user: String,
    deviceId: String,
    ip: String,
    snippet: String,
    pattern: String,
    severity: String,
  }, { versionKey: false });

  Ban = mongoose.models.Ban || mongoose.model('Ban', banSchema);
  Warning = mongoose.models.Warning || mongoose.model('Warning', warningSchema);
  Notification = mongoose.models.Notification || mongoose.model('Notification', notificationSchema);
  Incident = mongoose.models.Incident || mongoose.model('Incident', incidentSchema);
}

// Load everything from MongoDB into memory on startup.
async function loadFromDb() {
  const [bans, warns, notifs, incs] = await Promise.all([
    Ban.find({}).lean(),
    Warning.find({}).lean(),
    Notification.find({}).sort({ createdAt: -1 }).limit(200).lean(),
    Incident.find({}).sort({ timestamp: -1 }).limit(100).lean(),
  ]);

  for (const b of bans) {
    const entry = {
      value: b.value,
      type: b.type,
      reason: b.reason || '',
      warningMessage: b.warningMessage || '',
      bannedAt: b.bannedAt,
      bannedBy: b.bannedBy || '',
      expiresAt: b.expiresAt || null,
    };
    const store = b.type === 'user' ? bannedUsers : b.type === 'device' ? bannedDevices : bannedIPs;
    store.set((b.type === 'user' ? b.value.toLowerCase() : b.value), entry);
  }

  for (const w of warns) {
    warnings.set(w._key, {
      value: w.value,
      type: w.type,
      message: w.message || '',
      createdAt: w.createdAt,
      expiresAt: w.expiresAt || null,
      dismissed: !!w.dismissed,
    });
  }

  for (const n of notifs) {
    notifications.push({
      id: n._key,
      title: n.title,
      body: n.body,
      targetEmail: n.targetEmail || null,
      targetDeviceId: n.targetDeviceId || null,
      createdAt: n.createdAt,
      readBy: n.readBy || [],
      sentBy: n.sentBy || '',
    });
  }

  for (const i of incs) {
    securityIncidentsLog.push({
      id: i._key,
      timestamp: i.timestamp,
      user: i.user,
      deviceId: i.deviceId,
      ip: i.ip,
      snippet: i.snippet,
      pattern: i.pattern,
      severity: i.severity,
    });
  }

  console.log(`📦 Store: loaded ${bans.length} bans, ${warns.length} warnings, ` +
    `${notifs.length} notifications, ${incs.length} incidents from MongoDB`);
}

// Initialise the store. Call once at startup with the MONGO_URI (may be empty).
export async function initStore(uri) {
  if (!uri) {
    console.log('📦 Store: running in-memory only (no MONGO_URI)');
    return;
  }
  try {
    await mongoose.connect(uri, { serverSelectionTimeoutMS: 5000 });
    defineModels();
    await loadFromDb();
    mongoEnabled = true;
    storeReady = true;
    console.log('📦 Store: MongoDB persistence enabled');
  } catch (err) {
    console.log('⚠️ MongoDB unavailable, falling back to in-memory store:', err.message);
    mongoEnabled = false;
    storeReady = false;
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
function banKey(type, value) {
  return `${type}:${(type === 'user' ? value.toLowerCase() : value)}`;
}

export function isBanActive(entry) {
  if (!entry) return false;
  if (!entry.expiresAt) return true; // permanent ban
  return new Date(entry.expiresAt) > new Date();
}

export function getActiveBans(store) {
  const active = [];
  for (const [key, entry] of store) {
    if (isBanActive(entry)) {
      active.push(entry);
    } else {
      store.delete(key); // cleanup expired
      if (mongoEnabled) {
        Ban.deleteOne({ _key: banKey(entry.type, entry.value) }).catch(() => {});
      }
    }
  }
  return active;
}

// ── Bans ─────────────────────────────────────────────────────────────────────
export async function addBan(ban) {
  const { value, type } = ban;
  const store = type === 'user' ? bannedUsers : type === 'device' ? bannedDevices : bannedIPs;
  const key = type === 'user' ? value.toLowerCase() : value;
  const entry = {
    value,
    type,
    reason: ban.reason || '',
    warningMessage: ban.warningMessage || '',
    bannedAt: ban.bannedAt,
    bannedBy: ban.bannedBy || '',
    expiresAt: ban.expiresAt || null,
  };
  store.set(key, entry);

  if (mongoEnabled) {
    await Ban.findOneAndUpdate(
      { _key: banKey(type, value) },
      {
        $set: {
          value,
          type,
          reason: entry.reason,
          warningMessage: entry.warningMessage,
          bannedAt: entry.bannedAt,
          bannedBy: entry.bannedBy,
          expiresAt: entry.expiresAt,
        },
      },
      { upsert: true, new: true, setDefaultsOnInsert: true },
    ).catch((err) => console.error('[STORE] addBan error:', err.message));
  }
  return entry;
}

export async function removeBan(type, value) {
  const store = type === 'user' ? bannedUsers : type === 'device' ? bannedDevices : bannedIPs;
  const key = type === 'user' ? value.toLowerCase() : value;
  store.delete(key);
  warnings.delete(banKey(type, value));

  if (mongoEnabled) {
    await Promise.all([
      Ban.deleteOne({ _key: banKey(type, value) }).catch(() => {}),
      Warning.deleteOne({ _key: banKey(type, value) }).catch(() => {}),
    ]);
  }
}

// ── Warnings ─────────────────────────────────────────────────────────────────
export async function addWarning({ value, type, message, createdAt, expiresAt }) {
  const key = banKey(type, value);
  warnings.set(key, {
    value,
    type,
    message: message || '',
    createdAt,
    expiresAt: expiresAt || null,
    dismissed: false,
  });

  if (mongoEnabled) {
    await Warning.findOneAndUpdate(
      { _key: key },
      { $set: { value, type, message: message || '', createdAt, expiresAt: expiresAt || null, dismissed: false } },
      { upsert: true, new: true, setDefaultsOnInsert: true },
    ).catch((err) => console.error('[STORE] addWarning error:', err.message));
  }
}

export async function dismissWarning(type, value) {
  const key = banKey(type, value);
  const entry = warnings.get(key);
  if (entry) entry.dismissed = true;

  if (mongoEnabled) {
    await Warning.updateOne({ _key: key }, { $set: { dismissed: true } }).catch(() => {});
  }
}

// ── Notifications ────────────────────────────────────────────────────────────
export async function addNotification(notification) {
  notifications.unshift(notification);
  if (notifications.length > 200) {
    const removed = notifications.pop();
    if (mongoEnabled && removed) {
      Notification.deleteOne({ _key: removed.id }).catch(() => {});
    }
  }

  if (mongoEnabled) {
    await Notification.create({
      _key: notification.id,
      title: notification.title,
      body: notification.body,
      targetEmail: notification.targetEmail || null,
      targetDeviceId: notification.targetDeviceId || null,
      createdAt: notification.createdAt,
      readBy: notification.readBy || [],
      sentBy: notification.sentBy || '',
    }).catch((err) => console.error('[STORE] addNotification error:', err.message));
  }
}

export async function deleteNotification(id) {
  const idx = notifications.findIndex((n) => n.id === id);
  if (idx !== -1) notifications.splice(idx, 1);

  if (mongoEnabled) {
    await Notification.deleteOne({ _key: id }).catch(() => {});
  }
}

export async function markNotificationRead(id, email) {
  const notif = notifications.find((n) => n.id === id);
  if (notif && !notif.readBy?.includes(email)) {
    notif.readBy = notif.readBy || [];
    notif.readBy.push(email);
  }

  if (mongoEnabled) {
    await Notification.updateOne({ _key: id }, { $addToSet: { readBy: email } }).catch(() => {});
  }
}

// ── Security incidents ───────────────────────────────────────────────────────
export async function addIncident(incident) {
  securityIncidentsLog.unshift(incident);
  if (securityIncidentsLog.length > 100) {
    const removed = securityIncidentsLog.pop();
    if (mongoEnabled && removed) {
      Incident.deleteOne({ _key: removed.id }).catch(() => {});
    }
  }

  if (mongoEnabled) {
    await Incident.create({
      _key: incident.id,
      timestamp: incident.timestamp,
      user: incident.user,
      deviceId: incident.deviceId,
      ip: incident.ip,
      snippet: incident.snippet,
      pattern: incident.pattern,
      severity: incident.severity,
    }).catch((err) => console.error('[STORE] addIncident error:', err.message));
  }
}

// Diagnostics
export function storeStatus() {
  return {
    mongoEnabled,
    ready: storeReady,
    bans: bannedUsers.size + bannedDevices.size + bannedIPs.size,
    warnings: warnings.size,
    notifications: notifications.length,
    incidents: securityIncidentsLog.length,
  };
}
