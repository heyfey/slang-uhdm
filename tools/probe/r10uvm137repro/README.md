# r10uvm137 — § `dottedForeachLoopVarBaseMustDrill137`

**The head cleared.**  MiniAmiq, both modes, 56 cmp lines and one `^LHS:` at
base `194069b` (re-measured on THIS worktree's own pristine build with
`rowheads.sh` before a line of code was written — see `head_pris_*_MiniAmiq.cmp`):

```systemverilog
      foreach (pred_of_succ[pred]) begin        // uvm_phase.svh:1737
        if (pred.get_phase_type() != UVM_PHASE_NODE) begin
          …
          foreach (pred.m_predecessors[next_pred])     // :1740   <- THE HEAD
```

```
LHS (golden)                                RHS (ours)
int_var:  (…::next_pred) 1740:40-1740:49    class_var: (…::next_pred) 1740:40-1740:49
|vpiTypespec -> ref_typespec                |vpiTypespec -> ref_typespec
  |vpiActual -> int_typespec  (bare)          |vpiActual -> class_typespec 'uvm_phase'
|vpiName:next_pred                          |vpiName:next_pred
```

`vpiName`, the span and the parent already agreed; the only Compare-visible
difference is the loop variable's KIND and, through `ref_typespec::Actual_group`,
its typespec's kind and name.

**Head after:** MiniAmiq both modes **56 → 58**, still exactly one `^LHS:`, on a
NEW object — `string_var 'values'` at `uvm_component.svh:3380`, where the ONLY
differing line is our `|vpiAutomatic:1` against golden's absent flag (R0 below;
`head_pat_*_MiniAmiq.cmp`).  The count rises because it is a DEPTH, not a
distance.  Every other row's head is unchanged: SeqDriver 17, SimpleUVM 64,
Scoreboard/default 64, BuildUVMPkg 64, Earlgrey_0_1 21302 / 21926,
Rggen/default 0.

---

## 1. The decoded model (Surelog, read line by line)

`UhdmWriter::lateTypedefBinding` (`UhdmWriter.cpp:3139-3148`) hands every
`VpiLoopVars()` entry of a `foreach_stmt` to **`swapForSpecifiedVar`**
(`UhdmWriter.cpp:2490`), which types the loop variable from the object the
foreach lists under `vpiVariables` and reads only TWO kinds: a `hier_path`
goes to `decodeHierPath` **AS WRITTEN** (`:2507` / `:2521`), a `ref_var` gets a
synthetic one-element path built from its NAME (`:2529`).  When the walk
answers nothing, `indexTypespec` stays null, `getSimpleVarFromTypespec` is
never called, and `:2546-2553` mints the bare fallback

```cpp
int_var* ivar = s.MakeInt_var();
ref_typespec* rt = s.MakeRef_typespec();
rt->Actual_typespec(s.MakeInt_typespec());   // no name, no span, no ranges
```

— the very fallback § `foreachScopedArrayLoopVarIntFallback34` decoded for the
`::`-written spelling.  **This pass decodes when the DOTTED spelling reaches
it.**

`CompileHelper::decodeHierPath` (`CompileExpression.cpp:759`) forwards to
`UHDM::ExprEval::decodeHierPath` (`ExprEval.cpp:2227`), which takes the
**FIRST** `Path_elems` entry's name as `baseObject` (`:2233`) and resolves it
with `ExprEval::getObject`.  That walk climbs `VpiParent` and, at every level,
after the scope's `Variables()` and a `task_func`'s `Io_decls()`, reads

```cpp
if (pexpr->UhdmType() == uhdmforeach_stmt) {          // ExprEval.cpp:417-427
  for (auto var : *((foreach_stmt*)pexpr)->VpiLoopVars())
    if (var->VpiName() == name) { result = var; break; }
}
```

— **an enclosing foreach's LOOP VARIABLE is a resolvable base**, and it is
found *as `lateTypedefBinding` has already swapped it* (registration order is
source order, so the outer loop variable is typed before the inner one is
looked up).

`hierarchicalSelector` (`ExprEval.cpp:2303`) then drills that object.  Its
`variables` arm has exactly three cases — `uhdmstruct_var`, `uhdmclass_var`,
`uhdmarray_var` — and the CLASS and STRUCT ones both search the members and
fall through when the name does not match, so that the `level == 0` re-entry
(`ExprEval.cpp:2708-2710`) can retry the real member at level 1 (corrected by
the verifier: the STRUCT arm drills too — see the amendment below).  The
`array_var` arm CONSUMES the level (it recurses with the typespec), and every
other variable kind has no arm at all.  A walk that answers nothing returns
`nullptr` → the `int_var` fallback.

### The law

> **§ dottedForeachLoopVarBaseMustDrill137.**  A `foreach` whose loop list is
> DOTTED is typed by walking the WRITTEN path from its base object, and the
> base is resolved the way `ExprEval::getObject` resolves it — **an enclosing
> `foreach`'s loop variable included**.  Of the objects that can stand there,
> only a **`class_var`** lets the walk reach the member: every other loop-variable
> kind — `bit_var`, `int_var`, `string_var`, `enum_var`, `struct_var`,
> `real_var`, `array_var` — leaves `indexTypespec` null and gives EVERY loop
> variable of the inner list Surelog's bare `int_var` + `int_typespec`,
> whatever the drilled member's own type is.

**VERIFIER AMENDMENT (r10v137).**  `struct_var` does NOT belong in that list.
`ExprEval::hierarchicalSelector`'s FIRST `variables` arm is `uhdmstruct_var`
(`ExprEval.cpp:2331-2355`): it searches the base's `struct_typespec`
`Members()` for the element name and RECURSES on a non-last element, and at
level 0 it looks for the base's OWN name — not a member of its own struct — so
it falls through to the same `level == 0` re-entry the `class_var` arm gets.
A `struct_var` base therefore DRILLS.  The table below reads `int_var` for the
`plate137_s` row only because `wells137` is declared in class `Ingot137` and in
no struct, so that cell fails for a reason the base KIND did not cause.  The
shipped predicate is narrowed to `!= class_var && != struct_var` — see
`tools/probe/r10v137repro/README.md` §2 and `v137_a_structbase.sv`, where the
raw test moved a `bit_var` golden cell to `int_var` in both views.

Probe-verified on `g137_b_kinds.sv`, one dotted loop list under thirteen bases,
in BOTH views (identical tables):

| the enclosing `foreach`'s array (its loop variable is the dotted base) | golden's base kind | golden's INNER loop variable |
|---|---|---|
| `ref bit  f[Ingot137]` | `bit_var` | **`int_var`** |
| `ref int  f[Ingot137]` | `int_var` | **`int_var`** |
| `ref string f[Ingot137]` | `string_var` | **`int_var`** |
| `ref Ingot137 f[Ingot137]` | `class_var` | `class_var` (the member's own answer) |
| `ref grade137_e f[Ingot137]` | `enum_var` | **`int_var`** |
| `ref plate137_s f[Ingot137]` (packed struct) | `struct_var` | **`int_var`** |
| `ref real f[Ingot137]` | `real_var` | **`int_var`** |
| a `class_var` base, STRING-keyed member | `class_var` | `string_var` |
| a `bit_var` base, STRING-keyed member | `bit_var` | **`int_var`** |

and on `g137_a_base.sv`, the same dotted member under nineteen BASES: a
subroutine local handle, a formal handle, a class property, a STATIC class
property, a package-level handle, a `this.`-rooted property and a loop variable
over a LOCAL class-keyed associative array all resolve (golden `class_var`,
`string_var`, `int_var`, `array_var` by the member) — **exactly one cell of that
arm disagreed with us, and it is the corpus's shape**: the base is the loop
variable of a foreach over a FORMAL class-keyed associative array whose element
is `bit`, so golden's base is a `bit_var` and the answer is `int_var`.

### The gate, and why it is a HOME list rather than a raw kind test

The predicate needs GOLDEN's base kind, and our own loop-variable typing agrees
with golden's only in the homes where Surelog also drills to the ELEMENT.
Measured, cell by cell:

| the enclosing array's home | golden's loop variable | ours |
|---|---|---|
| subroutine FORMAL | the ELEMENT | the ELEMENT ✔ |
| MODULE-level variable | the ELEMENT | the ELEMENT ✔ |
| INTERFACE-level variable | the ELEMENT | the ELEMENT ✔ |
| subroutine local / class property (resolving) | the INDEX | the INDEX ✔ |
| PACKAGE-level variable | the INDEX | the element ✘ (arm B `zf zh zj zn zp zr`) |
| PROGRAM-level variable | the INDEX | the element ✘ (arm C `hp`) |
| GENERATE-BLOCK variable | the INDEX | the element ✘ (arm D `e1`) |
| statement-block AUTOMATIC local | `array_var` | the element ✘ (arm C `ht hv g6 g8`) |

The last four rows are pre-existing residues of § `foreachAssocIdxLocalOnly20`,
not of this law — and on every one of them golden's base IS a `class_var`, so a
raw "our base is not a `class_var`" test would have moved four correct cells
OFF golden.  The shipped gate therefore admits only the three ✔ homes (plus a
base this law itself minted, so the rule cascades through a chain of dotted
foreaches — arm D `dl`→`dm`).  **An unlisted home can only cost this law a
cell; it can never move one.**

---

## 2. What shipped

`src/StmtEmit.cpp`, the `StatementKind::ForeachLoop` arm, plus one `std::set`
member in `include/UhdmExporter.h`:

* `dotBase137` — the base segment of the written loop list, read off
  `Path_elems()->at(0)->VpiName()` of the `hier_path` the arm has just built,
  so it is the same string `ExprEval::getObject` is handed, by construction;
* `elemDrilledHome137` — the three ELEMENT-DRILL homes above;
* `foreachElemDrilledLV137` — the names of the open loop variables whose kind
  provably equals golden's, maintained beside `openForeachVars` and erased with
  it;
* in `declLoopVar`, before every resolved arm (each of which is `!lv`-guarded,
  exactly as Surelog skips `getSimpleVarFromTypespec` when `indexTypespec` is
  null): if the dotted base is such a name and is not a `class_var`, set
  `lv`/`lts` to the `int_var` + bare `int_typespec` pair.

The unresolved arms are untouched and still come first (a name that already
resolves in the enclosing scope, a nested foreach re-listing an open variable,
and the `classMethodNoBind || pkgDefViewBody9 || pkgImportCloneEmit` copies
that golden never runs `lateTypedefBinding` over) — which is why the DEF-view
listings of every corpus cell are byte-identical.

---

## 3. The corpus census (question 3, over all 956 + 1358 databases)

`pred137.cpp` + `predsweep137.sh` enumerate, from a PRISTINE database alone,
every `foreach_stmt` whose `Variable()` is a `hier_path` whose first path
element names a loop variable of an ENCLOSING `foreach_stmt` — literally
`ExprEval::getObject`'s walk — and report the ones whose kind is not
`class_var`.  Over the whole surelog corpus (**956 databases, 0 census
failures**) exactly **nine** rows qualify, and the whole population is FOUR
written sites in one file:

```
uvm_phase.svh:1678   p.m_predecessors[next_p]       base `p`     ref_var only
uvm_phase.svh:1707   s.m_successors[next_s]         base `s`     ref_var only
uvm_phase.svh:1740   pred.m_predecessors[next_pred] base `pred`  bit_var  <- THE LAW
                                                    (+ ref_var copies)
BuildUVMPkg's pp_output spells the same three at 34558 / 34587 / 34620.
```

The `ref_var` cells are the DEF-view / class-method listings, where golden's
loop variable is an unresolved `ref_var` too and neither producer resolves
anything; `:1678` and `:1707` iterate a subroutine-LOCAL `bit …[uvm_phase]`, so
their resolved base IS a `class_var` and both sides already agreed.  Only
`:1740` iterates a FORMAL (`output bit pred_of_succ[uvm_phase]`), and that is
the single resolvable candidate per database.  **uhdm2rtlil has zero: 1358
databases, `CAN-MOVE=0`.**

`ct137cen.cpp` (uvm134's census, unchanged but for its name) + `score137.py`
then join golden / pristine / patched as a MULTISET on the id-free key
`HOME|PATH|SPAN|NLV|LVNAMES` and score `VKIND VNAME VTS VTSNAME LVKINDS LVTS`
(all read by `Compare`) plus `VFULL`/`VSPAN` (dump-only).  Driver:
`uvmcen137.sh`, golden path read from each row's OWN `cmds.txt`, every rc
recorded.  The key **calibrates clean on all nine databases**: `ONLY-GOLDEN 0`,
`ONLY-OURS 0`, `AWAY 0` in every column.

| row | mode | foreach cells | LVKINDS W→R | **RIGHT→WRONG** | LVKINDS still wrong |
|---|---|---|---|---|---|
| SeqDriver | default / testflags | 1345 | 1 / 1 | **0 / 0** | 0 |
| SimpleUVM | default / testflags | 737 | 1 / 1 | **0 / 0** | 0 |
| Scoreboard | default | 739 | 1 | **0** | 0 |
| MiniAmiq | default / testflags | 1458 | 1 / 1 | **0 / 0** | 19 |
| BuildUVMPkg | default / testflags | 773 | 1 / 1 | **0 / 0** | 0 |
| **total** | | **9365** | **9** | **0** | |

Every other scored column is `RIGHT->RIGHT` on every row except the
pre-existing `VTS`/`VTSNAME`/`VSPAN` residues, which are IDENTICAL in pristine
and patched.  MiniAmiq's 19 remaining `LVKINDS` cells are its
`svaunit_vpi_interface` interface-homed foreaches (buvm34's R1) — untouched.

---

## 4. Grids — 5 arms x {DEF, ELAB}, 832 foreach cells

`arms137.sh` runs every `g137_*.sv` under Surelog (golden), the pristine and
the patched binary in both views and scores with `ct137cen` + `score137.py`
(each arm in its OWN subdirectory keyed on its relative path; file list on
fd 3; children `</dev/null`; `PROCESSED` asserted; every rc recorded).

| arm | what it varies | view | cells | LVKINDS W→R | **R→W** |
|---|---|---|---|---|---|
| `g137_a_base` | 19 BASES of one dotted member (local / formal / class property / static property / package handle / `this.`-rooted / loop variable over a local vs a formal assoc) x 5 member types | def / elab | 52 / 104 | 1 / 2 | **0 / 0** |
| `g137_b_kinds` | the base loop variable's KIND: 7 element types x {formal, package-level, class property, subroutine local} outer arrays, string- and class-keyed members | def / elab | 82 / 164 | 9 / 18 | **0 / 0** |
| `g137_c_homes` | 12 HOMES: in-body / out-of-body / static class method, package function, package task, interface function, program initial, module initial, module task, always, fork…join_none, block-local automatics | def / elab | 56 / 104 | 6 / 11 | **0 / 0** |
| `g137_d_shapes` | interface- / program- / generate-block / module-level and static-property outer arrays; dotted DEPTH 3; arity `[i,j]`, `[,j]`, `[i,]`; the base nested one deeper; the same text three times | def / elab | 60 / 136 | 10 / 19 | **0 / 0** |
| `g137_e_mult` | 1, 2 and 3 instances of one parameterised module + a package class used from each | def / elab | 16 / 58 | 2 / 9 | **0 / 0** |
| **total** | | | **832** | **87** | **0** |

`ONLY-GOLDEN`, `ONLY-OURS` and `AWAY` are **0 in every column of every
arm-view** except `g137_d_shapes`, whose leading/trailing skipped slots
(`[,j]` / `[i,]`) are buvm34's recorded R2 shape residue and whose ELAB view
lists a package body a different number of times — both are IDENTICAL in
pristine and patched, so `AWAY` is still 0.  **`RIGHT->WRONG` is 0 in every
column of every arm-view.**

Names are deliberately unalike across arms (`Nugget137`/`Quarry137`,
`Ingot137`/`Smithy137`, `Bale137`/`Loom137`, `Shard137`/`Vessel137`/`Depot137`,
`Rivet137`/`Press137`; index names `u1..uq`, `z1..zz`, `h1..hz`, `d1..e2`,
`m1..ma`) — a grid that calls everything `a_t`/`b_t`/`c_t` over `A`/`B`/`C` is
self-confirming.

---

## 5. Boundary — 982 files x both views

`bound137.sh` compiles every `.sv`/`.svh` under every probe tree that contains
a `foreach`, plus the whole of the brief's must-stay trees (`r10uvm77-79`,
`r10uvm82-91`, `r10uvm113`, `r10uvm122`, `r10uvm131`, `r10uvm134`,
`r10buvm3-15`, `r10buvm33/34`, `r10sd8-12`), from a COPY of the tree, with the
pristine and the patched binary, and diffs the two uhdm-dumps whole
(workdir-normalised).  A file whose dump moved must be attributable on TWO
independent counts: its `ct137cen` census must have moved too, AND its SOURCE
must contain the law's syntactic predicate (a `.` written inside a `foreach`
loop list before the index select).

```
LISTED=982 PROCESSED=982 MOVED=10 BREACH=0 RC-MISMATCH=0 NORUN=24
PROCESSED-ASSERT-OK
BOUNDARY PASS
```

The ten moved file-views are the five `g137_*.sv` arms of THIS pass, in both
views.  **No foreign arm moved**: every `buvm33`/`buvm34` foreach cell, every
`uvm84/85` `this.`/`super.` cell, every `uvm89`/`buvm14` `hier_path` cell,
every `uvm134` loop-list cell and every `sd8-12` arm is byte-identical.
`NORUN=24` are arm-views that produce no database on EITHER binary (equal rc,
recorded — several are pre-existing segfaults that crash both binaries
identically).  Positive control `CTRL=1` over this pass's own arm directory:
`MOVED=10`, `POSITIVE-CONTROL-OK`.  See `BOUNDARY.txt`.

The four slang-fenced tests are never dispatched and never spelled here;
`canaudit.sh canaries.sh ctcan2.sh` run from this directory reports
`audited=29 UNCOVERED=0 FENCE-BREACH=0`.

---

## 6. Gates (all green, on this worktree's OWN pinned build and workdirs)

1. **build** both binaries `-j 2`, md5 taken separately, both frozen
   `chmod 555` at immutable paths before any sweep.  Every `cmds.txt` audited
   BY BINARY PATH (not by the string `slang-uhdm`, which also matches the
   golden cache): of 1573 surelog `cmds.txt` **1523 name the frozen binary and
   50 name none at all** (golden-cache-only cells), and of 1462 uhdm2rtlil
   `cmds.txt` **1458 name it** — in BOTH sweeps.  **Zero cells name the
   main-tree binary or this worktree's `build/slang-uhdm`, in either corpus, in
   either sweep.**
2. **goldens** `SLANG_UHDM` exported explicitly to EACH binary: patched
   **23 PASS / 0 FAIL**, pristine **23 PASS / 0 FAIL**; negative control
   `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**.
3. **uhdm2rtlil**, testflags AND default: **679 CMP_EQUAL / 50 SLANG_REJECT /
   2 SURELOG_FAIL** in both modes (status histogram read — a rc=139 segfault
   would surface as SLANG_REJECT); `ct8rows.sh` **0 differing rows** against
   the committed `results/gate_uhdm2rtlil.csv` AND against this build's own
   pristine sweep, in both modes, status AND dump column;
   `byteverify.sh SELFCHECK=1` **MOVERS 0 / 1358** (SELFCHECK 1357/1358).
4. **surelog `--mode both`**, 1588 rows: **937 CMP_EQUAL / 567 SLANG_REJECT /
   48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE /
   2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM** — identical to pristine;
   `ct8rows.sh` **0 differing rows over 1588** against the committed
   `results/golden_surelog.csv` and against the pristine sweep.  **NO ROW IS
   CONVERTED** (MiniAmiq stays CMP_NOTEQUAL at a new, unrelated head) and
   `results/*.csv` is untouched.
5. **byteverify.sh SELFCHECK=1** on surelog: **MOVERS 9 / 956**, SELFCHECK
   955/956 — precisely the nine names `PREDICTION.txt` named a priori from the
   PRISTINE databases, and no others.

Canaries: `canaries.sh` `ok=52 changed=0 absent=0` (surelog) and
`ok=8 changed=0 absent=0` (u2r); `EXPECT_UNKNOWN=1` / `EXPECT_UNKNOWN=6`
`ctcan2.sh` PASS on both corpora; `canaudit.sh` PASS.  Protected databases by
name, md5 vs the pristine sweep, BOTH modes: InterfaceModPort,
BlackParrotComplex, YosysOldOr **SAME**; SVSwitch `4842211c4030`; YosysVerx
`6ccda350c24a`.

**Mover attribution, ORDER-BLIND** (`movers137.sh`: both dumps id- and
workdir-normalised and `LC_ALL=C sort`ed — the only sound attribution for
Scoreboard/default and SeqDriver, which are ~50/50 coins):

| database | mode | order-blind differing lines | unattributed |
|---|---|---|---|
| BuildUVMPkg | default / testflags | 13 / 13 | 0 |
| MiniAmiq | default / testflags | 13 / 13 | 0 |
| Scoreboard | default | 13 | 0 |
| SeqDriver | default / testflags | 13 / 13 | 0 |
| SimpleUVM | default / testflags | 13 / 13 | 0 |
| **total** | | **117** | **0** |

All 117 lines are the law's own object: `class_var 'next_pred'` → `int_var`
(the variable is dumped three times — under `vpiLoopVars`, as its
`ref_typespec`'s `vpiParent`, and at the body reference that binds it),
`class_typespec 'uvm_phase'` → `int_typespec`, and the three lines the dump
prints INSIDE the departing `class_typespec` (its `class_defn` back-pointer,
`|vpiClassDefn:` and `|vpiName:uvm_phase`).

---

## 7. Residues and R0

* **R0 (the next head).**  MiniAmiq x2, 58 cmp lines, ONE `^LHS:` —
  `string_var 'values'` at `uvm_component.svh:3380`
  (`uvm_component::m_set_cl_verb`'s subroutine-local `string values[$]`).  The
  two decompiles are line-for-line identical except that OURS carries
  `|vpiAutomatic:1` and golden's carries no `vpiAutomatic` at all.  Both modes
  produce a byte-identical cmp log.  Source-first this is Surelog's
  `vpiAutomatic` policy for a subroutine local inside a class method (the flag
  is set from the enclosing subroutine's lifetime; a class method's body is
  automatic by LRM but Surelog does not stamp its locals), against ours, which
  stamps every automatic local.  See `head_pat_default_MiniAmiq.cmp`.
* **R1 — the INDEX rule is wider in golden than § `foreachAssocIdxLocalOnly20`
  models it.**  A BARE foreach over a class-keyed associative array takes the
  INDEX (golden `class_var`) not only for a subroutine local and a resolving
  class property but also for a **PACKAGE-level**, a **PROGRAM-level** and a
  **GENERATE-BLOCK** variable — 6 + 1 + 1 = 8 measured cells (`g137_b_kinds`
  `zf zh zj zn zp zr`, `g137_c_homes` `hp`, `g137_d_shapes` `e1`), identical in
  pristine and patched.  A **statement-block AUTOMATIC** local is a fourth
  shape: golden answers `array_var` over the whole `array_typespec` and never
  recurses (`g137_c_homes` `ht hv g6 g8`).  This law deliberately refuses to
  fire on any of them, because on all four golden's base IS a `class_var` and
  firing would move four correct inner cells OFF golden.  Corpus incidence of
  the dotted half: **zero** (`pred137` finds no such base in 956 + 1358
  databases).
* **R2 — the four block-local cells this law therefore MISSES.**
  `g137_c_homes` `hu hw g7 g9`: golden's inner loop variable is `int_var` (its
  base is an `array_var`) and ours stays `class_var`.  They are unchanged by
  this pass, they are the SAME four foreaches as R1's `array_var` bases, and
  they will fall out of R1 the moment the outer rule is corrected.
* **R3 — the leading / trailing skipped-slot SHAPE**, buvm34's recorded R2:
  `foreach (a[,j])` is TWO entries in golden (an EMPTY-NAMED `ref_var` at the
  comma, then `j`) and `foreach (a[i,])` is ONE, while we emit a `vpiNullOp`
  for every skipped dimension.  `g137_d_shapes` measures both spellings on the
  dotted face; pristine and patched are IDENTICAL on each.  Corpus incidence
  of a leading/trailing skip: zero.
* **R4 — MiniAmiq's 19 interface-homed `LVKINDS` cells** (buvm34's R1: an
  `svaunit_vpi_interface` foreach whose home golden never elaborates).  Bare
  spellings, outside this law's face, untouched.
