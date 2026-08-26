import express from 'express';

const router = express.Router();

export let currentRemoteConfig = {
  version: '1.0.0',
  defaultTemperature: 0.3,
  maxTokens: 2048,
  presetContexts: [
    { id: '1', title: 'Американцу в Slack', context: 'Разговорный формат, США, дружелюбный деловой тон' },
    { id: '2', title: 'Домашка по UK English', context: 'Британский английский, академический академический стиль' },
    { id: '3', title: 'Официальная деловая переписка', context: 'Строгий бизнес-стиль, вежливое обращение' },
    { id: '4', title: 'Разговорный сленг', context: 'Неформальное общение, молодежный сленг' }
  ],
  systemPromptOverride: null,
  reduceTransparencySupported: true
};

router.get('/', (req, res) => {
  res.json(currentRemoteConfig);
});

export default router;
