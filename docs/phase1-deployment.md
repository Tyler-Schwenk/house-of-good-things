# Phase 1 Deployment Guide

Step-by-step guide for deploying NetBird and Public Square API on fart-pi.

## Prerequisites

- Raspberry Pi 5 running Raspberry Pi OS
- Network access to Pi (same local network, Pi Connect, or physical access)
- Docker and Docker Compose installed on Pi
- Git installed on Pi
- NetBird account on John's self-hosted instance: https://johnserv.garrepi.dev
- Setup key generated and saved (see [pre-deployment.md](pre-deployment.md))

**Network Access Note:** If you're remote (coffee shop, etc.), use Raspberry Pi Connect or wait until you're on the same network as the Pi. After NetBird is deployed, you can access from anywhere via the Bird Wide Web network.

## Deployment Overview

Phase 1 consists of two services:
1. **NetBird**: VPN for remote access as part of Bird Wide Web
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
netbird/
public-square/
```

## Step 2: Deploy NetBird

### 2.1 Get NetBird Setup Key

1. Visit **https://johnserv.garrepi.dev**
2. Navigate to "Setup Keys" in the sidebar
3. Click "Create Setup Key"
4. Configure:
   - Name: fart-pi (or descriptive name)
   - Type: Reusable
   - Expiration: Choose appropriate duration (e.g., 30 days)
   - Auto-assign groups: (optional)
5. Copy the generated setup key

### 2.2 Configure NetBird

```bash
cd ~/house-of-good-things/services/netbird
cp .env.example .env
nano .env
```

Paste your setup key:
```env
NB_SETUP_KEY=your-setup-key-here
```

Save and exit (Ctrl+X, Y, Enter).

### 2.3 Deploy NetBird Container

```bash
docker compose up -d
```

### 2.4 Verify NetBird Connection

```bash
# Check container status
docker compose ps

# View logs
docker compose logs -f

# Check NetBird status (wait 10-15 seconds after startup)
docker exec netbird netbird status
```

Expected output:
- Container status: Up
- NetBird status: Shows connected peers and your IP
- NetBird IP: 100.124.76.27

### 2.5 Test Remote Access

From your laptop (with NetBird installed and connected to the same network):

```bash
# SSH via NetBird hostname
ssh tyler@fart-pi.johnserv.garrepi.dev

# Or use IP
ssh tyler@100.124.76.27
```

Success! You can now access the Pi from anywhere via the Bird Wide Web network.

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

From your laptop (via NetBird):

Visit: `http://fart-pi.johnserv.garrepi.dev:8000/docs` or `http://100.124.76.27:8000/docs`

You should see the interactive Swagger UI documentation.

## Step 4: Verify NetBird Access

### 4.1 Test from NetBird Network

From any device connected to the Bird Wide Web NetBird network:

Visit the API URL in a browser:
- `http://fart-pi.johnserv.garrepi.dev:8000`
- Or: `http://100.124.76.27:8000`

You should see:
```json
{
  "name": "Public Square API",
  "version": "1.0.0",
  "docs": "/docs",
  "health": "/health"
}
```

### 4.2 Access from Friends' Servers

Your API is now accessible to all peers on the Bird Wide Web network, including:
- JohnSERV (100.124.56.240)
- JohnNAS
- Bebop

Success! Your API is accessible across the mesh network.

## Step 5: Verification Checklist

On the Pi:
```bash
# Check all containers
docker ps

# Should show:
# - netbird (Up)
# - public-square-api (Up, healthy)
```

Test access methods:
- [ ] SSH via NetBird: `ssh tyler@fart-pi.johnserv.garrepi.dev`
- [ ] API via local network: `http://192.168.1.115:8000`
- [ ] API via NetBird hostname: `http://fart-pi.johnserv.garrepi.dev:8000`
- [ ] API via NetBird IP: `http://100.124.76.27:8000`
- [ ] API docs accessible: `http://fart-pi.johnserv.garrepi.dev:8000/docs`

## Step 6: Update Frontend

In your frontend code, update the API URL to use NetBird access:

```javascript
// For Bird Wide Web network access
const API_URL = 'http://fart-pi.johnserv.garrepi.dev:8000';
// Or use IP: 'http://100.124.76.27:8000'
```

**Note:** If you need public access (without NetBird), you'll need to set up a reverse proxy with a public domain or use a service like Cloudflare Tunnel.

## Common Issues

### NetBird Won't Connect

```bash
# Check logs
cd ~/house-of-good-things/services/netbird
docker compose logs

# Verify setup key is correct
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

### Network Access Not Working

```bash
# Check NetBird status
docker exec netbird netbird status

# Verify peers are connected
# Check NetBird dashboard at https://app.netbird.io
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
# NetBird logs
cd ~/house-of-good-things/services/netbird
docker compose logs -f

# Public Square logs
cd ~/house-of-good-things/services/public-square
docker compose logs -f
```

### Restart Services

```bash
# Restart NetBird
cd ~/house-of-good-things/services/netbird
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

# NetBird usually doesn't need rebuilding
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

cd ~/house-of-good-things/services/netbird
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
- Review NetBird dashboard regularly (https://johnserv.garrepi.dev)
