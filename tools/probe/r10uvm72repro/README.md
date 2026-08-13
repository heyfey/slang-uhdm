# r10uvm72 — `§ inheritedNameBindsPkgFn72`: the 389-line head **CLEARED on all THREE target rows**, and SimpleUVM's whole `uvm_report_enabled` census now matches golden **CELL FOR CELL** — 1079/1/1/17 against 1079/1/1/17

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after, and no conversion
was expected. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines — whole ROW, dump column included — **0 differing ROWS** on
both, and both PRISTINE sweeps reproduce those same baselines.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**.
`SimpleUVM/default`, `SimpleUVM/testflags` and `Scoreboard/default` each sat at
**389** cmp lines on the head `LHS: function (uvm_pkg::uvm_report_enabled)`
against our `RHS: <null>`. All three now sit at **50** lines on a head in a
different family, a different file and a different object
(`logic_var (uvm_pkg::uvm_sequence_request::request)` @1771:34, from
`uvm_sequencer_base.svh`). The three new heads are **byte-identical to each
other** with ids normalised. `BuildUVMPkg` did **not** move: it reads **17** cmp lines on the same
`constant` head before and after (see the correction in §3).

**THIRD LINE, and it is the finding.** The brief asked *which calls does golden
bind and which do we*, and guessed the answer would be a slang bind refusal.
**It is not a refusal. Nothing was refused, and nothing had to be re-asked.**
uvm-1.2 declares `uvm_report_enabled` **THREE TIMES** — once as a package free
function (`uvm_globals.svh:133`, the head) and twice as a CLASS METHOD
(`uvm_report_object.svh:120`, `uvm_sequence_item.svh:343`). Inside a method of
any class that inherits one of those, the unqualified name is **SHADOWED**:
slang resolves it to the inherited METHOD, and Surelog binds the PACKAGE
FUNCTION. Our emitter already knew that rule — LAW C's fall-back has
implemented it for passes — but the fall-back sits ~200 lines BELOW an arm
(`§ classCallNoLink12`) that `return`s first for exactly the population that
needs it. **The law was present, correct, and unreachable.**

Base **1251d66**. Worktree `/tmp/wt_r10uvm72`; pristine control worktree
`/tmp/wt_r10uvm72pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `1251d66eeabbbaa05161a3443a280f5f0a37f1d6`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 1251d66) | `caf3519f3a3e8d830b72321859c281fb` | my own build of the base commit |
| **SHIPPED (patched)** | **`a7f32de3b28ea975a86828cbf276168f`** | every number below was measured on THIS binary |

BUILD DIRS (absolute): `/tmp/wt_r10uvm72/build`, `/tmp/wt_r10uvm72pris/build`,
both `-j 2`. `[100%] Linking CXX executable slang-uhdm` → `[100%] Built target
slang_uhdm` was read before any md5 was taken; every md5 was asserted in its own
command against `^[0-9a-f]{32}$`.

**ONE CONTROL-ANCHOR CAVEAT, STATED RATHER THAN HIDDEN.** The usual third
anchor — "the MAIN TREE's `build/slang-uhdm` at `HEAD == base` has the same
md5" — held when this pass started (main tree at `1251d66`, binary
`caf3519f3a3e8d830b72321859c281fb`, printed at 15:47) and then **stopped
holding**: another pass landed and the main tree moved to `38f308e` and rebuilt
at 15:57. The main tree is therefore **not** an anchor for this write-up and is
not cited as one. The two anchors that DO hold are cited instead, and they are
stronger: my pristine build reproduces the base-commit binary that the main tree
carried at pass start, and **both pristine sweeps reproduce the committed
baseline CSVs byte for byte** (0 differing ROWS on 731 and on 1588). For the
same reason every baseline CSV in this document is `git show 1251d66:results/…`
— **my base's** committed file, not the main tree's working copy, which is now
a different commit's. (`md5sum` says the worktree's `results/gate_uhdm2rtlil.csv`
and that blob are the same file: `b8e5e57796326d48006221f056b28d42`.)

`git stash` was never used. `results/*.csv` were only ever READ. slang was not
patched. `GOLDEN_DEFER` was left **UNSET** (echoed as `[UNSET]` at every sweep
launch). The four slang-fenced tests (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) were never dispatched — `canaudit.sh` proves it
mechanically (`FENCE-BREACH=0`).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

---

## 0. THE LAW

### § inheritedNameBindsPkgFn72

*An UNQUALIFIED call written inside a class method, whose name slang resolves to
a method **INHERITED from another class**, binds the **FREE SUBROUTINE OF THE
SAME NAME** in the enclosing package / module / wildcard-imported package —
never the inherited method. Only a call to the **caller's OWN class's** method
binds the method. Where no free twin is reachable, the call carries **no link at
all** — the inherited method is never the answer.*

*This is LAW C, which the emitter already implemented. This pass makes it
**REACHABLE** (the `§ classCallNoLink12` arm returns before it), **POSITION-
INDEPENDENT** (it stopped applying inside an `if` CONDITION), and **COMPLETE**
(it saw only DIRECT package members, not WILDCARD-IMPORTED ones).*

```
uvm-1.2 declares the name THREE times:
  base/uvm_globals.svh:133        function int uvm_report_enabled(...)   <- package FREE function
  base/uvm_report_object.svh:120  function int uvm_report_enabled(...)   <- class METHOD
  seq/uvm_sequence_item.svh:343   function int uvm_report_enabled(...)   <- class METHOD
```

Every `` `uvm_info/`uvm_warning/`uvm_error/`uvm_fatal `` expands to
`if (uvm_report_enabled(...))`, so uvm-1.2 leans on this coincidence ~1100
times in SimpleUVM alone.

### The three defects, and they are one law seen three ways

| # | what was wrong | population in SimpleUVM |
|---|---|---|
| **A** | `§ classCallNoLink12` `return`s BEFORE LAW C's fall-back, so a call whose callee is not yet in `subMap` never reaches it | **140** func_calls left `vpiFunction` NULL — **the head** |
| **B** | the in-body arm read `classMethodNoBind`, which StmtEmit turns OFF inside an `if`/`case` CONDITION — so the identical call bound the inherited METHOD in `if (f())` and took LAW C one line later | **14** func_calls bound to the WRONG function |
| **C** | the lookup saw only a scope's DIRECT members, so a class at `$unit` scope under `import uvm_pkg::*` found nothing | **5** of the 14 (SimpleUVM's own `class env`) |

### Where this sits

Pass 71 asked *does this object's container own a vector at all*. This one asks
*which of three same-named callees is the right one* — and the answer is
**never the inherited method**. The mis-diagnosis the brief carried ("slang may
REFUSE some of these binds… the fix is emitting the link from OUR side's own
resolution") is refuted in §1.4: instrumentation shows the fall-back's lookup
**succeeded on every one of the 123 calls that reached it** (`fb9=1 inMap=1`,
no exceptions). Nothing was refused. The calls that came out null **never
executed the lookup at all**.

### STATED GATE == CODE GATE — read off the source, not the comment

ONE predicate, ONE lookup helper, TWO call sites, all in `src/ExprEmit.cpp`:

```bash
grep -c "inheritedNameBindsPkgFn72" src/ExprEmit.cpp   # 5 — all of them comments
grep -c "inheritedCall72"           src/ExprEmit.cpp   # 4 — decl, assignment, and the TWO reads
grep -c "pkgFreeSubForName72"       src/ExprEmit.cpp   # 4 — definition, TWO calls, one comment
```

The code gate is **exactly this, and nothing else**:

```cpp
bool inheritedCall72 = false;
if (currentSubSym && curSubClassScope9 && !qualCall9)
    if (auto* callee9 = sub.getParentScope())
        if (auto* caller9 = currentSubSym->getParentScope())
            inheritedCall72 =
                callee9->asSymbol().kind == SymbolKind::ClassType &&
                caller9->asSymbol().kind == SymbolKind::ClassType &&
                (curSubOob9 || &callee9->asSymbol() != &caller9->asSymbol());
```

* **The gate is HOISTED, not rewritten.** It is the same expression that lived
  ~200 lines below, moved above the `subMap` lookup so the
  `§ classCallNoLink12` arm can read it. `qualCall9` moved with it, unchanged.
* **`classMethodNoBind` is GONE from it, and that is defect B.** That flag is a
  REF-binding rule; `StmtEmit.cpp:2408` sets it to `false` inside an `if`/`case`
  condition ("condition refs DO bind"). Reading it here made a CALL's binding
  depend on **where in the body the call sits** — the exact thing
  `TaskFuncEmit.cpp:5234` already says must not happen: *"unlike
  classMethodNoBind these are NOT toggled inside conditions — a call's binding
  does not depend on where in the body it sits."* The patch makes the code obey
  a law the code already stated.
* **SITE 2 binds a FUNCTION only.** That arm has already committed to a
  `func_call` (Surelog's single-pass default for an unseen name), so stamping a
  task into `vpiFunction` would be a bad cast. Arm a2's `tk` cell is the
  measured negative control: an inherited TASK name with a package TASK twin
  stays a bare `func_call`, before and after, byte for byte.
* **The lookup helper is the OLD walk, moved.** `pkgFreeSubForName72` is
  LAW C's inline walk lifted verbatim into a function so the two arms cannot
  drift, plus the wildcard-import half (defect C). The walk starts at the
  **CALLER**, never the callee — the whole point is that the name is inherited,
  so the callee's home is a base class that says nothing about which package
  the call was written in.

---

## 1. THE CENSUS, BOTH SIDES, SPAN-KEYED — RUN FIRST, BEFORE ANY CODE

### 1.1 The instrument, and the two ways it was wrong first

`ct72cen.py` merges an object's several full prints and reports
`CALL_DISAGREE`; `ct72sites.py` deliberately does NOT merge, because the
divergence here is BETWEEN the prints of one call site. Two corrections were
forced by the data before any number below could be trusted:

1. **A span is not a key without its FILE.** `114:10-114:67` exists in a dozen
   UVM files (the `` `uvm_info `` macro body's own line numbers travel with the
   expansion). Keying on span alone reported 85 golden objects against 95 of
   ours and **37 phantom `CALL_DISAGREE`s**. `uhdm-dump` prints `file:` only
   where it CHANGES, so the file is inherited down the print chain.
2. **A PRESENT link is not a CORRECT link.** The first census tested
   `vpiFunction` for presence and read defect B — 16 calls bound to the WRONG
   function — as **green**. The census records the TARGET's fullname as part of
   the status. Had it not, this pass would have shipped half a fix and called
   the arm clean.

### 1.2 The census that decoded the axis (SimpleUVM/default, every FULL print)

| bind target | golden | ours (pristine) | **ours (final)** |
|---|---|---|---|
| `uvm_pkg::uvm_report_enabled` (the package FREE function) | **1079** | 925 | **1079** ✓ |
| `uvm_pkg::uvm_report_object::uvm_report_enabled` (method) | **1** | 8 | **1** ✓ |
| `uvm_pkg::uvm_sequence_item::uvm_report_enabled` (method) | **1** | 8 | **1** ✓ |
| UNBOUND | **17** | 157 | **17** ✓ |
| total prints | 1098 | 1098 | 1098 |

**The population was IDENTICAL on both sides all along — 1098 prints, no
missing object, no surplus one.** Only the *target* differed. And golden's two
class-method binds are not an exception to the law, they are the law: both are a
call inside `uvm_report_object::uvm_report` / `uvm_sequence_item::uvm_report` —
**the class that DECLARES the method**.

The 17 UNBOUND are `method_func_call`s under a `hier_path`
(`top.uvm_report_enabled`, `uvm_top.…`, `c.…`) — receiver-qualified calls,
**17 on both sides before and after**. That is
`§ retNameRecvCollapse69`'s neighbourhood and this pass does not touch it.

### 1.3 The bound/unbound split, keyed on the VIEW (pristine)

| | golden | ours (pristine) |
|---|---|---|
| package-view prints (`package < function`), BOUND | 418 | **418** — identical |
| class-view prints (`package < class_defn < function`), BOUND | 663 | **523** |
| class-view prints, UNBOUND | 0 | **140** |

The same call site is emitted TWICE — once into the DEF package's `Task_funcs`
(the out-of-body clone) and once under the class's `class_defn`. **We bound the
package-view print and left the class-view print null**, which is why a
census keyed on anything coarser than the print would have reported "we bind
it" and moved on.

### 1.4 THE INSTRUMENTED RUN — what refuted the brief's premise

A temporary `fprintf` at the fall-back and at the bind decision (built, run,
then **removed**; `git diff` carries none of it):

```
R10UVM72      callee=uvm_report_enabled oob=1 cmnb=0 osc=uvm_pkg osckind=50 fb9=1 inMap=1  x123
R10UVM72FINAL calleeParent=uvm_pkg           inb9=0 ... x802
R10UVM72FINAL calleeParent=uvm_report_object inb9=0 ... x97
R10UVM72FINAL calleeParent=uvm_sequence_item inb9=0 ... x42
```

* **`fb9=1 inMap=1` on all 123.** Every call that REACHED the fall-back found
  its package function and bound it. There is no refusal, no missing symbol, no
  ordering problem — the brief's whole hypothesis space is empty.
* 802 + 123 = **925**, exactly the pristine census's correct binds; 139 − 123 =
  **16**, exactly its wrong ones. The instrument and the dump agree to the unit.
* A second run tagged every one of the **11** `MakeFunc_call()` sites in the
  tree. The result named the culprit with no ambiguity at all:

```
    140 R10UVM72MINT site=EE_fc0_1      <- § classCallNoLink12's arm
    941 R10UVM72MINT site=EE_main       <- the arm that carries LAW C
```

**140 of the 1081 func_calls are not minted by the arm that knows the law.**
That is the head, counted at its source.

---

## 2. THE GRID, CELL FOR CELL

Two arms, both UVM-free, both run against the CONTROL and the FINAL binary.
LHS is ALWAYS golden. `ct72cells.sh` prints golden's table, ours, and a `diff`,
so a matching cell shows up as an ABSENT diff line rather than an eyeballed
pair.

### 2.1 arm a1 — the SHADOW axis (`a1_shadow.sv`)

A package free function `fe`, a class `shbase` whose method shadows it, and
callers at every remove.

| cell | caller | golden binds | pristine | **final** |
|---|---|---|---|---|
| `shbase::base_inbody` | the DECLARING class | `p1::shbase::fe` | same | same = |
| **`shderived::d_inbody`** | inherited, in-body, in an `if` | **`p1::fe`** | **`p1::shbase::fe`** ✗ | **`p1::fe`** ✓ |
| **`shgrand::g_inbody`** | inherited TWO levels, in-body | **`p1::fe`** | **`p1::shbase::fe`** ✗ | **`p1::fe`** ✓ |
| `shderived::d_oob` (2 prints) | inherited, OUT-OF-BODY | `p1::fe` | `p1::fe` | `p1::fe` = |
| `shgrand::g_oob` (2 prints) | inherited, oob | `p1::fe` | `p1::fe` | `p1::fe` = |
| `clear::c_inbody`, `c_oob` (3 prints) | class with NOTHING inherited | `p1::fe` | `p1::fe` | `p1::fe` = |
| `pkg_caller` (2 prints) | a package free function | `p1::fe` | `p1::fe` | `p1::fe` = |
| module `initial`, wildcard-imported | module procedure | `p1::fe` | `p1::fe` | `p1::fe` = |
| **totals for the bare name `fe`** | **13 prints** | **12 `p1::fe` + 1 method** | **10 + 3** ✗ | **12 + 1** ✓ |

The two other names in the arm are counted separately, because a QUALIFIED call
is a DIFFERENT call object with a DIFFERENT `vpiName` — a table that folded them
into `fe` would be counting something the dump does not have:

| separately-named cell | prints | golden | pristine | **final** |
|---|---|---|---|---|
| `p1::fe` — the QUALIFIED spelling (`d_inbody_qual`, `d_oob_qual`, x2 views) | 4 | all `p1::fe` | all `p1::fe` | all `p1::fe` = |
| `other_free` — an unshadowed free-function name (`d_inbody_other`) | 1 | `p1::other_free` | same | same = |

`diff` of the FINAL per-cell table against GOLDEN's: **empty — all 13 `fe`
prints, every target identical to golden**, and the 4 + 1 prints of the other
two names are unchanged in all three builds. The pristine table differs on exactly the two
in-body inherited cells. The arm `PASS_CMP`es on both binaries (its divergence
is a typespec-ordering residue the dump sees and cmp does not), so **the arm's
evidence is the target table, not the cmp** — stated plainly rather than
dressed up as a cleared head.

### 2.2 arm a2 — the SITE axis and the NEGATIVE CONTROLS (`a2_site.sv`)

| cell | what it pins | golden | pristine | **final** |
|---|---|---|---|---|
| **`inpkg::c_shadowed`** | inherited, class in the package — **defect A** | `p2::fe` | **UNBOUND** ✗ | **`p2::fe`** ✓ |
| **`unitcls::u_shadowed`** | class at **`$unit`** under `import p2::*` — **defect C** | `p2::fe` | **`p2::shbase::fe`** ✗ | **`p2::fe`** ✓ |
| **`unitcls::u_lonely`** | inherited name with **NO** package twin | **UNBOUND** | **`p2::shbase::lonely`** ✗ | **UNBOUND** ✓ |
| `inpkg::c_lonely` | same, inside the package | UNBOUND | UNBOUND | UNBOUND = |
| `shbase::base_calls_own` / `inpkg::c_own_inherited` | `own()` — the OWN-CLASS control | 2 prints, unchanged | = | **CELLS IDENTICAL TO GOLDEN** = |
| `inpkg::c_taskname` | inherited TASK + package TASK twin | 0 prints | 1 bare `func_call`, no link | **unchanged** = |
| `inpkg::c_qual` | QUALIFIED call | `p2::fe` | `p2::fe` | `p2::fe` = |
| `modcls::m_shadowed` | class in a MODULE, module-level free fn | `work@top.mfe` | `work@top::modbase::mfe` ✗ | **UNBOUND** ~ |

a2's cmp head depth fell **117 → 56**. Two cells deserve their own sentences:

* **`u_lonely` is the cell that proves the law is not "bind something".** An
  inherited name with no free twin must carry **NO link**; pristine bound the
  inherited method, golden binds nothing, and the final matches golden. The
  same cell is the reason defect B's fix cannot be "keep binding the method".
* **`m_shadowed` is a PARTIAL, and it is reported as one.** Golden binds the
  MODULE's free function; pristine bound the class method (wrong object); the
  final leaves it **null**. Both are divergences and the cell is not fixed —
  it went from a wrong object to no object. The cause is measured: the walk
  finds `work@top.mfe` correctly, but the module function is **not yet in
  `subMap`** when a class body inside that module is emitted, so nothing can be
  bound to. **No UVM row contains this shape** (uvm-1.2's classes and their free
  functions are all package-scope), which is why it is ranked as residue 1 and
  not fixed here. It is also why the corpus gates matter more than the arm:
  §4.5 shows the whole 1632-database corpus moved **7 databases and no others**.

---

## 3. THE HEAD, before and after

`rowheads.sh` on the pristine and the final workdir. LHS is ALWAYS golden.

| row | CONTROL cmp lines | head object (CONTROL) | FINAL cmp lines | head object (FINAL) |
|---|---|---|---|---|
| **SimpleUVM/default** | **389** | `function (uvm_pkg::uvm_report_enabled)` vs `RHS:<null>` | **50** | `logic_var (uvm_pkg::uvm_sequence_request::request)` @1771:34 |
| **SimpleUVM/testflags** | **389** | *same* | **50** | *same* |
| **Scoreboard/default** | **389** | *same* | **50** | *same* |
| BuildUVMPkg/default | 17 | `constant` @38677:23-38677:28 | 17 | **same head OBJECT, unchanged** |
| BuildUVMPkg/testflags | 17 | *same* | 17 | *same* |
| SeqDriver/default | 1414833 | `LHS:<null>` vs our `package uvm_pkg @28:1` | 1416169 | **same head OBJECT** |
| SeqDriver/testflags | 1414833 | *same* | 1416169 | *same* |
| Scoreboard/testflags | — | `SLANG_REJECT`, no database | — | *same* |

* **All three target rows CLEARED**, and the new head is byte-identical across
  the three (first 14 lines, ids normalised, `cmp` equal pairwise).
* **A CORRECTION I OWE THIS TABLE.** I first wrote "BuildUVMPkg 58 → 17,
  cleared". That **58 is pass 71's number, not mine**: carried across from
  `r10uvm71repro/README.md` instead of measured on my own control. Measured on
  the PRISTINE 1251d66 workdir I built, BuildUVMPkg's control is **17 lines on
  the same `constant` @38677:23 head**, in both modes — so this pass moves its
  head **not at all**. A number quoted from another pass's base is not a
  measurement, and the whole claim was wrong. Every other figure in this table
  was read off my own two workdirs.
* **SeqDriver did NOT regress.** Its head is the same pre-existing
  `package uvm_pkg` object (pass 2's `§ instanceIsNeverAClassDefn2` head, still
  open) — verified by `cmp` on the head lines with ids normalised. **`+1336`
  lines is that ONE head's decompile growing, not distance**: a head is not a
  distance, and this pass ADDS `vpiFunction` links, so the decompile of the
  object that contains them gets longer. Its own row status and dump column are
  byte-identical to the baseline (§4.4).

---

## 4. THE FIVE GATES

### GATE 1 — BUILD

`cmake --build build -j 2` → `[100%] Linking CXX executable slang-uhdm` /
`[100%] Built target slang_uhdm`, read before any md5 was taken. Then, in a
SEPARATE command:

```
PRISTINE=caf3519f3a3e8d830b72321859c281fb
FINAL=a7f32de3b28ea975a86828cbf276168f
OK: BINARY md5 CHANGED caf3519f3a3e8d830b72321859c281fb -> a7f32de3b28ea975a86828cbf276168f
32-hex OK
```

The pristine/main-tree anchor is discussed in the header caveat: it held at pass
start and the main tree then moved off this pass's base commit. The corpus
anchors below are the ones cited.

### GATE 2 — GOLDENS

`tests/check_goldens.sh` on the FINAL binary: **23 PASS / 0 FAIL**.
NEGATIVE CONTROL `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the control
fires.

### GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`

**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump column
**496 match / 183 differ / 52 blank**. WHOLE-ROW judge (`ct8rows.sh`) against
`git show 1251d66:results/gate_uhdm2rtlil.csv`:

```
baseline: 732 lines = 731 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

The PRISTINE sweep is **also** 0 differing ROWS — the control is anchored on the
corpus, not just on the binary.

### GATE 4 — surelog, `--mode both`, `--jobs 2`

`default` **469 CMP_EQUAL / 11 CMP_NOTEQUAL** / 5 DEFERRED / 284 SLANG_REJECT /
25 SURELOG_FAIL; `testflags` **465 CMP_EQUAL / 8 CMP_NOTEQUAL** / 5 DEFERRED /
286 SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE /
1 TIMEOUT / 1 NO_UHDM. Dump column 225 match / 244 differ (default), 165 match /
300 differ (testflags). Every figure equals the expected one and **both
histograms are unchanged**. WHOLE-ROW judge:

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` was left UNSET: the 5 memory-giant tests read `DEFERRED` in both
modes, exactly as the baseline does.

### GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs the PRISTINE 1251d66 workdirs I built

`SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched-wd> <pristine-wd>`:

```
surelog / both modes:
  databases: patched=953 pristine=953
  PATH_SETS_IDENTICAL (953 paths)
  MOVERS: 7 / 953
  SELFCHECK: 952 / 953 flagged        SELFCHECK1: 8

uhdm2rtlil / testflags:
  databases: patched=679 pristine=679
  PATH_SETS_IDENTICAL (679 paths)
  MOVERS: 0 / 679
  SELFCHECK: 678 / 679 flagged        SELFCHECK1: 1
```

Both negative controls fire on both corpora (`SELFCHECK1`'s 8 = the 7 real
movers plus the one corrupted file).

### 4.5 MOVERS, PREDICTED FIRST

`ct72predict.py` reads the PRISTINE workdirs alone and names every database
that CAN move: one that holds a func_call bound to a class method whose leaf
name is also a free subroutine (it will re-target), or an unbound one inside a
class whose name is (it will bind).

* **surelog PREDICTION: exactly 7 movers / 953, `DUMP_FAIL=0`**, named —
  `default/{SimpleUVM, Scoreboard, SeqDriver, BuildUVMPkg}` and
  `testflags/{SimpleUVM, SeqDriver, BuildUVMPkg}`. `Scoreboard/testflags` is
  `SLANG_REJECT` and has no database. **The sweep produced exactly those seven
  and nothing else** — same names, same modes.
* **uhdm2rtlil PREDICTION: 0 movers / 679, `DUMP_FAIL=0`.** **The sweep
  produced exactly 0.** Not one uhdm2rtlil design shadows a free subroutine's
  name with an inherited method.
* Both predictions were computed from the PRISTINE workdirs and written to
  `/tmp/r10uvm72_predict_{sl,u2r}.txt` before `byteverify.sh` was run on the
  corresponding patched workdir.

**NOT ONE `CMP_EQUAL` DATABASE MOVED A BYTE, IN EITHER CORPUS.** The only 7 that
changed are the 4 UVM tests (x modes), all `CMP_NOTEQUAL` before and after.
There is therefore no room for a silent regression inside the 183 + 244 + 300
rows whose dump column reads `differ`.

### 4.6 MOVERS PER-SHAPE, BY MULTISET — and the accounting CLOSES

`mv72.sh` sorts whitespace-stripped dump lines and diffs the MULTISETS, because
a positional `diff` reports re-indentation as change. (Its output files are
written with a leading `.` — `tag=$(echo ./default/... | tr / _)` keeps the
leading dot — so they need `ls -a`. Noted because I briefly read an empty `ls`
as "the analysis produced nothing".)

| mover | `\|vpiFunction:` ADDED | REMOVED | target lines ADDED | REMOVED | ANY OTHER SHAPE | size delta |
|---|---|---|---|---|---|---|
| `default/SimpleUVM` | 336 | **0** | 360 | 24 | **0** | +648 |
| `default/Scoreboard` | 332 | **0** | 352 | 20 | **0** | +644 |
| `default/SeqDriver` | 334 | **0** | 355 | 21 | **0** | +652 |
| `default/BuildUVMPkg` | 281 | **0** | 296 | 15 | **0** | +547 |
| `testflags/SimpleUVM` | 336 | **0** | 360 | 24 | **0** | +648 |
| `testflags/SeqDriver` | 334 | **0** | 355 | 21 | **0** | +652 |
| `testflags/BuildUVMPkg` | 281 | **0** | 296 | 15 | **0** | +547 |

Three facts, each measured rather than asserted:

1. **Only TWO line shapes appear in any of the seven diffs** — the
   `|vpiFunction:` label and the `\_function:` object it points at. The
   `OTHER` column is **0** on every row. This patch adds links; it moves
   nothing else.
2. **`|vpiFunction:` REMOVED is 0 on all seven — NO BIND WAS EVER LOST.** Every
   change is a NEW link or a link RE-POINTED.
3. **The arithmetic closes on every row**: added target lines = new labels +
   removed targets. `360 = 336 + 24`, `352 = 332 + 20`, `355 = 334 + 21`,
   `296 = 281 + 15`. And for SimpleUVM the head's own target,
   `uvm_report_enabled @133:1-140:12`, is added **154** times = **140**
   (defect A) + **14** (defect B), the two populations §1.2 counted
   independently.

**EVERY ONE OF THE 24 REMOVED TARGETS IS A CLASS METHOD.** Pooled over all
seven movers, the removed set is five methods and nothing else:

```
  45  uvm_pkg::uvm_reg::get_full_name                 (+18 at the 1800.2 spans)
  37  uvm_pkg::uvm_sequence_item::uvm_report_enabled  (+6  at the 1800.2 spans)
  23  uvm_pkg::uvm_report_object::uvm_report_enabled
   7  uvm_pkg::uvm_object::get_name
   4  uvm_pkg::uvm_policy::get_active_object_depth
```

Not one free function lost a link. And the two non-`uvm_report_enabled` names
are the law GENERALISING, checked against golden:

| name | golden | pristine | **final** |
|---|---|---|---|
| `get_name` bound to `uvm_object::get_name` | **0** | 1 | **0** ✓ |
| `get_full_name` bound to `uvm_reg::get_full_name` (INHERITED) | **0** | 9 | **0** ✓ |
| `get_full_name` bound to `uvm_port_base::get_full_name` (OWN class) | **4** | 4 | **4** = |

The own-class control holds in the wild, not just in the arm.

### 4.7 THE DESIGN-WIDE BIND CENSUS — every name, not just the head's

`vpiFunction` links in SimpleUVM/default, counted by TARGET FULLNAME:

| | golden | pristine | **final** |
|---|---|---|---|
| total `vpiFunction` links | **2931** | 2583 | **2919** |
| links to a CLASS METHOD | **254** | 269 | **245** |
| distinct targets | 181 | 174 | 172 |

Target rows where golden and the final build disagree: **13, totalling 16
links** — and **12 of the 13 are byte-identical to the PRISTINE disagreement**,
i.e. pre-existing and untouched by this pass (10 class methods golden binds once
or twice and we have never bound, `uvm_root::get` 6-vs-4, and a 2-link surplus
on `uvm_sequence_library::add_typewide_sequence`). **Exactly ONE row moved and
did not land exactly**: `uvm_report_fatal`, **185 → 223 against golden's 224** —
one link short. That single link is residue 2 below.

---

## 5. RESIDUES, RANKED

1. **`m_shadowed`: a MODULE-level free function is found but not yet in
   `subMap`** (arm a2, §2.2). Golden binds `work@top.mfe`; we now bind nothing
   where we used to bind the wrong object. The lookup is right and the timing is
   wrong — the module's own functions are emitted after a class body inside that
   module. **No corpus row exhibits it**; the fix is an ordering or shell-bind
   question, not a lookup one.
2. **`uvm_report_fatal` is ONE link short of golden** (§4.7): 185 → **223**
   against golden's **224**, the only target row this pass moved without
   landing exactly. One site, in one design, already isolated by the
   design-wide census — the cheapest open cell in this family.
3. **The 17 receiver-qualified `method_func_call`s** (`top.uvm_report_enabled`,
   `uvm_top.…`, `c.…`) are unbound on BOTH sides — but their **endln spans
   differ**: golden ends the call at `211:14-211:32`, we run it to `211:14-551:3`.
   17 sites, `§ retNameRecvCollapse69`'s family, pre-existing and untouched.
   Also here: the **12 pre-existing target rows** of §4.7 (10 class methods
   golden binds and we never have, `uvm_root::get` 6-vs-4, and a 2-link surplus
   on `uvm_sequence_library::add_typewide_sequence`) — named, measured, and NOT
   caused by this pass.
4. **arm a2's `tk` cell**: golden emits NO `func_call` for an inherited task
   call with a package task twin; we emit a bare unlinked one. A shape
   divergence, not a binding one, and deliberately left alone (§0's FUNCTION-
   only rule).
5. **arm a1's / a2's remaining dump residues** are `int_typespec` and
   `class_typespec` ORDERING (24 and ~100 lines): the same objects in a
   different sequence, cmp-invisible.
6. **The new head on all three target rows** — `logic_var
   (uvm_pkg::uvm_sequence_request::request)` @`uvm_sequencer_base.svh:1771`,
   50 cmp lines. A different family entirely and the natural next target.

---

## 6. THE CANARIES

| guard | result |
|---|---|
| `canaries.sh` surelog | **ok=52 changed=0 absent=0**, unknown-names=7 (the u2r-only names, the documented number) |
| `canaries.sh` uhdm2rtlil | **ok=8 changed=0 absent=0**, unknown-names=25 (the surelog-only names) |
| `ctcan2.sh` surelog, `EXPECT_UNKNOWN=1` | **ok=58 changed=0 absent=0**, unknown-patterns=**1** — PASS |
| `ctcan2.sh` uhdm2rtlil, `EXPECT_UNKNOWN=6` | **ok=1 changed=0 absent=0**, unknown-patterns=**6** — PASS |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0** — PASS |
| `InterfaceModPort` BY NAME | `default` + `testflags` both `CMP_EQUAL/differ`, **byte-identical to baseline** |
| `BlackParrotComplex` BY NAME | `default` + `testflags` both `CMP_EQUAL/differ`, **byte-identical to baseline** |

**BOUNDARIES.** The pass touches ONE file, `src/ExprEmit.cpp`, in four hunks
inside one function plus one file-local helper.

* `§ invalidNewCallFromSyntax55` owns **new()-call bind refusals**. Read first,
  as the brief required — and its mechanics are **NOT** the ones here. §1.4's
  instrumentation shows nothing was refused: every lookup that ran succeeded.
  §55's three tagged sites are untouched and its `newcen.sh` shape (an
  `assignment` whose `vpiRhs` is `method_func_call(new)`) is not read or written
  by this patch.
* `§ retNameRecvCollapse69` owns **return-name receiver collapse**, and the
  brief asked how IT binds. It binds through `subMap.find(&fsub69)` on the
  ENCLOSING function's own symbol — a different lookup, a different key, and
  a different arm; this patch adds no code to it and its 17-print population is
  identical before and after (§1.2).
* `§ ctorBodyLocalsNotOnFunc71`'s a1–a4 arms are in `TaskFuncEmit.cpp` and hold:
  this pass writes no `Variables()` vector and the file is not edited.
* `§ classMethodRetNameNoBind56` concerns the RETURN name; untouched.
* Live passes `r10buvm2` (class-property init) and `r10earl43` (override Rhs
  fold, ParamEmit). `r10earl43` is `ParamEmit.cpp` — **no overlap**. `r10buvm2`
  may share `ExprEmit.cpp`; my hunks are confined to the tf-call arm of
  `emitExpr` and to one new file-local static, so a textual collision is
  unlikely but **possible and hereby reported** rather than assumed away.

**LANDING HYGIENE.** No `README.verifier.md` is carried forward — that file is
the VERIFIER's to author, and this directory deliberately contains none, so no
stale one can be mistaken for this pass's. Every script here was RUN in this
pass; the temporary `fprintf` instrumentation of §1.4 was built, run, and
**reverted** (`git checkout --`) before the shipped binary was built, and the
delivered diff contains none of it.

---

## 7. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm72repro
# the grid, either binary
SLANG_UHDM=<bin> ./ct72arm.sh a1_shadow.sv /tmp/x_a1
SLANG_UHDM=<bin> ./ct72arm.sh a2_site.sv   /tmp/x_a2
./ct72cells.sh /tmp/x_a1 fe other_free            # per-cell target table vs golden
./ct72cells.sh /tmp/x_a2 fe tk own lonely mfe

# the census that decoded the axis (ONE SIDE per run; the TARGET is the status)
python3 ct72sites.py <dump> uvm_report_enabled --chain --only all
python3 ct72cen.py   <dump> --callee uvm_report_enabled --kinds func_call,method_func_call

# the mover PREDICTION, from a PRISTINE workdir, before the patched sweep
python3 ct72predict.py <pristine verify_golden workdir>

# the head on the target rows
./rowheads.sh <verify_golden workdir> <outdir> SimpleUVM Scoreboard SeqDriver BuildUVMPkg
```
