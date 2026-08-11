# r10uvm55 — ONE law; the brief's TARGET-1 diagnosis REFUTED by a positional probe (the module listing was already correct); SimpleUVM's and Scoreboard's head CLEARED; the brief's TARGET-4 site count REFUTED (nine, not three); **NO conversion**

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order — every driver here passes them that way and says so on every run.

Base **0c08a3f** (pass 54's committed FINAL).

| binary | md5 | what it is |
|---|---|---|
| HEAD control | `9d3e335a2b43dcbf698cdf2a0d8598bf` | this worktree's build of pristine 0c08a3f — **byte-identical to the main-tree `build/slang-uhdm` at the start of this pass**, which is what makes it a valid control (printed by `md5sum` on both, §8) |
| FINAL (gated, shipped) | `549f2c2ad003c05414107ea6a9af1d21` | every gate below ran on this binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` and
`results/golden_surelog.csv` were **read only**; their row counts (**731** and
**1588**) come from `csvdiff.py`'s parsed dict, never from `wc -l` (which would
say 732 / 1589 because of the header).

**DUMP-DISTANCE CONVENTION, stated once.** `wdump.sh` strips uhdm-dump's first
line (the database path) with `sed '1d'` and reports `diff -u | grep -c '^[-+]'`
**minus 2**, the 2 being ONLY the two `diff -u` header lines. `dumpdist.sh`
prints that number AND the path-scrubbed variant `gold.sh` uses; on every corpus
row measured here the two are **IDENTICAL**, so the convention is not what
separates my figures from pass 54's (§0, last bullet).

## 0. HEADLINE — honest

* **NOTHING CONVERTED.** `SimpleUVM`, `SeqDriver`, `Scoreboard` and
  `BuildUVMPkg` are still `CMP_NOTEQUAL` in both modes; `Scoreboard,testflags`
  is still `SLANG_REJECT`. **`csvdiff.py` reports ROW DIFFS 0 against BOTH
  committed baselines. No row moved; there is no promotion to make.**
* **ONE law landed: `invalidNewCallFromSyntax55`** — `src/ExprEmit.cpp`, three
  tagged sites (`grep -n 'invalidNewCallFromSyntax55' src/ExprEmit.cpp` gives
  the predicate, the Lhs half and the emit half).
  DIRECTION: **ADD** (a `method_func_call` that was absent) plus a **RESHAPE**
  of the Lhs (the existing artefact `hier_path` re-parent, gate widened).
* **SimpleUVM's and Scoreboard's cmp HEAD IS CLEARED.** The head at
  `uvm_registry.svh:207` — `LHS: method_func_call (new) … / RHS: <null>` — is
  gone on both rows; the head ADVANCED to an older, pre-existing object (§6).
  * SimpleUVM `default`: cmp **13 -> 29** lines / 1 head; dump content
    **238411 -> 238132**.
  * Scoreboard `default`: cmp **13 -> 29** lines / 1 head.
  * **cmp GREW while distance FELL** — cmp length is a head-DEPTH measure, and
    the new head is simply a bigger object. Both numbers are reported for every
    row, per the standing method law.
* **THE PER-FIELD CENSUS THAT SHOWS THE LAW WORKING** (`newcen.sh`, ours side,
  control -> FINAL; golden is a constant and is quoted for scale). Every figure
  names its test AND its UVM version:

  | test (UVM version) | assignments with a NULL `vpiRhs` | assignments whose `vpiRhs` is `method_func_call(new)` | golden's two figures |
  |---|---|---|---|
  | SimpleUVM (uvm-1.2) | **22 -> 15** (-7) | **393 -> 400** (+7) | 16 / 341 |
  | SeqDriver (uvm-1.2) | **28 -> 21** (-7) | **524 -> 531** (+7) | 24 / 444 |
  | Scoreboard (uvm-1.2) | **22 -> 15** (-7) | **395 -> 402** (+7) | 16 / 343 |
  | BuildUVMPkg (1800.2-2017-1.0) | **29 -> 23** (-6) | **443 -> 449** (+6) | 21 / 389 |

  Seven sites on each uvm-1.2 test, six on the 1800.2 one, and the two counters
  move by the SAME amount on every test — so every filled site minted exactly
  one object and nothing was over-minted.
* **THE BRIEF'S TARGET 1 (R4b) IS REFUTED, and the refutation is positional.**
  The brief says SeqDriver's `class_typespec (adpcm_pkg::type_id)` head is "A
  MISSING MODULE LISTING … the object is listed in the wrong container".
  `tslist.cpp` walks the `Typespecs()` vector of every container in both
  databases and prints each element's INDEX: `module_inst work@top_tb` lists
  that object at **index 20 and index 50 on BOTH sides**, and so does
  `package adpcm_pkg`. **The listing is already identical.** The real head is
  `class_typespec::Parameters()` — golden **1**, ours **NULL** — i.e. pass 54's
  residue **R1**, not its R4b (§3).
* **THE BRIEF'S TARGET 4 (R7) IS REFUTED IN ITS COUNT.** It says the doubled
  prefix is "one rule at three call sites … (17804, 18038, 18183)".
  `grep -c 'prefix + prefix' src/ParamEmit.cpp` = **9**, at 17804, 18038, 18183,
  18389, 18767, 18828, 18850, 19032 and 19237 — and 19237 takes its name from a
  different source (`pkgClassTd9`), so it is not even the same edit. Declined
  (§7), and the brief's own warning about widening a gate applies with three
  times the force it thought.
* **THE BRIEF'S TARGET 2 (R4) CENSUS IS CONFIRMED EXACTLY** on the control
  database: BuildUVMPkg (1800.2-2017-1.0) golden **4** `ref_var
  (uvm_pkg::uvm_registry_common::__deferred_init::rgtry)` / **0** `int_var`;
  ours **0** / **4**. Declined this pass with a measured reason (§7, R2).
* **ONE PASS-54 FIGURE I COULD NOT REPRODUCE, reported as unreconciled rather
  than as a refutation.** Pass 54's FINAL dump distances were BuildUVMPkg
  167059 and SimpleUVM 238633. On this base (its own FINAL commit) I measure
  **167353** and **238411**, in BOTH conventions and in BOTH modes
  (`dumpdist.sh` prints them side by side; `default` and `testflags` give the
  same 167353 for BuildUVMPkg). The likeliest cause is that pass 54's figures
  came from a FRESH `surelog -parse` run rather than the harness's cached
  golden, but I did not prove that, so it stays an open discrepancy. **All
  movement figures in this write-up are control-vs-FINAL on MY instrument, so
  the discrepancy does not affect any claim here.**
* **ONE OPS-TRAP CORRECTION.** The brief's recipe
  `ps -eo args | awk '$2=="python3"'` **misses the sweep this harness starts**:
  the launcher `exec`s the interpreter, so the sweep's argv[0] IS `python3` and
  the interpreter is field **$1**, not $2. `$1=="python3" || $2=="python3"`
  finds it. I hit this and nearly concluded a running sweep had died.

## 1. THE HEAD, AND WHY ITS `RHS: <null>` MEANT TWO DIFFERENT THINGS

Both of the brief's `<null>` heads are `SafeCompare` artefacts, but of DIFFERENT
kinds, and the difference decides the fix. Transcribed from
`/home/heyfey/.local/include/uhdm/BaseClass.h` (`grep -n 'SafeCompare'`):

* the SCALAR overload — `lhs != null && rhs == null` sets
  `m_failedLhs = lhs` and leaves `m_failedRhs` UNSET. The head then names the
  object golden HAS at that field, and RHS prints `<null>`.
* the VECTOR overload — `lhs` non-null and non-empty with `rhs == nullptr` sets
  `m_failedLhs = lhs_obj`, **the CONTAINER**, and again leaves `m_failedRhs`
  unset. The head then names the container, and a MISSING VECTOR prints as a
  MISSING OBJECT.

SimpleUVM/Scoreboard's head is the SCALAR case: `assignment::Rhs()` (compared
BEFORE `Lhs()` — `UHDM/build/generated/src/assignment.cpp`, `grep -n
'int32_t assignment::Compare'`, Rhs at line 112 and Lhs at 113). SeqDriver's is
the VECTOR case: `class_typespec::Parameters()`. `asgat.cpp` and `ctsfield.cpp`
exist to tell them apart, and each one names the FIELD rather than the object.

Also transcribed, because it prices every "span" claim in this cluster:
`BaseClass::Compare` (`UHDM/templates/BaseClass.cpp`, `grep -n
'BaseClass::Compare'`) reads **VpiType, VpiName and VpiDefName ONLY**.
**File, line and column are NOT cmp-visible.** Every span figure below is
therefore a DUMP figure.

## 2. TARGET 3 (R5) — THE MECHANISM, TRANSCRIBED FROM SLANG, NOT GUESSED

Our side emitted an `assignment` with a NULL `vpiRhs`. The cause is in
`slang/source/ast/expressions/AssignmentExpressions.cpp`,
`grep -n 'resolveNewClassTarget'`:

```
  if (nameSyntax.kind == SyntaxKind::ConstructorName) {
      if (!assignmentTarget || !assignmentTarget->isClass()) {
          if (!assignmentTarget || !assignmentTarget->isError())
              context.addDiag(diag::NewClassTarget, range);      // branch (b)
          return {nullptr, false};
      }
      ...
  }
  if (!isSuperClass && classType->isAbstract) {
      context.addDiag(diag::NewVirtualClass, range) << classType->name;  // (a)
      return {nullptr, false};
  }
```
and `NewClassExpression::fromSyntax` immediately after it:
`if (!classType) return badExpr(comp, nullptr);`

`Expression::badExpr` (`slang/source/ast/Expression.cpp`, `grep -n
'Expression& Expression::badExpr'`) is
`alloc.emplace<InvalidExpression>(expr, ErrorType::Instance)` — child NULL,
sourceRange EMPTY — and `Expression::create`'s tail
(`grep -n 'result->syntax = &syntax'`, one hit, line 1002) still attaches the
original `NewClassExpressionSyntax`. **The syntax is the only surviving
evidence, and it is enough.**

Both branches fire inside a GENERIC class's DEFAULT specialization, where
slang's diagnostics are suppressed — which is why the databases still build and
the loss was silent:

| uvm-1.2 site (SimpleUVM) | source | why slang refuses |
|---|---|---|
| `base/uvm_registry.svh:66` | `obj = new(name);`, `T obj` | (a) `T` defaults to `virtual class uvm_component` |
| `base/uvm_registry.svh:207` | `if (name=="") obj = new();` | (a) `T` defaults to `virtual class uvm_object` |
| `base/uvm_registry.svh:208` | `else obj = new(name);` | (a) same |
| `comps/uvm_pair.svh:67` | `first = new;` (no parens) | (b) `T1` defaults to `int` — not a class at all |
| `comps/uvm_pair.svh:72` | `second = new;` | (b) same |
| `comps/uvm_random_stimulus.svh:101` | `t = new;` | (a) `T` defaults to `virtual class uvm_transaction` |
| `base/uvm_pool.svh:307` | `pool[key] = new (key);` | (a) `T` defaults to `virtual class uvm_object` |

Surelog never type-checks the construct and emits the call regardless. So did
we, for every shape slang BINDS — the whole difference is the bind. Line numbers
here are uvm-1.2 source lines read in the file, paired with the greppable
symbols above.

### 2a. THE LAW

**Sites, all tagged `NOTE § invalidNewCallFromSyntax55`:**
`grep -n 'sourceIsNewClassExpr55' src/ExprEmit.cpp` — the predicate (its own
NOTE block carries the slang citation), the **Lhs half** inside the
`AssignmentExpression` arm, and the **emit half** inside `case
ExpressionKind::Invalid`.

```
PREDICATE sourceIsNewClassExpr55(e)
  true  if e.kind == NewClass                              (already handled)
  true  if e.kind == Invalid
          AND e.syntax != null
          AND e.syntax->kind == SyntaxKind::NewClassExpression
          AND e.syntax->as<NewClassExpressionSyntax>().scopedNew->kind
                == SyntaxKind::ConstructorName              (BARE `new` only)
  false otherwise

EMIT HALF, placed AFTER the existing child-unwrap and IMMEDIATELY BEFORE
`noteUnsupportedAt("expression kind: Invalid", ...)`, so it can only ever turn a
`return nullptr` into an object:
  method_func_call  VpiName "new", VpiParent = the caller's parent, NO LOCATION
  per ORDERED argument whose (Simple{Property,Sequence}Expr-unwrapped) syntax is
  an IdentifierName:
      ref_obj  VpiName = the identifier, VpiFullName = joinRef(prefix, name),
               VpiParent = the mfcall, span = the identifier's own range
  any other actual shape: noteUnsupportedAt("unbound new() argument shape: …")
  Tf_call_args set only when the vector is non-empty

LHS HALF: the pre-existing `bar = new()` artefact `hier_path` re-parent, whose
gate goes from `kind == NewClass` to `sourceIsNewClassExpr55`.
```

**Why the SCOPED forms are excluded.** `super.new` / `C::new` are named
"super.new" by golden, and no cell here measures them; they keep the existing
unsupported note rather than be guessed at. This is a deliberately narrow gate
and it is why the corpus census moves by exactly the site count.

**Why the emit half sits last in the arm.** The `Invalid` arm already carries
four landed laws (let-decl formals, property-decl formals, formal-indexed
selects, `§ droppedCall14`) and a child unwrap. Placing the new code after all
of them means no path that currently returns an object can change shape — the
only behaviour that changes is `nullptr` -> object. That is a property of the
POSITION, not of the predicate, and it is why the arm's other cells are
untouched (the a1 table in §2b: C1-C5 and C7 are identical before and after).

### 2b. ARM a1 — every cell, BOTH SIDES, one golden

`tools/probe/r10uvm55repro/a1/dut.sv`, run with `gold.sh a1 <out>` and read with
`armasg.sh <out>`. Ours is the CONTROL binary `9d3e335a` for the "before"
column and the FINAL `549f2c2a` for the "after" one; golden is one Surelog run
and is the same in both. Every cell's comment in `dut.sv` matches the row here.

| cell | source | golden (LHS) `vpiRhs` | ours BEFORE | ours AFTER |
|---|---|---|---|---|
| C1 `@44:13-44:24` | `T obj; obj = new();`, T defaults to a CONCRETE class | `method_func_call:new` args 0 | same | same |
| C2 `@46:13-46:28` | `obj = new(name);`, concrete default | `method_func_call:new` args 1 | same | same |
| C3 `@53:9-53:18` | concrete-class handle `h = new();` | `method_func_call:new` args 0 | same | same |
| C4 `@58:9-58:21` | concrete-class handle `h = new("k");` | `method_func_call:new` args 1 | same | same |
| C5 `@63:11-63:22` | `T obj = new();` — DECLARATION initialiser | **no assignment at all** | an extra `assignment` + mfcall | unchanged (PRE-EXISTING, residue R6) |
| C7 `@73:9-73:20` | typedef-typed handle in a NON-generic class | `method_func_call:new` args 0 | same | same |
| **C8a `@96:13-96:24`** | `T obj; obj = new();`, **T defaults to a `virtual class`** | `method_func_call:new` args 0 | **`<null>`** | **`method_func_call:new` args 0** |
| **C8b `@98:13-98:28`** | `else obj = new(name);`, same | `method_func_call:new` args 1 | **`<null>`** | **`method_func_call:new` args 1** |
| **C9 `@133:9-133:19`** | `c9_t = new;` — **BARE `new`, no parens** | `method_func_call:new` args 0 | **`<null>`** | **`method_func_call:new` args 0** |
| **C10 `@136:9-136:24`** | `c10_first = new;`, **`type T1 = int`** (slang's OTHER badExpr branch) | `method_func_call:new` args 0 | **`<null>`** | **`method_func_call:new` args 0** |
| **C11 `@140:13-140:38`** | `c11_pool[key] = new (key);` — assoc-array element target | `method_func_call:new` args 1 | **`<null>`** | **`method_func_call:new` args 1** |

Arm dump content +/- : **387 (control) -> 334 (FINAL)**, and `slang rc` goes
**4 -> 0** (the arm's only `noteUnsupported` was this construct, so rc 4 ->
rc 0 is itself proof the code RAN and that nothing else in the arm is
unsupported).

**C11's Rhs subtree is BYTE-EQUAL to golden**, argument included:

```
golden (LHS)                                    ours (RHS), FINAL
|vpiRhs:                                        |vpiRhs:
\_method_func_call: (new)                       \_method_func_call: (new)
  |vpiArgument:                                   |vpiArgument:
  \_ref_obj: (work@gen9_55::c11_assoc_elem::key), line:140:34, endln:140:37   <- identical on both sides
    |vpiName:key                                    |vpiName:key
    |vpiFullName:work@gen9_55::c11_assoc_elem::key  |vpiFullName:… (same)
  |vpiName:new                                    |vpiName:new
```

**ONE COST THE ARM PRICES AND I DID NOT PAY.** C11's `vpiLhs` `bit_select` span
is golden `@140:22-140:25` against ours `@140:13-140:26`. That is PRE-EXISTING
(identical before and after) and is recorded as residue **R7**, not fixed here.

### 2c. THE CORPUS NEGATIVE CONTROL — a `<null>` Rhs that MUST STAY `<null>`

SimpleUVM's `uvm_reg_predictor.svh:120` is `t = BUSTYPE::type_id::create("t");`
— also an `ExpressionKind::Invalid` on our side, also a NULL `vpiRhs`, and NOT a
`new`. **After the law it is still NULL**, which is what proves the gate is on
the SYNTAX KIND and not on "Invalid". The full before/after diff of our
NULL-Rhs list is 7 lines removed and 0 added:

```
-ASSIGN @101:7-101:14  lhs=ref_obj:t        (uvm_random_stimulus.svh)
-ASSIGN @207:19-207:30 lhs=ref_obj:obj      (uvm_registry.svh)  <- THE HEAD
-ASSIGN @208:10-208:25 lhs=ref_obj:obj      (uvm_registry.svh)
-ASSIGN @307:7-307:28  lhs=bit_select:pool  (uvm_pool.svh)
-ASSIGN @66:5-66:28    lhs=ref_obj:obj      (uvm_registry.svh)
-ASSIGN @67:7-67:18    lhs=ref_obj:first    (uvm_pair.svh)
-ASSIGN @72:7-72:19    lhs=ref_obj:second   (uvm_pair.svh)
 ASSIGN @120:7-120:40  lhs=ref_obj:t        (uvm_reg_predictor.svh)  <- STAYS
```
(the 14 other rows are unchanged and are shapes golden leaves NULL too —
declaration-initialiser assignments in constructors.)

## 3. TARGET 1 (R4b) — REFUTED, with the positional evidence

`tslist.cpp` lists the `Typespecs()` vector of the design, every package, every
class and every module, IN POSITIONAL ORDER, because
`SafeCompare(lhs->Typespecs(), rhs->Typespecs())` compares those vectors
POSITIONALLY and uhdm-dump's indentation is NOT a faithful depth. Filtered to
`type_id`, SeqDriver (uvm-1.2), CONTROL binary — 8 rows on each side, and the
CONTAINER AND INDEX MATCH ON EVERY ONE:

| container | index | golden (LHS) | ours (RHS) |
|---|---|---|---|
| `package adpcm_pkg` | 20 | `adpcm_pkg::type_id` @468:12-468:34 | same name, same span |
| `package adpcm_pkg` | 50 | `adpcm_pkg::type_id` @440:12-440:31 | same |
| `module_inst <anon>` | 20 / 50 | same two | same |
| `module_inst work@top_tb` | 20 / 50 | same two | same |

The only per-row differences `tslist` prints are `parent=module_inst:<anon>`
(golden) against `parent=class_defn:adpcm_seq_item` / `adpcm_driver` (ours), and
a `VpiFile` golden fills and we leave empty — **and neither is cmp-visible**
(`BaseClass::Compare`, §1). So R4b as the brief states it cannot be the head.

`ctsfield.cpp` then names the field, printing exactly what
`class_typespec::Compare` reads, in compare order:

```
golden (LHS)  adpcm_pkg::type_id @440:12-440:31
  classType=0 automatic=0 extends=0 variables=null taskfuncs=null constraints=null
  parameters=1 paramassigns=1 vifvars=null namedevents=null namedeventarrays=null
  scopes=null classdefn=uvm_object_registry
ours   (RHS)  adpcm_pkg::type_id @440:12-440:31
  … parameters=NULL paramassigns=NULL …            <- the ONLY cmp-visible difference
```

**Every other cmp-visible field is EQUAL on both of SeqDriver's two objects.**
The head is the `Parameters()` vector, which is pass 54's residue **R1**.

### 3a. THE POPULATION, and why R1 is a SeqDriver-ONLY law

`ctscen.sh` census of EVERY `class_typespec`, control binary, `default` mode.
`parameters` is reported as `null` / `empty` / `>=1` separately because
SafeCompare treats null-vs-empty as EQUAL and non-empty-vs-null as a FAIL:

| test (UVM version) | side | class_typespec | parameters `null` | `>=1` |
|---|---|---|---|---|
| SeqDriver (uvm-1.2) | golden | 9748 | 9686 | **62** |
| SeqDriver (uvm-1.2) | ours | 8789 | 8789 | **0** |
| SimpleUVM (uvm-1.2) | golden | 5882 | 5882 | **0** |
| SimpleUVM (uvm-1.2) | ours | 6154 | 6154 | **0** |
| BuildUVMPkg (1800.2) | golden | 5932 | 5932 | **0** |
| BuildUVMPkg (1800.2) | ours | 6371 | 6371 | **0** |

**Two tests on the SAME UVM version disagree**, and the reason is measured, not
argued: `ctsparams.sh` shows SeqDriver golden's 62 are 58 `type_id` + 2
`adpcm_pkg::type_id` + 2 `this_type`, in exactly TWO groups keyed by the generic
(`uvm_object_registry` -> T = `adpcm_seq_item` @440:31-440:65 and
`uvm_component_registry` -> T = `adpcm_driver` @468:35-468:65) — i.e. every
member is a `clone_tree` of ONE base, which is why they all carry the base's
parameters AND the base's span. And the SPAN histogram of the `type_id`
class_typespecs says which base was walked first:

| test (UVM version) | golden's `type_id` spans |
|---|---|
| SeqDriver (uvm-1.2) | 49 @440:12-440:31 + 9 @468:12-468:34 |
| SimpleUVM (uvm-1.2) | 48 @453:12-453:31 + 7 @483:12-483:34 |

Read in `uvm-1.2/src/macros/uvm_object_defines.svh`: **440** and **468** are the
`_internal` typedefs `uvm_object_registry#(T,`"S`")` /
`uvm_component_registry #(T,`"S`")` (two arguments), **453** and **483** are the
`_param` ones `uvm_object_registry #(T)` / `uvm_component_registry #(T)` (one).
`uvm_object_utils` expands to the first pair, `uvm_object_param_utils` to the
second (lines 245-262 and 330-344 of the same file). So the whole 62-vs-0
difference between two same-version tests is **WHICH typedef Surelog's
`bindTypedefs_` walked first**, and R1 must be modelled on the SeqDriver base,
not the SimpleUVM one. **This is the corpus conflation trap the brief warns
about, sitting inside ONE UVM version.** Not taken here (§7, R1).

## 4. WHAT I DID NOT TOUCH, AND THE MEASUREMENT FOR EACH

* **Target 2 (R4)**: census CONFIRMED exactly — BuildUVMPkg (1800.2-2017-1.0)
  golden 4 `ref_var (…::__deferred_init::rgtry)` / 0 `int_var`, ours 0 / 4.
  The source is `pp_output/uvm_pkg.sv:14104` `Tregistry rgtry = Tregistry::get();`
  inside `class uvm_registry_common #( type Tregistry=int, … )` declared at
  14031, and golden's typespec `int_typespec @14031:45-14031:48` is the type
  PARAMETER's own `int`, not the declaration's. So the law is "a variable whose
  DECLARED type is a type PARAMETER is a `ref_var` typed by the parameter's
  typespec, with no `vpiSigned`" — a variable-KIND replace. **Declined**: total
  `ref_var` occurrences are 3537 golden / 3405 ours on that test, so the
  population is NOT the 4 the head names, and a kind replace over an
  unmeasured population is not a one-pass edit. Residue **R2**.
* **Target 1 (R1)** — §3a. Residue **R1**.
* **Target 4 (R7-of-pass-54)** — nine sites, not three (§0). Not cmp-visible.
  **Declined**, and additionally because it changes `vpiFullName` bytes on every
  law-4 row, which would blur gate 5's mover attribution — the only evidence
  this pass has that its own law is surgical. Residue **R4**.
* **Pass 54's R10** (`classNestedTdGroupPointerOrder54`, "a 6-line fix worth
  taking on any pass that re-gates anyway"). **Declined for the same reason**:
  it re-orders minted objects and would put byte movers on every row with a
  class-nested typedef group, so gate 5 could no longer say "the movers are
  exactly the target rows". Cheap edit, expensive evidence. Residue **R5**.

## 5. DRIVERS AND THEIR EXERCISED GUARDS

**Every asset below was RUN in this pass.** No tool is named here that I did not
invoke, and no guard is cited that I did not exercise.

| asset | what it is, and the guard I fired |
|---|---|
| `pbuild.sh` | **new** — builds one C++ probe against the installed UHDM. GUARD: a compile failure is exit 1 with the compiler's output. **FIRED**: `tslist` and `ctsfield` both failed to compile first time (`VpiFullName` on `BaseClass`, an ambiguous `Restore` overload, a missing `kindOf`) and the driver refused to produce a binary rather than leave a stale one. Prints the built path and its md5. |
| `tslist.cpp` | **new** — the `Typespecs()` vector of every container, IN POSITIONAL ORDER, with each element's index/kind/name/span/parent. This is the instrument that REFUTED target 1 (§3). GUARDS: a database with no design is `UNMEASURED: no design` + exit 4; a NULL vector prints `<null-vector>` distinctly from an empty one. |
| `ctsfield.cpp` | **new** — every `class_typespec` matching a name filter, printing EXACTLY the fields `class_typespec::Compare` reads IN COMPARE ORDER, with the dump-only ones in a separate trailing group, plus per-`vpiParameter` and per-`vpiParamAssign` detail. Reaches objects through `Serializer::AllObjects()` so no traversal order can hide one. GUARD **FIRED**: with a filter matching nothing it printed `UNMEASURED: 0 class_typespec matched` and exited 4. |
| `asgat.cpp` | **new** — every `assignment` / `method_func_call` at a file:line (or `all`), with `assignment::Compare`'s own fields, `VpiFile`, and the parent chain. This is the instrument that found the NULL `vpiRhs`. GUARD **FIRED**: `asgcen.sh` on `uvm_registry.svh:207` printed `asgat rc: golden=0 ours=4` — i.e. exit code **4** with `UNMEASURED: 0 objects matched` on OUR side, which is how I learned our objects carry an EMPTY `VpiFile` and that a FILE filter cannot be used against our databases at all. A silent "0 rows" there would have read as "we do not emit the assignment", which is FALSE — re-running with an empty file filter found it at once, with `rhs=<null>`. |
| `ctscen.sh` | **new** — the `class_typespec` parameter census, both sides of one workdir row; counts NULL and EMPTY vectors separately. Propagates `ctsfield`'s exit 4 per side. |
| `ctsparams.sh` | **new** — lists every parameter-carrying `class_typespec`. GUARD: zero such rows is `ZERO parameter-carrying class_typespec` + exit 5. |
| `newcen.sh` | **new** — the `new`-call census of one row: NULL-Rhs count, `Rhs=mfcall(new)` count, `new` / `super.new` totals, BOTH sides. The table in §0 is its output. |
| `asgcen.sh` | **new** — `asgat` on both sides of one row at one file:line, printed side by side. |
| `armasg.sh` | **new** — the arm cell table: every assignment and mfcall in both sides of a `gold.sh` outdir, sorted and diffed. |
| `wdump.sh` | **new** — dumps BOTH sides of one workdir row and prints cmp lines / heads AND dump content +/-. GUARDS: both databases existence-checked (uhdm-cmp exits 0 on a missing input); dumps through `sed '1d'`; the golden CACHE DIRECTORY turned into `…/golden.uhdm`; cmp's own rc captured immediately. |
| `dumpdist.sh` | **new** — the dump distance under BOTH campaign conventions, so a figure from one pass can be compared with a figure from another without guessing. GUARD: a missing/empty dump is exit 6. **This driver is why §0's discrepancy is stated as a discrepancy and not as a refutation.** |
| `canaudit.sh` | **new** — AUDITS `canaries.sh` and `ctcan2.sh` against the brief's protected list, name by name, and asserts the four SLANG-FENCED names appear in NO driver here. **BOTH negative controls RUN**: renaming `Earlgrey_0_1` in a copy of `canaries.sh` makes it print `Earlgrey_0_1 UNCOVERED` and exit **5**; planting a file that mentions `TopParam` makes it print `FENCE-BREACH` and exit **6** (the file was removed afterwards). The auditor EXCLUDES ITSELF from the fence search — it must name the fenced tests to look for them — and the planted-breach control is what proves the exclusion did not disable the check. |
| `rowheads.sh` | copied from `r10uvm54repro`. GUARDS **BOTH FIRED** in the control run: `SKIP-NOFILE` for `Scoreboard,testflags`, and `UNKNOWN-NAME` for a deliberately injected `ZZZ_TYPO_NOT_A_TEST`. |
| `gold.sh` | copied. Tool existence checks on both arms; prints the slang binary's md5 on every run (that is how each arm run below is attributed to a binary). |
| `canaries.sh` | copied, 37 names. **NEGATIVE CONTROL RUN**: injecting `ZZZ_TYPO_NOT_A_TEST` makes it appear BY NAME and the unknown count go 28 -> 29 on the u2r csv. |
| `ctcan2.sh` | copied from `r10oth7repro` — the ONLY script covering the `EvalFunc` (10 rows), `ParamFile` (8) and `Black*` (34) families. **NEGATIVE CONTROL RUN**: with the WRONG `EXPECT_UNKNOWN` (1 instead of 6 on a u2r csv) it exits **6**. |
| `csvdiff.py` | copied — whole-row diff against the committed baseline, row counts from the parsed dict. |
| `manifest.sh` / `bvcompare.sh` | copied — the byte verifier. GUARDS exercised in §10. |
| `detcheck.sh` | copied — N runs of one binary on one input. §10b. |
| `a1/dut.sv` | **new** — 11 cells: the corpus shape, its concrete-class controls in the SAME generic body, a bare `new` with no parens, slang's OTHER badExpr branch (`type T1 = int`), an assoc-array-element target, a declaration-initialiser control and a non-generic control. Two cells cost an arm run each and both costs are recorded in the file's own comments (the derived class's IMPLICIT 0-argument constructor; the abstract base needing an explicit `new`). |

## 6. THE NEW HEAD — named, and shown to be PRE-EXISTING

SimpleUVM and Scoreboard now land on the same object, and it is one **WE** hold
and golden does not (so the `<null>` is on the LHS this time):

```
LHS: <null>
RHS ours: class_var (uvm_pkg::uvm_object_registry::create::create) @250:19-250:20
          |vpiParent  ref_obj (…::create::create) @259:16-259:22
          |vpiTypespec ref_typespec -> class_typespec (anonymous)
```

**PRE-EXISTING, measured not argued**: `class_var:
(uvm_pkg::uvm_object_registry::create::create)` appears **3 times in the CONTROL
database's dump, 3 times in the FINAL one, and 0 times in golden's**. The law
touches neither `class_var` minting nor `ref_obj` binding; the object was simply
behind the removed head. It is residue **R3**.

## 7. RANKED RESIDUE — most reachable first, ONE number per residue

**R1. `classNestedTdCarriesSpecParams55` — a class-nested class-handle typedef of
a `#(...)`-SPECIALIZED generic carries a `vpiParameter` `type_parameter` and a
`vpiParamAssign` in golden and NOTHING in ours. DIRECTION: ADD (a vector).
Depth: medium. RANK 1, and it is SeqDriver's cmp head in BOTH modes (85 lines,
1 head) — worth 2 rows.** Population, both sides, measured (§3a): SeqDriver
(uvm-1.2) golden **62** parameter-carrying `class_typespec` of 9748, ours **0**
of 8789; SimpleUVM (uvm-1.2) and BuildUVMPkg (1800.2-2017-1.0) golden **0**, so
**the law is SeqDriver-only and must be modelled on SeqDriver's base**. The
shape to mint, per member (from `ctsfield`): one `type_parameter` named `T`,
LOC-LESS, `vpiFullName = <owner key>::<typedef name>::T` (and
`work@top_tb.adpcm_pkg::type_id.T` for the module-clone base), typed by a
`ref_typespec` of the same fullname whose `vpiActual` is the SPECIALIZATION
ARGUMENT's `class_typespec` (`adpcm_seq_item` @440:31-440:65 /
`adpcm_driver` @468:35-468:65); plus one `param_assign` with `vpiRhs` = that
type_parameter and `vpiLhs` = the GENERIC's own type parameter
(`uvm_pkg::uvm_object_registry::T` @189:34-189:35 /
`uvm_component_registry::T` @51:37), `vpiOverriden` 0. This is pass 54's R1 with
the population and the shape now measured; pass 54's "NOT a corpus head" note
was right for SimpleUVM/BuildUVMPkg and wrong for SeqDriver.

**R2. `typeParamTypedLocalIsRefVar` — a local variable whose declared type is a
class TYPE PARAMETER is a `ref_var` in golden, typed by the PARAMETER's own
typespec and carrying NO `vpiSigned`; we emit an `int_var` with `vpiSigned:1`
typed by its own declaration text. DIRECTION: REPLACE (kind), with typespec and
`vpiSigned` as two further halves. Depth: unknown. RANK 2, and it is
BuildUVMPkg's cmp head in both modes (58 lines, 1 head) — worth 2 rows.**
Both sides on the CONTROL database, BuildUVMPkg (1800.2-2017-1.0): golden **4**
`ref_var (uvm_pkg::uvm_registry_common::__deferred_init::rgtry)` / **0**
`int_var`; ours **0** / **4**. Golden's typespec is `int_typespec
@14031:45-14031:48` — the `int` of `type Tregistry=int` in the class header — and
ours is `int_typespec @14104:6-14104:15`, the declaration's own `Tregistry` text.
The BLOCKER before writing it: total `ref_var` occurrences are golden **3537** /
ours **3405** on that test, so the affected population is larger than the 4 the
head names and must be censused first (the next pass should extend
`ctsfield.cpp`'s pattern to variables).

**R3. `objRegistryCreateClassVarExtra` — we hold a `class_var
(uvm_pkg::uvm_object_registry::create::create)` @250:19-250:20, parented at a
`ref_obj` @259:16-259:22 and typed by an ANONYMOUS `class_typespec`, that golden
does not hold at all. DIRECTION: DROP. Depth: unknown. RANK 3, and it is
SimpleUVM's and Scoreboard's NEW cmp head (29 lines, 1 head) — worth 3 rows.**
Ours 3 dump occurrences on BOTH the control and the FINAL database, golden 0
(§6). PRE-EXISTING.

**R4. `containerPrefixJoiner` at NINE sites — pass-50 law 4 writes
`prefix + prefix + name` for an alias `vpiFullName`. DIRECTION: REPLACE.
Depth: shallow per site. RANK 4, and it is DUMP-ONLY.** `grep -c 'prefix +
prefix' src/ParamEmit.cpp` = **9** (17804, 18038, 18183, 18389, 18767, 18828,
18850, 19032, 19237); the brief said three. Site 19237 takes its name from
`pkgClassTd9` rather than a `TypeAlias`, so it is a different edit inside the
same rule. `surelogClassKey54` DOES exist (`include/UhdmExporter.h:3037`,
`src/UhdmExporter.cpp:2189`, used at :2386) — that half of the brief is
CONFIRMED. Declined here because it changes bytes on every law-4 row and would
blur gate 5.

**R5. `classNestedTdGroupPointerOrder54` — carried from pass 54 UNCHANGED and
re-declined. DIRECTION: REORDER. Depth: 6 lines. RANK 5, and it is NOT
OBSERVED.** Re-measured on the FINAL binary with `detcheck.sh` (§10b) rather
than inherited.

**R6. `typeParamDeclInitEmitsExtraAssignment` — `T obj = new();` (a DECLARATION
initialiser) gives us an `assignment` + `method_func_call` and golden NOTHING.
DIRECTION: DROP. Depth: shallow. RANK 6.** Arm a1 cell C5 `@63:11-63:22`,
identical before and after this pass. It is also why our corpus
`Rhs=mfcall(new)` count stays ABOVE golden's after the law (SimpleUVM 400 vs
341), so it is the next thing to look at in this family.

**R7. `assocElemLvalueSpan` — an assoc-array-element assignment target's
`bit_select` spans the WHOLE `pool[key]` text in ours and only the INDEX in
golden. DIRECTION: RESHAPE (span). Depth: shallow. RANK 7.** Arm a1 C11:
golden `@140:22-140:25`, ours `@140:13-140:26`; unchanged by this pass.

**R8. `ourObjectsCarryNoVpiFile` — every `assignment` in our databases has an
EMPTY `VpiFile` where golden carries the absolute source path. DIRECTION: ADD.
Depth: unknown. RANK 8, and it is DUMP-ONLY** (`BaseClass::Compare` reads
VpiType/VpiName/VpiDefName only). Measured on SimpleUVM (uvm-1.2): all 5
line-207 assignments print `file=''` on our side and the full path on golden's.
It is why a file filter cannot be used against our databases and it cost this
pass one wrong turn (§5, `asgat.cpp`).

**R9. `scopedClassTsNameDropsSpecialization`** — pass 53's R2 / pass 54's R6,
carried forward UNCHANGED and NOT re-measured here. Site:
`grep -n 'rawText(sn0->sourceRange())' src/TypeEmit.cpp`.

**R10. `assocArrayVarCarriesElemSign`** — pass 52's R4, carried forward
UNCHANGED and NOT re-measured here.

**R11. the `LHSgolden=BOUND / RHSours=NONE` half of the ref_obj binding table,
302 disagreements** — pass 53's R6, carried forward UNCHANGED and NOT
re-measured here.

## 8. GATES — all five, as separate steps, with MY numbers

| gate | result |
|---|---|
| 1. `cmake --build build -j 3` | rc 0, `Built target slang_uhdm`. md5 printed BEFORE and AFTER: control `9d3e335a2b43dcbf698cdf2a0d8598bf` -> FINAL **`549f2c2ad003c05414107ea6a9af1d21`**. **THE md5 CHANGED**, asserted before any gate ran, so nothing below ran on a stale binary. The control md5 is byte-identical to the main-tree `build/slang-uhdm` at 0c08a3f. No rebuild happened while a sweep was running (§10's restore rebuild came after gate 4 finished and before gate 5's control sweeps started). |
| 2. 23 goldens, `SLANG_UHDM` exported to MY build | **PASS 23 / FAIL 0** |
| 2b. negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** — the harness really used the exported binary |
| 3. uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir` | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; `csvdiff.py` vs `results/gate_uhdm2rtlil.csv` **ROW DIFFS 0** (baseline rows 731, new rows 731) |
| 4. surelog, `--mode both --jobs 2`, own `--out`/`--workdir` | §9 |
| 5. byte verifier, BOTH corpora, same workdir paths | §10 |

## 9. GATE 4 — the surelog corpus

`--mode both --jobs 2 --out /tmp/r10uvm55_sl.csv --workdir /tmp/r10uvm55_sl_wd`,
`SLANG_UHDM` exported to my build, md5 `549f2c2a` printed by the launcher.

* `default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL**; `testflags` **463 / 10** —
  exactly the 0c08a3f figures the brief quotes, re-measured here.
* totals **930 CMP_EQUAL / 23 CMP_NOTEQUAL / 570 SLANG_REJECT / 48 SURELOG_FAIL
  / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM**.
* dump **390 match / 540 differ / 658 blank** — **THE MATCH COUNTS DID NOT
  FALL** (390 = 225 default + 165 testflags).
* `csvdiff.py` vs `results/golden_surelog.csv`: **ROW DIFFS 0**, whole row,
  status AND dump; baseline rows 1588, new rows 1588.
* `LowMemPkg,testflags` reproduced its baseline row (`SURELOG_FAIL/`) with its
  absolute session-scratchpad path; NOT touched, NOT reported as a regression.

**Canaries, INDIVIDUALLY BY NAME** (`canaries.sh`, 37 names): **ok=58 changed=0
absent=0 unknown-names=8**, rc 0 — exactly the documented surelog numbers. Both
live fragile conversions intact: `InterfaceModPort` CMP_EQUAL/differ in BOTH
modes, `BlackParrotComplex` CMP_EQUAL/differ in BOTH modes. `SVSwitch`
CMP_NOTEQUAL/CMP_NOTEQUAL, `Earlgrey_0_1` CMP_NOTEQUAL/SLANG_REJECT,
`LowMemPkg` CMP_EQUAL(match)/SURELOG_FAIL — all at baseline.
**NEGATIVE CONTROL RUN** (on the u2r csv, where the list is smaller and the
count is unambiguous): injecting `ZZZ_TYPO_NOT_A_TEST` makes it appear BY NAME
and the unknown count go **28 -> 29**, so a typo'd canary cannot read as green.

**FAMILY canaries** (`ctcan2.sh`, the ONLY script covering them):
on the surelog csv **ok=58 changed=0 absent=0 unknown-patterns=1** with
`EXPECT_UNKNOWN=1`, **PASS** — `EvalFunc*` **5 names = 10 rows**, `ParamFile*`
**4 names = 8 rows**, `Black*` **17 names = 34 rows**, which is exactly the
brief's 10 / 8 / 34. On the u2r csv **ok=1 unknown-patterns=6** with
`EXPECT_UNKNOWN=6`, **PASS**.
**NEGATIVE CONTROL RUN**: with the WRONG expectation (`EXPECT_UNKNOWN=1` on a
u2r csv) it exits **6** and prints the measured expectations.

**CANARY-COVERAGE AUDIT** (`canaudit.sh`, new): all **26** brief-protected names
and all **3** brief-named families are carried by a script that RAN here
(UNCOVERED 0), and the four SLANG-FENCED tests **`UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam` appear in NO driver in this
directory** (FENCE-BREACH 0) — measured, not asserted. **Both of the auditor's
own negative controls RUN**: an uncovered name -> exit **5**, a planted mention
of a fenced test -> exit **6**.

### 9a. per-row cmp and dump distance, all four target rows

`rowheads.sh` on the GATE-4 workdir (the same numbers as on the separate 4-test
workdir, both modes):

| test (UVM version) | mode | cmp lines / heads, control | cmp lines / heads, FINAL |
|---|---|---|---|
| SimpleUVM (uvm-1.2) | default / testflags | 13 / 1 (both) | **29 / 1 (both)** |
| Scoreboard (uvm-1.2) | default | 13 / 1 | **29 / 1** |
| Scoreboard (uvm-1.2) | testflags | SKIP-NOFILE (SLANG_REJECT at baseline) | SKIP-NOFILE |
| SeqDriver (uvm-1.2) | default / testflags | 85 / 1 (both) | **85 / 1 (both)** |
| BuildUVMPkg (1800.2-2017-1.0) | default / testflags | 58 / 1 (both) | **58 / 1 (both)** |

Dump content +/- , `default` mode, MY convention (§ header):

| test (UVM version) | control | FINAL | our dump lines |
|---|---|---|---|
| SimpleUVM (uvm-1.2) | 238411 | **238132** (-279) | 1100377 -> 1100472 (+95) |
| Scoreboard (uvm-1.2) | 226795 | **226760** (-35) | 1096965 -> 1097060 (+95) |
| BuildUVMPkg (1800.2-2017-1.0) | 167353 | **167341** (-12) | 1076195 -> 1076279 (+84) |
| SeqDriver (uvm-1.2) | 513534 | **518721 (+5187)** | 1808884 -> 1808979 (+95) |

**SEQDRIVER'S DUMP DISTANCE ROSE, AND I AM NOT HIDING IT.** `dumpdist.sh`'s
split says what happened: golden-only lines **337579 -> 340125 (+2546)** and
ours-only **175955 -> 178596 (+2641)** — BOTH halves rose by ~2600 while our file
grew by only **95** lines. ~2550 lines that previously matched are now counted on
both sides: `diff` picked a different LCS and RESYNCHRONISED over a large region.
That is the "dump content is a ROUGH DISTANCE" method law, and it is why the
other three rows fell while this one rose on the SAME 7-site change. What I can
state as measured: SeqDriver's **cmp answer is unchanged (85 / 1, both modes)**,
its per-field census moved by exactly **-7 NULL-Rhs / +7 mfcall(new)** like every
other row, and gate 5 confirms its byte change is confined to that row. What I
have NOT proved is that no content regressed inside the resynchronised region —
so this is recorded as an open measurement, not as a clean result.

## 10. GATE 5 — the byte verifier, BOTH corpora

Run BACKWARDS, as passes 50-54 did. The POST manifests come from the gate-3 and
gate-4 sweeps on `549f2c2a`; then the source was restored to pristine 0c08a3f
(`git checkout 0c08a3f -- src/ExprEmit.cpp`, **never `git stash`**), rebuilt —
**the control md5 `9d3e335a2b43dcbf698cdf2a0d8598bf` was REPRODUCED exactly** —
and re-run into the **SAME workdir paths**. My edited file was copied to
`/tmp/r10uvm55_mine/` first (md5 `333e575d44e324cd205d360b6b56347a`) and the
`git diff 0c08a3f` taken before the restore was saved
(md5 `4e7866ceb03c90079e0fc3b91b89f85c`) so the restore can be proved
byte-identical afterwards.

Both control sweeps reproduced the committed baselines exactly (`csvdiff.py`
**ROW DIFFS 0** against both), which independently validates them as controls.

| corpus | head dbs | post dbs | paired | identical | DIFFER | UNPAIRED |
|---|---|---|---|---|---|---|
| uhdm2rtlil (`testflags`) | 679 | 679 | 679 | **679** | **0** | **0** |
| surelog (`both`) | 953 | 953 | 953 | **946** | **7** | **0** |

Path sets IDENTICAL on both corpora (UNPAIRED 0, printed explicitly).

### 10a. THE 7 MOVERS ARE EXACTLY THE 7 COMPARABLE TARGET ROWS AND NOTHING ELSE

```
  [TARGET, and also KNOWN-NONDETERMINISTIC — neither clean evidence nor a clean pass]
                                         default/Scoreboard-59431470/slang.uhdm
  MOVER default/BuildUVMPkg-bf853d43     MOVER testflags/BuildUVMPkg-bf853d43
  MOVER default/SeqDriver-32af76aa       MOVER testflags/SeqDriver-32af76aa
  MOVER default/SimpleUVM-1dc93a62       MOVER testflags/SimpleUVM-1dc93a62
```

**ZERO collateral out of 1632 databases** (679 u2r + 953 surelog), which is the
bar the brief set. `Scoreboard,testflags` is `SLANG_REJECT` and emits no
database, so seven movers is every comparable target row and nothing besides.

**THE LAW'S REACH, counted rather than assumed.** It fires at **7** sites per
uvm-1.2 test (SimpleUVM, SeqDriver, Scoreboard), **6** on BuildUVMPkg
(1800.2-2017-1.0), **5** cells in arm a1, and — by gate 5's zero collateral —
**0 sites in all 679 uhdm2rtlil databases and in the other 946 surelog
databases**. A fix that reaches nothing measures zero and reads as a refutation;
this one reaches exactly the four UVM tests, and that is why the u2r corpus is
byte-identical rather than merely status-identical.

**Comparator NEGATIVE CONTROL, RUN:** flipping ONE character of ONE hash in the
u2r POST manifest makes `bvcompare.sh` report
`identical 678 / DIFFER 1 / MOVER testflags/1DUnpackedArray-a9848385/slang.uhdm`,
so a real difference cannot pass unnoticed. **Second guard, RUN:** joining the
u2r head manifest against the surelog POST manifest gives
`paired: 0 / REFUSING TO REPORT: the two manifests share no path` and **exit 5**,
so a mis-paired verifier cannot report "0 differ".

**THE GATED BINARY IS THE SHIPPED SOURCE.** After gate 5 the restored file was
put back (`md5 333e575d44e324cd205d360b6b56347a`), the `git diff 0c08a3f` taken
AFTER the restore is **byte-identical** to the one taken before it (both
`md5 4e7866ceb03c90079e0fc3b91b89f85c`), and one more build came out
**`549f2c2ad003c05414107ea6a9af1d21`** again.

### 10b. DETERMINISM — measured ON THE BINARY THAT HAS THE LAW

`detcheck.sh`, 4 runs each. Pass 54's integration correction C8 was that a
determinism claim must be measured on the binary that HAS the law, and that the
Scoreboard flake needs a CONTROL cell; both are done here.

| binary | input | distinct sha256 in 4 runs |
|---|---|---|
| FINAL `549f2c2a` | arm a1 | **1** |
| FINAL `549f2c2a` | BuildUVMPkg (1800.2-2017-1.0) | **1** |
| FINAL `549f2c2a` | **Scoreboard (uvm-1.2)** | **3** |
| control `9d3e335a` | **Scoreboard (uvm-1.2)** | **2** |

`invalidNewCallFromSyntax55` mints its objects on a straight-line syntax walk
with no pointer-keyed container, so it has no ordering hazard of its own, and
the two non-Scoreboard cells are 1-of-4 on the binary that has it. **Scoreboard's
3-of-4 on FINAL against 2-of-4 on the CONTROL is the KNOWN PRE-EXISTING
macro-buffer flake** — it flakes on the control too, which is the control cell,
and it is why `bvcompare.sh` labels Scoreboard's byte mover as neither clean
evidence nor a clean pass. Its cmp answer was stable at 29 / 1 across the
separate 4-test workdir and the gate-4 workdir.
