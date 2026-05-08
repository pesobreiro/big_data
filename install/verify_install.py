"""
Verifica se o ambiente PySpark está corretamente instalado.
Uso: python install/verify_install.py
"""

import sys
import os
import shutil

CHECKS = []

def check(label, fn):
    try:
        result = fn()
        CHECKS.append(("OK", label, result or ""))
    except Exception as e:
        CHECKS.append(("FAIL", label, str(e)))

def find_conda_java():
    """Tenta encontrar o Java instalado no ambiente conda atual."""
    conda_prefix = os.environ.get("CONDA_PREFIX")
    if conda_prefix:
        candidates = [
            conda_prefix,                                          # Linux/Mac moderno: JAVA_HOME=$CONDA_PREFIX
            os.path.join(conda_prefix, "lib", "jvm"),             # Linux/Mac legado
            os.path.join(conda_prefix, "Library"),                 # Windows
        ]
        for candidate in candidates:
            java_bin = os.path.join(candidate, "bin", "java")
            if os.path.exists(java_bin) or os.path.exists(java_bin + ".exe"):
                return candidate
    return None

def find_system_java():
    """Tenta encontrar o Java no PATH do sistema."""
    java_path = shutil.which("java")
    if java_path:
        # java está em .../bin/java, JAVA_HOME é o diretório pai de bin
        return os.path.dirname(os.path.dirname(java_path))
    return None

# ── Python ────────────────────────────────────────────────────────────────────
check("Python >= 3.9", lambda: (
    f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    if sys.version_info >= (3, 9) else (_ for _ in ()).throw(RuntimeError(f"Python {sys.version} — requer 3.9+"))
))

# ── JAVA_HOME ─────────────────────────────────────────────────────────────────
def _java_home_check():
    java_home = os.environ.get("JAVA_HOME")
    if java_home:
        return java_home
    # Tentar auto-detetar
    conda_java = find_conda_java()
    if conda_java:
        os.environ["JAVA_HOME"] = conda_java
        return f"{conda_java} (auto-detetado do ambiente conda)"
    system_java = find_system_java()
    if system_java:
        os.environ["JAVA_HOME"] = system_java
        return f"{system_java} (auto-detetado do PATH)"
    raise RuntimeError(
        "JAVA_HOME não definido e Java não detetado.\n"
        "  → Garante que o ambiente conda 'bigdata' está ativo: conda activate bigdata\n"
        "  → Ou define JAVA_HOME manualmente (ver install/README.md)"
    )

check("JAVA_HOME definido", _java_home_check)

# ── Pacotes ───────────────────────────────────────────────────────────────────
for pkg in ["pyspark", "pyarrow", "jupyterlab"]:
    def _check(p=pkg):
        mod = __import__(p.replace("-", "_"))
        return getattr(mod, "__version__", "instalado")
    check(f"Pacote {pkg}", _check)

# ── SparkSession ──────────────────────────────────────────────────────────────
def _spark_check():
    from pyspark.sql import SparkSession
    spark = SparkSession.builder \
        .master("local") \
        .appName("verify") \
        .config("spark.ui.showConsoleProgress", "false") \
        .getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")
    df = spark.range(10)
    count = df.count()
    spark.stop()
    if count != 10:
        raise RuntimeError(f"Esperado 10 linhas, obtido {count}")
    return f"SparkSession criada, contagem={count}"

check("SparkSession funcional", _spark_check)

# ── Relatório ─────────────────────────────────────────────────────────────────
print("\n=== Verificação do ambiente PySpark ===\n")
all_ok = True
for status, label, detail in CHECKS:
    icon = "OK" if status == "OK" else "FAIL"
    line = f"  [{icon}] {label}"
    if detail:
        line += f"  ({detail})"
    print(line)
    if status != "OK":
        all_ok = False

print()
if all_ok:
    print("Ambiente OK — pode iniciar o JupyterLab com: jupyter lab")
else:
    print("Existem problemas. Consulta o README para instruções de resolução.")
    sys.exit(1)
