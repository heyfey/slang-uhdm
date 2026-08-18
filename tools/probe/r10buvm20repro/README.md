# r10buvm20 — § `pkgClassOobRetNameBareClone20` — **the 152-line BuildUVMPkg head cleared: the BODY-LOCAL return variable of an OUT-OF-BODY package-class method takes the same BARE-NAMED typedef clone the method's own `vpiReturn` already takes**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `de79702` |
| worktree | `/tmp/wt_r10buvm20` |
| pristine binary | md5 `7aa2538c15f50452f39416bd6e2036e3` (reproduced the main tree's byte-for-byte at pass start), frozen `chmod 555` at `/tmp/r10buvm20_bin/pris.bin` |
| patched binary | md5 `ac97b47aa254cc61c5598ec872194560`, frozen at `/tmp/r10buvm20_bin/pat.bin` |
| production surface | `src/ModuleEmit.cpp` — ONE arm inside `drainFuncRet`, 57 added lines, 48 of them comment |
| probe surface | `tools/probe/r10buvm20repro/` only |
| deliverable | `/tmp/r10buvm20.patch`, applies clean on a FRESH `de79702` |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines in both corpora and both modes.  What it
does is clear the head buvm19 handed over (R0) and close the bare-typedef
clone family at the one site that still shared.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines (`2>&1`, the brief's counting), default / testflags | **152 / 152** | **29 / 29** |
| `BuildUVMPkg` cmp lines (stderr only) | 76 / 76 | 15 / 15 |
| `BuildUVMPkg` cmp md5 (`2>&1`), both modes | `23df339e1b17` (the brief's pin, hit exactly) | `6e1067f47e20` |
| head object | `logic_typespec (uvm_bitstream_t)` vs `logic_typespec (uvm_pkg::uvm_bitstream_t)` | `io_decl (severity)` vs `<null>` — a `ref_obj::Actual_group` bind gap (**R0**) |
| subroutine-site typespec census, `BuildUVMPkg` | — | **CONVERTED 2, OVER-FIRE 0**, same 8949, residue 3850 |
| the golden GRID (`g20.sv`, 75 cells) | — | **CONVERTED 1, OVER-FIRE 0**, same 59, residue 14 |
| byte movers | — | **9 / 956** surelog (all 9 PREDICTED BY NAME first), **0 / 1358** u2r |
| boundary gate | — | see § 7 |

The other **ten** cmp logs of the seven-row head set are **byte-identical
between the two binaries** (not merely id-normalised — `cmp -s` on the raw
logs), and both `BuildUVMPkg` modes' logs are byte-identical to each other on
both binaries.

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

`/tmp/r10buvm20_wd/pris.default.cmp` (stderr, 76 lines; `2>&1` = 152 lines,
md5 `23df339e1b177269ecf960e2ba8097e9`, `grep -c '^LHS:'` = 1):

```
LHS:
logic_typespec: (uvm_bitstream_t), id:193166, line:7840:9, endln:7840:42
|vpiParent:        \_ref_typespec: (uvm_pkg::uvm_packer::unpack_field::unpack_field), id:193165
|vpiName:uvm_bitstream_t
|vpiTypedefAlias:  \_ref_typespec: (…::unpack_field::unpack_field::uvm_bitstream_t), id:193167
                     |vpiActual: \_logic_typespec: (uvm_pkg::uvm_bitstream_t), id:193168
|vpiInstance:      \_package: uvm_pkg, id:1
|vpiRange:         \_range: L=constant INT:4095 @7840:23  R=constant UINT:0
|vpiSigned:1
RHS:
logic_typespec: (uvm_pkg::uvm_bitstream_t), id:179019, line:7840:9, endln:7840:42
|vpiParent:        \_ref_typespec: (uvm_pkg::uvm_packer::unpack_field::unpack_field), id:179018
|vpiName:uvm_pkg::uvm_bitstream_t
|vpiInstance:      \_package: uvm_pkg, id:2
|vpiRange:         \_range: L=operation (UVM_STREAMBITS-1) @7840:23  R=constant UINT:0
|vpiSigned:1
```

BOTH sides are set and both are objects, so this is neither `<null>` arm of
`BaseClass.h:187-198`.  The FIELD is `typespec::Compare`'s FIRST own field
(`typespec.cpp`): `VpiName().compare(...)`, read BEFORE `Typedef_alias` and
before `Instance` — so the ALIAS and the RANGE never even got looked at; the
NAME alone is the head.

### THE OWNER IS **NOT** THE FUNCTION'S `vpiReturn` — THAT ONE ALREADY AGREED

The brief framed this as "the RETURN typespec ref of `function uvm_bitstream_t
uvm_packer::unpack_field(int size)`".  **Measured, that framing is wrong and
the distinction is the whole pass.**  `r10buvm20cen` (this directory) and the
one-off `p1`/`p2` ref-walkers report, on the PRISTINE databases:

| `ref_typespec` `VpiFullName` | owner | golden | ours (pristine) |
|---|---|---|---|
| `uvm_pkg::uvm_packer::unpack_field` (× 3 copies) | the `function`'s `vpiReturn` `logic_var` | `logic_typespec(uvm_bitstream_t)[alias->…]` | **the same** — already agreed |
| `uvm_pkg::uvm_packer::unpack_field::unpack_field` (golden × 1, ours × 2) | a `logic_var` whose `vpiParent` is a **`ref_obj`** | `logic_typespec(uvm_bitstream_t)[alias->logic_typespec(uvm_pkg::uvm_bitstream_t)]`, bound **FOLDED** `INT:4095` | `logic_typespec(uvm_pkg::uvm_bitstream_t)[noalias]`, bound **SYMBOLIC** |

The head object is the **BODY-LOCAL return variable** — the variable the body
reference `unpack_field = 'b0;` (`uvm_pkg.sv:22793`) binds as its
`Actual_group`, which Surelog only materialises in the write phase and which we
mint in `UhdmExporter::drainFuncRet` (`src/ModuleEmit.cpp`).  It is not any
function's `Return()`, so a census that walks `function::Return()` cannot see
it: `r10buvm20cen` carries a dedicated `RETLOCAL` site for exactly this reason
(217 rows in golden, 393 in ours).

## 2. THE LAW

> **§ `pkgClassOobRetNameBareClone20`** — the "declared INSIDE the typedef's own
> package" test that decides whether a package-typedef'd return type takes a
> **bare-named per-declaration CLONE** (with a `Typedef_alias` back to the
> package's listing object) or **shares the package object under its qualified
> name** REACHES THROUGH CLASS SCOPES at the BODY-LOCAL return-variable site
> too: an **OUT-OF-BODY method of a package class**
> (`function uvm_bitstream_t uvm_packer::unpack_field(int size);`) is compiled
> in the package, and Surelog gives its body-local return variable the very
> same clone it gives the function's own `vpiReturn`.
>
> And that clone's packed bound is **FOLDED in every listing**: golden holds
> exactly ONE such object for an out-of-body method (against TWO for a package
> FREE function, whose def-listing copy keeps the symbolic operation per
> § `pkgTdRangeViewFold18`), and its bound is the reduced constant.

`emitTaskFuncs`' own return-typespec arm (`sameScopePkgFn9`,
`src/TaskFuncEmit.cpp`) has walked that class chain since the `jeras_union` /
`SeqDriver` work.  `drainFuncRet` tested `sub.getParentScope() == sc1`, saw the
**class**, fell through to the qualified-name arm, and emitted
`uvm_pkg::uvm_bitstream_t` with no alias.  This pass makes the two sites agree.

**What is IRRELEVANT** (measured on `g20.sv`, § 3): the typedef's KIND does not
reach this arm — `bit` and `int` package typedefs take the SHARED-object route
higher up in `drainFuncRet` and already agree with golden on every judged field
(`bit_typespec(b8_t)[alias->bit_typespec(gp20::b8_t)]`, folded); only the
`logic` vector kind reaches the clone arm.  **What is NOT irrelevant**: how the
type is WRITTEN — a package-QUALIFIED spelling shares in golden and we clone
(residue **R1**, § 8) — and whether the method is IN-BODY: an in-body class
method records no body reference at all, on either side (grid `inb_ret`: 0
objects in golden, 0 in ours).

## 3. THE GOLDEN GRID (`g20.sv` + `gridcen20.sh` + `r10buvm20cen`)

One Surelog run over a source that crosses **home** (package free function /
class in-body method / class out-of-body prototype+definition / task) ×
**written type** (bare same-package typedef / package-QUALIFIED / builtin) ×
**typedef kind** (`logic signed [P-1:0]` / `bit [7:0]` / `int` / enum / packed
struct) × **site** (return type / formal / local var / class property /
BODY-LOCAL return variable) × **view** (`uhdmallPackages` / `uhdmtopPackages`).
Golden's answer (`kind(name)[alias->kind(name)] rg=[bound] sg= inst=`):

| site \ written | bare same-package typedef | package-QUALIFIED |
|---|---|---|
| free package fn RETURN | `logic_typespec(bs_t)[alias->logic_typespec(gp20::bs_t)]`, DEF **symbolic** / ELAB **folded** | `logic_typespec(gp20::bs_t)[noalias]`, **folded in BOTH** |
| free package fn BODY-LOCAL | the same clone, TWO objects: one symbolic, one folded | the shared object, `[noalias]`, folded |
| class OOB method RETURN | `logic_typespec(bs_t)[alias->…]`, **folded** | — |
| class OOB method BODY-LOCAL | the same clone, **ONE object, folded** | — |
| class IN-BODY method RETURN | `logic_typespec(bs_t)[alias->…]`, folded | — |
| class IN-BODY method BODY-LOCAL | **no object at all** | — |
| class method FORMAL (`io_decl`) | `logic_typespec(bs_t)[alias->…]`, folded | `logic_typespec(gp20::bs_t)[noalias]`, folded |
| class method LOCAL var | `logic_typespec(bs_t)[alias->…]`, folded | `logic_typespec(gp20::bs_t)[noalias]`, folded |
| class PROPERTY | `logic_typespec(bs_t)[alias->…]`, folded | `logic_typespec(gp20::bs_t)[noalias]`, folded |
| package TASK formals | `logic_typespec(bs_t)[alias->…]`, DEF symbolic / ELAB folded | — |

Typedef-kind axis on the RETURN site, all package-homed and written bare:
`bit [7:0]` → `bit_typespec(b8_t)[alias->bit_typespec(gp20::b8_t)]`;
`int` → `int_typespec(i_t)[alias->int_typespec(gp20::i_t)]`;
**enum** → `enum_typespec(gp20::e_t)[noalias]` **shared**;
**packed struct** → `struct_typespec(gp20::s_t)[noalias]` **shared**.
(The same aggregate-vs-scalar split buvm18 measured for parameters.)

Three-way verdicts on that grid (`gridcen20.sh <arm> <pris> <pat>`):

```
-- CELLS 75  same 59  CONVERTED 1  OVER-FIRE 0  MOVED-STILL-WRONG 1  residue 14
```

The single `MOVED-STILL-WRONG` is the DEFPKG twin of the converted cell —
golden has **no row at that key at all** (it holds ONE object where we hold
two), and the twin moved to the shape golden's single object has.  Of the 14
residues, 8 are copy-count / location artefacts whose VALUES are identical
(golden lists an out-of-body method at its PROTOTYPE's location, we at the
DEFINITION's; neither is a field `Compare` reads) and 6 are residue **R1**.

## 4. DECODED FROM SURELOG

The clone is minted by `CompileHelper::compileTypespec`
(`src/DesignCompile/CompileType.cpp:880-896`), in the `while (dt)` resolution
walk of a NAMED type reference:

```cpp
} else if (const SimpleType* sit = datatype_cast<const SimpleType*>(dt)) {
    result = sit->getTypespec();
    if (parent_tpd && result) {                       // reached VIA a TypeDef
      ElaboratorContext elaboratorContext(&s, false, true);
      if (typespec* new_result = any_cast<typespec*>(
              UHDM::clone_tree((any*)result, &elaboratorContext))) {
        if (new_result->Typedef_alias() == nullptr) { … }
        new_result->Typedef_alias()->Actual_typespec(result);
        result = new_result;                          // ONE CLONE PER REFERENCE
      }
    }
```

and the BARE name comes for free: a plain vector typedef in a package is built
by `CompileHelper::compileTypeDef` (`CompileHelper.cpp:1055-1097`), whose
`else` branch calls `ts->VpiName(name)` with the **bare** identifier and
`simple->setTypespec(ts)` — it never calls `newTypeDef->setTypespec(...)`, which
is exactly why the walk above falls past the `TypeDef` arm (`parent_tpd->
getTypespec()` is null) into the `SimpleType` arm that clones.  The QUALIFIED
name is stamped much later, at write time, by
`UhdmWriter::writeDataTypes` (`UhdmWriter.cpp`):

```cpp
if (parent->UhdmType() == uhdmpackage) {
  if (tps && (tps->VpiName().find("::") == std::string::npos))
    tps->VpiName(StrCat(parent->VpiName(), "::", tps->VpiName()));
}
```

— so the **listing object** ends up `uvm_pkg::uvm_bitstream_t` and every clone
taken before that keeps `uvm_bitstream_t`.  This is the same mechanism buvm18
decoded for parameters, one site over.  The FOLDED `INT:4095` is
`UVM_STREAMBITS-1` reduced by `ExprEval` in every view but the typedef's own
home-package DEF listing (§ `pkgTdRangeViewFold18`), and the out-of-body
method's body-local clone is not IN that listing — measured, not assumed:
golden holds ONE object and it is folded.

## 5. THE PRODUCER, AND WHAT WAS ACTUALLY WRONG

`UhdmExporter::drainFuncRet`, `src/ModuleEmit.cpp`, the
`ts->UhdmType() == uhdmlogic_typespec` arm.  Two lines were load-bearing:

1. **the scope test** — `sub.getParentScope() == sc1` is TRUE only for a
   package FREE function; for `uvm_packer::unpack_field` the parent scope is the
   `ClassType`.  The new arm walks up through `ClassType` /
   `GenericClassDef` scopes exactly as `sameScopePkgFn9` does in
   `TaskFuncEmit.cpp`, and records whether it had to.
2. **the fold test** — `topPf0` is membership of `pf.inst` in `pkgTopMap`, and
   a class method's listing owner is the `class_defn`, so `topPf0` was FALSE in
   **both** views and both copies came out symbolic.  When the walk passed
   through a class, the clone folds unconditionally.  This is not a guess: the
   DEF package listing is walked FIRST (`design::Compare`: `AllPackages`, then
   `TopPackages`, then `AllClasses`) and `CompareContext::m_visited` is keyed on
   the **LHS**, so golden's single object is judged exactly once, against our
   first-reached copy.

Nothing else moved: `sameScope0`'s free-function behaviour, the `$unit` arm,
the aggregate arm, the `bit` arm (§ `retVarTdViewFold19`) and the qualified-name
arm are all reached by the same code as before.

## 6. THE CORPUS CENSUS (`r10buvm20cen`, `BuildUVMPkg`, both modes)

One row per typespec SITE — `RET` (function `vpiReturn`), `IO` (`io_decl`),
`LOC` (subroutine local), `PROP` (class property) and `RETLOCAL` (the
body-local return variable this pass is about) — keyed
`view|owner-fullname|site|line:col`, valued
`kind(name)[alias->kind(name)] rg=[bounds] sg= inst=`.  Multiset join, three
ways (golden / pristine / patched):

```
same 8949   CONVERTED 2   OVER-FIRE 0   MOVED-STILL-WRONG 2   residue 3850
CONVERTED   ELABPKG|uvm_pkg::uvm_packer::unpack_field::unpack_field     |RETLOCAL
CONVERTED   ELABPKG|uvm_pkg::uvm_packer::unpack_field_int::unpack_field_int|RETLOCAL
```

The two `MOVED-STILL-WRONG` are the DEFPKG twins of those same two cells, at a
key golden has **no row for** (`G=None`); they moved to the shape of golden's
single object.  The 3850 residues are PRE-EXISTING and untouched by this pass
(`O == P` in every one): 2780 `IO` + 949 `RET` of them are the known
class-method `vpiInstance` family (golden `inst=package(uvm_pkg)`, ours
`inst=-`), which is masked behind this head and is not this law's window.

### THE MOVER SET, PREDICTED BY NAME FIRST

`r10buvm20pred` + `predict20.sh` read ONLY the GOLDEN databases (independent of
both our binaries) and list every (test, mode) whose golden carries the law's
shape — a `ref_typespec` on a `variables` whose parent is a `ref_obj`, actual a
`logic_typespec`, fullname `pkg::class::method::method`.  Run on the PRISTINE
workdirs, before the patched sweep was looked at:

```
surelog:  22 tests / 42 (test,mode) pairs
          AmiqEth AmiqSimpleTestSuite BuildOVMPkg BuildUVMPkg CoresSweRV
          CoresSweRVMP Driver Ibex IbexGoogle MiniAmiq Monitor Opentitan
          OVMSwitch Scoreboard SeqDriver SimpleClass1 SimpleInterface
          SimpleOVM SimpleUVM UnitAmiqEth UVMNestedSeq UVMSwitch
u2r:      0 tests, 0 cells   ← THE FENCE: no u2r CMP_EQUAL row can move
```

Intersected with "produces a database at all" (the other 17 are `SLANG_REJECT`
or `SURELOG_FAIL` in both modes) the prediction is exactly

```
BuildUVMPkg×2  MiniAmiq×2  SeqDriver×2  SimpleUVM×2  Scoreboard/default   = 9
```

and `byteverify SELFCHECK=1` reports **`MOVERS: 9 / 956`** — that exact set,
**zero unpredicted movers**.  All nine were already `CMP_NOTEQUAL` rows;
**no `CMP_EQUAL` row moved in either corpus.**

`Scoreboard/default` is the known ~50/50 COIN, so it was NOT taken on trust: the
ORDER-BLIND diff (both dumps sorted, workdir paths normalised) is **185 lines**
and carries `|vpiTypedefAlias:` — the law's own lines — so it is a REAL mover.
`MiniAmiq`, `SeqDriver` and `SimpleUVM` give the same 185-line order-blind
signature with 4 `vpiTypedefAlias` lines each (2 cells × 2 views).

The `BuildUVMPkg` whole-dump diff (banner- and path-normalised) is **20 removed
/ 173 added lines, every one of them inside the two cells this law names**
(`unpack_field` / `unpack_field_int` body-local return typespecs): the
qualified shared reference replaced by a bare-named clone, its alias ref, its
folded twin and the folded bound.

## 7. THE GATES (all run in this worktree, both binaries frozen `chmod 555`)

| gate | result |
|---|---|
| 1. build both, md5 | pristine `7aa2538c15f50452f39416bd6e2036e3`, patched `ac97b47aa254cc61c5598ec872194560` |
| 2. goldens | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` → **23 FAIL** (negative control), `SLANG_UHDM` exported per binary |
| 3. u2r testflags vs committed `gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** (679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`) |
| 3. u2r testflags + default vs the PRISTINE sweep taken first in this worktree | **PASS, 0 differing rows** both modes |
| 4. surelog `--mode both` vs committed `results/golden_surelog.csv` | **PASS, 0 differing rows over 1588**, status AND dump.  **NO ROW CONVERTED.** |
| 4. surelog vs the PRISTINE sweep | **PASS, 0 differing rows** |
| 5. byteverify `SELFCHECK=1`, u2r | `MOVERS: 0 / 1358`, selfcheck 1357/1358 |
| 5. byteverify `SELFCHECK=1`, surelog | `MOVERS: 9 / 956`, all 9 predicted BY NAME first; selfcheck 955/956 |
| canaries | `canaries.sh` `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2.sh` PASS on both; `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` **byte-identical** both modes; `SVSwitch` `4842211c4030`; `YosysVerx` `6ccda350c24a` |
| boundary | `PROCESSED=2909 == LISTED=2909`, rejects symmetric (128 == 128, **no asymmetric reject**), **DIFFER=1** — `r10buvm20repro/g20.sv`, this pass's own grid arm and its POSITIVE CONTROL (proof the gate can see) |

The PRISTINE sweep is byte-identical to both committed baselines, so there is no
drift to report this pass.  Every `cmds.txt` in all four sweep workdirs names
exactly one slang binary (`/tmp/r10buvm20_bin/pris.bin` or
`/tmp/r10buvm20_bin/pat.bin`) — audited by PATH, not by the string
`slang-uhdm`.

Every bind-window arm in the tree (buvm3-19, uvm82-95, sd8-12,
§ `classArgBind12`, § `retNameRecvCollapseArgsBindLikeBody15`,
§ `collArgNamedBlkLocalNoBind15`, § `controlBodyNoBind28`,
§ `blkLocalSameCtrlDepthArgBinds57/64`, § `pkgVarBindsOnlyThroughInstance88`,
§ `formalDefaultBindsLikeBody13`, § `classInBodyRecvCallArgNoBind52`,
§ `superNewFormalBinds28`, § `newArrayArgNoBind16`,
§ `foreachElabLoopVarAnyKindBinds17`, § `pkgParamBareTdNamedClone18`,
§ `foreachArraySelfSelectAssignDropsTs19`) is untouched by construction: this
law changes ONE naming/fold decision on ONE typespec clone and never goes near
`lateBinding`, `Actual_group` or any listing kind.

## 8. RESIDUES

**R0 — THE NEW HEAD (BuildUVMPkg, both modes, 29 cmp lines `2>&1` / 15 on
stderr, md5 `6e1067f47e20`, 1 head).**

```
LHS:
io_decl: (severity), id:129936, line:30000:50, endln:30000:58
|vpiParent:  \_function: (uvm_pkg::uvm_default_report_server::incr_severity_count), id:129935
|vpiDirection:1
|vpiName:severity
|vpiTypedef:  \_ref_typespec: (…::incr_severity_count::severity), id:129937
                |vpiActual: \_enum_typespec: (uvm_pkg::uvm_severity), id:2737
RHS: <null>
```

`LHS` set with `RHS: <null>` is `BaseClass.h:190`'s SINGULAR arm
(`lhs != nullptr && rhs == nullptr`, `m_failedLhs` only), so it names a VALUE.
It is NOT a vector: `io_decl`'s only vector is `Ranges()`, and golden's is
`<null>` here too (measured); `task_func::Io_decls` would have printed the
FUNCTION as owner, and both sides' vectors are size 1 with no null element
(measured over all 5275 subroutines in each database).  The one singular slot an
`io_decl` can fill is **`ref_obj::Actual_group`** — and that is exactly where it
is:

```
uvm_pkg.sv:30000  function void incr_severity_count(uvm_severity severity);
uvm_pkg.sv:30001    m_severity_count[severity]++;
```

golden's `ref_obj (…::incr_severity_count::severity)` at `30001:22`, whose
`vpiParent` is a **`bit_select`** (the INDEX of `m_severity_count[severity]`),
binds the formal's `io_decl` as its `Actual_group`; **ours leaves it NULL**
(both measured with `p7`/`p8` in `/tmp/r10buvm20_*`).  A bind-window law at the
`bit_select` INDEX position — next pass's target.

**It is not a regression.**  The whole-dump diff of the pristine and patched
`BuildUVMPkg` databases is 20 removed / 173 added lines, all inside the two
cells this law names; the head region is untouched between the two binaries.
R0 was simply MASKED by the head this pass cleared.

**R1 — a PACKAGE-QUALIFIED written reference should SHARE, and we clone.**
Grid `free_ret_q` / `formals::f2` / `l2` / `prop2`: golden keeps the shared
package object (`logic_typespec(gp20::bs_t)[noalias]`, folded) wherever the type
is written `gp20::bs_t`, and we mint the bare clone with an alias — the exact
mirror of buvm18's `writtenBare18` gate, which exists for PARAMETERS only.
6 grid cells.  **Corpus-invisible today: 0 cells in `BuildUVMPkg`** (measured —
`uvm_pkg` never writes its own typedefs package-qualified inside itself), which
is why it is left as a residue rather than folded into this pass.

**R2 — we mint TWO body-local return variables per out-of-body method where
golden mints ONE.**  Identity and object COUNT are not fields `Compare` reads,
and `m_visited` is keyed on the LHS, so the second copy is invisible to the
judge; both now carry the same shape.  2 cells on `BuildUVMPkg`, 1 on the grid.

**R3 — the class-method `vpiInstance` family.**  2780 `io_decl` + 949 `RET`
cells on `BuildUVMPkg` where golden carries `vpiInstance -> package uvm_pkg` and
we carry none.  PRE-EXISTING (identical in both binaries), currently masked.

## 9. THE INSTRUMENTS

| file | what it is |
|---|---|
| `r10buvm20cen.cpp` / `build20.sh` | the subroutine-site typespec census: one row per RET / IO / LOC / PROP / **RETLOCAL** site, keyed (view, owner fullname, site, line:col), valued kind(name)[alias->kind(name)] + the packed-bound ENCODING (folded constant vs symbolic tree) + `VpiSigned` + `vpiInstance`.  The `RETLOCAL` site is new and is the only one that can see this head. |
| `r10buvm20pred.cpp` / `predict20.sh` | the a-priori mover prediction, from the GOLDEN databases only |
| `g20.sv` / `gridcen20.sh` | the golden grid of § 3 and its three-way verdicts |
| `sweeps20.sh` | both corpora, both modes, ONE named binary, into a workdir this pass owns (cmds.txt audited by PATH) |
| `bound20.sh` | the boundary gate (fd-3 arm list, children `</dev/null`, PROCESSED asserted, subdirectories included, banner normalised) |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `byteverify.sh` `rowheads.sh` | carried forward UNCHANGED from `r10buvm19repro` (md5-verified identical) |

**Two traps this pass paid for, recorded so the next one does not:**

* **`uhdm-cmp` prints the SAME text to stdout and stderr**, so the pinned cmp
  md5s in the campaign's write-ups (`23df339e1b17`, 152 lines) are the `2>&1`
  MERGE, while a `2>` capture alone gives half the lines and a different hash.
  Check which one a brief means before reporting "the pin missed".
* **there are two `surelog` binaries on this machine.**  `~/git-repos/sv-tests/
  third_party/tools/Surelog/build/bin/surelog` (what the `surelog` shell alias
  resolves to) writes databases that make `uhdm-dump` print
  `Internal Error: adding wrong object type … in a actual_group group!` and then
  SEGFAULT.  `verify_golden.py` uses `~/git-repos/Surelog/build/bin/surelog`;
  every golden in this directory does too.
