# r10earl54 — § connReplFoldNested54

**Earlgrey_0_1/default's head CLEARED: the replication at
`tlul_fifo_sync.sv:76` folds, and with it 99 of them across the design — every
one landing exactly on golden, 0 moving away, 0 changed-but-still-wrong, the DEF
view byte-identical, and the new head PREDICTED IN ADVANCE down to golden's own
object id.**

Head: **82 cmp lines → 34**, 1 head → 1 head.

---

## THE HEAD (R0 of the pass, cleared)

```
LHS(golden): constant  tlul_fifo_sync.sv:76:69-76:91
             |vpiParent: operation  75:22-76:91        (the ternary)
             |vpiDecompile:00000000000000000000000000000000
             |vpiSize:32
             |BIN:00000000000000000000000000000000
             |vpiTypespec: ref_typespec
             |  |vpiFullName:work@top_earlgrey.u_rv_core_ibex.fifo_i.rspfifo.wdata
             |  |vpiActual: int_typespec            (no location)
             |vpiConstType:3
RHS(ours)  : operation  76:69-76:91  vpiOpType:34
             |vpiOperand: constant  UINT:32 size 64
             |vpiOperand: operation vpiOpType:33
                          |vpiOperand: constant 1'b0 BIN:0 size 1
```

`hw/ip/tlul/rtl/tlul_fifo_sync.sv:64-91`, the `rspfifo` connection:

```systemverilog
prim_fifo_sync #(...) rspfifo (
  .wdata ({tl_d_i.d_opcode, ... ,
           (tl_d_i.d_opcode == tlul_pkg::AccessAckData) ? tl_d_i.d_data :
                                                          {top_pkg::TL_DW{1'b0}} ,
           ... , spare_rsp_i}),
```

The replication is **two levels down**: the false arm of a ternary that is an
operand of a concat that is the actual.

## THE MECHANISM, TRANSCRIBED FROM SURELOG

`NetlistElaboration::high_conn_` (src/DesignCompile/NetlistElaboration.cpp:1333)
compiles the actual in the PARENT's scope with **`Reduce::Yes`**:

```cpp
hexpr = (expr*)m_helper.compileExpression(
    parent_comp, fC, Expression, m_compileDesign, Reduce::Yes, nullptr, parent);
```

and `CompileHelper::compileExpression` ends (CompileExpression.cpp:3648) with

```cpp
if ((result != nullptr) && (reduce == Reduce::Yes)) {
    if (any *tmp = reduceExpr(result, invalidValue, ...))
        if (!invalidValue) result = tmp;
}
```

`reduce` is threaded down every recursive `compileExpression` call — the concat
arm at :3145 and the multiconcat arm at :3172 both pass it on — so **that tail
runs at EVERY nesting level**. Any sub-expression of a connection actual that
evaluates becomes a constant, however deep. We had implemented exactly ONE
special case of that: the replication that IS the whole actual
(`ReplicationPassedToInstance`, ModuleEmit.cpp ~9891). This pass is the same
object at depth > 0.

## THE LAW

> **§ connReplFoldNested54 — a REPLICATION nested at ANY DEPTH inside an
> ELABORATED port-connection actual folds to a full-width BIN constant.**
> The constant carries the depth-0 arm's shape exactly — bare-bits
> `vpiDecompile` at the replication's own width, `BIN:` value, `vpiBinaryConst`,
> and a conn-scoped `ref_typespec` (`<this instance's path>.<formal>`) over a
> loc-less `int_typespec` — with ONE field different: **`vpiParent` is the
> ENCLOSING OPERATION**, not the port.
>
> The fence is the whole law. The SAME written replication does NOT fold in a
> cont-assign RHS, in a procedural assignment, in a parameter declaration
> initializer, or in the DEF listing's `ref_module` connections.

## THE GRID — golden vs pristine vs patched

`arm54.sh` runs BOTH sides with `-elabuhdm` / `--elabuhdm`.
**This is the pass's one methodological correction and it matters:** the first
`a1` run used `arm53.sh`, i.e. plain `-parse`, whose golden has no elaborated
netlist at all — its port HighConns come from the definition compile, which folds
NOTHING. That run read "golden does not fold" and would have killed the pass.
`Earlgrey_0_1.sl` is `+define+SYNTHESIS -f ...scr -elabuhdm -parse ...`; the
golden this head lives in is the ELABORATED one.

### `a1_earl54.sv` — where does it fold?

| cell | written, inside `.a(...)` | golden | pristine | patched |
|---|---|---|---|---|
| `u_direct` | `{8{1'b0}}` — IS the actual | `BIN:00000000` sz8 + ts | same ✓ | same ✓ (untouched) |
| `u_ter` | concat > ternary > repl | **`BIN:0000` sz4 + ts** | op34 | **matches golden** |
| `u_bin` | `d \| {8{1'b1}}` | **`BIN:11111111` sz8 + ts** | op34 | **matches golden** |
| `u_deep` | concat>ternary>binary>repl | **`BIN:1111` sz4 + ts** | op34 | **matches golden** |
| `u_pkgc` | `{pk54::W{1'b0}}`, pkg-param count | **`BIN:00000000` sz8 + ts** | op34 | **matches golden** |
| `u_nonc` | `{4{d[0]}}` NON-const body | **op34 KEPT** | op34 ✓ | op34 ✓ (abstains) |
| `u_cbin` | nested `4'h3 + 4'h1` | `UINT:4` sz4 | `UINT:4` ✓ | unchanged |
| `u_cat` | `{{4{1'b0}},{4{1'b1}}}` all-const | ONE constant, **no decompile, no ts** | operation | operation (**R1**) |
| `u_nest` | `{{2{{2{1'b1}}}},4'h7}` all-const | ONE constant, no decompile/ts | operation | operation (**R1**) |
| **C7 `assign w_ca = {sel ? d[3:0] : {4{1'b0}}, 4'h5}`** | cont-assign RHS | **op34 KEPT** | op34 ✓ | op34 ✓ **FENCE** |
| **C8 same shape in `always_comb`** | procedural | **op34 KEPT** | op34 ✓ | op34 ✓ **FENCE** |
| every DEF-listing (`ref_module`) row | | op34 kept (12 of them) | op34 (12) | op34 (12) **FENCE** |

`a1`'s cmp head is `u_cat` (R1) on BOTH binaries — unchanged, and the pass adds
no new head to the probe.

### `a2_earl54.sv` — the boundary grid (where CAN the connection put one?)

10 predicted movers, **10 turned, 0 away**; patched slot count = golden's 62 exactly.

| cell | connection shape | result |
|---|---|---|
| `u_pinit` | pkg param actual, repl in the PARAMETER'S INITIALIZER (the clkmgr shape) | folds, `BIN:1111` sz4 inside op75 — **matches golden** |
| `gen_b2[0..1].u_gen` | inside a for-generate | both fold |
| `gen_b3[1..2].u_gv` | count is the **GENVAR** | fold PER INSTANCE: gj=1 → `BIN:1` sz**1**, gj=2 → `BIN:11` sz**2**, ts `…gen_b3[2].u_gv.a` — matches golden |
| `u_arr[0..1]` | instance ARRAY, one written conn | both fold |
| `u_in_mid` | inside a submodule that also has an iface port | folds |
| `u_sys` | `4'($bits({4{1'b0}}))` — under a system call | golden folds the whole cast; unchanged, already equal |
| `u_rr` | `{2{{2{1'b1}}}}` nested repl | folds to `BIN:1111` sz4 (outer wins; inner subtree gone) |
| **`u_keep`** | `{pk2_54::N{d[0]}}` NON-const body | **op34 on all three sides** |
| `u_pat` | assignment pattern written AT the conn | unchanged (**R5**) |
| `u_povr` | repl inside a param OVERRIDE expression | unchanged |
| `gen_b11.u_cif` | inside an if-generate | folds |

### `a3_earl54.sv` — the two paths a1/a2 could not reach

The line this arm sits next to has a special case that could have made the ts
fullname wrong on exactly one shape:

```cpp
const std::string& hcPrefix =
    (!bindPath.empty() && !currentTopPrefix.empty()) ? currentTopPrefix
                                                     : parentPrefix;
```

A **`bind`ed** instance's high-conn names are TOP-scoped. This arm uses `prefix`,
not `hcPrefix`, so the bound case is measured rather than assumed:

| cell | shape | golden | patched |
|---|---|---|---|
| `u_dut.u_plain` | plain nested repl | `BIN:0000` sz4 | **matches** |
| `u_dut.u_bound` | **`bind dut3_54 probe3_54 u_bound (.pa({sel ? d[3:0] : {4{1'b1}}, 4'h2}))`** | `BIN:1111` sz4, ts `work@a3_earl54.u_dut.u_bound.pa` | **matches, fullname included** |
| `u_bufs` | **GATE form** `buf u_bufs [3:0] (gout, {4{1'b1}})` | `BIN:1111` sz4, **`vpiParent` = the `gate`** | unchanged (**R7**) |

`attrib54.py`: TO-GOLDEN 8, **AWAY-GOLDEN 0**, STILL-WRONG 0, UNMOVED-BAD 0;
patched slot count = golden's 10 exactly. `a3`'s head ADVANCES from the
`u_plain` cell (which this law fixes) to the gate-form cell, which was already
wrong and merely masked behind it.

## CENSUS: PREDICTED 99, MOVED 99

`CENSUS_PREDICT54.txt` was written from the golden + pristine pair before the
patched database existed. `census54.py` counts every
(instance, port, span) slot inside an ELABORATED port HighConn at depth > 0; its
`--selftest` asserts the a1 grid's known answers first.

| | predicted | measured |
|---|---:|---:|
| MOVERS (ours op34 → golden constant) | **99** | **99 → 0 remaining** |
| KEEP (must NOT move) | 1 | 1, still op34 |
| UNPAIRED | 0 | 0 |
| `attrib54.py` TO-GOLDEN slots | 99×4 = 396 | **396** |
| `attrib54.py` AWAY-GOLDEN | 0 | **0** |
| `attrib54.py` STILL-WRONG | 0 | **0** |
| new `int_typespec` objects in the dump diff | 99 | **99** |

The 4 slots per site are the op34 (→ constant) plus the three that VANISH (the
count constant, the inner `vpiConcatOp`, the body literal); golden has nothing at
those three spans either, which is why they count as landing on golden.

Population: **98** at `tlul_fifo_sync.sv:76:69-76:91` (the `rspfifo` inside every
`tlul_fifo_sync`) plus **1** at `clkmgr_pkg.sv:38:11-38:20`, distributed over the
top's subsystems as:

| top-level child | movers |
|---|---:|
| `u_xbar_main` | 74 |
| `u_xbar_peri` | 9 |
| `u_flash_ctrl` | 4 |
| `u_spi_device` | 3 |
| `u_hmac` | 3 |
| `u_usbdev` | 3 |
| `u_rv_core_ibex` | 2 |
| `u_clkmgr` | 1 (the `clkmgr_pkg` cell) |

The base ladder reached only 12 of the 98 before its mask/budget, which is why
the ladder family looked like 15 rungs and the census says 99: **masking an
object skips its whole subtree**, so a ladder family size is a lower bound on
its population and the census is the instrument that counts it.

The ONE cell that had to stay put:
`work@top_earlgrey.u_rstmgr.i_sys_src | rst_req_i | 149:36-149:65` —
`{PowerDomains{ndm_req_valid}}`, a non-constant body. It did.

## THE NEW HEAD WAS PREDICTED (`PREDICT_R0.txt`)

Written before the patched `cmp.log` was opened, from the base ladder alone:
rungs 26 and 60 are this law; 27–59 and 61–70 are r10earl53's already-cleared
`ref_typespec|<rhs-null>` family; so the new head must be **rung 71**.

```
PREDICTED  L(golden) int_typespec @:0:0-0:0 #288957   R(ours) logic_typespec #765149
MEASURED   int_typespec: id:288957 |UINT:1
           logic_typespec: id:771001 |vpiRange: range [0:0]
```

Right down to golden's object id (**288957**). R0 of the next pass is a loc-less
typespec KIND mismatch — golden `int_typespec`, ours `logic_typespec [0:0]` — and
has nothing to do with replication, folding, or connections.

## LADDER: which rungs this clears

MEASURED, not inferred: a FULL pristine ladder and a FULL patched ladder over
Earlgrey_0_1/default, both `--max=20000 --budget=1500`, run back-to-back and
ALONE, and joined on the GOLDEN SITE by `ladcmp54.py` (never the rung index).
The two runs reach comparable depth, which is what makes the join fair:

| | rungs | stop | secs | maxvis |
|---|---:|---|---:|---|
| pristine | 3 113 | BUDGET | 1500.2 | 610 086 / 783 183 |
| patched  | 3 103 | BUDGET | 1500.1 | 620 243 / 783 183 |

```
CLEARED (a pristine rung whose golden site is gone) = 37   ALL of one family
NEW     (a patched rung with no pristine twin)      = 26   ALL of ANOTHER family
KEPT                                                = 3036
```

**Every one of the 37 CLEARED rungs is `constant|VpiType|KIND:constant>operation`,
and that family goes 44 -> 7.** The split is exactly the census's two sites:

| site | pristine rungs | patched | this law? |
|---|---:|---:|---|
| `tlul_fifo_sync.sv:76:69-76:91` | 36 | **0** | YES — the head's site |
| `clkmgr_pkg.sv:38:11-38:20` | 1 | **0** | YES — the param-initializer cell |
| `:0:0-0:0` (loc-less) | 3 | 3 | no |
| `flash_ctrl.sv:137:18-137:30` | 1 | 1 | no — unpacked-array-of-struct ELEMENT SELECT, no replication |
| `pinmux_pkg.sv:20:32-20:39` | 1 | 1 | no |
| `alert_handler.sv:87:27-87:51` | 1 | 1 | no |
| `pwrmgr_pkg.sv:156:14-156:32` | 1 | 1 | no — the R4 WIDTH CAST, deliberately excluded |

This was PREDICTED BEFORE the patched ladder was read
(`/tmp/r10earl54_ladder_predict.txt`, reproduced in `LADDER54.md`): family
44 -> 7, tlul 36 -> 0, clkmgr 1 -> 0, and the seven survivors named. All exact.

**The 26 NEW rungs are NOT new defects.** They are all
`int_typespec|VpiType|KIND:int_typespec>integer_typespec` at
`tlul_socket_1n.sv:49:27`, a family the PRISTINE ladder already carries **333**
rungs of; the patched run carries **359**. Freed of 37 masks the patched walk
gets ~10 000 objects deeper inside the same 1500 s, so it simply REACHES 26 more
cells of a pre-existing family. Nothing changed kind that the census did not name.

> THE `15 rungs / 12 tlul` FIGURES IN THE FIRST WRITE-UP WERE WRONG. They were
> read off `tools/probe/r10ladder1repro/ladder_default_Earlgrey_0_1.txt`, which
> was taken at an OLDER BASE, and were quoted as if they described 5bd0a3a. A
> fresh pristine ladder at 5bd0a3a has 44 rungs in the family, 36 of them at the
> tlul site. The conclusion ("the tlul rungs all clear") survived; the numbers
> supporting it did not, and a ladder claim must come from a ladder run at the
> base under test.

### The 1 330-object `constant>ref_obj` family is NOT this law and is NOT taken

The brief asked whether one law answers both. **It does not, and the answer is
not a judgement call.**

> RE-MEASURED AT INTEGRATION, AND THE FIRST STATEMENT OF IT WAS WRONG. This
> family has **2 036 rungs** in a fresh pristine ladder at 5bd0a3a (the `1 304`
> above came from the older base ladder file), and it is **NOT** "every cell a
> procedural statement". Grouping all 2 036 by their last four parent kinds:
> `cont_assign < gen_scope < gen_scope_array < gen_scope` 889,
> `operation < cont_assign < gen_scope < gen_scope_array` 381,
> `gen_scope_array < gen_scope < gen_scope_array < gen_scope` 381,
> `operation < operation < cont_assign < gen_scope` 254,
> `gen_scope < gen_scope_array < …` 81 — i.e. **~1 524 are CONT-ASSIGNs inside
> generate scopes** and only **22** are the `assignment < begin < if_stmt <
> event_control` procedural shape quoted below. The quoted cell is real but it
> is 22/2036, not the family.
>
> THE CONCLUSION IS UNCHANGED and does not rest on that misread: the family
> folds a **parameter reference** (`ref_obj` → `constant`), there is no
> replication and no port-connection actual anywhere in it, and this pass's arm
> only ever rewrites a `vpiMultiConcatOp` operand reached from a port HighConn.
> The measurement that settles it is gate 5: 2 311 databases, ONE mover.

A representative cell (22 of the 2 036) is a **PROCEDURAL** statement:

```
L(golden) constant  @prim_fifo_sync.sv:131:29-131:38
R(ours)   ref_obj(PTR_WIDTH) @:131:29-131:38
PL … < operation < part_select(fifo_wptr) < bit_select(storage) < assignment
   < begin < if_stmt < event_control
```

`storage[fifo_wptr[PTR_WIDTH-1:0]]` inside an `always` block: golden folds a
**parameter reference** in a part-select bound. There is no replication and no
connection actual — the context is one this law's fence measurably EXCLUDES
(cell C8). Rggen is untouched by this pass.

## ONE DELIBERATE DIFFERENCE FROM § connPathRootTs53'S FENCE

`bindConnPathRootTs53` collects its hier_paths FIRST and returns without
building its name map when there are none — a fence, not an optimisation,
because forcing slang's LAZY type resolution earlier than the emit chain
otherwise would REORDERS later objects, and earl53's byte verifier caught exactly
that on two rows.

`foldConnReplNested54` does NOT have the mirror-image fence: it visits the
connection expression (and referenced parameters' initializers) before looking
for a multiconcat in the UHDM tree. That ordering is deliberate and its safety is
MEASURED, not assumed:

* it touches `getInitializer()`, not `getDeclaredType()->getType()`, and the
  post-pass runs AFTER the actual has been emitted — which already required that
  initializer — so nothing is forced earlier than the emit chain forced it; and
* **gate 5 is the proof**: 2 311 databases byte-compared, **exactly ONE mover**,
  and it is `default/Earlgrey_0_1`, the single row this law names. A reorder would
  have shown up as movers on rows with no replication in them at all, which is
  precisely how earl53's was found.

Adding the fence anyway would be free at runtime but would invalidate all five
gates and require the full sweep round again for zero measured change, so it is
recorded here rather than guessed at. It is the obvious first edit for any pass
that touches this helper for another reason.

## THE PLAIN (NON-ELABORATED) VIEW: MEASURED AT INTEGRATION, AND THE FIRST
## STATEMENT OF IT WAS BACKWARDS

`arm54.sh`'s header says a plain `-parse` golden's port HighConns "come from the
DEFINITION compile — a DIFFERENT code path that folds NOTHING". **That is false
as written, and the wide boundary sweep is what exposed it**: `a1`/`a2`/`a3`
differ between the two binaries in the `plain` view as well as the `elab` one, so
the arm demonstrably fires without `--elabuhdm`.

What a plain golden actually contains for `a1_earl54.sv` is BOTH listings —
**187 `module_inst`** objects and **40 `ref_module`** objects (our output: the
same 187 / 40) — and they answer differently:

| plain-golden listing | nested replication in a port HighConn |
|---|---|
| `ref_module` chain (the DEFINITION listing) | **op34 KEPT** — this is the real fence, and the earl38 byte fence |
| `module_inst` chain | **FOLDED**, exactly as in the elaborated view |

So the discriminator was never "elaborated vs plain". It is **`module_inst` vs
`ref_module`**, and `census54.scan` had it right all along by excluding
`ref_module` chains and the `uhdmallModules` subtree. The Earlgrey DEF view being
byte-identical (1 046 523 lines, md5 `3694eca02c308c3419cb5ae30405f505` on both
binaries) is the same fact measured on the corpus.

The correction MATTERS because it changes the sign of the plain view. A
three-way span-keyed check against a freshly built plain golden, counting
PRISTINE-RIGHT -> PATCHED-WRONG cells (the only class that is a regression):

| arm | golden slots | pristine | patched | FIXED | **BROKE** | reshaped |
|---|---:|---:|---:|---:|---:|---:|
| a1 plain | 27 | 57 | 33 | 28 | **0** | 3 |
| a2 plain | 64 | 96 | 63 | 43 | **0** | 0 |
| a3 plain | 10 | 16 | 10 | 8 | **0** | 0 |
| a1 elab | 27 | 55 | 31 | 28 | **0** | 3 |
| a2 elab | 62 | 95 | 62 | 43 | **0** | 0 |
| a3 elab | 10 | 16 | 10 | 8 | **0** | 0 |

**BROKE = 0 in BOTH views on all three arms**, and the plain view gains 79 slots
to golden rather than losing any. The 3 "reshaped" cells are R1 (`u_cat`,
`u_nest`): golden has NO slot at those spans because it folded a WIDER
expression, so both our sides are unequal there and the patch changes one wrong
answer for another — the earl52-F2 ranking, not a regression.

The over-fire guard was checked the same way, three-way, on the two
non-constant-body cells:

```
a1 u_nonc {4{d[0]}}  50:38-50:47   golden=multiconcat pris=multiconcat pat=multiconcat
a2 u_keep {N{d[0]}}  76:49-76:66   golden=multiconcat pris=multiconcat pat=multiconcat
```

## RESIDUES

* **R1** — a WHOLLY constant-foldable conn actual folds to ONE constant in
  golden with **no `vpiDecompile` and no `vpiTypespec`** (a1 `u_cat` →
  `BIN:00001111` sz8; `u_nest` → `BIN:11110111` sz8). A different shape from this
  law's; measured on two probe cells only, both of which were unequal BEFORE this
  pass. Folding their nested replications leaves them unequal in a new way, which
  per earl52-F2's ranking is not a regression — no corpus row that WAS equal is
  involved, and the corpus gates confirm it.
* **R4 — the next step, fully characterised.** `Reduce::Yes` folds every
  sub-expression, not only replications. Earlgrey's remaining slot-space kind
  mismatch is exactly one: `work@top_earlgrey.u_pwrmgr | pwr_peri_i |
  156:14-156:32`, `pwrmgr_pkg.sv:156 wakeups: WakeUpPeris'(1'b1)` — a **WIDTH
  CAST**. Golden's folded constant there is `vpiSize:16`, `UINT:1`,
  `vpiConstType:9`, and **no `vpiDecompile`, no `vpiTypespec`** — a DIFFERENT
  shape from the replication's. Extending this arm to casts without measuring
  that would have turned a wrong-KIND residue into a wrong-VALUE one, so the arm
  is deliberately Replication-only.
* **R2** — the pre-existing depth-0 arm's `ref_typespec` VpiFullName is one
  component short of golden's (`hcPrefix`, the parent path, where golden uses the
  instance's own path: `work@a1_earl54.a` vs `work@a1_earl54.u_direct.a`).
  `ref_typespec::Compare` reads VpiName + VpiDefName + Actual_typespec and NOT
  VpiFullName, so it is cmp-invisible. Left alone on purpose; the NEW site uses
  `prefix`, which is golden's.
* **R3** — nested conn-actual `ref_obj` VpiFullNames are unscoped on our side
  (`work@a1_earl54.sel` vs golden `work@a1_earl54.u_ter.a.sel`); the existing
  scoping loop covers DIRECT concat operands only. Also cmp-invisible.
* **R5** — `.p('{hi: {4{1'b1}}, lo: 4'h6})`: golden keeps the pattern's operands
  as two constants; our conn arm folds the whole pattern to one based-decimal
  constant, so those slots do not exist on our side. Pristine == patched.
* **R7** — a **GATE / UDP-form** instantiation's actual
  (`buf u_bufs [3:0] (gout, {4{1'b1}})`, a3): golden folds the replication to
  `BIN:1111` sz4 with **`vpiParent` = the `gate`**, and reaches it through
  `NetlistElaboration`'s `bitBlast` (the `paNet_lvalue` branch), not
  `high_conn_`. A different code path on both sides; this arm hooks module_inst
  ports only and correctly abstains. It is a3's new head and was already wrong
  before, merely masked behind the `u_plain` cell this law fixes.
* **R6** — `gen_b3[N].u_gv | a | 56:42-56:46` (`d[7-gj:0]`): golden folds the
  genvar arithmetic in a part-select bound to a constant, we keep an operation.
  A different law (and R4's family). Pristine == patched.

## PRE-EXISTING CRASHES, PROVEN SYMMETRIC

The wide boundary sweep's first run reported `signal rows: patched=4
pristine=0`, which reads exactly like four crashes introduced here. It was an
INSTRUMENT DEFECT: the side loop `break`ed when side A failed, so the pristine
side of those arms was never run. Fixed in `vbndall54.sh` (both sides always
run) and measured directly:

```
pris c3_iface    rc=139        pat c3_iface    rc=139
pris v3_boundary rc=139        pat v3_boundary rc=139
```

`tools/probe/r10uvm67repro/{c3_iface,v3_boundary}.sv` segfault on BOTH binaries.
Pre-existing, symmetric, not this pass's.

## FILES

| file | what it is |
|---|---|
| `arm54.sh` | arm driver WITH `-elabuhdm` on both sides (see the warning above) |
| `a1_earl54.sv` | the law grid: 12 contexts, including the two counterexamples |
| `a2_earl54.sv` | the boundary grid: 11 connection shapes |
| `a3_earl54.sv` | the bind path and the gate/UDP path |
| `grid54.py` | per-(instance, port) HighConn extractor; refuses the DEF listing |
| `census54.py` | the population instrument, with `--selftest` |
| `attrib54.py` | pristine→patched mover attribution joined against golden |
| `CENSUS_PREDICT54.txt` | written before the patched database existed |
| `PREDICT_R0.txt` | the new head, predicted before `cmp.log` was opened |
| `earl54.sh` `sweeps54.sh` `ct8rows.sh` `byteverify54.sh` `canaries.sh` `canaudit.sh` `ctcan2.sh` `rowheads.sh` `varm.sh` | carried-forward harness |
| `vbndall54.sh` | wide boundary sweep, both views, symmetric sides |
| `ladcmp54.py` | ladder before/after joined on the GOLDEN SITE, never the rung index (removing one head renumbers every rung after it) |
| `LADDER54.md` | the ladder prediction + the measured before/after it was held to |
| `plainreg54.py` | three-way span-keyed PRISTINE-RIGHT -> PATCHED-WRONG counter; the instrument behind the plain-view table |

## GATE RESULTS (all five, exact numbers)

| gate | measurement | result |
|---|---|---|
| 1 build | both binaries, `-j 2`, md5 separately | pristine `7ce3130a87d5b31d4d167a3e82d7bbb0`, patched `ee002f2dc03e36e0b7cb9eda01a78819` |
| 2 goldens | `tests/check_goldens.sh` | patched **23 PASS / 0 FAIL**; pristine 23/0; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (the negative control) |
| 3 u2r | `ct8rows.sh`, baseline FIRST | baseline vs pristine **0 differing rows**; baseline vs patched **0**; pristine vs patched **0**. Status **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** unchanged in both modes; dump column unchanged |
| 4 surelog | `--mode` default + testflags concatenated, 1588 rows | baseline vs patched **0 differing rows**; baseline vs pristine **0**; pristine vs patched **0**. `PASS: every row byte-identical to the committed baseline` |
| 5 byteverify | `SELFCHECK=1 SELFCHECK1=1` | u2r 1358 paths, **0 movers**; surelog 953 paths, **1 mover** = `./default/Earlgrey_0_1-71da2fd7/slang.uhdm`. Controls: SELFCHECK 1357/1358 and 952/953 flagged; SELFCHECK1 = 1 and 2 |

`Earlgrey_0_1/testflags` is `SLANG_REJECT` and has no database, which is why the
surelog mover count is 1 and not 2.

**Canaries**: `canaries.sh` 52 rows OK / 0 changed / 0 absent on the surelog CSV
and 8/0/0 on the u2r CSV; `ctcan2.sh` 58/0/0 and 1/0/0; `canaudit.sh`
`audited=29 UNCOVERED=0 FENCE-BREACH=0` — UnsignedParam, HierPathEval,
FileLocalParam and TopParam dispatched by no driver here. `InterfaceModPort`,
`BlackParrotComplex`, `YosysOldOr` and `SVSwitch` all at baseline.

**Wide boundary** (`vbndall54.sh`): 769 arms × 2 views = **1538 runs, 1514
identical, DIFFERING = 6** — and all six are `a1_earl54.sv`, `a2_earl54.sv` and
`a3_earl54.sv`, this pass's own grid arms, in both views. Nothing else in the
entire probe corpus moved.

> RE-MEASURED AT INTEGRATION. The first sweep read `768 arms / 1536 runs /
> DIFFERING = 4` because it was run BEFORE `a3_earl54.sv` existed, so the arm
> this pass added last was never swept. The corrected run above includes it.
> A sweep whose corpus predates the files under test undercounts by exactly the
> arms it cannot see, which is indistinguishable from those arms not moving.

**Determinism**: the patched Earlgrey database re-runs to the same md5
(`29794f8bda099c1d09cecd74e809bf34`, matching the sweep's mover), so the 34-line
head and the 99 movers are not a coin.

**DEF view on Earlgrey**: `uhdmallModules` subtree, 1 046 523 lines,
md5 `3694eca02c308c3419cb5ae30405f505` on BOTH binaries — byte-identical.

**The `setLoc` refactor is proven behaviour-preserving by gate 5**: extracting
`locLineCol` touches the span arithmetic of every object in the exporter, and
2 311 databases came back with exactly one mover, the row the law names.
