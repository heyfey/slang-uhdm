# r10uvm157 — § `stmtScopeTdListedOnEnclosingScope157` — **A TYPEDEF DECLARED INSIDE A STATEMENT SCOPE IS LISTED ON THAT SCOPE'S OWN `Typespecs()` VECTOR** — the BuildUVMPkg ×2 **1371-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; `GOLDEN_DEFER` stayed
UNSET; **nothing was promoted** and **NO CORPUS ROW CONVERTED**. The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `1f9906a` |
| worktree | `/tmp/wt_r10uvm157` |
| pristine binary | md5 `100987bc8d76f2052aa842d7c65c5110`, built from a clean `1f9906a` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `d27df00cf3c52be5bee8d3286ef2b9b2`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` (the law, the form classifier, Surelog's body-item count), `include/UhdmExporter.h` (one declaration + one flag), `src/TypeEmit.cpp` (the factory), `src/StmtEmit.cpp` (SITES 1 and 2), `src/TaskFuncEmit.cpp` (SITE 3) |
| probe surface | `tools/probe/r10uvm157repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **BuildUVMPkg default / testflags** | **1371** | **163** | 1 — a **NEW head**, a different object further along the walk (§7) |
| SeqDriver default / testflags | 22 | 22 | 1 unchanged, head log BYTE-IDENTICAL |
| SimpleUVM default / testflags | 163 | 163 | 1 unchanged, head log BYTE-IDENTICAL |
| Scoreboard default | 163 | 163 | 1 unchanged, head log BYTE-IDENTICAL |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 31 / 36 | 31 / 36 | 1 unchanged, head log BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes; `CMP_NOTEQUAL` stays **19** on surelog and `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2` on uhdm2rtlil, status AND dump histograms IDENTICAL | |
| byte movers | — | **2 / 956** surelog (BOTH predicted BY NAME; the Scoreboard coin did not flip), **0 / 1358** uhdm2rtlil | |
| the family census (9 UVM DBs, full listing payload) | — | **2 cells moved, TOWARD; 0 WRONG, 0 AWAY** | |
| the grid (5 arms, both views) | 210 differing cells | **34** — **176 MOVED TOWARD, 0 MOVED WRONG, 0 AWAY** | |
| the WIDE boundary (4418 arms, both views) | — | **25 moved arms, 255 cells TOWARD, 0 AWAY, 0 RESHAPE, RC_DIFFS 0** (5 of the 25 are this pass's own grid — the positive control) | |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT's
decompile size. `head_pris_BuildUVMPkg.default.cmp` (1371 lines) is the head
the brief named — a `begin` that decompiles its whole body;
`head_pat_BuildUVMPkg.default.cmp` (163) is a different, much smaller `begin`
much further along.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST, AND ITS FIELD DECODED BY THE OWNER-FINDER

`rowheads.sh` on this pass's own pristine sweep reproduced the brief exactly —
BuildUVMPkg ×2, **1371 cmp lines, 1 head**, `RHS: <null>` at line 1371.

`uhdm-cmp` CANNOT NAME THE FIELD for this shape.
`BaseClass::SafeCompare`'s **vector** overload
(`~/.local/include/uhdm/BaseClass.h:201-224`) sets `m_failedLhs` to the
**OWNER** and leaves `m_failedRhs` untouched when `rhs == nullptr`, so the log
prints the whole `begin` and the word `<null>` and says nothing about WHICH of
`scope::Compare`'s seventeen vectors returned. `ct157own.cpp` — the
owner-finder, descended from `r10uvm146repro/ct146own.cpp` and
`r10uvm113repro/ct113own.cpp` — links the SAME generated `Compare`, runs it,
recovers OUR counterpart by kind + `VpiFullName` + span (checking that exactly
one exists), and walks `scope::Compare`'s own order
(`~/git-repos/UHDM/build/generated/src/scope.cpp:335-351`):

```
HEAD LHS parent chain:
    < if_stmt()@51337:3-51431:6      < begin()@51294:1-51432:4
    < begin()@51291:52-51434:9       < for_stmt()@51291:6-51291:9
    < begin()@51280:6-51280:27       < function(build_phase)@51278:3-51436:14
    < class_defn(uvm_agent)          < package(uvm_pkg)   < design
OUR counterparts by kind+fullname+span: 1
OUR counterpart = begin()@51337:29-51431:6#82799   (patched: #6069 pristine)
   Property_decls  null/null   Sequence_decls null/null  Concurrent_assertions null/null
   Named_events    null/null   Named_event_arrays null/null
   Variables       LHS=2 RHS=2      Virtual_interface_vars null/null
   Logic_vars      null/null   Array_vars null/null   Array_var_mems null/null
   Parameters      null/null   Param_assigns null/null   Scopes null/null
-> Typespecs       LHS=1 RHS=null
   Instance_items  null/null   Let_decls null/null   Attributes null/null
  LHS Typespecs[0] = bit_typespec(__tmp_int_t__)@51338:14-51339:48
```

**THE FIELD IS `scope::Typespecs()`, AT INDEX 0**, on the `begin` at
`uvm_pkg.sv:51337:29`. Golden lists one entry, we list none. Source —
`1800.2-2017-1.0/pp_output/uvm_pkg.sv`, the `uvm_config_db` macro expansion
inside `uvm_agent::build_phase`:

```systemverilog
  if (!/* SUCCESS */ found) begin                                     // :51337
     typedef bit [$bits(                                              // :51338
                /* TYPE */    uvm_active_passive_enum)-1:0] __tmp_int_t__;  // :51339
     __tmp_int_t__                 __tmp_int_val__;                   // :51340
```

Note the ORDER: `Variables` is compared at `scope.cpp:340`, BEFORE `Typespecs`
at `:348`. r10uvm155 made `__tmp_int_val__` a `ref_var` on both sides, and that
is exactly why the walk now gets as far as `Typespecs` — this pass is the
second half of the arm r10uvm155 decoded.

---

## 2. THE LAW

> **§ `stmtScopeTdListedOnEnclosingScope157`** — *a typedef declared inside a
> STATEMENT SCOPE is pushed onto the ENCLOSING UHDM `scope`'s `Typespecs()`
> vector, in DECLARATION ORDER: the innermost `begin` / `named_begin` /
> `fork` / `named_fork` that contains it; for a SUBROUTINE's own typedefs, the
> SYNTHESISED body `begin` when the body has MORE THAN ONE source item, and the
> `task` / `function` itself when it has exactly one. The listed object is what
> `compileTypespec` makes of the WRITTEN TYPE under `Reduce::No`: named with the
> typedef's BARE name, spanned over the written type, with NO `vpiInstance`, NO
> `Typedef_alias`, and its range bounds left SYMBOLIC. A typedef whose written
> target is a NAME — another typedef, a class, a scoped type, a `virtual`
> interface — is pushed NOWHERE. A CONSTRUCTOR's body lists NOTHING ANYWHERE,
> and neither does a subroutine compiled under the TF-ITEM production.*
>
> **WHY, read off Surelog.** `CompileHelper::compileTypeDef`
> (`src/DesignCompile/CompileHelper.cpp:501-517`) opens with
>
> ```cpp
> UHDM::VectorOftypespec* typespecs = nullptr;
> if (pstmt) {
>   UHDM::scope* scope = any_cast<UHDM::scope*>(pstmt);
>   if (scope) {
>     typespecs = scope->Typespecs();
>     if (typespecs == nullptr) { typespecs = s.MakeTypespecVec();
>                                 scope->Typespecs(typespecs); }
>   }
> }
> ```
>
> and every later arm ends `if (typespecs) typespecs->push_back(<ts>)`
> (`:688, :698, :702, :724, :734, :738, :776, :786, :790, :928, :961, :989,
> :1013, :1042, :1095`). `pstmt` is whatever `compileStmt`'s
> `paType_declaration` arm was called with (`CompileStmt.cpp:1284-1290`) — the
> same arm r10uvm155 decoded, and the same line (`component = nullptr`) is why
> the DESIGN-COMPONENT half of that call registers nothing. The
> `any_cast<UHDM::scope*>` IS the placement rule: `paSeq_block`
> (`CompileStmt.cpp:334`) and `paPar_block` (`:427`) hand the block object
> itself to every child, so the listing lands on the INNERMOST block; an
> `if_stmt` / `case_stmt` / `while_stmt` is not a `scope` and can never carry
> one (and in legal SystemVerilog a `block_item_declaration` only ever appears
> in a `seq_block`, a `par_block` or a subroutine body anyway).
>
> **`scope` IS NULL AND `reduce` IS `Reduce::No`, and that is what makes this
> object DIFFERENT from a package's or a module's listing entry:**
> * **no `vpiInstance`** — every `ts->Instance(scope->getUhdmInstance())` stamp
>   (`:679, :709, :913, :1085`) is guarded
>   `reduce == Reduce::Yes && valuedcomponenti_cast<Package*>(scope)`;
> * **no `Typedef_alias`** — the whole clone-and-alias arm (`:900-1046`) sits
>   inside the same guard;
> * **the BARE name** — `fullName` gains a `pkg::` prefix only when
>   `valuedcomponenti_cast<Package*>(scope)` succeeds (`:614-616`);
> * **RANGE BOUNDS STAY SYMBOLIC** — `compileTypespec` runs with `Reduce::No`,
>   so `$bits(x)-1` stays an `operation` over a `sys_func_call` and `PARAM-1`
>   stays an `operation` over a `ref_obj`. **That is the corpus head's own
>   shape.**
>
> **THE NAME TARGET IS PUSHED NOWHERE.** When `fC->Type(stype)` is
> `slStringConst` or `paClass_scope` — another typedef, a class, a scoped type,
> a forward declaration, with or without the `virtual` keyword that `:882` steps
> over — control takes the DummyType arm (`:891-1051`), whose ENTIRE typespec
> construction is wrapped in `if ((reduce == Reduce::Yes) && (Package ||
> FileContent))`. Under `Reduce::No` that body is skipped and nothing is pushed.
>
> **AN EMPTY VECTOR AND A NULL VECTOR ARE THE SAME ANSWER TO THE JUDGE.**
> `BaseClass::SafeCompare`'s vector overload returns 0 for (null, empty) and for
> (empty, null); only a NON-EMPTY vector against a null one, or two vectors of
> different size, can fail. So a scope whose every typedef is a NAME target
> needs no vector from us — and, measured, Surelog's own empty vector does not
> survive the capnp round trip either (`g157_b_form` b23/b24/b25 read `N=null`
> on BOTH sides).

### 2.1 WHERE A SUBROUTINE'S OWN TYPEDEFS GO — Surelog's BODY-ITEM COUNT

`compileTask` / `compileFunction` read `Statement_or_null` and then
`MoreStatement_or_null = fC->Sibling(Statement_or_null)`
(`CompileStmt.cpp:2037-2041` / `:2455-2462`). With a sibling ("Page 983, 2017
Standard: More than 1 Stmts") they synthesise a `begin` and pass THAT to every
body statement (`:2043-2075`); without one they pass the `task` / `function`
itself (`:2115-2121`). The siblings counted are SOURCE ITEMS —
`block_item_declaration`s and statements alike. MEASURED, golden, both views:

| body | where golden lists |
|---|---|
| `task t(); typedef bit[2:0] q; endtask` | **on the TASK** |
| `task t(); typedef q1; typedef q2; endtask` | on the synthesised `begin` (both entries) |
| `task t(); parameter K=2; typedef q; endtask` | on the synthesised `begin` |
| `task t(); typedef q; q v; endtask` | on the synthesised `begin` |
| `function int f(); typedef q; return 1; endfunction` | on the synthesised `begin` |
| `function void f(); typedef bit[2:0] q; endfunction` | **NOT MEASURABLE — Surelog SEGFAULTS** (rc=139 in a package, a module and a class alike; the `task` spelling is rc=0). Named here so it is never quietly re-added to a grid. |

### 2.2 THE TWO CARVE-OUTS, both found by the grid as AWAY-GOLDEN cells in a first cut

1. **THE TF-ITEM PRODUCTION lists nothing.** When a subroutine's body opens
   with a non-ANSI port declaration, `compileTask` / `compileFunction` hand the
   whole leading `tf_item_declaration` run to `compileTfPortDecl`
   (`:2010-2027` / `:2425-2470`) BEFORE the statement walk starts, and that
   function's `paBlock_item_declaration` arm (`:1661-1712`) only ever reads a
   `paVariable_declaration`: a `paType_declaration` there is compiled by
   NOBODY. MEASURED (`g157_d_sub`): `tfItemTask157` (`input int spark;` written
   in the body) lists NOTHING in golden, while its ANSI twin `ansiTask157`
   lists its typedef. Without this gate the first cut put an entry on the task
   and the grid scored it **AWAY**.
2. **A CLASS CONSTRUCTOR lists nothing, anywhere.**
   `compileClassConstructorDeclaration` (`CompileStmt.cpp:2165-2300`) walks the
   ctor's items with `fC->Child(Stmt)` and never reaches a
   `paType_declaration`. MEASURED: a ctor's own typedef reaches NO object in
   the whole golden database (`g157_d_sub` `kilnNewCtor157`, 0 occurrences),
   and a typedef inside a WRITTEN `begin` in a ctor body reaches none either —
   golden emits no such `begin` at all (probe `PC::CC::new`, which is §
   `constructorBodyElementShift27`'s territory). Without this gate the first cut
   listed on the `function` and the grid scored it **AWAY**.

---

## 3. STATED GATE == CODE GATE

**STATED**, as ONE form classifier (`stmtScopeTdListForm157`,
`src/EmitHelpers.h`) with three answers, plus ONE structural rule:

1. **Skip** — the written target is a `NamedType` (a bare identifier, a scoped
   name, a class name) or a `VirtualInterfaceType`. Golden pushes nothing for
   these, so neither do we, and the scope's other typedefs still list.
2. **Build** — the written target canonicalises to `ScalarType`,
   `PackedArrayType`, `PredefinedIntegerType`, `StringType`, `FloatingType`,
   `CHandleType` or `EventType`, and the typedef carries no unpacked
   dimensions. These are exactly the forms our shared `makeTypespec` produces
   as ONE self-contained object with no member / enum-constant sub-listing.
3. **Decline** — an `enum`, a `struct`, a `union`, or any UNPACKED-DIMENSIONED
   typedef. All of them are MEASURED (`g157_b_form` lists all of them in
   golden) and all are left exactly as they are today: their listed objects
   carry member / enum-const chains whose naming and parenting are a different
   law's.
4. **THE STRUCTURAL RULE: a Decline is taken over the WHOLE SCOPE.** A scope
   holding one declined form lists NOTHING and stays byte-identical to today.
   A half-filled vector would disagree with golden's SIZE in a NEW way, which
   is a MOVED-WRONG; `g157_b_form` b33 (`tallyMixedVec157` +
   `tallyMixedEnum157` in one `begin`) is the cell that scores it, and it is
   byte-identical to the pristine answer.
   The classification pass runs BEFORE anything is built, so a decline leaves
   the serializer exactly as it found it — an abandoned typespec would still be
   written to the database and move bytes on an arm this law does not claim.

**SITES — three, each setting `Typespecs()` and NOTHING else**, so no scope's
name, full name, span, parent, statements or variables move:

* `src/StmtEmit.cpp` ~2445 — **SITE 1, the WRITTEN block**: `begin`, a named
  begin, a `fork` arm, a loop body, an `if` arm, a `case` item, a module
  `initial` / `always` / `final` body, a generate block's own `initial`, an
  interface's `initial`, a program's `initial`. Gated `!tfBodyCtor27`.
* `src/StmtEmit.cpp` ~5615 — **SITE 2, the SUBROUTINE BODY's SYNTHESISED
  `begin`**, from `currentSubSym`'s DIRECT members. Gated
  `tfBodyStmt9 == &stmt && !tfBodyTfItems9 && !tfBodyCtor27`.
* `src/TaskFuncEmit.cpp` ~6445 — **SITE 3, the SUBROUTINE WITH NO WRAPPER**,
  on the `task_func` itself. Gated `!tdListed157 && !tdTfItems157 &&
  !tdCtor157 && subroutineBodyItemCount157(sub) == 1`.
  The two flags are CAPTURED where they are SET, because this site runs after
  `tfBodyTfItems9` and `tfBodyCtor27` have already been restored to the
  ENCLOSING subroutine's values.

**CODE** — `git diff 1f9906a --numstat`: `src/EmitHelpers.h` **+190/−0**,
`include/UhdmExporter.h` **+23/−0**, `src/TypeEmit.cpp` **+67/−0**,
`src/StmtEmit.cpp` **+53/−0**, `src/TaskFuncEmit.cpp` **+38/−0**. **NOTHING IS
DELETED AND NO EXISTING ARM'S ANSWER CHANGES**: every line is either the new
predicate/factory or a new call that only ever WRITES a vector that was null.

### 3.1 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | fires on the corpus? | what proves it |
|---|---|---|
| SITE 1 (the written block) | **FIRES**, once | the corpus head `uvm_pkg.sv:51337:29`; on the grid, 16 scope kinds in `a_scope` and every loop / case / always / label flavour in `e_edge` |
| SITE 2 (the body wrapper) | **UNEXERCISED on the corpus** | `a_scope` `flock` / `lone` / `burrow` / `knead` / `churn` / `perch` / `groom` / `preen` / `prune`, `c_count` `hammerOne/Two/Three`, `d_sub` `emberFull157` / `ansiTask157` / `autoFn157` / `pourIn157` / `pourVirtual157` / `pourStatic157` / `pourOut157` / `emberParam157` |
| SITE 3 (the bare task_func) | **UNEXERCISED on the corpus** | `d_sub` `soleTdTask157` and `soleTdModTask157` only |
| Skip (a NAME target) | **UNEXERCISED on the corpus** | `b_form` b23/b24/b25 and `QUIRE_ALIAS`, and b32 where a NAME target sits BETWEEN two listed ones and the ORDER survives |
| Decline (enum/struct/union/array) | **UNEXERCISED on the corpus** | `b_form` b18-b22 and b26-b30, and b33 for the whole-scope rule |
| the TF-ITEM carve-out | **UNEXERCISED on the corpus** | `d_sub` `tfItemTask157` against `ansiTask157` |
| the CONSTRUCTOR carve-out | **UNEXERCISED on the corpus** | `d_sub` `kilnNewCtor157` |
| the item-count gate on SITE 3 | **UNEXERCISED on the corpus** | `d_sub` `emberDeclOnly157` / `emberReturn157` (which it turns OFF) against `soleTdTask157` (which it turns ON) |

The corpus reach of this law is **ONE scope in two databases**: the a-priori
prediction (§4.1) censused 956 surelog and 1358 uhdm2rtlil databases on both
sides and found no other statement-scope typedef anywhere. Everything above the
first row is grid-only coverage, stated rather than hidden.

---

## 4. THE MOVERS

### 4.1 PREDICTED FIRST, from the PRISTINE databases — `PREDICT.r10uvm157.txt`

`predsweep157.sh` censused **956 surelog** and **1358 uhdm2rtlil** databases on
BOTH sides with the pristine binary only:

```
surelog     2 cells   default/BuildUVMPkg-bf853d43   ELABPKG uvm_pkg::uvm_agent::build_phase begin depth4
                      testflags/BuildUVMPkg-bf853d43  G=[bit_typespec|__tmp_int_t__|51338:14-51339:48|<noinst>|0:operation[11]/constant[UINT:0]] N=1
                                                      O=[N=null]
uhdm2rtlil  0 cells
```

**PREDICTION, BY NAME:** `default/BuildUVMPkg-bf853d43` and
`testflags/BuildUVMPkg-bf853d43`, one cell each; nothing else in either corpus.

A CENSUS TRAP worth recording: without the `--listed` filter the same sweep
reports ~270 "cells" in `Earlgrey_0_1/testflags` alone. Every one of them is
null-vs-null — a scope MULTIPLICITY artifact (a builtin class's `task` appears
once in golden and twice in ours under the same key), not a listing difference.
Earlgrey has **zero** statement-scope typedefs on either side: 0 listing
entries in 15908 golden and 24907 our scope rows.

### 4.2 MEASURED — `byteverify.sh SELFCHECK=1`, both corpora

```
surelog     PATH_SETS_IDENTICAL (956)   MOVERS 2 / 956   SELFCHECK 955/956 flagged
              ./default/BuildUVMPkg-bf853d43/slang.uhdm     PREDICTED
              ./testflags/BuildUVMPkg-bf853d43/slang.uhdm   PREDICTED
uhdm2rtlil  PATH_SETS_IDENTICAL (1358)  MOVERS 0 / 1358  SELFCHECK 1357/1358 flagged
```

Scoreboard/default — the ~50/50 COIN — did NOT flip on this run and is
byte-identical between the two sweeps.

**BuildUVMPkg, path-normalised whole-dump diff: 39 lines ADDED, 0 REMOVED, 0
CHANGED**, and every added line is the listing entry:

```
+ |vpiTypedef:
+ \_bit_typespec: (__tmp_int_t__), line:51338:14, endln:51339:48
+   |vpiName:__tmp_int_t__
+   |vpiRange: \_range: , line:51338:18, endln:51339:48
+     |vpiLeftRange: \_operation: , line:51338:19, endln:51339:45  |vpiOpType:11
+       |vpiOperand: \_sys_func_call: ($bits), line:51338:19, endln:51339:43
+         |vpiArgument: \_ref_obj: (__tmp_int_t__.uvm_active_passive_enum) …
+       |vpiOperand: \_constant: UINT:1
+     |vpiRightRange: \_constant: UINT:0
```

byte for byte the object `head_pris_BuildUVMPkg.default.cmp` lines 33-71 show
golden has. Both modes produce the same database, as they did before.

### 4.3 THE FAMILY CENSUS — `CENSUS.r10uvm157.txt`

Calibrated golden-vs-golden FIRST: the nine golden censuses taken during the
pristine sweep and during the patched sweep are BYTE-IDENTICAL, all nine.
Over the nine measurable UVM databases, full listing payload:
**2 cells moved, both TOWARD golden; 0 WRONG, 0 AWAY.** Eight of the nine
databases hold no statement-scope typedef at all on either side.

### 4.4 THE GRID — `GRID.r10uvm157.txt`

```
a_scope    pristine-DIFF=35   patched-DIFF=0    MOVED-TOWARD=35   MOVED-WRONG/AWAY=0
b_form     pristine-DIFF=76   patched-DIFF=28   MOVED-TOWARD=48   MOVED-WRONG/AWAY=0
c_count    pristine-DIFF=36   patched-DIFF=0    MOVED-TOWARD=36   MOVED-WRONG/AWAY=0
d_sub      pristine-DIFF=23   patched-DIFF=6    MOVED-TOWARD=17   MOVED-WRONG/AWAY=0
e_edge     pristine-DIFF=40   patched-DIFF=0    MOVED-TOWARD=40   MOVED-WRONG/AWAY=0
-- TOTAL MOVED-TOWARD=176  MOVED-WRONG/AWAY=0
```

| arm | what it settles | golden |
|---|---|---|
| **`g157_a_scope.sv`** — NINETEEN scope kinds | WHICH object carries the listing | an in-body class method's body and a `begin` inside one, a class TASK, an OUT-OF-BODY method's body AND its nested `begin`, a package free function, a package free task, a module `initial`, a NAMED begin, a nested begin, a `fork` arm, a `for` body, an `if` arm, a `case` item, a module function, a module task, a named `always_comb`, a generate block's `initial`, a PROGRAM's `initial` and a PROGRAM's task — **all nineteen list, and all nineteen are now golden-exact in BOTH views** (0 differing cells) |
| **`g157_b_form.sv`** — THIRTY-THREE target forms, ONE PER `begin` | which forms are pushed, with what kind / name / span / range | vector (constant range, `$bits()` range, PARAM range, bare `bit`, `signed`), `logic`, `int`, `int unsigned`, `byte`, `shortint`, `longint`, `integer`, `time`, `string`, `real`, `shortreal`, `chandle` all list; `enum` (with and without a base), packed & unpacked `struct`, packed `union`, four unpacked-array forms and an associative one list in golden and are DECLINED here; the three NAME targets list NOWHERE on either side; an ORPHAN typedef with no user at all IS listed; the ORDER survives a NAME target sitting between two listed ones; a mixed listable+declined scope lists nothing here |
| **`g157_c_count.sv`** — COUNT / ORDER / INSTANCES | 1, 2 and 3 entries per scope, interleaved with variables, over 1, 2 and 3 instances of the same parameterised module | **0 differing cells** — the listing count, the index order and the per-instance ELABORATED copies all match, and a nested `begin` inside a listing scope keeps its own |
| **`g157_d_sub.sv`** — the SUBROUTINE axis | SITE 2 vs SITE 3 vs "nowhere" | the item-count rule (§2.1) and the two carve-outs (§2.2); 6 cells still differ, each byte-identical to the pristine answer and each named in §7 |
| **`g157_e_edge.sv`** — the NEGATIVE and BOUNDARY arm | where this law must move NOTHING, and every remaining statement flavour | a `$unit`, package, class, module, interface and GENERATE-BLOCK typedef all stay exactly as they are; `foreach` / `while` / `do..while` / `repeat` / `forever` bodies, all three `case` flavours including `default`, a labelled begin with an end label, a labelled `fork ... join_any`, `always_ff` / `always_latch` / `always @(*)` / `final`, an interface task and initial, a PROGRAM initial, a `begin` whose ONLY content is a typedef, two SIBLING begins declaring the SAME typedef name, and a statement-scope typedef whose bare name is ALSO a package typedef's — **0 differing cells** |

---

## 5. GATES — `GATES.r10uvm157.txt`

All green; the file carries every number, including the binary-path audit of
all four sweeps (1523 + 1458 references each, none to a main-tree binary).

## 6. BOUNDARIES — `BOUNDARY.r10uvm157.txt`

`bound157.sh` over a COPY of the WHOLE `tools/probe` tree — top level AND
subdirectories, both views, both binaries:
**`LISTED=4418 PROCESSED=4418 PRODUCED_DBS=4271 MOVED_ARMS=25 RC_DIFFS=0`**,
and every one of the 25 scored cell by cell against a Surelog-built golden:
**255 cells TOWARD, 0 AWAY, 0 RESHAPE.**

Five of the 25 are this pass's own grid arms — the positive control that proves
the gate can see. Fourteen are r10uvm155's grid and its verifier's arms plus
r10v98's two collision arms: the SAME population, every one holding a typedef
declared in a statement scope. Two more are `r10uvm114repro/g114_c_clspkg.sv`
(a class method's and a package function's local typedefs) and —
**the best independent witness in the whole pass** —
`r10v131repro/arms/v131_k_null.sv`, which writes

```systemverilog
    fork typedef int t_ka; join_none
    fork : kD typedef int t_kb; join_any : kD
```

a typedef with NO enclosing `begin` at all. Golden lists it on the `fork_stmt`
and on the `named_fork` **themselves**, and so do we — confirming from an arm
this pass did not write that the placement rule really is
`any_cast<UHDM::scope*>(pstmt)` and not "the nearest `begin`".

The last two — `r10buvm22repro/g22.sv` and `r10uvm154repro/l154_noenum.sv` —
**MOVED IN BYTES with 0 CELLS**: the whole-dump diff of each is a single folded
constant in an associative-dimension range, `22548185` → `22552281`, **exactly
one 4096-byte page**. That is the defect r10uvm155's README named, measured and
proved binary-image-derived with a positive control; neither file contains a
statement-scope typedef this law could mint anything in.

Two arms needed the `--noowner` reading and got it, with both numbers recorded:
in the ELABORATED view golden spells a module subroutine's `VpiFullName` with
the INSTANCE path and we spell it with the DEFINITION — a pre-existing residue
of a different law that no generated `Compare` reads. Their LISTED PAYLOAD is
byte-identical to golden either way.

## 7. RESIDUES AND R0

**R0 — the NEW BuildUVMPkg head, decoded with the same owner-finder.** The head
is now the `begin` at `uvm_pkg.sv:61835:28` in
`uvm_pkg::uvm_reg_predictor::type_name`, again printed with `RHS: <null>`, and
`ct157own` names the vector and the index:

```
HEAD LHS parent chain: < if_stmt@61835:5 < begin@61835:5 < function(type_name)@61833:3
                       < class_defn(uvm_reg_predictor) < package(uvm_pkg) < design
OUR counterpart = begin()@61835:28-61839:8
-> Variables      LHS=1  RHS=null        (Typespecs is null on BOTH sides)
```

```systemverilog
  static function string type_name();
    if (type_name == "") begin                                  // :61835
      BUSTYPE t = BUSTYPE::create("t");                         // :61836  <- THE HEAD
      type_name = {"uvm_reg_predictor #(", t.get_type_name(), ")"};
    end
```

**Golden LISTS the block-local `t` on the enclosing `begin`'s `Variables()`
vector, as a `ref_var` bound to an `int_typespec` from elsewhere
(`@61859:31-61859:38`), and we list NOTHING there.** `BUSTYPE` is the class's
own TYPE PARAMETER, so this is the `Variables` twin of the family
r10uvm155 opened: a local whose written type Surelog cannot resolve at
`compileVariable` time. **R0: emit the block-local declaration whose written
type is a CLASS TYPE PARAMETER — golden's `ref_var` on the enclosing `begin`'s
`Variables` — where we emit nothing at all.**

**RESIDUES this pass measured and deliberately did NOT move:**

* **the ENUM / STRUCT / UNION / UNPACKED-ARRAY listing forms.** Golden lists
  all of them (`g157_b_form` b18-b22, b26-b30, and the module twins); this law
  declines them, and declines the WHOLE SCOPE that holds one, so those cells
  are byte-identical to the pristine answer. Their listed objects carry member
  and enum-constant chains whose naming and parenting are a different law's —
  the module/package typedef listing in `TypeEmit.cpp` builds them with a
  module parent, a `vpiInstance` and module-prefixed member fullnames, none of
  which a statement-scope entry may have. Zero corpus reach today.
* **the SUBROUTINE-BODY WRAPPER THRESHOLD.** Surelog counts a typedef as a
  body ITEM, so `function int f(); typedef q; return 1; endfunction` and
  `task t(); typedef q; q v; endtask` both get a synthesised `begin`; our
  threshold counts only STATEMENTS and builds none, so those two cells stay
  ONLY-G (`g157_d_sub` `emberReturn157`, `emberDeclOnly157`). A begin that does
  not exist cannot carry a listing. That threshold is
  § `tfItemLocalInitHoistsNoStatement145`'s and it is left to its own pass.
* **the SYNTHESISED BODY BEGIN's SPAN.** Surelog anchors it at the SECOND body
  item, counting the typedef; we anchor it at the first executable statement.
  Measured on every subroutine cell of `a_scope` (golden `54:5-54:26` where we
  read `55:5-55:18`). Invisible to every generated `Compare` — no `Compare`
  reads a line or a column — and left alone rather than moved by a pass whose
  law is about a vector.
* **A MODULE-HOMED subroutine taking SITE 3 lists the entry TWICE.**
  `g157_d_sub` `soleTdModTask157`: golden's module `task` carries `N=2`, the
  same object pushed twice, where its package twin `soleTdTask157` carries
  `N=1`. `compileTypeDef` appends to a vector the task_func already owns, and a
  module's body is compiled in more than one pass while a freshly-made `begin`
  is not. Measured, declined, and byte-unreachable on the corpus: the
  a-priori prediction found no module subroutine with a sole typedef in either
  corpus.
* **`function void f(); typedef bit[2:0] q; endfunction` SEGFAULTS Surelog**
  (rc=139 in a package, a module and a class alike; the `task` spelling is
  rc=0). Golden has no answer for that shape, so it is in no arm — named here
  so it is never quietly re-added.
* **the ELABORATED `VpiFullName` of a module subroutine** — golden spells it
  with the instance path, we spell it with the definition. Pre-existing, not
  read by the judge, and the reason `score157.py` carries `--noowner`.
* **the g22 / l154_noenum associative-dimension constant** — one folded number
  derived from the BINARY IMAGE's layout, moving exactly one 4096-byte page for
  any binary. Named again so the next pass's boundary gate recognises it
  instead of re-attributing it.

## 8. HOW TO REPRODUCE

```bash
# one grid arm, both views, on two binaries
bash grid157.sh g157_a_scope.sv <pristine> <patched> <workdir> <ct157cen>
python3 score157.py <workdir>/cen.g.txt <workdir>/cen.b.txt --listed
bash scoreall157.sh <griddir-prefix> a_scope b_form c_count d_sub e_edge

# the a-priori prediction, from PRISTINE databases only
CEN=<ct157cen> SCORE=$PWD/score157.py bash predsweep157.sh <pristine workdir> pred.tsv

# the family census
CEN=<ct157cen> bash scan157.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg

# the head's FIELD and INDEX, from the two databases
./ct157own <golden.uhdm> <ours.uhdm>

# build the two tools
g++ -O2 -std=c++17 ct157cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct157cen
g++ -O2 -std=c++17 ct157own.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct157own
```
