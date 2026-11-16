#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --output=slurm_logs/%x-%j.log

# Generic launcher for any (task, model, mode) combination.
# Submit with explicit overrides, e.g.:
#   sbatch --job-name=verify-cyclic_shift-7b --mem=64G --time=00:30:00 \
#     tasks/run_task.sbatch cyclic_shift Qwen/Qwen2.5-7B-Instruct verify

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
cd ${REPO_DIR:-$PWD}

TASK_NAME="$1"
MODEL_ID="$2"
MODE="$3"
TRIALS="${4:-}"
TRIAL_START="${5:-}"

echo "=================================================="
echo "Node:  $(hostname)"
echo "Time:  $(date)"
echo "Task:  $TASK_NAME | Model: $MODEL_ID | Mode: $MODE | Trials: ${TRIALS:-default} | TrialStart: ${TRIAL_START:-0}"
echo "=================================================="
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

"$ENV/bin/python" -m tasks.run_task "$TASK_NAME" "$MODEL_ID" "$MODE" $TRIALS $TRIAL_START

echo "=================================================="
echo "Done: $(date)"
echo "=================================================="
