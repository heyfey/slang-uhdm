# r10uvm189 — § `assocIdxNamePromoteInImportClone189` — **A WILDCARD-IMPORT CLONE IS A `Reduce::Yes` LISTING: AN ASSOCIATIVE INDEX WRITTEN AS A NAME IS THE SENTINEL THERE, IN BOTH VIEWS** — the SeqDriver ×2 / MiniAmiq ×2 62-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `89631b31` |
| pristine binary | md5 `fc4c6d192b7e39bf2e48728a17a6e29f`, built from this pass's OWN worktree at a clean `89631b31` and frozen `chmod 555` before any sweep |
| patched binary | md5 `9ec3fd24db011affffd41387a38053d8`, frozen `chmod 555` |
| production surface | `src/TaskFuncEmit.cpp` (the call site now asks the law), `include/UhdmExporter.h` (the law and its decode) |
| probe surface | `tools/probe/r10uvm189repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default/testflags AND MiniAmiq default/testflags, 62 cmp lines, ONE `^LHS:` each, the SAME object in all four row-modes → cleared** (62 → 55 lines, still ONE head, a NEW object). |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **surelog 4 / 956** — the four PREDICTED by name from the pristine databases alone (SeqDriver ×2, MiniAmiq ×2) and nothing else; no Scoreboard coin flipped this run. **0 / 1358** uhdm2rtlil. |
| the a-priori prediction | `LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4` and `LISTED=1358 PROCESSED=1358 NOGOLDEN=0 PREDICTED=0`, from the PRISTINE databases with no golden and no patched binary. |
| the corpus population | a body local of a package task_func whose associative index is written as a NAME, in a WILDCARD-IMPORT CLONE listing: **4 declarations × 2 views = 8 cells** per moving row-mode, all in `uvm-1.2 base/uvm_phase.svh` (`predecessors` 1664, `successors` 1693, `pred_of_succ` 1758, `siblings` 2131). |
| the census (nine UVM row-modes) | SeqDriver ×2 and MiniAmiq ×2 **LAW: TOGOLDEN 8 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 0 / ONLY-OURS-MOVED 0**; SimpleUVM ×2, Scoreboard/default and BuildUVMPkg ×2 score **TOGOLDEN 0 / AWAY 0 / MOVED-WRONG 0** and are untouched. Calibrated golden-vs-golden-vs-golden FIRST: every column 0 but `UNTOUCHED=516`. |
| the grid (3 arms × both views) | arm A (INDEX KINDS × listing) **LAW TOGOLDEN 9 / AWAY 0 / MOVED-WRONG 0**; arm B (SCOPES) **LAW TOGOLDEN 5 / AWAY 0 / MOVED-WRONG 0**; arm C (the LISTING axis) **LAW TOGOLDEN 3 / AWAY 0 / MOVED-WRONG 0** — every one in BOTH views, each against a REAL Surelog golden built per arm per view. |
| the WIDE boundary (5087 arms × both views) | `LISTED=5087 FENCED_SKIPPED=0 PROCESSED=5087 PROCESSED-ASSERT-OK`, **MOVED 8 arm-views** — this pass's three arms (6) and `r10uvm184repro/g184_b_kinds.sv` (2), re-measured against its own golden at **TOGOLDEN 1 / AWAY 0 / MOVED-WRONG 0 in both views and both columns**, with uvm184's own cmp head byte-identical in `def` and differing only in object IDs in `elab`. Every uvm186 / uvm185 / uvm181-184 / uvm82-91 / buvm3-15 / sd8-12 / § 139 arm is byte-identical. |
| the patch reproduces | applied to a FRESH `89631b31` worktree and built there, the tree produces md5 `9ec3fd24db011affffd41387a38053d8` — the very binary every number above was measured on. |
| what the corpus itself fences | `int visited[uvm_phase]` at `uvm_phase.svh:1896` and `:1946` — a NESTED-`begin` local (five `if_else` frames deep) at the identical face, in the identical clone listings. Golden keeps the SIZE model there in **every** listing, and so do we, before and after. It is the corpus's own negative control for this law, and arm B's `nestedB189` is its grid twin. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `89631b31` worktree
(md5 `fc4c6d192b7e39bf2e48728a17a6e29f`, the recorded pristine at BASE), ran its
23/23 goldens (`/bin/false` 0/23), and reproduced the committed baselines row for
row — surelog `937/567/48/19/10/3/2/1/1`, uhdm2rtlil `679/50/2` in both modes,
`ct8rows` PASS on all of them, status AND dump column — before a line of code was
written. `rowheads.sh` on that sweep (`HEADS.r10uvm189.txt`):

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         62      1
SeqDriver      testflags       62      1
SimpleUVM      ×2          664681      1
Scoreboard     default         95      1
MiniAmiq       default         62      1
MiniAmiq       testflags       62      1
BuildUVMPkg    ×2              36      1
Earlgrey_0_1   default/tf   31 / 37     1
Rggen          default    CMP_EQUAL
```

The head, identical on all four row-modes (`head_pris_*.cmp`; SeqDriver and
MiniAmiq differ only in the importing package's name, `adpcm_pkg` vs
`svaunit_pkg`) — a BOTH-SIDES compare, not a `<null>`:

```
LHS (golden)                         RHS (ours)
constant: @1664:20-1664:21           operation: @1664:21-1664:30
|vpiParent: range @1664:20-1664:31   |vpiParent: range @1664:21-1664:30
|vpiDecompile:associative            |vpiOpType:11               (vpiSubOp)
|STRING:associative                  |vpiOperand: ref_obj (uvm_phase) @1664:21
|vpiTypespec: -> ref_typespec        |vpiOperand: constant INT:1 vpiSize 64
   -> class_typespec (uvm_phase)                        vpiConstType 7
|vpiConstType:6
```

The declaration is `bit predecessors[uvm_phase];` — uvm-1.2
`base/uvm_phase.svh:1664`, a body local of
`function void uvm_phase::get_adjacent_predecessor_nodes`.

### DECODING THE JUDGE — which field fails first, and why it is not the `array_var`

`ct189assoc own` runs the OFFICIAL `design::Compare` and then scans BOTH
databases with `GetByVpiType`, the generated kind-agnostic edge accessor, so no
field is named by hand and none can be missed by omission:

```
HEAD LHS(golden) = constant()@1664:20-1664:21#196615
HEAD RHS(ours)   = operation()@1664:21-1664:30#195562
GOLDEN parent chain:
    < range()@1664:20-1664:31
    < array_typespec()@1664:8-1664:31
    < ref_typespec()
    < array_var(predecessors)@1664:8-1664:20
    < function(uvm_phase::get_adjacent_predecessor_nodes)@1662:1
    < package(adpcm_pkg)@10:1
    < design(work@top_tb)
edges landing on the head:  range -> edge vpiType=83 (singular)      [vpiRightRange]
```

So the judge stopped inside `range::Compare`
(`UHDM/build/generated/src/range.cpp:92`), on
`SafeCompare(lhs->Right_expr(), rhs->Right_expr())`, and the FIRST field that
differs is `BaseClass::Compare`'s `VpiType` (`BaseClass.cpp:170`) —
`uhdmconstant` against `uhdmoperation`.

**Why not `array_var::VpiArrayType`, which also differs (golden 3, ours 1)?**
Because `array_var::Compare` reads its own `VpiArrayType` only AFTER
`basetype_t::Compare`, and that base chain runs `expr::Compare`, whose last act
is `SafeCompare(lhs->Typespec(), rhs->Typespec())` — into
`array_typespec::Compare`, which reads `Ranges()` BEFORE `Index_typespec()`.
The typespec is therefore walked before the variable's own fields, and the
range bound is the first difference on that path. It also means ONE flag fixes
all four differing fields at once, which §3 measures.

---

## 2. DECODING SURELOG — the sentinel rule, per face

### HALF 1 — why a NAME is a SIZE at all, and what promotes it

Surelog's grammar orders the dimension alternatives
`unsized | unpacked | associative | queue`
(`grammar/SV3_1aParser.g4:1212-1216`), and `unpacked_dimension` has an
`OPEN_BRACKET constant_expression CLOSE_BRACKET` alternative (`:1195-1199`) that
a bare IDENTIFIER matches — so `[uvm_phase]` parses as `paConstant_expression`
and only a type KEYWORD (`[string]`, `[int]`, `[*]`) ever reaches
`paAssociative_dimension`. That much is § `assocIoRange9`'s decode.

`CompileHelper::compileRanges` then compiles the bracket text AS AN EXPRESSION
and, at `src/DesignCompile/CompileExpression.cpp:4096-4133`:

```cpp
if (rexp && (rexp->UhdmType() == uhdmref_obj) && (reduce == Reduce::Yes)) {
  if (typespec *assoc_tps = compileTypespec(component, fC, rexpr, ...)) {
    associativeArray = true;
    UHDM::range *range = s.MakeRange();
    lexpc  = UINT:0 / vpiUIntConst / VpiSize 64 / decompile "0"
    rexpc  = STRING:associative / vpiStringConst / VpiSize 0 / decompile "associative"
    ref_typespec *assoc_tps_rt = ...; rexpc->Typespec(assoc_tps_rt);
    ranges->push_back(range);
    Packed_dimension = fC->Sibling(Packed_dimension);
    continue;                       // DISCARDING the size range it just built
  }
}
if (!associativeArray) {            // :4135-4150
  operation *op = ...; op->VpiOpType(vpiSubOp);   // <name> - 1
}
```

The SENTINEL is minted for a NAME index **exactly when `reduce == Reduce::Yes`**.
Everything else about it — `vpiConstType 6`, `VpiSize 0`, the decompile TEXT
`associative` (a field `expr::Compare` DOES read), the index typespec riding the
right constant — is that block, literally.

§ `assocIdxNameHoistNet135` reads the OTHER consequence of the same arm (the
`ref_obj` the promoted branch discards is already in the late-binding pool, so
it still mints and spans the importing module's implicit wire) and is untouched
by this law.

### HALF 2 — which listings are `Reduce::Yes`, and why a CLONE is one without being compiled that way

`CompilePackage.cpp` (FunctorCompilePackage) compiles a package TWICE: the
elaborated `Package` with `Reduce::Yes` (`design.TopPackages`) and the
`getUnElabPackage()` twin with `Reduce::No` (`design.AllPackages`). An
out-of-body `C::m` written at package level is a package-level
`paFunction_declaration` (`CompilePackage.cpp:213-218`) and inherits the
package's `reduce`; an IN-BODY method is compiled by `CompileClass` and never
sees `Reduce::Yes`.

And `CompileHelper::importPackage` (`CompileHelper.cpp:300-330`) does

```cpp
Package* def = design->getPackage(pack_name);          // :143 — the ELABORATED one
...
task_func* clone = (task_func*)UHDM::clone_tree((any*)func, &elaboratorContext);
sfuncs->push_back(clone);
```

`Design::getPackage` (`src/Design/Design.cpp:435-443`) returns the elaborated
`Package*`; the unelaborated twin is reachable only through
`getUnElabPackage()`. **So BOTH views of an importer hold `clone_tree` copies of
ALREADY-PROMOTED bodies.** A clone is not re-compiled — it is copied from the
`Reduce::Yes` side. That is the same set § `pkgRetTsListing127` decoded for its
own stamp, and this law lands on it for a second field.

### THE FOUR LISTINGS, read off the two pristine databases

`ct189assoc var` on SeqDriver/default. `arrayType` is
`array_var::VpiArrayType`, a COMPARED field; the bound is the
`array_typespec`'s dimension range; the DEF/ELAB tag is read from
`design.AllPackages` / `design.TopPackages` and never merged:

| listing | golden | ours (pristine) | |
|---|---|---|---|
| `class_defn uvm_phase` in `package:uvm_pkg/ELAB` | `3 / SENTINEL`, ats @1664:8-**31** | `3 / SENTINEL`, ats @1664:8-**31** | Reduce::Yes (a), agreed |
| `package:uvm_pkg/DEF` — the `C::m` clone listing | `1 / SIZE`, ats @1664:8-**30** | `1 / SIZE`, ats @1664:8-**30** | Reduce::No, agreed |
| `package:adpcm_pkg/DEF` — import clone | `3 / SENTINEL` | `1 / SIZE` | ← **the head** |
| `package:adpcm_pkg/ELAB` — import clone | `3 / SENTINEL` | `1 / SIZE` | ← the same cell |

Golden lists the clone's `array_var` TWICE per view (once under the `function`,
once under its body `begin`); we share ONE object between the two vectors, which
no generated `Compare` can see (none reads `VpiParent` — RESUME §9). That is why
the judge compares golden's function-level copy against our shared object, and
why the census keys on the LISTING and the owner's face rather than on the
object.

---

## 3. DECODING SLANG — one gated render, four fields

`makeAssocArrayVar` (`src/TaskFuncEmit.cpp`, § `assocLocalArrayVar40`) already
derives EVERY differing field from one predicate,
`assocDim0(i) = !namedIdx0(i) || promoteNamed`:

* the range's right bound — SENTINEL constant vs the `vpiSubOp` size model;
* `array_var::VpiArrayType` — `vpiAssocArray` (3) vs `vpiStaticArray` (1);
* `array_typespec::Index_typespec` — present vs absent;
* the `array_typespec`'s end column — `dims.back().end()` minus `(promoted ? 0 : 1)`.

So the whole law is the value of `promoteNamed` at ONE call site. It was

```cpp
oob ? !cloneMode : (pkgTopEmit && !classScope)
```

and is now `promoteAssocIdxName189(oob, cloneMode, classScope)`
(`include/UhdmExporter.h`, next to § `pkgRetTsListing127` whose set it shares):

```cpp
if (pkgImportCloneEmit) return !(classScope && !oob);
return oob ? !cloneMode : (pkgTopEmit && !classScope);
```

* **an import clone promotes in BOTH views** — the new conjunct. For a
  class-method clone `pkgClassTfClone` is the IMPORTER package
  (`src/ParamEmit.cpp:23381-23385`), so `cloneMode` was true there and the old
  spelling refused; for a free package function's clone
  (`src/ParamEmit.cpp:20969`) the DEF view had no `pkgTopEmit` and refused too.
  Arm C separates the two: both move, in the same direction, in both views.
* **`classScope && !oob` still never promotes** — an IN-BODY class method, which
  `CompileClass` compiles with `Reduce::No` and which § `assocLocalArrayVar40`
  measured on t57a (`inb57::iAssocCls57::iacls`). The guard is written out so a
  future in-body clone cannot slip through.
* **a NESTED-`begin` local still never promotes** — `StmtEmit.cpp`'s call site
  passes `false` unconditionally and is not touched; `compileStmt`'s
  `paSeq_block` arm hardcodes `Reduce::No`. The corpus and arm B both witness it.
* **a KEYWORD index is untouched** — `[string]`, `[int]`, `[*]` are
  `paAssociative_dimension` and are the sentinel in every listing already;
  `promoteNamed` never reaches them (arm A measures all three as UNTOUCHED).

---

## 4. THE GRID — three arms, both views, a REAL Surelog golden per cell

`grid189.sh` builds ONE Surelog golden and BOTH binaries' databases per view,
records every rc (an `rc=139` segfault must never read as a result, RESUME §9),
and `score189.py` joins the three censuses on an ID-FREE, RANGE-SPAN-FREE key
(`LISTING+VIEW | OWNER LINE:COL | OWNER NAME | DIM#`) — the range's own span
cannot enter the key, because the two producers span a promoted range at the
whole bracket and a size range at the selector alone.

**Two columns, scored separately**: `LAW` = `arrayType` + the bound's KIND (the
fields this law governs, and the one the judge stopped on); `IDXTS` = the index
typespec's identity. A pre-existing residue on the second axis must not be
laundered into the first, and a regression on it must not be hidden by it.

Calibrated golden-vs-golden-vs-golden FIRST on every arm: every column 0 but
UNTOUCHED.

| arm | what it varies | LAW, both views |
|---|---|---|
| A `g189_a_idxkind.sv` | SEVEN index spellings (class name, typedef-of-class-handle, `string`, `int`, `[*]`, enum typedef, typedef-of-int) × three bodies (out-of-body method, in-body method, free package function) × home / wildcard-import clone | **TOGOLDEN 9 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 0 / UNTOUCHED 33** |
| B `g189_b_scope.sv` | ONE class-name index at SEVEN scopes: package variable, class property, out-of-body method local, NESTED-`begin` local, out-of-body TASK local, free package function local, module variable | **TOGOLDEN 5 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 0 / UNTOUCHED 11** |
| C `g189_c_listing.sv` | home vs EXPLICIT import (`import P::fn;`) vs WILDCARD import vs a package never imported at all | **TOGOLDEN 3 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 1 / UNTOUCHED 12** |

What the arms prove that the corpus alone cannot:

* **Every index kind promotes together.** Golden's clone is the sentinel for a
  class name, a typedef of a class handle, an enum typedef and a typedef of
  `int` alike; the KEYWORD spellings were already the sentinel in every listing
  and do not move. The law is about the LISTING, not the index kind.
* **A TASK local moves exactly like a FUNCTION local** (arm B `taskLocB189`) —
  the population is `task_func`, not `function`.
* **A NESTED-`begin` local does not move and must not** (arm B `nestedB189`,
  golden SIZE in every listing) — the arm's own negative control, and the corpus
  carries the identical face twice (`visited` @1896, @1946).
* **A class property, a package variable and a module variable do not move** —
  they are not this call site's population at all.
* **The free package function's clone was already right in the ELAB view and
  wrong in the DEF view** (arm A `frClsA189`, arm C `freeClsC189`): the old
  `pkgTopEmit` half covered one view of one face, which is exactly the shape of
  a half-decoded listing rule.

---

## 5. THE CENSUS — nine UVM row-modes, movers by name

`cenall189.sh` censuses golden, pristine and patched for every named row × mode,
reading each row's golden path out of its OWN `cmds.txt` so no golden is guessed,
and asserting `PROCESSED` so a silent skip cannot read as clean
(`LISTED=10 PROCESSED=9 SKIPPED=1`, the skip being Scoreboard/testflags, which
has no golden — the same `SKIP-NOFILE` `rowheads.sh` reports).

Calibration first, golden in all three slots (SeqDriver/default):
`LAW TOGOLDEN=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 UNTOUCHED=516`.

| row-mode | LAW | IDXTS |
|---|---|---|
| SeqDriver default / testflags | TOGOLDEN **8** / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 0 / UNTOUCHED 506 | TOGOLDEN 8 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 1 |
| MiniAmiq default / testflags | TOGOLDEN **8** / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 0 / UNTOUCHED 549 | TOGOLDEN 8 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 1 |
| SimpleUVM default / testflags | 0 / 0 / 0 / 0 / UNTOUCHED 293 | 0 / 0 / 0 / STILL-WRONG 1 |
| Scoreboard default | 0 / 0 / 0 / 0 / UNTOUCHED 297 | 0 / 0 / 0 / STILL-WRONG 1 |
| BuildUVMPkg default / testflags | 0 / 0 / 0 / 0 / UNTOUCHED 343 | 0 / 0 / 0 / STILL-WRONG 4 |

`ONLY-OURS-MOVED = 0` on every row. The eight moving cells per row-mode are four
declarations × two views of one clone listing:

```
package:adpcm_pkg/DEF   predecessors@1664:8   arrayType=1 SIZE  ->  arrayType=3 SENTINEL
package:adpcm_pkg/DEF   successors@1693:8     arrayType=1 SIZE  ->  arrayType=3 SENTINEL
package:adpcm_pkg/DEF   pred_of_succ@1758:9   arrayType=1 SIZE  ->  arrayType=3 SENTINEL
package:adpcm_pkg/DEF   siblings@2131:7       arrayType=1 SIZE  ->  arrayType=3 SENTINEL
package:adpcm_pkg/ELAB  ... the same four
```

with the index typespec landing on golden's object in every one
(`class_typespec (uvm_phase)` at the selector's span, `vpiInstance` = package
`uvm_pkg`, `vpiClassDefn` = `uvm_pkg::uvm_phase` — checked in the dump).

**The IDXTS STILL-WRONG cells are pre-existing and identical in the pristine and
patched databases** (that is what STILL-WRONG means here: `ours == pristine !=
golden`). SimpleUVM, Scoreboard and BuildUVMPkg carry the same ones with the LAW
column at 0, which is the control that dates them before this pass.

### The mover prediction, made BEFORE the patched sweep was read

`predict189.sh` reads only OUR PRISTINE databases: a movable cell is a
declaration-dimension range still in the SIZE form whose owner `array_var` is
listed under a `package` and whose owner face also occurs under a DIFFERENT
package name — the database-visible signature of a clone listing. It is a
deliberate SUPERSET in one direction (it cannot tell a wildcard import from an
explicit one, and the law fires only on the wildcard — residue R1) and it names
the HOME listing's own cell alongside the clone's.

```
surelog     LISTED=956  PROCESSED=956  NOGOLDEN=0  PREDICTED=4   PROCESSED-ASSERT-OK
uhdm2rtlil  LISTED=1358 PROCESSED=1358 NOGOLDEN=0  PREDICTED=0   PROCESSED-ASSERT-OK
```

The four are `default/SeqDriver`, `testflags/SeqDriver`, `default/MiniAmiq`,
`testflags/MiniAmiq`. `byteverify.sh SELFCHECK=1` then reports **MOVERS 4 / 956**
— those four and nothing else — and **0 / 1358** on uhdm2rtlil.

Attribution, order-blind (sorted whole dumps, workdir path normalised): each of
the four moves **384 lines**, and every one of them sits on the four declaration
lines the law names:

```
18 line:2131:7   18 line:2131:16   18 line:1758:9   18 line:1758:22
18 line:1693:8   18 line:1693:19   18 line:1664:8   18 line:1664:21
 6 line:2131:15   6 line:1758:21    6 line:1693:18   6 line:1664:20
 8 line:28:1     (package uvm_pkg — the new class_typespec's vpiInstance)
 8 line:134:1    (class_defn uvm_phase — its vpiClassDefn)
```

by kind: `array_typespec` 72, `range` 48, `constant` 24, `class_typespec
(uvm_phase)` 24, `operation` 16 — the law's own objects and nothing else.

### The head cleared, proved rather than assumed

`ct189assoc skip` carries r10uvm184's visited-set technique: every generated
`Compare` opens with `if (!context->m_visited.insert(this).second) return r;`,
so PRE-SEEDING the previous head makes the judge skip it and keep walking, with
NO EDIT to either database. On the PATCHED SeqDriver/default database the ladder
reads

```
round 0: array_var(predecessors)@1664:8#14293 / <null>   (class_defn uvm_phase, uvm_pkg/ELAB)
round 1: array_typespec()@1664:8-1664:31#14294 / <null>
round 2: package(uvm_pkg)@28:1#1 / <null>
```

— **no sentinel constant appears anywhere behind the new head**: the eight
promoted cells now compare equal, they are not merely masked.

---

## 6. GATES

All in `GATES.r10uvm189.txt`; `SLANG_UHDM` was exported explicitly to each
binary and every `cmds.txt` audited by BINARY PATH (`/tmp/…/pris.bin` for the
pristine sweeps, `/tmp/…/pat.bin` for the patched ones — never the main-tree
binary, which both harnesses silently default to).

* goldens **23/0** on the pristine binary, **23/0** on the patched, **0/23** with
  `SLANG_UHDM=/bin/false`;
* uhdm2rtlil `679/50/2` in BOTH modes on BOTH binaries; surelog
  `937/567/48/19/10/3/2/1/1` on BOTH — the status histogram checked, not just
  the row count (an `rc=139` segfault would read as `SLANG_REJECT`);
* `ct8rows` **PASS** on all seven comparisons — committed baseline vs pristine,
  committed baseline vs patched, and patched vs this pass's own pristine, on
  both corpora and both modes, status AND dump column;
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (uhdm2rtlil);
  `ctcan2` PASS with `EXPECT_UNKNOWN=1` / `EXPECT_UNKNOWN=6`;
  `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`;
* protected databases byte-identical: InterfaceModPort, BlackParrotComplex,
  YosysOldOr; SVSwitch pinned `4842211c4030`; YosysVerx pinned `6ccda350c24a`.

---

## 7. RESIDUES AND R0

* **R0 — the next head.** SeqDriver ×2 and MiniAmiq ×2, **55 cmp lines, ONE
  `^LHS:`**, the same object in all four row-modes. It is
  `array_var (predecessors) @1664:8` in the CLASS_DEFN listing
  (`uvm_pkg/ELAB`) with `RHS: <null>` — `BaseClass.h`'s SINGULAR `SafeCompare`
  naming a VALUE, so a reference of OURS is BARE where golden's is bound. The
  reference is the BASE of a `hier_path` inside the WILDCARD-IMPORT CLONE:
  `pred = new[predecessors.size()];` (uvm-1.2 `uvm_phase.svh:1685`), whose
  `ref_obj (predecessors) @1685:16` golden binds to the HOME declaration's
  `array_var` in both clone views and we leave bare. Golden's clone listing
  holds SIX bound references to that object (1669:6, 1675:16, 1677:13, 1679:15,
  1685:16, 1686:13) and ours holds FIVE — every one but the `hier_path` base.
  In the HOME listing both sides are BARE, so it is a CLONE-LISTING binding law,
  the same family as § `cloneNewArrayArgBindsOwnDecl186`, at the `hier_path`
  base face. `head_pat_*.cmp`. (SimpleUVM's own cmp log is the 664681-line depth
  artifact and is deliberately not carried here.)
* **R1 — the EXPLICIT-import copy.** `import P::fn;` produces a copy that golden
  promotes exactly like the wildcard clone (arm C, `package:Riser189/DEF`,
  `freeClsC189`, both views), and this law does not fire there because its gate
  is `pkgImportCloneEmit`, the WILDCARD flag. Surelog does not distinguish them:
  `importPackage`'s `object_name` filter selects WHICH task_func to clone, not
  HOW. **Corpus incidence: zero** — the superset predictor, which cannot tell
  the two apart, names no such cell in 956 + 1358 databases. (r10uvm186's R1 and
  r10uvm184's R1 are the same face for their own laws.)
* **R2 — a TYPEDEF-OF-A-CLASS-HANDLE index typespec.** For
  `bit x[tdTrellisA189]` where `typedef Trellis189 tdTrellisA189`, golden's index
  typespec is `unsupported_typespec (tdTrellisA189)` (Surelog's `compileTypespec`
  declines a class-handle alias) and `assocIndexTs`
  (`src/UhdmExporter.cpp:2276`) hands back `class_typespec (Trellis189)`. Arm A
  scores it `IDXTS MOVED-WRONG 2`, and the SAME cell reads `IDXTS STILL-WRONG` in
  the `class_defn` listing on BOTH binaries — which dates the residue before this
  pass and identifies it as an `assocIndexTs` law, not a listing law. The LAW
  column on those cells is TOGOLDEN: the bound, the `arrayType`, the end column
  are golden's. Widening `assocIndexTs` would move the class-property, io_decl
  and typedef-container sites too and is wider than this pass's evidence.
  **Corpus incidence: zero** (the census's IDXTS MOVED-WRONG is 0 on all nine
  UVM row-modes, and the corpus indices are class NAMES).
* **R3 — an ENUM-typedef index typespec's `vpiInstance` after an import.** Arm A
  golden re-stamps the shared `enum_typespec (Girder189::enKindA189)`'s
  `vpiInstance` to the IMPORTER package once the clone references it; ours keeps
  the home package. **Identical in the pristine and patched databases** (checked
  in both dumps), so it is a pre-existing difference this law merely UNMASKS: it
  is why arm A's patched cmp reads 2852 lines against 62 — the head object
  changed from the sentinel constant to a `package`, whose decompile is enormous,
  and a line count going up with a changed head object is a move, not a
  regression (RESUME §7).
* **R4 — a package variable's `array_var` range.** Arm B reports
  `ONLY-GOLDEN 2` for `pkgVarB189@10:7 dim100` in `Lintel189/DEF` and
  `Soffit189/DEF`: golden hangs an inner-dimension range off the `array_var` of
  a PACKAGE-level associative variable and we hang none. `ONLY-OURS-MOVED 0`,
  identical pristine and patched; not this call site's population
  (§ `emitAssocDims` owns it).
* **R5 — the clone's index `ref_typespec` fullname and the sentinel constant's
  span.** Golden's marker constant is spanned at the `[` (`1664:20-1664:21`,
  `populateCoreMembers(Packed_dimension, …)` then `VpiEndColumnNo(col+1)`) and
  its `ref_typespec` carries `vpiFullName` = the array's clone-scoped fullname;
  we leave both unset. Neither field is read by any generated `Compare`
  (RESUME §9), so the axis is invisible to the judge; it is unchanged by this
  pass in the listing that already promoted.

---

## 8. REPRODUCING

```sh
g++ -O2 -std=c++17 ct189assoc.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o ct189assoc

./ct189assoc own  <golden.uhdm> <ours.uhdm>          # which field the judge stops on, both sides
./ct189assoc skip <golden.uhdm> <ours.uhdm> [rounds] # the heads BEHIND the first one
./ct189assoc cen  <db.uhdm> [name-substr]            # one row per declaration-dimension bound
./ct189assoc var  <db.uhdm> [name-substr]            # one row per array_var (sharing made visible)
./ct189assoc refs <db.uhdm> <name>                   # every reference and its vpiActual
./ct189assoc pred <db.uhdm>                          # the a-priori movable cells

CT189=./ct189assoc ./grid189.sh g189_a_idxkind.sv  <pris.bin> <pat.bin> <workdir>
CT189=./ct189assoc ./grid189.sh g189_b_scope.sv    <pris.bin> <pat.bin> <workdir>
CT189=./ct189assoc ./grid189.sh g189_c_listing.sv  <pris.bin> <pat.bin> <workdir>
python3 score189.py <wd>/cen.g.<view>.txt <wd>/cen.a.<view>.txt <wd>/cen.b.<view>.txt [-v]

CT189=./ct189assoc ./predict189.sh <PRISTINE workdir> <out.txt>
CT189=./ct189assoc ./cenall189.sh  <pris wd> <pat wd> <outdir> SeqDriver MiniAmiq SimpleUVM Scoreboard BuildUVMPkg
./attrib189.sh <pris wd> <pat wd> <outdir> 'SeqDriver|MiniAmiq'
PRI=<pris.bin> PAT=<pat.bin> ROOT=<copy of tools/probe> BWD=/tmp/r10uvm189_bound ./bound189.sh
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
./canaries.sh <fresh.csv> <baseline.csv>;  EXPECT_UNKNOWN=<n> ./ctcan2.sh <baseline.csv> <fresh.csv>
bash canaudit.sh canaries.sh ctcan2.sh
```

Recorded outputs: `HEADS.r10uvm189.txt`, `GRID.r10uvm189.txt`,
`CENSUS.r10uvm189.txt`, `PREDICT.r10uvm189.txt`, `MOVERS.r10uvm189.txt`,
`BOUNDARY.r10uvm189.txt`, `GATES.r10uvm189.txt`, and the per-row
`head_pris_*.cmp` / `head_pat_*.cmp`.
