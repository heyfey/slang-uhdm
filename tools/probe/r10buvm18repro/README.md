# r10buvm18 — § `pkgParamBareTdNamedClone18` — **the 84-line BuildUVMPkg typespec head cleared: a package parameter written with a bare typedef name takes a NAMED CLONE of that typedef's typespec, not the untyped `int_typespec` default**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `0b35637` |
| worktree | `/tmp/wt_r10buvm18` |
| pristine binary | md5 `44fa483202b0522e0b04f1fc34b23a7f` (reproduced the main tree's byte-for-byte) |
| patched binary | md5 `34a8e17db6bedfb3f4fb2c1dff6d543d` |
| production surface | `src/ParamEmit.cpp` — ONE new arm at the head of `makeParamTs`, 111 added lines, 78 of them comment |
| probe surface | `tools/probe/r10buvm18repro/` only |
| deliverable | `/tmp/r10buvm18.patch`, applies clean on a FRESH `0b35637` |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines in both corpora and both modes.  What it
does is clear the head buvm17 handed over and close the typedef-typed
package-parameter typespec family.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines, default / testflags | **84 / 84** | **17 / 17** |
| `BuildUVMPkg` cmp md5, both modes | `551fe9a07afd` (the brief's pin, hit exactly) | `2bb940e8dd2d` |
| head object | `bit_typespec(uvm_field_flag_t)` vs a bare `int_typespec` | a `ref_typespec` on a `foreach` array `ref_var` that golden does not have (**R0**) |
| parameter-typespec census, BuildUVMPkg both modes | 44 / 164 cells match golden | **154 / 164** — **TO-GOLDEN 110, AWAY 0, CHANGED-STILL-WRONG 0** |
| the golden GRID (`grid18.sv`, 110 cells) | 25 match | **48** — **TO-GOLDEN 23, AWAY 0, CHANGED-STILL-WRONG 0** |
| byte movers | — | **2 / 956** surelog (BuildUVMPkg × 2 modes, both PREDICTED BY NAME first) + 1 PROVEN COIN, **0 / 1358** u2r |
| boundary gate | — | **2 differing arms / 2829**, both cells this law NAMES |

The other **ten** cmp logs of the seven-row head set are **byte-identical
between the two binaries**, and both `BuildUVMPkg` modes' logs are byte-identical
to each other on both binaries.

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

Read out of `/tmp/r10buvm18_wd/pris.both.cmp` (84 lines, md5 `551fe9a07afd`,
`grep -c '^LHS:'` = 1) before any code was written:

```
LHS:
bit_typespec: (uvm_field_flag_t), id:2174, line:7859:9, endln:7859:49
|vpiParent:        \_parameter: (uvm_pkg::UVM_PACK), id:2179, line:8001:28
|vpiName:uvm_field_flag_t
|vpiTypedefAlias:  \_ref_typespec: (uvm_pkg::UVM_PACK::uvm_field_flag_t), id:2178
                     |vpiActual: \_bit_typespec: (uvm_pkg::uvm_field_flag_t), id:1584
|vpiInstance:      \_package: uvm_pkg, id:1
|vpiRange:         \_range: id:2175  L=constant INT:27 @7859:14  R=constant UINT:0 @7859:47
RHS:
int_typespec: , id:177658, line:8001:11, endln:8001:27
|vpiParent:        \_parameter: (uvm_pkg::UVM_PACK), id:2850
|vpiInstance:      \_package: uvm_pkg, id:2745
```

BOTH sides are set and both are objects, so this is `BaseClass::Compare`'s
`VpiType` arm, not either `<null>` arm of `BaseClass.h:187-198`.  The SLOT is
`expr::Compare`'s last field (`expr.cpp:100`):
`SafeCompare(lhs->Typespec(), rhs->Typespec())` — `parameter` is a
`simple_expr` is an `expr`, and `parameter::Compare` runs `basetype_t::Compare`
FIRST, so the parameter's typespec is judged before its own
`VpiConstType`/`Expr`/`Ranges`/`VpiName`.  Both sides' `ref_typespec` matched
(it carries only `VpiFullName`, which Compare does not read), and the failure
is on its `Actual_typespec`.

### WHY `UVM_PACK`, AND NOT `UVM_COPY` (7993) OR `UVM_MACRO_NUMFLAGS` (7981)

The brief offered two hypotheses — Compare order, or the earlier parameters
already agreeing.  **BOTH ARE WRONG, and the answer is measured, not
reasoned**: `r10buvm18probe` compares every parameter pair of the package under
a fresh context and then re-runs the walk under ONE shared context.

* **Every one of the 27 `uvm_field_flag_t` parameters is equally wrong** in the
  pristine database — all 27 carry a bare `int_typespec`, in BOTH listings
  (see § 3).  Nothing about `UVM_PACK` is special.
* **The head is not reached through the parameters vector at all.**  The
  vector walk (`VECWALK` in the probe, replaying `scope::Compare`'s fixed field
  order under one context with the package pre-marked visited) stops at
  `uvm_pkg` **`Variables[2]`** — the package-level `array_var
  uvm_deferred_init` — which descends into the class graph and lands on
  `UVM_PACK`'s typespec long before `scope::Compare` ever reaches
  `Parameters[0]`.
* **And the head object is the ELABORATED listing's clone, not the DEF one.**
  `r10buvm18cen` prints the object id and the range shape: golden's
  `uhdmallPackages` clone is id 61573…62046 with a **symbolic** left bound
  (`operation@7859:14`), its `uhdmtopPackages` clone is id 1785…2174 with the
  **folded** `INT:27`.  The head prints `INT:27`, i.e. **id 2174 = the ELAB
  clone**, reached from the DEF package's variable.  Any framing that reads the
  head as "the def listing's UVM_PACK" is wrong.

The masking mechanism is worth stating because it will keep mattering:
`CompareContext::m_visited` is keyed on the **LHS** object and every generated
`Compare` returns 0 for an already-visited LHS.  A golden typespec that many
declarations SHARE is therefore judged ONCE and is invisible everywhere else —
which is exactly why the grid's `work@m MP/MB/ML` rows (golden shares one
package object with fan-out 19) never surface even though we emit an
`int_typespec` for them.

## 2. THE LAW

> **§ `pkgParamBareTdNamedClone18`** — a `parameter` / `localparam` HOMED IN A
> PACKAGE and declared with the **bare name** of a typedef homed in **that same
> package** does not take the untyped `int_typespec` default.  Surelog mints a
> **per-declaration NAMED CLONE** of the typedef's own typespec — `VpiName` =
> the typedef's bare name, `Typedef_alias` → a `ref_typespec` (fullname
> `<pkg>::<PARAM>::<typedef>`) → **this view's** shared typedef object,
> `vpiInstance` = **this view's** package — and the clone's packed-range bound
> follows § `pkgTdRangeViewFold18` exactly: SYMBOLIC in the typedef's own
> home-package DEF listing, REDUCED in every other view.
>
> The clone's KIND is the typedef's kind.  This arm implements
> `bit` / `int` / `byte`; `logic` already had its own arm, and enum / struct
> typedefs SHARE the package object with no alias at all.

**What is IRRELEVANT** (measured, § 3): the initializer shape — `(1<<k)`, a
plain literal, a sized literal, another parameter of the same typedef, an
expression, a cast, a concat — the `parameter`-vs-`localparam` keyword, and
whether the typedef's own range bound is a parameter or a literal.  **What is
NOT irrelevant**: how the type is WRITTEN.  A package-QUALIFIED reference
(`gp::bflag_t`) shares the package object with no clone and no alias.

## 3. THE GOLDEN GRID (`grid18.sv` + `gridcen18.sh`)

One Surelog run over a source that crosses declared type × home × initializer ×
`parameter`/`localparam` × DEF/ELAB.  Golden's answer, `r10buvm18cen` rows
(`kind(name)[alias->kind(name)] rg=N R[..] apar=.. inst=..`):

| declared type | package home | module home, OWN typedef | module home, `pkg::`-QUALIFIED |
|---|---|---|---|
| `typedef bit [NB-1:0]` | `bit_typespec(bflag_t)[alias->bit_typespec(gp::bflag_t)]` | `bit_typespec(loc_t)[alias->bit_typespec(loc_t)]` | `bit_typespec(gp::bflag_t)[noalias]`, **shared, fan-out 19** |
| `typedef bit [7:0]` | `bit_typespec(b8_t)[alias->…]` | — | — |
| `typedef logic [7:0]` | `logic_typespec(l8_t)[alias->…]` | `logic_typespec(locl_t)[alias->…]` | `logic_typespec(gp::l8_t)[noalias]` |
| `typedef int` | `int_typespec(i_t)[alias->…]` | `int_typespec(loci_t)[alias->…]` | `int_typespec(gp::i_t)[noalias]` |
| `typedef byte` | `byte_typespec(by_t)[alias->…]` | — | — |
| `typedef bit` (scalar) | `bit_typespec(b1_t)[alias->…] rg=0` | — | — |
| `typedef logic` (scalar) | `logic_typespec(l1_t)[alias->…] rg=0` | — | — |
| enum typedef | `enum_typespec(gp::e_t)[noalias]` **shared** | — | — |
| struct typedef | `struct_typespec(gp::s_t)[noalias]` **shared** | — | — |
| typedef OF typedef | `bit_typespec(gp::bflag2_t)[alias->bit_typespec(bflag_t)]` **shared alias object** | — | — |
| builtin `bit [7:0]` / `logic [7:0]` | `bit_/logic_typespec()[noalias]` with its own range | — | — |
| `int` / untyped | `int_typespec()[noalias]` | — | — |

Initializer axis, all on `bflag_t` in the package, **all identical**:
`(1<<8)`, `5`, `8'hAA`, `P_SHIFT`, `P_SHIFT+1`, `bflag_t'(3)`, `{4'h1,4'h2}`,
and the `localparam` row.

Bound-fold axis (the same clone, two listings):

| listing | left bound |
|---|---|
| `uhdmallPackages` (the typedef's own home DEF listing) | `operation@5:18` — SYMBOLIC |
| `uhdmtopPackages` | `constant INT:27 @5:18 sz64 ct7` — REDUCED at the LEFTMOST LEAF |
| every module view (def and elab), incl. wildcard-import copies | REDUCED |

`uvm_pkg` reproduces this exactly (`uvm_field_flag_t` = `bit
[UVM_FIELD_FLAG_RESERVED_BITS-1 : 0]`), and an UNTYPED bound parameter
(`parameter NBU = 28`) behaves identically to a typed one — a hypothesis this
pass tested and REFUTED before trusting the split.

## 4. THE PRODUCER, AND WHAT WAS ACTUALLY WRONG

`makeParamTs` (`src/ParamEmit.cpp`) already had a typedef-clone arm, but it sat
inside `ct.kind == SymbolKind::PackedArrayType` and was gated
`sharedTd->UhdmType() == uhdmlogic_typespec`.  A `bit` vector typedef therefore
fell straight through to the `int_typespec` default at the end of the function,
and an `int` typedef never even entered the branch (its canonical kind is
`PredefinedIntegerType`, whose switch has no `Int` case).  The new arm runs
BEFORE the kind arms, keyed on the SHARED TYPEDEF OBJECT's kind rather than on
slang's canonical kind, so it covers bit-vector, bit-scalar, int and byte
typedefs with one construction.

Two gate details cost a build each and are load-bearing:

1. **`pkgParamOwnDefView(ps)`, not `pkgTdOwnDefView(ta)`.**  The DEF listing's
   package parameters are built by the DEFERRED drain (`drainDefParamTs`),
   which runs after `emitPackage` has restored `curPkgEmitSym` and hands the
   "which listing am I" signal over through `paramTsOwnPkgDefView` — a signal
   only `pkgParamOwnDefView` reads.  Keyed on the typedef predicate, all 27
   DEF-listing clones folded a bound golden keeps symbolic.
2. **`ownPkgListing18`** — the ref prefix must start with the parameter's own
   package name.  A materialized WILDCARD-IMPORT copy is re-listed MODULE-side
   while `getParentScope()` still names the origin package; golden's copy there
   aliases a SECOND, BARE-NAMED clone, not the qualified shared object.  Without
   this test the grid reported **26 CHANGED-STILL-WRONG cells** in `work@mi`;
   with it, **23 TO-GOLDEN and nothing else moves**.

## 5. THE GATES (all run in this worktree, both binaries frozen `chmod 555`)

| gate | result |
|---|---|
| 1. build both, md5 | pristine `44fa4832…` (= main tree at `0b35637`), patched `34a8e17d…` |
| 2. goldens | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` → **23 FAIL** (negative control) |
| 3. u2r testflags vs committed `gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** (679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL) |
| 3. u2r testflags + default vs the pristine sweep | **PASS, 0 differing rows** both modes |
| 4. surelog `--mode both` vs committed `golden_surelog.csv` | **PASS, 0 differing rows over 1588** |
| 4. surelog vs the pristine sweep | **PASS, 0 differing rows** |
| 5. byteverify SELFCHECK=1, u2r | `MOVERS: 0 / 1358`, selfcheck 1357/1358 |
| 5. byteverify SELFCHECK=1, surelog | `MOVERS: 3 / 956`, selfcheck 955/956 — 2 predicted, 1 proven coin |
| canaries | `ok=52 changed=0` (surelog), `ok=8 changed=0` (u2r) |
| ctcan2 | PASS both corpora |
| canaudit | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr **byte-identical**; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| boundary gate | `PROCESSED=2829 LISTED=2829 DIFFER=2 PRIS_REJECT=127 PATCHED_REJECT=127` |

`verify_golden.py` and `tests/check_goldens.sh` were run with `SLANG_UHDM`
exported per binary, and every `cmds.txt` in both sweep workdirs names exactly
one slang binary (`/tmp/r10buvm18_pris.bin` or `/tmp/r10buvm18_pat.bin`) —
audited by path, not by the string `slang-uhdm`.

### THE MOVER SET, PREDICTED BY NAME FIRST

`predict18.py` reads ONLY the golden databases (independent of our binaries)
and lists every test whose golden carries the law's shape.  Run on the PRISTINE
workdirs, before the patched sweep was looked at:

```
surelog:  PREDICTED-MOVER-TESTS 5   BuildUVMPkg CoresSweRV CoresSweRVMP Monitor Opentitan
          PREDICTED-CELLS 464 over 8 (test,mode) pairs
u2r:      PREDICTED-MOVER-TESTS 0
```

Of those five, **only `BuildUVMPkg` produces a database at all** — `CoresSweRV`
and `CoresSweRVMP` are `SURELOG_FAIL`/`SLANG_REJECT`, `Monitor` and `Opentitan`
are `SLANG_REJECT` in both modes — so the predicted set intersected with
"has a database" is exactly `{BuildUVMPkg}`, and exactly `BuildUVMPkg`'s two
modes moved.  **Zero unpredicted movers.**

`./default/Scoreboard-59431470/slang.uhdm` also flagged.  It is the known
~50/50 COIN, proven twice and not assumed:

* the ORDER-BLIND diff (both dumps sorted, workdir paths normalised) is
  **0 lines** over 1 099 523;
* the **PRISTINE binary alone**, run six times on that test's own command line,
  produced `81c333dead33` five times and `dd2344581b19` once — i.e. it produced
  BOTH of the two hashes the sweep pair reported.

### THE BOUNDARY GATE'S TWO DIFFERING ARMS

`bound18.sh` compiles every `.sv` under `tools/probe/` — 2829 arms, including
every subdirectory — with both binaries and diffs the banner-normalised dumps.

* `r10buvm10repro/w3v_fence10.sv` — it declares `parameter f_t FP = 8'h5;`
  inside `package pf10` over `typedef bit [7:0] f_t;`, which **is** a cell this
  law names.  Re-measured against Surelog: DEFPKG and ELABPKG `FP` are
  **TO-GOLDEN**, the module-side `FP` import copy and `MP` are untouched
  (STILL-WRONG), **0 AWAY**.  It is this pass's POSITIVE CONTROL — proof the
  gate can see.
* `r10buvm18repro/grid18.sv` — this pass's own grid.

Every other bind-window arm in the tree (buvm3-17, uvm82-94, sd8-12,
§ `classArgBind12`, § `controlBodyNoBind28`, § `blkLocalSameCtrlDepthArgBinds57/64`,
§ `pkgVarBindsOnlyThroughInstance88`, § `superNewFormalBinds28`,
§ `newArrayArgNoBind16`, § `foreachElabLoopVarAnyKindBinds17`, …) is
**byte-identical**, which is expected: this law touches parameter typespec
minting only and never goes near `lateBinding` or `Actual_group`.

## 6. RESIDUES

**R0 — THE NEW HEAD (BuildUVMPkg, both modes, 17 cmp lines, md5
`2bb940e8dd2d`, 1 head).**  `LHS: <null>`; ours carries an extra
`ref_typespec` id 42704 on the `ref_var
(uvm_pkg::uvm_packer::pack_object_with_meta::m_object_references)` id 42703 at
`uvm_pkg.sv:22452:11-30`, whose actual is an `unsupported_typespec
(m_object_references)` id 42705.  Line 22452 is
`foreach(m_object_references[i])` — the foreach header's ARRAY reference.  The
slot is `expr::Compare`'s `Typespec()` (`BaseClass.h:194`'s
`lhs == nullptr && rhs != nullptr` arm, which sets only `m_failedRhs`): golden's
`ref_var` for a foreach array reference carries **no** typespec, ours carries an
unresolved one.  Next pass's target.

**R1 — the DEF listing's `int`-typedef parameters.**  `UVM_STDIN` /
`UVM_STDOUT` / `UVM_STDERR` (`typedef int UVM_FILE`) get the clone in the ELAB
listing but not the DEF one: their DEF-listing `int_typespec` is minted by an
EARLY inline site (object ids 197/203/209, next to the other DEF-listing
integers) instead of the deferred `makeParamTs` drain that the vector-typedef
parameters take (id 177713).  3 cells × 1 listing; the routing decision, not
this law, is what needs moving.

**R2 — the module-side wildcard-import copy.**  A materialized import copy of a
bit/int-typedef'd package parameter still carries a bare `int_typespec`.
Golden's shape is measured and recorded (grid `work@mi` rows): the same NAMED
clone, but its `Typedef_alias` names a SECOND, BARE-NAMED clone
(`alias->bit_typespec(bflag_t)`), `vpiParent` is the `ref_typespec`, and
`vpiInstance` is the ELABORATED package.  The logic arm below already models
exactly this with its `tdHome9` second clone; a future pass should make that
sub-arm kind-agnostic instead of duplicating it.

**R3 — a module parameter typed by an UNQUALIFIED imported typedef** (grid
`work@mi MIU`): golden clones with `alias->bit_typespec(gp::bflag_t)`, we keep
`int_typespec`.  Not package-homed, so out of this law's window.

**R4 — `UVM_RADIX` (uvm_pkg.sv:7897) carries a typespec we should not emit.**
`parameter UVM_RADIX = 'hf000000;` — an untyped parameter whose default is an
UNSIZED based literal — has NO `vpiTypespec` at all in golden, in both
listings; we mint a bare `int_typespec` at the whole declaration.  PRE-EXISTING
(the pristine binary reproduces it), 2 cells, and it is currently MASKED from
the judge.

## 7. THE INSTRUMENTS

| file | what it is |
|---|---|
| `r10buvm18cen.cpp` / `build18.sh` | the parameter-typespec census: one row per parameter, keyed (view, owner, name, line:col), valued kind(name)[alias->kind(name)#id] + range bound encodings + `apar` + `id` + `inst` + the SHARING FAN-OUT `nsh` (how many `ref_typespec`s point at the same actual — the field that decides whether the judge ever looks) |
| `r10buvm18probe.cpp` / `buildp18.sh` | the Compare-order probe: whole-design head, per-package head, per-parameter-pair heads under FRESH contexts, the same under ONE SHARED context, and `VECWALK` — `scope::Compare`'s vector order replayed with the package pre-marked visited, which is what names `Variables[2]` |
| `grid18.sv` / `gridcen18.sh` | the golden grid of § 3 |
| `predict18.py` | the a-priori mover prediction, from the GOLDEN databases only |
| `cenall18.sh` | the three-way (golden / pristine / patched) MULTISET census over a sweep, id-normalised, verdicts TO-GOLDEN / AWAY / CHANGED-STILL-WRONG / STILL-WRONG / STILL-RIGHT |
| `bound18.sh` | the boundary gate (fd-3 arm list, children `</dev/null`, PROCESSED asserted, subdirectories included, banner normalised) |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `byteverify.sh` `rowheads.sh` | carried forward unchanged from the landed passes |

**Two traps this pass paid for, recorded so the next one does not:**

* `UHDM::decompile()` **streams to stdout and returns only its banner**, so a
  probe that prints `decompile(obj)` gets the literal string `decompile:` while
  the object's text goes somewhere else entirely.  `r10buvm18probe` describes
  failed objects with its own field printer instead.
* the shared `/tmp/ctl_wd_*` control workdirs are **deleted underneath you** by
  the master's rotation mid-pass (a `Restore` began failing with
  `kj/io.c++:348 … Bad file descriptor; fd = -1` halfway through this pass).
  The standing rule to build your OWN pinned workdir is not advice.
