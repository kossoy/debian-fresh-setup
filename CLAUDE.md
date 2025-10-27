# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Semi-automated development environment setup tool for Debian-based Linux distributions. Automates installation of development tools, shell configuration, and provides a structured workspace with **context switching** between work and personal environments to prevent credential leakage.

**Target Systems**: Debian 13+, Ubuntu 22.04+, Linux Mint 21+, Pop!_OS 22.04+

## Bootstrap Entry Points

Three installation methods (choose based on user's needs):

1. **`simple-bootstrap.sh`** (Recommended): Non-interactive, installs packages + Docker + Oh My Zsh + deploys configs. Use this by default.
2. **`bootstrap.sh`**: Interactive installer with user prompts for customization. Only use if user explicitly wants guided setup.
3. **`install.sh`**: Web-accessible one-liner that handles git installation, repo cloning, and offers to run simple-bootstrap.sh. Solves the bootstrap problem on fresh systems.

## Repository Structure

```
debian-fresh-setup/
├── bootstrap.sh, simple-bootstrap.sh, install.sh  # Entry points
├── setup-helpers/            # Modular, idempotent setup scripts
│   ├── 01-install-packages.sh    # APT packages, GitHub CLI, eza, symlinks
│   ├── 02-install-oh-my-zsh.sh   # Oh My Zsh + plugins + Powerlevel10k
│   ├── 03-setup-shell.sh         # Deploy modular zsh config
│   ├── 03-git-and-ssh-setup.sh   # Interactive Git/SSH/GitHub setup
│   ├── 04-install-docker.sh      # Docker Engine + Docker Compose
│   ├── 05-install-python.sh      # pyenv + Python versions
│   ├── 06-install-nodejs.sh      # Volta (Node.js version manager)
│   ├── 07-setup-databases.sh     # Docker database containers
│   ├── 08-restore-sensitive.sh   # Restore sensitive data from backups
│   └── 09-install-ai-ml-tools.sh # AI/ML development tools
├── config/zsh/               # Shell configuration (SOURCE OF TRUTH)
│   ├── config/              # Modular configs: aliases, functions, paths, tools, context
│   │   ├── aliases.zsh
│   │   ├── functions.zsh
│   │   ├── paths.zsh
│   │   ├── tools.zsh
│   │   ├── context.zsh      # Context switching implementation
│   │   └── python.zsh
│   └── zshrc.template       # Template (not used by simple-bootstrap)
├── scripts/                 # Utility scripts → installed to ~/work/scripts/
├── setup/                   # User documentation guides
└── systemd-templates/       # Systemd service templates
```

## Core Architecture

### 1. Context Switching System (Most Important Feature)

**Purpose**: Prevent accidentally committing with wrong email/SSH key by automatically switching Git credentials, SSH keys, and directories.

**Implementation** (defined in `config/zsh/config/context.zsh`):
- Functions: `work`, `personal`, `show-context`
- State file: `~/.zsh/private/current.zsh` (dynamically generated on context switch)
- When switching context:
  1. Writes heredoc to `~/.zsh/private/current.zsh` with `GIT_AUTHOR_*`, `GIT_COMMITTER_*`, `WORK_CONTEXT` env vars
  2. Sources the file to apply immediately
  3. Optionally loads SSH key (if `~/.ssh/id_ed25519_work` or `~/.ssh/id_ed25519_personal` exists)
  4. Changes to context-specific directory (`~/work/projects/work` or `~/work/projects/personal`)

**Critical for editing**: When modifying `context.zsh`, preserve the heredoc format for writing `current.zsh` and maintain the SSH key loading logic.

**Directory structure**:
```
~/work/
├── projects/{work,personal}/  # Context-separated projects
├── configs/{work,personal}/   # Context-specific configs
├── scripts/                   # Utility scripts (ai_wdu.sh, systemd-manager.sh, etc.)
└── databases/, tools/, docs/, bin/
```

### 2. Modular Shell Configuration

**Source of truth**: `config/zsh/config/*.zsh` files in this repo
**Deployed to**: `~/.zsh/config/*.zsh` by bootstrap scripts

Split into modules (loaded in order by `~/.zshrc`):
1. `paths.zsh` - PATH management
2. `aliases.zsh` - Command aliases (ls→eza, system shortcuts, package management)
3. `functions.zsh` - Shell functions (psme, myip, extract, mkcd, etc.)
4. `tools.zsh` - Tool-specific configurations (pyenv, volta, docker, etc.)
5. `context.zsh` - Context switching functions
6. `python.zsh` - Python-specific configuration

**Private directory** (`~/.zsh/private/`): Not version controlled, contains:
- `current.zsh` - Current context state (auto-generated)
- `api-keys.zsh` - API keys (user-created)

**When editing**: Always edit files in `config/zsh/config/`, not deployed user configs.

### 3. Setup Helper Design Pattern

All scripts in `setup-helpers/` are:
- **Idempotent**: Safe to run multiple times
- **Independent**: Can run standalone or via bootstrap
- **Distribution-aware**: Check for APT, detect Debian/Ubuntu, warn if not compatible

Key implementation details:
- All scripts use `set -e` for error handling
- Distribution detection via `/etc/os-release` and `command -v apt`
- Debian package name workarounds:
  - `batcat` → symlinked to `/usr/local/bin/bat`
  - `fdfind` → symlinked to `/usr/local/bin/fd`
- Third-party repos added for: GitHub CLI (`gh`), `eza` (modern ls replacement)
- **Optional packages** (`neovim`, `btop`, `tldr`, `fastfetch`) - not available in all Debian versions, gracefully skipped if unavailable

### 4. Deployment Flow

**simple-bootstrap.sh workflow**:
1. Detect OS (Linux check) and distribution (APT check)
2. Install essential packages via APT
3. Install optional packages (with fallback if unavailable)
4. Add third-party repos (gh, eza)
5. Create symlinks (fd, bat)
6. Install Docker Engine + add user to docker group (handles missing systemd)
7. Install Oh My Zsh + plugins (zsh-autosuggestions, zsh-syntax-highlighting) + Powerlevel10k theme
8. Create `~/.zsh/{config,private}` directories
9. Copy `config/zsh/config/*.zsh` → `~/.zsh/config/`
10. Generate `~/.zshrc` (sources Oh My Zsh + custom configs)
11. Copy p10k config
12. Create `~/work/` directory structure
13. Copy utility scripts to `~/work/scripts/`
14. Offer to set zsh as default shell via `chsh`

## Commands for Development

### Testing & Running

```bash
# Test bootstrap (recommended for testing changes)
./simple-bootstrap.sh

# Test interactive bootstrap in test mode
./bootstrap.sh --test

# Run individual setup helpers (idempotent)
./setup-helpers/01-install-packages.sh
./setup-helpers/04-install-docker.sh
# etc.

# Test in Docker (clean environment)
docker compose -f test/docker/docker-compose.yaml up -d --build --remove-orphans
docker compose -f test/docker/docker-compose.yaml exec debian-test-container bash
# Inside container:
cd debian-fresh-setup && ./simple-bootstrap.sh
```

### Working with Configurations

```bash
# ALWAYS edit source files (in repo):
vim config/zsh/config/aliases.zsh
vim config/zsh/config/context.zsh

# Test changes by copying to deployed location:
cp config/zsh/config/aliases.zsh ~/.zsh/config/
source ~/.zshrc

# Verify context switching:
work && show-context
personal && show-context
echo $GIT_AUTHOR_EMAIL
ssh-add -l
```

### Utility Scripts

```bash
wdu                                  # Disk usage analyzer (also in scripts/ai_wdu.sh)
~/work/scripts/systemd-manager.sh    # Manage systemd services
~/work/scripts/update-check.sh       # Check for updates
~/work/scripts/backup-configs.sh     # Backup configurations
```

## Key Patterns & Conventions

### Bash Script Standards

All setup scripts follow:
- `set -e` for error handling
- Color-coded output (BLUE=info, GREEN=success, YELLOW=warning, RED=error)
- Distribution compatibility checks
- Idempotent operations (check before install)

Example pattern:
```bash
if ! command -v gh >/dev/null 2>&1; then
    # Install gh
else
    echo "✅ gh already installed"
fi
```

### Handling Missing Systemd (Docker containers, etc.)

When using systemctl commands:
```bash
if systemctl --version >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
else
    echo "⚠️  Systemd not available, skipping service management"
fi
```

### Handling Optional Packages

Some packages may not be available in all Debian versions:
```bash
for pkg in neovim btop tldr fastfetch; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
        sudo apt install -y "$pkg" || echo "⚠️  Failed to install $pkg, skipping..."
    else
        echo "⚠️  Package $pkg not available, skipping..."
    fi
done
```

### Context Switching Critical Code

When modifying `context.zsh`, preserve this pattern:
```bash
work() {
    cat > "$CONTEXT_FILE" << 'WORKEOF'
export WORK_CONTEXT="work"
export GIT_AUTHOR_NAME="..."
export GIT_AUTHOR_EMAIL="..."
# ... more vars
WORKEOF
    source "$CONTEXT_FILE"
    # SSH key loading logic
}
```

### Git Workflow

- Main branch is stable
- Commit messages use imperative mood ("Add feature", "Fix bug", "Update config")
- Each logical change is a separate commit

## Testing

See `test/TESTING_RESULTS.md` for comprehensive testing documentation including all issues found and fixed during Docker container testing.

**Key Testing Fixes**:
1. Optional packages handle missing packages gracefully
2. `$(whoami)` instead of `$USER` for Docker compatibility
3. Systemd detection before service management commands

## Related

**macOS version**: https://github.com/kossoy/macos-fresh-setup (similar architecture, different package manager/service management)
