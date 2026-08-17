# r10earl58 — § genLpOneHopProcBoundOp58

**The R0 head is cleared: 107 objects to golden, AWAY-GOLDEN 0, STILL-WRONG 0,
DEF view untouched, and the whole-design blast radius is 1 605 diff lines of
which every single one is the one identifier this law names.  The "one hop up
the name" that r10earl47 measured and r10earl56 fenced is DECODED: it is one
line of `DesignElaboration.cpp`, and three independently-measured laws fall out
of it.**

Head: **46 cmp lines → 29**, 1 head → 1 head, and the new head is a
DIFFERENT FAMILY and a MISSING OBJECT (`RHS: <null>`), not a field difference.

---

## THE HEAD (R0 of the pass, cleared)

```
LHS(golden): constant  id:291799  prim_fifo_sync.sv:131:29-131:38  UINT:2 size 32
             < operation 131:29-131:40 < part_select(fifo_wptr)
             < bit_select(storage) < assignment < begin < if_stmt < always_ff
             < gen_scope(gen_depth_gt1) < gen_scope(gen_normal_fifo)
RHS(ours)  : ref_obj(…gen_depth_gt1.storage.fifo_wptr.PTR_WIDTH) id:236039
```

`hw/ip/prim/rtl/prim_fifo_sync.sv`:

```systemverilog
end else begin : gen_normal_fifo
  localparam int unsigned PTRV_W    = $clog2(Depth) + ~|$clog2(Depth);   // 55
  localparam int unsigned PTR_WIDTH = PTRV_W+1;                          // 56
  …
  if (fifo_wptr[PTR_WIDTH-2:0] == (Depth-1)) begin                       //  88  d0
  …
  end else begin : gen_depth_gt1
    assign storage_rdata = storage[fifo_rptr[PTR_WIDTH-2:0]];            // 127  d1 CA
    always_ff @(posedge clk_i)
      if (fifo_incr_wptr) begin
        storage[fifo_wptr[PTR_WIDTH-2:0]] <= wdata;                      // 131  d1 PROC
```

107 elaborated `gen_normal_fifo.gen_depth_gt1` copies.  The sibling **cont-assign
four lines up was already golden on our side** (§ genCaLhsParamFold; r10earl56's
107-cell regression note is about exactly those cells).  The PROCEDURAL twin was
the hole.

---

## WHAT "ONE HOP" ACTUALLY IS — DECODED FROM SURELOG, THEN MEASURED

`DesignElaboration::elaborateInstance_`, three call sites (lines 1538, 1621,
1660, and the two at 911/1145):

```cpp
// Compile generate block
((ModuleDefinition*)def)->setGenBlockId(blockId);
FunctorCompileModule funct(m_compileDesign, (ModuleDefinition*)def, design,
                           …, parent);          // <-- m_instance = THE PARENT
funct.operator()();
child = factory->newModuleInstance(def, fC, blockId, parent, …);  // the block's
                                                                  // OWN instance,
                                                                  // created AFTER
```

A generate block's `ModuleDefinition` is compiled **with the PARENT
`ModuleInstance`**, never its own.  Every statement inside it is compiled at
`Reduce::No` — `CompileHelper::compileAlwaysBlock` hardcodes it, twice.  At
`Reduce::No` the ONLY substitution `CompileExpression`'s identifier arm can still
make is this one (`CompileExpression.cpp` ~2865):

```cpp
if (ModuleInstance *inst = valuedcomponenti_cast<ModuleInstance *>(instance))
  if (Netlist *netlist = inst->getNetlist())
    for (param_assign *pa : *netlist->param_assigns())
      if (pa->Lhs()->VpiName() == name)
        if ((reduce == Reduce::Yes) ||
            (pa->Rhs() && pa->Rhs()->UhdmType() == uhdmconstant))   // <-- Reduce::No
          result = clone_tree(pa->Rhs()); result->VpiParent(pa);
          fC->populateCoreMembers(child, child, result);            // the USE's span
          … res->Typespec(<the parameter's OWN typespec>) …
```

and `NetlistElaboration::elab_parameters_` fills that vector from
`mod->getParamAssignVec()` — **the definition's OWN parameters, nothing
inherited**.

> **THE PARAMETER SET VISIBLE INSIDE A GENERATE BLOCK IS EXACTLY ITS PARENT
> SCOPE'S OWN PARAMETERS.**

Distance 0 invisible (a block cannot see itself), distance 1 visible, distance
2+ invisible.  **Three laws this campaign measured separately are the same line
of code:**

| law | what it measured | what the decode says |
|---|---|---|
| § genLpUseFoldParentScope47 | "one hop up the name, no more and no less" | parent-instance compile |
| § genScopeOwnParamNoSelFold56 | d0 keeps `ref_obj` | a block is not its own parent |
| § genProcParamFoldTopGenOnly20 | a MODULE param folds in a FLAT gen block, keeps its ref in a NESTED one | a flat block's parent IS the module instance; a nested block's parent is a gen scope with no module parameters |

and the three contexts that refuse at EVERY distance are decoded too:
`compileInitialBlock` passes **no instance at all**; function/task bodies the
same; net-decl-assign / var-decl-init are elaborated against the declaring
scope's OWN instance, which is why they answer **d0/d1 backwards** (r10earl56's
R-V1, re-measured here).

---

## THE GOLDEN GRID (`a1_earl58.sv`, `grid58.py`)

One arm, 468 golden cells: **3 distances × 9 contexts × 12 positions × 3
generate kinds × 5 parameter kinds, both elaborated copies.**  `grid58.py` keys
each cell on the identifier's own EXACT SOURCE EXTENT (line, start col, end col)
— a start-only key merges `L1` with the operation `L1-1` that begins at the same
column and reports `constant` for a cell whose identifier is still a `ref_obj`.

| context | d0 | **d1** | d2 |
|---|---|---|---|
| `assign` (cont_assign) | ref_obj | **CONSTANT** | ref_obj |
| `always_ff` / `always_comb` / `always @*` | ref_obj | **CONSTANT** | ref_obj |
| `initial` | ref_obj | ref_obj | ref_obj |
| function body / task body | ref_obj | ref_obj | ref_obj |
| net-decl-assign (`wire x = …`) | **CONSTANT** | ref_obj | ref_obj |
| var-decl-init (`logic x = …`) | **CONSTANT** | ref_obj | ref_obj |

At d1 in a cont-assign or an always block golden substitutes at **every position
measured**: direct part-select left and right, part-select left inside an
OPERATION, ips base direct and nested, ips width, bit_select index direct and
nested, bare operand, plain operation operand, replication count, comparison
operand, LHS select bound, `if` condition, `case` item.  The GENERATE KIND does
not matter — a named if-generate, an **UNNAMED** `begin`/`end` and a
**for-generate** body all substitute (rows `un_*`, `fg_*`).  Neither does the
PARAMETER KIND — typed `int unsigned`, typed signed `int`, UNTYPED, a gen-scope
`parameter`, and one COMPUTED from a module parameter all substitute (rows
`kp_*`).  A **GENVAR** never does (rows `fg_gv`), and cannot: it has no
`param_assign`.

**The POSITION restriction in the shipped law is OURS, exactly as
§ genLpUseFoldParentScope47's was** — see the residues.

---

## THE LAW

> **§ genLpOneHopProcBoundOp58 — in an ELABORATED gen-scope `always` /
> `always_ff` / `always_comb` / `always_latch`, a reference to a parameter
> DECLARED BY THE IMMEDIATELY-ENCLOSING GENERATE SCOPE'S PARENT GENERATE SCOPE,
> NESTED INSIDE A SELECT-BOUND OPERATION, is replaced by a copy of that
> parameter's elaborated `param_assign` Rhs CONSTANT — value, size, decompile
> and encoding verbatim, the USE's own span, the enclosing OPERATION as
> `vpiParent`, and a `ref_typespec` at the SELECT BASE onto the parameter's own
> typespec.**

Five fences, each one measured, none decorative:

1. **`alwaysProc58`** — not an `initial`/`final`.  **THIS FENCE IS A REGRESSION
   THIS PASS MEASURED AND FIXED BEFORE LANDING**: the first build folded inside
   `initial` too and turned **8 pristine-right cells into patched-wrong**
   (`a1_earl58.sv` rows `in_d1_pslo`, `in_d1_ipsbo`, `in_e1_pslo`,
   `in_e1_ipsbo`, both elaborated copies).  `AWAY-GOLDEN` went 8 → 0 and
   `UNMOVED-GOOD` 13 798 → 13 806.
2. **`!currentSubSym`** — not a function/task body.
3. **`!defGenProcessEmit` + `inGenScopeProc`** — ELABORATED emission only, which
   is why the DEF view cannot move.
4. **`inPsBound && !directBound56 && parent is an operation`** — the position
   restriction, and the discriminator r10earl56 proved exact.
5. **the Rhs-is-a-constant test** — **Surelog's own**, not a heuristic: at
   `Reduce::No` the substitution is guarded by
   `pa->Rhs()->UhdmType() == uhdmconstant`, and `genLpFoldByPath` is this
   exporter's model of that netlist `param_assign`.

The fold constant is found **BY PATH**, `genBlkFullName58` minus one component,
never by a scan over the map's values: 107 `gen_depth_gt1` copies do NOT share a
PTR_WIDTH (Depth differs), and the measured values are **101 × 2, 3 × 5, 2 × 6,
1 × 3** — the Rggen lesson (a location+name scan hands back whichever instance
was emitted first) encoded as a lookup that cannot make that mistake.

---

## CENSUS: PREDICTED 107, MEASURED 107, AWAY-GOLDEN 0

`v58span3.py` (r10earl56's deep below-slot instrument) keys EVERY object at any
depth on (VIEW, own line:col, slot, parent kind, parent span, occurrence) with
an IDENTITY payload.  **Calibration first**, `a1_earl58` golden vs golden vs
golden: `UNMOVED-GOOD=14927 TO-GOLDEN=0 AWAY-GOLDEN=0 STILL-WRONG=0` — a
detector that flags nothing on identical inputs.

**Earlgrey_0_1/default, golden / pristine / patched:**

```
== UNMOVED-GOOD=489539  TO-GOLDEN=107  AWAY-GOLDEN=0  STILL-WRONG=0
   UNMOVED-BAD=10828  KEY-MOVED=0  KEY-ONLY-GOLD=7802
```

Every one of the 107 is the same row:

```
TO-GOLDEN ELAB 131:29 vpiOperand par=operation 131:29 occ=1..107
   gold=constant[vpiDecompile=2,vpiSize=32,UINT=2,vpiConstType=9]
   pris=ref_obj(PTR_WIDTH)  pat=constant[…identical to gold…]
```

`CENSUS_PREDICT58.txt` was written BEFORE the patched binary existed and
predicted **107 / 0 / 0**, the object field for field, and the mover list by
name.  All exact.

### THE FAMILY, AND WHAT THIS PASS LEAVES

The whole `constant > ref_obj` family in Earlgrey_0_1/default is **2 595 cells
in 80 groups**.  This law claims **107** and leaves **2 488**, by named
sub-family:

| n | sub-family | why not this pass |
|---:|---|---|
| **107** | **d1 gen-scope localparam nested in a select-bound OPERATION, in a PROCESS** | **CLAIMED — the head** |
| 1 989 | d1 gen-scope localparam at a DIRECT `bit_select` INDEX, in a CONT-ASSIGN (rv_plic_target `gen_level`→`gen_nodes` `Pa`/`C0`/`C1`, 15 sites × 127, + 84 in u_flash_eflash) | **residue R1** — same law, one position over; those cont-assigns sit in a FOR-generate body where `genCaLhsParamFold` is switched off by `blkInLoop3` and `currentGenBlkScope` is not set at all |
| 348 | GENVARs at a bit_select index (tlul_socket_m1) | excluded by the law itself |
| 90 | MODULE / PACKAGE parameters in gen-scope cont-assigns (tlul_socket_m1 `IDW`/`STIDW`, pinmux `MioPeriphHasSleepMode`) | a different family |
| 61 | port HighConns and function bodies (flash_phy_core, spi_device, tlul_socket_1n, flash_ctrl, prim_sram_arbiter) + 3 DEF cells | a different family |

The opposite direction (`ref_obj > constant`, we substitute and golden does not)
is **28 cells** before and **28 cells after** — untouched, because an arm that
only fires where the pristine binary emits a `ref_obj` cannot destroy them.

---

## THE WHOLE-DESIGN BLAST RADIUS

Earlgrey_0_1/default, path-normalised whole-dump diff, pristine vs patched:
**1 605 lines, and the line histogram IS the family:**

```
REMOVED                                  ADDED
 107  \_ref_obj: (…storage.fifo_wptr.PTR_WIDTH)   214  \_constant: @131:29
 107  |vpiName:PTR_WIDTH                          107  \_ref_typespec: (…storage.fifo_wptr)
 107  |vpiFullName:… (107 DISTINCT instance paths) 107  \_int_typespec: @56:16
                                                  107  |vpiSize:32  |vpiConstType:9  |UINT:…
```

**ZERO** lines naming any other file, any other identifier, or any net, var,
port, process, assign, module or instance object.  **ZERO** diff lines carry a
DEF-view path (`work@prim_fifo_sync.…`); all 107 moved fullnames are elaborated
`work@top_earlgrey.…` paths.  **The DEF fence holds, and the census says so
independently: 0 DEF cells in the mover set.**

---

## GATE RESULTS

| gate | measurement | result |
|---|---|---|
| 1 build | both, `-j 2`, md5 separately, then COPIED to immutable paths | pristine **`d3e7f0df4195b2b26d9100d1e00afd37`**, patched **`aaf21e86e1efe4599d12816a4fbf7fb7`** |
| 2 goldens | `tests/check_goldens.sh`, `SLANG_UHDM` exported to EACH | patched **23 / 0**, pristine **23 / 0**, `/bin/false` **0 / 23** |
| 3 u2r | `ct8rows.sh`, baseline FIRST | testflags vs committed baseline: pristine **0 rows**, patched **0 rows**; default pristine↔patched **0 rows**; testflags pristine↔patched **0 rows**.  Status **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** unchanged |
| 4 surelog | both modes concatenated, **1 588 rows** | baseline↔pristine **0**, baseline↔patched **0**, pristine↔patched **0**.  **NO ROW CONVERTED**; `results/*.csv` NOT edited |
| 5 byteverify | `byteverify58.sh` + both controls | u2r **1 358 paths, 0 movers**; surelog **956 paths, EXACTLY 2 movers** — `default/Earlgrey_0_1` and `testflags/Earlgrey_0_1`, both PREDICTED BY NAME.  Controls: `SELFCHECK` **1357/1358** flagged, `SELFCHECK1` = **1** |

**BINARY AUDIT (the trap this pass fell into and caught).**  The first sweep run
raced a rebuild: `build_pat` was recompiled underneath a running sweep.  The run
was KILLED, its CSVs and workdirs DELETED, both binaries COPIED to
`/tmp/r10earl58_bin/{pris,pat2}` where no build can touch them, and the sweeps
re-run.  `sweeps58.sh`'s own `find … | head -1` readback is AMBIGUOUS across a
re-run (it can pick a cmds.txt the current mode has not rewritten yet); the
authoritative audit is over EVERY file:

```
/tmp/r10earl58_swd/uhdm2rtlil_pat  1458 slang: lines, 1458 name pat2, 0 name the stale binary
/tmp/r10earl58_swd/surelog_pat     1523 slang: lines, 1523 name pat2, 0 name the stale binary
```

### CANARIES AND BOUNDARIES

* `canaudit.sh canaries.sh ctcan2.sh`: **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
  the four slang-fenced names dispatched by no driver here.
* `canaries.sh`: surelog **ok=52 changed=0 absent=0**, u2r **ok=8 changed=0**;
  pristine side identical.  `ctcan2.sh` (EXPECT_UNKNOWN=1): **ok=58 changed=0**.
* Every named pin (InterfaceModPort, BlackParrotComplex, YosysOldOr, SVSwitch,
  YosysVerx) is covered by the byte verifier's result: **2 304 of 2 314
  databases byte-identical, the only 2 movers named above.**
* **WIDE BOUNDARY** (`vbndall58.sh`, both views, both binaries, every committed
  `.sv` under `tools/probe`): **runs=1950 arms=975 identical=1918 DIFFERING=4
  no_output=28** — and the 4 differing rows are **this pass's own arm**
  (`a1_earl58.sv`, reached by both globs, × 2 views).  No other arm moves.  The
  2 SIGNAL rows are symmetric (both binaries, pre-existing).

---

## THE TWO EARLGREY MODES

**default** — head **46 → 29** lines, 1 head.  New R0 (`PREDICT_R0.txt`):

```
LHS(golden): logic_net (…u_dm_top.i_dm_csrs.i_fifo.rdata) id:291318
             prim_fifo_sync.sv:29:27-29:32  < module_inst work@prim_fifo_sync
RHS(ours)  : <null>          <== A MISSING OBJECT, NOT A FIELD DIFFERENCE
```

`prim_fifo_sync.sv:29` is `logic [Width-1:0] rdata;` — a module-level net golden
lists on the ELABORATED `module_inst` and we do not emit at all.  Not this
pass's family and not a regression: the object is absent on the pristine side
too, it simply could not surface while a field difference sat above it.

**testflags** — head **33 lines, UNCHANGED**: the EXTRA-OURS elaborated
localparam `i_dm_mem.DbgAddressBits` that r10earl57 left.  The only difference
between the pristine and patched cmp logs is **object ids** (237107→237109,
755745→755959), shifted by the 107 new constants.  Same cell, same family, not
this pass's.

---

## RESIDUES, RANKED (every one measured on `a1_earl58.sv`, not guessed)

* **R1 — the bit_select INDEX at d1, 1 989 Earlgrey cells.**  The biggest
  remaining block of this exact law: rv_plic_target's `gen_nodes` reads
  `is_tree[C0]` / `id_tree[Pa]` where `C0`/`Pa` belong to the enclosing
  `gen_level`.  Golden's object is the same shape this pass emits, with the
  bit_select as `vpiParent` and `INT:1 / vpiConstType 7` (a *signed* `int`
  localparam keeps its encoding — the pa-Rhs copy already gets that right).
  Blocked on elaborated-context plumbing, not on the law: those cont-assigns
  live in a FOR-generate body where `genCaLhsParamFold` is off (`blkInLoop3`)
  and `currentGenBlkScope` is never set.  Arm rows: `ca_d1_bsd`, `ca_e1_bsd`.
* **R2 — the other d1 positions** (bare operand, plain operation operand,
  replication count, comparison operand, `if` condition, `case` item, and the
  bit_select index inside a PROCESS).  Golden substitutes at all of them; **the
  Earlgrey corpus holds ZERO cells of any of these shapes with a one-hop
  gen-scope parameter**, so claiming them would be unmeasured risk for zero
  corpus gain.  Arm rows: `ff_d1_bare`, `ff_d1_opnd`, `ff_d1_rep`,
  `ff_d1_cmpo`, `295`, `296`, `298`.
* **R3 — we OVER-fold at d0 and d2 in gen-scope CONT-ASSIGNS.**
  `genCaLhsParamFold`'s nested-in-operation arm has no distance test at all, so
  `ca_d0_pslo` / `ca_d0_ipsbo` (golden `ref_obj`) and `ca_d2_pslo` /
  `ca_d2_ipsbo` fold on our side.  PRE-EXISTING, unchanged by this pass, and now
  named with a reproducing arm.  § genScopeOwnParamNoSelFold56's `directBound56`
  fence is the direct-bound half of the same rule; the nested half is missing.
* **R4 — the d0/d1 BACKWARDS family.**  net-decl-assign and var-decl-init fold
  at d0 in golden and we do not (arm rows `nd_d0_*`, `vd_d0_*`, 20 cells), and
  we fold at d1 where golden does not (`nd_d1_psld`…, `vd_d1_bare`, 5 cells).
  Decoded above: those are elaborated against the declaring scope's OWN
  instance.  r10earl56's R-V1, now with a reproducing arm and a mechanism.
* **R5 — function/task bodies at d0.**  We fold every position; golden keeps the
  `ref_obj` (arm rows 118-146, 24 cells).  `compileFunction`/`compileTask` are
  the `compileInitialBlock` case: no instance.

## THE LADDER

**Not re-run, and this pass says so rather than quoting a stale number.**
r10earl57's own LADDER57.md established that the horizon rule is not a sound
ordering bound because masking reorders the walk, and that **the whole-dump diff
is the arbiter**.  Here both arbiters are exact and agree: the census says
TO-GOLDEN=107 / AWAY-GOLDEN=0 over 489 539 keyed objects, and the whole-dump
diff contains 1 605 lines carrying one identifier.  A ladder run could not add
to that and could subtract from it by being quoted as a distance.

## FILES

| file | what |
|---|---|
| `a1_earl58.sv` | THE GRID — 468 golden cells, 3 distances × 9 contexts × 12 positions × 3 generate kinds × 5 parameter kinds |
| `grid58.py` | the grid reader: source-extent key, so a `ref_obj` and the operation that starts at its column are never merged |
| `v58span3.py` | r10earl56's deep 3-way census (calibrated gold/gold/gold before use) |
| `CENSUS_PREDICT58.txt` | the prediction, written before the patched binary existed |
| `PREDICT_R0.txt` | the next head, predicted then measured |
| `arm58.sh` / `armplain58.sh` | arm drivers, elab and plain |
| `earl58.sh` | Earlgrey_0_1/default with one binary against the immutable golden cache |
| `sweeps58.sh` / `ct8rows.sh` / `byteverify58.sh` | gates 3, 4, 5 |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary battery and its audit |
| `vbndall58.sh` | the wide boundary (975 arms, 1 950 runs) |
