# r10oth5 — state transfer

**Pass result: NO CONVERSION, and — said plainly up front — ZERO CORPUS MOVERS.
FOUR laws in two families, all in `src/ModuleEmit.cpp`, all measured on both
sides of ~220 arm cells, and the byte verifier says they change NOT ONE BYTE of
either corpus. Residue R1 from r10oth4 — the one whose direction the previous
pass INVERTED and the master corrected — is CLOSED: I re-measured it myself off
the dumps, CONFIRMED the corrected direction, and implemented it. The two C5
residues are also closed, and MY MEASUREMENT REFUTES ONE HALF OF THE C5 REPORT
AND THE OBVIOUS READING OF THE OTHER.**

**THE PASS'S MOST USEFUL OUTPUT IS PROBABLY ITS THREE REFUTATIONS**, two of them
caught by the ROW GATES on an intermediate binary whose ARMS WERE CLEAN
(`TypespecExpr`, then `2DFunctionArg` + `ClogCast`). Those three rows were the
laws' ONLY corpus reach, and all three moves were WRONG; the guards that fixed
them are what leaves the final reach at zero. A master who wants a minimal patch
can drop family two (§2) without touching family one, and vice versa.

Base commit `6744b86`, branch `auto5h`.

Direction convention, used in this file and in every note comment the patch adds:
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.

Binaries. Every figure below names the one that produced it.
* pristine `6744b86` — md5 **`4a5ef68fd946f278d0918993bef58829`** (built twice
  from two different trees, same md5 both times — see §5).
* patched, FINAL — md5 **`190fa2eda33082098e559c74d236f429`**.
* three intermediates are named where they matter, so nobody mistakes one set of
  figures for another:
  `8186b9473f3ec257b843e0277654e20e` (the cut that REGRESSED `p9_replvalue`),
  `d55f81def8734d17cf1713ba8094fc7e` (family one only — the binary the
  `TypespecExpr` regression was found on), and
  `190fa2eda33082098e559c74d236f429  <!-- CORRECTED AT INTEGRATION: this cited 443733953ead05ce3e7677217ec4ae5f, which this same README defines as family two's FIRST CUT -- the binary the 2DFunctionArg and ClogCast regressions were found on. Every figure here reproduces on the FINAL binary. -->` (family two's first cut — the binary the
  `2DFunctionArg` and `ClogCast` regressions were found on).
  **Every gate figure in §3 is the FINAL binary's**, and every sweep was re-run
  from scratch on it. The md5 was printed before AND after every sweep and never
  changed within one; the pristine control binary lives in a SEPARATE build tree
  so no rebuild ever raced a sweep.

---

## 0. THE TARGET, RE-MEASURED FROM SCRATCH — the corrected direction is CONFIRMED

Order-of-work item A was "re-measure the `d1_paramref` cell YOURSELF, both views,
both sides, off the DUMPS". Done, on the pristine binary, with the whole witness
in one file. `diff -u g.dump o.dump` is **exactly two content hunks plus one
orphan typespec** and nothing else:

```
 uhdmtopModules … param_assign … vpiRhs … \_constant: , line:2:22, endln:2:27
       |vpiParent:
-      \_cont_assign: , line:4:8, endln:4:13        <- golden: the CONT_ASSIGN
+      \_param_assign: , line:2:18, endln:2:27      <- ours:   the PARAM_ASSIGN

 uhdmtopModules … cont_assign … |vpiRhs:
     \_constant: , line:2:22, endln:2:27            <- golden: BACK-REFERENCE, stop
+      |vpiParent: \_cont_assign …                  <- ours:   a SECOND object,
+      |vpiDecompile:5  |vpiSize:20  |UINT:5           printed in full
+      |vpiTypespec: … vpiActual: \_int_typespec: , line:2:1, endln:2:27
+      |vpiConstType:9
```

So, both views quoted separately as the method laws demand:

| | golden (LHS) | ours (RHS), pristine |
|---|---|---|
| **DEF** (`uhdmallModules`) cont_assign vpiRhs | `ref_obj (work@d1_paramref.Q) 4:12-4:13` | **identical — ALREADY EQUAL** |
| **ELAB** (`uhdmtopModules`) param_assign vpiRhs | `constant 2:22-2:27` HEX:5 ct5 `20'h5` sz20, ts -> LOC-LESS `logic_typespec`, **vpiParent = the cont_assign** | byte-identical EXCEPT vpiParent = the param_assign |
| **ELAB** cont_assign vpiRhs | **the SAME OBJECT, by reference** | a **SECOND** constant, UINT:5 ct9 `5`, ts -> LOCATED `int_typespec` |

**The master's correction is right and the r10oth4 write-up's "add a bail" was
inverted.** The fold is correct; the OBJECT IDENTITY and ENCODING were wrong.
There is no suppressing guard to go looking for, exactly as the brief said.

### The instrument that made this readable, and why the old one could not

`r10oth4repro/replform.py` deliberately skips BACK-REFERENCE subtrees, so
golden's `cont_assign -> vpiRhs` row is INVISIBLE to it and `rtab.sh` renders the
cell empty. This pass ships **`caform.py`**, which flattens the dump into one row
per NODE and marks each `DEF` (printed in full — this is the object's definition
site) or **`REF` (printed by reference — a BACK-REFERENCE)**, because "the two
edges point at ONE object" is the fact under measurement. `ptab.sh` joins the two
sides per `(view, module, path)` cell and prints
**`UNMEASURED(no such row on this side)`** where a side has no row at all — the
thing `rtab.sh` could not do and the reason r10oth4's R1 got a guess.

The DEF/REF rule is one line of dump grammar: a payload header sits at the SAME
indent as its edge and its children at indent+2, so **a payload with no line at
indent+2 after it is a back-reference**. `caform.py --expect N` is a real
positive control (exit 3), and `parm.sh` pipes both dumps through `sed 1d`
because uhdm-dump's first line is the database path.

---

## 1. FAMILY ONE — the ELAB cont_assign reuses the parameter's own constant

### `§ elabCaReusesParamValueConst` — DIRECTION: REPLACE (REUSE, not a bail, not a mint)

Two hunks in `src/ModuleEmit.cpp`, both inside `UhdmExporter::emitContAssigns`
(grep the § name; the eligibility block sits immediately after
`bool unbasedShareRhs`, the reuse itself immediately after the
`unbasedSharedPaConst` block that is its narrow ancestor).

**THE LAW.** Surelog's `substituteAssignedValue` hands the reading cont_assign
the PARAMETER'S OWN value-constant object, and `CompileHelper::adjustSize`
(`Surelog/src/DesignCompile/CompileHelper.cpp:3949`) then mutates it IN PLACE
against the assignment target. One object serves both `vpiRhs` edges; its
`vpiParent` is claimed by the LAST cont_assign that reads it.

**THE GATE, and it is adjustSize's `uniquify` clone set, transcribed not
guessed.** `adjustSize` calls `clone_tree(c)` under `uniquify` in exactly three
arms — `vpiUIntConst`, `orig_size == -1`, and signed-binary-with-MSB — and
MUTATES `c` in place in every other. A clone is a fresh object, which is what we
already emit. So the reuse fires only for a **non-UINT, sized** constant.

Three more conjuncts, each with the cell that proves it necessary:

| conjunct | why, and the witness |
|---|---|
| `VpiConstType() != vpiUIntConst` | `p4_untyped_unsized`, `p8_opvalue`, `p15_int`, `q5_unbased` — all UINT-encoded, golden MINTS A FRESH constant for all four, and we already matched all four. Without this the law would have broken four equal cells. |
| `VpiSize() != -1` | the unbased forms are `§ unbasedSharedPaConst`'s, already landed; `q5b_unbased_zero` is the control and is untouched. |
| NOT a PACKAGE parameter | `q8_pkgref` / `q9_import`: golden's **DEF view already folds** that read to a HEX constant carrying the REFERENCE's span, and the ELAB view shares THAT object, not the package param_assign's. A different mechanism; we already match the def half. Filed as residue R2. |
| `!elabReadNoValue9 && !aggActualParamRef` | **THE REGRESSION GUARD — see §1.3.** |

The `!caReuseParamConst9` term added to the def-CA share test is what makes the
reuse REACHABLE for rows whose value has UNKNOWN bits (`p22_unknown`), whose type
is string/real (`q6_string`, `q7_real`) or that have a SELECT Lhs
(`q13_sel_lhs`): those keep `typedParamRhs` null and would otherwise share the
def cont_assign whole, where golden emits a fresh one with a by-reference Rhs.
**Proved necessary**: without the term those cells stay `UNMEASURED` on our side
(no elab Rhs row exists at all).

**THE SIZE HALF, and it is a DELIBERATE MUTATION OF A NOW-MORE-SHARED OBJECT.**
The brief's standing law is "never mutate a shared object"; here golden's own
producer does, and both mutations are REQUIRED, not incidental:
* `vpiParent` := the reading cont_assign. `p2_twice` pins LAST-writer: with two
  cont_assigns golden's parent is the SECOND one.
* `vpiSize` := the target NET's width for every encoding except binary and
  decimal — and the change is visible on the PARAM_ASSIGN row too, which is the
  whole point: `p6_narrow` (param 20 bits, net `[3:0]`) golden's param_assign Rhs
  is **sz 4**; `p7_wide` (net `[31:0]`) **sz 32**.
* a BINARY constant instead takes adjustSize's logic arm, which TRUNCATES ONLY
  (`orig > target`) and writes a **BARE** decompile: `q1_bin_narrow` 20 -> 4
  digits IN PLACE; `q2_bin_wide` is the control that keeps 20 against a 32-bit
  target.
* the target width comes from the LHS **base net**, selects stripped:
  `q13_sel_lhs` (`assign t[7:4] = Q`) leaves golden's constant at the NET's 20,
  not the select's 4.

### `§ replParamConstClampsToDeclWidth` — DIRECTION: REPLACE. Same site.

A REPLICATION-valued parameter's constant still carries its NATURAL width at the
cont_assign (21 for `parameter [19:0] R = {21{1'b1}}`); Surelog's param-side
adjustSize already clamped it to the DECLARED width through the int_typespec
arm's `VpiSize(min(orig,size))`, which never touches the digits — golden is
**size 20 with 21 digits and `vpiDecompile:20'b1…1`**. See §1.2 for why this had
to be written down rather than inherited.

### 1.1 THE ARM — BOTH SIDES OF EVERY CELL

`p1_paramref.v`, 34 modules, read with `parm.sh` + `caform.py` + `ptab.sh`.
Every row is the **ELAB** (`uhdmtopModules`) view; the DEF view is `ref_obj` on
both sides in every `p*` cell and was checked separately (0 differing DEF cells).
`REUSE` = golden prints the cont_assign's Rhs as a BACK-REFERENCE to the
param_assign's constant. Sizes are the param_assign Rhs constant's.

| cell | source | golden(LHS) | ours BEFORE (RHS) | ours AFTER |
|---|---|---|---|---|
| `p1_bare` | `[19:0] Q = 20'h5`, net 20 | **REUSE**, sz20 | fresh UINT:5 ct9 | REUSE ✓ |
| `p2_twice` | the same, read by TWO CAs | REUSE by both; parent = the **2nd** | two fresh | REUSE, parent 2nd ✓ |
| `p3_untyped_sized` | `Q = 20'h5` | REUSE | fresh | REUSE ✓ |
| `p4_untyped_unsized` | `Q = 5` | **FRESH** (UINT: clone arm) | fresh — **already equal** | unchanged ✓ |
| `p5_localparam` | `localparam` | REUSE | fresh | REUSE ✓ |
| `p6_narrow` | net `[3:0]` | REUSE, **sz 4** | fresh; pa sz20 | REUSE, pa sz4 ✓ |
| `p7_wide` | net `[31:0]` | REUSE, **sz 32** | fresh; pa sz20 | REUSE, pa sz32 ✓ |
| `p8_opvalue` | `Q = 20'h4 + 1` | **FRESH** (UINT) | fresh — already equal | unchanged ✓ |
| `p9_replvalue` | `R = {21{1'b1}}` | REUSE, sz20 / 21 digits / `20'b…` | fresh UINT | REUSE ✓ (see §1.2) |
| `p10_in_op` | `assign t = Q + 1` | CONTROL: fresh op fold | equal | unchanged ✓ |
| `p11_select` | `assign t = Q[3:0]` | CONTROL: golden folds `BIN:1110 sz4` | **UNMEASURED** (we share the def CA) | unchanged — residue R3 |
| `p12_proc` | procedural read only | CONTROL: no CA | equal | unchanged ✓ |
| `p13_child/top` | read as an instance PORT actual | CONTROL: no fold | equal (but see R5) | unchanged ✓ |
| `p14_child` | param OVERRIDDEN at the instance | REUSE | fresh UINT:7 | REUSE ✓ |
| `p15_int` | `parameter int Q = 5` | **FRESH** (UINT) | already equal | unchanged ✓ |
| `p16_child` x2 | SAME module, two instances, two overrides | REUSE **per instance** (1 and 2) | two fresh | REUSE, per instance ✓ |
| `p17_alsoparam` | also read by another param's init | REUSE | fresh | REUSE ✓ |
| `p18_chain` | `A`, then `B = A`, `assign t = B` | REUSE of **B's** constant | fresh | REUSE ✓ |
| `p19_signed` | `signed [19:0] Q = -20'sd5` | REUSE, INT:-5 sz20 | fresh INT:-5 | REUSE ✓ |
| `p20_bit` | `parameter bit Q = 1'b1`, scalar net | REUSE, BIN:1 sz1 | fresh UINT:1 | REUSE ✓ |
| `p21_w68` | 68-bit param | REUSE, sz68 | fresh UINT (68-bit decimal) | REUSE ✓ |
| `p22_unknown` | `Q = 20'hABCDX` | REUSE, HEX:ABCDX | **UNMEASURED** (def-CA share) | REUSE ✓ |

`q1_spellings.v`, 20 more modules, the OTHER SPELLINGS ("a law that only ever saw
one spelling has an unmeasured half"):

| cell | source | golden(LHS) | ours BEFORE | ours AFTER |
|---|---|---|---|---|
| `q1_bin_narrow` | BIN value, net `[3:0]` | REUSE; **digits truncated 20 -> 4 IN PLACE**, decompile BARE `1010`, sz4 | fresh UINT:10; pa BIN 20 digits sz20 | REUSE + truncation ✓ |
| `q2_bin_wide` | BIN value, net `[31:0]` | REUSE, **sz stays 20** (no truncating arm) | fresh UINT | REUSE ✓ |
| `q3_dec` | `20'd5` -> ct7 INT | REUSE, **sz 4** (target) | fresh; pa sz20 | REUSE, pa sz4 ✓ |
| `q4_signed_bin` | `signed [3:0] Q = 4'sb1000`, net `[7:0]` | REUSE, INT:**-8** sz8 | fresh; pa INT:8 sz4 | REUSE, pa INT:8 **sz8** — size fixed, SIGN still wrong (residue R5) |
| `q5_unbased` | `Q = '1` | FRESH (UINT / size -1 clone arms) | already equal | unchanged ✓ |
| `q5b_unbased_zero` | `Q = '0` | REUSE — the EXISTING § unbasedSharedPaConst | already REUSE; pa encoding BIN:0 vs our UINT:0 | unchanged — residue R6 |
| `q6_string` | `parameter string Q = "abc"` | REUSE, sz24 | **UNMEASURED** (def-CA share) | REUSE ✓ |
| `q7_real` | `parameter real Q = 1.5` | REUSE, REAL sz64 | **UNMEASURED** | REUSE ✓ |
| `q8_pkgref` | `assign t = q8_pkg::Q` | REUSE of the **DEF-VIEW cont_assign's** constant | fresh UINT | unchanged — residue R2 |
| `q9_import` | imported pkg param, bare name | the same | fresh UINT | unchanged — residue R2 |
| `q10_gen` | CA in a genblock reading a MODULE param | **FRESH** — a CLONE at the REFERENCE's span, HEX, sz20 | already equal | unchanged ✓ |
| `q11_genparam` | param AND CA both in the genblock | REUSE | already REUSE | unchanged ✓ |
| `q12_if` | INTERFACE param + interface CA | REUSE | **UNMEASURED** | still UNMEASURED — residue R1 |
| `q13_sel_lhs` | `assign t[7:4] = Q` | REUSE, sz stays the NET's 20 | **UNMEASURED** | REUSE ✓ |
| `q14_two` | two params, one CA each | REUSE, each its own | two fresh | REUSE, no aliasing ✓ |
| `q15_enum` | `parameter e_t Q = E0` | REUSE, HEX:3 sz4 | fresh UINT:3 | REUSE ✓ |
| `q16_cast` | `assign t = 4'(Q)` | CONTROL: fresh UINT sz4 | already equal | unchanged ✓ |
| `q17_typedef_net` | net declared through a typedef | REUSE | fresh | REUSE ✓ |
| `q18_child` | param passed down as an override actual | REUSE in the CHILD | fresh | REUSE ✓ |

**Arm totals.** Both sides re-measured on the SAME arm files with the PRISTINE
binary `4a5ef68f…` and the FINAL binary `190fa2ed…`, so these are like for like:

| arm | `ptab.sh` filter | pristine | final |
|---|---|---|---|
| `p1_paramref.v` | `*Assign[n]/vpiRhs[0]` | **21 differing of 93** | **1** |
| `p1_paramref.v` | `vpiVariables[0]/vpiExpr*` (family two) | **13 differing of 45** | **0** |
| `p1_paramref.v` | whole dump | 1375 content lines / 85 hunks | **1031 / 48** |
| `q1_spellings.v` | `*Assign[n]/vpiRhs[0]` | **19 differing of 79** | **5** |
| `q1_spellings.v` | whole dump | 1291 content lines / 60 hunks | **1060 / 40** |

The 1 remaining `p1` cell is `p11_select` (residue R3) and the 5 remaining `q1`
cells are residues R2 x2, R1, R5 and R6 — **every one of them PRE-EXISTING**, and
each is named and ranked below.

### 1.2 REFUTATION OF MY OWN FIRST CUT — `orig_size` is not `VpiSize()`

The first cut (binary `8186b9473f3e…`) read adjustSize's `orig_size` off
`pcR9->VpiSize()`. That is WRONG in our pipeline and it **REGRESSED
`p9_replvalue`, a cell that was already equal**, truncating golden's 21-digit
`20'b1…1` to a bare 20-digit string. Root cause, measured rather than assumed:
a replication-valued parameter's constant is still at its NATURAL width (21) when
the cont_assign is emitted.

Then a second measurement REFUTED my repair as well. I first modelled the
BIN-truncation split on the constant's OWN typespec (adjustSize replaces `ts`
with the constant's typespec, so a replication should land in the int_typespec
arm that never truncates). **Measured: `p9_replvalue` and `q1_bin_narrow` BOTH
carry a loc-less `logic_typespec` in golden's ELAB view.** The typespec does not
distinguish them; the SIZE does. Taking `orig_size` from the PARAMETER SYMBOL's
declared width makes `p9` a no-op (20 vs target 20) and leaves `q1` truncating
(20 vs target 4), which is what golden does.

**And a PRE-EXISTING defect fell out of it, proved on the pristine binary.** With
NO cont_assign reading it, `parameter [19:0] R = {21{1'b1}}` is size **21** /
`21'b…` on the PRISTINE binary too, against golden's 20 / `20'b…`. The pre-patch
"correct" answer in the arm was an ACCIDENT of the fold path this law replaces.
`§ replParamConstClampsToDeclWidth` restores it at the read; the UNREAD spelling
is still wrong on both binaries and is residue R8.

### 1.3 REFUTATION BY THE CORPUS — `TypespecExpr`, and only the ROW GATE saw it

The target-1-only binary `d55f81de…` passed the goldens (23/0) and the whole u2r
row gate BYTE-IDENTICALLY, and its arms were clean. The **surelog row gate**
caught a real regression:

```
- TypespecExpr,default,CMP_EQUAL,,,match          - TypespecExpr,testflags,CMP_EQUAL,,,differ
+ TypespecExpr,default,CMP_EQUAL,,,differ         + TypespecExpr,testflags,CMP_NOTEQUAL,decompile:,,
```

`Surelog/tests/TypespecExpr/dut.sv` is
`module Mod1 #(parameter logic [31:0] PARAM = '0)` overridden with a packed-STRUCT
parameter and read by `assign x = PARAM`. Golden keeps the plain
`ref_obj (work@Mod2.mod1.PARAM)` there — this is the pre-existing
`§ srlgAggActualNoFold` rule ("an aggregate override actual leaves the read
unfolded in EVERY arm") plus the general
`exprElabParamUnreduced / exprPatNoFold / noParamSubst` clearing. **The reuse is
an arm too and must honour both.** The fix hoists that clearing condition into a
named `elabReadNoValue9` and ANDs it (with `aggActualParamRef`) into the gate;
after it the row is CMP_EQUAL + `differ` again, i.e. back to baseline.

**METHOD NOTE.** The arms were clean and both dump-diffs improved on the binary
that carried this defect. The corpus row gate is what found it — the mirror image
of r10oth4's lesson, where only the byte verifier did. Run everything.

### 1.4 A THIRD REFUTATION, from family two, same shape

Family two's first cut (binary `443733953e…`) over-fired on MULTI-DIMENSIONAL
packed targets and broke **two more rows the arms could not see**: u2r
`2DFunctionArg` (`logic [1:0][3:0] x = {4'hF, 4'hF};` — CMP_EQUAL + `match` ->
CMP_NOTEQUAL `decompile:`) and surelog `ClogCast`
(`const logic [RomSize-1:0][63:0] mem = {…}` — CMP_EQUAL/`match` ->
CMP_NOTEQUAL, BOTH modes). Golden leaves those operands at their OWN width;
Surelog's `Bits(ts)` evidently does not return the whole width for a
multi-dimensional packed typespec. The gate is now restricted to the shapes
actually measured (§2). **Three of this pass's four laws had to be narrowed by a
gate the arms could not have found.**

---

## 2. FAMILY TWO — the two C5 residues (variable initializers)

Both were "LIVE DIFFERENCES that NO INSTRUMENT PRINTS"; `ptab.sh` prints them.

### `§ varInitReplKeepsOperation` — DIRECTION: ADD a missing subtree

`logic [19:0] v = {21{1'b1}};` — golden's ELAB `logic_var` carries a `vpiExpr`
that is the UNFOLDED replication (opType 34 over `constant UINT:21 sz20`, opType
33 over `BIN:1 sz1`); we emitted the `logic_var` with **no `vpiExpr` at all**.
The variable-initializer arm accepted `Concatenation` and not `Replication`; it
now accepts both (`bool concatInit`).

**HALF OF THE C5 REPORT IS REFUTED.** It also said we emit "an extra
`vpiVisibility:1`" there. **We do not** — BOTH sides carry `vpiVisibility=1` on
the `logic_var` in `e1`, `e3` and `e4` alike. The whole difference was the
missing subtree.

### `§ varInitConcatOperandAdjustSize` — DIRECTION: REPLACE

The report was "`logic [3:0] v = {8'hF5, 8'h0F};` — golden's two operand
constants carry `vpiSize:4`, ours `vpiSize:8`", which is one cell, and **one cell
cannot tell `size = target` from `size = min(own, target)`.** Six new cells
REFUTE the `min` reading outright and identify the rule as adjustSize again — the
SAME law as family one, split by ENCODING:

| cell | source | operand encodings | golden(LHS) | ours BEFORE | ours AFTER |
|---|---|---|---|---|---|
| `e1_varinit` | `logic [19:0] v = {2'b10,2'b01}` | BIN,BIN | 2, 2 | 2, 2 | unchanged ✓ |
| `e2_varinit_int` | `int v = {2'b10,2'b01}` | BIN,BIN | 2, 2 | 2, 2 | unchanged ✓ |
| `e3_varinit_trunc` | `logic [3:0] v = {8'hF5,8'h0F}` | HEX,HEX | **4, 4** | 8, 8 | 4, 4 ✓ |
| `e5_varinit_eq` | `logic [7:0] v = {8'hF5,8'h0F}` | HEX,HEX | 8, 8 | 8, 8 | unchanged ✓ |
| `e6_varinit_odd` | `logic [5:0] v = {8'hF5,8'h0F}` | HEX,HEX | **6, 6** | 8, 8 | 6, 6 ✓ |
| `e7_varinit_small` | `logic [3:0] v = {2'b10,2'b01}` | BIN,BIN | 2, 2 | 2, 2 | unchanged ✓ |
| `e8_varinit_mixed` | `logic [3:0] v = {8'hF5,2'b01}` | HEX,BIN | **4, 2** | 8, 2 | 4, 2 ✓ |
| `e9_varinit_int32` | `int v = {8'hF5,8'h0F}` | HEX,HEX | **32, 32** | 8, 8 | 32, 32 ✓ |
| `e10_varinit_nested` | `logic [3:0] v = {{2'b10,2'b01},4'hF}` | op,HEX | inner 2,2 / outer 4 | same | unchanged ✓ |
| `e4_varinit_repl` | `logic [19:0] v = {21{1'b1}}` | UINT,op(BIN) | 20, (1) | **no vpiExpr at all** | 20, (1) ✓ |

* **`e9` kills `min(own,target)`**: an `int` target makes BOTH 8-bit operands
  **32**, i.e. WIDER than they were written.
* **`e8` proves the split is per ENCODING, not per width**: in ONE concat its
  `8'hF5` becomes 4 and its `2'b01` stays 2.
* the rule is exactly adjustSize's: HEX/OCT/INT/… -> the final `else`,
  `size := target`; BINARY -> the logic arm, TRUNCATE ONLY when `orig > target`;
  UINT -> mask + size (`e4`'s repeat count 21 -> size 20, value unchanged);
  DEC -> untouched by the outer guard.
* **14 of 14 measured operand cells agree.** NESTED operands are left alone
  (`e10`'s inner concat keeps its 2-bit operands); the HEX spelling of a NESTED
  operand is **UNMEASURED**.

`ptab.sh` over `vpiVariables[0]/vpiExpr*`: **45 cells, 0 differing** after the
patch. The 8 remaining `e*` differences in the arm are all one unrelated
pre-existing cell — the var's `logic_typespec` ACTUAL SPAN, golden `209:1-209:6`
(`logic`) vs ours `209:1-209:13` (`logic [19:0]`) — filed as residue R9.

---

## 3. GATES

Numbers below are the ones I measured, on the FINAL binary
**`190fa2eda33082098e559c74d236f429  <!-- CORRECTED AT INTEGRATION: this cited 443733953ead05ce3e7677217ec4ae5f, which this same README defines as family two's FIRST CUT -- the binary the 2DFunctionArg and ClogCast regressions were found on. Every figure here reproduces on the FINAL binary. -->`** unless a line names another.

1. **Build** — `cmake --build build -j 3` in this worktree: exit 0, no new
   warnings (the four `-Wnarrowing` notices at `ModuleEmit.cpp:13138-13141` and
   `:20078-20079` are pre-existing and present on the pristine build too).
2. **Goldens** — `bash tests/check_goldens.sh` with `SLANG_UHDM` exported to this
   worktree's build: **PASS 23 / FAIL 0**. Negative control `SLANG_UHDM=/bin/false`:
   **PASS 0 / FAIL 23**, so the `verify_golden.py:52` / `check_goldens.sh:5`
   main-tree default is not what got measured.
3. **uhdm2rtlil, `testflags`, `--jobs 2`, own `--out`** — see §3.1.
4. **surelog, `--mode both`, `--jobs 2`, own `--out`** — see §3.1.
5. **BYTE VERIFIER on BOTH corpora** — see §3.2.

### 3.1 ROW GATES — both BYTE-IDENTICAL to the committed baselines

* **uhdm2rtlil, `testflags`** — **731 rows** (the committed CSV is 732 LINES
  including its header): **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**,
  dump **496 match / 183 differ / 52 blank**. Whole-row diff against
  `results/gate_uhdm2rtlil.csv`, status *and* dump column: **0 lines.**
  `default` was NOT run (no committed baseline) and nothing here implies it was.
* **surelog, `--mode both`** — **1588 rows** (CSV 1589 LINES):
  `default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL** / 5 DEFERRED / 284 SLANG_REJECT /
  25 SURELOG_FAIL, dump **match 225**; `testflags` **463 CMP_EQUAL /
  10 CMP_NOTEQUAL** / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL /
  3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM, dump **match 165**.
  Every cell equals the brief's `6744b86` baseline and **the dump match counts
  did not fall.** Whole-row diff against `results/golden_surelog.csv`:
  **0 lines.**
* **POSITIVE CONTROL on the harness invocation itself**: the PRISTINE binary,
  swept the same way into its own workdirs, reproduced BOTH committed baseline
  CSVs exactly (0-line diffs), so a zero-change reading is a real measurement and
  not a driver that cannot see its probe.
* The known `Google,testflags` golden-side environment flake shows as
  `TIMEOUT surelog timeout` in BOTH the patched and the pristine sweep and in the
  committed baseline — named, not filtered, not promoted.
* `results/golden_surelog.csv`'s `LowMemPkg,testflags` row embeds an absolute
  SESSION-SCRATCHPAD path; it reproduced identically here (the row diff is
  empty), so the judge is sound. Not "fixed", per the standing instruction.

### 3.2 BYTE VERIFIER — both corpora, and this is where the reach is zero

`byteverify.sh` (reused unchanged from `r10oth4repro`, shipped here too): PATH-SET
ASSERTION plus a comparator negative control. The pristine side is built from a
SEPARATE source tree (`/tmp/r10oth5_pristine_src` = `6744b86`'s `ModuleEmit.cpp`
over this worktree's other files) into `/tmp/r10oth5_pristine_build`, so no
rebuild ever raced a sweep; **`git stash` was never used.** That separate build
produced **the same md5 `4a5ef68fd946f278d0918993bef58829`** as the in-worktree
pristine build — the control that the pristine source copy is exact.

* **uhdm2rtlil: 679 databases, PATH_SETS_IDENTICAL, 0 MOVERS.** Comparator
  negative control (`SELFCHECK=1`): **678 / 679 flagged** — the one unflagged
  path is the fixed file compared with itself, so the comparator is provably live.
* **surelog: 953 databases, PATH_SETS_IDENTICAL, 1 MOVER**, and the mover is
  `default/Scoreboard`, the KNOWN intermittent flake. **PROVED, not asserted**:
  `r10oth2repro/scoreboard_nondet.sh`, 4 runs per binary, shows the **PRISTINE**
  binary disagreeing with ITSELF (`54245ef8…` x3 then `eff032af…`) and producing
  the very md5 the verifier attributed to the patched side; the two binaries'
  output sets OVERLAP on `54245ef8…`. Three distinct md5s were seen across the
  session (`54245ef8`, `eff032af`, `0a5ce029`), so it is at least 3-way.
  Comparator negative control: **952 / 953 flagged.**
* **So the FINAL patch changes ZERO bytes on BOTH corpora.** The laws are correct
  on the arms and reach nothing real. Said plainly rather than dressed up:
  the corpus's dominant parameter spelling is `parameter int P = 0` /
  `parameter P = 5`, which is UINT-encoded and therefore in adjustSize's CLONE
  set — exactly the cells (`p4`, `p8`, `p15`) where golden mints a fresh constant
  and we already matched. `AdditionAsParameterInInstance`
  (`parameter int P = 0; assign a = P;`) is the witness: byte-identical, and
  CORRECTLY so.

### 3.3 CANARIES, checked individually BY NAME, not as an aggregate

Guaranteed by the two empty whole-row diffs and the byte verifier, and
spot-checked by name besides. `InterfaceModPort` CMP_EQUAL+`differ` both modes ✓;
**`BlackParrotComplex`** (the fragile `ed653b4` conversion, and this pass's law
lives in its neighbourhood — param_assign Rhs constants) CMP_EQUAL+`differ` both
modes and a NON-MOVER in the byte verifier, so the traversal-order hazard its
CMP_EQUAL depends on was not disturbed ✓; `YosysBigSimReed`, `YosysOldOpen`
CMP_EQUAL+`differ`, non-movers ✓; `YosysOldOr` CMP_NOTEQUAL both modes,
UNCHANGED — this pass did not touch it ✓; pass 50's five (`ClassParamAsParam`,
`ClassTypeParam`, `SVSwitch`, `SimpleConstraint`, `ApbSlave`) all at baseline ✓;
`InterfaceBinding` / `InterfaceModExp` / `BindHierPath` / `EnumConcat` /
`LowMemPkg (default)` CMP_EQUAL + dump **`match`** — the strongest control, since
any byte change there flips the dump column ✓; `Earlgrey_0_1`
(default CMP_NOTEQUAL / testflags SLANG_REJECT), `Scr1SvTests`, `BasicOh`,
`ClassExtends`, `FuncStruct`, `FuncStructVal`, `FuncIoTypespec`, `PartSelect4`,
and the `EvalFunc*` / `ParamFile*` / `Black*` families (52 rows) all unchanged ✓;
u2r `paramod_genscope_child`, `issue326_packed_mem`, `assignment-pattern`,
`hier_path`, `MultirangesStartNotFromZero`, `genscope_cells`,
`genvar_loop_decl_3` unchanged ✓. The four slang-fenced tests (`UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam`) were never dispatched as targets;
they are ordinary corpus rows and match the baseline ✓. And the two rows this
pass BROKE and then FIXED — `TypespecExpr` (CMP_EQUAL `match`/`differ`) and
`ClogCast` (CMP_EQUAL `match`/`match`), plus u2r `2DFunctionArg` (CMP_EQUAL
`match`) — are all back at baseline ✓.

---

## 4. RANKED RESIDUE (most reachable first)

### R0. THE REACH QUESTION ITSELF. DIRECTION: measure before implementing. Depth: shallow, and it should come FIRST next pass.
This pass's four laws are right on ~220 cells and move ZERO corpus bytes, because
the corpus's parameters are overwhelmingly UINT-encoded and therefore in
adjustSize's CLONE set. **The cheapest next step is not another law but a
CENSUS**: `caform.py` over the existing sweep workdirs, counting ELAB
`cont_assign -> vpiRhs` cells where golden is a back-reference and ours is a
definition. That number, not an arm, should choose the next target. The
instrument to do it is already in this directory and already reads
back-references; it needs only a driver that walks a sweep root.


### R1. `q12_if` — an INTERFACE's own cont_assign never reaches the reuse. DIRECTION: ADD (route the law). Depth: shallow. HONESTLY NOT DONE.
`interface q12_if; parameter [19:0] Q = 20'h5; wire [19:0] t; assign t = Q;` —
golden REUSES exactly as a module does; ours emits no ELAB cont_assign Rhs row at
all (`UNMEASURED`), i.e. the interface's elab CA still shares the def object. The
law is written and gated; only this emission path does not run through
`emitContAssigns`'s site. Find the interface CA emitter and apply the same block.

### R2. `q8_pkgref` / `q9_import` — a PACKAGE parameter read by a cont_assign. DIRECTION: ADD (a second, different reuse source). Depth: shallow. Measured, deliberately excluded.
Golden's **DEF view already folds** the read to a HEX constant carrying the
REFERENCE's span (we match that byte for byte) and the **ELAB view shares THAT
object**. So the source is the DEF-VIEW CONT_ASSIGN's own Rhs, not the package
param_assign's — `defInfo->contAssigns[myIdx]->Rhs()` is already in hand at the
site. The vpiParent question is **UNMEASURED**: golden's two cont_assigns share a
span, so the dump cannot say which claims it.

### R3. `p11_select` — `assign t = Q[3:0]` folds in golden's ELAB view and we share the def CA. DIRECTION: ADD. Depth: shallow. Pre-existing.
Golden: `constant BIN:1110 sz4`, loc-less. Ours: no elab Rhs row at all.
Independent of this pass's law (it is a SELECT, not a bare ref).

### R4. `p13_top` — a param read ONLY as an instance PORT ACTUAL takes the bare loc-less setRange typespec. DIRECTION: ADD a read spelling. Depth: shallow. NEWLY MEASURED.
`q6_top` in r10oth4's `r3_setrange.v` measured the PARAM-OVERRIDE actual and
found LOCATED. A PORT actual (`p13_child c0(.i(Q))`) is a different spelling and
golden gives it the **BARE loc-less `logic_typespec`** where we keep the LOCATED
`int_typespec`. Same family as r10oth4's R2 (`h5_condpos`) and reachable by the
same machinery.

### R5. `q4_signed_bin` — a SIGNED based literal param keeps the wrong SIGN. DIRECTION: REPLACE. Depth: shallow. Pre-existing; this pass fixed its SIZE only.
`parameter signed [3:0] Q = 4'sb1000` — golden `INT:-8`, ours `INT:8`. The size
half (4 -> 8) is fixed by this pass's reuse; the sign is untouched and predates it.

### R6. `q5b_unbased_zero` — a `'0` param's own constant encoding. DIRECTION: REPLACE. Depth: shallow. Pre-existing.
Golden `BIN:0 ct3 vpiDecompile:20'b0`, ours `UINT:0 ct9 vpiDecompile:0`. The
SHARING is already right (the existing `§ unbasedSharedPaConst`); only the
encoding of the shared object differs.

### R7. An UNREAD replication-valued parameter is size-NATURAL, not size-DECLARED. DIRECTION: REPLACE. Depth: shallow. PRE-EXISTING on BOTH binaries, proved this pass.
`parameter [19:0] R = {21{1'b1}}` with no reader: golden sz 20 / `20'b…`, both
our binaries sz 21 / `21'b…`. `§ replParamConstClampsToDeclWidth` fixes it only at
the READ. The proper home is the paramCtx replication arm of
`tryFoldConst` (`src/ExprEmit.cpp`, grep `§ replFoldParamInt32`), which should
clamp against the parameter's DECLARED width and not just the `>32` rule — but
that arm is gated over 22 landed cells, so it wants its own pass and its own arm.

### R8. The var's `logic_typespec` ACTUAL SPAN. DIRECTION: REPLACE. Depth: shallow. Pre-existing, 8 arm cells.
Golden spans the TYPE KEYWORD only (`209:1-209:6`, `logic`); we span the whole
declared type including the packed range (`209:1-209:13`, `logic [19:0]`).
Reproduces on every `e*` cell, so it is a one-site `setLoc` question.

### R9. The ELAB view SHARES the DEF cont_assign OBJECT where golden emits a distinct one. DIRECTION: not shallow, and possibly not worth doing. Measured.
On `p11_select` / `p22_unknown` (pre-patch) our ELAB `cont_assign` is itself a
BACK-REFERENCE to the DEF one; golden always emits two objects. `caform.py` sees
this; `uhdm-cmp` does not appear to. Ranked low deliberately.

### R10. Inherited, untouched this pass: r10oth4's R2 (`h5_condpos` condition-position read), R2b (`g9_op` spurious ref_typespec), R3 (YosysOldOr's read half — a whole-compilation property), R4/R5 (`materializeDefNetTs` port context, named-type split ports), R6 (**Rggen — RANKED LAST, needs a second Surelog-faithful interpreter, not touched**), R7, R8.

---

## 5. ASSETS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `caform.py` | the instrument r10oth4 lacked: one row per NODE, each marked **DEF or REF (back-reference)**, with module attribution and an indexed edge path. `--expect N` exits 3 (a real positive control). This is what makes "the two edges point at ONE object" measurable. |
| `ptab.sh` | joins the two sides of a `parm.sh` workdir per `(view, module, path)` cell and prints **`UNMEASURED(no such row on this side)`** where a side has no row — the r10oth4 failure mode, fixed. Exits 3 if the path filter selects nothing on BOTH sides. |
| `parm.sh` | the arm driver. Requires `SLANG_UHDM` (no default, on purpose), guards `[ -f slang.uhdm ]` because uhdm-cmp exits 0 on a missing input, pipes both dumps through `sed 1d` because uhdm-dump's first line is the database path, and reports dump-diff as **content lines already minus the two `diff -u` header lines**. |
| `p1_paramref.v` | 34 modules: 22 `p*` cells for § elabCaReusesParamValueConst (encodings, target widths, overrides, two instances, chains, procedural/port/select/operation CONTROLS) plus the 10 `e*` variable-initializer cells for family two. |
| `q1_spellings.v` | 20 modules: the OTHER SPELLINGS — binary/dec/signed/unbased/string/real/enum encodings, package and imported package params, generate scopes, an interface, a select LHS, a typedef'd net, a passed-down override. |
| `byteverify.sh` | reused unchanged from `r10oth4repro`: PATH-SET ASSERTION + comparator negative control. |

Reading conventions, stated once: dump-diff figures are **content lines** =
`grep -c '^[-+]'` minus the two `diff -u` header lines (`parm.sh` already
subtracts them); CSV row counts are LINES MINUS ONE for the header (732 = 731,
1589 = 1588); head counts are `grep -c '^LHS:'` at column 0.

Neither baseline CSV was rebuilt, edited, or included in the patch. `git stash`
was never used. Every probe wrote under `/tmp/r10oth5_*`.


## Corrections applied at integration by the master (pass verifier C1-C8)

**C1 — the gates section attributed every figure to the REGRESSED intermediate
binary** (family two's first cut, the one the `2DFunctionArg`/`ClogCast`
regressions were found on) instead of the final. Corrected in place; all figures
reproduce on `190fa2eda33082098e559c74d236f429`.

**C2 — FIVE residue pointers named the wrong residue, ONE OF THEM IN PRODUCTION
CODE.** `src/ModuleEmit.cpp` (inside `§ replParamConstClampsToDeclWidth`) said
"filed as residue R4" while this README's section 1.2 said R8 and the pass report
said R7 — **three different numbers for one residue**. R7 is correct and the code
comment now says so, with the disagreement recorded there. The four README
pointers (`q12_if` R4->R1, `q5b` R7->R6, `q4` R6->R5, unread-replication R8->R7)
are corrected in place. A residue number that drifts between the code, the README
and the report is worse than no number: the next pass greps for it.

**C3 — fixed in `tools/probe/r10oth4repro/README.md`, and it was MY error.** The
corrected R1 direction was appended there as a blockquote at the previous
integration, but **the original INVERTED body was left standing immediately
below it** — still claiming golden keeps a `ref_obj`, still calling the fix "a
bail", still telling the reader to "find that guard". A reader who skipped the
blockquote got exactly the direction that had already been wrong twice. The stale
body is now STRUCK and labelled as a warning. **Deleting a superseded claim is
part of applying a correction; appending the right answer above the wrong one is
not enough.**

**C4 — an arm file still asserts a refuted fact.** `p1_paramref.v` says our side
emits no `vpiExpr` "plus an extra `vpiVisibility:1`". The patch's own
`§ varInitReplKeepsOperation` comment refutes the second half — both sides carry
it — and the verifier confirmed it on the dumps. The arm is what the next pass
reads, so a refuted claim left in it will be re-inherited.

**C5 — off-by-one, twice**: `p1_paramref.v` has **35** modules, not 34
(`grep -c '^module '`). The "22 `p*` cells" and q1's "20 modules" are correct.

**C6 — NEW RESIDUE, and a compressed transcription.** The README claims
`adjustSize` clones "in exactly three arms". The definition citation
(`Surelog/src/DesignCompile/CompileHelper.cpp:3949`) is correct, but I counted the
`clone_tree` sites under `uniquify` myself: there are **FIVE** — `3996` (UINT,
gated), `4064` and `4092`/`4109` (`orig_size == -1`, gated), and **`4080`
(`constantIsSigned && orig_size == 1 && val == 1`), which is none of the three
named classes and is NOT gated by this patch**. The patch's gate is only
`VpiConstType() != vpiUIntConst && VpiSize() != -1`; it never implements the
signed-binary exclusion its own comment names, and its size logic transcribes the
`logic_typespec` truncate-only arm while the `int_typespec` branch uses
`min(orig,size)`. **Harmless today — reach is zero and the measured cells arrive
already re-encoded — but `parameter signed Q = 1'sb1` is a spelling no cell covers
and it lands in the ungated arm.** Filed with all five line numbers so "exactly
three arms" is not inherited.

**C7 — a reproducibility note, not an error.** The README quotes three distinct
Scoreboard md5s; the verifier saw only **two** across 8 runs, with BOTH binaries
emitting BOTH. The nondeterminism conclusion is unchanged and better supported,
but the third md5 should not be cited as a fixed fact.

**C8 — instrument limits.** `ptab.sh`'s regex is UNANCHORED: the filter as written
in the README gives 397 cells / 105 differing on pristine p1, while the README's
own 93/21 figures require the anchored form ending in `\]$`. Anyone re-running it
without the `$` gets different numbers and will think something moved.
