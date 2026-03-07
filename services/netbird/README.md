# NetBird VPN Service

NetBird provides secure remote access to fart-pi and enables peer-to-peer connectivity across the Bird Wide Web network.

## Prerequisites

- NetBird account on John's self-hosted instance
- Setup key generated from NetBird dashboard (https://johnserv.garrepi.dev)

## Configuration

### Step 1: Generate Setup Key

1. Log in to the NetBird dashboard at **https://johnserv.garrepi.dev**
2. Navigate to Setup Keys
3. Click "Create Setup Key"
4. Configure:
   - **Name**: fart-pi (or descriptive name)
   - **Type**: Reusable (allows container recreation)
   - **Expiration**: Choose appropriate duration
   - **Auto-assign groups**: Optional
5. Copy the generated setup key

### Step 2: Configure Environment

```bash
cp .env.example .env
nano .env
```

Add your setup key to the `.env` file:

```
NB_SETUP_KEY=your-setup-key-here
```

## Deployment

```bash
# Start NetBird
docker compose up -d

# Verify connection
docker compose logs -f

# Check status
docker exec netbird netbird status

# Get NetBird IP
docker exec netbird netbird status | grep NetBird
```

## Usage

### SSH Access

Once deployed, you can SSH from anywhere on the NetBird network:

```bash
# Using NetBird hostname
ssh tyler@fart-pi.johnserv.garrepi.dev

# Using NetBird IP
ssh tyler@100.124.76.27
```

### Access Services via NetBird

Services running on the Pi can be accessed via NetBird:

```
http://fart-pi.johnserv.garrepi.dev:4533      # Navidrome
http://fart-pi.johnserv.garrepi.dev:8000      # Public Square API
http://100.124.76.27:4533                     # Navidrome (by IP)
http://100.124.76.27:8000                     # Public Square API (by IP)
```

## Network Configuration

### Network Mode: Host

This container uses `network_mode: host`, meaning:

- Container shares the Pi's network namespace
- No port mapping needed
- Required for NetBird to create VPN tunnels
- Can access localhost services on the Pi

### Peer-to-Peer Connectivity

NetBird establishes direct peer-to-peer connections when possible:

- **Relay**: Used when direct connection not possible
- **Direct**: Peer-to-peer encrypted tunnel
- Check connection type: `docker exec netbird netbird status`

## NetBird Dashboard

Access the dashboard at **https://johnserv.garrepi.dev** to:

- View connected peers
- Manage access control policies
- Configure DNS settings
- Set up network routes
- Monitor peer status and activity

## Troubleshooting

### Check Connection Status

```bash
docker compose logs
docker exec netbird netbird status
```

### Restart NetBird

```bash
docker compose restart
```

### Reset Connection

```bash
docker compose down
docker compose up -d
```

### Check NetBird Configuration

```bash
docker exec netbird cat /etc/netbird/config.json
```

## Network Information

- **Network**: Bird Wide Web
- **Domain**: johnserv.garrepi.dev
- **fart-pi NetBird IP**: 100.124.76.27
- **Management Server**: https://johnserv.garrepi.dev:443 (self-hosted by John)

## Connected Peers

- **JohnSERV**: 100.124.56.240 (johnserv.johnserv.garrepi.dev)
- **JohnNAS**: Check NetBird dashboard
- **Bebop**: Check NetBird dashboard

## Security Notes

- NetBird uses WireGuard protocol for encryption
- All traffic is end-to-end encrypted
- Setup keys should be kept secure and rotated periodically
- Access control policies can be configured in the dashboard
- Self-hosted management server means full control and privacy
