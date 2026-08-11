# r10oth2 — state transfer

**Pass result: TARGET A (BlackParrotComplex) CONVERTED, CMP_NOTEQUAL -> CMP_EQUAL
in BOTH modes — TWO comparable rows. TARGET B (YosysOldOr) HONESTLY NOT DONE;
its leading hypothesis is REFUTED and the search space is cut, handed forward as
R1 below.** Base commit `b33d11b`, branch `auto5h`. Two laws, both gated by
purpose-built goldens.

Direction convention used everywhere in this file and in every note comment the
patch adds: **LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.

---

## 0. THE FILLED 2x2 — and why the brief's framing is REFUTED

The brief asked whether direction A CONTRADICTS the campaign's partial law
("a def view keeps parameter-dependent expressions in syntax form"), since golden
folds a localparam whose expression reads a parameter. **It does not. A is the
ELABORATED view, and answering "which view is each of these in" really was the
whole pass.**

Measured on BlackParrotComplex's own golden database, `dut.sv:45`
(`localparam output_dirs_sparse_lp = ...`), both views present in the SAME
database (`default` mode, no `-elabuhdm` needed — Surelog always writes
`uhdmtopModules`):

| | golden DEF view (`uhdmallModules`) | golden ELAB view (`uhdmtopModules`) |
|---|---|---|
| BlackParrotComplex `dut.sv:45` | `operation` opType 24, whole tree, span 45:36-51:249 | `constant UINT:5 size 64 vpiUIntConst`, same span |
| ours, before this patch | `operation` opType 24 — **already identical to golden** | `operation` opType 24 — **the defect** |

So direction A is a pure ELAB-view fold refusal. The partial law survives
untouched; there was never a contradiction to resolve.

The full 2x2 the pass was asked for, filled by reading golden on **50** purpose-built
arm rows (`a1` 12 rows, `a2` 21, `a3` 14) plus the two corpus witnesses:

| | golden KEEPS THE SYNTAX TREE | golden FOLDS TO A CONSTANT |
|---|---|---|
| **DEF view** | **46 of the 50 arm rows**, and BlackParrotComplex:45, and YosysOldOr's `[dw-1:0]` bound. A def-view parameter *operation* is never folded, and we already matched every one. | **4 rows**: `a2 u7` (`'X`) and `a3 z0`/`z1`/`zx` — a BARE UNBASED LITERAL folds in the DEF view too — plus a plain literal init (`a`/`b`, `IntegerLiteral`s that never reach the fold path) |
| **ELAB view** | the two `ExprEval` bails transcribed in law 1 — an UNSIZED left-shift operand, and `get_value` on an X/Z binary constant. **19 of the 50 rows**: `a1 r1,r5`; `a2 s3,s4,s6,s7,u1,u2,u3,u4,u8,u9`; `a3 p1,p2,p4,c1,c3,n1,n3`. | **everything else — 31 of the 50 rows**, including BlackParrotComplex:45. Plus YosysOldOr's `dw-1 -> 31`, which we ALREADY produce correctly when the module is compiled with just its own deps. |

**One rule explains both directions, and it is not a fold rule at all:** golden's
def view keeps the tree and golden's elab view folds, in BOTH designs, and our
emitter already implements that split. Direction A is an elab fold our REDUCER
MODEL wrongly refused (a modelling defect). Direction B is an elab/def object
that only the FULL-DESIGN CONTEXT corrupts (a context defect). They are two
different defects behind one shared, already-correct law — which is why they
needed two separately gated fixes, and why B is not a folding problem.

---

## THE LAWS

### 1. `§ srlgUnbasedReduceBail` — DIRECTION: NARROW an existing bail (net effect ADD folds)

Site: `src/ExprEmit.cpp` — new file-static `srlgHasUnbasedLit` +
`srlgUnbasedReduce` immediately above `UhdmExporter::tryFoldConst`, and the
rewritten unbased-literal clause inside `tryFoldConst`.

**What it replaces.** `tryFoldConst` refused to fold ANY operation containing an
unbased-unsized literal (`'0`/`'1`/`'x`/`'z`), on the strength of one witness
(`'0 << 8`) and the comment *"Expressions CONTAINING unbased-unsized literals
never fold: Surelog's folded model re-emits the operation."*

**That generalisation is REFUTED.** On `a1_unbased_fold.v` (12 localparams, one
per row, nothing else varied) golden's ELAB view folds **10 of the 12** and
refuses exactly two:

| row | source | golden ELAB | golden DEF |
|---|---|---|---|
| r1 | `'0 << 8` | operation 22 — **NO FOLD** | operation 22 |
| r2 | `(a<b) ? 1'b0 : 'X` | `BIN:0 sz 1` | operation 32 |
| r3 | `(a>b) ? 1'b0 : 'X` | `BIN:X sz -1` | operation 32 |
| r4 | `((a<b)?1'b0:'X) + 5` | **`UINT:5 sz 64 ct9`** | operation 24 |
| r5 | `'X + 1` | operation 24 — **NO FOLD** | operation 24 |
| r6 | `'0 + 1` | `UINT:1 sz 64` | operation 24 |
| r7 | `'1 + 1` | `UINT:2 sz 64` | operation 24 |
| r8 | `(a<b) ? 1'b1 : '0` | `BIN:1 sz 1` | operation 32 |
| r9 | `!'0` | `UINT:1 sz 64` | operation 3 |
| r10 | `{'0, 1'b1}` | `BIN:01 sz 2` | operation 33 |
| r11 | control, no unbased | `UINT:5 sz 64` | operation 24 |
| r12 | `(a>b) ? 1'b1 : '0` | `BIN:0 sz -1` | operation 32 |

r4 is BlackParrotComplex's shape in miniature and golden's answer there —
`UINT:5 size 64 vpiUIntConst` — is *byte for byte* the corpus witness's Rhs.

**THE MODEL, transcribed not guessed** from
`Surelog/third_party/UHDM/templates/ExprEval.cpp`. An unbased-unsized literal is,
in Surelog, a `constant` with **`VpiSize() == -1`** and value `BIN:0`/`BIN:1`/
`BIN:X`/`BIN:Z`. Only two things in the reducer then fail:

1. **The shifts, and only the shifts, reject an unsized LEFT operand.**
   `case vpiArithLShiftOp: case vpiLShiftOp:` (`:3137`) and
   `case vpiArithRShiftOp: case vpiRShiftOp:` (`:3050`) both open with
   ```c
   expr *arg0 = reduceExpr(operands[0], invalidValue, inst, pexpr, muteError);
   if (arg0 && arg0->UhdmType() == uhdmconstant)
       if (((constant *)arg0)->VpiSize() == -1) invalidValue = true;
   ```
   `operands[1]` — the shift AMOUNT — is not checked.
2. **An UNKNOWN unbased literal poisons any operator that reads its VALUE.**
   `get_value` (`:1946`) / `get_uvalue` (`:2057`) parse a `vpiBinaryConst` with
   `NumUtils::parseBinary` and, with `strict` defaulted to **true**
   (`ExprEval.h:97`/`:99`), set `invalidValue` when the parse fails — which it
   does for any X or Z digit. `'0`/`'1` parse fine.

Neither failure is syntactic, which is the whole law:
* `case vpiConditionOp:` (`:3763`) reduces the condition, then reduces **only the
  selected arm**. An `'X` in the UNTAKEN arm is never read.
* `case vpiConcatOp:` (`:3882`) assembles BITS instead of calling `get_value`, so
  a concat over `'X` folds to a BIN constant carrying X bits.

**PROOF EACH CLAUSE IS NECESSARY** — `a2_unbased_ops.v`, 21 rows, golden ELAB:

| clause | rows that PROVE it |
|---|---|
| the size(-1) test is on **operands[0] only** | `'0 >> 1` s3 **no fold**, `'1 << 1` s4 **no fold**, `'0 <<< 2` s6 **no fold** vs `8 << '0` s5 **folds UINT:8**. Controls `1'b0 << 8` s1 -> `UINT:0` and `a << 8` s2 -> `UINT:256` prove it is the OPERAND's unsizedness, not the operator. |
| the bail **propagates outward** | `('0 << 8) + 0` s7 -> operation 24; `1 + ('0 << 2)` (a3 n1) -> operation 24 |
| **known** unbased literals fold in every operator | k1 `'0*2`, k2 `'0-1`, k3 `'0&1`, k4 `'1\|0`, k5 `'0==0` all fold |
| it is **UNKNOWN-ness**, not unbased-ness, that poisons get_value | u1 `1 + 'X`, u2 `'Z + 1`, u3 `'X & 1'b0`, u4 `!'X`, u8 `-'X`, u9 `('X)+1` all **no fold** — while their `'0` twins all fold |
| concat is **exempt** from rule (2) | u5 `{'X,1'b1}` **folds** to `BIN:X1 sz 2` |
| a bare unbased literal is not an operation at all | u7 `'X` -> `BIN:X sz -1` |
| the conditional is **path-sensitive** (the clause BlackParrotComplex needs) | a3 n2 `(a<b)?1'b0:('0<<2)` **folds** `BIN:0 sz 1` even though the untaken arm holds a bailing shift; a3 n3, the same source with the condition inverted, does **not** fold |
| size(-1) is **not re-encoded** by a conditional, so `unsized` must propagate through the selected arm | a3 c1 `((a<b)?'0:'1) << 1` -> operation 22 (**no fold**), against control c2 `((a<b)?1'b0:1'b1) << 1` -> `UINT:0` |

**THE GATE, and why it is safe.** The precondition is UNCHANGED from before the
patch — an unbased literal written in the tree AND a top level of
`BinaryOp`/`UnaryOp`/`ConditionalOp`/`Concatenation` — and the reduce model is
ANDed on top. Every expression kind the model does not cover returns
`bails = true`, i.e. the pre-r10oth2 answer. **So the change is a strict
NARROWING: it can only ever add folds, never remove one.** That is why gate 3
(u2r) is byte-identical and gate 4 moves exactly two rows.

**Fold/no-fold agreement with golden: 31 of the 33 measured arm rows, with TWO
conservative misses** (corrected by the pass-48-era verifier; the write-up said
32-of-33 and one miss). The two are `a2 u6` (`'X=='X`, residue R4) and `a1 r3`
(`(a>b)?1'b0:'X`, the R5 family) — both already in the residue list, only the
headline count was wrong. The
miss is CONSERVATIVE (we refuse where golden folds), so it is not a regression —
see residue R4.

### 2. `§ unpElemSelKeeps64` — DIRECTION: REMOVE a case from `elabRefFold9`

Site: `src/ParamEmit.cpp`, the `unpElemSel9` block immediately above
`bool elabRefFold9 = ...`, which now carries `!unpElemSel9`.

With law 1 landed, BlackParrotComplex's cmp head moved to `dut.sv:82`
`parameter A = A3[2];`: LHS(golden) `UINT:3 vpiSize:64`, RHS(ours) `vpiSize:32`.
The existing `§ elabRefFold9` claims "an ELAB fold whose source is a parameter
reference — bare, qualified or **SELECTED** (`a = x[0]`) — is sized at the
param's own TYPE width". **The SELECTED half of that claim is too wide.**

**PROOF OF THE GATE** — `a4_selfold_width.v`, golden ELAB view, one localparam
per row:

| base declaration | read | golden | keeps `elabRefFold9`? |
|---|---|---|---|
| `parameter int UA[0:2] = {1,2,3}` | `UA[2]` | `UINT:3 sz 64` | **NO** — the law |
| `parameter int UP[0:2] = '{1,2,3}` | `UP[2]` | `UINT:3 sz 32` | yes |
| `parameter logic [7:0] PV = 8'hAB` | `PV[3]` | `BIN:1 sz 1` | yes |
| `parameter [7:0] PU = 8'hAB` | `PU[3]` | `BIN:1 sz 1` | yes |
| `parameter bit [1:0][2:0] PA` | `PA[0]` | `BIN:1 sz 1` | yes (see R5) |
| `parameter logic [7:0] PV` | `PV[3:0]` | `BIN:1011 sz 4` | yes |
| `parameter int NB = 7` / untyped `NC` | bare | `UINT:7 sz 32` | yes |
| `parameter logic [7:0] UC[0:2] = {8'h1,8'h2,8'h3}` | `UC[2]` | **`BIN:0 sz 1`** | yes — deliberately |
| `parameter int UD[0:2] = {32'd1,32'd2,32'd3}` | `UD[2]` | **`BIN:0 sz 1`** | yes — deliberately |

Three halves. **TWO are arm-proven necessary; the third is a CONSERVATISM CHOICE,
not a proven necessity** (corrected by the pass-48-era verifier — the original
"each independently necessary" overstated it). The unpacked-array base
(`s_pv`/`s_pu`/`s_pa`/`r_pv`) and THE BRACE (`s_up`) are genuinely arm-proven.
The unsized-element conjunct is not: `UC`/`UD` are wrong with the gate open AND
closed (golden gives `BIN:0 sz 1`; we give sz 8 / sz 32 closed, sz 64 open), so
no cell makes it *correct* — it is chosen to avoid trading one wrong width for
another. The prose below already said this; only the heading overclaimed.

* **`FixedSizeUnpackedArrayType` base.** Every PACKED select row keeps
  `elabRefFold9`'s answer (there the reading param's own width happens to equal
  the select width), so only the unpacked-array element differs. Surelog's reduce
  hands back the ELEMENT CONSTANT OBJECT, which is still the unsized `1`/`2`/`3`
  it was built from — size 64.
* **THE BRACE.** BlackParrotComplex hands this half over ready-made: it writes
  BOTH spellings six lines apart — `dut.sv:69` `parameter int A3[0:2]='{1,2,3};`
  in module `middle` and `dut.sv:81` `parameter int A3[0:2]= {1,2,3};` in module
  `bottom` — and golden's two elab folds DISAGREE: line 70 is `UINT:1 sz 32`,
  line 82 is `UINT:3 sz 64`. A CONCATENATION keeps the raw unsized element
  constants; an assignment PATTERN goes through Surelog's
  `reorderAssignmentPattern` and is re-typed to the ELEMENT type.
  **My first implementation accepted both braces and REGRESSED line 70 from right
  to wrong. That regression is what named this half of the gate** — it appeared as
  a new cmp head at `dut.sv:70` (golden sz 32, ours sz 64) the moment the
  `dut.sv:82` head cleared, and arm row `s_up` reproduces it in isolation.
* **UNSIZED elements.** The `UC`/`UD` rows are the other spelling, and golden
  DEGENERATES on them: its own VALUE is **0** (`BIN:0 sz 1`), i.e. Surelog fails
  to reduce a SIZED-element unpacked select at all, so no rule can match those
  two cells. The gate deliberately leaves them at the pre-r10oth2 answer rather
  than trade one wrong width for another.

---

## GATES — all four ran; every number below was MEASURED on this worktree's build

`SLANG_UHDM` exported to
a build of b33d11b + this patch, md5 `2bb5fa96ddb8d21df0e224fa690e64d0`, for
every gate. (The original text hard-coded the implementing agent's own worktree
path here — a path that vanishes on cleanup, inside a state-transfer document.)
Final binary md5 **`2bb5fa96ddb8d21df0e224fa690e64d0`**, checked BEFORE and AFTER
both sweeps and unchanged (no rebuild ran concurrently with any sweep). The
pristine b33d11b control binary is md5 `b6ecb3487baadabcddfdae76236c5a60` — a
different file, so the byte verifier's control is real.

> **The whole gate set below was run TWICE.** The first full run measured binary
> `a5f3b3ad0c62e29e4a883df9cd3264fc`; the concat/replication arm of
> `srlgUnbasedReduce` was then refactored for clarity, which changed the md5, so
> **every number was re-measured on the final binary rather than inherited**. All
> figures below are the FINAL run's, and they came out identical to the first
> run's in every cell — including all four arms' residues.

1. **Build** — `cmake --build build -j 3` -> `Built target slang_uhdm`, no errors.
2. **Goldens** — `bash tests/check_goldens.sh | grep -c '^PASS'` = **23**,
   FAIL **0**. Negative control `SLANG_UHDM=/bin/false` -> **PASS 0 / FAIL 23**,
   so the export is real and the `verify_golden.py:52` /
   `check_goldens.sh:5` main-tree default was not what got measured.
3. **uhdm2rtlil, mode `testflags`, `--jobs 2`, own `--out`** — **731 test rows**
   (the committed CSV is 732 LINES including its header — a figure correction to
   the brief's "732 rows"): **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**,
   dump **496 match / 183 differ / 52 blank**. Whole-row diff against the
   committed `results/gate_uhdm2rtlil.csv` (status *and* dump column):
   **0 lines — byte-identical.** `default` mode was NOT run and has no committed
   baseline; nothing here implies it was row-checked.
4. **surelog, `--mode both`, `--jobs 2`, own `--out`** — **1588 test rows** (the
   committed CSV is 1589 LINES including its header — figure correction to the
   brief's "1589 rows"):
   * `default`  **467 CMP_EQUAL** (baseline 466, **+1**) / **13 CMP_NOTEQUAL**
     (baseline 14, **-1**) / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL;
     dump **match 225** (baseline 225 — **did not fall**) / 242 differ.
   * `testflags` **463 CMP_EQUAL** (baseline 462, **+1**) / **10 CMP_NOTEQUAL**
     (baseline 11, **-1**) / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL /
     3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM;
     dump **match 165** (baseline 165 — **did not fall**) / 298 differ.
   * Whole-row diff against the committed `results/golden_surelog.csv`, all 1588
     rows:
     ```
     < BlackParrotComplex,default,CMP_NOTEQUAL,decompile:,,
     < BlackParrotComplex,testflags,CMP_NOTEQUAL,decompile:,,
     ---
     > BlackParrotComplex,default,CMP_EQUAL,,,differ
     > BlackParrotComplex,testflags,CMP_EQUAL,,,differ
     ```
     **That is the ENTIRE diff.** Two rows, both the intended CONVERSION. The
     known `Google,testflags` golden-side environment flake did NOT differ from
     the baseline this run — it is named here, not filtered.

**BYTE VERIFIER** (the whole-row diff is blind inside already-CMP_NOTEQUAL rows).
Every `slang.uhdm` from the pristine-b33d11b binary byte-compared against the
patched one, **both runs writing to the SAME workdir path**:

| corpus | databases | movers |
|---|---|---|
| surelog, both modes | **953** | **3** — `default/BlackParrotComplex`, `testflags/BlackParrotComplex`, and `default/Scoreboard` |
| uhdm2rtlil, testflags | **679** | **0** |

The two BlackParrotComplex movers are the conversion. **The third is the known
intermittent UVM `Scoreboard` `default` nondeterminism, PROVEN rather than
asserted** by `scoreboard_nondet.sh` (committed), which runs each binary four
times against `Scoreboard` alone. TWO independent samplings, and they came out
OPPOSITE:

```
sampling 1   FINAL    2bb5fa96…  d661db6a d661db6a d661db6a d661db6a  -> 1 distinct
             PRISTINE b6ecb348…  d661db6a 792bdba4 d661db6a 792bdba4  -> 2 distinct
sampling 2   FINAL    2bb5fa96…  792bdba4 792bdba4 d661db6a 792bdba4  -> 2 distinct
             PRISTINE b6ecb348…  792bdba4 792bdba4 792bdba4 792bdba4  -> 1 distinct
```

**Both binaries disagree with themselves run to run, both emit exactly the same
two md5s, and which one happens to look "stable" flips between samplings.** So
the byte "MOVED" reading was one side landing on its other variant, and the
difference is not attributable to this patch. Consistent with the recorded
mechanism (SourceLocation compares across macro buffers flipping per run under
parallel parse). It is not cited in any identity control, and a single run of it
would have been worthless in either direction.

As a positive control on the harness invocation itself, the PRISTINE u2r sweep
reproduced the committed baseline CSV exactly (empty diff) — so the zero-mover
reading is a real measurement, not a driver that cannot see its probe.

**CANARIES, checked as rows.** 78 surelog-corpus rows and 9 u2r rows matching the
named canary set were diffed line-by-line against the committed baselines:
**identical except the two intended BlackParrotComplex rows.** In particular
`InterfaceModPort` (b33d11b's conversion) stays **CMP_EQUAL in both modes**, and
`InterfaceBinding` / `InterfaceModExp` stay **CMP_EQUAL + dump `match`** in both
modes — the strongest available control, since any byte change there would flip
those dumps to `differ`. `Earlgrey_0_1` is unchanged
(`default` CMP_NOTEQUAL / `testflags` SLANG_REJECT). The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched as targets; they are ordinary rows in the corpus sweep and match the
baseline.

Neither baseline CSV was rebuilt, edited, or included in the patch. `git stash`
was never used. No `out/` directory is committed; every arm writes to `/tmp`.

---

## REFUTATIONS (the valuable part)

1. **"Direction A appears to CONTRADICT the def-view law, because golden folds a
   localparam whose expression reads a parameter."** REFUTED. Golden's DEF view
   keeps the whole operation at `dut.sv:45`, and **so did ours, before the
   patch** — the two databases already agreed there. A is elab-only. There was no
   contradiction, and "which view is each of these in" was indeed the whole pass.
2. **"Full cmp output 6666 lines, 4 heads (2 distinct sides of 2 positions)."**
   Figure corrected: 6666 lines is **TWO heads printed twice each = ONE distinct
   position** (golden id 1935 twice, our id 810 twice). Behind it sat **two more**
   positions that `uhdm-cmp` structurally cannot show until the first clears —
   `dut.sv:82` and then `dut.sv:70`. The head count was 1 visible / 3 real, and
   the third one only existed because my own first gate was too wide.
3. **`tryFoldConst`'s "Expressions CONTAINING unbased-unsized literals never
   fold"** — refuted as a generalisation; see law 1. It was right about `'0 << 8`
   and wrong about 10 of 12 arm rows.
4. **`§ elabRefFold9`'s "or SELECTED (`a = x[0]`)"** — refuted for an
   unpacked-array base with concatenation-spelled unsized elements; see law 2.
5. **Direction B's leading hypothesis is REFUTED.** R1 of the r10oth1 handoff
   proposed "a shared/cached typespec or range object reused across the two
   modules … a MINT-SITE collision" as the thing to test first. Measured
   (`b4_pair113.sh`): compiling **both** line-113 files together with the union of
   their dependencies — `or1200_defines.v`, `or1200_du.v`, `or1200_ic_top.v` and
   19 more — is **PASS_CMP**, with golden and ours reporting the SAME counts
   (6 unfolded / 3 folded grep hits on each side). Sharing between the two
   line-113 modules is therefore not the mechanism; something else in the
   remaining ~60 files is required to trigger it.
6. **Direction B's object counts in the brief are grep LINE hits, not objects.**
   Re-measured on fresh full-design dumps with `loc113.py`, which classifies each
   `range: , line:113:8, endln:113:16` by its LeftRange form: golden has **5**
   such `logic_typespec`s — **2 UNFOLDED / 3 FOLDED** — and ours has **5** —
   **1 UNFOLDED / 4 FOLDED**. The conclusion the brief drew ("exactly ONE object
   differs") is CONFIRMED. **CORRECTED by the pass-48-era verifier: the brief's
   "golden 6/8 vs ours 3/9" are NOT figures that correspond to nothing — they
   reproduce EXACTLY as grep LINE counts.** They were the right numbers in the
   wrong UNIT, not wrong numbers. The object re-measurement (golden 2 unfolded /
   3 folded, ours 1 / 4, five objects each) is the figure to carry forward.
   INSTRUMENT CAVEAT worth documenting: `loc113.py` classifies only 5 of the 15
   line-113 `range` matches per side and reports the other 10 as `?`
   (parent-chain back-references). It is consistent on both sides, so the
   conclusion holds, but the `?` rows are not evidence of anything.
7. **The brief's "settled, needs NO work: the UINT/constType-9/size-64 vs INT/7
   difference on that constant"** is confirmed still true and still settled — but
   note that direction B's full-design dump is **35,299 diff lines in 2,088
   hunks**, not a small residue around line 113, so "one cmp head" badly
   understates the state of that database.

---

## RANKED RESIDUE (most reachable first)

### R1. YosysOldOr (Target B) — **HONESTLY NOT DONE**. Direction: REPLACE. Depth: medium; the search space is now cut, and its leading hypothesis is dead.
Head unchanged and re-measured: a def-view port packed range `[dw-1:0]` at
`or1200_du.v:113` / `or1200_ic_top.v:113`. LHS(golden) keeps `dw-1` as
`operation` opType 11 (operands `ref_obj(dw)` + `constant UINT:1 sz 64 ct9`);
RHS(ours) folds it to `constant INT:31 ct7`. What I ADD to the r10oth1 handoff:
* **The 2-file pair is PASS_CMP** (`b4_pair113.sh`, committed). So it is NOT
  object sharing between the two line-113 modules — refutation 5 above. The next
  bisector step must ADD files, not subtract them.
* **Exactly one object flips, re-measured as OBJECTS** (`loc113.py`, committed):
  golden 2 unfolded / 3 folded, ours 1 unfolded / 4 folded.
* **The rest of that database is very far from equal**: 35,299 dump diff lines in
  2,088 hunks, dominated by weak-tail `logic_typespec` ordering and by
  present/absent typespec subtrees at other lines (e.g. `126:7-126:15`). A
  conversion needs the ONE cmp-visible object; a DUMP_MATCH needs all of it.
* **Ranked next step:** bisect the 80-file `.sl` list by halves with
  `b4_pair113.sh`'s counter as the oracle (it is a positive-controlled counter —
  it reported 6/3 on both sides on a design known to be equal, so it can see its
  probe). Then, once a minimal failing file set exists, an id walk from the design
  root to golden id 186092 / our id 214152.

### R2. Surelog's unbased literal is worth the INTEGER 0 or 1, not slang's all-ones. Direction: REPLACE. Depth: medium. NEWLY EXPOSED by law 1.
`get_value`/`get_uvalue` parse `BIN:1` as the integer **1**. Slang types `'1` as
all-ones at the context width, so our fold of `'1 + 1` gives `UINT:0` where
golden gives `UINT:2`; `'0 - 1` gives `INT:4294967295` where golden gives
`INT:-1`; `'1 | 0` gives `UINT:4294967295` where golden gives `UINT:1`
(arm rows a1 r7, a2 k2, a2 k4). **Not a verdict regression** — those rows were
`operation` before the patch and golden's is a `constant`, so they were unequal
either way, and the byte verifier shows no corpus database moved because of them.
Closing it means substituting each unbased literal with 0/1 *before* handing the
expression to slang's evaluator, which slang's `tryEval` does not let you hook —
hence "medium", not "shallow". Highest-ranked correctness residue in this family.

### R3. An unbased literal reached through a PARAMETER REFERENCE is invisible to law 1's precondition. Direction: ADD. Depth: shallow. PRE-EXISTING; measured, not fixed.
`srlgHasUnbasedLit` scans literals WRITTEN in the expression, so
`localparam z0 = '0; localparam p1 = z0 << 1;` never reaches the reduce model and
we **fold** it where golden keeps `operation 22` (arm a3 rows p1, p2, c3).
`srlgUnbasedReduce` already recurses into a parameter's initializer and would
answer these correctly; only the cheap precondition blocks it. Deliberately NOT
widened in this pass: widening the precondition can only REMOVE folds, which is
the one direction that can regress a currently-CMP_EQUAL row, and no corpus test
demanded it. The three rows are wrong today and were wrong before the patch.

### R4. `'X == 'X` folds in golden and my model bails. Direction: ADD. Depth: shallow. Conservative miss.
Arm a2 u6: golden `BIN:1 sz 1`, ours `operation 14`. The transcription predicts a
bail (`reduceCompOp`, `ExprEval.cpp:1638`, sets `invalidValue` when
`invalidValueI && invalidValueD && invalidValueS` and all three do become true for
`BIN:X`), so **golden's own answer here does not come from UHDM's `ExprEval`** —
it must come from Surelog's own `Value`/`ExprBuilder` evaluation writing the
parameter value at compile time. That is the one row of 33 the model misses, and
it misses CONSERVATIVELY (we refuse, so nothing changed). Worth naming because it
means there are **two** evaluators in play and a future law in this area must
decide which one owns the site.

### R5. A bare unbased literal parameter, and an `'X` SELECTED by a ternary, keep an operation where golden has a size(-1) BIN constant. Direction: REPLACE. Depth: shallow. PRE-EXISTING.
Golden gives `parameter z0 = '0` -> `BIN:0 vpiSize:-1 ct3` and
`parameter zx = 'X` -> `BIN:X sz -1`; we give `UINT:0 sz 64` and
`UINT:4294967295 sz 64` for the first two (arm a3 z0/z1 — `zx` we already match).
And `(a>b) ? 1'b0 : 'X` (a1 r3, a3 p8) folds in golden to the selected `BIN:X
sz -1` while we keep the operation, because `tryFoldConst`'s pre-existing
`iv.hasUnknown()` clause only exempts a `Concatenation`. Same family: the
**size -1 / BIN encoding of an unbased constant** is not modelled anywhere in the
emitter. Fixing R5 is probably a prerequisite for R3 (a param whose elab constant
must READ as size -1).

### R6. `PA[0]` on `parameter bit [1:0][2:0]` is a BIT select to Surelog, not an element select. Direction: REPLACE. Depth: shallow. PRE-EXISTING.
Arm a4 `s_pa`: golden `BIN:1 sz 1`, ours `BIN:101 sz 3`. Surelog answers an
element select off a MULTI-DIM PACKED parameter at 1 bit, i.e. it flattens the
declared dimensions before selecting. Untouched by this patch (it is not on the
unbased or unpacked path) and not needed by either target.

### R7. A ternary whose SELECTED arm fails to reduce is REPLACED BY THAT ARM in golden. Direction: REPLACE. Depth: shallow. Dump- and cmp-visible.
Arm a3 `n3` `(a>b) ? 1'b0 : ('0 << 2)`: golden emits `operation` opType **22**
(the arm's own shift) as the whole param_assign Rhs; we emit `operation` opType
**32** (the whole ternary). Transcribed cause: `case vpiConditionOp:`
(`ExprEval.cpp:3763`) ends `result = the_val` — the reduced selected arm object —
whenever `get_value(the_val)` fails. `vpiOpType` is a Compare field, so this is
cmp-visible wherever it occurs. Pre-existing; my model correctly predicts the
no-fold but not the arm substitution.

### R8. BlackParrotComplex is CMP_EQUAL with dump `differ`. Direction: mixed. Depth: not shallow.
Post-patch residue, MEASURED (`default` mode): golden 5660 dump lines, ours 5664;
**240 CHANGED lines in 5 hunks, 118 golden-only / 122 ours-only** (before this patch
it was 8979 dump lines against golden's 5660, and a 6666-line cmp log).
Three classes, none cmp-visible today: (a) golden's elab `routing_matrix_p`
(`dut.sv:40`) Rhs is the SUBSTITUTED `operation 9:31-25:33` where we fold to
`constant UINT:553163846905791 sz 50` — **pre-existing, the pristine binary
produces the identical constant**, so it is not caused by this patch, and it is a
KIND difference that a future Compare change could make cmp-visible;
(b) weak-tail `array_typespec`/`int_typespec` ordering for `work@middle.A3` /
`work@bottom.A3`; (c) two golden-only `vpiParent` back-references on the folded
`51:211` sub-operation. (a) is the ranked one.

---

## Assets in this directory

| file | what it is |
|---|---|
| `arm.sh` | one-source arm driver: Surelog + ours, cmp, dump diff, and a per-parameter per-view Rhs-form diff. **REQUIRES `SLANG_UHDM`** — no default, so it can never silently measure the main-tree binary. Verified to run from the patch. |
| `rhsform.py` | prints `{view, parameter, Rhs form}` for every `param_assign` in a `uhdm-dump`. This is the instrument the whole 2x2 was read with. |
| `a1_unbased_fold.v` | 12 rows: the unbased literal in every position (shift, ternary arms taken/untaken, arithmetic, unary, concat) plus a no-unbased control. Proves the old blanket bail wrong. |
| `a2_unbased_ops.v` | 21 rows: separates "is it the shift OPERATOR" from "is it an unsized LEFT operand", and "is it unbased-ness" from "is it UNKNOWN-ness". |
| `a3_unbased_ref.v` | 14 rows: both rules reached through a PARAMETER REFERENCE, whether a conditional re-encodes a size(-1) arm (`c1` vs `c2`), and a bailing shift in the taken vs untaken arm (`n2` vs `n3`). Sources R3, R5, R7. |
| `a4_selfold_width.v` | the select-width grid for law 2, including the `'{` vs `{` control (`s_up` vs `s_ua`) that named the brace half of the gate, and the `UC`/`UD` cells where golden degenerates. |
| `b4_pair113.sh` | Direction B bisector step: both line-113 files + the union of their deps -> **PASS_CMP**, refuting r10oth1's leading hypothesis. Takes its binary from `SLANG_UHDM`, stages its own sources, guards against the `uhdm-cmp`-exits-0-on-missing-input trap. |
| `loc113.py` | classifies every line-113 `range` in a dump as UNFOLDED-op or FOLDED-const, which is how the "exactly one OBJECT flips" figure was re-measured. |
| `scoreboard_nondet.sh` | runs `SLANG_UHDM` and `PRISTINE_UHDM` four times each against the UVM `Scoreboard` `default` database and prints the per-run md5s. This is the instrument that turns "a database moved" into "both binaries are nondeterministic here". Reusable by any future pass that trips the same byte-verifier mover. Both env vars are required, neither defaults. |


## Residues added by the pass-48-era verifier (measured, with commands)

### R9. Unbased concat folds now, and our `BIN` value is LOWERCASE where golden is UPPER. Direction: REPLACE. Depth: shallow. NEWLY REACHABLE.
`{'X, 1'b1}` folds under law 1 and we emit `constant vpiSize:2 BIN:x1` where
golden writes **`BIN:X1`**. Pre-patch that row was an `operation` (verified on the
pristine binary), so law 1 is what made the encoding mismatch REACHABLE — it is
not a regression (zero corpus movers) but it IS a field that a `constant`
`Compare` reads. Origin is the pre-existing `iv.hasUnknown()` concat branch in
`src/ExprEmit.cpp`, which builds `'x'`/`'z'` lowercase.

### R2 has an UNMEASURED HALF: no arm puts an unbased literal in a ternary PREDICATE.
Every ternary predicate in a1/a2/a3 is `(a<b)` or `(a>b)`.
`srlgUnbasedReduce` picks the arm with slang's `tryEval(pred)`, and R2 already
establishes that slang and Surelog DISAGREE on what `'1` is worth (Surelog: integer
1; slang: all-ones). So `('1 == 1) ? ('0<<1) : 5` would select OPPOSITE arms in the
two evaluators and flip the fold decision **in the non-conservative direction**.
Not reached by the corpus (no unexplained movers), but the path-sensitivity clause
is unproven on that half. A law that only ever saw one spelling has an unmeasured
half — and here the unseen spelling is the dangerous one.

### Reading convention for every `arm.sh` DUMP_DIFF figure in this document
`arm.sh` computes `DUMP_DIFF $(grep -c '^[-+]' d.diff)`, which counts the two
`diff -u` FILE HEADER lines (`---`/`+++`) along with the content. **Every
DUMP_DIFF number here is content + 2.** Said once so no future pass reads them as
object counts.

### Durability note on the BlackParrotComplex conversion — READ BEFORE TOUCHING Compare
BPC is now CMP_EQUAL **while an ELAB `param_assign` Rhs KIND difference is still
live**: at `work@top.routing_matrix_p` golden's Rhs is an `operation` (span
9:31-25:33) and ours is `constant UINT:553163846905791 sz 50`. It is PRE-EXISTING
(the pristine binary reproduces it identically) and it is filed as R8(a). The
point to record is that **this conversion depends on `Compare` not walking that
Rhs** — exactly the `m_visited` / traversal-order hazard that let a defect hide
for 30+ passes in pass 47's § ifaceDupSharesHomePorts. If a future pass changes
traversal order or adds a field to a compared object, BPC can un-convert without
anyone touching the fold laws.

### Scoring correction for the YosysOldOr target (affects RANKING, not this patch)
The harness passes the **same** slang argv for YosysOldOr in both modes (no
`--elabuhdm`), so the two rows share ONE ours-database — the pass-48-era verifier
measured md5 `ed4fad45231232c986c8d53732a0633c` on both binaries. YosysOldOr is
therefore **one defect scored twice**, not two independent targets. Its nominal
"2 rows" of value is real for the scoreboard but it is a single fix.

### Master's independent spot-checks at integration (commands and raw output in the commit)
Two of the verifier's corrections were re-measured rather than inherited, because
a reach/classification figure is what the NEXT pass ranks on:

* **Correction 2 CONFIRMED on my own binary.** `arm.sh a3_unbased_ref.v` prints,
  in golden's DEF view (`uhdmallModules`), `z0 -> constant vpiSize:-1 BIN:0`,
  `z1 -> constant vpiSize:-1 BIN:1`, `zx -> constant vpiSize:-1 BIN:X`. So a BARE
  UNBASED LITERAL really does fold in the DEF view, and the original claim that
  "every one of the arm rows keeps the syntax tree in the DEF view" was wrong.
  The DEF view folds a bare literal and never folds an *operation* — that is the
  precise statement.
* **R2 CONFIRMED directly, and it is bigger than a value disagreement.** In the
  same run, golden's ELAB `z1` is `constant vpiSize:-1 BIN:1` while ours is
  `constant vpiSize:64 UINT:4294967295`. So for `'1` we disagree with Surelog on
  the VALUE (all-ones vs integer 1), the SIZE (64 vs -1) and the ENCODING
  (UINT/ct9 vs BIN/ct3) simultaneously. R5 (the size(-1)/BIN encoding) and R2 (the
  value) are the same object seen from two sides and should be worked together.
* Also visible in that run and consistent with the verifier's account: our ELAB
  view over-folds `a3 p1`/`p2` (golden keeps `operation opType 22`, we emit a
  `constant`). The verifier established these are PRE-EXISTING and
  precondition-blocked by diffing pristine-vs-patched `o.forms`, where only `n2`
  moves — and `n2` moves TO golden's answer. No corpus row exercises them; the
  arms are not gates. Carried as residue, not as a regression.
