import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';
import mongoose from 'mongoose';

import { authMiddleware } from './middleware/auth.js';
import { injectionFilterMiddleware } from './middleware/injectionFilter.js';

import translateRouter from './routes/translate.js';
import configRouter from './routes/config.js';
import adminRouter from './routes/admin.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS & JSON parsing
app.use(cors());
app.use(express.json());

// Global Rate Limiting (Section 5.7)
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
    bypassAuth: process.env.BYPASS_AUTH === 'true'
  });
});

// Authentication middleware for all /api endpoints
app.use('/api', authMiddleware);

// Security prompt injection filter middleware (Section 5.2)
app.use('/api', injectionFilterMiddleware);

// Routes
app.use('/api/translate', translateRouter);
app.use('/api/config', configRouter);
app.use('/api/admin', adminRouter);

// Attempt optional MongoDB connection (graceful fallback if MongoDB is offline)
const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/translator';
mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 2000 })
  .then(() => console.log('✅ Connected to MongoDB server'))
  .catch((err) => console.log('⚠️ MongoDB offline/skipped (operating in in-memory mode):', err.message));

app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🚀 Contextual Translator Proxy Backend Running`);
  console.log(`URL: http://localhost:${PORT}`);
  console.log(`DeepSeek Key Status: ${process.env.DEEPSEEK_API_KEY ? 'Present ✅' : 'Missing ❌'}`);
  console.log(`Bypass Auth Mode: ${process.env.BYPASS_AUTH === 'true' ? 'Active (Testing Mode)' : 'Disabled'}`);
  console.log(`====================================================`);
});
