# Git Configuration and SSH Key Setup

Complete guide for configuring Git and managing SSH keys on Debian.

## Table of Contents

1. [Basic Git Configuration](#basic-git-configuration)
2. [SSH Key Setup](#ssh-key-setup)
3. [Multiple SSH Keys (Work/Personal)](#multiple-ssh-keys-workpersonal)
4. [Git Aliases](#git-aliases)
5. [Global Gitignore](#global-gitignore)
6. [Git Editor Configuration](#git-editor-configuration)
7. [Credential Helper](#credential-helper)
8. [Commit Message Templates](#commit-message-templates)
9. [GitHub CLI Configuration](#github-cli-configuration)

---

## Basic Git Configuration

### Set Your Identity

```bash
# For personal use
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# For work use (in work repos)
cd ~/work/projects/work/your-repo
git config user.name "Your Work Name"
git config user.email "work@company.com"
```

### Other Useful Settings

```bash
# Default branch name
git config --global init.defaultBranch main

# Color output
git config --global color.ui auto

# Show original state in merge conflicts
git config --global merge.conflictstyle diff3

# Rebase on pull by default
git config --global pull.rebase true

# Prune deleted remote branches on fetch
git config --global fetch.prune true

# Use SSH instead of HTTPS for GitHub
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

---

## SSH Key Setup

### Generate New SSH Key

```bash
# Ed25519 (recommended)
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519

# Or RSA 4096 (for older systems)
ssh-keygen -t rsa -b 4096 -C "your.email@example.com" -f ~/.ssh/id_rsa
```

### Add SSH Key to SSH Agent

```bash
# Start ssh-agent
eval "$(ssh-agent -s)"

# Add your key
ssh-add ~/.ssh/id_ed25519
```

### Add SSH Key to GitHub

```bash
# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub

# Or use xclip if available
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
```

Then:
1. Go to GitHub → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Paste your public key
4. Click "Add SSH key"

### Test SSH Connection

```bash
# Test GitHub connection
ssh -T git@github.com

# Expected output:
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## Multiple SSH Keys (Work/Personal)

### Generate Separate Keys

```bash
# Personal key
ssh-keygen -t ed25519 -C "personal@email.com" -f ~/.ssh/id_ed25519_personal

# Work key
ssh-keygen -t ed25519 -C "work@company.com" -f ~/.ssh/id_ed25519_work
```

### Configure SSH Config

Create/edit `~/.ssh/config`:

```bash
# Personal GitHub
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Work GitHub
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# GitLab (if needed)
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
```

### Usage with Different Hosts

```bash
# Clone personal repo
git clone git@github.com-personal:username/repo.git

# Clone work repo
git clone git@github.com-work:company/repo.git

# Change existing repo's remote
cd existing-repo
git remote set-url origin git@github.com-work:company/repo.git
```

### Integration with Context Switching

Update `~/.zsh/config/context.zsh` to set SSH identity:

```bash
work() {
    echo "🏢 Switching to WORK context..."
    # ... existing code ...

    # Set SSH key for work
    ssh-add -D 2>/dev/null  # Clear all keys
    ssh-add ~/.ssh/id_ed25519_work 2>/dev/null

    echo "✅ Work context activated (SSH: work key)"
}

personal() {
    echo "🏠 Switching to PERSONAL context..."
    # ... existing code ...

    # Set SSH key for personal
    ssh-add -D 2>/dev/null  # Clear all keys
    ssh-add ~/.ssh/id_ed25519_personal 2>/dev/null

    echo "✅ Personal context activated (SSH: personal key)"
}
```

---

## Git Aliases

Add these to your `~/.gitconfig` or run as commands:

```bash
# Status shortcuts
git config --global alias.st status
git config --global alias.s "status -s"

# Branch shortcuts
git config --global alias.br branch
git config --global alias.co checkout
git config --global alias.cob "checkout -b"

# Commit shortcuts
git config --global alias.ci commit
git config --global alias.ca "commit --amend"
git config --global alias.can "commit --amend --no-edit"

# Log shortcuts
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.ll "log --oneline -10"

# Diff shortcuts
git config --global alias.df diff
git config --global alias.dc "diff --cached"

# Reset shortcuts
git config --global alias.unstage "reset HEAD --"
git config --global alias.undo "reset --soft HEAD^"

# Stash shortcuts
git config --global alias.sl "stash list"
git config --global alias.sp "stash pop"
git config --global alias.ss "stash save"

# Remote shortcuts
git config --global alias.pl pull
git config --global alias.ps push
git config --global alias.psf "push --force-with-lease"

# Show contributors
git config --global alias.contributors "shortlog -sn"

# Show all aliases
git config --global alias.aliases "config --get-regexp ^alias\."
```

### Usage

```bash
git st          # git status
git s           # git status -s
git lg          # pretty log
git cob feature # git checkout -b feature
git can         # git commit --amend --no-edit
```

---

## Global Gitignore

Create `~/.gitignore_global`:

```bash
# OS Files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Thumbs.db
Desktop.ini

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~
.project
.classpath
.settings/

# Environment files
.env
.env.local
.env.*.local
*.env

# Build outputs
node_modules/
dist/
build/
*.pyc
__pycache__/
.pytest_cache/
.coverage
.venv/
venv/
*.egg-info/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Temporary files
tmp/
temp/
*.tmp
```

Enable global gitignore:

```bash
git config --global core.excludesfile ~/.gitignore_global
```

---

## Git Editor Configuration

### Set Default Editor

```bash
# Use vim
git config --global core.editor vim

# Use nano
git config --global core.editor nano

# Use neovim
git config --global core.editor nvim

# Use VS Code (wait for editor to close)
git config --global core.editor "code --wait"
```

---

## Credential Helper

### Store Credentials

```bash
# Store credentials in memory for 1 hour (default)
git config --global credential.helper cache

# Store credentials in memory for 8 hours
git config --global credential.helper 'cache --timeout=28800'

# Store credentials in plaintext file (less secure)
git config --global credential.helper store
```

### Use GitHub CLI for Credentials

```bash
# GitHub CLI handles authentication automatically
gh auth login

# Set git to use gh for auth
gh auth setup-git
```

---

## Commit Message Templates

### Create Template

Create `~/.gitmessage`:

```text
# <type>: <subject> (max 50 chars)
# |<----  Using a Maximum Of 50 Characters  ---->|

# Explain why this change is being made
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|

# Provide links or keys to any relevant tickets, articles or other resources
# Example: Fixes #23

# --- COMMIT END ---
# Type can be:
#    feat     (new feature)
#    fix      (bug fix)
#    refactor (refactoring code)
#    style    (formatting, missing semicolons, etc)
#    doc      (changes to documentation)
#    test     (adding or refactoring tests)
#    chore    (updating build tasks, package manager configs, etc)
# --------------------
# Remember to:
#    Capitalize the subject line
#    Use the imperative mood in the subject line
#    Do not end the subject line with a period
#    Separate subject from body with a blank line
#    Use the body to explain what and why vs. how
#    Can use multiple lines with "-" for bullet points in body
# --------------------
```

### Enable Template

```bash
git config --global commit.template ~/.gitmessage
```

---

## GitHub CLI Configuration

### Install (Already Done in Bootstrap)

```bash
gh --version
```

### Authentication

```bash
# Login to GitHub
gh auth login

# Follow prompts:
# - Choose GitHub.com
# - Choose SSH
# - Upload your public key
# - Authenticate via browser
```

### Useful Commands

```bash
# View status
gh auth status

# Create repo
gh repo create my-repo --public

# Clone repo
gh repo clone username/repo

# Create PR
gh pr create --title "Feature" --body "Description"

# View PRs
gh pr list

# View issues
gh issue list

# Create issue
gh issue create --title "Bug" --body "Description"

# Fork repo
gh repo fork

# View repo in browser
gh repo view --web
```

### Aliases

Add to `~/.zsh/config/aliases.zsh`:

```bash
# GitHub CLI shortcuts
alias ghpr='gh pr create'
alias ghprl='gh pr list'
alias ghprv='gh pr view'
alias ghis='gh issue list'
alias ghisc='gh issue create'
alias ghrepo='gh repo view --web'
```

---

## Verify Configuration

### View All Settings

```bash
# View all git config
git config --list

# View global config
git config --global --list

# View specific setting
git config --global user.name
git config --global user.email
```

### Test Everything

```bash
# Test SSH
ssh -T git@github.com

# Test GitHub CLI
gh auth status

# View git aliases
git aliases

# Test context switching
personal
show-context
work
show-context
```

---

## Quick Setup Script

Create `~/work/scripts/git-setup.sh`:

```bash
#!/bin/bash
# Quick Git Configuration Script

echo "🔧 Git Configuration Setup"
echo ""

# Basic config
read -p "Enter your name: " git_name
read -p "Enter your email: " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global color.ui auto
git config --global pull.rebase true
git config --global fetch.prune true

echo "✅ Basic configuration complete"

# SSH key
read -p "Generate SSH key? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    echo ""
    echo "📋 Your public key:"
    cat ~/.ssh/id_ed25519.pub
    echo ""
    echo "✅ Copy this key and add it to GitHub"
fi

echo ""
echo "✅ Git setup complete!"
```

Make it executable:

```bash
chmod +x ~/work/scripts/git-setup.sh
```

---

**Last Updated**: October 26, 2025
