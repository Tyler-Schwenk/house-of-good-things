# Homelab

Overview of machines and services in the lab.

---

# Topology

```mermaid
flowchart TB

subgraph "House of good things"
    FartPi[FartPi]
    NetBird --> FartPi
end

subgraph "Beer home"
    Bebop[Bebop]
    NetBird --> Bebop
end

subgraph "JohnHOME"
    JohnNAS[JohnNAS]
    JohnSERV[JohnSERV]
    NetBird["NetBird Overlay Network - lives in JohnHOME"]
    NetBird -. hosted on .-> JohnSERV
    NetBird --> JohnNAS
    NetBird --> JohnSERV
end
```

---

# NetBird Access

All host-to-host connectivity in this lab is expected to run over NetBird.

1. Install NetBird on your client and sign in to the same NetBird network.
2. Verify your peer is connected in the NetBird dashboard.
3. Connect to services using each node's NetBird IP or DNS name.

Example:

```bash
ssh user@<netbird-hostname-or-ip>
```

---

# Sites

## JohnSERV

| Site | Server | URL |
| --- | --- | --- |
| Jellyfin | JohnSERV | http://100.124.56.240:8096/ |

---

# Services

```mermaid
flowchart LR

Navidrome --> FartPi
Mattbot --> Bebop
LLM --> Bebop
SpeechToText[Speech to Text] --> Bebop

TrueNAS --> JohnNAS

Jellyfin --> JohnSERV
Minecraft[Minecraft Server] --> JohnSERV
```

---

# Full View

```mermaid
flowchart TB

subgraph "House of good things"
    FartPi[FartPi]
    Navidrome
    Navidrome --> FartPi
    NetBird --> FartPi
end

subgraph "Beer home"
    Bebop[Bebop]
    Mattbot
    LLM
    STT[Speech to Text]

    Mattbot --> Bebop
    LLM --> Bebop
    STT --> Bebop
    NetBird --> Bebop
end

subgraph "JohnHOME"
    JohnNAS[JohnNAS]
    TrueNAS
    JohnSERV[JohnSERV]
    NetBird[NetBird Overlay Network]
    Jellyfin
    Minecraft

    TrueNAS --> JohnNAS
    Jellyfin --> JohnSERV
    Minecraft --> JohnSERV
    NetBird -. hosted on .-> JohnSERV
    NetBird --> JohnNAS
    NetBird --> JohnSERV
end
```