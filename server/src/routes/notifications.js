import express from 'express';
import {
  notifications,
  addNotification,
  deleteNotification,
  markNotificationRead,
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

// ── Public: Get notifications for current user ──────────────────────
router.get('/', (req, res) => {
  const userEmail = req.user?.email;
  const deviceId = req.headers['x-device-id'];

  const myNotifications = notifications.filter(n => {
    // Targeted notifications
    if (n.targetEmail && n.targetEmail !== userEmail) return false;
    if (n.targetDeviceId && n.targetDeviceId !== deviceId) return false;
    // Global notifications (no target)
    return true;
  }).map(n => ({
    ...n,
    isRead: n.readBy?.includes(userEmail) || false,
  }));

  res.json({ notifications: myNotifications });
});

// ── Public: Mark notification as read ──────────────────────────────
router.post('/:id/read', async (req, res) => {
  const { id } = req.params;
  const userEmail = req.user?.email;
  await markNotificationRead(id, userEmail);
  res.json({ success: true });
});

// ── Admin: Send notification ──────────────────────────────────────
router.post('/send', adminOnly, async (req, res) => {
  const { title, body, targetEmail, targetDeviceId } = req.body;
  if (!title || !body) {
    return res.status(400).json({ error: 'title and body are required' });
  }

  const notification = {
    id: Date.now().toString(),
    title,
    body,
    targetEmail: targetEmail || null,
    targetDeviceId: targetDeviceId || null,
    createdAt: new Date().toISOString(),
    readBy: [],
    sentBy: req.user.email,
  };

  await addNotification(notification);

  res.json({ success: true, notification });
});

// ── Admin: Get all notifications ──────────────────────────────────
router.get('/all', adminOnly, (req, res) => {
  res.json({ notifications });
});

// ── Admin: Delete notification ────────────────────────────────────
router.delete('/:id', adminOnly, async (req, res) => {
  const { id } = req.params;
  await deleteNotification(id);
  res.json({ success: true });
});

export default router;
