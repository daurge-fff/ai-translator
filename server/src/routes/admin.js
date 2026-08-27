import express from 'express';
import {
  bannedUsers,
  bannedDevices,
  bannedIPs,
  warnings,
  securityIncidentsLog,
  isBanActive,
  getActiveBans,
  addBan,
  removeBan,
  addWarning,
  dismissWarning,
} from '../services/store.js';

const router = express.Router();

// Middleware to enforce admin access
function adminOnly(req, res, next) {
  if (!req.user || !req.user.isAdmin) {
    console.warn(`[ADMIN] blocked non-admin: ${req.user?.email || 'anonymous'} → ${req.method} ${req.originalUrl}`);
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
router.post('/bans', async (req, res) => {
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

  await addBan(ban);

  // If there's a warning message, also create a warning entry
  if (warningMessage) {
    await addWarning({
      value,
      type,
      message: warningMessage,
      createdAt: new Date().toISOString(),
      expiresAt: expiresAt || null,
    });
  }

  res.json({ success: true, ban });
});

// Remove a ban
router.delete('/bans/:type/:value', async (req, res) => {
  const { type, value } = req.params;
  await removeBan(type, value);
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
router.post('/warnings/dismiss', async (req, res) => {
  const { value, type } = req.body;
  await dismissWarning(type, value);
  res.json({ success: true });
});

export default router;
