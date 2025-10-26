#!/bin/zsh
# =============================================================================
# PATH MANAGEMENT CONFIGURATION - Debian 13
# =============================================================================
# Centralized PATH management with deduplication and logical ordering
# =============================================================================

# Function to add path only if it exists and isn't already in PATH
add_to_path() {
    local path_to_add="$1"
    if [[ -d "$path_to_add" && ":$PATH:" != *":$path_to_add:"* ]]; then
        export PATH="$path_to_add:$PATH"
    fi
}

# Function to add path to end of PATH
append_to_path() {
    local path_to_add="$1"
    if [[ -d "$path_to_add" && ":$PATH:" != *":$path_to_add:"* ]]; then
        export PATH="$PATH:$path_to_add"
    fi
}

# =============================================================================
# SYSTEM PATHS
# =============================================================================

# User local bin (highest priority)
add_to_path "$HOME/.local/bin"

# User bin
if [[ -d "$HOME/bin" ]]; then
    add_to_path "$HOME/bin"
fi

# Standard system paths
add_to_path "/usr/local/bin"
add_to_path "/usr/local/sbin"

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

# Node.js version managers (prioritize volta over nvm)
if [[ -d "$HOME/.volta" ]]; then
    export VOLTA_HOME="$HOME/.volta"
    add_to_path "$VOLTA_HOME/bin"
fi

# NVM (Node Version Manager)
if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    # Load nvm if it exists (lazy loading for performance)
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
fi

# pnpm
if [[ -d "$HOME/.local/share/pnpm" ]]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    add_to_path "$PNPM_HOME"
fi

# Deno
if [[ -d "$HOME/.deno" ]]; then
    export DENO_INSTALL="$HOME/.deno"
    add_to_path "$DENO_INSTALL/bin"
fi

# Bun
if [[ -d "$HOME/.bun" ]]; then
    export BUN_INSTALL="$HOME/.bun"
    add_to_path "$BUN_INSTALL/bin"
fi

# Python tools
add_to_path "$HOME/.local/bin"

# Rust/Cargo
if [[ -d "$HOME/.cargo" ]]; then
    add_to_path "$HOME/.cargo/bin"
fi

# Go
if [[ -d "/usr/local/go/bin" ]]; then
    add_to_path "/usr/local/go/bin"
fi
if [[ -d "$HOME/go/bin" ]]; then
    add_to_path "$HOME/go/bin"
fi

# =============================================================================
# CUSTOM BINARIES
# =============================================================================

# Custom work binaries
add_to_path "$HOME/work/bin"
add_to_path "$HOME/work/scripts"

# Local node_modules binaries (for current project)
append_to_path "./node_modules/.bin"

# =============================================================================
# JAVA/JVM TOOLS
# =============================================================================

# SDKMAN
if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    # Load sdkman (lazy loading for performance)
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# Maven
if [[ -d "$HOME/.m2" ]]; then
    export M2_HOME="$HOME/.m2"
fi

# =============================================================================
# KUBERNETES TOOLS
# =============================================================================

# Krew plugin manager
if [[ -d "${KREW_ROOT:-$HOME/.krew}/bin" ]]; then
    add_to_path "${KREW_ROOT:-$HOME/.krew}/bin"
fi

# =============================================================================
# AI/ML TOOLS
# =============================================================================

# LM Studio (if installed in user space)
if [[ -d "$HOME/.lmstudio/bin" ]]; then
    add_to_path "$HOME/.lmstudio/bin"
fi

# =============================================================================
# DEVELOPMENT ENVIRONMENT VARIABLES
# =============================================================================

# Set default editor
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="vim"
    export VISUAL="vim"
else
    export EDITOR="nano"
    export VISUAL="nano"
fi

# Git editor
export GIT_EDITOR="$EDITOR"

# =============================================================================
# WORK DIRECTORY STRUCTURE
# =============================================================================

# Development paths
export WORK_ROOT="$HOME/work"
export PROJECTS_ROOT="$WORK_ROOT/projects"
export CONFIGS_ROOT="$WORK_ROOT/configs"
export SCRIPTS_ROOT="$WORK_ROOT/scripts"
export TOOLS_ROOT="$WORK_ROOT/tools"
export DOCS_ROOT="$WORK_ROOT/docs"

# =============================================================================
# PATH VERIFICATION
# =============================================================================

# Remove duplicate paths
if command -v typeset >/dev/null 2>&1; then
    typeset -U PATH
fi

# Debug PATH if ZSH_DEBUG is set
if [[ "${ZSH_DEBUG:-false}" == "true" ]]; then
    echo "Final PATH:" >&2
    echo "$PATH" | tr ':' '\n' | nl >&2
fi
