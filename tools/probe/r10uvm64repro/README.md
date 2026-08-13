# r10uvm64 — § blkLocalSameCtrlDepthWindowBinds64, the briefed 31-line head **CLEARED on all THREE target rows** — 7 movers, all 7 inside the 22 rows a pre-patch census predicted, **408 new bindings and every single one of them correct on a whole-design per-cell audit** — and **MY BRIEF'S HEAD DESCRIPTION WAS FACTUALLY WRONG**: we never dropped the variable

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after. No conversion was
expected and none happened. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are byte-identical to the committed
baselines in **both** my sweeps, pristine and patched.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**
(`SimpleUVM/default`, `SimpleUVM/testflags`, `Scoreboard/default`). All three go
from **31 cmp lines to 13** and now head on the same different, deeper object —
an empty `begin (uvm_pkg::uvm_recorder::do_open) @547:18-547:25` that was masked
behind this one, and which is another law.

**THIRD LINE, and it is the one that had to be established before a line of code
was written.** The brief states the head as *"golden `integer_var
(uvm_pkg::uvm_recorder::get_handle::handle) @343:18-343:24` — RHS `<null>`: we
emit NO object for this local"*, and instructs: *"here the whole `integer_var`
IS absent from our dump, verify that first"*, and *"READ THE EMITTER STDERR
unsupported summary FIRST — a dropped local var is likely a noted bail."*

**All three of those are false, and the census that proves it took four minutes.**
We emit that `integer_var`. Our dump carries it at the *same* dump position,
under the *same* `begin`'s `vpiVariables`, with the *same* `vpiParent:
assignment`, the *same* `ref_typespec`, the *same* `vpiSigned:1` — the region is
**byte-identical on both sides** (golden `/tmp/r64_g.dump` 814576..814609 versus
ours 808269..808302). The emitter's `unsupported constructs` summary for this
file has exactly **two** entries, `expression kind: UnboundedLiteral` and
`system method call: size`; no bail is involved anywhere near line 343.

The real head is **ONE MISSING `vpiActual` EDGE**, three lines later:

```
golden  \_ref_obj: (uvm_pkg::uvm_recorder::get_handle::handle), line:346:75, endln:346:81
          |vpiParent: \_operation: , line:346:48, endln:346:81
          |vpiName:handle
          |vpiFullName:uvm_pkg::uvm_recorder::get_handle::handle
          |vpiActual:                                              <-- ONLY THIS
          \_integer_var: (…::get_handle::handle), line:343:18, endln:343:24
ours    (the same ref_obj, the same span, the same two names, and no vpiActual)
```

`uhdm-cmp` reports the head as the `integer_var` because the `integer_var` is
what sits in the **slot** golden fills and we leave null — the failing slot is
`ref_obj.vpiActual`, not a variable listing. **`RHS: <null>` names the SLOT, not
a missing object, and this pass is the cleanest example of that trap the campaign
has produced: the brief's entire measurement list (a)–(h) was written about
emitting a variable we already emit, and following it would have produced a
patch minting a duplicate object.** Items (a)–(h) are answered anyway, in §1.4,
because a brief item is measured rather than waved away — and two of them turn
out to carry no term at all.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `ct64arm.sh` and `rowheads.sh` print that they did on every run.

Base **957974d**. Worktree `/tmp/wt_r10uvm64`; pristine control worktree
`/tmp/wt_r10uvm64pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `957974dabc7aacfb75ce00295ef363f70b189be0`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 957974d) | `8a7c07f418d3a567de0b24c6a5e90fe3` | my own build of the base commit |
| **FINAL (shipped)** | **`494f6babd956ea73f323c1da7b3eda31`** | every gate number below was measured on THIS binary |

BUILD DIR (absolute): `/tmp/wt_r10uvm64/build`. The link line
(`[100%] Linking CXX executable slang-uhdm`) was waited for and read before any
md5 was taken; both md5s were asserted in their own command and both are 32 hex
digits. `git stash` was never used. The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched — `canaudit.sh` proves it mechanically (FENCE-BREACH=0).
`GOLDEN_DEFER` left **UNSET** (echoed as `[UNSET]` at both surelog sweep
launches; **5 DEFERRED** in both modes, as in the baseline). slang was not
patched. `results/*.csv` were only ever read.

---

## 0. THE LAW

### § blkLocalSameCtrlDepthWindowBinds64

*§ blockLocalSameCtrlDepthArgBinds57's carve-out from § controlBodyNoBind28 is
**not ARGUMENT-LIST-shaped; it is WINDOW-shaped**. An in-body class method has
**two** binding windows — the § classArgBind12 argument list **and the if/case
CONDITION**, the one place `StmtEmit.cpp` clears `classMethodNoBind` — and
golden lifts §28 for a same-`ctrlBodyDepth28` **unnamed-block local** in **both**
of them. Nothing else about the declaration conditions it: not the variable's
KIND, not whether it has an INITIALISER, not what shape that initialiser is, and
not whether the block is an `if`-begin, an `else`-begin or a bare `begin`.*

* **DIRECTION: ADD ONLY.** The patch mints no object, deletes none, re-parents
  none, moves no span. The only dump-line shapes it can produce are a
  `|vpiActual:` field and the header line of the object it points at —
  **measured**, not asserted: across all 7 mover databases `mv64.sh` reports
  `REMOVED line instances=0`, and the ADDED shapes are exactly `|vpiActual:`
  plus `class_var` / `enum_var` / `bit_var` / `int_var` / `string_var` /
  `ref_var` / `integer_var` headers (§4).
* **§57 was not wrong, it was under-measured.** Its arms b1..b4 contain no
  condition-position cell, so its gate wrote in the only window it had evidence
  for. This pass adds the missing arm and widens the gate to what the evidence
  now says. §57's own cell list is unchanged and still holds.
* `grep -rn 'blkLocalWindowBind64\|blkLocalSameCtrlDepth57' src/ include/` →
  the predicate is still declared once, defined once and called from **one**
  site; the change is to that site's gate, not to the predicate.

### STATED GATE == CODE GATE — read off the source, not the comment

| | |
|---|---|
| **the whole change** | `classArgBindDepth12 > 0` → `(classArgBindDepth12 > 0 \|\| !classMethodNoBind)` |
| **the whole gate** | `bool blkLocalWindowBind64 = (classArgBindDepth12 > 0 \|\| !classMethodNoBind) && blkLocalSameCtrlDepth57(nv.symbol);` then, unchanged, `bool ctrlBodyNoBind28 = curSubClassScope9 && !curSubOob9 && ctrlBodyDepth28 > 0 && !blkLocalWindowBind64;` |
| **not in the gate** | no var-KIND test · no initialiser test · no block-shape test · no name test · no file/scope-name test · no new state, no new counter, no new member |
| the predicate (untouched) | `blkLocalSameCtrlDepth57`: `SymbolKind::Variable`, declaring scope is an **unnamed** `StatementBlock`, that block is **open** and was entered at exactly the current `ctrlBodyDepth28` |

**Why `!classMethodNoBind` IS the condition window, mechanically and not by
analogy.** `ctrlBodyNoBind28`'s own first two terms are
`curSubClassScope9 && !curSubOob9`, and `TaskFuncEmit.cpp:5087` sets
`classMethodNoBind = classScope && !oob` for exactly that subroutine. So inside
this branch `classMethodNoBind` is **true by construction** — unless something
cleared it. `grep -rn 'classMethodNoBind = false' src/` returns **three** sites
and only three: `StmtEmit.cpp:2305` (`if_else` condition), `2325` (`if_stmt`
condition) and `2599` (`case_stmt` condition), each carrying the comment
`// condition refs DO bind`. `!classMethodNoBind` here therefore *means* "this
reference is in an if/case condition", with no new state to keep in sync.

**And the discriminator that makes this a measurement rather than a guess:** a
`while` condition is **not** a window. `StmtEmit.cpp`'s while/do-while/repeat
arms emit their condition without touching `classMethodNoBind`, so the gate
leaves them silent — and arm cell **c13 (`while (c20_blkloc == 11)`, depth 1) is
golden BARE**. A gate written as "any condition" would have over-fired on it.

---

## 1. WHAT WAS MEASURED BEFORE ANY CODE WAS WRITTEN

### 1.1 The head, on my own pristine build, and the census that reclassified it

```
rowheads.sh /tmp/r64_ctl_wd …   SimpleUVM Scoreboard
  SimpleUVM   default     31 cmp lines  1 head
  SimpleUVM   testflags   31 cmp lines  1 head
  Scoreboard  default     31 cmp lines  1 head
  Scoreboard  testflags   SKIP-NOFILE (SLANG_REJECT, no database — reported, not hidden)
```

**CENSUS OF BOTH SIDES, span-keyed, BEFORE any missing-object claim.** The
`integer_var (…::get_handle::handle) @343:18-343:24` is present in **both**
dumps, in the same place, with the same fields:

| | golden `/tmp/r64_g.dump` | ours `/tmp/r64_o.dump` |
|---|---|---|
| listed under `begin @342:12-353:10` `vpiVariables` | line 814581 | line 808274 |
| `vpiParent` | `assignment @343:18-343:40` | `assignment @343:18-343:40` |
| `vpiTypespec` → `ref_typespec` → `vpiActual` | `integer_typespec @343:10-343:17` | identical |
| `vpiName` / `vpiFullName` / `vpiSigned` | `handle` / `uvm_pkg::…::handle` / `1` | identical |
| the `assignment` at `vpiStmt`, its `vpiRhs func_call (get_inst_id)`, its `vpiLhs` | present | identical |

The emitter's own note list for this compile, read first as the rules require:

```
slang-uhdm: unsupported constructs encountered:
  expression kind: UnboundedLiteral
  system method call: size
```

Neither is at line 343 and neither is a variable. **No bail. Nothing dropped.**

### 1.2 THE CORPUS WITNESS'S FOUR USE SITES — the discriminator, read off golden

`uvm-1.2/src/base/uvm_recorder.svh` 338..354. `handle` is read four times and
golden binds it **once**:

| source | span | position | golden | ours (pristine) |
|---|---|---|---|---|
| `… m_ids_by_recorder[this] != handle)` | 346:75 | **if CONDITION**, depth 1 | **BIND** | bare ← THE HEAD |
| `m_recorders_by_id[handle] = this;` | 349:28 | bit-select index on an assignment **LHS** | bare | bare |
| `m_ids_by_recorder[this] = handle;` | 350:36 | assignment **RHS** | bare | bare |
| `return handle;` | 352:17 | **return** operand | bare | bare |

One golden `BIND` among four uses of one variable inside one block is the whole
law in one function. Any hypothesis of the form "block-locals bind" or "we drop
the variable" is refuted by the other three rows before an arm is written.

### 1.3 THE FIELD-POLICY GRID, cell for cell

`ct64cells.py <g.dump> <o.dump>` finds every `ref_obj`, keeps each one at its
**fullest occurrence**, reads **own-child-indent** fields only, and reports
whether `vpiActual` is present on each side. Traps encoded, each paid for
earlier: an object is not a dump occurrence (a bound ref prints again as a bare
back-reference under every other parent); own fields only (the same text two
indents deeper belongs to a grandchild); a span present on one side only is
`-NOOBJ-`/`UNMEASURED` and never counts as agreement.

**GOLDEN's policy on arm `b1_cond.sv`** (`d` = `ctrlBodyDepth28`; every cell is
an in-body method of class `b1c`):

| cell | source | position | depth | GOLDEN | ours pristine | ours patched |
|---|---|---|---|---|---|---|
| c01 40:11 | `if (c01_blkloc == 3)` | if CONDITION | 1==1 | **BIND** | bare | **BIND** |
| c12 64:13 | `case (c20_blkloc)` | CASE condition | 1==1 | **BIND** | bare | **BIND** |
| c14 61:13 | cond inside a nested **plain** `begin` | if CONDITION | 1==1 | **BIND** | bare | **BIND** |
| c30 102:11 | `if (c30_blkloc + 1 == 3)` | cond, under an OPERATION | 1==1 | **BIND** | bare | **BIND** |
| c31 103:16 | `if (sink(c30_blkloc))` | cond, inside a CALL ARG | 1==1 | **BIND** | bare | **BIND** |
| c36 108:11 | `if (c30_blkloc inside {1,2})` | cond, `inside` operand | 1==1 | **BIND** | bare | **BIND** |
| c32 104:13 | `sink2(c30_blkloc);` | STATEMENT-position call arg | 1==1 | BIND | BIND | BIND |
| **c13 63:14** | **`while (c20_blkloc == 11)`** | **WHILE condition** | 1==1 | **bare** | bare | bare |
| c02 41:11 | `r = c01_blkloc;` | assignment RHS | 1 | bare | bare | bare |
| c03 42:9 | `q[c01_blkloc] = 4;` | LHS bit-select index | 1 | bare | bare | bare |
| c04 46:14 | `return c01_blkloc;` | return operand | 1 | bare | bare | bare |
| c33 105:16 | `r = sink(c30_blkloc);` | EXPRESSION-position call arg | 1 | bare | bare | bare |
| c34 106:23 | `$display("%0d", c30_blkloc);` | SYSTEM call arg | 1 | bare | bare | bare |
| c35 107:14 | `q[1] = c30_blkloc;` | RHS of an indexed assignment | 1 | bare | bare | bare |
| c05 43:11 | `if (bodyloc == 5)` | cond, METHOD-BODY local | 1 | bare | bare | bare |
| c09 44:11 | `if (prop == 6)` | cond, class PROPERTY | 1 | bare | bare | bare |
| c10 45:11 | `if (farg == 7)` | cond, FORMAL | 1 | bare | bare | bare |
| c07 58:13 | same local read one `if` deeper | cond | 1 vs 2 | bare | bare | bare |
| c15 69:13 | same local read inside a `for` body | cond | 1 vs 2 | bare | bare | bare |
| c16 90:11 | local of a **NAMED** block at d1 | cond | 1==1 | bare | bare | bare |
| c06 79:9 | body local, **depth 0** | cond | 0 | BIND | BIND | BIND |
| c11 86:11 | unnamed-block local, **depth 0** | cond | 0 | BIND | BIND | BIND |
| **c08 82:11** | **NAMED-block local, depth 0** | cond | 0 | **bare** | **BIND** | **BIND** ← residue R1 |

**Arm `b3_kinds.sv` — the two axes that carry NO term at all.** Every cell is a
same-depth unnamed-block local read in an if CONDITION at depth 1.

| axis | cells | GOLDEN | ours pristine | ours patched |
|---|---|---|---|---|
| KIND: `int` `integer` `logic` `bit` `byte` `string` `real` class handle `logic[7:0]` | d01..d09 | **BIND (9/9)** | bare (9/9) | **BIND (9/9)** |
| INITIALISER: none / literal / **CALL** / operation | e01..e04 | **BIND (4/4)** | bare (4/4) | **BIND (4/4)** |
| BLOCK SHAPE: `if`-begin / `else`-begin | g01 g02 | **BIND (2/2)** | bare (2/2) | **BIND (2/2)** |
| BLOCK SHAPE: bare `begin` at depth 0 | g03 | BIND | BIND | BIND |
| BLOCK SHAPE: **named** begin at depth 1 | g04 | bare | bare | bare |

**Arm `b2_modtwin.sv` — the NEGATIVE CONTROL, and it did not move.**

| scope | cells | pristine | patched |
|---|---|---|---|
| MODULE function `b2_top.m1` | 5 | 5 same, 0 DIFFER | **unchanged** |
| PACKAGE function `b2p::p1` | 3 | 3 same, 0 DIFFER | **unchanged** |
| `$UNIT` function `u1` (§ unitSubNoBind9) | 5 | 2 DIFFER | **unchanged** ← residue R2 |
| OUT-OF-BODY method `b2c::o1` (`curSubOob9`) | 5 | 2 DIFFER + 5 NAME-DIFFERS | **unchanged** ← residues R3/R4 |

Arm totals, pristine → patched:

```
b1_cond     cells=66  same=59 DIFFER=7  ->  same=65 DIFFER=1   (6 cleared, 0 new)
b2_modtwin  cells=41  same=32 DIFFER=9  ->  same=32 DIFFER=9   UNCHANGED, as required
b3_kinds    cells=48  same=33 DIFFER=15 ->  same=48 DIFFER=0
```

### 1.4 THE BRIEF'S MEASUREMENT LIST (a)–(h), ANSWERED

Written on the premise that we drop the variable, which §1.1 refutes. Measured
anyway, and two of them turn out to be non-axes:

* **(a) local with a CALL initialiser inside `else begin`** — b3 `e03_call`,
  golden BIND. Identical to (b) and (c).
* **(b) same local, no initialiser** — b3 `e01_none`, golden BIND. **NO TERM.**
* **(c) initialiser that is not a call** — b3 `e02_lit`, `e04_expr`, golden BIND.
  **NO TERM.**
* **(d) if-begin vs else-begin vs bare begin vs named begin** — b3 `g01`/`g02`
  identical; `g03` is a depth-0 cell that already bound; `g04` **named** is the
  one that differs, and it differs because §57's named-block exclusion (already
  in the predicate) is right.
* **(e) module-function twin** — b2 `m01`..`m04`: golden binds *everything* in a
  module function, we already did, 5/5 same, untouched by the patch.
* **(f) the var KIND spread** — b3 `d01`..`d09`, nine kinds, **all identical**.
  **NO TERM.**
* **(g) where golden PARENTS the local, and what fields it carries** — golden
  parents it at the **`assignment`**, not at the `begin`, and carries
  `vpiTypespec` / `vpiName` / `vpiFullName` / `vpiSigned:1`. **We already do all
  of it, byte for byte** (§1.1 table). Nothing to change.
* **(h) does golden emit the initialiser as `vpiExpr`, and in what shape** — it
  does **not** use `vpiExpr` at all. The initialiser is a separate
  `assignment` statement in the `begin`'s `vpiStmt` list
  (`vpiOpType:82`, `vpiBlocking:1`, `vpiRhs func_call (get_inst_id)`,
  `vpiLhs` → the `integer_var` itself). **We already emit exactly that.**

### 1.5 THE CORPUS CENSUS — the mover prediction, recorded BEFORE gate 5 ran

`census64.sh <workdir> <out>` dumps every database a sweep produced and counts,
per database, the `ref_obj` occurrences that (1) carry no `vpiActual` today and
(2) name a variable some `begin` lists under `vpiVariables`. Both facts are
readable off **our own pristine dump**, so the candidate set exists before the
patched binary does. It is deliberately a **SUPERSET** — the dump prints neither
the control depth, nor the class-vs-module scope, nor whether the reference sits
in a condition — so **zero candidates means a database cannot move**, and that
asymmetry is what makes "the movers are exactly these" checkable instead of
sampled.

**The scanner was controlled on the arms first**, because a scanner that finds
nothing where the grid shows six movers is measuring nothing:

```
b1_cond    pristine 41 candidates -> patched 35   delta = 6   grid moved 6   MATCH
b3_kinds   pristine 35 candidates -> patched 20   delta = 15  grid moved 15  MATCH
b2_modtwin pristine  9 candidates -> patched  9   delta = 0   grid moved 0   MATCH
```

```
surelog    (/tmp/r64_pris_wd_sl)  : 953 databases scanned, NO_DUMP=0, 22 CANDIDATE rows
uhdm2rtlil (/tmp/r64_pris_wd_u2r) : 679 databases scanned, NO_DUMP=0,  5 CANDIDATE rows
```

The 22 surelog candidates, in count order:

```
8447  default+testflags/BuildUVMPkg        119  default/Earlgrey_0_1
7849  default/Scoreboard                   118  default/FuncStructVal
7835  default+testflags/SimpleUVM           39  default+testflags/SVSwitch
6268  default+testflags/SeqDriver            8  default+testflags/{SimpleConstraint, Scr1SvTests}
                                             4  default/FuncStructValSimple
                                             2  default+testflags/ApbSlave
                                             2  default/{LocalScopeHierPath, IOClassStruct, ArrayMethodIterator}
                                             1  default/ClassVar
```

The 5 uhdm2rtlil candidates are `rp32_r5p_{alu,bru,mdu,wbu}` (45 each) and
`rsp_gen_minimal` (3) — RTL designs with no class in them, so the gate's
`curSubClassScope9` term cannot fire.

**PREDICTION, recorded before gate 5: uhdm2rtlil 0 movers; surelog movers a
SUBSET of those 22 rows.** The uhdm2rtlil half was checked directly on the five
named databases before the verifier ran — all five byte-identical across the two
binaries.

---

## 2. THE GRID AFTER THE PATCH, AND THE WHOLE-DESIGN AUDIT

The arm grid is in §1.3, third column. The stronger reading is the **whole
design**, every `ref_obj` in the database, not a sample:

`NAMEKEY=1 ct64cells.py` on each mover's golden / pristine / patched dumps, then
a key-join of the pristine and patched tables:

| row | shared keys | keys only in one table | cells whose verdict MOVED | direction | golden on those cells |
|---|---|---|---|---|---|
| default/SimpleUVM | 25818 | **0** | **58** | bare → BIND | **BIND on all 58** |
| default/Scoreboard | 25879 | **0** | **58** | bare → BIND | **BIND on all 58** |
| default/SeqDriver | 26088 | **0** | **58** | bare → BIND | **BIND on all 58** |
| default/BuildUVMPkg | 27857 | **0** | **59** | bare → BIND | **BIND on all 59** |

**Zero cells moved in the wrong direction; zero cells moved where golden is
bare; zero cells appeared or disappeared. Across four distinct designs that is
233 binding decisions changed and 233 of them right**, and with the three
testflags twins the shipped total is **408 new `vpiActual` edges, 0 wrong**.

### 2.1 A DEFECT IN MY OWN INSTRUMENT, FOUND AND FIXED MID-PASS

The first whole-design reading used the arm's key — the **span alone** — and
reported "226 → 170 DIFFER, 56 moved". **That reading was invalid.** uhdm-dump
does not print the FILE, and `uvm_pkg.sv` includes ~200 files, so `line:116:11`
is ~200 different references collapsed onto one key; the table showed **285
`NAME-DIFFERS`**, which is the instrument saying so out loud. `NAMEKEY=1` keys
on `(vpiFullName, span)` and gives the sound reading above — and the true mover
count is **58, not 56**. Both keys are kept, both are documented in
`ct64cells.py`'s header, and the span-only key remains correct (and necessary)
on a single-file arm, where it is what lets the `o1.farg` vs `farg` naming
residue show up as a printed `NAME-DIFFERS` instead of splitting a cell in two.
**A number I had already written down was wrong by 2 and I found it by reading
my own instrument's warning column rather than its verdict column.**

---

## 3. THE FIVE GATES

### GATE 1 — BUILD

```
BUILD DIR (absolute) : /tmp/wt_r10uvm64/build
link line            : [100%] Linking CXX executable slang-uhdm   (waited for, then read)
errors in build log  : 0
FINAL   md5 : 494f6babd956ea73f323c1da7b3eda31   (32 hex, asserted in its own command)
PRISTINE md5: 8a7c07f418d3a567de0b24c6a5e90fe3   (32 hex, asserted in its own command)
both worktrees: git rev-parse HEAD = 957974dabc7aacfb75ce00295ef363f70b189be0
```

A final comment-only tidy in `UhdmExporter.h` was rebuilt and re-hashed: the md5
is **unchanged**, so every number below stands on the shipped binary.

### GATE 2 — GOLDENS

```
SLANG_UHDM=<final>     ./tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false  ./tests/check_goldens.sh   rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump       496 match      183 differ        52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv -> 0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

My **PRISTINE** sweep reproduces the committed baseline at **0 differing ROWS**
too — which is what makes gate 5's byte comparison meaningful.

### GATE 4 — surelog, `--mode both --jobs 2`

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump       default   225 match / 242 differ / 327 blank
           testflags 165 match / 298 differ / 331 blank
ct8rows.sh results/golden_surelog.csv -> 0 differing ROWS (0 diff row-sides)
baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
PASS: every row byte-identical to the committed baseline
```

The pristine sweep also reproduces this baseline at **0 differing ROWS**, and
both dump histograms are unchanged.

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs my own pristine 957974d

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged         SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
             SELFCHECK 952/953 flagged         SELFCHECK1 = 8  (= 7 real + 1 injected)
```

The 7 movers, and every one is inside §1.5's predicted 22:

```
default/{BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM}
testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}
```

`Scoreboard/testflags` is `SLANG_REJECT` and emits no database, which is why the
UVM four give seven rows and not eight. The other **15** candidate rows did not
move — the census is a superset and behaved like one.

**The mover set is complete BY CONSTRUCTION, not by sampling.** The patch can
only add a `vpiActual`, so any database that gains one *must* differ in bytes;
the verifier compares **all 953** and `SELFCHECK1` proves it detects a
**one-byte** change.

### CANARIES

```
canaudit.sh canaries.sh ctcan2.sh   audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
ctcan2.sh  uhdm2rtlil  EXPECT_UNKNOWN=6  ok=1   changed=0 absent=0 unknown=6   PASS
ctcan2.sh  surelog     EXPECT_UNKNOWN=1  ok=58  changed=0 absent=0 unknown=1   PASS
canaries.sh uhdm2rtlil  ok=8   changed=0 absent=0   unknown-names=25 (the surelog-only names)
canaries.sh surelog     ok=52  changed=0 absent=0   unknown-names=7  (the u2r-only names)
InterfaceModPort   base==fresh  default,CMP_EQUAL,differ  testflags,CMP_EQUAL,differ
BlackParrotComplex base==fresh  default,CMP_EQUAL,differ  testflags,CMP_EQUAL,differ
SimpleUVM/SeqDriver/BuildUVMPkg/SVSwitch base==fresh (CMP_NOTEQUAL both modes)
Scoreboard         base==fresh  default,CMP_NOTEQUAL  testflags,SLANG_REJECT
```

Both scripts were run on **both** corpora — neither supersedes the other, and
they take their arguments in **opposite order** (`ctcan2.sh <base> <fresh>`,
`canaries.sh <fresh> <base>`).

### DETERMINISM, and the KNOWN Scoreboard/default FLAKE

The new code path is deterministic — 3 emissions each, 1 distinct hash each:

```
detcheck.sh <final> 3 b1_cond.sv    distinct hashes=1  NO_OUTPUT=0
detcheck.sh <final> 3 b3_kinds.sv   distinct hashes=1  NO_OUTPUT=0
```

The standing `Scoreboard/default` multi-stability flake is **REAL, PRE-EXISTING,
and attributed with reps** as the rules require. Both binaries were run three
times on the identical argv:

```
Scoreboard/default, 3 runs each, same argv, same cwd
  PRISTINE 8a7c07f4…  b71f4479 / f57c2186 / 19398003   distinct=3   bytes 11133449 (all 3)
  PATCHED  494f6bab…  034ff03d / 034ff03d / 034ff03d   distinct=1   bytes 11133994 (all 3)
```

**The PRISTINE binary reproduces the flake at three distinct hashes**, so it is
not this patch; the patched binary happened to be stable across these three
reps, which is not evidence either way and is reported as what it is. What keeps
the Scoreboard mover attribution valid is the **byte SIZE**, which is stable
within each binary and differs by a deterministic **+545 bytes** — consistent
with the 58 added `vpiActual` edges `mv64.sh` reports for that database.

---

## 4. THE MOVERS, PER SHAPE, BY MULTISET

`mv64.sh <golden> <pristine> <patched> <label>` reports the multiset distance to
golden before and after, ADDED and REMOVED **separately and never netted**, and
the ADDED shapes normalised. `msdist.sh` is the resync-immune instrument; the
**SIGN of the distance is not a verdict** and is reported as data.

**All 7 movers, not a sample:**

| row | dist pristine | dist patched | gain | ADDED lines | REMOVED |
|---|---|---|---|---|---|
| default/SimpleUVM | 144517 | 144463 | +54 | 116 | **0** |
| testflags/SimpleUVM | 144513 | 144459 | +54 | 116 | **0** |
| default/Scoreboard | 134810 | 134770 | +40 | 116 | **0** |
| default/SeqDriver | 367715 | 367603 | +112 | 116 | **0** |
| testflags/SeqDriver | 367715 | 367603 | +112 | 116 | **0** |
| default/BuildUVMPkg | 81215 | 81115 | +100 | 118 | **0** |
| testflags/BuildUVMPkg | 81215 | 81115 | +100 | 118 | **0** |

`BuildUVMPkg`'s two modes produce the same database bytes (patched md5 prefix
`e1d3438bffe4` in both), which is why their numbers are identical.

**THE ADDED SHAPES, aggregated by kind** — every added line is either the
`|vpiActual:` field or the header of the object it now points at, and the two
counts match exactly:

| row | `\|vpiActual:` | class_var | enum_var | bit_var | int_var | string_var | ref_var | integer_var | Σ targets |
|---|---|---|---|---|---|---|---|---|---|
| default/SimpleUVM | **58** | 26 | 8 | 8 | 6 | 5 | 3 | 2 | **58** |
| default/Scoreboard | **58** | 26 | 8 | 8 | 6 | 5 | 3 | 2 | **58** |
| default/SeqDriver | **58** | 26 | 8 | 8 | 6 | 5 | 3 | 2 | **58** |
| default/BuildUVMPkg | **59** | 20 | 7 | 13 | 11 | 6 | 2 | – | **59** |

**Two independent instruments agree to the unit**: the multiset shape count says
58 new edges on SimpleUVM, and the per-cell whole-design audit (§2) says 58 cells
moved bare→BIND. **ADD-ONLY HOLDS: REMOVED == 0 on all seven.**

Named examples of what got bound, from the shape list: the head itself
(`uvm_recorder::get_handle::handle`), its twin
`uvm_tr_stream::get_handle::handle`, `uvm_objection::m_raise::diff_count`,
`uvm_objection::m_report::last_dot`, `uvm_resource_pool::delete::q_size`,
`uvm_reg_single_access_seq::body::ro`,
`uvm_reg_mem_hdl_paths_seq::check_reg::p_`,
`uvm_typed_callbacks::m_get_tw_cb_q::dt`, and the
`__m_uvm_execute_field_op::__tmp_*` family the UVM field-automation macros
expand into.

---

## 5. THE REFUTATIONS, STATED PLAINLY

1. **THE BRIEF'S HEAD DESCRIPTION IS FALSE.** "We emit NO object for this local"
   and "the whole `integer_var` IS absent from our dump" — we emit it, in the
   same place, with the same fields, byte for byte (§1.1). The head is a missing
   `vpiActual` **edge** on a `ref_obj` three lines further down. `RHS: <null>`
   named the SLOT, and the slot's *value* is the variable, not the variable's
   *listing*.
2. **THE BRIEF'S SUSPECTED MECHANISM IS FALSE.** "A dropped local var is likely
   a noted bail." The unsupported summary for this compile has two entries,
   neither of them near line 343 and neither of them a variable.
3. **THE BRIEF'S ENTIRE MEASUREMENT LIST (a)–(h) IS OFF-AXIS**, and two of its
   items are non-axes even on their own terms: the var **KIND** (9 cells) and the
   **INITIALISER** shape (4 cells) do not condition the binding at all (§1.4).
   Had I written the patch the brief describes, it would have minted a duplicate
   `integer_var` next to a correct one.
4. **§57's LAW-SHAPE WAS TOO NARROW, NOT WRONG.** It states the carve-out as
   argument-list-scoped. Golden's carve-out is window-scoped, and §57 simply had
   no condition-position cell in its arms. Every §57 cell still reads as §57
   recorded it.
5. **"ANY CONDITION" WOULD HAVE OVER-FIRED.** A `while` condition looks exactly
   like an `if` condition in source and is *not* a window: golden leaves
   `while (blkloc == 11)` bare (b1 c13). The gate keys on `!classMethodNoBind`,
   which is true only where `StmtEmit.cpp` actually clears it, and so gets this
   cell right for a mechanical reason rather than a lucky one.
6. **MY OWN FIRST WHOLE-DESIGN NUMBER WAS WRONG.** "56 cells moved" was produced
   with a key that collides across the ~200 files of `uvm_pkg.sv`. The sound key
   says 58. §2.1.

---

## 6. RANKED RESIDUES

Ranked by measured cell count on `SimpleUVM/default` after the patch
(`NAMEKEY=1`, whole design: **89 DIFFER** — 48 where we over-bind, 41 where we
under-bind — and **5681 UNMEASURED**, spans one side emits and the other does
not).

* **R1 — NAMED-block local at DEPTH 0 in a condition: we OVER-BIND.**
  Arm cell b1 **c08 82:11** — `begin : nmd int c08_nmdblk = 4; if (c08_nmdblk == 5)`
  at `ctrlBodyDepth28 == 0`: golden **bare**, we **BIND**. Its unnamed twin
  (c11 86:11) is golden **BIND**, so the discriminator is the LABEL, exactly as
  §57 found at depth 1 (b2 f:24). We get the depth-1 cell right (c16 90:11)
  only because §28 silences it for an unrelated reason. **PRE-EXISTING and
  untouched by this pass** — it is a DELETE-direction law at depth 0, where
  neither §28 nor §57 nor §64 applies. This is the single remaining DIFFER on
  arm b1 and the top candidate for the next pass in this family.
* **R2 — `$UNIT`-scope function has NO condition carve-out at all
  (§ unitSubNoBind9): we UNDER-BIND.** Arm b2 `u1`: golden binds the
  **depth-0** condition ref (23:7) *and* the depth-1 same-block-local condition
  ref (28:9); we bind neither. Two cells. The depth-1 half is the exact shape
  §64 clears for a class method, so §64's disjunct could be widened to lift
  `unitSubNoBind9` too — but the depth-0 half would still be wrong, so it is a
  head of its own and was left alone under ONE HEAD PER RUN.
* **R3 — OUT-OF-BODY method (`curSubOob9`) binds too widely.** Arm b2 `o1`:
  golden binds the two condition refs (57:7, 59:9) and leaves the assignment
  RHS (60:9) and the body-local-in-a-condition (61:9) **bare**; we bind all
  four. Two cells. The in-tree comment claims an out-of-body definition "binds
  everywhere already"; on a class declared at **$unit** scope that is measurably
  false. Note the class in the earlier measurement lived in a **package**, so
  this is a new cell rather than a contradiction — and it is exactly the kind of
  scope axis that needs its own arm.
* **R4 — out-of-body ref NAMING.** Golden names `b2c::o1`'s refs `o1.farg` /
  `o1.o01_blkloc`; we name them `farg` / `o01_blkloc`. 5 cells on arm b2, and
  285 `NAME-DIFFERS` on a span-keyed SimpleUVM read. Pre-existing.
* **R5 — the new head on all three target rows**: an empty
  `begin (uvm_pkg::uvm_recorder::do_open) @547:18-547:25` that golden emits and
  we do not. Different law, now unmasked.
* **R6 — the 89 remaining `SimpleUVM/default` DIFFERs as a whole: 48 over-binds
  and 41 under-binds.** R1–R4 are arm-measured *shapes*; how much of these 89
  they account for is **not** yet measured and is not claimed. The under side is
  dominated by loop variables (`i` at 623:14, 623:33, 623:52 …) and
  `compiled_regex` / `waiter` / `severity`; the over side by class-property and
  enum-constant refs at declaration positions (`build_ph`..`report_ph` at
  122:5..129:5, `UVM_UNBOUNDED_CONNECTIONS`, `seq_item_export`). Not yet
  decomposed into laws. The 5681 `UNMEASURED` spans are a separate,
  object-identity residue and are larger than all of this put together.

---

## 7. FILES

| file | what it is |
|---|---|
| `b1_cond.sv` | **the arm that decides the law** — 28 cells: the condition window, the depth axis, the named/unnamed axis, and every non-window position at depth 1 |
| `b2_modtwin.sv` | the NEGATIVE CONTROL — module / package / `$unit` / out-of-body twins |
| `b3_kinds.sv` | the two non-axes (9 var kinds, 4 initialiser shapes) plus the block-shape spread |
| `ct64arm.sh` | arm driver; LHS golden, RHS ours; `sed 1d` on both dumps; missing-input guards |
| `ct64cells.py` | the cell reader; fullest occurrence, own-field indent, `-NOOBJ-` bucket, `NAMEKEY=1` for multi-file designs |
| `census64.sh` / `census64.py` | the pre-patch mover prediction (SUPERSET), arm-controlled before every corpus scan |
| `mv64.sh` | per-shape mover analysis; ADDED/REMOVED never netted |
| `msdist.sh` | resync-immune multiset distance (whitespace-preserving) |
| `byteverify.sh` | gate 5, with `SELFCHECK` and `SELFCHECK1` |
| `ct8rows.sh` | the whole-ROW CSV gate |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary set and the audit that proves the set covers the brief |
| `detcheck.sh` / `manifest.sh` / `rowheads.sh` | determinism, manifests, per-row head counts |
