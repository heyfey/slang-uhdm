# r10earl59 — § genCaNestedModuleLhsOpRhsBinds59

**The R0 head is cleared: 127 objects to golden, AWAY-GOLDEN 0, STILL-WRONG 0,
DEF view untouched, and the whole-design blast radius is 254 diff lines — 127
`|vpiActual:` pointers and the 127 net lines they name, ADDED ONLY, ZERO
REMOVED. This pass is a REFUTATION: the law that was in the tree
(`ModuleEmit.cpp` "A NESTED gen scope leaves a MODULE-level whole-ref LHS
unbound") over-claimed, and the correction is not a heuristic — it is
`UhdmWriter::writeCont_assign`'s own three-line test, read out of Surelog.**

Head: **Earlgrey_0_1/default 29 cmp lines → 9 743 cmp lines, 1 head → 1 head.**
The new head is a DIFFERENT FAMILY whose failing LHS is a whole `package`, which
is why its decompile is 9 743 lines — **cmp line count is HEAD DEPTH, never a
distance.**  Earlgrey_0_1/testflags **33 lines → 33 lines, cmp log
BYTE-IDENTICAL including object ids.**

---

## THE HEAD (R0 of the pass, cleared)

```
LHS(golden): logic_net (work@top_earlgrey.u_dm_top.i_dm_csrs.i_fifo.rdata)
             id:291318  prim_fifo_sync.sv:29:27-29:32
             vpiTypespec -> ref_typespec #291319 -> logic_typespec 29:11-29:22
RHS(ours)  : <null>
```

**`RHS: <null>` is a SIGNATURE, and reading it is the whole first half of this
pass.**  `BaseClass.h`'s vector `SafeCompare` sets **both** `m_failedLhs` and
`m_failedRhs` to the OWNER object on a size mismatch; only the two-argument
scalar `SafeCompare(lhs, rhs)` sets `m_failedLhs` alone.  So the head is a
SCALAR slot, not a short vector — and the brief's first hypothesis (our `Nets`
vector drops the port net) is **REFUTED before any code**:

| | golden | ours (pristine) |
|---|---|---|
| `Nets()` on `…i_dm_csrs.i_fifo` | clk_i rst_ni clr_i wvalid wready wdata rvalid rready **rdata** depth | **identical, all 10, same order** |
| `port(rdata)` subtree (46 lines: HighConn `hier_path(dmi_resp_o.data)`, LowConn `ref_obj → logic_net rdata`, vpiTypedef) | | **byte-identical** |
| whole `i_fifo` subtree, 2 539 vs 2 537 lines | | **the ONLY structural difference is 2 lines** |

Those two lines are the head:

```
prim_fifo_sync.sv:144   if (OutputZeroIfEmpty == 1'b1) begin : gen_output_zero
prim_fifo_sync.sv:145     assign rdata = empty ? 'b0 : rdata_int;
```

```
gen_scope(…i_fifo.gen_normal_fifo.gen_output_zero)
  cont_assign 145:14-145:45
    vpiRhs  operation (vpiOpType 32, the ternary)
    vpiLhs  ref_obj (…gen_normal_fifo.gen_output_zero.rdata)
              |vpiActual:  \_logic_net (…i_fifo.rdata) 29:27-29:32   <== GOLDEN ONLY
```

`prim_fifo_sync.sv:29` is the ANSI port `output [Width-1:0] rdata,`; its net is
declared at MODULE level and written from a **NESTED** generate scope
(`gen_normal_fifo` → `gen_output_zero`).  Golden binds the Lhs ref's
`Actual_group`; we left it null.  Not a naming or a span question — one pointer.

The brief's other hypotheses, each REFUTED by measurement, not opinion: the
instance is `.Depth(2)`, **not** the `Depth==0` passthrough branch (`gen_passthru_fifo`
never elaborates here); `.rdata(dmi_resp_o.data)` being a **member select** and
`.depth()` being **unconnected** change nothing (both ports' HighConns are
byte-identical to golden); and golden does not list rdata twice — it lists it
once as a net and points three refs at it, exactly as we do minus this one.

---

## WHAT THE TREE SAID, AND WHY IT WAS WRONG

`src/ModuleEmit.cpp`, the elaborated gen-scope cont_assign arm:

```cpp
// A NESTED gen scope (parent scope is itself a generate block)
// leaves a MODULE-level whole-ref LHS unbound; refs to GEN-scope
// nets still bind (Surelog).
if ((pk0 == SymbolKind::GenerateBlock &&
     (symModuleLevel || lsym0.kind == SymbolKind::Variable)) ||
    (pk0 == SymbolKind::GenerateBlockArray && mapsToVar0))
    lhsSuppress = true;
```

That is a DEPTH law.  Golden's law is not about depth at all.

---

## DECODED FROM SURELOG — TWO BINDERS, NOT ONE

**Binder 1, COMPILE TIME.**  r10earl58's decode: a generate block's
`ModuleDefinition` is compiled with the **PARENT** `ModuleInstance`.  A FLAT
gen block's parent is the module instance, so its netlist holds the module's
nets and the Lhs binds at **any** Rhs shape.  A NESTED block's parent is the
enclosing gen scope, whose netlist holds only THAT scope's nets — so at d2 a
module-level name is invisible here, and an ANCESTOR gen scope's net/var is not.
This is why d1 binds a bare-ref Rhs and d2 does not, and it is the same line of
`DesignElaboration.cpp` § genLpOneHopProcBoundOp58 already names.

**Binder 2, WRITE TIME — the half that was missing.**
`Surelog/src/DesignCompile/UhdmWriter.cpp:2120`, `UhdmWriter::writeCont_assign`:

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  UHDM::any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
  if (var) {
    if (rhs->UhdmType() == uhdmoperation) {          // <-- THE ONLY GATE
      if (cloned == false) { … clone_tree(assign) … }
      ref_obj* ref = (ref_obj*)lhs;
      ref->Actual_group(var);                        // <-- THE BIND
      cloned = true;
```

and `CompileHelper::bindVariable(component, scope, name)`
(`CompileStmt.cpp:3089`) has **no `uhdmgen_scope` case**: it falls through to
`default` and

```cpp
return bindVariable(component, scope->VpiParent(), name, compileDesign);
```

recursing up the parent chain until a `uhdmmodule_inst` case searches that
instance's `Variables()` then its `Nets()`.

> **From a generate scope, `bindVariable` walks straight up to the enclosing
> `module_inst`.  The gen-scope nesting DEPTH is irrelevant; a MODULE-LEVEL name
> is always found.  The only gate on the write-time bind is `Rhs` being an
> `uhdmoperation`.**

That also explains, with no extra rule, why the block's OWN gen-local net never
binds (a `gen_scope` is not searched and the module has no such name → `var ==
nullptr`), and it is the same fact the sibling note four screens down already
recorded from the other direction ("Surelog's elab writer only re-binds a
cont_assign LHS on the clone path it takes for an OPERATION Rhs").

---

## THE GRID (`a1_earl59.sv`, `v59v1/v59v2/v59v3_earl59.sv`, `census59.py`)

**The arm needs a WRAPPER.**  The first arm made `a1` the top module.  It
reproduces (6 gold-only cells) but `uhdm-cmp` reports **PASS** on it, because
`design::Compare` walks `AllModules` before `TopModules` and a one-module design
gives the comparator nothing to disagree about first.  **The dump is the
arbiter on the arms; the official `uhdm-cmp` is the judge on the corpus** — and
v59v1/v2/v3 wrap the module under test in `a1 → u_sub`, which is the corpus
shape (`prim_fifo_sync` is never a top).

`census59.py` keys every cont_assign Lhs/Rhs ref on **(enclosing-scope kind,
NORMALISED scope name, cont_assign SOURCE EXTENT, slot, ref LEAF name,
occurrence)** with the `vpiActual` target's (kind, leaf name) as payload — the
leaf name because our fullname prefixes differ from golden's and `Compare` does
not read fullname; the source extent + occurrence because two elaborated copies
of one generate body must never merge.  **Calibrated before use**, Earlgrey
golden vs golden: `SAME=13797`, every other bucket **0**.

### Rhs SHAPE at d2 (nested if-gen), module-level `wire` LHS

| Rhs, as EMITTED | golden | pristine | patched |
|---|---|---|---|
| `operation` — binary, ternary, unary `~`, concat, replication, comparison, cast | **BOUND** | null | **BOUND** |
| bare `ref_obj` (gen-local, ANCESTOR gen-local, or module net alike) | null | null | null |
| `constant` (literal, and a parameter that FOLDED to one) | null | null | null |
| `part_select` | null | null | null |
| `hier_path` (struct member access) | null | null | null |
| `func_call` | null | null | null |
| `sys_func_call` (`$signed`) | null | null | null |
| `bit_select` | **BOUND** | null | null → **residue R1** |

### LHS KIND at d2, operation Rhs

ANSI `output` PORT net, `output logic` port (a net in the elab view), module
`wire`, module `logic` VAR (binds the `logic_var`, not a net) — **golden binds
all four; pristine bound none; patched binds all four.**

### GENERATE NESTING, operation Rhs

if-in-if (d2), three deep (d3), an **UNNAMED** `begin`/`end` inside a named
if-gen, an if-gen inside a **FOR-generate body**, and a module-level VAR written
from a for-generate body (the `mapsToVar0` half) — **golden binds all five;
pristine bound none; patched binds all five.**

### AND WHAT THE ARM DELIBERATELY LEAVES ALONE

Flat if-gen (d1) at every Rhs shape, a for-generate body's module-NET Lhs, an
ANCESTOR gen scope's net and var, and the writing block's own gen-local VAR were
**already bound on both sides**; the block's own gen-local NET was **unbound on
both**; the whole DEF listing (`work@a3sub.…`) is **`None` on every row, both
sides, before and after**.  Patched arm totals: **v59v1 DIFFERING 0, v59v2
DIFFERING 0, a1 DIFFERING 0, v59v3 DIFFERING 1 — the one bit_select residue.**

---

## THE LAW

> **§ genCaNestedModuleLhsOpRhsBinds59 — in an ELABORATED generate scope whose
> parent scope is itself a generate block or generate-block array, a
> `cont_assign` whose Lhs is a WHOLE `ref_obj` naming a signal declared at
> MODULE level BINDS that ref's `Actual_group` to the module's own net or
> variable object WHEN, AND ONLY WHEN, THE EMITTED `Rhs` IS AN `operation`.**

Implementation: one flag added inside the existing suppression, nothing else.

```cpp
bool opRhsModuleLhs59 = symModuleLevel && rhs &&
                        rhs->UhdmType() == UHDM::uhdmoperation;
if (!opRhsModuleLhs59 && ( …the pre-existing condition, verbatim… ))
    lhsSuppress = true;
```

Three fences, each measured, none decorative:

1. **`symModuleLevel`** — the LHS symbol's parent scope is the `InstanceBody`.
   This is exactly the set `bindVariable` can reach, so it is Surelog's own
   reach, not a guess.  The `lsym0.kind == Variable` clause (a GEN-scope
   variable) and the `mapsToVar0` clause keep their suppression untouched for
   non-module-level symbols; those rows were already right on both sides
   because `bindGenLocal9` re-binds them (the TWO WRITERS note).
2. **`rhs->UhdmType() == uhdmoperation`** — `writeCont_assign`'s own test,
   verified against 8 distinct emitted Rhs kinds on the arm.
3. **the arm is inside `emitGenScopes`' ELABORATED path**, which is why the DEF
   view cannot move — and the census says so independently: **0 DEF cells in
   the mover set, 0 diff lines carrying a `work@prim_fifo_sync.…` path.**

---

## CENSUS: PREDICTED 127, MEASURED 127, AWAY-GOLDEN 0

`CENSUS_PREDICT59.txt` was written BEFORE the patched binary existed.

3-way attribution, Earlgrey_0_1/default, golden / pristine / patched, 13 536
keyed rows:

```
UNMOVED-GOOD=13409   TO-GOLDEN=127   AWAY-GOLDEN=0   STILL-WRONG=0
UNMOVED-BAD=352
```

and every one of the 127 is the same row:

```
TO-GOLDEN gen_scope  line:145:14, endln:145:45  ref=rdata  Rhs=operation
   gold=('logic_net','rdata')   pris=None   pat=('logic_net','rdata')
```

127 elaborated `gen_normal_fifo.gen_output_zero` copies, in 127 DISTINCT
instance paths: 43 `rspfifo` + 43 `reqfifo` (the tlul sockets), 9 each of
`u_rspfifo`/`u_reqfifo`/`u_maskfifo`, then `i_slice`, `i_rsp_order_fifo`,
`i_host_rsp_fifo`, `u_uart_txfifo`, `u_uart_rxfifo`, `u_req_fifo`, `u_rd_fifo`,
`u_prog_fifo`, `u_msg_fifo`, … and `…i_dm_csrs.i_fifo`, the head itself.

### WHOLE-DESIGN BLAST RADIUS

Path-normalised whole-dump diff, pristine vs patched: **254 lines in 127 hunks,
and the histogram IS the law:**

```
ADDED    127   |vpiActual:
ADDED    127   \_logic_net: (work@top_earlgrey.<path>.rdata), line:29:27, endln:29:32
REMOVED    0
```

**ZERO** removed lines.  **ZERO** lines naming any other identifier, file, net,
var, port, process, assign, module or instance.  **ZERO** DEF-view paths.  No
new object is minted — the 127 net objects already existed and are merely
pointed at.

### THE FAMILY, AND WHAT THIS PASS LEAVES

The `GOLD-BINDS-WE-DONT` bucket on Earlgrey_0_1/default was **127 cells and is
now 0**.  The other census buckets are **unchanged, cell for cell**, and each is
named:

| n | bucket | what it is |
|---:|---|---|
| **127** | GOLD-BINDS-WE-DONT | **CLAIMED — the head, all of it** |
| 128 | we bind, golden's row sits under a scope the reader cannot attribute | pinmux `data_mux`/`oe_mux`/`sleep_mux` (:160/:174/:175/:176), PAIRED 1:1 with 128 `KEY-ONLY-GOLD` rows at the SAME extent, SAME name and the SAME actual — a scope-ATTRIBUTION difference, not a binding difference |
| 89 | KEY-ONLY-OURS `\|vpiRhs:` | `offset` at :73/:114 — cont_assign SPAN keys golden does not have; payload `None` on both, so no binding disagrees |
| 3 | Rhs-KIND differs (`warl_mask`, `a_wmask_d`, `b_wmask_d`) | both sides BIND the same object; the Rhs shape differs |
| 2+2 | prim_packer `valid_next` :183 | net-vs-var and a one-column span |

---

## GATE RESULTS

| gate | measurement | result |
|---|---|---|
| **1 build** | both, `-j 2`, md5 **separately**, then COPIED to `/tmp/r10earl59_bin/{pris,pat}` and `chmod 555` so no build can touch them | pristine **`62012557c82e8b1f1bf9527ff5333dd1`**, patched **`cf2dadb2c8fc5811e76b801a078c1ddf`** |
| **2 goldens** | `tests/check_goldens.sh`, `SLANG_UHDM` exported EXPLICITLY to EACH | patched **23 PASS / 0 FAIL**, pristine **23 / 0**, `/bin/false` **0 PASS / 23 FAIL** |
| **3 u2r** | `ct8rows.sh`, **baseline FIRST** | testflags vs committed baseline: pristine **0 rows**, patched **0 rows**; pristine↔patched **0 rows** in BOTH modes.  Status **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in every cell, dump column included |
| **4 surelog** | both modes concatenated, **1 588 rows** | baseline↔pristine **0**, baseline↔patched **0**, pristine↔patched **0**.  Status and dump histograms identical (default 470/11/5/283/25; testflags 466/9/5/3/1/284/23/1/2).  **NO ROW CONVERTED**; `results/*.csv` NOT edited |
| **5 byteverify** | `byteverify59.sh` + both controls | surelog **956 paths, EXACTLY 2 movers** — `./default/Earlgrey_0_1-71da2fd7` and `./testflags/Earlgrey_0_1-71da2fd7`, **both PREDICTED BY NAME in `CENSUS_PREDICT59.txt`**; u2r **1 358 paths, 0 movers**.  Controls: `SELFCHECK=1` → **1357/1358** flagged, `SELFCHECK1=1` → **exactly 1** |

**BINARY AUDIT — EVERY `cmds.txt`, not `head -1`.**  `sweeps59.sh`'s own
`find … | head -1` readback is ambiguous across a re-run, so the authoritative
audit is over every file in every workdir root:

```
/tmp/r10earl59_swd/surelog_pat     1523 slang: lines, 1523 name .../pat,  OTHER 0
/tmp/r10earl59_swd/surelog_pris    1523 slang: lines, 1523 name .../pris, OTHER 0
/tmp/r10earl59_swd/uhdm2rtlil_pat  1458 slang: lines, 1458 name .../pat,  OTHER 0
/tmp/r10earl59_swd/uhdm2rtlil_pris 1458 slang: lines, 1458 name .../pris, OTHER 0
```

`GOLDEN_DEFER` was never set (`sweeps59.sh` unsets it explicitly).  Both
binaries were frozen at immutable paths BEFORE any sweep started (earl58's
build-race lesson), and no build ran during the sweeps.

### CANARIES AND BOUNDARIES

* `canaudit.sh canaries.sh ctcan2.sh`: **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
  all four slang-fenced names dispatched by no driver here, and none of them is
  spelled in any artifact of this pass.
* `canaries.sh`: surelog **ok=52 changed=0 absent=0** on BOTH binaries; u2r
  (testflags CSV, matching the committed baseline's own mode) **ok=8 changed=0
  absent=0** on both.  `ctcan2.sh` (`EXPECT_UNKNOWN=1`): **ok=58 changed=0**.
* Every named pin — InterfaceModPort, BlackParrotComplex, YosysOldOr, SVSwitch,
  YosysVerx — is covered by gate 5's result: **2 312 of 2 314 databases
  byte-identical, the only 2 movers named above.**
* **WIDE BOUNDARY** (`vbndall59.sh`, both views, both binaries, every committed
  `.sv` under `tools/probe`, recursive): **runs=2022 arms=1011 identical=1959
  DIFFERING=34 no_output=29**.  8 of the 34 are this pass's own four arms
  reached twice by the two globs (earl58 documented that double-reach); the
  remaining 26 rows are **10 DISTINCT EARLIER-PASS ARMS, and this pass says so
  LOUDLY rather than quoting `identical=` and moving on**:

  ```
  r10earl50repro/w2_v50.sv          plain elab
  r10earl57repro/v2_contexts57.sv   plain
  r10earl58repro/v58v2_earl58.sv    plain elab
  r10earl58repro/v58v5_earl58.sv    plain elab
  r10earl58repro/v58v6_earl58.sv    plain elab
  r10earl58repro/v58v7_earl58.sv    plain elab
  r10earl_repro/qa25.sv             plain elab
  r10earl_repro/qb25.sv             plain elab
  r10earl_repro/qc25.sv             plain elab
  r10earl_repro/qh21.sv             plain
  ```

  **Every one of them is a gen-scope `cont_assign` arm — the very shapes this
  law is about — and every one MOVES ONTO GOLDEN.**  `varm59.sh` runs Surelog
  plus BOTH binaries on each and attributes every moved cell three ways; summed
  over all **18 arm/view runs**:

  | | TO-GOLDEN | **AWAY-GOLDEN** | STILL-WRONG |
  |---|---|---|---|
  | keyed binding census (exact, slot-aware) | **25 cells** | **0** | **0** |

  and the whole-dump line-multiset distance to golden FALLS on **15** of the 18
  (`w2_v50` 103→101 / 113→111, `v2_contexts57` 38→34, `qh21` 18→16, `v58v2`
  372→370 / 387→385, `v58v5` 337→335 / 371→369, `v58v6` 207→205 / 225→223,
  `v58v7` 211→209 / 220→218, `qa25/elab` 322→320, `qc25` 98→92 / 151→145) and is
  UNCHANGED on the other **3** (`qa25/plain` 143, `qb25` 30 and 43).  Every moved cell has the same shape as the head: a module-level
  whole-ref Lhs in a NESTED gen scope with an `operation` Rhs, e.g.
  `v58v2_earl58/elab` `assign o = r_lat ^ … ^ r_whl;` at 39:14 inside
  `g1.g2` — golden `('logic_net','o')`, pristine `None`, patched
  `('logic_net','o')`.  `qb25/elab`'s `GOLD-BINDS-WE-DONT` bucket goes **2 → 0**
  and its `WE-BIND-GOLD-DOESNT` bucket is **0 before and 0 after**.

  **AN INSTRUMENT BUG THIS PASS FOUND AND FIXED, because it first read as a
  regression.**  `varm59.sh`'s original line-multiset keyed on the RAW line,
  leading whitespace included, which makes TREE DEPTH part of the key — and
  these arms carry PRE-EXISTING depth differences vs golden.  It reported
  `AWAY-GOLDEN=2` for `v58v2_earl58/elab` on a line whose plain count went
  **6 → 7 against golden's 7**, i.e. a cell that landed exactly ON golden
  (`|vpiActual:` totals: golden 165, pristine 162, patched 163).  Stripping the
  indentation turned all four of those into TO-GOLDEN.  Three runs
  (`qa25/plain`, `qb25/plain`, `qb25/elab`) still print a bare
  `AWAY-LINE: |vpiActual:` with the total distance **UNCHANGED** (143→143,
  30→30, 43→43) — the same three — : a tag line with no identity of its own, and the exact keyed
  census on those same arms reports **AWAY-GOLDEN=0** with the arm's
  `GOLD-BINDS-WE-DONT` going 2 → 0.  The aggregate `|vpiActual:` total
  overshooting golden's on `qb25` is a PRE-EXISTING offsetting pair OUTSIDE the
  cont_assign Lhs/Rhs slots this census keys (the arm binds 2 that golden does
  not, somewhere this instrument does not look) — unchanged by this pass.
* **DEF-VIEW FENCE, measured twice.**  Earlgrey: of the 254 diff lines, **0**
  carry a `work@prim_fifo_sync.…` DEF path.  Arms: on `qc25/elab` the 14
  DEF-listing keyed rows are **0 moved**, and on `v59v3` every `work@a3sub.…`
  row is `None` on both sides before and after.  The law names no DEF cell and
  no DEF cell moves.
* **SIGNAL rows**: 6, and **SYMMETRIC** — `r10buvm8repro/v21shadow8.sv`,
  `r10uvm84repro/v84x8_break.sv`, `r10uvm87repro/v87_a4_scope.sv` each rc=139 on
  **BOTH** binaries in the elab view.  Pre-existing, and an asymmetric
  instrument could not have said so.
* **ROW HEADS** (`rowheads.sh`, LHS always golden), pristine → patched:

  | test | default | testflags |
  |---|---|---|
  | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg | 47 → 47, 1 head | 47 → 47 |
  | Rggen | 85 → 85, 1 head | (no golden on this machine) |
  | **Earlgrey_0_1** | **29 → 9 743, 1 head → 1 head, NEW FAMILY** | **33 → 33, cmp log BYTE-IDENTICAL, ids included** |

---

## THE TWO EARLGREY MODES

**default** — head cleared, see `PREDICT_R0.txt`.  The new R0 is
`typespec::Instance()` — the `vpiInstance` back-pointer from an elaborated
typespec to its DECLARING PACKAGE.  Golden sets **15 402** of them from
`uhdmtopModules` to the end of the dump and we set **13 660**; the 1 742 missing
are spread over **33 packages**, `dm::` merely being the first the walk reaches
after this pass's cell.  **NOT A REGRESSION, measured not asserted:** the
`vpiInstance → package dm` count is **405 in the pristine dump and 405 in the
patched dump** (golden 432), and the pristine↔patched whole-dump diff contains
nothing but this pass's 127 pointers.

**testflags** — head **33 lines, UNCHANGED**, and the cmp log is **byte-identical
between the two binaries down to the object ids** (237109, 755959).
**DECODED HERE against the testflags golden, and the brief's framing is REFUTED
BY THE CENSUS BEFORE ANY CODE.**  It is *not* an extra elaborated localparam:
the `Parameters()` vector on the elaborated `…u_dm_top.i_dm_mem` module_inst is
**20 entries on both sides, name for name, same order — EXTRA-OURS `[]`,
MISSING-OURS `[]`.**  `LHS: <null>` with a non-null RHS is the scalar
`SafeCompare` read the other way round: an `Actual_group` golden leaves NULL and
we SET.  The census over every slot pointing at a `DbgAddressBits` parameter
gives `|vpiActual:` **golden 27, ours 28**, and the 28th is exactly one
reference:

```
dm_mem.sv:64  localparam logic [DbgAddressBits-1:0] DataBaseAddr = (dm::DataAddr);
                               ^^^^^^^^^^^^^^ 64:21-64:35
range 64:20 < operation 64:21 < ref_obj (work@dm_mem.DataBaseAddr.DbgAddressBits)
   golden: vpiName + vpiFullName, NO vpiActual
   ours  : |vpiActual: -> parameter (work@top_earlgrey.u_dm_top.i_dm_mem.DbgAddressBits)
```

> **R0-testflags is a CROSS-VIEW ACTUAL LEAK: a DEF-VIEW localparam
> declaration's RANGE BOUND binds to the ELABORATED INSTANCE's parameter
> object.**

Testflags-only, and measured so: the same census on the DEFAULT dumps reads
**golden 0 / pristine 0 / patched 0** — there the ref at 64:21 binds the DEF-view
`work@dm_mem.DbgAddressBits` identically on both sides, and only `--elabuhdm`
mints the elaborated-instance parameter the def-view range then grabs.  A
SEPARATE MECHANISM, not a candidate to fold in: this pass moves `cont_assign`
Lhs pointers to MODULE-LEVEL NETS inside NESTED GENERATE SCOPES, while
R0-testflags has no generate scope and no cont_assign in it at all.  Full decode
in `PREDICT_R0.txt`.

---

## RESIDUES, RANKED (every one measured, none guessed)

* **R1 — a BARE `bit_select` Rhs at d2 also binds in golden.**  Arm row
  `mn_d2_bselbare` (`assign mn = ln_net[1];` inside a nested if-gen): golden
  BOUND, patched still null.  It is **not** the `uhdmoperation` test, so it is
  one of `writeCont_assign`'s OTHER clone triggers (the `DetectUnsizedConstant`
  branch is the leading candidate — the index literal `1` is unsized — and a
  clone binds the Lhs unconditionally through `ref_obj::DeepCopy`'s
  `bindAny(VpiName())`).  A BARE `part_select` at the same position does NOT
  bind, which is what makes it a clone-trigger question and not a select
  question.  **The Earlgrey corpus holds ZERO cells of this shape**, so claiming
  it now would be unmeasured risk for zero corpus gain.  Reproducing arm row:
  `v59v3_earl59.sv` `mn_d2_bselbare`.
* **R2 — the 128 pinmux `data_mux`/`oe_mux`/`sleep_mux` cells.**  Both sides
  BIND the same object; golden's cont_assign hangs under a parent the census
  reader cannot attribute to a `gen_scope`/`module_inst` ancestor while ours
  hangs under a `gen_scope`.  A STRUCTURAL parent difference in a gen-scope
  listing, PRE-EXISTING, unchanged by this pass, and now counted.
* **R3 — 89 `|vpiRhs:` span keys** (`offset` at :73 and :114) present in our
  dump under a cont_assign extent golden does not have.  Payload `None` on both
  sides, so no binding disagrees; a SPAN family.
* **R4 — the new R0**, `typespec::Instance()` → the declaring package, **1 742
  slots over 33 packages**, plus three `module_inst`-valued rows (golden gives
  one typespec `vpiInstance → work@dmi_jtag` and one → `work@ibex_cs_registers`
  that we do not; we give one → `work@prim_sram_arbiter` that golden does not).
  Fully characterised in `PREDICT_R0.txt`.
* **R5 — R0-testflags**, `i_dm_mem.DbgAddressBits`, decoded above as
  flag-conditioned and left for a pass whose primary arm is the testflags
  golden.

## THE LADDER

**Not re-run, and this pass says so rather than quoting a stale number.**
r10earl57's `LADDER57.md` established that the horizon rule is not a sound
ordering bound (masking reorders the walk) and that the whole-dump diff is the
arbiter.  Here both arbiters are exact and agree: the 3-way census says
`TO-GOLDEN=127 / AWAY-GOLDEN=0 / STILL-WRONG=0`, and the whole-dump diff is 254
lines carrying one identifier.  A ladder run could not add to that and could
subtract from it by being quoted as a distance.

## FILES

| file | what |
|---|---|
| `a1_earl59.sv` | the first arm — module under test as TOP.  Kept because it is the reason the wrapper exists: it reproduces in the dump and `uhdm-cmp` calls it PASS |
| `v59v1_earl59.sv` | the same rows WRAPPED (`a1 → u_sub`), the corpus shape; the head reproduces here |
| `v59v2_earl59.sv` | THE GRID — Rhs shape × LHS kind × generate nesting, one axis per row |
| `v59v3_earl59.sv` | the shapes v2 left open: bare bit/part-select, hier_path, cast, replication, comparison, module VAR from a for-gen body, ancestor gen var/net |
| `census59.py` | the whole-design binding census (extent+occurrence key, leaf-name payload, Rhs-kind recorded); calibrated gold-vs-gold before use |
| `gridrows59.sh` | one-line-per-row grid printer for an arm workdir |
| `CENSUS_PREDICT59.txt` | the prediction, written before the patched binary existed |
| `PREDICT_R0.txt` | the next head (both modes), predicted then measured |
| `arm59.sh` / `armplain59.sh` | arm drivers, elab and plain |
| `earl59.sh` | Earlgrey_0_1/default, one binary, against the immutable golden cache |
| `sweeps59.sh` / `ct8rows.sh` / `byteverify59.sh` | gates 3, 4, 5 |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary battery and its audit |
| `rowheads.sh` | the seven named row heads |
| `vbndall59.sh` | the wide boundary (1 011 arms, 2 022 runs) |
| `varm59.sh` | the boundary 3-way verifier: Surelog + both binaries per arm, TO/AWAY/STILL attribution on dump lines AND on keyed bindings |
