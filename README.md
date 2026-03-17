# house-of-good-things

Configuration repository for **fart-pi** - Raspberry Pi 5 home server.

## Current Status

**Repository Status:**
- Pushed to GitHub: https://github.com/Tyler-Schwenk/house-of-good-things
- Cloned to Pi: ~/house-of-good-things
- Docker installed on Pi

**Deployed Services:**
1. **NetBird** - VPN for secure remote access (Bird Wide Web)
   - Status: To be deployed
   - Network: Bird Wide Web (johnserv.garrepi.dev)
   - NetBird IP: 100.124.76.27
   - Management: Self-hosted by John at https://johnserv.garrepi.dev
   - Connected Peers: JohnSERV, JohnNAS, Bebop

2. **Website Backend** - FastAPI + SQLite backend (forum + gallery)
   - Status: Running
   - Access: http://fart-pi.johnserv.garrepi.dev:8000
   - API Docs: http://fart-pi.johnserv.garrepi.dev:8000/docs
   - Health: http://fart-pi.johnserv.garrepi.dev:8000/health
   - Features:
     - Public Square forum (posts, comments - endpoints pending)
     - Photo galleries with thumbnails (implemented)
     - JWT authentication (JWT tokens, routers pending)

3. **Beszel** - System monitoring
   - Status: Running and operational
   - Dashboard: http://100.124.76.27:8090 (via NetBird)
   - Monitoring: CPU, RAM, disk, temperature, network, containers
   - Agent version: 0.18.4

**Phase 2+ - Future Services:**
- Immich (photo management)
- Samba (local file sharing)
- Off-site backups

See full planning document: [docs/architecture.md](docs/architecture.md)

## Hardware

- **Pi**: Raspberry Pi 5 (8GB RAM)
- **Hostname**: fart-pi
- **OS**: Raspberry Pi OS (64-bit)
- **Network**: 
  - Local Wi-Fi: 192.168.1.115
  - Local Ethernet: 192.168.1.116
  - NetBird: 100.124.76.27 (Bird Wide Web access)
- **Storage**: External SSD via USB (for media files)
- **Docker**: Version 29.2.1, Compose v5.1.0

More details: [docs/hardware.md](docs/hardware.md)

## Repository Structure

```
house-of-good-things/
├── services/           # Docker Compose configs for each service
│   ├── beszel/         # System monitoring (ready to deploy)
│   ├── netbird/        # VPN access (Bird Wide Web)
│   └── website-backend/  # Forum + gallery API (deployed)
├── docs/               # Documentation
│   ├── pre-deployment.md    # Prerequisites checklist
│   ├── phase1-deployment.md # Step-by-step deployment
│   ├── architecture.md      # System planning
│   ├── hardware.md          # Hardware specs
│   ├── services/            # Service-specific docs
│   │   ├── beszel.md        # Monitoring documentation
│   │   └── navidrome.md     # Music streaming (future)
│   └── api/                 # External API docs
│       └── website-backend-api.md
└── scripts/            # Automation scripts (TBD)
```

## Getting Started

### Prerequisites Needed

Before deploying to the Pi, you'll need:

1. **NetBird Account** - Access to John's self-hosted instance at https://johnserv.garrepi.dev
2. **Docker on Pi** - Check if installed: `ssh tyler@192.168.1.115 docker --version`
3. **Get Code to Pi** - Either via GitHub or direct copy

See complete checklist: [docs/pre-deployment.md](docs/pre-deployment.md)

### Deployment Process

Once prerequisites are done:

1. **Get code on Pi:**
   ```bash
   # Option A: Push to GitHub, then clone on Pi
   # Option B: scp -r house-of-good-things tyler@192.168.1.115:~/
   ```

2. **Deploy services:**
   - Follow step-by-step: [docs/phase1-deployment.md](docs/phase1-deployment.md)
   - Deploy NetBird first (~5 min)
   - Then deploy Website Backend (~10 min)

3. **Test everything:**
   - SSH via NetBird
   - Access services via NetBird network
   - Verify connectivity with other Bird Wide Web peers

## Planning & Architecture

**Current Focus: Phase 1 Deployment**

Building the initial infrastructure:
1. **NetBird** - Secure VPN access as part of the Bird Wide Web
2. **Website Backend** - Unified API for Public Square forum and photo galleries

Service structures are created in this repository. Frontend is deployed on GitHub Pages. Backend runs on Pi and is accessible via the NetBird network.

**Phase 2+ services:**
- Navidrome for music streaming
- Immich for photo backup
- Beszel for monitoring
- Samba for local file sharing
- Automated encrypted backups to parents' house

**Key planning documents:**
- [Pre-Deployment Checklist](docs/pre-deployment.md) - Accounts and prerequisites
- [Architecture Plan](docs/architecture.md) - Phased deployment plan with technical decisions
- [Phase 1 Deployment](docs/phase1-deployment.md) - Complete deployment guide
- [Hardware & Network](docs/hardware.md) - Physical setup and networking

## Quick Commands

**SSH access:**
```bash
# Via Ethernet (recommended)
ssh tyler@192.168.1.116

# Or via WiFi
ssh tyler@192.168.1.115
```

**Check if Docker is installed:**
```bash
ssh tyler@192.168.1.116 docker --version
```

**Copy repo to Pi (if not using Git):**
```bash
scp -r house-of-good-things tyler@192.168.1.116:~/
```

**Deploy a new service:**
```bash
cd ~/house-of-good-things/services/<service-name>
cp .env.example .env   # Configure secrets
nano .env              # Edit configuration
docker compose up -d   # Start service
```

## Documentation

All documentation is in the [docs/](docs) directory:

- [Pre-Deployment Checklist](docs/pre-deployment.md) - Start here!
- [Architecture Plan](docs/architecture.md) - Overall system design with open questions
- [Phase 1 Deployment](docs/phase1-deployment.md) - Step-by-step deployment guide
- [Website Backend API](docs/api/website-backend-api.md) - API documentation for frontend
- [Hardware & Network](docs/hardware.md) - Physical setup and networking

## Security Considerations

**Current:**
- No ports exposed to internet
- Local network access only

**Planned:**
- All remote access via encrypted VPN (NetBird/WireGuard)
- Bird Wide Web peer-to-peer connectivity
- No router port forwarding needed
- JWT authentication for API
- Rate limiting on all endpoints
- Container isolation
- Encrypted backups
- Read-only volume mounts where appropriate

## Contributing

This is a personal infrastructure project, but feel free to use it as reference for your own setups.
