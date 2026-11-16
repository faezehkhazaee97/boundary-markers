#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:titan:1
#SBATCH --cpus-per-task=6
#SBATCH --mem=48G
#SBATCH --time=10:00:00
#SBATCH --array=0-4%1
#SBATCH --output=slurm_logs/%x-%A_%a.log
# Evaluate a merged LoRA checkpoint (results/lora_separator/<tag>) on held-out tasks with the usual runners.
#   sbatch --job-name=evallora-<tag> scripts/eval_lora.sbatch <tag>
set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache HF_HUB_OFFLINE=1 PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
MODEL=results/lora_separator/$1
TASKS=(copy_previous sliding_window_max running_xor random_permutation_digits running_sum_local)
TASK=${TASKS[$SLURM_ARRAY_TASK_ID]}
echo "Node: $(hostname) | $MODEL | $TASK | $(date)"
if [ "$TASK" = random_permutation_digits ]; then "$ENV/bin/python" -m tasks.run_digit_controls "$TASK" "$MODEL" 20
else "$ENV/bin/python" -m tasks.run_task "$TASK" "$MODEL" grid 20; fi
echo "Done: $(date)"
