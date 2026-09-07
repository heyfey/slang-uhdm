# r10uvm197 — § `impCopyStringConstSize` — **SURELOG MATERIALIZES AN IMPORTED PARAMETER BY `clone_tree`-ING THE PACKAGE'S OWN `param_assign`, SO THE COPY'S CONSTANT KEEPS THE PACKAGE CONSTANT'S SIZE; ONLY AN INTEGRAL TARGET IS EVER RE-SIZED, AND A `string` HAS NO WIDTH** — the SimpleUVM ×2 62-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED** in either direction. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched by any driver
here; the corpus censuses walk a sweep workdir that contains them, so
`scrub197.sh` redacts their names out of every artifact — reading the fence
list out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f7a77143` |
| pristine binary | md5 `a2733a6622a01308a82a434a9e747d5e`, built from this pass's OWN worktree at a clean `f7a77143` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own binary at that commit**, and its 956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduce the committed baselines row for row (one informational dump-column cell excepted, § GATES (5)) |
| patched binary | md5 `509209e7d53d55dc7c8b79165aed9f56`, frozen `chmod 555`. The patch applied to a **FRESH `f7a77143` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on |
| production surface | `src/ParamEmit.cpp` only — **one added conjunct** on an existing gate (`ps.getType().getBitWidth() > 0`) plus the decode. Nothing deleted, no object created, no object re-pointed. |
| probe surface | `tools/probe/r10uvm197repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SimpleUVM default and testflags, 62 cmp lines, ONE head each → 17**, on a different object of a different kind (§ 7). Both modes. |
| every other row's head | cmp log **BYTE-IDENTICAL** between the two binaries — SeqDriver ×2 198, Scoreboard/default 95, MiniAmiq ×2 198, BuildUVMPkg ×2 **0**, Earlgrey_0_1 56 / **0**, Rggen/default 0. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against this pass's own pristine sweeps. 1588 surelog rows, 731 + 731 uhdm2rtlil rows. `BuildUVMPkg` ×2 and `Earlgrey_0_1/testflags` stay **CMP_EQUAL** on both binaries. |
| byte movers | **7 / 956** surelog. **6 PREDICTED BY NAME before the patched binary existed**, from PRISTINE databases alone (`SimpleUVM`, `SeqDriver`, `MiniAmiq`, ×2 modes). The 7th is `default/Scoreboard`, whose ORDER-BLIND sorted-dump diff is **ADDED 0 / REMOVED 0** — RESUME §9's ~50/50 coin. **0 / 1358** uhdm2rtlil, also predicted (that corpus holds 190 cells of this face and **not one** of them was wrong). |
| the attribution | 6 rows × **12 ADDED dump lines each = 72, every one a `\|vpiSize:` line; REMOVED 0; ADDED-THAT-ARE-NOT-`vpiSize` 0**. |
| the census (956 + 1358 databases, golden × ours) | AGREE **13450 → 13522** (+72); SIZE-DIFF **492 → 348**; ONLY-GOLDEN **48 → 48**, ONLY-OURS **314 → 314** (both untouched — a different family, R1). Cell counts identical on both sides before and after (13966 ours, 13408 golden): **nothing created, nothing destroyed**. **TO-GOLDEN 72 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / MISSED 0.** Zero-size cells **72 → 0**. |
| the grid (6 arms × 2 views = 12 arm-views, one REAL Surelog golden each) | SIZE-DIFF **92 → 0**, AGREE **174 → 220** (+46); ONLY-GOLDEN 18 → 18 and ONLY-OURS 18 → 18 (untouched); **0 nonzero rcs**. |
| the WIDE boundary (5227 sources × 2 views × 2 binaries) | `LISTED=5227 PROCESSED=5227 PRODUCED_DBS=5042 MOVED_ARMS=36 RC_DIFFS=0`. Six are this pass's own POSITIVE CONTROL. **All 36 rebuilt with a REAL Surelog golden in BOTH views and scored: 72 views, TO-GOLDEN 172, AWAY-GOLDEN 0**, 0 unbuildable. |
| the FLOOR | uvm192's 4 arms, uvm193's 4, uvm184's 2, uvm194's 3, uvm186/189/191's 3 each, uvm185's 5, uvm190's 4, uvm187's 6, uvm188's 4, uvm170's 5, uvm82–91's 113, buvm3–15's 119, sd8–12's 347 — **625 arms, MOVED = 0** (§ 8). |
| gates | goldens **23/0**, negative control **0/23**; canaries `ok=52` / `ok=8`, `changed=0` against this pass's own pristine; `ctcan2` PASS ×3; `canaudit` PASS, `FENCE-BREACH=0`; all 10 protected databases SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `f7a77143` worktree; it
came out **byte-identical** to the main tree's binary at that commit
(md5 `a2733a66…`). Its 956-row surelog sweep and both 731-row uhdm2rtlil
sweeps reproduce the committed baselines row for row. Every `cmds.txt` in
every sweep names this pass's own frozen binary, audited BY PATH
(1523 + 1458 rows per binary).

`rowheads.sh` on that sweep put SimpleUVM at **62 cmp lines, ONE head**, both
modes — the R0 r10uvm196 named (`head_pris_SimpleUVM.{default,testflags}.cmp`,
byte-identical to each other):

```
LHS golden  constant: , id:119857, line:26:39, endln:26:82
            |vpiParent: \_param_assign: , id:119856, line:26:18, endln:26:82
            |vpiDecompile:"(C) 2007-2014 Mentor Graphics Corporation"
            |vpiSize:328
            |STRING:(C) 2007-2014 Mentor Graphics Corporation
            |vpiTypespec: \_ref_typespec: (work@top) -> string_typespec @26:11-26:17
            |vpiConstType:6
RHS ours    the SAME constant, id:178991 — same span, same decompile (quotes
            included), same value, same const type, same typespec chain —
            with NO `vpiSize` line at all.
```

The line count is the head OBJECT's decompile size, not a distance.

## 2. DECODING THE JUDGE — ONE FIELD, AND `expr::Compare` READS IT FIRST

`constant` derives from `expr`, and `expr::Compare`
(`~/git-repos/UHDM/build/generated/src/expr.cpp`) compares `VpiSize` **ahead of
every `constant` field** — `constant.cpp` itself never names `VpiSize`. So a
pair that is identical in decompile, value, const type and typespec still stops
the walk here. This is the smallest kind of head: one integer on a
face-identical pair.

"No `vpiSize` line" is **not** "no field". `uhdm-dump` prints the property only
when it is non-zero
(`~/git-repos/UHDM/build/generated/src/vpi_visitor.cpp`:
`if (const int32_t n = vpi_get(vpiSize, obj_h)) …`), so the RHS above carries
`VpiSize() == 0` against golden's 328. That distinction is what turns the head
from "a missing field" into "a field somebody WROTE 0 into" — and § 4 finds the
writer.

**THE OWNER-FINDER, run on the six string parameters both sides AND the
package-side copies** (`ct197cen --cen`, the compare-visible census; the arm
`grid197/g197_a_types.sv` reproduces the whole shape at 1/1000 the size).
On SimpleUVM/default, pristine:

```
def   module_inst work@top  uvm_mgc_copyright  uvm_pkg  string_typespec  golden 328  ours 0   x2
def   module_inst work@top  uvm_cdn_copyright  uvm_pkg  string_typespec  golden 336  ours 0   x2
def   module_inst work@top  uvm_snps_copyright uvm_pkg  string_typespec  golden 224  ours 0   x2
def   module_inst work@top  uvm_cy_copyright   uvm_pkg  string_typespec  golden 328  ours 0   x2
def   module_inst work@top  uvm_nv_copyright   uvm_pkg  string_typespec  golden 256  ours 0   x2
def   module_inst work@top  uvm_revision       uvm_pkg  string_typespec  golden  56  ours 0   x2
elab  module_inst work@top  … all six …                                  AGREE
defpkg/elabpkg  package uvm_pkg  … all six …                             AGREE
```

Twelve cells per row (six parameters × the two copies § `modUnitImportParamsTwice196`
makes of a file-scope import item), **in the DEFINITION module listing only**.
The `uvm_pkg` package's own two listings and the module's ELABORATED listing
were already right — which is exactly the brief's framing, and it is what
localises the defect to the def-view materialized copy.

## 3. DECODING SURELOG — THE COPY IS A `clone_tree`, AND NOTHING RE-SIZES IT

`CompileHelper::importPackage`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:238-273`) materializes
the parameters of an imported package like this:

```cpp
auto& params = def->getParamAssignVec();
for (ParamAssign* orig : params) {
  ParamAssign* clone = new ParamAssign(*orig);
  scope->addParamAssign(clone);
  UHDM::param_assign* pass = clone->getUhdmParamAssign();
  ElaboratorContext elaboratorContext(&s, false, true);
  UHDM::param_assign* cpass =
      (UHDM::param_assign*)UHDM::clone_tree(pass, &elaboratorContext);
  param_assigns->push_back(cpass);
  ...
  the_p->VpiImported(pack_name);
}
```

The copy is a **verbatim `clone_tree` of the package's own already-compiled
`param_assign`**, Rhs constant included — same value, same decompile, same
const type, same span, **same `VpiSize`**. There is no re-sizing step in that
loop. The only place Surelog ever re-sizes a parameter's constant is
`CompileHelper::adjustSize`, and every arm of that function is an INTEGRAL
typespec kind — the population the existing type-width model already covers.
A `string` target reaches no arm of it, so the clone keeps the package
constant's own size: **8 bits per RAW SOURCE character**.

### THE GOLDEN TABLE — measured, not assumed (`grid197`, real Surelog goldens)

`grid197/g197_a_types.sv` is one package of thirteen parameters wildcard-imported
into one module, built with `surelog -parse -d coveruhdm` and again with
`-elabuhdm`. Golden's **DEFINITION** module listing:

| declaration | golden size | ours, pristine | ours, patched |
|---|---|---|---|
| `parameter string P_STR = "hello"` | **40** (8×5) | **none** | **40** |
| `parameter str_t P_TSTR = "tdef"` (a `string` TYPEDEF) | **32** | **none** | **32** |
| `parameter P_USTR = "untyped"` (UNTYPED) | 56 | 56 — already right | 56 |
| `parameter int P_INT = 7` | 32 | 32 | 32 |
| `parameter integer P_ITG = 9` | 32 | 32 | 32 |
| `parameter byte P_BYTE = 8'd3` | 8 | 8 | 8 |
| `parameter logic [7:0] P_VEC = 8'hAB` | 8 | 8 | 8 |
| `parameter nib_t P_TNIB = 4'h5` (a vector TYPEDEF) | 4 | 4 | 4 |
| `parameter bit P_BIT = 1'b1` | 1 | 1 | 1 |
| `parameter [5:0] P_RANGE = 6'd12` (RANGED-untyped) | 6 | 6 | 6 |
| `parameter time P_TIME = 3ns` | 64 | 64 | 64 |
| `parameter real P_REAL = 1.5` | 32 | 64 | 64 — **untouched, R2** |
| `parameter shortreal P_SREAL = 2.5` | 32 | 32 | 32 |

The ELABORATED listing carries the same sizes and our emission already agreed on
every row of it, before and after.

**The typed/untyped split is the tell.** `P_USTR` is a string too, and it was
already right, because the existing stamp is fenced on `typedParam`. Only a
parameter written with a TYPE that has no width was reachable.

### THE OTHER FIVE ARMS — what each one TESTS rather than agrees with

| arm | what it separates | golden | pristine → patched |
|---|---|---|---|
| `g197_b_bodyimp.sv` | a MODULE-BODY `import p::*` (one copy) instead of a file-scope one (two) | 88 | none → 88 — **the defect is not § `modUnitImportParamsTwice196`'s doubling**; it predates it |
| `g197_c_kinds.sv` | MODULE vs INTERFACE vs PROGRAM out of ONE file-scope item | 24 each | none → 24 — the interface arm is why `MiniAmiq` (an `interface_inst` def listing) is a mover |
| `g197_d_explicit.sv` | `import p::D_USED;` `p::D_UNUSED;` `p::D_EMPTY;` — EXPLICIT items, one never referenced | 32 / 96 / **0** | none/none/0 → 32/96/**0**. `D_EMPTY = ""` is the CONTROL: an empty string is size 0 on BOTH sides before and after, so the law is not "always write something" |
| `g197_e_reexport.sv` | a RE-EXPORTED string (`eOuter` wildcard-imports `eInner`) | 88 both, `vpiImported=eOuter` | none → 88, tag unchanged |
| `g197_f_escapes.sv` | `"a\nb"`, `"a\\b"`, `"a\"b"`, `"a\tb"` | **32 each** | none → 32 each |

`g197_f_escapes` settles the counting rule against a real golden: `"a\nb"` is
**32 bits = 8 × 4 RAW SOURCE characters** (`a`, `\`, `n`, `b`), not 8 × 3
interpreted ones. That is already what `emitExpr`'s `StringLiteral` arm computes
(`src/ExprEmit.cpp`, `VpiSize((int32_t)(inner.size() * 8))`), which is why this
law needs no renderer of its own — only to stop destroying the number.

## 4. DECODING SLANG — THE GATED SIZE, FOUND BY INSTRUMENT, NOT BY READING

Three throwaway `fprintf` traces (in `emitExpr`'s `StringLiteral` arm, at
`ParamEmit`'s `pa->Rhs(rhs)` tail, and over `*passigns` immediately before
`m->Param_assigns(passigns)`) answered it in one run of
`grid197/g197_b_bodyimp.sv`:

```
R197 EXPREMIT-STRLIT size=88 dec="hello world"
R197 TAIL13726 S_MGC topView=0 inPkg=0 imp=1 typed=1 size=88 val=STRING:hello world
R197 FINAL      S_MGC topView=0 inPkg=0 kind=constant size=0        <== ZEROED
R197 FINAL      U_STR topView=0 inPkg=0 kind=constant size=56       (untyped: right)
```

The constant is built CORRECTLY at 88 and is still 88 at the Rhs tail; something
between the tail and the end of `emitParameters` writes 0 into it. That
something is `src/ParamEmit.cpp`, immediately after the Rhs is installed:

```cpp
// An IMPORTED param's def-view copy is a materialized (already resolved)
// param: its bare-decimal RHS folds to the type width (int -> 32), exactly
// like the elab view — NOT the package def's raw 64-bit bare decimal.
if (isImported && !topView && typedParam &&
    rhs->UhdmType() == UHDM::uhdmconstant)
    ((UHDM::constant*)rhs)->VpiSize((int32_t)ps.getType().getBitWidth());
```

For a `string` parameter `ps.getType().getBitWidth()` is **0**, so the stamp
wipes the size the emit chain had already got right. The model behind the stamp
is § 3's `adjustSize` — which only ever touches an integral target — so the fix
is to say so:

```cpp
if (isImported && !topView && typedParam &&
    rhs->UhdmType() == UHDM::uhdmconstant &&
    ps.getType().getBitWidth() > 0)
    ((UHDM::constant*)rhs)->VpiSize((int32_t)ps.getType().getBitWidth());
```

**Why `getBitWidth() > 0` and not `!isString()`.** They are the same rule over
both corpora, and that is a MEASUREMENT, not a hope: across 2314 databases the
census finds **13966** materialized-import cells with a constant Rhs, of which
exactly **72** carry `VpiSize 0`, and **every one of them is a
`string_typespec`** (`PREDICTION.pristine.r10uvm197.txt` lists all 72 by key).
No unpacked-array, class, event, chandle or void-typed cell of this face exists
anywhere in either corpus, so the wider phrasing moves nothing the narrower one
would not. The wider phrasing is kept because it states the law
(`adjustSize` re-sizes a target that HAS a width) rather than one instance of it.

## 4b. THE CENSUS, ROW BY ROW — NINE ROWS CARRY EVERY UNEQUAL CELL

Over 956 surelog databases only **NINE** rows have any unequal
materialized-parameter cell at all, and the census prints each one before and
after:

```
row / mode                 cellsG cellsO   AGREE            SIZE-DIFF   ONLY-G  ONLY-O
default/SimpleUVM             315    315   295 ->  307      24 -> 0        8       8
testflags/SimpleUVM           315    315   295 ->  307      24 -> 0        8       8
default/SeqDriver             495    495   475 ->  487      24 -> 0        8       8
testflags/SeqDriver           495    495   475 ->  487      24 -> 0        8       8
default/MiniAmiq              720    720   700 ->  712      24 -> 0        8       8
testflags/MiniAmiq            720    720   700 ->  712      24 -> 0        8       8
default/Earlgrey_0_1         3472   3458  3458 -> 3458      14 -> 14       0       0
testflags/Earlgrey_0_1       4156   4540  4142 -> 4142     334 -> 334      0      78
default/Rggen                 860   1048   860 ->  860       0 -> 0        0     188
```

`BuildUVMPkg` ×2 and `Scoreboard`/default are NOT in the list: their
materialized-parameter cells were already equal cell for cell, and they stay so.
Every cell this pass moves is a `+12 AGREE / −24 SIZE-DIFF` on the six UVM
rows; the Earlgrey and Rggen residues (R3, and the `ONLY-OURS` multiplicity
family) are untouched to the cell.

## 5. THE MOVERS, PREDICTED BY NAME FROM PRISTINE DATABASES

`ct197cen --pred` needs no golden, so it ran over **every** database of the
PRISTINE sweeps, before the patched binary was built:

```
surelog   956 databases  13966 cells   72 zero-size cells   6 MOVER ROWS
u2r      1358 databases    190 cells    0 zero-size cells   0 MOVER ROWS
```

and the six rows, by name:

```
default/SimpleUVM   12 cells   def   module_inst work@top                  x uvm_pkg
testflags/SimpleUVM 12 cells   (same)
default/SeqDriver   12 cells   def   module_inst work@top_tb               x {uvm_pkg, adpcm_pkg}
testflags/SeqDriver 12 cells   (same)
default/MiniAmiq    12 cells   defif interface_inst work@svaunit_vpi_interface
                                                                          x {uvm_pkg, svaunit_pkg}
testflags/MiniAmiq  12 cells   (same)
```

`byteverify SELFCHECK=1` on the patched sweep then reported **7 / 956**: those
six, plus `default/Scoreboard`.

## 6. THE ATTRIBUTION

`attrib197.sh` dumps both databases, normalises the workdir path the dump
embeds, SORTS both and diffs — so a pure ORDER flip scores zero
(RESUME §9: `Scoreboard/default` is a ~50/50 coin per invocation).

```
default/MiniAmiq    ADDED=12 REMOVED=0 ADDED-THAT-ARE-NOT-vpiSize=0   zero-size cells 12 -> 0
default/Scoreboard  ADDED= 0 REMOVED=0 ADDED-THAT-ARE-NOT-vpiSize=0   zero-size cells  0 -> 0
default/SeqDriver   ADDED=12 REMOVED=0 ADDED-THAT-ARE-NOT-vpiSize=0   zero-size cells 12 -> 0
default/SimpleUVM   ADDED=12 REMOVED=0 ADDED-THAT-ARE-NOT-vpiSize=0   zero-size cells 12 -> 0
testflags/MiniAmiq  ADDED=12 REMOVED=0 ADDED-THAT-ARE-NOT-vpiSize=0   zero-size cells 12 -> 0
testflags/SeqDriver ADDED=12 REMOVED=0 ADDED-THAT-ARE-NOT-vpiSize=0   zero-size cells 12 -> 0
testflags/SimpleUVM ADDED=12 REMOVED=0 ADDED-THAT-ARE-NOT-vpiSize=0   zero-size cells 12 -> 0
-- TOTAL sorted-diff lines=72 REMOVED-TOTAL=0 ADDED-NOT-vpiSize=0
```

and the 72 added lines, in full:

```
  20 x |vpiSize:328   (uvm_mgc_copyright 41 chars, uvm_cy_copyright 41 chars)
  10 x |vpiSize:336   (uvm_cdn_copyright, 42)
  10 x |vpiSize:256   (uvm_nv_copyright, 32)
  10 x |vpiSize:224   (uvm_snps_copyright, 28)
  10 x |vpiSize:56    (uvm_revision "UVM.1.2", 7)
```

`Scoreboard/default` is the COIN: 0 added, 0 removed, order-blind. Its cmp log
is byte-identical between the two binaries, and `ct197cen --pred` finds no cell
of this face in it at all.

`SeqDriver` and `MiniAmiq` are byte movers whose **cmp logs are BYTE-IDENTICAL**
(198 lines, one head, both modes): their heads fire earlier than this law's
cells, so the 12 sizes each gained sit behind the head. They move toward golden
and nothing there regresses.

## 7. THE HEAD AFTER — AND R0

```
SimpleUVM default and testflags, 62 -> 17 cmp lines, ONE head each

LHS: <null>
RHS ours    ref_typespec: (work@top.UVM_RADIX), id:179060
            |vpiParent: \_parameter: (work@top.UVM_RADIX), id:179059, @99:11-99:20
            |vpiFullName:work@top.UVM_RADIX
            |vpiActual: \_int_typespec: , id:179071, @99:1-99:32
```

**R0 — A MATERIALIZED IMPORT COPY OF AN UNTYPED PACKAGE PARAMETER CARRIES NO
`ref_typespec` IN GOLDEN, AND OURS MINTS ONE.** The `LHS: <null>` arm is
`BaseClass.h`'s SINGULAR overload MIRRORED (RESUME §9): golden's
`parameter::Typespec()` is null, ours is a `ref_typespec` bound to an
`int_typespec` spanning the whole declaration line, so the judge names OURS as
the extra value. This is the exact residue this pass's own census already
isolated and left alone — four parameters per copy, eight cells per SimpleUVM
mode:

```
ONLY-GOLDEN  def module_inst work@top  UVM_ALL_ON    uvm_pkg  -              3  BIN:000000101010101  n=2
ONLY-OURS    def module_inst work@top  UVM_ALL_ON    uvm_pkg  int_typespec   3  BIN:000000101010101  n=2
ONLY-GOLDEN  def module_inst work@top  UVM_DEFAULT   uvm_pkg  -              3  BIN:000010101010101  n=2
ONLY-OURS    def module_inst work@top  UVM_DEFAULT   uvm_pkg  int_typespec   3  BIN:000010101010101  n=2
ONLY-GOLDEN  def module_inst work@top  UVM_FLAGS_ON  uvm_pkg  -              3  BIN:000000101010101  n=2
ONLY-OURS    def module_inst work@top  UVM_FLAGS_ON  uvm_pkg  int_typespec   3  BIN:000000101010101  n=2
ONLY-GOLDEN  def module_inst work@top  UVM_RADIX     uvm_pkg  -              5  HEX:f000000         n=2
ONLY-OURS    def module_inst work@top  UVM_RADIX     uvm_pkg  int_typespec   5  HEX:f000000         n=2
```

All four are UNTYPED `parameter`s of `uvm_pkg` whose value is an UNSIZED
BASED literal (`uvm_object_globals.svh:99` `parameter UVM_RADIX = 'hf000000;`,
`:180-182` `UVM_DEFAULT`/`UVM_ALL_ON`/`UVM_FLAGS_ON` = `'b000…`). The census puts the
whole family at **48 ONLY-GOLDEN / 314 ONLY-OURS cells** corpus-wide, unchanged
by this pass, and `PREDICTION` shows it has nothing to do with sizes. The next
pass should read § 3's `clone_tree` model again: if the copy is a verbatim clone
of the package's `param_assign`, then whatever the PACKAGE listing carries is
what the copy must carry — so the question to answer first is what
`uvm_pkg`'s OWN listing does with those four, on both sides.

## 8. THE BOUNDARY AND THE FLOOR

```
LISTED=5227 PROCESSED=5227 PRODUCED_DBS=5042 MOVED_ARMS=36 RC_DIFFS=0
```

Subdirectory arms are compiled (the list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, PROCESSED is asserted
against LISTED). This pass's six `grid197/g197_*.sv` are the POSITIVE CONTROL —
they are all in the moved list, and without them a green gate would prove
nothing. Several `--elabuhdm` runs segfault; they segfault **identically on
both binaries** (`RC_DIFFS=0`), and the counter records it rather than hiding it.

**All 36 moved arms were rebuilt with a REAL Surelog golden in BOTH views and
scored** (`bscore197.sh`, 72 views, 0 unbuildable, 0 missing):

```
-- SCORED views=72 MISSING-ARMS=0 NODB-views=0 TO-GOLDEN=172 AWAY-GOLDEN=0
```

No view loses AGREE and no view's ONLY-GOLDEN or ONLY-OURS set grows. The
biggest single winner is `r10v146repro/v09_homes.sv` (AGREE 40 → 50 per view);
uvm196's own positive control `grid196/g196_h_self.sv` moves TO-GOLDEN 4 per
view because it declares `parameter string ANVIL_NAME = "anvil"`.

**THE FLOOR IS UNTOUCHED**, verified BY NAME in the moved list rather than
assumed:

```
uvm192 (4 arms)  uvm193 (4)  uvm184 (2)  uvm194 (3)  uvm186 (3)  uvm189 (3)
uvm191 (3)  uvm185 (5)  uvm190 (4)  uvm187 (6)  uvm188 (4)  uvm170 (5)
uvm82-91 (113)  buvm3-15 (119)  sd8-12 (347)
625 arms, MOVED = 0
```

No static-address false mover appeared: all 36 moved arms are accounted for by
content, and every one contains a `string` package parameter that an import
materialises.

## 9. RESIDUES, ranked

* **R0 — the untyped materialized copy's missing/extra `ref_typespec`**, § 7.
  The current head, both SimpleUVM modes, 17 cmp lines, one field. 48
  ONLY-GOLDEN / 314 ONLY-OURS cells corpus-wide.
* **R1 — the ENUM-typed materialized copy's size, the MIRROR of this law.**
  On `r10uvm168repro/g168_b_form.sv` (a real golden), a materialized copy of an
  `enum`-typed package parameter reads golden **size 0** and ours **32**: the
  same type-width stamp, now writing a number where Surelog's `clone_tree`
  wrote none, because an `enum_typespec` is not one of `adjustSize`'s arms
  either. It is arm-visible, not corpus-visible today (`g168_b_form` residual
  SIZE-DIFF 16 → 14 across this pass, i.e. untouched), and it is the natural
  next narrowing of the very gate this pass widened. **Do not narrow it
  blind:** the same stamp is load-bearing for `int` copies (`P_INT` 32 against
  the package def's 64), so the next pass must census which typespec kinds
  golden re-sizes before moving the fence.
* **R2 — the `real` materialized copy's size**, § 3's table: golden 32, ours 64,
  in the DEF module listing and in the package's own ELAB listing
  (`real_typespec`), together with a `REAL:1.5` vs `REAL:1.500000` decompile and
  a `short_real_typespec` vs `real_typespec` kind. Pre-existing, identical
  before and after, 18 one-sided grid cells. No corpus row carries it.
* **R3 — Earlgrey's `other`-view `int_typespec` size family.** The census's
  residual SIZE-DIFF 348 is entirely `Earlgrey_0_1` (default 14, testflags 334),
  every cell a materialized copy whose owner is in NEITHER `AllModules` nor
  `TopModules` (the design-level / generate-scope listings). Identical before
  and after; `Earlgrey_0_1/testflags` is CMP_EQUAL, so it is judge-invisible
  there today.
* **R4 — an ops trap worth carrying.** `cen197.sh` runs its rows under
  `xargs -P`, so two rows' lines can INTERLEAVE and a `CENSUM` record can end up
  glued to the tail of another row's line. A `^`-anchored `grep -c '^CENSUM'`
  read **952** where the truth was **956**. `censum197.sh` totals with `grep -o`
  over the whole record and ASSERTS record-count == row-count; every census
  number in this README comes from it, and the `-- TOTALS` line inside the raw
  census files (which uses the anchored form) must not be quoted.

## 10. THE FILES

| file | what it is |
|---|---|
| `ct197cen.cpp` | the census / mover predictor. `--pred <ours>` needs no golden and lists every materialized-import cell whose constant carries `VpiSize 0`; `--cen <golden> <ours>` is the compare-visible multiset join, keyed on view + owner face + param + `vpiImported` + typespec kind + const type + value, payload `VpiSize`. Golden-vs-golden calibrates to **AGREE=cells, SIZE-DIFF 0, ONLY-* 0**. |
| `cen197.sh` | runs either mode over a whole `verify_golden` workdir; each row's golden is read out of THAT ROW'S OWN `cmds.txt`, never guessed from a test name. |
| `censum197.sh` | the ROBUST totaller (R4). |
| `grid197/` + `grid197.sh` | six arms × two views × one real Surelog golden each, scored on both binaries. |
| `bound197.sh` / `bscore197.sh` | the wide boundary and the golden scoring of every arm it moved. |
| `attrib197.sh` | the order-blind sorted-dump attribution plus the zero-size-cell count. |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the gate battery (copies, unmodified). |
| `scrub197.sh` | redacts the four fenced test names out of the evidence files, reading the list out of `canaudit.sh`. |
| `GATES.…txt` | every gate, with the numbers. |
| `CENSUS.{pristine,patched}.{surelog,u2r}.…txt` | the four corpus censuses, trimmed to the unequal rows plus robust totals. |
| `PREDICTION.{pristine,patched}.…txt` | the mover prediction, made from PRISTINE databases only, and its re-run after the patch. |
| `GRID.…txt`, `BOUNDARY.…txt`, `BOUNDARY_MOVERS.…txt`, `BOUNDARY_SCORES.…txt`, `ATTRIBUTION.…txt` | the raw evidence behind § 3, § 6 and § 8. |
| `head_{pris,pat}_SimpleUVM.{default,testflags}.cmp` | the official `uhdm-cmp` head, before and after. |

## 11. REPRODUCING

```bash
git worktree add /tmp/wt f7a77143 && cd /tmp/wt
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 2
cp build/slang-uhdm /tmp/pris && chmod 555 /tmp/pris        # md5 a2733a66…
git apply /tmp/r10uvm197.patch && cmake --build build -j 2
cp build/slang-uhdm /tmp/pat && chmod 555 /tmp/pat          # md5 509209e7…

cd tools/probe/r10uvm197repro
g++ -O2 -std=c++17 ct197cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct197cen
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=/tmp/ct197cen ./grid197.sh grid197 /tmp/g197 /tmp/GRID.txt
#   -- PRISTINE  12 cells, SIZE-DIFF total 92 …
#   -- PATCHED   12 cells, SIZE-DIFF total  0 …   (a "cell" here is one arm-view)

# sweeps: export SLANG_UHDM per binary, --jobs 2, your OWN --out/--workdir,
# then audit every cmds.txt by binary PATH before believing a single row.
CEN=/tmp/ct197cen ./cen197.sh --pred <pristine workdir> /tmp/PRED.txt 2
./censum197.sh /tmp/PRED.txt
```
