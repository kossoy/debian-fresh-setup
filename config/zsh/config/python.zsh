#!/bin/zsh
# =============================================================================
# PYTHON CONFIGURATION - LINUX VERSION
# =============================================================================
# Python development environment configuration
# =============================================================================

# =============================================================================
# PYTHON VERSION MANAGEMENT
# =============================================================================

# Pyenv configuration
if command -v pyenv >/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# =============================================================================
# PYTHON ALIASES
# =============================================================================

# Python shortcuts
alias py='python3'
alias pip='pip3'
alias python='python3'

# Virtual environment shortcuts
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
alias deactivate='deactivate'

# =============================================================================
# PYTHON FUNCTIONS
# =============================================================================

# Create and activate virtual environment
pyenv-create() {
    local name="${1:-venv}"
    python3 -m venv "$name"
    source "$name/bin/activate"
    pip install --upgrade pip
    echo "Virtual environment '$name' created and activated"
}

# Activate virtual environment
pyenv-activate() {
    local name="${1:-venv}"
    if [[ -f "$name/bin/activate" ]]; then
        source "$name/bin/activate"
        echo "Virtual environment '$name' activated"
    else
        echo "Virtual environment '$name' not found"
        return 1
    fi
}

# Install common Python packages
pyenv-install-common() {
    pip install \
        requests \
        numpy \
        pandas \
        matplotlib \
        seaborn \
        jupyter \
        ipython \
        black \
        flake8 \
        pytest \
        pipenv
    echo "Common Python packages installed"
}

# =============================================================================
# JUPYTER CONFIGURATION
# =============================================================================

# Jupyter shortcuts
alias jupyter='jupyter lab'
alias notebook='jupyter notebook'
alias lab='jupyter lab'

# Jupyter functions
jupyter-start() {
    local port="${1:-8888}"
    jupyter lab --port "$port" --no-browser --ip=0.0.0.0
}

# =============================================================================
# PYTHON DEVELOPMENT HELPERS
# =============================================================================

# Quick Python project setup
pyproject-init() {
    local project_name="${1:-myproject}"
    
    mkdir "$project_name"
    cd "$project_name"
    
    # Create virtual environment
    python3 -m venv venv
    source venv/bin/activate
    
    # Create basic structure
    mkdir src tests docs
    touch src/__init__.py tests/__init__.py
    
    # Create requirements.txt
    cat > requirements.txt << EOF
# Development dependencies
pytest>=7.0.0
black>=22.0.0
flake8>=4.0.0
mypy>=0.950

# Production dependencies
# Add your dependencies here
EOF
    
    # Create setup.py
    cat > setup.py << EOF
from setuptools import setup, find_packages

setup(
    name="$project_name",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[],
    python_requires=">=3.8",
)
EOF
    
    # Create .gitignore
    cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
env/
ENV/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF
    
    # Initialize git
    git init
    git add .
    git commit -m "Initial commit"
    
    echo "Python project '$project_name' initialized"
}

# =============================================================================
# PYTHON TESTING
# =============================================================================

# Run tests with coverage
test-coverage() {
    if [[ -f "requirements.txt" ]]; then
        pip install pytest-cov
    fi
    
    pytest --cov=. --cov-report=html --cov-report=term
}

# Run linting
lint() {
    if command -v black >/dev/null 2>&1; then
        echo "Running black..."
        black .
    fi
    
    if command -v flake8 >/dev/null 2>&1; then
        echo "Running flake8..."
        flake8 .
    fi
    
    if command -v mypy >/dev/null 2>&1; then
        echo "Running mypy..."
        mypy .
    fi
}

# =============================================================================
# PYTHON PACKAGE MANAGEMENT
# =============================================================================

# Install from requirements
pip-install() {
    if [[ -f "requirements.txt" ]]; then
        pip install -r requirements.txt
    else
        echo "requirements.txt not found"
        return 1
    fi
}

# Freeze requirements
pip-freeze() {
    pip freeze > requirements.txt
    echo "Requirements frozen to requirements.txt"
}

# =============================================================================
# PYTHON ENVIRONMENT INFO
# =============================================================================

# Show Python environment info
pyinfo() {
    echo "=== Python Environment ==="
    echo "Python version: $(python3 --version)"
    echo "Pip version: $(pip3 --version)"
    echo "Virtual environment: ${VIRTUAL_ENV:-'Not activated'}"
    
    if command -v pyenv >/dev/null 2>&1; then
        echo "Pyenv version: $(pyenv --version)"
        echo "Available Python versions:"
        pyenv versions
    fi
}
