#!/bin/bash
#SBATCH --job-name=job-a2-32b
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=15:00:00
#SBATCH --output=slurm_logs/job-a2-%j.log

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
cd ${REPO_DIR:-$PWD}

echo "=================================================="
echo "JOB A2: YOUR_ACCOUNT A100 #1 - Running XOR 32B + Modsum 32B"
echo "Start Time: $(date)"
echo "=================================================="
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

echo ""
echo "========== RUNNING XOR 32B =========="
sed 's/MODEL_ID = "Qwen\/Qwen2.5-7B-Instruct"/MODEL_ID = "Qwen\/Qwen2.5-32B-Instruct"/' scripts/run_running_xor_structured_boundaries.py > /tmp/xor_32b.py
"$ENV/bin/python" /tmp/xor_32b.py

echo ""
echo "========== MODSUM 32B =========="
"$ENV/bin/python" scripts/run_modsum_modulus_sweep.py "Qwen/Qwen2.5-32B-Instruct"

echo ""
echo "=================================================="
echo "JOB A2 COMPLETE: $(date)"
echo "=================================================="
