import express from 'express';
import { securityIncidentsLog } from '../middleware/injectionFilter.js';
import { currentRemoteConfig } from './config.js';

const router = express.Router();

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

// Update remote config dynamically
router.post('/config', (req, res) => {
  const { defaultTemperature, maxTokens, systemPromptOverride, presetContexts } = req.body;
  if (defaultTemperature !== undefined) currentRemoteConfig.defaultTemperature = defaultTemperature;
  if (maxTokens !== undefined) currentRemoteConfig.maxTokens = maxTokens;
  if (systemPromptOverride !== undefined) currentRemoteConfig.systemPromptOverride = systemPromptOverride;
  if (presetContexts !== undefined) currentRemoteConfig.presetContexts = presetContexts;

  res.json({ success: true, config: currentRemoteConfig });
});

// Get access control list
router.get('/access-control', (req, res) => {
  res.json({
    bannedUsers: [],
    bannedDevices: [],
    bannedIPs: []
  });
});

export default router;
