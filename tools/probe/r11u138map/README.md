# r11u138map — the strict ground map, fourth edition (measurement only)

Base `e562f4d4` (branch matrix-1.87), after passes 130 and 131 and the strict flip (c9e2923c: `STRICT_NOTEQUAL`
rows are the gate's explicit residue; `results/golden_*.csv` ARE the fail lists). No edit to `src/`, `scripts/`,
`results/`, `tests/` or `third_party/`; this directory is the whole patch. Worktree `/tmp/wt_r11u138`, system-deps
config, `-j 2`. Frozen binaries (`chmod 555`, before any measurement):

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `c7b333fcf978012efd649d7383f77730` | the worktree's pristine build, byte-identical to the main tree's `build/slang-uhdm` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | byte-identical to the main tree's (mode 4, r11u129; the tool is unchanged since 4f73d52f) |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | drivers/strictcmp_x.cpp (r11u132map's variant, same md5 as its `strictcmp_x2`): the committed tool + the mode-4 rule's inputs and `--dump-ids` in the dump; stdout identical to the committed tool (40 / 40, evidence/verify.txt) |
| `slang-uhdm.g1` | `4049435634d65f99c89611ca46d5cefd` | the same source with `-DCMAKE_CXX_FLAGS=-g1` (build_g1), for gdb only; databases byte-identical to the release binary's (5 / 5 sampled cases) |
| `objrank` | `87f0a607ef941a44e4d7a2487fae7016` | drivers/objrank.cpp: an object's creation rank among its type |

Law names are written `law <name>` (no section sign), so scripts/law_index.py does not read this directory as a
pass of laws; adding this README still adds one row (`| r11u138map |  |  | 0 | 0 |`) to the passes table of
tests/LAWS.md, as r11u128map and r11u132map did: the landing must run `python3 scripts/law_index.py` and commit
tests/LAWS.md with it (this pass may not edit tests/). A slang-fenced test that is a strict-NE surelog row (both
modes) is written `FENCED_1` everywhere (file names included), as in r11u132map. Probe case paths: the grid
directory some passes name `cases/` is written `cases/`, as r11u132map wrote it (map `/cases/` back to `/cases/` to
join with `results/golden_probe.csv`).

## 0. Where we stand (e562f4d4, the committed baselines)

| corpus | mode | judge-equal | strict-equal (`CMP_EQUAL`) | `STRICT_NOTEQUAL` | tests NE in some mode |
|---|---|---|---|---|---|
| surelog | default | 480 | 354 | 126 | 152 |
| surelog | testflags | 474 | 330 | 144 | |
| uhdm2rtlil | default | 803 | 643 | 160 | 160 (the same names in both modes) |
| uhdm2rtlil | testflags | 803 | 643 | 160 | |
| probe cases | — | 4087 | 2112 | 1975 | — |

**The fail list: 590 row-modes (312 tests) + 1975 probe cases.** First fields over the 590 corpus row-modes:
fullname 245, endcol 60, line 59, depth 59, file 47, endline 39, col 32, type 22, name 12, count 9, value 4,
decompile 2. Probe: fullname 738, endcol 351, depth 236, line 213, file 135, type 105, endline 78, col 77, name 31,
value 5, count 3, decompile 3. Surelog NE in default only: DecValue Moves PackStructField PackageParamConst
PortInitVal (+ Rggen Scoreboard YosysBigSimEllip, judged in default only); NE in testflags only: AllPackageSignal
ArrayExprFuncArg ArrayVarName CarryAdd ClogParam DollarBits EmptyAssign EvalFuncNamed FileList ForeachFunction
FuncParam FuncRetArray FuncStruct GenScopeHierPath3 HierPathTypespec ImplicitPackedStructNet InterfInst
InterfaceUnpackedStructArrayDim JKFlipflop NoParamSubs OneNetInterf OneNetRange PortByName SequenceInst TypespecExpr
UnsizedFunc. **Every uhdm2rtlil fail row-mode (320 of 320) is downstream IDENTICAL**
(`results/downstream_uhdm2rtlil.csv`); the 2 EQUIVALENT rows (func_upto, matching_end_labels) are strict-equal.

Since r11u132map (4f73d52f; evidence/delta.txt): 86 corpus row-modes and 43 probe cases left the fail list (676 ->
590, 2018 -> 1975), none entered; by their r11u132map first cluster the corpus ones were COVERED r11u130 36,
COVERED r11u131 13, OPEN 37 (side effects of the landed laws). Clusters 2378 -> 2365: 15 gone (13 OPEN, one each of
r11u130's and r11u131's), 2 new (Q0001: one BuildUVMPkg method-call ref name, 2 row-modes; Q0002: one probe case).
Of the 33 clusters r11u132map gave to passes 130/131, 31 are still present (N0011 29 -> 9, N0016 26 -> 4, N0037 18
-> 4, N0047 15 -> 5, N0012 29 -> 23, N0034 19 -> 13, N0040 17 -> 11; the net-binding clusters and the macro line
model clusters unchanged). 566 of 590 surviving row-modes keep their first cluster; 525 keep their strict cell.

## 1. Method

1. **Input**: the e562f4d4 reference sweep `/tmp/intr11u136` (READ-ONLY; every one of its 3273 `slang:` lines
   names the main-tree binary, md5 `c7b333fcf978` = the worktree's own pristine build; its status and strict
   columns equal `results/golden_surelog.csv` and `results/golden_uhdm2rtlil.csv` on 1596 + 1742 of 1596 + 1742
   rows). The job list is every `STRICT_NOTEQUAL` row-mode of the committed baselines (the gate's fail list since
   c9e2923c): 590 = 126 + 144 surelog + 160 + 160 uhdm2rtlil. Probe: all 4087 cases, golden =
   `scripts/check_probe.py`'s `cache_dir(rel)` (its key now carries a sha1 of the case's files), ours =
   `/tmp/intr11u136/probe/<rel with / -> __>.uhdm`.
2. `drivers/run1.sh`: `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job. strictcmp_x is r11u132map's
   variant (drivers/strictcmp_x.cpp, byte-identical build `db96066a…`): the committed tool (unchanged since
   4f73d52f) plus the mode-4 rule's inputs in the dump; its stdout and rc equal the committed tool's on 40 of 40
   sampled rows (evidence/verify.txt). All 590 corpus runs rc=2; probe 2112 rc=0 + 1975 rc=2, the NE set and every
   `differ:<field>(<n>)` cell equal to `results/golden_probe.csv`.
3. `drivers/analyze.py` (r11u132map's aligner and mode-4 reimplementation, unchanged) records EVERY differing
   object; its per-row reimplementation agrees with the tool's own stdout (field tally, objects differing, first
   field) on **2565 of 2565 rows**, and with the csv strict cell on every corpus row (0 CELL-MISMATCH).
4. Clusters use r11u132map's key (`facet|type|shape|under:<walk parent type>` + the `@builtin` / `@in-typespec`
   splits), so **a cluster that persists keeps its r11u132map id (N####)**; a cluster new since r11u132map gets
   `Q####`. `rank` orders them by corpus row-modes, then probe cases.
5. Sites, exact for every cluster: the example object's UhdmId (a `--dump-ids` re-dump) gives its creation rank
   among its type's objects (drivers/objrank.cpp), the `-g1` exporter is stopped at that call of
   `Serializer::Make<type>` and the first three source frames are the site, each with the nearest law above it.
   Round 1 (r11u132map's pinprep2 + pinall, one gdb run per cluster) pinned 265 clusters of the r11u132map set;
   round 2, `drivers/pinmulti.py`, pins every cluster of one example row in ONE gdb run (a Python breakpoint per
   needed `Make<type>` counts calls and records the backtrace at the wanted ranks) and pinned the rest; on 4 of 4
   clusters pinned both ways it reproduces round 1's frames line for line. The `-g1` build writes databases
   byte-identical to the release binary's (5 of 5 sampled probe cases) and, run in the worktree, object ranks
   identical to the reference sweep's (3 of 3). A mint site is where the object is BORN; for a full-name or span
   cluster the field may be written (or the parent set) elsewhere, so the decoded fix sites of passes 130/131 and
   of this map are carried as notes (evidence/decoded_sites.json).
6. Coverage by the two live pairs, from their briefs' r11u132map ids:
   * **r11u133 (pair A: ExprEmit/EmitHelpers/StmtEmit/ParamEmit)**: N0003 N0008 N0138 (unparented golden
     ref_typespec), N0001 N0007 N0019 (hier_path element spans/names), N0005 N0036 (constant/select spans),
     N0002 N0441 N0133 N0554 (the elaborated imported-parameter clone and sharing classes C, C2, E, E2);
   * **r11u134 (pair B: TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main)**: N0004 N0014 N0028 N0032 N0013
     N0020 N0019 (full name in the typespec subtree), N0031 N0042 (range-bound constants), N0045 (member-default
     constant), N0124 N0280 N0282 N0652 N0695 N1124 N1286 N1837 N1849 (the --elabuhdm clones), N0085 (class B
     typedef alias). **N0019 is named by both briefs.**
   * **Residues of the landed passes 130/131** (a cluster r11u132map gave to r11u130/r11u131 that is still present)
     go to the pair whose ground holds the FIX site: the site pass 130/131 decoded where they did (R1, R7, R10 and
     the port-view residue: `RESIDUE_DECODED` in drivers/final.py), else the file of the pinned mint frame.
   * **The net-binding class** (N0006 N0021 N0022 N0023 N0046 N1098: pass 131's R1) is **OPEN on the module
     ground** (ModuleEmit: emitContAssigns, emitScopeClocking's caller, emitInstance), not counted in either pair.
   Yields are OPTIMISTIC (a covered cluster counts as fixed whole) and given twice: NAMED (the briefs' ids only) and
   +RESIDUES.
7. Every slang-fenced test name is written `FENCED_<n>` in every artifact (drivers/redact.py reads the names from
   RESUME.md, never spells them); one fenced test is a strict-NE surelog row in both modes (`FENCED_1`, as in
   r11u132map). Probe case paths follow r11u132map's spelling (the header
   note above): a grid directory is written `cases/`; every other path component is verbatim.

## 2. Positive controls (evidence/controls/, evidence/verify.txt)

| control | result |
|---|---|
| surelog/default/1364_2005 | `STRICT_EQUAL 159 objects`, record dumps byte-identical (159) |
| surelog/default/HierPathInterfBlock | `STRICT_EQUAL 226 objects`, dumps identical (226) |
| uhdm2rtlil/default/1DUnpackedArray | `STRICT_EQUAL 194 objects`, dumps identical (194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, `lhsPath: design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline row `CMP_NOTEQUAL` both modes |
| analyzer rule vs tool stdout | 2565 / 2565 rows (590 corpus + 1975 probe) |
| csv strict cell vs tool | 590 / 590 corpus, 1975 / 1975 probe; the probe NE set = `results/golden_probe.csv`'s |
| variant vs committed tool | 40 / 40 sampled rows, stdout and rc byte-identical |
| gdb pinning, two methods | 4 / 4 clusters: pinmulti's frames = pinall's frames, line for line |
| classifier can see | the structural classifier places all 90 structural row-modes; class H (other) holds 0 |

## 3. The live pairs: yield and the fail list after them

| | clusters | row-modes cleared | tests cleared (every NE mode) | probe cases cleared |
|---|---|---|---|---|
| r11u133 (pair A), NAMED | 12 | 29 | 13 | 47 |
| r11u133 (pair A), + residues | 20 | 35 | 16 | 47 |
| r11u134 (pair B), NAMED | 19 | 25 | 14 | 20 |
| r11u134 (pair B), + residues | 37 | 47 | 28 | 152 |
| **both, NAMED** | 30 | **56** | **28** | **69** |
| **both, + residues** | 56 | **97** | **51** | **201** |
| family-extended upper bound (every cluster of a family either pair touches) | 1346 | 285 | — | 871 |

| corpus | mode | fails today | A (named / +res) | B (named / +res) | A+B (named / +res) | **fails after both pairs** (named / +res) |
|---|---|---|---|---|---|---|
| surelog | default | 126 | 7 / 8 | 4 / 5 | 12 / 16 | **114 / 110** |
| surelog | testflags | 144 | 4 / 5 | 7 / 14 | 12 / 21 | **132 / 123** |
| uhdm2rtlil | default | 160 | 9 / 11 | 7 / 14 | 16 / 30 | **144 / 130** |
| uhdm2rtlil | testflags | 160 | 9 / 11 | 7 / 14 | 16 / 30 | **144 / 130** |
| **corpus** | | **590 row-modes / 312 tests** | 29 / 35 | 25 / 47 | 56 / 97 | **534 / 493 row-modes; 284 / 261 tests** |
| **probe cases** | | **1975** | 47 / 47 | 20 / 152 | 69 / 201 | **1906 / 1774** |

The yields are OPTIMISTIC: a covered cluster counts as fixed whole. The 51 tests the pairs clear in every NE mode
(+ residues): surelog ArrayVarName CarryAdd ClogParam DollarBits ForeachFunction GenForIfaceLocalparamBound
GenForIfaceLocalparamNestedGen GenIfIfaceParamStructField HierPathStruct IntegerConcat LogicTypedef NoParamSubs
NoReducTypespec OneNetInterf ParamMultiConcat PartSelectNoParent PortByName SelectHierPath SignedBin TypespecExpr
WireType; uhdm2rtlil IndexedPartSelectInFor IndexedPartSelectOfArrayElement LocalParamInNestedForLoops
ParameterInitializedByPartSelectOfParametersAssignedToVar PartSelectInFor ReplicationPassedToInstance
SumOfParametersInNestedForLoops def_ctx_struct_param expr_width_cast gen_scope_typaram ibex_alu ibex_branch_predict
ibex_csr ibex_fetch_fifo iface_array_elem_cfg_param iface_cfg_param_def_pass indexed_partsel_array
latch_decoder_partial latch_nested_ex_field latch_tlb_napot mem_ff_partial_rsp mem_packed_2d_byte_write net_types
param_unpacked_struct_array port_chained_type_param portsel_struct_param struct_dynamic_range
struct_pattern_named_default typed_named_pattern unpacked_elem_partsel_comb (row-modes in evidence/report.txt).

After both pairs, row-modes by open clusters left: 1 open cluster 179, 2: 118, 3: 37, 4: 30, 5+: 129
(evidence/extra.txt). By the ground of their open clusters: only pair-B ground 261, only pair-A ground 92, both 126,
with an unpinned cluster 14 (evidence/report.txt).

Notes on the pairs' named clusters (evidence/decoded_sites.json):
* **N0019 is named by both briefs** (pair A's hier_path element names, pair B's typespec subtree): its mint is
  TypeEmit.cpp emitSyntaxExpr (law hpSymbolicSelect), pair B's file. The two pairs must agree who takes it.
* **N0138** (pair A) is minted and named in ModuleEmit.cpp emitInstance (the ELAB conn REPLICATION actual-fold
  block beside law patFlatUnsizedMemberWidth61; r11u131 R3) — pair B's file.
* **N0001** (pair A): r11u131 R2 pinned one of its shapes (the base ref of a struct-parameter member path in a
  constant context) to TypeEmit.cpp emitSyntaxExpr; the example mint here is ExprEmit.cpp emitExpr. The cluster
  spans both grounds.
* N0003 fell from 57 to 14 row-modes (law pkgPatReadTsNoParent131); N0008 from 34 to 29.
* The --elabuhdm clusters N0124 … N1849 are unchanged (25 surelog/testflags row-modes, 12 of them first); beyond
  them, 582 OPEN clusters (50 corpus row-modes, all testflags) are minted inside UHDM's own `ElaboratorListener`
  DeepClone (site `UHDM library DeepClone < DeepCopy … run from main (uhdm_main.cpp)`): the same class, pair B's
  uhdm_main ground.

### The covered clusters


| cluster | rows sl/u2r | tests | first in | probe | alone | coverage | key | site |
|---|---|---|---|---|---|---|---|---|
| N0001 | 82 36/46 | 42 | 26 | 78 | 4 | COVERED r11u133 (N0001) | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSub — NOTE: r11u131 R2 pinned one shape of this cluster (the base ref of a struct-parameter member path in a constant context, located at the MEMBER token in golden;  |
| N0002 | 58 18/40 | 29 | 20 | 206 | 3 | COVERED r11u133 (N0002) | `struct\|golden-only:fewer-copies\|parameter\|under:param_assign` | emitParameters (ParamEmit.cpp, law replFoldTs) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law — DECODED: golden's elaborated param_assign Lhs for an imported package parameter is a module-scoped CLONE (the r11u122 C0012 shape); ours points at the package p |
| N0004 | 48 22/26 | 24 | 22 | 33 | 10 | COVERED r11u134 (N0004) | `fullname\|ref_typespec\|tok:id@id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < emitTopP |
| N0005 | 44 18/26 | 22 | 4 | 163 | 0 | COVERED r11u133 (N0005) | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsP |
| N0007 | 38 26/12 | 20 | 2 | 33 | 2 | COVERED r11u133 (N0007) | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubro |
| N0009 | 32 14/18 | 16 | 12 | 21 | 0 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmi — DECODED (r11u130 R2): struct typespec spans taken at the use (one shared object where golden holds a copy per use) |
| N0010 | 30 10/20 | 15 | 0 | 4 | 0 | COVERED r11u133 (residue of r11u131, ExprEmit.cpp) | `span\|constant\|col+endcol\|under:param_assign` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTargetKinds) < emitParameters (ParamEmit.cpp,  |
| N0008 | 29 5/24 | 15 | 4 | 25 | 2 | COVERED r11u133 (N0008) | `fullname\|ref_typespec\|golden-empty\|under:constant` | emitParameters (ParamEmit.cpp, law timeLitParamIntTs) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.c — DECODED: the same as N0003 on a constant's typespec ref: golden unparented |
| N0014 | 27 11/16 | 14 | 8 | 22 | 0 | COVERED r11u134 (N0014) | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypespec (TypeEmit.c |
| N0015 | 27 7/20 | 14 | 0 | 1 | 0 | COVERED r11u134 (residue of r11u131, decoded r11u131 R7: macro-argument line model, UhdmExporter.cpp locLineCo | `span\|constant\|line+col+endline+endcol\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineColla — DECODED (r11u131 R7): macro-argument spans (ibex prim_assert $error/$time lines): the multi-line macro line model, UhdmExporter.cpp locLineCol / fullFilePath (p |
| N0017 | 26 6/20 | 13 | 0 | 5 | 0 | COVERED r11u134 (residue of r11u131, decoded r11u131 R7: macro-argument line model, UhdmExporter.cpp locLineCo | `span\|constant\|endline+endcol\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineColla — DECODED (r11u131 R7): CovMacro's predefined SV_COV_* constants end at 0:0; the macro line model, UhdmExporter.cpp locLineCol |
| N0018 | 25 21/4 | 13 | 0 | 18 | 0 | COVERED r11u133 (residue of r11u131, ExprEmit.cpp) | `fullname\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNa |
| N0012 | 23 11/12 | 12 | 14 | 5 | 0 | COVERED r11u133 (residue of r11u130, decoded r11u130 R1: type-parameter override by a module-local enum, Param | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < emitTaskFuncs (TaskFuncEmit.cp — DECODED (r11u130 R1): the type-parameter override by a module-local enum typedef; ParamEmit.cpp emitParameters after law typeParamChainBorrow45 (buildEnumTs(... |
| N0019 | 22 8/14 | 11 | 0 | 38 | 0 | COVERED r11u133+r11u134 (N0019) | `fullname\|ref_obj\|golden-empty@in-typespec\|under:hier_path` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRange |
| N0020 | 22 2/20 | 11 | 22 | 1 | 0 | COVERED r11u134 (N0020) | `fullname\|ref_obj\|tok:::id::->.@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVa |
| N0024 | 20 12/8 | 10 | 6 | 37 | 0 | COVERED r11u134 (residue of r11u131, ModuleEmit.cpp) | `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec` | emitModuleDef (ModuleEmit.cpp, law ifaceDefNetTypespecIsTheModuleRule224) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < m — NOTE (r11u131 R6): the tagged-pattern key's cast typespec (golden struct, ours integer_typespec); not decoded |
| N0025 | 20 6/14 | 11 | 0 | 12 | 0 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `depth\|constant\|range->operation` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarR — DECODED (r11u130 R5): TypedefWithParameter: our net typespec carries a Typedef_alias clone golden lacks (class B), so the walk diverges before the range |
| N0026 | 20 0/20 | 10 | 0 | 10 | 0 | COVERED r11u134 (residue of r11u131, decoded r11u131 R7: macro-argument line model, UhdmExporter.cpp locLineCo | `span\|constant\|line+endline\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineColla — DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol |
| N0027 | 20 0/20 | 10 | 4 | 8 | 0 | COVERED r11u134 (residue of r11u131, decoded r11u131 R7: macro-argument line model, UhdmExporter.cpp locLineCo | `span\|sys_func_call\|line+endcol\|under:begin` | emitExpr (ExprEmit.cpp, law sysCallKwTypeArgNameSpan131) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) < emitStmt (StmtEmit.c — DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol |
| N0028 | 20 6/14 | 10 | 2 | 3 | 0 | COVERED r11u134 (N0028) | `fullname\|ref_typespec\|tok:->id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < patchParamTypespec |
| N0029 | 20 0/20 | 10 | 0 | 0 | 0 | COVERED r11u134 (residue of r11u131, decoded r11u131 R7: macro-argument line model, UhdmExporter.cpp locLineCo | `span\|sys_func_call\|line+endline\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law sysCallKwTypeArgNameSpan131) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSu — DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol |
| N0030 | 19 11/8 | 11 | 7 | 58 | 5 | COVERED r11u134 (residue of r11u131, decoded r11u131 R10: elaborated process/cont_assign named by the definiti | `fullname\|ref_obj\|tok:id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law genLpUse — DECODED (r11u131 R10): the elaborated process / continuous assignment named by the definition (work@dut.b for work@top.dut.b): shared def-view objects in Module |
| N0031 | 19 11/8 | 10 | 0 | 19 | 0 | COVERED r11u134 (N0031) | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < |
| N0032 | 19 11/8 | 10 | 10 | 16 | 1 | COVERED r11u134 (N0032) | `fullname\|ref_typespec\|tok:->id@id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmE |
| N0033 | 19 5/14 | 10 | 0 | 12 | 0 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `struct\|ours-only:fewer-copies\|operation\|under:range` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) < makeTypespec (TypeEmit.cpp, law typ — DECODED (r11u130 R5): as N0025 |
| N0036 | 18 14/4 | 10 | 0 | 7 | 0 | COVERED r11u133 (N0036) | `span\|bit_select\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitMixedHierPath (ExprEmit.cpp, law hpM |
| N0039 | 17 17/0 | 10 | 2 | 222 | 2 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExpor — DECODED (r11u130 R3 + K0070): the int_typespec declaration-vs-use span; its corpus head TypeParam is the type-parameter definition net (materializeDefNetTs -> m |
| N0042 | 17 11/6 | 9 | 0 | 16 | 0 | COVERED r11u134 (N0042) | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < |
| N0043 | 17 11/6 | 10 | 2 | 5 | 0 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmi — DECODED (r11u130 R2): as N0009 |
| N0045 | 16 8/8 | 8 | 2 | 12 | 0 | COVERED r11u134 (N0045) | `struct\|golden-only:fewer-copies\|constant\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < main (uhdm_ma — DECODED: golden lists the member default constant twice (a copy under typespec_member); ours shares one object. HOLDER pinned |
| N0044 | 14 6/8 | 7 | 10 | 73 | 2 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitTopPorts (ModuleEmit — DECODED (r11u130 R2): as N0009 |
| N0003 | 14 8/6 | 7 | 6 | 36 | 0 | COVERED r11u133 (N0003) | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInstance (Modu — DECODED: golden's ref_typespec of an assignment-pattern/cast operation carries NO VpiParent (uhdm-dump: no vpiParent line), so its synthesised full name is empt |
| N0059 | 14 6/8 | 7 | 0 | 33 | 0 | COVERED r11u133 (residue of r11u131, ExprEmit.cpp) | `struct\|ours-only:absent\|integer_typespec\|under:ref_typespec` | emitExpr (ExprEmit.cpp, law castTgtDefaultIsLiteral) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubrout — NOTE (r11u131 R6): the ours-side twin of N0024 (integer_typespec golden lacks) |
| N0034 | 13 9/4 | 7 | 0 | 5 | 0 | COVERED r11u133 (residue of r11u130, decoded r11u130 R1: type-parameter override by a module-local enum, Param | `span\|enum_typespec\|ours-zero\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < emitTaskFuncs (TaskFuncEmit.cp — DECODED (r11u130 R1): the span face of N0012, same site |
| N0077 | 13 9/4 | 7 | 2 | 3 | 2 | COVERED r11u133 (residue of r11u131, ExprEmit.cpp) | `fullname\|ref_obj\|tok:id.id[id].->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFo |
| N0085 | 12 4/8 | 6 | 6 | 39 | 6 | COVERED r11u134 (N0085) | `struct\|ours-only:fewer-copies\|ref_typespec\|under:logic_typespec` | bareScalarTdCopyOf (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52) < bareScalarTypedefVarTs (TypeEmit.cpp, law unpackedElemVecTypedef) < exportDesi |
| N0040 | 11 9/2 | 6 | 2 | 34 | 0 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef |
| N0124 | 11 11/0 | 11 | 0 | 0 | 0 | COVERED r11u134 (N0124) | `fullname\|ref_obj\|tok:id.id->id\|under:assignment` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |
| N0133 | 10 0/10 | 5 | 6 | 10 | 0 | COVERED r11u133 (N0133) | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < exportDesign (UhdmExporte — DECODED: SHARING: ours's elaborated cont_assign Rhs func_call is the definition's object (listed once); golden holds a copy (r11u128map's 'fold' reading was wro |
| N0136 | 10 10/0 | 9 | 5 | 4 | 5 | COVERED r11u134 (residue of r11u131, decoded r11u131 R10: elaborated process/cont_assign named by the definiti | `fullname\|ref_obj\|tok:id.id->id\|under:cont_assign` | UHDM library DeepClone < DeepClone < elabModule_inst (--elabuhdm, testflags) run from main (uhdm_main.cpp) — DECODED (r11u131 R10): as N0030 (InterfInst), ModuleEmit.cpp |
| N0138 | 10 8/2 | 5 | 6 | 3 | 6 | COVERED r11u133 (N0138) | `fullname\|ref_typespec\|tok:id.->\|under:constant` | emitInstance (ModuleEmit.cpp, law patFlatUnsizedMemberWidth61) < emitInstance (ModuleEmit.cpp, law bindIfaceTwinInParent46) < exportDesign (UhdmExport — NOTE: r11u131 R3: a port connection written as a replication folds to a constant whose ref_typespec golden names through <instance>.<port>; ModuleEmit.cpp emitI |
| N0011 | 9 7/2 | 5 | 2 | 12 | 0 | COVERED r11u134 (residue of r11u131, TypeEmit.cpp) | `file\|logic_net\|golden-empty\|under:ref_obj` | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cpp, law hoistedThisRidesTheForwardedBlock |
| N0280 | 8 8/0 | 8 | 0 | 0 | 0 | COVERED r11u134 (N0280) | `fullname\|ref_obj\|tok:id.id->id\|under:bit_select` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |
| N0282 | 8 8/0 | 8 | 4 | 0 | 0 | COVERED r11u134 (N0282) | `fullname\|function\|tok:id.id->id\|under:module_inst` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |
| N0441 | 6 6/0 | 3 | 6 | 0 | 1 | COVERED r11u133 (N0441) | `struct\|ours-only:fewer-copies\|constant\|under:array_expr` | emitParameters (ParamEmit.cpp, law patOpMemberAsmSplit28) < emitInstance (ModuleEmit.cpp, law elabParamTsRebind) < exportDesign (UhdmExporter.cpp, law — DECODED: ours lists two constants where golden shares one (array_expr default pattern) |
| N0047 | 5 1/4 | 3 | 2 | 38 | 0 | COVERED r11u134 (residue of r11u130, decoded r11u130 residue: port-view parameter full name, ModuleEmit.cpp em | `fullname\|parameter\|tok:id->id.id.id\|under:param_assign` | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInstance (Modu — DECODED (r11u130 residue): the port-view parameter full name faces law portViewParamDefName130 did not reach (iface_param_port_width, interface_array(_fanout)); |
| N0037 | 4 4/0 | 2 | 0 | 1 | 0 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `file\|packed_array_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < emitTopPorts (ModuleEmit.cpp, law defNetTsScope) < exportDesign (UhdmExporter.cpp, law |
| N0554 | 4 0/4 | 2 | 2 | 1 | 2 | COVERED r11u133 (N0554) | `struct\|golden-only:fewer-copies\|constant\|under:cont_assign` | operator() (ModuleEmit.cpp, law genvarWholeCaRhsFold68) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) < operator() (ModuleEmit.cpp, la — DECODED: SHARING: ours's elaborated cont_assign Rhs is the param_assign's constant object (listed once); golden holds a copy. HOLDER pinned |
| N0652 | 4 4/0 | 4 | 2 | 0 | 0 | COVERED r11u134 (N0652) | `fullname\|ref_typespec\|tok:id@id.id.->id::id::\|under:io_decl` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |
| N0016 | 4 4/0 | 2 | 0 | 0 | 0 | COVERED r11u133 (residue of r11u130, ExprEmit.cpp) | `file\|logic_net\|golden-empty\|under:module_inst` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) < emitStmt (StmtEmit.cpp, law recvNam |
| N0695 | 3 3/0 | 3 | 1 | 0 | 1 | COVERED r11u134 (N0695) | `fullname\|ref_obj\|tok:id.id.id->id\|under:cont_assign` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |
| N0827 | 2 2/0 | 1 | 0 | 1 | 0 | COVERED r11u133 (residue of r11u131, ParamEmit.cpp) | `value\|parameter\|value:INT->empty\|under:module_inst` | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_ |
| N1124 | 2 2/0 | 2 | 2 | 0 | 2 | COVERED r11u134 (N1124) | `fullname\|ref_typespec\|tok:->.id\|under:int_var` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |
| N1286 | 1 1/0 | 1 | 1 | 0 | 0 | COVERED r11u134 (N1286) | `fullname\|ref_obj\|tok:id[id].id[id].id[id - n].id.->\|under:bit_select` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |
| N1837 | 1 1/0 | 1 | 1 | 0 | 0 | COVERED r11u134 (N1837) | `fullname\|begin\|tok:id.->\|under:initial` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |
| N1849 | 1 1/0 | 1 | 1 | 0 | 0 | COVERED r11u134 (N1849) | `fullname\|logic_var\|tok:id@id.id.->id::id::\|under:function` | UHDM ElaboratorListener::elabModule_inst DeepClone (UHDM library, out of scope) run from main (uhdm_main.cpp, the --elabuhdm block); the clone copies  — DECODED: testflags --elabuhdm clone; fix on our definition object or in the uhdm_main post-elaboration pass |

## 4. Ranked OPEN clusters with sites

Rows = corpus row-modes (surelog/uhdm2rtlil); first in = row-modes whose FIRST differing object is in the
cluster; +pairs = row-modes it clears alone on top of both pairs (+ residues). Site = the PINNED mint (function,
file, nearest law) with the decoded fix site as a note where one exists. Full list: `cluster_index.csv` (every
cluster: rank, rows per corpus, probe cases, alone yield, first-in rows, coverage, r11u132map coverage, r11u128
id, site, probe laws, key, example); one record-window file per cluster with at least 4 row-modes or in the pin
set in evidence/clusters/ (727 files); one example object per cluster in evidence/objects.csv (2365).


| rank | cluster | rows sl/u2r | tests | first in | probe | +pairs | key | example (row #golden/#ours type name golden / ours) | site (mint: function (file, nearest law) < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|
| 5 | N0006 | 39 15/24 | 22 | 20 | 29 | 18 | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj` | uhdm2rtlil/testflags/ParameterColonReference #50/-1 logic_net 'a' golden=1 objs ours= | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law caUnbasedFillPackedAggregateKeepsRaw43) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) — DECODED (r11u131 R1, class A net binding): a continuous assignment whose right-hand side Surelog REDUCES to a constant (UhdmWriter writeCont_assign's simplified |
| 17 | N0021 | 21 17/4 | 11 | 8 | 16 | 2 | `fullname\|ref_obj\|tok:id.id.->\|under:operation` | uhdm2rtlil/testflags/dff_different_styles #782/782 ref_obj 'preset' golden=work@dffsr2.uut.preset.preset ours=work@dffsr | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitInstance (ModuleEmit.cpp, law elabPortConnUnitEnumNet) — DECODED (r11u131 R1, class A names): port connection operands: golden binds the DEFINITION net and names the ref through the port (work@dffsr2.uut.preset.preset |
| 18 | N0022 | 21 9/12 | 12 | 8 | 3 | 0 | `struct\|golden-only:elsewhere\|logic_net\|under:ref_obj` | uhdm2rtlil/testflags/sva_value_change_changed #107/-1 logic_net 'clk' golden=1 objs ours= | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitEventExpr (StmtEmit.cpp, law evCtrlOperandBinds108) < emitScopeClocking (ModuleEmit.cpp, law clockingSkewDelayControl) — DECODED (r11u131 R1, class A): the default clocking block's event binds golden's DEFINITION net; the elaborated listing calls emitScopeClocking(body, ..., topNe |
| 19 | N0023 | 21 9/12 | 12 | 0 | 3 | 0 | `struct\|ours-only:elsewhere\|logic_net\|under:ref_obj` | uhdm2rtlil/testflags/sva_value_change_changed #-1/131 logic_net 'clk' golden= ours=1 objs | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) — DECODED (r11u131 R1, class A): the ours-side twin of N0022 (the elaborated net listed where golden lists the definition net), ModuleEmit.cpp emitScopeClocking's |
| 32 | N0041 | 17 17/0 | 9 | 2 | 34 | 1 | `file\|unsupported_typespec\|ours-empty\|under:ref_typespec` | surelog/testflags/ClassVar #52/52 unsupported_typespec 'paths' golden=dut.sv 16:11:16:16 ours= 16:11:16:16 | emitStmt (StmtEmit.cpp, law foreachArraySelfSelectAssignDropsTs19) < emitStmt (StmtEmit.cpp, law invalidChild14) < emitStmt (StmtEmit.cpp, law invalidChild14) |
| 36 | N0046 | 16 8/8 | 9 | 10 | 6 | 7 | `struct\|ours-only:fewer-copies\|logic_net\|under:ref_obj` | uhdm2rtlil/testflags/cdc_static_basic #-1/101 logic_net 'src_data' golden= ours=1 objs | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) — DECODED (r11u131 R1, class A mirror): a continuous-assignment RHS operand: golden binds the ELABORATED net, ours the definition net; the same function (ModuleEm |
| 37 | N0050 | 15 15/0 | 8 | 0 | 10 | 0 | `span\|operation\|col+endcol\|under:assignment` | surelog/testflags/MacroArgMismatch #15/15 operation '' golden=5:13:5:15 ours=5:14:5:16 | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) |
| 38 | N0051 | 15 15/0 | 8 | 2 | 9 | 0 | `span\|class_typespec\|endcol\|under:ref_typespec` | surelog/testflags/ClassParamAsParam #8/8 class_typespec 'object' golden=18:14:18:20 ours=18:14:18:30 | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter.cpp, law typedefAliasSharesTypespec25) < emitClassDefn (UhdmExporter.cpp, law classDefnVi |
| 39 | N0052 | 15 13/2 | 8 | 2 | 8 | 2 | `fullname\|ref_obj\|tok:id.id[id]::->\|under:bit_select` | uhdm2rtlil/testflags/struct_param_func_loop #162/162 ref_obj 'k' golden=p::inside_regions::C.base[k]::k ours=p::inside_r | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) |
| 40 | N0053 | 15 11/4 | 8 | 2 | 7 | 2 | `span\|begin\|line+endline+endcol\|under:function` | uhdm2rtlil/testflags/func_local_compound_xor #33/33 begin '' golden=19:5:19:20 ours=18:5:18:30 | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitPackageClassMethodClones (ParamEmit.cpp, law pkgFreeSub |
| 41 | N0054 | 15 15/0 | 8 | 4 | 3 | 0 | `span\|assignment\|endcol\|under:begin` | surelog/testflags/CovMacro #101/101 assignment '' golden=12:9:12:52 ours=12:9:12:86 | emitStmt (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCall |
| 42 | N0055 | 15 13/2 | 8 | 0 | 1 | 0 | `span\|ref_obj\|line+endline\|under:operation` | surelog/testflags/ExplictiPorts #43/43 ref_obj 'b' golden=38:14:38:15 ours=39:14:39:15 | emitBadConcatOperand160 (ExprEmit.cpp, law badConcatCompoundOperands162) < emitBadConcatFromSyntax160 (ExprEmit.cpp, law classArgBind12) < emitExpr (ExprEmit.cpp, law droppedIdxRecvCall26) |
| 43 | N0056 | 15 13/2 | 8 | 6 | 1 | 2 | `span\|bit_typespec\|endcol\|under:ref_typespec` | surelog/testflags/GenCase #5/5 bit_typespec '' golden=6:13:6:16 ours=6:13:6:25 | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitTaskFuncs (TaskFuncEmit.cpp, law pkgTdCloneRefNoBind18) < emitModuleDef (ModuleEmit.cpp, law thisImplicitNetBoth38) |
| 44 | N0057 | 15 5/10 | 8 | 0 | 0 | 0 | `struct\|golden-only:fewer-copies\|ref_typespec\|under:enum_typespec` | surelog/testflags/PackedEnumPort #49/-1 ref_typespec '' golden=8 objs ours= | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp, law importCopyAggFormalOwnCopy32) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 46 | N0058 | 14 2/12 | 7 | 4 | 55 | 4 | `span\|operation\|endcol\|under:param_assign` | uhdm2rtlil/testflags/assert_wide_const_cond #82/82 operation '' golden=11:36:11:45 ours=11:36:11:55 | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) |
| 49 | N0060 | 14 10/4 | 8 | 0 | 15 | 0 | `span\|operation\|col+endcol\|under:operation` | surelog/default/BlackConst #761/761 operation '' golden=10:103:10:131 ours=10:65:10:93 | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < operator() (ExprEmit.cpp, law pkgTdCloneRefNoBind18) < emitExpr (ExprEmit.cpp, law pkgTdCloneRefNoBind18) |
| 50 | N0061 | 14 12/2 | 8 | 0 | 8 | 0 | `span\|bit_select\|col+endcol\|under:hier_path` | uhdm2rtlil/testflags/struct_member_trailing_index #172/172 bit_select 'sat' golden=36:20:36:24 ours=36:16:36:25 | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectErased4) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) |
| 51 | N0063 | 14 2/12 | 7 | 0 | 2 | 4 | `fullname\|ref_typespec\|ours-empty\|under:operation` | uhdm2rtlil/testflags/iface_nested_param_field #326/326 ref_typespec '' golden=work@iface_nested_param_field.u.sub ours= | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender112) < emitExpr (ExprEmit.cpp, law concatRefNoSubst) |
| 52 | N0064 | 14 14/0 | 8 | 14 | 0 | 0 | `span\|include_file_info\|line+endline\|under:design` | surelog/testflags/ApbSlave #4/4 include_file_info '' golden=375:12:375:32 ours=373:12:373:32 | emitIncludeFileInfos (UhdmExporter.cpp, law includeLeadTabIsText130v) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| 53 | N0065 | 14 10/4 | 7 | 0 | 0 | 0 | `depth\|typespec_member\|struct_typespec->struct_typespec` | surelog/testflags/TypedefUnpacked #37/30 typespec_member 'x' golden=9 struct_typespec(pkg::a) < ref_typespec ours=5 stru | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 54 | N0066 | 14 10/4 | 7 | 0 | 0 | 0 | `depth\|ref_typespec\|typespec_member->typespec_member` | surelog/testflags/TypedefUnpacked #38/31 ref_typespec '' golden=10 typespec_member(x) < struct_typespec(pkg::a) ours=6 t | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 55 | N0067 | 13 13/0 | 7 | 0 | 47 | 0 | `file\|class_typespec\|ours-empty\|under:ref_typespec` | surelog/testflags/ApbSlave #713/717 class_typespec 'svunit_testsuite' golden=svunit_testrunner.sv 32:9:32:25 ours= 0:0:0 | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPropIsArrayVar6) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor5 |
| 56 | N0068 | 13 13/0 | 7 | 0 | 47 | 0 | `span\|class_typespec\|ours-zero\|under:ref_typespec` | surelog/testflags/ApbSlave #713/717 class_typespec 'svunit_testsuite' golden=32:9:32:25 ours=0:0:0:0 | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPropIsArrayVar6) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor5 |
| 57 | N0069 | 13 13/0 | 7 | 0 | 25 | 0 | `span\|string_typespec\|line+col+endline+endcol\|under:ref_typespec` | surelog/testflags/ClassTypeParam #32/32 string_typespec '' golden=26:30:26:36 ours=20:36:20:42 | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < sharedTypespec (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) |
| 58 | N0070 | 13 13/0 | 7 | 1 | 17 | 0 | `span\|function\|endline+endcol\|under:class_defn` | surelog/testflags/ClassTypeParam #80/80 function 'check_all_sva_passed' golden=11:2:11:9 ours=11:2:12:13 | emitTaskFuncs (TaskFuncEmit.cpp, law dpiExportListedAtExportItem216) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTd |
| 59 | N0071 | 13 13/0 | 7 | 0 | 17 | 0 | `span\|hier_path\|endcol\|under:operation` | surelog/default/SimpleConstraint #212/212 hier_path 'frame.randomize' golden=57:12:57:29 ours=57:12:57:27 | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) |
| 60 | N0072 | 13 13/0 | 7 | 0 | 16 | 0 | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | surelog/testflags/ArrayMethodIterator #17/17 class_typespec 'uvm_callback' golden=10:50:10:62 ours=14:3:14:5 | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) |
| 61 | N0074 | 13 7/6 | 7 | 4 | 9 | 4 | `fullname\|ref_typespec\|tok:->id@id.\|under:enum_typespec` | uhdm2rtlil/testflags/EnumInPackage #48/48 ref_typespec '' golden=pkg3::enum2 ours=work@dut.pkg3::enum2 | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 62 | N0075 | 13 13/0 | 7 | 2 | 8 | 0 | `span\|enum_typespec\|line+col+endline+endcol\|under:package` | surelog/testflags/FuncCase #2/2 enum_typespec 'fpnew_pkg::opgroup_e' golden=7:46:7:55 ours=2:1:4:15 | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 63 | N0076 | 13 7/6 | 7 | 7 | 5 | 0 | `fullname\|ref_obj\|tok:id.->\|under:part_select` | uhdm2rtlil/testflags/comb_dyn_2d_packed_sel #240/240 ref_obj 'ALIGN' golden=work@dut.wr_off_i.ALIGN ours=work@dut.ALIGN | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < operator() (ModuleEmit.cpp, law genCaTernaryFoldGenScope22) |
| 66 | N0078 | 13 11/2 | 7 | 4 | 2 | 4 | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` | surelog/testflags/PackStructVar #115/115 ref_obj 'top_pkg::TL_SZW' golden=tlul_pkg::tlul_pkg::tl_h2d_t::d_size::top_pkg: | emitSyntaxExpr (TypeEmit.cpp, law qualSelBaseNoWhitespace41) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) |
| 67 | N0079 | 13 11/2 | 7 | 0 | 1 | 0 | `span\|constant\|line+endline\|under:operation` | surelog/testflags/BlackConst #274/274 constant '' golden=9:22:9:23 ours=154:22:154:23 | emitBadConcatOperand160 (ExprEmit.cpp, law typeParamScopedCallRef59) < emitBadConcatFromSyntax160 (ExprEmit.cpp, law classArgBind12) < emitExpr (ExprEmit.cpp, law droppedIdxRecvCall26) |
| 68 | N0080 | 13 13/0 | 7 | 0 | 1 | 0 | `span\|struct_typespec\|line+col+endline+endcol\|under:package` | surelog/default/FuncStructValSimple #298/298 struct_typespec 'config_pkg::cva6_user_cfg_t' golden=38:63:38:75 ours=3:11: | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 69 | N0081 | 13 13/0 | 7 | 2 | 0 | 0 | `span\|ref_obj\|line+col+endline+endcol\|under:operation` | surelog/testflags/PortExpr #7/7 ref_obj 'op[79]' golden=2:9:2:21 ours=4:11:5:3 | emitPortExprPort (ModuleEmit.cpp, law importedPkgVecPortClone) < emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitModuleDefPorts (ModuleEmit.cpp, law caNestedModDefNameScoped99) |
| 70 | N0082 | 13 9/4 | 7 | 0 | 0 | 0 | `depth\|struct_typespec\|ref_typespec->ref_typespec` | surelog/testflags/TypedefUnpacked #36/29 struct_typespec 'pkg::a' golden=8 ref_typespec < struct_typespec(pkg::a) ours=4 | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 71 | N0083 | 12 2/10 | 6 | 0 | 63 | 0 | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec` | surelog/testflags/LogicTypespec #15/-1 range '' golden=3 objs ours= | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) |
| 72 | N0084 | 12 8/4 | 6 | 0 | 51 | 4 | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` | uhdm2rtlil/testflags/cva6_struct_param_field #69/69 ref_typespec '' golden=work@cva6_struct_param_field.I.x ours=x | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) |
| 74 | N0086 | 12 4/8 | 6 | 2 | 20 | 0 | `file\|constant\|golden-empty\|under:typespec_member` | uhdm2rtlil/testflags/struct_param_field_shift #75/75 constant '' golden= 0:0:0:0 ours=dut.sv 20:33:20:49 | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79 |
| 75 | N0087 | 12 4/8 | 6 | 0 | 20 | 0 | `span\|constant\|golden-zero\|under:typespec_member` | uhdm2rtlil/testflags/struct_param_field_shift #75/75 constant '' golden=0:0:0:0 ours=20:33:20:49 | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79 |
| 76 | N0088 | 12 10/2 | 6 | 6 | 19 | 4 | `span\|ref_obj\|line+col+endline+endcol\|under:port` | uhdm2rtlil/testflags/empty_port_connection #159/159 ref_obj 'carry' golden=19:22:19:27 ours=33:6:33:11 | emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInterfaceDef (ModuleEmit.cpp, law modportExprPort) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) |
| 77 | N0089 | 12 12/0 | 12 | 1 | 10 | 0 | `fullname\|ref_obj\|tok:id.id->id\|under:operation` | surelog/testflags/FuncRetArray #137/137 ref_obj 'i' golden=work@main.top1.ASSIGN_VADDR.i ours=work@top.ASSIGN_VADDR.i | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law memberActualLeak) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) |
| 78 | N0090 | 12 6/6 | 6 | 8 | 3 | 1 | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | uhdm2rtlil/testflags/typedef_package #46/46 logic_typespec 'pkg::uint8_t' golden=2:10:11:35 ours=2:10:2:21 | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFile |
| 79 | N0091 | 12 10/2 | 6 | 0 | 1 | 0 | `span\|ref_obj\|col+endcol\|under:operation` | surelog/testflags/MacroArgMismatch #16/16 ref_obj 'd' golden=5:14:5:15 ours=5:15:5:16 | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) |
| 80 | N0092 | 12 2/10 | 6 | 2 | 0 | 0 | `value\|constant\|value:UINT->UINT\|under:range` | surelog/default/UnionCast #179/179 constant '' golden=00/64/UINT:00/9 ours=00/64/UINT:0/9 | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabSize113) < buildStructTs (TypeEmit.cpp, law pkgTdRangeViewFold18) |
| 81 | N0093 | 11 11/0 | 6 | 0 | 65 | 0 | `span\|io_decl\|line+col+endline+endcol\|under:function` | surelog/testflags/ApbSlave #445/449 io_decl 'name' golden=43:30:43:34 ours=59:34:59:38 | emitTaskFuncs (TaskFuncEmit.cpp, law classScopedTdDeclTsUnsupported11) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClass |


Owner file of the pinned mint, OPEN clusters with corpus rows (clusters / corpus row-modes touched): TypeEmit.cpp
318 / 287, ExprEmit.cpp 387 / 235, ModuleEmit.cpp 98 / 134, ParamEmit.cpp 150 / 73, UHDM library under
--elabuhdm (uhdm_main.cpp) 582 / 50, StmtEmit.cpp 87 / 47, UhdmExporter.cpp 50 / 35, TaskFuncEmit.cpp 101 / 24,
not pinned 53 / 16 (of the 55 unpinned clusters, 46 are Earlgrey-only clusters whose pin run was OOM-killed,
evidence/unpinned_earlgrey.txt, and 9 golden-only objects with no holder on our side; an unpinned cluster that
r11u132map pinned shows that pin, marked `(r11u132map pin)`).

**Clusters that are the ONLY open cluster of a row** (row-modes they clear alone on top of both pairs): N0006 18
(net binding), N0108 8, N0046 7 (net binding), N0271 6, N0270 6, N0394 5, N0281 5, N0084 4, N0272 4, N0088 4, N0078
4, N0074 4, N0058 4, N0284 4, N0063 4, N0427 3, N0412 3.

**OPEN families, greedy on top of both pairs** (family, its rows, cumulative rows / tests): 1 FULLNAME-IN-TYPESPEC-
SUBTREE (H01, 223 rows, 295 open clusters) 179 / 92 · 2 FULLNAME\|ref_obj\|tok (H02, 112) 212 / 113 · 3
STRUCT-SHARE\|golden\|logic_net (H09 = net binding) 234 / 125 · 4 STRUCT-SHARE\|ours\|logic_net (H13 = net binding)
258 / 137 · 5 SPAN\|operation (H08) 280 / 148 · 6 STRUCT-TSCOPY\|golden (H05) 296 / 156 · 7 SPAN\|struct_typespec
(H07) 308 / 162 · 8 FULLNAME\|bit_select\|tok (H16) 318 / 167 · 9 SPAN\|logic_typespec (H11) 326 / 170 · 10
SPAN\|hier_path (H15) 332 / 173 · … 25 steps 404 / 210; every cluster 590 / 312 (evidence/final.txt).

**The full-name ground under mode 4** (evidence/extra.txt): 584,080 full-name facets: OUT (outside any copy)
151,252 in 248 row-modes; inside a copy with different tails (TAIL) 99,237 in 128; inside a copy with equal tails
that mode 4 still reads as content (STABLE) 333,591 in 150 — the same shape as r11u132map's; a naming/parenting law
reaches each of them.

### The first clusters (what the gate names first on each failing row)


| first cluster | row-modes it heads | coverage | key | site |
|---|---|---|---|---|
| N0001 | 26 | COVERED r11u133 (N0001) | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSub — NOTE: r11u131 R2 pinned one shape of this cluster (the base ref of a struct-parameter member path in a constant context, located at the MEMBER token in golden;  |
| N0004 | 22 | COVERED r11u134 (N0004) | `fullname\|ref_typespec\|tok:id@id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < emitTopP |
| N0020 | 22 | COVERED r11u134 (N0020) | `fullname\|ref_obj\|tok:::id::->.@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVa |
| N0002 | 20 | COVERED r11u133 (N0002) | `struct\|golden-only:fewer-copies\|parameter\|under:param_assign` | emitParameters (ParamEmit.cpp, law replFoldTs) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law — DECODED: golden's elaborated param_assign Lhs for an imported package parameter is a module-scoped CLONE (the r11u122 C0012 shape); ours points at the package p |
| N0006 | 20 | OPEN (net binding, module ground: ModuleEmit) | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law caUnbasedFillPackedAggregateKeepsRaw43) < emitInstance (Mo — DECODED (r11u131 R1, class A net binding): a continuous assignment whose right-hand side Surelog REDUCES to a constant (UhdmWriter writeCont_assign's simplified |
| N0064 | 14 | OPEN | `span\|include_file_info\|line+endline\|under:design` | emitIncludeFileInfos (UhdmExporter.cpp, law includeLeadTabIsText130v) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < main (uhdm_main.c |
| N0012 | 14 | COVERED r11u133 (residue of r11u130, decoded r11u130 R1: type-paramete | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < emitTaskFuncs (TaskFuncEmit.cp — DECODED (r11u130 R1): the type-parameter override by a module-local enum typedef; ParamEmit.cpp emitParameters after law typeParamChainBorrow45 (buildEnumTs(... |
| N0009 | 12 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmi — DECODED (r11u130 R2): struct typespec spans taken at the use (one shared object where golden holds a copy per use) |
| N0032 | 10 | COVERED r11u134 (N0032) | `fullname\|ref_typespec\|tok:->id@id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmE |
| N0139 | 10 | OPEN | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < emitParameters (Pa |
| N0046 | 10 | OPEN (net binding, module ground: ModuleEmit) | `struct\|ours-only:fewer-copies\|logic_net\|under:ref_obj` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_m — DECODED (r11u131 R1, class A mirror): a continuous-assignment RHS operand: golden binds the ELABORATED net, ours the definition net; the same function (ModuleEm |
| N0044 | 10 | COVERED r11u134 (residue of r11u130, TypeEmit.cpp) | `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitTopPorts (ModuleEmit — DECODED (r11u130 R2): as N0009 |
| N0283 | 8 | OPEN | `file\|struct_typespec\|ours-empty\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExp |
| N0014 | 8 | COVERED r11u134 (N0014) | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypespec (TypeEmit.c |
| N0090 | 8 | OPEN | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < exportDesign |
| N0021 | 8 | OPEN (net binding, module ground: ModuleEmit) | `fullname\|ref_obj\|tok:id.id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitInstance (ModuleEmit.cpp, law el — DECODED (r11u131 R1, class A names): port connection operands: golden binds the DEFINITION net and names the ref through the port (work@dffsr2.uut.preset.preset |
| N0279 | 8 | OPEN | `fullname\|ref_typespec\|tok:id@id.id::id.->id::id::\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law a7) < exportDesign (UhdmExporter.cpp, law caUne |
| N0022 | 8 | OPEN (net binding, module ground: ModuleEmit) | `struct\|golden-only:elsewhere\|logic_net\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitEventExpr (StmtEmit.cpp, law evCtrlOperandBinds108) < emitScopeClocking (ModuleEmit.cpp, la — DECODED (r11u131 R1, class A): the default clocking block's event binds golden's DEFINITION net; the elaborated listing calls emitScopeClocking(body, ..., topNe |
| N0076 | 7 | OPEN | `fullname\|ref_obj\|tok:id.->\|under:part_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < operator() (ModuleEmit.cpp, law genCaT |
| N0030 | 7 | COVERED r11u134 (residue of r11u131, decoded r11u131 R10: elaborated p | `fullname\|ref_obj\|tok:id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law genLpUse — DECODED (r11u131 R10): the elaborated process / continuous assignment named by the definition (work@dut.b for work@top.dut.b): shared def-view objects in Module |
| N0088 | 6 | OPEN | `span\|ref_obj\|line+col+endline+endcol\|under:port` | emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInterfaceDef (ModuleEmit.cpp, law modportExprPort) < exportDesign (UhdmExporter.cpp, law imp |
| N0441 | 6 | COVERED r11u133 (N0441) | `struct\|ours-only:fewer-copies\|constant\|under:array_expr` | emitParameters (ParamEmit.cpp, law patOpMemberAsmSplit28) < emitInstance (ModuleEmit.cpp, law elabParamTsRebind) < exportDesign (UhdmExporter.cpp, law — DECODED: ours lists two constants where golden shares one (array_expr default pattern) |
| N0056 | 6 | OPEN | `span\|bit_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitTaskFuncs (TaskFuncEmit.cpp, law pkgTdCloneRefNoBind18) < emitModuleDef (ModuleEmit.cpp,  |
| N0137 | 6 | OPEN | `fullname\|ref_typespec\|tok:id::id::id::id::->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < buildStructTs (TypeEmi |
| N0085 | 6 | COVERED r11u134 (N0085) | `struct\|ours-only:fewer-copies\|ref_typespec\|under:logic_typespec` | bareScalarTdCopyOf (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52) < bareScalarTypedefVarTs (TypeEmit.cpp, law unpackedElemVecTypedef) < exportDesi |
| N0433 | 6 | OPEN | `file\|packed_array_typespec\|golden-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < buildUnionTs (TypeEmit.cpp, law pkgTdRangeViewFold18) < exportDesign (UhdmExporter.cpp |
| N0271 | 6 | OPEN | `fullname\|ref_typespec\|tok:id@id.->\|under:packed_array_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < buildStructTs (TypeEmit.cpp, law pkgTdRangeViewFold18) < emitPackage (ParamEmit.cpp, law ag |
| N0138 | 6 | COVERED r11u133 (N0138) | `fullname\|ref_typespec\|tok:id.->\|under:constant` | emitInstance (ModuleEmit.cpp, law patFlatUnsizedMemberWidth61) < emitInstance (ModuleEmit.cpp, law bindIfaceTwinInParent46) < exportDesign (UhdmExport — NOTE: r11u131 R3: a port connection written as a replication folds to a constant whose ref_typespec golden names through <instance>.<port>; ModuleEmit.cpp emitI |
| N0003 | 6 | COVERED r11u133 (N0003) | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInstance (Modu — DECODED: golden's ref_typespec of an assignment-pattern/cast operation carries NO VpiParent (uhdm-dump: no vpiParent line), so its synthesised full name is empt |
| N0135 | 6 | OPEN | `span\|struct_typespec\|endline+endcol\|under:module_inst` | buildStructTs (TypeEmit.cpp, law typeParamAnonAggMemberNoReduce35) < emitTypedefs (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52) < emitModuleDef ( |

147 distinct first clusters.

## 5. The structural rows after passes 130/131 (depth 59 / type 22 / count 9 = 90 row-modes, 47 tests)

Every one classed by its first cluster (evidence/structural.txt); r11u132map section 5 updated (86 -> 90: the
net-binding class grew by the rows whose earlier heads passes 130/131 cleared — PackStructField/default,
sva_counter both modes, YosysOldOpen/testflags).

| class | row-modes (tests) | first cluster | what differs | coverage | clear with the pairs |
|---|---|---|---|---|---|
| A. NET-BINDING | 38 (21) | N0006, N0046, N0022, N0021 | which net `ref_obj.Actual` names (below) | **OPEN, module ground** | 0 (43 row-modes clear with the pairs + net binding) |
| B. TYPEDEF-ALIAS on the net typespec | 6 (3: LogicTypedef, WireType, net_types) | N0085 | ours's net typespec carries `Typedef_alias`; golden's has none | COVERED r11u134 | 6 |
| C. IMPORTED-PARAMETER CLONE | 20 (10: BitSelectOfParameterPassedToSubmodule HierPathOverride Kmac ParamFromPackage ParameterFromPkgOnParameterPortList StructArrayParameterInitializedByPatternPassedAsPort ff_dead_both_branches ff_dead_guarded_reset param_struct_field_bitsel param_unpacked_struct_array) | N0002 | golden's ELABORATED param_assign Lhs for an imported package parameter is a module-scoped clone; ours points at the package parameter | COVERED r11u133 | 3 (Kmac/default, param_unpacked_struct_array both modes) |
| C2. CONSTANT COPIED | 6 (3: DefaultPatternInt DefaultPatternModule ParamArrayUnsizedPattern) | N0441 | an array_expr default pattern: ours two constants, golden one shared | COVERED r11u133 | 2 (the default-mode DefaultPattern rows) |
| D. MEMBER-DEFAULT COPY | 2 (StructParamFuncBodyFieldCompare) | N0045 | golden lists the member default constant twice | COVERED r11u134 | 0 (4 other open clusters) |
| D2. CAST TARGET | 6 (def_ctx_struct_param latch_decoder_partial latch_tlb_napot) | N0024 | the tagged-pattern key's cast typespec: golden struct, ours integer | COVERED r11u134 (residue of r11u131; not decoded, r11u131 R6) | 6 |
| E. SHARED func_call | 6 (FunctionParam SelectGivenBySelectOnParameterInFunction func_local_array) | N0133 | ours's elaborated cont_assign Rhs is the definition's func_call; golden a copy | COVERED r11u133 (mint: ModuleEmit.cpp emitContAssigns) | 0 (1-2 other open clusters each) |
| E2. SHARED constant | 2 (SumOfParametersInNestedForLoops) | N0554 | ours's gen-scope cont_assign Rhs is the param_assign's constant; golden a copy | COVERED r11u133 (mint: ModuleEmit.cpp gen-scope lambda) | 2 |
| F. TYPE-PARAMETER DEF NET | 2 (TypeParam) | N0770 | the definition net typed by a type parameter: golden logic_typespec (the default), ours int_typespec (r11u130 R3) | OPEN | 0 |
| G. EXTRA FOLDED CONSTANT | 2 (BlackParrotComplex) | N0724 | ours folds an elaborated param_assign Rhs to a constant golden keeps as an operation | OPEN | 0 |

### The net-binding class: OPEN on the module ground

Pass 131 decoded it (r11u131 R1, verified r11v131 V1) to ModuleEmit sites, none of them on pair A's ground: the
Actual choice is ModuleEmit's in every shape measured.
* **continuous-assignment LHS over a reduced RHS** (N0006 golden-only DEFINITION net): UhdmWriter
  writeCont_assign's `simplified == false` reduce clones the assign with a context-free ElaboratorContext, so the
  LHS keeps the definition net; ours binds the elaborated net. Fix: ModuleEmit.cpp **emitContAssigns**, the
  COMPUTED-RHS fold rule beside law caStrengthAndDelayDeclined88 (an element select of a parameter is the missing
  kind).
* **the mirror, a continuous-assignment RHS operand** (N0046 ours-only): golden ELAB, ours DEF — the same function.
* **the default clocking event** (N0022 / N0023): golden binds the DEFINITION net; the elaborated listing calls
  `emitScopeClocking(body, …, topNets, false)` where the global clocking block passes the definition nets
  (**emitScopeClocking's caller**, ModuleEmit.cpp beside law caProgramGenFlattensEveryKind95).
* **port connection operands** (N0021 names, `work@dffsr2.uut.preset.preset` vs `work@dffsr2.preset`): golden binds
  the DEFINITION net and names the ref through the port; **emitInstance** chooses the map and the name.
* N1098 (PortExpr, golden-only `op[79]` net, 2 row-modes) is the same key shape, not decoded.

67 row-modes (37 tests) carry a net-binding cluster; 38 have one as their first cluster; **43 row-modes (23 tests)
clear with the pairs + net binding** (97 -> 140; surelog Moves/default PackStructField/default PackageParamConst/default
YosysOldSimpleSpi YosysOldSpi; uhdm2rtlil Clog2OfSumWithParameterIn2InstancesOfSubmodule ParameterColonReference
StructLocalParam StructParameter array_assign cdc_static_basic dff_different_styles param_type_logic_width
partsel_simple sva_counter sva_range sva_throughout sva_value_change_changed sva_value_change_changed_wide
sva_value_change_rose unbased_unsized_param vector_index wandwor, both modes where NE). Every uhdm2rtlil row of the
class is downstream IDENTICAL. The full list with first cluster and clusters per row is in evidence/structural.txt.

## 6. Probe cases by law

1975 NE cases in 990 clusters (probe_clusters.csv: case, law, first field, cluster, objects; laws from
scripts/law_index.py). 201 clear with the pairs (+ residues), 69 with the named clusters. Laws with the most NE
cases: loopCaParamReadKeepsLiteral116 84/123, badConcatOperandsFromSyntax160 71/71, genCaOpFoldElabTs115 68/68,
tpPackedArrayTsVar108 57/73, tpElemRebindElabPort110 57/61, nestedGenProcLhsKeepsRef116 46/74,
portViewRangeRecvParams 45/55, pvExprDefaultFold115 43/50, caNestedModPortedDefShell101 36/38,
srlgCondOpInstValueTernFold9 32/140. Probe-heavy clusters: N0039 (int_typespec decl-vs-use span, 222 cases,
residue of r11u130 -> pair B), N0002 (class C, 206), N0005 (folded-constant endcol under param_assign, 163), N1897
(`work@sub.work@sub::innermod.i`-shaped net names, 119 cases, 0 corpus rows), N0261 (113), N0469 (111), N1898
(92), N0151 (85), N0127 (79), N0001 (78), N0470 (77), N0044 (73), N0152/N0153 (function begin unlocated, 71).

## 7. Recommended next briefs per ground (on top of both pairs; greedy, evidence/report.txt)

**Module/type ground (pair B's files; every OPEN cluster of it clears 358 row-modes / 188 tests with the pairs):**
1. **Net binding** (N0006 N0046 N0021 N0022 N0023): +43 row-modes / 23 tests on top of both pairs (97 -> 140; N0006 +
   N0046 alone give 97 -> 124), the largest yield on the map; ModuleEmit.cpp emitContAssigns / emitScopeClocking's caller / emitInstance, decoded above.
2. **FULLNAME-IN-TYPESPEC-SUBTREE beyond pair B's named seven**: N0108 (`work@top.ABC.BC1.B` vs `B`), N0084, N0271,
   N0074, N0638, N0096, N0139, N0279, N0137: golden prefixes the use scope on a ref inside a typedef copy
   (TypeEmit.cpp buildStructTs / buildEnumTs / makeTypespec); with net binding 97 -> 167 in ten steps.
3. **N0270** (the shared typedef's end moved to the LAST net declarator's unpacked dimension — decoded here: writeNets'
   end-only populate lands on the shared typedef; ModuleEmit.cpp materializeDefNetTs, law defNetEndOnlyLoc130's
   slot), 6 single-cluster row-modes.
4. **N0281 / N0078 / N0412** (TypeEmit.cpp emitSyntaxExpr: ref names inside a type-parameter typespec, the
   ours-empty full name of a package-qualified bound, a package function call span in a range).
5. **N0088** (port ref_obj located at the port declaration instead of the connection), **N0064** (include_file_info
   lines under the macro line model: 14 row-modes, all first, all UVM/Earlgrey/Scr1/YosysOldOpen — r11u130 R6),
   **N0041** (unsupported_typespec without file, 17 row-modes).

**Expression/parameter ground (pair A's files; every OPEN cluster clears 189 row-modes / 99 tests with the pairs):**
1. **N0394** (a parameter operand substituted into an elaborated localparam operation: golden's constant carries the
   file, ours has none — decoded here; ParamEmit.cpp emitParameters): 5 single-cluster row-modes.
2. **N0058 / N0413 / N0212 / N0245** (operation spans in parameter initializers and system calls: ExprEmit.cpp
   emitExpr under ParamEmit.cpp emitParameters).
3. **N0063** (golden names an operation's ref_typespec `work@….u.sub`, ours unnamed), **N0272 / N0427 / N0052 /
   N0357 / N0523** (bit_select / ref_obj full names through a port or a generate index: ExprEmit.cpp emitExpr).
4. **N0284** (ours lists an extra constant under a struct-parameter cont_assign substitution: ModuleEmit's
   emitCaStructParamSubst55 calling ExprEmit).
5. The probe-heavy OPEN clusters N0261 / N0469 / N0151 (genCaOpFoldElabTs115, badConcatOperandsFromSyntax160: the
   formal's / parameter's typespec reference on a folded constant).

## Files

* `clusters.csv` — every (row-mode, cluster) with its object count (test,mode,corpus,first_field,cluster_id,objects; 7164 rows).
* `probe_clusters.csv` — every (probe case, cluster) (case,law,first_field,cluster_id,objects; 6726 rows).
* `fail_list.csv` (590) / `probe_fail_list.csv` (1975) — the gate's fail list: every `STRICT_NOTEQUAL` row-mode / probe
  case, its strict cell, first cluster, its coverage and site, clusters, open clusters, whether the pairs clear it
  (`A+B`, `A`, `B`; + residues) and the downstream verdict.
* `cluster_index.csv` (2365) / `family_index.csv` — ranked, with rows per corpus, probe cases, alone yield, first-in
  rows, coverage, r11u132map coverage, r11u128 id, site, probe laws, key, example.
* `evidence/clusters/N####_*.txt` — golden and our records around the example object (mode-4 flags), the holder on
  the other side, the row's facets (727 files: every cluster with at least 4 row-modes or in the pin set).
* `evidence/objects.csv` (one example per cluster, 2365), `evidence/row_objects.csv` (one example per (row-mode or
  case, cluster), with the object count).
* `evidence/pins.txt` (the gdb frames, 2310 clusters), `sites.json`, `decoded_sites.json` (r11u132map's decodes +
  the pass 130/131 decodes + this map's N0270 / N0394), `pinprep2.tsv`, `pinwant*.txt`, `unpinned_earlgrey.txt`.
* `evidence/final.txt`, `extra.txt`, `report.txt`, `structural.txt`, `delta.txt` — the pipeline's printouts (yields,
  greedy, first clusters, probe views, full-name classes, per-ground briefs, structural rows, changes since
  r11u132map); `verify.txt`, `controls/`.
* `drivers/` — `run.sh` (the pipeline, every step), `strictcmp_x.cpp` + `cc.sh`, `run1.sh`, `jobs.py` (reads the
  `STRICT_NOTEQUAL` status), `probejobs.py`, `probelaw.py`, `analyze.py`, `common.py`, `final.py` (persistent ids,
  the pairs' coverage, residue routing), `extra.py`, `report.py`, `mdtables.py`, `structural.py`, `delta.py`,
  `evid.py`, `rowobjects.py`, `objrank.cpp`, `pinprep2.py` + `pinall.py` + `pinsite.sh` (one gdb run per cluster),
  `pinmulti.py` (one gdb run per row), `pinrecover.py`, `sites.py`, `redact.py`; `pinprep.py` (r11u132map's
  superseded matcher, kept for reference).
