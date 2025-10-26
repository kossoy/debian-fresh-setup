# System Setup - Debian 13

Initial system configuration for Debian 13 development environment.

## Prerequisites

- Debian 13 (Trixie) or compatible Debian-based distribution
- Administrator/sudo access
- Stable internet connection

## Development Environment Organization

Recommended directory structure for both **work** and **personal** projects:

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

### Initial Setup

```bash
# Create the organized development structure
mkdir -p ~/work/{databases,tools,projects/{work,personal},configs/{work,personal},scripts,docs,bin}

# Set up Git for the work directory (optional)
cd ~/work
git init
echo "*.log" >> .gitignore
echo "node_modules/" >> .gitignore
echo ".DS_Store" >> .gitignore
echo "projects/work/" >> .gitignore  # Exclude work projects from personal repo
echo "configs/work/" >> .gitignore   # Exclude work configs from personal repo
```

## 1. System Updates

```bash
# Update package lists
sudo apt update

# Upgrade all packages
sudo apt upgrade -y

# Install firmware updates (if applicable)
sudo apt full-upgrade -y
```

## 2. Essential Build Tools

Required for many development tools including compilers and more.

```bash
# Install build essentials
sudo apt install -y build-essential

# Verify installation
gcc --version
make --version
```

## 3. Essential Packages

Install core utilities and development tools.

```bash
# Core utilities
sudo apt install -y git wget curl tree jq htop unzip zip

# Modern CLI tools
sudo apt install -y bat fd-find ripgrep

# Development tools
sudo apt install -y vim nano zsh

# All at once
sudo apt install -y git wget curl tree jq bat fd-find ripgrep build-essential vim nano zsh htop unzip zip
```

### Create Symlinks for Debian-Specific Commands

Debian names some packages differently:

```bash
# fd-find is named 'fdfind' on Debian
sudo ln -s $(which fdfind) /usr/local/bin/fd

# bat is named 'batcat' on Debian  
sudo ln -s $(which batcat) /usr/local/bin/bat
```

## 4. Install eza (Modern ls Replacement)

```bash
# Add eza repository
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Install eza
sudo apt update
sudo apt install -y eza

# Verify installation
eza --version
```

## 5. Shell Configuration (Zsh)

Debian supports Zsh as a powerful alternative to Bash.

```bash
# Install Zsh (if not already installed)
sudo apt install -y zsh

# Verify installation
zsh --version

# Set Zsh as default shell
chsh -s $(which zsh)

# Logout and login again for changes to take effect
```

## 6. Install Oh My Zsh

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install useful plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

## 7. Enhanced Shell Configuration

### Option A: Automated Setup (Recommended)

Use the setup script from this repository:

```bash
# Clone this repository
git clone https://github.com/username/debian-fresh-setup.git ~/debian-fresh-setup

# Run the simple bootstrap
cd ~/debian-fresh-setup
chmod +x simple-bootstrap.sh
./simple-bootstrap.sh
```

### Option B: Manual Setup

Set up basic shell configuration manually:

```bash
# Create zsh configuration structure
mkdir -p ~/.zsh/{config,private}

# Create paths configuration
cat > ~/.zsh/config/paths.zsh << 'PATHS_EOF'
# Development paths
export WORK_ROOT="$HOME/work"
export PROJECTS_ROOT="$WORK_ROOT/projects"
export CONFIGS_ROOT="$WORK_ROOT/configs"
export SCRIPTS_ROOT="$WORK_ROOT/scripts"
export TOOLS_ROOT="$WORK_ROOT/tools"
export DOCS_ROOT="$WORK_ROOT/docs"

# Add scripts to PATH
export PATH="$SCRIPTS_ROOT:$PATH"
export PATH="$HOME/work/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Editor preferences
export EDITOR="vim"
export VISUAL="vim"
export GIT_EDITOR="vim"
PATHS_EOF

# Create basic aliases
cat > ~/.zsh/config/aliases.zsh << 'ALIASES_EOF'
# Navigation shortcuts
alias cdwork="cd $PROJECTS_ROOT"
alias cdscripts="cd $SCRIPTS_ROOT"
alias cddocs="cd $DOCS_ROOT"

# Common shortcuts
alias ll="ls -la"
alias la="ls -la"
alias ..="cd .."
alias ...="cd ../.."

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias glog="git log --oneline --graph --decorate"

# System shortcuts
alias update="sudo apt update"
alias upgrade="sudo apt upgrade"
alias install="sudo apt install"
alias remove="sudo apt remove"
ALIASES_EOF

# Update .zshrc
cat >> ~/.zshrc << 'ZSHRC_EOF'

# Load custom configuration
ZSH_CONFIG_DIR="$HOME/.zsh/config"
[ -f "$ZSH_CONFIG_DIR/paths.zsh" ] && source "$ZSH_CONFIG_DIR/paths.zsh"
[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ] && source "$ZSH_CONFIG_DIR/aliases.zsh"
ZSHRC_EOF

# Reload shell
source ~/.zshrc
```

## 8. Verify Installation

```bash
# Reload shell configuration
source ~/.zshrc

# Verify Git
git --version

# Verify Zsh
echo $SHELL  # Should be /usr/bin/zsh or /bin/zsh

# Verify other tools
jq --version
rg --version
eza --version
```

## 9. Additional System Configuration

### Enable systemd user services

```bash
# Enable lingering (allows user services to run without being logged in)
loginctl enable-linger $USER
```

### Install additional useful packages

```bash
# Network tools
sudo apt install -y net-tools dnsutils traceroute netcat-openbsd

# System monitoring
sudo apt install -y iotop iftop nethogs sysstat

# Archive tools
sudo apt install -y p7zip-full unrar-free

# X11/Wayland clipboard tools
sudo apt install -y xclip wl-clipboard  # Install based on your display server
```

## Next Steps

Continue with:
- **[Python Environment](02-python-environment.md)** - Set up Python development
- **[Node.js Environment](03-nodejs-environment.md)** - Set up JavaScript development
- **[Docker Setup](04-docker-setup.md)** - Set up Docker and containers

---

**Estimated Time**: 30 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 26, 2025
