# r10uvm56 — THE HEAD ON ALL THREE TARGET ROWS IS CLEARED; TWO laws; the brief's own law statement REFUTED and REPLACED

**FIRST LINE, as the brief demands: the head DID clear.** The
`LHS: <null> / RHS: class_var (uvm_pkg::uvm_object_registry::create::create)`
head is gone from SimpleUVM (both modes) and Scoreboard (default), and the new
head is characterised in §7. **No row converted** — all four UVM rows stay
`CMP_NOTEQUAL`, and every gate reads 0 differing rows against the committed
baselines.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`~/.local/bin/uhdm-cmp` and every driver here passes `(golden.uhdm, ours.uhdm)`
in that order and prints that it did.

---

## 0. MASTER'S INTEGRATION ADDENDUM — verdict PASS, two comment fixes, five recorded corrections

The verifier reproduced every number on its own build from a fresh pristine twin,
built **four arms the pass never built** (`v1_scopes2`, `v2_call`, `v3_hierpath`,
`v4_methodkinds` — 62 further return-name cells and 51 further local cells, all now
in this directory) and found **ZERO over-fires** plus 14 further over-binds that
the law correctly clears. No finding was a defect in the shipped code. Two of them
were nevertheless applied to the CODE, because both were statements a future
reader would act on:

| # | what it corrects | applied |
|---|---|---|
| **name vs predicate** | `§ retNameNewLhsNoBind56`'s name says `new`-Lhs; the code is `parent->UhdmType() == uhdmhier_path` and nothing narrower — ANY hier_path-parented return-name ref at ANY scope. The width is CORRECT (arm `v3_hierpath` puts SOURCE-built hier_paths — struct member as lvalue and as a read, class-handle member, a NESTED member — at module and package scope and golden binds **0 of all 26**; ours over-bound only the 4 `= new()` sites and now agrees). | **CODE COMMENT REWRITTEN** — "READ THE PREDICATE, NOT THE NAME". The § marker is kept because it is already the greppable name at four sites. |
| **F1** | "the two consumers that run after this point are proved not to reach these refs" is true of OUR passes only. After `exportDesign()` returns, `uhdm_main.cpp:471–506` runs UHDM-LIBRARY consumers that DO read `Actual_group` (`ElaboratorContext` + `UhdmAdjuster` under `-elabuhdm`, `SynthSubset` under `-synth`), and **636 surelog testflags rows carry `-elabuhdm`**. Risk is bounded to zero EMPIRICALLY — none of the 636 moved, and the three UVM testflags movers carry no `-elabuhdm`. | **CODE COMMENT EXTENDED** at `retNameNoBind56`, so any future widening re-prices it; a within-emitter grep cannot see those consumers. |

Recorded, not code: **F2** the report's canary figures (`ok=9/28`, `ok=58/8`) came
from `r10uvm55repro/canaries.sh` (37 names), not the brief's
`r10uvm52repro/canaries.sh` (33 names, `ok=8/25` and `ok=52/7`) — coverage is not
weakened (33 is a strict subset of 37) but the script must be named; I ran the
brief's, and both read `changed=0 absent=0`. **F3** `retlist.py` reporting
`OVERBIND 0` is true of that instrument while its sibling `retx.py` still shows 2
`gx oB` cells on SimpleUVM — the macro-buffer coordinate residue ranked R3, classed
differently by construction, not a regression. **F4** the two named canaries are
`CMP_EQUAL/differ` rows, and a `differ` dump column is blind inside the database —
the verifier closed it by proving both databases BYTE-IDENTICAL between pristine
and patched in both modes. **F5** `SimpleUVM/testflags` is missing from the
movement table; its numbers are 29 → 29 cmp lines and 238654 → 238586. **F6** a
new residue only `v1` can see: for a class declared **inside an INTERFACE** ours
emits **no return-name reference at all** where golden emits three unbound ones
(`work@i1::i_in` @22:10, 23:14, 24:12) — reference EXISTENCE, not binding, present
in control and final alike, so not caused by this pass.

**A SEVENTH RESIDUE, found by ME re-running the verifier's own arms on the
integrated binary and then on a PRISTINE `946579a` (`ed106184`) to date it.**
Arm `v2_call` reports **1 differing LOCAL cell on BOTH binaries**:
`p2::der2::f2`'s `ref_obj (p2::der2::f2::y)` @29:24 — the ARGUMENT of
`f2 = super.f2(y) + 1` — is **unbound in golden and bound by us to
`io_decl (y)`**. It is an ORDINARY LOCAL (a formal), so this law cannot reach it
(`funcRetRefs` is pushed only when the symbol IS `sub.returnValVar`), and the
pristine run dates it as **PRE-EXISTING**. It belongs to the `super.<m>(args)`
family — see § superMethodCall17 and the § hierCallArgTakesBase39 marker — and
ranks after R6. Recorded because the pass's table reports v2 as "2 → 0" for its
RETURN-NAME column only, and a reader could take that as the whole arm agreeing.

**My own re-measurement of every arm on the integrated binary** — which also
carries r10svs2, so this doubles as that pass's non-interference check:
`a1_witness` 0/11, `a2_local` 0/17, `a3_scope` 0/28, `a5_argpos` 0/40,
`a6_type` 0/38, `a8_newlhs` 0/14, `v3_hierpath` **0/58**, `v4_methodkinds`
**0/35** — all zero differing. `v1_scopes2` 4 (F6's 3 interface-class NOREF cells
plus 1 pre-existing local) and `v2_call` 1 (the pre-existing local above), and its
RETURN-NAME column is **2 → 0** exactly as reported.

Base commit **946579a**, branch `auto5h`, own worktree
`.claude/worktrees/r10uvm56` with a PRISTINE 946579a twin at
`.claude/worktrees/r10uvm56pris` built from source in this pass.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 946579a) | `ed106184c97207183fe1316211507882` | **byte-identical to the main-tree `build/slang-uhdm`**, which is what makes it a valid control (`md5sum` on all three printed the same digest, §1) |
| FINAL (gated, shipped) | `de52f8be5bfa705510cb622cadad4d12` | every gate below ran on this binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **read only**; row counts come
from `ct8rows.sh`'s lines-minus-one, never from `wc -l`.

---

## 0. THE LAW, in the form a future pass can grep for

Two § markers, both applied in ONE design-final pass
(`grep -n 'RetNameNoBind56\|retNameNoBind56\|retNameRefs56' src include`):

### § classMethodRetNameNoBind56

> **A reference to a function's IMPLICIT RETURN VARIABLE carries NO `vpiActual`
> when the function is an IN-BODY CLASS METHOD.** The discriminator is the flag
> the emitted routine already carries: **`vpiMethod` = 1**, taken only in its
> CLASS half. An OUT-OF-BODY method's class listing carries `vpiMethod` = 0 and
> **keeps** the binding; a module function, a generate-block function and a
> package free function all keep it too.

### § retNameNewLhsNoBind56

> **A return-name reference that § invalidNewCallFromSyntax55 re-parented into
> the artefact `hier_path` of `<name> = new(...)` carries no `vpiActual`
> either.** Pass 55 nulls that reference at emit time on purpose;
> `drainFuncRet` runs LATER and was silently CLOBBERING the null whenever the
> lvalue was the return name.

DIRECTION for both: **DROP a binding, never add one.** Applied **design-final**,
after every pass that fills a null `Actual_group`, so nothing can re-bind what
is dropped; the return-variable object is still **minted** (exactly as
§ classRetNameDefViewNoBind37 leaves it) so serializer ids do not shift.

**Sites** — `src/TypeEmit.cpp` (`retNameNoBind56`, the law text and the pass),
`src/UhdmExporter.cpp` (the design-final call, immediately after pass 37),
`src/ModuleEmit.cpp` (the recording hand-off inside `drainFuncRet`),
`include/UhdmExporter.h` (`RetNameRefs56`). **+136 lines, 0 deletions, 4
files.** Nothing under `results/`, nothing under `~/.local`, no harness file.

---

## 1. FOUR REFUTATIONS OF THE BRIEF, each proved, because a refutation is worth more than agreement

### R-1. The brief's law statement is WRONG as written, and the arm that proves it is a3

The brief says:

> "the law to establish is: A REFERENCE TO A FUNCTION'S IMPLICIT RETURN VARIABLE
> CARRIES NO `vpiActual` IN GOLDEN, while a reference to an ordinary local does."

**That is false.** Golden binds **218** return-name references on SimpleUVM
alone (`retx.py`, §3) and **176 of 189** in the out-of-body-class-listing bucket
(`owntab.py`, §4). Arm `a3_scope.sv` puts a function at every scope in ONE
database and reads golden's binding off each — the grid is in §5.1 and it says
module, generate-block, package and out-of-body-class-method all BIND. Only the
IN-BODY class method does not. Had the brief's statement been implemented, it
would have dropped **218 correct bindings on SimpleUVM** and every one of them
is `agree` in the control.

### R-2. The rule does NOT key on `$cast`, on the argument position, or on the return TYPE

The brief builds its case on `$cast(create, obj)` and asks (question 6) whether
the rule keys on a CLASS HANDLE return. Both are refuted by their own arms,
golden side, at own child depth:

* `a5_argpos.sv`, class IN-BODY: `$cast` **2** refs, plain call **3**, function
  `output` formal **2**, `inout` formal **2**, plain-assignment lvalue **1** —
  golden binds **0 of all 11**. The identical five positions at module scope
  bind **11 of 11**. The position is irrelevant; the scope is everything.
* `a6_type.sv`, class IN-BODY: class handle **3**, `int` **3**, `string` **3**,
  packed struct **3** — golden binds **0 of all 12**. The same four types at
  module scope bind **3/3/3/1**. The rule does not see the type.

### R-3. Pass 55's "the ref's `Actual_group` is null on BOTH sides there" does not hold for a RETURN NAME

`src/ExprEmit.cpp:3227` nulls the artefact-`hier_path` Lhs ref and its comment
claims the field is null on both sides at the corpus sites. It is null on both
sides for an **ordinary local** (arm a8 cell `p_loc`, both sides bound to the
local; and `n_loc`, both sides unbound) — but for a **return name**
`drainFuncRet` re-binds it afterwards, so ours carried a binding golden never
had. Corpus witness: `uvm_mem_mam::reserve_region` at
`uvm_mem_mam.svh:742:10` and `:749:4`, **2 refs per test on all four UVM
tests**. Isolated witness: arm a8's module-scope `p_ret` (`OVERBIND` in the
control, `agree` in the final). This is a **pass-55 interaction defect**, not a
new law, and it is the only one this pass found.

### R-4. § classRetNameDefViewNoBind37's cell table does not describe what its own predicate does on this corpus

Pass 37's header table reports `ELABPKG uvm_pkg 343 GO / 27 gO` for class
methods. Under the `vpiMethod` split those 343 are **out-of-body class
listings** (`vpiMethod` = 0), not in-body methods — the two passes are talking
about different populations with the same words. Measured with the pass's own
debug hook, `SLANG_UHDM_DBG37=1` on SimpleUVM: **all 60** class entries
classify `def=0 top=1`, so **pass 37's class arm never fires on SimpleUVM at
all**; the 57 `cd=(nil)` entries (out-of-body methods reached as PACKAGE items)
are the ones it actually unbinds. Pass 37 is left **byte-for-byte unchanged**
here; this pass adds a disjoint arm rather than widening its gate.

### R-5. One brief figure I could not reproduce, reported as unreconciled rather than as a refutation

The brief says our side has "3 occurrences of that `class_var` in the SimpleUVM
dump". I measure the head's `class_var` id `181259` and its two children
(`ref_typespec` `181260`, `class_typespec` `181261`) — **3 OBJECTS**, printed at
more than one depth. "3 occurrences" and "3 objects" are two different
instruments (the standing law: *an object is NOT a dump occurrence*), and since
the fix removes all three either way I did not chase the distinction further.

---

## 2. WHY THE HEAD READ `LHS: <null>`, and the head itself, measured on BOTH sides

Transcribed from the control run (`d_ctrl/cmp.txt`, 29 lines, **1** head at
column 0 by `grep -c '^LHS:'`):

```
LHS: <null>
RHS:
decompile:
class_var: (uvm_pkg::uvm_object_registry::create::create), id:181259, line:250:19, endln:250:20
|vpiParent:
\_ref_obj: (uvm_pkg::uvm_object_registry::create::create), id:39355, line:259:16, endln:259:22
```

`ref_obj::Compare` chases `Actual_group`; the scalar `SafeCompare` overload with
`lhs == null && rhs != null` sets `m_failedRhs` and leaves `m_failedLhs` unset,
which is why the head prints the object OURS has. The site is
`uvm_registry.svh:259`, `$cast(create, obj)`, and `create` there is the
function's own implicit return variable. **The name is identical on both sides,
doubled final segment included — this was never a naming residue and the name
was not touched.**

The POSITIVE CONTROL is in the same statement and it is untouched by this pass:
`obj`, an ordinary function local, reads
`ref_obj 'obj' 259:24 -> class_var:obj(bare)` on **both** sides in the control
and in the final (`grep "'obj' 259:24" g.cen o.cen of_SimpleUVM.cen`).

---

## 3. THE CORPUS CENSUS THAT FOUND THE REAL PREDICATE (`retx.py` / `retlist.py`)

Key = (view, owning routine, ref kind, ref name, line:col); a RETURN-NAME
reference is one whose name equals the last `::`/`.` segment of its owner's
fullname. Position is **not** in the key, so a parent-shape change reads as a
cell move rather than an add plus a drop.

SimpleUVM, control, golden vs ours (`gB oB` = both bound, `gx oB` = **we
over-bind**, `gB ox` = we under-bind, `gx ox` = both unbound):

| | gB oB | gB ox | gx oB | gx ox |
|---|---|---|---|---|
| TOTAL over all views and parent kinds | **218** | 3 | **10** | 275 |

so **golden binds 218 of them** and the whole disagreement is 13 cells. The
`gx oB` over-binds, listed per test with `retlist.py … OVERBIND`, are **three
routines and nothing else**:

| routine | SimpleUVM | Scoreboard | SeqDriver | BuildUVMPkg |
|---|---|---|---|---|
| `*_registry::create` (`$cast(create,obj)`) | 2 | 2 | 2 | 1 (`uvm_registry_common::create`) |
| `uvm_tlm_generic_payload::do_compare` | 4 | 4 | 4 | 0 (absent in 1800.2) |
| `uvm_mem_mam::reserve_region` (`= new(...)`) | 2 | 2 | 2 | 2 |
| **total over-binds** | **8** | **8** | **8** | **3** |

**A TRAP THIS PASS FELL INTO AND CLIMBED OUT OF, recorded because a future pass
will hit it too:** on SimpleUVM the census's own view tag looked like the
predicate — golden binds **0 of 70** return-name refs in `ELABPKG` there. It is
NOT the predicate. On **Scoreboard** the same routines are tagged `ELABPKG` and
golden binds **218** of them. The r10uvm28g view tag depends on which package
objects a design happens to list and **is not stable across tests**; any law
built on it would have read green on one test and destroyed another. Checking
all four tests is what caught it.

---

## 4. THE PREDICATE, cross-tabbed on the FUNCTION OBJECT (`retown.cpp` + `owntab.py`)

`retown.cpp` reads the facts off the `function` object instead of the listing
that holds it. Return-name references bound / total, per `vpiMethod` bucket:

| test | bucket | golden | ours CONTROL | ours FINAL |
|---|---|---|---|---|
| SimpleUVM | `vpiMethod=1` inClass | **0 / 67** | 6 | **0** |
| SimpleUVM | `vpiMethod=0` inClass | 176 / 189 | 176 | 174 |
| SimpleUVM | `vpiMethod=0` noClass | 46 / 243 | 46 | 46 |
| Scoreboard | `vpiMethod=1` inClass | **0 / 67** | 6 | **0** |
| Scoreboard | `vpiMethod=0` inClass | 176 / 189 | 176 | 174 |
| SeqDriver | `vpiMethod=1` inClass | **0 / 68** | 6 | **0** |
| SeqDriver | `vpiMethod=0` inClass | 176 / 189 | 176 | 174 |
| SeqDriver | `vpiMethod=0` noClass | 100 / 675 | 92 | 92 |
| BuildUVMPkg | `vpiMethod=1` inClass | **0 / 39** | 1 | **0** |
| BuildUVMPkg | `vpiMethod=0` inClass | 173 / 183 | 173 | 171 |
| BuildUVMPkg | `vpiMethod=0` noClass | 48 / 237 | 46 | 46 |

**241 `vpiMethod=1` return-name references across the four tests and golden
binds NONE of them.** The `vpiMethod=0` buckets are where golden's 218 live and
ours already agreed there — which is why the FLAG and not a scope walk is the
predicate. `vpiMethod` is our own field
(`src/TaskFuncEmit.cpp:2613`, `protoOf || ((designScope || classScope) &&
(!oob || oobCtor))`) and it agrees with golden's on **every function object of
every arm and every UVM test** (identical `funcs=` counts in both halves of the
table above).

The `vpiMethod=0 inClass` figure falling 176 → 174 is § retNameNewLhsNoBind56
dropping `reserve_region`'s two artefact-hier_path bindings, which golden also
does not have; the residual 189 − 186 = 3 refs are ones **ours does not emit at
all** (ranked R2/R3 in §8).

---

## 5. THE ARM CELL TABLES

Eight arms, one `.sv` each, both sides listed at OWN CHILD DEPTH
(`arm.sh` builds, `cells.sh`/`cells.py` tabulate). A cell present on only one
side prints `NOREF` and counts as differing — never silently dropped.
`local cells` are the **positive control**: every reference in the same
databases that is NOT a return name.

| arm | what it isolates | return-name cells | LOCAL (control) cells | differing CONTROL | differing FINAL | dump content +/- control → final | cmp heads final |
|---|---|---|---|---|---|---|---|
| `a1_witness.sv` | the witness: in-body class method, `$cast(f,y)` / `f=x` / `return f` / `if (f==…)` | 8 | 3 | **2** | **0** | 82 → **45** | 1 |
| `a2_local.sv` | the POSITIVE CONTROL: the same four shapes on an ordinary local | 3 | 14 | **0** | **0** | 32 → **32** (byte-identical) | 1 |
| `a3_scope.sv` | a function at EVERY scope | 21 | 7 | **1** | **0** | 171 → **150** | **0 — cmp rc=0, this arm CONVERTED** |
| `a4_kinds.sv` | explicit `return` vs own-name assign; `void` function; task | 6 | 14 | **0** | **0** | 11 → **11** (byte-identical) | 1 |
| `a5_argpos.sv` | the return var as argument: `$cast`, plain call, `output`, `inout`, lvalue | 22 | 18 | **3** | **0** | 101 → **37** | 1 |
| `a6_type.sv` | return type: class handle vs `int` vs struct vs `string` | 24 | 14 | **3** | **0** | 162 → **100** | 1 |
| `a7_recur.sv` | the recursive self-call `f = f(x-1)` | 4 | 4 | **0** | **0** | 12 → **12** (byte-identical) | 1 |
| `a8_newlhs.sv` | `<name> = new(...)` as the return-name lvalue, plus the local control | 4 | 10 | **1** | **0** | 70 → **56** | 1 |
| **TOTAL** | | **92** | **84** | **10** | **0** | | |

**Every one of the 84 local (positive-control) cells agrees in the control and
in the final, and the three arms with no return-name over-bind (a2, a4, a7) are
byte-identical before and after.** That is the ordinary-local guarantee the
brief asked for, measured rather than asserted.

### 5.1 arm a3 — THE SCOPE GRID, golden side, which is what fixes the boundary

| scope | routine | golden bound / refs | verdict |
|---|---|---|---|
| module-level function | `work@a3_top.mf` | **3 / 3** | BINDS |
| generate-block function | `work@a3_top.gb.gf` | **3 / 3** | BINDS |
| package free function, DEF view | `p3::pf` | **3 / 3** | BINDS |
| package free function, ELAB view | `p3::pf` | **3 / 3** | BINDS |
| class OUT-OF-BODY method, ELAB view | `p3::c3::m_out` | **3 / 3** | BINDS |
| class OUT-OF-BODY method, DEF view | `p3::c3::m_out` | **0 / 3** | § 37's law, untouched |
| **class IN-BODY method** | `p3::c3::m_in` | **0 / 3** | **§ classMethodRetNameNoBind56** |

`vpiMethod` on those same objects (`retown.cpp`, both sides identical):
`m_in` = **1**; `m_out` (both views), `mf`, `gb.gf`, `pf` = **0**. Question 3 of
the brief is answered: the rule IS scope-bound, and the boundary is in-body vs
out-of-body, not class vs non-class.

### 5.2 arm a4 / a7 — the questions with a NEGATIVE answer, stated plainly

* an EXPLICIT-`return`-only function has **no return-name reference at all**, so
  there is nothing to bind and nothing to drop (`k_return`, `t_return`: 0 cells).
* a **`void` function** and a **task** have no return variable: 0 cells each,
  both scopes. `drainFuncRet` already guards on
  `!sub.returnValVar || getReturnType().isVoid()`.
* **recursion** is not special: `f = f(x-1)` at class scope is unbound on both
  sides (2 cells) and at module scope bound on both sides (2 cells). The name
  being both the function and the return variable changes nothing.

### 5.3 the fix firing, per reference, with the debug hook

`SLANG_UHDM_DBG56=1` prints one line per DROP. SimpleUVM:

```
DBG56 lawA uvm_pkg::uvm_component_registry::create 'create' 116:16
DBG56 lawB uvm_pkg::uvm_mem_mam::reserve_region 'reserve_region' 742:10
DBG56 lawB uvm_pkg::uvm_mem_mam::reserve_region 'reserve_region' 749:4
DBG56 lawA uvm_pkg::uvm_object_registry::create 'create' 259:16
DBG56 lawA uvm_pkg::uvm_tlm_generic_payload::do_compare 'do_compare' 459:9
DBG56 lawA uvm_pkg::uvm_tlm_generic_payload::do_compare 'do_compare' 473:9
DBG56 lawA uvm_pkg::uvm_tlm_generic_payload::do_compare 'do_compare' 483:9
DBG56 lawA uvm_pkg::uvm_tlm_generic_payload::do_compare 'do_compare' 493:10
DBG56 routines=139 lawA-drops=6 lawB-drops=2
```

**139 routines recorded, 8 references dropped** — exactly the 8 the census
predicted, with no collateral. Arms: a1 `lawA-drops=2 lawB-drops=0`,
a8 `lawA-drops=0 lawB-drops=1`.

---

## 6. THE HAZARD THE BRIEF NAMED: is anything left dangling?

`vpiActual` is a binding and dropping bindings is how references become
dangling. Two things make this safe and both were executed, not assumed:

1. **The drop is design-final, AFTER every pass that fills a null
   `Actual_group`.** `retNameNoBind56(d)` is called from
   `src/UhdmExporter.cpp` immediately after `classRetNameDefViewNoBind37(d)`.
   Only two passes run after it, and NEITHER can reach these references:
   * `§ thisImplicitNetBoth38` — `grep -n 'VpiName() != "this"' src/TypeEmit.cpp`
     shows its first guard; a return-name ref is never named `this`.
   * `§ castSizeParamRefBindFinal` — it walks a listing's `Parameters()` and
     only an `int_typespec`'s `Cast_to_expr`; a statement-level return-name ref
     is not reachable from there.
   * the four remaining design-final passes (`drainClassNestedTdGroups54`,
     `importPublishesPackageClasses24`, `classInheritsContainerImports23`,
     `modulePublishesPackageClasses45`) contain **zero** occurrences of
     `Actual_group` — checked by extracting each function body and grepping it.
2. **The precedent is identical.** `§ classRetNameDefViewNoBind37` has been
   doing exactly `r->Actual_group(nullptr)` on return-name refs, in the same
   place, for 19 passes. This pass adds a disjoint arm to the same field.
3. **The return-variable object is still MINTED.** The drop replaces only the
   final `r->Actual_group(lv)`, so no serializer id shifts and the only dump
   change is the disappearance of the now-unreachable `class_var` +
   `ref_typespec` + `class_typespec` triple — which is what golden has.

**And golden does emit a return-variable object elsewhere; "no binding" is not
"no object".** Censused separately: golden's `function::Return()` variable
exists on all 160 SimpleUVM functions that have return-name refs (it prints as
`ret=class_var()` / `ret=int_var()` etc. with an EMPTY `vpiName` in
`retown.cpp`'s output), including on `uvm_object_registry::create`. What golden
lacks is the per-reference `class_var` our drain mints, not the return variable
itself.

---

## 7. THE NEW HEAD, and the row-by-row movement

Old head **CLEARED on all three target rows.** New head, SimpleUVM and
Scoreboard alike (`f_SimpleUVM/cmp.txt`, 29 lines, 1 head):

```
LHS:
string_var: (uvm_pkg::uvm_object_registry::create::msg), id:139929, line:260:14, endln:260:17
|vpiParent:
\_begin: (uvm_pkg::uvm_object_registry::create), id:139927, line:259:30, endln:266:8
…
RHS: <null>
```

i.e. **golden's `begin` block at `uvm_registry.svh:259:30` lists a
`string msg;` block-local that ours does not** — direction **ADD**, the
opposite of this pass. It is the same statement family and it was already
visible in the control census as the `msg` cell
(`ref_obj 'msg' 265:34 -> string_var:msg` in golden, `-` in ours). Ranked **R1**
in §8.

THREE DIFFERENT NUMBERS, never conflated, control → FINAL:

| row (mode `default`) | cmp lines (HEAD DEPTH) | heads | dump content +/- (ALIGNMENT-SENSITIVE) | MULTISET distance (`msdist.sh`, no alignment) |
|---|---|---|---|---|
| SimpleUVM | 29 → **29** | 1 → 1 | 238656 → **238588** (−68) | 46983 → **46958** (−25) |
| Scoreboard | 29 → **29** | 1 → 1 | 226798 → **226714** (−84) | 45194 → **45169** (−25) |
| SeqDriver | 85 → **85** | 1 → 1 | 513503 → **518693** (+5190) | 133269 → **133248** (−21) |
| BuildUVMPkg | 58 → **58** | 1 → 1 | 167366 → **167315** (−51) | 34261 → **34235** (−26) |

**SeqDriver's `diff -u` figure grew by 5190 while its TRUE distance FELL by
21.** This is the campaign's alignment law reproduced exactly: `diff -u`
content is an LCS measure and re-picks its alignment; `msdist.sh` uses no
alignment at all. The per-shape settlement is §4's table — the `vpiMethod=1`
bucket goes 6 → 0 against golden's 0 on every test, and `retlist.py` reports
**OVERBIND 0 rows** on all four tests after the fix (8/8/8/3 before), with the
UNDERBIND lists **byte-identical before and after** (SeqDriver 4 rows,
BuildUVMPkg 2 rows, SimpleUVM and Scoreboard 0).

---

## 8. RANKED RESIDUE

Ranked by (rows it heads) × (cells it would close), most valuable first.

**R1 — a `begin` block's block-local `string msg;` is missing from our
`Variables()`.** THE NEW HEAD of SimpleUVM (both modes) and Scoreboard
(default). Golden: `string_var (…::create::msg) @260:14-260:17` parented at
`begin (…::create) @259:30-266:8`, with its own `ref_typespec` →
`string_typespec @260:7-260:13`. Ours: nothing. Direction **ADD**. The
reference to it at `265:34` is our census's only remaining `UNDERBIND`-shaped
cell on SimpleUVM (golden `string_var:msg`, ours `-`) — one fix closes the head
AND that cell. Cheap to locate: the declaration is inside the `begin … end` of
an `if` in an in-body class method, i.e. a statement-block variable listing.

**R2 — a `method_func_call` argument that is the return name is not emitted at
all.** `uvm_mem_mam::reserve_region` at `744:32` and `751:26`
(`this.in_use.insert(i, reserve_region)`, `this.in_use.push_back(reserve_region)`):
golden emits a `ref_obj` bound to the `class_var`, ours emits **no reference
object**. 2 cells × 4 tests. Direction **ADD**. Same routine as
§ retNameNewLhsNoBind56, and worth doing next because the two together would
make `reserve_region` cell-exact.

**R3 — a return-name reference at a MACRO-BUFFER coordinate golden does not
share.** `uvm_mem::get_access`: golden has one ref at `150:55`, ours has two at
`1165:63` and `1176:63`, all bound to `string_var:get_access`. A SPAN plus a
COUNT residue in one place, on the campaign's known macro-buffer/SourceLocation
axis. 3 cells × 3 tests. **Not** a binding residue — do not try to fix it by
binding.

**R4 — § classRetNameDefViewNoBind37's DEF-view arm is too wide for an
out-of-body method whose return name is SELECTED.**
`uvm_pkg::uvm_packer::unpack_string` on BuildUVMPkg, DEF view: golden binds 2 of
3 refs to a `bit_select:unpack_string`, ours binds 0. 2 cells, BuildUVMPkg only,
and it is `vpiMethod=0` so this pass's law is not implicated (checked
explicitly, §4). Direction **ADD**, inside pass 37's predicate.

**R5 — `uvm_instance_scope`'s two `hier_path` return-name refs are absent from
ours entirely** (`351:9`, `357:24`, and on SeqDriver golden's `adpcm_pkg` clone
binds them to a `string_var`). 2–4 cells per test. Direction **ADD**.

**R6 — assorted `method_func_call`-parented return-name refs one side lacks**:
`uvm_printer::index_string@992:3` (golden has it, unbound; ours has no ref),
`uvm_sequence_base::create_item`, `uvm_tr_database::open_stream`,
`uvm_tr_stream::open_recorder`, `uvm_*_link::get_link` (ours has them, golden
does not). 16–43 `NOREF` cells per test; all of them are reference-EXISTENCE
residues, none is a binding residue. Lowest value per cell because they are
scattered over many routines.

---

## 9. THE FIVE GATES, each with the number measured on the FINAL binary

### GATE 1 — BUILD

`cmake --build build -j 3` → `[100%] Linking CXX executable slang-uhdm` /
`[100%] Built target slang_uhdm`. Then, in a SEPARATE command before any sweep:

```
de52f8be5bfa705510cb622cadad4d12  …/r10uvm56/build/slang-uhdm
ed106184c97207183fe1316211507882  …/r10uvm56pris/build/slang-uhdm
OK: BINARY md5 CHANGED  ed106184c97207183fe1316211507882 -> de52f8be5bfa705510cb622cadad4d12
```

and the control's validity anchor, printed before any edit: the pristine
worktree build, my worktree's pre-edit build and the main-tree
`build/slang-uhdm` were all `ed106184c97207183fe1316211507882`.

### GATE 2 — GOLDENS

`tests/check_goldens.sh` on the FINAL binary: **23 PASS / 0 FAIL**.
NEGATIVE CONTROL, quoted:

```
$ SLANG_UHDM=/bin/false bash tests/check_goldens.sh
FAIL wreduce_test0 (diff …/tests/golden/wreduce_test0.dump /tmp/tmp.Mpu0dAgjRF/slang.dump)
neg PASS=0 neg FAIL=23
```

**0 PASS / 23 FAIL** — the control fires.

### GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`

**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump column
**496 match / 183 differ / 52 blank**. WHOLE-ROW judge against the committed
baseline (`ct8rows.sh results/gate_uhdm2rtlil.csv …`):

```
baseline: 732 lines = 731 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both`, `--jobs 2`

`default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL** / 5 DEFERRED / 284 SLANG_REJECT /
25 SURELOG_FAIL; `testflags` **463 CMP_EQUAL / 10 CMP_NOTEQUAL** / 5 DEFERRED /
286 SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE /
1 TIMEOUT / 1 NO_UHDM. Dump column **match 225 (default) / 165 (testflags)**,
`differ` 242 / 298, blank 327 / 331. Every one of those equals the expected
figure. WHOLE-ROW judge:

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` was left at its default: the 5 memory-giant tests read
`DEFERRED` in both modes, exactly as the baseline does.

### GATE 5 — BYTE VERIFIER, both corpora, against the PRISTINE 946579a workdir built in this pass

`SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched-wd> <pristine-wd>`:

```
uhdm2rtlil/testflags:
  databases: patched=679 pristine=679
  PATH_SETS_IDENTICAL (679 paths)
  MOVERS: 0 / 679
  SELFCHECK (every file vs one fixed file): 678 / 679 flagged
  SELFCHECK1 (one file corrupted, expected exactly 1 + the real movers): 1

surelog/both:
  databases: patched=953 pristine=953
  PATH_SETS_IDENTICAL (953 paths)
  MOVERS: 7 / 953
  SELFCHECK (every file vs one fixed file): 952 / 953 flagged
  SELFCHECK1 (one file corrupted, expected exactly 1 + the real movers): 8
```

**0 movers on uhdm2rtlil, 7 on surelog**, with both negative controls firing on
both corpora (678/679 and 952/953 are correct — the fixed reference file is
compared with itself; SELFCHECK1's 8 is the 7 real movers plus the corrupted
one).

#### 9.5.1 EVERY mover attributed, by CONTENT, not by test name

`ct9movers.sh` plus a per-mover direction and name census. **All 7 are PURE
DELETIONS — `+0` lines added on every one of them**, which also means nothing
was reordered or renumbered:

| mover | content lines changed | added | removed | law-name-carrying lines |
|---|---|---|---|---|
| `default/SimpleUVM` | 152 | **0** | 152 | `create::create` 16, `do_compare::do_compare` 32, `reserve_region::reserve_region` 16 |
| `default/Scoreboard` | 152 | **0** | 152 | 16 / 32 / 16 |
| `default/SeqDriver` | 152 | **0** | 152 | 16 / 32 / 16 |
| `default/BuildUVMPkg` | 59 | **0** | 59 | `create::create` 8, `reserve_region::reserve_region` 16 (no `do_compare` — the routine does not exist in 1800.2 UVM) |
| `testflags/SimpleUVM` | 152 | **0** | 152 | 16 / 32 / 16 |
| `testflags/SeqDriver` | 152 | **0** | 152 | 16 / 32 / 16 |
| `testflags/BuildUVMPkg` | 59 | **0** | 59 | 8 / 16 |

The remaining changed lines are, exhaustively, the CHILD and EDGE lines of the
removed return-variable triples — `|vpiActual:`, `|vpiParent:`,
`|vpiTypespec:`, `|vpiName:`, `|vpiFullName:`, `|vpiInstance:`,
`|vpiClassDefn:`, `\_ref_typespec:`, `\_class_typespec:`, `\_bit_typespec:`,
`\_int_typespec:`, `|vpiSigned:1` and the `\_class_defn:` edge printed under the
removed `class_typespec`. Filtering out the three routine names AND the bare
field/edge shapes leaves **only** those child lines and **nothing else**; there
is no unattributed content on any mover.

The hunk itself, verbatim, with the POSITIVE CONTROL visible in the same diff
(the sibling `obj` argument reference is untouched):

```
                 \_sys_func_call: ($cast), line:259:10, endln:259:28
                 |vpiName:create
                 |vpiFullName:uvm_pkg::uvm_object_registry::create::create
-                |vpiActual:
-                \_class_var: (uvm_pkg::uvm_object_registry::create::create), line:250:19, endln:250:20
               |vpiArgument:
               \_ref_obj: (uvm_pkg::uvm_object_registry::create::obj), line:259:24, endln:259:27
```

**THE KNOWN UVM BUILD-DEPENDENCE DID NOT FIRE THIS TIME, and that is a measured
statement, not luck-by-assumption.** `tools/probe/r10oth8repro/README.md`
§0.1–0.2 warns that the UVM `vpiTypedefAlias` / `class_typespec` population is
pointer-address-ordered and shifts on semantically-null edits. On these 7
movers: `vpiTypedefAlias` changed lines **0**, added lines **0**, and every
`class_typespec` changed line is a child of a removed triple. Both
`BuildUVMPkg` rows have the SAME md5 in the patched tree (`2f5eb902c640`) and
the same in the pristine tree (`6455c28a7a86`), so the two modes agree with each
other on both binaries.

No mover changed a row's STATUS or its dump VERDICT — all 7 are on rows that
were already `CMP_NOTEQUAL` with a blank dump column, which is why gate 4's
whole-row judge reads 0.

### CANARIES

* `EXPECT_UNKNOWN=6 ctcan2.sh results/gate_uhdm2rtlil.csv u2r_fin.csv` →
  `ok=1 changed=0 absent=0 unknown-patterns=6`, rc 0.
* `EXPECT_UNKNOWN=1 ctcan2.sh results/golden_surelog.csv sl_fin.csv` →
  `ok=58 changed=0 absent=0 unknown-patterns=1`, rc 0.
* `canaries.sh u2r_fin.csv results/gate_uhdm2rtlil.csv` →
  `ok=9 changed=0 absent=0 unknown-names=28`, rc 0 (28 is the documented u2r
  figure).
* `canaries.sh sl_fin.csv results/golden_surelog.csv` →
  `ok=58 changed=0 absent=0 unknown-names=8`, rc 0 (8 is the documented surelog
  figure).
* **the two names the brief asks for BY NAME**, from that run:
  `InterfaceModPort default OK CMP_EQUAL/differ`,
  `InterfaceModPort testflags OK CMP_EQUAL/differ`,
  `BlackParrotComplex default OK CMP_EQUAL/differ`,
  `BlackParrotComplex testflags OK CMP_EQUAL/differ` — **both unchanged in both
  modes, dump column included.**
* `canaudit.sh canaries.sh ctcan2.sh` →
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`, and each of the four SLANG-FENCED
  names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) prints
  `not dispatched by any driver (OK)`. **No driver in this directory mentions
  any of the four, and none was dispatched or measured individually.**

---

## 10. MANIFEST — everything in this directory

| file | what it is |
|---|---|
| `README.md` | this record |
| `arm.sh` | build ONE arm's golden + ours, dump both, cmp both; guards for the missing-input/first-line/silent-default traps |
| `cells.sh` / `cells.py` | THE ARM CELL TABLE: return-name cells and LOCAL control cells, both sides at own child depth, with a differing count |
| `retown.cpp` | per-`function` probe: `vpiMethod`, `vpiVirtual`, visibility, class parent, class `Parameters()`, and return-name refs bound / total. The probe that found the predicate. |
| `a1_witness.sv` | the witness, reduced from `uvm_registry.svh:259` |
| `a2_local.sv` | the POSITIVE CONTROL — the same shapes on an ordinary local |
| `a3_scope.sv` | a function at every scope; the arm that fixes the boundary |
| `a4_kinds.sv` | explicit `return` / own-name assign / `void` function / task |
| `a5_argpos.sv` | the return var as argument in five positions |
| `a6_type.sv` | four return types at two scopes |
| `a7_recur.sv` | the recursive self-call |
| `a8_newlhs.sv` | `= new(...)` as the return-name lvalue + the local control |

| `retx.py` | the corpus cross-tab of §3: (view × parent kind) × golden-bound/ours-bound over return-name refs |
| `retlist.py` | the same census as a flat list, tagged `OVERBIND` / `UNDERBIND` / `NOREF` — the instrument the residue ranking in §8 was read off |
| `owntab.py` | the `vpiMethod` cross-tab of §4 over `retown.cpp`'s output |

Reused from earlier passes and RUN here, not merely cited:
`tools/probe/r10uvm28g.cpp` (the reference-binding census),
`tools/probe/r10uvm55repro/{wdump.sh,msdist.sh,canaries.sh,canaudit.sh}`,
`tools/probe/r10oth6repro/byteverify.sh`,
`tools/probe/r10oth7repro/ctcan2.sh`,
`tools/probe/r10oth8repro/ct8rows.sh`,
`tools/probe/r10oth9repro/ct9movers.sh`.

**HOW TO REPRODUCE THE WHOLE MEASUREMENT.**

```
# build the census probe against the installed UHDM
g++ -std=c++20 -O1 tools/probe/r10uvm28g.cpp -o /tmp/r10uvm56_28g \
    -I$HOME/.local/include $HOME/.local/lib64/lib{uhdm,capnp,kj}.a -lpthread
g++ -std=c++20 -O1 tools/probe/r10uvm56repro/retown.cpp -o /tmp/r10uvm56_retown \
    -I$HOME/.local/include $HOME/.local/lib64/lib{uhdm,capnp,kj}.a -lpthread
# one arm, end to end
tools/probe/r10uvm56repro/arm.sh a3_scope.sv /tmp/arm_a3 <slang-binary>
tools/probe/r10uvm56repro/cells.sh /tmp/arm_a3
# the corpus census (after a verify_golden run into <workdir>)
tools/probe/r10uvm55repro/wdump.sh <workdir> SimpleUVM default /tmp/d
/tmp/r10uvm56_28g <golden.uhdm> > g.cen ; /tmp/r10uvm56_28g <ours.uhdm> > o.cen
python3 tools/probe/r10uvm56repro/retx.py     g.cen o.cen
python3 tools/probe/r10uvm56repro/retlist.py  g.cen o.cen OVERBIND
/tmp/r10uvm56_retown <golden.uhdm> > g.own ; /tmp/r10uvm56_retown <ours.uhdm> > o.own
python3 tools/probe/r10uvm56repro/owntab.py SimpleUVM g.own o.own
# the fix, per reference
SLANG_UHDM_DBG56=1 <slang-binary> … 2>&1 | grep DBG56
```
