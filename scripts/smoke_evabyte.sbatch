#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:titan:1
#SBATCH --cpus-per-task=6
#SBATCH --mem=48G
#SBATCH --time=00:40:00
#SBATCH --output=slurm_logs/%x-%j.log
# Smoke-test the byte-level EvaByte-SFT twice: with its Triton kernels, then with its PyTorch fallback.
#   sbatch --job-name=smoke-evabyte scripts/smoke_evabyte.sbatch
set -uo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache HF_HUB_OFFLINE=1 PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
echo "===== attempt A: triton kernels"
"$ENV/bin/python" scripts/smoke_evabyte.py evabyte/EvaByte-SFT 2>&1 | grep -vE "Warning|warn" | tail -12
echo "===== attempt B: pytorch fallback"
"$ENV/bin/python" scripts/smoke_evabyte.py evabyte/EvaByte-SFT --no-triton 2>&1 | grep -vE "Warning|warn" | tail -12
echo "Done: $(date)"
