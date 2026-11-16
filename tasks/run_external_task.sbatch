#!/bin/bash
#SBATCH --account=YOUR_OTHER_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --output=slurm_logs/%x-%j.log

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
cd ${REPO_DIR:-$PWD}

TASK_NAME="$1"
MODEL_ID="$2"
MODE="$3"
TRIALS="${4:-}"

echo "=================================================="
echo "Node:  $(hostname)"
echo "Time:  $(date)"
echo "Task:  $TASK_NAME | Model: $MODEL_ID | Mode: $MODE | Trials: ${TRIALS:-default}"
echo "=================================================="
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

"$ENV/bin/python" -m tasks.run_external_task "$TASK_NAME" "$MODEL_ID" "$MODE" $TRIALS

echo "=================================================="
echo "Done: $(date)"
echo "=================================================="
