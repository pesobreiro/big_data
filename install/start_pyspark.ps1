# Inicia o JupyterLab com o ambiente bigdata no Windows.
# Uso: .\install\start_pyspark.ps1

$ENV_NAME = "bigdata"
$MINICONDA_DIR = "$env:USERPROFILE\miniconda3"

# Tentar encontrar o conda
$condaFound = $false
if (Get-Command conda -ErrorAction SilentlyContinue) {
    $condaFound = $true
} else {
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
            $condaFound = $true
            break
        }
    }
}

if (-not $condaFound) {
    Write-Host "ERRO: conda não encontrado. Correr primeiro: .\install\windows_install.ps1" -ForegroundColor Red
    exit 1
}

conda activate $ENV_NAME

# Garantir JAVA_HOME se não estiver definido
if (-not $env:JAVA_HOME) {
    if ($env:CONDA_PREFIX -and (Test-Path "$env:CONDA_PREFIX\Library\bin\java.exe")) {
        $env:JAVA_HOME = "$env:CONDA_PREFIX\Library"
        Write-Host "[INFO] JAVA_HOME auto-definido: $env:JAVA_HOME" -ForegroundColor Yellow
    } else {
        Write-Host "AVISO: JAVA_HOME não está definido. O PySpark pode falhar." -ForegroundColor Red
        Write-Host "  -> Garante que o ambiente 'bigdata' está ativo: conda activate bigdata" -ForegroundColor Red
    }
}

$projectDir = Split-Path -Parent $PSScriptRoot
jupyter lab --notebook-dir="$projectDir"
