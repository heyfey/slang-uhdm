# r10uvm152 — § `ctorEatenLocalBindsPkgCopy152`

**BuildUVMPkg ×2, 30 cmp lines, one `^LHS:` each — THE BRIEFED HEAD OBJECT
CLEARED.  Base commit `5cfc64a`.**

**MEASUREMENT-ONLY directory.**  Nothing in it is an acceptance judge.  The
official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY** and are byte-identical to the committed
baselines; `GOLDEN_DEFER` stayed unset; **nothing was promoted** and **NO
CORPUS ROW CONVERTED**; the four slang-fenced tests were never dispatched and
are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `5cfc64a` (= UVM pass 150) |
| pristine binary | built in a clean worktree at `5cfc64a`, frozen `chmod 555` before any sweep; **md5 `04b111949fb08caa98ad4ac0c8bc3242`, byte-identical to the main tree's own control binary at this base**, and its head log reproduces the committed `r10uvm150repro/head_pat_BuildUVMPkg.default.cmp` exactly |
| patched binary | `502f483f715b5612dea9cc3367e59f70` |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY — one new predicate, one new term on § 81's existing call, one new early return in § 148's existing predicate |
| probe surface | `tools/probe/r10uvm152repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **BuildUVMPkg default / testflags** | **30** cmp lines, 1 head | **45**, 1 head — a **DIFFERENT, DEEPER** object (§ 8, R0) |
| SeqDriver default / testflags | 36, 1 head | 36 — head log **BYTE-IDENTICAL** |
| SimpleUVM default / testflags | 36, 1 head | 36 — **BYTE-IDENTICAL** |
| Scoreboard default | 36, 1 head | 36 — **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 36, 1 head | 36 — **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 46 / 50, 1 head | 46 / 50 — **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this base's own control CSVs (1588 surelog row-modes + 1358 u2r) |
| byte movers | — | **4 / 956** surelog (2 PREDICTED BY NAME + 2 order-only coins), **0 / 1358** uhdm2rtlil |
| the law's corpus population | 2 wrong cells in 2 databases | **0** — and the whole 1 077 364-line dump diff is those 2 substitutions plus 30 tail removals, nothing else |
| the grid, five arms × two views | — | **RIGHT->WRONG 0, AWAY 0** in every arm, every view; every one-sided set count IDENTICAL before and after; **24 WRONG->RIGHT** cells |
| wide boundary | — | 4311 files × 2 views (see `BOUNDARY.r10uvm152.txt`) |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`uvm_pkg.sv:38762`, an **out-of-body constructor with an EMPTY port list**:

```systemverilog
function uvm_root::new();
  uvm_report_handler rh;          // 38763   <- THE FIRST BODY ELEMENT
  super.new("__top__", null);     // 38764
  rh = new("reporter");           // 38767
  set_report_handler(rh);         // 38768   <- THE CARRIER
```

30 cmp lines, ONE `^LHS:` (`head_pris_BuildUVMPkg.default.cmp`, identical in
both modes and identical to the head `r10uvm150repro` shipped):

```
LHS (golden)                                    RHS (ours)
class_typespec: (uvm_report_handler)            class_typespec: ,
  38763:3-38763:21                                38763:3-38763:21
|vpiParent: \_class_var: (uvm_pkg::rh)          (absent)
|vpiName:uvm_report_handler                     (absent)
|vpiInstance: -> package uvm_pkg                (absent)
|vpiClassDefn: -> uvm_pkg::uvm_report_handler   |vpiClassDefn: -> the same
```

**THE BRIEF'S FRAMING NEEDS ONE CORRECTION, AND THE CORRECTION IS THE LAW.**
The brief reads the head as *"golden's `class_typespec` for the package-scope
`class_var rh` is named and instanced; ours is nameless and uninstanced"*.
Read off both `uhdm-dump`s: **our package-scope `class_var (uvm_pkg::rh)` and
its `class_typespec (uvm_report_handler)` are already there, and the fifteen
dump lines that carry them are BYTE-IDENTICAL to golden's** (`sed -n
'282,297p'` of either dump).  The head is not a missing name — it is a
**BINDING**:

```
uvm_pkg.sv:38768:22   ref_obj (rh)   |vpiActual ->
    golden : class_var (uvm_pkg::rh)                  <- the PACKAGE copy
    ours   : class_var (uvm_pkg::uvm_root::new::rh)   <- a subroutine local
```

and the local's typespec is `compileVariable`'s unnamed fallback.  The head
names the TYPESPEC rather than the variable because `expr::Compare` walks
`Typespec()` inside `basetype_t::Compare` **before** `variables::Compare`
reaches `VpiAutomatic` / `VpiVisibility`, which golden's package copy carries
and our local does not (read from
`~/git-repos/UHDM/build/generated/src/variables.cpp`, not assumed).  Naming
our local's typespec would therefore have moved the head to
`VpiAutomatic` on the same object and cleared nothing.

---

## 2. THE DECODED MODEL (Surelog, read line by line, then measured)

Two mechanisms meet on one name.

### 2.1  The package copy exists — `CompilePackage::collectObjects_`

`src/DesignCompile/CompilePackage.cpp:123` walks the package's whole
FileContent with FOUR stop points — `paClass_declaration`,
`paFunction_body_declaration`, `paTask_body_declaration`,
`paInterface_class_declaration` — and **`paClass_constructor_declaration` is
not one of them**.  So the walk descends into an out-of-body constructor and
hands its `paData_declaration` block items to `compileDataDeclaration(
m_package, …)` (`:261`).  That is § `tfItemLocalLosesToPkgVar148`'s decode, and
we already emit every one of those copies through `collectOobCtorLocals`.

### 2.2  The subroutine local does NOT exist — the constructor compiler's shift

`CompileHelper::compileClassConstructorDeclaration`
(`src/DesignCompile/CompileStmt.cpp:2165`) reads the node after the class scope
as the port list

```cpp
Tf_port_list = fC->Child(nodeId);
if (fC->Type(Tf_port_list) == VObjectType::paClass_scope) {  … 
    Tf_port_list = fC->Sibling(Tf_port_list); }
…
NodeId Stmt;
if (fC->Type(Tf_port_list) == VObjectType::paFunction_statement_or_null)
     Stmt = Tf_port_list;                    // :2219
else Stmt = fC->Sibling(Tf_port_list);
…
} else if (nbStmts > 1) {                    // :2266
    Stmt = fC->Sibling(Tf_port_list);        //   unconditionally, again
```

With an **empty or absent port list there is no `paTf_port_list` node**, so
`Tf_port_list` IS the first body element and the statement walk starts one
element late.  That element is never compiled — § `constructorBodyElementShift27`.

**GOLDEN SAYS IT, IN ONE FILE, WITH ITS OWN CONTROL** (`g152_b_first.sv`, one
Surelog run, both views):

| constructor header | first body element | second | golden |
|---|---|---|---|
| `function E0b152::new();` | `Kb152 e0_one;` | `Kb152 e0_two;` | `e0_one` has **NO** local object at all; the reference at 35:5 binds `class_var (pb152::e0_one)`, the PACKAGE copy.  `e0_two`/`e0_three` are ordinary locals and bind them. |
| `function E1b152::new;` (paren-less) | `Kb152 e1_one;` | `Kb152 e1_two;` | identical split |
| `function E2b152::new();` | the STATEMENT `z2 = 3;` | a nested `begin` | the STATEMENT IS DROPPED from the body; the nested block's own locals are ordinary locals |
| `function F0b152::new(int a);` | `Kb152 f0_one;` | `Kb152 f0_two;` | **BOTH** are ordinary locals — a real port list eats nothing |

and the corpus agrees on its own scale: golden's `uvm_component::new (string
name, uvm_component parent)` (a REAL port list) keeps
`class_var (uvm_pkg::uvm_component::new::top)` and binds it, while
`uvm_root::new()` has no `uvm_pkg::uvm_root::new::rh` anywhere in the database.

### 2.3  Where the reference then lands

§ `ctorFirstBodyItemIsUnlistedNoBind144` read the COMPILE-TIME consequence:
`CompileHelper::bindVariable` (`CompileStmt.cpp:3089`) reads only a scope's
`Variables()` / `Io_decls()`, finds nothing, and the reference falls to late
binding.  What it did not carry is where late binding LANDS.
`UhdmWriter::lateBinding`'s `uhdmfunction`/`uhdmtask` arm
(`UhdmWriter.cpp:3369-3470`) ends at `Instance()`'s `Variables()` guarded by
`inst->UhdmType() == uhdmpackage` — and for an out-of-body constructor that
instance IS the home package, whose listing carries §2.1's copy.  § 144 had
already SEEN this (its arm `e07`: *"an OUT-OF-BODY constructor: golden BINDS,
but to the PACKAGE-level object"*) and fenced itself off with `!curSubOob9`;
nothing then supplied the binding.

> ### § ctorEatenLocalBindsPkgCopy152
>
> A reference to a declaration the constructor compiler **ate** is bare only
> when nothing else lists the name.  When the constructor is **out of body at
> package scope**, the same declaration has already been collected as a
> **package data declaration**, and every reference to it — **in every
> position, the early-bound ones included** — binds that package copy.

**AND THE EARLY-BOUND EXCEPTION DOES NOT APPLY.**  § 81's
`condPredEarlyBound81` exists because a predicate's reference binds EARLY,
through `bindVariable`, and never reaches the pool the package overwrite
iterates.  An eaten declaration is listed on NO scope, so that walk fails in a
predicate exactly as it fails everywhere else.  Measured, not assumed:
`g152_d_pos.sv` reads fourteen names from one eaten declaration in fourteen
positions and golden binds `pd152::<name>` in **all** of them —
`if` predicate (`d_ifc` @26:9), `case` CONDITION (`d_casec` @27:11), `while`
condition, a `for` body's `if`, an lvalue, a ternary operand, a call argument,
an immediate-assertion expression, a NAMED block's `if`, a nested `begin`.  The
SAME constructor's SECOND body element (`int k;`) binds the LOCAL in every one
of those positions — the control that keeps the law to the eaten element.

### 2.4  The sibling correction: a constructor is never the TF-ITEM production

`tfItemBodyLocal148` gates on `tfBodyTfItems9`, i.e. § `blockItems9`, which
reads only the port-list paren — so a **paren-less** `function C::new;` was
called TF-ITEM and **every** one of its body locals took the package copy.
§ `tfItemLocalClassTsNotAConstructor142v` had already decoded why that is
wrong (a constructor body never reaches `compileTfPortDecl`'s
`paBlock_item_declaration` arm), for the TYPESPEC-naming reader.  This pass
gives the BINDING reader the same term, `tfBodyCtor27`
(slang's `MethodFlags::Constructor`, never a `name == "new"` test).  It takes
two pristine-WRONG cells WRONG→RIGHT: `g152_b_first.sv` `e1_two` @45:5 and
`g152_c_home.sv` `a2_second` @40:5, both of which golden binds to the LOCAL.
**It is corpus-INVISIBLE**: a regex over every source tree either corpus can
read finds ZERO paren-less out-of-body constructors, and the two paren-less
IN-BODY ones declare no body local (`PREDICT.r10uvm152.txt`).

---

## 3. THE PRODUCTION CHANGE — three hunks, no new walk, no new object

```
include/UhdmExporter.h   the law, its Surelog citations, its gates and its
                         measured fences + `bool ctorEatenLocal152(...) const;`
src/ExprEmit.cpp         (a) `if (tfBodyCtor27) return false;` inside
                             `tfItemBodyLocal148`            (§ 2.4)
                         (b) `ctorEatenLocal152()` — membership in the set
                             `emitCtorBody27` already records for § 144
                         (c) one term on § 81's existing call:
```
```c++
bool ctorEaten152 = ctorEatenLocal152(nv.symbol);
if (subHomeIsPkg81(currentSubSym, pkgScopeInst) &&
    (ctorEaten152 || !condPredEarlyBound81(expr.syntax)))
    if (auto* pv81 = pkgVarOverFormal81(
            pkgScopeInst, ref->Actual_group(), ref->VpiName(),
            tfItemBodyLocal148(nv.symbol) || ctorEaten152))
        ref->Actual_group(pv81);
```

Nothing is minted.  `pkgVarOverFormal81` is unchanged: it keeps the `!bound`
guard (the law only ever REPLACES a binding) and Surelog's own
`inst->UhdmType() == uhdmpackage` guard and first-match-wins loop.
`ctorUnlistedBid144` is `emitCtorBody27`'s OWN record of the elements it did
not walk — including § `ctorEatenElementIsTheWholeDeclaration144v`'s widening
to every declarator of the eaten `data_declaration` — so the gate cannot drift
from the shift arithmetic that produced it.

**THE FENCES ARE § 81's, REUSED VERBATIM, AND EACH ONE IS A MEASURED CELL** of
`g152_c_home.sv` where NO package copy exists and golden therefore does
something else:

* an **IN-BODY** constructor (`a5_*`): golden leaves the reference BARE, and the
  package lists nothing because `collectObjects_` stops at
  `paClass_declaration`.  `subHomeIsPkg81` reaches it, `pkgVarOverFormal81`
  answers `nullptr`.
* a **`$unit`** class's out-of-body constructor (`u9_*`): golden leaves BOTH
  the eaten and the ordinary local BARE; we bind the local (pre-existing
  residue R4).  No package in the scope chain — inert.
* a **MODULE** class's out-of-body constructor (`m10_*`): golden binds the
  MODULE-level copy `work@mc152.m10_first` (the same shift, with
  `CompileModule.cpp:832` as the caller); we emit no such copy, so we stay bare
  (residue R3).  Inert here, and never moved AWAY.

---

## 4. THE GRIDS — five arms, ten arm-views (`ARMS.r10uvm152.txt`, `CENSUS.r10uvm152.txt`)

Census key = (reference `VpiFullName`, line, col); payload = the **MULTISET** of
`vpiActual` target `VpiFullName`s (`<bare>` for an unnamed target).  Calibrated
golden-vs-golden-vs-golden FIRST: RIGHT→RIGHT 35, every other counter 0.

| arm.view | R→R | **W→R** | **R→W** | WW-unmoved | WW-moved | ONLY-GOLDEN pris/patc | ONLY-OURS pris/patc |
|---|---|---|---|---|---|---|---|
| `g152_a_mech.def` | 8 | **1** | **0** | 0 | 0 | 0 / 0 | 0 / 0 |
| `g152_a_mech.elab` | 6 | 0 | **0** | 8 | 1 | 8 / 8 | 0 / 0 |
| `g152_b_first.def` | 15 | **2** | **0** | 0 | 0 | 0 / 0 | 0 / 0 |
| `g152_b_first.elab` | 8 | 0 | **0** | 12 | 1 | 13 / 13 | 0 / 0 |
| `g152_c_home.def` | 26 | **3** | **0** | 3 | 0 | 3 / 3 | 4 / 4 |
| `g152_c_home.elab` | 23 | 0 | **0** | 21 | 2 | 91 / 91 | 3 / 3 |
| `g152_d_pos.def` | 20 | **10** | **0** | 0 | 0 | 0 / 0 | 1 / 0 |
| `g152_d_pos.elab` | 5 | 0 | **0** | 25 | 2 | 27 / 27 | 0 / 0 |
| `g152_e_shape.def` | 25 | **8** | **0** | 3 | 0 | 1 / 1 | 0 / 0 |
| `g152_e_shape.elab` | 22 | 0 | **0** | 20 | 6 | 26 / 26 | 0 / 0 |

**MOVED-WRONG (RIGHT→WRONG) = 0 on every column of every arm-view**, and every
one-sided count is IDENTICAL before and after — which is what makes AWAY zero
rather than merely unreported.

**THE `WW-moved` CELLS ARE SCORED INDIVIDUALLY, NOT AGGREGATED AWAY.**  Every
one is in the ELAB view and every one is the same law moving TOWARD golden:
pristine `{package copy: 3, LOCAL: 2}` becomes patched `{package copy: 5}`
against golden's `{package copy: 4}` — the LOCAL binding is gone and the
residual multiplicity difference is our pre-existing elab module-clone surplus,
unchanged.  (`g152_c_home.elab` `a1_first`: pristine
`{pc2152::a1_first:2, three module-clone names:2 each, LOCAL:2}` → patched
`{pc2152::a1_first:4, the same three clone names}` vs golden
`{pc2152::a1_first:4}`.)

**THE ONE-SIDED SETS, SCORED EXPLICITLY** (where "a binding added where golden
has none" could hide):

* `g152_d_pos.def` ONLY-OURS 1 → 0.  It is a **weaklyReferenced TAIL** entry
  that disappeared with the orphaned local; the tail is unreachable to the
  judge (RESUME.md §9).  No compared field changed.
* `g152_c_home` ONLY-OURS 4 / ONLY-GOLDEN 3 (def) and the elab view's
  ONLY-GOLDEN 91: the elab module-hoist clones of a package's subroutines,
  which golden RE-NAMES per hoisting class and we do not.  Pre-existing,
  count-for-count unchanged.
* `g152_e_shape` ONLY-GOLDEN 1: `e7_a`, an UNPACKED ARRAY of handles, whose
  package copy golden lists as an `array_var` and we drop entirely (R2).

**THE WHOLE-DUMP DIFF, path-normalised, pristine vs patched, per arm-view**
(`CENSUS.r10uvm152.txt` tail): **every added line is one half of a paired
substitution — there is not a single unpaired addition in any arm, in either
view.**  The patch adds no object and no field; it re-points targets and lets
the orphans fall out of the tail.

### The axes the brief asked for, and what each one decided

| axis | cells | golden's answer |
|---|---|---|
| variable home: package-collected out-of-body constructor local | `a_mech v_ooctor/v_ooctorbare`, `b_first e0_one/e1_one`, `c_home a1_first/a3_first`, `d_pos` ×10, `e_shape` ×8 | the PACKAGE copy — **the law** |
| variable home: package body | `a_mech v_pkgown`, `c_home` | untouched, RIGHT→RIGHT |
| variable home: out-of-body METHOD local (paren'd and paren-less) | `c_home a6_par_*`, `a6_bare_*` | the LOCAL — nothing is eaten, no package copy exists |
| variable home: package free function | `c_home a7_*`, `a_mech v_pf` | the LOCAL |
| variable home: in-body class method / in-body constructor | `a_mech v_ibm/v_ibnew/v_ibctor`, `c_home a5_*` | BARE |
| variable home: `$unit` class | `c_home u9_*` | BARE (R4) |
| variable home: module class, in-body and out-of-body | `c_home m10_*`, `m11_*` | the MODULE-level copy / the local (R3) |
| class home: same package / another package wildcard-imported / SCOPED | `c_home a1/a2/a3` | no term — all three take the package copy |
| typedef'd handle, typedef of a specialization | `e_shape e4_a`, `e6_a` | the package copy, whose KIND golden makes a `logic_var`; ours is a `class_var` and the reference is unbound at the § 81 site, so this law leaves it exactly where it found it (R1) |
| parameterized class handle | `e_shape e5_a` | the package copy — **moved** |
| arrays / queues / associative arrays of handles | `e_shape e7_a/e8_a/e11_a` | `e7_a` R2; the queue and the assoc array are read through method receivers and carry no `vpiActual` cell |
| 1 / 2 / 3 declarators in one declaration | `e_shape e1_a`, `e2_a/b/c`, `e3_a` vs `e3_b` | ALL declarators of the eaten `data_declaration` (§ 144v), and ONLY that declaration |
| non-class kinds and an initialiser | `e_shape e9_i/e9_s/e9_v/e9_r`, `e10_i` | the kind carries no term; only being FIRST does |
| DEF / ELAB | every arm | identical law, both views |

---

## 5. THE A-PRIORI PREDICTION (`PREDICT.r10uvm152.txt`)

Made from the pristine databases and the corpus SOURCES alone, before the
patched binary existed.  The law's necessary condition is an out-of-body class
constructor, at package scope, with an empty or absent port list, whose FIRST
body element is a data declaration that is then referenced.  A regex over every
source tree either corpus can read finds five such files; the control
workdirs' own `cmds.txt` say that of the rows reading them, **only
`BuildUVMPkg` produces a database at all** (the OVM/VMM/uvm-1.1d rows are
`SLANG_REJECT`/`SURELOG_FAIL`, and the two that do produce one contain no
object of the shape).  `Surelog/tests/ExtendClassMember/dut.sv` has an
empty-paren out-of-body constructor whose first element is a STATEMENT — the
already-modelled § 27 case, with no cell of this law.

```
PREDICTED MOVERS   default/BuildUVMPkg-bf853d43 , testflags/BuildUVMPkg-bf853d43
PREDICTED CELL     uvm_pkg.sv:38768:22  vpiActual
                     class_var (uvm_pkg::uvm_root::new::rh)  ->
                     class_var (uvm_pkg::rh)
                   2 cells per database (def + elab), 4 in total
OBSERVED           exactly that, and 30 tail removals, in a 1 077 364-line dump
```

The two unpredicted movers, `default/Scoreboard` and `default/SeqDriver`, are
ORDER ONLY: sorted, path-normalised dumps diff to **0 lines** over 1 100 243
and 1 816 068 lines.  Their testflags twins did not move.

---

## 6. GATES — `GATES.r10uvm152.txt`, all green

Build (both binaries, md5s, and a FROM-SCRATCH rebuild after two `cmake
--build` runs briefly overlapped — the BUILD RACE trap, defused by discarding
both object trees); goldens 23/0 with the `/bin/false` negative control 0/23;
u2r testflags+default 0 differing rows against three baselines with byteverify
`MOVERS 0/1358`; surelog `--mode both` 0 differing rows over 1588 row-modes
with byteverify `MOVERS 4/956`, all four named and attributed; heads;
`canaries.sh` ok=52 / ok=8 changed=0; `ctcan2.sh` ×2 PASS; `canaudit.sh` PASS
(audited=29, UNCOVERED=0, FENCE-BREACH=0); SVSwitch pinned `4842211c4030` and
YosysVerx `6ccda350c24a`.  **NO ROW CONVERTED.**

---

## 7. BOUNDARY — `BOUNDARY.r10uvm152.txt`

`bound152.sh` over a COPY of the whole committed probe tree: every `.sv`/`.v`
at top level AND in subdirectories, both views, both binaries, byte-compared,
with `PROCESSED` asserted against `LISTED`, every child `</dev/null`, every rc
recorded, and scratch keyed on the RELATIVE path.  This pass's own five arms
are the POSITIVE CONTROL — a gate that reports zero movers over them cannot
see.

    LISTED=4311  PROCESSED=4311  PRODUCED_DBS=4166  MOVED_ARMS=9  RC_DIFFS=0

Five movers are this pass's own arms.  The other FOUR are earlier-pass arms,
every one re-measured against golden with the official `uhdm-cmp` and the
census, and every one carrying exactly ONE cell of this law that moves
**WRONG→RIGHT**:

| earlier-pass arm | the cell | pristine → patched | golden |
|---|---|---|---|
| `r10uvm144repro/g144_e.sv` | `p144e::C07::new::vc07` @29:48 | local → `p144e::vc07` | `p144e::vc07` |
| `r10uvm47repro/t65c/dut.sv` | `r1::ooc::new::shared_name` @38:9 | local → `r1::shared_name` | `r1::shared_name` |
| `r10uvm47repro/t65d/dut.sv` | `r2::ooc::new::dup_name` @22:9 | local → `r2::dup_name` | `r2::dup_name` |
| `r10v144repro/v144_b_ctor.sv` | `q144b::B22::new::b22x` @70:44 | local → `q144b::b22x` | `q144b::b22x` |

`g144_e.sv` is § 144's OWN arm `e07` — the cell its README recorded as *"an
OUT-OF-BODY constructor: golden BINDS, but to the PACKAGE-level object"* and
fenced itself off from with `!curSubOob9`.  This pass is what supplies it.
`RIGHT→WRONG = 0` and every one-sided count is IDENTICAL on all four arms, in
both views, and the official cmp line count and head count of all four are
UNCHANGED (the cells sit below each arm's head).  `RC_DIFFS=0`.

---

## 8. RESIDUES, RANKED, AND R0

* **R0 — THE NEXT HEAD.**  BuildUVMPkg, both modes, 45 cmp lines, one `^LHS:`:
  `LHS: class_var (uvm_pkg::clp)` @`33188:27-33188:66` (`uvm_phase::new`'s
  nested-`begin` local `uvm_cmdline_processor clp = uvm_cmdline_processor::
  get_inst();`, collected into the package listing with `vpiAutomatic:1
  vpiVisibility:1` and `vpiExpr -> ref_obj (uvm_cmdline_processor::get_inst)`)
  with **`RHS: <null>`**.  READ THE OVERLOAD BEFORE NAMING THE FIELD
  (RESUME.md §9): **both dumps contain that object**, so this is not a missing
  variable — the `<null>` names a CONTAINER whose element golden has at a
  position we do not, i.e. a vector size/order mismatch on whatever lists it.
  Decode which container first.
* **R1** — a TYPEDEF'd class handle as the eaten element (`e_shape e4_a`,
  `e6_a`): golden's package copy is a **`logic_var`** (Surelog's package
  data-declaration split by WRITTEN type), ours a `class_var`, and our
  reference is not bound at the § 81 site at all (it goes to §§ 107/117's
  module-net hoist pool), so `pkgVarOverFormal81`'s `!bound` guard leaves it
  untouched.  Corpus incidence ZERO.
* **R2** — an UNPACKED ARRAY as the eaten element (`e_shape e7_a`): golden
  lists a package `array_var`; our package listing drops unpacked arrays
  ("not modelled yet, still dropped", ParamEmit).  Corpus incidence ZERO.
* **R3** — a MODULE class's out-of-body constructor (`c_home m10_*`): the same
  shift with `CompileModule.cpp:832` as the caller, so golden binds the
  MODULE-level copy `work@mc152.m10_first` and lists the ordinary local
  `work@mc152.M10c152::new.m10_second`; we emit neither and stay bare.  Corpus
  incidence ZERO.
* **R4** — a `$unit` class's out-of-body constructor (`c_home u9_*`): golden
  leaves EVERY reference bare, eaten or not; we bind the local.  Pre-existing;
  `unitSubNoBind9` does not cover an out-of-body constructor body.
* **R5** — the SPAN of a PAREN-LESS constructor's ordinary local:
  `pb152::E1b152::new::e1_two` is ours at `43:5-43:10` and golden's at
  `43:11-43:17`, because § `blockItems9` reads only the port-list paren.  Span
  is DUMP-ONLY — no generated `Compare` reads a location.
* **R6** — the ELAB module-hoist clones of a package's subroutines: golden
  re-names every reference inside a clone after the hoisting class
  (`work@mc152::M10c152::new::a1_first`) and we keep the package spelling.  A
  large pre-existing ONLY-GOLDEN set, count-for-count unchanged by this pass.
