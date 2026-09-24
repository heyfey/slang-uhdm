# r11u136gate — the flipped gate, attacked (verification pass; scripts and docs only)

Base `c9e2923c` (branch matrix-1.87), the strict flip of `tools/probe/r11u135flip`. The target was to make the
gate (A) PASS a real regression, or (B) FAIL a clean run, and to check (C) how the probe baseline is
maintained. Every attempt below is a script under `attempts/` run on the base scripts
(`/tmp/wt_r11u136pris`, pristine `c9e2923c`) and on the fixed ones (`/tmp/wt_r11u136`). Its output is under
`evidence/`, one log per side.

No exporter or comparator source changed. `src/`, `include/`, `tools/uhdm-strictcmp/`, `results/`,
`tests/probe/` and `third_party/` are untouched. The patch changes `scripts/compare_results.py`,
`scripts/verify_golden.py`, `scripts/check_probe.py`, `scripts/downstream_uhdm2rtlil.py`, `tests/sweep.sh`,
`tests/README.md`, `tests/LAWS.md` (the index gains `| r11u136gate |  |  | 0 | 0 |` for this README),
one row of the flip's `tools/probe/r11u135flip/compare_selftest.sh`, and this directory.

Binaries, frozen (`chmod 555`) before any measurement at `/tmp/r11u136_bin/`:

| binary | md5 | |
|---|---|---|
| `slang-uhdm` | `61cfb59f3cfa1865bccb360c76bf09dd` | worktree build (system deps, `-j 2`) = main tree = frozen copy |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | worktree build = main tree = frozen copy |

Every `slang:` line of the two full sweeps names the frozen binary (3273 of 3273 each,
evidence/sweep_F_joins_and_audit.txt).

## 1. The attempts

HOLE means the base gate gave the wrong verdict. The fixed column is the same command on the fixed scripts.

| # | shape | command (attempts/) | expected | base `c9e2923c` | verdict | fixed |
|---|---|---|---|---|---|---|
| A1 | thread exception in verify_golden.py (a regular file where the test's work dir goes) | `a01_poisoned_workdir.sh`, `a01b_…_unfiltered.sh` | FAIL | **rc 0**: the exception becomes a `harness`-mode row that `--modes` drops, and the test's two rows read ONLY-COMMITTED (`only-committed=2`) | **HOLE** | rc 1: `REGRESSION HARNESS 1DUnpackedArray …` + 2× `REGRESSION ONLY-COMMITTED (not run)` |
| A2 | `SLANG_UHDM` not executable (a frozen copy left `chmod 444`) | `SLANG_UHDM=<444 copy> tests/sweep.sh --corpus "surelog uhdm2rtlil"` | FAIL | **rc 0**: every test raises `[Errno 13]`, and 1643 harness rows mean `only-committed=1544` + `1742`, `regressions=0` | **HOLE** | rc 1: `regressions=2316` / `2613` |
| A3 | probe case `dut.sv` deleted / renamed to `dut.v` | `a03_probe_case_vanishes.sh` (scratch copy of tests/probe) | FAIL | **rc 0**, `only-committed=2` | **HOLE** | rc 1: 2× `REGRESSION ONLY-COMMITTED (not run)` |
| A4 | probe case edited in place; the cache is keyed by its path | `a04_edited_case_stale_golden.sh` (appends an empty module to a1_earl59) | the edited text's verdict: EQUAL (Surelog on the edited text: `STRICT_EQUAL 587 objects`) | **rc 1**: judged against the old text's golden, `NOT_EQUAL` (the edited text keys to the SAME entry) | **HOLE** (B: a false fail. A false pass needs slang-uhdm to be wrong on the new text in exactly the way that matches Surelog on the old text; not constructed, and the same fix closes it) | rc 0: new key, the golden is built from the edited text, `EQUAL` |
| A5 | corrupted cache entry: truncated golden / 0-byte golden | `a05_corrupt_golden.sh` | FAIL / clean verdict | truncated: rc 1 `EQUAL -> NOT_EQUAL`; 0-byte: treated as a miss, rebuilt, rc 0 | OK (fails safe) | same |
| A5' | another case's golden (the flip's b3/b3') | flip evidence, and N3 below | FAIL | rc 1 | OK | rc 1 |
| A6a | stale GOLDEN in a reused verify_golden workdir (cache off, Surelog writes nothing) | `a06a_stale_golden_workdir.sh` (`GOLDEN_CACHE=0`, 2nd run `SURELOG=/bin/false`) | FAIL (`SURELOG_FAIL`) | **rc 0**: `CMP_EQUAL` against the first run's `slpp_all/surelog.uhdm` | **HOLE** | rc 1: `CMP_EQUAL -> SURELOG_FAIL` ×2 |
| A6b | stale `slang.uhdm` in a reused downstream workdir | `a06b_downstream_stale_slangdb.sh` (2nd run `SLANG_UHDM=/bin/false`) | FAIL | **rc 0**: `adff,IDENTICAL` from the previous run's database | **HOLE** | rc 1: `SLANG_REJECT adff` (not excused) |
| A6c | a rejection only the downstream command line reaches (`-DSYNTHESIS`) | `a06c_downstream_only_rejection.sh` (a wrapper that fails for adff only under `-DSYNTHESIS`) | FAIL: row leaves IDENTICAL | **rc 0**: the corpus stage reads `adff` `CMP_EQUAL` ×2, and downstream reads `SLANG_REJECT` as "the allowed exception" | **HOLE** | rc 1: `not identical and not excused=1` |
| A6d | stale probe database | fixed by the flip (r11u135flip 2a) | — | — | OK | — |
| A7a | `STRICT_CMP` = uhdm-cmp, with a real regression (`R11U124_OFF=1`) | `a07_comparator_identity.sh <repo> <wd> $UHDM_CMP 1` | FAIL | **rc 0**: `uhdm-cmp --max 0 <a> <b>` prints its usage and exits 0, so every pair reads `equal`: `EQUAL=4087`, `conversions=2006`, `regressions=0` | **HOLE** | rc 1: `regressions=2081 changes=2006` |
| A7b | `STRICT_CMP=/bin/true`, same regression | `a07_…sh <repo> <wd> /bin/true 1` | FAIL | **rc 0**, `conversions=2006` | **HOLE** | rc 1 |
| A7c | an older comparator build (9c839593, md5 `70ddf0ad`, default mode 3) | `a07_…sh <repo> <wd> <old> 0` (no law off) | FAIL | rc 1: `regressions=29 conversions=28 changes=196` | OK (older builds are stricter by history, so they fail loudly). The mode is the binary's default; the harness passes no mode. Passing `--canon-fullname 4` was tried and dropped: the old binary accepts 4 and reads it as mode 0 inside copies, which is laxer |
| A7d | `UHDM_CMP=/bin/true` and a real judge-level regression (b3': v59v2's golden := v59v1's) | `a07d_judge_wrong_golden_swap.sh` | FAIL `STRICT_NOTEQUAL -> NOT_EQUAL` | **rc 0**: `CHANGE … differ:endcol(4) -> differ:stage1` (the strict comparator's stage 1 saw it and the harness filed it as a STRICT_NOTEQUAL verdict) | **HOLE** | rc 1: `REGRESSION … STRICT_NOTEQUAL -> NOT_EQUAL` (`uhdm-strictcmp stage 1: not equal`) |
| A7e | `STRICT_CMP` = uhdm-cmp on both corpora | `a07e` logs | FAIL | **rc 0**, `conversions=315` + `336` | **HOLE** (A7a) | rc 1: `regressions=639` + `1270` |
| A7f | comparator missing | N4 below | FAIL | rc 1 (flip) | OK | rc 1 |
| A8 | mode mix-up: a default-only csv against the both-modes baseline | `gate_selftest.sh` G1/G8 | FAIL unless `--modes default` | rc 0 (testflags rows only-committed) | **HOLE** (the A1 mechanism) | rc 1; with `--modes default` rc 0 |
| A9 | CRLF fresh csv; BOM on the fresh probe csv | G9, G11 | same verdict | CRLF: same (OK). BOM: the header reads as the corpus shape, every row drops out, rc 0 | CRLF OK; BOM **HOLE** (unreachable from check_probe, which writes no BOM) | same verdict; BOM tolerated |
| A10 | duplicate key in the fresh csv / in golden_probe.csv | G7, G13 | FAIL | rc 0, last row wins | **HOLE** (hand-edited baselines) | rc 1 `REGRESSION DUPLICATE …` |
| A11 | `--filter` subset hides a lost row inside the filter | A1 (filtered) | FAIL | rc 0 | **HOLE** | rc 1; rows the filter excludes are not expected (G3) |
| A12 | golden_probe.csv missing a case / a new case dir | `c02_new_case.sh` | new STRICT_NOTEQUAL case FAILS, new EQUAL case passes | rc 1 / rc 0 | OK | rc 1 / rc 0 |
| A13 | rc aggregation: probe fails, then downstream passes; a stale law index alone | `a13_rc_aggregation.sh`, evidence/a13_law_index_stale.log | rc 1 / rc 1 | rc 1 (the downstream stage itself passed `SLANG_REJECT`) / rc 1 | OK | rc 1 (downstream fails too) / rc 1 |
| A14 | malformed csv (short row); empty or 0-byte fresh csv | G10; G5, G6 | FAIL | short row: traceback, rc 1 (OK). Empty: **rc 0** (`only-committed=4`) | empty **HOLE** | rc 1 |
| A15 | corpus root is an empty dir (mis-set `UHDM2RTLIL_TESTS`) | `a15_empty_corpus_root.sh` | FAIL | **rc 0**: `only-committed=1742`, and downstream `(of 0)` | **HOLE** | rc 1: `regressions=1742`, downstream `not identical and not excused=871` (NOT_RUN) |
| B1 | the UVM order coin, run repeatedly | sweeps P, F, J + `b01_uvm_coin.sh … 6` | statuses stable | 1596 of 1596 row-modes equal on status and strict across P, F and J. The coin fired: 5 and 6 byte movers between the runs, all in the family, and 5 distinct md5s in 6 runs for MiniAmiq and SeqDriver. The verdicts stay `differ:line(199)`, `(182)`, `(195)` | OK | — |
| B2 | cold golden cache | pcold (4087 probe goldens rebuilt), `b02_cold_cache.sh` (uhdm2rtlil + downstream `^[a-c]`, surelog `^(Assign\|Bit\|Case)`) | same verdicts | probe csv byte-identical to the baseline; 176 + 50 corpus rows and 88 downstream rows equal to the warm sweep | OK | — |
| B3 | `--jobs 1` vs `--jobs 3` | sweep J vs F | same csvs | probe and uhdm2rtlil byte-identical; surelog differs only in the LowMem log-path detail | OK | — |
| B4 | the two modes' work dirs | code: `<workroot>/<mode>/<name>-<sha1(dir)[:8]>` | disjoint | disjoint (default/ and testflags/ trees in every sweep) | OK | — |
| B5 | two downstream sweeps of the same tests at once | `b05_concurrent_downstream.sh` | no collision | both `IDENTICAL=4`; 24 of 24 RTLIL/netlist files byte-identical between them and with sweep P (other workdir length) | OK | — |
| C1 | re-baselining the probe | evidence/c01_probe_baseline_regen.txt | byte-identical | P, F, J and the cold run all give byte-identical `probe.csv`. A promoted case reads `CONVERSION` (rc 0), and `cp <workdir>/probe.csv` reproduces the landed baseline | OK (documented now in tests/README.md) | — |
| C2 | a new case dir | A12 | only-fresh must be EQUAL | yes | OK | yes |

## 2. The fixes (smallest diffs)

1. `scripts/compare_results.py`:
   - A baseline row the fresh csv lacks is a REGRESSION (`REGRESSION ONLY-COMMITTED (not run)`), except rows
     excluded by the new `--filter REGEX`. The filter is matched as the harness matches it: `re.search` on the
     test name, or on the case path.
   - A `harness`-mode row is a regression.
   - A key listed twice in either csv is a regression.
   - The probe header is read through a BOM.

   Closes A1, A2, A3, A8, A10, A11, A14 and A15 (corpus side).
2. `tests/sweep.sh` passes `--filter "$FILTER"` to both compares.
3. `scripts/verify_golden.py`:
   - `strict_verdict` needs rc 0 AND a `STRICT_EQUAL ` line (A7a, A7b, A7e).
   - A `differ:stage1` verdict (the strict comparator's stage 1 is uhdm-cmp's own Compare) is `CMP_NOTEQUAL`
     (A7d). No baseline row holds `differ:stage1`.
   - On a golden cache miss, `slpp_all`/`slpp_unit` are removed before Surelog runs (A6a).
4. `scripts/check_probe.py`:
   - A `differ:stage1` verdict is `NOT_EQUAL`.
   - The golden cache key adds a sha1 of the case dir's files (all but `LAW`) (A4). The first run after this
     patch rebuilds the 4087 probe goldens once (5 min at `--jobs 3`, evidence/b2_probe_cold_content_keys.log;
     that run used an intermediate verify_golden.py that passed `--canon-fullname 4`, the binary's own
     default, and sweep F repeats it warm on the final scripts with the same csv).
5. `scripts/downstream_uhdm2rtlil.py`:
   - `slang_db` unlinks `slang.uhdm` first (A6b).
   - `SLANG_UHDM`'s rejection is excused only where the baseline records `SLANG_REJECT`, or for a test the
     baseline does not name (A6c).
   - A baseline test the run did not produce, within `--filter`, is `NOT_RUN` and fails (A15).
6. `tests/README.md`: the new regression rules; the comparator-identity rule; the downstream rule; the probe
   key; the probe re-baseline (`cp <workdir>/probe.csv results/golden_probe.csv`); and a filtered direct-use
   example.
7. `tools/probe/r11u135flip/compare_selftest.sh`: its row `only-committed (filter) passes` asserted the A1/A11
   hole as a rule. That row now passes `--filter '^(eq|sne|ne)$'` (a `XARGS` hook in `run`). At base
   scripts, the unpatched selftest reads 16/16. On the fixed scripts, the unpatched selftest reads 15/16 (that
   row), and the patched one reads 16/16 (evidence/compare_selftest.txt).

`gate_selftest.sh <repo>` holds the csv-level controls G1-G13. The base reads 3 of 13 ok and the fixed
scripts 13 of 13 (evidence/gate_selftest.txt).

## 3. Gates after the fixes (fixed scripts, frozen binaries)

| gate | result |
|---|---|
| (1) build | md5s above, both byte-identical to the main tree's |
| positive control, full sweep F | **rc 0** (8m21s). Law index current. Probe `EQUAL=2081 STRICT_NOTEQUAL=2006 (of 4087)`, and every csv stage reads `regressions=0 conversions=0 changes=0 only-fresh=0 only-committed=0`. Downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`, and 0 of 871 rows changed verdict or `differs` against the baseline. The probe csv is byte-identical to `results/golden_probe.csv`. The corpus csvs equal the baselines on status, blocked_by and strict for every row, and are byte-identical to the base-script sweep P except for the LowMem log-path detail (evidence/sweep_F_*.txt/.log). Sweep P (base scripts) also read rc 0 with the same numbers |
| sweep J (`--jobs 1`, probe + corpora) | rc 0, the same csvs (B3) |
| (5) uhdm-cmp | no status changed in any row of F, J or P against the baselines, so every row's uhdm-cmp verdict stands |
| negative b1 `SLANG_UHDM=/bin/false`, full sweep | **rc 1**. Probe `regressions=4087`. Surelog `regressions=954 changes=6`, uhdm2rtlil `regressions=1606 changes=2`: the flip's numbers. The downstream stage now fails as well, with `not identical and not excused=805`; at base it passed with 871 SLANG_REJECT (evidence/neg_binfalse_fixed.log) |
| negative b2 `R11U124_OFF=1` | **rc 1**. Probe `regressions=180 changes=162`, surelog `43 / 55`, uhdm2rtlil `38 / 40`: the flip's numbers exactly (evidence/neg_r11u124off_fixed.log) |
| negative b3 / b3' golden swaps | **rc 1** each: `a1_earl59 EQUAL -> NOT_EQUAL`, `v59v2_earl59 STRICT_NOTEQUAL -> NOT_EQUAL`. b3' also holds with `UHDM_CMP=/bin/true` (A7d) |
| missing comparator | **rc 1**: `missing tool` in each stage, then `probe: no csv written` |
| compare_selftest.sh / gate_selftest.sh | SELFTEST PASS (16/16) / GATE SELFTEST PASS (13/13) |
| (6) byteverify F vs P (same binary; the predicted movers are the UVM coin family only) | surelog `MOVERS: 5 / 960` (MiniAmiq default+testflags, SeqDriver default+testflags, SimpleUVM testflags: the coin), uhdm2rtlil `0 / 1608`, downstream `0 / 805`; selfchecks 959/960, 1607/1608, 804/805. Probe databases embed the source's absolute path, and P ran from another checkout, so they are compared at the same location instead: F vs the cold run, 0 of 4087 differ (evidence/byteverify.txt) |
| canaries (F) | `canaries.sh`: surelog `ok=52 changed=0 absent=0`, u2r `ok=16 changed=0`. `EXPECT_UNKNOWN=1 ctcan2.sh`: `ok=58 … PASS`. `EXPECT_UNKNOWN=6`: `ok=2 … PASS` (evidence/canaries.txt) |

No targeted row: this pass changes no exporter byte, so no row moved in any corpus, and none in downstream
or the probe.

## 4. Residues, ranked

1. **The corpus golden key is Surelog's version line only.** v1.87 and uhdm2rtlil's v1.87-5-g04a865c0 both
   print `VERSION: 1.87` and key the same entry (evidence/r1_surelog_identity_key.txt). A Surelog pin bump
   inside one version line keeps serving the old goldens, and a cold cache filled by another build of the
   same line poisons it for everyone. tests/README.md and tests/probe/README.md say a pin bump changes the
   key, which holds only when the version line changes. The downstream lane already keys on the submodule's
   git revision. Not fixed: rekeying makes all ~30k corpus entries rebuild (about an hour), which is the
   user's call. The fix is the downstream lane's `@rev` in `_surelog_identity`.
2. **Status moves among non-equal statuses are CHANGEs** (exit 0), for example `CMP_NOTEQUAL -> SLANG_REJECT`.
   A `STRICT_NOTEQUAL` row whose verdict becomes `differ:?` (comparator exit 3: canon overflow or crash) or
   `timeout` is also a CHANGE. This is by design since the uhdm-cmp gate, and it is printed.
3. **Downstream EQUIVALENT rows** (2) are compared on verdict only. A larger `differs` set still passes.
4. **Timeouts under load** (verify_golden 180 s, Yosys 300 s) could fail a clean run. None did in 5 full or
   partial sweeps. `Google testflags` (`surelog timeout`) is stable in the baseline and every run.
5. `tests/sweep.sh --corpus ""` runs only the law index and exits 0. This is an explicit operator choice.
6. An A-direction edited-case false pass (A4) was not constructed. The content key closes both directions.
7. `tests/probe/README.md` is read-only here. It still says the key is the case's path, and should add "and
   its text". It also says "Any case not EQUAL fails the gate" (the flip's note 5). The
   `GOLDEN_EQUIVALENCE.md` 3.3 table reads surelog default `CMP_EQUAL=327 STRICT_NOTEQUAL=153`, while the
   baseline and `accounting.py --md` read `331 / 149`. This drift predates this pass.

## Files

- `attempts/*.sh`: one script per attempt (`<repo> <workdir>`), `mkfake.sh` (a scratch copy of tests/probe
  for A3, A4 and C2).
- `gate_selftest.sh <repo>`: G1-G13.
- `evidence/`: `<attempt>_base.log` / `<attempt>_fixed.log`, the sweep logs (P = base scripts, F = fixed,
  J = `--jobs 1`), the joins, byteverify, canaries and the negative controls. The A2 fixed log is condensed
  (the first 10 of its 1643 `REGRESSION HARNESS` lines).
