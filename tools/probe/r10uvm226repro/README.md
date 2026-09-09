# r10uvm226 — § ifaceDefListsItsOwnProcesses226

**An interface DEFINITION lists its own procedural blocks as `Process()`,
whether or not anything elaborates it — and in the view nothing elaborates,
every reference in those bodies is bare except in the class-method binding
window.**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; they are named only inside `canaudit.sh`'s own `FENCED=`
list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `d51916f9` |
| pristine binary | md5 `52ad6bb9c32d5f34198b6c24a3de339d`, built `-j 2` from this pass's OWN worktree at a clean `d51916f9` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's `build/slang-uhdm` at that commit** |
| patched binary | md5 `437d06b01c501a1154f27f095a74a578`, frozen `chmod 555`. **The deliverable patch applied to a FRESH `d51916f9` worktree and built there comes out byte-identical to it** — every gate below was run on the binary the patch reproduces. |
| production surface | `include/UhdmExporter.h`, `src/ExprEmit.cpp`, `src/ModuleEmit.cpp` |
| probe surface | `tools/probe/r10uvm226repro/` only |

---

## 1. THE QUESTIONS, ANSWERED IN ORDER

### (1) RE-MEASURED FIRST, on this pass's own pristine build

`rowheads.sh` on this pass's own pristine sweep, before a line was written:

```
TEST           MODE      CMPLINES  HEADS
MiniAmiq       default     713053      1   cmp rc=255
MiniAmiq       testflags   713053      1   cmp rc=255
SeqDriver x2, SimpleUVM x2, Scoreboard/default,
BuildUVMPkg x2, Earlgrey_0_1 x2, Rggen/default      0 lines, 0 heads, rc=0
```

and `ct226field` (r10uvm225's `ct225field`, copied verbatim; MEASUREMENT-ONLY)
walking `instance::Compare`'s and `interface_inst::Compare`'s own field
sequences through ONE `CompareContext`:

```
Nets 71/71  Array_nets 5/5  Variables null/null  Array_vars null/null
Named_events null/null  Parameters 90/90  Param_assigns 90/90
Typespecs 128/128  Interface_tf_decls … Interface_arrays  all null/null
Process                golden=1     ours=null   <-- DISAGREES
FIRST-DISAGREEING-FIELD Process
```

**THE FAILING FIELD IS `Process`, golden 1, ours 0** — r10uvm225's R0 exactly,
re-measured here on a binary this pass built. The cell is
`work@svaunit_vpi_interface`'s one `initial` block
(`svaunit_vpi_interface.sv:95-107`, a `$sformatf` header chain, a
`` `uvm_info `` macro and an if/else over `uvm_top.get_report_verbosity_level()`
calling the DPI import `register_assertions_dpi`). The interface is
**UNINSTANTIATED** — `-parse`, no top.

**THE FULL FIELDS OF THE CELL, BOTH SIDES × BOTH VIEWS.** Golden's def-view
process is an `initial` whose `vpiStmt` is an UNNAMED `begin` carrying the def
prefix as its `vpiFullName`, parented at the def `interface_inst`, and **not one
reference in it carries a `vpiActual`**. There is no ELAB view: nothing
elaborates the interface. Ours has no process object at all, in either view.
The INSTANTIATED twin is already exact on both binaries — grid arm
`a2_instantiated`, 15 cells, `MISSING 0 EXTRA 0 DIFF 0`, def view and elab view
alike, where the elab view's six entries are the SAME six objects the def view
lists (uhdm-dump prints them as stubs because Surelog folds one object into both
views).

### (2) THE PRODUCER, DECODED FROM SURELOG SOURCE

`UhdmWriter::writeInterface` — the ONLY writer for an interface DEFINITION —
copies the component's process vector verbatim and asks nothing else
(`src/DesignCompile/UhdmWriter.cpp:1737-1742`):

```cpp
  // Processes
  if (mod->getProcesses()) {
    m->Process(mod->getProcesses());
    for (auto ps : *m->Process()) ps->VpiParent(m);
  }
```

the same three lines `writeModule` runs at `:1481-1487` and `writeProgram` at
`:1863-1869`. The vector is filled by
`CompileModule::collectInterfaceObjects_` (`CompileModule.cpp:1026-1527`) at
three arms — `paAlways_construct` `:1160-1170`, `paInitial_construct`
`:1358-1368`, `paFinal_construct` `:1371-1381` — each compiling the block and
pushing it onto `m_module->getProcesses()`. **Those arms run in the DEFINITION
compile, before any elaboration, so INSTANTIATION IS NOT A GATE.** The
elaborated writer then hands the SAME vector to the same field
(`NetlistElaboration.cpp:661` `netlist->process_stmts(component->getProcesses())`,
read back at `UhdmWriter.cpp:4262`), which is why an instantiated interface's
def view and every elab view point at ONE object.

**WHAT THE BODY HOLDS.** `writeInterface` contains **NO `lateBinding` call at
all** (r10uvm218's decode of `:1626-1794`, still true at this commit), so an
interface nothing elaborates never gets the pass that fills a reference's
`vpiActual`; and a PROCESS body has no subroutine scope, so the compile-time
road `CompileHelper::bindVariable` (`CompileStmt.cpp:3089`,
`if (scope == nullptr) return nullptr;`) is the only binder left. What survives
is measured, not inferred — see the a15 table in (3).

### (3) THE GOLDEN GRID

16 arms, `grid226/`, every arm compiled with the canonical golden-side Surelog
(the one `scripts/verify_golden.py` names) and with each pinned binary,
**every rc recorded on both sides, all zero**, `LISTED 16 PROCESSED 16` on both.

**THE KIND GRID** (`a1_ifkinds`, empty parens, uninstantiated; golden lists SIX
where we listed NONE):

| written | golden object | `vpiAlwaysType` |
|---|---|---|
| `initial` | `initial` | — |
| `always @(clk)` | `always` | **1** |
| `always_comb` | `always` | **2** |
| `always_ff @(posedge clk)` | `always` | **3** |
| `always_latch` | `always` | **4** |
| `final` | `final_stmt` | — |

each with `vpiParent` = the def `interface_inst` and a `vpiStmt` subtree whose
unnamed `begin` carries `vpiFullName = work@<iface>`.

**THE HOLDER FENCE, AND ITS FIRST FACE.** `a3_holders` puts the identical six
blocks under an uninstantiated MODULE, an instantiated module, a PROGRAM and a
CHECKER: **15 cells, and only ONE is wrong on either binary** (the program cell
of R3, wrong on both). The module road's def-view process emission — the fence's
first face — is byte-for-byte what it was.

**THE GENERATE-REGION COUNT, AND IT IS THE OPPOSITE OF THE MODULE ROAD'S.**
`a14_genregcount` writes ONE own process plus a `generate ... endgenerate`
region holding TWO, under an interface and under a module, at zero / one / two
instances. Read off real goldens:

```
                 0 inst   1 inst   2 inst
   interface        3        3        3
   module           1        1        1
```

A module's region processes reach **no vector at all**; an interface's reach the
DEFINITION's exactly once, however many instances exist. The module road's
`regionPbs x defAllInstCount` model (`ModuleEmit.cpp:2338-2347`) produces
neither column — it reads **3 / 3 / 5** against golden's **1 / 1 / 1** on this
arm, on the PRISTINE binary and the patched one alike. That is **R1**, not this
law; this law's loop carries **no region test at all**, which is what the
interface column asks for. The first cut DID transcribe the module rule and
`a10_genregion` convicted it (`work@if226_gru#DEF[1]` MISSING).

**THE BINDING WINDOW OF A PROCESS BODY** (`a15_window`, 28 labelled cells in one
uninstantiated interface, one reference each; U = local of the process's own
unnamed outer block, D = local of an unnamed block one control level deeper,
B = NAMED-block local, M/N/L/P = the interface's own variable / net /
localparam / parameter):

```
BIND   w03 IF condition (U)          w04 CASE condition (U)
       w05 CASE ITEM expression (U)  w11 IMMEDIATE-ASSERT condition (U)
       w09 user TASK call arg, STATEMENT position (U)
       w20 IF condition (D), declaration at the same depth
       w28 the same IF-condition cell inside an `always_comb`
BARE   w01/w02 assignment LHS and RHS      w06 WHILE condition
       w07 FOR condition                   w08 user FUNCTION arg, EXPRESSION position
       w10 SYSTEM call argument            w12 CAST operand
       w13-w18 M, N, L and P in every one of those positions
       w22/w23 a local read one control level BELOW its declaration
       w24-w27 a NAMED-block local in EVERY position, conditions included
```

That is § refVarLocalWindowBinds5's window and § classInBodyBareCallArgStmtOnly53's
statement-position restriction, cell for cell, **with the subroutine dropped** —
so `uninstIfaceWindowBind218`'s opening `!currentSubSym` is the one term that
widens, and nothing else moves. The a7 cell that first showed it
(`if226_b#DEF[1]`, a case condition over an unnamed-block local) is the reason
this arm exists.

**THE TWO LAWS THAT ALREADY RIDE THE HOLDER FLAG ANSWER HERE TOO**
(`a13_enumassert`, uninstantiated column): an ENUM CONSTANT reference is BARE in
an assignment RHS, an if condition and a case ITEM alike
(§ uninstIfaceEnumConstNoActual221), and a `foreach` header keeps Surelog's
`ref_var` over an `unsupported_typespec` NAMED AS WRITTEN, array reference and
loop variable both (§ uninstIfaceForeachHdrUnresolved220). Their producer
arguments are about the HOLDER — `writeInterface` runs no `lateBinding` and no
`lateTypedefBinding` — so they were never subroutine facts, and this arm is what
says so rather than the argument.

**THE REST OF THE GRID**

```
a4_genscope    a conditional generate and a for-genvar INSIDE an interface —
               golden lists the interface's OWN process and NOT the gen scope's,
               uninstantiated and instantiated alike.
a5_modport     a modport interface, ported and unported; golden lists the
               processes and NO MODPORT OBJECT MOVES (the InterfaceModPort shape).
a6_headerforms empty parens / no parens / ANSI ports / genuine non-ANSI —
               7 golden cells, the SAME answer in all four.  This law is NOT
               gated on the header form (r10uvm224's typespec law is).
a7_body        every referent kind a process can name — member variable, member
               net, localparam, parameter, wildcard-imported package variable,
               package-scoped localparam (FOLDED to a constant), own function
               call, own task call, named-block automatic local, unnamed-block
               local, foreach header, system call — uninstantiated beside an
               instantiated twin.
a8_order       five processes interleaved with a net, a function, a cont_assign
               and a modport: golden's vector is WRITTEN-DECLARATION order.
a9_multiinst   an interface instantiated three times (two siblings and one
               nested): golden's def view lists ONE process per written block.
a11_nested     the MiniAmiq shape reduced — a `$sformatf` chain over a named
               block's automatic string, a DPI-import call, an if/else over a
               package class handle's method.
a12_pkgimport  the MUST-STAY floor: §223, §224, §225, §221, §220, §222 and §218
               in one file, beside a process.
a16_forvar     the identical `for (int k = 0; k < n; k++)` in a FUNCTION, a TASK,
               an `initial` and an `always_comb` of one uninstantiated
               interface — R-A's arm.
```

### (4) SLANG, DECODED

`emitInterfaceDef` (`src/ModuleEmit.cpp:29271`) emitted **no processes at all**.
Its own comment said "Processes are emitted once in the ELAB view and shared
here", and that is true — `emitInterfaceInstance` (`:31527`) compiles the bodies
in the elaborated instance's context and calls `instSetProcess` on BOTH the elab
`interface_inst` and the def one through `ifaceDefMap`. An interface **no
instance elaborates never reaches that site**, so its def view got nothing.

The patch is three files:

* **`src/ModuleEmit.cpp`** — an `!ifaceInstantiated225` loop in
  `emitInterfaceDef`, placed exactly where Surelog's collect order puts it
  (after the def's task_funcs, nets and cont_assigns), walking `body.members()`
  in order and calling the shared `emitProcess`. It raises
  `suppressRefActual` — the same blanket the subroutine road above it raises —
  and `uninstIfaceSubBody218` beside it, so § 220 and § 221 answer.
* **`include/UhdmExporter.h`** — `uninstIfaceProcBody226`, raised only inside
  that loop, never alone.
* **`src/ExprEmit.cpp`** — ONE widened term in `uninstIfaceWindowBind218`
  (`!currentSubSym` becomes `!(currentSubSym || uninstIfaceProcBody226)`), plus
  R-A below.

**THE CONCURRENT-ASSERTION FENCE.** A `assert property (...)` written as an
interface ITEM is not a process: `writeInterface` lists it under `Assertions()`
from `mod->getAssertions()` (`:1729-1735`), a vector this def view does not fill
at all. The loop SKIPS such a block from its SYNTAX (`ConcurrentAssertionMember`,
the same test `emitAssertion` opens with) rather than calling `emitAssertion` and
discarding the result — **a `Make…` call is a WRITE, and never mint on a path
that can still decline** (r10uvm225's orphan lesson). The gap it leaves is R2.

**R-A — THE `for`-HEADER ITERATOR OVER-BIND, ON BOTH ROADS.**
`ExprEmit.cpp`'s `activeForVars` clause is the one binder inside the whole
`suppressRefActual` arm that answers without asking the window, so it fired for
a `for` header's own iterator where golden leaves every reference to it bare —
the FOR condition is not a binding window (a15 w07), and neither is the
increment nor the body. MEASURED on `a16_forvar`: golden leaves the iterator
bare in the condition, the increment and the body of a FUNCTION, a TASK, an
`initial` and an `always_comb` of one uninstantiated interface, and the
**PRISTINE** binary binds all three references in the two SUBROUTINE columns —
§ uninstIfaceBodyBindsInMethodWindow218's road, shipped since r10uvm218. So the
term added is the HOLDER flag `!uninstIfaceSubBody218`, which repairs the
subroutine column with the process one; it is a REPAIR of a pre-existing
over-bind on a road this pass newly reaches, not a fence around the new road.
Inert everywhere else. `a16_forvar` goes CELL 3 TO-GOLDEN / AWAY 0.

### (5) THE CENSUS, AND THE PROVEN u2r ZERO

**THE A-PRIORI PREDICTION, made before the patched sweep was scored.**
`R10E226_DBG=1` makes the emitter name on STDERR every cell this law touches —
each process it MINTS (holder and kind) and each R-A binding it declines
(`proc=1` in a process body, `proc=0` in a subroutine) — and it writes NOTHING
to the database, proved by hand: the same source compiled in the SAME directory
with and without the variable gives byte-identical `.uhdm` files
(`6a19e2cd4d2c`). `predict226.sh` replays the EXACT command line the harness
recorded in every row's `cmds.txt`, into scratch of its own:

```
uhdm2rtlil  testflags  LISTED 731   PROCESSED 731   HIT_ROWS 0
            default    LISTED 731   PROCESSED 731   HIT_ROWS 0
                       (1462 row-modes, 4 NOCMD = the two SURELOG_FAIL tests x 2 modes)
surelog                LISTED 1573  PROCESSED 1573  HIT_ROWS 2
              default/MiniAmiq   1 line   MINT226 iface=work@svaunit_vpi_interface kind=Initial
              testflags/MiniAmiq 1 line   MINT226 iface=work@svaunit_vpi_interface kind=Initial
              ZERO RAFOR226 lines in EITHER corpus
```

so **the u2r zero is a POSITIVE statement** — the law is traced as touching no
cell in that corpus at all — and the surelog mover set is named down to the
cell. The `RAFOR226` trace is a working POSITIVE CONTROL: it prints 12 lines on
`a16_forvar` (6 `proc=0`, 6 `proc=1`) and zero on the corpus, because
`svaunit_vpi_interface.sv` contains no `for (` at all. R-A's corpus blast radius
is measured as nothing, not asserted to be.

**THE CANARY MEASURED FIRST.** Per the ops rule, `InterfaceModPort`'s
interfaces' process population was read BEFORE anything else: its four
interface_insts (`sif`, `mif`, `tif`, `miff`) carry **NO processes at all** and
every one of them is INSTANTIATED, so this law cannot reach the database. It is
byte-identical after the patch.

### (6) THE LAW GATED

**THE GOLDEN GRID, THREE-WAY** (`armdelta226.sh` + `tri226.py`, pristine vs
patched vs golden, on TWO axes — the CELL axis keyed positionally the way
`interface_inst::Compare` reads the vector, and the FIELD axis over every line
of the flattened subtree, because a whole-cell compare is blind to one
judge-visible field going right → wrong inside a cell that is wrong on both
binaries):

```
CELL   TO-GOLDEN 52    AWAY 0    STILL-WRONG 43    SAME-RIGHT 111
FIELD  TO-GOLDEN 1069  AWAY 0    STILL-WRONG 594   SAME-RIGHT 904
```

and positionally golden-vs-ours over the 16 arms, `MISSING 34 / EXTRA 20 /
DIFF 23 / SAME 109` becomes `MISSING 0 / EXTRA 20 / DIFF 23 / SAME 147`:
**every missing cell is gone and neither the EXTRA count nor the DIFF count
rose.** All 43 STILL-WRONG cells are pre-existing and named in §4's residue
list — 24 in `a14` (R1's 18 module region copies + 6 of R4), 6 in `a10` and 6 in
`a9` (R4), 3 in `a13`, 2 in `a15`, 1 in `a7` and 1 in `a3` (R3).

---

## 2. FILES

* `grid226/` (16 arms), `grid226.sh` — the golden grid and its driver.
* `proccen226.py` — the PROCESS census (positional, whole-subtree, `vpiActual`
  descended one level as `ACT=`, `vpiParent` never descended).
* `gscore226.sh` — golden-vs-ours per arm; `armdelta226.sh` + `tri226.py` — the
  THREE-WAY score on the CELL and FIELD axes.
* `ct226field.cpp` — the head-field probe (r10uvm225's, verbatim).
* `predict226.sh` — the a-priori mover prediction (`R10E226_DBG=1`).
* `bound226.sh` + `bscore226.sh` — the wide boundary and its two-axis re-score.
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the gate copies run here.
* `GATES.r10uvm226.txt`, `GRID.r10uvm226.txt`, `ARMDELTA.r10uvm226.txt`,
  `PREDICT.*.r10uvm226.txt`, `BOUNDARY.r10uvm226.txt`,
  `BOUNDARY.score.r10uvm226.txt`, `HEADFIELD.r10uvm226.txt`.

---

## 3. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD: A `class_var` INSIDE THE FUNCTION THE PROCESS
  CALLS.** The head OBJECT changed. `ct226field` reads
  `Process golden=1 ours=1 <-- DISAGREES` — same size, so the failure is inside
  the element — and `ct226inner` (this pass's own probe, which runs the SHIPPED
  `BaseClass::Compare` on the element pair in a fresh `CompareContext` and
  prints the context's `m_failedLhs` / `m_failedRhs`) names it:

  ```
  ELEMENT[0] golden_type=2178 ours_type=2178 r=1 <-- DISAGREES
    failedLhs(golden) type=2060 (class_var) name=cs
                      file=uvm-1.2/src/base/uvm_globals.svh line=136:21..136:23
    failedRhs(ours)   <null>
  ```

  `uvm_coreservice_t cs;` is a LOCAL of the free function
  `uvm_pkg::uvm_report_enabled` (`uvm_globals.svh:133-140`), which the interface's
  `initial` reaches through the `` `uvm_info `` macro's `func_call`'s
  `vpiFunction`. Golden BINDS a reference to it; we leave that reference bare —
  the SINGULAR `SafeCompare` signature (lhs set, rhs null, RESUME §9). So the
  next rung is a PACKAGE FREE FUNCTION's body binding, not an interface law at
  all; the process is now the road that reaches it. **The cmp log now prints
  BOTH sides (713053 -> 1392014 lines, one head, both modes): the count is the
  new head's decompile size, not a distance, and the successor must run
  `ct226field` + `ct226inner` rather than the line count.**
* **R1 — THE MODULE ROAD'S GENERATE-REGION PROCESS RULE IS WRONG, AND `a14`
  MEASURES IT.** `ModuleEmit.cpp:2338-2347` repeats a `generate ... endgenerate`
  region's processes once per instance (`regionPbs x defAllInstCount`). Golden
  gives a MODULE **1 / 1 / 1** at zero / one / two instances — the region's
  processes reach no vector at all — where we give **3 / 3 / 5**, on the
  pristine binary and this one alike (18 EXTRA cells in `a14_genregcount`, def
  view and elab view together). Deliberately NOT taken here: it is the module
  road's law, it needs its own grid and its own a-priori census, and every one
  of its cells is wrong on the pristine build too.
* **R2 — THE ELABORATED INTERFACE ROAD LISTS A CONCURRENT ASSERTION AS A
  PROCESS.** `a13_enumassert`'s instantiated twin: golden's
  `work@if226_eai` lists TWO processes (the `initial` and the `always_comb`) and
  puts `assert property (@(posedge clk) ...)` under `Assertions()`;
  `emitInterfaceInstance` pushes it into `Process()` instead, so our vector is
  three long and position [1] is an `assert_stmt` where golden has the
  `always_comb`. Wrong on the pristine binary too. This pass's DEF-view loop
  fences it correctly (the uninstantiated `work@if226_ea` is exact, 2 cells) —
  and the fence is a SKIP, not a discarded `emitAssertion`, so nothing is
  minted. The other half of R2 is that an interface DEFINITION fills no
  `Assertions()` vector at all, where `writeInterface:1729-1735` does.
* **R3 — AN UNINSTANTIATED PROGRAM'S DEF-VIEW PROCESS BINDS WHAT GOLDEN LEAVES
  BARE.** `a3_holders`' `work@prg226_h`: golden's `initial` leaves its
  `a226` reference with no `vpiActual`, we bind the `logic_net`. Wrong on the
  pristine binary; already named in the code at `ModuleEmit.cpp:2283-2289`
  ("needs the same treatment `classMethodNoBind` gives class methods, scoped to
  `uninstProgDefs` processes"). It is the PROGRAM twin of the law this pass
  decodes for the interface, and it is one flag away — but it is a different
  holder with a different producer arm (`writeProgram:1863`), so it gets its own
  grid, not a transcription of this one.
* **R4 — THE DEF VIEW AND EVERY ELAB VIEW OF A MULTIPLY-INSTANTIATED INTERFACE
  MUST SHARE ONE PROCESS OBJECT, BOUND TO THE FIRST INSTANCE.** Surelog's def
  writer and its elaborated writer hand the SAME vector to the same field
  (`UhdmWriter.cpp:1739` and `:4262` over
  `NetlistElaboration.cpp:661`), so golden's `work@if226_m` def process and both
  `u_a226` / `u_b226` elab listings are ONE object whose references bind
  `u_a226`'s variables — the FIRST instance. We compile a fresh copy per
  instance and `instSetProcess` the LAST one into the def, so the def binds
  `u_b226` and the first instance's elab view holds objects the def no longer
  names. 12 STILL-WRONG cells across `a9_multiinst` and `a10_genregion`, wrong
  on the pristine binary too. UNTOUCHED here and measured so: this law fires
  only when the instance count is ZERO.
* **R5 — IN THE `--elabuhdm` VIEW, UHDM'S OWN `ElaboratorListener` RE-BINDS THE
  LOOP-VARIABLE REFERENCES R-A DECLINES.** Measured on `a16_forvar`, one source,
  four columns:

  ```
                        subroutine k226 bound   process k226 bound   (golden: 0, 0)
    pristine  -parse            3                    -  (no process)
    patched   -parse            0  <- R-A            0
    pristine  --elabuhdm        3                    -  (no process)
    patched   --elabuhdm        3  <- put back       6  <- put back
  ```

  The emitter code is identical in the two modes, so the binder is UHDM's
  `ElaboratorContext`, which `uhdm_main.cpp` runs over the database only when
  `--elabuhdm` is given. It is what the wide boundary's **38 FIELD AWAY lines**
  are, and all 38 are in cells that do not exist on the pristine binary at all
  (`away_split`: `in a cell ABSENT from the pristine listing = 38`, `a genuine
  field regression = 0`), with **CELL AWAY 0 on every one of the 35 re-scored
  arms**. No corpus row reaches it: the a-priori prediction hits 2 row-modes and
  neither is an `--elabuhdm` row, and byteverify reads 2/956 and 0/1358.
  Closing it means teaching the listener, not the emitter.
* **R6 — THE INSTANTIATED INTERFACE'S PROCESS BODY STILL HAS TWO KNOWN GAPS**
  (both wrong on the pristine binary, both untouched here): a wildcard-imported
  package variable's reference is bound in golden and bare for us
  (`a7_body` `work@if226_bi`), and we stamp a `vpiTypespec` `ref_typespec` on
  block-local references where golden stamps none (`a7_body`, `a15_window`
  `work@if226_wi`, 3 cells).

---

## 4. THE GATES, IN ONE PLACE

All green; the numbers are in `GATES.r10uvm226.txt`. In one line: goldens
**23 PASS / 0 FAIL on BOTH binaries** and `/bin/false` **0 PASS / 23 FAIL**;
uhdm2rtlil **679 / 50 / 2 in BOTH modes** with `ct8rows` at **zero differing
rows** against the committed baseline, this pass's own pristine control and the
rotated control alike, and byteverify **MOVERS 0/679 per mode (0/1358)** against
both; surelog **476/5 + 470/5** with **ZERO differing STATUS rows over 1588**
against all three, and byteverify **2/956** — the two MiniAmiq row-modes, both
predicted by name; the nine converted row-modes and Rggen/default at judge rc
**zero** on both columns (`rowheads.sh`, both columns quoted); canaries 50+2/8
(the 2 are the Earlgrey dump-column cells below), ctcan2 both PASS, canaudit
**audited=29 UNCOVERED=0 FENCE-BREACH=0**; the five protected databases
byte-identical with InterfaceModPort on `59a365f3ce2c`, SVSwitch on
`4842211c4030` and YosysVerx on `6ccda350c24a`.

**THE TWO ROWS THAT ARE NOT BYTE-IDENTICAL IN THE CSV, READ OUT IN FULL.** The
whole-row `ct8rows` diff against the committed baseline is exactly:

```
< Earlgrey_0_1,default,CMP_EQUAL,,,differ
< Earlgrey_0_1,testflags,CMP_EQUAL,,,differ
> Earlgrey_0_1,default,CMP_EQUAL,,,
> Earlgrey_0_1,testflags,CMP_EQUAL,,,
```

**the DUMP COLUMN only, and the STATUS histograms are cell-for-cell identical.**
`verify_golden.py`'s `dump_verdict` returns `''` on a `uhdm-dump` TIMEOUT
(`scripts/verify_golden.py:521-537`) — the recorded Earlgrey artifact the ops
rules name — and the databases themselves are proved **byte-identical between
this pass's pristine and patched sweeps** (`8c2ba25c4d7f` default,
`92bf7b7facdc` testflags, `cmp` clean), which is the check the rule asks for
instead. Earlgrey's judge rc is **0** in both modes on the patched sweep.

**THE THIRD BYTE MOVER AGAINST THE ROTATED CONTROL IS THE COIN.** Against
`/tmp/ctl_wd_sl_d51916f9` byteverify reads 3/956, the third being
`default/Scoreboard`. Order-blind (path-normalised, sorted dumps) the rotated
control and the patched database differ by **0 lines**, and this pass's OWN
pristine binary produced the SAME hash as the patched one (`61ee9cb4f6c1` both,
control `89c1b4e51d8e`) — so the flip belongs to the control's run, not to the
patch, and against this pass's own pristine control Scoreboard is not a mover at
all.

**THE WIDE BOUNDARY** — the only gate that convicts a corpus-invisible
regression:

```
LISTED 5645   PROCESSED 5645   MOVED_ARMS 65 (34 sources x 2 views)   RC_DIFFS 0
re-scored against a FRESH Surelog per moved source (35 arm-views, 3 error-recovery):
   CELL   TO-GOLDEN 148   AWAY 0    STILL-WRONG 133   SAME-RIGHT 239
   FIELD  TO-GOLDEN 2106  AWAY 38   STILL-WRONG 2073  SAME-RIGHT 2488
   of the 38 FIELD AWAY lines:  in a cell ABSENT from the pristine listing = 38
                                a genuine field regression                = 0
```

21 of the 34 moved sources are EARLIER-PASS arms, and they are exactly the
must-stay families this law touches by construction —
`§ uninstIfaceBodyBindsInMethodWindow218`'s `a2_window`,
`§ uninstIfaceForeachHdrUnresolved220`'s `a1_uninst_if`,
`§ uninstIfaceEnumConstNoActual221`'s `a1_ctx` / `a5_r5mix` and its verifier's
`v2_uninst` / `v4_r5iter` / `v6_nonsubbody`,
`§ wildcardImportCopiesPkgVarsToDefNets223`'s `a1_iface_wild` / `a13_ifaceproc`
and its verifier's `v15_uses_noimport` / `v20_refsites` — every one an
UNINSTANTIATED interface that writes a process, and every one CELL AWAY 0. The
38 FIELD AWAY lines are R5 (UHDM's own `ElaboratorListener`, `--elabuhdm` only,
in cells that did not exist before). No family moved on any axis but this law's,
and `§ ifaceDefNetTypespecIsTheModuleRule224`, `§ ifaceDefArrayNetIsAnyUnpacked-
Dim225`, `§ ifaceOwnCallCalleeFormRoutes222` and
`§ dpiExportListedAtExportItem216` did not move at all.

**NO CONVERSION IS CLAIMED and `results/*.csv` were NOT edited.** MiniAmiq stays
`CMP_NOTEQUAL` in both modes: the `Process` field now agrees in SIZE and the
head moved INSIDE it, to R0's `class_var cs`. The interface object does NOT
agree after this rung, so the row cannot be promoted — that was predicted BOTH
ways before the run (if the one process had compared EQUAL under the shipped
`Compare`, `ct226field` would have read `Ports` or later and the row would have
been a conversion candidate; it reads `Process ... DISAGREES` with equal sizes,
which is why `ct226inner` exists).

**THE ORPHAN CHECK (r10uvm225's sharpest ops lesson, re-run here).** The loop
mints its `VectorOfprocess_stmt` before it knows the interface writes any
process, and `s.Make…` hands out something the serializer can WRITE — the exact
shape of r10uvm225's invisible 130-row byte mover. It is answered by
MEASUREMENT, not by argument: an uninstantiated interface that writes NO process
is common in both corpora and all over the probe tree, and if the empty vector
were written every such def would have moved bytes. It reads **MOVERS 0/1358 on
uhdm2rtlil** (a corpus the a-priori trace trips on exactly zero rows), **2/956
on surelog** (the two predicted MiniAmiq rows and nothing else) and, on the wide
boundary, only the 34 sources that actually write one. The same
mint-then-populate shape is what the module road at `ModuleEmit.cpp:2252` has
always used.

**AND THE EARLGREY DUMP COLUMN IS PROVED, NOT ARGUED.** `dump_verdict`'s own
logic — `uhdm-dump` both databases, drop the banner line, compare — re-run by
hand on the PATCHED sweep's pair with a 3000 s timeout reads **`differ` in both
modes, uhdm-dump rc 0 on all four files**, which is EXACTLY the committed
baseline's value for both rows. The blank is the harness's timeout and nothing
else.
