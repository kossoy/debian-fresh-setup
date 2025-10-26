# Node.js & JavaScript Development Environment - Debian 13

Complete Node.js setup with Volta for version management and essential packages for modern JavaScript/TypeScript development.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Build essentials installed
- Git installed
- curl installed

## 1. Volta (Node.js Version Manager)

Volta is the recommended version manager - it's fast, reliable, and automatically switches Node versions per project.

```bash
# Install Volta
curl https://get.volta.sh | bash

# Reload shell to activate Volta
source ~/.zshrc

# Verify installation
volta --version
```

### Why Volta over NVM?

- Fast (written in Rust)
- Automatic version switching based on package.json
- No shell hooks needed
- Cross-platform (macOS, Linux, Windows)

## 2. Install Node.js

```bash
# Install latest LTS version
volta install node@lts

# Install latest stable version
volta install node@latest

# Verify installation
node --version
npm --version
```

### Install Specific Versions

```bash
# Install specific version
volta install node@18

# List installed versions
volta list node
```

## 3. Essential Global Packages

### Check What's Installed

```bash
# List active tools
volta list

# Example output if only Node.js is installed:
# ⚡️ Currently active tools:
#     Node: v22.21.0 (default)
#     Tool binaries available: NONE

# List all installed tools
volta list all

# List only Node versions
volta list node
```

**"Tool binaries available: NONE"** means you haven't installed any global tools yet (yarn, pnpm, typescript, etc.). This is normal after minimal installation.

### Install Global Tools

```bash
# Package managers
volta install yarn pnpm

# TypeScript
volta install typescript ts-node

# Development tools
volta install nodemon eslint prettier

# Build tools
volta install webpack webpack-cli vite

# All at once
volta install yarn pnpm typescript ts-node nodemon eslint prettier webpack webpack-cli vite
```

### Re-run Setup Script

If you used the automated script with minimal mode, you can re-run it:

```bash
cd ~/debian-fresh-setup
./setup-helpers/06-install-nodejs.sh
# Choose option 2 (Standard) or 3 (Full)
```

## 4. Project-Specific Version Management

```bash
# Pin Node version for project
volta pin node@18.17.0
volta pin npm@9.6.7
```

## 5. Common Commands

```bash
# Check versions
node --version
npm --version

# Update packages
npm update
npm outdated

# Security audit
npm audit
npm audit fix
```

## 6. IDEs

### WebStorm

```bash
# Install via Snap
sudo snap install webstorm --classic
```

### VS Code

```bash
# Install VS Code
sudo apt install -y software-properties-common apt-transport-https wget
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code
```

## 7. Troubleshooting

### File Watcher Limit (Linux)

```bash
# Increase file watcher limit
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Port Already in Use

```bash
# Find process using port
sudo ss -tulpn | grep :3000

# Kill process
kill -9 <PID>
```

## Next Steps

Continue with:
- **[Docker Setup](04-docker-setup.md)** - Containerization
- **[Python Environment](02-python-environment.md)** - Python development

---

**Last Updated**: October 26, 2025
