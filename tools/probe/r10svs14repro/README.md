# r10svs14 — THE COL-0 TAIL DUP'S `Variables()` **IS** THE HOME VIEW'S, AND THE OLD CODE FILTERED ON THE WRONG THING ENTIRELY

**Verdict, up front: SVSwitch DID NOT CONVERT.** Both rows are unchanged from the
committed baseline, so this pass is read in the **UNCONVERTED world** of GATE 4
and every gate below is judged against the unconverted expectation:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

No `results/*.csv` was touched by this pass.

The brief's target head — the col-0 **TAIL DUPLICATE** of `work@top.mem_intf`
listing **4** Variables where golden lists **5** with `bit_var clock` first, **484
cmp lines in both modes** — is **CLEARED**, and the head **ADVANCED out of the
program entirely**: from inside `instance::Compare`'s field **332** (`Programs()`)
to `module_inst::Compare`'s field **401** (`Interfaces()`), **484 → 31 cmp
lines**. The whole `program work@top.TC` subtree — all three ports, the
interface-array island `r10svs13` unowned, every tail dup it reaches — now
compares **EQUAL**.

* **ONE LAW, `§ ifaceDupVarsAreHomeVars14`**, and it is not a filter: the dup's
  `Variables()` **IS** the home view's, element for element and in order. The
  executable change is **5 lines** replacing **34**, in ONE function.
* **THE BRIEF'S NAMED ORDER RULE IS REFUTED.** "golden lists the port var FIRST"
  is false: arm b2 cell **d1** (a NON-ANSI interface whose body variable is
  declared BEFORE the port's own `input bit clk;`) has golden listing
  `logic_var dat` FIRST and `bit_var clk` LAST — on the home view AND on the dup.
  The order is the HOME VIEW's (declaration order) and nothing else (§6.1).
* **"MODPORT-CONNECTED" IS NOT THE DISCRIMINATOR EITHER.** Cell **c9** is the
  same interface with **no modport at all** and shows the identical defect and
  the identical fix (§6.2).
* **NOR IS THE RE-PASS.** The RECEIVING port's own view (`work@top.rN.p`, 14
  cells across the two arms) was **already correct on both binaries**; only the
  SOURCE instance's own col-0 dup was wrong (§6.3).
* **THE REAL DISCRIMINATOR IS THE UHDM CLASS OF THE SHARED HOME OBJECT**, and the
  old code tested the SLANG SYMBOL KIND instead. slang models an interface's ANSI
  header port as a **NetSymbol whatever its data type**, so `it.sym->kind ==
  SymbolKind::Net` dropped `input bit clock` (`bit_var`) and `input int n`
  (`int_var`) along with `input wire clk` (`logic_net`). Golden lists the first
  two and not the third (§2, §3.1).
* **GRID: 83 CELLS — 61 across two purpose-built arms and 22 on the witness.
  11 CONVERGED, 56 HELD, NOT ONE REGRESSED** (§3).
* **FIVE GATES GREEN** (§5) under the UNCONVERTED expectation.
* **MOVERS: 2** (`SVSwitch`, both modes) out of 1632 databases across both
  corpora — exactly what the census predicted after its 17-dir upper bound was
  reasoned down (§5.4.2, §5.5).
* **EIGHT REFUTATIONS plus a written list of what this pass did NOT prove**
  (§6): four against this pass's own brief, one against a script this pass
  generalised (`NAME` is an EXPORTED environment variable here, and the harness
  exited **0** with an EMPTY csv), and one against this pass's own headline — the
  **MULTISET DISTANCE DID NOT MOVE** (864 → 864), and §5.6 says why.

Base commit `42c42f6`, branch `auto5h`.
Pristine binary md5 **`1ca164075ce693c54c9d04045ae4624d`** (worktree
`/tmp/wt_r10svs14pris`, `git rev-parse HEAD` =
`42c42f6b568463a800f7855115598873ee9f4caa`, `git status --porcelain` EMPTY).
Shipped binary md5 **`56adb99b1fcf35bff90a416d199cf650`** (worktree
`/tmp/wt_r10svs14`, same `HEAD`, `git status --porcelain` = exactly
` M src/ModuleEmit.cpp` + `?? tools/probe/r10svs14repro/`).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script in
this directory.

---

## 1. LOCALIZATION

### 1.1 The head, on both sides, verbatim (the BASELINE head)

```
LHS: interface_inst: work@mem_interface (work@top.mem_intf), id:2472, line:26:0
RHS: interface_inst: work@mem_interface (work@top.mem_intf), id:2740, line:26:0
```

`line:26:0` with **no `endln`**: the **col-0 TAIL DUPLICATE**, reference style,
not the home view (`line:26:1, endln:26:31`). The first field that differs is
`Variables()`:

```
golden  bit_var clock, logic_var mem_data, mem_add, mem_en, mem_rd_wr     (5)
ours                   logic_var mem_data, mem_add, mem_en, mem_rd_wr     (4)
```

**The entire byte difference in that 89-line subtree is TWO LINES** (measured, not
asserted — `diff -u` of the two indent-0 subtrees):

```
-  \_bit_var: (work@top.mem_intf.clock), line:16:35, endln:16:40
-  |vpiVariables:
```

and **the HOME view is byte-identical on both sides** (177-line listings,
`diff` clean). Everything else about the dup already matched, down to the
modport's `io_decl (clock)` whose `vpiExpr` is **that same `bit_var`** on our side
too — the object was built, shared and reachable; it was only missing from **one
vector**.

### 1.2 It was never ONE cell — it was THREE, and the reader is what showed that

`dupread.py` walks the dump's indent column and reports every `interface_inst`'s
OWN listing (largest subtree wins; a `vpiParent` reprint has a subtree of zero
lines) keyed by **DEFNAME + FULLNAME + VIEW**, where the view is decided by the
**COLUMN** (`line:N:0` and no `endln` → DUP) and never by the name — Surelog gives
the dup the SAME `vpiName` and `vpiFullName` as the home view. On the witness:

```
                                     GOLDEN            OURS (baseline)
DUP  work@top.mem_intf               5  clock first    4   DIF
DUP  work@top.input_intf             4  clock first    3   DIF
DUP  work@top.output_intf[0]         4  clock first    3   DIF
HOME work@top.{mem,input,output[0..3]}                     EQ (all 6)
```

Three DIF cells, one cause. A reader keyed on the fullname alone would have
reported the HOME view's (correct) numbers for the dup and the localization would
have been unfalsifiable.

### 1.3 WHICH FIELDS ARE COMPARED — read off the generated comparators

```cpp
// interface_inst.cpp / scope chain: Variables() is a compared vector.
// instance.cpp:332       SafeCompare(lhs, lhs->Programs(),   rhs, rhs->Programs())
// program.cpp:221        SafeCompare(lhs, lhs->Ports(),      rhs, rhs->Ports())
// module_inst.cpp:400    Ports()      :401 Interfaces()      :402 Interface_arrays()
// module_inst.cpp:367    module_inst::Compare calls basetype_t::Compare (instance::Compare) FIRST
```

so `Programs()` (332, inside the base) is compared **before** `Interfaces()`
(401, module_inst's own) — the fact §1.4 turns on.

### 1.4 The head ADVANCED — settled by the compare order, not by the depth

A depth is not a distance, so the direction is settled by WHICH object
`m_failedLhs` names and where that object is reachable from.

```
                     BASELINE                          SHIPPED
cmp HEAD DEPTH       484                               31
cmp HEAD OBJECT      interface_inst tail dup           bit_var (work@top.output_intf[0].clock)
                     (work@top.mem_intf)               LHS only, RHS <null>
reached via          instance::Compare:332 Programs    module_inst::Compare:401 Interfaces
                       -> program work@top.TC
                       -> program::Compare:221 Ports
                       -> ports[0] (mem_intf) HighConn
                       -> ref_obj Actual -> the dup
                       -> Variables()
```

`Programs()` at 332 precedes `Interfaces()` at 401 in the SAME
`module_inst::Compare` invocation (module_inst calls `basetype_t::Compare` — i.e.
`instance::Compare` — as its FIRST statement, `:370`), so the head moved
**forward, out of `Programs()` and into `Interfaces()`**, and — the stronger
statement — **`SafeCompare` now returns 0 for the whole `Programs()` vector**, so
every field the comparator reaches inside `program work@top.TC` matched,
including ports[2]'s interface-ARRAY island that `r10svs13` unowned and its four
element views. r10svs13 §6.7 left those explicitly UNPROVEN because the
comparator stopped at ports[0]; they are no longer unproven.

**The reach is checked, not assumed.** The new failing `ref_obj`
(`work@top.output_intf[1].cb.clock`) lives in a CLOCKING BLOCK, and the only views
that carry `Clocking_blocks` are the HOME views: neither golden's island elements
(`output_intf.output_intf[i]`) nor ours (`work@top.TC.output_intf[i]`) contain any
`cb.clock` reference at all (grepped in both dumps, zero hits), so the object
cannot be reached from inside `Programs()` and must be reached from
`Interfaces()`/`Interface_arrays()` at `:401`/`:402`.

**The standing caveat, stated once and applying to every "compares equal" in this
campaign:** `BaseClass::Compare` short-circuits on
`m_visited.insert(this).second`, so "the vector returned 0" means *nothing the
comparator reached was unequal*, not *field-for-field identical*. The dump-level
statement is the one in §5.6: three two-line insertions, nothing else.

The new head, fully localized and **PRE-EXISTING** (R1 in §7): golden binds an
interface-ARRAY element's clocking-block clock reference to element **[0]**'s
variable, for elements **1..3 only**, and we leave it unbound:

```
golden  ref_obj (work@top.output_intf[1].cb.clock)  |vpiActual:
                 \_bit_var: (work@top.output_intf[0].clock)      <- element ZERO
ours    ref_obj (work@top.output_intf[1].cb.clock)  (no vpiActual)
```

Neither side binds `output_intf[0].cb.clock` or the scalar `mem_intf.cb.clock`,
so this is specifically the array-element re-resolution quirk that
`§ modportExprPort` already records for expression modport ports ("the FIRST
elaborated instance's variables"). **31 cmp lines, both modes.** It is
byte-identical on both binaries.

---

## 2. THE LAW

### § ifaceDupVarsAreHomeVars14

> **The col-0 tail duplicate's `Variables()` IS the HOME view's `Variables()` —
> element for element, object for object, and in the same order.** The dup SHARES
> the home view's variable objects (uhdm-dump prints them shallow because the
> home view was visited first) and it does **not decide membership for itself**.
> In particular the interface's **own ANSI HEADER PORT** appears in the dup
> exactly when it appears in the home view, i.e. exactly when its home object is
> a UHDM `variables`: `input bit clock` → `bit_var` **listed**, `input int n` →
> `int_var` **listed**, `input wire clk` / `input logic clk` / `output reg r` →
> `logic_net` **not listed**, a struct member → `struct_net` **not listed**, and
> `logic arr [0:1]` → `array_var` **listed**. The ORDER is the home view's
> declaration order — **not "the port variable first"**: a NON-ANSI interface
> whose body variable is declared before the port's own `input bit clk;` lists
> the body variable FIRST, in golden, on both views. The DOUBLING an interface
> handed to an unbound generic `interface` port shows is likewise the home view's
> and needs no separate computation.

### STATED GATE == CODE GATE

The whole executable change in `src/ModuleEmit.cpp`, `makeIfaceRefDup`:

```cpp
auto* vars = s.MakeVariablesVec();
if (home && home->Variables())
    for (auto* hv : *home->Variables())
        vars->push_back(hv);
if (!vars->empty())
    dup->Variables(vars);
```

**There is no gate.** No symbol-kind test, no UHDM-type switch, no modport test,
no port-count test, no doubling predicate, no name and no string. That is exactly
what the law above says, and §3 measures each of the deleted conditions as its own
axis.

### What was there before, and the one thing it got wrong

```cpp
auto* vars = s.MakeVariablesVec();
for (auto& it : collectNetOrder(body))
    if (auto nit = it.portExprNet ? sharedNets.end() : sharedNets.find(it.sym);
        nit != sharedNets.end()) {
        if (it.sym->kind == SymbolKind::Net)          // <-- THE BUG
            continue;
        switch (nit->second->UhdmType()) {            // five NET-CLASS types
            case UHDM::uhdmstruct_net: case UHDM::uhdmlogic_net:
            case UHDM::uhdmarray_net:  case UHDM::uhdmenum_net:
            case UHDM::uhdmpacked_array_net: continue;
            default: break;
        }
        vars->push_back((UHDM::variables*)nit->second);
    }
if (!vars->empty() && boundToPlainGenericIfacePort(                 // a SECOND
        inst, [this](const InterfacePortSymbol& ip9) {               // COPY of
            return isUnboundGenericIfacePort(ip9);                   // the home
        })) {                                                        // view's
    size_t half9 = vars->size();                                     // dblVars9
    for (size_t i9 = 0; i9 < half9; i9++) vars->push_back((*vars)[i9]);
}
```

The list was **RE-DERIVED from the symbol table** and then filtered twice. The
`SymbolKind::Net` filter is the defect: **slang models an interface's ANSI header
port as a `NetSymbol` regardless of its data type**, so it dropped every header
port — including the ones whose home object is a `variables`. Its own comment
("NET-kind symbols (header-port-backing clk/rst wires) are not listed as dup
Variables (Surelog); they reach the dup via the modport io_decl exprs instead")
was **right about `clk`/`rst` wires and wrong as a rule**, and the switch below it
was already testing the correct thing (the UHDM class) for the five cases it
enumerated. The home view's own `Variables()` vector applies exactly that
partition, in exactly golden's order — so copying it is the whole rule.

**The two candidate patches are output-identical, and that was checked before
choosing.** Every push into the home view's `vars` happens at exactly four sites
(`grep -n 'vars->push_back' src/ModuleEmit.cpp` restricted to the interface
emitter: `:23321 av`, `:23360 bv`, `:23503 v`, `:23535` the doubling), all inside
the SAME `collectNetOrder(body)` loop, and each of those three objects is also
written into `netMap`. So

```
home->Variables()  ==  { netMap[sym] : sym in collectNetOrder(body),
                         netMap[sym] is a UHDM variables }   in the same order
```

i.e. "filter the derivation by UHDM class instead of symbol kind" and "copy the
home list" produce the identical vector. The shipped one is chosen because it
**states** the law rather than re-deriving it, and because it deletes the second
copy of the doubling predicate. Both were measured on the same 61 arm cells.

---

## 3. THE GRID, CELL FOR CELL

A CELL is one (interface view, ordered `Variables()` list) pair. Views are keyed
by DEFNAME + FULLNAME + **VIEW**, where VIEW is HOME or the col-0 DUP and is
decided by the COLUMN, never by the name (§1.2). Both columns were produced from
the SAME golden — `grid14.sh` refuses the table unless the two arm runs' golden
dumps are identical after normalising the scratch-directory path, which is the
only thing that legitimately differs between them.

Both arms ran on BOTH binaries; all four workdirs are on disk
(`/tmp/r10svs14_arm_{pris,ship}_b{1,2}`).

### 3.1 `b1_hdrport.sv` — THE HEADER-PORT KIND, one axis, nine interfaces

Every interface carries a modport, every instance is handed WHOLE (a bare,
dot-free connection) to a sibling module port — which is what mints the dup.

```
cell  interface header             home object   GOLDEN dup vars        PRIS  SHIP
c1    input bit clock  + clocking  bit_var       3  clock,d,e           DIF 2  EQ  <- THE WITNESS
c2    input wire clk               logic_net     2  d,e                 EQ     EQ  <- InterfaceModPort's shape
c3    input logic clk              logic_net     1  d                   EQ     EQ
c4    input int n                  int_var       2  n,d                 DIF 1  EQ
c5    output reg r                 logic_net     1  d                   EQ     EQ
c6    input bit a, wire w, bit b   bit_var x2    3  a,b,d               DIF 1  EQ
c7    (no header port)             -             2  d,e                 EQ     EQ
c8    input bit clock, NO body var bit_var       1  clock               DIF 0  EQ
c9    input bit clock, NO MODPORT  bit_var       2  clock,d             DIF 1  EQ
      the same nine interfaces' HOME views                              EQ x9  EQ x9
      the nine RECEIVING PORTS' own views (work@top.rN.p)               EQ x9  EQ x9
                                   cells 36    held 31   CONVERGED 5   REGRESSED 0
```

**Three columns cross the outcome column.** `bit` vs `wire` splits it (c1 vs c2);
`int` vs `logic` splits it the same way (c4 vs c3) so it is not "2-state"; and c9
has **no modport** while c2 has one, so the modport does not enter it. What
predicts every cell is the single column "home object" — `variables` or `nets`.

### 3.2 `b2_orderdbl.sv` — ORDER, DOUBLING, RECEIVER KIND, COMPANIONS, ARRAYS

```
cell  shape                                   GOLDEN dup vars          PRIS      SHIP
d1    NON-ANSI, body var declared FIRST       2  dat, clk (!)          EQ        EQ
d2    NON-ANSI, port declared FIRST           2  clk, dat              DIF       DIF  <- R4
d3    handed to an UNBOUND generic port       2  clk, dat              DIF 2     DIF 4 <- R5
d4    handed to a PROGRAM (SVSwitch's shape)  2  clk, dat              DIF 1     EQ
d5    struct + unpacked-array companions      3  clk, arr, pl          DIF 2     EQ
d6    instantiated as an ARRAY  e6[2]         2  clk, dat              DIF 1     EQ
      HOME views                              (d2, d3 DIF on both)     -         -
      receiving ports' own views x5            (x2.p, x4.p DIF)        -         -
                                   cells 25    held 16   CONVERGED 3   REGRESSED 0   stillDIF 6
```

**d1 is the refutation of the brief's order rule** (§6.1): golden lists
`logic_var dat` FIRST and `bit_var clk` SECOND, and we already matched it — the
non-ANSI header port was never affected, because slang gives it a body
declaration and it never took the `SymbolKind::Net` path.

**d2 and d3 are PRE-EXISTING HOME-VIEW defects** and both are DIF on the home view
on BOTH binaries: d2's order (R4) and d3's doubling (golden 2, ours 4 — R5).
**d3's DUP is the one cell whose content changed without converging**: 2 → 4
entries, because the dup now inherits the home view's over-doubled list. It is
reported as CHANGED-NOT-CONVERGED, its multiset distance to golden is 2 before and
2 after, and its cause is R5 and not this law — the dup and the home now agree,
which is what golden does, so ONE defect remains instead of two.

**d5 fences the two companion classes in opposite directions in one cell**: the
`struct` member (`struct_net`) must stay OUT and the unpacked array (`array_var`)
must stay IN, and both hold on both binaries.

### 3.3 The witness itself, 22 cells

```
                                   PRIS            SHIP
DUP  work@top.mem_intf             DIF 4 / 5       EQ
DUP  work@top.input_intf           DIF 3 / 4       EQ
DUP  work@top.output_intf[0]       DIF 3 / 4       EQ
HOME x6, DEF x3                    EQ              EQ
the 10 program-port-view / island-naming cells (R2, R3)  DIF        DIF
                                   CELLS 22   EQ 9 -> 12   REGRESSED 0
```

### 3.4 Totals

```
arm       cells   held   CONVERGED   REGRESSED   stillDIF
b1           36     31       5            0          0
b2           25     16       3            0          6
witness      22      9       3            0         10
        -------  -----  ---------   ---------   --------
             83     56      11            0         16
```

**Not one cell regressed**, and the 16 stillDIF cells are R2/R3/R4/R5 — every one
of them DIF on the pristine binary too, and 15 of the 16 byte-identical on both.

---

## 4. THE PRODUCER

`src/ModuleEmit.cpp`, `UhdmExporter::makeIfaceRefDup` (`:22474`), the Variables
block. One call site (`:23876`, the interface home-view path, which passes the
home `iface`); `grep -c 'makeIfaceRefDup('` = **3** = the definition, the new
comment, and that one call.

```
 src/ModuleEmit.cpp | 83 ++++++++++++++++++++++++++++++++----------------------
 1 file changed, 50 insertions(+), 33 deletions(-)
```

**5 executable lines replace 34**; 45 of the 50 insertions are the comment that
records the measurement. `sharedNets` stays a parameter — it still resolves the
dup's modport `io_decl` `vpiExpr`s a hundred lines further down, which is the
other half of what the deleted comment described and is untouched here.

Nothing else in the dup builder is disturbed, and that is measured rather than
argued. `§ ifaceDupSharesHomePorts` (the deferred port share), the dup's own
default-valued `Parameters()` + shared `Param_assigns()`, its self-referencing
`Modports()` and their `io_decl` exprs: the pristine→shipped diff of each arm's
OURS dump contains **only additions, and only two kinds of line**:

```
arm b1   6 x  > |vpiVariables:        and 6 objects:  bit_var  c1.clock
         0 removed lines                              int_var  c4.n
                                                      bit_var  c6.a, c6.b
                                                      bit_var  c8.clock, c9.clock
arm b2   5 x  > |vpiVariables:        and 5 objects:  bit_var  e3.clk (TWICE — the
         0 removed lines                                       R5 doubling)
                                                      bit_var  e4.clk, e5.clk,
                                                               e6[0].clk
```

Six objects for b1's five converged cells (c6 needed two), five for b2's three
(e3 is the doubled non-converging cell). **Zero removed lines in either arm** —
so no port, parameter, param_assign, modport or io_decl moved anywhere, and
c2/c3/c5/c7 plus d1 hold all of them fixed while the others move.

---

## 5. THE FIVE GATES

### 5.1 GATE 1 — BUILD

```
/tmp/wt_r10svs14                    (shipped)
[100%] Linking CXX executable slang-uhdm      <- the link line, forced and waited for
[100%] Built target slang_uhdm
BUILD_RC=0    compiler "error:" lines: 0
md5(build/slang-uhdm) = 56adb99b1fcf35bff90a416d199cf650
   32-HEX ASSERT: OK (len=32)                 <- asserted SEPARATELY from the build
git rev-parse HEAD  = 42c42f6b568463a800f7855115598873ee9f4caa
git status --porcelain =  M src/ModuleEmit.cpp
                        ?? tools/probe/r10svs14repro/

/tmp/wt_r10svs14pris                (pristine, built HERE, not reused)
[100%] Linking CXX executable slang-uhdm
[100%] Built target slang_uhdm
BUILD_RC=0    compiler "error:" lines: 0
md5(build/slang-uhdm) = 1ca164075ce693c54c9d04045ae4624d
   32-HEX ASSERT: OK (len=32)
git rev-parse HEAD  = 42c42f6b568463a800f7855115598873ee9f4caa
git status --porcelain = <EMPTY>
```

Both binaries were relinked from scratch (`rm build/slang-uhdm` before the build)
so the link line is real and not a stale-target message.

**Cross-check on the pristine binary, and it is a real one:** r10svs13 (the pass
that PRODUCED `42c42f6`) reports its shipped SVSwitch `o.dump` md5 as
`8417bab6ec5e1e2e351875153f21b394` and the golden as
`886fbfeb40956c7ced8b702809981c64`. The pristine binary built here reproduces
**both**, in BOTH modes, along with r10svs13's 484 / 25694 / 1352 / 864. The
baseline is the committed one, not a look-alike.

**THE BASE MARKER IS BEHAVIOURAL AND TWO-DIRECTIONAL** (`basemark.sh`, run on
every binary these gates quote). This pass adds no new symbol — the law name lives
only in a comment (`strings … | grep -c ifaceDupVarsAreHomeVars14` = **0** on
BOTH binaries) and the code calls a pre-existing accessor:

```
SOURCE      grep -c ifaceDupVarsAreHomeVars14 src/ModuleEmit.cpp
              shipped worktree = 1        pristine worktree = 0
COUNT       b1 cell c1's col-0 DUP vpiVariables entries
              pristine = 2               shipped = 3
FIRST SLOT  the FIRST of those entries              <- the two-directional half
              pristine = logic_var d    shipped = bit_var clock
CONTROL A   c2 (input wire clk) DUP entries
              BOTH binaries = 2, first = logic_var d
CONTROL B   c1's HOME view entries (already correct before this pass)
              BOTH binaries = 3, first = bit_var clock
```

### 5.2 GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped>  tests/check_goldens.sh  ->  23 PASS / 0 FAIL   (rc=0)
SLANG_UHDM=<pristine> tests/check_goldens.sh  ->  23 PASS / 0 FAIL   (rc=0)
SLANG_UHDM=/bin/false tests/check_goldens.sh  ->   0 PASS / 23 FAIL  (rc=1, control FIRES)
```

Stated honestly: no golden hands a whole interface with a variables-class header
port to a sibling instance, so the 23 prove this law broke nothing; **they cannot
confirm it.** The instruments that confirm it are §3 and GATE 5.

### 5.3 GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
PRISTINE control sweep, judged the same way:   0 differing ROWS (0 diff row-sides)
```

### 5.4 GATE 4 — surelog `--mode both --jobs 2` (`GOLDEN_DEFER` left UNSET)

**THE WORLD IS THE UNCONVERTED ONE, SAID FIRST**: `SVSwitch` stays
`CMP_NOTEQUAL` in both modes, so the unconverted expectation applies and it is
**0 row-sides**, not 2 per mode.

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

The two sweeps were run **SEQUENTIALLY**, not concurrently: the ops rules mark
`SURELOG_FAIL` detail rows as racing under concurrent sweeps, and this corpus also
carries a `TIMEOUT` row (`Google,testflags`) that load can flip. Nothing else was
run against either sweep while it was in flight.

CANARIES, and the two the rules require BY NAME first:

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

#### 5.4.1 `InterfaceModPort` — THE PROTECTED IN-FAMILY CANARY, MEASURED, NOT ASSUMED

The ops rules make it a stop condition, so it was read BY NAME FIRST and then
measured **from the sweep's own control workdirs** (no extra run, no perturbation).
Its 7 cells:

```
view  fullname                                   GOLDEN vars   OURS   verdict
DUP   work@interface_modports.miff                    11        11    EQ
HOME  work@interface_modports.miff                    11        11    EQ
DUP   work@interface_modports.U_ctrl.sif              11        11    EQ
DUP   work@interface_modports.U_model.mif             11        11    EQ
DUP   work@interface_modports.U_test.tif            ABSENT      11    DIF  <- R2, pre-existing
HOME  work@mem_if (def)  /  work@mem_interface (def)   0         0    EQ x2
```

**Why this law cannot reach it, stated as a measurement:** the instantiated
interface is `mem_if (input wire clk)` — a 4-state `wire` header port, home object
`logic_net`, **excluded by the old rule AND by the new one** (that is arm b1 cell
c2). The one interface in that file with a `bit` header port, `mem_interface(input
bit clock)`, is **never instantiated**, so it has no tail dup at all. The one DIF
cell is the PROGRAM port view R2, DIF on both binaries. **0 byte movement**
(GATE 5), rows byte-identical, and it is named first here because the rules say so.

#### 5.4.2 CENSUS-PREDICT, run FIRST, and it is an UPPER BOUND

`census14.sh` filters on the law's ONE necessary source condition — an interface
with an **ANSI header port carrying a variables-class data type** — parsing each
`interface` header with balanced parens rather than grepping lines, because a
header spans lines and `bit`/`int` occur everywhere else. Three sufficient
conditions are omitted (the interface must be INSTANTIATED; some sibling must
receive it WHOLE through a bare dot-free connection; slang must accept the file),
so this is a necessary-condition filter. Run BEFORE the verifier and recorded
before its answer was known:

```
surelog corpus : 10 of 750 test dirs
   InterfAlways  InterfaceBinding  InterfaceModPort  Google  OVMSwitch
   SVSwitch      SimpleUVM         Tnoc              UVMSwitch  Verilator
u2r corpus     :  7 of 734 test dirs
   ImportedPackageEnumItemInInterface  InterfaceAlways  InterfaceAssign
   InterfaceInitial  InterfaceWithPort  add_sub_bind_if  iface_pkg_enum_item
UPPER BOUND    : 17 test dirs
```

The verifier found **2 movers, both `SVSwitch`**, and **0 in the other 16** — an
8:1 over-count at the test-dir level, recorded as such. Its real service was
naming the 16 so their non-movement could be **explained rather than assumed**,
and every one of them fails a condition the filter does not test:

```
OVMSwitch UVMSwitch Tnoc Verilator Google   SLANG_REJECT / TIMEOUT -> no database
InterfaceModPort                            its bit-port iface is never INSTANTIATED (§5.4.1)
InterfaceBinding SimpleUVM                  the iface is BIND-instantiated; no sibling
                                            receives it whole -> no tail dup
InterfAlways                                sw_test_status_if(output int x) is not
                                            passed to anything
the 7 u2r dirs                              same: `sw_test_status_if(output int x)` /
                                            `sim_sram_if(input int x)` are instantiated
                                            and READ, never handed on -> no tail dup
```

Note that 7 of those u2r rows are `CMP_EQUAL` **with dump `match`** — fully
byte-identical tests — so the census's job here was to find the highest-risk
non-movers and it did.

### 5.5 GATE 5 — BYTE VERIFIER, both corpora BOTH modes, vs a PRISTINE 42c42f6 built here

`byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 2 / 953
          SELFCHECK 952/953 flagged        SELFCHECK1 = 3  (= 2 flagged + 1 corrupted)

  ./default/SVSwitch-db796243/slang.uhdm      patched=a9b96265ef3d pristine=98b682118031
  ./testflags/SVSwitch-db796243/slang.uhdm    patched=a9b96265ef3d pristine=98b682118031
```

**2 movers, both the target, both modes, and NO third row printed** — in
particular `Scoreboard/default`, which r10svs13 had to run down as a
three-hash flake, did not appear at all this time, and no `InterfaceModPort`
row appeared in either mode, which is the byte-level form of §5.4.1's claim.
And the PRISTINE hash `98b682118031` is the one r10svs13 reports as its own
SHIPPED SVSwitch hash: a second independent confirmation that the baseline built
here is `42c42f6` itself.

### 5.6 MOVERS PER SHAPE, BY MULTISET — AND THE HEADLINE THIS REFUTES

`sed 1d` on every dump; ADDED and REMOVED counted **separately** and never netted;
every shape checked against **GOLDEN's own count**, which is the only test that
says a mover is a CONVERGENCE. Keys include the leading indentation
(`msthree.sh`, which prints it as `(ind N)`; `msmovers.sh`'s display strips it —
the defect r10svs13 §6.5 reported and left in place).

```
                                                                     GOLD PRIS SHIP
ADDED  OBJ  (ind 2)  \_bit_var: (work@top.mem_intf.clock) 16:35-16:40    2    1    2
ADDED  OBJ  (ind 2)  \_bit_var: (work@top.input_intf.clock) 38:37        2    1    2
ADDED  OBJ  (ind 2)  \_bit_var: (work@top.output_intf[0].clock) 58:38    2    1    2
BARE FIELD lines (NON-ATTRIBUTABLE absorbers, listed not counted as objects)
ADDED  FLD  (ind 2)  |vpiVariables:                                     38   44   47
TOTAL SHAPES MOVED   4
```

**All THREE object shapes land on GOLDEN's count EXACTLY**, and there is no fourth
`bit_var` shape and no REMOVED shape at all: the entire database delta is three
two-line insertions and nothing else (`diff -u` of the pristine and shipped
`o.dump`, +6 lines, 3 hunks, quoted in full below).

```
@@ -21957,6 +21957,8 @@              (and the same two lines at input_intf and
   |vpiVariables:                     output_intf[0])
+  \_bit_var: (work@top.mem_intf.clock), line:16:35, endln:16:40
+  |vpiVariables:
   \_logic_var: (work@top.mem_intf.mem_data), line:17:15, endln:17:23
```

**AND NOW THE REFUTATION OF THIS PASS'S OWN HEADLINE — THE MULTISET DISTANCE DID
NOT MOVE:**

```
                                   PRISTINE      SHIPPED     GOLDEN
cmp HEAD DEPTH (NOT a distance)       484            31          -
cmp HEAD OBJECT                    iface tail dup  bit_var       -
dump content +/- (diff -u, -2 hdrs)  1352          1346          -
MULTISET DISTANCE (resync-immune)     864           864          -
golden-only line instances             244           241         -
ours-only   line instances             620           623         -
o.dump lines                         25694         25700       25318
```

The three `bit_var` shapes we added were golden-only deficits, so golden-only fell
by exactly 3. The three `|vpiVariables:` labels that came with them pushed
ours-only UP by exactly 3, because **our count for that bare label was ALREADY 6
over golden's** (44 vs 38) — and the reason is a DIFFERENT, pre-existing defect:
the two program-port-view dups `work@top.TC.mem_intf` and
`work@top.TC.input_intf` that we mint and golden does not have at all (R2), each
contributing indent-2 `|vpiVariables:` labels. So the metric nets to zero, and
saying "the design got closer by N lines" would be false. What DID move is the
head (484 → 31, forward by 69 fields, out of the program entirely), the content
count (-6), and 11 grid cells.

Identical in both modes on both binaries: the two `slang.uhdm` databases are
**byte-identical mode-to-mode** (`cmp` run and printed), the two `o.dump` files
share one md5 per binary (`51688c74c86c77153ef2212d61154cf0` shipped,
`8417bab6ec5e1e2e351875153f21b394` pristine), and the two `cmp.txt` files are
byte-identical mode-to-mode (`d28f8f5dc6c3e5237c8c4c7a0cea6e46` shipped,
`608f61cab8da529a487b8f2765f96dc9` pristine).

---

## 6. REFUTATIONS

### 6.1 THE BRIEF'S ORDER RULE IS WRONG — THE PORT VARIABLE IS NOT "FIRST"

The brief: *"(e) the ORDER rule (golden lists the port var FIRST — is it
port-order or decl-order?)"*. Neither, as stated: arm b2 cell **d1** is a NON-ANSI
interface

```systemverilog
interface d1_if(clk);
  logic [7:0] dat;      // body variable declared FIRST
  input bit clk;        // the PORT's own declaration, AFTER it
```

and golden lists `logic_var dat` **first**, `bit_var clk` **second** — on the home
view AND on the col-0 dup. Cell d2, the same interface with the two declarations
swapped, has golden listing `clk` first. So the order is the **home view's
declaration order**, which is why the shipped law does not compute an order at all;
it inherits one. A rule that prepended the port variable would have broken d1, and
d1 exists only because b1's ANSI cells cannot tell the two candidate rules apart
(there the port is written first anyway).

### 6.2 "MODPORT-CONNECTED" IS NOT THE DISCRIMINATOR

The brief calls the head "the modport-connected interface" and names
`InterfaceModPort` as the in-family canary because "modport-connected interfaces
are its whole subject". Cell **c9** is `interface if_nomp(input bit clock)` with
**no modport at all**, handed to a plain whole-interface port: golden 2, ours 1,
DIF — the identical defect — and it converges identically. Meanwhile c2 HAS a
modport and never moves. The modport enters the dup's `Modports()`/`io_decl` exprs
and does not enter its `Variables()`.

### 6.3 NOR IS THE RE-PASS — THE RECEIVING VIEW WAS ALREADY RIGHT

The brief: *"The head is about which VARIABLES a re-passed/tail-duplicated
interface_inst lists — the elaborated interface re-pass machinery."* Half right.
The 14 RECEIVING-port views across the two arms (`work@top.r1..r9.p`,
`work@top.x1/x2/x5/x6.p`) are `interface_inst` objects built by the **port-view**
path, they are also printed at col 0, and **every one of them already listed the
header-port variable on the pristine binary** (b1: 9 of 9 EQ). The defect was
confined to the SOURCE instance's OWN dup, built by `makeIfaceRefDup`, which is a
different producer from the re-pass path. Naming the re-pass machinery would have
sent the patch to the wrong function.

### 6.4 THE DEFECT IS NOT ABOUT `bit`, AND NOT ABOUT "2-STATE"

Cell **c4** is `input int n` — a 4-byte integer type, `int_var` — and it was
dropped exactly like `bit`. Cell **c3** is `input logic clk`, also a single bit,
and it is correctly absent on both sides. The axis is `variables` vs `nets`, i.e.
whether slang's default net type applies, and `bit`/`int`/`var` versus
`wire`/`logic`/`reg` is only how that axis shows up in the source.

### 6.5 IT IS NOT A "MISSING FIRST ELEMENT" BUG

The head reads as "the port variable is missing from the front of the list", which
invites a fix that prepends. Cell **c8** (`interface if_portonly(input bit clock)`
with NO body variables) has golden **1** and ours **0** — the vector was not
merely short at the front, it was **absent entirely** (`if (!vars->empty())`), so
the dup carried no `vpiVariables` label at all.

### 6.6 A CARRIED SCRIPT'S DEFAULT WAS CAPTURED BY THE ENVIRONMENT — AND THE HARNESS EXITED 0

Generalising `svsgen.sh` from `--filter '^SVSwitch$'` to a parameter, the obvious
spelling is `NAME=${NAME:-SVSwitch}`. **This environment EXPORTS `NAME`** (it is
the machine/user tag, `tsungtso-ca`), so the script filtered on `^tsungtso-ca$`,
matched **0 tests**, and `verify_golden.py` **exited 0 with a header-only csv** —
`harness rc=0` printed, and only the downstream `grep` for the row caught it. A
green rc on a run that measured nothing is the exact failure mode this campaign's
guards exist for; the parameter is now `TESTNAME` and the trap is written into the
script's header so the next generalisation does not repeat it.

### 6.7 `msdist` DID NOT IMPROVE, AND THE PER-SHAPE TABLE IS WHY

Reported in full in §5.6 rather than buried: 864 → 864. A pass that quoted only
"head 484 → 31" and "content 1352 → 1346" would be reporting a byte convergence
that the resync-immune metric does not show. The three converged object shapes are
cancelled by one bare-label absorber whose excess belongs to R2.

### 6.8 THE DELETED DOUBLING BLOCK WAS A SECOND COPY OF A RULE, AND IT SHOWED

`makeIfaceRefDup` recomputed `boundToPlainGenericIfacePort(inst,
isUnboundGenericIfacePort)` — the same predicate the interface emitter had already
applied to the very vector being copied (`dblVars9`, `src/ModuleEmit.cpp:23528`).
Two copies of one rule cannot disagree about WHETHER to double, but they did
disagree about WHAT to double: on b2 cell d3 the pristine dup doubled its
`clk`-less 1-element list to `[dat, dat]` while the home view doubled the correct
2-element list to 4. Golden doubles neither (R5). After this pass the dup and the
home agree and exactly one defect remains there.

### 6.9 WHAT THIS PASS DID **NOT** PROVE

* It did not prove that a `variables`-class header port is listed on a **PORT
  VIEW** for the right reason. Those 14 cells were already EQ on both binaries and
  are produced by a different path (`portView`, which has its own `portBacked9`
  logic); this pass did not touch them and did not audit them.
* It did not prove anything about `time`/`real`/`chandle`/`var logic` header
  ports. The census pattern includes them; no arm cell and no corpus test
  exercises them, and the law is stated in terms of the home object's class
  precisely so that they need no new rule — but that is a prediction, not a
  measurement.
* The multiset distance is unchanged (§6.7), so "the design is closer to golden in
  bytes" is UNPROVEN by this pass's own instrument. The head and the grid are what
  moved.

---

## 7. RANKED RESIDUES

**R1 (the new head, blocking; PRE-EXISTING).** An interface-ARRAY element's
CLOCKING-BLOCK clock reference. Golden binds `work@top.output_intf[1..3].cb.clock`
to element **[0]**'s `bit_var` — the FIRST elaborated element's variable, the same
quirk `§ modportExprPort` records for expression modport ports — and leaves
element **[0]**'s own reference (and the scalar interfaces' `cb.clock`) UNBOUND.
Ours leaves all of them unbound. **31 cmp lines, both modes**, byte-identical on
both binaries. This is the next head, and the rule to transcribe is "elements
1..N-1 bind to element 0", which is narrow and testable.

**R2 (the biggest byte block, and the one that ate this pass's multiset gain).**
We MINT an `interface_inst` PORT VIEW for a **program**'s interface port and
golden has none at all: `work@top.TC.{mem_intf,input_intf,output_intf[0..3]}` on
the witness (6 objects), `work@top.x4.p` on arm b2, and
`work@interface_modports.U_test.tif` on `InterfaceModPort`. It is the same
producer decision `§ progPortIfaceArrayUnowned13` (LANDED at `42c42f6`) settled
for the interface-ARRAY wrapper's OWNERSHIP, one step further: for a program the
scalar port view is not merely unowned, it does not EXIST. **This sits directly on
that law's declared boundary, so it is reported and NOT touched here.** Its
`|vpiVariables:` labels are the whole of our 9-line excess on that shape (§5.6).

**R3 (svs13's R2, unchanged).** The unowned interface-array island's NAMING:
golden names it off the PORT (`output_intf.output_intf[i]`), we name it off the
instance path (`work@top.TC.output_intf[i]`). Uncompared today
(`instance_array::Compare` never reads `VpiFullName`); ~10 of the witness's 22
cells.

**R4 (one arm cell, HOME view, pre-existing).** A NON-ANSI header port's ORDER.
`interface d2_if(clk); input bit clk; logic [7:0] dat;` — golden lists
`[clk, dat]`, we list `[dat, clk]`, on the HOME view and therefore now also on the
dup and on the receiving port's view. `collectNetOrder` sorts the port item by the
PORT's location bucket rather than by its body declaration's; d1 (the reverse
order) is EQ, so the two cells bracket the fix.

**R5 (one arm cell, HOME view, pre-existing).** The generic-port DOUBLING
over-fires. `interface d3_if(input bit clk)` handed to `module rx_gen(interface
bus)` — an UNBOUND generic port — has golden listing its 2 variables ONCE and us
listing them TWICE, on the home view, on both binaries. Since the dup now copies
the home list, the over-fire is visible in two places instead of one, which is
correct behaviour for a wrong list. `dblVars9` / `boundToPlainGenericIfacePort`
(`src/ModuleEmit.cpp:23528`) is the single place to fix it.

---

## 7.1 WHAT IS STILL ON DISK, AND WHAT WAS DELETED

The two ARM workdirs per binary are kept because §3's table is re-readable from
them without re-running either tool:
`/tmp/r10svs14_arm_{pris,ship}_b{1,2}`, plus the witness pair's dumps and cmp
reports in `/tmp/r10svs14_svs_{pris,ship}` and the `InterfaceModPort` control
dumps in `/tmp/r10svs14_imp`. The four CSVs
(`/tmp/r10svs14_{sl,u2r}_{pris,ship}.csv`) are kept.

The four SWEEP workdirs (`/tmp/r10svs14_{sl,u2r}_{ship,pris}_wd`, 799 MB) were
**DELETED** after GATE 5 read them, as the ops rules require. Every number they
produced is quoted above; re-deriving them needs the two binaries, both of which
are still in their worktrees with the md5s in §5.1.

Also verified before quoting: the arm `.sv` files copied into all four arm
workdirs are byte-identical to the ones shipped in this directory (`cmp`, 4 of 4),
so the grid was measured on the sources that are being landed.

---

## 8. FILES IN THIS DIRECTORY

```
b1_hdrport.sv       arm b1 — the HEADER-PORT KIND, 9 interfaces, 36 cells
b2_orderdbl.sv      arm b2 — order / doubling / receiver kind / companions, 25 cells
svs14arm.sh         arm driver (carried from r10svs13repro/svs13arm.sh)
dupread.py          THE CELL READER — indent-column walk, DUP vs HOME by COLUMN
grid14.sh           the grid: both binaries in one table, golden-identity asserted
basemark.sh         GATE 1's behavioural, two-directional base marker
svsgen.sh           one corpus test through THE HARNESS, both modes (TESTNAME=…)
census14.sh         carrier census — balanced-paren header parse, an UPPER BOUND
msthree.sh          three-way per-shape mover table (GOLD/PRIS/SHIP), indent-explicit
msdist.sh           resync-immune multiset dump distance
msmovers.sh         carried mover analyser (display defect reported in svs13 §6.5)
byteverify.sh       GATE 5 byte verifier, two mandatory controls
ct8rows.sh          GATE 3/4 whole-row gate against the committed baseline
canaries.sh         33 named canaries, individually
ctcan2.sh           the supplementary canary check (brief names canaries.sh lacks)
canaudit.sh         AUDIT the canary scripts against the brief
README.verifier.md  the verifier's own notes, carried
```
