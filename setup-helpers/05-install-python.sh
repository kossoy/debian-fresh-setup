#!/bin/bash
# =============================================================================
# Python Development Environment Setup
# =============================================================================
# Installs pyenv, Python, and essential packages
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🐍 Python Development Environment Setup${NC}"
echo "========================================"
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
    echo "1) Minimal - pyenv + Python + pip essentials"
    echo "2) Development - + dev tools (black, pytest, mypy, etc.)"
    echo "3) Web Development - + web frameworks (django, flask, fastapi)"
    echo "4) Full - Everything including AI/ML (tensorflow, pytorch, jupyter)"
    echo ""
    read -p "Select mode (1-4) [default: 1]: " -n 1 -r
    echo ""

    case $REPLY in
        1|"") INSTALL_MODE="minimal" ;;
        2) INSTALL_MODE="dev" ;;
        3) INSTALL_MODE="web" ;;
        4) INSTALL_MODE="full" ;;
        *) echo "Invalid choice, using minimal"; INSTALL_MODE="minimal" ;;
    esac
fi

echo -e "${GREEN}Installation mode: $INSTALL_MODE${NC}"
echo ""

# Step 1: Install Python build dependencies
echo -e "${BLUE}📦 Installing Python build dependencies...${NC}"
sudo apt update
sudo apt install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    git

echo -e "${GREEN}✅ Build dependencies installed${NC}"
echo ""

# Step 2: Install pyenv
if command -v pyenv >/dev/null 2>&1; then
    echo -e "${GREEN}✅ pyenv already installed: $(pyenv --version)${NC}"
else
    echo -e "${BLUE}📥 Installing pyenv...${NC}"
    curl https://pyenv.run | bash

    # Add to shell configuration if not already there
    ZSHRC="$HOME/.zshrc"
    if [[ -f "$ZSHRC" ]]; then
        if ! grep -q "PYENV_ROOT" "$ZSHRC"; then
            echo "" >> "$ZSHRC"
            echo '# Pyenv configuration' >> "$ZSHRC"
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$ZSHRC"
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$ZSHRC"
            echo 'eval "$(pyenv init -)"' >> "$ZSHRC"
        fi
    fi

    # Load pyenv in current shell
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    echo -e "${GREEN}✅ pyenv installed: $(pyenv --version)${NC}"
fi

echo ""

# Step 3: Install Python
PYTHON_VERSION="3.12.8"
echo -e "${BLUE}🐍 Installing Python $PYTHON_VERSION...${NC}"

if pyenv versions | grep -q "$PYTHON_VERSION"; then
    echo -e "${GREEN}✅ Python $PYTHON_VERSION already installed${NC}"
else
    echo "This may take several minutes..."
    pyenv install "$PYTHON_VERSION"
    echo -e "${GREEN}✅ Python $PYTHON_VERSION installed${NC}"
fi

# Set as global version
pyenv global "$PYTHON_VERSION"
echo -e "${GREEN}✅ Python $PYTHON_VERSION set as global${NC}"

# Verify Python installation
echo ""
echo "Python version:"
python --version
pip --version

echo ""

# Step 4: Upgrade pip
echo -e "${BLUE}📦 Upgrading pip...${NC}"
pip install --upgrade pip
echo -e "${GREEN}✅ pip upgraded${NC}"

echo ""

# Step 5: Install packages based on mode
case $INSTALL_MODE in
    minimal)
        echo -e "${BLUE}📦 Installing minimal Python packages...${NC}"
        pip install virtualenv
        echo -e "${GREEN}✅ Minimal packages installed: virtualenv${NC}"
        ;;

    dev)
        echo -e "${BLUE}📦 Installing development tools...${NC}"
        pip install \
            virtualenv \
            pipenv \
            poetry \
            black \
            flake8 \
            mypy \
            pytest \
            pytest-cov \
            pylint \
            autopep8 \
            ipython
        echo -e "${GREEN}✅ Development tools installed${NC}"
        ;;

    web)
        echo -e "${BLUE}📦 Installing web development packages...${NC}"
        pip install \
            virtualenv \
            pipenv \
            poetry \
            black \
            flake8 \
            mypy \
            pytest \
            pytest-cov \
            django \
            flask \
            fastapi \
            uvicorn \
            gunicorn \
            requests \
            beautifulsoup4 \
            httpx \
            sqlalchemy \
            alembic \
            pydantic \
            python-dotenv \
            ipython
        echo -e "${GREEN}✅ Web development packages installed${NC}"
        ;;

    full)
        echo -e "${BLUE}📦 Installing full Python stack (this will take a while)...${NC}"
        echo "Installing base packages..."
        pip install \
            virtualenv \
            pipenv \
            poetry \
            black \
            flake8 \
            mypy \
            pytest \
            pytest-cov \
            pylint \
            autopep8 \
            ipython

        echo "Installing web frameworks..."
        pip install \
            django \
            flask \
            fastapi \
            uvicorn \
            gunicorn \
            requests \
            beautifulsoup4 \
            httpx \
            sqlalchemy \
            alembic \
            pydantic \
            python-dotenv

        echo "Installing data science packages..."
        pip install \
            numpy \
            pandas \
            matplotlib \
            seaborn \
            scikit-learn

        echo "Installing Jupyter..."
        pip install \
            jupyter \
            jupyterlab \
            notebook

        echo -e "${YELLOW}⚠️  Skipping TensorFlow/PyTorch (install manually if needed)${NC}"
        echo "   TensorFlow: pip install tensorflow"
        echo "   PyTorch: pip install torch torchvision torchaudio"

        echo -e "${GREEN}✅ Full Python stack installed (except TensorFlow/PyTorch)${NC}"
        ;;
esac

echo ""

# Step 6: Create helper function
echo -e "${BLUE}📝 Creating Python helper functions...${NC}"

FUNCTIONS_FILE="$HOME/.zsh/config/functions.zsh"
if [[ -f "$FUNCTIONS_FILE" ]]; then
    if ! grep -q "py_new()" "$FUNCTIONS_FILE"; then
        cat >> "$FUNCTIONS_FILE" << 'PYEOF'

# Python project creation helper
py_new() {
    local project_name="$1"
    if [[ -z "$project_name" ]]; then
        echo "Usage: py_new <project_name>"
        return 1
    fi

    echo "Creating Python project: $project_name"
    mkdir -p "$project_name"
    cd "$project_name"

    # Create virtual environment
    python -m venv venv
    source venv/bin/activate

    # Upgrade pip
    pip install --upgrade pip

    # Create project structure
    mkdir -p src tests docs

    # Create requirements files
    cat > requirements.txt << 'REQEOF'
# Production dependencies
REQEOF

    cat > requirements-dev.txt << 'DEVEOF'
-r requirements.txt
# Development dependencies
pytest>=7.0.0
black>=22.0.0
flake8>=4.0.0
DEVEOF

    # Create .gitignore
    cat > .gitignore << 'GITEOF'
__pycache__/
*.py[cod]
venv/
.venv/
*.egg-info/
.pytest_cache/
.coverage
.env
.idea/
.vscode/
GITEOF

    # Create README
    echo "# $project_name" > README.md

    # Initialize git
    git init

    echo "✅ Python project '$project_name' created!"
    echo "   Activate venv: source venv/bin/activate"
}
PYEOF
        echo -e "${GREEN}✅ Helper function 'py_new' added to functions.zsh${NC}"
    else
        echo -e "${GREEN}✅ Helper function 'py_new' already exists${NC}"
    fi
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Python Environment Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Installed:"
echo "  • Python: $(python --version 2>&1)"
echo "  • pip: $(pip --version | cut -d' ' -f1-2)"
echo "  • pyenv: $(pyenv --version 2>&1)"
echo ""
echo "Useful commands:"
echo "  python --version       # Check Python version"
echo "  pip list              # List installed packages"
echo "  pyenv versions        # List installed Python versions"
echo "  pyenv install 3.11.7  # Install another Python version"
echo "  pyenv global 3.11.7   # Switch global Python version"
echo "  py_new myproject      # Create new Python project"
echo ""
echo "Create a virtual environment:"
echo "  python -m venv myenv"
echo "  source myenv/bin/activate"
echo ""

if [[ "$INSTALL_MODE" == "full" ]]; then
    echo -e "${YELLOW}Note: TensorFlow/PyTorch not installed (very large packages)${NC}"
    echo "Install manually if needed:"
    echo "  pip install tensorflow"
    echo "  pip install torch torchvision torchaudio"
    echo ""
fi
