#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT          # group allocation (4 A100s max at once)
#SBATCH --partition=YOUR_GPU_PARTITION        # A100 80GB nodes
#SBATCH --gres=gpu:a100:1             # one A100 holds a 27-31B model in bf16
#SBATCH --cpus-per-task=8
#SBATCH --mem=110G                    # same as the Qwen2.5-32B runs
#SBATCH --time=03:00:00               # includes the first-time weight download
#SBATCH --output=slurm_logs/%x-%j.log

# Smoke test for a newly added model: downloads the weights (first run only),
# runs cyclic_shift + copy_previous in verify mode (1 trial/cell), then
# validates the outputs. Exit status gates the full-grid array (afterok).
#   sbatch --job-name=smoke-<tag> scripts/run_new_model_smoke.sbatch <hf_model_id>

set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
cd ${REPO_DIR:-$PWD}

MODEL_ID="$1"
TAG="${MODEL_ID##*/}"
echo "Node: $(hostname) | Model: $MODEL_ID | $(date)"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

for TASK in cyclic_shift copy_previous; do
  START=$SECONDS
  "$ENV/bin/python" -m tasks.run_task "$TASK" "$MODEL_ID" verify
  echo "$TASK verify wall=$((SECONDS - START)) s"
done
"$ENV/bin/python" scripts/validate_new_model_smoke.py "$TAG"
echo "Done: $(date)"
