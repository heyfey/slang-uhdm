# r10earl39 — § defGenProcArgNoFormalTs39

**THE HEADLINE, FIRST — AND THE BRIEF'S TWO FACTUAL ERRORS, CORRECTED BY
MEASUREMENT BEFORE ANY CODE WAS WRITTEN.**

The brief described the head as a `ref_typespec` surplus on a reference to a
*"FUNCTION-LOCAL variable"* inside *"a function (`p_fwd_d64` in the fullname
path)"*, with the referenced variable's *"TYPE text"* at `prim_prince.sv`
110:59-64, and it asked me to grid *"ref target = function-local var vs function
ARG vs module var vs pkg param; ref site = inside the same function vs
outside"*.

Both anchors are wrong, and reading the two source files answered it in the
first five minutes:

* **`p_fwd_d64` is not a function. It is the label of an `always_comb` block**
  (`prim_prince.sv:88` — `always_comb begin : p_fwd_d64`) written inside
  `if (DataWidth == 64) begin : gen_fwd_d64` inside
  `for (genvar k = 1; ...) begin : gen_fwd_pass`. There is no function anywhere
  in the fullname path, so the whole "function-local vs function-arg" axis the
  brief asked me to grid **does not exist in this cell**.
* **`110:59-110:64` is not in `prim_prince.sv` at all** — line 110 of that file
  is a bare `end`. It is `prim_cipher_pkg.sv:110`, and column 59 is the `logic`
  of `function automatic logic [63:0] prince_mult_prime_64bit(logic [63:0]
  state_in);` — **the CALLEE'S FORMAL ARGUMENT type**, not the referenced
  variable's type.

Reading the golden dump instead of the brief turns the head into something with
an existing law and an existing flag: **the formal-typespec stamp that Surelog
leaves on a call ACTUAL when it binds that actual to a formal.** The rule is
already implemented and already bars two procedural emitters (`!inProcessEmit`,
`!inGenScopeProc`). There is a **THIRD** procedural emitter — the one that
re-emits an `always`/`initial` written inside a generate scope for the
`uhdmallModules` (definition) listing — and it was covered by neither flag. Its
own flag, `defGenProcessEmit`, was already set at the call site; the gate simply
never tested it.

`Earlgrey_0_1/default`'s **17-line head is CLEARED** and the next head is a
different family in a different construct (a def-view gen-block cont-assign's
package-array select, `prim_prince.sv:106`).

**Say the uncomfortable number out loud: the cmp log grows from 17 lines to 100.**
That is NOT a regression and it must not be read as one. A cmp log prints the
first divergent object in full, so its length is **HEAD DEPTH, never a distance**
— the old head was a 4-field `ref_typespec`, the new one is a `var_select` with
two `vpiIndex` children and a nested range operation, so it simply prints bigger.
The instruments that ARE distances all move the right way: the whole-design
multiset distance to golden falls **309009 → 308941**, the dump shrinks by
**exactly the 126 predicted lines**, `Earlgrey_0_1`'s CSV row is **byte-identical**
to the committed baseline, and the byte verifier finds **no other database moved
in either corpus**.

The object-level fence computed
from the two dumps **before the build** predicted **18 actuals, 126 dump lines
removed, 0 added, all in `prim_prince`**; the measured whole-design delta is
**126 lines**, and the diff's extra 28-for-28 exchange is a **second defect the
same predicate repaired** (below). 22 of 22 grid cells go from wrong to
golden-identical, **0 regressions**, five gates green, and the byte verifier
reports **exactly ONE mover in 2311 databases** across both corpora and both
modes — `Earlgrey_0_1/default`, the target itself.

---

## 0. THE LAW

> **§ defGenProcArgNoFormalTs39 — a subroutine call written inside a GENERATE
> SCOPE is a PROCEDURAL call in the DEFINITION listing too, and Surelog stamps
> NO formal typespec on its actuals. `inProcessEmit` covers `emitModuleDef`'s
> process loop and `inGenScopeProc` covers the ELABORATED `gen_scope` loop; the
> DEF-view generate emitter (`emitDefGenStmts`' own process loop, which sets
> `defGenProcessEmit`) is a THIRD emitter of the same context and must be barred
> as well — for a gen-for BODY, a gen-if / gen-else BRANCH and a gen-case ITEM
> alike, and for every kind of actual.**
>
> **A generate CONT-ASSIGN is NOT covered.** It is not a procedural context;
> golden's behaviour there is mixed by actual kind and stays untouched.
>
> **SECOND EFFECT, cmp-invisible and byte-load-bearing:**
> `UHDM::ref_obj::VpiFullName()` is a **lazy memoising getter** — when the field
> is unset it calls `ComputeFullName()` (a `vpiParent` walk) and **caches the
> result forever**. The stamping block READ that getter to name the
> `ref_typespec`, and at that instant `emitDefGenStmts` had **not yet executed
> `p->VpiParent(b)`** on the process, so the walk stopped at the module and froze
> a fullname **missing every generate component**. Not stamping means not
> reading, so those refs are named at DUMP time from the finished tree and reach
> golden's string exactly. **An observation with a side effect: measuring the
> object too early corrupted it.**

### STATED GATE == CODE GATE

`src/ExprEmit.cpp`, the call-argument formal-typespec stamp. Verbatim before:

```cpp
                        if (isFunc && !inProcessEmit && !inGenScopeProc &&
                            !caCondReduceStop && argCtxOk && !pkgScopedRef &&
```

Verbatim after (the ONE added conjunct; everything else in the ~90-line
condition is unchanged):

```cpp
                        if (isFunc && !inProcessEmit && !inGenScopeProc &&
                            !defGenProcessEmit &&
                            !caCondReduceStop && argCtxOk && !pkgScopedRef &&
```

**One production file, one site, one conjunct.** `git diff --stat` is
`src/ExprEmit.cpp | 51 ++++++` (0 deletions), of which **1 line is code** and 50
are the comment that states this law and its two measurements. The single hunk is
`@@ -11347,7 +11347,58 @@`, and `git apply --check` against a fresh `983cf4b`
worktree passes for all 10 files.

`defGenProcessEmit` has exactly ONE writer in the whole tree
(`src/ModuleEmit.cpp` ~26451/26455, set and cleared around the def-view
generate process loop), which is why a single conjunct is the whole change.

---

## 1. THE MEASUREMENT THAT CAME FIRST — BOTH SIDES, SPAN-KEYED

`argts39.py` emits one row per object in a `vpiArgument` slot of a user
`func_call`/`task_call`:

```
<kind> <span> ts=<0|1> call=<callee> ctx=<ordered ancestor chain> name=<fullname>
```

`ctx` is the discriminator carrier, because **a process written inside a
generate branch is written with the same characters as one at module level** and
only the emitted objects say which emitter compiled it. Earlgrey golden,
4 823 448 dump lines, **759 rows**:

| golden ctx (def view unless noted) | ts=0 | ts=1 |
|---|---|---|
| `module_inst/gen_for/named_begin/gen_if_else/named_begin/always/named_begin/assignment/func_call` | **20** | **0** |
| `module_inst/gen_if_else/named_begin/always/named_begin/assignment/func_call` | **10** | **0** |
| `module_inst/always/...` (module-level process, every nesting) | 71 | 0 |
| `module_inst/gen_scope_array/gen_scope/.../always/...` (ELAB gen process) | 55 | 0 |
| `module_inst/cont_assign/func_call` | 57 | 28 |
| `module_inst/gen_scope_array/gen_scope/.../cont_assign/func_call` | 68 | 68+64 |
| `module_inst/function/begin/assignment/func_call` | 118 | 0 |
| `package/function/begin/assignment/func_call` | 118 | 0 |

**THE FENCE, stated as a filter and not as a story:** every row whose `ctx`
contains a generate-branch construct FOLLOWED BY a process.

```
golden: 0 stamped / 30 bare        ours (PRISTINE): 18 stamped / 12 bare
```

**30/30 golden-bare. Zero golden stamps anywhere under a def-view generate
process, in a 4.8-million-line design.** That is the predicate, read off
golden's own objects before a line of code was written.

The 12 that were already bare on both sides are the controls inside the head's
own ctx: parameter/localparam refs (`paramRef`, barred for years) and
`pkg::NAME`-scoped refs (`pkgScopedRef`). The rule being added is **indifferent
to the actual's kind** and those two carve-outs are what keeps it honest.

### Why an object census and not a line grep

The surplus is a **child object** occupying 7 dump lines. A line diff of two
4.8M-line dumps shifts alignment for the rest of the enclosing block, so
`diff | grep -c` cannot count it. `argts39.py` reads objects; `argcmp39.py`
joins the two censuses on the object key and splits the disagreement into
SURPLUS / MISSING / KEY-ONLY, counted as a **multiset** (the elaborated view
repeats a key once per instance).

**KEY-ONLY is why the join alone is not the fence.** On Earlgrey the key join
reports only 4 SURPLUS, because the *other* 14 movers also have a **different
`name`** on our side — the memoised-fullname defect above changes the key. The
fence in `cenpred39.sh` therefore counts by CTX FILTER, not by key join. A key
join alone would have under-counted the movers by 78%.

---

## 2. THE PREDICTION, MADE BEFORE THE PATCHED BUILD EXISTED

`cenpred39.sh <golden.dump> <pristine.dump>`:

```
PREDICTION: 18 actuals lose a formal ref_typespec; golden keeps 0 stamped here
```

all 18 in `prim_prince`, named individually (spans 89:68, 91:69, 92:68, 97:68,
99:69, 100:68, 116:67, 118:68, 119:56, 124:74, 126:68, 127:56, 147:66, 149:67,
150:70, 155:66, 157:67, 158:70) — **14 `ref_obj` + 4 `bit_select`**.

`predlines39.py <pristine.dump>` turns that into the exact per-shape line
multiset:

```
PREDICTED MOVER OBJECTS: 18
PREDICTED LINES REMOVED: 126 (0 added)
   12 |vpiActual:        12 |vpiParent:        12 |vpiTypespec:     (indent 24/22/20)
    6 |vpiActual:         6 |vpiParent:         6 |vpiTypespec:     (indent 20/18/16)
    + 18 \_ref_typespec: / 18 |vpiFullName: / 18 \_<owner> stub / 18 \_logic_typespec:
```

7 lines × 18 objects = 126. **Nothing outside `prim_prince` is reachable.**

### Measured, PRISTINE dump vs PATCHED dump (whole design, both `sed 1d`)

```
$ diff -u pris/o.dump pat/o.dump
removed = 154   added = 28   hunks = 18
line count 4 655 219 -> 4 655 093   =   -126      <-- EXACTLY the prediction
```

The 28-for-28 exchange inside those 154/28 is the **SECOND EFFECT**: 14
`ref_obj`s × 2 lines each (the object header's parenthesised name and the
`|vpiFullName:` field) rewritten from the frozen truncated string to the full
one. **All 22 distinct added line shapes are present VERBATIM in the golden
dump** (checked line-for-line with `grep -qxF` against `g_earl.dump`: 22/22).

So the accounting closes twice over: `154 − 28 = 126` predicted removals, and
the 28 additions are 28 repairs, not 28 new defects.

### Census after the patch

```
golden: 0 stamped / 30 bare        ours (PATCHED): 0 stamped / 30 bare
TOTALS: surplus=0  missing=0
```

**Exact parity on the head's whole population.**

---

## 3. THE GRID, CELL FOR CELL

`a1_argts.sv` crosses CALL SITE × PROCESS KIND × ACTUAL KIND × FORMAL TYPE ×
TARGET SCOPE. `G` = golden, `O` = ours PRISTINE, `P` = ours PATCHED; `ts=1`
means the actual carries a `ref_typespec` naming the callee's formal.

| cell | span | shape | G | O | P | verdict |
|---|---|---|---|---|---|---|
| m1 | 64:23 | module-level `always_comb`, var ref | 0 | 0 | 0 | HOLD (already barred by `!inProcessEmit`) |
| m2 | 70:30 | module-level **cont-assign**, whole RHS is the call | **1** | 1 | 1 | HOLD — golden DOES stamp; the patch must not touch it |
| m3 | 75:38 | module-level `always_comb`, bit-select actual | 0 | 0 | 0 | HOLD |
| g1 | 84:25 | **gen-for BODY** process (def view) | 0 | **1** | **0** | **MOVED to golden** |
| g1e | 84:25 | the same in the ELAB `gen_scope` view | 0 | 0 | 0 | HOLD (`!inGenScopeProc`) |
| g2 | 94:27 | **gen-IF branch** process, module-port ref | 0 | **1** | **0** | **MOVED** |
| g2 | 95:27 | gen-if branch process, **gen-block-LOCAL** ref | 0 | **1** | **0** | **MOVED** |
| g2 | 96:29 / 96:37 | gen-if branch, **two** actuals of one call | 0 | **1** | **0** | **MOVED** (both) |
| g2e | 103:28 | **gen-ELSE branch** process (untaken arm) | 0 | **1** | **0** | **MOVED** |
| g3a | 113:29 / 114:29 | **gen-for > gen-if** (prim_prince's exact shape) | 0 | **1** | **0** | **MOVED** (both) |
| g3b | 119:29 | gen-for > gen-**else** | 0 | **1** | **0** | **MOVED** |
| g4a | 130:29 | **gen-CASE item** process | 0 | **1** | **0** | **MOVED** |
| g4b | 136:30 | gen-case **default** item process | 0 | **1** | **0** | **MOVED** |
| g5 | 150:29 | gen-if `always_ff @(posedge)` | 0 | **1** | **0** | **MOVED** |
| g5 | 153:39 | gen-if `always_latch`, call under an `if_stmt` | 0 | **1** | **0** | **MOVED** |
| g5 | 156:28 | gen-if `always @*` | 0 | **1** | **0** | **MOVED** |
| g5 | 159:28 | gen-if **`initial`**, CONSTANT actual | 0 | **1** | **0** | **MOVED** |
| g5 | 162:38 | gen-if, **bit-select** actual | 0 | **1** | **0** | **MOVED** |
| g5 | 163:28 | gen-if, **part-select** actual | 0 | **1** | **0** | **MOVED** |
| g5 | 164:28 | gen-if, **operation** actual (`in39 ^ K39`) | 0 | **1** | **0** | **MOVED** |
| g5 | 165:28 | gen-if, **nested-call** actual | 0 | **1** | **0** | **MOVED** |
| g5 | 165:39 | the nested call's OWN actual (depth 2) | 0 | **1** | **0** | **MOVED** |
| g5 | 166:28 | gen-if, **localparam** actual | 0 | 0 | 0 | HOLD (`paramRef` already bars it) |
| g5 | 167:28 | gen-if, **`int` formal** + constant actual | 0 | **1** | **0** | **MOVED** |
| g5 | 168:28 | gen-if, **typedef formal** (`pk39::byte39_t`) | 0 | **1** | **0** | **MOVED** |
| g6 | 177:32 | **gen-if CONT-ASSIGN** (def view) | 0 | 0 | 0 | HOLD — the not-covered control |
| g6e | 177:32 | the same in the ELAB gen_scope view | **1** | 1 | 1 | HOLD — golden stamps; untouched |
| f1 | 184:20 | **function body** call | 0 | 0 | 0 | HOLD |
| f2 | 190:44 | **localparam initializer** call | 0 | 0 | 0 | HOLD |
| R2 | 192:39 | module-level cont-assign, call nested in an operation, **module-local** callee | 0 | **1** | **1** | **SURPLUS SURVIVES** → residue R2 |

**22 MOVED, all 22 to exact golden parity. 9 HOLD rows in the table above,
byte-unchanged. 0 regressions. 1 surviving surplus (R2), which is a different law
and is the arm's own cmp head both before and after.**

The table lists two ELAB twins explicitly (`g1e`, `g6e`); the full census carries
**19 more** — one for every MOVED cell — and every one of them is `0 / 0 / 0`,
i.e. already correct in PRISTINE and untouched by the patch. That is the strongest
single fact in this grid: **the patch changes the DEF listing of a process and
leaves the ELAB listing of the same process byte-identical**, which is what
"a third emitter of the same context" has to mean if the reading is right. Three
further ELAB cells where golden DOES stamp (`166:28` constant, `177:32`
cont-assign, `190:44` param_assign) are also untouched.

The arm's whole-dump distance to golden falls **440 → 222** and its
`DUMP_DIFF content` **524 → 306** (hunks 41 → 21). It does not reach
`PASS_CMP`, because R2 (a cell I put in the arm deliberately, not a cell of this
head) is the head at both ends.

### The separating pairs

* **g1 vs g1e** — the same source process seen through the DEF emitter and the
  ELAB emitter. ELAB was already right; DEF was wrong. **This isolates THE
  EMITTER as the discriminator**, with the source text held fixed.
* **g2 vs g6** — the same gen-if branch, `always_comb` vs `assign`. One moves,
  one must not. **This isolates PROCEDURAL-vs-CONTINUOUS**, with the generate
  nesting held fixed.
* **m2 vs g6e** — golden's two `ts=1` cells in the whole arm are both
  cont-assigns. The patch touches neither.

---

## 4. WHY THE BRIEF'S OWN GRID AXES ARE THE WRONG AXES (stated plainly)

The brief asked for: *ref target = function-local var vs function ARG vs module
var vs pkg param; ref site = inside the same function vs outside; type = logic
vs typedef vs class; def-view vs elaborated view.*

Measured answer: **the ref TARGET is irrelevant and the ref TYPE is irrelevant.**
The grid above puts a module port (`94:27`), a gen-block local (`95:27`), a
module-level array element (`89:68`), a `logic` formal, an `int` formal
(`167:28`) and a `typedef` formal (`168:28`) in the same position, and every one
of them behaves identically. What decides is **which emitter compiled the
enclosing statement** — and of the brief's four axes only the last one
(def-view vs elaborated) is even a proxy for it, and only a partial one, because
the ELAB view was already correct and the DEF view was wrong *for generate
scopes only*.

Three of the brief's four axes are therefore **REFUTED as discriminators**, with
cell-for-cell evidence rather than an assertion.

---

## 5. earl38's R3 IS A DIFFERENT FAMILY — REFUTED, NOT ASSUMED

The brief asked whether the same predicate clears earl38's residue R3 (an
untyped def-view gen localparam getting a `ref_typespec` we mint and golden does
not), witness `tools/probe/r10earl38repro/a2_fence.sv`.

**It does not, and it cannot.** Measured with both binaries:

```
a2_fence.sv   PRISTINE  CMP_FAIL  heads=1 lines=17   DUMP_DIFF content=989 hunks=68
a2_fence.sv   PATCHED   CMP_FAIL  heads=1 lines=17   DUMP_DIFF content=989 hunks=68
cmp.log byte-identical: YES
o.dump byte-identical after workdir-path normalisation: YES
```

R3's cmp head, character-identical before and after:

```
LHS: <null>
RHS: ref_typespec: (work@fence38.gen_f1.gen_f1a.F1A_U)
     |vpiParent: \_parameter: (work@fence38.gen_f1.gen_f1a.F1A_U), line:52:31, endln:52:40
     |vpiActual: \_int_typespec: , line:52:7, endln:52:40
```

The surplus hangs on a **`parameter` object**, whose `vpiTypespec` is written by
the localparam arm of the def-view gen emitter. This pass's conjunct sits on the
**call-argument** stamp; a parameter declaration is not a call argument, so the
predicate has no reach there. Both surpluses live under `defGenProcessEmit`-era
code and both are def-view gen-block artefacts, which is what made the brief's
guess reasonable — but they are two different objects written by two different
sites, and R3 stays open exactly where earl38 left it.

**This double-duty as an OVER-FIRE FENCE is the more valuable result:**
`a2_fence.sv` carries 58 def block names across localparams, four process kinds,
case-generates and four type policies, and the patched dump is **byte-identical**
to the pristine one. So is `a1_chain.sv`, which stays **`PASS_CMP`** — the
boundary this pass was told to protect (`§ genChainBranchScopeThreads38`, whose
a1/a2 arms must hold) is **held byte-for-byte**.

---

## 6. THE FIVE GATES

| binary | md5 | 32-hex asserted |
|---|---|---|
| PRISTINE `983cf4b` (built here, `/tmp/wt_r10earl39pris/build/slang-uhdm`) | `d1e122cf2a4999c362efa0ef536765c7` | yes |
| PATCHED (`/tmp/wt_r10earl39/build/slang-uhdm`) | `bbee9562c6a92d50d76199f32bf20f22` | yes |

**GATE 1 — BUILD.** Absolute paths above. Both builds waited for the LINK line
(`[100%] Linking CXX executable slang-uhdm` → `[100%] Built target slang_uhdm`,
`grep -c` = 1; note `slang_uhdm_obj_lib` substring-matches a naive grep, hence
the anchored `slang_uhdm$`). `grep -icE 'error:'` = **0** on both. md5 taken in a
SEPARATE step, length- and charset-asserted at 32 hex, and different between the
two. `git status --porcelain` in the PRISTINE worktree = **0 lines** at
`983cf4b`. **GREEN.**

*Recorded because it is a measurement, not a courtesy:* after all gates had run
I corrected the in-code comment (the first draft said "generate BRANCH" where the
grid proves the law also covers a gen-for BODY — cell g1). I rebuilt and the
binary came back **`bbee9562c6a92d50d76199f32bf20f22`, byte-identical**, so every
number below is a number for the delivered source. A comment edit that changed
the md5 would have voided the gates and I would have re-run them.

**GATE 2 — GOLDENS.** `tests/check_goldens.sh` with `SLANG_UHDM` **exported
first and echoed with its md5** (the script defaults it to the MAIN TREE):
**23 PASS / 0 FAIL**. Negative control `SLANG_UHDM=/bin/false`: **0 PASS /
23 FAIL**. **GREEN.**

**GATE 3 — uhdm2rtlil, `--mode both`, `--jobs 2`**, own `--out`/`--workdir`.

```
[default]   CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2   -> 679/50/2   EXPECTED
[testflags] CMP_EQUAL 679   SLANG_REJECT 50   SURELOG_FAIL 2   -> 679/50/2   EXPECTED
dump (testflags): 496 match / 183 differ / 52 blank             -> 496/183/52 EXPECTED
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
```

The committed baseline carries **testflags rows only** (`awk` count of
non-testflags baseline rows = **0**), so the row gate is fed the TESTFLAGS
PROJECTION: 731 rows against 731. **GREEN.**

**GATE 4 — surelog, BOTH modes, `--jobs 2`.**

```
[default]   CMP_EQUAL 469   CMP_NOTEQUAL 11   SURELOG_FAIL 25   DEFERRED 5  -> 469/11  EXPECTED
[testflags] CMP_EQUAL 465   CMP_NOTEQUAL  8   SURELOG_FAIL 23   DEFERRED 5  -> 465/8   EXPECTED
ct8rows vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
dump histograms UNCHANGED both modes:
  default   325 blank / 244 differ / 225 match   (base == fresh)
  testflags 329 blank / 300 differ / 165 match   (base == fresh)
```

`SURELOG_FAIL` 25/23 and `DEFERRED` 5/5 are **byte-identical to the committed
baseline's own counts**, so the documented detail-row race under concurrent
sweeps did not fire and no isolated re-run was owed. The two surelog sweeps were
run **sequentially** for exactly that reason. `GOLDEN_DEFER` was left UNSET.
`Earlgrey_0_1/default` stays `CMP_NOTEQUAL` and `testflags` stays
`SLANG_REJECT`: **its ROW does not move, its BYTES do**, which is the target.
Its baseline detail string is `decompile:` and the new head's first line is also
`decompile:`, which is why the row is byte-identical rather than merely
same-status. **GREEN.**

**GATE 5 — BYTE VERIFIER**, `r10oth6repro/byteverify.sh`, PATCHED vs the
PRISTINE `983cf4b` I built myself, **both corpora, BOTH modes**:

```
uhdm2rtlil : databases patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
surelog    : databases patched= 953 pristine= 953  PATH_SETS_IDENTICAL  MOVERS: 1 /  953
MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=971d2c072671 pristine=bcc891266140
```

(953, not 1588: a `SLANG_REJECT` / `SURELOG_FAIL` / `DEFERRED` row writes no
`slang.uhdm`, so the byte verifier's population is the databases that exist.
2311 databases compared in total.)

Both mandatory controls fire on both corpora:

```
uhdm2rtlil  SELFCHECK=1  -> 1357 / 1358 flagged      SELFCHECK1=1 -> 1
surelog     SELFCHECK=1  ->  952 /  953 flagged      SELFCHECK1=1 -> 2
```

The surelog `SELFCHECK1` answer is **2 = the one corrupted file + the one real
mover**, which is precisely what that control's own message says to expect
("expected exactly 1 + the real movers"); reading it as a failure would be
misreading the instrument.

**The single surelog mover is `Earlgrey_0_1/default` — the target, named by the
verifier itself.** It is accounted for object-for-object in § 2. Every other
database in either corpus, in either mode, is byte-identical. **GREEN.**

**Independent confirmation that my PRISTINE is the landed baseline:** the
pristine sweeps' CSVs are byte-identical to the committed
`results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv` (`ct8rows`:
0 differing rows for the PRISTINE csv too), and `diff sl_pat.csv sl_pris.csv`
and `diff u2r_pat.csv u2r_pris.csv` are both **empty** — so every row-level
number above is a property of the change, not of the machine.

### Movers per shape, vs GOLDEN, by MULTISET, ADDED and REMOVED separately

`msdist.sh` (alignment-free, whitespace-exact) on Earlgrey:

```
golden vs PRISTINE : golden-only 238619   ours-only 70390   MULTISET DISTANCE 309009
golden vs PATCHED  : golden-only 238648   ours-only 70293   MULTISET DISTANCE 308941
                                                            improvement          -68
```

Per-shape closure: **102 distinct line shapes changed, 93 of them reach EXACT
golden parity (|g−p| = 0)**, and

```
SUM|g-o| over changed shapes = 9809
SUM|g-p| over changed shapes = 9741
                   difference =   68   ==   309009 - 308941
```

**Closes to the unit**, so no line outside the changed shapes moved.

**The 8 shapes that move AWAY, each explained, none a regression:**

| shape (indent significant) | g | pristine | patched | why |
|---|---|---|---|---|
| `\|vpiTypespec:` (indent 22) | 5727 | 3811 | **3799** | −12 |
| `\|vpiParent:` (indent 24) | 24734 | 22966 | **22954** | −12 |
| `\|vpiActual:` (indent 24) | 9908 | 7967 | **7955** | −12 |
| `\|vpiTypespec:` (indent 18) | 5574 | 4382 | **4376** | −6 |
| `\|vpiParent:` (indent 20) | 32631 | 31940 | **31934** | −6 |
| `\|vpiActual:` (indent 20) | 14363 | 12247 | **12241** | −6 |

These six are **anonymous field labels counted design-wide**, and golden has
**more** of each than we do — a large pre-existing typespec-ref DEFICIT
elsewhere in Earlgrey (golden 5727 vs ours 3811 at one indent alone). Deleting a
SURPLUS at the correct 18 positions necessarily moves the global count of an
anonymous label further from golden while the deficit stands. The **object-level**
census is the authority and it says our count in the head's own population is now
**exactly** golden's (0/30 both sides). This is a counting artefact of
whitespace-keyed line shapes, not a byte that got worse: no line moved away from
golden **at a position where golden has one**.

The other two:

| shape | g | pristine | patched | why |
|---|---|---|---|---|
| `\_logic_typespec: , line:336:47, endln:336:52` (indent 20) | 31 | 2 | **0** | net **zero** — the SAME shape at indent 28 goes 33 → 31 (toward golden's 0 by 2). Golden prints that shared `sbox4_64bit` formal typespec at a SHALLOWER tree position than we do; the pair `(−2 at 20, +2 at 28)` is one pre-existing indent-position mismatch, not two defects |
| `\_bit_select: (…p_middle_d64.data_state), line:116:67…` (indent 20) | 2 | 2 | **1** | the line we lost is the `ref_typespec`'s own `\|vpiParent:` BACK-REFERENCE stub. Golden's 2 instances sit at a different structural position; at the object level § 2 reports parity |

### The census-instrument defect I found and fixed in my own tools

`predlines39.py` first reported **0 mover objects** and then **18 lines** instead
of 126. Both were the same misreading of `uhdm-dump`'s layout, and both were
caught by checking the instrument against a hand-read block of the dump rather
than by trusting its output:

1. uhdm-dump prints an object's parent as a **shallow back-reference stub AT THE
   SAME INDENT as the `|vpiParent:` label**, so the stub can sit on top of the
   ancestor stack and `stack[-1]` is not the field's owner. The owner must be
   found **by indent** (`indent − 2`).
2. A singular child object is likewise printed **at its label's indent**, not
   deeper, so a `> indent` capture window swallows nothing.

`argts39.py` was independently correct on both counts (it searches the stack by
indent, and stubs are transient because the next real line pops them) — which is
why the census was right from the first run while the line predictor was not.
**A prediction of 126 that had been derived after seeing the 126 would have been
worth nothing; this one was derived from the pristine dump alone and is
reproducible from it.**

---

## 7. CANARIES

```
canaries.sh  u2r  : rows ok=8  changed=0 absent=0  unknown-names=25   (u2r/surelog split)
canaries.sh  SL   : rows ok=52 changed=0 absent=0  unknown-names=7    (the 7 u2r-only names)
ctcan2.sh    u2r  : EXPECT_UNKNOWN=6  rows ok=1  changed=0 absent=0  unknown-patterns=6  PASS
ctcan2.sh    SL   : EXPECT_UNKNOWN=1  rows ok=58 changed=0 absent=0  unknown-patterns=1  PASS
canaudit.sh       : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
```

Both `ctcan2` runs are **mode-matched to the corpus** and take the COMMITTED
baseline as their first argument, per the script's own contract.

`canaudit` confirms the four slang-fenced names (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) are **dispatched by no driver in this directory**.
They are named nowhere in this README's prose either.

**BY NAME, per corpus, so a vacuous "identical" cannot hide:**

```
InterfaceModPort     gate_uhdm2rtlil.csv : 0 rows (surelog-only canary)  -- vacuous, stated
                     golden_surelog.csv  : 2 rows, both CMP_EQUAL/differ, IDENTICAL
BlackParrotComplex   gate_uhdm2rtlil.csv : 0 rows (surelog-only canary)  -- vacuous, stated
                     golden_surelog.csv  : 2 rows, both CMP_EQUAL/differ, IDENTICAL
```

`Scoreboard` needed no multi-stability arbitration this pass: the byte verifier
reported **one** mover across 2311 databases and it is the named target, so there
was no same-size/size-delta attribution to make. (`Scoreboard` itself is
`CMP_NOTEQUAL/default` + `SLANG_REJECT/testflags` in both sweeps, byte-identical
rows, and it is NOT in the mover list.)

---

## 8. RANKED RESIDUES

**R1 — the NEXT HEAD on `Earlgrey_0_1/default`, fully decoded and ready.**
`prim_prince.sv:105-106`, a DEF-view gen-block CONT-ASSIGN RHS:

```
assign data_state_xor = data_state_round ^
                        prim_cipher_pkg::PRINCE_ROUND_CONST[k][DataWidth-1:0];
```

Golden builds a **`var_select`** named `prim_cipher_pkg::PRINCE_ROUND_CONST` with
TWO `vpiIndex` children (a `ref_obj k`, and a `part_select` carrying
`vpiConstantSelect:1` with `vpiLeftRange`/`vpiRightRange`). We emit a **single
`ref_obj` whose `vpiName` is the whole written text**
`prim_cipher_pkg::PRINCE_ROUND_CONST[k][DataWidth-1:0]` — i.e. the def-view gen
cont-assign path does not decompose a package-array select at all: it hands the
whole written text to a single `ref_obj` as its `vpiName`.

The new cmp log is **100 lines / 1 head** (against the old 17 / 1): golden's
`var_select` subtree is simply a bigger object to print, and the LHS is printed
twice because uhdm-cmp reports the failing pair from both walk entries. **Head
depth is not a distance** — see the headline. Both sides are in `pat/cmp.log` in
full.

Note the two `ref_obj` names inside golden's own print
(`work@prim_prince.gen_fwd_pass.prim_cipher_pkg::PRINCE_ROUND_CONST.k` and
`…PRINCE_ROUND_CONST.PRINCE_ROUND_CONST.DataWidth`): golden's fullname synthesis
for the index refs is itself odd, so whoever takes R1 should transcribe those
strings rather than derive them. **This is the cheapest true next step on this
row**, it is *statement-shaped*, and its fix is in the def-view gen cont-assign
select path (`emitSyntaxExpr`), not in the process path this pass touched.

**R2 — a module-level cont-assign whose call is NESTED IN AN OPERATION stamps a
formal typespec golden withholds.** `a1_argts.sv` cell `192:39`
(`assign out39 = mv39 ^ mv2_39 ^ mf39(in39) ^ LP39 ^ wide39[7:0];`), golden bare,
ours stamped, in BOTH views — and it is the arm's cmp head before and after this
patch. **My arm cannot separate the two candidate distinguishers** and I will not
pretend it can: `mf39` is *both* a MODULE-LOCAL callee *and* nested under a `^`
operation, whereas cell `m2` (`assign mv2_39 = pk39::fv39(in39);`, golden `ts=1`)
is *neither*. The existing code comment near this gate already names
`ndaOpCallArg9` and *"a call nested under an OPERATION in a def-view
cont-assign"* as a known analogue, which makes the operation-nesting reading the
likelier one. **The missing cell is one line:** `assign x = mf39(in39);` (module
-local callee, NOT operation-nested) beside `assign y = a ^ pk39::fv39(in39);`
(package callee, operation-nested). Whoever takes R2 should add those two first.
Earlgrey population unmeasured (golden's `module_inst/cont_assign/func_call` ctx
is 57 bare / 28 stamped, so the population is real but the split is not this
pass's to claim).

**R3 — earl38's R3 stands, and it is NOT this family.** § 5 above, measured on
both binaries. It is a **one-conjunct change in the def-view gen LOCALPARAM arm**
(`typedP2`), and `a2_fence.sv` already carries typed and untyped side by side.
Unchanged from earl38's own ranking; this pass only proved the two are distinct.

**R4 — the memoising-getter trap is a CLASS of defect, not one bug.**
`ref_obj::VpiFullName()` caches a `ComputeFullName()` result on first read, and
every emitter that reads a ref's fullname **before the enclosing statement is
parented** freezes a wrong name. This pass removed one such read by accident. A
cheap audit exists: `grep -n 'VpiFullName()' src/*.cpp` on the ref/select types
and ask, for each, whether the object's ancestor chain is complete at that point.
The 14 Earlgrey objects repaired here are proof the trap is live, and it is
**cmp-invisible** (`ref_obj::Compare` compares `VpiName`, `VpiDefName`,
`VpiGeneric`, `Actual_group`, `VpiStructMember` — **never `VpiFullName`**), so
only a byte gate can ever see it. That is exactly the kind of defect a
`CMP_EQUAL`-but-`differ` row is made of, and 183 u2r + 544 surelog rows are in
that state.

**R5 — the design-wide typespec-ref DEFICIT the away-shapes in § 6 expose.**
Golden has 5727 `|vpiTypespec:` at one indent where we have 3799, and 5574 where
we have 4376 — roughly **3100 typespec refs golden attaches and we do not**, on
Earlgrey alone. Recorded so the six "AWAY" rows are read as a symptom of that
deficit rather than as damage from this patch, and because it is very likely the
largest single remaining byte gap on this row.

**R6 — the u2r corpus has ZERO population for this law** (byte verifier: 0 movers
in 1358 databases). Stated as a measured fact, not a claim of safety by
coverage: this law's only witness corpora are `surelog` and the purpose-built arm.

---

## 9. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm39.sh` | one arm's golden + ours + dumps + cmp. `r10earl38repro/arm38.sh` carried forward (prints the binary md5 on every run; `sed 1d` on both dumps; existence-guards every tool because `uhdm-cmp` exits 0 on a missing input; runs in its own scratch dir because Surelog synthesizes `builtin.sv` into the CWD) |
| `earl39.sh` | **the Earlgrey driver**: one binary → `slang.uhdm` + `o.dump` + `cmp.log`, taking the GOLDEN from the immutable golden cache (`verify_golden.py`'s key) so Surelog is never re-run for it. Encodes the cwd requirement (the `.scr` filelist is relative) and prints the md5 under test |
| `a1_argts.sv` | **THE WITNESS AND ITS AXES** — 30 census cells crossing CALL SITE (module process / gen-for body / gen-if / gen-else / gen-case item / nested gen-for>gen-if / module cont-assign / gen cont-assign / function body / localparam init), PROCESS KIND (`always_comb`/`always_ff`/`always_latch`/`always @*`/`initial`), ACTUAL KIND (var ref / gen-local ref / bit-select / part-select / constant / operation / nested call / param ref) and FORMAL TYPE (vector / `int` / typedef). `g1` vs `g1e` is the separating pair and it isolates THE EMITTER; `g2` vs `g6` isolates PROCEDURAL-vs-CONTINUOUS |
| `argts39.py` | **THE CALL-ARGUMENT FORMAL-TYPESPEC CENSUS** — one row per `vpiArgument` actual with its `ts` flag and its ORDERED ancestor chain. Purpose-built because the defect is a child object, and view-agnostic by construction (the elaborated fullname's `[i]` separates the views, so no def/elab state machine can drop rows — r10earl38's F4) |
| `argcmp39.py` | joins two censuses on the object key as a MULTISET and splits SURPLUS / MISSING / KEY-ONLY. **Its own weakness is stated in § 1:** the key join alone found 4 of the 18 movers, because 14 of them also differ in `name` |
| `cenpred39.sh` | **THE OBJECT-LEVEL MOVER FENCE** — counts by CTX FILTER, not by key join, for that reason. Predicted 18 actuals across the two Earlgrey shapes; 18 moved, 0 elsewhere |
| `predlines39.py` | **THE LINE-LEVEL PREDICTION** from the pristine dump alone: 18 objects, 126 lines removed, 0 added, as an exact per-shape multiset. Two self-inflicted defects found and fixed in it are documented in § 6 |
| `r1_nexthead.cmp` | the PATCHED `uhdm-cmp` log for `Earlgrey_0_1/default`, verbatim — **residue R1's whole witness, shipped rather than described**, so the next pass starts from golden's actual `var_select` shape instead of re-deriving it from a 4.8M-line dump |
| `README.verifier.md` | THIS pass's verifier placeholder — no verdict, written by the implementer, listing exactly what an independent verifier must re-measure |

Reused unchanged and by ABSOLUTE path:
`r10earl38repro/{arm38.sh,a1_chain.sv,a2_fence.sv}` (the boundary arms),
`r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`,
`r10uvm52repro/canaries.sh`, `r10oth6repro/byteverify.sh`,
`r10oth8repro/ct8rows.sh`.
