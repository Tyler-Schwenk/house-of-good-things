# house-of-good-things

Configuration repository for **fart-pi** - Raspberry Pi 5 home server.

## Current Status

**Repository Status:**
- Service configurations created and ready
- Code is on your laptop (not yet on Pi)
- Nothing deployed yet

**Phase 1 - Ready to Deploy:**
1. **Public Square** - FastAPI + SQLite forum API
   - Service structure created (not yet deployed)
   - Publicly accessible via Tailscale Funnel
   - Auth: JWT tokens (email/password)
   - Features: Posts, comments, threads
   - API docs at `/docs` endpoint
2. **Tailscale** - VPN for secure remote access
   - Service structure created (not yet deployed)
   - Enable remote development
   - Expose Public Square API publicly via Funnel

**Phase 2+ - Future Services:**
- Immich (photo management)
- Beszel (monitoring)
- Samba (local file sharing)
- Off-site backups

See full planning document: [docs/architecture.md](docs/architecture.md)

## Hardware

- **Pi**: Raspberry Pi 5 (8GB RAM)
- **Hostname**: fart-pi
- **OS**: Raspberry Pi OS (64-bit)
- **Network**: 
  - Wi-Fi: 192.168.1.115
  - Ethernet: 192.168.1.116
- **Storage**: External SSD via USB (for media files)

More details: [docs/hardware.md](docs/hardware.md)

## Repository Structure

```
house-of-good-things/
├── services/           # Docker Compose configs for each service
│   ├── public-square/  # Forum API (ready to deploy)
│   └── tailscale/      # VPN access (ready to deploy)
├── docs/               # Documentation
│   ├── pre-deployment.md    # Prerequisites checklist
│   ├── phase1-deployment.md # Step-by-step deployment
│   ├── architecture.md      # System planning
│   ├── hardware.md          # Hardware specs
│   └── api/                 # External API docs
│       └── public-square-api.md
└── scripts/            # Automation scripts (TBD)
```

## Getting Started

### Prerequisites Needed

Before deploying to the Pi, you'll need:

1. **Tailscale Account** (free) - https://login.tailscale.com
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
   - Deploy Tailscale first (~5 min)
   - Then deploy Public Square (~10 min)

3. **Test everything:**
   - SSH via Tailscale
   - Access API via public URL
   - Connect frontend to backend

## Planning & Architecture

**Current Focus: Phase 1 Deployment**

Building the initial infrastructure to host a public forum (Public Square):
1. **Tailscale** - Secure VPN access + public Funnel feature
2. **Public Square** - FastAPI + SQLite forum API

Service structures are created in this repository. Frontend is already deployed on GitHub Pages. Backend will run on Pi and be publicly accessible via Tailscale Funnel (no port forwarding needed).

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
ssh tyler@192.168.1.115
```

**Check if Docker is installed:**
```bash
ssh tyler@192.168.1.115 docker --version
```

**Copy repo to Pi (if not using Git):**
```bash
scp -r house-of-good-things tyler@192.168.1.115:~/
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
- [Public Square API](docs/api/public-square-api.md) - API documentation for frontend
- [Hardware & Network](docs/hardware.md) - Physical setup and networking

## Security Considerations

**Current:**
- No ports exposed to internet
- Local network access only

**Planned:**
- All remote access via encrypted VPN (Tailscale)
- Public API exposure via Tailscale Funnel (HTTPS)
- No router port forwarding needed
- JWT authentication for API
- Rate limiting on all endpoints
- Container isolation
- Encrypted backups
- Read-only volume mounts where appropriate

## Contributing

This is a personal infrastructure project, but feel free to use it as reference for your own setups.
