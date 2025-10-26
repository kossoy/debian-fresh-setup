# Context Switching Guide

Complete guide for managing work and personal development contexts on Debian.

## Table of Contents

1. [What is Context Switching?](#what-is-context-switching)
2. [Built-in Context Functions](#built-in-context-functions)
3. [How It Works](#how-it-works)
4. [Setup and Configuration](#setup-and-configuration)
5. [Git Integration](#git-integration)
6. [SSH Key Integration](#ssh-key-integration)
7. [Project Organization](#project-organization)
8. [Advanced Usage](#advanced-usage)
9. [Tips and Best Practices](#tips-and-best-practices)

---

## What is Context Switching?

Context switching allows you to seamlessly switch between work and personal development environments, automatically configuring:

- Git credentials (name and email)
- SSH keys
- Default project directories
- Environment variables
- Custom configurations per context

This prevents accidentally committing with the wrong email or using the wrong SSH key.

---

## Built-in Context Functions

After running the bootstrap script, you have access to these commands:

### `work`
Switches to work context:
- Sets work Git credentials
- Loads work SSH key
- Changes to work projects directory
- Sets WORK_CONTEXT environment variable

### `personal`
Switches to personal context:
- Sets personal Git credentials
- Loads personal SSH key
- Changes to personal projects directory
- Sets WORK_CONTEXT environment variable

### `show-context`
Displays current context:
- Shows active context (work/personal)
- Shows current Git name and email
- Shows current working directory

---

## How It Works

### Context Storage

Context configuration is stored in `~/.zsh/private/current.zsh`:

```bash
# Created when you run 'work' or 'personal'
export WORK_CONTEXT="work"
export GIT_AUTHOR_NAME="Your Work Name"
export GIT_AUTHOR_EMAIL="work@company.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export WORK_PROJECTS="$HOME/work/projects/work"
```

This file is sourced automatically when you open a new shell.

### Context Loading

In your `~/.zshrc`, the context is loaded on startup:

```bash
# Load current context if it exists
if [[ -f "$HOME/.zsh/private/current.zsh" ]]; then
    source "$HOME/.zsh/private/current.zsh"
fi
```

---

## Setup and Configuration

### 1. Initial Setup

The bootstrap script already created the necessary directory structure:

```bash
~/.zsh/
├── config/
│   ├── aliases.zsh
│   ├── functions.zsh
│   ├── paths.zsh
│   ├── tools.zsh
│   └── context.zsh      # Context switching functions
└── private/
    ├── current.zsh      # Current active context (auto-generated)
    └── api-keys.zsh     # API keys (create manually)
```

### 2. Customize Context Settings

Edit `~/.zsh/config/context.zsh` to customize your contexts:

```bash
vim ~/.zsh/config/context.zsh
```

Update these sections:

**Work Context:**
```bash
work() {
    echo "🏢 Switching to WORK context..."
    cat > "$CONTEXT_FILE" << 'WORKEOF'
export WORK_CONTEXT="work"
export GIT_AUTHOR_NAME="John Doe"              # Your work name
export GIT_AUTHOR_EMAIL="john.doe@company.com" # Your work email
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export WORK_PROJECTS="$HOME/work/projects/work"
cd "$WORK_PROJECTS" 2>/dev/null || cd "$HOME/work"
WORKEOF

    source "$CONTEXT_FILE"

    # Load work SSH key if exists
    if [[ -f "$HOME/.ssh/id_ed25519_work" ]]; then
        ssh-add -D 2>/dev/null
        ssh-add "$HOME/.ssh/id_ed25519_work" 2>/dev/null
    fi

    echo "✅ Work context activated"
}
```

**Personal Context:**
```bash
personal() {
    echo "🏠 Switching to PERSONAL context..."
    cat > "$CONTEXT_FILE" << 'PERSONALEOF'
export WORK_CONTEXT="personal"
export GIT_AUTHOR_NAME="John Doe"               # Your personal name
export GIT_AUTHOR_EMAIL="john@example.com"      # Your personal email
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export PERSONAL_PROJECTS="$HOME/work/projects/personal"
cd "$PERSONAL_PROJECTS" 2>/dev/null || cd "$HOME/work"
PERSONALEOF

    source "$CONTEXT_FILE"

    # Load personal SSH key if exists
    if [[ -f "$HOME/.ssh/id_ed25519_personal" ]]; then
        ssh-add -D 2>/dev/null
        ssh-add "$HOME/.ssh/id_ed25519_personal" 2>/dev/null
    fi

    echo "✅ Personal context activated"
}
```

### 3. Set Default Context

Add to your `~/.zshrc` (after sourcing Oh My Zsh):

```bash
# Set default context on shell startup
if [[ ! -f "$HOME/.zsh/private/current.zsh" ]]; then
    # Default to personal context
    personal > /dev/null
fi
```

---

## Git Integration

### How Git Credentials Work

When you switch contexts, Git environment variables are set:

- `GIT_AUTHOR_NAME` - Name used for commits
- `GIT_AUTHOR_EMAIL` - Email used for commits
- `GIT_COMMITTER_NAME` - Name used for committing
- `GIT_COMMITTER_EMAIL` - Email used for committing

These override global git config, so you don't need to manually change git settings.

### Verify Git Configuration

```bash
# Switch to work context
work

# Check what Git will use
git config user.name    # Should show work name
git config user.email   # Should show work email

# Make a test commit
echo "test" > test.txt
git add test.txt
git commit -m "Test commit"
git log -1              # Verify author and committer
```

### Per-Repository Configuration

If you want to lock a repository to a specific context:

```bash
# In a work repository
cd ~/work/projects/work/company-repo
git config user.name "Work Name"
git config user.email "work@company.com"

# In a personal repository
cd ~/work/projects/personal/my-project
git config user.name "Personal Name"
git config user.email "personal@example.com"
```

Repository-level config takes precedence over environment variables.

---

## SSH Key Integration

### Multiple SSH Keys

Generate separate SSH keys for work and personal:

```bash
# Generate work key
ssh-keygen -t ed25519 -C "work@company.com" -f ~/.ssh/id_ed25519_work

# Generate personal key
ssh-keygen -t ed25519 -C "personal@example.com" -f ~/.ssh/id_ed25519_personal
```

### SSH Config

Create `~/.ssh/config`:

```bash
# Work GitHub
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# Personal GitHub
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
```

### Automatic SSH Key Loading

The context functions automatically load the appropriate SSH key:

```bash
# When you run 'work'
work
# → Clears all SSH keys
# → Loads ~/.ssh/id_ed25519_work

# When you run 'personal'
personal
# → Clears all SSH keys
# → Loads ~/.ssh/id_ed25519_personal
```

### Clone with Correct Key

```bash
# Work projects - use work host
git clone git@github.com-work:company/repo.git

# Personal projects - use personal host
git clone git@github.com-personal:username/repo.git
```

### Change Remote for Existing Repos

```bash
# Change work repo to use work key
cd ~/work/projects/work/company-repo
git remote set-url origin git@github.com-work:company/repo.git

# Change personal repo to use personal key
cd ~/work/projects/personal/my-project
git remote set-url origin git@github.com-personal:username/repo.git
```

---

## Project Organization

### Directory Structure

The bootstrap creates this structure:

```bash
~/work/
├── projects/
│   ├── work/           # Work projects
│   │   ├── company-app/
│   │   └── internal-tool/
│   └── personal/       # Personal projects
│       ├── my-blog/
│       └── side-project/
├── configs/
│   ├── work/          # Work-specific configs
│   └── personal/      # Personal configs
├── databases/         # Development databases
├── tools/            # Development tools
├── scripts/          # Utility scripts
├── docs/             # Documentation
└── bin/              # Custom binaries
```

### Automatic Directory Navigation

Context switching automatically changes to the appropriate directory:

```bash
# Switch to work - goes to ~/work/projects/work
work
pwd  # /home/username/work/projects/work

# Switch to personal - goes to ~/work/projects/personal
personal
pwd  # /home/username/work/projects/personal
```

---

## Advanced Usage

### Add Custom Environment Variables

Edit `~/.zsh/config/context.zsh` to add more variables:

**Work Context:**
```bash
export WORK_CONTEXT="work"
export GIT_AUTHOR_NAME="Work Name"
export GIT_AUTHOR_EMAIL="work@company.com"

# Custom work variables
export AWS_PROFILE="company-dev"
export DATABASE_URL="postgresql://localhost:5432/company_dev"
export API_BASE_URL="https://api-dev.company.com"
export NODE_ENV="development"
```

**Personal Context:**
```bash
export WORK_CONTEXT="personal"
export GIT_AUTHOR_NAME="Personal Name"
export GIT_AUTHOR_EMAIL="personal@example.com"

# Custom personal variables
export AWS_PROFILE="personal"
export DATABASE_URL="postgresql://localhost:5432/personal_dev"
export API_BASE_URL="http://localhost:3000"
export NODE_ENV="development"
```

### Create Additional Contexts

Add more context functions in `~/.zsh/config/context.zsh`:

```bash
# Client context for freelance work
client() {
    echo "💼 Switching to CLIENT context..."
    cat > "$CONTEXT_FILE" << 'CLIENTEOF'
export WORK_CONTEXT="client"
export GIT_AUTHOR_NAME="Freelance Name"
export GIT_AUTHOR_EMAIL="freelance@example.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export CLIENT_PROJECTS="$HOME/work/projects/client"
cd "$CLIENT_PROJECTS" 2>/dev/null || cd "$HOME/work"
CLIENTEOF

    source "$CONTEXT_FILE"

    if [[ -f "$HOME/.ssh/id_ed25519_client" ]]; then
        ssh-add -D 2>/dev/null
        ssh-add "$HOME/.ssh/id_ed25519_client" 2>/dev/null
    fi

    echo "✅ Client context activated"
}
```

### Context-Aware Prompts

If using Powerlevel10k, you can show context in your prompt.

Edit `~/.p10k.zsh` and find the `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS` array:

```bash
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    background_jobs
    context  # Add this line
    # ... other elements
)
```

Then add this to `~/.zsh/config/context.zsh`:

```bash
# Add context indicator to prompt
prompt_context() {
    if [[ -n "$WORK_CONTEXT" ]]; then
        case "$WORK_CONTEXT" in
            work)
                echo -n "%F{blue}🏢 WORK%f"
                ;;
            personal)
                echo -n "%F{green}🏠 PERSONAL%f"
                ;;
            *)
                echo -n "%F{yellow}$WORK_CONTEXT%f"
                ;;
        esac
    fi
}
```

---

## Tips and Best Practices

### 1. Always Check Context

Before making commits, verify your context:

```bash
show-context
```

### 2. Use Context-Specific Aliases

Add to `~/.zsh/config/aliases.zsh`:

```bash
# Show context before common git operations
alias gc='show-context && git commit'
alias gp='show-context && git push'
```

### 3. Automatic Context Detection

Add to `~/.zsh/config/context.zsh`:

```bash
# Auto-detect context based on directory
auto_context() {
    local current_dir="$PWD"

    if [[ "$current_dir" == */work/projects/work* ]]; then
        if [[ "$WORK_CONTEXT" != "work" ]]; then
            work > /dev/null
        fi
    elif [[ "$current_dir" == */work/projects/personal* ]]; then
        if [[ "$WORK_CONTEXT" != "personal" ]]; then
            personal > /dev/null
        fi
    fi
}

# Run on directory change
chpwd_functions+=(auto_context)
```

### 4. Context Verification Script

Create `~/work/scripts/verify-context.sh`:

```bash
#!/bin/bash
# Verify git commits are using correct context

echo "🔍 Verifying Git Context"
echo "======================="
echo ""

# Show current context
if [[ -n "$WORK_CONTEXT" ]]; then
    echo "Current context: $WORK_CONTEXT"
else
    echo "⚠️  No context set!"
fi

echo ""

# Show what Git will use
echo "Git will commit as:"
echo "  Name:  $(git config user.name || echo 'NOT SET')"
echo "  Email: $(git config user.email || echo 'NOT SET')"

echo ""

# Show loaded SSH keys
echo "Loaded SSH keys:"
ssh-add -l 2>/dev/null || echo "  No keys loaded"

echo ""

# Show repository remote
if git remote -v >/dev/null 2>&1; then
    echo "Repository remote:"
    git remote -v | head -2
fi
```

Make it executable:

```bash
chmod +x ~/work/scripts/verify-context.sh
```

Add alias:

```bash
alias check='~/work/scripts/verify-context.sh'
```

### 5. Prevent Wrong Context Commits

Add git hooks to warn about context mismatches.

Create `.git/hooks/pre-commit` in your repos:

```bash
#!/bin/bash
# Warn if committing with wrong email domain

CURRENT_EMAIL=$(git config user.email)
REPO_PATH="$PWD"

# Check if in work directory but using personal email
if [[ "$REPO_PATH" == */work/projects/work/* ]]; then
    if [[ "$CURRENT_EMAIL" != *"@company.com" ]]; then
        echo "⚠️  WARNING: You're in a work repo but using email: $CURRENT_EMAIL"
        echo "   Expected work email (@company.com)"
        echo ""
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

# Check if in personal directory but using work email
if [[ "$REPO_PATH" == */work/projects/personal/* ]]; then
    if [[ "$CURRENT_EMAIL" == *"@company.com" ]]; then
        echo "⚠️  WARNING: You're in a personal repo but using work email: $CURRENT_EMAIL"
        echo ""
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi
```

---

## Quick Reference

### Common Commands

```bash
# Switch contexts
work              # Switch to work
personal          # Switch to personal
show-context      # Show current context

# Verify setup
check             # Run verification script (if you created it)
ssh-add -l        # List loaded SSH keys
git config user.email  # Check git email

# Fix context
work              # Reload work context
personal          # Reload personal context
```

### Troubleshooting

**Problem: Git still using wrong email**

```bash
# Check environment variables
echo $GIT_AUTHOR_EMAIL
echo $GIT_COMMITTER_EMAIL

# Check repository config (overrides environment)
cd /path/to/repo
git config user.email

# Remove repository config to use environment
git config --unset user.email
git config --unset user.name
```

**Problem: SSH key not loading**

```bash
# Check if key file exists
ls -la ~/.ssh/id_ed25519_work
ls -la ~/.ssh/id_ed25519_personal

# Manually load key
ssh-add ~/.ssh/id_ed25519_work

# List loaded keys
ssh-add -l

# Test connection
ssh -T git@github.com
```

**Problem: Context not persisting**

```bash
# Check if context file exists
cat ~/.zsh/private/current.zsh

# Check if sourced in .zshrc
grep "current.zsh" ~/.zshrc

# Manually source
source ~/.zsh/config/context.zsh
```

---

**Last Updated**: October 26, 2025
