# r10earl113 — § `genScopeCaPatNoFirstSize113` — **A GENERATE-SCOPE CONTINUOUS ASSIGN'S PATTERN NEVER SIZES ITS FIRST OPERAND, BECAUSE THE PASS THAT FLATTENS IT THERE IS NOT THE PASS THAT SIZES IT** — Earlgrey_0_1 testflags **364 → 17** cmp lines

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance
judge.  The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `b71d5feb` |
| pristine binary | md5 `bc09e77cf8fd251285c06f6f0b54a5bc`, built from this pass's OWN worktree at a clean `b71d5feb` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary | md5 `eb7b95960d659e302e9e8986470f1dcf`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` + `src/ModuleEmit.cpp` + `include/UhdmExporter.h` ONLY |
| probe surface | `tools/probe/r10earl113repro/` only |
| the head | **Earlgrey_0_1/testflags, 364 cmp lines, ONE head → 17 cmp lines, ONE head.**  The failing field was `expr::VpiSize` on the `hier_path` `tl_h_i[0].a_valid` (`tlul_socket_m1.sv:109`): `design::Compare` returned **−1** = `0 − 1`.  It now returns **+1**, the SINGULAR `Typespec` SafeCompare with `RHS: <null>` on the SAME object — earl112's R1, and this pass's arms reproduce it for the first time (§7). |
| Earlgrey_0_1/default | **31 lines, 1 head, cmp log BYTE-IDENTICAL** — r10earl107's pre-existing `u_pinmux.gen_mio_periph_in[0].data_mux` null, untouched |
| goldens | 23 PASS / 0 FAIL on the patched binary; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |
| corpus census | surelog, 956 databases × both modes, calibrated golden-vs-golden at **0 phantoms**: the law's family **SHAPE TO-GOLDEN 1 / AWAY 0 / MOVED-WRONG 0**, the REST family **TO-GOLDEN 0 / AWAY 0 / MOVED-WRONG 0**; uhdm2rtlil, 1358 databases: **all zero** |

---

## 1. THE JUDGE, DECODED FIRST — `own113`, the owner finder AND field bisector

RESUME.md §9's head-decode discipline: read the generated `Compare` ORDER
before naming a field.  For a `hier_path` that order is

```
hier_path::Compare
  -> expr::Compare
       -> BaseClass::Compare   VpiType, VpiName, VpiDefName
       -> VpiDecompile         (string compare)
       -> VpiSize              (int subtraction)      <-- THIS PASS
       -> Typespec             (SafeCompare, singular)
  -> Path_elems                (SafeCompare, vector)
  -> Root_value                (SafeCompare, singular)
  -> VpiName                   (string compare)
```

`own113.cpp` runs the OFFICIAL `design::Compare` (the same call `uhdm-cmp`
makes), prints EVERY field in that order with its own result, then READS the
parent chain, both `Path_elems` lists and — the question this pass had to
answer — **every sibling operand of the owning operation on both sides, with
its size**.  Full output in `OWNER_BEFORE.r10earl113.txt` /
`OWNER_AFTER.r10earl113.txt`, measured on THIS pass's own pristine build:

```
== ITERATION 0 : design::Compare -> -1
   HEAD LHS(golden) = hier_path id:793448  tlul_socket_m1.sv 109:19-109:36
        payload: name='tl_h_i[0].a_valid' size=0 ts=ref_typespec->array_typespec
   HEAD RHS(ours)   = hier_path id:1292812          109:19-109:36
        payload: name='tl_h_i[0].a_valid' size=1 ts=<null>
   -- FIELD BISECTION (generated Compare order) --
      BaseClass VpiType   : 5000 vs 5000 -> 0
      BaseClass VpiName   : 'tl_h_i[0].a_valid' vs 'tl_h_i[0].a_valid' -> 0
      BaseClass VpiDefName: '' vs '' -> 0
      expr VpiDecompile   : '' vs '' -> 0
      expr VpiSize        : 0 vs 1 -> -1                <-- THE FAILING FIELD
      expr Typespec       : ref_typespec[...] vs <null> <-- THE NEXT FIELD
      hier_path Path_elems: 2 vs 2      Root_value: array_var vs array_var
   -- OWNER CHAIN (both sides, identical) --
     operation optype=75 ops=10 ts=ref_typespec->struct_typespec @108:26-119:6
       cont_assign                @108:12-119:6
         gen_scope                @89:36-139:6
           gen_scope_array 'gen_host_fifo[0]'
             module_inst 'u_sm1_17' -> 'u_xbar_main' -> 'work@top_earlgrey'
   GOLDEN siblings (10 operands of optype 75, op size=0):
      [0] hier_path('tl_h_i[0].a_valid')[sz=0]   <-- THE HEAD
      [1..9] hier_path/ref_obj, EVERY ONE [sz=0]
   OURS   siblings (10 operands of optype 75, op size=0):
      [0] hier_path('tl_h_i[0].a_valid')[sz=1]   <-- THE HEAD
      [1..9] hier_path/ref_obj, EVERY ONE [sz=0]
```

Five facts the judge hands over, none inferred:

1. **The failing field is `VpiSize`, and the arithmetic proves it.**  −1 is
   `0 − 1`, an int subtraction; `VpiName`, `VpiDefName` and `VpiDecompile` all
   return 0 — earl112 CLOSED the name family and the judge descended exactly
   one field, as its R0 said it would.
2. **The NEXT field in line is `expr::Typespec`** — golden hangs a
   `ref_typespec → array_typespec`, we hang nothing.  That is earl112's R1,
   and it is what the head becomes after this pass (§7).
3. **It is ONE operand, not the list.**  Golden gives EVERY one of the ten
   operands `VpiSize` 0.  We give operand 0 the member width (1) and every
   other operand 0.  So ours differs from golden in exactly ONE cell of this
   operation, and it is the FIRST-operand stamp.
4. **The owner is `vpiAssignmentPatternOp` (optype 75) inside a `cont_assign`
   inside a `gen_scope`** — the carrier and the scope, read and not guessed.
5. **The operation itself carries a `struct_typespec` on both sides and
   `VpiSize` 0 on both sides**, so the pattern IS flattened in golden (its tags
   dropped) — which is the fact §2 explains and which decides the whole law.

### the source

```systemverilog
 89:  for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
 90:    tlul_pkg::tl_h2d_t hreq_fifo_i;            <- declared IN the gen block
108:    assign hreq_fifo_i = '{
109:      a_valid:    tl_h_i[i].a_valid,           <- THE HEAD (operand 0)
110:      a_opcode:   tl_h_i[i].a_opcode,
                       ... seven more ...
118:      d_ready:    tl_h_i[i].d_ready
119:    };
```

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

**Two different passes touch a continuous assign's pattern, and only one of
them sizes.**

**(a) The pass that SIZES — `UhdmWriter::writeCont_assign`
(`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:2090-2216`).**  It opens
with

```cpp
  const typespec* tps = nullptr;
  if (const ref_typespec* rt = lhs->Typespec()) tps = rt->Actual_typespec();
  ...
  if (lhs->UhdmType() == uhdmref_obj) {
    UHDM::any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
    if (var) { ...clone...; if (expr* exp = any_cast<expr*>(var))
                 if (const ref_typespec* rt = exp->Typespec())
                   if (const typespec* temp = rt->Actual_typespec()) tps = temp; }
  }
  if (tps) {                                        // <-- THE ARM THAT SIZES
    expr* tmp = eval.flattenPatternAssignments(s, tps, (expr*)rhs);
    ...
    if (opType == vpiAssignmentPatternOp || opType == vpiConditionOp)
      if (m_helper.substituteAssignedValue(rhs, m_compileDesign))
        rhs = m_helper.expandPatternAssignment(tps, (UHDM::expr*)rhs, mod, ...);
  } else if (rhs->UhdmType() == uhdmoperation) {    // <-- THE ARM THAT DOES NOT
    ... flattenPatternAssignments ONLY, off the OPERATION's own typespec ...
  }
```

`CompileHelper::expandPatternAssignment`'s untagged arm
(`CompileHelper.cpp:5237-5257`) is the committed
"a re-emitted OUTERMOST pattern sizes its FIRST operand" law:

```cpp
  for (any* op : *operands) {
    expr* cop = (expr*)op;
    expr* vexp = reduceExpr(cop, invalidValue, ...);
    uint64_t v = eval.get_uvalue(invalidValue, vexp);
    int32_t csize = adjustOpSize(tps, cop, opIndex, rhs, ...);   // WRITES VpiSize
    if (invalidValue) { return result; }                          // AFTER it
    ...
  }
```

— `adjustOpSize` (`CompileHelper.cpp:4944-5035`) writes `cop->VpiSize(ncsize)`
from the target typespec's member/element width, and the `invalidValue` bail
comes AFTER it, which is exactly why an UNREDUCIBLE first operand still gets a
size and the walk then stops.

**(b) The pass that FLATTENS a generate body — UHDM's own
`cont_assign::DeepClone` (`~/git-repos/UHDM/templates/clone_tree.cpp:803-816`),
the clone the unrolling makes per generate instance:**

```cpp
  if (ref_obj* ro = any_cast<ref_obj*>(lhs))
    if (struct_var* stv = ro->Actual_group<struct_var>())
      if (ref_typespec* rt = stv->Typespec())
        if (typespec* ts = rt->Actual_typespec()) {
          ExprEval eval(...);
          if (expr* res = eval.flattenPatternAssignments(*s, ts, rhs))
            if (res is operation) ((operation*)rhs)->Operands(res->Operands());
        }
```

**No `expandPatternAssignment`.  No `adjustOpSize`.**  The clone drops the
tags, gives the operation a `struct_typespec`, orders the operands by member —
and touches no operand's size, with ONE exception named in (c).

**(c) The ONE thing the flatten does resize.**  `ExprEval::flattenPatternAssignments`
(`~/git-repos/UHDM/templates/ExprEval.cpp:893-913`) re-encodes a tagged
constant whose `VpiSize()` is **−1** — an unsized `'1` / `'0` — to the FIELD
width, as a `UINT` with a decimal decompile.  Nothing else in that function
writes a size.

**(d) WHY THE TWO SCOPES DIFFER — `bindVariable`'s scope walk.**
`CompileHelper::bindVariable`'s `const UHDM::any* scope` overload
(`CompileStmt.cpp:3089-3148`) switches on `uhdmfunction`, `uhdmtask`,
`uhdmbegin` and `uhdmmodule_inst` and **has no `gen_scope` case**: a
`gen_scope` falls to the `default` and the function recurses to
`scope->VpiParent()`.  Therefore

* a target **declared in the generate block** is never found — `var` is null,
  `lhs->Typespec()` is null too, `tps` stays null, the `else if` arm runs, the
  pattern is flattened and **NOTHING is sized**;
* a target **declared in the module body** IS found from inside the generate
  block — `tps` is filled from the bound variable and
  `expandPatternAssignment` sizes operand 0 exactly as at module scope.

That second case is not hypothetical: it is uhdm2rtlil's
`gen_struct_access/dut.sv` and Surelog's `tests/FuncAlias/dut.sv`, and a first
cut of this law without the fence **converted both to `CMP_NOTEQUAL` in both
modes** (§6c).

---

## 3. THE GOLDEN GRID — four arms, both views, one axis at a time

`grid113.sh` builds them, `cen113` reads them, `score113.py` scores them three
ways (golden / pristine / patched); `GRID.r10earl113.txt` holds every row and
`CALIB.r10earl113.txt` the golden-vs-golden calibration (**209 cells, ALL
`SAME_AGREE`, 0 phantoms**).

**THE SHAPE THAT REPRODUCES THE HEAD, measured and not assumed.**  The clone
gate in §2(b) wants a `struct_var`.  A packed struct of pure `logic` members
driven by a continuous assign comes out a `struct_NET`, the gate refuses, and
golden keeps the `tagged_pattern` — which is why earl112's arms (and this
pass's first three attempts) never reproduced the corpus cell.  An **ENUM
member** makes Surelog model the object as a `struct_var`, and then the arm is
the corpus: this is the one-line difference between a probe that reproduces the
head and one that does not.

**Arm `s1_scope113` — THE SCOPE AXIS (ELAB view, operand 0 of the same keyed
pattern with the same dotted first value):**

| cell | scope | golden | ours, pristine | ours, patched |
|---|---|---|---|---|
| m1 | module body | **sz=1 (SIZED)** | sz=1 | sz=1 — **negative control, unmoved** |
| g1 | generate-for, depth 1 | **sz=0** | sz=1 | **sz=0** |
| g2 | generate-for, depth 2 | **sz=0** | sz=1 | **sz=0** |
| g3 | generate-if | **sz=0** | sz=1 | **sz=0** |
| g4 | generate-case | **sz=0** | sz=1 | **sz=0** |
| x1 | gen-local target of a PURE-LOGIC struct (`struct_net`) | golden never flattens — `tagged_pattern`, no first operand | sz=1 | sz=0 — **NOGOLD, §5** |
| x2 | pattern in a generate block, target in the MODULE BODY | **sz=1 (SIZED)** | sz=1 | sz=1 — **THE FENCE, unmoved** |
| x3 | module-scope ARRAY ELEMENT target (`bit_select` Lhs) | `tagged_pattern` | sz=1 | sz=1 — **unmoved** |

So the axis is the SCOPE **and the declaring scope of the target**, not the
depth: every generate flavour at every depth drops the size, and the module
body keeps it — including a module-body target written from inside a generate
block.

**Arm `s2_opkind113` — THE OPERAND-KIND AXIS at generate depth 1, beside its
module-scope twin:**

| operand 0 | golden, gen scope | ours pristine | ours patched | golden, module twin |
|---|---|---|---|---|
| `hier_path` | 0 | 1 | **0** | 1 (and ours 1) |
| `ref_obj` | 0 | 1 | **0** | 1 (and ours 1) |
| binary `operation` | 0 | 1 | **0** | 1 (and ours 1) |
| `bit_select` | 0 | 1 | **0** | 1 (and ours 1) |
| concatenation `operation` | 0 | 4 | **0** | 4 (and ours 4) |
| **sized constant `1'b1`** | **1** (the literal's own width) | 1 | 1 | 1 |
| **sized constant `4'h3` into an 8-bit member** | **4** (the literal's own width) | **8** | **4** | **8** (and ours 8) |
| **UNSIZED constant `'1` into an 8-bit member** | **8** (`flattenPatternAssignments`' own resize) | 8 | **8 — UNCHANGED** | 8 (and ours 8) |
| POSITIONAL `hier_path` | 0 | 0 | 0 | 1 (and ours 1) |
| POSITIONAL unsized `'1` | −1 | −1 | −1 | −1 |

The `4'h3`-into-8-bits cell is the DISCRIMINATOR that proves a constant is not
special-cased by kind: golden keeps the LITERAL's width where we wrote the
member width, and the suppress fixes it.  The `'1`-into-8-bits cell is the ONE
exception the law must carry: there golden's 8 IS the member width, written by
the flatten itself, and suppressing would move a right cell wrong.

**Arm `s3_carrier113` — THE CARRIER AXIS:** `cont_assign` splits by scope as
above; an `always_comb` and an `initial` keep the `tagged_pattern` in golden at
BOTH scopes and ours already matches; a variable initializer and a localparam
are a different producer.  **Only the gen-scope `cont_assign` cell moves.**

**Arm `s4_fence113` — THE MUST-STAY FLOOR, ELAB view:**

| cell | committed law | golden | ours, patched |
|---|---|---|---|
| f1 | module-scope packed-struct pattern (the first-operand sizing law's own module cell) | sz=1 | **sz=1, unmoved** |
| f2 | TYPEDEF'd unpacked-array target | sz=12 | **sz=12, unmoved** |
| f3 | § `inlineUnpackedArrayPatternNoFirstSize91` | sz=0 | **sz=0, unmoved** |
| f4 | § `elabPatternFirstRowElemSize45` nested table | unchanged | **unmoved** |
| f5 | the Kmac 1-D expression array | unchanged | **unmoved** |
| f6 | § `patCaGenIdxValueRender112`'s gen-scope pattern | the law's own cell | **sz 1 → 0** |
| f7 | § `hpSelHalfOpParamFold110`'s plain gen-scope select half | genvar SPELLED | **unmoved** |

**THE THREE-WAY SCORE over all four arms, both views** (`GRID.r10earl113.txt`):

```
-- TOTAL  TOGOLD=13  AWAY=0  MOVEDWRONG=0  SAME_AGREE=146  STILLWRONG=5
          NOGOLD=15  NOGOLD_UNMOVED=33  ONESIDED=45
```

and the NULL RUN (the pristine binary on BOTH sides, same instrument) scores
`TOGOLD=0 AWAY=0 MOVEDWRONG=0 NOGOLD=0 STILLWRONG=18` — the 13 wins are
exactly 13 of those 18, and the other 5 are named residues (§7).

---

## 4. THE LAW

> **§ `genScopeCaPatNoFirstSize113`.**  In an ELABORATED **generate-scope
> continuous assign whose TARGET is declared in that generate scope** (or in a
> generate block enclosing it), a re-emitted assignment pattern's FIRST operand
> **keeps its own size**: the emitter does not stamp the member width, because
> the only pass that touched the pattern there is the unrolling clone's
> `flattenPatternAssignments`, which sizes nothing.
>
> **THE ONE EXCEPTION is an UNSIZED CONSTANT** (`VpiSize() == -1`), which that
> same flatten re-encodes to the FIELD width — the same number the stamp
> writes — so it keeps the stamp.

### STATED GATE == CODE GATE

**STATED:** the pattern is emitted inside an elaborated gen-scope continuous
assign; the assign's target is a plain named reference declared in that
generate scope or in a generate block enclosing it; the operand is the FIRST
one of a non-nested pattern; and it is not an unsized constant.

**CODE:** `inGenScopeCa67 && genCaLhsGenLocal113 && !(e is uhdmconstant &&
e->VpiSize() == -1)` suppresses the existing `operands->empty() && !nestedPat`
stamp, where `genCaLhsGenLocal113` is set for the duration of one gen-scope
`cont_assign` emission by the scope walk in `ModuleEmit.cpp`.  There is no
condition in the code that is absent from the prose and none in the prose that
is absent from the code.

### the fences, each of them a measured cell

| fence | what it keeps out | the cell that measures it |
|---|---|---|
| (a) `inGenScopeCa67` | the DEF listing, every procedural block, every module-scope statement | s1 m1 (module scope, golden SIZES), s3's `always_comb` / `initial` rows (golden keeps the tags at both scopes and ours already matches) |
| (b) `genCaLhsGenLocal113` | a pattern written INSIDE a generate block onto a MODULE-BODY target, which `bindVariable` finds and `expandPatternAssignment` therefore sizes | s1 x2 — and, in the corpus, uhdm2rtlil `gen_struct_access` + Surelog `FuncAlias` + `GenStructAccess`, which the un-fenced first cut CONVERTED (§6c) |
| (c) the NamedValue test inside (b) | a `bit_select` / member-select target, for which `writeCont_assign`'s `lhs->UhdmType() == uhdmref_obj` arm never runs at all | s1 x3, and Earlgrey's own 29 `bit_select`-Lhs gen cells, all byte-identical across the patch |
| (d) the unsized-constant test | `'1` / `'0`, which `flattenPatternAssignments` itself resizes to the field width | s2 n2 (`'{w0: '1, …}` into an 8-bit member: golden 8, ours 8 before and after) |
| (e) `operands->empty() && !nestedPat` (pre-existing) | every operand but the first, and every nested pattern | the head's own nine siblings, all `VpiSize` 0 on both sides before and after |
| (f) the KIND-BEFORE-IDENTITY order in (b)'s walk | a module-body target reached on the walk's SECOND step, because a standalone `if` generate block's parent scope IS the module body | s1 x2 measured wrong with the identity test first, right with the kind test first — the bug was found by the arm, not by review |

### the hypotheses this pass REFUTED, each on an arm cell or on the judge

| candidate | refuted by |
|---|---|
| "the axis is the generate DEPTH" | s1 g1/g2 — depth 1 and depth 2 behave identically; s1 g3/g4 — a gen-if and a gen-case with no loop at all behave the same |
| "the axis is `gen_scope` versus `module_inst`" | s1 x2 — a pattern INSIDE a generate block whose target is a module-body variable is SIZED by golden |
| "a constant operand is special-cased by kind" | s2 n1 — `4'h3` into an 8-bit member is size 4 in golden (the literal's own width), and the suppress fixes it |
| "no constant needs the stamp" | s2 n2 — an UNSIZED `'1` into an 8-bit member IS size 8 in golden, written by the flatten |
| "the positional (untagged) site needs the same suppress" | s2 p1 — a positional gen-scope pattern's first operand is already `VpiSize` 0 on both sides; the `elements()` stamp is not reached there and the pass leaves it alone |
| "an all-`logic` packed struct reproduces the corpus cell" | §3 — it comes out a `struct_net`, the clone's `Actual_group<struct_var>` gate refuses, and golden never flattens |
| "fixing the size clears the head" | §1 fact 2 and §7 — the same object's `Typespec` is next, and that is what the head becomes |

---

## 5. THE CORPUS CENSUS — 2314 databases, both corpora × both modes

`cen113` over every database of both sweeps (`censweep113.sh`, `ACCOUNTING
PASS` on each: surelog LISTED 1573 / PROCESSED 956 / SKIPPED 617 / CENFAIL 0;
uhdm2rtlil LISTED 1462 / PROCESSED 1358 / SKIPPED 104 / CENFAIL 0), split by
`sweepsplit113.sh` — which **asserts the two sweeps' GOLDEN halves are
byte-identical** before anything is scored (it does; both corpora) — and joined
as a MULTISET by `cen113.py`.  Three families are printed:

* **PX** — the law's surface, keyed on span + scope + generate depth + carrier
  + the Lhs/clone gate + the operand KIND, payload = the compare-visible `expr`
  fields of operand 0.  The kind is in the KEY because one span legitimately
  holds several operand-0 objects at once (golden's arena keeps the flattened
  operation AND the un-flattened `tagged_pattern` side by side).
* **P0** — the same operand keyed on the SPAN ALONE with the kind in the
  payload: the coarse view, kept so nothing can hide in the re-keying.
* **PR** — THE REST, compare-visible: the operation's own `VpiSize` and
  typespec edge, its operand COUNT, and every operand from index 1 up.

| corpus | family | keys joined | SHAPE TO-GOLDEN | AWAY | MOVED-WRONG | ONE-SIDED-CHANGED |
|---|---|---|---|---|---|---|
| surelog | **PX** (the law) | 1154 | **1** | **0** | **0** | 1 |
| surelog | **P0** | 572 | 1 | **0** | 1 (see below) | 0 |
| surelog | **PR** (the rest) | 572 | 0 | **0** | **0** | 0 |
| uhdm2rtlil | **PX** | 642 | 0 | **0** | **0** | 0 |
| uhdm2rtlil | **P0** | 512 | 0 | **0** | **0** | 0 |
| uhdm2rtlil | **PR** | 512 | 0 | **0** | **0** | 0 |

* **AWAY 0 and MOVED-WRONG 0 in the PX and PR families of both corpora.**  The
  **PR** row is the proof that the law moved its own field and nothing else:
  every other compare-visible field of every pattern operation in both corpora
  is exactly what the pristine binary produced.
* **The ONE PX SHAPE-TO-GOLDEN cell** is `testflags/Earlgrey_0_1 |
  108:26-119:6 | sc=gen_scope | gd=1 | car=cont_assign |
  lhs=ref_obj/act=struct_var/decl=gen_scope | k=hier_path`, moving
  `sz=1 → sz=0` onto golden's `sz=0`.  Its STRICT (multiset) score is
  MOVED-WRONG because our elaborated tree holds 116 copies of that payload
  where golden holds 58 — earl112's R6 arena-count residue, pre-existing on
  both binaries and invisible to every generated `Compare` (no `Compare`
  counts arena copies).  Both scores are printed; the SHAPE line is the judged
  one, on earl111/earl112's precedent.
* **The ONE PX ONE-SIDED-CHANGED cell** is the same coordinate in
  `default/Earlgrey_0_1`, where golden does NOT flatten the pattern at all
  (its operand 0 is a `tagged_pattern`) and ours is a `hier_path` whose size
  goes 1 → 0.  Golden has no operand of our kind there, so the move is neither
  toward nor away: it is named, counted, and reported as NOGOLD rather than
  folded into either column (earl45's lesson).  The P0 family, whose key does
  not separate kinds, scores that same cell SHAPE-MOVED-WRONG — the coarse
  view of the identical fact, printed so the re-keying hides nothing.
* uhdm2rtlil: **not one cell of any family moved**, matching byteverify's
  MOVERS 0 / 1358.

### THE PREDICTION, made from the PRISTINE databases FIRST

`predict113.py` reads only the PRISTINE sweep census (our pristine databases
and the goldens; it never sees a patched database) and applies the code's own
gate.  `PREDICT_sl.txt`:

```
--- GATE-MATCHING cells: 2 ---
--- PREDICTED MOVE cells: 1 ---
MOVE  testflags/Earlgrey_0_1-71da2fd7  PX|108:26-119:6|...|k=hier_path
        from ["sz=1,…"]   to   ["sz=0,…"]
--- NOGOLD cells: 1 ---
NOGOLD default/Earlgrey_0_1-71da2fd7  PX|108:26-119:6|...|k=hier_path
ROWS PREDICTED TO MOVE (2):
  default/Earlgrey_0_1-71da2fd7
  testflags/Earlgrey_0_1-71da2fd7
```

`PREDICT_u2r.txt`: **0 gate-matching cells, 0 rows** over 1358 databases.

**The predicted cell set, the predicted new VALUES and the predicted ROW set
are exactly what the patched census and `byteverify.sh` measured** — one moving
cell with `sz=0` as its new payload, one NOGOLD cell, two Earlgrey rows, and no
third row from the law.

---

## 6. THE GATES — ALL GREEN

Both binaries were built from THIS pass's own worktree at a clean `b71d5feb`
and frozen `chmod 555` BEFORE any sweep; every `cmds.txt` in all four workdirs
was audited BY BINARY PATH — `/tmp/r10earl113_bin/pristine` in the two control
workdirs (1523 + 1458 files) and `/tmp/r10earl113_bin/patched` in the two
patched ones (1523 + 1458), one distinct path per workdir and no other.

| gate | result |
|---|---|
| (1) build both, md5s | pristine `bc09e77cf8fd251285c06f6f0b54a5bc` (byte-identical to the main tree's `build/slang-uhdm`), patched `eb7b95960d659e302e9e8986470f1dcf` |
| (2) goldens | **23 PASS / 0 FAIL** on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** (the negative control) |
| (3) uhdm2rtlil, testflags AND default | **CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2** on both binaries, identical histograms; **0 changed rows** (status AND dump column) in both modes; `ct8rows` **PASS** against the committed baseline AND against this pass's own pristine control, in BOTH modes |
| (4) surelog, `--mode both`, 1588 rows | identical status histograms on both binaries (CMP_EQUAL 937, CMP_NOTEQUAL 19, SLANG_REJECT 567, SURELOG_FAIL 48, DEFERRED 10, NO_DATABASE 3, NO_UHDM 1, UNTRANSLATABLE 2, TIMEOUT 1); **0 changed rows**; `ct8rows` **PASS** against the committed baseline AND against the pristine control.  **NO ROW CONVERTED**, in either direction |
| (5) `byteverify.sh SELFCHECK=1` | uhdm2rtlil **MOVERS 0 / 1358**; surelog **MOVERS 3 / 956** — the two PREDICTED Earlgrey rows plus `Scoreboard/default`, RESUME.md §9's documented coin, attributed as such in §6a.  SELFCHECK flagged 1357/1358 and 955/956, so the comparator can see |
| rowheads | **Earlgrey_0_1 testflags 364 → 17, ONE head**; every other row unchanged and its cmp log BYTE-IDENTICAL: SeqDriver 29/29, SimpleUVM at the depth artifact, Scoreboard/default 95, MiniAmiq 29/29, BuildUVMPkg 52/52, Earlgrey_0_1 default 31, Rggen/default 0 |
| canaries | `canaries.sh` surelog **ok=52 changed=0**, uhdm2rtlil **ok=8 changed=0**; `ctcan2.sh` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs, by name | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a`/`73a10e8217e5`, `YosysOldOr` `d68e0796d62c` — all SAME as pristine in both modes; `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a**, both pins met (12 pins, all SAME) |
| the four slang-fenced tests | never dispatched; no probe file in this directory spells any of the four outside `canaudit.sh`'s own `FENCED=` line |

### 6a. THE THREE BYTE MOVERS, ATTRIBUTED

* **`Scoreboard/default` — RAW 98 lines, ORDER-BLIND 0 content lines.**  A pure
  ordering flip: RESUME.md §9's `svunit_pkg vpiTaskFunc` list-order coin
  ("~92 dump lines"), which flips per invocation on an unchanged binary.  (The
  sorted diff shows 4 lines, all of them the dump's own header naming the two
  workdir paths; excluding that header the order-blind diff is **0 lines**.)
  Not this law — `predict113.py` names 0 cells there, and the census scores
  every one of its keys `SAME_AGREE` or unchanged-`STILLWRONG`.
* **`Earlgrey_0_1/default` and `Earlgrey_0_1/testflags`** — the two rows the
  prediction named.  Attributed THREE independent ways:
  0. the SECTIONED, path-normalised, ORDER-BLIND whole-dump diff
     (`ATTRIB_Earlgrey.txt`).  In TESTFLAGS: RAW 120 lines, ORDER-BLIND 64, of
     which the only content shape is **`|vpiSize:N` REMOVED, 58 times, all in
     ONE ELAB section**.  In DEFAULT: RAW 62, ORDER-BLIND 34, the only content
     shape **`|vpiSize:N` REMOVED, 29 times, all in ONE ELAB section**.
     **Zero additions, no other shape, in either mode, with the DEF section and
     the weaklyReferenced TAIL untouched** (the remaining 1+1 lines per mode
     are the dump's own header naming the two workdir paths).  `uhdm-dump`
     omits `vpiSize` when it is 0, so a suppress reads as a removal; 29 is one
     per unrolled `gen_host_fifo` instance and 58 is the same objects under
     testflags' 2× arena multiplicity (R5), which is exactly the split the
     census reports (58 arena objects in default, 116 in testflags).
  1. **`kinds113`, the WHOLE-DATABASE census over `Serializer::AllObjects`**
     (every object, reachable or not, by kind AND by kind+name — the
     instrument for a database whose dump is too large to diff): the two files
     are **IDENTICAL, 0 diff lines**, for BOTH modes.  Not one object was
     added, removed or renamed anywhere in the database; the byte difference is
     a FIELD VALUE change and nothing else, which is exactly what a suppress
     is.
  2. the census itself (§5): the only compare-visible field that changed in
     either database is operand 0's `VpiSize` at `tlul_socket_m1.sv:108-119`,
     `1 → 0`, on 58 objects per mode, with the `PR` family — every other
     compare-visible field of every pattern operation — at TO-GOLDEN 0 /
     AWAY 0 / MOVED-WRONG 0.

### 6b. THE WIDE BOUNDARY

`widerun113.sh` stages a COPY of the whole committed `tools/probe` tree (this
pass's own directory excluded, so it can be scored separately as the positive
control), lists every `.sv`/`.v` at ANY depth, filters the four fenced names
out of the list BEFORE a single child runs, and compares the
workdir-normalised `uhdm-dump` of both frozen binaries in BOTH views.

```
LISTED=5017  FENCED_REMOVED=0  (of 5017 found)
PROCESSED=5017  identical=9630  DIFFERING=22  no_output=382
rc by side:  A/0 9263  A/3 366  A/4 389  A/139 16
             B/0 9263  B/3 366  B/4 389  B/139 16   <- perfectly SYMMETRIC
differing: plain+elab of r10earl112repro's g1_head112 g2_carrier112
                        g3_depth112 g4_fence112, and of r10vearl112repro's
                        v1_call112 v2_hier112 v3_inst112 v4_one112
                        v5_floor112 v7_iface112 v8_repl112
```

`PROCESSED == LISTED`, and the rc histogram is identical side for side — no arm
rejects on one binary and not the other, and the 16 `rc=139` segfaults are the
same 16 on both sides.

**The 22 differing cells are eleven earl112 / r10vearl112 arm files in both
views, and EVERY ONE was rebuilt against its own real golden and re-scored**
(`grid113.sh` over those arms; `BOUNDARY_earl112arms.txt` and
`BOUNDARY_v112arms.txt`):

```
earl112's four arms   -- TOTAL  TOGOLD=0  AWAY=0  MOVEDWRONG=0  SAME_AGREE=59
                                NOGOLD=27  NOGOLD_UNMOVED=7  ONESIDED=44
the verifier's eight  -- TOTAL  TOGOLD=0  AWAY=0  MOVEDWRONG=0  SAME_AGREE=60
                                NOGOLD=29  NOGOLD_UNMOVED=19  ONESIDED=71
```

* **AWAY 0 and MOVED-WRONG 0 on both sets**: not one earl112 or verifier cell
  moved away from golden.
* Every moved cell is **NOGOLD** — those arms declare their pattern targets
  with pure-`logic` packed structs, which Surelog models as `struct_net`, so
  the clone gate of §2(b) refuses and golden emits no first operand there at
  all.  The direction of the move is the law's own direction (golden sizes
  NOTHING in a gen-scope continuous assign, in every cell of every arm and of
  the corpus).
* **The official judge sees no change on any of the twelve arms**: `uhdm-cmp`
  reports **30 lines / 1 head on eleven of them and 32 / 1 on `v7_iface112`,
  in both views, pristine and patched alike**, so earl112's law, its
  user-call-argument fence and earl110's arms are intact by the only authority
  that counts.

**THE POSITIVE CONTROL** (RESUME.md §9: "a positive control — a deliberately
moved cell — proves the gate can see") is this pass's own four arms, which the
same instrument reports as differing in both views.

### 6c. THE REGRESSION THE CORPUS CAUGHT, AND THE FENCE IT BOUGHT

The first cut of this law gated on `inGenScopeCa67` alone.  It cleared the head
and passed the arms — and the **corpus sweeps converted four rows**, quoted
here because a pass that hides its own refutation is worthless:

```
CHANGED ('GenStructAccess', 'default')   CMP_EQUAL -> CMP_NOTEQUAL
CHANGED ('GenStructAccess', 'testflags') CMP_EQUAL -> CMP_NOTEQUAL
CHANGED ('FuncAlias',       'default')   CMP_EQUAL -> CMP_NOTEQUAL
CHANGED ('FuncAlias',       'testflags') CMP_EQUAL -> CMP_NOTEQUAL
```

plus `gen_struct_access` in both uhdm2rtlil modes.  All of them are the same
shape — `td2 inst1;` in the MODULE BODY, `assign inst1 = '{…}` inside
`if(1) begin : GEN1` — and golden sizes their first operand 64, because
`bindVariable` finds a module-body target from inside a generate block (§2d).
`genCaLhsGenLocal113` is the fence that decode bought; its first implementation
compared scope identity before scope kind and still lost the cell (fence (f)),
and arm `s1 x2` is the cell that caught that too.

---

## 7. RESIDUES, and R0

* **R0 — `expr::Typespec` ON THE SAME OBJECT, and this pass's arms reproduce
  it.**  `design::Compare` returned **−1** before this pass and returns **+1**
  after it: the SINGULAR `Typespec` SafeCompare with `RHS: <null>`.  Golden
  hangs a `ref_typespec → array_typespec` (the ROOT array's own) on the
  pattern-carried `hier_path`; we hang nothing.  This is earl112's R1, which
  its README recorded as **"not reproduced by any arm here"** — arm
  `s1_scope113`'s elaborated view now produces exactly that head, byte for byte
  (`ref_typespec (…gen_d1[0].tl_h_i[0].a_valid) → array_typespec`, RHS
  `<null>`), because the enum-bearing struct of §3 gives the arm an `array_var`
  root instead of the `array_net` earl112's arms came out with.  **This is the
  next pass, and it starts from a 100-line arm instead of a 30-minute corpus
  build.**
* **R1 — `Path_elems[1].Actual_group`.**  Golden's trailing `ref_obj a_valid`
  is UNBOUND; ours binds it to the `typespec_member`.  Golden's FIRST element
  IS bound (`Actual_group → array_var`), so it is a per-position rule and needs
  its own grid.  It is the field after R0 on the same object (earl112's R2).
* **R2 — the DEFAULT-mode flatten.**  In `default` mode golden does NOT flatten
  the corpus pattern at all (operand 0 is a `tagged_pattern`, 30 of them) while
  we flatten in both modes.  That is a pre-existing divergence on both
  binaries; this law only moves the size of the object we already emit there.
  Whatever decides the flatten between the two golden runs is unread.
* **R3 — the `struct_net` half of the clone gate.**  UHDM's
  `cont_assign::DeepClone` flattens only when the target is a `struct_var`; a
  pure-`logic` packed struct is a `struct_net` and golden keeps the
  `tagged_pattern`.  We flatten either way.  **Corpus population: 29 cells in
  Earlgrey (the `bit_select`-Lhs ones), all left on their pristine bytes by
  fence (c); the arm cells are s1 x1 and earl112's four arms.**
* **R4 — the unsized constant's VALUE and DECOMPILE in a generate scope.**
  Golden's flatten re-encodes `'1` into an 8-bit member as
  `UINT:255` / `'255'` / `vpiUIntConst`; ours keeps `BIN:1` / `''1'` /
  `vpiBinaryConst` at the right SIZE.  At MODULE scope we already produce
  golden's form.  Measured on arm `s2` n2, both views.  **Corpus population:
  zero.**
* **R5 — the arena COUNT residue.**  In TESTFLAGS our elaborated tree holds 116
  copies of the head operand at one span where golden holds 58 (identical
  payload SETS).  Invisible to the judge and pre-existing on both binaries
  (earl112's R6); reported so the STRICT and SHAPE scores can be read against
  each other rather than one being quietly chosen.
* **R6 — the POSITIONAL site.**  A positional (untagged) gen-scope pattern's
  first operand is already `VpiSize` 0 on both sides, so the `elements()` stamp
  at `ExprEmit.cpp:29647` is not reached there and this pass deliberately does
  not touch it.  Why it is not reached was not decoded; if a future shape ever
  reaches it, the same law applies and the same fences with it.
* **R7 — earl110's and earl112's laws are untouched** by the only authority
  that counts: all four earl112 arms report 30 cmp lines / 1 head on both
  binaries in both views (§6b).

---

## 8. FILES

| file | what it is |
|---|---|
| `own113.cpp` | the owner finder AND field bisector: runs the OFFICIAL `design::Compare`, prints every field in the generated order with its own result, the parent chain, both `Path_elems` lists and EVERY SIBLING OPERAND with its size, then masks and re-runs to read the next field |
| `cen113.cpp` | the census: every assignment-pattern operation's FIRST operand, in THREE families — `PX` (the law's surface, keyed on the scope × carrier × clone-gate × kind matrix), `P0` (the same keyed on the span alone) and `PR` (the rest, compare-visible) |
| `cen113.py` | the MULTISET join and scorer (earl112's, unchanged): STRICT and SHAPE, `TOGOLD` / `AWAY` / `MOVEDWRONG` / `STILLWRONG` / `ONE-SIDED-CHANGED` |
| `score113.py`, `px113.py` | the per-arm three-way scorer and the human-readable grid printer |
| `grid113.sh`, `TOPS.txt` | the grid driver and its `-top` table |
| `calib113.sh`, `CALIB.r10earl113.txt` | golden-vs-golden calibration, 209 cells, 0 phantoms |
| `s1_scope113.sv` | THE SCOPE AXIS: module / gen-for depth 1 / depth 2 / gen-if / gen-case, plus the clone-gate control (x1), THE FENCE's own cell (x2) and the `bit_select`-Lhs cell (x3) |
| `s2_opkind113.sv` | THE OPERAND-KIND AXIS, with the constant DISCRIMINATOR (a 4-bit literal and an unsized `'1` into an 8-bit first member) |
| `s3_carrier113.sv` | THE CARRIER AXIS: cont_assign / always_comb / initial / var initializer / localparam × module and generate depth 1 |
| `s4_fence113.sv` | THE MUST-STAY FLOOR — earl45's, earl91's, earl110's and earl112's committed shapes |
| `censweep113.sh`, `sweepsplit113.sh`, `predict113.py` | the corpus census sweep, the two-sweep splitter (which ASSERTS the two sweeps' golden halves identical), and the BY-NAME mover prediction from PRISTINE databases |
| `attrib113.sh`, `secattr113.py` | the sectioned, path-normalised, ORDER-BLIND whole-dump mover attribution (the weaklyReferenced TAIL is never counted) |
| `kinds113.cpp` | the WHOLE-DATABASE kind/name census over `Serializer::AllObjects` — the attribution instrument for a database whose dump is too large to diff, and the one that cannot miss a change outside the shapes a dump diff happened to show |
| `wide113.sh`, `widerun113.sh` | the wide boundary over every `.sv`/`.v` in `tools/probe` at any depth, both views, both binaries, workdir-normalised dump compare |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the landing gates (copied verbatim from their owning pass dirs) |
| `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp` | the official `uhdm-cmp` output on the head row, both modes, both binaries |
| `OWNER_BEFORE.r10earl113.txt` / `OWNER_AFTER.r10earl113.txt` | `own113` on the pristine and on the patched databases |
| `GRID.r10earl113.txt`, `BOUNDARY_earl112arms.txt`, `BOUNDARY_v112arms.txt` | the arm grid's three-way score and the re-measurement of every earl112 / r10vearl112 arm the wide boundary flagged |
| `BOUNDARY_WIDE.tally`, `BOUNDARY_WIDE.rc_by_side`, `BOUNDARY_WIDE.diff` | the wide boundary's own counts, its per-side rc histogram and its differing list |
| `ATTRIB_Scoreboard.txt`, `ATTRIB_Earlgrey.txt` | the order-blind mover attribution of the coin and of the two predicted rows |
| `CENSUS_sl.{P0,PR,PX}.txt`, `PREDICT_sl.txt`, `PREDICT_u2r.txt` | the corpus census scores and the frozen prediction |

**Build the two C++ instruments with**

```
g++ -O2 -std=c++17 <tool>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <tool>
```
