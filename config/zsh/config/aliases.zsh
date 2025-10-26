#!/bin/zsh
# =============================================================================
# ALIASES CONFIGURATION - Debian 13
# =============================================================================
# Organized aliases with categories and improved functionality for Debian
# =============================================================================

# =============================================================================
# SYSTEM ALIASES
# =============================================================================

# Enhanced ls commands
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -laht'  # Sort by modification time

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# =============================================================================
# NETWORK ALIASES
# =============================================================================

# IP address utilities
alias myip='curl -s ipinfo.io/ip'
alias myipx='curl -s ipinfo.io | jq'
alias myip4='curl -4 -s ipinfo.io/ip'
alias myip6='curl -6 -s ipinfo.io/ip'

# Network diagnostics
alias ping='ping -c 5'
alias fastping='ping -c 100 -i.2'

# =============================================================================
# DEVELOPMENT ALIASES
# =============================================================================

# File operations
alias files='find . -type f | wc -l'
alias dirs='find . -type d | wc -l'

# =============================================================================
# KUBERNETES ALIASES
# =============================================================================

# kubectl shortcuts
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kctx='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'

# kubectl with verbose logging
alias kgetc='kubectl -v=8 config get-contexts'
alias kpod='kubectl -v=8 get pods'

# =============================================================================
# SYSTEM UTILITIES
# =============================================================================

# System information
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='htop'  # If htop is installed

# =============================================================================
# LINUX SPECIFIC ALIASES
# =============================================================================

# System package management
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias autoremove='sudo apt autoremove'
alias clean='sudo apt clean && sudo apt autoclean'

# Systemd management
alias sc='systemctl'
alias scu='systemctl --user'
alias jc='journalctl'
alias jcu='journalctl --user'

# Show systemd user services status
alias svc-status='systemctl --user status'
alias svc-list='systemctl --user list-units'
alias svc-enable='systemctl --user enable'
alias svc-disable='systemctl --user disable'
alias svc-start='systemctl --user start'
alias svc-stop='systemctl --user stop'
alias svc-restart='systemctl --user restart'

# =============================================================================
# DOCKER ALIASES
# =============================================================================

alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# =============================================================================
# GIT ALIASES (Enhanced)
# =============================================================================

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gl='git log --oneline'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gst='git stash'
alias gstp='git stash pop'

# =============================================================================
# SAFETY ALIASES
# =============================================================================

# Make commands safer
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# =============================================================================
# UTILITY ALIASES
# =============================================================================

# Quick edits
alias zshconfig='$EDITOR ~/.zshrc'
alias zshreload='source ~/.zshrc'
alias ohmyzsh='$EDITOR ~/.oh-my-zsh'

# Weather (if curl is available)
alias weather='curl -s wttr.in'

# =============================================================================
# CONDITIONAL ALIASES
# =============================================================================

# Only set aliases if the commands exist
if command -v jq >/dev/null 2>&1; then
    alias json='jq .'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    unalias ll 2>/dev/null || true
    alias ll='eza -la'
    alias la='eza -a'
fi

# =============================================================================
# CLIPBOARD ALIASES (Linux)
# =============================================================================

# X11 clipboard (if xclip is installed)
if command -v xclip >/dev/null 2>&1; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

# Wayland clipboard (if wl-clipboard is installed)
if command -v wl-copy >/dev/null 2>&1; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
fi

# =============================================================================
# DISK USAGE ANALYZER
# =============================================================================

# Disk usage analyzer (wdu)
if [[ -f "$HOME/work/scripts/wdu.sh" ]]; then
    alias wdu="bash $HOME/work/scripts/wdu.sh"
fi
