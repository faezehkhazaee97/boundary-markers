#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT          # group allocation (launcher may use YOUR_OTHER_ACCOUNT)
#SBATCH --partition=YOUR_GPU_PARTITION        # A100 80GB nodes
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G                     # earlier runs peaked under 2 GB host RAM
#SBATCH --time=06:00:00               # ~0.5-1.5 h per task at 27-32B
#SBATCH --array=0-3%1                 # four tasks, one at a time
#SBATCH --output=slurm_logs/%x-%A_%a.log

# Instruction-wording test for the post-marker blind spot (tasks/common/wording.py):
# copy_previous and sliding_window_max with "neutral" and "across" marker instructions (completes Table wording).
#   sbatch --job-name=wording2-<tag> scripts/run_wording_controls2.sbatch <hf_model_id>
set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
export HF_HUB_OFFLINE=1
export PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
MODEL_ID="$1"
TASKS=(copy_previous_neutral copy_previous_across sliding_window_max_neutral sliding_window_max_across)
TASK="${TASKS[$SLURM_ARRAY_TASK_ID]}"
echo "Node: $(hostname) | Model: $MODEL_ID | Task: $TASK | $(date)"
"$ENV/bin/python" -m tasks.run_digit_controls "$TASK" "$MODEL_ID" 20
echo "Done: $(date)"
