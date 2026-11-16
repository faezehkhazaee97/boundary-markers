#!/bin/bash
#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=YOUR_GPU_PARTITION
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=110G
#SBATCH --time=08:00:00
#SBATCH --output=slurm_logs/%x-%j.log
# Review follow-ups on one model: task:trials pairs run one after another with the standard runner.
#   sbatch --job-name=extras-32b scripts/run_review_extras.sbatch Qwen/Qwen2.5-32B-Instruct \
#       running_xor_echo:20 running_sum_local_echo:20 text_copy_previous_natural:80
set -uo pipefail
ENV=${REPO_DIR:-$PWD}/.conda/envs/qwen-focus
export HF_HOME=${REPO_DIR:-$PWD}/hf_cache HF_HUB_OFFLINE=1 PYTHONUNBUFFERED=1
cd ${REPO_DIR:-$PWD}
MODEL=$1; shift
echo "Node: $(hostname) | $MODEL | $* | $(date)"
for SPEC in "$@"; do
  TASK=${SPEC%%:*}; TRIALS=${SPEC##*:}
  echo "=== $TASK ($TRIALS trials per cell) $(date)"
  "$ENV/bin/python" -m tasks.run_task "$TASK" "$MODEL" grid "$TRIALS"
done
echo "Done: $(date)"
