#!/bin/bash
# =============================================================================
# AI/ML Tools Installation Script - Debian 13
# =============================================================================
# Sets up comprehensive AI/ML development environment with Python libraries
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🤖 AI/ML Tools Setup${NC}"
echo "====================================="
echo ""

# Check if Python is installed
PYTHON_CMD=""
if command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
else
    echo -e "${RED}❌ Python is not installed${NC}"
    echo "Install Python first:"
    echo "  ./setup-helpers/05-install-python.sh"
    echo "Or install system Python:"
    echo "  sudo apt install python3 python3-pip python3-venv"
    exit 1
fi

PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
echo -e "${GREEN}✅ Python $PYTHON_VERSION detected${NC}"
echo ""

# Check if pip is available
if ! $PYTHON_CMD -m pip --version >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  pip is not installed${NC}"
    echo "Installing pip..."

    # Try to install pip using apt first
    if command -v apt >/dev/null 2>&1; then
        sudo apt update >/dev/null 2>&1
        if [[ "$PYTHON_CMD" == "python3" ]]; then
            sudo apt install -y python3-pip python3-venv
        else
            sudo apt install -y python-pip python-venv
        fi
    else
        # Fallback to get-pip.py
        echo "Installing pip using get-pip.py..."
        curl -sS https://bootstrap.pypa.io/get-pip.py | $PYTHON_CMD
    fi

    # Verify pip installation
    if ! $PYTHON_CMD -m pip --version >/dev/null 2>&1; then
        echo -e "${RED}❌ Failed to install pip${NC}"
        echo "Please install pip manually:"
        echo "  sudo apt install python3-pip"
        exit 1
    fi

    echo -e "${GREEN}✅ pip installed${NC}"
    echo ""
fi

# Use python3 if python is not available
if [[ "$PYTHON_CMD" == "python3" ]]; then
    # Create alias for this session
    alias python=python3
    # Check for pip3
    if ! command -v pip >/dev/null 2>&1 && command -v pip3 >/dev/null 2>&1; then
        alias pip=pip3
    fi
fi

# Check for PEP 668 (externally-managed-environment) restriction
PEP668_FILE="/usr/lib/python$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)/EXTERNALLY-MANAGED"
if [[ -f "$PEP668_FILE" ]] && [[ "$PYTHON_CMD" == "python3" ]]; then
    if [[ "$AUTO_INSTALL" == "false" ]]; then
        echo -e "${YELLOW}⚠️  Debian 13 uses PEP 668 (externally-managed-environment)${NC}"
        echo ""
        echo "This prevents installing packages globally to protect system Python."
        echo "We need to use --break-system-packages flag for user-level installations."
        echo ""
        echo "This is SAFE because:"
        echo "  • Packages install to ~/.local/lib/python3.13/site-packages"
        echo "  • System Python packages are not affected"
        echo "  • Only affects your user account"
        echo ""
        read -p "Continue with --break-system-packages? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            echo ""
            echo "Alternative: Use pyenv for isolated Python environment:"
            echo "  ./setup-helpers/05-install-python.sh"
            exit 0
        fi
        echo ""
    fi
    PIP_BREAK_SYSTEM="--break-system-packages"
else
    PIP_BREAK_SYSTEM=""
fi

# Function to install packages
install_packages() {
    local package_list="$1"
    local description="$2"

    echo -e "${BLUE}📦 Installing $description...${NC}"
    # Install to user directory with PEP 668 override if needed
    $PYTHON_CMD -m pip install --user $PIP_BREAK_SYSTEM --upgrade $package_list
    echo -e "${GREEN}✅ $description installed${NC}"
    echo ""
}

# Installation modes
echo "Choose installation mode:"
echo ""
echo "1. Minimal     - Core data science stack only (numpy, pandas, matplotlib)"
echo "2. Standard    - Core + scikit-learn + Jupyter Lab"
echo "3. Deep Learning - Standard + TensorFlow + PyTorch"
echo "4. Full        - Everything including experiment tracking, NLP, CV"
echo "5. Custom      - Choose individual components"
echo ""

# Auto-install mode
AUTO_INSTALL=false
if [[ "$1" == "--auto" ]]; then
    AUTO_INSTALL=true
    MODE="2"  # Standard by default
    if [[ -n "$2" ]]; then
        MODE="$2"
    fi
else
    read -p "Select mode (1-5): " -n 1 -r MODE
    echo ""
fi

echo ""

case $MODE in
    1)  # Minimal
        echo -e "${BLUE}Installing Minimal AI/ML stack...${NC}"
        echo ""

        install_packages "numpy pandas matplotlib seaborn scipy" "Core data science libraries"
        ;;

    2)  # Standard
        echo -e "${BLUE}Installing Standard AI/ML stack...${NC}"
        echo ""

        install_packages "numpy pandas matplotlib seaborn scipy" "Core data science libraries"
        install_packages "scikit-learn" "Machine learning library"
        install_packages "jupyterlab jupyter-contrib-nbextensions jupyterlab-git" "Jupyter Lab"
        install_packages "ipykernel" "Jupyter kernel support"

        # Generate Jupyter config
        echo -e "${BLUE}Configuring Jupyter Lab...${NC}"
        jupyter lab --generate-config
        echo -e "${GREEN}✅ Jupyter Lab configured${NC}"
        echo ""
        ;;

    3)  # Deep Learning
        echo -e "${BLUE}Installing Deep Learning stack...${NC}"
        echo ""

        install_packages "numpy pandas matplotlib seaborn scipy" "Core data science libraries"
        install_packages "scikit-learn" "Machine learning library"
        install_packages "jupyterlab jupyter-contrib-nbextensions jupyterlab-git" "Jupyter Lab"
        install_packages "ipykernel" "Jupyter kernel support"
        install_packages "tensorflow" "TensorFlow"
        install_packages "torch torchvision torchaudio" "PyTorch"
        install_packages "tensorboard" "TensorBoard visualization"

        # Generate Jupyter config
        jupyter lab --generate-config 2>/dev/null || true
        echo ""
        ;;

    4)  # Full
        echo -e "${BLUE}Installing Full AI/ML stack...${NC}"
        echo ""

        install_packages "numpy pandas matplotlib seaborn scipy" "Core data science libraries"
        install_packages "scikit-learn" "Machine learning library"
        install_packages "jupyterlab jupyter-contrib-nbextensions jupyterlab-git" "Jupyter Lab"
        install_packages "ipykernel jupyterlab-lsp python-lsp-server" "Jupyter extensions"
        install_packages "jupyterlab-code-formatter black isort" "Code formatting"
        install_packages "tensorflow" "TensorFlow"
        install_packages "torch torchvision torchaudio" "PyTorch"
        install_packages "tensorboard" "TensorBoard visualization"
        install_packages "mlflow" "MLflow experiment tracking"
        install_packages "transformers datasets accelerate" "Hugging Face Transformers"
        install_packages "opencv-python opencv-contrib-python" "OpenCV computer vision"
        install_packages "nltk" "NLTK natural language processing"
        install_packages "wandb" "Weights & Biases"
        install_packages "dvc" "Data Version Control"
        install_packages "fastapi uvicorn" "Model serving"

        # Generate Jupyter config
        jupyter lab --generate-config 2>/dev/null || true

        # Download NLTK data
        echo -e "${BLUE}Downloading NLTK data...${NC}"
        $PYTHON_CMD -c "import nltk; nltk.download('popular', quiet=True)" 2>/dev/null || true
        echo -e "${GREEN}✅ NLTK data downloaded${NC}"
        echo ""
        ;;

    5)  # Custom
        echo -e "${BLUE}Custom installation${NC}"
        echo ""

        # Core libraries
        read -p "Install core data science libraries (numpy, pandas, matplotlib)? (y/n): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] && install_packages "numpy pandas matplotlib seaborn scipy" "Core data science libraries"

        # Machine learning
        read -p "Install scikit-learn? (y/n): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] && install_packages "scikit-learn" "Machine learning library"

        # Jupyter
        read -p "Install Jupyter Lab? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_packages "jupyterlab jupyter-contrib-nbextensions jupyterlab-git" "Jupyter Lab"
            install_packages "ipykernel" "Jupyter kernel support"
            jupyter lab --generate-config 2>/dev/null || true
        fi

        # TensorFlow
        read -p "Install TensorFlow? (y/n): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] && install_packages "tensorflow tensorboard" "TensorFlow"

        # PyTorch
        read -p "Install PyTorch? (y/n): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] && install_packages "torch torchvision torchaudio" "PyTorch"

        # Experiment tracking
        read -p "Install experiment tracking (MLflow)? (y/n): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] && install_packages "mlflow" "MLflow experiment tracking"

        # Transformers
        read -p "Install Hugging Face Transformers? (y/n): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] && install_packages "transformers datasets accelerate" "Hugging Face Transformers"

        # Computer Vision
        read -p "Install OpenCV? (y/n): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] && install_packages "opencv-python opencv-contrib-python" "OpenCV computer vision"

        # NLP
        read -p "Install NLTK? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_packages "nltk" "NLTK natural language processing"
            $PYTHON_CMD -c "import nltk; nltk.download('popular', quiet=True)" 2>/dev/null || true
        fi

        # Model serving
        read -p "Install FastAPI for model serving? (y/n): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] && install_packages "fastapi uvicorn" "Model serving"
        ;;

    *)
        echo -e "${RED}Invalid selection${NC}"
        exit 1
        ;;
esac

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ AI/ML Tools Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check what's installed
echo "Installed packages:"
echo ""

if $PYTHON_CMD -c "import numpy" 2>/dev/null; then
    NUMPY_VER=$($PYTHON_CMD -c "import numpy; print(numpy.__version__)")
    echo -e "${GREEN}✅ NumPy $NUMPY_VER${NC}"
fi

if $PYTHON_CMD -c "import pandas" 2>/dev/null; then
    PANDAS_VER=$($PYTHON_CMD -c "import pandas; print(pandas.__version__)")
    echo -e "${GREEN}✅ Pandas $PANDAS_VER${NC}"
fi

if $PYTHON_CMD -c "import sklearn" 2>/dev/null; then
    SKLEARN_VER=$($PYTHON_CMD -c "import sklearn; print(sklearn.__version__)")
    echo -e "${GREEN}✅ scikit-learn $SKLEARN_VER${NC}"
fi

if command -v jupyter >/dev/null 2>&1; then
    JUPYTER_VER=$(jupyter --version 2>&1 | head -1)
    echo -e "${GREEN}✅ Jupyter Lab installed${NC}"
fi

if $PYTHON_CMD -c "import tensorflow" 2>/dev/null; then
    TF_VER=$($PYTHON_CMD -c "import tensorflow; print(tensorflow.__version__)")
    echo -e "${GREEN}✅ TensorFlow $TF_VER${NC}"
fi

if $PYTHON_CMD -c "import torch" 2>/dev/null; then
    TORCH_VER=$($PYTHON_CMD -c "import torch; print(torch.__version__)")
    echo -e "${GREEN}✅ PyTorch $TORCH_VER${NC}"
fi

if $PYTHON_CMD -c "import mlflow" 2>/dev/null; then
    echo -e "${GREEN}✅ MLflow installed${NC}"
fi

if $PYTHON_CMD -c "import transformers" 2>/dev/null; then
    echo -e "${GREEN}✅ Hugging Face Transformers installed${NC}"
fi

if $PYTHON_CMD -c "import cv2" 2>/dev/null; then
    echo -e "${GREEN}✅ OpenCV installed${NC}"
fi

echo ""
echo "Quick start commands:"
echo ""

if command -v jupyter >/dev/null 2>&1; then
    echo "  jupyter lab                    # Start Jupyter Lab"
fi

if python -c "import mlflow" 2>/dev/null; then
    echo "  mlflow ui                      # Start MLflow UI"
fi

if python -c "import tensorboard" 2>/dev/null; then
    echo "  tensorboard --logdir=./logs    # Start TensorBoard"
fi

echo ""
echo "GPU Support:"
echo ""

# Check for NVIDIA GPU
if command -v nvidia-smi >/dev/null 2>&1; then
    echo -e "${GREEN}✅ NVIDIA GPU detected${NC}"
    nvidia-smi --query-gpu=name --format=csv,noheader | head -1
    echo ""
    echo "To enable CUDA support for PyTorch/TensorFlow:"
    echo "  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118"
    echo "  pip install tensorflow[and-cuda]"
else
    echo -e "${YELLOW}⚠️  No NVIDIA GPU detected${NC}"
    echo "AI/ML libraries will use CPU only"
fi

echo ""

# Check if ~/.local/bin is in PATH
if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}⚠️  ~/.local/bin is not in your PATH${NC}"
    echo ""
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Or run now:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

echo "Next steps:"
echo "  1. Test installation: python3 -c 'import numpy, pandas; print(\"✅ All good\")'"
echo "  2. Create ML project: py_new my-ml-project (if pyenv installed)"
echo "  3. Start Jupyter Lab: jupyter lab (if installed)"
echo "  4. Check databases: db-manage.sh status"
echo ""
