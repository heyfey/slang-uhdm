# r10earl105 — VERIFIER VERDICT: **ACCEPT AS SHIPPED**

No `.verified.patch`: I found **no pristine-right → patched-wrong cell on any legal SystemVerilog I could construct**, so there is nothing to fix. Ship `/tmp/r10earl105.patch` (md5 `304c1a8b83b20bdc9fb753d39c18d170`) unchanged.

Worktrees `/tmp/wt_v105` (patched) and `/tmp/wt_v105pris` (pristine), both fresh at `cd1e4c0a`. Patch applied `git apply -3`, rc 0. Surface audit: `src/ExprEmit.cpp` +222/−2 is the **only** file under `src/` or `include/`; `results/*.csv` untouched; slang not patched; the four fenced names appear 0 times in the diff; `GOLDEN_DEFER` unset.

## 1. EVERY HEADLINE NUMBER REPRODUCED BIT-FOR-BIT

I built both binaries myself, `-j 2`, md5'd separately, froze them `chmod 555` at `/tmp/v105_pris.bin` / `/tmp/v105_patched.bin` before any sweep, and exported `SLANG_UHDM` explicitly per binary.

| claim | implementer | mine |
|---|---|---|
| pristine md5 | `f03b9172df4dcc0900ab7af35d35ffa5` | **same** |
| patched md5 | `44486814fbddd146e2af71c4fddc0310` | **same** |
| Earlgrey_0_1 testflags heads | 50/1 → 26/1 | **50/1 → 26/1** |
| Earlgrey_0_1 default | 31/1, head log byte-identical | **31/1, `diff` empty** |
| the other 10 head logs | unmoved | **11 of 12 `.cmp` files byte-identical; only Earlgrey/testflags differs** |
| surelog movers | 3/956 (2 predicted + Scoreboard coin) | **2/956** — `default/Earlgrey_0_1 02b37834ae6d ← 5b86d1db45c6`, `testflags/Earlgrey_0_1 da7542fd91e5 ← 57e778aad5aa`, hash-for-hash identical. **Scoreboard did NOT flip in my run** — which is the strongest possible confirmation that their third mover was the recorded coin, not the law |
| u2r movers | 0/1358 | **0/1358**, PATH_SETS_IDENTICAL |
| census surelog | 12 736 cells, AWAY 0 / WRONG 0 / TO-GOLDEN 238 | **identical, cell for cell** (10 331 UNMOVED-GOOD, 1 898 UNMOVED-BAD, 269 UNREACHABLE, 0 UNREACHABLE-CHANGED); families 116 IDW + 58 STIDW (40+18) + 64 MioPeriphHasSleepMode (32+32) |
| census u2r | 264 cells, 0/0/0 | **identical** (260 / 4) |
| `--judge` projection | 0 / 0 | **0 / 0**, TO-GOLDEN 238 |
| whole-dump attribution | 2470 default / 2534 testflags changed lines | **2470 / 2534**; I classified the 2 113 lines that do not spell a family name and every one is a field line of the substituted constant (`vpiSize`/`vpiDecompile`/`vpiConstType`/`ref_typespec`/`int_typespec`) under `u_xbar_main.u_sm1_*` or `u_pinmux`. The `58 <  \_operation:` rows are the *removed `vpiParent` line* of the old `ref_obj`, not a replaced operation |
| `cmds.txt` audit | 0 of 6070 name the main tree | **0 of 6070**; 2981/3035 per sweep name the correct frozen binary; **0 cross-contamination in either direction** |
| status histogram | 471/466 EQ, 10/9 NE, 283/284 REJECT, 25/23 SURELOG_FAIL | **identical** |

**Gates, all re-run by me and green:** goldens 23 PASS / 0 FAIL, `/bin/false` 0/23 · `ct8rows` **0 differing rows** for surelog vs `results/golden_surelog.csv` **and** vs my own pristine, and for u2r testflags vs `results/gate_uhdm2rtlil.csv`, testflags vs my pristine, default vs my pristine — **no row converts** · canaries `ok=52 changed=0` / `ok=8 changed=0` · ctcan2 PASS both · canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` · protected DBs all SAME with the exact pins (`SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `ReplicationPassedToInstance 48d4b425cfca`/`761e1d318376`, InterfaceModPort/BlackParrotComplex/YosysOldOr byte-identical).

**Wide boundary, mine:** LISTED 4726 (their 4715 plus 11 of my arms), **PROCESSED = 4726**, `FENCED=0`, rc perfectly symmetric (0: 8687/8687, 3: 362/362, 4: 387/387, 139: 16/16), DIFFERING **45 = their 25 + my 20**. Their 25 reproduce name-for-name.

**The Surelog decode is verbatim-correct.** `~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:2919-2952` holds exactly `clone_tree(param_ass->Rhs(), &elaboratorContext)` → `result->VpiParent(param_ass)` → `populateCoreMembers(child, child, result)`, and `if (result == nullptr)` is the `ref_obj` fallback.

## 2. BREAKING THE LAW — 13 new arms + 33 re-run, AWAY-GOLDEN 0 everywhere

Instrument first: **positive control** — feeding `score105.py` the two sides swapped on `v7_repl105` turns its 28 TO-GOLDEN into **28 AWAY-GOLDEN**, so the zero is a measurement, not a blind scorer. Independent **golden-vs-golden calibration** on my own arm: `agree=148 disagree=0 only_golden=0 only_ours=0`.

Every substitution face × home × instance count I could reach:

| arm | what it attacks | result |
|---|---|---|
| `v1_old105` | the OLD top-module windows with `int` params in hex/octal/binary/negative spellings, 12 positions | 32/1 → 32/1, **0 movement** — the clone arm never fires on a plain `int` (its Rhs typespec ref is bound late) |
| `v2_inst105` | **three instances** of one leaf, overrides `2` / `4'b0010` / `1+1` and `3` / `4'h3` / `6'o03`, plain + select | TO-GOLDEN 18, **AWAY 0**; each instance carries **its own** override (`u_dec` `UINT:2`, `u_bin` `BIN:0010 sz4`, `u_exp` `UINT:2`, `Q` `HEX:3 sz4` only in `u_bin`) |
| `v3_unk105` | the missing `cvL9.isInteger() && !hasUnknown()` guard: x/z 4-state vectors, `real`, `string` | **none reach the copy**; AWAY 0, MOVED-WRONG 2 → **0 under `--judge`** |
| `v4_home105` | module scope, top-level gen-IF, gen-local localparam, genvar, gen-IF-in-loop, loop-in-loop, loop-in-gen-IF | 23/1 → **0/0 CMP_EQUAL**; every fenced home keeps `ref_obj` **and golden keeps it too**, cell for cell |
| `v5_w1_105` | earl55's width-1 mints; a param read in a substituting **and** a non-substituting ($clog2 arg) position in one scope | TO-GOLDEN 4, cmp unchanged, mints stay |
| `v6_port105` | port actuals / whole-actual reads inside the loop body (the `high_conn` territory) | AWAY 0, no port cell moves |
| `v7_repl105` | **the sharpest probe** — a replication-folded param (earl104's eager typespec) in the OLD select windows, top module **and** child | 23/1 → **0/0**, TO-GOLDEN 28 |
| `v8_ts105` / `v10_tdef105` | typedef'd `int`, typedef'd signed vector, enum-typed, package-qualified params | AWAY 0; one new residue, below |
| `v9_depth105` | **instance depth 3** and an **interface** home | TO-GOLDEN 12, AWAY 0 |
| `v11_edge105` | the `(!inLhs \|\| inPsBound)` gate (LHS bit-select vs LHS indexed-part-select), a hierarchical Rhs, a net-range read | TO-GOLDEN 4, AWAY 0 |
| `v12_untyped105` | untyped and ranged-untyped replication sources (where the two halves of the patch disagree by construction) | TO-GOLDEN 8, AWAY 0 |
| **earl104's 15 arms + the 7 verifier arms** | its law must be undisturbed | AWAY 0 / WRONG 0 on all 44 rows; **`vb2_genfor` 0/0 → 0/0 and `vb4_instarr` 0/0 → 0/0** |
| **earl55's 13 arms** | the width-1 mints | every cmp count byte-unchanged, AWAY 0 |

**Both cmp-line rises verified independently, by object identity:** `r10v69repro/v5_inst69` — the head **object moved forward**, `hier_path arr[i].g[7+:8]` id 917 at 18:20 → `arr[i].g[7 + i+:8]` id 941 at 22:20 (the first head cleared, TO-GOLDEN 36). `r10earl_repro/qg21` and `r10earl104repro/g5_gscope104` — the head is **the same object id on both binaries** (`constant id:391`, `constant id:3871`); golden folds the whole Rhs and we keep an operation, so Compare stops above and the growth is that head's print. Counts are depth, not distance.

**R0 confirmed at the byte level.** My `Earlgrey_0_1.testflags.cmp` is byte-identical to the committed `HEAD_AFTER_Earlgrey_testflags.cmp`, object ids included: golden a loc-less `vpiDecompile:63 vpiSize:8 UINT:63 ct 9`, ours `39:24-39:38 sz 64` with no spelling — the `padctrl.sv:39` cast fold in the gen-IF `u_padctrl.gen_generic`. The `RESUME.md` §3b edit matches what I measured (31/26).

## 3. RANKED RESIDUES — three the pass did not name

**R-A (highest — the pass's own stated principle, violated once).** `intAtom105` is [`getCanonicalType().isPredefinedInteger()`](src/ExprEmit.cpp#L16041), which is **true for a `typedef int`** — so the encoding half answers the new window there. But golden's substituted constant carries the **typedef's name** on its `int_typespec`, because when the clone has no typespec Surelog **shares the parameter's own declared typespec** (`CompileExpression.cpp:2955-2975`, `tps_rt->Actual_typespec(tps)`), and `BaseClass::Compare` reads `VpiName`. The mint at [`src/ExprEmit.cpp:16159`](src/ExprEmit.cpp#L16159) copies neither the name nor `Typedef_alias`. Measured on `v10_tdef105`: golden `int_typespec name=v10_myint_t,signed`, ours nameless — MOVED-WRONG 2 in both views and **under `--judge` too**. **Not a regression** (pristine emitted a `ref_obj`, strictly further away) and masked here by a bigger pre-existing defect on the same shape (our parameter's *own* typespec also lacks the alias, so both binaries stop at the identical head, 20/1 → 20/1). But it is an inexact clone in a window the pass promised to answer "only by a clone it can build exactly". Fix: fence `intAtom105` to a non-typedef canonical type, or carry the source typespec's `VpiName`/`Typedef_alias`.

**R-B (a new self-inconsistency inside one scope).** The encoding half is gated on `loopPlainNew105` at [`src/ExprEmit.cpp:16004`](src/ExprEmit.cpp#L16004), so in **one and the same** gen-loop body of one child instance, `assign r0 = P ^ sig;` now gets the override's encoding (`BIN:0010 sz4`) while `assign r1 = sig[P];` keeps the decimal mint (`UINT:2 sz32`) — golden copies in **both**. On `v2_inst105` the patched head becomes exactly that select cell (`u_bin.gen_i[0].r1` at 13:21), and the cell is **byte-identical between the two binaries** — a pre-existing wrongness newly exposed, not a regression. Lifting `adjustCopiedParamConst64` into `caLoopSelPos21` takes those cells; it is worth its own pass because the dump column is the risk.

**R-C (latent, currently unreachable).** The full-clone arm carries **no** `cvL9.isInteger() && !cvL9.integer().hasUnknown()` guard, which the mint it preempts does carry. `v3_unk105` (x/z 4-state vectors, `real`, `string`) proves nothing reaches it today — those sources carry a `logic_typespec`/`real_typespec`, not an `int_typespec` — so it is a latent widening, not a live one. Worth a comment or the guard.

**One documentation correction, not a defect.** The README's §7 grid reports `g3`/`g4` unchanged, which reads as "the old windows are untouched"; §3(b) says the full clone "Runs in every window" but ships no arm that exercises it there, because `g3_sel105` uses `logic`-vector parameters that decline. My `v7_repl105` supplies the missing evidence and it is a **gain**: with a replication-folded parameter the clone preempts the decimal mint in the bit-select index, the indexed-part-select base, the part-select bounds and the operation-index positions too, moving 20 cells from `UINT:5 sz4 ct9` to golden's `BIN:0101 sz4 ct3` in **both** the top module and the child, and taking the arm 23/1 → **0/0**. The old-window reach is correct — it was simply unmeasured.

## Artifacts

Frozen binaries `/tmp/v105_pris.bin`, `/tmp/v105_patched.bin`; sweeps `/tmp/v105_wdP` (pristine) and `/tmp/v105_wdA` (patched) left in place for control rotation; head logs `/tmp/v105_headsP` / `/tmp/v105_headsA`; my arms `/tmp/v105_arms/v{1..12}_*.sv` + `TOPS.txt` + `vgrid105.sh`; grids `/tmp/v105_grid`, `/tmp/v105_grid55`, `/tmp/v105_gridB`; wide boundary `/tmp/v105_WIDE.{tally,diff,rc,rc_histogram,signal}` and `/tmp/v105_wide.list`. Bulk scratch pruned (`/tmp` at 11%).