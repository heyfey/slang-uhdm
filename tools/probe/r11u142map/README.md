# r11u142map — the strict ground map, fifth edition (measurement only)

Base `a7bee711` (branch matrix-1.87), after passes 133 (d8473d78) and 134 (8e8d2643) and the r11u141 refinements
(a7bee711). No edit to `src/`, `scripts/`, `results/`, `tests/` or `third_party/`; this directory is the whole patch.
Worktree `/tmp/wt_r11u142`, system-deps config, `-j 2`. Frozen binaries (`chmod 555` copies, before any
measurement; evidence/verify.txt):

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `c4ed97f9a285203b39547c8bd500249a` | the worktree's pristine a7bee711 build, byte-identical to the main tree's a7bee711 `build/slang-uhdm` (the brief's `c7b333fcf978` is the e562f4d4 binary; the r11u141 laws changed UhdmExporter/EmitHelpers/ExprEmit) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's; the tool is unchanged since 4f73d52f |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | drivers/strictcmp_x.cpp (maps 3 and 4's variant, the same md5): the committed tool + the mode-4 rule's inputs and `--dump-ids` in the dump; stdout + rc identical to the committed tool on 40 / 40 sampled rows |
| `slang-uhdm.g1` | `eb07a262a800e8bccd19ce65b1b19ae6` | the same source with `-DCMAKE_CXX_FLAGS=-g1`, gdb only; 654 of its 741 pin runs wrote the reference database byte for byte |
| `slang-uhdm.nb` | `7e68dc3dc6fb7983ecc487858a7383f3` | MEASUREMENT ONLY: a7bee711 + `tools/probe/r11u139netbind/law.patch` (it applies clean at a7bee711, offsets only; worktree `/tmp/wt_r11u142nb`) |
| `slang-uhdm.p137` | `614337e4c8d4b8833fe5c71262db8aae` | MEASUREMENT ONLY: **6ef15be0 = pass 137 (pair B r11u137), which LANDED while this map was measured**; byte-identical to the main tree's 6ef15be0 binary (worktree `/tmp/wt_r11u142p137`) |
| `objrank` | `3e213a154aab7f619443de5f11646f0a` | drivers/objrank.cpp: an object's creation rank among its type |

Law names are written `law <name>` (no section sign), so scripts/law_index.py does not read this directory as a
pass of laws; like maps 3 and 4 the README still adds one row (`| r11u142map |  |  | 0 | 0 |`) to the passes table of
tests/LAWS.md: the landing must run `python3 scripts/law_index.py` and commit tests/LAWS.md with it. The
slang-fenced test that is a strict-NE surelog row (both modes) is written `FENCED_1` everywhere (file names
included); drivers/pinmulti.py never runs slang-uhdm on a fenced test. The tests/probe grid directory is written `cases/` in
every artifact here, as maps 3 and 4 wrote it (map it back to the repo's own spelling, the one
results/golden_probe.csv uses, to join).

## 0. Where we stand (a7bee711, the committed baselines = the fail list)

| corpus | mode | judge-equal | strict-equal (`CMP_EQUAL`) | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 367 | 113 |
| surelog | testflags | 474 | 342 | 132 |
| uhdm2rtlil | default | 803 | 667 | 136 |
| uhdm2rtlil | testflags | 803 | 667 | 136 |
| probe cases | — | 4087 | 2221 | 1866 |

**The fail list: 517 row-modes (245 surelog + 272 uhdm2rtlil) in 275 tests (139 + 136) + 1866 probe cases.**
First fields, from the csvs' detail column: surelog fullname 85, line 43, endcol 42, file 22, depth 13, endline 13,
col 10, name 6, value 4, type 4, decompile 2, count 1; uhdm2rtlil fullname 96, file 34, depth 28, col 28, line 22,
type 22, endcol 18, endline 10, count 8, name 6; probe fullname 749, endcol 337, line 218, file 138, type 119, depth
110, col 80, endline 72, name 32, value 5, count 3, decompile 3. Surelog NE in default only: Moves PackStructField
PackageParamConst PortInitVal Rggen Scoreboard YosysBigSimEllip; NE in testflags only: AllPackageSignal
ArrayExprFuncArg ArrayVarName CarryAdd ClogParam DollarBits EmptyAssign EvalFuncNamed FileList ForeachFunction
FuncParam FuncRetArray FuncStruct GenScopeHierPath3 HierPathTypespec ImplicitPackedStructNet InterfInst
InterfaceUnpackedStructArrayDim JKFlipflop NoParamSubs OneNetInterf OneNetRange PortByName SequenceInst
TypespecExpr UnsizedFunc (every uhdm2rtlil fail test is NE in both modes). **Every uhdm2rtlil fail row-mode (272 of
272) is downstream IDENTICAL** (results/downstream_uhdm2rtlil.csv).

**Since map 4 (e562f4d4; evidence/delta.txt):** 73 corpus row-modes and 109 probe cases left the fail list (590 ->
517, 1975 -> 1866), **none entered**. Clusters 2365 -> 2142: 227 gone (225 OPEN, one each of pass 133's and pass
134's), 4 new. Of map 4's pair clusters, still present: pass 133's N0001 (82 -> 82), N0005 (44), N0007 (38 -> 34),
N0010, N0008, N0018, N0012, N0036, N0003, N0059, N0034, N0077, N0133, N0138, N0441, N0554, N0016, N0827 (N0002 is
gone); pass 134's N0004 (48 -> 4), N0009 (32 -> 18), N0014 (27 -> 16), N0028 (20 -> 14), N0031 (19 -> 15), N0032 (19
-> 2), N0085 (12 -> 4), N0019 (22 -> 2) and every macro-line, --elabuhdm and struct-span residue unchanged.
**Calibration of the optimistic yields: map 4 predicted 97 row-modes for the two pairs (+ residues); 73 left, and
only 24 of those were among the 97.** A covered cluster rarely clears whole; read every optimistic yield below as
an upper bound on the named rows and a weak predictor of which rows move (section 3 measures pass 137 against its
prediction: 54 of 68 predicted rows moved, plus 59 unpredicted).

## 1. Method (maps 3 and 4's pipeline, drivers/run.sh)

1. **Input**: the a7bee711 reference sweep `/tmp/intr11u141` (READ-ONLY). Every one of its 3273 `slang:` lines names
   the main-tree binary, built 16:32:21; every database was written after it (16:32:37-16:37:23), and four rows
   re-run with the frozen pristine binary are byte-identical. Its status and strict columns equal
   results/golden_surelog.csv and results/golden_uhdm2rtlil.csv on 1596 + 1742 of 1596 + 1742 rows, and
   results/golden_probe.csv on 4087 of 4087. Jobs: every `STRICT_NOTEQUAL` row-mode of the committed baselines
   (517 = 113 + 132 + 136 + 136), golden = the cache entry its cmds.txt names; every probe case (4087), golden =
   `scripts/check_probe.py`'s `cache_dir(rel)` (the key carries a sha1 of the case's files), ours =
   `/tmp/intr11u141/probe/<rel with / -> __>.uhdm`.
2. `drivers/run1.sh`: `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job. All 517 corpus runs rc=2;
   probe 2221 rc=0 + 1866 rc=2, the NE set and every `differ:<field>(<n>)` cell equal to results/golden_probe.csv.
3. `drivers/analyze.py` (unchanged) records EVERY differing object; its mode-4 reimplementation agrees with the
   tool's own stdout (field tally, objects differing, first field) on **2383 of 2383 rows** and with the csv
   strict cell on every corpus row (0 CELL-MISMATCH).
4. Clusters keep map 4's key (`facet|type|shape|under:<walk parent type>` + the `@builtin` / `@in-typespec`
   splits), so **a cluster whose key persists keeps its map-4 id** (2138 of 2142). A new key takes the next id from
   N0700 that no earlier map used: N0700-N2378 are all taken by maps 3 and 4, so the four new clusters are
   **N2379-N2382**.
5. Sites: `drivers/pinmulti.py` (one gdb run per example row, the `-g1` exporter stopped at the example object's
   `Serializer::Make<type>` rank) re-pinned 741 clusters (every cluster with >= 3 row-modes, first on a fail row,
   covered, >= 40 probe cases, or new) from the MAIN checkout's case directories, so each run's database can be
   compared with the reference one: `db=SAME` on 654, `DIFF` on 87 (MiniAmiq/default 86, SimpleUVM/default 1: the
   UVM order coin — those keep map 4's pin). `drivers/mksites.py`: 627 new pins agree with map 4's mint frame or
   have no map-4 pin, 18 name another mint (both are given), 9 whose new example row is an `--elabuhdm` testflags
   row minted by UHDM's DeepClone keep map 4's source pin; every other cluster keeps map 4's pin (marked
   `[r11u138map pin]` in cluster_index.csv). Decoded notes of maps 3/4 and this map (evidence/decoded_sites.json)
   ride on the site.
6. **Coverage by the live pairs**, from their briefs' map-4 ids:
   * **r11u140 (pair A: ExprEmit/EmitHelpers/StmtEmit/ParamEmit, base d8473d78)**: N0394, N0058 N0413 N0212 N0245
     N0050 N0060, N0063 N0272 N0427 N0052 N0357 N0523, N0061, N0284 N0041 N0053 N0054 N0055 N0079, N0261 N0469
     N0151; its named RESIDUES mapped to clusters by running the residue cases the pass READMEs name through the
     same pipeline (`drivers/casekeys.sh`, evidence/residue_cases.txt, evidence/residue_routes.json):
     pass-133 R2 -> **N0003** (tools/probe/r11u133repro/pkr p01, u01), R6 -> **N0142, N0451**
     (lhs/l04_hdr_unpacked: first=N0142), the emitMixedHierPath residues -> **N0077** (r11v133 F4: tix a02_gen_for,
     f06_gen_if) and **N2379, N2380** (the pass-133 trailing-select index names in UVM class-method bodies:
     law hpTrailSelIdxNamesByPath133 frames in the mint chain). R5 (lhs l01 l07 l09 l11) reads first=N0039 alone,
     but N0039 is the 222-case int_typespec declaration-vs-use span whose corpus head is the type-parameter
     definition net; it is NOT routed (one shape of it). R7 (tix t14), R8 (tix t08) and F4's hier_path index
     (tix a07) are keys the corpus does not carry.
   * **r11u137 (pair B: TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main, base 8e8d2643)**: N0108 N0084 N0271
     N0074 N0638 N0096 N0139 N0279 N0137, N0270, N0281 N0078 N0412, N0088 N0064 N0041 and the net binding N0006
     N0046 N0021 N0022 N0023 (r11u139's law.patch). **N0041 is named by both briefs.**
   * Four named ids are already gone at a7bee711: N0469 (pair A; 4 row-modes / 111 cases in map 4), N0074, N0279,
     N0137 (pair B). A cluster map 4 gave to passes 133/134 that is still present and no live brief names is
     `OPEN (residue of r11u133|r11u134: map 4 named it, still present)` or `OPEN (map 4 routed it to ... as a
     residue of ...; not landed)`.
7. **Two measured cross-sections** (the same jobs/analyzer/key on other databases, drivers/afternb.py):
   * **nb** = a7bee711 + r11u139's law.patch: a full `tests/sweep.sh --corpus "probe surelog uhdm2rtlil"` with the
     nb binary (`/tmp/r11u142_nbwd`, 3273 of 3273 slang lines name it), every remaining `STRICT_NOTEQUAL` row and
     probe case re-dumped and re-clustered;
   * **p137** = 6ef15be0 (pass 137 landed): the same, from a 6ef15be0 worktree (its sweep reproduces the 6ef15be0
     baselines exactly: `regressions=0 conversions=0 changes=0` in all three stages).
   The fail list and cluster index carry both (columns `*_after_nb`, `*_after_p137`).

## 2. Positive controls (evidence/controls/, evidence/verify.txt)

| control | result |
|---|---|
| surelog/default/1364_2005 | `STRICT_EQUAL 159 objects`, record dumps byte-identical (159 / 159) |
| surelog/default/HierPathInterfBlock | `STRICT_EQUAL 226 objects`, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray | `STRICT_EQUAL 194 objects`, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, `lhsPath: design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL` both modes |
| analyzer rule vs tool stdout | 2383 / 2383 rows (517 corpus + 1866 probe) |
| csv strict cell vs tool | 517 / 517 corpus, 1866 / 1866 probe; the probe NE set = results/golden_probe.csv's |
| variant vs committed tool | 40 / 40 sampled rows, stdout and rc byte-identical |
| reference databases vs frozen pristine binary | 4 / 4 rows byte-identical (ibex_alu/d, sva_range/t, ComplexHierPath/d, TypeParam/t) |
| pin validity | 654 / 741 gdb runs wrote the reference database byte for byte; the 87 others keep map 4's pin |
| nb binary sweep vs a7bee711 baselines | `regressions=0` in all three stages: surelog conversions 9, uhdm2rtlil 36, probe 19 — exactly r11u139's 45 + 19 at 53471a35 |
| p137 binary sweep vs 6ef15be0 baselines | `regressions=0 conversions=0 changes=0` in all three stages |

## 3. The live pairs: yield, and the fail list after them

### 3a. Predicted at a7bee711 (optimistic: a covered cluster counts as fixed whole; evidence/report.txt, afternb.txt)

| | clusters | row-modes cleared | tests cleared (every NE mode) | probe cases cleared |
|---|---|---|---|---|
| r11u140 (pair A), NAMED | 22 | 12 | 6 | 63 |
| r11u140 (pair A), + residues | 28 | 19 | 9 | 63 |
| r11u137 (pair B), NAMED (net binding included) | 18 | 68 | 34 | 42 |
| **both, + residues** | 45 | **86** | **43** | **103** |
| net binding **MEASURED** (the nb binary's full sweep) | 5 roads' clusters | **45** (surelog 9, uhdm2rtlil 36) | 24 | 19 |
| nb measured, then the other covered clusters optimistic | — | 45 + 39 = **84** | — | 19 + 85 |

| corpus | mode | fails today | after net binding (measured) | after both pairs (nb measured + rest optimistic) |
|---|---|---|---|---|
| surelog | default | 113 | 107 | 95 |
| surelog | testflags | 132 | 129 | 120 |
| uhdm2rtlil | default | 136 | 118 | 109 |
| uhdm2rtlil | testflags | 136 | 118 | 109 |
| **corpus** | | **517 row-modes / 275 tests** | **472** | **433 row-modes / 233 tests** |
| **probe cases** | | **1866** | **1847** | **1762** |

The nb conversions are exactly r11u139's 45 (BitsArray d/t, Moves d, PackStructField d, PackageParamConst d,
YosysOldSimpleSpi d/t, YosysOldSpi d/t; uhdm2rtlil AssignBitsCallToSubmoduleParameter, Clog2OfSum...,
ParameterColonReference, StructLocalParam, StructParameter, cdc_static_basic, dff_different_styles,
param_type_logic_width, partsel_simple, sva_counter, sva_range, sva_throughout, sva_value_change_changed,
sva_value_change_changed_wide, sva_value_change_rose, unbased_unsized_param, vector_index, wandwor, both modes),
`regressions=0` in all three stages (evidence/nb_sweep_summary.txt). Against the cluster prediction: of the 43
row-modes whose clusters are all named net-binding clusters, 41 convert (**array_assign d/t does not**: it keeps
`depth(1)` N0046, the unpacked-array-net Lhs road); 4 converting row-modes carry only **N0272**, a cluster pair A's
brief names (BitsArray d/t, AssignBitsCallToSubmoduleParameter d/t: road (c), connection operands) — **N0272 is
shared with the net-binding law; pair A should not count those rows.** The nb records hold 4 keys the pristine map
lacks (46 facets, `struct|{golden,ours}-only:elsewhere|{function,task}|under:design`: the YosysOldOr-style
unmasking r11u141 proved, order only).

### 3b. MEASURED: pass 137 (pair B) landed during this map (6ef15be0; evidence/afterp137.txt)

Pass 137 converted **113 row-modes** (surelog 63, uhdm2rtlil 50; 69 tests clear in every NE mode) and **51 probe
cases** (1866 -> 1815), none entered. Against the prediction above: pair B's optimistic set predicted 68 row-modes,
**54 of them moved**; **59 moved that the prediction did not name** (the landing took the --elabuhdm clones
N0124/N0280/N0282/N0652/N1124/N1837/N1849, N0283, N0138, N0136, N0211, N0770 (TypeParam), N0263, N0769, N1160 and
the struct-parameter path base inside N0001: 82 -> 62). Of the brief's named clusters only **N0271 (6 -> 0) and
N0412 (6 -> 0)** are gone and **N0088** fell 12 -> 4; **N0084 (8), N0096 (11), N0139 (10), N0078 (13), N0281 (8),
N0064 (14), N0041 (17), N0108 (1), N0638 (4), N0270 (2) are untouched**, and the net-binding clusters keep the
rows the law leaves (N0006 4, N0046 2, N0021 4, N0022 4, N0023 4: array_assign and the rows whose other clusters
remain).

| corpus | mode | fails today | after pass 137 (measured) | + pair A r11u140 (optimistic) |
|---|---|---|---|---|
| surelog | default | 113 | 91 | 87 |
| surelog | testflags | 132 | 91 | 87 |
| uhdm2rtlil | default | 136 | 111 | 107 |
| uhdm2rtlil | testflags | 136 | 111 | 107 |
| **corpus** | | **517 / 275 tests** | **404 / 206 tests** | **388 row-modes / 198 tests** |
| **probe** | | **1866** | **1815** | **1751** |

**The fail list after both live pairs: 388 row-modes in 198 tests + 1751 probe cases** (pass 137 measured, pair A
optimistic: 16 row-modes = ClassVar, ComplexExprSize, Kmac, ParamScope (surelog, both modes),
func_local_compound_xor, param_struct_field_bitsel, param_unpacked_struct_array, struct_dynamic_range (uhdm2rtlil,
both modes); 64 probe cases). First fields after pass 137: fullname 134, line 61, endcol 50, file 50, col 28,
endline 25, type 24, depth 14, name 12, value 4, decompile 2.

Pair A's covered clusters (named + routed residues) and what each still carries after pass 137 are in the covered
table below; its largest are N0142 (44 row-modes, 10 first; pass-133 R6), N0041 (17, shared with pair B), N0050 /
N0053 / N0054 / N0055 (15 each), N0003 (14; R2), N0060 / N0061 / N0063 (14 each).

### The covered clusters (both briefs; columns after nb / after p137 are MEASURED cluster presence)

| cluster | rows sl/u2r | tests | first in | probe | after nb | after p137 (probe) | coverage | key | site |
|---|---|---|---|---|---|---|---|---|---|
| N0142 | 44 16/28 | 23 | 10 | 4 | 44 | 44 (4) | COVERED r11u140 (residue: pass-133 R6, the unpacked-array import clone's array_typespec ra | `struct\|golden-only:fewer-copies\|range\|under:array_typespec` | makeUnpackedArrayParamTs (ParamEmit.cpp, law pkgParamTsRef) < emitParameters (ParamEmit.cpp, law importElemBar — DECODED (pass-133 R6, measured here): grew 10 -> 44 row-modes since map 4 — pass 133's law impPaLhsDisjointClone133 gives the elaborated imp |
| N0006 | 39 15/24 | 22 | 20 | 29 | 4 | 4 (3) | COVERED r11u137 (N0006, net binding: r11u139 law.patch) | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law caUnbasedFillPacke — DECODED (r11u131 R1, class A net binding): a continuous assignment whose right-hand side Surelog REDUCES to a constant (UhdmWriter writeCont |
| N0021 | 21 17/4 | 11 | 8 | 16 | 5 | 4 (0) | COVERED r11u137 (N0021, net binding: r11u139 law.patch) | `fullname\|ref_obj\|tok:id.id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124 — DECODED (r11u131 R1, class A names): port connection operands: golden binds the DEFINITION net and names the ref through the port (work@dffs |
| N0022 | 21 9/12 | 12 | 8 | 3 | 4 | 4 (1) | COVERED r11u137 (N0022, net binding: r11u139 law.patch) | `struct\|golden-only:elsewhere\|logic_net\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitEventExpr (StmtEmit.cpp, law evCtrlOperandBinds108) — DECODED (r11u131 R1, class A): the default clocking block's event binds golden's DEFINITION net; the elaborated listing calls emitScopeClock |
| N0023 | 21 9/12 | 12 | 0 | 3 | 4 | 4 (1) | COVERED r11u137 (N0023, net binding: r11u139 law.patch) | `struct\|ours-only:elsewhere\|logic_net\|under:ref_obj` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedC — DECODED (r11u131 R1, class A): the ours-side twin of N0022 (the elaborated net listed where golden lists the definition net), ModuleEmit.cpp |
| N0041 | 17 17/0 | 9 | 2 | 34 | 17 | 17 (34) | COVERED r11u140+r11u137 (N0041) | `file\|unsupported_typespec\|ours-empty\|under:ref_typespec` | emitStmt (StmtEmit.cpp, law foreachArraySelfSelectAssignDropsTs19) < emitStmt (StmtEmit.cpp, law invalidChild1 |
| N0046 | 16 8/8 | 9 | 10 | 6 | 2 | 2 (5) | COVERED r11u137 (N0046, net binding: r11u139 law.patch) | `struct\|ours-only:fewer-copies\|logic_net\|under:ref_obj` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedC — DECODED (r11u131 R1, class A mirror): a continuous-assignment RHS operand: golden binds the ELABORATED net, ours the definition net; the sam |
| N0050 | 15 15/0 | 8 | 0 | 10 | 15 | 15 (10) | COVERED r11u140 (N0050) | `span\|operation\|col+endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law connIpsPkgParamBoundNoTs65) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < e |
| N0053 | 15 11/4 | 8 | 2 | 7 | 15 | 15 (7) | COVERED r11u140 (N0053) | `span\|begin\|line+endline+endcol\|under:function` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetim |
| N0054 | 15 15/0 | 8 | 4 | 3 | 15 | 15 (3) | COVERED r11u140 (N0054) | `span\|assignment\|endcol\|under:begin` | emitStmt (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifeti |
| N0055 | 15 13/2 | 8 | 0 | 1 | 15 | 15 (1) | COVERED r11u140 (N0055) | `span\|ref_obj\|line+endline\|under:operation` | emitBadConcatOperand160 (ExprEmit.cpp, law badConcatCompoundOperands162) < emitBadConcatFromSyntax160 (ExprEmi |
| N0003 | 14 8/6 | 7 | 6 | 36 | 14 | 14 (36) | COVERED r11u140 (residue: pass-133 R2, the in-package unqualified pattern read (tools/prob | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitPackage (ParamEmit.cpp, law caPkgListingNe — DECODED: golden's ref_typespec of an assignment-pattern/cast operation carries NO VpiParent (uhdm-dump: no vpiParent line), so its synthesis |
| N0060 | 14 10/4 | 8 | 0 | 15 | 14 | 14 (15) | COVERED r11u140 (N0060) | `span\|operation\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < operator() (ExprEmit.cpp, law pkgTdCloneRefN |
| N0061 | 14 12/2 | 8 | 0 | 8 | 14 | 14 (8) | COVERED r11u140 (N0061) | `span\|bit_select\|col+endcol\|under:hier_path` | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectEras |
| N0063 | 14 2/12 | 7 | 0 | 2 | 14 | 14 (2) | COVERED r11u140 (N0063) | `fullname\|ref_typespec\|ours-empty\|under:operation` | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender |
| N0064 | 14 14/0 | 8 | 14 | 0 | 14 | 14 (0) | COVERED r11u137 (N0064) | `span\|include_file_info\|line+endline\|under:design` | emitIncludeFileInfos (UhdmExporter.cpp, law includeInactiveTabNotText141v) < exportDesign (UhdmExporter.cpp, l |
| N0078 | 13 11/2 | 7 | 4 | 2 | 13 | 13 (2) | COVERED r11u137 (N0078) | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law qualSelBaseNoWhitespace41) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSel |
| N0077 | 13 9/4 | 7 | 2 | 0 | 13 | 13 (0) | COVERED r11u140 (residue: emitMixedHierPath residue, r11v133 F4 (tools/probe/r11v133repro/ | `fullname\|ref_obj\|tok:id.id[id].->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emi — emitMixedHierPath residue r11v133 F4 (measured here): tools/probe/r11v133repro/tix a02_gen_for and f06_gen_if read N0968 + N0061 + N0077 |
| N0088 | 12 10/2 | 6 | 6 | 19 | 12 | 4 (4) | COVERED r11u137 (N0088) | `span\|ref_obj\|line+col+endline+endcol\|under:port` | emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInterfaceDef (ModuleEmit.cpp, law modportExprPort) < |
| N0096 | 11 11/0 | 6 | 2 | 21 | 11 | 11 (21) | COVERED r11u137 (N0096) | `fullname\|ref_typespec\|tok:id::->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp,  |
| N0079 | 11 9/2 | 6 | 0 | 1 | 11 | 11 (1) | COVERED r11u140 (N0079) | `span\|constant\|line+endline\|under:operation` | emitBadConcatOperand160 (ExprEmit.cpp, law typeParamScopedCallRef59) < emitBadConcatFromSyntax160 (ExprEmit.cp |
| N0139 | 10 2/8 | 5 | 10 | 1 | 10 | 10 (1) | COVERED r11u137 (N0139) | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonA |
| N0052 | 9 9/0 | 5 | 0 | 3 | 9 | 9 (3) | COVERED r11u140 (N0052) | `fullname\|ref_obj\|tok:id.id[id]::->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNamesByPath133 |
| N0212 | 9 9/0 | 5 | 2 | 0 | 9 | 9 (0) | COVERED r11u140 (N0212) | `span\|operation\|line+col+endline+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law argWrittenQualIsSyntax |
| N2379 | 9 9/0 | 5 | 0 | 0 | 9 | 9 (0) | COVERED r11u140 (residue: emitMixedHierPath residue: the pass-133 trailing-select index na | `fullname\|ref_obj\|tok:id.id::id::->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNamesByPath133 |
| N2380 | 9 9/0 | 5 | 0 | 0 | 9 | 9 (0) | COVERED r11u140 (residue: emitMixedHierPath residue: as N2379 (hpTrailSelIdxNamesByPath133 | `fullname\|ref_obj\|tok:id.id.id::->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNamesByPath133 |
| N0245 | 9 9/0 | 5 | 2 | 0 | 9 | 9 (0) | COVERED r11u140 (N0245) | `span\|operation\|endcol\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law connIpsPkgParamBoundNoTs65) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) <  |
| N0084 | 8 6/2 | 4 | 0 | 50 | 8 | 8 (50) | COVERED r11u137 (N0084) | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPacke |
| N0272 | 8 6/2 | 5 | 4 | 1 | 1 | 0 (0) | COVERED r11u140 (N0272) | `fullname\|bit_select\|tok:id.id.->\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emi — SHARED with net binding (measured here): on BitsArray (both modes) and AssignBitsCallToSubmoduleParameter (both modes) N0272 is the only clu |
| N0281 | 8 2/6 | 4 | 6 | 0 | 8 | 8 (0) | COVERED r11u137 (N0281) | `fullname\|ref_obj\|tok:id.->@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect |
| N0151 | 7 7/0 | 4 | 0 | 84 | 7 | 7 (84) | COVERED r11u140 (N0151) | `struct\|golden-only:fewer-copies\|ref_typespec\|under:parameter` | importParamCopy82 (ModuleEmit.cpp, law impOcc) < classInheritsContainerImports23 (ModuleEmit.cpp, law classImp |
| N0284 | 7 3/4 | 4 | 0 | 49 | 7 | 7 (49) | COVERED r11u140 (N0284) | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgUnvaluedActualLitRetFold8) < emitInstance (ModuleEmit.cpp, law elabPo |
| N0357 | 7 5/2 | 4 | 2 | 0 | 7 | 7 (0) | COVERED r11u140 (N0357) | `fullname\|ref_obj\|tok:id.id[id - n:n].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124 |
| N0412 | 6 2/4 | 3 | 6 | 6 | 6 | 0 (1) | COVERED r11u137 (N0412) | `span\|func_call\|endcol\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law pkgParamOwnDefRange) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < |
| N0427 | 6 6/0 | 4 | 1 | 0 | 6 | 5 (0) | COVERED r11u140 (N0427) | `fullname\|ref_obj\|tok:id[id].id.->\|under:bit_select` | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp, law genCaParamFoldOneHopPool95) < emitGenScopes (ModuleE |
| N0271 | 6 6/0 | 3 | 6 | 0 | 6 | 0 (0) | COVERED r11u137 (N0271) | `fullname\|ref_typespec\|tok:id@id.->\|under:packed_array_typespec` | emitTypedefs (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52) < emitModuleDef (ModuleEmit.cpp, law endBlockL |
| N0451 | 5 1/4 | 3 | 0 | 2 | 5 | 5 (2) | COVERED r11u140 (residue: pass-133 R6, the same clone's element ref_typespec name (lhs/l04 | `fullname\|ref_typespec\|tok:->.id\|under:array_typespec` | makeUnpackedArrayParamTs (ParamEmit.cpp, law pkgParamTsRef) < operator() (ParamEmit.cpp, law importElemBareTdA |
| N0523 | 4 4/0 | 4 | 2 | 2 | 4 | 1 (2) | COVERED r11u140 (N0523) | `fullname\|ref_obj\|tok:id.id->id\|under:hier_path` | emitExpr (ExprEmit.cpp) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emitExpr (ExprEmit.cpp, law  |
| N0638 | 4 0/4 | 2 | 0 | 0 | 4 | 4 (0) | COVERED r11u137 (N0638) | `fullname\|ref_typespec\|tok:id@id.id.id.->\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45 |
| N0394 | 4 2/2 | 2 | 2 | 0 | 4 | 4 (0) | COVERED r11u140 (N0394) | `file\|constant\|ours-empty\|under:operation` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < emitContAssigns (ModuleEmit.cpp, law caIfaceElabN — DECODED (this map, uhdm2rtlil/ParameterWithUnderscoreValueDividedPassedFromCommandLine `localparam int C = A / B;`): an operand of an elabor |
| N0413 | 2 2/0 | 1 | 0 | 4 | 2 | 2 (4) | COVERED r11u140 (N0413) | `span\|operation\|line+col+endline+endcol\|under:param_assign` | emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < emitInstance (ModuleEmit.cpp, law elabParamT |
| N0261 | 2 0/2 | 1 | 0 | 0 | 2 | 2 (0) | COVERED r11u140 (N0261) | `struct\|golden-only:fewer-copies\|ref_typespec\|under:constant` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law namedTfArgsFormalSlots4 |
| N0270 | 2 0/2 | 1 | 0 | 0 | 2 | 2 (0) | COVERED r11u137 (N0270) | `span\|struct_typespec\|endline+endcol\|under:design` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < exportDesign (UhdmExporter.cpp, law unitImportHo — DECODED (this map, uhdm2rtlil/unpacked_struct_mixed): golden's $unit typedef c_t spans 1:9-16:29, its end is the LAST net declarator's unpac |
| N0108 | 1 1/0 | 1 | 0 | 7 | 1 | 1 (7) | COVERED r11u137 (N0108) | `fullname\|ref_typespec\|tok:id@id.id.id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPacke |
| N0058 | 0 0/0 | 0 | 0 | 1 | 0 | 0 (1) | COVERED r11u140 (N0058) | `span\|operation\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPacka |

## 4. Ranked OPEN clusters with sites

Rows = corpus row-modes at a7bee711 (surelog/uhdm2rtlil); first in = row-modes whose FIRST differing object is in
the cluster; after nb / after p137 = row-modes still carrying the cluster in the MEASURED cross-sections; alone
(p137) = row-modes it clears ALONE on top of pass 137 (measured) and pair A (optimistic); ground = the owner of the
fix: the pinned mint's file, overridden where a pass decoded the fix site elsewhere (evidence/ground_override.json:
N0030/N0136 elaborated-process naming and N0015/N0017/N0026/N0027/N0029 the macro line model -> B; N0012/N0034 the
type-parameter enum override -> A; N0008/N0047/N0138 -> B). Site = the PINNED mint (function (file, nearest law) <
caller < caller) with the decoded note where one exists. Full list: `cluster_index.csv` (every cluster: rank, rows
per corpus, probe cases, alone yield, first-in rows, coverage, map-4 coverage, r11u128 id, site, probe laws, key,
example, the after-nb and after-p137 columns, ground); one record-window file per cluster with >= 4 row-modes or in
the pin set in evidence/clusters/ (748 files); one example object per cluster in evidence/objects.csv (2142).

| rank | cluster | rows sl/u2r | tests | first in | probe | after nb | after p137 | alone (p137) | ground | coverage | key | example | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0001 | 82 36/46 | 42 | 30 | 78 | 82 | 62 | 4 | A | OPEN (residue of r11u133: map 4 named it, still  | `span\|ref_obj\|col+endcol\|under:hier_path` | surelog/testflags/ComplexHierPath #30/30 ref_obj 'B' golden=11:58:11:59 ours=11:56:11:57 | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSub — NOTE: r11u131 R2 pinned one shape of this cluster (the base ref of a struct-parameter member path in a constant context, located at the MEMB |
| 2 | N0005 | 44 18/26 | 22 | 8 | 163 | 44 | 44 | 4 | A | OPEN (residue of r11u133: map 4 named it, still  | `span\|constant\|endcol\|under:param_assign` | surelog/testflags/GenForIfaceLocalparamBound #165/165 constant '' golden=10:33:10:36 ours= | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsP |
| 5 | N0007 | 34 24/10 | 18 | 0 | 28 | 34 | 34 | 0 | A | OPEN (residue of r11u133: map 4 named it, still  | `fullname\|ref_obj\|golden-empty\|under:hier_path` | surelog/testflags/ComplexHierPath #31/31 ref_obj 'x' golden= ours=work@genblk_dive_top.Z.A | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubro |
| 6 | N0010 | 30 10/20 | 15 | 2 | 4 | 30 | 30 | 0 | A | OPEN (map 4 routed it to r11u133 as a residue of | `span\|constant\|col+endcol\|under:param_assign` | surelog/testflags/HierPathStructTypespec #182/182 constant '' golden=10:34:10:64 ours=10:3 | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTargetKinds) < emitParameters (ParamEmit.cpp,  |
| 7 | N0008 | 29 5/24 | 15 | 20 | 25 | 29 | 29 | 2 | B | OPEN (residue of r11u133: map 4 named it, still  | `fullname\|ref_typespec\|golden-empty\|under:constant` | uhdm2rtlil/testflags/LocalParamInNestedForLoops #70/70 ref_typespec '' golden= ours=work@t | operator() (ModuleEmit.cpp, law genLpFoldDigitsMathValue18) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) < operator() (ModuleEmit.cpp — DECODED: the same as N0003 on a constant's typespec ref: golden unparented |
| 8 | N0015 | 27 7/20 | 14 | 0 | 1 | 27 | 27 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|constant\|line+col+endline+endcol\|under:sys_func_call` | uhdm2rtlil/testflags/ibex_csr #56/56 constant '' golden=29:60:29:144 ours=32:92:33:53 | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineColla — DECODED (r11u131 R7): macro-argument spans (ibex prim_assert $error/$time lines): the multi-line macro line model, UhdmExporter.cpp locLineC |
| 9 | N0017 | 26 6/20 | 13 | 0 | 5 | 26 | 26 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|constant\|endline+endcol\|under:sys_func_call` | surelog/testflags/CovMacro #103/103 constant '' golden=12:31:12:32 ours=12:31:0:0 | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineColla — DECODED (r11u131 R7): CovMacro's predefined SV_COV_* constants end at 0:0; the macro line model, UhdmExporter.cpp locLineCol |
| 10 | N0018 | 25 21/4 | 13 | 0 | 18 | 25 | 25 | 0 | A | OPEN (map 4 routed it to r11u133 as a residue of | `fullname\|ref_obj\|ours-empty\|under:hier_path` | surelog/testflags/LocalScopeHierPath #82/82 ref_obj 'path' golden=pack::uvm_mem_mam::check | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNa |
| 11 | N0012 | 23 11/12 | 12 | 14 | 5 | 23 | 23 | 0 | A | OPEN (map 4 routed it to r11u133 as a residue of | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | uhdm2rtlil/testflags/TypeParameterAsPortTypeWithEnumOfParametrizedWidth #62/62 enum_typesp | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInstance (ModuleEmit.cpp, law — DECODED (r11u130 R1): the type-parameter override by a module-local enum typedef; ParamEmit.cpp emitParameters after law typeParamChainBorro |
| 15 | N0026 | 20 0/20 | 10 | 0 | 10 | 20 | 20 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|constant\|line+endline\|under:sys_func_call` | uhdm2rtlil/testflags/ibex_csr #54/54 constant '' golden=29:10:29:51 ours=32:10:32:51 | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineColla — DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol |
| 16 | N0027 | 20 0/20 | 10 | 4 | 8 | 20 | 20 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|sys_func_call\|line+endcol\|under:begin` | uhdm2rtlil/testflags/ibex_csr #53/53 sys_func_call '$error' golden=29:3:33:27 ours=32:3:33 | emitExpr (ExprEmit.cpp, law sysCallKwTypeArgNameSpan131) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) < emitStmt (StmtEmit.c — DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol |
| 17 | N0029 | 20 0/20 | 10 | 0 | 0 | 20 | 20 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|sys_func_call\|line+endline\|under:sys_func_call` | uhdm2rtlil/testflags/ibex_csr #55/55 sys_func_call '$time' golden=29:53:29:58 ours=32:53:3 | emitExpr (ExprEmit.cpp, law sysCallKwTypeArgNameSpan131) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSu — DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol |
| 18 | N0030 | 19 11/8 | 11 | 7 | 58 | 19 | 18 | 7 | B | OPEN (map 4 routed it to r11u134 as a residue of | `fullname\|ref_obj\|tok:id.->\|under:operation` | surelog/testflags/EmptyAssign #72/72 ref_obj 'b' golden=work@top.dut.b ours=work@dut.b | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law genLpUse — DECODED (r11u131 R10): the elaborated process / continuous assignment named by the definition (work@dut.b for work@top.dut.b): shared def-vi |
| 19 | N0024 | 18 10/8 | 9 | 6 | 37 | 18 | 18 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec` | uhdm2rtlil/testflags/cva6_struct_param_field #126/-1 struct_typespec 'cfg_pkg::cfg_t' gold | emitModuleDef (ModuleEmit.cpp, law ifaceDefNetTypespecIsTheModuleRule224) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < m — NOTE (r11u131 R6): the tagged-pattern key's cast typespec (golden struct, ours integer_typespec); not decoded |
| 20 | N0009 | 18 10/8 | 9 | 6 | 16 | 18 | 18 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | surelog/testflags/TypeParamElab #129/129 struct_typespec 'axi_meta_t' golden=27:11:30:4 ou | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit — DECODED (r11u130 R2): struct typespec spans taken at the use (one shared object where golden holds a copy per use) |
| 21 | N0036 | 18 14/4 | 10 | 0 | 7 | 18 | 18 | 0 | A | OPEN (residue of r11u133: map 4 named it, still  | `span\|bit_select\|col+endcol\|under:operation` | uhdm2rtlil/testflags/latch_packed_dyn_write #194/194 bit_select 'bit_i' golden=47:32:47:33 | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitMixedHierPath (ExprEmit.cpp, law hpM |
| 23 | N0033 | 17 5/12 | 9 | 0 | 11 | 17 | 17 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `struct\|ours-only:fewer-copies\|operation\|under:range` | uhdm2rtlil/testflags/cfg_func_width_loop #-1/382 operation '' golden= ours=2 objs | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) < makeTypespec (TypeEmit.cpp, law typ — DECODED (r11u130 R5): as N0025 |
| 24 | N0025 | 17 5/12 | 9 | 0 | 11 | 17 | 17 | 0 | B | OPEN (map 4 routed it to r11u134 as a residue of | `depth\|constant\|range->operation` | uhdm2rtlil/testflags/cfg_func_width_loop #382/384 constant '' golden=8 range < logic_types | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarR — DECODED (r11u130 R5): TypedefWithParameter: our net typespec carries a Typedef_alias clone golden lacks (class B), so the walk diverges befo |
| 25 | N0039 | 16 16/0 | 9 | 2 | 222 | 16 | 14 | 2 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | surelog/testflags/TypeParam #26/26 int_typespec '' golden=17:85:17:88 ours=20:5:20:8 | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExpor — DECODED (r11u130 R3 + K0070): the int_typespec declaration-vs-use span; its corpus head TypeParam is the type-parameter definition net (mate |
| 26 | N0014 | 16 8/8 | 8 | 2 | 18 | 16 | 16 | 0 | B | OPEN (residue of r11u134: map 4 named it, still  | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | uhdm2rtlil/testflags/gen_scope_typaram #148/148 ref_typespec '' golden=pair_t.x ours=x | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypespec (TypeEmit.c |
| 27 | N0045 | 16 8/8 | 8 | 2 | 12 | 16 | 16 | 0 | B | OPEN (residue of r11u134: map 4 named it, still  | `struct\|golden-only:fewer-copies\|constant\|under:typespec_member` | surelog/default/StructParamPatternInitCast #77/-1 constant '' golden=1 objs ours= | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < main (uhdm_ma — DECODED: golden lists the member default constant twice (a copy under typespec_member); ours shares one object. HOLDER pinned |
| 29 | N0043 | 16 10/6 | 9 | 4 | 5 | 16 | 16 | 2 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | uhdm2rtlil/testflags/const_cast_signext #4/4 struct_typespec 'op_t' golden=19:42:19:46 our | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit — DECODED (r11u130 R2): as N0009 |
| 30 | N0031 | 15 9/6 | 8 | 0 | 16 | 15 | 15 | 0 | B | OPEN (residue of r11u134: map 4 named it, still  | `file\|constant\|ours-empty\|under:range` | uhdm2rtlil/testflags/ParameterFromPkgInNestedModule #170/170 constant '' golden=dut.sv 2:2 | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < |
| 32 | N0051 | 15 15/0 | 8 | 2 | 9 | 15 | 15 | 0 | B | OPEN | `span\|class_typespec\|endcol\|under:ref_typespec` | surelog/testflags/ClassParamAsParam #8/8 class_typespec 'object' golden=18:14:18:20 ours=1 | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter.cpp, law typedefAliasSharesTypespec25)  |
| 36 | N0056 | 15 13/2 | 8 | 6 | 1 | 15 | 15 | 2 | A | OPEN | `span\|bit_typespec\|endcol\|under:ref_typespec` | surelog/testflags/GenCase #5/5 bit_typespec '' golden=6:13:6:16 ours=6:13:6:25 | makeParamTs (ParamEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law pkgParamTsRefColons131) < exportDesign (UhdmExporter.cpp, law imp |
| 37 | N0044 | 14 6/8 | 7 | 10 | 73 | 14 | 14 | 2 | B | OPEN (map 4 routed it to r11u134 as a residue of | `span\|struct_typespec\|endcol\|under:ref_typespec` | uhdm2rtlil/testflags/gen_scope_typaram #146/146 struct_typespec 'pair_t' golden=17:13:17:6 | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitTopPorts (ModuleEmit. — DECODED (r11u130 R2): as N0009 |
| 39 | N0059 | 14 6/8 | 7 | 0 | 33 | 14 | 14 | 0 | A | OPEN (map 4 routed it to r11u133 as a residue of | `struct\|ours-only:absent\|integer_typespec\|under:ref_typespec` | uhdm2rtlil/testflags/cva6_struct_param_field #-1/126 integer_typespec '' golden= ours=4 ob | emitExpr (ExprEmit.cpp, law castTgtDefaultIsLiteral) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubrout — NOTE (r11u131 R6): the ours-side twin of N0024 (integer_typespec golden lacks) |
| 42 | N0028 | 14 4/10 | 7 | 0 | 2 | 14 | 14 | 0 | B | OPEN (residue of r11u134: map 4 named it, still  | `fullname\|ref_typespec\|tok:->id.\|under:typespec_member` | surelog/testflags/FENCED_1 #102/100 ref_typespec '' golden=work@top.pinmux_pkg::target_cfg | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < patchParamTypespec |
| 45 | N0057 | 14 4/10 | 7 | 0 | 0 | 14 | 14 | 0 | B | OPEN | `struct\|golden-only:fewer-copies\|ref_typespec\|under:enum_typespec` | surelog/testflags/PackedEnumPort #49/-1 ref_typespec '' golden=8 objs ours= | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp, law importCopyAggFormalOwnCopy32) < exportDesign (UhdmExporter.cpp |
| 46 | N0067 | 13 13/0 | 7 | 0 | 47 | 13 | 13 | 0 | B | OPEN | `file\|class_typespec\|ours-empty\|under:ref_typespec` | surelog/testflags/ApbSlave #713/717 class_typespec 'svunit_testsuite' golden=svunit_testru | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPropIsArrayVar6) < emitPackageClasses (Uhdm |
| 47 | N0068 | 13 13/0 | 7 | 0 | 47 | 13 | 13 | 0 | B | OPEN | `span\|class_typespec\|ours-zero\|under:ref_typespec` | surelog/testflags/ApbSlave #713/717 class_typespec 'svunit_testsuite' golden=32:9:32:25 ou | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPropIsArrayVar6) < emitPackageClasses (Uhdm |
| 48 | N0069 | 13 13/0 | 7 | 0 | 25 | 13 | 13 | 0 | B | OPEN | `span\|string_typespec\|line+col+endline+endcol\|under:ref_typespec` | surelog/testflags/ClassTypeParam #32/32 string_typespec '' golden=26:30:26:36 ours=20:36:2 | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < sharedTypespec (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTaskFuncs (Ta |
| 49 | N0070 | 13 13/0 | 7 | 1 | 17 | 13 | 13 | 0 | B | OPEN | `span\|function\|endline+endcol\|under:class_defn` | surelog/testflags/ClassTypeParam #80/80 function 'check_all_sva_passed' golden=11:2:11:9 o | emitTaskFuncs (TaskFuncEmit.cpp, law dpiExportListedAtExportItem216) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackag |
| 50 | N0071 | 13 13/0 | 7 | 0 | 17 | 13 | 13 | 0 | A | OPEN | `span\|hier_path\|endcol\|under:operation` | surelog/default/SimpleConstraint #212/212 hier_path 'frame.randomize' golden=57:12:57:29 o | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNa |
| 51 | N0072 | 13 13/0 | 7 | 0 | 16 | 13 | 13 | 0 | B | OPEN | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | surelog/testflags/ArrayMethodIterator #17/17 class_typespec 'uvm_callback' golden=10:50:10 | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExporter.c |
| 52 | N0042 | 13 9/4 | 7 | 0 | 13 | 13 | 13 | 0 | B | OPEN (residue of r11u134: map 4 named it, still  | `span\|constant\|ours-zero\|under:range` | uhdm2rtlil/testflags/ParameterFromPkgInNestedModule #170/170 constant '' golden=2:21:2:22  | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < |
| 53 | N0075 | 13 13/0 | 7 | 2 | 8 | 13 | 13 | 0 | B | OPEN | `span\|enum_typespec\|line+col+endline+endcol\|under:package` | surelog/testflags/FuncCase #2/2 enum_typespec 'fpnew_pkg::opgroup_e' golden=7:46:7:55 ours | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 54 | N0076 | 13 7/6 | 7 | 7 | 5 | 13 | 13 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.->\|under:part_select` | uhdm2rtlil/testflags/comb_dyn_2d_packed_sel #240/240 ref_obj 'ALIGN' golden=work@dut.wr_of | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < operator() (ModuleEmit.cpp, law genCaT |
| 55 | N0034 | 13 9/4 | 7 | 0 | 5 | 13 | 13 | 0 | A | OPEN (map 4 routed it to r11u133 as a residue of | `span\|enum_typespec\|ours-zero\|under:ref_typespec` | uhdm2rtlil/testflags/TypeParameterAsPortTypeWithEnumOfParametrizedWidth #62/62 enum_typesp | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInstance (ModuleEmit.cpp, law — DECODED (r11u130 R1): the span face of N0012, same site |
| 57 | N0080 | 13 13/0 | 7 | 2 | 1 | 13 | 13 | 0 | B | OPEN | `span\|struct_typespec\|line+col+endline+endcol\|under:package` | surelog/default/FuncStructValSimple #298/298 struct_typespec 'config_pkg::cva6_user_cfg_t' | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.c |
| 58 | N0081 | 13 13/0 | 7 | 2 | 0 | 13 | 13 | 0 | B | OPEN | `span\|ref_obj\|line+col+endline+endcol\|under:operation` | surelog/testflags/PortExpr #7/7 ref_obj 'op[79]' golden=2:9:2:21 ours=4:11:5:3 | emitPortExprPort (ModuleEmit.cpp, law importedPkgVecPortClone) < emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitModuleDefPorts (ModuleEmit. |
| 60 | N0083 | 12 2/10 | 6 | 0 | 63 | 12 | 12 | 0 | B | OPEN | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec` | surelog/testflags/LogicTypespec #15/-1 range '' golden=3 objs ours= | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |
| 61 | N0086 | 12 4/8 | 6 | 2 | 20 | 12 | 12 | 0 | A | OPEN | `file\|constant\|golden-empty\|under:typespec_member` | uhdm2rtlil/testflags/struct_param_field_shift #75/75 constant '' golden= 0:0:0:0 ours=dut. | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitPackage  |
| 62 | N0087 | 12 4/8 | 6 | 0 | 20 | 12 | 12 | 0 | A | OPEN | `span\|constant\|golden-zero\|under:typespec_member` | uhdm2rtlil/testflags/struct_param_field_shift #75/75 constant '' golden=0:0:0:0 ours=20:33 | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitPackage  |
| 64 | N0089 | 12 12/0 | 12 | 1 | 10 | 12 | 1 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id->id\|under:operation` | surelog/testflags/FuncRetArray #137/137 ref_obj 'i' golden=work@main.top1.ASSIGN_VADDR.i o | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law memberActualLeak) < emitContAssigns (ModuleEmit.cpp, law elabCaTern |
| 65 | N0091 | 12 10/2 | 6 | 0 | 1 | 12 | 12 | 0 | A | OPEN | `span\|ref_obj\|col+endcol\|under:operation` | surelog/testflags/MacroArgMismatch #16/16 ref_obj 'd' golden=5:14:5:15 ours=5:15:5:16 | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBa |
| 66 | N0092 | 12 2/10 | 6 | 2 | 0 | 12 | 12 | 0 | B | OPEN | `value\|constant\|value:UINT->UINT\|under:range` | surelog/default/UnionCast #179/179 constant '' golden=00/64/UINT:00/9 ours=00/64/UINT:0/9 | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabSize113) < buildStructTs (TypeEmit.cpp, l |
| 67 | N0065 | 12 8/4 | 6 | 0 | 0 | 12 | 6 | 0 | B | OPEN | `depth\|typespec_member\|struct_typespec->struct_typespec` | surelog/testflags/TypedefUnpacked #37/30 typespec_member 'x' golden=9 struct_typespec(pkg: | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExpo |
| 68 | N0066 | 12 8/4 | 6 | 0 | 0 | 12 | 6 | 0 | B | OPEN | `depth\|ref_typespec\|typespec_member->typespec_member` | surelog/testflags/TypedefUnpacked #38/31 ref_typespec '' golden=10 typespec_member(x) < st | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmE |
| 69 | N0082 | 12 8/4 | 6 | 0 | 0 | 12 | 6 | 0 | B | OPEN | `depth\|struct_typespec\|ref_typespec->ref_typespec` | surelog/testflags/TypedefUnpacked #36/29 struct_typespec 'pkg::a' golden=8 ref_typespec <  | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.c |

### The first clusters (what the gate names first on each failing row)

| first cluster | row-modes it heads | after nb | after p137 | coverage | key | site |
|---|---|---|---|---|---|---|
| N0001 | 30 | 30 | 20 | OPEN (residue of r11u133: map 4 named it, still present) | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt ( — NOTE: r11u131 R2 pinned one shape of this cluster (the base ref of a struct-parameter member path in a constant context, located at the MEMB |
| N0006 | 20 | 0 | 0 | COVERED r11u137 (N0006, net binding: r11u139 law.patch) | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law caUnbasedFillPackedAggregate — DECODED (r11u131 R1, class A net binding): a continuous assignment whose right-hand side Surelog REDUCES to a constant (UhdmWriter writeCont |
| N0008 | 20 | 20 | 20 | OPEN (residue of r11u133: map 4 named it, still present) | `fullname\|ref_typespec\|golden-empty\|under:constant` | operator() (ModuleEmit.cpp, law genLpFoldDigitsMathValue18) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48 — DECODED: the same as N0003 on a constant's typespec ref: golden unparented |
| N0064 | 14 | 14 | 14 | COVERED r11u137 (N0064) | `span\|include_file_info\|line+endline\|under:design` | emitIncludeFileInfos (UhdmExporter.cpp, law includeInactiveTabNotText141v) < exportDesign (UhdmExporter.cpp, law dottedT |
| N0012 | 14 | 14 | 14 | OPEN (map 4 routed it to r11u133 as a residue of r11u130; no | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emi — DECODED (r11u130 R1): the type-parameter override by a module-local enum typedef; ParamEmit.cpp emitParameters after law typeParamChainBorro |
| N0139 | 10 | 10 | 10 | COVERED r11u137 (N0139) | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsN |
| N0142 | 10 | 10 | 10 | COVERED r11u140 (residue: pass-133 R6, the unpacked-array im | `struct\|golden-only:fewer-copies\|range\|under:array_typespec` | makeUnpackedArrayParamTs (ParamEmit.cpp, law pkgParamTsRef) < emitParameters (ParamEmit.cpp, law importElemBareTdAlias)  — DECODED (pass-133 R6, measured here): grew 10 -> 44 row-modes since map 4 — pass 133's law impPaLhsDisjointClone133 gives the elaborated imp |
| N0046 | 10 | 2 | 2 | COVERED r11u137 (N0046, net binding: r11u139 law.patch) | `struct\|ours-only:fewer-copies\|logic_net\|under:ref_obj` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRide — DECODED (r11u131 R1, class A mirror): a continuous-assignment RHS operand: golden binds the ELABORATED net, ours the definition net; the sam |
| N0044 | 10 | 10 | 10 | OPEN (map 4 routed it to r11u134 as a residue of r11u130; no | `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword13 — DECODED (r11u130 R2): as N0009 |
| N0005 | 8 | 8 | 8 | OPEN (residue of r11u133: map 4 named it, still present) | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.c |
| N0283 | 8 | 8 | 0 | OPEN | `file\|struct_typespec\|ours-empty\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v)  |
| N0021 | 8 | 0 | 0 | COVERED r11u137 (N0021, net binding: r11u139 law.patch) | `fullname\|ref_obj\|tok:id.id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitIn — DECODED (r11u131 R1, class A names): port connection operands: golden binds the DEFINITION net and names the ref through the port (work@dffs |
| N0149 | 8 | 8 | 8 | OPEN | `file\|struct_typespec\|other-file\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) < exportDesign (UhdmEx |
| N0022 | 8 | 0 | 0 | COVERED r11u137 (N0022, net binding: r11u139 law.patch) | `struct\|golden-only:elsewhere\|logic_net\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitEventExpr (StmtEmit.cpp, law evCtrlOperandBinds108) < emitSco — DECODED (r11u131 R1, class A): the default clocking block's event binds golden's DEFINITION net; the elaborated listing calls emitScopeClock |
| N0076 | 7 | 7 | 7 | OPEN | `fullname\|ref_obj\|tok:id.->\|under:part_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < operator |
| N0030 | 7 | 7 | 7 | OPEN (map 4 routed it to r11u134 as a residue of r11u131; no | `fullname\|ref_obj\|tok:id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitEx — DECODED (r11u131 R10): the elaborated process / continuous assignment named by the definition (work@dut.b for work@top.dut.b): shared def-vi |
| N0088 | 6 | 6 | 2 | COVERED r11u137 (N0088) | `span\|ref_obj\|line+col+endline+endcol\|under:port` | emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInterfaceDef (ModuleEmit.cpp, law modportExprPort) < exportDes |
| N0441 | 6 | 6 | 6 | OPEN (residue of r11u133: map 4 named it, still present) | `struct\|ours-only:fewer-copies\|constant\|under:array_expr` | emitParameters (ParamEmit.cpp, law patOpMemberAsmSplit28) < emitInstance (ModuleEmit.cpp, law elabParamTsRebind) < expor — DECODED: ours lists two constants where golden shares one (array_expr default pattern) |
| N0056 | 6 | 6 | 6 | OPEN | `span\|bit_typespec\|endcol\|under:ref_typespec` | makeParamTs (ParamEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law pkgParamTsRefColons131) < exportDes |
| N0433 | 6 | 6 | 6 | OPEN | `file\|packed_array_typespec\|golden-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < buildUnionTs (TypeEmit.cpp, law pkgTdRangeViewFold18) <  |
| N0271 | 6 | 6 | 0 | COVERED r11u137 (N0271) | `fullname\|ref_typespec\|tok:id@id.->\|under:packed_array_typespec` | emitTypedefs (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52) < emitModuleDef (ModuleEmit.cpp, law endBlockLabelAllOwn |
| N0138 | 6 | 6 | 0 | OPEN (residue of r11u133: map 4 named it, still present) | `fullname\|ref_typespec\|tok:id.->\|under:constant` | emitInstance (ModuleEmit.cpp, law patFlatUnsizedMemberWidth61) < emitInstance (ModuleEmit.cpp, law bindIfaceTwinInParent — NOTE: r11u131 R3: a port connection written as a replication folds to a constant whose ref_typespec golden names through <instance>.<port>;  |
| N0003 | 6 | 6 | 6 | COVERED r11u140 (residue: pass-133 R2, the in-package unqual | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPer — DECODED: golden's ref_typespec of an assignment-pattern/cast operation carries NO VpiParent (uhdm-dump: no vpiParent line), so its synthesis |
| N0412 | 6 | 6 | 0 | COVERED r11u137 (N0412) | `span\|func_call\|endcol\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law pkgParamOwnDefRange) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator( |
| N0009 | 6 | 6 | 8 | OPEN (map 4 routed it to r11u134 as a residue of r11u130; no | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword13 — DECODED (r11u130 R2): struct typespec spans taken at the use (one shared object where golden holds a copy per use) |
| N0090 | 6 | 6 | 6 | OPEN | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, law typePara |
| N0281 | 6 | 6 | 6 | COVERED r11u137 (N0281) | `fullname\|ref_obj\|tok:id.->@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operat |
| N0133 | 6 | 6 | 6 | OPEN (residue of r11u133: map 4 named it, still present) | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs10 — DECODED: SHARING: ours's elaborated cont_assign Rhs func_call is the definition's object (listed once); golden holds a copy (r11u128map's 'f |
| N0024 | 6 | 6 | 6 | OPEN (map 4 routed it to r11u134 as a residue of r11u131; no | `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec` | emitModuleDef (ModuleEmit.cpp, law ifaceDefNetTypespecIsTheModuleRule224) < exportDesign (UhdmExporter.cpp, law imported — NOTE (r11u131 R6): the tagged-pattern key's cast typespec (golden struct, ours integer_typespec); not decoded |
| N0455 | 5 | 5 | 5 | OPEN | `span\|assignment\|line+col+endline+endcol\|under:initial` | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172)  |
distinct first clusters: 141

The new clusters since map 4 (N2379-N2382): N2379 / N2380 (`fullname|ref_obj|tok:id.id::id::->|under:bit_select`
and `tok:id.id.id::->`, 9 row-modes each, the UVM family: BuildUVMPkg, MiniAmiq, Scoreboard, SeqDriver, SimpleUVM)
are the pass-133 trailing-select index names in class-method bodies (golden `...::m_set_reg_offset::top_map.
m_regs_by_offset::...`, ours `...::info.addr[i]::i`; mint emitExpr with law hpTrailSelIdxNamesByPath133 frames),
routed to pair A as emitMixedHierPath residues; N2381 (BuildUVMPkg both modes, a method_func_call receiver name,
mint emitExpr beside law emptyArgSlotIntZero24) and N2382 (Earlgrey_0_1/testflags only, a typespec_member ref name
through `flash_ctrl_reg_pkg`, mint buildStructTs) are the small ones.


## 5. The structural rows (first field depth / type / count) after passes 133/134 and the net-binding decode

At a7bee711: **76 row-modes in 40 tests** (depth 41, type 26, count 9; evidence/structural.txt, by first cluster
with map 4's classes). **After the nb binary (a7bee711 + r11u139's law.patch, measured): 40 row-modes in 20 tests**
(evidence/afternb.txt); **after pass 137 (measured): 38 row-modes in 19 tests** (evidence/afterp137.txt).
The law.patch applies clean at a7bee711 (`git apply --check`: offsets only).

| class | at a7bee711 | after nb (measured) | after p137 (measured) | first cluster | what differs | coverage |
|---|---|---|---|---|---|---|
| A. NET-BINDING | 38 (21 tests) | 2 (array_assign d/t) | 2 (array_assign d/t) | N0006, N0046, N0022, N0021 | which net `ref_obj.Actual` names | r11u139 law (pass 137): 36 of 38 cleared; **array_assign** stays `depth(1)` N0046 (an operation onto an unpacked array net: golden keeps the definition net, r11u139 residue) |
| C3. IMPORT-CLONE ARRAY TYPESPEC | 10 (5) | 10 | 10 | N0142 | golden's elaborated import clone lists an `array_typespec` range (+ element ref) ours lacks: grew 10 -> 44 row-modes when pass 133 gave the clone its own copy | pair A (pass-133 R6), ParamEmit.cpp makeUnpackedArrayParamTs |
| C2. CONSTANT COPIED | 6 (3) | 6 | 6 | N0441 | array_expr default pattern: ours two constants, golden one shared (DefaultPatternInt, DefaultPatternModule, ParamArrayUnsizedPattern) | OPEN (map-4 pair-A residue), ParamEmit.cpp emitParameters |
| D. MEMBER-DEFAULT COPY | 2 (1) | 2 | 2 | N0045 | golden lists the member default constant under typespec_member (StructParamFuncBodyFieldCompare) | OPEN (pass-134 R3), TypeEmit.cpp buildStructTs |
| D2. CAST TARGET | 6 (3) | 6 | 6 | N0024 | tagged-pattern key's cast typespec: golden struct, ours integer (def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot) | OPEN, ModuleEmit.cpp emitModuleDef (not decoded) |
| E. SHARED func_call | 6 (3) | 6 | 6 | N0133 | ours's elaborated cont_assign Rhs is the definition's func_call; golden a copy (FunctionParam, SelectGivenBySelectOnParameterInFunction, func_local_array) | OPEN (map-4 pair-A residue), ModuleEmit.cpp emitContAssigns |
| E2. SHARED constant | 2 (1) | 2 | 2 | N0554 | gen-scope cont_assign Rhs is the param_assign's constant (SumOfParametersInNestedForLoops) | OPEN, ModuleEmit.cpp gen-scope lambda |
| F. TYPE-PARAMETER DEF NET | 2 (TypeParam) | 2 | **0** | N0770 | golden logic_typespec (the default), ours int_typespec | cleared by pass 137 |
| G. EXTRA FOLDED CONSTANT | 2 (BlackParrotComplex) | 2 | 2 | N0724 | ours folds an elaborated param_assign Rhs golden keeps as an operation | OPEN |
| I. EXTRA CONSTANT under ref_obj | 2 (simple_package) | 2 | 2 | N0764 | ours lists a constant under the package-parameter ref_obj | OPEN (new class here) |

B (typedef alias on the net typespec, N0085) and C (imported-parameter clone, N0002) left the structural rows with
passes 134 and 133. After pass 137 every structural row is one of: pair A's C3 (10, clears optimistically only on
Kmac/default, param_struct_field_bitsel, param_unpacked_struct_array: the Nested/StructArray...PassedAsPort rows and
Kmac/testflags carry more clusters), the ParamEmit/ModuleEmit sharing classes C2/E/E2 (14), D/D2 (8), G, I and the
array_assign net-binding residue. **YosysOldOr** (both modes) is `line(78)` -> `line(604)` under the net-binding law:
the unmasking r11u141 proved (the walk aligns to the end; the extra fields are old values past the old divergence).

## 6. Probe cases by law

1866 NE cases in 942 clusters (probe_clusters.csv: case, law, first field, cluster, objects; laws from
scripts/law_index.py). 103 clear with the pairs by the a7bee711 prediction; measured: 19 with the net-binding law,
**51 with pass 137** (1815 left), 64 more with pair A optimistic (1751). Laws with the most NE cases:
loopCaParamReadKeepsLiteral116 84/123, badConcatOperandsFromSyntax160 71/71, tpElemRebindElabPort110 57/61,
tpPackedArrayTsVar108 56/73, nestedGenProcLhsKeepsRef116 46/74, portViewRangeRecvParams 45/55,
pvExprDefaultFold115 43/50, caNestedModPortedDefShell101 36/38, srlgCondOpInstValueTernFold9 32/140,
nestedParamActualTs6 29/41. Probe-heavy clusters: N0039 (int_typespec decl-vs-use span, 222 cases -> 219 after
pass 137; pass-133 R5 is one shape of it), N0005 (163), N1897 (`work@sub.work@sub::innermod.i`-shaped net names, 119
cases, no corpus row), N1898 (92), N0151 (84, pair A), N0127 (79), N0001 (78 -> 45 after pass 137), N0470 (77),
N0044 (73), N0152/N0153 (function begin unlocated, 71 each), N0128/N0680/N0736/N0737 (the port-view range family,
68-69 each: portViewRangeRecvParams + sizeDimOvrChain4).

## 7. Recommended next briefs per ground

Computed on the rows that remain after pass 137 (MEASURED, 6ef15be0) with pair A r11u140's covered clusters counted
fixed (optimistic): greedy by marginal row-modes cleared, ties by rows carried (evidence/afterp137.txt; the same
greedy on the a7bee711 + net-binding cross-section is evidence/afternb.txt). Rows that still fail after both pairs
have 1 open cluster: 109 row-modes, 2: 88, 3: 53, 4-5: 68, 6 or more: 113 (a7bee711 basis, evidence/extra.txt), so single
clusters clear few rows; the briefs below group clusters by fix site. After pass 137 the 388 remaining row-modes
split by the ground of their open clusters (pair B's named clusters that pass 137 left on a row count as open
again): A only 73, B only 138, both 164, with an unpinned cluster 13.



**Ground A** (base 16 row-modes / 8 tests cleared by the pairs)

| step | cluster | +row-modes | cum row-modes | cum tests | probe | key | site |
|---|---|---|---|---|---|---|---|
| 1 | N0441 | 6 | 22 | 11 | 0 | `struct\|ours-only:fewer-copies\|constant\|under:array_expr` | emitParameters (ParamEmit.cpp, law patOpMemberAsmSplit28) < emitInstance (ModuleEmit.cpp, law elabParamTsRebind) < expor |
| 2 | N0001 | 4 | 26 | 13 | 45 | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt ( |
| 3 | N0007 | 6 | 32 | 16 | 28 | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (St |
| 4 | N0005 | 4 | 36 | 18 | 163 | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.c |
| 5 | N0010 | 2 | 38 | 19 | 4 | `span\|constant\|col+endcol\|under:param_assign` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTargetKinds) < e |
| 6 | N0018 | 2 | 40 | 20 | 18 | `fullname\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emit |
| 7 | N0056 | 2 | 42 | 21 | 1 | `span\|bit_typespec\|endcol\|under:ref_typespec` | makeParamTs (ParamEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law pkgParamTsRefColons131) < exportDes |
| 8 | N0415 | 2 | 44 | 22 | 4 | `fullname\|ref_typespec\|tok:->.id.id\|under:constant` | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < emitModuleD |
| 9 | N0675 | 2 | 46 | 23 | 0 | `fullname\|ref_typespec\|tok:id->id.id\|under:constant` | emitParameters (ParamEmit.cpp, law timeLitParamIntTs) < emitInstance (ModuleEmit.cpp, law elabParamTsRebind) < emitInsta |
| 10 | N1167 | 2 | 48 | 24 | 0 | `value\|constant\|value:UINT->UINT+decompile+size\|under:cont_assign` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall9 |
| 11 | N1140 | 2 | 50 | 25 | 0 | `span\|constant\|ours-zero\|under:operation` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < emitContAssigns (ModuleEmit.cpp, law caIfaceElabNetDeclAssi |
| 12 | N1132 | 2 | 52 | 26 | 0 | `fullname\|ref_typespec\|tok:id@id.id->id\|under:operation` | emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsP |
| 13 | N1118 | 2 | 54 | 27 | 0 | `fullname\|part_select\|tok:id.->\|under:port` | emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < emitInstance (ModuleEmit.cpp, law elabPortConnUnitEnumNet) < op |
| 14 | N1057 | 2 | 56 | 28 | 0 | `fullname\|bit_select\|tok:id[id][id].id[id]->id@id.id[id][id].id[id].id\|under:hier_path` | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law pkgQualParamMemberSelParamIn |
| 15 | N1017 | 2 | 58 | 29 | 0 | `fullname\|ref_obj\|tok:id[id - n].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitMi |
| 16 | N0129 | 1 | 59 | 29 | 58 | `fullname\|ref_typespec\|tok:->.id\|under:constant` | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emitExpr  |
| 17 | N0739 | 1 | 60 | 29 | 27 | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) < |
| 18 | N0012 | 0 | 60 | 29 | 5 | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emi |
| 19 | N0036 | 0 | 60 | 29 | 7 | `span\|bit_select\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitMixedH |
| 20 | N1053 | 2 | 62 | 30 | 0 | `fullname\|bit_select\|tok:id.->\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emitExpr (Exp |

Every OPEN cluster of ground A: 89 row-modes, 44 tests.

**Ground B** (base 16 row-modes / 8 tests cleared by the pairs)

| step | cluster | +row-modes | cum row-modes | cum tests | probe | key | site |
|---|---|---|---|---|---|---|---|
| 1 | N0030 | 7 | 23 | 12 | 58 | `fullname\|ref_obj\|tok:id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitEx |
| 2 | N0139 | 6 | 29 | 15 | 1 | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsN |
| 3 | N0281 | 5 | 34 | 17 | 0 | `fullname\|ref_obj\|tok:id.->@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operat |
| 4 | N0078 | 4 | 38 | 19 | 2 | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law qualSelBaseNoWhitespace41) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < ope |
| 5 | N0133 | 4 | 42 | 21 | 10 | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs10 |
| 6 | N0008 | 2 | 44 | 22 | 25 | `fullname\|ref_typespec\|golden-empty\|under:constant` | operator() (ModuleEmit.cpp, law genLpFoldDigitsMathValue18) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48 |
| 7 | N0554 | 4 | 48 | 24 | 1 | `struct\|golden-only:fewer-copies\|constant\|under:cont_assign` | operator() (ModuleEmit.cpp, law genvarWholeCaRhsFold68) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) <  |
| 8 | N0043 | 2 | 50 | 25 | 5 | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword13 |
| 9 | N0044 | 2 | 52 | 26 | 73 | `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword13 |
| 10 | N0014 | 2 | 54 | 27 | 18 | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs1 |
| 11 | N0039 | 2 | 56 | 28 | 219 | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind2 |
| 12 | N0096 | 2 | 58 | 29 | 21 | `fullname\|ref_typespec\|tok:id::->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp, law typede |
| 13 | N0011 | 2 | 60 | 30 | 12 | `file\|logic_net\|golden-empty\|under:ref_obj` | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cpp, law hoi |
| 14 | N0274 | 2 | 62 | 31 | 1 | `fullname\|ref_obj\|golden-empty@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < typePa |
| 15 | N0454 | 2 | 64 | 32 | 1 | `fullname\|ref_typespec\|tok:id@id.id.id.id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAt |
| 16 | N0528 | 2 | 66 | 33 | 2 | `value\|constant\|value:UINT->UINT\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgUnvaluedActualLitRetFold8) < emitInstance (ModuleEmit.cpp, law elabPortBoundInt |
| 17 | N0472 | 2 | 68 | 34 | 42 | `fullname\|ref_obj\|tok:id->id.id@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < typePa |
| 18 | N0470 | 4 | 72 | 36 | 77 | `fullname\|ref_typespec\|tok:id->id\|under:packed_array_typespec` | namedElemPackedDimTs31 (TypeEmit.cpp, law crossPkgRangeBoundFold) < emitParameters (ParamEmit.cpp, law typeParamNamedEle |
| 19 | N0681 | 2 | 74 | 37 | 23 | `span\|constant\|ours-zero\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgCondOpInstValueTernFold9) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntP |
| 20 | N1108 | 2 | 76 | 38 | 0 | `depth\|constant\|func_call->cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgUnvaluedActualLitRetFold8) < emitInstance (ModuleEmit.cpp, law elabPortBoundInt |

Every OPEN cluster of ground B: 154 row-modes, 79 tests.

Every OPEN cluster of both grounds: 404 row-modes.

**Module/type ground (pair B's files; the next refill after pass 137):**
1. **N0030** (18 row-modes after pass 137, +7 alone): the elaborated process / continuous assignment named by the
   definition (`work@dut.b` for `work@top.dut.b`, r11u131 R10: shared definition-view objects in ModuleEmit.cpp);
   its --elabuhdm twin N0136 went 10 -> 1 with pass 137.
2. **The brief's full-name-in-typespec clusters pass 137 did not move**: N0139 (10, heads 10, +6), N0281 (8, +5),
   N0078 (13, +4), N0096 (11), N0084 (8, 50 probe cases), N0014 / N0028 / N0454 (pass-134 R1: member names in
   parameter typespecs, makeParamTs) and N0274 / N0472 / N0470 (type-parameter default-bound and element names,
   42 + 77 probe cases): TypeEmit.cpp buildStructTs / emitSyntaxExpr (law hpSymbolicSelect) / namedElemPackedDimTs31.
3. **Sharing classes E / E2** (N0133 func_call, N0554 constant; 8 row-modes, +4 each): ours's elaborated cont_assign
   Rhs is the definition's object, golden holds a copy (ModuleEmit.cpp emitContAssigns, the gen-scope lambda).
4. **N0008** (29 row-modes, **heads 20** after pass 137 — tied largest first cluster with N0001): the folded range
   bound's `ref_typespec` full name; golden's chain ends at an UNPARENTED logic_typespec copy, so the name computes
   empty (pass-133 R1, decoded: TypeEmit.cpp makeTypespec's bound-fold lambda beside law
   foldedBoundTsIsTheSignednessCapture48 stores the owner name; the law is "store no name there"; the a7bee711 pin
   for the LocalParamInNestedForLoops example lands in ModuleEmit.cpp's generate-loop fold lambda).
5. **Struct typespec spans taken at the use** (N0043, N0044, N0009: 16 + 14 + 18 row-modes, 73 probe cases; r11u130
   R2, 12 of its 17 rows still differ): TypeEmit.cpp buildStructTs.
6. **N0039** (14 after pass 137, 219 probe cases): the int_typespec declaration-vs-use span (TypeParam, the UVM
   family; pass-133 R5 is its elaborated `Q = X` import face).
7. **The macro line model** (N0015 / N0017 / N0026 / N0027 / N0029: 20-27 row-modes each, 0 alone: the ibex
   prim_assert `$error`/`$time` rows; r11u131 R7, UhdmExporter.cpp locLineCol) and **N0064** (include_file_info
   lines, 14, all first; the brief named it, pass 137 left it).
8. **The class ground** (UhdmExporter.cpp): N0051, N0067, N0068, N0069, N0072, N0103 (class_typespec / string_typespec
   spans, files and names, 11-15 row-modes each, 25-47 probe cases), N0070 (function span in class_defn), N0041
   (unsupported_typespec without file, 17; named by both briefs, pass 137 left it).

**Expression/parameter ground (pair A's files; the next refill after r11u140):**
1. **N0441** (class C2, 6 structural row-modes, +6 alone): the array_expr default pattern's constant copied where
   golden shares one (ParamEmit.cpp emitParameters, law patOpMemberAsmSplit28).
2. **N0001** (62 after pass 137, heads 20; +4 alone): hier_path element spans (ExprEmit.cpp emitExpr); pass 137
   took the struct-parameter path base (82 -> 62).
3. **N0007 / N0018** (34 / 25 row-modes): hier_path element full names golden leaves empty / names through the
   class scope (ExprEmit.cpp emitExpr beside law vifClockingPathComponent5), with N0098 / N0099 / N0101 / N0102
   (hier_path element file and span, 11 each) and N0071 / N0097 (hier_path endcol).
4. **N0005 / N0010** (44 / 30 row-modes, 163 + 4 probe cases): folded parameter constants' spans under param_assign
   (ExprEmit.cpp emitExpr / tryFoldConst under ParamEmit.cpp emitParameters); the port-view share of N0005 is
   pass-133 R4 (ModuleEmit.cpp emitInterfaceInstance).
5. **ref_typespec names under constants**: N0129 (58 probe cases), N0415, N0675, N1132 (ParamEmit / ExprEmit).
6. **N0056** (15, heads 6: bit_typespec endcol under a parameter; the a7bee711 pin is ParamEmit.cpp makeParamTs),
   **N0036** (bit_select span in operations), **N0076** (part_select ref names, heads 7).
7. Before counting any row of **N0272**: its BitsArray / AssignBitsCallToSubmoduleParameter rows were net-binding
   rows and cleared with pass 137.

## 8. Files

* `clusters.csv` — every (row-mode, cluster) with its object count (test,mode,corpus,first_field,cluster_id,objects).
* `probe_clusters.csv` — every (probe case, cluster) (case,law,first_field,cluster_id,objects).
* `fail_list.csv` (517) / `probe_fail_list.csv` (1866) — the gate's fail list: every `STRICT_NOTEQUAL` row-mode /
  probe case, its strict cell, first cluster, its coverage and site, clusters, open clusters, whether the pairs'
  covered clusters clear it (`A+B`, `A`, `B`), the downstream verdict, and the MEASURED cross-sections:
  `strict_after_nb`, `first_cluster_after_nb`, `clears_after_both_pairs` (nb measured + the rest optimistic),
  `strict_after_p137`, `first_cluster_after_p137`, `clears_after_both_pairs_p137` (pass 137 measured + pair A
  optimistic).
* `cluster_index.csv` (2142) / `family_index.csv` — ranked, with rows per corpus, probe cases, alone yield, first-in
  rows, coverage, map-4 coverage, r11u128 id, site, probe laws, key, example, `rows_after_nb`, `tests_after_nb`,
  `first_in_after_nb`, `alone_on_top_of_pairs_after_nb`, `probe_after_nb`, `ground`, and the same five after p137.
* `evidence/clusters/N####_*.txt` — golden and our records around the example object (mode-4 flags), the holder on
  the other side, the row's facets (748 files: every cluster with >= 4 row-modes or in the pin set).
* `evidence/objects.csv` (one example per cluster, 2142), `evidence/row_objects.csv` (one example per (row-mode or
  case, cluster), with the object count).
* `evidence/pins_new.txt` (the a7bee711 gdb frames, 741 clusters, with db=SAME/DIFF), `sites.json` (the final site
  per re-pinned or decoded cluster; every other cluster's site is map 4's, marked in cluster_index.csv),
  `decoded_sites.json` (this map's decodes), `residue_routes.json`, `ground_override.json`, `residue_cases.txt`
  (the pass READMEs' residue cases through the pipeline), `pinwant.txt`.
* `evidence/final.txt`, `report.txt`, `extra.txt`, `structural.txt`, `afternb.txt`, `afterp137.txt`, `mdtables.txt`,
  `delta.txt`, `nb_sweep_summary.txt`, `p137_sweep_summary.txt`, `verify.txt`, `controls/` — the pipeline's printouts.
* `drivers/` — `run.sh` (every step), `strictcmp_x.cpp` + `cc.sh`, `run1.sh`, `jobs.py`, `probejobs.py`,
  `probelaw.py`, `analyze.py`, `common.py`, `final.py` (persistent ids, the new N-id rule, the pairs' coverage),
  `pinmulti.py` (+ db=SAME/DIFF, never a fenced test), `sites.py`, `mksites.py`, `casekeys.sh`, `afternb.py` (the
  measured cross-sections, `AFTER_TAG=nb|p137`), `report.py`, `extra.py`, `structural.py`, `mdtables.py`,
  `readme_tables.py`, `delta.py`, `evid.py`, `rowobjects.py`, `redact.py`, `objrank.cpp`; `pinall.py` /
  `pinprep2.py` / `pinsite.sh` / `pinrecover.py` (map 4's one-cluster-per-run pinning, kept for reference).
