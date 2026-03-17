# Public API Access (Cloudflare Tunnel)

Make your Pi API publicly accessible so your GitHub Pages website can fetch gallery data.

## Why Needed

- GitHub Pages (static site) needs to call your Pi API
- Visitors from anywhere need to load photos
- Without tunnel: API only accessible on local network or via NetBird

## How It Works

```
Visitor's Browser → api.yoursite.com (Cloudflare) → Tunnel → Pi → API
```

- **Secure**: No ports open on router, tunnel is outbound from Pi
- **Fast**: Cloudflare CDN caching
- **Safe**: Read-only gallery endpoints are public, write operations still require auth

## Setup (One-Time)

### 1. Create Tunnel

Visit: https://one.dash.cloudflare.com/
- Navigate to Zero Trust > Networks > Tunnels
- Create tunnel named `fart-pi-tunnel`
- Copy the token

### 2. Deploy Tunnel Container

On Pi:
```bash
mkdir -p ~/house-of-good-things/services/cloudflared
cd ~/house-of-good-things/services/cloudflared
nano docker-compose.yml
```

Paste:
```yaml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared-tunnel
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=YOUR_TOKEN_HERE
    networks:
      - website-backend_default

networks:
  website-backend_default:
    external: true
```

Start:
```bash
docker compose up -d
```

### 3. Configure Routing

In Cloudflare dashboard under your tunnel:
- Public hostname: `api.yoursite.com`
- Service: `http://website-backend-api:8000`
- Save

### 4. Update CORS

```bash
cd ~/house-of-good-things/services/website-backend
nano .env
```

Add tunnel domain:
```env
CORS_ORIGINS=http://localhost:3000,https://tyler-schwenk.github.io,https://api.yoursite.com
```

Restart:
```bash
docker compose restart
```

## Test

```bash
# From anywhere
curl https://api.yoursite.com/health
curl https://api.yoursite.com/galleries
```

## Using in Frontend

```typescript
const API_URL = 'https://api.yoursite.com';

// Fetch gallery
const gallery = await fetch(`${API_URL}/galleries/slug/jordan`).then(r => r.json());

// Display photo
<img src={`${API_URL}/galleries/photos/${photo.id}/file?thumbnail=true`} />
```

Done! Your website can now load photos from Pi for all visitors.
