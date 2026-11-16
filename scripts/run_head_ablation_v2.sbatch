#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT          # group allocation
#SBATCH --partition=YOUR_GPU_PARTITION        # 32B needs an A100; 7B is submitted to YOUR_GPU_PARTITION (Titan) by the caller
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=110G
#SBATCH --time=08:00:00               # ~2 h expected at 32B (about 1,100 generations); resumable
#SBATCH --output=slurm_logs/%x-%j.log

# Head ablation v2 (scripts/run_head_ablation_v2.py): merged letters vs spaced letters vs
# digits, random_permutation A=8, N in {32, 64}, k in {2, 8}, with random-head and
# sham-position controls.
#   sbatch --job-name=ablation-<tag> scripts/run_head_ablation_v2.sbatch <hf_model_id>
set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
export HF_HUB_OFFLINE=1
export PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
echo "Node: $(hostname) | Model: $1 | $(date)"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
"$ENV/bin/python" scripts/run_head_ablation_v2.py --model "$1" "${@:2}"
echo "Done: $(date)"
