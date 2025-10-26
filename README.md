# Debian Fresh Setup Package

🚀 **Semi-automated development environment setup for Debian 13**

## Quick Start

### 1. Clone & Run
```bash
git clone https://github.com/username/debian-fresh-setup.git
cd debian-fresh-setup
chmod +x simple-bootstrap.sh
./simple-bootstrap.sh
```

### 2. Set zsh as Default Shell
```bash
chsh -s $(which zsh)
# Logout and login again for changes to take effect
```

### 3. Reload Shell
```bash
source ~/.zshrc
# or restart your terminal
```

## What You Get

✅ **Enhanced Shell**: Oh My Zsh + Powerlevel10k + custom functions  
✅ **Context Switching**: Automatic work/personal environment switching  
✅ **Utility Scripts**: Disk usage, process management, network tools  
✅ **Work Organization**: Structured project directories  
✅ **Linux Integration**: Systemd services, apt package management  

## Essential Commands

```bash
work                    # Switch to work context
personal               # Switch to personal context
show-context           # Check current context
wdu                    # Disk usage analyzer
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

- **Quick Setup**: See `simple-bootstrap.sh` for minimal setup
- **Setup Guides**: See `setup/` directory for detailed instructions
- **Guides**: See `guides/` directory for specific configurations

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
./setup-helpers/01-install-packages.sh
./setup-helpers/02-install-oh-my-zsh.sh
./setup-helpers/03-setup-shell.sh
```

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

1. Configure Git:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. Set up SSH keys:
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```

3. Install additional development tools (see `setup/` guides)

4. Configure context switching (see `guides/context-switching.md`)

---

**Ready to code!** 🚀

**Last Updated**: October 26, 2025  
**System**: Debian 13  
**Architecture**: x86_64 / ARM64
