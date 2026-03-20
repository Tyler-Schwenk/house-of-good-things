# Public API Access (Cloudflare Tunnel)

**Note:** This guide is for quick tunnel (temporary URL). See [custom-domain-setup.md](custom-domain-setup.md) for permanent setup with tyler-schwenk.com.

Make your Pi API publicly accessible so your GitHub Pages website can fetch gallery data.

## Why Needed

- GitHub Pages (static site) needs to call your Pi API
- Visitors from anywhere need to load photos
- Without tunnel: API only accessible on local network or via NetBird

## How It Works

```
Visitor's Browser → random.trycloudflare.com (Cloudflare) → Tunnel → Pi → API
```

- **Secure**: No ports open on router, tunnel is outbound from Pi
- **Fast**: Cloudflare CDN caching
- **Safe**: Read-only gallery endpoints are public, write operations still require auth

## Quick Setup (Current)

### 1. Deploy Tunnel Container

On Pi:
```bash
cd ~/house-of-good-things/services/cloudflared
docker compose up -d
docker compose logs -f
```

Look for:
```
Your quick Tunnel has been created! Visit it at:
https://trinity-minus-correctly-lap.trycloudflare.com
```

### 2. Update CORS

```bash
cd ~/house-of-good-things/services/website-backend
nano .env
```

Add tunnel URL:
```env
CORS_ORIGINS=http://localhost:3000,http://localhost:5173,https://tyler-schwenk.github.io,https://trinity-minus-correctly-lap.trycloudflare.com
```

Restart:
```bash
docker compose restart
```

### 3. Test

From your phone or any device:
```
https://trinity-minus-correctly-lap.trycloudflare.com/health
https://trinity-minus-correctly-lap.trycloudflare.com/galleries
```

## Using in Frontend

```typescript
const API_URL = 'https://trinity-minus-correctly-lap.trycloudflare.com';

// Fetch gallery
const gallery = await fetch(`${API_URL}/galleries/slug/jordan`).then(r => r.json());

// Display photo
<img src={`${API_URL}/galleries/photos/${photo.id}/file?thumbnail=true`} />
```

**Important:** Quick tunnel URL changes on restart. For permanent URL, get a custom domain and use named tunnel setup (see docs/services/cloudflare-tunnel.md).

Done! Your website can now load photos from Pi for all visitors.
