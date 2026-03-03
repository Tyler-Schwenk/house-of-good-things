# Tailscale VPN Service

Tailscale provides secure remote access to fart-pi and enables the Funnel feature to expose services publicly.

## Prerequisites

- Tailscale account (free): https://login.tailscale.com
- Auth key generated from admin console

## Configuration

### Step 1: Generate Auth Key

1. Visit https://login.tailscale.com/admin/settings/keys
2. Click "Generate auth key"
3. Configure:
   - **Reusable**: Yes (allows container recreation)
   - **Ephemeral**: No (device persists across restarts)
   - **Pre-approved**: Yes (auto-authorize)
   - **Tags**: `tag:server` (optional)
4. Copy the key (starts with `tskey-auth-`)

### Step 2: Configure Environment

```bash
cp .env.example .env
nano .env
```

Paste your auth key into the `TS_AUTHKEY` variable.

## Deployment

```bash
# Start Tailscale
docker compose up -d

# Verify connection
docker compose logs -f

# Check status
docker exec tailscale tailscale status

# Get Tailscale IP
docker exec tailscale tailscale ip -4
```

## Usage

### SSH Access

Once deployed, you can SSH from anywhere:

```bash
# Using Tailscale hostname (requires MagicDNS enabled)
ssh tyler@fart-pi

# Using Tailscale IP
ssh tyler@100.x.x.x
```

### Expose Services with Funnel

Funnel makes a service publicly accessible (no VPN required for users):

```bash
# Expose a service on port 8000
docker exec tailscale tailscale funnel 8000

# List active funnels
docker exec tailscale tailscale funnel status

# Remove funnel
docker exec tailscale tailscale funnel --remove 8000
```

Public URL will be: `https://fart-pi.your-tailnet.ts.net:8000`

### Access Other Services via Tailscale

Services running on the Pi can be accessed via Tailscale:

```
http://fart-pi:4533      # Navidrome
http://fart-pi:8000      # Public Square API
```

## Network Mode: Host

This container uses `network_mode: host`, meaning:

- Container shares the Pi's network namespace
- No port mapping needed
- Required for Tailscale to function properly
- Can access localhost services on the Pi

## Troubleshooting

### Check Connection Status

```bash
docker exec tailscale tailscale status
```

Should show connected devices in your Tailnet.

### View Logs

```bash
docker compose logs -f
```

### Restart Service

```bash
docker compose restart
```

### Reset and Rejoin

```bash
docker compose down
rm -rf data/
docker compose up -d
```

### Verify Funnel

```bash
docker exec tailscale tailscale funnel status
```

## Security Notes

- Auth key is sensitive: keep `.env` file secure
- Never commit `.env` to Git
- Tailscale provides end-to-end encryption
- Funnel traffic is HTTPS with automatic certificates
- Container requires elevated privileges (NET_ADMIN, SYS_MODULE) for VPN functionality

## Container Details

- **Image**: `tailscale/tailscale:latest`
- **Hostname**: `fart-pi`
- **Network**: Host mode
- **Capabilities**: NET_ADMIN, SYS_MODULE (required for VPN)
- **Volumes**: `./data/state` (persistent Tailscale state)
- **Restart Policy**: unless-stopped

## References

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale Funnel](https://tailscale.com/kb/1223/tailscale-funnel/)
- [Docker Container](https://tailscale.com/kb/1282/docker/)
