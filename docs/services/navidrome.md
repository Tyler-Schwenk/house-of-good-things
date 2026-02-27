# Navidrome

Self-hosted music streaming server compatible with the Subsonic API.

## Overview

Navidrome allows you to stream your personal music collection from anywhere. It provides a web interface and is compatible with many mobile and desktop music players.

## Features

- Web-based music player
- Subsonic/OpenSubsonic API compatible
- Multi-user support
- Automatic music library scanning
- Album art and metadata management
- Playlists and favorites
- Last.fm scrobbling
- Low resource usage (perfect for Raspberry Pi)

## Compatible Clients

### Desktop
- **Feishin**: Modern, feature-rich client (recommended)
- **Sublime Music**: Linux-focused client
- Web browser (built-in player)

### Mobile
- **Symfonium** (Android): Premium client, highly recommended
- **play:Sub** (iOS): Feature-complete iOS client
- **substreamer** (iOS/Android): Free alternative
- **DSub** (Android): Classic Android client

### Command Line
- **ncmpcpp**: Can be used with Subsonic plugin
- **stmp**: Terminal-based Subsonic client

## Service Configuration

### Docker Compose Details

The service runs in a Docker container with the following configuration:

- **Container Name**: navidrome
- **Image**: deluan/navidrome:latest
- **Port**: 4533 (mapped to host)
- **Music Directory**: `/music` (mount your music collection here)
- **Data Directory**: `/data` (persistent storage for database and cache)

### Environment Variables

Key configuration options set in docker-compose.yml:

- `ND_LOGLEVEL`: Logging verbosity (info, debug, error)
- `ND_BASEURL`: Base URL for reverse proxy setups
- `ND_SESSIONTIMEOUT`: Session timeout duration
- `ND_ENABLETRANSCODINGCONFIG`: Allow transcoding settings
- `ND_TRANSCODINGCACHESIZE`: Cache size for transcoded files

### Volume Mounts

Three volumes are required:

1. **Music Library**: Your music files (read-only recommended)
   - Host: `/path/to/your/music`
   - Container: `/music`

2. **Application Data**: Database and configuration
   - Host: `./data`
   - Container: `/data`

3. **Configuration**: Optional additional config
   - Host: `./config`
   - Container: `/config`

## Deployment

### Prerequisites

1. Docker and Docker Compose installed on fart-pi
2. Music collection accessible on the Pi
3. Sufficient storage space for transcoding cache

### Step 1: Prepare Music Library

Organize your music on the Pi:

```bash
mkdir -p ~/music
# Copy your music files to ~/music or mount external storage
```

Supported formats:
- FLAC (lossless, recommended)
- MP3
- M4A/AAC
- OGG Vorbis
- WMA
- OPUS

### Step 2: Configure Service

Edit `docker-compose.yml` to set your music directory path:

```yaml
volumes:
  - /home/tyler/music:/music:ro
```

### Step 3: Deploy

```bash
cd ~/boy-pocket/services/navidrome
docker compose up -d
```

### Step 4: Initial Setup

1. Access the web interface:
   - Local: http://192.168.1.115:4533
   - Or http://fart-pi.local:4533

2. Create your admin account (first user becomes admin)

3. Navidrome will automatically scan your music library

## Access Configuration

### Local Network Access

Direct access from any device on your home network:
- URL: http://192.168.1.115:4533
- Username: (created during initial setup)
- Password: (created during initial setup)

### Remote Access Options

#### Option 1: Raspberry Pi Connect (Limited)
Access via Raspberry Pi Connect web interface, then use the browser-based player.

#### Option 2: Port Forwarding (Not Recommended)
- Set up port forwarding on router: External 4533 → 192.168.1.115:4533
- Security risk: Exposes service to internet
- Requires HTTPS for secure access

#### Option 3: Tailscale (Recommended)
- Install Tailscale on fart-pi and client devices
- Access via Tailscale IP
- Secure, encrypted connection
- No port forwarding needed

#### Option 4: Reverse Proxy + HTTPS
- Use Caddy or nginx as reverse proxy
- Obtain SSL certificate (Let's Encrypt)
- Access via domain name
- Most professional solution

## Client Setup

### Feishin (Desktop)

1. Download from https://github.com/jeffvli/feishin
2. Open Feishin
3. Add server:
   - Name: fart-pi music
   - URL: http://192.168.1.115:4533
   - Username: your_username
   - Password: your_password
4. Connect and enjoy

### Symfonium (Android)

1. Install from Google Play Store
2. Add server:
   - Type: Subsonic
   - Name: fart-pi music
   - Server URL: http://192.168.1.115:4533
   - Username: your_username
   - Password: your_password
3. Configure playback and caching settings
4. Start streaming

### Other Clients

Use similar settings with the Subsonic API:
- Server: http://192.168.1.115:4533
- API path: /rest (usually auto-detected)
- Protocol: Subsonic/OpenSubsonic

## Management

### View Logs

```bash
docker compose logs -f navidrome
```

### Restart Service

```bash
docker compose restart
```

### Trigger Manual Library Scan

From web interface: Settings → Scan Library Now

Or restart the container:
```bash
docker compose restart
```

### Update Navidrome

```bash
docker compose pull
docker compose up -d
```

### Backup

Backup the data directory:
```bash
tar -czf navidrome-backup-$(date +%Y%m%d).tar.gz ./data
```

## Performance Tuning

### Transcoding

Navidrome can transcode high-quality audio to lower bitrates for mobile streaming:

- Configure in web interface: Settings → Transcoding
- Useful for saving mobile data
- Increases CPU usage on Pi

### Cache Size

Adjust transcoding cache size in environment variables:
```yaml
- ND_TRANSCODINGCACHESIZE=512MB
```

### Scanning

For large libraries:
- Initial scan may take several minutes
- Subsequent scans are incremental
- Schedule scans during low-usage periods

## Troubleshooting

### Music Library Not Found

Check volume mount in docker-compose.yml and ensure path exists:
```bash
ls -la /home/tyler/music
```

### Permission Errors

Ensure the data directory is writable:
```bash
chmod -R 755 ./data
```

### Can't Connect from Client

Verify service is running:
```bash
docker compose ps
```

Check port is accessible:
```bash
curl http://192.168.1.115:4533
```

### Slow Performance

- Reduce transcoding quality
- Increase cache size
- Use Ethernet instead of Wi-Fi for large transfers
- Consider external storage for music library

## Advanced Configuration

### Multiple Music Folders

Add multiple library paths in Navidrome settings after initial setup.

### Last.fm Integration

Configure in web interface: Settings → Last.fm

### Reverse Proxy Setup

Example nginx configuration:
```nginx
location /music {
    proxy_pass http://192.168.1.115:4533;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## Resources

- Official Documentation: https://www.navidrome.org/docs/
- GitHub Repository: https://github.com/navidrome/navidrome
- Community Forum: https://github.com/navidrome/navidrome/discussions
- Subsonic API Docs: http://www.subsonic.org/pages/api.jsp
