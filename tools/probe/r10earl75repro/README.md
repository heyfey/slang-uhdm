# r10earl75 — § genScopeProcOpFoldTs75: a generate block is a SCOPE, not a compilation mode

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `94e673b`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The Earlgrey_0_1 head r10earl74 named as R0 — 17 cmp lines, one head,
byte-identical in both modes — is CLEARED in both modes,** and every other named
row's head is unchanged.

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_default.cmp` / `HEAD_BEFORE_testflags.cmp` are the verbatim
pristine logs. They reproduce r10earl74's committed `HEAD_AFTER_*.cmp` **byte
for byte**, and the binary that produced them rebuilds to the main tree's own
md5 at `94e673b`, so this pass starts on exactly the object earl74 named.

```
LHS (golden)                                  RHS (ours)
ref_typespec (work@top_earlgrey.u_flash_eflash <null>
              .gen_flash_banks[0].i_core)
|vpiParent -> constant 190:27-190:36
|vpiActual -> int_typespec  17:13-17:16
```

**Which arm.** Read the generated `Compare` order before naming the field:

```c++
// UHDM/build/generated/src/expr.cpp:83
int32_t expr::Compare(...) {
  basetype_t::Compare(...)                            // VpiType/VpiName/VpiDefName
  lhs->VpiDecompile().compare(rhs->VpiDecompile())    // "64" == "64"
  lhs->VpiSize() - rhs->VpiSize()                     // 32 == 32
  SafeCompare(lhs->Typespec(), rhs->Typespec(), ...)  // <-- THE HEAD
}
// BaseClass.h:187-199, singular overload, lhs != nullptr && rhs == nullptr:
//   sets m_failedLhs to golden's ref_typespec, leaves m_failedRhs unset
//   -> the `RHS: <null>` spelling.
// UHDM/build/generated/src/ref_typespec.cpp
int32_t ref_typespec::Compare(...) {
  basetype_t::Compare(...)   // VpiType / VpiName / VpiDefName
  lhs->VpiName()... lhs->VpiDefName()...
  SafeCompare(lhs->Actual_typespec(), rhs->Actual_typespec(), ...)
}
```

`ref_typespec::Compare` reads **VpiName, VpiDefName and Actual_typespec — never
VpiFullName**. The `(work@…i_core)` the dump prints in parentheses is the
FULLNAME; golden's `VpiName` is EMPTY and so is ours. The fullname is matched
anyway, for exactness, not because the judge reads it — `HEAD_OBJECT.txt`
(`rtfn75.cpp`) prints all four fields of the corpus object out of both databases
and they agree character for character, `gen_flash_banks[0]` and `[1]` alike.

**Which object.** `flash_phy_core.sv:190`

```systemverilog
  end else begin : gen_prog_data
    logic [WidthMultiple-1:0][BusWidth-1:0] prog_data_packed;
    always_comb begin
      prog_data_packed = {DataWidth{1'b1}};
                          ^^^^^^^^^  190:27-190:36
```

in `top_earlgrey.u_flash_eflash.gen_flash_banks[0|1].i_core`. `DataWidth` is
`flash_phy_pkg.sv:17  parameter int DataWidth = flash_ctrl_pkg::DataWidth;`,
read through `module flash_phy_core import flash_phy_pkg::*;`, and `17:13-17:16`
is that parameter's own `int` keyword. Golden's `ref_typespec` is named after
the **OWNING INSTANCE** — `…gen_flash_banks[0].i_core`, **not** the gen scope
`…i_core.gen_prog_data`, and not the package.

**Golden RE-PARENTS the folded constant at the package parameter's
`param_assign`** (`par=param_assign` in `CENSUS.txt`) while we leave it under its
operation. No generated `Compare` reads `VpiParent`, so the judge cannot see
that — but a census keyed on the constant's own parent would manufacture a
phantom AWAY cell for every such object. `cscen75` keys on the SITE's chain
instead. (`UhdmListener::getCallstack()` is not a key either: it is the
FIRST-VISIT route, which wanders the whole typespec graph before it reaches the
instance tree and differs between the two databases for reasons that have
nothing to do with position. Both traps were hit and both are recorded in the
instrument's header.)

---

## 2. Question 1 — WHICH folded constants carry a `ref_typespec` in golden

`cscen75` visits **every constant** reachable from a `cont_assign`, a
`param_assign`, a port `High_conn`, an `always`, an `initial`, a `final`, a
`function` or a `task` — including **process bodies**, which
`r10earl72repro/tscen72.cpp` (three hand-picked containers) was structurally
blind to, and which is exactly where this head lives. Payload = the
JUDGE-VISIBLE fields only; the span is a KEY field and is never scored
(earl60's lesson: a span-carrying payload hides a flip).

Calibrated **golden-vs-golden first**: 66,312 deduped cells, all STILL-RIGHT.

Joined golden-vs-ours over the whole Earlgrey database, both modes, the answer
is one sentence:

> **EVERY cell of the Earlgrey databases where golden has a `ref_typespec` and
> we have none is inside a GENERATE SCOPE — and there is not one cell anywhere
> where we have a `ref_typespec` and golden has none.**

| owner | gd | route | default | testflags | family |
|---|---:|---|---:|---:|---|
| `cont_assign` | 1 | `RHS[/opN]*/hp[i]/w` | 261 | 348 | earl72's R1 |
| `port_highconn` | 1 | `HC/w` | 24 | 48 | earl65's mirror |
| `always` | 2 | `ST/s[i]/R/op34[0]` | **4** | **8** | **THIS HEAD** |
| TS-EXTRA-OURS (we stamp, golden does not) | — | — | **0** | **0** | — |

(undeduped cell counts; the three families are 87 + 6 + 2 distinct objects.)

The three are **not one law**, and the census says so by reading what golden
stamps rather than only whether it stamps:

* **this head** — origin a WILDCARD-IMPORTED PACKAGE parameter
  (`parameter int DataWidth`), typespec **LOCATED** at the package declaration
  (`flash_phy_pkg.sv:17:13-17:16`), **SIGNED**;
* **earl72's R1** — origin a MODULE LOCALPARAM
  (`tlul_socket_m1.sv:73 localparam int unsigned STIDW = $clog2(M);`), typespec
  LOCATED at `73:14-73:26` (the `int unsigned`), **UNSIGNED**;
* **the port one** — origin a MODULE LOCALPARAM
  (`rv_timer.sv:20 localparam int N_TIMERS = 1;`), typespec **BARE** —
  span-less, nameless — which is earl65's separately-named MIRROR family.

Only the first is reachable through the `importedParamDefTs` gate this arm
carries. The other two are ranked below as R1 and R2 with their producers named.

---

## 3. Question 2 — the decode

`inProcessEmit` is set by `emitModuleDef`'s process loop **only**
(`src/ModuleEmit.cpp:1509/1603`). The ELABORATED generate scope runs its own
process loop (`src/ModuleEmit.cpp:16200-16246`, `inGenScopeProc = true` around
`emitProcess`) and never sets it. `§ procOpFold9` — the arm that stamps every
operand fold of an unqualified imported package parameter inside a process — is
gated on `inProcessEmit`, so **every fold inside an `always` written in a
generate block came out bare while the byte-identical statement in the module
body was stamped.** That is the whole defect; it is a missing context flag, not
a missing rule.

Surelog does not distinguish the two homes at all. The stamp is minted in
`CompileHelper::getValue`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp`), whose instance
arm builds the constant from the parameter's elaborated `Value` and hands it the
parameter's own declaration typespec; the gen-scope arm of `UhdmWriter` and its
module-body arm pass the SAME `compileExpression` the SAME instance. The
generate block is a scope, not a compilation mode — which is why the corpus head
is stamped in golden and why the `ref_typespec` names the INSTANCE
(`…i_core`) and not the gen block.

**The gen-scope `cont_assign` site is a different question and this pass does
not answer it.** `§ ipsWidFold9` already fires there regardless of context; what
those 87 objects miss is not a context flag but a typespec SOURCE — a module
localparam's own `int unsigned` declaration, which `importedParamDefTs` does not
hold. R1 below.

**The always_comb-in-gen-scope replication count is the SAME site as the
module-body one**, one emitter flag apart. It is not a third producer.

---

## 4. The law

**§ genScopeProcOpFoldTs75 — a fold of an unqualified wildcard-imported package
parameter that an OPERATION inside a GENERATE SCOPE'S `always` block reduces
carries the parameter's own declaration typespec, exactly as the byte-identical
statement written in the module body already does. The `ref_typespec` is named
after the OWNING INSTANCE, not the generate block. It adds a `ref_typespec`
EDGE and nothing else — not the size, not the value, not the vpiConstType, not
the sign.**

```c++
bool gsProcOpFold75 = inGenScopeProc && !inProcessEmit && !inParamInit &&
                      gsProcAlways75 && procForAllDepth9 == 0 &&
                      parent && parent->UhdmType() == UHDM::uhdmoperation;
```

joined to the existing stamping condition — and **deliberately NOT** to the
`VpiSize` arm beside it (`§ defParamInitImportOpFold`'s untyped-materialized-
import width rule was measured on a MODULE-BODY process witness only).

### The two fences, both convicted on the grid before they were written

Both are already-measured campaign law, and neither can suppress a stamp golden
makes — **in both regions golden has no constant to stamp at all**:

* **(a) an `initial` / `final`** (`gsProcAlways75`, the procedure-kind test
  `§ genLpOneHopProcBoundOp58` carries as `alwaysProc58`). Surelog's
  `compileInitialBlock` passes NO instance, so there is no netlist to substitute
  from and golden keeps the `ref_obj` at every distance. `g1` row F
  (`initial f2 = {NB{req_i}} & alloc;`) has **no golden constant**; we over-fold
  it already, and stamping that over-fold would invent a typespec for an object
  golden does not have.
* **(b) a for-stmt, HEADER AND BODY** (`procForAllDepth9 == 0`). Golden keeps
  the `ref_obj` in all five positions (`§ genProcParamFold`; V-FIX v58 (a)
  re-measured it on the verifier's v5/v6 arms). `g1` row B_P11
  (`for (int k = 0; k < NB; k++)`) has no golden constant — **and neither does
  the corpus cell one line below the head**, `flash_phy_core.sv:191
  for (int i = 0; i < WidthMultiple; i++)`, where golden keeps a `ref_obj` bound
  to an `enum_const`.

Without fence (b) the corpus census reported 4 (default) / 8 (testflags) stamps
on constants golden does not have, and the grid reported 12. With both fences
the count is **0 in the corpus and 0 on the grid, in both views.**

---

## 5. Question 3 — measured on golden

`g1_gsproc75.sv`: **14 POSITIONS** in a process, **7 HOMES** and **8 ORIGINS**
(not a full cross product — the positions are swept in the two homes that
matter and the origins in a third), the module instantiated three times. `GOLDEN_TABLE.txt` is the per-row answer and
`GRID_SCORE.txt` the field-split score; `armscore75.sh` builds the arm with
Surelog and with both frozen binaries and scores both views.

Homes: module-body `always_comb` (the POSITIVE CONTROL — already right, must not
move), a gen-`if` block, a gen-`for` block (two iterations), a NESTED gen block,
a gen-scope `always_ff`, a gen-scope `initial`, a gen-scope `function`.

| position in a gen-scope `always_comb` | golden | pristine | patched |
|---|---|---|---|
| P1 replication COUNT, whole Rhs (**the head shape**) | int_ts | bare | **int_ts** |
| P2 replication count under `&` | int_ts | bare | **int_ts** |
| P3 concat MEMBER | int_ts | bare | **int_ts** |
| P4 arithmetic operand | int_ts | bare | **int_ts** |
| P5 ternary arm | int_ts | bare | **int_ts** |
| P12 `if` CONDITION operand | int_ts | bare | **int_ts** |
| P13 `case` ITEM operand | int_ts | bare | **int_ts** |
| P7 bit-select INDEX / P8 part-select BOUND / P9 ips WIDTH | int_ts | int_ts | int_ts (already right) |
| P6 whole Rhs, NO operation | int_ts | bare | bare (**R4**, wrong in BOTH homes) |
| P10 `$clog2` ARGUMENT | int_ts | bare | bare (**R4**, wrong in BOTH homes) |
| P11 for-loop CONDITION bound | **no constant** | over-fold | over-fold, unstamped (fence b) |
| P14 bare user-CALL argument | **no constant in a gen scope, in ANY database** — and the MODULE BODY folds and stamps it | — | — |

| home | golden | patched |
|---|---|---|
| module body (control) | int_ts | unchanged, still int_ts |
| gen-`if` | int_ts | **int_ts** |
| gen-`for`, both iterations, all three instances | int_ts | **int_ts** |
| gen-scope `always_ff` | int_ts | **int_ts** |
| gen-scope `initial` | **no constant** | unstamped (fence a) |
| gen-scope `function` | int_ts | unchanged (`§ tfOpFold9` already) |
| NESTED gen block | **no constant in ANY database** | nothing to stamp |

| origin, inside a gen-scope process | golden | patched |
|---|---|---|
| wildcard-imported `parameter int NB` | int_typespec **signed** | **matches** |
| the SAME parameter read QUALIFIED `g75p::NB` | **bare** | **bare** (negative control holds) |
| package `parameter bit [7:0] TB` | **bit_typespec** | **matches** |
| package IMPLICITLY typed `parameter UT = 5` | int_typespec **UNSIGNED** | **matches** (earl72's R2 respected) |
| module parameter `MP` / module localparam `ML` | int_ts | already right |
| gen-scope localparam `GL` / the genvar `(i+1)` | never folds | never folds |

**Score, `g1_gsproc75.sv`, BOTH views, IDENTICAL in both:**

| | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | no-golden-cell MOVED |
|---|---:|---:|---:|---:|
| `ref_typespec` fields | **54** | **0** | **0** | **0** |
| value fields (ct/size/value/decompile) | 0 | **0** | **0** | **0** |

13 source rows move, 0 move away, 0 move wrong, 60 stay right and 5 stay wrong
(all five pre-existing in the MODULE BODY too, so none of them is this law's).

---

## 6. Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 17 cmp lines, 1 head | **36 cmp lines, 1 head** |
| Earlgrey_0_1 / testflags | 17 cmp lines, 1 head | **36 cmp lines, 1 head** |

The two modes stay byte-identical (`HEAD_AFTER_*.cmp` differ in nothing at all).
The line count went UP because the head OBJECT changed — a cmp line count is the
head's decompile DEPTH, never a distance. The `ref_typespec`/`<null>` miss is
gone and the next head is a different family (R0 below), one line further down
the same `always_comb`.

**Earlgrey constant census** (`CENSUS.txt`, deduped, calibrated golden-vs-golden
first at 66,312 cells all STILL-RIGHT):

| mode | cells | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | no-golden-cell MOVED |
|---|---:|---:|---:|---:|---:|
| default | 67,179 | **2** | **0** | **0** | **0** |
| testflags | 89,943 | **2** | **0** | **0** | **0** |

and the VALUE fields (`vpiConstType` / `VpiSize` / `VpiValue` / `VpiDecompile`)
record **no movement of any kind in either mode** — the law writes one edge.
The 2 per mode are `gen_flash_banks[0]` and `[1]`.

---

## 7. Gates

All green — `GATES.txt` has every number. In one line: both binaries built
`-j 2` and frozen `chmod 555` before any sweep, and **every one of the 3,035
`cmds.txt` files per sweep audited by binary PATH — 0 name the main-tree
binary**; goldens 23/0 on BOTH binaries and 0/23 on `/bin/false`; uhdm2rtlil
**679/50/2 in both modes with 0 differing rows** against the committed baseline
AND against my own pristine sweep; surelog **0 differing rows over 1588** with
identical status histograms in both modes (5-way default, 9-way testflags) — **no row converted and `results/*.csv`
not edited**; byte movers **0/1358** and **2/956**, the two being exactly the
PREDICTED Earlgrey databases; 52 + 8 canary rows unchanged, both supplementary
canary suites PASS, `canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0; all five
protected databases byte-identical with `SVSwitch 4842211c4030` and
`YosysVerx 6ccda350c24a` on their pins; and every other named row's head is
unchanged while Earlgrey goes 17 -> 36 in both modes.

Movers were **PREDICTED BY NAME from the PRISTINE databases first**
(`PREDICT_R0.txt`, `predict75.sh`): the over-approximating stage 1 flagged 34
uhdm2rtlil databases and 6 surelog names, and stage 2 refuted every one of them
by reading the source except `Earlgrey_0_1` — leaving the two Earlgrey
databases, and exactly those two moved.

---

## 8. Boundary

`vwide75.sh` / `vdir75.sh` walk a COPY of `tools/probe` with **no path filter**,
`.sv` and `.v`, at ANY depth, both views, both frozen binaries,
workdir-normalised dump byte-compare; the file list is read on fd 3 with children
`</dev/null`, `PROCESSED` is asserted and every cell records its `rc`. **The four
slang-fenced tests are never dispatched** (`FENCED=` filter on the list; 0 files
matched, and `canaudit` asserts no driver in this directory names them).

- **WIDE, per file**: `PROCESSED=3435 identical=6590 DIFFERING=4 no_output=276`
- **DIR, per directory**: `PROCESSED=1500 identical=2744 DIFFERING=10 no_output=246`

`ARMS.txt` adjudicates every differing arm.

| arm | verdict |
|---|---|
| `r10earl75repro/g1_gsproc75.sv` (wide AND dir) | this pass's own grid — the positive control |
| `r10earl_repro/pf19.sv` | **TS TO-GOLDEN 1, AWAY-GOLDEN 0, MOVED-WRONG 0**, both views |
| `r10uvm75repro`, `r10uvm76repro`, `r10uvm88repro`, `r10v109repro` (dir only) | the COIN — see below |

**`r10earl_repro/pf19.sv` is an EARLIER PASS'S ARM carrying this law's exact
shape.** `§ defGenPkgParamFoldQual19`'s matrix puts the two spellings side by
side in one gen block:

```systemverilog
  if (1) begin : gen_body
    always_comb pq = {p19::QA{1'b1}};   // line 50, QUALIFIED
    always_comb pw = {QB{1'b1}};        // line 51, WILDCARD-IMPORTED
```

Line 51 moves TO-GOLDEN (`bare` -> `int_typespec`, signed) and **line 50 does
not move at all** — the qualified-read negative control the origin gate carries,
holding in an arm this pass did not write.

**The four dir-only arms are the documented per-invocation ORDERING coin, and
the NEUTRAL control settles it without reference to the patched binary at all:**
the PRISTINE binary alone, run three times on `r10v109repro`, differs from
itself by 18-22 raw dump lines and by **0 lines once both dumps are sorted** —
the identical signature the patched-vs-pristine comparison shows on all eight
cells. The per-file wide walk sees nothing in any of the four.

Every `rc=139` pairs A with B in both walks (24 wide, 12 dir) — the pre-existing
elab segfaults, on both binaries. No new crash, no new timeout.

---

## 9. Residues, ranked (R0 first)

**R0 — THE NEW EARLGREY HEAD, both modes, 36 lines, 1 head, byte-identical
across the two modes (`HEAD_AFTER_*.cmp`). We FOLD a package-parameter read
inside a for-stmt of a gen-scope process where golden keeps the `ref_obj`.**

```
flash_phy_core.sv:191   for (int i = 0; i < WidthMultiple; i++)
                                            ^^^^^^^^^^^^^  191:27-191:40
in top_earlgrey.u_flash_eflash.gen_flash_banks[0].i_core.gen_prog_data

LHS (golden)  ref_obj  (…gen_prog_data.WidthMultiple)
              vpiActual -> enum_const (WidthMultiple)
RHS (ours)    constant  UINT:2  vpiSize 32  vpiConstType 9
```

The failing field is `VpiType` in `basetype_t::Compare` — the object KIND, not a
value. This is the OVER-FOLD half of the region fence (b) above names: golden
keeps the reference in a for-stmt header and body inside a gen-scope process
(`§ genProcParamFold`, V-FIX v58 (a)) and binds it to a fresh loc-less
`enum_const` carrying the parameter's value (the same shape
`§ genNestedScopePkgParamNoFold24` produces for a nested gen scope). We fold.
The site is `emitExpr`'s NamedValue arm; the fix is to suppress the FOLD, not
the stamp, when `inGenScopeProc && procForAllDepth9 > 0` and the symbol is a
wildcard-imported package parameter — and to bind a `ref_obj` to an
`enum_const` instead. `g1_gsproc75.sv` row B_P11 is the ready-made positive
control (golden has no constant there; three instances x the deduped route), and
row A_P11 is the negative control that says the MODULE BODY does fold and must
not change. Both the always_comb and the always_ff homes are already in the arm.

**R1 — earl72's R1, unchanged, and now FULLY DECODED: the gen-scope
`cont_assign` indexed-part-select WIDTH, 87 objects / 261 (default) and 348
(testflags) census cells, the largest remaining Earlgrey typespec family.**

```
tlul_socket_m1.sv:73    localparam int unsigned STIDW = $clog2(M);
tlul_socket_m1.sv:105   ... tl_h_i[i].a_source[IDW-1 -: STIDW] ...   (gen_host_fifo)
tlul_socket_m1.sv:235   ... drsp_fifo_o.d_source[0+:STIDW] == i ...  (gen_idrouting)

golden  constant UINT:2 sz 32  ref_typespec -> int_typespec 73:14-73:26, UNSIGNED
ours    <null>
```

**It is NOT this pass's law wearing another position.** The origin is a MODULE
LOCALPARAM, not an imported package parameter, so `importedParamDefTs` does not
hold it and `§ ipsWidFold9` — which already fires in a gen-scope `cont_assign`,
context-free — has no typespec to stamp. What the next pass needs is a
**module-localparam declaration-typespec registry** with the same
`(kind, sign, span)` fidelity `makeParamTs` gives an imported one: golden wants a
LOCATED `int_typespec` with `vpiSigned = 0` for `int unsigned`. Every one of the
87 is under `u_xbar_main`/`u_xbar_peri`'s `u_sm1_*` instances, in
`gen_host_fifo[0..2]` and `gen_idrouting[0..2]`, at three operation depths
(`RHS/hp[1]/w`, `RHS/op28[1]/op14[0]/hp[1]/w`,
`RHS/op28[0]/op28[1]/op14[0]/hp[1]/w`).

**R2 — the gen-scope port `High_conn` ips WIDTH, 6 objects / 24 (default) and 48
(testflags) cells — and golden's typespec there is BARE.**

```
rv_timer.sv:20    localparam int N_TIMERS = 1;
rv_timer.sv:83-108  .reg2hw_intr_enable_q_i (intr_timer_en[h*N_TIMERS+:N_TIMERS]),
                    … x6, inside `for (genvar h = 0; …) begin : gen_harts`

golden  constant UINT:1 sz 32  ref_typespec -> int_typespec  span 0:0-0:0 (BARE), SIGNED
ours    <null>
```

This is earl65's named MIRROR family ("a MODULE-BODY localparam / PORT parameter
fold in the same ips position carries a BARE signed `int_typespec` in golden and
nothing at all in ours"), reached inside a gen scope.
`§ connIpsPkgParamBoundNoTs65` refuses the LOCATED stamp in an elaborated
High_conn and is the measured negative control for the located half — a BARE
typespec is a different object and does not contradict it. 6 objects, both
modes, zero cells outside Earlgrey.

**R3 — the `--elabuhdm` view over-folds far more widely than the default view
does.** `g1_gsproc75.sv` has **96 deduped cells** that exist in our `--elabuhdm`
output and in no golden database (against 6 in the default view). Unchanged by
this pass (0 of the 96 moved) and pre-existing, but it is the reason the elab
view's boundary arms are noisy and it is worth a pass of its own.

**R4 — two POSITIONS golden stamps in a process and we stamp in neither home.**
`g1_gsproc75.sv` rows P6 and P10, wrong in the MODULE BODY as well as in the gen
scope, so they are `§ procOpFold9`'s hole and not this law's:
* **P6, a whole Rhs with no operation** — `x = NB;` inside an `always_comb`:
  golden stamps, we leave it bare. The `parent` is the `assignment`, so no arm
  in the chain fires.
* **P10, a `$clog2` ARGUMENT** — earl72's R3, now measured inside a process too.

**R5 — a `param_assign` typespec KIND flip**, 1 cell per mode: golden
`int_typespec` unsigned where we write `logic_typespec`. Pre-existing, untouched,
and invisible to the head.

**R6 — carried forward unchanged:** earl74's R2 (the cross-package PACKED bound),
R3 (the inline-expression dimension), R4 (the `unsigned'(...)` cast blocking a
dimension bound) and R5 (the associative-array bound's allocation-tracking
garbage number); earl72's R2 signedness note (respected and matched by this pass
on the grid) and R4; earl71's R1/R2 and earl69's R1/R5 prettyPrint names.

---

## 10. Reproduction

```bash
# the census reader (direct .uhdm; never uhdm-dump on Earlgrey)
g++ -O2 -std=c++17 cscen75.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cscen75

# the corpus head, one binary, one mode
SLANG_UHDM=<abs path> ./earl75.sh <outdir> default|testflags [--nodump]

# the grid arm: Surelog golden + both frozen binaries, both views, scored
CSCEN75=./cscen75 SCORE75=./score75.py NORM75=./norm75.sh \
PRIS=<pristine> PATCHED=<patched> ./armscore75.sh g1_gsproc75.sv <outdir>
python3 ./goldtbl75.py <outdir>/g.n <outdir>/o.n <outdir>/q.n   # the row table
python3 ./tbl75.py     <outdir>/g.n <outdir>/o.n <outdir>/q.n   # the field split

# the mover prediction, from PRISTINE databases only
CSCEN75=./cscen75 ./predict75.sh <sweep-workdir> <label>

# the boundaries
PROBE_ROOT=<copy of tools/probe> PATCHED_BIN=<p> PRISTINE_BIN=<q> \
  ./vwide75.sh <file-list> <out-prefix>
PROBE_ROOT=<copy of tools/probe> PATCHED_BIN=<p> PRISTINE_BIN=<q> \
  ./vdir75.sh  <dir-list>  <out-prefix>
```

`norm75.sh` is not optional: our databases leave `VpiFile` EMPTY on a folded
constant, the `||` tail is compare-invisible evidence, and the dedup is what
keeps the listener's per-database visit multiplicity from manufacturing 102
phantom "golden has no cell" rows in the `--elabuhdm` view.
