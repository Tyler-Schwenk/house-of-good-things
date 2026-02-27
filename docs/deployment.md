# Deployment Guide

## Prerequisites

### Local Machine (Windows)
- SSH client (built into Windows 10/11)
- Git (for cloning this repository)
- Text editor (VS Code recommended)

### Raspberry Pi (fart-pi)
- Raspberry Pi OS (64-bit) installed
- SSH access enabled
- Internet connection
- Docker and Docker Compose (installed via setup script)

## Initial Setup

### Step 1: Install Docker on fart-pi

From your Windows machine, copy the setup script to the Pi and run it:

```bash
scp scripts/setup-docker.sh tyler@192.168.1.115:~/
ssh tyler@192.168.1.115
chmod +x setup-docker.sh
./setup-docker.sh
```

After installation, log out and back in for Docker permissions to take effect.

### Step 2: Verify Docker Installation

```bash
docker --version
docker compose version
```

## Deploying Services

### General Deployment Process

Each service in the `services/` directory contains:
- `docker-compose.yml` - Container configuration
- `README.md` - Service-specific documentation
- Configuration files as needed

To deploy a service:

1. SSH into fart-pi
2. Clone or sync this repository
3. Navigate to the service directory
4. Run docker compose

Example for Navidrome:
```bash
cd ~/boy-pocket/services/navidrome
docker compose up -d
```

### Service Management Commands

Start a service:
```bash
docker compose up -d
```

Stop a service:
```bash
docker compose down
```

View logs:
```bash
docker compose logs -f
```

Restart a service:
```bash
docker compose restart
```

Check status:
```bash
docker compose ps
```

Update and restart:
```bash
docker compose pull
docker compose up -d
```

## Managing Multiple Services

### View All Running Containers
```bash
docker ps
```

### View All Container Status
```bash
docker ps -a
```

### System Resource Usage
```bash
docker stats
```

### Clean Up Unused Resources
```bash
docker system prune -a
```

## File Synchronization

### Syncing Repository to fart-pi

From your Windows machine:

Using rsync (if available):
```bash
rsync -avz --exclude '.git' C:\Users\tyler\important\projects\pi\boy-pocket/ tyler@192.168.1.115:~/boy-pocket/
```

Or using scp:
```bash
scp -r C:\Users\tyler\important\projects\pi\boy-pocket tyler@192.168.1.115:~/
```

Using Git (recommended):
```bash
ssh tyler@192.168.1.115
cd ~/boy-pocket
git pull origin main
```

## Network Configuration

### Port Mapping

Each service exposes ports on the Pi. These are defined in each service's `docker-compose.yml`.

Common ports:
- Navidrome: 4533

To access services:
- **Local**: http://192.168.1.115:PORT
- **Remote**: Configure port forwarding on router or use Tailscale

### Firewall Configuration

If UFW is enabled on the Pi:

```bash
sudo ufw allow PORT/tcp
sudo ufw reload
```

## Troubleshooting

### Service Won't Start

Check logs:
```bash
docker compose logs
```

Check container status:
```bash
docker compose ps
```

### Permission Issues

Ensure user is in docker group:
```bash
groups
```

Should show `docker` in the list. If not:
```bash
sudo usermod -aG docker $USER
```
Then log out and back in.

### Disk Space Issues

Check disk usage:
```bash
df -h
```

Clean up Docker resources:
```bash
docker system prune -a --volumes
```

### Network Issues

Verify container network:
```bash
docker network ls
docker network inspect bridge
```

Check Pi network connectivity:
```bash
ping 8.8.8.8
```

## Backup and Recovery

### Backing Up Service Data

Each service stores data in its `data/` directory. Back up regularly:

```bash
tar -czf navidrome-backup-$(date +%Y%m%d).tar.gz ~/boy-pocket/services/navidrome/data
```

### Restoring Service Data

```bash
cd ~/boy-pocket/services/navidrome
docker compose down
tar -xzf navidrome-backup-YYYYMMDD.tar.gz
docker compose up -d
```

## Security Best Practices

### SSH Key Authentication

Generate SSH key on Windows:
```powershell
ssh-keygen -t ed25519
```

Copy to Pi:
```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh tyler@192.168.1.115 "cat >> ~/.ssh/authorized_keys"
```

### Keep System Updated

On fart-pi:
```bash
sudo apt update
sudo apt upgrade -y
```

### Use Strong Passwords

Change default passwords for all services after deployment.

### Consider Tailscale

For secure remote access without port forwarding:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

## Monitoring

### System Resources

Check CPU and memory:
```bash
htop
```

Check temperature:
```bash
vcgencmd measure_temp
```

### Docker Resources

```bash
docker stats
```

### Service Health Checks

Most services provide health endpoints. Check service-specific documentation.
