# r11u275 — pass 275, the module/type ground (refill after pass 273)

Base commit `dc979404` (pass 273). Production surface: `src/UhdmExporter.cpp`, `src/ModuleEmit.cpp`,
`src/TaskFuncEmit.cpp` and the new `src/R275.h`. Nothing under `results/`, `tests/` (apart from the regenerated
`tests/LAWS.md`) or `third_party/` is touched. No file of the sister's ground (ExprEmit, EmitHelpers.h, StmtEmit,
ParamEmit) is edited.

| binary | md5 | what |
|---|---|---|
| pristine | `0bb3812861a4eae78cd2f672f6a144fb` | built in the worktree at the base, byte-identical to the main tree's `build/slang-uhdm` |
| law | `a0b963c2946ea0de76c0dd91807973c5` | the delivered patch, frozen (`chmod 555`) before the firing census and every gate sweep; a rebuild of the delivered source gives the same md5 |

Both link slang 12.0.0+545f88b2e.

## Verdict

No corpus row converts and no corpus database moves: at the base no corpus record is on this ground (MiniAmiq d/t
`differ:fullname(4)` and SeqDriver d/t `differ:fullname(6)` carry only the sister's records, below). The pass works
the PROBE RESIDUE, item (1) of the brief:

**39 probe conversions** (STRICT_NOTEQUAL -> EQUAL; `evidence/probe_conversions.txt`, each attributed by the firing
census), 0 regressions, 7 changes (every one a shrinking count, attributed below); probe 3721 EQUAL + 366
STRICT_NOTEQUAL of 4087 (base 3682 + 405). **Downstream moves toward golden**: on the 39 converted probe cases and the
44 grid case dirs, 24 dirs go to IDENTICAL (7 DIVERGENT -> IDENTICAL, 17 EQUIVALENT -> IDENTICAL), none leaves
IDENTICAL (`evidence/downstream_cases_{pristine,law}.txt`).

| law | switch | conversions |
|---|---|---|
| § tpPackedArrCaUnparent275 (UhdmExporter) | `R11U275_TPPATRESET_OFF` | 6: r11u107repro/grid/t05_tp_struct_dim, r11u31repro/g5, v11u93b107repro/brk q01_dim_valparam, q05_union_dim, q06_two_dims, q12_dim_one_ovr_child (all `differ:fullname`) |
| § importNetTsDimEnd275 (ModuleEmit) | `R11U275_IMPNETDIMEND_OFF` | 9: r10uvm148repro/g148_a_prod, r10uvm48repro/t67b, r10v148repro/v148_g_corpus, r10uvm223repro/grid223/a3_module_wild, r11u82repro/grid/w9_typeshapes, r11u88repro/grid i1_ifkinds, i8_modtwin, r11v75repro/grid/xe_impkind, r11v77repro/grid/ve_ifacenet (all `differ:endcol`) |
| § ifaceGenCaLhsUnbound275 (ModuleEmit, in lhsTyped273) | `R11U275_IFGENUNBOUND_OFF` | 4: r11u69repro/grid/g11_iface, r11u71repro/grid/n3_ifacegrid, r11v69repro/grid/v7_ifacemix, r11v71repro/grid/x6_ifacedeep (all `differ:type(1)`) |
| § tfLocalArrRangeDimEnd275 (TaskFuncEmit) | `R11U275_TFARRRANGEEND_OFF` | 5: r10uvm122repro g122_b_shape, g122_d_pos, r10v122repro q1shapes, q7extra, r10v96repro/v96_a4_operands (all `differ:endcol(2)`) |
| § tpTypedVarInitNameSpan275 (ModuleEmit) | `R11U275_TPVARINIT_OFF` | 5 alone: r11u108repro/grid/f5/f5a18_init, r11u110repro/grid/f2 i03_init_2state, i21_two_decl_init, v11u110repro/brk/v1 b01_init_unbased, b08_top_default_init (`differ:endcol`); 3 more with the next law |
| § defNetTpDimLastInstPat275 (UhdmExporter) | `R11U275_DEFNETTPPAT_OFF` | 7 alone: r11u108repro/grid/f5 f5a05_override, f5a16_ovr2state, r11u110repro/grid/e1/e30_var_body_ctl, v11u108repro/brk/f5 b08_two_inst_mixed, b29_override_packed_elem, v11u110repro/brk/v1 a33_parent_overrides_and_child_rt_port_bodyvar, d03_attr_dimless_two_decl_ctl (`differ:line` / `type`); with § tpTypedVarInitNameSpan275: r11u110repro/grid/f2/i02_init_child_ovr, v11u110repro/brk/v1 b11_nonlocal_param_init, b12_init_int_elem |

`R11U275_OFF` drops all six and gives pristine's bytes on 88 of 88 grid case-views; `R11U275_TRACE=<dir>` logs
every firing (one file per process, first line `OUT <-o path>`).

## The laws

### § tpPackedArrCaUnparent275 (UhdmExporter, design-final after § typeParamStructLastNetParent273) — `R11U275_TPPATRESET_OFF`

A type parameter whose default (or override) is an anonymous packed struct or union WITH packed dimensions
(`parameter type T = struct packed {..} [1:0]`, § typeParamAnonAggDefault107's wrapper) holds one
packed_array_typespec, parented at the type parameter. NetlistElaboration::elabSignal does not re-parent it (a
packed_array_typespec takes the getSimpleVarFromTypespec branch, no `spec->VpiParent(..)`), but
UhdmWriter::writeCont_assign ends every elaborated assignment with `tps->VpiParent(nullptr)` on the left side's
typespec (the bound signal's), so `assign o = i;` to a signal of the type leaves the array unparented, in every
instance and in the definition listing that shares it. Surelog stores no full name below it: the writer computes the
element ref's name through the final chain (nothing for the anonymous element), where ours had stored the chain
through the type parameter (`work@child.T`; probe cluster N0494). The law collects every elaborated instance's and
generate scope's type parameters whose actual is such an array, binds each continuous assignment's left side as
§ typeParamStructLastNetParent273 does (its own typespec, else the module instance's variables then nets by name, a
declaration-initializer cell by the signal of its name), unparents every array so assigned (our signal's own copy at
the same span too: golden has one object) and un-stores every full name below it that read the old chain.

A NAMED element (`localparam type rt_t = id_t [3:0]`, § typeParamNamedElemPackedDim31's wrapper) is outside the law:
golden keeps that array parented under a port or a plain body declaration (probe r11u108repro f5 f5a01, f5a03, f5a06,
v11u108repro b19 `output var rt_t o`, r11u31repro g4 — a first draft without the gate moved 18 such EQUAL probe cases
to `differ:fullname` on the dev probe check, refined before the freeze); only a body `var rt_t x;` resets it
(v11u108repro b18_var_kw), not modelled.

### § importNetTsDimEnd275 (ModuleEmit emitImportedPkgVarNets) — `R11U275_IMPNETDIMEND_OFF`

The module's (and the interface's) re-created typespec of an imported package declaration is listed as a definition
net, so UhdmWriter::writeNets runs on it the end-only populateCoreMembers the module's own nets get
(§ defNetEndOnlyLoc130, materializeDefNetTs): the END moves to the end of the FIRST unpacked dimension
(`wire [7:0] a_net [0:1];` golden 5:3-5:26, ours 5:3-5:14), or, with none, to the end of the FIRST packed dimension of
a multi-dimension packed declaration (`logic [1:0][7:0] v_pkd;` golden 18:3-18:14, ours 18:3-18:19). Probe cluster
N0040. A one-dimension declaration keeps the type span (grid IN in06); a dimension written by a macro keeps the raw
column (the law reads only non-macro locations).

### § ifaceGenCaLhsUnbound275 (ModuleEmit lhsTyped273) — `R11U275_IFGENUNBOUND_OFF`

writeCont_assign binds a plain left-side name with CompileHelper::bindVariable, which reads the variables and nets of
a `module_inst` only and walks every other scope up its parent chain (CompileStmt.cpp, bindVariable's switch). From a
generate scope of an INTERFACE the walk passes the interface_inst and goes on to the instantiating module, so the
interface's own signal is never found and the reduced value goes in untyped: golden lists the param_assign value
once, under the param_assign, where ours listed a copy at `assign i_gen = C.n;` inside `if (1) begin : gi`
(§ paramValRhsSharesParamConst273 and § fnRetLitRhsSharesDefConst273 both read lhsTyped273). An assignment at the
interface's own level keeps the measured copy (r11u88repro x6_ifdefcast, grid IG ig02); a namesake in the
instantiating module still binds (grid IG ig03); a module generate scope still binds its module (IG ig06).

### § tfLocalArrRangeDimEnd275 (TaskFuncEmit, the tf-item fixed-size array site) — `R11U275_TFARRRANGEEND_OFF`

A subroutine-local fixed-size array's array_typespec ends AFTER the closing bracket of a RANGED dimension
(`int v [0:3];` golden 59:9-59:16, ours 59:9-59:15) and before it for a SIZE dimension (`[4]`): the quirk emitPorts and
§ deferredPortUnpackedArrayTs already model; this site applied `end - 1` to every dimension. The last dimension
decides (grid TA ta04 `[0:1][0:3]`, ta06 `[2][0:3]`). Probe cluster N0127 (pass 268's sister-ground report pinned it
here: the `aEnd = dim0->sourceRange().end() - 1` span).

### § tpTypedVarInitNameSpan275 (ModuleEmit, the elaborated makeVar branch) — `R11U275_TPVARINIT_OFF`

A variable declared with a TYPE PARAMETER and an initializer (`rt_t x = 8'h5a;`, `T x = 4'h5;`) keeps its NAME span
in the elaborated view: elabSignal's DummyType road hands the signal the parameter's typespec and the object is
located at the name before the initializer's populateCoreMembers can stretch it (golden 2:8-2:9, ours 2:8-2:17
through the anonymous-typespec branch). A `var` or `const` declaration keeps the stretch (probe r11u110repro
i16_var_kw_init, v11u110repro b06_const_init; grid TV tv03, tv04 — a first draft without the gate grew both cases'
counts on the dev probe check, refined before the freeze). Probe cluster N1931.

### § defNetTpDimLastInstPat275 (UhdmExporter, design-final after the previous law) — `R11U275_DEFNETTPPAT_OFF`

`localparam type rt_t = id_t [3:0]` is compiled again for every elaborated instance: Surelog's
CompileHelper::compileParameterDeclaration (the paTYPE branch) looks the element up by name through the previous type
parameter's actual (the instance's own `id_t`, an override included), builds a new packed_array_typespec parented at
the DEFINITION's type parameter and re-points the parameter's DummyType at it, so a body signal declared `rt_t x;`,
which writeNets types through that DummyType after elaboration, reads the LAST elaborated instance's array in the
definition listing (golden `child`'s x: element `logic [1:0]` at the override 7:17-7:28 where ours bound the default
`logic` 1:38-1:43; with two instances the second's). The definition's own type parameter keeps its default. The law,
design-final: for every definition whose type parameter holds such an array, every net or variable of the definition
listing typed by it (or by our copy at the same span) takes a copy of the array the same-named signal of the
definition's last instance (depth first through instances and generate scopes) holds, re-parented at the declaring
type parameter with every name below it read through the new chain; an instance overriding the array parameter
itself is skipped (the one before it wins, grid TN tn03), and an instance whose element is the default's own moves
nothing (TN tn04). Probe cluster `line|logic_typespec under packed_array_typespec`.

## Grid (tools/probe/r11u275repro/cases: PA 9, IN 8, IG 7, TA 6, TV 7, TN 7 case dirs, both views; every grid line carries its exit code)

`drivers/grid.sh` on P (pristine), L (law), OFF (`R11U275_OFF=1`) and the law with each switch dropped alone;
`drivers/gridsum275.py` (`evidence/grid.txt`, 792 lines; `evidence/grid_summary.txt`): 88 case-views; OFF gives
pristine's bytes on 88 of 88; 60 case-views moving, each attributed to exactly one switch (DEFNETTPPAT 12,
IFGENUNBOUND 4, IMPNETDIMEND 14, TFARRRANGEEND 10, TPPATRESET 8, TPVARINIT 12), 47 entering STRICT_EQUAL, none leaving,
no exit code and no uhdm-cmp line count changing. Away census (`drivers/awaycv.sh`: drivers/away.py order-blind and
drivers/awaychain.py chain-keyed; `evidence/away_grid_movers.txt`): 0 lost and 0 chain-keyed away on 59 of the 60;
the 60th, TN/tn07_param_depth in the `--elabuhdm` view (stage of the strict walk `depth` on both binaries), loses 3
golden-agreeing records (the range bound `D` of the definition net's array, its parameter binding and that parameter's
int_typespec, which the elaborated clone of our copied array does not reach) and gains 4 (dump distance 2 -> 1); its
default view enters STRICT_EQUAL. A first refinement that carried the source's `Actual_group` across the copy did not
restore it and was withdrawn before the freeze (the delivered source rebuilds to the frozen md5); it stands as a residue.

Grid cases moving without entering: PA pa06 (a declaration initializer `T x = '0;`: our elaborated view writes no
cont_assign for it, so the reset leg cannot see it; TPVARINIT moves its span), IN in02 (a package NET's own listing,
the sister's ground, below), IN in05 / in07 and TA ta01 / ta03 / TV tv06 (uhdm-cmp stage 1 on both binaries), TN tn07
in the elaborated view (above).

Downstream on the 44 grid dirs (`evidence/downstream_cases_*.txt`): 10 move to IDENTICAL (PA pa06, TN tn01, tn02,
tn03, tn06, tn07, TV tv01, tv02, tv05, tv07), none leaves IDENTICAL; the other 14 of the 24 movers are converted
probe cases.

## Census, sweeps and controls

- Firing census frozen before the law sweep (`drivers/tracecensus.sh` on the law binary under `R11U275_TRACE`, the
  probe and both corpora in both modes, the filter built from `$FENCED`): `evidence/predict.txt` (md5 in
  predict.md5), 49 lines: 47 probe cases and surelog FuncDeclScope d/t (IFGENUNBOUND fired on its left-side binding).
- Law gate sweep `tests/sweep.sh --jobs 3` (`evidence/sweep_law_summary.txt`, exit 0): probe 3721 EQUAL + 366
  STRICT_NOTEQUAL, regressions=0 conversions=39 changes=7; surelog default 476 + 4, testflags 470 + 4,
  regressions=0 conversions=0 changes=0; uhdm2rtlil 803 / 1 / 67 both modes, regressions=0 conversions=0 changes=0;
  downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the csv identical to the pristine
  sweep's. The pristine sweep (same harness, same-length workdir) reproduces every baseline
  (`evidence/sweep_pristine_summary.txt`; exit 1 on the law-index check alone: the new case dirs were in the worktree
  and the index was regenerated after that check had run; the law sweep reads the index current).
- The seven changes, each attributed by the census and the grid: r10uvm122repro/g122_f_clone endcol(7) -> fullname(3)
  (TFARRRANGEEND clears its four array-span records; the three left are the import-clone naming
  `p122f_home::f122f::hv` / `p122f_expl::...`, the walk unchanged before them); r11u77repro/grid/y4_bindreach
  endcol(4) -> (2), r11u82repro/grid/w3_arraynet endcol(4) -> (2), r11u88repro/grid/y1_pkgnetkind endcol(3) -> (2)
  (IMPNETDIMEND clears the module copies; the records left are the package NET's own listing, the sister's ground);
  r11u88repro/grid/i6_ifarray endline(23) -> (15), r11u88repro/grid/y2_pkgvarkind endline(23) -> (21),
  r11v77repro/grid/vh_arrelem endline(37) -> (35) (IMPNETDIMEND, the same first field and walk, fewer records). One
  more probe database moves with its detail unchanged: v11u110repro/brk/v1/b06_const_init `differ:endline(4)`
  (DEFNETTPPAT converts its definition-view face; the four records left are the `const` elaborated view).
- Probe byte movers: 47 of 4087 databases, exactly the predicted 47. Away census on all 47
  (`evidence/away_probe_movers.txt`): 0 lost order-blind, 0 chain-keyed away.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered hard-link mirrors
  (`drivers/bvmirror.sh`, 2560 of 2568 databases, 8 fenced row-modes left out): MOVERS 0 / 2560, SELFCHECK 2559 / 2560
  (the fixed reference equals itself); the predicted FuncDeclScope d/t did not move (IFGENUNBOUND's skip there leaves
  lhsTyped273's answer unchanged). Downstream lane databases: 0 of 805 fence-filtered move, with a positive control
  (two different rows flagged) (`evidence/byteverify_downstream.txt`).
- Binary-path audit (`evidence/binary_audit.txt`): 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary,
  the other 50 run no slang, none names another binary.
- Canaries (`evidence/canaries.txt`): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs.
- Determinism (`drivers/det.sh`, three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen with the law binary; `evidence/determinism_law.txt`): one hash per row-mode
  (12 row-modes; Scoreboard and Rggen have no testflags row), each equal to the law sweep's and to the pristine sweep's.
- Byte controls (`drivers/controls.sh`, every case dir of r11u273repro, v11u273repro, r11u271repro, v11u271repro,
  r11u269repro, r11u267repro, r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11u131repro, r11u107repro,
  r11u108repro, r11u110repro, v11u110repro, v11u108repro, r11u88repro, r11u77repro, r11u82repro, r11u183dec,
  r11u69repro, r11v69repro, r11u71repro, r11v71repro, r11u112repro, r11u130repro, r11u137repro and v11u93b107repro,
  path lists fence-filtered first; `evidence/controls.txt`, `controls_summary.txt`): 1375 dirs, 2750 case-views; 18
  moving, 6 entering STRICT_EQUAL (r11u183dec/cases/a/c07, r11u77repro/grid/xe_impkind, r11u88repro/grid/g11_iface,
  both views), none leaving, no exit code and no uhdm-cmp line count changing; away census on all 18
  (`evidence/away_control_movers.txt`): 0 lost, 0 chain-keyed away.

## The sister's ground at this base (reported, not written)

- SeqDriver d/t `differ:fullname(6)`: all six records the `inside`-set package-parameter fold (ExprEmit emitExpr).
- MiniAmiq d/t `differ:fullname(4)`: #227043 / #227046 / #227049 the same fold, and the walk divergence #227149 (the
  enum-alias cast binding, ParamEmit emitPackage's enum-alias branch plus ExprEmit). Not stubbed on a scratch binary
  here: what stands behind #227149 is still unread.
- Found by this pass: a package NET with an unpacked dimension (`wire [7:0] a_net [0:1];` inside a package) lists its
  own typespec without writeNets' stretch (golden 5:3-5:26, ours 5:3-5:14): ParamEmit's package-net branch beside
  § caPkgListingNetTypeIsPerView79 (the `s.MakeLogic_net()` package listing), the same rule as § importNetTsDimEnd275;
  it would convert r11u77repro/grid/y4_bindreach, r11u82repro/grid/w3_arraynet and r11u88repro/grid/y1_pkgnetkind
  (grid IN in02).
- The largest ground-A probe buckets at the law sweep: `name` on `ref_obj` under an elaborated cont_assign (25 cases,
  the struct-parameter read `assign o = P;`), `fullname` on a ref_typespec under `operation | typespec_member`
  (24 cases, the struct-valued function fold inside member typespec ranges, ParamEmit), `name` on an alias
  logic_typespec (10, `home48::w48_t`).

## Residues on this ground, ranked by probe cases (all wrong on pristine too)

The map's ground column (tools/probe/r11u230map/probe_fail_list.csv) reads 228 A and 137 B over the 366 left (it
predates this pass: 15 of its A pins were TypeEmit / ModuleEmit / UhdmExporter sites this pass converted).

1. `fullname` on struct-member ref_typespecs outside type parameters (13 cases: r10sd10repro g4, g6, v2, v9, v13, v14,
   r10sd6repro/v3_hier_path, r11u107repro a08, a18, t13, v11u93b107repro/p02, r10v136repro/v136_d_homes): package
   and class typedef listings whose last writer the 134 / 212 models do not reach.
2. The share family's remaining `type|constant under cont_assign` (7: a member of a concatenation-valued pattern
   r11u114repro a25 / a28, v11u114repro g25; r11u109repro/p03_ready; a class static call r10v111repro/v111_b6;
   r10vrgg9repro/w_typeparam, r10vrgg6repro/w_two_ctx_order).
3. `fullname` under `constant | operation` in rgg4 (5: r10rgg4repro a1, b1, c1, r10vrgg4repro v5k, r10v64repro v7).
4. Four-case buckets: bit_typespec ref names (r10uvm207repro c, e, h, r10sd5repro v6), class_typespec endcols
   (r10v150repro f1, r10v119repro j, r10sd1repro b27, r10uvm56repro v3; plus 5 more at class_defn / logic_net),
   indexed part-select ref_obj names (v11u112repro b4b, b4d, b4h, v11u115repro v06).
5. This pass's own open shapes: the named-element type parameter (§31) in a body `var` declaration (b18_var_kw) and in
   a chain whose instance recompiles the inner array (r11u110repro e18_chain_rt), an always_ff-driven var (b21); the
   declaration-initializer reset of § tpPackedArrCaUnparent275 (grid PA pa06: no cont_assign in our elaborated view);
   § defNetTpDimLastInstPat275 on extra packed or unpacked dimensions over the array (`rt_t [1:0] x`, `rt_t x [2]`:
   r11u110repro i09, i11, v11u110repro d01, d02) and its `--elabuhdm` parameter-bound face (grid TN tn07); the type
   parameter's def-view port and parameter faces (r11u110repro e25, v11u93b107repro r05, v11u110repro a11);
   `var` / `const` type-parameter declarations with an initializer in the elaborated view (i16, b06: the array's end).
6. Items (2) to (7) of the brief beyond the above (pass 273's share and type-parameter shapes, vt03, the
   generate-scope delay, the `var` detection from the syntax tree; pass 271's net-declaration neighbours; pass 269's
   clone-law and select-fold shapes, the package listing order, typedefParentModel134's cast-copy re-parent; passes
   267 / 265 / 263 / 261 / 259 residues): not attempted.

## Process notes

- The fence: every corpus path list was filtered by `$FENCED` (word boundary) before anything was opened; the census
  used the fence filter; byteverify ran on fence-filtered hard-link mirrors; the downstream byte compare listed paths
  first and filtered them; no fenced database or source was read.
- The first control run invoked drivers/case.sh before it was made executable and wrote nothing (every line
  `Permission denied`); it was rerun after `chmod +x` with the same arguments.
- The worktree's `build/slang-uhdm` was rebuilt while the pristine sweep ran (that sweep ran the frozen copy under
  `/tmp`, as the binary audit shows), restoring the source to the frozen law's bytes after a withdrawn refinement.
- No process was signalled. Nothing was written outside the worktree and `/tmp/r11u275_*` scratch.

## Files

- `cases/PA` (§ tpPackedArrCaUnparent275), `cases/IN` (§ importNetTsDimEnd275), `cases/IG`
  (§ ifaceGenCaLhsUnbound275), `cases/TA` (§ tfLocalArrRangeDimEnd275), `cases/TV` (§ tpTypedVarInitNameSpan275),
  `cases/TN` (§ defNetTpDimLastInstPat275): each `dut.sv` names its law on its first line.
- `drivers/`: copied from r11u273repro/drivers (env.sh, case.sh, grid.sh with this pass's switches, tracecensus.sh with
  `R11U275_TRACE`, controls.sh, ctlsum.py, det.sh, bvmirror.sh, away.py, awaychain.py, awayrows.py, awaydump.py,
  awaycorp.sh, strictcmp_x.cpp, cc_x.sh, dscases.py) plus gridsum275.py and awaycv.sh.
- `evidence/`: grid.txt, grid_summary.txt, predict.txt + predict.md5, probe_conversions.txt, away_grid_movers.txt,
  away_probe_movers.txt, away_control_movers.txt, byteverify_corpus.txt, byteverify_downstream.txt,
  downstream_cases_pristine.txt, downstream_cases_law.txt, determinism_law.txt, binary_audit.txt, canaries.txt,
  sweep_law_summary.txt, sweep_pristine_summary.txt, controls.txt, controls_summary.txt.
