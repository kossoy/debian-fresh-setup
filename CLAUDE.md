# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a semi-automated development environment setup tool for Debian-based Linux distributions (Debian 13+, Ubuntu 22.04+, Linux Mint 21+, Pop!_OS 22.04+). It automates the installation of development tools, shell configuration, and provides a structured workspace with context switching between work and personal environments.

## Repository Structure

```
debian-fresh-setup/
├── bootstrap.sh              # Interactive, full-featured installer with user prompts
├── simple-bootstrap.sh       # Quick, non-interactive installer (recommended)
├── install.sh                # One-line web installer (downloads repo then runs setup)
├── setup-helpers/            # Modular setup scripts called by bootstrap
│   ├── 01-install-packages.sh    # APT packages, GitHub CLI, eza, symlinks
│   ├── 02-install-oh-my-zsh.sh   # Oh My Zsh, plugins, Powerlevel10k theme
│   ├── 03-setup-shell.sh         # Shell config deployment
│   ├── 03-git-and-ssh-setup.sh   # Interactive Git/SSH/GitHub setup
│   ├── 04-install-docker.sh      # Docker Engine and Docker Compose
│   ├── 05-install-python.sh      # pyenv, Python versions
│   ├── 06-install-nodejs.sh      # Volta (Node.js version manager)
│   ├── 07-setup-databases.sh     # Docker database containers
│   ├── 08-restore-sensitive.sh   # Restore sensitive data from backups
│   └── 09-install-ai-ml-tools.sh # AI/ML development tools
├── config/                   # Configuration templates
│   ├── zsh/                 # Shell configuration files (source of truth)
│   │   ├── config/          # Modular zsh configs (aliases, functions, paths, tools, context)
│   │   └── zshrc.template   # Main zshrc template
│   └── p10k.zsh             # Powerlevel10k theme configuration
├── scripts/                 # Utility scripts installed to ~/work/scripts/
│   ├── wdu.sh              # Disk usage analyzer (also aliased as 'wdu')
│   ├── systemd-manager.sh  # Systemd user service management
│   ├── update-check.sh     # System update checker
│   ├── backup-configs.sh   # Configuration backup tool
│   ├── llm-usage.sh        # LLM API usage tracker
│   ├── sync-to-branches.sh # Sync files across git branches
│   ├── organize-screenshots.sh
│   └── video-to-audio.sh
├── setup/                   # Documentation guides
│   ├── 01-system-setup.md
│   ├── 02-python-environment.md
│   ├── 03-nodejs-environment.md
│   ├── 04-docker-setup.md
│   ├── 05-git-configuration.md
│   └── 06-context-switching.md  # Complete context switching guide
└── systemd-templates/       # Systemd service templates
```

## Key Architecture Concepts

### 1. Two Bootstrap Approaches

- **`simple-bootstrap.sh`** (Recommended): Quick, non-interactive setup that installs packages, Docker, Oh My Zsh, and deploys configurations. Always choose this for automated/fast setup.
- **`bootstrap.sh`**: Full interactive installer with user prompts for customization (name, emails, browsers, VPN, installation mode selection). Use only if user explicitly wants guided setup.
- **`install.sh`**: Web-accessible one-liner that handles git installation, repo cloning, and offers to run simple-bootstrap.sh. This solves the bootstrap problem on fresh systems.

### 2. Modular Setup Helpers

All setup scripts in `setup-helpers/` are:
- **Idempotent**: Can be run multiple times safely
- **Independent**: Can be run standalone or as part of bootstrap
- **Distribution-aware**: Detect Debian-based systems and fail gracefully otherwise

Key scripts:
- `01-install-packages.sh`: Installs essential tools via APT, adds third-party repos (GitHub CLI, eza), creates symlinks for Debian-specific names (fdfind→fd, batcat→bat)
- `02-install-oh-my-zsh.sh`: Installs Oh My Zsh framework, zsh-autosuggestions, zsh-syntax-highlighting, and Powerlevel10k theme
- `03-setup-shell.sh`: Deploys modular zsh configuration from `config/zsh/` to `~/.zsh/`
- `04-install-docker.sh`: Installs Docker Engine, adds user to docker group, enables systemd services

### 3. Context Switching System

**Core Concept**: Automatically switch Git credentials, SSH keys, and working directories between work and personal contexts to prevent credential leakage.

**Implementation**:
- Functions defined in `config/zsh/config/context.zsh`
- State stored in `~/.zsh/private/current.zsh` (generated dynamically)
- Available commands: `work`, `personal`, `show-context`

**How it works**:
1. `work` or `personal` command writes context-specific environment variables to `~/.zsh/private/current.zsh`
2. Sets `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL`
3. Clears SSH agent and loads context-specific SSH key
4. Changes directory to context-specific project folder
5. New shells source `current.zsh` to maintain context

**Directory structure created**:
```
~/work/
├── projects/{work,personal}/  # Separate project directories per context
├── configs/{work,personal}/   # Context-specific configs
├── databases/                 # Docker database configs
├── scripts/                   # Utility scripts
├── tools/                     # Development tools
├── docs/                      # Documentation
└── bin/                       # Custom binaries
```

### 4. Configuration Philosophy

**Modular Shell Config**: Instead of one monolithic `.zshrc`, configuration is split into:
- `aliases.zsh`: Command aliases (ls→eza, system shortcuts)
- `functions.zsh`: Shell functions (psme, myip, etc.)
- `paths.zsh`: PATH management
- `tools.zsh`: Tool-specific configurations
- `context.zsh`: Context switching functions
- `current.zsh` (private/): Active context state

**Benefits**:
- Easy to modify specific aspects without breaking others
- Can be version controlled (except private/ directory)
- Portable across systems

### 5. Debian-Specific Considerations

**Package Name Differences**:
- `bat` → `batcat` (symlinked to /usr/local/bin/bat)
- `fd` → `fdfind` (symlinked to /usr/local/bin/fd)
- Scripts handle this automatically

**Distribution Detection**:
All scripts check for:
1. Linux vs other OS (uname -s)
2. APT package manager presence
3. Distribution ID via /etc/os-release
4. Warn if not Debian/Ubuntu-based but allow continuation

## Development Commands

### Testing Bootstrap Scripts

```bash
# Test simple bootstrap (recommended)
./simple-bootstrap.sh

# Test full interactive bootstrap in test mode
./bootstrap.sh --test

# Run individual setup helpers
./setup-helpers/01-install-packages.sh
./setup-helpers/02-install-oh-my-zsh.sh
# etc.
```

### Working with Shell Configurations

```bash
# Edit configurations (source of truth)
config/zsh/config/aliases.zsh
config/zsh/config/functions.zsh
config/zsh/config/context.zsh

# Test changes by copying to home directory
cp config/zsh/config/aliases.zsh ~/.zsh/config/aliases.zsh
source ~/.zshrc

# After bootstrap, user configs are at:
~/.zsh/config/           # Deployed configs
~/.zsh/private/          # Private data (API keys, current context)
```

### Context Switching Testing

```bash
# Switch contexts
work         # Switch to work context
personal     # Switch to personal context
show-context # Display current context

# Verify Git configuration
git config user.name
git config user.email
echo $GIT_AUTHOR_EMAIL

# Check loaded SSH keys
ssh-add -l
```

### Common Utility Scripts

```bash
wdu                              # Disk usage analyzer
~/work/scripts/systemd-manager.sh    # Manage systemd services
~/work/scripts/update-check.sh       # Check for updates
~/work/scripts/backup-configs.sh     # Backup configurations
```

## Important Notes for Claude Code

### When Making Changes

1. **Shell Configs**: Always edit files in `config/zsh/`, not in example home directories. These are the source templates.

2. **Script Modifications**: All bash scripts should:
   - Include `set -e` for error handling
   - Check for distribution compatibility
   - Be idempotent (safe to run multiple times)
   - Provide clear status messages with colored output

3. **Context Switching**: When modifying context.zsh:
   - Remember the heredoc format for writing `current.zsh`
   - Maintain SSH key loading logic
   - Preserve directory navigation
   - Keep show-context function in sync

4. **Documentation**: The README.md is the primary user-facing documentation. Keep it in sync with:
   - Available features
   - Installation commands
   - Directory structure
   - Context switching commands

### Testing Strategy

1. **VM Testing**: Changes should ideally be tested on fresh Debian VM
2. **Dry-run**: Use echo instead of actual commands for testing script flow
3. **Test Mode**: Use `bootstrap.sh --test` for non-interactive testing
4. **Idempotency**: Always test running scripts twice to ensure they handle existing installations

### Git Workflow

- **Main branch**: Stable, tested configurations
- Recent commits show pattern: Feature additions with descriptive messages
- Commit messages use imperative mood ("Add X", "Update Y", "Fix Z")
- Each logical change is a separate commit

### Common Patterns

**Color codes used throughout**:
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'  # No Color
```

**Status messages**:
```bash
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
```

**Distribution checking pattern**:
```bash
if ! command -v apt >/dev/null 2>&1; then
    echo "❌ This script requires apt package manager"
    exit 1
fi
```

## Related Projects

**macOS Version**: https://github.com/kossoy/macos-fresh-setup
- Similar architecture but uses Homebrew instead of APT
- LaunchAgents instead of systemd
- Different package names and installation methods
