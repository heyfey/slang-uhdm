# r11u289 — module/type ground: the struct-parameter member read takes the producer's own value object

Base af6dc102 (pass 287). Seven laws in ModuleEmit behind `src/R289.h`. Each law reads its own
`R11U289_<LAW>_OFF` switch. `R11U289_OFF` drops all of them and gives pristine's bytes on 116 of 116 grid
case-views. `R11U289_TRACE=<dir>` logs every firing and abstention (one file per process, `OUT <-o path>` first).

**FIVE PROBE CONVERSIONS**, no probe change, no regression. No corpus row changes status or strict column, and no
corpus database moves (0 of 3365).

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| r11u114repro/grid/f1/a25 | `type(1)` | **EQUAL** | § caStructParamModSharesPaOperand289 |
| r11u114repro/grid/f1/a28 | `type(1)` | **EQUAL** | § caStructParamModSharesPaOperand289 |
| v11u114repro/grid/set1/g25 | `type(1)` | **EQUAL** | § caStructParamModSharesPaOperand289 |
| r11v83repro/grid/b14_cadelay | `type(1)` | **EQUAL** | § caStructParamIfaceCloneReused289 |
| r11u88repro/grid/j3_ifcaselect | `type(1)` | **EQUAL** | § caStructParamIfaceCloneReused289 with § caIfaceSelLhsTakesSharedRhs289 |
| probe | EQUAL 3888 + STRICT_NOTEQUAL 199 | **EQUAL 3893 + STRICT_NOTEQUAL 194** | regressions 0, changes 0 |
| surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

All five conversions are STRICT_EQUAL in the elaborated view too (j3_ifcaselect's elaborated view was at uhdm-cmp
stage 1 on pristine, 43 lines).

## The face

A continuous assignment whose right side reads a member of a struct parameter (`assign o = IMPL.a;`). Surelog's
`UhdmWriter::writeCont_assign` reduces the right side. For `P.a` the reduce hands back the elaborated instance's
param_assign operand: the flattened pattern's member constant. Then `CompileHelper::adjustSize(tps, ...,
uniquify=true)` runs with `tps` = the Lhs's typespec, and `res->VpiParent(assign)`.

- `adjustSize` CLONES only a vpiUIntConst (and an unsized fill, or a signed int-typed binary with its sign bit set).
  Every other kind is returned as is and becomes the cont_assign's Rhs. The walk lists it once, under the
  param_assign, and skips it at the cell.
- It mutates that shared object in place:
  - a binary constant on a logic Lhs keeps its low Lhs-width bits when it is wider;
  - a binary constant typed int (its own unsigned int_typespec, a replication's product, or an int Lhs) narrows
    its size to the Lhs width;
  - a hex or octal constant takes the Lhs width (the `else { c->VpiSize(size); }` branch);
  - a decimal constant keeps its own size.
- In an interface `tps` is null on every cont_assign (bindVariable's switch has no interface_inst case), so
  `adjustSize` returns at once.
- WHERE the parameter is declared decides the object (measured, grid MS / MI):
  - a PACKAGE parameter (imported, explicitly imported, or read inside an interface that imports it): the operand
    itself;
  - the instance body's OWN parameter or localparam at module level: a fresh CLONE of the operand (pass 282's decode
    of CompileExpression's getValue). The clone the FIRST cell's read makes is the one every later cell of that
    instance reading the same member takes;
  - inside a generate block, a module parameter too reduces to the operand itself (pass 287's law 4 for the untyped
    Lhs; this pass for the typed one).
- Ours minted a fresh constant at the member's width per cell (§ caStructParamPatternSubst55's emitter). The judge
  cannot see the identity, but the walk lists one extra record (`type(1)`), and where the encodings differ (BIN
  versus UINT, the mutated size) uhdm-cmp reads stage 1.

## The laws

1. **§ caStructParamModSharesPaOperand289** (ModuleEmit `emitContAssigns`, before the § caStructParamPatternSubst55
   emission; switch `R11U289_MODCASHARE_OFF`).
   - A module-level whole-name Lhs reading a PACKAGE parameter's member takes the instance's param_assign operand
     itself, mutated in place as `adjustSize` does (`modCaAdjustKeeps289`, `shareAdjust289`), re-parented at the
     cell.
   - Abstains on a vpiUIntConst, an unsized fill, x/z digits, a 1-bit or signed-int binary, an int or string
     constant.
2. **§ caStructParamModClonesPaOperand289** (same site; switch `R11U289_MODCACLONE_OFF`).
   - The instance body's own parameter: a clone of the operand (value, decompile, size, type, span, a reference to
     the same typespec), re-sized the same way. A later cell reading the same member takes the first cell's clone
     and re-sizes it in place (grid MS m31, m32).
3. **§ genCaStructParamTypedLhsShares289** (ModuleEmit `emitGenScopes`, after § genCaStructParamSharesPaOperand287;
   switch `R11U289_GENCATYPED_OFF`).
   - The typed twin of pass 287's law 4: a generate-scope whole-name Lhs that bindVariable types (pass 71's adjWt
     non-zero) takes the operand under the same `adjustSize` model, for package and module parameters alike.
4. **§ caStructParamIfaceSharesPaOperand289** (ModuleEmit `emitInterfaceInstance`, the § caIfaceBodyCaFolds83
   branch; switch `R11U289_IFCASHARE_OFF`).
   - In an interface, a PACKAGE parameter's member read takes the operand itself, unchanged.
5. **§ caStructParamIfaceCloneReused289** (same branch; switches `R11U289_IFCLONEREUSE_OFF` for the later cells and
   `R11U289_IFCLONEFIRST_OFF` for the first).
   - The interface's OWN parameter: the first cell's read makes a clone of the operand; every later cell of that
     instance reading the same member takes it.
   - Ours minted one constant per cell. b14_cadelay's `d_plain` reuses `d_del`'s `8'd6`.
6. **§ caIfaceSelLhsTakesSharedRhs289** (same branch; switch `R11U289_IFSELSHARE_OFF`).
   - A struct-parameter member read written onto a bit- or part-select Lhs in an interface gets a fresh elaborated
     cont_assign. Its select Lhs carries the elaborated name (`work@dut.u_i.bitsel`, the index or both bounds
     copied; a part-select re-list is new here).
   - Its Rhs is the object the member's read already gave the instance: the package operand, or the interface's
     clone from an earlier cell.
   - Ours kept the definition's cell (hier_path Rhs, `work@ifc.bitsel`).
   - A select cell that comes before every whole-name read of the member abstains (MI/i09, residue).

Two gates are shared by all seven, both added after the byte controls convicted a draft:

- `setterKindOk289`: the setter must be a literal, a concatenation or a replication.
  - Under a draft that took every setter, tools/probe r11v56repro/grid x2_enum (an enum-valued member) and x4_nest
    (a `'1` inner `default:` fill) read chain away 1 in both views. Our operand carries our encoding there, golden
    the reduce's.
- `opAtSetter289`: the operand reached by field index must start where the setter does.
  - Our elaborated pattern lists no operand for some members (`'x`), which shifts every later index. Under a draft,
    r11u56repro/grid/e1_enc56 `hx` took `bn`'s operand (chain away 1, the record `HEX:BEEF` 43:35).
  - A macro-expanded setter abstains.

## Gates (law binary d6bea85a8c605e723527f3c612da2739; pristine 79b73d19da0324ee68ff7fe6adaa2f56 = the main tree's)

- **tests/sweep.sh --jobs 3**, all four stages (evidence/sweep_L.log):
  - probe: regressions=0, conversions=5, changes=0 (EQUAL 3893 + STRICT_NOTEQUAL 194).
  - surelog: 0 / 0 / 0 (default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2).
  - uhdm2rtlil: 0 / 0 / 0 (803/1/67 both modes).
  - downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0. The csv is byte-identical to
    pristine's and to results/downstream_uhdm2rtlil.csv.
  - The surelog csv equals pristine's except the workdir path in the LowMemLib / LowMemPkg testflags detail. The
    uhdm2rtlil csvs are identical.
  - The sweep exited 1 on the law-index check alone; this patch regenerates tests/LAWS.md.
- **Pristine sweep** (evidence/sweep_P.log): probe 3888 + 199, surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67,
  downstream 803/66/2/0, each 0 / 0 / 0.
- **Predictor** (drivers/tracecensus.sh, R11U289_TRACE over the probe cases and both corpora in both modes, fence
  filtered). It ran on the final binary and was frozen before the law sweep (evidence/predict.txt, 17 lines):
  - 11 probe databases: the 5 targets, plus 6 where a law fires but writes the bytes pristine wrote. Those 6 are
    MODCACLONE on r11u51repro/e1_ca_rhskind and r11v55repro vv4_singleread, vv6_edge, vv8_sharemut, and
    IFCLONEFIRST on r11u69repro/g11_iface and r11v83repro/b18_xmember.
  - 6 corpus row-modes, all MODCACLONE: uhdm2rtlil StructLocalParam, StructParameter and
    struct_param_pattern_packing, each d/t. The clone equals the constant pristine minted, so no byte moves.
- **Byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors from
  drivers/bvmirror.sh; 8 fenced row-mode databases left out; evidence/byteverify_corpus.txt):
  - **0 of 3365 corpus databases move** (surelog, uhdm2rtlil, downstream).
  - SELFCHECK reads 3363 of 3365, the known twin of downstream/1DUnpackedArray.
- **Probe byte compare** (evidence/byteverify_probe.txt, the same 4087 paths on both sweeps): **5 of 4087 move**,
  exactly the five conversions, each predicted by name.
- **uhdm-cmp**: 0 lines on every converted case and every corpus row (no corpus database moved).
- **Canaries** (evidence/canaries.txt): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 PASS on both
  csvs (EXPECT_UNKNOWN=1 and 6).
- **Binary-path audit** (fence-filtered; evidence/binary_audit.txt): on each sweep, 3265 of 3315 cmds.txt name that
  sweep's own frozen binary, and the other 50 carry no slang line.
- **Determinism** (drivers/det.sh, three concurrent draws per row-mode with the law binary on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen; evidence/determinism.txt): one hash per
  row-mode, each equal to the law sweep's. Scoreboard and Rggen testflags write no database, as at the base.

## Grid (cases/; evidence/grid.txt, grid_summary.txt, grid_away.txt)

There are 58 case dirs: MS 33 module-level, MG 10 generate, MI 10 interface, and the 5 probe targets. Each is run
in both views, 116 case-views, every line with its exit code. Each case-view runs on pristine, the law, the law
with R11U289_OFF, and the law with each of the seven switches off.

- **90 moving, 80 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.** R11U289_OFF gives pristine's bytes on
  116 of 116.
- Attribution, by the switch whose removal alone restores pristine's bytes:

  | switch | moving case-views |
  |---|---|
  | MODCASHARE | 44 |
  | GENCATYPED | 18 |
  | MODCACLONE | 12 |
  | IFCLONEREUSE | 6 |
  | IFCASHARE | 2 |
  | IFSELSHARE | 2 |
  | IFCLONEREUSE and IFSELSHARE together (j3_ifcaselect) | 4 |
  | IFCLONEREUSE or IFCLONEFIRST alone (i04_el, i07_el) | 2 |

- Module-level conversions, in both views:
  - m01 concat, m02 hex, m03 bin, m04 wider Lhs, m05 narrower Lhs (stage 1 -> equal, the truncation), m06 two
    cells, m08 explicit import, m11 two instances, m13 replication, m14 sized decimal, m16 concat with a parameter,
    m17, m18 int member, m20 variable Lhs, m25 hex into a wider Lhs (stage 1 -> equal), m26 int Lhs, m27 binary
    into int, m28 octal, m33 two instances of different widths (stage 1 -> equal);
  - MODCACLONE: m09, m10, m31, m32, all stage 1 -> equal.
- Generate conversions:
  - g01, g07, g08 (two widths, the last writer's size), g09, g10 case generate;
  - g04 and g05 (stage 1 -> equal);
  - MS/m23 (a module parameter with an inline default in an if-generate).
- Interface conversions: i02, i05, i08 (stage 1 -> equal) and the elaborated views of i04 and i07.
- Unmoved controls: m15 (unsized, UINT, cloned by the producer), m30 (a cast setter), g03 (pass 287's select cell),
  g06, i01, i03 (STRICT_EQUAL on both binaries).
- **Away census** (drivers/awaycv.sh: order-blind away.py and chain-keyed awaychain.py): lost 0 and chain away 0 on
  all 90 movers.
  - The positive control (binaries swapped; evidence/away_poscontrol.txt) reads chain away 1 on m09, g05 and m33,
    and lost 3 / chain away 3 on j3_ifcaselect.
  - Its `dist 0 -> N` lines on stage-1 pristine cells are the comparator's object count once stage 2 runs, not a
    growth.
- **Downstream** (drivers/dscases.py, both binaries, 58 dirs; evidence/downstream_cases.txt):
  - 4 cases go EQUIVALENT -> IDENTICAL: m04, m26, m32 and g08, where the Rhs width now follows `adjustSize`;
  - 51 stay IDENTICAL, 2 stay EQUIVALENT (i06, i10) and 1 stays DIVERGENT (m24, below). None gets worse.

## Byte controls (evidence/controls.txt, controls_summary.txt, controls_away.txt)

The controls cover 24 earlier repro dirs of this family and pass 287: r11u55, r11v55, r11u56, r11v56, r11u68, r11v68,
r11u69, r11v69, r11u71, r11v71, r11u74, r11v74, r11u83, r11v83, r11u85, r11u88, r11v88, r11u109, r11u114, v11u114,
r11u282, v11u282, r11u287 and v11u287. That is 1527 case dirs and 3054 case-views on pristine and the final law,
every line with its exit code, paths filtered by $FENCED before any case was opened.

- **50 moving, 22 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, lost 0 and chain away 0 on all 50.**
- Entering STRICT_EQUAL:
  - from stage 1: r11u287repro GS/s12_gen_plain_hex (pass 287's HEX residue), r11u55repro ve6_adjust_table,
    r11u85/r11u88/r11v83 b10_mixdecline, r11v55repro vv7_gensubst and v11u114repro g22;
  - from type: r11u83/r11u85 j3_ifcaselect and r11u85/r11u88 b14_cadelay (copies of the targets).
- r11v69repro/w3_widthcross moves stage 1 -> type in both views.
- The rest move inside stage 1 with the same uhdm-cmp line count and lost 0 / chain away 0: r11u56 e1_enc56 and
  e3_base56, r11u68 c1_stamp68, r11u69 g3_rhskind and g7_enc, r11u85/r11u88/r11v83 b4_calign, r11u85/r11u88 n1_ifnest
  and n3_nestkinds, r11v56 x1_optable, x2_enum, x3_names and x4_nest, r11v69 v6_memtypes.
- r11u85repro/x6_ifdefcast moves while STRICT_EQUAL on both binaries.

## Residues (ranked; all wrong on pristine too)

1. **The module-level select Lhs** (grid MS/m19_selLhs, `type` on both binaries).
   - Golden clones the cont_assign and shares the operand. Ours shares the definition's cell for every select Lhs
     at module level (the "Select-LHS assigns always stay shared" rule in emitContAssigns).
   - A fresh elaborated cell with a select Lhs would be needed, as pass 287 and law 6 do in their homes.
2. **The interface select cell before any whole-name read** (MI/i09_sel_first, stage 1 on both binaries).
   - Golden's first select cell makes the clone. A draft that minted it there saw the operand re-parented at the
     select cell by something downstream of the emitter (not decoded), so the law abstains.
3. **Overridden or package-defaulted module parameters**: m21, m22, m24, MG/g02, MI/i06, all stage 1 on both
   binaries.
   - The head is the instance's param_assign (golden keeps the package or override pattern operation where ours
     folds), ParamEmit, the sister's ground.
   - m24 is DIVERGENT downstream on both binaries.
4. **The second interface instance's signal bindings** (MI/i04, i07, default view, stage 1; the head is a `u_a.d`
   logic_var binding). The elaborated views convert.
   - MI/i10_two_inst_sel's stage-1 head moves later, from u_i's part_select to u_j's override param_assign, with
     the uhdm-cmp line count 51 -> 68 (55 -> 68 elaborated). Its earlier records now match.
5. **Qualified reads and nested members**: m07 `q2::IMPL.a` and m12 `IMPL.s.y`, stage 1 on both binaries
   (another face).
6. **Signed literals**: m29 `-8'sd3`, stage 1 on both binaries.
7. **The setters the gates refuse**: enum-valued members, `default:` fills and names keep the member emitter
   (x2_enum, x4_nest, e1_enc56, all stage 1).
8. **The rest of the probe residue**: 194 first records classified on the law sweep
   (evidence/residue_first_records_law.tsv; the base's 199 in residue_first_records_base.tsv). By first field:
   fullname 69, line 26, endcol 24, type 15, file 15, depth 15, name 9, col 8, endline 6, value 4, count 2,
   decompile 1. On this ground, located but not written:
   - **The positional interface-modport actual** (r11u1repro/grid2, r11v1repro/vA, `col`): golden's hier_path
     `u_df.mp` written positionally gives its first ref_obj the span of `mp` and leaves `mp` without a full name.
     The named form matches. Surelog's NetlistElaboration high_conn code does not write it; not decoded further.
   - **The type-parameter override written `.T(pk::w_t [1:0])`** (v11u111repro y61, y68, y69, `name`): golden binds
     the elaborated variable to the package listing `pk::w_t` itself with the dimensions dropped, where ours binds
     an unparented copy named `w_t`.
     - It is not TypeEmit's arrayElemTdClone42 (a breakpoint there never fired).
     - The debug build meant to find the writer was killed at startup by the machine.
     - y65 and y64 (positional overrides) are Surelog ignoring ordered type overrides.
   - The interface declaration order (pb10, pb19, v15), the class_typespec spans (a4_corpus, a6_headerforms, b27,
     v119_j), the modport net full names (vx8, v14) and the param_assign operation's net names (r11v70 v5, v11), as
     pass 287 listed them.
   - p03_ready (golden keeps the hier_path `I.y` where ours folds a cast member; elabReadNoValue's face), v111_b6
     and w_typeparam (`type`, the elaborated cont_assign Rhs of a package function initializer and a `$bits(T)`
     ternary).
9. Items (2) to (7) of the brief beyond the above were not attempted.

Sister-ground faces (ExprEmit / ParamEmit / StmtEmit; reported, not written):

- The instance param_assign of a module parameter whose default or override is a package or literal pattern (grid
  m21, m22, m24, g02, i06; ParamEmit). This is the head of residue 3.
- The rest as pass 287 listed them:
  - ParamEmit: the alias references on package typedef listings (6), the type-parameter struct member names (4),
    the chain borrow (3), the evalFunc member leftovers (3), the typedef-of-typedef parameter (3), the 64-bit cast
    range constants (4);
  - ExprEmit / ParamEmit: the generate-scope fold reference names;
  - the package function call folds (`depth`: r10buvm13 v3_clone13, r10buvm8 v9fold8, r10uvm52 a1).

## Process

- **Fence.** $FENCED was read fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line through
  drivers/env.sh semantics and never spelled.
  - The gate sweeps dispatched every row themselves.
  - The census ran through the harness filter built from $FENCED.
  - The byteverify mirrors, the binary audit and the control path lists were filtered by word boundary before any
    file was opened.
  - The decode helpers that open databases (objinfo.cpp, awaydump.py, case.sh) check $FENCED fail-closed. They
    were used only on grid, probe and tools/probe cases.
  - No process of another agent was listed or signalled. The main tree was not written.
- **Slips.**
  - The first background build's `&` detached from the task and died. It was rebuilt in the foreground.
  - A debug build of pristine (`-O1 -g1`) was SIGKILLed at startup on every run, even `--version`. It was deleted
    and no measurement used it.
  - Four law drafts were superseded:
    - the interface share took every home and broke MI i01 and i03;
    - the x/z digit scan read the `X` of `HEX:`;
    - the setter-kind gate and the operand-location gate came after the byte controls.
  - The grid, census, controls, sweeps, byteverify, canaries, audit and determinism were all rerun on the final
    binary.
  - Case first lines were relabelled to their law after a first grid. The case driver keys its goldens on the
    files' md5, so those goldens were rebuilt.
- tools/probe/r11u289repro: README, 58 case dirs in MS, MG and MI (each first line names its law), drivers
  (copied from r11u287repro with gridsum289.py and ctlsum289.py new), and evidence.
