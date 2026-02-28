# Documentation Index

This directory contains all project documentation for the house-of-good-things Raspberry Pi system.

## Quick Links

### Getting Started
- [Hardware & Network Configuration](hardware.md) - Pi 5 specs, network setup, and access methods
- [Deployment Guide](deployment.md) - How to deploy and manage services on fart-pi

### Services
- [Navidrome](services/navidrome.md) - Music streaming service documentation

## Documentation Structure

```
docs/
├── README.md              # This file
├── hardware.md            # Hardware specs and network configuration
├── deployment.md          # Deployment and management guide
└── services/              # Service-specific documentation
    └── navidrome.md       # Navidrome music streaming service
```

## System Overview

**Hostname**: fart-pi  
**OS**: Raspberry Pi OS (64-bit)  
**Access**: SSH and Raspberry Pi Connect

### Network Details
- Wi-Fi IP: 192.168.1.115
- Ethernet IP: 192.168.1.116
- Router: 192.168.1.254

### SSH Access
```bash
ssh tyler@192.168.1.115
```

## Service Status

### Active Services
- **Navidrome** (Port 4533): Music streaming server

### Planned Services
Future additions will be documented here as they are deployed.

## Documentation Guidelines

All documentation in this directory follows these principles:

1. **Current State Only**: Documents reflect how the system works today, not historical changes
2. **No Emojis**: Clean, professional documentation
3. **Focus on Behavior**: Emphasize data formats, APIs, and system behavior
4. **Keep Updated**: Documentation is authoritative and must stay current with system changes

## Quick Reference

### Common Commands

Check running services:
```bash
docker ps
```

Deploy a service:
```bash
cd ~/house-of-good-things/services/<service-name>
docker compose up -d
```

View logs:
```bash
docker compose logs -f
```

### Service Ports

| Service | Port | Access URL |
|---------|------|------------|
| Navidrome | 4533 | http://192.168.1.115:4533 |

### Useful Paths

- Music Library: `/home/tyler/music`
- Service Data: `~/house-of-good-things/services/<service>/data`
- Scripts: `~/house-of-good-things/scripts`

## Finding Information

### Hardware & Network Issues
See [hardware.md](hardware.md)

### Deployment & Management
See [deployment.md](deployment.md)

### Service-Specific Questions
Check the relevant guide in [services/](services/)

## Contributing to Documentation

When adding new services or making changes:

1. Update the relevant documentation immediately
2. Follow the existing structure and style
3. Keep documentation focused on current behavior
4. Add new services to the index and service list
5. Update this README if adding new documentation categories
