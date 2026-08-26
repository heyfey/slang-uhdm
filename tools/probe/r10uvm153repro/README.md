# r10uvm153 — § `classPropRefBindsPkgListing153`

*A class property read inside an **out-of-body** method of a **package** class
binds the home package's `Variables()` listing **by name** — the first entry of
that name, whatever it actually is — and is bare only when the listing holds no
such name.*

Base commit **34c4dc9**.  LHS is **always** golden (Surelog); RHS is always
ours.  The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else;
every instrument in this directory is measurement-only and links the same
generated `Compare`.

---

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **BuildUVMPkg default / testflags** | **45** cmp lines, 1 head | **36**, 1 head — a **DIFFERENT** object: the head the other four UVM rows already carry |
| SeqDriver default / testflags | 36, 1 head | 36 — head log **BYTE-IDENTICAL** |
| SimpleUVM default / testflags | 36, 1 head | 36 — **BYTE-IDENTICAL** |
| Scoreboard default | 36, 1 head | 36 — **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 36, 1 head | 36 — **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 112 / 112, 1 head | 112 / 112 — **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this base's own pristine control CSVs (1588 surelog row-modes + 1358 u2r × 2 modes) |
| byte movers | — | **9 / 956** surelog — **exactly the nine predicted BY NAME from pristine data**; **0 / 1358** uhdm2rtlil |
| the law's corpus population | 5 wrong cells in 5 databases (9 row-modes) | **0** — and the whole 1 077 338-line dump diff is 4 lines per database (11 where a hoist net also went) |
| the grid, five arms × two views | — | **RIGHT→WRONG 0, AWAY 0** in every arm-view; **71 WRONG→RIGHT** |
| wide boundary | — | 4339 files × 2 views (`BOUNDARY.r10uvm153.txt`) |

No row was converted.  `results/*.csv` untouched.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reads BuildUVMPkg **45 cmp
lines, one `^LHS:`, both modes**, and the log is byte-identical to the one
`r10uvm152repro` shipped as its patched head:

```
LHS:  class_var: (uvm_pkg::clp), line:33188:27, endln:33188:66
      |vpiParent: \_package: uvm_pkg
      |vpiAutomatic:1  |vpiVisibility:1
      |vpiExpr: \_ref_obj: (uvm_cmdline_processor::get_inst)
RHS:  <null>
```

**BOTH DATABASES CONTAIN THAT OBJECT**, so the `<null>` is not a missing
variable, and the head print alone does not say which container it belongs to.
Three `SafeCompare` shapes can produce it (`~/.local/include/uhdm/BaseClass.h`):
a **singular** field whose RHS is null, a **vector element** that is null on our
side, or the vector overload with `lhs_obj` = that object.  `HEAD.r10uvm153.txt`
is the decode, and `ct153own.cpp` is the tool:

1. the official `design::Compare`, re-run with both failed objects and their
   full `VpiParent` chains — LHS `class_var(clp)#186630 < package(uvm_pkg) <
   design`, RHS unset;
2. **is it the package listing?**  Both sides, index by index: `Variables=26`
   on golden and on ours, membership *and order* identical, `clp` at index 5 in
   both, in both views.  **Not** a listing mismatch;
3. the **reverse-reference scan** — every golden object and every relation for
   which `GetByVpiType(t)` yields the target.  **Exactly one holder**, through
   `vpiActual` (700): `ref_obj (clp) @38789:3-38789:6`.  So the head is the
   SINGULAR `ref_obj::Actual_group` overload (RESUME.md § 9's buvm13/15 shape);
4. the same source position on both sides:

```
uvm_pkg.sv:38789:3   ref_obj (clp)   |vpiActual ->
    golden : class_var (uvm_pkg::clp) @33188:27   (both views)
    ours   : <null>                               (both views)
```

`uvm_pkg.sv:38789` is `clp = uvm_cmdline_processor::get_inst();` inside
`function uvm_root::new();`.  **`clp` is `uvm_root`'s own class property**
(declared @38507), and golden binds it to the **package copy of
`uvm_phase::new`'s nested-`begin` local** @33188 — a different class entirely.

---

## 2. THE DECODED MODEL (Surelog, read line by line, then measured)

### 2.1  Why the reference reaches late binding

`CompileHelper::bindVariable` (`src/DesignCompile/CompileStmt.cpp:3089`)
resolves a name against a scope's `Variables()` and `Io_decls()` **only**.  An
out-of-body method is compiled in the home **package's** scope, where the
class's own members are invisible (that is
§ `pkgVarBindsOnlyThroughInstance88`'s decode), so a class property is on
neither list.  `CompileExpression.cpp:5769-5788` therefore takes its
`else component->needLateBinding(ref)` branch and the reference lands in
`DesignComponent::m_needLateBinding`.

### 2.2  Where late binding puts it

`UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3294`) walks the
ref's `VpiParent` chain outward.  At the enclosing `uhdmfunction` (`:3369`) or
`uhdmtask` (`:3434`) it scans `Io_decls()`, `Variables()`, `Parameters()` — a
class property is in none — and then

```cpp
if (const UHDM::instance* inst = func->Instance()) {
  if (inst->UhdmType() == uhdmpackage) {
    package* pack = (package*)inst;
    if (pack->Variables())
      for (auto n : *pack->Variables())
        if (n->VpiName() == name) { ref->Actual_group(n); break; }   // FIRST wins
```

For an out-of-body method that `Instance()` **is** the home package.  The
listing it scans is the WHOLE listing — the package's own declarations **and**
the copies `CompilePackage::collectObjects_` makes of every out-of-body
constructor's block items (§ 148's decode, which we already emit through
`collectOobCtorLocals`).  That is how a `uvm_root` property binds a
`uvm_phase::new` local.

> ### § classPropRefBindsPkgListing153
>
> A class property read inside an **out-of-body** method of a **package** class
> binds the home package's `Variables()` listing **by name** — the FIRST entry
> of that name, whatever it actually is — and is bare only when the listing
> holds no such name.

### 2.3  Golden says it, in five files, with its own controls

`g153_a_mech.sv` — one package, one donor constructor, one reading class:

| reference | what the name is in the package listing | golden |
|---|---|---|
| `a_prop` @44 / @53 / @60 | **nothing** | **BARE** (the control) |
| `a_pkgv` @45 / @54 / @61 | a REAL package variable | binds `int_var (pa153::a_pkgv)` |
| `a_body` @46 | a HOISTED constructor **body-level** local | binds it |
| `a_nest` @47 / @55 / @62 | a HOISTED constructor **nested-`begin`** local | binds it |
| `a_pkgs` @48 | a package variable slang itself resolves | already bound on both sides |
| `inbody153`'s three reads @36-38 | an IN-BODY method | **BARE** on both sides |
| `fa153`'s formal `a_pkgv` @67 | § 81's population | unchanged |

and the three rows repeat for an out-of-body **function**, an out-of-body
**task** and an out-of-body **constructor** alike.

`g153_b_pos.sv` — sixteen POSITIONS of one colliding property, one golden:
plain lvalue, plain rvalue, `if` **predicate**, `while` condition, `case`
selector, ternary operand, system-call argument, call argument, a colliding
`string` property, nested `begin`, `for` body, immediate assertion, and the
same name inside an out-of-body **task**.  **All thirteen bind.**  § 81's
`condPredEarlyBound81` exception does **not** apply, for § 152's reason: a name
listed on no scope fails `bindVariable` in a predicate exactly as everywhere
else.

`g153_d_kind.sv` — the LISTING.  `int` / `string` / `bit` / `logic` / `real` /
class handle / `enum` and three declarators on one line all bind their listing
entry.  A package **NET** (`d_nib d_net;`, a user typedef over a packed vector)
is **not** in `Variables()` and golden is bare — as are we.  An unpacked array
element is a `bit_select`, not a `ref_obj`, and is outside the law on both
sides.  And **FIRST-MATCH-WINS is real**: `d_first` exists TWICE in golden's
listing — the hoisted constructor local at slot 0 (line 18) and the real
package variable at slot 1 (line 22) — and golden binds **slot 0**.  Our
listing has the same two entries in the same order, so our first-match loop
answers the same object.

`g153_e_shape.sv` — an ordinary property, an **INHERITED** property (declared in
the base class), a **STATIC** property, a property inside a **`fork`**, inside a
**`foreach`** body, a method declared `extern virtual`, a `static` method, a
**parameterized** class and a **named block**: ten cells, ten binds.

---

## 3. THE FENCES, EVERY ONE A MEASURED GOLDEN CELL

* a **hier-path element** (`b_h.fb = p` @45; `c_h.fc = p` @29 and @38), a
  **call receiver** (`b_recv.kb()` @46; `c_recv.kc()` @30 and @39) and a
  **`= new` lvalue** (`b_newv = new()` @47; `c_newv = new()` @31 and @40) are
  **BARE in golden**: Surelog builds all three outside `compileExpression`'s
  identifier arm, so they never enter the late-binding pool.
  **`g153_c_home.sv` asks the same three positions of a REAL PACKAGE VARIABLE
  from a package FREE function** — the one place our own § 88 binder already
  runs — **and golden is bare there too while our PRISTINE binary is already
  bare**: our emitter builds a hier_path element, a receiver and a `= new`
  lvalue outside this binding site.  The three fences are therefore *inherited
  by construction*, not coded.  The corpus agrees on its own scale: BuildUVMPkg
  holds **90** further bare `clp` / `cs` / `top` / `bld` / `common` references
  that Surelog's raw walk would bind, **61 with a `hier_path` parent and 29
  with a `method_func_call` parent**, and golden binds **none** of them.
* an **IN-BODY** class method — § `pkgVarBindsOnlyThroughInstance88`: no
  `vpiInstance`, nothing to scan.  `inBodyClassMethod88` is the term.
* a **wildcard-import CLONE** of the package's subroutines — § 81's
  `subHomeIsPkg81`, measured on the corpus: MiniAmiq and SeqDriver hold FOUR
  copies of `clp` @339:3 and golden binds only the TWO in `uvm_pkg`'s own
  listing, leaving the `svaunit_pkg` / `adpcm_pkg` clone copies bare.
* a **MODULE** class's out-of-body method (`Mc153::moob153` @61) — Surelog's
  `inst->UhdmType() == uhdmpackage` guard.  Golden binds the MODULE-level object
  (a `logic_net`) we do not emit, so we stay bare (residue R1).  A **`$unit`**
  class (`Uc153::uoob153` @51) has no package in its scope chain at all and
  golden is bare (residue R2).
* a name that matches a package **PARAMETER** and not a `Variables()` entry:
  golden binds a folded `constant` through a different mechanism entirely
  (`g153_e_shape.sv` `e_param` @38); this law scans `Variables()` only and
  leaves it alone (residue R3).

---

## 4. THE PRODUCTION CHANGE — one hunk, two file-static helpers, no new object

```
include/UhdmExporter.h   the law, its Surelog citations, its measured fences
src/ExprEmit.cpp         `pkgListingByName153`  (the listing read BY NAME, the
                         way UhdmWriter.cpp:3410-3428 reads it — first match
                         wins, Surelog's uhdmpackage guard verbatim)
                         `classPropOfPkgClass153` (the population)
                         + four lines at § 88's existing binder site:
```
```c++
if (!inBodyClassMethod88 && !ref->Actual_group() &&
    classPropOfPkgClass153(nv.symbol) &&
    subHomeIsPkg81(currentSubSym, pkgScopeInst))
    if (auto* pv153 = pkgListingByName153(pkgScopeInst, ref->VpiName()))
        ref->Actual_group(pv153);
```

Nothing is minted, no walk is added, and `pkgVarOverFormal81` is untouched —
§ 81 / § 148 / § 152 are all **replacers** and keep their `!bound` guard; this
law is the one that gives a binding to a reference nothing else could bind,
which is exactly why no replacer could ever have carried it.

The placement is deliberate: **before** the § 75 / § 107 class-property hoist
pool, whose push is guarded by `!ref->Actual_group()`.  A reference this law
binds therefore no longer mints an implicit module wire — and golden never had
that wire (§ 5).

---

## 5. THE MOVERS, PREDICTED BY NAME BEFORE THE PATCHED SWEEP EXISTED

`ct153pred.cpp` re-runs Surelog's own walk on **our PRISTINE databases only**
(golden never consulted), minus the three fences, which in the emitted tree are
exactly the `hier_path` / `method_func_call` / `method_task_call` parents.
`predsweep153.sh` runs it over every database in a workdir:

* **uhdm2rtlil, 1358 pristine databases: 0 predicted.**
* **surelog, 956 pristine databases: 9 predicted, by name** — BuildUVMPkg
  (both modes), MiniAmiq (both), Scoreboard (default; testflags has no
  database), SeqDriver (both), SimpleUVM (both).

`byteverify.sh SELFCHECK=1` then measured **MOVERS 9 / 956** and **0 / 1358** —
the measured set **is** the predicted set, name for name, with no order coin in
this run.  Attributed line by line from sorted, path-normalised `uhdm-dump`s:

* BuildUVMPkg / MiniAmiq / Scoreboard — **4 lines each**: the binding
  substitution in the DEF and the ELAB view (`+2` target lines, `+2`
  `|vpiActual:`), nothing else in 1 077 338 dump lines;
* SimpleUVM / SeqDriver — **11 lines each**: the same substitution (one of the
  two copies was already bound, to **our own** hoist net) **plus the removal of
  `logic_net (work@top.clp) @339:3`** and its stamps.  Golden's module-level
  `clp` objects sit at the DECLARATOR span (801:27); scored as a MEMBERSHIP set
  over every `module_inst` `Nets()` vector, `ONLY-OURS` falls 23→22 (SimpleUVM)
  and 22→21 (SeqDriver) while `ONLY-GOLD` (37 / 62) and `SHARED` (188 / 162)
  are unchanged to the element.

  **CORRECTED BY THE VERIFIER (r10v153).**  That census is keyed on the SPAN,
  and no generated `Compare` reads `VpiLineNo`/`VpiColumnNo` (RESUME § 9).  On
  the key the judge actually reads — kind + `VpiName` — the removed net *did*
  match one of golden's, so the same `Nets()` multiset moves the other way:
  `ONLY-GOLD` 14→15 and `SHARED` 211→210 on SimpleUVM/default, `ONLY-GOLD`
  40→41 and `SHARED` 184→183 on SeqDriver/default, with `logic_net clp` going
  golden 2 : ours 1 → golden 2 : ours **0**.  It changes no verdict (that
  vector is 225 vs 210 and already fails the size check, and the head moved
  45→36 regardless), but the durable reading is: the **binding** half of this
  law is a move toward golden and the **un-minting** half is a small move away.
  Residue R4 is where the two are reconciled.

---

## 6. THE GRID — five arms, ten arm-views

`ARMS.r10uvm153.txt` (`ct153bind` + `score153.py`, cell by cell against golden):

| arm | def | elab |
|---|---|---|
| `g153_a_mech` | 7 WRONG→RIGHT | 2 WRONG→RIGHT |
| `g153_b_pos` | 13 | 12 |
| `g153_c_home` | 1 | 0 |
| `g153_d_kind` | 11 | 11 |
| `g153_e_shape` | 9 | 5 |

**RIGHT→WRONG 0 and AWAY 0 in all ten**, 71 WRONG→RIGHT.  The `CHANGED-WRONG`
cells in the ELAB views are all one shape: our elab databases hold more copies
of a key than golden's (a pre-existing structural residue of these arms), and
the change turned a `<bare>` copy into the object golden's copies hold — toward
golden, and the residual disagreement is the copy COUNT, which the pass does
not touch.  The two `GOLD-BOUND` cells that survive are residues R1 (a MODULE
class) and R3 (a package parameter).

The arms' own `uhdm-cmp` line counts are printed at the bottom of
`ARMS.r10uvm153.txt` **with a warning**: every arm's single head is the
`design` object itself, so that column measures the design's decompile size and
not the disagreement.  The cell score is the instrument; the corpus head,
measured through `rowheads.sh`, is the verdict.

---

## 7. GATES — `GATES.r10uvm153.txt`, all green

Two frozen binaries (`chmod 555` copies made before any sweep), every
`cmds.txt` audited by BINARY PATH:

* goldens **23/0** on both binaries; negative control `SLANG_UHDM=/bin/false`
  **0/23**;
* uhdm2rtlil both modes **679 / 50 / 2**, `ct8rows` PASS against the committed
  baseline and against this pass's own pristine controls, byteverify **0/1358**;
* surelog `--mode both`: **937 CMP_EQUAL / 19 CMP_NOTEQUAL** over 1588
  comparable row-modes, identical pristine and patched, `ct8rows` **0 differing
  rows** on both baselines, **no row converted**, `results/*.csv` untouched;
* `rowheads` BuildUVMPkg **45 → 36** both modes, every other head log
  byte-identical;
* canaries **ok=52 / ok=8, changed=0**, ctcan2 PASS ×2, canaudit **audited=29
  UNCOVERED=0 FENCE-BREACH=0**, all ten protected databases SAME
  (SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`).

---

## 8. BOUNDARY — `BOUNDARY.r10uvm153.txt`

`LISTED=4339 PROCESSED=4339 PRODUCED_DBS=4193 MOVED_ARMS=6 RC_DIFFS=0`, both
views.  Five of the six movers are **this pass's own arms** — the positive
control, without which the gate could not be shown to see.

The sixth is `tools/probe/r10v152repro/arms/v152_h_prop.sv`, **the arm
r10uvm152's verifier built for exactly this R0** ("a CLASS PROPERTY read inside
an out-of-body constructor at package scope, where the PACKAGE listing carries
a variable of the same name … exactly as `uvm_pkg::clp` is").  Re-measured
against a fresh Surelog golden it moves **TOWARD** it: **3 WRONG→RIGHT
(RIGHT→WRONG 0, AWAY 0)** in the def view — a colliding property, a **static**
property, and the same property in an ordinary out-of-body method — and its
official `uhdm-cmp` count falls **4912 → 4910** (def) and **6788 → 6774**
(elab), one head throughout.  Its § 152 cell `h01` is untouched.

---

## 9. RESIDUES, RANKED, AND R0

* **R0 — THE NEXT HEAD.**  BuildUVMPkg, both modes, **36** cmp lines, one
  `^LHS:`, and it is now **the head all five UVM rows share**:
  `uvm_pkg.sv:41234:9` (`= uvm_component.svh:3436:9` in the uvm-1.2 trees),
  `if (m_time_settings.size() > 0) m_time_settings.sort() with (item.offset);`
  inside `uvm_component::m_set_cl_verb`.
  `LHS: func_call (m_time_settings) @41234:9-41234:52` with `vpiParent ->
  if_stmt` against `RHS: method_func_call (sort) @41234:25-41234:29` with
  `vpiPrefix -> ref_obj (…m_set_cl_verb::m_time_settings)`.  Golden models the
  whole `<array>.sort() with (…)` statement as ONE `func_call` NAMED AFTER THE
  ARRAY and spanning the whole call; we build a `method_func_call` named after
  the METHOD with the array as a prefix.  Clearing it moves **five** row-modes
  at once (SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg).
* **R1** — a **MODULE** class's out-of-body method (`g153_c_home.sv`
  `Mc153::moob153` @61): golden binds the MODULE-level object, and it is a
  `logic_net (c_int) @55:7` — a module `int c_int;` that golden models as a NET
  in this position — which we do not emit, so we stay bare.  Corpus incidence
  zero.
* **R2** — a **`$unit`** class's out-of-body method (`Uc153::uoob153` @51):
  golden leaves even the FORMAL `p` bare (`c_int` too) while we bind the
  `io_decl`.  Pre-existing, one cell, unchanged by this pass (arm C's
  `OURS-BOUND` count is 1 before and after); the same family as § 152's R4.
* **R3** — a property whose name matches a package **PARAMETER** and not a
  `Variables()` entry (`g153_e_shape.sv` `e_param` @38): golden binds a folded
  `constant` owned by a `param_assign`, through a mechanism that is not
  `lateBinding`'s package scan at all.  We stay bare.  Corpus incidence zero.
* **R4** — the **module hoist of a package's variable listing**: golden's
  `work@top` carries `logic_net (clp) @801:27` AND `class_var (clp) @801:27`
  copies of the package listing that we never emit (SimpleUVM's module Nets
  `ONLY-GOLD` set is 37 members, SeqDriver's 62).  A large pre-existing
  ONLY-GOLDEN set, member-for-member unchanged by this pass.
* **R5** — BuildUVMPkg's other `GOLD-BOUND` cell, `msg` @14065:34: a nested
  `begin`'s own local (`string_var (msg)` @14060:14) inside an IN-CLASS-BODY
  static method of a parameterised class.  Golden binds it through
  `lateBinding`'s `uhdmbegin` arm (UhdmWriter.cpp:3550); we are bare.  § 145's
  LOWN family, one cell, untouched here.
* **R6** — our ELAB databases hold MORE copies of an out-of-body body than
  golden's (four against two in the grid arms).  Every `CHANGED-WRONG` cell in
  the elab views is that copy count and nothing else; the pass moves the
  bindings inside those copies toward golden and does not change how many there
  are.
* **R7** — SeqDriver/MiniAmiq keep `clp` @3399:20 in `DIFF` on both sides
  identically: golden's `uvm_component::m_set_cl_verb` local spans
  `3383:3-3383:24` and ours `3383:25-3383:28`.  § 152's R5 span family; span is
  dump-only, no generated `Compare` reads a location.
