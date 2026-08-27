import express from 'express';
import { securityIncidentsLog } from '../middleware/injectionFilter.js';
import { currentRemoteConfig } from './config.js';

const router = express.Router();

// In-memory ban store (swap for DB in production)
// Each entry: { value, type, reason, warningMessage, bannedAt, bannedBy, expiresAt }
export const bannedUsers = new Map();
export const bannedDevices = new Map();
export const bannedIPs = new Map();

// In-memory warnings store (non-blocking warnings shown to user)
// Each entry: { value, type, message, createdAt, expiresAt, dismissed }
export const warnings = new Map();

// Check if a ban is currently active (not expired)
function isBanActive(entry) {
  if (!entry) return false;
  if (!entry.expiresAt) return true; // permanent ban
  return new Date(entry.expiresAt) > new Date();
}

// Get active bans from a store
function getActiveBans(store) {
  const active = [];
  for (const [key, entry] of store) {
    if (isBanActive(entry)) {
      active.push(entry);
    } else {
      store.delete(key); // cleanup expired
    }
  }
  return active;
}

// Middleware to enforce admin access
function adminOnly(req, res, next) {
  if (!req.user || !req.user.isAdmin) {
    return res.status(403).json({ error: 'Access denied: Admin rights required' });
  }
  next();
}

router.use(adminOnly);

// Get security incidents log
router.get('/incidents', (req, res) => {
  res.json({ incidents: securityIncidentsLog });
});

// Get access control list (active bans only)
router.get('/access-control', (req, res) => {
  res.json({
    bannedUsers: Object.fromEntries(getActiveBans(bannedUsers).map(b => [b.value, b])),
    bannedDevices: Object.fromEntries(getActiveBans(bannedDevices).map(b => [b.value, b])),
    bannedIPs: Object.fromEntries(getActiveBans(bannedIPs).map(b => [b.value, b])),
  });
});

// Add a ban with optional expiration and warning
router.post('/bans', (req, res) => {
  const { value, type, reason, warningMessage, expiresAt } = req.body;
  if (!value || !type) {
    return res.status(400).json({ error: 'value and type are required' });
  }

  const ban = {
    value,
    type,
    reason: reason || '',
    warningMessage: warningMessage || '',
    bannedAt: new Date().toISOString(),
    bannedBy: req.user.email,
    expiresAt: expiresAt || null, // null = permanent
  };

  const store = type === 'user' ? bannedUsers : type === 'device' ? bannedDevices : bannedIPs;
  store.set(value.toLowerCase(), ban);

  // If there's a warning message, also create a warning entry
  if (warningMessage) {
    warnings.set(`${type}:${value}`, {
      value,
      type,
      message: warningMessage,
      createdAt: new Date().toISOString(),
      expiresAt: expiresAt || null,
      dismissed: false,
    });
  }

  res.json({ success: true, ban });
});

// Remove a ban
router.delete('/bans/:type/:value', (req, res) => {
  const { type, value } = req.params;
  const store = type === 'user' ? bannedUsers : type === 'device' ? bannedDevices : bannedIPs;
  const decoded = value;
  store.delete(decoded.toLowerCase());
  warnings.delete(`${type}:${decoded}`);
  res.json({ success: true });
});

// Check if an entity is banned (used by auth middleware)
router.get('/bans/check', (req, res) => {
  const { email, deviceId, ip } = req.query;
  const isBanned =
    (email && isBanActive(bannedUsers.get(email.toLowerCase()))) ||
    (deviceId && isBanActive(bannedDevices.get(deviceId))) ||
    (ip && isBanActive(bannedIPs.get(ip)));
  res.json({ banned: !!isBanned });
});

// Get active warnings for a user/device
router.get('/warnings', (req, res) => {
  const { email, deviceId } = req.query;
  const activeWarnings = [];
  for (const [key, entry] of warnings) {
    if (entry.dismissed) continue;
    if (entry.expiresAt && new Date(entry.expiresAt) <= new Date()) continue;
    if (email && entry.type === 'user' && entry.value.toLowerCase() === email.toLowerCase()) {
      activeWarnings.push(entry);
    }
    if (deviceId && entry.type === 'device' && entry.value === deviceId) {
      activeWarnings.push(entry);
    }
  }
  res.json({ warnings: activeWarnings });
});

// Dismiss a warning
router.post('/warnings/dismiss', (req, res) => {
  const { value, type } = req.body;
  const key = `${type}:${value}`;
  const entry = warnings.get(key);
  if (entry) {
    entry.dismissed = true;
  }
  res.json({ success: true });
});

export default router;
