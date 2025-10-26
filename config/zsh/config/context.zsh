#!/bin/zsh
# =============================================================================
# CONTEXT SWITCHING - Debian
# =============================================================================
# Switch between work and personal development environments
# =============================================================================

# Context configuration directory
CONTEXT_DIR="$HOME/.zsh/private"
CONTEXT_FILE="$CONTEXT_DIR/current.zsh"

# =============================================================================
# CONTEXT SWITCHING FUNCTIONS
# =============================================================================

# Switch to work context
work() {
    echo "🏢 Switching to WORK context..."
    
    # Create context file
    cat > "$CONTEXT_FILE" << 'WORKEOF'
# Work Context Configuration
export WORK_CONTEXT="work"
export GIT_AUTHOR_NAME="Your Work Name"
export GIT_AUTHOR_EMAIL="work@company.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# Work-specific paths
export WORK_PROJECTS="$HOME/work/projects/work"
cd "$WORK_PROJECTS" 2>/dev/null || cd "$HOME/work"
WORKEOF
    
    # Reload configuration
    source "$CONTEXT_FILE"
    
    echo "✅ Work context activated"
    echo "   📧 Email: $GIT_AUTHOR_EMAIL"
    echo "   📁 Projects: $WORK_PROJECTS"
}

# Switch to personal context
personal() {
    echo "🏠 Switching to PERSONAL context..."
    
    # Create context file
    cat > "$CONTEXT_FILE" << 'PERSONALEOF'
# Personal Context Configuration
export WORK_CONTEXT="personal"
export GIT_AUTHOR_NAME="Your Personal Name"
export GIT_AUTHOR_EMAIL="personal@email.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# Personal-specific paths
export WORK_PROJECTS="$HOME/work/projects/personal"
cd "$WORK_PROJECTS" 2>/dev/null || cd "$HOME/work"
PERSONALEOF
    
    # Reload configuration
    source "$CONTEXT_FILE"
    
    echo "✅ Personal context activated"
    echo "   📧 Email: $GIT_AUTHOR_EMAIL"
    echo "   📁 Projects: $WORK_PROJECTS"
}

# Show current context
show-context() {
    if [[ -f "$CONTEXT_FILE" ]]; then
        source "$CONTEXT_FILE"
        echo "📋 Current Context: ${WORK_CONTEXT:-not set}"
        echo "   👤 Name: ${GIT_AUTHOR_NAME:-not set}"
        echo "   📧 Email: ${GIT_AUTHOR_EMAIL:-not set}"
        echo "   📁 Projects: ${WORK_PROJECTS:-not set}"
    else
        echo "⚠️  No context set. Run 'work' or 'personal' to set context."
    fi
}

# =============================================================================
# AUTO-LOAD CONTEXT ON SHELL START
# =============================================================================

# Load context if it exists
if [[ -f "$CONTEXT_FILE" ]]; then
    source "$CONTEXT_FILE" 2>/dev/null
fi
