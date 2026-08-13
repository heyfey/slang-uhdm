# r10svs15 — SVSwitch **CONVERTS**: an elab clocking block is a **CLONE** of the def's, and the clone carries the def ref's binding **AT CLONE TIME**

**Verdict, up front: `SVSwitch` CONVERTS in BOTH MODES.** The rows, quoted from
the committed authoritative baseline FIRST and then from this pass's fresh sweep.
**No `results/*.csv` was touched by this pass** (`git status --porcelain
results/` is EMPTY); the MASTER promotes.

```
committed results/golden_surelog.csv        BEFORE
  SVSwitch,default,CMP_NOTEQUAL,decompile:,,
  SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,

this pass, shipped binary f1a2249bc847024b1bb06232ffd8bc79   AFTER
  SVSwitch,default,CMP_EQUAL,,,differ
  SVSwitch,testflags,CMP_EQUAL,,,differ
```

`uhdm-cmp` rc **255 → 0**, HEAD DEPTH **31 → 0**, heads **1 → 0**, in both modes.
The brief's head is not merely advanced: `module_inst::Compare` on
`work@top` returns **0** and the whole design compares EQUAL.

* **ONE LAW, `§ cbEventRefFirstInstance15`**, five lines of statement and **one
  new drain**. The diff is **+112/−16 lines** across three files (comment-heavy: the
  executable core is ~20 lines), and
  it is a *transcription of a mechanism this codebase had already written down for
  a different carrier* (`src/ModuleEmit.cpp:10515`, the GLOBAL clocking block:
  *"a CLONE of the def's: a distinct object whose event ref still points at the
  DEF net"*). **The law existed; a call site was skipped.**
* **THE BRIEF'S LAW IS TOO NARROW, AND ARM a2 REFUTES IT OUTRIGHT.** The brief
  says *"element [0]'s bit_var for OTHER elements"*. It is not about the array at
  all: **two SCALAR instances** of one interface show the identical binding
  (`d1b.cb.clock → d1a.clock`), an array binds to a **SCALAR** declared before it
  (`d2arr[0..1] → d2s.clock`), a scalar binds to an **array element** declared
  before it (`d3s → d3arr[0]`), a second array binds to the **first array's**
  element (`d4q[*] → d4p[0]`), and two instances in **different parent scopes**
  bind across them (`s2.u → s1.u`). §6.1.
* **AND IT IS NOT "ELEMENT [0]" EITHER — THERE NEED BE NO ELEMENT 0.** Arm a1
  cell **c7** is `c7_if c7a[5:2]`: golden's target is **`c7a[2]`**, the LOWEST
  index, and `c7a[2]`'s own ref is the unbound one. §6.2.
* **NOR IS IT PER-PARAMETERIZATION.** Arm a3 cell **e1**: `e1_if #(16) e16`
  binds to **`e1_if #(8) e8`**'s variable — across a parameterization boundary.
  This is why the implementation keys on the clocking declaration's **SYNTAX
  NODE**; a key of (definition, parameterization) would have UNDER-fired here,
  and a key of the definition alone would have merged arm a3's two blocks. The
  arm was written to catch an over-fire and instead **decided the key**. §6.3.
* **GRID: 102 CELLS across the witness and three purpose-built arms —
  42 CONVERGED, 46 HELD, NOT ONE REGRESSED**, 14 `stillDIF` every one of which is
  a ref on an object **we do not emit at all** (§3.4). §3.
* **FIVE GATES GREEN** in the **CONVERSION** world (§5), the two histogram
  row-sides per mode being exactly `SVSwitch`'s.
* **MOVERS: 2** (`SVSwitch`, both modes) out of **1632** databases (679 u2r + 953 surelog) across both
  corpora — and the per-shape multiset table shows the movers are **three
  two-line `|vpiActual:` insertions per database and nothing else** (§5.5).
* **SEVEN REFUTATIONS**, three of them against this pass's own brief, one against
  its own first cut of GATE 1's marker script, plus a written list of what this
  pass did **NOT** prove (§6, §6.8).

Base commit `a27a874`, branch `auto5h`.
Pristine binary md5 **`fe6962c25b01f8e48387b1ec2dcde8ee`** (worktree
`/tmp/wt_r10svs15pris`, `git rev-parse HEAD` =
`a27a8746a82b6e74c90a1992f1694da2cfcb8f12`, `git status --porcelain` EMPTY).
Shipped binary md5 **`f1a2249bc847024b1bb06232ffd8bc79`** (worktree
`/tmp/wt_r10svs15`, same `HEAD`, `git status --porcelain` = exactly the three
production files and this directory).

---

## 1. THE HEAD, AND THE CENSUS THAT LOCALIZED IT

### 1.1 The head as `uhdm-cmp` reported it at `a27a874`

31 lines, ONE head, **byte-identical in both modes** (`cmp -s` on the two
`*.cmp.txt`), and the failing field is a **singular** one: `RHS: <null>` against
a golden `bit_var`.

```
LHS:
decompile:
bit_var: (work@top.output_intf[0].clock), id:2543, line:58:38, endln:58:43
...
RHS: <null>
```

`uhdm-cmp` names the LHS object but not the slot, so the slot was found by
CENSUS, not by reading the report.

### 1.2 The census — BOTH SIDES, span-keyed, run BEFORE any code was written

`cbcensus.sh` walks **every `ref_obj` in a database** and prints its `vpiActual`
target, keyed by the PAIR (`vpiFullName`, source span). A cell present on one
side only is reported `MISSING`, never dropped — *a census that drops a row reads
exactly like a census where the row agrees.* On the witness at `a27a874`:

```
CELLS 694   EQ 664   DIF 7   MISSING 23
```

Restricted to the clocking-block event refs, all **nine** of them, this is the
entire head:

| # | ref `vpiFullName` | view | GOLDEN `vpiActual` | OURS | |
|---|---|---|---|---|---|
| 1 | `work@mem_interface.cb.clock` | DEF | `bit_var work@top.mem_intf.clock` | same | EQ |
| 2 | `work@input_interface.cb.clock` | DEF | `bit_var work@top.input_intf.clock` | same | EQ |
| 3 | `work@output_interface.cb.clock` | DEF | `bit_var work@top.output_intf[0].clock` | same | EQ |
| 4 | `work@top.mem_intf.cb.clock` | HOME (scalar) | *(unbound)* | *(unbound)* | EQ |
| 5 | `work@top.input_intf.cb.clock` | HOME (scalar) | *(unbound)* | *(unbound)* | EQ |
| 6 | `work@top.output_intf[0].cb.clock` | HOME `[0]` | *(unbound)* | *(unbound)* | EQ |
| 7 | `work@top.output_intf[1].cb.clock` | HOME `[1]` | `bit_var work@top.output_intf[0].clock` | *(unbound)* | **DIF** |
| 8 | `work@top.output_intf[2].cb.clock` | HOME `[2]` | `bit_var work@top.output_intf[0].clock` | *(unbound)* | **DIF** |
| 9 | `work@top.output_intf[3].cb.clock` | HOME `[3]` | `bit_var work@top.output_intf[0].clock` | *(unbound)* | **DIF** |

**Exactly three DIF cells, and the compare goes EQUAL when they are fixed** — so
the localization is complete and it was complete before a line was written.

### 1.3 The four DIF cells that are NOT this head

The census's other 4 DIF cells are `work@top.TC.output_intf[0..3].clock` — golden
names the target `output_intf.output_intf[i]`, we name it
`work@top.TC.output_intf[i]`. That is `r10svs14`'s **R3**, the unowned
interface-array island's NAMING, sitting on `§ progPortIfaceArrayUnowned13`'s
declared boundary. It is **UNCOMPARED** by `uhdm-cmp` today (which is why the
design goes EQUAL with it still present), it is reported in §7 as **R6**, and it
was NOT touched. The 23 `MISSING` cells are class-scope method-ref naming
(`::` vs `.`) plus `r10svs14`'s R2 (§7 **R5**); likewise untouched.

---

## 2. THE LAW

### § cbEventRefFirstInstance15

> **An ELAB (home) view's clocking block is a CLONE of the DEF view's, and the
> clone carries whatever the DEF's event ref pointed at AT CLONE TIME.** The DEF's
> ref is patched by the **FIRST elaborated instance** of the def, so:
>
> 1. the **first** instance cloned an UNBOUND ref → **its own ref stays UNBOUND**;
> 2. every **other** instance cloned the already-patched ref → **its ref binds to
>    the FIRST elaborated instance's variable**, the *same object* the DEF view's
>    own ref names;
> 3. "the def's instances" means **design-wide and syntax-wide**: array elements,
>    separate scalars, separate arrays, different parent scopes, and **different
>    parameterizations** are all one population.
>
> A single-instance interface therefore has both its refs correct by
> construction — which is why 19 of the 20 carrier test dirs cannot move.

**The asymmetry IS the law.** "The first instance's own ref is unbound" is not an
exception bolted onto a lookup rule; it is the *only* thing that distinguishes a
clone rule from a lookup rule, and it is what says the mechanism is temporal.
Every arm cell in §3 is a test of that one sentence.

### 2.1 STATED GATE == CODE GATE

| the STATEMENT | the CODE that enforces it |
|---|---|
| "the DEF's ref is patched by the FIRST elaborated instance" | `src/ModuleEmit.cpp` — `if (!r9->Actual_group())` added to the `pendingCbRefs` drain: **first writer wins**, explicitly, instead of relying on bodies happening to be distinct objects |
| "the first instance's own ref stays UNBOUND" | `defCbBody[csyn] != &body` — the elab ref is recorded ONLY when this body is **not** the one that produced the def view, compared by **body identity**, which is the very same body whose nets patched the def ref, so the two halves cannot disagree |
| "binds to the object the DEF ref names" | `drainCbElabRefs15()` copies `defCbEventRefs[key]->Actual_group()`; it never re-derives the target, so a wrong def binding can only produce a *consistently* wrong follower, never a *differently* wrong one |
| "design-wide and syntax-wide, across parameterizations" | the key is `(const void*)csyn` — the clocking **declaration's syntax node**, which all instances of a def share regardless of parameterization (arm a3 cell e1) |
| "and it separates two clocking blocks in one interface" | the key's second half is the ref's **name**, and `csyn` is per-BLOCK, not per-interface (arm a3 cell e2: `cba.clock` and `cbb.clk2` resolve independently) |
| "the answer does not depend on emission order" | the drain is **DESIGN-FINAL** (`UhdmExporter.cpp`, ahead of the pinned tail), not inline at elab-emission time; §4.2 explains why that distinction is load-bearing and not defensive padding |
| "…and the DEF view itself is written down once" | `defCbBody` / `defCbEventRefs` carry **no** first-writer guard, and that is structural, not lucky: `emitInterfaceDef` is called from exactly ONE site (`UhdmExporter.cpp:4788`) iterating `defs`, which holds ONE entry **per def name**, so a given `csyn` reaches that line exactly once. Arm a3 cell **e1** measures the only shape that could challenge it — one interface at **two parameterizations** — and confirms a SINGLE def view (`work@e1_if`) for both. A guard here would have been an **unexercised branch**, which §6.8 already flags as a weakness for the one guard that genuinely needs to exist |

### 2.2 THE LAW WAS ALREADY IN THIS CODEBASE, ON A DIFFERENT CARRIER

`src/ModuleEmit.cpp:10515`, pre-existing, about a **GLOBAL** clocking block:

> *"A GLOBAL clocking block's elab view is a CLONE of the def's: a distinct object
> whose event ref still points at the DEF net"*

Same mechanism, same word — *clone*. This pass is the **interface-instance** call
site of a rule the codebase had already characterized, which is the recurring
shape of this campaign: the law exists, a builder was skipped. Naming it that way
in the code is deliberate, so the next pass on the third carrier finds it.

### 2.3 THE ADJACENT LAWS, AND WHY THIS IS NOT ONE OF THEM

* **`§ modportExprPort`** (`include/UhdmExporter.h:711`,
  `src/ModuleEmit.cpp:21764/22440/23556/23686`) — *"In the DEF view the ref form
  binds the FIRST elaborated instance's variable"*, for modport **EXPRESSION**
  ports (`.P(r[3:0])`). It is the same *"first elaborated instance"* observation,
  and the brief correctly pointed at it — but it is **only about the DEF ref**,
  which on our carrier was **ALREADY CORRECT** before this pass (census cells 1–3,
  §1.2, EQ on both binaries). `§ modportExprPort` has nothing to say about the
  *other* instances' own refs, which is this head. **Not touched**:
  `pendingModportExprRefs` is a separate vector and a separate drain, and the only
  edit near it is in a different function.
* **`§ ifaceDupVarsAreHomeVars14`** (LANDED `a27a874`) — the col-0 tail dup's
  `Variables()`. Reads `home->Variables()`; writes no `Actual_group`. Disjoint.
* **`§ vifClockingPathComponent5`** — clocking *components* of a virtual-interface
  PATH (`vif.cb.sig` as an expression). This law is about the clocking block's
  own **event** expression, in an interface's own view. Disjoint carriers; both
  arms and the witness leave every `vif`-path cell EQ.
* **`§ progPortIfaceArrayUnowned13`** — owns §7's R2/R3, explicitly not touched.

**No collision.** The live passes named in the brief (`r10earl37`, `r10uvm67`)
touch neither `emitNamedClockingBlocks` nor `exportDesign`'s design-final region
as of the worktrees on disk at `45716d3` / `00b7fda`.

---

## 3. THE GRID, CELL FOR CELL

A **CELL** is one clocking-block event `ref_obj`, keyed (`vpiFullName`, span); the
value is its `vpiActual`. `grid15.sh <tag>` prints GOLDEN / PRIS / SHIP in one
table from dumps **already on disk**, and it **refuses to print** (exit 4) if the
two runs' golden dumps differ by anything beyond the arm scratch path.

```
witness  CELLS 13   held 10   CONVERGED  3   REGRESSED 0   stillDIF  0
arm a1   CELLS 50   held 18   CONVERGED 22   REGRESSED 0   stillDIF 10
arm a2   CELLS 19   held 10   CONVERGED  9   REGRESSED 0   stillDIF  0
arm a3   CELLS 20   held  8   CONVERGED  8   REGRESSED 0   stillDIF  4
------------------------------------------------------------------------
TOTAL   CELLS 102   held 46   CONVERGED 42   REGRESSED 0   stillDIF 14
```

### 3.1 The witness (`svsgen.sh`, mode `default`; `testflags` is byte-identical)

| ref | GOLDEN | PRIS | SHIP | verdict |
|---|---|---|---|---|
| `work@mem_interface.cb.clock` | `top.mem_intf.clock` | same | same | held |
| `work@input_interface.cb.clock` | `top.input_intf.clock` | same | same | held |
| `work@output_interface.cb.clock` | `top.output_intf[0].clock` | same | same | held |
| `work@top.mem_intf.cb.clock` | *(unbound)* | *(unbound)* | *(unbound)* | held |
| `work@top.input_intf.cb.clock` | *(unbound)* | *(unbound)* | *(unbound)* | held |
| `work@top.output_intf[0].cb.clock` | *(unbound)* | *(unbound)* | *(unbound)* | **held — the asymmetry** |
| `work@top.output_intf[1].cb.clock` | `top.output_intf[0].clock` | *(unbound)* | `top.output_intf[0].clock` | **CONVERGED** |
| `work@top.output_intf[2].cb.clock` | `top.output_intf[0].clock` | *(unbound)* | `top.output_intf[0].clock` | **CONVERGED** |
| `work@top.output_intf[3].cb.clock` | `top.output_intf[0].clock` | *(unbound)* | `top.output_intf[0].clock` | **CONVERGED** |

### 3.2 Arm **a1** — WHICH element, and WHICH shapes carry the rule
(`a1_cbarr.sv`; one def per cell, each instantiated exactly one way)

| cell | shape | GOLDEN's target | PRIS→SHIP |
|---|---|---|---|
| **c1** | `[4]`, ANSI header clock, `default` skew, modport `clocking cb` — the witness replica | `c1a[0].clock`; `[0]` unbound | 3 CONVERGED |
| **c2** | the same with **NO MODPORT** | `c2a[0].clock`; `[0]` unbound | 3 CONVERGED |
| **c3** | `@(posedge clock or negedge rst)` — **TWO** refs | `c3a[0].clock` **and** `c3a[0].rst`, each independently | 6 CONVERGED |
| **c4** | the clock is a **BODY variable**, not a header port | `c4a[0].lclk`; `[0]` unbound | 3 CONVERGED |
| **c5** | **no clocking block** — `always @(posedge clock)` | *(no per-element elab ref exists at all)* | see §6.5 / **R1** |
| **c6** | a **MODULE** with a named clocking block, `[4]` | `logic_net work@c6_mod.clock` — **the DEF's OWN net, for all four** | 5 stillDIF; **we emit none** (R2) |
| **c7** | `[5:2]` — **descending, no element 0** | **`c7a[2]`** (the LOWEST index); `c7a[2]` unbound | 3 CONVERGED |
| **c8** | a **SCALAR** twin | its own ref **unbound** | held (control) |
| **c9** | `[2]` — smallest array | `c9a[0].clock` | 1 CONVERGED |
| **c10** | `[2:5]` — ascending, non-zero base | `c10a[2].clock` | 3 CONVERGED |
| **c11** | `[2][2]` — **2-D** | `c11a[0][0].clock` for **all three** others — ONE first across the whole nested array | 5 stillDIF; **we emit no elab views** (R3) |

### 3.3 Arm **a2** — the population: ARRAY, or the DEF's first instance ANYWHERE?
(`a2_cbmul.sv`; one def, MORE THAN ONE instantiation site. **This arm decides the
law**, and it decides it against the brief.)

| cell | shape | GOLDEN | PRIS | SHIP | verdict |
|---|---|---|---|---|---|
| **d1** | two SCALARS, `d1a` then `d1b` | `d1b → d1a.clock`, `d1a` unbound | *(unbound)* | `d1a.clock` | **CONVERGED** |
| **d2** | SCALAR then ARRAY | `d2arr[0] → d2s.clock`, `d2arr[1] → d2s.clock`, `d2s` unbound | *(unbound)* | `d2s.clock` | **2 CONVERGED** |
| **d3** | ARRAY then SCALAR | `d3arr[1] → d3arr[0]`, **`d3s → d3arr[0]`**, `d3arr[0]` unbound | *(unbound)* | `d3arr[0].clock` | **2 CONVERGED** |
| **d4** | two ARRAYS | `d4p[1]`, `d4q[0]`, `d4q[1]` **all → `d4p[0]`**, `d4p[0]` unbound | *(unbound)* | `d4p[0].clock` | **3 CONVERGED** |
| **d5** | one iface inside a submodule instantiated TWICE | `s2.u → s1.u.clock`, `s1.u` unbound | *(unbound)* | `s1.u.clock` | **CONVERGED** |

Read `d2` and `d3` together: the **same def**, the **same two shapes**, and the
target flips with **declaration order**. That is what "first elaborated instance"
means, stated as a measurement.

### 3.4 Arm **a3** — the OVER-FIRE arm, which instead decided the KEY
(`a3_cbpar.sv`)

| cell | shape | GOLDEN | SHIP | verdict |
|---|---|---|---|---|
| **e1** | `e1_if #(8) e8; #(16) e16; #(8) e8b;` | **`e16 → e8.clock`** and `e8b → e8.clock`; `e8` unbound; ONE def view `work@e1_if` for both parameterizations | matches | **2 CONVERGED** |
| **e2** | TWO named blocks `cba`/`cbb`, `[3]` | `cba.clock → e2a[0].clock`, `cbb.clk2 → e2a[0].clk2`, independently; both `[0]` refs unbound | matches | **4 CONVERGED** |
| **e3** | `clocking cb@(clock)` — **bare identifier, no edge operation** | `e3a[1..2] → e3a[0].clock`; `e3a[0]` unbound | matches | **2 CONVERGED** |
| **e4** | **`default clocking`**, `[3]` | `e4a[1..2] → e4a[0].clock` — **THE SAME LAW** | **we emit no clocking block at all** | 4 stillDIF (**R4**) |

### 3.5 All 14 `stillDIF` cells are objects we do not emit

c11 (2-D iface array) **5**, c6 (module named cb) **5**, e4 (interface `default
clocking`) **4** — that is 14, exactly. **Not one `stillDIF` cell is a wrongly
bound ref**: every one is a ref on an object absent from our database entirely, so
none of them is a binding this law got wrong, and each is a separate missing
producer (R2/R3/R4 in §7). **0 REGRESSED, in all 102 cells.**

---

## 4. THE PATCH

`+112 / −16` lines across three files (`include/UhdmExporter.h` +28,
`src/ModuleEmit.cpp` +76/−16, `src/UhdmExporter.cpp` +8) — one new function and
~20 lines of executable change; the rest is the law and its traps, written where
the next reader will look.

### 4.1 `src/ModuleEmit.cpp` — `emitNamedClockingBlocks`

1. **The existing `pendingCbRefs` drain becomes FIRST-WRITER-WINS** —
   `if (!r9->Actual_group())`. Today every corpus and arm instance body is a
   distinct object, so `nm.find(sym9)` succeeds exactly once and the guard is a
   **measured no-op** (GATE 5 proves it: the 2 movers' per-shape table is three
   `|vpiActual:` insertions, §5.5). It is there because the *stated* rule is "the
   FIRST", and without the guard a def whose instances SHARED one body would end
   up naming the **LAST** — after which the clones would faithfully follow the def
   ref to the wrong object. **STATED == CODE.**
2. **The def/elab ref walk is factored into one `walk9` lambda.** The old
   `collect` was def-view-only and inlined; a bare `@(clock)` is a `ref_obj`
   directly and a `posedge`/`or` form is an `operation` over them, so both views
   need the same two-case walk (arm a3 cell **e3** is the cell that would have
   caught a walk that only descended operations).
3. **DEF view additionally records** `defCbBody[csyn] = &body` and
   `defCbEventRefs[{csyn, name}] = r0`.
4. **ELAB view**, and only when `defCbBody[csyn] != &body`, records each unbound
   ref into `pendingCbElabRefs`. The `!=` is the whole of clause (1) of the law.

### 4.2 `src/UhdmExporter.cpp` — `drainCbElabRefs15()`, DESIGN-FINAL

**Why deferred rather than inline, and why that is not defensive padding.** An
inline copy would read the def ref's `Actual_group` at the moment the elab view is
emitted, which is null until the **first** instance's home view has run. That is
fine if home views are always emitted in declaration order — and on the witness
and all three arms they are. But nothing in `emitInterfaceInstance`'s callers
*guarantees* it (interfaces are reached from at least eight call sites in
`ModuleEmit.cpp`, including gen-scope and port-driven paths), and if a non-first
instance were ever emitted first, an inline copy would silently leave it
**unbound** — indistinguishable from the pre-patch bug and invisible to every gate
that passed here. Deferring to design-final makes the law depend on **nothing but
"all views are emitted"**.

**Placement.** Immediately **ahead** of the pinned tail
(`§ 54 → § 24 → § 23 → § 45 → § 38`), with the independence argued in the comment
rather than assumed: the drain only ever fills a **null** `vpiActual` on a
clocking-block **event** `ref_obj`, and no tail pass reads or writes one
(`§ 54` writes `class_typespec` spans; `§ 24`/`§ 23`/`§ 45` rewrite package and
class **listings**; `§ 38` touches only refs **named `this`**). The pinned order
is unchanged.

### 4.3 `include/UhdmExporter.h`

Three members and one declaration, with the key's justification written where the
key is declared (`defCbEventRefs`), because "why `csyn` and not the definition" is
exactly the question the next reader will have, and arm a3 cell e1 is the answer.

---

## 5. THE FIVE GATES

Read in the **CONVERSION** world of GATE 4 — **said first, as the brief
requires** — because `SVSwitch` moved.

### 5.1 GATE 1 — BUILD, and a BEHAVIOURAL base marker

Both binaries built from an absolute path; the **link line waited for** and
counted (`Linking CXX executable slang-uhdm` = 1 in each log); **0** lines
matching `error:`; each md5 asserted in its **own** command and checked to be
32 hex.

```
pristine  /tmp/wt_r10svs15pris/build/slang-uhdm   fe6962c25b01f8e48387b1ec2dcde8ee   32-hex ✓
shipped   /tmp/wt_r10svs15/build/slang-uhdm       f1a2249bc847024b1bb06232ffd8bc79   32-hex ✓
```

**One late edit, and the assertion that it costs nothing.** After the gates below
had all run, a comment was added to `emitNamedClockingBlocks` recording *why*
`defCbBody` needs no first-writer guard (§2.1's last row). The tree was rebuilt
and the binary's md5 came back **`f1a2249bc847024b1bb06232ffd8bc79` — byte for
byte the binary every number below was measured on**, so no gate was re-run on a
different binary and none of them is stale. That is asserted, not assumed:

```
after the edit + rebuild   f1a2249bc847024b1bb06232ffd8bc79  build/slang-uhdm
the binary the gates ran   f1a2249bc847024b1bb06232ffd8bc79  (copy kept before rebuilding)
```

`basemark.sh` is **two-directional on one observable, with three controls that
must NOT move**, so neither binary can pass by accident:

```
                                                  PRISTINE                        SHIPPED
SYMBOL     drainCbElabRefs15                      0                               1
MOVER      work@top.c1a[1].cb.clock               (unbound)                       bit_var work@top.c1a[0].clock
CONTROL A  work@top.c1a[0].cb.clock               (unbound)                       (unbound)
CONTROL B  work@top.c8s.cb.clock                  (unbound)                       (unbound)
CONTROL C  work@c1_if.cb.clock                    bit_var work@top.c1a[0].clock   bit_var work@top.c1a[0].clock
```

CONTROL A is the law's asymmetry, CONTROL B the scalar twin, CONTROL C the def
ref that was already right. The symbol row is quoted **as well as**, never instead
of, the behaviour — a symbol proves the object linked, not that the law fires.

### 5.2 GATE 2 — GOLDENS, both directions

```
SLANG_UHDM=<shipped>  ./tests/check_goldens.sh   rc=0   PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh   rc=1   PASS=0   FAIL=23
```

### 5.3 GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`

```
679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL        (= 679/50/2)
496 match       183 differ        52 <empty>            (= 496/183/52)
ct8rows.sh vs committed results/gate_uhdm2rtlil.csv:
  baseline 731 ROWS, fresh 731 ROWS
  WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  PASS: every row byte-identical to the committed baseline
```

### 5.4 GATE 4 — surelog, BOTH modes, `--jobs 2` — **CONVERSION world**

**WHICH WORLD, SAID FIRST: the CONVERSION world.** `SVSwitch` moved, so the
UNCONVERTED expectation (`467/13` + `463/10`, histograms unchanged, 0 rows) is
**not** the one to judge against; the conversion expectation is, and it is met
exactly:

```
                       BASELINE            FRESH               expected
default    CMP_EQUAL   467          ->     468                 468   ✓
default    CMP_NOTEQUAL 13          ->      12                  12   ✓
testflags  CMP_EQUAL   463          ->     464                 464   ✓
testflags  CMP_NOTEQUAL 10          ->       9                   9   ✓
```

Every other status bucket is **unchanged in both modes**: `DEFERRED` 5/5,
`SLANG_REJECT` 284/286, `SURELOG_FAIL` 25/23, `NO_DATABASE` 3, `NO_UHDM` 1,
`TIMEOUT` 1, `UNTRANSLATABLE` 2. (The two sweeps ran concurrently, which the ops
rules warn can race `SURELOG_FAIL` **detail** rows; the whole-row diff below
shows no `SURELOG_FAIL` row moved at all, in either direction.)

`ct8rows.sh` against the committed `results/golden_surelog.csv`, whole row,
status **and** dump column:

```
baseline 1588 ROWS, fresh 1588 ROWS
WHOLE-ROW diff: 2 differing ROWS (4 diff row-sides)   = EXACTLY 2 row-sides per mode ✓
  < SVSwitch,default,CMP_NOTEQUAL,decompile:,,
  < SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
  > SVSwitch,default,CMP_EQUAL,,,differ
  > SVSwitch,testflags,CMP_EQUAL,,,differ
```

The dump-column histogram moves consistently and only there: `default` empty
327→326 / differ 242→243, `testflags` empty 331→330 / differ 298→299 — one row
per mode leaving the empty bucket, which is `SVSwitch` acquiring a dump verdict
now that it compares.

**CANARIES.**

* **`InterfaceModPort` — the protected in-family canary, checked FIRST and by
  name**, both modes, baseline then fresh:
  `CMP_EQUAL,,,differ` → `CMP_EQUAL,,,differ`, **unmoved**. It is the closest
  neighbour this pass has (`clocking cb@(posedge clock)` on an interface with a
  modport, `results/golden_surelog.csv`), and it is instantiated **once**, which
  is exactly why the law cannot reach it.
* **`BlackParrotComplex` — by name**, both modes: `CMP_EQUAL,,,differ` unmoved.
* `r10uvm52repro/canaries.sh`, **named on both corpora**: surelog
  `ok=50 changed=2 absent=0 unknown-names=7` (7 is the documented u2r-only count);
  u2r `ok=8 changed=0 absent=0`. **The 2 CHANGED rows are printed, read, and are
  exactly the intended conversion** — `SVSwitch default` and `SVSwitch testflags`,
  `CMP_NOTEQUAL/ -> CMP_EQUAL/differ`. Nothing else in either corpus moved.
* `ctcan2.sh`, **EXPECT_UNKNOWN mode-matched and baseline FIRST**: surelog
  `EXPECT_UNKNOWN=1` → `ok=58 changed=0 absent=0 unknown-patterns=1`, **PASS**;
  u2r `EXPECT_UNKNOWN=6` → `ok=1 changed=0 absent=0 unknown-patterns=6`, **PASS**.
* `canaudit.sh` → `audited=29  UNCOVERED=0  FENCE-BREACH=0`, and the four
  slang-fenced names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) are dispatched by **no** driver in this directory.

### 5.5 GATE 5 — the BYTE VERIFIER, both corpora, vs the PRISTINE `a27a874` I built

**CENSUS-PREDICT, recorded BEFORE the verifier's answer was known** (§5.5.0), then
the verifier (§5.5.1), then the per-shape table (§5.5.2).

#### 5.5.0 The prediction

`census15.sh` filters on the law's **necessary** condition — an INTERFACE carrying
a **NAMED** clocking block — and is an explicit **UPPER BOUND**, because instance
COUNT is an elaboration fact no grep can decide:

```
surelog corpus : 19 of 750 test dirs   (Escape GenerateInterface InterfaceBinding
                 InterfaceModPort SimpleInterface SplitFile TimeUnit Driver Ibex
                 Monitor OVMSwitch Opentitan SVSwitch SeqDriver SimpleUVM Tnoc
                 UVMSwitch ariane rggen)
uhdm2rtlil     :  1 of 734 test dirs   (add_sub_bind_if)
UPPER BOUND    : 20 test dirs
```

Reasoned down before measuring: the law needs **more than one elaborated
instance** of the def, and `SVSwitch` is the only listed dir known to have one
(`output_interface output_intf[4](Clock)`). `UVMSwitch` carries the identical
source line and was the named candidate for the only other possible movers.
**Predicted: 2 databases (SVSwitch × 2 modes), with UVMSwitch the one plausible
surprise.**

#### 5.5.1 The verifier

`byteverify.sh`, `SELFCHECK=1 SELFCHECK1=1`, against the pristine sweeps of the
**same** binary-to-corpus pairing:

```
uhdm2rtlil   databases: patched=679 pristine=679   PATH_SETS_IDENTICAL
             MOVERS: 0 / 679
             SELFCHECK  678/679 flagged      SELFCHECK1  1     ✓

surelog      databases: patched=953 pristine=953   PATH_SETS_IDENTICAL
             MOVER ./default/SVSwitch-db796243/slang.uhdm
             MOVER ./testflags/SVSwitch-db796243/slang.uhdm
             MOVER ./default/Scoreboard-59431470/slang.uhdm
             MOVERS: 3 / 953
             SELFCHECK  952/953 flagged      SELFCHECK1  4  (= 1 corrupted + 3) ✓
```

**REAL MOVERS: 2. `Scoreboard/default` is the documented same-size flake, and it
is PROVEN here rather than asserted.** The ops rules say "Scoreboard/default
MULTI-STABLE (same-size = flake)", so it was run **twice with each binary**:

```
file size          ship 11122503   pris 11122503     delta 0
Scoreboard run 1, SHIPPED binary   d24170f7b1ea
Scoreboard run 2, SHIPPED binary   814cba9780b8      <- SAME BINARY, DIFFERENT BYTES
Scoreboard run 1, PRISTINE binary  814cba9780b8
Scoreboard run 2, PRISTINE binary  814cba9780b8
```

The shipped binary produced **both** digests, and the one the sweep happened to
catch (`d24170f7b1ea`) is the value the *pristine* sweep also produced — the
pairing was luck of the draw, not a change. Characterised further:
`msthree.sh` between the two SHIPPED runs reports **TOTAL SHAPES MOVED = 0** (the
dump-line MULTISETS are identical) while the dumps differ by **92 lines** that are
one `svunit_pkg` task/function listing block appearing at a different position —
a pure **RE-ORDERING**, which is the emitter nondeterminism already in memory.
Its CSV row is `CMP_NOTEQUAL` on both binaries and both sweeps. **Nothing in this
pass touches package listings.**

The census's prediction was therefore **correct on SVSwitch and CONSERVATIVE on
`UVMSwitch`**, which did not move — an honest miss to record: `UVMSwitch` is
`SLANG_REJECT` in both modes, so it produces no database at all and could never
have been a mover. The upper bound was 20 dirs; the truth was 1.

#### 5.5.2 MOVERS PER SHAPE, vs GOLDEN, BY MULTISET — ADDED and REMOVED separately

`msthree.sh <golden> <pristine> <patched>` on `SVSwitch/default`. The two modes'
shipped databases are **byte-identical** (`md5 de7ab46e3f2e…` for both), so one
table serves both:

```
ADDED    FLD  ind 12   GOLD 90   PRIS 91   SHIP 94   |vpiActual:
ADDED    OBJ  ind 12   GOLD  3   PRIS  0   SHIP  3   \_bit_var: (work@top.output_intf[0].clock), line:58:38, endln:58:43
TOTAL SHAPES MOVED   2
```

**No REMOVED section at all** — the change only ever fills a null field, and the
table proves it rather than restating the code. The OBJECT shape lands on
golden's count **exactly**: `GOLD 3, PRIS 0, SHIP 3`. Three two-line insertions,
6 dump lines (25700 → 25706), **+34 bytes**, nothing else.

#### 5.5.3 The multiset distance DID NOT MOVE, and §6.7 says why

```
PRISTINE   golden-only 241   ours-only 623   MULTISET DISTANCE 864
SHIPPED    golden-only 238   ours-only 626   MULTISET DISTANCE 864
```

Split into halves, this is fully explained by the table above and is **not** a
null result: golden-only fell by **exactly 3** — the three
`\_bit_var: (work@top.output_intf[0].clock)` instances golden had and we lacked
are now matched — while ours-only rose by **exactly 3**, because the companion
line is the **bare field label** `|vpiActual:`, of which golden has 90 at that
depth and we already had 91 (our excess minted program-port views, residue **R5**,
carry the same label at the same depth). A bare label is indistinguishable
between shapes, which `msthree.sh`'s own header states, so the instrument cannot
credit the object it just got right. **The COMPARE is what converted; the
multiset distance is silent about it, and that is a property of the instrument,
not of the fix.**

---

## 6. REFUTATIONS

### 6.1 **THE BRIEF'S LAW IS TOO NARROW — arm a2, five cells**

The brief: *"golden binds the ref_obj `work@top.output_intf[N].cb.clock` for N in
1..3 via vpiActual to ELEMENT [0]'s bit_var"*, and it instructs: *"The binding
target is element [0]'s bit_var for OTHER elements"*. Every clause about **the
array** is false as a general rule:

* **d1** — `d1_if d1a(Clock); d1_if d1b(Clock);` — **no array anywhere**, and
  `d1b.cb.clock → d1a.clock`. An array-scoped rule predicts BOTH unbound.
* **d2** — the array binds to a **SCALAR**: `d2arr[0]` and `d2arr[1]` both name
  `d2s.clock`, and `d2arr[0]`'s own ref is **bound**, not unbound. An
  array-scoped rule predicts `d2arr[0]` unbound and `d2arr[1] → d2arr[0]`; **both
  halves wrong**.
* **d3** — the **scalar** binds to an array element: `d3s → d3arr[0]`.
* **d4** — the second array binds to the **first** array's element:
  `d4q[0] → d4p[0]`, so `d4q[0]` is bound where an array-scoped rule says unbound.
* **d5** — across **parent scopes**: `s2.u → s1.u`.

Had the brief's rule been transcribed literally, `d2arr[0]`, `d4q[0]`, `d3s` and
`d1b` would each have been left wrong, and `d2arr[1]` would have been pointed at
the **wrong object**. The witness cannot see any of this: every interface on it is
instantiated exactly once, so the array *is* the population there — which is
precisely why the arms are built before the code.

### 6.2 **"ELEMENT [0]" IS NOT STATABLE — arm a1 cell c7**

`c7_if c7a[5:2](Clock);` has elements 5, 4, 3, 2 and **no element 0**. Golden's
target is `c7a[2]` — the **lowest** index, not the leftmost (5) — and `c7a[2]`'s
own ref is the unbound one. c10 (`[2:5]`, where lowest and leftmost coincide)
brackets it. The brief's item (b), *"what if [0] is culled"*, has an answer: the
rule never mentions 0; it means **first elaborated**, and Surelog elaborates
ascending by index.

### 6.3 **THE OVER-FIRE ARM CAME BACK THE OTHER WAY — arm a3 cell e1**

a3 was written to catch an over-fire: keying on the clocking declaration's
**syntax node** merges two *parameterizations* of one interface, which are
different bodies. Golden **also** merges them — `e1_if #(16) e16` binds to
`e1_if #(8) e8`'s `bit_var`, and golden emits ONE def view (`work@e1_if`) for
both. So the risky key is the **correct** key, and the safe-looking alternative
(definition + parameterization) would have left `e16` **wrong**. Stated plainly:
**this pass's own safety arm refuted this pass's own safety concern**, and the
narrower key would have been the bug.

### 6.4 **"THE MODPORT" IS NOT THE DISCRIMINATOR — arm a1 cell c2**

The witness's `modport OP(clocking cb, input clock)` is not part of the rule: c2
is the identical shape with no modport at all and shows the identical defect and
the identical fix. Nor is the **carrier class** of the target: c4's clock is a
body `bit` variable rather than an ANSI header port, and the rule holds unchanged.

### 6.5 **ITEM (f) HAS NO CELL TO COMPARE — AND FOUND A DIFFERENT BUG**

The brief asks for *"non-cb signal refs in the same position"*. Arm a1 cell **c5**
(`always @(posedge clock)` in an interface, `[4]`) shows there **is** no such
position: neither golden nor we emit a per-element elaborated ref for a process's
event at all, so the law's carrier cannot be widened to "signal refs in an
interface array element" — only clocking blocks have per-element clones.

What c5 *did* find is a **separate, pre-existing, deterministic defect on the
DEF-ref half of the same idea**, identical on both binaries:

```
work@c5_if.clock   GOLDEN bit_var work@top.c5a[0].clock   OURS bit_var work@top.c5a[2].clock
work@c5_if.d       GOLDEN logic_var work@top.c5a[0].d      OURS logic_var work@top.c5a[2].d
```

Golden's def-view process refs name the **FIRST** element; ours name **`[2]`** of
four. Stable across two independent pristine runs (the whole path-normalised dump
is byte-identical), so it is a deterministic wrong-element pick, **not** a flake
and not the emitter nondeterminism recorded in memory. **R1 in §7** — and note it
is the *same sentence* as this pass's law on a third carrier.

### 6.6 **THE FIRST CUT OF GATE 1's MARKER READ ITS OWN OUTPUT WRONG**

`basemark.sh` first pulled the OURS column out of `cbcensus.sh` by awk **field
number** (`$6 $7`). `(unbound)` is ONE whitespace-separated token and
`bit_var work@…` is TWO, so the field read printed the **verdict** column for the
pristine binary and the **value** column for the shipped one:

```
  MOVER     work@top.c1a[1].cb.clock  = EQ            <- pristine, printed as if measured
  CONTROL C work@c1_if.cb.clock  = bit_var work@top.c1a[0].clock
```

A marker whose two directions are read by different rules cannot be two-directional.
Fixed **before** any number was quoted: the OURS field is now read by **fixed
column** (cols 110–143 of the census's `%-46s %-26s %-34s %-34s %s`), with the
trap written into the script's comment. This is the campaign's "a cited guard that
does not guard" failure, caught by running the marker on the **pristine** binary
first and disbelieving a green-looking row.

### 6.7 **THE MULTISET DISTANCE MOVES — BUT ONLY BY SIX**

*(§5.5.1)* Our witness dump grows by 6 lines (25700 → 25706) and the raw
`diff -u` content shrinks 1346 → 1340. Both are consistent with three two-line
`|vpiActual:` insertions per database; neither is a claim that the database is
"closer to golden" in any general sense. The **compare** is what converted.

### 6.8 WHAT THIS PASS DID **NOT** PROVE

* It did **not** prove the law for an interface whose clocking event does not
  resolve at all (a clock from an enclosing scope). Then the def ref never binds,
  `drainCbElabRefs15` copies nothing, and every elab ref stays unbound. No arm
  cell and no corpus test exercises it; the code's behaviour there is *stated*
  (nothing happens) but golden's is **unmeasured**.
* It did **not** prove anything about a **module's** named clocking block, an
  interface's **`default`/`global`** clocking block, or a **2-D** interface array,
  beyond golden's targets recorded in §3.2/§3.4. We emit none of those objects, so
  the law cannot be tested on them, and **e4 shows golden applies the same rule to
  a `default` block** — a prediction for whoever mints it, not a measurement of
  our code.
* It did **not** audit the 23 `MISSING` and 4 remaining `DIF` census cells on the
  witness (§1.3). They are `r10svs14`'s R2/R3 and class-scope naming, on another
  law's boundary, and they are **uncompared** by `uhdm-cmp` today — which is the
  only reason the design goes EQUAL with them present. A future comparator change
  can un-hide them.
* The **body-sharing** branch of §4.1's first-writer-wins guard is **unexercised**:
  every body in both corpora and all three arms is a distinct object, so the guard
  is proven to be a no-op and **not** proven to do the right thing if it ever
  fired.

---

## 7. RANKED RESIDUES

**R1 (the sharpest, and the same sentence as this pass's law).** A DEF-view
**process** ref names the WRONG element. Arm a1 cell c5:
`interface c5_if(input bit clock); logic d; always @(posedge clock) d <= 1'b0;`
instantiated `[4]` — golden's `work@c5_if.clock` / `.d` name element **`[0]`**,
ours name **`[2]`**. Deterministic, identical on both binaries, and it is exactly
"the def ref must name the FIRST elaborated instance" failing on the process-ref
carrier rather than the clocking-event carrier. Two cells, one arm, already on
disk; the fix is wherever process def refs are patched, and the first-writer-wins
shape of §4.1 is likely the whole of it. **Not on the SVSwitch path** (its
interfaces have no processes), so it blocks nothing today.

**R2 (the biggest missing producer on this carrier).** A **MODULE's** named
clocking block is **not emitted at all** — `emitNamedClockingBlocks` has exactly
two call sites, both on interfaces (`ModuleEmit.cpp:22459` def,
`:23867` elab), and `emitScopeClocking` is gated on `asModuleInst`. Arm a1 cell
**c6**, 5 cells: golden emits the def block plus one per array element, and binds
**every one of them — the def's and all four elements' — to `logic_net
work@c6_mod.clock`, the DEF's OWN net**. That is a *different* target rule from
this law (the def's own net, not the first instance's variable), so minting the
object is necessary but not sufficient; the target rule is measured and recorded
here.

**R3 (2-D interface arrays are not elaborated).** Arm a1 cell **c11**
(`c11_if c11a[2][2]`), 5 cells: we emit **no elab view at all** for
`c11a[i][j]`, so its cb refs are absent and the def ref is left unbound where
golden binds it. Golden's rule needs no extension — `c11a[0][0]` is the single
first instance and the other three bind to it — so once the views exist,
`§ cbEventRefFirstInstance15` covers them unchanged.

**R4 (an interface's `default clocking` is not emitted).** Arm a3 cell **e4**,
4 cells. `emitScopeClocking` is reached only through `asModuleInst(m)`, so an
interface's `default clocking cb@(posedge clock)` produces nothing. Golden emits
it and **applies this pass's law to it verbatim** (`e4a[1..2] → e4a[0].clock`,
`e4a[0]` unbound), so this is a pure missing-producer residue with its binding
rule already known.

**R5 (`r10svs14`'s R2, unchanged).** We MINT an `interface_inst` PORT VIEW for a
**program**'s interface port and golden has none:
`work@top.TC.{mem_intf,input_intf,output_intf[0..3]}` on the witness. On
`§ progPortIfaceArrayUnowned13`'s declared boundary; reported, not touched. Part
of the witness census's 23 `MISSING`.

**R6 (`r10svs14`'s R3, unchanged).** The unowned interface-array island's
**NAMING**: golden `output_intf.output_intf[i]`, ours
`work@top.TC.output_intf[i]` — the 4 remaining `DIF` census cells (§1.3).
Uncompared by `uhdm-cmp` today.

**R7 (`r10svs14`'s R4/R5, unchanged and unrelated to this carrier).** The NON-ANSI
header-port ORDER and the generic-port doubling over-fire, both in
`collectNetOrder` / `dblVars9`. Neither is on any cell this pass measured.

---

## 8. WHAT IS ON DISK, WHAT WAS DELETED, AND WHAT THIS DIRECTORY DOES NOT SHIP

### 8.1 LANDING HYGIENE — **there is deliberately no `README.verifier.md` here**

The brief records that `README.verifier.md` has been **misfiled twice**: a
previous pass's verifier report carried forward into a new pass's directory,
where every number in it is about a different binary. **No independent verifier
ran in this pass**, so shipping any `README.verifier.md` at all — carried forward
or invented — would be the exact failure the rule exists to prevent. This
directory therefore ships **none**, and this paragraph is the record of that
choice so that its absence reads as deliberate rather than forgotten. If a
verifier runs later, its report is what belongs at that filename, and it must
quote **`f1a2249bc847024b1bb06232ffd8bc79`** (shipped) and
**`fe6962c25b01f8e48387b1ec2dcde8ee`** (pristine) or it is about some other pass.

The scripts carried in from `r10svs14repro` (`byteverify.sh`, `msthree.sh`,
`msdist.sh`, `msmovers.sh`, `canaries.sh`, `ctcan2.sh`, `ct8rows.sh`,
`canaudit.sh`, and `svsgen.sh`) are byte-identical to their sources except
`svs15arm.sh`, which is `svs14arm.sh` with its `/tmp` tag renamed. The files
written **for** this pass are `cbcensus.sh`, `grid15.sh`, `census15.sh`,
`basemark.sh`, the three arm sources, and this README.

### 8.2 KEPT, because §1, §3 and §5 are re-readable from them without re-running
any tool

```
/tmp/r10svs15_arm_{pris,ship}_a{1,2,3}      six arm workdirs (g.dump/o.dump/cmp.log)
/tmp/r10svs15_arm_pris_a1_r2                the §6.5 determinism re-run
/tmp/r10svs15_svs_{pris,ship}               witness dumps, cmp reports, row.csv
/tmp/r10svs15_{sl,u2r}_{pris,ship}.csv      the four sweep CSVs
/tmp/r10svs15_sb_{ship,pris}_r{1,2}.csv     the four Scoreboard flake runs' rows
/tmp/r10svs15_sb_r{1,2}.dump                the two flake dumps §5.5.1 diffs
/tmp/r10svs15_{pris,ship}_{cfg,build}.log   the build logs GATE 1 quotes
/tmp/r10svs15_gold_{ship,false}.log         GATE 2's two directions
```

119 MB in total, and §1, §3, §5.5.2 and §6.5 are all re-readable from it without
re-running Surelog or either binary.

### 8.3 DELETED after the gates read them, as the ops rules require

The four SWEEP workdirs — `/tmp/r10svs15_{sl,u2r}_{ship,pris}_wd`, **774 MB**
(350+350+37+37) — were deleted once GATE 5 had read them, together with the four
`Scoreboard` flake WORKDIRS (their CSVs, dumps and digests are kept and quoted).
Every number they produced is quoted above; re-deriving them needs only the two
binaries, whose md5s are in §5.1 and which remain in their worktrees
`/tmp/wt_r10svs15` and `/tmp/wt_r10svs15pris`.

### 8.4 The arm sources the grid was measured on ARE the ones being landed

Verified by `cmp` before any number in §3 was quoted: the `.sv` files copied into
all six arm workdirs are byte-identical to the three shipped here.
