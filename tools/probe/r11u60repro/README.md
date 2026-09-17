# r11u60 — the materialized import copy is typed and flat when the declaring package selects a member

Base `00608fe8` (v1.87 pass 58).  Pins per `SUPPORT_MATRIX.md`: slang
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 (`0445655ee7`), uhdm2rtlil corpus v0.68.
Every golden in this directory is a real Surelog v1.87 run through `arm.sh`;
every arm records `slrc`/`ourrc`/`slerr` and no arm carries a framing forward.

Target: r11u49's **R0**
([tools/probe/r11u49repro/README.md:341](tools/probe/r11u49repro/README.md#L341))
— the standing head of `iface_zero_width_field`, one level out from the
elaborated package cell that pass 48 landed.

---

## 0. THE HEAD AND THE WHOLE RESIDUE, RE-MEASURED AT `00608fe8`

Pristine binary `md5 fd9480af20aeb844dce0fe2ec7d8fee1`, byte-identical to the
main tree's `build/slang-uhdm` at `00608fe8` (built independently in this
pass's own worktree; the two md5s agree).  Two row-modes, one test; each
`uhdm-cmp` run reports **one** head (`grep -c '^LHS:'` = 1 on both).  Full
logs: `evidence/head.pris.*.cmp`.

`iface_zero_width_field`, both modes — identical text, 17 cmp lines each:

```
LHS:
ref_typespec: (work@my_if), id:379
|vpiParent:
\_operation: , id:378, line:8:24, endln:8:46
|vpiFullName:work@my_if
|vpiActual:
\_struct_typespec: (p::bus_t), id:380, line:7:11, endln:7:75
RHS: <null>
```

The SHAPE LISTER (`shape.py`) over the row's own workdir databases, cell by
cell.  `p::B` is `localparam bus_t B = '{CTL:0, DAT:8, STS:0}` in package `p`
(`dut.sv:8`), an UNPACKED struct, and the package's own typedef dimensions
select `B.CTL`, `B.DAT` and `B.STS` (`dut.sv:11,12,15,16`):

| listing | golden | pristine |
|---|---|---|
| `uhdmallPackages p::B` (DEF) | tagged | tagged ✔ |
| `uhdmtopPackages p::B` (ELAB) | typed + flat 32/32/32 | typed + flat 32/32/32 ✔ (pass 48) |
| `uhdmallInterfaces work@my_if.B` | typed + flat 32/32/32 | **untyped, tagged** |
| `uhdmallModules work@pass.B` | typed + flat 32/32/32 | **untyped, tagged** |
| `uhdmallModules work@top.B` | typed + flat 32/32/32 | **untyped, tagged** |
| `uhdmtopModules` ×6 copies | flat 32/32/32 | flat 32/**64**/**64** |
| `uhdmtopPackages` op ts ref | BARE (no name, no parent) | named `(p)` + parent + fullname |

**Three cells per mode, exactly as R0 stated.**  The ORDER-BLIND whole-dump
distance at the base is **1003 lines**, and the sectioned split says where it
lives:

```
uhdmallClasses    0     uhdmallPackages   0     uhdmtopPackages     5
uhdmallInterfaces 70    uhdmallModules  140     uhdmtopModules    800
```

**PREDICTION, stated LOUDLY before any patch: this ADVANCES, it does NOT
CONVERT.**  The keyed arithmetic: the three R0 cells are worth 70 + 140 = 210
of the 1003 lines; the 800 lines in `uhdmtopModules` are r11u49's **R3** (the
ELAB module copies' operands past the first keep the unsized 64, plus golden's
per-copy typespec clone) and the 5 in `uhdmtopPackages` are a residue of the
op-level `ref_typespec` NAME — neither is this face.  Measured after: 1003 ->
**645**, `uhdmallInterfaces` and `uhdmallModules` both **0**, and the row stays
`CMP_NOTEQUAL` in both modes.  The head moved one level out again (§6).

---

## 1. THE PRODUCER

`substituteAssignedValue` reduces the package's own `param_assign` **IN PLACE**
for every `P.member` select compiled inside the package, and a module
definition's materialized import copy is a **CLONE of that same
`param_assign`**.  So only a reduce that ALREADY RAN during the PACKAGE's
compilation is visible in the clone.

The other trigger of the same reduce — `CompileHelper::getValue`'s `pkg::NAME`
arm (`src/DesignCompile/CompileExpression.cpp:901-955`), which
r11u49 § 1 decoded for the package listing — runs while a MODULE BODY is
compiled, **after** the module definitions have been materialized.  Its reduce
reaches the elaborated package listing and nothing else.

That asymmetry is the whole law, and arm `g1` isolates it: five identical
packed-struct package localparams differing only in which reader touches them.

| parameter | its one reader | golden ELAB package | golden DEF import copy |
|---|---|---|---|
| `p1::PSEL` | member select in a package TYPEDEF DIM | flat | **FLAT** |
| `p1::PFUN` | member select in a package FUNCTION body | flat | **FLAT** |
| `p1::PSCP` | `p1::PSCP` whole read, from a module | flat | **TAGGED** |
| `p1::PMOD` | `PMOD.a` select, written in a module | tagged | TAGGED |
| `p1::PNON` | never read | tagged | TAGGED |

`PSCP` is the cell that refutes the obvious model ("the DEF copy mirrors the
ELAB package listing"): golden flattens that package listing and keeps the
clone tagged.  The trigger is the **package-scope member select**, not the
package listing's shape.

`g2` is the same five-way in UNPACKED form — the corpus face — with the same
polarity.

---

## 2. THE LAW — `§ modDefImportPkgSelFlat60`

> **A module's or interface's DEFINITION-view MATERIALIZED IMPORT COPY of a
> struct-pattern package parameter is TYPED and FLAT — op75 -> `ref_typespec`
> -> the package's `struct_typespec`, one constant per member at the MEMBER
> WIDTH — exactly when the DECLARING PACKAGE'S OWN SCOPE member-selects that
> parameter.**

Our blocker was twofold and both halves are named in the diff:

* `unpPkgPat49` (the pass-48 unpacked admission) is `inPackage`-only, so an
  UNPACKED import copy never reached `structPat` at all;
* `structModDefTagged9` (`§ modDefImportPatSel`) holds every PACKED import
  copy's DEF view tagged unless the module's own parameter port list selects an
  imported parameter.

The law is a **separate disjunct**, not a widening of either: `unpPkgPat49`
stays `inPackage`-only (widening it would double-emit on the elaborated module
road, r11u49 arms `a2`/`a6`), and `structModDefTagged9` keeps holding every
import copy the package never selects — `g1`'s `PSCP`/`PMOD`/`PNON` and
BlackBePipeInt's 21 never-selected config parameters are that clause still
working.

`hasMemberSelectOf` is **READ UNCHANGED**.  The r11u49 R1 warning stands — the
predicate keys on a bare name and any package — and this face does not widen
it; the trigger added here is the MATERIALIZATION site, and the name test is
the one pass 48 already landed.

---

## 3. THE GOLDEN GRID — 8 arms, scored cell by cell

`score60.py` joins golden / pristine / law per `(listing, parameter, loc)` cell
and classifies TO / AWAY / MOVED-WRONG / STILL / SAME.  Full output:
`evidence/GRID.score.txt`.

```
ARM g1   TO 4   AWAY 0   MOVED-WRONG 0   STILL 0   SAME 26
ARM g2   TO 2   AWAY 0   MOVED-WRONG 0   STILL 8   SAME 14
ARM g3   TO 4   AWAY 0   MOVED-WRONG 0   STILL 7   SAME 10
ARM g4   TO 3   AWAY 0   MOVED-WRONG 0   STILL 3   SAME 2
ARM g5   TO 1   AWAY 0   MOVED-WRONG 0   STILL 7   SAME 12
ARM g6   TO 1   AWAY 0   MOVED-WRONG 0   STILL 2   SAME 5
ARM g7   TO 1   AWAY 0   MOVED-WRONG 0   STILL 0   SAME 7
GRID TOTAL over 7 scored arms:  TO 16   AWAY 0   MOVED-WRONG 0   STILL 27   SAME 76
```

Every arm `slrc=0 ourrc=0 slerr=0` on both binaries.  (`g8` is the
non-measurable arm; see the fence table.)

### 3a. IMPORT KINDS x HOLDER KINDS x COPY COUNTS

`g4` — the same package-selected parameter behind four import spellings.
Golden flattens the DEF copy under **all three** that produce one, and the
fourth has no copy to flatten on either side:

| module | import | golden DEF copy | pristine | law |
|---|---|---|---|---|
| `g4w` | wildcard HEADER `import p4::*;` | typed + flat | tagged | flat ✔ |
| `g4b` | wildcard BODY `import p4::*;` | typed + flat | tagged | flat ✔ |
| `g4e` | EXPLICIT `import p4::B4;` | typed + flat | tagged | flat ✔ |
| `g4n` | none (writes `p4::v4_t` only) | **no copy** | no copy | no copy ✔ |

`g3` — one parameter, six holders, and the copy counts.

| holder | golden DEF copy | pristine | law |
|---|---|---|---|
| `interface g3if` | typed + flat 32/32 | tagged | flat ✔ |
| `module g3child` (TWO instances) | typed + flat 32/32 | tagged | flat ✔ |
| `module g3port` (plain parameter port list) | typed + flat 32/32 | typed + flat 32/**64** | flat 32/32 ✔ |
| `module g3sel` (port list SELECTS it) | typed + flat 32/32 | typed + flat 32/**64** | flat 32/32 ✔ |
| `package p3b` (re-exporter) | flat ×2 | flat ×1 | flat ×1 (untouched) |

The two `g3` rows that were ALREADY flat are the law's **bonus**: their DEF
copies reached the flat shape through the `§ modDefImportShape` topView flip
and the generic elab fold, which leaves every operand past the first at the
unsized 64.  Routing them through the same op75 walk the package listing uses
sizes every operand at the member width — golden's 32/32 — so R3 is closed on
this one face.  The DEF copy of a **package** (`p3b`) is deliberately out of
scope (`!inPackage`): it already flattens on the pristine binary, and its
`×2`-vs-`×1` count is a different residue.

### 3b. THE SIX PASS-48 FENCES, GRIDDED AT THIS FACE

`g5` is one package, one **never-called** package-function select per parameter
(r11v49's `RFDEAD` face, so a type key cannot turn the arm into an
error-recovery measurement), everything else held fixed and only the SHAPE
varying.  `g6` is the class fence, `g7` the width face, `g8` the type key.

| fence | arm | golden DEF import copy | law | verdict |
|---|---|---|---|---|
| — (control, plain named pattern) | `g5` `FPLAIN` | typed + FLAT 32/32 | flat ✔ | the law's cell |
| PATTERN-VALUED ELEMENT | `g5` `FNEST` | **TAGGED** | tagged ✔ | declines (`patParamPatElem26v`) |
| POSITIONAL pattern | `g5` `FPOS` | **UNTYPED**, operands resized to 32 | untyped, 64/64 — unmoved | declines; the resize is a residue |
| NON-INTEGRAL member (`real`) | `g5` `FREAL` | **TAGGED** | tagged ✔ | declines |
| `time` member | `g5` `FTIME` | **TAGGED** | tagged ✔ | declines |
| CLASS-BODY select | `g6` `p6::CCLS` | **TAGGED** | tagged ✔ | declines for free |
| TYPE key | `g8` `p8::FTYP` | **NOT MEASURABLE** | declines | see below |

`g6` carries its own positive half — `p6::CPKG`, the same struct selected from
ordinary package code, is FLAT in golden and moves ✔ — so "class" is separated
from "this arm cannot move anything".

**The TYPE-KEY face cannot be measured at this face at all**, and that is the
finding, not a gap.  Arm `g8` puts a type-key pattern parameter in a package
that a module imports, and Surelog v1.87 answers

```
[ERR:UH0713] .../g8.sv:11:19: Unmatched member during pattern assignment "b".
```

— `slrc=4`.  r11u49's `b3` reads the same parameter (`p::UTYP.A`) from a module
that does NOT import and compiles clean, so it is the MATERIALIZATION that
fails.  An arm whose compile fails teaches error recovery, not golden, so the
type/index-setter fence is carried over verbatim and never widened.

The **>64-bit WIDTH rule does not apply here**, measured rather than assumed.
`g7` is one package with two 96-bit packed structs:

| parameter | golden ELAB package | golden DEF import copy | pristine | law |
|---|---|---|---|---|
| `p7::WSEL` (package-selected) | flat 32/32/32 | **flat 32/32/32** | tagged | flat ✔ |
| `p7::WNON` (never read) | tagged | tagged | tagged | tagged ✔ |

The member select outranks the width at this face exactly as it does in the
package listing.

---

## 4. CENSUS, and the movers predicted BY NAME before the patched sweeps

Two instruments, both reading **PRISTINE** databases only.

`cen60.py` is the SHAPE LISTER over a whole `verify_golden.py` workdir,
restricted to the DEF listings, with three columns: the golden typed-flat count
(the POSITIVE CONTROL), the law's cell (golden typed+flat, ours different), and
the RISK bound (every other DEF-listing op cell where the two sides already
AGREE — the complete AWAY-GOLDEN exposure).

`pred60.py` is the A-PRIORI predictor: a test is named only when its pristine
database carries a DEF-listing op75-over-a-struct cell AND a textual mirror of
`hasMemberSelectOf` (the bare name written as `NAME.` inside a
`package ... endpackage` region, outside every `class ... endclass`) fires on
that parameter.  The source half is deliberately crude and over-inclusive; the
gate is that every MEASURED mover lies inside the predicted set.

**uhdm2rtlil, both modes.**  Positive control non-zero: the golden column is
populated in the real corpus, so a small OUR column is a fact about the corpus
and not about the instrument.  The law's cell appears on **exactly one test**:

```
LAWCELL iface_zero_width_field  uhdmallInterfaces work@my_if.B  line:8:20
LAWCELL iface_zero_width_field  uhdmallModules    work@pass.B   line:8:20
LAWCELL iface_zero_width_field  uhdmallModules    work@top.B    line:8:20
== default   GCTRL=4  LAWCELLS=3 on 1 tests  RISK(must not move)=529
== testflags GCTRL=4  LAWCELLS=3 on 1 tests  RISK(must not move)=529
```

and `pred60.py` independently names the same three cells and no others
(174 candidate DEF struct-op cells per mode).

**PREDICTED MOVER SET, stated LOUDLY before scoring: `iface_zero_width_field`
in both uhdm2rtlil modes, and on the Surelog suite `BlackBePipeInt` in both
modes — nothing else.**

`BlackBePipeInt` was predicted, measured and attributed BEFORE the patched
sweep, by running both frozen binaries on its own source: `md5` pristine
`1de61516fba2` vs law `764682b2b583`, a real mover.  The shape lister sees NO
cell change (`evidence/GRID.BlackBePipeInt.txt`: **TO 0 AWAY 0 MOVED-WRONG 0
STILL 1 SAME 1416**), because the move is below its resolution — the ORDER-BLIND
whole-dump diff names it exactly:

```
82 cells:   \_ref_typespec:              ->   \_ref_typespec: (work@bp_be_pipe_int)
                                              |vpiParent: \_operation: ...
                                              |vpiFullName:work@bp_be_pipe_int
```

and it is a move **TOWARD GOLDEN**: golden's own op-level `ref_typespec` on
those cells is `(work@bp_be_pipe_int)` with a parent and a fullname, quoted side
by side in `evidence/GRID.BlackBePipeInt.txt`.  Named `ref_typespec`s in that
listing: golden **6390**, pristine **5086**, law **5250**.  All 21 DEF copies
golden keeps TAGGED there have **0** member selects in the sources and stay
tagged; the flat ones (`bp_default_cfg_p` 144 selects, `bp_unicore_cfg_p` 216)
are the ones that gain the name.

---

## 5. WHAT MOVED

`iface_zero_width_field`'s R0 head is GONE in both modes, and the two DEF
sections are now ORDER-BLIND IDENTICAL to golden:

```
              pristine   law
allInterfaces    70   ->   0
allModules      140   ->   0
topPackages       5   ->   5   (unmoved — R1 below)
topModules      800   -> 638   (unmoved class; R2 below)
whole dump     1003   -> 645
```

The new head is the SAME FAMILY one level out again — r11u49's R3, now the
row's head, a constant SIZE on the ELAB module copies (cmp lines 17 -> 36,
which is the new head object's larger decompile, one head per run on both
modes):

```
LHS:
constant: , id:715, line:8:37, endln:8:38
|vpiParent: \_operation: , id:702, line:8:24, endln:8:46
|vpiDecompile:8   |vpiSize:32   |UINT:8   |vpiConstType:9
RHS:
constant: , id:517, line:8:37, endln:8:38
|vpiParent: \_operation: , id:515, line:8:24, endln:8:46
|vpiDecompile:8   |vpiSize:64   |UINT:8   |vpiConstType:9
```

Scoreboard unmoved: uhdm2rtlil 785 / 19 / 67 both modes, surelog 474/9 +
469/8.  This pass buys three cells per mode on the target row (six row-modes of
the cluster head), 82 cells moved toward golden on `BlackBePipeInt`, R3 closed
on the DEF import-copy face, and the residues below decoded.

---

## 6. RESIDUES

* **R0 — the ELAB module copies' operand sizes (r11u49's R3), now the row's
  head.**  `uhdmtopModules work@top.B` and its five sibling copies flatten to
  `32/64/64` where golden writes `32/32/32`: the generic elab fold sizes
  operand 0 at the member width and leaves 1..N at the unsized 64.  This pass
  closed exactly that bug on the DEF import-copy face by routing it through the
  op75 walk (`g3`'s `g3port`/`g3sel`, 32/64 -> 32/32), which is the shape of
  the fix for the ELAB face too.  638 order-blind lines on one test, two modes;
  golden also CLONES the `struct_typespec` per copy where we share one.  **This
  is the R0 the next pass should take.**
* **R1 — the op-level `ref_typespec` NAME is decided per LISTING, and the two
  faces disagree.**  In the module/interface DEF import copy golden NAMES it
  after the holder (`(work@my_if)`, `(work@bp_be_pipe_int)`) with a parent and a
  fullname — which this law now produces.  In the ELABORATED PACKAGE listing
  golden leaves it BARE and we name it `(p)`; 5 order-blind lines on
  `iface_zero_width_field`, pre-existing and unmoved here.  The mirror image of
  the cell this pass fixed, and the two must not be "unified".
* **R2 — a POSITIONAL package pattern's operands are resized but the op stays
  untyped, at BOTH faces.**  `g5`'s `FPOS`: golden's elab package listing AND
  its DEF import copy are untyped with operands at the member width (32/32);
  ours keeps the unsized 64/64 in both.  The TYPE half is fenced on purpose
  (typing it is a mint, r11u49 R4); only the SIZE half is the residue.  No
  corpus cell is on it.
* **R3 — a re-exporting package materializes the copy TWICE.**  `g3`'s `p3b`
  (`import p3::*; export p3::*;`): golden's `uhdmallPackages` and
  `uhdmtopPackages` each carry TWO `p3b::B3` `param_assign`s, we carry one.
  Both of ours are flat and agree in shape; it is a COUNT residue, and it is
  the package-side sibling of `§ elabReExportPaLhsShare`.  Deliberately out of
  this law's scope (`!inPackage`).
* **R4 — the TYPE KEY cannot be materialized at all.**  Arm `g8`: Surelog
  v1.87 raises `[ERR:UH0713] Unmatched member during pattern assignment` the
  moment a type-key pattern package parameter is imported into a module, while
  the same parameter read from a NON-importing module compiles clean
  (r11u49 `b3`).  Recorded so that no later pass reads the missing golden cell
  as an opportunity.

---

## 7. FILES

| file | what it is |
|---|---|
| `arm.sh` | one arm through Surelog + one slang-uhdm binary, both dumped, rc recorded (from r11u34) |
| `shape.py` | THE SHAPE LISTER — every `param_assign` in every top-level listing: op type, op-level typespec actual, operand kinds and constant sizes (from r11u49) |
| `score60.py` | joins golden / pristine / law per cell: TO / AWAY / MOVED-WRONG / STILL / SAME |
| `cen60.py` | `shape.py` over a whole `verify_golden.py` workdir, restricted to the DEF listings: positive control, law cells, AWAY-risk bound |
| `pred60.py` | the A-PRIORI mover predictor — pristine databases + a textual mirror of `hasMemberSelectOf` over the tests' own sources |
| `g1.sv` `g2.sv` | THE MIRROR ARMS — five package-scope triggers x packed / unpacked |
| `g3.sv` | holder kinds x copy counts (interface, two instances, port list, port-list select, re-exporting package) |
| `g4.sv` | import kinds (wildcard header / wildcard body / explicit / none) |
| `g5.sv` | the shape fences: pattern-valued element, positional, `real`, `time`, plus the control |
| `g6.sv` | the class-body fence, with its own positive half |
| `g7.sv` | the >64-bit width face |
| `g8.sv` | the TYPE-KEY face, recorded as NOT MEASURABLE (Surelog errors on materialization) |
| `byteverify.sh` `ct8rows.sh` `rowheads.sh` | the gates |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` | the current-generation battery (r10uvm221repro), run here |
| `evidence/` | the four cmp heads, the grid score, the BlackBePipeInt attribution, the two censuses |

---

## 8. GATES — all green

Binaries frozen `chmod 555` at `/tmp/r11u60_bin/` before any sweep; every
`cmds.txt` audited by binary PATH — 1531 + 1742 `law.bin` lines in the patched
workdirs, 1531 + 1742 `pris.bin` lines in the pristine ones, and not one
main-tree path in either.

1. **BUILD.**  PRISTINE `md5 fd9480af20aeb844dce0fe2ec7d8fee1`, built in this
   pass's own worktree and byte-identical to the main tree's binary at
   `00608fe8` — the brief's stated hash.  PATCHED
   `md5 2f7181e05985e7c2e1c313858f93b6e7`, 0 errors, `-j 2`.
2. **GOLDENS.**  `tests/check_goldens.sh` PASS 23 / FAIL 0 on BOTH binaries.
   Negative control `SLANG_UHDM=/bin/false` PASS 0 / FAIL 23.
3. **uhdm2rtlil, both modes** (own pristine sweep + committed baselines).
   785 CMP_EQUAL / 19 CMP_NOTEQUAL / 67 SLANG_REJECT in each mode — the
   baseline exactly.  `ct8rows.sh` *PASS: every row byte-identical* against
   `results/gate_uhdm2rtlil.csv`, against `results/golden_uhdm2rtlil.csv` (both
   modes joined) and against this pass's own pristine CSVs in both modes.
4. **Surelog suite, `--mode both`.**  default 474 / 9, testflags 469 / 8 — the
   baseline exactly, and every other status bucket identical to the own-pristine
   sweep (DEFERRED 5/5, SLANG_REJECT 285/286, SURELOG_FAIL 25/23, NO_DATABASE 3,
   NO_UHDM 1, TIMEOUT 1, UNTRANSLATABLE 2).  `ct8rows.sh` flags **three** rows
   against the own pristine sweep and the same three against the committed
   `results/golden_surelog.csv`, none of them a status move:

   ```
   < LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../LowMemLib-f068a766/slpp_all/surelog.log".,,
   < LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   < Earlgrey_0_1,testflags,CMP_EQUAL,,,differ
   > Earlgrey_0_1,testflags,CMP_EQUAL,,,
   ```

   The first two are the workdir PATH inside a golden-side failure message and
   are not this pass's.  The third is the documented `uhdm-dump` TIMEOUT DRAW on
   Earlgrey's dump COLUMN: the STATUS is `CMP_EQUAL` on both sweeps and the two
   DATABASES ARE BYTE-IDENTICAL (`59d0ee6d10c3`, the brief's testflags pin), so
   the column difference is a harness artefact and cannot be a content change.
5. **byteverify, `SELFCHECK=1`, against this pass's own pristine workdirs.**
   * uhdm2rtlil: PATH_SETS_IDENTICAL (1608), **MOVERS 2 / 1608**, both
     `iface_zero_width_field` — the predicted set, name for name.  SELFCHECK
     1607/1608 flagged.
   * Surelog: PATH_SETS_IDENTICAL (960), **MOVERS 7 / 960** — `BlackBePipeInt`
     in BOTH modes (PREDICTED BY NAME, §4, and attributed TOWARD golden cell by
     cell), plus five UVM-family draws, every one attributed by RE-DRAW from
     the UNCHANGED pristine binary, not by assertion.  SELFCHECK 959/960.

     Three consecutive runs of the PRISTINE binary itself on the sweep's own
     command line:
     `MiniAmiq/default` -> `14a0b7dabc54` (18852251 B), `a2900470873a`
     (18852287 B), `02918e28a004` (18852242 B) — three hashes and three SIZES
     from one unchanged binary, none of them the sweep's `3466452c82ff` or the
     patched `27419f6011b4`; `SeqDriver/default` -> `ce4c651222c3` (18074292 B),
     `2fb39f8b4130` (18074287 B), `d6d28143fa25` (18074291 B) — likewise;
     `Scoreboard/default` -> `1621aec6c9f3` three times, which is the PATCHED
     sweep's hash, so it is the PRISTINE sweep's `e70775324004` that was the
     outlier draw.  The path-normalised ORDER-BLIND sorted-dump diff on each of
     the five is the documented class and nothing else:

     ```
     default/MiniAmiq    4 lines   |UINT:0    <-> |UINT:1177   (+ vpiDecompile)
     default/SeqDriver   4 lines   |UINT:0    <-> |UINT:1130   (+ vpiDecompile)
     default/Scoreboard  0 lines   (the documented 0-line order draw)
     testflags/MiniAmiq  4 lines   |UINT:1124 <-> |UINT:892    (+ vpiDecompile)
     testflags/SeqDriver 4 lines   |UINT:676  <-> |UINT:980    (+ vpiDecompile)
     ```

     Their STATUS is `CMP_EQUAL` in both modes on both sweeps, which is what the
     family's pin requires.
   * Both corpora: **MOVED-WRONG 0, AWAY-GOLDEN 0**, scored cell by cell on the
     golden grid (§3) and by name in the corpora (§4).
6. **Protected databases, by name, patched vs own pristine** — every one SAME:
   `SVSwitch 4842211c4030` (both modes, hard byte pin), `YosysVerx 6ccda350c24a`
   (both modes, hard byte pin), `InterfaceModPort 59a365f3ce2c` (both modes),
   `BlackParrotComplex` (default `e3e354129d5a`, testflags `73a10e8217e5`),
   `YosysOldOr d68e0796d62c` (both modes), `Earlgrey_0_1` default
   `8bdf25272e08` and testflags `59d0ee6d10c3` — the two Earlgrey pins the brief
   names, hit exactly.
7. **Canaries.**  `canaries.sh` patched-vs-own-pristine: surelog `ok=51
   changed=1 absent=0`, uhdm2rtlil `ok=8 changed=0 absent=0`; surelog against
   the committed CSV reads the same `ok=51 changed=1`.  The one CHANGED row is
   `Earlgrey_0_1 testflags CMP_EQUAL/differ -> CMP_EQUAL/` — the dump-column
   timeout draw of gate 4, status unchanged and database byte-identical.
   `ctcan2.sh` PASS on both corpora.  `canaudit.sh canaries.sh ctcan2.sh` —
   *PASS: every brief-protected name and family is carried by a script that RUNS
   here*.  The battery is the current generation (`r10uvm221repro`, md5s
   `e1f84a84bf5d` / `3d3f9a2aa485` / `b2289875bb3d`).
8. **rowheads** on the converted families, patched workdir: `SeqDriver`,
   `SimpleUVM`, `Scoreboard/default`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1`
   AND `BlackBePipeInt` — every one `0 cmp lines, 0 heads, rc=0` in both modes,
   so the 82 cells that moved on `BlackBePipeInt` kept it exactly equal.
   SKIP-NOFILE on `Scoreboard/testflags` and `Rggen/testflags` is the expected
   pair; `Rggen/default` is `CMP_NOTEQUAL` on the committed baseline, on this
   pass's pristine sweep and on its patched sweep alike.
9. **`results/*.csv` untouched** — `git status` shows one modified source and
   one untracked probe directory, nothing else.  No fenced test was ever
   dispatched (`FENCED=` names were never spelled or run).  `GOLDEN_DEFER`
   unset throughout.
10. **No metric doc needs refreshing**: no scoreboard number moved.
