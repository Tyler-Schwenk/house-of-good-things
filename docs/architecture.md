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
1. **NetBird** - VPN for secure remote access (Bird Wide Web)
   - Status: Running on fart-pi
   - NetBird IP: 100.124.76.27
   - Network Domain: johnserv.garrepi.dev
   - Management: Self-hosted by John at https://johnserv.garrepi.dev
   - Connected Peers: JohnSERV (100.124.56.240), JohnNAS, Bebop

2. **Public Square** - FastAPI forum and gallery API
   - Status: Running and operational
   - Access: http://fart-pi.johnserv.garrepi.dev:8000 or http://100.124.76.27:8000
   - API Documentation: http://fart-pi.johnserv.garrepi.dev:8000/docs
   - Health Check: http://fart-pi.johnserv.garrepi.dev:8000/health
   - Database: SQLite at /app/data/public_square.db
   - Features:
     - Forum discussions (posts, comments, users)
     - Photo galleries with automatic thumbnails
     - JWT authentication (routers not yet implemented)
   - Photo Storage: /mnt/external-ssd/public-gallery

3. **Beszel** - System monitoring and health tracking
   - Status: Running and operational
   - Dashboard: http://100.124.76.27:8090 (via NetBird)
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
- **Public Square** - Forum and gallery API for website
  - FastAPI (Python) with SQLite database
  - User auth: JWT (email/password)
  - Features: 
    - Forum posts, comments, threads
    - Photo galleries with automatic thumbnails
    - Image storage and serving
  - Frontend: GitHub Pages (hosted separately)
  - Backend accessible via NetBird or public Cloudflare Tunnel (planned)
  - Port: 8000
  - API docs: `/docs` endpoint
  - Database models:
    - Users (authentication + profile)
    - Posts (forum threads)
    - Comments (post replies)
    - Galleries (photo albums)
    - GalleryPhotos (photos with metadata)
  - **Status**: Deployed, gallery endpoints operational

**Infrastructure**
- **NetBird** 🚧 - Secure remote access (Bird Wide Web)
  - WireGuard-based VPN mesh network
  - No port forwarding needed
  - Access all services remotely via hostname or IP
  - Peer-to-peer connectivity with friends' servers
  - **Status**: Account created, not yet deployed on fart-pi
  - **Why first**: Required for remote development and Bird Wide Web connectivity

### Phase 2+: Future Services

**Media Services**
- **Navidrome** ✅ - Music streaming (Subsonic API compatible)
  - Already deployed
  - Port: 4533
  - Will be accessible via NetBird once deployed
  
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
  - Local network only

**Backups**
- **Off-site backup** 📋 - To parents' house
  - Automated encrypted backups
  - Tool: Probably Restic
  - Target: Another Raspberry Pi
  - Connected via NetBird

Legend: ✅ Deployed | 🚧 Next Up | 📋 Future

## Storage Architecture

### External SSD (`/media/tyler/FE645A9A645A558D/`)
**Purpose**: Store large media files

**Device**: `/dev/sda1` - 193GB NTFS partition (1% used, 193GB available)

Directories:
```
/media/tyler/FE645A9A645A558D/
├── music/              # Music library (Navidrome)
├── photos/             # Personal photo library (Immich - planned)
├── public-gallery/     # Curated photos for website (Public Square API)
│   ├── gallery_1/
│   │   ├── *.jpg       # Original images
│   │   └── thumbnails/ # Auto-generated thumbnails (400x400px)
│   └── gallery_2/
└── movies/             # Movie collection
```

### Internal Storage (SD Card/NVMe)
**Purpose**: System and service configurations

```
/home/tyler/house-of-good-things/    # This repo
├── services/                         # Service configs
│   ├── navidrome/                   # ✅ Exists
│   ├── immich/                      # 📋 To create
│   ├── netbird/                     # 📋 To create
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
│   ├── NetBird container 📋
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

### Remote Access (via NetBird)
```
Your Phone (anywhere) → NetBird VPN → fart-pi:4533 → Navidrome
```
- Peer-to-peer encrypted connection
- No port forwarding needed
- Access via: `http://fart-pi.johnserv.garrepi.dev:4533` or `http://100.124.76.27:4533`

**NetBird Benefits:**
- No open ports on home router
- End-to-end encrypted (WireGuard)
- Works from anywhere
- Automatic local network optimization
- Part of Bird Wide Web collaborative network

### Service Port Plan

| Service | Port | Local Access | Remote Access |
|---------|------|--------------|---------------|
| Navidrome | 4533 | ✅ | 📋 (via NetBird) |
| Immich | 2283 | 📋 | 📋 (via NetBird) |
| Monitoring | 8090 | 📋 | 📋 (via NetBird) |
| Samba | 445 | 📋 | ❌ (local only) |
| Blog Backend | 3000 | 📋 | 📋 (via NetBird) |

## Security Approach

**Remote Access:**
- All remote access via NetBird VPN
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
- Connected via NetBird
- Automated via cron

### Backup Tool
Probably Restic:
- Encrypted backups
- Incremental (deduplication)
- Reliable restore
- Low overhead

## Implementation Plan

### Phase 1: Initial Deployment (CURRENT FOCUS)

**Step 1: Deploy NetBird**
1. Create `services/netbird/` with docker-compose.yml
2. Get NetBird setup key from John's dashboard (https://johnserv.garrepi.dev)
3. Deploy container on Pi
4. Verify connection from laptop/phone
5. Test SSH via NetBird hostname (ssh tyler@fart-pi.johnserv.garrepi.dev)

**Step 2: Deploy Blog Backend**
1. Create `services/blog-backend/` structure
2. Write FastAPI application:
   - Database models (User, Post, Comment)
   - Auth endpoints (register, login)
   - CRUD endpoints for posts/comments
   - SQLite database
3. Create Dockerfile and docker-compose.yml
4. Test locally, then deploy to Pi
5. Access via NetBird network
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
- [x] Network access? **→ NetBird - part of Bird Wide Web collaborative network**
- [ ] Frontend-backend communication details?
- [ ] Rate limiting to prevent spam?
- [ ] Moderation features needed?

### Phase 1: NetBird
- [x] Network choice? **→ NetBird - chosen for collaborative setup with John**
- [x] Self-hosted vs cloud? **→ Self-hosted by John = unlimited users/peers**
- [x] Collaborative setup? **→ Yes - Bird Wide Web with John and friends**
- [x] Enable DNS? **→ Yes - allows ssh tyler@fart-pi.johnserv.garrepi.dev**
- [ ] Access control policies needed?

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
- **NetBird routing**: WireGuard-based peer-to-peer connections
- **Local optimization**: When on same network, stays local
- **Relay servers**: Used as fallback when direct connection fails
- **Signal servers**: Only for initial handshake, not data transfer

### From Docker Discussion
- **Containers are siblings**: Not nested, all at same level
- **This repo is config**: Not a running container itself
- **Volume mounts**: How containers access host filesystem
- **Port mapping**: How host ports reach containers

### From Architecture Discussion
- **Orchestration**: Docker Compose reads configs and manages containers
- **No special container**: NetBird is a container like any other
- **Network paths**: Local traffic stays local, remote goes through NetBird

## Design Principles

1. **Deploy gradually**: One service at a time, test thoroughly
2. **Document reality**: Update docs after implementation, not speculation
3. **Keep it simple**: Avoid premature complexity
4. **Test backups**: Verify restores actually work
5. **Security first**: Default to secure, relax if needed
6. **Monitor everything**: Know when things break

## Resources

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [NetBird Documentation](https://docs.netbird.io/)
- [Raspberry Pi Docs](https://www.raspberrypi.com/documentation/)

---

**Note**: This document will evolve. Current state reflects planning and understanding, not implemented reality. Update after each deployment and based on real-world experience.
