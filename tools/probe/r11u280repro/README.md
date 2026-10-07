# r11u280 — pass 280, the expression/parameter ground (ExprEmit, ParamEmit)

Implementer of pass 280 (pair A, refill after pass 278), base c49f4f5c6. Five laws, four in `src/ExprEmit.cpp` and
one in `src/ParamEmit.cpp`, behind `src/R280.h` (each `R11U280_<LAW>_OFF`; `R11U280_OFF` drops all five and gives
pristine's bytes on 130 of 130 grid case-views; `R11U280_TRACE=<dir>` logs every firing and abstention, one file per
process, first line `OUT <-o path>`). The design-final drain of § hpMemVarSelNamesFinal280 is called at the end of
ParamEmit's `drainShareDefParamTs` (the last pass of this ground).

**Verdict.** No corpus row converts or moves (byteverify 0 of 2560 corpus databases, 0 of 805 downstream
databases); **FOUR PROBE CONVERSIONS** and five probe changes toward golden, every one predicted by name by the
firing census frozen before the law sweep (9 lines, all probe, 0 corpus; exactly the 9 byte movers). The Surelog
corpus stays at zero open rows (every row-mode CMP_EQUAL except the known failures LogicTypespec d/t and
Scr1SvTests d/t), uhdm2rtlil 1606 + 0, downstream 803 / 66 / 2 / 0 with the csv byte-identical to pristine's and to
results/downstream_uhdm2rtlil.csv.

Fresh csv rows of the conversions (`results/` untouched; the law sweep's `probe.csv`):

    r10svs4repro/g1_thisidx,EQUAL,,equal          (was differ:col(2))     § hpMemVarSelRvalSpan280 + § hpMemVarSelIdxNamesByChain280
    r10uvm147repro/g147_a,EQUAL,,equal            (was differ:col(6))     § hpMemVarSelRvalSpan280 + § hpMemVarSelIdxNamesByChain280
    r11u39repro/a1,EQUAL,,equal                   (was differ:col(6))     § hpMemVarSelRvalSpan280 + § hpMemVarSelIdxNamesByChain280
    r10vearl105repro/v7_repl105,EQUAL,,equal      (was differ:fullname(8)) § genLoopDirectBoundPaCopy280

The five changes (all toward golden, chain-keyed away census 0 on each, evidence/away_probe.txt):

    r10earl29repro/b1_sites            differ:col(10)     -> differ:fullname(4)   VSRVSPAN + VSIDXNAME (o1's `z.g[{1'b0, k[0]}][3]`
                                       cleared, toward 6; the new head is o2/o3's bit_select `k[0]` inside a bit_select element's
                                       index, a different site, residue 3)
    r10uvm92repro/v92_b2_varsel        differ:col(2)      -> differ:fullname(1)   VSRVSPAN (the element column cleared, toward 1; the
                                       new head is a NESTED path `bb.q` inside the inner var_select's index, which the index law
                                       abstains on, residue 3)
    r11u88repro/grid/i6_ifarray        differ:endline(13) -> differ:endcol(1)     § pkgNetNamedTsDimEnd280 (12 records cleared; the
                                       left one is the importing interface's struct_net copy, the sister's, below)
    r11u88repro/grid/y2_pkgvarkind     differ:endline(21) -> differ:endcol(1)     § pkgNetNamedTsDimEnd280 (20 cleared; the module
                                       import copy left, the sister's)
    r11v77repro/grid/vh_arrelem        differ:endline(33) -> differ:endline(9)    § pkgNetNamedTsDimEnd280 (24 cleared; the variable
                                       road's `si_t` / `en_t` left, abstained by design, residue 2)

## The laws

### § hpMemVarSelRvalSpan280 (ExprEmit, the member-path multi-select site) — `R11U280_VSRVSPAN_OFF`

A member path ending in two or more element selects (`m0.sat[s_i][1]`, `rw.value[idx][3]`, `z.g[{1'b0, k[0]}][3]`,
`pkt.m2[k][1]`) is a hier_path whose last element is a var_select. In an RVALUE Surelog's element spans the final
member's name through the last bracket (golden r11u39repro/a1 `sat` 42:19-42:30), the span the lvalue branch already
wrote; ours spanned the whole path from the root token (42:16). The site is the "Nested selects whose leaf is a
member access" branch of emitExpr's element-select branch (the root a NamedValue). Trace `VSRVSPAN <path>`.

### § hpMemVarSelIdxNamesByChain280 (ExprEmit, the same site) — `R11U280_VSIDXNAME_OFF`

Surelog stores no full name on the objects of that var_select's index list, so UHDM's ComputeFullName derives them
from the parent chain: a ref_obj directly under the var_select keeps the var_select's name above it (only a
bit_select, an indexed part select or a hier_path is skipped above a ref_obj) and the hier_path's name is kept
above the var_select: golden `work@dut.m0.sat[s_i][1].sat.s_i`, a class function's
`q147a::drv147::fa::rw.value[idx][3]::value::idx`, a bit select inside a concatenation index
`work@b1_sites.z.g[{1'b0,}][3].g.k`; ours stored `m0.sat[s_i][1].s_i` (the path text as prefix, no scope, no
element name). The names are built from the emission prefix with § trailIdxNestedNames187's per-link rule
(references and one-level selects directly under the var_select or under unnamed operations, a reference below a
bit_select or an indexed part select skipping it); a call, a nested path or a nested var_select inside an index
abstains for its subtree (traced `VSIDXNAME abstain <kind>`). The lvalue branch shares the site and is reached too
(grid VR/r22, both views converting). Trace `VSIDXNAME <name>`.

### § hpMemVarSelNamesFinal280 (ExprEmit `hpMemVarSelNamesDrain280`, called at the end of ParamEmit `drainShareDefParamTs`) — `R11U280_VSFINAL_OFF`

The same names design-final: every var_select of the site is recorded at emission and re-named at the end of this
ground's last drain with ComputeFullName over its FINAL parent chain (`chainFullName280`, the walk of UHDM
BaseClass::ComputeFullName), and so is every object the index law names. The emission-time branches use the scope prefix
and the var_select's own lazily frozen name, which a chain completed later does not reach: a process two generate
levels down (grid VR/r08: golden `work@top.ga[0].gb[0].z.g[k][j].g`, ours frozen as `work@top.z.g[k][j].g` before
the always reached its scope; both views convert) and a port actual (VR/r27: golden `work@top.u.a.z.g[k][1].g.k`, the
chain through the port and the instance that owns it; the elaborated view converts, the default view moves on to a
pre-existing binding face). With `R11U280_VSIDXNAME_OFF` the drain renames only the var_selects. Trace
`VSFINAL <name>` where a name changes.

### § pkgNetNamedTsDimEnd280 (ParamEmit, the package net listing `emitOne9`, beside § pkgNetTsDimEnd274) — `R11U280_PKGNAMEDDIMEND_OFF`

UhdmWriter::writeNets (third_party/Surelog/src/DesignCompile/UhdmWriter.cpp) asks compileTypespec for a package net's
type and moves the END of whatever it returns to the end of the net's first unpacked dimension
(`fC->populateCoreMembers(InvalidNodeId, dimensions, ts)`). For a net whose element type is a typedef
(`st_t v_sarr [0:1];`) that is the package's OWN typedef object, shared by every listing of it, so the typedef reads
stretched everywhere: golden i6_ifarray `pk::st_t` 5:11-7:27 (the end of `[0:1]` on line 7), ours 5:11-5:58; with
several such entries the last one written wins (y2_pkgvarkind 10:11-19:33). § pkgNetTsDimEnd274 moved only the
anonymous typespec it mints; this moves the named element typedef the branch binds, for the package's own entries
listed as nets with an unpacked dimension on the declarator. Abstains (traced): a dimension end written by a macro
(PS/p10, golden stretches to the macro use; left as pristine), a typedef declared in ANOTHER package
(PS/p11: golden stretches the home package's elaborated listing object and keeps its definition listing's
unstretched where ours lists one object in both; measured, the unguarded draft moved that listing away, so the
guard was added before the census), no unpacked dimension. Not the variable road (emitPackageVar's array_var: a
struct with an int member, an enum element): golden stretches the typedef in ONE of its two package listings there
(vh_arrelem `si_t`, `en_t`) where ours lists one object in both; a draft that stretched it moved the other listing's
records away (4 records on vh_arrelem) and was dropped. Trace `PKGNAMEDDIMEND fire|abstain ...`.

### § genLoopDirectBoundPaCopy280 (ExprEmit `loopDirectBoundPa280`, the c5 copy branch of § genCaTopLoopParamPaCopy105) — `R11U280_LOOPBOUNDCOPY_OFF`

§ genLoopDirectBoundPaConst262 for the ENCODING COPY. A parameter that IS a select's bound (a part-select bound, an
indexed part select's base or width) in a for-generate body's continuous assignment is Surelog's clone of the
parameter's elaborated constant (CompileExpression's `clone_tree(param_ass->Rhs())`, `result->VpiParent(param_ass)`):
parented at the instance's param_assign, its reference named by the instance. Pass 262 wrote that on the decimal mint
(c9); the copy branch that reproduces a non-decimal encoding (c5: a parameter whose elaborated value is a replication
fold, `localparam logic [3:0] R4 = {2{2'b01}}`, `BIN:0101`) still parented the copy at the select and named it by
the generate scope: golden v7_repl105 `sig[R4 +: 2]`, `sig[R4+1 : R4]` read `work@v7_repl105.u_leaf`, ours
`...u_leaf.gen_r[0]`. Same gates as pass 262's, its verifier's § loopBoundBinOperandPlainLhs262v included. Trace
`LOOPBOUNDCOPY <old> -> <new>` / `abstain`.

## Grid (drivers/grid.sh, case.sh, gridsum.py, attrib.py; evidence/grid.txt, grid_summary.txt, grid_attrib.txt)

65 fresh case dirs, each naming its law(s) in its first line: cases/VR r01-r28 (§ hpMemVarSelRvalSpan280,
§ hpMemVarSelIdxNamesByChain280; § hpMemVarSelNamesFinal280 acts on r08 and r27), cases/PS p01-p19
(§ pkgNetNamedTsDimEnd280), cases/LB b01-b18 (§ genLoopDirectBoundPaCopy280); both views (default and
`-elabuhdm` / `--elabuhdm`), each on pristine, the law, the law + R11U280_OFF and the law + each of the five
switches: **130 case-views, 1040 lines, every line with its exit code; 94 moving, 69 entering STRICT_EQUAL, 0
leaving, 0 exit-code changes, 0 uhdm-cmp line changes; R11U280_OFF gives pristine's bytes on 130 / 130.** Per
family: VR 56 case-views, 50 moving, 33 entering; PS 38, 24, 18; LB 36, 20, 18. The laws acting on each mover (a
single switch off changes the law's bytes; evidence/grid_attrib.txt): LOOPBOUNDCOPY 20, PKGNAMEDDIMEND 24,
VSRVSPAN alone 6 (literal indices), VSRVSPAN + VSIDXNAME 40, VSRVSPAN + VSIDXNAME + VSFINAL 4 (VR/r08 and r27); the
movers of single-law families return to pristine's bytes under exactly that switch.
**Away census** (chain-keyed, tools/probe/r11u272repro/drivers/awaychain.py with strictcmp_x built by its cc_x.sh,
drivers/awaygrid.sh; evidence/away_grid.txt): **away 0 and flat away 0 on all 94 movers**; positive control
(binaries swapped on VR/r01 d, PS/p01 d, LB/b01 d, VR/r08 e) away 4, 7, 4, 12 (evidence/away_poscontrol.txt).

Coverage. VR: rvalue member multi-selects in a module continuous assignment, an always_comb, a module function, a
task, a package function, class methods (a member of `this` class and a handle's member), for-, if- and
case-generate scopes, two generate levels, instance depths 1-3, a macro-written path, a port actual, an operand /
ternary branch / concatenation member, an implicit net index, parameter and localparam indices (the constant
slots), operation, concatenation, part-select and indexed-part-select indices, a call and a nested path inside an
index (the abstentions), three selects, a two-member path, an unpacked member array, and the lvalue beside the
rvalue; interface and `this.` paths (r09, r10, r14) are stage 1 on both binaries and do not move. PS: a variable
and a wire of a struct, union and logic-vector typedef, two entries of one typedef (the later wins), net-then-variable
and variable-then-net order, two unpacked dimensions, dynamic arrays and queues, two declarators, a header package,
a macro dimension (abstains), a typedef from another package (abstains), a scalar and a packed dimension, an enum
and an int-member struct (the variable road: already golden's, untouched), an interface and a generate block using
the typedef. LB: a replication-fold localparam as an indexed part-select base and width and as part-select bounds,
child instances at depths 1-3, the select as a binary operand under a plain or generate-local left side, under a
concatenation, a ternary and a unary operator, a bound inside an operation (not a direct bound: untouched), if- and
case-generate, two for-generate levels, overridden int parameters in binary / hex spelling, an always_comb, a select
left side, a macro, a header parameter, an imported package parameter, a decimal int control, an interface body, a
bit-select index and a plain operand (other windows, controls).

Per case (`d` and `e` views, pristine -> law; `(bytes =)` = byte-identical; EQ = STRICT_EQUAL):

| case | result |
|---|---|
| LB/b01_repl_ips | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b02_repl_ps | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b03_child | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b04_binop_plain | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b05_binop_local | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b06_concat_tern | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b07_bound_op | d: rc0 fullname -> rc0 fullname (bytes =) ; e: rc0 fullname -> rc0 fullname (bytes =) |
| LB/b08_ifgen | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| LB/b09_twolevel | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| LB/b10_ovr_bin | d: rc0 stage1(64) -> rc0 stage1(64) (bytes =) ; e: rc0 stage1(64) -> rc0 stage1(64) (bytes =) |
| LB/b11_process | d: rc0 stage1(58) -> rc0 stage1(58) (bytes =) ; e: rc0 stage1(58) -> rc0 stage1(58) (bytes =) |
| LB/b12_select_lhs | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b13_macro | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b14_header_param | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| LB/b15_pkg_param | d: rc0 stage1(50) -> rc0 stage1(50) (bytes =) ; e: rc0 stage1(50) -> rc0 stage1(50) (bytes =) |
| LB/b16_int_plain | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| LB/b17_iface | d: rc0 stage1(126) -> rc0 stage1(126) ; e: rc0 stage1(126) -> rc0 stage1(126) |
| LB/b18_bitsel_idx | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| PS/p01_struct_var | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| PS/p02_struct_net | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| PS/p03_two_uses | d: rc0 endline -> rc0 endcol ; e: rc0 endline -> rc0 endcol |
| PS/p04_order_net_var | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| PS/p05_order_var_net | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| PS/p06_union | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| PS/p07_logic_td | d: rc0 stage1(58) -> rc0 stage1(58) (bytes =) ; e: rc0 stage1(58) -> rc0 stage1(58) (bytes =) |
| PS/p08_multi_dim | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| PS/p09_dynamic | d: rc0 stage1(183) -> rc0 stage1(183) (bytes =) ; e: rc0 stage1(183) -> rc0 stage1(183) (bytes =) |
| PS/p10_macro_dim | d: rc0 endline -> rc0 endline (bytes =) ; e: rc0 endline -> rc0 endline (bytes =) |
| PS/p11_imported_td | d: rc0 endline -> rc0 endline (bytes =) ; e: rc0 endline -> rc0 endline (bytes =) |
| PS/p12_no_dim | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| PS/p13_packed_dim | d: rc0 stage1(197) -> rc0 stage1(197) (bytes =) ; e: rc0 stage1(197) -> rc0 stage1(197) (bytes =) |
| PS/p14_enum | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| PS/p15_int_member | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| PS/p16_iface_import | d: rc0 endline -> rc0 endcol ; e: rc0 endline -> rc0 endcol |
| PS/p17_generate_user | d: rc0 stage1(58) -> rc0 stage1(58) ; e: rc0 stage1(58) -> rc0 stage1(58) |
| PS/p18_two_decl | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| PS/p19_include | d: rc0 endline -> rc0 EQ ; e: rc0 endline -> rc0 EQ |
| VR/r01_struct_ca | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r02_struct_lit | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r03_op_idx | d: rc0 stage1(208) -> rc0 stage1(208) ; e: rc0 stage1(208) -> rc0 stage1(208) |
| VR/r04_concat_idx | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r05_param_idx | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r06_forgen | d: rc0 stage1(64) -> rc0 stage1(64) ; e: rc0 stage1(64) -> rc0 stage1(64) |
| VR/r07_ifgen | d: rc0 stage1(68) -> rc0 stage1(68) ; e: rc0 stage1(68) -> rc0 stage1(68) |
| VR/r08_twolevel_gen | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VR/r09_iface | d: rc0 stage1(76) -> rc0 stage1(76) (bytes =) ; e: rc0 stage1(76) -> rc0 stage1(76) (bytes =) |
| VR/r10_iface_port | d: rc0 stage1(76) -> rc0 stage1(76) (bytes =) ; e: rc0 stage1(76) -> rc0 stage1(76) (bytes =) |
| VR/r11_func | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r12_task | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r13_class | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r14_this | d: rc0 stage1(71) -> rc0 stage1(71) (bytes =) ; e: rc0 stage1(71) -> rc0 stage1(71) (bytes =) |
| VR/r15_pkgfunc | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r16_nested_member | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r17_three_sel | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r18_ps_idx | d: rc0 stage1(180) -> rc0 stage1(180) ; e: rc0 stage1(180) -> rc0 stage1(180) |
| VR/r19_ips_idx | d: rc0 stage1(184) -> rc0 stage1(184) ; e: rc0 stage1(184) -> rc0 stage1(184) |
| VR/r20_call_idx | d: rc0 stage1(174) -> rc0 stage1(174) ; e: rc0 stage1(174) -> rc0 stage1(174) |
| VR/r21_path_idx | d: rc0 stage1(164) -> rc0 stage1(164) ; e: rc0 stage1(164) -> rc0 stage1(164) |
| VR/r22_lhs | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VR/r23_inst_depth | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r24_macro | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r25_unpacked | d: rc0 stage1(71) -> rc0 stage1(71) ; e: rc0 stage1(71) -> rc0 stage1(71) |
| VR/r26_operand | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| VR/r27_portactual | d: rc0 col -> rc0 depth ; e: rc0 col -> rc0 EQ |
| VR/r28_implicit | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |

## Gates (law binary 479517a7c2af2dd64df98d1db915b89b; pristine 902d5954de344b684ebc9f7daf62e5dc = the main tree's build)

- Probe (tests/sweep.sh --corpus probe inside the full sweep): **regressions=0 conversions=4 changes=5** (EQUAL 3825
  + STRICT_NOTEQUAL 262; base 3821 + 266, the pristine sweep's probe stage reading regressions=0 conversions=0
  changes=0); every case uhdm-cmp-equal.
- Surelog: regressions=0 conversions=0 changes=0 (default 478 + 2, testflags 472 + 2); the law sweep's csv differs
  from pristine's only in the LowMemLib / LowMemPkg testflags detail text (the workdir path). uhdm2rtlil:
  regressions=0 conversions=0 changes=0 (803 / 1 / 67 both modes, csv byte-identical to pristine's). Both sweeps exit
  1 on the law-index staleness check alone (tests/LAWS.md regenerated last, in the patch).
- Downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, csv byte-identical to pristine's and to
  results/downstream_uhdm2rtlil.csv; **0 of 805 slang-lane databases move** (evidence/byteverify_downstream.txt).
- No corpus row is touched, so the uhdm-cmp-at-0-lines gate holds trivially on the corpora.
- **Firing census** (drivers/tracecensus.sh with R11U280_TRACE over the probe cases and both corpora in both modes,
  the fenced tests excluded by the harness filter built from `$FENCED`; frozen before the law sweep:
  evidence/predict.txt, md5 in predict.md5): **9 lines, all probe, 0 corpus**. **byteverify** (fence-filtered
  hard-link mirrors, tools/probe/r11u272repro/drivers/bvmirror.sh, 8 fenced paths skipped; tools/probe/r11v75repro/
  byteverify.sh, SELFCHECK=1): PATH_SETS_IDENTICAL 2560, **MOVERS 0 / 2560**; SELFCHECK reads 2559 / 2560 because
  every file is compared against one fixed file and that file is the one not flagged (pass 201's self-check
  artefact, not a mover). Probe: **9 of 4087 databases move, exactly the 9 predicted lines** (the 4 conversions and the
  5 changes; evidence/byteverify_probe.txt), the chain-keyed away census 0 on all 9 (evidence/away_probe.txt).
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6;
  evidence/canaries.txt). Binary-path audit over the fence-filtered cmds.txt list: 3265 of 3315 name each sweep's own
  frozen binary, 0 name any other slang-uhdm binary, the other 50 carry no slang-uhdm line (evidence/binary_audit.txt).
- Determinism (drivers/det.sh, three concurrent draws per row-mode): Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen default and the testflags row-modes with a database: one hash each, equal to the
  law sweep's (evidence/determinism.txt).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` first): 22 earlier repro dirs (r11u278,
  v11u278, r11u276, v11u276, r11u274, v11u274, r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u187, r11u133,
  r11u262, v11u262, r11u79, r11u77, r11v77, r11u39, r11u169, r11u154, r11u88), both views: **2656 case-views, 16
  moving, 0 entering, 0 leaving, 0 exit-code or uhdm-cmp line changes** (evidence/controls.txt, controls_summary.txt);
  the 16: r11u39repro/a3, r11u77repro y2_pkgvarkind, r11u79repro vb_unpackedfaces / vh_arrelem / y2_pkgvarkind /
  z5_pkgunpacked, r11v77repro vb_unpackedfaces and v11u278repro VS/vs08, both views each; chain-keyed away 0 on all
  16, toward 6 to 24 (vs08 toward 0, stage 1 on both binaries; evidence/away_controls.txt).
- Downstream on the 65 fresh case dirs (drivers/dscases.py, both binaries; evidence/downstream_cases_*.txt): 62
  IDENTICAL, 2 EQUIVALENT, 1 DIVERGENT on both, the same verdict per case; the slang lane's 195 `.il`,
  `_nohier.il` and `_synth.v` files byte-identical between the binaries.

## The probe residue at the base, by writer (evidence/residue_chains_base.tsv, residue_first_records_base.txt)

drivers/classify.py + chains.py over the 266 STRICT_NOTEQUAL cases of the base sweep (the first record and its
object chain), with the writer located by a gdb backtrace on a line-table build of the pristine source (`-g1`, a
second worktree; probe cases only) where the chain did not name it. Worked here: the member-path multi-select
element (5 cases: 3 converted, b1_sites and v92 moved), the package typedef stretch (i6, y2, vh: moved, the
remainders the sister's or abstained), the encoding copy in a loop bound (v7_repl105, converted).

## Decodes stopping at the sister's ground (reported, not written)

1. **The importer's struct_net copy end column** (i6_ifarray `work@dut.u_if.v_sarr` 7:15-7:27, y2_pkgvarkind
   `work@dut.v_sarr`, vh_arrelem `a_nsl` / `a_vsl`, PS/p03 and p16): the element variable of an imported package
   array copy ends at the first unpacked dimension in golden, ours at the name; the module and interface import copies
   are ModuleEmit (§ importNetTsDimEnd275's neighbourhood).
2. **The module net typed by a package typedef** (r10earl53repro/v2_v53, `wire pv2_v53::sa_t sn;` stretching
   `sa_t` to the end of the type, 32:21) and the module struct typedef with an initialized variable (r11u32repro/k9b,
   `var t_t b_init = '0;`, the typedef and the struct_net to 54:22): the same writeNets stretch in a MODULE, ModuleEmit;
   r10uvm149repro/g149/homes (an anonymous struct variable in a module, 33:3-34:24) likewise.
3. **The definition-view generate block's select operands** (r10earl120repro/a1_axis120, r10earl56repro/a5_earl56 and
   v2_nestedsel56, grid LB/b07): a reference inside an operation in an indexed part select of a for-generate body is
   named through the select (golden `work@top.g.sig.R4`, ours `work@top.g.R4`); the backtrace places the writer at
   TypeEmit emitSyntaxExpr (called from ModuleEmit's definition generate emission).
4. **Tagged-pattern package enum constants** (r10earl115repro/p1_pos115, r10earl121repro/a1_axis121): `p::OpA` in a
   definition-view generate assignment pattern ends after `p::` (ours) where golden spans the whole name; the same
   TypeEmit syntax emission. The elaborated twins of p1_pos115 keep the genvar `i` in the element select names where
   golden substitutes its value (`two_i[0]`).
5. **The interface-array port range fold** (r10rgg4repro a1_noovr, b1_int_noovr, c1_p_noovr, r10vrgg4repro
   v5k_noovr_int_signed): the folded `R-1` operand's ref_typespec is unnamed and its int_typespec unlocated in golden;
   ours names it `work@top.u` and binds R's declared typespec; ModuleEmit `fillSizeDimRange`.
6. **The continuous assignment child order** (r10v111repro/v111_b6, r10v92repro/v4_arm, r11u114repro a25 / a28,
   v11u114repro g25: golden walks the Lhs ref_obj where ours walks the folded Rhs), the comma-list cont_assign spans
   (r10vearl106repro va3_span106 / va7_mix106, r11u22repro d21_comma_list, r11u23repro d10_comma_list,
   r10vearl113repro v1_decl113): ModuleEmit's continuous assignments.
7. Standing as passes 276 and 278 reported them: the elaborated cont_assign call fold (6 cases), the doubled
   for-generate part-select base (4 cases, TypeEmit), the received localparam typespec (3 cases, ModuleEmit
   pvFold115), a program instantiated twice (7 cases), the elaborated chained type parameter's and the interface type
   parameter's variables, the struct-member full names (TypeEmit), the type-parameter array faces (UhdmExporter).

## Residues, ranked (this ground)

1. **The generate-scope fold reference names** (unchanged in number; LB's law took v7_repl105): v08_comb (an
   always_comb indexed-part-select WIDTH under a var_select, the gen-process branch § genProcFoldTsKeepsScope154,
   golden the owning instance), g5_hop95 / x09 / v11_concat (an if-generate plain-operand fold c7 branch,
   § unaryOperandParamOwnerName145's neighbour: golden the owner for a concatenation member under a ternary; the
   operand grid could not be measured here, every fresh shape read stage 1 on an unrelated port listing), v7_inst64
   (golden an EMPTY name: an unparented clone), a3_earl47 (a left-side base, golden the chain), vo, v07_genfor_comb_ctl
   (golden the chain: a freshly folded operation), g99_a7_shapes / pu20 / b07 (function and call contexts, golden the
   owner).
2. **The variable road of the package stretch** (vh_arrelem `si_t`, `en_t`): golden stretches one of the two package
   listings only; ours lists one object in both, so the stretch needs a per-view object first.
3. The member-path laws' leftovers: v92's nested path inside the inner var_select's index (`bb.two_d[1][bb.q]`,
   golden `...::bin::two_d::q`), b1_sites' bit_select element `t.arr[{1'b0, k[0]}].fld[0]` (the inner `k[0]` spans
   only `0` and is named by the scope; a different site), interface and `this.` paths (VR r09, r10, r14 stage 1).
4. The macro dimension of the package stretch (PS/p10, golden stretching to the macro use) and the foreign typedef
   (PS/p11).
5. The brief's items (2) to (7) beyond the above were not attempted.

## Process

Fence: every corpus path list was filtered by `$FENCED` (word boundary) before any file was opened (controls.sh,
bvmirror.sh, the binary audit); the census ran with the harness filter built from `$FENCED`; the probe and
downstream byte comparisons walked trees that hold no fenced name (checked by a name count of each tree's listing,
0); no fenced source, database or cmds.txt was read or dispatched outside the gate sweeps. gdb ran on probe cases and
fresh cases only. Every tool variable was checked with `[ -x ]` (the env file refuses to load without them). No
process was listed or signalled. Superseded binaries law1-law6 (the span law alone; the index law before the
design-final drain; the package law with a variable road, measured moving vh_arrelem's other listing away and dropped;
before the foreign-typedef guard); the census, grid, controls and the law sweep ran on the final one (law7 = law.bin).
The main tree was not written.

Files: drivers/case.sh, grid.sh, gridsum.py, controls.sh, ctlsum.py, awaygrid.sh, tracecensus.sh, classify.py and
chains.py (from r11u278repro), det.sh and dscases.py (from r11u272repro), attrib.py (new); the away census
(awaychain.py with strictcmp_x) and bvmirror.sh are used in place from tools/probe/r11u272repro/drivers.
