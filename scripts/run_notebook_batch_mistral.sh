#!/bin/bash
#SBATCH --job-name=mistral-notebook-run
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=10:00:00
#SBATCH --output=slurm_logs/notebook-run-mistral-%j.log

set -euo pipefail

ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache

cd ${REPO_DIR:-$PWD}

echo "=================================================="
echo "Node:  $(hostname)"
echo "Time:  $(date)"
echo "=================================================="
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

"$ENV/bin/jupyter" nbconvert \
    --to notebook \
    --execute \
    --output LLM-Focus-Mistral-executed.ipynb \
    --ExecutePreprocessor.timeout=-1 \
    --ExecutePreprocessor.kernel_name=qwen-focus \
    LLM-Focus-Mistral-input.ipynb

echo "=================================================="
echo "Done: $(date)"
echo "=================================================="
