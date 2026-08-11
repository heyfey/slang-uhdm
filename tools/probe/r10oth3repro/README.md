# r10oth3 — state transfer

**Pass result: NO CONVERSION. ONE law landed, fully gated, with 7 explained byte
movers (6 attributable to the law across 3 tests, plus 1 proven-nondeterministic
`Scoreboard default`) and 0 row changes on either corpus. TARGET 2 (YosysOldOr): its cmp head —
the one r10oth1 and r10oth2 both failed to move — IS CLEARED; the test stays
CMP_NOTEQUAL on a NEW head one position behind it, and its dump residue drops
35297 -> 34673 content lines. Two neighbouring tests improve for free. TARGET 1
(Rggen): NOT DONE and DELIBERATELY NOT ATTEMPTED — all three of the brief's
candidate models are REFUTED, the real mechanism is a Surelog SELF-MODIFYING-AST
bug whose value is a function of the whole design's evaluation trace, and it is
reproduced, quantified to a closed form, and shown to be the most expensive row
on the board rather than the cheapest.**

Base commit `ed653b4`, branch `auto5h`.

Direction convention used in this file and in every note comment the patch adds:
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.

Binaries used for every number below:
* pristine `ed653b4` — md5 **`57a614326d85e6017fa021ba92336e83`**
* patched (this pass) — md5 **`6bc48eb590d1eb99c19546be740049fd`**

Both md5s were printed BEFORE and AFTER every sweep and were unchanged; no build
ran concurrently with any sweep.

---

## 0. TARGET 1 (Rggen) — THE BRIEF'S THREE MODELS ARE ALL REFUTED

### 0.1 The head, re-measured, not inherited

`uhdm-cmp <golden> <ours>` on the `default`-mode Rggen databases: **28 lines,
`grep -c '^LHS:'` at column 0 = 1 — ONE head**, and the two sides differ in the
VALUE alone. Verbatim, exactly as the brief reported it:

```
LHS(golden):  constant: , id:10103, line:30:22, endln:30:23
              |vpiDecompile:0  |vpiSize:64  |UINT:0  |vpiConstType:9
RHS(ours):    constant: , id:10179, line:30:22, endln:30:23
              |vpiDecompile:1  |vpiSize:64  |UINT:1  |vpiConstType:9
```

Censused on BOTH sides (law 2 of the brief): the object exists exactly ONCE per
database (`grep -c "constant: , line:30:22, endln:30:23"` = 1 golden, 1 ours), it
is the `vpiRhs` of `assignment 30:7-30:23 vpiOpType:24` whose `vpiLhs` is
`ref_obj work@rggen_or_reducer.get_sub_n_list.list_index`, and **the surrounding
40 dump lines are byte-identical on the two sides.** It is not an ADD and not a
`<null>` artefact: it is one field of one live object. It sits in the **DEF view**
(`uhdmallModules`, golden dump line 60880 of 1,588,369) — ONE shared object for
the whole design.

### 0.2 The one-line reproduction the brief asked for — and what it says

`carm.sh c1_compound.sv` — a module with the same statement in eight contexts,
one statement per row, read with `asgform.py`. **BOTH sides of every cell**,
golden's `uhdmallModules` listing (there are ZERO `uhdmtopModules` assignment
rows in this database — `grep -c uhdmtopModules g.asg` = 0):

| row | source line | statement | op | golden(LHS) | ours(RHS) | verdict |
|---|---|---|---|---|---|---|
| A0 | 17 | `x = 0;` (in `fa`, CALLED by a localparam) | 82 | `UINT:0 sz64 ct9` | `UINT:0 sz64 ct9` | equal |
| A1 | 18 | `x += 1;` | 24 | `UINT:1 sz64 ct9` | `UINT:1 sz64 ct9` | equal *by coincidence* |
| A2 | 19 | `x -= 1;` | 11 | **`INT:0 sz64 ct7`** | `UINT:1 sz64 ct9` | **DIFFER** |
| A3 | 20 | `x *= 2;` | 25 | **`INT:0 sz64 ct7`** | `UINT:2 sz64 ct9` | **DIFFER** |
| A4 | 21 | `x <<= 1;` | 22 | `UINT:1 sz64 ct9` | `UINT:1 sz64 ct9` | equal |
| A5 | 22 | `x += 7;` | 24 | **`UINT:8 sz64 ct9`** | `UINT:7 sz64 ct9` | **DIFFER** |
| A6 | 23 | `x += 0;` | 24 | **`UINT:8 sz32 ct9`** | `UINT:0 sz64 ct9` | **DIFFER** |
| B1..B6 | 32-37 | the SAME six statements in `fb`, which NO constant context calls | 24,11,25,22,24,24 | `1, 1, 2, 1, 7, 0` — every literal as written | `1, 1, 2, 1, 7, 0` | **all equal** |
| C1 | 49 | `x += 1;` inside `while (i<n)` in `fc`, CALLED with n=3 | 24 | **`UINT:26 sz64`** | `UINT:1 sz64` | **DIFFER** |
| C2 | 50 | `x += 7;` same loop | 24 | **`UINT:43 sz32`** | `UINT:7 sz64` | **DIFFER** |
| C3 | 51 | `i += 1;` same loop | 24 | **`UINT:4 sz64`** | `UINT:1 sz64` | **DIFFER** |
| D1..D3 | 64-66 | the same while loop in `fd`, which nobody calls | 24 | `1, 7, 1` | `1, 7, 1` | **all equal** |
| E1,E2 | 75,76 | `ey += 1; ey += 7;` in an `always_comb` | 24 | `1, 7` | `1, 7` | **all equal** |
| F1,F2 | 82,83 | `ez += 1; ez += 7;` in an `initial` | 24 | `1, 7` | `1, 7` | **all equal** |
| G1..G3 | 90-92 | `x = 1; x = 7; x = x + 1;` plain assigns in a CALLED function | 82 | `1`, `7`, `operation 24` | same | **all equal** |

That table alone refutes every model the brief offered:

1. **"Surelog rewrites `a += 1` into `a = a + 1` and the rewrite mints or
   overwrites the RHS constant."** REFUTED. There is no rewrite: golden keeps the
   compound form, encoding the operator in the ASSIGNMENT's `vpiOpType`
   (24=add, 11=sub, 25=mult, 22=lshift, 82=plain) with the bare literal as
   `vpiRhs`, and **we already match that shape everywhere.** Rows B/D/E/F prove
   the constant is untouched whenever nothing evaluates the function.
2. **"The object is not the literal at all but a reduction result carrying the
   literal's location."** REFUTED as stated — it IS the literal's object (rows
   A1/A4 keep the written value, and the plain-assign rows G1/G2 keep theirs) —
   but the RIGHT half of the guess is that a reduction result gets written INTO
   it.
3. **"The enclosing function is a constant function evaluated at elaboration and
   the value is a snapshot of some evaluation state."** This is the closest, and
   it is now EXACT rather than a guess (below). "Some evaluation state" is
   specifically *the running value of the assignment's own LHS*.

### 0.3 THE MODEL, and it is a Surelog SELF-MODIFYING AST

> **Surelog's constant-function evaluation computes `lhs <op> rhs` and WRITES THE
> RESULT BACK INTO THE RHS CONSTANT OBJECT of the UHDM tree. The write PERSISTS
> into the database, and it FEEDS BACK: the next iteration, and every later
> evaluation of the same function, reads the MUTATED literal as the operand.**

Hand-simulating that rule reproduces all eight of golden's odd values exactly:

* `fa` (straight line): x=0. `x+=1` -> 0+1=1, rhs<-1 (A1 golden 1 ✓). `x-=1` ->
  1-1=0, rhs<-0 (A2 golden 0 ✓). `x*=2` -> 0*2=0, rhs<-0 (A3 golden 0 ✓).
  `x<<=1` -> the shift FAILS to reduce, rhs stays 1 and x takes that 1 (A4
  golden 1 ✓). `x+=7` -> 1+7=8, rhs<-8 (A5 golden 8 ✓). `x+=0` -> 8+0=8, rhs<-8
  (A6 golden 8 ✓).
* `fc` (the loop, n=3, three iterations, `r` = the mutated literal):
  it1 `x+=1`: x=0+1=1, rA<-1; `x+=7`: x=1+7=8, rB<-8; `i+=1`: i=1, rC<-1.
  it2 `x+=1` reads rA=1: x=8+1=9, rA<-9; `x+=7` reads rB=8: x=9+8=17, rB<-17;
  `i+=1`: i=2, rC<-2.
  it3 `x+=1` reads rA=9: x=17+9=**26**, rA<-26 (C1 golden 26 ✓); `x+=7` reads
  rB=17: x=26+17=**43**, rB<-43 (C2 golden 43 ✓); `i+=1` reads rC=2: i=2+2=**4**,
  rC<-4 (C3 golden 4 ✓) — and i=4 is why the loop stops after three iterations.

**Seven non-trivial golden values, seven exact hits — plus two cells the model
correctly predicts to be UNCHANGED.** (CORRECTED at integration: the headline said
"nine ... nine". Only 7 of the 9 cells differ from the literal as written; rows A1
(`x+=1`->1) and A4 (`x<<=1`->1) coincide with the unmutated literal and carry NO
discriminating power. `diff g.asg o.asg` yields exactly 7 differing rows. The body
below already flagged A1 as "equal by coincidence", so this was a headline count,
not a false claim — but a headline is what the next pass reads.)

**The negative control on the corpus witness itself.** Compiling
`rggen_or_reducer.sv` ALONE — no arm file needed, just
`cp $HOME/git-repos/Surelog/third_party/tests/rggen/rggen-sv-rtl/rggen_or_reducer.sv
tools/probe/r10oth3repro/ && SLANG_UHDM=… ./carm.sh rggen_or_reducer.sv`
(the file is NOT copied into this directory: it is a verbatim third-party source
with a stable corpus path) — gives golden `line:30:7` -> `constant UINT:1 sz64
ct9` and ours the SAME, i.e. **the whole assignment table is EQUAL and line 30 is
1 on both sides.** With `N` at its default of 1 the loop runs once and the
exponent is 0, so the mutation is invisible. Rggen's `0` needs the whole design's
recursive instantiations, which is the point of §0.4's `lfc` row.

### 0.4 The closed form and the WIDTH — arm `c3_trace.sv`, five PREDICTED cells

For `x += <lit>` the recurrence is `x_k = x_{k-1} + r_{k-1}`, `r_k = x_k`, so over
K iterations from a starting literal `r0`, **`r_K = r0 * 2^(K-1)`**. Every row of
`c3_trace.sv` was PREDICTED from that before it was measured:

| row | shape | prediction | golden(LHS) | ours(RHS) |
|---|---|---|---|---|
| `lf3` line 26 | `fk(3)`, K=3 | 2^2 = 4 | **`UINT:4 sz32`** ✓ | `UINT:1 sz64` |
| `lf5` line 42 | `fk(5)`, K=5 | 2^4 = 16 | **`UINT:16 sz32`** ✓ | `UINT:1 sz64` |
| `lf33` line 58 | `fk(33)`, K=33 | 2^32 -> **0 iff the store wraps at 32 bits** | **`UINT:0 sz32`** ✓ | `UINT:1 sz64` |
| `lf65` line 74 | `fk(65)`, K=65 | 2^64 -> 0 either way | **`UINT:0 sz32`** ✓ | `UINT:1 sz64` |
| `lfc` line 94 | ONE module def, TWO instances `#(3)` and `#(5)` | cumulative: 2^((3-1)+(5-1)) = **64**, not 4 and not 16 | **`UINT:64 sz32`** ✓ | `UINT:1 sz64` |

Two things are settled by that table and both matter:

* **The store wraps at the LHS variable's own width** (`int`, 32 bits) — `lf33`
  is 0, so 2^32 truncated. That is how Rggen's `list_index` (an `int`) ends up
  worth exactly **0**: `rggen_or_reducer` is instantiated recursively many times
  across the design, the exponent accumulates past 32, and the constant
  degenerates.
* **The mutation is CUMULATIVE ACROSS INSTANCES.** `lfc` proves the def view's one
  shared function body is re-mutated by every elaborated evaluation. So Rggen's
  value is a function of the WHOLE DESIGN's evaluation order and trip counts.

### 0.5 Why Target 1 was NOT implemented — this is a REFUTATION of its ranking

To emit golden's `0` faithfully we would have to run a second, Surelog-faithful
constant-function INTERPRETER over our own UHDM, reproducing (a) Surelog's
evaluation ORDER over every instance of every module, (b) the write-back into the
RHS constant object, (c) the feedback of the mutated literal into later
iterations and later evaluations, (d) the per-operator result ENCODING the
mutation drags along (`-=`/`*=` land on `INT/ct7`, `+=` on `UINT/ct9`, size 32 or
64 depending on the path), and (e) the reduce FAILURES that leave the literal
alone (row A4's shift). The answer is not a property of the statement; it is a
property of the design.

**And the blast radius forbids the cheap version.** `c4_census.sh` (positive
control: it asserts it can find Rggen's own witness file and exits 3 if it
cannot): **114 corpus files** contain a compound assignment with a literal RHS —
7 in `Surelog/tests`, 102 in `Surelog/third_party/tests`, 5 in `uhdm2rtlil/test`
— and **53 of those 114 also declare a function.** Rows B/D/E/F above show that
the correct answer for the vast majority is the literal AS WRITTEN, which is what
we already emit. Any law that zeroed or rewrote `+= <literal>` RHS constants
would move dozens of currently-CMP_EQUAL rows to buy ONE row (Rggen's `testflags`
row is SURELOG_FAIL at baseline, so `default` is all there is).

**Verdict: Rggen is not the cheapest conversion on the board. It is the most
expensive row on the board.** Filed as residue R3 with the mechanism, the closed
form and the reproduction, so no future pass has to rediscover any of it.

---

## THE LAW

### `§ mergedPortDefRangeSymbolic` — DIRECTION: ADD a case to the DEF-view port-typespec deferral

Sites, all in `src/ModuleEmit.cpp` plus two declarations in
`include/UhdmExporter.h`:

1. new `UhdmExporter::mergedPortDeclTypeSyn9` immediately above
   `rangeRefsOverriddenParam`;
2. `rangeRefsOverriddenParam` gains a third, defaulted `synOverride` parameter
   (plus an early `return false` for the text-scanning fallback when an override
   is in play, because that fallback reads `sym.location` and would scan the
   wrong declaration's text);
3. the DEF-view port-typespec branch inside `emitPorts`;
4. `PendingNetTs` gains a `port` field, and `materializeDefNetTs` both asks the
   deferral question against the port's syntax and passes `pn.port` as
   `makeTypespec`'s `portCtx`.

**THE PREDICATE.** In the DEF (`uhdmallModules`) view of a **non-top module**
definition, a port whose declaration is a **SPLIT (Verilog-95) port/variable
pair** — the same name declared twice, once as a port and once in the body —
takes its `vpiTypedef` typespec from the **PORT declaration's** dims, and its
parameter-dependent bounds stay a SYMBOLIC operation, exactly like an ordinary
non-top def port.

**WHAT WAS WRONG.** slang's `PortSymbol::internalSymbol` points at the BODY
re-declaration, so `rangeRefsOverriddenParam(*internal, …)` — the predicate that
decides whether to DEFER the def-view port typespec to the write phase, where it
unfolds — was reading the wrong declaration:

```
or1200_du.v:113   output [dw-1:0]  spr_dat_o;    <- the head's range, reads dw
or1200_du.v:450   reg    [31:0]    spr_dat_o;    <- what internalSymbol points at
```

It saw the literal `[31:0]`, answered "no parameter", took the inline
`makeTypespec` path, and FOLDED the bound to `31`. Golden keeps the written
`dw-1`.

**THE WITNESS.** YosysOldOr, `or1200_du.v:113`, `default` and `testflags` (one
shared ours-database, md5 verified identical in both modes — see the scoring note
below):

```
LHS(golden):  operation: , id:186094, line:113:9, endln:113:13  vpiOpType:11
              |vpiOperand: ref_obj (dw) id:186093 113:9-113:11
              |vpiOperand: constant  id:186095 113:12-113:13 UINT:1 sz64 ct9
              (parent: range id:186092 113:8-113:16)
RHS(ours):    constant: , id:214153, line:113:9, endln:113:11
              |vpiDecompile:31 |vpiSize:64 |INT:31 |vpiConstType:7
```

**HOW THE GATE WAS PROVED NECESSARY.** Arm `d2_splitdecl.v`, ONE module pair per
row, one database, read with `darm.sh` + `rangeform.py`. **Both sides of every
cell**, `L=` is the range's LEFT bound (`op(11)` = the written `dw-1` kept,
`const(INT:31)` = folded):

| row | line | shape | golden(LHS) | ours BEFORE (RHS) | ours AFTER |
|---|---|---|---|---|---|
| r1 `d2_child` | 19 | `output [dw-1:0] o;` + `reg [31:0] o;`, INSTANTIATED | 1x `const(INT:31)` + 1x **`op(11)`** | **2x `const(INT:31)`** | 1x const + 1x **op(11)** ✓ |
| r2 `d2_lone` | 32 | the same split declaration, NOT instantiated (its own top) | 1x const + 1x `op(11)` | 1x const + 1x `op(11)` — **already equal** | unchanged ✓ |
| r3 `d2_par` | 40/41 | `output [dw-1:0] o;` + `reg [dw-1:0] o;` | `op(11)` at **40:8** (the PORT), const at 41:5 | `op(11)` at **41:5** (the reg), const at 40:8 — **wrong anchor** | `op(11)` at 40:8 ✓ |
| r4 `d2_wire` | 53 | `output [dw-1:0] o;` + `wire [31:0] o;`, INSTANTIATED | 1x const + 1x **`op(11)`** | **2x `const(INT:31)`** | 1x const + 1x op(11) ✓ |
| r6 `d2_ctl` | 72 | CONTROL: NO split declaration, instantiated | 2x const + 1x `op(11)` | 2x const + 1x `op(11)` — **already equal** | unchanged ✓ |

* **r6 is why the gate must require MERGED.** The identical port with no body
  re-declaration was already right, through the pre-existing predicate; widening
  past "merged" would rewrite rows that already match.
* **r2 is why the gate must keep the NON-TOP condition.** The same split
  declaration in an uninstantiated (top) def was already right too. The non-top
  condition is the pre-existing `nonTopDefP`; the law reuses it rather than
  inventing one.
* **r3 is why `pn.port` has to reach `makeTypespec`.** Without it the deferral
  already fired (the reg's own range refs `dw`) but built the typespec from the
  reg, anchoring golden's 40:8 object at 41:5. Passing the port turns on
  `makeTypespec`'s existing `mergedPort` branch and the anchor comes out right.
* **r5 was DESIGNED AND REMOVED, not silently dropped**: `output [dw-1:0] o;` +
  `reg o;` (no range) is rejected by slang outright — *"inconsistent dimensions
  declared for 'o'"* — so the cell is unmeasurable on our side and would have
  made the whole arm NO_OUTPUT. It is recorded in the arm file as a comment.

Arm `d2_splitdecl.v` goes **CMP_FAIL (1 head) -> PASS_CMP**, and all 23 of its
range definitions match golden.

**Arm `d1_portrange.v` is the REFUTATION that got me here.** Before finding the
split declaration I built the obvious five spellings — instantiated child,
uninstantiated child, ANSI header, explicit `#(16)` override, child instantiated
twice — and **all five were already PASS_CMP and equal in every range form.** The
plain shape was never broken. That is what forced the search onto what makes
`or1200_du` different from `or1200_ic_top`, which is the second declaration.

---

## THE BISECTION — 77 files down to THREE, and the brief's method was right

r10oth2 proved the DOWNWARD search was exhausted (each line-113 file alone, and
the two together with their 22-file dependency closure, are PASS_CMP) and told
the next pass to ADD files. `b5_addfiles.sh` does that. **What made it possible at
all was `--ignore-unknown-modules`**: Surelog writes a database for a file set
with dangling instances but slang rejects it (*"unknown module
'or1200_ic_tag'"*), so without the flag every non-closed subset is NO_OUTPUT and
the only testable sets are the 22-file closure and the whole design. The flag is
used on EVERY row including the full-design positive control, which still
reproduces golden 2 UNFOLDED / 3 FOLDED vs ours 1 / 4 — so it does not blind the
probe.

Rows, all measured on the pristine binary, with the AUTHORITATIVE object counter:

| row | file set | golden(LHS) | ours(RHS) |
|---|---|---|---|
| `full` | all 77 (POSITIVE CONTROL) | 5 defs: **2 UNFOLDED / 3 FOLDED** | 5 defs: **1 / 4** — defect reproduced |
| `e1_pair` | `defines + du + ic_top` | 5 defs: 2 / 3 | 5 defs: 2 / 3 — **EQUAL** |
| `e5_top_only` | `defines + top` | PROBE_BLIND (no line-113 range) | PROBE_BLIND |
| `e4_ictop_top` | `defines + ic_top + top` | 3 defs: 1 / 2 | 3 defs: 1 / 2 — **EQUAL** |
| **`e3_du_top`** | **`defines + du + top`** | **2 defs: 1 UNFOLDED / 1 FOLDED** | **2 defs: 0 / 2 — THE DEFECT IN 3 FILES** |

**MINIMAL TRIGGERING FILE SET: `or1200_defines.v` + `or1200_du.v` +
`or1200_top.v`.** And the diagnosis is in the CONTRAST: `or1200_ic_top` given the
identical treatment is equal, so "a module with a parameter-dependent port range
gets instantiated" is not the trigger. `anc.py` then named the two objects in
`e3` on both sides — `uhdmallModules / module_inst work@or1200_du / port
spr_dat_o / ref_typespec work@or1200_du.spr_dat_o` (the DEF one) and
`uhdmtopModules / or1200_top / or1200_du / port spr_dat_o` (the ELAB one) — which
said the DEF one is what flips. The last step was reading both files: `spr_dat_o`
is declared twice in `or1200_du.v` and `icqmem_dat_o` is declared once in
`or1200_ic_top.v`.

### Three FIGURE CORRECTIONS to the brief and to r10oth2

1. **"both heads below are ONE position each"** — CONFIRMED for both, by
   `grep -c '^LHS:'` at column 0: Rggen 28 lines / 1 head, YosysOldOr 56 lines /
   1 head in each mode.
2. **The `range 113:8-113:16` object count is 5 per side and the classification
   is golden 2 UNFOLDED / 3 FOLDED vs ours 1 / 4 — r10oth2's corrected figure
   REPRODUCES EXACTLY.** But its instrument was still weak (10 of 15 matches
   unclassified), so `loc113b.py` replaces it: it anchors on a range DEFINITION
   (a `\_range:` header owning a `|vpiLeftRange:` tag) rather than on the header
   text. Two counters that look right and are NOT: `grep -c` on the operation
   text counts vpiParent back-references (golden 6 hits for 2 objects), and
   counting indent-4 lines under `|vpiLeftRange:` also catches OTHER files' line
   113 ranges that start at column 9 — that one inflates golden to 2 / 8 and ours
   to 1 / 9. Both are recorded in `loc113b.py`'s docstring.
3. **"def keeps `dw-1`, elab folds to 31" does not describe the FULL design.** In
   the 77-file compile **all five objects live in the `uhdmtopModules` region of
   the dump**, in the flat weak-tail typespec pool; `grep` over the
   `uhdmallModules` region finds NO `range 113:8-113:16` at all. The def/elab
   split is real (`anc.py` shows one object reached through
   `work@or1200_du.spr_dat_o` and one through
   `work@or1200_top.or1200_du.spr_dat_o`) but it is not a dump-section split, and
   a future pass that greps by section will get zero.

### Scoring note, re-verified rather than inherited
The harness passes the SAME slang argv for YosysOldOr in both modes: the two
databases are md5-identical (`ed4fad45231232c986c8d53732a0633c` pristine,
`e695a0b12197e9d7f50ee0a3000df48d` patched, each identical across the two modes).
ONE defect scored twice.

---

## GATES — all four ran, on binary `6bc48eb590d1eb99c19546be740049fd`

1. **Build** — `cmake --build build -j 3` in this worktree: `Built target
   slang_uhdm`, no errors, no new warnings.
2. **Goldens** — `bash tests/check_goldens.sh` with `SLANG_UHDM` exported to this
   worktree's build: **PASS 23 / FAIL 0**. Negative control
   `SLANG_UHDM=/bin/false`: **PASS 0 / FAIL 23**, so the export is real and the
   `verify_golden.py:52` / `check_goldens.sh:5` main-tree default was not what got
   measured.
3. **uhdm2rtlil, mode `testflags`, `--jobs 2`, own `--out`** — **731 rows** (the
   committed CSV is 732 LINES including its header): **679 CMP_EQUAL / 50
   SLANG_REJECT / 2 SURELOG_FAIL**, dump **496 match / 183 differ / 52 blank**.
   Whole-row diff against `results/gate_uhdm2rtlil.csv`, status *and* dump
   column: **0 lines — BYTE-IDENTICAL.**
   `default` was **NOT run** (it has no committed baseline) and nothing here
   implies it was row-checked.
4. **surelog, `--mode both`, `--jobs 2`, own `--out`** — **1588 rows** (the
   committed CSV is 1589 LINES including its header):
   * `default` **467 CMP_EQUAL** / **13 CMP_NOTEQUAL** / 5 DEFERRED / 284
     SLANG_REJECT / 25 SURELOG_FAIL; dump **match 225** / differ 242.
   * `testflags` **463 CMP_EQUAL** / **10 CMP_NOTEQUAL** / 5 DEFERRED / 286
     SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1
     TIMEOUT / 1 NO_UHDM; dump **match 165** / differ 298.
   * Every one of those cells equals the brief's `ed653b4` baseline exactly; the
     match counts did NOT fall.
   * Whole-row diff against `results/golden_surelog.csv`, all 1588 rows:
     **0 lines — BYTE-IDENTICAL.** No conversion and no regression.
   * The known `Google,testflags` golden-side environment flake did NOT differ
     from the baseline this run. Named, not filtered.

**BYTE VERIFIER** — every `slang.uhdm` from the pristine-`ed653b4` binary
byte-compared against the patched one, **both runs writing to the SAME workdir
paths** (`/tmp/r10oth3_sl_wd`, `/tmp/r10oth3_u2r_wd`), patched first and
snapshotted before the pristine run overwrote them. **1632 databases per side**,
and the verifier asserts the two path SETS are identical before reporting (a
"no movers" reading otherwise cannot be distinguished from paths that failed to
line up). **7 movers, every one explained:**

| mover | explanation |
|---|---|
| `default/YosysOldOr`, `testflags/YosysOldOr` | **the intended target.** ONE database counted twice. Head cleared; dump-diff **35297 -> 34673** content lines, **2088 -> 2061** hunks (`mover.sh`, content = `grep -c '^[-+]'` minus the two `diff -u` header lines — the brief's "35,299" is the same number in the header-inclusive convention). |
| `default/YosysBigSimReed`, `testflags/YosysBigSimReed` | **the same law, unasked-for improvement.** Row is `CMP_EQUAL` + dump `differ` in the baseline AND now, so the CSV diff is blind here; measured directly, dump-diff **1128 -> 1056** content lines, **48 -> 45** hunks. The vanished hunks are exactly this law's shape: golden `logic_typespec 27:8-27:24` where pristine-ours had `29:1-29:21` (the body re-declaration) and patched-ours now has 27:8-27:24. |
| `default/YosysOldOpen`, `testflags/YosysOldOpen` | **the same law again.** `CMP_EQUAL` + `differ` before and after; dump-diff **17171 -> 17157** content lines, **585 -> 583** hunks. Same vanished shape (`work@omsp_mem_backbone.dmem_addr`: golden `91:8-91:15`, pristine-ours `147:1-147:13`, patched-ours `91:8-91:15`). |
| `default/Scoreboard` | **the known intermittent UVM nondeterminism, PROVEN not asserted.** `scoreboard_nondet.sh` (committed by r10oth2) run 4x per binary: the PATCHED binary emitted `903283c8, c23b73e6, 903283c8, 903283c8` and the PRISTINE binary emitted `903283c8, 903283c8, c23b73e6, 903283c8` — **each binary disagrees with itself, and both emit the SAME TWO md5s**, which are precisely the two the byte verifier reported as the "move". Consistent with the recorded mechanism (SourceLocation compares across macro buffers flipping per run under parallel parse). Not cited in any identity control, and a single run of it would have been worthless in either direction. |

As a positive control on the harness invocation itself, the PRISTINE sweeps
reproduced BOTH committed baseline CSVs exactly (empty whole-row diffs), so the
zero-row-change reading is a real measurement and not a driver that cannot see
its probe.

**CANARIES, checked individually as rows** against the committed baselines
(by direct row comparison — **NOTE, corrected at integration: this originally
cited a `canary.sh` that DOES NOT EXIST in this directory.** The canary RESULT is
correct and was independently reproduced by the pass verifier with its own script,
but the cited instrument was absent, which is exactly the missing-control-asset
failure class this campaign keeps hitting. Citation removed rather than a script
invented after the fact.): all 25 named tests plus the `EvalFunc*` (10 rows), `ParamFile*`
(8 rows) and `Black*` (34 rows) families, in both corpora — **every row
IDENTICAL**. Specifically:
* **`InterfaceModPort`** (the `b33d11b` conversion): `CMP_EQUAL` both modes ✓
* **`BlackParrotComplex`** (the `ed653b4` conversion, the fragile one): **`CMP_EQUAL`
  both modes, dump `differ`, unchanged** ✓ — and its byte-identity is confirmed
  independently by the byte verifier, which lists it as a NON-mover, so the
  traversal-order hazard recorded in r10oth2 (the live ELAB `param_assign` Rhs
  KIND difference at `work@top.routing_matrix_p` that this conversion depends on
  `Compare` not walking) was not disturbed.
* `InterfaceBinding` / `InterfaceModExp` / `BindHierPath` / `EnumConcat` /
  `LowMemPkg` keep `CMP_EQUAL` + dump **`match`** — the strongest available
  control, since any byte change there flips the dump to `differ`.
* `Earlgrey_0_1` unchanged (`default` CMP_NOTEQUAL / `testflags` SLANG_REJECT).
* The four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) were never dispatched as targets; they are ordinary corpus rows and
  match the baseline.

Neither baseline CSV was rebuilt, edited, or included in the patch. `git stash`
was never used. No `out/` directory is committed; every arm writes under
`/tmp/r10oth3_*`.

---

## REFUTATIONS

1. **"Rggen … the cheapest conversion on the board … ROW VALUE: ONE row."**
   The ONE row is right; "cheapest" is REFUTED. The value is produced by a
   Surelog self-modifying-AST bug that is cumulative across every elaborated
   evaluation of the enclosing constant function, wraps at the LHS variable's
   width, and therefore depends on the whole design's evaluation trace. See §0.
2. **All three of the brief's candidate models for Rggen.** The compound-assign
   REWRITE does not happen (golden keeps `vpiOpType` on the assignment and the
   bare literal as Rhs, and we already match); the object IS the literal, not a
   reduction result borrowing its location; and "a snapshot of some evaluation
   state" is specifically *the running value of the assignment's own LHS, written
   into the literal's object*.
3. **"`+=` and friends are everywhere in a 97%-equal corpus, so we clearly
   already match golden for the ordinary case, OR this shape is rare."** The
   first disjunct is right and now measured: 114 corpus files carry the shape, 53
   of them with functions, and rows B/D/E/F show the ordinary answer is the
   literal as written, which we emit. The shape is NOT rare — which is exactly
   why the emitter law would have been too wide.
4. **"THE METHOD THAT IS LEFT: bisect the file list UPWARD … using a
   POSITIVE-CONTROLLED counter (b4_pair113.sh already has one — reuse it)."**
   The method was RIGHT and it worked in five compiles. Two corrections: the
   upward bisection is IMPOSSIBLE without `--ignore-unknown-modules`, because
   slang rejects every dependency-open subset; and `b4_pair113.sh`'s counter is
   a `grep` LINE counter, not an object counter (it reports 6/3 where the objects
   are 2/3), so `loc113b.py` replaced it.
5. **"AN ID WALK OR INSTRUMENTATION, NOT DUMP GREPPING — the two candidate sites
   are textually identical so no textual measurement can separate them."**
   Correct in spirit, and the separation came from `anc.py`'s ancestor walk. But
   no id walk was needed in the end: the CONTRAST between two three-file compiles
   (`e3_du_top` fails, `e4_ictop_top` passes) separated the two sites, and then
   READING THE TWO SOURCE FILES gave the distinguisher.
6. **"def keeps `dw-1`, elab folds to 31"** — true as a rule, false as a
   description of where the objects live in the full-design dump. See correction 3
   above.
7. **r10oth2's R1 next-step guess ("an id walk from the design root to golden id
   186092 / our id 214152")** was not what cracked it and would have been slow;
   the cheap step was the 3-file contrast.

---

## RANKED RESIDUE (most reachable first)

### R1. YosysOldOr's NEW head: a REPLICATION constant's digit string. Direction: REPLACE. Depth: shallow. NEWLY EXPOSED by this pass and fully characterised.
This is the head that now blocks YosysOldOr's 2 rows. Witness
`or1200_dc_tag.v:99` `assign tag = {dw-1{1'b0}};` with `parameter dw =
`OR1200_DCTAG_W+1;` = 22 and `output [dw-3:0] tag;` (20 bits):
```
LHS(golden):  constant BIN:000000000000000000000  (21 digits)  vpiSize:20  ct3
RHS(ours):    constant BIN:00000000000000000000   (20 digits)  vpiSize:20  ct3
```
Arm `d3_replwidth.v`, five rows, BOTH sides:

| row | source | golden(LHS) | ours(RHS) |
|---|---|---|---|
| `d3_narrow` | `{dw-1{1'b0}}` dw=22 (21 reps) into `[19:0]` | sz 20, **21** digits | sz 20, 20 digits |
| `d3_lit` | `{21{1'b0}}` into `[19:0]` | sz 20, **21** digits | sz 20, 20 digits |
| `d3_exact` | 20 reps into `[19:0]` | sz 20, 20 digits | sz 20, 20 digits — **EQUAL** |
| `d3_wide` | 21 reps into `[31:0]` | sz **21**, 21 digits | sz **32**, 32 digits |
| `d3_ones` | `{dw-1{1'b1}}` into `[19:0]` | sz 20, **21** ones | sz 20, 20 ones |

**The law those five cells state:** golden's replication constant carries exactly
`count` digits (its own natural width, never widened and never truncated) and a
`vpiSize` of `min(count, target width)`. We use the TARGET width for BOTH. The
`d3_lit` row proves it is not about the parameter, and `d3_exact` is the
equal-width control. A constant's value string is a `Compare` field, so this is
cmp-visible. NOT attempted here: it rewrites replication constants corpus-wide
and the gates would have to be re-run; and with 34,673 dump-diff lines still in
that database, clearing one more head is unlikely to convert the test in one pass.

### R2. `materializeDefNetTs` builds a deferred def-net typespec with NO port context in general. Direction: ADD. Depth: shallow. PARTIALLY closed by this pass.
`PendingNetTs.port` is set ONLY at this law's site, deliberately, so the change
could not touch any other pending net. Arm `d2_splitdecl.v` row r3 shows the
class: before the patch, a split declaration whose BODY range also refs the
parameter deferred correctly but anchored the operation at the reg (41:5) instead
of the port (40:8). That specific cell is fixed *because* the new gate also
covers it, but any other route into `materializeDefNetTs` for a merged port still
has no port context. Widening means setting `pn.port` on the merged-port pushes
at `ModuleEmit.cpp:942` too, which was not measured and so was not done.

### R3. Rggen / Surelog's self-modifying compound-assignment RHS. Direction: REPLACE. Depth: DEEP (a second evaluator whose answer depends on whole-design evaluation order). Fully characterised, HONESTLY NOT DONE.
Everything needed is in §0: the mechanism, the closed form `r_K = r0 * 2^(K-1)`,
the 32-bit (LHS-width) wrap that produces Rggen's `0`, the cumulation across
instances, the encoding drift (`-=`/`*=` -> `INT/ct7`; sizes 32 and 64 both
occur), the reduce failure that exempts `<<=`, and the 114-file / 53-function
blast radius that forbids a cheap approximation. Worth ONE row (`Rggen,default`;
its `testflags` row is SURELOG_FAIL at baseline). **Rank it LAST among reachable
work, not first.**

### R4. Golden's mutated constants also change SIZE and ENCODING, and the pattern is not modelled. Direction: REPLACE. Depth: shallow, but only meaningful after R3. Measured, not fixed.
Within one arm run golden produces `INT:0 sz64 ct7` (`-=`, `*=`), `UINT:8 sz64`
(`+= 7`) and `UINT:8 sz32` (`+= 0`) — same statement kind, different size — and
in `c3_trace.sv` every mutated constant is `sz32` while every unmutated one is
`sz64`. Whatever picks 32 vs 64 is unexplained; a future pass working R3 must
decide it, and a law that only ever saw one size has an unmeasured half.

### R5. NAMED-type split port declarations are refused by the new gate. Direction: ADD. Depth: shallow. UNMEASURED half, declared rather than hidden.
`rangeRefsOverriddenParam`'s text-scanning fallback (for packed dims written
after a named type, `st_t [P-1:0] a`) reads `sym.location` and `dt0->getType()`,
which describe the BODY declaration; mixing those with an overriding PORT syntax
would scan the wrong text. The new code therefore returns false there rather than
guess. Every witnessed split port declaration is an `ImplicitType` (`output
[dw-1:0] x;`) or an `IntegerType` (`output reg [dw-1:0] x;`), both handled — but
`module m(o); parameter P=8; output st_t [P-1:0] o; st_t [7:0] o;` was never
built, so that half of the law is UNMEASURED.

### R6. YosysOldOr is still 34,673 dump-diff content lines in 2,061 hunks. Direction: mixed. Depth: not shallow.
A CMP_EQUAL needs the heads one at a time (R1 next); a DUMP_MATCH needs all of it.
The residue is dominated by weak-tail `logic_typespec` ordering and by
present/absent typespec subtrees at other lines. Recorded so "one cmp head" is not
mistaken for "nearly equal".

---

## Assets in this directory

| file | what it is |
|---|---|
| `carm.sh` | one-source arm driver for TARGET 1: Surelog + ours, cmp (with a column-0 `^LHS:` head count), dump diff, and a per-`assignment` `vpiOpType`+Rhs-form diff. **REQUIRES `SLANG_UHDM`** — no default. |
| `asgform.py` | prints `{view, span, vpiOpType, Lhs, Rhs form}` for every `assignment` in a `uhdm-dump`. `--expect N` is its POSITIVE CONTROL. The instrument the whole §0 table was read with. |
| `c1_compound.sv` | 8 contexts x the same compound assignment: constant function that IS called, one that is not, in a while loop and straight-line, `always_comb`, `initial`, and plain-assign controls. This is the one-file reproduction of "golden gives this literal a different value". |
| `c3_trace.sv` | the quantifier: K=3, 5, 33, 65 and a two-instance cumulation row, each with a closed-form PREDICTION. Pins the wrap width at the LHS variable's 32 bits and proves the mutation is cumulative across instances. |
| `c4_census.sh` | the TARGET 1 blast-radius census (114 files / 53 with functions), with a positive control that asserts it can see Rggen's own witness file. |
| `darm.sh` | one-source arm driver for TARGET 2, same shape as `carm.sh` but reading packed-RANGE bound forms. |
| `rangeform.py` | prints `{view, range span, left-bound form, right-bound form}` for every range DEFINITION in a dump; skips vpiParent back-references. `--expect N` positive control. |
| `loc113b.py` | the AUTHORITATIVE YosysOldOr counter: classifies every `range 113:8-113:16` DEFINITION as UNFOLDED/FOLDED with its view and dump line. Its docstring records the three wrong counters this replaces. |
| `anc.py` | prints the ancestor chain (and the enclosing view marker) of any dump line number. This is what named which of the five line-113 objects belongs to the def view and which to `work@or1200_top.or1200_du`. |
| `b5_addfiles.sh` | the UPWARD bisector. Takes any file list (or `@listfile`), compiles it with both tools the way the harness's `testflags` row does, and prints the authoritative fold classification for both sides. Carries the `--ignore-unknown-modules` note and a real PROBE_BLIND positive control (with a note on the `X=$(cmd \| sed)` trap that made an earlier version's guard dead). |
| `d1_portrange.v` | the five OBVIOUS spellings of a parameter-dependent port range, all of which were ALREADY equal. The refutation that forced the search onto the split declaration. |
| `d2_splitdecl.v` | the law's gate arm: split declaration vs not, instantiated vs not, reg vs wire, literal vs parameter body range, plus the removed-and-recorded `reg o;` cell. |
| `d3_replwidth.v` | residue R1's arm: the replication-constant digit-count/size grid, five rows. |
| `mover.sh` | the MOVER EXPLAINER: builds one test with both binaries into separate workdirs and reports each one's dump-diff size against the same golden. This is how a byte mover inside an already-`differ` row is shown to move TOWARD golden. Requires BOTH `SLANG_UHDM` and `PRISTINE_UHDM`. |

`scoreboard_nondet.sh` and `b4_pair113.sh` were reused from
`tools/probe/r10oth2repro/` unchanged.

### Reading conventions used above, stated once
* Every `DUMP_DIFF` number printed by `carm.sh`/`darm.sh` is `grep -c '^[-+]'`,
  i.e. **content + 2** (it counts the two `diff -u` file-header lines); the driver
  says so on the line it prints. Every dump-diff figure in the GATES and RESIDUE
  sections above is **content only**, with the two header lines subtracted.
* Every "rows" figure is CSV **lines minus one** for the header: 732 lines = 731
  rows, 1589 lines = 1588 rows.
* Head counts are `grep -c '^LHS:'` at **column 0**.


## Corrections applied at integration by the master (pass-49-era verifier findings)

Four documentation corrections, each re-checked before applying:

1. **Byte-mover count**: the header said 6, the body said 7 and listed 7. The
   truth is **7** — 6 attributable to the law across 3 tests, plus one
   proven-nondeterministic `Scoreboard default`. Header fixed.
2. **`canary.sh` did not exist.** Confirmed absent by `ls` in this directory; the
   patch ships 15 probe files and that is not among them. The citation is removed
   rather than back-filled with a script written after the measurement.
3. **`d3_replwidth.v` (residue R1's five-cell arm) HAS NO WORKING DRIVER.**
   `carm.sh` exits `INSTRUMENT_BLIND_GOLDEN` on it (`asgform: PROBE NOT FOUND` —
   the arm has no procedural `assignment` objects at all), and `darm.sh` /
   `rangeform.py` read RANGES, not replication constants. The five-row R1 table is
   nevertheless CORRECT — the verifier checked all five cells by hand off
   `g.dump`/`o.dump`, and so must the next pass. **Read d3 by direct dump
   inspection, or write a `replform.py` first.** Credit where due: the positive
   control FIRED rather than printing perfection, which is the whole point of
   having one.
4. **The "nine values" headline overstated by two** — see the corrected heading
   above.

Also applied, from the same verifier, a **zero-risk narrowing of the production
code** (not a documentation fix): `src/ModuleEmit.cpp` computed
`mergedPortDeclTypeSyn9` and its `rangeRefsOverriddenParam` UNCONDITIONALLY,
before the `!topView && module_inst` test. In the TOP view `nonTopDefP` is false so
the `anyParam` early-out does not fire, which meant the patched binary performed an
`Expression::bind` on a split port declaration's range bounds that the pre-patch
binary never performed, plus an O(module-members) scan per merged port. Empirically
harmless — but there is no reason to run it outside the gate, so both are now
inside the same `if`. The master re-gated the whole patch after this change rather
than inheriting the pre-narrowing gate results.

### One BASELINE HYGIENE finding, not caused by this pass — worth knowing before it
### is mistaken for a regression
`results/golden_surelog.csv`'s `LowMemPkg,testflags` row embeds an ABSOLUTE
SESSION-SCRATCHPAD PATH in its detail field
(`…/c0e9d6be-dba9-45c9-a681-e7a0c848a435/scratchpad/undef_bb0`). It reproduces
identically within this session, so every whole-row judge in this block is sound —
but that row is ENVIRONMENT-COUPLED and will differ under any other session id. A
future verifier will report it as a phantom regression. Left as-is deliberately:
editing the authoritative baseline outside a deliberate promotion is against the
campaign's own rule.
