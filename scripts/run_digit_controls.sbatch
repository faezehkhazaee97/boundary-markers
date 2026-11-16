#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT          # group allocation
#SBATCH --partition=YOUR_GPU_PARTITION        # launcher adds YOUR_GPU_PARTITION (Titan) for the small models
#SBATCH --gres=gpu:a100:1             # launcher uses an untyped gpu:1 for the small models
#SBATCH --cpus-per-task=8
#SBATCH --mem=110G
#SBATCH --time=08:00:00               # ~1-2 h per task at 27-32B; launcher shortens for small models
#SBATCH --array=0-2%1                 # the three digit tasks, one at a time per model
#SBATCH --output=slurm_logs/%x-%A_%a.log

# Tokenization controls for the three position-local tasks: digit-alphabet (FAMILY=digits,
# default) or spaced-letter (FAMILY=spaced) versions.
#   sbatch --job-name=<family>-<tag> scripts/run_digit_controls.sbatch <hf_model_id> [digits|spaced]

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
export HF_HUB_OFFLINE=1
export PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}

MODEL_ID="$1"
FAMILY="${2:-digits}"
TASKS=(cyclic_shift_$FAMILY random_permutation_$FAMILY conditional_shift_$FAMILY)
TASK="${TASKS[$SLURM_ARRAY_TASK_ID]}"
echo "Node: $(hostname) | Model: $MODEL_ID | Task: $TASK | $(date)"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
"$ENV/bin/python" -m tasks.run_digit_controls "$TASK" "$MODEL_ID" 20
echo "Done: $(date)"
