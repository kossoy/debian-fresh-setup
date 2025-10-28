# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Semi-automated development environment setup tool for Debian-based Linux distributions. Automates installation of development tools, shell configuration, and provides a structured workspace with **context switching** between work and personal environments to prevent credential leakage.

**Target Systems**: Debian 13+, Ubuntu 22.04+, Linux Mint 21+, Pop!_OS 22.04+

## Bootstrap Entry Points

Three installation methods (choose based on user's needs):

1. **`install.sh`** (Primary entry point): Web-accessible one-liner that clones repo and **automatically runs** `simple-bootstrap.sh` without prompts. After basic setup completes, offers optional full bootstrap. This is the intended user flow.
   - Command: `bash <(wget -qO- https://raw.githubusercontent.com/kossoy/debian-fresh-setup/main/install.sh)`

2. **`simple-bootstrap.sh`** (Default automation): Non-interactive, installs packages + Docker + Oh My Zsh + deploys configs. Automatically called by install.sh.

3. **`bootstrap.sh`** (Advanced/Interactive): Interactive installer with Git/SSH/GitHub configuration prompts. Optionally called by install.sh after simple setup. Does NOT include Python/Node/databases/AI-ML (those are separate setup-helpers).

## Repository Structure

```
debian-fresh-setup/
├── bootstrap.sh, simple-bootstrap.sh, install.sh  # Entry points
├── setup-helpers/            # Modular, idempotent setup scripts
│   ├── 01-install-packages.sh    # APT packages, GitHub CLI, eza, symlinks
│   ├── 02-install-oh-my-zsh.sh   # Oh My Zsh + plugins + Powerlevel10k
│   ├── 03-setup-shell.sh         # Deploy modular zsh config (called by simple-bootstrap.sh)
│   ├── 03-git-and-ssh-setup.sh   # Interactive Git/SSH/GitHub setup (called by bootstrap.sh)
│   ├── 04-install-docker.sh      # Docker Engine + Docker Compose
│   ├── 05-install-python.sh      # pyenv + Python versions
│   ├── 06-install-nodejs.sh      # Volta (Node.js version manager)
│   ├── 07-setup-databases.sh     # Docker database containers
│   ├── 08-restore-sensitive.sh   # Restore sensitive data from backups
│   └── 09-install-ai-ml-tools.sh # AI/ML development tools
│   Note: Two scripts share "03-" prefix - they serve different bootstrap flows
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
│   ├── ai_wdu.sh              # Disk usage analyzer (zsh version)
│   ├── backup-configs.sh      # Backup shell configurations
│   ├── llm-usage.sh           # Track LLM API usage and costs
│   ├── organize-screenshots.sh # Organize screenshot files
│   ├── sync-to-branches.sh    # Sync files across git branches
│   ├── systemd-manager.sh     # Manage systemd user services
│   ├── update-check.sh        # Check for system updates
│   └── video-to-audio.sh      # Convert video files to audio
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
- **Optional packages** (`neovim`, `btop`, `fastfetch`) - not available in all Debian versions, gracefully skipped if unavailable
- **Package replacements**: `tldr` was removed from Debian, replaced with `tealdeer` (Rust-based tldr client that provides the same `tldr` command)

### 4. Deployment Flow

**install.sh (one-liner) workflow**:
1. Check Linux + APT availability
2. Install git if missing
3. Clone repo to `~/debian-fresh-setup`
4. **Automatically run** `simple-bootstrap.sh` (no prompt)
5. After completion, offer to run `bootstrap.sh` (Git/GitHub setup)
6. Show commands for optional tools (Python, Node, databases, AI-ML)

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

**Optional tools** (run separately after basic setup):
- Python: `./setup-helpers/05-install-python.sh`
- Node.js: `./setup-helpers/06-install-nodejs.sh`
- Databases: `./setup-helpers/07-setup-databases.sh`
- AI/ML: `./setup-helpers/09-install-ai-ml-tools.sh`

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

# Test in Docker (clean environment, mimics real user experience)
cd docker-test-env

# Use convenience scripts (recommended):
./build.sh           # Build the container image
./up.sh              # Start container in detached mode
./exec.sh            # Enter container with bash (default)
./exec.sh zsh        # Enter container with zsh (after bootstrap)
./clean.sh           # Complete cleanup (removes images and volumes)

# Or use docker compose directly:
cd docker
docker compose up -d --build
docker exec -it debian-test-container bash

# Inside container - test one-liner from GitHub (recommended):
bash <(wget -qO- https://raw.githubusercontent.com/kossoy/debian-fresh-setup/main/install.sh)

# Or test manual clone:
git clone https://github.com/kossoy/debian-fresh-setup.git
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
wdu                                      # Disk usage analyzer (alias to scripts/ai_wdu.sh)
~/work/scripts/systemd-manager.sh        # Manage systemd user services
~/work/scripts/update-check.sh           # Check for system updates
~/work/scripts/backup-configs.sh         # Backup shell configurations
~/work/scripts/llm-usage.sh              # Track LLM API usage and costs
~/work/scripts/organize-screenshots.sh   # Organize screenshot files by date
~/work/scripts/sync-to-branches.sh       # Sync files across git branches
~/work/scripts/video-to-audio.sh         # Convert video to audio (ffmpeg)
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
for pkg in neovim btop fastfetch; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
        # Check install output for "no installation candidate" errors
        if sudo apt install -y "$pkg" 2>&1 | grep -q "has no installation candidate\|is not available"; then
            echo "⚠️  Package $pkg not available, skipping..."
        fi
    else
        echo "⚠️  Package $pkg not available in repositories, skipping..."
    fi
done
```

**Why this pattern**: Some packages may have complex dependencies that cause `apt-cache show` to succeed but `apt install` to fail. The grep check catches these cases without breaking `set -e`.

### Handling Package Replacements

The `tldr` package was removed from Debian Bookworm/Trixie. Use `tealdeer` as replacement:
```bash
# Install tealdeer (tldr replacement) - available in Bookworm and Trixie
echo "📦 Installing tealdeer (tldr pages client)..."
if apt-cache show tealdeer >/dev/null 2>&1; then
    sudo apt install -y tealdeer || echo "⚠️  Failed to install tealdeer, skipping..."
else
    echo "⚠️  Package tealdeer not available, skipping..."
fi
```

**Background**: The original `tldr` (Haskell client) was removed from Debian. `tealdeer` is a Rust-based implementation that provides the same `tldr` command and is the recommended replacement. Alternative: `tldr-py` (Python client).

### Context Switching Critical Code

When modifying `context.zsh`, preserve this pattern:
```bash
work() {
    echo "🏢 Switching to WORK context..."

    # Create context file with heredoc
    cat > "$CONTEXT_FILE" << 'WORKEOF'
export WORK_CONTEXT="work"
export GIT_AUTHOR_NAME="Your Work Name"
export GIT_AUTHOR_EMAIL="work@company.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export WORK_PROJECTS="$HOME/work/projects/work"
cd "$WORK_PROJECTS" 2>/dev/null || cd "$HOME/work"
WORKEOF

    # Source the file to apply immediately
    source "$CONTEXT_FILE"

    echo "✅ Work context activated"
    echo "   📧 Email: $GIT_AUTHOR_EMAIL"
    echo "   📁 Projects: $WORK_PROJECTS"
}
```

**Critical**: The heredoc delimiter must be quoted ('WORKEOF') to prevent variable expansion. The context file is sourced immediately after creation, and users must manually edit the template values (names/emails) after first setup.

### Git Workflow

- Main branch is stable
- Commit messages use imperative mood ("Add feature", "Fix bug", "Update config")
- Each logical change is a separate commit

## Testing

See `docker-test-env/TESTING_RESULTS.md` for comprehensive testing documentation including all issues found and fixed during Docker container testing.

**Docker Test Environment** (`docker-test-env/`):
- Isolated Debian stable container with sudo, wget, git pre-installed
- NO repository mounting (tests fresh clone from GitHub)
- Only APT cache volumes (faster rebuilds)
- Convenience scripts: `build.sh`, `up.sh`, `exec.sh [bash|zsh]`, `clean.sh`
- Or use `docker compose` directly from `docker-test-env/docker/`

**Key Testing Fixes**:
1. Optional packages handle missing packages gracefully (neovim, btop, fastfetch)
2. Replaced `tldr` with `tealdeer` - tldr was removed from Debian, tealdeer is the recommended replacement
3. `$(whoami)` instead of `$USER` for Docker compatibility
4. Systemd detection before service management commands
5. install.sh automatically runs simple-bootstrap.sh (tested successfully)

## Related

**macOS version**: https://github.com/kossoy/macos-fresh-setup (similar architecture, different package manager/service management)
