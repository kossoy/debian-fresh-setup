# Debian Fresh Setup Package

🚀 **Semi-automated development environment setup for Debian 13**

## Quick Start

### One-Line Installation (Recommended)

No git required! Just run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kossoy/debian-fresh-setup/main/install.sh)
```

Or with wget:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/kossoy/debian-fresh-setup/main/install.sh)
```

This will:
- Install git if needed
- Clone the repository to `~/debian-fresh-setup`
- Offer to run the automatic setup

### Alternative: Manual Clone & Run

If you already have git installed:

```bash
git clone https://github.com/kossoy/debian-fresh-setup.git
cd debian-fresh-setup
./simple-bootstrap.sh
```

### After Installation

1. Set zsh as default shell (if prompted):
   ```bash
   chsh -s $(which zsh)
   # Logout and login for changes to take effect
   ```

2. Reload shell:
   ```bash
   source ~/.zshrc
   ```

## What You Get

✅ **Enhanced Shell**: Oh My Zsh + Powerlevel10k + custom functions
✅ **Context Switching**: Automatic work/personal environment switching
✅ **Essential Dev Tools**: git, gh, vim, neovim, tmux, htop, btop, ncdu, tldr, ripgrep, bat, fd, eza
✅ **Utility Scripts**: Disk usage, systemd manager, update checker, backup tools
✅ **Work Organization**: Structured project directories
✅ **Linux Integration**: Systemd services, apt package management
✅ **Comprehensive Guides**: Python, Node.js, Docker, Git, SSH, Context Switching  

## Essential Commands

### Context Switching
```bash
work                    # Switch to work context
personal               # Switch to personal context
show-context           # Check current context
```

### Utility Scripts
```bash
wdu                    # Disk usage analyzer
~/work/scripts/systemd-manager.sh    # Manage systemd user services
~/work/scripts/update-check.sh       # Check for system updates
~/work/scripts/backup-configs.sh     # Backup configurations
~/work/scripts/llm-usage.sh          # Track LLM API usage
~/work/scripts/sync-to-branches.sh   # Sync files across git branches
```

### System Info
```bash
psme <process>         # Find processes
myip                   # Get your public IP
```

## Requirements

- **Debian-based Linux distribution** (see compatibility below)
- Administrator/sudo access
- Internet connection

### Distribution Compatibility

This setup is designed for **Debian-based distributions** using the `apt` package manager:

✅ **Fully Supported:**
- Debian 13 (Trixie) and newer
- Debian 12 (Bookworm)
- Ubuntu 22.04 LTS and newer
- Linux Mint 21+
- Pop!_OS 22.04+
- elementary OS 7+

⚠️ **May Work (not tested):**
- Other Debian/Ubuntu derivatives
- Older Debian/Ubuntu versions

❌ **Not Supported:**
- Red Hat/Fedora/CentOS/Rocky (uses `dnf`/`yum`)
- Arch Linux/Manjaro (uses `pacman`)
- openSUSE (uses `zypper`)
- Alpine Linux (uses `apk`)

**Note:** The script will detect your distribution and warn you if it's not Debian-based.

## Structure

```
~/work/
├── databases/          # Docker database configurations
├── tools/             # Development tools and utilities
├── projects/          # Development projects
│   ├── work/          # Work projects
│   └── personal/      # Personal projects
├── configs/           # Configuration files
│   ├── work/          # Work-specific configurations
│   └── personal/      # Personal project configurations
├── scripts/           # Custom scripts and automation
├── docs/              # Documentation and notes
└── bin/               # Custom binaries
```

## Documentation

### Quick Setup
- **Simple Bootstrap**: `simple-bootstrap.sh` - One-command setup

### Setup Helpers (in `setup-helpers/`)
- `01-install-packages.sh` - Install essential packages
- `02-install-oh-my-zsh.sh` - Install Oh My Zsh and plugins
- `03-git-and-ssh-setup.sh` - Interactive Git and SSH configuration

### Comprehensive Guides (in `setup/`)
- `01-zsh-configuration.md` - Shell configuration guide
- `02-python-environment.md` - Python development setup (pyenv, pip, virtualenv)
- `03-nodejs-environment.md` - Node.js development setup (Volta, npm, yarn)
- `04-docker-setup.md` - Docker and containerization setup
- `05-git-configuration.md` - Git configuration and SSH keys
- `06-context-switching.md` - Work/Personal context switching guide

### Systemd Templates (in `systemd-templates/`)
- Service templates for web apps, Python apps, and timers
- Complete README with examples and best practices

## Key Features

- **Context-Aware Development**: Separate work and personal environments
- **Docker-Based Databases**: PostgreSQL, MySQL, MongoDB, Redis with port isolation
- **Enhanced Shell**: Powerful zsh configuration with aliases, functions, and utilities
- **Linux Native**: Systemd integration, apt package management
- **Cross-Platform**: Many scripts compatible with the macOS version

## Package Management

### System Packages (apt)
```bash
update                 # Update package lists
upgrade                # Upgrade all packages
install <package>      # Install a package
remove <package>       # Remove a package
autoremove             # Remove unused dependencies
clean                  # Clean package cache
```

### Systemd Services
```bash
svc-status [service]   # Show service status
svc-start <service>    # Start a service
svc-stop <service>     # Stop a service
svc-restart <service>  # Restart a service
svc-enable <service>   # Enable service at boot
svc-disable <service>  # Disable service at boot
```

## Development Tools

The setup includes configurations for:
- Python (pyenv, pip, virtual environments)
- Node.js (nvm, volta, npm)
- Java (SDKMAN, Maven, Gradle)
- Docker & Docker Compose
- Kubernetes (kubectl, k9s)
- Git & GitHub CLI
- And more...

## Installation Modes

### Simple Installation (Recommended)
```bash
./simple-bootstrap.sh
```
Installs essential packages, Oh My Zsh, and shell configuration.

### Manual Installation
Run setup helpers individually:
```bash
./setup-helpers/01-install-packages.sh      # Install packages
./setup-helpers/02-install-oh-my-zsh.sh     # Install Oh My Zsh
./setup-helpers/03-git-and-ssh-setup.sh     # Configure Git and SSH
```

### Post-Installation Setup
Run the interactive Git and SSH setup:
```bash
./setup-helpers/03-git-and-ssh-setup.sh
```

This will guide you through:
- Git configuration (name, email, aliases)
- SSH key generation
- GitHub CLI authentication
- Multiple SSH keys for work/personal

## Customization

### Aliases
Edit `~/.zsh/config/aliases.zsh` for custom aliases

### Functions
Edit `~/.zsh/config/functions.zsh` for custom functions

### Paths
Edit `~/.zsh/config/paths.zsh` for PATH management

### Tools
Edit `~/.zsh/config/tools.zsh` for tool-specific configurations

## Troubleshooting

### Zsh not working after installation
```bash
# Set zsh as default shell
chsh -s $(which zsh)
# Logout and login again
```

### Command not found errors
```bash
# Reload shell configuration
source ~/.zshrc

# Check if PATH is set correctly
echo $PATH
```

### Permission denied errors
```bash
# Make scripts executable
chmod +x ~/work/scripts/*.sh
chmod +x ~/work/scripts/*.zsh
```

## Differences from macOS Version

- Uses `apt` package manager instead of Homebrew
- Systemd services instead of LaunchAgents
- Linux-specific commands (ss, systemctl, etc.)
- X11/Wayland clipboard support (xclip/wl-clipboard)
- Different package names (bat → batcat, fd → fdfind with symlinks)
- Distribution detection and compatibility checks
- **macOS version**: https://github.com/kossoy/macos-fresh-setup

## Next Steps

After installation:

1. **Configure Git and SSH** (Interactive):
   ```bash
   ./setup-helpers/03-git-and-ssh-setup.sh
   ```

2. **Customize Context Switching**:
   - Edit `~/.zsh/config/context.zsh`
   - Update work and personal email addresses
   - See `setup/06-context-switching.md` for full guide

3. **Set Up Development Environments**:
   - Python: See `setup/02-python-environment.md`
   - Node.js: See `setup/03-nodejs-environment.md`
   - Docker: See `setup/04-docker-setup.md`

4. **Configure API Keys** (Optional):
   ```bash
   nano ~/.zsh/private/api-keys.zsh
   chmod 600 ~/.zsh/private/api-keys.zsh
   ```

5. **Explore Utility Scripts**:
   ```bash
   ls -l ~/work/scripts/
   ```

---

**Ready to code!** 🚀

**Last Updated**: October 26, 2025  
**System**: Debian 13  
**Architecture**: x86_64 / ARM64
