# r11u309 — interface actuals of instance arrays and generate children (module/type ground)

Base cee373de. Six laws in src/ModuleEmit.cpp, each behind its own switch read through src/LawSwitch.h
(`lawOn(309, ...)`), `R11U309_OFF` dropping all six, `R11U309_TRACE=<dir>` logging every firing. No src/R*.h, no
LawState.h entry (the state is static in ModuleEmit.cpp).

Pristine binary md5 2c0499bc5c68c49e3a4606a43bfefe37 (equal to the main tree's build at the base); law binary
c5379532851208184fa072ef72c65188; both link slang 12.0.0+545f88b2e.

## The decode

Surelog's `NetlistElaboration::elab_interface_` writes a col-0 duplicate of every interface instance (the
instance's line only, `line:N:0`), registered in the parent netlist's symbol table. A receiving port's HighConn
resolved through that table binds the duplicate; the duplicate is printed (weakly referenced) only when something
binds it. Ours mints the duplicate only when `wantTailDup` is set in `emitInterfaceInstance`, and the sibling scan
that sets it read only the `Instance` siblings of the interface's own scope.

Separately, the definition view compiles a named interface connection of an instance array through the parent
implicit-net fallback exactly as for a single instance, so the connection-site `logic_net` (§ implicitNetNoFile119)
exists for an array child too, anchored at the first connection in source order.

## Laws

| law | switch | site | statement |
|---|---|---|---|
| § ifaceTailDupArrayChild309 | R11U309_TAILDUPARR_OFF | ModuleEmit emitInterfaceInstance, the wantTailDup scan | an InstanceArray sibling whose elements connect the interface by a bare name makes it carry the col-0 duplicate; the elements' HighConn bind it |
| § ifaceTailDupGenChild309 | R11U309_TAILDUPGEN_OFF | same scan | the scan descends into the instantiated generate blocks of the interface's scope (a single child or an array inside `if`/`for` generate naming an enclosing interface) |
| § ifaceConnNetArrayChild309 | R11U309_CONNNETARR_OFF | ModuleEmit, the connection-site net loop of the definition view | an instance-array child mints the connection-site net (first in source order wins), bound by the module_array port's HighConn |
| § ifaceArrSliceElemName309 | R11U309_ARRSLICE_OFF | ModuleEmit: the connection-site net loop, the definition-view module_array port binding, the elaborated HighConn branch of emitInstance and the interface-array `arrBareConn` scan | an instance array fed a WHOLE interface array through a scalar interface port (`child a2 [2] (.p(arr))`): the net is named by the array; every element's HighConn is a ref_obj named by the array (ours wrote the element's empty name, `work@top.`) bound to the first interface element's col-0 duplicate, which the first element now carries; a passthrough of an interface-array PORT stands aside (golden binds the port's interface_array) |
| § defGenModArraySizeRange309 | R11U309_GENARRSIZE_OFF | ModuleEmit, the definition-view generate-block HierarchyInstantiation path | a size-form dimension (`child a3 [2]`) gets the range [0 : size-1]: range and operation at the size expression, an unlocated UINT 0, the size as written (emitSyntaxExpr), an unlocated INT 1; the path wrote no range |
| § ifFillArmSharesDefOperand309 | R11U309_IFFILLDEFOP_OFF | ModuleEmit, the § ifCaTernFillArmKept303 fill block | the folded interface cell's Rhs is the definition's own branch operand re-parented at the instance cont_assign (golden prints the definition operand's `'0` with vpiParent cont_assign); UHDM's UhdmAdjuster::leaveConstant then resizes it in the -elabuhdm view (golden 8 bits, ours -1 before) |

## Cases (every first line names its law)

- TA (tail duplicate, connection net, generate size range; 28 dirs): a01_mod_arr, a04_two_arrays, a05_2d_arr,
  a06_gen_arr_inner_iface, a10_modport_arr_ctl, a11_positional_udp_ctl, a12_param_iface, a17_iface_arr_elem_ctl,
  a19_arr_size_nogen_ctl, a22_passthru_scalar_ctl, a27_iface_param_ovr_arr (§ ifaceTailDupArrayChild309);
  a07_gen_arr_outer_iface, a08_gen_single_outer_iface, a09_genif_arr, a13_nested_gen, a18_gen_arr_and_inst,
  a25_genif_single_outer, a26_gen_uninst_ctl, a29_genfor_iface_used_outside (§ ifaceTailDupGenChild309);
  a02_arr_then_inst, a03_inst_then_arr_ctl, a23_implicit_named, a24_wildcard, a28_two_ifaces_arr
  (§ ifaceConnNetArrayChild309); a14_gen_param_size, a15_gen_range_ctl, a16_gen_size_expr,
  a20_gen_size_nested_iface_ctl (§ defGenModArraySizeRange309).
- TS (§ ifaceArrSliceElemName309; 6 dirs): s01_mod_arr_slice, s02_gen_arr_slice, s03_range_slice,
  s04_slice_and_single, s05_gen_inner_slice, s06_passthru_samename_ctl.
- FO (§ ifFillArmSharesDefOperand309; 8 dirs): f01_ones, f02_nested, f03_two_inst_same, f04_true_branch, f05_bitsel,
  f06_split, f07_module_twin_ctl, f08_partsel.

## Grid (drivers/grid.sh, evidence/grid.txt, evidence/gridsum.txt; every line carries rc=)

- 42 dirs, 84 case-views (both views). **68 moving, 43 entering STRICT_EQUAL, 0 leaving**, 0 exit-code changes;
  `R11U309_OFF` gives pristine's bytes on 84 of 84.
- Restored by exactly one switch: IFFILLDEFOP 14, TAILDUPARR 6, ARRSLICE 6, GENARRSIZE 6, TAILDUPGEN 4, CONNNETARR 2.
  30 case-views need two or more switches (an array case fires both TAILDUPARR and CONNNETARR, an array in a
  generate block TAILDUPARR with TAILDUPGEN and GENARRSIZE): the list is at the end of evidence/gridsum.txt.
- Movers staying at uhdm-cmp stage 1 (all wrong on pristine too): a11_positional_udp_ctl (771 -> 43 lines, the
  udp-shaped list), a14_gen_param_size (Surelog mints an implicit `work@child.N` net in the child definition, a
  defect not copied), a16_gen_size_expr (265 -> 1378 lines: the range is now written and the walk reaches Surelog
  elaborating `[1+1]` to one element, a defect not copied), a23_implicit_named (moved toward golden: the col-0
  duplicate golden binds), s05_gen_inner_slice (an interface ARRAY inside a generate block: its first element's
  duplicate is not minted on that path, residue 1).
- Away-moved census (drivers/awaycv.sh, chain-keyed, evidence/away_grid.txt): lost 0, chain away 0, flat away 0 on
  all 68 movers, 261 records toward golden; the positive control (binaries swapped, 12 entering movers,
  evidence/away_poscontrol.txt) reads away on 12 of 12.

## The targeted residues

- r10vrgg16repro/cells/v12 (pass 307's chain-away 6): default view stage 1 (1836 lines) -> **STRICT_EQUAL 769
  objects**; elaborated view stage 1 -> STRICT_NOTEQUAL depth (a param_assign of the parameterized interface array
  in UHDM's elaborated copy at #656, residue 2).
- v11u307repro VA/va08_iface_array_conn: stage 1 -> **STRICT_EQUAL** in both views.
- r11u305repro IU/u01_plain_fill and u03_plain_split, r11u303repro IF/i08_plainlhs: elaborated view stage 1 (28
  lines) -> **STRICT_EQUAL** (default views stay STRICT_EQUAL).

## Firing scan and byte controls

- Firing scan (drivers/firescan.sh, law binary, default view): 26443 fence-filtered tools/probe dirs, 101 firing,
  67 of them earlier dirs; the one exit 139 is v11u112repro/grid/brk2/k/m07_hdr_enum_default, crashing on pristine
  too.
- The 67 earlier firing dirs in both views (drivers/controls.sh, evidence/controls_firing.txt and
  controls_firing_sum.txt): 134 case-views, all moving in bytes, **38 entering STRICT_EQUAL, 0 leaving**, 0 exit-code
  changes; away census lost 0, chain away 0, flat away 0 on all 134 with 264 records toward golden
  (evidence/away_controls.txt). Entering: r10rgg16repro/cells/g5, r10vrgg16repro/cells v6 and v12,
  r10vrgg3repro/z2_recv_module_array (both views), r11u115repro/grid/i n05, o01, o06 and o07, r11u162verify cx/x03,
  r11u164repro PV a16 and a20, r11u173verify pv p13, p15 (both views) and p16, r11u185verify PG/p03_prog_in_generate,
  r11u22repro and r11u23repro a08_iface_mod_fill0_el, r11u303repro IF/i08_el, r11u305repro IU u01_el and u03_el,
  r11u307repro GA/a11_iface_port (pass 307's residue 5), r11v130repro adv/f03_pv_gen_port, r11v23repro
  x20_iface_body_nogen_el, v11u115repro f2b q06 to q09, v11u293repro VP vp04, vp16 and vp18, v11u305repro VU
  vu11_el and vu27_el, v11u307repro VA/va08 (both views), VD/vd11 and VG/vg07.
- Control movers still not STRICT_EQUAL: v12_el (stage 1 -> depth), v11u268repro VQ/vq04_gen_inst_array (stage 1
  -> STRICT_NOTEQUAL line, both views), r11u176repro PG/g19 527 -> 34, v11u115repro q05 449 -> 36, v11u263repro
  VG/vg04 231 -> 36 (all heads moved later), r10vrgg16repro/cells/v3 and v11u297repro VS/vs03 (same line count),
  r10vrgg3repro/x5_iface_in_generate 89 -> 467 lines in both views (the first head, the definition-view interface
  module_array's missing range, cleared by GENARRSIZE; the next head is residue 1's interface-array duplicate),
  r11v130repro f03_el (strict fullname 8 objects on both).
- Standard byte controls over passes 118, 119, 120, 124 and 131 (r11u118repro r11v11u118repro r11u119repro
  r11u120repro r11v120repro r11u124repro r11v124repro r11u131repro r11v131repro; evidence/controls_earlier.txt):
  720 dirs, 1440 case-views, **0 moving**, 0 exit-code changes (none of them fires).

## Gates (tests/sweep.sh --jobs 3; each sweep exits 1 on the law-index check alone)

| sweep | probe | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|
| pristine / law | EQUAL 4015 + STRICT_NOTEQUAL 72; regressions 0, conversions 0, changes 0 | 480 + 0 / 474 + 0; 0/0/0 | 803/1/67 both modes; 0/0/0 | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; both csvs byte-identical to the committed one |

- Row diff law vs pristine: only the LowMemLib and LowMemPkg detail text (the workdir path).
- Firing census frozen before the law sweep (drivers/tracecensus.sh, evidence/predict.txt): no corpus row-mode
  fires; one probe database, r10rgg9repro/cells/c_iface_body (IFFILLDEFOP). byteverify on fence-filtered mirrors
  (drivers/bvmirror.sh, tools/probe/r11v75repro/byteverify.sh): **0 of 3365** corpus and downstream databases move
  (SELFCHECK 3363 of 3365, the known twin); probe **1 of 4087**, exactly c_iface_body, EQUAL on both.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both.
- Binary audit: 3323 cmds.txt per sweep, 3273 naming the sweep's own binary, 0 the other, 50 running no slang.
- Determinism (drivers/det.sh, evidence/det.txt): three concurrent draws, one hash per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, each equal to the law sweep's.
- uhdm-cmp stays at 0 lines on every corpus row and probe case (no corpus database moves).

## Residues (ranked; all wrong on pristine too)

1. An interface ARRAY declared inside a generate block feeding an instance array (TS/s05_gen_inner_slice,
   r10vrgg3repro/x5_iface_in_generate): the gen-scope interface-array path does not mint the first element's col-0
   duplicate (no `forceTailDup` there); ModuleEmit emitGenScopes.
2. r10vrgg16repro/cells/v12 elaborated view at depth: the parameterized interface array's param_assign in UHDM's
   elaborated copy.
3. Surelog defects seen and not copied: the implicit net `work@child.N` minted in the child definition for a
   parameter-sized generate instance array (a14), `[1+1]` elaborated to one element (a16).
4. The udp-shaped positional array (a11, rc 4 on both), an interface-array passthrough (s06: golden binds the port's
   interface_array; the law stands aside), a22 (a scalar passthrough into an array, unmoved, stage 1).
5. The module twin of the fill law (§ caTernFillArmKept193) is not touched: f07 is STRICT_EQUAL in both views on
   both binaries.

Sister-ground faces: none reached (no ExprEmit, ParamEmit, StmtEmit or EmitHelpers.h site written or read).

## Process

Pristine frozen before any edit; drafts d1 to d6 frozen as they were built, the law binary frozen before the
predictor, grid, controls and law sweep. Every driver reads $FENCED fail-closed from
tools/probe/r11u107repro/canaudit.sh and filters path lists before opening a file. One slip, no effect: an early
shell called `$UHDM_DUMP` with the variable unset inside my own scratch directory, which executed a golden database
and dropped one empty garbage-named file there (removed); every later call went through a guarded environment
script. No other agent's process was touched and nothing was written outside the worktree and /tmp/r11u309_*.
