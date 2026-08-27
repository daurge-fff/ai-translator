import express from 'express';
import { bannedUsers, bannedDevices, isBanActive } from '../services/store.js';

const router = express.Router();

// Public: current user's ban status (email + device).
// Does not require admin rights so that even a banned user can check it.
router.get('/status', (req, res) => {
  const email = (req.user?.email || '').toLowerCase();
  const deviceId = req.user?.deviceId || req.headers['x-device-id'];

  const userBan = bannedUsers.get(email);
  const deviceBan = bannedDevices.get(deviceId);
  const ban = isBanActive(userBan) ? userBan : isBanActive(deviceBan) ? deviceBan : null;

  if (!ban) {
    return res.json({ banned: false });
  }

  res.json({
    banned: true,
    reason: ban.reason || '',
    warningMessage: ban.warningMessage || '',
    expiresAt: ban.expiresAt,
  });
});

export default router;
