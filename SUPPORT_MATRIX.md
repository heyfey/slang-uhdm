# slang-uhdm matrix-1.87 — support matrix (release matrix; convergence stopped at ALL CLEAN on 2026-11-04)

This branch (`matrix-1.87`) carries the target release matrix: Surelog v1.87 +
UHDM v1.87 + uhdm2rtlil v0.68 + slang v12.0 (anchored 2026-10-04). The pins
below are locked and the baselines are measured on the strict axis
(`uhdm-cmp` AND `uhdm-strictcmp` equal). The convergence campaign stopped on
2026-11-04 at `9889dcaad` with every gate clean except the rows excluded by
decision (below); this is the candidate point for the release cut. For the
converged pilot, see branch `pilot-0.1` (tag `v0.1.0-pilot`).

## Pinned dependency versions

| Dependency | Version | Commit | Role |
|---|---|---|---|
| slang | v12.0 (release 2026-09-29) | `545f88b2e` | compiler front end |
| UHDM | v1.87 | `c756248` (Surelog's pin; the gate binaries link `18837c1`, an earlier commit of the same line and schema) | database library, `uhdm-dump`, `uhdm-cmp` |
| Surelog | v1.87 | `0445655ee7` | golden-side reference producer |
| uhdm2rtlil | v0.68 | `ddef9ffd` | test corpus (916 test dirs, 871 discovered rows) |

The default build compiles slang and UHDM in-tree from the submodules;
`-DSLANG_UHDM_USE_SYSTEM_DEPS=ON` resolves them through CMake config packages
installed at a prefix instead (`slang_DIR`, `UHDM_DIR`; the campaign machine
built that way against `~/.local`). The canonical golden-side Surelog is
the build inside the pinned Surelog tree — the one
`scripts/verify_golden.py` names. Surelog v1.87 adds 4 tests to its corpus
(798 discovered row-names); uhdm2rtlil v0.68 adds ~147 test dirs.

## Measured baseline at this matrix (strict axis)

Measured 2026-11-04 at `9889dcaad` (the convergence stop), from the committed
baselines; the strict gate counts a row equal only when `uhdm-cmp` and
`uhdm-strictcmp` both read equal.

| Stage | Mode | Rows | CMP_EQUAL (strict) | STRICT_NOTEQUAL | CMP_NOTEQUAL | not comparable |
|---|---|---|---|---|---|---|
| Surelog suite | default | 798 | 480 | 0 | 4 | 314 (SLANG_REJECT 284, SURELOG_FAIL 25, DEFERRED 5) |
| Surelog suite | testflags | 798 | 474 | 0 | 4 | 320 (SLANG_REJECT 285, SURELOG_FAIL 23, DEFERRED 5, NO_DATABASE 3, UNTRANSLATABLE 2, TIMEOUT 1, NO_UHDM 1) |
| uhdm2rtlil | default | 871 | 803 | 0 | 1 | 67 (SLANG_REJECT) |
| uhdm2rtlil | testflags | 871 | 803 | 0 | 1 | 67 (SLANG_REJECT) |
| probe cases (tests/probe) | — | 31943 | 29901 (EQUAL) | 2042 | 0 | 0 |
| sv-tests (both accept) | — | 1940 of 2346 | 1937 (EQUAL) | 0 | 3 (DIFFERENT) | 406 (SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1) |

The rows that stay not equal by decision: in the Surelog suite the four
slang-fenced tests (six of the eight CMP_NOTEQUAL row-modes; `tests/FENCED.md`)
and Tnoc d/t (a Surelog artefact the exporter does not copy); in uhdm2rtlil
stamped_gen_param d/t; in sv-tests the three known exceptions
`generated/hdlconv_std2017/hdlconvertor_std2017_p733.sv`, `..._p737.sv` and
`generated/tnoc/tnoc.sv` (user decision 2026-11-02). The 2042
STRICT_NOTEQUAL probe cases are the strict residue of the evidence grids, each
named in `tests/LAWS.md`. The downstream gate
(`results/downstream_uhdm2rtlil.csv`: uhdm2rtlil must synthesize our database
identically to Surelog's) reads 803 IDENTICAL / 66 SLANG_REJECT / 2
EQUIVALENT / 0 DIVERGENT of 871. Baselines: `results/golden_surelog.csv`,
`results/golden_uhdm2rtlil.csv`, `results/golden_probe.csv`,
`results/golden_svtests.csv`, `results/downstream_uhdm2rtlil.csv`;
`tests/sweep.sh` is the only gate.

The 2026-10-04 anchor measurement (slang moved from `7d61e0ad1` to v12.0 with
no database changing: all 6657 databases of the three stages byte-identical)
read Surelog 468/464 CMP_EQUAL with 12/10 STRICT_NOTEQUAL, uhdm2rtlil 801/801
with 2/2, and probe 3453 EQUAL + 634 STRICT_NOTEQUAL of 4087; passes 401 to
491 converted the rest.

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
  no database changed from the 7d61e0ad1 pin): the first stable matrix.
  Strict convergence ran as passes 401 to 491 (the sv-tests campaign, user
  directive 2026-10-15) and stopped on 2026-11-04 at `9889dcaad` with every
  gate clean but the rows excluded by decision; the release cut starts here.

The equivalence result is a property of the exact pin set. Moving any pin
requires regenerating the goldens and re-baselining the CSVs before the
scoreboard means anything.
