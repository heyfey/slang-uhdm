# r11u165map: the strict ground map, eighth edition (measurement only)

**Base.** Measured at `f2f2d30b` (branch matrix-1.87), HEAD of the branch for the whole pass (no landing after it).
It sits after passes 152 (`78f8134a`), 154 (`fc99b2d5`), 155 (`75226e07`), 158 (`202fb296`), 160 (`d48f8f8a`) and
**163 (`576b21fa`)**, the decodes r11u157 (landed by pass 158), r11u161 (`16607134`, law.patch not in src) and r11u166
(`f2f2d30b` itself, law patches not in src), and the verifications r11u159 (`73a67945`) and r11u162 (`0f607463`).
The reference sweep is `/tmp/intr11u163` (read-only).

**Pair A r11u163 is not live: it LANDED as pass 163 (`576b21fa`) before this base**, so its conversions (16 row-modes,
50 probe cases) are already in the committed baselines, and the prediction audit (section 7) reads them as a landing.
No live pair-A brief was handed to this map, so no pair-A yield is computed; section 6's ground-A list is the next
pair-A refill. **Pair B r11u164 is live.** Its brief starts with r11u161's law.patch and holds the macro model's next
faces, so the two unlanded decodes are measured here as pair B's share (one binary, section 3a). Its other items are
applied optimistically (section 3c).

Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited. This directory is the whole patch.

Conventions:
- Law names are written `law <name>`, without the section sign, so `scripts/law_index.py` does not read this
  directory as a pass of laws.
- The slang-fenced tests are written `FENCED_n` (drivers/redact.py). No fenced row is STRICT_NOTEQUAL at f2f2d30b, so
  none is in the fail list. **No binary, gdb run or script touched a fenced test's sources or databases in this pass.**
  - `drivers/jobs.py`, `pinmulti.py`, `uvmdist.sh` and `dsfaces.py` read the fenced names from RESUME.md and refuse
    them (fail closed).
  - The byte comparisons ran on hard-link mirrors that leave the 8 fenced row-mode databases out (`drivers/bvmirror.sh`,
    `fenced_skipped=8`).
  - The attribution re-runs used `--filter` lists of named tests, none fenced.
  - The gate sweeps ran every row, as the gate mandates.

Binaries, frozen with `chmod 555` in `/tmp/r11u165_bin` before any measurement:

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `2a705713aa2d9ba859d3fd83eaa95ed7` | worktree `/tmp/wt_r11u165` at f2f2d30b, system-deps config, `-j 2`. Byte-identical to the main tree's `build/slang-uhdm`, which the reference sweep ran (3273 of 3273 `slang:` lines) |
| `slang-uhdm.dec` | `f182a177d286301c74a0cf46a6d5a116` | MEASUREMENT ONLY: f2f2d30b + `evidence/decodes_scratch.patch` = r11u166's `law_on_d48f8f8a8.patch` + `law_litall.patch` + `law_macroconn.patch` (all clean `git apply`) + r11u161's `law.patch` (a 3-way apply; its only two conflicts are the helper declarations beside `r11u160Law`, resolved by keeping both sides). The scratch patch applies clean on a fresh f2f2d30b |
| `slang-uhdm.g1` | `aa26f5092a8f9f4455aeed7800295e3d` | f2f2d30b with `-DCMAKE_CXX_FLAGS=-g1`; gdb only |
| `slang-uhdm.0f60` | `a52c8ec19093858f0da7a4daae5bfbad` | 0f607463 (before passes 158 and 160) = r11u166's pristine md5; the UVM distance only |
| `slang-uhdm.d48f` | `76f6b803e83ec4e631b29a1f4d18b1bd` | d48f8f8a (after 158 and 160, before 163) = r11u166's `wdH` md5; the UVM distance only |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's; the comparator is unchanged since map 7 |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | drivers/strictcmp_x.cpp (maps 3-7's variant), same md5 as map 7's |
| `objrank` | `87f0a607ef941a44e4d7a2487fae7016` | drivers/objrank.cpp |

## 0. Where we stand (f2f2d30b; the committed baselines are the fail list)

| corpus | mode | judge-equal | strict-equal | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 437 | 43 |
| surelog | testflags | 474 | 434 | 40 |
| uhdm2rtlil | default | 803 | 769 | 34 |
| uhdm2rtlil | testflags | 803 | 769 | 34 |
| probe cases | | 4087 | 2597 | 1490 |

**The fail list is 151 row-modes (83 surelog + 68 uhdm2rtlil) in 79 tests, plus 1490 probe cases.** All 151 row-modes
were dispatched; none is fenced.

First fields, tallied from the detail column of results/golden_*.csv:
* surelog 83: fullname 30, line 20, endcol 12, endline 5, file 5, col 4, value 4, name 2, type 1;
* uhdm2rtlil 68: fullname 30, file 14, line 12, endcol 4, name 4, endline 2, col 2;
* probe 1490: fullname 599, endcol 231, line 229, file 116, type 101, depth 92, name 58, col 43, endline 14,
  decompile 4, value 3.

Mode asymmetries:
* surelog NE in default only: InterfArrayBind and UnsizedParam (testflags CMP_EQUAL), YosysBigSimEllip (testflags
  NO_DATABASE), Rggen (testflags SURELOG_FAIL), Scoreboard (testflags SLANG_REJECT);
* surelog NE in testflags only: HierPathTypespec and LocalScopeHierPath;
* every uhdm2rtlil fail test is NE in both modes, and **every uhdm2rtlil fail row-mode is downstream IDENTICAL**
  (68 of 68).

**Since map 7.** Map 7 counted 321 row-modes and 1697 probe cases at 89d599ef (291 and 1642 after pass 147). Since
then 170 row-modes and 207 probe cases converted, and none entered:

| landing | row-modes | tests | probe cases |
|---|---|---|---|
| pass 147 (`b6af876c`) | 30 | 15 | 55 |
| pass 152 (`78f8134a`) | 36 | 18 | 46 |
| pass 154 (`fc99b2d5`) | 25 | 13 | 15 |
| pass 155 (`75226e07`) | 20 | 10 | 8 |
| r11u162 verification (`0f607463`) | 0 | 0 | 1 |
| pass 158 (`202fb296`) | 13 | 7 | 14 |
| pass 160 (`d48f8f8a`) | 30 | 15 | 18 |
| pass 163 (`576b21fa`) | 16 | 8 | 50 |

**Clusters.** Map 7 had 1460 clusters; this map has 1284 (854 carry a corpus row, 776 a probe case). 1273 keep their
map-7 id, because the key is maps 4-7's key. 187 map-7 clusters are gone. **11 are new, N2400-N2410:**

| cluster | rows f2f2d30b -> after the decodes | probe -> after | ground | key | example | site |
|---|---|---|---|---|---|---|
| N2400 | 9 -> 9 | 0 -> 0 | A | `fullname\|ref_obj\|tok:id.id[]::id::->\|under:hier_path` | surelog/default/BuildUVMPkg #82349/82304 ref_obj 'addr' golden=uvm_pkg::uvm_reg_predictor::write::predict_info | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNamesByPath133) < emit |
| N2401 | 9 -> 9 | 0 -> 0 | A | `fullname\|ref_obj\|tok:id.id.id[]::id::->\|under:hier_path` | surelog/default/BuildUVMPkg #164660/164604 ref_obj 'obj' golden=uvm_pkg::uvm_objection::m_execute_scheduled_fo | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNamesByPath133) < emit |
| N2402 | 7 -> 0 | 0 -> 0 | A | `span\|ref_obj\|col+endcol\|under:func_call` | surelog/default/Scoreboard #11112/11126 ref_obj 'UVM_DEBUG' golden=124:81:124:90 ours=124:863:124:872 | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law namedTfArgsFormalSlots4) < emitStmt ( |
| N2403 | 7 -> 0 | 0 -> 0 | B | `span\|ref_obj\|col\|under:bit_var` | surelog/default/Scoreboard #68988/69001 ref_obj 'uvm_callbacks::m_register_pair' golden=60:55:60:109 ours=60:4 | emitClassPropInit29 (UhdmExporter.cpp, law srlgBitsFoldArg) < emitClassDefn (UhdmExporter.cpp, law classPropInit29) < em |
| N2404 | 7 -> 0 | 0 -> 0 | A | `span\|operation\|col+endcol\|under:func_call` | surelog/default/Scoreboard #62601/62610 operation '' golden=116:65:116:77 ours=116:114:116:126 | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law namedTfArgsFormalSlots4) < emitSt |
| N2405 | 2 -> 2 | 0 -> 0 | B | `struct\|golden-only:fewer-copies\|ref_obj\|under:int_typespec` | surelog/testflags/Scr1SvTests #63286/-1 ref_obj 'ALLTRIG_W' golden=3 objs ours= | emitSyntaxExpr (TypeEmit.cpp, law elabMisevalRefSubst) < emitSyntaxExpr (TypeEmit.cpp, law structParamPathBaseAtMember13 |
| N2406 | 2 -> 2 | 0 -> 0 | A | `fullname\|ref_obj\|tok:id["id"].id::->\|under:method_func_call` | surelog/default/BuildUVMPkg #96756/96711 ref_obj 'uvm_run_phase::get' golden=uvm_pkg::uvm_domain::get_common_d | emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitExpr (Expr |
| N2407 | 0 -> 0 | 3 -> 0 | A | `span\|begin\|endcol\|under:initial` | r11v11u8repro/v12 #3/3 begin '' golden=3:21:5:5 ours=3:21:5:38 | emitStmt (StmtEmit.cpp, law parBlockJoinTailAfterFirstItem131) < emitProcess (StmtEmit.cpp, law classPropUnitImport21) < |
| N2408 | 0 -> 0 | 3 -> 0 | A | `span\|initial\|endcol\|under:module_inst` | r11v11u8repro/v12 #2/2 initial '' golden=3:13:5:5 ours=3:13:5:38 | emitProcess (StmtEmit.cpp, law classPropUnitImport21) < emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < ex |
| N2409 | 0 -> 0 | 3 -> 0 | B | `span\|module_inst\|endcol\|under:design` | r11v11u8repro/v12 #1/1 module_inst '' golden=3:1:5:15 ours=3:1:5:48 | exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < realMain (uhdm_main.cpp, law genCaPatKeepTagDef |
| N2410 | 0 -> 0 | 1 -> 0 | A | `span\|assignment\|line+col\|under:initial` | r11v11u8repro/v9 #11/11 assignment '' golden=10:9:11:16 ours=12:11:11:16 | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172)  |

* N2400, N2401 and N2406 are UVM hier_path component names with a select inside the path (`predict_info.addr[]`,
  `c.objection.m_sched...`, `m_domains["common"]`: r11u157's R3 shape). Their keys changed when pass 158 landed the
  hier_path element family.
* N2402-N2404 are macro-argument spans on the UVM rows; the r11u166 model clears them.
* N2405 is an Scr1SvTests int_typespec range reference.
* N2407-N2409 sit on r11v11u8repro v8/v10/v12, which the decodes convert; N2410 sits on v9, which they change.

## 1. Method (map 7's pipeline, drivers/run8.sh)

1. **Input.** The READ-ONLY f2f2d30b reference sweep `/tmp/intr11u163`. Its status and strict columns equal
   results/golden_surelog.csv (1596 of 1596 rows), golden_uhdm2rtlil.csv (1742 of 1742) and golden_probe.csv
   (4087 of 4087). The jobs are every `STRICT_NOTEQUAL` row-mode of the committed baselines (151). Each golden is the
   cache entry its cmds.txt names. Every probe case is a job too (4087); its golden is `scripts/check_probe.py`'s
   `cache_dir(rel)`, whose key hashes the case's files.
2. **Strict runs.** `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job.
   * All 151 corpus runs return rc=2.
   * Probe runs return rc=0 on 2597 cases and rc=2 on 1490. Every `differ:<field>(<n>)` cell equals
     results/golden_probe.csv (4087 of 4087, 0 mismatches).
3. **Analysis.** `drivers/analyze.py` records EVERY differing object (map 3's alignment: GNU diff on the key, change
   hunks sub-aligned by type). Its mode-4 reimplementation agrees with the tool's stdout on 1641 of 1641 rows
   (0 VERIFY-MISMATCH, 0 CELL-MISMATCH against the csv cells).
4. **Clusters.** The key is maps 4-7's (`facet|type|shape|under:<walk parent type>` + `@builtin` / `@in-typespec`). A
   key that persists keeps its map-7 id; a new key takes the next id from N2400 (maps 3-7 used N0001-N2392).
5. **Sites.** `drivers/pinmulti.py` ran one gdb session per example row (the `-g1` exporter stops at the example
   object's `Serializer::Make<type>` rank; the main checkout's case directories are the cwd). It pinned 58 clusters:
   the 11 new ones, plus those whose example object changed since map 7, among those with >= 3 row-modes, first on a
   fail row, or >= 40 probe cases (evidence/pinwant.txt).
   * 57 runs wrote the reference database byte for byte (`db=SAME`); 1 did not (N0438, SimpleUVM: the UVM order
     coin) and keeps map 7's pin.
   * 40 new pins name the same mint as map 7's, 6 name another (map 7's pin is kept beside it), 11 are new clusters.

   Every other cluster keeps map 7's pin, marked `[r11u156map pin]` (or an older map's).
   `drivers/mksites8.py` merges the pins.
6. **Ground.** A = ExprEmit/EmitHelpers/StmtEmit/ParamEmit, B = TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/
   uhdm_main, by the pinned mint's file. Overridden where a pass decoded the fix site elsewhere
   (evidence/ground_override.json: map 7's list plus this map's).
   * To B: N0129 (pass 163 S1, ModuleEmit `substNdaParamRefs`), N0525/N0562 (pass 163 S2), N1115 (pass 163 S5),
     N0457/N0136/N0775 (pass 163 S6) and N0284 (pass 163 S7).
   * To A: N0009/N0084, pass 155's R-SP: the copies are minted by ParamEmit `makeParamTs`, the first non-TypeEmit
     caller.

   6 clusters have no partner record and no pin (ground `?`).
7. **Coverage** (evidence/routes.json, drivers/report8.py):
   * **the decodes, MEASURED**: a cluster gone under the decode binary's full sweep reads
     `COVERED r11u164 (decodes r11u161+r11u166, MEASURED)`;
   * **pair B r11u164, OPTIMISTIC**:
     * the named clusters: N0108 (the procedural `localparam type` struct, r11u160 R4), N1174 (HierPathTypespec t),
       N0969 (GenerateUnnamed), N0528 (HighLow's `$high` fold, pass 158 S1), N0430 (UnionCast's union file);
     * the named ROWS (the rest of the ibex family, ApbSlave, GenerateUnnamed, ClassTypeParam, UnionCast, HighLow,
       iface_param_port_width, HierPathTypespec t): their ground-B clusters whose rows are all named rows;
     * the UVM/Earlgrey-only clusters of ground B.

     **A named row does not cover a multi-test cluster**: it reads `OPEN (one shape named by r11u164: ...)` and counts
     as open, as in map 7. The brief's items with no corpus row or probe case (the 2-state/enum vector default TV
     v07/v08, the generate-scope cast fold sc/c10, the delay on the first assignment, r11u162's N1 and N3) have no
     cluster here; their downstream verdicts are in section 5b;
   * **OPEN** otherwise. The status names the pass that left it where a README says so, and map 7's routing where it
     had one (`map 7 gave it to r11u152; pass 152 left it`, `map 7 listed it: ground-X step n`). A cluster the
     decodes reduce but do not clear says so (`[the decodes reduce it: rows a->b]`).
8. **Yields.** The decode binary's full sweep is re-dumped and re-keyed, so it is MEASURED. Pair B's other covered
   clusters are then applied optimistically to that cross-section (a covered cluster counts fixed whole). The
   `alone` column is the rows a cluster clears alone on top of both.

## 2. Positive controls and gates

| control | result |
|---|---|
| surelog/default/1364_2005 | `STRICT_EQUAL 159 objects`, record dumps identical (159 / 159) |
| surelog/default/HierPathInterfBlock | `STRICT_EQUAL 226 objects`, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray | `STRICT_EQUAL 194 objects`, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, lhsPath `design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL,decompile:` both modes |
| analyzer rule vs tool stdout | 1641 / 1641 (f2f2d30b), and on the decode cross-section 1612 / 1612 |
| probe cells vs golden_probe.csv | 4087 / 4087 identical |
| pin validity | 57 / 58 gdb runs wrote the reference database byte for byte; the other (UVM coin) keeps map 7's pin |

Gates. This map lands no binary. The frozen pristine binary ran the full `tests/sweep.sh --jobs 3 --workdir
/tmp/r11u165swP` from the worktree with every pin exported (evidence/sweeps/sweep_pristine.txt). All 3273 `slang:`
lines name `/tmp/r11u165_bin/slang-uhdm`.

| gate | result |
|---|---|
| (1) build | pristine 2a705713 = the main tree's f2f2d30b build; decodes f182a177; g1 aa26f509 |
| (2) probe vs golden_probe.csv | EQUAL 2597 / STRICT_NOTEQUAL 1490; `regressions=0 conversions=0 changes=0`; probe.csv byte-identical to the baseline |
| (3) surelog + uhdm2rtlil vs golden_*.csv | `regressions=0 conversions=0 changes=0` in both. The scoreboards are 480/3 + 474/3 and 803/1/67 |
| (4) downstream | EQUIVALENT 2, IDENTICAL 803, SLANG_REJECT 66; not identical and not excused 0. Joined to results/downstream_uhdm2rtlil.csv, 0 of 871 verdicts differ; joined to the reference sweep's downstream.csv, 0 of 871 rows differ on any column. No row is targeted: this map lands no law |
| (5) uhdm-cmp | no row touched |
| (6) byteverify | Pristine vs the reference sweep (same-length workdirs, fence-clean mirrors, SELFCHECK 951/952 and 1607/1608 flagged): surelog 6 movers, MiniAmiq/SeqDriver/SimpleUVM d/t, the UVM order coin. Their order-blind uhdm-dump diff is 4 lines each, `UINT`/`vpiDecompile` only (evidence/sweeps/byteverify_pristine_vs_head.txt). uhdm2rtlil 0 movers. Probe databases embed the checkout path (worktree against main tree), so all 4087 differ in bytes; a path-normalised uhdm-dump of every 68th case (61) reads 0 differences |
| canaries | canaries.sh: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 `EXPECT_UNKNOWN=1` surelog PASS (ok=58); `EXPECT_UNKNOWN=6` uhdm2rtlil PASS (ok=2) (evidence/sweeps/canaries.txt) |

The sweep's rc is 1 only because the law index reads `STALE`. A clean f2f2d30b checkout reads STALE too
(`scripts/law_index.py --check`), so the cause is not this directory.

## 3. The decodes and pair B: yield, and the fail list after them

### 3a. The decodes, MEASURED (r11u161 law.patch + r11u166 law_on_d48f8f8a8 + litall + macroconn)

A full gate sweep of `slang-uhdm.dec`, `/tmp/r11u165swL` (all 3273 `slang:` lines name it;
evidence/sweeps/sweep_decodes.txt). **Every stage reads `regressions=0`.**

| stage | conversions | changes |
|---|---|---|
| probe | **23** (EQUAL 2597 -> 2620) | 6, every one fewer objects or the next face |
| surelog | **4**: GenIfIfaceParamStructField d/t, YosysMarlann d/t | 23 |
| uhdm2rtlil | **2**: ibex_load_store_unit d/t | 2 (ibex_pmp d/t `file(52) -> file(16)`) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT; 0 of 871 rows differ from the pristine sweep on any column | |

Fresh csv rows, loudly (not written to results/):

    GenIfIfaceParamStructField,default,CMP_EQUAL,,,equal      r11u161 (law defGenPathSel161)
    GenIfIfaceParamStructField,testflags,CMP_EQUAL,,,equal
    YosysMarlann,default,CMP_EQUAL,,,equal                    r11u166 (law_litall: law ppBasedLitWsAfter166)
    YosysMarlann,testflags,CMP_EQUAL,,,equal
    ibex_load_store_unit,default,CMP_EQUAL,,,equal            r11u166 (law.patch: the macro location model)
    ibex_load_store_unit,testflags,CMP_EQUAL,,,equal

**Probe conversions (23)**:
* r11u161: `r10earl_repro/ps23`, `tj`, `r10vearl115repro/w1_memlhs`, `r11u25repro/grid/p13_member_lhs_fill0`;
* r11u166: `r10uvm60repro/b7_multiline`, `r11u8repro/{b5,b8,gA,gB}` and `r11v11u8repro/{v1,v2,v4,v5,v8,v10,v11,v12,v13}`
  (r11u166 measured these 14 at d48f8f8a);
* litall: `r10earl42repro/v42_overfire`, `r10earl43repro/v43_h1_order`, `r10earl54repro/v10step1`,
  `r10earl_repro/a`, `mm`.

**Attribution** (evidence/sweeps/decodes_attribution.txt): each moved row re-run with `R11U161_OFF=1` (r11u166 alone)
and with `R11U166_OFF=1` (r11u161 alone), bytes compared with both sweeps.
* **r11u161 alone** reproduces:
  * GenIfIfaceParamStructField (the conversion), ComplexHierPath `col(7) -> depth(1)`, GenForStructParamBound
    `fullname(7) -> fullname(3)`;
  * byte-only moves: OneNetModPort d/t (`file(3)` unchanged), and the CMP_EQUAL rows genvar_iface_struct and
    iface_array_modport_drive d/t (stay CMP_EQUAL, downstream IDENTICAL).
* **r11u166 alone** reproduces YosysMarlann, ibex_load_store_unit, ibex_pmp, ApbSlave `line(26) -> depth(1)`, CovMacro
  `endcol(118) -> fullname(8)`, Scr1SvTests `line(219) -> file(143)`, YosysOldOr `line(75) -> line(1)`, YosysRiscv
  `endcol(86) -> col(40)`, and the UVM rows (MiniAmiq/SeqDriver `-> file(46)`, SimpleUVM/Scoreboard
  `-> fullname(62)`).
* **Both together** move Earlgrey_0_1 (`line(1730) -> fullname(520)`; r11u166 alone `fullname(564)`, r11u161 alone
  `line(1686)`) and Rggen (bytes only, `fullname(7)` unchanged).

The byte movers against the pristine sweep (fence-clean mirrors; evidence/sweeps/byteverify_decodes_vs_pristine.txt)
are surelog 30 / 952 and uhdm2rtlil 8 / 1608, exactly the rows above.

**The two new structural first fields are unmaskings, not new divergences**:
* ComplexHierPath d/t `depth(1)` is the walk divergence at record #190, where ours lists the generate-scope
  `logic_net z` (and its typespec) and golden has the cont_assign (N0830). It is in the pristine walk too (202 vs 205
  objects both); the decode cleared the col/fullname faces before it;
* ApbSlave d/t `depth(1)` is the pre-existing svunit_pkg divergence at #372 (ours lists `string_var svunit_version`
  as a reference's actual; N0289), 3678 vs 3682 objects in both.

### 3b. A FILE-axis move AWAY from golden in the r11u166 decode (for pair B)

Record-level analysis of the decode cross-section (not visible in the strict counts) finds **120 to 240 objects per UVM
row whose FILE moved away from golden**:

| row (default) | objects whose file became wrong | file facets fixed | net file facets |
|---|---|---|---|
| MiniAmiq | 201 | 85 | +116 |
| SeqDriver | 241 | 100 | +141 |
| SimpleUVM | 161 | 70 | +91 |
| Scoreboard | 121 | 55 | +66 |

Every one is a `method_func_call` (plus one constant) inside a macro argument. Example: `get_full_name()` in the
`$sformatf` argument of `uvm_report_info`, record chain `sys_func_call($sformatf) < operation <
func_call(uvm_report_info) < if_stmt`.
* golden: `uvm_message_defines.svh 116:13-116:26`;
* pristine: `uvm_message_defines.svh 115:89-1346:16` (file right, span wrong);
* decodes: `uvm_phase.svh 115:89-1346:16` (file wrong now, span still wrong).

With `R11U166_FILE_OFF=1` on the same binary, SimpleUVM's file facets return to pristine's 2753 (0 away) while the
span gains stay (14611 span objects pristine, 4936 with the law, 5097 with FILE off). **The mover is law
ppOutputFile166**: it files a span whose start lies in a macro body and whose end lies at the call site by the call
site's record. Pair B should gate it on a start and end in the same buffer, or read the start's buffer, before landing
r11u166. No corpus row changes status because of it. The UVM rows are already NE, and the order-blind distance still
falls (section 8). The class exists in the corpus only on the UVM rows.

### 3c. The yield, and the fail list after the decodes and pair B (evidence/report.txt sections 1-2)

| | row-modes cleared | tests cleared (every NE mode) | probe cases cleared |
|---|---|---|---|
| pair A r11u163, LANDED as pass 163 (already in the base) | 16 | 8 | 50 |
| the decodes r11u161 + r11u166, MEASURED | 6 | 3 | 23 |
| pair B r11u164's other items, optimistic, on top | 5 (GenerateUnnamed d/t, HighLow d/t, HierPathTypespec t) | 3 | 77 |
| **the decodes + pair B** | **11** | **6** | **100** |

### T5. Fail-list size

| corpus | mode | f2f2d30b | after the decodes (measured) | after the decodes + pair B (optimistic) |
|---|---|---|---|---|
| surelog | default | 43 | 41 | 39 |
| surelog | testflags | 40 | 38 | 35 |
| uhdm2rtlil | default | 34 | 33 | 33 |
| uhdm2rtlil | testflags | 34 | 33 | 33 |
| **all** | | **151 / 79 tests** | **145 / 76 tests** | **140 / 73 tests** |
| probe cases | | 1490 | 1467 | 1390 |

First fields after the decodes (the decode sweep's csvs):
* surelog 79: fullname 37, file 11, line 7, endcol 6, endline 5, depth 4, value 4, name 2, col 2, type 1;
* uhdm2rtlil 66: fullname 30, file 14, line 12, endcol 4, name 4, col 2;
* probe 1467: fullname 599, line 225, endcol 217, file 116, type 101, depth 92, name 58, col 39, endline 13,
  decompile 4, value 3.

## 4. Ranked OPEN clusters with sites (on top of the decodes measured + pair B optimistic)

Columns:
* `rows left` counts the row-modes the cluster still carries after the decodes and pair B; its rows at f2f2d30b are in
  parentheses.
* `heads` counts the rows it is FIRST on (after the decodes).
* `alone` counts the rows it clears alone on top of both.
* `probe` counts its probe cases after the decodes.

The whole list is cluster_index.csv (columns `rows_after_law`, `rows_after_pairs`, `alone_on_top_of_pairs`,
`first_in_after_pairs`, `alone_on_pristine`, `coverage`, `ground`, `site`).

**467 OPEN clusters still carry a row** (ground A 313, B 148, unpinned 6). The list by rows is dominated by the UVM
family (9 row-modes, 5 tests), so it is given twice: T1 by all rows, and T1b over the rows outside the big families
(UVM, Earlgrey_0_1, Rggen, BlackBePipeInt, Scr1SvTests, ApbSlave), which is what the next briefs convert.

### T1. Ranked OPEN clusters, all rows (top 40 of 467)

| # | cluster | rows left (f2f2d30b) | sl/u2r | tests | families | heads | alone | probe (after dec) | ground | status | key | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0025 | 17 (17) | 5/12 | 9 | UVM rp32 | 0 | 0 | 11 | B | OPEN (map 7 ground-B step 3) | `depth\|constant\|range->operation` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect)  |
| 2 | N0033 | 17 (17) | 5/12 | 9 | UVM rp32 | 0 | 0 | 11 | B | OPEN (map 7 ground-B step 3) | `struct\|ours-only:fewer-copies\|operation\|under:range` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCallScopeDecl1 |
| 3 | N0031 | 15 (15) | 9/6 | 8 | UVM | 0 | 0 | 13 | B | OPEN | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp,  |
| 4 | N0043 | 14 (14) | 10/4 | 8 | UVM | 2 | 0 | 5 | B | OPEN (residue: pass 155 R-SP / pass 163 residue 3: the defin | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWholeLhsB |
| 5 | N0001 | 14 (24) | 22/2 | 13 | Earlgrey Rggen UVM | 0 | 0 | 8 | A | OPEN (map 7 ground-A step 3) [the decodes reduce it: rows 24 | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) <  |
| 6 | N0072 | 13 (13) | 13/0 | 7 | UVM | 0 | 2 | 16 | B | OPEN (one shape named by r11u164: ClassTypeParam) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNo |
| 7 | N0012 | 13 (13) | 9/4 | 7 | UVM | 4 | 0 | 5 | A | OPEN | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorro |
| 8 | N0080 | 13 (13) | 13/0 | 7 | UVM | 2 | 0 | 1 | B | OPEN | `span\|struct_typespec\|line+col+endline+endcol\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInline |
| 9 | N0067 | 13 (13) | 13/0 | 7 | ApbSlave UVM | 0 | 0 | 47 | B | OPEN (one shape named by r11u164: ApbSlave) | `file\|class_typespec\|ours-empty\|under:ref_typespec` | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPro |
| 10 | N0068 | 13 (13) | 13/0 | 7 | ApbSlave UVM | 0 | 0 | 47 | B | OPEN (one shape named by r11u164: ApbSlave) | `span\|class_typespec\|ours-zero\|under:ref_typespec` | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPro |
| 11 | N0042 | 13 (13) | 9/4 | 7 | UVM | 0 | 0 | 10 | B | OPEN | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp,  |
| 12 | N0007 | 13 (24) | 22/2 | 13 | Earlgrey Rggen UVM | 0 | 0 | 6 | A | OPEN (map 7 ground-A step 3) [the decodes reduce it: rows 24 | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < em |
| 13 | N0034 | 13 (13) | 9/4 | 7 | UVM | 0 | 0 | 5 | A | OPEN | `span\|enum_typespec\|ours-zero\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChainBorro |
| 14 | N0036 | 12 (14) | 12/2 | 8 | UVM ibex | 2 | 2 | 6 | A | OPEN (residue: r11u166 R1: the spaced based literal (YosysRi | `span\|bit_select\|col+endcol\|under:operation` | emitExpr (ExprEmit.cpp, law ifaceMemberTrailIdxNamesByPath147) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 15 | N0092 | 12 (12) | 2/10 | 6 | rp32 | 2 | 2 | 0 | B | OPEN (one shape named by r11u164: UnionCast) [residue: pass  | `value\|constant\|value:UINT->UINT\|under:range` | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabS |
| 16 | N0086 | 12 (12) | 4/8 | 6 | - | 2 | 0 | 20 | A | OPEN | `file\|constant\|golden-empty\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgSt |
| 17 | N0039 | 12 (12) | 12/0 | 7 | ApbSlave Rggen UVM | 0 | 0 | 219 | B | OPEN (one shape named by r11u164: ApbSlave) | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRa |
| 18 | N0087 | 12 (12) | 4/8 | 6 | - | 0 | 0 | 20 | A | OPEN | `span\|constant\|golden-zero\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, law pkgSt |
| 19 | N0061 | 12 (12) | 12/0 | 7 | Earlgrey Rggen UVM | 0 | 0 | 8 | A | OPEN | `span\|bit_select\|col+endcol\|under:hier_path` | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectEras |
| 20 | N0142 | 12 (12) | 12/0 | 7 | Earlgrey Rggen UVM | 0 | 0 | 0 | A | OPEN | `struct\|golden-only:fewer-copies\|range\|under:array_typespec` | makeUnpackedArrayParamTs (ParamEmit.cpp, law pkgParamTsRef) < emitParameters (ParamEmit.cpp, law importElemBar |
| 21 | N0056 | 11 (11) | 9/2 | 6 | UVM | 2 | 2 | 1 | B | OPEN (residue: map 7: pass-145 R2 (sister), PreprocTest enum | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 22 | N0095 | 11 (11) | 11/0 | 6 | UVM | 2 | 0 | 15 | A | OPEN | `fullname\|ref_obj\|tok:id.id::->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < em |
| 23 | N0103 | 11 (11) | 11/0 | 6 | UVM | 2 | 0 | 7 | B | OPEN (map 7 gave it to r11u152; pass 152 left it) | `name\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNo |
| 24 | N0094 | 11 (11) | 11/0 | 6 | UVM | 0 | 0 | 58 | B | OPEN | `span\|constant\|line+col+endline+endcol\|under:range` | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBoundElabS |
| 25 | N0097 | 11 (11) | 11/0 | 6 | UVM | 0 | 0 | 12 | A | OPEN (map 7 ground-A step 6) | `span\|hier_path\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) <  |
| 26 | N0111 | 11 (11) | 11/0 | 6 | ApbSlave UVM | 0 | 0 | 4 | A | OPEN | `span\|constant\|line+col+endline+endcol\|under:io_decl` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitTaskFuncs (TaskFuncEmit.cpp, law classArgBind12) < emitClass |
| 27 | N0119 | 11 (11) | 11/0 | 6 | UVM | 0 | 0 | 1 | A | OPEN | `span\|bit_select\|col+endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) < |
| 28 | N0118 | 11 (11) | 11/0 | 6 | BlackBePipeInt UVM | 0 | 0 | 0 | A | OPEN [the decodes reduce it: rows 11->11, probe 1->0] | `span\|constant\|line+col+endline+endcol\|under:operation` | emitBadConcatOperand160 (ExprEmit.cpp, law typeParamScopedCallRef59) < emitBadConcatFromSyntax160 (ExprEmit.cp |
| 29 | N0129 | 10 (10) | 4/6 | 5 | Earlgrey ibex | 1 | 1 | 33 | B | OPEN (one shape named by r11u164: the rest of the ibex famil | `fullname\|ref_typespec\|tok:->.id\|under:constant` | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < |
| 30 | N0149 | 10 (10) | 2/8 | 5 | Earlgrey rp32 | 8 | 0 | 0 | B | OPEN (map 7 gave it to r11u152; pass 152 left it) | `file\|struct_typespec\|other-file\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) < exportDesi |
| 31 | N0127 | 10 (10) | 10/0 | 6 | Rggen UVM | 0 | 0 | 79 | B | OPEN | `span\|array_typespec\|endcol\|under:ref_typespec` | makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDimOvrChain4) < emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPo |
| 32 | N0128 | 10 (10) | 10/0 | 6 | Rggen UVM | 0 | 0 | 69 | B | OPEN | `span\|range\|col+endcol\|under:array_typespec` | operator() (ModuleEmit.cpp, law sizeDimOvrChain4) < makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDimOvrChain4 |
| 33 | N0131 | 10 (10) | 10/0 | 5 | Earlgrey UVM | 0 | 0 | 17 | A | OPEN | `fullname\|ref_typespec\|ours-empty\|under:constant` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law negLitPkgRetFoldNested3 |
| 34 | N0140 | 10 (10) | 2/8 | 5 | Earlgrey rp32 | 0 | 0 | 0 | B | OPEN (map 7 gave it to r11u152; pass 152 left it) | `file\|struct_typespec\|other-file\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) < exportDesi |
| 35 | N0141 | 10 (10) | 10/0 | 6 | Earlgrey Rggen UVM | 0 | 0 | 0 | B | OPEN | `file\|logic_typespec\|other-file+span\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitTaskFuncs (TaskFuncEmit.cpp, law modTdRetCloneSym |
| 36 | N0143 | 10 (10) | 2/8 | 5 | Earlgrey rp32 | 0 | 0 | 0 | B | OPEN (map 7 gave it to r11u152; pass 152 left it) | `file\|struct_typespec\|other-file\|under:module_inst` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) < exportDesi |
| 37 | N0078 | 9 (9) | 7/2 | 5 | Rggen Scr1 UVM ibex | 2 | 2 | 0 | B | OPEN (one shape named by r11u164: the rest of the ibex famil | `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law structParamPathB |
| 38 | N0040 | 9 (11) | 9/2 | 6 | Earlgrey Rggen Scr1 | 2 | 0 | 34 | B | OPEN [the decodes reduce it: rows 11->9, probe 34->34] | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 39 | N0210 | 9 (9) | 9/0 | 5 | Scr1 UVM | 2 | 0 | 0 | B | OPEN | `file\|typespec_member\|other-file\|under:struct_typespec` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < exportDesign (UhdmExporter.cpp, law unitIm |
| 40 | N0152 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 71 | A | OPEN | `file\|begin\|ours-empty\|under:function` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetim |

### T1b. Ranked OPEN clusters on the rows outside the big families (top 40)

| # | cluster | rows outside the big families (all rows) | heads there | alone | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|
| 1 | N0086 | 12 (12) | 2 | 0 | A | OPEN | `file\|constant\|golden-empty\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, |
| 2 | N0092 | 12 (12) | 2 | 2 | B | OPEN (one shape named by r11u164: UnionCast) [residue: pass 160 S: Uni | `value\|constant\|value:UINT->UINT\|under:range` | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkg |
| 3 | N0025 | 12 (17) | 0 | 0 | B | OPEN (map 7 ground-B step 3) | `depth\|constant\|range->operation` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbol |
| 4 | N0033 | 12 (17) | 0 | 0 | B | OPEN (map 7 ground-B step 3) | `struct\|ours-only:fewer-copies\|operation\|under:range` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCall |
| 5 | N0087 | 12 (12) | 0 | 0 | A | OPEN | `span\|constant\|golden-zero\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, |
| 6 | N0149 | 8 (10) | 8 | 0 | B | OPEN (map 7 gave it to r11u152; pass 152 left it) | `file\|struct_typespec\|other-file\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) <  |
| 7 | N0084 | 8 (8) | 6 | 0 | A | OPEN (residue: pass 155 R-SP: a value parameter struct copy names its  | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law |
| 8 | N0129 | 8 (10) | 1 | 1 | B | OPEN (one shape named by r11u164: the rest of the ibex family) [residu | `fullname\|ref_typespec\|tok:->.id\|under:constant` | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldN |
| 9 | N0009 | 8 (8) | 0 | 0 | A | OPEN (residue: pass 155 R-SP: the struct copy span after the formal re | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpClon |
| 10 | N0140 | 8 (10) | 0 | 0 | B | OPEN (map 7 gave it to r11u152; pass 152 left it) | `file\|struct_typespec\|other-file\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) <  |
| 11 | N0143 | 8 (10) | 0 | 0 | B | OPEN (map 7 gave it to r11u152; pass 152 left it) | `file\|struct_typespec\|other-file\|under:module_inst` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law a7) <  |
| 12 | N0267 | 8 (8) | 0 | 0 | A | OPEN | `fullname\|ref_typespec\|tok:id@id.id.id::id.id->id\|under:constant` | stampEvalFuncLeftovers (ParamEmit.cpp, law memLeftFormalReadTs18) < exportDesign (UhdmExporter.cpp,  |
| 13 | N0268 | 8 (8) | 0 | 0 | B | OPEN | `struct\|ours-only:fewer-copies\|logic_var\|under:io_decl` | makeVar (TypeEmit.cpp, law pkgScopedPortAnyDirVar77) < emitInterfaceInstance (ModuleEmit.cpp, law de |
| 14 | N0003 | 6 (8) | 4 | 0 | A | OPEN (residue: pass 163 R2: the elaborated package listing of an UNPAC | `fullname\|ref_typespec\|golden-empty\|under:operation` | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitInterfaceInstance (ModuleEmit.cp |
| 15 | N0407 | 6 (6) | 4 | 0 | A | OPEN | `span\|constant\|line+col+endline+endcol\|under:typespec_member` | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) < emitParameters (ParamEmit.cpp, |
| 16 | N0090 | 6 (8) | 2 | 0 | B | OPEN (map 7 ground-B step 11) | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEm |
| 17 | N0418 | 6 (6) | 2 | 0 | B | OPEN | `file\|ref_obj\|golden-empty\|under:port` | emitPorts (ModuleEmit.cpp, law caIfacePortDeclNetMint93) < emitModuleDefPorts (ModuleEmit.cpp, law c |
| 18 | N0005 | 6 (8) | 0 | 0 | A | OPEN (map 7 ground-A step 1) | `span\|constant\|endcol\|under:param_assign` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emit |
| 19 | N0031 | 6 (15) | 0 | 0 | B | OPEN | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExpo |
| 20 | N0083 | 6 (6) | 0 | 0 | B | OPEN (map 7 ground-B step 10) | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typePara |
| 21 | N0406 | 6 (6) | 0 | 0 | A | OPEN | `fullname\|ref_typespec\|tok:::id.id->\|under:constant` | stampEvalFuncLeftovers (ParamEmit.cpp, law memLeftFormalReadTs18) < exportDesign (UhdmExporter.cpp,  |
| 22 | N0411 | 6 (6) | 0 | 0 | B | OPEN | `struct\|golden-only:absent\|constant\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law  |
| 23 | N0419 | 6 (6) | 0 | 0 | B | OPEN | `span\|ref_obj\|golden-zero\|under:port` | emitPorts (ModuleEmit.cpp, law caIfacePortDeclNetMint93) < emitModuleDefPorts (ModuleEmit.cpp, law c |
| 24 | N0043 | 5 (14) | 2 | 0 | B | OPEN (residue: pass 155 R-SP / pass 163 residue 3: the definition list | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpClon |
| 25 | N0012 | 4 (13) | 4 | 0 | A | OPEN | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParam |
| 26 | N0047 | 4 (5) | 4 | 0 | B | OPEN (one shape named by r11u164: pass 158 S6 iface_param_port_width) | `fullname\|parameter\|tok:id->id.id.id\|under:param_assign` | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < emitInterfaceInstance (ModuleEmit. |
| 27 | N0536 | 4 (4) | 4 | 0 | A | OPEN (map 7: residue of pass 147; still present) | `fullname\|ref_typespec\|tok:id.id->id\|under:constant` | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitContAssigns (ModuleEmit.cpp, law elabCaTerna |
| 28 | N0627 | 4 (4) | 4 | 0 | B | OPEN | `fullname\|property_decl\|tok:id.id.id->id\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDesign (UhdmExporter.cpp, law im |
| 29 | N0014 | 4 (6) | 2 | 0 | B | OPEN (residue: pass 154 R3: a package struct typedef reached through t | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law |
| 30 | N0040 | 4 (9) | 2 | 0 | B | OPEN [the decodes reduce it: rows 11->9, probe 34->34] | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law |
| 31 | N0049 | 4 (6) | 2 | 0 | B | OPEN (one shape named by r11u164: the rest of the ibex family) [residu | `span\|sys_func_call\|endcol\|under:operation` | emitSyntaxExpr (TypeEmit.cpp, law syntaxMultiConcat) < emitSyntaxExpr (TypeEmit.cpp, law structParam |
| 32 | N0056 | 4 (11) | 2 | 2 | B | OPEN (residue: map 7: pass-145 R2 (sister), PreprocTest enum base bit_ | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (Uhd |
| 33 | N0007 | 4 (13) | 0 | 0 | A | OPEN (map 7 ground-A step 3) [the decodes reduce it: rows 24->13, prob | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFo |
| 34 | N0034 | 4 (13) | 0 | 0 | A | OPEN | `span\|enum_typespec\|ours-zero\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParam |
| 35 | N0042 | 4 (13) | 0 | 0 | B | OPEN | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExpo |
| 36 | N0048 | 4 (5) | 0 | 0 | A | OPEN | `fullname\|ref_typespec\|tok:id->id.id.id\|under:parameter` | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitInterfaceInstance (ModuleEmit.cpp, law i |
| 37 | N0072 | 4 (13) | 0 | 2 | B | OPEN (one shape named by r11u164: ClassTypeParam) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneD |
| 38 | N0080 | 4 (13) | 0 | 0 | B | OPEN | `span\|struct_typespec\|line+col+endline+endcol\|under:package` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRng |
| 39 | N0131 | 4 (10) | 0 | 0 | A | OPEN | `fullname\|ref_typespec\|ours-empty\|under:constant` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law negLitPkgRetF |
| 40 | N0133 | 4 (4) | 0 | 0 | B | OPEN (map 7: residue of pass 147; still present) | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law unnam |

Probe-only OPEN clusters with the most cases after the decodes: N1897 (119, B), N1898 (92, B), N1899 (52, B),
N1900 (50, B), N0044 (46, B), N1901 (45, B), N1902 (37, A), N0739 (27, A), N1903 (21, A), N1904 (20, A),
N1905 (17, B), N1907 (15, B). Laws with the most NE cases:
* badConcatOperandsFromSyntax160 71/71;
* loopCaParamReadKeepsLiteral116 59/123;
* portViewRangeRecvParams 41/55;
* pvExprDefaultFold115 41/50;
* caNestedModPortedDefShell101 36/38;
* srlgCondOpInstValueTernFold9 32/140;
* nestedParamActualTs6 29/41;
* tpPackedArrayTsVar108 29/73;
* spVoidCastValue109 27/27;
* caIfacePortDeclNetMint93 27/35.

### T4. First clusters of the rows left (row-modes each heads, after the decodes + pair B)

| first cluster | row-modes it heads | ground | status (short) | rows |
|---|---|---|---|---|
| N0149 | 8 | B | OPEN (map 7 gave it to r11u152; pass 152 left it) | rp32_r5p_{alu,bru,mdu,wbu} d/t: `file(46)`, a package struct typespec filed at another file |
| N0084 | 6 | A | OPEN (pass 155 R-SP) | StructParamFieldRange, StructParamFuncBodyFieldCompare d/t, cva6_struct_param_field d/t |
| N0163 | 5 | B | OPEN (map 7 gave it to r11u152) | Earlgrey_0_1 d/t, Rggen d, PackedArrayHighConn d/t |
| N0536 | 4 | A | OPEN (map 7: pass-147 residue) | ParameterFromPkgInNestedModule, ParameterFromPkgOnParameterPortList d/t |
| N0407 | 4 | A | OPEN | param_nested_struct_field_width, struct_param_func_config d/t |
| N0144 | 4 | B | COVERED r11u164 (UVM/Earlgrey-only) | the UVM rows |
| N0003 | 4 | A | OPEN (pass 163 R2) | iface_zero_width_field d/t, StructParamPatternInitCast d/t |
| N0047 | 4 | B | OPEN (one shape named: pass 158 S6) | iface_param_port_width d/t, interface_array d/t |
| N0012 | 4 | A | OPEN | TypeParameterAsPortTypeWithEnum(+OfParametrizedWidth) d/t |
| N0627 | 4 | B | OPEN | AssertDelayError, AssertTempError d/t |
| N0682 | 3 | A | OPEN | Scoreboard d, SimpleUVM d/t (a package parameter's `::` reference name) |

The full list is evidence/report.txt section 5, and every row's first cluster and site are in fail_list.csv.

### The pair-B covered clusters

evidence/report.txt section 6 lists the 267 optimistic clusters and the 138 the decodes clear (measured), with rows
before and after. The measured ones with the most rows are:
* N0091 (17 row-modes, `span|ref_obj|col+endcol|under:operation`);
* N0287 (13);
* N0125 (11);
* the ibex macro-line tail N0015/N0026/N0027;
* the UVM include/macro spans N0296-N0405.

**N0064** (the include_file_info line model) falls 14 -> 1 row-modes. The last is YosysOldOpen d, an `include` after
a macro-only include.

## 5. Structural rows and downstream-visible faces

### 5a. Structural rows (first field depth / type / count)

| row | f2f2d30b | after the decodes | first cluster | what it needs |
|---|---|---|---|---|
| YosysBigSimEllip d | `type(1)` | `type(1)` | N0284 | pass 163 S7: at #70374 golden has the Lhs `part_select C` of `assign C[195:194] = 0;` where ours has the Rhs constant; ours lists 8 fewer objects. A cont_assign is missing or reordered in ModuleEmit's elaborated listing; not decoded; no landed or unlanded law covers it |
| ComplexHierPath d/t | `col(7)` | `depth(1)` | N0830 | unmasked by law defGenPathSel161 (r11u161). The pre-existing #190 divergence: ours lists the gen-scope `logic_net z` under the cont_assign (N0830 `struct|ours-only:fewer-copies|logic_net|under:cont_assign`, ModuleEmit). Map 7 gave N0830 to r11u152; pass 152 did not take it |
| ApbSlave d/t | `line(26)` | `depth(1)` | N0289 | unmasked by the r11u166 model: the pre-existing svunit_pkg #372 divergence. Ours binds a reference `svunit_version` to the package `string_var` and lists it (N0289 `struct|ours-only:fewer-copies|string_var|under:ref_obj`, TypeEmit makeVar < ParamEmit emitPackageVar); not decoded |

The probe set holds 101 `type` and 92 `depth` first fields, 0 of which the decodes move.

### 5b. Downstream-visible faces (drivers/dsfaces.py: the gate's own `one()`, fresh GOLDEN_CACHE, both binaries)

The rows below were measured on the evidence cases the passes left (evidence/sweeps/dsfaces_*.csv). No corpus row
changes verdict under either binary (section 2 and 3a).

| face | cases | pristine f2f2d30b | the decodes | what it needs |
|---|---|---|---|---|
| r11u159 R1: the non-package enum alias width (the plugin reads a module / `$unit` alias-typed packed array 32 or 64 bits wide) | r11u161gen/cases/al e01-e18 | **11 DIVERGENT** (e02 e04 e05 e07 e09 e10 e11 e12 e16 e17 e18), 7 IDENTICAL | **those 11 IDENTICAL**; e15 (the packed-dim control) DIVERGENT on both | law enumAliasClone161 (r11u161, pair B's first item) |
| r11u162 N2: the macro-expanded interface-member connection (`.clk(\`CK)`: no HighConn, `\clk` unconnected) | r11u166mac/cases/ds c05, c08 | EQUIVALENT (nohier il synth) | **IDENTICAL** | law macroConnInRange166 (r11u166 law_macroconn.patch, ModuleEmit emitInstance) |
| r11u162 N1: blanks inside a dotted path (`bs . wdtxx [3:0]`) | ds l06, p04 | STATUS_DIFF (slang lane READ_FAIL) | STATUS_DIFF | ExprEmit's text-splitting path builders (r11u166 R3, pair A). Surelog's own lane reads NO_GATES, so even a full fix meets STATUS_DIFF unless ours also yields no gates |
| pass 158's size cast as a whole continuous-assign value | r11u158repro/cases/sc c1-c17 | 15 IDENTICAL; c10 EQUIVALENT (nohier il), c12 EQUIVALENT (nohier) | same | c10 = pass 158 S2 (a gen-if `3'(-1)`: golden folds to UINT:7, ModuleEmit emitBlock's gen-CA branch); c12 = S3 (an instance-overridden width `W'(7)`: the fold reads the definition's width, ModuleEmit emitContAssigns). Pair B's brief names "the generate-scope cast fold" (c10) |
| pass 160: the LogicTypespec Surelog-defect candidate | r11u160repro/evidence/residue/LT l01, l02 | l01 IDENTICAL; **l02 DIVERGENT** (`$bits(x)` reads 2 on the Surelog lane, 32 on ours) | same | Golden binds `my_package::t2 [1:0][7:0] x` to the package typedef and drops the written dims. Following it changes a netlist toward a Surelog defect: a user decision, not a law |
| r11u159 R2: the delay on the first assignment only (`assign #d b = a, c = ~a`) | r11u159verify/cases/dv d01-d04 | 4 IDENTICAL | same | not downstream-visible (the walk diverges on the strict axis only); ModuleEmit emitContAssigns, pass 158 S4 |

## 6. The per-ground briefs (on top of the decodes measured + pair B optimistic)

The base is 11 row-modes / 6 tests cleared (the decodes 6 + pair B 5). **The remaining 140 row-modes carry:**
* by open-cluster count: 1 open cluster 19, 2: 26, 3: 16, 4: 18, 5: 14, 6 or more: 47;
* by ground: A only 16, B only 45, both 66, with an unpinned or new-under-the-law key 13 (the UVM rows).

Every OPEN cluster of ground A clears 16 row-modes alone (27 with the pairs); every OPEN cluster of ground B clears 45
(56). **Most rows need both grounds**, so the joint list (A+B) is the one that plans two refills. A candidate is the
whole open-cluster set of one remaining row (<= 4 clusters one ground, <= 6 joint), and the greedy picks by row-modes
cleared per cluster added (drivers/report8.py section 8; evidence/report.txt).

**Ground A: expression/parameter (ExprEmit/EmitHelpers/StmtEmit/ParamEmit). The next pair-A refill.**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0009 + N0084 + N0759 | 6 | 17 | 9 | StructParamFieldRange/d StructParamFuncBodyFieldCompare/d StructParamFieldRange/t StructParamFuncBodyFieldCompare/t cva6_struct_param_field/d/u2r cva6_struct_param_field/t/u2r | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWhol |
| 2 | N0036 | 2 | 19 | 10 | YosysRiscv/d YosysRiscv/t | emitExpr (ExprEmit.cpp, law ifaceMemberTrailIdxNamesByPath147) < emitExpr (ExprEmit.cpp, law incDecMember |
| 3 | N0977 | 2 | 21 | 11 | CovMacro/d CovMacro/t | buildDottedHierPath (ExprEmit.cpp, law hpIdxClassBodyNeverLateBinds143) < emitExpr (ExprEmit.cpp, law imp |
| 4 | N0471 + N0943 | 2 | 23 | 12 | ibex_pmp/d/u2r ibex_pmp/t/u2r | emitExpr (ExprEmit.cpp, law loopCaParamReadKeepsLiteral116) < emitExpr (ExprEmit.cpp, law incDecMemberPat |
| 5 | N0278 | 1 | 24 | 13 | LocalScopeHierPath/t | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxAt |
| 6 | N0427 | 1 | 25 | 14 | InterfArrayBind/d | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp, law genCaParamFoldOneHopPool95) < emitGenScopes (Mo |
ground A: the 9 clusters above clear 14 row-modes on top of the pairs (25 with them)

**Ground B: module/type (TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main). On top of r11u164, or its refill.**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0072 | 2 | 13 | 7 | ClassTypeParam/d ClassTypeParam/t | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRa |
| 2 | N0092 | 2 | 15 | 8 | UnionCast/d UnionCast/t | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBound |
| 3 | N0056 | 2 | 17 | 9 | PreprocTest/d PreprocTest/t | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExpo |
| 4 | N0078 | 2 | 19 | 10 | ibex_register_file_ff/d/u2r ibex_register_file_ff/t/u2r | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law structParam |
| 5 | N0830 | 2 | 21 | 11 | ComplexHierPath/d ComplexHierPath/t | operator() (ModuleEmit.cpp, law readerWidthIsTheSecondAdjust104) < operator() (ModuleEmit.cpp, law elseAr |
| 6 | N0661 | 2 | 23 | 12 | YosysOldOr/d YosysOldOr/t | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec (TypeEmit.cpp, law typeParamDefau |
| 7 | N0094 + N1058 | 2 | 25 | 13 | GenForStructParamBound/d GenForStructParamBound/t | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBound |
| 8 | N0064 + N0129 | 2 | 27 | 14 | YosysOldOpen/d YosysOldOpen/t | emitIncludeFileInfos (UhdmExporter.cpp, law includeInactiveTabNotText141v) < exportDesign (UhdmExporter.c |
| 9 | N0525 + N0562 | 2 | 29 | 15 | StructArrayNet/d StructArrayNet/t | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpIdxOpOperandFold1 |
| 10 | N0163 + N1115 | 2 | 31 | 16 | PackedArrayHighConn/d PackedArrayHighConn/t | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp, law enumAliasEndAtDimOrI |
| 11 | N0804 + N0805 | 2 | 33 | 17 | mem_read_reg/d/u2r mem_read_reg/t/u2r | exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPa |
| 12 | N0043 + N0133 + N0487 | 2 | 35 | 18 | const_cast_signext/d/u2r const_cast_signext/t/u2r | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWhol |
| 13 | N0268 + N0418 + N0419 | 2 | 37 | 19 | OneNetModPort/d OneNetModPort/t | makeVar (TypeEmit.cpp, law pkgScopedPortAnyDirVar77) < emitInterfaceInstance (ModuleEmit.cpp, law defNetE |
| 14 | N0083 + N0422 + N0484 + N1149 | 2 | 39 | 20 | LogicTypespec/d LogicTypespec/t | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChai |
| 15 | N0136 + N0457 + N0775 | 1 | 40 | 21 | UnsizedParam/d | UHDM library DeepClone < DeepClone < elabModule_inst (--elabuhdm, testflags) run from main (uhdm_main.cpp |
ground B: the 29 clusters above clear 29 row-modes on top of the pairs (40 with them)

**Joint (both grounds), the order that converts the most rows per cluster.**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0009 + N0084 + N0759 | 6 | 17 | 9 | StructParamFieldRange/d StructParamFuncBodyFieldCompare/d StructParamFieldRange/t StructParamFuncBodyFieldCompare/t cva6_struct_param_field/d/u2r cva6_struct_param_field/t/u2r | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWhol |
| 2 | N0072 | 2 | 19 | 10 | ClassTypeParam/d ClassTypeParam/t | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRa |
| 3 | N0036 | 2 | 21 | 11 | YosysRiscv/d YosysRiscv/t | emitExpr (ExprEmit.cpp, law ifaceMemberTrailIdxNamesByPath147) < emitExpr (ExprEmit.cpp, law incDecMember |
| 4 | N0092 | 2 | 23 | 12 | UnionCast/d UnionCast/t | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBound |
| 5 | N0056 | 2 | 25 | 13 | PreprocTest/d PreprocTest/t | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExpo |
| 6 | N0078 | 2 | 27 | 14 | ibex_register_file_ff/d/u2r ibex_register_file_ff/t/u2r | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < emitSyntaxExpr (TypeEmit.cpp, law structParam |
| 7 | N0830 | 2 | 29 | 15 | ComplexHierPath/d ComplexHierPath/t | operator() (ModuleEmit.cpp, law readerWidthIsTheSecondAdjust104) < operator() (ModuleEmit.cpp, law elseAr |
| 8 | N0661 | 2 | 31 | 16 | YosysOldOr/d YosysOldOr/t | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec (TypeEmit.cpp, law typeParamDefau |
| 9 | N0977 | 2 | 33 | 17 | CovMacro/d CovMacro/t | buildDottedHierPath (ExprEmit.cpp, law hpIdxClassBodyNeverLateBinds143) < emitExpr (ExprEmit.cpp, law imp |
| 10 | N0025 + N0033 + N0140 + N0143 + N0149 | 6 | 39 | 20 | rp32_r5p_bru/d/u2r rp32_r5p_mdu/d/u2r rp32_r5p_wbu/d/u2r rp32_r5p_bru/t/u2r rp32_r5p_mdu/t/u2r rp32_r5p_wbu/t/u2r | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSel |
| 11 | N0049 + N0545 + N0546 | 4 | 43 | 22 | ibex_multdiv_fast/d/u2r rp32_r5p_alu/d/u2r ibex_multdiv_fast/t/u2r rp32_r5p_alu/t/u2r | emitSyntaxExpr (TypeEmit.cpp, law syntaxMultiConcat) < emitSyntaxExpr (TypeEmit.cpp, law structParamPathB |
| 12 | N0047 + N0048 + N0129 + N0442 + N0475 | 5 | 48 | 24 | YosysOldOpen/t iface_param_port_width/d/u2r interface_array/d/u2r iface_param_port_width/t/u2r interface_array/t/u2r | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < emitInterfaceInstance (ModuleEmit.cpp,  |
| 13 | N0012 + N0034 + N0281 + N0638 | 4 | 52 | 26 | TypeParameterAsPortTypeWithEnum/d/u2r TypeParameterAsPortTypeWithEnumOfParametrizedWidth/d/u2r TypeParameterAsPortTypeWithEnum/t/u2r TypeParameterAsPortTypeWithEnumOfParametrizedWidth/t/u2r | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters (ParamEmit.cpp, law typeParamChain |
| 14 | N0097 + N0103 | 2 | 54 | 27 | ArrayMethodIterator/d ArrayMethodIterator/t | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold6 |
| 15 | N0007 + N0962 | 2 | 56 | 28 | mriscv_bind_sva/d/u2r mriscv_bind_sva/t/u2r | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) |
| 16 | N0003 + N0014 | 2 | 58 | 29 | StructParamPatternInitCast/d StructParamPatternInitCast/t | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitInterfaceInstance (ModuleEmit.cpp, la |
| 17 | N0820 | 2 | 60 | 30 | anon_struct_packed_dim/d/u2r anon_struct_packed_dim/t/u2r | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLval |
| 18 | N0688 | 2 | 62 | 31 | iface_zero_width_field/d/u2r iface_zero_width_field/t/u2r | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tp |
| 19 | N0094 + N1058 | 2 | 64 | 32 | GenForStructParamBound/d GenForStructParamBound/t | makeBoundConst (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypespec (TypeEmit.cpp, law typedPkgBound |
| 20 | N0525 + N0562 | 2 | 66 | 33 | StructArrayNet/d StructArrayNet/t | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law genLpIdxOpOperandFold1 |
| 21 | N0163 + N1115 | 2 | 68 | 34 | PackedArrayHighConn/d PackedArrayHighConn/t | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp, law enumAliasEndAtDimOrI |
| 22 | N0085 + N0738 | 2 | 70 | 35 | func_typename_ret/d/u2r func_typename_ret/t/u2r | makeParamTs (ParamEmit.cpp, law pkgParamOwnDefRange) < drainDefParamTs (ParamEmit.cpp, law paramCloneImpo |
| 23 | N0736 + N0737 | 2 | 72 | 36 | interface_array_fanout/d/u2r interface_array_fanout/t/u2r | emitParameters (ParamEmit.cpp, law unsizedBasedParamRhsSize106) < emitInterfaceInstance (ModuleEmit.cpp,  |
| 24 | N0471 + N0943 | 2 | 74 | 37 | ibex_pmp/d/u2r ibex_pmp/t/u2r | emitExpr (ExprEmit.cpp, law loopCaParamReadKeepsLiteral116) < emitExpr (ExprEmit.cpp, law incDecMemberPat |
| 25 | N0804 + N0805 | 2 | 76 | 38 | mem_read_reg/d/u2r mem_read_reg/t/u2r | exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPa |
| 26 | N0278 | 1 | 77 | 39 | LocalScopeHierPath/t | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxAt |
| 27 | N0427 | 1 | 78 | 40 | InterfArrayBind/d | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp, law genCaParamFoldOneHopPool95) < emitGenScopes (Mo |
| 28 | N0064 | 1 | 79 | 41 | YosysOldOpen/d | emitIncludeFileInfos (UhdmExporter.cpp, law includeInactiveTabNotText141v) < exportDesign (UhdmExporter.c |
| 29 | N0040 + N0268 + N0418 + N0419 + N0526 | 4 | 83 | 43 | InterfaceModPort/d OneNetModPort/d InterfaceModPort/t OneNetModPort/t | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobC |
| 30 | N0299 + N0431 + N0627 + N0628 + N1047 | 4 | 87 | 45 | AssertDelayError/d AssertTempError/d AssertDelayError/t AssertTempError/t | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law memberActualLeak) < em |
| 31 | N0043 + N0133 + N0487 | 2 | 89 | 46 | const_cast_signext/d/u2r const_cast_signext/t/u2r | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWhol |
| 32 | N0011 + N0016 + N0090 | 2 | 91 | 47 | UnitElabBlock/d UnitElabBlock/t | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExport |
| 33 | N0443 + N0448 + N0684 | 2 | 93 | 48 | arb_idx_cast/d/u2r arb_idx_cast/t/u2r | genLpUseFoldBound47 (ExprEmit.cpp, law genLpUseFoldParentScope47) < emitExpr (ExprEmit.cpp, law genCaSysC |
| 34 | N0022 + N0023 + N0416 | 2 | 95 | 49 | rsp_gen_minimal/d/u2r rsp_gen_minimal/t/u2r | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested |
| 35 | N0039 + N0067 + N0068 + N0111 | 2 | 97 | 50 | ApbSlave/d ApbSlave/t | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneD |
| 36 | N0080 + N0086 + N0087 + N0131 | 2 | 99 | 51 | FuncStructValSimple/d FuncStructValSimple/t | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipI |
| 37 | N0411 + N1083 | 2 | 101 | 52 | pkg_nested_struct_param_width/d/u2r pkg_nested_struct_param_width/t/u2r | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRn |
| 38 | N0005 + N0267 + N0406 + N0745 | 2 | 103 | 53 | struct_param_field_shift/d/u2r struct_param_field_shift/t/u2r | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPacka |
| 39 | N0001 + N0191 + N0853 + N1127 | 2 | 105 | 54 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold6 |
| 40 | N0415 + N0474 + N0549 + N0942 | 2 | 107 | 55 | ibex_icache/d/u2r ibex_icache/t/u2r | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitExpr (ExprEmit.cpp, law genLpUseFoldParentScope47 |
ground A+B: the 97 clusters above clear 96 row-modes on top of the pairs (107 with them)

In short:

* **Expression/parameter ground (the next pair A).**
  1. **R-SP's rest, N0009 + N0084 + N0759 (6 row-modes):** StructParamFieldRange and
     StructParamFuncBodyFieldCompare d/t, cva6_struct_param_field d/t. A value parameter's struct copy names its members
     through the parameter, with the span after the formal relocation. Pass 155 decoded it to ParamEmit
     `makeParamTs`; pass 163 landed only the aggregate-default half. N0759 is StructParamFuncBodyFieldCompare's
     hier_path member name.
  2. **Singles**, each one row's last open face:
     * N0036, YosysRiscv's index span after litall;
     * N0977, CovMacro's `$root.top` hier_path name (r11u166 R6);
     * N0471 + N0943, ibex_pmp;
     * N0278, LocalScopeHierPath t: golden's `--elabuhdm` foreach index has no stored full name, pass 163 R1;
     * N0427, InterfArrayBind d: the default view's interface-array index, pass 154 R1a.
  3. **Joint rows whose ground-A half is small:**
     * N0003 + N0014, StructParamPatternInitCast;
     * N0536, ParameterFromPkg* with N0031/N0042 (B);
     * N0407 / N0745 / N1083, the makeMemLeftConst member-default spans of param_nested_struct_field_width,
       struct_param_func_config, pkg_nested_struct_param_width and struct_param_field_shift;
     * N0012 + N0034, TypeParameterAsPortTypeWithEnum*;
     * N0097, ArrayMethodIterator with N0103 (B);
     * N0415 + N0474 + N0549 + N0942, ibex_icache;
     * N0049, ibex_multdiv_fast's `$signed` span.
  4. **Pass 158/163 residues not yet worked:** r11u157 R2/R3 (mixed paths; N2400/N2401 are R3's new UVM faces), gl/l4,
     ev/e16, hl/h3, R6/R8/R9, and pass 163's rl/q03, hc/g02 (probe/evidence only). The UVM hier_path names
     N0001/N0007/N0018 still carry 14/13/4 row-modes after the decodes. The r11u161 decode takes their def-view shape
     (24 -> 14, 24 -> 13).
* **Module/type ground (r11u164 and its refill).**
  1. **Singles:**
     * N0072, ClassTypeParam's specialization typespec end, if pair B's named row lands its other faces;
     * N0092, UnionCast's value text: pass 160 decoded it to ExprEmit IntegerLiteral, a ground-A site for the
       UnionCast shape, while the rp32 shape is TypeEmit makeBoundConst;
     * N0056, PreprocTest's enum base bit_typespec end (map 7 gave it to r11u152);
     * N0078, ibex_register_file_ff's `DataWidth` bound name;
     * N0661, YosysOldOr's non-ANSI port typespec line (r11u166 R6);
     * N0830, the unmasked ComplexHierPath divergence.
  2. **Pairs:**
     * N0094 + N1058, GenForStructParamBound after r11u161;
     * N0064 + N0129, YosysOldOpen. N0064 is the include after a macro-only include, the one row N0064 keeps after the
       decodes; N0129 is pass 163 S1, ModuleEmit `substNdaParamRefs`;
     * N0525 + N0562, StructArrayNet, pass 163 S2;
     * N0163 + N1115, PackedArrayHighConn, pass 163 S5;
     * N0804 + N0805, mem_read_reg;
     * N0043 + N0133 + N0487, const_cast_signext;
     * OneNetModPort's N0268 + N0418 + N0419;
     * LogicTypespec's four (a Surelog-defect candidate, section 5b);
     * UnsizedParam's N0136 + N0457 + N0775, pass 163 S6.
  3. **The rp32 set:** N0025 + N0033 + N0140 + N0143 + N0149 clear 6 row-modes; with N0049 + N0545 + N0546 they clear
     rp32_r5p_alu too.
* **The decodes are pair B's to land first.** They are measured at 6 row-modes and 23 probe cases with 0 regressions.
  Before landing r11u166, pair B should fix section 3b's FILE move (law ppOutputFile166 on a span whose start lies in a
  macro body and whose end lies at the call site).

## 7. Prediction audit of map 7 (evidence/audit.txt; drivers/audit8.py reads the committed baselines at every landing)

**Since map 7's pass-147 cross-section (291 row-modes), 140 row-modes converted**: pass 152 36, 154 25, 155 20,
158 13, 160 30, 163 16.

| map 7 predicted | row-modes | moved | by | still open |
|---|---|---|---|---|
| pair B r11u152, optimistic (named + routed + C3) | 40 | **36** | pass 152 22, 154 2, 160 8, 163 4 | 4: PreprocTest d/t, ibex_register_file_ff d/t |
| section 6, ground-A list (23 steps) | 64 | **47** | 154 22, 155 8, 158 6, 160 3, 163 8 | 17: GenIfIfaceParamStructField d/t (the r11u161 decode converts it), mriscv_bind_sva d/t, HighLow d/t, ComplexHierPath d/t, PackedArrayHighConn d/t, InterfArrayBind d, iface_zero_width_field d/t, ArrayMethodIterator d/t, YosysOldOpen d/t |
| section 6, ground-B list (24 steps) | 63 | **42** | 152 14, 155 12, 158 6, 160 8, 163 2 | 21: StructParamFieldRange d/t, cva6_struct_param_field d/t, const_cast_signext d/t, GenerateUnnamed d/t, HierPathTypespec t, LogicTypespec d/t, the rp32 set (8), UnionCast d/t |
| not predicted | | **15** | 154 1, 158 1, 160 11, 163 2 | |

**The 15 unpredicted conversions:**
* BasicOh d (pass 154, gen-scope part-select names);
* LocalScopeHierPath d (pass 158, law foreachArrPathVarForm157);
* pass 160's macro-line rows: BlackConst d/t and ibex_compressed_decoder, ibex_decoder, ibex_multdiv_slow and
  ibex_wb_stage d/t. Map 7 had routed only four ibex tests to r11u152 and read the rest as multi-face;
* ComplexParamOverload d (pass 160; its t row was on list A);
* ParamTypespec2 d/t (pass 163).

**Crossings.** 25 predicted row-modes were landed by the other ground's pass:
* list-A rows taken by pair-B passes: GenForIface* x4, genscope_module_ctx_reset d/t and PatternStruct d/t by 155;
  ComplexParamOverload t and MacroArgMismatch d/t by 160;
* list-B rows taken by pair-A passes: EnumVar, SimpleConstraint and MultirangesStartNotFromZero d/t by 158;
  struct_param_pattern_packing d/t by 163;
* r11u152's rows taken by pair-A passes: InterfaceParamOverrideProp d/t by 154; param_array_wildcard and
  type_param_override_elem_sel d/t by 163.

**Clusters.**
* **Map 7's pair B r11u152 covered clusters (55):**
  * 16 gone, 7 lost every row;
  * 10 fell: N0008 27->5, N0015 27->7, N0017 26->6, N0051 15->9, N0071 13->9, N0163 9->5, and more;
  * 22 unchanged: the UVM/Earlgrey set N0064/N0067/N0068/N0069/N0072/N0093, N0056, N0078, N0084, N0092, N0103, the
    rp32 set N0140/N0143/N0149, N0830, N0962 and more.
* **Map 7's section-6 lists (72 clusters):** 29 gone, 10 lost every row, 18 fell, 14 unchanged, 1 grew (N0091 12->17,
  unmasked; the decodes clear it).
* **102 clusters map 7 routed nowhere lost rows.** Most are UVM spans the macro model moved (N0293-N0401, 7->0 each)
  and the UVM method-body spans N0099/N0101/N0102/N0112/N0114/N0115 (11->0).

**Site pins** (map 7's pin of each converted row's first cluster after pass 147, against the landing law's file from
the pass README):

| landing | pin's mint file = the law's file | the law's file is a caller in the pin | pin misses |
|---|---|---|---|
| pass 152 (B) | 26 | 8 | 2 (ibex_alu d/t: joint) |
| pass 154 (A) | 13 | 10 | 2 (mem_ff_partial_rsp: EmitHelpers law, ExprEmit pin) |
| pass 155 (B) | 4 | 12 | 4 (GenForIface*: ModuleEmit law, ExprEmit pin) |
| pass 158 (A) | 4 | 4 | 5 (SimpleConstraint, MultirangesStartNotFromZero, LocalScopeHierPath) |
| pass 160 (B) | 2 | 18 | 10 (ibex_csr/fetch_fifo: ExprEmit pin; gen_scope_numports, packed_array_struct, packed_struct_array_fifo: the UhdmExporter post-pass) |
| pass 163 (A) | 4 | 6 | 6 (FuncIoTypespec: TypeEmit pin; param_array_wildcard, type_param_override_elem_sel: TypeEmit pins of N0472) |
| **all 140** | **53** | **58** | **29** |

What it says:
* **Measured laws are exact.** Every row the decodes convert here is one r11u161/r11u166 measured, and
  r11u166 measured at d48f8f8a exactly the ibex_load_store_unit conversion that reads here.
* **Map 7's optimistic columns were upper bounds, but good ones on this stretch.** 125 of its 167 predicted row-modes
  moved (75%). Map 6's pair lists had moved 26 of 71 and map 7's pair-A list 10 of 25. The difference is that
  passes 152-163 were briefed from map 7's section-6 SETS of clusters per row, not from single clusters.
* **The pin names the fix file in 111 of 140 (79%), but only 53 at the mint.** A pass fixes at the first caller at
  least as often as at the mint. The misses cluster where one law re-decides a whole family from another file:
  * the UhdmExporter post-passes (tpUseBindsDefDefault160, the macro model);
  * ModuleEmit's port-view and connection builders for ExprEmit mints (155);
  * ParamEmit's type-parameter naming for TypeEmit mints (163).

  Map 7's rule stands, and one more is added: **read the first caller outside the mint's file, and check for a
  post-pass (UhdmExporter) that rewrites the field after emission.**

## 8. The family view

| family | row-modes / tests | clusters per row at f2f2d30b | after the decodes (measured) | open per row after the decodes + pair B (optimistic) | distinct clusters: f2f2d30b -> decodes -> + pair B | cleared |
|---|---|---|---|---|---|---|
| UVM (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg) | 9 / 5 | 167-431 | 167-372 | 102-178 | 506 -> 431 -> 210 | 0 |
| Earlgrey_0_1 | 2 / 1 | 112-115 | 88-92 | 60-70 | 128 -> 105 -> 70 | 0 |
| Rggen (default only) | 1 / 1 | 67 | 64 | 64 | 67 -> 64 -> 64 | 0 |
| BlackBePipeInt | 2 / 1 | 28-30 | 28-30 | 28-30 | 30 -> 30 -> 30 | 0 |
| Scr1SvTests | 2 / 1 | 25 | 24 | 24 | 25 -> 24 -> 24 | 0 |
| ApbSlave | 2 / 1 | 33 | 16 | 4 | 33 -> 16 -> 4 | 0 |
| ibex (6 tests) | 12 / 6 | 1-21 | 1-8 (ibex_load_store_unit converts; ibex_pmp 21 -> 8) | 1-6 | 43 -> 24 -> 17 | 2 |
| rp32 (4 tests) | 8 / 4 | 6-7 | 6-7 | 6-7 | 7 -> 7 -> 7 | 0 |

Per ibex test at f2f2d30b: ibex_pmp 21 clusters, ibex_load_store_unit 9 (converts), ibex_tracer 6, ibex_icache 5,
ibex_multdiv_fast 4, ibex_register_file_ff 1.

**The near rows.** At f2f2d30b 12 row-modes in 8 tests are single-cluster: GenerateUnnamed d/t N0969, HighLow d/t
N0528, InterfArrayBind d N0427, PreprocTest d/t N0056, HierPathTypespec t N1174, LocalScopeHierPath t N0278,
YosysOldOpen t N0129, ibex_register_file_ff d/t N0078. After the decodes and pair B, 19 row-modes in 11 tests have one
open cluster:

| row(s) | the open cluster |
|---|---|
| ClassTypeParam d/t | N0072 |
| ComplexHierPath d/t | N0830 |
| CovMacro d/t | N0977 |
| InterfArrayBind d | N0427 |
| PreprocTest d/t | N0056 |
| UnionCast d/t | N0092 |
| YosysOldOr d/t | N0661 |
| YosysRiscv d/t | N0036 |
| LocalScopeHierPath t | N0278 |
| YosysOldOpen t | N0129 |
| ibex_register_file_ff d/t | N0078 |

26 more row-modes have two (evidence/report.txt section 9).

**The UVM family: order-blind uhdm-dump distance to golden** (drivers/uvmdist.sh; lines only in golden + lines only
in ours, path-normalised, `LC_ALL=C` sorted; evidence/sweeps/uvm_orderblind_distance.txt):

| row | before pass 158 (0f607463) | after passes 158 + 160 (d48f8f8a) | f2f2d30b (after 163) | + the decodes |
|---|---|---|---|---|
| MiniAmiq d / t | 342763 | 281473 (-17.9%) | 281473 | 249671 (-11.3%) |
| SeqDriver d / t | 328035 | 268431 / 268427 (-18.2%) | 268427 / 268431 | 237137 / 237133 (-11.7%) |
| SimpleUVM d / t | 112073 | 77679 / 77675 (-30.7%) | 77675 | 60145 / 60141 (-22.6%) |
| Scoreboard d | 111227 | 76913 (-30.9%) | 76913 | 59039 (-23.2%) |
| BuildUVMPkg d / t | 58003 | 54140 (-6.7%) | 54140 | 54140 (0) |

The +-4 in SeqDriver is the UINT/decompile order coin. Passes 158 and 160 moved the UVM rows 7-31% toward golden
without converting any, as their reports said. Pass 163 did not touch them. The decodes take another 11-23% (the
include lines, the macro-body spans), except BuildUVMPkg, which holds no macro face. The UVM rows still carry 167-372
clusters each after the decodes: they stay the last family, behind the hier_path element family (r11u157 R2/R3/R6-R9)
and the class-method spans (N0104-N0107, N0152-N0209).

## 9. Files

* **cluster_index.csv**: one row per cluster, with rows / probe at f2f2d30b, after the decodes (`rows_after_law`) and
  after the decodes + pair B (`rows_after_pairs`), `alone_on_top_of_pairs`, `first_in_after_pairs`, coverage, ground,
  site, map 7's rows and coverage, key, example.
* **clusters.csv**: row-mode x cluster, with a `first` flag. **probe_clusters.csv** is the same for probe cases.
* **fail_list.csv**: every `STRICT_NOTEQUAL` row-mode with its first cluster, that cluster's coverage, ground and site,
  its open clusters, family, downstream verdict, the strict cell after the decodes, and whether the decodes / pair B
  clear it. **probe_fail_list.csv** is the same for probe cases.
* **evidence/**:
  * `clusters/`: record dumps, one example per cluster with a row or >= 3 probe cases (940);
  * `objects.csv`: one example object for every cluster;
  * `report.txt` (drivers/report8.py), `audit.txt` (drivers/audit8.py), `final8.txt`, `pristine_index.csv`;
  * `routes.json` (pair B's items, the residue notes and map 7's lists), `ground_override.json`, `sites.json`,
    `pins_new.txt`, `pinwant.txt`;
  * `decodes_scratch.patch`: the measured decode binary's source, f2f2d30b + r11u166 + r11u161, NOT applied;
  * `controls/controls.txt`;
  * `sweeps/`:
    * `sweep_pristine.txt`, `sweep_decodes.txt`;
    * `byteverify_pristine_vs_head.txt`, `byteverify_decodes_vs_pristine.txt`;
    * `decodes_attribution.txt`, `canaries.txt`;
    * `uvm_orderblind_distance.txt`, `dsfaces_{P,L}.csv`, `dsfacesLT_{P,L}.csv`;
  * `env.sh.txt`: the pins; FENCED is built from RESUME.md.
* **drivers/**:
  * `run8.sh` (the pipeline as run);
  * `final8.py` (ids from N2400), `report8.py` (coverage, yields, greedy sets, families), `audit8.py`, `tables8.py`;
  * `mksites8.py`, `uvmdist.sh`, `dsfaces.py`, `bvmirror.sh`;
  * map 7's `analyze.py`, `common.py`, `jobs.py` (the fence fails closed), `probejobs.py`, `probelaw.py`, `run1.sh`,
    `cc.sh`, `strictcmp_x.cpp`, `objrank.cpp`, `pinmulti.py`, `sites.py`, `evid.py`, `redact.py`.
