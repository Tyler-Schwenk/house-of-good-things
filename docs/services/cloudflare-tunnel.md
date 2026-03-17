# Cloudflare Tunnel Setup

Cloudflare Tunnel creates a secure connection from your Pi to Cloudflare's edge, allowing public access to your API without exposing ports or configuring port forwarding.

## Current Setup

**Mode:** Quick Tunnel (temporary URL)
**Status:** Operational
**URL:** https://trinity-minus-correctly-lap.trycloudflare.com
**Target:** website-backend-api:8000

**Important:** Quick tunnel URLs are temporary and change on restart. For a permanent custom domain, see "Option 2: Named Tunnel" below.

## Prerequisites

- Docker and Docker Compose
- Website Backend API running on Pi
- Network: Both containers on website-backend_default network

## Benefits

- No port forwarding required
- Free SSL/TLS certificates
- DDoS protection included
- No exposed ports on home router
- Works behind CGNAT
- Can restrict access by country, IP, etc.

## Option 1: Quick Tunnel (Current Setup)

Fast setup with automatic free .trycloudflare.com subdomain. No Cloudflare account required.

**docker-compose.yml:**
```yaml
services:
  cloudflared:
    image: cloudflare/cloudflare:latest
    container_name: cloudflared-tunnel
    restart: unless-stopped
    command: tunnel --url http://website-backend-api:8000
    networks:
      - website-backend_default

networks:
  website-backend_default:
    external: true
```

**Deploy:**
```bash
cd ~/house-of-good-things/services/cloudflared
docker compose up -d
docker compose logs -f
```

**Find your URL:**
Look for this in the logs:
```
Your quick Tunnel has been created! Visit it at:
https://random-words-here.trycloudflare.com
```

**Caveat:** URL changes every container restart. Not suitable for production if you need a stable URL.

## Option 2: Named Tunnel (Permanent URL)

For production with custom domain (api.yoursite.com). Requires Cloudflare account and domain.

### Setup Steps

1. **Create Cloudflare account** and add your domain

2. **Get tunnel token:**
   - Visit https://one.dash.cloudflare.com/
   - Navigate to Zero Trust > Networks > Tunnels
   - Create tunnel named `fart-pi-tunnel`
   - Copy the tunnel token

3. **Update docker-compose.yml:**
```yaml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared-tunnel
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=${TUNNEL_TOKEN}
    networks:
      - website-backend_default

networks:
  website-backend_default:
    external: true
```

4. **Configure environment:**
```bash
cd ~/house-of-good-things/services/cloudflared
cp .env.example .env
nano .env
```

Add your token:
```env
TUNNEL_TOKEN=your-token-here
```

5. **Deploy:**
```bash
docker compose down
docker compose up -d
```

6. **Configure routing in Cloudflare dashboard:**
   - Edit tunnel → Add public hostname
   - Fill form:
     - Public hostname: api.yoursite.com
     - Service: http://website-backend-api:8000
   - Save

### Permanent URL Result

Your API will be accessible at: https://api.yoursite.com

## Update CORS Configuration

After tunnel is running, update Website Backend API to allow requests from tunnel domain:

```bash
cd ~/house-of-good-things/services/website-backend
nano .env
```

Add tunnel domain to CORS_ORIGINS:
```env
CORS_ORIGINS=http://localhost:3000,http://localhost:5173,https://tyler-schwenk.github.io,https://your-tunnel-url.trycloudflare.com
```

Restart:
```bash
docker compose restart
```

## Verification

**Check tunnel status and get URL:**
```bash
cd ~/house-of-good-things/services/cloudflared
docker compose logs
```

Look for: "Your quick Tunnel has been created! Visit it at: https://..."

**Test public access:**

From any device (not on local network):
```bash
curl https://your-tunnel-url.trycloudflare.com/health
```

Should return:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "..."
}
```

**Test in browser:**
- Health: https://your-tunnel-url.trycloudflare.com/health
- Galleries: https://your-tunnel-url.trycloudflare.com/galleries
- API docs: https://your-tunnel-url.trycloudflare.com/docs

## Security Considerations

**Quick Tunnel Mode:**
- Tunnel URL is obscure and hard to guess
- No authentication by default on public endpoints
- Gallery endpoints (GET) are safe to expose publicly
- Write operations (POST/PUT/DELETE) require JWT auth in API

**For production with named tunnel:**
- Use Cloudflare Zero Trust access policies
- Add rate limiting via Cloudflare WAF
- Restrict by country/IP if needed

## Troubleshooting

**Tunnel not starting:**
```bash
docker compose logs cloudflared
```

Common issues:
- Website Backend API container not running
- Network isolation (containers not on same network)
- Port conflict

**Error 1033 or 502:**

Causes:
- Website Backend API not responding
- Wrong service name in tunnel command
- API container crashed

Fix:
```bash
# Check API is running
docker ps | grep website-backend

# Test API locally
curl http://localhost:8000/health

# Restart both services
cd ~/house-of-good-things/services/website-backend
docker compose restart
cd ~/house-of-good-things/services/cloudflared
docker compose restart
```

**CORS errors:**

If frontend gets blocked:
1. Add tunnel URL to CORS_ORIGINS in website-backend/.env
2. Ensure protocol matches (https for tunnel)
3. Restart API container

**URL changed after restart:**

Quick tunnel URLs are temporary. Either:
- Accept new URL and update frontend
- Switch to named tunnel with custom domain (Option 2)

## Monitoring

**Check tunnel health:**
```bash
docker ps | grep cloudflared
docker compose logs cloudflared --tail 50
```

Look for "Registered tunnel connection" messages.

**Beszel monitoring:**
- Tunnel container resource usage tracked automatically
- Alerts if container stops

## Cost

Cloudflare Tunnel is **completely free**:
- Quick tunnel: No account required
- Named tunnel: Free with Cloudflare account
- Unlimited bandwidth and requests
- DDoS protection included
- SSL/TLS certificates included
