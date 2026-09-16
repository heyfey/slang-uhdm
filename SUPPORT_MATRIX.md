# slang-uhdm matrix-1.87 — support matrix (PRE-CONVERGENCE)

This branch (`matrix-1.87`) upgrades the dependency matrix past pilot 0.1.
The pins below are locked and the baselines are measured; convergence work
on the regressions is IN PROGRESS. For the converged pilot, see branch
`pilot-0.1` (tag `v0.1.0-pilot`).

## Pinned dependency versions

| Dependency | Version | Commit | Role |
|---|---|---|---|
| slang | 11.0 development line + 86 (upstream head, pre-v12.0) | `7d61e0ad1` | compiler front end |
| UHDM | v1.87 | `18837c1` | database library, `uhdm-dump`, `uhdm-cmp` |
| Surelog | v1.87 | `0445655ee7` | golden-side reference producer |
| uhdm2rtlil | v0.68 | `ddef9ffd` | test corpus (916 test dirs, 871 discovered rows) |

The build resolves slang and UHDM through CMake config packages installed at
`~/.local` (`slang_DIR=~/.local/lib64/cmake/slang`,
`UHDM_DIR=~/.local/lib64/cmake/UHDM`). The canonical golden-side Surelog is
the build inside the pinned Surelog tree — the one
`scripts/verify_golden.py` names. Surelog v1.87 adds 4 tests to its corpus
(798 discovered row-names); uhdm2rtlil v0.68 adds ~147 test dirs.

## Measured baseline at this pin (PRE-CONVERGENCE)

| Corpus | Mode | Rows | Equal | Not-equal |
|---|---|---|---|---|
| Surelog suite | default | 798 | 474 | 9 |
| Surelog suite | testflags | 798 | 469 | 8 |
| uhdm2rtlil | default | 871 | 784 | 20 |
| uhdm2rtlil | testflags | 871 | 784 | 20 |

For comparison, pilot 0.1 measured 477/4 + 471/4 and 679/0 ×2 on its own
pins. The regression sets cluster in interface-parameter, struct-parameter,
and hierarchy-parameter families (plus the new ibex_* and latch_* tests in
uhdm2rtlil v0.68). Three of the four slang-fenced tests remain not-equal in both
modes (one converted untargeted under the new pins). Baselines: `results/golden_surelog.csv`,
`results/gate_uhdm2rtlil.csv` (testflags gate),
`results/golden_uhdm2rtlil.csv` (both modes);
`GOLDEN_EQUIVALENCE.md` §3.3 carries the generated table.

## Version history plan

- **pilot 0.1** (branch `pilot-0.1`, tag `v0.1.0-pilot`) — slang 11.0-dev
  `24809c8e0`, UHDM v1.86-31, Surelog v1.86-114, uhdm2rtlil pre-v0.68:
  CONVERGED (every runnable test judge-equal in both corpora and modes).
- **this branch** — the matrix above: goldens regenerated, baselines
  measured, convergence in progress.
- **first stable** — the same procedure against slang v12.0 when it is cut.

The equivalence result is a property of the exact pin set. Moving any pin
requires regenerating the goldens and re-baselining the CSVs before the
scoreboard means anything.
