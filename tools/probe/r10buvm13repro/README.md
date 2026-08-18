# r10buvm13 — § formalDefaultBindsLikeBody13 — **the BuildUVMPkg head cleared; a formal's DEFAULT VALUE is bound by the SAME window as the body**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `d3cfb2b` |
| worktree | `/tmp/wt_r10buvm13` |
| pristine binary | md5 `2b8635970f941564ca806cdf24baf450` |
| patched binary | md5 `ab712e768e23bdad71b15b34b28e70bc` |
| production surface | `src/TaskFuncEmit.cpp` ONLY — **119 added lines, 99 of them comment, 20 code** |
| probe surface | `tools/probe/r10buvm13repro/` only |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines.  What it does is clear the head buvm12
left as its residue R0, and with it the whole default-value BINDING family.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| head object | `io_decl(severity)@9560:40` < `function(uvm_pkg::uvm_report)@9560:1` / `RHS: <null>` | `hier_path(m_recur_states[lhs][rhs].exists)@21564:13` < `operation` / `RHS: <null>` (**R0**) |
| cmp lines | 29 / 29 | 140 / 140 — a BIGGER OBJECT, not more defects (see §8) |
| default-value ref cells agreeing with golden (BuildUVMPkg, location-blind) | 111 / 189 | **189 / 189** |
| the same, corpus-wide (surelog, 339 joined databases) | 1 432 agree / **706 DISAGREE** | 2 134 agree / **4 DISAGREE** |

Both modes' cmp logs are **byte-identical to each other** on both binaries
(`373f66ad06d7cf9f86913f362b95183c` patched), and the other ten cmp logs of the
seven-row head set are **byte-identical between the two binaries** (§7).

## 1. THE HEAD, DECODED — a SINGULAR `Actual_group`, and the brief's listing hypothesis REFUTED before any code

`LHS: io_decl(severity) … RHS: <null>`.  Read against `BaseClass.h`, that
spelling has exactly one producer.  The VECTOR `SafeCompare` sets
`m_failedLhs` **and** `m_failedRhs` to the two CONTAINERS on a size mismatch,
and sets `m_failedLhs` to the OWNER (`lhs_obj`) when the rhs vector is null:

```cpp
} else if ((lhs != nullptr) && !lhs->empty() && (rhs == nullptr)) {
  context->m_failedLhs = lhs_obj;            // <-- the FUNCTION, not an io_decl
```

So a short or missing `task_func::Io_decls()` would decompile the **function**.
It decompiles the **io_decl** with a null RHS, which only the SINGULAR overload
can produce — and the only singular field in the whole Compare walk whose value
can be an `io_decl` is `ref_obj::Actual_group()`
(`generated/src/ref_obj.cpp`, after `VpiName`/`VpiDefName`/`VpiGeneric`).

The dump says exactly that.  `uvm_pkg.sv:9560` is a **package free function**
whose 4th formal's default value reads the 1st formal twice:

```
function void uvm_report( uvm_severity severity, string id, string message,
                          int verbosity = (severity == uvm_severity'(UVM_ERROR)) ? UVM_LOW :
                                          (severity == uvm_severity'(UVM_FATAL)) ? UVM_NONE : UVM_MEDIUM,
                          ... );
```

```
golden                                                ours
\_io_decl: (verbosity) 9563:31                          \_io_decl: (verbosity) 9563:31
  |vpiExpr: \_operation: 9563:43                          |vpiExpr: \_operation: 9563:43
    |vpiOperand: \_operation: 9563:44                       |vpiOperand: \_operation: 9563:44
      |vpiOperand: \_ref_obj: (…::severity) 9563:44           |vpiOperand: \_ref_obj: (…::severity) 9563:44
        |vpiName:severity                                       |vpiName:severity
        |vpiActual:                                         <-- THE DEFECT: ABSENT ON OUR SIDE
        \_io_decl: (severity) 9560:40, endln:9560:48
```

**And the LISTING hypothesis is refuted a second time, by census rather than by
argument:** `IOV listing` (one row per `task_func`: io_decl COUNT, NAMES in
order, DIRECTIONS, and how many carry an Expr) is **AGREE 5 275 / DISAGREE 0**
on BuildUVMPkg and **AGREE 63 493 / DISAGREE 0** corpus-wide, *identically on
both binaries*.  Not one io_decl vector in either corpus is short or misordered.

## 2. THE CENSUS — and the ONE MEASUREMENT TRAP THAT WOULD HAVE FAKED 277 DEFECTS

`r10buvm13cen` reads a database out of `Serializer::AllObjects()` (never dump
TEXT) and prints one `DV` row per `ref_obj` inside an io_decl's DEFAULT VALUE —
owner task_func, formal index and name, ref name and span, whether it carries
`vpiActual` and of what KIND and NAME, the owner's home, `vpiMethod`, and
whether the named thing is an EARLIER formal — plus one `IOV` row per
`task_func` listing.

**THE OWNER WALK IS NOT A PARENT WALK, and it must not be.**  Our emitter builds
a default value with a NULL parent (`emitExpr(*dv, nullptr, …)`), so the TOP
node of the expression has no `vpiParent` and an upward walk from a ref inside
it never reaches the io_decl; Surelog parents it at the io_decl.  The walk
therefore climbs `vpiParent` **and probes a map of every io_decl EXPRESSION ROOT
at each step**, so both producers' cells are found.

**THE VIEW MUST BE TAKEN FROM THE OWNER, NOT FROM THE REF**, for the same
reason.  The first join, keyed on `viewOf(ref)`, reported `AGREE=2
ARITY-DIFF=277`: every one of our cells landed in an `OTHER` bucket because the
climb from the ref died at the unparented top, so all three views' copies
collided into one key.  **277 spurious defects, in a pure binding census, from
one field of the key.**  Fixed, and the fix is the calibration's job to prove.

**CALIBRATION FIRST, golden against golden** (BuildUVMPkg):
`IOV AGREE=5275 / DV AGREE=189 / DISAGREE 0` under both keyings.  A join that
cannot report zero on identical inputs cannot report 78 on different ones.

BuildUVMPkg, golden vs ours, **location-blind** (`BaseClass::Compare` reads
`VpiType`/`VpiName`/`VpiDefName` **only** — location is not a field the judge
can see, so the strict key's 86 `ARITY-DIFF` are a separate, invisible family):

| class | pristine | patched |
|---|---|---|
| AGREE | 111 | **189** |
| **DISAGREE** | **78** | **0** |

and the 78 SEPARATE PERFECTLY, in **two opposite directions**, on ONE property
of the OWNER — is it an IN-CLASS listing?

| owner | cells | golden | ours (pristine) |
|---|---|---|---|
| package free function, ref names an EARLIER FORMAL | **4** | `vpiActual -> io_decl` | **absent** |
| IN-CLASS listing (in-body method, `extern` prototype, `pure virtual`), ref names an ENUM CONSTANT | **74** | **bare** | `vpiActual -> enum_const` |
| package free function / out-of-body definition, enum constant | 102 | bound | bound (already right) |
| in-class listing, earlier formal | 4 | bare | bare (already right) |

Both halves are ONE defect with ONE cause: the default value was emitted
**outside the subroutine's binder window** — with an EMPTY map (so no formal
could ever bind) and with `classMethodNoBind` NOT in force (so an enum constant
always did).

## 3. DECODED FROM THE PRODUCER

`CompileHelper::compileTfPortList` (`CompileStmt.cpp:1824`) compiles the default
with the io_decl as the parent object and **no** `pexpr`:

```cpp
if (any* defvalue = compileExpression(component, fC, expression, compileDesign,
                                      Reduce::No, decl, nullptr))
  decl->Expr(defvalue);
```

Nothing is bound there.  Every name comes out an unresolved `ref_obj` on the
component's `getLateBinding()` list, and `UhdmWriter::lateBinding`
(`UhdmWriter.cpp:3293`) resolves it in the WRITE phase by walking the ref's
**`VpiParent` CHAIN** — which for a default value runs
`ref -> operation(s) -> io_decl -> task_func`, so the `uhdmfunction` /
`uhdmtask` arm fires and matches the name against `func->Io_decls()`:

```cpp
} else if (parent->UhdmType() == uhdmfunction) {
  ...
  if (auto decls = func->Io_decls()) {
    for (auto decl : *decls) {
      if (decl->VpiName() == name) { ref->Actual_group(decl); break; }
```

That is the whole mechanism, and it is the same list the BODY's refs are
resolved against — which is why the law is "**binds like the body**" and not a
new rule.

## 4. THE LAW

> **§ formalDefaultBindsLikeBody13** — a formal's DEFAULT VALUE expression is
> bound by the **SAME binder window as the subroutine's own BODY**: its refs see
> the subroutine's own formals (the io_decls built so far, in declaration
> order), and the whole expression is silenced by `classMethodNoBind`
> (`classScope && !oob`) and by `unitSubNoBind9`, exactly as `emitTaskFuncs`
> sets them around `emitStmt(sub.getBody())`.
> **…with ONE fence: a WILDCARD-IMPORT CLONE binds nothing.**

### STATED GATE == CODE GATE

**STATED:** one `NetMap` (`dvFormals13`) filled in DECLARATION ORDER as each
io_decl is built; the emission site saves/restores `classMethodNoBind` and
`unitSubNoBind9` and sets them to the body's own values; a `pure virtual`
prototype (a second emission site, § `pureVirtIoDecls30`'s) sets
`classMethodNoBind = true` unconditionally, because the keyword exists only
inside a class and has no out-of-body form; and a wildcard-import clone gets an
EMPTY map.

**CODE:** `git diff` vs `d3cfb2b` — **119 added lines, 99 comment, 20 code**, in
`src/TaskFuncEmit.cpp` alone.  The whole of it:

```cpp
        NetMap dvFormals13;                          // next to funcMap
...
                dvFormals13[arg] = io;               // the no-typespec branch
...
            dvFormals13[arg] = io;                   // the normal branch
...
                    NetMap noBind13;
                    bool savedCMNB13 = classMethodNoBind;
                    bool savedUSNB13 = unitSubNoBind9;
                    classMethodNoBind = classScope && !oob;
                    if (auto* usc13 = sub.getParentScope())
                        unitSubNoBind9 = usc13->asSymbol().kind ==
                                         SymbolKind::CompilationUnit;
                    auto* de = emitExpr(
                        *dv, nullptr, fullName,
                        (pkgImportCloneEmit || importCloneEmit) ? noBind13
                                                                : dvFormals13);
                    classMethodNoBind = savedCMNB13;
                    unitSubNoBind9 = savedUSNB13;
...
                            bool savedCMNB13p = classMethodNoBind;   // pure virtual
                            classMethodNoBind = true;
                            ...
                            classMethodNoBind = savedCMNB13p;
```

`§ noDirNamedTypeDefaultDropped30` (WHETHER a default is emitted at all),
`§ formalRealDefaultRawValue30` (its `vpiValue` for a real literal),
`§ pureVirtIoDecls30` / `§ pureVirtIoRanges34` /
`§ pkgContainerTdFormalListing34` (the io_decl LISTING, ranges and typespecs)
all still run untouched, and the census proves it: the `IOV` listing figures are
**identical between the two binaries on both corpora**.

### the gates that were REFUTED, each on a grid arm or on the census

| candidate gate | refuted by |
|---|---|
| "the `Io_decls` vector is short or misordered" (the brief's first branch) | §1 — the vector `SafeCompare` cannot decompile an ELEMENT with a null RHS, and the `IOV` census is `DISAGREE 0` on 63 493 listings |
| "the io_decl's own field (`Expr` / `Typespec` / `VpiDirection`) differs" (the brief's third branch) | §1 — those are compared BEFORE `Expr`'s subtree and `io_decl(severity)` (Io_decls[0]) had already compared EQUAL |
| "the default value binds nothing anywhere" (the pristine behaviour) | arm v1 `pf_earlier`/`pt_earlier`, v2 `mf_*`/`mt_earlier`/`ifb_earlier`, v3 `p13home::*` — golden binds |
| "it binds everywhere" | arm v1 `m_enumi` / `x_enumi`@proto / `v_enumi`, v2 `cm_earlier`/`cx_earlier`@proto — golden is BARE in every IN-CLASS listing |
| "an out-of-body definition is a class method for this purpose" | arm v1 `c13::x_earlier`@def, v2 `cm13::cx_earlier`@def — golden BINDS (`!oob`) |
| "a `pure virtual` behaves like a package function because it has no body" | arm v1 `v13::v_enumi` — golden is BARE; this is the second code site |
| "an INTERFACE is fenced out" | arm v2 `ifb_earlier`/`ifb_net` in an **INSTANTIATED** interface — golden BINDS; the bare `if13` cells are an ELABORATION artefact, not a rule (**R2**) |
| "a DEFINITION-VIEW component is fenced out" | arm v2 `m13_unused2` (an uninstantiated module **with ports**, which slang cannot auto-top) — golden BINDS |
| "a wildcard-import CLONE is just another package function" | **the corpus refuted this AFTER the first patched sweep** — see §6 |

## 5. THE GRID — three arms, 82 golden cells, **0 OVER-FIRE**

`grid13.sh` is the three-way cell table (golden / pristine / patched).  Surelog
and BOTH binaries run in the SAME directory (a UHDM database records the source
file's ABSOLUTE path — buvm8's `bndarms` trap).  The cell is
`<view>:act<0|1>-><actual kind>(<actual name>)`; the actual is spelled by KIND
and NAME and never by address or location, because location is not a field
`Compare` reads.  **BOTH keyings are printed** — strict, and LOCATION-BLIND,
which is the one that maps onto `uhdm-cmp`.

| arm | what it varies | golden cells | verdict (location-blind) |
|---|---|---|---|
| `v1_site13` | package free function / task, IN-BODY method, `extern` PROTOTYPE listing, its OUT-OF-BODY DEFINITION, `pure virtual`; defaults naming an EARLIER FORMAL, an ENUM CONSTANT, a package VAR / PARAMETER / LOCALPARAM, and a CALL | 37 | **CONVERTED 8, OVER-FIRE 0** |
| `v2_reach13` | MODULE function/task, `$unit` function, UNinstantiated INTERFACE, INSTANTIATED interface, UNinstantiated module with and without ports, class-in-a-module; refs in OPERAND / CALL-ARG / CONCAT / INDEX position; module NET and VAR | 24 | **CONVERTED 8, OVER-FIRE 0** |
| `v3_clone13` | the WILDCARD-IMPORT CLONE fence, home copy against clone copy of one text | 8 | **CONVERTED 2, OVER-FIRE 0**, all six clone cells `same` |

**18 CONVERTED, 0 OVER-FIRE, 0 MOVED-STILL-WRONG (location-blind).**  Cells
worth naming:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| v1 `pf_earlier` / `pt_earlier` | package `function/task (int a, int b = a)` | `act1->io_decl(a)` both views | `act0` | **= golden** |
| v1 `pf_mix` | `int b = a + PK13 + LK13` | `act1->io_decl(a)` | `act0` | **= golden** (the two params are a different family, R3) |
| v1 `c13::m_enumi` | IN-BODY method `int v = E13_B` | **bare** | `act1->enum_const` | **= golden** |
| v1 `c13::x_enumi` @proto | `extern` PROTOTYPE listing | **bare** | `act1` | **= golden** |
| v1 `c13::x_earlier` @def | its OUT-OF-BODY DEFINITION | `act1->io_decl(a)` | `act0` | **= golden** |
| v1 `v13::v_enumi` | `pure virtual … (int v = E13_B)` | **bare** | `act1->enum_const` | **= golden** (code site 2) |
| v1 `u13_earlier` (v2) | `$unit`-scope function | **bare** | bare | unchanged — the FENCE (`unitSubNoBind9`) |
| v2 `mf_arg`/`mf_concat`/`mf_idx` | the same ref in CALL-ARG / CONCAT / INDEX position | `act1->io_decl(a)` | `act0` | **= golden** |
| v2 `ifb_earlier` | INSTANTIATED interface function | `act1->io_decl(a)` | `act0` | **= golden** |
| v2 `m13_unused2.uf2_earlier` | UNinstantiated module WITH PORTS | `act1->io_decl(a)` | `act0` | **= golden** |
| v2 `if13.if_earlier` | UNinstantiated INTERFACE | **bare** | bare | unchanged — **R2** |
| v2 `mf_net` / `mf_var` / `ifb_net` | a default naming a module NET or VAR | `act1->logic_net` | `act0` | unchanged — **R1** |
| v3 `p13home::hf_earlier` | the HOME package copy | `act1->io_decl(a)` | `act0` | **= golden** |
| v3 `p13imp::hf_earlier` | the WILDCARD-IMPORT CLONE of the same text | **bare** | bare | unchanged — the FENCE |

The three `MOVED-STILL-WRONG` cells the STRICT keying still reports were run
back object by object and every one is RIGHT: for `c13::x_earlier` our two
objects read `meth=1 -> act0` (the prototype listing) and `meth=0 -> act1` (the
definition), exactly golden's pair; they collide only because our prototype
listing writes its default expression at the DEFINITION's `line:col` (R4) and,
in v2, because we spell a class-in-a-module's out-of-body definition
`work@m13::cm13::` where Surelog writes `work@m13.cm13::` (a fullname family;
`VpiFullName` is not a field `Compare` reads).

`detcheck.sh`, 3 runs of the patched binary on each arm: **1 distinct hash, 0
NO_OUTPUT** (the map is keyed by a slang symbol POINTER and is only ever looked
up, never iterated).

## 6. THE CORPUS REFUTED THE FIRST GATE — the WILDCARD-IMPORT CLONE

The first patched sweep passed every row gate and every canary, and the
corpus-wide census still reported **20** residual disagreements where the
BuildUVMPkg census reported **0**.  Sixteen of them were **pristine-right ->
patched-wrong**, i.e. an OVER-FIRE that no arm had:

```
MiniAmiq  DEF+ELAB  svaunit_pkg::uvm_report  verbosity  ref severity   G act=0   P act=1
SeqDriver DEF+ELAB  adpcm_pkg::uvm_report    verbosity  ref severity   G act=0   P act=1
```

**Golden disagrees with ITSELF about two copies of one text.**  MiniAmiq's
golden holds `uvm_pkg::uvm_report` — the HOME copy — with
`vpiActual -> io_decl(severity)` on both refs in both views, and
`svaunit_pkg::uvm_report` — the copy the wildcard import materialises — with
none, on either ref, in either view.  Surelog's clone is a `clone_tree` copy
made in the WRITE phase, so its refs were never on the importing component's
`getLateBinding()` list and `lateBinding` never sees them.  Our clone already
left the ENUM CONSTANTS of the same expression bare, so the fence restores the
clone to the one behaviour it already had rather than inventing a new one.

`v3_clone13.sv` was then written so the fence is a WITNESS and not only a
corpus reading, and it reproduces golden's self-disagreement cell for cell.

**This is why the corpus-wide census is a gate and not a garnish: one row's
census said `DISAGREE 0` while the corpus said 16 cells had gone backwards.**

## 7. RESIDUES, each measured and left deliberately

* **R0 — THE NEW HEAD.**  `hier_path(m_recur_states[lhs][rhs].exists)@21564:13`
  under `operation@21564:12` inside `uvm_comparer::object_compared`,
  `RHS: <null>`, both modes, byte-identical between them.  A `hier_path`
  `Actual_group` / `Path_elems` family (the ladder counts 18 more `hier_path`
  rungs behind it), pre-existing, and nothing to do with formal defaults.
* **R1 — a default naming a module/interface NET or VAR.**  Golden binds
  (`mf_net -> logic_net`, `mf_var -> logic_net`, `ifb_net -> logic_var`,
  `uf_net`, `uf2_net`) and we do not.  `lateBinding` walks one level FURTHER up
  the parent chain than the `uhdmfunction` arm.  **Corpus population: ZERO** —
  every one of the 2 138 corpus cells names a formal, an enum constant, a
  package var or a parameter — which is exactly why the law carries a
  formals-only map rather than `funcMap` (which starts life holding the
  enclosing module's nets and would have moved cells no census predicted).
* **R2 — the UNinstantiated INTERFACE.**  Golden leaves `if13.if_earlier` and
  `if13.if_param` bare while the INSTANTIATED `if13b`'s identical cells bind,
  and an UNinstantiated MODULE (ported or not) binds: Surelog never runs
  `lateBinding` on a component it never elaborates.  We agree there by
  construction (our uninstantiated-interface formals are not the symbols the
  default expression refers to), so it costs no cell — but our own
  uninstantiated-interface ENUM cell (`if_enumi`) is an over-bind we ALREADY
  had, unchanged by this pass.
* **R3 — a default naming a PARAMETER.**  Golden emits a `ref_obj` with
  `vpiActual -> constant` in a package and a BARE `ref_obj` in a module; we FOLD
  the reference away and emit the constant itself.  A `ParamEmit` fold family
  (`pf_param`, `pf_local`, `mf_param`, `mf_local`), zero cells in either
  corpus's census because we emit no ref there at all.
* **R4 — the io_decl-LOCATION family.**  An `extern` prototype's own io_decls
  carry the DEFINITION's `line:col` on our side.  `784` `ARITY-DIFF` keys under
  the strict census keying, **identical on both binaries**, and NOT cmp-visible
  (`BaseClass::Compare` reads `VpiType`/`VpiName`/`VpiDefName` only).
* **R5 — `uvm_phase::get_predecessors_for_successors`.**  The whole residual
  corpus disagreement: **4 cells** (SeqDriver + SimpleUVM x 2 modes) where the
  formal `pred_of_succ`'s default names `uvm_phase` and golden binds a
  `logic_net` called `uvm_phase`.  A class-name-shaped cell of its own; not
  this family, and pre-existing.

## 8. WHY THE `uhdm-cmp` LINE COUNT ROSE, 29 -> 140, AND WHY IT IS NOT A REGRESSION

`uhdm-cmp` prints ONE head and decompiles it.  A head's line count is the SIZE
OF THAT OBJECT'S DECOMPILE, not a defect count: the old head was a 4-field
`io_decl`, the new one a `hier_path` with three `Path_elems` each carrying a
nested `ref_obj` and its actual.  **Heads: 1 -> 1, both modes, both binaries.**

The same caution applies to the ladder, and it is stated rather than hidden.
`tools/probe/r10ladder1repro/ctladder` (measurement only; `uhdm-cmp` is the
judge), BuildUVMPkg/default, calibration on this pass's golden against itself
**0 rungs on 183 142 objects**:

| | pristine | patched |
|---|---|---|
| rungs (fixpoint) | **166** | **210** |
| masks / cascades | 196 / 68 | 240 / 99 |
| secs | 39.3 | 28.2 |

The rung total ROSE, and the reason is in the pristine ladder's own rung 1:

```
RUNG 1 … KINDL=io_decl KINDR=<null> SHAPE=MISSING-OURS
   MK function(uvm_report)@uvm_pkg.sv:9560:1  [CASCADE: this mask hides >=1% of the golden database for every later rung]
```

To continue past that head the ladder had to MASK the whole
`function(uvm_report)` object, suppressing everything under it for every later
rung.  The patched ladder never masks it (`grep -c 'function(uvm_report)'` over
the `MK` lines: pristine **1**, patched **0**), so `uvm_report` is COMPARED
instead of hidden and objects that were suppressed become visible.  **The rung
set is not comparable across a change that removes a CASCADE mask**, which is
why the family-specific census — not the rung count — is this pass's verdict.
The ladder's own `io_decl|<rhs-null>|MISSING-OURS` family still went 9 -> 8 and
`<null>|<lhs-null>|EXTRA-OURS` 25 -> 21.

## 9. THE CORPUS-WIDE CENSUS, golden vs ours, on BOTH binaries

`cenall13.sh` runs the join over every database of a sweep workdir, reading each
test's golden out of its OWN `cmds.txt`.  `SKIP` (no golden or no database) is
COUNTED and printed, never hidden, and the number of `==` headers is asserted
against the number of joins actually reported (buvm12's lost-577-joins trap).

**surelog — 956 databases, 339 with both sides (617 SKIP)**

| class | pristine | patched | delta |
|---|---|---|---|
| DV LOCATION-BLIND **AGREE** | 1 432 | **2 134** | **+702** |
| DV LOCATION-BLIND **DISAGREE** | **706** | **4** | **−702** |
| DV LOCATION-BLIND `ARITY-DIFF` | 10 | 10 | 0 |
| DV strict-keyed DISAGREE | 324 | **0** | −324 |
| DV strict-keyed `ARITY-DIFF` (R4) | 784 | 784 | 0 |
| **`IOV` listing AGREE** | **63 493** | **63 493** | **0** |
| **`IOV` listing `ARITY-DIFF`** | **722** | **722** | **0** |

**uhdm2rtlil — 1 358 databases, 1 254 with both sides (104 SKIP): `IOV` AGREE
12 810, and ZERO `DV` cells at all** — the corpus contains no formal default
value holding a reference.  A strict no-op, identical on both binaries, exactly
as `predict13.sh` said before the fact.

## 10. THE MOVERS, PREDICTED BY NAME BEFORE ANY BYTE WAS COMPARED

`predict13.sh` reads ONLY the PRISTINE databases (never the patched ones, never
golden).  Both directions have an exact UHDM shadow: *in-class listing* is
`vpiParent` a `class_defn` **and** `vpiMethod == 1` (an out-of-body definition
carries `vpiMethod 0`; the ELAB view MOVES the definition into the `class_defn`,
so the parent test alone would read every out-of-body body as in-body — buvm12's
lesson, reused).

* **CAND A** (GAIN) — a default-value ref naming an EARLIER FORMAL, currently
  unbound, owner NOT an in-class listing.
* **CAND B** (LOSE) — a default-value ref that currently carries an actual and
  whose owner IS an in-class listing.
* **CAND C** — the CONTROL, not a prediction: every other bound default-value
  ref.  Any CAND C object that moves is an over-fire.

| corpus | databases | CAND A | CAND B | CAND C | predicted MOVER databases |
|---|---|---|---|---|---|
| uhdm2rtlil | 1 358 | **0** | **0** | **0** | **0** |
| surelog | 956 | **52** | **684** | 905 | **9** |

```
44 CANDA+CANDB {default,testflags}/BuildUVMPkg   84 {default,testflags}/MiniAmiq
84 {default,testflags}/SeqDriver                 80 {default,testflags}/SimpleUVM
80 default/Scoreboard
```

Those **9 databases are EXACTLY the 9 byte movers** gate 5 then found, and the
u2r prediction of ZERO is exactly its 0 movers.  CAND A is an UPPER BOUND by
construction — the UHDM shadow cannot see `pkgImportCloneEmit`, so MiniAmiq and
SeqDriver each predict 8 where 4 move (the clone fence, §6); CAND B is an upper
bound for the same reason and 76 predicted / 74 moved per database.  **0 CAND C
objects moved.**

## 11. THE FIVE GATES

| # | gate | result |
|---|---|---|
| 1 | build BOTH binaries, `-j 2`, md5 separately | pristine `2b8635970f941564ca806cdf24baf450`, patched `ab712e768e23bdad71b15b34b28e70bc`.  The deliverable was applied to a THIRD, untouched `d3cfb2b` worktree (`git apply --check` clean) and built from scratch: md5 **`ab712e768e23bdad71b15b34b28e70bc`** — the patch reproduces, bit for bit, the binary every reading above was taken with. |
| 2 | `tests/check_goldens.sh` + negative control | **23** PASS on the pristine, the patched AND the from-scratch reproduction; `SLANG_UHDM=/bin/false` -> **0** PASS.  `SLANG_UHDM` exported explicitly to EACH binary. |
| 3 | uhdm2rtlil, both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in each mode on each binary.  `ct13rows.sh`: pristine `testflags` vs the COMMITTED `results/gate_uhdm2rtlil.csv` = **0 differing ROWS** over 731 (**BASELINE FIRST**); patched vs the same = **0**; pristine vs patched over all 1 462 = **0** (status AND dump column). |
| 4 | Surelog suite, `--mode both` | `ct13rows.sh` patched vs the COMMITTED `results/golden_surelog.csv` = **0 differing rows** over 1 588; pristine vs the same = **0**; pristine vs patched = **0**.  Status and dump histograms identical.  **NO ROW CONVERTED — `BuildUVMPkg` stays `CMP_NOTEQUAL` in both modes, `Earlgrey_0_1/testflags` stays `CMP_NOTEQUAL`, and `results/*.csv` were not touched.** |
| 5 | `byteverify.sh SELFCHECK=1 SELFCHECK1=1` | surelog **9 / 956** movers, u2r **0 / 1 358**.  Controls: 955/956 + `SELFCHECK1`=10 (1 corruption + the 9 movers), and 1357/1358 + `SELFCHECK1`=1. |

Every mover attributed by `attrib13.sh` (census delta on the law's own field +
a whole-dump path-normalised diff, judged ORDER-BLIND):

| database | census GAINED / LOST | dump RAW | dump ORDER-BLIND | verdict |
|---|---|---|---|---|
| `{default,testflags}/BuildUVMPkg` | 4 / 74 | +8 / −148 | shallow +4/−74, marker net −70, other 0 | **ATTRIBUTED** (predicted) |
| `{default,testflags}/SeqDriver` | 4 / 74 | +8 / −148 | same | **ATTRIBUTED** (predicted) |
| `{default,testflags}/SimpleUVM` | 4 / 74 | +8 / −148 | same | **ATTRIBUTED** (predicted) |
| `{default,testflags}/MiniAmiq` | 4 / 74 | +8 / −148 | shallow +4/−74, marker +1/−71 (net −70), other 0 | **ATTRIBUTED** (predicted) |
| `default/Scoreboard` | 4 / 74 | +8 / −148 | same | **ATTRIBUTED** (predicted) |

`-- databases NOT ATTRIBUTED: 0`.

> **THE LINE MODEL IS NOT "2 LINES PER MOVED BIND", AND ASSUMING IT WAS FAILED
> ALL NINE.**  A bind prints a MARKER line (`|vpiActual:`) and a SHALLOW target
> line.  The order-blind diff is a MULTISET diff of line TEXT, so the gained and
> lost MARKERS cancel and only the net survives; the shallow lines do not.  The
> assertion is `shallow-added == GAINED`, `shallow-removed == LOST`,
> `marker-removed − marker-added == LOST − GAINED`, `other == 0`.  The first run
> also handed `comm` files sorted under `LC_ALL=C` while `comm` itself collated
> in the ambient locale — it printed "file is not in sorted order" on stderr and
> returned numbers that still looked like numbers (`GAINED=21 LOST=78` instead of
> `4 / 74`).  Both fixed; every figure above is from the fixed script.

### the canary battery, all pristine-vs-patched

| check | result |
|---|---|
| `canaries.sh` on the surelog CSVs (patched vs pristine AND patched vs COMMITTED) | `ok=52 changed=0 absent=0` both, 7 expected unknown names (the u2r-only canaries) |
| `canaries.sh` on the u2r CSVs | `ok=16 changed=0 absent=0`, 25 expected unknown names |
| `ctcan2.sh` surelog (`EXPECT_UNKNOWN=1`) / u2r (`EXPECT_UNKNOWN=6`) | `ok=58 changed=0` / `ok=2 changed=0` — **PASS** both |
| `canaudit.sh canaries.sh ctcan2.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0`, both self-tests live |
| `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` | **byte-identical** in both modes (md5s printed, not merely absent from the mover list) |
| `SVSwitch` md5 pin | **`4842211c4030`** on the PATCHED binary, both modes |
| `YosysVerx` md5 pin | **`6ccda350c24a`** on the PATCHED binary, both modes |

### the SEVEN-ROW HEAD SET, both binaries, out of the FULL sweep workdirs

| row | mode | pristine | patched | cmp log |
|---|---|---|---|---|
| `BuildUVMPkg` | default, testflags | 29 / 1 | **140 / 1** | the head MOVED (§ THE HEADLINE, §8) |
| `SeqDriver` | default, testflags | 96 / 1 | 96 / 1 | **BYTE-IDENTICAL** (its database moved; its cmp log did not) |
| `SimpleUVM` | default, testflags | 96 / 1 | 96 / 1 | **BYTE-IDENTICAL** (same) |
| `Scoreboard` | default | 96 / 1 | 96 / 1 | **BYTE-IDENTICAL** (same) |
| `MiniAmiq` | default, testflags | 96 / 1 | 96 / 1 | **BYTE-IDENTICAL** (same) |
| `Earlgrey_0_1` | default / testflags | 29 / 1, 33 / 1 | 29 / 1, 33 / 1 | **BYTE-IDENTICAL** |
| `Rggen` | default | 66 / 1 | 66 / 1 | **BYTE-IDENTICAL** |

`Scoreboard testflags` and `Rggen testflags` print SKIP-NOFILE and are COUNTED,
not hidden.  **ONE head per run on every measured row.**

### the boundary gate

`bndsub13.sh` over **582** arm sources — `r10buvm3..12`, `r10oth8`, `r10oth9`,
`r10svs6`, `r10sd8..12`, `r10uvm80`, `r10uvm82..88` (subdirectory arms included,
buvm9's lesson; the list travels on fd 3 with children `</dev/null`, buvm10's
lesson) — on both binaries:

```
-- arms PROCESSED=582 IDENTICAL=576 MOVED=0 REJECT-BOTH=6 ONE-SIDE=0
```

**ZERO arms moved**, so no boundary law's cell needed re-adjudicating.  The
laws named in the brief — the `io_decl` emission and DEFAULT-VALUE laws
(§ `noDirNamedTypeDefaultDropped30`, § `formalRealDefaultRawValue30`,
§ `pureVirtIoDecls30`, § `pureVirtIoRanges34`,
§ `pkgContainerTdFormalListing34`, § `bareFormalTsReached`,
§ `pkgRetTopCallArgFormalTs8`), the ARGUMENT-LIST laws
(§ `namedTfArgsFormalSlots4`, § `namedMethodArgsWritten4`,
§ `writtenCallArgs16`), the ref-ACTUAL gating laws
(§ `pkgVarBindsOnlyThroughInstance88`, § `inheritedNameBindsPkgFn72`,
§ `controlBodyNoBind28`, § `classInBodyRecvCallArgNoBind52`,
§ `blkLocalSameCtrlDepthWindowBinds64`, sd10/sd12 `scopedReach`/`scopedOrder`)
and uvm81's formal contest are all in those 576 IDENTICAL arms.  This law moves
**one** field, `ref_obj::Actual_group()`, and only for a ref inside an
`io_decl::Expr()`; it changes no listing, no argument list, no span, no name and
no typespec, and the census proves it corpus-wide (`IOV` figures identical
between the binaries on both corpora).

## 12. reproduce
```sh
./build13.sh                                              # the census instrument
/tmp/r10buvm13cen <golden.uhdm> G > g.cen                 # census golden ...
/tmp/r10buvm13cen <ours.uhdm>   P > p.cen                 # ... and ours
./cenjoin13.py g.cen p.cen 60                             # the join (both keyings)
./cenjoin13.py g.cen <(sed 's/^\(IOV\|DV\|ORPH\|SUMMARY\) G /\1 P /' g.cen)   # the CALIBRATION
./cenall13.sh <workdir> /tmp/cen.txt                      # the corpus-wide census
VERBOSE=1 PRISTINE=<d3cfb2b bin> PATCHED=<patched bin> ./grid13.sh v1_site13.sv   # ... v2, v3
./allsweeps13.sh                                          # four sweeps, one at a time, --jobs 2
./predict13.sh /tmp/r10buvm13_wds_pristine                # PREDICT FIRST
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh /tmp/r10buvm13_wds_patched /tmp/r10buvm13_wds_pristine
./attrib13.sh <patched wd> <pristine wd> <rel>/slang.uhdm ...
./ct13rows.sh <baseline.csv> <fresh.csv>
./canaries.sh <fresh.csv> <baseline.csv>; EXPECT_UNKNOWN=<n> ./ctcan2.sh ...
bash canaudit.sh canaries.sh ctcan2.sh
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
./detcheck.sh <bin> 3 <arm>.sv
PRISTINE=... PATCHED=... ./bndsub13.sh < <list of ABSOLUTE arm paths>
```

---

# VERIFIER ADDENDUM — r10buvm13 adversarial verification (worktrees `/tmp/wt_vbuvm13`, `/tmp/wt_vbuvm13pris`)

**VERDICT: ACCEPT WITH A FIX.**  Every headline number above reproduced
bit-for-bit from independently built binaries.  Seven new arms (`a1`..`a7`, 196
golden cells) then broke the shipped law in **three** places, all of them
**pristine-right → patched-wrong on legal SystemVerilog**.  The fix is 1 code
predicate in `src/TaskFuncEmit.cpp` at the same site, and it is a **strict
byte no-op on both corpora** (0 movers against the shipped patch over 956 + 1 358
databases) while closing all 12 measured over-fire cells.

## What reproduced, bit for bit

| | shipped claim | verifier measurement |
|---|---|---|
| pristine md5 | `2b8635970f941564ca806cdf24baf450` | **same** |
| shipped-patched md5 | `ab712e768e23bdad71b15b34b28e70bc` | **same** |
| goldens pristine / patched / `/bin/false` | 23 / 23 / 0 | **same** |
| u2r both modes | 679 / 50 / 2 | **same**, both binaries |
| surelog rows vs COMMITTED | 0 differing over 1 588 | **same**, both binaries; pristine-vs-patched 0 |
| corpus census pristine (DV loc-blind) | AGREE 1 432 / DISAGREE 706 | **same** (956 tests, 617 SKIP, 339 joined) |
| corpus census patched | AGREE 2 134 / DISAGREE 4 | **same**; strict DISAGREE 324 → 0; `IOV` 63 493/722 unchanged |
| mover prediction | CAND A 52 / B 684 / C 905 → 9 dbs | **same**, the same 9 names |
| byteverify | surelog 9/956, u2r 0/1358, controls 955+10 / 1357+1 | **same** |
| attribution | 4 gained / 74 lost, other 0, NOT ATTRIBUTED 0 | **same**, all 9 |
| boundary gate | 582 / 576 / 0 / 6 / 0 | **same** |
| canaries / ctcan2 / canaudit | 52+16 / 58+2 / 29,0,0 | **same** |
| pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **same** |
| heads | BuildUVMPkg 29/1 → 140/1, ten other logs byte-identical, cmp md5 `373f66ad06d7cf9f86913f362b95183c` | **same** |

Two **reporting inaccuracies**, both harmless to the verdict: the grids report
`MOVED-STILL-WRONG=4` under the strict keying (README says three) and **`=1`
under the LOCATION-BLIND keying** (README says zero) — `v2`'s
`work@m13::cm13::cx_earlier`, which is the pre-existing `work@m13.cm13::` vs
`work@m13::cm13::` FULLNAME family, per-object bind identical to golden.

## THE THREE HOLES, each measured on a purpose-built arm

**1 — an IN-CLASS listing whose default value holds a CALL** (`a3_window13`,
`a1`, `a2`).  `classMethodNoBind`'s silence is LIFTED inside a user call's
argument list (`ExprEmit`'s gate reads `classMethodNoBind && classArgBindDepth12
== 0`, § classArgBind12), and a default value may hold a call.  **12 over-fire
cells**: `r3(a)`, `r3b(a,a)`, `r3(r3(a))`, `r3(a+1)`, `helper(a)`, `int'(r3(a))`,
`(a>0)?r3(a):0` in an in-body method, the same in a NESTED class, the `extern`
PROTOTYPE listing's ELAB copy — golden bare, pristine bare, shipped patch bound.
A CONCAT argument (`r3({a,a})`, which `ClassArgBindOff12` zeroes) and a SYSTEM
call (`$bits(a+1)`) never open the window and were already right.

**2 — the EXPLICIT (non-wildcard) IMPORT CLONE** (`a4_clone13`, `a5_unit13`).
`import p::f;` re-emits the subroutine through the same `emitTaskFuncs` with
`importCopyTsInst` set and **`pkgImportCloneEmit` FALSE**, so the shipped fence
(`pkgImportCloneEmit || importCloneEmit`, which names only ParamEmit's two
WILDCARD arms) never saw it.  Golden leaves `pe4::hf_earlier` /
`pex5::hf_earlier` / `pex5::ht_earlier` BARE in both views, pristine agreed, the
shipped patch bound them.

**3 — a `$unit`-scope CLASS's OUT-OF-BODY definition** (`a5_unit13`, `a4`).
`unitSubNoBind9` was read off the SUBROUTINE's own parent scope, which for an
out-of-body definition is the CLASS, so every `$unit` class method missed the
fence.  Golden leaves `gc5::gx_earlier`, `gx_call` and `gx_enumi` bare;
the shipped patch bound them.  A class in a MODULE or a PACKAGE still binds in
its out-of-body definition (`v2` `cm13::cx_earlier`, `a2` `pc2::p_x`).

## THE FIX (verifier, `src/TaskFuncEmit.cpp`, one site)

The map is **WITHHELD**, not merely silenced, wherever golden binds nothing —
which reproduces the pristine emitter cell for cell in exactly those places:

```cpp
bool inClass13 = classScope && !oob;          // in-body method / extern proto
bool unitSub13 = <parent scope, walking OUT through enclosing CLASSes,
                  is a CompilationUnit>;      // $unit reach
bool noBindDv13 = inClass13 || unitSub13 || pkgImportCloneEmit ||
                  importCloneEmit || importCopyTsInst != nullptr;
emitExpr(*dv, nullptr, fullName, noBindDv13 ? noBind13 : dvFormals13);
```

`importCopyTsInst` is the test that names ALL THREE clone paths (explicit
import, wildcard free subroutine, wildcard class method).

## THE GRIDS AFTER THE FIX — 10 arms, 273 golden cells, **0 OVER-FIRE**

| arm | golden cells | before the fix | after |
|---|---|---|---|
| `v1_site13` | 37 | CONVERTED 8 | CONVERTED 8, 0 over-fire |
| `v2_reach13` | 24 | CONVERTED 8, MOVED 1 (fullname family) | unchanged |
| `v3_clone13` | 16 | CONVERTED 2 | unchanged |
| `a1_forms13` | 61 | CONVERTED 14, **OVER-FIRE 1** | CONVERTED 14, **0** |
| `a2_sites13` | 34 | CONVERTED 14, **OVER-FIRE 1** | CONVERTED 14, **0** |
| `a3_window13` | 28 | CONVERTED 3, **OVER-FIRE 7**, MOVED 2 | CONVERTED 5, **0**, MOVED 0 |
| `a4_clone13` | 34 | CONVERTED 3, **OVER-FIRE 1**, MOVED 2 | CONVERTED 4, **0**, MOVED 0 |
| `a5_unit13` | 22 | CONVERTED 4, **OVER-FIRE 2**, MOVED 3 | CONVERTED 4, **0**, MOVED 1 (an IMPROVEMENT keyed as a collision) |
| `a6_prop13` | 12 | all `same` | all `same` |
| `a7_dpi13` | 5 | CONVERTED 3 | CONVERTED 3, 0 over-fire |

`detcheck.sh` ×3 on each new arm: 1 distinct hash, 0 NO_OUTPUT.

`a6_prop13` (a default naming a CLASS PROPERTY, a STATIC property or a
`localparam`, in-body and out-of-body) and `a7_dpi13` (a DPI-C import prototype
whose formal carries a default — slang accepts it, and it has no body at all)
are the two axes the brief names that the shipped arms did not carry: a6 is
`same` in every cell on both binaries, a7 converts 3 and over-fires 0 (a `$unit`
DPI prototype carries no default expression in golden at all).

## GATES ON THE FIXED BINARY (md5 `0cb6ee513102f0ee84a20a5858a378d0`)

1. built `-j 2` from the same worktree; md5 taken separately.
2. goldens **23**; `/bin/false` **0**.
3. u2r **679 / 50 / 2** both modes; testflags vs COMMITTED **0 differing rows**;
   pristine-vs-fixed over 1 462 **0**.
4. surelog vs COMMITTED **0 differing rows over 1 588**; pristine-vs-fixed **0**;
   shipped-patched-vs-fixed **0**.  **NO ROW CONVERTED.**
5. byteverify `SELFCHECK=1 SELFCHECK1=1`: surelog **9 / 956** (the same 9 names
   and the same md5s as the shipped patch), u2r **0 / 1 358**; controls 955 + 10
   and 1357 + 1.  **fixed vs shipped-patched: 0 / 956 and 0 / 1 358 — the fix is
   a strict BYTE no-op on both corpora**, so the corpus census, the attribution
   (4 gained / 74 lost, other 0, NOT ATTRIBUTED 0) and every head carry over
   unchanged.
6. boundary gate over the same 582 arms with the FIXED binary:
   `PROCESSED=582 IDENTICAL=576 MOVED=0 REJECT-BOTH=6 ONE-SIDE=0`.
7. canaries `ok=52`/`ok=16` changed=0; ctcan2 58/2 changed=0; canaudit
   `audited=29 UNCOVERED=0 FENCE-BREACH=0`; pins SVSwitch `4842211c4030`,
   YosysVerx `6ccda350c24a`.

## RANKED RESIDUES ADDED BY THE VERIFIER

* **R6 — a SELF-reference (`function f(int a = a)`).**  slang accepts it and
  golden BINDS the formal to its own io_decl (Surelog's `lateBinding` matches by
  NAME against the finished `Io_decls()` vector, which already holds it); our map
  is filled AFTER the default is emitted, so we leave it bare.  Pre-existing
  direction (pristine bare too), corpus population 0.  `a1` `f_self`.
* **R7 — the EXPLICIT-import clone's ENUM CONSTANT.**  Golden leaves
  `pex5::hf_enumi`'s `U5_B` bare; we bind it, on BOTH binaries.  The README's
  "our clone already leaves the ENUM CONSTANTS bare" holds for the WILDCARD
  clone only.  Pre-existing, not this pass's family, left deliberately.
* **R8 — a `$unit` TASK's default emits an expression golden does not have**
  (`a5` `gt_earlier`: golden has NO cell, both binaries emit one, act0).
  Pre-existing.
* The fullname families (`work@m13.cm13::` vs `work@m13::cm13::`,
  `uc4::` vs `work@uc4::`) are unchanged and are not fields `Compare` reads.
