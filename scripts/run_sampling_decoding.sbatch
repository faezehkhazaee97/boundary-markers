#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT          # group allocation
#SBATCH --partition=YOUR_GPU_PARTITION        # Qwen2.5-32B (~65 GB in bf16) needs an 80 GB A100
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=110G
#SBATCH --time=06:00:00               # ~1.5 h expected (720 generations); resumable
#SBATCH --output=slurm_logs/%x-%j.log

# Sampling instead of greedy decoding (scripts/run_sampling_decoding.py): three tasks,
# N in {32, 64}, no markers and "|" at k in {4, 16}, temperature 0.7 and 1.0.
#   sbatch --job-name=sampling-32B scripts/run_sampling_decoding.sbatch Qwen/Qwen2.5-32B-Instruct
set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
export HF_HUB_OFFLINE=1
export PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
echo "Node: $(hostname) | Model: $1 | $(date)"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
"$ENV/bin/python" scripts/run_sampling_decoding.py --model "$1" "${@:2}"
echo "Done: $(date)"
