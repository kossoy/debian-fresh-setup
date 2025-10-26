# Python Development Environment - Debian 13

Complete Python setup with pyenv for version management and essential packages for web development and AI/ML.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Build essentials installed
- Git installed

## 1. Install Python Build Dependencies

Pyenv needs these dependencies to build Python from source:

```bash
# Install Python build dependencies
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
    liblzma-dev
```

## 2. Pyenv (Python Version Management)

Pyenv allows you to easily switch between multiple versions of Python.

```bash
# Install pyenv
curl https://pyenv.run | bash

# Add to shell configuration (already done if using our bootstrap)
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Reload shell
source ~/.zshrc

# Install latest Python versions
pyenv install 3.11.7
pyenv install 3.12.1
pyenv global 3.12.1

# Verify installation
python --version
pip --version
```

## 3. Essential Python Packages

### Package Managers & Virtual Environments

```bash
# Upgrade pip
pip install --upgrade pip

# Install package managers
pip install pipenv poetry virtualenv
```

### Development Tools

```bash
# Code quality and testing
pip install black flake8 mypy pytest pytest-cov pylint autopep8
```

### AI/ML Packages

```bash
# Core data science libraries
pip install numpy pandas matplotlib seaborn scikit-learn

# Deep learning frameworks
pip install tensorflow torch torchvision torchaudio

# Jupyter for notebooks
pip install jupyter jupyterlab notebook
```

### Web Development

```bash
# Web frameworks
pip install django flask fastapi uvicorn gunicorn

# HTTP and web scraping
pip install requests beautifulsoup4 httpx

# API and database tools
pip install sqlalchemy alembic pydantic python-dotenv
```

### All-in-One Installation

```bash
# Install all essential packages at once
pip install \
  pipenv poetry virtualenv \
  black flake8 mypy pytest pytest-cov pylint autopep8 \
  numpy pandas matplotlib seaborn scikit-learn \
  tensorflow torch torchvision torchaudio \
  jupyter jupyterlab notebook \
  django flask fastapi uvicorn gunicorn \
  requests beautifulsoup4 httpx \
  sqlalchemy alembic pydantic python-dotenv
```

## 4. Jupyter Lab/Notebook

Jupyter provides an interactive computing environment.

```bash
# Install Jupyter Lab
pip install jupyterlab

# Install Jupyter extensions
pip install jupyter-contrib-nbextensions

# Generate configuration
jupyter lab --generate-config

# Start Jupyter Lab
jupyter lab

# Start Jupyter Lab on specific port
jupyter lab --port=8888
```

## 5. Virtual Environment Best Practices

### Using venv (Built-in)

```bash
# Create virtual environment
python -m venv myproject-env

# Activate
source myproject-env/bin/activate

# Deactivate
deactivate
```

### Using pipenv

```bash
# Install dependencies from Pipfile
pipenv install

# Activate environment
pipenv shell

# Install package
pipenv install requests

# Install dev dependencies
pipenv install --dev pytest
```

### Using poetry

```bash
# Create new project
poetry new myproject

# Install dependencies
poetry install

# Add package
poetry add requests

# Run script in environment
poetry run python script.py
```

## 6. Python Project Template

```bash
# Create new Python project structure
mkdir -p ~/work/projects/personal/my-python-project
cd ~/work/projects/personal/my-python-project

# Create project structure
mkdir -p src tests docs

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Create requirements files
cat > requirements.txt << 'REQEOF'
# Production dependencies
fastapi>=0.68.0
uvicorn>=0.15.0
pydantic>=1.8.0
sqlalchemy>=2.0.0
alembic>=1.12.0
requests>=2.31.0
python-dotenv>=1.0.0
REQEOF

cat > requirements-dev.txt << 'DEVEOF'
# Development dependencies
-r requirements.txt
pytest>=7.0.0
black>=22.0.0
flake8>=4.0.0
mypy>=0.950
pytest-cov>=4.0.0
DEVEOF

# Create .gitignore
cat > .gitignore << 'GITEOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv
*.egg-info/
dist/
build/

# Testing
.pytest_cache/
.coverage
htmlcov/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# Environment
.env
.env.local
GITEOF

# Initialize git
git init
echo "# My Python Project" > README.md
```

## 7. Python in JetBrains PyCharm

PyCharm Professional provides the best Python IDE experience:

```bash
# Install PyCharm via Snap (recommended)
sudo snap install pycharm-professional --classic

# Or download from JetBrains website
# https://www.jetbrains.com/pycharm/download/

# Open project in PyCharm
pycharm ~/work/projects/personal/my-python-project
```

**Key PyCharm Features:**
- Intelligent code completion
- Built-in debugger
- Database tools integration
- Docker and Kubernetes support
- Jupyter notebook support
- Scientific tools (NumPy, Pandas)
- Web frameworks support (Django, Flask, FastAPI)

## 8. Alternative: VS Code for Python

```bash
# Install VS Code
sudo apt install -y software-properties-common apt-transport-https wget
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code

# Recommended extensions (install via VS Code)
# - Python (ms-python.python)
# - Pylance (ms-python.vscode-pylance)
# - Python Debugger (ms-python.debugpy)
# - Jupyter (ms-toolsai.jupyter)
```

## 9. Common Commands

```bash
# Check Python version
python --version

# List installed packages
pip list

# Show package info
pip show <package-name>

# Update all packages
pip list --outdated
pip install --upgrade <package-name>

# Freeze dependencies
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt

# Run Python with specific version
python3.11 script.py
python3.12 script.py
```

## 10. Troubleshooting

### SSL Certificate Issues

```bash
# Update certificates
pip install --upgrade certifi

# Install system certificates
sudo apt install -y ca-certificates
sudo update-ca-certificates
```

### Permission Errors

Never use `sudo pip install`. Instead:

```bash
# Use --user flag
pip install --user <package-name>

# Or use virtual environment (recommended)
python -m venv venv
source venv/bin/activate
pip install <package-name>
```

### Pyenv Build Failures

If Python build fails:

```bash
# Make sure all dependencies are installed
sudo apt install -y build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl \
  libncursesw5-dev xz-utils tk-dev libxml2-dev \
  libxmlsec1-dev libffi-dev liblzma-dev

# Try building again
pyenv install 3.12.1
```

### TensorFlow/PyTorch on CPU

For CPU-only installations:

```bash
# TensorFlow CPU
pip install tensorflow-cpu

# PyTorch CPU
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

## 11. Python Development Workflow

### Quick Start New Project

```bash
# Function to create Python project (add to ~/.zsh/config/functions.zsh)
py_new() {
    local project_name="$1"
    if [[ -z "$project_name" ]]; then
        echo "Usage: py_new <project_name>"
        return 1
    fi
    
    mkdir -p "$project_name"
    cd "$project_name"
    python -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    mkdir -p src tests docs
    touch README.md requirements.txt .gitignore
    git init
    echo "Python project '$project_name' created!"
}
```

## Next Steps

Continue with:
- **[Node.js Environment](03-nodejs-environment.md)** - JavaScript development
- **[Docker Setup](04-docker-setup.md)** - Containerization
- **[IDEs & Editors](05-ides-editors.md)** - Development tools

---

**Estimated Time**: 30 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 26, 2025
