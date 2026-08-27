import express from 'express';
import { translateText } from '../services/deepseekClient.js';
import { bannedUsers, bannedDevices, isBanActive } from '../services/store.js';

const router = express.Router();

router.post('/', async (req, res) => {
  try {
    // Bans only block the translator, never admin pages.
    const email = (req.user?.email || '').toLowerCase();
    const deviceId = req.user?.deviceId || req.headers['x-device-id'];
    const userBan = bannedUsers.get(email);
    const deviceBan = bannedDevices.get(deviceId);
    const activeBan = isBanActive(userBan) ? userBan : isBanActive(deviceBan) ? deviceBan : null;
    if (activeBan) {
      return res.status(403).json({
        error: 'Access denied: account is banned',
        reason: activeBan.reason || '',
        warningMessage: activeBan.warningMessage || '',
        expiresAt: activeBan.expiresAt,
      });
    }

    const { sourceText, source_text, sourceLang, source_lang, targetLang, target_lang, userContext, user_context, regionalVariant, regional_variant } = req.body;

    const text = sourceText || source_text;
    if (!text || typeof text !== 'string' || !text.trim()) {
      return res.status(400).json({ error: 'sourceText is required' });
    }

    const sLang = sourceLang || source_lang || 'Auto';
    const tLang = targetLang || target_lang || 'English';
    const uContext = userContext || user_context || '';
    const rVariant = regionalVariant || regional_variant || '';

    const translation = await translateText({
      sourceText: text,
      sourceLang: sLang,
      targetLang: tLang,
      userContext: uContext,
      regionalVariant: rVariant
    });

    return res.json({
      translation,
      sourceText: text,
      sourceLang: sLang,
      targetLang: tLang,
      contextUsed: uContext,
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    console.error('Translation route error:', err.message);
    return res.status(500).json({ error: err.message || 'Translation service error' });
  }
});

export default router;
