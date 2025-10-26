#!/bin/bash
# =============================================================================
# Debian 12 Fresh Setup Bootstrap Script
# =============================================================================
# Semi-automated development environment setup for Debian 12.13 desktop workstation
# =============================================================================

set -e

# Check for test mode
TEST_MODE=false
if [[ "$1" == "--test" ]]; then
    TEST_MODE=true
    echo "🧪 Running in test mode (non-interactive)"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Function to check system requirements
check_system() {
    print_header "🔍 System Compatibility Check"
    
    # Check if running on Debian
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        print_status "OS: $NAME $VERSION"
        
        if [[ "$ID" == "debian" ]]; then
            if [[ "$VERSION_ID" == "12" ]] || [[ "$VERSION_ID" == "12."* ]]; then
                print_success "Debian 12 detected - compatible"
            else
                print_warning "This script is designed for Debian 12, but you have $VERSION_ID"
                read -p "Continue anyway? (y/n): " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
        else
            print_warning "This script is designed for Debian 12, but you have $ID"
            read -p "Continue anyway? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        print_error "Cannot detect OS version. This script requires Debian 12."
        exit 1
    fi
    
    # Check architecture
    local arch=$(uname -m)
    print_status "Architecture: $arch"
    
    if [[ "$arch" == "x86_64" ]]; then
        print_success "x86_64 architecture detected"
    elif [[ "$arch" == "aarch64" ]] || [[ "$arch" == "arm64" ]]; then
        print_success "ARM64 architecture detected"
    else
        print_warning "Architecture $arch may not be fully supported"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "Don't run this script as root/sudo"
        exit 1
    fi
    
    # Check for sudo access
    if ! sudo -n true 2>/dev/null; then
        print_warning "This script requires sudo access for package installation"
        print_status "You may be prompted for your password"
    fi
    
    print_success "System compatibility check passed"
    echo ""
}

# Function to collect user information
collect_user_info() {
    print_header "📝 User Information Collection"
    
    if $TEST_MODE; then
        # Use test data in test mode
        USER_FULL_NAME="Test User"
        WORK_EMAIL="test@example.com"
        PERSONAL_EMAIL="test@personal.com"
        WORK_CONTEXT="TEST_WORK"
        PERSONAL_CONTEXT="TEST_PERSONAL"
        GITHUB_USERNAME="testuser"
        GITHUB_ORG="testorg"
        BROWSER_CHOICE="1"
        VPN_CHOICE="portal"
        INSTALLATION_MODE="1"
        return
    fi
    
    # Full name for Git
    read -p "Enter your full name for Git commits: " USER_FULL_NAME
    if [[ -z "$USER_FULL_NAME" ]]; then
        print_error "Full name is required"
        exit 1
    fi
    
    # Work email
    read -p "Enter your work email address: " WORK_EMAIL
    if [[ -z "$WORK_EMAIL" ]]; then
        print_error "Work email is required"
        exit 1
    fi
    
    # Personal email
    read -p "Enter your personal email address: " PERSONAL_EMAIL
    if [[ -z "$PERSONAL_EMAIL" ]]; then
        print_error "Personal email is required"
        exit 1
    fi
    
    # Work context name
    read -p "Enter work context name (default: COMPANY_ORG): " WORK_CONTEXT
    WORK_CONTEXT=${WORK_CONTEXT:-COMPANY_ORG}
    
    # Personal context name
    read -p "Enter personal context name (default: PERSONAL_ORG): " PERSONAL_CONTEXT
    PERSONAL_CONTEXT=${PERSONAL_CONTEXT:-PERSONAL_ORG}
    
    # GitHub usernames
    read -p "Enter work GitHub username: " WORK_GITHUB_USER
    read -p "Enter personal GitHub username: " PERSONAL_GITHUB_USER
    
    # Browser preferences
    echo "Browser preferences:"
    echo "1) Firefox for work, Chrome for personal (recommended)"
    echo "2) Chrome for work, Firefox for personal"
    echo "3) Firefox for work, Brave for personal"
    echo "4) Custom"
    read -p "Choose option (1-4): " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            WORK_BROWSER="firefox"
            PERSONAL_BROWSER="chrome"
            ;;
        2)
            WORK_BROWSER="chrome"
            PERSONAL_BROWSER="firefox"
            ;;
        3)
            WORK_BROWSER="firefox"
            PERSONAL_BROWSER="brave"
            ;;
        4)
            read -p "Enter work browser (firefox/chrome/brave/edge): " WORK_BROWSER
            read -p "Enter personal browser (firefox/chrome/brave/edge): " PERSONAL_BROWSER
            ;;
        *)
            WORK_BROWSER="firefox"
            PERSONAL_BROWSER="chrome"
            ;;
    esac
    
    # VPN portal (optional)
    read -p "Enter VPN portal address (optional, press Enter to skip): " VPN_PORTAL
    
    print_success "User information collected"
    echo ""
}

# Function to select installation mode
select_installation_mode() {
    print_header "⚙️  Installation Mode Selection"
    
    echo "Choose installation mode:"
    echo "1) Full Installation (recommended)"
    echo "   - System packages via APT"
    echo "   - Docker Engine + Docker Compose"
    echo "   - Oh My Zsh + plugins + Powerlevel10k"
    echo "   - Complete shell configuration"
    echo "   - Utility scripts"
    echo "   - Work directory structure"
    echo ""
    echo "2) Minimal Installation"
    echo "   - Shell configuration only"
    echo "   - Essential scripts"
    echo "   - Skip package installations"
    echo ""
    echo "3) Custom Installation"
    echo "   - Choose individual components"
    echo ""
    
    if $TEST_MODE; then
        REPLY="1"  # Full installation for test
    else
        read -p "Select mode (1-3): " -n 1 -r
        echo ""
    fi
    
    case $REPLY in
        1)
            INSTALL_MODE="full"
            ;;
        2)
            INSTALL_MODE="minimal"
            ;;
        3)
            INSTALL_MODE="custom"
            ;;
        *)
            INSTALL_MODE="full"
            ;;
    esac
    
    print_success "Selected installation mode: $INSTALL_MODE"
    echo ""
}

# Function to customize installation for custom mode
customize_installation() {
    if [[ "$INSTALL_MODE" != "custom" ]]; then
        return
    fi
    
    print_header "🔧 Custom Installation Options"
    
    INSTALL_SYSTEM_PACKAGES=false
    INSTALL_OHMYZSH=false
    INSTALL_DOCKER=false
    INSTALL_SHELL_CONFIG=true
    INSTALL_SCRIPTS=true
    INSTALL_WORK_DIR=true

    echo "Select components to install:"
    read -p "Install system packages via APT? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_SYSTEM_PACKAGES=true
    fi

    read -p "Install Docker? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_DOCKER=true
    fi

    read -p "Install Oh My Zsh + plugins? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_OHMYZSH=true
    fi
    
    read -p "Install shell configuration? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_SHELL_CONFIG=true
    fi
    
    read -p "Install utility scripts? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_SCRIPTS=true
    fi
    
    read -p "Create work directory structure? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_WORK_DIR=true
    fi
    
    print_success "Custom installation configured"
    echo ""
}

# Function to display installation plan
display_installation_plan() {
    print_header "📋 Installation Plan"
    
    echo "The following will be installed:"
    echo ""
    
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_SYSTEM_PACKAGES" == "true" ]]; then
        echo "✅ System packages via APT (build-essential, git, curl, etc.)"
        echo "✅ Development dependencies"
        echo "✅ Modern CLI tools (ripgrep, fd, bat, eza, gh, etc.)"
    fi

    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_DOCKER" == "true" ]]; then
        echo "✅ Docker Engine + Docker Compose"
        echo "✅ Docker user group membership"
    fi
    
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_OHMYZSH" == "true" ]]; then
        echo "✅ Oh My Zsh framework"
        echo "✅ zsh-autosuggestions plugin"
        echo "✅ zsh-syntax-highlighting plugin"
        echo "✅ Powerlevel10k theme"
    fi
    
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_SHELL_CONFIG" == "true" ]]; then
        echo "✅ Zsh configuration (~/.zshrc)"
        echo "✅ Modular config structure (~/.zsh/)"
        echo "✅ Aliases and functions"
        echo "✅ Context switching (work/personal)"
        echo "✅ Powerlevel10k configuration"
    fi
    
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_SCRIPTS" == "true" ]]; then
        echo "✅ Utility scripts (~/work/scripts/)"
        echo "✅ Disk usage analyzer (wdu)"
        echo "✅ Process management tools"
        echo "✅ Network utilities"
        echo "✅ File organization tools"
    fi
    
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_WORK_DIR" == "true" ]]; then
        echo "✅ Work directory structure (~/work/)"
        echo "✅ Project organization"
        echo "✅ Configuration management"
    fi
    
    echo ""
    echo "User Configuration:"
    echo "👤 Name: $USER_FULL_NAME"
    echo "📧 Work Email: $WORK_EMAIL"
    echo "📧 Personal Email: $PERSONAL_EMAIL"
    echo "🏢 Work Context: $WORK_CONTEXT"
    echo "🏠 Personal Context: $PERSONAL_CONTEXT"
    echo "🌐 Work Browser: $WORK_BROWSER"
    echo "🌐 Personal Browser: $PERSONAL_BROWSER"
    if [[ -n "$VPN_PORTAL" ]]; then
        echo "🔒 VPN Portal: $VPN_PORTAL"
    fi
    echo ""
    
    if ! $TEST_MODE; then
        read -p "Proceed with installation? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
    fi
}

# Function to run installation steps
run_installation() {
    print_header "🚀 Starting Installation"
    
    # Install system packages
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_SYSTEM_PACKAGES" == "true" ]]; then
        print_status "Installing system packages..."
        bash "$SCRIPT_DIR/setup-helpers/01-install-packages.sh"
        print_success "System packages installation complete"
    fi

    # Install Docker
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_DOCKER" == "true" ]]; then
        print_status "Installing Docker..."
        bash "$SCRIPT_DIR/setup-helpers/04-install-docker.sh"
        print_success "Docker installation complete"
    fi

    # Install Oh My Zsh
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_OHMYZSH" == "true" ]]; then
        print_status "Installing Oh My Zsh and plugins..."
        bash "$SCRIPT_DIR/setup-helpers/02-install-oh-my-zsh.sh"
        print_success "Oh My Zsh installation complete"
    fi

    # Setup shell configuration
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_SHELL_CONFIG" == "true" ]]; then
        print_status "Setting up shell configuration..."
        bash "$SCRIPT_DIR/setup-helpers/03-setup-shell.sh"
        print_success "Shell configuration complete"
    fi
    
    # Install utility scripts
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_SCRIPTS" == "true" ]]; then
        print_status "Installing utility scripts..."
        mkdir -p ~/work/scripts
        cp -r "$SCRIPT_DIR/scripts/"* ~/work/scripts/ 2>/dev/null || true
        chmod +x ~/work/scripts/*.sh ~/work/scripts/*.zsh 2>/dev/null || true
        print_success "Utility scripts installed"
    fi
    
    # Create work directory structure
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_WORK_DIR" == "true" ]]; then
        print_status "Creating work directory structure..."
        mkdir -p ~/work/{databases,tools,projects/{work,personal},configs/{work,personal},scripts,docs,bin}
        print_success "Work directory structure created"
    fi

    # Configure Git
    print_status "Configuring Git..."
    git config --global user.name "$USER_FULL_NAME"
    git config --global user.email "$PERSONAL_EMAIL"
    git config --global init.defaultBranch main
    git config --global color.ui auto
    git config --global pull.rebase true
    git config --global fetch.prune true
    print_success "Git configured with: $USER_FULL_NAME <$PERSONAL_EMAIL>"

    # Generate SSH key
    SSH_KEY_GENERATED=false
    if [[ ! -f ~/.ssh/id_ed25519 ]]; then
        print_status "Generating SSH key for personal use..."
        ssh-keygen -t ed25519 -C "$PERSONAL_EMAIL" -f ~/.ssh/id_ed25519 -N ""
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        print_success "SSH key generated: ~/.ssh/id_ed25519"
        SSH_KEY_GENERATED=true

        print_status "Your public key:"
        cat ~/.ssh/id_ed25519.pub
        echo ""
    else
        print_status "SSH key already exists, skipping generation"
    fi

    # Authenticate with GitHub and add SSH key
    if command -v gh >/dev/null 2>&1; then
        print_status "Configuring GitHub CLI..."

        # Check if already authenticated
        if gh auth status >/dev/null 2>&1; then
            print_success "Already authenticated with GitHub CLI"
        else
            print_status "Authenticating with GitHub CLI..."
            if ! $TEST_MODE; then
                gh auth login --git-protocol ssh --web
            fi
        fi

        # Add SSH key to GitHub if we just generated it
        if [[ "$SSH_KEY_GENERATED" == "true" ]] && gh auth status >/dev/null 2>&1; then
            print_status "Adding SSH key to GitHub..."
            if gh ssh-key add ~/.ssh/id_ed25519.pub --title "debian-$(hostname)-$(date +%Y%m%d)" 2>/dev/null; then
                print_success "SSH key automatically added to GitHub!"
            else
                print_warning "Could not automatically add SSH key (may already exist)"
                print_status "Add it manually at: https://github.com/settings/keys"
            fi
        fi
    else
        print_warning "GitHub CLI not installed, skipping GitHub authentication"
        print_status "Install with: sudo apt install gh"
    fi

    # Setup context switching with actual user data
    print_status "Setting up context switching..."
    mkdir -p ~/.zsh/private

    # Create work context template
    cat > ~/.zsh/private/work-template.zsh << WORK_CONTEXT_EOF
export WORK_CONTEXT="work"
export GIT_AUTHOR_NAME="$USER_FULL_NAME"
export GIT_AUTHOR_EMAIL="$WORK_EMAIL"
export GIT_COMMITTER_NAME="\$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="\$GIT_AUTHOR_EMAIL"
export WORK_PROJECTS="\$HOME/work/projects/work"
cd "\$WORK_PROJECTS" 2>/dev/null || cd "\$HOME/work"
WORK_CONTEXT_EOF

    # Create personal context template
    cat > ~/.zsh/private/personal-template.zsh << PERSONAL_CONTEXT_EOF
export WORK_CONTEXT="personal"
export GIT_AUTHOR_NAME="$USER_FULL_NAME"
export GIT_AUTHOR_EMAIL="$PERSONAL_EMAIL"
export GIT_COMMITTER_NAME="\$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="\$GIT_AUTHOR_EMAIL"
export PERSONAL_PROJECTS="\$HOME/work/projects/personal"
cd "\$PERSONAL_PROJECTS" 2>/dev/null || cd "\$HOME/work"
PERSONAL_CONTEXT_EOF

    # Update context.zsh with real email addresses
    if [[ -f ~/.zsh/config/context.zsh ]]; then
        sed -i.bak "s/john.doe@company.com/$WORK_EMAIL/g" ~/.zsh/config/context.zsh
        sed -i.bak "s/john@example.com/$PERSONAL_EMAIL/g" ~/.zsh/config/context.zsh
        sed -i.bak "s/John Doe/$USER_FULL_NAME/g" ~/.zsh/config/context.zsh
        rm ~/.zsh/config/context.zsh.bak
    fi

    # Set default to personal context
    cp ~/.zsh/private/personal-template.zsh ~/.zsh/private/current.zsh
    print_success "Context switching configured (default: personal)"

    print_success "Installation completed successfully!"
    echo ""
}

# Function to display post-installation instructions
display_post_installation() {
    print_header "🎉 Installation Complete!"

    echo "✅ What was configured automatically:"
    echo ""
    echo "  ✓ Git: $USER_FULL_NAME <$PERSONAL_EMAIL>"
    echo "  ✓ SSH key: ~/.ssh/id_ed25519"
    echo "  ✓ Context switching: work ↔ personal"
    echo "  ✓ Work directory: ~/work/"
    echo "  ✓ Shell: zsh + Oh My Zsh + Powerlevel10k"
    echo ""

    print_header "📝 Next Steps (Required):"
    echo ""
    if [[ "$INSTALL_MODE" == "full" ]] || [[ "$INSTALL_DOCKER" == "true" ]]; then
        echo "1. 🔄 Log out and log back in (or run: newgrp docker)"
        echo "   This activates your docker group membership"
        echo ""
        echo "2. 🔄 Reload your shell:"
        echo "   exec zsh"
        echo ""
    else
        echo "1. 🔄 Reload your shell:"
        echo "   exec zsh"
        echo ""
    fi

    print_header "🧪 Test Your Setup:"
    echo ""
    echo "  work          # Switch to work context ($WORK_EMAIL)"
    echo "  personal      # Switch to personal context ($PERSONAL_EMAIL)"
    echo "  show-context  # Check current context"
    echo "  wdu           # Disk usage analyzer"
    echo ""

    print_header "🔧 Optional:"
    echo ""
    echo "• Generate work SSH key:"
    echo "  ssh-keygen -t ed25519 -C '$WORK_EMAIL' -f ~/.ssh/id_ed25519_work"
    echo ""
    echo "• Add API keys (if needed):"
    echo "  nano ~/.zsh/private/api-keys.zsh"
    echo ""

    print_success "Setup complete! Welcome to your new development environment! 🚀"
}

# Main execution
main() {
    print_header "🐧 Debian 12 Fresh Setup Package"
    print_header "=================================="
    echo ""
    echo "Semi-automated development environment setup for Debian 12.13 desktop workstation"
    echo ""
    
    # Check system requirements
    check_system
    
    # Collect user information
    collect_user_info
    
    # Select installation mode
    select_installation_mode
    
    # Customize installation if needed
    customize_installation
    
    # Display installation plan
    display_installation_plan
    
    # Run installation
    run_installation
    
    # Display post-installation instructions
    display_post_installation
}

# Run main function
main "$@"
