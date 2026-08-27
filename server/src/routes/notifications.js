import express from 'express';

const router = express.Router();

// In-memory notification store (swap for DB in production)
const notifications = []; // { id, title, body, targetEmail, targetDeviceId, createdAt, readBy: [] }

// Middleware to enforce admin access
function adminOnly(req, res, next) {
  if (!req.user || !req.user.isAdmin) {
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
router.post('/:id/read', (req, res) => {
  const { id } = req.params;
  const userEmail = req.user?.email;
  const notif = notifications.find(n => n.id === id);
  if (notif && !notif.readBy?.includes(userEmail)) {
    notif.readBy = notif.readBy || [];
    notif.readBy.push(userEmail);
  }
  res.json({ success: true });
});

// ── Admin: Send notification ──────────────────────────────────────
router.post('/send', adminOnly, (req, res) => {
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

  notifications.unshift(notification);
  if (notifications.length > 200) notifications.pop();

  res.json({ success: true, notification });
});

// ── Admin: Get all notifications ──────────────────────────────────
router.get('/all', adminOnly, (req, res) => {
  res.json({ notifications });
});

// ── Admin: Delete notification ────────────────────────────────────
router.delete('/:id', adminOnly, (req, res) => {
  const { id } = req.params;
  const idx = notifications.findIndex(n => n.id === id);
  if (idx !== -1) notifications.splice(idx, 1);
  res.json({ success: true });
});

export default router;
