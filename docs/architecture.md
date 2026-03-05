# Architecture Plan

**Status**: Planning phase - most services not yet implemented

## Overview

Planning document for fart-pi multi-service home server. This will be updated as services are actually deployed and tested.

## Current State

**What exists now:**
- Raspberry Pi 5 (fart-pi) running Raspberry Pi OS
- Docker and Docker Compose installed on Pi
- Repository pushed to GitHub: https://github.com/Tyler-Schwenk/house-of-good-things
- Repository cloned to Pi: ~/house-of-good-things
- External SSD connected to Pi via USB

**Deployed Services:**
1. **Tailscale** - VPN for secure remote access
   - Status: Running and operational
   - Tailscale IP: 100.72.84.128
   - Accessible via: `ssh tyler@fart-pi` or `ssh tyler@100.72.84.128`
   - Devices: fart-pi (Pi), tylerschwelapto (laptop)
   - Funnel enabled for public API access

2. **Public Square** - FastAPI + SQLite forum API
   - Status: Running and operational
   - Public URL: https://fart-pi.tail67548a.ts.net/
   - API Documentation: https://fart-pi.tail67548a.ts.net/docs
   - Health Check: https://fart-pi.tail67548a.ts.net/health
   - Database: SQLite at /app/data/public_square.db
   - Authentication: JWT tokens (routers not yet implemented)

3. **Beszel** - System monitoring and health tracking
   - Status: Running and operational
   - Dashboard: http://100.72.84.128:8090 (via Tailscale)
   - Hub + Agent architecture
   - Monitoring: CPU, RAM, disk, temperature, network, Docker containers
   - Agent version: 0.18.4
   - Resource usage: <1% CPU, ~50MB RAM

**Later additions (Phase 2+):**
- Immich (photo management)
- Samba (local file sharing)
- Off-site backups

## Hardware Setup

- **Pi**: Raspberry Pi 5 (8GB RAM)
- **Storage**: External SSD via USB (for large media files)
- **Network**: Dual connectivity (Ethernet + WiFi)

## Planned Services

### Phase 1: Initial Deployment (PRIORITY)

**Custom Applications**
- **Public Square** 🚧 - Forum API for public discussions
  - FastAPI (Python) with SQLite database
  - User auth: JWT (email/password)
  - Features: Posts, comments, threads
  - Frontend: GitHub Pages (already deployed separately)
  - Exposed publicly via Tailscale Funnel
  - Port: 8000
  - API docs: `/docs` endpoint
  - **Status**: Service structure created, routers not yet implemented
  - **Why first**: Core personal project, drives need for other services

**Infrastructure**
- **Tailscale** 🚧 - Secure remote access
  - VPN mesh network
  - No port forwarding needed
  - Enable Funnel to expose Public Square API publicly
  - Access all services remotely via hostname
  - **Status**: Service structure created, not yet deployed
  - **Why first**: Required for remote development and Funnel feature

### Phase 2+: Future Services

**Media Services**
- **Navidrome** ✅ - Music streaming (Subsonic API compatible)
  - Already deployed
  - Port: 4533
  - Will be accessible via Tailscale once deployed
  
- **Immich** 📋 - Photo management with mobile backup
  - Self-hosted Google Photos alternative
  - Automatic phone photo backup
  - Machine learning for faces/objects
  - Port: 2283

**Monitoring**
- **Beszel** 📋 - System health tracking
  - Lightweight monitoring
  - Track CPU, RAM, disk, temperature
  - Alert on issues
  - Port: 8090

**File Sharing**
- **Samba** 📋 - Local network file sharing
  - SMB/CIFS for Windows/Mac/Linux
  - Access Pi files from any local device
  - Port: 445
  - Local network only (not via Tailscale)

**Backups**
- **Off-site backup** 📋 - To parents' house
  - Automated encrypted backups
  - Tool: Probably Restic
  - Target: Another Raspberry Pi
  - Connected via Tailscale

Legend: ✅ Deployed | 🚧 Next Up | 📋 Future

## Storage Architecture

### External SSD (`/mnt/external-ssd/`)
**Purpose**: Store large media files

Planned directories:
```
/mnt/external-ssd/
├── music/          # Music library (Navidrome)
├── photos/         # Photo library (Immich)
├── files/          # General file storage (Samba)
├── blog-data/      # Blog posts and content
└── backups/        # Local backup staging
```

### Internal Storage (SD Card/NVMe)
**Purpose**: System and service configurations

```
/home/tyler/house-of-good-things/    # This repo
├── services/                         # Service configs
│   ├── navidrome/                   # ✅ Exists
│   ├── immich/                      # 📋 To create
│   ├── tailscale/                   # 📋 To create
│   └── ...
├── docs/                            # Documentation
└── scripts/                         # Automation scripts
```

Each service directory contains:
- `docker-compose.yml` - Container configuration
- `.env` - Secrets and config (not in Git)
- `data/` - Service databases and caches
- `README.md` - Service-specific docs

## Docker Architecture

**How it works:**
- All services run as Docker containers
- Containers are siblings (not nested)
- Each managed by Docker Engine
- Containers access SSD via volume mounts

```
Raspberry Pi OS (Host)
├── Docker Engine
│   ├── Navidrome container ✅
│   ├── Tailscale container 📋
│   ├── Immich containers 📋
│   ├── Monitoring container 📋
│   └── Samba container 📋
└── house-of-good-things/ (This repo - config files)
```

**Volume mounting example:**
```yaml
services:
  navidrome:
    volumes:
      - /mnt/external-ssd/music:/music:ro    # Maps SSD to container
      - ./data:/data                          # Service database
```

## Network Architecture

### Local Network Access
```
Your PC/Phone (on WiFi) → 192.168.1.115:4533 → Navidrome
```
- Direct access when on home network
- Fast (local speeds)

### Remote Access (via Tailscale - Planned)
```
Your Phone (anywhere) → Tailscale VPN → fart-pi:4533 → Navidrome
```
- Peer-to-peer encrypted connection
- No port forwarding needed
- Access via: `http://fart-pi:4533`

**Tailscale Benefits:**
- No open ports on home router
- End-to-end encrypted
- Works from anywhere
- Automatic local network optimization

### Service Port Plan

| Service | Port | Local Access | Remote Access |
|---------|------|--------------|---------------|
| Navidrome | 4533 | ✅ | 📋 (via Tailscale) |
| Immich | 2283 | 📋 | 📋 (via Tailscale) |
| Monitoring | 8090 | 📋 | 📋 (via Tailscale) |
| Samba | 445 | 📋 | ❌ (local only) |
| Blog Backend | 3000 | 📋 | 📋 (via Tailscale) |

## Security Approach

**Remote Access:**
- All remote access via Tailscale VPN
- No ports exposed to internet
- No router port forwarding

**Container Isolation:**
- Each service in own container
- Dedicated Docker networks
- Read-only mounts where appropriate

**Secrets Management:**
- Passwords in `.env` files
- `.env` files not committed to Git
- Strong passwords for all services

**Regular Updates:**
- Docker images kept updated
- Pi OS security updates
- Monitor security advisories

## Backup Strategy (Planned)

### What to Backup
**Critical (daily):**
- Photo library
- Service databases
- Blog content

**Important (weekly):**
- Music library (if changed)
- Service configurations

**Low priority:**
- Cached data
- Downloadable content

### Backup Target
- Another Raspberry Pi at parents' house
- Connected via Tailscale
- Automated via cron

### Backup Tool
Probably Restic:
- Encrypted backups
- Incremental (deduplication)
- Reliable restore
- Low overhead

## Implementation Plan

### Phase 1: Initial Deployment (CURRENT FOCUS)

**Step 1: Deploy Tailscale**
1. Create `services/tailscale/` with docker-compose.yml
2. Get Tailscale auth key from admin console
3. Deploy container on Pi
4. Verify connection from laptop/phone
5. Test SSH via Tailscale hostname (ssh tyler@fart-pi)

**Step 2: Deploy Blog Backend**
1. Create `services/blog-backend/` structure
2. Write FastAPI application:
   - Database models (User, Post, Comment)
   - Auth endpoints (register, login)
   - CRUD endpoints for posts/comments
   - SQLite database
3. Create Dockerfile and docker-compose.yml
4. Test locally, then deploy to Pi
5. Enable Tailscale Funnel to expose publicly
6. Connect GitHub Pages frontend to API

**Step 3: Verify & Document**
1. Test full workflow (register, post, comment)
2. Verify public access works
3. Test from different devices
4. Update documentation with actual setup

### Phase 2: Expand Infrastructure (LATER)

**Media & Monitoring**
1. Deploy monitoring (Beszel)
2. Improve Navidrome setup (migrate to SSD if needed)
3. Deploy Immich for photos

**Storage & Backups**
1. Set up external SSD properly
2. Create directory structure
3. Deploy Samba for local file sharing
4. Set up parents' Pi at their house
5. Configure automated backups

## Open Questions & Decisions Needed

### Phase 1: Blog Backend (IN PROGRESS - DECISIONS MADE)
- [x] Tech stack? **→ FastAPI (Python) - open source, well-documented, AI-friendly**
- [x] Database choice? **→ SQLite - simpler, lighter, perfect for personal blog**
- [x] Auth strategy? **→ FastAPI-Users library (email/password + OAuth)**
- [x] Public access method? **→ Tailscale Funnel - free HTTPS, no port forwarding**
- [ ] Frontend-backend communication details?
- [ ] Rate limiting to prevent spam?
- [ ] Moderation features needed?

### Phase 1: Tailscale
- [ ] Personal vs team account? (Free personal likely sufficient)
- [x] Enable MagicDNS? **→ Yes - allows ssh tyler@fart-pi**
- [x] Funnel for blog API? **→ Yes - expose port 8000 publicly**
- [ ] Subnet router mode needed?

### Phase 2+: Storage
- [ ] What size SSD? (500GB, 1TB, 2TB?)
- [ ] Filesystem: ext4 or NTFS?
- [ ] How to organize directories?

### Phase 2+: Monitoring
- [ ] Which tool? (Beszel is lightweight)
- [ ] What to monitor beyond basics?
- [ ] Where to send alerts?

### Phase 2+: Immich
- [ ] Disable ML on Pi 5 for performance?
- [ ] How much storage for photos?
- [ ] Backup strategy for photos?

### Phase 2+: Backups
- [ ] Backup frequency?
- [ ] Retention periods?
- [ ] Test restore how often?

## Key Learning Points

### From Network Discussion
- **Tailscale routing**: Direct peer-to-peer, not through external servers
- **Local optimization**: When on same WiFi, stays local
- **DERP relays**: Only used as fallback when direct connection fails
- **Coordination servers**: Only for initial handshake, not data transfer

### From Docker Discussion
- **Containers are siblings**: Not nested, all at same level
- **This repo is config**: Not a running container itself
- **Volume mounts**: How containers access host filesystem
- **Port mapping**: How host ports reach containers

### From Architecture Discussion
- **Orchestration**: Docker Compose reads configs and manages containers
- **No special container**: Tailscale is a container like any other
- **Network paths**: Local traffic stays local, remote goes through Tailscale

## Design Principles

1. **Deploy gradually**: One service at a time, test thoroughly
2. **Document reality**: Update docs after implementation, not speculation
3. **Keep it simple**: Avoid premature complexity
4. **Test backups**: Verify restores actually work
5. **Security first**: Default to secure, relax if needed
6. **Monitor everything**: Know when things break

## Resources

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Raspberry Pi Docs](https://www.raspberrypi.com/documentation/)

---

**Note**: This document will evolve. Current state reflects planning and understanding, not implemented reality. Update after each deployment and based on real-world experience.
