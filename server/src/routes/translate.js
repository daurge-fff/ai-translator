import express from 'express';
import { translateText } from '../services/deepseekClient.js';

const router = express.Router();

router.post('/', async (req, res) => {
  try {
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
