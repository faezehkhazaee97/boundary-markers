# Re-Tokenization, Segmentation, and a Blind Spot: code and data

Code, prompts, raw generations, and analysis scripts for the anonymous submission "Re-Tokenization,
Segmentation, and a Blind Spot: What Content-Free Boundary Markers Do in Sequence Transformation".
Every prompt is rebuilt deterministically from (task, format, length N, marker spacing k, alphabet
or modulus, trial), so the result files store inputs and outputs but not prompts.

## Layout

| Path | Contents |
|---|---|
| `tasks/<task>/engine.py` | One task per folder: input generation, ground truth, marker insertion, prompt. `<task>_spaced` and `<task>_digits` are the tokenization controls (spaced letters; digits), exact reformattings of the letter tasks; `<task>_reset` are the reset variants of the dependency tasks. |
| `tasks/common/` | Shared runner (`runner.py`, including the generation budget `max_new_tokens`), scoring, the spaced-format wrapper (`spaced.py`), analysis modules, Gemini client, vendored ProcBench and CLRS code (with their licenses). |
| `tasks/run_task.py`, `tasks/run_digit_controls.py` | Entry points for a task grid on one open model (the second runs the spaced and digit controls at N <= 64). |
| `scripts/` | Slurm job scripts, analysis and figure scripts (`analyze_per_position.py`, `make_fig_*.py`, `make_table*.py`), head-ablation experiments (`run_head_ablation_v2.py` is the one in the paper's main ablation table). Many other scripts are earlier exploratory runs kept for completeness. |
| `results_clean/<task>/grid/<model>.csv` | Raw generations, one row per call (columns below). |
| `results_clean/_summary/` | Derived values behind the figures and tables. |
| `results_clean/gemini_pilot/` | Gemini runs (`gemini-flash-latest_POOLED_3trials.csv` is the pooled grid). |
| `results/ablation_v2/` | Head-ablation results and the heads blocked. |
| `results/<model>/` | Earlier mechanism experiments (attention captures, the first head ablation) and the grids they reuse. |

Result columns: `Method` (`Base` = no markers, `Cellular_Bounds` = markers), `Interval` (k; 0 for Base),
`Seq_Length` (N), `Trial`, `Alphabet_Size` or `Modulus` where the task has one, `Input_Given`,
`Ground_Truth`, `LLM_Output` (markers and spaces stripped, clipped to the truth length), `TAR`
(per-position accuracy), `SAR` (exact match), `First_Error_Pos`, and `Raw_Model_Output` (full generation;
absent in some early files). `_trialsA-B` files are additional, non-overlapping seed batches; `_N128`
files extend a grid to N = 128. Read answer columns as text (e.g. `pd.read_csv(..., dtype=str)` for
those columns): all-digit answers lose leading zeros if parsed as numbers.

## Setup

Python 3.11 and `pip install -r requirements.txt`. Models load from the Hugging Face hub in
bfloat16 with greedy decoding: `Qwen/Qwen2.5-{7B,14B,32B}-Instruct`, `mistralai/Mistral-7B-Instruct-v0.3`,
`microsoft/Phi-3.5-mini-instruct`, `Qwen/Qwen3.8-27B`, `google/gemma-4-31B-it`. The 27B to 32B models
need one 80 GB GPU. Gemini runs need `GEMINI_API_KEY`.

Job scripts expect a Python environment at `$REPO_DIR/.conda/envs/qwen-focus` (edit the `ENV=` line
otherwise), are submitted from the repository root, and contain placeholders `YOUR_ACCOUNT` and
`YOUR_GPU_PARTITION` for your cluster.

## Running

    python -m tasks.run_task <task> <hf_model_id> grid <trials_per_cell> [trial_start]
    python -m tasks.run_digit_controls <task>_spaced|<task>_digits <hf_model_id> 20

write `results_clean/<task>/grid/<model_tag>.csv`. Position-local tasks: `cyclic_shift`,
`random_permutation`, `conditional_shift`; dependency tasks: `copy_previous`, `running_xor`,
`running_sum_local`, `sliding_window_max`, each with a `_reset` variant. External tasks run through
`python -m tasks.run_external_task`. Head ablation: `python scripts/run_head_ablation_v2.py --model <id>`.

Generation budget: int(1.5N)+20 new tokens, and 2N+20 at k = 1, where a correct marked answer is
2N-1 tokens. Cells at k = 1 and N >= 64 were first generated under the smaller budget and then
regenerated with the larger one by `tasks/rerun_capped_k1.py` (greedy decoding: the new outputs extend
the old ones).

## Figures and tables

Run `scripts/analyze_per_position.py`, `scripts/summarize_pooled.py`, and `scripts/make_fig_split_heatmap.py`
first; they write the summary CSVs that the figures and tables read.

| Paper item | Script (`scripts/`) |
|---|---|
| Overview figure (Figure 1) | `make_fig_overview.py` |
| Three-format comparison; length and spacing profile; per-task profile | `make_fig_three_formats.py` |
| Per-position accuracy; reset variants per position | `make_fig_per_position.py` |
| Pooled effects, every task and model (heatmap) | `make_fig_split_heatmap.py` |
| Head-ablation tables (32B in the main text, 7B in the appendix) | `make_table_ablation_v2.py` |
| Appendix per-position and distance tables | `make_tables_per_position.py` |
| Appendix reset, Gemini/CLRS and external tables | `make_tables_pooled.py` |
| Appendix: mechanism figure | `make_fig2_mechanism_merged.py` |
| Appendix: best density by length | `make_fig2_vertex_migration.py` |
| Appendix: per-model accuracy by length (all seven open models) | `make_fig_by_model.py` |
| Appendix: other figures | `make_fig_divide_and_conquer.py`, `make_fig_head_heatmaps_32b.py`, `make_fig_causal_ablation.py`, `make_fig_external_tier1_checks.py`, `make_fig_external_benchmark_gemini.py` |

## Follow-up experiments and robustness checks

Each pair is a run script (Slurm job, `.sbatch` alongside) and the analysis that writes the
corresponding appendix table into `paper_tmlr/tables/`.

| Paper item | Run | Analysis |
|---|---|---|
| Alignment-robust (edit-distance) re-scoring | (reuses the main grid) | `analyze_aligned_scoring.py` |
| Instruction wording for the blind spot; head-count dose response | `run_wording_controls.sbatch`; `run_head_ablation_v2.py --top 50/200` | `analyze_wording_and_dose.py` |
| Delimiter type (bar, comma, line break) and N up to 256 | `run_delimiter_length.py` | `analyze_delimiter_length.py` |
| Sampling instead of greedy decoding | `run_sampling_decoding.py` | `analyze_sampling_decoding.py` |
| Larger state space (modulus 8, 16, 32) | `run_large_state.py` | `analyze_large_state.py` |
| Prompt delivery (system prompt, no chat template) | `run_prompt_delivery.py` | `analyze_prompt_delivery.py` |
| Input vs output markers, instruction-based 2x2 | `run_marker_sides.py` | `analyze_marker_sides.py`, `analyze_interaction.py` |
| Input vs output markers, format constrained by a logits processor | `run_marker_sides_forced.py` | `analyze_marker_sides_forced.py` |
| No-marker baselines whose prompt never mentions markers (300 cells) | `run_clean_baseline.py` | `analyze_clean_baseline.py` |
| Generation-budget cut-off check | (reuses the main grid) | `analyze_budget.py` |
| Exact transformation match and marker-placement compliance | (reuses the main grid) | `analyze_compliance.py` |
| Bootstrap sensitivity and the A = 2 / M = 2 redundancy check | (reuses the main grid) | `analyze_statistics_robustness.py` |

Their raw outputs are under `results/<experiment>/` and `results_clean/<task>_{neutral,across}/`.

## Statistics

A pooled effect is Delta = mean TAR(Bounds) - sum_N p_N mean TAR(Base at N), where p_N is the share of
marker runs at length N (only k < N is run, so marker runs sit at longer lengths); it pools N in
{4, 8, 16, 32, 64}, k in {1, 2, 4, 8, 16} (k = 3 is run but excluded), and alphabet or modulus values
(`tasks/common/pooled.py`). The share of remaining errors removed is the mean Delta over a model's tasks
divided by one minus the mean length-matched no-marker accuracy.
Per-position accuracy classes positions as right after a marker (i > 0, i mod k = 0) or within a segment
and compares each with the no-marker run at the same indices (`scripts/analyze_per_position.py`).

## License

Our code is released under the MIT License (`LICENSE`). Vendored code keeps its own license:
`tasks/common/procbench_vendor/LICENSE` (MIT) and `tasks/common/clrs_vendor/LICENSE` (Apache 2.0).
