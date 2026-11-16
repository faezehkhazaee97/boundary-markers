#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT          # launcher overrides for the A100 job (YOUR_OTHER_ACCOUNT)
#SBATCH --partition=YOUR_GPU_PARTITION              # Titan GPUs; the YOUR_ACCOUNT A100 pool is left alone
#SBATCH --gres=gpu:titan:1
#SBATCH --cpus-per-task=6
#SBATCH --mem=48G
#SBATCH --time=10:00:00
#SBATCH --output=slurm_logs/%x-%j.log

# Budget-sensitivity rerun: the same grid under max_new_tokens = 2N+20 at every spacing,
# written to results_clean/<task>/grid_budget2n/<model>.csv (see tasks/rerun_budget2n.py).
#   sbatch --job-name=b2n-<tag> scripts/rerun_budget2n.sbatch <hf_model_id> <task> [task ...]

set -uo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache
export HF_HUB_OFFLINE=1               # the cached weights the original runs used
export PYTHONUNBUFFERED=1
export AB_GEN_BUDGET=2n               # the whole point of this job; default stays 1.5N+20
cd ${REPO_DIR:-$PWD}

MODEL_ID="$1"; shift
echo "Node: $(hostname) | Model: $MODEL_ID | Tasks: $* | $(date)"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
rc=0
for TASK in "$@"; do
  echo "===== $TASK $(date)"
  "$ENV/bin/python" -m tasks.rerun_budget2n "$TASK" "$MODEL_ID" 20 || rc=1
done
echo "Done: $(date) (rc=$rc)"
exit $rc
