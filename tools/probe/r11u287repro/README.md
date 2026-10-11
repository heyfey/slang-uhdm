# r11u287 — module/type ground: six laws on the probe residue (port views, generate scopes, the evalFunc keep set)

Base 04d369c8 (pass 285). Six laws in ModuleEmit and UhdmExporter behind `src/R287.h`. Each law reads its own
`R11U287_<LAW>_OFF` switch. `R11U287_OFF` drops all six (and the refinement inside law 6) and gives pristine's bytes on 294 of 294 grid case-views.
`R11U287_TRACE=<dir>` logs every firing (one file per process, `OUT <-o path>` first).

**TWENTY-FIVE PROBE CONVERSIONS**, one probe change toward golden, no regression. No corpus row changes status or
strict column, and no corpus database moves.

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| r10rgg4repro a1_noovr, b1_int_noovr, c1_p_noovr; r10vrgg4repro/v5k_noovr_int_signed | `fullname(2)` | **4 EQUAL** | § ifArrPortSizeIntTsUnlocated287 |
| v11u112repro/grid/brk/v b4b_opidx_minus, b4d_param_arr, b4h_port_2d; v11u115repro/grid/f1/v06_gf_vs_psel | `fullname(1)` | **4 EQUAL** | § defGenSelRefChainName287 |
| r10earl56repro a5_earl56 / v2_nestedsel56; r10earl120repro/a1_axis120 | `fullname(1)`, `fullname(10)`, `fullname(5)` | **3 EQUAL** | § defGenSelRefChainName287 |
| r10rgg3repro/n2_recv_localparam, r10vrgg3repro/xc_recv_localparam_only, r11u115repro/grid/i/s01_recv_bodylp | `line(3)`, `line(3)`, `line(1)` | **3 EQUAL** | § pvRecvBodyParamTs287 |
| r11u69repro/grid g2_iter, g4_lhskind, g5_nest; r11v69repro/grid/v10_arraysel | `type(1)` | **4 EQUAL** | § genCaStructParamSharesPaOperand287 |
| r11v4repro/v5 | `fullname(2)` | **EQUAL** | § pvPatFlattenTsUnparented287 |
| r11v4repro/v6 | `fullname(2)` | `fullname(1)` (change, shrinking) | § pvPatFlattenTsUnparented287 |
| r10rgg6repro/cells one_none_n4_yes_typed_ca, top_none_n4_yes_typed_ca, r2_ca_outer; r10vrgg6repro/cells/w_two_ctx_order; r11u108repro/grid/pk k17_func_in_pkg, k20_cfg_func_width | `type(1)` | **6 EQUAL** | § evalFuncUnreducedOperandKeepsCall287 |
| probe | EQUAL 3853 + STRICT_NOTEQUAL 234 | **EQUAL 3878 + STRICT_NOTEQUAL 209** | regressions 0, changes 1 |
| surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

## Gates (law binary 76dc7188c4ed5eef1e7b6efab889226c; pristine 99feee870ddf8af0d49063e9916ac921 = the main tree's)

- **tests/sweep.sh --jobs 3**, all four stages (evidence/sweep_L.log):
  - probe: regressions=0 conversions=25 changes=1 (EQUAL 3878 + STRICT_NOTEQUAL 209). The change is r11v4repro/v6
    `fullname(2) -> fullname(1)`, the same first field with one object fewer.
  - surelog: regressions=0 conversions=0 changes=0 (default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2).
  - uhdm2rtlil: 0 / 0 / 0 (803/1/67 both modes).
  - downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0. The csv is byte-identical to
    pristine's and to results/downstream_uhdm2rtlil.csv.
  - The surelog csv differs from pristine's only in the LowMemLib / LowMemPkg testflags detail text (the workdir
    path). The uhdm2rtlil csvs are identical.
  - The sweep exited 1 on the law-index check alone (stale at the base); this patch regenerates tests/LAWS.md.
- **Pristine sweeps** on the same machine: probe 3853 + 234, surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67,
  downstream 803/66/2/0, each with regressions=0 conversions=0 changes=0.
- **Predictor** (drivers/tracecensus.sh). The law binary ran under R11U287_TRACE over the probe cases and both
  corpora in both modes, with the fence filter, and was frozen before the law sweep (evidence/predict.txt, 54
  lines):
  - 39 probe databases: the 25 targets, r11v4repro/v6, 12 generate-scope cells of § genCaStructParamSharesPaOperand287
    that read EQUAL on both binaries, and r10earl31repro/e1_psbound.
  - 15 corpus row-modes, all § evalFuncUnreducedOperandKeepsCall287: Earlgrey_0_1 d/t, FuncIoTypespec d/t, Rggen d,
    Scr1SvTests d/t, uhdm2rtlil func_forloop_onehot, function_loop, ibex_pmp and many_functions d/t.
  - The predicate fires there, but another keep or fold gate already decides the cell, so no byte moves. The census
    over-predicts by those 15 and by e1_psbound.
- **Byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors from drivers/bvmirror.sh;
  8 fenced row-mode databases left out; evidence/byteverify_corpus.txt): **0 of 3365 corpus databases move**
  (surelog, uhdm2rtlil and downstream). SELFCHECK reads 3363 of 3365. That is the expected count: the reference
  file downstream/1DUnpackedArray has a byte-identical twin, uhdm2rtlil/testflags/1DUnpackedArray, as pass 285
  documented.
- **Probe byte compare** (evidence/byteverify_probe.txt, the same path set of 4087 on both sweeps): **38 of 4087
  move**, every one predicted by name (the 39 predicted minus e1_psbound).
- **Away census** on the 38 probe movers (drivers/awaycv.sh, order-blind and chain-keyed; evidence/probe_away.txt):
  lost 0 and chain away 0 on all 38. The conversions read toward 1 to 10. The 12 byte-only GENCASHARE cells read
  0 / 0: the shared object is the one the walk already listed.
- **Elaborated view** of the 38 probe movers (evidence/probe_movers_el.txt): all 25 conversions are STRICT_EQUAL in
  the elaborated view too. Nothing leaves STRICT_EQUAL. r11v4repro/v6 and r11u74repro b4_nonamesake stay
  `fullname` on both binaries.
- **uhdm-cmp**: 0 lines on every converted case and every corpus row (no corpus database moved).
- **Canaries** (evidence/canaries.txt): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 PASS on both
  csvs (EXPECT_UNKNOWN=1 and 6).
- **Binary-path audit** (fence-filtered cmds.txt lists; evidence/binary_audit.txt): on each sweep, 3265 of 3315 name
  that sweep's own frozen binary and the other 50 carry no slang line.
- **Determinism** (drivers/det.sh, three concurrent draws per row-mode with the law binary on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen; evidence/determinism.txt): one hash per
  row-mode, each equal to the law sweep's. Scoreboard and Rggen testflags write no database, as at the base.


## The laws

1. **§ ifArrPortSizeIntTsUnlocated287** (ModuleEmit `fillSizeDimRange`, the elaborated interface-array port's size
   dimension `ifc.mp arr[R]`; switch `R11U287_IFARRINTTS_OFF`).
   - Golden: the dimension's folded bound constant (`R` = 4) has a type link with no full name, bound to a fresh,
     unlocated signed `int_typespec`.
   - Ours bound the parameter's own located `int` (`6:13-6:16`) through a reference named `work@top.u`.
   - The branch is the only one that carries a type link: a plain signed `int` parameter, not overridden. Every other
     kind is already bare and equal (`integer`, `int unsigned`, `bit [7:0]`, the overridden cells; tests/probe
     r10rgg4repro b2..b9, r10vrgg4repro v5c..v5n).
   - uhdm-cmp reads only VpiSigned on that typespec. uhdm-strictcmp reads the reference's full name.
2. **§ defGenSelRefChainName287** (a design-final drain in UhdmExporter, `final287` at the end of `exportDesign`; the
   writer is TypeEmit `emitSyntaxExpr` under ModuleEmit `emitDefGenStmts`; switch `R11U287_DEFGENSELNAME_OFF`).
   - In the definition view of a generate block, golden stores no full name on the references and selects inside a
     select's index, bounds or width. BaseClass::ComputeFullName then names each one from its parent chain:
     - a reference whose parent is an `indexed_part_select` skips that select's name: `rd[i+1][o -: 4]` reads golden
       `work@m.g.rd.o`, where ours stored `work@m.g.rd.rd.o`;
     - an operation or a nested select between them keeps the select's name: `din[0 +: K1-1]` reads golden
       `...h1.h2.din.K1`, ours `...h1.h2.K1`; the part select `idx[PN:1]` used as an indexed base reads
       `...gen_n.din.idx`.
   - The drain covers every ref_obj kind (the selects derive from ref_obj in the UHDM pin) and every ref_typespec
     with a stored name, a select ancestor and, above it, a `gen_for` / `gen_if` / `gen_if_else` / `gen_case`. Each
     takes the chain's name (ComputeFullName is protected; its walk is transcribed in `chainFullName287`).
   - It leaves alone the no-fullname idiom (a stored name equal to the object's own name: r10earl41repro
     v41v_comment's qualified bases) and anything below a `hier_path`.
   - **Refined before delivery.** The first law sweep read Earlgrey_0_1 d/t `CMP_EQUAL -> STRICT_NOTEQUAL
     fullname(6)`. Six pinmux records under generate blocks were affected: `reg2hw.periph_insel[k]` and
     `...dio_data_mux.reg2hw.wkup_detector_padsel[k].k`, member-path elements whose names golden stores. The
     hier_path exclusion restored Earlgrey's pristine bytes in both modes.
   - Grid controls DG/g12_hierpath_ctl and g13_hierpath_idx_ctl reproduce the break on the unrefined binary
     (STRICT_EQUAL -> fullname) and read pristine's bytes on the delivered one.
3. **§ pvRecvBodyParamTs287** (ModuleEmit, the port view's param_assign in `emitInterfaceInstance` after
   § pvRecvShadow115; the binding is applied design-final in UhdmExporter `final287`, because a later drain re-binds
   every port-view param_assign constant; switch `R11U287_PVRECVBODYTS_OFF`).
   - A port view's parameter can be shadowed by a receiver parameter declared in the receiver's BODY
     (`localparam int A = 5;`, or `parameter int A = 5;` under a header with no parameter port list). Its value then
     carries that receiver parameter's own typespec in golden: `int` at the receiver's `8:14-8:17`, where ours had
     the interface's `1:27-1:30`.
   - A `bit [3:0]`, `longint`, `int unsigned` or untyped localparam binds its own kind and span (grid PR r01..r11).
   - A receiver HEADER parameter leaves the interface parameter's typespec (grid PR/r20; tests/probe r11u115repro e02,
     e04, e07, e09, s02, s15 already equal).
   - **Refined before delivery.** Only an initializer made of literals and operators fires. A system call (`$clog2(N)`)
     keeps the interface typespec: tests/probe r10vrgg3repro/v13_recv_clog2 went EQUAL -> line(3) under the first
     draft. A reference to another parameter (`A = N`) binds an unlocated int in golden, another face (PR/r07,
     residue).
4. **§ genCaStructParamSharesPaOperand287** (ModuleEmit `emitGenScopes`, beside § caStructParamGenScopeSubst69;
   switch `R11U287_GENCASHARE_OFF`).
   - Inside a generate block, writeCont_assign's reduce of `CFG.n` hands back the elaborated instance's param_assign
     operand itself, the flattened pattern's member constant. Where `adjustSize` returns at once, nothing clones it:
     `tps` is null on a bit-, part- or element-select Lhs (bindVariable never types one) and on a generate-local
     target (pass 71's adjWt 0).
   - Golden's cont_assign Rhs therefore IS that operand, re-parented at the last cont_assign that takes it. The walk
     lists it once, under the param_assign, and skips it at every cell.
   - Ours kept the definition's `hier_path` on a select Lhs (pass 69 declined the W1/W2 chains there) and minted a
     fresh constant per generate-local cell.
   - The operand is found by walking the instance's param_assign Rhs through assignment-pattern operations by field
     index. A miss leaves the cell as it was.
5. **§ pvPatFlattenTsUnparented287** (ModuleEmit, the port-view block of `emitInterfaceInstance`, queued beside the
   r11v4 guard of face (B); applied design-final in UhdmExporter `final287`; switch `R11U287_PVFLATTS_OFF`).
   - The reduced port-view pattern is `flattenPatternAssignments`' own clone. Its operation carries a ref_typespec
     created with NO parent: golden's `work@top.a0.q` param_assign Rhs reads `ref_typespec:` with no full name, while
     the elaborated instance's own (`work@top.u`) is parented.
   - That reference binds the struct the view's parameter binds. That is golden's one object, parented at
     `work@top.a0.q.CFG`'s ref_typespec, so its members read `work@top.a0.q.CFG.r::bus_t.DAT`. Ours parented the
     reference at the operation and bound a private copy.
   - Only a flattened SCALAR pattern fires (every operand a constant). A nested aggregate member is
     § ifacePortViewAggregateFlattens' face.
   - **Refined before delivery.** The rebind needs the view's own copy with the same vpiInstance as the copy the
     reference held. On r11v4repro v6 (a `$unit` typedef) the rebind put uhdm-cmp at stage 1, because golden's copy
     carries the design as its instance. There only the unparenting applies: `fullname(2) -> fullname(1)`.
   - A first draft also sat inside face (B)'s if/else chain and stole the next branch: tests/probe r11u1repro/grid2 read
     STRICT_NOTEQUAL -> NOT_EQUAL. The law is now its own statement before the chain.
6. **§ evalFuncUnreducedOperandKeepsCall287** (ModuleEmit, the keep-call gates of `emitContAssigns` and
   `emitGenScopes` beside § evalFuncSelectKeepsCall148 / § evalFuncCastMemberKeepsCall191; switch
   `R11U287_EVALKEEP_OFF`).
   - Three more body shapes that ExprEval::evalFunc does not reduce, so writeCont_assign keeps the elaborated
     whole-Rhs call.
   - Measured on 83 fresh golden cells (grid EV) before the law was written (90 with the loop cells):
     - **S**: inside an ASSIGNMENT's right side, a comparison operand or a conditional's condition that is a bit- or
       part-select of a formal or a local variable. evalStmt reduces an assignment's Rhs with `pexpr` = the
       statement, so ExprEval::getObject climbs to the function's io_decl / variable and the select stays
       unreduced; reduceCompOp then poisons `invalidValue`.
       - Keep: `nn += ((a3[i] != 0) ? 1 : 0)`, `n = (l[2] != 0)`, `nn = nn + (a[2] ? 1 : 0)`.
       - Fold: the same comparison in a return or an if condition (`pexpr` null), or the select as an add operand
         (deferred, then reduced at the return).
     - **M**: in a function declared in a module, interface or program body, a parameter read as an operand of an
       operator anywhere the body executes.
       - Keep: `r = a + NF`, `if (a > NF)`, `for (...; i < NF; ...)`, `while (i < NF)`, `return a + NF`.
       - Fold: a bare `r = NF` or `return NF`, and a read in a for-loop initializer.
     - **P**: in a package function, the same read outside a return statement.
       - Keep: `r = a + NF`, `i < NF`.
       - Fold: `return a + NF`, `return (a > NF) ? 1 : 0`.
   - Statements inside an if or case branch are not claimed; only their conditions are.
   - **§ evalFuncLoopBodyRunsOnce287** (inside the law; switch `R11U287_LOOPONCE_OFF`). A loop BODY is claimed only
     when its condition holds on entry, evaluated with the formals bound to the call's actuals and the loop
     variables at their initial values.
     - It was added before delivery: the byte controls found tools/probe/r11u237repro/cases/FW/g15 (`for (i = 0;
       i < n - 2; ...) r = r + ENC[i]` with n = 2 never runs) reading chain away 1 under the unrefined law.
     - Grid cells EV/l01, l02 and l06 (loops that never run) read STRICT_EQUAL on pristine, stage 1 under the
       unrefined law and STRICT_EQUAL again with the refinement.
     - EV/l03 and l07 (loops that run) convert.
     - EV/l04, a loop whose count is a local assigned before the loop, is left unclaimed where golden keeps the
       call. It is a conservative miss, at pristine's bytes.
   - The decode: the evalFunc / evalStmt / getObject / reduceCompOp paths in
     third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp and writeCont_assign's trailing reduce in
     third_party/Surelog/src/DesignCompile/UhdmWriter.cpp. Rules M and P are empirical; no single ExprEval line was
     isolated for them.

## Grid (tools/probe/r11u287repro/cases, 147 case dirs in both views: 294 case-views, every line with its exit code)

The groups:
- IA (8 dirs, law 1): plain and signed `int`, unsigned / `integer` / overridden controls, a generic interface port,
  two instances, an instance in a generate block.
- DG (13, law 2): an indexed part select in a var_select, an operation width, a part select as an indexed base, a
  bit-select index, a case generate, an interface generate, the comment idiom control, `+:`, an always_comb control,
  CRLF line ends, a macro, two hier_path controls.
- PR (16, law 3): body `parameter`, `localparam` of int / bit [3:0] / untyped / longint / int unsigned, operation,
  parenthesis and negative initializers, the parameter-reference and sized / based-literal controls, a header
  control, a `$clog2` control, a single interface, two receivers, a generic port.
- GS (13, law 4): gen-for and gen-if selects, an own pattern, a nested member, a child override, an interface
  generate block, two reads, a module-level control, a generate-local net and variable, hex members.
- PF (7, law 5): a package default, a `$unit` typedef, two members, a nested-aggregate control, a named-modport
  control, an override, an array element.
- EV (90, law 6): the S / M / P shapes and their fold controls (returns, if conditions, add operands, bare reads,
  loop initializers, select Lhs), and seven loop-iteration cells l01..l07 for the refinement.

drivers/grid.sh runs every case-view on pristine (P), the law (L), the law with `R11U287_OFF`, and the law with
each switch off (evidence/grid.txt, 2646 lines; the refinement switch on the loop cells in
evidence/grid_looponce.txt). drivers/gridsum287.py summarises it (evidence/grid_summary.txt):

- `R11U287_OFF` gives pristine's bytes on **294 of 294**. Every line exits 0 on every binary.
- **138 moving, 122 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.**
- Every mover returns to pristine's bytes under exactly one switch:

  | switch | movers |
  |---|---|
  | EVALKEEP | 66 |
  | GENCASHARE | 22 |
  | PVRECVBODYTS | 20 |
  | DEFGENSELNAME | 12 |
  | IFARRINTTS | 10 |
  | PVFLATTS | 8 |

- 33 uhdm-cmp line counts change, all toward golden: elaborated EV cells go from 50 or 64 lines (stage 1) to 0
  (STRICT_EQUAL). The default views of those cells already read STRICT_NOTEQUAL type.
- Movers that stay off STRICT_EQUAL, all at stage 1 on both binaries except p02, which reads `fullname` on both:
  - GS/s23_nested_member and s24_child_override;
  - IA/i04_localparam_size (a generic port) and i07_gen_inst;
  - PF/p02_unit_typedef;
  - PR/r24_generic_port.
- **Away census** (drivers/awaycv.sh; evidence/grid_away.txt): lost 0 and chain away 0 on all 138. The order-blind
  half is blind on a pristine stage-1 view (the comparator writes no records past stage 1); the chain-keyed half
  dumps each database against itself and covers those. s23_el reads flat_away 1 with chain away 0.
- Positive control, binaries swapped (evidence/away_poscontrol.txt): chain away 1 to 7 on EV/k26, IA/i01,
  DG/g01, PR/r01 and PF/p01. GS/s10 reads distance 0 -> 3 with no lost record, because the shared object is
  identity, not a record.
- Downstream on the grid: not run per case. The downstream corpus gate moves no verdict, and no corpus database
  moves.


## Byte controls (drivers/controls.sh; evidence/controls_dirs.txt, controls.txt, controls_summary.txt, controls_attr.txt, controls_away.txt)

Every case of 40 earlier repro dirs, in both views on pristine and law, with every line carrying its exit code.
Each path list was filtered by $FENCED before any case was opened.
- The dirs:
  - passes 283 and 285 with their verifiers;
  - pass 118's, 119's, 120's, 124's, 125's and 131's grids and their verifiers;
  - the families these laws extend: r11u148share, r11u191dec, r11u196repro, r11u237repro / v11u237repro, r11u69 /
    r11v69, r11u71, r11u115 / v11u115, r11u4 / r11v4, r11u7, r11u55, r11u83 / r11v83, r11u88, r10rgg3 / r10vrgg3,
    r10rgg4 / r10vrgg4, r10rgg6 / r10vrgg6, r11u112 / v11u112.
- **1869 dirs, 3738 case-views: 40 moving, 4 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.** The four
  entering are r10vrgg4repro/v5a_noovr_int_td and r11u148share/cases/E/f08_param_arith, both views.
- 8 uhdm-cmp line counts change, all shrinking:
  - v5a: 36 -> 0;
  - f08_el: 64 -> 0;
  - r10vrgg4repro/v2a_defparam: 50 -> 48 in both views;
  - r11v11u118repro w11_pkgbound_func: 36 -> 34 in both views;
  - r11v11u118repro x03_vs_pkgbound_func_el: 34 -> 0, stage 1 -> fullname.
- Every mover returns to pristine's bytes under exactly one switch: GENCASHARE 18, EVALKEEP 10, IFARRINTTS 8,
  PVFLATTS 4.
- The away census reads lost 0 and chain away 0 on all 40.
- Under the unrefined law 6 the same run read 42 movers. The two extra were r11u237repro/cases/FW/g15 in both views,
  and g15's default view read chain away 1 (`ref_obj o` of the call site's cont_assign). That finding produced
  § evalFuncLoopBodyRunsOnce287; with it, g15 is back to pristine's bytes.

## Downstream on the grid (drivers/dscases.py; evidence/downstream_cases_{P,L}.txt)

147 dirs on both binaries:
- pristine: IDENTICAL 108, EQUIVALENT 8, DIVERGENT 31;
- law: IDENTICAL 120, EQUIVALENT 8, DIVERGENT 19.
- **12 DIVERGENT -> IDENTICAL**, every one a law-6 cell where the kept call is what the plugin reads in golden:
  EV/c05, c09, c13, d01, d02, d07, d08, d09, e02, f01, k26 and l03.
- No verdict moves away from IDENTICAL or EQUIVALENT.


## Residues (ranked; all wrong on pristine too)

1. **The interface body's struct-parameter share** (my ground: ModuleEmit, `emitInterfaceInstance` and
   § caIfaceBodyCaFolds83). Decoded, not written.
   - In an interface, bindVariable has no `interface_inst` case, so `tps` is null on every cont_assign and golden
     shares ONE reduced value object per member across all of the instance's cont_assigns. A select-Lhs
     cont_assign is cloned with elaborated names (`work@dut.u_i.bitsel`).
   - Ours mints a fresh constant per plain cell and keeps the definition's cont_assign (`work@ifc.bitsel`) for a
     select Lhs.
   - tests/probe r11v83repro/grid/b14_cadelay: `d_plain` would reuse `d_del`'s `8'd6`.
   - r11u88repro/grid/j3_ifcaselect: needs part-select Lhs cloning as well.
2. **The module-level select Lhs reading a struct-parameter member through a chain** (grid GS/s27_mod_level_ctl,
   stage 1 on both binaries; uhdm-cmp-visible, not in the gate). Golden substitutes a constant, a separate object
   from the param_assign operand at module level. Ours keeps the definition's hier_path (pass 55's plainLhs fence).
3. **§ evalFuncUnreducedOperandKeepsCall287's open shapes.**
   - Golden keeps the call where ours folds:
     - EV/f06_loop_flat, k04_notern and k05_rettern: an actual that is a module localparam, read through a select;
     - EV/h09_ret_whole: `return a` of a 64-bit formal into an `int` return.
   - The fold VALUE faces at stage 1 on both binaries: the evalFunc result's encoding and size (h01..h04, h11,
     k08, k10..k13, k15..k17, k19, k20, k27, k29, c01..c04, c06..c08, c10..c12, c14, d03, d05, d06, e03, e04;
     golden folds to a constant whose value or size differs from ours). That needs a transcription of evalFunc's
     return-value code (the logic_typespec mask, the BIN truncation).
4. **§ pvRecvBodyParamTs287's open shapes.**
   - PR/r07_body_lp_ref (`A = N`): golden binds an unlocated int (`file` on both binaries).
   - PR/r08 and r09: a sized or based receiver literal, stage 1.
   - PR/r24_generic_port: stage 1 on another face.
5. **§ pvPatFlattenTsUnparented287's open shapes.**
   - PF/p02_unit_typedef = tests/probe r11v4repro/v6: golden's reference binds the view's own `$unit` struct copy,
     but ours' copy carries no `vpiInstance` where golden's carries the design, so the rebind is withheld; the
     copy's instance is the fix.
   - PF/p04_nested_ctl (§ ifacePortViewAggregateFlattens' face) and PF/p06_override: stage 1.
6. **§ genCaStructParamSharesPaOperand287's open shapes.**
   - GS/s23_nested_member (`CFG.s.a`, the operand under a nested pattern) and s24_child_override: stage 1 on both
     binaries, chain away 0.
   - GS/s12_gen_plain_hex and s29: a HEX member with a typed Lhs, where `adjustSize` mutates the shared object in
     place (last writer's width).
7. **§ ifArrPortSizeIntTsUnlocated287's open shapes**: IA/i04 (a generic interface port) and i07 (the instance in
   a generate block), stage 1 on other faces.
8. **§ defGenSelRefChainName287's open shapes**: DG/g05_case_gen and g06_iface_gen, stage 1 on other faces.
9. **The rest of the probe residue**, 209 first records classified on the law sweep
   (evidence/residue_first_records_law.tsv; buckets in evidence/residue_buckets_law.txt; fullname 79, line 26,
   endcol 24, type 20, file 15, depth 15, name 9, col 8, endline 6, value 4, count 2, decompile 1).
   - My ground, decoded or located, not written:
     - the cont_assign Rhs shared with an earlier object (r10v111repro/v111_b6, v11u114repro g25, r11u114repro a25
       and a28, r11u109repro p03_ready, r10vrgg9repro w_typeparam; ModuleEmit emitContAssigns);
     - the interface declaration order (r11u93repro pb10_ifnetuse and pb19_modportview, r11v93repro
       v15_ifdeclafterbody);
     - the class_typespec spans (r10uvm221repro a4_corpus, r10uvm225repro a6_headerforms, r10sd1repro b27,
       r10v119repro v119_j);
     - the modport net full names (r11u90repro vx8_strifport, r11v88repro v14_ndamodport);
     - the param_assign operation's net names (r11v70repro v5, v11);
     - the port and param_assign reference columns (r11u1repro grid2, r11v1repro vA, r11u21repro t9,
       r11u24repro n1).

Sister-ground faces (ExprEmit / ParamEmit / StmtEmit; reported, not written, counts from the law sweep's first
records):
- ParamEmit:
  - the alias references on package typedef listings, 6: r10vearl100repro v6_more100, r11u108repro f5a20_ovr_pkgarr,
    r11u111repro a10_q_chain, v11u108repro b13_pkg_arr, v11u111repro y31_two_pkgs_rows and x65_chain_td_dims;
  - the type-parameter struct member names, 4: r11u112repro k14_unpacked, r11u47repro g10 and g12,
    r11v47repro v12; § tpAnonStructLastParamUser167;
  - the chain borrow, 3: r11u45repro g10, r11v45repro v7, v11u111repro y64; § typeParamChainBorrow45;
  - the evalFunc member leftovers, 3: r11u26repro m4 and m7, r11u28repro a2; stampEvalFuncLeftovers;
  - the elaborated parameter typed by a typedef of a typedef, 3: r11u108repro k05_param_a, r11u111repro
    a27_q_row_named_dims, v11u111repro x38_param_in_module_typed;
  - the struct member names under parameters, 2: r11u24repro n11, r11v21repro v15;
  - the 64-bit cast range constants, 4: r11u109repro c04, c06, p06, p07.
- ExprEmit / ParamEmit:
  - the generate-scope fold reference names: r10earl95repro g5_hop95, r10v64repro v7_inst64, r11u113repro c09
    and c11, r11v23repro v11 and x09;
  - the package function call folds (`depth`): r10buvm13repro v3_clone13, r10buvm8repro v9fold8,
    r10uvm52repro a1.


## Process

- **Fence.** $FENCED was read fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line through
  drivers/env.sh.
  - Every corpus path list was filtered by it before any file was opened: the mirrors (drivers/bvmirror.sh), the
    census filter, the binary-path audit, the probe byte compare and the controls list.
  - The Earlgrey_0_1 decode read only that non-fenced row's database and golden.
  - Every helper used here refuses with $FENCED unset and refuses a fenced path: case.sh, grid.sh, awaycv.sh,
    away.py, awaychain.py, dscases.py, probecls287.py, tracecensus.sh, det.sh, bvmirror.sh, controls.sh.
  - No fenced source or database was read or dispatched outside the gate sweeps.
- No process of another agent was listed or signalled. Completion waits read the output files or used `pgrep -u`
  with this pass's own command line. Every tool variable was checked with `[ -x ]`. Nothing was written outside
  the worktree and this pass's /tmp/r11u287_* scratch.
- **Breaks found and fixed before delivery**, each by the pass's own gates:
  - the probe sweep found r10vrgg3repro/v13_recv_clog2 (law 3, the literal-only initializer);
  - the probe sweep found r11u1repro/grid2 (law 5, out of the if/else chain);
  - the probe case r11v4repro/v6 went to stage 1 (law 5, the instance guard);
  - the first full law sweep found Earlgrey_0_1 d/t STRICT_NOTEQUAL fullname(6) (law 2, the hier_path exclusion;
    grid controls DG/g12 and g13 added).
  - the byte controls found r11u237repro/cases/FW/g15 reading chain away 1 (law 6, § evalFuncLoopBodyRunsOnce287;
    grid cells EV/l01..l07 added).
  - The predictor, the grid, the full law sweep, the byte controls and the determinism draws were all rerun on the
    final binary after the last fix.
- **SLIP (no effect).** One status check of the background downstream-grid run used `pgrep -u <me> -f` with a
  pattern contained in its own command line, so it listed only the checking shell. Nothing was signalled;
  completion was read from the output files' line counts.
- The law binaries superseded during development (law1 to law7) were never used for a reported number; every
  number above is from 76dc7188.
- Drivers: copied from tools/probe/r11u285repro/drivers with the R11U287 switches. Added: gridsum287.py,
  probecls287.py (the r11u285 classifier, renamed). evidence/residue_first_records_base.tsv is the base
  classification of the 234 cases, evidence/residue_first_records_law.tsv the law's 209.

