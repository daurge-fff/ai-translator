import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';

import { authMiddleware } from './middleware/auth.js';
import { injectionFilterMiddleware } from './middleware/injectionFilter.js';
import { initStore, storeStatus } from './services/store.js';

import translateRouter from './routes/translate.js';
import configRouter from './routes/config.js';
import adminRouter from './routes/admin.js';
import notificationsRouter from './routes/notifications.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3214;

// Trust nginx reverse proxy for correct client IPs in rate limiting
app.set('trust proxy', 1);

// Enable CORS & JSON parsing
app.use(cors({
  origin: (process.env.ALLOWED_ORIGINS || '').split(',').filter(Boolean),
  credentials: true,
}));
app.use(express.json());

// Global Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { error: 'Too many requests, please try again later.' }
});
app.use(limiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'Contextual Translator API',
    bypassAuth: process.env.BYPASS_AUTH === 'true',
    store: storeStatus(),
  });
});

// Authentication middleware for all /api endpoints
app.use('/api', authMiddleware);

// Security prompt injection filter middleware
app.use('/api', injectionFilterMiddleware);

// Routes
app.use('/api/translate', translateRouter);
app.use('/api/config', configRouter);
app.use('/api/admin', adminRouter);
app.use('/api/notifications', notificationsRouter);

// Global error handler
app.use((err, req, res, next) => {
  console.error('[ERROR]', err.message);
  res.status(500).json({ error: 'Internal server error' });
});

// Optional MongoDB Atlas connection (durable store for bans/notifications/incidents)
const mongoUri = process.env.MONGO_URI;
initStore(mongoUri).then(() => {
  console.log(`   Store: ${storeStatus().mongoEnabled ? 'MongoDB ✅' : 'In-memory ⚠️'}`);
});

app.listen(PORT, () => {
  console.log(`🚀 Contextual Translator API running on port ${PORT}`);
  console.log(`   DeepSeek Key: ${process.env.DEEPSEEK_API_KEY ? '✅' : '❌'}`);
  console.log(`   Auth Bypass: ${process.env.BYPASS_AUTH === 'true' ? '✅' : '❌'}`);
  console.log(`   MongoDB: ${mongoUri ? 'configured' : 'not set'}`);
});
