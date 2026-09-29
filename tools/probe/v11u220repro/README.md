# v11u220repro: the adversarial verification of pass 220 (r11u220), CONFIRMED with no fix

This directory holds the verifier's fresh cases, drivers and evidence. The verifier delivered it without a README; the integrator wrote this one from the verifier's final report, unchanged below apart from this note and the title. Each case file names the law it tests on its first line.


I found no break. All 190 case-views of my fresh grid, plus 28 more from 14 later cases, stayed where they were or moved toward golden. Nothing left EQUAL, no judge-equal case became stage 1, and no downstream verdict or RTLIL changed. The source stands as delivered, so there is no `/tmp/r11u220.verified.patch`. The integrator should use `/tmp/r11u220.patch` (md5 `6a2463b485df74610a10d6f1340d1bb9`), which applies cleanly on a fresh `57ce3ae8`.

Three checks the brief asks for are not done by me; the numbers for them are the implementer's. The Bash safety check failed nine times in a row near the end, so I stopped before a tenth failure would end the session:
- the three-concurrent-runs determinism check on Earlgrey_0_1 and the UVM rows;
- the UVM order-blind distance (MiniAmiq 6266 → 2786, SeqDriver 4969 → 2493, and so on);
- the reversed positive control on the corpus-wide away census. I did run the reversed control per case: C/c02 reads away 8, toward 0, the exact mirror of its forward reading.

## Binaries and builds
- **pristine.bin** `de9af7b93a576744d480028edeee07ed`: matches the required md5. It was frozen before any measurement.
- **law.bin** `0c0c5c4dc782b8265c226971d7585f85`: rebuilt from the patch in `/tmp/wt_v11u220` and byte-identical to the implementer's.
- **comp896.bin** `2510f4fe44619abb4eae492a1a0e737f`: `896ec643` plus the patch applied 3-way. Only `tests/LAWS.md` conflicted and regenerating it fixed that. Also byte-identical to the implementer's.
- **strictcmp_x** `5bbd7f8373a051201b6367d6f0d615a7`, built with `tools/probe/r11u211map/drivers/cc.sh`; uhdm-strictcmp `fa6e4f42…`.
- **Binary audit:** 3273 of 3273 `slang:` lines in each sweep's `cmds.txt` name the right binary (pristine.bin in one, law.bin in the other).
- The r11u218 law patch is in the source exactly as `tools/probe/r11u218dec/law_exprstmt.patch`. The only additions are the `R11U220_OFF` hook in `src/R218.h` and this pass's calls. All `R11U218_*` switches are kept.

## Gates (my sweeps, `tests/sweep.sh --jobs 3`)
Every headline number reproduces exactly:

| stage | pristine vs `57ce3ae8` baselines | law.bin |
|---|---|---|
| probe | 3422 + 665, 0/0/0; csv byte-identical to the base commit's `golden_probe.csv` | 3433 + 654: 0 regressions, 11 conversions, 11 changes (the implementer's exact list) |
| surelog | 929 + 25, 0/0/0 | 0 regressions, 0 conversions, 7 changes |
| uhdm2rtlil | 1598 + 8, 0/0/0 | 0 regressions, 2 conversions |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0; csv byte-identical to pristine's |

- **Surelog changes:**
  - BuildUVMPkg d/t `line(31)` → `line(19)`
  - Earlgrey_0_1 d/t `endcol(45)` → `fullname(25)`
  - SimpleUVM d/t `fullname(185)` → `fullname(183)`
  - Scoreboard d `fullname(137)` → `fullname(135)`
- **uhdm2rtlil conversion, fresh rows:**
  - `anon_struct_packed_dim,default,CMP_EQUAL,,,equal`
  - `anon_struct_packed_dim,testflags,CMP_EQUAL,,,equal`
  - Its downstream row: `anon_struct_packed_dim,IDENTICAL,OK,OK,52,52,,`
- **Why EXIT=1 on both sweeps:** only the stale `tests/LAWS.md` notice (my new, untracked directory in the law worktree, and the base commit's own index). The composition sweep, where the index was regenerated, reads EXIT=0.
- **Canaries:**
  - surelog law ok=45 changed=7 (exactly those seven); pristine ok=52.
  - uhdm2rtlil ok=16 on both binaries.
  - ctcan2 PASS for surelog (EXPECT_UNKNOWN=1) and uhdm2rtlil (EXPECT_UNKNOWN=6) on both binaries.
- **uhdm-cmp:** every touched row and probe case is still judge-equal (CMP_EQUAL or STRICT_NOTEQUAL), so uhdm-cmp reads 0 lines on each.

## Movers, predicted before the law sweep
- I ran my own firing census with the law binary's traces over the corpus (with the fenced rows excluded by `--filter`), every probe case and every downstream lane.
- The prediction was frozen at 2026-09-29 02:06:32 (md5 `c11a57e9…`), before the law sweep started. It names 40 rows, the same rows and firing counts as the implementer's `predict_final.txt`.
- **Corpus:** byteverify on mirrors with the 8 fenced row-mode databases left out finds 13 of 2560 movers, exactly the prediction.
  - SELFCHECK reads 2559 of 2560. That is an artifact of the self-check: it compares every file against one fixed file, and that file compared with itself can never be flagged.
- **Probe:** 26 of 4087 movers, exactly the prediction.
  - My first comparison showed every probe file differing. That was because probe databases embed the worktree's absolute path, so I re-ran the pristine probe stage from the law worktree.
- **Downstream:** 1 of 805 lanes moved (anon_struct_packed_dim). Its `.il`, `_nohier.il` and `_synth.v` are byte-identical to the pristine lane's.
- **Away census over the 39 moving databases (chain-keyed):** 0 away, 7730 toward.
  - The flat census reads 598 away: MiniAmiq d/t 154 each, SeqDriver d/t 143 each, g208_e_head 4.
  - These are the subtrees of the minted return variables that § importCloneSharesHomeReturn218 leaves unreferenced. I did not re-measure that attribution; it is the implementer's (flat away 0 with `R11U218_CLONERET_OFF`).

## Landing-205 switch reach
Over 156 case-views (every r11u205dec case plus IA, both views; FT/f03 is rejected by slang on both binaries):
- `R11U220_LANDING205A_OFF` moves exactly 2 (IA a02 and a05, parse view), byte-identical to `R11U205_IFARRIDX_OFF` on all.
- `R11U205_OFF` moves 34.

## Composition with current main (`896ec643`)
0 regressions in every stage and downstream 803/66/2/0.
- Probe: the same 11 conversions and 11 changes.
- Surelog: 7 changes.
  - BuildUVMPkg d/t `line(31)` → `line(19)`
  - Earlgrey_0_1 d/t `endcol(39)` → `fullname(19)`
  - SimpleUVM d/t `file(56)` → `file(54)`
  - Scoreboard d `file(32)` → `file(30)`
- uhdm2rtlil: anon_struct_packed_dim d/t converting.

## Breaking the laws: fresh grid
95 fresh cases, each in both views (190 case-views), judged by uhdm-cmp and uhdm-strictcmp against the v1.87 goldens, plus 41 of them through the downstream harness. Case families:
- **T** (19): the string end-column rule.
- **K** (15): string literals continued over lines.
- **W** (15): `new[...]` arguments.
- **G** (20): a path's trailing var_select.
- **C** (14): select indices in importer clones.
- **Q, H, X, R** (15): fresh cases of the four landed r11u218 laws.

Results:
- **113 case-views convert, 0 leave EQUAL, 0 go from judge-equal to stage 1, every exit code is 0.**
- `R11U220_OFF` writes the pristine bytes on all 190.
- Away census on every moved case-view that did not convert: 0 away everywhere. That covers 130 judge-equal case-views (chain-keyed and flat) and 28 stage-1 ones (self-keyed with strictcmp_x).
- **Downstream:** 41 cases, verdicts and `_nohier.il` hashes identical between pristine and law (36 IDENTICAL; 3 DIVERGENT and 2 EQUIVALENT on both binaries). The 3 DIVERGENT are pre-existing faces this pass does not touch: t19 is a string value encoding, k01 and k08 involve continued literals.

14 later cases, run only with the per-case driver (T/t20, K/k18, G/g24–g29, C/c18–c23), cover the brief's remaining shapes: an include file with a macro-born string, a continued literal from an include, super/this paths, streaming, a var_select in an lvalue index, a nested read index, an implicit net index, a generate with a select target, and clone indices that are hier_paths, method calls, calls, part selects and casts. None broke: 18 case-views convert (8 cases in both views) and none leaves EQUAL. The rest are unmoved or moved with 0 away.

## Residues found, not breaks (each is wrong on both binaries)
Ranked by how easy each is to act on:
1. **Backtick-tab string (T/t12).** § strLitShiftNeedsBacktick220 counts a tab after a backtick as a blank. Golden keeps the source span there (`3:15-24`; ours `-28`).
   - In Surelog, `SV3_1aPpTreeShapeListener::enterString` re-evaluates every string that contains a backtick, and the shift comes from what that evaluation changes. Limiting the predicate to backtick-space would convert this case.
   - Related: a double backtick then a blank (T/t14) leaves only the `initial`'s end column wrong.
2. **Conditional ending at a continued literal (K/k04, `c ? "x" : "ab \⏎cd"`).** The operation and the assignment keep the old two-line end. The drain only handles a literal that is the right side directly.
3. **Continued literal from a macro (K/k09).** The line is pre-existing wrong; the assignment's end moved 3:6 → 5:24 where golden has 2:24. Wrong to wrong, 0 away.
4. **The r11u218 path-select naming joins `.` after a `::` scope (C/c23).** A package-class `arr[i].v[k+:2]` gives ours `p1::c::f.arr[i].v[k+:2]::k` against golden `p1::c::f::arr[i].v[k+:2]::k`. This predates the patch; ExprEmit, this ground.
5. **Clone select indices the drain does not reach:** a call as the index (C/c21: `arr[g(i+k)]` and `arr[g(arr[i].a)]`), a part select of the index (C/c22: `arr[i[1:0]]`, `::arr::i`), and the index names in the home listing.
6. **var_select as an lvalue (G/g07: `s.arr[i][1:0] = d`).** Golden names the index `work@top.s.arr[i][1:0].i`; the law covers reads only.
7. **Pass 215's writer stamp against r11u214's writer law** (brief item 1): not measured, by me or the implementer. r11u219 is now landed, so it can be measured at `896ec643` with `R11U215_TDALIAS_OFF` / `R11U215_ENUMCLONE_OFF`.
8. The implementer's residues stand as written: the sister-ground halves of InterfArrayBind, OutputSize, the nested-class writers and the UVM heads; the other backtick-blank shift (SL s30–s39); `new[arr[k+1]]`; CI c09; BlackBePipeInt #66 and #15272; FuncStructVal #747; N0008; the value encodings; map 13's N0739 / N1903 / N1904 / N0476 / N0477.

## Fence and process
- Every driver reads the four fenced names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed.
- No binary or script ran on a fenced test's sources or databases outside the gate sweeps. The only fenced facts used are the gate csv verdicts, plus a grep of `cmds.txt` for the binary path.
- I killed no process. Every file I wrote is under `/tmp/wt_v11u220*`, `/tmp/v11u220_*` or the session scratchpad.
- The worktrees and scratch are still on disk: `/tmp/wt_v11u220`, `/tmp/wt_v11u220pris`, `/tmp/wt_v11u220H`, `/tmp/v11u220_l218wt` (unused, can be removed), and `/tmp/v11u220_*`.

Files are in `/tmp/wt_v11u220/tools/probe/v11u220repro` and `/tmp/v11u220_scratch`:
- `cases/`: the fresh cases, each naming its law on its first line
- `drivers/`: `vcase.sh`, `vgrid.sh`, `dsgrid.py`, `vaway.py`, `vaway1.py`, `env.sh`
- `evidence/census/predict_v.txt` and `predict_v.stamp`: the frozen prediction
- `grid_P.txt`, `grid_L.txt`, `grid_LOFF.txt`: the grid under each binary
- `grid_away.txt`, `grid_away1.txt`: the per-case away census
- `ds_P.txt`, `ds_L.txt`: the downstream grid
- `reach205.txt`: the landing-205 switch reach
- `swP.log`, `swL.log`, `swH.log`: the sweeps
- `away_law.txt`: the corpus-wide away census

The `v11u220repro` directory has no README and is not in any patch.