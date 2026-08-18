# r10buvm19 — § `foreachArraySelfSelectAssignDropsTs19` — **the `foreach` header's array reference loses its typespec in the ELABORATED package listing when an ancestor block assigns the same name through a SELECT**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `bab1c2e` |
| worktree | `/tmp/wt_r10buvm19` |
| pristine binary | md5 `7e9bfebd45e988d63767a207a6ff168c` (frozen `chmod 555` at `/tmp/r10buvm19_bin/pris.bin`) |
| patched binary | md5 `1d1cb908cc3dd8000d80661eecbc22de` (frozen at `/tmp/r10buvm19_bin/pat.bin`) |
| production surface | `src/StmtEmit.cpp` (one predicate, one RAII push at two list sites, one gate) + `include/UhdmExporter.h` (three declarations) |
| probe surface | `tools/probe/r10buvm19repro/` only |
| deliverable | `/tmp/r10buvm19.patch`, applies clean on a FRESH `bab1c2e` |

> **VERIFIER AMENDMENT (r10vbuvm19).**  The shipped law over-fired on one
> family and the gate carries an extra clause: a **PACKAGE-LEVEL VARIABLE** is
> excluded.  Golden's answer for one is CONTEXT-DEPENDENT — when a MODULE or an
> INTERFACE wildcard-imports the package, golden RESOLVES the reference to the
> variable's `array_typespec` and the PRISTINE binary already matched it
> exactly.  All 20 corpus cells this law moves are CLASS PROPERTIES, so the
> clause is byte-inert on both corpora (the fixed binary's 956 surelog
> databases are byte-identical to the ones measured below); in THIS directory's
> grid it costs exactly one cell — `free19` is no longer CONVERTED, so the
> table below reads `CONVERTED 13` / `residue 6` on the verified binary, and
> `grid19.sv` shows 13 removed `|vpiTypespec:` edges instead of 14.  See
> `tools/probe/r10vbuvm19repro/README.md` and `vg19j.sv` / `vg19k.sv` /
> `vg19l.sv`.

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines in both corpora and both modes.  What it
does is clear buvm18's residue R0 and close the foreach ARRAY-REFERENCE
typespec family.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines, default / testflags | **17 / 17** | **152 / 152** (a DIFFERENT, DEEPER head — § 8) |
| `BuildUVMPkg` cmp md5, both modes | `2bb940e8dd2d` (the brief's pin, hit exactly) | `23df339e1b17` |
| head object | a `ref_typespec` on the `foreach` array `ref_var` `m_object_references` that golden does not have | `logic_typespec (uvm_bitstream_t)` vs `logic_typespec (uvm_pkg::uvm_bitstream_t)` (**R0**) |
| golden-vs-ours foreach census, `BuildUVMPkg` | **9** differing (site x view) cells / 1546 | **6 / 1546** |
| the golden GRID (`grid19.sv`, 93 cells) | 19 differ | **5** — **CONVERTED 14, OVER-FIRE 0, MOVED-STILL-WRONG 0** |
| byte movers | — | **9 / 956** surelog (all 9 PREDICTED BY NAME first), **0 / 1358** u2r |
| boundary gate | — | **1 differing arm / 2868** — this pass's own grid |

The other **ten** cmp logs of the seven-row head set keep the SAME HEAD OBJECT:
`Earlgrey_0_1` and `Rggen` are byte-identical, and the five uvm-1.2 rows
(`SeqDriver` / `SimpleUVM` / `Scoreboard` / `MiniAmiq`) differ only in printed
object **ids** — id-normalised (`sed 's/id:[0-9]*/id:N/g'`) all seven logs hash
to one value on both binaries.

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

`/tmp/r10buvm19_s/cmb.txt`, 17 lines, md5 `2bb940e8dd2d7c425c2d64803c6efd04`,
`grep -c '^LHS:'` = 1:

```
LHS: <null>
RHS:
ref_typespec: (uvm_pkg::uvm_packer::pack_object_with_meta::m_object_references), id:42704
|vpiParent:
\_ref_var: (uvm_pkg::uvm_packer::pack_object_with_meta::m_object_references), id:42703, line:22452:11, endln:22452:30
|vpiFullName:uvm_pkg::uvm_packer::pack_object_with_meta::m_object_references
|vpiActual:
\_unsupported_typespec: (m_object_references), id:42705, line:22452:11, endln:22452:30
```

`LHS: <null>` with a full RHS is `BaseClass.h:194`'s SINGULAR mirror

```cpp
} else if ((lhs == nullptr) && (rhs != nullptr)) {
  context->m_failedRhs = rhs;      // only the RHS is set
  return 1;
```

so it names a VALUE, not a container.  The owner is a `ref_var`; `ref_var` is a
`variables` is an `expr`, and `expr::Compare` (`expr.cpp:100`) ends with
`SafeCompare(lhs->Typespec(), rhs->Typespec())` — the ONE singular slot a
`ref_var` has that a golden object can leave null.  So: **golden's `foreach`
header array reference carries no typespec at all and ours carries one.**

`uvm_pkg.sv:22452` is `foreach(m_object_references[i])` inside the out-of-body
`function void uvm_packer::pack_object_with_meta(uvm_object value)`, over the
class property `local uvm_object m_object_references[int];` (`:21712`) — an
associative array of class handles indexed by `int`.

**AND THE SPLIT IS DEF-vs-ELAB, MEASURED IN GOLDEN BEFORE ANY CODE.**  Golden's
`uhdmallPackages` listing of the very same site (dump line 53888) DOES carry
`ref_typespec -> unsupported_typespec (m_object_references)`; only its
`uhdmtopPackages` copy (relative line 300510) is bare.  So the question is not
"does Surelog mint it" (it does) but "what REMOVES it in the elaborated copy".

## 2. THE LAW

> **§ `foreachArraySelfSelectAssignDropsTs19`** — in the **ELABORATED** listing
> of the **HOME** package, a `foreach` header's ARRAY reference loses its
> `vpiTypespec` **entirely** when some **ANCESTOR BLOCK** of the foreach
> (`begin` / named `begin` / `fork` / named `fork`, the subroutine body
> included) has, **in its own direct statement list**, an **ASSIGNMENT whose
> left-hand side is a SELECT written with the array's BARE name** — `a[i] = v;`.
>
> The un-elaborated (`uhdmallPackages`) twin always keeps the
> `unsupported_typespec`; so does an **IN-BODY** class method, and so does every
> **IMPORT CLONE**, in both of the importer's views.
>
> It is INDEPENDENT of the array's kind and of what the reference's typespec
> WOULD have been: a class property's `unsupported_typespec`, a formal's
> `io_decl` typespec and a package variable's real `array_typespec` all go to
> NOTHING.  It does NOT fire for a BARE-name assignment (`a = b;`), for a
> `this.a[i] = v;` / `obj.a[i] = v;` spelling, for a select on a DIFFERENT name,
> for an assignment INSIDE the foreach body, for one in a sibling block, or when
> a nearer ancestor block DECLARES the name.

### THE PRODUCER, READ OUT OF SURELOG

`CompileHelper::compileVariable` (`CompileType.cpp:404-...`) compiles the
foreach header's array name: it resolves to no data type and no class, so the
final `else` makes a `ref_var` over whatever `compileTypespec` returned — an
`unsupported_typespec` — and registers it:

```cpp
ref_var* ref = s.MakeRef_var();
if (ts) { … ref->Typespec(tsRef); tsRef->Actual_typespec(ts);
          if (ts->UhdmType() == uhdmunsupported_typespec)
            component->needLateTypedefBinding(ref); }
```

`UhdmWriter::writePackage` redeems that registration for the ELABORATED copy
only (`UhdmWriter.cpp:1301`, the same `if (elaborated)` that
§ `foreachElabLoopVarAnyKindBinds17` turns on):

```cpp
  if (elaborated) { lateTypedefBinding(s, pack, p); }
  lateBinding(s, pack, p);
```

`lateTypedefBinding` (`:2573`) walks the reference's own `VpiParent` chain.  At
each `begin` / `named_begin` / `fork_stmt` / `named_fork` ancestor it checks the
block's `Variables()`, then its `Parameters()`, then its own direct `Stmts()`:

```cpp
for (auto init : *stmts)
  if (init->UhdmType() == uhdmassignment) {
    const expr* lhs = ((assignment*)init)->Lhs();
    if (lhs && lhs->VpiName() == name) {
      if (lhs->UhdmType() == uhdmref_var) continue;   // the BARE spelling
      if (lhs->UhdmType() == uhdmref_obj) continue;   //   is skipped
      found = true;
      if (const ref_typespec* rt = lhs->Typespec()) tps = rt->Actual_typespec();
```

A SELECT left-hand side is a `bit_select`, which is neither skipped kind, so
`found` becomes true; a `bit_select` carries no typespec, so `tps` stays null;
and the tail at `:3210` then executes

```cpp
if (found == true) { if (tps == nullptr) { … ex->Typespec(nullptr); …
```

which **clears** the array reference's typespec instead of replacing it.  That
is the whole mechanism, and every negative in § 2 falls straight out of it: a
bare-name LHS is the `ref_obj` the loop `continue`s past; a dotted LHS is a
`hier_path` whose `VpiName` is the DOTTED text; a statement inside the foreach
body is not on the parent chain; and a block's `Variables()` are read BEFORE its
`Stmts()`, so a same-named local wins with its real typespec.

`uvm_pkg.sv:22462` `m_object_references[reference_id] = value;` is the direct
statement of the same function-body `begin` that parents the foreach — that one
line is why the head exists.

## 3. THE GOLDEN GRID (`grid19.sv` + `gridcen19.sh`)

A package and nothing else, exactly BuildUVMPkg's shape (no module, so no
`$unit` import and no module elaboration), plus one wildcard-importing package.
93 (site × view) cells.  Verdicts `CONVERTED` / `OVER-FIRE` /
`MOVED-STILL-WRONG` / `residue` / `same`:

**`-- CELLS 93  same 74  CONVERTED 14  OVER-FIRE 0  MOVED-STILL-WRONG 0  residue 5`**

| cell | written | golden DEF | golden ELAB | verdict |
|---|---|---|---|---|
| `none19` | class property, foreach and nothing else | unsupported | unsupported | same |
| **`sel19`** | **the BuildUVMPkg shape: `pa19[7] = null;` in the same block** | unsupported | **NONE** | **CONVERTED** |
| `bare19` | `pa19 = other19;` — the BARE name on the left | unsupported | unsupported | same |
| `deep19` | the select assignment INSIDE the foreach body | unsupported | unsupported | same |
| **`outer19`** | the assignment TWO named blocks up | unsupported | **NONE** | **CONVERTED** |
| **`qsel19` / `isel19` / `fsel19` / `dsel19` / `bsel19`** | queue / assoc-of-int / fixed / dynamic / assoc-by-CLASS | unsupported | **NONE** | **CONVERTED** ×5 |
| **`before19`** | the assignment written BEFORE the loop | unsupported | **NONE** | **CONVERTED** |
| `othersel19` | a select assignment on a DIFFERENT name | unsupported | unsupported | same |
| `insidebody19` | the assignment in a SIBLING `if` block | unsupported | unsupported | same |
| **`twolv19`** | two loop variables | unsupported | **NONE** | **CONVERTED** |
| **`free19`** | a PACKAGE variable + select assignment, package free function | unsupported | **NONE** | **CONVERTED** (ours bound a real `array_typespec`) |
| `freenone19` | the same package variable, no assignment | unsupported | `array_typespec` | same |
| `locsel19` | a subroutine LOCAL + select assignment | unsupported | `array_typespec` | same — **the `Variables()`-before-`Stmts()` control** |
| `thissel19` | **`this.qa19[5] = null;`** | unsupported | **unsupported** | same — **the dotted-LHS control** |
| **`forksel19` / `namedsel19` / `ifanc19`** | a `fork` / named `begin` / `if`-branch ancestor chain | unsupported | **NONE** | **CONVERTED** ×3 |
| **`formsel19`** | a subroutine FORMAL `ref base19 fa19[$]` + select assignment | unsupported | **NONE** | **CONVERTED** (ours bound the io_decl's `class_typespec`) |
| `formnone19` | the same formal, no assignment | unsupported | `class_typespec` | same |
| `inbody19` | an IN-BODY class method with `sel19`'s exact shape | — | unsupported | same — **the class_defn control** |
| **`imp19::*` (19 cells)** | a wildcard IMPORT CLONE of every one of the above | unsupported | **unsupported, BOTH views** | same — **the import-clone control** |

`thissel19`, `bare19`, `deep19`, `othersel19`, `insidebody19`, `locsel19`,
`inbody19` and the whole `imp19` arm are the cells that make "no over-fire" a
MEASUREMENT rather than an inference: each one sits one written token away from
a converting cell and golden keeps its typespec, and the patched binary keeps
it too.

The five `residue` cells are all PRE-EXISTING and all in `imp19` (golden's
import clone keeps an `unsupported_typespec` where we bind a real typespec) —
`P == O` on every one of them, i.e. this pass does not touch them.

## 4. THE IMPORT-CLONE EXCLUSION WAS A MEASURED FIX, NOT A GUESS

The first shipped gate used `pkgRetFoldHome86` (§ `negLitPkgRetFold86`'s window),
which deliberately INCLUDES import clones.  The corpus census caught it
immediately — `MiniAmiq`, `r10buvm19cen` rows from the PRISTINE sweep:

```
G: key=uvm_pkg::uvm_phase::execute_phase|1479:22    view=ELABPKG  ts=NONE
G: key=uvm_pkg::uvm_phase::execute_phase|1479:22    view=DEFPKG   ts=TS  unsupported_typespec
G: key=svaunit_pkg::uvm_phase::execute_phase|1479:22 view=ELABPKG ts=TS  unsupported_typespec
G: key=svaunit_pkg::uvm_phase::execute_phase|1479:22 view=DEFPKG  ts=TS  unsupported_typespec
```

so golden clears the HOME package's elaborated copy and leaves the
wildcard-import copy in `svaunit_pkg` alone, in BOTH views.  The first binary
dropped 4 of MiniAmiq's 6 moved cells AWAY from golden.  The shipped gate is

```cpp
curSubPkgHome17 && !pkgDefViewBody9 &&
!pkgImportCloneEmit && !importCloneEmit && importCopyTsInst == nullptr
```

— all three clone paths named, exactly as § `formalDefaultBindsLikeBody13`
already had to (`pkgImportCloneEmit` covers only the WILDCARD ones).  The
`imp19` grid arm was added at the same time so the boundary between the two is
witnessed on 30 lines and not only in a 2-million-line corpus row.

## 5. THE PRODUCTION CHANGE

* `foreachSelfSelAssign19(arrSym)` — the ancestor scan described in § 2,
  innermost first, stopping at the block that DECLARES the array.
* `BlockAnc19` — an RAII push of the enclosing statement LIST.  It is pushed at
  **two** sites, and that is load-bearing: `case StatementKind::List` covers a
  subroutine body, but a WRITTEN `begin` / `fork` is `case StatementKind::Block`,
  which iterates its own statement list inline instead of routing through the
  `List` case.  With only the first site, `outer19` / `namedsel19` / `ifanc19`
  saw an EMPTY ancestor stack and the law fired on nothing there.
* the gate of § 4, and `rv->Typespec(art)` skipped (and no `pendingForeachArrayTs`
  / `pendingLoopVarTs9` entry deferred) when it holds.

**A trap this pass paid for and records:** slang leaves the inner `NamedValue`
of an `ElementSelectExpression` with a **NULL `syntax`**, so a "written bare?"
test that reads the BASE expression's syntax node rejects every real cell.  The
test reads the OUTERMOST written node and peels `ElementSelectExpression` layers
off it instead.

## 6. THE CENSUS

`r10buvm19cen.cpp` reads a `.uhdm` out of `Serializer::AllObjects()` (never dump
TEXT) and prints one row per `foreach_stmt`: the enclosing subroutine's full
name + the foreach's `line:col` as the KEY, the VIEW (`ELABPKG` / `DEFPKG` /
`TOPMOD` / `DEFMOD` / `DEFCLASS` / `DEFPROG` / `DEFIFACE`, decided by which
design listing the foreach's ROOT ancestor sits in — buvm17's trap 1: walking
all the way to `uhdmdesign` answers "design" for every row and reads the axis as
a constant), and the VALUE: the `vpiVariables` array reference's kind, name,
typespec presence and actual, plus the whole `vpiLoopVars` listing so a change
that also moved a LOOP VARIABLE (§ `foreachElabLoopVarAnyKindBinds17`'s window)
cannot hide.

`cenall19.sh` runs it over every database of a sweep workdir, both sides, taking
GOLDEN from the cache entry `cmds.txt` records.  **Each job writes its OWN file
and the files are concatenated at the end** — the first version appended to one
shared file from 6 writers and interleaved lines whenever a write exceeded
`PIPE_BUF`, silently corrupting ~0.02 % of the rows.

### BuildUVMPkg, golden vs ours, all 773 foreach sites

| view / shape | golden | ours pristine | ours patched |
|---|---|---|---|
| ELAB, `ref_var` with NO typespec | **17** | 14 | **17** |
| ELAB, `ref_var` -> `unsupported_typespec` | 302 | 306 | 303 |
| ELAB, `ref_var` -> `array_typespec` | 78 | 79 | 79 |
| ELAB, other resolved typespec | 16 | 14 | 14 |
| ELAB, `hier_path` (no typespec) | 47 | 48 | 48 |
| DEF, `ref_var` -> `unsupported_typespec` | 262 | 262 | 262 |
| DEF, `ref_var` with NO typespec | 14 | 14 | 14 |
| differing (site x view) CELLS, golden vs ours | — | **9** | **6** |

### the corpus, all 956 surelog databases, ELABPKG sites

| (golden ts, ours ts) | pristine | patched |
|---|---|---|
| (NONE, NONE) | 700 | **720** |
| (NONE, TS) | **20** | **0** |
| (TS, TS) | 4615 | 4615 |
| (TS, NONE) | 31 | 31 (unchanged — a PRE-EXISTING residue, R2) |

## 7. THE MOVER SET, PREDICTED BY NAME FIRST

`predict19.py` was run on the PRISTINE sweep's census, before the patched sweep
was looked at, with the predicate *"an `ELABPKG` foreach array reference whose
GOLDEN has no typespec and whose OURS has one"*:

```
PREDICTED-MOVER-DBS 9   CELLS 20
  default/BuildUVMPkg 3   default/MiniAmiq 2   default/Scoreboard 2
  default/SeqDriver 2     default/SimpleUVM 2
  testflags/BuildUVMPkg 3 testflags/MiniAmiq 2 testflags/SeqDriver 2
  testflags/SimpleUVM 2
PREDICTED-MOVER-TESTS  BuildUVMPkg MiniAmiq Scoreboard SeqDriver SimpleUVM
u2r: foreach = 0 in ALL 1358 databases  ->  PREDICTED-MOVER-TESTS 0
```

The 20 cells are exactly two array names — `uvm_packer::pack_object_with_meta`'s
`m_object_references` and `uvm_phase::execute_phase`'s `m_executing_phases` (two
sites) — and the `lv=` loop-variable listing is IDENTICAL on both sides at every
one of them, so § `foreachElabLoopVarAnyKindBinds17` is provably untouched.

**`byteverify.sh SELFCHECK=1` reported exactly those 9 databases and no others
out of 956, and 0 / 1358 on u2r.**  `Scoreboard/default` is a real mover here
(2 predicted cells) as well as the campaign's documented `vpiTaskFunc` ORDER
COIN, so it is attributed ORDER-BLIND: RAW 100 sides, SORTED 22 sides = the 2
cells' 11 lines each.

**Every changed side is a REMOVED `|vpiTypespec:` and its subtree; ZERO lines
were added anywhere** (`dumpdiff19.sh`, id- and path-normalised):

| database | raw sides | sorted sides | content |
|---|---|---|---|
| `BuildUVMPkg` (both modes) | 33 | 33 | 3 cells: `pack_object_with_meta::m_object_references`, `execute_phase::m_executing_phases` ×2 |
| `SeqDriver` / `SimpleUVM` / `MiniAmiq` (both modes) | 22 | 22 | 2 cells: `execute_phase::m_executing_phases` ×2 |
| `Scoreboard` (default) | 100 | **22** | the same 2 cells; the extra 78 raw sides are the documented COIN — order-blind the diff is **0 added / 22 removed** |

`detcheck19.sh`: 3 runs of the patched binary on the `BuildUVMPkg` command line
give **1 distinct hash**, 0 `NO_OUTPUT`.

## 8. R0 — THE NEW HEAD, AND IT IS NOT A REGRESSION

`BuildUVMPkg`, both modes, **152 cmp lines, md5 `23df339e1b17`, 1 head**:

```
LHS:
logic_typespec: (uvm_bitstream_t), id:193166, line:7840:9, endln:7840:42
|vpiParent:        \_ref_typespec: (uvm_pkg::uvm_packer::unpack_field::unpack_field), id:193165
|vpiName:uvm_bitstream_t
|vpiTypedefAlias:  \_ref_typespec: (…::unpack_field::uvm_bitstream_t) -> logic_typespec (uvm_pkg::uvm_bitstream_t)
|vpiInstance:      \_package: uvm_pkg, id:1
|vpiRange:         \_range: L=constant INT:4095 @7840:23 (FOLDED)  R=constant UINT:0
|vpiSigned:1
RHS:
logic_typespec: (uvm_pkg::uvm_bitstream_t), id:179019, line:7840:9, endln:7840:42
|vpiParent:        \_ref_typespec: (uvm_pkg::uvm_packer::unpack_field::unpack_field), id:179018
|vpiName:uvm_pkg::uvm_bitstream_t
|vpiInstance:      \_package: uvm_pkg, id:2
|vpiRange:         \_range: L=operation (UVM_STREAMBITS-1) @7840:23 (SYMBOLIC)  R=constant UINT:0
|vpiSigned:1
```

Both sides are set, so this is `BaseClass::Compare`'s `VpiType`/`VpiName` arm on
the SUBROUTINE-RETURN typespec of `uvm_packer::unpack_field` — the same
NAMED-CLONE family buvm18 closed for package PARAMETERS
(§ `pkgParamBareTdNamedClone18`), now on a function's return type written with
the bare name of a package typedef: golden mints a per-declaration clone named
`uvm_bitstream_t` with a `vpiTypedefAlias` and a FOLDED left bound, we share the
package object under its QUALIFIED name with a SYMBOLIC bound.  Next pass's
target.

**It is not a regression.**  The whole-dump diff of the pristine and patched
`BuildUVMPkg` databases (id- and banner-normalised) is **33 lines, every one of
them a REMOVAL inside the three cells this law names, and ZERO additions** — the
head region is byte-identical between the two binaries.  R0 was simply MASKED by
the head this pass cleared.

**The line count going UP (17 -> 152) is not more defects** — it is a bigger
object printing (buvm17's precedent): the old head decompiled one `ref_typespec`,
the new one decompiles a `logic_typespec` with its alias chain, its instance and
its whole range subtree, twice.  The head count is 1 on both binaries and both
modes.

## 9. THE GATES (all run in this worktree, both binaries frozen `chmod 555`)

| gate | result |
|---|---|
| 1. build both, md5 | pristine `7e9bfebd45e988d63767a207a6ff168c`, patched `1d1cb908cc3dd8000d80661eecbc22de` |
| 2. goldens | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` -> **23 FAIL** (negative control), each with `SLANG_UHDM` exported per binary |
| 3. u2r testflags vs committed `gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** (679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`) |
| 3. u2r testflags + default vs the PRISTINE sweep taken first in this worktree | **PASS, 0 differing rows** both modes |
| 4. surelog `--mode both` vs committed `results/golden_surelog.csv` | **PASS, 0 differing rows over 1588**, status AND dump.  **NO ROW CONVERTED.** |
| 4. surelog vs the pristine sweep | **PASS, 0 differing rows** |
| 5. byteverify `SELFCHECK=1`, u2r | `MOVERS: 0 / 1358`, selfcheck 1357/1358 |
| 5. byteverify `SELFCHECK=1`, surelog | `MOVERS: 9 / 956`, all 9 predicted BY NAME first; selfcheck 955/956 |
| canaries | `canaries.sh` `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2.sh` PASS on both; `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` **byte-identical** both modes; `SVSwitch` `4842211c4030`; `YosysVerx` `6ccda350c24a` |
| boundary | `PROCESSED=2868 == LISTED=2868`, rejects symmetric (128 == 128, no asymmetric reject), **DIFFER=1** — `r10buvm19repro/grid19.sv`, this pass's own arm and its positive control |

The PRISTINE sweep is byte-identical to both committed baselines, so there is no
drift to report this pass.  `verify_golden.py` and `tests/check_goldens.sh` were
run with `SLANG_UHDM` exported per binary, and every `cmds.txt` in all four
sweep workdirs names exactly one slang binary (`/tmp/r10buvm19_bin/pris.bin` or
`/tmp/r10buvm19_bin/pat.bin`) — audited by PATH, not by the string `slang-uhdm`.

Every bind-window arm in the tree (buvm3-18, uvm82-94, sd8-12,
§ `classArgBind12`, § `retNameRecvCollapseArgsBindLikeBody15`,
§ `collArgNamedBlkLocalNoBind15`, § `controlBodyNoBind28`,
§ `blkLocalSameCtrlDepthArgBinds57/64`, § `pkgVarBindsOnlyThroughInstance88`,
§ `formalDefaultBindsLikeBody13`, § `classInBodyRecvCallArgNoBind52`,
§ `superNewFormalBinds28`, § `newArrayArgNoBind16`,
§ `foreachElabLoopVarAnyKindBinds17`, § `pkgParamBareTdNamedClone18`, …) is
**byte-identical**, which is expected: this law removes one `vpiTypespec` edge
on one `foreach` header object and never goes near `lateBinding`,
`Actual_group` or any listing kind.

## 10. RESIDUES

* **R0 — THE NEW HEAD**, § 8: the bare-typedef-named clone on a SUBROUTINE
  RETURN typespec (`uvm_packer::unpack_field`, `uvm_bitstream_t`).  The
  parameter half of that family is buvm18's § `pkgParamBareTdNamedClone18`; this
  is the same construction applied at a different declaration site, and the
  RANGE-FOLD half (§ `pkgTdRangeViewFold18`) applies too — golden's bound is
  folded `INT:4095`, ours is the symbolic `UVM_STREAMBITS-1`.
* **R1 — the three remaining differing foreach sites in `BuildUVMPkg`**
  (down from 9): `uvm_phase::get_predecessors_for_successors|34610:7` (golden
  lists a `ref_var` where we build a `hier_path` — buvm17's R2 family),
  `uvm_sequence_library::init_sequence_library|56591:3` (golden lists a
  `class_var` named `this_type::m_typewide_sequences`, we list a bare `ref_var`),
  and `uvm_component::m_set_cl_verb|41183/41196` (golden binds the `string_typespec`
  of a `values` formal where we bind an `array_typespec`).
* **R2 — 31 corpus cells where OURS has no typespec and GOLDEN does**, unchanged
  by this pass (`predict19.py`'s REVERSE table): 11 in MiniAmiq, 2 in SeqDriver,
  1 each in BuildUVMPkg / Scoreboard / SimpleUVM, per mode.  Pre-existing; the
  `imp19` grid rows are the same shape (golden's import clone keeps an
  `unsupported_typespec` we resolve).
* **R3 — `Surelog` clears the typespec, it does not RE-POINT it.**  The
  `lateTypedefBinding` walk has a whole family of arms this pass did not model
  (a `for_stmt`'s init assignment, a function's `Io_decls` / `Return` /
  `Parameters`, a `module_inst`'s ports and nets, the `::`-qualified package
  typespec lookup).  Where those arms would REPLACE a typespec rather than clear
  it, our emitter's own resolution already agrees with golden on 4 615 of 4 646
  corpus ELABPKG cells, so no arm was widened speculatively.

## 11. FILES

| file | what it is |
|---|---|
| `r10buvm19cen.cpp` / `build19.sh` | the foreach array-reference typespec census instrument |
| `cenall19.sh` | the corpus-wide, both-sides census driver (per-job output files) |
| `predict19.py` | the a-priori mover prediction + the ELABPKG contingency table |
| `grid19.sv` / `gridcen19.sh` | the 93-cell golden grid of § 3 and its three-way verdict table |
| `sweeps19.sh` | the sweep driver (binary asserted out of every `cmds.txt`) |
| `dumpdiff19.sh` | mover attribution, raw AND order-blind |
| `detcheck19.sh` | determinism (N runs, one binary) |
| `bound19.sh` | the boundary gate (fd-3 arm list, children `</dev/null`, PROCESSED asserted, subdirectories included, banner normalised) |
| `byteverify.sh` `rowheads.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | carried forward unchanged from the landed passes |
