# r10v85 — adversarial verification of r10earl85 (§ srlgUnsizedBasedShiftBail85 + § paOvFoldedRangeNoStamp85 + § elabParamOpLeafValueFold85)

The verifier's report, verbatim (paths under /tmp were its scratch; its arms and
the census/grid/boundary tools it wrote are copied beside this file by the master
at landing).

All verification complete. Every headline number reproduced bit-for-bit; no regression found.

# VERDICT: **ACCEPT** — ship `/tmp/r10earl85.patch` **unchanged** (md5 `9ca0287e5c79189364cb9a3e3871af53`). No `.verified.patch`: I found **no pristine-right→patched-wrong cell on any legal SV**, so there was nothing to fix.

## 1. Bit-for-bit reproduction of every headline number

Fresh worktrees `/tmp/wt_v85` (patched) + `/tmp/wt_v85pris` at `d6bb922`, both built myself `-j 2`, md5'd separately, frozen `chmod 555` at `/tmp/v85_pris.bin` / `/tmp/v85_pat.bin` **before any sweep**.

| claim | implementer | **my independent measurement** |
|---|---|---|
| patch applies clean on fresh `d6bb922` | yes | **yes, 0 conflicts**, 37 files, surface = `src/ExprEmit.cpp` `src/ParamEmit.cpp` `include/UhdmExporter.h` + `tools/probe/r10earl85repro/` only; `results/*.csv` 0 hunks; slang 0 hunks |
| pristine binary md5 | `acb3029f2f7456c13be41ce88185d4cd` | **identical** |
| patched binary md5 | `3e8c14f93ca128fe962fd1dedebabdde` | **identical** |
| goldens | 23/0, `/bin/false` 0/23 | **23 PASS / 0 FAIL; negative control 0 PASS / 23 FAIL** (pristine also 23/0) |
| u2r rows | 0 differing, 679/50/2 | **0 differing** vs baseline, vs own pristine tf **and** default; `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` |
| surelog rows | 0 / 1588 | **0 differing ROWS / 1588**, status **and** dump histograms byte-identical both modes |
| row converted | none | **none** — `Earlgrey_0_1` stays `CMP_NOTEQUAL` in both modes; I edited no CSV |
| u2r byte movers | 0 / 1358 | **0 / 1358**, SELFCHECK 1357/1358 |
| surelog byte movers | 3 / 956 | **3 / 956**, SELFCHECK 955/956 |
| Earlgrey pristine hashes | `eca4492a7f16` / `3d2354c0922c` | **identical** |
| Earlgrey patched hashes | `e0571f86c482` / `664f81104e1f` | **identical** |
| kill switch A/B | `R10E85_OFF=1` == pristine, both modes | **reproduced byte-for-byte**: off = `eca4492a7f169f0b9db830674133a72d` / `3d2354c0922cde08366893a0cbef73f0` |
| heads | Earlgrey 214→90 / 144→150, all others unchanged | **exactly**: SeqDriver 28/28, SimpleUVM 12/12, Scoreboard 12, MiniAmiq 28/28, BuildUVMPkg 12/12, Rggen 0 |
| canaries | ok=52 / ok=8 changed=0, ctcan2 PASS/PASS, canaudit PASS | **identical**; `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **matched**; InterfaceModPort / BlackParrotComplex / YosysOldOr SAME |

**cmds.txt audited file-by-file by binary PATH**: `sl_pat` 1523 / `u2r_pat` 1458 name `/tmp/v85_pat.bin`, `sl_pris`/`u2r_pris` name `/tmp/v85_pris.bin`; **zero** reference to any main-tree binary. `GOLDEN_DEFER` never set. Fence grep over `tools/probe/r10earl85repro/` (excluding `canaudit.sh`): **0 hits**, no fenced test dispatched.

**Head OBJECT genuinely gone.** Pristine's head in *both* modes was `param_assign id:401986` at `flash_erase_ctrl.sv:41:31` (`PageAddrMask`). `grep -c '41:31'` on both patched head logs = **0**. The testflags 144→150 growth is depth, not distance.

**Third surelog mover attributed.** Mine was `Scoreboard/default` (theirs was `MiniAmiq/testflags` — both documented coins). Order-blind sorted-dump diff **0 lines** on 1,099,213 lines; unsorted **92 lines** — the documented svunit_pkg `vpiTaskFunc` order flip, exactly.

**Corpus-internal check on the only two databases that changed.** `pacen85` census of both Earlgrey DBs (golden from each test's own cache path):

| | default | testflags |
|---|---|---|
| BOTH-SAME | 11 015 | 13 105 |
| **WRONG→RIGHT** | **2** | **2** |
| **RIGHT→WRONG** | **0** | **0** |
| **WRONG→OTHER** | **0** | **0** |

Key sets pristine == patched **identical** in both modes. The 4 moved cells are exactly `PageAddrMask` (41:31) and `BankAddrMask` (42:31) at `u_flash_ctrl.u_flash_erase_ctrl`. FAMILY-OPKEPT **3+3 → 1+1**, FAMILY-OVSTAMP **8+8 → 8+8** — i.e. their claimed 6→2 / 16→16. The surviving OPKEPT cell is `prim_flop_2sync.sv:9 ResetValue`, their named R3.

**Wide boundary, my own run**: `PROCESSED=3820 == LISTED`, fd-3 list, children `</dev/null`. identical **7314**, DIFFERING **32** = their 18 + my 12 grid files + `g7_v84cell85.sv`×2 (see F8). `rc=139` **28**, perfectly symmetric (14 files, `elab` only, both sides) — matches their histogram. **`r10earl73repro`, `r10earl71repro`, `r10earl80repro`, `r10rgg18repro` — and `earl59/60/61/64/72/81`, `uvm118`, `buvm29` — 0 differing files.** The required must-stay controls are byte-identical.

**`r10buvm22repro/g22.sv` independently cleared.** 3 runs of each binary: each is self-deterministic; `R10E85_OFF=1` reproduces the **patched** hash `89b4e46ce43a4b740e7e453cf160fed4`. The whole delta is 12 dump lines, all address-derived values (`22449657` vs `22466073`, differing by a code-size shift) — earl84's R5, not this law.

## 2. Breaking the law — my own adversarial grid (10 files × 2 views = 20 arm runs, all against Surelog golden)

`/tmp/v85_grid/va{1..9,A}*.sv`, scored three ways: the `pacen85` param_assign census, an **indentation-aware whole-dump object census** (each object's own scalar fields, span-keyed), and `uhdm-cmp`.

| arm | matrix covered | result |
|---|---|---|
| `va1_unary85` | `~ - ! & \| ^ ~& ~\| ~^` × {sized lit, unsized lit, folded shift-minus, folded add, param ref, `$clog2`, concat, ternary} × widths 8/17/32/33/64/65 × `logic[W-1:0]`/`int`/`bit signed`/`logic signed`/implicit × nested `~(~x)` | **W2R 50/49, R2W 0** |
| `va2_homes85` | module / gen-for / gen-if / interface / package homes, 1–3 instances, overridden + not | **W2R 20/27, R2W 0** |
| `va3_shadow85` | OV stamp: wildcard-shadowed vs not vs no-import vs explicit import | **W2R 3, R2W 0** |
| `va4_leaf85` | leaf fold × 10 declared types × overridden/not × package bare/qualified × sub-expression/`$clog2`/concat, 2 instances | **W2R 32/30, R2W 0** |
| `va5_ctx85` | cont-assign, net-decl-assign, var init, packed range bound, port actual, `always_comb`, case item, replication | **R2W 0** |
| `va6_unbased85` | the UNBASED family (r10oth2's own law) incl. `'{default:'1}` / `'{'1,'1}` | **W2R 2, R2W 0** |
| `va7_lits85` | 33 literal spellings — `'h 'H 'd 'D 'o 'O 'b 'B 'sh 'sb 'sd 'so 'SH`, `'h 1`, `'h1_0`, `>> >>> <<<`, amount-side size(−1), no-shift | **W2R 24, R2W 0**; one law-boundary defect found (F1) |
| `va8_ov85` | OV stamp × `bit`/multi-dim packed/`2*W`/`W:0`/non-integer pkg member/gen-scope/interface, 3 instances | **11 OV cells fixed, R2W 0** |
| `va9_ovedge85` | can the suppression fire while the range still names the param? `$clog2` bound, typedef-typed, 2-D, ternary bound, qualified read, unpacked | **W2R 2, R2W 0; never fires wrongly** |
| `vaA_misc85` | class param, function body + default arg + local, package localparam, enum const, for-loop bound | **W2R 8/9, R2W 0** |

`RIGHT→WRONG = 0` in all 20 runs, and `patched_delta < pristine_delta` on the whole-dump object census in every single arm. On the head shape itself the patched database is **line-for-line identical to golden** in the region (DEF copy keeps `ref_obj W`, ELAB copy carries the folded constant — no shared-object corruption from the in-place operand rewrite).

Three decodes I confirmed in the sources rather than taking on trust: `ExprEval.cpp:3050/3137` do set `invalidValue` on a size(−1) `arg0`; `vpiBitNegOp:3415` opens `if (invalidValue) break;`; `CompileType.cpp:2230-2330 isOverloaded` walks only range **objects** and returns true only for a surviving `ref_obj`/`parameter`/`type_parameter`. The carve-out is load-bearing and correct: `'b1 <<` appears **99×** in the corpora and golden folds it (cell k07); `'h1 <<` appears **114×** and golden bails (k01).

## 3. Findings (ranked; none blocks the landing)

**F1 — the `'b0`/`'b1` carve-out over-matches the SIGNED spelling.** Measured, `va7_lits85` cell **k13**: golden keeps `~('sb1 << W)` as `operation 4 / 22`; both binaries fold it to `constant UINT:4294967279`. `'b1`/`'B1`/`'b0` (k07/k08/k09) correctly fold, and `'sh1`/`'sd1`/`'so1` (k12/k14/k15) correctly bail — only `'sb0`/`'sb1` are wrong. Cause: `srlgUnsizedBasedLit85` (`src/ExprEmit.cpp`) strips `s`/`S` before testing `base85 == 'b'`, so the value-`"0"`/`"1"` carve-out swallows the signed spelling. Minimal fix: remember that a sign letter was consumed and skip the carve-out when it was. **Corpus incidence 0** — grep of both corpora finds `'sb0` twice (never a shift left operand) and `'sb10110 <<` twice (value `"10110"`, correctly not carved out). Pre-existing wrong → still wrong, not a regression; the README's "the `'b0 / 'b1 / 'B0 / 'B1` spellings are EXCLUDED" should read "the UNSIGNED `'b0`/`'b1` spellings".

**F2 — the `derivedOv9` text scan mis-fires on a PACKAGE-QUALIFIED read too.** `va2_homes85` `PkgRangeMask`, declared `logic [q85b_pkg::AddrW-1:0]` in a module whose own `AddrW` is overridden: golden `vpiOverriden:0`, both binaries `1`. The boundary test accepts `:` as a left word boundary, so `pkg::AddrW` matches the local name. This is the *same* law the pass decoded ("the stamp follows the emitted range") reached by a second route, and it is the natural widening of § `paOvFoldedRangeNoStamp85`. Pre-existing, unchanged by the patch.

**F3 — R2 is wider than the report says.** The unmasked `~` fold is claimed as "0 corpus cells, arm cells g1 u02/u03/u04". It also hits **concat** and **ternary** operands: `~{4'hf,4'h0}` golden `UINT:15` vs ours `UINT:4294967055`; `~{'h1,4'h0}` golden `UINT:7` vs ours `UINT:68719476719`; `|{'h1,4'h0}` golden `0` vs ours `1`; `~((W>4)?8'hf0:8'h0f)` golden `UINT:15` vs ours `UINT:4294967055` (`va1` cells f01/f02/f03/g01/g03, plus b03 `-('h1+W)` golden `INT:-9 ct7` vs ours `UINT:4294967287 ct9`). All pre-existing, patched == pristine.

**F4 — the boundary accounting for `r10v84repro/v7_more84.sv` rests on a census that cannot see the moved cell.** The report scores that file "WRONG→RIGHT 1 / RIGHT→WRONG 0"; my param_assign census agrees, but the file's **port-actual part-select base** also moved and is invisible to `pacen85`: `sinkv84 #(.W(8)) u_op (.a(reg2hw.addr.q[Op +: 8]))` where `Op = ~(('h1<<3)-1'b1) & 32'h7`. Golden's elab `hier_path` is named `reg2hw.addr.q[~'h1 << 3 - 1'b1 & 32'h7+:8]`; pristine `[0+:8]`, patched `[Op+:8]`. `VpiName` is a Compare field, so all three differ — **WRONG→OTHER, not a regression** (pristine was already wrong), and it is the new head there (76→165 lines is depth: the pristine head, the `Op` param_assign operation at 32:25, is cleared). Worth naming as an R0 sibling: an operation the bail keeps still needs *inlining* into a part-select base, not a surviving `ref_obj`.

**F5 — a new WRONG→OTHER shape: the ternary is not arm-selected inside a kept operation.** `va1` `g02 = ~((W>4) ? ('h1<<W) : 8'h0f)`: golden's ELAB copy is `operation 4` over `operation 22` (the reducer selected the true arm), patched is `operation 4` over `operation 32` (ternary kept), pristine was a folded constant. Patched now gets the kind and the typespec right and the operand wrong; pristine got everything wrong. Same family as R0-default (fold the maximal non-bailing operand subtree).

**F6 — the OV suppression never fired wrongly, but a typedef-typed range is out of its reach.** `va9` `E2` (`typedef logic [AddrW-1:0] tw_t;` used as the param type): our emitted range still names `AddrW` and `vpiOverriden:1` survives in **both** binaries where golden has neither — the scan is skipped because `rng8` is empty for a `NamedType`. Pre-existing; a second widening target for the same law. In every cell where the suppression *did* fire (`va8` A1–A5 ×2 instances + interface D1, `va9` E1/E3/E4/E5/E6), the emitted range had **no** surviving ref and golden had **no** stamp — the proxy holds on all 17.

**F7 — REQUIRED AT INTEGRATION: `RESUME.md` §3b goes stale with this landing.** §6's own rule ("DOCS IMPLIED BY THE LANDING RIDE WITH IT") and the 2026-08-18 user direction apply, and §3b was last refreshed *at earl84*, one landing ago. Its `Earlgrey_0_1×2` row still reads `214 default / 144 testflags` and names `PageAddrMask` as the head. The replacement, measured: **90 default / 150 testflags**; **R0-default** = `flash_erase_ctrl.sv:42:57` inside `BankAddrMask`, golden folds the shift amount `(PagesBitWidth + WordsBitWidth)` to `constant UINT:16 vpiSize:32` where we keep `operation vpiOpType:24` over `constant UINT:8`; **R0-testflags** = `param_assign 12:18 PagesPerBank` at the same instance, golden `vpiOverriden:1`, ours unset — the FAMILY-OVSTAMP direction, 16 corpus cells. The patch as delivered touches no docs, so the master must add this edit in the landing commit.

**F8 — reporting nit.** `BOUNDARY_WIDE.tally` (`PROCESSED=3813`, `DIFFERING 18`, "14 my own arms") predates `g7_v84cell85.sv` being added to the repro dir; that file is a copy of `r10v84repro/v7_more84.sv` and differs in both views, so the true count for the committed tree is 8 arms → **16 own + 2 + 2 = 20**. Cosmetic; refresh the tally or re-run.

## Artifacts

Worktrees `/tmp/wt_v85` (patched), `/tmp/wt_v85pris`. Frozen binaries `/tmp/v85_pris.bin`, `/tmp/v85_pat.bin`. Sweeps + workdirs `/tmp/v85wd/`. Adversarial arms `/tmp/v85_grid/va{1..9,A}*.sv`, built dirs and scores under `/tmp/v85_arms/<arm>_{plain,elab}/{g,o,q}.uhdm,.rows,score.txt,cmp_{o,q}.err`. Wide boundary `/tmp/v85_wide/OUT.{tally,diff,rc,rc_histogram,signal}`. Earlgrey census `/tmp/v85_cen/eg_{default,testflags}.{g,o,q}.rows` + `.score.txt`. Kill-switch A/B `/tmp/v85_ab/{def,tf}/slang.uhdm`. Head logs `/tmp/v85_heads_{pris,pat}/`. Scorers `/tmp/v85_tree.py` (indentation-aware object census), `/tmp/v85_dumpscore.py`, `/tmp/v85_g22det/` (determinism).
