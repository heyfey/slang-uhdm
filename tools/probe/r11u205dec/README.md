# r11u205dec: map 12's ground-B heads and families decoded and scratch-verified (analyst pass, measurement only)

**Base.** `3668bf30` (branch matrix-1.87: passes 201 and 202 and the r11u204 verification landed). Nothing under
`src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited by this directory; the laws are delivered as two
ground patches for the pairs to land:

* [law_typeemit.patch](law_typeemit.patch) (ground B: TypeEmit.cpp, ModuleEmit.cpp, UhdmExporter.cpp; 394 added lines),
* [law_exprstmt.patch](law_exprstmt.patch) (ground A: ExprEmit.cpp, EmitHelpers.h; 140 added lines).

Each applies clean on a fresh `3668bf30` alone and after the other; together they reproduce the measured law source
byte for byte (section 1). A probe case is called a case throughout. The four slang-fenced tests are never named here;
every driver reads them from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed (section 9).

## 0. Verdicts (per cluster family)

| family (map 12 cluster) | rule golden follows | law, ground | row-modes converted | cases | away census |
|---|---|---|---|---|---|
| arb_idx_cast's last cluster (N0090) | writeNets' end-only populate moves the SHARED type-parameter default object; a cast to the type parameter and an unpacked-array element read that object | law tpDefaultUseCastAndArrayElem205, B | **arb_idx_cast d/t** | grid TP t02 (2 views), 2 scratch copies of the corpus shape | 0 lost |
| Earlgrey_0_1's head (N0945) | a generate-scope instance's hier_path port actual: the TRAILING bit_select sits at its index and stores no full name; its index reference reads the chain through the path | law genConnTrailSelChain205, B | none (Earlgrey d/t `fullname(76)` -> `endcol(46)`: all 30 head records) | grid GS: 14 case-views | 0 lost |
| Rggen's head (N1249) | a definition-view generate assignment TARGET's indexed part select is named by compilePartSelectRange: VpiDefName = the field, no stored full name | law defGenTargetIpsDefName205, B | none (Rggen d `defname(142)` -> `file(4)`) | grid IP: 10 case-views | 0 lost |
| N1899 + N0094 (probe-only, 51 cases) | a non-ANSI interface port is typed from its PORT DECLARATION (keyword or first dimension through the last dimension) | law ifacePortDeclTsAtPortDecl205, B | none (probe only) | **20 probe conversions** (of the clusters' 51 cases; the other shapes, e.g. law pkgTdOfNamedDimsListing111's and defPkgMemberTdOfNamedShares108's 8 cases, are other writers), 3 closer | 0 lost |
| UnitElabBlock (N0016 / N0011) | the implicit net minted for a Verilog-mode hidden block `logic` is a late-binding mint: no file | law hiddenBlockVarNetNoFile205, A | **UnitElabBlock d/t** | - | 0 lost |
| InterfArrayBind d (N0427) | a target's base-select index stores no name in the parse form when the right side is a literal (nothing to bind) | law elabIfArrIdxChainName205, A | none (`fullname(3)` -> `fullname(1)`) | grid IA: 2 case-views | 0 lost |
| B3 (r11u204 N1): named / empty-slot omission | compileTfCallArguments fills every missing formal with `INT:0` (size 64, vpiIntConst); evalFunc binds them and FOLDS | decoded, grid B3; **no law** (section 4.1) | - | - | - |
| N5 (default item only), N7, N8, N9 | see section 4 | decoded / re-measured, no law | - | - | - |
| the scalar-typedef formal writer (BuildUVMPkg #3245, MiniAmiq #899's family) | a formal typed by a bare SimpleType / enum typedef RE-LOCATES the typedef's shared typespec to its own type token (last writer wins) | decoded, grid FT; **no law** (section 4.3) | - | - | - |

**Conversions: 4 corpus row-modes (arb_idx_cast d/t, UnitElabBlock d/t) and 20 probe cases, with 0 regressions in
every stage.** The corpus scoreboard moves from surelog 922 + 32 / uhdm2rtlil 1594 + 12 to surelog 924 + 30 /
uhdm2rtlil 1596 + 10; probe 3363 + 724 -> 3383 + 704. Downstream 803/66/2/0 unchanged (csv verdict-identical).

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u205_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `d27bb984d49f6d31eb76cd00e98e517f` | worktree `/tmp/wt_r11u205` at `3668bf30`, system-deps config (`-j 2`, then `-j 1` after an OOM kill, a retry): **byte-identical to the main tree's `build/slang-uhdm`** |
| `law9.bin` | `2d4300a846b85c32bc21e61f61939914` | `3668bf30` + both patches (the source `diff -r` equals `law_typeemit.patch` + `law_exprstmt.patch` applied to a fresh `git archive 3668bf30`) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's `build/uhdm-strictcmp` (not edited: no comparator defect found) |
| `lawB.bin` / `lawA.bin` | `675530df0203...` / `380f74384926...` | `law_typeemit.patch` alone / `law_exprstmt.patch` alone on a fresh `3668bf30` (worktree `/tmp/wt_r11u205B`, `-j 1`): section 8 |
| `law1.bin` .. `law8.bin` | (development) | the laws as they were written and refined; section 6 names the two refinements the sweeps forced (law6 -> law7 -> law9) |

Every `slang:` line of the sweeps' `cmds.txt` names its frozen binary by path (section 5). Drivers: [drivers/](drivers)
(`env.sh` the pins and the fence; `case.sh` one case, both views, goldens cached per text hash; `grid.sh` every case
with two binaries and the `R11U205_OFF` byte check; `heads.sh` the strict records of every `STRICT_NOTEQUAL` row-mode;
`probestrict.py` the same for the 724 probe cases; `census.sh` the firing census (the mover predictor); `away.py` map
12's away-moved-record census; `dsfaces.py` the downstream faces; `det.sh` the determinism control).

## 2. The fail list at the base (`3668bf30`)

[evidence/heads_base/](evidence/heads_base) holds `uhdm-strictcmp --max 60` of every `STRICT_NOTEQUAL` row-mode of the
committed baselines (44 row-modes, 32 surelog + 12 uhdm2rtlil, all reproduced from the pass-201 integration sweep
`/tmp/intr11u201`), and all 724 probe cases reproduce `STRICT_NOTEQUAL` ([drivers/probestrict.py](drivers/probestrict.py)).
What the landings did to the brief's clusters, checked at the base before working any of them:

* **N0778** (BuildUVMPkg's first-open head in map 12) is **not reachable at the base**: BuildUVMPkg d reads 11 records
  and then a structural record (`#22506`: golden `enum_typespec uvm_pkg::uvm_verbosity` 43411:55, ours a
  `bit_typespec` 38374:5, walk diverged), so no record behind it is compared. Its visible records are the
  `uvm_action` copies (#3245, #20735, #20759, #20795: section 4.3's writer family) and two `m_set_cl_verb` local
  columns (#22454, #22460).
* **cfg_func_width_loop**: the kept-call half (N0133 / N0487) is **covered at the base** (pass 196's
  law evalFuncOmittedDefaultKeepsCall196 with r11u204's law dfltArgTaintExec204v: no func_call record differs); the three
  records left are the evaluator's formal-typespec stamp on the parameter constant (golden `logic_typespec mask_t` at
  the FORMAL `mask_t cfg` 27:40-27:46 with the range folded to `INT:2`; ours the typedef's 16:11-16:25 with `NF-1`):
  ground A (ParamEmit, r11u200's 3e), not written here.
* **UnitElabBlock d** (N0011) is gone; d and t both read only the ground-A implicit-net file (N0016), which this pass
  writes (section 3.5) because it converts the row.
* **HierPathTypespec t** `fullname(1)`: golden `pkg::pkg::b::pkg::a::x`, ours `pkg::pkg::a::x` (the member typespec of
  struct `a` read through the `-elabuhdm` parent chain of the array typedef `b`); default mode is CMP_EQUAL, so it is
  the listener's re-parenting of a shared typedef: the naming-context face, no law.
* **anon_struct_packed_dim d/t** (43 records, one family): golden names the members of the `$unit` typedef `pte_t`
  reached through member `gpte` of the anonymous struct `gpte.pte_t.ppn`, ours `pte_t.ppn` (13 x 3 records); not
  decoded to a writer this pass.
* **ibex_tracer d/t** (579 records): 191 `ref_typespec` records name package-parameter struct copies with the chain's
  `::` separators in golden (`ibex_tracer_pkg::ExcCauseBreakpoint::ibex_pkg::exc_cause_t::irq_int`) where ours joins
  with `.` (ground B), and 388 `ref_obj` records are case-item references to wildcard-imported package parameters,
  golden `work@ibex_tracer.INSN_CLW`, ours `ibex_tracer_pkg::INSN_CLW` (ground A): the row needs both grounds.
* **InterfaceStructMemberPort d/t** (6 records): the modport view's `struct_net req` / `logic_var trn` store no full
  name in golden and their `ref_typespec` reads only the net's name (the chain stops at the net), and the child's
  `sys_wen` operation references read through the child's port (`work@top.w.u.sys_wen.wen`); r11u202's IM grid
  diverges structurally before the naming. Not written.
* **OutputSizeWithParameterOfInstanceInitializedByStructMember d/t** (8 records): the substituted `Info.x` hier_path
  located at each USE of the localparam (17:11-17:26, 4:18-4:23), its `Info` ref_obj at `x` (15:42-15:43), and the
  child's `'1` kept unsized (`BIN:1`, size -1) where ours folds `UINT:65535`: mostly ground A (ExprEmit / StmtEmit);
  not written.
## 3. The decodes and the laws (per cluster family)

Every law reads its own switch; `R11U205_OFF=1` drops all six and restores the pristine bytes (grid: 132 of 132
case-views `OFF=pristine`, [evidence/grid/grid_pris_law9.tsv](evidence/grid/grid_pris_law9.tsv)).
`R11U205_TRACE=<dir>` names every firing (the mover predictor, section 6).

| law | switch | ground / file | cluster (map 12) | rows it converts |
|---|---|---|---|---|
| law tpDefaultUseCastAndArrayElem205 | `R11U205_TPDEFUSE_OFF` | B, UhdmExporter.cpp (the law tpUseBindsDefDefault160 post-pass) | N0090 (arb_idx_cast's last cluster) | **arb_idx_cast d/t** |
| law genConnTrailSelChain205 | `R11U205_GENIDXSEL_OFF` | B, ModuleEmit.cpp (`emitDefGenStmts`, definition view) + UhdmExporter.cpp (post-pass, elaborated view) | N0945 (Earlgrey_0_1 d/t head) | none alone (Earlgrey `fullname(76)` -> `endcol(46)`) |
| law defGenTargetIpsDefName205 | `R11U205_IPSNAME_OFF` | B, TypeEmit.cpp (`emitSyntaxExpr`'s hier_path branch, the indexed part select) | N1249 (Rggen d head) | none alone (Rggen d `defname(142)` -> `file(4)`) |
| law ifacePortDeclTsAtPortDecl205 | `R11U205_PORTDECLTS_OFF` | B, ModuleEmit.cpp (`emitInterfaceInstance`, `portTsPre`) | N1899 + N0094 (probe-only, 51 cases) | 20 probe cases |
| law hiddenBlockVarNetNoFile205 | `R11U205_HIDDENNETFILE_OFF` | A, ExprEmit.cpp (the `vlogHiddenBlockVars` mint) + EmitHelpers.h (the switch helper) | N0016 / N0011 (UnitElabBlock) | **UnitElabBlock d/t** |
| law elabIfArrIdxChainName205 | `R11U205_IFARRIDX_OFF` | A, ExprEmit.cpp (the HierarchicalValue base-select branch) | N0427 (InterfArrayBind d) | none alone (InterfArrayBind d `fullname(3)` -> `fullname(1)`) |

### 3.1 law tpDefaultUseCastAndArrayElem205 (arb_idx_cast's last cluster, N0090)

**Heads at the base** (arb_idx_cast d/t `endline(2)`, #360 and #384): golden `logic_typespec` 8:40-**15:27**, ours
8:40-**8:60**, both inside the cast `idx_t'({1'b1, index_nodes[...]})` of the else branch of the elaborated
`gen_other_levels` conditional.

**Decode.** `UhdmWriter::writeNets` (Surelog `src/DesignCompile/UhdmWriter.cpp:812`, the definition view,
`instance == nullptr`) types a definition net with `compileTypespec(orig_net->getTypeSpecId())` and then moves only
the END of the answer to the declaration's first unpacked, else first packed, dimension
(`fC->populateCoreMembers(InvalidNodeId, dimensions, ts)`, :881). For a type-parameter-typed net `compileTypespec`'s
identifier branch answers the parameter's DEFAULT object itself (`result = rt->Actual_typespec()`,
CompileType.cpp:2002), so the move lands on the ONE shared default (the last declaration wins), which every reader
of the type parameter then shows: the ports (already modelled: law defNetTypeParamDefault137,
law defNetTypeParamPackedDim144, law defNetTypeParamPackedVec160), the elaborated variables and nets (re-pointed by
law tpUseBindsDefDefault160's post-pass), **and** an explicit cast to the type parameter anywhere in the instance
(the cast target is compiled through the same branch) and the element variable of an unpacked array of the type
parameter. Ours kept the instance's copy (unmoved) in those two readers: the cast under a conditional operand (scratch
reductions of the corpus source, not committed since they copy a corpus test, isolate the ternary: the same cast as
the whole right side already read the moved object) and the unpacked array's element variable (`t x [4];`, grid TP
t02).

**Law.** In law tpUseBindsDefDefault160's walk, per elaborated module instance and per type parameter not named by its
instantiation (the same `e2d` map, filled only where UHDM's own `Compare` reads the copy and the default equal), also
re-point (1) every `vpiCastOp` typespec reference in the continuous assignments of the instance and of its generate
scopes (operand trees walked), (2) every element variable's typespec reference of an `array_var`.

**Grid** ([cases/TP](cases/TP), 17 cases x 2 views): t02 (unpacked dimension) converts in both views; t01, t03, t05,
t10, t11, t14, t15, t16 stay EQUAL; t04, t06-t09, t12, t17 are stage-1 at the base and after; **t13** (`parameter type
t = int`, `t x [2];`) stays `endline(2)`: the int default's own object is not moved by ours at all (the def-net branch
law defNetTypeParamDefault137 reaches only a logic/struct default through `portTypeParam`), a separate residue (R4).

### 3.2 law genConnTrailSelChain205 (Earlgrey_0_1's head, N0945)

**Heads at the base** (Earlgrey d/t, #90097..#90175, 30 records, and gpio.sv 40): in the definition view of
`alert_handler`, `.class_en_i(reg2hw_wrap.class_en[k])` of `i_accu` inside `for (genvar k ...) : gen_classes`:

    golden  bit_select class_en  work@alert_handler.gen_classes.i_accu.class_en_i.reg2hw_wrap.class_en[k].class_en  148:44-148:45
    ours    bit_select class_en  reg2hw_wrap.class_en[k]                                                             148:35-148:43
    golden  ref_obj    k         work@alert_handler.gen_classes.i_accu.class_en_i.reg2hw_wrap.class_en[k].k         148:44-148:45
    ours    ref_obj    k         work@alert_handler.gen_classes.i_accu.class_en_i.k

and in the elaborated view (grid q01): golden `work@top.gen_classes[0].i_accu.class_en_i.reg2hw_wrap.class_en[0].class_en`,
ours `work@top.i_accu.class_en_i.reg2hw_wrap.class_en[k].class_en`.

**Decode.** Surelog's path compiler builds the LAST select of a hier_path as a `bit_select` located at the INDEX
expression, stores no vpiFullName on it, and compiles the index with the select as its parent
(`CompileHelper::compileComplexFuncCall`, CompileExpression.cpp:5062; the `paConstant_expression` branch :5120-5134:
`fC->populateCoreMembers(Constant_expresion, Constant_expresion, sel)`, `compileExpression(..., sel, ...)`), so both
names are UHDM's lazy chain (`ref_obj::VpiFullName()` -> `BaseClass::ComputeFullName`): the select through the
hier_path's name and the port and instance above it, the index through the select (skipped) and the path. A MIDDLE
select (`reg2hw.cause[k].d`, grid g14) stores its dotted text and keeps ours. Ours: the definition-view listing
(`emitDefGenStmts`'s generate-scope connection, ModuleEmit call site 1 of law genConnDottedActualIsHierPath37) takes
TypeEmit's hier_path branch, which stored the bare text at the member token and named the index through the formal; the
elaborated view stored a name frozen before the instance was parented at its generate scope (the scope and the folded
index missing).

**Law.** Definition view: in `emitDefGenStmts`' post-stamp of a hier_path actual, a trailing `bit_select` takes the
index's span and the names `<branch>.<instance>.<formal>.<path text>.<member>` / `...<path text>.<index>`. Elaborated
view: a post-pass (UhdmExporter, after law tpUseBindsDefDefault160) over every module or interface instance whose parent
is a `gen_scope`, both the definition and the top listings: each port whose high_conn is a hier_path of two or more
elements ending in a bit_select takes `<instance full name>.<formal>.<path name>.<member>`, the index's span, and an
index reference the same prefix. The instance-scope form (grid q03) and a middle select (g14) are unchanged.

**Grid** ([cases/GS](cases/GS), 18 cases x 2 views): g01, g08, g09, g13, q01, q05, q06 convert in both views (14
case-views); g02, g04, g07, g14, q03 stay EQUAL; g03, g05, g06, g10, g11, g12 are stage-1 at the base and after
(g03 a genvar-based indexed part select, g05 nested generates, g06 a positional list, g10-g12 a parameter index: other
faces).

### 3.3 law defGenTargetIpsDefName205 (Rggen's head, N1249)

**Heads at the base** (Rggen d, 138 of the row's 142 records, #3227..): in `assign bit_field_if.read_data[0+:4] = ...`
inside the definition view of `g_register_0.g_bit_field_0`, golden `indexed_part_select read_data` with **defname
`read_data`** and full name `work@block_0.g_register_0.g_bit_field_0.bit_field_if.read_data[0+:4].read_data`; ours no
defname and `bit_field_if.read_data[0+:4]`. The right-side twin (`bit_field_if.write_data[0+:4]`) has neither in
golden, as ours.

**Decode.** `CompileHelper::compilePartSelectRange` (CompileExpression.cpp:4250) names BOTH its branches by the field
(`part_select->VpiName(name); part_select->VpiDefName(name);`, :4274-4276 for `[l:r]` and :4299-4301 for `[b+:w]`) and
stores no full name; the SEL writer of law defGenPathSel161 (a definition-view generate assignment target) already
transcribes that for the `[l:r]` part select, not for the indexed one.

**Law.** In TypeEmit's hier_path branch, the indexed part select under route SEL (`sel161`, `i > 0`, the name axis
on) takes `VpiDefName(field)` and the chain name `<scope>.<path text>.<field>`, exactly as the `[l:r]` branch beside it.

**Grid** ([cases/IP](cases/IP), 8 cases x 2 views): i01 (for-generate, interface member), i02 (if-generate), i03
(struct member), i04 (`-:`), i08 (an interface PORT, Rggen's shape) convert in both views (10 case-views); i05 (the
right side), i06 (nested generates: already golden's), i07 (module scope) stay EQUAL.

### 3.4 law ifacePortDeclTsAtPortDecl205 (N1899 + N0094: the probe-only clusters with the most cases)

**Heads at the base** (tests/probe/r11u93repro/grid/pb14_ifbothstr and 50 more): in the ELABORATED interface instance,
the port-declaration net `o` and the port `o` read a `logic_typespec` golden 3:10-3:16 (the `[31:0]` of
`output [31:0] o;`), ours 5:25-5:31 (the body re-declaration `wire (strong1, weak0) [31:0] o = 32'd12;`), with its
range and both bound constants alike.

**Decode.** A non-ANSI interface port is the `Signal` the PORT DECLARATION pushed (law caIfacePortDeclNetMint93's decode:
`collectInterfaceObjects_` has no `paPort` case, so `setDirectionAndType`'s `found == false` branch, CompileHelper.cpp,
creates it from the port declaration), typed from that declaration's own data type: the span runs from the written
net-type or data-type keyword (`output wire [31:0] o;` golden 3:10-3:21, `output reg [31:0] o;` 3:10-3:20: v11u93
v16, v3), else from the first dimension, to the last dimension; the range and the bounds sit at the port
declaration's dimension. Ours built the typespec (`portTsPre`, shared by the port and the mint) from the body
declaration slang binds the port's internal symbol to.

**Law.** In `emitInterfaceInstance`, after `portTsPre` is built, a port whose PORT DECLARATION carries range
dimensions relocates its `logic_typespec` (one range per written dimension, every dimension a simple `[l:r]`) to the
declaration: start at the net-type or data-type keyword else the first dimension, end at the last dimension, each
range at its dimension and its bounds at their expressions. Declined on a signing keyword (r11u200's signing span rule
is not modelled here). Values are untouched (the bounds' values are the body declaration's, which a legal redeclaration
must match).

**Measured** (probe stage of the law sweep): **20 conversions** (r11u93repro n3 n4 pb3 pb4 pb5 pb7 pb8 pb9 pb11 pb12
pb14 pb16 pb17, r11v93repro v1 v3 v10 v12 v17 v18, r11u90repro vx9) and 3 changes, each a shorter residue (pb10
`line(36)` -> `line(20)`, pb19 `line(38)` -> `line(14)`, v15 `line(20)` -> `line(4)`). The first draft (law6) started
the typespec at the first dimension and regressed v11u93 v16 (`output wire [31:0]`, `col(4)`): law7 starts it at the
keyword and converts v3 too.

### 3.5 law hiddenBlockVarNetNoFile205 (UnitElabBlock, ground A)

**Heads at the base**: UnitElabBlock d `file(2)`, t `file(1)`: the implicit `logic_net work@mod.hold` (21:1-21:5)
golden with NO file, ours `top.v`. The mint is ExprEmit's `vlogHiddenBlockVars` branch (a block-local `logic hold;`
in a `.v` file, hidden from Verilog-mode lexing, binds an implicit module wire at the first reference: r11u202's
residue 2); it was the one implicit-net mint that did not call `noteImplicitNetMint131` (law implicitNetMintNoFile131:
Surelog's late-binding mint, UhdmWriter lateBinding, copies the reference's span and no file).

**Law.** The mint notes itself. Converts **UnitElabBlock d/t**.

### 3.6 law elabIfArrIdxChainName205 (InterfArrayBind d, ground A)

**Heads at the base** (InterfArrayBind d `fullname(3)`): `assign peripheral_io_bus[io_idx].write_en = 1;` in the
elaborated `io_gen[0]` / `io_gen[1]`, and `assign peripheral_io_bus[IO_ONES].write_en = 32'hffffffff;` at module
scope: golden's base-select index reads the chain (`work@soc_tb.io_gen[0].peripheral_io_bus[io_idx].write_en.io_idx`),
ours the scoped `work@soc_tb.io_gen[0].io_idx`. Testflags (`-elabuhdm`) is CMP_EQUAL at the base.

**Decode by grid** ([cases/IA](cases/IA), 9 cases x 2 views): the parse form stores no name on the index exactly
where the continuous assignment's right side is a LITERAL (a02 `= 1'b1` in a for-generate, a05 the same through an
interface-array port) and keeps the scoped name where it reads anything (a06 `= x[i]`, a07 `= x`, a08, a09, and
uhdm2rtlil genvar_iface_struct / iface_array_modport_drive, whose right sides read references); the `-elabuhdm` form
stores it everywhere (every `_el` view EQUAL at the base). Surelog binds a continuous assignment's references in the
parse-form elaboration only where there is something to bind.

**Law.** In ExprEmit's HierarchicalValue base-select branch (the simple-identifier index), parse form, elaborated view,
assignment target, right side an integer literal: the index takes `<prefix>.<path text>.<index>`. a02 and a05 convert
(2 case-views: the parse form; their `-elabuhdm` views are EQUAL at the base and stay); a04 (a read), a06-a09 stay EQUAL. **Residue**: the module-scope target (a01, a03, and
InterfArrayBind's own #183 `peripheral_io_bus[IO_ONES].write_en`) is emitted by another branch that this law does not
reach: InterfArrayBind d reads `fullname(1)` after the law. The first draft gated on an interface-instance array and
regressed genvar_iface_struct d/t and iface_array_modport_drive d/t (`CMP_EQUAL` -> `fullname(2)`, law6's sweep);
the grid then isolated the right-side distinguisher (law9).

## 4. Decoded without a law (the rule, the grid, the site, and why no law)

### 4.1 B3 (r11u204's N1): an omission through named arguments or an empty slot

**Decode.** `CompileHelper::compileTfCallArguments` (Surelog CompileHelper.cpp:4456): an EMPTY positional slot
(`f(1, , 3)`) compiles to a located `constant INT:0` (size 64, `vpiIntConst`, :4524-4529); once ANY argument is named,
the argument vector is rebuilt in formal order and every formal no named argument supplies gets an UNLOCATED
`constant INT:0` carrying only the file (:4550-4560), appended AFTER the positional ones (so `f(1, .c(3))` binds
`[1, INT:0, INT:0, 3]`: `a = 1, b = 0, c = 0`). `ExprEval::evalFunc` binds `args->size()` actuals, so no formal is left
unbound and the call FOLDS with each missing formal read as 0; only a TRAILING positional omission (`f(1)`) leaves a
formal unbound (pass 196's keep). Every argument is also stamped with its formal's typespec (`exparg->Typespec(...)`,
golden's definition-view `func_call` in e08: `ref_typespec` on `1`, on each `INT:0`).

**Golden's values** ([cases/B3](cases/B3), [evidence/decode/B3_golden_vs_ours.txt](evidence/decode/B3_golden_vs_ours.txt)):

| case | call | golden elaborated right side | ours (base = law) |
|---|---|---|---|
| b01 | `f(.a(1))`, `f(.a(1), .c(3))`, `f(.c(3), .b(5), .a(1))` (`a + b + c`) | `INT:1` s32, `INT:4` s32, `UINT:9` s32 | kept, kept, `INT:9` |
| b02 | `f(1, , 3)`, `f(1)` | `INT:4` s32, kept | kept, kept |
| b03 | `logic [7:0]` formals, `a \| b`: `f(.a(8'h01))`, `f(.b(8'h02), .a(8'h01))` | `UINT:1` s8, `UINT:3` s8 | kept, `UINT:3` s8 |
| b04 | `int b = a`, `f(.a(3))` (`a*2 + b`) | `INT:6` (b = 0, not a) | kept |
| b05 | `g(f(.a(1)))` | `INT:3` | kept |
| b06 | `if (b > 0) return a; return a + 7;`, `f(.a(1))`, `f(.b(1), .a(1))` | `UINT:8`, `UINT:1` located at the returned literal (8:27) | kept, `INT:1` |
| b07 | `f(1, .c(3))` | `INT:1` (c bound to 0: the named value lands in a fourth slot) | kept |
| b08 | `int unsigned` formals, `f(.a(1))`, `f(1, 4)` | `INT:1`, `UINT:5` | kept, `UINT:5` |

The value's type follows UHDM `ExprEval`'s arithmetic (an `INT:0` placeholder in an arithmetic operand makes the
result `INT`; a bitwise operator or an all-literal expression stays `UINT`; a `return` of a bare literal hands back
that literal's own located constant). **No law**: the fold decision alone (a ModuleEmit change in
law evalFuncOmittedDefaultKeepsCall196's `omitted` set: a formal omitted by name or by an empty slot is BOUND to 0) would
move these calls from kept to folded, but ours encodes every fold as the function's return type (`INT:9` where golden
writes `UINT:9` on b01's full named call, which is a pre-existing stage-1 record), so no case converts without the
value-encoding model of `constCallFold` (r11u204's N10); and the kept call is downstream IDENTICAL today (the plugin
evaluates our `INT:0` placeholders exactly as golden's evaluator did) while every fold that encodes the value wrongly
risks a verdict. Downstream at the base: b05 and b07 are **DIVERGENT** (new faces, both binaries: the nested named
omission and the mixed positional-named call), the other six IDENTICAL.

### 4.2 N5: a case whose only return sits in the DEFAULT item

**Decode** (UHDM `ExprEval::evalStmt`, templates/ExprEval.cpp, the `vpiCase` row: only items WITH expressions are
visited; a default item never runs). Grid [cases/D5](cases/D5): d01 `f(3)` (the default item's return) is KEPT in
golden, `f(0)` folds to the literal `5` itself (`UINT:5` located at 5:14); d02 folds to `UINT:7` at the literal;
**d03 (`f = 1; case (a) 0: f = 2; default: f = 4;`) folds to `UINT:1`** (the default assignment never ran: a Surelog
evaluator defect that golden carries); d04 (no item taken) `UINT:6`. Ours folds every one with slang's correct value,
typed `INT` and unlocated. **No law**: the keep half is law dfltArgTaintExec204v's executor made unconditional (today it
is consulted only where an omitted formal is read), but every folded neighbour (d01's `f(0)`, d02-d04) is stage-1
unequal on the same value encoding, so the grid cannot show a conversion, and d03's golden value is the defect.
Downstream (the gate's `one()`, both binaries alike): **d01 and d03 DIVERGENT** (new downstream-visible faces: the
kept default-item call and the defect's value), d02 and d04 IDENTICAL.

### 4.3 The scalar-typedef formal writer (BuildUVMPkg #3245 and the uvm_action records; MiniAmiq #899's family)

**Heads.** BuildUVMPkg d/t first record: `int_typespec uvm_action` golden at the formal's type token
(`output uvm_action action`, uvm_pkg.sv 9704:72-82), ours the typedef's `int` (8075:9-12); the same object at #20735,
#20759, #20795 (class-method formals). MiniAmiq's first record #899 (`enum_typespec uvm_pkg::uvm_severity` golden
uvm_globals.svh 271:61-73, the formal `output uvm_severity sev`; ours its declaration) is the enum member of the family.

**Decode.** For a bare typedef name, `compileDatastructureTypespec` answers the typedef's OWN typespec (a SimpleType:
`result = sit->getTypespec()`, CompileType.cpp:883, cloned only under a `parent_tpd`; an enum or struct likewise), and
the formal's compile then populates the answer's location at its own type token, so every formal typed by the typedef
RE-LOCATES the one shared object and the last formal compiled wins, the package listing included. Grid
[cases/FT](cases/FT): f01 (a package function's `output act_t a`) reproduces in both views (golden 4:45-4:50, ours
3:11-3:14, 2 records: the package listing and the formal); f02, f04-f06 are stage-1 at the base on their call sites,
f03 (a package class method) is rejected by slang-uhdm (rc 3).

**No law**: the writer ORDER across a package's functions, class methods and other packages is exactly what map 12
left open on MiniAmiq #899 (pass 196's R1: `law tfArgClassMethodOrder176` is the existing mover, and the last writer in
uvm_pkg depends on Surelog's class-method compile order); a law written from f01 alone would re-locate the UVM
typedefs to the wrong writer and move records away on the four UVM rows. Site: TaskFuncEmit's io_decl typespec
(`emitTaskFuncs`) with the order model in UhdmExporter's law tfArgClassMethodOrder176 pass.

### 4.4 N7, N8, N9 (r11u204's residues), re-measured at the base

* **N7** (split real ports of a parameterized module instantiated twice, r11u204verify V191/rp2): downstream DIVERGENT
  at the base and with law9 (the laws do not touch it; section 7).
* **N8** (a type-parameter-typed array declared in a generate scope, X/x5): golden's `logic_var` carries folded ranges
  spanning the left operand; ours writes none (stage 1). The type-parameter default law of this pass (3.1) does not
  reach a generate-scope declaration: grid TP t06 (`t [1:0] y;` in a for-generate) is stage-1 at the base and after.
  Site: ModuleEmit's generate-scope variable emission (the elaborated `gen_scope` variables), not written.
* **N9** (the union-formal keep and the struct-element queue twin): left to the pristine rules, as r11u204 left them;
  not re-decoded.

## 5. The gates (law9 against the committed baselines; pristine sweep beside it)

Sweeps `tests/sweep.sh --jobs 3` from this worktree, all four stages: pristine `/tmp/r11u205_sP` (`SLANG_UHDM` = the
frozen pristine) and law `/tmp/r11u205_sQ` (`SLANG_UHDM` = `law9.bin`; same-length workdir names). **All 3273 `slang:`
lines of each sweep's `cmds.txt` name that sweep's frozen binary by path.** Logs: [evidence/sweeps/](evidence/sweeps).

| stage | pristine vs baselines | **law9 vs baselines** |
|---|---|---|
| probe | 3363 + 724, regressions 0, conversions 0, changes 0 | **3383 + 704: regressions 0, conversions 20, changes 3** (section 3.4) |
| surelog | 922 + 32, 0 / 0 / 0 | **924 + 30: regressions 0, conversions 2 (UnitElabBlock d/t), changes 4** (Earlgrey_0_1 d/t `fullname(76)` -> `endcol(46)`, InterfArrayBind d `fullname(3)` -> `fullname(1)`, Rggen d `defname(142)` -> `file(4)`) |
| uhdm2rtlil | 1594 + 12, 0 / 0 / 0 | **1596 + 10: regressions 0, conversions 2 (arb_idx_cast d/t)**, changes 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **803 / 66 / 2 / 0, verdict-identical to the baseline csv and to the pristine sweep, row for row** |

The converted rows, quoted from the law sweep's csvs:

    UnitElabBlock,default,CMP_EQUAL,,,equal
    UnitElabBlock,testflags,CMP_EQUAL,,,equal
    arb_idx_cast,default,CMP_EQUAL,,,equal
    arb_idx_cast,testflags,CMP_EQUAL,,,equal

uhdm-cmp reads 0 lines on every row this pass touches (each stays `CMP_EQUAL` or `STRICT_NOTEQUAL`, both judge-equal).
Canaries: `r11u107repro/canaries.sh` surelog ok=50 changed=2 (Earlgrey_0_1 d/t, the predicted N0945 change) absent=0,
uhdm2rtlil ok=16 changed=0; `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` PASS (ok=58), uhdm2rtlil `EXPECT_UNKNOWN=6` PASS
(ok=2). The sweep's `law_index.py --check` reads **STALE** in both sweeps: the measured source carries the six new
section-signed `...205` law names (both sweeps ran from this worktree), which only the landing that commits them regenerates into tests/LAWS.md. This directory writes law names
without the section sign (as the analyst maps do), and on a fresh `3668bf30` with only this directory applied
`law_index.py --check` reads STALE for one reason: the index lists every new tools/probe directory and its
evidence cases (one row `r11u205dec`, 70 cases, no law attributed), so the landing that commits this directory
regenerates tests/LAWS.md with it.

## 6. Movers, predicted by name before the law sweep

**The predictor** ([drivers/census.sh](drivers/census.sh)): law9 with `R11U205_TRACE` over the 4087 probe cases and
both corpora in both modes, the corpus runs filtered by `^(?!(<the four fenced names>)$)` read from `$FENCED` (fail
closed: `fenced hits 0 0 0 0`), every firing mapped to its row-mode or case; frozen (`chmod 444`,
[evidence/predicted_firings_law9.txt](evidence/predicted_firings_law9.txt), md5 `f779a877`) before the law sweep
started. It names **8 corpus row-modes** (Earlgrey_0_1 d/t, InterfArrayBind d, Rggen d, UnitElabBlock d/t,
arb_idx_cast d/t) and **27 probe cases**.

**The movers** ([evidence/movers/](evidence/movers)): `byteverify.sh` (`SELFCHECK=1`: 959 / 960 and 1607 / 1608 flagged,
path sets identical) reads **10 corpus databases**: the 8 predicted, all moved, plus **MiniAmiq d and Scoreboard d, the
UVM storage-order coin** (their path-normalised sorted `uhdm-dump`s against the pristine databases differ in 0 lines,
and three concurrent law9 runs of MiniAmiq draw the pristine hash too: section 8). Probe: **25 of 4087 databases move,
every one predicted**; 2 predicted cases do not move (pb13_ifnoansiplainnouse and v16_ifportdeclnetonly: the relocation
equals the existing span). Of the 25: 20 conversions, 3 closer, and 2 bytes-only (r11u113repro c25 / c27, gen-for
ternary casts to a type parameter: law tpDefaultUseCastAndArrayElem205 re-points the cast to the Compare-equal default
object, EQUAL before and after). Downstream lane: 805 slang databases compared, 1 moves (arb_idx_cast, predicted,
verdict IDENTICAL both).

**The development sweep that failed** (law6, `/tmp/r11u205_sL`, recorded because it shaped two laws): probe
regressions 1 (v11u93 v16: fixed in law7, section 3.4) and uhdm2rtlil regressions 4 (genvar_iface_struct d/t,
iface_array_modport_drive d/t: fixed in law9, section 3.6); law6's census had no trace in the ground-A index law,
which is why those four movers were not predicted, and why law8/law9 carry one.

## 7. The away-moved-record census (map 12's method)

[drivers/away.py](drivers/away.py) on all 35 movers (10 corpus row-modes + 25 cases), strict records with the depth
dropped as multisets, golden vs pristine vs law9 ([evidence/movers/away_census.txt](evidence/movers/away_census.txt)):
**LOST 0 on every mover; GAINED 767** (Earlgrey d/t 118 each, Rggen d 138, InterfArrayBind d 2, UnitElabBlock 2 / 1,
arb_idx_cast 2 / 2, MiniAmiq d and Scoreboard d 0 / 0, the 25 cases 4 to 32 each). No law of this pass moves a record
away from golden, so none was refined or withdrawn on this count (the two refinements of section 6 were regressions,
found by the gate). The UVM rows' order-blind distance to golden is unchanged by construction: SeqDriver, SimpleUVM
and BuildUVMPkg are byte-identical, MiniAmiq d and Scoreboard d lose and gain 0 records; the family census of
r11u175uvm therefore reads the pristine census (no UVM firing in the predictor).

## 8. Downstream and determinism

**Downstream faces** ([drivers/dsfaces.py](drivers/dsfaces.py): the gate's own `one()`, a fresh `GOLDEN_CACHE`,
both binaries; [evidence/downstream/](evidence/downstream)): map 12's 125 face cases plus this directory's 62 cases:
pristine 149 IDENTICAL / 21 EQUIVALENT / 10 DIVERGENT / 6 STATUS_DIFF / 1 SLANG_REJECT, **law9 the same, row for
row (0 verdict changes)**. So the section-8b faces stand: q08 DIVERGENT (the generate-scope `$high` sysFold), w12 /
w13 DIVERGENT, c10 / c12 / u02 / u08 EQUIVALENT (the sized whole-CA constant), GV v07 / v08 / v09 / v15 / p04
STATUS_DIFF, u01 STATUS_DIFF (the 70-bit digit-separator localparam), PU/u06, UD/u04 and c06 DIVERGENT: **none of them
is addressed by a law of this pass** (section 10). New downstream-visible faces found on the way, present in both
binaries: B3 b05 and b07 (nested and mixed named omissions) DIVERGENT, D5 d01 and d03 (the default-item keep and the
default-never-runs value) DIVERGENT, r11u204's rp2 (N7) and x5 (N8) DIVERGENT, TP t12 DIVERGENT and t04 / t06 / t08 /
t09 / t17 EQUIVALENT (type-parameter shapes judge-unequal at stage 1 already).

**Determinism** ([drivers/det.sh](drivers/det.sh), three CONCURRENT runs per binary per row-mode with the sweep's
command line; [evidence/determinism/](evidence/determinism)): law9 reads **one hash per mode on Earlgrey_0_1**
(`e157846712e1` / `27a4508013e1`, the law sweep's), one hash on SeqDriver, SimpleUVM, Scoreboard default and
BuildUVMPkg (each the pristine sweep's), and **MiniAmiq two draws per mode** (`dd9e7e671b37`, `44503790f4d7`) whose
sorted dumps are identical: storage order only (the known UVM coin); Scoreboard testflags is SLANG_REJECT (skipped).
The pristine binary's three concurrent runs ([det_pris.txt](evidence/determinism/det_pris.txt)): one hash per mode on
Earlgrey_0_1 (the pristine sweep's), and the SAME coins: MiniAmiq default `dd9e7e671b37` / `44503790f4d7` (the two
hashes law9 draws), Scoreboard default `e8579dab5a62` / `96872705d270` (the two hashes the law and pristine sweeps
wrote), SeqDriver default `a08930879bae` / `98e3c2db2362`; law9 moves none of them.
One intermittent crash was seen during development: law4 on tests/probe/r11u93repro/grid/pa11_proggenregion once
printed `Segmentation fault` from the harness while its database was already written and judged EQUAL; 40 + 40
further runs of law4 and of the pristine binary on that case read rc 0, and the final sweeps record no rc 139.

**Each patch alone** (`/tmp/wt_r11u205B`, a second worktree at `3668bf30`): `law_typeemit.patch` alone compiles and
its binary (`lawB.bin`, md5 `675530df0203`) is **byte-identical to law9 with the two ground-A switches off** on 12 of
12 case-views (GS q01, TP t02, IP i01, IA a02, the arb_idx_cast shape, pb14, both views); `law_exprstmt.patch` alone
compiles too (`lawA.bin`, md5 `380f74384926`), is byte-identical to law9 with the four ground-B switches off on 12 of
12 case-views (IA a02 a05, GS q01, TP t02, pb14, the arb_idx_cast shape, both views), and converts UnitElabBlock d/t
by itself (`UnitElabBlock,default,CMP_EQUAL,,,equal` / `testflags` alike). Measured by switch (the delivered source runs a law only under its own switch), the split of the gains
is: ground B alone converts arb_idx_cast d/t and the 20 cases and moves Earlgrey d/t and Rggen d; ground A alone
converts UnitElabBlock d/t and moves InterfArrayBind d; the composition is additive (no mover carries firings of both
grounds: section 6's firing list).

## 9. The fence and the process

* Every driver that reads a corpus source or database reads the four fenced names from the `FENCED=` line of
  `tools/probe/r11u107repro/canaudit.sh` and fails closed: `env.sh` (`FENCED`, `FENCE_RE`; exits unless four names),
  `case.sh` (refuses a fenced path), `heads.sh` (skips a fenced row), `probestrict.py`, `away.py`, `dsfaces.py`
  (assert), `census.sh` (the corpus runs filtered `^(?!(...)$)`, and a fenced-hit count that must read `0 0 0 0`).
  No fenced row is `STRICT_NOTEQUAL` at the base, so none is in any list here. The two gate sweeps dispatched every
  row, as the gate mandates; **no binary, gdb run or script touched a fenced test's sources or databases outside
  them.** No gdb was used at all (every decode above is from Surelog's source and purpose-built goldens). A grep of this
  directory for the four names reads 0 (checked on the delivered patch).
* Builds: `-j 2`, and `-j 1` whenever another build or a sweep shared the machine; one OOM kill of the first pristine
  build (`cc1plus` Killed) was retried, never measured. No source was edited while its unit compiled.
* Scratch: `/tmp/r11u205_*` only (binaries `/tmp/r11u205_bin`, sweeps `_sP` `_sQ` (and law6's `_sL`), the census
  `_cen9`, case goldens `/tmp/r11u205_g`, downstream `/tmp/r11u205_ds`, determinism `/tmp/r11u205_det`); worktrees
  `/tmp/wt_r11u205` and `/tmp/wt_r11u205B` (the patch-alone builds). After the measurements the superseded scratch
  (law6's sweep and census, the determinism databases, the second worktree) was removed; the two gate sweeps
  `/tmp/r11u205_sP` / `_sQ`, the census `_cen9` and the binaries are kept for the integrator. No file was written relative to a working
  directory; no `results/`, `tests/` or `third_party/` file was touched; no stash; `GOLDEN_DEFER` unset (the census
  script's first version exported it EMPTY, which `verify_golden.py` reads as unset; removed before the law9 census).
* Processes: only this pass's own sweeps and census were stopped (the obsolete law8 census, by pid after reading each
  command line).

## 10. Residues, ranked (what is left and why)

1. **Earlgrey_0_1 d/t `endcol(46)`** (after law genConnTrailSelChain205): 17 `constant` records whose span golden stops
   at a package-qualified parameter's `pkg::` qualifier inside a module-scope fold (dm_csrs.sv 91 `dm::Data0` in a
   `dm::dm_csr_e'(...)` localparam, 91:52-56 golden / -61 ours; tlul_adapter_sram.sv 56/57 `top_pkg::TL_SZW-1` in a
   module typedef range, the law unitBoundFoldAtLeftOperand200 left operand spanning the qualifier alone; dm_mem.sv
   64-67; flash_phy_pkg.sv 43), 13 `ref_typespec` full names (`work@flash_ctrl` vs `region_cfgs[8]`, flash_ctrl's
   port typespecs), 12 `ref_obj` names (6 of them read through an indexed part select, `tl_i.a_data[8*i+:8].a_data.i`
   and flash_ctrl's `op_addr_i.reg2hw.addr.q[DataBitWidth+:17]`: the chain family of law genConnTrailSelChain205 on an
   indexed part select, not written), 2 part_select definition names (dm_csrs 362 / 417), 1 range and 1 logic_typespec,
   then the structural `#130430` (hmac_pkg.sv 26: a range against a ref_typespec). Mostly ground A (ExprEmit / ParamEmit: the qualifier span); the row stays behind the structural record.
2. **Rggen d `file(4)`** (after law defGenTargetIpsDefName205): `#22375` the folded bound of the interface array
   `register_if[...]` carries block_0.sv where golden has rggen_apb_adapter.sv (the line and columns are the adapter's:
   the file of a substituted-parameter fold comes from the instantiating context), then `#23164` a modport io_decl's
   `logic_typespec` that golden takes from ANOTHER file's declaration of the same text (rggen_adapter_common.sv 43,
   Surelog's typespec cache), walk diverged there. Ground B (TypeEmit makeBoundConst for the file; the cache face is an
   identity family).
3. **InterfArrayBind d `fullname(1)`**: the module-scope target `peripheral_io_bus[IO_ONES].write_en = 32'h...` (#183)
   takes another ExprEmit branch than the one law elabIfArrIdxChainName205 reaches (grid IA a01, a03 stay). Ground A.
4. **TP t13**: a type parameter whose default is `int`, `t x [2];`: golden moves the int default's end to `[2]`
   (1:33-2:10), ours never moves an int default (law defNetTypeParamDefault137's `portTypeParam` branch reaches only
   logic / struct defaults). Ground B, ModuleEmit `materializeDefNetTs`.
5. **The r11u93 module strength face** (tests/probe/r11u93repro n1, n2, n7, n8, n10: 5 cases): a MODULE's non-ANSI
   port whose body re-declaration carries a strength (erased by law caNetDeclStrengthDropped90) takes the PORT's
   typespec for its elaborated net in golden (3:10-3:16), ours the whole erased declaration (5:3-5:31); the port itself
   is already golden's. Ground B, ModuleEmit's module elaborated net listing (the `strPortRevert` branch of
   `collectNetOrder93` feeds `pendingNetTs` the body symbol).
6. **B3 / N5 / the fold value encoding** (sections 4.1, 4.2): the named / empty-slot fold decision and the default-item
   keep are decoded, but every fold neighbour is stage-1 unequal on ours encoding the fold as the function's return
   type where UHDM's ExprEval hands back the literal's own located constant or an operator-typed value: the
   value-encoding model of `constCallFold` (ModuleEmit) is the prerequisite; four new DIVERGENT downstream faces
   (b05, b07, d01, d03) stand at the base.
7. **The scalar-typedef formal writer** (section 4.3): BuildUVMPkg's first records and MiniAmiq #899, one family; needs
   the writer order across uvm_pkg's functions and class methods (TaskFuncEmit + law tfArgClassMethodOrder176).
8. **ibex_tracer d/t, anon_struct_packed_dim d/t, InterfaceStructMemberPort d/t, HierPathTypespec t,
   OutputSize... d/t, cfg_func_width_loop d/t** (section 2): decoded only as far as section 2 states; cfg's last half
   is ground A (the evaluator's formal stamp), ibex_tracer needs both grounds.
9. **Downstream faces of map 12 section 8b** (q08, UD/u04, c06, GV v07 v08 v09 v15 p04, u01, u02 / u08, c10 / c12):
   **not attempted** in this pass (their verdicts re-measured unchanged in both binaries, section 8).
10. **N8** (the generate-scope type-parameter array's ranges), **N7** (rp2), **N9**: section 4.4.

## 11. Files

* [law_typeemit.patch](law_typeemit.patch), [law_exprstmt.patch](law_exprstmt.patch): the laws (git diffs of src/
  against `3668bf30`; apply alone and together; the together tree is law9's source byte for byte).
* [cases/](cases): TP (17, section 3.1), GS (18: q01 q03 q05 q06 copied from r11u195repro/evidence/residue/Q with a
  new first line, section 3.2), IP (8, 3.3), IA (9, 3.6), B3 (8, 4.1), D5 (4, 4.2), FT (6, 4.3). Goldens are built by
  `case.sh` with check_probe's Surelog arguments (`-elabuhdm` for the `_el` view) and cached per text hash.
* [drivers/](drivers): section 1's list.
* [evidence/](evidence): `heads_base/` and `heads_law/` (strict records of every baseline `STRICT_NOTEQUAL` row-mode at
  the base and under law9), `grid/grid_pris_law9.tsv` (132 case-views, both binaries, the `R11U205_OFF` byte check),
  `predicted_firings_law9.txt` (the frozen predictor), `movers/` (byteverify, probe movers, away census), `sweeps/`
  (both sweep logs, the law sweep's csvs; `law9_surelog.csv` without the eight fenced row-modes, which the gate sweep
  dispatched and read at their baseline statuses), `downstream/` (face verdicts, both binaries), `determinism/`,
  `decode/B3_golden_vs_ours.txt`.
