# Guia de Instalação — PySpark

Scripts de instalação automática do ambiente PySpark para Mac, Windows e Linux.

## Ficheiros disponíveis

| Ficheiro | Sistema | Descrição |
|----------|---------|-----------|
| `mac_install.sh` | macOS | Deteta Anaconda/Miniconda existente; instala se necessário |
| `linux_install.sh` | Linux (Ubuntu/Debian) | Deteta Anaconda/Miniconda existente; instala se necessário |
| `windows_install.ps1` | Windows 10/11 | Deteta Anaconda/Miniconda existente; instala se necessário |
| `verify_install.py` | Todos | Verifica se o ambiente está funcional |

O ambiente criado chama-se `bigdata` e inclui:

- Python 3.11
- OpenJDK 17 (Java — necessário para o PySpark)
- PySpark 3.x
- JupyterLab
- PyArrow

## Anaconda já instalado?

**Os scripts funcionam com Anaconda ou Miniconda — não é necessário instalar nada de novo.**

Se já tiveres Anaconda ou Miniconda instalado, o script deteta-o automaticamente nos
caminhos mais comuns (ex: `~/anaconda3`, `~/miniconda3`, `C:\Anaconda3`, etc.) e avança
diretamente para a criação do ambiente `bigdata`.

Se o `conda` não estiver no PATH mas a instalação existir, o script localiza-a e
carrega-a para a sessão atual.

Caminhos verificados automaticamente:

**Mac / Linux:** `~/anaconda3`, `~/anaconda`, `/opt/anaconda3`, `~/miniconda3`, `/opt/miniconda3`, `/opt/conda`

**Windows:** `%USERPROFILE%\anaconda3`, `%USERPROFILE%\Anaconda3`, `%LOCALAPPDATA%\anaconda3`, `C:\ProgramData\Anaconda3`, `C:\Anaconda3`, `%USERPROFILE%\miniconda3`, `C:\miniconda3`

---

## macOS

### Pré-requisitos

- macOS 12 (Monterey) ou superior
- Terminal (zsh — padrão desde macOS Catalina)

### Passos

```bash
# 1. Clonar o repositório
git clone <url-do-repositorio>
cd big_data

# 2. Correr o script de instalação
bash install/mac_install.sh
```

O script deteta se o Homebrew e o Miniconda já estão instalados e evita reinstalações.
Se o Miniconda for instalado pela primeira vez, o script pede para fechar e reabrir
o terminal e depois correr novamente.

### Nota Apple Silicon (M1/M2/M3)

O script deteta automaticamente a arquitetura `arm64` e configura o Homebrew no
caminho correto (`/opt/homebrew`).

---

## Linux (Ubuntu / Debian)

### Pré-requisitos

- Ubuntu 20.04+ ou Debian 11+
- `curl` ou `wget` instalado (`sudo apt-get install -y curl`)

### Passos

```bash
# 1. Clonar o repositório
git clone <url-do-repositorio>
cd big_data

# 2. Correr o script de instalação
bash install/linux_install.sh
```

Se o Miniconda for instalado pela primeira vez, o script pede para fechar e reabrir
o terminal e depois correr novamente.

### Outras distribuições Linux

O script funciona em qualquer distribuição Linux com `bash`. Em distribuições não-Debian
(Fedora, Arch, etc.), ignorar a parte `apt-get` — apenas o Miniconda é necessário.

```bash
# Instalar Miniconda manualmente em qualquer distribuição
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
$HOME/miniconda3/bin/conda init bash
# Fechar e reabrir o terminal, depois:
bash install/linux_install.sh
```

---

## Windows

### Pré-requisitos

- Windows 10 (20H2+) ou Windows 11
- PowerShell 5.1+ (já incluído no Windows)
- `winget` (já incluído no Windows 10 20H2+ e Windows 11)

### Passos

```powershell
# 1. Abrir PowerShell (não é necessário ser Administrador)

# 2. Permitir execução de scripts (apenas uma vez)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Navegar para a pasta do projeto
cd big_data

# 4. Correr o script de instalação
.\install\windows_install.ps1
```

Se o Miniconda for instalado pela primeira vez, o script pede para **reiniciar o
PowerShell** e correr novamente.

### Usar o Anaconda Prompt (alternativa)

Após instalar o Miniconda, pode-se usar o **Anaconda Prompt** em vez do PowerShell
— o `conda` já está configurado:

```
conda activate bigdata
jupyter lab
```

### Problema: `conda` não reconhecido no PowerShell

Se o PowerShell não reconhecer `conda` após a instalação:

```powershell
# Inicializar conda para PowerShell (correr uma única vez)
$HOME\miniconda3\Scripts\conda init powershell
# Fechar e reabrir o PowerShell
```

### Problema: `JAVA_HOME` não definido

Se o PySpark falhar com erro Java mesmo após a instalação:

```powershell
conda activate bigdata
$env:JAVA_HOME = "$env:CONDA_PREFIX\Library"
jupyter lab
```

Para tornar permanente, adicionar ao perfil do PowerShell:

```powershell
notepad $PROFILE
# Adicionar a linha:
# $env:JAVA_HOME = "$env:CONDA_PREFIX\Library"
```

---

## VS Code — Extensões recomendadas

O VS Code permite abrir e correr notebooks `.ipynb` diretamente, sem browser,
e também ligar a um servidor JupyterLab externo.

### Extensões essenciais

| Extensão | ID | Para quê |
|----------|----|---------|
| Python | `ms-python.python` | Suporte Python, seleção de interpreter/kernel |
| Jupyter | `ms-toolsai.jupyter` | Abrir e correr notebooks `.ipynb` no VS Code |
| Jupyter Keymap | `ms-toolsai.jupyter-keymap` | Atalhos de teclado estilo Jupyter |
| Jupyter Cell Tags | `ms-toolsai.jupyter-celltags` | Tags de células (usado em slides e testes) |

Instalar todas de uma vez no terminal:

```bash
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension ms-toolsai.jupyter-keymap
code --install-extension ms-toolsai.jupyter-celltags
```

### Selecionar o kernel do ambiente `bigdata`

1. Abrir um notebook `.ipynb` no VS Code
2. Clicar em **Select Kernel** (canto superior direito)
3. Escolher **Python Environments...**
4. Selecionar o ambiente **bigdata** (Python 3.11)

Se o ambiente não aparecer, garantir que o ambiente conda está ativo e o `ipykernel` instalado:

```bash
conda activate bigdata
python -m ipykernel install --user --name bigdata --display-name "Python (bigdata)"
```

Depois reiniciar o VS Code e repetir a seleção do kernel.

### Ligar ao JupyterLab a correr (servidor externo)

Se o JupyterLab já estiver a correr (`jupyter lab`), é possível ligar o VS Code ao mesmo servidor:

1. Copiar o URL do JupyterLab (ex: `http://localhost:8888/lab?token=...`)
2. No VS Code, abrir um notebook
3. Clicar em **Select Kernel** → **Existing Jupyter Server...**
4. Colar o URL

Desta forma o notebook corre no mesmo servidor que o JupyterLab — útil quando se usa Docker.

### Usar com Docker

Com o Docker a correr (`docker compose up`), ligar o VS Code ao servidor dentro do container:

1. Obter o token do container:

```bash
docker compose logs jupyter | grep "token="
```

2. No VS Code: **Select Kernel** → **Existing Jupyter Server...** → `http://localhost:8888/?token=<token>`

---

## Verificar a instalação (todas as plataformas)

Após instalar, confirmar que tudo funciona:

```bash
conda activate bigdata
python install/verify_install.py
```

Saída esperada:

```
=== Verificação do ambiente PySpark ===

  [OK] Python >= 3.9  (3.11.x)
  [OK] JAVA_HOME definido  (/path/to/conda/envs/bigdata/...)
  [OK] Pacote pyspark  (3.x.x)
  [OK] Pacote pyarrow  (x.x.x)
  [OK] Pacote jupyterlab  (x.x.x)
  [OK] SparkSession funcional  (SparkSession criada, contagem=10)

Ambiente OK — pode iniciar o JupyterLab com: jupyter lab
```

---

## Iniciar o JupyterLab

```bash
conda activate bigdata
jupyter lab
```

Abrir [http://localhost:8888](http://localhost:8888) no browser.
Os notebooks estão na pasta `notebooks/`.

---

## Resolução de problemas frequentes

| Problema | Causa provável | Solução |
|----------|---------------|---------|
| `conda: command not found` | conda não inicializado | Fechar/reabrir terminal ou correr `conda init` |
| `JAVA_HOME is not set` | Java não detetado | Ver secção Windows acima ou reinstalar com o script |
| `Port 8888 already in use` | Outro JupyterLab ativo | Correr `jupyter lab --port 8889` |
| PySpark demora a iniciar | Normal na primeira vez | Aguardar 30-60 segundos |
| `Permission denied` no Linux | Script sem permissão de execução | Usar `bash install/linux_install.sh` (não `./`) |
| `cannot import name '_builtin_table'` | PySpark < 3.5 com pandas 2.x | Ver secção abaixo |

### Remover e reinstalar o ambiente `bigdata` do zero

Quando há erros de pacotes, conflitos ou a instalação ficou incompleta, a solução mais
rápida é apagar o ambiente e recriar.

**Mac / Linux:**

```bash
conda deactivate
conda remove -n bigdata --all -y
conda create -n bigdata python=3.11 -y
mamba install -n bigdata -c conda-forge "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y
```

**Windows (PowerShell ou Anaconda Prompt):**

```powershell
conda deactivate
conda remove -n bigdata --all -y
conda create -n bigdata python=3.11 -y
mamba install -n bigdata -c conda-forge "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y
```

> Se `mamba` não estiver disponível: `conda install -n base -c conda-forge mamba -y`

Ou correr novamente o script de instalação — deteta que o ambiente não existe e recria-o:

```bash
bash install/mac_install.sh      # Mac
bash install/linux_install.sh    # Linux
.\install\windows_install.ps1    # Windows
```

Verificar o resultado:

```bash
conda activate bigdata
python install/verify_install.py
```

### Erro: `cannot import name '_builtin_table'`

Este erro ocorre quando o ambiente tem **PySpark 3.3 ou 3.4** com **pandas 2.x**. A API `pyspark.pandas` nestas versões não suporta pandas 2.0+. O PySpark 3.5+ corrige o problema.

Corrigir sem recriar o ambiente:

```bash
conda activate bigdata
conda install -c conda-forge "pyspark>=3.5" -y
```

Verificar versões após a atualização:

```bash
conda activate bigdata
python -c "import pyspark, pandas; print('PySpark', pyspark.__version__, '/ pandas', pandas.__version__)"
```

### Anaconda instalado + Orange noutra disciplina

Se tens **Anaconda instalado** para usar o **Orange** (mineração de dados) e o ambiente `bigdata` está a dar problemas, a forma mais limpa é manter **só o Miniconda** e instalar o Orange também como ambiente conda:

**Porquê Miniconda em vez de Anaconda?**

- Anaconda instala ~250 pacotes que frequentemente criam conflitos de versões (ex: pandas muito novo para PySpark antigo)
- Miniconda é minimalista — instala apenas o essencial, e cada ambiente fica isolado
- O Orange funciona como ambiente conda separado, sem interferir com o `bigdata`

**Instalar Orange no Miniconda:**

```bash
# Criar ambiente separado para Orange (não interferir com bigdata)
conda create -n orange python=3.10 -y
conda activate orange
conda install -c conda-forge orange3 -y
```

Para abrir o Orange:

```bash
conda activate orange
python -m Orange.canvas
```

Desta forma tens dois ambientes completamente isolados:
- `bigdata` → PySpark + JupyterLab
- `orange` → Orange Data Mining
