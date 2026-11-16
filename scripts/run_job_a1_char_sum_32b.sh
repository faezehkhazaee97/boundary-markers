#!/bin/bash
#SBATCH --job-name=job-a1-32b
#SBATCH --account=YOUR_OTHER_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=15:00:00
#SBATCH --output=slurm_logs/job-a1-%j.log

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
cd ${REPO_DIR:-$PWD}

echo "=================================================="
echo "JOB A1: YOUR_OTHER_ACCOUNT A100 - Char Sub 32B + Running Sum 32B"
echo "Start Time: $(date)"
echo "=================================================="
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

echo ""
echo "========== CHAR SUB 32B =========="
"$ENV/bin/python" scripts/run_character_substitution_alphabet_sweep.py "Qwen/Qwen2.5-32B-Instruct"

echo ""
echo "========== RUNNING SUM LOCAL 32B =========="
"$ENV/bin/python" scripts/run_running_sum_local_modulus_sweep.py "Qwen/Qwen2.5-32B-Instruct"

echo ""
echo "=================================================="
echo "JOB A1 COMPLETE: $(date)"
echo "=================================================="
