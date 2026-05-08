#!/usr/bin/env bash
# Inicia o JupyterLab com o ambiente bigdata.
# Funciona mesmo que o Anaconda seja o conda padrão do sistema.
# Uso: bash install/start_pyspark.sh

set -euo pipefail

ENV_NAME="bigdata"

# Tentar encontrar o conda (Anaconda ou Miniconda)
for dir in \
    "" \
    "$HOME/miniconda3" "$HOME/anaconda3" "$HOME/anaconda" \
    "/opt/miniconda3" "/opt/anaconda3" "/opt/conda"
do
    if [[ -z "$dir" ]] && command -v conda &>/dev/null; then
        break
    elif [[ -n "$dir" ]] && [[ -f "$dir/bin/conda" ]]; then
        source "$dir/etc/profile.d/conda.sh"
        break
    fi
done

if ! command -v conda &>/dev/null; then
    echo "ERRO: conda não encontrado. Correr primeiro: bash install/mac_install.sh" >&2
    exit 1
fi

conda activate "$ENV_NAME"

# Garantir JAVA_HOME se não estiver definido (o conda deve definir via openjdk_activate.sh,
# mas serve de segurança se algo falhou)
if [[ -z "${JAVA_HOME:-}" ]] && [[ -n "${CONDA_PREFIX:-}" ]]; then
    if [[ -f "$CONDA_PREFIX/bin/java" ]]; then
        # openjdk moderno: JAVA_HOME=$CONDA_PREFIX
        export JAVA_HOME="$CONDA_PREFIX"
        echo "[INFO] JAVA_HOME auto-definido: $JAVA_HOME"
    elif [[ -d "$CONDA_PREFIX/lib/jvm" ]]; then
        # path legado
        export JAVA_HOME="$CONDA_PREFIX/lib/jvm"
        echo "[INFO] JAVA_HOME auto-definido: $JAVA_HOME"
    else
        echo "AVISO: JAVA_HOME não está definido. O PySpark pode falhar." >&2
        echo "  → Garante que o ambiente 'bigdata' está ativo: conda activate bigdata" >&2
    fi
fi

jupyter lab --notebook-dir="$(dirname "$(dirname "$0")")"
