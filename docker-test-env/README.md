# Docker Test Environment

Clean, isolated Debian environment for testing bootstrap scripts.

## Structure

```
docker-test-env/
├── docker/
│   ├── Dockerfile              # Debian stable + sudo + wget + git
│   └── docker-compose.yaml     # Container orchestration
├── build.sh                    # Build container image
├── up.sh                       # Start container in detached mode
├── exec.sh                     # Enter container (bash or zsh)
├── clean.sh                    # Complete cleanup (images + volumes)
├── TESTING_RESULTS.md          # Test documentation
└── README.md                   # This file
```

## Safety First

**✅ No repository mounting** - Completely isolated container
**✅ No data volumes** - Everything stays inside container
**✅ Fresh start every time** - `docker compose down` removes everything

## Quick Start (Recommended)

```bash
cd docker-test-env

./build.sh      # Build the container image
./up.sh         # Start container in detached mode
./exec.sh       # Enter container with bash
./exec.sh zsh   # Enter container with zsh (after bootstrap)
./clean.sh      # Complete cleanup (removes everything)
```

## Usage

### Method 1: Convenience Scripts (Recommended)

```bash
cd docker-test-env

# Build and start
./build.sh
./up.sh

# Enter container
./exec.sh       # Default: bash
./exec.sh zsh   # Use zsh (after running bootstrap)

# Complete cleanup
./clean.sh      # Removes containers, images, and volumes
```

### Method 2: Docker Compose Directly

```bash
# From repo root
docker compose -f docker-test-env/docker/docker-compose.yaml up -d --build

# Or from docker-test-env/docker/
cd docker-test-env/docker
docker compose up -d --build

# Access container
docker exec -it debian-test-container bash
```

### Inside Container - Test Like a Real User

**Method 1: One-liner (recommended - tests the actual user flow)**
```bash
bash <(wget -qO- https://raw.githubusercontent.com/kossoy/debian-fresh-setup/main/install.sh)
```

**Method 2: Manual clone + simple bootstrap**
```bash
git clone https://github.com/kossoy/debian-fresh-setup.git
cd debian-fresh-setup
./simple-bootstrap.sh
```

**Method 3: Manual clone + interactive bootstrap**
```bash
git clone https://github.com/kossoy/debian-fresh-setup.git
cd debian-fresh-setup
./bootstrap.sh --test
```

### Verify Installation

```bash
# Check installed tools
command -v git gh docker zsh eza bat fd

# Check Oh My Zsh
ls ~/.oh-my-zsh

# Check zsh config
ls ~/.zsh/config/

# Test context switching
zsh
source ~/.zshrc
work
show-context
personal
show-context
```

### Stop and Clean Up

**Using convenience script (recommended):**
```bash
cd docker-test-env
./clean.sh      # Prompts for confirmation, removes everything
```

**Using docker compose directly:**
```bash
# Stop container and remove images (completely fresh start)
docker compose -f docker-test-env/docker/docker-compose.yaml down --rmi all

# Remove volumes too
docker volume rm docker_apt-cache docker_apt-lib

# Or from docker-test-env/docker/
cd docker-test-env/docker
docker compose down --rmi all
docker volume rm docker_apt-cache docker_apt-lib
```

## What Gets Tested

- ✅ Real Debian stable environment
- ✅ Fresh git clone from GitHub
- ✅ One-liner install.sh flow
- ✅ simple-bootstrap.sh (non-interactive)
- ✅ bootstrap.sh --test (interactive test mode)
- ✅ Package installation
- ✅ Docker installation
- ✅ Oh My Zsh + plugins
- ✅ Context switching
- ✅ All utility scripts

## Notes

- Container includes wget, git, sudo pre-installed (minimal Debian doesn't have them)
- APT cache is persisted between runs (faster rebuilds)
- Container runs as user `god` with sudo access
- Container hostname is `debian-test` for easy identification
