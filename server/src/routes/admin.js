import express from 'express';
import { securityIncidentsLog } from '../middleware/injectionFilter.js';
import { currentRemoteConfig } from './config.js';

const router = express.Router();

// In-memory ban store (swap for DB in production)
export const bannedUsers = new Map();
export const bannedDevices = new Map();
export const bannedIPs = new Map();

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

// Get access control list
router.get('/access-control', (req, res) => {
  res.json({
    bannedUsers: Object.fromEntries(bannedUsers),
    bannedDevices: Object.fromEntries(bannedDevices),
    bannedIPs: Object.fromEntries(bannedIPs),
  });
});

// Add a ban
router.post('/bans', (req, res) => {
  const { value, type, reason } = req.body;
  if (!value || !type) {
    return res.status(400).json({ error: 'value and type are required' });
  }
  const store = type === 'user' ? bannedUsers : type === 'device' ? bannedDevices : bannedIPs;
  store.set(value, { value, type, reason: reason || '', bannedAt: new Date().toISOString(), bannedBy: req.user.email });
  res.json({ success: true, ban: { value, type, reason } });
});

// Remove a ban
router.delete('/bans/:type/:value', (req, res) => {
  const { type, value } = req.params;
  const store = type === 'user' ? bannedUsers : type === 'device' ? bannedDevices : bannedIPs;
  store.delete(value);
  res.json({ success: true });
});

// Check if an entity is banned (used by auth middleware)
router.get('/bans/check', (req, res) => {
  const { email, deviceId, ip } = req.query;
  const isBanned =
    (email && bannedUsers.has(email.toLowerCase())) ||
    (deviceId && bannedDevices.has(deviceId)) ||
    (ip && bannedIPs.has(ip));
  res.json({ banned: !!isBanned });
});

export default router;
