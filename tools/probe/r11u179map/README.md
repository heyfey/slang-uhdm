# r11u179map: the strict ground map, ninth edition (measurement only)

**Base.** Measured at `5e8d08d9` (branch matrix-1.87), HEAD of the branch for the whole pass: `git log 5e8d08d9..matrix-1.87`
is empty. The base sits after passes 164 (`35ed4056`), 167 (`45b8e774`), 168 (`f34d9d7c`, the r11u166 location model),
169 (`31739f79`), 171 (`72fd3061`, the r11u172 TypeEmit laws), 174 (`38d03148`, the r11u172 depth law), the verifications
r11u170 (`2dcbc596`), r11u173 (`e3f14d0a`) and r11u177 (`5e8d08d9` itself), and the decodes r11u172 (`tools/probe/r11u172rp`,
all landed) and r11u175 (`50a01bc3`, `tools/probe/r11u175uvm`: `law_exprstmt.patch` and `law_typeemit.patch` are NOT in
src). The eighth map is `tools/probe/r11u165map` (at `f2f2d30b`).

**The reference sweep.** The brief names `/tmp/intr11u163`; it no longer exists on this machine (pruned). This map
therefore ran its own full gate sweep of the pristine worktree build (`/tmp/r11u179_swP`, below) and uses it as the
reference. It equals the committed baselines cell for cell: status and strict columns 1596 of 1596 surelog rows and
1742 of 1742 uhdm2rtlil rows, `probe.csv` byte-identical to `results/golden_probe.csv`, `downstream.csv` equal to
`results/downstream_uhdm2rtlil.csv` on every verdict. It also equals the r11u177 landing sweep of this commit
(`/tmp/intr11u177`, read-only): its `downstream.csv` is identical on every column, and the byte comparison of the two
corpus sweeps (fence-free hard-link mirrors) reads 5 movers of 2560, MiniAmiq d/t, SeqDriver d/t and SimpleUVM d, each
a 4-line order-blind `uhdm-dump` difference (`UINT` / `vpiDecompile` only): the UVM order coin
([evidence/sweeps/byteverify_pristine_vs_head.txt](evidence/sweeps/byteverify_pristine_vs_head.txt)).

Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited; this directory is the whole patch.
Law names are written `law <name>` (no section sign) so `scripts/law_index.py` does not read this directory as a pass.

**The fence.** No fenced row is STRICT_NOTEQUAL at 5e8d08d9, so none is in the fail list, and their rows are counted from
the csv verdicts only. Every driver here that reads a database or a source takes the four names from the `FENCED=` line
of `tools/probe/r11u107repro/canaudit.sh` (`drivers/common.py fenced()`, `drivers/env.sh`; fail closed; never RESUME.md
by line number) and refuses them by word boundary: `jobs.py` (0 skipped: none is a fail row), `pinmulti.py`,
`dsfaces.py`, `uvmcensus9.sh`, `uvmdist.sh`, and `bvmirror.sh` (the byte comparisons ran on hard-link mirrors that leave
the 8 fenced row-mode databases out, `fenced_skipped=8`). The gate sweeps dispatched every row, as the gate mandates.
**No binary, gdb run or script touched a fenced test's sources or databases outside those sweeps.** A grep of this
directory for the four names reads 0 (825 files).

## Binaries (frozen `chmod 555` in `/tmp/r11u179_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `9958104447d83791aab5afe31f796885` | worktree `/tmp/wt_r11u179` at 5e8d08d9, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` |
| `slang-uhdm.law175` | `25b3b98b35cd0c25ed014cd7c18d5207` | MEASUREMENT ONLY: 5e8d08d9 + [evidence/law175_scratch.patch](evidence/law175_scratch.patch) = r11u175's `law_exprstmt.patch` + `law_typeemit.patch`, both a clean `git apply` on a fresh 5e8d08d9 (scratch worktree `/tmp/wt_r11u179L`) |
| `slang-uhdm.g1` | `b8e4ff6f548f7082b5a25adb879915e1` | 5e8d08d9 with `-DCMAKE_CXX_FLAGS=-g1`; gdb pins only |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's (the comparator is unchanged since map 7) |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | `drivers/strictcmp_x.cpp` built by `drivers/cc.sh`; the same md5 as maps 7 and 8 |
| `objrank` | `3e213a154aab7f619443de5f11646f0a` | `drivers/objrank.cpp` |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs): `/tmp/r11u179_swP` (pristine) and
`/tmp/r11u179_swL` (law175). In each, all 3273 `slang:` lines of the corpus `cmds.txt` files name that sweep's frozen
binary ([evidence/sweeps/sweep_pristine.txt](evidence/sweeps/sweep_pristine.txt),
[evidence/sweeps/sweep_law175.txt](evidence/sweeps/sweep_law175.txt)). Both exit 1 for one reason only,
`law index STALE: tests/LAWS.md`, which the main tree at 5e8d08d9 reads too (`scripts/law_index.py --check`, rc 1).

## 0. Where we stand (5e8d08d9; the committed baselines are the fail list)

| corpus | mode | judge-equal | strict-equal | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 450 | 30 |
| surelog | testflags | 474 | 446 | 28 |
| uhdm2rtlil | default | 803 | 783 | 20 |
| uhdm2rtlil | testflags | 803 | 783 | 20 |
| probe cases | | 4087 | 2796 | 1291 |

**The fail list is 98 row-modes (58 surelog + 40 uhdm2rtlil) in 52 tests, plus 1291 probe cases.** All 98 row-modes
and all 4087 probe cases were dispatched to the strict comparator; none is fenced.

First fields, tallied from the `strict` column of results/golden_*.csv (= the pristine sweep's):
* surelog 58: fullname 26, file 9, endcol 6, endline 5, line 4, depth 2, name 2, type 2, col 2;
* uhdm2rtlil 40: fullname 18, line 8, file 8, name 4, endcol 2;
* probe 1291: fullname 468, line 220, endcol 192, file 110, type 102, depth 91, name 58, col 28, endline 13, value 5,
  decompile 4.

Mode asymmetries (the default row is the map's row; these differ in testflags):
* NE in default only: InterfArrayBind and UnsizedParam (testflags CMP_EQUAL), Rggen (testflags SURELOG_FAIL),
  Scoreboard (testflags SLANG_REJECT);
* NE in testflags only: HierPathTypespec and LocalScopeHierPath;
* a different cell per mode: ArrayMethodIterator `name(6)` / `name(16)`, AssertDelayError `fullname(48)` / `(66)`,
  AssertTempError `fullname(28)` / `(38)`, ClassTypeParam `endline(17)` / `file(30)`, FuncStructVal `endcol(95)` /
  `(177)`, FuncStructValSimple `file(40)` / `(60)`, UnitElabBlock `endline(13)` / `(12)`;
* every uhdm2rtlil fail test is NE in both modes with the same cell, and **every uhdm2rtlil fail row-mode is downstream
  IDENTICAL** (40 of 40).

**Since map 8.** Map 8 counted 151 row-modes and 1490 probe cases at f2f2d30b. Since then 53 row-modes and 199 probe
cases converted and none entered (committed baselines at each landing, [evidence/audit.txt](evidence/audit.txt) A):

| landing | row-modes | tests | probe cases | strict-cell changes |
|---|---|---|---|---|
| pass 164 (`35ed4056`) | 14 | 7 | 50 | 4 |
| r11u170 verification (`2dcbc596`) | 0 | 0 | 0 | 0 |
| pass 167 (`45b8e774`) | 8 | 4 | 29 | 2 |
| pass 168 (`f34d9d7c`) | 10 | 5 | 21 | 23 |
| r11u173 verification (`e3f14d0a`) | 0 | 0 | 0 | 0 |
| pass 169 (`31739f79`) | 2 | 1 | 58 | 10 |
| pass 171 (`72fd3061`) | 7 | 4 | 13 | 23 |
| pass 174 (`38d03148`) | 12 | 6 | 28 | 6 |
| r11u177 verification (`5e8d08d9`) | 0 | 0 | 0 | 0 |

**Clusters.** Map 8 had 1284 clusters; this map has **1101** (681 carry a corpus row, 710 a probe case). The key is
maps 4-8's (`facet|type|shape|under:<walk parent type>` + `@builtin` / `@in-typespec`), so a persisting key keeps its id:
1094 keep map 8's id, 2 reappear under an earlier map's id (N0675, N2345), **5 are new, N2411-N2415**; 190 map-8
clusters are gone.

| cluster | rows 5e8d08d9 -> after r11u175 | probe -> after | ground | key | example | site |
|---|---|---|---|---|---|---|
| N0675 | 2 -> 2 | 0 -> 0 | A | `fullname\|ref_typespec\|tok:id->id.id\|under:constant` | uhdm2rtlil/testflags/struct_param_func_config #2485/2359 ref_typespec '' golden=work@child.C.p::cfg_t.u ours=w | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law evalFuncBodyRhsStam |
| N2345 | 0 -> 0 | 1 -> 1 | B | `struct\|golden-only:elsewhere\|constant\|under:cont_assign` | r11u88repro/grid/a6_commadrive #197/-1 constant '' golden=1 objs ours= | emitInterfaceInstance (ModuleEmit.cpp, law caIfaceBodyCaFolds83) < emitInstance (ModuleEmit.cpp, law caNestedModDeclNoRe |
| N2411 | 7 -> 7 | 0 -> 0 | A | `span\|constant\|col\|under:method_func_call` | surelog/default/Scoreboard #195016/194379 constant '' golden=270:51:270:63 ours=270:42:270:63 | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitStmt (StmtEmit.cp |
| N2412 | 2 -> 2 | 0 -> 0 | A | `fullname\|ref_typespec\|tok:->id@id.id.\|under:constant` | uhdm2rtlil/testflags/struct_param_func_config #1848/1776 ref_typespec '' golden=p::cfg_t.u ours=work@struct_pa | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law evalFuncBodyRhsStam |
| N2413 | 0 -> 0 | 1 -> 1 | A | `span\|assignment\|col\|under:initial` | r11v11u8repro/v9 #11/11 assignment '' golden=10:9:11:16 ours=10:11:11:16 | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStmtCall172)  |
| N2414 | 0 -> 0 | 1 -> 1 | A | `span\|initial\|col\|under:module_inst` | r11v11u8repro/v9 #10/10 initial '' golden=10:1:11:17 ours=10:3:11:17 | emitProcess (StmtEmit.cpp, law classPropUnitImport21) < emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < ex |
| N2415 | 0 -> 0 | 1 -> 1 | A | `value\|constant\|value:UINT->DEC+decompile+size+consttype:9->1\|under:cont_assign` | r11u88repro/grid/a6_commadrive #196/196 constant '' golden=#4\|64\|UINT:4\|9 ours=32'd2\|32\|DEC:2\|1 | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitContAssigns (ModuleEmit.cpp, law elabCaTernaryArmInstall9 |

* N2411 is a UVM macro-argument constant column (`uvm_printer_defines.svh` 270:51 golden, 270:42 ours) on the four
  UVM tests' 7 row-modes: the location model's next face, ExprEmit.
* N2412 and N0675 are struct_param_func_config's leftover reference names under pass 174's copies (the `leftRefFix174`
  walk; golden `p::cfg_t.u` / `work@child.C.p::cfg_t.u`, ours through the instance), ParamEmit: pass 174's own residue
  after its change `fullname(14) -> line(8)` moved this row's head to the struct relocation (N0043).
* N2413 / N2414 are r11v11u8repro/v9's column faces (map 8's N2410 re-keyed after pass 168's location model);
  N2345 / N2415 are r11u88repro a6_commadrive's `#4` delay constant (golden `UINT:4`, ours `32'd2` decompile).

## 1. Method (map 8's pipeline re-based, [drivers/run9.sh](drivers/run9.sh))

1. **Input.** The pristine sweep `/tmp/r11u179_swP` (= the committed baselines, above). The jobs are every
   `STRICT_NOTEQUAL` row-mode of results/golden_*.csv (98; `drivers/jobs.py`: 0 missing, 0 fenced, one binary). Each
   golden is the cache entry its `cmds.txt` names. Every probe case is a job too (4087); its golden is
   `scripts/check_probe.py`'s `cache_dir(rel)` (Surelog's identity + the case path + a hash of the case's files).
2. **Strict runs.** `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job. All 98 corpus runs return rc=2;
   probe runs return rc=0 on 2796 cases and rc=2 on 1291, and every probe `differ:<field>(<n>)` cell rebuilt from the
   run (first field + `objects_differing`) equals results/golden_probe.csv (1291 of 1291).
3. **Analysis.** `drivers/analyze.py` (map 3's alignment, the committed mode-4 rule) records EVERY differing object;
   its reimplementation of the tool's rule agrees with the tool's stdout on 1389 of 1389 rows (0 VERIFY-MISMATCH,
   0 CELL-MISMATCH against the csv cells; [evidence/final9.txt](evidence/final9.txt)).
4. **Clusters.** `drivers/final9.py`: map 8's key; ids persist from map 8 (else the latest earlier map); new ids from
   N2411.
5. **Sites.** `drivers/pinmulti.py` ran one gdb session per example row (the `-g1` exporter stops at the example
   object's `Serializer::Make<type>` rank; the worktree's and the pinned corpora's case directories are the cwd). It
   pinned the 41 clusters of [evidence/pinwant.txt](evidence/pinwant.txt): those with >= 3 row-modes, first on a fail
   row, >= 40 probe cases or not in map 8, whose example object changed since map 8 (or had no pin).
   * 36 runs wrote the reference database byte for byte (`db=SAME`).
   * 3 (N0050, N0297, N2411) live only on the UVM coin rows (Scoreboard, SimpleUVM, MiniAmiq, SeqDriver), where no gdb
     run reproduced the database byte for byte (4 runs on Scoreboard, 1 on SimpleUVM). Their pins were kept because
     the object at the pinned rank in the gdb run's own database carries the example's name, file and span
     (`db=DIFF-rankverified`, [evidence/pins_final.txt](evidence/pins_final.txt)).
   * 2 (N0194, N0478) have no partner record (golden-only objects); they keep map 8's pin.
   * Of the 39 new pins, 29 name the same mint as map 8's, 2 name another (N0054, N0297: map 8's pin is kept beside
     it), 8 are clusters map 8 did not pin. Every other cluster keeps map 8's pin, marked `[r11u165map pin]`.
   `drivers/mksites9.py` merges them ([evidence/sites.json](evidence/sites.json)).
6. **Ground.** A = ExprEmit/EmitHelpers/StmtEmit/ParamEmit, B = TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/
   uhdm_main, by the pinned mint's file, overridden where a pass decoded the fix site elsewhere
   ([evidence/ground_override.json](evidence/ground_override.json): map 8's list, plus to A: N0638 / N0281 (pass 171
   R4: the enum copy is minted by ParamEmit `emitParameters`), N0965 (pass 171 R3), N0545 / N0546 (pass 171 R2)).
7. **Coverage** ([evidence/routes.json](evidence/routes.json), `drivers/report9.py`):
   * **r11u175's two law patches, MEASURED**: a cluster gone under the law175 binary's full sweep reads
     `COVERED r11u175 (law patches, MEASURED ...)`;
   * **pair A r11u178, OPTIMISTIC**: its brief items mapped to clusters and rows (below); a covered cluster counts fixed
     whole; a named ROW covers a cluster only when every row of the cluster is a named row of that ground (a named
     row does not cover a multi-test cluster: it reads `OPEN (one shape named by r11u178: ...)`);
   * **pair B r11u176, OPTIMISTIC**: the same, plus the ground-B clusters of the UVM (MiniAmiq, SeqDriver, SimpleUVM,
     Scoreboard, BuildUVMPkg) and Earlgrey_0_1 rows' **first ten differing records** at the r11u175 cross-section whose
     rows are all UVM/Earlgrey rows (the brief's "UVM/Earlgrey first records");
   * **OPEN** otherwise, with map 8's routing where it had one (`map 8 gave it to r11u164; passes 164-174 left it`,
     `map 8 listed it: ground-X step n`).
8. **Yields.** The law175 binary's full sweep is re-dumped and re-keyed (1313 of 1313 analyzer rows verify), so r11u175
   is MEASURED; the pairs are applied optimistically to that cross-section. The `alone` column is the rows a cluster
   clears alone on top of r11u175 and both pairs.

What the live pairs were mapped to (evidence/routes.json):

| pair | brief item | clusters | named rows |
|---|---|---|---|
| A r11u178 | r11u175 `law_exprstmt.patch` | MEASURED (with law_typeemit) | |
| A | pass 174 residues: FuncStructValSimple's package-listing leftovers, FuncStructVal's endcol | N0086 N0087 N1096 | FuncStructValSimple, FuncStructVal |
| A | pass 174: the overridden struct parameter's member fold, the shared minted leftover | none (evidence cases only: ub/u12, lr/l15) | |
| A | r11u177 / r11u175 residues: the importer-clone foreach variables, the middle-select references | N0490 N0491 N0134 N0408, N0175 | |
| A | r11u177: the wildcard-imported bound, the pattern-literal actual, the empty-name family | none (evidence cases only) | |
| A | the macro-born based literal's spaces | none (stage 1, outside the strict fail list) | |
| A | pass 171's sister faces: ibex_multdiv_fast, Scr1SvTests' call-argument typespec, TypeParameterAsPortTypeWithEnum's enum copy | N0545 N0546, N0965, N0012 N0034 N0638 | ibex_multdiv_fast, TypeParameterAsPortTypeWithEnum(+OfParametrizedWidth) |
| A | map 8's ground-A leftovers | N0036 N0977 N0943 N0278 N0427 N0003 N0536 N0407 N0745 N1083 N0097 N0415 N0474 N0549 N0942 | YosysRiscv, CovMacro, LocalScopeHierPath t, InterfArrayBind d, StructParamPatternInitCast, iface_zero_width_field, ibex_icache |
| B r11u176 | r11u175 `law_typeemit.patch` (law externProtoFormalsFromPrototype175) | MEASURED | |
| B | the F3 typedef relocation order to class-method formals | N0080 N0075 N0144 N0239 N0121 | |
| B | pass 171: the package-qualified formal not relocated | N0219 N0325 N0434 | ibex_pmp |
| B | pass 171: UnsizedParam's per-instance copy; OneNetModPort | N0457 N0136 N0775 | UnsizedParam d, OneNetModPort |
| B | pass 171: same-position declarator in two files, bare-type-name formal key, the non-lvalue UDP-form swallow, the else-if gaps | none (evidence cases only) | |
| B | the import-parameter copies N0151 / N0262 / N0182 | N0151 N0262 N0182 | |
| B | the UVM/Earlgrey first records | the ground-B first-ten clusters (all already named: N0075 N0080 N0144 N0239; N0163 also has non-UVM rows, so it stays OPEN) | |

## 2. Positive controls ([evidence/controls/controls.txt](evidence/controls/controls.txt))

| control | result |
|---|---|
| surelog/default/1364_2005 (CMP_EQUAL) | `STRICT_EQUAL 159 objects`, rc 0, record dumps identical (159 / 159) |
| surelog/default/HierPathInterfBlock (CMP_EQUAL) | `STRICT_EQUAL 226 objects`, rc 0, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray (CMP_EQUAL) | `STRICT_EQUAL 194 objects`, rc 0, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, lhsPath = rhsPath `design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL,decompile:` both modes |
| analyzer rule vs tool stdout | 1389 / 1389 at 5e8d08d9; 1313 / 1313 on the r11u175 cross-section |
| probe cells vs golden_probe.csv | 4087 / 4087 (probe.csv byte-identical); 1291 / 1291 rebuilt from the strict runs |
| pin validity | 36 / 41 `db=SAME`, 3 rank-verified on the coin rows, 2 no partner (map 8's pin kept) |

## 3. The gates (this map lands no binary; both sweeps measured)

| gate | pristine `9958104447d8` (`/tmp/r11u179_swP`) | law175 `25b3b98b35cd` (`/tmp/r11u179_swL`) |
|---|---|---|
| (1) build | = the main tree's build (md5 above) | 5e8d08d9 + the two r11u175 patches (clean apply) |
| (2) probe vs golden_probe.csv | EQUAL 2796 / STRICT_NOTEQUAL 1291; `regressions=0 conversions=0 changes=0`; probe.csv byte-identical | EQUAL **2872** / 1215; `regressions=0 conversions=76 changes=73` |
| (3) surelog + uhdm2rtlil vs golden_*.csv | `regressions=0 conversions=0 changes=0` both; 480/3 + 474/3, 803/1/67 | surelog `regressions=0 conversions=0 changes=11` (below); uhdm2rtlil `0 / 0 / 0` |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; not identical and not excused 0; every verdict = results/downstream_uhdm2rtlil.csv | the same; `downstream.csv` byte-identical to the pristine sweep's |
| (5) uhdm-cmp | no row touched | every corpus mover keeps its judge status (the 11 changes are STRICT_NOTEQUAL -> STRICT_NOTEQUAL) |
| (6) byteverify (SELFCHECK=1, fence-free mirrors) | vs `/tmp/intr11u177`: 5 / 2560 movers, the UVM coin (4 lines `UINT`/`vpiDecompile` each, order-blind) | vs pristine: **13 / 2560 movers, exactly r11u175's 13 predicted names** (ApbSlave d/t, BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t, SimpleUVM d/t, SVSwitch d/t; [evidence/sweeps/byteverify_law175_vs_pristine.txt](evidence/sweeps/byteverify_law175_vs_pristine.txt)); uhdm2rtlil 0 |
| canaries ([evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)) | surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS | surelog ok=43 changed=9 (exactly the 9 canary rows among the 11 changes); uhdm2rtlil ok=16; ctcan2 PASS both |

The mover prediction is r11u175's own (its `predict175` read the e3f14d0a pristine databases and named these 13 row-modes
before its law sweep); this map did not re-run a predictor before its law sweep. Every mover is one of the 11 CHANGE
rows or ApbSlave d/t (bytes only: `depth(1)` unchanged, order-blind 88 -> 12).

## 4. r11u175's two law patches, MEASURED at 5e8d08d9 (the cross-section)

| stage | conversions | changes |
|---|---|---|
| probe | **76** (EQUAL 2796 -> 2872; r11u175 measured 75 at e3f14d0a) | 73 |
| surelog | 0 | **11**, exactly r11u175's 11 |
| uhdm2rtlil | 0 | 0 |
| downstream | 803 / 66 / 2 / 0, csv byte-identical | |

The 11 surelog changes (fresh csv cells of `/tmp/r11u179_swL/surelog.csv`, not written to results/):

    BuildUVMPkg default/testflags  differ:line(94)     -> differ:line(69)
    MiniAmiq    default/testflags  differ:file(29)     -> differ:file(26)
    SeqDriver   default/testflags  differ:file(29)     -> differ:file(26)
    SimpleUVM   default/testflags  differ:fullname(45) -> differ:fullname(42)
    Scoreboard  default            differ:fullname(45) -> differ:fullname(42)   (testflags SLANG_REJECT)
    SVSwitch    default/testflags  differ:fullname(11) -> differ:file(9)

(r11u175 measured `file(46) -> file(43)` and `fullname(62) -> fullname(59)` at e3f14d0a: passes 169/171/174 moved the
heads in between; the deltas are the same.)

**Per patch** ([evidence/sweeps/r11u175_attribution.txt](evidence/sweeps/r11u175_attribution.txt); the law binary with
`R11U175_FSPAN_OFF=1`, i.e. `law_exprstmt.patch` alone, and with `R11U175_MULT_OFF=1 R11U175_FULLNAME_OFF=1
R11U175_ESPAN_OFF=1`, i.e. `law_typeemit.patch` alone): of the 76 probe conversions, **17 need only law_exprstmt
(pair A's share), 54 only law_typeemit (pair B's share), 5 need both**; neither alone regresses a case. All 11 surelog
cell changes come from law_exprstmt alone (law_typeemit alone moves bytes and records, no first cell).

**Clusters.** 101 clusters are gone under the patches (among them N0093, N0095, N0104-N0107, N0111, N0154, N0156,
N0157, N0174, N0226, N0233, N0489, N0500), 6 fall (N0069 13->2, N0118 11->2, N0100 11->2, N0141 10->3, N0120 11->9,
N0039 12->10), and 2 grow on MiniAmiq/SeqDriver only (N0706 2->4, N0784 0->4, plus 1 key new under the law): the
importer clones' new copies (law importCloneBodyLocalCopies175) carry the facets their home objects already have
(`...::do_bus_write::foreach_value::rw_access::uvm_pkg::uvm_reg_bus_op::byte_en` names), as r11u175 recorded.

No corpus row converts: every moved row keeps other families (section 9).

## 5. The yield, and the fail list after r11u175 and both pairs

| | row-modes cleared | tests cleared (every NE mode) | probe cases cleared |
|---|---|---|---|
| r11u175's two law patches, MEASURED | 0 | 0 | 76 |
| pair A r11u178, optimistic, on top of r11u175 | **12**: CovMacro d/t, YosysRiscv d/t, InterfArrayBind d, LocalScopeHierPath t, ibex_multdiv_fast d/t, TypeParameterAsPortTypeWithEnum d/t, ...OfParametrizedWidth d/t | 7 | 40 |
| pair B r11u176, optimistic, on top of r11u175 | **1**: UnsizedParam d | 1 | 8 |
| **everything** (r11u175 + both pairs) | **15** (the 13 above + ibex_pmp d/t, which needs both: A N0943, B the relocation family) | **9** | **124** |

| corpus | mode | 5e8d08d9 | after r11u175 (measured) | + pair A | + pair B | + both pairs |
|---|---|---|---|---|---|---|
| surelog | default | 30 | 30 | 27 | 29 | 26 |
| surelog | testflags | 28 | 28 | 25 | 28 | 25 |
| uhdm2rtlil | default | 20 | 20 | 17 | 20 | 16 |
| uhdm2rtlil | testflags | 20 | 20 | 17 | 20 | 16 |
| **all** | | **98 / 52 tests** | **98 / 52** | 86 | 97 | **83 / 43 tests** |
| probe cases | | 1291 | 1215 | 1175 | 1207 | **1167** |

First fields after r11u175 (the law sweep's csvs): surelog 58: fullname 24, file 11, endcol 6, endline 5, line 4,
depth 2, name 2, type 2, col 2; uhdm2rtlil 40 unchanged; probe 1215: fullname 456, endcol 197, line 169, file 107,
depth 103, type 76, name 58, col 29, endline 11, value 5, decompile 4.

**The named-row upper bound.** Under the rule a named row does not cover a multi-test cluster. Four named row-modes stay
open only on such a cluster of their own pair: FuncStructValSimple d/t on N0131 (pass 174 R1's `#129`, the whole-formal
leftover whose reference stores `cva6_config_pkg` in golden: pair A's own item; N0131 also sits on Earlgrey, FuncStructVal,
MiniAmiq, SeqDriver) and OneNetModPort d/t on N0268 + N0418 + N0419 (pair B's; shared with OneNetModPortGeneric,
InterfaceModPort, SVSwitch). If each pair's fix reaches its named row whole, the pairs clear **19 row-modes / 11 tests**.
StructParamPatternInitCast, iface_zero_width_field and ibex_icache are pair-A named rows whose last cluster is ground B
(N0014, N0688, N0129): the next pair-B refill's first steps (section 8).

## 6. Ranked OPEN clusters with sites (on top of r11u175 measured + both pairs optimistic)

Columns: `rows left` = row-modes the cluster still carries after r11u175 and the pairs (rows at 5e8d08d9 in
parentheses); `first-open heads` = rows it is the first OPEN record of (the earliest walk record no landing, patch or
pair covers); `alone` = rows it clears alone on top of everything; `probe` = its cases after r11u175. The whole list is
cluster_index.csv (`rows_after_law`, `rows_after_pairs`, `alone_on_top_of_pairs`, `first_in_after_pairs`,
`alone_on_pristine`, `coverage`, `ground`, `site`, map 8's columns).

**532 OPEN clusters still carry a row** (ground A 219, B 308, unpinned 5). The list by rows is dominated by the UVM family
(9 row-modes, 5 tests), so it is given three ways: T1 by all rows, T1b over the rows outside the big families (UVM,
Earlgrey_0_1, Rggen, BlackBePipeInt, Scr1SvTests, ApbSlave, SVSwitch), and T1c per ground.

### T1. Ranked OPEN clusters, all rows (top 40 of 532)

| # | cluster | rows left (5e8d08d9) | sl/u2r | tests | families | first-open heads | alone | probe (after r11u175) | ground | status | key | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0031 | 15 (15) | 9/6 | 8 | UVM jeras | 0 | 0 | 13 | B | OPEN | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp,  |
| 2 | N0043 | 14 (14) | 10/4 | 8 | UVM | 4 | 0 | 5 | B | OPEN (map 8 ground-B step 12) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWholeLhsB |
| 3 | N0001 | 14 (14) | 12/2 | 8 | Earlgrey Rggen UVM | 0 | 0 | 8 | A | OPEN (map 8 ground-A+B step 39) | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
| 4 | N0067 | 13 (13) | 13/0 | 7 | ApbSlave SVSwitch UVM | 2 | 0 | 47 | B | OPEN (map 8 ground-A+B step 35) | `file\|class_typespec\|ours-empty\|under:ref_typespec` | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPro |
| 5 | N0072 | 13 (13) | 13/0 | 7 | UVM | 2 | 0 | 8 | B | OPEN (map 8 ground-B step 1) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNo |
| 6 | N0068 | 13 (13) | 13/0 | 7 | ApbSlave SVSwitch UVM | 0 | 0 | 47 | B | OPEN (map 8 ground-A+B step 35) | `span\|class_typespec\|ours-zero\|under:ref_typespec` | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPro |
| 7 | N0042 | 13 (13) | 9/4 | 7 | UVM | 0 | 0 | 10 | B | OPEN | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp,  |
| 8 | N0061 | 12 (12) | 12/0 | 7 | Earlgrey Rggen UVM | 0 | 0 | 8 | A | OPEN | `span\|bit_select\|col+endcol\|under:hier_path` | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPathSelectEras |
| 9 | N0142 | 12 (12) | 12/0 | 7 | Earlgrey Rggen UVM | 0 | 0 | 0 | A | OPEN | `struct\|golden-only:fewer-copies\|range\|under:array_typespec` | makeUnpackedArrayParamTs (ParamEmit.cpp, law pkgParamTsRef) < emitParameters (ParamEmit.cpp, law importElemBar |
| 10 | N0056 | 11 (11) | 9/2 | 6 | UVM | 2 | 2 | 1 | B | OPEN (map 8 ground-B step 3) | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 11 | N0103 | 11 (11) | 11/0 | 6 | UVM | 0 | 0 | 7 | B | OPEN (map 8 ground-A+B step 14) | `name\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNo |
| 12 | N0007 | 11 (11) | 11/0 | 6 | SVSwitch UVM | 0 | 0 | 6 | A | OPEN (map 8 ground-A+B step 15) | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
| 13 | N0116 | 11 (11) | 11/0 | 6 | UVM | 0 | 0 | 2 | B | OPEN (map 8 gave it to r11u164) | `span\|class_typespec\|col+endcol\|under:ref_typespec` | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeTypespec (Type |
| 14 | N0119 | 11 (11) | 11/0 | 6 | SVSwitch UVM | 0 | 0 | 2 | A | OPEN | `span\|bit_select\|col+endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBaseOnly110) < |
| 15 | N0131 | 10 (10) | 10/0 | 5 | Earlgrey UVM | 4 | 2 | 5 | A | OPEN (one shape named by r11u178: pass 174 R1 FuncStructValS | `fullname\|ref_typespec\|ours-empty\|under:constant` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law negLitPkgRetFoldNested3 |
| 16 | N0039 | 10 (12) | 12/0 | 7 | ApbSlave Rggen UVM | 0 | 0 | 156 | B | OPEN (map 8 ground-A+B step 35) [r11u175: rows 12->10] | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law implicitArgDimsInner155) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRa |
| 17 | N0127 | 10 (10) | 10/0 | 6 | Rggen UVM | 0 | 0 | 79 | B | OPEN | `span\|array_typespec\|endcol\|under:ref_typespec` | makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDimOvrChain4) < emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPo |
| 18 | N0128 | 10 (10) | 10/0 | 6 | Rggen UVM | 0 | 0 | 69 | B | OPEN | `span\|range\|col+endcol\|under:array_typespec` | operator() (ModuleEmit.cpp, law sizeDimOvrChain4) < makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDimOvrChain4 |
| 19 | N0164 | 9 (9) | 9/0 | 5 | UVM | 6 | 0 | 5 | B | OPEN (map 8 gave it to r11u164) | `fullname\|ref_typespec\|tok:id::id::id::id::->\|under:bit_typespec` | bareScalarTdCopyOf (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52) < operator() (TypeEmit.cpp, law modScala |
| 20 | N0040 | 9 (9) | 7/2 | 5 | Earlgrey Rggen Scr1 | 2 | 0 | 34 | B | OPEN (map 8 ground-A+B step 29) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 21 | N0152 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 71 | A | OPEN | `file\|begin\|ours-empty\|under:function` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetim |
| 22 | N0153 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 71 | A | OPEN | `span\|begin\|ours-zero\|under:function` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetim |
| 23 | N0051 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 9 | B | OPEN (map 8 gave it to r11u164) | `span\|class_typespec\|endcol\|under:ref_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter |
| 24 | N0132 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 7 | B | OPEN (map 8 gave it to r11u164) | `span\|int_typespec\|line+endline\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitClassParameters (UhdmExporter.cpp, law classTpT |
| 25 | N0109 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 6 | A | OPEN | `file\|string_typespec\|ours-empty\|under:ref_typespec` | operator() (StmtEmit.cpp, law classPropUnitImport21) < emitStmt (StmtEmit.cpp, law foreachLoopVarObjs9) < emit |
| 26 | N0110 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 6 | A | OPEN | `span\|string_typespec\|ours-zero\|under:ref_typespec` | operator() (StmtEmit.cpp, law classPropUnitImport21) < emitStmt (StmtEmit.cpp, law foreachLoopVarObjs9) < emit |
| 27 | N0160 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 6 | A | OPEN | `span\|ref_var\|endcol\|under:foreach_stmt` | emitStmt (StmtEmit.cpp, law foreachScopedArrayWrittenClassVar33) < emitStmt (StmtEmit.cpp, law invalidChild14) |
| 28 | N0161 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 6 | B | OPEN (map 8 gave it to r11u164) | `fullname\|ref_typespec\|tok:id::->\|under:class_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law sharedAliasNoStamp41) < makeTypespec (TypeEmit.cpp, law classTdLoca |
| 29 | N0162 | 9 (9) | 9/0 | 5 | ApbSlave UVM | 0 | 0 | 6 | B | OPEN (map 8 gave it to r11u164) | `span\|string_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law unsignedScalarVecTsAtKeyword137) < emitImportedPkgVarNets (ModuleEmit.cpp, law |
| 30 | N0171 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 6 | B | OPEN (map 8 gave it to r11u164) | `struct\|golden-only:fewer-copies\|bit_typespec\|under:ref_typespec` | namedElemPackedDimTs31 (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypeParamDefaultTs (TypeEmit.cpp, law  |
| 31 | N0170 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 5 | B | OPEN (map 8 gave it to r11u164) | `span\|class_var\|col+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitPackageClassMethodClon |
| 32 | N0071 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 4 | A | OPEN | `span\|hier_path\|endcol\|under:operation` | emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue1 |
| 33 | N0172 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 4 | A | OPEN | `file\|begin\|ours-empty\|under:task` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetim |
| 34 | N0173 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 4 | A | OPEN | `span\|begin\|ours-zero\|under:task` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetim |
| 35 | N0757 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 4 | B | OPEN (map 8 gave it to r11u164) | `span\|typespec_member\|endcol\|under:struct_typespec` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTypedefs (TypeEmit.cpp, law bodyTypede |
| 36 | N0178 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | A | OPEN | `file\|begin\|ours-empty\|under:if_stmt` | emitStmt (StmtEmit.cpp, law parBlockJoinTailAfterFirstItem131) < emitStmt (StmtEmit.cpp, law invalidChild14) < |
| 37 | N0179 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | A | OPEN | `span\|begin\|ours-zero\|under:if_stmt` | emitStmt (StmtEmit.cpp, law parBlockJoinTailAfterFirstItem131) < emitStmt (StmtEmit.cpp, law invalidChild14) < |
| 38 | N0180 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 8 gave it to r11u164) | `fullname\|ref_typespec\|ours-empty\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListin |
| 39 | N0158 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN (map 8 gave it to r11u164) | `depth\|bit_typespec\|ref_typespec->ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDe |
| 40 | N0168 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN (map 8 gave it to r11u164) | `span\|int_typespec\|col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitClassParameters (UhdmExporter.cpp, law classTpT |

### T1b. Ranked OPEN clusters on the rows outside the big families (top 30)

| # | cluster | rows outside the big families (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0083 | 6 (3) | 0 | 0 | 23 | B | OPEN (map 8 ground-B step 14) | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typePara |
| 2 | N0031 | 6 (8) | 0 | 0 | 13 | B | OPEN | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExpo |
| 3 | N0268 | 6 (4) | 0 | 0 | 3 | B | OPEN (one shape named by r11u176: pass 171 R9 OneNetModPort) | `struct\|ours-only:fewer-copies\|logic_var\|under:io_decl` | makeVar (TypeEmit.cpp, law pkgScopedPortAnyDirVar77) < emitInterfaceInstance (ModuleEmit.cpp, law de |
| 4 | N0043 | 5 (8) | 4 | 0 | 5 | B | OPEN (map 8 ground-B step 12) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpClon |
| 5 | N0014 | 4 (3) | 4 | 2 | 12 | B | OPEN (map 8 ground-A+B step 16) | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law |
| 6 | N0131 | 4 (5) | 4 | 2 | 5 | A | OPEN (one shape named by r11u178: pass 174 R1 FuncStructValS | `fullname\|ref_typespec\|ours-empty\|under:constant` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law negLitPkgRetF |
| 7 | N0627 | 4 (2) | 4 | 0 | 0 | B | OPEN (map 8 ground-A+B step 30) | `fullname\|property_decl\|tok:id.id.id->id\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDesign (UhdmExporter.cpp, law im |
| 8 | N0679 | 4 (2) | 4 | 0 | 0 | B | OPEN | `value\|constant\|value:HEX->UINT+decompile+consttype:5->9\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law replParamConstClampsToDeclWidth) < emitInstance (ModuleEmit.cpp |
| 9 | N0040 | 4 (5) | 2 | 0 | 34 | B | OPEN (map 8 ground-A+B step 29) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law |
| 10 | N0072 | 4 (7) | 2 | 0 | 8 | B | OPEN (map 8 ground-B step 1) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneD |
| 11 | N0418 | 4 (3) | 2 | 0 | 3 | B | OPEN (one shape named by r11u176: pass 171 R9 OneNetModPort) | `file\|ref_obj\|golden-empty\|under:port` | emitPorts (ModuleEmit.cpp, law caIfacePortDeclNetMint93) < emitModuleDefPorts (ModuleEmit.cpp, law c |
| 12 | N0056 | 4 (6) | 2 | 2 | 1 | B | OPEN (map 8 ground-B step 3) | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (Uhd |
| 13 | N0090 | 4 (4) | 2 | 0 | 0 | B | OPEN (map 8 ground-A+B step 32) | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEm |
| 14 | N0476 | 4 (2) | 0 | 0 | 21 | A | OPEN | `file\|logic_typespec\|ours-empty\|under:ref_typespec` | makeBareVecParamTs (ParamEmit.cpp, law genLpCaSharedBareTs) < patchParamTypespecs (ParamEmit.cpp, la |
| 15 | N0477 | 4 (2) | 0 | 0 | 21 | A | OPEN | `span\|logic_typespec\|ours-zero\|under:ref_typespec` | makeBareVecParamTs (ParamEmit.cpp, law genLpCaSharedBareTs) < patchParamTypespecs (ParamEmit.cpp, la |
| 16 | N0042 | 4 (7) | 0 | 0 | 10 | B | OPEN | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExpo |
| 17 | N0133 | 4 (2) | 0 | 0 | 10 | B | OPEN (map 8 ground-B step 12) | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law unnam |
| 18 | N0487 | 4 (2) | 0 | 0 | 10 | B | OPEN (map 8 ground-B step 12) | `struct\|ours-only:absent\|constant\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgUnvaluedActualLitRetFold8) < emitInstance (ModuleEmit.cpp,  |
| 19 | N0444 | 4 (2) | 0 | 0 | 8 | B | OPEN | `file\|range\|ours-empty\|under:logic_typespec` | emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassDefn (UhdmE |
| 20 | N0445 | 4 (2) | 0 | 0 | 8 | B | OPEN | `span\|range\|ours-zero\|under:logic_typespec` | emitClassParameters (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassDefn (UhdmE |
| 21 | N0499 | 4 (2) | 0 | 0 | 7 | A | OPEN | `value\|constant\|decompile+size+consttype:9->0\|under:range` | operator() (ParamEmit.cpp, law genLpCaSharedBareTs) < makeBareVecParamTs (ParamEmit.cpp, law genLpCa |
| 22 | N0419 | 4 (3) | 0 | 0 | 3 | B | OPEN (one shape named by r11u176: pass 171 R9 OneNetModPort) | `span\|ref_obj\|golden-zero\|under:port` | emitPorts (ModuleEmit.cpp, law caIfacePortDeclNetMint93) < emitModuleDefPorts (ModuleEmit.cpp, law c |
| 23 | N0299 | 4 (3) | 0 | 0 | 1 | A | OPEN (map 8 ground-A+B step 30) | `fullname\|ref_obj\|tok:id.id.id->id\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law memberActualLeak) |
| 24 | N0431 | 4 (3) | 0 | 0 | 0 | B | OPEN (map 8 ground-A+B step 30) | `fullname\|assert_stmt\|tok:id.id.id->id\|under:module_inst` | emitAssertion (ModuleEmit.cpp, law genProcParamFold) < emitModuleDef (ModuleEmit.cpp, law shadowedIm |
| 25 | N0628 | 4 (2) | 0 | 0 | 0 | A | OPEN (map 8 ground-A+B step 30) | `fullname\|ref_obj\|tok:id.id.id->id\|under:property_spec` | emitExpr (ExprEmit.cpp, law writtenCallArgs16) < emitAssertionExpr (ModuleEmit.cpp, law clockingSkew |
| 26 | N0263 | 2 (3) | 2 | 0 | 60 | B | OPEN | `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec (TypeEmit.cpp, law typeParam |
| 27 | N0738 | 2 (1) | 2 | 0 | 36 | B | OPEN (map 8 ground-A+B step 22) | `name\|logic_typespec\|tok:id::->\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs (ParamEmit.cpp, law pkgParamOwn |
| 28 | N0129 | 2 (2) | 2 | 2 | 15 | B | OPEN (map 8 ground-B step 8) | `fullname\|ref_typespec\|tok:->.id\|under:constant` | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldN |
| 29 | N0163 | 2 (3) | 2 | 2 | 5 | B | OPEN (map 8 ground-B step 10) | `fullname\|ref_typespec\|tok:id->id\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp, law enumAliasEndAtD |
| 30 | N0088 | 2 (1) | 2 | 0 | 4 | B | OPEN | `span\|ref_obj\|line+col+endline+endcol\|under:port` | emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInterfaceDef (ModuleEmit.cpp, law modportE |

### T1c. Per ground, all rows (top 25 each)

Ground A (ExprEmit / EmitHelpers / StmtEmit / ParamEmit):

| # | cluster | rows (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0001 | 14 (8) | 0 | 0 | 8 | A | OPEN (map 8 ground-A+B step 39) | `span\|ref_obj\|col+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPa |
| 2 | N0061 | 12 (7) | 0 | 0 | 8 | A | OPEN | `span\|bit_select\|col+endcol\|under:hier_path` | emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxDecompiled79) < emitExpr (ExprEmit.cpp, law thisPath |
| 3 | N0142 | 12 (7) | 0 | 0 | 0 | A | OPEN | `struct\|golden-only:fewer-copies\|range\|under:array_typespec` | makeUnpackedArrayParamTs (ParamEmit.cpp, law pkgParamTsRef) < emitParameters (ParamEmit.cpp, law imp |
| 4 | N0007 | 11 (6) | 0 | 0 | 6 | A | OPEN (map 8 ground-A+B step 15) | `fullname\|ref_obj\|golden-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPa |
| 5 | N0119 | 11 (6) | 0 | 0 | 2 | A | OPEN | `span\|bit_select\|col+endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law dynArrayNewLvalueBase |
| 6 | N0131 | 10 (5) | 4 | 2 | 5 | A | OPEN (one shape named by r11u178: pass 174 R1 FuncStructValS | `fullname\|ref_typespec\|ours-empty\|under:constant` | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law negLitPkgRetF |
| 7 | N0152 | 9 (5) | 0 | 0 | 71 | A | OPEN | `file\|begin\|ours-empty\|under:function` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualif |
| 8 | N0153 | 9 (5) | 0 | 0 | 71 | A | OPEN | `span\|begin\|ours-zero\|under:function` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualif |
| 9 | N0109 | 9 (5) | 0 | 0 | 6 | A | OPEN | `file\|string_typespec\|ours-empty\|under:ref_typespec` | operator() (StmtEmit.cpp, law classPropUnitImport21) < emitStmt (StmtEmit.cpp, law foreachLoopVarObj |
| 10 | N0110 | 9 (5) | 0 | 0 | 6 | A | OPEN | `span\|string_typespec\|ours-zero\|under:ref_typespec` | operator() (StmtEmit.cpp, law classPropUnitImport21) < emitStmt (StmtEmit.cpp, law foreachLoopVarObj |
| 11 | N0160 | 9 (5) | 0 | 0 | 6 | A | OPEN | `span\|ref_var\|endcol\|under:foreach_stmt` | emitStmt (StmtEmit.cpp, law foreachScopedArrayWrittenClassVar33) < emitStmt (StmtEmit.cpp, law inval |
| 12 | N0071 | 9 (5) | 0 | 0 | 4 | A | OPEN | `span\|hier_path\|endcol\|under:operation` | emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < emitExpr (ExprEmit.cpp, law incDecMemberPat |
| 13 | N0172 | 9 (5) | 0 | 0 | 4 | A | OPEN | `file\|begin\|ours-empty\|under:task` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualif |
| 14 | N0173 | 9 (5) | 0 | 0 | 4 | A | OPEN | `span\|begin\|ours-zero\|under:task` | emitStmt (StmtEmit.cpp, law thisSuperNewAssignNoStmt3) < emitTaskFuncs (TaskFuncEmit.cpp, law qualif |
| 15 | N0178 | 9 (5) | 0 | 0 | 3 | A | OPEN | `file\|begin\|ours-empty\|under:if_stmt` | emitStmt (StmtEmit.cpp, law parBlockJoinTailAfterFirstItem131) < emitStmt (StmtEmit.cpp, law invalid |
| 16 | N0179 | 9 (5) | 0 | 0 | 3 | A | OPEN | `span\|begin\|ours-zero\|under:if_stmt` | emitStmt (StmtEmit.cpp, law parBlockJoinTailAfterFirstItem131) < emitStmt (StmtEmit.cpp, law invalid |
| 17 | N0187 | 9 (5) | 0 | 0 | 2 | A | OPEN | `span\|func_call\|endcol\|under:bit_select` | emitExpr (ExprEmit.cpp, law defGenQualPkgCallBinds18) < emitMixedHierPath (ExprEmit.cpp, law hpMidSe |
| 18 | N0185 | 9 (5) | 0 | 0 | 1 | A | OPEN | `span\|constant\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < operator() (StmtEmit.cpp, law declInitWrittenNewNoStmt |
| 19 | N0193 | 9 (5) | 0 | 0 | 1 | A | OPEN | `span\|hier_path\|endcol\|under:return_stmt` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law shellCallKeepsItsSynt |
| 20 | N0196 | 9 (5) | 0 | 0 | 1 | A | OPEN | `fullname\|ref_obj\|tok:id.id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law cloneBuiltinMet |
| 21 | N0197 | 9 (5) | 0 | 0 | 1 | A | OPEN | `struct\|golden-only:fewer-copies\|string_typespec\|under:ref_typespec` | operator() (StmtEmit.cpp, law foreachAssocIdxAliasTs22) < emitStmt (StmtEmit.cpp, law foreachLoopVar |
| 22 | N0199 | 9 (5) | 0 | 0 | 1 | A | OPEN | `fullname\|bit_select\|tok:id.id::->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law cloneBuiltinMethodArg |
| 23 | N0207 | 9 (5) | 0 | 0 | 1 | A | OPEN | `fullname\|ref_obj\|tok:::->.\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law genCaSysCallArgBinds22) < emitExpr (ExprEmit.cpp, law incDecMemberPathIs |
| 24 | N0054 | 9 (5) | 0 | 0 | 0 | A | OPEN | `span\|assignment\|endcol\|under:begin` | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCo |
| 25 | N0123 | 9 (5) | 0 | 0 | 0 | A | OPEN | `file\|int_typespec\|other-file+span\|under:ref_typespec` | makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator() (ParamEmit.cpp, law pkgUntyp |

Ground B (TypeEmit / ModuleEmit / UhdmExporter / TaskFuncEmit / uhdm_main):

| # | cluster | rows (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0031 | 15 (8) | 0 | 0 | 13 | B | OPEN | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExpo |
| 2 | N0043 | 14 (8) | 4 | 0 | 5 | B | OPEN (map 8 ground-B step 12) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpClon |
| 3 | N0067 | 13 (7) | 2 | 0 | 47 | B | OPEN (map 8 ground-A+B step 35) | `file\|class_typespec\|ours-empty\|under:ref_typespec` | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fix |
| 4 | N0072 | 13 (7) | 2 | 0 | 8 | B | OPEN (map 8 ground-B step 1) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneD |
| 5 | N0068 | 13 (7) | 0 | 0 | 47 | B | OPEN (map 8 ground-A+B step 35) | `span\|class_typespec\|ours-zero\|under:ref_typespec` | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fix |
| 6 | N0042 | 13 (7) | 0 | 0 | 10 | B | OPEN | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExpo |
| 7 | N0056 | 11 (6) | 2 | 2 | 1 | B | OPEN (map 8 ground-B step 3) | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (Uhd |
| 8 | N0103 | 11 (6) | 0 | 0 | 7 | B | OPEN (map 8 ground-A+B step 14) | `name\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneD |
| 9 | N0116 | 11 (6) | 0 | 0 | 2 | B | OPEN (map 8 gave it to r11u164) | `span\|class_typespec\|col+endcol\|under:ref_typespec` | emitClassTsParams (UhdmExporter.cpp, law builtinClassLocalUnsupportedBeforeClassPhase115) < makeType |
| 10 | N0039 | 10 (7) | 0 | 0 | 156 | B | OPEN (map 8 ground-A+B step 35) [r11u175: rows 12->10] | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law implicitArgDimsInner155) < emitTaskFuncs (TaskFuncEmit.cpp, law impC |
| 11 | N0127 | 10 (6) | 0 | 0 | 79 | B | OPEN | `span\|array_typespec\|endcol\|under:ref_typespec` | makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDimOvrChain4) < emitPorts (ModuleEmit.cpp, law ifaceIf |
| 12 | N0128 | 10 (6) | 0 | 0 | 69 | B | OPEN | `span\|range\|col+endcol\|under:array_typespec` | operator() (ModuleEmit.cpp, law sizeDimOvrChain4) < makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDi |
| 13 | N0164 | 9 (5) | 6 | 0 | 5 | B | OPEN (map 8 gave it to r11u164) | `fullname\|ref_typespec\|tok:id::id::id::id::->\|under:bit_typespec` | bareScalarTdCopyOf (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52) < operator() (TypeEmit.cpp, la |
| 14 | N0040 | 9 (5) | 2 | 0 | 34 | B | OPEN (map 8 ground-A+B step 29) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law |
| 15 | N0051 | 9 (5) | 0 | 0 | 9 | B | OPEN (map 8 gave it to r11u164) | `span\|class_typespec\|endcol\|under:ref_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (Uh |
| 16 | N0132 | 9 (5) | 0 | 0 | 7 | B | OPEN (map 8 gave it to r11u164) | `span\|int_typespec\|line+endline\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitClassParameters (UhdmExporter.cpp, la |
| 17 | N0161 | 9 (5) | 0 | 0 | 6 | B | OPEN (map 8 gave it to r11u164) | `fullname\|ref_typespec\|tok:id::->\|under:class_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law sharedAliasNoStamp41) < makeTypespec (TypeEmit.cpp, law c |
| 18 | N0162 | 9 (5) | 0 | 0 | 6 | B | OPEN (map 8 gave it to r11u164) | `span\|string_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law unsignedScalarVecTsAtKeyword137) < emitImportedPkgVarNets (ModuleEmi |
| 19 | N0171 | 9 (5) | 0 | 0 | 6 | B | OPEN (map 8 gave it to r11u164) | `struct\|golden-only:fewer-copies\|bit_typespec\|under:ref_typespec` | namedElemPackedDimTs31 (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypeParamDefaultTs (TypeEmit |
| 20 | N0170 | 9 (5) | 0 | 0 | 5 | B | OPEN (map 8 gave it to r11u164) | `span\|class_var\|col+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitPackageClass |
| 21 | N0757 | 9 (5) | 0 | 0 | 4 | B | OPEN (map 8 gave it to r11u164) | `span\|typespec_member\|endcol\|under:struct_typespec` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTypedefs (TypeEmit.cpp, law  |
| 22 | N0180 | 9 (5) | 0 | 0 | 3 | B | OPEN (map 8 gave it to r11u164) | `fullname\|ref_typespec\|ours-empty\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law classPkgGeneric |
| 23 | N0158 | 9 (5) | 0 | 0 | 2 | B | OPEN (map 8 gave it to r11u164) | `depth\|bit_typespec\|ref_typespec->ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |
| 24 | N0168 | 9 (5) | 0 | 0 | 2 | B | OPEN (map 8 gave it to r11u164) | `span\|int_typespec\|col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitClassParameters (UhdmExporter.cpp, la |
| 25 | N0177 | 9 (5) | 0 | 0 | 2 | B | OPEN (map 8 gave it to r11u164) | `struct\|ours-only:absent\|bit_typespec\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |

Probe-only OPEN clusters with the most cases after r11u175: N1897 (119, B: `fullname|logic_net|tok:.id@id->|under:module_inst`,
laws caNestedModPortedDefShell101 / caTopNamesakeKeyAtEntry105), N1898 (92, B), N1899 (52, B), N1900 (50, B), N1901
(45, B), N1902 (37, A), N0739 (27, A), N1903 (21, A), N1904 (20, A), N1905 (17, B), N1907 / N1910 / N1911 (14 each, B),
N1909 (14, A) ([evidence/report.txt](evidence/report.txt) section 4). Laws with the most NE cases:
badConcatOperandsFromSyntax160 71/71, caNestedModPortedDefShell101 36/38, portViewRangeRecvParams 34/55,
srlgCondOpInstValueTernFold9 32/140, nestedParamActualTs6 29/41, tpPackedArrayTsVar108 29/73.
The probe cases by first cluster:

| first cluster | probe cases it heads | clears (r11u175 / pairs) | ground | status | key | top laws |
|---|---|---|---|---|---|---|
| N1897 | 106 | no 106 | B | OPEN | `fullname\|logic_net\|tok:.id@id->\|under:module_inst` | caNestedModPortedDefShell101:36 caTopNamesakeKeyAtEntry105:26 caNested |
| N0127 | 78 | no 78 | B | OPEN | `span\|array_typespec\|endcol\|under:ref_typespec` | portViewRangeRecvParams:34 sizeDimOvrChain4:24 ifaceArrayElemViewFolds |
| N0039 | 72 | no 72 | B | OPEN (map 8 ground-A+B step 35) [r11u175: rows 12- | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | badConcatOperandsFromSyntax160:57 nestedParamActualTs6:22 classNestedT |
| N0151 | 68 | no 61, yes pair B 7 | B | COVERED r11u176 (r11u175 F2 residue: the import-pa | `struct\|golden-only:fewer-copies\|ref_typespec\|under:parameter` | badConcatOperandsFromSyntax160:66 impFoldRhsMirrorsLhsTs201:7 impUnsiz |
| N0263 | 54 | no 54 | B | OPEN | `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` | caIfacePortDeclNetMint93:26 tpPackedArrayTsVar108:5 tpPackedArrayTsVar |
| N0284 | 44 | no 44 | B | OPEN | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` | srlgUnvaluedActualLitRetFold8:19 loopCaParamReadKeepsLiteral116:10 caS |
| N0067 | 42 | no 42 | B | OPEN (map 8 ground-A+B step 35) | `file\|class_typespec\|ours-empty\|under:ref_typespec` | foreachLoopListStopsAtFirstSelect134:4 thisSuperNewAssignEmpty121:4 wi |
| N0003 | 35 | no 34, yes pair A 1 | A | COVERED r11u178 (map 8 joint: StructParamPatternIn | `fullname\|ref_typespec\|golden-empty\|under:operation` | patParamEvalFuncRead26:13 patParamLeftoverShare26:7 memLeftStampOwnTyp |
| N0040 | 28 | no 28 | B | OPEN (map 8 ground-A+B step 29) | `span\|logic_typespec\|endcol\|under:ref_typespec` | nestedParamActualTs6:18 caIfaceNdaNameFoldsToParamValue88:5 caIfaceEla |
| N0738 | 27 | no 27 | B | OPEN (map 8 ground-A+B step 22) | `name\|logic_typespec\|tok:id::->\|under:ref_typespec` | pkgTdQualParamCopiesListing111:11 defPkgMemberTdOfNamedShares108:8 pkg |
| N0739 | 26 | no 26 | A | OPEN | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | pkgRhsStructBareCopy111:14 defPkgMemberTdOfNamedShares108:11 tpPackedA |
| N0474 | 25 | yes pair A 25 | A | COVERED r11u178 (map 8 joint: ibex_icache's consta | `fullname\|ref_typespec\|tok:->.id[n]\|under:constant` | genCaOpFoldElabTs115:16 caSysArgOpFoldTs115:5 genCaTopLoopParamPaCopy1 |
| N1169 | 23 | no 23 | B | OPEN | `file\|constant\|ours-empty\|under:cont_assign` | srlgCondOpInstValueTernFold9:22 caTernFillArmKeepsEncoding19:1 |
| N0154 | 19 | yes r11u175 18, no 1 | B | COVERED r11u175 (law patches, MEASURED: gone under | `span\|int_var\|line+col+endline+endcol\|under:function` | pkgVarInitCmViewClone111:5 classTdLocalVarKindFollowsCompileOrder10:3  |
| N0264 | 17 | no 17 | B | OPEN (map 8 gave it to r11u164) | `span\|int_typespec\|endcol\|under:ref_typespec` | interfaceDefViewNeverLateBinds223v:6 importedFreeCallTakesFirstListing |
| N0093 | 16 | yes r11u175 15, no 1 | B | COVERED r11u175 (law patches, MEASURED: gone under | `span\|io_decl\|line+col+endline+endcol\|under:function` | classArgBind12:5 oobClassTypeParamPlaceholderPerView213:4 instanceIsNe |
| N0443 | 15 | no 15 | A | OPEN (map 8 ground-A+B step 33) | `fullname\|ref_typespec\|tok:.id.id->\|under:constant` | genLpIdxOpOperandFold112:12 genElseArmCollapse48:1 genCaNestedModuleLh |
| N0129 | 14 | no 14 | B | OPEN (map 8 ground-B step 8) | `fullname\|ref_typespec\|tok:->.id\|under:constant` | genCaOpFoldElabTs115:6 insideSetFirstRangeTruncates99:2 genCaUnboundTe |
| N1911 | 14 | no 14 | B | OPEN | `fullname\|type_parameter\|tok:->id::@in-typespec\|under:class_typespec` | classTdCloneSpecOverridesOwnArgs112:14 |
| N0682 | 12 | no 12 | A | OPEN | `fullname\|ref_typespec\|tok:->id::\|under:parameter` | impFoldRhsMirrorsLhsTs201:7 unitImportHoistsPkgParams146:3 impUnsizedB |
| N1916 | 12 | no 12 | B | OPEN | `struct\|golden-only:fewer-copies\|logic_net\|under:cont_assign` | caIfaceNdaNameFoldsToParamValue88:9 caIfaceElabNetDeclAssignListing88: |
| N0095 | 11 | yes r11u175 8, no 3 | A | COVERED r11u175 (law patches, MEASURED: gone under | `fullname\|ref_obj\|tok:id.id::->\|under:method_func_call` | classInBodyRecvCallArgNoBind52:3 shellCallKeepsItsSyntax167:2 oobRefVa |
| N0485 | 11 | no 11 | B | OPEN (map 8 gave it to r11u164) | `fullname\|int_var\|tok:id->id\|under:function` | pkgVarInitCmViewClone111:5 cloneBodyIsAScopeEvenWithNoOwnLocals181:3 c |
| N0473 | 11 | no 8, yes r11u175 3 | A | OPEN [r11u175: rows 4->0] | `struct\|golden-only:fewer-copies\|int_var\|under:begin` | importedFreeCallTakesFirstListingImport227:5 retNameSelBindsHomeReturn |
| N1921 | 9 | no 9 | B | OPEN | `span\|int_var\|col+endcol\|under:function` | tfItemLocalInitHoistsNoStatement145:4 tfItemTaskParamBreaksTheWalk145v |

## 7. The fail list with sites (fail_list.csv, probe_fail_list.csv)

Every STRICT_NOTEQUAL row-mode with its first cluster (at 5e8d08d9), that cluster's coverage, ground and site, all its
clusters, the strict cell after r11u175, its first OPEN cluster after the pairs, the open clusters left and whether it
clears (r11u175 measured / pair A / pair B / both, optimistic). probe_fail_list.csv is the same per probe case (1291).
By test, sorted by cluster count (a `-` mode is not NE):

| corpus | test | cell d / t | clusters d/t | first cluster (ground) | first site | after r11u175 | first open after the pairs | open after pairs | clears | downstream |
|---|---|---|---|---|---|---|---|---|---|---|
| sur | CovMacro | differ:fullname(8) / differ:fullname(8) | 1/1 | N0977 (A) | buildDottedHierPath (ExprEmit.cpp, law hpIdxClassBodyNeverLateBinds143 | same | - | 0/0 | yes (pair A, optimistic) | - |
| sur | HierPathTypespec | - / differ:fullname(1) | -/1 | N1174 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | N1174 | -/1 | no | - |
| sur | InterfArrayBind | differ:fullname(3) / - | 1/- | N0427 (A) | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp, law genCaParamFo | same | - | 0/- | yes (pair A, optimistic) | - |
| sur | LocalScopeHierPath | - / differ:fullname(1) | -/1 | N0278 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitMixedHierPa | same | - | -/0 | yes (pair A, optimistic) | - |
| sur | PackedArrayHighConn | differ:fullname(5) / differ:fullname(5) | 1/1 | N0163 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (Para | same | N0163 | 1/1 | no | - |
| sur | PreprocTest | differ:endcol(2) / differ:endcol(2) | 1/1 | N0056 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (Para | same | N0056 | 1/1 | no | - |
| sur | YosysRiscv | differ:col(40) / differ:col(40) | 1/1 | N0036 (A) | emitExpr (ExprEmit.cpp, law ifaceMemberTrailIdxNamesByPath147) < emitE | same | - | 0/0 | yes (pair A, optimistic) | - |
| sur | StructParamPatternInitCast | differ:fullname(3) / differ:fullname(3) | 2/2 | N0003 (A) | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitIn | same | N0014 | 1/1 | no | - |
| sur | UnitElabBlock | differ:endline(13) / differ:endline(12) | 3/2 | N0090 (B) | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduc | same | N0090 | 3/2 | no | - |
| sur | ArrayMethodIterator | differ:name(6) / differ:name(16) | 3/3 | N0103 (B) | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (T | same | N0072 | 2/2 | no | - |
| sur | OneNetModPort | differ:file(3) / differ:file(3) | 3/3 | N0418 (B) | emitPorts (ModuleEmit.cpp, law caIfacePortDeclNetMint93) < emitModuleD | same | N0418 | 3/3 | no | - |
| sur | UnsizedParam | differ:fullname(2) / - | 3/- | N0457 (B) | emitExpr (ExprEmit.cpp, law packageVarAutomaticIsDataDeclShape26) < em | same | - | 0/- | yes (pair B, optimistic) | - |
| sur | AssertDelayError | differ:fullname(48) / differ:fullname(66) | 4/5 | N0627 (B) | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDe | same | N0627 | 4/5 | no | - |
| sur | AssertTempError | differ:fullname(28) / differ:fullname(38) | 4/5 | N0627 (B) | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDe | same | N0627 | 4/5 | no | - |
| sur | FuncStructValSimple | differ:file(40) / differ:file(60) | 4/4 | N0086 (A) | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) <  | same | N0131 | 1/1 | no | - |
| sur | LogicTypespec | differ:endline(3) / differ:endline(3) | 4/4 | N0422 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage ( | same | N0422 | 4/4 | no | - |
| sur | InterfaceModPort | differ:endcol(15) / differ:endcol(15) | 5/5 | N0040 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedP | same | N0040 | 5/5 | no | - |
| sur | InterfaceStructMemberPort | differ:fullname(6) / differ:fullname(6) | 5/5 | N1134 (B) | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) < emitInst | same | N1134 | 5/5 | no | - |
| sur | OneNetModPortGeneric | differ:line(2) / differ:line(2) | 5/5 | N0088 (B) | emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInterfaceDef | same | N0088 | 5/5 | no | - |
| sur | ClassTypeParam | differ:endline(17) / differ:file(30) | 8/10 | N1081 (B) | exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < m | same | N1081 | 8/10 | no | - |
| sur | FuncStructVal | differ:endcol(95) / differ:endcol(177) | 8/10 | N1096 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprE | same | N0131 | 2/3 | no | - |
| sur | ApbSlave | differ:depth(1) / differ:depth(1) | 16/16 | N0289 (B) | makeVar (TypeEmit.cpp, law tpPackedArrayTsVarInit110) < emitPackageVar | same | N0289 | 4/4 | no | - |
| sur | SVSwitch | differ:fullname(11) / differ:fullname(11) | 17/17 | N0095 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprE | differ:file(9) / differ:file(9) | N0067 | 16/16 | no | - |
| sur | Scr1SvTests | differ:type(1) / differ:type(1) | 23/23 | N0965 (A) | emitExpr (ExprEmit.cpp, law pkgQualParamPartSelName118) < emitExpr (Ex | same | N0448 | 21/21 | no | - |
| sur | BlackBePipeInt | differ:fullname(2) / differ:fullname(2) | 28/26 | N0923 (A) | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefModuleCopy) | same | N0923 | 27/25 | no | - |
| sur | Rggen | differ:fullname(7) / - | 56/- | N0163 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (Para | same | N0163 | 54/- | no | - |
| sur | Earlgrey_0_1 | differ:fullname(436) / differ:fullname(436) | 80/85 | N0163 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (Para | same | N0163 | 75/79 | no | - |
| sur | BuildUVMPkg | differ:line(94) / differ:line(94) | 167/167 | N0080 (B) | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPack | differ:line(69) / differ:line(69) | N0164 | 114/114 | no | - |
| sur | Scoreboard | differ:fullname(45) / - | 200/- | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitPackage (P | differ:fullname(42) / - | N0682 | 137/- | no | - |
| sur | SimpleUVM | differ:fullname(45) / differ:fullname(45) | 210/210 | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitPackage (P | differ:fullname(42) / differ:fullname(42) | N0682 | 144/144 | no | - |
| sur | SeqDriver | differ:file(29) / differ:file(29) | 354/354 | N0144 (B) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (P | differ:file(26) / differ:file(26) | N0164 | 240/240 | no | - |
| sur | MiniAmiq | differ:file(29) / differ:file(29) | 370/370 | N0144 (B) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (P | differ:file(26) / differ:file(26) | N0164 | 247/247 | no | - |
| uhd | anon_struct_packed_dim | differ:fullname(43) / differ:fullname(43) | 2/2 | N0014 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | N0014 | 2/2 | no | IDENTICAL |
| uhd | func_typename_ret | differ:name(2) / differ:name(2) | 2/2 | N0738 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs ( | same | N0738 | 2/2 | no | IDENTICAL |
| uhd | ibex_multdiv_fast | differ:file(11) / differ:file(11) | 2/2 | N0545 (A) | emitExpr (ExprEmit.cpp, law uninstIfaceEnumConstNoActual221) < emitExp | same | - | 0/0 | yes (pair A, optimistic) | IDENTICAL |
| uhd | iface_zero_width_field | differ:fullname(4) / differ:fullname(4) | 2/2 | N0003 (A) | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitIn | same | N0688 | 1/1 | no | IDENTICAL |
| uhd | jeras_union | differ:fullname(75) / differ:fullname(75) | 2/2 | N0938 (A) | emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesi | same | N0938 | 2/2 | no | IDENTICAL |
| uhd | mem_read_reg | differ:name(5) / differ:name(5) | 2/2 | N0805 (B) | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPack | same | N0805 | 2/2 | no | IDENTICAL |
| uhd | TypeParameterAsPortTypeWithEnum | differ:file(8) / differ:file(8) | 3/3 | N0012 (A) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters | same | - | 0/0 | yes (pair A, optimistic) | IDENTICAL |
| uhd | const_cast_signext | differ:line(5) / differ:line(5) | 3/3 | N0043 (B) | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeType | same | N0043 | 3/3 | no | IDENTICAL |
| uhd | rsp_gen_minimal | differ:fullname(2) / differ:fullname(2) | 3/3 | N0416 (A) | emitExpr (ExprEmit.cpp, law packageVarAutomaticIsDataDeclShape26) < em | same | N0416 | 3/3 | no | IDENTICAL |
| uhd | OutputSizeWithParameterOfInstanceInitializedByStructMember | differ:line(8) / differ:line(8) | 4/4 | N0191 (A) | emitDroppedCall14 (StmtEmit.cpp, law classArgBind12) < emitBadConcatFr | same | N0191 | 4/4 | no | IDENTICAL |
| uhd | TypeParameterAsPortTypeWithEnumOfParametrizedWidth | differ:file(6) / differ:file(6) | 4/4 | N0012 (A) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters | same | - | 0/0 | yes (pair A, optimistic) | IDENTICAL |
| uhd | arb_idx_cast | differ:endcol(17) / differ:endcol(17) | 4/4 | N0448 (B) | operator() (TypeEmit.cpp, law shadowedImportParamFold) < makeTypespec  | same | N0448 | 4/4 | no | IDENTICAL |
| uhd | ibex_icache | differ:fullname(49) / differ:fullname(49) | 5/5 | N0415 (A) | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitExpr (ExprEmit | same | N0129 | 1/1 | no | IDENTICAL |
| uhd | ibex_tracer | differ:fullname(579) / differ:fullname(579) | 6/6 | N0563 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | N0563 | 5/5 | no | IDENTICAL |
| uhd | cfg_func_width_loop | differ:line(3) / differ:line(3) | 7/7 | N0263 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespe | same | N0263 | 7/7 | no | IDENTICAL |
| uhd | ibex_pmp | differ:file(15) / differ:file(15) | 7/7 | N0219 (B) | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPack | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | int_types | differ:fullname(82) / differ:fullname(82) | 8/8 | N0912 (B) | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < operator() | same | N0912 | 8/8 | no | IDENTICAL |
| uhd | struct_param_func_config | differ:line(8) / differ:line(8) | 8/8 | N0043 (B) | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeType | same | N0043 | 8/8 | no | IDENTICAL |
| uhd | ParameterFromPkgInNestedModule | differ:fullname(7) / differ:fullname(7) | 10/10 | N0536 (A) | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitContAssigns (M | same | N0679 | 9/9 | no | IDENTICAL |
| uhd | ParameterFromPkgOnParameterPortList | differ:fullname(7) / differ:fullname(7) | 10/10 | N0536 (A) | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitContAssigns (M | same | N0679 | 9/9 | no | IDENTICAL |

## 8. Structural rows and downstream-visible faces

### 8a. Structural rows (first field depth / type / count)

| row | 5e8d08d9 | after r11u175 | first cluster | what it needs |
|---|---|---|---|---|
| ApbSlave d/t | `depth(1)` | `depth(1)` | N0289 `struct\|ours-only:fewer-copies\|string_var\|under:ref_obj` (B; TypeEmit `makeVar` < ParamEmit `emitPackageVar`) | map 8 5a: the svunit_pkg #372 divergence (ours binds `svunit_version` to the package `string_var` and lists it). Not decoded; no landed or unlanded law covers it. r11u175 clears 12 of ApbSlave's 16 clusters (order-blind 88 -> 12); after it ApbSlave carries N0067 + N0068 + N0162 + N0289 |
| Scr1SvTests d/t | `type(1)` | `type(1)` | N0965 `struct\|golden-only:fewer-copies\|ref_typespec\|under:indexed_part_select` (A) | pass 171 R3: golden's call argument `din[(i+1)*2-1-:2]` carries the called formal's typespec (Surelog `compileTfCallArgs`); pair A r11u178's brief. Behind it 22 more clusters (N0284's `assign` constant, N0448, the `other-file` operations N1009/N1112/N1113 ...) |

No row is `count` or `stage1`. The probe set holds 102 `type` and 91 `depth` first fields at 5e8d08d9 (heads: N0284 44
type, N0151 68 depth, N0473 11, N1916 12), and 76 `type` / 103 `depth` after r11u175 (net: 26 fewer `type` heads, mostly
the importer-clone locals N0473 / N0489 / N0497 / N0501 the F2 law now copies; 12 more cases reach a `depth` record
further down the walk).

### 8b. Downstream-visible faces ([drivers/dsfaces.py](drivers/dsfaces.py): the gate's own `one()`, fresh `GOLDEN_CACHE`, both binaries; [evidence/sweeps/dsfaces_P.csv](evidence/sweeps/dsfaces_P.csv), [dsfaces_L.csv](evidence/sweeps/dsfaces_L.csv))

**No verdict differs between the pristine and the law175 binary on any of the 59 cases**, and no corpus row changes
verdict (section 3).

| face | cases | verdict at 5e8d08d9 (= law175) | what it needs |
|---|---|---|---|
| r11u173 N1: a range query onto an implicit net in a generate-for (`assign ccc = $high(a)`) | r11u173verify/cases/rq/q08 (q03 the declared-net control) | **q08 DIVERGENT** (nohier il synth: golden folds `$high` to `UINT:4`, the Surelog lane `connect \g[0].ccc 1'0`, ours keeps the sys_func_call, `1'1`); q03 IDENTICAL | ModuleEmit's generate-scope cont_assign emission (emitGenScopes) has no sysFold branch; pass 164's law rangeQueryFoldUnconverted164 does not reach it (ground B) |
| r11u173 N2: `g[S.a].x`, a hier path into a generate array indexed by a struct-parameter member | r11u173verify/cases/hw/w13 (w12 with blanks) | **w12, w13 DIVERGENT** (stage 1 as well; golden's lane `connect \y \g[1].x`, ours `1'x`) | the index fold of a struct-parameter member inside a hier_path (ExprEmit path builders, ground A); not decoded |
| pass 158: the size cast as a whole continuous-assign value | r11u158repro/cases/sc c1-c17 | 15 IDENTICAL; **c10 EQUIVALENT** (nohier il), **c12 EQUIVALENT** (nohier) | c10 = pass 158 S2 (a gen-if `3'(-1)`: golden folds to `UINT:7`, ModuleEmit emitBlock's gen-CA branch); c12 = S3 (an instance-overridden width `W'(7)`, ModuleEmit emitContAssigns). Unchanged since map 8 |
| pass 160: the LogicTypespec Surelog-defect candidate | r11u160repro/evidence/residue/LT l01, l02 (run from scratch copies) | l01 IDENTICAL; **l02 DIVERGENT** (`$bits(x)` 2 on the Surelog lane, 32 on ours) | golden binds `my_package::t2 [1:0][7:0] x` to the package typedef and drops the written dims; following it changes a netlist toward a Surelog defect: a user decision (LogicTypespec d/t stay in the fail list, greedy B step 12) |
| r11u171 / v11u171 R4: the UDP-form swallow on a non-lvalue first concatenation | v11u171repro/cases/Q c01-c14 | **c07, c12 EQUIVALENT** (nohier il synth); c02, c08, c14 EQUIVALENT too (c02, c14: nohier il; c08: nohier il synth); the other 9 IDENTICAL | law udpSwallowLvalueOnly171v's net_lvalue rule applied to the late wrap too (ModuleEmit emitInstance, ground B: pair B's brief) |
| r11u161: the non-package enum alias width | r11u161gen/cases/al e01-e18 | 17 IDENTICAL (map 8 read 11 DIVERGENT at f2f2d30b: pass 164 landed law enumAliasClone161); e15 (the packed-dim control) DIVERGENT, as in map 8 | done |
| r11u162 N2: the macro-expanded interface-member connection | r11u166mac/cases/ds c05, c08 | IDENTICAL (map 8: EQUIVALENT; pass 168 landed law macroConnInRange166) | done |
| r11u162 N1: blanks inside a dotted path | r11u166mac/cases/ds l06, p04 | l06 STATUS_DIFF (slang lane READ_FAIL, Surelog lane NO_GATES); **p04 IDENTICAL** (map 8: STATUS_DIFF; pass 167's law hpDotWsTrimmed167) | l06: ExprEmit's text-splitting path builders (r11u173 N4 for the generate-target route, TypeEmit) |

## 9. The per-ground briefs (on top of r11u175 measured + both pairs optimistic)

The base is 15 row-modes / 9 tests cleared. **The remaining 83 row-modes carry**: by open-cluster count, 1: 13, 2: 12,
3: 8, 4: 10, 5: 10, 6 or more: 30; by ground, A only 2, B only 33, both 35, with a key new under the patches or an
unpinned cluster 13 (the UVM rows and their neighbours). Every OPEN cluster of ground A (219) clears only 2 row-modes
alone (17 with the pairs); every OPEN cluster of ground B (308) clears 33 (48). **Most rows now end on ground B**; the
joint list plans two refills. A candidate is the whole open-cluster set of one remaining row (<= 4 clusters one ground,
<= 6 joint); the greedy picks by row-modes cleared per cluster added ([evidence/report.txt](evidence/report.txt) section 8,
[evidence/greedy9.json](evidence/greedy9.json)).

**Ground A (the next pair-A refill, after r11u178).**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0131 | 2 | 17 | FuncStructValSimple/d FuncStructValSimple/t | A | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law negLitPkgRetFoldNested3 |

**Ground B (the next pair-B refill, after r11u176).**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0056 | 2 | 17 | PreprocTest/d PreprocTest/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 2 | N0014 | 2 | 19 | StructParamPatternInitCast/d StructParamPatternInitCast/t | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPacke |
| 3 | N0163 | 2 | 21 | PackedArrayHighConn/d PackedArrayHighConn/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp, law enumAliasEndAtDimOrInitDe |
| 4 | N0129 | 2 | 23 | ibex_icache/d/u2r ibex_icache/t/u2r | B | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < |
| 5 | N0688 | 2 | 25 | iface_zero_width_field/d/u2r iface_zero_width_field/t/u2r | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonA |
| 6 | N0072 + N0103 | 2 | 27 | ArrayMethodIterator/d ArrayMethodIterator/t | B | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNo |
| 7 | N0804 + N0805 | 2 | 29 | mem_read_reg/d/u2r mem_read_reg/t/u2r | B | exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeep |
| 8 | N1174 | 1 | 30 | HierPathTypespec/t | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp,  |
| 9 | N0043 + N0133 + N0487 | 2 | 32 | const_cast_signext/d/u2r const_cast_signext/t/u2r | B | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWholeLhsB |
| 10 | N0268 + N0418 + N0419 | 2 | 34 | OneNetModPort/d OneNetModPort/t | B | makeVar (TypeEmit.cpp, law pkgScopedPortAnyDirVar77) < emitInterfaceInstance (ModuleEmit.cpp, law defNetEndOnl |
| 11 | N0067 + N0068 + N0162 + N0289 | 2 | 36 | ApbSlave/d ApbSlave/t | B | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPro |
| 12 | N0083 + N0422 + N0484 + N1149 | 2 | 38 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |

**Joint (both grounds), the order that converts the most rows per cluster.**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0014 + N0820 | 4 | 19 | StructParamPatternInitCast/d StructParamPatternInitCast/t anon_struct_packed_dim/d/u2r anon_struct_packed_dim/t/u2r | A+B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < operator() (TypeEmit.cpp, law anonPacke |
| 2 | N0056 | 2 | 21 | PreprocTest/d PreprocTest/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 3 | N0131 | 2 | 23 | FuncStructValSimple/d FuncStructValSimple/t | A | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitStmt (StmtEmit.cpp, law negLitPkgRetFoldNested3 |
| 4 | N0163 | 2 | 25 | PackedArrayHighConn/d PackedArrayHighConn/t | B | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp, law enumAliasEndAtDimOrInitDe |
| 5 | N0129 | 2 | 27 | ibex_icache/d/u2r ibex_icache/t/u2r | B | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < |
| 6 | N0688 | 2 | 29 | iface_zero_width_field/d/u2r iface_zero_width_field/t/u2r | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonA |
| 7 | N0072 + N0103 | 2 | 31 | ArrayMethodIterator/d ArrayMethodIterator/t | B | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneDeclRangeNo |
| 8 | N0031 + N0938 | 2 | 33 | jeras_union/d/u2r jeras_union/t/u2r | A+B | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp,  |
| 9 | N0043 + N0891 | 2 | 35 | FuncStructVal/d FuncStructVal/t | B | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < makeTypespec (TypeEmit.cpp, law tpCloneWholeLhsB |
| 10 | N0133 + N0487 | 2 | 37 | const_cast_signext/d/u2r const_cast_signext/t/u2r | B | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law unnamedConcatIf |
| 11 | N0085 + N0738 | 2 | 39 | func_typename_ret/d/u2r func_typename_ret/t/u2r | A+B | makeParamTs (ParamEmit.cpp, law pkgParamOwnDefRange) < drainDefParamTs (ParamEmit.cpp, law paramCloneImportedC |
| 12 | N0804 + N0805 | 2 | 41 | mem_read_reg/d/u2r mem_read_reg/t/u2r | B | exportDesign (UhdmExporter.cpp, law importedClassTsRideTheFileUnit206) < main (uhdm_main.cpp, law genCaPatKeep |
| 13 | N1174 | 1 | 42 | HierPathTypespec/t | B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp,  |
| 14 | N0040 + N0268 + N0418 + N0419 + N0526 | 4 | 46 | InterfaceModPort/d OneNetModPort/d InterfaceModPort/t OneNetModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 15 | N0299 + N0431 + N0627 + N0628 + N1047 | 4 | 50 | AssertDelayError/d AssertTempError/d AssertDelayError/t AssertTempError/t | A+B | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law memberActualLeak) < emitCon |
| 16 | N0011 + N0016 + N0090 | 2 | 52 | UnitElabBlock/d UnitElabBlock/t | A+B | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cp |
| 17 | N0443 + N0448 + N0684 | 2 | 54 | arb_idx_cast/d/u2r arb_idx_cast/t/u2r | A+B | genLpUseFoldBound47 (ExprEmit.cpp, law genLpUseFoldParentScope47) < emitExpr (ExprEmit.cpp, law genCaSysCallAr |
| 18 | N0022 + N0023 + N0416 | 2 | 56 | rsp_gen_minimal/d/u2r rsp_gen_minimal/t/u2r | A+B | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < |
| 19 | N0067 + N0068 + N0162 + N0289 | 2 | 58 | ApbSlave/d ApbSlave/t | B | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassDefn (UhdmExporter.cpp, law fixedClassPro |
| 20 | N0001 + N0191 + N0853 + N1127 | 2 | 60 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | A+B | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue |
| 21 | N0083 + N0422 + N0484 + N1149 | 2 | 62 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |
| 22 | N0088 + N0750 + N0819 + N1000 | 2 | 64 | OneNetModPortGeneric/d OneNetModPortGeneric/t | B | emitPorts (ModuleEmit.cpp, law ifaceIfaceTypedPort) < emitInterfaceDef (ModuleEmit.cpp, law modportExprPort) < |
| 23 | N0563 + N0763 + N0957 + N0971 + N0979 | 2 | 66 | ibex_tracer/d/u2r ibex_tracer/t/u2r | A+B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonA |
| 24 | N0519 + N1117 + N1126 + N1128 + N1134 | 2 | 68 | InterfaceStructMemberPort/d InterfaceStructMemberPort/t | B | UHDM library DeepClone < DeepClone < DeepCopy (--elabuhdm, testflags) run from main (uhdm_main.cpp) |

In short:

* **Expression/parameter ground (after r11u178).**
  1. **N0131** (`fullname|ref_typespec|ours-empty|under:constant`, ExprEmit emitExpr): FuncStructValSimple d/t's last
     cluster (pass 174 R1's `#129`: a whole-formal leftover whose reference stores the formal type's package,
     `cva6_config_pkg`, when the function sits in another package, law memLeftFormalReadTs18's `tsPrefix`); with N0891
     (B) it clears FuncStructVal d/t too. If r11u178 lands pass 174 R1 whole, these four row-modes go with it.
  2. **The small joint rows' ground-A halves**: N0416 + N0022 + N0023 (rsp_gen_minimal), N0938 (jeras_union, with N0031
     B), N0191 + N0001 + N0853 + N1127 (OutputSizeWithParameterOfInstanceInitializedByStructMember), N0443 + N0684
     (arb_idx_cast, with N0448 B), N0299 + N0628 (AssertDelayError/AssertTempError, with N0627 / N0431 / N1047 B),
     N0476 + N0477 + N0499 (ParameterFromPkg*: the bare-vector parameter typespec, ParamEmit makeBareVecParamTs).
  3. **The UVM ground-A families** (r11u175 F5/F7 residues after its laws): N0682 (the package parameter
     `UVM_MACRO_NUMFLAGS` ref_typespec full name, the first OPEN record of SimpleUVM d/t and Scoreboard d), N0001 /
     N0007 / N0061 / N0119 (hier_path element spans and names), N0152 / N0153 / N0172 / N0173 / N0178 / N0179 (a
     method body `begin` with no file and no span: 71 + 4 + 3 probe cases), N0160 (the foreach ref_var end), N2411
     (the macro-argument constant column).
* **Module/type ground (after r11u176).**
  1. **Singles**: N0056 (PreprocTest's enum base `bit_typespec` end: the Verilog-mode face, the harness gives `-sv` to
     Surelog only), N0163 (PackedArrayHighConn's enum base names; also Rggen/Earlgrey's first record), N0014
     (StructParamPatternInitCast's last cluster, and anon_struct_packed_dim with N0820), N0129 (ibex_icache's last:
     ModuleEmit `substNdaParamRefs`, pass 163 S1), N0688 (iface_zero_width_field's last), N1174 (HierPathTypespec t,
     `pkg::pkg::b::pkg::a::x`: naming context-dependent, keep the memory's warning).
  2. **Pairs and triples**: N0072 + N0103 (ArrayMethodIterator), N0804 + N0805 (mem_read_reg), N0043 + N0133 + N0487
     (const_cast_signext), N0268 + N0418 + N0419 (OneNetModPort, pair B's named row), N0067 + N0068 + N0162 + N0289
     (ApbSlave after r11u175, N0289 the structural row), N0040 + N0526 (InterfaceModPort with OneNetModPort's three),
     N0011 + N0016 + N0090 (UnitElabBlock), N0088 + N0750 + N0819 + N1000 (OneNetModPortGeneric).
  3. **LogicTypespec's four** (N0083 + N0422 + N0484 + N1149) are a user decision (section 8b).
  4. **The UVM ground-B heads**: N0164 (`fullname|ref_typespec|...under:bit_typespec`, the first OPEN record of
     MiniAmiq, SeqDriver and BuildUVMPkg d/t after r11u175), N0043 (struct typespec spans), N0031 / N0042 (class
     parameter range constants with no file / no span), N0067 / N0068 (class_typespec copies with no file / span),
     N0116, N0127 / N0128 (interface-array port typespecs: 79 / 69 probe cases).

## 10. Prediction audit of map 8 ([evidence/audit.txt](evidence/audit.txt), [evidence/audit_open.txt](evidence/audit_open.txt); `drivers/audit9.py` reads the committed baselines at every landing)

**Since map 8 (151 row-modes at f2f2d30b), 53 row-modes converted**: pass 164 14, 167 8, 168 10, 169 2, 171 7, 174 12
(the verifications 0).

| map 8 predicted | row-modes | converted | by | still open |
|---|---|---|---|---|
| the decodes (measured) + pair B r11u164 (optimistic) | 11 | **10** | 164 4, 168 4, 171 2 | 1: HierPathTypespec t (N1174) |
| section-6 ground-A list (6 steps) | 14 | **6** | 167 6 | 8: YosysRiscv d/t, CovMacro d/t, ibex_pmp d/t, LocalScopeHierPath t, InterfArrayBind d |
| section-6 ground-B list (15 steps) | 29 | **14** | 164 2, 167 2, 168 6, 171 4 | 15: ClassTypeParam d/t, PreprocTest d/t, PackedArrayHighConn d/t, mem_read_reg d/t, const_cast_signext d/t, OneNetModPort d/t, LogicTypespec d/t, UnsizedParam d |
| section-6 joint list (40 steps) | 96 | **40** | 164 10, 167 8, 168 6, 169 2, 171 4, 174 10 (rows shared with the lists above counted in both) | 56 |
| **any of them** | **110** | **50** | | 60 |
| not predicted | | **3** | 171 1 (YosysBigSimEllip d), 174 2 (param_nested_struct_field_width d/t) | 38 open, never predicted: the UVM / Earlgrey / Rggen / Scr1 / BlackBePipeInt / SVSwitch rows and ten tests whose open sets were above the lists' 6-cluster cap (FuncStructVal, InterfaceStructMemberPort, OneNetModPortGeneric, ParameterFromPkg* x2, cfg_func_width_loop, ibex_tracer, int_types, jeras_union, struct_param_func_config) |

* **50 of the 53 conversions were predicted (94%)**, 45% of what map 8 predicted converted. Every one of the decode
  predictions converted exactly (the r11u161 and r11u166 decodes landed with 164 and 168 as measured).
* **The unpredicted conversions:** YosysBigSimEllip d, whose first cluster N0284 map 8 said "no landed or unlanded law
  covers" (pass 171's law selLhsBareDecRhsShared171 + law udpFormConcatSwallowSpans171 decoded it); and
  param_nested_struct_field_width d/t, whose open set was above the lists' 6-cluster cap (pass 169 unmasked it, pass
  174 converted it).
* **Why 60 predicted rows did not convert.** 70 of the 98 open rows still carry every cluster map 8 left open on them,
  28 lost some (evidence/audit_open.txt). The predicted-but-open rows are the single-cluster items no brief took:
  passes 167, 169 and 174 worked the struct-parameter / leftover / rp32 families (and cleared N0009 + N0084 + N0759,
  the ground-A list's step 1) but not map 8's ground-A singles N0036 / N0977 / N0278 / N0427, now in r11u178's brief;
  passes 164, 168 and 171 took ground-B steps 2, 4, 5, 6, 7, 8, 9 but not the singles N0072 (ClassTypeParam), N0056
  (PreprocTest), N0163 (PackedArrayHighConn: its N1115 half went with pass 168), N0804 + N0805, the const_cast_signext
  triple, OneNetModPort's three or UnsizedParam's three (the last two are now in r11u176's brief). ibex_pmp d/t lost
  map 8's N0471 but the r11u166 location model (pass 168) unmasked the F3 relocation faces map 8 had counted as pair
  B's (N0121 / N0144 / N0219 / N0239 / N0325 / N0434), so it now needs both pairs.
* **Map 7's 167 predicted row-modes, recounted through pass 174** ([evidence/audit_map7_recount.txt](evidence/audit_map7_recount.txt)):
  125 had converted by pass 163 (map 8's count), **153 by 5e8d08d9 (92%)**; the 14 still open are ArrayMethodIterator
  d/t, InterfArrayBind d, LogicTypespec d/t, PackedArrayHighConn d/t, PreprocTest d/t, HierPathTypespec t,
  const_cast_signext d/t and iface_zero_width_field d/t.

**Clusters.** Map 8's pair-B covered set (405 clusters: the decodes measured + r11u164 optimistic): 142 gone, 260
unchanged, 3 grew (N0297 0->7, N0314 0->7, N0757 2->9: macro and member faces the location model unmasked). Map 8's
section-6 lists (104 clusters): 21 gone, 6 lost every row, 13 fell, 64 unchanged. 25 clusters map 8 routed nowhere lost
rows (N0210 9->0: pass 171's law tsMemberRootFile171; the rp32 set N0922 / N0948 / N0988 / N0032; N0407 6->2).

**Site pins** (map 8's pin of each converted row's first cluster after the decodes, against the files of the landing
laws, read from src by the section sign):

| landing | pin's mint file = a law's file | a law's file is a caller in the pin | pin misses |
|---|---|---|---|
| pass 164 (B) | 6 | 6 | 2 (GenIfIfaceParamStructField d/t: ExprEmit pin N0001, ModuleEmit + TypeEmit law defGenPathSel161) |
| pass 167 (A) | 0 | 0 | 8 (StructParamFieldRange, StructParamFuncBodyFieldCompare, cva6_struct_param_field: TypeEmit `buildStructTs` pin N0084, ParamEmit type-parameter laws; ibex_register_file_ff: TypeEmit pin N0078, ExprEmit law genProcFoldDeclTsScopeNamed167) |
| pass 168 (B) | 3 | 6 | 1 (YosysOldOpen t: ExprEmit pin N0129, ModuleEmit law paramBaseSelTsInstName168) |
| pass 169 (A) | 2 | 0 | 0 |
| pass 171 (B) | 6 | 1 | 0 |
| pass 174 (A) | 12 | 0 | 0 |
| **all 53** | **29** | **13** | **11** |

What it says: **the pin names a fix file in 42 of 53 (79%), 29 at the mint** (map 8: 111 of 140, 53 at the mint). The
misses are again the laws that decide upstream of the mint in another file: the type-parameter copy decisions in
ParamEmit for TypeEmit mints (pass 167, as pass 163 before it), ModuleEmit's path routing for ExprEmit mints (164, 168).
Map 8's rule stands: read the first caller outside the mint's file, and check for a post-pass that rewrites the field.
Every row passes 169, 171 and 174 converted had a pin naming a file of its law (20 at the mint, 1 at a caller).

## 11. The family view

| family | row-modes / tests | clusters per row at 5e8d08d9 | after r11u175 (measured) | open per row after r11u175 + both pairs | distinct clusters: 5e8d08d9 -> r11u175 -> + pairs | cleared |
|---|---|---|---|---|---|---|
| UVM (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg) | 9 / 5 | 167-370 | 121-266 | 114-247 | 428 -> 321 -> 300 | 0 |
| Earlgrey_0_1 | 2 / 1 | 80-85 | 80-85 | 75-79 | 97 -> 97 -> 91 | 0 |
| Rggen (default only) | 1 / 1 | 56 | 56 | 54 | 56 -> 56 -> 54 | 0 |
| BlackBePipeInt | 2 / 1 | 26-28 | 26-28 | 25-27 | 28 -> 28 -> 27 | 0 |
| Scr1SvTests | 2 / 1 | 23 | 23 | 21 | 23 -> 23 -> 21 | 0 |
| SVSwitch | 2 / 1 | 17 | 16 | 16 | 17 -> 16 -> 16 | 0 |
| ApbSlave | 2 / 1 | 16 | 4 | 4 | 16 -> 4 -> 4 | 0 |
| ibex (icache, multdiv_fast, pmp, tracer) | 8 / 4 | 2-7 | 2-7 | 0-5 | 20 -> 20 -> 6 | 4 (multdiv_fast d/t, pmp d/t) |
| jeras (jeras_union) | 2 / 1 | 2 | 2 | 2 | 2 -> 2 -> 2 | 0 |

rp32 is gone (pass 174 converted all 8 row-modes). Per ibex test at 5e8d08d9: ibex_pmp 7 clusters, ibex_tracer 6,
ibex_icache 5, ibex_multdiv_fast 2.

**The near rows.** At 5e8d08d9, 11 row-modes in 7 tests are single-cluster: CovMacro d/t N0977, InterfArrayBind d N0427,
PackedArrayHighConn d/t N0163, PreprocTest d/t N0056, YosysRiscv d/t N0036, HierPathTypespec t N1174,
LocalScopeHierPath t N0278. After r11u175 and both pairs, 13 row-modes in 7 tests have one open cluster:

| row(s) | the open cluster |
|---|---|
| FuncStructValSimple d/t | N0131 (A; pair A's own shape, section 5) |
| PackedArrayHighConn d/t | N0163 (B) |
| PreprocTest d/t | N0056 (B) |
| StructParamPatternInitCast d/t | N0014 (B) |
| HierPathTypespec t | N1174 (B) |
| ibex_icache d/t | N0129 (B) |
| iface_zero_width_field d/t | N0688 (B) |

12 more have two: ArrayMethodIterator d/t N0072 + N0103, FuncStructVal d N0131 + N0891, UnitElabBlock t N0016 + N0090,
anon_struct_packed_dim d/t N0014 + N0820, func_typename_ret d/t N0085 + N0738, jeras_union d/t N0031 + N0938,
mem_read_reg d/t N0804 + N0805.

**The UVM family: r11u175's census by family key** (its `uvmcensus.py` + `uvmfamilies.py` over map 8's cluster keys,
the five UVM rows' default databases; [evidence/uvm/](evidence/uvm/)):

| family | 2dcbc596 (r11u172) | e3f14d0a (r11u175) | **5e8d08d9** | e3f14d0a + the patches (r11u175) | **5e8d08d9 + the patches** |
|---|---|---|---|---|---|
| F2 object multiplicity | 47,650 | 48,573 | **47,777** | 23,489 | **23,489** |
| F1 preprocessor location model | 35,866 | 720 | **720** | 720 | **720** |
| F4 formal / typespec / bound spans | 19,711 | 19,697 | **19,697** | 3,513 | **3,513** |
| F5 reference full names | 19,445 | 19,445 | **19,445** | 12,516 | **12,516** |
| F6 file facets | 11,817 | 11,817 | **8,180** | 12,376 | **8,204** |
| F7 expression spans outside the pp model | 12,768 | 4,986 | **5,030** | 1,863 | **1,907** |
| F3 typedef relocation spans | 1,045 | 1,045 | **1,045** | 1,095 | **1,095** |
| F8 names | 732 | 732 | **732** | 726 | **726** |
| F9 value / order / depth | 363 | 363 | **363** | 292 | **292** |
| **all** | 149,397 (504 clusters) | 107,378 (433) | **102,989 (426)** | 56,590 (322) | **52,462 (319)** |

Since r11u175's base: pass 171's law tsMemberRootFile171 took F6 11,817 -> 8,180 (N0210's typespec_member files) and
passes 169/171/174 took F2 by 796; F7 grew by 44. Under the patches F2, F4, F5, F3, F8, F9 and F1 land on exactly r11u175's after-counts; F7
falls by the same 3,123 (to 1,907); F6 grows by 24 (r11u175: +559; consistent with the typespec_member file face N0210 that pass 171
cleared, which the new F2 copies inherited at e3f14d0a).

**Order-blind uhdm-dump distance to golden** (records ours-not-golden + golden-not-ours, depth dropped, multiset;
`drivers/uvmdist.sh`, [evidence/sweeps/uvm_orderblind_distance.txt](evidence/sweeps/uvm_orderblind_distance.txt)):

| row-mode | e3f14d0a (r11u175 pristine) | e3f14d0a + patches | **5e8d08d9** | **5e8d08d9 + patches** |
|---|---|---|---|---|
| MiniAmiq d / t | 55,321 | 31,977 | **53,273** | **29,287** (-45%) |
| SeqDriver d / t | 44,891 | 25,575 | **42,605 / 42,607** | **22,861 / 22,863** (-46%) |
| SimpleUVM d / t | 22,068 | 11,510 | **20,344** | **9,786** (-52%) |
| Scoreboard d | 19,316 | 9,256 | **18,002** | **7,942** (-56%) |
| BuildUVMPkg d / t | 14,833 | 5,189 | **14,833** | **5,189** (-65%) |
| ApbSlave d / t | 88 | 12 | **88** | **12** |
| SVSwitch d / t | 127 | 123 | **127** | **123** |

The +-2 in SeqDriver is the UINT/decompile order coin. Passes 169-174 moved the UVM rows 0-8% toward golden without
converting any (MiniAmiq -3.7%, SeqDriver -5.1%, SimpleUVM -7.8%, Scoreboard -6.8%, BuildUVMPkg 0); the two r11u175 patches take another 45-65%. The UVM rows still carry 121-266 clusters each after them
and 114-247 after both pairs: after the patches the largest UVM families are F2 (23,489: the import-parameter copies
N0151 / N0262 / N0182, pair B's; the importer clone's foreach variable N0134 / N0408, pair A's), F5 (12,516) and F6
(8,204).

## 12. Files

* **cluster_index.csv**: one row per cluster (1101), with rows / probe at 5e8d08d9, after r11u175 (`rows_after_law`),
  after both pairs (`rows_after_pairs`), `alone_on_top_of_pairs`, `first_in_after_pairs` (first OPEN record),
  `alone_on_pristine`, coverage, ground, site, map 8's rows and coverage, families, probe laws, key, example.
* **clusters.csv**: row-mode x cluster with a `first` flag; **probe_clusters.csv** the same per probe case.
* **fail_list.csv**: every STRICT_NOTEQUAL row-mode (98) with its first cluster, that cluster's coverage / ground /
  site, cluster counts, family, downstream verdict, the strict cell after r11u175, the first OPEN cluster after the
  pairs, the open clusters left and `clears`. **probe_fail_list.csv**: the same for the 1291 probe cases.
* **evidence/**:
  * `clusters/`: record dumps, one example per cluster with a row or >= 3 probe cases (765); `objects.csv`: one
    example object for every cluster (1101);
  * `report.txt` (drivers/report9.py), `audit.txt` (drivers/audit9.py), `audit_open.txt`, `audit_map7_recount.txt`,
    `final9.txt`, `pristine_index.csv`, `greedy9.json`;
  * `routes.json` (the live pairs' items), `ground_override.json`, `sites.json`, `pins_final.txt`, `pinwant.txt`;
  * `law175_scratch.patch`: the measured r11u175 binary's source (5e8d08d9 + both patches), NOT applied;
  * `controls/controls.txt`; `uvm/` (the census at 5e8d08d9 and under the patches: families, ranks, first ten);
  * `sweeps/`: `sweep_pristine.txt`, `sweep_law175.txt`, `byteverify_law175_vs_pristine.txt`,
    `byteverify_pristine_vs_head.txt`, `canaries.txt`, `r11u175_attribution.txt`, `uvm_orderblind_distance.txt`,
    `dsfaces_P.csv`, `dsfaces_L.csv`.
* **drivers/**: `run9.sh` (the pipeline as run), `env.sh`, `common.py` (key rewrite + the fence), `jobs.py`,
  `probejobs.py`, `probelaw.py`, `run1.sh`, `cc.sh`, `strictcmp_x.cpp`, `objrank.cpp`, `analyze.py`, `final9.py`,
  `pinmulti.py`, `sites.py`, `mksites9.py`, `report9.py`, `audit9.py`, `tables9.py`, `evid.py`, `dsfaces.py`,
  `bvmirror.sh`, `uvmcensus9.sh` (+ r11u175's `uvmcensus.py`, `uvmfamilies.py`), `uvmdist.sh`.
