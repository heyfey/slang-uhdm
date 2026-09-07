# r10uvm199 — § `impUnsizedBasedLhsNoTs199` — **THE `param_assign` Lhs CLONE OF A MATERIALIZED IMPORT MIRRORS ITS `Parameters`-LISTING TWIN: WHEN § `implicitUnsizedBasedNoTs102` DECLINES THE TYPESPEC ON AN UNTYPED PARAMETER WITH AN UNSIZED BASED DEFAULT, THE CLONE DECLINES IT TOO** — the SimpleUVM ×2 17-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED** in either direction. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched by any driver
here; the corpus censuses walk a sweep workdir that contains them, so
`scrub199.sh` redacts their names out of every artifact — reading the fence
list out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `078597b7` |
| pristine binary | md5 `509209e7d53d55dc7c8b79165aed9f56`, built from this pass's OWN worktree at a clean `078597b7` and frozen `chmod 555` before any sweep. It is **byte-identical to r10uvm197's committed patched binary**, which IS the binary of `078597b7`; its 956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduce the committed baselines row for row (one informational dump-column cell excepted, § 9), and `rowheads.sh` on it reproduces r10uvm197's committed post-landing head table exactly. |
| patched binary | md5 `e950ec36eb6d946937966eeee18f8642`, frozen `chmod 555`. The patch applied to a **FRESH `078597b7` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on. |
| production surface | `src/ParamEmit.cpp` only — **one `if (up->Typespec())` around four existing lines**, plus the decode. Nothing deleted, no object re-pointed, no name written. |
| probe surface | `tools/probe/r10uvm199repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SimpleUVM default and testflags, 17 cmp lines, ONE head each → 17**, on a **DIFFERENT OBJECT, from the OTHER SIDE** (§ 7). The pristine head is `LHS: <null>` against a `ref_typespec` of OURS on `work@top.UVM_RADIX`; the patched head is its MIRROR, `RHS: <null>` against a `ref_typespec` of GOLDEN's on the Rhs CONSTANT of `UVM_SETINT`. Both modes. The count is the head object's decompile size, not a distance. |
| every other row's head | cmp log **BYTE-IDENTICAL** between the two binaries — SeqDriver ×2 198, Scoreboard/default 95, MiniAmiq ×2 198, BuildUVMPkg ×2 **0**, Earlgrey_0_1 56 / **0**, Rggen/default 0. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against this pass's own pristine sweeps. 1588 surelog rows, 731 + 731 uhdm2rtlil rows. `BuildUVMPkg` ×2, `Earlgrey_0_1/testflags` and `Rggen/default` stay **CMP_EQUAL** with both columns byte-identical. |
| byte movers | **7 / 956** surelog. **6 PREDICTED BY NAME before the patched binary existed**, from PRISTINE databases alone (`SimpleUVM`, `SeqDriver`, `MiniAmiq`, ×2 modes). The 7th is `default/Scoreboard`, whose ORDER-BLIND sorted-dump diff is **ADDED 0 / REMOVED 0** — RESUME §9's ~50/50 coin. **0 / 1358** uhdm2rtlil, also predicted (that corpus holds 236 cells of this face and **not one** of them is asymmetric). |
| the attribution | 6 rows × **160 REMOVED dump lines each = 960; ADDED 0**. At OBJECT level (`ct199obj`), on SimpleUVM/default: **exactly 40 objects removed**, `ref_typespec` −8, `int_typespec` −8, `range` −8, `constant` −16 — one declined `ref_typespec` → its `int_typespec` → its `range` → the range's two bound constants, times the 8 cells. **Nothing created, nothing re-spanned, nothing re-typed; no other kind's count moves at all.** |
| the census (956 + 1358 databases, golden × ours, BOTH slots) | surelog AGREE **27586 → 27634** (+48); TS-DIFF **764 → 668** (−96); ONLY-GOLDEN **0 → 0**, ONLY-OURS **162 → 162** (both untouched — Earlgrey's multiplicity family, R2). Cell counts identical on both sides before and after (27662 golden, 28436 ours): **nothing created, nothing destroyed**. **TO-GOLDEN 48 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / MISSED 0.** u2r 472 cells, **all AGREE before and after**. |
| the grid (7 arms × 2 views = 14 arm-views, one REAL Surelog golden each) | CALIB golden-vs-golden **AGREE 448, everything else 0**. PRISTINE TS-DIFF **100**, AGREE **382**; PATCHED TS-DIFF **0**, AGREE **432** (+50); ONLY-GOLDEN 16 → 16 and ONLY-OURS 16 → 16 (untouched); **0 nonzero rcs**. |
| the WIDE boundary (5234 sources × 2 views × 2 binaries) | `LISTED=5234 PROCESSED=5234 PRODUCED_DBS=5049 MOVED_ARMS=20 RC_DIFFS=0`. Six are this pass's own POSITIVE CONTROL. **All 20 rebuilt with a REAL Surelog golden in BOTH views and scored: 40 views, TO-GOLDEN 172, AWAY-GOLDEN 0**, 0 unbuildable. |
| the FLOOR | uvm197's 6 arms, uvm196's 9, uvm192's 4, uvm193's 4, uvm184's 2, uvm194's 3, uvm186/189/191's 3 each, uvm185's 5, uvm190's 4, uvm187's 6, uvm188's 4, uvm170's 5, uvm82–91's 141, buvm3–15's 192, sd8–12's 347 — **741 arms, MOVED = 0** (§ 8). |
| gates | goldens **23/0**, negative control **0/23**; canaries `ok=52` / `ok=8`, `changed=0` against this pass's own pristine; `ctcan2` PASS ×3; `canaudit` PASS, `FENCE-BREACH=0`; all 10 protected databases SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `078597b7` worktree; it
came out **byte-identical to r10uvm197's committed patched binary**
(md5 `509209e7…`), which is the binary of `078597b7`. Its 956-row surelog sweep
and both 731-row uhdm2rtlil sweeps reproduce the committed baselines row for
row, and `rowheads.sh` on that sweep reproduces r10uvm197's committed
post-landing head table to the line:

```
SeqDriver ×2 198 · SimpleUVM ×2 17 · Scoreboard/default 95 · MiniAmiq ×2 198
BuildUVMPkg ×2 0 · Earlgrey_0_1 56 / 0 · Rggen/default 0
```

Every `cmds.txt` in every sweep names this pass's own frozen binary, audited BY
PATH (1573 + 1458 files per binary, 0 naming any other).

The SimpleUVM head is **17 cmp lines, ONE head**, both modes
(`head_pris_SimpleUVM.{default,testflags}.cmp`, byte-identical to each other) —
the R0 r10uvm197 named:

```
LHS: <null>
RHS ours    ref_typespec: (work@top.UVM_RADIX), id:179060
            |vpiParent: \_parameter: (work@top.UVM_RADIX), id:179059, @99:11-99:20
            |vpiFullName:work@top.UVM_RADIX
            |vpiActual: \_int_typespec: , id:179071, @99:1-99:32
```

## 2. DECODING THE JUDGE — THE cmp LOG CANNOT NAME THE OWNER, AND THE OWNER-FINDER CAN

`LHS: <null>` with a full RHS is `BaseClass.h`'s SINGULAR `SafeCompare`
overload MIRRORED (RESUME §9): it names the **VALUE** that only one side
carries — golden's `parameter::Typespec()` is null, ours is a `ref_typespec` —
so the judge prints ours as the extra value and never prints the owner.

That is a problem, because on our side **TWO DISTINCT `parameter` objects carry
that same name, the same span and the same fullname**: the element of the
scope's `Parameters` vector (`up` in `src/ParamEmit.cpp`) and the `Lhs` of the
matching `param_assign` (`upLhs9`, § 4). `scope::Compare` walks both vectors,
so "which of the two is it" cannot be read off the cmp log at all. `ct199own`
answers it by POSITION — every `parameter` of that name in the database, with
its id, its `vpiImported` tag, its typespec, and the LISTING it sits in named
by owner and INDEX. On SimpleUVM/default, **all four parameters, both sides,
including the package-side originals** (full text in
`DECODE.slots.SimpleUVM.r10uvm199.txt`; `UVM_RADIX` shown, the other three are
identical in shape):

```
                                             GOLDEN                       OURS (pristine)
def     module_inst work@top  Parameters[26]/90        #119791 NO-TYPESPEC   #179056 NO-TYPESPEC
def     module_inst work@top  Parameters[71]/90        #120230 NO-TYPESPEC   #179549 NO-TYPESPEC
def     module_inst work@top  Param_assigns[ 8]/90.Lhs #119908 NO-TYPESPEC   #179059 ref_typespec -> int_typespec  <== THE HEAD
def     module_inst work@top  Param_assigns[53]/90.Lhs #120347 NO-TYPESPEC   #179552 ref_typespec -> int_typespec  <== and its twin
elab    module_inst work@top  Parameters[26] / [71]              NO-TYPESPEC          NO-TYPESPEC
elab    module_inst work@top  Param_assigns[8] / [53].Lhs        NO-TYPESPEC          NO-TYPESPEC
other   class_defn  work@env  Parameters + Param_assigns.Lhs     NO-TYPESPEC          NO-TYPESPEC
defpkg  package uvm_pkg  Parameters[8]/45                #60962 NO-TYPESPEC      #195 NO-TYPESPEC
defpkg  package uvm_pkg  Param_assigns[8]/45.Lhs         #60962 NO-TYPESPEC      #195 NO-TYPESPEC
elabpkg package uvm_pkg  ... the same ...                       NO-TYPESPEC          NO-TYPESPEC
```

Three things fall out of that table, and they are the whole decode.

1. **The head object is the DEF-view `Param_assigns[i].Lhs`, not the
   `Parameters[i]` entry.** Our `Parameters` entries are already right —
   `NO-TYPESPEC`, matching golden — because § `implicitUnsizedBasedNoTs102`
   already declines there. Only the Lhs clone was wrong. Eight cells per
   SimpleUVM mode: four parameters × the two copies § `modUnitImportParamsTwice196`
   makes of a file-scope import item.
2. **THE PACKAGE'S OWN LISTING — the first thing the brief said to read —
   carries NO typespec, on BOTH sides, in BOTH package views.** That is the
   `clone_tree` SOURCE (§ 3), and it settles the law without any appeal to
   width rules: whatever the package declaration carries is what the copy must
   carry, and here it carries nothing.
3. **Surelog SHARES one object between `Parameters[i]` and
   `Param_assigns[i].Lhs` in the ELAB and the PACKAGE views (#197927, #60962)
   and uses DISTINCT objects in the DEF module view (#119791 vs #119908) — and
   so do we** (#180615 shared in elab, #179056 vs #179059 distinct in def).
   The def-view clone is not our invention; it is § 4's existing model and it
   stays. Only its typespec goes.

The Rhs constant is identical on both sides for all four
(`constType=5 size=-1 HEX:f000000`, `constType=3 size=-1 BIN:…`) — a size of
**−1** is exactly the unsized-based signature § 3 turns on.

## 3. DECODING SURELOG — WHEN THE CLONE-TREE CARRIES A TYPESPEC, PER DECLARED-TYPE KIND

`CompileHelper::importPackage`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:238-273`) materializes
an imported package's parameters by `clone_tree`-ing the package's own
already-compiled `param_assign` (the model r10uvm197 decoded and this pass
extends). Nothing in that loop adds a typespec. So the copy carries a typespec
exactly when the PACKAGE DECLARATION does — and what the package declaration
does is `CompileHelper.cpp:3795-3840`, which derives an implicit parameter type
from the reduced constant and, for `vpiHexConst` / `vpiOctConst` /
`vpiBinaryConst`, creates and attaches the `int_typespec` **only when
`VpiSize() != -1`** (`case vpiDecConst: break;` is why a decimal-based literal
never gets one at all). An UNSIZED based literal has size −1. That is
§ `implicitUnsizedBasedNoTs102`, and this pass is its `param_assign`-Lhs half.

### THE GOLDEN TABLE — measured, not assumed (`grid199`, real Surelog goldens)

`grid199/g199_a_untyped.sv` and `g199_g_typed.sv` are two packages
wildcard-imported at FILE scope into one module each, built with
`surelog -parse -d coveruhdm` and again with `-elabuhdm`. The DEF-view
materialized copy's `Param_assigns[i].Lhs` typespec:

| declaration | golden | ours, pristine | ours, patched |
|---|---|---|---|
| `parameter A_UHEX = 'hf000000` (UNSIZED-BASED hex) | **none** | `int_typespec` | **none** |
| `parameter A_UBIN = 'b000000101010101` (UNSIZED-BASED bin) | **none** | `int_typespec` | **none** |
| `parameter A_UOCT = 'o777` (UNSIZED-BASED oct) | **none** | `int_typespec` | **none** |
| `parameter A_USZ = 8'hab` (SIZED-BASED) | `int_typespec` | `int_typespec` | `int_typespec` |
| `parameter A_UDEC = 13` (PLAIN DECIMAL) | `int_typespec` | `int_typespec` | `int_typespec` |
| `parameter A_UDB = 'd13` (DECIMAL-BASED) | none | none — already right | none |
| `parameter A_UNB = '0` (UNBASED-UNSIZED) | none | none — already right | none |
| `parameter A_USTR = "untyped"` (STRING LITERAL) | `string_typespec` | `string_typespec` | `string_typespec` |
| `parameter [5:0] G_RNG = 6'd12` (RANGED-untyped) | `int_typespec` | `int_typespec` | `int_typespec` |
| `parameter signed G_SGN = 'h5` (explicit SIGNING) | `int_typespec` | `int_typespec` | `int_typespec` |
| `parameter int G_INT = 7` | `int_typespec` | `int_typespec` | `int_typespec` |
| `parameter string G_STR = "hello"` | `string_typespec` | `string_typespec` | `string_typespec` |
| `parameter nib_t G_TNIB = 4'h5` (TYPEDEF'd vector) | `logic_typespec` | `logic_typespec` | `logic_typespec` |

**Three rows move and ten do not**, and the ten are the fence. `A_UDB` and
`A_UNB` are the arms that prove the fence is not "always decline": golden gives
those none either, and we already gave them none — they were never on the
`wantTs` path (`!decBasedInit`, `!unbasedInit`). `A_USZ` and `G_SGN` are the
arms that prove it is not "decline for every untyped parameter": a WIDTH (a
size, a range, a signing) puts the declaration back on the typespec path in
golden, and the patched binary keeps it there.

`g199_g_typed.sv` is also the boundary's NEGATIVE control: it is the one grid
arm that did **not** move (§ 8).

### THE OTHER FIVE ARMS — what each one TESTS rather than agrees with

| arm | what it separates | golden | pristine → patched |
|---|---|---|---|
| `g199_b_bodyimp.sv` | a MODULE-BODY `import p::*` (ONE copy) instead of a file-scope one (TWO) | none | `int_typespec` → none. **The defect is not § `modUnitImportParamsTwice196`'s doubling** — the copy COUNT does not change the verdict |
| `g199_c_kinds.sv` | MODULE vs INTERFACE vs PROGRAM out of ONE file-scope item | none in all three | `int_typespec` → none in all three. The `defif` arm is why `MiniAmiq` (an `interface_inst` def listing) is a mover |
| `g199_d_explicit.sv` | `import p::D_UHEX;` `p::D_UNUSED;` `p::D_UDEC;` — EXPLICIT items, one never referenced | none / none / **`int_typespec`** | none/none → the two unsized-based decline, and **`D_UDEC` (plain decimal) KEEPS its typespec on both binaries** — the CONTROL that convicts a blind widening |
| `g199_e_reexport.sv` | a RE-EXPORTED unsized-based param (`eOuter` wildcard-imports `eInner`) | none for both | `int_typespec` → none, `vpiImported=eOuter` unchanged on both |
| `g199_f_uvmshape.sv` | the CORPUS SHAPE at 1/1000 the size: `uvm_object_globals.svh`'s four declarations verbatim, next to a `parameter int` and a `parameter string` that must KEEP theirs | none ×4, `int_typespec`, `string_typespec` | the four decline; **`F_KEEP_INT` and `F_KEEP_STR` are byte-for-byte unchanged and match golden slot for slot** |

## 4. DECODING SLANG — ONE UNGATED ATTACH, FOUND BY THE SLOT TABLE

`src/ParamEmit.cpp:4732` already carries the declaration-side law:

```cpp
bool implicitUnsizedBasedNoTs102 =
    unsizedBasedInit && !typedParam && !isRangedUntypedParam(ps) &&
    !implicitSigning102 && !overridden && !funcScope;
if (!cliOv && !implicitUnsizedBasedNoTs102)
    up->Typespec(prt);            // <- correctly DECLINED for UVM_RADIX
```

and 500 lines later builds the DEF-view materialized copy's `param_assign` Lhs
clone (`:5189-5236`, § the `wantLhsClone9` block). Its typespec attach was
gated only on whether the ref `prt` was **built**, never on whether it was
**attached**:

```cpp
prtLhs9 = s.MakeRef_typespec();               // pristine: unconditional
prtLhs9->VpiFullName(std::string(prt->VpiFullName()));
prtLhs9->VpiParent(upLhs9);
upLhs9->Typespec(prtLhs9);
```

`prt` is built whenever `wantTs` is true, and `wantTs` IS true for
`parameter UVM_RADIX = 'hf000000` (`literalInit && !unbasedInit &&
!decBasedInit`); only the ATTACH to `up` is declined. So the clone ended up
with a typespec its own twin has not got — and the fix is to say that the clone
mirrors the twin:

```cpp
if (up->Typespec()) {
    prtLhs9 = s.MakeRef_typespec();
    prtLhs9->VpiFullName(std::string(prt->VpiFullName()));
    prtLhs9->VpiParent(upLhs9);
    upLhs9->Typespec(prtLhs9);
}
```

**Why `up->Typespec()` and not a restatement of `implicitUnsizedBasedNoTs102`.**
The clone is a `clone_tree` COPY of the same declaration (§ 3); every reason
`up` has for carrying or not carrying a typespec is a reason the copy has. The
mirror is the law; restating the predicate would leave the two free to drift.
It is also the narrower phrasing over both corpora — a MEASUREMENT, not a hope:
across 2314 databases the predictor finds **13228 + 236 = 13464** materialized-
copy `param_assign` Lhs cells, of which exactly **48** carry a typespec their
`Parameters` twin does not, and every one of them is an untyped parameter with
an unsized based default (`PREDICTION.pristine.surelog.r10uvm199.txt` lists all
48 by key). No `cliOv` cell of this face exists anywhere in either corpus or
anywhere in the 5234-source boundary, so the two phrasings move exactly the
same cells.

Downstream is untouched: `pendingDefParamTs` (`:14771`) and the late
`Actual_typespec` binding (`:14957`) were already written `if (upLhs9 &&
prtLhs9)` / `if (prtLhs9 && …)`, so a null `prtLhs9` simply skips them. The Lhs
clone PARAMETER still exists — golden has one too (§ 2).

## 5. THE CENSUS AND THE MOVERS, PREDICTED BY NAME FROM PRISTINE DATABASES

`ct199cen --pred` needs no golden, so it ran over **every** database of the
PRISTINE sweeps, before the patched binary was built:

```
surelog   956 databases  13228 Lhs cells   48 ts-asymmetric cells   6 MOVER ROWS
u2r      1358 databases    236 Lhs cells    0 ts-asymmetric cells   0 MOVER ROWS
```

and the six rows, by name, with their cells:

```
default/SimpleUVM   8 cells  def   module_inst  work@top                    × uvm_pkg           (4 params × 2 copies)
testflags/SimpleUVM 8 cells  (same)
default/SeqDriver   8 cells  def   module_inst  work@top_tb                 × {uvm_pkg, adpcm_pkg}
testflags/SeqDriver 8 cells  (same)
default/MiniAmiq    8 cells  defif interface_inst work@svaunit_vpi_interface × {uvm_pkg, svaunit_pkg}
testflags/MiniAmiq  8 cells  (same)
```

all four parameters being `uvm_object_globals.svh:99` `UVM_RADIX = 'hf000000`
and `:180-182` `UVM_DEFAULT` / `UVM_ALL_ON` / `UVM_FLAGS_ON` = `'b…`.
`byteverify SELFCHECK=1` on the patched sweep then reported **7 / 956**: those
six, plus `default/Scoreboard`.

The COMPARE-VISIBLE census (golden × ours, both slots, each row's golden read
out of THAT ROW'S OWN `cmds.txt`) puts every unequal cell on **eight** rows,
and prints each before and after:

```
row / mode                 cellsG cellsO   AGREE            TS-DIFF     ONLY-G  ONLY-O
default/SimpleUVM             450    450   442 ->  450      16 -> 0        0       0
testflags/SimpleUVM           450    450   442 ->  450      16 -> 0        0       0
default/SeqDriver             765    765   757 ->  765      16 -> 0        0       0
testflags/SeqDriver           765    765   757 ->  765      16 -> 0        0       0
default/MiniAmiq              900    900   892 ->  900      16 -> 0        0       0
testflags/MiniAmiq            900    900   892 ->  900      16 -> 0        0       0
default/Earlgrey_0_1         7422   7408  7408 -> 7408      14 -> 14       0       0
testflags/Earlgrey_0_1       8838   9626  8824 -> 8824     654 -> 654      0     162
```

The six UVM rows reach **cell-for-cell equality** on this face. The Earlgrey
residue (R2) is untouched to the cell — every one of its cells has an
`int_typespec` on BOTH sides and differs only in MULTIPLICITY on the
`other`-view (design-level / generate-scope) listings, which is why the
predictor correctly calls Earlgrey a non-mover. `BuildUVMPkg` ×2, `Rggen` and
`Scoreboard`/default carry no unequal cell before or after.

Robust totals (`censum199.sh`, R4): surelog `records=956 rows=956`
AGREE **27586 → 27634**, TS-DIFF **764 → 668**, ONLY-GOLDEN **0 → 0**,
ONLY-OURS **162 → 162**, `cellsG` and `cellsO` identical before and after.
u2r `records=1358 rows=1358` AGREE **472 → 472**, everything else 0.
**TO-GOLDEN 48 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / MISSED 0.**

## 6. THE ATTRIBUTION

`attrib199.sh` dumps both databases, normalises the workdir path the dump
embeds, SORTS both and diffs — so a pure ORDER flip scores zero
(RESUME §9: `Scoreboard/default` is a ~50/50 coin per invocation).

```
default/MiniAmiq    ADDED=0 REMOVED=160    ts-asymmetric cells 8 -> 0
default/Scoreboard  ADDED=0 REMOVED=  0    ts-asymmetric cells 0 -> 0    <== THE COIN
default/SeqDriver   ADDED=0 REMOVED=160    ts-asymmetric cells 8 -> 0
default/SimpleUVM   ADDED=0 REMOVED=160    ts-asymmetric cells 8 -> 0
testflags/MiniAmiq  ADDED=0 REMOVED=160    ts-asymmetric cells 8 -> 0
testflags/SeqDriver ADDED=0 REMOVED=160    ts-asymmetric cells 8 -> 0
testflags/SimpleUVM ADDED=0 REMOVED=160    ts-asymmetric cells 8 -> 0
-- TOTAL sorted-diff lines=960 ADDED-TOTAL=0
```

A LINE count is a weak attribution for a SUBTRACTIVE law (one removed object
prints its header again wherever it is somebody's `vpiParent`), so the honest
attribution is at the OBJECT level. `ct199obj` counts every object by kind over
`Serializer::AllObjects`; on SimpleUVM/default:

```
kind                     golden     pris  patched  pris-gld  pat-gld
constant                  25716    24201    24185     -1515    -1531
int_typespec               3022     3038     3030       +16        +8
range                      1539      940      932      -599      -607
ref_typespec              19364    18583    18575      -781      -789
-- no other kind's count moves.  objects removed = 40.  totals 185005 -> 184965.
```

**Exactly 40 objects, and they are exactly the declined chain**: 8 cells ×
(1 `ref_typespec` + 1 `int_typespec` + 1 `range` + the range's 2 bound
`constant`s) = 8 + 8 + 8 + 16 = 40. Nothing else is created or destroyed
anywhere in the database.

The `int_typespec` count moves **toward** golden (+16 → +8 — it is the very
overshoot r10uvm196 recorded as its R3). The `ref_typespec`, `range` and
`constant` AGGREGATE totals move away, and that is stated rather than dressed
up: those three totals are dominated by large PRE-EXISTING deficits (−781,
−599, −1515) from unrelated families, so removing objects golden also has not
got in these cells necessarily widens an aggregate gap. The measurement that
decides the direction is the compare-visible one — the census (TO-GOLDEN 48,
AWAY 0), the grid (TO-GOLDEN 50, AWAY 0), the boundary (TO-GOLDEN 172, AWAY 0),
and the head — and all four say the same thing.

`Scoreboard/default` is the COIN: 0 added, 0 removed, order-blind; its cmp log
is byte-identical between the two binaries (95 lines), and `ct199cen --pred`
finds no asymmetric cell in it at all, before or after.

`SeqDriver` and `MiniAmiq` are byte movers whose **cmp logs are BYTE-IDENTICAL**
(198 lines, one head, both modes): their heads fire earlier than this law's
cells, so the 8 declines each sit behind the head. They move toward golden and
nothing there regresses. **Note for the master:** r10uvm198 owns those two rows'
head and was landing in parallel; the rows moving under it here are this law's
8 cells per mode, named above and attributed object for object.

## 7. THE HEAD AFTER — AND R0

```
SimpleUVM default and testflags, 17 -> 17 cmp lines, ONE head each,
on a DIFFERENT OBJECT and from the OTHER SIDE

LHS golden  ref_typespec: (work@top), id:120084
            |vpiParent: \_constant: , id:120083, @217:31-217:38
            |vpiFullName:work@top
            |vpiActual: \_int_typespec: , id:120085, @217:1-217:38
RHS: <null>
```

The old head is gone: our `parameter (work@top.UVM_RADIX)` now has no typespec,
exactly like golden's. The new head is the SAME family's **Rhs half**, and it is
the MIRROR — `RHS: <null>` is `BaseClass.h`'s SINGULAR overload in its normal
direction, naming GOLDEN's extra value. The line count is unchanged only because
a `ref_typespec`'s decompile is 17 lines either way; the OBJECT and the SIDE
both changed.

**R0 — A MATERIALIZED IMPORT COPY'S `param_assign` Rhs CONSTANT CARRIES AN
`int_typespec` IN GOLDEN THAT OURS DOES NOT MINT.** The owner is
`uvm_object_globals.svh:217`, `parameter UVM_SETINT = UVM_SET;` — an untyped
parameter whose default is a REFERENCE to a sibling package parameter, folded
to a constant on both sides. Golden's folded constant carries a
`ref_typespec -> int_typespec` spanning the whole declaration line (217:1-217:38,
the same anchoring shape the declaration-side `int_typespec` uses); ours carries
none. It is in the DEF view of `work@top` (id 120084 sits in the def-listing
range the § 2 slot table maps), i.e. the same materialized-copy population this
pass and r10uvm197 have been working through, one field further along
`expr::Compare`. The question to answer first is which DEFAULT FORMS give the
copy's folded Rhs constant a typespec — `grid199`'s arm A already holds the
package-side half of that grid (`A_UDEC`'s Rhs, `A_USZ`'s Rhs …) and needs only
a REFERENCE-defaulted row added to it.

## 8. THE BOUNDARY AND THE FLOOR

```
LISTED=5234 PROCESSED=5234 PRODUCED_DBS=5049 MOVED_ARMS=20 RC_DIFFS=0
```

Subdirectory arms are compiled (the list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, PROCESSED is asserted
against LISTED). Six of this pass's seven `grid199/g199_*.sv` are the POSITIVE
CONTROL — they are all in the moved list, and without them a green gate would
prove nothing. The seventh, `g199_g_typed.sv`, is the NEGATIVE control and is
correctly **absent** from it. Several `--elabuhdm` runs segfault; they segfault
**identically on both binaries** (`RC_DIFFS=0`), and the counter records it
rather than hiding it.

**All 20 moved arms were rebuilt with a REAL Surelog golden in BOTH views and
scored** (`bscore199.sh`, 40 views, 0 unbuildable, 0 missing, 0 nonzero rcs):

```
-- SCORED views=40 MISSING-ARMS=0 NODB-views=0 TO-GOLDEN=172 AWAY-GOLDEN=0
```

No view loses AGREE and no view's ONLY-GOLDEN or ONLY-OURS set grows. Every one
of the 14 arms that is not this pass's own belongs to the two neighbouring laws:
`r10uvm102repro/g102.sv` (§ `implicitUnsizedBasedNoTs102` itself, TS-DIFF
16 → 0 per view), four `r10uvm106repro/*` and seven `r10v106repro/*`
(§ `unsizedBasedParamRhsSize106` and its verifier), plus
`r10v146repro/v10_kinds.sv` and `r10v159repro/v159_b_faces.sv`.

**THE FLOOR IS UNTOUCHED**, verified BY NAME in the moved list rather than
assumed:

```
uvm197 (6 arms)  uvm196 (9)  uvm192 (4)  uvm193 (4)  uvm184 (2)  uvm194 (3)
uvm186 (3)  uvm189 (3)  uvm191 (3)  uvm185 (5)  uvm190 (4)  uvm187 (6)
uvm188 (4)  uvm170 (5)  uvm82-91 (141)  buvm3-15 (192)  sd8-12 (347)
741 arms, MOVED = 0
```

r10uvm197's § `impCopyStringConstSize` arms, r10uvm196's
§ `modUnitImportParamsTwice196` arms, r10uvm188's render arms and r10uvm187's
deferral arms are all in that list and all still. No static-address false mover
appeared: all 20 moved arms are accounted for by content, and every one contains
an untyped parameter with an unsized based default that an import materialises.

## 9. RESIDUES, ranked

* **R0 — the materialized copy's folded Rhs constant `int_typespec`**, § 7.
  The current head, both SimpleUVM modes, 17 cmp lines, one field, and now on
  the GOLDEN side.
* **R1 — the `Earlgrey_0_1/testflags` dump-column cell in the COMMITTED
  baseline.** This pass's PRISTINE binary already reports
  `Earlgrey_0_1,testflags,CMP_EQUAL,,,` where `results/golden_surelog.csv`
  records `…,CMP_EQUAL,,,differ` — the STATUS agrees, only the informational
  dump column differs, and it differs on the pristine binary too (r10uvm197
  recorded the same cell). It is not this pass's, nothing was promoted, and
  `results/*.csv` were read only. The master should decide whether to refresh
  that one informational cell.
* **R2 — Earlgrey's materialized-copy MULTIPLICITY residue.** TS-DIFF 14
  (default) / 654 + ONLY-OURS 162 (testflags), every cell carrying an
  `int_typespec` on BOTH sides and differing only in HOW MANY copies sit behind
  one owner face, on the `other` view (owners in neither `AllModules` nor
  `TopModules` — the design-level and generate-scope listings). Identical
  before and after; `Earlgrey_0_1/testflags` is CMP_EQUAL, so it is
  judge-invisible there today. Same family as r10uvm196's R2 and r10uvm197's R3.
* **R3 — the aggregate `ref_typespec` / `range` / `constant` object counts**,
  § 6. We are 781 / 599 / 1515 objects short of golden's totals on SimpleUVM
  before this pass and 789 / 607 / 1531 after. The 40 objects this law declines
  are ones golden has not got EITHER in these cells; the deficit is other
  families entirely, and this is recorded so no future pass reads the widened
  aggregate as a regression of this law.
* **R4 — the `xargs -P` interleave trap, carried forward and paid for again.**
  `cen199.sh` runs its rows under `xargs -P`, so two rows' lines can INTERLEAVE
  and a `CENSUM` record can end up glued to another row's line. Its own
  `-- TOTALS` line (anchored `^CENSUM`) read **AGREE 26734** on the patched
  surelog census where the truth is **27634**; `censum199.sh` totals with
  `grep -o` over the whole record and ASSERTS record-count == row-count
  (`records=956 rows=956 RECORDS-COMPLETE`). **Every census number in this
  README comes from `censum199.sh`; the raw file's own `-- TOTALS` line must
  not be quoted.**
* **R5 — an ops trap worth carrying: the WRONG SURELOG produces a golden this
  UHDM build SEGFAULTS on.** A first cut of `grid199.sh` was pointed at
  `sv-tests/third_party/tools/Surelog/build/bin/surelog`; its databases restore
  sometimes and crash `Serializer::Restore` (and `uhdm-dump`) other times on the
  same source, and where they DO restore they carry no `vpiImported` at all, so
  the golden-vs-golden calibration read **AGREE 0** — a census that silently
  measures nothing. The canonical `~/git-repos/Surelog/build/bin/surelog`
  (v1.86) calibrates to AGREE 448. **Calibrate golden-vs-golden FIRST**
  (RESUME §9) is what caught it. A separate, real limit found on the way: ONE
  package carrying all thirteen declared-type kinds produces a Surelog database
  this UHDM build segfaults on restore, reproducibly, on two independent
  Surelog runs — which is why the declared-type grid is two arms
  (`g199_a_untyped.sv` + `g199_g_typed.sv`) rather than one.

## 10. THE FILES

| file | what it is |
|---|---|
| `ct199own.cpp` | the OWNER-FINDER. `--slots <db> <name>` prints every `parameter` of that name with its id, span, `vpiImported`, typespec and the LISTING it sits in named by owner and INDEX (`Parameters[i]/n`, `Param_assigns[i]/n.Lhs`) plus the Rhs constant's type/size; `--pkg` restricts it to package owners — the `clone_tree` source. The tool that answers the question the cmp log cannot. |
| `ct199cen.cpp` | the CENSUS / MOVER PREDICTOR. `--pred <ours>` needs no golden and lists every DEF-view materialized copy whose `Param_assigns`-Lhs carries a typespec its own `Parameters` twin has not; `--cen <golden> <ours>` is the compare-visible multiset join, keyed on view + owner face + param + `vpiImported` + SLOT + declared-type kind, payload the TYPESPEC KIND. Golden-vs-golden calibrates to **AGREE=cells, TS-DIFF 0, ONLY-* 0**. |
| `ct199obj.cpp` | the whole-database OBJECT-KIND counter, for the object-level attribution of a SUBTRACTIVE law. |
| `cen199.sh` | runs either mode over a whole `verify_golden` workdir; each row's golden is read out of THAT ROW'S OWN `cmds.txt`, never guessed from a test name. |
| `censum199.sh` | the ROBUST totaller (R4) — the only number to quote. |
| `grid199/` + `grid199.sh` | seven arms × two views × one real Surelog golden each, CALIBRATED golden-vs-golden and scored on both binaries. |
| `bound199.sh` / `bscore199.sh` | the wide boundary and the golden scoring of every arm it moved. |
| `attrib199.sh` | the order-blind sorted-dump attribution plus the ts-asymmetric-cell count. |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the gate battery (copies, unmodified). |
| `scrub199.sh` | redacts the four fenced test names out of the evidence files, reading the list out of `canaudit.sh`. |
| `GATES.…txt` | every gate, with the numbers. |
| `DECODE.slots.SimpleUVM.…txt` | § 2's slot table in full: all four parameters, golden × pristine × patched, every listing. |
| `CENSUS.{pristine,patched}.{surelog,u2r}.…txt` | the four corpus censuses, trimmed to the unequal rows plus robust totals. |
| `PREDICTION.{pristine,patched}.{surelog,u2r}.…txt` | the mover prediction, made from PRISTINE databases only, and its re-run after the patch (0 on all four). |
| `GRID.…txt`, `OBJECTS.…txt`, `BOUNDARY*.…txt`, `ATTRIBUTION.…txt` | the raw evidence behind § 3, § 6 and § 8. |
| `head_{pris,pat}_SimpleUVM.{default,testflags}.cmp` | the official `uhdm-cmp` head, before and after. |

## 11. REPRODUCING

```bash
git worktree add /tmp/wt 078597b7 && cd /tmp/wt
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 2
cp build/slang-uhdm /tmp/pris && chmod 555 /tmp/pris        # md5 509209e7…
git apply /tmp/r10uvm199.patch && cmake --build build -j 2
cp build/slang-uhdm /tmp/pat && chmod 555 /tmp/pat          # md5 e950ec36…

cd tools/probe/r10uvm199repro
for t in cen own obj; do g++ -O2 -std=c++17 ct199$t.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct199$t; done

# THE GRID.  SURELOG MUST BE ~/git-repos/Surelog/build/bin/surelog (R5) and the
# CALIB line must read AGREE 448 / TS-DIFF 0 / ONLY-* 0 before any other number
# in the file is worth reading.
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=/tmp/ct199cen ./grid199.sh grid199 /tmp/g199 /tmp/GRID.txt

# sweeps: export SLANG_UHDM per binary, --jobs 2, your OWN --out/--workdir,
# then audit every cmds.txt by binary PATH before believing a single row.
CEN=/tmp/ct199cen ./cen199.sh --pred <pristine workdir> /tmp/PRED.txt 2
./censum199.sh /tmp/PRED.txt
/tmp/ct199own --slots <golden.uhdm> UVM_RADIX
/tmp/ct199own --slots <ours.uhdm>   UVM_RADIX
```
