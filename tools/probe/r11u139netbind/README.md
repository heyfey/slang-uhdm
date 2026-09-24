# r11u139 — net binding: which net object an elaborated reference names

Analyst pass on the fourth-edition strict map (tools/probe/r11u138map): the net-binding clusters N0006, N0021, N0022,
N0023 and N0046 (pass 131's residue R1), plus N1098. Base 53471a35. **No src/ edit ships.** The law is delivered
as `law.patch` (a `git diff` of src/ and include/ against 53471a35; it applies clean), scratch-verified with the
full `tests/sweep.sh`.

## 1. The clusters at 53471a35 (question 1)

`evidence/q1_records.txt` holds `uhdm-strictcmp --max 50 --dump-a/--dump-b` for the example rows, with each
differing record's parent chain. The record list shows the binding through the walk: the listener visits an
object once per design section, so a reference whose Actual is the **definition's** net expands that net as a new
subtree under the `ref_obj` (the definition listing is a different section). A reference to the **elaborated**
net, already listed under the `module_inst`, expands nothing.

| cluster | example row | golden | ours |
|---|---|---|---|
| N0006 | u2r ParameterColonReference `assign a = pkg::A[0]` | record 51: `logic_net a` (depth 4) expanded under the Lhs `ref_obj`, which means the DEFINITION net | the elaborated net (no record) |
| N0046 | u2r cdc_static_basic `wire [3:0] gated_data = src_data;` | the elaborated net (no record) | record 102: `logic_net src_data` (depth 4) expanded, the DEFINITION net |
| N0022/N0023 | u2r sva_value_change_changed `default clocking @(posedge clk)` | record 108: `logic_net clk` (depth 6) under clocking_block/event_control/operation/ref_obj, the DEFINITION net | the elaborated net. Record 132 is ours-only: the `always @(posedge clk)` reference now expands the definition net first |
| N0021 | u2r dff_different_styles `dffsr2_sub uut (clk, preset && !clear, ...)` | `ref_obj preset` full name `work@dffsr2.uut.preset.preset` plus the DEFINITION net expanded | `work@dffsr2.preset`, elaborated net |
| N0006/port | u2r wandwor `.I0({A, B})`, param_type_logic_width `.d_i({a, b})` | concatenation operands name the DEFINITION net | elaborated |
| N1098 | surelog PortExpr `module top(.op({\op[79] ,\op[78] }))` | the low-conn concatenation operands name the DEFINITION net, and the escaped-name span ends at 4:23 | elaborated net, span 4:11-5:3 |

`drivers/refbind.cpp` (pass 131's driver, extended to the select kinds and to print the Actual's own location and
typespec presence) lists, for every elaborated `ref_obj`/select, whether its Actual is a definition-listing object
(DEF) or an elaborated one (ELAB). `evidence/refbind_pristine_67rows.txt` is its golden/ours diff on the 67
row-modes of the clusters at 53471a35 (produced before the select-kinds extension).

## 2. The decode (question 2)

These rows are `-parse` databases with no `-elabuhdm`, so no UHDM ElaboratorListener pass runs. Every Actual is
therefore the one Surelog's compile, netlist elaboration and writer leave behind. Three mechanisms decide it
(paths under third_party/Surelog/src):

* **Compile-time binding.** `CompileExpression.cpp`: every reference creation site (for example the
  `slStringConst` case, `compileExpression` around line 5815, and the primary-literal case around line 3006) binds
  with `if (pexpr) bindVariable(component, pexpr, name) ... else if (instance) bindVariable(component, instance, name)
  ... else component->needLateBinding(ref)`. The instance overload (`CompileStmt.cpp`
  `CompileHelper::bindVariable(DesignComponent*, ValuedComponentI*, ...)`) searches that instance netlist's
  `nets()` and `variables()` as they stand **at that moment**, and never its `array_nets()`. The scope overload
  walks the parent chain of `pexpr`. The operation it is handed has no parent yet, so it finds nothing, and
  the reference goes to late binding. `UhdmWriter::lateBinding` later resolves it against the **definition**
  module. The binary case (`case paExpression`, around line 2277) compiles the LEFT operand with the caller's
  `pexpr` (`opL = compileExpression(..., pexpr, instance)`) and every other operand under the new operation. A
  ternary's condition is that left operand. A unary operator, a concatenation, a call or a cast compiles its
  operands under itself. A bit-select's index takes the select's own `pexpr`; an indexed part-select's does not
  (grid n31). Result: when an expression is compiled with no parent, **exactly one leaf** binds the instance:
  the one reached through left operands, ternary conditions and bit-select indices. Every other reference
  names the definition's net or variable.
* **Net-declaration assignment** (`NetlistElaboration::elabSignal`, around line 2207): `exprFromAssign_` compiles
  the initializer with `pexpr = nullptr` and the instance. The instance netlist holds only the signals the signal
  walk has elaborated so far (`elab_ports_nets_`, pass 1 over `getSignals()`): the ANSI ports, then body
  declarations in source order. A non-ANSI port declared by its port declaration alone (`input p;`,
  `input wire p;`) is not there yet (grid n11/n24/n25). With a body `wire p;` declared earlier, it is (n23).
* **Port-connection actual** (`NetlistElaboration::high_conn_`): a named or ordered connection list is compiled by
  `compileExpression(parent_comp, fC, Expression, ..., Reduce::Yes, nullptr, parent)`. The parent's netlist is
  complete by then, so the leftmost leaf binds the parent instance's net (grid pc25: a non-ANSI parent with no
  wire declaration still binds). A **udp-shaped** instantiation (`udpShapedInstantiation`: an ordered list of two
  or more terminals whose first is a `net_lvalue`, with at most a delay2-shaped `#(...)`) goes through the
  `Net_lvalue` loop, which compiles every non-identifier terminal under the port (`pexpr = p`). There no leaf
  binds the instance (dff_different_styles, pc19/pc23/pc24/pc29). Nothing on either path sets the reference's
  `VpiFullName`, so its full name is the parent chain's: `<parent>.<instance>.<formal>.<name>` at any depth.
* **Explicit continuous assignment** (`UhdmWriter::writeCont_assign`): the netlist's cont_assigns are the
  DEFINITION's objects. The writer re-points a plain-name Lhs at the instance's variable
  (`bindVariable(mod, m, name)` over the written `module_inst`'s Variables and Nets) **only** inside its
  `rhs->UhdmType() == uhdmoperation` case. Every other right-hand side either keeps the definition object or gets
  a context-free clone of it (`ElaboratorContext(&s, false, true)`: the reduce-to-constant case, the unsized case,
  the delay case). `ref_obj::DeepCopy` copies the Actual, and `bindAny` has no instance on its stack. So the Lhs
  names the DEFINITION net for a literal, a reference, a parameter, an element or member select of a parameter,
  or a function or system call. An operation onto an unpacked array net finds nothing in `Nets()` and keeps the
  definition net too (array_assign). An operation onto an implicit net dropped from the elaborated instance does
  the same (c23). An implicit net that a port connection created is in the instance, and rebinds (mriscv
  `done_exec`).
* **Clocking blocks** (`UhdmWriter::writeInstance`, the `getClockingBlockMap` loop): every clocking block,
  whether default, global or named, is `clone_tree(cblock.getActual(), ElaboratorContext(&s, false, true))` of the
  definition's block. The context-free clone keeps the definition's Actuals, so the event names the DEFINITION's
  net in every instance, whatever the net's kind (a `logic` variable clock names the definition's `logic_net`, k06)
  and under a parameter override (k05). This is the same shape § the global clocking block already modelled.

## 3. The grid (question 3)

98 cases under `cases/{ca,nda,clk,pc}/`. Goldens come from the pinned Surelog with the probe flags
(`drivers/grid.sh`: refbind diff, uhdm-cmp line count and uhdm-strictcmp verdict per case). The table is
`evidence/grid_pristine_vs_law.txt`.

* `ca` (23): explicit assign × right-hand side kind: literal, reference, binary, unary, concatenation, ternary,
  cast, parameter, package-parameter select, struct-parameter member, `$clog2`, `$signed`, function call,
  bit-select, unbased literal, a folding parameter operation, a logic variable Lhs, an `output int` Lhs, an
  implicit Lhs, a bit-select Lhs, a submodule, a body wire.
* `nda` (32): net-declaration assignment × leaf position and kind: reference, binary, unary, concatenation, ternary,
  parenthesis, three leaves, replication, parameter first, delay, bit-select, indexed part-select, memory index,
  select-index operation, logic variable, driven and undriven `reg`, ANSI and non-ANSI ports (wire before, wire
  after, `input wire`), a submodule, a chain of body wires, multi-declarator.
* `clk` (10): default (unnamed and named), named regular, global, submodule with parameter overrides, a logic
  variable clock, a body-wire clock, clocking with io declarations, `or` event, SVA consumer.
* `pc` (33): connection by name, position, wildcard and implicit name × operand kind: binary, concatenation, unary,
  ternary, bit-select, select index, three leaves, same-name and cross-name nets, a nested parent, a body wire, a
  logic variable, a non-ANSI child or parent, a parent array net, a generate scope, udp shapes (identifier,
  concatenation or bit-select first; `#(1)`; `#(.W(1))`).

Pristine → law: **50 cases STRICT_NOTEQUAL → STRICT_EQUAL**. The 37 cases that were already STRICT_EQUAL stay
equal (these are the controls). 9 cases are NOT_EQUAL at stage 1 before and after, with identical uhdm-cmp line
counts (these are pre-existing positional-operation and named-clocking shapes: pc03/04/17/22/28/30, k03, k08,
c21). 2 residues remain (pc31 bit-select span, pc33 whole-select index full name). `R11U139_OFF=1` gives
byte-identical databases to pristine on all 98 cases that export. Each single switch changes exactly its own
road's cases.

## 4. The law (question 4): `law.patch`, four switches plus the master `R11U139_OFF`

| road | law | switch | site |
|---|---|---|---|
| (a) explicit assign Lhs | § caLhsDefNetUnlessOpRhs139: a plain-name Lhs names the instance net only when the DEFINITION listing's Rhs is an `operation` AND the Lhs is in the elaborated net map as a non-`array_net`. Otherwise it names the definition's object (`defView139`, matched by symbol, else by name and declaration location). This rule only turns ELAB into DEF, never the reverse | R11U139_CA_OFF | ModuleEmit.cpp emitContAssigns, the Lhs `lhsMap` site |
| (a') net-declaration Rhs | § ndaLeftmostLeafElab139: every Net/Variable reference names the definition's object, except the leftmost leaf (through BinaryOp left, ConditionalOp condition, ElementSelect selector over a named base). That leaf names the instance's object when it is an ANSI port, or a body declaration located before the declarator, and is not an `array_net`. It is re-dispatched by `emitExpr` (`nb139Leaf`/`nb139LeafMap`) | R11U139_NDA_OFF | ModuleEmit.cpp emitContAssigns, the net-declaration loop; ExprEmit.cpp emitExpr entry |
| (b) clocking event | § clockingEventDefNet139: the elaborated default clocking block's event binds the definition's nets (`defView139(topNets, def nets)`), as the global block already does | R11U139_CLK_OFF | ModuleEmit.cpp, the elaborated `emitScopeClocking` call |
| (c) connection operands | § connLeftmostLeafElab139: inside an OPERATION actual, every `ref_obj`, bit-select and part-select takes the full name `<parent>.<instance>.<formal>.<name>`. Walking the operands and bit-select indices, every reference except the leftmost leaf (none in a udp-shaped instantiation) is re-pointed from the parent's elaborated object to its definition object. Binding is at module scope only; in a generate scope only the name changes | R11U139_PORT_OFF | ModuleEmit.cpp emitInstance, after the concatenation full-name rule |

`R11U139_TRACE=1` prints every decision (`R11U139CA`, `R11U139NDA`, `R11U139PORT`).

## 5. Measurements (binary with law.patch applied; the pristine build is byte-identical to the main tree's, md5 c7b333fcf978)

Full `tests/sweep.sh --jobs 3` with the law binary, against the committed baselines (`evidence/sweep_law_vs_baselines.txt`):

* **probe**: regressions=0, conversions=14, changes=17 (EQUAL 2112 → 2126). Every change was checked with refbind:
  each moves the bindings toward golden. The larger strict counts (v3_v54 col 70→132, a3_inst66 endcol 4→12) come
  from the walk staying aligned further, because the refbind distance is equal or smaller.
* **surelog**: regressions=0, **conversions=9**: BitsArray d/t, Moves d, PackStructField d, PackageParamConst d,
  YosysOldSimpleSpi d/t, YosysOldSpi d/t. There are 10 changes (DelayAssign d, YosysBigSimEllip d, YosysBigSimReed
  d/t, YosysOldOpen d/t, YosysOldOr d/t, YosysRiscv d/t). In every one the refbind binding flips drop to 0,
  except Ellip, where 136 remain, see §6.
* **uhdm2rtlil**: regressions=0, **conversions=36** (18 tests × both modes): AssignBitsCallToSubmoduleParameter,
  Clog2OfSumWithParameterIn2InstancesOfSubmodule, ParameterColonReference, StructLocalParam, StructParameter,
  cdc_static_basic, dff_different_styles, param_type_logic_width, partsel_simple, sva_counter, sva_range,
  sva_throughout, sva_value_change_changed, sva_value_change_changed_wide, sva_value_change_rose,
  unbased_unsized_param, vector_index, wandwor. There are 4 changes (rsp_gen_minimal d/t fullname 166→165,
  struct_param_pattern_packing d/t endcol 4→3). Fresh rows: `evidence/fresh_*_converted_rows.csv`.
* **downstream**: EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66, 0 not excused. Verdict column identical to
  results/downstream_uhdm2rtlil.csv row by row. All 18 converted u2r tests read IDENTICAL
  (`evidence/downstream_target_rows.txt`).
* Every probe case stays uhdm-cmp equal. No corpus row changes its uhdm-cmp status. The non-judge-equal rows'
  csv text differs from the own-pristine sweep only in the LowMem workdir-path detail.
* Own pristine sweep (same worktree, same env): regressions=0 conversions=0 changes=0 in both corpora.
  `sweep.sh` exits 1 in both runs only because `law_index.py --check` reads tests/LAWS.md STALE. That is already
  true at 53471a35 in the main tree.
* **Per road** (each switch off alone, `evidence/single_switch_rows.txt`). CA: Clog2OfSum, ParameterColonReference,
  StructLocalParam, StructParameter, unbased_unsized_param (both modes), PackageParamConst d, PackStructField d,
  12 row-modes in all. NDA: cdc_static_basic, partsel_simple, vector_index (both), Moves d, 7, plus
  YosysOldSimpleSpi d/t shared with PORT. CLK: the six sva tests × 2 = 12. PORT: AssignBitsCall, dff_different_styles,
  param_type_logic_width, wandwor, BitsArray, YosysOldSpi (both) = 12, plus YosysOldSimpleSpi d/t. Total 45.
* **Byte movers** (`evidence/byteverify_*.txt`, SELFCHECK 959/960 and 1607/1608, path sets identical): surelog
  43/960, uhdm2rtlil 44/1608. The prediction came from the PRISTINE databases (`drivers/predict.sh` +
  `drivers/predflip.py`: rows whose golden/ours refbind diff has a binding flip or a full-name difference, 241 rows,
  `evidence/predicted_pristine_bindflips.txt`). 80 of the 87 movers are in it. The 7 others are attributed in
  `evidence/unpredicted_movers_attribution.txt`:
  * MiniAmiq d/t: the known UVM 4-line UINT/decompile coin.
  * Five `-elabuhdm` testflags twins, whose pristine refbind was already 0 because our elaboration step re-binds.
    DelayAssign, Moves and PackageParamConst have an identical uhdm-dump (serialisation only). PackStructField's
    weakly-referenced Lhs now names `logic_net` exactly as golden's does. ExplictiPorts' bit-select full name is now
    `work@test.a4.a.a` as in golden. Each strict-equals its pristine database.

  Binding census over every corpus row (golden vs ours refbind): pristine 1122 binding flips in 92 row-modes; law
  223 in 30 row-modes. No row has more (`evidence/law_bindflips.txt`).
* Canaries (law vs own pristine csv): surelog ok=46 changed=6 (YosysOldOr, YosysBigSimReed, YosysOldOpen d/t, all
  predicted); u2r ok=16 changed=0; ctcan2 PASS (EXPECT_UNKNOWN=1 / 6).

## 6. Residues (ranked by binding flips left, `evidence/law_bindflips.txt`)

1. **UDP shape with a concatenation as the first terminal**: YosysBigSimEllip, 136 flips
   (`f3_add a142 ({w13[0], w13[1]}, w135, w141)`). Golden binds even the plain-identifier terminals to the DEFINITION
   net, with the port-chained full name. Ours keeps `bind_net_`'s instance net. Grid pc28 is NOT_EQUAL at stage 1
   on this shape at the base, so the fix belongs with that stage-1 difference.
2. Earlgrey_0_1 testflags, 24: parameter references in cont_assigns under deep instances (ELAB/DEF parameter), and
   a genvar `i` bound to a parameter versus an int_var. These are not net bindings.
3. **Explicit port expressions** (`module c(.a({a,b}))`, the low-conn side): ExplictiPorts d (2) and PortExpr
   (N1098). Golden binds the concatenation operands to the definition net. PortExpr also has an escaped-name span.
4. ibex_compressed_decoder (7, function-local part-select versus logic_var), typed_named_pattern (5, param_assign
   operation operands bind DEF in golden), type_param_unpacked_port (4, array_net versus element struct_net),
   StringMethod, SVSwitch (modport), MultirangesStartNotFromZero, HierPathVarArray, UnionParameter, array_assign
   (`pa` var_select), rsp_gen_minimal (struct_var versus logic_net under a port), InterfaceModPort/OneNetModPort,
   UnsizedParam, InterfArrayBind, UnpackPort: 1-7 each, each its own shape.
5. Grid pc31 (the udp first terminal's bit-select span covers the whole `v[0]`) and pc33 (a whole bit-select actual's
   index reference is named `<parent>.<instance>.<name>`).

No road copies an object golden holds once. The only new objects are the `NetMap` copies (`defView139`), which
are lookup tables, not UHDM objects.

## 7. Files

* `law.patch`: the src/include diff against 53471a35.
* `cases/`: 98 single-file probe cases (the grid).
* `drivers/`: `refbind.cpp` + `cc.sh`, `grid.sh`, `predict.sh`, `predflip.py`.
* `evidence/`: every measurement quoted above.
