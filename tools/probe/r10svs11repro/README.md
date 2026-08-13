# r10svs11 — THE CONNECTION LIST'S *PARSE* OWNS THE NET, AND OUR PREDICATE WAS WRONG IN BOTH DIRECTIONS

**Verdict, up front: SVSwitch DID NOT CONVERT.** Both rows are unchanged from
the committed baseline, so this pass is read in the **UNCONVERTED world** of
GATE 4 and every gate below is judged against the unconverted expectation:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

The brief's target head — `module_inst: work@top`, **2680 cmp lines**, identical
in both modes — **is CLEARED, and the head ADVANCED 2680 → 54 lines**.

* **THE HEAD WAS A VECTOR-SIZE MISMATCH, not an own-field failure**, and the
  brief's first instruction was to decide which. It is the
  `r=1 failLhs=<container>` family: `SafeCompare(lhs, lhs->Nets(), rhs,
  rhs->Nets(), …)` in the generated `instance::Compare` found **golden 1 net,
  ours 4**, and set *both* `m_failedLhs` and `m_failedRhs` to the `module_inst`
  itself (§1.1). Every other directly-compared field of `work@top` is
  byte-identical between the two sides — the 2680 lines were ONE missing
  integer comparison reported from a very high root.
* **ONE LAW, `§ udpShapedConnNoIfaceNet11`, and the predicate it replaces was
  wrong in BOTH directions** — we minted 5 nets golden does not have *and*
  missed 5 golden does (§2, §3.2).
* **THE PREDICATE THIS PASS NEEDED WAS ALREADY IN THE TREE.**
  `udpShapedInstantiation` (src/EmitHelpers.h) already decodes the exact
  Surelog parser law, for `ref_module`. Nothing new was built; it was applied
  at two more call sites. Net change: **42 insertions, 11 deletions** — and
  **38 of the 42 insertions are the comment recording the measurement**. The
  executable change is FOUR lines: `if (udpShapedInstantiation(child)) continue;`
  twice.
* **GRID: 36 cells across 3 arms. EQ 23 → 36, DIFF 13 → 0**, and **not one cell
  regressed** (§3).
* **THE BRIEF'S TWO NAMED SUSPECTS ARE BOTH REFUTED** — r10svs10's residues R2
  (parameterized-class name span) and R3 (interface-class handle) are not in
  the failing pair and not in this test at all (§6.1).
* **FIVE GATES GREEN** (§5) under the UNCONVERTED expectation.
* **MOVERS: 2** (`SVSwitch` in both modes) out of 1632 databases across both
  corpora, and every removed shape lands on GOLDEN's own count EXACTLY (§5.5).
* **SIX REFUTATIONS** (§6), three of them against this pass's own brief and one
  against the producer's own cited golden.

Base commit `957974d`, branch `auto5h`.
Pristine binary md5 **`8a7c07f418d3a567de0b24c6a5e90fe3`** (worktree
`/tmp/wt_r10svs11pris`, `git rev-parse` = 957974d and `git status --porcelain`
EMPTY, both checked and printed).
Shipped binary md5 **`d4890e6fd39981373e5497b9eaf67e31`** (worktree
`/tmp/wt_r10svs11`, `git rev-parse` = 957974d, `git status --porcelain` = exactly
`M src/ModuleEmit.cpp` + `?? tools/probe/r10svs11repro/`).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script in
this directory.

---

## 1. LOCALIZATION — VECTOR SIZE vs OWN FIELD, DECIDED FIRST

### 1.1 It is a VECTOR-SIZE mismatch

`uhdm-cmp`'s head prints `module_inst: work@top` on BOTH sides. The brief warns
that this is ambiguous: a `module_inst` head is either (a) an own-field failure
(the r10uvm62 law: every recursive vector PASSED) or (b) a vector-SIZE mismatch,
because the vector `SafeCompare` sets both sides to the CONTAINERS:

```cpp
// UHDM/build/generated/uhdm/BaseClass.h:202
if ((r = static_cast<int32_t>(lhs->size() - rhs->size())) != 0) {
    context->m_failedLhs = lhs_obj;   // <- the module_inst, not an element
    context->m_failedRhs = rhs_obj;
    return 1;
}
```

The two are told apart by censusing `work@top`'s DIRECTLY-COMPARED fields on
both sides, at the object's own indent, span-keyed. Read from the head print
itself (`uhdm-cmp` prints the failing object TWICE per side — 657 lines each on
LHS, 680 on RHS — and the two copies are byte-identical, so only the first is
counted):

```
                 GOLDEN (LHS)   OURS (RHS)
|vpiParent           1              1
|vpiFullName         1              1
|vpiDefName          1              1
|vpiNet              1              4      <-- THE PAIR
|vpiProcess          1              1
|vpiModuleArray      1              1
|vpiRefModule        3              3
```

**Exactly one field family differs and it differs in SIZE.** Every other
directly-compared child is present in the same number and, object for object,
identical:

```
GOLDEN                                        OURS
\_logic_net: (work@top.Clock) 17:5-17:10      \_logic_net: (work@top.Clock) 17:5-17:10
                                              \_logic_net: (work@top.mem_intf)    44:14-44:22   OURS-ONLY
                                              \_logic_net: (work@top.input_intf)  44:23-44:33   OURS-ONLY
                                              \_logic_net: (work@top.output_intf) 44:34-44:45   OURS-ONLY
\_initial: 19:1-20:30                         \_initial: 19:1-20:30
\_module_array: (work@output_interface) 38:18 \_module_array: (work@output_interface) 38:18
\_ref_module: work@mem_interface (mem_intf)   \_ref_module: work@mem_interface (mem_intf)
\_ref_module: work@input_interface (input_intf) \_ref_module: work@input_interface (input_intf)
\_ref_module: work@switch (DUT)               \_ref_module: work@switch (DUT)
```

`Nets()` is compared in `instance::Compare`, AFTER every `scope` vector
(`Variables`, `Logic_vars`, `Parameters`, `Param_assigns`, `Scopes`,
`Typespecs`, `Instance_items`, …) and after `Programs`, `Program_arrays`,
`Class_defns`, `Task_funcs` — all of them absent on BOTH sides here — and BEFORE
every `module_inst` vector (`Module_array`, `Ports`, `Interfaces`, `Process`,
`Modules`, `Module_arrays`, `Gen_scope_arrays`, …). So `Nets()` is provably the
FIRST failing comparison, not merely *a* difference.

### 1.2 The three extras, and a 26-line repro

All three extras sit on **top.sv line 44**, at the exact spans of the three
actuals of

```systemverilog
testcase TC (mem_intf,input_intf,output_intf);       // top.sv:44
```

They are bare wires (`vpiNetType:1`, no typespec) minted by the two
**connection-site net** loops in `ModuleEmit.cpp`'s `emitInstance`. Reduced to a
single self-contained file that reproduces the head exactly (golden 1 net, ours
4) — `r3` in the reduction log, folded into arm `c2_udpshape.sv` as cells
e2/e3:

```systemverilog
interface mem_interface(input bit clock);   logic [7:0] mem_data;  modport MEM(input clock);  endinterface
interface input_interface(input bit clock); logic reset;  modport IP(output reset,input clock); endinterface
interface output_interface(input bit clock);logic ready;  modport OP(input clock);  endinterface
program testcase(mem_interface.MEM mem_intf,input_interface.IP input_intf,
                 output_interface.OP output_intf[4]);
  initial begin $display("x"); end
endprogram
module top();
  bit Clock;
  mem_interface   mem_intf(Clock);
  input_interface input_intf(Clock);
  output_interface output_intf[4](Clock);
  testcase TC (mem_intf,input_intf,output_intf);
endmodule
```

---

## 2. THE LAW

### § udpShapedConnNoIfaceNet11

> **A connection-site net for an interface actual exists only when Surelog
> parsed the instantiation as a `module_instantiation`.** An **ORDERED**
> connection list of **two or more** terminals, every terminal non-empty, whose
> **FIRST** terminal parses as a `net_lvalue`, is resolved by Surelog's parser
> as a **`udp_instantiation`** instead; `compileUdpInstantiation` never reaches
> the parent implicit-net fallback that mints this net, so **NONE** of that
> list's actuals gets one — scalar interface instance and interface ARRAY
> alike. Everything else mints them normally: a one-terminal ordered list, any
> named list, an ordered list whose first terminal is an operation or a
> literal, an ordered list containing an empty terminal, and an ordered list
> under a `#()` override that exceeds `delay2`.

This is the SAME parser law our tree already carries for `ref_module`, and the
predicate that decides it already existed:

```cpp
// src/EmitHelpers.h:1287   (UNCHANGED by this pass — only newly APPLIED)
inline bool udpShapedInstantiation(const InstanceSymbol& inst) { … }
```

The mechanism is not inferred; it is read straight off Surelog's own parse tree
via `surelog -parse -nocache -d ast`, for every cell (§3.2's `parse` column).
`testcase TC (mem_intf);` yields `Ordered_port_connection` /
`List_of_port_connections`; `testcase TC (mem_intf,input_intf);` yields
**`Net_lvalue`** — the gate/UDP terminal form.

### STATED GATE == CODE GATE

The two gates in `src/ModuleEmit.cpp` are, in full, after this pass:

```cpp
// the SCALAR connection-site loop
if (udpShapedInstantiation(child))
    continue;

// the interface-ARRAY connection-site loop (hoisted to the child, per-instance)
if (udpShapedInstantiation(child))
    continue;
```

Nothing else in either loop changed. There is no interface-port count in them,
no child-kind test, no modport test and no name comparison — which is precisely
what the law above says, and what §3.1 and §6.2/§6.3/§6.4 measure.

### What was there before, and why it was wrong

```cpp
// scalar loop only; the ARRAY loop had NO shape gate at all
bool mixed9 = false;
for (auto cc9 : child.getPortConnections())
    if (cc9->port.kind != SymbolKind::InterfacePort)
        mixed9 = true;
if (hasOrderedConns(child) && mixed9)
    continue;
```

Read as a claim about golden it says: *an ordered list mints nothing exactly
when the child also has a non-interface port.* It was read off one witness,
`iface_method_call h1(hintf, su, …)`, which confounds two axes — that list is
BOTH mixed AND udp-shaped. §3.2 separates them and the predicate fails on both
sides of the separation.

---

## 3. THE GRID, CELL FOR CELL

Read by `netread.py`, which walks the dump's **indent column** and collects only
the objects at the measured object's own indent+2 under a `|vpiNet:` label —
necessary because each net is REPRINTED inside other objects (as a `vpiParent`
back-pointer and as a `ref_obj`'s `vpiActual`), so a `grep` for `logic_net` over
`work@top`'s subtree over-counts wildly. Cells are keyed by **(field, object
kind, name, source span)** on BOTH sides. `MINT` = the net is in `work@top`'s
`Nets()`; `NONE` = it is not.

Every interface instance in every arm is connected to **exactly one** child, so
the producer's separate "connected to MULTIPLE children" clause cannot confound
any cell.

### 3.1 `c1_childkind.sv` — CHILD KIND x FORMAL FORM x CONNECTION STYLE

Eight cells at connection-count 1, crossing the three axes the SVSwitch witness
pairs with everything else.

```
cell  child    formal form   conn style   GOLDEN  PRIS   SHIP
a1    module   ifa.MP p      positional   MINT    MINT   MINT    EQ
a2    module   ifa p         positional   MINT    MINT   MINT    EQ
a5    module   ifa.MP p      named        MINT    MINT   MINT    EQ
a6    module   ifa p         named        MINT    MINT   MINT    EQ
a3    program  ifa.MP p      positional   MINT    MINT   MINT    EQ
a4    program  ifa p         positional   MINT    MINT   MINT    EQ
a7    program  ifa.MP p      named        MINT    MINT   MINT    EQ
a8    program  ifa p         named        MINT    MINT   MINT    EQ
                            cells 9 (incl. Clock)  EQ 9 -> 9   DIFF 0 -> 0
```

**Golden's answer is MINT in all eight.** Child kind is REFUTED as a
discriminator; formal modport-qualification is REFUTED; connection style ALONE
is REFUTED. This arm also proves the fix regresses nothing here: all nine cells
were EQ before and are EQ after.

### 3.2 `c2_udpshape.sv` — THE DECISIVE ARM: the CONNECTION-LIST SHAPE

`parse` is Surelog's own node type for that connection list, from
`surelog -d ast`. `udp?` is `udpShapedInstantiation`'s answer.

```
cell  connection list                     parse         udp?  GOLDEN PRIS  SHIP
e1    k1  u1  (e1i)                       Ordered/List  no    MINT   MINT  MINT   EQ
e2a   k2  u2  (e2a, e2b)                  Net_lvalue    YES   NONE   MINT  NONE ->EQ
e2b   k2  u2  (e2a, e2b)                  Net_lvalue    YES   NONE   MINT  NONE ->EQ
e3a   k3  u3  (e3a, e3b, e3c)             Net_lvalue    YES   NONE   MINT  NONE ->EQ
e3b   k3  u3  (e3a, e3b, e3c)             Net_lvalue    YES   NONE   MINT  NONE ->EQ
e3c   k3  u3  (e3a, e3b, e3c)             Net_lvalue    YES   NONE   MINT  NONE ->EQ
e4    kmi u4  (e4i, Clock)                Net_lvalue    YES   NONE   NONE  NONE   EQ
e5    kim u5  (Clock, e5i)                Net_lvalue    YES   NONE   NONE  NONE   EQ
e6    kim u6  (Clock & 1'b1, e6i)         Ordered/List  no    MINT   NONE  MINT ->EQ
e7    kim u7  (1'b0, e7i)                 Ordered/List  no    MINT   NONE  MINT ->EQ
e8    kmi u8  (e8i)          2nd port free Ordered/List no    MINT   NONE  MINT ->EQ
e9a   k2  u9  (.m(e9a), .n(e9b))          Named/List    no    MINT   MINT  MINT   EQ
e9b   k2  u9  (.m(e9a), .n(e9b))          Named/List    no    MINT   MINT  MINT   EQ
e10   k1  u10 (.m(e10i))                  Named/List    no    MINT   MINT  MINT   EQ
e11   kmi u11 (e11i, Clock & 1'b1)        Net_lvalue    YES   NONE   NONE  NONE   EQ
e12   kie u12 (Clock, , e12i)             Ordered/List  no    MINT   NONE  MINT ->EQ
e13   kp #(1,2)   u13 (e13i, Clock)       Net_lvalue    YES   NONE   NONE  NONE   EQ
e14   kp #(1,2,3) u14 (e14i, Clock)       Ordered/List  no    MINT   NONE  MINT ->EQ
                            cells 19 (incl. Clock)  EQ 9 -> 19   DIFF 10 -> 0
```

**`udp? == YES` and `GOLDEN == NONE` agree on ALL 18 signal cells, with no
exception.** Three readings settle the old predicate:

* **e2/e3 vs e4/e5 — the OVER-MINT.** `e2`/`e3` are all-interface lists with no
  regular port anywhere, so `mixed9` stayed FALSE and we minted 5 nets golden
  does not have. That is SVSwitch's shape exactly: `testcase` has three ports
  and all three are interface ports.
* **e6/e7 vs e11 — the FIRST TERMINAL is what the parser looks at.** `e6`
  (`Clock & 1'b1` first) and `e7` (`1'b0` first) are NOT udp-shaped and golden
  MINTS; `e11` (interface first, operation second) IS udp-shaped and golden
  mints nothing. `mixed9` is TRUE in all three and answers all three the same
  way — wrongly in two.
* **e8, e12, e14 — the UNDER-MINT, three more ways.** One terminal with a
  second port left unconnected; an EMPTY terminal; a `#()` override that
  exceeds `delay2`. Golden mints in all three; the old predicate minted in
  none.

### 3.3 `c3_ifacearray.sv` — the interface-ARRAY connection-site net

The producer mints in TWO loops and SVSwitch's ONE list carries both kinds, so a
fix to only the scalar loop would clear two thirds of the head and leave the
third.

```
cell  connection list                    parse         udp?  GOLDEN PRIS  SHIP
f1    a1m v1 (g1i)                       Ordered/List  no    MINT   MINT  MINT   EQ
f2a   a2m v2 (g2a, g2b)                  Net_lvalue    YES   NONE   MINT  NONE ->EQ
f2b   a2m v2 (g2a, g2b)                  Net_lvalue    YES   NONE   MINT  NONE ->EQ
f3    a1m v3 (.m(g3i))                   Named/List    no    MINT   MINT  MINT   EQ
f4    a3m v4 (g4i, Clock)                Net_lvalue    YES   NONE   MINT  NONE ->EQ
f5    s1m v5 (g5i[0])   element select    Ordered/List  n/a   NONE   NONE  NONE   EQ
f6    a1m v6 (.m(g6i))                   Named/List    no    MINT   MINT  MINT   EQ
                            cells 8 (incl. Clock)  EQ 5 -> 8   DIFF 3 -> 0
```

`f5` is the control for the clause this pass did NOT touch: an ELEMENT SELECT
(`g5i[0]`) carries a `[`, the producer excludes it, and golden agrees — on both
binaries.

### 3.4 Totals

```
             cells   EQ pristine -> shipped   DIFF pristine -> shipped
c1              9          9 ->  9                   0 -> 0
c2             19          9 -> 19                  10 -> 0
c3              8          5 ->  8                   3 -> 0
              -----      -----------              ----------
               36         23 -> 36                  13 -> 0
```

**Not one cell regressed**: every cell EQ on the pristine binary is EQ on the
shipped one, and every DIFF cell converged. There is no residue in this grid.

---

## 4. THE PRODUCER

`src/ModuleEmit.cpp`, `emitInstance`'s two connection-site net loops. Loop 1
walks each child instance's interface PORTS and mints a wire named after the
connected interface INSTANCE; loop 2 does the same for a whole interface ARRAY
passed to an interface-ARRAY port. Both push into the parent `module_inst`'s
`Nets()` and register in `ifaceConnNet` so a multi-child interface takes one net
at its FIRST connection site.

The change adds `udpShapedInstantiation(child)` as an early `continue` in each,
and deletes the 8-line `mixed9` block from loop 1. In loop 2 the guard is
hoisted to the CHILD level (outside the port walk), because the law is a
property of the child's connection LIST, not of any one port.

**No other net-minting rule is disturbed.** Verified on the dump rather than
argued: the four other clauses of loop 1 (dotted/modport actual, implicit named
connection `.intf`, passthrough interface owned by an outer module, duplicate
site) and the two of loop 2 (`.`/`[` in the actual's raw text, non-`InstanceArray`
actual, passthrough) are untouched, and arms `c2` e5/e11/e13 and `c3` f5 hold
them fixed while the new gate moves. `udpShapedInstantiation` itself is
UNCHANGED — its two pre-existing call sites (`ModuleEmit.cpp:2478` ref_module,
`:8604` high-conn) are byte-identical, and GATE 3's 0 differing rows over 731
uhdm2rtlil tests is the blast-radius measurement for that.

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

```
/tmp/wt_r10svs11                    (shipped)
[100%] Linking CXX executable slang-uhdm      <- the link line, waited for
[100%] Built target slang_uhdm
SHIP_RC=0     compiler errors: 0
md5(build/slang-uhdm) = d4890e6fd39981373e5497b9eaf67e31   (32 hex, asserted separately)
git rev-parse HEAD  = 957974dabc7aacfb75ce00295ef363f70b189be0
git status --porcelain =  M src/ModuleEmit.cpp
                        ?? tools/probe/r10svs11repro/

/tmp/wt_r10svs11pris                (pristine, built here, NOT reused)
[100%] Linking CXX executable slang-uhdm
[100%] Built target slang_uhdm
PRIS_RC=0     compiler errors: 0
md5(build/slang-uhdm) = 8a7c07f418d3a567de0b24c6a5e90fe3   (32 hex, asserted separately)
git rev-parse HEAD  = 957974dabc7aacfb75ce00295ef363f70b189be0
git status --porcelain = <EMPTY>
```

**THE BASE MARKER IS BEHAVIOURAL, AND TWO-DIRECTIONAL.** This pass adds no new
symbol — `udpShapedConnNoIfaceNet11` names a law that lives in a COMMENT and
the predicate it applies is a pre-existing `inline` function — so
`strings | grep -c <lawName>` is unavailable and quoting it would be a guard
that does not guard. The substitute tests the law itself, in BOTH directions, so
a binary cannot pass it by accident:

```
SOURCE     grep -c udpShapedConnNoIfaceNet11 src/ModuleEmit.cpp
             shipped worktree = 2      pristine worktree = 0
BEHAVIOUR  arm c2 cell e2a  (an all-interface udp-shaped list — the OVER-MINT)
             shipped = NONE            pristine = MINT
BEHAVIOUR  arm c2 cell e6i  (an operation-first ordered list — the UNDER-MINT)
             shipped = MINT            pristine = NONE
```

All three were run on every binary these gates quote.

### GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped> tests/check_goldens.sh   ->  23 PASS / 0 FAIL
SLANG_UHDM=/bin/false tests/check_goldens.sh  ->   0 PASS / 23 FAIL   (control fires)
```

Stated honestly: the 23 goldens contain no interface connection list of this
shape, so they prove this law did not break the unrelated corpus; **they cannot
confirm it.** The instruments that confirm it are §3 and GATE 5.

### GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep, judged the same way:   0 differing ROWS
```

### GATE 4 — surelog `--mode both --jobs 2` (`GOLDEN_DEFER` left UNSET)

**UNCONVERTED WORLD**, and the expectation is met exactly:

```
default   : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
testflags : 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
            (+ 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM)
dump histograms: UNCHANGED in both modes
   default    327 blank / 242 differ / 225 match   (baseline: identical)
   testflags  331 blank / 298 differ / 165 match   (baseline: identical)
WHOLE-ROW diff vs results/golden_surelog.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep: 0 differing ROWS
```

No `results/*.csv` was touched by this pass.

#### 5.4.1 The SVSwitch instruments, reported separately and never conflated

```
                                    PRISTINE      SHIPPED
cmp HEAD DEPTH (NOT a distance)        2680          54
dump content +/-                       1912         1891
MULTISET DISTANCE (resync-immune)      1354         1333
o.dump lines                          25720        25699   (golden 25318)
golden-only line instances              476          476
ours-only   line instances              878          857
```

Identical in both modes; the two `cmp.txt` files are byte-identical
mode-to-mode on both binaries. **All four instruments moved the right way**:
this is the first head on this row where the depth also FELL, because the law
removes objects rather than adding them. `golden-only` is unchanged at 476 —
this law only removes ours-only lines, and it removes exactly 21 of them (3 nets
x 7 dump lines each).

**The successor head, `port` of `module_array (work@output_interface)`, 54 cmp
lines**, is ranked R1 in §7 and is a clean two-field pair.

### GATE 5 — BYTE VERIFIER, both corpora, vs a PRISTINE 957974d built here

`byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 3 / 953
          SELFCHECK 952/953 flagged        SELFCHECK1 = 4  (= 3 flagged + 1 corrupted)

  ./default/SVSwitch      ./testflags/SVSwitch      <- law content
  ./default/Scoreboard                              <- FALSE MOVER, see 5.5.1
```

**2 real movers**, both the target, both modes — not the 3 the verifier printed.

#### 5.4.2 CENSUS-PREDICT, run FIRST, and it is an UPPER BOUND

`census.sh` filters on the law's two NECESSARY conditions — the test declares an
`interface` AND contains an ordered connection list — because the SUFFICIENT
condition (`udpShapedInstantiation`: >=2 ordered terminals, none empty, first a
`net_lvalue`, `#()` still readable as `delay2`) needs slang's parse tree, which
a shell script does not have. It named:

```
surelog corpus : 29 of 70 test dirs      u2r corpus : 53 of 734 test dirs
```

and the verifier found **2** movers in one of the 29 and **0** in any of the 53.
**It is an UPPER BOUND by a factor of 41, and it is recorded as such rather
than dressed up.** Its one real service was naming `iface_method_call` and
`load_and_derive` — the two goldens the removed and the retained clauses cite —
so their non-movement could be checked rather than assumed (§6.5).

### 5.5 MOVERS PER SHAPE, BY MULTISET

`sed 1d` on every dump; ADDED and REMOVED counted **separately** and never
netted; every REMOVED shape checked against **GOLDEN's own count**, which is the
only test that says a mover is a CONVERGENCE.

**SVSwitch** (identical in both modes), OUR side, pristine → shipped. There are
**no ADDED shapes at all** — on this test the law only removes:

```
                                                              GOLD PRIS SHIP
REMOVED +1  \_logic_net: (work@top.mem_intf), 44:14-44:22         0    1    0
REMOVED +1  \_logic_net: (work@top.input_intf), 44:23-44:33       0    1    0
REMOVED +1  \_logic_net: (work@top.output_intf), 44:34-44:45      0    1    0
REMOVED +3  \_module_inst: work@top (work@top), 12:1-73:10       28   31   28
```

**Every one of the four object shapes lands on golden's count EXACTLY**
(shipped == golden on all four; pristine over by exactly the amount removed).
There is no fifth shape, no relocation and no net-zero pairing. The
`\_module_inst` line is the three removed nets' own `vpiParent` reprint, which
is why it moves by exactly 3.

The bare field lines each lost the matching amount and are listed by
`msmovers.sh` as NON-ATTRIBUTABLE absorbers, never counted as object movement:
`|vpiNet:` -3, `|vpiParent:` -3, `|vpiNetType:1` -3, and one `|vpiName:` +
`|vpiFullName:` per net.

Distance accounting closes exactly: ours-only line instances 878 → 857
(**-21** = the 4 object shapes' 6 line instances + 3 `vpiNet` + 3 `vpiParent`
+ 3 `vpiNetType` + 3 `vpiName` + 3 `vpiFullName`), golden-only unchanged at
476, net **1354 → 1333**.

#### 5.5.1 `Scoreboard/default` — THE KNOWN FLAKE, EXECUTED, AND A FALSE MOVER

The ops rules name this row MULTI-STABLE and require a 3-rep plus a size delta
before attributing anything to it. Run on BOTH binaries, from the test's own
source directory, with the argv taken verbatim from the workdir's `cmds.txt`:

```
ship  rep1 md5=9cf807ea56e4e00d bytes=11133449
ship  rep2 md5=1ba839e9c6080f2e bytes=11133449
ship  rep3 md5=0735c667b15d9bea bytes=11133449     <-- the verifier's "patched" sample
pris  rep1 md5=0163f3d486538b8a bytes=11133449     <-- the verifier's "pristine" sample
pris  rep2 md5=1ba839e9c6080f2e bytes=11133449
pris  rep3 md5=1ba839e9c6080f2e bytes=11133449
```

**THREE HASHES ON THE SHIPPED BINARY, ONE SIZE ON ALL SIX, AND THE TWO BINARIES'
HASH SETS INTERSECT** — `1ba839e9c6080f2e` is produced by both. The verifier
happened to sample `0735c667` for "patched" and `0163f3d4` for "pristine"; the
reverse sampling was equally available. Content, measured rather than inferred:

```
MULTISET DISTANCE  pristine rep2  vs  shipped rep1 :  0   (1095684 lines both)
MULTISET DISTANCE  shipped  rep1  vs  shipped rep3 :  0   (same-binary control)
MULTISET DISTANCE  pristine rep1  vs  shipped rep3 :  0   (the verifier's OWN two samples)
```

**Zero content difference across binaries, the same zero within one binary, and
zero between the exact two files the verifier compared.** `Scoreboard/default`
carries no interface connection list of this shape at all and is a FALSE MOVER
on four instruments. Note the contrast with r10svs9, where the same row was a
REAL mover: there it showed a −237 byte size delta; here the size is identical
to the byte on all six runs. The size delta is what separates the two cases,
which is exactly why the ops rule demands it.

### 5.6 CANARIES

```
surelog  canaries.sh  ok=52  changed=0  absent=0   unknown-names=7  (expected 7)
         ctcan2.sh    ok=58  changed=0  absent=0   unknown-patterns=1  EXPECT_UNKNOWN=1
u2r      canaries.sh  ok=8   changed=0  absent=0   unknown-names=25 (expected 25)
         ctcan2.sh    ok=1   changed=0  absent=0   unknown-patterns=6  EXPECT_UNKNOWN=6
canaudit.sh  audited=29  UNCOVERED=0  FENCE-BREACH=0
```

Baseline passed FIRST and the fresh CSV mode-matched, per the ops rule: the
PRISTINE csv was run through `canaries.sh` against the committed baseline before
the shipped csv was, and both read `ok=8 changed=0` on u2r / `ok=52 changed=0`
on surelog. The two canaries the rules require BY NAME, checked by name before
any aggregate:

```
InterfaceModPort    baseline default/testflags  fresh IDENTICAL
BlackParrotComplex  baseline default/testflags  fresh IDENTICAL
```

`canaudit` also re-confirms the four SLANG-FENCED names (`UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched by no driver here.

---

## 6. REFUTATIONS

**6.1 THE BRIEF'S TWO NAMED SUSPECTS, BOTH REFUTED.** The brief directed this
pass to "check R2 (parameterized-class name span: golden `P`, ours `P#(2)`) and
R3 (interface-class handle: golden `unsupported_typespec`, ours
`class_typespec`) against the localized pair before building anything new".
Neither is the pair and neither is even present: the failing comparison is an
integer `Nets()->size()` difference, and SVSwitch's `top.sv` declares no class
handle at all — the only `class_typespec` objects r10svs10 added to this test
live in `work@testcase`, a different `program`, several vectors away from the
head. Both suspects were checked first, as instructed, and both were excluded
before any code was written.

**6.2 THE PRODUCER'S OWN PREDICATE, REFUTED IN BOTH DIRECTIONS.** `hasOrderedConns
&& mixed9` over-mints on all-interface udp-shaped lists (`c2` e2/e3, 5 cells —
SVSwitch's own shape) and under-mints on ordered lists that are not udp-shaped
(`c2` e6/e7/e8/e12/e14, 5 cells). A predicate that is wrong in both directions
is not an approximation of the law; it is a different law.

**6.3 CHILD KIND, REFUTED.** `program` and `module` children behave identically
in golden — `c1` a1/a3 and a2/a4 at count 1 (both MINT), and reduction `r6` at
count 3 (both NONE). The seed observation that SVSwitch's `TC` is a `program`,
and that golden lists no `ref_module` for it in `work@top`, is a coincidence of
the witness: the net rule never consults the child's kind.

**6.4 INTERFACE-PORT COUNT, REFUTED — and it was this pass's own first law.**
The grid's first six cells (`n1p`/`n2p`/`n3p` and their named twins) are all
consistent with "an ordered list mints only when the child has exactly ONE
port", and that is what this pass wrote down before testing further. `c2` e6 and
e7 refute it: two ordered terminals, and golden MINTS — because the first
terminal is an operation, so the parser never took the UDP alternative. The
count is a CONSEQUENCE of `udpShapedInstantiation`'s `size() < 2`, not the law.
Had the count law been shipped, e6/e7/e12/e14 would have stayed wrong and e8
would have regressed.

**6.5 THE REMOVED CLAUSE'S CITED GOLDEN SURVIVES THE REMOVAL.**
`iface_method_call h1(hintf, su, …)` was the witness for `mixed9`. It has three
ordered terminals with `hintf` (an identifier, hence a `net_lvalue`) first, so
it IS udp-shaped and the new gate still skips it — and the byte verifier proves
it byte-for-byte: `iface_method_call` is one of the 679 u2r databases and
**0 of 679 moved**. `load_and_derive`, the citation for the retained
implicit-named clause, is likewise unmoved. A citation that survives the
deletion of the thing it cites was never evidence for it.

**6.6 THIS PASS'S OWN CENSUS OVER-COUNTED BY A FACTOR OF 41, and the byte
verifier corrected it.** 82 upper-bound carriers named, 2 movers found. The
predicate models two NECESSARY conditions and none of the four sufficient ones,
and it is reported as a filter rather than a prediction (§5.4.2). Same lesson as
r10svs10's census from the same side: **a census is only as good as the
predicate it names, and only the verifier settles it.**

---

## 7. RESIDUES, RANKED

**R1 — THE SVSwitch SUCCESSOR HEAD: the `port` of `module_array
(work@output_interface)`, 54 cmp lines, identical in both modes.** A clean
TWO-FIELD pair on one object, and the next target on this row:

```
LHS golden  port: , id:1164, 38:33-38:38          <- vpiName EMPTY
            \_ref_obj: (work@top.output_intf.Clock)      38:33-38:38
RHS ours    port: (clock), id:2636                <- vpiName "clock", and NO span
            \_ref_obj: (work@top.output_intf.clock.Clock) 38:33-38:38
```

Two differences, both compared: (a) the port's `vpiName` — golden leaves an
interface-ARRAY's port unnamed, we name it after the formal; (b) the highconn
`ref_obj`'s `vpiFullName` — ours interposes the formal name (`.clock.`) that
golden omits. Ours also carries no source span on the `port` while golden spans
the actual. Highest-ranked by a wide margin: 54 lines, one object, and
`module_array` port naming is a shape every interface-array design has.

**R2 — the SVSwitch row's remaining distance is 1333 with `golden-only` at 476
and `ours-only` at 857.** The asymmetry is the standing shape of this row: we
still emit 857 line instances golden does not. Nothing in this pass's grid
accounts for any of them, so the next passes' heads are the only instrument.

**R3 — `udpShapedInstantiation` is now applied at FOUR call sites and derived
from ONE decoded parser law, but the law is stated only in comments.** Four
sites, four independent chances to forget it; the campaign's own history
(`mixed9` here, and the class-handle strip in r10svs10) is that a predicate
duplicated by hand drifts. Deferred deliberately under the no-premature-
extraction rule — the converged corpus is the spec — but worth naming as a
consolidation candidate for after 0 DIFF/0 CMP_ONLY.

**R4 — golden's `work@top` lists NO `ref_module` for the `program` instance
`TC`, and ours agrees.** Recorded as a NON-residue, measured not assumed: it was
the first hypothesis when `c1` refuted child kind, and the depth-0 census in
§1.1 shows both sides at `vpiRefModule` = 3 with the same three children. No
work needed; noted so the next pass does not re-open it.

---

## 8. FILES

```
README.md           this record
svs11arm.sh         one arm: Surelog + ours + dumps + cmp, in its own scratch dir
svsgen.sh           the SVSwitch pair, both modes, through the harness itself
gridread.sh         run one arm and print its Nets() cell table
netread.py          the grid reader: the DIRECT members of one object's one
                    vector, indent-walked so vpiParent/vpiActual reprints are
                    not counted; span-keyed on both sides
census.sh           the carrier census, both corpora (an UPPER BOUND -- see 5.4.2)
c1_childkind.sv     child kind x formal form x connection style  (all REFUTED)
c2_udpshape.sv      THE DECISIVE ARM: the connection list's parse, 14 shapes
c3_ifacearray.sv    the interface-ARRAY connection-site net, same axes
byteverify.sh ct8rows.sh canaries.sh ctcan2.sh canaudit.sh msdist.sh msmovers.sh
                    the gate + canary harness, carried from r10svs10repro unchanged
```
