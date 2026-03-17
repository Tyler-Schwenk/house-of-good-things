# Documentation Index

Documentation for fart-pi Raspberry Pi 5 home server.

## Current Documentation

### Planning & Architecture
- [**Architecture Plan**](architecture.md) - System design, planned services, and open questions
- [**Hardware & Network**](hardware.md) - Pi 5 specs and network configuration
- [**Deployment Guide**](deployment.md) - How to deploy services on fart-pi

### Services
- [**Navidrome**](services/navidrome.md) - Music streaming (already deployed)

## System Overview

**What's deployed:**
- Raspberry Pi 5 running Raspberry Pi OS
- NetBird VPN for remote access (Bird Wide Web network)
- Beszel monitoring agent
- Website Backend API (forum + galleries)
- Navidrome music streaming service
- External SSD for media storage

**What's planned:**
- Immich photo management
- Samba file sharing
- Off-site backups

See [Architecture Plan](architecture.md) for full details.

## Quick Reference

### Access

**SSH (Remote via NetBird)**: 
```bash
ssh tyler@fart-pi.johnserv.garrepi.dev
ssh tyler@100.124.76.27
```

**SSH (Local Network)**:
```bash
ssh tyler@192.168.1.115      # Via Wi-Fi
ssh tyler@192.168.1.116      # Via Ethernet
```

**Web Services**:
- Navidrome: http://fart-pi.johnserv.garrepi.dev:4533 (via NetBird)
- Website Backend API: http://fart-pi.johnserv.garrepi.dev:8000 (via NetBird)

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
- [NetBird Documentation](https://docs.netbird.io/) (for VPN setup)
