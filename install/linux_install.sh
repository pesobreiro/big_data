#!/usr/bin/env bash
# Instalação do ambiente PySpark no Linux (Ubuntu/Debian e outras distribuições)
#
# Uso normal (usa Anaconda ou Miniconda já instalado):
#   bash install/linux_install.sh
#
# Forçar Miniconda separado (quando Anaconda está instalado mas com problemas,
# ou para não interferir com Orange / outras ferramentas):
#   bash install/linux_install.sh --miniconda

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

echo "=== Instalação PySpark — Linux ==="
[[ "$FORCE_MINICONDA" == true ]] && echo "  (modo: Miniconda separado)"
echo ""

# ── Função: localizar conda (Anaconda ou Miniconda) ────────────────────────────
find_conda() {
    if command -v conda &>/dev/null; then return 0; fi
    for dir in \
        "$HOME/anaconda3" "$HOME/anaconda" "/opt/anaconda3" "/usr/local/anaconda3" \
        "$HOME/miniconda3" "$HOME/miniconda" "/opt/miniconda3" "/opt/conda"
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

install_miniconda() {
    local ARCH
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    elif [[ "$ARCH" == "aarch64" ]]; then
        URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
    else
        echo "ERRO: arquitetura '$ARCH' não suportada." >&2
        exit 1
    fi
    local INSTALLER="/tmp/miniconda_install.sh"
    curl -fsSL "$URL" -o "$INSTALLER"
    bash "$INSTALLER" -b -p "$MINICONDA_DIR"
    rm -f "$INSTALLER"
    source "$MINICONDA_DIR/etc/profile.d/conda.sh"
}

# ── 1. Dependências do sistema ─────────────────────────────────────────────────
echo "[1/4] A verificar dependências do sistema..."
if command -v apt-get &>/dev/null; then
    sudo apt-get install -y --no-install-recommends curl wget ca-certificates 2>/dev/null || true
fi

# ── 2. Conda ───────────────────────────────────────────────────────────────────
if [[ "$FORCE_MINICONDA" == true ]]; then
    if use_miniconda; then
        echo "[2/4] Miniconda já instalado em $MINICONDA_DIR — ok"
    else
        echo "[2/4] A instalar Miniconda em $MINICONDA_DIR (sem alterar o Anaconda)..."
        install_miniconda
        # NÃO corremos conda init — o Anaconda continua a ser o conda do sistema
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
        install_miniconda
        "$MINICONDA_DIR/bin/conda" init bash
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

# ── 3.5. Verificar JAVA_HOME ──────────────────────────────────────────────────
ENV_PATH=$(conda env list | grep "^$ENV_NAME " | awk '{print $2}')
if [[ -f "$ENV_PATH/bin/java" ]]; then
    # openjdk moderno (conda-forge): JAVA_HOME=$CONDA_PREFIX, java em $CONDA_PREFIX/bin/java
    echo "  Java detetado em $ENV_PATH/bin/java (openjdk_activate.sh configura JAVA_HOME automaticamente)"
elif [[ -d "$ENV_PATH/lib/jvm" ]]; then
    # path legado — criar script de ativação caso o openjdk não o tenha criado
    echo "  Java detetado em $ENV_PATH/lib/jvm"
    if [[ ! -f "$ENV_PATH/etc/conda/activate.d/openjdk_activate.sh" ]]; then
        mkdir -p "$ENV_PATH/etc/conda/activate.d" "$ENV_PATH/etc/conda/deactivate.d"
        echo 'export JAVA_HOME="$CONDA_PREFIX/lib/jvm"' > "$ENV_PATH/etc/conda/activate.d/java_home.sh"
        echo 'unset JAVA_HOME' > "$ENV_PATH/etc/conda/deactivate.d/java_home.sh"
        echo "  Scripts de ativação do Java criados."
    fi
else
    echo "  AVISO: Java não detetado no ambiente. A instalação pode ter falhado." >&2
fi

# ── 4. Verificação ─────────────────────────────────────────────────────────────
echo "[4/5] A verificar instalação..."
conda run -n "$ENV_NAME" python - <<'EOF'
import pyspark
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local").appName("test").getOrCreate()
spark.stop()
print(f"  PySpark {pyspark.__version__} — OK")
EOF

# ── 5. Instruções finais ───────────────────────────────────────────────────────
echo ""
echo "=== Instalação concluída ==="
echo ""
echo "IMPORTANTE: O ambiente conda deve estar ATIVO antes de usar o PySpark."
echo ""
if [[ "$FORCE_MINICONDA" == true ]]; then
    echo "Para iniciar o JupyterLab nesta sessão:"
    echo "  source ~/miniconda3/etc/profile.d/conda.sh"
    echo "  conda activate $ENV_NAME"
    echo "  jupyter lab"
    echo ""
    echo "Ou usar o script de arranque (ativa automaticamente):"
    echo "  bash install/start_pyspark.sh"
else
    echo "Para iniciar o JupyterLab:"
    echo "  conda activate $ENV_NAME"
    echo "  jupyter lab"
    echo ""
    echo "Ou usar o script de arranque (ativa automaticamente):"
    echo "  bash install/start_pyspark.sh"
fi
echo ""
echo "Verificar a instalação:"
echo "  conda activate $ENV_NAME"
echo "  python install/verify_install.py"
