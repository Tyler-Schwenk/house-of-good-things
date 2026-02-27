# boy-pocket

Raspberry Pi 5 multi-service host running on **fart-pi**.

## Overview

This repository manages services and configuration for a headless Raspberry Pi 5 system. The Pi hosts self-hosted services accessible both locally and remotely.

## Current Services

### Navidrome
Music streaming server compatible with Subsonic API. Access your music library from anywhere using clients like Feishin (desktop) or Symfonium (Android).

- Service directory: [services/navidrome](services/navidrome)
- Documentation: [docs/services/navidrome.md](docs/services/navidrome.md)

## System Information

- **Hostname**: fart-pi
- **OS**: Raspberry Pi OS (64-bit)
- **Network**: Dual Ethernet + Wi-Fi
- **Access**: SSH and Raspberry Pi Connect

Full system details: [Raspberry Pi 5 System Setup Document.md](Raspberry%20Pi%205%20System%20Setup%20Document.md)

## Quick Start

### Prerequisites

SSH access to fart-pi:
```bash
ssh tyler@192.168.1.115
```

### Initial Setup

1. Install Docker on the Pi:
```bash
./scripts/setup-docker.sh
```

2. Deploy a service:
```bash
./scripts/deploy-service.sh navidrome
```

## Documentation

All documentation is in the [docs](docs) directory:

- [Hardware & Network](docs/hardware.md) - Pi 5 specifications and network configuration
- [Deployment Guide](docs/deployment.md) - How to deploy and manage services
- [Services](docs/services/) - Individual service documentation

## Project Structure

```
boy-pocket/
├── docs/              # All documentation
├── services/          # Service configurations
│   └── navidrome/    # Music streaming service
├── scripts/          # Deployment and setup scripts
└── README.md         # This file
```

## Future Services

Planned additions:
- Home automation
- Media management
- Network monitoring
- Development tools

## Remote Access

The Pi is accessible remotely via:
- **Raspberry Pi Connect**: https://connect.raspberrypi.com
- **Local SSH**: `ssh tyler@192.168.1.115` (Wi-Fi) or `ssh tyler@192.168.1.116` (Ethernet)

## Contributing

This is a personal project for managing fart-pi services and configuration.

## License

Personal use repository.
