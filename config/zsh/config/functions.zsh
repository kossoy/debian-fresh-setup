#!/bin/zsh
# =============================================================================
# CUSTOM FUNCTIONS - Debian 13
# =============================================================================
# Enhanced functions with better error handling and Linux-specific features
# =============================================================================

# =============================================================================
# DIRECTORY UTILITIES
# =============================================================================

# Create directory and navigate to it
mkcd() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: mkcd <directory>" >&2
        return 1
    fi

    local dir="$1"
    if mkdir -p -- "$dir" 2>/dev/null; then
        cd -P -- "$dir" || {
            echo "Error: Failed to change to directory '$dir'" >&2
            return 1
        }
    else
        echo "Error: Failed to create directory '$dir'" >&2
        return 1
    fi
}

# =============================================================================
# PROCESS UTILITIES
# =============================================================================

# Find processes by name (improved version)
psme() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: psme <process_name>" >&2
        return 1
    fi

    local pattern="$1"
    ps aux | command grep -i "$pattern" | command grep -v grep
}

# Get process IDs by name
psmes() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: psmes <process_name>" >&2
        return 1
    fi

    local pattern="$1"
    ps aux | command grep -i "$pattern" | command grep -v grep | awk '{print $2}'
}

# Kill processes by name with signal
slay() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: slay <process_name> [signal]" >&2
        echo "Signals: -9 (SIGKILL), -15 (SIGTERM, default)" >&2
        return 1
    fi

    local pattern="$1"
    local signal="${2:--15}"
    local pids

    pids=$(psmes "$pattern")

    if [[ -z "$pids" ]]; then
        echo "No processes found matching '$pattern'" >&2
        return 1
    fi

    echo "Killing processes: $pids" >&2
    echo "$pids" | xargs kill "$signal"
}

# =============================================================================
# KUBERNETES UTILITIES
# =============================================================================

# Get full pod name (improved with error handling)
get_full_pod_name() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: get_full_pod_name <pod_pattern>" >&2
        return 1
    fi

    local pattern="$1"
    local pod_name

    pod_name=$(kubectl get pods --no-headers 2>/dev/null | command grep "$pattern" | head -n1 | awk '{print $1}')

    if [[ -z "$pod_name" ]]; then
        echo "Error: No pod found matching '$pattern'" >&2
        return 1
    fi

    echo "$pod_name"
}

# Connect to pod (improved version)
pod_connect() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: pod_connect <pod_pattern>" >&2
        return 1
    fi

    local pattern="$1"
    local pod_name
    local green=$(tput setaf 2 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)

    pod_name=$(get_full_pod_name "$pattern")

    if [[ $? -eq 0 ]]; then
        echo "Connecting to: ${green}${pod_name}${reset}" >&2
        kubectl exec -it "$pod_name" -- sh
    else
        return 1
    fi
}

# Get pod logs (improved version)
klogs() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: klogs <pod_pattern> [options]" >&2
        return 1
    fi

    local pattern="$1"
    shift
    local pod_name
    local green=$(tput setaf 2 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)

    pod_name=$(get_full_pod_name "$pattern")

    if [[ $? -eq 0 ]]; then
        echo "Getting logs for: ${green}${pod_name}${reset}" >&2
        kubectl logs "$pod_name" --all-containers=true "$@"
    else
        return 1
    fi
}

# Set Kubernetes context to datascience namespace
dscontext() {
    local current_context
    current_context=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)

    if [[ -z "$current_context" ]]; then
        echo "Error: Could not get current Kubernetes context" >&2
        return 1
    fi

    kubectl config set-context "$current_context" --namespace=datascience
    echo "Set namespace to 'datascience' for context: $current_context" >&2
}

# =============================================================================
# NETWORK UTILITIES
# =============================================================================

# List listening ports (Linux version using ss)
listening() {
    local pattern=""

    if [[ $# -gt 0 ]]; then
        pattern="$1"
    fi

    if [[ -n "$pattern" ]]; then
        sudo ss -tulpn | command grep -i --color "$pattern"
    else
        sudo ss -tulpn
    fi
}

# =============================================================================
# SYSTEM UTILITIES - LINUX SPECIFIC
# =============================================================================

# Show systemd service status
svc_status() {
    if [[ $# -eq 0 ]]; then
        systemctl --user list-units --type=service
    else
        systemctl --user status "$1"
    fi
}

# Reload systemd user daemon
svc_reload() {
    systemctl --user daemon-reload
    echo "Systemd user daemon reloaded" >&2
}

# Show service logs
svc_logs() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: svc_logs <service_name> [options]" >&2
        return 1
    fi

    journalctl --user -u "$1" "${@:2}"
}

# =============================================================================
# DEVELOPMENT UTILITIES
# =============================================================================

# Quick project setup
project_setup() {
    local project_name="$1"

    if [[ -z "$project_name" ]]; then
        echo "Usage: project_setup <project_name>" >&2
        return 1
    fi

    mkcd "$project_name"

    # Initialize git if not already a repo
    if [[ ! -d ".git" ]]; then
        git init
        echo "Initialized git repository" >&2
    fi

    # Create basic project structure
    mkdir -p {src,tests,docs,scripts}
    touch README.md .gitignore

    echo "Project '$project_name' setup complete" >&2
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Extract various archive formats
extract() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: extract <archive>" >&2
        return 1
    fi

    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found" >&2
        return 1
    fi

    case "$file" in
        *.tar.bz2)   tar xjf "$file"     ;;
        *.tar.gz)    tar xzf "$file"     ;;
        *.bz2)       bunzip2 "$file"     ;;
        *.rar)       unrar e "$file"     ;;
        *.gz)        gunzip "$file"      ;;
        *.tar)       tar xf "$file"      ;;
        *.tbz2)      tar xjf "$file"     ;;
        *.tgz)       tar xzf "$file"     ;;
        *.zip)       unzip "$file"       ;;
        *.Z)         uncompress "$file"  ;;
        *.7z)        7z x "$file"        ;;
        *)           echo "Error: '$file' cannot be extracted" >&2 ;;
    esac
}

# Create a backup of a file
backup() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: backup <file>" >&2
        return 1
    fi

    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found" >&2
        return 1
    fi

    cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backup created: ${file}.backup.$(date +%Y%m%d_%H%M%S)" >&2
}

# =============================================================================
# DEBUGGING UTILITIES
# =============================================================================

# Show function definitions
show_function() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: show_function <function_name>" >&2
        return 1
    fi

    local func_name="$1"
    if declare -f "$func_name" >/dev/null 2>&1; then
        declare -f "$func_name"
    else
        echo "Function '$func_name' not found" >&2
        return 1
    fi
}

# List all custom functions
list_functions() {
    echo "Custom functions:" >&2
    declare -f | command grep '^[a-zA-Z_][a-zA-Z0-9_]* ()' | sed 's/ ()//' | sort
}
