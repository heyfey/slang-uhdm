# r11u150map — the strict ground map, sixth edition (measurement only)

Base `98aa49db` (branch matrix-1.87). No pass landed after it while this map was measured, so every number here is
at 98aa49db: after passes 137 (6ef15be0), 140 (c24699f1) and 144 (b2199096), the verifier refinements of r11u141,
r11u143 and r11u149 (the r11u149 fix `tpDefaultEndTopTwin149v` is in 98aa49db), and the sharing-classes decode
r11u148share (1d0c82ef; its law.patch is NOT landed). Nothing under `src/`, `scripts/`, `results/`, `tests/` or
`third_party/` is edited; this directory is the whole patch.

Law names are written `law <name>`, never with the section sign, so `scripts/law_index.py` does not read this
directory as a pass of laws. Like maps 3-5, this README still adds one row to the passes table of tests/LAWS.md, so
the landing must run `python3 scripts/law_index.py` and commit tests/LAWS.md with it. The one slang-fenced test that
is a strict-NE surelog row (both modes) is written `FENCED_1` everywhere, file names included
(drivers/redact.py). No binary, gdb run or script touched a fenced test's source: drivers/pinmulti.py skips fenced
rows, and the only reads of that row are strictcmp_x record dumps of the two databases the reference sweep had
already written.

Worktree `/tmp/wt_r11u150` (system-deps config, `-j 2`). Binaries frozen with `chmod 555` in `/tmp/r11u150_bin`
before any measurement (evidence/verify.txt):

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `134fb0c36f027328611ae600c56123c5` | the worktree's 98aa49db build, byte-identical to the main tree's `build/slang-uhdm`. The brief's `c7b333fcf978` is an older binary (map 5 said the same of it); 134fb0c3 is the binary the reference sweep ran |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's; the tool is unchanged since 4f73d52f |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | drivers/strictcmp_x.cpp built with drivers/cc.sh (maps 3-5's variant, same md5): the committed tool plus `--dump-ids` and the mode-4 rule's inputs in the dump. Its stdout and rc equal the committed tool's on 40 of 40 sampled rows |
| `slang-uhdm.g1` | `79394079bc66395744ff75b6dae88e0f` | the same source built with `-DCMAKE_CXX_FLAGS=-g1` (/tmp/r11u150_g1build); used by gdb only. 76 of its 84 pin runs wrote the reference database byte for byte |
| `slang-uhdm.share` | `8b8675cc0dae6e36c860d75f70ce56d5` | MEASUREMENT ONLY: 98aa49db + `tools/probe/r11u148share/law.patch` (clean `git apply`, offsets only; worktree `/tmp/wt_r11u150share`) |
| `objrank` | `82be8e819d67948b41f0cbf0a904f216` | drivers/objrank.cpp: an object's creation rank among the objects of its type |

## 0. Where we stand (98aa49db; the committed baselines are the fail list)

| corpus | mode | judge-equal | strict-equal (`CMP_EQUAL` / `EQUAL`) | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 399 | 81 |
| surelog | testflags | 474 | 397 | 77 |
| uhdm2rtlil | default | 803 | 702 | 101 |
| uhdm2rtlil | testflags | 803 | 702 | 101 |
| probe cases | — | 4087 | 2308 | 1779 |

**The fail list is 360 row-modes (158 surelog + 202 uhdm2rtlil) in 183 tests, plus 1779 probe cases.**

First fields, tallied from the detail column of results/golden_*.csv (evidence/tallies.txt):
* surelog: fullname 36, line 35, endcol 34, file 16, endline 13, col 8, name 6, depth 6, value 4.
* uhdm2rtlil: fullname 86, file 32, line 22, col 20, endline 10, depth 10, endcol 8, type 8, name 6.
* probe: fullname 747, endcol 337, line 223, file 125, depth 102, type 94, col 57, endline 53, name 33, value 5,
  decompile 3.

Mode asymmetries:
* Surelog rows NE in default only: PortInitVal, Rggen, Scoreboard, UnsizedParam, YosysBigSimEllip.
* Surelog rows NE in testflags only: HierPathTypespec.
* Every uhdm2rtlil fail test is NE in both modes.

**Every uhdm2rtlil fail row-mode (202 of 202) is downstream IDENTICAL** (results/downstream_uhdm2rtlil.csv).

**Since map 5.** Map 5 measured pass 137 at 6ef15be0: 404 row-modes and 1815 probe cases. Since then, **44 row-modes
and 36 probe cases left the fail list, and none entered**:
* Pass 140 took 26 row-modes and 23 probe cases. Its README lists 23 row-modes; the landing also re-baselined
  ClassVar t, DefaultPatternModule t and Kmac t, as r11u149 established.
* Pass 144 took 18 row-modes and 13 probe cases.

Map 5 had 2142 clusters at a7bee711. This map has 1518: 1040 carry a corpus row and 920 a probe case. **7 of them are
new (N2383-N2389)**; every other cluster keeps its map-5 id, because its key is map 5's key.

## 1. Method (map 5's pipeline, drivers/run.sh)

1. **Input.** The READ-ONLY 98aa49db reference sweep `/tmp/intr11u149`. All 3273 `slang:` lines in its cmds.txt
   name the main-tree binary 134fb0c3, built at 20:47:14. Every database of the sweep was written after that, between
   20:47:51 and 20:52:27. Its status and strict columns equal results/golden_surelog.csv (1596 of 1596 rows),
   golden_uhdm2rtlil.csv (1742 of 1742) and golden_probe.csv (4087 of 4087). Four rows re-run with the frozen
   pristine binary are byte-identical (sva_range/d, TypeParam/t, ComplexHierPath/d, FunctionParam/t).
   * Jobs are every `STRICT_NOTEQUAL` row-mode of the committed baselines (360); the golden is the cache entry its
     cmds.txt names.
   * Every probe case is a job too (4087). Its golden is `scripts/check_probe.py`'s `cache_dir(rel)`, whose key
     carries a sha1 of the case's files; ours is `/tmp/intr11u149/probe/<rel with / -> __>.uhdm`.
2. **Strict runs.** `drivers/run1.sh` runs `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job.
   * All 360 corpus runs return rc=2.
   * Probe runs return rc=0 on 2308 cases and rc=2 on 1779. That NE set, and every `differ:<field>(<n>)` cell,
     equals results/golden_probe.csv.
3. **Analysis.** `drivers/analyze.py` records EVERY differing object; it is unchanged since map 3. Its mode-4
   reimplementation agrees with the tool's stdout (field tally, objects differing, first field) on **2139 of 2139
   rows**, and with the csv strict cell on every corpus row (0 CELL-MISMATCH).
4. **Clusters.** The key is maps 4/5's: `facet|type|shape|under:<walk parent type>`, plus the `@builtin` and
   `@in-typespec` splits. **A cluster whose key persists keeps its map-5 id** (1511 of 1518). A new key takes the
   next id from N2383 that no earlier map used (maps 3-5 use N0001-N2382).
5. **Sites.** For 89 clusters, `drivers/pinmulti.py` ran one gdb session per example row: the `-g1` exporter stops at
   the example object's `Serializer::Make<type>` rank, with the MAIN checkout's case directories as cwd so the run's
   database can be compared with the reference one. The 89 are the clusters that are new, or whose example object
   changed since map 5, among those with >= 3 row-modes, first on a fail row, covered, or >= 40 probe cases.
   Results:
   * 84 pinned: `db=SAME` on 76, and `db=DIFF` on 8, all on MiniAmiq/default and Scoreboard/default (the UVM order
     coin). The DIFF ones keep map 5's pin.
   * 5 have no partner record and keep map 5's site: N0142, N0194, N0478, N0488, N1098.

   `drivers/mksites6.py` merges the new pins with map 5's sites. 64 new pins name the same mint as map 5, 8 had no
   map-5 pin, and 4 name another mint (N0021, N0030, N0134, N0457; both are given). Every other cluster keeps map 5's
   pin, marked `[r11u142map pin]`. Map 5's decoded notes and this map's (evidence/decoded_sites.json) ride on the
   site.
6. **Coverage by the live pairs**, from the brief's map-5 ids (`drivers/final.py`):
   * **Pair A, r11u145** (ExprEmit/EmitHelpers/StmtEmit/ParamEmit; base c24699f1):
     * Named: N0441 (gone; its successor N2385 is routed), N0001, N0007, N0018; the hier_path file/span clusters
       N0098, N0099, N0101, N0102, N0071, N0097; N0005 and N0010; N0129, N0415, N0675 (gone, cleared by pass 140),
       N1132, N0063; N0056, N0036, N0076, N0052, N0089, N0091; and pass-137 sister residue S3, N0057 (S2 is N0056's
       parameter half).
     * Routed residues (evidence/residue_routes.json): the size cast N0059 + N0024 (r11u140 R5); ParamNoImport N0003
       (R4); the process-lvalue part-select names N0357 + N1064 (R12); r11v140's leftovers N0061 (plv/v11) and N0551
       (stm/b04, b05); and N2385.
   * **Pair B, r11u146** (TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main; base b2199096):
     * **r11u148share's law.patch, MEASURED (section 3).** Its clusters are N0133, N0554, N0764 and N0284.
     * Named: N0030, N0139, N0096, N0084; the struct/int typespec spans N0043, N0044, N0009, N0014, N0028, N0039,
       N0025, N0033, N0031, N0042; the UVM/Earlgrey clusters N0064, N0015, N0067, N0068, N0069, N0070 (gone: pass
       144's method-span law cleared it, 13 -> 0), N0071, N0072, N0051, N0093.
     * Routed: PortExpr/ExplictiPorts (r11u144 R1) N0081, N0515, N0532, N0824, N0825, N1098, N1085, N1093, N1111,
       N1148, N0088, N0055; pc31 N0568; pc33 N0525 + N0562.
     * Routed, the verifiers' faces: N0427 (v11u144 residue 1), N0276 (v11u144 residue 2 and r11u149 R-b), N0681 +
       N1169 (v11u144 residue 4), N1017 (v11u144 residue 6).
   * **N0071 is named by both briefs**: pair A's "hier_path span clusters" and pair B's "N0067-N0072".
   * **How the residues were routed.** The residue cases the pass READMEs name went through the same pipeline
     (`drivers/casekeys.sh`, plain and `--elabuhdm`; evidence/residue_cases.txt). A residue case whose keys the
     corpus lacks cannot be routed:
     * plv/v05 and v07 (process-lvalue index names in a function body, and a base-select operation index);
     * v11u144 hg/x1 and x2 (the elaborated generate-scope index reference);
     * el/x1 (the `--elabuhdm` part-select base span);
     * r11u149 el/n06 (the `--elabuhdm` instance-array property name).

     Those are probe-grid shapes only.
   * A cluster map 5 gave to a pair that has since landed, still present, reads `OPEN (residue of r11u140|r11u137:
     ...)`. A cluster that pass 144's brief named, still present, reads `OPEN (residue of r11u144: ...)`.
7. **Grounds.** A cluster's ground is its pinned mint's file (A = ExprEmit/EmitHelpers/StmtEmit/ParamEmit, B = the
   rest), overridden where a pass decoded the fix site elsewhere (evidence/ground_override.json). The overrides are
   map 5's, plus r11u148's pair-A decodes N0045, N0724, N0046, N2383, N2384 and N2385, plus N0059, N0024 and N0003.
8. **Yields.** Pair A's covered clusters count as fixed whole (optimistic). For pair B, r11u148's law is MEASURED
   (the share binary's full sweep, re-dumped and re-keyed), and pair B's other covered clusters are then applied
   optimistically to the share cross-section. The share clusters are not re-applied: what the measured law leaves is
   open.

## 2. Positive controls (evidence/controls/, evidence/verify.txt)

| control | result |
|---|---|
| surelog/default/1364_2005 | `STRICT_EQUAL 159 objects`, record dumps byte-identical (159 / 159) |
| surelog/default/HierPathInterfBlock | `STRICT_EQUAL 226 objects`, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray | `STRICT_EQUAL 194 objects`, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, `lhsPath: design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL,decompile:` both modes |
| analyzer rule vs tool stdout | 2139 / 2139 rows (360 corpus + 1779 probe) |
| csv strict cell vs tool | 360 / 360 corpus; the probe NE set and cells = results/golden_probe.csv's |
| variant vs committed tool | 40 / 40 sampled rows, stdout and rc identical |
| reference databases vs frozen pristine binary | 4 / 4 rows byte-identical |
| pin validity | 76 / 84 gdb runs wrote the reference database byte for byte; the 8 others keep map 5's pin |
| share binary sweep vs 98aa49db baselines | `regressions=0` in all three stages. Probe: conversions 2 (r11v48repro/vc1, vc2), changes 1 (r10v200repro/v200_5_modmat fullname 2 -> 3, r11u148's proven unmasking). Surelog 0/0/0. uhdm2rtlil: conversions 10, changes 2 (LocalParamInNestedForLoops d/t fullname 2 -> 1). This is exactly r11u148share's claim at 0024d365, reproduced at 98aa49db. All 3273 `slang:` lines name the share binary |

## 2b. Gates (this map changes no binary; the measured binary is the pristine 98aa49db one)

This map's own full sweep of the frozen pristine binary ran from the worktree, with every pin exported:
`tests/sweep.sh --jobs 3 --workdir /tmp/r11u150_swP`. Its summary is in evidence/pristine_sweep_summary.txt, and all
3273 `slang:` lines name `/tmp/r11u150_bin/slang-uhdm`. The sweep's rc is 1 only because the law index reads
`STALE`, and it would with or without this directory. At 98aa49db, `scripts/law_index.py` already regenerates three
`commits:` lines for 98aa49db's own laws, and this README adds the passes-table row `| r11u150map |  |  | 0 | 0 |`.

| gate | result |
|---|---|
| (1) binaries | pristine 134fb0c3 = the main tree's build; share 8b8675cc; g1 79394079 (section 0 table) |
| (2) probe vs golden_probe.csv | EQUAL 2308 / STRICT_NOTEQUAL 1779; `regressions=0 conversions=0 changes=0` |
| (3) surelog + uhdm2rtlil vs golden_*.csv | `regressions=0 conversions=0 changes=0` in both corpora. The scoreboards are 480/3 + 474/3 and 803/1/67 |
| (4) downstream | EQUIVALENT 2, IDENTICAL 803, SLANG_REJECT 66, not identical and not excused 0. The verdict equals results/downstream_uhdm2rtlil.csv on 871 of 871 rows. No row is targeted: this map lands no law |
| (5) uhdm-cmp on touched rows | no row is touched (no source edit) |
| (6) byteverify | Pristine vs the reference sweep /tmp/intr11u149: the only corpus movers are MiniAmiq and SeqDriver d/t, the UVM order coin. Share vs pristine (same-length workdirs, SELFCHECK 959/960 and 1607/1608 flagged, evidence/byteverify_share.txt): surelog 4 movers (MiniAmiq and SeqDriver d/t, the coin); uhdm2rtlil 12 movers, exactly r11u148share's census (E, E2, I on FunctionParam, SelectGivenBy..., func_local_array, SumOfParameters..., LocalParamInNestedForLoops and simple_package, both modes). Probe databases are compared by strict verdict only, because the two sweeps ran from different worktree paths |
| canaries | canaries.sh: surelog ok=52 changed=0 (7 unknown, the u2r-only names); uhdm2rtlil ok=16 changed=0 (25 unknown). ctcan2 `EXPECT_UNKNOWN=1` surelog PASS (ok=58); `EXPECT_UNKNOWN=6` uhdm2rtlil PASS (ok=2) |

## 3. The live pairs: yield, and the fail list after them

### 3a. Pair B's share law, MEASURED (evidence/report.txt section 1, evidence/share_sweep_summary.txt)

The share binary converts **10 row-modes**, all uhdm2rtlil in both modes: FunctionParam, SelectGivenBySelectOn
ParameterInFunction, func_local_array (class E), SumOfParametersInNestedForLoops (E2) and simple_package (I). It also
converts **2 probe cases** (r11v48repro/vc1, vc2). None entered. Two row-modes change cluster sets
(LocalParamInNestedForLoops d/t loses N0554, leaving only N0008), and one probe case does (v200_5_modmat loses
N2346, the I-2 unmasking). The share records hold no key the pristine map lacks.

**Calibration:** the share clusters predicted 6 of the 10 conversions. The 4 unpredicted (func_local_array d/t,
simple_package d/t) carry other clusters in the pristine map, and the walk re-aligns once the law fixes the head.
The measured cross-section is therefore the one to trust. N0133 keeps 4 row-modes and N0284 keeps 3 after the
law: N0133 on cfg_func_width_loop d/t and const_cast_signext d/t, N0284 on Scr1SvTests d/t and YosysBigSimEllip d.
These are call shapes the law does not claim; r11u148's e12 and f08 residues are grid cases of the same kind.

### 3b. Both pairs (pair A optimistic; pair B = share measured + the rest optimistic)

| | clusters | row-modes cleared | tests cleared (every NE mode) | probe cases cleared |
|---|---|---|---|---|
| pair A r11u145 (named + routed), optimistic | 30 | 23 | 11 | 100 |
| pair B r11u146: r11u148 share law, MEASURED | 4 | 10 | 5 | 2 |
| pair B r11u146: the other named + routed clusters, optimistic | 43 | 25 | 12 | 172 |
| **both** | 77 | **71** | **35** | **299** |

| corpus | mode | fails today | after the share law (measured) | after both pairs |
|---|---|---|---|---|
| surelog | default | 81 | 81 | 69 |
| surelog | testflags | 77 | 77 | 64 |
| uhdm2rtlil | default | 101 | 96 | 78 |
| uhdm2rtlil | testflags | 101 | 96 | 78 |
| **corpus** | | **360 row-modes / 183 tests** | **350** | **289 row-modes / 148 tests** |
| **probe cases** | | **1779** | **1777** | **1480** |

The rows the pairs clear (evidence/report.txt section 2):
* **A** (23): DefaultPatternInt d/t (N2385), GenIfIfaceParamStructField d/t, HierPathStructTypespec d/t,
  ParamNoImport d/t, PreprocTest d/t, YosysOldOpen t; uhdm2rtlil ibex_counter, iface_cfg_mem, iface_param_2level,
  jeras_tcb_gpio, mem_ff_partial_rsp and portsel_struct_param, all d/t.
* **B, optimistic** (25): InterfaceParamOverrideProp d/t, InterfArrayBind d/t, IOClassStruct d/t, PortExpr d/t,
  StructArrayNet d/t, ExplictiPorts t; uhdm2rtlil gen_scope_typaram, genvar_iface_struct, mem_packed_2d_byte_write,
  packed_struct_array_shift, port_chained_type_param, struct_param_pattern_packing and unpacked_elem_partsel_comb,
  all d/t.
* **B, measured** (10): the share conversions above.
* **A+B** (13): StructParamFieldRange d/t, YosysOldOpen d; uhdm2rtlil cva6_struct_param_field,
  iface_nested_param_field, iface_scalar_localparam, iface_struct_field_param_width and packed_struct_array_fifo,
  all d/t.

**Read every optimistic count as an upper bound on the named rows.** Map 5's calibration: its pair-A prediction moved
16 of 16, and 10 unpredicted rows moved beside it; map 4 moved 24 of 97 (section 8).

After both pairs, the 289 remaining row-modes carry:
* by open-cluster count: 1 open cluster 53, 2: 90, 3: 24, 4-5: 57, 6 or more: 65;
* by ground: A only 56, B only 125, both 95, with an unpinned cluster 13;
* by the share-measured first field: fullname 91, line 53, file 48, endcol 32, endline 21, col 16, name 12, depth 12,
  value 4.

### The covered clusters (columns: rows at 98aa49db, rows and probe cases after the share law, measured)

| cluster | rows sl/u2r | tests | first in | probe | after share (probe) | coverage | key | site |
|---|---|---|---|---|---|---|---|---|
| N0001 | 62 32/30 | 32 | 20 | 45 | 62 (45) | COVERED r11u145 (N0001) | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [NOTE: r11u131 R2 pin |
| N0005 | 44 18/26 | 22 | 8 | 163 | 44 (163) | COVERED r11u145 (N0005) | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) [r11u142map pin] |
| N0007 | 34 24/10 | 18 | 0 | 28 | 34 (28) | COVERED r11u145 (N0007) | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin] |
| N0010 | 30 10/20 | 15 | 2 | 4 | 30 (4) | COVERED r11u145 (N0010) | `span\|constant\|col+endcol\|under:param_assign` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTargetKinds) < emitParameters (ParamEmit.cpp, law castElabFoldTargetKinds) [r11u142map pin] |
| N0015 | 27 7/20 | 14 | 0 | 1 | 27 (1) | COVERED r11u146 (N0015) | `span\|constant\|line+col+endline+endcol\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [DECODED (r11u131 R7): macro-argu |
| N0018 | 25 21/4 | 13 | 0 | 18 | 25 (18) | COVERED r11u145 (N0018) | `fullname\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin |
| N0009 | 18 10/8 | 9 | 6 | 16 | 18 (16) | COVERED r11u146 (N0009) | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) [DECODED (r11u13 |
| N0036 | 18 14/4 | 10 | 0 | 7 | 18 (7) | COVERED r11u145 (N0036) | `span\|bit_select\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxAtPath79) [r11u142map pin] |
| N0025 | 17 5/12 | 9 | 0 | 11 | 17 (11) | COVERED r11u146 (N0025) | `depth\|constant\|range->operation` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) [DECODED (r11u130 R5): Typede |
| N0033 | 17 5/12 | 9 | 0 | 11 | 17 (11) | COVERED r11u146 (N0033) | `struct\|ours-only:fewer-copies\|operation\|under:range` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabSize113) [DECODED (r11u130 R5): as N |
| N0030 | 16 8/8 | 8 | 8 | 58 | 16 (58) | COVERED r11u146 (N0030) | `fullname\|ref_obj\|tok:id.->\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law structParamPathBaseAtMember137) < operator() (ModuleEmit.cpp, law connOperandOwnScopeBind61) [r11u142map p |
| N0043 | 16 10/6 | 9 | 4 | 5 | 16 (5) | COVERED r11u146 (N0043) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) [DECODED (r11u13 |
| N0031 | 15 9/6 | 8 | 0 | 13 | 15 (13) | COVERED r11u146 (N0031) | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassDefn (UhdmExporter.cpp, law classDefnVir |
| N0051 | 15 15/0 | 8 | 2 | 9 | 15 (9) | COVERED r11u146 (N0051) | `span\|class_typespec\|endcol\|under:ref_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter.cpp, law typedefAliasSharesTypespec25) < emitClassDefn (UhdmExporter.cpp, law classDefnVi |
| N0055 | 15 13/2 | 8 | 0 | 1 | 15 (1) | COVERED r11u146 (residue: ExplictiPorts port expression operands (r11u140 R10)) | `span\|ref_obj\|line+endline\|under:operation` | emitBadConcatOperand160 (ExprEmit.cpp, law badConcatCompoundOperands162) < emitBadConcatFromSyntax160 (ExprEmit.cpp, law classArgBind12) < emitExpr (ExprEmit.cpp, law droppedIdxRecvCall26) [r11u142map |
| N0056 | 15 13/2 | 8 | 6 | 1 | 15 (1) | COVERED r11u145 (N0056) | `span\|bit_typespec\|endcol\|under:ref_typespec` | makeParamTs (ParamEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law pkgParamTsRefColons131) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) [r11u138map pin (o |
| N0044 | 14 6/8 | 7 | 10 | 73 | 14 (73) | COVERED r11u146 (N0044) | `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitTopPorts (ModuleEmit.cpp, law defNetTsScope) [DECODED (r11u130 R2): as  |
| N0003 | 14 8/6 | 7 | 8 | 36 | 14 (36) | COVERED r11u145 (residue: ParamNoImport / StructParamPatternInitCast (r11u140 R4): golden' | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [DECODE |
| N0014 | 14 8/6 | 7 | 2 | 18 | 14 (18) | COVERED r11u146 (N0014) | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypespec (TypeEmit.cpp, law anonPackedAggDimTs107) [r11u142map pin] |
| N0028 | 14 4/10 | 7 | 0 | 2 | 14 (2) | COVERED r11u146 (N0028) | `fullname\|ref_typespec\|tok:->id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < patchParamTypespecs (ParamEmit.cpp, law paramCloneImportedCopy) |
| N0063 | 14 2/12 | 7 | 0 | 2 | 14 (2) | COVERED r11u145 (N0063) | `fullname\|ref_typespec\|ours-empty\|under:operation` | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender112) < emitExpr (ExprEmit.cpp, law concatRefNoSubst) [r11u142map pin] |
| N0057 | 14 4/10 | 7 | 0 | 0 | 14 (0) | COVERED r11u145 (N0057) | `struct\|golden-only:fewer-copies\|ref_typespec\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp, law importCopyAggFormalOwnCopy32) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u138map pin]  |
| N0064 | 14 14/0 | 8 | 14 | 0 | 14 (0) | COVERED r11u146 (N0064) | `span\|include_file_info\|line+endline\|under:design` | emitIncludeFileInfos (UhdmExporter.cpp, law includeInactiveTabNotText141v) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| N0067 | 13 13/0 | 7 | 0 | 47 | 13 (47) | COVERED r11u146 (N0067) | `file\|class_typespec\|ours-empty\|under:ref_typespec` | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPropIsArrayVar6) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor5 |
| N0068 | 13 13/0 | 7 | 0 | 47 | 13 (47) | COVERED r11u146 (N0068) | `span\|class_typespec\|ours-zero\|under:ref_typespec` | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPropIsArrayVar6) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor5 |
| N0069 | 13 13/0 | 7 | 0 | 25 | 13 (25) | COVERED r11u146 (N0069) | `span\|string_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < sharedTypespec (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) [r |
| N0071 | 13 13/0 | 7 | 0 | 17 | 13 (17) | COVERED r11u145+r11u146 (N0071) | `span\|hier_path\|endcol\|under:operation` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) [r11u142map pin] |
| N0072 | 13 13/0 | 7 | 0 | 16 | 13 (16) | COVERED r11u146 (N0072) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) [r11u142map  |
| N0042 | 13 9/4 | 7 | 0 | 10 | 13 (10) | COVERED r11u146 (N0042) | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassDefn (UhdmExporter.cpp, law classDefnVir |
| N0076 | 13 7/6 | 7 | 9 | 5 | 13 (5) | COVERED r11u145 (N0076) | `fullname\|ref_obj\|tok:id.->\|under:part_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < operator() (ModuleEmit.cpp, law genCaTernaryFoldGenScope22) [r11u142map pin] |
| N0081 | 13 13/0 | 7 | 2 | 0 | 13 (0) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|ref_obj\|line+col+endline+endcol\|under:operation` | emitPortExprPort (ModuleEmit.cpp, law importedPkgVecPortClone) < emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitModuleDefPorts (ModuleEmit.cpp, law caNestedModDefNameScoped99) [r11u142map p |
| N0039 | 12 12/0 | 7 | 0 | 219 | 12 (219) | COVERED r11u146 (N0039) | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) [DECODE |
| N0024 | 12 10/2 | 6 | 0 | 34 | 12 (34) | COVERED r11u145 (residue: the size cast's twin (r11u140 R5): golden's struct_typespec copy | `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec` | emitModuleDef (ModuleEmit.cpp, law ifaceDefNetTypespecIsTheModuleRule224) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| N0061 | 12 12/0 | 7 | 0 | 8 | 12 (8) | COVERED r11u145 (residue: process-lvalue leftover (r11v140 residue 4, plv/v11_incdec)) | `span\|bit_select\|col+endcol\|under:hier_path` | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectErased4) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) |
| N0091 | 12 10/2 | 6 | 0 | 1 | 12 (1) | COVERED r11u145 (N0091) | `span\|ref_obj\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) [r11u142map pin] |
| N0093 | 11 11/0 | 6 | 0 | 65 | 11 (65) | COVERED r11u146 (N0093) | `span\|io_decl\|line+col+endline+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law classScopedTdDeclTsUnsupported11) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClass |
| N0096 | 11 11/0 | 6 | 2 | 21 | 11 (21) | COVERED r11u146 (N0096) | `fullname\|ref_typespec\|tok:id::->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp, law typedefAliasSharesTypespec25) < classElemVar (UhdmExporter.cpp, law classPropElemTsFol |
| N0097 | 11 11/0 | 6 | 0 | 17 | 11 (17) | COVERED r11u145 (N0097) | `span\|hier_path\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin] |
| N0098 | 11 11/0 | 6 | 0 | 13 | 11 (13) | COVERED r11u145 (N0098) | `file\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin] |
| N0099 | 11 11/0 | 6 | 0 | 12 | 11 (12) | COVERED r11u145 (N0099) | `span\|ref_obj\|ours-zero\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin] |
| N0101 | 11 11/0 | 6 | 0 | 7 | 11 (7) | COVERED r11u145 (N0101) | `file\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin |
| N0102 | 11 11/0 | 6 | 0 | 7 | 11 (7) | COVERED r11u145 (N0102) | `span\|ref_obj\|golden-zero\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin |
| N0129 | 10 4/6 | 5 | 1 | 58 | 10 (58) | COVERED r11u145 (N0129) | `fullname\|ref_typespec\|tok:->.id\|under:constant` | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emitExpr (ExprEmit.cpp, law psBoundPkgParamTs31) [r11u142map pin] |
| N0133 | 10 0/10 | 5 | 6 | 10 | 4 (10) | COVERED r11u146 (N0133, r11u148share law.patch) | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) [DECODED: SHARIN |
| N0139 | 10 2/8 | 5 | 10 | 1 | 10 (1) | COVERED r11u146 (N0139) | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < emitParameters (ParamEmit.cpp, law pkgParamTsRefColons131) [r11u142m |
| N0052 | 9 9/0 | 5 | 0 | 3 | 9 (3) | COVERED r11u145 (N0052) | `fullname\|ref_obj\|tok:id.id[id]::->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNamesByPath133) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) [r11u142map pin] |
| N0084 | 8 6/2 | 4 | 0 | 50 | 8 (50) | COVERED r11u146 (N0084) | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPackedAggDimTs107) < makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) |
| N0059 | 8 6/2 | 4 | 0 | 32 | 8 (32) | COVERED r11u145 (residue: the size cast Cfg.XLEN'(1) (r11u140 R5): ours mints integer_type | `struct\|ours-only:absent\|integer_typespec\|under:ref_typespec` | emitExpr (ExprEmit.cpp, law castTgtDefaultIsLiteral) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [NOTE (r11u131 R6): the o |
| N0284 | 7 3/4 | 4 | 0 | 49 | 3 (49) | COVERED r11u146 (N0284, r11u148share law.patch) | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgUnvaluedActualLitRetFold8) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) [r11u13 |
| N0357 | 7 5/2 | 4 | 2 | 0 | 7 (0) | COVERED r11u145 (residue: process-lvalue part-select bound names (r11u140 R12, jeras_tcb_g | `fullname\|ref_obj\|tok:id.id[id - n:n].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) [r11u142map pin] |
| N0415 | 6 2/4 | 3 | 2 | 4 | 6 (4) | COVERED r11u145 (N0415) | `fullname\|ref_typespec\|tok:->.id.id\|under:constant` | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < emitModuleDefPorts (ModuleEmit.cpp, law structParamBareImportRef) [r11u142map pin] |
| N0088 | 4 4/0 | 2 | 2 | 4 | 4 (4) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|ref_obj\|line+col+endline+endcol\|under:port` | emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInterfaceDef (ModuleEmit.cpp, law modportExprPort) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) |
| N0515 | 4 2/2 | 2 | 4 | 4 | 4 (4) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|logic_net\|endline+endcol\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) [r11u142ma |
| N0525 | 4 4/0 | 2 | 2 | 2 | 4 (2) | COVERED r11u146 (residue: pc33 (v11u144 residue 3, r11u139netbind pc33_sel_index_whole)) | `fullname\|ref_obj\|tok:->id.\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpIdxOpOperandFold112) < emitModuleDefPorts (ModuleEmit.cpp, law structParamBareImportRef) [r11u142map pin] |
| N0532 | 4 4/0 | 2 | 0 | 2 | 4 (2) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|operation\|endcol\|under:port` | emitPortExprPort (ModuleEmit.cpp, law importedPkgVecPortClone) < emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitModuleDefPorts (ModuleEmit.cpp, law caNestedModDefNameScoped99) [r11u142map p |
| N0551 | 4 0/4 | 2 | 0 | 1 | 4 (1) | COVERED r11u145 (residue: stream operand after a comment / macro (r11v140 residue 3, stm/b | `span\|operation\|col+endcol\|under:cont_assign` | emitExpr (ExprEmit.cpp, law connIpsPkgParamBoundNoTs65) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) < emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) [r11u142map pin] |
| N0554 | 4 0/4 | 2 | 2 | 1 | 0 (1) | COVERED r11u146 (N0554, r11u148share law.patch) | `struct\|golden-only:fewer-copies\|constant\|under:cont_assign` | operator() (ModuleEmit.cpp, law genvarWholeCaRhsFold68) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) < operator() (ModuleEmit.cpp, law genNestedScopePkgParamNoFold24) [DECODED: SHARIN |
| N0562 | 4 4/0 | 2 | 0 | 1 | 4 (1) | COVERED r11u146 (residue: pc33 (v11u144 residue 3, r11u139netbind pc33_sel_index_whole)) | `fullname\|ref_obj\|tok:id.->\|under:bit_select` | UHDM library DeepClone < DeepCopy < DeepClone (--elabuhdm, testflags) run from main (uhdm_main.cpp) [r11u142map pin] |
| N0568 | 4 2/2 | 2 | 2 | 0 | 4 (0) | COVERED r11u146 (residue: pc31 (v11u144 residue 3, r11u139netbind pc31_bitsel_first_pos)) | `span\|bit_select\|col+endcol\|under:port` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitInstance (ModuleEmit.cpp, law elabPortConnUnitEnumNet) < operator() (ModuleEmit.cpp, law genScopeIface) [r11u142map pin] |
| N0427 | 3 3/0 | 2 | 0 | 0 | 3 (0) | COVERED r11u146 (residue: verifier face: elaborated generate-scope index reference (v11u14 | `fullname\|ref_obj\|tok:id[id].id.->\|under:bit_select` | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp, law genCaParamFoldOneHopPool95) < emitGenScopes (ModuleEmit.cpp, law genLoopUnitMiseval) |
| N0764 | 2 0/2 | 1 | 2 | 3 | 0 (1) | COVERED r11u146 (N0764, r11u148share law.patch) | `struct\|ours-only:fewer-copies\|constant\|under:ref_obj` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) [r11u142map pin] [DECODED ( |
| N0824 | 2 2/0 | 1 | 0 | 1 | 2 (1) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|port\|endline+endcol\|under:module_inst` | emitPorts (ModuleEmit.cpp, law tpDimVecPortTsIsDefault120) < emitModuleDefPorts (ModuleEmit.cpp, law caNestedModDefNameScoped99) < emitInstance (ModuleEmit.cpp, law importedFreeCallTakesFirstListingIm |
| N0825 | 2 2/0 | 1 | 0 | 1 | 2 (1) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|ref_obj\|endline+endcol\|under:port` | emitPorts (ModuleEmit.cpp, law tpDimVecPortTsIsDefault120) < emitModuleDefPorts (ModuleEmit.cpp, law caNestedModDefNameScoped99) < emitInstance (ModuleEmit.cpp, law importedFreeCallTakesFirstListingIm |
| N0276 | 2 2/0 | 1 | 0 | 0 | 2 (0) | COVERED r11u146 (residue: verifier face: definition-view generate path span (v11u144 resid | `span\|hier_path\|endcol\|under:cont_assign` | emitExpr (ExprEmit.cpp, law r10fsv2) < operator() (ModuleEmit.cpp, law genCaParamFoldOneHopPool95) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) [r11u138map pin (other example): emitSy |
| N1017 | 2 0/2 | 1 | 2 | 0 | 2 (0) | COVERED r11u146 (residue: verifier face: definition-view generate index name (v11u144 resi | `fullname\|ref_obj\|tok:id[id - n].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxAtPath79) [r11u142map pin] |
| N1064 | 2 0/2 | 1 | 0 | 0 | 2 (0) | COVERED r11u145 (residue: the cont_assign twin of r11u140 R12 (iface_scalar_localparam)) | `fullname\|ref_obj\|tok:id.id[id - n:].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) [r11u138map pin] [r11u142map pin |
| N1085 | 2 2/0 | 1 | 0 | 0 | 2 (0) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|logic_net\|line+col+endline+endcol\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) [r11u138ma |
| N1093 | 2 2/0 | 1 | 0 | 0 | 2 (0) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|port\|line+col+endline+endcol\|under:module_inst` | emitPorts (ModuleEmit.cpp, law tpDimVecPortTsIsDefault120) < emitModuleDefPorts (ModuleEmit.cpp, law caNestedModDefNameScoped99) < emitInstance (ModuleEmit.cpp, law importedFreeCallTakesFirstListingIm |
| N1098 | 2 2/0 | 1 | 0 | 0 | 2 (0) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `struct\|golden-only:absent\|logic_net\|under:ref_obj` | - |
| N1111 | 2 2/0 | 1 | 0 | 0 | 2 (0) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `file\|interface_inst\|ours-empty\|under:ref_obj` | emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < emitInstance (ModuleEmit.cpp, law bindIfaceTwinInParent46) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) [r11u138map pin] |
| N1132 | 2 2/0 | 1 | 0 | 0 | 2 (0) | COVERED r11u145 (N1132) | `fullname\|ref_typespec\|tok:id@id.id->id\|under:operation` | emitParameters (ParamEmit.cpp, law elabUnpStructOperandWidth61) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u |
| N1148 | 2 2/0 | 1 | 0 | 0 | 2 (0) | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144 R1)) | `span\|interface_inst\|ours-zero\|under:ref_obj` | emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < emitInstance (ModuleEmit.cpp, law bindIfaceTwinInParent46) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) [r11u138map pin] |
| N2385 | 2 2/0 | 1 | 2 | 0 | 2 (0) | COVERED r11u145 (residue: N0441's successor after pass 140 (DefaultPatternInt: the package | `struct\|golden-only:fewer-copies\|constant\|under:array_expr` | emitParameters (ParamEmit.cpp, law patOpMemberAsmSplit28) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) [DECODED here:  |
| N0681 | 1 1/0 | 1 | 0 | 23 | 1 (23) | COVERED r11u146 (residue: verifier face: folded call replication (v11u144 residue 4, brk/p | `span\|constant\|ours-zero\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgCondOpInstValueTernFold9) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < emitInstance (ModuleEmit.cpp, law bindIfaceTwinInParent46) |
| N1169 | 1 1/0 | 1 | 0 | 23 | 1 (23) | COVERED r11u146 (residue: verifier face: folded call formal-indexed bit select (v11u144 re | `file\|constant\|ours-empty\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgCondOpInstValueTernFold9) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < emitInstance (ModuleEmit.cpp, law bindIfaceTwinInParent46) [r11u138 |
| N0089 | 1 1/0 | 1 | 0 | 10 | 1 (10) | COVERED r11u145 (N0089) | `fullname\|ref_obj\|tok:id.id->id\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law memberActualLeak) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) |

## 4. Ranked OPEN clusters with sites

The columns:
* rows = corpus row-modes that still carry the cluster after both pairs (share measured, the rest optimistic);
* first in = row-modes the cluster heads among them;
* alone = row-modes it clears ALONE on top of both pairs;
* probe = probe cases after the share law;
* ground = the owner of the fix (section 1 item 7);
* site = the pinned mint (`function (file, nearest law) < caller < caller`) with its decoded notes.

`cluster_index.csv` holds every cluster (1518) with:
* rank; rows per corpus and probe cases, with the map-5 columns (`r11u142_coverage`, `r11u142_rows`,
  `r11u142_rows_after_p137`, `r11u142_probe*`) and `example_as_map5`;
* coverage, site, probe laws, key and example;
* `ground`, `rows_after_share`, `probe_after_share`, `rows_after_pairs`, `first_in_after_pairs` and
  `alone_on_top_of_pairs`.

One record-window file per cluster with a corpus row or >= 3 probe cases is in evidence/clusters/ (1129 files), and one
example object per cluster in evidence/objects.csv (1518). The top 45 by rows after both pairs:

| # | cluster | rows (after pairs) | sl/u2r | tests | first in | alone | probe | ground | coverage | key | example | site |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0008 | 27 | 5/22 | 14 | 18 | 4 | 23 | B | OPEN (residue of r11u144: its brief named it, still present) | `fullname\|ref_typespec\|golden-empty\|under:constant` | uhdm2rtlil/testflags/LocalParamInNestedForLoops #70/70 ref_typespec '' golden= ours=work@top | operator() (ModuleEmit.cpp, law genLpFoldDigitsMathValue18) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) < operator() (ModuleEmit.cpp, law genNestedScopePkgParamNoFold24) [r11u138map pin (other example): emitParameters (ParamEmit.cpp, law time |
| 2 | N0017 | 26 | 6/20 | 13 | 0 | 0 | 5 | B | OPEN | `span\|constant\|endline+endcol\|under:sys_func_call` | surelog/testflags/CovMacro #103/103 constant '' golden=12:31:12:32 ours=12:31:0:0 | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [DECODED (r11u131 R7): CovMacro's predefined SV_COV_* constants end at 0:0; the macro line mo |
| 3 | N0012 | 23 | 11/12 | 12 | 14 | 0 | 5 | A | OPEN | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | uhdm2rtlil/testflags/TypeParameterAsPortTypeWithEnumOfParametrizedWidth #62/62 enum_typespec 'state_ | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInstance (ModuleEmit.cpp, law elabParamTsRebind) [DECODED (r11u130 R1): the type-parameter override by a module-local enum typedef; ParamEm |
| 4 | N0026 | 20 | 0/20 | 10 | 0 | 0 | 10 | B | OPEN | `span\|constant\|line+endline\|under:sys_func_call` | uhdm2rtlil/testflags/ibex_csr #54/54 constant '' golden=29:10:29:51 ours=32:10:32:51 | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol] [r11u142map pin] |
| 5 | N0027 | 20 | 0/20 | 10 | 4 | 0 | 8 | B | OPEN | `span\|sys_func_call\|line+endcol\|under:begin` | uhdm2rtlil/testflags/ibex_csr #53/53 sys_func_call '$error' golden=29:3:33:27 ours=32:3:33:18 | emitExpr (ExprEmit.cpp, law sysCallKwTypeArgNameSpan131) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) < emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) [DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol] [ |
| 6 | N0029 | 20 | 0/20 | 10 | 0 | 0 | 0 | B | OPEN | `span\|sys_func_call\|line+endline\|under:sys_func_call` | uhdm2rtlil/testflags/ibex_csr #55/55 sys_func_call '$time' golden=29:53:29:58 ours=32:53:32:58 | emitExpr (ExprEmit.cpp, law sysCallKwTypeArgNameSpan131) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [DECODED (r11u131 R7): the macro line model, UhdmExporter.cpp locLineCol] [r11u1 |
| 7 | N0054 | 15 | 15/0 | 8 | 4 | 0 | 3 | A | OPEN (residue of r11u140: map 5 named it, still present) | `span\|assignment\|endcol\|under:begin` | surelog/testflags/CovMacro #101/101 assignment '' golden=12:9:12:52 ours=12:9:12:86 | emitStmt (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) [r11u142map pin] |
| 8 | N0075 | 13 | 13/0 | 7 | 2 | 0 | 8 | B | OPEN | `span\|enum_typespec\|line+col+endline+endcol\|under:package` | surelog/testflags/FuncCase #2/2 enum_typespec 'fpnew_pkg::opgroup_e' golden=7:46:7:55 ours=2:1:4:15 | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u142map pin] |
| 9 | N0034 | 13 | 9/4 | 7 | 0 | 0 | 5 | A | OPEN | `span\|enum_typespec\|ours-zero\|under:ref_typespec` | uhdm2rtlil/testflags/TypeParameterAsPortTypeWithEnumOfParametrizedWidth #62/62 enum_typespec 'state_ | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInstance (ModuleEmit.cpp, law elabParamTsRebind) [DECODED (r11u130 R1): the span face of N0012, same site] [r11u142map pin] |
| 10 | N0080 | 13 | 13/0 | 7 | 2 | 0 | 1 | B | OPEN | `span\|struct_typespec\|line+col+endline+endcol\|under:package` | surelog/default/FuncStructValSimple #298/298 struct_typespec 'config_pkg::cva6_user_cfg_t' golden=38 | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u142map pin] |
| 11 | N0050 | 13 | 13/0 | 7 | 0 | 0 | 0 | A | OPEN (residue of r11u140: map 5 named it, still present) | `span\|operation\|col+endcol\|under:assignment` | surelog/testflags/MacroArgMismatch #15/15 operation '' golden=5:13:5:15 ours=5:14:5:16 | emitExpr (ExprEmit.cpp, law connIpsPkgParamBoundNoTs65) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin] |
| 12 | N0083 | 12 | 2/10 | 6 | 0 | 0 | 41 | B | OPEN | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec` | surelog/testflags/LogicTypespec #15/-1 range '' golden=3 objs ours= | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmit.cpp, law ifaceIfaceTypedPort) [r11u138map pin] [r11u142map pin] |
| 13 | N0086 | 12 | 4/8 | 6 | 2 | 0 | 20 | A | OPEN | `file\|constant\|golden-empty\|under:typespec_member` | uhdm2rtlil/testflags/struct_param_field_shift #75/75 constant '' golden= 0:0:0:0 ours=dut.sv 20:33:2 | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) [r11u142map pin] |
| 14 | N0087 | 12 | 4/8 | 6 | 0 | 0 | 20 | A | OPEN | `span\|constant\|golden-zero\|under:typespec_member` | uhdm2rtlil/testflags/struct_param_field_shift #75/75 constant '' golden=0:0:0:0 ours=20:33:20:49 | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) [r11u142map pin] |
| 15 | N0060 | 12 | 8/4 | 7 | 0 | 0 | 3 | A | OPEN (residue of r11u140: map 5 named it, still present) | `span\|operation\|col+endcol\|under:operation` | surelog/default/BlackConst #761/761 operation '' golden=10:103:10:131 ours=10:65:10:93 | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < operator() (ExprEmit.cpp, law pkgTdCloneRefNoBind18) < emitExpr (ExprEmit.cpp, law pkgTdCloneRefNoBind18) [r11u142map pin] |
| 16 | N0092 | 12 | 2/10 | 6 | 2 | 0 | 0 | B | OPEN | `value\|constant\|value:UINT->UINT\|under:range` | surelog/default/UnionCast #179/179 constant '' golden=00\|64\|UINT:00\|9 ours=00\|64\|UINT:0\|9 | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabSize113) < buildStructTs (TypeEmit.cpp, law pkgTdRangeViewFold18) [r11u142map pin] |
| 17 | N0142 | 12 | 12/0 | 7 | 0 | 0 | 0 | A | OPEN (map 5 routed it to r11u140 as a residue; still present | `struct\|golden-only:fewer-copies\|range\|under:array_typespec` | surelog/default/BuildUVMPkg #118186/-1 range '' golden=5 objs ours= | makeUnpackedArrayParamTs (ParamEmit.cpp, law pkgParamTsRef) < emitParameters (ParamEmit.cpp, law importElemBareTdAlias) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) [DECODED (pass-133 R6, measured here): grew 10 -> 44 row-modes sinc |
| 18 | N0103 | 11 | 11/0 | 6 | 2 | 2 | 7 | B | OPEN | `name\|class_typespec\|ours-empty\|under:ref_typespec` | surelog/testflags/ArrayMethodIterator #17/17 class_typespec 'uvm_callback' golden=uvm_callback\| our | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) [r11u142map pin] |
| 19 | N0094 | 11 | 11/0 | 6 | 0 | 0 | 58 | B | OPEN | `span\|constant\|line+col+endline+endcol\|under:range` | surelog/testflags/GenForStructParamBound #351/351 constant '' golden=10:39:10:40 ours=13:16:13:27 | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabSize113) < emitInterfaceInstance (ModuleEmit.cpp, law ifacePortViewAggregateFlattens) [r11u142map pin] |
| 20 | N0040 | 11 | 9/2 | 6 | 2 | 0 | 34 | B | OPEN | `span\|logic_typespec\|endcol\|under:ref_typespec` | surelog/default/InterfaceModPort #95/95 logic_typespec '' golden=27:3:27:8 ours=27:3:27:21 | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLocalsRideTheImport203) < emitInterfaceDef (ModuleEmit.cpp, law interfaceDefViewNeverLateBinds223v) [r11u142map pin] |
| 21 | N0095 | 11 | 11/0 | 6 | 0 | 0 | 25 | A | OPEN | `fullname\|ref_obj\|tok:id.id::->\|under:method_func_call` | surelog/default/SVSwitch #101/101 ref_obj 'bytes' golden=work@Driver::start::pkt.byte_pack::bytes ou | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) [r11u142map pin] |
| 22 | N0100 | 11 | 11/0 | 6 | 0 | 0 | 11 | B | OPEN | `span\|bit_typespec\|line+col+endline+endcol\|under:ref_typespec` | surelog/default/ApbSlave #539/543 bit_typespec '' golden=58:19:58:22 ours=129:10:129:13 | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) |
| 23 | N0104 | 11 | 11/0 | 6 | 0 | 0 | 7 | B | OPEN | `span\|bit_var\|line+col+endline+endcol\|under:function` | surelog/default/ApbSlave #537/541 bit_var '' golden=58:19:58:22 ours=129:10:129:13 | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) |
| 24 | N0105 | 11 | 11/0 | 6 | 0 | 0 | 7 | B | OPEN | `span\|string_var\|line+col+endline+endcol\|under:function` | surelog/default/ApbSlave #449/453 string_var '' golden=44:19:44:25 ours=68:10:68:16 | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) |
| 25 | N0106 | 11 | 11/0 | 6 | 0 | 0 | 7 | B | OPEN | `file\|class_var\|golden-empty\|under:function` | surelog/default/ApbSlave #442/446 class_var '' golden= 0:0:0:0 ours=svunit_base.sv 59:34:59:38 | emitTaskFuncs (TaskFuncEmit.cpp, law methodSpanSkipsAttrs144) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) |
| 26 | N0107 | 11 | 11/0 | 6 | 0 | 0 | 7 | B | OPEN | `span\|class_var\|golden-zero\|under:function` | surelog/default/ApbSlave #442/446 class_var '' golden=0:0:0:0 ours=59:34:59:38 | emitTaskFuncs (TaskFuncEmit.cpp, law methodSpanSkipsAttrs144) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) |
| 27 | N0109 | 11 | 9/2 | 6 | 0 | 0 | 6 | A | OPEN | `file\|string_typespec\|ours-empty\|under:ref_typespec` | uhdm2rtlil/testflags/SelectFromUnpackedInFunction #59/59 string_typespec 'default' golden=dut.sv 6:3 | emitExpr (ExprEmit.cpp, law r10fsv2) < emitExpr (ExprEmit.cpp, law shellCallKeepsItsSyntax167) < emitExpr (ExprEmit.cpp, law r10fsv2) [r11u142map pin] |
| 28 | N0110 | 11 | 9/2 | 6 | 0 | 0 | 6 | A | OPEN | `span\|string_typespec\|ours-zero\|under:ref_typespec` | uhdm2rtlil/testflags/SelectFromUnpackedInFunction #59/59 string_typespec 'default' golden=6:39:6:46  | emitExpr (ExprEmit.cpp, law r10fsv2) < emitExpr (ExprEmit.cpp, law shellCallKeepsItsSyntax167) < emitExpr (ExprEmit.cpp, law r10fsv2) [r11u142map pin] |
| 29 | N0111 | 11 | 11/0 | 6 | 0 | 0 | 4 | A | OPEN | `span\|constant\|line+col+endline+endcol\|under:io_decl` | surelog/default/ApbSlave #556/560 constant '' golden=58:83:58:85 ours=129:91:129:93 | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitTaskFuncs (TaskFuncEmit.cpp, law classArgBind12) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) |
| 30 | N0112 | 11 | 11/0 | 6 | 0 | 0 | 3 | A | OPEN | `span\|hier_path\|endcol\|under:sys_func_call` | surelog/default/SVSwitch #1193/1193 hier_path 'this.fcs' golden=130:83:130:91 ours=130:83:130:87 | emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [r11u142map pin] |
| 31 | N0113 | 11 | 11/0 | 6 | 0 | 0 | 3 | A | OPEN | `span\|bit_select\|col+endcol\|under:bit_select` | surelog/default/BuildUVMPkg #17385/17383 bit_select 'm_sync' golden=35130:21:35130:22 ours=35130:14: | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law genLpIdxOpOperandFold112) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) [r11u142map pin] |
| 32 | N0114 | 11 | 11/0 | 6 | 2 | 0 | 2 | B | OPEN | `file\|hier_path\|golden-empty\|under:foreach_stmt` | surelog/testflags/LocalScopeHierPath #81/81 hier_path '' golden= 0:0:0:0 ours=dut.sv 18:14:18:25 | UHDM library DeepClone < DeepCopy < DeepClone (--elabuhdm, testflags) run from main (uhdm_main.cpp) [r11u142map pin] |
| 33 | N0115 | 11 | 11/0 | 6 | 0 | 0 | 2 | B | OPEN | `span\|hier_path\|golden-zero\|under:foreach_stmt` | surelog/testflags/LocalScopeHierPath #81/81 hier_path '' golden=0:0:0:0 ours=18:14:18:25 | UHDM library DeepClone < DeepCopy < DeepClone (--elabuhdm, testflags) run from main (uhdm_main.cpp) [r11u142map pin] |
| 34 | N0116 | 11 | 11/0 | 6 | 0 | 0 | 2 | B | OPEN | `span\|class_typespec\|col+endcol\|under:ref_typespec` | surelog/testflags/ClassTypeParam #11/11 class_typespec 'uvm_object' golden=20:22:20:43 ours=20:24:20 | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) [r11u142map pin] |
| 35 | N0117 | 11 | 11/0 | 6 | 2 | 0 | 2 | B | OPEN | `span\|unsupported_typespec\|endcol\|under:ref_typespec` | surelog/testflags/CrossFunc #70/70 unsupported_typespec 'cg' golden=24:2:24:21 ours=24:2:24:22 | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < emitTopPorts (ModuleEmit.cpp, law tpDimVecPortTsIsDefault120) [r11u142map pin] |
| 36 | N0079 | 11 | 9/2 | 6 | 0 | 0 | 1 | A | OPEN (residue of r11u140: map 5 named it, still present) | `span\|constant\|line+endline\|under:operation` | surelog/testflags/BlackConst #274/274 constant '' golden=9:22:9:23 ours=154:22:154:23 | emitBadConcatOperand160 (ExprEmit.cpp, law typeParamScopedCallRef59) < emitBadConcatFromSyntax160 (ExprEmit.cpp, law classArgBind12) < emitExpr (ExprEmit.cpp, law droppedIdxRecvCall26) [r11u142map pin] |
| 37 | N0118 | 11 | 11/0 | 6 | 0 | 0 | 1 | A | OPEN | `span\|constant\|line+col+endline+endcol\|under:operation` | surelog/default/BuildUVMPkg #85255/85210 constant '' golden=52368:59:52368:60 ours=53120:62:53120:63 | emitBadConcatOperand160 (ExprEmit.cpp, law typeParamScopedCallRef59) < emitBadConcatFromSyntax160 (ExprEmit.cpp, law classArgBind12) < emitExpr (ExprEmit.cpp, law droppedIdxRecvCall26) [r11u142map pin] |
| 38 | N0119 | 11 | 11/0 | 6 | 0 | 0 | 1 | A | OPEN | `span\|bit_select\|col+endcol\|under:assignment` | surelog/default/SVSwitch #264/264 bit_select 'rcvr' golden=43:11:43:12 ours=43:6:43:13 | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) < emitExpr (ExprEmit.cpp, law shellCallKeepsItsSyntax167) [r11u142map pin] |
| 39 | N0120 | 11 | 11/0 | 6 | 0 | 0 | 1 | B | OPEN | `span\|enum_var\|line+col+endline+endcol\|under:function` | surelog/default/ApbSlave #453/457 enum_var '' golden=45:19:45:28 ours=87:10:87:19 | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallBinds12) < emitPackageClasses (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) |
| 40 | N0121 | 11 | 9/2 | 6 | 0 | 0 | 0 | B | OPEN | `file\|enum_typespec\|other-file+span\|under:ref_typespec` | uhdm2rtlil/testflags/ibex_pmp #6922/6922 enum_typespec 'ibex_pkg::priv_lvl_e' golden=ibex_pmp.sv 132 | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| 41 | N0125 | 11 | 11/0 | 6 | 2 | 0 | 0 | A | OPEN | `span\|case_item\|endcol\|under:case_stmt` | surelog/default/YosysRiscv #205/205 case_item '' golden=60:5:60:30 ours=60:5:60:31 | emitStmt (StmtEmit.cpp, law castOperandNeverBindsInCondWindow164) < emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitStmt (StmtEmit.cpp, law castOperandNeverBindsInCondWindow164) [r11u142map pin] |
| 42 | N0045 | 10 | 8/2 | 5 | 2 | 2 | 12 | A | OPEN | `struct\|golden-only:fewer-copies\|constant\|under:typespec_member` | surelog/default/StructParamPatternInitCast #77/-1 constant '' golden=1 objs ours= | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < main (uhdm_main.cpp, law genCaPatKeepTagDefView121) [DECODED: golden lists the member default constant twice (a copy under  |
| 43 | N0127 | 10 | 10/0 | 6 | 0 | 0 | 79 | B | OPEN | `span\|array_typespec\|endcol\|under:ref_typespec` | surelog/default/BuildUVMPkg #9050/9050 array_typespec '' golden=20517:11:20517:14 ours=20517:11:2051 | makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDimOvrChain4) < emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitModuleDefPorts (ModuleEmit.cpp, law caNestedModDefNameScoped99) [r11u142map pin] |
| 44 | N0128 | 10 | 10/0 | 6 | 0 | 0 | 69 | B | OPEN | `span\|range\|col+endcol\|under:array_typespec` | surelog/default/BuildUVMPkg #162458/162402 range '' golden=28180:60:28180:61 ours=28180:59:28180:62 | operator() (ModuleEmit.cpp, law sizeDimOvrChain4) < makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDimOvrChain4) < emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) [r11u142map pin] |
| 45 | N0131 | 10 | 10/0 | 5 | 0 | 0 | 17 | A | OPEN | `fullname\|ref_typespec\|ours-empty\|under:constant` | surelog/default/FuncStructValSimple #129/129 ref_typespec '' golden=cva6_config_pkg ours= | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law negLitPkgRetFoldNested30) < emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) [r11u142map pin] |

The fail list after the pairs is dominated by a few row families, each carrying dozens to hundreds of clusters
(evidence/row_families.txt):
* the UVM rows: BuildUVMPkg, MiniAmiq, Scoreboard, SeqDriver, SimpleUVM, ApbSlave;
* Earlgrey_0_1, Rggen, Scr1SvTests, BlackBePipeInt, YosysOldOr;
* the ibex rows: 10 uhdm2rtlil tests share the macro-line clusters N0017, N0026, N0027 and N0029.

These rows clear only with whole families. **The rows that can clear are the 167 with 1-3 open clusters
(evidence/near_rows.txt), and the per-ground briefs in section 7 are built from them.**

Probe-only OPEN clusters with the most cases:
* N1897 (119; `work@sub.work@sub::innermod.i`-shaped net names, ModuleEmit emitModuleDef);
* N1898 (92);
* N1899 (52);
* N1900 (50);
* N1901 (45);
* N1902 (37, ground A);
* N1903 and N1904 (21 and 20, ParamEmit memLeftPatParamClone26).

### The first clusters (what the gate names first on each failing row, at 98aa49db)

| first cluster | row-modes it heads | after share | after both pairs | ground | coverage | key | site |
|---|---|---|---|---|---|---|---|
| N0001 | 20 | 20 | 0 | A | COVERED r11u145 (N0001) | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [ |
| N0008 | 18 | 18 | 18 | B | OPEN (residue of r11u144: its brief named it, still present) | `fullname\|ref_typespec\|golden-empty\|under:constant` | operator() (ModuleEmit.cpp, law genLpFoldDigitsMathValue18) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) < operator() (ModuleEmit.cpp, law genNestedScopePkgParamNo |
| N0064 | 14 | 14 | 0 | B | COVERED r11u146 (N0064) | `span\|include_file_info\|line+endline\|under:design` | emitIncludeFileInfos (UhdmExporter.cpp, law includeInactiveTabNotText141v) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareElab) < main (uhdm_main.cpp, law genCaPatKeepTagDe |
| N0012 | 14 | 14 | 14 | A | OPEN | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInstance (ModuleEmit.cpp, law elabParamTsRebind) [DECODED ( |
| N0139 | 10 | 10 | 0 | B | COVERED r11u146 (N0139) | `fullname\|ref_typespec\|tok:id::id::id::->id@id.id.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < emitParameters (ParamEmit.cpp, law pkgParamTsRef |
| N0044 | 10 | 10 | 0 | B | COVERED r11u146 (N0044) | `span\|struct_typespec\|endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitTopPorts (ModuleEmit.cpp, law defNetTsScope) [DECOD |
| N0076 | 9 | 9 | 0 | A | COVERED r11u145 (N0076) | `fullname\|ref_obj\|tok:id.->\|under:part_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < operator() (ModuleEmit.cpp, law genCaTernaryFoldGenScope22) [r11u142 |
| N0005 | 8 | 8 | 0 | A | COVERED r11u145 (N0005) | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) [r11u142map pin] |
| N0030 | 8 | 8 | 0 | B | COVERED r11u146 (N0030) | `fullname\|ref_obj\|tok:id.->\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law structParamPathBaseAtMember137) < operator() (ModuleEmit.cpp, law connOperandOwnScopeB |
| N0003 | 8 | 8 | 0 | A | COVERED r11u145 (residue: ParamNoImport / StructParamPattern | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.cpp, law caUnelabBodyCh |
| N0149 | 8 | 8 | 8 | B | OPEN | `file\|struct_typespec\|other-file\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u142map pin] |
| N0056 | 6 | 6 | 0 | A | COVERED r11u145 (N0056) | `span\|bit_typespec\|endcol\|under:ref_typespec` | makeParamTs (ParamEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law pkgParamTsRefColons131) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206 |
| N0433 | 6 | 6 | 6 | B | OPEN | `file\|packed_array_typespec\|golden-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < buildUnionTs (TypeEmit.cpp, law pkgTdRangeViewFold18) < exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParam |
| N0009 | 6 | 6 | 0 | B | COVERED r11u146 (N0009) | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow |
| N0090 | 6 | 6 | 6 | B | OPEN | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < exportDesign (UhdmExporter.cpp, law import |
| N2384 | 6 | 6 | 6 | A | OPEN (new since r11u142map) | `struct\|ours-only:elsewhere\|constant\|under:typespec_member` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [ |
| N0133 | 6 | 0 | 0 | B | COVERED r11u146 (N0133, r11u148share law.patch) | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < exportDesign (UhdmExporter.cpp, law dottedTopNameBareEl |
| N0455 | 5 | 5 | 5 | A | OPEN | `span\|assignment\|line+col+endline+endcol\|under:initial` | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) < emitProcess (StmtEmit.cpp, law classPropUnitImport21) [r11 |
| N0627 | 4 | 4 | 4 | B | OPEN | `fullname\|property_decl\|tok:id.id.id->id\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDefVi |
| N0054 | 4 | 4 | 4 | A | OPEN (residue of r11u140: map 5 named it, still present) | `span\|assignment\|endcol\|under:begin` | emitStmt (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitClassDefn (UhdmExporter.cpp, law e |
| N0011 | 4 | 4 | 4 | B | OPEN | `file\|logic_net\|golden-empty\|under:ref_obj` | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cpp, law hoistedThisRidesTheForwardedBlock219) < main (uhdm_main.cpp, la |
| N0655 | 4 | 4 | 4 | B | OPEN | `name\|enum_typespec\|tok:id->id\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u142map pin] |
| N0515 | 4 | 4 | 0 | B | COVERED r11u146 (residue: PortExpr / ExplictiPorts (r11u144  | `span\|logic_net\|endline+endcol\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeepTagDe |
| N0043 | 4 | 4 | 0 | B | COVERED r11u146 (N0043) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow |
| N0274 | 4 | 4 | 4 | B | OPEN | `fullname\|ref_obj\|golden-empty@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < typeParamDefaultBound20 (TypeEmit.cpp, law crossPkgRangeBoundFold) |
| N0027 | 4 | 4 | 4 | B | OPEN | `span\|sys_func_call\|line+endcol\|under:begin` | emitExpr (ExprEmit.cpp, law sysCallKwTypeArgNameSpan131) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) < emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoSt |
| N0472 | 4 | 4 | 4 | B | OPEN | `fullname\|ref_obj\|tok:id->id.id@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < typeParamDefaultBound20 (TypeEmit.cpp, law crossPkgRangeBoundFold) |
| N0407 | 4 | 4 | 4 | A | OPEN | `span\|constant\|line+col+endline+endcol\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitInstance (ModuleEmit.cpp, law elabPara |
| N0536 | 4 | 4 | 4 | A | OPEN | `fullname\|ref_typespec\|tok:id.id->id\|under:constant` | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) < emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) [r |
| N0103 | 2 | 2 | 2 | B | OPEN | `name\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExporter.cpp, law externProtoInBodyCallB |

## 5. The structural rows (first field depth / type / count) after passes 140/144 and r11u148's decode

At 98aa49db: **24 row-modes in 12 tests** (depth 16, type 8, count 0). **After the share law (measured): 14 row-modes
in 7 tests. After both pairs: 12 row-modes in 6 tests** (evidence/structural.txt, classed by first cluster with
r11u148share's letters):

| class | at 98aa49db | after share (measured) | after both pairs | first cluster | rows | what each still needs |
|---|---|---|---|---|---|---|
| E. func_call kept (r11u148 E) | 6 (3) | **0** | 0 | N0133 | FunctionParam, SelectGivenBySelectOnParameterInFunction, func_local_array d/t | cleared by the share law (evalFuncSelectKeepsCall148) |
| E2. gen-scope UINT own copy | 2 (1) | **0** | 0 | N0554 | SumOfParametersInNestedForLoops d/t | cleared by the share law (genLpUintCaRhsOwnCopy148) |
| I. signature range binding | 2 (1) | **0** | 0 | N0764 | simple_package d/t | cleared by the share law (pkgTfSigRangeTopViewConst148) |
| **D2. the swapped cast targets** | 6 (3) | 6 | 6 | N2384 (+ N2383) | def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot d/t | **D2 alone clears all 6**: open after the pairs = N2383 + N2384 only. Bind the definition listing's deferred cast to the definition package's typedef (ParamEmit drainShareDefParamTs, law pkgTypedefCastTargetTs140; the member stamps of stampEvalFuncLeftovers then land on golden's copy) |
| **D. the operation-valued member default** | 2 (1) | 2 | 2 | N0045 | StructParamFuncBodyFieldCompare d/t | D (N0045) + the hier_path records under golden's unreduced Flag operation (N0756, N0758, N0759: depth and full names inside the stamped operation). D alone is StructParamPatternInitCast's last open cluster after the pairs (+2 row-modes) |
| **G. the kept concatenation** | 2 (1) | 2 | 2 | N0724 | BlackParrotComplex d/t | G (N0724) + N1129 (the array_typespec reference name under the shared value) |
| **ARR. the procedural var_select binding** | 2 (1) | 2 | 2 | N0046 | array_assign d/t | **ARR alone** (N0046 is the only open cluster) |
| C2. the default fill | 2 (1) | 2 | **0** (optimistic) | N2385 | DefaultPatternInt d/t | N0441's successor (routed to pair A): pass 140's `defaultFillOneConstant140` made it one constant; golden keeps one per element when the declaration is in a PACKAGE |
| C3. port connection operation span (r11u148 C3) | 0 structural | — | — | N0417 + N0534 | StructArray... / NestedStructArray...PassedAsPort d/t (`line(2)` / `fullname(4)`) | not structural since pass 140; **N0417 + N0534 alone clear all 4** (the port high_conn copy relocated to the actual's span, named without the doubled instance) |

Class B (typedef alias) and C (imported-parameter clone) left with passes 134 and 133; C3's array-typespec face left
with pass 140 (impLhsCloneArrayTsOwnCopy140); F (the type-parameter definition net) left with pass 137. **The
twelve structural row-modes left after both pairs need D2 (6), D (2 + N0756/N0758/N0759), G (2 + N1129) and ARR (2):
all four are r11u148's pair-A decodes, none is in r11u145's brief.**

## 6. Probe cases by law

1779 NE cases sit in 920 clusters (probe_clusters.csv: case, law, first field, cluster, objects; laws from
scripts/law_index.py). **299 clear with the pairs**: 2 measured, the rest optimistic, leaving 1480.

Laws with the most NE cases:
* loopCaParamReadKeepsLiteral116 84 of 123;
* badConcatOperandsFromSyntax160 71/71;
* tpElemRebindElabPort110 57/61;
* nestedGenProcLhsKeepsRef116 46/74;
* portViewRangeRecvParams 45/55;
* tpPackedArrayTsVar108 43/73;
* pvExprDefaultFold115 43/50;
* caNestedModPortedDefShell101 36/38;
* srlgCondOpInstValueTernFold9 32/140;
* nestedParamActualTs6 29/41.

Probe-heavy clusters:
* N0039 (219; pair B, int_typespec declaration-vs-use span);
* N0005 (163; pair A);
* N1897 (119);
* N1898 (92);
* N0151 (84);
* N0127 (79);
* N0470 (77);
* N0044 (73; pair B);
* N0152 and N0153 (71 each);
* the port-view range family N0128, N0680, N0262, N0737, N0736 (68-69 each).

## 7. Recommended next briefs per ground

**The single-cluster greedy stalls.** Computed on top of both pairs (share measured, the rest optimistic;
evidence/report.txt section 6), it gains 4, 2, 2, ... row-modes and then 0 from step 10 (A) and step 19 (B), because
most remaining rows need two or more clusters fixed at once. The briefs below come from `drivers/greedy_sets.py`
instead (evidence/greedy_sets.txt). A candidate there is the whole open-cluster set of one remaining row whose open
clusters all belong to one ground, and the greedy picks by row-modes cleared per cluster added. The base is 71
row-modes / 35 tests cleared by the two live pairs.

**Ground A: expression/parameter (ExprEmit/EmitHelpers/StmtEmit/ParamEmit). The refill after r11u145.**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0077 | 4 | 75 | 37 | GenForIfaceLocalparamBound/d GenForIfaceLocalparamNestedGen/d GenForIfaceLocalparamBound/t GenForIfaceLocalparamNestedGen/t | `fullname\|ref_obj\|tok:id.id[id].->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) [r11u138map pi |
| 2 | N2383 + N2384 | 6 | 81 | 40 | def_ctx_struct_param/d/u2r latch_decoder_partial/d/u2r latch_tlb_napot/d/u2r def_ctx_struct_param/t/u2r latch_decoder_partial/t/u2r latch_tlb_napot/t/u2r | `struct\|golden-only:elsewhere\|constant\|under:typespec_member`; `struct\|ours-only:elsewhere\|constant\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesign (UhdmExporter.cpp, law caUnel |
| 3 | N0455 + N0456 | 5 | 86 | 43 | PortInitVal/d PortInitVal2/d PortInitVal2/t sat_asserts_seq/d/u2r sat_asserts_seq/t/u2r | `span\|assignment\|line+col+endline+endcol\|under:initial`; `span\|ref_obj\|line+col+endline+endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) < emitProcess (StmtEmit.cpp, law classPropUnitImpo |
| 4 | N0417 + N0534 | 4 | 90 | 45 | NestedStructArrayParameterInitializedByPatternPassedAsPort/d/u2r StructArrayParameterInitializedByPatternPassedAsPort/d/u2r NestedStructArrayParameterInitializedByPatternPassedAsPort/t/u2r StructArrayParameterInitializedByPatternPassedAsPort/t/u2r | `span\|operation\|line+col+endline+endcol\|under:port`; `fullname\|ref_typespec\|tok:->id.\|under:operation` | foldUnpackedStructArrayPattern (ParamEmit.cpp, law unpackedStructArrPatOneElemFold) < emitInstance (ModuleEmit.cpp, law genConnIdxFoldConnOnly21) < emitInstance (ModuleEm |
| 5 | N0045 | 2 | 92 | 46 | StructParamPatternInitCast/d StructParamPatternInitCast/t | `struct\|golden-only:fewer-copies\|constant\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < main (uhdm_main.cpp, law genCaPat |
| 6 | N0286 | 2 | 94 | 47 | comb_dyn_2d_packed_sel/d/u2r comb_dyn_2d_packed_sel/t/u2r | `struct\|ours-only:fewer-copies\|ref_obj\|under:int_typespec` | emitExpr (ExprEmit.cpp, law castTgtDefaultIsLiteral) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < operator() (ExprEmit.cpp, law pkgTdCloneRefNoBind18) [r1 |
| 7 | N0046 | 2 | 96 | 48 | array_assign/d/u2r array_assign/t/u2r | `struct\|ours-only:fewer-copies\|logic_net\|under:ref_obj` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPa |
| 8 | N1053 | 2 | 98 | 49 | latch_packed_dyn_write/d/u2r latch_packed_dyn_write/t/u2r | `fullname\|bit_select\|tok:id.->\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) [r11u142 |
| 9 | N1063 | 2 | 100 | 50 | iface_struct_field_partsel/d/u2r iface_struct_field_partsel/t/u2r | `fullname\|ref_obj\|tok:id.id.id[id - n:].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) [r |
| 10 | N1118 | 2 | 102 | 51 | genscope_module_ctx_reset/d/u2r genscope_module_ctx_reset/t/u2r | `fullname\|part_select\|tok:id.->\|under:port` | emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47) < emitInstance (ModuleEmit.cpp, law elabPortConnUnitEnumNet) < operator() (ModuleEmit.cpp, law genScopeIface) [r11u |
| 11 | N0820 | 2 | 104 | 52 | anon_struct_packed_dim/d/u2r anon_struct_packed_dim/t/u2r | `fullname\|ref_obj\|tok:id[id].id[n - id][n:n].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) [r |
| 12 | N0471 + N0702 | 2 | 106 | 53 | multiplier/d/u2r multiplier/t/u2r | `fullname\|ref_typespec\|tok:.id[n]->\|under:constant`; `fullname\|ref_typespec\|tok:.id[n].id.id->\|under:constant` | emitExpr (ExprEmit.cpp, law loopCaParamReadKeepsLiteral116) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < operator() (ModuleEmit.cpp, law genCaTernaryFoldG |
| 13 | N0006 + N0765 | 2 | 108 | 54 | StringMethod/d StringMethod/t | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj`; `fullname\|ref_obj\|tok:id.id.->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < emitContAssigns (ModuleEmit.cpp, law caLhsDefNetUnlessOpRhs |
| 14 | N0833 + N1067 | 2 | 110 | 55 | iface_arr_struct_field_partsel/d/u2r iface_arr_struct_field_partsel/t/u2r | `fullname\|bit_select\|tok:id.->\|under:hier_path`; `fullname\|ref_obj\|tok:id.id[n].id[id(id) - n:n].id.->\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law hpConnElemIdxFold17) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) < emitModuleDef (ModuleEmit.cpp, law shadowedImportPara |
| 15 | N0394 + N1140 | 2 | 112 | 56 | PatternStruct/d/u2r PatternStruct/t/u2r | `file\|constant\|ours-empty\|under:operation`; `span\|constant\|ours-zero\|under:operation` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < emitContAssigns (ModuleEmit.cpp, law caIfaceElabNetDeclAssignListing88) < emitInstance (ModuleEmit.cpp, law e |
| 16 | N0724 + N1129 | 2 | 114 | 57 | BlackParrotComplex/d BlackParrotComplex/t | `struct\|ours-only:absent\|constant\|under:param_assign`; `fullname\|ref_typespec\|tok:.id->\|under:array_typespec` | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator() (ParamEmit.cpp, law castElabFoldTargetKinds) < emitParameters (ParamEmit.cpp, law castElabFoldTarg |
| 17 | N0739 | 1 | 115 | 57 | ComplexParamOverload/t | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall92) < emitModuleDef (ModuleEmit.cpp, law shadowedImport |
| 18 | N0050 + N1075 + N1076 | 2 | 117 | 58 | MacroArgMismatch/d MacroArgMismatch/t | `span\|operation\|col+endcol\|under:assignment`; `span\|always\|endcol\|under:module_inst`; `span\|assignment\|endcol\|under:event_control` | emitExpr (ExprEmit.cpp, law connIpsPkgParamBoundNoTs65) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtC |
| 19 | N0756 + N0758 + N0759 | 2 | 119 | 59 | StructParamFuncBodyFieldCompare/d StructParamFuncBodyFieldCompare/t | `depth\|ref_obj\|hier_path->hier_path`; `depth\|hier_path\|operation->integer_typespec`; `fullname\|ref_obj\|tok:id@id.id.id::id.id.->id::id::\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law castTgtDefaultIsLiteral) < emitExpr (ExprEmit.cpp, law r10fsv2) [r11u138map pin] [r |
| 20 | N0109 + N0110 + N1114 + N1159 | 2 | 121 | 60 | SelectFromUnpackedInFunction/d/u2r SelectFromUnpackedInFunction/t/u2r | `file\|string_typespec\|ours-empty\|under:ref_typespec`; `span\|string_typespec\|ours-zero\|under:ref_typespec`; `file\|tagged_pattern\|ours-empty\|under:operation`; `span\|tagged_pattern\|ours-zero\|under:operation` | emitExpr (ExprEmit.cpp, law r10fsv2) < emitExpr (ExprEmit.cpp, law shellCallKeepsItsSyntax167) < emitExpr (ExprEmit.cpp, law r10fsv2) [r11u142map pin] |
| 21 | N0054 + N0460 + N0561 + N0823 | 2 | 123 | 61 | YosysMarlann/d YosysMarlann/t | `span\|assignment\|endcol\|under:begin`; `span\|begin\|col\|under:if_stmt`; `span\|operation\|endcol\|under:operation`; `span\|operation\|endcol\|under:assignment` | emitStmt (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitClassDefn (UhdmExporter. |

ground A: the 39 clusters above clear 52 row-modes on top of the pairs (123 with them).

**Ground B: module/type (TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main). The refill after r11u146.**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0008 | 4 | 75 | 37 | LocalParamInNestedForLoops/d/u2r ibex_alu/d/u2r LocalParamInNestedForLoops/t/u2r ibex_alu/t/u2r | `fullname\|ref_typespec\|golden-empty\|under:constant` | operator() (ModuleEmit.cpp, law genLpFoldDigitsMathValue18) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) < operator() (ModuleEmit.cpp, law genNestedScope |
| 2 | N0470 + N0472 | 6 | 81 | 40 | param_array_wildcard/d/u2r type_param_override_elem_sel/d/u2r type_param_packed_dim/d/u2r param_array_wildcard/t/u2r type_param_override_elem_sel/t/u2r type_param_packed_dim/t/u2r | `fullname\|ref_typespec\|tok:id->id\|under:packed_array_typespec`; `fullname\|ref_obj\|tok:id->id.id@in-typespec\|under:operation` | namedElemPackedDimTs31 (TypeEmit.cpp, law crossPkgRangeBoundFold) < emitParameters (ParamEmit.cpp, law typeParamNamedElemPackedDim31) < emitInstance (ModuleEmit.cpp, law  |
| 3 | N0433 + N0436 + N0494 | 6 | 87 | 43 | PackageMemberTypespec/d UnsupportedTypespecRange/d PackageMemberTypespec/t UnsupportedTypespecRange/t FileLevelUnionWithMultirange/d/u2r FileLevelUnionWithMultirange/t/u2r | `file\|packed_array_typespec\|golden-empty\|under:ref_typespec`; `span\|packed_array_typespec\|golden-zero\|under:ref_typespec`; `fullname\|ref_typespec\|golden-empty\|under:packed_array_typespec` | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < buildUnionTs (TypeEmit.cpp, law pkgTdRangeViewFold18) < exportDesign (UhdmExporter.cpp, law unitImportHois |
| 4 | N0163 + N0655 | 4 | 91 | 45 | PackedEnumPort/d PackedEnumPort/t VarPassedTo2Submodules/d/u2r VarPassedTo2Submodules/t/u2r | `fullname\|ref_typespec\|tok:id->id\|under:enum_typespec`; `name\|enum_typespec\|tok:id->id\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11u142map pin] |
| 5 | N0274 + N1014 | 4 | 95 | 47 | gen_scope_numports/d/u2r param_name_collision_typeparam/d/u2r gen_scope_numports/t/u2r param_name_collision_typeparam/t/u2r | `fullname\|ref_obj\|golden-empty@in-typespec\|under:operation`; `fullname\|ref_obj\|tok:id->id.id.id[n].id@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < typeParamDefaultBound20 (TypeEmit.cpp, law crossPkgRange |
| 6 | N0004 + N0265 | 4 | 99 | 49 | LargeValue2Struct/d StructUnsizedVal/d LargeValue2Struct/t StructUnsizedVal/t | `fullname\|ref_typespec\|tok:id@id.->\|under:typespec_member`; `fullname\|ref_typespec\|tok:id@id.->\|under:logic_typespec` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator() (ParamEmit.cpp, law pkgUnty |
| 7 | N0103 | 2 | 101 | 50 | ArrayMethodIterator/d ArrayMethodIterator/t | `name\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNoBind200) < emitClassDefn (UhdmExporter.cpp, law externProtoI |
| 8 | N0011 | 2 | 103 | 51 | typed_named_pattern/d/u2r typed_named_pattern/t/u2r | `file\|logic_net\|golden-empty\|under:ref_obj` | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cpp, law hoistedThisRidesTheForwardedBlock219) < main (uhdm_ma |
| 9 | N0078 | 2 | 105 | 52 | ibex_register_file_ff/d/u2r ibex_register_file_ff/t/u2r | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law structParamPathBaseAtMember137) < operator() (TypeEmit.cpp, law elabVarRange |
| 10 | N0454 | 2 | 107 | 53 | packed_array_struct_port_sel/d/u2r packed_array_struct_port_sel/t/u2r | `fullname\|ref_typespec\|tok:id@id.id.id.id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit.cpp, law t |
| 11 | N0528 | 2 | 109 | 54 | DelayAssign/d DelayAssign/t | `value\|constant\|value:UINT->UINT\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgUnvaluedActualLitRetFold8) < emitInstance (ModuleEmit.cpp, law elabPortBoundIntParamTs109) < exportDesign (UhdmExporter.cpp, law  |
| 12 | N0531 | 2 | 111 | 55 | struct_member_cfg_width/d/u2r struct_member_cfg_width/t/u2r | `fullname\|ref_typespec\|tok:id@id.id.id.id.id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters (ParamEmit.cpp, law t |
| 13 | N0646 | 2 | 113 | 56 | GenCaseStmt/d GenCaseStmt/t | `fullname\|ref_obj\|golden-empty\|under:case_item` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < operator() (ModuleEmit.cpp, law caDefGenBlockKeepsFinal98) < emitDefGenStmts (ModuleEmit.cpp, law genRegionCon |
| 14 | N0688 | 2 | 115 | 57 | iface_zero_width_field/d/u2r iface_zero_width_field/t/u2r | `fullname\|ref_typespec\|tok:id@id->id::id\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < emitParameters (ParamEmit.cpp, law pkg |
| 15 | N0830 | 2 | 117 | 58 | ComplexHierPath/d ComplexHierPath/t | `struct\|ours-only:fewer-copies\|logic_net\|under:cont_assign` | operator() (ModuleEmit.cpp, law readerWidthIsTheSecondAdjust104) < operator() (ModuleEmit.cpp, law elseArmFirstItemReplaces48) < operator() (ModuleEmit.cpp, law genNested |
| 16 | N0962 | 2 | 119 | 59 | mriscv_bind_sva/d/u2r mriscv_bind_sva/t/u2r | `fullname\|hier_path\|golden-empty\|under:port` | emitInstance (ModuleEmit.cpp, law wildcardConnRefSpan130) < emitInstance (ModuleEmit.cpp, law bindIfaceTwinInParent46) < exportDesign (UhdmExporter.cpp, law dottedTopName |
| 17 | N0019 | 2 | 121 | 60 | expr_width_cast/d/u2r expr_width_cast/t/u2r | `fullname\|ref_obj\|golden-empty@in-typespec\|under:hier_path` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl12) [r1 |
| 18 | N0017 + N0026 + N0027 + N0029 | 6 | 127 | 63 | ibex_branch_predict/d/u2r ibex_csr/d/u2r ibex_fetch_fifo/d/u2r ibex_branch_predict/t/u2r ibex_csr/t/u2r ibex_fetch_fifo/t/u2r | `span\|constant\|endline+endcol\|under:sys_func_call`; `span\|constant\|line+endline\|under:sys_func_call`; `span\|sys_func_call\|line+endcol\|under:begin`; `span\|sys_func_call\|line+endline\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172) [DE |
| 19 | N0092 + N0140 + N0143 + N0149 | 6 | 133 | 66 | rp32_r5p_bru/d/u2r rp32_r5p_mdu/d/u2r rp32_r5p_wbu/d/u2r rp32_r5p_bru/t/u2r rp32_r5p_mdu/t/u2r rp32_r5p_wbu/t/u2r | `value\|constant\|value:UINT->UINT\|under:range`; `file\|struct_typespec\|other-file\|under:ref_typespec`; `file\|struct_typespec\|other-file\|under:module_inst`; `file\|struct_typespec\|other-file\|under:package` | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabSize113) < buildStructTs (TypeEmit.cpp, law pkgTdRangeViewFol |
| 20 | N0430 | 2 | 135 | 67 | UnionCast/d UnionCast/t | `file\|union_typespec\|ours-empty\|under:ref_typespec` | buildUnionTs (TypeEmit.cpp, law modStructMemberBoundMeta) < emitExpr (ExprEmit.cpp, law modFnLocalTdCastClone112) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmI |
| 21 | N0117 + N0768 | 2 | 137 | 68 | CrossFunc/d CrossFunc/t | `span\|unsupported_typespec\|endcol\|under:ref_typespec`; `span\|logic_var\|endcol\|under:module_inst` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDefRangeSymbolic) < emitTopPorts (ModuleEmit.cpp, law tpDimVecPor |
| 22 | N0094 + N1058 | 2 | 139 | 69 | GenForStructParamBound/d GenForStructParamBound/t | `span\|constant\|line+col+endline+endcol\|under:range`; `fullname\|hier_path\|golden-empty\|under:range` | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabSize113) < emitInterfaceInstance (ModuleEmit.cpp, law ifacePo |
| 23 | N0269 + N0450 | 2 | 141 | 70 | OneNetModport/d/u2r OneNetModport/t/u2r | `fullname\|ref_typespec\|tok:id.id->id\|under:logic_var`; `fullname\|logic_var\|tok:id.id->id\|under:io_decl` | emitInterfaceInstance (ModuleEmit.cpp, law caIfaceElabNetDeclAssignListing88) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFallback215v) < emitInsta |
| 24 | N0447 + N0498 | 2 | 143 | 71 | ClassParamAsParam/d ClassParamAsParam/t | `file\|param_assign\|golden-empty\|under:class_typespec`; `span\|class_var\|endcol\|under:module_inst` | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < materializeDef |
| 25 | N0037 + N0062 | 2 | 145 | 72 | ParamTypespec2/d ParamTypespec2/t | `file\|packed_array_typespec\|ours-empty\|under:ref_typespec`; `span\|packed_array_typespec\|ours-zero\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListing53) < sharedTypespec (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPorts (ModuleEmit.cpp, law tpDimV |

ground B: the 42 clusters above clear 74 row-modes on top of the pairs (145 with them).

In short, the next two refills can be written from these tables:

* **Expression/parameter ground, after r11u145.**
  1. **r11u148's pair-A decodes, all structural:**
     * D2: N2383 + N2384, 6 row-modes, one site.
     * ARR: N0046, array_assign.
     * D: N0045 + N0756/N0758/N0759. N0045 alone also clears StructParamPatternInitCast.
     * G: N0724 + N1129, BlackParrotComplex.
     * C3: N0417 + N0534, the two ...PassedAsPort tests.

     Together they are 20 row-modes, every one decoded in tools/probe/r11u148share/README.md.
  2. **The generate-scope and interface member-path names:**
     * N0077: GenForIfaceLocalparamBound and GenForIfaceLocalparamNestedGen, 4 row-modes.
     * N1053, N1063, N0820, N1118.
     * N0833 + N1067.

     All are ExprEmit emitExpr full names of a select inside a member path.
  3. **Continuous-assignment folds:**
     * PortInitVal / sat_asserts_seq spans: N0455 + N0456, 5 row-modes.
     * multiplier: N0471 + N0702.
     * PatternStruct: N0394 + N1140, r11u140 R1.
     * ComplexParamOverload: N0739.
  4. **The big multi-row span families,** 0 alone but carried by 11-23 row-modes each, and gating the UVM/ibex
     rows:
     * N0012 + N0034: the type-parameter enum override, r11u130 R1 (ground A by override).
     * N0054, N0050 + N0060, N0086 + N0087, N0142, N0095, N0109 + N0110.
* **Module/type ground, after r11u146.**
  1. **N0008** (27 row-modes, heads 18; pass 144's `foldedBoundTsRefUnstored144` took one face):
     * alone it clears LocalParamInNestedForLoops (already down to it after the share law) and ibex_alu;
     * map 5's decode (TypeEmit's folded-bound reference name) stands, but the pin still lands in ModuleEmit's
       generate-loop fold.
  2. **Type-parameter default-bound and element names:**
     * N0470 + N0472 (6 row-modes; 77 + 42 probe cases);
     * N0274 + N1014;
     * N0454, N0531, N0688 (the member reference names in parameter typespecs);
     * N0004 + N0265 (StructUnsizedVal, LargeValue2Struct).
  3. **Package-member typespec file/span:**
     * N0433 + N0436 + N0494 (6);
     * N0163 + N0655 (4, the enum copies);
     * N0037 + N0062.
  4. **Singles:** N0103, N0011, N0078 (the leftover after pass 144's law), N0528, N0646, N0830, N0962, N0019.
  5. **The ibex macro-line model:** N0017 + N0026 + N0027 + N0029, r11u131 R7, UhdmExporter locLineCol. It clears
     6 row-modes alone and gates 20.
  6. **The rp32 family:** N0092 + N0140 + N0143 + N0149 (6).

**A caution on grounds** (evidence/caller_ground.txt). Passes 144 fixed N1167 (IndexAssign) and N0276
(iface_array_modport_drive) in the ModuleEmit CALLER of an ExprEmit mint that map 5 had grounded A. 33 OPEN clusters
have that shape (113 row-mode slots), among them:
* N0739, N1118, N0833 and N0394/N1140 in the ground-A list above;
* N0111, N0174, N0216, N0218, N0231 (TaskFuncEmit callers).

Before either pair claims one of them, read its first caller.

## 8. Prediction audit of map 5 (evidence/report.txt section 8)

**Pass 140 (pair A r11u140) moved 26 row-modes. Map 5's optimistic pair-A prediction named 16, and all 16 moved:**
* ClassVar, ComplexExprSize, Kmac, ParamScope d/t;
* func_local_compound_xor, param_struct_field_bitsel, param_unpacked_struct_array, struct_dynamic_range d/t.

That is the best calibration of any map (map 4: 24 of 97). The **10 unpredicted** rows:

| rows | map-5 first cluster | map 5 said | landed by |
|---|---|---|---|
| DefaultPatternModule d/t, ParamArrayUnsizedPattern d/t | N0441 | OPEN, ground-A step 1 (ParamEmit emitParameters) | `defaultFillOneConstant140` (+ `replCountFoldFile140`), ParamEmit: pin right, not in r11u140's brief |
| ParamFromPackage d/t | N0675 | ground-A step 9 (ParamEmit emitParameters) | `pkgRefFoldClonesMultiDimOnly140`, ParamEmit: pin right |
| IntegerConcat d/t | N0039 | pair B (TypeEmit makeTypespec pin) | `pkgRefFoldClonesMultiDimOnly140`, **ParamEmit: pin wrong ground** (the row's N0039 face was the fold, not the int_typespec span) |
| struct_member_trailing_index d/t | N1057 (+ N0061, N0077 covered) | ground-A step 14 (ExprEmit emitMixedHierPath) | `procLvTrailIdxNamesByPath140` + `procLvBaseSelTrailAtIdx140`, ExprEmit: pin right |

**Pass 144 (pair B's refill, from map 5's section-7 ground-B list) moved 18 row-modes.** Map 5's "alone" figures for
its ground-B list, against what moved:

| cluster | map 5 alone (after p137) | moved | landed by |
|---|---|---|---|
| N0281 | +5 | **5** (UnsizedParam t, ParameterOfParametrizedType d/t, ...InSubmodule d/t) | `paramAliasBoundRefUnstored144`, TypeEmit: pin right |
| N0078 | +4 | 2 (PackStructVar d/t); N0078 13 -> 9 | `pkgTsForeignQualRefUnstored144`, TypeEmit: pin right |
| N0008 | +2 | **2** (ParameterInitializedByPartSelectOfParametersAssignedToVar d/t) | `foldedBoundTsRefUnstored144`, **TypeEmit: the decoded note was right, the pin (ModuleEmit gen-loop lambda) wrong** |
| N0681 | +2 (step 19) | **2** (PkgParamAsFunctionArg d/t) | `callFoldFormalBitSelLoc144`, ModuleEmit: pin right |
| N0030 | +7 | 1 (CarryAdd t, via the `--elabuhdm` clone law) | `elabCloneInstTreeUnstored144`, uhdm_main (map 5's ground override B) |
| N0139 | +6 | 0 | not in pass 144's brief |
| N0133 / N0554 | +4 / +4 | 0 | not landed; r11u148's law now MEASURED at 6 + 2 (+ 2 simple_package) |
| (not in the B list) N1167 | map 5 ground-A step 10 | **2** (IndexAssign d/t) | `caSelLhsBareDecNoAdjust144`, **ModuleEmit: the CALLER of the pinned ExprEmit mint** |
| (not in the B list) N0276 | ground A, 0 alone | **2** (iface_array_modport_drive d/t) | `defGenLhsHpBaseAnchor144`, **ModuleEmit: the caller again** |
| N1286, N1625 | UHDM DeepClone pins (uhdm_main) | 2 (GenScopeHierPath3 t, SequenceInst t) | `elabCloneInstTreeUnstored144`, uhdm_main: pin right |

Cluster movement since map 5 (at p137 -> now):
* **Map 5's pair-A covered set (28):**
  * cleared 5: N0041, N0053, N0058, N0245, N0272;
  * fell 9: N0142 44 -> 12, N0077 13 -> 9, N0050, N0060, N0061, N0212, N0394, N0427, N0451;
  * unchanged 14, among them N0003, N0052, N0054, N0055, N0063, N0079 and N0151. These are now r11u145's or OPEN.
* **Map 5's section-7 ground-A list (20):**
  * cleared 4: N0441 (it became N2385), N0675, N1167, N1057;
  * the other 16 unchanged, among them N0001 62, N0005 44, N0007 34, N0010 30, N0012 23 and N0018 25. All of these
    are in r11u145's brief now.
* **Map 5's section-7 ground-B list (20):**
  * none cleared;
  * fell 7: N0281 8 -> 2, N0078 13 -> 9, N0030 18 -> 16, N0008 29 -> 27, N0014 16 -> 14, N0039 14 -> 12,
    N0681 3 -> 1;
  * 13 unchanged, among them N0139, N0043, N0044, N0096, N0133 and N0554.

**What it says about the site pins:**
* Of the 21 cleared or falling clusters traced to a landed law, the pinned mint's file is the law's file in 15:
  N0041, N0053, N0245, N0212, N0142, N0441, N0675, N1057, N0061, N0681, N0281, N0078, N0070, N1286 and N1625.
* It is the first CALLER's file in 2 (N1167, N0276: an ExprEmit emitExpr mint under a ModuleEmit emitter).
* It is the decoded note's file, not the pin's, in 1 (N0008).
* It is another file altogether in 3:
  * N0039 on IntegerConcat, where the row's face was a fold;
  * N0030 on CarryAdd t, an `--elabuhdm` clone;
  * N0394: an ExprEmit tryFoldConst pin under ModuleEmit, where pass 140 took its ParamEmit share with
    `replCountFoldFile140`.

So a pin names the right file about seven times in ten. Where the mint is a generic ExprEmit entry, the first
non-ExprEmit caller is the better ground guess (section 7's caution). Map 5's optimistic yields were exact for a
brief built from its own ids (16 of 16), and N0281 and N0008 met their alone figures exactly. N0030 (+7 -> 1) and
N0078 (+4 -> 2) over-predicted: the landing took one shape of a many-shape cluster.

## 9. Files

* `clusters.csv`: every (row-mode, cluster) with its object count (test,mode,corpus,first_field,cluster_id,objects).
* `probe_clusters.csv`: every (probe case, cluster) (case,law,first_field,cluster_id,objects).
* `fail_list.csv` (360) and `probe_fail_list.csv` (1779): the gate's fail list. Every `STRICT_NOTEQUAL` row-mode or
  probe case with:
  * its strict cell, first cluster, that cluster's coverage and site (`first_site`);
  * its clusters and open clusters;
  * `clears_with_pairs` (cluster-optimistic);
  * the downstream verdict;
  * the MEASURED share cross-section: `strict_after_share`, `first_cluster_after_share`;
  * `open_clusters_after_pairs` and `clears_after_both_pairs` (`yes (share, measured)`, `yes (optimistic)`, `no`).
* `cluster_index.csv` (1518) and `family_index.csv`: section 4's columns.
* `evidence/clusters/N####_*.txt`: golden's and our records around the example object (with the mode-4 flags), the
  holder on the other side, and the row's facets. 1129 files: every cluster with a corpus row or >= 3 probe cases.
* `evidence/objects.csv` (one example per cluster, 1518) and `evidence/row_objects.csv` (one example per (row-mode or
  case, cluster), with the object count).
* `evidence/report.txt`: sections 0-10 of drivers/report6.py. It covers the share measurement, the yields, the
  OPEN and first tables, the greedy, probe by law, the prediction audit, and the covered table.
* `evidence/greedy_sets.txt`, `near_rows.txt` (the 167 rows with <= 3 open clusters) and `row_families.txt` (open
  clusters grouped by their exact row set).
* `evidence/caller_ground.txt`, `structural.txt`, `final.txt`, `tallies.txt`.
* `evidence/pins_new.txt` (the 98aa49db gdb frames, with db=SAME/DIFF) and `sites.json` (the final site of every
  re-pinned or decoded cluster; every other cluster's site is map 5's).
* `evidence/decoded_sites.json`, `residue_routes.json`, `residue_cases.txt`, `ground_override.json` and
  `pinwant.txt`.
* `evidence/verify.txt`, `controls/`, `share_sweep_summary.txt`, `pristine_sweep_summary.txt` and
  `byteverify_share.txt`.
* `drivers/`:
  * `run.sh` (every step);
  * `strictcmp_x.cpp` + `cc.sh`, `objrank.cpp`;
  * `run1.sh`, `jobs.py`, `probejobs.py`, `probelaw.py`, `analyze.py`, `common.py` (maps 3-5's);
  * `final.py` (map-5 ids persist, new from N2383, the pairs' coverage);
  * `casekeys.sh` (+ `ELAB=1`);
  * `pinmulti.py` (never a fenced test), `sites.py`, `mksites6.py`;
  * `report6.py`, `greedy_sets.py`, `structural.py`, `evid.py`, `rowobjects.py`, `redact.py`.
