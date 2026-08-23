# r10uvm110 — § `dynArrayNewLvalueBaseOnly110`

*The dynamic-array `new [n]` lvalue collapses to its RECEIVER.*
Base commit `28f373a`.  LHS is ALWAYS golden (Surelog); the judge is the
official `uhdm-cmp` and nothing else.  Every instrument here is
MEASUREMENT-ONLY.

## R0 — the head this pass was given

uvm-1.2 `src/reg/uvm_reg_adapter.svh:195`, inside
`uvm_reg_tlm_adapter::reg2bus`:

```systemverilog
    gp.m_byte_enable = new [nbytes];      // gp is a local `uvm_tlm_gp` handle
```

`head_before_SeqDriver_{default,testflags}.cmp` (46 cmp lines, ONE head, both
modes, identical text):

```
LHS: ref_obj: (uvm_pkg::uvm_reg_tlm_adapter::reg2bus::gp), line:195:6, endln:195:22
     |vpiParent: assignment 195:6-195:37
     |vpiName:gp
     |vpiFullName:uvm_pkg::uvm_reg_tlm_adapter::reg2bus::gp      <- NO vpiActual
RHS: hier_path: (gp.m_byte_enable), line:195:6, endln:195:22
     |vpiActual: ref_obj (gp)              195:9-195:22
     |vpiActual: ref_obj (m_byte_enable)   195:9-195:22
     |vpiName:gp.m_byte_enable
```

A KIND divergence on `assignment::Lhs`.  Golden ships the RECEIVER ALONE — a
plain `ref_obj` named `gp`, spanning the WHOLE `gp.m_byte_enable` text
(195:6-195:22), carrying the scope-qualified `vpiFullName` and **no**
`vpiActual`.  Measured directly on the golden database, not inferred: the
`uhdm-dump` of golden holds NO `hier_path` for the statement at all.

## The law

**§ `dynArrayNewLvalueBaseOnly110`** — an assignment written

```
<base>[.<name> | [idx]]... = new [n];        (and the copy form `new [n] (src)`)
```

with a **dotted** lvalue takes, in golden, a plain `ref_obj` **named after the
FIRST identifier** of the lvalue and **spanning the whole lvalue text**, not the
`hier_path` every other dotted lvalue takes.  The trailing components are never
compiled at all.

### Producer decode (Surelog, exact)

The SV grammar gives the dynamic-array form its own alternative,
`grammar/SV3_1aParser.g4:2312`

```
blocking_assignment
  : variable_lvalue ASSIGN_OP delay_or_event_control expression
  | nonrange_variable_lvalue ASSIGN_OP dynamic_array_new          <-- THIS ONE
  | (implicit_class_handle DOT | class_scope | package_scope)? (identifier | hierarchical_identifier) select ASSIGN_OP class_new
  | operator_assignment ;
```

so the lvalue is wrapped in a **`paNonrange_variable_lvalue`** VObject rather
than the `paVariable_lvalue` / bare `paHierarchical_identifier` the other three
alternatives produce.

`CompileHelper::compileBlockingAssignment`
(`src/DesignCompile/CompileHelper.cpp:4456`) reaches its FIRST arm for it — the
arm's test reads `fC->Child(Operator_assignment)`, which here is the
`paHierarchical_identifier` — and that arm then **shadows its own local**:

```cpp
  if (fC->Type(Variable_lvalue) == paHierarchical_identifier ||
      fC->Type(Variable_lvalue) == slStringConst) {
    NodeId Variable_lvalue = Operator_assignment;      // the paNonrange_… WRAPPER
    Delay_or_event_control = fC->Sibling(Variable_lvalue);
    …
    lhs_rf = any_cast<expr*>(compileExpression(component, fC, Variable_lvalue, …));
    if (fC->Type(Delay_or_event_control) == paDynamic_array_new) { … "new" fcall … }
```

i.e. it hands `compileExpression` the WRAPPER node, not the identifier.  Inside
`compileExpression` (`src/DesignCompile/CompileExpression.cpp:2696` case, name /
select tail at 2782-2852) the branch that walks a dotted chain reads

```cpp
    if (parentType == paHierarchical_identifier ||
        parentType == paPs_or_hierarchical_identifier) rhs = parent;
    else                                               rhs = child;
    …
    while ((rhs = fC->Sibling(rhs))) {          // appends ".<seg>" / compileSelectExpression
```

`parentType` is `paNonrange_variable_lvalue`, so `rhs = child` — and the sibling
walk that appends `.<seg>` to the name and calls `compileSelectExpression`
(which is where the `hier_path` at `CompileExpression.cpp:1374` is built)
therefore starts one level too deep and finds NOTHING.  What survives is the
plain `ref_obj` the tail mints from `name` — the FIRST segment —
`populateCoreMembers`'d over the whole `paNonrange_variable_lvalue` span.

The `= new (…)` **class** form takes the THIRD arm instead
(`CompileHelper.cpp:4533-4557`), which passes the `paHierarchical_identifier`
itself, so `rhs = parent`, the chain IS walked, and golden keeps its
`hier_path` — which is exactly what § `oobRefVarLocalHoistNet107` decoded for
that form, and why the two `new` spellings must NOT share a shape.

### Implementation

One clause in `src/ExprEmit.cpp`'s `ExpressionKind::Assignment` arm: when the
predicate fires, emit the **base subexpression** through the ordinary lvalue
path and restamp only its SPAN to the whole lvalue text.  Emitting the base
(rather than rewriting a finished `hier_path`) is what makes the ref take the
same `vpiActual` an undotted lvalue of that base would take — which is what
golden has.

## What moved

`head_after_SeqDriver_{default,testflags}.cmp` — **SeqDriver 46 → 17 cmp lines,
both modes, ONE head each.**  The `reg2bus` cell is gone; the 17-line head that
surfaces underneath is a PRE-EXISTING divergence the cleared one was masking (an
extra `logic_net work@top_tb.hdl_paths_pool`, present in the PRISTINE database
already — 6 occurrences — and absent from golden: 0).  That is R0 below.

Corpus reach, from a whole-tree scan of the UVM sources: **three sites**, and
they are all of them.

| site | statement |
|---|---|
| uvm-1.2 `reg/uvm_reg_adapter.svh:195` | `gp.m_byte_enable = new [nbytes];` |
| uvm-1.2 `reg/uvm_reg_adapter.svh:200` | `gp.m_data = new [gp.get_streaming_width()];` |
| svaunit `sv/svaunit_immediate_assertion_info.svh:273` | `copy.checks_details = new[…](copy.checks_details);` |

`ATTRIB.txt`: the ORDER-BLIND whole-dump diff of all nine moved databases
contains **nothing but those three sites** — 8 lines removed and 2 added per
site per copy, and every one of them named.

`CENSUS.txt`: over the nine databases, 20 cells to golden and nothing away.
Golden-vs-golden calibration is 0 differing keys on all five databases first.

`GRID.txt`: four arms × both views, **AWAY = 0 in all ten cells**, plus another
pass's arm (`r10svs3repro/a1_newlhs.sv`, written for
§ `thisSuperNewAssignNoStmt3`) whose ONE dotted `new[]` cell goes TO_GOLDEN
while its seven undotted / `this.` / `super.` siblings stay SAME.

## Residues

* **R0 (the new SeqDriver head, 17 cmp lines, both modes)** — `LHS: <null>`
  against `RHS: logic_net (work@top_tb.hdl_paths_pool) 1971:5-1971:19`,
  `vpiNetType:1`, parented on `module_inst work@top_tb`.  A SINGULAR-overload
  mismatch with our side present and golden's absent: we HOIST an implicit
  module-level net for a name golden never nets.  PRE-EXISTING (6 occurrences in
  the pristine database, 0 in golden) and the same family as SimpleUVM's and
  BuildUVMPkg's own 17-line heads — uvm109 is on the `work@top.rsp_export`
  mirror of it.  `head_after_SeqDriver_{default,testflags}.cmp` are the logs.
* **R-hier110** — a HIERARCHICAL receiver.  Golden collapses `P.IB = new [3];`
  (a2 e17, an interface-port member) and `D.dh.v = new [5];` (a3 f07, a
  cross-instance path) to `ref_obj(P)` / `ref_obj(D)` WITH the instance's
  `logic_net` as `vpiActual`; we keep the `hier_path`.  slang binds each of
  those as ONE `HierarchicalValueExpression` with no base subexpression to emit,
  so reaching them means SYNTHESISING a net-bound ref rather than reusing the
  ordinary lvalue path — and the interface family is a 41-test cluster.
  Deliberately fenced (`root110->kind != NamedValue` declines), no corpus witness.
* **R-genbind110 / R-prog110** — the collapsed ref's `vpiActual`, on two homes
  the corpus head does not exercise.  In a GENERATE scope golden binds the
  declaration's `class_var` and we bind nothing (a4 g16); in a PROGRAM golden
  binds NOTHING and we bind a hoisted `logic_net` (a4 g14).  Both cells were
  ALREADY differing before this pass — the KIND now agrees and only the actual
  does not — and R-prog110 is uvm108's R-prog108 (`a program initial reading a
  program-scope name is golden-BARE and we already over-bind it`), pre-existing
  on both binaries, seen here on a new shape.
* **R-static110 / R-pkgscope110** — a `::`-scoped receiver.  Golden emits NO
  STATEMENT AT ALL for `holderK::SHARED.m_byte_enable = new [1];` (a1 c18),
  `pkg110C::GLOBALARR110 = new [2];` (a3 f02) or
  `Boxz::STAT2.dyn2 = new [3];` (the verifier's `r10v110repro/v2a_scope.sv` c02);
  we emit a statement in all three.  CORRECTED BY THE VERIFIER: on the
  CLASS-scoped spelling the predicate DOES fire — slang binds the `::`-qualified
  base as a plain `NamedValue`, so the collapsed ref is emitted and the object's
  NAME changes, both views:
      golden    no statement
      pristine  `ref_obj (@@BAD_SYMBOL@@)`
      shipped   `ref_obj (SHARED)`
  It is NOT a regression: golden has no object, so neither name matches, and the
  enclosing statement-vector mismatch is identical in kind on both binaries —
  a1's shipped cmp head is exactly that `begin` block, and the pristine database
  carries the same extra statement.  A PACKAGE-scoped receiver
  (`Wk2::PKG_H2.dyn = new [4];`) does NOT change: both binaries differ from
  golden identically.  Neither shape is repaired here.
* **R-span110** — the collapsed ref is `setLoc`'d to the whole lvalue text, and
  golden agrees; but where the receiver ALSO mints a hoisted `logic_net` (a1
  c32, an out-of-body method's property), golden gives that NET the whole-lvalue
  span and we give it the base-name span.  NOT judge-visible (no generated
  `Compare` reads `VpiFile`/line/col); recorded because the span-exact census
  shows it.
* **R-newbind110** — an UNDOTTED `x = new(…)` lvalue where golden binds NOTHING
  and we bind a hoisted `logic_net` (SeqDriver `clear_hdl_path`, `configure`,
  `new`; SimpleUVM the same).  4 of the 5 SeqDriver census keys that still
  differ.  Pre-existing, untouched, and the nearest neighbour of R0.
* **R-fuaCast110 (found by the boundary, not by the law; NOT repaired)** —
  `src/TypeEmit.cpp:10359`, `auto& fua = ct.as<FixedSizeUnpackedArrayType>();`
  is an UNCHECKED slang `as<>` (a no-op under `NDEBUG`).  Two of its three call
  sites gate on `ct.kind == SymbolKind::FixedSizeUnpackedArrayType`
  (`UhdmExporter.cpp:3765`, `TypeEmit.cpp:10862`); the third,
  `TaskFuncEmit.cpp:3511`, gates only on the return typespec's UHDM kind, so a
  function returning a typedef'd ASSOCIATIVE array
  (`typedef C ka_t[string];`) reaches it with an `AssociativeArrayType` and
  `fua.range.width()` reads the object's `indexType` POINTER, which is emitted
  as the `array_typespec` range's `UINT`.  Golden has no such object.  Because
  the value is an ADDRESS it shifts for ANY layout change, which makes it a
  standing trap for every future wide boundary: PROVED here with a third binary
  built from PRISTINE `28f373a` plus one exported 4096-byte never-read symbol
  and no law, whose value moves by EXACTLY `0x1000`
  (`0x1559d79 -> 0x155ad79`, the same value the shipped binary gives).
  Repro: `tools/probe/r10buvm22repro/g22.sv:70-72`.
* uvm108's **R-idxbase108 / R-this108 / R-span108 / R-iface108 / R-prog108 /
  R-pkgevhoist108**, uvm106's **R1-import / R-class106 / R-func106 / R-ovsize /
  R-signdec**, uvm104's **R-args / R-esc / R-assoc** and MiniAmiq's 348-line
  head are unchanged by this pass.

## Files

`cen110.py` (the assignment-lvalue census; `PROJ=1` projects onto the
judge-visible axes and drops the span from the KEY as well as the value),
`join110.py` (multiset join, LHS always golden), `pred110.py` (the a-priori
mover predictor; the four fenced tests are skipped by the md5 of their names,
never spelled), `run110.sh` (three-way arm runner, rc per cell, BOTH views),
`score110.sh` (TO_GOLDEN / AWAY / LATERAL / STILL classifier),
`bnd110.sh` / `bshard110.sh` (the wide boundary, per-file and per-directory),
`attr110.sh` (order-blind attribution of every moved database),
`a1_shapes.sv` (35 cells: Rhs kinds, receiver declarations, dot depth, selects),
`a2_recv.sv` (20 cells: deeper chains, struct / interface / module receivers,
loop and branch homes), `a3_fence.sv` (16 cells: the `this.`/`super.` and
`::`-scoped fences, hierarchical receivers), `a4_homes.sv` (17 cells: one
in-law cell and one control per statement SLOT — constructor, fork, foreach,
case item, sole `if` branch, interface, program, generate),
`head_{before,after}_SeqDriver_{default,testflags}.cmp`,
`GATES.txt`, `CENSUS.txt`, `GRID.txt`, `BOUNDARY.txt`, `ATTRIB.txt`,
`PREDICT.txt`, and `canaries.sh` / `ctcan2.sh` / `canaudit.sh` (the battery,
run from this directory as `bash canaudit.sh canaries.sh ctcan2.sh`).
