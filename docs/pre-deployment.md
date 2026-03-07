# Pre-Deployment Checklist

Before deploying services to fart-pi, complete these prerequisites.

## Required Accounts

### 1. NetBird Account (FREE)

**Why:** Provides VPN access for the Bird Wide Web collaborative network.

**Steps:**
1. Visit John's self-hosted NetBird dashboard: **https://johnserv.garrepi.dev**
2. Sign up (John can invite you or you can create an account)
3. Self-hosted instance = unlimited users and peers!

**After signup:**
- Access dashboard at https://johnserv.garrepi.dev
- You'll need to generate a setup key for the Pi
- No payment required (John hosts it)

### 2. Git Repository (Optional but Recommended)

**Why:** Easier to sync code between laptop and Pi.

**Options:**

**GitHub (Recommended):**
1. Create account at https://github.com
2. Create new repository: "house-of-good-things"
3. Make it private (contains configs, though no secrets committed)
4. Push this local repo to GitHub

**Alternative: Skip Git**
- Just copy files directly to Pi via SCP
- Less convenient for updates

## Pi Prerequisites

### 1. Network Access to Pi

**For initial deployment**, you need ONE of the following:

**Option A: Same Local Network (Easiest)**
- Be on the same WiFi/network as the Pi
- SSH directly: `ssh tyler@192.168.1.115` or `ssh tyler@192.168.1.116`

**Option B: Remote Access Tool**
- If Raspberry Pi Connect or another remote access tool is configured, use it
- Deploy NetBird through remote session
- After NetBird is running, switch to NetBird SSH

**Option C: Physical Access**
- Connect keyboard/monitor to the Pi
- Deploy NetBird directly on the Pi
- After NetBird is running, disconnect peripherals and access remotely

**After NetBird is deployed:** You can SSH from anywhere (coffee shops, travel, etc.) via NetBird:
```bash
ssh tyler@fart-pi.johnserv.garrepi.dev   # NetBird hostname
ssh tyler@100.124.76.27                  # NetBird IP
```

### 2. SSH Access Verification

If you're on the same local network, verify SSH works:

```bash
# From your laptop
ssh tyler@192.168.1.115
```

If this works, you're ready. If not, see network access options above.

### 3. Docker Installed

Check if Docker is installed on the Pi:

```bash
ssh tyler@192.168.1.115
docker --version
docker compose version
```

**If not installed:**
```bash
# Run on the Pi
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (avoid sudo)
sudo usermod -aG docker $USER

# Log out and back in for group to take effect
exit
ssh tyler@192.168.1.115

# Test without sudo
docker ps
```

### 4. Disk Space

Verify you have space for Docker images and databases:

```bash
df -h
```

Should have at least 5-10GB free on the system partition.

## Deployment Workflow Options

### Option A: Via GitHub (Recommended)

**On your laptop:**
```bash
cd house-of-good-things

# Create GitHub repo first, then:
git remote add origin git@github.com:yourusername/house-of-good-things.git
git branch -M main
git push -u origin main
```

**On the Pi:**
```bash
ssh tyler@192.168.1.115
cd ~
git clone git@github.com:yourusername/house-of-good-things.git
cd house-of-good-things
```

**Future updates:**
```bash
# On laptop: make changes, commit, push
git add .
git commit -m "Update config"
git push

# On Pi: pull changes
cd ~/house-of-good-things
git pull
```

### Option B: Direct SCP (Simpler, Less Convenient)

**Copy entire directory to Pi:**
```bash
# From your laptop (in parent directory)
scp -r house-of-good-things tyler@192.168.1.115:~/
```

**Future updates:**
```bash
# Copy just changed files
scp services/public-square/app/main.py tyler@192.168.1.115:~/house-of-good-things/services/public-square/app/
```

## Pre-Deployment Steps Summary

1. [ ] Create NetBird account
2. [ ] Decide: GitHub or direct copy?
3. [ ] If GitHub: Create repo and push code
4. [ ] SSH into Pi and verify Docker is installed
5. [ ] Get code onto Pi (clone or SCP)
6. [ ] Verify directory structure on Pi

## Verification

Before starting deployment, verify on the Pi:

```bash
ssh tyler@192.168.1.115

# Check Docker
docker --version

# Check repository
cd ~/house-of-good-things
ls -la services/

# Should see:
# - navidrome/
# - netbird/
# - public-square/
```

## What Happens During Deployment

1. **NetBird Deployment (~5 minutes)**
   - Generate setup key from NetBird dashboard
   - Configure environment variables (.env file)
   - Run `docker compose up -d`
   - Verify connection
   - Test SSH via NetBird hostname

2. **Public Square Deployment (~10 minutes)**
   - Generate JWT secret
   - Configure environment variables
   - Build Docker image (first time: 3-5 minutes)
   - Run `docker compose up -d`
   - Verify API responds
   - Test from within NetBird network
   - Test from frontend

## Next Document

Once prerequisites are complete, follow:
- [docs/phase1-deployment.md](phase1-deployment.md) for step-by-step deployment

## Notes

- Secrets (auth keys, passwords) are never committed to Git
- You'll create `.env` files on the Pi with actual secrets
- `.env.example` files in repo show what's needed
- Each service is independent (can deploy one at a time)
- No downtime when adding new services
