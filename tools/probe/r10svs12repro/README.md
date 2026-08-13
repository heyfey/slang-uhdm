# r10svs12 — A BROADCAST PORT IS BUILT FROM THE CONNECTION AS WRITTEN, AND THE WHOLE 54-LINE HEAD WAS **ONE** COMPARED FIELD

**Verdict, up front: SVSwitch DID NOT CONVERT.** Both rows are unchanged from
the committed baseline, so this pass is read in the **UNCONVERTED world** of
GATE 4 and every gate below is judged against the unconverted expectation:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

No `results/*.csv` was touched by this pass.

The brief's target head — `port: , id:1164, line:38:33, endln:38:38` under
`module_array (work@output_interface)`, **54 cmp lines, identical in both
modes** — is **CLEARED**, and the head **ADVANCED out of the def view
entirely**: from `design::AllModules()` (generated `design.cpp:302`) to
`design::TopModules()` (`design.cpp:308`), across six intervening design-level
vectors.

* **THE HEAD WAS ONE COMPARED FIELD — the port's `vpiName`** — and the brief's
  instruction to "check which of ITS fields are compared before assuming" pays
  off in the *opposite* direction from the brief's framing: **`ref_obj::Compare`
  does NOT compare `VpiFullName`, and NO `Compare` anywhere compares a source
  span.** The highconn-fullname and port-span differences the brief names
  alongside the name are **dump-only byte-cosmetics** (§1.2). Fixing the name
  alone would have cleared the head; fixing the fullname alone would have moved
  nothing.
* **ONE LAW, `§ arrayBcastPortPositionalNoFormal12`**, and it is a
  TRANSCRIPTION of a rule the tree already carried 470 lines further down for
  the `ref_module` writer — three clauses, same reason, same shape (§2).
* **THE EXECUTABLE CHANGE IS 10 ADDED LINES** in one function
  (`src/ModuleEmit.cpp`, `emitModuleArray`); of the 43 inserted lines, **33 are
  the comment that records the measurement**.
* **GRID: 34 port cells + 3 container-absence cells across FOUR arms.
  Full-triple EQ 16 → 20; COMPARED-fields-only EQ 19 → 24. NOT ONE CELL
  REGRESSED** (§3).
* **FIVE GATES GREEN** (§5) under the UNCONVERTED expectation.
* **MOVERS: 2** (`SVSwitch` in both modes) out of 1632 databases across both
  corpora. The verifier printed 3; the third is `Scoreboard/default`, the named
  flake, **executed to 3 reps on both binaries and measured to zero content
  distance** (§5.6.1).
* **SEVEN REFUTATIONS** (§6), three of them against this pass's own brief, one
  against the immediately preceding pass's write-up, and one against a comment
  this pass's own earlier draft had already committed to a probe file.

Base commit `ed1e6ce`, branch `auto5h`.
Pristine binary md5 **`d4890e6fd39981373e5497b9eaf67e31`** (worktree
`/tmp/wt_r10svs12pris`, `git rev-parse HEAD` = `ed1e6ce87c89dfc870f8d00cb97d86cce30a4045`,
`git status --porcelain` EMPTY — both printed in §5.1).
Shipped binary md5 **`0ba389807cb1de8f416942e491c2afa5`** (worktree
`/tmp/wt_r10svs12`, same `HEAD`, `git status --porcelain` = exactly
` M src/ModuleEmit.cpp` + `?? tools/probe/r10svs12repro/`).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script in
this directory.

---

## 1. LOCALIZATION — WHICH FIELDS ARE COMPARED, DECIDED FIRST

### 1.1 The head, on both sides, verbatim

```
LHS golden   port: , id:1164, line:38:33, endln:38:38
             |vpiParent:  \_module_array: (work@output_interface), id:1161, 38:18-38:29
             |vpiHighConn:
             \_ref_obj: (work@top.output_intf.Clock), id:1165, 38:33-38:38
               |vpiName:Clock
               |vpiFullName:work@top.output_intf.Clock
               |vpiActual:  \_logic_net: (work@top.Clock), id:4377, 17:5-17:10

RHS ours     port: (clock), id:2636                       <- NO span at all
             |vpiParent:  \_module_array: (work@output_interface), 38:18-38:29
             |vpiName:clock
             |vpiHighConn:
             \_ref_obj: (work@top.output_intf.clock.Clock), 38:33-38:38
               |vpiName:Clock
               |vpiFullName:work@top.output_intf.clock.Clock
               |vpiActual:  \_logic_net: (work@top.Clock), 17:5-17:10
```

Three differences: the port's **name** (golden empty, ours `clock`), the port's
**span** (golden the actual `Clock` at 38:33-38:38, ours none) and the highconn
ref's **fullname** (ours interposes the formal `clock`).

### 1.2 EXACTLY ONE OF THE THREE IS COMPARED

Read off the generated comparators, not inferred:

```cpp
// UHDM/templates/BaseClass.cpp — BaseClass::Compare, in full:
//   VpiType, VpiName, VpiDefName.  THAT IS ALL.  No vpiLineNo, no vpiColumnNo.
// UHDM/build/generated/src/ports.cpp:157-179 — ports::Compare:
//   basetype_t::Compare (-> BaseClass: VpiName), VpiPortIndex, VpiName (again),
//   VpiPortType, VpiScalar, VpiVector, VpiConnByName, VpiDirection, VpiSize,
//   VpiExplicitName, then High_conn, Low_conn, Typespec, Instance, Module_inst.
// UHDM/build/generated/src/ref_obj.cpp — ref_obj::Compare:
//   VpiType, basetype_t (expr: VpiDecompile, VpiSize, Typespec; BaseClass:
//   VpiName, VpiDefName), VpiName, VpiDefName, VpiGeneric, Actual_group,
//   VpiStructMember.   <-- NO VpiFullName.  NO span.
```

So:

| difference | compared? | by what |
|---|---|---|
| port `vpiName` `""` vs `clock` | **YES**, twice | `BaseClass::Compare`, then `ports::Compare` |
| port source span | **NO** | no comparator reads `vpiLineNo`/`vpiColumnNo` |
| highconn ref `vpiFullName` | **NO** | `ref_obj::Compare`'s field list omits it |
| highconn ref `Actual_group` | YES | identical on both sides (`work@top.Clock`) |

**The 54-line head was the port's `vpiName` and nothing else.** The other two
are real byte-differences that the dump shows and `uhdm-cmp` does not read; they
are fixed here because they are the same producer bug, and they are reported as
DUMP-ONLY throughout rather than dressed up as compared failures.

### 1.3 The head ADVANCED — measured, not asserted

`cmp` HEAD DEPTH went 54 → **1603**, which is a DEPTH and not a distance. The
question the number cannot answer is whether the head moved LATER or EARLIER,
and the compare order settles it:

```
design::Compare   (generated design.cpp)
  295 Include_file_infos   296 AllPackages   297 TopPackages   298 AllClasses
  299 AllInterfaces        300 AllUdps       301 AllPrograms
  302 AllModules   <-- the DEF view.  THE OLD HEAD LIVED HERE
        work@top -> module_inst::Compare:398 Module_array -> ports -> port::vpiName
  303 Typespecs 304 Let_decls 305 Task_funcs 306 Parameters 307 Param_assigns
  308 TopModules   <-- the ELAB view.  THE NEW HEAD LIVES HERE
        work@top -> instance::Compare:332 Programs -> program::Compare Interface_arrays
```

The dump confirms the two views are two distinct `module_inst: work@top`
subtrees (ours: `default.o.dump` lines 16173 and 16877; golden: 16166 and
16870), the old head's hunk is at line ~16272 (inside the FIRST = def one) and
the new head is at ~16897 (inside the SECOND = elab one). **The head moved from
design vector 302 to design vector 308.** It is an advance by six vectors, and
the whole def-view `AllModules` comparison now returns 0.

### 1.4 The new head is fully localized, and it is NOT this pass's doing

`LHS: <null>` / `RHS: program: work@testcase (work@top.TC)` is the signature of
the vector `SafeCompare`'s one-sided branch, which sets **only** `m_failedRhs`
and to the **CONTAINER**:

```cpp
// UHDM/build/generated/uhdm/BaseClass.h:218
} else if ((lhs == nullptr) && (rhs != nullptr) && !rhs->empty()) {
    context->m_failedRhs = rhs_obj;      // <- the program, not an element
    return -1;
}
```

Diffing the two elab `program work@testcase` subtrees names the vector: golden's
is 126 dump lines, ours is **607**, and the 481 extra are a whole
`|vpiInterfaceArray:` → `interface_array: (work@top.TC.output_intf) 18:95-18:106`
that golden does not have. `program::Compare` reaches `Interface_arrays()` as its
7th own field, after `VpiIndex`, `VpiType`, `Default_clocking`, `Instance_array`,
`Interfaces`, `Expr_dist`. That `Interfaces()` (the neighbour that produces the
identical `LHS: <null>` signature) is NOT the failing one is measured, not
assumed: censusing the two program subtrees' OWN-INDENT field labels gives

```
golden  vpiParent vpiName vpiFullName vpiVariables x2 vpiDefName vpiDefFile
        vpiDefLineNo vpiInstance                  vpiProcess x2 vpiPort x3
ours    vpiParent vpiName vpiFullName vpiVariables x2 vpiDefName vpiDefFile
        vpiDefLineNo vpiInstance vpiInterfaceArray vpiProcess x2 vpiPort x3
```

— **no `|vpiInterface:` on either side, `|vpiInterfaceArray:` on ours alone**, and
the three `vpiPort`s (equal in count) are compared AFTER it and never reached.
That is R1 in §7.

**It is pre-existing, and this is the proof rather than the argument**: the
ENTIRE delta between the pristine and shipped SVSwitch databases is the 9-line
hunk in §5.5. Our elab program subtree is byte-identical on both binaries, so
its failure was there before this pass and was merely hidden behind the def-view
port head.

---

## 2. THE LAW

### § arrayBcastPortPositionalNoFormal12

> **A `module_array`'s broadcast port is built from the connection AS WRITTEN,
> not from the formal it resolves to.** When the instantiation's connection list
> is **ORDERED (positional)**, each broadcast port is
> **(a) NAMELESS** — no `vpiName` at all, not the formal's name;
> **(b) ANCHORED AT THE ACTUAL** — its source span is the actual expression's
> span, because there is no `.formal(actual)` text to span; and
> **(c) SCOPED THROUGH THE ARRAY ALONE** — the HighConn ref's fullname is
> `<module>.<array>.<actual>`, with the formal absent, because Surelog leaves
> that fullname unset and UHDM computes it at write time by walking
> `ref -> port -> module_array -> module`, and a nameless port contributes
> nothing to the walk.
> A **NAMED** connection keeps all three the other way: the formal's name, the
> whole `.formal(actual)` span, and `<module>.<array>.<formal>.<actual>`.
> The rule is **INDEPENDENT of the child's kind** (module or interface) and of
> the container's kind (interface array, module array, scalar `ref_module`).

Only (a) is a compared field (§1.2). (b) and (c) are dump-only and are fixed
because they are the same producer bug read off the same syntax node.

### STATED GATE == CODE GATE

The gate in `src/ModuleEmit.cpp` is, in full, after this pass:

```cpp
bool orderedA = hasOrderedConns(*rep);          // src/ModuleEmit.cpp:2278
…
if (!orderedA)                                   // (a) NAMELESS
    p->VpiName(conn->port.name);
p->VpiParent(ma);
if (npcA)
    setLoc(p, npcA->sourceRange());
else if (orderedA)                               // (b) ANCHORED AT THE ACTUAL
    setLoc(p, ax->sourceRange);
…
std::string connScopeA =                         // (c) NO FORMAL IN THE SCOPE
    prefix + "." + std::string(arr.name) +
    (orderedA ? "" : "." + std::string(conn->port.name));
r->VpiFullName(connScopeA + "." + std::string(rsym->name));
```

and `hasOrderedConns` (`src/EmitHelpers.h:1243`, **UNCHANGED** by this pass) is:

```cpp
inline bool hasOrderedConns(const InstanceSymbol& inst) {
    auto syn = inst.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::HierarchicalInstance) return false;
    for (auto conn : syn->as<syntax::HierarchicalInstanceSyntax>().connections)
        if (conn->kind == syntax::SyntaxKind::OrderedPortConnection) return true;
    return false;
}
```

**The gate reads SYNTAX KINDS ONLY — no name, no string, no count, no child
kind, no modport test, no interface test.** That is exactly what the law above
says, and §3 measures each of those non-conditions as a separate refuted axis.
Because the gate reads no name, escaped identifiers cannot reach it; arm **d4**
(§3.4) measures that claim instead of asserting it, on both branches and on both
sides of the connection.

### What was there before, and why it was wrong

Before: the port was named `conn->port.name` **unconditionally**, got a span
only when a `NamedPortConnectionSyntax` existed (so a positional port got
**none**), and the HighConn fullname **always** interposed
`"." + conn->port.name`. Read as a claim about golden it says *a broadcast port
is the FORMAL* — and golden's broadcast port is the CONNECTION. The two coincide
for a named list and disagree in all three fields for a positional one.

### It was already in the tree, 470 lines down

`emitRefModule`'s port writer (`src/ModuleEmit.cpp:2730-2770`) already obeys the
same three clauses for the scalar `ref_module` case, `connScope9` included, and
it was already RIGHT for that case before this pass — arm cells **d1 h8** and
**d2 m7** are EQ on the pristine binary. This pass makes the array writer agree
with the module writer. That is why `d1 h8/h9` and `d2 m7/m8` are the controls
that must not move, and they do not.

---

## 3. THE GRID, CELL FOR CELL

Read by `portread.py`, which walks the dump's **indent column** and collects only
the objects at the container's own indent+2 under a `|vpiPort:` label — necessary
because each port is REPRINTED inside its own children as a `vpiParent`
back-pointer, so a `grep` over the subtree over-counts. Containers are keyed by
their **SOURCE SPAN**, not their name: a `module_array` header carries only
`(work@<def>)`, so two arrays of the same interface would collide on a name key.

A cell is the triple **(port name, port span, HighConn kind+name+fullname)** on
both sides. Two tallies are reported for every arm and they are not the same
number:

* **FULL-TRIPLE EQ** — the whole triple matches, span included. This is the
  DUMP/byte view.
* **COMPARED EQ** — only the fields §1.2 proves `uhdm-cmp` reads: the port's
  `vpiName` and the HighConn's `VpiType`. This is the cmp view.

Reported side by side because conflating them is exactly the mistake §1.2
corrects. `MINT`/`NONE`-style absence cells (a container golden does not build
at all) are counted separately and never folded into the port-cell totals.

All four arms were run on BOTH binaries from the same script
(`gridread.sh` / `d1read.sh`), in per-arm scratch dirs, and both columns are
still on disk (`/tmp/r10svs12_arm_{pris,ship}_*`).

### 3.1 `d1_ifacearrayport.sv` — CONNECTION STYLE x PORT COUNT x WRITTEN ORDER

Container fixed as an INTERFACE array; the axis under test is the connection
list's written style.

```
cell  instantiation                     style        GOLDEN name/span/hc-full            PRIS      SHIP
h1    if1 a1[4](Clock)                  positional   ""  / 39:11-39:16 / …a1.Clock       DIF       EQ
h2    if1 a2[4](.clk(Clock))            named        clk / 41:11-41:22 / …a2.clk.Clock   EQ        EQ
h4    if2 a4[4](.clk(C), .rst(R))       named x2     clk / 45:11-45:22 / …a4.clk.Clock   EQ        EQ
                                                     rst / 45:24-45:33 / …a4.rst.Rst     EQ        EQ
h5    if2 a5[4](.rst(R), .clk(C))       named x2 REV rst / 47:11-47:20 / …a5.rst.Rst     EQ        EQ
                                                     clk / 47:22-47:33 / …a5.clk.Clock   EQ        EQ
h6    if1 a6[4](.clk())                 named EMPTY  ""  / 49:11-49:17 / (no highconn)   DIF       DIF
h7    if1 a7[4](.clk)                   `.name`      clk / 51:11-51:15 / (no highconn)   DIF       DIF
h8    if1 s1(Clock)                     SCALAR pos   ""  / 54:8-54:13  / …s1.Clock       EQ        EQ
h9    if1 s2(.clk(Clock))               SCALAR named clk / 56:8-56:19  / …s2.clk.Clock   EQ        EQ
h10   if1 a8[2](Clock)                  positional   ""  / 58:11-58:16 / …a8.Clock       DIF       EQ
absence cell
h3    if2 a3[4](Clock, Rst)             positional x2 — GOLDEN BUILDS NO def module_array
                          port cells 11   full-triple EQ 7 -> 9    compared EQ 7 -> 9
```

**Golden is nameless-at-the-actual for every positional cell and formal-named
for every named cell, with no exception.** h8/h9 are the scalar `ref_module`
controls that already matched and still match. h6/h7 are UNTOUCHED pre-existing
DIFs and are R2/R3 in §7 — for h6 golden has a nameless port and we emit **none**
at all; for h7 golden's port has **no** HighConn and we emit one.

### 3.2 `d2_modarrayport.sv` — THE MODULE (NON-INTERFACE) ARRAY TWIN

`emitModuleArray`'s port loop is shared with module arrays in the DEF view, so
this arm is the blast-radius measurement for the module side, cell for cell.

```
cell  instantiation                     style        GOLDEN name/span/hc                 PRIS      SHIP
m1    leaf1 b1[4](Clock)                positional   "" / 25:13-25:18 / ref_obj …b1.Clock   DIF    EQ
m2    leaf1 b2[4](.a(Clock))            named        a  / 27:13-27:22 / ref_obj …b2.a.Clock EQ     EQ
m4    leaf2 b4[4](.a(C), .b(R))         named x2     a, b                                  EQ EQ  EQ EQ
m6    leaf2 b6[4](.b(R), .a(C))         named x2 REV b, a                                  EQ EQ  EQ EQ
m7    leaf1 c1(Clock)                   SCALAR pos   "" / 37:10-37:15 / ref_obj …c1.Clock   EQ     EQ
m8    leaf1 c2(.a(Clock))               SCALAR named a  / 39:10-39:19 / ref_obj …c2.a.Clock EQ     EQ
m9    leaf1 b7[4](Vec[0])               positional   "" / 44:13-44:19 / bit_select …b7.Vec  DIF    DIF*
m10   leaf1 b8[4](.a(Vec[0]))           named        a  / 47:13-47:23 / bit_select …b8.Vec  DIF    DIF*
absence cells
m3    leaf2 b3[4](Clock, Rst)           positional x2, no #()  — GOLDEN BUILDS NO container; ours neither  EQ
m5    leaf3 #(1) b5[4](Clock, Rst)      positional x2 under #() — GOLDEN BUILDS NO container; ours builds 2 ports  DIF both
                          port cells 12   full-triple EQ 7 -> 8    compared EQ 8 -> 9
```

`*` **m9 ADVANCED without becoming EQ, and m10 was never a compared DIF.** m9's
name and span now match golden exactly and its fullname went
`work@top.b7.a.Vec` → `work@top.b7.Vec` = golden's; what remains is the HighConn
OBJECT KIND (golden `bit_select`, ours `ref_obj`), which IS compared
(`ref_obj::Compare`'s first field is `VpiType`) and is R4 in §7. m10's only
difference in either binary is the `bit_select`'s **fullname** — golden does NOT
interpose the formal there even for a NAMED connection — which is dump-only and
is R5.

**m5 is the one cell whose DIF CONTENT changed**: golden builds no container, we
build two ports either way, and their names went `a`/`b` → nameless. It was DIF
before and is DIF after, on both tallies; nothing regressed, and the honest
reading is that the law is being applied inside a container golden does not have
at all (see §6.7).

### 3.3 `d3_hcshape.sv` — THE ACTUAL'S FORM, BOTH STYLES, INTERFACE ARRAY

```
cell  instantiation                 style        GOLDEN name / hc kind        PRIS   SHIP
k1    if1 d1[4](Clock)              positional   ""  / ref_obj                DIF    EQ
k2    if1 d2[4](.clk(Clock))        named        clk / ref_obj                EQ     EQ
k3    if1 d3[4](Vec[0])             positional   ""  / bit_select   ours NONE  DIF    DIF
k4    if1 d4[4](.clk(Vec[0]))       named        clk / bit_select   ours NONE  DIF    DIF
k5    if1 d5[4](Clock & 1'b1)       positional   ""  / operation    ours NONE  DIF    DIF
k6    if1 d6[4](.clk(Clock & 1'b1)) named        clk / operation    ours NONE  DIF    DIF
k7    if1 d7[4](1'b0)               positional   ""  / constant     ours NONE  DIF    DIF
                          port cells 7   full-triple EQ 1 -> 2    compared EQ 1 -> 2
```

k3–k7 are the `ifaceArr` boundary this pass deliberately did NOT touch: for an
INTERFACE array the producer skips every non-`NamedValue` actual, so we emit no
port at all where golden emits one. Five cells, one cause, R6 in §7. Their value
here is as a FENCE: they are DIF-identical on both binaries, which proves the
new gate did not silently reroute the select-syntax branch.

### 3.4 `d4_escaped.sv` — ESCAPED IDENTIFIERS, THE OPS-MANDATED ARM

The gate reads no name (§2), but the law DELETES a name and REWRITES a fullname,
so escaped spellings are exactly where a name-shaped law goes wrong.

```
cell  instantiation                     style       GOLDEN name / hc-full        PRIS         SHIP
e2    ifE e2[4](.clk(C), .\r$t (R))     named x2    clk  / …e2.clk.Clock         EQ           EQ
                                                    r$t  / …e2.r$t.Rst           DIF(span)    DIF(span)
e3    ifE e3[2](\Cl$ck )                positional  ""   / …e3.Cl$ck             DIF(3 flds)  DIF(span)
e4    ifE e4[2](.\r$t (R))              named       r$t  / …e4.r$t.Rst           DIF(span)    DIF(span)
absence cell
e1    ifE e1[4](\Cl$ck , Rst)           positional x2 — GOLDEN BUILDS NO def module_array
                          port cells 4   full-triple EQ 1 -> 1    compared EQ 3 -> 4
```

**e3 is the answer.** On the pristine binary all three fields were wrong
(`name=clk`, no span, `work@top.e3.clk.Cl$ck`); on the shipped one the **name is
empty and the fullname is `work@top.e3.Cl$ck` — golden's, character for
character, `$` included.** The residual difference is the SPAN and it is
**Surelog's own escaped-identifier span, not ours**: golden reports
`31:11-31:22` for a `\Cl$ck ` token that occupies columns 11-17 of a 19-column
line, over-running the line end by four. The identical **+4** over-run appears
on golden's NAMED cells e2 (`29:24-29:39` vs our `29:24-29:35`) and e4
(`33:11-33:26` vs `33:11-33:22`), on BOTH binaries. So it is one pre-existing,
style-independent, UNCOMPARED Surelog escaping artifact (R7), and the compared
tally is the one that moves: **3 → 4 of 4**.

### 3.5 Totals

```
arm   port cells   full-triple EQ   compared EQ   absence cells
d1        11          7 ->  9         7 ->  9        1  (h3)
d2        12          7 ->  8         8 ->  9        2  (m3 EQ, m5 DIF)
d3         7          1 ->  2         1 ->  2        -
d4         4          1 ->  1         3 ->  4        1  (e1)
      --------      -----------     -----------
          34         16 -> 20        19 -> 24        4
```

**Not one cell regressed on either tally.** Five cells converged on the compared
tally (h1, h10, m1, k1, e3), four on the full-triple tally (the same minus e3,
whose remaining difference is Surelog's escaped-id span). Every cell EQ on the
pristine binary is EQ on the shipped one.

---

## 4. THE PRODUCER

`src/ModuleEmit.cpp`, `emitModuleArray`'s broadcast-port loop (~line 2244-2380).
The loop runs for an INTERFACE array in both views and for a MODULE array in the
DEF view only (`modElems` returns early). Per written connection it mints a
`port` parented at the `module_array`, and a HighConn — either through
`emitSyntaxExpr` (named conn, select actual, module array only) or as a bare
`ref_obj`.

The change is confined to that loop:

```
 src/ModuleEmit.cpp | 48 +++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 43 insertions(+), 5 deletions(-)
```

and 33 of the 43 insertions are the comment recording the measurement. The
executable delta, in full:

```
+    bool orderedA = hasOrderedConns(*rep);         // hoisted, was inline below
-    if (!hasOrderedConns(*rep)) {                  // the def-order re-key, unchanged
+    if (!orderedA) {
-        p->VpiName(conn->port.name);
+        if (!orderedA)
+            p->VpiName(conn->port.name);
+        else if (orderedA)
+            setLoc(p, ax->sourceRange);
-        r->VpiFullName(prefix + "." + arr.name + "." + conn->port.name + "." + rsym->name);
+        std::string connScopeA = prefix + "." + arr.name +
+                                 (orderedA ? "" : "." + conn->port.name);
+        r->VpiFullName(connScopeA + "." + rsym->name);
```

**No other rule in this loop is disturbed**, and that is measured rather than
argued. The def-order re-key block still runs for named lists only and is
byte-identical (`hasOrderedConns(*rep)` → the identically-valued `orderedA`);
`ifaceArr`'s non-`NamedValue` skip, the `emitSyntaxExpr`/`syntaxRefPrefix`
select branch, the `modElems` early return and the `udpFormInstantiation`
container gate are all untouched, and cells **d2 m3/m5/m10**, **d3 k3-k7** hold
each of them fixed while the new gate moves. `hasOrderedConns` itself is
UNCHANGED — its four other call sites (`ModuleEmit.cpp:2542`, `:2605`, `:8672`,
`:24134`) are byte-identical, and GATE 3's 0 differing rows over 731
uhdm2rtlil tests is the blast-radius measurement for that.

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

```
/tmp/wt_r10svs12                    (shipped)
[ 88%] Linking CXX executable slang-uhdm      <- the link line, forced and waited for
[100%] Built target slang_uhdm
SHIP_RC=0     compiler "error:" lines: 0
md5(build/slang-uhdm) = 0ba389807cb1de8f416942e491c2afa5
   32-HEX ASSERT: OK (len=32)                 <- asserted SEPARATELY from the build
git rev-parse HEAD  = ed1e6ce87c89dfc870f8d00cb97d86cce30a4045
git status --porcelain =  M src/ModuleEmit.cpp
                        ?? tools/probe/r10svs12repro/

/tmp/wt_r10svs12pris                (pristine, built HERE, not reused from another pass)
[100%] Built target slang_uhdm
PRIS_RC=0
md5(build/slang-uhdm) = d4890e6fd39981373e5497b9eaf67e31
   32-HEX ASSERT: OK (len=32)
git rev-parse HEAD  = ed1e6ce87c89dfc870f8d00cb97d86cce30a4045
git status --porcelain = <EMPTY>
```

The shipped binary was **relinked from scratch** (`rm build/slang-uhdm` then
rebuild) so the link line is real and not a stale-target message, and the md5
reproduced identically across the incremental and the forced-relink builds.

**THE BASE MARKER IS BEHAVIOURAL AND TWO-DIRECTIONAL.** This pass adds no new
symbol — the law name lives only in comments (`strings | grep -c
arrayBcastPortPositionalNoFormal12` = **0** on the shipped binary, so quoting it
would be a guard that does not guard) — and the predicate it applies is a
pre-existing `inline` function. The substitute is stated in BOTH directions so a
binary cannot pass it by accident:

```
SOURCE     grep -c arrayBcastPortPositionalNoFormal12 src/ModuleEmit.cpp
             shipped worktree = 3      pristine worktree = 0
BEHAVIOUR  arm d3 cell k1, port vpiName  (a name REMOVED)
             shipped = <EMPTY>          pristine = clk
BEHAVIOUR  arm d3 cell k1, port span     (a span ADDED)
             shipped = 32:11-32:16      pristine = NOSPAN
CONTROL    arm d3 cell k2 (NAMED)        both binaries = clk / 34:11-34:22
```

All four were run on every binary these gates quote.

### GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped>  tests/check_goldens.sh  ->  23 PASS / 0 FAIL   (rc=0)
SLANG_UHDM=<pristine> tests/check_goldens.sh  ->  23 PASS / 0 FAIL   (rc=0)
SLANG_UHDM=/bin/false tests/check_goldens.sh  ->   0 PASS / 23 FAIL  (rc=1, control FIRES)
```

Stated honestly: none of the 23 goldens carries a positionally-connected
instance ARRAY, so they prove this law broke nothing; **they cannot confirm it.**
The instruments that confirm it are §3 and GATE 5.

### GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
PRISTINE control sweep, judged the same way:   0 differing ROWS (0 diff row-sides)
```

### GATE 4 — surelog `--mode both --jobs 2` (`GOLDEN_DEFER` left UNSET)

**THE WORLD IS THE UNCONVERTED ONE, SAID FIRST**: `SVSwitch` stays
`CMP_NOTEQUAL` in both modes, so the unconverted expectation applies and it is
met exactly.

```
default   : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
testflags : 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
            (+ 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM)
dump histograms: UNCHANGED in both modes
   default    327 blank / 242 differ / 225 match   (baseline: identical)
   testflags  331 blank / 298 differ / 165 match   (baseline: identical)
WHOLE-ROW diff vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
PRISTINE control sweep, judged the same way:  0 differing ROWS (0 diff row-sides)
```

#### 5.4.1 The SVSwitch instruments, reported separately and never conflated

```
                                    PRISTINE      SHIPPED     GOLDEN
cmp HEAD DEPTH (NOT a distance)        54          1603          -
cmp HEAD OBJECT                     def-view port  elab program  -
dump content +/- (diff -u, -2 hdrs)  1891          1882          -
MULTISET DISTANCE (resync-immune)    1333          1326          -
o.dump lines                        25699         25698        25318
golden-only line instances            476           473          -
ours-only   line instances            857           853          -
```

Identical in both modes: the two `slang.uhdm` databases are **byte-identical
mode-to-mode on each binary** (`cmp` run, printed), the two `o.dump` files share
one md5 per binary (`410069ad…` shipped, `37a64565…` pristine), and the two
`cmp.txt` files are byte-identical mode-to-mode on **both** binaries.
**Every content instrument moved the right way**; the HEAD
DEPTH rose because the head moved to a much larger object, and §1.3 shows by the
compare order that the move is FORWARD.

#### 5.4.2 CENSUS-PREDICT, run FIRST, and it is an UPPER BOUND

`census12.sh` filters on the law's two NECESSARY conditions — an instance-ARRAY
declaration `Type name[range](…)` whose connection list opens with a
non-`.` terminal — because four SUFFICIENT conditions need slang's parse tree
(the `udpFormInstantiation` container gate, the `modElems` early return,
`connectionExpr` non-null, and `ifaceArr`'s non-`NamedValue` skip). Run BEFORE
the verifier, and recorded before its answer was known:

```
surelog corpus : 11 of 70 test dirs
   black-parrot Icarus OVMSwitch SVSwitch Tnoc UtdSV UVMSwitch Verilator
   XilinxUnisimLibrary Yosys YosysTestSuite
u2r corpus     :  2 of 734 test dirs
   arraycells simple_instance_array
```

The verifier found **2 movers, both in SVSwitch**, and **0 in any of the other
12**. **13 upper-bound carrier test dirs named, 1 real one** — an over-count of
13:1 at the test-dir level, recorded as such rather than dressed up. Its
one real service was naming the two u2r carriers so their non-movement could be
**explained rather than assumed** — and both explanations are cells of the grid:

```
arraycells             aoi12 p [31:0] (a, b, c, y);   4 positional terminals, no #()
                       -> udpFormInstantiation -> NO def module_array  (= cell m3)
simple_instance_array  and and_gates[3:0] (and_out, a, b);
                       -> a GATE PRIMITIVE array, not a module_array at all
```

### 5.5 GATE 5 — BYTE VERIFIER, both corpora BOTH modes, vs a PRISTINE ed1e6ce built here

`byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 3 / 953
          SELFCHECK 952/953 flagged        SELFCHECK1 = 4  (= 3 flagged + 1 corrupted)

  ./default/SVSwitch-db796243/slang.uhdm      patched=4765452ab634 pristine=65bf286fe24c
  ./testflags/SVSwitch-db796243/slang.uhdm    patched=4765452ab634 pristine=65bf286fe24c
  ./default/Scoreboard-59431470/slang.uhdm    patched=0735c667b15d pristine=0163f3d48653  <- FALSE MOVER, §5.6.1
```

**2 real movers**, both the target, both modes — not the 3 the verifier printed.
Both mover databases are byte-identical to each other (one md5 per binary across
the two modes), and their ENTIRE content delta is the law:

```
-    \_port: (clock)
+    \_port: , line:38:33, endln:38:38
-      |vpiName:clock
-      \_ref_obj: (work@top.output_intf.clock.Clock), line:38:33, endln:38:38
+      \_ref_obj: (work@top.output_intf.Clock), line:38:33, endln:38:38
-        \_port: (clock)
+        \_port: , line:38:33, endln:38:38
-        |vpiFullName:work@top.output_intf.clock.Clock
+        |vpiFullName:work@top.output_intf.Clock
```

Nine lines. Nothing else in either database changed.

### 5.6 MOVERS PER SHAPE, BY MULTISET

`sed 1d` on every dump; ADDED and REMOVED counted **separately** and never
netted; every shape checked against **GOLDEN's own count**, which is the only
test that says a mover is a CONVERGENCE. Keys include the leading indentation,
so the object's own listing and its `vpiParent` reprint are separate shapes.

**SVSwitch**, OUR side, pristine → shipped, indent-exact and complete — these
NINE shapes are the entire multiset delta:

```
                                                                       GOLD PRIS SHIP
ADDED   +1  (ind 4)  \_port: , line:38:33, endln:38:38                    1    0    1
ADDED   +1  (ind 8)  \_port: , line:38:33, endln:38:38                    1    0    1
ADDED   +1  (ind 6)  \_ref_obj: (work@top.output_intf.Clock) 38:33-38:38  1    0    1
REMOVED +1  (ind 4)  \_port: (clock)                                      0    1    0
REMOVED +1  (ind 8)  \_port: (clock)                                      0    1    0
REMOVED +1  (ind 6)  \_ref_obj: (…output_intf.clock.Clock) 38:33-38:38    0    1    0
BARE FIELD lines (NON-ATTRIBUTABLE absorbers, listed not counted as objects)
ADDED   +1  (ind 8)  |vpiFullName:work@top.output_intf.Clock              1    0    1
REMOVED +1  (ind 8)  |vpiFullName:work@top.output_intf.clock.Clock        0    1    0
REMOVED +1  (ind 6)  |vpiName:clock                                      29   26   25
```

**Eight of the nine land on GOLDEN's count EXACTLY** (shipped == golden;
pristine off by exactly the amount moved). There is no tenth shape, no
relocation and no net-zero pairing.

**The ninth is reported as the partial it is.** `      |vpiName:clock` at indent
6 is an AGGREGATE over every indent-6 object named `clock` in the design: golden
has 29, we had 26, we now have 25. One of our 26 was the wrong one (this port's),
so removing it is correct — and doing so exposes a PRE-EXISTING deficit of four
indent-6 `clock` names elsewhere that our wrong line had been masking to three.
Hence the multiset's `golden-only` for that one shape moves 3 → 4 while the
design gets strictly closer. This is exactly why `msmovers.sh` refuses to count
bare field lines as object movement, and why the totals below are stated per
shape rather than netted.

Distance accounting closes exactly:

```
ours-only line instances    857 -> 853   (-4: the four ours-only shapes, 1 each)
golden-only line instances  476 -> 473   (-3: four golden-only shapes at -1 each,
                                              plus the aggregate |vpiName:clock at +1)
MULTISET DISTANCE          1333 -> 1326  (-7)
```

#### 5.6.1 `Scoreboard/default` — THE NAMED FLAKE, EXECUTED, AND A FALSE MOVER

The ops rules mark this row MULTI-STABLE and require a 3-rep plus a size delta
before attributing anything to it. Run on BOTH binaries from the test's own
source directory with the argv taken verbatim from the workdir's `cmds.txt`:

```
ship  rep1 md5=9cf807ea56e4e00d bytes=11133449
ship  rep2 md5=0735c667b15d9bea bytes=11133449     <-- the verifier's "patched" sample
ship  rep3 md5=1ba839e9c6080f2e bytes=11133449
pris  rep1 md5=0163f3d486538b8a bytes=11133449     <-- the verifier's "pristine" sample
pris  rep2 md5=1ba839e9c6080f2e bytes=11133449
pris  rep3 md5=1ba839e9c6080f2e bytes=11133449
```

**THREE DISTINCT HASHES ON THE SHIPPED BINARY ALONE, ONE SIZE ON ALL SIX, AND
THE TWO BINARIES' HASH SETS INTERSECT** (`1ba839e9c6080f2e` is produced by
both). Content, measured rather than inferred:

```
MULTISET DISTANCE  pris rep2  vs  ship rep1  :  0   (1095684 lines both)
MULTISET DISTANCE  ship rep1  vs  ship rep3  :  0   (same-binary control)
MULTISET DISTANCE  pris rep1  vs  ship rep2  :  0   (the verifier's OWN two samples)
```

Zero content difference across binaries, the same zero within one binary, and
zero between the exact two files the verifier compared. `Scoreboard` is also
**not named by `census12.sh`** — it carries no instance array of this shape at
all. FALSE MOVER on five instruments. Note the contrast with r10svs9, where the
same row was a REAL mover and showed a −237-byte size delta; here the size is
identical to the byte on all six runs, which is precisely the discriminator the
ops rule demands.

### 5.7 CANARIES

Baseline passed FIRST and the fresh CSV mode-matched, per the ops rule — the
PRISTINE csv was run through both scripts against the committed baseline before
the shipped csv was:

```
u2r      canaries.sh  PRISTINE ok=8  changed=0 absent=0  unknown-names=25 (expected 25)
         canaries.sh  SHIPPED  ok=8  changed=0 absent=0  unknown-names=25
         ctcan2.sh    PRISTINE ok=1  changed=0 absent=0  unknown-patterns=6  EXPECT_UNKNOWN=6
         ctcan2.sh    SHIPPED  ok=1  changed=0 absent=0  unknown-patterns=6  EXPECT_UNKNOWN=6
surelog  canaries.sh  SHIPPED  ok=52 changed=0 absent=0  unknown-names=7  (expected 7)
         ctcan2.sh    SHIPPED  ok=58 changed=0 absent=0  unknown-patterns=1  EXPECT_UNKNOWN=1
canaudit.sh  audited=29  UNCOVERED=0  FENCE-BREACH=0
```

The two canaries the rules require BY NAME, checked by name before any
aggregate, and `InterfaceModPort` FIRST as the brief instructs:

```
InterfaceModPort    baseline default/testflags = CMP_EQUAL,,,differ   fresh IDENTICAL
BlackParrotComplex  baseline default/testflags = CMP_EQUAL,,,differ   fresh IDENTICAL
```

`InterfaceModPort` is also byte-unmoved in GATE 5 (it is one of the 953 surelog
databases and one of the 950 that did not move) — see §6.6 for what its source
actually contains, which is not what the brief supposed. `canaudit` re-confirms
the four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by no driver here.

---

## 6. REFUTATIONS

**6.1 THE BRIEF'S FRAMING OF THE SECOND FIELD, REFUTED — AND THE PRECEDING
PASS'S WRITE-UP WITH IT.** The brief says the head is a "clean two-field pair"
and that the highconn difference "is its ref's fullname/binding shape (check
which of ITS fields are compared before assuming)". Checked, on the generated
source: **`ref_obj::Compare` never reads `VpiFullName`, and no comparator
anywhere reads a source span** (§1.2). r10svs11's residue R1 called the port
name and the highconn fullname "two differences, both compared" — the second
half is FALSE. The head was ONE compared field. This matters operationally:
a pass that had "fixed" only the fullname would have measured a 54-line head
that did not budge and concluded the localization was wrong.

**6.2 A COMMENT THIS PASS ITSELF HAD ALREADY WRITTEN, REFUTED AND CORRECTED IN
PLACE.** `d3_hcshape.sv`'s header asserted "ref_obj::Compare does compare
VpiFullName, so it is a real second failure hiding behind the first". That
sentence is now replaced by the generated field list and the DUMP-ONLY verdict.
A probe file that states a false law is worse than one that states none, because
the next pass greps the probe files.

**6.3 CHILD KIND AND CONTAINER KIND, BOTH REFUTED.** The witness confounds three
axes — positional conn, interface array, interface def. `d2` holds the same
positional/named contrast on a MODULE array with MODULE children (m1 vs m2,
m9 vs m10) and golden answers identically; `d1 h8/h9` and `d2 m7/m8` do it on a
SCALAR `ref_module` for both kinds and golden answers identically again. Neither
the instantiated def's kind nor the container's kind reaches the rule. The
connection's WRITTEN STYLE is the whole discriminator.

**6.4 PORT COUNT AND WRITTEN ORDER, REFUTED.** `d1 h4` (two named conns in
declaration order) and `h5` (the same two REVERSED) are both fully EQ on both
binaries, and `h2`/`h10` are one-conn cells on two different arrays of the same
def. The count enters only through `udpFormInstantiation`'s separate
container-existence gate (h3, m3, m5, e1), never through the port's name.

**6.5 "THE PRODUCER NAMES PORTS FROM THE FORMAL" — CONFIRMED, BUT THE BRIEF'S
SECOND CLAUSE REFUTED.** The brief's suspect was "the module_array port writer
names ports from the FORMAL where golden leaves the name empty for positional
iface-array conns **and scopes the highconn through the actual alone**". The
first half is exactly right. The second half is right for a `ref_obj` HighConn
and **wrong for a `bit_select` one**: `d2 m10`, a NAMED connection with a
select actual, has golden's `bit_select` fullname at `work@top.b8.Vec` — the
formal omitted even though the connection is named and the port IS named `a`.
So "scoped through the actual alone" is a property of the SELECT HighConn, not
of the positional style. That cell is untouched by this pass and is R5.

**6.6 `InterfaceModPort` IS NOT THE IN-LAW NEIGHBOUR THE BRIEF SUPPOSED.** The
brief calls it "the closest in-law neighbour (interface arrays through ports)".
Read: `~/git-repos/Surelog/tests/InterfaceModPort/top.v` declares two interfaces
and instantiates `mem_if miff(clk); memory_ctrl U_ctrl(miff); memory_model
U_model(miff); test U_test(miff);` — **four SCALAR instances, one positional
terminal each, and NOT ONE instance array in the file.** It never enters
`emitModuleArray`; it is in-family only through the `port`/HighConn writers it
shares. `census12.sh` does not name it, and the byte verifier confirms it did
not move. It was checked FIRST as instructed, and the instruction's premise is
what the check corrected.

**6.7 THIS PASS APPLIES THE LAW INSIDE A CONTAINER GOLDEN DOES NOT BUILD, AND
SAYS SO.** Cell `d2 m5` (`leaf3 #(1) b5[4](Clock, Rst)`) is a positional
two-terminal list under a `#()` that still reads as `delay2`: golden builds NO
def-view `module_array` for it, we build one with two ports, and this pass
renamed those two phantom ports from `a`/`b` to nameless. The cell was DIF
before and is DIF after on both tallies, so nothing regressed — but the honest
statement is that the law was applied to an object that should not exist, and the
fix for m5 is the container gate (R8), not the port gate. Recorded rather than
quietly absorbed into the "EQ unchanged" column.

---

## 7. RESIDUES, RANKED

**R1 — THE SVSwitch SUCCESSOR HEAD, FULLY LOCALIZED: we mint an
`interface_array` inside the elab `program` for its interface-ARRAY PORT, golden
mints none.** 1603 cmp lines, identical in both modes, and it is a
vector-one-sided failure, not an own-field one:

```
LHS golden  <null>                       (program::Interface_arrays() is NULL)
RHS ours    program: work@testcase (work@top.TC), 44:1-44:47
              |vpiInterfaceArray:
              \_interface_array: (work@top.TC.output_intf), 18:95-18:106   <- 481 dump lines
                 vpiName output_intf, vpiFullName work@top.TC.output_intf, vpiSize 4,
                 vpiRange 18:106-18:109 (folded 0 .. 4-1)
```

The formal is `output_interface.OP output_intf[4]` on `program testcase`
(top.sv:18). Golden's elab program subtree is 126 dump lines; ours is 607.
`program::Compare` reaches `Interface_arrays()` after six equal fields, and the
`lhs==nullptr && !rhs->empty()` branch (`BaseClass.h:218`) reports the CONTAINER
on the RHS with a null LHS — exactly the printed head. **Highest-ranked by a
wide margin**: one vector, one object, 481 dump lines, and it is the SAME family
as this pass (an interface array reached through a port). First instrument for
the next pass: where golden puts that array instead — `Interfaces()`? a plain
`port` typespec? nothing at all? — read off golden's own 126 lines.

**R2 — `d1 h6`: a NAMED connection with an EMPTY actual (`.clk()`) produces no
port on our side and a nameless port on golden's.** A vector-SIZE failure
(golden 1, ours 0) whenever it occurs. The `ref_module` writer already models
it (`emptyConn9`, `ModuleEmit.cpp:2732`); the array writer does not. This is the
smallest remaining item in the loop this pass touched, and its fix is one more
transcription of the same neighbour.

**R3 — `d1 h7`: the `.name` SHORTHAND (`.clk`) — golden's port carries NO
HighConn, ours carries one** (`ref_obj (work@top.a7.clk.clk)`). Again already
modelled for `ref_module` (`npcS && !npcS->openParen` → `continue`) and not for
the array. R2 and R3 are one commit if taken together, and both are compared
failures.

**R4 — `d2 m9`: a POSITIONAL connection with a SELECT actual on a module array
gets golden's `bit_select` and our `ref_obj`.** A `VpiType` mismatch, hence
compared. This pass fixed the same cell's name, span and fullname; the HighConn
OBJECT KIND remains, because the `emitSyntaxExpr` select branch is gated on
`npcA` (a NamedPortConnectionSyntax), which a positional conn does not have.
The fix is to reach the actual's syntax through `connectionExpr` instead.

**R5 — `d2 m10` / `d3 k4`: golden does NOT interpose the formal in a
`bit_select` HighConn's fullname even for a NAMED connection.** Golden
`work@top.b8.Vec`, ours `work@top.b8.a.Vec`. DUMP-ONLY (`ref_obj::Compare` and
the select comparators do not read `VpiFullName`), which is why it is ranked
below R4 despite being the same cell. It refutes the brief's "scoped through the
actual alone" as a positional-only rule (§6.5) and wants its own arm.

**R6 — `d3 k3-k7`: for an INTERFACE array, every non-`NamedValue` actual is
skipped and we emit NO port where golden emits one.** Five cells, one cause
(`ifaceArr` in the `rsym` selection), covering element-select, operation and
literal actuals under BOTH connection styles. Vector-SIZE failures, so compared.
Deliberately fenced by this pass — they are DIF-identical on both binaries and
serve as the proof the new gate did not reroute the select branch.

**R7 — Surelog's ESCAPED-IDENTIFIER SPAN over-runs by the escape's width, in
both connection styles, and we do not reproduce it.** `\Cl$ck ` at columns 11-17
spans `31:11-31:22` in golden; `.\r$t (Rst)` spans `29:24-29:39` where we say
`29:24-29:35`. UNCOMPARED, so it costs nothing at cmp; it is the last difference
in `d4 e2/e3/e4` and the reason d4's full-triple tally does not move while its
compared tally goes 3/4 → 4/4.

**R8 — the def-view `module_array` CONTAINER gate is wrong for a positional
list under a readable `#()`.** `d2 m5`: golden builds no container, we build one.
This is `udpFormInstantiation`'s territory (r10svs11's `§ udpShapedConn…11`
family, whose `#()`/`delay2` clause is already decoded), not the port writer's,
and it is the only cell in this grid where we emit an object golden lacks at the
CONTAINER level.

**R9 — the SVSwitch row's remaining distance is 1326, with `golden-only` at 473
and `ours-only` at 853.** The asymmetry is the standing shape of this row: we
still emit 853 line instances golden does not, and 481 of them are R1's single
`interface_array`. That is the first time this row's residue has been more than
half accounted for by one named object.

---

## 8. FILES

```
README.md            this record
svs12arm.sh          one arm: Surelog + ours + dumps + cmp, in its own scratch dir
svsgen.sh            the SVSwitch pair, both modes, THROUGH THE HARNESS ITSELF
gridread.sh          run one arm and print its port cell table
d1read.sh            re-read every cell of all four arms from already-run workdirs
portread.py          the grid reader: the DIRECT members of one container's
                     vpiPort vector, indent-walked so vpiParent reprints are not
                     counted; cells are (name, span, highconn) on both sides
netread.py           r10svs11's Nets() reader, carried unchanged (the retained
                     connection-site-net cells are still read with it)
census12.sh          THIS pass's carrier census, both corpora (an UPPER BOUND)
census.sh            r10svs11's census, carried unchanged for reference
byteverify.sh        GATE 5, with both negative controls
msdist.sh            resync-immune multiset dump distance
msmovers.sh          per-shape ADDED/REMOVED for one mover, vs GOLDEN's count
ct8rows.sh           the whole-row gate against a committed baseline
canaries.sh          named-canary spot check (33 names)
ctcan2.sh            supplementary canary check (exact names + families)
canaudit.sh          audits the canary scripts against the brief's list
d1_ifacearrayport.sv arm d1: connection style x port count x written order
d2_modarrayport.sv   arm d2: the MODULE-array twin, cell for cell
d3_hcshape.sv        arm d3: the actual's FORM under both styles
d4_escaped.sv        arm d4: ESCAPED identifiers on both branches
```

Workdirs left on disk for re-reading (16 MB total; the four 37-363 MB SWEEP
workdirs were DELETED per the ops rule, and their CSVs kept):
`/tmp/r10svs12_arm_{pris,ship}_{d1_ifacearrayport,d2_modarrayport,d3_hcshape,d4_escaped}`
— re-readable with `TAG=<pris|ship> ./d1read.sh` without re-running anything —
`/tmp/r10svs12_svs_{pris2,ship2}` (the SVSwitch pair, both modes, both binaries,
with `*.g.dump`/`*.o.dump`/`*.cmp.txt`), and the four sweep CSVs
`/tmp/r10svs12_{u2r,sl}_{pris2,ship2}.csv`.
