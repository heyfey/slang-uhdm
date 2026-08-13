# r10uvm67 — § retLocalPkgRangeBind67: the briefed 33-line head **CLEARED on all THREE target rows**, 7 movers all predicted BY NAME — and **the brief's own description of the head was wrong in three ways**, which the mandated census caught before a single line was written

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after, and no conversion
was expected. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines — whole ROW, dump column included — with **0 differing
ROWS** on both.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**
(`SimpleUVM/default`, `SimpleUVM/testflags`, `Scoreboard/default`). The new head
on all three is a *different object in a different family* — an `int_var` at
`uvm_text_recorder.svh:1038:18` carrying `vpiSigned:1` that golden does not — and
**that divergence is PRE-EXISTING and was masked**: it is present in the
**pristine** dump at line 812952 (§6 residue 1). cmp LINES went 33 → 58, which is
HEAD DEPTH, not distance: the head object changed, so the old divergence is gone.

**THIRD LINE, and it is the one this pass exists to record. THE BRIEF DESCRIBED
THE HEAD WRONG, IN THREE WAYS, AND EVERY ONE OF THEM WOULD HAVE SENT THE PASS
INTO A DIFFERENT FILE.** The brief said the failing pair was a package
parameter's *own* `param_assign` Rhs — "the constant's value encoding, the
typespec presence/kind/span, or the ref_typespec name" — and told me to build
arms for TYPED package parameters with folded initialisers.

1. **`uvm_globals.svh:410` is UNTYPED** (`parameter UVM_LARGE_STRING = ...`, no
   data type), so "typed package parameters" named the wrong population.
2. **That `param_assign` and its Rhs constant are BYTE-IDENTICAL on both sides**
   (§1.2). Nothing about the value encoding, the typespec, or the
   `ref_typespec` name is wrong with them.
3. **The `uvm_pkg` ref_typespec name is not odd and needs no decoding**: the
   campaign's own `stampFoldedPkgParamTs` already stamps
   `VpiFullName(<enclosing-scope prefix>)` on a folded package parameter's
   ref_typespec, and OUR side prints exactly the same `(uvm_pkg)` /
   `vpiFullName:uvm_pkg` in the same place (§1.2). It was never a distinguisher.

The constant in the cmp head is a **REACHED** object, not a **BROKEN** one.
`ref_obj::Compare` walks `Actual_group` immediately after `VpiName`, so a
`ref_obj` whose `vpiActual` is null on our side reports
`LHS: <the object golden points at> / RHS: <null>` — and `chain()` then prints
that object's OWN parent chain (`param_assign < package uvm_pkg`), which is what
the brief read as "the head is in the param_assign". **The head was a DANGLING
POINTER two files away**, at `uvm_globals.svh:421`, in the return type of
`function bit[UVM_LARGE_STRING:0] uvm_string_to_bits`.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `ct67arm.sh` and `rowheads.sh` print that they did on every run.

Base **00b7fda**. Worktree `/tmp/wt_r10uvm67`; pristine control worktree
`/tmp/wt_r10uvm67pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `00b7fda089084e42ca7c51e4e0231aeba8d11fb8`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 00b7fda) | `28a566eb8d342b653f0ce68ebe0518ac` | my own build of the base commit |
| **SHIPPED (patched)** | **`906ced1ada00852a2bcd3ad4bda18ec0`** | every gate number below was measured on THIS binary |

BUILD DIRS (absolute): `/tmp/wt_r10uvm67/build`, `/tmp/wt_r10uvm67pris/build`.
The link line (`[100%] Linking CXX executable slang-uhdm` → `[100%] Built target
slang_uhdm`) was waited for and read before any md5 was taken; every md5 was
asserted in its own command and matched against an explicit `^[0-9a-f]{32}$`.
`git stash` was never used. The four slang-fenced tests (`UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam`) were never dispatched —
`canaudit.sh` proves it mechanically (FENCE-BREACH=0). `GOLDEN_DEFER` left
**UNSET** (echoed as `[UNSET]` at both sweep launches; **5 DEFERRED** in both
surelog modes, as in the baseline). slang was not patched. `results/*.csv` were
only ever read.

**COLLISION CHECK — NO COLLISION.** The delivered patch
(`/tmp/r10uvm67.patch`, md5 `bef1d2b5583193a01b386d252751c0bd`) `git apply
--check`s **clean on a fresh `00b7fda` worktree AND on the current branch head
`97f6f90`**, and re-`git diff`ing the applied tree regenerates a patch with the
**same md5** (it round-trips). The three commits that landed since the base
(`r10svs14 42c42f6`, `r10earl37 49475c9`, `r10svs15 97f6f90`) DO touch
`include/UhdmExporter.h` (+28) and `src/ModuleEmit.cpp` (+242/−53) — the two
live passes named in the brief — but in different regions, so the hunks apply
unchanged. `src/TypeEmit.cpp` was untouched by all three.

**OPS NOTE.** `make -j 4` was **OOM-killed** mid-pass (`c++: fatal error: Killed
signal terminated program cc1plus`, `free` showing `available: 0` of 15 GB with
other agents' `cc1plus` resident). `-j 2` completed. Same trap as r10uvm66's ops
note: **check `free` before reading a build log** — a build that dies without an
`error:` line is not a compile error.

**LANDING HYGIENE.** This directory contains **no `README.verifier.md` copied
from r10uvm66** — see `README.verifier.md`, which is THIS pass's and states
plainly that **no independent adversarial verifier ran**, exactly which
self-checks the implementer ran, and which adversarial checks are therefore
MISSING. A stale pass-66 verifier document was deliberately not carried over.

---

## 0. THE LAW

### § retLocalPkgRangeBind67

*The **per-reference body-local return variable** that `drainFuncRet` mints for
every reference to a subroutine's implicit return name compiles its return type
with **`tfTypeScope` unset**, alone among the two emissions of that type. For a
**PACKAGE-homed** subroutine that type's **range bound naming a parameter** must
therefore bind nothing, where golden binds `vpiActual` to that parameter's own
Rhs object — the declaration's **`operation`** in the package DEF view and the
folded **`constant`** in the elaborated view. Set `tfTypeScope` (and, with it,
the `::` reference separator a package-scope local's fullname uses) and the
already-landed `§ r10fsv3 S3` arm does the rest; the DEF-view local additionally
needs `pkgParamDefRhsDefView17`, because the drain runs after every view and the
per-view maps are frozen in their LAST-view state.*

```
uvm-1.2/src/base/uvm_globals.svh
407  parameter UVM_LINE_WIDTH   = `UVM_LINE_WIDTH;                 //    120
408  parameter UVM_NUM_LINES    = `UVM_NUM_LINES;                  //    120
409  parameter UVM_SMALL_STRING = UVM_LINE_WIDTH*8-1;              //    959
410  parameter UVM_LARGE_STRING = UVM_LINE_WIDTH*UVM_NUM_LINES*8-1;// 115199
...
421  function bit[UVM_LARGE_STRING:0] uvm_string_to_bits(string str);
422     $swrite(uvm_string_to_bits, "%0s", str);     <- the reference that makes
423  endfunction                                        the drain mint a local
```

* **DIRECTION: ADD a binding, and RE-SPELL one fullname.** It is not add-only and
  is never described as one: `mv67.sh` reports **8 ADDED and 4 REMOVED line
  instances** per UVM database, and all 4 REMOVED are the `.`-separator spelling
  of the two `ref_obj` lines being replaced by the `::` spelling golden uses
  (§4). No object is deleted.
* **Both added texts land at EXACTLY golden's count** in all 7 databases:
  `\_ref_obj: (uvm_pkg::uvm_string_to_bits::uvm_string_to_bits::UVM_LARGE_STRING)`
  golden 2 / pristine 0 / patched **2**, and its `|vpiFullName:` line likewise
  2 / 0 / **2** (§4).
* `grep -rn 'retLocalDefView67' src/ include/` → **1 declaration, 1 consumer
  (TypeEmit), 3 lines at the single setter (ModuleEmit)**.

### STATED GATE == CODE GATE — read off the source, not the comment

| | |
|---|---|
| **the whole gate, site 1 of 2** | `ModuleEmit.cpp` `drainFuncRet`, the `if (!ts)` return-type emission: `retPkgScope67 = sub.getParentScope()` **iff** that scope's `kind == SymbolKind::Package` · `retTopView67` = `pf.inst` is a value in `pkgTopMap` (the same test the aggregate-typedef arm two blocks above already makes as `topPf1`) · when `retPkgScope67`: `tfTypeScope = retPkgScope67`, `retLocalDefView67 = !retTopView67`, `syntaxRefSep = "::"` · all three saved and restored around the one `makeTypespec` call |
| **the whole gate, site 2 of 2** | `TypeEmit.cpp`, the `§ r10fsv3 S3` arm inside the `IdentifierName` case: **one new leading branch** — `if (retLocalDefView67 && pkgParamDefRhsDefView17.find(&psy) has a non-null value) → bind it`, otherwise the pre-existing three-branch chain runs **unchanged** |
| **not in the gate** | no module/interface/class/`$unit`-scope arm · no argument-type arm · no body-local arm · no test on the parameter's TYPE, its initialiser form, or its value · no new map, no new pass, no design-final walk · nothing outside the `if (!ts)` branch of `drainFuncRet` · `tfContext`, `syntaxRefPrefix`, the ref-typespec/alias/`Instance` handling and the span logic are untouched |
| **also shipped, deliberately** | `R10UVM67_REFDBG=1`, a `static const bool`-gated one-line-per-identifier-ref trace at the branch point, printing every gate that could have stopped a bind. It is what found the answer (§1.4) and it is the reason the next pass in this family will not need a build to ask the same question. |

**Why PACKAGE-HOMED ONLY, measured rather than assumed.** Arm a2 m12 is the
module-scope twin (`function bit[A2_LARGE:0] t_to_bits` inside `module a2top`,
reading a `$unit`-wildcard-imported package parameter). **Golden emits NO
range-bound `ref_obj` there at all** — it folds the bound to a constant — so the
cell is `-NOOBJ-` on golden's side and binding ours would be minting agreement
with nothing (§2, cell `103:16`). The same gate keeps the separator change off
the module case, whose golden fullname convention is not measured here.

### 0.1 Why the DEF-view branch exists at all

`drainFuncRet` runs **after every package view is emitted**. `pkgParamConst` and
`pkgParamDefRhs` are per-view maps that the top-view pass overwrites, so at drain
time both locals — the def view's and the elaborated view's — read the SAME final
state and both bound the folded `constant`. Golden binds **one of each**. The v1
build measured exactly that: arm a2 40:16 came out
`{constant, constant, constant, operation}` against golden's
`{constant, constant, operation, operation}`. `pkgParamDefRhsDefView17` is the one
map `§ pkgOwnParamRefActualIsRhs17` records per-DEF-view and the top pass cannot
overwrite; reading it first when `retLocalDefView67` is set produced the exact
multiset. **A one-branch patch would have looked green on 5 of 8 cells and put
the wrong object on the other 3.**

---

## 1. WHAT WAS MEASURED BEFORE ANY CODE WAS WRITTEN

### 1.1 The head, on my own pristine build

```
rowheads.sh /tmp/r10uvm67_ctl_wd …   SimpleUVM Scoreboard
  SimpleUVM   default     33 cmp lines  1 head
  SimpleUVM   testflags   33 cmp lines  1 head
  Scoreboard  default     33 cmp lines  1 head
  Scoreboard  testflags   SKIP-NOFILE (SLANG_REJECT, no database — reported, not hidden)
```

### 1.2 THE CENSUS OF BOTH SIDES, SPAN-KEYED — the brief's first instruction, and it REFUTED the brief

`census67.py <g.dump> <o.dump> 'param_assign@410:11-410:62'` and
`'constant@410:30-410:60'`, run before any theory. Every container path, every
field, both sides:

| object at line 410 | GOLDEN (LHS) | OURS (RHS, pristine) |
|---|---|---|
| `parameter uvm_pkg::UVM_LARGE_STRING @410:11-410:27` | 2 prints, both under `package(uvm_pkg)` | **identical, 2 prints** |
| its `int_typespec @410:1-410:62` (the whole-declaration span) | present | **present, same span** |
| DEF-view `param_assign @410:11-410:62` Rhs | `operation @410:30-410:62` over two `ref_obj`s | **identical, operand for operand** |
| ELAB-view `param_assign` Rhs | `constant`, `INT:115199`, `vpiSize 32`, `vpiConstType 7`, decompile `115199` | **identical, field for field** |
| that constant's `vpiTypespec` | `ref_typespec (uvm_pkg)`, `vpiFullName:uvm_pkg` → `int_typespec @410:1-410:62` | **identical, name included** |

**Not one of the three failure modes the brief listed is present.** The only
line-410 difference the census found is on the *parameter object* in the
elaborated view — golden `INT:115199`, ours `UINT:115199` — which is a
**different family**, is NOT the head (the head is a `constant`, not a
`parameter`), and is left untouched by this pass (§6 residue 3).

### 1.3 WHERE THE HEAD ACTUALLY IS — three instruments, one answer

1. **`ct67cells.py`** (this pass's grid) keys every RANGE-BOUND `ref_obj` and
   prints its `vpiActual`. On SimpleUVM it names ONE differing key:

```
   UVM_LARGE_STRING @421:16-421:32
     GOLDEN 6 objects   4 unnamed (2 views x 2 sites) + 2 function-qualified
            unnamed        -> constant@410:30 , constant@410:30 , operation@410:30 , operation@410:30
            f::f::NAME     -> constant@410:30 , operation@410:30
     OURS   6 objects, the same spans
            unnamed        -> constant , constant , operation , operation   (already correct)
            f::f.NAME      -> NULL , NULL                                   <- THE HEAD
```

2. **`ref_obj::Compare`, read out of UHDM's generated source**: `VpiType`,
   `m_visited` insert, `expr::Compare`, `VpiName`, `VpiDefName`, `VpiGeneric`,
   then **`SafeCompare(Actual_group)`** — and `SafeCompare(lhs, nullptr)` sets
   `m_failedLhs` and leaves `m_failedRhs` null. That is the head's exact
   printout. **`VpiFullName` is never compared**, which is why the `.`/`::`
   spelling is a dump-line fact and not a cmp fact.
3. **`ct67design.cpp`** (this pass's design-field comparator) confirms the
   deepest failing pair is that constant with `rhsNULL`, and prints the whole
   design-field landscape besides (§6 residues 4–5).

**A NOTE ON WHY THE HEAD'S PARENT CHAIN LIES.** `m_failedLhs` is the object
golden POINTS AT; `chain()` walks its `VpiParent`. A shared value object's parent
is its declaration, not the reference that reached it. Four of the last five UVM
briefs mis-described the gap by reading that chain as the location — this pass
makes five, and the fix is the same each time: read our side from the cmp RHS and
census both sides span-keyed FIRST.

### 1.4 THE ENV-GATED TRACE, at the branch point

`R10UVM67_REFDBG=1` on the arm printed, in one command, the reason:

```
DBG67 name=A2_LARGE full=A2_LARGE                                loc=40:16 bound=constant   tfTs=1 curPkg=a2pkg cur=0
DBG67 name=A2_LARGE full=A2_LARGE                                loc=40:16 bound=operation  tfTs=1 curPkg=a2pkg cur=0
DBG67 name=A2_LARGE full=a2pkg::a2_to_bits::a2_to_bits.A2_LARGE  loc=40:16 bound=NULL       tfTs=0 curPkg=-     cur=1
DBG67 name=A2_LARGE full=a2pkg::a2_to_bits::a2_to_bits.A2_LARGE  loc=40:16 bound=NULL       tfTs=0 curPkg=-     cur=1
```

`tfTs=0` on exactly the unbound rows. No map was missing, no flag was set against
us: the **scope was simply never handed to the emitter** at one of its two call
sites. (r10e23's lesson, applied: an env-gated trace at the branch point beats a
hypothesis. It cost one build and closed the question in one line.)

---

## 2. THE GRID, CELL FOR CELL — arm `a2_rangeref.sv`

`ct67cells.py` TABLE B (fullname-blind, so the `.`/`::` spelling cannot split a
cell into two UNMEASURED halves; TABLE A keys the fullname too and is printed
beside it). `G` = golden. `pre` = ours `28a566eb…`. `post` = ours `906ced1a…`.
Each cell's value is the MULTISET of `vpiActual` over all views of that
reference.

| cell | source (all package-scope unless noted) | G | pre | post |
|---|---|---|---|---|
| **m01 40:16** | **the corpus shape: `function bit[A2_LARGE:0] a2_to_bits`, folded param** | `{const,const,op,op}` | `{NULL,NULL,const,op}` | **match** |
| m02 45:39 | the same bound on an **ARGUMENT** type | `{const,op}` | same | same |
| m03 50:16 | **literal**-initialised param as the bound | `{const×4}` | `{NULL,NULL,const,const}` | **match** |
| m04 55:16 | **localparam** as the bound | `{const,const,op,op}` | `{NULL,NULL,const,op}` | **match** |
| m05 60:16 | **typed** (`parameter int`) param as the bound | `{const,const,op,op}` | `{NULL,NULL,const,op}` | **match** |
| m06 66:10 | a **body-local variable**'s range (`§ r10fsv3 S3`'s own cell) | `{const,op}` | same | same |
| m08 77:16 | an **EXPRESSION** bound (`[A2_LARGE-1:0]`) | `{const,const,op,op}` | `{NULL,NULL,const,op}` | **match** |
| m07 72 | a **literal-only** bound (control: no ref_obj at all) | — | — | — |
| m09 82:8 | a package **VARIABLE**'s range | `{parameter}` | `-NOOBJ-` | UNMEASURED — §6.2 |
| m10 86:18 | a **CLASS METHOD**'s return range | `-NOOBJ-` | `{const}` | UNMEASURED — §6.2 |
| m11 93:16 | a package **TYPEDEF**'s range | `{parameter}` | `{op}` | DIFF, untouched — §6.2 |
| **m12 103:16** | **MODULE-scope function, `$unit`-imported param** | **`-NOOBJ-`** | `{NULL,NULL}` | **deliberately untouched** |

**5 cells moved DIFF→SAME; 0 moved SAME→DIFF** (TABLE B: SAME 2→7, DIFF 6→1).
TABLE A additionally loses 2 UNMEASURED rows, because the two fullname spellings
that used to key separate half-cells now key one measured cell.

**m03 against m01 is the whole initialiser axis**: a literal-init param wants
`{const×4}` and a folded one wants `{const,const,op,op}`, and ONE branch order
produces both — the def-view branch reads `pkgParamDefRhsDefView17`, whose entry
for a literal-init param IS the def constant. **m02 is the negative control that
keeps the gate narrow**: an ARGUMENT range was already right on both sides, so
the law is about the RETURN-name local and nothing wider.

### 2.2 THE BRIEF'S OWN ARM, `a1_pkgparamts.sv`, gridded rather than asserted

Every `param_assign` in a1, keyed by its Lhs fullname, valued by the MULTISET of
`(Rhs kind, span, value, size, constType, ref_typespec name → actual kind/span)`
over all views. **This arm is UNCHANGED by the patch**: with the workdir path
normalised out of `file:` (the ARM-PATH trap, and it fired — the raw dumps differ
only by the workdir string), pristine and patched `o.dump` are BYTE-IDENTICAL.

| view | SAME | DIFF | the DIFF cells |
|---|---|---|---|
| PACKAGE (`a1pkg::`) | **31** | **5** | `A1_LIT_SIZED`, `A1_NEG`, `A1_PARENS`, `A1_TBY_FOLD`, `A1_TERN` |
| IMPORT-MATERIALIZED (`work@a1top`) | 7 | **29** | almost every cell |

**THE WITNESS'S OWN SHAPE IS IN THE 31.** `A1_SMALL_STRING` and
`A1_LARGE_STRING` — untyped package parameters with folded initialisers over
other package parameters, the exact shape of `uvm_globals.svh:409/410` — are
**SAME in the package view, in both of its own sub-views, field for field
including the `ref_typespec (a1pkg)` name and the whole-declaration
`int_typespec` span**. That is the measurement §7.1 rests on, and it is a grid
row, not an assertion.

The 5 package-view DIFFs are four distinct pre-existing families, none of them
the head and none of them line 410's shape (§6.8). The 29 import-materialized
DIFFs are ONE family with one signature (§6.9): golden's TWO materialized copies
of a parameter carry **two different Rhs spans** — one ending at the RHS's last
token, one ending at the DECLARATION's end — and we emit the first span twice.

### 2.1 THE REVERSE AUDIT — whole design, three UVM databases

Same instrument, whole design, every range-bound reference:

| | pristine | shipped | moved |
|---|---|---|---|
| `SimpleUVM` TABLE B | SAME=7 **DIFF=6** UNM=1 | SAME=8 **DIFF=5** UNM=1 | **1 DIFF→SAME, 0 SAME→DIFF** |
| `SimpleUVM` TABLE A | SAME=8 DIFF=7 UNM=4 | SAME=9 DIFF=7 UNM=2 | +1 SAME, −2 UNMEASURED |
| `BuildUVMPkg` TABLE B | SAME=13 **DIFF=3** UNM=1 | SAME=14 **DIFF=2** UNM=1 | **1 DIFF→SAME, 0 SAME→DIFF** |
| `SeqDriver` TABLE B (clone view) | SAME=4 **DIFF=9** UNM=1 | SAME=5 **DIFF=8** UNM=1 | **1 DIFF→SAME, 0 SAME→DIFF** |

**OVER-FIRE = 0**: no cell where golden leaves `vpiActual` null and we now bind
it. **UNDER-FIRE of this law = 0**: no remaining cell whose only defect is a null
actual on a package subroutine's return-name local. The residual DIFF cells are
three other families, named in §6.

---

## 3. THE CENSUS-PREDICT, run BEFORE the verifier

`census67src.py` scans SOURCE (block comments, line comments and string literals
stripped first) for every site the law can fire on: a subroutine at PACKAGE
scope, whose RETURN type carries a range, whose range text holds an identifier,
and whose BODY names the routine (or the drain mints no local at all). It is
deliberately independent of the patch.

**Its first version predicted ZERO for UVM and was WRONG, and the reason is worth
keeping**: `uvm_globals.svh` has no `package` line of its own — it is
`` `include ``d into `uvm_pkg.sv` between `package uvm_pkg;` and `endpackage` —
so a file-local scan classified the witness as "not package scope". The fixed
script classifies a file with **no container of its own** as an INCLUDE BODY and
reports its routines as CANDIDATES **in their own column**, never merged with the
certain ones.

Stated bound: **exact on distinct SOURCE SITES**; a **LOWER** bound on dump-line
movers (each site moves once per view and once per binding reference, and the
script counts neither); it cannot know whether a file's test compiles or whether
an identifier resolves to a parameter.

* **uhdm2rtlil corpus: 0 sites, 0 candidates → 0 movers, both modes.**
* **UVM 1.2: 0 certain, 1 CANDIDATE** — `src/base/uvm_globals.svh:421
  uvm_string_to_bits`, `range=[UVM_LARGE_STRING:0]`. The witness, and the only
  one.
* **The rest of the Surelog corpus: 2 certain sites + 4 candidates in 3 files**,
  read against the committed READ-ONLY baseline:
  * `Ibex/…/dv_utils_pkg.sv:112 get_masked_data` — `Ibex` is **SLANG_REJECT in
    both modes** (no database) → cannot move;
  * `Opentitan/…/dv_utils_pkg.sv` — `Opentitan` is **SLANG_REJECT in both
    modes** → cannot move;
  * `YosysBigSim/bch_verilog/rtl/bch.vh` (4 candidates, `[MAX_M:0]`) — the file
    is `` `include ``d **inside a module** (`chien.v:16`, after the port list),
    so those routines are MODULE-scope and the gate excludes them; and no
    `bch`-family test row exists in the baseline at all → **predicted not to
    move**, with both reasons stated.

**PREDICTED MOVER SET, recorded before the byte verifier ran: 7 databases —**
`default/{BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM}` and
`testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}` (Scoreboard/testflags is
SLANG_REJECT).

**THE VERIFIER FOUND EXACTLY THOSE 7, and 0 in u2r.** `BlackParrotComplex`,
`SimpleConstraint`, `InterfaceModPort` did not move.

---

## 4. THE MOVERS, PER SHAPE, BY MULTISET

All 7, `mv67.sh` (LHS always golden). **ADDED and REMOVED are never netted.**

| mover | multiset distance to golden, pristine → patched | ADDED | REMOVED |
|---|---|---|---|
| `default/BuildUVMPkg` | 80345 → 80337 (**gain 8**) | 8 | 4 |
| `default/Scoreboard` | 134025 → 134013 (**gain 12**) | 8 | 4 |
| `default/SeqDriver` | 366876 → 366866 (**gain 10**) | 8 | 4 |
| `default/SimpleUVM` | 143692 → 143680 (**gain 12**) | 8 | 4 |
| `testflags/BuildUVMPkg` | gain 8 | 8 | 4 |
| `testflags/SeqDriver` | gain 10 | 8 | 4 |
| `testflags/SimpleUVM` | 143688 → 143676 (gain 12) | 8 | 4 |

**Every mover moves TOWARD golden, and all seven move by the SAME shape** — this
law fires exactly twice per database (once per package view of one function).

### 4.1 The four REMOVED instances are a RENAME, not a deletion

```
REMOVED  \_ref_obj: (uvm_pkg::uvm_string_to_bits::uvm_string_to_bits.UVM_LARGE_STRING)   x2
REMOVED  |vpiFullName:uvm_pkg::uvm_string_to_bits::uvm_string_to_bits.UVM_LARGE_STRING   x2
ADDED    \_ref_obj: (uvm_pkg::uvm_string_to_bits::uvm_string_to_bits::UVM_LARGE_STRING)  x2   golden=2 pristine=0 patched=2
ADDED    |vpiFullName:uvm_pkg::uvm_string_to_bits::uvm_string_to_bits::UVM_LARGE_STRING  x2   golden=2 pristine=0 patched=2
```

The same two objects, one separator apart. **Both added texts land at EXACTLY
golden's count in all 7 databases; 0 above, 0 still below.**

### 4.2 The other four ADDED instances, three-way counted

| text (indent-verbatim) | golden | pristine | patched | reading |
|---|---|---|---|---|
| `      \|vpiActual:` | 568 | 296 | 298 | still far BELOW golden — the two new bindings fill 2 of a 272-instance deficit |
| `      \_operation: , line:410:30, endln:410:62` | 3 | 2 | **3** | **exactly golden** |
| `      \_constant: , line:410:30, endln:410:60` | 4 | 2 | 3 | still BELOW golden |

Two rows in the seven read `ours ALREADY >= golden`, and both are instrument
artefacts of an INDENT-KEYED multiset, not defects: `BuildUVMPkg`'s
`      |vpiActual:` bucket (178/178/180) and `SeqDriver`'s
`      \_constant:` bucket (3/4/5) count only ONE indent depth, and the same
object printed at another depth lands in another bucket. **THE AUTHORITY ON
WHETHER THE RIGHT OBJECT GOT THE POINTER IS THE PER-OBJECT GRID (§2.1: OVER-FIRE
0, SAME→DIFF 0 on both of those databases) AND uhdm-cmp's HEAD**, never the
multiset.

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

`/tmp/wt_r10uvm67/build` and `/tmp/wt_r10uvm67pris/build`, absolute.
`[100%] Linking CXX executable slang-uhdm` then `[100%] Built target slang_uhdm`
read before any measurement; `grep -c "error:"` = 0. md5s asserted in their own
commands against `^[0-9a-f]{32}$`: control `28a566eb8d342b653f0ce68ebe0518ac`,
shipped `906ced1ada00852a2bcd3ad4bda18ec0`. Both worktrees at
`00b7fda089084e42ca7c51e4e0231aeba8d11fb8`. `retLocalDefView67`: **1 declaration
(UhdmExporter.h), 1 consumer (TypeEmit.cpp), 3 lines at 1 setter
(ModuleEmit.cpp)**.

### GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped> ./tests/check_goldens.sh   ->  PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh  ->  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--jobs 2`, own `--out`/`--workdir`

```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
dump column:            match 496        differ 183         (blank) 52
ct8rows.sh vs results/gate_uhdm2rtlil.csv (testflags-only extract, 731 rows both sides):
  WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  per-mode STATUS and DUMP histograms: identical
  PASS: every row byte-identical to the committed baseline
[default]   731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
            dump: match 492  differ 187  (blank) 52   (no committed baseline for this mode)
```

The committed baseline is testflags-only (731 rows, not 1462), so the row gate
was run on a testflags-only extract and the fact is stated rather than hidden.

### GATE 4 — surelog, both modes, `--jobs 2`, `GOLDEN_DEFER` echoed `[UNSET]`

```
[default]   794 tests  CMP_EQUAL 467  CMP_NOTEQUAL 13  DEFERRED 5  SLANG_REJECT 284  SURELOG_FAIL 25
[testflags] 794 tests  CMP_EQUAL 463  CMP_NOTEQUAL 10  DEFERRED 5  SLANG_REJECT 286  SURELOG_FAIL 23
                       NO_DATABASE 3  UNTRANSLATABLE 2  TIMEOUT 1  NO_UHDM 1
ct8rows.sh vs results/golden_surelog.csv:
  1588 ROWS both sides · WHOLE-ROW diff: 0 differing ROWS
  per-mode STATUS histograms: identical    per-mode DUMP histograms: identical
    default   327 blank / 242 differ / 225 match      (baseline and fresh)
    testflags 331 blank / 298 differ / 165 match      (baseline and fresh)
  PASS: every row byte-identical to the committed baseline
```

The pristine control sweep produced a CSV whose 1588 rows are **identical to the
patched sweep's** (`diff | wc -l` = 0), so the status figures are a property of
the corpus and not of either binary.

### GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs the PRISTINE 00b7fda I built

```
surelog  : PATH_SETS_IDENTICAL (953 paths)    MOVERS: 7 / 953
           SELFCHECK 952/953 flagged          SELFCHECK1 = 8  (= 7 real + 1 corrupted)
u2r      : PATH_SETS_IDENTICAL (1358 paths)   MOVERS: 0 / 1358
           SELFCHECK 1357/1358 flagged        SELFCHECK1 = 1  (= 0 real + 1 corrupted)
```

Both negative controls fire in both corpora, so "0 movers" in u2r is a
measurement and not a mis-wired driver. The 7 are the predicted set exactly:

```
MOVER ./default/BuildUVMPkg    MOVER ./default/Scoreboard   MOVER ./default/SeqDriver
MOVER ./default/SimpleUVM      MOVER ./testflags/BuildUVMPkg
MOVER ./testflags/SeqDriver    MOVER ./testflags/SimpleUVM
```

### MULTI-STABILITY, and the size delta

`detcheck.sh`, `Scoreboard/default`, 3 runs each:

| binary | distinct sha256 | bytes (all runs) |
|---|---|---|
| pristine `28a566eb…` | **2** | 11 122 503 |
| shipped `906ced1a…` | **3** | 11 122 522 |

The hash flake is **PRE-EXISTING** — the campaign's known emitter
nondeterminism (SourceLocation compares across macro buffers under parallel
parse) — and per the standing rule, **same size = flake**: the size is stable
within each binary across all three runs. The size DELTA is stable and real:
**+19 bytes**, the direction an ADD law predicts.

**The flake lands on exactly the UVM databases, which are exactly the byte
movers — so the byte compare ALONE could not establish that the 7 are real.** It
does not have to: the movers are established by DUMP CONTENT (§4: 8 added and 4
removed line instances each, both added texts at golden's exact count), by the
cleared `uhdm-cmp` head on three of them, and by the per-object grid (§2.1).

### CANARIES

```
canaries.sh  vs surelog baseline : ok=52  changed=0  absent=0  unknown-names=7  (the u2r-only names)
canaries.sh  vs u2r baseline     : ok=8   changed=0  absent=0  unknown-names=25 (the surelog-only names)
ctcan2.sh EXPECT_UNKNOWN=1 (sl)  : ok=58  changed=0  absent=0  unknown-patterns=1   PASS
ctcan2.sh EXPECT_UNKNOWN=6 (u2r) : ok=1   changed=0  absent=0  unknown-patterns=6   PASS
canaudit.sh canaries.sh ctcan2.sh: audited=29  UNCOVERED=0  FENCE-BREACH=0        PASS
BY NAME InterfaceModPort    default CMP_EQUAL/differ  testflags CMP_EQUAL/differ  == baseline
BY NAME BlackParrotComplex  default CMP_EQUAL/differ  testflags CMP_EQUAL/differ  == baseline
BY NAME SimpleConstraint    default CMP_EQUAL/differ  testflags CMP_EQUAL/differ  == baseline
BY NAME SVSwitch / ApbSlave / SeqDriver / BuildUVMPkg / SimpleUVM / Scoreboard    == baseline
```

Both canary scripts were run against **both** baselines, mode-matched, baseline
first, and the expected-unknown counts were stated to the scripts rather than
read back out.

### The two NON-TARGET UVM rows did not regress

`SeqDriver` (85 cmp lines) and `BuildUVMPkg` (58) keep **the same head object,
byte for byte**, before and after — `class_typespec (adpcm_pkg::type_id)@440:12`
and `ref_obj (…__deferred_init…)@14107:7` respectively. Their heads sit *earlier*
than this law's site, so both move bytes without moving their head, which is
exactly what §4 reports.

---

## 6. RANKED RESIDUES

1. **The new head on all three target rows** (58 cmp lines): `int_var
   uvm_pkg::uvm_text_recorder::m_set_attribute::file @1038:18` carries
   `vpiSigned:1` on our side and not on golden's. **PRE-EXISTING and proved so**
   — present at line 812952 of the PRISTINE dump, absent from golden's 819738
   block — and unmasked, not caused, by this pass. `int` is signed in
   SystemVerilog, so the question is why golden omits the flag on a
   declaration-initialiser local of a typedef'd `UVM_FILE` type; the sibling
   `int_typespec (UVM_FILE)@313:9` carries `vpiSigned:1` on our side too.
2. **`design.Parameters` and `design.Param_assigns` are NULL on our side where
   golden carries 45 each** (`ct67design`): a `$unit`-scope `import uvm_pkg::*;`
   (SimpleUVM `testbench.sv:1`) materialises the package's 45 parameters onto
   the **DESIGN** object as CLONES — `vpiParamAssign` in the package's own
   source order, `vpiParameter` NAME-SORTED, each `parameter` UNQUALIFIED with
   `vpiImported:uvm_pkg`, each `param_assign` re-parented on the design with a
   fresh Rhs clone whose `ref_typespec` is UNNAMED. `module_inst work@top` gets
   **90** (2×45) of the same clones with `work@top.NAME` fullnames and we emit
   **none**. Our `class_defn work@env` DOES carry 90 — but as the PACKAGE's OWN
   objects (`parent=package(uvm_pkg)`, `uvm_pkg::UVM_LARGE_STRING`,
   `vpiImported` empty) where golden clones (`parent=class_defn(work@env)`,
   `work@env::UVM_LARGE_STRING`, `vpiImported=uvm_pkg`). **One mechanism, three
   containers, fully decoded here and untouched by this pass** — the largest
   single item left on these three rows.
3. **The elaborated-view `parameter` object's value encoding**: golden
   `INT:115199`, ours `UINT:115199`, on `uvm_pkg::UVM_LARGE_STRING` (and its
   409 sibling). The `param_assign` Rhs constant next to it is INT on both
   sides, so this is the PARAMETER object alone. Same line the brief pointed at,
   different object — and cmp does not reach it yet.
4. **`design.Typespecs` 123 vs 89** — the typedef half of residue 2's
   `$unit`-import materialisation, 34 entries short.
5. **Three more range-bound families still DIFF on SimpleUVM** (§2.1's residual
   5): `UVM_HDL_MAX_WIDTH@50:16` (golden binds the **parameter**, we bind its
   **constant**), `UVM_STREAMBITS@49:23` (golden binds NOTHING in 13 views, we
   bind a constant in one — an OVER-fire of an OLDER law), and `uvm_phase@1722 /
   1896 / 1946` (golden binds a `logic_net@1664:21`, we bind nothing).
6. **Arm-only shapes this pass measured but did not touch**: a package
   VARIABLE's range bound (golden keeps a `ref_obj` → the **parameter**, we fold
   to a constant — arm m09, and it is the ARM's own unchanged head); a package
   TYPEDEF's range bound (golden → **parameter**, ours → operation — m11); a
   CLASS METHOD's return range (golden folds to a constant with no ref at all,
   we keep a bound ref — m10); a MODULE function's return range over an
   imported param (golden folds, we keep two unbound refs — m12). All four are
   the same open question — **when does Surelog bind a range ref to the
   `parameter` OBJECT rather than to its Rhs?** — and none is reachable by this
   law's gate.
7. **`|vpiActual:` is 272 instances short on SimpleUVM** (568 vs 298 after this
   pass's +2) at that one indent depth. A census of the deficit's owners is the
   cheapest next survey on this family.
8. **Four package-view param_assign families, from the brief's own arm** (§2.2,
   all pre-existing, all measured here for the first time):
   * `A1_TBY_FOLD` — a `parameter byte P = 8'd7 + 1;` folds to `vpiConstType 7`
     (INT) in golden and `9` (UINT) in ours, at the same size 8. A one-field
     encoding law on a BYTE-typed folded parameter.
   * `A1_NEG` / `A1_TERN` — a unary-minus and a ternary initialiser fold to
     `size 32` **with** the declaration's `int_typespec` in golden; ours emits
     `size 64` and **no typespec at all** in one view (`A1_NEG` also keeps the
     whole `operation` where golden keeps a folded constant beside it).
   * `A1_PARENS` — `(A1_LINE_WIDTH*8)-1`: our second view's folded constant
     spans the INNER parenthesised text (`44:26-44:41`) where golden spans the
     whole RHS (`44:25-44:44`).
   * `A1_LIT_SIZED` — `32'd115199`: one of our two copies carries no
     `ref_typespec` where golden gives both one.
9. **The IMPORT-MATERIALIZED copy's Rhs SPAN** (§2.2, 29 of a1's 36 cells, and
   visible on `work@a1top` for nearly every parameter shape): golden's two
   materialized copies of one package parameter carry **different Rhs spans** —
   copy A ends at the initialiser's last token, copy B ends at the DECLARATION's
   end (`34:31-34:46` and `34:31-34:48`) — while we emit copy A's span twice.
   One rule, 29 cells, and it is the same `$unit`/wildcard-import materialisation
   machinery as residue 2.

---

## 7. REFUTATIONS, stated plainly

1. **THE BRIEF'S DESCRIPTION OF THE HEAD IS REFUTED IN THREE PLACES** (§0 third
   line, §1.2): line 410 is UNTYPED, not typed; its `param_assign`, its Rhs
   constant, its `int_typespec` span and its `ref_typespec` NAME are
   byte-identical on both sides; and the `uvm_pkg` ref_typespec name is the
   campaign's own already-implemented `stampFoldedPkgParamTs` convention, not an
   odd one needing decoding. Every arm the brief asked for — literal twin,
   untyped twin, module twin, whole-line-span rule — was built (a1) and **the
   witness's own shape measured EQUAL in all of them** (§2.2: 31 of 36
   package-view cells SAME, and both witness cells among them). **Had I coded to
   the brief I would have changed `makeParamTs` / `stampFoldedPkgParamTs` — the
   two owners the brief itself fences — and moved objects that are already
   correct, to fix nothing.** What a1 DID buy is 34 newly-measured DIFF cells in
   neighbouring shapes (§6.8, §6.9), so the arm earns its place as evidence
   twice over: once as the refutation, once as a survey.
2. **"The head is where the head's parent chain says it is."** Refuted by
   `ref_obj::Compare`'s field order plus `SafeCompare(lhs, nullptr)`: the
   reported object is the one GOLDEN POINTS AT, and its parent chain is its
   DECLARATION's, not the referring site's. The referring site was two files and
   eleven lines away.
3. **"One branch is enough — bind whatever the maps hold."** Refuted by the v1
   build: both views bound the folded constant and golden wants one `operation`
   and one `constant`. The drain runs after every view, so the per-view maps are
   frozen; the view has to be recovered from `pf.inst` (§0.1).
4. **"Bind every unbound range ref in this emission."** Refuted by arm m12: the
   module-scope twin has NO golden counterpart at all. The gate is
   package-homed, and that is measured, not cautious.
5. **"`census67src.py` said 0 sites in UVM, so the law does not fire there."**
   Refuted by my own script's first version — an `` `include ``d body has no
   `package` line of its own. A predictor that cannot see the witness predicts
   zero and reads as green (§3).
6. **"cmp lines went 33 → 58, so the pass made it worse."** Refuted by the head
   OBJECT: cmp lines are HEAD DEPTH, not distance. The old head is gone from all
   three rows, the multiset distance to golden FELL on all 7 movers, and the new
   head is present on the pristine binary's own dump.

---

## 8. FILES

| file | what it is |
|---|---|
| `a1_pkgparamts.sv` | the arm the BRIEF asked for: 36 package-parameter cells (typed/untyped × literal/folded/macro/arith/concat/ternary, localparam, comma-list, two-line, indented, macro-whole-decl, trailing comment). §2.2 grids it. **The witness's OWN shape is EQUAL on both sides** — the refutation in §7.1 — and the arm additionally turned up 34 DIFF cells in NEIGHBOURING shapes, all pre-existing and all now residues §6.8/§6.9. |
| `a2_rangeref.sv` | the arm the CENSUS asked for: 12 range-bound cells. §2's grid. |
| `dumptree.py` | the uhdm-dump parser every instrument here shares (back-ref aware, `file:` normalising, two name spellings). |
| `census67.py` | span-keyed census of BOTH sides with container paths + multiset diff. §1.2. |
| `vecdiff67.py` | one container's one vector, element by element, both sides. |
| `ct67cells.py` | THE GRID: every range-bound ref, keyed with and without the fullname. §2. |
| `ct67design.cpp` | design-field comparator: which field, which element, with parent chains. §1.3, residues 2/4. |
| `census67src.py` | the census-predict, source-only, include-body aware. §3. |
| `ct67arm.sh` | arm driver (golden + ours + cmp + dump diff), `GOLDEN_ONLY=1` for the golden side alone. |
| `mv67.sh`, `msdist.sh` | per-shape movers by multiset, three-way counted. §4. |
| `rowheads.sh`, `ct8rows.sh`, `byteverify.sh`, `detcheck.sh`, `manifest.sh` | the gate instruments, carried forward unchanged. |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary instruments, carried forward unchanged. |
| `README.verifier.md` | THIS pass's, and it says plainly that no independent verifier ran. |
