# r11u203map: the strict ground map, twelfth edition (measurement only)

**Base.** Measured at `ddc67d87` (branch matrix-1.87), HEAD of the branch for the whole pass: `git log ddc67d87..HEAD`
read empty in the main tree when this map was written, so no landing followed. The base sits after map 11
(`tools/probe/r11u197map`, measured at `4a65840e`, committed as `58905f76`), pass 193 (`b8719ea9`, landed after map 11's
measurement and before its commit), pass 195 (`7eb6f4b5`), the verification r11u199 (`a015c911`), pass 198
(`cffb131f`), pass 196 (`c029f423`) and the decode r11u200 (`ddc67d87` itself: `tools/probe/r11u200dec/law_exprstmt.patch`
and `law_typeemit.patch`, NOT in src). Pair A r11u201 and pair B r11u202 are live at the same base; their worktrees were
not touched.

**The reference sweep.** `/tmp/intr11u196` (the pass-196 integration sweep, read-only here). Its csvs equal the committed
baselines at `ddc67d87` cell for cell (1596 of 1596 surelog rows and 1742 of 1742 uhdm2rtlil rows, status and strict),
its `probe.csv` is byte-identical to `results/golden_probe.csv`, and all 3273 `slang:` lines of its `cmds.txt` files name
the main tree's `build/slang-uhdm` (md5 `18183f058868`), which this worktree's build reproduces byte for byte. It is the
pristine side of every comparison below.

Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited; this directory is the whole patch.
Law names are written `law <name>` (no section sign) so `scripts/law_index.py` does not read this directory as a pass. A
probe case is called a case throughout.

**The fence.** No fenced row is `STRICT_NOTEQUAL` at `ddc67d87` (their eight row-modes read `CMP_NOTEQUAL` x6 and
`CMP_EQUAL` x2 in the committed csvs and in the law sweep; `drivers/jobs.py`: `fenced_skipped=0`), so none is in the
fail list. Every driver that reads a database or a source takes the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` (`drivers/common.py fenced()`, `drivers/env.sh`; fail closed) and refuses them by
word boundary: `jobs.py`, `pinmulti.py`, `dsfaces.py`, `uvmcensus9.sh`, `uvmdist.sh`, `census.sh` (the firing census ran
`--filter '^(?!(<fenced>)$)'`), `bvmirror.sh` (the byte comparison ran on hard-link mirrors that leave the 8 fenced
row-mode databases out, `fenced_skipped=8` on both sides), `attribution.sh` (its filter lists the 62 predicted mover
tests, checked against the fence when written). The gate sweep of the law binary dispatched every row, as the gate
mandates. **No binary, gdb run or script touched a fenced test's sources or databases outside that sweep.** A grep of
this directory for the four names reads 0.

## Binaries (frozen `chmod 555` in `/tmp/r11u203_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `18183f058868a85659208c85a099980e` | worktree `/tmp/wt_r11u203` at ddc67d87, system-deps config, `-j 2`: byte-identical to the main tree's `build/slang-uhdm` |
| `slang-uhdm.law200` | `8c135e661f59e4fad29bc546965b3e49` | MEASUREMENT ONLY: ddc67d87 + [evidence/law200_on_ddc67d87.patch](evidence/law200_on_ddc67d87.patch) = r11u200's `law_exprstmt.patch` (applies clean over pass 198) + `law_typeemit.patch` rebased over pass 196. The rebase has two conflicts, both the r11u200 law modGenericClassListedAtDefault200 (the module listing of a parameterized class and its typespec half), which duplicates pass 196's landed laws modGenericClassListed196 / modGenericHandleBare196: **pass 196's versions kept, r11u200's dropped** (the overlap: both list the default specialization and strip the specialization typespec's parameters; pass 196 lists the generic classes after the plain ones where r11u200 interleaved them in member order, and pass 196's handle law also climbs out of generate blocks and covers class-property and package sites). 678 added, 15 deleted lines (r11u200's own two patches: 725 / 16). Scratch worktree `/tmp/wt_r11u203L` |
| `slang-uhdm.lawA` | `ce1ab244baa42558bd167edc1fc22b24` | ddc67d87 + [evidence/lawA_on_ddc67d87.patch](evidence/lawA_on_ddc67d87.patch) (law_exprstmt alone: ExprEmit, ParamEmit; pair A r11u201's first item) |
| `slang-uhdm.lawB` | `281fae8167db995648da42ab239aaba2` | ddc67d87 + [evidence/lawB_on_ddc67d87.patch](evidence/lawB_on_ddc67d87.patch) (law_typeemit alone, rebased: ModuleEmit, TypeEmit, TaskFuncEmit, UhdmExporter; pair B r11u202's first item) |
| `slang-uhdm.g1` | `d10de76ad742633de2a8972700b38fb7` | ddc67d87 with `-DCMAKE_CXX_FLAGS=-g1` (worktree `/tmp/wt_r11u203g`); gdb pins only; every pinned database `db=SAME` |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` (the tool is unchanged since map 11) |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | [drivers/strictcmp_x.cpp](drivers/strictcmp_x.cpp) built by `drivers/cc.sh`: byte-identical to map 11's variant (escaped record dumps, `--dump-ids`); its verdict equals the tool's on 792 of 792 jobs (section 1) |
| `objrank` | `82be8e819d67948b41f0cbf0a904f216` | [drivers/objrank.cpp](drivers/objrank.cpp) |

Sweeps: the reference `/tmp/intr11u196` (pristine) and this map's `/tmp/r11u203_sL` (law200, `tests/sweep.sh --jobs 3`,
all four stages; both workdir names are 15 characters). All 3273 `slang:` lines of the law sweep's `cmds.txt` files name
`/tmp/r11u203_bin/slang-uhdm.law200`; the attribution runs name `slang-uhdm.lawA` / `.lawB` in 122 of 122 each. The law
sweep exits 0 (the law index is current at ddc67d87).

## 0. Where we stand (ddc67d87; the committed baselines are the fail list)

| corpus | mode | judge-equal | strict-equal | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 461 | 19 |
| surelog | testflags | 474 | 457 | 17 |
| uhdm2rtlil | default | 803 | 796 | 7 |
| uhdm2rtlil | testflags | 803 | 796 | 7 |
| probe cases | | 4087 | 3345 | 742 |

**The fail list is 50 row-modes (36 surelog + 14 uhdm2rtlil) in 27 tests, plus 742 probe cases.** All 50 row-modes and
all 4087 probe cases were dispatched to the strict comparator: rc=2 on all 50 row-modes; on the cases rc=0 on 3345 and
rc=2 on 742, exactly the baseline split.

First fields, tallied from the `strict` column of results/golden_*.csv (= the reference sweep's):
* surelog 36: fullname 15, endcol 9, endline 5, file 5, line 2;
* uhdm2rtlil 14: fullname 8, line 4, endline 2;
* probe 742: fullname 266, line 112, endcol 109, type 71, name 61, file 43, depth 34, col 27, endline 11, value 7,
  decompile 1.

Mode asymmetries (the default row is the map's row; these differ in testflags): NE in default only: InterfArrayBind
(testflags CMP_EQUAL), Rggen (testflags SURELOG_FAIL), Scoreboard (testflags SLANG_REJECT); NE in testflags only:
HierPathTypespec; a different cell per mode: ClassTypeParam `endline(17)` / `file(30)`, FuncStructVal `endcol(95)` /
`(165)`, FuncStructValSimple `file(39)` / `(59)`, UnitElabBlock `endline(13)` / `(12)`. Every uhdm2rtlil fail row-mode
is downstream IDENTICAL (14 of 14).

**Since map 11** (60 row-modes / 32 tests, 932 cases at 4a65840e): **10 row-modes and 190 cases converted, none
entered** (committed baselines at each landing; [evidence/audit.txt](evidence/audit.txt) A):

| landing | row-modes converted | cases | strict-cell changes |
|---|---|---|---|
| pass 193 (`b8719ea9`) | rsp_gen_minimal d/t | 144 | 2 (ibex_pmp `file(5)` -> `type(1)`) |
| map 11 (`58905f76`) | - | 0 | 0 |
| pass 195 (`7eb6f4b5`) | StructParamPatternInitCast d/t | 7 | 11 |
| r11u199 (`a015c911`) | - | 0 | 0 |
| pass 198 (`cffb131f`) | ibex_pmp d/t | 37 | 2 (arb_idx_cast `endcol(17)` -> `endcol(3)`) |
| pass 196 (`c029f423`) | const_cast_signext d/t, func_typename_ret d/t | 2 | 11 |
| r11u200 (`ddc67d87`) | - | 0 | 0 |

**Clusters.** Map 11's key (`facet|type|shape|under:<walk parent type>` + `@builtin` / `@in-typespec`), ids persisting:
**891 clusters at ddc67d87 (458 carry a corpus row, 610 a case), every one keeps map 11's id; no key is new; 65 map-11
clusters are gone.** Two keys exist only under the r11u200 patches and get new ids **N2467 / N2468** (section 4: they are
records the patches move AWAY from golden).

## 1. Method (map 11's pipeline re-based, [drivers/run12.sh](drivers/run12.sh))

1. **Input.** The reference sweep `/tmp/intr11u196` (= the committed baselines). Jobs: every `STRICT_NOTEQUAL` row-mode
   of results/golden_*.csv (50; `drivers/jobs.py`: 0 missing, 0 fenced, one binary), golden = the cache entry its
   `cmds.txt` names; every probe case (4087), golden = `scripts/check_probe.py cache_dir(rel)` (Surelog's identity, the
   case path and a hash of the case's files; 0 missing), ours = `/tmp/intr11u196/probe/<rel with / -> __>.uhdm`.
2. **Strict runs.** `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job (`drivers/strict_runs.sh`).
3. **Analysis.** `drivers/analyze.py` (the committed mode-4 rule) records EVERY differing object; its reimplementation of
   the tool's rule agrees with the tool's stdout on **792 of 792** jobs (0 VERIFY-MISMATCH, 0 CELL-MISMATCH against the
   csv cells; [evidence/final12.txt](evidence/final12.txt)).
4. **Clusters.** `drivers/final12.py`: map 11's key; ids persist from map 11 (else the latest earlier map).
5. **Sites.** Map 11's pins are kept where the example object is unchanged ignoring record indices. Of the clusters with
   >= 3 row-modes, a first record or >= 40 cases, 11 have a changed example: 6 have only coin-prone UVM rows and no case
   (N0219, N0318, N0215, N0192, N2416, N0620: map 11's rule keeps their pin), and 5 were re-pinned with the `-g1` build
   (`drivers/pinmulti.py`, one gdb session per example row, [evidence/pinwant.txt](evidence/pinwant.txt)): N0164, N0543,
   N0784 (TypeEmit `pkgTdRangeViewFold18`'s operator < `importCloneBareTdAlias16`), N0014 (TypeEmit `buildStructTs`),
   N0448 (TypeEmit `shadowedImportParamFold`'s operator < `makeTypespec`). **5 of 5 `db=SAME`, 5 of 5 name map 11's
   mint** ([evidence/pins/](evidence/pins/)). N2467 / N2468 exist only under the patches: sited by switch attribution
   (section 4), not gdb.
6. **Ground.** A = ExprEmit/EmitHelpers/StmtEmit/ParamEmit, B = TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main,
   by the pinned mint's file, overridden where a pass decoded the fix site elsewhere
   ([evidence/ground_override.json](evidence/ground_override.json): map 11's list plus N0945 -> B (pass 195 section 8:
   Earlgrey's generate-scope port-connection select is TypeEmit `emitSyntaxExpr` / ModuleEmit), N0028 N0552 N0761 N0817
   -> A (r11u200 3e: ParamEmit `makeParamTs` `memberScope`), N0263 N0025 N0033 -> A (r11u200 3e: the evaluator's formal
   typespec stamp on a shared parameter constant, ParamEmit), N2467 N2468 -> B).
7. **Coverage** ([evidence/routes.json](evidence/routes.json), `drivers/report12.py`):
   * **r11u200's two law patches, MEASURED**: the law200 binary's full gate sweep re-dumped and re-keyed
     (`drivers/crosssection.sh`); a cluster gone under it reads `COVERED r11u200 (law patches, MEASURED ...)`;
   * **pair A r11u201, OPTIMISTIC** and **pair B r11u202, OPTIMISTIC**: their brief items mapped to clusters (table below);
     a covered cluster counts fixed whole; pair B also takes the ground-B clusters of the UVM / Earlgrey rows' first ten
     differing records at the cross-section whose rows are all UVM / Earlgrey rows (map 11's rule);
   * **OPEN** otherwise, with map 11's routing where it had one.
8. **Yields.** The `alone` column is the rows a cluster clears alone on top of r11u200 (measured) and both pairs.

What the live pairs were mapped to:

| pair | brief item | clusters |
|---|---|---|
| A r11u201 | r11u200 `law_exprstmt.patch` (first) | MEASURED (with law_typeemit) |
| A | pass 198's residues: R2 / pass 195 R1 (references named through a method-call path, the nested remainder: N0175 N0217 N0220), R7 / pass 195 R2 (the `UVM_MACRO_*` names N0682), R8 (map 11's list not attempted, below) | 4 + R8 |
| A | r11u200's ground-A decodes (decoded, **no law**): cfg_func_width_loop's evaluator stamp (N0263 N0025 N0033), struct_param_func_config's names through the chain root (N0028 N0552 N0761 N0817) | 7 |
| A | map 11's ground-A list: struct_param_func_config (N0045 N0675 N2412), cfg_func_width_loop (N0754 N0794), Scr1SvTests (N0741 N0779 N0836 N1069 N1119), Earlgrey N0941, Rggen N0145, BuildUVMPkg N0189, the UVM ground-A families (N0097 N0012 N0034 N0207 N0054 N0197 N0222 N0225 N0227 N0234 N0235 N0237 N0238 N0247 N0252 N0253 N2400 N2401), anon_struct_packed_dim N0820, FuncStructValSimple (N0086 N0087 N0131), FuncStructVal (N0407 N0891 N0980 N1096), InterfArrayBind N0427, and every map-11 pair-A route still live (OutputSize N0191 N0001, UnitElabBlock N0016, ibex_tracer N0763 N0957 N0971 N0979 N0003, N0416, and 21 UVM clusters: N0196 N0160 N0071 N0178 N0179 N0109 N0110 N0185 N0193 N0199 N0192 N0183 N0061 N0119 N0152 N0153 N0172 N0173 N2411 ...) | 67 |
| B r11u202 | r11u200 `law_typeemit.patch` (first) | MEASURED; **plus its own AWAY records N2467 N2468** (the landing must refine, section 4) |
| B | pass 196's residues: R1 MiniAmiq #899 (N0144), R5 BuildUVMPkg #3245 (N0039); section 7's not-attempted list (map 11's pair-B routes carried: N0040, N0090 N0448, N0853 N1127, N0011, N0519 N1117 N1126 N1128 N1134, N0563, N0014, N1174, N1946; ClassTypeParam and UnitElabBlock as named rows) | 22 + 2 rows |
| B | r11u200's ground-B decodes without a law: cfg_func_width_loop's kept call (N0133 N0487) | 2 |
| B | pass 193's residues | evidence cases only (no gate row or case carries a cluster of its own) |
| B | the UVM ground-B families (map 11 B6 + map 10's list): N0067 N0068 N0180 N0158 N0177 N0184 N0188 N0423 N0117 N0120 N0213 N0230 N0232 N0254 N0255 N0256 N0072 N0103 N0051 N0161 N0170 N0171 N0757 N0327 | 24 |
| not routed | BlackBePipeInt N0923 (an identity family), Scr1SvTests' structural record N0791 (a Surelog binding defect, r11u200 3d), PreprocTest N0056 (`.vh` face, not implementable), LogicTypespec (a user decision), r11u199 N2-N6, pass 198 R1 / R3-R6 / R9 / R10, pass 196 R2-R4 / R6-R10 (evidence cases) | |

## 2. Positive controls ([evidence/controls/](evidence/controls/))

| control | result |
|---|---|
| surelog/default/1364_2005 (CMP_EQUAL) | `STRICT_EQUAL 159 objects`, rc 0, record dumps identical (159 / 159) |
| surelog/default/HierPathInterfBlock (CMP_EQUAL) | `STRICT_EQUAL 226 objects`, rc 0, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray (CMP_EQUAL) | `STRICT_EQUAL 194 objects`, rc 0, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, lhsPath / rhsPath `design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL,decompile:` both modes |
| analyzer rule vs tool stdout | 792 / 792 at ddc67d87; 774 / 774 on the r11u200 cross-section (46 row-modes + 728 cases) |
| probe cells vs golden_probe.csv | 4087 / 4087; 742 / 742 rc=2 from the strict runs |
| pin validity | 5 / 5 `db=SAME`, 5 / 5 the same mint as map 11 |
| byteverify self-check | 2559 / 2560 flagged with one side corrupted |
| the fenced rows | counted from the csv verdicts only: 6 row-modes CMP_NOTEQUAL + 2 CMP_EQUAL, unchanged in the law sweep |

### The determinism control ([evidence/determinism/](evidence/determinism/), [drivers/det.sh](drivers/det.sh), [ob.sh](drivers/ob.sh))

The HEAD binary run three times CONCURRENTLY per row-mode (the reference sweep's command line and cwd, output to scratch),
plus the reference sweep's own database as a fourth sample; distinct md5s, and the order-blind `uhdm-dump` difference
(paths normalised, sorted, `comm -3` line count) of every pair; then, for every multi-hash row, the RAW (unsorted) dump
difference and `uhdm-strictcmp --max 0` objects differing per run
([raw_dump_draws.txt](evidence/determinism/raw_dump_draws.txt)).

| row-mode | distinct hashes (of 4) | order-blind lines per pair | raw dump lines | strict objects differing per run |
|---|---|---|---|---|
| Earlgrey_0_1 default | **1** (`2a3a623104a7`) | - | - | - |
| Earlgrey_0_1 testflags | **1** (`52b21f1158b5`) | - | - | - |
| MiniAmiq default | **1** (`653c73c12480`) | - | - | - |
| MiniAmiq testflags | 2 (one run drew default's hash) | **0** | **0** | 17 / 17 / 17 |
| SeqDriver default | 2 | **0** | **0** | 16 / 16 / 16 |
| SeqDriver testflags | **1** | - | - | - |
| SimpleUVM default | 2 | **0** | **0** | 44 / 44 / 44 |
| SimpleUVM testflags | **1** | - | - | - |
| Scoreboard default | 2 | **0** | 92 (the svunit listing order) | 44 / 44 / 44 |
| BuildUVMPkg default | **1** (`5210d0613d6b`) | - | - | - |
| BuildUVMPkg testflags | **1** (the same `5210d0613d6b`) | - | - | - |

Scoreboard testflags is SLANG_REJECT (not run).

* **The UVM one-constant value coin is CLOSED at HEAD** (law queueRetTwinDynShape191, landed by pass 196): no pair of
  any UVM row differs order-blind (map 11 read 4 lines on every MiniAmiq / SeqDriver / SimpleUVM pair at 4a65840e, the
  `types_t` bound).
* **Three rows keep a storage-order draw** (MiniAmiq testflags, SeqDriver default, SimpleUVM default): the two hashes'
  raw dumps are identical line for line, the strict cells identical, so the draw lives in the Cap'n Proto storage order
  only (r11u199's BuildUVMPkg finding, now one-valued there). **The one reader-visible coin left is Scoreboard default's
  svunit `vpiTaskFunc` listing order** (92 raw dump lines, 0 order-blind, the same strict cell): a reader walking the
  listing in order sees it; nothing keyed by name or value does.
* **Earlgrey_0_1 is one-valued in both modes** (4 samples each).

## 3. The gates of the law sweep (this map lands no binary)

| gate | pristine `18183f05` (`/tmp/intr11u196`) | law200 `8c135e66` (`/tmp/r11u203_sL`) |
|---|---|---|
| (1) build | = the main tree's build | ddc67d87 + the two r11u200 patches (rebased as above) |
| (2) probe vs golden_probe.csv | EQUAL 3345 / STRICT_NOTEQUAL 742; byte-identical to the baseline | EQUAL **3359** / 728: `regressions=0 conversions=14 changes=13` |
| (3) surelog vs golden_surelog.csv | = the baseline | `regressions=0 conversions=2 (SVSwitch d/t) changes=16`; judge-equal 462+18 / 458+16, CMP_NOTEQUAL 3 / 3 |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | = the baseline | `regressions=0 conversions=2 (int_types d/t) changes=0`; 797+6 per mode, CMP_NOTEQUAL 1 |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; not identical and not excused 0 |
| (5) uhdm-cmp | | every corpus row keeps its judge status; every case stays uhdm-cmp EQUAL |
| (6) byteverify (SELFCHECK=1, fence-free mirrors) | | **20 / 2560 movers, 20 of 20 PREDICTED by name** by the firing census (`R11U200_TRACE`, 121 row-modes and 152 cases predicted, [evidence/sweeps/census/](evidence/sweeps/census/), frozen `chmod 444` at 05:51:21 before the sweep started): surelog d/t BuildUVMPkg Earlgrey_0_1 MiniAmiq Scr1SvTests SeqDriver SimpleUVM SVSwitch UnitElabBlock, surelog d Rggen Scoreboard, uhdm2rtlil d/t int_types |

**These are exactly r11u200's own numbers at a015c911** (its section 5: probe 14 / 13, surelog 2 / 16, uhdm2rtlil 2,
the same 20 movers): passes 198 and 196 in between change none of the patches' cells, and the class-listing overlap
dropped from law_typeemit moves no gate cell (pass 196 had already converted what it converted). The fresh rows (NOT
written to results/):

    SVSwitch,default,CMP_EQUAL,,,equal       was differ:fullname(13)   lawA + lawB (neither alone)
    SVSwitch,testflags,CMP_EQUAL,,,equal     was differ:fullname(13)
    int_types,default,CMP_EQUAL,,,equal      was differ:fullname(82)   lawB alone
    int_types,testflags,CMP_EQUAL,,,equal    was differ:fullname(82)

## 4. r11u200's two law patches, MEASURED at ddc67d87 (the cross-section)

| stage | both (law200) | law_exprstmt alone (lawA) | law_typeemit alone (lawB) |
|---|---|---|---|
| probe | **14 conversions** (742 -> 728), 13 changes, 0 regressions | 2 (r10svs2repro/s4_context, r10svs3repro/a1_newlhs) / 0 / 0 | 12 / 13 / 0 |
| surelog | **2 conversions (SVSwitch d/t)**, 16 changes | 4 changes: SVSwitch d/t `fullname(13)` -> `endline(11)`, Scr1SvTests d/t `endcol(29)` -> `endcol(19)` | 18 changes (SVSwitch d/t -> `fullname(2)`, Scr1SvTests d/t -> `endcol(11)`, and the 14 others) |
| uhdm2rtlil | **2 conversions (int_types d/t)** | 0 | 2 conversions (int_types d/t) |
| downstream | 803 / 66 / 2 / 0 | (not run) | (not run) |

([evidence/sweeps/attribution_lawA/](evidence/sweeps/attribution_lawA/), [attribution_lawB/](evidence/sweeps/attribution_lawB/):
the probe stage in full, the corpus stages filtered to the 62 predicted tests.) **The per-patch split is r11u200's own
section 9.** The 16 surelog changes: BuildUVMPkg d/t `line(11)` -> `line(24)`, Earlgrey_0_1 d/t `fullname(82)` ->
`endcol(80)`, MiniAmiq d/t `file(17)` -> `file(91)`, Rggen d `endcol(144)` -> `defname(142)`, Scoreboard d `fullname(44)`
-> `fullname(123)`, Scr1SvTests d/t `endcol(29)` -> `type(1)`, SeqDriver d/t `fullname(16)` -> `fullname(85)`,
SimpleUVM d/t `fullname(44)` -> `fullname(115)`, UnitElabBlock d/t `endline(13/12)` -> `file(2/1)`. The UVM counts grow
because the walk no longer diverges at `get_event_pool` (law classTdRetSharesTypedefTs200); the order-blind distance
falls on every one (section 11).

**Clusters.** Gone under the patches (25): N0103 N0248 N0439 N0459 N0590 N0624 N0678 N0991 N2465 (UVM: the class
typedef return records), N0526 N0954 N0958 N1010 N1011 N1019 N1020 (SVSwitch), N0852 N0912 N1137 N1147 N1150 N1155
(int_types), N0741 N1139 (Scr1SvTests' reduced bounds), N2262. Fell: N0056 11 -> 2 rows (the UVM signing face gone;
PreprocTest's `.vh` face stays), N0040 9 -> 4, N0090 8 -> 4, N0203 5 -> 2, N0448 3 -> 1, N0007 11 -> 9, N0164 5 -> 4.
Grew: N0318 6 -> 7, and the two new keys.

**NEW: the patches move 74 corpus records AWAY from golden** ([drivers/awaycensus.py](drivers/awaycensus.py): strict
records, depth dropped, as multisets; a LOST record is one golden and the PRISTINE database share that the law database
no longer has; [evidence/away/](evidence/away/)). The gate cannot see them (the rows stay STRICT_NOTEQUAL and the net
distance falls: 988 records gained), and no case loses one (728 cases: lost 0, gained 13). Each is attributed by
re-running the law binary with one switch ([away/switch_attribution.txt](evidence/away/switch_attribution.txt)):

| law (switch) | rows | lost per row-mode | what golden (= pristine) has | what the law writes |
|---|---|---|---|---|
| classTdRetSharesTypedefTs200 (`R11U200_CLASSTDRET_OFF`) | MiniAmiq, SeqDriver, SimpleUVM d/t, Scoreboard d, BuildUVMPkg d/t | 6 / 3 / 5: **N2467** `span\|class_var\|...\|under:function` (52 records) | the return class_var of `function uvm_resource_types::rsrc_q_t lookup_name(...)` spans the data type, uvm_pkg.sv 16092:12-16092:40 | the typedef's span 15203:11-15203:20 (`typedef uvm_queue#(uvm_resource_base) rsrc_q_t;`) |
| the same | MiniAmiq, SeqDriver, SimpleUVM d/t, Scoreboard d | 2: **N2468** `file\|ref_var\|other-file\|under:function` (14 records) | the late-bound ref_var return of `static function this_type get();` (uvm-1.2 uvm_callback.svh 507:19-28) in uvm_callback.svh | the same span in uvm_heartbeat.svh (the file of the specialization's typedef) |
| defPortPackedTsKeepsWholeSpan200 (`R11U200_PORTPACKED_OFF`) | Earlgrey_0_1 d/t | 4 (and 8 gained) | an IMPLICIT-typed multi-dimensional port (`input [NAlerts-1:0] [CLASS_DW-1:0] alert_class_i`, alert_handler_class.sv 15-16, alert_handler_esc_timer.sv 30 / 32) keeps golden's first-dimension span 15:9-15:22 | the whole 15:9-15:40; golden spans the whole type only where the port is written with `logic` (dm_csrs.sv 55, padctrl.sv 25: the 8 gained) |

With `R11U200_PORTPACKED_OFF` Earlgrey loses 0 and gains 0; with `R11U200_CLASSTDRET_OFF` Scoreboard loses 0 and gains 4
(the signing law's). **Earlgrey_0_1's new first record under the patches (`#89859 endcol`, the `endcol(80)` cell) IS one of
these AWAY records**, so the cell change is not progress. **Pair B, landing law_typeemit, must refine both laws**: the
class-typedef return law must keep the return variable's own span and file (a class-scope typedef written qualified,
`K::T f()`, and the late-bound `this_type` return), and the port law must decline on a port with no data-type keyword.

## 5. The yield, and the fail list after r11u200 and both pairs

| | row-modes cleared | tests cleared (every NE mode) | cases cleared |
|---|---|---|---|
| r11u200's two law patches, MEASURED | **4** (SVSwitch d/t, int_types d/t) | 2 | **14** |
| pair A r11u201, optimistic, on top of r11u200 | **7**: FuncStructValSimple d/t, FuncStructVal d, InterfArrayBind d, UnitElabBlock t, struct_param_func_config d/t | 3 | 31 |
| pair B r11u202, optimistic, on top of r11u200 | **9**: ClassTypeParam d/t, InterfaceModPort d/t, InterfaceStructMemberPort d/t, HierPathTypespec t, arb_idx_cast d/t | 5 | 85 |
| **everything** (r11u200 + both pairs) | **30** (the 20 above + 10 that need both pairs: UnitElabBlock d, FuncStructVal t, OutputSize... d/t, anon_struct_packed_dim d/t, cfg_func_width_loop d/t, ibex_tracer d/t) | **16** | **154** |

| corpus | mode | ddc67d87 | after r11u200 (measured) | + pair A | + pair B | + both pairs |
|---|---|---|---|---|---|---|
| surelog | default | 19 | 18 | 15 | 15 | 11 |
| surelog | testflags | 17 | 16 | 14 | 12 | 9 |
| uhdm2rtlil | default | 7 | 6 | 5 | 5 | 0 |
| uhdm2rtlil | testflags | 7 | 6 | 5 | 5 | 0 |
| **all** | | **50 / 27 tests** | **46 / 25** | | | **20 / 11 tests** |
| probe cases | | 742 | 728 | 697 | 643 | **588** |

First fields after r11u200 (the law sweep's csvs): surelog 34: fullname 11, endcol 8, file 7, endline 3, line 2,
**type 2** (Scr1SvTests d/t), defname 1; uhdm2rtlil 12: fullname 6, line 4, endline 2; probe 728: fullname 264, line 124,
endcol 89, type 71, name 58, file 43, depth 33, col 27, endline 11, value 7, decompile 1.

**The pair yields are optimistic in named ways.** Map 11's five named optimisms stand (InterfaceModPort d/t converts only
once the harness passes `--sverilog`, pass 188 R1; InterfArrayBind d needs the ModuleEmit half too; ClassTypeParam d/t is
credited through named rows, never decoded; FuncStructVal d/t's first record is judge-unequal in every small shape;
HierPathTypespec t is the naming-context face), **and two more come from r11u200's decodes without a law**
(cfg_func_width_loop d/t: both halves decoded, neither written; struct_param_func_config d/t: golden holds five
differently named copies of `cfg_t.u`, last writer wins). **Without those 12 row-modes, everything clears 18 row-modes
(9 tests) and 32 row-modes in 18 tests remain.**

## 6. Ranked OPEN clusters with sites (on top of r11u200 measured + both pairs optimistic)

Columns: `rows left` = row-modes the cluster still carries after r11u200 and the pairs (rows at ddc67d87 in
parentheses); `first-open heads` = rows it is the first OPEN record of; `alone` = rows it clears alone on top of
everything; `probe` = its cases after r11u200. The whole list is cluster_index.csv.

**309 OPEN clusters still carry a row** (ground A 132, B 177). Every one of the top 70 is a UVM (and Earlgrey / Scr1)
cluster; **only one OPEN cluster clears a row alone: N0056** (PreprocTest d/t, not implementable). The first-open
heads of the 20 remaining row-modes:

| first OPEN cluster | row-modes it heads | ground | example (golden / ours) | site |
|---|---|---|---|---|
| N0540 | 4 (MiniAmiq d/t, SeqDriver d/t) | A | `class_typespec uvm_pkg::uvm_reg_field_cb_iter` ref_typespec name `work@svaunit_vpi_interface.uvm_pkg::uvm_reg_field_cb_iter` / `uvm_pkg::uvm_reg_field_cb_iter` (a class typedef read in a module-imported package copy) | emitPackage (ParamEmit.cpp, law pkgImportCloneLastWriter32) < exportDesign (UhdmExporter.cpp) |
| N0689 | 3 (SimpleUVM d/t, Scoreboard d) | A | the same object: `work@my_scoreboard::uvm_pkg::uvm_reg_field_cb_iter` / `uvm_pkg::uvm_pkg::uvm_reg_field_cb_iter` | emitPackage (ParamEmit.cpp, law classNestedClassTdJoinsPkgGroup50) < exportDesign (UhdmExporter.cpp) |
| N0923 | 2 (BlackBePipeInt d/t) | A | `ref_obj dev_addr_width_gp` in a package parameter's int_typespec, golden unnamed / `work@bp_be_pipe_int.dev_addr_width_gp.dev_addr_width_gp` (an identity family: per-use copies) | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefModuleCopy) |
| N0945 | 2 (Earlgrey_0_1 d/t) | B | `bit_select class_en` in `.class_en_i(reg2hw_wrap.class_en[k])` of a for-generate instance: golden `work@alert_handler.gen_classes.i_accu.class_en_i.reg2hw_wrap.class_en[k].class_en` at the index / ours `reg2hw_wrap.class_en[k]` at the member (pass 195 section 8) | emitSyntaxExpr (TypeEmit.cpp, law hpMidGenvarSelect) < operator() (ModuleEmit.cpp, law genConnDottedActualIsHierPath37) |
| N0778 | 2 (BuildUVMPkg d/t) | B | an `io_decl val` enum ref_typespec name `uvm_pkg::uvm_pkg::UVM_SEQ_ARB_TYPE` / `uvm_pkg::UVM_SEQ_ARB_TYPE` (set_arbitration) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < buildStructTs (TypeEmit.cpp, law structInlineEnumMemberTs113) |
| N0284 | 2 (Scr1SvTests d/t) | B | an ours-only folded constant under an elaborated cont_assign (a copy golden does not make), behind the structural record N0791 (the unresolved `$unit` enum constant, a Surelog defect) | emitExpr (ExprEmit.cpp) < emitCaStructParamSubst55 (ModuleEmit.cpp, law caStructParamPathBaseAtMember) |
| N0422 | 2 (LogicTypespec d/t) | B | (a user decision) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage (ParamEmit.cpp) |
| N0056 | 2 (PreprocTest d/t) | B | `bit` lexed as an identifier in a `.vh` file (not implementable, pass 186 R5) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) |
| N1249 | 1 (Rggen d) | B | `indexed_part_select read_data` in `bit_field_if.read_data[0+:4]`: golden `work@block_0.g_register_0.g_bit_field_0.bit_field_if.read_data[0+:4].read_data` / ours the short form | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (ModuleEmit.cpp, law genConnReplCastActual) |

### T1. Ranked OPEN clusters, all rows (top 30 of 309)

| # | cluster | rows left (ddc67d87) | sl/u2r | tests | families | first-open heads | alone | probe (after r11u200) | ground | status | key | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0288 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 4 | B | OPEN (map 11 ground-A+B step 10) | `fullname\|ref_typespec\|golden-empty\|under:array_typespec` | importVarCopy5 (ModuleEmit.cpp, law importCopyTsSubtreeNoInstance7) < classInheritsContainerImports23 (ModuleEmit.cpp) |
| 2 | N0290 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 2 | A | OPEN (map 11 ground-A+B step 10) | `span\|method_func_call\|endline+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) |
| 3 | N0098 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 1 | A | OPEN (map 11 ground-A+B step 10) | `file\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < emitExpr (ExprEmit.cpp) |
| 4 | N0303 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 1 | A | OPEN (map 11 ground-A+B step 10) | `file\|method_func_call\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp) |
| 5 | N0304 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 1 | A | OPEN (map 11 ground-A+B step 10) | `file\|method_func_call\|ours-empty\|under:while_stmt` | emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < emitStmt (StmtEmit.cpp) |
| 6 | N0305 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 1 | A | OPEN (map 11 ground-A+B step 10) | `file\|ref_obj\|ours-empty\|under:method_func_call` | emitExpr (ExprEmit.cpp, law macroPasteRecvMisreadIsAstChain132) < emitStmt (StmtEmit.cpp) |
| 7 | N0306 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 1 | A | OPEN (map 11 ground-A+B step 10) | `fullname\|ref_obj\|tok:id.id[+:n]::id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law everyPartSelIsConstSel78) |
| 8 | N0050 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `span\|operation\|col+endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) |
| 9 | N0121 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | B | OPEN (map 11 ground-A+B step 10) | `file\|enum_typespec\|other-file+span\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) |
| 10 | N0123 | 7 (7) | 7/0 | 4 | Earlgrey UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 11) | `file\|int_typespec\|other-file+span\|under:ref_typespec` | makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator() (ParamEmit.cpp, law pkgUntypedYNoStamp60) |
| 11 | N0262 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | B | OPEN (map 11 ground-A+B step 10) | `struct\|golden-only:fewer-copies\|constant\|under:param_assign` | importPaCopy82 (ModuleEmit.cpp, law classImportParamStamped82) < classInheritsContainerImports23 (ModuleEmit.cpp) |
| 12 | N0297 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `span\|method_func_call\|line+col+endline+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) |
| 13 | N0314 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `span\|method_func_call\|line+col+endline+endcol\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law elabMisevalArgNoFold) |
| 14 | N0318 | 7 (6) | 6/0 | 3 | UVM | 0 | 0 | 0 | B | OPEN (map 11 ground-A+B step 10) | `file\|bit_typespec\|other-file+span\|under:ref_typespec` | bareScalarTdCopyOfFresh16 (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < bareScalarTdCopyOf (TypeEmit.cpp) |
| 15 | N0321 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | B | OPEN (map 11 ground-A+B step 10) | `file\|enum_typespec\|other-file+span\|under:class_defn` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (ParamEmit.cpp) |
| 16 | N0326 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `span\|method_func_call\|endline+endcol\|under:begin` | emitExpr (ExprEmit.cpp, law hierCallArgTakesBase39) < emitStmt (StmtEmit.cpp) |
| 17 | N0337 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | B | OPEN (map 11 ground-A+B step 10) | `file\|class_typespec\|other-file+span\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law classHandleRetTsNameUnlessSameHomeComponent156) < emitPackageClassMethodClones (ParamEmit.cpp) |
| 18 | N0352 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `span\|method_func_call\|endline+endcol\|under:if_stmt` | emitExpr (ExprEmit.cpp, law hierCallArgTakesBase39) < emitStmt (StmtEmit.cpp) |
| 19 | N0374 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `span\|method_func_call\|endcol\|under:begin` | emitExpr (ExprEmit.cpp, law hierCallArgTakesBase39) < emitStmt (StmtEmit.cpp) |
| 20 | N0375 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `fullname\|bit_select\|tok:id.id::->\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) |
| 21 | N0387 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `file\|begin\|ours-empty\|under:begin` | emitStmt (StmtEmit.cpp, law parBlockJoinTailAfterFirstItem131) < emitStmt (StmtEmit.cpp, law invalidChild14) |
| 22 | N0390 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `span\|begin\|ours-zero\|under:begin` | emitStmt (StmtEmit.cpp, law parBlockJoinTailAfterFirstItem131) < emitStmt (StmtEmit.cpp, law invalidChild14) |
| 23 | N0392 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `span\|operation\|line+col+endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law insideOpenRangeMemberIsOneListOp30) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) |
| 24 | N0397 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `fullname\|ref_obj\|tok:::->.\|under:hier_path` | emitExpr (ExprEmit.cpp) < emitExpr (ExprEmit.cpp, law namedTfArgsFormalSlots4) |
| 25 | N0399 | 7 (7) | 7/0 | 4 | UVM | 0 | 0 | 0 | A | OPEN (map 11 ground-A+B step 10) | `fullname\|ref_obj\|tok:id.id[id % ]::id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) |
| 26 | N0266 | 6 (6) | 6/0 | 3 | UVM | 0 | 0 | 4 | B | OPEN (map 11 ground-A+B step 9) | `span\|enum_typespec\|line+col+endline+endcol\|under:ref_typespec` | aggImportCloneCopy32 (TypeEmit.cpp, law pkgImportAggCloneLastWriter32) < emitTaskFuncs (TaskFuncEmit.cpp) |
| 27 | N0408 | 6 (6) | 6/0 | 3 | UVM | 0 | 0 | 4 | A | OPEN (map 11 ground-A+B step 10) | `struct\|ours-only:fewer-copies\|unsupported_typespec\|under:ref_typespec` | operator() (StmtEmit.cpp, law cloneLoopVarShared37) < emitStmt (StmtEmit.cpp, law foreachLoopVarObjs9) |
| 28 | N0043 | 6 (6) | 6/0 | 3 | UVM | 0 | 0 | 3 | B | OPEN (map 11 ground-A+B step 9) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWholeLhsBare160) |
| 29 | N0078 | 6 (6) | 6/0 | 3 | Scr1 UVM | 0 | 0 | 0 | B | OPEN (map 11 ground-A+B step 7) | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law elabMisevalRefSubst) |
| 30 | N0426 | 6 (6) | 6/0 | 3 | Scr1 UVM | 0 | 0 | 0 | B | OPEN (map 11 ground-A+B step 7) | `fullname\|ref_obj\|ours-empty\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law syntaxMultiConcat) |

### T1b. OPEN clusters on the rows outside the big families

After r11u200 and both pairs, only two rows outside the families (UVM, Earlgrey, Rggen, BlackBePipeInt, Scr1) are
left, both not routed: **PreprocTest d/t** (N0056 alone, `alone` 2: the `.vh` face, not implementable) and
**LogicTypespec d/t** (N0083 + N0422 + N0484 + N1149, a user decision).

### T1c. Probe-only OPEN clusters with the most cases (after r11u200)

N0094 (51, B: `span|constant|...|under:range`, TypeEmit `makeBoundConst`), N1899 (51, B: `span|range|...|under:logic_typespec`,
TypeEmit `makeTypespec` < ModuleEmit `emitInterfaceInstance`; both are law caIfacePortDeclNetMint93's 27 cases),
N0739 (27, A: pass 198 R9, golden's elaborated `assign o = P` of a struct-typed parameter has NO right side), N1903 /
N1904 (21 / 20, A: ParamEmit `memLeftPatParamClone26`), N0476 / N0477 (20 each, A: ParamEmit `makeBareVecParamTs`),
N1905 (17, B), N1907 (15, B), N1906 / N1908 / N1910 / N1911 (14 each, B), N1909 (14, A). The cases' first records:
N0263 54 (cfg_func_width_loop's stamp family, A), N0284 44 (B), N0039 31, N0040 29, N0738 27, N0739 26, N0003 24.

## 7. The fail list with sites (fail_list.csv, probe_fail_list.csv)

Every STRICT_NOTEQUAL row-mode with its first cluster at ddc67d87, that cluster's coverage, ground and site, all its
clusters, the strict cell after r11u200, its first OPEN cluster after the pairs, the open clusters left and whether it
clears. probe_fail_list.csv is the same per case (742). By test, sorted by cluster count (a `-` mode is not NE):

| corpus | test | cell d / t | clusters d/t | first cluster (ground) | first site | after r11u200 | first open after the pairs | open after pairs | clears | downstream |
|---|---|---|---|---|---|---|---|---|---|---|
| sur | HierPathTypespec | - / differ:fullname(1) | -/1 | N1174 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) | same | - | -/0 | yes (pair B, optimistic) | - |
| sur | InterfArrayBind | differ:fullname(3) / - | 1/- | N0427 (A) | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp) | same | - | 0/- | yes (pair A, optimistic) | - |
| sur | InterfaceModPort | differ:endcol(12) / differ:endcol(12) | 1/1 | N0040 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) | same | - | 0/0 | yes (pair B, optimistic) | - |
| sur | PreprocTest | differ:endcol(2) / differ:endcol(2) | 1/1 | N0056 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) | same | N0056 | 1/1 | no | - |
| sur | UnitElabBlock | differ:endline(13) / differ:endline(12) | 3/2 | N0090 (B) | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) | differ:file(2) / differ:file(1) | - | 0/0 | yes (pairs A+B / pair A, optimistic) | - |
| sur | FuncStructValSimple | differ:file(39) / differ:file(59) | 3/3 | N0086 (A) | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) | same | - | 0/0 | yes (pair A, optimistic) | - |
| sur | LogicTypespec | differ:endline(3) / differ:endline(3) | 4/4 | N0422 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) | same | N0422 | 4/4 | no | - |
| sur | InterfaceStructMemberPort | differ:fullname(6) / differ:fullname(6) | 5/5 | N1134 (B) | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) | same | - | 0/0 | yes (pair B, optimistic) | - |
| sur | FuncStructVal | differ:endcol(95) / differ:endcol(165) | 7/8 | N1096 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) | same | - | 0/0 | yes (pair A / pairs A+B, optimistic) | - |
| sur | ClassTypeParam | differ:endline(17) / differ:file(30) | 8/10 | N1081 (B) | exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) | same | - | 0/0 | yes (pair B, optimistic) | - |
| sur | SVSwitch | differ:fullname(13) / differ:fullname(13) | 9/9 | N0007 (A) | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) | **equal (r11u200, measured)** | - | 0/0 | yes (r11u200, measured) | - |
| sur | Scr1SvTests | differ:endcol(29) / differ:endcol(29) | 21/21 | N0448 (B) | operator() (TypeEmit.cpp, law shadowedImportParamFold) < makeTypespec | differ:type(1) / differ:type(1) | N0284 | 11/11 | no | - |
| sur | BlackBePipeInt | differ:fullname(2) / differ:fullname(2) | 26/24 | N0923 (A) | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefModuleCopy) | same | N0923 | 23/21 | no | - |
| sur | Rggen | differ:endcol(144) / - | 25/- | N0040 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) | differ:defname(142) / - | N1249 | 20/- | no | - |
| sur | Earlgrey_0_1 | differ:fullname(82) / differ:fullname(82) | 69/65 | N0945 (B) | emitSyntaxExpr (TypeEmit.cpp, law hpMidGenvarSelect) < operator() (ModuleEmit.cpp) | differ:endcol(80) / differ:endcol(80) (an AWAY record, section 4) | N0945 | 61/57 | no | - |
| sur | BuildUVMPkg | differ:line(11) / differ:line(11) | 86/86 | N0039 (A) | emitExpr (ExprEmit.cpp, law castTargetKeywordTypespecKind96) | differ:line(24) / differ:line(24) | N0778 | 25/25 | no | - |
| sur | Scoreboard | differ:fullname(44) / - | 102/- | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) | differ:fullname(123) / - | N0689 | 36/- | no | - |
| sur | SimpleUVM | differ:fullname(44) / differ:fullname(44) | 108/108 | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) | differ:fullname(115) / differ:fullname(115) | N0689 | 43/43 | no | - |
| sur | SeqDriver | differ:fullname(16) / differ:fullname(16) | 219/219 | N0217 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) | differ:fullname(85) / differ:fullname(85) | N0540 | 149/149 | no | - |
| sur | MiniAmiq | differ:file(17) / differ:file(17) | 223/223 | N0144 (B) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage | differ:file(91) / differ:file(91) | N0540 | 151/151 | no | - |
| uhd | arb_idx_cast | differ:endline(2) / differ:endline(2) | 1/1 | N0090 (B) | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) | same | - | 0/0 | yes (pair B, optimistic) | IDENTICAL |
| uhd | anon_struct_packed_dim | differ:fullname(43) / differ:fullname(43) | 2/2 | N0014 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | OutputSizeWithParameterOfInstanceInitializedByStructMember | differ:line(8) / differ:line(8) | 4/4 | N0191 (A) | emitDroppedCall14 (StmtEmit.cpp, law classArgBind12) | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | ibex_tracer | differ:fullname(579) / differ:fullname(579) | 6/6 | N0563 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | cfg_func_width_loop | differ:line(3) / differ:line(3) | 7/7 | N0263 (A) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec | same | - | 0/0 | yes (pairs A+B, optimistic; decoded, no law) | IDENTICAL |
| uhd | struct_param_func_config | differ:fullname(5) / differ:fullname(5) | 7/7 | N0817 (A) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) | same | - | 0/0 | yes (pair A, optimistic; decoded, no law) | IDENTICAL |
| uhd | int_types | differ:fullname(82) / differ:fullname(82) | 8/8 | N0912 (B) | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) | **equal (r11u200, measured)** | - | 0/0 | yes (r11u200, measured) | IDENTICAL |

**The count: 50 row-modes / 27 tests -> 46 / 25 after r11u200 (measured) -> 20 / 11 after both pairs (optimistic; 32 /
18 without the 12 named optimisms of section 5); probe 742 -> 728 -> 588.**

## 8. Structural rows and downstream-visible faces

### 8a. Structural rows (first field depth / type / count)

| row | ddc67d87 | after r11u200 | first cluster | what it needs |
|---|---|---|---|---|
| Scr1SvTests d/t | `endcol(29)` | **`type(1)`** | N0791 `struct\|golden-only:fewer-copies\|ref_obj\|under:cont_assign` (B, ModuleEmit `emitContAssigns`) | r11u200 3d: `assign ifu2imem_cmd_o = SCR1_MEM_CMD_RD;` (scr1_pipe_ifu.sv 607) — golden SHARES the definition cont_assign and binds the right side to an IMPLICIT `logic_net work@scr1_pipe_ifu.SCR1_MEM_CMD_RD` with no file, because Surelog's per-file compilation units leave the include-guarded `$unit` enum constant unresolved; ours folds it (`1'b0`). **A Surelog binding defect: no law without inventing an unresolved-name net slang resolves; the row cannot convert without that model.** Behind it 10 more B clusters (UhdmExporter `cloneUnitParamRhs` / law unitRefSubst N0021 N0921 N1009 N1112 N1113; TypeEmit `emitSyntaxExpr` N0030 N0078 N0426 N2405; ModuleEmit N0284) |

At ddc67d87 no corpus row is structural (the Scr1SvTests `type(1)` of map 11 was cleared by pass 195's law
evalFuncExecCallArgTs191; law_exprstmt + law_typeemit re-expose a different one). The probe set holds 34 `depth` and 71
`type` first fields at ddc67d87, 33 and 71 after r11u200.

### 8b. Downstream-visible faces ([drivers/dsfaces.py](drivers/dsfaces.py): the gate's own `one()`, a fresh `GOLDEN_CACHE`, both binaries; [evidence/downstream/](evidence/downstream/))

127 cases. HEAD: 92 IDENTICAL, 16 EQUIVALENT, 13 DIVERGENT, 6 STATUS_DIFF; law200: 97 IDENTICAL, 16 EQUIVALENT, 8
DIVERGENT, 6 STATUS_DIFF. Every verdict the law binary changes moves to IDENTICAL (the five r11u199 N7 cases).

| face | cases | map 11 (4a65840e) | **HEAD (ddc67d87)** | law200 | what it needs |
|---|---|---|---|---|---|
| r11u173 N1: `$high` onto an implicit net in a generate-for | r11u173verify rq/q08 (q03 control) | q08 DIVERGENT | **DIVERGENT** | DIVERGENT | ModuleEmit's generate-scope cont_assign emission has no sysFold branch (B); unchanged since map 8 |
| r11u173 N2: `g[S.a].x` | r11u173verify hw/w12, w13 | DIVERGENT | **DIVERGENT** | DIVERGENT | the struct-parameter member index fold in a hier_path (ExprEmit, A); not decoded |
| pass 158: the size cast as a whole CA value | r11u158repro sc/c1-c17 | c10, c12 EQUIVALENT | **c10, c12 EQUIVALENT**, 15 IDENTICAL | same | c10 gen-if `3'(-1)` (ModuleEmit emitBlock), c12 instance-overridden `W'(7)` (ModuleEmit emitContAssigns) |
| pass 160: LogicTypespec's defect candidate | scratch copies of r11u160repro residue LT l01, l02 | l02 DIVERGENT | **l02 DIVERGENT** (`$bits(x)` 2 vs 32), l01 IDENTICAL | same | a user decision |
| pass 181: unsized based literal as a whole CA right side | r11u181repro us/u01-u08 | u02, u08 EQUIVALENT | **u02, u08 EQUIVALENT** | same | golden sizes it to the target (Surelog's cont_assign writer clone, pass 184 R7); ModuleEmit |
| r11u185: generic ANSI interface port after an interface-typed port | r11u185verify GV v01-v15, PG/p04 | v07 v08 v09 v15 p04 STATUS_DIFF | **the same five STATUS_DIFF** (ours READ_FAIL), v02 v11 EQUIVALENT | same | type the generic port in the definition view like its predecessor (ModuleEmit, B); stage 1, the strict map cannot see it |
| r11u185 PU/u06: `C = B` beside `$bits(B)` and `B.D` | PU/u06 | DIVERGENT | **DIVERGENT** | same | golden expands C's listing to tagged patterns (ParamEmit, A) |
| r11u185 UD/u04: UDP-form instance array | UD/u04 | DIVERGENT | **DIVERGENT** | same | ModuleEmit instance-array UDP form (B); r11u200's law posOpConnKeepsRefModule200 does not reach it |
| v11u171: UDP-form swallow | v11u171repro Q c01-c14 | c02 c08 c14 EQUIVALENT | **c02 c08 c14 EQUIVALENT** | same | unchanged since map 10 |
| **r11u194 N1: the module-local parameterized class crash** | r11u194verify Z/z01, X/x01; r11u200dec K k01-k08 | z01 x01 STATUS_DIFF (slang lane CRASH) | **z01 IDENTICAL, x01 EQUIVALENT (nohier); K: 7 IDENTICAL, k02 EQUIVALENT; `--elabuhdm` rc 0 on z01 x01 k01 k02 k03 k08** | same | **CLOSED by pass 196** (laws modGenericClassListed196, modGenericHandleBare196, modClassTsLinksDefListing196); r11u200's own class law is a duplicate (dropped in the rebase) |
| r11u190 N5: a split port redeclared `real` | r11u190verify R/r01; r11u191dec R r01-r04 | r01 r01 r02 DIVERGENT, r03 EQUIVALENT | **all IDENTICAL** | same | CLOSED by pass 196 (law splitPortRealRedeclLogicTs191) |
| r11u190 N6: a 70-bit localparam with digit separators | r11u190verify US u01-u04 | u01 STATUS_DIFF | **u01 STATUS_DIFF** (the plugin cannot parse `INT:100000000000000000000`) | same | not decoded |
| pass 186's P face: the elaborated constant sized to the LHS | r11u191dec U (the 18 map 11 measured) | 10 EQUIVALENT, u08 DIVERGENT | **15 IDENTICAL; u08, u_p02, u_p07 EQUIVALENT** | same | pass 196 landed law elabCaConstLhsSized191; u08 (a negative int), u_p02, u_p07 stay |
| r11u199 N7: `$bits` of a select in a generate body | r11u199verify W/w8, r11u200dec B b01-b05 | (new) | **w8 b01 b03 b04 b05 DIVERGENT** (ours `connect \z 32`, Surelog lane 5); b02 IDENTICAL (the control) | **all IDENTICAL** | law genBlockBitsKeepsSelect200 (unlanded: A ExprEmit + B TypeEmit halves, one in each pair's first patch) |
| r11u199 N6: casts in an array net's initializer | r11u199verify C/c06 | (new) | **DIVERGENT** | DIVERGENT | the elaborated `$signed` takes the net's typespec in golden (ModuleEmit net-declaration assignment, B); decoded by r11u200, no law |
| r11u199 N5: an enum-typed type-parameter port written by a cast | r11u199verify X/x06 | (new) | **DIVERGENT** | DIVERGENT | a Surelog defect (the Surelog lane's netlist is the wrong one); no law |
| r11u199 N4: fill conditionals in a generate loop / on a member target | T/t03, X/x05, T/t04 | (new) | t03, x05 EQUIVALENT; t04 IDENTICAL | same | not reached |
| r11u199 N8: `$unsigned` / `$signed` of a select in a generate loop | W/w1, w2 | (new) | IDENTICAL | IDENTICAL | |

## 9. The per-ground briefs (on top of r11u200 measured + both pairs optimistic)

The base is 30 row-modes / 16 tests cleared. **The remaining 20 row-modes carry** by open-cluster count 1: 2
(PreprocTest), 4: 2 (LogicTypespec), 6 or more: 16; by ground: B only 6 (PreprocTest, LogicTypespec, Scr1SvTests), both
14. Every OPEN cluster of ground A (132) clears 0 row-modes alone; every OPEN cluster of ground B (177) clears 6.
**No remaining row ends on ground A alone.** The greedy picks by row-modes cleared per cluster added
([evidence/report.txt](evidence/report.txt) section 8, [evidence/greedy12.json](evidence/greedy12.json)); a candidate is
the whole open set of one remaining row.

**Ground A.** Empty: every remaining row needs ground B too.

**Ground B, deep (whole rows).**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0056 | 2 | 32 | 17 | PreprocTest d/t (not implementable) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) |
| 2 | N0083 + N0422 + N0484 + N1149 | 2 | 34 | 18 | LogicTypespec d/t (a user decision) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) |
| 3 | N0021 N0030 N0078 N0284 N0426 N0791 N0921 N1009 N1112 N1113 N2405 | 2 | 36 | 19 | Scr1SvTests d/t (N0791 is the Surelog defect of 8a) | cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) |

**Joint (both grounds), deep.**

| step | clusters | +row-modes | cum row-modes | cum tests | rows |
|---|---|---|---|---|---|
| 1-3 | as ground B | 6 | 36 | 19 | PreprocTest, LogicTypespec, Scr1SvTests |
| 4 | 23 (19 A, 4 B; first N0923) | 2 | 38 | 20 | BlackBePipeInt d/t |
| 5 | 25 (first N0778) | 2 | 40 | 21 | BuildUVMPkg d/t |
| 6 | 20 (3 A, 17 B; first N1249) | 1 | 41 | 22 | Rggen d |
| 7 | 43 | 2 | 43 | 23 | SimpleUVM d/t |
| 8 | +3 (N0123 N0447 N1424) | 1 | 44 | 24 | Scoreboard d |
| 9 | 48 | 1 | 45 | 24 | Earlgrey_0_1 t |
| 10 | +13 | 1 | 46 | 25 | Earlgrey_0_1 d |
| 11 | ~120 | 2 | 48 | 26 | SeqDriver d/t |
| 12 | +8 | 2 | 50 | 27 | MiniAmiq d/t |

In short, for the next two refills:

* **Module/type ground (pair B after r11u202).**
  1. **The r11u200 law_typeemit refinements, first** (section 4): law classTdRetSharesTypedefTs200 must leave the
     return VARIABLE's span on the data type (N2467: a qualified class-scope typedef return,
     `uvm_resource_types::rsrc_q_t lookup_name`, 52 records on 9 row-modes) and the late-bound `this_type` return's FILE
     on the return token (N2468, 14 records); law defPortPackedTsKeepsWholeSpan200 must decline on a port with no
     data-type keyword (`input [A-1:0][B-1:0] x`: golden keeps the first dimension; Earlgrey's new first record).
  2. **The near rows of this ground**: arb_idx_cast d/t — ONE cluster left after r11u200, N0090 (`#360` / `#384`): the
     type parameter `idx_t`'s default `logic_typespec` read by the elaborated `idx_t [2**NumLevels-2:0] index_nodes`
     spans golden 8:40-15:27 (the default's start to the USE's packed-dimension end), ours 8:40-8:60 (TypeEmit
     `makeTypeParamDefaultTs`, law typeParamDefaultBoundNoReduce20; pass 198 section 8). UnitElabBlock d (with ground
     A's N0016): N0011, the implicit net's file (below).
  3. **InterfaceStructMemberPort d/t** (5 clusters, all B: N0519 N1117 N1126 N1128 N1134, ModuleEmit
     `emitInterfaceInstance` near law modportExprPort), **ClassTypeParam d/t** (8 / 10 B clusters, UhdmExporter
     `emitClassTsParams` / `exportDesign`; never decoded), **HierPathTypespec t** (N1174), **OutputSize... d/t**' B half
     (N0853 N1127), **anon_struct_packed_dim** (N0014, 39 of 43 records), **ibex_tracer**'s B half (N0563).
  4. **cfg_func_width_loop's kept call** (N0133 N0487: law evalFuncCastMemberKeepsCall191 extended to a package
     localparam's member read reached through a callee's `for` / `if`).
  5. **The heads the pairs leave on the big rows**: BuildUVMPkg N0778 (a package enum typedef's ref name doubled
     `uvm_pkg::uvm_pkg::`), Earlgrey N0945 (the generate-scope port-connection select, both views), Rggen N1249 (the
     generate-scope `indexed_part_select` name), MiniAmiq N0144 (the `uvm_severity` enum file).
  6. **The UVM ground-B families** (177 B clusters in all; 7-row each: N0288 N0121 N0262 N0318 N0321 N0337; 6-row: N0266
     N0043 N0078 N0426 N0974).
  7. Not routed: PreprocTest (N0056), LogicTypespec, Scr1SvTests' N0791 (Surelog defect).
* **Expression/parameter ground (pair A after r11u201).**
  1. **The near row UnitElabBlock t** — ONE cluster left after r11u200, N0016: the implicit net golden creates for the
     named-block variable `hold` read in `hold = in;` (top.v 21:1-21:5) carries NO file (`work@mod.hold`, golden
     `vpiFile` empty; ours `top.v`: law vpiFileOnEveryLocated117 reaches an object golden leaves unfiled). With B's
     N0011 it clears UnitElabBlock d too.
  2. **The UVM heads the pairs leave**: N0540 (MiniAmiq, SeqDriver: a class typedef's ref name in a module-imported
     package copy, ParamEmit `emitPackage` law pkgImportCloneLastWriter32) and N0689 (SimpleUVM, Scoreboard: the same
     object named `uvm_pkg::uvm_pkg::`, ParamEmit law classNestedClassTdJoinsPkgGroup50). Each is the first OPEN record
     of 3-4 row-modes.
  3. **struct_param_func_config's A half** (N0045 N0675 N2412 + the memberScope names) and **cfg_func_width_loop's**
     (N0754 N0794 + the evaluator stamp N0263 N0025 N0033), both decoded by r11u200 without a law.
  4. **The UVM ground-A families** (132 A clusters with a row; 7-row each: N0290 N0098 N0303 N0304 N0305 N0306 N0050
     N0123 N0297 N0314 N0326 N0352 N0374 N0375 N0387 N0390 N0392 N0397 N0399), **Earlgrey's A half** (34 / 25).
  5. **BlackBePipeInt's head** N0923 stays an identity family (19 A clusters behind it).
  6. The largest A case-only clusters: N0739 (27 cases, pass 198 R9), N1903 / N1904 (21 / 20), N0476 / N0477 (20 each).

## 10. Prediction audit of map 11 ([evidence/audit.txt](evidence/audit.txt); `drivers/audit12.py` reads the committed baselines at every landing)

**Since map 11 (60 row-modes at 4a65840e), 10 row-modes converted**: pass 193 2 (rsp_gen_minimal d/t), pass 195 2
(StructParamPatternInitCast d/t), pass 198 2 (ibex_pmp d/t), pass 196 4 (const_cast_signext d/t, func_typename_ret d/t).
**All 10 were predicted by map 11** (its r11u191 + pairs column; 10 of 10), and 0 converted row was not predicted.

| map 11 predicted | row-modes | converted | by | still open at ddc67d87 |
|---|---|---|---|---|
| r11u191 (measured) + pairs r11u195 / r11u193 (optimistic) | 32 (24 without its five named optimisms) | **10** (10 of the 24) | 193 2, 195 2, 196 4, 198 2 | 22 (8 of them the named optimisms) |
| section-9 ground-B list / deep B | 4 / 8 | 0 | - | PreprocTest d/t, LogicTypespec d/t; int_types d/t and SVSwitch d/t **convert under r11u200's patches** (measured here, unlanded) |
| section-9 deep A+B | 28 | 0 | - | 28 (4 of them convert under r11u200's patches) |
| **any of them** | **60** | **10 (17%)** | | 50 |

**Why 22 predicted row-modes did not convert.** FuncStructValSimple d/t and FuncStructVal d/t: pass 195 R10 and pass 198
R8 list them as not reached (the `INT:N` constant-function leftovers). InterfArrayBind d: needs the ModuleEmit half.
InterfaceModPort d/t: the harness flag. InterfaceStructMemberPort d/t, ClassTypeParam d/t, UnitElabBlock d/t,
HierPathTypespec t: pass 193 and pass 196 did not attempt them (pass 196 section 7 (4)); UnitElabBlock moves under
r11u200 to one or two records. OutputSize d/t: its first records are ground A's `hier_path Info.x` spans (pass 196
section 7), and neither pass 195 nor 198 took them. anon_struct_packed_dim d/t: needs both N0014 (39 records, B) and N0820
(A). arb_idx_cast d/t: **one cluster short** — pass 196 cleared `#209` (law tpArrBoundAtLeftOperand196) and pass 198 14
records (laws genHopFoldSelName198, genCaCastRhsRefUnnamed198); N0090's two records (TypeEmit) remain. ibex_tracer d/t:
not attempted. cfg_func_width_loop, struct_param_func_config: decoded by r11u200 without a law.

**Probe cases.** Map 11 predicted 145 cases. Of the 190 that converted since, **26 were predicted** (1 of pass 193's, 5
of pass 195's, 2 of pass 196's, 18 of pass 198's) and **164 were not**: pass 193's 143 (N1897's
105 nested-module grid cases of law nestedDefChainName193, N1169's 22 r10rgg9 ternary cells, N1922 9, N0129 8 ...) —
pass 193 landed after map 11 measured and map 11's pair-B routes never named those grids — pass 198's 19 and pass
195's 2. 119 predicted cases did not convert (88 of pair B's optimistic, 20 of pair A's, 11 needing both).

**Site pins** (map 11's pin of each converted row's first cluster, against the files of the landing laws, read from src
by the section sign): **10 of 10 name a fix file, 6 at the mint** (StructParamPatternInitCast: ParamEmit;
const_cast_signext: ModuleEmit; func_typename_ret: TypeEmit) **and 4 at a caller** (rsp_gen_minimal: pin ExprEmit, laws in
ModuleEmit + UhdmExporter, the caller `emitInstance`; ibex_pmp: pin TypeEmit `buildStructTs` < ParamEmit <
UhdmExporter, laws pass 193's tfArgOutsideCopyOrder193 in UhdmExporter and pass 198's callArgVarSelStamp198 in ExprEmit —
a two-landing conversion whose second record map 11 had pinned in ExprEmit, N0943). Map 11 for map 10: 24 of 24 (12 at
the mint); map 10 for map 9: 12 of 14. The rule stands: read the first caller outside the mint's file, and expect a
row's records to split across grounds.

**The rate over time.** Map 11's 60 predictions converted 10 (17%) over five landings; map 10's 58 had converted 24
(41%) by map 11 and map 9's 68 34 (50%) by map 11. Map 11's lower rate follows its own section 5: 28 of its 60 predictions
came from the deep whole-row lists alone, on the big families and the mid-size joint rows (no pass took one), and 8 of the 32 pair predictions were named
optimisms, none of which converted.

**Clusters.** Map 11's covered set (99): 17 gone, 6 lost every row (N0022 N0023 N0031 N0042 N0443 N0738), 7 fell (N0003
4 -> 2, N0014 6 -> 4, N0085 4 -> 2, N0192 9 -> 4, N0219 9 -> 7, N0416 6 -> 2, N0448 5 -> 3), 69 unchanged (the pair
routes passes 193-198 did not take). Map 11's section-9 lists (407): 16 gone (N0235, N0342, N0941, Rggen's 11 one-row
clusters, N0790, N2387), 5 lost every row, 5 fell, 2 grew, 379 unchanged. 32 clusters map 11 routed nowhere lost cases
(pass 193's nested-module and ternary grids). The item-by-item recount is audit.txt section F.

## 11. The family view

| family | row-modes / tests | clusters per row at ddc67d87 | after r11u200 (measured) | open per row after r11u200 + both pairs | distinct clusters: ddc67d87 -> r11u200 -> + pairs | cleared |
|---|---|---|---|---|---|---|
| UVM (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg) | 9 / 5 | 86-223 | 84-214 | 25-151 | 272 -> 263 -> 195 | 0 |
| Earlgrey_0_1 | 2 / 1 | 65-69 | 65-69 | 57-61 | 78 -> 78 -> 70 | 0 |
| Rggen (default only) | 1 / 1 | 25 | 24 | 20 | 25 -> 24 -> 20 | 0 |
| BlackBePipeInt | 2 / 1 | 24-26 | 24-26 | 21-23 | 26 -> 26 -> 23 | 0 |
| Scr1SvTests | 2 / 1 | 21 | 17 | 11 | 21 -> 17 -> 11 | 0 |
| ibex (tracer) | 2 / 1 | 6 | 6 | 0 | 6 -> 6 -> 0 | 2 (pairs A+B, optimistic) |
| SVSwitch | 2 / 1 | 9 | 0 | 0 | 9 -> 0 -> 0 | 2 (r11u200, measured) |
| jeras, ApbSlave, ibex_pmp / icache / multdiv_fast | 0 | - | - | - | - | converted |

**The near rows.** At ddc67d87, 8 row-modes in 5 tests are single-cluster: InterfArrayBind d N0427, InterfaceModPort d/t
N0040, PreprocTest d/t N0056, HierPathTypespec t N1174, **arb_idx_cast d/t N0090**. After r11u200 (measured) also
**UnitElabBlock t N0016**, and two-cluster rows UnitElabBlock d (N0011 + N0016) and anon_struct_packed_dim d/t (N0014 +
N0820). **The implementable near rows are arb_idx_cast d/t (B) and UnitElabBlock d/t (A + B)**; InterfaceModPort needs
the harness flag, PreprocTest is not implementable, HierPathTypespec t is the naming-context face. After both pairs only
PreprocTest d/t keeps one open cluster and LogicTypespec d/t four; every other remaining row has 11 or more.

**The UVM family: r11u175's census by family key** (`uvmcensus.py` + `uvmfamilies.py` over map 8's cluster keys, the
five UVM rows' default databases; [evidence/uvm/](evidence/uvm/)):

| family | 4a65840e (map 11) | 4a65840e + r11u191 (map 11) | **ddc67d87** | **ddc67d87 + r11u200 patches** |
|---|---|---|---|---|
| F2 object multiplicity | 12,666 | 11,862 | **11,862** | **11,840** |
| F5 reference full names | 10,153 | 9,544 | **9,293** | **8,698** |
| F6 file facets | 2,627 | 2,467 | **2,065** | **2,173** |
| F7 expression spans outside the pp model | 1,399 | 1,182 | **1,182** | **1,211** |
| F4 formal / typespec / bound spans | 1,059 | 1,050 | **1,040** | **483** |
| F1 preprocessor location model | 720 | 720 | **720** | **720** |
| F8 names | 565 | 565 | **565** | **95** |
| F9 value / order / depth | 292 | 283 | **283** | **283** |
| F3 typedef relocation spans | 139 | 139 | **139** | **139** |
| **all** | **29,620 (286 clusters)** | **27,812 (275)** | **27,149 (271)** | **25,642 (262)** |

Since map 11, passes 195, 196 and 198 took F5 -860 (method-call path names, formal defaults), F6 -562 (the formal
typedef-clone file, the queue bound), F4 -19, F2 -804 (the r11u191 patches and Scoreboard's svunit order draw of map 11,
796 objects). The r11u200 patches take F4 -557 and F8 -470 (the class typedef return: the walk no longer diverges at
`get_event_pool`) and F5 -595, and ADD F6 +108 / F7 +29: the census is walk-keyed, so records the walk now reaches past
the old divergence count here (Scoreboard's F6 171 -> 277), and N2468's 14 file records are among them. **The largest UVM
families are still F2 (11,840: the importer clones' copies) and F5 (8,698).**

**Order-blind uhdm-dump distance to golden** (strict records, depth dropped, multiset: ours-not-golden + golden-not-ours;
`drivers/uvmdist.sh`, [evidence/uvm/uvmdist.txt](evidence/uvm/uvmdist.txt)):

| row-mode | 4a65840e (map 11) | **ddc67d87** | **ddc67d87 + r11u200** |
|---|---|---|---|
| MiniAmiq d / t | 16,071 | **15,559** | **15,366** (-193) |
| SeqDriver d / t | 12,461 | **11,805** | **11,624** (-181) |
| SimpleUVM d / t | 5,070 | **4,538** | **4,368** (-170) |
| Scoreboard d | 3,877 | **3,451** | **3,283** (-168) |
| BuildUVMPkg d / t | 2,071 | **1,907** | **1,703** (-204) |
| SVSwitch d / t | 102 | **102** | **0** (converted) |
| Earlgrey_0_1 d / t | - | **8,570 / 8,316** | 8,562 / 8,308 |
| Rggen d | - | **10,659** | 10,655 |
| Scr1SvTests d / t | - | **251** | 195 |
| UnitElabBlock d / t | - | **26 / 24** | 4 / 2 |
| BlackBePipeInt d / t | - | **31,837 / 31,882** | unchanged |

Passes 193-198 moved the UVM rows another 3-11% toward golden since map 11 without converting one; the r11u200 patches
take 168-204 more each (net of their 74 AWAY records, section 4).

## 12. Files

* **cluster_index.csv**: one row per cluster (893 = 891 + N2467 / N2468), with rows / probe at ddc67d87, after r11u200
  (`rows_after_law`), after both pairs (`rows_after_pairs`), `alone_on_top_of_pairs`, `first_in_after_pairs`,
  `alone_on_pristine`, coverage, ground, site, map 11's rows and coverage (`map11_*`), families, probe laws, key, example.
* **clusters.csv**: row-mode x cluster with a `first` flag; **probe_clusters.csv** the same per case.
* **fail_list.csv** (50) and **probe_fail_list.csv** (742): first cluster, coverage, ground, site, cluster counts, family,
  downstream verdict, the strict cell after r11u200, the first OPEN cluster after the pairs, the open clusters left, `clears`.
* **evidence/**: `clusters/` (record dumps, one example per cluster with a row or >= 3 cases: 535) and `objects.csv`
  (one example object for every cluster); `report.txt` (drivers/report12.py), `audit.txt`, `final12.txt`,
  `pristine_index.csv`, `greedy12.json`, `routes.json`, `ground_override.json`, `sites.json`, `pinwant.txt`, `pins/`,
  `evwant.txt`; `law200_on_ddc67d87.patch` (the measured binary's source, NOT applied) and its ground halves
  `lawA_on_ddc67d87.patch` / `lawB_on_ddc67d87.patch` (the rebase pair B r11u202 needs at ddc67d87, the class-listing
  duplicate dropped); `controls/`; `determinism/`; `uvm/`; `away/` (the AWAY census and its switch attribution);
  `sweeps/` (`sweep_law200.txt`, `byteverify_law200_vs_head.txt`, `census/` (the frozen prediction),
  `attribution_lawA/`, `attribution_lawB/`); `downstream/` (`dsfaces_P.csv`, `dsfaces_L.csv`, `cases.txt`).
* **drivers/**: `run12.sh` (the pipeline as run), `env.sh`, `common.py` (key rewrite + the fence), `jobs.py`,
  `probejobs.py`, `probelaw.py`, `strict_runs.sh`, `run1.sh`, `cc.sh`, `strictcmp_x.cpp`, `objrank.cpp`, `analyze.py`,
  `final12.py`, `pinmulti.py`, `sites.py`, `mksites12.py`, `crosssection.sh`, `report12.py`, `audit12.py`,
  `tables12.py`, `evid.py`, `census.sh` + `censum.py`, `lawsweep.sh`, `bvmirror.sh`, `attribution.sh`, `awaycensus.py`,
  `sw.sh`, `dsfaces.py`, `uvmcensus9.sh` (+ r11u175's `uvmcensus.py`, `uvmfamilies.py`), `uvmdist.sh`, `det.sh` + `ob.sh`.
