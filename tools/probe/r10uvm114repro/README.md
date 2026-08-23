# r10uvm114 — § `enumBaseTdCloneElabRanges114`

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `beaf889`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The head this pass was given — SeqDriver x2 + MiniAmiq x2, 62 cmp lines, one
head, at `beaf889` — is CLEARED in all four rows.**

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD

The pristine binary rebuilt from `beaf889` in this pass's worktree is
**byte-identical to the main tree's build**, and `rowheads.sh` reproduces the
master's head log for SeqDriver/default **line for line** (ids aside).

```
LHS (golden)                              RHS (ours)
constant   @105:15-105:17                 operation  @105:15-105:19
|vpiParent -> range @105:14-105:22        |vpiParent -> range @105:14-105:22
|vpiDecompile:31                          |vpiOpType:11              (vpiSubOp)
|vpiSize:64                               |vpiOperand constant UINT:32 @105:15-105:17
|INT:31                                   |vpiOperand constant UINT:1  @105:18-105:19
|vpiConstType:7
```

`uvm-1.2 reg/uvm_reg_model.svh:105` is
`typedef  bit [`UVM_REG_CVR_WIDTH-1:0]  uvm_reg_cvr_t ;` — a package-level
typedef's packed dimension, the macro expanding to `32`.

### The object is NOT the one the parent pointer names

`owner114.cpp` names every object that HOLDS a given `range` in its `Ranges()`
vector — sharing is invisible to `VpiParent`, and the head's framing depends on
it:

```
GOLDEN holders of range 28217:  bit_typespec 28216  'uvm_reg_cvr_t'  (unparented)
OURS   holders of range 653 :   bit_typespec 652    'uvm_pkg::uvm_reg_cvr_t' (package(uvm_pkg))
                                bit_typespec 703    'uvm_reg_cvr_t'  (unparented)
                                bit_typespec 3571   'uvm_reg_cvr_t'  (unparented)
                                bit_typespec 297868 'uvm_reg_cvr_t'  (unparented)
```

`uhdm-cmp` prints the constant's own `vpiParent`, which is the DEF package
listing object's range — but the object pair the walk actually failed on is a
BARE-NAMED clone: our clones SHARE the DEF listing's range vector, golden's
each own a copy.  `tdclone114.cpp` names the referencing context of every such
clone, and the whole delta between the two databases is ONE cell:

| enum_typespec `uvm_pkg::uvm_coverage_model_e`, its base clone | golden | ours (pristine) |
|---|---|---|
| in `package(uvm_pkg)` — the DEF package typedef listing | `OP11` | `OP11` ✓ |
| in `module_inst(work@top_tb)` — the materialized import listing | **`C{INT:31,ct=7}`** | `OP11` ✗ |

`uvm_reg_model.svh:106` is `typedef enum uvm_reg_cvr_t { ... }
uvm_coverage_model_e;`.  Of golden's two ENUM-base clones exactly one is
unfolded — the DEF-package one — and every other unfolded bare clone on either
side sits in the DEF package's out-of-body method listings, where the two
databases agree (golden 24 such objects, ours 28 referencing contexts over 6
shared objects; the sharing is residue R3 and invisible to the judge).  **The
module-context enum base is the single disagreement in the whole database.**  `pkgls114.cpp` and `alias114.cpp` show the package
Typespecs listings and the `Typedef_alias` chains agreeing object for object on
both sides, which is what rules the listing itself out.

`mutfold114.cpp` confirmed the pairing before a line of emitter code was
written: folding that one range in a restored copy of our own database moves
the official head to a different object, while a restore/save round trip with
nothing folded reproduces the 31-line head byte for byte.

---

## 2. THE DECODED MODEL

### Where Surelog folds a typespec's range bound

`CompileHelper::compileRanges`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:3940`), the
EXPLICIT-RANGE arm at `:4006-4025`:

```c++
if ((lexp) && (rexp)) {
  if (reduce == Reduce::Yes) {
    lexp = reduceExpr(lexp, invalidValue, component, compileDesign, ...);
    rexp = reduceExpr(rexp, invalidValue, component, compileDesign, ...);
    if (lexp) { lexp->VpiParent(range); range->Left_expr(lexp); }
    if (rexp) { rexp->VpiParent(range); range->Right_expr(rexp); }
```

so BOTH bounds of a `[a:b]` dimension are reduced, in place, whenever the
caller's `reduce` is `Reduce::Yes`.  `compileTypespec`'s builtin-vector arm
(`CompileType.cpp:1287`) and `compileTypeDef` (`CompileHelper.cpp:501`) pass
their own `reduce` straight through, and `compileDataDeclaration`
(`CompileHelper.cpp:2278`) hands `compileTypeDef` the `reduce` its CALLER chose:

| home of the typedef | reduce | file:line |
|---|---|---|
| **PACKAGE** | the package's own — `Yes` in the elaborated copy, `No` in the unelab twin | CompilePackage.cpp:263 |
| `$unit` FileContent | **`Reduce::Yes`** | CompileFileContent.cpp:104 |
| MODULE | `Reduce::No` | CompileModule.cpp:653 / :1130 |
| PROGRAM | `Reduce::No` | CompileProgram.cpp:301 |
| CLASS body | `Reduce::No` | CompileClass.cpp:294 |

`FunctorCompilePackage` (CompilePackage.cpp:63/68) is what makes the package
row two-valued: the elaborated `Package` with `Reduce::Yes` (UhdmWriter puts it
in `TopPackages`) and its `getUnElabPackage()` twin with `Reduce::No`
(`AllPackages`).  So **a package vector typedef exists TWICE — once with the
bound's operation tree and once with one folded constant** — and every per-use
`clone_tree` (`compileDatastructureTypespec`'s `SimpleType` arm,
`CompileType.cpp ~882-896`, reached for an enum base at `~1319`) copies
whichever of the two its own view holds.

### The folded constant's fields

`ExprEval::reduceExpr`'s binary arms (`UHDM/templates/ExprEval.cpp:3343`
onwards) mint the constant with NO location, so `compileExpression`'s tail
(`CompileExpression.cpp:3647-3665`) stamps it:

```c++
if ((result != nullptr) && (reduce == Reduce::Yes)) { ...reduceExpr... }
if (result && (result->VpiLineNo() == 0)) {
  if (child) fC->populateCoreMembers(child, child, result);
  else       fC->populateCoreMembers(parent, parent, result);
}
```

`child` is the expression node's FIRST CHILD — the LEFT OPERAND's own node —
which is why the folded constant wears the left operand's SPAN and not the
whole bound's.  Measured on golden across `g114_a_pkghome.sv` and
`g114_h_ops.sv`, every cell:

| written bound | folded constant | span |
|---|---|---|
| `` `WID114-1 `` (macro `32`) | `INT:31` ct 7 sz 64 | the `32` |
| `32-1` | `INT:31` ct 7 sz 64 | the `32` |
| `Span-1` | `INT:11` ct 7 sz 64 | the `Span` |
| `Span*2-1` | `INT:23` ct 7 sz 64 | the `Span*2` |
| `(Span*2)-1` | `INT:23` ct 7 sz 64 | the `(Span*2)` — parens INCLUDED |
| `$clog2(Span)-1` | `INT:3` ct 7 sz 64 | the `$clog2(Span)` |
| `Half+Span-1` | `INT:17` ct 7 sz 64 | the `Half+Span` |
| `7` (a literal) | untouched, `UINT:7` ct 9 | — |

### The per-operator encoder (`g114_h_ops.sv`, thirteen typedefs, `Reach`=12, `Lift`=6)

Golden's fold, and what our own ELABORATED listing object already writes:

| written | vpiOpType | golden | ours (elab listing) |
|---|---|---|---|
| `Reach-1` | 11 vpiSubOp | `INT:11` ct 7 | same ✓ |
| `Reach+1` | 24 vpiAddOp | `UINT:13` ct 9 | same ✓ |
| `Reach*2` | 25 vpiMultOp | `INT:24` ct 7 | same ✓ |
| `Reach/2` | 12 vpiDivOp | `INT:6` ct 7 | same ✓ |
| `Reach%7` | 13 vpiModOp | `INT:5` ct 7 | **`UINT:5` ct 9** ✗ |
| `Reach<<1` | 22 vpiLShiftOp | `UINT:24` ct 9 | same ✓ |
| `Reach>>1` | 23 vpiRShiftOp | `UINT:6` ct 9 | same ✓ |
| `Reach&15` | 28 vpiBitAndOp | `UINT:12` ct 9 | same ✓ |
| `Reach\|1` | 29 vpiBitOrOp | `UINT:13` ct 9 | same ✓ |
| `2**Lift` | 43 vpiPowerOp | `INT:64` ct 7 | **`UINT:64` ct 9** ✗ |
| `` `WIDE114-1 `` | 11 | `INT:31` ct 7 | same ✓ |
| `Lift+Reach-1` | 11 over 24 | `INT:17` ct 7 | same ✓ |
| `[7:0]` | — | `UINT:7` ct 9 | same ✓ |

All size 64, all spanned at the left operand.  Eleven of thirteen agree; the
two that do not belong to a DIFFERENT law and are FENCED OUT here (residue R1)
so this pass cannot spread them.

### § `enumBaseTdCloneElabRanges114`

> The per-use clone of an enum's NAMED VECTOR-TYPEDEF base carries the range
> bounds of the VIEW it is built in.  Only the HOME package's own DEF typedef
> listing keeps the bound's operation tree; the elaborated package view, every
> import-clone listing and every module-context listing carry the FOLDED
> constant, because Surelog's `clone_tree` copies the elaborated object there.
> Two fences from the corpus: the DEF-package listing is untouched, and a
> bound whose top-level operator is `%` or `**` is left alone.

---

## 3. THE DISTINGUISHER, MEASURED

`g114_e_enumbase.sv` (one package, module imports it) already agreed with
golden on all eight bound shapes before this pass.  `g114_f_twopkg.sv` — the
SeqDriver topology, package B wildcard-imports package A and the module imports
both — did not, and `g114_g_split.sv` separates the two candidate causes:

| arm | topology | module-context enum base, pristine | golden |
|---|---|---|---|
| `g114_e_enumbase` | one package, module imports it | FOLD | FOLD |
| `g114_g_split` `hazel114` | one package WITH a class | FOLD | FOLD |
| `g114_g_split` `gorse114` | **a second package imports the first** | **OP** | FOLD |
| `g114_f_twopkg` | second package + class | **OP** | FOLD |

`R10U114_ENUMBASEDBG=1` reads out the mechanism: with one package `buildEnumTs`
runs twice, `tdEmit=1 topEmit=0` and `tdEmit=1 topEmit=1`, and the TOP-view
build is the object every later listing shares.  With a second importing
package it runs twice with `topEmit=0` both times — the second under
`importCloneEmit=1` — and **the home package's TOP view build never happens at
all**, so the object every later listing shares is an import clone built while
`sharedAliasTs` still answered with the DEF object.

That is why the fix is DESIGN-FINAL and why the view test has to admit
`importCloneEmit`: golden's import clone is a copy of the ELABORATED object,
the same rule § `negLitPkgRetFold86`'s arm a4 measured for a subroutine clone.
`enumls114.cpp` prints the whole table; on `g114_f_twopkg` golden's
`ALLPKG(heather114_pkg)` / both `TOPPKG`s / `ALLMOD` / `TOPMOD` all list the
FOLDED-base enum object and only `ALLPKG(bramble114_pkg)` lists the symbolic
one.

---

## 4. THE CHANGE

Three production edits, no new file:

* `include/UhdmExporter.h` — `enumBaseTdClone114`, the recorded
  `(clone, base TypeAlias)` pairs, with the law written out.
* `src/TypeEmit.cpp` (`buildEnumTs`, the named-typedef-base clone arm) — record
  the clone unless it is the HOME package's own DEF typedef listing
  (`inPkgTypedefEmit && !pkgTopEmit && !importCloneEmit`).
* `src/UhdmExporter.cpp` (`exportDesign`, design-final, immediately before
  `drainShareDefParamTs()`) — re-point each recorded clone's `Ranges()` at the
  TOP-view listing object's OWN ranges.

The pass **re-points, it does not re-fold**: the bounds it installs are the
ones our own elaborated listing object already computed, so a bound that
listing deliberately left symbolic (§ `elabUnitMisevalNoFold` and its family)
stays symbolic here too, and the two objects cannot disagree.  Four fences,
each a refusal to move a cell this pass did not measure: same typespec KIND,
same range-vector LENGTH, the clone must hold an `operation` the top object
does not, and the top-level bound operator must not be `%` or `**`.

`R10U114_ENUMBASEDBG=1` prints the recorded count and one line per re-point.

---

## 5. GATES

All green.  **NO row converted, nothing promoted, `results/*.csv` untouched.**
`GATES.r10uvm114.txt` carries the battery verbatim; the headlines:

* goldens **23/0** (patched AND pristine), `/bin/false` **0/23**.
* uhdm2rtlil **679 / 50 / 2** in both modes; `ct8rows` **0 differing rows**
  against the committed baseline and against this pass's own pristine CSVs.
* surelog `--mode both`: **471/283/25/10/5** (default) and
  **466/284/23/9/5/3/2/1/1** (testflags) — every histogram identical to this
  pass's own pristine sweep; `ct8rows` **0 differing rows over 1588** against
  `results/golden_surelog.csv`.
* **byteverify MOVERS 0 / 1358** (uhdm2rtlil) and **5 / 956** (surelog), every
  one PREDICTED BY NAME from the pristine databases before the patched sweep
  ran (`PREDICT.r10uvm114.txt`) and attributed row by row
  (`MOVERS.r10uvm114.txt`, `ATTR.r10uvm114.txt`).
* canaries **ok=52 / ok=8, changed=0**; `ctcan2` PASS on both corpora;
  `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**; the five protected
  databases byte-identical, `SVSwitch 4842211c4030` and
  `YosysVerx 6ccda350c24a` pinned.
* **wide boundary**: 3535 arms x 2 views x 2 binaries, PROCESSED asserted,
  **6778 identical / 4 DIFFERING**.  Two are this pass's own arms (the
  POSITIVE CONTROL that the gate can see this law) and two are
  `r10buvm22repro/g22.sv` (residue R2).  All 24 rc=139 cells occur on BOTH
  binaries.

### The heads

```
SeqDriver     default    62 -> 47   NEW HEAD   (head_pris_* -> head_pat_*)
SeqDriver     testflags  62 -> 47   NEW HEAD
MiniAmiq      default    62 -> 60   NEW HEAD
MiniAmiq      testflags  62 -> 60   NEW HEAD
SimpleUVM     both      565 -> 565  log byte-identical
Scoreboard    default   565 -> 565  log byte-identical
BuildUVMPkg   both       47 ->  47  log byte-identical
Earlgrey_0_1  both       36 ->  36  log byte-identical
Rggen         default      0 ->  0  still cmp-equal
```

The line counts are the NEW head object's decompile DEPTH, and the head OBJECT
changed in all four target rows:

* **SeqDriver (both modes) R0** — `uvm_sequence_library.svh:192`
  `int seqs_distrib[$] = '{...}` : golden's `operation` (`vpiOpType:75`,
  assignment pattern) over a `tagged_pattern`, parented at the `int_var`
  `uvm_pkg::uvm_sequence_library::seqs_distrib`, against ours.
* **MiniAmiq (both modes) R0** — `uvm_sequence_lib.svh:196`
  `method_func_call (randomize)` with a `vpiWith` `constraint
  uvm_pkg::uvm_exhaustive_sequence::body`.

### Arm scores (`ARMS.r10uvm114.txt`)

Every purpose-built golden is NON-INCREASING; the three arms in the failing
topology go 30 -> 0, 10 -> 0 and 120 -> 20, and the five arms that were already
golden stay at 0.  `g114_h_ops`'s residual 20 rows are the two FENCED operators.

---

## 6. RESIDUES

* **R1 — `%` and `**` as a bound's TOP-LEVEL operator.**  Golden's fold is
  `INT:` / `vpiIntConst`; our own ELABORATED listing object already writes
  `UINT:` / `vpiUIntConst` there (`g114_h_ops.sv`, the thirteen-operator table:
  eleven agree, these two do not).  That is a defect of the elaborated
  listing's per-operator encoder — r10earl73's family — not of this law, and
  this pass FENCES those two operators out rather than copy a wrong encoding
  into a second object.  Zero corpus witnesses: no database in either corpus
  has an enum whose named vector-typedef base is bounded by a top-level `%` or
  `**`.  Repairing the encoder would let the fence be dropped in one line.

* **R2 — `r10buvm22repro/g22.sv`'s associative-array size-form range.**  The
  two boundary cells that move are a `[string]`-keyed typedef
  (`typedef int ka_int_t[string];`) for which we emit an EXTRA `array_typespec`
  carrying a size-form range `OP11(UINT:<n>, INT:1)` that golden does not emit
  at all.  `<n>` is `22400409` (`0x155cd99`) on the pristine binary and
  `22404505` (`0x155dd99`) on the patched one — an ADDRESS rendered as a
  decimal, deterministic per binary across repeated runs and independent of the
  working directory.  **A BEHAVIOUR-OFF CONTROL BINARY PROVES IT**: built with
  ALL of this pass's code present and both call sites guarded by an UNSET
  environment variable, it produces an enum table byte-identical to the
  pristine binary's (0 differing rows — it does nothing this law does) and
  `<n>` moved anyway, to `22404569` (`0x155ddd9`).  Adding the header member
  alone did not move it; adding the CODE did.  So the two g22 boundary cells
  track the emitter's code size, not this law, and the cell is equally wrong on
  both sides of all four binaries.  `LAYOUT_CONTROL.r10uvm114.txt` has the
  table.

* **R3 — the DEF-package listing's own bare clones.**  Golden mints a separate
  `clone_tree` copy of the typedef object at every named-type use; we SHARE one
  object across the uses in a view (SeqDriver: `tdclone114` counts 158 distinct
  typespecs whose name carries `uvm_reg_cvr_t` on golden and 38 on ours).  Invisible to the judge — no generated
  `Compare` reads `VpiParent`, and every shared object carries the same
  Compare-visible fields — but it is why `uhdm-cmp`'s head printed a
  package-parented `vpiParent` for an object the walk reached as an unparented
  clone, and why `owner114.cpp` had to be written to decode the head at all.

* **R4 — the package VARIABLE's own dims in the DEF view.**  `g114_a_pkghome`
  measures it as a bystander: `bit [32-1:0] pkglit;` written at package scope
  has golden keeping the operation in the DEF view and folding in the
  elaborated one, while we fold in BOTH.  Untouched here — this law is about a
  TYPEDEF's per-use clone, not a variable's own typespec — and recorded so the
  next pass in this family has the measurement.
