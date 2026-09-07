# r10uvm187 — § `pkgScalarTdParamDefDefer187` — **A PACKAGE LISTING EMITS ITS PARAMETERS BEFORE ITS TYPEDEFS, SO A SCALAR-TYPEDEF'D PARAMETER MUST DEFER ITS TYPESPEC** — the BuildUVMPkg ×2 48-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list — the wide boundary compiles `tools/probe` arms
exclusively and dispatches no corpus test at all.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `362dcfa0` |
| pristine binary | md5 `8b1777950b91feef705565e6f16e8b0a`, built from this pass's OWN worktree at a clean `362dcfa0` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own binary at that commit** |
| patched binary | md5 `b15c4f042d5928e133f3bde9806352c4`, frozen `chmod 555` |
| production surface | `src/ParamEmit.cpp` (the predicate + two call sites), `include/UhdmExporter.h` (its declaration) |
| probe surface | `tools/probe/r10uvm187repro/` only |

---

## READ THIS FIRST — the numbers

| | pristine | patched |
|---|---|---|
| `BuildUVMPkg` cmp lines, default / testflags | **48 / 48** | **36 / 36** |
| `BuildUVMPkg` heads (`grep -c '^LHS:'`) | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp md5, both modes | `df87bde51760` | `7f92233e04ae` |
| head object | `int_typespec(UVM_FILE)` vs an anonymous `int_typespec` | a **different object**: `enum_const(UVM_DEEP)` (**R0**) |
| the other twelve head-set cmp logs | — | **byte-identical between the two binaries** |
| grid cells, seven arms | 99 match | **122** — **TO-GOLDEN 23, AWAY-GOLDEN 0, CHANGED-STILL-WRONG 0** |
| `BuildUVMPkg` parameter census (89 cells × 2 modes) | 79 match | **82** |
| the face, whole corpus | 6 cells (BuildUVMPkg ×2) | **0** |
| byte movers | — | **3 / 956** surelog (BuildUVMPkg ×2 **predicted by name first**, + 1 PROVEN COIN), **0 / 1358** u2r |
| boundary | — | 5052 listed = 5052 processed, **5 moved arms** (4 this pass's own, 1 an earlier pass's grid that moves TO-GOLDEN 3 / AWAY 0) |

---

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

`/tmp/r10uvm187_wd/heads_pris/BuildUVMPkg.default.cmp`, 48 lines, md5
`df87bde51760`, `grep -c '^LHS:'` = 1, byte-identical to the testflags log —
read before a line of code was written:

```
LHS:
int_typespec: (UVM_FILE), id:62665, line:8459:9, endln:8459:12
|vpiParent:        \_parameter: (uvm_pkg::UVM_STDIN), id:62667, line:8461:20, endln:8461:29
|vpiName:UVM_FILE
|vpiTypedefAlias:  \_ref_typespec: (uvm_pkg::UVM_STDIN::UVM_FILE), id:62666
                     |vpiFullName:uvm_pkg::UVM_STDIN::UVM_FILE
                     |vpiActual: \_int_typespec: (uvm_pkg::UVM_FILE), id:62664, line:8459:9, endln:8459:12
|vpiInstance:      \_package: uvm_pkg, id:60163
|vpiSigned:1
RHS:
int_typespec: , id:197, line:8461:11, endln:8461:19
|vpiParent:        \_parameter: (uvm_pkg::UVM_STDIN), id:192, line:8461:20, endln:8461:29
|vpiInstance:      \_package: uvm_pkg, id:2
|vpiSigned:1
```

The source (`1800.2-2017-1.0/pp_output/uvm_pkg.sv`, `package uvm_pkg` spans
7351–83263):

```
8459  typedef int UVM_FILE;
8461  parameter UVM_FILE UVM_STDIN  = 32'h8000_0000;
8462  parameter UVM_FILE UVM_STDOUT = 32'h8000_0001;
8463  parameter UVM_FILE UVM_STDERR = 32'h8000_0002;
```

### 1.1 THE LADDER — which field fails, and what comes after it

Read out of the generated `Compare`s, not guessed
(`~/git-repos/UHDM/build/generated/src/`):

| step | reader | golden | ours | verdict |
|---|---|---|---|---|
| 1 | `BaseClass::Compare` `VpiType` | `int_typespec` | `int_typespec` | equal |
| 2 | `BaseClass::Compare` **`VpiName`** | `UVM_FILE` | *(empty)* | **FAILS FIRST** |
| 3 | `BaseClass::Compare` `VpiDefName` | empty | empty | — |
| 4 | `typespec::Compare` `VpiName` | (same field again) | | |
| 5 | `typespec::Compare` `Typedef_alias` | a `ref_typespec` | `<null>` | next |
| 6 | `typespec::Compare` `Instance` | `package uvm_pkg` | `package uvm_pkg` | equal |
| 7 | `int_typespec::Compare` `Cast_to_expr` | null | null | equal |
| 8 | `int_typespec::Compare` `VpiSigned` | 1 | 1 | equal |
| 9 | `int_typespec::Compare` `Ranges` | none | none | equal |

`ref_typespec::Compare` reads `VpiName`, `VpiDefName`, then `Actual_typespec` —
it does **not** read `VpiFullName`, so the `uvm_pkg::UVM_STDIN::UVM_FILE`
string on the alias ref is dump-only and the judge lands on the alias TARGET.

### 1.2 THE ALIAS TARGET'S IDENTITY AND SHARERS (`sh187.cpp`, on the golden DB)

```
golden  int_typespec id=62664  VpiName 'uvm_pkg::UVM_FILE'  @8459:9-8459:12
        parent=package   alias=no   inst=yes   sharers=10        <- the ELAB listing's object
golden  int_typespec id=2909   VpiName 'uvm_pkg::UVM_FILE'  @8459:9-8459:12
        parent=package   alias=no   inst=yes   sharers=41        <- the DEF listing's object
golden  three per-parameter CLONES per listing (ids 2910/2926/2942 and
        62665/62681/62697): VpiName 'UVM_FILE', parent=parameter, alias=yes,
        inst=yes, sharers=2
```

So the shared typedef object is package-parented and **qualified-named**
(`uvm_pkg::UVM_FILE`), while each clone is parameter-parented and **bare-named**
(`UVM_FILE`) — the two names are different strings and the judge reads both.
After the patch our database carries the same six clones (ids
177833/177835/177837 and 177969/177971/177973, `parent=parameter alias=yes
sharers=2`) and our own shared objects at `sharers=10` (ELAB, equal to golden)
and `5` (DEF, against golden's 41 — a **sharing fan-out**, which no generated
`Compare` reads because none of them reads `VpiParent` and a shared LHS is
judged once).

---

## 2. THE LAW

> **§ `pkgScalarTdParamDefDefer187`** — a `parameter` / `localparam` homed in a
> package and written with the **bare name** of a **scalar** typedef homed in
> that same package must have its typespec built **after** the package's
> typedefs, not before them. § `pkgParamBareTdNamedClone18` already mints the
> per-declaration NAMED CLONE for that shape; it could not fire in the
> package's own DEF listing because the clone aliases `typedefTs[<typedef>]`
> and **a package listing emits its parameters BEFORE its typedefs**. Routing
> the parameter through the existing `pendingDefParamTs` / `drainDefParamTs`
> deferral — and keeping it off that drain's *share* shortcut, exactly as the
> vector-typedef case already is — makes the DEF listing mint the clone the
> ELAB listing already minted.
>
> The deferral is gated to the three shapes § 18 can mint (`int` / `byte` /
> scalar `bit`), to a **bare-written** reference, to the typedef's **own home
> package**, and **not** to an alias-of-alias.

### 2.1 SURELOG, the producer

`CompileHelper::compileParameterDeclaration` (`CompileHelper.cpp:3442`, regular-
param arm at `:3545`) calls `compileTypespec` **once per `Param_assignment`,
per compile**, so every listing gets its own answer.

`compileDatastructureTypespec` (`CompileType.cpp:850-900`) walks the DataType
chain, recording `parent_tpd` at the TypeDef, and the clone is minted in **one
branch only** — the `SimpleType` one:

```cpp
} else if (const SimpleType* sit = datatype_cast<const SimpleType*>(dt)) {
  result = sit->getTypespec();
  if (parent_tpd && result) {
    ElaboratorContext elaboratorContext(&s, false, true);
    if (typespec* new_result = any_cast<typespec*>(
            UHDM::clone_tree((any*)result, &elaboratorContext))) {
      if (new_result->Typedef_alias() == nullptr) { ...MakeRef_typespec()... }
      new_result->Typedef_alias()->Actual_typespec(result);
      result = new_result;
    }
  }
  break;
```

That single `if (parent_tpd && result)` is the whole rule, and it explains
every face of the grid:

| golden face | why |
|---|---|
| scalar / vector typedef → **per-declaration NAMED CLONE + alias** | the walk ends at `SimpleType` with `parent_tpd` set |
| **enum** typedef → shared, no clone | the `Enum` branch (`CompileType.cpp:874`) returns `en->getTypespec()` and `break`s before `SimpleType` |
| **struct / union** typedef → shared, no clone | same, the `Struct` / `Union` branches |
| **typedef OF a typedef** → shared, and the alias hangs off the SHARED object | `compileTypeDef` (`CompileHelper.cpp:1019-1026`) gave that TypeDef its own typespec, so the walk breaks at the `TypeDef` branch (`CompileType.cpp:852-856`) |
| **package-QUALIFIED** reference (`gp::i_t`) → shared, no clone, no alias | a different arm entirely (§ 18's measured grid) |

### 2.2 OUR EMITTER, and what was actually wrong

`makeParamTs`'s § 18 arm (`src/ParamEmit.cpp` ~17325) is unchanged and was
already right — in the ELABORATED listing. In the package's **own DEF
listing** it aliases `typedefTs[<the typedef>]`, and that map is still empty
when the DEF listing emits its parameters. `emitPackage` orders parameters
before typedefs, which is exactly why `deferAggTs` (`src/ParamEmit.cpp` ~14549)
already existed and already deferred

* `PackedStructType` / `PackedUnionType` / `EnumType` typedef'd parameters, and
* integral `PackedArrayType` (vector) typedef'd parameters,

past `emitTypedefs` through `pendingDefParamTs` → `drainDefParamTs`. A
**scalar** typedef'd parameter was not in that list. `shared18` came back null,
§ 18's kind gate declined, and the DEF listing fell through to the anonymous
`int_typespec` anchored at the parameter's own type token.

Two edits, both one-term:

1. `deferAggTs |= pkgScalarTdParamDefDefer187(ps)` beside the existing
   `namedPackedDimParamAlias` term.
2. In `drainDefParamTs`, `&& !scalarTdClone187` on **both** share shortcuts
   (`topPkgView && !vectorAlias …` and `typedefTs.find(&dt0) … && !vectorAlias
   && !bareAggPkgTd`), for the same reason the vector case is fenced off them:
   this parameter is deferred so it can **clone**, not so it can share.

**Both edits are load-bearing and each cost a build.** Without (2) the drain
handed the parameter the package's own listing object and **five cells that were
already right in the ELAB view went AWAY** (`gp187::P_I` / `L_I` / `P_BY` /
`L_BY` / `P_B1`: `int_typespec(gp187::i_t) apar=package [noalias]`). Without the
alias-of-alias fence inside the predicate, `gp187::P_I2` moved from one wrong
answer to another (**CHANGED-STILL-WRONG 1**).

---

## 3. THE GRID — `grid187.sv`, `probe0.sv`, `grid187/g187_*.sv`, `ct187cen` + `score187.py`

Full output: `GRIDS.r10uvm187.txt`. The CELL is one `parameter` keyed on
(view, owning scope's full name, parameter name, its own `line:col`,
`PARAM`/`LOCAL`); the VALUE is its typespec actual decoded as
`kind(VpiName)@span[alias->kind(VpiName)@span] rg= sgn= apar= inst= nsh=` —
every field there except `apar`/`nsh` is one a generated `Compare` reads. Keys
are joined as a **multiset** and both one-sided sets are printed
(`ONE-SIDED-KEY=0` everywhere).

| arm | cells | match before | match after | TO-GOLDEN | AWAY | STILL-WRONG |
|---|---|---|---|---|---|---|
| `grid187.sv` | 53 | 23 | 28 | 5 | 0 | 0 |
| `probe0.sv` | 10 | 6 | 10 | 4 | 0 | 0 |
| `grid187/g187_a_order.sv` | 16 | 9 | 16 | 7 | 0 | 0 |
| `grid187/g187_b_negative.sv` | 16 | 8 | 8 | 0 | 0 | 0 |
| `grid187/g187_c_homes.sv` | 5 | 0 | 0 | 0 | 0 | 0 |
| `grid187/g187_d_scalarkinds.sv` | 20 | 4 | 8 | 4 | 0 | 0 |
| `r10buvm18repro/grid18.sv` (an EARLIER pass's committed arm) | 111 | 49 | 52 | 3 | 0 | 0 |
| **total** | **231** | **99** | **122** | **23** | **0** | **0** |

### 3.1 GOLDEN'S ANSWER, by scope × typedef kind × parameter/localparam × view

Measured on `grid187.sv` (one Surelog run). "CLONE" = a per-declaration
`kind(<bare typedef name>)` anchored at the TYPEDEF's own type token, with
`Typedef_alias` → this view's shared object; "SHARE" = the shared object itself,
package-parented and qualified-named, with no alias.

| declared type | package home, bare | module home, own td | class home | `pkg::`-QUALIFIED |
|---|---|---|---|---|
| `typedef int` | **CLONE** both views | **CLONE** | **CLONE** | SHARE |
| `typedef byte` | **CLONE** both views | — | — | — |
| `typedef bit` (scalar) | **CLONE** both views | — | — | — |
| `typedef shortint` / `longint` / `integer` | **CLONE** both views | — | — | — |
| `typedef logic` (scalar) | **CLONE** both views | — | — | — |
| `typedef string` / `real` / `time` | **CLONE** both views | — | — | — |
| `typedef bit [7:0]` / `logic [7:0]` / `bit [NB-1:0]` | **CLONE** both views | **CLONE** | **CLONE** | SHARE |
| enum typedef | SHARE | — | — | — |
| packed-struct typedef | SHARE | — | — | — |
| typedef OF a typedef | **SHARE** (the alias rides the shared object) | — | — | — |
| written builtin (`int`, `bit [7:0]`) / untyped | anonymous, no alias | — | — | — |

`parameter` vs `localparam` is **IRRELEVANT** on every row that was gridded
both ways (`P_I`/`L_I`, `P_BY`/`L_BY`, `P_B8`/`L_B8`, `D_INT`/`D_INTL`,
`HM_P`/`HM_L`), and so is the initialiser shape (literal, negative literal,
sized literal, another parameter, `q9 + 1`).

### 3.2 WHAT THIS PASS MOVES, AND WHAT IT DELIBERATELY DOES NOT

MOVES: the **DEF-listing** cell of a package-homed, bare-written, non-alias-of-
alias `int` / `byte` / scalar-`bit` typedef'd parameter or localparam. The ELAB
cell of that same shape was already right and stays right (`MATCH-KEPT`).

DOES NOT MOVE (all measured, all `WRONG-KEPT`, none touched):

* `shortint` / `longint` / `integer` / scalar `logic` / `string` / `real` /
  `time` typedefs — golden clones them in **both** views, § 18 declines them in
  **both**, so deferring them would change the path without changing the answer
  (`g187_d_scalarkinds`: 12 cells).
* module home, class home, generate-scope home (`g187_c_homes`: 5 cells).
* the negative faces — qualified reference, typedef-of-typedef, enum, struct,
  written builtin, untyped (`g187_b_negative`: 8 `WRONG-KEPT` + 8 `MATCH-KEPT`,
  **0 changed**).
* `typedef int` at **$unit** scope is a PRE-EXISTING slang-uhdm decline on both
  binaries (`unsupported constructs: typedef target: PredefinedIntegerType`,
  rc=4) and is therefore not gridded — an arm that cannot be scored is not an
  arm. Recorded as residue R3.

---

## 4. THE CENSUS — the nine UVM databases × both modes, and the whole corpus

`CENSUS.r10uvm187.txt` (`cen187.sh`). Nine of the eighteen (test, mode) pairs
produce a database at all; the other nine print `SKIP-NOFILE` and are COUNTED.

```
TEST             MODE        CELLS P-MATCH Q-MATCH FACE-P FACE-Q
BuildUVMPkg      default        89      79      82      3      0
BuildUVMPkg      testflags      89      79      82      3      0
SeqDriver        default       770     314     314      0      0
SeqDriver        testflags     770     314     314      0      0
SimpleUVM        default       275     106     106      0      0
SimpleUVM        testflags     275     106     106      0      0
Scoreboard       default       275     106     106      0      0
MiniAmiq         default       905     326     326      0      0
MiniAmiq         testflags     905     326     326      0      0
```

**Only `BuildUVMPkg` carries the face, and the census said so BEFORE the patched
sweep was built.** Why the uvm-1.2 rows do not: 1800.2 writes
`parameter UVM_FILE UVM_STDIN` against `typedef int UVM_FILE;`, while uvm-1.2
declares the same parameter UNTYPED —
`uvm-1.2/src/base/uvm_printer.svh:26  parameter UVM_STDOUT = 1;` — and the
SeqDriver golden's `UVM_STDOUT` cells are anonymous `int_typespec`s spanning the
whole declaration (`26:1-26:25`), nameless and unaliased, in every listing. Both
trees carry `typedef int UVM_FILE;` (uvm-1.2:313, uvm-1.1d:315,
1800.2 `src/base/uvm_object_globals.svh:669`); only the parameter's declaration
differs. **The shape is 1800.2-specific in this corpus for a SOURCE reason, not
a Surelog-version one.**

### 4.1 THE MOVER SET, PREDICTED BY NAME FROM PRISTINE DATABASES FIRST

`predict187.sh` joins `ct187cen` over each test's GOLDEN database and its
PRISTINE `slang.uhdm` and reports every cell whose golden side carries this
law's shape and whose ours side disagrees. Run before the patched sweep:

```
surelog     SCANNED=1573  SKIP=617  PREDICTED-CELLS=6
            BuildUVMPkg default   DEFPKG|uvm_pkg::|UVM_STDIN |8461:20|PARAM
            BuildUVMPkg default   DEFPKG|uvm_pkg::|UVM_STDOUT|8462:20|PARAM
            BuildUVMPkg default   DEFPKG|uvm_pkg::|UVM_STDERR|8463:20|PARAM
            BuildUVMPkg testflags   (the same three)
            PREDICTED-MOVER TEST NAMES: BuildUVMPkg
uhdm2rtlil  SCANNED=1462  SKIP=104  PREDICTED-CELLS=0
```

The same scan over the PATCHED sweeps reads **0 cells in both corpora**: the
face is closed corpus-wide.

The observed byte movers were exactly `BuildUVMPkg` × 2 plus the known
`Scoreboard/default` coin — see § 5.

### 4.2 THE WIDER FAMILY, for the residue ledger

`resid187.sh` drops every gate except "golden mints a per-declaration named
clone with an alias and we disagree", over all views and all typespec kinds:

| corpus | pristine | patched |
|---|---|---|
| surelog | 8 cells / 2 tests | **2 cells / 1 test** |
| uhdm2rtlil | 4 cells / 1 test | 4 cells / 1 test (untouched) |

The 6 that closed are this pass's. The 6 that remain are a **different law**
(a module-listing `logic_typespec` clone): `ParamSubstituteComplex` DEFMOD ×2
and `typedef_package` ELABPKG ×4 — residue R2.

---

## 5. THE GATES

Full output: `GATES.r10uvm187.txt`. Every gate was run in this pass's own
worktree, with `SLANG_UHDM` exported explicitly to each binary and every
`cmds.txt` audited by binary PATH (not by the string `slang-uhdm`, which also
matches `slang-uhdm-goldens/`).

| gate | result |
|---|---|
| 1. build both, md5 | pristine `8b177795…` (= the main tree at `362dcfa0`), patched `b15c4f04…` |
| 2. goldens | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| 3. u2r testflags | 679 / 50 / 2; ct8rows vs committed `gate_uhdm2rtlil.csv` **PASS, 0 differing rows** |
| 3. u2r testflags + default vs this pass's pristine sweep | **PASS, 0 differing rows** both modes |
| 4. surelog `--mode both` vs committed `golden_surelog.csv` | **PASS, 0 differing rows over 1588** |
| 4. surelog vs this pass's pristine sweep | **PASS, 0 differing rows** |
| 5. byteverify SELFCHECK=1, u2r | `MOVERS 0 / 1358`, selfcheck 1357/1358, PATH_SETS_IDENTICAL |
| 5. byteverify SELFCHECK=1, surelog | `MOVERS 3 / 956`, selfcheck 955/956, PATH_SETS_IDENTICAL |
| canaries | `ok=52 changed=0` (surelog), `ok=8 changed=0` (u2r) |
| ctcan2 | PASS both corpora |
| canaudit | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| boundary | `LISTED=5052 PROCESSED=5052 PRODUCED_DBS=4892 MOVED_ARMS=5 RC_DIFFS=0` |

### 5.1 EVERY MOVER, NAMED AND ATTRIBUTED

```
BuildUVMPkg/default    bbf172cd412b -> 3e9b187f5f57   PREDICTED BY NAME (3 cells)
BuildUVMPkg/testflags  bbf172cd412b -> 3e9b187f5f57   PREDICTED BY NAME (3 cells)
Scoreboard/default     6b7c9be975d8 -> 0d80f8f5d07e   THE KNOWN ~50/50 COIN
```

`Scoreboard/default` is attributed ORDER-BLIND, as the coin law requires:
`uhdm-dump` both databases, normalise the workdir path, **sort**, diff — the
only differing line is the dump's own header naming the input file, i.e. **0
content lines**. Unsorted the diff is 85 lines, the svunit_pkg `vpiTaskFunc`
order-flip signature. Its `uhdm-cmp` log is byte-identical on both binaries
(95 lines, one head) and its corpus row is byte-identical.

### 5.2 THE MUST-STAY FLOOR

The boundary compiled every `.sv`/`.v` in a COPY of the whole `tools/probe`
tree, top level and subdirectories, in both views, on both binaries. Four of
the five moved arms are this pass's own (`grid187.sv`, `probe0.sv`,
`grid187/g187_a_order.sv`, `grid187/g187_d_scalarkinds.sv`) — they are the
POSITIVE CONTROL; a gate reporting zero over them could not see. The fifth is
`r10buvm18repro/grid18.sv`, an earlier pass's committed grid, re-measured
against golden: **TO-GOLDEN 3 (`gp::P_I`, `gp::P_BY`, `gp::P_B1`, all DEFPKG),
AWAY-GOLDEN 0, CHANGED-STILL-WRONG 0**, 49 → 52 matching cells.

Every committed arm set the brief names as the floor is **byte-identical on both
binaries** (absent from `MOVERS`): `r10earl111repro` (6 arms, the
`modLocalIntTsFold111` int-whitelist arms), `r10uvm185repro` (5, the prototype
arms and both inheritance fences), `r10uvm170repro` (5, its arms and both
fences), `r10uvm181repro` / `r10uvm182repro` / `r10uvm183repro` /
`r10uvm184repro` (4 / 4 / 6 / 2), `r10uvm82repro` (7), `r10uvm91repro` (5),
`r10buvm3repro` (4), `r10buvm15repro` (9), `r10sd8repro` (37),
`r10sd12repro` (108). Both scoring columns are stated explicitly: **AWAY-GOLDEN
0 and MOVED-WRONG (CHANGED-STILL-WRONG) 0**, over all 231 grid cells and over
every committed arm.

---

## 6. THE HEAD AFTER — AND R0

```
BuildUVMPkg default and testflags, 36 cmp lines, ONE head each,
both cmp logs BYTE-IDENTICAL to each other (md5 7f92233e04ae)

uvm_pkg.sv:7932   UVM_DEEP  = 'h1 << 16   (in uvm_recursion_policy_enum)

LHS golden  enum_const: (UVM_DEEP) @7932:3-7932:31  |UINT:65536
            |vpiDecompile:1 << 16   |vpiSize:80
            parent enum_typespec(uvm_pkg::uvm_recursion_policy_enum) @21584:51
RHS ours    enum_const: (UVM_DEEP) @7932:3-7932:31  |INT:65536
            |vpiDecompile:1<<16     |vpiSize:64
            parent enum_typespec(uvm_pkg::uvm_recursion_policy_enum) @7930:1-7935:30
```

`enum_const::Compare` runs `basetype_t::Compare` (`expr::Compare`) first, which
reads **`VpiDecompile` before `VpiSize`** — so the first failing field is the
DECOMPILE STRING: golden renders the enum initialiser as `1 << 16` with spaces,
we render the source text `1<<16`. Behind it, in order, sit `VpiSize` (80 vs
64) and the value encoding (`UINT` vs `INT`).

**R0** — an enum constant's `vpiDecompile` is Surelog's own re-rendering of the
initialiser expression (spaced binary operators), not the source text, and its
`VpiSize`/value encoding follow the enum's base width rather than the literal's.
Decode the renderer (`ExprEval`/`decompile`) and the width rule together; the
`enum_typespec` parent's span (`21584:51-21584:76` vs our `7930:1-7935:30`)
is the same family's next question but is not a compared field here.

**R1** — the six scalar typedef kinds golden clones and § 18 declines
(`shortint`, `longint`, `integer`, scalar `logic`, `string`, `real`, `time`),
in BOTH listings. 12 grid cells; **0 corpus cells measured** in either corpus,
so the extension would be unscoreable on the corpus today.

**R2** — the module-listing `logic_typespec` half of the same family: 2 cells
in `ParamSubstituteComplex` (surelog, DEFMOD) and 4 in `typedef_package`
(uhdm2rtlil, ELABPKG). This is the whole remaining corpus population of "golden
mints a per-declaration named typespec clone and we do not".

**R3** — `typedef int` at **$unit** scope is a pre-existing slang-uhdm decline
(`unsupported constructs: typedef target: PredefinedIntegerType`, rc=4) on both
binaries; it cannot be scored on either side and is fenced out of the grid.

**R4** — golden's DEF-listing shared `uvm_pkg::UVM_FILE` object has 41 sharers
against our 5 (the ELAB pair agree at 10). A sharing fan-out, invisible to the
judge (no generated `Compare` reads `VpiParent`, and a shared LHS is judged
once); measured, not moved.

---

## 7. THE FILES

| file | what it is |
|---|---|
| `ct187cen.cpp` | the per-parameter typespec census (kind / name / span / alias / signed / ranges / parent / instance / sharers), over `AllPackages`, `TopPackages`, `AllClasses`, `AllModules`, `TopModules`, `AllInterfaces`, `AllPrograms`, plus class defns, task-func parameter lists and generate scopes |
| `score187.py` | the golden × pristine × patched multiset join and its verdict (`TO-GOLDEN` / `AWAY-GOLDEN` / `CHANGED-STILL-WRONG` / `WRONG-KEPT` / `ONE-SIDED-KEY`) |
| `predict187.sh` | the mover set, named from pristine databases only |
| `cen187.sh` | the per-row census table (the nine UVM databases × both modes) |
| `bound187.sh` | the wide boundary gate |
| `probe0.sv` | the head's own shape, reduced to eleven lines |
| `grid187.sv` | the main grid: scope × typedef kind × parameter/localparam × DEF/ELAB |
| `grid187/g187_a_order.sv` | names, case, numbers and listing order varied — the arm that TESTS rather than agrees |
| `grid187/g187_b_negative.sv` | the faces the law must not touch |
| `grid187/g187_c_homes.sv` | the homes the law does not claim |
| `grid187/g187_d_scalarkinds.sv` | every scalar typedef kind, minted and declined side by side |
| `GRIDS` / `CENSUS` / `PREDICT` / `BOUNDARY` / `GATES` `.r10uvm187.txt` | the recorded output of each |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the standing gates, copied verbatim so this directory's `canaudit.sh` can audit its own neighbours |
| `resid187.sh` | the wider-family residue scan (every gate dropped except "golden mints a per-declaration named clone and we disagree") |
| `sh187.cpp` | the alias target's identity and sharing fan-out, by `VpiName` |
