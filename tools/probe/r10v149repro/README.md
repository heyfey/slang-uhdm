# r10v149repro — adversarial verification of r10uvm149 (§ structMemberWrittenQueueArrayTs149)

Assembled by the master from the verifier's own scratch: `arms/<name>/dut.sv` are its 16 grid arms, `av149.sh` its driver, `ctv149pred.cpp` + `pred_run.sh` its independent predictor, `PRED_*.txt` / `ATTR.txt` / `census/` its measurements. The verdict text follows verbatim.

---

VERDICT: **ACCEPT** — `/tmp/r10uvm149.patch` (md5 `18affbc088598388aec62954d652a45d`) ships unchanged. No `.verified.patch` is needed: I found **no pristine-right → patched-wrong cell on any legal SV I could construct**.

## 1. Bit-for-bit reproduction of every headline number

Fresh worktrees `/tmp/wt_v149` (patched) + `/tmp/wt_v149pris` at `cfc5eaa`, own cmake configure, `-j 2`, binaries frozen 555 at `/tmp/v149_bin/{pris,pat}149.bin`.

| claim | implementer | my own measurement |
|---|---|---|
| pristine binary md5 | `3d9368e21075921b812c46aa037bbad6` | **identical** |
| patched binary md5 | `84ed00899ed5a2726a1ea002040c79cb` | **identical** |
| goldens (patched / `/bin/false`) | 23 PASS 0 FAIL / 23 FAIL | **23/0 and 23 FAIL** (pristine also 23/0) |
| u2r testflags **and** default | 679 / 50 / 2 | **679 / 50 / 2 both modes, both binaries** |
| surelog 1588 rows | 937 EQ, 19 NE, 567 REJ, 48 SF, 10 DEF, 3 NODB, 2 UNTR, 1 TO, 1 NOUHDM | **histogram identical, both binaries** |
| ct8rows (5 comparisons) | PASS | **PASS** — vs committed baselines, vs my own pristine, status **and** dump column; **0 rows converted** |
| predicted movers | 36 surelog row-modes → 9 with a DB, 0 u2r | I wrote **my own** predictor (`/tmp/v149_scratch/ctv149pred.cpp`, golden signature = nameless `array_typespec`, 1 range, a `vpiUnboundedConst` bound) and scanned 1573 + 1462 golden DBs **before** looking at byteverify: **36 / 0**, the 9 named rows identical |
| measured movers | 9/956, 0/1358 | **9/956, 0/1358**, `PATH_SETS_IDENTICAL`, SELFCHECK 955/956 and 1357/1358 |
| head table | SimpleUVM ×2 + Scoreboard/default 60→62, all others unchanged | **identical**, one head per run everywhere; the committed `head_pris_*.cmp` / `head_pat_*.cmp` are **byte-identical to mine, object ids included** |
| canaries / audit | ok=52, ok=8, ctcan2 PASS×2, audited=29 UNCOVERED=0 FENCE-BREACH=0 | **identical**; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort/BlackParrot/YosysOldOr SAME |
| implementer's 5-arm grid | 24 wrong keys → 18 TO-GOLDEN / 0 AWAY / 6 STILL-WRONG; `shapes` converts 64→0; `neg` byte-identical | **reproduced exactly** (9+8+5+0+2 → 6+0+0+0+0), calibration 0 on all five |

Binary hygiene: 1573+1573+1462+1462 `cmds.txt` audited by **path** — 1523/1523/1458/1458 name the correct frozen binary, **0 name the main-tree binary**; the 47/4 that mention the string `slang-uhdm` without the frozen path are the `slang-uhdm-goldens/` cache (exactly the trap). Main tree left clean; `results/*.csv` untouched (0 files); no conflict markers; fence check 0/0/0/0; the repro dir has no `rm -rf`, no shared `/tmp/ctl_*` reads, no other-pass hard-coded paths, and its six carried gate scripts are byte-identical to the canonical ones.

## 2. Breaking the law — 16 of my own arms, both views, all named `dut.sv` in subdirs

Own driver (`/tmp/v149_scratch/av149.sh`, fd-3 list, children `</dev/null`, PROCESSED==LISTED, RELATIVE-path scratch, every rc recorded, binaries printed) building **golden DEF + golden ELAB + ours DEF + ours ELAB** per arm. Golden-vs-golden calibration **0 residual on every arm, both views**.

**Aggregate over 16 arms × 2 views: TO-GOLDEN 70 · AWAY-GOLDEN 0 · MOVED-WRONG 14 · byte-identical negative control.**

Faces the implementer's grid did **not** carry, all measured against golden:

- **Homes**: interface, program, class-nested-in-class, class-in-module, generate block (`homes2`) → 4 TO-GOLDEN def / 2 elab, 0 AWAY.
- **Struct as a port**: input port of struct type, interface `modport` carrying it (`ports`) → 1 TO-GOLDEN; head moved 64→191 lines, which I convicted as a **cascade unmask**, not a regression: the whole-dump path-normalised diff of our two DBs changes **only the law's own objects** (3 removed / 53 added, 0 non-law), so the `interface_inst` failure the patched head names was already in the pristine DB, masked.
- **hier_path / select chain** (`hier`, the uvm143/147 boundary): `rec.chainWord[idx][7:0]`, `i_deep.leafRec.chainWord[0][3:0]`, `foreach` → 2 TO-GOLDEN, 0 AWAY, **0 non-law dump lines**.
- **Union half of the hook**: a `union tagged` carrying `string TagQ[$]` (`tagged`) → 2 TO-GOLDEN. The hook is live, not dead code.
- **Shared-typespec hazard** — the one real design risk in the patch, since `bareWrapInst` now *writes* `ea0->Instance(...)` on a possibly shared element. Arm `shared` uses one `typedef enum`/`typedef struct`/`typedef logic[6:0]` from **both** `[$]` members and plain members/free variables: **4 TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG**, the three plain members stay `SAME`, and the only non-law dump line is a `vpiFullName` (dump-synthesized, not compare-read). **Refuted.**
- **Multiple declarators on one member line** (`string mdA[$], mdB; int mdC, mdD[$], mdE[3];`) → per-declarator, exactly like Surelog's `variable_decl_assignment` loop: `mdA`/`mdD` TO-GOLDEN, `mdB` SAME, `mdE` STILL-WRONG (R4).
- **Element faces**: parameterized-width vector, int-based enum, nested struct, class handle, `logic[7:0]`, real, queue-of-queue `[$][$]`, struct-only-member, 3-deep nesting → all TO-GOLDEN.
- **Assoc/dynamic non-firing**: `[int] [string] [*] [key_t] [level_e] [KeyClass] []` all STILL-WRONG with **payload unchanged** — the new `bareWrapInst` clause provably does not fire outside the queue signature.
- **`paramtype` arm CONVERTS**: uhdm-cmp 64 → **0** in both views (a second conversion beyond the implementer's `shapes`).
- **`neg2`** (packed-only, no unpacked dim anywhere): our two DBs **BYTE-IDENTICAL**.
- `[$:0]` is rejected by slang ("value must be positive"), so that edge cannot diverge.

**Wide boundary**, whole probe tree + my arms: `LISTED = PROCESSED = 4262`, `PRODUCED_DBS=4117`, **`RC_DIFFS=0`**, `MOVED_ARMS=18` = the implementer's 4 + 3 earlier-pass arms + **11 of my own** (my `neg2` correctly did *not* move). Nothing else in 4262 arms moved. Every must-stay family the brief names was **compiled and unmoved**: r10uvm146 (7), r10v146 (33), r10uvm114 (8), r10uvm97 (5), r10v97 (10), r10uvm112 (12), r10buvm33 (3), r10buvm34 (3), r10uvm87 (13), r10uvm141 (3), r10uvm113 (4), r10uvm143 (4), r10uvm147 (5), r10uvm89 (2), r10buvm14 (1), r10uvm77 (9), r10uvm84/85 (23 each), r10sd8 (37). (`r10v114repro` named in the brief does not exist in the tree; `r10uvm114repro` does and is unmoved.) I re-scored the 3 earlier-pass movers against Surelog golden myself: **5 keys TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG**, `r10v128repro/arms/v128_f_hier.sv` head 60→94.

**Corpus census, independently:** ct149cen over golden/pristine/patched for SimpleUVM ×2, Scoreboard/default, SeqDriver/default, BuildUVMPkg/default → **TO-GOLDEN 1 / AWAY-GOLDEN 0 / MOVED-WRONG 0** on every one, calibration 0 on every one.

**Mover attribution, order-blind** (both dumps path-normalised, ids stripped, sorted): all **9** movers show **25 differing lines, 0 non-law** — including Scoreboard/default, the coin, whose 25 lines are identical to SimpleUVM/default's. (The implementer's 27 vs my 25 is exactly the two `Restored design` header lines my normalisation folds together.)

## 3. Model check against Surelog source

I re-read the cited sites rather than trusting the write-up. [`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:1731-1760`](../../git-repos/Surelog/src/DesignCompile/CompileType.cpp#L1731) is verbatim as decoded (`pats` never gets `populateCoreMembers`, never gets a `VpiParent`; `ref->Actual_typespec(m->Typespec()->Actual_typespec())`; the element keeps `VpiParent(m)`). [`CompileExpression.cpp:4038`](../../git-repos/Surelog/src/DesignCompile/CompileExpression.cpp#L4038) "Specified by size" gives the location-less `UINT:0`/size-64 left bound and `populateCoreMembers(Constant_range,…)` on the range, and [`:4095`](../../git-repos/Surelog/src/DesignCompile/CompileExpression.cpp#L4095) `if (c->VpiConstType() == vpiUnboundedConst) associativeArray = true;` is what skips the `-1` decrement. `compileRanges`' `while` **does** walk siblings — the first-dimension-only claim survives only because `fC->Child(Expression)` is the sole child of the first `paVariable_dimension`; I confirmed the consequence empirically (`[$][5]`, `[5][$]`, `[$][$]`). [`grammar/SV3_1aParser.g4:1193-1218`](../../git-repos/Surelog/grammar/SV3_1aParser.g4#L1193) confirms `unpacked_dimension` precedes `queue_dimension`, so `[$]`/`[$:N]` never reach the `queue_dimension` alternative.

## 4. Ranked residues

1. **R-V1 (NEW, introduced by this pass, arm `bounds`, 6 of my 14 MOVED-WRONG cells)** — `[$:N]` is modelled only for a **literal** bound. For a **parameter** (`[$:LIMIT]`) or a **localparam** (`[$:OTHER]`) golden's two objects are `ref_obj{LIMIT}` (def-side) and `c{5,sz32,ct9,idx=int_typespec}` (elab-side); for an **expression** (`[$:2+3]`) they are `op{vpiAddOp,2,3}` and `c{5,sz64,ct9}`. `memberWrittenQueueTs149` emits `c{N,sz64,ct9,idx=-}` on both, so a named bound is wrong on both objects and a folded expression on one. Not a regression (pristine had no wrapper at all), **0 corpus population**, cmp unchanged (375→375). Worth a follow-up pass; the fix is view-aware and I judged it out of scope for a verifier's minimal patch.
2. **R0 (as declared)** — the next head on SimpleUVM ×2 and Scoreboard/default is golden's `class_var (uvm_pkg::cs)` at `uvm_pkg.sv:1731:21`, 62 lines, 1 head; five UVM row-modes now share it. Confirmed from my own patched head logs.
3. **R1 (as declared)** — a member written with a *typedef of* a queue binds golden's **named, package-instanced** `array_typespec` with `Typedef_alias`; we still give the bare element. My `multi` arm (`strq_t mdTdef`) reproduces golden's exact shape and confirms the syntactic gate is the right one — a canonical-type gate would have minted a *nameless* wrapper there and been wrong.
4. **R4 (as declared, widened)** — the fixed unpacked-dimension arm: `string x[9]` → wrapper with `R=- elem={NONE}`; `int x[3]`/`int mdE[3]` → element `logic_typespec` where golden has `int_typespec`. Seen in `qfaces` (`twoD`) and `multi` (`mdE`).
5. **Anonymous inline element types (arm `anon`, 4 MOVED-WRONG cells)** — with the wrapper now correct, the remaining error is that an inline `struct{…} q[$]` element comes out `logic_typespec` and an inline `enum{…} q[$]` element `bit_typespec` (golden: `struct_typespec` / `enum_typespec`). Pre-existing (pristine emitted the same wrong kinds bare); same family as the declared R5.
6. **Object-count residues (uvm97 family, 4 MOVED-WRONG cells)** — `homes2`/elab and `paramtype` show the shape now matching golden exactly while the *number* of `typespec_member` objects differs (7 vs 3, 2 vs 3). Compare-invisible: `paramtype` converts to cmp 0.
7. **Function/task-local struct typedefs** (arm `scoped`) are absent from our DB entirely — ONLY-GOLDEN, unrelated to this law.
8. **R2 / R3** as declared (member span; the dynamic `[]` member's `unsupported_expr` `Default_value`, which `typespec_member::Compare` reads) — both reproduced, both unchanged by the patch.

Evidence lives in `/tmp/v149_scratch` (grids `gv149`, `gv149b`, `gv149c`, `gv149d`; scorings `wgv149*`; `ctv149pred.cpp`; `PRED_sl*.txt`; `ATTR.txt`; `heads_pris/`, `heads_pat/`), `/tmp/v149_wd` (the four sweeps + CSVs), and `/tmp/v149_bnd/out/{LISTED,MOVERS}`.
