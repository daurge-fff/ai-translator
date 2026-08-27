# Deploying AI Translator Server on aaPanel + Docker

## Prerequisites
- VPS with aaPanel installed (Ubuntu 22.04 recommended)
- Docker installed via aaPanel (App Store → Docker)
- Domain pointed to your VPS IP (e.g. `api.yourdomain.com`)
- DeepSeek API key

---

## Step 1: Upload Server Files

1. In aaPanel, go to **Files** → navigate to `/www/wwwroot/`
2. Create folder `ai-translator-server`
3. Upload the entire `server/` folder contents into it:
   - `src/`
   - `package.json`
   - `Dockerfile`
   - `docker-compose.yml`
   - `.env` (create from `.env.example`)

---

## Step 2: Configure .env

Create `/www/wwwroot/ai-translator-server/.env`:

```
PORT=8080
NODE_ENV=production
DEEPSEEK_API_KEY=sk-your-key-here
MONGO_URI=mongodb://mongo:27017/translator
ADMIN_EMAILS=germangpt3@gmail.com
BYPASS_AUTH=false
GOOGLE_CLIENT_ID=841057078666-fmstis3g9qm2tlp7bisf0reh69q2173l.apps.googleusercontent.com
```

---

## Step 3: Build & Run with Docker

### Option A: docker-compose (recommended)

```bash
cd /www/wwwroot/ai-translator-server
docker compose up -d --build
```

This starts two containers:
- `proxy` (Node.js API) on port **8080**
- `mongo` (MongoDB 8) on port **27017** (internal only)

### Option B: Manual Docker

```bash
cd /www/wwwroot/ai-translator-server

# Build image
docker build -t ai-translator-api .

# Run
docker run -d \
  --name ai-translator-api \
  --restart unless-stopped \
  -p 127.0.0.1:8080:8080 \
  --env-file .env \
  ai-translator-api
```

---

## Step 4: Set Up Reverse Proxy in aaPanel

1. Go to **Website** → **Add Site**
2. Enter your domain: `api.yourdomain.com`
3. PHP version: **Pure static** (or leave default)
4. After site is created, click **Settings** → **Reverse Proxy**
5. Add reverse proxy:
   - **Proxy Name**: `ai-translator`
   - **Target URL**: `http://127.0.0.1:8080`
   - Enable **Send Domain** and **Enable WebSocket**

### Or manually create Nginx config:

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    client_max_body_size 10m;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 30s;
        proxy_read_timeout 30s;
    }
}
```

---

## Step 5: Add SSL Certificate (Let's Encrypt)

1. In aaPanel → **Website** → select your site → **SSL**
2. Click **Let's Encrypt** → select your domain → **Apply**
3. After cert is issued, enable **HTTPS Redirect**

---

## Step 6: Update Flutter App to Use Production Server

In `lib/core/constants/api_constants.dart`:

```dart
static String get baseUrl {
  if (kDebugMode) {
    // Development
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }
  // Production
  return 'https://api.yourdomain.com';
}
```

---

## Step 7: Update Google OAuth for Production

In [Google Cloud Console](https://console.cloud.google.com/apis/credentials):
1. Add OAuth client for your production domain
2. Add authorized redirect URIs: `https://api.yourdomain.com/*`
3. Update `GOOGLE_CLIENT_ID` in `.env` if needed

---

## Ports Summary

| Service | Container Port | Host Port | Binding |
|---------|---------------|-----------|---------|
| Node.js API | 8080 | 8080 | 127.0.0.1 (internal) |
| MongoDB | 27017 | 27017 | 127.0.0.1 (internal) |
| Nginx (aaPanel) | 80/443 | 80/443 | 0.0.0.0 (public) |

Only Nginx is exposed publicly. API and MongoDB are bound to localhost.

---

## Useful Commands

```bash
# Check containers
docker ps

# View logs
docker logs ai-translator-api -f

# Restart
docker restart ai-translator-api

# Stop
docker stop ai-translator-api

# Rebuild after code changes
docker compose up -d --build

# Enter container shell
docker exec -it ai-translator-api sh
```

---

## Health Check

```bash
curl https://api.yourdomain.com/health
```

Expected:
```json
{
  "status": "ok",
  "service": "Contextual Translator API",
  "bypassAuth": false
}
```
