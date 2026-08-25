# r10uvm127 — § `pkgRetOobClassAndImportCloneTs127`

**AN OUT-OF-BODY CLASS-METHOD DEFINITION IS A *PACKAGE-LEVEL* FUNCTION
DECLARATION, AND AN IMPORT CLONE IS A CLONE OF THE ELABORATED LISTING** — the
SeqDriver ×2 + MiniAmiq ×2 head **CLEARED** on all four row-modes.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW WAS CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f561b4d` |
| production surface | `include/UhdmExporter.h` (one predicate + its decode) and the TWO gate sites that read it — `src/StmtEmit.cpp`, `src/ExprEmit.cpp` — **3 files, +53 −4 lines, 45 of the added lines are the decode comment** |
| probe surface | `tools/probe/r10uvm127repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SeqDriver default / testflags** | **17** | **17** | 1 — a **NEW** head object, a different family (§6 R0) |
| **MiniAmiq default / testflags** | **17** | **294** | 1 — a **NEW** head object, a different family (§6 R0) |
| SimpleUVM default / testflags | 12 | 12 | same head object, **object ids only** (2 new objects are minted ahead of it) |
| Scoreboard default | 12 | 12 | same head object, object ids only |
| BuildUVMPkg default / testflags | 12 | 12 | cmp log **byte-identical** |
| Earlgrey_0_1 default / testflags | 214 / 144 | 214 / 144 | cmp log **byte-identical** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** over 1588 surelog rows and 1462 uhdm2rtlil rows | |
| byte movers | — | **7 / 956** surelog, **0 / 1358** uhdm2rtlil | |
| the nine UVM databases | — | **46 cells TOGOLD, 0 MOVED-WRONG, 4 MOVEDOTHER, 0 one-sided added or removed, 0 one-sided payload rewrites** | |
| the twelve arm-views | — | **75 TOGOLD, 0 MOVED-WRONG, 8 MOVEDOTHER, 0 ONESIDED_MIXED** | |
| wide boundary | — | 3830 sources × 2 views, **26 moved arm-views**, 10 this pass's own; the 16 foreign ones score **7 TOGOLD / 0 MOVED-WRONG** | |

The cmp-line counts are DEPTH, not distance: they are the size of the head
object's decompile.  MiniAmiq's 17 → 294 is a head **object** change (a
`named_fork` container), not a regression — the whole-dump diff of that database
**removes nothing** and adds only this law's own lines (§7).

---

## 1. THE HEAD, AS THE JUDGE PRINTED IT

`head_pris_default_SeqDriver.cmp` (17 lines, `grep -c '^LHS:'` = 1; identical in
both modes and, but for object ids, on MiniAmiq):

```
LHS  ref_typespec: (uvm_pkg::uvm_printer::adjust_name::id), id:7725
       |vpiParent:  \_ref_obj (…::adjust_name::id) @808:25-808:27
       |vpiActual:  \_string_typespec  @445:33-445:39
RHS: <null>
```

**THE FIELD IS `expr::Typespec`.**  `ref_obj::Compare`
(`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:122`) does **not** read
`Typespec` itself; it delegates to `expr::Compare`
(`…/generated/src/expr.cpp`), whose last line is
`SafeCompare(lhs->Typespec(), rhs->Typespec(), context)`.  The SINGULAR
`SafeCompare` overload with `rhs == nullptr` names the VALUE and prints
`RHS: <null>` (RESUME §9): golden's reference carries a `ref_typespec`, ours
carried none.

Site, `uvm-1.2 src/base/uvm_printer.svh:805-809`:

```systemverilog
function string uvm_printer::adjust_name(string id, byte scope_separator=".");
  if (knobs.show_root && …) return id;
  return uvm_leaf_scope(id, scope_separator);
//                      ^col 25
endfunction
```

and `uvm_misc.svh:445` is
`function string uvm_leaf_scope (string full_name, byte scope_separator = ".");`
— columns 33-38 are the **CALLEE's FIRST FORMAL's** `string`.

**THE STAMP IS BY POSITION AND THE OBJECT IS SHARED.**  `ct127cen` reports
`ATSID == FTSID` on every golden cell of this family, and `uvm_re_match`'s cell
proves the binding is POSITIONAL, not by name: the actual is `s`, the formal is
`re`, and the actual takes `re`'s typespec.

---

## 2. THE DECODE — READ, NOT GUESSED

### 2.1 who writes the typespec

`UHDM::ExprEval::evalFunc`, `~/git-repos/UHDM/templates/ExprEval.cpp:5860-5885`,
"set args":

```cpp
  if (func->Io_decls()) {
    uint32_t index = 0;
    for (auto io : *func->Io_decls()) {
      if (args && (index < args->size())) {
        …
        typespec *tps = io->Typespec()->Actual_typespec();
        expr *ioexp = (expr *)args->at(index);
        if (expr *exparg = reduceExpr(ioexp, invalidValue, modinst, pexpr, muteError)) {
          if (exparg->Typespec() == nullptr) { … mint a ref_typespec … }
          if (exparg->Typespec())
            exparg->Typespec()->Actual_typespec(tps);      // <-- THE ASSIGNMENT
```

It walks the callee's `Io_decls` **BY POSITION**, mints a `ref_typespec` on the
actual when it has none, and points it at the **formal's OWN typespec object —
a shared pointer, never a `clone_tree` copy**.  The id-identity in the dump is
what decides that, and it decides SHARED.  The write happens BEFORE the body is
evaluated, so it lands whatever the body does; when the body then FOLDS, the
whole call is replaced by the constant and the stamped actuals leave the tree
with it.  `Surelog CompileHelper::compileTfCallArguments`
(`CompileHelper.cpp:4350-4358`) also fetches `Io_decls`, but ONLY to order
named arguments — it never writes a typespec.  There is no other writer:
`grep -rn -e '->Function()' -e '->Task()' src/` over the whole Surelog tree
returns exactly those two lines.

### 2.2 who calls it, and therefore WHICH LISTINGS carry the stamp

`ExprEval::evalFunc` has exactly two callers:
`ExprEval::reduceExpr`'s `uhdmfunc_call` arm (`ExprEval.cpp:4691`) and
`CompileHelper::EvalFunc` (`CompileExpression.cpp:3257`), which runs **only
when `reduce == Reduce::Yes`**.  And:

* `CompilePackage.cpp:63,68` — a package is compiled **TWICE**:
  `instance->compile(Reduce::Yes)` on the `Package`, then
  `compile(Reduce::No)` on `getUnElabPackage()`.  UhdmWriter puts the first in
  `design.TopPackages` and the second in `AllPackages`.
* `CompileStmt.cpp:834-843` — `paRETURN` is the ONLY statement arm that threads
  the inherited `reduce` into `compileExpression`; every nested construct
  hardcodes `Reduce::No` (this is r10buvm8's § `pkgRetTopCallArgFormalTs8`).
* **`CompilePackage.cpp:213-218` — `paFunction_declaration` AT PACKAGE LEVEL
  goes to `compileFunction(m_package, fC, id, m_compileDesign, reduce, …)`,
  and `CompileStmt.cpp:2344-2351` shows that an out-of-body definition
  `function T C::m(…);` IS such a declaration**: its `paClass_scope` name is
  assembled into `"C::m"` and looked up in the PACKAGE's task_funcs.  So an
  out-of-body method body is compiled with the PACKAGE's `reduce` — Reduce::Yes
  in the elaborated pass — exactly like a free package function.  An IN-BODY
  method is compiled by `CompileClass` and never sees Reduce::Yes.
* **`CompileHelper::importPackage` (`CompileHelper.cpp:319-325`) `clone_tree`s
  `def->getTask_funcs()`** of the imported package into the importer, where
  `def` is the ELABORATED `Package*` found by name in the Design — the same
  object whichever view of the IMPORTER is being compiled.  So BOTH of the
  importer's listings are clones of ALREADY-STAMPED bodies.
* `CompileModule.cpp:776,784` and `CompileFileContent.cpp:95-98` compile their
  tasks and functions with a hardcoded `Reduce::No`: a class living in a MODULE
  or at `$unit` scope takes nothing, out-of-body or not.

### 2.3 the golden table this predicts, and MEASURES (SeqDriver, `ct127cen`)

| listing | golden | ours (pristine) |
|---|---|---|
| `uvm_pkg` **AllPackages** (the unelab twin), free fn and `C::m` clone | **bare** | bare ✓ |
| `uvm_pkg` **TopPackages**, free fn | stamped | stamped ✓ |
| `uvm_pkg` **TopPackages**, out-of-body method (the `class_defn`'s own body) | **stamped** | **bare ✗ — the head** |
| `adpcm_pkg` (importer) **TopPackages**, free fn | stamped | stamped ✓ |
| `adpcm_pkg` **AllPackages**, free fn | **stamped** | **bare ✗** |
| `adpcm_pkg` both views, out-of-body method | **stamped** | **bare ✗** |

Five call sites carry the whole family in SeqDriver's golden — `uvm_leaf_scope`,
`uvm_bitstream_to_string`, `uvm_re_match`, `uvm_dpi_get_next_arg_c` — 102 of
35 214 bound-callee `ref_obj` actuals.

### 2.4 the discriminator that the corpus itself proves

Three CLASS-METHOD callers in the same golden are **BARE**:
`uvm_resource_pool::lookup_regex_names`, `uvm_objection::convert2string`,
`uvm_default_report_server::compose_message` — all three are **IN-BODY**
definitions (`uvm_resource.svh:1065`, `uvm_objection.svh:1058`,
`uvm_report_server.svh:897`).  `uvm_printer::adjust_name` is `extern` at
`uvm_printer.svh:238` and DEFINED out-of-body at `:805`.  In-body vs
out-of-body is the whole difference, and it is exactly `Reduce::No` vs
`Reduce::Yes`.

---

## 3. THE LAW

> **§ `pkgRetOobClassAndImportCloneTs127`.**  The callee-formal typespec stamp
> of § `pkgRetTopCallArgFormalTs8` is present in **every listing that derives
> from Surelog's `Reduce::Yes` package compile**, not only the home package's
> elaborated free-subroutine listing:
>
> 1. the **`class_defn`'s own copy of an OUT-OF-BODY method body**, when the
>    class's home is a **PACKAGE** (a module- or `$unit`-scoped class takes
>    nothing);
> 2. and **BOTH VIEWS of a WILDCARD-IMPORT CLONE**, because the clone is a
>    `clone_tree` of the imported package's ELABORATED listing.
>
> **The HOME package's own `AllPackages` listing stays BARE** — free
> subroutines and `C::m` clones alike — because that listing is the
> `getUnElabPackage()` compile with `Reduce::No`.
>
> **An IN-BODY class method is not in the family at all**: `pkgScopeInst` is
> already null exactly for `classScope && !oob`, so the existing gate fences it
> with no new test.

Implementation — the whole behavioural change is one predicate replacing
`pkgTopEmit` at the window's two gate sites:

```cpp
    bool pkgRetTsListing127() const {
        return pkgTopEmit || pkgImportCloneEmit ||
               (inClassBodyEmit && classBodyHomePkg75 != nullptr);
    }
```

`inClassBodyEmit` (`= oob && classScope && !cloneMode`) and
`classBodyHomePkg75` (the class's home package, non-null only when that home IS
a package) were both already computed at the emission site, for
§ `withIterIterBindsHoistNet75` / § `oobRefVarLocalHoistNet107`; the
home-package DEF-view `C::m` clone listing is `cloneMode` with neither
`pkgTopEmit` nor `pkgImportCloneEmit` and therefore stays bare, which is what
golden's unelaborated twin holds.

---

## 4. THE GRIDS (`g127_*.sv`, six arms, both views, `arms127.sh`)

**Every callee whose actual is expected to take a stamp is a DPI-C import or an
SV function whose own body reaches one.**  That is not decoration: `evalFunc`
stamps BEFORE it discovers whether the body evaluates, and a callee whose body
DOES fold has its whole call replaced by the constant — the stamped actuals
leave the tree with it, and the cell reads exactly like an unstamped one.  The
first draft of these grids used ordinary SV callees and measured **nothing**
(golden showed no stamp anywhere, including for the free-package-function shape
the corpus proves is stamped); `g127_a_kinds`'s `emberFold` is that fold fence,
kept deliberately.

| arm | axis | patched (ARGKINDS=all) |
|---|---|---|
| `g127_a_kinds` | CALLEE KINDS from a free package function's direct return: DPI plain / DPI context / DPI with enum + packed-vector formals / an unfoldable SV wrapper / a FOLDABLE SV callee / a FORWARD-declared callee / a non-return assignment / a task body | 0 TOGOLD (all already agreeing or pre-existing residues), 0 MOVED-WRONG |
| `g127_b_oob` | **THE PASS'S AXIS**: out-of-body single-statement body, out-of-body multi-statement (synthetic `begin`) body, out-of-body body with the call inside a nested `if` (fence), out-of-body task, and TWO IN-BODY methods (fence) | def 4 / elab 4 TOGOLD |
| `g127_c_import` | WILDCARD-IMPORT CLONES: a home package with free functions and an out-of-body method, an importer that only imports | def 8 / elab 4 TOGOLD (+4 MOVEDOTHER, §5 R2) |
| `g127_d_homes` | THE HOME FENCE: `$unit` class + free function, MODULE class + module function, PACKAGE class + package function as the positive control, all four written out-of-body | def 2 / elab 2 TOGOLD; the `$unit` and module halves stay BARE |
| `g127_e_ts` | TYPESPEC KINDS × DIRECTIONS × ACTUAL SHAPES: string int byte logic enum struct typedef class real; input output inout ref; formal / local / class property / part-select / member (hier_path fence) / literal / operation | def 14 / elab 13 TOGOLD (+2 MOVEDOTHER, §5 R3) |
| `g127_f_mult` | MULTIPLICITY and NESTING: one/two/three-argument calls, a nested call whose INNER actuals stamp too, an array-index actual, RECURSION, and the same shape written three times with different names | def 12 / elab 12 TOGOLD |

Totals over the twelve arm-views: **75 TOGOLD, 0 MOVED-WRONG, 8 MOVEDOTHER,
0 ONESIDED_MIXED, 0 ONESIDED_PAT_CHANGED**.
Golden-vs-golden calibration over the same twelve arm-views — run 1 in the arms
scratch, run 2 in a DIFFERENT directory — is **0 DIFF / 0 ONESIDED**
(`CALIB.r10uvm127.txt`), so the census key is neither path- nor run-dependent.

The arms are NOT scored with the official `uhdm-cmp`: each of them differs from
its golden at the DESIGN object itself (thousands of cmp lines, from DPI
imports and other families), so a cmp line count there measures the whole
design's decompile size and nothing else.  The census is the instrument, as in
every pass of this family.

---

## 5. RESIDUES

**R1 — a payload written onto a cell GOLDEN FOLDED AWAY (grid-only).**  Where
the callee's body folds, golden's elaborated listing holds a CONSTANT and no
call object at all, while ours still holds the call.  The law then writes a
typespec onto an actual golden has no counterpart for.  This is scored
explicitly as `ONESIDED_PAT_CHANGED` and is **0 on all nine UVM databases in
both argument-kind settings, and 0 on the twelve g127 arm-views**; it is 26 across
the eighteen FOREIGN arm-views the wide boundary reports (`FOREIGN.r10uvm127.txt`).
The underlying defect is that WE do not fold those calls — a different family;
if we folded, there would be no object to stamp.  Left visible rather than
fenced, because a "callee body folds" fence would have to model
`ExprEval`'s evaluator and this pass did not decode it.

**R2 — the importer's listing COPY COUNT (grid-only).**  `g127_c_import.elab`:
golden holds FOUR copies of the importer's clone cell, we hold THREE.  The
pass converts our last bare one, so the multiset goes from
`{bare 1, stamped 2}` to `{stamped 3}` against golden's `{stamped 4}` —
strictly closer, scored MOVEDOTHER because the counts still differ.  Corpus
population zero: the nine UVM databases have the same copy counts on both
sides.

**R3 — the object the stamp POINTS AT, where OUR formal's own typespec already
differed.**  Four corpus cells (SeqDriver ×2 modes, MiniAmiq ×2 modes:
`uvm_vector_to_string`'s `radix`) and two arm cells (`g127_e_ts` `kEnum`,
`kStruct`) score MOVEDOTHER: the law faithfully copies OUR formal's typespec,
and that object was already a different one from golden's (the enum/struct
typedef-linkage family).  The SIBLING cell in each case is `SAME_DIFF` with the
same mismatch on BOTH binaries, which is what pins it as pre-existing.

**R4 — r10buvm8's residue R6 is CLOSED.**  That pass recorded
"class-method top-level return … fenced out — `voob8.sv` stays BARE on both
binaries, the fence does not leak".  It verified OUR two binaries, never golden.
Golden STAMPS `voob8`'s `class_defn(C)/function(oobm)` copy and leaves the
package `C::m` clone and the IN-BODY `inlm` bare — measured here
(`FOREIGN.r10uvm127.txt`), and the arm now scores 2 TOGOLD in both views.

**R5 — the FORWARD-REFERENCE fence disagrees with golden on a DPI callee
(pre-existing).**  `g127_a_kinds`'s `oxbowEarly` calls a DPI import declared
LATER in the same package: golden STAMPS it, our
§ `pkgRetCalleeDeclaredFirst8v` refuses.  `SAME_DIFF` — identical on both
binaries, untouched by this pass; recorded because the arm makes it visible.

---

## 6. R0 — THE NEXT HEAD

Two different objects, both pre-existing behind the cleared one (the whole-dump
diff of every mover REMOVES NOTHING, so neither is new):

* **SeqDriver ×2, `head_pat_default_SeqDriver.cmp`, 17 lines** — a MISSING NET:
  `LHS logic_net (work@top_tb.sz) @488:15-488:17, vpiNetType:1`, parent
  `module_inst work@top_tb`, `RHS: <null>`.  `uvm-1.2 base/uvm_packer.svh:488`
  is `bytes = new[sz];` inside the OUT-OF-BODY method `uvm_packer::get_bytes`
  (defined at `:484`), and columns 15-17 are the `sz` operand of the
  array-`new` size.  Golden hoists an implicit wire for that unresolvable name
  into the TOP MODULE; we mint none.  Same family as
  §§ `withIterIterBindsHoistNet75` / `oobRefVarLocalHoistNet107` /
  `pkgFreeSubRefVarHoistNet117`, but the pool it lands in is the top module's,
  not a package's.
* **MiniAmiq ×2, `head_pat_default_MiniAmiq.cmp`, 294 lines** — a MISSING
  `named_fork`: `LHS named_fork (uvm_pkg::uvm_phase::execute_phase::
  master_phase_process) @1400:9-1413:18, vpiJoinType:1`, parent the
  `execute_phase` `begin`, `RHS: <null>`.  `uvm_phase.svh:1400` is
  `fork begin : master_phase_process … end join_none` inside
  `uvm_phase::execute_phase`; we emit no named fork there at all.

---

## 7. THE MOVER PREDICTION, MADE BEFORE THE COMPARISON

`pred127.cpp` reads a **PRISTINE database ALONE** and names every cell the law
could touch: an untyped `ref_obj`/`constant`/`operation` actual of a BOUND
`func_call` that is the direct body-level `return` expression of its enclosing
subroutine, where the enclosing function is either parented by a `class_defn`
whose home is a package AND has a `C::m` package listing entry (the out-of-body
signal, read from the database itself), or parented by a package whose listing
name also appears in a DIFFERENTLY-NAMED package (the import-clone signal).  It
deliberately OVER-approximates — the home package's own DEF and ELAB listings
are both named and neither moves, which is the fence doing its job.

* `PREDICT.r10uvm127.txt` — `LISTED=956 PROCESSED=956 CANDIDATE_DATABASES=7
  ZERO_CANDIDATE_DATABASES=949 CANDIDATE_CELLS=94`:
  `default/{MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}` and
  `testflags/{MiniAmiq,SeqDriver,SimpleUVM}`.
* `PREDICT.u2r.r10uvm127.txt` — `LISTED=1358 PROCESSED=1358
  CANDIDATE_DATABASES=0`.

`byteverify` then found **exactly** those 7 databases on surelog and **0** on
uhdm2rtlil: **0 movers unpredicted, 0 predicted databases that failed to move.**

`MOVERS.r10uvm127.txt` is the order-blind, path-normalised whole-dump diff of
each mover (both dumps sorted, so Scoreboard/default's ~50/50 `vpiTaskFunc`
ORDER COIN cannot be mistaken for a move).  Per mover: **0 removed lines**, and
91 added on SeqDriver/MiniAmiq (13 new stamps) / 14 on SimpleUVM/Scoreboard
(2 new stamps).  **Every added line in every mover is one of the law's own** —
`|vpiTypespec:` / `|vpiParent:` / `|vpiActual:` / `\_ref_typespec:` /
`\_ref_obj:` / `\_<kind>_typespec:` / `|vpiFullName:` — 0 lines outside it.

---

## 8. INSTRUMENTS (all measurement-only; the judge is `uhdm-cmp`)

| file | what it does |
|---|---|
| `ct127cen.cpp` | census of EVERY argument of every tf_call: the argument's kind, span, `ref_typespec` ACTUAL kind/id/span, its `vpiActual`, and the CALLEE's formal at that position (name, direction, typespec kind/id/span) — so `ATSID == FTSID` answers "shared or cloned" directly.  The owner CHAIN is printed with object ids, which is how the four listings of one package are told apart |
| `score127.py` | golden vs pristine vs patched, multiset join per key; one row per OBJECT (the listener revisits shared subtrees, and a visit count is not a cell count); `ARGKINDS` widens the join from `ref_obj` to the constant/operation actuals; `ONESIDED_PAT_CHANGED` makes a payload write onto a cell golden has no object for impossible to miss |
| `arms127.sh` | every `g127_*.sv` under Surelog + both binaries, BOTH views, per-arm subdirectory keyed on the arm's RELATIVE path, fd-3 file list, children `</dev/null`, every rc recorded, PROCESSED asserted |
| `uvmcen127.sh` | the same census over the named rows of two `verify_golden` workdirs; the golden path comes out of each row's OWN `cmds.txt`; a missing side prints SKIP-NOFILE and is COUNTED |
| `pred127.cpp` / `predsweep127.sh` | the A-PRIORI mover predictor and its whole-workdir sweep (§7).  A database with nothing to predict prints NOTHING and is COUNTED, so the artifact never enumerates a workdir's rows by name |
| `bound127.sh` | the WIDE boundary (from `r10buvm30/bound30.sh` via `r10uvm124`): every `.sv`/`.v` under a COPY of `tools/probe`, both binaries, both views, no path filter |
| `g127_a_kinds.sv` … `g127_f_mult.sv` | the six grids of §4 |
| `head_{pris,pat}_{default,testflags}_{SeqDriver,MiniAmiq}.cmp` | the judge's own head logs, before and after |
| `ARMS… CENSUS… CALIB… FOREIGN… PREDICT… MOVERS… BOUNDARY… GATES…` | the evidence |
| `canaudit.sh` / `canaries.sh` / `ctcan2.sh` / `ct8rows.sh` / `byteverify.sh` / `rowheads.sh` | the standard gate battery, carried so `canaudit.sh` can prove the fenced names are covered here |

## 9. GATES

All green — `GATES.r10uvm127.txt` carries the full list with both binaries'
md5s, the `cmds.txt` binary audits, the two status histograms, `ct8rows` against
both the committed baseline and this pass's own pristine sweep (0 differing rows
over 1588 + 1462), the byteverify SELFCHECKs, the a-priori prediction, the head
table, the canary battery, the protected-database md5s and the wide boundary.
