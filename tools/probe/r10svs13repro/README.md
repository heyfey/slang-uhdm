# r10svs13 — A `program` INSTANCE DOES NOT OWN ITS PORT-VIEW `interface_array`, AND THE UDP SHAPE HAS NOTHING TO DO WITH IT

**Verdict, up front: SVSwitch DID NOT CONVERT.** Both rows are unchanged from
the committed baseline, so this pass is read in the **UNCONVERTED world** of
GATE 4 and every gate below is judged against the unconverted expectation:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

No `results/*.csv` was touched by this pass.

The brief's target head — `program: work@testcase (work@top.TC)` failing at
`program::Compare`'s `Interface_arrays()` with golden **null**, **1603 cmp lines
in both modes**, 481 dump lines golden does not have — is **CLEARED**, and the
head **ADVANCED four fields inside the same object**, from `program::Compare`'s
field **217** (`Interface_arrays`) to field **221** (`Ports`).

* **THE BRIEF'S NAMED HYPOTHESIS IS REFUTED, AND IN BOTH DIRECTIONS.** The brief
  proposed that "the udp-shaped parse may be the discriminator again — golden
  mints NO per-instance `interface_array` for a udp-shaped parent." Measured
  against Surelog's own parse tree on **20 cells**: golden **DOES** mint one for
  a **udp-shaped MODULE** parent, and mints **NONE** for a **NOT-udp-shaped
  PROGRAM** parent. The udp shape predicts **nothing** here; the **PARENT'S
  KIND** predicts **every** cell (§3, §6.1).
* **THE OBJECT IS NOT SPURIOUS — IT IS UNOWNED.** Golden builds the very same
  `interface_array` and binds it as the port's `Low_conn` actual; it simply puts
  it in **no vector** and gives it **no parent**, so it lands in uhdm-dump's
  `weaklyReferenced` tail. Deleting it, which "the spurious object" invites,
  would have broken the port binding golden relies on (§6.2).
* **ONE LAW, `§ progPortIfaceArrayUnowned13`**, and it is the **TRANSCRIPTION**
  for `Interface_arrays()` of a rule this same file already carries ~1900 lines
  further down for `Interfaces()` (§2).
* **THE EXECUTABLE CHANGE IS 13 LINES** in one function
  (`src/ModuleEmit.cpp`, `emitInstance`'s interface-ARRAY port branch); of 43
  inserted lines, **30 are the comment that records the measurement**.
* **GRID: 31 cells across FOUR arms. EQ 20 → 30, DIF 11 → 1. NOT ONE CELL
  REGRESSED** (§3).
* **FIVE GATES GREEN** (§5) under the UNCONVERTED expectation.
* **MOVERS: 2** (`SVSwitch` in both modes) out of 1632 databases across both
  corpora (§5.5).
* **SEVEN REFUTATIONS** (§6), two against this pass's own brief, one against a
  script this campaign has been carrying for six passes, and one that this pass's
  own fence arm turned up **against our own producer in the opposite direction**.

Base commit `550eac3`, branch `auto5h`.
Pristine binary md5 **`76e80298abdf4b2792ddc68f271798de`** (worktree
`/tmp/wt_r10svs13pris`, `git rev-parse HEAD` =
`550eac3556355af2077f492891b5af45bed36c0d`, `git status --porcelain` EMPTY —
both printed in §5.1).
Shipped binary md5 **`ef883dda0ad1d34756d14d7d24fd6277`** (worktree
`/tmp/wt_r10svs13`, same `HEAD`, `git status --porcelain` = exactly
` M src/ModuleEmit.cpp` + `?? tools/probe/r10svs13repro/`).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script in
this directory.

---

## 1. LOCALIZATION

### 1.1 The head, on both sides, verbatim

`uhdm-cmp`'s head is the one-sided vector signature of
`BaseClass.h:218` — `m_failedLhs` unset, `m_failedRhs` set to the **CONTAINER**:

```
LHS: <null>
RHS: program: work@testcase (work@top.TC), id:2954, line:44:1, endln:44:47
```

The failing vector is named by censusing the two elab `program work@testcase`
subtrees' **own-indent** field labels (`iaread.py`, which walks the indent column
— a grep over the subtree over-counts, because every object is reprinted inside
its own children as a `vpiParent` back-pointer and this wrapper is reprinted a
THIRD time as the port `Low_conn`'s `vpiActual`):

```
golden  vpiParent vpiName vpiFullName vpiVariables x2 vpiDefName vpiDefFile
        vpiDefLineNo vpiInstance                     vpiProcess x2 vpiPort x3
ours    vpiParent vpiName vpiFullName vpiVariables x2 vpiDefName vpiDefFile
        vpiDefLineNo vpiInstance vpiInterfaceArray   vpiProcess x2 vpiPort x3
```

— `|vpiInterfaceArray:` on ours alone, **481 dump lines**, and `|vpiInterface:`
absent from BOTH sides.  `program::Compare` (generated `program.cpp`) reaches:

```
215 Interfaces        <- null on BOTH sides; NOT the failing neighbour (measured)
217 Interface_arrays  <- THE OLD HEAD.  golden null, ours 1 element
218 Process   219 Cont_assigns   220 Clocking_blocks
221 Ports             <- THE NEW HEAD (§1.3)
```

### 1.2 WHICH FIELDS ARE COMPARED — read off the generated comparators, not inferred

```cpp
// program.cpp:217        SafeCompare(lhs, lhs->Interface_arrays(), rhs, rhs->Interface_arrays())
// module_inst.cpp:402    the same, one field after Interfaces() at :401
// instance_array.cpp:167 interface_array's own chain compares
//   BaseClass(VpiType,VpiName,VpiDefName), VpiName, VpiSize, Expr, Ranges,
//   Left_expr, Right_expr, Instances, Modules, Elem_typespec, Ports
//   ...and interface_array.cpp:88 adds Param_assigns.   NO VpiFullName ANYWHERE.
// BaseClass::Compare  — VpiType, VpiName, VpiDefName.  No vpiLineNo/vpiColumnNo,
//                       and NO vpiParent.
```

| difference | compared? | by what |
|---|---|---|
| the program's `Interface_arrays()` vector: golden null vs ours 1 | **YES** | `program.cpp:217`, one-sided vector |
| the wrapper's `VpiFullName` (`work@top.TC.output_intf` vs golden ABSENT) | **NO** | `instance_array::Compare`'s field list omits it |
| the wrapper's `vpiParent` (ours the program, golden none) | **NO** | no `Compare` anywhere reads `vpiParent` |
| the wrapper's `VpiName` (`output_intf`) | YES | identical on both sides |
| the wrapper's `VpiSize` (4) | YES | identical on both sides |

**The 481-line head was the vector membership and nothing else.** The fullname
and the parent are real byte-differences the dump shows and `uhdm-cmp` does not
read; they are fixed here because they are the same producer decision (an OWNED
object gets a path-qualified fullname and a parent; an UNOWNED one gets neither),
and they are reported as DUMP-ONLY throughout.

### 1.3 The head ADVANCED — measured by the compare order, not asserted

`cmp` HEAD DEPTH went 1603 → **484**, and a depth is not a distance, so the
direction is settled by the compare order and by WHICH object `m_failedLhs`
names. The new head prints the SAME object on both sides:

```
LHS: interface_inst: work@mem_interface (work@top.mem_intf), id:2472, line:26:0
RHS: interface_inst: work@mem_interface (work@top.mem_intf), id:2740, line:26:0
```

Note `line:26:0` with **no `endln`**: this is the **col-0 TAIL DUPLICATE**, not
the home view (`line:26:1, endln:26:31`). The home views are **byte-identical on
both sides** (177 lines each, 25 own-indent lines each, checked). The tail
duplicate is reachable **only** through the program's port `High_conn` ref, so
the path is

```
design::Compare -> uhdmtopModules -> module_inst work@top
  -> basetype instance::Compare:332  Programs        -> program work@top.TC
       program::Compare:217 Interface_arrays   <- OLD HEAD (now equal)
       program::Compare:221 Ports -> ports[0] (mem_intf) -> High_conn
         -> ref_obj::Actual_group -> interface_inst col-0 dup -> Variables()
```

so the head moved **forward by four fields inside the same `program` object**.
It did NOT leave the program; claiming otherwise would be the depth number
talking. Every content instrument agrees on the direction (§5.4.1).

The new head's cause, fully localized and **PRE-EXISTING**: the col-0 tail
duplicate's `Variables()` has **5 elements in golden and 4 in ours** — ours omits
the interface's **own port variable**, `bit_var (work@top.mem_intf.clock)`, which
BOTH sides do carry on the home view. That is **R1** in §7, and the proof that
this pass did not cause it is that the ENTIRE delta between the pristine and the
shipped SVSwitch database is the three hunks of §5.5 — that subtree is
byte-identical on both binaries.

---

## 2. THE LAW

### § progPortIfaceArrayUnowned13

> **A `program` INSTANCE OWNS NO PORT-VIEW `interface_array`.** For a whole
> interface-ARRAY port (`oif.OP a[4]` connected to an array instance), the
> wrapper is still BUILT and is still the port `Low_conn`'s actual, but it is
> **UNOWNED**: it is **(a) NOT in the program's `Interface_arrays()` vector**,
> and it carries **(b) NO `vpiParent`** and **(c) NO `vpiFullName`** — so
> Surelog's database reaches it only through that one weak reference, and
> uhdm-dump prints it in the `weaklyReferenced` tail instead of under the
> program. A **`module_inst`** parent and an **`interface_inst`** parent OWN it
> normally, with the path-qualified fullname and the parent back-pointer.
> **The discriminator is the PARENT'S KIND and nothing else.** It is
> INDEPENDENT of the written connection shape: measured identical across
> ordered-x2 udp-shaped, ordered-x2 NOT-udp-shaped (operation first terminal),
> ordered-x2 with an EMPTY terminal, ordered-x1, named, and both sides of the
> `#()` `delay2` boundary.

Only (a) is a compared field (§1.2). (b) and (c) are dump-only and are fixed
because they are the same producer decision read off the same branch.

### STATED GATE == CODE GATE

The gate in `src/ModuleEmit.cpp` is, in full, after this pass:

```cpp
bool progOwner13 = m->UhdmType() == UHDM::uhdmprogram;   // the WHOLE gate
auto* iarr = s.MakeInterface_array();
iarr->VpiName(std::string(portBase->name));
if (!progOwner13) {                        // (c) NO FULLNAME  (b) NO PARENT
    iarr->VpiFullName(prefix + "." + std::string(portBase->name));
    iarr->VpiParent(m);
}
iarr->VpiSize((int32_t)insts->size());
…
if (!progOwner13) {                        // (a) NO OWNERSHIP
    auto* iarrs = instGetInterfaceArrays(m);
    if (!iarrs) {
        iarrs = s.MakeInterface_arrayVec();
        instSetInterfaceArrays(m, iarrs);
    }
    iarrs->push_back(iarr);
}
// UNCHANGED, and deliberately so: the wrapper is still minted, still ranged,
// still carries its Instances(), and the port Low_conn is still re-pointed at
// it for EVERY parent kind.
for (auto* pp : ifPortList)
    if (pp->VpiName() == ip.name && pp->Low_conn() &&
        pp->Low_conn()->UhdmType() == UHDM::uhdmref_obj)
        ((UHDM::ref_obj*)pp->Low_conn())->Actual_group(iarr);
```

**The gate reads ONE ENUM — the UHDM type of the parent instance. No name, no
string, no count, no connection syntax, no `udpShapedInstantiation`, no modport
test, no port-count test.** That is exactly what the law above says, and §3
measures each of those non-conditions as a separate refuted axis.

### It was already in the tree, ~1900 lines down

`emitInstance`'s `Interfaces()` assembly (`src/ModuleEmit.cpp:10189`) already
carries the SAME rule for the sibling vector, and its comment already states the
reason:

```cpp
// A `program` instance lists NO port-view interface_inst: Surelog's program
// writer never materialises the per-iface-port instance view that its module
// writer does (OneNetModPort work@TOP.tb carries only vpiPort/vpiProcess, while
// the sibling module middle1 also carries vpiInterface intf).
if (m->UhdmType() != UHDM::uhdmprogram && allIf->empty()) { … }
```

Same writer, same omission, same reason, adjacent vector — `Interfaces()` at
`program.cpp:215`, `Interface_arrays()` at `:217`. This pass makes the ARRAY
vector agree with the SCALAR vector. That is why arm **a2** (every cell scalar)
is the control that must not move, and it does not: 8 of 8 EQ on both binaries.

### What was there before, and why it was wrong

Before: the wrapper was **unconditionally** given `prefix + "." + port`, a
`vpiParent` of the instance, and a push into `instGetInterfaceArrays(m)` — where
`instGetInterfaceArrays`/`instSetInterfaceArrays` (`src/EmitHelpers.h:1758`)
dispatch over all THREE instance kinds, `program` included. Read as a claim about
golden it says *every instance kind owns its port-view array*. Golden's program
owns nothing of the sort, and the two views coincide for the other two kinds.

---

## 3. THE GRID, CELL FOR CELL

Read by `iaread.py`, which walks the dump's **indent column** and reports an
instance's OWN `Interfaces()` / `Interface_arrays()` labels at exactly its
indent + 2. An object's OWN LISTING is the occurrence of its header with the
LARGEST subtree (a `vpiParent` reprint has a subtree of one line); instances are
keyed by their elab **fullname** (`(work@top.p1)`), which separates them from
their def views (`(work@leaf2p)`) with no ambiguity.

A cell is the pair **(`Interfaces()` size, `Interface_arrays()` size)** on both
sides, which is what the two `SafeCompare` vector calls read. The `parse` column
is **Surelog's own verdict**, taken from `surelog -parse -nocache -d ast` on the
arm file itself and mapped by source line — never inferred from the predicate.

All four arms were run on BOTH binaries from the same driver (`svs13arm.sh`,
carried unchanged in substance from `r10svs12repro/svs12arm.sh`), in per-arm
scratch dirs; both columns are still on disk
(`/tmp/r10svs13_arm_{pris,ship}_a{1,2,3,4}`).

### 3.1 `a1_ifarrport.sv` — PARENT KIND x CONNECTION STYLE, interface-ARRAY port

```
cell  instantiation                 parse (SURELOG)       GOLDEN if/iarr  PRIS      SHIP
p1    leaf2p p1(arr, sc)            Udp_instantiation      0 / 0          DIF 0/1   EQ 0/0
p2    leaf2p p2(.a(arr), .b(sc))    Module_instantiation   0 / 0          DIF 0/1   EQ 0/0
p3    leaf1p p3(arr)                Module_instantiation   0 / 0          DIF 0/1   EQ 0/0
p4    leaf1p p4(.a(arr))            Module_instantiation   0 / 0          DIF 0/1   EQ 0/0
m1    leaf2m m1(arr, sc)            Udp_instantiation      5 / 1          EQ        EQ
m2    leaf2m m2(.a(arr), .b(sc))    Module_instantiation   5 / 1          EQ        EQ
m3    leaf1m m3(arr)                Module_instantiation   4 / 1          EQ        EQ
m4    leaf1m m4(.a(arr))            Module_instantiation   4 / 1          EQ        EQ
                                    cells 8    EQ 4 -> 8    DIF 4 -> 0
design-wide `|vpiInterfaceArray:` labels   GOLDEN 6    PRIS 10 -> SHIP 6
```

**Golden is 0/0 for every PROGRAM cell and N/1 for every MODULE cell, with no
exception, and the `parse` column crosses the outcome column TWICE** (p1 is a
UDP and omits; m2/m3/m4 are module_instantiations and own).

### 3.2 `a2_scalariface.sv` — THE SCALAR TWIN, i.e. `Interfaces()` (THE CONTROL)

Every interface port scalar, so the vector under test is `Interfaces()` — the
field compared IMMEDIATELY BEFORE `Interface_arrays()`, and the one that produces
the identical one-sided `LHS: <null>` signature.

```
cell  instantiation                 GOLDEN if/iarr   PRIS   SHIP
q1    leaf2ps q1(sc, sd)             0 / 0           EQ     EQ
q2    leaf2ps q2(.a(sc), .b(sd))     0 / 0           EQ     EQ
q3    leaf1ps q3(sc)                 0 / 0           EQ     EQ
q4    leaf1ps q4(.a(sc))             0 / 0           EQ     EQ
n1    leaf2ms n1(sc, sd)             2 / 0           EQ     EQ
n2    leaf2ms n2(.a(sc), .b(sd))     2 / 0           EQ     EQ
n3    leaf1ms n3(sc)                 1 / 0           EQ     EQ
n4    leaf1ms n4(.a(sc))             1 / 0           EQ     EQ
                                    cells 8    EQ 8 -> 8    DIF 0 -> 0
design-wide `|vpiInterfaceArray:` labels   GOLDEN 0    PRIS 0 -> SHIP 0
```

Two things measured here, not asserted. First, the brief's "`Interfaces()` is
measured null on BOTH sides" for the SVSwitch program is **not an accident of
that test's shape**: it is the pre-existing law, and it holds for all four
program cells and all four module cells. Second, this arm is the **BLAST-RADIUS
FENCE** for the sibling vector — the new gate must not reach it, and 8 of 8 cells
plus a design-wide label count of 0/0/0 say it does not.

### 3.3 `a3_udpboundary.sv` — SEPARATE "UDP-SHAPED" FROM "TWO ORDERED TERMINALS"

Every cell has an ORDERED list of exactly TWO terminals and an interface-ARRAY
port, so the only axis moving is the udp verdict.

```
cell  instantiation                     parse (SURELOG)       GOLDEN if/iarr  PRIS      SHIP
s1p   leafmixp s1p(Clock & 1'b1, arr)   Module_instantiation   0 / 0          DIF 0/1   EQ
s1m   leafmixm s1m(Clock & 1'b1, arr)   Module_instantiation   4 / 1          EQ        EQ
s2p   leafmixp s2p(Clock, arr)          Udp_instantiation      0 / 0          DIF 0/1   EQ
s2m   leafmixm s2m(Clock, arr)          Udp_instantiation      4 / 1          EQ        EQ
s3p   leafmixp s3p(, arr)               Module_instantiation   0 / 0          DIF 0/1   EQ
s3m   leafmixm s3m(, arr)               Module_instantiation   4 / 1          EQ        EQ
s4p   leaf2pP #(1) s4p(arr, sc)         Udp_instantiation      0 / 0          DIF 0/1   EQ
s4m   leaf2mP #(1) s4m(arr, sc)         Udp_instantiation      5 / 1          EQ        EQ
s5p   leaf3pP #(1,2,3) s5p(arr, sc)     Module_instantiation   0 / 0          DIF 0/1   EQ
s5m   leaf3mP #(1,2,3) s5m(arr, sc)     Module_instantiation   5 / 1          EQ        EQ
s6p   leaf3pP #(.W(1)) s6p(arr, sc)     Module_instantiation   0 / 0          DIF 0/1   EQ
s6m   leaf3mP #(.W(1)) s6m(arr, sc)     Module_instantiation   5 / 1          EQ        EQ
                                    cells 12    EQ 6 -> 12    DIF 6 -> 0
design-wide `|vpiInterfaceArray:` labels   GOLDEN 9    PRIS 15 -> SHIP 9
```

**This is the refutation, cell for cell.** The `parse` column splits 4 udp / 8
module_instantiation; the outcome column splits **6 program / 6 module**. Every
one of the four `delay2` claims `udpShapedInstantiation`'s comment makes is
reproduced here by Surelog itself (`#(1)` stays a UDP, `#(1,2,3)` and `#(.W(1))`
do not; an operation first terminal and an empty terminal both break the shape) —
and **not one of them moves the `interface_array` verdict**.

### 3.4 `a4_parentkinds.sv` — THE THIRD PARENT KIND AND THE RE-PASS (THE FENCE)

`instGetInterfaceArrays`/`instSetInterfaceArrays` dispatch over THREE instance
kinds. a1/a3 pin `program` and `module_inst`; this arm pins `interface_inst`, and
adds a module that re-passes the whole array on to a child.

```
cell  instance                     GOLDEN if/iarr   PRIS        SHIP
h1    holder h1(arr)  INTERFACE     0 / 1           DIF 1/0     DIF 1/0   <- pre-existing, OPPOSITE direction
d1    mid d1(arr)     MODULE        4 / 1           EQ          EQ
d1i   d1.inner        MODULE re-pass 4 / 1          EQ          EQ
                                    cells 3    EQ 2 -> 2    DIF 1 -> 1
design-wide `|vpiInterfaceArray:` labels   GOLDEN 5    PRIS 4 -> SHIP 4
```

**h1 is an UNTOUCHED PRE-EXISTING DIF IN THE OPPOSITE DIRECTION** — golden OWNS
the wrapper on an `interface_inst` parent and **we build none at all**. It is
**R3** in §7. Its value here is as the fence that says the new gate keys on
`uhdmprogram` and not on "anything that is not a module": h1 is DIF-identical on
both binaries and the design-wide label count is 4 on both.

**A measurement, not an aside:** a `program` cannot contain a
module/interface/program instantiation (LRM 24.3), so the ONLY `interface_array`
a program instance can ever carry is a PORT VIEW. There is no
locally-declared-interface-array cell to write for a program, which is why this
gate — unlike the `Interfaces()` one it transcribes, which had to add
`&& allIf->empty()` — needs no second clause to avoid over-firing onto one.

### 3.5 Totals

```
arm   cells   EQ            DIF          design-wide labels GOLD / PRIS -> SHIP
a1       8    4 ->  8       4 -> 0        6 / 10 -> 6
a2       8    8 ->  8       0 -> 0        0 /  0 -> 0
a3      12    6 -> 12       6 -> 0        9 / 15 -> 9
a4       3    2 ->  2       1 -> 1        5 /  4 -> 4
      -----  ---------     --------
        31   20 -> 30      11 -> 1
```

**Not one cell regressed.** Ten cells converged (a1 p1-p4, a3 s1p/s2p/s3p/s4p/
s5p/s6p); the one remaining DIF (a4 h1) is pre-existing, points the other way,
and is byte-identical on both binaries. On three of the four arms our design-wide
`|vpiInterfaceArray:` count now equals golden's **exactly**; on the fourth (a4)
it is unchanged and short by the one h1 wrapper we never build.

---

## 4. THE PRODUCER

`src/ModuleEmit.cpp`, `emitInstance` (`:5562`), the whole-interface-ARRAY-port
branch of the interface-port loop (`conn.first->kind == SymbolKind::InstanceArray`,
~line 8146-8300). Per such port it emits the per-element modport port views, then
mints the `interface_array` wrapper, ranges it, hangs the element list on it,
registers it on the parent instance, and re-points the port's `Low_conn` ref at
it.

The change is confined to two `if (!progOwner13)` guards in that branch:

```
 src/ModuleEmit.cpp | 50 +++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 43 insertions(+), 7 deletions(-)
```

and 30 of the 43 insertions are the comment recording the measurement. The
executable delta is 13 lines, listed in full in §2's gate block.

**No other rule in this branch is disturbed**, and that is measured rather than
argued: the per-element `emitInterfaceInstance` fan-out, the
`sizeDimFoldsWithoutParams` one-element narrowing, `fillSizeDimRange`'s
size-vs-`[msb:lsb]` split, the folded-bound `INT`/`UINT` constant rule, and the
`Low_conn` re-point are all untouched, and cells **a1 m1-m4**, **a3 s1m-s6m**,
**a4 d1/d1i** hold every one of them fixed while the program cells move.
`instGetInterfaceArrays`/`instSetInterfaceArrays` are UNCHANGED; their only other
caller, the DEF-view `makeIfaceArrayPortTs` (`:22011`, reached from `:16219`), is
already gated on `m->UhdmType() == UHDM::uhdmmodule_inst` and is byte-identical
here — arm a1/a3's `\_interface_array: (oif.OP)` def-view listings are EQ-count on
both binaries, and GATE 3's 0 differing rows over 731 uhdm2rtlil tests is the
blast-radius measurement.

---

## 5. THE FIVE GATES

### 5.1 GATE 1 — BUILD

```
/tmp/wt_r10svs13                    (shipped)
[100%] Linking CXX executable slang-uhdm      <- the link line, forced and waited for
[100%] Built target slang_uhdm
SHIP_RC=0     compiler "error:" lines: 0
md5(build/slang-uhdm) = ef883dda0ad1d34756d14d7d24fd6277
   32-HEX ASSERT: OK (len=32)                 <- asserted SEPARATELY from the build
git rev-parse HEAD  = 550eac3556355af2077f492891b5af45bed36c0d
git status --porcelain =  M src/ModuleEmit.cpp
                        ?? tools/probe/r10svs13repro/

/tmp/wt_r10svs13pris                (pristine, built HERE, not reused)
[100%] Linking CXX executable slang-uhdm
[100%] Built target slang_uhdm
PRIS_RC=0     compiler "error:" lines: 0
md5(build/slang-uhdm) = 76e80298abdf4b2792ddc68f271798de
   32-HEX ASSERT: OK (len=32)
git rev-parse HEAD  = 550eac3556355af2077f492891b5af45bed36c0d
git status --porcelain = <EMPTY>
```

Both binaries were relinked from scratch (`rm build/slang-uhdm` before the
build) so the link line is real and not a stale-target message.

**Cross-check on the pristine binary, and it is a real one:** r10svs12 (the pass
that PRODUCED `550eac3`) reports its shipped SVSwitch `o.dump` md5 as
`410069ad…`. The pristine binary built here reproduces
`410069adae1ee78764f55c2dc4872bab` for the same file in BOTH modes. The baseline
is therefore the committed one, not a look-alike.

**THE BASE MARKER IS BEHAVIOURAL AND TWO-DIRECTIONAL** (`basemark.sh`, run on
every binary these gates quote). This pass adds no new symbol — the law name
lives only in comments (`strings … | grep -c progPortIfaceArrayUnowned13` = **0**
on BOTH binaries, so quoting it would be a guard that does not guard) and the
gate reads a pre-existing accessor:

```
SOURCE     grep -c progPortIfaceArrayUnowned13 src/ModuleEmit.cpp
             shipped worktree = 2        pristine worktree = 0
BEHAVIOUR  a1 cell p1 (PROGRAM)   Interface_arrays  (a vector EMPTIED)
             pristine = 1               shipped = 0
BEHAVIOUR  a1 tail listing `\_interface_array: (a),` at INDENT 0  (objects UNOWNED)
             pristine = 0               shipped = 4
CONTROL    a1 cell m1 (MODULE)    Interface_arrays
             BOTH binaries = 1  (and Interfaces = 5 on both)
```

### 5.2 GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped>  tests/check_goldens.sh  ->  23 PASS / 0 FAIL   (rc=0)
SLANG_UHDM=<pristine> tests/check_goldens.sh  ->  23 PASS / 0 FAIL   (rc=0)
SLANG_UHDM=/bin/false tests/check_goldens.sh  ->   0 PASS / 23 FAIL  (rc=1, control FIRES)
```

Stated honestly: none of the 23 goldens instantiates a `program` with a whole
interface-ARRAY port, so they prove this law broke nothing; **they cannot confirm
it.** The instruments that confirm it are §3 and GATE 5.

### 5.3 GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
PRISTINE control sweep, judged the same way:   0 differing ROWS (0 diff row-sides)
```

### 5.4 GATE 4 — surelog `--mode both --jobs 2` (`GOLDEN_DEFER` left UNSET)

**THE WORLD IS THE UNCONVERTED ONE, SAID FIRST**: `SVSwitch` stays
`CMP_NOTEQUAL` in both modes, so the unconverted expectation applies.

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

**The UNCONVERTED expectation is 0 row-sides, and 0 is what both sweeps give.**
The 2-row-sides-per-mode expectation belongs to the CONVERSION world and does not
apply; naming which world first is the point of the ops rule.

CANARIES, all four CSVs, and the two the rules require BY NAME first:

```
InterfaceModPort     baseline default/testflags = CMP_EQUAL,,,differ   fresh IDENTICAL
BlackParrotComplex   baseline default/testflags = CMP_EQUAL,,,differ   fresh IDENTICAL

surelog  canaries.sh SHIPPED  ok=52 changed=0 absent=0 unknown-names=7  (expected 7)
         canaries.sh PRISTINE ok=52 changed=0 absent=0 unknown-names=7
         ctcan2.sh   SHIPPED  ok=58 changed=0 absent=0 unknown-patterns=1  EXPECT_UNKNOWN=1
         ctcan2.sh   PRISTINE ok=58 changed=0 absent=0 unknown-patterns=1  EXPECT_UNKNOWN=1
u2r      canaries.sh SHIPPED  ok=8  changed=0 absent=0 unknown-names=25 (expected 25)
         canaries.sh PRISTINE ok=8  changed=0 absent=0 unknown-names=25
         ctcan2.sh   SHIPPED  ok=1  changed=0 absent=0 unknown-patterns=6  EXPECT_UNKNOWN=6
         ctcan2.sh   PRISTINE ok=1  changed=0 absent=0 unknown-patterns=6  EXPECT_UNKNOWN=6
canaudit.sh  audited=29  UNCOVERED=0  FENCE-BREACH=0
```

#### 5.4.1 The SVSwitch instruments, reported separately and never conflated

```
                                    PRISTINE      SHIPPED     GOLDEN
cmp HEAD DEPTH (NOT a distance)       1603           484          -
cmp HEAD OBJECT                     program TC    iface tail dup  -
cmp HEAD FIELD                      Interface_arrays  Ports       -
dump content +/- (diff -u, -2 hdrs)  1882          1352          -
MULTISET DISTANCE (resync-immune)    1326           864          -
golden-only line instances            473           244          -
ours-only   line instances            853           620          -
o.dump lines                        25698         25694        25318
```

Identical in both modes on both binaries: the two `slang.uhdm` databases are
**byte-identical mode-to-mode** (`cmp` run and printed), the two `o.dump` files
share one md5 per binary (`8417bab6…` shipped, `410069ad…` pristine), and the two
`cmp.txt` files are byte-identical mode-to-mode. **Every content instrument moved
the right way**; the HEAD DEPTH fell and §1.3 shows by the compare order that the
move is FORWARD.

#### 5.4.2 CENSUS-PREDICT, run FIRST, and it is an UPPER BOUND

`census13.sh` filters on the law's two NECESSARY conditions — a `program`
declaration WITH a port list, and an array-dimensioned port declaration anywhere
in the same test dir — because three SUFFICIENT conditions need slang's symbol
table (the connection must resolve to an `InstanceArray`, the program must
actually be instantiated, and slang must accept the file). Run BEFORE the
verifier and recorded before its answer was known:

```
surelog corpus : 4 of 761 test dirs    ariane  Google  SVSwitch  Verilator
u2r corpus     : 0 of 734 test dirs
UPPER BOUND    : 4 test dirs
```

The verifier found **2 movers, both in SVSwitch**, and **0 in the other 3** — an
over-count of 4:1 at the test-dir level, recorded as such rather than dressed up.
The filter's one honest weakness is stated in its own header: it requires the
`(` on the same line as `program <name>`, so a port list opened on the next line
would be missed.

Its one real service was naming the three non-movers so their non-movement could
be **explained rather than assumed**:

```
ariane      program testbench ();                       EMPTY port list -> no iface port
            (and the row is Ariane = SURELOG_FAIL in both modes: no golden at all)
Google      program prog(input wire a, input wire b);   no INTERFACE port
            (rows: default SLANG_REJECT, testflags TIMEOUT)
Verilator   program Prog (input si);                    no INTERFACE port
            (rows: SLANG_REJECT in both modes)
```

Not one of the three has an interface port, let alone an ARRAY one — the census's
condition (b) matched an unrelated array-dimensioned declaration elsewhere in the
same test dir, which is exactly the looseness its header warns about.

### 5.5 GATE 5 — BYTE VERIFIER, both corpora BOTH modes, vs a PRISTINE 550eac3 built here

`byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 3 / 953
          SELFCHECK 952/953 flagged        SELFCHECK1 = 4  (= 3 flagged + 1 corrupted)

  ./default/SVSwitch-db796243/slang.uhdm      patched=98b682118031 pristine=4765452ab634
  ./testflags/SVSwitch-db796243/slang.uhdm    patched=98b682118031 pristine=4765452ab634
  ./default/Scoreboard-59431470/slang.uhdm    patched=a6441eb4dfed pristine=31586294781f  <- FALSE MOVER, §5.5.1
```

**2 real movers**, both the target, both modes — not the 3 the verifier printed.
Both mover databases are byte-identical to each other (one hash per binary across
the two modes). And the PRISTINE hash `4765452ab634` is the one r10svs12 reports
as its own SHIPPED SVSwitch hash: a second independent confirmation that the
baseline built here is `550eac3` itself.

#### 5.5.1 `Scoreboard/default` — THE NAMED FLAKE, EXECUTED, AND A FALSE MOVER

The ops rules mark this row MULTI-STABLE and require a 3-rep plus a size delta
before attributing anything to it. Run on BOTH binaries from the test's own
source directory with the argv taken verbatim from the workdir's `cmds.txt`:

```
ship  rep1 md5=c71ab4fab332bb2c bytes=11133994
ship  rep2 md5=31586294781f692e bytes=11133994   <-- the verifier's "PRISTINE" hash,
ship  rep3 md5=c71ab4fab332bb2c bytes=11133994       produced by the SHIPPED binary
pris  rep1 md5=31586294781f692e bytes=11133994
pris  rep2 md5=31586294781f692e bytes=11133994
pris  rep3 md5=31586294781f692e bytes=11133994
```

**THE TWO BINARIES' HASH SETS INTERSECT** — `31586294781f692e` is produced by
both — **and the verifier's own "patched" sample (`a6441eb4dfed`) is a THIRD hash
that appears in none of these six reps**, so the shipped binary alone produces at
least three. One size on all six. Content, measured rather than inferred:

```
MULTISET DISTANCE  pris rep1  vs  ship rep1                  :  0   (1095800 lines both)
MULTISET DISTANCE  ship rep1  vs  ship rep2  (same binary)   :  0
MULTISET DISTANCE  pris rep1  vs  the verifier's ship sample :  0
MULTISET DISTANCE  the verifier's OWN TWO SAMPLES            :  0
```

Zero content difference across binaries, the same zero within one binary, and
zero between the exact two files the verifier compared. `Scoreboard` is also
**not named by `census13.sh`** — it instantiates no `program` at all — so nothing
about this law can reach it.

The mover databases' ENTIRE content delta is the law — **three hunks, and
nothing else in either database changed**:

```
@@ -16933,487 +16933,6 @@      the 481-line wrapper subtree LEAVES the program
-    |vpiInterfaceArray:
-    \_interface_array: (work@top.TC.output_intf), line:18:95, endln:18:106
-      |vpiParent:
-      \_program: work@testcase (work@top.TC), …
-      |vpiName:output_intf
-      |vpiFullName:work@top.TC.output_intf
-      …479 more lines…

@@ -17494,7 +17013,7 @@         the port Low_conn ref's shallow reprint
-        \_interface_array: (work@top.TC.output_intf), line:18:95, endln:18:106
+        \_interface_array: (output_intf), line:18:95, endln:18:106

@@ -23107,6 +22626,483 @@        …and REAPPEARS in the weaklyReferenced tail,
+\_interface_array: (output_intf), line:18:95, endln:18:106   at INDENT 0,
+  |vpiName:output_intf                                       with no vpiParent
+  |vpiSize:4                                                 and no vpiFullName
+  …477 more lines…                                           — golden's shape
```

Net **-4 dump lines** (25698 → 25694): the four removed are the
`|vpiInterfaceArray:` label, the `|vpiParent:` label and its element line, and
the `|vpiFullName:` line.

### 5.6 MOVERS PER SHAPE, BY MULTISET

`sed 1d` on every dump; ADDED and REMOVED counted **separately** and never
netted; every shape checked against **GOLDEN's own count**, which is the only
test that says a mover is a CONVERGENCE. Keys include the leading indentation, so
an object's listing under the program and the same object's listing in the tail
are DIFFERENT shapes — which for this law is the point, because **this law
RELOCATES a subtree rather than minting or deleting one**, and 325 indent-exact
shapes move.

The three-way table (`msthree.sh`, `GOLD / PRIS / SHIP` per shape) closes as
follows:

```
shapes moved (pris != ship)                     325
  CLOSER to GOLDEN's count                      214
  SAME distance to GOLDEN                         1
  FARTHER from GOLDEN's count                   110
  SHIP count == GOLDEN count EXACTLY            204
ours-only line instances    853 -> 620   (-233)
golden-only line instances  473 -> 244   (-229)
MULTISET DISTANCE          1326 -> 864   (-462)
```

**The 110 FARTHER shapes are reported as the partial they are, and they have ONE
cause.** They are the relocated island's own lines at their NEW indentation, and
they miss golden's count because **golden names the island off the PORT while we
name it off the INSTANCE PATH**: golden's tail elements are
`interface_inst (output_intf.output_intf[0])`, ours are
`interface_inst (work@top.TC.output_intf[0])`. Every FARTHER shape is either a
`|vpiFullName:work@top.TC.output_intf…` line, an object header carrying that
fullname, or an aggregate absorber (`|vpiParent:`, `|vpiRange:`, `|vpiSize:64`).
The wrapper's OWN header line now matches golden character for character at
indent 0. That naming difference is **R2** in §7; it is NOT compared
(`instance_array::Compare` never reads `VpiFullName`, and the elements' `VpiName`
is `output_intf[i]` on both sides), and the distance accounting above shows the
design gets strictly closer by 462 lines while it stands.

The headline object shapes:

```
                                                                        GOLD PRIS SHIP
ADDED   +1  (ind 0)  \_interface_array: (output_intf) 18:95-18:106          1    0    1
ADDED   +1  (ind 8)  \_interface_array: (output_intf) 18:95-18:106          1    0    1
REMOVED +1  (ind 4)  \_interface_array: (work@top.TC.output_intf)           0    1    0
REMOVED +1  (ind 8)  \_interface_array: (work@top.TC.output_intf)           0    1    0
BARE FIELD lines (NON-ATTRIBUTABLE absorbers, listed not counted as objects)
REMOVED +1  (ind 4)  |vpiInterfaceArray:                                    0    1    0
```

**All four object shapes land on GOLDEN's count EXACTLY** (`ind 0` is the tail
listing, `ind 8` is the port `Low_conn`'s shallow reprint), the label line is
removed to golden's 0, and there is no fifth `interface_array` shape.

---

## 6. REFUTATIONS

### 6.1 THE BRIEF'S NAMED DISCRIMINATOR IS WRONG, IN BOTH DIRECTIONS

The brief: *"the udp-shaped parse (the TC instantiation IS udp-shaped, r10svs11
proved it) may be the discriminator again: golden mints NO per-instance
interface_array for a udp-shaped parent. Measure, do not assume."* Measured, with
Surelog's own parse tree as the column:

* **A udp-shaped parent DOES get one** — a1 `m1` (`Udp_instantiation`, golden
  `Interface_arrays` = 1), a3 `s2m` and `s4m` likewise. Three counterexamples to
  the stated rule.
* **A NOT-udp-shaped parent gets NONE** — a1 `p2`/`p3`/`p4`
  (`Module_instantiation`, golden 0) and a3 `s1p`/`s3p`/`s5p`/`s6p`. Seven
  counterexamples to its converse.
* Had the udp predicate been used as the gate, **7 of the 10 program cells would
  have stayed wrong and 3 of the 10 module cells would have been broken.**

The brief's instruction to measure rather than assume is what caught it, and the
arm that did it (a3) exists only because a1's udp-shaped cells all also had two
ordered terminals and a1 alone could not tell the candidate gates apart.

### 6.2 "THE SPURIOUS OBJECT" IS NOT SPURIOUS

The brief calls the `interface_array` "the spurious object" and names the fix
direction as DELETE. Golden **builds the identical object** — same `VpiName`,
same `VpiSize`, same range, same four element views, same source span — and binds
it as the program port's `Low_conn` actual (`golden … |vpiLowConn: \_ref_obj:
(work@top.TC.output_intf) … |vpiActual: \_interface_array: (output_intf)`).
Deleting it would have broken that binding and traded a one-sided vector for a
one-sided `Actual_group`. The difference is **OWNERSHIP**, not existence, and the
distinction is what makes the law a three-clause law instead of a `continue`.

### 6.3 THE FIFTH `udpShapedInstantiation` CALL SITE THE BRIEF EXPECTED DOES NOT EXIST HERE

The brief offers *"the same `udpShapedInstantiation` predicate may be the correct
gate here too (FOUR call sites already; this could be the fifth — the
consolidation residue svs11 R3 flagged)"*. It is not. After this pass
`udpShapedInstantiation` still has exactly **four** call sites
(`ModuleEmit.cpp:1162, 1197, 2570, 8696`), all byte-identical, and svs11's
consolidation residue is untouched by this pass in either direction.

### 6.4 THE BRIEF'S ONE CORRECT CLAIM, CONFIRMED AND GENERALIZED

*"`Interfaces()` is measured null on BOTH sides (not the failing neighbour)."*
Confirmed on the witness, and arm a2 turns the observation into the law it
already was: a program instance lists no port-view `interface_inst` for scalar
actuals either, in all four connection styles, and the rule was already in the
tree with its reason written down (§2). That is what made the transcription
obvious once the parent-kind axis was measured.

### 6.5 A CARRIED SCRIPT'S DISPLAY WAS LOSSY — `msmovers.sh`

`msmovers.sh` has been carried since r10svs7 and its header states, correctly,
that keys include indentation. Its **display** then pipes the key through
`sed -E 's/\t +/\t/'`, which **strips the leading spaces from the printed
shape**. On a law that relocates a subtree this prints pairs of
identical-looking rows with no way to tell them apart — e.g. two separate
`ADDED +1 \_bit_var: (work@top.TC.output_intf[0].clock)` rows that are actually
indent 4 and indent 8. This is the same whitespace-blindness `msdist.sh` was
fixed for at integration on 2026-08-11, surviving one file over. `msthree.sh`
prints `(ind N)` explicitly and adds GOLDEN's column; `msmovers.sh` is left
byte-unchanged so the defect is reported rather than quietly patched under an
unrelated law.

### 6.6 THE FENCE ARM FOUND A DEFECT POINTING THE OTHER WAY

a4 `h1` exists only as a blast-radius fence for the third parent kind. It found
that on an `interface_inst` parent golden OWNS the port-view wrapper and **we
build none at all** (golden 1, ours 0) — a pre-existing MISSING object, the exact
mirror of the one this pass unowns. It is R3 in §7. An arm written only to prove
a gate does not over-fire turned up an under-fire next door.

### 6.7 WHAT THIS PASS DID **NOT** PROVE

The island's compared fields are **UNPROVEN EQUAL**, and saying otherwise would
be reading the head as a distance. After the fix, `program::Compare` fails at
`Ports()` on **`ports[0]` (`mem_intf`)**, whose `High_conn` is compared before
any later port's `Low_conn`. The `output_intf` port's `Low_conn` — and therefore
the whole relocated island — **is never reached by the comparator on this test**.
That its `VpiName`/`VpiSize`/`Ranges`/`Instances` all look equal in the dump is
an observation, not a `Compare` result; R1 must clear before it becomes one.

---

## 7. RANKED RESIDUES

**R1 (the new head, blocking; PRE-EXISTING).** The **col-0 TAIL DUPLICATE** of a
modport-connected `interface_inst` omits the interface's **own port variable**
from `Variables()`: golden's `work@top.mem_intf` tail dup lists
`bit_var clock, logic_var mem_data, mem_add, mem_en, mem_rd_wr` (5); ours lists
the four `logic_var`s only. The HOME view carries `clock` on both sides, so the
producer that builds the tail duplicate (`ifaceTailDup`) drops exactly the port
variable. **484 cmp lines, both modes.** Byte-identical on both binaries, so it
is not this pass's doing. This is the next head.

**R2 (the biggest remaining byte block; NOT compared).** The unowned island's
NAMING. Golden names it off the PORT — wrapper with **no** `vpiFullName`, elements
`output_intf.output_intf[i]`, and everything inside them prefixed `output_intf.` —
while we name it off the instance path (`work@top.TC.output_intf[i]`). ~110
indent-exact shapes and the bulk of the residual 864 multiset distance.
`instance_array::Compare` never reads `VpiFullName` and the elements' `VpiName`
matches, so this is DUMP-ONLY on today's comparator; it is the obvious next
byte-convergence target once R1 clears.

**R3 (one cell, opposite direction).** An `interface_inst` parent's port-view
`interface_array` is **MISSING** on our side (a4 h1: golden 1, ours 0). The
producer measured in §4 runs from `emitInstance`; the interface path
(`emitInterfaceInstance`) evidently never reaches this branch. Golden also gives
that wrapper a path-qualified fullname (`work@top.h1.a`), i.e. an
`interface_inst` parent OWNS it exactly like a module.

**R4 (cosmetic, both views).** Our `interface_array` range subtree is 2 lines
longer than golden's in EVERY cell, owned or unowned: our folded `INT:1` bound
constant carries a `|vpiParent:` back-pointer to the `\_operation:` and golden's
does not, and the range's own span is the whole `[4]` where golden's is one column
narrower. Uncompared; identical on both binaries; visible in a1/a3's def-view
`(oif.OP)` listings (42 golden vs 44 ours) as well as every elab one.

---

## 8. FILES IN THIS DIRECTORY

```
a1_ifarrport.sv     arm a1 — parent kind x connection style, iface-ARRAY port
a2_scalariface.sv   arm a2 — the SCALAR twin (Interfaces()), the control
a3_udpboundary.sv   arm a3 — udp-shape vs two-ordered-terminals, 12 cells
a4_parentkinds.sv   arm a4 — interface_inst parent + re-pass, the fence
svs13arm.sh         arm driver (carried from r10svs12repro/svs12arm.sh)
iaread.py           THE CELL READER — indent-column walk, own-vector sizes
gridread13.sh       run one arm and print its cells on one binary
basemark.sh         GATE 1's behavioural, two-directional base marker
svsgen.sh           the SVSwitch witness through THE HARNESS, both modes
census13.sh         carrier census — an UPPER BOUND, run BEFORE the verifier
msthree.sh          three-way per-shape mover table (GOLD/PRIS/SHIP), indent-explicit
msdist.sh           resync-immune multiset dump distance
msmovers.sh         carried mover analyser (display defect reported in §6.5)
byteverify.sh       GATE 5 byte verifier, two mandatory controls
ct8rows.sh          GATE 3/4 whole-row gate against the committed baseline
canaries.sh         33 named canaries, individually
ctcan2.sh           the supplementary canary check (brief names canaries.sh lacks)
canaudit.sh         AUDIT the canary scripts against the brief
README.verifier.md  the verifier's own notes, carried
```
