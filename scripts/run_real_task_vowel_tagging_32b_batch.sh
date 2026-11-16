#!/bin/bash
#SBATCH --job-name=vowel-tagging-realtask-32b
#SBATCH --account=YOUR_OTHER_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=80G
#SBATCH --time=01:30:00
#SBATCH --output=slurm_logs/vowel-tagging-realtask-32b-%j.log

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
cd ${REPO_DIR:-$PWD}

echo "=================================================="
echo "Node:  $(hostname)"
echo "Time:  $(date)"
echo "=================================================="
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

"$ENV/bin/python" scripts/run_real_task_vowel_tagging_32b.py

echo "=================================================="
echo "Done: $(date)"
echo "=================================================="
