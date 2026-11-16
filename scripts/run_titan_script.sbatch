#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT          # group allocation
#SBATCH --partition=YOUR_GPU_PARTITION              # the group's Titan RTX GPUs (24 GB): 7B-class models only
#SBATCH --gres=gpu:titan:1
#SBATCH --cpus-per-task=6
#SBATCH --mem=48G
#SBATCH --time=12:00:00
#SBATCH --output=slurm_logs/%x-%j.log

# Run one of the resumable scripts/run_*.py experiment scripts on a Titan.
#   sbatch --job-name=<name> scripts/run_titan_script.sbatch scripts/run_paired_inputs.py --model Qwen/Qwen2.5-7B-Instruct
set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
export HF_HUB_OFFLINE=1
export PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
echo "Node: $(hostname) | $* | $(date)"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
"$ENV/bin/python" "$@"
echo "Done: $(date)"
