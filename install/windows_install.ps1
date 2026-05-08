# Instalação do ambiente PySpark no Windows
#
# Uso normal (usa Anaconda ou Miniconda já instalado):
#   .\install\windows_install.ps1
#
# Forçar Miniconda separado (quando Anaconda está instalado mas com problemas,
# ou para não interferir com Orange / outras ferramentas):
#   .\install\windows_install.ps1 -Miniconda

param(
    [switch]$Miniconda   # instalar/usar Miniconda separado sem tocar no Anaconda
)

$ENV_NAME = "bigdata"
$PYTHON_VERSION = "3.11"
$MINICONDA_DIR = "$env:USERPROFILE\miniconda3"

Write-Host "=== Instalação PySpark — Windows ===" -ForegroundColor Cyan
if ($Miniconda) { Write-Host "  (modo: Miniconda separado)" -ForegroundColor Yellow }
Write-Host ""

# ── Função: localizar conda (Anaconda ou Miniconda) ────────────────────────────
function Find-Conda {
    if (Get-Command conda -ErrorAction SilentlyContinue) { return $true }
    $candidates = @(
        "$env:USERPROFILE\anaconda3", "$env:USERPROFILE\Anaconda3",
        "$env:LOCALAPPDATA\anaconda3", "$env:LOCALAPPDATA\Anaconda3",
        "C:\ProgramData\anaconda3",   "C:\ProgramData\Anaconda3",
        "C:\anaconda3",               "C:\Anaconda3",
        "$env:USERPROFILE\miniconda3","$env:USERPROFILE\Miniconda3",
        "$env:LOCALAPPDATA\miniconda3","C:\ProgramData\miniconda3",
        "C:\miniconda3"
    )
    foreach ($dir in $candidates) {
        if (Test-Path "$dir\Scripts\conda.exe") {
            $env:PATH = "$dir\Scripts;$dir\condabin;$dir;$env:PATH"
            Write-Host "  (conda encontrado em $dir)"
            return $true
        }
    }
    return $false
}

# ── Função: usar apenas o Miniconda separado ───────────────────────────────────
function Find-Miniconda {
    if (Test-Path "$MINICONDA_DIR\Scripts\conda.exe") {
        $env:PATH = "$MINICONDA_DIR\Scripts;$MINICONDA_DIR\condabin;$MINICONDA_DIR;$env:PATH"
        Write-Host "  (Miniconda encontrado em $MINICONDA_DIR)"
        return $true
    }
    return $false
}

# ── 1. Verificar winget ────────────────────────────────────────────────────────
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: winget não encontrado." -ForegroundColor Red
    Write-Host "  Instalar manualmente em: https://aka.ms/getwinget"
    exit 1
}
Write-Host "[1/4] winget disponível — ok" -ForegroundColor Green

# ── 2. Git ─────────────────────────────────────────────────────────────────────
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[2/4] A instalar Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget --silent
} else {
    Write-Host "[2/4] Git já instalado — ok" -ForegroundColor Green
}

# ── 3. Conda ───────────────────────────────────────────────────────────────────
if ($Miniconda) {
    if (Find-Miniconda) {
        $condaBase = conda info --base 2>$null
        Write-Host "[3/4] Miniconda já instalado em $condaBase — ok" -ForegroundColor Green
    } else {
        Write-Host "[3/4] A instalar Miniconda em $MINICONDA_DIR (sem alterar o Anaconda)..." -ForegroundColor Yellow
        winget install --id Anaconda.Miniconda3 -e --source winget --silent
        # Adicionar ao PATH desta sessão (SEM conda init para não sobrescrever Anaconda)
        $env:PATH = "$MINICONDA_DIR\Scripts;$MINICONDA_DIR\condabin;$MINICONDA_DIR;$env:PATH"
        Write-Host ""
        Write-Host "  Miniconda instalado em $MINICONDA_DIR" -ForegroundColor Green
        Write-Host "  O Anaconda (e o Orange) continuam sem alterações." -ForegroundColor Green
        Write-Host ""
        Write-Host "  ATENÇÃO: Reiniciar o PowerShell e correr novamente este script com -Miniconda." -ForegroundColor Yellow
        exit 0
    }
} else {
    if (Find-Conda) {
        $condaBase = conda info --base 2>$null
        Write-Host "[3/4] Conda já instalado em $condaBase — ok" -ForegroundColor Green
    } else {
        Write-Host "[3/4] Conda não encontrado. A instalar Miniconda..." -ForegroundColor Yellow
        winget install --id Anaconda.Miniconda3 -e --source winget --silent
        Write-Host ""
        Write-Host "  ATENÇÃO: Reiniciar o PowerShell e correr novamente este script." -ForegroundColor Yellow
        exit 0
    }
}

# ── 4. Ambiente conda ──────────────────────────────────────────────────────────
Write-Host "[4/4] A criar ambiente '$ENV_NAME'..." -ForegroundColor Yellow

# Garantir que mamba está disponível (evita bloqueio em "Solving environment")
if (-not (Get-Command mamba -ErrorAction SilentlyContinue)) {
    Write-Host "  A instalar mamba para resolver dependências mais rapidamente..." -ForegroundColor Yellow
    conda install -n base -c conda-forge mamba -y
}

$envExists = conda env list | Select-String "^$ENV_NAME\s"
if ($envExists) {
    Write-Host "  Ambiente '$ENV_NAME' já existe. A atualizar pacotes..." -ForegroundColor Yellow
} else {
    conda create -n $ENV_NAME python=$PYTHON_VERSION -y
}

mamba install -n $ENV_NAME -c conda-forge `
    "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y

# ── 4.5. Configurar JAVA_HOME persistente ─────────────────────────────────────
$envPath = (conda env list | Select-String "^$ENV_NAME\s").Line.Split()[-1]
if (Test-Path (Join-Path $envPath "Library\bin\java.exe")) {
    Write-Host "  Java detetado em $envPath\Library" -ForegroundColor Green
    # Criar scripts de ativação PowerShell (fallback)
    $activateDir = Join-Path $envPath "etc\conda\activate.d"
    $deactivateDir = Join-Path $envPath "etc\conda\deactivate.d"
    New-Item -ItemType Directory -Force -Path $activateDir | Out-Null
    New-Item -ItemType Directory -Force -Path $deactivateDir | Out-Null
    '$env:JAVA_HOME = "$env:CONDA_PREFIX\Library"' | Out-File -FilePath (Join-Path $activateDir "java_home.ps1") -Encoding utf8
    'Remove-Item Env:\JAVA_HOME -ErrorAction SilentlyContinue' | Out-File -FilePath (Join-Path $deactivateDir "java_home.ps1") -Encoding utf8
    # Também criar .bat para cmd/Anaconda Prompt
    'set JAVA_HOME=%CONDA_PREFIX%\Library' | Out-File -FilePath (Join-Path $activateDir "java_home.bat") -Encoding utf8
    'set JAVA_HOME=' | Out-File -FilePath (Join-Path $deactivateDir "java_home.bat") -Encoding utf8
    Write-Host "  Scripts de ativação do Java criados." -ForegroundColor Green
} else {
    Write-Host "  AVISO: Java não detetado no ambiente. A instalação pode ter falhado." -ForegroundColor Red
}

# ── 5. Verificação ─────────────────────────────────────────────────────────────
Write-Host "[5/5] A verificar instalação..." -ForegroundColor Yellow

$testScript = @"
import os, pyspark
from pyspark.sql import SparkSession
os.environ.setdefault('JAVA_HOME', os.path.join(os.environ.get('CONDA_PREFIX',''), 'Library'))
spark = SparkSession.builder.master('local').appName('test').getOrCreate()
spark.stop()
print(f'  PySpark {pyspark.__version__} — OK')
"@

conda run -n $ENV_NAME python -c $testScript

Write-Host ""
Write-Host "=== Instalação concluída ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANTE: O ambiente conda deve estar ATIVO antes de usar o PySpark." -ForegroundColor Yellow
Write-Host ""
if ($Miniconda) {
    Write-Host "Para iniciar o JupyterLab com Miniconda:"
    Write-Host "  conda activate $ENV_NAME"
    Write-Host "  jupyter lab"
    Write-Host ""
    Write-Host "Ou usar o script de arranque (ativa automaticamente):"
    Write-Host "  .\install\start_pyspark.ps1"
} else {
    Write-Host "Para iniciar o JupyterLab:"
    Write-Host "  conda activate $ENV_NAME"
    Write-Host "  jupyter lab"
    Write-Host ""
    Write-Host "Ou usar o script de arranque (ativa automaticamente):"
    Write-Host "  .\install\start_pyspark.ps1"
}
Write-Host ""
Write-Host "Verificar a instalação:"
Write-Host "  conda activate $ENV_NAME"
Write-Host "  python install\verify_install.py"
