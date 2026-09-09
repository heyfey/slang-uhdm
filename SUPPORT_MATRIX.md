# slang-uhdm pilot 0.1 — support matrix

This branch (`pilot-0.1`, tag `v0.1.0-pilot`) is the FIRST PILOT VERSION of
slang-uhdm. It snapshots the converged state at commit `cd81d148`
(2026-09-09): every runnable test in both corpora is `uhdm-cmp`-equal to the
Surelog golden in both modes.

## Pinned dependency versions

| Dependency | Version | Commit | Role |
|---|---|---|---|
| slang | 11.0 development line | `24809c8e0` (upstream base; the local tree carries 23 `tools/uhdm:` note commits on top, none of which patch the library) | compiler front end |
| UHDM | v1.86 + 31 commits | `5523dfc` (`v1.86-31-g5523dfc`) | database library, `uhdm-dump`, `uhdm-cmp` |
| Surelog | v1.86 + 114 commits | `cbdbea458c` (`v1.86-114-gcbdbea458c`) | golden-side reference producer |

The build resolves slang and UHDM through CMake config packages installed at
`~/.local` (`slang_DIR=~/.local/lib64/cmake/slang`,
`UHDM_DIR=~/.local/lib64/cmake/UHDM`). The canonical golden-side Surelog is
the build inside the pinned Surelog tree — the one
`scripts/verify_golden.py` names.

## Measured result at this pin (the whole point of the pilot)

| Corpus | Mode | Rows | Equal | Not-equal |
|---|---|---|---|---|
| Surelog suite | default | 794 | 477 | 4 |
| Surelog suite | testflags | 794 | 471 | 4 |
| uhdm2rtlil | default | 731 | 679 | 0 |
| uhdm2rtlil | testflags | 731 | 679 | 0 |

The eight not-equal row-modes are the four slang-fenced tests (slang-side
limitations, out of scope for this project) in both modes. Every other
comparable row is judge-equal at rc 0. Baselines:
`results/golden_surelog.csv` and `results/gate_uhdm2rtlil.csv`;
`GOLDEN_EQUIVALENCE.md` §3.3 carries the generated table.

## Version history plan

- **pilot 0.1 (this branch)** — the triple above.
- **next** — Surelog v1.87 + UHDM v1.87 + slang upstream head: goldens
  regenerated, tests rerun, runnable regressions fixed (in progress on the
  upgrade branch).
- **first stable** — the same procedure against slang v12.0 when it is cut.

The equivalence result is a property of the exact triple. Moving any of the
three dependencies requires regenerating the goldens and re-baselining both
CSVs before the scoreboard means anything.
