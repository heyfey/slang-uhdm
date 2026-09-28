# r11u211map: the strict ground map, thirteenth edition (measurement only)

**Base.** Measured at `4acbe8a5` (branch matrix-1.87), HEAD of the branch when this pass started (`git log
4acbe8a5..HEAD` read empty then). **Pass 207 (pair A r11u207) landed during the pass, at `62ac216e` (13:23, 40 minutes
after the start)**: every section below is measured at `4acbe8a5`, and section 13 re-measures the fail list, the
clusters and the away census at `62ac216e` from its integration sweep `/tmp/intr11u207` and two sweeps of this map
(HEAD and pass-207-off), so both bases are stated wherever they differ. The base sits after map 12
(`tools/probe/r11u203map`, measured at `ddc67d87`, committed as `1454b68c`), the verification r11u204 (`93c4c999`, four
refinements `R11V204_*`), pass 202 (`0e776f9c`), pass 201 (`3668bf30`), the decode r11u205 (`032fbb89`:
`tools/probe/r11u205dec/law_typeemit.patch` and `law_exprstmt.patch`, NOT in src), pass 206 (`6e39a3fc`) and the
verification r11u208 (`4acbe8a5` itself, law opCtxTargetAncestorBind208v). Pair A r11u207 (base `3668bf30`) and pair B
r11u209 (base `6e39a3fc`) were live at the start; pair B has not landed, pair A landed as pass 207 (section 13). Their
worktrees were not touched.

**The reference sweep.** `/tmp/intr11u208` (the integration sweep of r11u208, read-only here). Its csvs equal the
committed baselines cell for cell (1596 of 1596 surelog rows, 1742 of 1742 uhdm2rtlil rows, status and strict), its
`probe.csv` is byte-identical to `results/golden_probe.csv`, and all 3273 `slang:` lines of its `cmds.txt` files name
the main tree's `build/slang-uhdm` (md5 `9c0e77451011`), which this worktree's build reproduces byte for byte. This
map's own pristine gate sweep `/tmp/r11u211_sP` reads 0/0/0 in all three compare stages and downstream 803 / 66 / 2 / 0.

Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited; this directory is the whole patch.
Law names are written `law <name>` (no section sign) so `scripts/law_index.py` does not read this directory as a pass.
A probe case is called a case throughout.

**The fence.** No fenced row is `STRICT_NOTEQUAL` at `4acbe8a5` (`drivers/jobs.py`: `fenced_skipped=0`), so none is in
the fail list; their row-modes are counted from the csv verdicts only. Every driver that reads a database or a source
takes the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` (`drivers/common.py fenced()`,
`drivers/env.sh` `FENCED` / `FENCERE`; fail closed) and refuses them by word boundary: `jobs.py`, `pinmulti.py`,
`dsfaces.py`, `uvmcensus9.sh`, `uvmdist.sh`, `census.sh` (its corpus runs filtered `^(?!(<fenced>)$)`), `bvmirror.sh`
(byteverify ran on hard-link mirrors without the 8 fenced row-mode databases, `fenced_skipped=8`), `awayrows.py`,
`attribution.sh` (its nine filtered tests checked against the fence), `rebuildid.sh`, `orphanscan.sh`. The gate sweeps
(pristine, law, and the five switch states) dispatched every row, as the gate mandates. **No binary, gdb run or script
touched a fenced test's sources or databases outside those sweeps.** A grep of this directory for the four names reads 0.

## Binaries (frozen `chmod 555` in `/tmp/r11u211_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `9c0e7745101105b89052e5e037a0169c` | worktree `/tmp/wt_r11u211` at `4acbe8a5`, system-deps config, `-j 1`: byte-identical to the main tree's `build/slang-uhdm` |
| `slang-uhdm.rebuild2` | `9c0e7745101105b89052e5e037a0169c` | a second, independent build of the same source (scratch worktree `/tmp/wt_r11u211L`, fresh build dir, `-j 1`): the rebuild-identity control (section 2c) |
| `slang-uhdm.law205` | `e197e9c76e6cf5cf4612287c55bc60c4` | MEASUREMENT ONLY: `4acbe8a5` + [evidence/law205_on_4acbe8a5.patch](evidence/law205_on_4acbe8a5.patch) = r11u205's `law_exprstmt.patch` (applies clean at `4acbe8a5`: pass 201 and r11u208's refinement do not touch its two hunks) + `law_typeemit.patch` **minus its first law tpDefaultUseCastAndArrayElem205** (superseded by pass 206's laws tpCastUseBindsDefDefault206 / tpArrayElemBindsDefDefault206, not to be landed), rebased over pass 206: one conflict, the `exportDesign` call site of the post-pass, where pass 206's form (`tpUseBindsDefDefault160` with its `e2d206` map, then `tpCastUseBindsDefDefault206`) is kept and `genConnTrailSelChain205(d)` is called after it. 473 added lines (ModuleEmit 140, TypeEmit 26, UhdmExporter 167, ExprEmit 132, EmitHelpers 8) |
| `slang-uhdm.lawA205` | `f70d2717253c5d480bc8535c9837d566` | `4acbe8a5` + [evidence/lawA205_on_4acbe8a5.patch](evidence/lawA205_on_4acbe8a5.patch) (law_exprstmt alone: ExprEmit, EmitHelpers.h; pair A's next refill r11u210) |
| `slang-uhdm.lawB205` | `9f049970b2723006fbb621e56e9766dd` | `4acbe8a5` + [evidence/lawB205_on_4acbe8a5.patch](evidence/lawB205_on_4acbe8a5.patch) (law_typeemit minus its first law, rebased: ModuleEmit, TypeEmit, UhdmExporter; pair B r11u209's first item) |
| `slang-uhdm.g1` | `8b6b9be516b0d0438b87ca6549d70107` | `4acbe8a5` with `-DCMAKE_CXX_FLAGS=-g1` (`/tmp/wt_r11u211/build-g1`, target `slang_uhdm`); gdb pins only; every pinned database `db=SAME` |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` (unchanged since map 11) |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | [drivers/strictcmp_x.cpp](drivers/strictcmp_x.cpp) built by `drivers/cc.sh`: byte-identical to map 12's variant; its verdict equals the tool's on 766 of 766 jobs (section 1) |
| `objrank` | `3e213a154aab7f619443de5f11646f0a` | [drivers/objrank.cpp](drivers/objrank.cpp) (map 12's source, `-O2`) |
| `st4.sh` `st2.sh` `st1.sh` `st6.sh` `st8.sh` | - | state wrappers `exec env <switches> slang-uhdm "$@"` for the away census (section 8) |

The three law binaries are incremental rebuilds of `/tmp/wt_r11u211L` (the `git diff` saved after each build equals the
patch it was built from, `diff` of the +/- lines 0 for each); the scratch worktree was reverted to `4acbe8a5` afterwards.
Sweeps (`tests/sweep.sh --jobs 3`, all 15-character workdirs): the reference `/tmp/intr11u208`, the pristine
`/tmp/r11u211_sP`, the law `/tmp/r11u211_sL`; all 3273 `slang:` lines of `sP` name `slang-uhdm`, of `sL`
`slang-uhdm.law205`, of each state sweep its wrapper, of the attribution sweeps their binary (17 of 17 corpus rows each).

## 0. Where we stand (4acbe8a5; the committed baselines are the fail list)

| corpus | mode | judge-equal | strict-equal | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 463 | 17 |
| surelog | testflags | 474 | 459 | 15 |
| uhdm2rtlil | default | 803 | 798 | 5 |
| uhdm2rtlil | testflags | 803 | 798 | 5 |
| probe cases | | 4087 | 3363 | 724 |

**The fail list is 42 row-modes (32 surelog + 10 uhdm2rtlil) in 23 tests, plus 724 probe cases.** All 42 row-modes and
all 4087 probe cases were dispatched to the strict comparator: rc=2 on all 42; on the cases rc=0 on 3363 and rc=2 on
724, exactly the baseline split.

First fields, tallied from the `strict` column of results/golden_*.csv (= the reference sweep's):
* surelog 32: fullname 13, endcol 6, file 6, line 2, endline 2, **type 2** (Scr1SvTests d/t), defname 1;
* uhdm2rtlil 10: fullname 6, line 4;
* probe 724: fullname 262, line 124, endcol 89, type 71, name 58, file 41, depth 33, col 27, endline 11, value 7,
  decompile 1.

Mode asymmetries (the default row is the map's row; these differ in testflags): NE in default only: InterfArrayBind
(testflags CMP_EQUAL), Rggen (testflags SURELOG_FAIL), Scoreboard (testflags SLANG_REJECT); NE in testflags only:
HierPathTypespec; a different cell per mode: FuncStructVal `endcol(95)` / `(165)`, FuncStructValSimple `file(39)` /
`(59)`, UnitElabBlock `file(2)` / `file(1)`. Every uhdm2rtlil fail row-mode is downstream IDENTICAL (10 of 10).

**Since map 12** (50 row-modes / 27 tests, 742 cases at ddc67d87): **8 row-modes and 18 cases converted, none entered**
(committed baselines at each landing; [evidence/audit.txt](evidence/audit.txt) A):

| landing | row-modes converted | cases | strict-cell changes |
|---|---|---|---|
| map 12 (`1454b68c`), r11u204 (`93c4c999`) | - | 0 | 0 |
| pass 202 (`0e776f9c`) | ClassTypeParam d/t, int_types d/t | 14 | 18 |
| pass 201 (`3668bf30`) | SVSwitch d/t (with pass 202's B half) | 4 | 11 |
| r11u205 (`032fbb89`), r11u208 (`4acbe8a5`) | - | 0 | 0 |
| pass 206 (`6e39a3fc`) | arb_idx_cast d/t | 0 | 0 |

**Clusters.** Map 11's key (`facet|type|shape|under:<walk parent type>` + `@builtin` / `@in-typespec`), ids persisting:
**847 clusters at 4acbe8a5 (415 carry a corpus row, 596 a case); 846 keep map 12's id, one key is new: N2469**
(`fullname|ref_obj|tok:->id.id[id].id::|under:bit_select`, MiniAmiq d/t only, 4 objects: the `index` reference in
`vpi_vif.sva_exists(...)` of svaunit's `get_sva_tested`, reached now that passes 201/202 moved the walk; pinned in
ExprEmit `emitExpr`, ground A); **47 map-12 clusters are gone.** No key exists only under the r11u205 patches (map 12's
two AWAY keys N2467 / N2468 of the r11u200 patches are gone: v11u202 refined both laws before pass 202 landed).

## 1. Method (map 12's pipeline re-based, [drivers/run13.sh](drivers/run13.sh))

1. **Input.** The reference sweep `/tmp/intr11u208`. Jobs: every `STRICT_NOTEQUAL` row-mode of results/golden_*.csv (42;
   `drivers/jobs.py`: 0 missing, 0 fenced, one binary), golden = the cache entry its `cmds.txt` names; every probe case
   (4087), golden = `scripts/check_probe.py cache_dir(rel)` (Surelog's identity, the case path and a hash of the case's
   files; 0 missing), ours = `/tmp/intr11u208/probe/<rel with / -> __>.uhdm`.
2. **Strict runs.** `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job (`drivers/strict_runs.sh`).
3. **Analysis.** `drivers/analyze.py` (the committed mode-4 rule) records EVERY differing object, including those past
   the tool's walk divergence (the alignment is a diff of the record keys); its reimplementation of the tool's rule
   agrees with the tool's stdout on **766 of 766** jobs (0 VERIFY-MISMATCH, 0 CELL-MISMATCH against the csv cells;
   [evidence/final13.txt](evidence/final13.txt)).
4. **Clusters.** `drivers/final13.py`: map 11's key; ids persist from map 12 (else the latest earlier map).
5. **Sites.** Map 12's pins are kept where the example object is unchanged ignoring record indices. Of the clusters with
   >= 3 row-modes, a first record or >= 40 cases, 12 have a changed example: 5 have only coin-prone UVM rows and no case
   (map 12's rule keeps their pin), and 7 were re-pinned with the `-g1` build (`drivers/pinmulti.py`, one gdb session
   per example row, [evidence/pinwant.txt](evidence/pinwant.txt)), plus the new N2469 on MiniAmiq default:
   **8 of 8 `db=SAME`** ([evidence/pins/](evidence/pins/)). The gdb runs use the MAIN tree's case paths, because the
   reference probe databases embed the checkout path of the case (a first run from the worktree read `db=DIFF` on all
   seven for that reason alone, [pins_new0_wtpath.txt](evidence/pins/pins_new0_wtpath.txt)). **6 of the 7 name map 12's
   mint** (N0164 N0543 N0784: TypeEmit `importCloneBareTdAlias16`'s alias view; N0540 / N0689: ParamEmit `emitPackage`;
   N0175: ExprEmit `emitExpr` < `emitMixedHierPath`, the nearest law name above the line now pass 201's); **N0007's new
   example** (a probe case, r11u117repro g13: `ref_obj v` in a definition-view generate path select) **is minted in
   TypeEmit `emitSyntaxExpr` (law defGenPathSel161)**, where map 12's SVSwitch example was ExprEmit's
   `parensLessCallIsPathRefObj`: the key spans two mints, the UVM records being ExprEmit's.
6. **Ground.** A = ExprEmit/EmitHelpers/StmtEmit/ParamEmit, B = TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main,
   by the pinned mint's file, overridden where a pass decoded the fix site elsewhere
   ([evidence/ground_override.json](evidence/ground_override.json): map 12's list minus N2467 / N2468, plus **N0145 -> B**
   (r11u201 section 7 item 4 and r11u205 3.3, measured here: law defGenTargetIpsDefName205 in TypeEmit clears it) and
   **N0039 -> B** (r11u205 4.3: the scalar-typedef formal writer, TaskFuncEmit + law tfArgClassMethodOrder176)).
7. **Coverage** ([evidence/routes.json](evidence/routes.json), `drivers/mkroutes13.py`, `drivers/report13.py`):
   * **r11u205's five remaining laws, MEASURED**: the law205 binary's full gate sweep re-dumped and re-keyed
     (`drivers/crosssection.sh`); a cluster gone under it reads `COVERED r11u205 (law patches, MEASURED ...)`;
   * **pair A r11u207, OPTIMISTIC** and **pair B r11u209, OPTIMISTIC**: their brief items mapped to clusters (table
     below); a covered cluster counts fixed whole; pair B also takes the ground-B clusters of the UVM / Earlgrey rows'
     first ten differing records at the cross-section whose rows are all UVM / Earlgrey rows (map 11's rule). Map 12's
     own pair routes are carried only where the new brief names the item again;
   * **OPEN** otherwise, with map 12's routing where it had one.
8. **Yields.** The `alone` column is the rows a cluster clears alone on top of r11u205 (measured) and both pairs.

What the live pairs were mapped to:

| pair | brief item | clusters |
|---|---|---|
| A r11u207 | map 12's UVM heads | N0540 N0689 |
| A | BlackBePipeInt's head (OPTIMISTIC: map 12 left it unrouted, an identity family of per-use copies) | N0923 |
| A | the A halves the sister needs: UnitElabBlock's implicit-net file (also MEASURED in r11u205's A patch), Scr1SvTests' bound and A names (OPTIMISTIC: the row ends on the Surelog defect N0791) | N0016; N0416 N0779 N0836 N1069 N1119 |
| A | pass 201 section 7: item 2 (UVM_MACRO_* names N0682, BuildUVMPkg #5639 N0189), item 6 (cfg_func_width_loop N0263 N0025 N0033 N0754 N0794, decoded, no law), item 7 (struct_param_func_config N0028 N0045 N0552 N0675 N0761 N0817 N2412, decoded, no law), item 10 carried (InterfArrayBind N0427; FuncStructVal/Simple N0086 N0087 N0131 N0407 N0891 N0980 N1096 N1946; anon_struct_packed_dim N0820; ibex_tracer N0003 N0763 N0957 N0971 N0979; OutputSize N0001 N0191) | 36 |
| A | the UVM ground-A families (map 12 section 9 A4, the 7-row clusters, and map 12's carried A routes) | 19 + 38 |
| A | r11u204's ground-A residues (N1-N4, N6, N10), pass 201 items 8-9 | evidence cases only (no gate row carries a cluster of its own) |
| B r11u209 | r11u205's three remaining ground-B laws | MEASURED (the lawB205 binary and the law205 composition) |
| B | the r11u204 twin helper's determinism fix (pass 206 R1) | reader-invisible, no cluster (section 2c) |
| B | pass 206's residues R2 (anon_struct_packed_dim N0014), R3 (InterfaceStructMemberPort N0519 N1117 N1126 N1128 N1134), R4 (HierPathTypespec t N1174, OPTIMISTIC: the naming-context face), section 6 (4): cfg_func_width_loop's kept call N0133 N0487, OutputSize's B half N0853 N1127, ibex_tracer's B half N0563; section 6 (2): Rggen N0145 N1249 | 14 |
| B | MiniAmiq #899 and BuildUVMPkg #3245 by Surelog's compile order | N0144, N0039 |
| B | r11u204 B3 / B4 / N5-N9; pass 206 R5-R7 | evidence cases and downstream faces (section 7b), no gate row |
| B | the UVM ground-B families (map 12 section 9 B6: 11 clusters; map 12's carried B routes: 30) | 41 |
| not routed | InterfaceModPort N0040 (converts only once the harness passes `--sverilog`, pass 188 R1; not in either brief), PreprocTest N0056 (`.vh` face, not implementable), LogicTypespec (a user decision), Scr1SvTests' structural record N0791 (a Surelog binding defect, r11u200 3d) | |

## 2. Controls

### 2a. Positive controls ([evidence/controls/](evidence/controls/))

| control | result |
|---|---|
| surelog/default/1364_2005 (CMP_EQUAL) | `STRICT_EQUAL 159 objects`, rc 0, record dumps identical (159 / 159) |
| surelog/default/HierPathInterfBlock (CMP_EQUAL) | `STRICT_EQUAL 226 objects`, rc 0, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray (CMP_EQUAL) | `STRICT_EQUAL 194 objects`, rc 0, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, lhsPath / rhsPath `design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL,decompile:` both modes |
| analyzer rule vs tool stdout | 766 / 766 at 4acbe8a5; 744 / 744 on the r11u205 cross-section (40 row-modes + 704 cases) |
| probe cells vs golden_probe.csv | 4087 / 4087; 724 / 724 rc=2 from the strict runs |
| pin validity | 8 / 8 `db=SAME`; 6 / 7 re-pins the same mint as map 12 |
| byteverify self-check | 2559 / 2560 flagged with one side replaced (the check's pass value, r11u208's reading) |
| away census positive control | the reversed comparison of pass 202 (section 8): **1337 chain-keyed records away** on 52 databases where the forward one reads 1337 toward |
| the switch states | each landing-off state reproduces the committed history: `R11U202_OFF` probe 14 regressions + 13 changes, surelog 4 (ClassTypeParam d/t, SVSwitch d/t) + 16, uhdm2rtlil 2 (int_types); pass 201 off probe 4, surelog 2 (SVSwitch) + 11; `R11U206_OFF` uhdm2rtlil 2 (arb_idx_cast); `R11V204_OFF` and `R11V208_OFF` 0/0/0 ([evidence/sweeps/state_st*.summary.txt](evidence/sweeps/)) |
| the fenced rows | counted from the csv verdicts only |

### 2b. The determinism control ([evidence/determinism/](evidence/determinism/), [drivers/det.sh](drivers/det.sh), [ob.sh](drivers/ob.sh))

The HEAD binary run three times CONCURRENTLY per row-mode (the reference sweep's command line and cwd, output to
scratch), plus the reference sweep's and this map's pristine sweep's databases; distinct md5s, and for every
multi-hash row the order-blind `uhdm-dump` difference (paths normalised, sorted, `comm -3`), the RAW dump difference,
and the strict verdict per hash.

| row-mode | draws (HEAD binary) | distinct hashes | order-blind lines | raw dump lines | reading |
|---|---|---|---|---|---|
| Earlgrey_0_1 default | 5 | **1** (`15e6e48bc148`) | - | - | deterministic |
| Earlgrey_0_1 testflags | 5 | **1** (`e449573deea9`) | - | - | deterministic |
| MiniAmiq default | 5 | 3 (`dd9e7e671b37`, `44503790f4d7`, `17adb057159f`) | **0** | **0** | storage order only |
| MiniAmiq testflags | 5 | 3 (the same three) | **0** | **0** | storage order only |
| SeqDriver default | 5 | **1** (`a08930879bae`) | - | - | deterministic |
| SeqDriver testflags | **11** (3 + 3 + 3 + both sweeps) | **1** (`5388c9e9503c`) | - | - | deterministic for this binary; the law binaries draw `4ebe09997747` in 8 of 10 (7 of 9 concurrent draws and the law sweep's; raw dump identical, same size, 331 bytes differ from offset 12064816: a storage-order draw whose odds follow the binary) |
| SimpleUVM default / testflags | 5 / 5 | **1** / **1** | - | - | deterministic |
| Scoreboard default | 5 | 3 (`e8579dab5a62`, `96872705d270`, `b35f475f27da`) | **0** | **92** between `e857` / `b35f` and `9687` (the svunit `vpiTaskFunc` listing order); 0 between `e857` and `b35f` | **the one reader-visible coin: confirmed** |
| BuildUVMPkg default / testflags | **23 / 23** (3 + 6 rounds x 3 + both sweeps) | **1 / 1** (`a22b6ee6955d`, the same bytes in both modes) | - | - | **v11u202's V2 draw (the missing weakly-referenced `this_type` class_typespec) NOT reproduced**: 0 of 23 per mode, and 0 of 9 per mode by the three law binaries (r11u208: 0 of 21; pass 206: seen once in its pristine sweep) |

Scoreboard testflags is SLANG_REJECT (not run). **The UVM value coin stays CLOSED** (no pair differs order-blind);
every multi-hash draw but Scoreboard default's listing order is storage order only. The three law binaries draw only
hashes of the pristine pool on every UVM row but SeqDriver testflags ([det_law205.txt](evidence/determinism/det_law205.txt),
[det_lawA205.txt](evidence/determinism/det_lawA205.txt), [det_lawB205.txt](evidence/determinism/det_lawB205.txt)).
Byte comparison of the two pristine sweeps (`/tmp/r11u211_sP` vs `/tmp/intr11u208`, the same binary):
**3 / 2560 corpus movers**, MiniAmiq d/t and Scoreboard d, each a hash of the pool above
([bv_P_vs_H.txt](evidence/determinism/bv_P_vs_H.txt)); every probe database differs in bytes between the two sweeps
because a probe database embeds the checkout path of its case (`/home/heyfey/git-repos/slang-uhdm/tests/probe/...` vs
`/tmp/wt_r11u211/tests/probe/...`, 18 bytes longer), dumps identical: compare probe databases only within one checkout.

### 2c. Rebuild identity (pass 206's R1; [evidence/rebuild/](evidence/rebuild/), [drivers/rebuildid.sh](drivers/rebuildid.sh), [orphanscan.sh](drivers/orphanscan.sh))

* **Two independent builds of the pristine source are byte-identical binaries** (`9c0e77451011` both, from two
  worktrees and two fresh build directories), so they write byte-identical databases: `r11u196repro/cases/V191/qr01`
  reads `98fe6fe3c120` in 3 of 3 runs of each; **0 databases differ across the two rebuilds** (the whole gate is the
  same binary). The `-g1` build (debug info only, the same code) writes the same `98fe6fe3c120`.
* **Across binaries built from different source the orphan moves**: qr01 reads `778d6e87c1e9` under law205,
  `a2fe7def3582` under lawA205, `85799f141965` under lawB205, each deterministic in 3 of 3 runs, the raw dumps identical
  to the pristine one (first differing byte 7200 / 7202): pass 206's reading, refined: "every rebuild of any source"
  holds for a CHANGE of the compiled code, not for a rebuild of the same source.
* **Which databases carry it** (name every one whose bytes differ with identical dumps): over the 170 case dirs of
  r11u196repro/cases, v11u196repro and r11u204verify/cases (pristine vs lawA205), **1: qr01**
  ([orphanscan_lawA205.txt](evidence/rebuild/orphanscan_lawA205.txt)); in the gate sweeps (pristine vs law205), 0 probe
  cases (23 of 23 probe movers carry a firing) and 0 corpus databases (the three unpredicted corpus movers are the UVM
  draws of 2b). `R11V204_OFF` moves the nine UVM databases in bytes only (0 records either way, section 8): the
  twin helper writes unreachable objects there, but their bytes do not change between binaries.

## 3. r11u205's five remaining laws, MEASURED at 4acbe8a5 (the cross-section)

| stage | both (law205) | law_exprstmt alone (lawA205) | law_typeemit minus its first law (lawB205) |
|---|---|---|---|
| probe | **20 conversions** (724 -> 704), 3 changes, 0 regressions | 0 / 0 / 0 | 20 / 3 / 0 |
| surelog | **2 conversions (UnitElabBlock d/t)**, 4 changes, 0 regressions | UnitElabBlock d/t convert; InterfArrayBind d `fullname(3)` -> `fullname(1)` | Earlgrey_0_1 d/t `fullname(76)` -> `endcol(46)`, Rggen d `defname(142)` -> `file(4)` |
| uhdm2rtlil | 0 / 0 / 0 | 0 | 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | (not run) | (not run) |

([evidence/sweeps/](evidence/sweeps/): `sweep_law205.log`, `attribution/` (probe in full, the corpus stages filtered to
the four predicted tests and the five UVM rows).) **These are r11u205's own numbers at 3668bf30 minus arb_idx_cast d/t**
(its superseded first law's conversion, landed by pass 206): the composition is additive (no mover carries firings of
both grounds). The fresh rows (NOT written to results/):

    UnitElabBlock,default,CMP_EQUAL,,,equal                    was differ:file(2)     lawA alone (law hiddenBlockVarNetNoFile205)
    UnitElabBlock,testflags,CMP_EQUAL,,,equal                  was differ:file(1)
    Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:endcol(46),,differ:endcol(46)    was differ:fullname(76)   lawB (law genConnTrailSelChain205)
    InterfArrayBind,default,STRICT_NOTEQUAL,differ:fullname(1),,differ:fullname(1) was differ:fullname(3) lawA (law elabIfArrIdxChainName205)
    Rggen,default,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)                 was differ:defname(142)   lawB (law defGenTargetIpsDefName205)

The 20 probe conversions are r11u93repro / r11v93repro / r11u90repro non-ANSI interface-port cases (law
ifacePortDeclTsAtPortDecl205); the three changes (pb10, pb19, v15) all shrink. **Movers, predicted by name**: the
firing census (`R11U205_TRACE`, frozen `chmod 444` at 13:08:18.758, the law sweep's workdir born at 13:08:18.778;
[evidence/sweeps/census/](evidence/sweeps/census/)) names 6 corpus row-modes (Earlgrey d/t, InterfArrayBind d, Rggen d,
UnitElabBlock d/t) and 25 cases; byteverify (fence-free mirrors): **9 / 2560 corpus movers, the 6 predicted plus
Scoreboard d, MiniAmiq t and SeqDriver t** (the draws of 2b, 0 records either way); **23 probe movers, 23 of 23
predicted**, two predicted cases not moving (r11u93 pb13, r11v93 v16: the law rewrote an equal value). The away census
(section 8): **0 records lost, 755 gained** (Earlgrey d/t 118 each, Rggen d 138, InterfArrayBind d 2, UnitElabBlock
2 / 1, the 23 cases 376). The 199 downstream-visible faces of section 7b: **0 verdict changes**.

**Clusters.** Gone under the patches (9): N0016 (UnitElabBlock), N0945 N0915 N0924 N1116 N1121 (Earlgrey's
generate-scope connection selects), N0145 N1249 N1677 (Rggen's indexed part selects); fell: N0011 5 -> 4 rows (its
UnitElabBlock d record, the same hidden-block net as N0016: section 10); N0094 and N1899 51 -> 30 cases.

## 4. The yield, and the fail list after r11u205 and both pairs

| | row-modes cleared | tests cleared (every NE mode) | cases cleared |
|---|---|---|---|
| r11u205's five laws, MEASURED | **2** (UnitElabBlock d/t) | 1 | **20** |
| pair A r11u207, optimistic, on top of r11u205 | **7**: FuncStructVal d/t, FuncStructValSimple d/t, InterfArrayBind d, struct_param_func_config d/t | 4 | 37 |
| pair B r11u209, optimistic, on top of r11u205 | **3**: InterfaceStructMemberPort d/t, HierPathTypespec t | 2 | 67 |
| **everything** (r11u205 + both pairs) | **20** (the 12 above + 8 that need both pairs: OutputSize... d/t, anon_struct_packed_dim d/t, cfg_func_width_loop d/t, ibex_tracer d/t) | **11** | **131** |

| corpus | mode | 4acbe8a5 | after r11u205 (measured) | + pair A | + pair B | + both pairs |
|---|---|---|---|---|---|---|
| surelog | default | 17 | 16 | 13 | 15 | 12 |
| surelog | testflags | 15 | 14 | 12 | 12 | 10 |
| uhdm2rtlil | default | 5 | 5 | 4 | 5 | 0 |
| uhdm2rtlil | testflags | 5 | 5 | 4 | 5 | 0 |
| **all** | | **42 / 23 tests** | **40 / 22** | | | **22 / 12 tests** |
| probe cases | | 724 | 704 | 667 | 637 | **593** |

First fields after r11u205 (the law sweep's csvs): surelog 30: fullname 11, endcol 8, file 5, line 2, endline 2, type 2;
uhdm2rtlil 10: fullname 6, line 4; probe 704: fullname 262, line 105, endcol 89, type 71, name 58, file 41, depth 33,
col 26, endline 11, value 7, decompile 1.

**The pair yields are optimistic in named ways.** Eight of the 20 credits are named optimisms carried from map 12:
FuncStructVal d/t (its first record is judge-unequal in every small shape, pass 187 R5), InterfArrayBind d (its last
record is a module-scope target another ExprEmit branch writes, r11u205 residue 3), HierPathTypespec t (the per-use
elaboration clone, pass 206 R4, the naming-context face), cfg_func_width_loop d/t and struct_param_func_config d/t
(decoded by r11u200, no law; for cfg the kept `q::maxw(M)` call N0133 / N0487 still differs past the walk divergence,
section 10). **Without them, everything clears 12 row-modes (6 tests) and 30 row-modes in 17 tests remain.** The other
pair credits are unattempted (OutputSize..., ibex_tracer) or decoded to a structural divergence in small shapes
(InterfaceStructMemberPort, pass 202 R12 / pass 206 R3; anon_struct_packed_dim needs a new writer kind, pass 206 R2).

## 5. Ranked OPEN clusters with sites (on top of r11u205 measured + both pairs optimistic)

Columns: `rows left` = row-modes the cluster still carries after r11u205 and the pairs (rows at 4acbe8a5 in
parentheses); `first-open heads` = rows it is the first OPEN record of; `alone` = rows it clears alone on top of
everything; `probe` = its cases after r11u205. The whole list is cluster_index.csv.

**274 OPEN clusters still carry a row** (ground A 109, B 165). **Only two OPEN clusters clear a row alone: N0040**
(InterfaceModPort d/t, the harness flag) **and N0056** (PreprocTest d/t, not implementable). The first-open heads of
the 22 remaining row-modes:

| first OPEN cluster | row-modes it heads | ground | example (golden / ours) | site |
|---|---|---|---|---|
| N0582 | 4 (MiniAmiq d/t, SeqDriver d/t) | A | `ref_typespec` of the enum typedef `UVM_SEQ_ARB_TYPE` in a module-imported package copy: `work@svaunit_vpi_interface.uvm_pkg::UVM_SEQ_ARB_TYPE` / `uvm_pkg::UVM_SEQ_ARB_TYPE` | emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) |
| N0900 | 2 (SimpleUVM d/t) | A | the same object: `work@env::uvm_pkg::UVM_SEQ_ARB_TYPE` / `work@top.uvm_pkg::UVM_SEQ_ARB_TYPE` | emitPackage (ParamEmit.cpp) |
| N1424 | 1 (Scoreboard d) | A | the same object: `work@my_scoreboard::uvm_pkg::UVM_SEQ_ARB_TYPE` / `uvm_pkg::UVM_SEQ_ARB_TYPE` | emitPackage (ParamEmit.cpp) |
| N0778 | 2 (BuildUVMPkg d/t) | B | the same object: `uvm_pkg::uvm_pkg::UVM_SEQ_ARB_TYPE` / `uvm_pkg::UVM_SEQ_ARB_TYPE` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < buildStructTs (TypeEmit.cpp, law structInlineEnumMemberTs113) |
| N0073 | 2 (Earlgrey_0_1 d/t) | B | a folded constant's span stops at the package qualifier in golden (`15483:12-34`, ours `-57`; r11u205 residue 1: `dm::Data0`, `top_pkg::TL_SZW-1`) | fillSizeDimRange (ModuleEmit.cpp, law sizeDimOvrChain4) < emitInstance (ModuleEmit.cpp) |
| N0897 | 2 (BlackBePipeInt d/t) | A | 8 ours-only `parameter dev_addr_width_gp` copies under ref_obj (behind N0923, pair A's credit) | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < emitPackage (ParamEmit.cpp) |
| N0284 | 2 (Scr1SvTests d/t) | B | an ours-only folded constant under an elaborated cont_assign, behind the structural N0791 (the Surelog binding defect) | emitExpr (ExprEmit.cpp) < emitCaStructParamSubst55 (ModuleEmit.cpp, law caStructParamPathBaseAtMember) |
| N0727 | 1 (Rggen d) | B | the folded bound of the interface array `register_if[...]` carries `block_0.sv` where golden has `rggen_apb_adapter.sv` (r11u205 residue 2) | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < fillSizeDimRange (ModuleEmit.cpp) |
| N0040 | 2 (InterfaceModPort d/t) | B | `logic_typespec` 27:3-8 / 27:3-21 (the harness flag) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp) |
| N0422 | 2 (LogicTypespec d/t) | B | (a user decision) | makeTypespec (TypeEmit.cpp) < emitPackage (ParamEmit.cpp) |
| N0056 | 2 (PreprocTest d/t) | B | `bit` lexed as an identifier in a `.vh` file (not implementable, pass 186 R5) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) |

**The nine UVM row-modes are all headed by ONE object after the pairs**: the `ref_typespec` of `uvm_pkg`'s enum typedef
`UVM_SEQ_ARB_TYPE` read in a package copy, whose golden full name carries the importing context in four spellings
(`work@<module>.uvm_pkg::`, `work@<class>::uvm_pkg::`, `uvm_pkg::uvm_pkg::`) where ours is bare or `work@top.`-prefixed.
It is the enum-typedef face of the family pair A is credited with (N0540 / N0689: the same prefixes on the class typedef
`uvm_event_pool`, ParamEmit `emitPackage`). Surelog's naming here is context-dependent (the memory note: never
"fix" `pkg::pkg::` uniformly), so one decode of the importing-context prefix covers N0540 N0689 N0582 N0900 N1424 and
the TypeEmit twin N0778.

### T1. Ranked OPEN clusters, all rows (top 20 of 274)

| # | cluster | rows left (4acbe8a5) | sl/u2r | tests | families | first-open heads | alone | probe (after r11u205) | ground | status | key | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0007 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 4 | B | OPEN (map 12 gave it to pair A r11u201; pass 201 left it) | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitSyntaxExpr (TypeEmit.cpp, law defGenPathSel161) < operator() (ModuleEmit.cpp) (the UVM records: ExprEmit, section 1.5) |
| 2 | N0408 | 6 (6) | 6/0 | 3 | UVM | 0 | 0 | 4 | A | OPEN (map 12 ground-A+B step 7) | `struct\|ours-only:fewer-copies\|unsupported_typespec\|under:ref_typespec` | operator() (StmtEmit.cpp, law cloneLoopVarShared37) < emitStmt (StmtEmit.cpp, law foreachLoopVarObjs9) |
| 3 | N0008 | 5 (5) | 5/0 | 3 | Earlgrey UVM | 0 | 0 | 23 | B | OPEN (map 12 ground-A+B step 7) | `fullname\|ref_typespec\|golden-empty\|under:constant` | emitParameters (ParamEmit.cpp, law timeLitParamIntTs) < emitPackage (ParamEmit.cpp) |
| 4 | N0449 | 5 (5) | 5/0 | 3 | Earlgrey UVM | 0 | 0 | 3 | B | OPEN (map 12 ground-A+B step 9) | `fullname\|ref_typespec\|tok:id@id.id::id.->id::id::id::\|under:typespec_member` | operator() (TypeEmit.cpp, law cloneStructMemberBareTdAlias207) < importCloneBareTdAlias16 (TypeEmit.cpp) |
| 5 | N0182 | 5 (5) | 5/0 | 3 | Earlgrey UVM | 0 | 0 | 2 | B | OPEN (map 12 ground-A+B step 9) | `struct\|golden-only:fewer-copies\|typespec_member\|under:struct_typespec` | operator() (TypeEmit.cpp, law cloneStructMemberBareTdAlias207) < importCloneBareTdAlias16 (TypeEmit.cpp) |
| 6 | N0467 | 5 (5) | 5/0 | 3 | UVM | 0 | 0 | 0 | B | OPEN (map 12 ground-A+B step 5) | `struct\|ours-only:fewer-copies\|array_typespec\|under:ref_typespec` | exportDesign (UhdmExporter.cpp, law enumNoBind13) |
| 7 | N0040 | 4 (4) | 4/0 | 2 | Earlgrey + InterfaceModPort | 2 | **2** | 14 | B | OPEN (map 12 gave it to pair B r11u202; passes 202 and 206 left it) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp) |
| 8 | N0582 | 4 (4) | 4/0 | 2 | UVM | **4** | 0 | 0 | A | OPEN (map 12 ground-A+B step 11) | `fullname\|ref_typespec\|tok:id@id.->\|under:enum_typespec` | emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp) |
| 9 | N0073 | 4 (4) | 4/0 | 2 | BlackBePipeInt Earlgrey | 2 | 0 | 4 | B | OPEN (map 12 ground-A+B step 4) | `span\|constant\|endcol\|under:operation` | fillSizeDimRange (ModuleEmit.cpp, law sizeDimOvrChain4) < emitInstance (ModuleEmit.cpp) |
| 10 | N0478 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 17 | B | OPEN (map 12 ground-A+B step 11) | `struct\|golden-only:fewer-copies\|type_parameter\|under:param_assign` | - |
| 11 | N0479 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 16 | B | OPEN (map 12 ground-A+B step 11) | `struct\|golden-only:fewer-copies\|class_typespec\|under:ref_typespec` | copyClassTdSpecParams1 (UhdmExporter.cpp, law classTdCloneSpecOverridesOwnArgs112) |
| 12 | N0480 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 16 | B | OPEN (map 12 ground-A+B step 11) | `struct\|ours-only:fewer-copies\|int_var\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitImportedPkgClassMethodClones (ParamEmit.cpp) |
| 13 | N0481 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 16 | B | OPEN (map 12 ground-A+B step 11) | `fullname\|ref_typespec\|tok:id->id\|under:int_var` | emitInterfaceInstance (ModuleEmit.cpp, law caIfaceElabNetDeclAssignListing88) |
| 14 | N0485 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 14 | B | OPEN (map 12 ground-A+B step 11) | `fullname\|int_var\|tok:id->id\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) |
| 15 | N0484 | 4 (4) | 4/0 | 2 | Earlgrey + LogicTypespec | 0 | 0 | 13 | B | OPEN (map 12 ground-B step 2) | `name\|logic_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp) |
| 16 | N0492 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 8 | B | OPEN (map 12 ground-A+B step 11) | `fullname\|ref_typespec\|ours-empty\|under:array_typespec` | memberWrittenQueueTs149 (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) |
| 17 | N0495 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 7 | A | OPEN (map 12 ground-A+B step 11) | `struct\|golden-only:fewer-copies\|int_var\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) |
| 18 | N0496 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 7 | A | OPEN (map 12 ground-A+B step 11) | `struct\|golden-only:fewer-copies\|class_var\|under:ref_obj` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) |
| 19 | N0507 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 7 | B | OPEN (map 12 ground-A+B step 11) | `name\|bit_typespec\|tok:id::->\|under:ref_typespec` | bareScalarTdCopyOfFresh16 (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < bareScalarTdCopyOf (TypeEmit.cpp) |
| 20 | N0503 | 4 (4) | 4/0 | 2 | UVM | 0 | 0 | 6 | B | OPEN (map 12 ground-A+B step 11) | `fullname\|class_var\|tok:id::id->id\|under:array_var` | importVarCopy5 (ModuleEmit.cpp, law importCopyTsSubtreeNoInstance7) < classInheritsContainerImports23 (ModuleEmit.cpp) |

Every top cluster is a UVM (and Earlgrey / Scr1) cluster. Many of the 4-row clusters are MiniAmiq / SeqDriver's
class-method clones in the svaunit package, named through the wrong package (N0485 N0511-N0514 N0521 N0539 N0598 N0599
N0606 N0607: golden `uvm_pkg::uvm_object::get_name`, ours `svaunit_pkg::uvm_object::get_name`; TaskFuncEmit
`emitTaskFuncs` < ParamEmit `emitImportedPkgClassMethodClones`) or duplicated there (N0480 N0510 N0537 N0580: ours-only
variables under the clone's function). The whole ranking is cluster_index.csv; [evidence/tables/](evidence/tables/) holds the top 25 OPEN clusters per ground (`t_groundA.md`, `t_groundB.md`) and section 9 names the per-ground heads.

### T1c. Probe-only OPEN clusters with the most cases (after r11u205)

N0094 (30, B) and N1899 (30, B) (law ifacePortDeclTsAtPortDecl205 took 21 of their 51 cases; the rest are other writers,
r11u205 3.4), N0739 (27, A: pass 198 R9, golden's elaborated `assign o = P` of a struct parameter has no right side),
N1903 / N1904 (21 / 20, A: ParamEmit `memLeftPatParamClone26`), N0476 / N0477 (20 each, A: ParamEmit
`makeBareVecParamTs`), N1905 (17, B), N1907 (15, B), N1906 / N1908 / N1910 / N1911 (14 each, B). The cases' first
records: N0263 54 (cfg_func_width_loop's stamp family, A), N0284 44 (B), N0039 43, N0738 27, N0739 26, N0003 24,
N1911 14, N0485 12, N0682 12, N1916 12. The laws with the most NE cases: tpPackedArrayTsVar108 28 of 73,
caIfacePortDeclNetMint93 27 of 35, nestedParamActualTs6 23 of 41, srlgUnvaluedActualLitRetFold8 23 of 98.

## 6. The fail list with sites (fail_list.csv, probe_fail_list.csv)

Every STRICT_NOTEQUAL row-mode with its first cluster at 4acbe8a5, that cluster's coverage, ground and site, all its
clusters, the strict cell after r11u205, its first OPEN cluster after the pairs, the open clusters left and whether it
clears. probe_fail_list.csv is the same per case (724). By test, sorted by cluster count (a `-` mode is not NE):

| corpus | test | cell d / t | clusters d/t | first cluster (ground) | first site | after r11u205 | first open after the pairs | open after pairs (A/B) | clears | downstream |
|---|---|---|---|---|---|---|---|---|---|---|
| sur | HierPathTypespec | - / fullname(1) | -/1 | N1174 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) | same | - | -/0 | yes (pair B, optimistic) | - |
| sur | InterfArrayBind | fullname(3) / - | 1/- | N0427 (A) | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp) | **fullname(1)** / - | - | 0/- | yes (pair A, optimistic) | - |
| sur | InterfaceModPort | endcol(12) / endcol(12) | 1/1 | N0040 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) | same | N0040 | 1/1 (0/1) | no | - |
| sur | PreprocTest | endcol(2) / endcol(2) | 1/1 | N0056 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) | same | N0056 | 1/1 (0/1) | no | - |
| sur | UnitElabBlock | file(2) / file(1) | 2/1 | N0016 (A) | emitExpr (ExprEmit.cpp) | **equal / equal (r11u205, measured)** | - | 0/0 | yes (r11u205, measured) | - |
| sur | FuncStructValSimple | file(39) / file(59) | 3/3 | N0086 (A) | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) | same | - | 0/0 | yes (pair A, optimistic) | - |
| sur | LogicTypespec | endline(3) / endline(3) | 4/4 | N0422 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) | same | N0422 | 4/4 (0/4) | no | - |
| sur | InterfaceStructMemberPort | fullname(6) / fullname(6) | 5/5 | N1134 (B) | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) | same | - | 0/0 | yes (pair B, optimistic) | - |
| sur | FuncStructVal | endcol(95) / endcol(165) | 7/8 | N1096 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) | same | - | 0/0 | yes (pair A, optimistic) | - |
| sur | Scr1SvTests | type(1) / type(1) | 17/17 | N0791 (B) | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) | same | N0284 | 9/9 (0/9) | no | - |
| sur | BlackBePipeInt | fullname(2) / fullname(2) | 26/24 | N0923 (A) | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefModuleCopy) | same | N0897 | 22/20 (18/4) | no | - |
| sur | Rggen | defname(142) / - | 24/- | N0145 (B) | emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) [map 12 pin; fixed in TypeEmit, section 1.6] | **file(4)** / - | N0727 | 19/- (3/16) | no | - |
| sur | Earlgrey_0_1 | fullname(76) / fullname(76) | 69/65 | N0945 (B) | emitSyntaxExpr (TypeEmit.cpp, law hpMidGenvarSelect) < operator() (ModuleEmit.cpp) | **endcol(46) / endcol(46)** | N0073 | 59/55 (34/25) | no | - |
| sur | BuildUVMPkg | line(11) / line(11) | 76/76 | N0039 (B) | emitExpr (ExprEmit.cpp, law castTargetKeywordTypespecKind96) [fixed in TaskFuncEmit, r11u205 4.3] | same | N0778 | 23/23 (15/8) | no | - |
| sur | Scoreboard | fullname(103) / - | 89/- | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) | same | N1424 | 11/- (1/10) | no | - |
| sur | SimpleUVM | fullname(95) / fullname(95) | 97/97 | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) | same | N0900 | 20/20 (5/15) | no | - |
| sur | SeqDriver | fullname(65) / fullname(65) | 201/201 | N0540 (A) | emitPackage (ParamEmit.cpp, law pkgImportCloneLastWriter32) | same | N0582 | 117/117 (28/89) | no | - |
| sur | MiniAmiq | file(71) / file(71) | 203/203 | N0144 (B) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage | same | N0582 | 119/119 (33/86) | no | - |
| uhd | anon_struct_packed_dim | fullname(43) / fullname(43) | 2/2 | N0014 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | OutputSizeWithParameterOfInstanceInitializedByStructMember | line(8) / line(8) | 4/4 | N0191 (A) | emitDroppedCall14 (StmtEmit.cpp, law classArgBind12) | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | ibex_tracer | fullname(579) / fullname(579) | 6/6 | N0563 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | cfg_func_width_loop | line(3) / line(3) | 7/7 | N0263 (A) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec | same | - | 0/0 | yes (pairs A+B, optimistic; decoded, no law) | IDENTICAL |
| uhd | struct_param_func_config | fullname(5) / fullname(5) | 7/7 | N0817 (A) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) | same | - | 0/0 | yes (pair A, optimistic; decoded, no law) | IDENTICAL |

**The count: 42 row-modes / 23 tests -> 40 / 22 after r11u205 (measured) -> 22 / 12 after both pairs (optimistic; 30 /
17 without the 8 named optimisms of section 4); probe 724 -> 704 -> 593.**

## 7. Structural rows and downstream-visible faces

### 7a. Structural rows (first field depth / type / count)

| row | 4acbe8a5 | after r11u205 | first cluster | what it needs |
|---|---|---|---|---|
| Scr1SvTests d/t | `type(1)` | `type(1)` | N0791 `struct\|golden-only:fewer-copies\|ref_obj\|under:cont_assign` (B, ModuleEmit `emitContAssigns`) | r11u200 3d: `assign ifu2imem_cmd_o = SCR1_MEM_CMD_RD;` — golden SHARES the definition cont_assign and binds the right side to an IMPLICIT `logic_net` with no file, because Surelog's per-file compilation units leave the include-guarded `$unit` enum constant unresolved; ours folds it. **A Surelog binding defect: no law without inventing an unresolved-name net slang resolves.** Behind it 8 more B clusters (UhdmExporter `cloneUnitParamRhs` / law unitRefSubst N0021 N0921 N1009 N1112 N1113; TypeEmit `emitSyntaxExpr` N0030 N2405; ModuleEmit N0284). Pass 201's laws took its A half (`endcol(11)` -> `type(1)`) |

No other corpus row is structural. The probe set holds 33 `depth` and 71 `type` first fields at 4acbe8a5 and after
r11u205. Note for every analyst: `uhdm-strictcmp` stops at the first structural record; the records past it are
visible only to the aligned analyzer (cfg_func_width_loop's kept call, section 10).

### 7b. Downstream-visible faces ([drivers/dsfaces.py](drivers/dsfaces.py): the gate's own `one()`, a fresh `GOLDEN_CACHE`, both binaries; [evidence/downstream/](evidence/downstream/))

199 cases (map 12's 127 incl. the two LogicTypespec scratch copies, r11u205's 62, r11u204's rp2 / x5 / DF e06 e08, pass
206's A/a12, v11u202's PP/p05) + 6 (pass 196's DF/d01 d03, r11u204's V191 cc4 cc6, DF e01 e07). **HEAD: 154 IDENTICAL,
21 EQUIVALENT, 17 DIVERGENT, 6 STATUS_DIFF, 1 SLANG_REJECT; law205: the same, row for row (0 verdict changes).** Since
r11u205's pristine measurement at 3668bf30 no verdict changed (passes 206 and r11u208 move none of these faces).

| face | cases | map 12 (ddc67d87) | **HEAD (4acbe8a5)** | law205 | what it needs |
|---|---|---|---|---|---|
| r11u173 N1: `$high` onto an implicit net in a generate-for | rq/q08 | DIVERGENT | **DIVERGENT** | same | ModuleEmit's generate-scope cont_assign has no sysFold branch (B) |
| r11u173 N2: `g[S.a].x` | hw/w12, w13 | DIVERGENT | **DIVERGENT** | same | the struct-parameter member index fold in a hier_path (ExprEmit, A) |
| pass 158: the size cast as a whole CA value | sc/c10, c12 | EQUIVALENT | **EQUIVALENT** (15 IDENTICAL) | same | ModuleEmit emitBlock / emitContAssigns |
| pass 160: LogicTypespec's defect candidate | LT/l02 (l01) | DIVERGENT (IDENTICAL) | **DIVERGENT** (IDENTICAL) | same | a user decision |
| pass 181: unsized based literal as a whole CA right side | us/u02, u08 | EQUIVALENT | **EQUIVALENT** | same | Surelog's cont_assign writer clone (ModuleEmit) |
| r11u185: generic ANSI interface port after an interface-typed port | GV v07 v08 v09 v15, PG/p04; v02 v11 | STATUS_DIFF; EQUIVALENT | **STATUS_DIFF; EQUIVALENT** | same | ModuleEmit (stage 1) |
| r11u185 PU/u06, UD/u04 | u06, u04 | DIVERGENT | **DIVERGENT** | same | ParamEmit tagged patterns (A); ModuleEmit instance-array UDP form (B) |
| v11u171: UDP-form swallow | Q c02 c08 c14 | EQUIVALENT | **EQUIVALENT** | same | unchanged since map 10 |
| r11u194 N1 / r11u200 K | z01, x01, K k01-k08 | z01 IDENTICAL, x01 EQUIVALENT, k02 EQUIVALENT | **the same** | same | closed by pass 196 but x01 / k02 |
| r11u190 N6: 70-bit digit-separator localparam | US/u01 | STATUS_DIFF | **STATUS_DIFF** | same | not decoded |
| pass 186's P face | U (18) | 15 IDENTICAL; u08 u_p02 u_p07 EQUIVALENT | **the same** | same | law elabCaConstLhsSized191's reach (r11u204 N6) |
| r11u199 N7: `$bits` of a select in a generate body | W/w8, B b01-b05 | DIVERGENT (law200 IDENTICAL) | **IDENTICAL** | same | **closed by passes 201 + 202** (law genBlockBitsKeepsSelect200, both halves) |
| r11u199 N6 / N5 / N4 | C/c06, X/x06; T/t03, X/x05 | DIVERGENT; EQUIVALENT | **the same** | same | ModuleEmit net-declaration assignment (B); a Surelog defect; not reached |
| **r11u204's encoding faces** | DF/e06, e08 (named / empty-slot omission, B3) | - | **IDENTICAL** (the kept call reproduces golden's netlist) | same | the complete B3 fold needs `constCallFold`'s INT:0 binding (r11u204 N1) |
| | pass 196's DF/d01, d03 | IDENTICAL since r11u204 | **IDENTICAL** | same | - |
| | V191/cc4, cc6 | cc4 IDENTICAL, cc6 EQUIVALENT (N10) | **cc4 IDENTICAL, cc6 EQUIVALENT** | same | cc6: the fold's value encoding (`srlgRedIntSyn`) |
| **r11u205's faces** | B3/b05, b07 (nested / mixed named omissions) | - | **DIVERGENT** | same | the fold-value model of `constCallFold` (r11u205 4.1) |
| | D5/d01, d03 (the default-item keep, the default-never-runs value) | - | **DIVERGENT** | same | r11u205 4.2: UHDM's `evalStmt` never runs a default item |
| | TP t12; t04 t06 t08 t09 t17; FT/f03 | - | **DIVERGENT; EQUIVALENT; SLANG_REJECT** | same | type-parameter shapes stage-1 unequal already |
| **pass 206's A/a12** (a module-scope function with type-parameter casts) | v11u206repro A/a12 | - | **DIVERGENT** | same | ExprEmit's module-scope type-parameter cast (pass 206 TE/e07) |
| **v11u202's PP/p05** (`input var` / `input bit` packed ports) | v11u202repro PP/p05 | - | **DIVERGENT** | same | ModuleEmit port / process emission (v11u202 V6) |
| **r11u204 N7** (split real ports, twice instantiated) | V191/rp2 | - | **DIVERGENT** | same | not decoded |
| **r11u204 N8** (a type-parameter array in a generate scope) | X/x5 | - | **DIVERGENT** | same | golden folds the ranges at the left operand (ModuleEmit / TypeEmit) |

## 8. The away-moved-record census of every landing since map 12 ([evidence/away/](evidence/away/), [drivers/awayrows.py](drivers/awayrows.py))

Method (r11u204's / r11u208's `awayrows.py`, map 12's census chain-keyed): the HEAD binary under one landing's
switches is swept (probe + both corpora, both modes: `/tmp/r11u211_st<k>`) beside the pristine HEAD sweep
`/tmp/r11u211_sP`; every database whose bytes differ is walked by `uhdm-strictcmp` against itself (golden, the
landing-off state, HEAD), each record keyed by its ancestor chain and, as map 12 did, flat (depth dropped); **away** =
records golden and the landing-off state share that HEAD lost (a field the landing moved away from golden), **toward**
= the reverse. Measured at HEAD, it answers both "did the landing move a record away" and "does any such record survive
at HEAD".

| landing (state) | switches | databases moved | away, chain-keyed | away, flat | toward (chain / flat) | earlier report | survives at HEAD |
|---|---|---|---|---|---|---|---|
| r11u204's refinements (st4) | `R11V204_OFF` | 9 (the UVM rows d/t, Scoreboard d) | **0** | 0 | 0 / 0 (bytes only) | r11u204: 0 for passes 196 / 198; r11u208: "moves nine UVM databases in bytes only": **reproduced** | 0 |
| pass 202 (st2) | `R11U202_OFF` (its eight laws, the ten r11u200 ground-B laws, v11u202's five refinements) | 52 (30 cases, 22 corpus) | **0** | 0 | 1337 / 1323 | v11u202: 0 after its refinements; r11u208: 52 databases, 1337 toward, 0 away: **reproduced exactly** | 0 |
| pass 201 (st1) | `R11U201_OFF R11V201_OFF R11U200_NEWARRHP_OFF R11U200_UNITFOLD_OFF R11U200_FOLDDEPTH_OFF` (r11u208's landing-201 state) | 18 (5 cases, 13 corpus) | **0** | 0 | 1246 / 1246 | r11u208: 18 databases, 1246 toward, 0 away: **reproduced exactly** | 0 |
| pass 206 (st6) | `R11U206_OFF` | 6 (3 r11u113 cases, arb_idx_cast d/t, Scoreboard d's draw) | **0** | 0 | 13 / 13 | v11u206: 0 lost on every corpus mover: **reproduced** | 0 |
| r11u208's refinement (st8) | `R11V208_OFF` | 1 (Scoreboard d's draw) | **0** | 0 | 0 / 0 | r11u208: fires on no corpus row or case: **reproduced** | 0 |
| **positive control**: pass 202 reversed (`sP` as the off side, st2 as ON) | | 52 | **1337** | **1323** | 0 | r11u208's R11V202_OFF control read 74 | - |
| **pass 207 (landed at 62ac216e during this pass; st7 vs h7, section 13)** | `R11U207_OFF R11V207_OFF` | 23 (10 cases, 13 corpus) | **0** | 0 | 701 / 717 | pass 207: 13 corpus + 10 probe databases, 0 lost: **reproduced**; reversed control 701 away | 0 |
| r11u205's patches (unlanded; law205 vs pristine) | | 32 (23 cases, 9 corpus) | **0** | 0 | 755 / 755 | r11u205: 0 lost, 767 gained at 3668bf30 (arb_idx_cast's 4 now pass 206's) | - |
| lawA205 alone / lawB205 alone | | 6 / 29 | **0 / 0** | 0 / 0 | 5 / 750 | | - |

**No landing since map 12 moved a strict record away from golden on any corpus row-mode or probe case, and none
survives at HEAD.** Map 12's own AWAY finding (74 records of the r11u200 patches: N2467 / N2468 and Earlgrey's 4
port-span records) was refined by v11u202 before pass 202 landed; both keys are absent at HEAD. The state sweeps'
compare lines reproduce the committed history (section 2a), so each state is the landing-off state it claims to be.

## 9. The per-ground briefs (on top of r11u205 measured + both pairs optimistic)

The base is 20 row-modes / 11 tests cleared. **The remaining 22 row-modes carry** by open-cluster count 1: 4
(InterfaceModPort d/t, PreprocTest d/t), 4: 2 (LogicTypespec), 6 or more: 16; by ground: B only 8 (InterfaceModPort,
PreprocTest, LogicTypespec, Scr1SvTests), both 14. Every OPEN cluster of ground A (109) clears 0 row-modes alone; every
OPEN cluster of ground B (165) clears 8 (4 of them the harness flag and the `.vh` face). **No remaining row ends on
ground A alone.** The greedy picks by row-modes cleared per cluster added ([evidence/report.txt](evidence/report.txt)
section 8, [evidence/greedy13.json](evidence/greedy13.json)); a candidate is the whole open set of one remaining row.

**Ground A.** Empty: every remaining row needs ground B too.

**Ground B, deep (whole rows).**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 22 | 12 | InterfaceModPort d/t (the harness flag) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp) |
| 2 | N0056 | 2 | 24 | 13 | PreprocTest d/t (not implementable) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) |
| 3 | N0083 + N0422 + N0484 + N1149 | 2 | 26 | 14 | LogicTypespec d/t (a user decision) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) |
| 4 | N0021 N0030 N0284 N0791 N0921 N1009 N1112 N1113 N2405 | 2 | 28 | 15 | Scr1SvTests d/t (N0791 is the Surelog defect of 7a) | cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) |

**Joint (both grounds), deep.**

| step | clusters | +row-modes | cum row-modes | cum tests | rows |
|---|---|---|---|---|---|
| 1-4 | as ground B | 8 | 28 | 15 | InterfaceModPort, PreprocTest, LogicTypespec, Scr1SvTests |
| 5 | 20 (5 A, 15 B; first N0007) | 2 | 30 | 16 | SimpleUVM d/t |
| 6 | +2 (N0447 N1424) | 1 | 31 | 17 | Scoreboard d |
| 7 | 21 (15 A, 6 B; first N0017) | 2 | 33 | 18 | BuildUVMPkg d/t |
| 8 | 22 (18 A, 4 B; first N0063) | 2 | 35 | 19 | BlackBePipeInt d/t |
| 9 | 19 (3 A, 16 B; first N0141) | 1 | 36 | 20 | Rggen d |
| 10 | 44 | 1 | 37 | 20 | Earlgrey_0_1 t |
| 11 | +13 | 1 | 38 | 21 | Earlgrey_0_1 d |
| 12 | ~109 | 2 | 40 | 22 | SeqDriver d/t |
| 13 | +9 | 2 | 42 | 23 | MiniAmiq d/t |

In short, for the next two refills:

* **Module/type ground (pair B after r11u209).**
  1. **r11u205's three ground-B laws, first** (r11u209's first item; measured here in lawB205 at 4acbe8a5: 20 probe
     conversions, Earlgrey d/t `fullname(76)` -> `endcol(46)`, Rggen d `defname(142)` -> `file(4)`, 0 away, 0
     downstream change; the rebase conflict is only the call site after pass 206's `tpCastUseBindsDefDefault206`).
  2. **The near rows of this ground**: none implementable alone — InterfaceModPort d/t is ONE cluster (N0040) but
     converts only with the harness flag (pass 188 R1: a harness change, outside the exporter), PreprocTest d/t is the
     `.vh` face, LogicTypespec a user decision. **Scoreboard d is the nearest real row: 11 open clusters after the pairs,
     10 of them B** (N0007's hier_path ref name, whose UVM records are ExprEmit's; N0008, a design-level param_assign
     constant's ref_typespec named `uvm_pkg` where golden stores no name; N0151, golden's extra ref_typespec copies of a
     package parameter (`UVM_CHECK_FIELDS`) read in the field-automation calls; N0447 the
     `uvm_analysis_port` param_assign file, N0458 the `uvm_active_passive_enum` file, N0467, N0691 / N0692 the
     `UVM_LARGE_STRING` / `UVM_SMALL_STRING` value `INT` vs ours `UINT`, N0732 / N0734 `uvm_random_seed_table_lookup`'s
     importing-context names) plus A's N1424; **SimpleUVM d/t: 20 (15 B)**.
  3. **The heads the pairs leave on the big rows**: BuildUVMPkg N0778 (the `UVM_SEQ_ARB_TYPE` ref name
     `uvm_pkg::uvm_pkg::`: decode it WITH pair A's N0582 / N0900 / N1424 family, section 5), Earlgrey N0073 (a folded
     constant's span to the package qualifier; r11u205 residue 1 found the qualifier span mostly ground A: pin
     ModuleEmit `fillSizeDimRange`), Rggen N0727 (the interface-array bound's file from the instantiating context,
     TypeEmit `emitSyntaxExpr` < ModuleEmit `fillSizeDimRange`), Scr1SvTests N0284 (behind the Surelog defect).
  4. **The UVM ground-B families** (165 B clusters with a row; MiniAmiq / SeqDriver carry 86 / 89 of them: the
     svaunit class-method clone names N0480 N0485 N0510-N0516, the module-imported copy names N0503 N0504 N0732 N0734,
     the `unsupported_typespec` / array copies N0467 N0478 N0479).
  5. Not routed: InterfaceModPort (N0040: the harness), PreprocTest (N0056), LogicTypespec, Scr1SvTests' N0791.
* **Expression/parameter ground (pair A after r11u207, which landed as pass 207 at 62ac216e: section 13).**
  1. **r11u205's law_exprstmt, what is left of it**: elabIfArrIdxChainName205 (InterfArrayBind d `fullname(3)` ->
     `fullname(1)`, 0 away); its hiddenBlockVarNetNoFile205 (UnitElabBlock d/t, measured converting in lawA205) is
     superseded by pass 207's hiddenBlockVarMintNoFile207 and must not be landed.
  2. **The importing-context prefix family, as ONE decode**: N0540 / N0689 (credited to r11u207) and their enum-typedef
     face N0582 (MiniAmiq d/t, SeqDriver d/t), N0900 (SimpleUVM d/t), N1424 (Scoreboard d) are the FIRST OPEN record of
     7 of the 9 UVM row-modes after the pairs, all minted in ParamEmit `emitPackage`; BuildUVMPkg's twin N0778 is
     TypeEmit's.
  3. **BlackBePipeInt's A half**: after N0923 (credited), N0897 heads both modes (8 ours-only parameter copies under
     ref_obj, ParamEmit `emitParameters`); 18 of its 22 open clusters are A.
  4. **struct_param_func_config's and cfg_func_width_loop's A halves** (decoded by r11u200, no law) and **InterfArrayBind
     d's module-scope target** (r11u205 residue 3).
  5. **The UVM ground-A families** (109 A clusters with a row: the 4-row ExprEmit / StmtEmit clusters N0495 N0496 N0547
     N0555 N0557 N0564 N0569 N0573 N0578 N0579 N0584 N0586 N0587 N0597 N0600 N0603 N0604, the 6-row N0408) and
     **Earlgrey's A half** (34 of its 59 open clusters).
  6. The largest A case-only clusters: N0739 (27 cases, pass 198 R9), N1903 / N1904 (21 / 20), N0476 / N0477 (20
     each).

## 10. Prediction audit of map 12 ([evidence/audit.txt](evidence/audit.txt); `drivers/audit13.py` reads the committed baselines at every landing)

**Since map 12 (50 row-modes at ddc67d87), 8 row-modes converted**: pass 202 4 (ClassTypeParam d/t, int_types d/t),
pass 201 2 (SVSwitch d/t, with pass 202's half), pass 206 2 (arb_idx_cast d/t). **All 8 were predicted by map 12**
(its r11u200 + pairs column; 8 of 8), and 0 converted row was not predicted.

| map 12 predicted | row-modes | converted | by | still open at 4acbe8a5 |
|---|---|---|---|---|
| r11u200 patches, MEASURED | 4 (SVSwitch d/t, int_types d/t) | **4 of 4** | passes 202 + 201 (the patches landed) | 0 |
| pair A r11u201, optimistic | 7 (FuncStructValSimple d/t, FuncStructVal d, InterfArrayBind d, UnitElabBlock t, struct_param_func_config d/t) | 0 | - | 7 (UnitElabBlock t converts under r11u205's A law, measured here, unlanded) |
| pair B r11u202, optimistic | 9 (ClassTypeParam d/t, InterfaceModPort d/t, InterfaceStructMemberPort d/t, HierPathTypespec t, arb_idx_cast d/t) | **4** (ClassTypeParam d/t: pass 202; arb_idx_cast d/t: pass 206, the next pair-B refill) | | 5 |
| both pairs, optimistic | 10 (UnitElabBlock d, FuncStructVal t, OutputSize d/t, anon_struct_packed_dim d/t, cfg_func_width_loop d/t, ibex_tracer d/t) | 0 | - | 10 (UnitElabBlock d converts under r11u205's A law alone) |
| section-9 lists (ground B / deep B / deep A+B) | 4 / 6 / 20 | 0 | - | all |
| **any of them** | **50** | **8 (16%)** | | 42 |

Map 12 credited 30 row-modes (12 of them named optimisms): **8 of 30 converted (27%); 6 of the 18 without the named
optimisms (33%), and 2 of the 12 optimism credits (ClassTypeParam d/t: "credited through named rows, never decoded" —
pass 202 decoded and converted it)**.

**Why 22 predicted row-modes did not convert.** Pair A r11u201 took its own brief's laws (the operation-context stamp,
the method-call path names, the new[] refinement) and not map 12's carried A list: FuncStructVal*, InterfArrayBind,
struct_param_func_config stayed "not reached" (pass 201 section 7 item 10). UnitElabBlock d/t: the fix is ExprEmit's
hidden-block mint, decoded by r11u202 and written by r11u205 (measured here), waiting for pair A's r11u210.
InterfaceModPort d/t: the harness flag (a named optimism, not attempted). InterfaceStructMemberPort d/t,
HierPathTypespec t, anon_struct_packed_dim d/t: decoded by pass 206 (R2-R4) without a law. OutputSize, ibex_tracer:
not attempted by passes 202 / 206. cfg_func_width_loop d/t: both halves decoded, neither written.

**Site pins** (map 12's pin of each converted row's first cluster, against the files of the landing laws, read from
src by the section sign): **8 of 8 name a fix file, 6 at the mint** (SVSwitch N0007 ExprEmit; ClassTypeParam N1081 /
N1599 UhdmExporter; int_types N0912 TypeEmit) **and 2 at a caller** (arb_idx_cast N0090: pin TypeEmit
`makeTypeParamDefaultTs`, laws in UhdmExporter's post-pass). Map 12 for map 11: 10 of 10; map 11 for map 10: 24 of 24.
**Two pin lessons from this interval**: (1) UnitElabBlock d — map 12 read it as needing N0011 (pin TypeEmit
`thisImplicitNetBoth38`, ground B) plus N0016 (ExprEmit, A); r11u205's A law alone converts both modes (measured here):
UnitElabBlock's N0011 record is the same hidden-block net as N0016 reached through a ref_obj, and map 12's N0011 pin is
another row's mint. A cluster's pin describes its example row; a row can carry the same key from a different mint.
(2) cfg_func_width_loop's kept call N0133 / N0487: r11u205 read it "covered at the base" from the tool's first 60
records, but the tool stops at the structural record `#472`; the aligned analyzer still sees the golden-only
`func_call` and the ours-only constant under the elaborated cont_assign. **Read the analyzer's records past a walk
divergence before calling a cluster covered.**

**The rate over time.** Map 12's 30 credited predictions converted 8 (27%) over six landings; map 11's 60 converted 10
(17%), map 10's 58 had converted 24 (41%) and map 9's 68 34 (50%) by their successors. Every conversion of the last
three intervals was predicted (10 / 10 and 8 / 8); what fails is the pair credit on rows the pairs' own briefs then do
not take.

**Clusters** (audit section D): map 12's covered set (161): 42 gone, 6 fell (N0007 11 -> 9, N0040 9 -> 4, N0072 11 ->
9, N0090 8 -> 2, N0175 9 -> 4, N0448 3 -> 1), 113 unchanged. Map 12's section-9 lists (309): 4 gone (N0375, N0605,
N0610, N0629), 3 fell (N0056 11 -> 2, N0164 5 -> 4, N0203 5 -> 2), 1 grew (N0318 6 -> 7), 301 unchanged. Two unrouted
clusters cleared rows or cases (N0509 rows 2 -> 0, N0765 cases 2 -> 0). The item-by-item recount is audit.txt section F.

## 11. The family view

| family | row-modes / tests | clusters per row at 4acbe8a5 | after r11u205 (measured) | open per row after r11u205 + both pairs | distinct clusters: 4acbe8a5 -> r11u205 -> + pairs | cleared |
|---|---|---|---|---|---|---|
| UVM (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg) | 9 / 5 | 76-203 | 76-203 | 11-119 | 252 -> 252 -> 163 | 0 |
| Earlgrey_0_1 | 2 / 1 | 65-69 | 60-64 | 55-59 | 78 -> 73 -> 68 | 0 |
| Rggen (default only) | 1 / 1 | 24 | 21 | 19 | 24 -> 21 -> 19 | 0 |
| BlackBePipeInt | 2 / 1 | 24-26 | 24-26 | 20-22 | 26 -> 26 -> 22 | 0 |
| Scr1SvTests | 2 / 1 | 17 | 17 | 9 | 17 -> 17 -> 9 | 0 |
| ibex (tracer) | 2 / 1 | 6 | 6 | 0 | 6 -> 6 -> 0 | 2 (pairs A+B, optimistic) |
| SVSwitch, arb_idx_cast, ClassTypeParam, int_types | 0 | - | - | - | - | converted since map 12 |

**The near rows.** At 4acbe8a5, 7 row-modes in 5 tests are single-cluster: InterfArrayBind d N0427, InterfaceModPort
d/t N0040, PreprocTest d/t N0056, HierPathTypespec t N1174, UnitElabBlock t N0016 (UnitElabBlock d carries N0016 +
N0011, one object). Under r11u205 (measured) UnitElabBlock d/t converts. **After r11u205 and both pairs only
InterfaceModPort d/t and PreprocTest d/t keep one open cluster** (neither implementable in the exporter), LogicTypespec
d/t four; every other remaining row has 9 or more, the nearest Scr1SvTests (9, behind a Surelog defect), Scoreboard d
(11) and Rggen d (19).

**The UVM family: r11u175's census by family key** (`uvmcensus.py` + `uvmfamilies.py` over map 8's cluster keys, the
five UVM rows' default databases; [evidence/uvm/](evidence/uvm/)):

| family | ddc67d87 (map 12) | ddc67d87 + r11u200 (map 12) | **4acbe8a5** | **4acbe8a5 + r11u205 patches** |
|---|---|---|---|---|
| F2 object multiplicity | 11,862 | 11,840 | **11,840** | **11,840** |
| F5 reference full names | 9,293 | 8,698 | **8,038** | **8,038** |
| F6 file facets | 2,065 | 2,173 | **2,165** | **2,165** |
| F7 expression spans outside the pp model | 1,182 | 1,211 | **1,182** | **1,182** |
| F1 preprocessor location model | 720 | 720 | **720** | **720** |
| F4 formal / typespec / bound spans | 1,040 | 483 | **483** | **483** |
| F9 value / order / depth | 283 | 283 | **283** | **283** |
| F3 typedef relocation spans | 139 | 139 | **139** | **139** |
| F8 names | 565 | 95 | **95** | **95** |
| **all** | **27,149 (271 clusters)** | **25,642 (262)** | **24,945 (251)** | **24,945 (251)** |

Since map 12's measured r11u200 state, passes 201 / 202 / 206 took F5 another -660 (method-call argument chain names,
the operation-context stamp), F7 -29 and F6 -8; r11u205's patches fire on no UVM row (the census is identical). **The
largest UVM families are still F2 (11,840: the importer clones' copies, MiniAmiq 6,342 and SeqDriver 4,608) and F5
(8,038).**

**Order-blind uhdm-dump distance to golden** ([drivers/uvmdist.sh](drivers/uvmdist.sh),
[evidence/uvm/uvmdist.txt](evidence/uvm/uvmdist.txt)): strict records with the depth dropped, as multisets. Two
measures, both given: **dist** = records ours holds that golden lacks (v11u202 / v11u206's measure), **sym** = dist +
records golden holds that ours lacks (pass 201's measure).

| row-mode | map 12 ddc67d87 (sym) | **4acbe8a5 dist / sym** | 4acbe8a5 + r11u205 |
|---|---|---|---|
| MiniAmiq d / t | 15,559 | **6,634 / 15,058** | the same |
| SeqDriver d / t | 11,805 | **5,194 / 11,252** | the same |
| SimpleUVM d / t | 4,538 | **2,074 / 4,060** | the same |
| Scoreboard d | 3,451 | **1,526 / 3,029** | the same |
| BuildUVMPkg d / t | 1,907 | **776 / 1,551** | the same |
| Earlgrey_0_1 d / t | 8,570 / 8,316 | 4,599 / 8,554 and 4,293 / 8,300 | **4,481 / 8,318 and 4,175 / 8,064** |
| Rggen d | 10,659 | 4,463 / 10,655 | **4,325 / 10,379** |
| Scr1SvTests d / t | 251 | 117 / 195 | the same |
| UnitElabBlock d / t | 26 / 24 | 2 / 4 and 1 / 2 | **0 / 0 (converted)** |
| InterfArrayBind d | - | 3 / 6 | **1 / 2** |
| BlackBePipeInt d / t | 31,837 / 31,882 | 17,110 / 31,837 and 17,181 / 31,882 | the same |

The UVM figures equal v11u206's (dist, at 3668bf30 by pass 206's sweep) and r11u208's law column (dist / sym) exactly:
passes 206 and r11u208 move no UVM record. Pass 201's published figures (15,265 / 11,449 / 4,246 / 3,213 / 1,765) are
the sym measure of the pass-202-off state (r11u208 section 10).

## 12. Files

* **cluster_index.csv**: one row per cluster (847), with rows / probe at 4acbe8a5, after r11u205 (`rows_after_law`),
  after both pairs (`rows_after_pairs`), `alone_on_top_of_pairs`, `first_in_after_pairs`, `alone_on_pristine`,
  coverage, ground, site, map 12's rows, coverage and site (`map12_*`), families, probe laws, key, example.
* **clusters.csv**: row-mode x cluster with objects and a `first` flag; **probe_clusters.csv** the same per case.
* **fail_list.csv** (42) and **probe_fail_list.csv** (724): first cluster, coverage, ground, site, cluster counts,
  family, downstream verdict, the strict cell after r11u205, the first OPEN cluster after the pairs, the open clusters
  left, `clears`.
* **evidence/**: `clusters/` (record dumps, one example per cluster with a row or >= 3 cases: 493) and `objects.csv`
  (one example object for every cluster); `report.txt` (drivers/report13.py), `audit.txt`, `final13.txt`,
  `pristine_index.csv`, `greedy13.json`, `routes.json`, `ground_override.json`, `sites.json`, `pinwant.txt`, `pins/`,
  `evwant.txt`; `law205_on_4acbe8a5.patch` (the measured binary's source, NOT applied) and its ground halves
  `lawA205_on_4acbe8a5.patch` / `lawB205_on_4acbe8a5.patch` (the rebase pair B r11u209 needs at 4acbe8a5 and the patch
  pair A r11u210 lands as is); `controls/`; `determinism/`; `rebuild/`; `uvm/`; `away/` (every landing's census, the
  positive control, the r11u205 patches); `sweeps/` (`sweep_pristine.log`, `sweep_law205.log`,
  `byteverify_law205_vs_pristine.txt`, `probe_byte_movers_law205.txt`, `census/` (the frozen prediction),
  `attribution/`, `state_st*.summary.txt`); `addendum_62ac216e/` (section 13: `final13h.txt`, `fail_list_62ac216e.csv`, the
  pass-207 away census and its reversed control, the two sweep summaries); `tables/`; `downstream/` (`dsfaces_P.csv`, `dsfaces_L.csv`, the extra faces,
  `cases.txt`).
* **tests/LAWS.md** must be regenerated at landing (`python3 scripts/law_index.py`): a new `tools/probe/` directory adds one
  row (`| r11u211map |  |  | 0 | 0 |`, checked by rendering the index to scratch); this patch cannot touch `tests/`.
* **drivers/**: `run13.sh` (the pipeline as run), `env.sh`, `common.py` (key rewrite + the fence), `jobs.py`,
  `probejobs.py`, `probelaw.py`, `strict_runs.sh`, `run1.sh`, `cc.sh`, `strictcmp_x.cpp`, `objrank.cpp`, `analyze.py`,
  `final13.py` (+ `final13h.py`, the 62ac216e addendum keyed to this map's ids), `pinmulti.py`, `sites.py`, `mksites13.py`, `mkroutes13.py`, `crosssection.sh`, `report13.py`,
  `audit13.py`, `tables13.py`, `evid.py`, `census.sh` + `censum.py`, `lawsweep.sh`, `bvmirror.sh`, `attribution.sh`,
  `awayrows.py`, `dsfaces.py`, `uvmcensus9.sh` (+ r11u175's `uvmcensus.py`, `uvmfamilies.py`), `uvmdist.sh`, `det.sh` +
  `ob.sh`, `rebuildid.sh`, `orphanscan.sh`.

## 13. Addendum: pass 207 landed at `62ac216e` during this pass ([evidence/addendum_62ac216e/](evidence/addendum_62ac216e/))

Pass 207 (pair A r11u207: seven laws, one refinement, the verifier's fix) landed at 13:23. Re-measured without editing
anything above:

* **The reference.** `/tmp/intr11u207` (its integration sweep) equals the committed baselines at `62ac216e` cell for
  cell (1596 / 1742 rows, probe byte-identical); all 3273 `slang:` lines name the main tree's `build/slang-uhdm`
  (`6292e702987d`), which a fresh worktree `/tmp/wt_r11u211h` at `62ac216e` rebuilds byte for byte (frozen as
  `slang-uhdm.h207`); this map's HEAD sweep with it (`/tmp/r11u211_h7`, probe + both corpora) reads 0/0/0.
* **The fail list at 62ac216e: 40 row-modes (30 surelog + 10 uhdm2rtlil) in 22 tests, 717 probe cases** (surelog 924
  CMP_EQUAL + 30, uhdm2rtlil 1596 + 10, probe 3370 + 717). Converted by pass 207: **UnitElabBlock d/t** (its own law
  hiddenBlockVarMintNoFile207, switch `R11U207_HIDDENVARFILE_OFF`, which supersedes r11u205's hiddenBlockVarNetNoFile205: not to be landed) and 7 cases; changed:
  BlackBePipeInt d/t `fullname(2)` -> `type(1)` / `depth(1)`, BuildUVMPkg d/t `line(11)` -> `line(7)`, MiniAmiq d/t
  `file(71)` -> `file(70)`, SeqDriver d/t `(65)` -> `(64)`, SimpleUVM d/t `(95)` -> `(94)`, Scoreboard d `(103)` ->
  `(102)`. **Structural rows now: Scr1SvTests d/t `type(1)` and BlackBePipeInt d/t `type(1)` / `depth(1)`** (first
  records N0868, a tagged-pattern constant ours lists elsewhere, and N0897, pass 207's residue "a tagged-pattern child
  order and the testflags first-listing binding").
* **Clusters at 62ac216e** (`drivers/final13h.py`, this map's ids kept; 757 / 757 analyzer-vs-tool): **843**; gone
  since 4acbe8a5: N0016, N0160, N0189, N0237, N1136, N1780, N1815, N1947, N2045 (and N0071, N0193 lose all their rows);
  new: N2470 (BlackBePipeInt d: 4 ours-only `dev_addr_width_gp` parameter copies elsewhere, pass 207's elaborated-view
  refinement) and N1211 N1212 N1438 N1439 (Scoreboard d's svunit `get_name` / `wait_for_error` listed elsewhere: the
  intr11u207 database drew the other svunit listing order, the reader-visible coin of 2b, not a law).
* **This map's own pair-A prediction, audited against pass 207 at once.** Credited optimistically to pair A: 7
  row-modes alone (FuncStructVal d/t, FuncStructValSimple d/t, InterfArrayBind d, struct_param_func_config d/t) + its
  half of 8 joint ones, 87 clusters, 37 cases. **Pass 207 converted 0 of the 7 row-modes** (its brief's laws went to
  the UVM A families, BlackBePipeInt's head and UnitElabBlock); **of the 87 credited clusters 5 lost their rows**
  (N0160 N0189 N0237 gone, N0071 N0193 9 -> 0 rows) and it cleared 6 uncredited ones (N0016 was credited to r11u205's
  measured A patch, N1136 N1780 N1815 N1947 N2045); **4 of its 7 case conversions were credited** (N0160's cases), the
  other 3 head in N1947 (the `INT:0` filler's root file), a cluster no route named. The site pins of every pass-207
  movement name its files (ExprEmit / ParamEmit / StmtEmit, ground A) — the pins are right; the credit (a brief item
  counted as a cleared row) is what fails, as section 10 found for earlier maps.
* **The count after, at 62ac216e**: pass 207 took UnitElabBlock (which section 4 credited to r11u205's measured A law)
  and none of the rows credited to pair A, so with pair A's routes carried to its next refill (r11u210) and pair B
  unchanged, **everything still leaves 22 row-modes / 12 tests (30 / 17 without the 8 named optimisms)**; probe **590**
  (593 less the 3 uncredited pass-207 conversions). r11u205's remaining laws for the refills are now four: the three of
  law_typeemit (pair B r11u209) and law_exprstmt's elabIfArrIdxChainName205 (InterfArrayBind d `fullname(3)` ->
  `fullname(1)`, no conversion); hiddenBlockVarNetNoFile205 is superseded.
* **The away census of pass 207** (section 8's method; `st7` = `R11U207_OFF R11V207_OFF` on `slang-uhdm.h207`, which
  reproduces the committed history: probe 7 regressions + 3 changes, surelog 2 (UnitElabBlock d/t) + 11): **23
  databases (10 cases, 13 corpus), 0 records away chain-keyed or flat, 701 / 717 toward**; the reversed comparison, the
  positive control, reads 701 away. Pass 207's own census (0 lost, 13 corpus + 10 probe movers) is reproduced exactly.
