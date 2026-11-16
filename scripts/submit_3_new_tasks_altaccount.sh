#!/bin/bash
# Submit 3 NEW tasks (20 trials each) to YOUR_OTHER_ACCOUNT on YOUR_GPU_PARTITION

set -e

echo "=================================================="
echo "Submitting 3 NEW tasks to YOUR_OTHER_ACCOUNT"
echo "Partition: YOUR_GPU_PARTITION (A100 GPU)"
echo "Model: Qwen2.5-7B-Instruct"
echo "Trials: 20 per config"
echo "=================================================="

cd "$(dirname "$0")"

echo ""
echo "[1/3] Submitting Character Substitution..."
JOB1=$(sbatch run_character_substitution_YOUR_OTHER_ACCOUNT_batch.sh | awk '{print $NF}')
echo "Job ID: $JOB1"

echo ""
echo "[2/3] Submitting Running XOR..."
JOB2=$(sbatch run_running_xor_YOUR_OTHER_ACCOUNT_batch.sh | awk '{print $NF}')
echo "Job ID: $JOB2"

echo ""
echo "[3/3] Submitting Running Sum (Local Window)..."
JOB3=$(sbatch run_running_sum_local_YOUR_OTHER_ACCOUNT_batch.sh | awk '{print $NF}')
echo "Job ID: $JOB3"

echo ""
echo "=================================================="
echo "All 3 jobs submitted to YOUR_OTHER_ACCOUNT!"
echo "=================================================="
echo "Job IDs: $JOB1, $JOB2, $JOB3"
echo ""
echo "Monitor with:"
echo "  squeue -u $USER"
echo "  squeue -A YOUR_OTHER_ACCOUNT"
echo ""
echo "Check logs:"
echo "  tail -f ../slurm_logs/char-sub-alt-$JOB1.log"
echo "  tail -f ../slurm_logs/running-xor-alt-$JOB2.log"
echo "  tail -f ../slurm_logs/running-sum-local-alt-$JOB3.log"
