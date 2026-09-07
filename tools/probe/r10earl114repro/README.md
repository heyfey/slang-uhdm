# r10earl114 — § `patHierPathRootTs114` — **A PATTERN-CARRIED `hier_path` HANGS THE ROOT OBJECT'S OWN TYPESPEC, BECAUSE THE ROOT VALUE AND THE TYPESPEC EDGE ARE ONE BINDING OFF ONE OBJECT** — the Earlgrey_0_1 testflags typespec head CLEARED, the object's next field named

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
| BASE | `362dcfa0` |
| pristine binary | md5 `8b1777950b91feef705565e6f16e8b0a`, built from this pass's OWN worktree at a clean `362dcfa0` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary | md5 `fff26ad19801bf4bbf445db25df03f44`, frozen `chmod 555` |
| production surface | `src/ModuleEmit.cpp` ONLY (one `if`, one fence loop, and the decode as comment) |
| probe surface | `tools/probe/r10earl114repro/` only |
| the head | **Earlgrey_0_1/testflags, 17 cmp lines, ONE head → 37 cmp lines, ONE head.**  The failing field was `expr::Typespec` on the `hier_path` `tl_h_i[0].a_valid` (`tlul_socket_m1.sv:109`): `design::Compare` returned **+1**, the SINGULAR `Typespec` SafeCompare with `RHS: <null>`.  It now returns **−1** on the SAME object's NEXT field, `Path_elems[1].Actual_group` (`LHS: <null>` vs our `typespec_member`).  **THE LINE COUNT IS THE HEAD OBJECT'S DECOMPILE SIZE, NOT A DISTANCE** — the judge descended one field and the new head object (a `typespec_member` with its `struct_typespec` owner and its own `ref_typespec`) simply decompiles larger than a bare `ref_typespec`.  §1 and §7 read that ladder off the databases rather than asserting it. |
| Earlgrey_0_1/default | **31 lines, 1 head, cmp log BYTE-IDENTICAL** — r10earl107's pre-existing `u_pinmux.gen_mio_periph_in[0].data_mux` null, untouched |
| goldens | 23 PASS / 0 FAIL on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |
| arm grid | 4 arms × 2 views × **3 census families**, calibrated golden-vs-golden at **1060 cells, ALL `SAME_AGREE`, 0 phantoms**: **AWAY 0 and MOVED-WRONG 0 IN EVERY FAMILY**, `PX` TO-GOLDEN 122, `P0` TO-GOLDEN 128, and the REST family `PR` TO-GOLDEN 0 / AWAY 0 / MOVED-WRONG 0 — the law moved its own field and nothing else |
| corpus census | 2314 databases, both corpora × both modes, golden halves asserted identical: surelog **PX SHAPE 68 / 0 / 0**, **P0 SHAPE 68 / 0 / 0 with STILLWRONG 0**, **PR 0 / 0 / 0**; uhdm2rtlil **every family all zero** |

---

## 1. THE JUDGE, DECODED FIRST — `own114`, the owner finder, field bisector, IDENTITY and SHARER finder

RESUME.md §9's head-decode discipline: read the generated `Compare` ORDER
before naming a field.  For a `hier_path` that order is

```
hier_path::Compare
  -> expr::Compare
       -> BaseClass::Compare   VpiType, VpiName, VpiDefName     (earl112 closed)
       -> VpiDecompile         (string compare)
       -> VpiSize              (int subtraction)                (earl113 closed)
       -> Typespec             (SafeCompare, singular)          <-- THIS PASS
  -> Path_elems                (SafeCompare, vector)            <-- R0
  -> Root_value                (SafeCompare, singular)
  -> VpiName                   (string compare)
```

and `ref_typespec::Compare` itself (UHDM generated `ref_typespec.cpp`) reads
**`VpiName`, `VpiDefName` and `Actual_typespec` — and NOT `VpiFullName`**.

`own114.cpp` runs the OFFICIAL `design::Compare` (the same call `uhdm-cmp`
makes) and then answers this pass's three questions off the databases.  Full
output in `OWNER_BEFORE.r10earl114.txt` / `OWNER_AFTER.r10earl114.txt`,
measured on THIS pass's own pristine build of the CORPUS row:

```
== ITERATION 0 : design::Compare -> 1
   HEAD LHS(golden) = ref_typespec id:793449
   HEAD RHS(ours)   = <null>
   RHS IS NULL -- the SINGULAR SafeCompare named the VALUE.  Climbing to the OWNER.
   OWNER(golden) = hier_path 'tl_h_i[0].a_valid' size=0
        ts=ref_typespec(id:793449,name='',dn='',
            full='work@top_earlgrey.u_xbar_main.u_sm1_17.gen_host_fifo[0].tl_h_i[0].a_valid')
            ->array_typespec(id:793266,name='')          @tlul_socket_m1.sv 109:19-109:36
   OWNER(ours)   = hier_path 'tl_h_i[0].a_valid' size=0  ts=<null>
   -- FIELD BISECTION (generated Compare order) --
      BaseClass VpiType/VpiName/VpiDefName : 0 / 0 / 0
      expr VpiDecompile                    : 0
      expr VpiSize                         : 0 vs 0 -> 0        <- earl113's field, CLOSED
      expr Typespec  : ref_typespec(...)->array_typespec  vs <null>   <-- THE FAILING FIELD
      hier_path Path_elems: 2 vs 2
      hier_path Root_value: array_var('tl_h_i') on BOTH sides
   GOLDEN IDENTITY:
     SAME ref_typespec OBJECT as the Root_value's   : no
     SAME Actual_typespec OBJECT as the Root_value's: YES
   GOLDEN SHARERS of array_typespec id:793266: 28 ref_typespec objects
        owner array_var    x1
        owner hier_path    x27
   -- OWNER CHAIN (both sides, identical) --
     operation optype=75 ops=10 ts=ref_typespec->struct_typespec(tlul_pkg::tl_h2d_t)
       cont_assign  ->  gen_scope  ->  gen_scope_array 'gen_host_fifo[0]'
         ->  module_inst 'u_sm1_17' -> 'u_xbar_main' -> 'work@top_earlgrey'
   GOLDEN siblings (10 operands of optype 75):
      [0..3,5..9] NINE hier_paths, EVERY ONE hanging array_typespec id:793266
      [4] ref_obj('shifted_id')  ts=<null>          <- not a hier_path, not hung
   OURS   siblings: the same ten, every hier_path ts=<null>
```

Six facts the judge hands over, none inferred:

1. **The failing field is `expr::Typespec`, and the arithmetic proves it.**
   `+1` is the SINGULAR `SafeCompare` with `rhs == nullptr`, which names the
   VALUE (golden's `ref_typespec`) and leaves RHS unset — RESUME.md §9's own
   rule, and why the tool CLIMBS to the owner instead of reporting a bare
   `ref_typespec` as "the head object".  `VpiSize` now returns 0 on both
   sides: earl113 closed it and the judge descended exactly one field.
2. **THE TARGET'S IDENTITY: the `ref_typespec` is MINTED PER PATH and the
   `Actual_typespec` is the ROOT's own object, SHARED.**  Golden's path
   ref_typespec is a *different object* from the root `array_var`'s
   (`SAME ref_typespec OBJECT: no`) while its `Actual_typespec` is the
   *identical* `array_typespec` (`SAME Actual_typespec OBJECT: YES`).
3. **ITS SHARERS: 28 `ref_typespec` objects point at that one
   `array_typespec` — 1 owned by the `array_var` and 27 by `hier_path`s.**
   So golden mints one nameless `ref_typespec` per path and never copies the
   typespec itself.
4. **The typespec golden hangs is the ROOT ARRAY'S, not the LEAF MEMBER'S.**
   The path's leaf `a_valid` is a one-bit `logic`; the hung typespec is the
   `array_typespec` of `tl_h_i`.  Arm t3 measures that across seven leaf
   kinds (§3).
5. **It is the whole hier_path operand list, not one cell.**  All NINE
   `hier_path` operands of the pattern hang the SAME `array_typespec`; the
   tenth operand is a `ref_obj` and is bare on both sides.
6. **THE NEXT FIELD, READ AND NOT PREDICTED.**  `own114` masks the owner's
   `Typespec` in memory and re-runs the official `design::Compare`: it returns
   **−1** with `LHS: <null>` against our `typespec_member('a_valid')` — the
   `Path_elems[1].Actual_group` edge, earl113's R1.  That is the head this
   pass hands forward, and it is what the patched database's head measurably
   IS (§6).

### the source

```systemverilog
 89:  for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
 90:    tlul_pkg::tl_h2d_t hreq_fifo_i;            <- declared IN the gen block
108:    assign hreq_fifo_i = '{
109:      a_valid:    tl_h_i[i].a_valid,           <- THE HEAD (operand 0)
                       ... nine more ...
119:    };
```

`tl_h_i` is the module's own `input tl_h2d_t tl_h_i [N]` — an unpacked array
PORT whose netlist object is an `array_var` carrying an `array_typespec`.

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

**The Root_value and the typespec edge are written by ONE `if`, off ONE
object.**  `CompileHelper::compileSelectExpression`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:5455-5496`):

```cpp
  UHDM::hier_path *path = s.MakeHier_path();
  VectorOfany *elems = s.MakeAnyVec();
  if (instance && (reduce == Reduce::Yes)) {                    // <-- THE GATE
    UHDM::any *rootValue = getObject(the_name, component, compileDesign,
                                     instance, pexpr);
    if (rootValue) {
      if (expr *expval = any_cast<expr *>(rootValue)) {         // <-- THE LAW
        path->Root_value(rootValue);
        if (ref_typespec *expval_rt = expval->Typespec()) {
          if (path->Typespec() == nullptr) {
            ref_typespec *path_rt = s.MakeRef_typespec();
            path_rt->VpiParent(path);                           // NAME: none
            path->Typespec(path_rt);
          }
          path->Typespec()->Actual_typespec(expval_rt->Actual_typespec());
        }
      } else if (UHDM::port *expval = any_cast<port *>(rootValue)) {
        path->Root_value(expval->Low_conn());                   // NO TYPESPEC
      } else if (param_assign *passign = any_cast<param_assign *>(rootValue)) {
        path->Root_value(passign->Rhs());
        ... the PARAMETER's own typespec ...
      }
    }
  }
```

Four consequences, each of them an axis this pass measured:

**(a) THE CARRIER GATE IS `instance && reduce == Reduce::Yes`,** and that is
the very gate r10earl112 decoded for the genvar VALUE rendering:
`CompileHelper::compileAssignmentPattern` (`CompileExpression.cpp:3688`) sets
`reduce = Reduce::Yes` when `instance` is non-null, and a generate body is
elaborated PER INSTANCE while a module-body continuous assign is compiled once
with `instance == nullptr`.  So golden hangs inside a generate scope and hangs
NOTHING at module scope — arm t2 cells c8/c9 measure exactly that, and it is
why this pass's emitter site (`flattenPatternCaRhs`, reached only from
`emitBlock`'s elaborated gen-scope cont-assign arm) is the right gate and not
an approximation of one.

**(b) THE MINT CARRIES NO NAME.**  Only `VpiParent` and `Actual_typespec` are
written.  `ref_typespec::Compare` reads `VpiName` and `VpiDefName`, so both
being EMPTY is part of the compared shape.  The full dotted `VpiFullName`
golden's dump prints is COMPUTED: UHDM's generated
`ref_typespec::VpiFullName()` (`ref_typespec.cpp:43`) calls `ComputeFullName()`
when the field is unset.  Setting a name here would have been a fabricated
difference; not setting one reproduces golden's dump line for line (§6a).

**(c) THE THREE BRANCHES ARE NOT INTERCHANGEABLE.**  A `port` root binds
`Low_conn` and hangs NOTHING; a `param_assign` root hangs the PARAMETER's
typespec; a task_func `io_decl` (a plain `BaseClass`, not an `expr`) takes no
branch at all and binds NEITHER field.  Arm t4 carries a cell for each.

**(d) `getObject`'s SEARCH ORDER IS THE ROOT-KIND AXIS**
(`CompileExpression.cpp:125-232`).  Per instance netlist it looks in

```
  array_nets()  ->  nets()  ->  variables()  ->  ports()  ->  param_assigns()
```

climbing outwards through GENERATE-kind instances only and stopping at the
first real module.  Two measured consequences:

* **`array_vars()` IS NEVER SEARCHED**, and
  `NetlistElaboration::elab_generates_`
  (`~/git-repos/Surelog/src/DesignCompile/NetlistElaboration.cpp:1819-1874`)
  builds a generate instance's netlist and then hands the `gen_scope` exactly
  `netlist->nets()` and `netlist->array_vars()`.  A signal **declared in a
  generate block** is therefore not answered by name: golden binds NEITHER
  field, and Surelog's own elaborator says so out loud for the undotted form
  (`[ERR:UH0725] Unresolved hierarchical reference "r4_src.a_valid"`).
  **This is the fence the corpus never had to teach us, because arm t1
  convicted the first cut first (§6c).**
* **A NET root carries no typespec of its own.**  A pure-`logic` packed struct
  driven by a continuous assign is modelled as an `array_net` / `struct_net`,
  and those objects have no `ref_typespec` — so `expval->Typespec()` is null
  and Surelog hangs nothing.  The SAME test does the SAME work on our side;
  the named over-fire risk needs no fence of its own, and that is a
  measurement (§3), not an argument.

---

## 3. THE GOLDEN GRID — four arms, both views, three census families

`grid114.sh` builds them, `cen114` reads them, `score114.py` scores the `PX`
family and `fam114.py` scores all three; `GRID.r10earl114.txt` holds every row
and `CALIB.r10earl114.txt` the golden-vs-golden calibration (**1060 cells, ALL
`SAME_AGREE`, 0 phantoms**).  Every cell is r10earl113 §3's head-reproducing
shape: a generate-for at depth 1, a KEYED pattern in a continuous assign whose
target is declared in that generate block and carries an ENUM member (which is
what makes Surelog model it a `struct_var`, so UHDM's `cont_assign::DeepClone`
flattens the pattern at all).

**Arm `t1_root114` — THE ROOT-KIND AXIS, the named over-fire risk (ELAB and
DEF views agree cell for cell):**

| cell | the path's ROOT | golden's Root_value / its typespec | golden hangs | ours, patched |
|---|---|---|---|---|
| r1 | PORT unpacked array of a typedef'd struct (**the corpus cell**) | `array_var` / `array_typespec` | **`ref_typespec → array_typespec`** | **hung, TO-GOLDEN** |
| r2 | MODULE-BODY unpacked array of the same struct | `array_var` / `array_typespec` | **hung** | **hung, TO-GOLDEN** |
| r3 | `wire`-declared array (`array_nets()` is searched FIRST) | `array_net` / **none** | **nothing** | **nothing** |
| r4 | gen-local packed struct | **none** (`ERR:UH0725`) | **nothing** | **nothing — THE FENCE** |
| r5 | gen-local struct NET | **none** (`ERR:UH0725`) | **nothing** | **nothing — THE FENCE** |
| r6 | module-body nested-struct array, 3-component path | `array_net` / **none** | **nothing** | **nothing** |
| r7 | a struct-typed LOCALPARAM | no root bound | **nothing** | **nothing** |
| r8 | an ANONYMOUS-typed array | `array_net` / **none** | **nothing** | **nothing** |
| r9 | a gen-local unpacked ARRAY (`array_vars()`, never searched) | **none** | **nothing** | **nothing — THE FENCE** |
| r10 | an ENCLOSING generate block's local, read from a nested one | **none** | **nothing** | **nothing — THE FENCE** |

So the axis is **the root OBJECT and where it is declared**, and the two halves
of the fence are different mechanisms: the net-rooted cells fence themselves
through the *typespec* test that Surelog itself applies, while the gen-local
cells need the *declaring-scope* test, because there golden has no root object
at all.

**Arm `t2_carrier114` — THE CARRIER AXIS (golden, ELAB view):**

| cell | carrier | golden's typespec edge |
|---|---|---|
| c1 | KEYED pattern member value, gen-scope `cont_assign` | **HUNG** (the head) |
| c2 | POSITIONAL pattern element, gen-scope `cont_assign` | **HUNG** — residue R1, we do not |
| c3 | pattern NESTED in a pattern | **HUNG** — residue R2, we do not |
| c4 | PLAIN `cont_assign` Rhs (no pattern) in a gen scope | bare on both sides |
| c5 | operand of a binary operation in a gen-scope `cont_assign` | bare on both sides |
| c6 | pattern in an `always_comb` in a gen scope (`car=assignment`) | **HUNG** — residue R1 |
| c7 | pattern in an `initial` in a gen scope | **HUNG** — residue R1 |
| c8 | **MODULE-SCOPE** `cont_assign` pattern | **BARE** — the `instance == nullptr` half of the gate |
| c9 | MODULE-SCOPE plain `cont_assign` Rhs | bare on both sides |
| c11 | a path inside a FUNCTION (root = the formal's `io_decl`) | bare on both sides |

**Arm `t3_member114` — THE MEMBER-KIND AXIS and THE DEPTH AXIS.**  Seven leaf
kinds — a one-bit `logic`, an ENUM member, a packed vector, a NESTED STRUCT
leaf, a three-component path, a BIT-SELECT on the member and a PART-SELECT on
the member — all hang **the same `array_typespec` of the root** in golden, and
all move to it here: the typespec is the ROOT's, never the leaf's, whatever the
leaf's width or kind.  The depth cells repeat r10earl113's scope axis on THIS
field: module body **bare**, gen-for depth 1 **hung**, depth 2 **hung**,
gen-if **hung**, gen-case **hung**.  `t3_member114_elab` is the arm whose
official `uhdm-cmp` head IS the corpus head, 17 lines → 37 lines, one head,
before and after.

**Arm `t4_fence114` — THE MUST-STAY FLOOR and the AWAY risks:** the
`struct_net` target golden never flattens (f1), the MODULE-BODY target inside a
generate block that r10earl113's size law is fenced off (f2), the
`bit_select`-Lhs target (f3), an interface-instance root `u_if.bus[i]` (f4,
`rv=<none>` and `ts=<none>` in golden AND in ours), a function-formal root (f5,
likewise bare on both sides), r10earl112's user-call-argument fence (f6), the
same head shape one instance DOWN in a child module (f7, TO-GOLDEN), and
r10earl110's genvar-bounded part select in a plain gen-scope assign (f8).

**THE THREE-FAMILY SCORE over all four arms, both views** (`GRID.r10earl114.txt`):

```
-- TOTAL PX  TOGOLD=122  AWAY=0  MOVEDWRONG=0  SAME_AGREE=152  STILLWRONG=4
             NOGOLD=12  NOGOLD_UNMOVED=56  ONESIDED=70
-- TOTAL P0  TOGOLD=128  AWAY=0  MOVEDWRONG=0  SAME_AGREE=170  STILLWRONG=28
             NOGOLD_UNMOVED=4  ONESIDED=30
-- TOTAL PR  TOGOLD=0    AWAY=0  MOVEDWRONG=0  SAME_AGREE=199  STILLWRONG=127
```

* **AWAY 0 and MOVED-WRONG 0 in all three families.**
* **`PR` — every other compare-visible field of every `hier_path` (VpiSize,
  VpiDecompile, VpiDefName, `Root_value`'s kind, and the whole `Path_elems`
  list with each element's `Actual_group` / index kind) — is TO-GOLDEN 0 /
  AWAY 0 / MOVED-WRONG 0**: the law moved its own field and nothing else.  Its
  127 `STILLWRONG` cells are pre-existing divergences (R0's element binding
  among them), byte for byte what the pristine binary produced.
* The 12 `PX` `NOGOLD` cells are all in t4 f1/f3, where OUR `lhs=` coordinate
  differs from golden's so the PX key does not join.  The COARSE `P0` family,
  keyed on span + name alone, scores those very spans **TO-GOLDEN with AWAY
  0** — which is why both families are run and both are printed.

---

## 4. THE LAW

> **§ `patHierPathRootTs114`.**  A `hier_path` that is an OPERAND of an
> assignment-pattern operation in an ELABORATED generate-scope continuous
> assign hangs a **`ref_typespec` whose `Actual_typespec` is the ROOT OBJECT'S
> OWN** — the same object the path's `Root_value` is bound to, shared and never
> copied — and the `ref_typespec` itself is MINTED PER PATH and carries NO
> `VpiName` and NO `VpiDefName`.
>
> **THE ROOT MUST BE ONE `getObject` CAN ANSWER**: not declared inside a
> generate block (`getObject` never searches `array_vars()`, and a generate
> instance's netlist is exactly what `elab_generates_` fills), and carrying a
> typespec of its own (an `array_net` / `struct_net` root has none, so neither
> emitter hangs anything).

### STATED GATE == CODE GATE

**STATED:** the path is an operand of an assignment-pattern operation emitted
inside an elaborated generate-scope continuous assign whose Rhs is a structured
pattern and whose Lhs is a packed struct; the path's ROOT resolves to an object
this emitter already binds as `Root_value`; that root is not declared in a
generate block; it carries a `ref_typespec` with a non-null `Actual_typespec`;
and the path does not already carry a `Typespec`.

**CODE:** inside `flattenPatternCaRhs`'s existing `Root_value` loop
(`src/ModuleEmit.cpp`), `!rootGenLocal114 && !hp114->Typespec() &&
any_cast<UHDM::expr*>(nit->second) && ->Typespec() && ->Actual_typespec()`,
where `rootGenLocal114` walks the root symbol's declaring scope out through
`StatementBlock`s and is set on `GenerateBlock` / `GenerateBlockArray`.  There
is no condition in the code that is absent from the prose and none in the prose
that is absent from the code.

### the fences, each of them a measured cell

| fence | what it keeps out | the cell that measures it |
|---|---|---|
| (a) the SITE (`flattenPatternCaRhs`) | the module-scope pattern, every non-pattern carrier, every path outside an assignment pattern — i.e. everything Surelog compiles with `instance == nullptr` or `Reduce::No` | t2 c8/c9 (module scope, golden BARE), t2 c4/c5 (plain Rhs and binary operand, bare on both sides) |
| (b) `nit != netMap.end()` (pre-existing) | a root this emitter binds no object for at all: an interface-instance root, a function formal | t4 f4 (`u_if.bus[i]`) and t4 f5 / t2 c11, all `rv=<none>` and `ts=<none>` on BOTH sides |
| (c) `!rootGenLocal114` | a root DECLARED IN A GENERATE BLOCK, which `getObject` cannot answer by name | t1 r4, r5, r9 and r10 — **five P0 cells scored SHAPE-AWAY before this fence existed (§6c)** |
| (d) the root's own `Typespec()` / `Actual_typespec()` | every NET root (`array_net`, `struct_net`) and every ANONYMOUS-typed root, none of which carries a typespec — the SAME test Surelog applies | t1 r3, r6, r8 (golden `rts=<none>`, hangs nothing; ours identical) |
| (e) `!hp114->Typespec()` | a path some earlier law already bound (§ `connPathRootTs53`'s connection sites are a different builder and are not reached here at all) | the corpus census `PR` family at MOVED-WRONG 0 |

### the hypotheses this pass REFUTED, each on an arm cell or on the judge

| candidate | refuted by |
|---|---|
| "the hung typespec is the LEAF MEMBER's" | t3 m1..m7 and the corpus head — a one-bit `logic` leaf hangs the ROOT's `array_typespec`; so do an enum, a vector, a nested struct, a bit-select and a part-select |
| "the typespec object is COPIED per path" | `own114`'s identity read: `SAME Actual_typespec OBJECT: YES`, with 28 `ref_typespec` objects sharing one `array_typespec` |
| "the `ref_typespec` needs golden's dotted `VpiFullName`" | `ref_typespec::VpiFullName()` COMPUTES it from the parent chain when unset; the mint sets only `VpiParent`, and the dump prints golden's exact string (§6a) |
| "the axis is the SCOPE (gen vs module)" alone | t2 c8 — a module-scope pattern is BARE in golden, so the axis is the INSTANCE, and t1 r4/r5/r9/r10 — a gen-scope pattern is bare too when the ROOT is gen-local |
| "an `array_net` root needs its own kind fence" | t1 r3/r6/r8 — the net objects carry no typespec on EITHER side; the existing test does the work |
| "a path inside a function or through an interface must be excluded by kind" | t4 f4/f5 — no root object is bound there on either side, so the site is never reached |
| "clearing this field clears the head" | §1 fact 6 and §7 — `Path_elems[1].Actual_group` is next, and that is what the head becomes |

---

## 5. THE CORPUS CENSUS — 2314 databases, both corpora × both modes

`cen114` over every database of both sweeps (`censweep114.sh`, `ACCOUNTING
PASS` on each of the four runs: surelog LISTED 1573 / PROCESSED 956 / SKIPPED
617 / CENFAIL 0; uhdm2rtlil LISTED 1462 / PROCESSED 1358 / SKIPPED 104 /
CENFAIL 0), split by `sweepsplit114.sh` — which **asserts the two sweeps'
GOLDEN halves are byte-identical** before anything is scored (it does, for both
corpora) — and joined as a MULTISET by `cen114.py`.

| corpus | family | keys joined | SHAPE TO-GOLDEN | AWAY | MOVED-WRONG | STILLWRONG | ONE-SIDED-CHANGED |
|---|---|---|---|---|---|---|---|
| surelog | **PX** (the law's surface) | 164 | **68** | **0** | **0** | **0** | 7 |
| surelog | **P0** (EVERY hier_path) | 49427 | **68** | **0** | **0** | **0** | 0 |
| surelog | **PR** (the rest) | 49427 | 0 | **0** | **0** | 2416 | 0 |
| uhdm2rtlil | **PX** | 80 | 0 | **0** | **0** | 0 | 0 |
| uhdm2rtlil | **P0** | 3416 | 0 | **0** | **0** | 0 | 0 |
| uhdm2rtlil | **PR** | 3416 | 0 | **0** | **0** | 0 | 0 |

* **AWAY 0 and MOVED-WRONG 0 in every family of both corpora.**  The `PR` row
  is the proof that the law moved its own field and nothing else: every other
  compare-visible field of every `hier_path` in both corpora is exactly what
  the pristine binary produced.
* **`P0` STILLWRONG 0 over 49 427 joined keys** — after this pass, EVERY joined
  `hier_path` key in the whole surelog corpus carries golden's typespec edge.
  The typespec-edge family is CLOSED corpus-wide on the joined keys; the
  positional and nested-pattern carriers of §3 (residues R1/R2) therefore have
  **zero corpus population**, which is why this pass does not widen the site to
  reach them.
* **The 7 `PX` ONE-SIDED-CHANGED cells** are `testflags/Earlgrey_0_1`'s
  `drsp_fifo_o.d_*` at `tlul_socket_m1.sv:242-249` — the `lhs=bit_select`
  shape (r10earl113's x3 / this pass's t4 f3), where OUR Lhs coordinate differs
  from golden's so the PX key does not join.  Under the coarse `P0` key the
  same objects score **TO-GOLDEN in `default`** and SHAPE-TO-GOLDEN in
  `testflags`: golden holds `{bare×1, hung×29}` there and the patched database
  holds `{bare×1, hung×58}` — golden's SHAPE at testflags' 2× arena
  multiplicity.  Named, counted, and not folded into either column.
* The STRICT (multiset) columns report MOVED-WRONG 27 (`PX`) and 34 (`P0`)
  where the SHAPE columns report 0: those are the arena COPY COUNTS
  (r10earl112's R6 / r10earl113's R5), which no generated `Compare` reads.
  Both scores are printed; the SHAPE line is the judged one, on
  earl111/112/113's precedent.
* uhdm2rtlil: **not one cell of any family moved**, matching byteverify's
  MOVERS 0 / 1358.

### THE PREDICTION, made from the PRISTINE databases FIRST

`predict114.py` reads only the PRISTINE sweep census (our pristine databases
and the goldens; it never sees a patched database) and applies the code's own
gate.  `PREDICT_sl.txt`:

```
--- GATE-MATCHING cells: 75 ---
--- PREDICTED MOVE cells: 68 ---
        each with its predicted payload constructed from the PRISTINE key:
        ts=ref_typespec(n='',dn='')-><the root's own rts>
--- PREDICTED NO-OP cells: 0 ---
--- NOGOLD cells: 7 ---   (the drsp_fifo_o bit_select-Lhs shape)
ROWS PREDICTED TO MOVE (2):
  default/Earlgrey_0_1-71da2fd7
  testflags/Earlgrey_0_1-71da2fd7
```

`PREDICT_u2r.txt`: **0 gate-matching cells, 0 rows** over 1358 databases.

**The predicted cell set, the predicted new PAYLOADS and the predicted ROW set
are exactly what the patched census and `byteverify.sh` measured** — 68 moving
cells with the predicted payload, 7 one-sided cells, two Earlgrey rows, and no
third row from the law.

---

## 6. THE GATES — ALL GREEN

Both binaries were built from THIS pass's own worktree at a clean `362dcfa0`
and frozen `chmod 555` BEFORE any sweep; every `cmds.txt` in all four workdirs
was audited BY BINARY PATH — `/tmp/r10earl114_bin/pristine` in the two control
workdirs (1573 + 1462 files) and `/tmp/r10earl114_bin/patched` in the two
patched ones (1573 + 1462), one distinct path per workdir and no other.

| gate | result |
|---|---|
| (1) build both, md5s | pristine `8b1777950b91feef705565e6f16e8b0a` (byte-identical to the main tree's `build/slang-uhdm`), patched `fff26ad19801bf4bbf445db25df03f44` |
| (2) goldens | **23 PASS / 0 FAIL** on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** (the negative control) |
| (3) uhdm2rtlil, testflags AND default | **CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2** on both binaries, identical histograms; `ct8rows` **PASS** against the committed baseline AND against this pass's own pristine control, in BOTH modes |
| (4) surelog, `--mode both`, 1588 rows | identical status histograms on both binaries (default CMP_EQUAL 471 / SLANG_REJECT 283 / SURELOG_FAIL 25 / CMP_NOTEQUAL 10 / DEFERRED 5; testflags CMP_EQUAL 466 / SLANG_REJECT 284 / SURELOG_FAIL 23 / CMP_NOTEQUAL 9 / DEFERRED 5 / NO_DATABASE 3 / UNTRANSLATABLE 2 / TIMEOUT 1 / NO_UHDM 1); `ct8rows` **PASS** — 0 differing rows — against the committed baseline AND against the pristine control.  **NO ROW CONVERTED**, in either direction |
| (5) `byteverify.sh SELFCHECK=1` | uhdm2rtlil **MOVERS 0 / 1358**; surelog **MOVERS 2 / 956** — exactly the two PREDICTED Earlgrey rows and nothing else (no coin this run).  SELFCHECK flagged 1357/1358 and 955/956, so the comparator can see |
| rowheads | **Earlgrey_0_1 testflags 17 → 37 cmp lines, ONE head, the judge advanced one field on the SAME object**; every other row unchanged: SeqDriver 31/31, SimpleUVM at the depth artifact, Scoreboard/default 95, MiniAmiq 31/31, BuildUVMPkg 48/48, Earlgrey_0_1 default 31 with a BYTE-IDENTICAL cmp log, Rggen/default 0 |
| canaries | `canaries.sh` surelog **ok=52 changed=0**, uhdm2rtlil **ok=8 changed=0**; `ctcan2.sh` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs, by name | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a`/`73a10e8217e5`, `YosysOldOr` `d68e0796d62c` — all SAME as pristine in both modes; `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a**, both pins met (10 pins, all SAME) |
| the four slang-fenced tests | never dispatched; no probe file in this directory spells any of the four outside `canaudit.sh`'s own `FENCED=` line |

### 6a. THE TWO BYTE MOVERS, ATTRIBUTED THREE INDEPENDENT WAYS

**0. The SECTIONED, path-normalised, ORDER-BLIND whole-dump diff**
(`attrib114.sh` + `secattr114.py`, whose three-region cut keeps the
weaklyReferenced TAIL out of the count instead of letting the last
`|uhdmtopModules:` section swallow it).  `ATTRIB_Earlgrey.txt`,
`SECATTR_default.txt`, `SECATTR_testflags.txt`:

```
default    RAW 3716  ORDER-BLIND 3407
           ADDED   total 3249  by region {DEF: 1, ELAB: 3248, TAIL: 0}
           REMOVED total    1  by region {DEF: 1, ELAB: 0,    TAIL: 0}
testflags  RAW 5804  ORDER-BLIND 5265
           ADDED   total 5076  by region {DEF: 1, ELAB: 3248, TAIL: 1827}
           REMOVED total    1  by region {DEF: 1, ELAB: 0,    TAIL: 0}
```

**The REMOVED side is exactly one line in each mode — the dump's own header
naming the workdir path.  ZERO content is removed anywhere, in either mode, in
any region.**  The ELABORATED addition is **the SAME 3248 lines in BOTH modes**
(the judge-visible change is mode-independent); testflags' extra 1827 lines are
all in the weaklyReferenced TAIL, which is unreachable to the judge and by this
campaign's rule never counted.  The added shapes in DEF+ELAB are, in both
modes, only these:

```
   464 |vpiTypespec:  +  464 |vpiParent:  +  464 |vpiActual:
                                   <- one triple per new ref_typespec
   261 \_array_typespec:      }
   203 \_struct_typespec: (tlul_pkg::tl_dNh_t)   }  261 + 203 = 464 ACTUALS
   16 x 29  \_ref_typespec: (...gen_host_fifo[N].tl_h_i[N].<member>)
   16 x 29    \_hier_path: (tl_h_i[N].<member>)
   16 x 29    |vpiFullName:...gen_host_fifo[N].tl_h_i[N].<member>
```

— the 464 minted `ref_typespec` objects (one per pattern-carried path per
unrolled `gen_host_fifo` / `gen_idrouting` instance), the objects they
reference, and the `VpiFullName` UHDM COMPUTES for each.  Nothing else changed.

**1. `kinds114`, the WHOLE-DATABASE census over `Serializer::AllObjects`**
(every object, reachable or not, by kind AND by kind+name).  `default`: the
ONLY difference in the entire database is `ref_typespec` **110389 → 110853
(+464)**; every other kind, and every name, identical.  `testflags`:
`ref_typespec` **188980 → 190169 (+1189)** AND `array_typespec` **825 → 1086
(+261)**.

**2. `ats114`, the array_typespec population probe — because this law mints
only `ref_typespec` and an unexplained +261 objects is exactly what a verifier
convicts a pass on.**  It prints every `array_typespec` by SPAN with its
`Elem_typespec` edge, its count and its referrers:

* `testflags`: the SET of coordinates is **IDENTICAL — 79 spans on both
  sides, none added, none removed**.  All 261 extra objects sit at ONE
  coordinate, the spanless anonymous `array_typespec`, whose count goes
  **206 → 467** while its referrer list goes `array_var x239` →
  `array_var x239, hier_path x783`.  They are ARENA COPIES the pristine save
  had no reference to and therefore never wrote; the new references pull them
  into the file.  That is r10earl112's R6 / r10earl113's R5 arena-count
  residue, and its 2× testflags multiplicity is exactly the split that shows
  here.
* `default`: the array_typespec population is **identical count for count**
  (78 spans, same numbers); only the referrer list grows, by `hier_path x261`.
  No new object at all.

### 6b. THE WIDE BOUNDARY

`widerun114.sh` stages a COPY of the whole committed `tools/probe` tree, lists
every `.sv`/`.v` at ANY depth, filters the four fenced names out of the list
BEFORE a single child runs, and compares the workdir-normalised `uhdm-dump` of
both frozen binaries in BOTH views.

```
LISTED (BOUNDARY_WIDE.all)   : 5050     FENCED-NAME HITS IN THE LIST : 0
DISTINCT FILES IN THE rc LOG : 5050     FILES WITH != 4 rc LINES     : 0
FILES LISTED BUT NEVER RUN   : 0
PROCESSED=5050  identical=9688  DIFFERING=28  no_output=384
rc by side:  A/0 9327  A/3 368  A/4 389  A/139 16
             B/0 9327  B/3 368  B/4 389  B/139 16   <- perfectly SYMMETRIC
differing: plain+elab of r10earl113repro's s1_scope113 s2_opkind113
                        s3_carrier113 s4_fence113, of r10vearl113repro's
                        v1_decl113 v2_pat113 v3_lhs113 v4_ctx113 v5_iface113
                        v6_name113, and of THIS pass's own four arms
```

**LISTED == PROCESSED == 5050, every listed file with exactly its four
invocations (2 views x 2 binaries), none skipped**, and the rc histogram is
identical side for side — no arm rejects on one binary and not the other, and
the 16 `rc=139` segfaults are the same 16 on both sides.  (The accounting is
reconstructed in `BOUNDARY_WIDE.accounting` from the per-invocation `rc` log
rather than from the driver's own stdout, because the first run was invoked
with its stdout redirected to the same path the driver used for its file list;
`widerun114.sh` now writes the list to `$OUT.list`, and reconstructing from the
rc log is the stronger check regardless — it proves every listed file actually
ran, which the driver's own counter cannot.)

**The 28 differing cells are ten r10earl113 / r10vearl113 arm files in both
views plus this pass's own four (the POSITIVE CONTROL, which proves the gate
can see), and EVERY ONE was rebuilt against its own real golden and re-scored**
(`BOUNDARY_earl113arms.txt`, `BOUNDARY_vearl113arms.txt`, calibrated at 162 and
450 cells with 0 phantoms):

```
r10earl113's four arms   -- TOTAL PX  TOGOLD=78  AWAY=0  MOVEDWRONG=0  SAME_AGREE=66
                            -- TOTAL P0  TOGOLD=84  AWAY=0  MOVEDWRONG=0  SAME_AGREE=70
                            -- TOTAL PR  TOGOLD=0   AWAY=0  MOVEDWRONG=0  SAME_AGREE=110
r10vearl113's six arms   -- TOTAL PX  TOGOLD=148 AWAY=0  MOVEDWRONG=0  SAME_AGREE=196
                                       NOGOLD=44  NOGOLD_UNMOVED=28  ONESIDED=106
                         -- TOTAL P0  TOGOLD=176 AWAY=0  MOVEDWRONG=4  SAME_AGREE=194
                         -- TOTAL PR  TOGOLD=0   AWAY=0  MOVEDWRONG=0  SAME_AGREE=297
```

(the `P0` MOVED-WRONG 4 is the SAME two `v5_iface113` cells counted in both
views, and nothing else; the `PX` NOGOLD 44 are cells whose ROOT KIND differs
between the two emitters — inside an interface Surelog models the root as a
`struct_var` and we as a `struct_net` — so the PX key does not join, which is
precisely why the coarse `P0` family is scored beside it and scores AWAY 0)

* **AWAY 0 on every one of the sixteen arm/views, and MOVED-WRONG 0 on
  fifteen of them.**
* **THE ONE EXCEPTION, NAMED LOUDLY: `v5_iface113` scores `P0` MOVED-WRONG 2**
  (the same two cells in both views), and the payloads say exactly what
  happened:

```
  [MOVEDWRONG] P0 v5_iface113_elab|P0|22:27-22:32|src.v      (and 22:37 src.o)
      G:{'ts=<none>': 1, "ts=ref_typespec(n='',dn='')->struct_typespec('pv5113::zs_t')": 2}
      P:{'ts=<none>': 2}
      Q:{"ts=ref_typespec(n='',dn='')->struct_typespec('pv5113::zs_t')": 2}
```

  Golden holds THREE objects at that span — TWO in `sc=gen_scope gd=1`, both
  **hung** with `struct_typespec('pv5113::zs_t')`, and ONE in
  `sc=interface_inst gd=0` (the definition copy) that is bare.  We hold TWO,
  both `sc=gen_scope gd=1`, and both moved onto **golden's gen-scope payload
  character for character**.  What remains is golden's THIRD, bare, definition
  copy, which we do not emit on EITHER binary — a pre-existing object-count
  divergence (r10earl113's R2 def-view residue), not a value moved wrong.  The
  SHAPE-set rule cannot say "our set is a subset of golden's and every element
  of it is golden's", so it reports MOVED-WRONG; the payloads above are printed
  instead of being folded away.  **The official judge agrees the arm did not
  move: `uhdm-cmp` reports 58 lines / 1 head on `v5_iface113` in BOTH views on
  BOTH binaries, and the two cmp logs are BYTE-IDENTICAL.**
* **r10earl110's, r10earl111's, r10earl112's and their verifiers' arms are not
  in the differing list at all** — every one of their `.sv` files dumps
  byte-identically from the two binaries in both views, so those laws and their
  fences are untouched by construction.

### 6b-2. THE MUST-STAY FLOOR SCORED BY ITS OWNER'S OWN INSTRUMENT

The census families above read the TYPESPEC edge; r10earl113's law is about the
pattern operation's FIRST OPERAND (its `VpiSize`, `VpiDecompile`, `VpiValue`,
const type and op type), which `cen114` does not look at.  So `cen113` — the
committed instrument of the law this pass sits on top of — was built from
`tools/probe/r10earl113repro/cen113.cpp` and run on all sixteen arm/views
(`FLOOR_earl113law.txt`):

```
arm/views scored: 16
-- TOTAL PX  NOGOLD_UNMOVED=130  ONESIDED=102  SAME_AGREE=340  STILLWRONG=5
-- TOTAL P0  ONESIDED=2   SAME_AGREE=101  STILLWRONG=127
-- TOTAL PR  ONESIDED=2   SAME_AGREE=100  STILLWRONG=128
```

**TOGOLD 0 / AWAY 0 / MOVEDWRONG 0 / NOGOLD 0 in all three of r10earl113's own
families**: every cell of its law is exactly where the pristine binary left it,
by its own scorer and not by this pass's.

### 6c. THE REGRESSION THE ARM CAUGHT, AND THE FENCE IT BOUGHT

The first cut of this law hung the typespec wherever `Root_value` was already
bound.  It cleared the head, scored `PX` TO-GOLDEN 12 / AWAY 0 on arm t1's own
family — and the COARSE `P0` family on the SAME arm convicted it, because the
PX key carries the root kind and therefore called the bad cells `NOGOLD`
instead of comparing them:

```
SHAPE TOGOLD=12 AWAY=5 MOVEDWRONG=0
 [AWAY] t1_root114_elab|P0|139:32-139:46|r4_src.a_valid
    G {'ts=<none>': 4}
    P {'ts=<none>': 10}
    Q {'ts=<none>': 1, "ts=ref_typespec(n='',dn='')->struct_typespec('p114::h2d_t')": 9}
 ... the same for r4_src.a_opcode, r5_src.a_valid, r9_src[1].a_valid,
     r9_src[1].a_opcode ...
```

All five are **roots declared in the generate block** — a packed struct, a
struct net and an unpacked array.  Golden binds NO `Root_value` and hangs NO
typespec there, and §2(d) is why: `getObject` never searches `array_vars()`,
and a generate instance's netlist is exactly what `elab_generates_` fills, so
the name is not answered at all.  `rootGenLocal114` is the fence that decode
bought, and cell r10 (an ENCLOSING generate block's local read from a nested
one) measures its reach.  **This is also why `fam114.py` exists and why every
score in this README is printed for all three families: the reading key and the
scoring key must not be the same key.**

Two arm shapes were also removed after being bisected cell by cell rather than
guessed: `assign <unpacked array> = '{default: '{...}}` **segfaults Surelog** in
`Creating UHDM Model` (and slang rejects it), and a MODULE-scope undotted struct
read from inside a generate scope draws `[ERR:UH0725] Unresolved hierarchical
reference` from Surelog's elaborator — an arm whose golden is an error message
is not an arm that tests anything.

---

## 7. RESIDUES, and R0

* **R0 — `Path_elems[1].Actual_group` ON THE SAME OBJECT, READ not predicted.**
  `design::Compare` returned **+1** before this pass and returns **−1** after
  it: golden's trailing `ref_obj a_valid` is UNBOUND (`LHS: <null>`) and ours
  binds it to the `typespec_member`.  Golden's FIRST element IS bound
  (`bit_select → Actual_group → array_var`) and ours is NOT, so it is a
  PER-POSITION rule and needs its own grid.  This is earl113's R1 / earl112's
  R2, now reproduced by `own114`'s mask ladder on BOTH the corpus row and arm
  `t3_member114_elab`, whose elaborated view produces the head byte for byte.
  **The next pass starts from a 140-line arm.**
* **R1 — the POSITIONAL and PROCESS carriers.**  Golden hangs the same typespec
  on a positional (untagged) gen-scope pattern element, on a pattern NESTED in
  a pattern, and on a pattern in an `always_comb` / `initial` in a generate
  scope (arm t2 cells c2, c3, c6, c7 — `car=assignment` for the last two).  We
  do not: `flattenPatternCaRhs` is entered only for a STRUCTURED pattern in a
  gen-scope continuous assign.  **Corpus population: ZERO** — the `P0` family's
  STILLWRONG is 0 over 49 427 joined keys — which is why this pass does not
  widen the site.
* **R2 — our `Root_value` binds where golden binds nothing.**  On a gen-local
  root (arm t1 r4/r5/r9/r10) we bind `Root_value` and golden does not, and
  `hier_path::Compare` DOES read `Root_value`.  That divergence is
  PRE-EXISTING on both binaries and this pass deliberately does not follow it;
  §2(d) now names the mechanism (`getObject` never searches `array_vars()`),
  so it is a decoded law waiting for its own pass rather than an open question.
* **R3 — the arena COUNT residue.**  Golden and ours agree on the SHAPE of
  every moved cell and differ on how many arena copies exist (2× under
  testflags).  Invisible to the judge and pre-existing on both binaries
  (earl112's R6, earl113's R5); reported so the STRICT and SHAPE scores can be
  read against each other rather than one being quietly chosen.  Its visible
  consequence here is the +261 previously-unwritten `array_typespec` copies of
  §6a, whose coordinate set is unchanged.
* **R4 — INSIDE AN INTERFACE, the two emitters disagree on the ROOT's KIND.**
  On arm `v5_iface113` Surelog models an interface-body `zs_t src` as a
  `struct_var` and we model it as a `struct_net`; both carry the same
  `struct_typespec`, so this law hangs the same object on both sides and the
  official judge's cmp log is byte-identical — but the kind itself is a
  pre-existing divergence, and it is what makes 44 `PX` cells of the
  r10vearl113 arms score NOGOLD instead of joining.  Golden also holds a THIRD,
  definition-view copy at those spans that we emit on neither binary (§6b).
  Neither is this law's, and both are now measured.
* **R5 — the DEFAULT-mode flatten** (earl113's R2) and **the `struct_net`
  clone gate** (earl113's R3) are untouched: this law writes a field on objects
  we already emit and creates no operand anywhere.
* **R6 — earl110's, earl111's, earl112's and earl113's laws are untouched.**
  earl110's, earl111's and earl112's arms (and their verifiers') are not even
  in the wide boundary's differing list — byte-identical from both binaries in
  both views.  earl113's own census family, run by its OWN committed instrument
  over all sixteen arm/views, scores TOGOLD 0 / AWAY 0 / MOVEDWRONG 0 / NOGOLD
  0 (§6b-2).

---

## 8. FILES

| file | what it is |
|---|---|
| `own114.cpp` | the owner finder, field bisector, IDENTITY and SHARER finder: runs the OFFICIAL `design::Compare`, CLIMBS from a null-RHS `ref_typespec` head to its owner and pairs ours by kind+name+span, prints every field in the generated order, both `Path_elems` lists, the parent chain, every sibling operand, whether the hung typespec is the ROOT's own OBJECT, and how many objects share it — then masks and re-runs to READ the next field |
| `cen114.cpp` | the census: every `hier_path` in a database, in THREE families — `PX` (the law's surface, keyed on span + name + the scope × depth × carrier × clone-gate × ROOT-KIND × ROOT-DECLARING-SCOPE matrix), `P0` (every hier_path keyed on span + name alone) and `PR` (THE REST, compare-visible) |
| `cen114.py` | the MULTISET join and scorer: STRICT and SHAPE, `TOGOLD` / `AWAY` / `MOVEDWRONG` / `STILLWRONG` / `ONE-SIDED-CHANGED` |
| `fam114.py` | the THREE-FAMILY arm scorer — the instrument that convicted the first cut (§6c), because the PX key hides a cell whose root kind differs from golden's and the P0 key does not |
| `score114.py`, `px114.py` | the per-arm PX scorer and the human-readable grid printer |
| `grid114.sh`, `TOPS.txt` | the grid driver and its `-top` table |
| `calib114.sh`, `CALIB.r10earl114.txt` | golden-vs-golden calibration, 1060 cells across three families, 0 phantoms |
| `t1_root114.sv` | THE ROOT-KIND AXIS: port array / module array / `wire` array / gen-local struct / gen-local struct net / nested-struct array / localparam / anonymous type / gen-local array / an ENCLOSING generate block's local |
| `t2_carrier114.sv` | THE CARRIER AXIS: keyed / positional / nested pattern, plain Rhs, binary operand, `always_comb`, `initial`, module scope, localparam, function |
| `t3_member114.sv` | THE MEMBER-KIND AXIS (seven leaf kinds) and THE DEPTH AXIS (module / gen-for 1 / gen-for 2 / gen-if / gen-case) — its ELAB view IS the corpus head |
| `t4_fence114.sv` | THE MUST-STAY FLOOR and the AWAY risks: struct_net target, module-body target, bit_select Lhs, interface-instance root, function-formal root, r10earl112's user-call fence, a CHILD instance, r10earl110's part select |
| `censweep114.sh`, `sweepsplit114.sh`, `predict114.py` | the corpus census sweep, the two-sweep splitter (which ASSERTS the two sweeps' golden halves identical) and the BY-NAME, BY-PAYLOAD mover prediction from PRISTINE databases |
| `attrib114.sh`, `secattr114.py` | the sectioned, path-normalised, ORDER-BLIND whole-dump mover attribution (the weaklyReferenced TAIL is never counted) |
| `kinds114.cpp` | the WHOLE-DATABASE kind/name census over `Serializer::AllObjects` |
| `ats114.cpp` | the `array_typespec` POPULATION probe — every such object by SPAN with its element edge, its count and its referrers, which is what proved the +261 objects are arena copies pulled into the file and not new types |
| `wide114.sh`, `widerun114.sh` | the wide boundary over every `.sv`/`.v` in `tools/probe` at any depth, both views, both binaries, workdir-normalised dump compare |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the landing gates (copied verbatim from their owning pass dirs) |
| `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp` | the official `uhdm-cmp` output on the head row, both modes, both binaries |
| `OWNER_BEFORE.r10earl114.txt` / `OWNER_AFTER.r10earl114.txt` | `own114` on the pristine and on the patched corpus databases |
| `GRID.r10earl114.txt` | the arm grid's three-family score |
| `CENSUS_{sl,u2r}.{PX,P0,PR}.txt`, `PREDICT_sl.txt`, `PREDICT_u2r.txt` | the corpus census scores and the frozen prediction |
| `SECATTR_default.txt`, `SECATTR_testflags.txt` | the THREE-REGION (DEF / ELAB / TAIL) order-blind attribution of each mover |
| `BOUNDARY_earl113arms.txt`, `BOUNDARY_vearl113arms.txt`, `FLOOR_earl113law.txt` | the ten r10earl113 / r10vearl113 arms the wide boundary flagged, re-scored in this pass's three families AND in r10earl113's OWN census family |
| `BOUNDARY_WIDE.accounting`, `BOUNDARY_WIDE.tally`, `BOUNDARY_WIDE.rc_by_side`, `BOUNDARY_WIDE.diff` | the wide boundary's independent accounting (reconstructed from the per-invocation rc log), its counts, its per-side rc histogram and its differing list |
| `KINDS_*.txt`, `KINDSDIFF_*.txt`, `ATS_*.txt` | the whole-database kind census on both movers and its diff, and the array_typespec population on both sides |
| `ATTRIB_Earlgrey.txt` | the order-blind whole-dump attribution of the two predicted rows |

**Build the four C++ instruments with**

```
g++ -O2 -std=c++17 <tool>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <tool>
```
