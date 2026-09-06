# r10uvm180 — § `cloneBodyBareTdAlias180` — **INSIDE A WILDCARD-IMPORT CLONE BODY, A PACKAGE TYPEDEF'S ALIAS TARGET IS BARE AT EVERY DEPTH AND IN EVERY ROLE — EXCEPT THE RETURN VARIABLE** — the SeqDriver ×2 142-line and MiniAmiq ×2 116-line heads CLEARED

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
WAS CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four slang-fenced tests were
never dispatched and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `87074d42` |
| pristine binary | md5 `32978f1be49b524fca38801f8a56ad50`, built from this pass's OWN worktree at a clean `87074d42` and frozen `chmod 555` before any sweep.  Its own 1588-row surelog sweep and its 731-row × 2-mode uhdm2rtlil sweeps reproduced `results/golden_surelog.csv` and `results/gate_uhdm2rtlil.csv` **row for row** before a line of the patch was written. |
| patched binary | md5 `14a355f3b04a10e6313cd65e95e2c270`, frozen `chmod 555` before any sweep.  The patch applied to a **FRESH `87074d42` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5, and that binary passes the 23 golden dump tests 23/0 — the patch IS the artifact every number below was measured on. |
| production surface | `src/TypeEmit.cpp` (the law, inside the existing `§ importCloneBareTdAlias16`), plus the one-parameter signature change that hands it the `design` it now walks (`include/UhdmExporter.h`, `src/UhdmExporter.cpp`).  Nothing else. |
| probe surface | `tools/probe/r10uvm180repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default+testflags 142 → 29 cmp lines, MiniAmiq default+testflags 116 → 26, ONE head each throughout — CLEARED.**  The head OBJECT changed in all four, and SeqDriver's and MiniAmiq's new heads are two DIFFERENT families, neither of them this one (§ 9). |
| every other row's head | cmp log **BYTE-IDENTICAL** — SimpleUVM ×2 (29), Scoreboard/default (95), BuildUVMPkg ×2 (52), Earlgrey_0_1 ×2 (31 / 176), Rggen/default (0). |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against the committed baselines AND against this pass's own pristine sweeps. |
| byte movers | **4 / 956** surelog and **0 / 1358** uhdm2rtlil, and **both counts were PREDICTED BY NAME**.  `predict180` opens OUR PRISTINE DATABASES ONLY — no golden, no patched artifact — so the prediction cannot be back-fitted to the result it is checked against, whichever order the two are run in. |
| the mover attribution | whole-dump, workdir-normalised, ORDER-BLIND diff per mover: **23 lines each** (2 removals, 21 additions), and in all four the number of changed lines that neither name one of the law's seven typedefs nor are a structural line of one of their typespecs is **0**.  The delta is small because most of what the law does is move an EDGE between objects the dump already prints (§ 8). |
| the census (nine UVM row-modes) | declaration family (`ct180cen`, every io_decl and variable in every package subroutine body): **TOGOLD 376, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0**.  Wide `ref_typespec` family (`ct180ref`, every typespec binding reachable down a package subroutine's statement tree): **differ 19 → 0** on each of the four moving row-modes, unchanged on the other five. |
| the listing pairing | `uvm_pkg` ALL 46 / TOP 89 and `adpcm_pkg` ALL 124 / TOP 124 — **ours equals golden in every one**, and across 383 listing slots there are **0** index-wise (kind, VpiName) mismatches, already in the PRISTINE database.  The brief's "46 vs 89" is golden's own DEF-view-vs-ELAB-view difference, not a gap between us and golden, and it contributes nothing to the head (§ 3). |
| the corpus-wide completeness scan | `predict180` reads OUR databases only.  Over the **956** pristine surelog databases it flags exactly the four moving row-modes and nothing else; over the **1358** pristine uhdm2rtlil databases it flags none; over the **956 PATCHED** surelog databases it flags **none** — the law leaves no cell of its family behind. |
| the grids (15 arms × 2 views, one fresh Surelog golden each) | **TOGOLD 94, AWAY 0, MOVED-WRONG 0.**  Three arms go from a head to **EQUAL to golden in BOTH views**: `g180_a_kinds` (116 → 0 lines), `r10buvm8repro/vxpkg8.sv` (112 → 0), `r10uvm123repro/g123_c_otherpkg.sv` (112 → 0).  `r10v123repro/v123_b_bounds.sv`/elab goes 112 → 62. |
| the WIDE boundary (4932 sources × 2 views × 2 binaries) | `LISTED=4932 FENCED_SKIPPED=0 PROCESSED=4932 MOVED=18 ASYMMETRIC=0 NO_OUTPUT_PAIRS=380`.  Every flagged arm was then scored by the OFFICIAL `uhdm-cmp` against a fresh Surelog golden (`GRID.r10uvm180.txt`); none regressed. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine surelog sweep — which `ct8rows`
certified byte-identical to the committed baseline on every one of the 1588
row-modes, status AND dump column, before a line of the patch was written:

```
SeqDriver      default        142      1
SeqDriver      testflags      142      1
MiniAmiq       default        116      1
MiniAmiq       testflags      116      1
```

which is the brief's R0 to the byte.  The pristine head
(`head_pris_SeqDriver.default.cmp`, 142 lines, one head) is

```
LHS(golden) = logic_typespec(uvm_bitstream_t)@49:9-49:42          #184529
RHS(ours)   = logic_typespec(uvm_pkg::uvm_bitstream_t)@49:9-49:42 #413
```

and `logic_typespec::Compare` stops on `VpiName`.  The site is uvm-1.2
`base/uvm_object_globals.svh:49` (`typedef logic signed [UVM_STREAMBITS-1:0]
uvm_bitstream_t;`).

---

## 2. THE JUDGE, DECODED — **IT IS NOT THE LISTING OBJECT, IT IS THE ALIAS TARGET OF A BLOCK LOCAL**

`ct180own` prints the head's parent chain on **both** sides.  The brief's
framing ("golden's clone typespec is named bare while ours keeps the
package-qualified spelling") is true of the OBJECTS but points at the wrong
one, and the chain says which:

```
GOLDEN
  logic_typespec(uvm_bitstream_t)#184529          <- the head: the ALIAS TARGET
   < ref_typespec#184528                          <- Typedef_alias of …
   < logic_typespec(uvm_bitstream_t)#184527       <- the per-declaration copy
   < ref_typespec#184526                          <- the variable's Typespec
   < logic_var(_t)@492:20#184525
   < begin()@491:25-497:7#184524                  <- A NESTED BLOCK
   < if_else()@491:3-499:27
   < begin()@491:3-499:27
   < function(uvm_bitstream_to_string)@483:1
   < package(adpcm_pkg)@10:1-207:22               <- THE WILDCARD-IMPORT CLONE
   < design(work@top_tb)

OURS
  logic_typespec(uvm_pkg::uvm_bitstream_t)#413    <- the head
   < package(uvm_pkg)@28:1-39:11#146              <- uvm_pkg's OWN LISTING OBJECT
   < design(work@top_tb)
```

Golden's chain in the clone is **bare → bare**; ours is **bare →
`uvm_pkg::…`**, because our copy's `Typedef_alias` still targets the home
package's qualified listing entry.  Our copy's own name was already bare —
LAW S made it.  The source is uvm-1.2 `base/uvm_misc.svh`:

```systemverilog
function string uvm_bitstream_to_string (uvm_bitstream_t value, …);   // 483
   …
   if($isunknown(value)) begin
	  uvm_bitstream_t _t;                                          // 492
```

`value` is a FORMAL and already agreed; `_t` is declared inside the
`begin`/`end` of an `if`, which is the whole difference.

**The 46-vs-89 count is not a gap.**  `ct180own`'s STEP 3 prints golden's and
our listings side by side by index (`PAIRING.r10uvm180.txt`), on the PRISTINE
database:

```
SCOPE ALL[1]|uvm_pkg     golden=46  ours=46
SCOPE TOP[1]|uvm_pkg     golden=89  ours=89
SCOPE ALL[2]|adpcm_pkg   golden=124 ours=124
SCOPE TOP[2]|adpcm_pkg   golden=124 ours=124
383 listing slots compared index by index, 0 (kind, VpiName) mismatches
```

46 and 89 are golden's own `AllPackages` (DEF) and `TopPackages` (ELAB) views of
`uvm_pkg`, and we match both.  r10uvm178's mirror scan printed golden's TWO
listings next to ONE of ours, which is where the "46 vs 89" reading came from.
It contributes nothing to the head, and there is no listing-pairing gap to fix.

---

## 3. SURELOG, DECODED — **THE CLONE IS MADE BEFORE THE PREFIX IS APPLIED**

Two sites, and the ORDER between them is the whole rule.

`UhdmWriter::writeDataTypes` (`src/DesignCompile/UhdmWriter.cpp:775-796`)
applies the `p::t` prefix **IN PLACE**, while it walks ONE package's
`datatypeMap`, and only when the parent is a package:

```cpp
    typespec* tps = dtype->getTypespec();
    …
    if (parent->UhdmType() == uhdmpackage) {
      if (tps && (tps->VpiName().find("::") == std::string::npos)) {
        const std::string newName = StrCat(parent->VpiName(), "::", tps->VpiName());
        tps->VpiName(newName);
      }
    }
```

`CompileHelper::importPackage` (`src/DesignCompile/CompileHelper.cpp:299-330`)
`clone_tree`s the imported subroutine listing into the importer, at **COMPILE**
time — before any of that:

```cpp
        if (!duplicate) {
          if (inPackage) {
            ElaboratorContext elaboratorContext(&s, false, /*mute errors*/ true);
            task_func* clone = (task_func*)UHDM::clone_tree((any*)func, &elaboratorContext);
            sfuncs->push_back(clone);
```

so every typespec inside a clone body is a COPY made while the name was still
bare, and nothing in it is ever the object the prefix walk touched — at any
block depth and in any role.  (The typedefs themselves are NOT cloned:
`importPackage` does `scope->insertDataType(type.first, type.second)`, the same
`DataType*`, so the importer's own LISTING holds the home's already-prefixed
object.  That is why the clone's copy is bare while the listing entry it used to
alias is qualified, and why this is a body law, not a listing law.)

This is the same sentence § `importCloneBareTdAlias16` already wrote for a clone
body's `Io_decls` and its `Variables` vector.  What this pass measured is that
the sentence has no depth clause and no role clause.

---

## 4. SLANG, DECODED — **THE SITE ENUMERATION WAS SHORT, NOT THE MECHANISM**

`§ importCloneBareTdAlias16` (`src/TypeEmit.cpp`) already mints the clone's
copy (`cloneCopyOf` → `bareScalarTdCopyOfFresh16`, with `defToTop18` picking the
ELABORATED twin so the copy carries the FOLDED range) and already re-points a
binding onto it (`rebind` → `listingOf`).  It only ever looked in two places:

```cpp
    for (auto* tf : pkgImportCloneTfs16) {
        auto* m = (UHDM::task_func*)tf;
        if (m->Io_decls())  for (auto* io : *m->Io_decls()) rebind(io->Typespec());
        if (m->Variables()) for (auto* v  : *m->Variables()) rebind(v->Typespec());
    }
```

A local declared inside a `begin`/`fork`/loop body hangs off THAT scope's
`Variables` vector, and an expression's typespec hangs off no listing at all.
`rebind` is idempotent on a cell that is already right (`listingOf` returns null
the moment the target is a bare copy), so widening the enumeration is the whole
change.

**Why UHDM's own listener and not a hand-rolled descent.**  Our `ref_typespec`
objects are UNPARENTED — a `VpiParent` climb from one reaches no package — so
no arena scan and no upward key can tell a clone body's ref from a home body's.
A hand-rolled descent was written first, and it MISSED the expression role: with
it, SeqDriver's head merely moved from `_t` to the `ref_obj` argument of
`uvm_vector_to_string`'s `return uvm_bitstream_to_string(value, …)` and the row
stayed at 142 lines.  `UhdmListener` is UHDM's own generated traversal: it walks
the design once (its `visited` set makes it O(N)) and hands every callback the
CALLSTACK, which IS the downward path.  The gate reads that callstack.

---

## 5. THE LAW, AND ITS THREE FENCES

```
§ cloneBodyBareTdAlias180
A ref_typespec reached DOWN a wildcard-import package clone's subroutine tree
takes the clone's own BARE copy — at any block depth and in any role —
   FENCE 1  the innermost subroutine on the callstack must be in
            `pkgImportCloneTfs16` (a wildcard-import package clone body);
   FENCE 2  nothing SHARED — a class_defn or another typespec — may stand
            between that subroutine and the ref;
   FENCE 3  the subroutine's RETURN VARIABLE is excluded.
```

**No name is written anywhere in this pass.**  Only a LINK is re-pointed, and
only onto a copy the pre-existing clone machinery already mints.  The recorded
naming dead-end (a uniform `pkg::` requalification broke the goldens once) is
respected the way § 111 respects it: clone context only, link only.

FENCE 2 is not decoration: `g180_d_class.sv` puts a clone body that declares a
class handle, calls a class method and reads a class property beside plain block
locals of the same typedef, and without the fence the walk would follow a
`class_typespec` into the shared class world both producers reach by other
routes.

FENCE 3 is MEASURED, not reasoned, and it was found by the wide boundary, not by
the corpus.  Golden gives a clone function's RETURN variable a typespec that
still aliases the HOME's QUALIFIED object while every io_decl and body local of
the same clone is bare.  Two already-committed arms show it independently:

```
r10uvm169repro/g169_a_import.sv   p169i's clone of f_typ169
    golden  return bit_var@33:12  bit_typespec[v169_t -> p169h::v169_t]
r10v169repro/v169_i_multi.sv      p169i1's clone
    golden  return bit_var@14:12  bit_typespec[vi169_t -> p169hi::vi169_t]
```

Without FENCE 3 both arms score **AWAY=1**.  With it both score AWAY=0, and the
corpus head clearance is unaffected — the 94 declaration cells and the 19 wide
`ref_typespec` cells the law moves on SeqDriver and MiniAmiq are block locals and
expression operands, never return variables.

---
## 6. THE CENSUS — NINE UVM ROW-MODES, TWO FAMILIES, BOTH ONE-SIDED SETS

Two instruments, because one key cannot see both roles.

**`ct180cen` — the DECLARATION family.**  Every `io_decl` and every `variables`
object in every package subroutine body of both databases, keyed
`listing | role | class | function | block-depth | name@line:col` — the listing
key is r10uvm178's (the design-vector membership of the outermost package
ancestor plus the package NAME, never an index and never an id).  For each key
it reads the two names `typespec::Compare` reads first: the bound typespec's
`VpiName` and its `Typedef_alias` target's `VpiName`.

On the PRISTINE SeqDriver/default database this says `agree 5033, differ 94`,
and the 94 are perfectly shaped:

* **all 94** are in `ALL[2] adpcm_pkg` (47) and `TOP[2] adpcm_pkg` (47) — the
  wildcard-import clone's two listings, and nothing else;
* **all 94** are at block depth 1..5, never 0;
* **all 94** read `gold=[t -> t]` against `ours=[t -> uvm_pkg::t]`;
* the 86 clone cells at depth ≥ 1 that ALREADY agree are the ones our emitter
  also lists in the subroutine's own `Variables` vector, which the pre-existing
  loop reached.

**`ct180ref` — the WIDE `ref_typespec` family.**  Every `ref_typespec` reached
DOWN a package subroutine's statement tree (UhdmListener; the path itself is the
key), which adds the expression role the declaration census cannot see.

`cen180score.py` joins the golden-vs-pristine and golden-vs-patched runs ON THE
KEY.  ONLY-GOLDEN / ONLY-OURS rows are key gaps and are reported separately and
never scored — counting one as a movement is how a NODEDUP census manufactures
AWAY-GOLDEN phantoms (RESUME §9).

| row-mode | declaration family | wide ref family |
|---|---|---|
| SeqDriver/default   | TOGOLD 94, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 | differ 19 → 0 |
| SeqDriver/testflags | TOGOLD 94, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 | differ 19 → 0 |
| MiniAmiq/default    | TOGOLD 94, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 | differ 19 → 0 |
| MiniAmiq/testflags  | TOGOLD 94, AWAY 0, MOVED-WRONG 0, STILL-WRONG 0 | differ 19 → 0 |
| SimpleUVM ×2        | TOGOLD 0, AWAY 0, MOVED-WRONG 0 | differ 0 → 0 |
| Scoreboard/default  | TOGOLD 0, AWAY 0, MOVED-WRONG 0 | differ 0 → 0 |
| BuildUVMPkg ×2      | TOGOLD 0, AWAY 0, MOVED-WRONG 0 | differ 6 → 6 (see below) |

BuildUVMPkg's six are a DIFFERENT family, untouched in both directions: a
package `parameter`'s typespec is unnamed in ours where golden names it
`UVM_FILE` and aliases it to `uvm_pkg::UVM_FILE`, in `uvm_pkg` — the HOME, not a
clone.  6 → 6 is the point: the law does not reach it.

**Corpus-wide.**  `predict180` reads OUR PRISTINE DATABASES ONLY — no golden and
no patched artifact — and names the cells the law can touch.  Over all **956**
surelog databases it named exactly **four** row-modes, and over all **1358**
uhdm2rtlil databases it named **none** (`PREDICT.r10uvm180.*`).  That prediction
was made before the patched sweep's `byteverify` ran, and `byteverify` then
measured exactly those four and zero.

---

## 7. THE GRIDS — KINDS × HOMES × LISTINGS × SPELLINGS × DEF/ELAB

Five purpose-built arms, each compiled by BOTH binaries in BOTH views against a
FRESH Surelog golden (`grid180.sh`, which records every command WITH ITS BINARY
PATH and every rc into `cmds.txt`).  Names are deliberately unlike each other and
unlike the corpus's — a grid that calls everything `a_t`/`b_t` over `A`/`B` is
self-confirming.

| arm | what it varies | what it must show |
|---|---|---|
| `g180_a_kinds` | seven LAW-S scalar kinds + an enum + a packed struct, each bound as a formal, a top-level local, a nested-block local and a call argument | the kind axis; the aggregates must not move |
| `g180_b_depth` | one typedef at depths 1..5 through `if`/`for`/`while`/`case`/`forever`/named `begin`/`foreach`, plus three expression shapes | the depth and statement-shape axis |
| `g180_c_home` | the HOME package's own body, a WILDCARD importer's clone, an EXPLICIT importer's clone, and a package with NO import that spells the typedef identically | the home control and the import-kind axis |
| `g180_d_class` | a clone body that declares a class handle, calls a class method and reads a class property, beside plain block locals | FENCE 2 |
| `g180_e_chain` | two hops, a diamond, a re-export and a SHADOW (`marl_lt` exists in three packages) | the import-graph axis |

Scores are in `GRID.r10uvm180.txt`; `score180.py` is the three-way join
(golden, pristine, patched).  Note that `ct180grid` is STRICTER than the judge:
it compares an alias name on every typespec binding it can reach, including ones
`Compare` never walks, so an arm can carry STILL-WRONG cells and still be EQUAL
to golden (`vxpkg8` is 8 STILL-WRONG and 0 cmp lines).  The official counts in
the same table are the verdict; the cell scores are there to say WHICH cells
moved and to prove AWAY=0.  `g180_a_kinds` goes from **116 cmp lines / 1 head
to 0 lines / 0 heads — EQUAL to golden — in BOTH views.**  `g180_c_home`'s cells
move in `hz180_wild` ONLY: `hz180_root` (the home) and `hz180_alone` (no import)
are untouched, and the arm's head moves from the wildcard clone to the EXPLICIT
clone, which is R1 below.

---

## 8. THE WIDE BOUNDARY

`bound180.sh` (r10uvm178's, verbatim): every `.sv`/`.v` under a COPY of
`tools/probe`, both binaries, DEF and ELAB, file list read on fd 3 with children
`</dev/null`, PROCESSED asserted, subdirectories included, fenced names skipped
and COUNTED.

Every arm it flagged was then scored by the OFFICIAL `uhdm-cmp` against a fresh
Surelog golden, on both binaries and in both views (`GRID.r10uvm180.txt`).

**A limitation this pass MEASURED and records for the next operator.**  The wide
boundary compares `uhdm-dump` output, and a clone-copy re-point can be
dump-invisible: `g180_c_home`'s two databases differ in BYTES while their dumps
are byte-identical, because the dump prints the same objects the same number of
times and only the EDGES between them moved.  The boundary therefore UNDER-reports
this family, and the instrument that does not is `predict180`, which reads the
databases structurally — which is why the corpus-wide claim above rests on
`predict180` over all 956 + 1358 databases and on `byteverify`, not on the dump.

---
## 9. THE NEW HEADS — R0 FOR THE NEXT PASS

The four moving row-modes DO NOT land on one head this time; SeqDriver and
MiniAmiq split into two different families, and both are new.

**SeqDriver ×2, 29 cmp lines, one head** (`head_pat_SeqDriver.*.cmp`):

```
LHS(golden) = ref_var(j)@1018:19-1018:20 #8259
              < foreach_stmt(uvm_pkg::uvm_table_printer::calculate_max_widths)@1018:4
              vpiTypespec -> ref_typespec -> array_typespec #323101
RHS         = <null>
```

`BaseClass.h`'s SINGULAR `SafeCompare` printing `RHS: <null>` with a full LHS
means GOLDEN has the value and WE do not: golden gives a `foreach` loop
variable a `vpiTypespec` — a `ref_typespec` onto the ARRAY's typespec — and we
give it none.  The site is uvm-1.2 `base/uvm_printer.svh:1018`
(`uvm_table_printer::calculate_max_widths`), in `uvm_pkg` itself, so this is a
HOME-listing question and not a clone one.  It is the `foreach`-loop-variable
family, adjacent to § `cloneLoopVarShared37`.

**MiniAmiq ×2, 26 cmp lines, one head** (`head_pat_MiniAmiq.*.cmp`):

```
LHS(golden) = unsupported_typespec(arg)@622:11-622:14 #120949
              < ref_typespec(svaunit_pkg::uvm_has_wildcard::arg)
RHS(ours)   = string_typespec()@614:42-614:48 #182950
```

Golden leaves a formal's typespec UNSUPPORTED where we resolved it to a
`string_typespec`, and the two spans differ (622:11 the formal's own type token
vs 614:42 the declaration we resolved to) — a `uvm_has_wildcard(string arg)`
inside the `svaunit_pkg` clone.  This is the unsupported-typespec family, not
this one's.

Both rows are now well under 30 cmp lines, from 142 and 116.

## 10. RESIDUES

- **R0 — the two new heads of § 9.**  SeqDriver ×2 at **29** cmp lines / 1 head:
  golden gives a `foreach` loop variable a `vpiTypespec` (a `ref_typespec` onto
  the array's typespec) and we give it none — `RHS: <null>`, at uvm-1.2
  `base/uvm_printer.svh:1018`, in `uvm_pkg` itself, so it is a HOME-listing
  question adjacent to § `cloneLoopVarShared37`.  MiniAmiq ×2 at **26** cmp
  lines / 1 head: golden leaves a formal's typespec `unsupported_typespec(arg)`
  at 622:11 where we resolved it to a `string_typespec` at 614:42
  (`uvm_has_wildcard(string arg)` in the `svaunit_pkg` clone) — the
  unsupported-typespec family.  Two different families; neither is this one.

- **R1 — the EXPLICIT-import clone.**  Surelog's `importPackage` clones a
  package's subroutines whenever `inPackage` is true, named import or wildcard
  alike, and golden's explicit-import clone is bare exactly like the wildcard
  one.  Our `pkgImportCloneTfs16` is wildcard-only, so `hz180_named` in
  `g180_c_home.sv` is STILL-WRONG in BOTH binaries — at depth 0 as well, which
  means the PRE-EXISTING § 16 loops do not reach it either.  It is now that
  arm's cmp head (the head moved there from `hz180_wild` when this law cleared
  the wildcard half).  A pass that widens `pkgImportCloneEmit` to explicit
  imports owns it; `g180_c_home.sv` is the ready-made witness, and FENCE 3 must
  come with it.

- **R2 — the UNPACKED-ARRAY element typespec in a clone body.**  In
  `g180_b_depth.sv`, `pumice_lt tray [4]`'s element typespec has NO NAME at all
  in ours, in BOTH binaries and in BOTH the home and the clone, where golden
  names it and aliases it (qualified in the home, bare in the clone).  LAW S's
  `pkgScalarTd` never sees an array element, so neither § 16 nor this law can.
  12 of `g180_b_depth`'s elab cells are this, and so are `v123_c_kinds`'s 14.

- **R3 — a clone body's `func_call` binds the HOME body.**  Walking down a
  clone body one crosses `func_call` → `Function()` into `uvm_pkg`'s OWN
  subroutine (`adpcm_pkg/function@545:1/…/func_call@548:11/function@483:1/…`),
  where golden has no such path at all — `ct180ref` marks every cell under it
  ONLY-OURS.  The qualified alias down there is CORRECT (it is the home body),
  so nothing of this law's is at stake, and the first cut of `predict180`
  mis-attributed it to the clone; the committed `predict180` keys the package
  off the SUBROUTINE's own `VpiParent` and does not.  The binding difference
  itself belongs to the § 178 / § 9 clone-binding family.

- **R4 — the build-layout-derived integer (r10uvm178's R3, still open).**
  `r10buvm22repro/g22.sv` and `r10uvm154repro/l154_noenum.sv` are FALSE movers
  in any wide boundary run: each holds an uninitialised-read integer that shifts
  when the binary grows (`vpiDecompile:22593273` → `22605561` on `l154_noenum`,
  the whole of its 8-line dump delta).  Both are invisible to the judge — their
  official cmp logs are identical on the two binaries — and both moved here for
  that reason alone.  Worth fixing so the boundary gate stops lying.

- **R5 — the wide boundary UNDER-reports this family.**  `g180_c_home`'s
  databases differ in bytes while their `uhdm-dump` output is byte-identical
  (§ 8).  A pass in this family must not treat a clean `bound*.sh` run as
  proof; `predict180` over the corpus is the instrument that sees it, and on
  the PATCHED corpus it reports 0 flagged / 0 problems over all 956 databases.

---

## 11. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `README.md` | this |
| `ct180own.cpp` | the owner-finder: the head with BOTH parent chains and both listings, every referrer on each side, the face counterparts, the per-listing TYPESPEC copy map, and the index-by-index LISTING PAIRING (STEP 3) that settles the 46-vs-89 question |
| `ct180cen.cpp` | the DECLARATION census: every io_decl/variable in every package subroutine body, keyed listing/role/class/function/block-depth/name@line:col, reading the typespec's `VpiName` and its `Typedef_alias` target's |
| `ct180ref.cpp` | the WIDE `ref_typespec` census: every typespec binding reached DOWN a package subroutine's tree (UhdmListener; the path is the key), which is the only way to see the EXPRESSION role |
| `ct180grid.cpp` | the single-database cell dump the arm scorer joins on |
| `predict180.cpp` / `predict180.sh` | the mover predictor: reads OUR PRISTINE databases only and names the cells the law can touch — this is what predicted the four surelog movers and the zero uhdm2rtlil movers before the patched sweep's byteverify ran |
| `cen180score.py` | joins two `ct180cen` runs (golden-vs-pristine, golden-vs-patched) into TOGOLD / AWAY / MOVED-WRONG / STILL-WRONG, key gaps reported and never scored |
| `score180.py` | the three-way arm scorer over `ct180grid` dumps |
| `cen180.sh` | the nine-UVM-row-mode census driver (finds each row's golden in its OWN `cmds.txt`) |
| `grid180.sh` | the arm driver: fresh Surelog golden + both binaries × both views, every command echoed WITH ITS BINARY PATH and every rc recorded |
| `bound180.sh` | the WIDE boundary gate (r10uvm178's, verbatim) |
| `g180_a_kinds.sv` … `g180_e_chain.sv` | the five arms (§ 7) |
| `head_pris_*.cmp` / `head_pat_*.cmp` | the four moving row-modes' official cmp logs, before and after |
| `GATES.r10uvm180.txt` | the landing gate battery as run |
| `CENSUS.r10uvm180.txt` | both censuses, all nine UVM row-modes |
| `PAIRING.r10uvm180.txt` | the index-by-index listing pairing (383 slots, 0 mismatches) |
| `PREDICT.r10uvm180.surelog.txt` / `.uhdm2rtlil.txt` | the prediction, from pristine databases only |
| `MOVERS.r10uvm180.txt` | the byte movers and their order-blind attribution |
| `GRID.r10uvm180.txt` | every arm's official cmp counts and score |
| `BOUNDARY.r10uvm180.txt` | the wide boundary run |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | the standing gate scripts, copied unchanged so this directory is self-contained |
