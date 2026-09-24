# r11u132map — the strict ground map, third edition (measurement only)

Base `4f73d52f` (branch matrix-1.87). No edit to `src/`, `scripts/`, `results/`, `tests/` or `third_party/`;
this directory is the whole patch. Worktree `/tmp/wt_r11u132`, system-deps config, `-j 2`. Frozen binaries
(`chmod 555`, before any measurement):

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `9767e18b4753a0562f90d27f919b01d8` | byte-identical to the main tree's `build/slang-uhdm` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | byte-identical to the main tree's (mode 4, r11u129) |
| `strictcmp_x` | `dccc8967e61b55e88ae0af2760848526` | drivers/strictcmp_x.cpp: the committed tool with a dump that also carries what the mode-4 rule reads (raw full name, refRoot/root/inCopy); stdout identical to the committed tool (evidence/verify.txt) |
| `strictcmp_x2` | `db96066ac072748e8d5b05cf675242f8` | the same source; `--dump-ids` adds the UhdmId (exact site pinning) |
| `slang-uhdm.g1` | `fcd25edb22be2891c367de59d4bb8093` | the same source with `-g1` line tables, for gdb only; its databases are byte-identical to the release binary's (5 of 5 sampled cases) |

Law names are written `law <name>` (no section sign), so scripts/law_index.py does not read this directory as a
pass of laws. Adding this README still adds one row (`| r11u132map |  |  | 0 | 0 |`) to the passes table of
tests/LAWS.md, as r11u128map did: the landing must run `python3 scripts/law_index.py` and commit tests/LAWS.md
with it (this pass may not edit tests/).

One of the four slang-fenced tests is a judge-equal, strict-NE surelog row (both modes). It is measured like every
other row but written `FENCED_1` everywhere in this directory (file names included), so no artifact spells a
fenced name.

## 0. Where we stand (4f73d52f, the committed mode-4 comparator)

| corpus | mode | judge-equal | strict-equal | strict NOT equal | tests NE in some mode |
|---|---|---|---|---|---|
| surelog | default | 480 | 327 | 153 | 177 |
| surelog | testflags | 474 | 305 | 169 | |
| uhdm2rtlil | default | 803 | 626 | 177 | 177 (the same names in both modes) |
| uhdm2rtlil | testflags | 803 | 626 | 177 | |
| probe cases | — | 4087 | 2069 | 2018 | — |

First fields over the 676 corpus row-modes: fullname 276, file 87, endcol 79, line 57, depth 55, endline 39,
col 36, type 22, name 10, count 9, value 4, decompile 2. Probe: fullname 768, endcol 365, depth 234, line 208,
file 147, type 101, endline 78, col 75, name 31, value 5, count 3, decompile 3. Every u2r row the flip would fail
(354 of 354) is downstream IDENTICAL; the 2 EQUIVALENT rows (func_upto, matching_end_labels) are strict-equal.

## 1. Method

1. A fresh pristine sweep with the frozen binaries (`tests/sweep.sh --jobs 3 --workdir /tmp/r11u132_sweep`, rc 0;
   evidence/sweep_gates.txt) is the input. Its strict column equals `results/golden_*.csv` column 6 on 1596 + 1742
   rows and /tmp/canon_mode4.csv on every judge-equal row; its databases equal the 4f73d52f reference sweep
   /tmp/intr11u124 except the UVM order coin (7 databases, attributed in evidence/dbcmp_attr.txt).
2. `drivers/run1.sh`: `strictcmp_x --max 50 --dump-a --dump-b golden ours` on all 676 strict-NE corpus row-modes
   (both modes) and all 4087 probe cases (2069 rc 0, 2018 rc 2).
3. `drivers/analyze.py` aligns the two record lists (r11u128map's aligner, unchanged) and records EVERY differing
   object with the **committed mode-4 rule** reimplemented (`fd`/`pairctx`: a copy's full name compared by its
   tail and excused only when USE-SITE; a ref-reached named root's span excused only when USE-SITE). The
   reimplementation is checked per row against the tool's own stdout (field tally, objects differing, first
   field): **2694 of 2694 rows agree**. 1,036,727 corpus facets, 23,151 probe facets.
4. Clusters use r11u128map's key (`facet|type|shape|under:<walk parent type>` + its two splits), so every cluster
   carries its r11u128map id (`cluster_index.csv` column `r11u128_id`). New ids are `N####`, ranked by corpus
   row-modes, then probe cases. 2378 clusters (1896 with corpus rows, 482 probe-only), 299 families (`H##`).
5. Coverage (`drivers/final.py`): **COVERED r11u131** (pair A) / **COVERED r11u130** (pair B) = the brief's
   r11u128map ids, mapped by key. A cluster r11u128map gave to r11u124 or r11u125 that is still present is
   **OPEN (residue of landed r11u124/125)**. Everything else is OPEN. K0062 and K0064 (pair A's parameter values on
   the import-Lhs clone) no longer occur: law paramValueIsDefRhs124 already cleared them.
6. Sites (`drivers/pinprep2.py` + `pinall.py` + `sites.py`): the example object's UhdmId, read from a
   `--dump-ids` re-dump of the same pair, gives its creation rank among its type's objects; gdb stops the `-g1`
   exporter at that call of `Serializer::Make<type>` and the backtrace's first three frames are the site, each
   with the nearest law above it. This is exact for unlocated objects (ref_typespec, range), which
   r11u128map's type/name/span match could not tell apart. 364 clusters pinned (every first cluster of a
   failing row, every cluster with at least 8 row-modes, the covered ones, those with at least 40 probe
   cases); 9 of them are minted inside UHDM's own elaborator under testflags `--elabuhdm` (decoded below).
   A mint site is where the object is born; for a full-name or span cluster the field may be written (or the
   parent set) elsewhere. PINNED = one example; a cluster can span contexts. DECODED = read from the records and
   uhdm-dump (evidence/decoded_sites.json).
7. Yield: a row-mode clears when EVERY cluster in it is fixed; a test when every NE mode clears. The pair yields
   are OPTIMISTIC (a covered cluster counts as fixed whole).

## 2. Positive controls (evidence/controls/)

| control | result |
|---|---|
| surelog/default/1364_2005 | `STRICT_EQUAL 159 objects`, record dumps byte-identical (159) |
| surelog/default/HierPathInterfBlock | `STRICT_EQUAL 226 objects`, dumps identical (226) |
| uhdm2rtlil/default/1DUnpackedArray | `STRICT_EQUAL 194 objects`, dumps identical (194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, `lhsPath: design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant` |
| analyzer rule vs tool | 2694 / 2694 rows |
| variant vs committed tool stdout | 38 / 38 sampled rows byte-identical |
| probe gate | EQUAL=4087 of 4087; strict histogram of the per-case runs = check_probe's |

Gates of the pristine sweep: probe EQUAL=4087; surelog 480/3 + 474/3, uhdm2rtlil 803/1/67 both modes,
`regressions=0 conversions=0 changes=0`; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, 0 not
excused; canaries ok=52 / ok=16 changed=0, ctcan2 PASS ok=58 (EXPECT_UNKNOWN=1) and PASS ok=2 (EXPECT_UNKNOWN=6)
on LF-normalised copies (the committed csvs are CRLF); cmds.txt audit 3273 / 3273 name the frozen binary.

## 3. The live pairs and the flip

| | clusters | row-modes touched | rows cleared alone | tests cleared |
|---|---|---|---|---|
| r11u131 (pair A) | 20 | 197 | 71 | 39 |
| r11u130 (pair B) | 13 | 179 | 26 | 11 |
| **both** | 33 | 316 | **102** | **54** |
| family-extended upper bound (every cluster of a family either pair touches) | 741 | — | 147 | — |

| corpus | mode | the flip fails today | cleared by A | by B | by A+B | **fails after both pairs** |
|---|---|---|---|---|---|---|
| surelog | default | 153 | 9 | 3 | 17 | **136** |
| surelog | testflags | 169 | 12 | 7 | 19 | **150** |
| uhdm2rtlil | default | 177 | 25 | 8 | 33 | **144** |
| uhdm2rtlil | testflags | 177 | 25 | 8 | 33 | **144** |
| corpus total | | **676 row-modes / 354 tests** | 71 | 26 | 102 | **574 row-modes / 300 tests** |
| probe cases | | **2018** | 87 | 66 | 161 | **1857** |

The fail list with the first cluster, its coverage and site per row-mode is `fail_list.csv` (676 rows);
`probe_fail_list.csv` for the probe (2018). The rows the pairs clear (102 row-modes in 56 tests; 54 tests clear in every NE mode, FuncIoTypespec and SequenceInst in one mode only): surelog
BlackParrotSkipParam CarryAdd CheckerInst ClogParam Disable DollarBits EvalFunc ForeachArray ForeachSquare
FuncIoTypespec LoopVar Moves NoParamSubs OneDivider PackageParamConst PortByName SequenceInst SignedWire
SynthForeach TypespecExpr WildConn YosysOldSimpleSpi YosysOldSpi; uhdm2rtlil AnonymousEnum
Clog2OfSumWithParameterIn2InstancesOfSubmodule Disable EnumArray EnumArrayListedElements ParameterColonReference
StructLocalParam StructParameter array_assign cdc_static_basic const_func_block_var dff_different_styles ibex_csr
ibex_fetch_fifo mem_packed_2d_byte_write param_type_logic_width partsel_simple port_chained_type_param simple_enum
static_cast_simple struct_dynamic_range struct_param_func_arg sva_basic02 sva_counter sva_range sva_throughout
sva_value_change_changed sva_value_change_changed_wide sva_value_change_rose unbased_unsized_param
unpacked_elem_partsel_comb vector_index wandwor (the NE modes of each).

Surelog tests NE in default only: DecValue Moves PackageParamConst ParamNoSubst PortInitVal. NE in testflags only:
AllPackageSignal ArrayExprFuncArg ArrayVarName CarryAdd ClogParam DollarBits EmptyAssign EvalFuncNamed FileList
ForeachFunction FuncParam FuncRetArray FuncStruct GenScopeHierPath3 HierPathTypespec ImplicitPackedStructNet
InterfInst InterfaceUnpackedStructArrayDim JKFlipflop NoParamSubs OneNetInterf PortByName TypespecExpr UnsizedFunc.
Judged in one mode only: Rggen Scoreboard YosysBigSimEllip. The u2r modes agree name for name.

After both pairs, rows by open clusters left: 1 open cluster 202 row-modes, 2: 109, 3: 67, 4: 38, 5+: 158
(evidence/extra.txt, which also lists the clusters that are the ONLY open cluster of a row).

## 4. Ranked OPEN clusters with sites

Rows = corpus row-modes (surelog/u2r); first in = row-modes whose FIRST differing object is in the cluster;
+pairs = row-modes it clears alone on top of both pairs. Site = the PINNED mint (function, file, nearest law)
unless marked DECODED. Full list: `cluster_index.csv` (every cluster, its site when pinned, example, probe laws);
one record-window file per pinned cluster in evidence/clusters/ (367) and one example object per cluster in
evidence/objects.csv (2378).

| # | cluster (r11u128) | rows sl/u2r | tests | first in | probe | +pairs | key | example (golden / ours) | site (mint; function, file, law) |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0001 (K0003) | 82 36/46 | 42 | 22 | 78 | 6 | `span\|ref_obj\|col+endcol\|under:hier_path` | surelog/testflags/ComplexHierPath #30/30 ref_obj 'B' golden=11:58:11:59 ours=11:56:11:57 | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) |
| 2 | N0002 (K0005) | 58 18/40 | 29 | 20 | 206 | 3 | `struct\|golden-only:fewer-copies\|parameter\|under:param_assign` | surelog/testflags/ParamFromPackage #73/-1 parameter 'X' golden=9 objs ours= | emitParameters (ParamEmit.cpp, law replFoldTs) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) — DECODED: golden's elaborated param_assign Lhs for an imported package parameter is a module-scoped CLONE (the r11u122 C0012 shape); ours points at the |
| 3 | N0003 (K0006) | 57 23/34 | 29 | 27 | 66 | 21 | `fullname\|ref_typespec\|golden-empty\|under:operation` | surelog/testflags/ParamNoImport #36/36 ref_typespec '' golden= ours=pkg | emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFallback215v) — DECODED: golden's ref_typespec of an assignment-pattern/cast operation carries NO VpiParent (uhdm-dump: no vpiParent  |
| 4 | N0004 (K0011) | 48 22/26 | 24 | 22 | 33 | 12 | `fullname\|ref_typespec\|tok:id@id.->\|under:typespec_member` | surelog/testflags/RangeSelect #13/13 ref_typespec '' golden=work@top.tl_h2d_t.source ours=tl_h2d_t.source | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < emitTopPorts (ModuleEmit.cpp, law tpDimVecPortTsIsDefault120) |
| 5 | N0005 (K0010) | 44 18/26 | 22 | 2 | 163 | 0 | `span\|constant\|endcol\|under:param_assign` | surelog/testflags/GenForIfaceLocalparamBound #165/165 constant '' golden=10:33:10:36 ours=10:33:10:38 | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) |
| 6 | N0007 (K0016) | 38 26/12 | 20 | 2 | 33 | 2 | `fullname\|ref_obj\|golden-empty\|under:hier_path` | surelog/testflags/SelectHierPath #8/8 ref_obj 'brResult' golden= ours=pipeReg[1].brResult | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) |
| 7 | N0008 (K0022) | 34 8/26 | 18 | 8 | 25 | 6 | `fullname\|ref_typespec\|golden-empty\|under:constant` | uhdm2rtlil/testflags/LocalParamInNestedForLoops #70/70 ref_typespec '' golden= ours=work@top | emitParameters (ParamEmit.cpp, law timeLitParamIntTs) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) — DECODED: the same as N0003 on a constant's typespec ref: golden unparented |
| 8 | N0013 (K0030) | 28 8/20 | 14 | 6 | 1 | 6 | `fullname\|ref_obj\|tok:::->.@in-typespec\|under:operation` | surelog/testflags/EarlgreyPackParam #10/10 ref_obj 'NAlerts' golden=alert_handler_reg_pkg::AsyncOn::NAlerts ours=alert_handler_reg_pkg::AsyncOn.NAlert | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) |
| 9 | N0014 (K0004) | 27 11/16 | 14 | 6 | 22 | 2 | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | surelog/testflags/PatternOrder #12/12 ref_typespec '' golden=BC1.B ours=B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypespec (TypeEmit.cpp, law anonPackedAggDimTs107) |
| 10 | N0019 (K0040) | 22 8/14 | 11 | 0 | 38 | 0 | `fullname\|ref_obj\|golden-empty@in-typespec\|under:hier_path` | uhdm2rtlil/testflags/OutputSizeWithParameterOfInstanceInitializedByStructMember #83/83 ref_obj 'x' golden= ours=work@top.data.x | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) |
| 11 | N0020 (K0042) | 22 2/20 | 11 | 22 | 1 | 0 | `fullname\|ref_obj\|tok:::id::->.@in-typespec\|under:operation` | uhdm2rtlil/testflags/ibex_branch_predict #357/357 ref_obj 'LfsrWidth' golden=ibex_pkg::RndCnstLfsrSeedDefault::lfsr_seed_t::LfsrWidth ours=ibex_pkg::R | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) |
| 12 | N0028 (K0007) | 20 6/14 | 10 | 2 | 3 | 0 | `fullname\|ref_typespec\|tok:->id.\|under:typespec_member` | surelog/testflags/FENCED_1 #102/100 ref_typespec '' golden=work@top.pinmux_pkg::target_cfg_t.a ours=work@top.TargetCfg.pinmux_pkg::target_cfg_t.a | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < patchParamTypespecs (ParamEmit.cpp, law paramCloneImportedCopy) |
| 13 | N0031 (K0014) | 19 11/8 | 10 | 0 | 19 | 0 | `file\|constant\|ours-empty\|under:range` | uhdm2rtlil/testflags/TypedefWithParameter #50/57 constant '' golden=dut.sv 3:19:3:20 ours= 0:0:0:0 | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassDefn (UhdmExporter.cpp, law classDefnVirtualFromVirtualIfaceDecl6) |
| 14 | N0032 (K0033) | 19 11/8 | 10 | 10 | 16 | 1 | `fullname\|ref_typespec\|tok:->id@id.\|under:typespec_member` | surelog/testflags/AssignRhsFlat #4/4 ref_typespec '' golden=ABC.A ours=work@dut.ABC.A | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 15 | N0036 (K0079) | 18 14/4 | 10 | 0 | 7 | 0 | `span\|bit_select\|col+endcol\|under:operation` | uhdm2rtlil/testflags/latch_packed_dyn_write #194/194 bit_select 'bit_i' golden=47:32:47:33 ours=47:26:47:34 | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxAtPath79) |
| 16 | N0041 (K0071) | 17 17/0 | 9 | 2 | 34 | 1 | `file\|unsupported_typespec\|ours-empty\|under:ref_typespec` | surelog/testflags/ClassVar #52/52 unsupported_typespec 'paths' golden=dut.sv 16:11:16:16 ours= 16:11:16:16 | emitStmt (StmtEmit.cpp, law foreachArraySelfSelectAssignDropsTs19) < emitStmt (StmtEmit.cpp, law invalidChild14) < emitStmt (StmtEmit.cpp, law invalidChild14) |
| 17 | N0042 (K0037) | 17 11/6 | 9 | 0 | 16 | 0 | `span\|constant\|ours-zero\|under:range` | uhdm2rtlil/testflags/TypedefWithParameter #50/57 constant '' golden=3:19:3:20 ours=0:0:0:0 | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassDefn (UhdmExporter.cpp, law classDefnVirtualFromVirtualIfaceDecl6) |
| 18 | N0045 (K0075) | 16 8/8 | 8 | 2 | 12 | 6 | `struct\|golden-only:fewer-copies\|constant\|under:typespec_member` | surelog/default/StructParamPatternInitCast #77/-1 constant '' golden=1 objs ours= | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) — DECODED: golden lists the member default constant twice (a copy under typespec_member); ours shares one object. HOLDER pinned |
| 19 | N0048 (K0086) | 15 7/8 | 8 | 0 | 55 | 6 | `fullname\|ref_typespec\|tok:id->id.id.id\|under:parameter` | surelog/testflags/InterfType #47/47 ref_typespec '' golden=work@tnoc_types.PACKET_CONFIG ours=work@dut.tnoc.types.PACKET_CONFIG | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFallback215v) |
| 20 | N0049 (K0089) | 15 11/4 | 8 | 0 | 15 | 0 | `span\|sys_func_call\|endcol\|under:operation` | uhdm2rtlil/testflags/ibex_multdiv_fast #7435/6955 sys_func_call '$signed' golden=158:24:158:31 ours=158:24:158:59 | emitSyntaxExpr (TypeEmit.cpp, law syntaxMultiConcat) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (ModuleEmit.cpp, law defGenElemIpsVarSel112) |
| 21 | N0050 (K0077) | 15 15/0 | 8 | 0 | 10 | 0 | `span\|operation\|col+endcol\|under:assignment` | surelog/testflags/MacroArgMismatch #15/15 operation '' golden=5:13:5:15 ours=5:14:5:16 | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) |
| 22 | N0051 (K0087) | 15 15/0 | 8 | 2 | 9 | 0 | `span\|class_typespec\|endcol\|under:ref_typespec` | surelog/testflags/ClassParamAsParam #8/8 class_typespec 'object' golden=18:14:18:20 ours=18:14:18:30 | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter.cpp, law typedefAliasSharesTypespec25) < emitClassDefn (UhdmExporter.cpp, law classDefnVirtualFromVirtualIfaceDecl6) |
| 23 | N0052 (K0091) | 15 13/2 | 8 | 2 | 8 | 2 | `fullname\|ref_obj\|tok:id.id[id]::->\|under:bit_select` | uhdm2rtlil/testflags/struct_param_func_loop #162/162 ref_obj 'k' golden=p::inside_regions::C.base[k]::k ours=p::inside_regions::k | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) |
| 24 | N0053 (K0092) | 15 11/4 | 8 | 2 | 7 | 2 | `span\|begin\|line+endline+endcol\|under:function` | uhdm2rtlil/testflags/func_local_compound_xor #33/33 begin '' golden=19:5:19:20 ours=18:5:18:30 | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitPackageClassMethodClones (ParamEmit.cpp, law pkgFreeSubRefVarHoistNet117) |
| 25 | N0054 (K0065) | 15 15/0 | 8 | 4 | 3 | 0 | `span\|assignment\|endcol\|under:begin` | surelog/testflags/CovMacro #101/101 assignment '' golden=12:9:12:52 ours=12:9:12:86 | emitStmt (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) |
| 26 | N0055 (K0178) | 15 13/2 | 8 | 0 | 1 | 0 | `span\|ref_obj\|line+endline\|under:operation` | surelog/testflags/ExplictiPorts #43/43 ref_obj 'b' golden=38:14:38:15 ours=39:14:39:15 | emitBadConcatOperand160 (ExprEmit.cpp, law badConcatCompoundOperands162) < emitBadConcatFromSyntax160 (ExprEmit.cpp, law classArgBind12) < emitExpr (ExprEmit.cpp, law droppedIdxRecvCall26) |
| 27 | N0056 (K0093) | 15 13/2 | 8 | 6 | 1 | 2 | `span\|bit_typespec\|endcol\|under:ref_typespec` | surelog/testflags/GenCase #5/5 bit_typespec '' golden=6:13:6:16 ours=6:13:6:25 | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law pkgTdCloneRefNoBind18) < emitModuleDef (ModuleEmit.cpp, law thisImplicitNetBoth38) |
| 28 | N0057 (K0096) | 15 5/10 | 8 | 0 | 0 | 0 | `struct\|golden-only:fewer-copies\|ref_typespec\|under:enum_typespec` | surelog/testflags/PackedEnumPort #49/-1 ref_typespec '' golden=8 objs ours= | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp, law importCopyAggFormalOwnCopy32) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 29 | N0058 (K0098) | 14 2/12 | 7 | 4 | 55 | 4 | `span\|operation\|endcol\|under:param_assign` | uhdm2rtlil/testflags/assert_wide_const_cond #82/82 operation '' golden=11:36:11:45 ours=11:36:11:55 | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) |
| 30 | N0060 (K0137) | 14 10/4 | 8 | 0 | 15 | 0 | `span\|operation\|col+endcol\|under:operation` | surelog/default/BlackConst #761/761 operation '' golden=10:103:10:131 ours=10:65:10:93 | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < operator() (ExprEmit.cpp, law pkgTdCloneRefNoBind18) < emitExpr (ExprEmit.cpp, law pkgTdCloneRefNoBind18) |
| 31 | N0061 (K0101) | 14 12/2 | 8 | 0 | 8 | 0 | `span\|bit_select\|col+endcol\|under:hier_path` | uhdm2rtlil/testflags/struct_member_trailing_index #172/172 bit_select 'sat' golden=36:20:36:24 ours=36:16:36:25 | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectErased4) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) |
| 32 | N0062 (K0103) | 14 8/6 | 7 | 0 | 3 | 2 | `span\|packed_array_typespec\|ours-zero\|under:ref_typespec` | surelog/testflags/StructArrayNet #29/29 packed_array_typespec '' golden=0:0:10:28 ours=0:0:0:0 | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) |
| 33 | N0063 (K0104) | 14 2/12 | 7 | 0 | 2 | 0 | `fullname\|ref_typespec\|ours-empty\|under:operation` | uhdm2rtlil/testflags/iface_nested_param_field #326/326 ref_typespec '' golden=work@iface_nested_param_field.u.sub ours= | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender112) < emitExpr (ExprEmit.cpp, law concatRefNoSubst) |
| 34 | N0064 (K0095) | 14 14/0 | 8 | 14 | 0 | 0 | `span\|include_file_info\|line+endline\|under:design` | surelog/default/ApbSlave #4/4 include_file_info '' golden=375:12:375:32 ours=373:12:373:32 | emitIncludeFileInfos (UhdmExporter.cpp, law emptyRedefineBareLine125v) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| 35 | N0065 (K0108) | 14 10/4 | 7 | 0 | 0 | 0 | `depth\|typespec_member\|struct_typespec->struct_typespec` | surelog/testflags/TypedefUnpacked #37/30 typespec_member 'x' golden=9 struct_typespec(pkg::a) < ref_typespec ours=5 struct_typespec(pkg::a) < ref_type | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 36 | N0066 (K0109) | 14 10/4 | 7 | 0 | 0 | 0 | `depth\|ref_typespec\|typespec_member->typespec_member` | surelog/testflags/TypedefUnpacked #38/31 ref_typespec '' golden=10 typespec_member(x) < struct_typespec(pkg::a) ours=6 typespec_member(x) < struct_typ | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 37 | N0067 (K0110) | 13 13/0 | 7 | 0 | 47 | 0 | `file\|class_typespec\|ours-empty\|under:ref_typespec` | surelog/default/ApbSlave #713/717 class_typespec 'svunit_testsuite' golden=svunit_testrunner.sv 32:9:32:25 ours= 0:0:0:0 | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPropIsArrayVar6) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) |
| 38 | N0068 (K0111) | 13 13/0 | 7 | 0 | 47 | 0 | `span\|class_typespec\|ours-zero\|under:ref_typespec` | surelog/default/ApbSlave #713/717 class_typespec 'svunit_testsuite' golden=32:9:32:25 ours=0:0:0:0 | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPropIsArrayVar6) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) |
| 39 | N0069 (K0112) | 13 13/0 | 7 | 0 | 25 | 0 | `span\|string_typespec\|line+col+endline+endcol\|under:ref_typespec` | surelog/testflags/ClassTypeParam #32/32 string_typespec '' golden=26:30:26:36 ours=20:36:20:42 | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < sharedTypespec (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) |
| 40 | N0070 (K0113) | 13 13/0 | 7 | 1 | 17 | 0 | `span\|function\|endline+endcol\|under:class_defn` | surelog/testflags/ClassTypeParam #80/80 function 'check_all_sva_passed' golden=11:2:11:9 ours=11:2:12:13 | emitTaskFuncs (TaskFuncEmit.cpp, law dpiExportListedAtExportItem216) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) |

Owner file of the pinned OPEN clusters (clusters / corpus row-modes touched): TypeEmit.cpp 107/334, ExprEmit.cpp 101/244, TaskFuncEmit.cpp 29/21, ModuleEmit.cpp 25/99, ParamEmit.cpp 21/142, StmtEmit.cpp 21/45, UhdmExporter.cpp 13/36, ? 9/25. The live pairs' grounds
split the same way: pair A (ExprEmit/EmitHelpers/StmtEmit/ParamEmit), pair B (TypeEmit/ModuleEmit/UhdmExporter/
TaskFuncEmit/uhdm_main).

**Greedy OPEN clusters on top of both pairs** (base 102 row-modes / 54 tests; cumulative): N0003 123/65,
N0004 135/71, N0001 141/74, N0048 149/78, N0007 155/81, N0008 161/84, N0013 167/87, N0045 173/90, N0085 179/93,
N0138 185/96, N0270 191/99, N0271 197/102, N0440 203/105, N0281 208/107, N0005 212/109, N0019 216/111,
N0058 220/113, N0084 226/116, N0014 230/118, N0108 238/122 (evidence/final.txt has 30 steps).

**OPEN families (brief-sized), greedy on top of both pairs** (family, its rows, cumulative rows / tests):
1 FULLNAME-IN-TYPESPEC-SUBTREE (H01, 334 rows, 309 open clusters) 232 / 120 · 2 SPAN\|ref_obj (H03, 121) 260 / 134 ·
3 FULLNAME\|ref_obj\|tok (H02, 97) 276 / 146 · 4 FULLNAME\|ref_obj\|golden-empty (H11, 44) 290 / 153 ·
5 SPAN\|struct_typespec (H06) 302 / 159 · 6 SPAN\|operation (H08) 314 / 165 · 7 STRUCT-IMPPARAM-CLONE\|golden (H07,
59 rows: class C below) 331 / 173 · 8 SPAN\|constant (H04) 347 / 181 · 9 STRUCT-TSCOPY\|golden (H05) 363 / 189 ·
10 STRUCT-SHARE\|golden\|constant (H22) 375 / 195 · … 25 steps 461 / 239; every cluster 676 / 354.

**The full-name ground under mode 4.** 584,630 full-name facets: OUT (outside any copy) 151,700 in 294
row-modes; inside a copy with DIFFERENT tails (TAIL: truncated, missing or mis-parented names) 99,237 in 128;
inside a copy with EQUAL tails that mode 4 still reads as content (STABLE: golden gives ours's object one name,
or several not including ours's) 333,693 in 170. None of them is identity by the comparator's definition: a
naming or parenting law can reach every one without a copy per use. H01 (r11u124's F02 parent policy, only
partly landed) is the largest open family; its biggest first-field clusters are N0004 (`work@top.tl_h2d_t.source`
vs `tl_h2d_t.source`: golden prefixes the use scope on a member ref inside a net's typedef copy), N0020 / N0013
(golden `pkg::Param::lfsr_seed_t::LfsrWidth` / `pkg::AsyncOn::NAlerts`, ours `pkg::Param.LfsrWidth`), N0032,
N0028, N0014. Of the top OPEN clusters, N0003 and N0008 are DECODED: golden's ref_typespec of an
assignment-pattern/cast operation (N0003) or of a constant (N0008) has NO VpiParent (uhdm-dump prints no
vpiParent line), so its full name is empty; ours is parented. N0007 / N0019 are the hier_path path element
ref_obj with golden's full name empty.

**The first clusters** (what the gate would name first on each failing row; 151 distinct):

| first cluster | row-modes it heads | coverage | key | site |
|---|---|---|---|---|
| N0003 (K0006) | 27 | OPEN, residue of r11u124 | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFal |
| N0004 (K0011) | 22 | OPEN, residue of r11u124 | `fullname\|ref_typespec\|tok:id@id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < emitTopPorts (ModuleEmit.cpp, law tpDimVecPortTsIsDefault1 |
| N0020 (K0042) | 22 | OPEN, residue of r11u124 | `fullname\|ref_obj\|tok:::id::->.@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) |
| N0001 (K0003) | 22 | OPEN, residue of r11u124 | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) |
| N0012 (K0028) | 20 | COVERED r11u130 (K0028) | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) |
| N0002 (K0005) | 20 | OPEN, residue of r11u124 | `struct\|golden-only:fewer-copies\|parameter\|under:param_assign` | emitParameters (ParamEmit.cpp, law replFoldTs) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) — DECODED: golden's el |
| N0006 (K0017) | 19 | COVERED r11u131 (K0017) | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law caUnbasedFillPackedAggregateKeepsRaw43) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) — DE |
| N0064 (K0095) | 14 | OPEN, residue of r11u125 | `span\|include_file_info\|line+endline\|under:design` | emitIncludeFileInfos (UhdmExporter.cpp, law emptyRedefineBareLine125v) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| N0011 (K0027) | 12 | COVERED r11u131 (K0027) | `file\|logic_net\|golden-empty\|under:ref_obj` | emitExpr (ExprEmit.cpp, law oobCtorLocalsRideTheImport203) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) |
| N0016 (K0034) | 12 | COVERED r11u130 (K0034) | `file\|logic_net\|golden-empty\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law implicitNetNoFile119) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| N0037 (K0053) | 12 | COVERED r11u130 (K0053) | `file\|packed_array_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) |
| N0044 (K0074) | 12 | COVERED r11u130 (K0074) | `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTopPorts (ModuleEmit.cpp, law defNetTsScope) |
| N0009 (K0024) | 12 | COVERED r11u130 (K0024) | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) |
| N0032 (K0033) | 10 | OPEN, residue of r11u124 | `fullname\|ref_typespec\|tok:->id@id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| N0047 (K0085) | 10 | COVERED r11u130 (K0085) | `fullname\|parameter\|tok:id->id.id.id\|under:param_assign` | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFal |
| N0139 (K0204) | 10 | OPEN, residue of r11u124 | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < emitParameters (ParamEmit.cpp, law modDefImportShape) |
| N0046 (K0080) | 9 | COVERED r11u131 (K0080) | `struct\|ours-only:fewer-copies\|logic_net\|under:ref_obj` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| N0035 (K0060) | 8 | COVERED r11u131 (K0060) | `span\|func_call\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law defGenQualPkgCallBinds18) < emitParameters (ParamEmit.cpp, law foldSigned9) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) |
| N0283 (K0023) | 8 | OPEN, residue of r11u125 | `file\|struct_typespec\|ours-empty\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| N0008 (K0022) | 8 | OPEN, residue of r11u124 | `fullname\|ref_typespec\|golden-empty\|under:constant` | emitParameters (ParamEmit.cpp, law timeLitParamIntTs) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) — DECODED: the  |
| N0090 (K0100) | 8 | OPEN | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFile |
| N0021 (K0043) | 8 | COVERED r11u131 (K0043) | `fullname\|ref_obj\|tok:id.id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitInstance (ModuleEmit.cpp, law elabPortConnUnitEnumNet) |
| N0279 (K0367) | 8 | OPEN, residue of r11u124 | `fullname\|ref_typespec\|tok:id@id.id::id.->id::id::\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law a7) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| N0076 (K0118) | 7 | OPEN | `fullname\|ref_obj\|tok:id.->\|under:part_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < operator() (ModuleEmit.cpp, law genCaTernaryFoldGenScope22) |
| N0040 (K0048) | 7 | COVERED r11u130 (K0048) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef (ModuleEmit.cpp, law interfaceDefViewNeverLateB |

## 5. The structural rows after mode 4 (depth 55 / count 9 / type 22 = 86 row-modes, 44 tests)

Every one decoded (evidence/structural.txt lists them; evidence/clusters/ has the record windows). Update of
r11u128map section 5:

| class | row-modes (tests) | first cluster (r11u128) | what differs | coverage | clears with the pairs |
|---|---|---|---|---|---|
| A. NET-BINDING | 34 (18: surelog Moves/default, PackageParamConst/default; u2r Clog2OfSumWithParameterIn2InstancesOfSubmodule ParameterColonReference StructLocalParam StructParameter array_assign cdc_static_basic param_type_logic_width partsel_simple sva_range sva_throughout sva_value_change_changed sva_value_change_changed_wide sva_value_change_rose unbased_unsized_param vector_index wandwor) | N0006 (K0017), N0046 (K0080), N0022 (K0044) | which net `ref_obj.Actual` names: golden's elaborated cont_assign LHS / port high-conn / clocking event binds the DEFINITION net (re-listed); ours the elaborated net (K0080 the mirror) | **COVERED r11u131** (the live net-binding work) | **all 34** |
| B. TYPEDEF-ALIAS on the net typespec | 6 (LogicTypedef, WireType, net_types) | N0085 (K0133) | ours's net typespec carries `Typedef_alias`; golden's has none (content) | OPEN (r11u125's F04 did not reach it) | 0 |
| C. IMPORTED-PARAMETER CLONE | 20 (10: BitSelectOfParameterPassedToSubmodule HierPathOverride Kmac ParamFromPackage ParameterFromPkgOnParameterPortList StructArrayParameterInitializedByPatternPassedAsPort ff_dead_both_branches ff_dead_guarded_reset param_struct_field_bitsel param_unpacked_struct_array) | N0002 (K0005 = r11u122 C0012) | golden's ELABORATED param_assign Lhs for an imported package parameter is a module-scoped clone (listed again, 9 objects with its typespec); ours points at the package parameter (listed once). The definition-view clone exists since law impLhsCloneFile124 | OPEN (residue of r11u124: it landed the clone's file, not the elaborated clone) | 0 |
| C2. CONSTANT COPIED | 6 (DefaultPatternInt, DefaultPatternModule, ParamArrayUnsizedPattern) | N0441 (K0590) | an array_expr default pattern: ours two constant objects, golden one shared | OPEN; PINNED emitParameters (ParamEmit.cpp, law patOpMemberAsmSplit28) < emitInstance | 0 |
| D. MEMBER-DEFAULT COPY | 2 (StructParamFuncBodyFieldCompare) | N0045 (K0075) | golden lists the member default constant twice (a copy under typespec_member); ours one shared object | OPEN (r11u123 called this walk completeness; mode 4 reads it as a listing difference, and a copy fixes it) | 0 |
| D2. CAST TARGET | 6 (def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot) | N0024 (K0047) | the tagged-pattern key's cast typespec: golden struct, ours integer | COVERED r11u131 | 0 (other open clusters) |
| E. SHARED func_call | 6 (FunctionParam, SelectGivenBySelectOnParameterInFunction, func_local_array) | N0133 (K0197) | ours's ELABORATED cont_assign Rhs is the definition's func_call object (listed once); golden holds a copy. **Correction of r11u128map**: not a fold (stage 1 reads a func_call on both sides) | OPEN; HOLDER emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance | 0 |
| E2. SHARED constant | 2 (SumOfParametersInNestedForLoops) | N0554 (K0718, new in this table) | ours's elaborated gen-scope cont_assign Rhs is the param_assign's constant object; golden a copy | OPEN; HOLDER the gen-scope cont_assign lambda (ModuleEmit.cpp, law genvarWholeCaRhsFold68) | 0 |
| F. TYPE-PARAMETER DEF NET | 2 (TypeParam) | N0770 (K0950) | the definition net typed by a type parameter: golden logic_typespec (the default), ours int_typespec | OPEN | 0 |
| G. EXTRA FOLDED CONSTANT | 2 (BlackParrotComplex) | N0724 (K0904) | ours folds an elaborated param_assign Rhs to a size-50 constant with an unlocated logic typespec; golden keeps the operation | OPEN; PINNED tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < emitParameters (ParamEmit.cpp, law castElabFoldTargetKinds) | 0 |

Classes C, C2, D, E and E2 (36 row-modes) are object SHARING differences outside typespecs: the listener lists a
shared object once, and the canonical walk re-expands only typespecs and enum constants. Golden holds the objects
in every case, so a copy (C, D, E, E2) or a share (C2) matches it without inventing anything. The live
net-binding work (r11u131) clears class A whole: 34 of the 86 structural row-modes.

## 6. The --elabuhdm clusters (testflags only)

Nine pinned clusters (N0124 N0280 N0282 N0652 N0695 N1124 N1286 N1837 N1849) touch 25 corpus row-modes, all surelog/testflags:
ArrayExprFuncArg ArrayVarName AssertDelayError AssertTempError BasicOh DefaultPatternInt DefaultPatternModule
Earlgrey_0_1 EmptyAssign EvalFuncNamed FileList ForeachFunction FuncIoTypespec FuncParam FuncRetArray FuncStruct
FuncStructVal GenScopeHierPath3 InterfaceParamOverrideProp JKFlipflop Kmac OneNetInterf StringRange UnionCast
UnsizedFunc. They are minted by UHDM's own `ElaboratorListener::elabModule_inst` DeepClone of our definition
objects, run from main (uhdm_main.cpp, the `--elabuhdm` block). The library is out of scope; the fix is on the
definition object we hand it or in uhdm_main's post-elaboration pass. 13 of the 24 surelog tests NE in testflags
only (section 3) carry one of them.

## 7. Probe cases by law

2018 NE cases in 996 clusters (probe_clusters.csv: case, law, first field, cluster, objects; laws from
scripts/law_index.py). 161 clear with the pairs. Laws with the most NE cases: loopCaParamReadKeepsLiteral116
84/123, badConcatOperandsFromSyntax160 71/71, genCaOpFoldElabTs115 68/68, tpPackedArrayTsVar108 57/73,
tpElemRebindElabPort110 57/61, pvExprDefaultFold115 48/50, nestedGenProcLhsKeepsRef116 46/74,
portViewRangeRecvParams 45/55, caNestedModPortedDefShell101 36/38, srlgCondOpInstValueTernFold9 32/140.
Probe-heavy clusters: N0039 (K0070, int_typespec decl-vs-use span, 222 cases, COVERED r11u130), N0002 (class C,
206), N0005 (K0010 folded-constant endcol under param_assign, 163), N1897 (K2107 `work@sub.work@sub::innermod.i`
vs `work@sub::innermod.i`, 119 cases, 0 corpus rows), N0261 (K0339 the formal's typespec on a constant
argument, 113), N0469 (K0626, 111), N1898 (K2108, 92), N0151 (K0218 golden ref_typespec under parameter, 85),
N0127/N0128/N0680 (port-view array_typespec / range spans, 69-79), N0152/N0153 (function begin unlocated, 71).

## 8. What changed since r11u128map

- The comparator became mode 4 (r11u129): the identity residue is zero, so every remaining facet is content.
  r11u128map's 271-row-mode "identity residue that needs a copy per use" is gone as a category; its full-name
  objects now read STABLE or TAIL (section 4) and a naming law can match them.
- Passes 124 and 125 landed: 277 of r11u128map's 2617 clusters no longer occur (243 with corpus rows: 60 it gave
  to r11u124, 133 to r11u125, 50 OPEN ones cleared as a side effect). 485 clusters r11u128map gave to them are
  still present (397 r11u124, 88 r11u125): the biggest are N0001 (K0003 hier_path element span), N0002 (C0012
  clone), N0003 (K0006), N0004 (K0011), N0005 (K0010), N0007 (K0016), N0008 (K0022) and the whole F02 family.
- 38 clusters are new (37 with corpus rows).
- Sites are exact (UhdmId rank) instead of type/name/span matches.

## 9. Residues ranked (what the next briefs should take — OPEN only)

1. **FULLNAME-IN-TYPESPEC-SUBTREE (H01)**: 334 row-modes, 309 open clusters, +130 row-modes on top of the pairs;
   STABLE/TAIL, so a parenting/naming law on our copies reaches it (TypeEmit.cpp buildStructTs /
   materializeDefNetTs; ParamEmit.cpp for the package cases). The single largest yield.
2. **Unparented golden typespec refs (N0003, N0008, N0138; FULLNAME golden-empty)**: 57 + 34 row-modes; golden
   leaves the operation/constant's ref_typespec without VpiParent. N0003 alone clears 21 row-modes on top of the
   pairs (the best single cluster). Mint: emitParameters (ParamEmit.cpp).
3. **hier_path element spans and names (N0001 SPAN\|ref_obj under hier_path, N0007/N0019 golden-empty full
   names)**: 82 + 38 + 22 row-modes; ExprEmit.cpp emitExpr.
4. **Object sharing outside typespecs (classes C, C2, D, E, E2)**: 36 structural row-modes; the elaborated
   imported-parameter clone (N0002, 58 row-modes touched, 206 probe cases) is the biggest.
5. **Spans: SPAN\|operation, SPAN\|constant (N0005 folded-constant endcol), SPAN\|bit_select, SPAN\|struct_typespec
   beyond the pair-B list, include_file_info lines (N0064, 14 row-modes: the r11u125 macro/include residue)**.
6. **The --elabuhdm clones (section 6)** and the typedef alias on net typespecs (class B).

## Files

* `clusters.csv` — every (row-mode, cluster) with its object count (test,mode,corpus,first_field,cluster_id,objects; 7425 rows).
* `probe_clusters.csv` — every (probe case, cluster) (case,law,first_field,cluster_id,objects; 6869 rows).
* `cluster_index.csv` / `family_index.csv` — ranked, with rows per corpus, probe cases, alone yield, first-in rows, coverage, r11u128map id, site, probe laws, key, example.
* `fail_list.csv` / `probe_fail_list.csv` — the flip fail list: every row-mode / probe case not strict-equal, its first cluster, coverage, site, clusters, open clusters, whether the pairs clear it (and the downstream verdict).
* `evidence/clusters/N####_*.txt` — golden and our records around the example object (mode-4 flags included), the holder on the other side, the row's facets (367 files).
* `evidence/objects.csv` (one example per cluster), `evidence/row_objects.csv` (one example per (row-mode or case, cluster), with the object count: 14,294 rows).
* `evidence/pins.txt`, `pinprep2.tsv`, `sites.json`, `decoded_sites.json` — gdb backtraces, the exact ranks, the sites.
* `evidence/final.txt`, `extra.txt` — the pipeline's printouts (yields, greedy, first clusters, probe views, full-name classes).
* `evidence/structural.txt`, `sweep_gates.txt`, `verify.txt`, `canaries.txt`, `dbcmp_attr.txt`, `controls/`.
* `drivers/` — `run.sh` (the pipeline), `strictcmp_x.cpp` + `cc.sh`, `run1.sh`, `jobs.py`, `probejobs.py`, `probelaw.py`, `analyze.py`, `common.py`, `final.py`, `extra.py`, `evid.py`, `rowobjects.py`, `objrank.cpp`, `pinprep2.py`, `pinprep.py` (r11u128map's type/name/span matcher with dump roots as arguments; superseded by pinprep2.py), `pinsite.sh`, `pinall.py`, `sites.py`.
