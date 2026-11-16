#!/bin/bash
#SBATCH --job-name=qwen-jupyter
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=08:00:00
#SBATCH --output=slurm_logs/jupyter-%j.log

set -euo pipefail

ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
PORT=$(shuf -i 20000-29999 -n 1)

echo "=================================================="
echo "Node:  $(hostname)"
echo "Port:  ${PORT}"
echo "Time:  $(date)"
echo "=================================================="

source $HOME/miniconda3/etc/profile.d/conda.sh
conda activate "${ENV}"

nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

exec jupyter lab \
    --no-browser \
    --ip=0.0.0.0 \
    --port="${PORT}" \
    --notebook-dir=${REPO_DIR:-$PWD}
