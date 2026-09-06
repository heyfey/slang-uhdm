# r10uvm174 — § `pkgDefClassCloneNoBitsFold174` — **A PACKAGE'S *DEF* LISTING FOLDS NOTHING, AND THE OUT-OF-BODY `C::m` CLONES THAT LISTING CARRIES ARE PART OF IT — BUT A WILDCARD-IMPORT CLONE IS NOT** — the SimpleUVM ×2 40-line head **CLEARED**, and the type-query family **CLOSES** on all nine UVM databases

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW WAS CONVERTED**. `GOLDEN_DEFER` was never set.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `a0a33bb3` |
| worktree | `/tmp/wt_r10uvm174` |
| pristine binary | md5 `9853d69d43a9cf87884b368be6f16c7f`, built from a clean `a0a33bb3` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `9b5f05dfd8e3b7688267182183b4c173`, frozen `chmod 555` before any sweep |
| production surface | `src/ExprEmit.cpp` (**+45 / −0**: one gated decline at the existing `$bits` fold site; no other line touched) |
| probe surface | `tools/probe/r10uvm174repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **40** | **52** | 1 — a **NEW head**, a different object (§8) |
| Scoreboard default | 95 | 95 | 1 unchanged, head log identical after id-stripping |
| MiniAmiq default / testflags | 40 | 40 | 1 unchanged, head log identical after id-stripping |
| SeqDriver default / testflags | 33 | 33 | 1 unchanged, head log **byte-identical** |
| BuildUVMPkg default / testflags | 52 | 52 | 1 unchanged, head log **byte-identical** |
| Earlgrey_0_1 default / testflags | 31 / 122 | 31 / 122 | 1 unchanged, head log **byte-identical** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |

A cmp line count going **up** on a head object that **CHANGED** is the expected
shape (RESUME §7): the count is the new head object's decompile size. The old
head object is gone from the log entirely.

Gates, all green (`GATES.r10uvm174.txt`): goldens 23 PASS / 0 FAIL on both
binaries and the `/bin/false` negative control 0 PASS / 23 FAIL; uhdm2rtlil
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in **both** modes with
`ct8rows` **0 differing rows** against the committed baseline *and* against this
pass's own pristine control, status column and dump column; the surelog corpus
**0 differing rows over 1588**; byteverify `SELFCHECK=1` **9 / 956** and
**0 / 1358** movers, **every one predicted BY NAME from pristine databases
before the patched sweep ran**; canaries `ok=52 changed=0` and `ok=8 changed=0`;
`ctcan2` PASS on both corpora; `canaudit` `UNCOVERED=0 FENCE-BREACH=0`; the five
protected databases byte-identical, `SVSwitch` pin `4842211c4030` and
`YosysVerx` pin `6ccda350c24a` both held.

---

## 1. THE HEAD, DECODED — the judge, the edge, both field vectors, golden's argument

`HEAD.r10uvm174.txt` holds the full transcript. The official head on SimpleUVM,
both modes, one `^LHS:` line, 40 cmp lines, at `a0a33bb3`:

```
LHS  sys_func_call: ($bits), id:69190, line:731:34, endln:731:39
       |vpiParent  \_operation: , id:69188, line:731:19, endln:731:45
       |vpiArgument \_byte_var: (uvm_pkg::uvm_packer::pack_bytes), id:69191,
                                 line:731:40, endln:731:44
       |vpiName:$bits
RHS  constant: , id:132083, line:731:34, endln:731:45
       |vpiParent  \_operation: , id:132079, line:731:19, endln:731:45
       |vpiDecompile:8 |vpiSize:64 |UINT:8 |vpiConstType:9
```

Both sides print in full, so this is `BaseClass::Compare`'s FIRST test — a
`VpiType` mismatch — and neither `SafeCompare` overload of RESUME §9 applies:
`m_failedLhs` and `m_failedRhs` are BOTH set, so the head names no null and no
container. `ct174own.cpp` (the owner-finder, mirror form, descended from
`r10uvm164repro/ct164own.cpp`) reads the edge from BOTH sides with the
generated, kind-agnostic `GetByVpiType`, so no field is named by hand and none
can be missed by omission:

```
golden operation()@731:19-731:45 #69188   edge vpiType=97 (vector index 1)
   ours operation()@731:19-731:45 #132079  -> vector present size 2, [1] = constant()@731:34-731:45
  ours operation()@731:19-731:45 #132079  edge vpiType=97 (vector index 1)
   golden operation()@731:19-731:45 #69188 -> vector present size 2, [1] = sys_func_call($bits)
```

**ONE edge — `vpiOperand[1]` of one `operation`, face-matched on both sides.**
The chain above it is `assignment@731:8` → `begin@733` →
`function(uvm_packer::pack_bytes)@730:1-757:12` → `package(uvm_pkg)`
**directly**: the package's own `Task_funcs` listing, not a `class_defn`.

**GOLDEN'S ARGUMENT OBJECT, exactly.** A `byte_var`: no `VpiName`, span
`731:40-731:44` (the five columns of the `byte` keyword), `vpiParent` = the
`sys_func_call`, no typespec. It is Surelog's rendering of a TYPE operand —
`CompileHelper::compileExpression`'s `paIntegerAtomType_Byte` arm
(`CompileExpression.cpp:1605-1608`) is exactly
`result = s.MakeByte_var(); result->VpiParent(pexpr);` and nothing more. The
`vpiFullName:uvm_pkg::uvm_packer::pack_bytes` the dump prints beside it is
SYNTHESIZED from the parent chain (RESUME §9: a naming residue is often a
parenting residue); the object carries no name of its own, and no generated
`Compare` reads `VpiFullName`.

**BOTH FIELD VECTORS.** Golden's `sys_func_call` carries `Tf_call_args` = that
one `byte_var`. Ours is a `constant` with `VpiValue "UINT:8"`,
`VpiDecompile "8"`, `VpiSize 64`, `VpiConstType 9` (`vpiUIntConst`) and **no
typespec** — the exact object `ExprEmit.cpp`'s `$bits` mint produces.

**BOTH COPIES ON LINE 731, SIDE BY SIDE** (`ct174own`'s step 2). uvm-1.2
`uvm_packer.svh:731`, `int max_size = value.size() * $bits(byte);`, inside the
out-of-body definition `function void uvm_packer::pack_bytes(...)`:

| the copy | golden | ours |
|---|---|---|
| under `class_defn:uvm_packer` (the ELABORATED listing) | `constant UINT:8` @731:34-731:39 | `constant UINT:8` @731:34-731:45 ✓ |
| under `package:uvm_pkg` directly (the DEF listing's `C::m` clone) | **`sys_func_call($bits)`** @731:34-731:39 | `constant UINT:8` @731:34-731:45 ✗ |

Each producer has exactly two copies of that body, and they disagree in exactly
one of them.

---

## 2. THE LAW, AND SURELOG'S FOLD-DECLINE MATRIX

> **`compileBits` can only fold under `Reduce::Yes`. The un-elaborated package
> compile is `Reduce::No` AND `m_elabMode == false`, so NOTHING in a package's
> DEF listing reduces — including the out-of-body `C::m` class-method
> DEFINITIONS that listing carries. A WILDCARD-IMPORT clone is not part of it:
> it is a copy of the HOME package's ELABORATED object and keeps the fold in
> both of the importer's views.**

`CompileHelper::compileBits` (Surelog `CompileExpression.cpp:4663-4790`) reaches
a `constant` down exactly two roads, and BOTH are gated on
`reduce == Reduce::Yes` (`:4736` the typespec road, `:4740` the expression
road). The ONLY thing that can promote a `Reduce::No` call is

```cpp
if (m_elabMode && (reduce == Reduce::No) && tps) {          // :4729
  UHDM::ExprEval eval;
  if (eval.isFullySpecified(tps)) reduce = Reduce::Yes;
}
```

and `FunctorCompilePackage` (`CompilePackage.cpp:60-68`) compiles every package
TWICE — the elaborated `Package` with `Reduce::Yes` and its
`getUnElabPackage()` twin with `Reduce::No` — while `CompilePackage::compile`
(`:80`) sets `m_helper.setElabMode(reduce == Reduce::Yes)` from that SAME
argument. In the un-elaborated compile BOTH halves of the promotion's guard are
false, so `$bits` cannot fold there **whatever its argument is**. That
`setElabMode` call is the whole decode, and it is why r10uvm95's
§ `bitsOutOfBlockNoReduce95` — which read the same split off an out-of-block
class method and could not attribute it — was left unshipped: the split is not
in-block versus out-of-block, it is **DEF listing versus ELABORATED listing**,
and an out-of-body class-method definition written at package scope is compiled
by the PACKAGE's two passes. `UhdmWriter::writePackage`'s `::`-split
(`UhdmWriter.cpp:1254`) later files the elaborated copy under the `class_defn`,
which is why the corpus head sits on a class method.

### 2.1 THE MATRIX, MEASURED PER LISTING BEFORE ANY CODE WAS WRITTEN

`grid174.sh` builds each arm with Surelog and with both binaries in BOTH views
and reads it with `ct174cen`, which keys every surviving type-query
`sys_func_call` on *listing × home × name × line × column*. The listing is read
STRUCTURALLY — membership of the root container in `design->AllPackages` /
`TopPackages` / `AllModules` / `TopModules` — so both producers answer it the
same way and the listings are never merged. GOLDEN'S ANSWER, arm
`g174_a_forms.sv`, one `$bits` per argument kind written identically in three
homes (`GRID.r10uvm174.txt`):

| `$bits(` argument `)` | DEF listing, `Prism::outBlockQuery` | ELAB listing, the `class_defn` copy of that SAME body | ELAB listing, the IN-BLOCK twin |
|---|---|---|---|
| `byte` `int` `shortint` `longint` (type keywords) | **KEEP** | fold | fold |
| `dozenWord` (package typedef) | **KEEP** | fold | fold |
| `shardKind` (class-local typedef) | **KEEP** | **KEEP** | fold |
| `facet` (own class property) | **KEEP** | **KEEP** | fold |
| `scratch` (function local) | **KEEP** | **KEEP** | **KEEP** |
| `lam` (formal) | **KEEP** | **KEEP** | **KEEP** |
| `SHEEN` (class localparam) | **KEEP** | **KEEP** | **KEEP** |
| `GLAZE` (package parameter) | **KEEP** | fold | **KEEP** |
| `lam + 1` (expression) | **KEEP** | fold | **KEEP** |

**The DEF-listing column is uniform: golden keeps all twelve.** That is the law,
and the whole of it. (The two ELAB columns differ from *each other* in four
cells; both are PRE-EXISTING, untouched by this pass, and the two of them where
we disagree with golden are residues R2 and R3.)

**THE SYSTEM FUNCTIONS** (`g174_b_sysfns.sv`, one out-of-body method and one
out-of-body task carrying twelve different type queries over the same operands):
in the DEF listing golden keeps `$bits`, `$size`, `$clog2`, `$high`, `$low`,
`$left`, `$right`, `$increment`, `$dimensions`, `$unpacked_dimensions` and
`$countones` — **every one of them**. We already kept ten for other reasons;
**`$bits` is the only one we still folded there**, which is why one gate on one
name is the entire change.

**THE HOMES** (`g174_c_homes.sv`): the DEF listing owns the package's own
function, its own task, the out-of-body METHOD, the out-of-body TASK and the
out-of-body CONSTRUCTOR (`Beacon::new`) — golden keeps in all five. It does not
own the class-property initializer or the package-parameter initializer (they
exist only in the elaborated listing), and it FOLDS the package-VARIABLE
initializer's `$bits(byte)` even in the def listing — residue R4.

**THE FENCE** (`g174_d_import.sv`): `sootPkg` does nothing but
`import emberPkg::*`, and both of its listings carry a copy of
`emberPkg::Kindling::gauge`. Golden folds all four of that copy's `$bits` in
BOTH of the importer's views — and so do we, before and after. The copy is of
the home's ELABORATED object (§ `negLitPkgRetFold86` arm a4, re-measured here).
`emitImportedPkgClassMethodClones` sets `pkgClassTfClone` exactly as the
own-package clone loop does, so a gate written on that flag alone would move
**eight measured cells AWAY** from golden. This arm is why
`&& !pkgImportCloneEmit && !importCloneEmit` is in the code, and the corpus
agrees: SeqDriver's and MiniAmiq's `adpcm_pkg` wildcard-imports `uvm_pkg` and
its clone listings hold 9 kept cells in each view on BOTH producers, before and
after.

### 2.2 OUR FOLD SITE, AND WHAT THE GATED DECLINE EMITS

`src/ExprEmit.cpp:25401-25412` already declines for the package's own def
listing (`curPkgEmitSym && !pkgEmitTopView`). Our `C::m` clones are built by
`emitPackageClassMethodClones` (`ParamEmit.cpp:22853, 22948-23007`), which runs
under `if (topView)` because it needs the `class_defn`s the top pass has just
created — so `pkgEmitTopView` is TRUE while the clone body is walked and that
guard cannot see it. `pkgClassTfClone` is exactly the window, the same signal
§ `pkgTdRangeViewFold18` already uses for the same reason
(`ParamEmit.cpp:16499-16506`).

The added gate is one `if`:

```cpp
if (pkgClassTfClone && !pkgImportCloneEmit && !importCloneEmit &&
    bitsOutOfBlock95())
    bitsKeep = true;
```

`bitsOutOfBlock95()` is the predicate r10uvm95 decoded and shipped **uncalled**
"for the next pass" — this is that pass, and calling it makes STATED GATE ==
CODE GATE: the def listing carries `extern`-declared method DEFINITIONS and
nothing else, so the predicate that names the shape also certifies it.

With `bitsKeep` true the site falls through to `MakeSys_func_call` and emits the
call with its argument built by the ordinary argument walk. For a type keyword
that argument is our minted typed variable — `byte_var` for `byte`, `int_var`
for `int`, `long_int_var` for `longint` — parented at the `sys_func_call`,
which is the object golden's `paIntegerAtomType_*` arm makes. On the head:

```
patched   sys_func_call($bits)@731:34-731:45  |vpiArgument \_byte_var@731:40-731:44
golden    sys_func_call($bits)@731:34-731:39  |vpiArgument \_byte_var@731:40-731:44
```

The only remaining difference is the CALL's span — golden wears a name-only
span, we span the whole call. That is r10uvm95's residue R5, restated here as
R6: dump-only, because no generated `Compare` reads a span.

---

## 3. THE GRID (`GRID.r10uvm174.txt`)

Five purpose-built goldens, each compiled by **Surelog** and by **both
binaries** in **both views** (`-elabuhdm` / `--elabuhdm`) — the law IS a
DEF/ELAB listing split and one view cannot see it. Names are deliberately
unrelated to each other and to the arm letter. Every arm's `rc` is recorded;
**non-zero rc count: 0** on all five, in both the pre-code and the post-code
run. Each arm is scored twice, on exact positions and as a span-blind multiset.

| arm | what it varies | verdict |
|---|---|---|
| `g174_a_forms.sv` | 12 ARGUMENT KINDS × free function / in-block method / out-of-block method | **TO-GOLDEN 12, AWAY-GOLDEN 0** in both scorings; cmp 40 → **18** in both views |
| `g174_b_sysfns.sv` | 12 SYSTEM FUNCTIONS on an out-of-body method and an out-of-body task | **TO-GOLDEN 8, AWAY-GOLDEN 0**; the `elab` view goes 40 cmp lines → **0, CMP-EQUAL** |
| `g174_c_homes.sv` | the HOMES: free function, free task, in-block method, out-of-body method, out-of-body task, out-of-body CONSTRUCTOR, class-property / package-variable / package-parameter initializers | **TO-GOLDEN 12, AWAY-GOLDEN 0** |
| `g174_d_import.sv` | THE FENCE: a wildcard-import clone of another package's out-of-body class method, both views | **TO-GOLDEN 6, AWAY-GOLDEN 0** — the importer's four clone cells did NOT move |
| `g174_e_notmove.sv` | THE NEGATIVE CONTROL: a class in a MODULE with an out-of-body method, a `$unit` function, an interface function, a module function | **NO CELL MOVED**, either view — and the boundary gate confirms the whole arm is byte-identical |

Arm A's DEF column is the cleanest statement of the law:

```
golden   PKGDEF Prism::outBlockQuery  12 kept cells  (byte int shortint longint
                                       dozenWord shardKind facet scratch lam
                                       SHEEN GLAZE lam+1)
pristine PKGDEF Prism::outBlockQuery   6 kept cells  (the last six only)
patched  PKGDEF Prism::outBlockQuery  12 kept cells  — golden, cell for cell
```

---

## 4. THE CENSUS AND THE MOVER LEDGER (`CENSUS.r10uvm174.txt`)

### 4.1 The nine UVM databases × both modes, golden vs ours, keyed by the matrix

`ct174cen` on every UVM row-mode, joined per position. **`OURS-ONLY` — a
position WE keep and golden folds — is 0 on every one of the nine**, so the
family is one-sided and the patch can only move toward golden:

| database | BOTH-KEEP | GOLDEN-ONLY | OURS-ONLY |
|---|---|---|---|
| SimpleUVM (default, testflags) | 32 | **17** | **0** |
| Scoreboard (default; testflags is SKIP-NOFILE) | 32 | **17** | **0** |
| SeqDriver (default, testflags) | 50 | **17** | **0** |
| MiniAmiq (default, testflags) | 50 | **17** | **0** |
| BuildUVMPkg (default, testflags) | 43 | **46** | **0** |

Every GOLDEN-ONLY position, on all nine, is the same cell of the matrix:
`listing=PKGDEF`, `home=…|PKGLIST|OOBNAME`, `call=$bits` — an out-of-body
class-method clone in a package's DEF listing. The arguments are the type
keywords `byte` / `int` / `longint` (rendered `byte_var` / `int_var` /
`long_int_var`) and, once per database, the package typedef `uvm_reg_data_t`
(a `ref_obj`) in `uvm_reg_block::check_data_width`.

### 4.2 The prediction, made from PRISTINE databases before the patched sweep

`predsweep174.sh` ran `ct174pred` over **every** pristine database of both
corpora and reported two numbers per database that bracket the truth from
opposite sides:

* **WINDOWS** — out-of-body `C::m` clones the DEF package listings carry. A
  database with `WINDOWS=0` provably cannot move: the gate is unreachable there.
* **CANDIDATES** — folded-`$bits` constants found inside those windows
  (`vpiSize` 64, `vpiConstType` 9, a `UINT:` value, span ≥ 8 columns wide).

```
surelog    SCANNED=956  POSSIBLE(WINDOWS>0)=11  PREDICTED_MOVERS=9  SCANFAIL=0
uhdm2rtlil SCANNED=1358 POSSIBLE(WINDOWS>0)=0   PREDICTED_MOVERS=0  SCANFAIL=0
```

**PREDICTED BY NAME:** `SimpleUVM`, `SeqDriver`, `MiniAmiq`, `BuildUVMPkg`
(default + testflags) and `Scoreboard` (default) — nine databases. The two
POSSIBLE-but-not-PREDICTED rows are `ApbSlave` (default + testflags): 23
windows, zero folded-`$bits` constants inside them, so it was predicted NOT to
move — **and it did not**.

`byteverify.sh SELFCHECK=1` then realised **exactly those nine and no other**
(9/956 and 0/1358; selfcheck 955/956 and 1357/1358 — the comparator can see).

The CANDIDATE count is a per-cell bound in both directions and both are stated:
SeqDriver and MiniAmiq report 34 candidates and move 17 (the other 17 are the
`adpcm_pkg` import clones the fence holds), while BuildUVMPkg reports 34 where
46 cells move — twelve of its cells are the `+: $bits(byte)` widths of indexed
part-selects, whose folded constant hangs off a carrier with no parent chain
back to the package, so a constant-keyed scan cannot attribute them. The
DATABASE-level set is exact, and `byteverify.sh` is its arbiter.

### 4.3 The direction of every realised mover

`census174.sh` scores each moved database against its golden, exact positions
and span-blind:

| database | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG |
|---|---|---|---|
| SimpleUVM ×2, Scoreboard, SeqDriver ×2, MiniAmiq ×2 | 17 each | **0** | **0** |
| BuildUVMPkg ×2 | 46 each | **0** | **0** |

211 cells, all TO-GOLDEN. **`STILL-WRONG = 0` on all nine means our type-query
KEEP set now EQUALS golden's, position for position, on every UVM database: the
family is CLOSED on this corpus.**

**Scoreboard/default is the ~50/50 COIN (RESUME §9), so its byte hash cannot
attribute itself.** The path-normalised, sorted (order-blind) `uhdm-dump` diff
of pristine vs patched is **268 lines out of 1 100 350, and every one is the
law's**: 17 `constant` lines removed, 34 `sys_func_call` lines added (the dump
prints each object twice), 17 typed argument variables (8 `byte_var`, 8
`int_var`, 1 `ref_obj`) and their field lines. **Zero `svunit_pkg` listing-order
lines** — the coin did not flip in this pair, and the byte move is the law and
nothing else (`DUMPDIFF.Scoreboard.default.r10uvm174.txt`).

---

## 5. THE BOUNDARY (`BOUNDARY.r10uvm174.txt`)

`bound174.sh` compiles **every** `.sv`/`.v` in a COPY of the whole committed
probe tree — top level **and** subdirectories — in **both** views with both
frozen binaries, asserts `PROCESSED == LISTED`, keys its scratch on the RELATIVE
path, gives every child `</dev/null` and reads the file list on fd 3. This
pass's own `g174_*.sv` are the positive control: a gate that reports zero movers
over them cannot see.

```
LISTED=4847  PROCESSED=4847  PRODUCED_DBS=4690  MOVED_ARMS=8  RC_DIFFS=0
```

Four of the eight are this pass's own positive control (`g174_e_notmove.sv`, the
negative control, is byte-identical). The other four were rebuilt against a
**fresh Surelog golden** by `armjudge174.sh` and scored — `--only PKGDEF
--nospan`, and again over ALL listings in both scorings:

| arm | cmp pristine → patched | verdict |
|---|---|---|
| `r10buvm27repro/g27_b_shapes.sv` | 122 → 122, same head object | TO-GOLDEN 2, **AWAY-GOLDEN 0** |
| `r10uvm95repro/g95_a3_order.sv` | 32 → 32, same head object | TO-GOLDEN 2, **AWAY-GOLDEN 0** |
| `r10uvm95repro/g95_a5_oob.sv` | 36 → 38, **new head object** (`$bits`@26:9 cleared, head moves to 28:9) | TO-GOLDEN 8, **AWAY-GOLDEN 0** |
| `r10v95repro/v95_b3_homes.sv` | 40 → 106, **new head object** (`sys_func_call`@35:13 → `constant`@42:12) | TO-GOLDEN 2, **AWAY-GOLDEN 0** |

**`arms judged=8  AWAY-GOLDEN rows=0  EMPTY-GOLDEN rows=0  MISSING=0`.** Every
row whose cmp count GREW did so because the head object CHANGED — verified head
by head, printed in `BOUNDARY.r10uvm174.txt` — never with the same object.
r10uvm95's own arms moving is the expected shape: this pass is the one that
ships the law that pass decoded and refused to ship un-split.

The four slang-fenced tests are a `FENCED=` list only, carried by `canaudit.sh`:
**zero** files in the arm tree match any of their names, none was dispatched by
any driver here, and `canaudit.sh` reports `FENCE-BREACH=0`.

---

## 6. WHAT THIS PASS DELIBERATELY DID NOT DO

* **The MODULE's own `C::m` listing.** `g174_e_notmove.sv` shows golden keeping
  `$bits(chainVec)` in the copy of `winchTop::Capstan::haul` that the MODULE's
  Task_funcs listing carries and folding it in the module's `class_defn` copy —
  the same DEF/ELAB shape one level over, and we have both halves backwards. It
  is NOT this law: `emitPackageClassMethodClones` is package-only, so
  `pkgClassTfClone` is null there, and the arm confirms the cell did not move.
  `CompileModule.cpp:776/783` hardcodes `Reduce::No` for both module compiles,
  so what a later pass must decode is `m_elabMode` in the MODULE pipeline
  (`UhdmWriter.cpp:4808/4925/4956/5150/5184`). Residue R5, corpus population 0.
* **Un-keeping anything.** Every disagreement this pass touches is one-sided
  (golden keeps, we fold). The reverse cells — R1, R3, R4 — need a fold to be
  ADDED, a different change with a different blast radius, and shipping one on
  the back of this one would have been a wash.

---

## 7. RESIDUES

* **R1 — THE FREE-FUNCTION HALF OF THE IMPORT CLONE.** `g174_d_import.sv`:
  golden folds `$bits(byte)` and `$bits(cinderWord)` in `sootPkg`'s copy of
  `emberPkg::freeGauge` — indeed it folds the whole `8 + 16` to a single `24` —
  where our def-listing guard `curPkgEmitSym && !pkgEmitTopView` makes us keep
  both. PRE-EXISTING, unchanged by this pass, and it is that arm's post-patch
  head. **2 arm cells; corpus population 0** — the 18 `adpcm_pkg` clone cells of
  §2.1 agree with golden on both binaries.
* **R2 — THE CLASS-LOCAL TYPEDEF IN THE ELABORATED CLASS BODY.** Arm A,
  `$bits(shardKind)` @30:31: golden KEEPS it in the `class_defn` copy of an
  out-of-body method and we fold it. 1 arm cell, corpus population 0.
* **R3 — THE PACKAGE PARAMETER AND THE EXPRESSION IN THE ELABORATED LISTING.**
  Arm A, `$bits(GLAZE)` and `$bits(lam + 1)` @32:12 / 32:27: golden FOLDS both
  in the `class_defn` copy of an out-of-body method, and again at 40:42 / 40:57
  in the elaborated listing of a free package function, where we keep them.
  `$clog2(64)` in arm B @16:29 is the same shape. PRE-EXISTING; 5 arm cells,
  corpus population 0.
* **R4 — THE PACKAGE-VARIABLE INITIALIZER.** Arm C, `int wickTally =
  $bits(byte);` @10:19: golden folds it in the DEF listing too, where the
  def-listing guard makes us keep it. It is that arm's head BEFORE and AFTER
  this pass, unchanged (cmp 40 → 40, same object). 1 arm cell, corpus
  population 0.
* **R5 — THE MODULE'S `C::m` LISTING.** §6 above. 2 arm cells per view, corpus
  population 0.
* **R6 — THE KEPT CALL'S SPAN.** Golden's surviving `sys_func_call` wears a
  NAME-ONLY span (`$bits`, 5 columns); ours spans the whole call. r10uvm95's R5,
  restated because this pass creates 211 more of them. `uhdm-cmp` reads no span,
  so this is dump-only.

## 8. R0 — THE NEXT HEAD

**SimpleUVM ×2 and Scoreboard/default, 52 lines, ONE head, the SAME object**
(the logs differ only in ids). Another `VpiType` mismatch —
`BaseClass::Compare`'s first test — so both sides print in full. uvm-1.2
`uvm_sequencer_base.svh:1389`,
`function SEQ_ARB_TYPE uvm_sequencer_base::get_arbitration();`:

```
LHS  ref_var:  (uvm_pkg::uvm_sequencer_base::get_arbitration) @1389:10-1389:26
       |vpiParent  \_function: (uvm_pkg::uvm_sequencer_base::get_arbitration) @1389:1-1391:12
       |vpiTypespec \_ref_typespec -> enum_typespec: (uvm_pkg::UVM_SEQ_ARB_TYPE) @332:40-332:56
RHS  enum_var: (uvm_pkg::uvm_sequencer_base::get_arbitration) @1389:10-1389:26
       |vpiTypespec \_ref_typespec -> enum_typespec: (uvm_pkg::UVM_SEQ_ARB_TYPE) @359:1-367:26
```

It is the function's own RETURN VARIABLE. Golden lists it as a bare `ref_var`
whose `ref_typespec` points at the `enum_typespec` **at the TYPEDEF's NAME
span** (`332:40-332:56`, the `SEQ_ARB_TYPE` alias); we mint an `enum_var` and
point at the enum's **DECLARATION span** (`359:1-367:26`, the `enum { … }`
body). Two facts in one head: the return variable's KIND for an enum-typed
return, and WHICH `enum_typespec` object a bare-alias return resolves to.
**R0: a function whose return type is a package enum TYPEDEF lists a `ref_var`
over the alias's typespec, not an `enum_var` over the enum body.**

BuildUVMPkg, SeqDriver, MiniAmiq and Earlgrey_0_1 keep their own older heads,
byte-untouched by this pass.

## 9. HOW TO REPRODUCE

```bash
# the probes
for f in ct174own ct174cen ct174pred; do
  g++ -O2 -std=c++17 $f.cpp -I ~/.local/include \
      -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/$f
done

# the head decode (needs a SimpleUVM workdir from verify_golden --filter SimpleUVM)
/tmp/ct174own <golden.uhdm> <ours.uhdm> 731

# the fold census of one database, and the golden-vs-ours join
/tmp/ct174cen <db.uhdm>
python3 join174.py <golden census> <ours census> <tag>

# one grid arm, both views, on two binaries, then score it
CT174CEN=/tmp/ct174cen bash grid174.sh g174_a_forms.sv <pristine> <patched> <wd>
python3 score174.py <wd> --list            # exact positions
python3 score174.py <wd> --nospan --list   # span-blind multiset

# predict the movers from PRISTINE databases, before touching anything
bash predsweep174.sh <pristine verify_golden workdir> /tmp/PRED.txt /tmp/ct174pred

# score the movers against golden
CT174CEN=/tmp/ct174cen bash census174.sh <pristine wd> <patched wd> <outdir> \
    SimpleUVM Scoreboard SeqDriver MiniAmiq BuildUVMPkg

# the boundary, and the verdict on every arm it moves
PRIS=<pristine> PATCHED=<patched> bash bound174.sh <copy of tools/probe> /tmp/bnd
CT174CEN=/tmp/ct174cen PRIS=<pristine> PATCHED=<patched> \
    bash armjudge174.sh /tmp/bnd/MOVERS <copy of tools/probe> /tmp/aj
```
