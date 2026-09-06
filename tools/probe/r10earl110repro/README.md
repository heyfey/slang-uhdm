# r10earl110 — § `hpSelHalfOpParamFold110` — **AN ARITHMETIC HALF OF AN INDEXED PART-SELECT RENDERS ITS PARAMETER LEAVES AT THEIR VALUES WHILE THE OPERATOR SURVIVES** — the Earlgrey_0_1 testflags 176-line head CLEARED (176 → 17)

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**
and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `6949e136` |
| pristine binary | md5 `75b85b861d89b7b7f270284613553218`, built from this pass's OWN worktree at a clean `6949e136` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary | md5 `63c01ddb4d5fe0bf7fe3ff6b32f94e04`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` ONLY — the dotted-base `RangeSelect` hier_path NAME builder |
| probe surface | `tools/probe/r10earl110repro/` only |

---

## READ THIS FIRST — and THE BRIEF IS REFUTED

The brief handed this pass *"an indexed part-select of an interface-array
element's member at `xbar_main.sv:97`, a `Path_elems` size mismatch"*.  Three of
those four claims are wrong, and the owner-finder says so before any code was
written (`own110`, `OWNER.r10earl110.txt`):

| the brief said | what the judge says |
|---|---|
| a **`Path_elems` SIZE mismatch** | **`Path_elems` is 2 on BOTH sides and every element's Compare-visible payload is IDENTICAL** — including the fully folded `Width_expr` `constant dec='6' ct=7`.  The size arm never fired. |
| `xbar_main.sv:97` | `tlul_socket_m1.sv:97` (and `:105`).  `u_sm1_17` is an INSTANCE inside `xbar_main`; the source is `lowrisc_tlul_socket_m1_0.1/rtl/tlul_socket_m1.sv`. |
| an **interface array** | an unpacked **ARRAY OF STRUCTS** module port, `input tlul_pkg::tl_h2d_t tl_h_i [M]` (`:39`). |
| an indexed part-select of a member | TRUE — that part is right, and it is where the difference lives. |

`hier_path::Compare` (`~/git-repos/UHDM/build/generated/src/hier_path.cpp:110`)
reads `Path_elems`, then `Root_value`, then **`VpiName`** — and `VpiName` is the
only field left:

```
LHS (golden)  hier_path VpiName = tl_h_i[i].a_source[0+:8 - 2]
RHS (ours)    hier_path VpiName = tl_h_i[i].a_source[0+:IDW-STIDW]
```

Everything else that differs between the two dumps — the index `ref_obj`'s
`VpiFullName`, the `indexed_part_select`'s `VpiFullName`, an end column of 40
against 39 — is **invisible to the judge**: no generated `Compare` reads a
fullname, a file or a span (RESUME.md §9).

| | |
|---|---|
| the head | **Earlgrey_0_1/testflags, 176 cmp lines, ONE head — CLEARED.**  176 → **17**, one head, a different family (R0 below). |
| Earlgrey_0_1/default | **31 lines, unchanged, cmp log BYTE-IDENTICAL** — the pre-existing `u_pinmux.gen_mio_periph_in[0].data_mux` null r10earl107 named, which this pass does not touch. |
| the grids | 6 arms × 2 views, 98 census keys, calibrated golden-vs-golden at **148 cells, 0 DIFF**: **TOGOLD 36, AWAY 0, MOVEDWRONG 2, STILLWRONG 38, SAME_AGREE 18**. |
| goldens | 23 PASS / 0 FAIL on the patched binary; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |

---

## 1. THE JUDGE, DECODED FIRST — `own110`, the owner-finder AND field bisector

`own110.cpp` runs the OFFICIAL `design::Compare` (the same call `uhdm-cmp`
makes), names the failed pair, prints BOTH `Path_elems` lists in full with the
COMPARE-VISIBLE payload of every element, and then **BISECTS the field by
MASKING**: it copies golden's `VpiName` onto our head `hier_path`, re-runs a
FRESH `design::Compare`, and prints the next head.  Repeating that walks the
whole reachable family and COUNTS it.  Full output in `OWNER.r10earl110.txt`:

```
== ITERATION 0 : design::Compare -> -17
   HEAD LHS(golden) = hier_path id:1615258  tlul_socket_m1.sv 97:7-97:41
   HEAD RHS(ours)   = hier_path id:1292361                    97:7-97:41
  LHS(golden) VpiName='tl_h_i[i].a_source[0+:8 - 2]'  Path_elems=2  Root_value=<null>
      [0] bit_select name='tl_h_i'   index: ref_obj name='i' actual=parameter('i')
      [1] indexed_part_select name='a_source' ipsType=1 constSel=1
             base:  constant dec='0' size=64 ct=9
             width: constant dec='6' size=64 ct=7
  RHS(ours)   VpiName='tl_h_i[i].a_source[0+:IDW-STIDW]'  Path_elems=2  Root_value=<null>
      [0] bit_select name='tl_h_i'   index: ref_obj name='i' actual=parameter('i')
      [1] indexed_part_select name='a_source' ipsType=1 constSel=1
             base:  constant dec='0' size=64 ct=9
             width: constant dec='6' size=64 ct=7
   SIZE TEST: 2 vs 2 -> EQUAL (the size arm did NOT fire)
   VPINAME  : DIFFERS      -> masked, re-running
== ITERATION 1 : design::Compare -> -17
   HEAD = hier_path @105:33-105:67
   golden 'tl_h_i[i].a_source[8 - 1-:2]'   ours 'tl_h_i[i].a_source[IDW - 1-:2]'
   SIZE TEST: 2 vs 2 -> EQUAL       VPINAME: DIFFERS   -> masked, re-running
== ITERATION 2 : design::Compare -> 1
   HEAD LHS(golden) = ref_typespec id:793443      HEAD RHS(ours) = <null>
   NOT a hier_path pair -- the family is exhausted here.
```

**THE FAMILY THE JUDGE REACHES IS EXACTLY TWO CELLS WIDE**, both in
`tlul_socket_m1.sv`, and the object that comes after them was named BEFORE the
patch existed — it is the R0 this pass hands on, and the patched binary's head
is that object to the byte (`HEAD_AFTER_Earlgrey_testflags.cmp`).

### the SOURCE

```systemverilog
 72:  localparam int unsigned IDW   = top_pkg::TL_AIW;      // 8
 73:  localparam int unsigned STIDW = $clog2(M);            // 1 or 2, per instance
 89:  for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
 96:    assign shifted_id = {
 97:      tl_h_i[i].a_source[0+:(IDW-STIDW)],
 98:      reqid_sub
 99:    };
105:    assign unused_tl_h_source = tl_h_i[i].a_source[IDW-1 -: STIDW];
```

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

A `hier_path`'s `VpiName` is not spelled from the source text.
`CompileHelper::compileSelectExpression`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:1403-1546`) builds
the select object and IMMEDIATELY appends `decompileHelper(sel)` to the running
name:

```cpp
if (expr *sel = (expr *)compilePartSelectRange(component, fC, Constant_range,
        field_name, compileDesign, reduce, path, instance, muteErrors)) {
  ...
  hname.append(".").append(field_name).append(decompileHelper(sel));   // :1484
}
```

`CompileHelper::decompileHelper` (`CompileHelper.cpp:2544`) is a CLOSED
dispatch, and its `indexed_part_select` row is

```cpp
StrCat("[", decompileHelper(pselect->Base_expr()),
       (VpiIndexedPartSelectType() == vpiPosIndexed ? "+" : "-"), ":",
       decompileHelper(pselect->Width_expr()), "]")
```

with `constant -> VpiDecompile`, `ref_obj -> VpiName`, **`operation ->
ExprEval::prettyPrint`**.  `ExprEval::prettyPrint`'s binary-operation arm
(`~/git-repos/UHDM/templates/ExprEval.cpp:1081-1087`) prints

```cpp
out << out_op0.str() << " " << opToken[opType] << " " << out_op1.str();
```

— **one space on each side of the token** — and the printer has **no
parenthesis node at all**, so every parenthesis written in the source
disappears.

### WHY THE OPERATION IS STILL THERE WHEN THE NAME IS COMPOSED

`compilePartSelectRange` (`CompileExpression.cpp:4258-4292`) compiles BOTH
halves with the caller's `reduce`, so in an elaborated context each half's
parameter LEAVES come back as `constant`s — and then it reduces the select
**only when BOTH halves are ALREADY constants**:

```cpp
if ((reduce == Reduce::Yes) &&
    (part_select->Base_expr()->UhdmType() == uhdmconstant) &&
    (part_select->Width_expr()->UhdmType() == uhdmconstant)) { ... reduceExpr ... }
```

A half that is an OPERATION therefore survives the name composition UNFOLDED,
and `prettyPrint` renders it over its already-folded leaves.  UHDM's
post-export `ElaboratorContext`/`UhdmAdjuster` later replaces that operation
with the folded constant and **never re-renders the name** — which is exactly
why golden's stored `Width_expr` at `:97` is the `vpiIntConst` **6** while its
NAME still reads **`8 - 2`**.

That is r10uvm94's measured **"fossil" class**: its whole-golden-cache
calibration found 380 name/object disagreements out of 8116 `indexed_part_select`
path elements and *"the split is PERFECT on one signature — every one of the 380
carries a `vpiIntConst` (constType 7) base or width"*.  uvm94 concluded that no
transcription off the FINAL tree can reach them.  It is right: **the reachable
road is not transcription, it is rendering the half from the SOURCE tree with
its leaves folded**, which is what this pass does.

---

## 3. THE SCOPE AXIS — MEASURED ONE AXIS AT A TIME, NOT ASSUMED

The first cut of this law fired wherever a parameter leaf folded, and arm `g3`
convicted it immediately: golden keeps the identifiers in a plain module-scope
`assign`, in `always_comb`, in `initial`, in `always_ff` and in a function
body, and folds them in an `if`-generate.  Arm `g6` then varies ONE axis at a
time.  Golden, `-elabuhdm`, the count is objects at that key:

| cell | shape | golden |
|---|---|---|
| `v0` | module body, NO generate | `arr6[0].w6[0+:SA - SB]` ×3 — **SYMBOLIC** |
| `v1` | for-generate, PARAMETER bound, genvar receiver | `[0+:7 - 2]` ×6 + `[0+:SA - SB]` ×1 — **FOLDED** |
| `v2` | for-generate, parameter bound, CONSTANT receiver | **FOLDED** |
| `v3` | for-generate, LITERAL bound 3 | **FOLDED** |
| `v4` | for-generate, ONE iteration | **FOLDED** |
| `v5` | one iteration, genvar receiver | **FOLDED** |
| `v6` | one `for` level | **FOLDED** |
| `v7` | **TWO `for` levels** | `[0+:SA - SB]` ×8 — **SYMBOLIC** |
| `v8` | `if`-generate | **FOLDED** |
| `v9` | **`if` INSIDE a `for`** | `[0+:SA - SB]` ×5 — **SYMBOLIC** |

So the axis is **neither "elaborated", nor "`for` versus `if`", nor the loop
bound, nor the receiver's index — it is the DEPTH of the generate nesting, and
only depth 1 folds.**  Depth 0 (module scope, procedural blocks, function
bodies) and depth ≥ 2 both keep the identifiers.  The corpus head is at depth 1
(`gen_host_fifo`), and arm `g3` agrees with `g6` cell for cell.

The depth is read off the **UHDM parent chain of the object the path is being
attached to** — where the path actually lands — and NOT off `currentScope`,
which RESUME.md §9 records as STALE throughout `emitInstance`.

---

## 4. THE LAW

> **§ `hpSelHalfOpParamFold110`.**  A half (base or width) of an INDEXED
> part-select that closes a DOTTED-base `hier_path` renders as
> `ExprEval::prettyPrint` renders the operation Surelog still holds there when
> it composes the name: each **parameter leaf at its VALUE**, each **integer
> literal in its own written spelling**, each **genvar SPELLED**, the `+`/`-`/
> `*`/`/` token with ONE SPACE on each side, and no parentheses — **and only
> where the select sits at generate-nesting depth EXACTLY ONE.**
>
> **THE LEAF TEST IS `selWidthParamFold`'s OWN** (§ `hierSelWidthOvParamNoFold`):
> a localparam or a package parameter folds; an OVERRIDABLE module parameter
> does not.  A genvar-derived parameter renders as its NAME and does not count
> as a fold.
>
> **AT LEAST ONE LEAF MUST ACTUALLY FOLD.**  This is the law's safety property,
> not a convenience: a half with no folding parameter in it returns `ok=false`
> and the pre-existing rendering runs BYTE FOR BYTE, so **the gate can only ever
> fire on a cell that was ALREADY WRONG** (it displayed an identifier where
> golden displays a value).  **AWAY is impossible by construction**, and the
> grids measure AWAY = 0 over 98 keys.

### STATED GATE == CODE GATE

**STATED:** an indexed part-select half on a dotted-base `hier_path`, at
generate depth exactly 1, that is a `+`/`-`/`*`/`/` tree over integer literals,
genvars and `selWidthParamFold`-folding parameters, with at least one fold.

**CODE:** `genDepth110(parent) == 1`, `stripImplicitConv(h).kind ==
ExpressionKind::BinaryOp`, `renderHalf110(...)` returning true, and
`folded110`.  There is no third condition in the code that is absent from the
prose and none in the prose that is absent from the code.  The `Simple`
(`[l:r]`) arm, the `NamedValue`-base arm and `renderBound9` are UNTOUCHED; the
`wf9.ok` and `else` arms were merged into one expression that is
term-for-term identical to the two it replaced whenever the new folds are off.

### the gates that were REFUTED, each on an arm cell or on the judge

| candidate gate | refuted by |
|---|---|
| "the head is a `Path_elems` SIZE mismatch" (the brief) | §1 — `own110` prints both lists: 2 vs 2, payload for payload identical |
| "the head is in `xbar_main.sv`" (the brief) | §1 — `tlul_socket_m1.sv`, an instance of it |
| "an interface array" (the brief) | §1 — an unpacked array of structs on a module port |
| "the axis is DEF versus ELAB" | `g3`/`g6` — golden keeps the identifiers in an ELABORATED module-scope `assign`, an `always_comb`, an `initial`, an `always_ff` and a function body |
| "the axis is `for` versus `if` generate" | `g6` v8 folds (`if`), v7 does not (`for`) |
| "the axis is the loop bound or the iteration count" | `g6` v3/v4/v5 — literal bound, ONE iteration, both fold |
| "any generate scope folds" | `g6` v7/v9 — depth 2 does NOT fold, either nesting |
| "fold the whole half to its value" | golden's own bytes — the name is `8 - 2` while the OBJECT is the constant 6 |
| "re-spell the literal in decimal" | `g2` f9 — golden keeps `9 - 4'd3` |
| "a genvar folds like a parameter" | `g2` fb — golden reads `chan[z].fld[z * 3+:4]`: `LCB` folds, `z` stays |
| "the law belongs to the WIDTH half" | `g1` c2 / `g2` fc — the BASE half takes it too |
| "one binary level is enough" | `g2` f7 — golden reads `9 - 3 - 1`, so the renderer recurses |
| "the SIMPLE `[l:r]` arm is the same law" | `g1` c3 — golden folds there too, but through `renderBound9`, a different rendering with its own spacing rule; left as residue R4 |

---

## 5. THE GRIDS — 6 arms × 2 views, calibrated FIRST

`calib110.sh` builds each arm's Surelog golden TWICE in two different
directories and scores the two censuses against each other: **148 cells over
the twelve arm-views, 0 DIFF** (`CALIB.r10earl110.txt`).  Only then does
`grid110.sh` build golden + both frozen binaries per arm-view, record EVERY rc,
and hand three censuses to `score110.py`, which joins them as a MULTISET on
`(span, ordered element kind:name vector)` and compares the SET of names at each
key — never the multiplicity (r10uvm170 residue R6: an elaborated copy count and
a definition copy count differ legitimately).

| arm | axis | TOGOLD | AWAY | MOVEDWRONG | STILLWRONG |
|---|---|---|---|---|---|
| `g1_head110` | the head shape rebuilt: width-arith, base-arith, SIMPLE part select, bit select, bare-param width, literal-only | 2 | 0 | 0 | 1 |
| `g2_fence110` | the fence: `-` `+` `*` `/`, package param, overridable param, three-term, `$clog2`, based literal, literal-only, genvar, `-:` with both halves arith | 8 | 0 | 1 | 3 |
| `g3_home110` | homes: module assign, `always_comb`, `initial`, `always_ff`, `if`-generate, nested `for`, function body | 1 | 0 | 0 | 5 |
| `g4_recv110` | receivers: array-of-struct, plain struct, nested chain, chain under an array element, 2-D array, INTERFACE-ARRAY element, port-connection position | 0 | 0 | 0 | 6 |
| `g5_neg110` | negative controls: literal halves, literal arithmetic, genvar-only arithmetic, bare-param width, simple part select, bit select | 0 | 0 | 0 | 1 |
| `g6_scope110` | the scope axis, ten cells (§3) | 7 | 0 | 0 | 3 |
| **both views, totals** | 98 keys | **36** | **0** | **2** | **38** |

The two `MOVEDWRONG` are `g2` cell `f5` in each view and are a **strict
improvement**, not a regression: golden folds a PACKAGE parameter in BOTH views
(packages compile first, so even the definition copy has a value), and the patch
converts our four elaborated copies while the definition copy — minted by a
DIFFERENT site, `TypeEmit.cpp`'s § `hpSelParenStrip` — stays symbolic.  Four of
five objects at that key now match golden where none did.  It is residue R3.

Every remaining `STILLWRONG` is the SAME pre-existing defect and is named in §7.

---

## 5b. THE WIDE BOUNDARY — the gate that convicts what no corpus can see

`widerun110.sh` stages a COPY of the WHOLE `tools/probe` tree, builds the file
list at ANY depth, filters the slang-fenced names out of it BEFORE a single
child runs (the fence list is read out of `canaudit.sh`'s own `FENCED=` line, so
the four names are never spelled here), and hands it to `wide110.sh`, which runs
BOTH frozen binaries in BOTH views on every file and byte-compares the
workdir-normalised `uhdm-dump`s.  The list goes in on **fd 3** and every child
gets `</dev/null` (a stdin-list was once swallowed by the first child), every
`rc` is recorded per side, and `PROCESSED` is asserted against `LISTED`.

```
LISTED=4921  FENCED_REMOVED=0  (of 4921 found)
PROCESSED=4921 identical=9444 DIFFERING=18 no_output=380
PROCESSED==LISTED (4921)
rc by side:  A/0 9073  A/3 364  A/4 389  A/139 16
             B/0 9073  B/3 364  B/4 389  B/139 16      ASYMMETRIC rc rows: 0
```

**Every differing file is accounted for**, and NONE of them is a regression:

| file | verdict |
|---|---|
| `r10earl110repro/g1_head110.sv`, `g2_fence110.sv`, `g3_home110.sv`, `g6_scope110.sv` | this pass's own converting arms (`g4_recv110` and `g5_neg110`, the negative controls, do NOT move) |
| `r10earl34repro/a2_shape.sv` | **TOGOLD** — `tl_h_i[gi].a_source[0+:FromPkg-FromClog]` → golden's `[0+:9 - 5]`, both views.  earl34 built that arm for this exact corpus shape and left it as its own residue; this law closes it. |
| `r10earl69repro/a1_hpname69.sv` | **TOGOLD** — `read_buf[i].addr[PP + i+:8]` → golden's `[7 + i+:8]`, both views.  The genvar `i` stays SPELLED while `PP` folds: § `hpNameBareIdxFold69`'s own measured note about genvars, now reproduced by this renderer. |
| `r10earl69repro/a2_fence69.sv` | **TOGOLD** — `st[i].a[QP - 1+:4]` → golden's `[5 - 1+:4]`, both views. |
| `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv` | **the DOCUMENTED LAYOUT ARTEFACT, not this law.**  Both move one tail constant by exactly **4096** (`22593273` → `22597369`) — the number r10uvm154 committed `l154_noenum.sv` to prove: *"a class-scoped `typedef <T> name[string]` leaks a binary-layout-derived number into a tail constant … so ANY code motion anywhere in the emitter moves it"*, on a source that contains no enum at all.  Both binaries are EQUIDISTANT from golden there (golden emits a `string_typespec`, we emit an `operation` over a garbage-valued constant), the value is run-STABLE per binary (four runs each), path-independent (two differently named directories), and **both arms' `uhdm-cmp` logs are BYTE-IDENTICAL between the two binaries** (`g22` 3438 lines, `l154_noenum` 17 lines, one head each). |

The three foreign TOGOLD arms were SCORED against a freshly built Surelog
golden, not merely observed to differ (`BOUNDARY_FOREIGN.txt`): **TOGOLD 1,
AWAY 0, MOVEDWRONG 0** in each of the six arm-views, and **AWAY 0 /
MOVEDWRONG 0 in all ten** foreign arm-views including the two layout ones.

Every `rc=139` in `BOUNDARY_WIDE.signal` appears on **BOTH sides** (`A` and
`B`) of the same file and view — pre-existing segfaults on legal SV, not
introduced here.

### THE FLOOR

Every other arm in the tree is byte-identical between the two binaries — the
r10uvm175 / r10uvm172 / r10uvm124 / r10uvm89 / r10uvm74 / r10buvm3-15 /
r10sd8-12 / r10earl45-60 / r10earl100-109 arm sets, the § `genCaNestedModuleLhsOpRhsBinds59`
binder mirror, the port `high_conn` arms, the assignment-pattern /
`tagged_pattern` arms, and the uvm / buvm arms all hold.

---

## 6. GATES — ALL GREEN

| gate | result |
|---|---|
| **1 build** | both binaries built `-j 2` from this pass's own worktree; pristine `75b85b861d89b7b7f270284613553218` = the main tree's `build/slang-uhdm` byte for byte; patched `63c01ddb4d5fe0bf7fe3ff6b32f94e04`; both frozen `chmod 555` BEFORE any sweep, and every `cmds.txt` audited by BINARY PATH |
| **2 goldens** | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (the negative control proves the harness can see) |
| **3 uhdm2rtlil** | testflags and default both **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**.  `ct8rows` **0 differing rows** against `results/gate_uhdm2rtlil.csv`, against this pass's own pristine testflags sweep, and against its own pristine default sweep — status AND dump column |
| **4 surelog** | `--mode both`, 1588 comparable rows.  `ct8rows` **0 differing rows** against `results/golden_surelog.csv` AND against this pass's own pristine sweep.  **NO ROW CONVERTED; nothing promoted; `results/*.csv` untouched.**  The pristine sweep itself reproduced the committed baseline row for row before the patch was built. |
| **5 byteverify** | `SELFCHECK=1`: uhdm2rtlil **0 movers / 1358**; surelog **3 movers / 956** — see below |
| canaries | `canaries.sh` surelog **ok=52 changed=0 absent=0**; uhdm2rtlil **ok=8 changed=0 absent=0**.  `ctcan2.sh` PASS on both.  `canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr` SAME in both modes; **`SVSwitch` `4842211c4030`**, **`YosysVerx` `6ccda350c24a`** — the brief's pins to the digit |
| heads | the seven-row head set, both modes: **11 of the 12 measurable `uhdm-cmp` logs BYTE-IDENTICAL**; the twelfth is the target |

### THE THREE SURELOG MOVERS, EACH ATTRIBUTED

```
MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm    PREDICTED BY NAME
MOVER ./testflags/Earlgrey_0_1-71da2fd7/slang.uhdm  PREDICTED BY NAME
MOVER ./default/SeqDriver-32af76aa/slang.uhdm       NOT the law -- proved below
```

`PREDICT_R0.txt` was written from PRISTINE databases BEFORE the patched sweeps
ran and named *"EXACTLY TWO byte movers: Earlgrey_0_1/default and
Earlgrey_0_1/testflags"* for surelog and *"ZERO byte movers, both modes"* for
uhdm2rtlil, candidate by candidate over the 18 + 20 regex candidates.  Both
predictions hold.

**SeqDriver/default is the documented per-invocation COIN (RESUME.md §9), and
this pass proves it on the PATCHED BINARY ITSELF rather than asserting it:**

* the ORDER-BLIND diff (both `uhdm-dump`s path-normalised and SORTED) is
  **0 lines** — the raw 42-line difference is two `bit_typespec` objects
  (`uvm_reg_data_t` / `uvm_reg_addr_t`) swapping slots;
* the patched binary run **four times in isolation** on that exact command line
  produces `b98b3c9300fb64ad3d8462812f33a271` every time — **which is the hash
  the PRISTINE sweep recorded**.  The patch does not change that database at
  all; the sweep's `4dad6007d724` is the parallel-parse coin landing the other
  way in that one invocation;
* its `uhdm-cmp` log is BYTE-IDENTICAL between the two sweeps, so the flip is
  invisible to the judge.

### THE CORPUS CENSUS AT THE MOVED ROW (`CENSUS_earlgrey.txt`)

Every `hier_path` in the Earlgrey_0_1 databases, both modes, golden vs pristine
vs patched, keyed as in §5:

| | default | testflags |
|---|---|---|
| keys | 3662 | 3662 |
| SAME_AGREE | 3648 | 3648 |
| **TOGOLD** | **2** | **2** |
| **AWAY** | **0** | **0** |
| **MOVEDWRONG** | **0** | **0** |
| STILLWRONG | 9 | 9 |
| one-sided (G-ONLY / O-ONLY) | 3 / 13 | 3 / 13 |

and the two moved keys match golden **object for object**, multiplicity
included:

| key | golden | ours PRISTINE | ours PATCHED |
|---|---|---|---|
| `97:7-97:41` | `[0+:8 - 1]` ×40, `[0+:8 - 2]` ×18, `[0+:IDW - STIDW]` ×1 | `[0+:IDW-STIDW]` ×58, `[0+:IDW - STIDW]` ×1 | **= golden, 40/18/1** |
| `105:33-105:67` | `[8 - 1-:1]` ×40, `[8 - 1-:2]` ×18, `[IDW - 1-:STIDW]` ×1 | `[IDW - 1-:1]` ×40, `[IDW - 1-:2]` ×18, `[IDW - 1-:STIDW]` ×1 | **= golden, 40/18/1** |

**116 objects converted; the two DEFINITION copies — the ones golden keeps
symbolic — were already right and stayed right.**  The nine STILLWRONG keys and
both one-sided sets are IDENTICAL between the pristine and the patched
databases: this law reaches nothing else in that design.

---

## 7. RESIDUES, and R0

* **R0 — THE NEXT HEAD IS NAMED AND MEASURED, and it was named BEFORE the patch
  existed** (`own110`'s mask ladder, iteration 2) and confirmed on the patched
  binary afterwards (`HEAD_AFTER_Earlgrey_testflags.cmp`).
  `Earlgrey_0_1/testflags`, **17 cmp lines, one head**, a SINGULAR field with
  `RHS <null>`:

  ```
  LHS (golden)  ref_typespec (work@top_earlgrey.u_xbar_main.u_sm1_17) id:793443
                |vpiParent -> constant  tlul_socket_m1.sv 105:61-105:66
                              (the folded STIDW WIDTH of
                               tl_h_i[i].a_source[IDW-1 -: STIDW])
                |vpiActual  -> int_typespec  73:14-73:26
                              (the `localparam int unsigned STIDW` DECLARATION)
  RHS           <null>
  ```

  Golden stamps a folded MODULE-LOCALPARAM select bound with that localparam's
  own declaration typespec; ours leaves the constant bare.  That is the
  § `elabHierSelWidthFold` / `stampFoldedPkgParamTs` family, whose declaration
  comment in `include/UhdmExporter.h` currently records *"A MODULE-scope
  parameter has no such object and is left bare"* — this cell says otherwise
  for a module LOCALPARAM, and reconciling the two is the next pass's decode.
  `Earlgrey_0_1/default` keeps its own pre-existing head (r10earl107's
  `u_pinmux.gen_mio_periph_in[0].data_mux` null) at 31 lines, byte-identical.

* **R1 — an OVERRIDABLE MODULE PARAMETER inside an arithmetic half.**  Arm `g2`
  cell `f6` measures golden at `chan[z].fld[0+:5 - 1]` ×4 elaborated +
  `[0+:OVW - 1]` ×1 definition, so golden DOES fold an overridable module
  parameter there.  This law refuses it, because its leaf test is
  `selWidthParamFold`'s own and that function's § `hierSelWidthOvParamNoFold`
  distinguisher was measured the OTHER way on a BARE width
  (`spi_device.sv:159`, `reg2hw.rxf_addr.base.q[SDW+:SramAw]`, where golden
  keeps BOTH the name and the `vpiWidthExpr` symbolic and `SramAw` is
  `parameter int SramAw = 9` in the port list).  The two cells disagree and the
  reconciliation needs its own arm and its own census — admitting the
  overridable kind here would also destroy this law's AWAY-impossible property,
  because a source that already writes `OVW - 1` with spaces renders
  IDENTICALLY to golden today.  ZERO corpus cells: no candidate in either
  corpus carries one (§ the narrowing in `PREDICT_R0.txt`).  1 arm flip per view.

* **R2 — a SYSTEM-CALL leaf.**  Arm `g2` cell `f8`: golden reads
  `chan[z].fld[0+:$clog2(2) + 1]` — `prettyPrint`'s `sys_func_call` row prints
  `name(` + comma-joined args + `)` with NO spaces, and the ARGUMENT (`NCH`, an
  overridable module parameter) folds inside it.  The gate refuses any leaf that
  is not a literal, a parameter or a genvar.  The same arm records a SECOND,
  pre-existing defect one site over: our DEFINITION copy reads
  `$clog2NCH + 1` — § `hpSelParenStrip` in `TypeEmit.cpp` strips the CALL's
  parentheses along with the grouping ones.  Neither is touched here.  ZERO
  corpus cells under this gate.

* **R3 — the DEFINITION copy of a PACKAGE-parameter half.**  The grid's only
  two `MOVEDWRONG` cells, `g2` `f5` in each view.  Golden folds a package
  parameter in BOTH views (a package compiles first, so even the definition copy
  has a value) and reads `chan[z].fld[0+:6 - 1]` ×5 with no symbolic row at all.
  The patch converts our four ELABORATED copies; the DEFINITION copy is minted
  by a different site — `TypeEmit.cpp`'s § `hpSelParenStrip` — and stays
  `pk2_110::PKW - 1`.  Four of five objects at that key now match golden where
  none did.  The fix belongs to the definition-view builder.

* **R4 — the SIMPLE `[l:r]` part-select arm.**  Arm `g1` cell `c3`: golden reads
  `inbus[q].payl[8 - 1:2]` where we read `[WFULL - 1:2]` (elaborated) and
  `[WFULL - 1 : WSUB]` (definition, where golden writes `[WFULL - 1:WSUB]` —
  a second, pre-existing SPACING defect around the `:`).  `decompileHelper`'s
  `part_select` row is the same rendering one row up, so the LAW is the same;
  the SITE is not — the Simple arm goes through `renderBound9`, which has its
  own spacing convention, and a change there would move every simple part-select
  bound in both corpora.  Deliberately out of scope; it needs its own census.
  The corpus population is visible in `PREDICT_sl.txt`/`PREDICT_u2r.txt`
  (`apb_if.paddr[ADDRESS_WIDTH - 1:0]`, `tl_i.a_address[SubAW - 1:0]`,
  `bus.wdt[GW - 1:0]`, `sub.adr[ADR - 1:]`, …).

* **R5 — the WIDTH half's spacing when NOTHING folds.**  Arm `g2` cell `fa`
  (`[0+:(9-3)]`) and arm `g5` cell `n2`: golden reads `[0+:9 - 3]`, we read
  `[0+:9-3]`.  The BASE half already goes through `spaceOps9` and is right; the
  WIDTH half does not (the site's own comment says *"the +:/-: token and the
  width stay tight"*, which is true of the TOKEN and false of the width's
  interior).  This law will not fix it, on purpose: with no folding leaf the
  cell is one where our text can already equal golden's, so spacing it is the
  one change that could be AWAY, and it needs its own measurement.  This is why
  arm `g5`'s `n2` reads STILLWRONG rather than converting.

* **R6 — the BIT-SELECT index and the genvar-index name.**  Arm `g1` `c4`
  (`inbus[q].payl[WSUB]` → golden `[2]`), and the Earlgrey census's untouched
  `109:19`-`118:19` family (`tl_h_i[i].a_valid` → golden `tl_h_i[0]` /
  `tl_h_i[1]` / `tl_h_i[2]`).  A different element kind, a different builder,
  and the genvar-folding direction is context-dependent — golden folds the
  genvar in that family and SPELLS it at `:97`.  Untouched, and unchanged
  between the pristine and the patched databases.

* **R7 — `g4`'s one-sided pair.**  `o2d[0][1].top[...]` — golden's element list
  is `bit_select(o2d), bit_select(<unnamed>), indexed_part_select` (r10buvm14's
  multi-dimension chain) where ours is `bit_select(o2d), indexed_part_select`,
  so the two never join.  A `Path_elems` SIZE difference — the family the brief
  named, in an arm rather than at the head — and unchanged by this pass.  Also
  in `g4`: `oflat.top[0+:(RA - RB]` keeps a stray `(` on both binaries, a
  pre-existing NamedValue-base rendering defect on a NON-array receiver.

---

## 8. FILE MAP

| file | what it is |
|---|---|
| `own110.cpp` | the owner-finder AND field bisector: official `design::Compare`, both element lists with Compare-visible payloads, then the VpiName mask ladder that counts the family |
| `OWNER.r10earl110.txt` | its output on the PRISTINE pair — the head decode, written before any code |
| `cen110.cpp` | the hier_path NAME census, keyed on `(span, ordered element kind:name vector)`, deduped by object identity over `Serializer::AllObjects()`, `CENRC` asserted |
| `score110.py` | the multiset scorer (TOGOLD / AWAY / MOVEDWRONG / STILLWRONG / one-sided) |
| `calib110.sh`, `CALIB.r10earl110.txt` | golden-vs-golden calibration, 148 cells 0 DIFF |
| `grid110.sh`, `GRID.r10earl110.txt` | the three-way grid and its per-arm scores |
| `g1_head110.sv` … `g6_scope110.sv`, `TOPS.txt` | the arms |
| `predict110.sh`, `PREDICT_sl.txt`, `PREDICT_u2r.txt` | the corpus-wide candidate scan over PRISTINE databases |
| `PREDICT_R0.txt` | the mover prediction and the R0 decode, written BEFORE the patched sweeps ran |
| `HEAD_BEFORE_*.cmp`, `HEAD_AFTER_*.cmp` | the committed `uhdm-cmp` head logs, both modes |
| `wide110.sh`, `widerun110.sh`, `BOUNDARY_WIDE.*` | the wide boundary over a COPY of the whole probe tree, both views |
| `BOUNDARY_FOREIGN.txt` | every arm the wide boundary flagged that is NOT this pass's own, scored three-way against a freshly built Surelog golden |
| `CENSUS_earlgrey.txt` | the whole-database hier_path name census at the moved row, both modes, golden / pristine / patched |
| `cen_g_testflags.txt`, `cen_p_testflags.txt`, `cen_a_testflags.txt` | the three raw censuses behind it |
| `byteverify.sh`, `canaries.sh`, `canaudit.sh`, `ct8rows.sh`, `ctcan2.sh`, `rowheads.sh` | the standing verification battery, copied unchanged |
