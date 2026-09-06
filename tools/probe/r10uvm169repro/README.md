# r10uvm169 — § `pkgRetParamSubstReachesTheImportCloneDefView169` — **A WILDCARD-IMPORT CLONE OF A PACKAGE SUBROUTINE IS A COPY OF THE HOME PACKAGE'S *ELABORATED* BODY, SO ITS `AllPackages` LISTING CARRIES THE HOME'S `Reduce::Yes` RETURN FOLD** — the SeqDriver ×2 **50-line head CLEARED** (27 lines, a NEW object)

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW WAS CONVERTED**. `GOLDEN_DEFER` was never set.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `cfb2321f` |
| worktree | `/tmp/wt_r10uvm169` |
| pristine binary | md5 `196a8dcc6d57a4a2da7f6017d652712d`, built from a clean `cfb2321f` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `ae36c8b5caa51176a4bb77e9f2fec2f2`, frozen `chmod 555` before any sweep |
| production surface | `src/StmtEmit.cpp` (**+69 / −5**: one gate widened, three clauses fenced to `pkgTopEmit`, and the law) |
| probe surface | `tools/probe/r10uvm169repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SeqDriver default / testflags** | **50** | **27** | 1 — a **NEW head**, a different object (§ 8) |
| SimpleUVM default / testflags | 17 | 17 | 1 unchanged (uvm167's other R0 — **not this pass**) |
| Scoreboard default | 95 | 95 | 1 unchanged |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged — the row **moves bytes** (predicted) but its head is an earlier object (§ 5) |
| BuildUVMPkg default / testflags | 60 | 60 | 1 unchanged |
| Earlgrey_0_1 default / testflags | 31 / 50 | 31 / 50 | 1 unchanged |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes; the surelog status histogram is IDENTICAL (`CMP_NOTEQUAL` stays 10 default / 9 testflags) and uhdm2rtlil stays `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2` in both modes | |
| byte movers | — | **5 / 956** surelog — **4 PREDICTED BY NAME** a priori and 1 the documented Scoreboard COIN; **0 / 1358** uhdm2rtlil | |
| the corpus census (956 + 1358 databases, both modes) | — | this law's bucket is **4 cells in 4 row-modes**; the AWAY column is **0 cells in both corpora** | |
| the grid (4 arms, both views) | — | **RET 24 TOWARD / 0 AWAY / 4 STILL-WRONG / 31 UNMOVED**; OBJ **0 AWAY in every arm** | |
| the WIDE boundary (4738 arms, both views) | — | **4 moved arms, RC_DIFFS 0**; 3 are this pass's own grid (the positive control), the 4th is `r10uvm120repro/g120_c_homes.sv` — this law's own population — re-measured against golden at **6 TOWARD / 0 AWAY** | |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT'S
decompile size. `head_pris_SeqDriver.default.cmp` (50 lines) is the head the
brief named; `head_pat_SeqDriver.default.cmp` (27) is the new one.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduced the brief exactly —
SeqDriver ×2, **50 cmp lines, 1 head, ONE object on both row-modes**.

From `head_pris_SeqDriver.default.cmp` — uvm-1.2 `base/uvm_version.svh`:

```systemverilog
parameter string uvm_revision = `UVM_VERSION_STRING;   // :31, ts at 31:11, Rhs at 31:33

function string uvm_revision_string();                 // :33
  return uvm_revision;                                 // :34
endfunction
```

```
LHS:  constant: , line:34:10, endln:34:22        <- golden FOLDED
      |vpiParent: \_return_stmt: , line:34:3
      |vpiDecompile:"UVM.1.2"  |vpiSize:56  |STRING:UVM.1.2  |vpiConstType:6
      |vpiTypespec: \_ref_typespec: (adpcm_pkg::uvm_revision_string)
                      |vpiActual: \_string_typespec: , line:31:11, endln:31:17
RHS:  ref_obj: (adpcm_pkg::uvm_revision_string::uvm_revision), line:34:10, endln:34:22
      |vpiActual: \_constant: , line:31:33, endln:31:42
```

**THE JUDGE, DECODED FIRST.** The failing edge is `BaseClass::Compare`'s FIRST
test, `VpiType` — which is why both sides print in full and why the cmp line
count is the whole decompile of golden's constant. The compared span of the
object golden holds is, in order:

* `expr::Compare` (`~/git-repos/UHDM/build/generated/src/expr.cpp:83-102`) reads
  `VpiDecompile`, then `VpiSize`, then `SafeCompare(lhs->Typespec(), …)` — **so
  the folded constant's `ref_typespec` IS inside the compared span**, and so is
  the `string_typespec` it resolves to;
* `ref_typespec::Compare` (`ref_typespec.cpp:123-143`) reads `VpiName`,
  `VpiDefName`, `Actual_typespec`;
* `typespec::Compare` (`typespec.cpp:81-96`) reads `VpiName`, `Typedef_alias`,
  `Instance`;
* `constant::Compare` (`constant.cpp:58-72`) adds `VpiConstType`.

The `string_typespec` at `31:11` prints as a LEAF in both dumps (`uhdm-dump`
DOES print `|vpiInstance:` for typespecs — see the `int_typespec (uvm_pkg::UVM_FILE)`
a few thousand lines earlier in the same dump), so its `VpiName`, `Typedef_alias`
and `Instance` are all empty on both sides and the typespec half of the compare
is satisfied by ANY bare `string_typespec`. `vpiParent` and `vpiFullName` are
read by NO generated `Compare` (RESUME §9) — which is why the two residues in
§ 8 do not reach the judge.

## 2. THE DECODE — WHERE GOLDEN'S FOLD BOUNDARY ACTUALLY IS

The head is NOT "a package function folds its parameter return". Golden's own
`uvm_pkg::uvm_revision_string` **keeps the `ref_obj`** in this very database.
The object that folds is the copy `import uvm_pkg::*;` materialises inside
`adpcm_pkg`. `ct169cen` on the pristine pair, keyed by the owning subroutine's
`vpiFullName` (the ONE string that separates a clone from its home):

```
G  adpcm_pkg::uvm_revision_string   {constant, constant}      <- BOTH listings folded
G  uvm_pkg::uvm_revision_string     {constant, ref_obj}       <- ELAB folded, DEF bare
O  adpcm_pkg::uvm_revision_string   {constant, ref_obj}       <- ours: only the ELAB one
O  uvm_pkg::uvm_revision_string     {constant, ref_obj}       <- ours: matches golden
```

**SURELOG.** `FunctorCompilePackage` (`CompilePackage.cpp:60-72`) compiles every
package TWICE: the elaborated `Package` with `Reduce::Yes` and the
`getUnElabPackage()` twin with `Reduce::No`; `UhdmWriter` puts the first in
`design.TopPackages` and the second in `AllPackages`. Inside a body,
`compileStmt`'s `paRETURN` arm (`CompileStmt.cpp:834-843`) is the ONLY arm that
threads the inherited `reduce` into `compileExpression`, whose tail then runs
`reduceExpr` over the whole return expression (`CompileExpression.cpp:3648-3656`).
For a bare parameter read, `ExprEval::reduceExpr`'s `uhdmref_obj` arm
(`~/git-repos/UHDM/templates/ExprEval.cpp:4695-4719`) calls back into
`CompileHelper::getValue`, which for a package parameter walks
`component->getParam_assigns()` and returns
`UHDM::clone_tree(param->Rhs(), …)` — **the param_assign's Rhs verbatim, its
typespec linkage included** (§ `pkgRetParamSubstIsRhsClone120`, already landed).

**AND THE CLONE.** `CompileHelper::importPackage` (`CompileHelper.cpp:319-325`)
`clone_tree`s `def->getTask_funcs()` of the imported package, where `def` is the
**ELABORATED** `Package*` found by name in the Design — *whatever view of the
importer is being compiled*. The importer's `AllPackages` listing is therefore a
copy of bodies that were ALREADY reduced. This is not a new decode: it is
exactly (b)/(c) of § `pkgRetOobClassAndImportCloneTs127`, which put both views of
a wildcard-import clone in the `Reduce::Yes` stamp set. **What this pass found is
that § 120's FOLD was still gated on `pkgTopEmit` alone while § 127's TYPESPEC
STAMP had already been widened to the four-listing set.**

**THE FOLD MATRIX, measured against golden on arm A (ten parameter kinds, one
function each, both views).** In the home package `p169h` every kind is
`{constant, ref_obj}`; in the wildcard importer `p169i` every kind is
`{constant, constant}`:

| parameter | home `p169h` (G) | clone `p169i` (G) | ours pristine (clone) |
|---|---|---|---|
| `string` | const + ref | **const + const** | const + ref |
| `string` (empty) | const + ref | **const + const** | const + ref |
| `int` | const + ref | **const + const** | const + ref |
| `localparam int` | const + ref | **const + const** | const + ref |
| untyped `parameter` | const + ref | **const + const** | const + ref |
| `byte` (`8'sd5`) | const + ref | **const + const** | const + ref |
| `bit [3:0]` | const + ref | **const + const** | const + ref |
| `enum int` | const + ref | **const + const** | const + ref |
| `real` | const + ref | **const + const** | const + ref |
| typedef'd `bit [5:0]` | const + ref | **const + const** | const + ref |

The attached typespec is **NOT the function's return typespec** — the brief's R0
framing, refuted here. It is the **PARAMETER's own** typespec, reached through
the cloned Rhs: golden's folded constant at `34:10` points at the
`string_typespec` at **`31:11`** (the `parameter string` keyword), while the
function's return typespec is at `33:10` and is a different object that golden
leaves on the `Return` `string_var`. It is SHARED, not minted: in golden's
`adpcm_pkg` listing the import-cloned `parameter uvm_revision`, its
`param_assign` Rhs and the folded return constant all resolve to the same
`31:11` object.

## 3. THE EMISSION SITE

`src/StmtEmit.cpp`, `StatementKind::Return`, § `pkgRetParamSubstIsRhsClone120`'s
block. The fold already builds every field golden holds — the constant is copied
from `pkgParamDefRhs[&param]` (the Rhs THIS listing emitted), spanned at the
REFERENCE site, and given a `ref_typespec` onto a param-typespec clone. The one
thing missing was the listing test. `pkgTopEmit` is set from `topView` for the
whole of `emitPackage`, and the wildcard-clone emission site
(`src/ParamEmit.cpp:20599`) sits inside it — so the ELABORATED clone already
folded and only the DEF clone did not.

**THE CHANGE, in four lines of code:**

```cpp
const bool foldWindow169 = pkgTopEmit || pkgImportCloneEmit;
if (foldWindow169) {
    …
    if (pkgTopEmit && cf.directSub && foldedRet.count(cf.directSub)) …   // fenced
    …
    if (pkgTopEmit && currentSubSym) foldedRet[currentSubSym] = c;       // fenced
    …
    if (pkgTopEmit && cf.lit && (!fp120 || direct120)) …                 // fenced
```

The three fences are load-bearing: `foldedRet` is keyed by the subroutine SYMBOL,
which a clone SHARES with its home, so a clone reading or writing it would splice
one listing's object into another's. Only the PARAMETER SUBSTITUTION is widened.

## 4. THE CENSUS AND THE A-PRIORI PREDICTION (`PREDICT.r10uvm169.txt`)

`predsweep169.sh` censuses BOTH databases of every row of the PRISTINE workdirs
with `ct169cen` and joins them as MULTISETS keyed by `<owning subroutine
vpiFullName> × <return_stmt span>` — the DEF/ELAB view is deliberately kept OUT
of the key (RESUME §9: the two producers label it differently), so a package's
two listings appear as a 2-element multiset. Both directions are reported.

```
SURELOG      rows=956 skipped=617 censusfail=0
             664 OTHER  (class `create` listing residues — a different family)
               4 OURS-REF-GOLDEN-CONST   <- this pass's bucket
               0 OURS-CONST-GOLDEN-REF   <- the AWAY direction
UHDM2RTLIL   rows=1358 skipped=104 censusfail=0
               0 cells in ANY direction
```

The four cells, named before the patched binary was run:

```
default/SeqDriver    adpcm_pkg::uvm_revision_string     34:3-34:9
testflags/SeqDriver  adpcm_pkg::uvm_revision_string     34:3-34:9
default/MiniAmiq     svaunit_pkg::uvm_revision_string   34:3-34:9
testflags/MiniAmiq   svaunit_pkg::uvm_revision_string   34:3-34:9
```

## 5. THE MOVERS, ATTRIBUTED

`byteverify.sh SELFCHECK=1` reported **5 / 956** on surelog and **0 / 1358** on
uhdm2rtlil. Every one was attributed by an ORDER-BLIND (`uhdm-dump` → workdir
path normalised → `sort`) diff:

| mover | order-blind diff lines | attribution |
|---|---|---|
| `default/SeqDriver` | 19 | the ONE `adpcm_pkg::uvm_revision_string` cell |
| `testflags/SeqDriver` | 19 | same cell |
| `default/MiniAmiq` | 19 | the ONE `svaunit_pkg::uvm_revision_string` cell |
| `testflags/MiniAmiq` | 19 | same cell |
| `default/Scoreboard` | **0** | RESUME §9's documented ~50/50 COIN — **not this law** |

The 19 lines are the same on all four: one `ref_obj` out, one `constant` +
`ref_typespec` + `string_typespec` in.

MiniAmiq's own HEAD does not move (an `unsupported_typespec (uvm_severity)`
against our `enum_typespec`, earlier in the walk than the return cell), so its
cmp line count stays 106 while its bytes move — which is exactly why the mover
had to be predicted from the census and not from the head counters.

## 6. THE GRID (`GRID.r10uvm169.txt`)

Four arms, both views, golden built by `~/git-repos/Surelog/build/bin/surelog`,
every command and every rc recorded in each arm's `cmds.txt`, and the Surelog
"units compiled" list printed so an arm that compiles to nothing cannot read
green.

| arm | what it varies | RET result |
|---|---|---|
| `g169_a_import.sv` | **ten parameter kinds** (string, empty string, int, localparam, untyped, byte, `bit[3:0]`, enum, real, typedef'd vector) × home vs wildcard importer × DEF/ELAB | **16 TOWARD, 0 AWAY**, 4 STILL-WRONG (§ 8 R3) |
| `g169_b_forms.sv` | **return forms** (bare, arithmetic, conditional, concatenation, literal, negated literal, `$clog2` argument) × **windows** (direct, `if`, explicit `begin/end`, `for`, synthetic multi-statement begin) inside a wildcard-imported package | **4 TOWARD, 0 AWAY** — only `f_bare169` and `f_two169` move; every nested-window cell keeps golden's reference |
| `g169_c_homes.sv` | **homes**: in-body class method, out-of-body class method, free function; **explicit** import vs **wildcard** import | **4 TOWARD, 0 AWAY** — the wildcard clone's free function AND its out-of-body class method both convert |
| `g169_d_scopes.sv` | the NEGATIVE homes: a module function over a module parameter, over a localparam and over a package parameter, a `$unit` function, and a MODULE-level wildcard import | **0 TOWARD, 0 AWAY** — byte-identical, as a module is not a package |

Totals over the four arms: **RET BOTH-RIGHT 59, TOWARD 24, AWAY 0,
STILL-WRONG 4, UNMOVED 31**; the whole-database OBJ census reports **AWAY 0 in
every arm**.

`g169_d_scopes.sv` moving nothing is the fence; `g169_a/b/c` moving is the
positive control that proves the boundary gate below can see.

## 7. THE WIDE BOUNDARY

`bound169.sh` over a COPY of the whole probe tree — **4738 arms**, top level and
subdirectories, both views, both binaries, children `</dev/null`, the file list
on fd 3, scratch keyed on the RELATIVE path, `PROCESSED` asserted against
`LISTED`. None of the four slang-fenced names appears in any arm path
(`FENCED_MATCHES=0`).

```
LISTED=4738 PROCESSED=4738 PRODUCED_DBS=4581 MOVED_ARMS=4 RC_DIFFS=0
```

The four movers are `g169_a_import.sv`, `g169_b_forms.sv`, `g169_c_homes.sv`
(this pass's own positive control) and **`r10uvm120repro/g120_c_homes.sv`** —
the arm of the very law this pass widens. Re-measured against golden with
`grid169.sh` + `score169.py`: **6 TOWARD, 0 AWAY, 0 STILL-WRONG** (`p120c2`
wildcard-imports `p120c1`; its clone's free function `pf` and its out-of-body
methods `oob` / `oobs` all convert, while `p120c1`'s own listings are UNMOVED).

**A FIFTH ARM was flagged and is a MEASUREMENT ARTEFACT, recorded here rather
than hidden.** The first boundary run — executed CONCURRENTLY with a `--jobs 2`
corpus sweep — also flagged `r10vrgg3repro/xi_iface_param_type/dut.sv`
(`def=MOVED elab=SAME`). That arm contains **no `return` statement at all**
(`ct169cen` reports 0 RET cells in either database), so the patch cannot reach
it. It did not reproduce: 25 pristine DEF runs and 25 pristine ELAB runs give ONE
hash each, three back-to-back `bound169.sh` runs over that arm alone report
`MOVED_ARMS=0`, and the whole 4738-arm boundary re-run on an IDLE machine
reports the four arms above and not this one. It is RESUME §9's documented
emitter nondeterminism under load.

## 8. RESIDUES AND R0

**R0 — the NEW head. SeqDriver ×2, 27 lines, `RHS: <null>`** — the SINGULAR
`SafeCompare` mirror (`~/.local/include/uhdm/BaseClass.h:193-195`) with
`rhs == nullptr`, so the object named is **golden's** and the field is one WE
leave unset: the `Return` `string_var` of `uvm_pkg::uvm_instance_scope`
(`uvm_misc.svh:340:10`) carrying a `ref_typespec` onto a `string_typespec` at
`340:10`. In our database the same function's `byte_var c` is parented at the
`begin` block where golden parents it at the FUNCTION, so the shapes around that
listing differ. **R0: a package function whose body opens with a declaration
block lists its declarations — and its `Return` variable — on the FUNCTION, not
on the body's `begin`.**

**RESIDUES this pass measured and deliberately did NOT move:**

* **R1 — the EXPLICIT `import p::f` CLONE.** Golden folds it too (arm C
  `p169ec::f_free169` is `{constant, constant}` in both views; ours is
  `{constant, ref_obj}`). The listing test that would take it is
  `importCopyTsInst != nullptr`, which names all three clone-emission sites. It
  was BUILT, MEASURED and REVERTED: our explicit-clone listing already disagrees
  with golden on its COUNT (5 objects against golden's 4 in the elab view) and
  the `pkgParamDefRhs` entry reachable there is the home DEF Rhs, whose
  `vpiSize` is **64** where golden's constant is **32** — so the arm converts a
  wrong KIND into a wrong SIZE and nothing else. Refused as a MOVED-WRONG rather
  than banked as a partial win. **Zero corpus witnesses in either corpus.**
* **R2 — the CLASS_DEFN'S OWN COPY of an out-of-body method body**, § 127's arm
  (a). Golden folds it (arm C `p169hc::c169::m_oob169` is `{constant, ref_obj}`
  against our `{ref_obj, ref_obj}`) and an IN-BODY method does NOT (arm C
  `m_in169`, one bare `ref_obj` in golden), so the arm needs an
  in-body/out-of-body separator this pass measured on exactly one cell each.
  **Zero corpus witnesses in either corpus.**
* **R3 — TWO PAYLOAD DEFECTS THE FOLD NOW REPLICATES INTO THE CLONE** (arm A,
  4 STILL-WRONG cells, both views). A `real` parameter folds to
  `1.500000 / SZ 64` where golden holds `1.5 / SZ 32`, and a TYPEDEF'D vector
  parameter folds carrying a bare `int_typespec` where golden carries
  `bit_typespec:v169_t`. Both are PRE-EXISTING and separately owned — the
  pristine binary emits exactly these payloads in the HOME package's own
  elaborated listing, where they are the typespec-linkage cluster's and the real-
  formatting family's business. The pass moves the KIND to golden's kind and
  introduces no new wrong value. **Zero corpus witnesses.**
* **R4 — the FOLDED CONSTANT'S `vpiParent` AND its `ref_typespec`'s
  `vpiFullName`.** Golden parents the folded constant at the `return_stmt` and
  its `ref_typespec` reports the FUNCTION's fullname; § 120 parents ours at the
  `param_assign` and names the PACKAGE. Neither is read by any generated
  `Compare` (RESUME §9), the head cleared with both present, and § 120 owns the
  choice — untouched.
* **R5 — the ref_obj `Actual_group` of a NESTED-WINDOW return in a clone.** Arm
  B `f_if169` / `f_beg169` / `f_for169`: golden's clone keeps the reference with
  **no** `vpiActual`, ours binds the constant. `ref_obj::Compare` DOES read
  `Actual_group`, so this is compare-visible, but it is a BINDING law, not a fold
  law, it is UNMOVED on both binaries, and it has zero corpus witnesses.

## 9. HOW TO REPRODUCE

```bash
# the census tool
g++ -O2 -std=c++17 ct169cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct169cen

# the a-priori prediction + the corpus census, from PRISTINE databases only
CEN=$PWD/ct169cen bash predsweep169.sh <pristine surelog workdir>    PRED_sl.tsv
CEN=$PWD/ct169cen bash predsweep169.sh <pristine uhdm2rtlil workdir> PRED_u2r.tsv

# the grid (golden + both binaries, both views)
for a in a_import b_forms c_homes d_scopes; do
  bash grid169.sh g169_$a.sv <pristine bin> <patched bin> /tmp/g169/$a $PWD/ct169cen
  python3 score169.py /tmp/g169/$a/cen.{g,a,b}.txt RET
  python3 score169.py /tmp/g169/$a/cen.{g,a,b}.txt OBJ
done

# the wide boundary, over a COPY of the probe tree, on an IDLE machine
PRIS=<pristine bin> PATCHED=<patched bin> bash bound169.sh <probe-tree copy> /tmp/bnd169

# the heads
bash rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
                 BuildUVMPkg Earlgrey_0_1 Rggen
```

Artifacts kept here: `PREDICT.r10uvm169.txt`, `CENSUS.r10uvm169.txt`, `GRID.r10uvm169.txt`, `BOUNDARY.r10uvm169.txt`,
`GATES.r10uvm169.txt`, and the pristine/patched head cmp logs.
