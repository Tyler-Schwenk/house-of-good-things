# Beszel Monitoring

Lightweight monitoring dashboard for fart-pi system metrics.

## Overview

Beszel provides real-time monitoring of:
- CPU usage and load
- RAM usage
- Disk space
- Docker containers
- Network traffic
- System uptime

## Setup

### 1. Deploy Beszel

```bash
cd ~/house-of-good-things/services/beszel
docker compose up -d
```

### 2. Access Dashboard

Via Tailscale (from anywhere):
```
http://100.72.84.128:8090
```

Or enable Funnel for public access:
```bash
cd ~/house-of-good-things/services/tailscale
docker exec tailscale tailscale funnel 8090
```

Then access at: https://fart-pi.tail67548a.ts.net:8090

### 3. Initial Configuration

On first access:
1. Create admin account
2. System will auto-detect the Pi as a monitored host
3. Configure alert thresholds (optional)

## Management

**View logs:**
```bash
docker compose logs -f
```

**Restart:**
```bash
docker compose restart
```

**Update:**
```bash
docker compose pull
docker compose up -d
```

## Data

All monitoring data and configuration stored in `./data/` (excluded from Git).

## Ports

- **8090**: Web dashboard

## Resources

- Minimal CPU usage (< 1%)
- ~50MB RAM
- Disk: ~100MB for Docker image + historical data
