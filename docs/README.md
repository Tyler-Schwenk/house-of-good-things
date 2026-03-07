# Documentation Index

Documentation for fart-pi Raspberry Pi 5 home server.

## Current Documentation

### Planning & Architecture
- [**Pre-Deployment Checklist**](pre-deployment.md) - Accounts and prerequisites needed
- [**Architecture Plan**](architecture.md) - System design, planned services, and open questions
- [**Phase 1 Deployment**](phase1-deployment.md) - Step-by-step guide for NetBird and Public Square
- [**Hardware & Network**](hardware.md) - Pi 5 specs and network configuration
- [**Deployment Guide**](deployment.md) - General deployment procedures

### External Documentation
- [**Public Square API**](api/public-square-api.md) - API documentation for frontend developers

### Services
- [**Beszel**](services/beszel.md) - System monitoring and health tracking
- [**Navidrome**](services/navidrome.md) - Music streaming (future deployment)

## System Overview

**What's deployed:**
- Raspberry Pi 5 running Pi OS
- Navidrome music streaming service
- External SSD for media storage

**What's planned:**
- NetBird VPN for remote access (self-hosted by John)
- Immich photo management
- Monitoring solution
- Samba file sharing
- Blog backend
- Off-site backups

See [Architecture Plan](architecture.md) for full details.

## Quick Reference

### Access

**SSH**: 
```bash
ssh tyler@192.168.1.115      # Via Wi-Fi
ssh tyler@192.168.1.116      # Via Ethernet
```

**Web Services**:
- Navidrome: http://192.168.1.115:4533

### Common Commands

**Check running services**:
```bash
docker ps
```

**Manage a service**:
```bash
cd ~/house-of-good-things/services/<service-name>
docker compose logs       # View logs
docker compose restart    # Restart
docker compose down       # Stop
docker compose up -d      # Start
```

**Update repository**:
```bash
cd ~/house-of-good-things
git pull
```

## Documentation Principles

All documentation follows these rules:

1. **Current state only** - No historical changes
2. **No emojis** - Clean, professional docs
3. **Focus on behavior** - Data formats, APIs, how things work
4. **Keep updated** - Docs reflect reality, not speculation

## Structure

```
docs/
├── README.md              # This file
├── architecture.md        # Planning and design
├── hardware.md            # Hardware specs
├── deployment.md          # Deployment guide
└── services/
    └── navidrome.md       # Navidrome service
```

## Resources

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
- [NetBird Documentation](https://docs.netbird.io/)
