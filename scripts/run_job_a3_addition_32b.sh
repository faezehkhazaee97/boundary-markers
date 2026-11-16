#!/bin/bash
#SBATCH --job-name=job-a3-32b
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=10:00:00
#SBATCH --output=slurm_logs/job-a3-%j.log

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
cd ${REPO_DIR:-$PWD}

echo "=================================================="
echo "JOB A3: YOUR_ACCOUNT A100 #2 - Integer Addition 32B"
echo "Start Time: $(date)"
echo "=================================================="
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

echo ""
echo "========== INTEGER ADDITION 32B =========="
"$ENV/bin/python" scripts/run_addition_digit_range_sweep.py "Qwen/Qwen2.5-32B-Instruct"

echo ""
echo "=================================================="
echo "JOB A3 COMPLETE: $(date)"
echo "=================================================="
