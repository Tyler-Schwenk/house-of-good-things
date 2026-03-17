# Cloudflare Tunnel Setup

Cloudflare Tunnel creates a secure connection from your Pi to Cloudflare's edge, allowing public access to your API without exposing ports or configuring port forwarding.

## Prerequisites

- Cloudflare account (free tier works)
- Domain name managed by Cloudflare (optional - can use trycloudflare.com subdomain)
- Website Backend API running on Pi

## Benefits

- No port forwarding required
- Free SSL/TLS certificates
- DDoS protection included
- No exposed ports on home router
- Works behind CGNAT
- Can restrict access by country, IP, etc.

## Installation

### Option 1: Docker (Recommended)

Create Cloudflare Tunnel service:

```bash
cd ~/house-of-good-things/services
mkdir -p cloudflared
cd cloudflared
```

**docker-compose.yml:**
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
      - website-backend-network

networks:
  website-backend-network:
    external: true
    name: website-backend_default
```

### Option 2: Native Installation

```bash
# Install cloudflared
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o cloudflared
sudo mv cloudflared /usr/local/bin/
sudo chmod +x /usr/local/bin/cloudflared

# Authenticate with Cloudflare
cloudflared tunnel login
```

## Setup Steps

### 1. Create Tunnel

Visit Cloudflare Zero Trust dashboard or use CLI:

```bash
# Via CLI
cloudflared tunnel create fart-pi-tunnel

# This creates a tunnel ID and credentials file
# Save the tunnel ID - you'll need it
```

Or via dashboard:
1. Go to https://one.dash.cloudflare.com/
2. Navigate to Networks > Tunnels
3. Click "Create a tunnel"
4. Name it: `fart-pi-tunnel`
5. Choose environment: Docker
6. Copy the tunnel token

### 2. Configure Tunnel Routing

Map your public hostname to the internal service:

**Via Dashboard:**
1. In tunnel settings, add public hostname
2. Subdomain: `api` (or whatever you want)
3. Domain: `yoursite.com`
4. Service: `http://website-backend-api:8000`
5. Save

**Via config file (config.yml):**
```yaml
tunnel: <your-tunnel-id>
credentials-file: /etc/cloudflared/credentials.json

ingress:
  - hostname: api.yoursite.com
    service: http://website-backend-api:8000
  - service: http_status:404
```

### 3. Deploy Tunnel

**Docker method:**
```bash
cd ~/house-of-good-things/services/cloudflared
echo "TUNNEL_TOKEN=<your-token-from-dashboard>" > .env
docker compose up -d
```

**Native method:**
```bash
# Copy config to system location
sudo mkdir -p /etc/cloudflared
sudo cp config.yml /etc/cloudflared/

# Install as systemd service
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

### 4. Update CORS Configuration

Update Website Backend API to allow requests from your domain:

```bash
cd ~/house-of-good-things/services/website-backend
nano .env
```

Add your domain to CORS_ORIGINS:
```env
CORS_ORIGINS=https://yourusername.github.io,https://api.yoursite.com
```

Restart Website Backend API:
```bash
docker compose restart
```

## Verification

### Check Tunnel Status

**Docker:**
```bash
docker logs cloudflared-tunnel
```

**Native:**
```bash
sudo systemctl status cloudflared
```

Look for: "Registered tunnel connection"

### Test Public Access

From your phone (not on home network):
```bash
curl https://api.yoursite.com/health
```

Should return:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2026-03-15T..."
}
```

### Test API Documentation

Visit in browser: `https://api.yoursite.com/docs`

Should show Swagger UI with all endpoints.

## Using Free Subdomain

If you don't have a domain, Cloudflare provides free subdomains:

1. Create tunnel as normal
2. Instead of custom domain, use: `<random>.trycloudflare.com`
3. Cloudflare generates a unique URL
4. Note: URL may change if tunnel restarts

To get persistent free subdomain, you can register a free domain at:
- Freenom (free .tk, .ml, .ga, .cf, .gq domains)
- Add domain to Cloudflare
- Use with tunnel

## Security Considerations

### Add Access Policies

Restrict who can access your API:

1. Go to Cloudflare Zero Trust > Access > Applications
2. Create application for your API hostname
3. Add policies:
   - Allow specific countries only
   - Allow specific email domains
   - Require authentication for admin endpoints

### Rate Limiting

Add rate limiting in Cloudflare dashboard:
1. Go to Security > WAF
2. Create rate limiting rule
3. Set threshold (e.g., 100 requests/minute per IP)

### Authentication

For sensitive endpoints (photo uploads, post creation), implement:
- JWT authentication in API (already configured)
- Cloudflare Access for additional layer

## Troubleshooting

### Tunnel Not Connecting

Check tunnel status:
```bash
docker logs cloudflared-tunnel
# or
sudo journalctl -u cloudflared -f
```

Common issues:
- Invalid tunnel token
- Network connectivity issues
- Service name mismatch in routing

### 502 Bad Gateway

Causes:
- Website Backend API not running
- Wrong service name/port in tunnel config
- Network isolation between containers

Fix:
```bash
# Ensure API is running
docker ps | grep website-backend

# Check if tunnel can reach API
docker exec cloudflared-tunnel ping website-backend-api

# Verify API responds locally
curl http://localhost:8000/health
```

### CORS Errors

If frontend gets CORS errors:
1. Check CORS_ORIGINS in .env includes your domain
2. Ensure protocol matches (https vs http)
3. Restart API after CORS changes

## Monitoring

Check tunnel health:
- Cloudflare dashboard shows connection status
- Alert on tunnel disconnections
- Monitor 5xx errors in Cloudflare Analytics

Add to Beszel monitoring:
```bash
# Add tunnel container to Beszel monitoring
# It will track if container stops
```

## Cost

Cloudflare Tunnel is **completely free** for personal use:
- Unlimited bandwidth
- Unlimited requests
- DDoS protection included
- SSL/TLS certificates included

## Alternative: Using Cloudflare Pages/Workers

For even tighter integration, you can deploy your frontend to Cloudflare Pages and use Workers for API routing, but tunnel is simpler for now.
