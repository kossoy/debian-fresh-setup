#!/bin/bash
# =============================================================================
# Node.js Development Environment Setup
# =============================================================================
# Installs Volta, Node.js, and essential packages
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}⚡ Node.js Development Environment Setup${NC}"
echo "=========================================="
echo ""

# Check if running in non-interactive mode
NON_INTERACTIVE=false
if [[ "$1" == "--non-interactive" ]]; then
    NON_INTERACTIVE=true
    INSTALL_MODE="minimal"
fi

# Installation mode selection
if [[ "$NON_INTERACTIVE" == "false" ]]; then
    echo "Choose installation mode:"
    echo "1) Minimal - Volta + Node.js LTS"
    echo "2) Standard - + yarn, pnpm, typescript"
    echo "3) Full - + all dev tools (eslint, prettier, webpack, vite, etc.)"
    echo ""
    read -p "Select mode (1-3) [default: 1]: " -n 1 -r
    echo ""

    case $REPLY in
        1|"") INSTALL_MODE="minimal" ;;
        2) INSTALL_MODE="standard" ;;
        3) INSTALL_MODE="full" ;;
        *) echo "Invalid choice, using minimal"; INSTALL_MODE="minimal" ;;
    esac
fi

echo -e "${GREEN}Installation mode: $INSTALL_MODE${NC}"
echo ""

# Step 1: Install Volta
if command -v volta >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Volta already installed: $(volta --version)${NC}"
else
    echo -e "${BLUE}📥 Installing Volta...${NC}"
    curl https://get.volta.sh | bash

    # Load Volta in current shell
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"

    echo -e "${GREEN}✅ Volta installed: $(volta --version)${NC}"
fi

echo ""

# Ensure Volta is loaded
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Step 2: Install Node.js
echo -e "${BLUE}📦 Installing Node.js LTS...${NC}"
volta install node@lts

echo -e "${GREEN}✅ Node.js installed: $(node --version)${NC}"
echo -e "${GREEN}✅ npm installed: $(npm --version)${NC}"

echo ""

# Step 3: Install packages based on mode
case $INSTALL_MODE in
    minimal)
        echo -e "${BLUE}📦 Minimal installation complete${NC}"
        ;;

    standard)
        echo -e "${BLUE}📦 Installing standard packages...${NC}"
        volta install yarn pnpm typescript ts-node
        echo -e "${GREEN}✅ Standard packages installed${NC}"
        echo "  • yarn: $(yarn --version)"
        echo "  • pnpm: $(pnpm --version)"
        echo "  • typescript: $(tsc --version)"
        ;;

    full)
        echo -e "${BLUE}📦 Installing full package set...${NC}"

        echo "Installing package managers..."
        volta install yarn pnpm

        echo "Installing TypeScript..."
        volta install typescript ts-node

        echo "Installing development tools..."
        volta install nodemon eslint prettier

        echo "Installing build tools..."
        volta install webpack webpack-cli vite

        echo -e "${GREEN}✅ Full package set installed${NC}"
        echo "  • yarn: $(yarn --version)"
        echo "  • pnpm: $(pnpm --version)"
        echo "  • typescript: $(tsc --version)"
        echo "  • nodemon: $(nodemon --version)"
        echo "  • vite: $(vite --version)"
        ;;
esac

echo ""

# Step 4: Configure file watcher limits (Linux specific)
echo -e "${BLUE}🔧 Configuring file watcher limits...${NC}"
if grep -q "fs.inotify.max_user_watches" /etc/sysctl.conf 2>/dev/null; then
    echo -e "${GREEN}✅ File watcher limit already configured${NC}"
else
    echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p >/dev/null 2>&1 || true
    echo -e "${GREEN}✅ File watcher limit configured (524288)${NC}"
fi

echo ""

# Step 5: Add helper functions to zsh
echo -e "${BLUE}📝 Creating Node.js helper functions...${NC}"

FUNCTIONS_FILE="$HOME/.zsh/config/functions.zsh"
if [[ -f "$FUNCTIONS_FILE" ]]; then
    if ! grep -q "node_new()" "$FUNCTIONS_FILE"; then
        cat >> "$FUNCTIONS_FILE" << 'NODEOF'

# Node.js project creation helper
node_new() {
    local project_name="$1"
    local project_type="${2:-basic}"

    if [[ -z "$project_name" ]]; then
        echo "Usage: node_new <project_name> [type]"
        echo "Types: basic, typescript, react, express"
        return 1
    fi

    echo "Creating Node.js project: $project_name (type: $project_type)"
    mkdir -p "$project_name"
    cd "$project_name"

    case $project_type in
        typescript)
            npm init -y
            npm install --save-dev typescript @types/node ts-node
            npx tsc --init
            mkdir -p src
            echo 'console.log("Hello TypeScript!");' > src/index.ts
            ;;
        react)
            npm create vite@latest . -- --template react-ts
            ;;
        express)
            npm init -y
            npm install express
            npm install --save-dev @types/express typescript ts-node nodemon
            npx tsc --init
            mkdir -p src
            cat > src/index.ts << 'EXPRESSEOF'
import express from 'express';

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello Express!');
});

app.listen(port, () => {
  console.log(\`Server running at http://localhost:\${port}\`);
});
EXPRESSEOF
            ;;
        *)
            npm init -y
            mkdir -p src
            echo 'console.log("Hello Node.js!");' > src/index.js
            ;;
    esac

    # Create .gitignore
    cat > .gitignore << 'GITEOF'
node_modules/
dist/
build/
.env
.env.local
.DS_Store
*.log
coverage/
.vite/
GITEOF

    # Initialize git
    git init

    echo "✅ Node.js project '$project_name' created!"
    echo "   npm install    # Install dependencies"
    echo "   npm run dev    # Start development server"
}
NODEOF
        echo -e "${GREEN}✅ Helper function 'node_new' added to functions.zsh${NC}"
    else
        echo -e "${GREEN}✅ Helper function 'node_new' already exists${NC}"
    fi
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Node.js Environment Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Installed:"
echo "  • Node.js: $(node --version)"
echo "  • npm: $(npm --version)"
echo "  • Volta: $(volta --version)"

if [[ "$INSTALL_MODE" != "minimal" ]]; then
    echo ""
    echo "Global packages:"
    volta list all 2>/dev/null | grep -v "Node" || true
fi

echo ""
echo "Useful commands:"
echo "  node --version         # Check Node.js version"
echo "  npm --version          # Check npm version"
echo "  volta list             # List installed tools"
echo "  volta install node@18  # Install specific Node version"
echo "  node_new myapp         # Create basic Node.js project"
echo "  node_new myapp typescript  # Create TypeScript project"
echo "  node_new myapp react   # Create React project"
echo "  node_new myapp express # Create Express API project"
echo ""
echo "File watcher limit: 524288 (configured)"
echo ""
