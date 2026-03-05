# Beszel Monitoring Service

System monitoring dashboard for fart-pi.

## Purpose

Provides real-time visibility into Pi system health and resource usage. Essential for:
- Detecting performance issues
- Capacity planning
- Docker container monitoring
- Troubleshooting

## Features

- **CPU Monitoring**: Usage percentage, load averages
- **Memory Monitoring**: RAM and swap usage
- **Disk Monitoring**: Space usage across all mounted drives
- **Container Stats**: Per-container CPU/RAM usage
- **Network Stats**: Bandwidth usage
- **Historical Graphs**: Time-series data for trends

## Architecture

Single container deployment:
- **Image**: henrygd/beszel:latest
- **Port**: 8090 (HTTP web interface)
- **Storage**: SQLite database in ./data/
- **Host Access**: Reads system metrics from host via Docker API

## Access

**Via Tailscale IP (private):**
```
http://100.72.84.128:8090
```

**Via Tailscale Funnel (public - optional):**
```
https://fart-pi.tail67548a.ts.net:8090
```

## Configuration

Default settings are sufficient for basic monitoring. Optional configurations:

### Alert Thresholds

Configure in web UI:
- CPU usage > 80%
- RAM usage > 85%
- Disk usage > 90%

### Data Retention

Default: 30 days of historical data. Configurable in web UI settings.

## Security

**Private access (recommended):**
- Only accessible via Tailscale network
- Protected by Beszel's built-in authentication

**Public access (optional):**
- Enable Funnel if you want to check Pi status from non-Tailscale devices
- Use strong admin password
- Consider IP allowlisting in Tailscale settings

## Maintenance

**Automatic:**
- Data cleanup based on retention settings
- Restarts on failure (unless-stopped policy)

**Manual:**
- Update container: `docker compose pull && docker compose up -d`
- Backup data: Copy `./data/` directory

## Resource Usage

- **CPU**: < 1% average
- **RAM**: ~50MB
- **Disk**: ~100MB for image, ~1-2GB for 30 days of data
- **Network**: Minimal (local metrics collection only)

## Troubleshooting

**Dashboard not loading:**
```bash
# Check container status
cd ~/house-of-good-things/services/beszel
docker compose ps
docker compose logs
```

**Metrics not updating:**
- Verify Docker socket is accessible
- Check container has proper permissions

**High disk usage:**
- Reduce data retention period in settings
- Consider moving data directory to external SSD
