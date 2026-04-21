# 🚨 Playbook de Contingência — Alunos "Stuck"

Documento rápido de referência para resolver os problemas mais comuns durante a instalação e utilização do ambiente PySpark em aula. Cada cenário inclui **diagnóstico** (1 comando), **solução imediata** e **plano nuclear** (se nada funcionar).

---

## Índice de cenários

| # | Cenário (o que o aluno diz) | Prioridade |
|---|---------------------------|------------|
| 1 | "O script fica bloqueado em 'Solving environment' há imenso tempo" | 🔴 Alta |
| 2 | "Dá erro de Java / JAVA_HOME não definido" | 🔴 Alta |
| 3 | "O Jupyter abre mas o kernel morre / não aparece o ambiente bigdata" | 🔴 Alta |
| 4 | "O Spark demora eternidades a iniciar ou dá 'out of memory'" | 🟡 Média |
| 5 | "O conda não é reconhecido no terminal" | 🟡 Média |
| 6 | "Dá erro de pandas / 'cannot import name _builtin_table'" | 🟡 Média |
| 7 | "Estava a funcionar e agora deixou de funcionar" | 🟡 Média |
| 8 | "Não consigo instalar nada / não tenho permissões de admin" | 🟢 Baixa |
| 9 | "O Docker não arranca / dá erro" | 🟢 Baixa |
| 10 | "O VS Code não reconhece o kernel" | 🟡 Média |

---

## 1. Script bloqueado em "Solving environment"

**Sintoma:** O `conda install` ou script de instalação fica preso há mais de 5-10 minutos.

**Causa:** O solver clássico do `conda` é lento quando há muitos pacotes na base (especialmente se o aluno tem Anaconda completo com Orange).

### Diagnóstico
```bash
# Verificar se mamba está disponível
mamba --version
```

### Solução imediata — usar mamba
Parar o script (Ctrl+C) e correr manualmente com `mamba`:

```bash
conda install -n base -c conda-forge mamba -y
conda activate bigdata
mamba install -c conda-forge "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y
```

Se o `mamba` também demorar, usar o **modo `--miniconda`** do script (isola uma instalação limpa):
```bash
bash install/mac_install.sh --miniconda      # Mac
bash install/linux_install.sh --miniconda    # Linux
```

### Plano nuclear
```bash
# 1. Apagar o ambiente problemático
conda deactivate
conda remove -n bigdata --all -y

# 2. Reinstalar com mamba (se disponível) ou --miniconda
conda create -n bigdata python=3.11 -y
conda activate bigdata
mamba install -c conda-forge "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y
```

---

## 2. Erro de Java / JAVA_HOME não definido

**Sintoma:** `JAVA_HOME is not set`, `Java gateway process exited`, ou `RuntimeError: Java not found`.

**Causa:** O aluno não ativou o ambiente conda `bigdata` antes de correr o Jupyter/PySpark.

### Diagnóstico
```bash
conda activate bigdata
python install/verify_install.py
```

Se `JAVA_HOME` aparecer como `FAIL`, continuar abaixo.

### Solução imediata — ativar ambiente
```bash
conda activate bigdata
jupyter lab
```

**No Windows (PowerShell):**
```powershell
conda activate bigdata
$env:JAVA_HOME = "$env:CONDA_PREFIX\Library"
jupyter lab
```

**No VS Code:** garantir que o kernel selecionado é **Python (bigdata)** e não o Python base do sistema.

### Solução automática — usar script de arranque
Em vez de ativar manualmente, usar o script que faz tudo:

```bash
bash install/start_pyspark.sh        # Mac / Linux
```

```powershell
.\install\start_pyspark.ps1         # Windows
```

### Plano nuclear — definir JAVA_HOME no notebook
Se nada funcionar, adicionar no **início do notebook** (antes de importar pyspark):

```python
import os
if not os.environ.get("JAVA_HOME"):
    conda_prefix = os.environ.get("CONDA_PREFIX", "")
    if os.path.exists(os.path.join(conda_prefix, "lib", "jvm", "bin", "java")):
        os.environ["JAVA_HOME"] = os.path.join(conda_prefix, "lib", "jvm")
    elif os.path.exists(os.path.join(conda_prefix, "Library", "bin", "java.exe")):
        os.environ["JAVA_HOME"] = os.path.join(conda_prefix, "Library")

import pyspark
```

---

## 3. Kernel morre / ambiente bigdata não aparece no Jupyter

**Sintoma:** Ao abrir um notebook no JupyterLab ou VS Code, o kernel morre imediatamente ou o ambiente `bigdata` não aparece na lista de kernels.

### Diagnóstico
```bash
conda activate bigdata
jupyter kernelspec list
```

Deve aparecer `bigdata` ou `python3` apontando para o ambiente correto.

### Solução imediata — registar kernel manualmente
```bash
conda activate bigdata
python -m ipykernel install --user --name bigdata --display-name "Python (bigdata)"
```

Reiniciar o JupyterLab / VS Code.

### Solução alternativa — correr sem kernelspec externo
```bash
conda activate bigdata
jupyter lab
```

No VS Code: **Select Kernel** → **Python Environments...** → escolher o caminho direto do Python do ambiente (ex: `~/anaconda3/envs/bigdata/bin/python`).

### Plano nuclear
```bash
conda activate bigdata
pip install --force-reinstall ipykernel
python -m ipykernel install --user --name bigdata --display-name "Python (bigdata)"
```

---

## 4. Spark lento ou "out of memory"

**Sintoma:** `java.lang.OutOfMemoryError`, ou o Spark demora 5+ minutos a criar a sessão.

**Causa:** RAM insuficiente (< 4GB), ou o Java está a alocar pouca memória por defeito.

### Diagnóstico
Verificar RAM disponível:
```bash
# Linux/Mac
free -h

# Windows
systeminfo | findstr "Total Physical Memory"
```

### Solução imediata — limitar memória do Spark
No início do notebook, configurar a sessão com menos memória:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Aula") \
    .config("spark.driver.memory", "2g") \
    .config("spark.executor.memory", "2g") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()
```

Para computadores muito lentos, usar **1g** em vez de **2g**.

### Workaround — usar sample dos dados
Em vez de carregar o dataset completo:

```python
df = spark.read.parquet("../data/btc_04h_usdt_binance.parquet").sample(fraction=0.1, seed=42)
```

---

## 5. Conda não reconhecido no terminal

**Sintoma:** `conda: command not found` depois de instalar o Miniconda.

### Diagnóstico
```bash
ls ~/miniconda3/bin/conda 2>/dev/null || echo "Miniconda não encontrado"
```

### Solução imediata — inicializar shell

**Mac / Linux:**
```bash
~/miniconda3/bin/conda init bash    # Linux (bash)
~/miniconda3/bin/conda init zsh     # Mac (zsh)
```

**Windows — PowerShell:**
```powershell
$HOME\miniconda3\Scripts\conda init powershell
```

**Windows — CMD (linha de comandos):**
```cmd
%USERPROFILE%\miniconda3\Scripts\conda init cmd.exe
```

> **⚠️ Importante:** Depois de correr o `conda init`, é obrigatório **fechar e reabrir o terminal** (ou reiniciar o PowerShell/CMD).

### Solução temporária (sem reiniciar terminal)

**Mac / Linux:**
```bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate bigdata
```

**Windows — PowerShell:**
```powershell
$env:PATH = "$HOME\miniconda3\Scripts;$HOME\miniconda3\condabin;$env:PATH"
conda activate bigdata
```

**Windows — CMD:**
```cmd
set PATH=%USERPROFILE%\miniconda3\Scripts;%USERPROFILE%\miniconda3\condabin;%PATH%
conda activate bigdata
```

---

## 6. Erro de pandas / `_builtin_table`

**Sintoma:** `cannot import name '_builtin_table' from 'pandas.core.common'`.

**Causa:** O código usa `import pyspark.pandas as ps`, que é incompatível com pandas 2.x.

### Solução imediata
**Nunca usar** `pyspark.pandas`. Substituir no notebook:

```python
# ❌ NÃO usar
import pyspark.pandas as ps

# ✅ Usar sempre
pandas_df = spark_df.toPandas()
```

Os notebooks deste projeto já estão corrigidos. Se o aluno copiou código antigo da internet, substituir.

---

## 7. Estava a funcionar e agora deixou de funcionar

**Sintoma:** Ontem funcionava, hoje dá erro ao importar pyspark ou iniciar sessão.

**Causas comuns:**
- Abriu o terminal/VS Code numa pasta diferente
- O ambiente conda foi alterado (outro grupo usou o computador)
- Atualização automática de pacotes quebrou dependências

### Diagnóstico
```bash
conda activate bigdata
python install/verify_install.py
```

### Solução imediata — verificar ambiente ativo
```bash
which python          # Mac/Linux
where python          # Windows
```

Deve apontar para `.../envs/bigdata/bin/python`. Se apontar para outro lado:
```bash
conda activate bigdata
```

### Plano nuclear — recriar ambiente
```bash
conda deactivate
conda remove -n bigdata --all -y
bash install/linux_install.sh   # ou mac_install.sh / windows_install.ps1
```

---

## 8. Sem permissões de admin / instalação bloqueada

**Sintoma:** Erros de `Permission denied`, `Access denied`, ou instalações corporativas/universitárias que bloqueiam software.

### Solução imediata — Miniconda em modo user
O Miniconda instala por defeito na pasta do utilizador (`$HOME/miniconda3` ou `%USERPROFILE%\miniconda3`), **não requer admin**.

Se o script de instalação falhar, instalar manualmente:

```bash
# Mac/Linux
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-$(uname)-$(uname -m).sh
bash Miniconda3-latest-*.sh -b -p $HOME/miniconda3
source $HOME/miniconda3/etc/profile.d/conda.sh
conda create -n bigdata python=3.11 -y
conda activate bigdata
conda install -c conda-forge mamba -y
mamba install -c conda-forge "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y
```

### Workaround — Google Colab
Se não for possível instalar nada localmente:

1. Aceder a [colab.research.google.com](https://colab.research.google.com)
2. Fazer upload do notebook
3. Na primeira célula:
```python
!pip install pyspark
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("Colab").getOrCreate()
```
4. Fazer upload dos ficheiros `.parquet` para o ambiente do Colab (painel esquerdo → 📁 → upload)

---

## 9. Docker não arranca

**Sintoma:** `docker: command not found`, `Cannot connect to Docker daemon`, ou o container Jupyter não inicia.

### Diagnóstico
```bash
docker run hello-world
```

### Solução imediata
1. **Verificar se o Docker Desktop está em execução** (Mac/Windows) — clicar no ícone e aguardar o "engine running"
2. **Linux:** garantir que o utilizador está no grupo `docker`:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```
3. **Windows:** usar `docker-compose` (com hífen) em vez de `docker compose` se a versão for antiga

### Plano nuclear — usar Conda diretamente
Se o Docker não funcionar, saltar diretamente para a **Opção 3 (Conda)** do README principal.

---

## 10. VS Code não reconhece o kernel bigdata

**Sintoma:** No VS Code, ao abrir um `.ipynb`, aparecem apenas kernels do Python base ou do sistema.

### Diagnóstico
```bash
conda activate bigdata
python -m ipykernel install --user --name bigdata --display-name "Python (bigdata)"
jupyter kernelspec list
```

### Solução imediata
1. No VS Code, clicar em **Select Kernel** (canto superior direito)
2. Escolher **Python Environments...**
3. Selecionar **bigdata** (ou o caminho direto `~/anaconda3/envs/bigdata/bin/python`)

Se não aparecer, reiniciar o VS Code completamente (Command Palette → `Developer: Reload Window`).

### Solução alternativa — ligar a servidor JupyterLab externo
1. No terminal: `conda activate bigdata && jupyter lab`
2. Copiar o URL com token
3. No VS Code: **Select Kernel** → **Existing Jupyter Server...** → colar o URL

---

## 🛟 Workaround universal: Google Colab

Se **nenhuma** das soluções acima funcionar num computador específico, o Google Colab é o plano de fuga imediato:

```python
# Célula 1 — instalar PySpark
!pip install pyspark

# Célula 2 — iniciar sessão
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("Colab").getOrCreate()

# Célula 3 — upload dos dados (menu esquerdo → 📁 → upload)
df = spark.read.parquet("/content/btc_04h_usdt_binance.parquet")
```

**Limitações:**
- RAM limitada (~12GB, mas partilhada)
- Sessão expira após ~90 min de inatividade
- Não é ideal para datasets muito grandes
- Para trabalho de grupo, cada aluno precisa de fazer upload dos dados

---

## 📋 Checklist rápido

Antes:
- [ ] Verificar que o repositório clona corretamente (`git clone ...`)
- [ ] Correr `python install/verify_install.py` no teu ambiente
- [ ] Ter o link do Colab pronto como backup

Depois:
1. **Perguntar primeiro:** "Correste `conda activate bigdata`?"
2. **Segundo:** "Correste `python install/verify_install.py`? O que diz?"
3. **Terceiro:** Apontar para o cenário correspondente neste playbook
4. **Nuclear:** "Apaga o ambiente e corre o script de novo" (leva < 3 min com mamba)
5. **Fuga:** Google Colab

---

*Última atualização: 2025/2026*
