# r10uvm113 — § classOwnLateMethodBindsPkgFn113

**THE SimpleUVM×2 + Scoreboard/default 565-LINE HEAD CLEARED** (565 → 56 cmp
lines, and the head OBJECT changed).

LHS is always golden (Surelog); RHS is always ours.

---

## 1. The head, and WHICH OWNER held it

`raw/head_pris_default_SimpleUVM.cmp`, re-measured on this pass's own pristine
build (`rowheads.sh` on a pristine workdir: SimpleUVM/default 565/1,
SimpleUVM/testflags 565/1, Scoreboard/default 565/1 — one head, the same
object in all three):

```
LHS: function: (uvm_pkg::uvm_report_fatal), id:805, line:236:1, endln:249:12
     vpiParent: package uvm_pkg
RHS: <null>
```

The **singular** `SafeCompare(lhs, rhs == nullptr)` overload (BaseClass.h:187)
sets only `m_failedLhs`, and sets it to the POINTEE — the object golden's edge
points AT.  So the head named the TARGET and hid the OWNER.

`ct113own.cpp` found the owner with the official `Compare`: seed a candidate
set into a FRESH `CompareContext::m_visited` (every generated `<kind>::Compare`
opens with an LHS-keyed visited-insert and returns 0 on a hit), re-run
`design::Compare`, and bisect for the single object whose masking moves the
head.  The pool is every golden object carrying a singular edge that can hold a
`function`/`task` (`func_call::Function`, `method_func_call::Function`,
`task_call::Task`, `method_task_call::Task`, `ref_obj::Actual_group`) whose
value is the head's LHS — 143 candidates.  `--calib` (a database against
itself) reads NO HEAD; the located object is re-verified alone.

```
OWNER (verified alone):
  func_call(uvm_report_fatal)@uvm_sequence_item.svh:151:7-151:92  FIELD=func_call::Function
    < begin()@uvm_sequence_item.svh:150:23-152:8
    < if_stmt()@uvm_sequence_item.svh:150:5-152:8
    < begin()@uvm_sequence_item.svh:153:5-153:56
    < function(set_id_info)@uvm_sequence_item.svh:149:3-155:14
    < class_defn(uvm_sequence_item)@uvm_sequence_item.svh:37:1-497:9
    < package(uvm_pkg)@uvm_pkg.sv:28:1-39:11        <- the ELABORATED view
    < design(work@top)
  next head after masking the whole pool:
    LHS=function(uvm_process_report_message)@uvm_globals.svh:259:1-267:12  RHS=<null>
```

Owner kind/field: a **`func_call`**, field **`vpiFunction`**
(`func_call::Compare`, `~/git-repos/UHDM/build/generated/src/func_call.cpp:77`,
`SafeCompare(lhs->Function(), rhs->Function(), context)`).  Home: a **class
method body** — `uvm_sequence_item::set_id_info`, in the **ELABORATED**
(`TopPackages`) view of `uvm_pkg`.  Raw run in `raw/OWNER.SimpleUVM.default.txt`.

## 2. THE CENSUS — the family is exactly THREE cells, and they are the same nine times

`ct113cen.cpp` prints one row per REACHABLE `tf_call` (`func_call` /
`task_call` / `method_func_call` / `method_task_call`) — view, container, owner
chain, call name, span, kind, and the callee it binds — and `cen113.py`
multiset-joins two censuses.

**Two keying traps, both paid for here.**  Keyed on the full span the join read
1861 ONLY-G against 1866 ONLY-O; keyed on the start alone, 1358 against 1363.
Both are phantoms: the two producers disagree about macro-expansion locations
(golden reports the macro BODY line `uvm_message_defines.svh:133`, we report
the USE line `uvm_component.svh:1887`; end columns differ too), and OUR objects
carry an EMPTY `VpiFile`.  **`Compare` reads no span at all**, so the
judge-visible cell is `(view, container, owner chain, call name, call kind)`
with a MULTISET of callee shapes — 34 non-SAME cells on SimpleUVM/default, not
3200.

Over the **nine UVM row-modes** (`SCORE.uvm9.txt`, `cenall113.sh`):

| | PRISTINE | PATCHED |
|---|---|---|
| SAME | 144430 | **144457** |
| OURS-NULL (golden binds, we bind nothing) | **27** | **0** |
| DIFF | 8226 | 8226 |
| ONLY-G / ONLY-O | 294 / 211 | 294 / 211 |

The 27 are 3 cells × 9 row-modes, **identical in every one**:

| view | home | call | golden binds |
|---|---|---|---|
| ELAB `uvm_pkg` | `uvm_report_object::uvm_report` | `uvm_process_report_message` | `uvm_pkg::uvm_process_report_message` |
| ELAB `uvm_pkg` | `uvm_sequence_item::set_id_info` | `uvm_report_fatal` | `uvm_pkg::uvm_report_fatal` |
| ELAB `uvm_pkg` | `uvm_sequence_item::uvm_report` | `uvm_process_report_message` | `uvm_pkg::uvm_process_report_message` |

`CENSUS.uvmglobals.txt` (`cenglob113.py`) narrows the same census to the calls
the brief names — every call to a `uvm_globals.svh` FREE subroutine
(`uvm_report_{info,warning,error,fatal}`, `uvm_report_enabled`, `uvm_report`,
`uvm_process_report_message`, `uvm_is_match`, `uvm_string_to_bits`,
`uvm_bits_to_string`, `uvm_wait_for_nba_region`, `uvm_split_string`,
`run_test`, `set_config_*`, … the whole list) across the nine row-modes:
**SAME 24088, OURS-NULL 27, DIFF 7982, ONLY-G 4, ONLY-O 8**.  The OURS-NULL 27
are the head; the DIFF 7982 are R-tf111 and are the same before and after.

**"bound to null", not "bound to the wrong object".**  That is what separates
this head from uvm111's R-tf111: R-tf111's cells are the `DIFF` column above
(MiniAmiq 2090, SeqDriver 2001 — golden binds `uvm_pkg`'s HOME function where
we bind the importer's clone; SimpleUVM's 6 are the `C::m`-spelled siblings).
Those cells are **untouched** by this pass, in both directions.  The two
families share the `getTaskFunc` walk but not the defect: R-tf111 is *which
copy*, this head is *whether anything at all*.

## 3. THE LAW

> A **bare (unqualified) call written in a class method body** that the emitting
> view cannot resolve to an ALREADY-EMITTED method binds the **free subroutine
> of that name in the enclosing package**, whether the method it failed to find
> is INHERITED from a base class or is the caller's **own class's method
> DECLARED BELOW the caller**.

The second half is the widening; the first half has been law since
§ inheritedNameBindsPkgFn72.

### Surelog producer

`CompileHelper::getTaskFunc`, `src/DesignCompile/CompileExpression.cpp:349`.
For a `::`-less name it is ONE walk with no notion of "inherited":

```cpp
while (comp) {
  if (comp->getTask_funcs())
    for (UHDM::task_func *tf : *comp->getTask_funcs())
      if (tf->VpiName() == name) return {tf, component};
  comp = (DesignComponent *)comp->getParentScope();   // class -> package
}
// then the component's FileContents, then getFuncFromPackage(), then instances
```

Surelog compiles a class single-pass, so at a call site the class's
`getTask_funcs()` holds only the methods written **ABOVE** it.  A name declared
BELOW misses the class scan **exactly as an inherited name does**, and the SAME
loop carries on to the parent scope — the package — and finds the free
function.  Whether the missed method is inherited or the caller's own sibling
is invisible to that walk, so the fall-back must not ask.

That is precisely the uvm-1.2 shape at all three cells:

| caller | call | the class's OWN method of that name |
|---|---|---|
| `uvm_sequence_item::set_id_info` (`uvm_sequence_item.svh:149`) | `uvm_report_fatal` (:151) | declared at **:422** |
| `uvm_sequence_item::uvm_report` (:352) | `uvm_process_report_message` (:369) | declared at **:434** |
| `uvm_report_object::uvm_report` (`uvm_report_object.svh:129`) | `uvm_process_report_message` (:146) | declared at **:248** |

### The golden grid (`GRID.txt`, arms `g113_a.sv` … `g113_d.sv`)

`g113_b.sv` is the discriminator, and it is the whole law in two lines:
one class, one package free function `alpha`, two callers — the one written
**above** `Kw::alpha` binds `pb::alpha`, the one written **below** it binds
`Kw::alpha`.  Names are deliberately unrelated to the law and the orders differ
per class, so an arm cannot agree by accident.  `Kz::early` is the negative
cell: no package function of that name exists, and golden leaves the call
**unbound** — as do we, before and after.

`g113_a.sv` is the CONTEXT grid the brief asks for — the same collision reached
from a package-variable initializer, a package function body, a class method
IN-BODY, OUT-OF-BODY and STATIC, a constraint, a module, an importing package,
a SECOND (explicit-import) package, and `$unit`.

The **constraint** context yields NO cell: neither producer emits a `constraint`
object at all for `constraint c_v { v == rho(2); }` — golden's dump contains the
string `constraint` zero times — so there is no call there for either side to
bind, and the context is covered by measurement rather than by a scored cell.

Scores (golden vs pristine vs patched, `score113.py`):

| arm | TO-GOLDEN | ALREADY-RIGHT | **AWAY-GOLDEN** | STILL-WRONG |
|---|---|---|---|---|
| g113_a context grid | 3 | 36 | **0** | 18 (+1 changed-still-wrong, §6 R-clone113) |
| g113_b order discriminator | 3 | 10 | **0** | 1 |
| g113_c `$unit`-import arm | 1 | 1 | **0** | 1 |
| g113_d non-package enclosures | 1 | 4 | **0** | 1 |

## 4. The fix

`src/ExprEmit.cpp`, inside the **§ classCallNoLink12** arm — the arm a call
reaches when `subMap` has no entry for a callee whose parent scope is a
`ClassType`, i.e. exactly "an unqualified call from a class method to a method
this view has not emitted".  The package-free-function fall-back was gated on
`inheritedCall72` (callee class ≠ caller class, or the caller is out-of-body);
the gate is now the ARM itself:

```cpp
bool classLateOrInherited113 =
    currentSubSym && curSubClassScope9 && !qualCall9;
if (classLateOrInherited113 && !protoBound12)
    if (auto* fb72 = pkgFreeSubForName72(currentSubSym, sub.name))
        ...
```

One condition weakened; nothing else moved.  `qualCall9` is re-read so an
explicitly scoped `C::m()` can never fall out to a package function of the same
base name, and `protoBound12` still wins (§ externProtoInBodyCallBinds12: the
class's own `extern` prototype is the nearer declaration and golden binds it).
The fall-back writes **no name anywhere** — it re-points one link — so the
standing "naming is context-dependent, do not uniformly fix `pkg::pkg::`"
memory is respected by construction.

**The fix can only fill a null.**  It runs only where the pristine emitter
emitted a `func_call` with NO `vpiFunction`; it never re-points a call that was
already bound.  That is why no arm and no corpus cell can move AWAY.

## 5. Evidence and gates

* `PREDICTION.txt` — `pred113.cpp` evaluated the patched arm's own predicate on
  **956 + 1358 PRISTINE** databases and named the mover set BY NAME before the
  patched sweep: the nine UVM row-modes, 3 cells each, and nothing else;
  0 predicted on uhdm2rtlil.  `byteverify.sh SELFCHECK=1` then measured
  **MOVERS 9/956 and 0/1358** — exactly the predicted set.
* `attrib113.sh` — order-blind attribution (dumps path-normalised and SORTED,
  because Scoreboard/default is a ~50/50 coin).  Every one of the nine movers:
  **removed=0, added=6** — three `|vpiFunction:` edges naming
  `uvm_pkg::uvm_report_fatal` once and `uvm_pkg::uvm_process_report_message`
  twice.  Nothing else, in any of the nine.
* `SCORE.uvm9.txt` — the census above: OURS-NULL 27 → 0, AWAY 0.
* `GRID.txt` — the four purpose-built goldens, 8 TO-GOLDEN / 0 AWAY-GOLDEN.
* `GATES.txt` — the whole landing battery.
* `BOUNDARY.acquittal.txt` — `bound113.sh` over a COPY of the WHOLE probe tree,
  four combinations (file/dir × def/elab), every differing arm acquitted.
* `raw/` — the pristine and patched heads for SimpleUVM/default and
  Scoreboard/default, the owner-locator run, and one attribution diff.

Heads, pristine → patched (`rowheads.sh`, official `uhdm-cmp`):

| row | mode | pristine | patched |
|---|---|---|---|
| SimpleUVM | default | 565 / 1 | **56 / 1** |
| SimpleUVM | testflags | 565 / 1 | **56 / 1** |
| Scoreboard | default | 565 / 1 | **56 / 1** |
| SeqDriver | both | 32 / 1 | 32 / 1 |
| MiniAmiq | both | 32 / 1 | 32 / 1 |
| BuildUVMPkg | both | 47 / 1 | 47 / 1 |
| Earlgrey_0_1 | both | 36 / 1 | 36 / 1 |
| Rggen | default | 0 / 0 | 0 / 0 |

## 6. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `ct113own.cpp` — the owner locator for an `RHS: <null>` head (method from
  `r10earl60repro/tsinst60.cpp`, pool widened from `typespec::Instance` to every
  singular function/task edge).  Build:
  `g++ -O2 -std=c++17 ct113own.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct113own`
* `ct113cen.cpp` — the call→callee binding census over every REACHABLE tf_call
  (the vpiParent chain must terminate at the design: uvm97's lesson that
  `Serializer::AllObjects` also holds objects in no dump tree).  Same build line.
* `cen113.py` — the multiset join and the verdicts (`KEY113=full|start|nospan`;
  `nospan` is the default and the only one that is not span-poisoned).
* `cenall113.sh` — the census over the nine UVM row-modes of a workdir.
* `cenglob113.py` — the same census narrowed to the `uvm_globals.svh` free
  subroutines the brief names, one line per row-mode plus a per-callee
  breakdown.  Its classifier names a ONE-SIDED cell BEFORE the `<null>` tests:
  the other order read OURS-NULL 7 on BuildUVMPkg where the join reads 3, by
  calling an absent golden entry facing our `<null>` a null binding.
* `score113.py` — TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / ALREADY-RIGHT per cell
  for golden vs pristine vs patched.
* `pred113.cpp` + `predall113.sh` — the a-priori mover predictor.
* `attrib113.sh` — order-blind mover attribution.
* `bound113.sh` — the boundary gate (a verbatim copy of
  `r10uvm111repro/bound111.sh`, retargeted).
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` / `ct8rows.sh` / `byteverify.sh` /
  `rowheads.sh` — the standard gates, copied for this pass.

## 7. Residues

* **R0 (the NEXT head — SimpleUVM both modes and Scoreboard/default, 56 lines).**
  `uvm_globals.svh:262`, `process p;` inside `uvm_process_report_message` — a
  body the judge only now reaches, because the call that leads there is bound.
  Golden has a **`ref_var`** whose `ref_typespec` points at an
  **`unsupported_typespec (process)`**; we have a **`class_var`** with a
  **`class_typespec (process)`**.  Surelog does not model the built-in `process`
  class, so the declaration degrades to an unsupported typespec and the variable
  is a `ref_var`.  Two objects, one law.  (`raw/head_pat_default_SimpleUVM.cmp`.)
* **R-unitimp113 (`g113_c.sv`).**  A COMPILATION-UNIT import that brings the
  colliding name into `$unit` — wildcard `import homec::*;` **or** explicit
  `import homec::rho;` — makes golden fall out to the package function for BOTH
  callers, the one above the class's own method AND the one below it.  A
  wildcard import of a DIFFERENT package does nothing.  The declaration-order
  rule of §3 is therefore golden's behaviour only in the absence of such an
  import; the mechanism behind the flip is not decoded.  We bind the class
  method there, pristine AND patched — a MISS, never an AWAY, and it reaches no
  corpus row (the corpus census has 0 such cells).
* **R-mod113 (`g113_d.sv`).**  The same collision with the free subroutine in a
  MODULE rather than a package: golden binds `work@tb_d::mu`, we leave the call
  unbound, pristine and patched alike.  `pkgFreeSubForName72` does walk out to
  an `InstanceBody`, but the module's own `task_func` is not in `subMap` when a
  class declared in that module is emitted, so the lookup misses.  0 cells in
  either corpus (`pred113`'s MAYBE column is 0 over 2314 pristine databases).
* **R-expimp113 (`g113_a.sv`, two cells).**  `imp2` imports `home::sigma` with
  an EXPLICIT single-symbol import; `imp2::Cimp2::first`/`::second` call `sigma`
  while `Cimp2::sigma` is declared below them.  Golden binds `home::sigma` — the
  HOME object, since an explicit import materialises no clone.  We bind nothing,
  pristine and patched, for one line's reason: `pkgFreeSubForName72` accepts a
  landing-scope hit only when `f72->kind == SymbolKind::Subroutine`, and slang
  answers an explicitly imported name with an `ExplicitImport` symbol.  Resolving
  through that symbol is a SECOND law and is deliberately not taken here; the
  cells are a MISS, never an AWAY, and reach no corpus row.
* **R-clone113 (`g113_a.sv`, one cell).**  `imp1::Cimp::above` calling `rho`:
  golden binds `home::rho` (the HOME object), we now bind `imp1::rho` (the
  importer's wildcard-import clone) where pristine bound nothing.  Clone and
  home share one `VpiName` and the clone is a `clone_tree` of the home, so the
  cell is invisible to `Compare`; it is uvm111's **R-tf111** family, reached
  from a new site rather than created here.
* **R-tf111 / R-buvm111 (carried, untouched).**  The `DIFF` column of §2 —
  MiniAmiq 2090, SeqDriver 2001, SimpleUVM/Scoreboard 6, BuildUVMPkg 13.  Golden
  binds free-function calls in an importer's bodies to the HOME objects while we
  bind the importer's clones, and golden's package-body `C::m()` calls carry the
  full `C::m` name where ours carry `m`.  Byte-identical before and after this
  pass.
* `pkgImportCloneLastWriter32` stays dead last.
