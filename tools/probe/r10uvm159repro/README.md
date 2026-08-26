# r10uvm159 — § `pkgImportTfOpFoldTs159`

*A folded read of a parameter carries **the parameter's own declaration
typespec**. The component that answers the name is whichever one lists the
parameter in `getParam_assigns()` — a MODULE that materialised a wildcard
import, or, **exactly as well, the PACKAGE that materialised it for its own
classes**. Our emitter only ever recorded the module case, so every operand
fold inside a **class method** came out with no typespec at all.*

Base commit **06e1acc**. LHS is **always** golden (Surelog); RHS is always
ours. The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else;
every instrument in this directory is measurement-only and links the same
generated `Compare`. slang was NOT patched; `results/*.csv` were READ ONLY.

---

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SeqDriver default / testflags** | **17** cmp lines, 1 head | **163**, 1 head — a **DIFFERENT** object (R0 below) |
| SimpleUVM default / testflags | 163, 1 head | 163 — head log **BYTE-IDENTICAL** |
| Scoreboard default | 163, 1 head | 163 — **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 106, 1 head | 106 — **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 1371, 1 head | 1371 — **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 36, 1 head | 36 — **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this pass's own pristine control sweeps (1588 surelog row-modes + 1358 u2r) |
| byte movers | — | **4 / 956** surelog — **exactly the four predicted BY NAME from pristine data**; **0 / 1358** uhdm2rtlil |
| the law's corpus population | **54** wrong cells (SeqDriver ×2, MiniAmiq ×2) | **0** — WRONG→RIGHT **54**, MOVED-WRONG **0**, **AWAY 0** |
| every OTHER census population | — | **unchanged, to the cell**: the patched-minus-pristine delta has exactly ONE line |
| grid, 4 arms × golden | — | law cells 13+9+5+5 → 0+1+0+0, **AWAY 0 in every arm** |
| wide boundary | 4441 arm files × 2 views | **5** moved, `RC_DIFFS 0`; every one re-measured against golden — WRONG→RIGHT **8**, MOVED-WRONG **0**, **AWAY 0**, and **two arm heads CLEARED** |

No row was converted. **No u2r row converts under this law** — see §6.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reads SeqDriver **17 cmp
lines, one `^LHS:`, both modes** (`head_pris_SeqDriver.*.cmp`, the two logs
identical but for object ids):

```
LHS:
decompile:
ref_typespec: (adpcm_pkg::adpcm_tx_seq), id:251392
|vpiParent:
\_constant: , id:251391, line:162:24, endln:162:34
|vpiFullName:adpcm_pkg::adpcm_tx_seq
|vpiActual:
\_int_typespec: , id:251393, line:217:1, endln:217:38
…
RHS: <null>
```

`RHS: <null>` on a SINGULAR `SafeCompare` names the VALUE and leaves the RHS
unset (RESUME.md §9's buvm13/15 framing), so the head is **an edge we do not
carry**, and the OWNER is the object the edge hangs off — the `constant`.

### The judge's read order, from the generated Compare

`constant::Compare` (`~/git-repos/UHDM/build/generated/src/constant.cpp:58`)
calls its base first, so the field order the judge actually walks is

| # | field | source |
|---|---|---|
| 1-3 | `VpiType`, `VpiName`, `VpiDefName` | `BaseClass::Compare` |
| 4 | `VpiDecompile` | `expr::Compare` |
| 5 | `VpiSize` | `expr::Compare` |
| 6 | **`Typespec()`** | `expr::Compare` — `SafeCompare(lhs->Typespec(), rhs->Typespec())` |
| 7 | `VpiConstType` | `constant::Compare` |

A constant's **typespec edge is read BEFORE its const-type**, and its VALUE is
not read at all. That is why this cell is the head while decompile, size and
value already agree.

### The owner, found with a direct reader over both databases

`ct159obj` (this directory) restores a database and prints one object with its
typespec edge, its parent chain and every relation that holds it. On golden:

```
OBJ constant(-)@uvm_object_defines.svh:162:24-162:34#251391
    expr dec=[131078] val=[UINT:131078] size=32
    ts  ref=ref_typespec(-)@:0:0-0:0#251392 -> actual=int_typespec(-)@uvm_object_globals.svh:217:1-217:38#251393
    par < param_assign(-)@uvm_object_globals.svh:217:11-217:38#251234
        < class_defn(adpcm_tx_seq)@testbench.sv:137:1-166:23#329
        < package(adpcm_pkg)@testbench.sv:10:1-207:22#325 < design(work@top_tb)
    held rel=97 by operation(-)@uvm_object_defines.svh:162:9-162:57#251390
```

and on ours, the same span, const-type, size, decompile and value — and no
typespec:

```
O K :162:24-162:34 ct=uint size=32 dec=[131078] val=[UINT:131078] ts=none
     par=operation own=operation@:162:9 home=cls:adpcm_tx_seq
```

* **the file and the spelling.** `uvm_object_defines.svh:162` cols 24…33 is
  `UVM_SETINT`, inside the body of the `` `uvm_field_utils_begin `` macro:
  `if(what__ inside {UVM_SETINT,UVM_SETSTR,UVM_SETOBJ}) begin`. Its two
  siblings at 162:35 and 162:46 are `UVM_SETSTR` and `UVM_SETOBJ`.
* **the const type and value.** `vpiUIntConst`, `UINT:131078`, size 32,
  decompile `131078` — **identical on both sides**.
* **the int_typespec's declaration line.** `uvm_object_globals.svh:217:1-217:38`
  is the WHOLE declaration `parameter UVM_SETINT        = UVM_SET;` (cols 1
  through 37; the `;` is excluded). 218 and 219 are `UVM_SETOBJ` and
  `UVM_SETSTR` the same way.
* **the owner is an `operation`, not the parent.** Golden's `vpiParent` is the
  *declaring* `param_assign` — the substitution artefact decoded in §2 — while
  the only object that *holds* the constant is the `inside` operation. Ours
  parents it at that operation. `vpiParent` is read by NO generated Compare,
  so the two framings are the same cell.
* **the typespec's own fields, both sides** (`ct159obj`): `int_typespec`,
  unnamed, `Typedef_alias` null, **`Instance` null**, `VpiSigned 0`, no ranges,
  span 217:1-217:38. Golden's is a per-reference clone; the object our own
  materialised `adpcm_pkg::UVM_SETINT` already carries is field-for-field the
  same. `typespec::Compare` reads VpiName → `Typedef_alias` → `Instance`, and
  `int_typespec::Compare` adds `Cast_to_expr` → `VpiSigned` → `Ranges`: every
  one of them agrees.

---

## 2. THE DECODED MODEL (Surelog, read line by line, then measured)

`CompileHelper::compileExpression`'s `slStringConst` arm resolves a bare name
against the enclosing component's parameters. `~/git-repos/Surelog` (the tree
`scripts/verify_golden.py` builds its goldens from), `src/DesignCompile/
CompileExpression.cpp`:

| site | scope searched | clone | typespec attached |
|---|---|---|---|
| **:2880** | `inst->getNetlist()->param_assigns()` | `clone_tree(param_ass->Rhs())`, `VpiParent(param_ass)`, `populateCoreMembers(child…)` | **YES**, :2901-2904 |
| **:2948** | `component->getParam_assigns()` | same three lines | **YES**, :2969-2972 |
| :2722 | `paPackage_scope` — a written `pkg::P` | `clone_tree`, `VpiParent(pexpr)` | **NO** |
| :2770 | `paClass_type` — a written `C::P` | `clone_tree` | **NO** |
| :950/:1021/:1123 | `getValue` helpers | `clone_tree` | **NO** |

and the attach itself is exactly:

```cpp
typespec *tps = nullptr;
const any *lhs = param_ass->Lhs();
…else if (lhs->UhdmType() == UHDM::uhdmparameter) {
    if (ref_typespec *lhs_rt = ((UHDM::parameter *)lhs)->Typespec())
      tps = lhs_rt->Actual_typespec();
}
expr *res = (expr *)result;
if (tps && (res->Typespec() == nullptr)) {
    ref_typespec *tps_rt = s.MakeRef_typespec();
    tps_rt->VpiParent(res);
    tps_rt->Actual_typespec(tps);
    res->Typespec(tps_rt);
}
```

Three consequences, all of them measured on golden:

1. **The clone's parent is the DECLARING `param_assign`, its span is the
   REFERENCE.** `result->VpiParent(param_ass)` then
   `fC->populateCoreMembers(child, child, result)` — which is exactly the
   golden object above: parent `param_assign@217:11-217:38`, span
   `162:24-162:34`. It is a substitution artefact and nothing else.
2. **A QUALIFIED read gets no typespec.** `pkg::P` is the `paPackage_scope`
   arm at :2722, which clones and locates but never looks at the Lhs typespec.
3. **No parameter typespec ⇒ no constant typespec.** `if (tps && …)`. An
   untyped parameter gets its implicit one from its own folded value in
   `CompileHelper::compileParameterDeclaration`
   (`src/DesignCompile/CompileHelper.cpp:3854-3866` for `vpiUIntConst`:
   `int_typespec`, `VpiSigned(false)`, `populateCoreMembers(nodeId, nodeId,
   its)` — the whole-declaration span 217:1-217:38 the head names), and a
   **`vpiDecConst` value mints nothing at all** (:3844, a bare `break;`).

### WHY THE CLASS CASE IS THE ONE WE MISS

`component` at :2948 is whatever `DesignComponent` owns the scope the name was
written in. For `UVM_SETINT` read inside `adpcm_tx_seq::__m_uvm_field_
automation`, that is the CLASS, and Surelog materialised `uvm_pkg`'s parameter
into it: golden holds `param_assign@217:11-217:38#251234` parented at
`class_defn(adpcm_tx_seq)`. Our ParamEmit materialises the very same import
copy — `parameter(UVM_SETINT)@:217:11-217:21#3279` in `package(adpcm_pkg)`
with `ref_typespec -> int_typespec@:217:1-217:38#3284` — but it only *records*
that typespec for a later fold to name on the `!inPackage` arm
(`importedParamDefTs`, ParamEmit.cpp ~14613). A package materialising the
import for its own classes wrote nothing down, so ExprEmit's § `tfOpFold9` —
"a TASK/FUNCTION-BODY operand fold reading an imported param carries the ts
ref" — found an empty map and the fold came out bare.

---

## 3. THE LAW

> **§ `pkgImportTfOpFoldTs159`** — a constant produced by folding an
> **UNQUALIFIED** read of a package parameter that the enclosing **PACKAGE**
> materialised from a wildcard import, **owned by an `operation`**, inside a
> **task or function whose home is a CLASS**, carries a fresh anonymous
> `ref_typespec` whose actual is that materialised copy's own declaration
> typespec.

Surface: three hunks, +103 lines, no deletions.

* `include/UhdmExporter.h` — `pkgImportParamTs159`, the package twin of
  `importedParamDefTs`.
* `src/ParamEmit.cpp` (~14587) — one line inside the existing
  `inPackage && isImported && <home is a package>` block: remember `its`.
* `src/ExprEmit.cpp` (~14299) — the stamp, placed AFTER the existing
  `importedParamDefTs` block and gated on `!c->Typespec()` so it can never
  restamp a cell an older arm already owns.

### THE GATES, AND THE GOLDEN MEASUREMENT BEHIND EACH

| gate | why, measured |
|---|---|
| `currentTf` **and the home is a CLASS** | golden's `own=operation ctx=tf` cells are `home=cls` in **all 54** corpus cells and in every grid arm; grid C's package function `c_pkgfunc159` reads the same imported parameter in the same operand position and golden gives it **no** typespec — 0 `home=pkg` cells anywhere in either corpus |
| parent is an `operation` | the same parent test § `tfOpFold9` already carries; grid A measures the alternatives separately (see R1) |
| the read is UNQUALIFIED (no `::` in the source text) | Surelog's `paPackage_scope` arm (CompileExpression.cpp:2722) attaches nothing; grid A row `a_qual` is the witness and stays bare on both sides |
| `pkgImportParamTs159` has the symbol | "no parameter typespec ⇒ no constant typespec" straight off :2969 |
| `!c->Typespec()` | `if (tps && (res->Typespec() == nullptr))` — and it keeps this arm out of every older arm's cells |

The typespec is SHARED with the materialised copy rather than cloned; golden
mints one per reference. **No generated `Compare` reads `VpiParent`**, and the
two objects are field-identical, so sharing versus cloning is invisible to the
judge. It is also what the `importedParamDefTs` arms have always done.

---

## 4. THE CENSUS (`ct159cls` / `cls159.sh` / `score159.py`)

Key = the constant's **compare-visible payload** plus its span
(`line:col-endline:endcol | constType | size | decompile | value`), joined as a
MULTISET; value = the typespec edge. `vpiParent` is deliberately OUT of the
key, because Surelog parents a substituted clone at the declaring
`param_assign` while we parent it at the expression that uses it. Each cell
also carries `own` (the first non-`vpiParent` holder), `ctx` (the first
enclosing scope above the owner) and `home`.

Two exclusions, both of them traps this pass paid for:

* **ORPHANS.** A constant nothing points at and with no parent is the
  weaklyReferenced TAIL, unreachable to the judge (RESUME.md §9). It reads 0
  on every real database here, but the guard stays.
* **NO-GOLDEN-OBJ.** A cell where golden has no *reachable* constant at all is
  not a cell where golden made a typespec decision — it is an over-fold of
  ours. Also 0 on every corpus database.

**Surelog corpus, 956 pairs, both modes** (`CENSUS.r10uvm159.txt`):

```
LAW POPULATION  own=operation ctx=tf home=cls
  pristine  STILL-WRONG 54   AWAY 0
  patched   STILL-WRONG  0   AWAY 0
  delta: the ONLY line in the whole patched-minus-pristine table is
         MISSING-OURS own=operation ctx=tf home=cls  -54
whole-census totals   gts 57674 (unchanged)   ots 52715 -> 52769 (+54)
                      MISSING-OURS 3359 -> 3305   EXTRA-OURS 1240 -> 1240
```

The 54 are, cell by cell: **SeqDriver ×2 modes × 2 classes × 3 spans = 12** and
**MiniAmiq ×2 modes × 7 classes × 3 spans = 42**. The three spans are
`162:24 UVM_SETINT`, `162:35 UVM_SETSTR`, `162:46 UVM_SETOBJ`; the classes are
the ones whose `` `uvm_object_utils_begin `` expansion carries
`` `uvm_field_utils_begin ``. **Every constant OURS holds at those spans is one
golden also holds AND stamps** — which is why the arm is WRONG→RIGHT on all 54
with no cell available to move AWAY.

**uhdm2rtlil corpus, 1358 pairs, both modes**: the law's population is **0
cells on both sides**, and the patched workdir is byte-identical to the
pristine one (0/1358 movers), so its census is unchanged by construction.

---

## 5. THE GRID (`arm159.sh`, `g159_*.sv`)

Four arms, each compiled against the real `uvm-1.2` tree with the SAME Surelog
`scripts/verify_golden.py` uses, and scored with `ct159cls` on golden.

| arm | axis | pristine law cells | patched | AWAY |
|---|---|---|---|---|
| `g159_a_owners` | 12 OWNER positions of the same read inside one class method | 13 | **0** | 0 |
| `g159_b_origins` | 12 ORIGINS of the folded name | 9 | **1** (R2) | 0 |
| `g159_c_homes` | class method / package function / module function / module process / gen-scope process / 3 instances | 5 | **0** | 0 |
| `g159_d_min` | the same shape with **no UVM at all** (the boundary's positive control) | 5 | **0** | 0 |

What the grid convicts, on GOLDEN:

* **owners (arm A).** Golden stamps the `inside` set, an arithmetic operand, a
  concat member, a replication count, both ternary arms and the condition —
  every one of them an `operation` — and it ALSO stamps a bare assignment RHS,
  a `return`, a `$sformatf` argument and a case item. This law takes the
  operation ones (13 → 0) and leaves the other four as R1. The `a_qual` row
  (`uvm_pkg::UVM_SETINT + 1`) is bare on **both** sides — the negative control
  for the `::` gate — and so are the package's own non-imported parameters.
* **homes (arm C).** The package FUNCTION `c_pkgfunc159` reads the same
  parameter in the same operand position and golden leaves it bare. That is
  the whole reason the law says `home=cls` and not `ctx=tf`.
* **origins (arm B).** An `int`, a `bit [7:0]`, an untyped and a `string`
  import all stamp; a class localparam, an enum constant, a literal, a `$bits`
  and a macro never fold to this shape at all. The one survivor is the
  TYPEDEF-declared import (R2).
* **arm D** is the standalone positive control: the law is keyed on the import
  materialisation, not on anything UVM supplies, so a 40-line file with no
  include path reproduces it — which is what makes the wide boundary able to
  see this pass at all.

---

## 6. THE u2r CANDIDATE — `LocalParamInNestedForLoops` DOES NOT CONVERT

The campaign memory records it as the row this family might convert. Measured
at 06e1acc, both modes: **it is already `CMP_EQUAL`** (its dump column
differs). Its residue is not a typespec edge at all — golden holds **25**
constants and we hold **24**: the missing one is the gen-scope
`param_assign` Rhs at `5:34-5:46`, which golden lists twice (once under
`param_assign`, once under the `cont_assign`) and we list once. The
typespec on the copy we DO emit already matches golden's
(`int_typespec@5:21-5:24`). No row on either corpus converts under this law.

---

## 7. WIDE BOUNDARY

`bound159.sh` over a COPY of the whole probe tree: **4441** arm files (top
level and subdirectories), both views, both binaries, file list on fd 3,
children `</dev/null`, scratch keyed on the RELATIVE path, `PROCESSED`
asserted against `LISTED`. `g159_d_min.sv` is the positive control and it
MOVED, so the gate can see.

```
LISTED=4441 PROCESSED=4441 PRODUCED_DBS=4291 MOVED_ARMS=5 RC_DIFFS=0
```

| moved arm | law cells pris→pat | EXTRA-OURS | uhdm-cmp head |
|---|---|---|---|
| `r10uvm106repro/a6_edge.sv` | 0 → 0 (note A) | 0 → 0 | 17L/1H unchanged |
| `r10uvm146repro/g146_c_owners.sv` | **2 → 0** | 1 → 1 | 50L/1H unchanged |
| `r10uvm47repro/t66b/dut.sv` | **1 → 0** | 0 → 0 | 17L/1H → 3958L/1H, **HEAD CLEARED** |
| `r10v106repro/b06_import.sv` | 0 → 0 (note A) | 0 → 0 | 34L/1H unchanged |
| `r10uvm159repro/g159_d_min.sv` | **5 → 0** (control) | 0 → 0 | 17L/1H → 46L/1H, **HEAD CLEARED** |

Both cleared heads were *this law's own shape* — a `ref_typespec` on a folded
constant with `RHS: <null>` — and both moved to a DIFFERENT object, which is
why the line counts rise (RESUME.md §7).

**Note A**: those two arms gain 4 stamps between them on cells golden ALSO
stamps, but the census cannot pair the cells because the two sides already
disagree about `VpiSize` there (an unsized literal parameter: golden -1, ours
32) — R5. Direction is toward golden; nothing went RIGHT→WRONG.

Full detail in `BOUNDARY.r10uvm159.txt`.

---

## 8. RESIDUES AND R0

* **R0 (the next head).** SeqDriver ×2, **163** cmp lines, ONE `^LHS:`, and it
  is now **the same object SimpleUVM and Scoreboard already stand on**: a
  `begin` block, `uvm_pkg::uvm_reg_predictor::get_type_name`,
  `uvm_reg_predictor.svh:118:26-122:8`, parented at an `if_stmt`, with
  **`RHS: <null>`** — a whole statement listing (a `ref_var t` plus two
  assignments) that we do not emit inside the `if` of a parameterised class's
  `get_type_name`. Three row families now share it. See
  `head_pat_SeqDriver.default.cmp`.
* **R1 — the FOUR non-operation owners.** Golden stamps a folded read whose
  owner is a bare `assignment` RHS, a `return_stmt`, a `sys_func_call`
  argument or a `case_item` in exactly the same class-method context.
  Measured on grid A (1 cell each) and grid D (1 `assignment` cell). Corpus
  incidence: **0** on both corpora, which is why this pass did not widen the
  parent test — there is no corpus witness to gate it on.
* **R2 — a TYPEDEF-declared import.** `parameter qb_t159 QB_TD159 = 6'd24;`
  read under an `int'()` cast: golden gives the fold a `logic_typespec` NAMED
  `qb_t159` (grid B, 37:19-37:27) and `pkgImportParamTs159` has no entry for
  it, so we stamp nothing. 1 grid cell, 0 corpus cells.
* **R3 — the `ref_typespec`'s synthesized `VpiFullName`.**
  `ref_typespec::VpiFullName()` is COMPUTED from the parent chain and cached
  (`~/git-repos/UHDM/build/generated/src/ref_typespec.cpp:43`), so golden's
  reads `adpcm_pkg::adpcm_tx_seq` (its constant is parented at the declaring
  `param_assign` under the class) and ours reads
  `adpcm_pkg::adpcm_tx_seq::__m_uvm_field_automation` (ours is parented at the
  operation). `ref_typespec::Compare` reads `VpiName`, `VpiDefName` and
  `Actual_typespec` and **never** `VpiFullName`, so this is a naming residue of
  a PARENTING choice, not a judge field. Do not "fix" it by writing the string.
* **R5 — an UNSIZED-literal parameter's fold.** `parameter E_TH0 = 'h0;`:
  golden's fold carries a `ref_typespec` with a **NULL `Actual_typespec`**
  (CompileHelper.cpp's hex/oct/bin arm mints the `int_typespec` only inside
  `if (c->VpiSize() != -1)`), while we name the parameter's own typespec.
  4 cells, all of them on boundary arms (`r10uvm106repro/a6_edge.sv`,
  `r10v106repro/b06_import.sv`), 0 corpus cells, and every one sits behind a
  PRE-EXISTING `VpiSize` mismatch (golden -1, ours 32) that the judge fails on
  first — which is also why the census cannot pair those cells at all.
* **R4 — the parameter-DECLARATION Rhs family, the big one next door.** The
  same census counts **3305** remaining `MISSING-OURS` constants corpus-wide,
  of which 4617 tallied cells are `own=param_assign ctx=param_assign` — a
  parameter's OWN value object missing the implicit typespec
  `CompileHelper.cpp:3826-3880` mints from its const-type — and **1240**
  `EXTRA-OURS` in the same class (2320 of them `home=mod`, 762 `home=iface`).
  Both directions exist, both are PRE-EXISTING and untouched by this pass
  (the patched and pristine tallies are identical line for line), and they are
  a different Surelog site. That family, not this one, is where the remaining
  constant-typespec mass is.

---

## 9. FILES

| file | what |
|---|---|
| `ct159cen.cpp` | every constant in one database: span, const-type, size, decompile, value, typespec edge, owner relation, home, parent chain |
| `ct159obj.cpp` | one object by id / kind / name / span, with its typespec edge (actual kind + id, which is what proves sharing vs copying), parent chain and every relation that holds it |
| `ct159join.cpp` | the plain multiset join of the two sides |
| `ct159cls.cpp` | the join CLASSIFIED by owner × context × home, with the orphan and no-golden-object exclusions — the census the law is scored on |
| `cen159.sh`, `cls159.sh` | run the join over a whole `verify_golden` workdir |
| `score159.py` | score one census pair: WRONG→RIGHT / AWAY / every other population |
| `predict159.sh` | name the mover set from PRISTINE data alone |
| `arm159.sh`, `g159_a..d*.sv` | the grid |
| `bound159.sh`, `remeasure159.sh` | the wide boundary and the golden re-measurement of its movers |
| `dumpdiff159.sh` | path-normalised, order-blind whole-dump diff of one moved database |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the official `uhdm-cmp` head log for each named row, before and after |
| `GATES/CENSUS/GRID/PREDICT/BOUNDARY/DUMPDIFF.r10uvm159.txt` | the measurements above, as produced |

### OPS TRAPS THIS PASS PAID FOR (all three now guarded in `arm159.sh`)

1. **The golden producer is `~/git-repos/Surelog/build/bin/surelog`**, the one
   `scripts/verify_golden.py` names — NOT the `sv-tests` copy the shell alias
   points at. The sv-tests build is older and writes databases the installed
   `libuhdm` **segfaults on**: `Serializer::Restore`, `uhdm-dump` and the
   official `uhdm-cmp` all die, and an arm run with it reports *zero cells*
   while looking healthy. It inverted a grid reading before it was found.
2. **`-noprecompiledcache` is mandatory whenever `uvm_pkg.sv` is on the
   command line** (`verify_golden.py`'s `precompiled_guard`).
3. **`-mt 0 -mp 0` are mandatory too** — `verify_golden.py` passes both.
