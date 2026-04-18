#!/usr/bin/env bash
# Instalação do ambiente PySpark no macOS
#
# Uso normal (usa Anaconda ou Miniconda já instalado):
#   bash install/mac_install.sh
#
# Forçar Miniconda separado (quando Anaconda está instalado mas com problemas,
# ou para não interferir com Orange / outras ferramentas):
#   bash install/mac_install.sh --miniconda

set -euo pipefail

ENV_NAME="bigdata"
PYTHON_VERSION="3.11"
MINICONDA_DIR="$HOME/miniconda3"
FORCE_MINICONDA=false

# ── Argumentos ─────────────────────────────────────────────────────────────────
for arg in "$@"; do
    case $arg in
        --miniconda) FORCE_MINICONDA=true ;;
    esac
done

echo "=== Instalação PySpark — macOS ==="
[[ "$FORCE_MINICONDA" == true ]] && echo "  (modo: Miniconda separado)"
echo ""

# ── Função: localizar conda (Anaconda ou Miniconda) ────────────────────────────
find_conda() {
    if command -v conda &>/dev/null; then return 0; fi
    for dir in \
        "$HOME/anaconda3" "$HOME/anaconda" "/opt/anaconda3" "/usr/local/anaconda3" \
        "$HOME/miniconda3" "$HOME/miniconda" "/opt/miniconda3" "/usr/local/miniconda3"
    do
        if [[ -f "$dir/bin/conda" ]]; then
            source "$dir/etc/profile.d/conda.sh"
            echo "  (conda encontrado em $dir)"
            return 0
        fi
    done
    return 1
}

# ── Função: usar Miniconda separado (sem tocar no Anaconda) ───────────────────
use_miniconda() {
    if [[ -f "$MINICONDA_DIR/bin/conda" ]]; then
        source "$MINICONDA_DIR/etc/profile.d/conda.sh"
        echo "  (Miniconda encontrado em $MINICONDA_DIR)"
        return 0
    fi
    return 1
}

# ── 1. Homebrew ────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo "[1/4] A instalar Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "[1/4] Homebrew já instalado — ok"
fi

# ── 2. Conda ───────────────────────────────────────────────────────────────────
if [[ "$FORCE_MINICONDA" == true ]]; then
    if use_miniconda; then
        echo "[2/4] Miniconda já instalado em $MINICONDA_DIR — ok"
    else
        echo "[2/4] A instalar Miniconda em $MINICONDA_DIR (sem alterar o Anaconda)..."
        brew install --cask miniconda
        # NÃO corremos conda init — o Anaconda continua a ser o conda do sistema
        source "$MINICONDA_DIR/etc/profile.d/conda.sh"
        echo ""
        echo "  Miniconda instalado em $MINICONDA_DIR"
        echo "  O Anaconda (e o Orange) continuam sem alterações."
    fi
else
    if find_conda; then
        CONDA_DIST=$(conda info --base 2>/dev/null || echo "desconhecido")
        echo "[2/4] Conda já instalado em $CONDA_DIST — ok"
    else
        echo "[2/4] Conda não encontrado. A instalar Miniconda..."
        brew install --cask miniconda
        conda init zsh
        echo ""
        echo "  ATENÇÃO: Fechar e reabrir o terminal, depois correr novamente este script."
        exit 0
    fi
fi

# ── Função: instalar pacotes com mamba (rápido) ou conda (lento) ──────────────
install_packages() {
    local env="$1"; shift
    if command -v mamba &>/dev/null; then
        mamba install -n "$env" -c conda-forge "$@"
    else
        # libmamba solver evita bloqueio em "Solving environment"
        conda install -n "$env" -c conda-forge --solver=libmamba "$@" 2>/dev/null \
            || conda install -n "$env" -c conda-forge "$@"
    fi
}

# ── 3. Ambiente conda ──────────────────────────────────────────────────────────
echo "[3/4] A criar ambiente '$ENV_NAME'..."

# Garantir que mamba está disponível no ambiente base
if ! command -v mamba &>/dev/null; then
    echo "  A instalar mamba para resolver dependências mais rapidamente..."
    conda install -n base -c conda-forge mamba -y
fi

if conda env list | grep -q "^$ENV_NAME "; then
    echo "  Ambiente '$ENV_NAME' já existe. A atualizar pacotes..."
else
    conda create -n "$ENV_NAME" python="$PYTHON_VERSION" -y
fi

install_packages "$ENV_NAME" \
    "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y

# ── 4. Verificação ─────────────────────────────────────────────────────────────
echo "[4/4] A verificar instalação..."
conda run -n "$ENV_NAME" python - <<'EOF'
import pyspark
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local").appName("test").getOrCreate()
spark.stop()
print(f"  PySpark {pyspark.__version__} — OK")
EOF

echo ""
echo "=== Instalação concluída ==="
echo ""
if [[ "$FORCE_MINICONDA" == true ]]; then
    echo "Para iniciar o JupyterLab nesta sessão:"
    echo "  source ~/miniconda3/etc/profile.d/conda.sh"
    echo "  conda activate $ENV_NAME"
    echo "  jupyter lab"
    echo ""
    echo "Ou usar o script de arranque:"
    echo "  bash install/start_pyspark.sh"
else
    echo "Para iniciar o JupyterLab:"
    echo "  conda activate $ENV_NAME"
    echo "  jupyter lab"
fi
