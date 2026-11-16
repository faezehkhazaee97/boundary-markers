#!/bin/bash
#SBATCH --account=publicgrp
#SBATCH --partition=low
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=slurm_logs/%x-%j.log
# pyarrow lets pandas read the parquet files of public Hugging Face datasets (scripts/fetch_real_data.py).
set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
"$ENV/bin/pip" install --quiet "pyarrow>=17"
"$ENV/bin/python" -c "import pyarrow; print('pyarrow', pyarrow.__version__)"
