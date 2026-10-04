# slang-uhdm matrix-1.87 — support matrix (release matrix, strict convergence in progress)

This branch (`matrix-1.87`) carries the target release matrix: Surelog v1.87 +
UHDM v1.87 + uhdm2rtlil v0.68 + slang v12.0 (anchored 2026-10-04). The pins
below are locked and the baselines are measured on the strict axis
(`uhdm-cmp` AND `uhdm-strictcmp` equal); convergence work on the remaining
strict-not-equal rows is IN PROGRESS. For the converged pilot, see branch
`pilot-0.1` (tag `v0.1.0-pilot`).

## Pinned dependency versions

| Dependency | Version | Commit | Role |
|---|---|---|---|
| slang | v12.0 (release 2026-09-29) | `545f88b2e` | compiler front end |
| UHDM | v1.87 | `18837c1` | database library, `uhdm-dump`, `uhdm-cmp` |
| Surelog | v1.87 | `0445655ee7` | golden-side reference producer |
| uhdm2rtlil | v0.68 | `ddef9ffd` | test corpus (916 test dirs, 871 discovered rows) |

The build resolves slang and UHDM through CMake config packages installed at
`~/.local` (`slang_DIR=~/.local/lib64/cmake/slang`,
`UHDM_DIR=~/.local/lib64/cmake/UHDM`). The canonical golden-side Surelog is
the build inside the pinned Surelog tree — the one
`scripts/verify_golden.py` names. Surelog v1.87 adds 4 tests to its corpus
(798 discovered row-names); uhdm2rtlil v0.68 adds ~147 test dirs.

## Measured baseline at this matrix (strict axis)

Measured 2026-10-04 at the slang v12.0 anchor. Moving slang from `7d61e0ad1`
(the 11.0 development line, 32 commits before v12.0) to v12.0 changed no
database: all 6657 databases of the three stages (962 Surelog-suite, 1608
uhdm2rtlil, 4087 probe) are byte-identical, and the gate reads 0 changes.

| Stage | Mode | Rows | CMP_EQUAL (strict) | STRICT_NOTEQUAL |
|---|---|---|---|---|
| Surelog suite | default | 798 | 468 | 12 |
| Surelog suite | testflags | 798 | 464 | 10 |
| uhdm2rtlil | default | 871 | 801 | 2 |
| uhdm2rtlil | testflags | 871 | 801 | 2 |
| probe cases (tests/probe) | — | 4087 | 3453 | 634 |

The remaining Surelog-suite rows are 798 − 480 per mode: slang rejects
(285/286), Surelog fails (25/23), deferred (5) and a few untranslatable or
timed-out rows. The 22 STRICT_NOTEQUAL row-modes include three known
failures that stay in the gate and are not work items (LogicTypespec d/t,
Scr1SvTests d/t, stamped_gen_param). The downstream gate
(`results/downstream_uhdm2rtlil.csv`: uhdm2rtlil must synthesize our database
identically to Surelog's) reads 803 IDENTICAL / 66 SLANG_REJECT / 2
EQUIVALENT / 0 open of 871. Baselines: `results/golden_surelog.csv`,
`results/golden_uhdm2rtlil.csv`, `results/golden_probe.csv`,
`results/downstream_uhdm2rtlil.csv`; `tests/sweep.sh` is the only gate.

uhdm2rtlil's Supported Core IP (lowRISC Ibex, rp32) is part of the corpus:
41 of the 871 rows (`ibex_*`, `rp32_*`). Downstream 24 are IDENTICAL and 17
are slang rejects: 11 unknown-module or unknown-package rows (the core
`project.f` lists only the package and the module, and Surelog black-boxes
the missing children where slang reports an error), 4 top-level modules
with an interface port, and 2 rows slang rejects on the source itself
(rp32_r5p_csr, rp32_r5p_hamster).

## Version history plan

- **pilot 0.1** (branch `pilot-0.1`, tag `v0.1.0-pilot`) — slang 11.0-dev
  `24809c8e0`, UHDM v1.86-31, Surelog v1.86-114, uhdm2rtlil pre-v0.68:
  CONVERGED (every runnable test judge-equal in both corpora and modes).
- **this branch** — the matrix above, slang anchored at v12.0 (2026-10-04,
  no database changed from the 7d61e0ad1 pin): the first stable matrix;
  strict convergence in progress.

The equivalence result is a property of the exact pin set. Moving any pin
requires regenerating the goldens and re-baselining the CSVs before the
scoreboard means anything.
