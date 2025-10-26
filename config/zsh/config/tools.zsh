#!/bin/zsh
# =============================================================================
# TOOL-SPECIFIC CONFIGURATIONS
# =============================================================================
# Lazy-loaded configurations for various development tools
# =============================================================================

# =============================================================================
# DOCKER CONFIGURATION
# =============================================================================

# Docker configuration (lazy loaded)
docker() {
    unfunction docker
    
    # Load Docker configuration
    export PATH="$PATH:$HOME/.docker/bin"
    export DOCKER_CONFIG="$HOME/.docker"
    
    # Docker CLI completions
    if [[ -d "$HOME/.docker/completions" ]]; then
        fpath=("$HOME/.docker/completions" $fpath)
        autoload -Uz compinit
        compinit
    fi
    
    # Call docker command
    command docker "$@"
}

# =============================================================================
# PYENV CONFIGURATION
# =============================================================================

# Pyenv is initialized in .zshrc - no lazy loading needed
# The shell integration requires proper initialization at startup

# =============================================================================
# CONDA CONFIGURATION
# =============================================================================

# Conda configuration (lazy loaded)
conda() {
    unfunction conda
    
    local conda_path="$HOME/opt/miniconda3/bin/conda"
    if [[ -f "$conda_path" ]]; then
        __conda_setup="$('$conda_path' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "$HOME/opt/miniconda3/etc/profile.d/conda.sh" ]; then
                . "$HOME/opt/miniconda3/etc/profile.d/conda.sh"
            else
                export PATH="$HOME/opt/miniconda3/bin:$PATH"
            fi
        fi
        unset __conda_setup
    fi
    
    # Call conda command
    command conda "$@"
}

# =============================================================================
# SDKMAN CONFIGURATION
# =============================================================================

# SDKMAN configuration (lazy loaded)
sdk() {
    unfunction sdk
    
    export SDKMAN_DIR="$HOME/.sdkman"
    if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
        export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"
    fi
    
    # Call sdk command
    command sdk "$@"
}

# =============================================================================
# NVM CONFIGURATION (if needed)
# =============================================================================

# NVM configuration (lazy loaded, only if volta is not available)
if ! command -v volta >/dev/null 2>&1; then
    nvm() {
        unfunction nvm
        
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            \. "$NVM_DIR/nvm.sh"
        fi
        if [[ -s "$NVM_DIR/bash_completion" ]]; then
            \. "$NVM_DIR/bash_completion"
        fi
        
        # Call nvm command
        command nvm "$@"
    }
fi

# =============================================================================
# KUBECTL CONFIGURATION
# =============================================================================

# Kubectl configuration
if command -v kubectl >/dev/null 2>&1; then
    # Enable kubectl autocompletion
    source <(kubectl completion zsh)
    
    # Set default kubectl options
    export KUBECTL_EXTERNAL_DIFF="colordiff -N -u"
fi

# =============================================================================
# TERRAFORM CONFIGURATION
# =============================================================================

# Terraform configuration
if command -v terraform >/dev/null 2>&1; then
    # Enable terraform autocompletion
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C terraform terraform
fi

# =============================================================================
# AWS CLI CONFIGURATION
# =============================================================================

# AWS CLI configuration
if command -v aws >/dev/null 2>&1; then
    # Enable AWS CLI autocompletion
    complete -C aws_completer aws
fi

# =============================================================================
# GIT CONFIGURATION
# =============================================================================

# Git configuration
if command -v git >/dev/null 2>&1; then
    # Set default git editor
    export GIT_EDITOR="$EDITOR"
    
    # Useful git configurations
    git config --global init.defaultBranch main 2>/dev/null
    git config --global pull.rebase false 2>/dev/null
    git config --global core.autocrlf input 2>/dev/null
fi

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

# Load development tool configurations if they exist
load_dev_tool() {
    local tool_name="$1"
    local config_file="$ZSH_CONFIG_DIR/config/${tool_name}.zsh"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

# Load specific tool configurations
load_dev_tool "gcloud"
load_dev_tool "heroku"
load_dev_tool "docker-compose"
load_dev_tool "python"

# =============================================================================
# ENVIRONMENT DETECTION
# =============================================================================

# Detect if we're in a specific development environment
detect_dev_environment() {
    # Check for common development indicators
    if [[ -f "package.json" ]]; then
        export DEV_ENV="node"
    elif [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
        export DEV_ENV="python"
    elif [[ -f "composer.json" ]]; then
        export DEV_ENV="php"
    elif [[ -f "Cargo.toml" ]]; then
        export DEV_ENV="rust"
    elif [[ -f "go.mod" ]]; then
        export DEV_ENV="go"
    elif [[ -f "Dockerfile" ]]; then
        export DEV_ENV="docker"
    fi
}

# Auto-detect development environment
detect_dev_environment

# =============================================================================
# TOOL-SPECIFIC ALIASES
# =============================================================================

# Docker aliases (only if docker is available)
if command -v docker >/dev/null 2>&1; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias drm='docker rm'
    alias drmi='docker rmi'
    alias dstop='docker stop'
    alias dstart='docker start'
    alias drestart='docker restart'
fi

# Kubernetes aliases (only if kubectl is available)
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgd='kubectl get deployments'
    alias kgn='kubectl get nodes'
    alias kctx='kubectl config current-context'
    alias kns='kubectl config set-context --current --namespace'
fi
