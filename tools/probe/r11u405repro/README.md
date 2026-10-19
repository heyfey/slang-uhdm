# r11u405 — the sv-tests campaign's third pass on the expression/parameter ground

Implementer pass on base 30acad58 (passes 401, 402, 404 and 403 landed),
ground src/ExprEmit.cpp, src/EmitHelpers.h, src/StmtEmit.cpp, src/ParamEmit.cpp.
Every law is `§ <name>405` read through `lawOn(405, "R11U405_<LAW>_OFF")`
(src/LawSwitch.h); `R11U405_OFF` drops all of them; `R11U405_TRACE=<dir>` logs
each firing through `lawTrace(405, ...)`.  No src/R*.h, no getenv, no reader
function, include/ unchanged (the added lines carry no getenv / envSet).

Binaries: pristine 10ec176d3fff159e0ac0aca38dbe6f32 (equal to the main tree's
build at the base), final law binary 4683ce55a2a022a55c36df946217f465.  Every case line below carries
the exit code.

## Goal 1 (exporter errors on suite-legal tests)

| row | before | after | law |
|---|---|---|---|
| generated/tnoc/tnoc.sv | SURELOG_ONLY (`expression kind: Invalid`, exit 4) | DIFFERENT (exit 0) | § tpCastBeforeTpListed405, § ifacePortTdCastLogicTs405 |

tnoc's two Invalid faces: (1) tbcm_demux / tbcm_selector `parameter DATA_TYPE
DEFAULT = DATA_TYPE'(0)` — a value parameter's initializer cast to a type
parameter of the same header is emitted (definition view) before the
type-parameter loop records the default typespec, so § castModTypeParamDefaultTs294
abstained ("nodefault") and the name bound as a size was Invalid; (2)
tnoc_flit_if.sv:128 and tnoc_packet_deserializer.sv:113 (3664 elaborated
sites) — a cast to a typedef declared through an interface port
(`typedef types.tnoc_common_header tnoc_common_header;`), which has no listed
typedef object in an elaborated instance.  tnoc's next head (the sister's or
a later face of this ground): `tnoc_pkg::is_valid_packet_type`'s enum
reference, golden a constant at 200:28-47, ours a ref_obj to
`TNOC_INVALID_PACKET`.

Other SURELOG_ONLY rows of results/golden_svtests.csv, by message:
* every row but two carries an upstream slang front-end diagnostic (the file:line
  `error:` messages: should-fail tests, `design element does not have a time
  scale defined` on 5 basejump rows and biquad_example, unknown modules in
  utd-sv, duplicate definitions, ...) — not this ground;
* generic/typedef/typedef_test_13.sv `typedef target: AssociativeArrayType` —
  the sister's (TypeEmit);
* generated/tnoc/tnoc.sv — this pass.
* generated/rsd/rsd.sv ('member access base') is SURELOG_CRASH (Surelog dies
  first), so no exporter change can move its status; not worked.
* BLACK-PARROT (6 rows, SURELOG_CRASH): pass 403's guard kept.  Measured
  bp_unicore alone with the guard ON (law binary): exit 3 in 17 s, max RSS 810
  MB (Python rusage; this machine has no /usr/bin/time).  Pass 403 measured
  10-11 GB per row without the guard and bp_multicore_4 killed for memory even
  alone; no memory-bounded export was found, so R11U403_MACROLITGUARD_OFF is
  not lifted and the rows stay SURELOG_CRASH.

## The laws

| law | switch | site | what golden writes |
|---|---|---|---|
| § undefParamCastSizeTs405 | R11U405_UNDEFCASTTS_OFF | ParamEmit (castSizeParamTs gate) + findParamSizeCastParen405 | a DEFAULT-LESS untyped module parameter (basejump `BSG_INV_PARAM(p)`) owes its typespec to the first `P'(x)` / `(P)'(x)` cast in the module's own items: an int_typespec NAMED P at the cast's name token with vpiExpr ref_obj `P.P` bound to the parameter, shared by every such cast (Surelog CompileType.cpp compileDatastructureTypespec: param_assign without typespec -> buildIntTypespec + lhs->Typespec + Cast_to_expr).  Definition view only |
| § castSizeGenFence405 | R11U405_CASTGENFENCE_OFF | ParamEmit, findParamSizeCastParen405 | the cast that mints that typespec is never one inside a generate construct (compiled with the generate block) nor in a net/variable declaration initializer: for a COMPUTED-init parameter too (bsg_circular_ptr, test_bsg_data_gen) |
| § castSizeParenComputed405 | R11U405_CASTPARENCOMP_OFF | ParamEmit | the parenthesized spelling `(P)'(x)` mints the same object for a computed-init parameter (bsg_counter_set_en `(lg_max_val_lp)'(reset_val_p)`) |
| § bitsParamArgNoFold405 | R11U405_BITSPARAM_OFF | ParamEmit (bitsFoldInit) | `$bits(k)` of a PARAMETER is not a definition-time fold: the untyped parameter keeps no typespec, its elaborated value a size-64 computed fold (bsg_permute_box `lg_items_lp=$bits(items_p)`) |
| § impUnbasedLitKept405 | R11U405_IMPUNBASED_OFF | ParamEmit (fold chain + the unbased-literal Rhs block) | a module's materialized import copy of an untyped package parameter with an unbased-unsized default is the package literal itself, located at it, size -1; the def listing (even one § modDefImportShape flipped) keeps '0/'1/'X/'Z with a dangling ts ref named after the module, the elaborated listing spells 'b0/'b1/'bX/'bZ with no ts (bsg_cache `amo_support_level_none_lp = '0`) |
| § impUnbasedReadIsLit405 | R11U405_IMPUNBASEDREAD_OFF | ExprEmit (NamedValue parameter fold) | a module-body operand reading such a package parameter is the substituted literal at the reference (size -1, BIN, vpiBinaryConst): through a wildcard import the written spelling with a dangling ts ref named after the reading scope, written `p::P` spelled 'b<d> with no ts |
| § modUnpackedDimArithRef405 | R11U405_UNPDIMARITH_OFF | ParamEmit (unpacked-dim prefix) | a module parameter's unpacked dimension ARITHMETIC over another parameter (`parameter int fifo_els_p[dirs_lp-1:0]`) keeps the bound symbolic in every view (the unbound ref_obj `<module>.<holder>.<bound>`), overridden or not |
| § hierSelWidthLocalKeep405 | R11U405_HSWLOCAL_OFF | ExprEmit (member indexed part-select width) | a MODULE localparam width substitutes only in a NET DECLARATION initializer (BlackBePipeInt's witness); elsewhere golden keeps `p.addr[k+:l]` and the vpiWidthExpr ref_obj (bsg_cache `cache_pkt.addr[way_offset_width_lp+:lg_ways_lp]`) |
| § hierSelMacroBoundPretty405 | R11U405_HSMACROBND_OFF | ExprEmit (member range select name) | a select bound written through a macro is named from the bound objects' decompile, operators spaced: `q.rs1_addr[5 - 1:0]` (ours `[]`) |
| § nestedRepPatCount64_405 | R11U405_REPPATNEST_OFF | ExprEmit (ReplicatedAssignmentPattern) | a replicated pattern nested in another pattern or concat keeps its count at 64 bits; only the outermost init count is 32 |
| § typenameKwIsString405 | R11U405_TYPENAMEKW_OFF | ExprEmit (system call) | `$typename(<builtin keyword>)` is Surelog compileTypename's string constant (decompile and STRING value the keyword, no size) over the `$typename` name |
| § tpCastBeforeTpListed405 | R11U405_TPCASTEARLY_OFF | ExprEmit (§ castModTypeParamDefaultTs294's abstain) | a value parameter's initializer cast to a PORT type parameter of the same header takes the type parameter's default typespec (built from the declaration; typespec identity canonicalised).  A body `localparam type` abstains (probe r11u47repro/arms/g2, see Process) |
| § ifacePortTdCastLogicTs405 | R11U405_IFTDCAST_OFF | ExprEmit (cast type branch) | a cast to a typedef declared through an interface port, with no listed typedef object: a logic_typespec NAMED after the typedef at the typedef's first written type token (tnoc 120:11-16) |
| § implicitNetOnePerName405 | R11U405_IMPNETNAME_OFF | ExprEmit (foreach / block-param implicit wire) | Surelog keys the implicit module wire by NAME: a second foreach over `i` binds the wire the first reference minted |
| § disableTargetScopeChain405 | R11U405_DISABLETGT_OFF | StmtEmit (Disable) | a disable target is bound only up the enclosing scope chain: an enclosing named block, or a task (its own object); a sibling block or named fork stays unbound |
| § blockParamWrittenRhs405 | R11U405_BLKPARAM_OFF | StmtEmit (block-scoped parameters) | a block parameter's param_assign holds the WRITTEN initializer (4'b000x, an unfolded op), and a typed or ranged one carries its typespec (int_typespec at the range / keyword) |
| § implicitPortPaLastNoBody405 | R11U405_IMPLPORTLAST_OFF | ParamEmit (elab param_assign ranks) | the keyword-less port parameter's demotion holds with no body parameter at all, when the port list also holds a keyword-ful entry (p707) |
| § unboundedTypedParamTs405 | R11U405_UNBOUNDEDPARAM_OFF | ParamEmit | a typed parameter defaulted to `$` keeps the `$` constant with the parameter's typespec; the elaborated listing re-encodes it as a 32-bit STRING constant |

## sv-tests (the fifth stage)

Measured on the final law binary with tests/sweep.sh's sv-tests stage
(scripts/check_svtests.py run read-only from the main tree, since a worktree
has no UVM tree; `R11U405_TRACE` on), against results/golden_svtests.csv at the
base: **regressions 0, conversions 48, changes 0**.

| status | base | law |
|---|---|---|
| EQUAL | 1548 | 1591 |
| STRICT_NOTEQUAL | 9 | 13 |
| DIFFERENT | 381 | 335 |
| SURELOG_ONLY | 77 | 76 |
| BOTH_REJECT / SLANG_ONLY / SURELOG_CRASH / TIMEOUT | 303 / 19 / 8 / 1 | unchanged |

The 48 rows, each attributed by its own trace file
(evidence/svtests_conversions_by_law.txt):

* goal 1: generated/tnoc/tnoc.sv SURELOG_ONLY -> DIFFERENT (§ ifacePortTdCastLogicTs405,
  § tpCastBeforeTpListed405);
* basejump, 36 rows (DIFFERENT -> EQUAL 32, -> STRICT_NOTEQUAL 4): the size-cast
  face of pass 404 (§ undefParamCastSizeTs405: bsg_counter_dynamic_limit,
  bsg_counter_set_down, bsg_dff_async_reset, bsg_dff_negedge_reset, bsg_dff_reset,
  bsg_dff_reset_en, bsg_fpu_f2i, bsg_fpu_i2f, bsg_scoreboard_dealloc_alloc,
  bsg_tag_master, bsg_tag_master_decentralized, bsg_wormhole_broadcast;
  bsg_lfsr -> STRICT_NOTEQUAL fullname(1); bsg_channel_tunnel_out -> STRICT_NOTEQUAL
  col(1) with § castSizeGenFence405), the computed-init fences (§ castSizeGenFence405:
  bsg_circular_ptr, bsg_mesh_to_ring_stitch, test_bsg_data_gen; § castSizeParenComputed405:
  bsg_counter_clear_up_one_hot, bsg_counter_set_en, bsg_serial_in_parallel_out,
  bsg_cache_non_blocking_dma, bsg_cache_non_blocking_miss_fifo), § bitsParamArgNoFold405
  (bsg_permute_box, bsg_concentrate_static, bsg_array_concentrate_static),
  § impUnbasedLitKept405 (bsg_cache_decode, bsg_cache_dma, bsg_cache_miss,
  bsg_cache_sbuf, bsg_cache_tbuf, bsg_cache_to_axi, bsg_nonsynth_cache_axe_tracer;
  bsg_cache_to_test_dram -> STRICT_NOTEQUAL fullname(2)), § modUnpackedDimArithRef405
  (bsg_mesh_router_buffered, bsg_router_crossbar_o_by_i), § hierSelMacroBoundPretty405
  (bsg_wormhole_concentrator_out -> STRICT_NOTEQUAL fullname(1));
* chapter-20/20.6--isunbounded.sv (§ unboundedTypedParamTs405), chapter-20/20.6--typename_type.sv
  (§ typenameKwIsString405), chapter-20/20.9--isunknown.sv (§ blockParamWrittenRhs405),
  chapter-5/5.11-arrays.sv and 5.11-arrays-replication.sv (§ nestedRepPatCount64_405),
  chapter-9/9.6.2--disable_other.sv (§ disableTargetScopeChain405), chapter-9/9.7--process_cls_await,
  _kill, _suspend_resume and hdlconvertor_std2017_p168 (§ implicitNetOnePerName405),
  hdlconvertor_std2017_p707 (§ implicitPortPaLastNoBody405) — all DIFFERENT -> EQUAL.

Basejump tier: 81 DIFFERENT at the base -> 45 (32 EQUAL, 4 STRICT_NOTEQUAL).
Trace census over the 2346 rows: laws fire on 65 rows (evidence/trace_census_law26.txt);
§ impUnbasedReadIsLit405 fires on no sv-tests row (grid cases PZ/pz08-pz13 are its
positive control).

## Grid

tools/probe/r11u405repro/cases: 121 case dirs in 14 groups (BP, BU, DS, HM, IN,
IP, PH, PZ, RP, SC, TN, TY, UA, UB); drivers/grid.sh (golden by Surelog
`-parse -nobuiltin -nocache -sv`, both binaries with `dut.sv --single-unit
--nobuiltin`); evidence/grid_law.txt, one line per case with both exit codes:

* 70 NOT_EQUAL -> STRICT_EQUAL, 1 STRICT_NOTEQUAL -> STRICT_EQUAL, 3 NOT_EQUAL
  -> STRICT_NOTEQUAL (UA/ua01, ua04, ua05: a pre-existing `file` residue, ua06
  pristine the same), 26 STRICT_EQUAL controls unchanged, 2 STRICT_NOTEQUAL
  unchanged, 19 NOT_EQUAL on both (residues below);
* one exit-code change: TN/tn03 4 -> 0;
* each group's own switch(es) give pristine's bytes and exit code on 121 of
  121, R11U405_OFF on 121 of 121;
* away check on the NOT_EQUAL cases that moved: SC/sc28 and sc29 dump lines
  from golden 50 -> 18 and 44 -> 12 (toward), PZ/pz11 56 -> 42 cmp lines.

## Corpus gates

One sweep of the four corpus stages on the final binary (tests/sweep.sh
--jobs 3, evidence/sweep_law26.log), against results/*.csv:

* probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions 0, conversions 0,
  changes 0;
* surelog: default CMP_EQUAL 479 + testflags 473 judge-equal plus the standing
  Tnoc d/t CMP_NOTEQUAL; regressions 0, conversions 0, changes 0;
* uhdm2rtlil: 803/1/67 in both modes, 0/0/0;
* downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871;
* canaries ok=52 and ok=16 (changed 0), ctcan2 PASS on both csvs;
* byteverify (SELFCHECK=1) law workdir /tmp/r11u405_wd against the master's
  control /tmp/intr11u403: surelog 4 of 962 movers, uhdm2rtlil 0 of 1608,
  downstream 0 of 805.  The four movers are the ones the trace census names:
  Earlgrey_0_1 default and testflags (§ hierSelWidthLocalKeep405, 58 firings
  each; the elaborated width constant now parents at its param_assign as
  golden's does, normalised dump distance to golden 846015 -> 845925 lines on
  default, status CMP_EQUAL / strict equal unchanged) and Tnoc default and
  testflags (§ ifacePortTdCastLogicTs405 3664 firings and § tpCastBeforeTpListed405
  2, status CMP_NOTEQUAL unchanged).  const_func_block_var (u2r and downstream)
  fires § blockParamWrittenRhs405 with identical bytes; the probe case
  r10earl111repro/g6_view111 fires § hierSelWidthLocalKeep405 with an unchanged
  csv row.

## Residues (ranked by sv-tests rows; all wrong on pristine too)

1. **10 basejump rows: a computed localparam carries a typespec golden does
   not write** (bsg_ready_and_link_async_to_wormhole `wormhole_width_lp =
   $bits(wormhole_packet_s)`, the struct's width read from default-less
   parameters, and nine where the localparam sits in a child instance or a
   generate scope: piso.clog2els_lp, lru.lg_els_lp, rof.segment_slot_lp,
   hash3.even.frac_width_lp x2, xbar.input_els_lp, in_ch.output_dirs_sparse_lp,
   bsg_tag_header_width_lp, mem_co_pos_lp).  The placeholder value of
   § undefaultedDefInvalidInst404 makes the `$bits` fold look legal; a
   placeholder-taint gate on tryFoldConst was drafted and withdrawn (it fired on
   no row, see Process).
2. **6 basejump definitions § undefaultedDefInvalidInst404 abstains on**
   (design-level head): sister ground, pass 404's residue.
3. **5 parenthesized gen-block casts** (sister face 1), **3 `$bits` folds in a
   macro struct** and **2 def-view gen `$bits`/`$clog2`** (sister face 2).
4. **Singletons on this ground**: bsg_async_fifo / bsg_launch_sync_sync (a
   parenthesized `(width_p-1)` port-connection bound named as one ref_obj),
   bsg_sync_sync (a macro-named bound `` `bss_max_block `` as ref_obj, golden the
   folded constant), bsg_mem_1r1w/1rw_sync_mask_write_var (vpiOpType 25 vs 24
   inside a computed bound), bsg_mul_array / bsg_nonsynth_dramsim3 (a part_select
   of a port written as one ref_obj), bsg_pipeline_stall_collapse (an assignment
   operator in an expression), bsg_nonsynth_mem_1rw_sync_mask_write_byte_assoc
   (`data_mem_pkt.data[0+:8 * 2 ** i]`), bsg_nonsynth_axi_mem and
   bsg_nonsynth_dpi_rom (operations), bsg_mux_one_hot (parameter order),
   bsg_wormhole_router_decoder_dor (`0` vs `3'd0`), bsg_mesh_stitch (logic
   typespec span), bsg_imod_range and bsg_mul_pipelined (listings).
5. **16.10 property-local variable** (3 rows): needs the sister's property_decl
   variable listing (sister face 4).
6. **tnoc** next head: an enum reference in a package function written as a
   ref_obj where golden folds the constant.
7. **Grid residues**: SC/sc10-sc12 (an OVERRIDDEN default-less or computed
   parameter in an elaborated instance: golden copies the cast typespec into the
   elaborated parameter and its constants), SC/sc28-sc30 (a declaration-
   initializer cast of a VALUED computed parameter: golden an int_typespec named
   after it at the parameter's name with its value; moved toward, not equal),
   BU/bu04 (`$bits(n+1)`: Surelog's own argument split), BU/bu06 (`$bits(logic
   [3:0])` beside a default-less parameter reads 1 in golden), PZ/pz11 (a
   package '0 read as a continuous assignment's whole right-hand side: golden
   sizes it to the target and reparents the package object), UA/ua07 (`[n*2]`
   size form), UB/ub02 (untyped `$` parameter), UB/ub03 (a `$` default
   overridden), IP/ip03 (parameter vector order), TN/tn02 (interface generate
   listing), TN/tn03 (a value parameter typed by a type parameter: its typespec
   is golden's type-parameter object).
8. Not reached this pass: pass 403's and 401's residue lists (VH/vh02, VM/vm10,
   vm12, VA/va04, VE/ve03, PM/pm08, FE/fe06, ML/ml01, VL/vl03, VD, RS, PE, PU,
   AP/BT/CS/SM singletons), class_test_51 (`$bits(int)` in a class localparam:
   our argument becomes a ref_obj `int`), p292 (a package `let` called with named
   arguments: golden a func_call with the call-site arguments, parented at the
   enclosing begin), p770 (an interface-array element as a `new()` argument),
   fx68k (case_item spans), the 70 probe residues.

## Process

* The first law sweep (binary 374f13632e7b409e3f4810babd84b35d,
  evidence/sweep_law23_first.log) read surelog regressions 2: BlackBePipeInt
  default and testflags TIMEOUT.  The cause was the draft § placeholderValueNoFold405
  gate on tryFoldConst: an unmemoised walk through every parameter initializer
  chain, exponential on BlackParrot (1 s pristine, > 600 s law).  Memoised, the
  row ran in 1 s with pristine's bytes; and since the trace census showed the
  gate firing on no corpus row, probe case or sv-tests row, it was removed from
  the patch altogether.
* The same sweep read probe changes 1: r11u47repro/arms/g2 STRICT_NOTEQUAL
  fullname(5) -> fullname(16).  § tpCastBeforeTpListed405 fired on a body
  `localparam type` (a union): the built copy's member records read further from
  golden's shared object; the law is fenced to PORT type parameters and g2 is
  back on pristine's bytes.
* Two draft laws were dropped as sister ground once decoded: the
  parenthesized gen-block cast (its emitter is TypeEmit's emitSyntaxExpr) and
  the property-local variable listing.
* Measurement budget: the corpus stages ran twice (law23, then the final law26
  after the two fixes above) and the sv-tests stage twice (law25, law26: the
  same 48 conversions; law25 differs from law26 only by the withdrawn gate,
  which fired on no row).  Targeted runner calls on the worked rows and the
  probe stage alone were run on intermediate binaries.
* SLIPS: two background wait loops matched their own `pgrep -f` pattern and
  never ended; they were stopped by task id.  No other agent's process was
  touched; the sister verifier's sweep and census ran during part of this
  pass's case work (single-case runs and builds only; this pass's sweeps were
  launched after its sweep ended).  Nothing was written outside the worktree
  and /tmp/r11u405_*; no fenced test was named, read or dispatched.

## Sister-ground faces (reported, not written)

1. **Generate-block def-view casts by a parenthesized name** (5 basejump rows:
   bsg_decode, bsg_round_robin_n_to_1, bsg_link_ddr_upstream,
   bsg_mesh_router_decoder_dor, bsg_nonsynth_ramulator_hbm): TypeEmit
   emitSyntaxExpr's Cast branch gives an IdentifierName target the
   unsupported_typespec placeholder but sends `(num_out_p) ' (x)` to the size
   branch (integer_typespec); golden the same unsupported_typespec named by the
   inner identifier over its own span (cases SC/sc23, sc24).
2. **`$bits` in a def-view generate block** (bsg_source_sync_channel_control_master
   143:53, bsg_comm_link 794:22): emitSyntaxExpr folds `$bits(out_calib_code)` /
   `$clog2(core_channels_p)` where golden keeps the sys_func_call; and the
   converse inside a macro-declared struct's member range (bsg_cache_dma_to_wormhole
   and two siblings, 69:50: golden folds `$bits(<enum>)` to 2).
3. **vpiRefLineNo of struct members declared through a macro** (bsg_cache,
   bsg_cache_to_test_dram, bsg_wormhole_router, ...): TypeEmit.
4. **16.10 property-local variable** (2 rows + the uvm twin): golden lists the
   property_decl's `int_var x` (ModuleEmit def-view property_decl); the read's
   implicit net is this ground but cannot convert the row alone.
5. **Sequence declarations** (16.7, 16.9 x3, 16.10 sequence x2, 9.4.2.4) and
   **deferred final assertions** (16.2 x6): ModuleEmit listings.
6. **Variable kinds / initializers**: 12.7.3/12.7.4/12.7.5 (string array
   element written logic_var), 10.4.1 (a 1-bit initializer not size-adjusted),
   5.9, 5.10, 8.22, p124/p88 (initializer typed by an overridden type
   parameter), 6.11 integer_signed_bit, 6.12 realtime, chapter-7 queues;
   class property initializers (p148, p184, class_test_56-58).
7. **$unit parameters** number_test_7 (`1'B0` decompile) and number_test_15
   (`4'sb1111` value): UhdmExporter's $unit parameter emission (§ unitParamXzLiteral404's site).
8. **p600** `typedef bit [9:1'b1] word` range bound in a package typedef (TypeEmit);
   **6.19 enum_xx** enum constant value (TypeEmit); the UVM rows (UVM_ALL_ON copies).
