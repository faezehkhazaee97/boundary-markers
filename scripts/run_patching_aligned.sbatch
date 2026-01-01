#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION        # Qwen2.5-32B (~65 GB in bf16) needs an 80 GB A100
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=110G
#SBATCH --time=24:00:00               # ~10,500 forward passes at 64 layers; resumable
#SBATCH --output=slurm_logs/%x-%j.log

# Position-aligned activation patching (scripts/run_patching_aligned.py): donor is the
# across-wording marked run, so marker placement, ground-truth answer and query token all match.
#   sbatch --job-name=patchalign-32B scripts/run_patching_aligned.sbatch Qwen/Qwen2.5-32B-Instruct
set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
export HF_HUB_OFFLINE=1
export PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
echo "Node: $(hostname) | Model: $1 | $(date)"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
"$ENV/bin/python" scripts/run_patching_aligned.py --model "$1" "${@:2}"
echo "Done: $(date)"
