# r11u135flip — the strict flip (harness, baselines and docs; no law)

Base `b3886a1c` (branch matrix-1.87). User direction 2026-09-24: flip the gate to strict with identity
canonicalised, and leave the rest as an explicit residue. The gate's equality is now strict: a corpus row is
`CMP_EQUAL`, and a probe case `EQUAL`, only when uhdm-cmp reads the pair equal AND uhdm-strictcmp reads it
`STRICT_EQUAL`. A pair uhdm-cmp reads equal that the strict comparator does not is `STRICT_NOTEQUAL`. The
baselines record those rows (the fail lists of `tools/probe/r11u132map`), and the gate stays red only on a
regression against them, as the uhdm-cmp gate always worked.

No exporter or comparator source changed: `src/`, `include/`, `tools/uhdm-strictcmp/` and `third_party/`
are untouched, and no law is added. The patch changes the harness (`scripts/verify_golden.py`,
`scripts/check_probe.py`, `scripts/compare_results.py`, `scripts/accounting.py`, `tests/sweep.sh`), the
baselines (`results/golden_surelog.csv`, `results/golden_uhdm2rtlil.csv`, new `results/golden_probe.csv`),
the docs (`tests/README.md`, `GOLDEN_EQUIVALENCE.md`, `PLAYBOOK.md`), `tests/LAWS.md` (the index gains the
row `| r11u135flip |  |  | 0 | 0 |` for this README) and this directory. `tests/probe/` is read-only here,
so `tests/probe/README.md` keeps its last line ("Any case not EQUAL fails the gate"); a landing should
change it to: a case that is not judge-equal, or a regression against `results/golden_probe.csv`, fails
the gate.

Worktree `/tmp/wt_r11u135`, built with the system-deps config (`-j 2`; a compile was OOM-killed under load
from other agents, so it was finished at `-j 1`). Frozen copies (`chmod 555`) were made before any
measurement, and every sweep ran with `SLANG_UHDM` and `STRICT_CMP` exported to them
(evidence/build.txt: 3273 of 3273 `slang:` lines of every sweep name the frozen binary):

| binary | md5 | |
|---|---|---|
| `slang-uhdm` | `9767e18b4753a0562f90d27f919b01d8` | worktree build = main tree = frozen copy |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | worktree build = main tree = frozen copy (mode 4, r11u129) |

The fenced tests are measured like every other row but written `FENCED_<n>` in every file of this
directory. The baselines under `results/` spell them, as the committed ones always did.

## 1. Where the status was decided (b3886a1c)

- `scripts/verify_golden.py:703`: `return (name, mode, 'CMP_EQUAL', '', '', strict_verdict(golden_uhdm, slang_out, timeout))`.
  Every uhdm-cmp-equal pair was `CMP_EQUAL`, and the strict verdict was only column 6. `:601-602`:
  `if not os.path.exists(STRICT_CMP): return ''`, so a missing comparator left the column empty and
  nothing failed.
- `scripts/check_probe.py:104-107`: `NOT_EQUAL` on a uhdm-cmp difference, else `EQUAL` with
  `strict=<verdict>` appended to the detail ("Measurement only"), and `:130,138`:
  `if st != 'EQUAL': bad.append(...)` / `sys.exit(1 if bad else 0)`. There was no csv and no baseline.
- `scripts/compare_results.py:40-45`: `if b[2] == 'CMP_EQUAL': regress` / `elif r[2] == 'CMP_EQUAL': convert`
  / else change. It compared status only. A row only in the fresh csv was listed, never failed.
- `tests/sweep.sh:40`: `check_probe.py ... || rc=1`, with no compare in the probe stage.

## 2. The design as landed

| piece | where | what |
|---|---|---|
| (1) | `scripts/verify_golden.py` `compare()` | after uhdm-cmp equal: `strict != 'equal'` gives `STRICT_NOTEQUAL` with the verdict in `detail` and `strict`, else `CMP_EQUAL`. `strict_verdict` no longer returns `''` for a missing binary. `main()` lists `STRICT_CMP` among the required tools, so a missing comparator exits `missing tool: ...` before any row. The run header names the comparator path |
| (2) | `scripts/compare_results.py` (rewritten, 110 lines) | reads both shapes (`name,mode,...` and `case,status,detail,strict`). The order is `CMP_EQUAL`/`EQUAL` > `STRICT_NOTEQUAL` > rest. REGRESSION: leaving `CMP_EQUAL`, `STRICT_NOTEQUAL` to a non-judge-equal status, or an ONLY-FRESH row that is not `CMP_EQUAL`/`EQUAL`. CONVERSION: entering `CMP_EQUAL`. CHANGE: other status moves, and a `STRICT_NOTEQUAL` row whose verdict changed, printed `old -> new [field +n]` when the field is the same. ONLY-COMMITTED prints the first 20 lines and then a count (a `--filter` run). Exit 1 on any regression |
| (3) | `scripts/check_probe.py` | `EQUAL` only when uhdm-cmp and strict are both equal, else `STRICT_NOTEQUAL` (detail = verdict). `--out CSV` writes `case,status,detail,strict` with LF endings. Exit 1 when a case is not judge-equal. The `probe cases:` line stays, and the strict tally is now `probe strict:`. **Fixed a proven defect**: the output database is now unlinked before the export (see 2a) |
| (4) | `tests/sweep.sh` | probe stage: `rm -f probe.csv`, `check_probe.py --out $WORKDIR/probe.csv`, then `compare_results.py probe.csv results/golden_probe.csv`; a missing csv sets rc=1. Every stage's regression still ends in exit 1 |
| | `scripts/accounting.py` | comparable = `CMP_EQUAL`+`STRICT_NOTEQUAL`+`CMP_NOTEQUAL`, judge-equal and strict-equal columns (the GOLDEN_EQUIVALENCE 3.3 table, regenerated) |

### 2a. The proven defect in check_probe.py (evidence/check_probe_stale_db_defect.txt)

At b3886a1c, `check_probe.py` wrote `<workdir>/<case>.uhdm` without removing an earlier one. With
`SLANG_UHDM=/bin/false` on a workdir that a real run had just filled, it read `EQUAL=4 (of 4)` and rc 0: a
failed export was judged on the previous run's database. The negative control `SLANG_UHDM=/bin/false`
with a reused workdir would have passed. With the unlink, the same command reads `SLANG_FAIL=4` and rc 1.
`verify_golden.py` has always unlinked its output. The `tests/sweep.sh` default workdir is reused across
runs, so this was reachable.

## 3. The baselines and the relabelling proof

Sweep A (`tests/sweep.sh --jobs 3 --workdir /tmp/r11u135_swA`, new scripts, b3886a1c baselines) is the
source: its three csvs are the new baselines, copied verbatim. They are LF. The committed scoreboards
were CRLF by accident, and `canaries.sh` then reads `ok=0 changed=1 absent=51` against the
old baseline (evidence/canaries.txt, last block). Against the old baselines, sweep A reads exactly the
relabelled rows as regressions: surelog `regressions=322`, uhdm2rtlil `regressions=354`, 0 conversions
and 0 changes. The probe stage had no baseline yet (evidence/sweep_A_new_scripts_old_baselines.log).

`relabel_proof.py` (evidence/relabel_proof.txt) checks the b3886a1c csvs against the new ones. They
have the same rows. Every row keeps its uhdm-cmp verdict and its strict column. An old `CMP_EQUAL`
row is new `CMP_EQUAL` exactly when its strict verdict is `equal`, else `STRICT_NOTEQUAL` with
detail = verdict. Every other detail is equal or differs only in the checkout or workdir path it
spells, because the committed csvs were swept from `~/git-repos/Surelog` and `~/git-repos/uhdm2rtlil`.

| baseline | CMP_EQUAL / EQUAL | STRICT_NOTEQUAL | of judge-equal | other statuses unchanged | violations |
|---|---|---|---|---|---|
| golden_surelog.csv (1596 rows) | 632 (327 + 305) | 322 (153 + 169) | 954 | 642 | 0 |
| golden_uhdm2rtlil.csv (1742 rows) | 1252 (626 + 626) | 354 (177 + 177) | 1606 | 136 | 0 |
| golden_probe.csv (4087 cases) | 2069 | 2018 | 4087 | — | 0 |

The probe side has no old csv. The b3886a1c `check_probe.py` run on the same binaries reads `EQUAL=4087`
with the strict tally `equal=2069 fullname=768 endcol=365 depth=234 line=208 file=147 type=101 endline=78
col=75 name=31 value=5 count=3 decompile=3` (evidence/probe_old_script_b3886a1c.log). The new csv
carries the same tally, and each case is `EQUAL` exactly when its strict verdict is `equal`.

`map_check.py` (evidence/map_check.txt) checks that the `STRICT_NOTEQUAL` rows are exactly the explicit
residue of `tools/probe/r11u132map`. That is 676 corpus row-modes in 354 tests, each with the same
strict verdict as `fail_list.csv` (the 2 FENCED_1 rows matched by mode and verdict). The probe side is
2018 cases, the same set and first field as `probe_fail_list.csv`. The map spells the 8 case dirs named
`cases` as `cases`, and the check reads them the same way. `MAP CHECK PASS mismatches=0`.

## 4. Docs

- `tests/README.md`: the gate's equality is strict since 2026-09-24. It adds a status table, the
  `STRICT_NOTEQUAL` residue (the r11u132map fail lists), the probe baseline row, the regression, conversion
  and change rules, how a landing promotes a row (`STRICT_NOTEQUAL -> CMP_EQUAL` is a conversion
  committed by re-baselining the row), the LF note, and the probe count 2833 -> 4087.
- `GOLDEN_EQUIVALENCE.md`: a new paragraph "The strict flip". It gives the date, the rule, the residue
  (the r11u132map fail lists with their sites), the counts, what identity means, and that the identity
  residue is zero. The 4.2 table row for `tests/sweep.sh` and the "sixth column" paragraph are updated,
  and the 3.3 table is regenerated with the judge-equal and strict-equal columns.
- `PLAYBOOK.md`: the probe csv compare in the gate recipe.

## 5. Gates

| gate | command | result |
|---|---|---|
| (1) build | worktree build | both md5s byte-identical to the main tree's (table above) |
| (a) full sweep, final scripts | `tests/sweep.sh --jobs 3 --workdir /tmp/r11u135_swC` | **rc 0**; law index current; probe `EQUAL=2069 STRICT_NOTEQUAL=2018 (of 4087)`, then `regressions=0 conversions=0 changes=0 only-fresh=0 only-committed=0` in all three csv stages; downstream `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`, and 0 of 871 rows changed verdict or `differs` against `results/downstream_uhdm2rtlil.csv`. The probe csv is byte-identical to the baseline, and the corpus csvs equal it on status, blocked_by and strict for every row (evidence/sweep_C_positive_control_final.log) |
| (c) positive control | sweep B, the same again before the last two script edits | rc 0, the same numbers (evidence/sweep_B_positive_control.log) |
| (b1) `SLANG_UHDM=/bin/false` | `--corpus "probe surelog uhdm2rtlil"` | **rc 1**. Probe `regressions=4087` (EQUAL 2069 + STRICT_NOTEQUAL 2018 -> SLANG_FAIL). Surelog `regressions=954` (632 CMP_EQUAL + 322 STRICT_NOTEQUAL -> SLANG_REJECT) with `changes=6` (CMP_NOTEQUAL -> SLANG_REJECT). uhdm2rtlil `regressions=1606` (1252 + 354) with `changes=2` (evidence/neg_binfalse.log, condensed) |
| (b2) `R11U124_OFF=1` | the frozen HEAD binary, `--corpus "probe surelog uhdm2rtlil"` | **rc 1**. Probe `regressions=180 changes=162`, surelog `regressions=43 changes=55`, uhdm2rtlil `regressions=38 changes=40`. All 261 regressions are `CMP_EQUAL`/`EQUAL -> STRICT_NOTEQUAL`, first field file 203, value 51, endcol 7 (evidence/neg_r11u124off.log). Attribution below |
| (b3) golden swap, EQUAL case | private `GOLDEN_CACHE` holding the four `r10earl59repro` entries, with `a1_earl59`'s golden replaced by `v59v3_earl59`'s; `--corpus probe --filter '^r10earl59repro/'` | **rc 1**: `REGRESSION r10earl59repro/a1_earl59 EQUAL -> NOT_EQUAL`, `regressions=1` (evidence/neg_golden_swap_equal_case.log) |
| (b3') golden swap, STRICT_NOTEQUAL case | `v59v2_earl59`'s golden replaced by `v59v1_earl59`'s | **rc 1**: `REGRESSION r10earl59repro/v59v2_earl59 STRICT_NOTEQUAL -> NOT_EQUAL` (evidence/neg_golden_swap_strictne_case.log) |
| missing comparator | `STRICT_CMP=/tmp/r11u135_nonexistent`, quick gate | **rc 1**: each stage prints `missing tool: /tmp/r11u135_nonexistent`, then `== probe: no csv written` (evidence/missing_comparator.log) |
| (d) quick gate | `tests/sweep.sh --filter '^Assign'` | rc 0. Surelog 7 tests and uhdm2rtlil 16, `regressions=0` in each; downstream `IDENTICAL=16 (of 16)`. With `/bin/false`: rc 1, surelog `regressions=6`, uhdm2rtlil `regressions=32` (evidence/quick_gate_assign*.log) |
| (e) law index | `python3 scripts/law_index.py --check` | `law index current` (tests/LAWS.md regenerated for this README) |
| compare rules | `compare_selftest.sh` | 16 of 16 synthetic cases, one per rule of section 2 and both csv shapes (evidence/compare_selftest.txt) |
| (5) uhdm-cmp | the relabelling proof | no row's uhdm-cmp verdict changed. No database changed, because no exporter source changed |
| (6) byteverify | `SELFCHECK=1 byteverify.sh`, sweeps B and C vs A | uhdm2rtlil `MOVERS: 0 / 1608` both times. Surelog `4 / 960` (B: MiniAmiq/default+testflags, Scoreboard/default, SeqDriver/default) and `3 / 960` (C). All are the UVM order coin on one binary, and their strict verdicts are the same in all three sweeps (`differ:line(199)`, `(182)`, `(195)`). Selfcheck 959/960 and 1607/1608 (evidence/byteverify.txt) |
| canaries | `canaries.sh` and `ctcan2.sh` on sweep B vs the new baselines | surelog `ok=52 changed=0 absent=0`, u2r `ok=16 changed=0`; `EXPECT_UNKNOWN=1 ctcan2.sh`: `ok=58 changed=0 ... PASS`; `EXPECT_UNKNOWN=6`: `ok=2 changed=0 ... PASS` (evidence/canaries.txt) |

### The R11U124_OFF control: predicted by name, then attributed (evidence/neg_r11u124off_attribution.txt)

The prediction was written before the run. It was the rows pass 124's census turned equal
(`tools/probe/r11u124repro/evidence/to_equal_rows.txt`, and `strictdiff_probe.txt` TO-EQUAL) that are
`CMP_EQUAL`/`EQUAL` in the new baselines: 106 corpus row-modes and 134 probe cases. 205 of those 240
regressed.

- 35 predicted rows did not regress: 34 corpus row-modes, both modes of surelog
  BitSelectPartSelectInFunction, ElabParam and IncompFunc and uhdm2rtlil BitSelectPartSelectInFunction,
  CastExpression, CastLogic, CastSize, FunctionReturnEnum, iface_param_set_value, InterfaceParameter,
  InterfaceParameterSetValue, int_port_signed, MemberSelectOf2DStructPackedArray, OneCast, OnePackage,
  ReturnEnumArray and unbased_unsized, plus 1 probe case (r10earl50repro/h6_earl50). Pass 125 landed before pass 124, on a base pass 124 never measured, and its
  cast-file law (`R11U125_CASTFILE_OFF`) also writes that file. With `R11U124_OFF=1
  R11U125_CASTFILE_OFF=1`, all 35 regress (`differ:file(1|2)`).
- 56 rows regressed that were not predicted. Pass 124's census moved each of them without converting
  it (BETTER 48, FIELD-CHANGE 8). Pass 125 and the comparator commits 9c839593 and 4f73d52f removed
  the rest of the difference, so at b3886a1c the row is equal only with pass 124's laws.
- A byte check on every database confirms this. Every verdict change (261 regressions and 257 changes)
  is on a database that moved under `R11U124_OFF` (0 changes without a byte move). 36 moved databases
  kept their verdict.

## 6. Notes and residues, ranked

1. **Fence check.** RESUME section 6's fence grep over the patch will list `results/golden_surelog.csv`.
   The scoreboard spells the four fenced tests, as the committed one always did. The CRLF-to-LF
   rewrite touches every line, and FENCED_1's two rows change status (`CMP_EQUAL` ->
   `STRICT_NOTEQUAL`, `differ:file(2)`) in any case. No other file of the patch spells them.
2. **The UVM order coin** (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard) is `STRICT_NOTEQUAL` in every
   mode. A coin that moved its object count would read as a CHANGE (exit 0), never a regression.
   None did in three sweeps.
3. **ONLY-COMMITTED stays non-fatal**, because a `--filter` run needs that. A thread exception in
   `verify_golden.py` writes a row with mode `harness`, which no `--modes` selects, so its real rows read
   as only-committed. This hole predates the flip and is unchanged.
4. **Detail text is environmental.** Paths in SLANG_REJECT and SURELOG_FAIL details, and the LowMem
   log-file path, differ per checkout and workdir. The compare never reads the detail column; it reads
   status, and the strict verdict on `STRICT_NOTEQUAL` rows.
5. **`tests/probe/README.md`** (read-only here) still says "Any case not EQUAL fails the gate". The
   next landing should update it.

## Files

- `relabel_proof.py`: the old baseline against the new one (corpus), or the old probe log against the
  new probe csv.
- `map_check.py`: the new baselines' `STRICT_NOTEQUAL` rows against the r11u132map fail lists.
- `compare_selftest.sh <repo>`: synthetic rows through `scripts/compare_results.py`.
- `evidence/`: every log named above.
