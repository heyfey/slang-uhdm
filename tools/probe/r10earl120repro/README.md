# r10earl120 — § `paPaCopyTsInstance120` — **THE HOME INSTANCE TRAVELS WITH THE COPY: SURELOG ANSWERS A BARE PARAMETER READ WITH `clone_tree(param_ass->Rhs())`, AND `typespec::DeepCopy` COPIES THE SOURCE TYPESPEC'S `vpiInstance` VERBATIM — SO THE SUBSTITUTED CONSTANT'S TYPESPEC IS INSTANCED AT THE PACKAGE THAT DECLARED THE PARAMETER** — the Earlgrey_0_1 **default** head `LHS: package top_pkg` / `RHS: <null>` CLEARED (833 → 386 cmp lines, and the head OBJECT is gone), on the exact next head r10earl119's R0 named

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY**, **nothing was promoted** and **NO CORPUS ROW
CONVERTED** in either direction — `BuildUVMPkg` (both modes),
`Earlgrey_0_1/testflags` and `Rggen/default` are all quoted below still
`CMP_EQUAL` with 0 cmp lines.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list, which `widerun120.sh` reads so the boundary
filter cannot drift from the audit.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `af2e5142` |
| pristine binary | md5 `0ec8f36d288c2d3a98fc17681473d4ff`, built from this pass's OWN worktree at a clean `af2e5142` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary (SHIPPED) | md5 `926a8a5e290bbd464e28a34d7fd08fd4`, frozen `chmod 555`.  **REPRODUCED**: the pass's patch applied to a FRESH `af2e5142` worktree and rebuilt there gives the SAME md5 — the patch IS the artifact every number below was measured on |
| the head | **Earlgrey_0_1/default, 833 cmp lines, ONE head → 386 cmp lines, ONE head, and the head OBJECT IS GONE.**  Before: `LHS: package top_pkg` (`top_pkg.sv:6:1`) / `RHS: <null>` — r10earl119's R0.  After: a DIFFERENT object, `LHS: tagged_pattern @tlul_socket_m1.sv:109:19` / `RHS: hier_path(tl_h_i[0].a_valid)`, which the PRISTINE owner-finder already named when it masked the whole owner pool.  Counts are DEPTH, not distance (RESUME.md §7) |
| production surface | `src/ExprEmit.cpp` — **one file, +31 lines, of which TWO are code**.  Nothing was edited or removed |

---

## 1. THE OWNER, NAMED BEFORE ANY CODE — `own120`

`BaseClass::SafeCompare(lhs, rhs, ctx)` with `rhs == nullptr`
(`~/.local/include/uhdm/BaseClass.h:187-193`) sets ONLY `m_failedLhs`, and sets
it to the **POINTEE**.  So `LHS: package top_pkg` / `RHS: <null>` names the
TARGET of a golden edge and HIDES the owner.  r10earl119's `r0next119` had
already ruled out the two obvious owners — both `design::AllPackages` and
`design::TopPackages` are 40 entries on both sides with no nulls and identical
pairing, and the isolated `top_pkg` pair `Compare`s to **0** with every
container equal.  So the edge is a SINGULAR relation elsewhere in the design.

`own120.cpp` answers it two independent ways that must agree.

**(A) THE FIELD SCAN.**  Every generated `<kind>::Compare`
(`~/git-repos/UHDM/build/generated/src/*.cpp`) was read and every SINGULAR
`SafeCompare(lhs->F(), rhs->F(), …)` whose declared type can hold a `package`
enumerated — `instance::Instance`, `typespec::Instance`, `variables::Instance`,
`variables::Scope`, `ports::Instance`, `task_func::Instance`,
`clocking_block::Instance`, `clocking_block::Actual`, `tf_call::Scope`,
`ref_obj`/`ref_var`/`ref_module`/`chandle_var::Actual_group`,
`gen_scope_array::VpiInstance`, `import_typespec::Item`.  On the pristine pair
(`OWNER_BEFORE.r10earl120.txt`) exactly ONE of them holds the edge:

```
== (A) FIELD SCAN — GOLDEN objects holding a compared singular edge to package(top_pkg)#1
   typespec::Instance  owner=int_typespec                  174
   POOL total = 174
```

**(B) MASK-AND-RERUN.**  Every generated `Compare` opens with
`if (!context->m_visited.insert(this).second) return r;` (LHS-keyed), so seeding
a golden object into a FRESH `CompareContext`'s `m_visited` makes its whole
`Compare` return 0.  Masking the whole pool MOVES the head — to
`LHS: tagged_pattern @tlul_socket_m1.sv:109:19-109:36` — so the owner is in the
pool.  Bisecting stops with a residual set of 3 rather than one object, and the
reason is itself a measurement: **every owner of this family produces the SAME
head** (`m_failedLhs` is the package, `m_failedRhs` is null), so masking one
owner merely uncovers the next.  The three the walk actually reaches are all the
same shape:

```
REACHED[0] int_typespec()@top_pkg.sv:10:12-10:15#793425   via typespec::Instance
     < ref_typespec()#793424 < constant()@tlul_socket_m1.sv:97:30-97:33#793423
     < operation()@97:30-97:39 < indexed_part_select(a_source)@97:17-97:40
     < hier_path(tl_h_i[i].a_source[0+:8 - 2])@97:7-97:41 < operation()@96:25-99:6
     < cont_assign()@96:12-99:6 < gen_scope()@89:36-139:6
     < gen_scope_array(gen_host_fifo[0]) < module_inst(u_sm1_17) < module_inst(u_xbar_main)
```

`tlul_socket_m1.sv:72` is `localparam int unsigned IDW = top_pkg::TL_AIW;` and
`:73` is `localparam int unsigned STIDW = $clog2(M);`.  Line 97 reads
`tl_h_i[i].a_source[0+:(IDW-STIDW)]`.  So **the owner is the typespec of the
SUBSTITUTED CONSTANT that stands for a parameter read**, and the two operands of
that one subtraction are the axis and its fence:

| operand | golden's constant's typespec | `Instance` |
|---|---|---|
| `IDW` (declared from a PACKAGE parameter) | `int_typespec@top_pkg.sv:10:12` | **`package top_pkg`** |
| `STIDW` (a MODULE localparam) | `int_typespec@tlul_socket_m1.sv:73:14` | **`<null>`** |

---

## 2. THE DECODE — SURELOG'S SOURCE AND UHDM'S, READ, NOT INFERRED

`CompileHelper::compileExpression` answers a simple identifier that matches a
`param_assign` on the enclosing `DesignComponent`
(`Surelog/src/DesignCompile/CompileExpression.cpp:2918-2975`), when
`reduce == Reduce::Yes` and `substituteAssignedValue` agrees, with

```cpp
result = UHDM::clone_tree(param_ass->Rhs(), …);
result->VpiParent(param_ass);
fC->populateCoreMembers(child, child, result);
```

— a CLONE of the parameter's own Rhs, re-parented at the `param_assign` and
re-anchored at the READ's span.  r10earl105 decoded that far and reproduced the
clone's VALUE, ENCODING and TYPESPEC SPAN by minting the typespec field by
field.  The field it did not carry is the one this pass adds, and UHDM's own
generated code says why it must be carried:

```cpp
// ~/git-repos/UHDM/build/generated/src/typespec.cpp:72-79
void typespec::DeepCopy(typespec* clone, BaseClass* parent, CloneContext* context) const {
  basetype_t::DeepCopy(clone, parent, context);
  if (auto obj = Typedef_alias()) clone->Typedef_alias(obj->DeepClone(clone, context));
  if (auto obj = Instance()) clone->Instance((instance*) obj);      // <== HERE
  if (instance* inst = any_cast<instance*>(parent)) clone->Instance(inst);
}
```

A clone copies `Instance()` from the SOURCE, and the parent-derived override
below it never fires here because the parent of a substituted constant's
typespec is a `ref_typespec`, not an `instance`.  The SOURCE is the parameter's
own elaborated `param_assign` Rhs typespec, and that object's home is the
package that declared the parameter (Surelog's package writer:
`UhdmWriter::writePackage`'s `tp->Instance(p)` at `UhdmWriter.cpp:1192`, and
`ReInstanceTypespec` at `:1109-1176`, whose comment is *"Non-elaborated package
typespec Instance relation need to point to non-elaborated package"*).

`typespec::Compare` (`typespec.cpp:96`) reads `Instance()`.  So the copy that
did not carry it read as `LHS: <the package> / RHS: <null>`.

**AN OPS FACT THAT COST AN HOUR AND IS WORTH RECORDING.**  There are TWO
`surelog` binaries on this machine.  `scripts/verify_golden.py` uses
`~/git-repos/Surelog/build/bin/surelog` (`SURELOG_ROOT` at
`verify_golden.py:49`); the shell's `surelog` alias points at
`~/git-repos/sv-tests/third_party/tools/Surelog/build/bin/surelog`, a DIFFERENT
build.  The alias's build **does not stamp this edge at all** and its databases
**segfault `uhdm-dump` and `uhdm-cmp`** on real Earlgrey sources (reduced: a
file holding only a package).  Four arms built with it read as "golden does not
do this", which is false.  **Always spell the harness path.**

---

## 3. WHAT WAS BUILT

`src/ExprEmit.cpp`, inside § `genCaTopLoopParamPaCopy105`'s eager typespec copy,
right after the fields that copy already carries (`VpiFile`, line/col span,
`VpiSigned`, `VpiValue`):

```cpp
if (auto* si5 = sits5->Instance())
    its5->Instance((UHDM::instance*)si5);
```

Two lines, inside a window this pass does not touch.  It is a **COPY, NOT A
LOOKUP**, and that is the whole fence:

* a source typespec with no home copies the NULL, so **an edge golden leaves
  null STAYS null** — no `MOVED-WRONG` is reachable in the null direction;
* it cannot fire where r10earl105's window does not already fire (the same
  `outerParam9 && (inPsBound || pa9 || caLoopSelPos21 || loopPlainNew105)` gate,
  the same `int_typespec`-source fence, the same `baseSpellingOk105` encoding
  fence);
* it adds no object, no branch and no evaluator call, so a cell the law declines
  is byte-identical — proved by arm `a2_fence120`, whose whole database dump md5
  is **identical between the two binaries**.

---

## 4. THE GRID — 2 ARMS × GOLDEN + BOTH BINARIES, EVERY CELL SCORED

`GRID.r10earl120.txt` holds the full table; `cen120` scores each cell on the
JUDGE-VISIBLE payload (the package the edge NAMES — see §6 for why the vector
role is separate).

`a1_axis120.sv` — the axis.  A package, a module with a package-origin
localparam and four fence-origin ones, a gen-for, and TWO instances of that
module with different parameters:

| row | origin of the read parameter | golden | pristine | patched |
|---|---|---|---|---|
| `46:33` `IDW` in `a[0 +: (IDW-STIDW)]` | PACKAGE localparam | `package:p120_pkg` | `<null>` | **`package:p120_pkg`** |
| `46:39` `STIDW` in the same expression | module localparam | `<null>` | `<null>` | `<null>` |
| `51:25` `IDW` in `a[IDW-1 -: 2]` (DOWN select) | PACKAGE localparam | `package:p120_pkg` | `<null>` | **`package:p120_pkg`** |
| `57:28` `MODW` (← a module PARAMETER) | module parameter | `<null>` | `<null>` | `<null>` |
| `57:35` `IMPW` (← an IMPLICITLY typed package localparam) | package, untyped | `<null>` | `<null>` | `<null>` |

and every one of those five rows repeats identically in BOTH instances (`u_a`
4 gen iterations, `u_b` 2).  Totals for the arm: **TO-GOLDEN 4 keys / 12 cells,
SAME_AGREE 6 keys / 18 cells, AWAY-GOLDEN 0, MOVED-WRONG 0**, plus the two
golden-only `<nohome>` keys of residue R3 (STILL-WRONG on both binaries), and the arm's official
`uhdm-cmp` verdict goes **385 cmp lines (head `LHS: package p120_pkg` /
`RHS: <null>` — the corpus head's own shape, in 70 lines of SystemVerilog) → 0
lines, CMP_EQUAL**.

The implicitly typed package localparam is the row worth naming: golden's
typespec for it spans the WHOLE declaration (`22:1-22:23`) and carries **no**
`Instance`, so the copy carries none either — the law is a copy, and the copy is
right for the reason the decode gives, not by a rule about packages.

`a2_fence120.sv` — the arm that must move NOTHING: a module localparam, a module
parameter, a genvar, a gen-scope-local localparam, a DEF-listing module-body
read, and a STRUCT-typed package parameter whose elaborated Rhs is not a
constant at all.  **Its dump md5 is identical between the two binaries**
(`de324218abd2f5bbd6a4c7f60f8c3b4a`), and its `uhdm-cmp` line count is 72 on
both.

---

## 5. THE CORPUS — PREDICTION FIRST, THEN THE CENSUS, THEN THE BYTES

`cen120` walks `Serializer::AllObjects` for every typespec whose parent is a
`ref_typespec` whose parent is a `constant` — the substituted-constant typespec
— and keys it
`home-instance-fullname | constant-span | ts-kind | ts-span | signed`, with the
file deliberately OUT of the key (our objects carry an EMPTY `VpiFile`,
RESUME.md §9).  It also emits a `SRC` row per package parameter's own
declaration typespec, which is what makes the prediction possible from the
PRISTINE database alone.

**CALIBRATION FIRST** (`score120.py` refuses to score otherwise): the GOLDEN
halves of the two sweeps are IDENTICAL — surelog 105 741 keys / 247 056 cells,
uhdm2rtlil 734 keys / 1 138 cells.

**THE PREDICTION, made from the PRISTINE databases alone** (`predict120.py`) —
a cell moves exactly when it is instance-less AND the source typespec it was
copied from carries an instance:

```
surelog     PREDICT-MOVE rows=2 cells=116
              default    Earlgrey_0_1   26 keys 58 cells
              testflags  Earlgrey_0_1   26 keys 58 cells
            PREDICT-DECLINE rows=94 cells=4772
uhdm2rtlil  PREDICT-MOVE rows=0 cells=0
            PREDICT-DECLINE rows=102 cells=302
```

**THE CENSUS** (`CENSUS_sl.txt` / `CENSUS_u2r.txt`), three-way multiset join:

```
surelog   FX TO-GOLDEN     52 keys    116 cells
          FX AWAY-GOLDEN    0 · FX MOVED-WRONG 0 · NOGOLD_MOVED 0
          FX SAME_AGREE  2960 keys · FX STILL-WRONG 30421 keys (residue R2)
          REST (the all-null fence population) SAME_AGREE 576 · STILL-WRONG 71732 · 0 MOVED
          MOVER ROWS: default Earlgrey_0_1 {'FX TO-GOLDEN': 26}
                      testflags Earlgrey_0_1 {'FX TO-GOLDEN': 26}
uhdm2rtlil DETAIL_TOTAL 0 — not one cell moved, in either mode
```

**THE BYTE MOVERS**: `byteverify.sh SELFCHECK=1` reports **2 / 956** on the
surelog corpus — `./default/Earlgrey_0_1-71da2fd7/slang.uhdm` and
`./testflags/Earlgrey_0_1-71da2fd7/slang.uhdm` — and **0 / 1358** on
uhdm2rtlil.  Exactly the predicted set, by name, in both corpora.  Both Earlgrey
modes were expected: the law lives in `emitExpr` and is not view-gated, and the
`testflags` row was `CMP_EQUAL` with 0 cmp lines before and **is `CMP_EQUAL`
with 0 cmp lines after** — the database moved TOWARD golden inside a row that
was already equal.

**THE ATTRIBUTION, line by line** (`attrib120.sh`: both dumps path-normalised,
diffed BOTH raw and ORDER-BLIND, then SECTIONED at `|uhdmtopModules:` so the
weaklyReferenced tail is never counted).  On `Earlgrey_0_1/default`
(`ATTRIB_Earlgrey_default.txt`):

```
RAW (order-sensitive) diff        174 lines
ORDER-BLIND (sorted) diff         118 lines
ORDER-BLIND diff BY SECTION       116 > sec=10        (the ELAB listing; DEF and the TAIL: 0)
CHANGED LINE SHAPES, ADDED side    58 |vpiInstance:
                                   58 \_package: top_pkg …top_pkg.sv, line:6:1, endln:20:11
CHANGED LINE SHAPES, REMOVED side  (none)
```

Fifty-eight cells, two dump lines each, all ADDITIONS, all in the judge-reachable
elaborated section, all naming the one package — and 58 is the number
`predict120.py` printed for that row before the patched database existed.

The `testflags` mover is the same law in the same design and is attributed the
same two ways *without* a whole-dump diff, which on that database is a
half-gigabyte `uhdm-dump` per side: the CENSUS gives it cell for cell
(`FX TO-GOLDEN 26 keys / 58 cells`, `AWAY-GOLDEN 0`, `MOVED-WRONG 0`,
`NOGOLD_MOVED 0`, and REST unmoved), and the JUDGE gives the verdict
(`uhdm-cmp` rc 0, **0 cmp lines before and 0 after**).  `attrib120.sh` is
carried here and takes that pair as its arguments for anyone who wants the
line-level view of it too.

---

## 6. THE ONE RESIDUE INSIDE THE LAW — THE VECTOR ROLE, MEASURED AND NOT HIDDEN

A design lists each package TWICE: `design::AllPackages` (the definition) and
`design::TopPackages` (the elaborated instance).  On all 52 moved keys **golden
names the `TopPackages` copy and we name the `AllPackages` copy**
(`pkgobj120`: golden's `top_pkg` id 1 = `TopPackages[1]` carries 174
`typespec::Instance` edges, id 214 = `AllPackages[1]` carries 11; ours after the
patch is 82 on `AllPackages[1]`, 78 on `TopPackages[1]`).  That is scored, out
loud, on its own census pass:

```
ROLECELL  FX MOVED-WRONG 52 keys / 116 cells      (the role)
CELL      FX TO-GOLDEN   52 keys / 116 cells      (the package the edge names)
```

It is **not** an acceptance failure, and the reason is a fact about the judge,
not a preference: no generated `Compare` reads which vector listed an object.
`typespec::Compare` follows `Instance()` into `package::Compare`, and by then
both package objects are already in `m_visited` from `design::Compare`'s own
`AllPackages`/`TopPackages` legs, which r10earl119's `r0next119` measured as 40
entries each, no nulls, identical pairing, the `top_pkg` pair comparing 0.  The
independent confirmation is the judge itself: arm `a1_axis120` goes to **0 cmp
lines** with the role "wrong", and the corpus head clears.

The role divergence is inherited, not introduced: our SOURCE typespec (the
parameter's own elaborated `param_assign` Rhs typespec) already names
`AllPackages[1]` where golden's names `TopPackages[1]`, and a copy copies.
Fixing it belongs to whatever law owns that source object, not here — R1 below.

---

## 7. THE GATES — ALL GREEN, AND NO ROW CONVERTED

Full transcript in `GATES.r10earl120.txt`.  In one line: goldens 23/0 on BOTH
binaries and 0/23 on `/bin/false`; uhdm2rtlil 679/50/2 in both modes on both
binaries with `ct8rows` PASS three ways and 0/1358 byte movers; surelog 1588
rows with `ct8rows` pristine-vs-patched PASS (0 differing rows, status AND dump)
and 2/956 byte movers, both predicted by name; canaries 51+8 ok, `ctcan2` PASS
twice, `canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0; SVSwitch `4842211c4030`
and YosysVerx `6ccda350c24a` pins hold; InterfaceModPort / BlackParrotComplex /
YosysOldOr byte-identical between the binaries.

`rowheads.sh` on the seven named rows, pristine → patched: SeqDriver 33/33,
SimpleUVM 17/17, Scoreboard/default 95, MiniAmiq 33/33, **BuildUVMPkg 0 and 0**,
**Rggen/default 0**, **Earlgrey_0_1/testflags 0**, and Earlgrey_0_1/default
**833 → 386**, one head throughout.  The four `CMP_EQUAL` row-modes are scored
on both columns and all four stay `CMP_EQUAL` with 0 cmp lines.

**The one row-side that differs from the COMMITTED baseline, quoted in full and
NOT a conversion:**

```
< Earlgrey_0_1,testflags,CMP_EQUAL,,,differ      (results/golden_surelog.csv)
> Earlgrey_0_1,testflags,CMP_EQUAL,,,            (both of THIS pass's sweeps)
```

The STATUS is `CMP_EQUAL` on both sides; only the dump column empties, and it
empties in this pass's PRISTINE sweep too (`ct8rows` pristine-vs-patched is PASS
on that row, and the canary scan reports the same one `CHANGED` line for the
pristine binary).  It is a `uhdm-dump` TIMEOUT under concurrent sweeps — the
identical observation r10earl119 recorded.  Nothing was promoted and
`results/*.csv` was not edited.

---

## 8. THE WIDE BOUNDARY — EVERY COMMITTED ARM

`widerun120.sh` stages a COPY of `tools/probe`, lists every `.sv`/`.v` at ANY
depth, filters the fenced names out of the list BEFORE a child runs (reading the
list out of `canaudit.sh`'s own `FENCED=` line), reads the list on fd 3 with
children `</dev/null`, and asserts PROCESSED == LISTED.

```
LISTED=5242  FENCED_REMOVED=0  (of 5242 found)
PROCESSED=5242 identical=10047 DIFFERING=3 no_output=434
PROCESSED==LISTED (5242)
rc by side:  A/0 9653  A/139 16  A/3 418  A/4 397
             B/0 9653  B/139 16  B/3 418  B/4 397     <-- SYMMETRIC
             (and the 32 rc=139 SIGNAL lines are 16 per side, symmetric)
```

Three arm×view cells differ, and both files were re-measured AGAINST GOLDEN:

* **`plain r10earl120repro/a1_axis120.sv`** — this pass's own axis arm.  §4
  scores it TO-GOLDEN 4 keys / 12 cells, AWAY-GOLDEN 0, MOVED-WRONG 0, and its
  official `uhdm-cmp` verdict goes 385 lines → **0**.  (`a2_fence120` is absent
  from the list: the all-fences arm does not move, in either view.)
* **`plain` and `elab r10earl34repro/a2_shape.sv`** — ONE earlier-pass arm,
  moving in BOTH views because this law lives in `emitExpr` and is not
  view-gated.  Re-measured cell by cell against golden in
  `BOUNDARY_earl34arm.txt`: in EACH view exactly ONE cell moves,
  `90:49-90:56 | int_typespec | 24:14-24:17 | s1`, from `<null>` to
  `package:e34b_pkg` — **which is golden's own value**.  Every other cell of
  that arm is identical on all three sides.  **TO-GOLDEN 1 · AWAY-GOLDEN 0 ·
  MOVED-WRONG 0 per view**; its `uhdm-cmp` line count is unchanged (17 plain,
  16210 elab — its head is elsewhere).

r10earl119's, § 106's and r10earl118's arms are all in the list and none of them
moved.

---

## 9. RESIDUES

* **R0 — THE NEXT HEAD, named and measured.**  `Earlgrey_0_1/default`, now 386
  cmp lines / 1 head: `LHS: tagged_pattern` (`tlul_socket_m1.sv:109:19-109:36`,
  inside the `'{ a_valid: …, a_opcode: … }` assignment pattern at `:108:26`)
  against `RHS: hier_path(tl_h_i[0].a_valid)` — golden keeps a `tagged_pattern`
  wrapper where we emit the bare member expression.  It is PRE-EXISTING and
  merely unmasked: `own120`'s whole-pool mask on the PRISTINE databases already
  named this exact pair.  `HEAD_AFTER_Earlgrey_default.cmp` holds it.
* **R1 — THE VECTOR ROLE OF THE SOURCE TYPESPEC.**  Our package parameter's own
  elaborated `param_assign` Rhs typespec names `AllPackages[…]` where golden's
  names `TopPackages[…]`, and this law copies whatever the source says.  52
  corpus keys and 6 arm keys carry it; the judge does not read it (§6).  The fix
  belongs to whichever law mints that source object.
* **R2 — THE 30 421 `FX STILL-WRONG` KEYS are not this law's.**  They are
  substituted-constant typespecs whose disagreement is a SPAN or a KIND, not the
  instance edge — the population r10earl105's residue R1 (`logic_typespec` /
  `bit_typespec` sources, whose RANGE subtree the mint does not clone) and the
  span families of other passes.  Named here so the number is not mistaken for
  this law's residue.
* **R3 — THE `<nohome>` GOLDEN CELL WE DO NOT HOLD AT ALL.**  In arm
  `a1_axis120` golden carries two extra cells keyed `<nohome>|36:35-36:45` and
  `<nohome>|39:35-39:45` — the `param_assign` Rhs constants of the module's own
  localparams, which our emitter parents differently and which the census
  therefore keys elsewhere.  Scored as `NOGOLD_SAME` on both binaries (238 keys
  corpus-wide, 0 moved); a parenting question, not an instance one.
* **R4 — THE TWO-SURELOG TRAP, recorded so it is paid for once.**  The shell
  alias `surelog` is NOT the harness's Surelog (§2).  Its databases crash
  `uhdm-dump`/`uhdm-cmp` on Earlgrey sources and it does not stamp
  `typespec::Instance` on package parameters at all.  Every arm in this
  directory was built with `~/git-repos/Surelog/build/bin/surelog`, spelled in
  full.

---

## 10. FILES

| file | what it is |
|---|---|
| `own120.cpp` | THE OWNER-FINDER for a `LHS: <package>` / `RHS: <null>` head: the enumerated compared-singular field scan on BOTH databases, plus mask-and-rerun around the OFFICIAL `design::Compare` with `--calib`, POOL-INERT and NOT-SINGLE guards |
| `OWNER_BEFORE.r10earl120.txt` | its output on the pristine pair: the pool (174 `int_typespec::Instance` edges), our 24, and the three owners the official walk reaches with their parent chains |
| `pkgobj120.cpp` | tells the two package objects of one name apart (`AllPackages[i]` vs `TopPackages[i]`) and counts the `typespec::Instance` edges landing on each — the tool §6's role residue is measured with |
| `inst120.cpp` / `join120.cpp` | the whole-design `typespec::Instance` inventory and its two-sided join, used to rule the other owner kinds out |
| `site120.cpp` | prints every typespec whose parent chain matches a substring, with its `Instance` spelled by role — how both sides of one reference site are read |
| `SITE.r10earl120.txt` | the head's own site, golden vs pristine vs patched, plus the `pkgobj120` edge counts for all three |
| `cen120.cpp` | THE CENSUS: every substituted-constant typespec keyed home/constant-span/ts-kind/ts-span/signed (file OUT of the key), payload = the package the `Instance` edge NAMES, with a separate `ROLECELL` row carrying the vector role and a `SRC` row per package-parameter declaration typespec |
| `censweep120.sh` | runs it over a whole `verify_golden.py` workdir, golden path from each test's OWN `cmds.txt`, every rc logged |
| `predict120.py` | the mover set predicted BY NAME from the PRISTINE census alone, using the condition the code checks (null cell + instanced source) |
| `score120.py` | the three-way multiset join; asserts the two sweeps' golden halves identical FIRST; scores `CELL` and `ROLECELL` separately |
| `PREDICT_sl.txt` / `PREDICT_u2r.txt` | the predictions, made from the pristine databases |
| `CENSUS_sl.txt` / `CENSUS_u2r.txt` | the corpus three-way scores, calibration line first |
| `a1_axis120.sv` | THE AXIS ARM: the package-origin read in two select shapes, the module-local fence in the same expression, a module-parameter origin, an implicitly typed package origin, a gen-for, two instances |
| `a2_fence120.sv` | THE FENCE ARM: module localparam, module parameter, genvar, gen-scope-local localparam, a DEF-listing body read, a struct-typed package parameter — nothing may move |
| `GRID.r10earl120.txt` | the scored arm grid (golden / pristine / patched, `CELL` and `ROLECELL`), with each arm's `uhdm-cmp` line count and dump md5 on both binaries |
| `HEAD_BEFORE_*` / `HEAD_AFTER_*` | the official `uhdm-cmp` head of Earlgrey_0_1 in both modes, before and after |
| `ROWHEADS_AFTER.r10earl120.txt` | `rowheads.sh` on the seven named rows, patched |
| `attrib120.sh` / `ATTRIB_*` | the sectioned, path-normalised, ORDER-BLIND whole-dump attribution of the two byte movers |
| `wide120.sh` / `widerun120.sh` / `BOUNDARY_*.txt` | the wide boundary over every committed arm, both views, with the fence filter, the rc histogram by side, and the differing list |
| `GATES.r10earl120.txt` | the gates, every command and every number |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the gate scripts, carried so this directory reproduces the battery on its own |
