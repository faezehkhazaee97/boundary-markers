#!/bin/bash
#SBATCH --job-name=multitrial-attn
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=00:30:00
#SBATCH --output=slurm_logs/multitrial-attn-%j.log

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
cd ${REPO_DIR:-$PWD}

echo "=================================================="
echo "Node:  $(hostname)"
echo "Time:  $(date)"
echo "=================================================="
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

"$ENV/bin/python" scripts/multitrial_attention_figures.py

echo "=================================================="
echo "Done: $(date)"
echo "=================================================="
