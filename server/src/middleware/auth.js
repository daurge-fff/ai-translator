import dotenv from 'dotenv';
import { OAuth2Client } from 'google-auth-library';

dotenv.config();

const googleClient = new OAuth2Client();

export async function authMiddleware(req, res, next) {
  const adminEmails = (process.env.ADMIN_EMAILS || '').split(',').map(e => e.trim().toLowerCase());
  const isBypass = process.env.BYPASS_AUTH === 'true' || process.env.NODE_ENV === 'development';

  const authHeader = req.headers.authorization;
  const deviceId = req.headers['x-device-id'] || 'dev-device-local-uuid';

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    if (isBypass) {
      req.user = {
        sub: 'mock-google-sub-12345',
        email: adminEmails[0] || 'admin@example.com',
        name: 'Demo Admin User',
        avatar: 'https://lh3.googleusercontent.com/a/default-user',
        isAdmin: true,
        deviceId
      };
      return next();
    }
    return res.status(401).json({ error: 'Missing or invalid Authorization header' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // If testing with mock token in headers
    if (isBypass && (token === 'mock-token' || token.startsWith('demo-'))) {
      req.user = {
        sub: 'mock-google-sub-12345',
        email: adminEmails[0] || 'admin@example.com',
        name: 'Demo Admin User',
        avatar: 'https://lh3.googleusercontent.com/a/default-user',
        isAdmin: true,
        deviceId
      };
      return next();
    }

    const ticket = await googleClient.verifyIdToken({
      idToken: token,
    });
    const payload = ticket.getPayload();

    const email = (payload.email || '').toLowerCase();
    const isAdmin = adminEmails.includes(email);

    req.user = {
      sub: payload.sub,
      email: payload.email,
      name: payload.name || payload.email,
      avatar: payload.picture,
      isAdmin,
      deviceId
    };
    next();
  } catch (err) {
    if (isBypass) {
      req.user = {
        sub: 'mock-google-sub-12345',
        email: adminEmails[0] || 'admin@example.com',
        name: 'Demo Admin User',
        avatar: 'https://lh3.googleusercontent.com/a/default-user',
        isAdmin: true,
        deviceId
      };
      return next();
    }
    return res.status(401).json({ error: 'Invalid Google ID Token: ' + err.message });
  }
}
