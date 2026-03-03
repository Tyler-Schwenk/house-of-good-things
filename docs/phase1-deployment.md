# Phase 1 Deployment Guide

Step-by-step guide for deploying Tailscale and Public Square API on fart-pi.

## Prerequisites

- Raspberry Pi 5 running Raspberry Pi OS
- Network access to Pi (same local network, Pi Connect, or physical access)
- Docker and Docker Compose installed on Pi
- Git installed on Pi
- Tailscale account created at https://login.tailscale.com
- Auth key generated and saved (see [pre-deployment.md](pre-deployment.md))

**Network Access Note:** If you're remote (coffee shop, etc.), use Raspberry Pi Connect or wait until you're on the same network as the Pi. After Tailscale is deployed, you can access from anywhere.

## Deployment Overview

Phase 1 consists of two services:
1. **Tailscale**: VPN for remote access and Funnel feature
2. **Public Square**: Forum API backend

Total deployment time: 30-45 minutes

## Step 1: Repository Setup

### 1.1 Clone Repository

SSH into the Pi:
```bash
ssh tyler@192.168.1.115
```

Clone the repository:
```bash
cd ~
git clone <repository-url> house-of-good-things
cd house-of-good-things
```

### 1.2 Verify Structure

```bash
ls -la services/
```

Should show:
```
public-square/
tailscale/
```

## Step 2: Deploy Tailscale

### 2.1 Get Tailscale Auth Key

1. Visit https://login.tailscale.com/admin/settings/keys
2. Click "Generate auth key"
3. Configure:
   - Reusable: Yes
   - Ephemeral: No
   - Pre-approved: Yes
4. Copy the key (starts with `tskey-auth-`)

### 2.2 Configure Tailscale

```bash
cd ~/house-of-good-things/services/tailscale
cp .env.example .env
nano .env
```

Paste your auth key:
```env
TS_AUTHKEY=tskey-auth-XXXXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Save and exit (Ctrl+X, Y, Enter).

### 2.3 Deploy Tailscale Container

```bash
docker compose up -d
```

### 2.4 Verify Tailscale Connection

```bash
# Check container status
docker compose ps

# View logs
docker compose logs -f

# Check Tailscale status (wait 10-15 seconds after startup)
docker exec tailscale tailscale status

# Get Tailscale IP
docker exec tailscale tailscale ip -4
```

Expected output:
- Container status: Up
- Tailscale status: Shows your Tailnet and connected devices
- Tailscale IP: Something like `100.x.x.x`

### 2.5 Test Remote Access

From your laptop (with Tailscale installed and connected):

```bash
# SSH via Tailscale
ssh tyler@fart-pi

# Or use IP
ssh tyler@100.x.x.x
```

Success! You can now access the Pi from anywhere.

## Step 3: Deploy Public Square API

### 3.1 Generate JWT Secret

On the Pi:
```bash
openssl rand -hex 32
```

Copy the output (64-character hex string).

### 3.2 Configure Public Square

```bash
cd ~/house-of-good-things/services/public-square
cp .env.example .env
nano .env
```

Update the file:
```env
JWT_SECRET=<paste-your-generated-secret-here>
CORS_ORIGINS=https://yourusername.github.io
```

Replace `yourusername.github.io` with your actual GitHub Pages domain.

Save and exit.

### 3.3 Build and Deploy

```bash
# Build the Docker image (first time only, takes 2-3 minutes)
docker compose build

# Start the service
docker compose up -d

# View logs
docker compose logs -f
```

Wait for the message: "Uvicorn running on http://0.0.0.0:8000"

Press Ctrl+C to exit logs.

### 3.4 Verify API

From the Pi:
```bash
# Test health endpoint
curl http://localhost:8000/health

# Test root endpoint
curl http://localhost:8000/
```

Expected responses: JSON with status and version info.

### 3.5 Test API Documentation

From your laptop (via Tailscale):

Visit: `http://fart-pi:8000/docs`

You should see the interactive Swagger UI documentation.

## Step 4: Enable Public Access

### 4.1 Enable Tailscale Funnel

On the Pi:
```bash
docker exec tailscale tailscale funnel 8000
```

### 4.2 Get Public URL

```bash
docker exec tailscale tailscale funnel status
```

Note the public URL. It will be something like:
```
https://fart-pi.your-tailnet.ts.net:8000
```

### 4.3 Test Public Access

From any device (without Tailscale):

Visit the public URL in a browser. You should see:
```json
{
  "name": "Public Square API",
  "version": "1.0.0",
  "docs": "/docs",
  "health": "/health"
}
```

Success! Your API is publicly accessible.

## Step 5: Verification Checklist

On the Pi:
```bash
# Check all containers
docker ps

# Should show:
# - tailscale (Up)
# - public-square-api (Up, healthy)
```

Test access methods:
- [ ] SSH via Tailscale: `ssh tyler@fart-pi`
- [ ] API via local network: `http://192.168.1.115:8000`
- [ ] API via Tailscale: `http://fart-pi:8000`
- [ ] API via public URL: `https://fart-pi.your-tailnet.ts.net:8000`
- [ ] API docs accessible: `https://fart-pi.your-tailnet.ts.net:8000/docs`

## Step 6: Update Frontend

In your frontend code, update the API URL:

```javascript
const API_URL = 'https://fart-pi.your-tailnet.ts.net:8000';
```

## Common Issues

### Tailscale Won't Connect

```bash
# Check logs
cd ~/house-of-good-things/services/tailscale
docker compose logs

# Verify auth key is correct
cat .env

# Restart
docker compose restart
```

### Public Square Build Fails

```bash
# Check logs
cd ~/house-of-good-things/services/public-square
docker compose logs

# Rebuild
docker compose build --no-cache
docker compose up -d
```

### Funnel Not Working

```bash
# Check Funnel status
docker exec tailscale tailscale funnel status

# Re-enable if needed
docker exec tailscale tailscale funnel --remove 8000
docker exec tailscale tailscale funnel 8000
```

### Port 8000 Already in Use

```bash
# Check what's using the port
sudo netstat -tulpn | grep 8000

# Stop conflicting service or change port in docker-compose.yml
```

## Maintenance

### View Logs

```bash
# Tailscale logs
cd ~/house-of-good-things/services/tailscale
docker compose logs -f

# Public Square logs
cd ~/house-of-good-things/services/public-square
docker compose logs -f
```

### Restart Services

```bash
# Restart Tailscale
cd ~/house-of-good-things/services/tailscale
docker compose restart

# Restart Public Square
cd ~/house-of-good-things/services/public-square
docker compose restart
```

### Update Services

```bash
cd ~/house-of-good-things

# Pull latest code
git pull

# Rebuild Public Square if code changed
cd services/public-square
docker compose build
docker compose down
docker compose up -d

# Tailscale usually doesn't need rebuilding
```

### Backup Database

```bash
cd ~/house-of-good-things/services/public-square
cp data/public_square.db data/public_square.db.$(date +%Y%m%d_%H%M%S)
```

## Next Steps

1. Implement API router modules (auth, posts, comments)
2. Test authentication flow
3. Connect frontend to API
4. Add rate limiting to endpoints
5. Test from multiple devices
6. Monitor logs for issues

## Rollback

If something goes wrong:

```bash
# Stop services
cd ~/house-of-good-things/services/public-square
docker compose down

cd ~/house-of-good-things/services/tailscale
docker compose down

# Restart
docker compose up -d
```

## Security Reminders

- Keep `.env` files secure
- Never commit `.env` to Git
- Use strong JWT secret (32+ bytes)
- Monitor API logs for suspicious activity
- Keep Docker images updated
- Review Tailscale admin panel regularly
