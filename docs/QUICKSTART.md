# Debian 13 Fresh Setup - Quick Start Guide

Get your Debian development environment up and running in minutes!

## 🚀 Super Quick Setup (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/username/debian-fresh-setup.git
cd debian-fresh-setup

# 2. Run the simple bootstrap script
chmod +x simple-bootstrap.sh
./simple-bootstrap.sh

# 3. Set zsh as default shell
chsh -s $(which zsh)

# 4. Logout and login again (or reboot)
# Then open a new terminal
```

That's it! Your enhanced shell is ready.

## 📋 What Just Happened?

The bootstrap script:
1. ✅ Installed essential packages (git, curl, jq, bat, eza, etc.)
2. ✅ Installed Oh My Zsh with useful plugins
3. ✅ Installed Powerlevel10k theme
4. ✅ Set up organized zsh configuration
5. ✅ Created ~/work directory structure
6. ✅ Copied utility scripts

## 🎨 First Steps After Installation

### 1. Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 2. Try Out Some Commands

```bash
# Check your public IP
myip

# Disk usage analyzer
wdu

# Find processes
psme firefox

# System package management
update     # Update package lists
upgrade    # Upgrade packages
install vim # Install a package
```

### 3. Explore Your New Aliases

```bash
# Modern ls with colors
ll

# Jump up directories
..
...
....

# Git shortcuts
gs    # git status
ga    # git add
gc    # git commit
gp    # git push
gl    # git pull
```

## 🔧 Directory Structure

Your organized workspace:

```
~/work/
├── bin/               # Your custom scripts/binaries
├── scripts/           # Utility scripts
├── projects/          # Your development projects
│   ├── work/          # Work projects
│   └── personal/      # Personal projects
├── configs/           # Configuration files
│   ├── work/          # Work configs
│   └── personal/      # Personal configs
├── databases/         # Database docker configurations
├── tools/             # Development tools
└── docs/              # Documentation
```

## 💡 Common Tasks

### Update System Packages

```bash
update && upgrade
```

### Install Development Tools

```bash
# Python
sudo apt install -y python3 python3-pip python3-venv

# Node.js (using nvm - see setup guides)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Docker
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
```

### Customize Your Shell

Edit these files to customize:
- `~/.zsh/config/aliases.zsh` - Your aliases
- `~/.zsh/config/functions.zsh` - Custom functions
- `~/.zsh/config/paths.zsh` - PATH management
- `~/.zshrc` - Main configuration

### Reload Configuration

```bash
source ~/.zshrc
# or use the alias:
zshreload
```

## 🐛 Troubleshooting

### Zsh not the default shell?

```bash
# Set zsh as default
chsh -s $(which zsh)
# Logout and login again
```

### Commands not found?

```bash
# Reload configuration
source ~/.zshrc

# Check PATH
echo $PATH
```

### bat command not working?

```bash
# On Debian, bat is installed as batcat
# Create a symlink:
sudo ln -s $(which batcat) /usr/local/bin/bat
```

### fd command not working?

```bash
# On Debian, fd is installed as fdfind
# Create a symlink:
sudo ln -s $(which fdfind) /usr/local/bin/fd
```

## 📚 Next Steps

Now that you have the basics set up:

1. **Install Development Tools**
   - See `setup/02-python-environment.md` for Python
   - See `setup/03-nodejs-environment.md` for Node.js
   - See `setup/04-docker-setup.md` for Docker

2. **Set Up Context Switching**
   - Configure work/personal contexts
   - See `guides/context-switching.md`

3. **Install Your Favorite IDE**
   - VS Code: `sudo apt install code`
   - IntelliJ IDEA: Download from JetBrains website

4. **Set Up SSH Keys**
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com"
   cat ~/.ssh/id_ed25519.pub
   # Add to GitHub/GitLab
   ```

## 🎯 Useful Systemd Commands

```bash
# User services
svc-status          # List user services
svc-start <name>    # Start a service
svc-stop <name>     # Stop a service
svc-restart <name>  # Restart a service
svc-logs <name>     # View service logs
```

## 🌟 Pro Tips

1. **Use tab completion** - Zsh has amazing tab completion
2. **Use zsh-autosuggestions** - Press → to accept suggestions
3. **Use aliases** - Type `alias` to see all available aliases
4. **Explore functions** - Type `list_functions` to see custom functions
5. **Use bat instead of cat** - Better syntax highlighting
6. **Use eza instead of ls** - More colors and features

## 📖 Documentation

- Full setup guides: `setup/` directory
- Specific guides: `guides/` directory  
- Reference: `reference/` directory
- Main README: `README.md`

## 🆘 Getting Help

- Check `reference/troubleshooting.md`
- Review setup guides in `setup/` directory
- Check command help: `<command> --help`

---

**Happy coding!** 🚀

*Last updated: October 26, 2025*
