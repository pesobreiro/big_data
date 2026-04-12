import pandas as pd
import numpy as np
from pathlib import Path
import sys

# CONFIGURAÇÃO
DATA_DIR = "~/crypto_data"  # O seu caminho
CRASH_THRESHOLD = 0.30      # 30% de variação numa vela é considerado suspeito/erro
WARN_GAPS = True            # Avisar se houver buracos no tempo

# Cores para o terminal
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def check_file(filepath):
    filename = filepath.name
    print(f"{Colors.BOLD}Checking {filename}...{Colors.ENDC}", end=" ")
    
    try:
        df = pd.read_parquet(filepath)
        
        # 1. Normalizar nomes de colunas
        if 'open_time' in df.columns and 'timestamp' not in df.columns:
            df.rename(columns={'open_time': 'timestamp'}, inplace=True)
        
        if 'timestamp' not in df.columns:
            print(f"{Colors.FAIL}[FAIL] No timestamp column found!{Colors.ENDC}")
            return

        # Converter para datetime se necessário
        if not np.issubdtype(df['timestamp'].dtype, np.datetime64):
            df['timestamp'] = pd.to_datetime(df['timestamp'])

        df = df.sort_values('timestamp').reset_index(drop=True)
        total_rows = len(df)
        
        issues = []

        # ---------------------------------------------------------
        # CHECK 1: Dados Vazios ou Zeros
        # ---------------------------------------------------------
        zeros = (df[['open', 'high', 'low', 'close']] == 0).sum().sum()
        nans = df[['open', 'high', 'low', 'close']].isna().sum().sum()
        
        if zeros > 0: issues.append(f"{Colors.FAIL}Found {zeros} prices = 0.0{Colors.ENDC}")
        if nans > 0: issues.append(f"{Colors.FAIL}Found {nans} NaNs{Colors.ENDC}")

        # ---------------------------------------------------------
        # CHECK 2: Bad Ticks (Variação > Threshold)
        # ---------------------------------------------------------
        # Variação absoluta percentual face à vela anterior
        df['pct_change'] = df['close'].pct_change().abs()
        
        # Variação Intra-vela (High vs Low)
        df['intra_change'] = (df['high'] - df['low']) / df['low']
        
        bad_ticks = df[(df['pct_change'] > CRASH_THRESHOLD) | (df['intra_change'] > CRASH_THRESHOLD)]
        
        if not bad_ticks.empty:
            issues.append(f"{Colors.FAIL}Found {len(bad_ticks)} BAD TICKS (> {CRASH_THRESHOLD*100}%){Colors.ENDC}")
            # Mostrar os primeiros 3 erros
            for idx, row in bad_ticks.head(3).iterrows():
                date = row['timestamp']
                pct = max(row.get('pct_change', 0), row.get('intra_change', 0)) * 100
                issues.append(f"   -> {date}: Variation of {pct:.1f}% (Close: {row['close']})")

        # ---------------------------------------------------------
        # CHECK 3: Time Gaps (Buracos no tempo)
        # ---------------------------------------------------------
        if WARN_GAPS and total_rows > 1:
            # Calcular a diferença entre linhas
            time_diffs = df['timestamp'].diff().dropna()
            
            # Descobrir o timeframe mais comum (ex: 15 min)
            mode_diff = time_diffs.mode()[0]
            
            # Encontrar onde a diferença não é igual à moda
            gaps = time_diffs[time_diffs != mode_diff]
            
            if not gaps.empty:
                gap_count = len(gaps)
                issues.append(f"{Colors.WARNING}Found {gap_count} time gaps (Missing candles){Colors.ENDC}")
                # Exemplo de gap
                first_gap_idx = gaps.index[0]
                gap_date = df.loc[first_gap_idx, 'timestamp']
                issues.append(f"   -> First gap around {gap_date}")

        # ---------------------------------------------------------
        # RESULTADO FINAL
        # ---------------------------------------------------------
        if not issues:
            print(f"{Colors.OKGREEN}[OK]{Colors.ENDC} ({total_rows} candles, {df['timestamp'].min().date()} to {df['timestamp'].max().date()})")
        else:
            print(f"{Colors.WARNING}[ISSUES FOUND]{Colors.ENDC}")
            for issue in issues:
                print(f"   {issue}")
            print("-" * 40)

    except Exception as e:
        print(f"{Colors.FAIL}[ERROR]{Colors.ENDC} Could not read file: {e}")

def main():
    path = Path(DATA_DIR).expanduser()
    if not path.exists():
        print(f"Directory not found: {path}")
        return

    files = list(path.glob("btc*.parquet"))
    if not files:
        print("No .parquet files found.")
        return

    print(f"Scanning {len(files)} files in {path}...\n")
    
    for file in files:
        check_file(file)

if __name__ == "__main__":
    main()
