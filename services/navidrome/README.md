# Navidrome Service

Music streaming server for fart-pi.

## Quick Start

### 1. Set Up Music Directory

Ensure your music is accessible on the Pi:

```bash
mkdir -p ~/music
# Copy or mount your music collection to ~/music
```

### 2. Update Music Path

Edit `docker-compose.yml` and change the music volume path if needed:

```yaml
volumes:
  - /home/tyler/music:/music:ro
```

### 3. Deploy

```bash
docker compose up -d
```

### 4. Access Web Interface

Open in browser:
- Local: http://192.168.1.115:4533
- Create admin account on first visit

## Configuration

### Environment Variables

Key settings in `docker-compose.yml`:

- `ND_LOGLEVEL`: Set to `info`, `debug`, or `error`
- `ND_SESSIONTIMEOUT`: How long users stay logged in
- `ND_SCANSCHEDULE`: How often to scan for new music
- `ND_TRANSCODINGCACHESIZE`: Cache size for transcoded audio

### Music Library Path

The music directory is mounted as read-only (`:ro`) for safety. If you need to modify files from within the container, remove the `:ro` flag.

Default path: `/home/tyler/music`

### Data Directory

The `./data` directory stores:
- SQLite database
- Album art cache
- Transcoding cache
- User preferences

This directory is created automatically and persists across container restarts.

## Management

### Start Service
```bash
docker compose up -d
```

### Stop Service
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f
```

### Restart After Config Change
```bash
docker compose down
docker compose up -d
```

### Update to Latest Version
```bash
docker compose pull
docker compose up -d
```

## Accessing Your Music

### Web Interface
Navigate to: http://192.168.1.115:4533

### Client Apps

**Desktop:**
- Feishin (recommended): https://github.com/jeffvli/feishin

**Android:**
- Symfonium (premium, best experience)
- Subtracks (free)

**iOS:**
- play:Sub

**Connection Settings:**
- Server URL: http://192.168.1.115:4533
- Username: (created during first setup)
- Password: (created during first setup)

## Troubleshooting

### Service Won't Start

Check logs:
```bash
docker compose logs
```

Common issues:
- Music directory doesn't exist or is empty
- Permissions on data directory
- Port 4533 already in use

### Music Not Showing Up

Force a library scan:
1. Access web interface
2. Go to Settings
3. Click "Scan Library Now"

Or restart the container:
```bash
docker compose restart
```

### Performance Issues

For large libraries (10,000+ tracks):
- First scan takes time (10-30 minutes)
- Subsequent scans are much faster
- Consider using Ethernet instead of Wi-Fi
- Reduce transcoding cache if low on disk space

## Full Documentation

See [docs/services/navidrome.md](../../docs/services/navidrome.md) for complete documentation including:
- Client setup guides
- Remote access configuration
- Advanced tuning
- Backup procedures
