#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:titan:1
#SBATCH --cpus-per-task=6
#SBATCH --mem=48G
#SBATCH --time=08:00:00
#SBATCH --output=slurm_logs/%x-%j.log
# Run several task grids on one model, one after another, with the standard runner.
#   sbatch --job-name=<name> scripts/run_variants.sbatch <model_id> <task> [<task> ...]
set -euo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache HF_HUB_OFFLINE=1 PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
MODEL=$1; shift
echo "Node: $(hostname) | $MODEL | $* | $(date)"
for TASK in "$@"; do
  echo "=== $TASK $(date)"
  "$ENV/bin/python" -m tasks.run_task "$TASK" "$MODEL" grid 20
done
echo "Done: $(date)"
