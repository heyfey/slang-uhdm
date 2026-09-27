# r11u189map: the strict ground map, tenth edition (measurement only)

**Base.** Measured at `2b97649e` (branch matrix-1.87), HEAD of the branch when the pass started. One landing followed while
it ran: pass 184 (`443933679`, pair A r11u184), read here from its committed baselines only (section 12); every
measurement below is at 2b97649e. The base sits after map 9 (`tools/probe/r11u179map`, at `5e8d08d9`, committed as `7fadac8a`), the verification
r11u182 (`312e26e2`, one refinement castUnionCloneKeepsCastParent182v), pass 178 (`80a1c2af`: r11u175's expression laws
+ hierPathSelIdxAtPath178 + pkgPatUnqualReadTsNoParent178), pass 176 (`804e3b75`: externProtoFormalsFromPrototype175 +
the module/type laws), pass 181 (`1eeff71d`: fifteen expression laws R11U181_* + four refinements R11V181_*), the decode
r11u183 (`459b7cdf`: `tools/probe/r11u183dec/law_exprstmt.patch` and `law_typeemit.patch`, NOT in src), pass 180
(`a3a62624`: ten module/type laws R11U180_* + three refinements R11V180_*) and the verification r11u185 (`2b97649e` itself,
one refinement genericAfterTypedIfacePortTyped185v).

**The reference sweep.** `/tmp/intr11u185` (the r11u185 landing sweep of 2b97649e, read-only here). Its csvs equal the
committed baselines cell for cell: 1596 of 1596 surelog rows and 1742 of 1742 uhdm2rtlil rows (status and strict), its
`probe.csv` byte-identical to `results/golden_probe.csv`, its `downstream.csv` equal to `results/downstream_uhdm2rtlil.csv`
on every verdict. All 3273 `slang:` lines of its `cmds.txt` files name the main tree's `build/slang-uhdm`, whose md5
`78e0b9590a16...` equals this worktree's build. It is therefore the pristine side of every comparison below.

Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited; this directory is the whole patch.
Law names are written `law <name>` (no section sign) so `scripts/law_index.py` does not read this directory as a pass.

**The fence.** No fenced row is STRICT_NOTEQUAL at 2b97649e (0 of 84), so none is in the fail list; their rows are
counted from the csv verdicts only. Every driver here that reads a database or a source takes the four names from the
`FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` (`drivers/common.py fenced()`, `drivers/env.sh`; fail closed;
never RESUME.md by line number) and refuses them by word boundary: `jobs.py` (0 skipped), `pinmulti.py`, `dsfaces.py`,
`uvmcensus9.sh`, `uvmdist.sh`, `census.sh` (the firing census ran `--filter '^(?!(<fenced>)$)'`), `bvmirror.sh` (the
byte comparison ran on hard-link mirrors that leave the 8 fenced row-mode databases out, `fenced_skipped=8`). The gate
sweep of the law binary dispatched every row, as the gate mandates. **No binary, gdb run or script touched a fenced
test's sources or databases outside that sweep.** A grep of this directory for the four names reads 0.

## Binaries (frozen `chmod 555` in `/tmp/r11u189_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `78e0b9590a16121c295119b5188e5e74` | worktree `/tmp/wt_r11u189` at 2b97649e, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` (the reference sweep's binary) |
| `slang-uhdm.law183` | `f2b351c41efaa9d9ec01b4be43e10295` | MEASUREMENT ONLY: 2b97649e + [evidence/law183_scratch_2b97649e.patch](evidence/law183_scratch_2b97649e.patch) = r11u183's `law_exprstmt.patch` (clean `git apply`) + `law_typeemit.patch` rebased over passes 176 and 180 (r11u183's own 804e3b75 rebase, whose one UhdmExporter hunk, classPropElemClassTsAtType183 at the array-element class_typespec, no longer applied after pass 180 inserted its noteTpUse180 call there; re-inserted by hand after that call; every other hunk applies with offsets). Scratch worktree `/tmp/wt_r11u189L` |
| `slang-uhdm.lawA` | `f5b8884f84f96b7f5f0a934ef22512f4` | 2b97649e + [evidence/law_exprstmt_on_2b97649e.patch](evidence/law_exprstmt_on_2b97649e.patch) alone (pair A's successor r11u187's share) |
| `slang-uhdm.lawB` | `ce82cc50bc31d197fb1b68a187ced19b` | 2b97649e + [evidence/law_typeemit_rebased_on_2b97649e.patch](evidence/law_typeemit_rebased_on_2b97649e.patch) alone (pair B r11u186's first item) |
| `slang-uhdm.g1` | `40f20d8deaa54fdd115c1161e22b485a` | 2b97649e with `-DCMAKE_CXX_FLAGS=-g1`; gdb pins only (its databases are byte-identical to the pristine binary's) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's (the comparator is unchanged since map 7) |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | `drivers/strictcmp_x.cpp` built by `drivers/cc.sh`; the same md5 as maps 7-9 |
| `objrank` | `82be8e819d67948b41f0cbf0a904f216` | `drivers/objrank.cpp` |

Sweeps: the reference `/tmp/intr11u185` (pristine) and this map's `/tmp/r11u189_sL` (law183, `tests/sweep.sh --jobs 3`,
all four stages; the two workdir names have the same length). All 3273 `slang:` lines of the law sweep's `cmds.txt`
files name `/tmp/r11u189_bin/slang-uhdm.law183` ([evidence/sweeps/sweep_law183.txt](evidence/sweeps/sweep_law183.txt)). The
sweep exits 1 for one reason only, `law index STALE: tests/LAWS.md`, which the main tree at 2b97649e reads too
(`python3 scripts/law_index.py --check`, rc 1, measured in the main tree and in the untouched worktree).

## 0. Where we stand (2b97649e; the committed baselines are the fail list)

| corpus | mode | judge-equal | strict-equal | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 456 | 24 |
| surelog | testflags | 474 | 452 | 22 |
| uhdm2rtlil | default | 803 | 784 | 19 |
| uhdm2rtlil | testflags | 803 | 784 | 19 |
| probe cases | | 4087 | 2895 | 1192 |

**The fail list is 84 row-modes (46 surelog + 38 uhdm2rtlil) in 44 tests, plus 1192 probe cases.** All 84 row-modes and
all 4087 probe cases were dispatched to the strict comparator; none is fenced.

First fields, tallied from the `strict` column of results/golden_*.csv (= the reference sweep's):
* surelog 46: fullname 21, endcol 9, endline 5, file 5, depth 2, col 2, type 2;
* uhdm2rtlil 38: fullname 20, file 8, line 4, endcol 2, type 2, name 2;
* probe 1192: fullname 447, endcol 199, line 164, depth 104, file 101, type 71, name 57, col 29, endline 11, value 5,
  decompile 4.

Mode asymmetries (the default row is the map's row; these differ in testflags):
* NE in default only: InterfArrayBind (testflags CMP_EQUAL), Rggen (testflags SURELOG_FAIL), Scoreboard (testflags
  SLANG_REJECT);
* NE in testflags only: HierPathTypespec;
* a different cell per mode: AssertDelayError `fullname(48)` / `(66)`, AssertTempError `fullname(28)` / `(38)`,
  ClassTypeParam `endline(17)` / `file(30)`, FuncStructVal `endcol(95)` / `(165)`, FuncStructValSimple `file(39)` / `(59)`,
  UnitElabBlock `endline(13)` / `(12)`;
* every uhdm2rtlil fail test is NE in both modes with the same cell, and **every uhdm2rtlil fail row-mode is downstream
  IDENTICAL** (38 of 38).

**Since map 9.** Map 9 counted 98 row-modes and 1291 probe cases at 5e8d08d9. Since then 14 row-modes and 99 probe cases
converted and none entered (committed baselines at each landing, [evidence/audit.txt](evidence/audit.txt) A):

| landing | row-modes | tests | probe cases | strict-cell changes |
|---|---|---|---|---|
| r11u182 verification (`312e26e2`) | 0 | 0 | 0 | 0 |
| pass 178 (`80a1c2af`) | 1 (LocalScopeHierPath t) | 1 | 18 | 13 |
| pass 176 (`804e3b75`) | 5 (OneNetModPort d/t, OneNetModPortGeneric d/t, UnsizedParam d) | 3 | 66 | 18 |
| pass 181 (`1eeff71d`) | 4 (CovMacro d/t, YosysRiscv d/t) | 2 | 6 | 11 |
| r11u183 decode (`459b7cdf`) | 0 | 0 | 0 | 0 |
| pass 180 (`a3a62624`) | 4 (PackedArrayHighConn d/t, mem_read_reg d/t) | 2 | 9 | 9 |
| r11u185 verification (`2b97649e`) | 0 | 0 | 0 | 0 |

**Clusters.** Map 9 had 1101 clusters; this map has **995** (527 carry a corpus row, 693 a probe case). The key is maps
4-9's (`facet|type|shape|under:<walk parent type>` + `@builtin` / `@in-typespec`), so a persisting key keeps its id: 941
keep map 9's id, 6 reappear under an earlier map's id (N0137, N0316, N0324, N0331, N1025, N2220), **48 are new,
N2416-N2463**; 160 map-9 clusters are gone. Only one new cluster carries a corpus row:

* **N2416** (4 row-modes: MiniAmiq d/t, SeqDriver d/t; `fullname|ref_typespec|tok:id::id::id::id::id::id::id::id::->|under:bit_typespec`):
  the importer-clone copies of `uvm_reg_bus_op::byte_en` inside `svaunit_pkg::uvm_reg_map::do_bus_write::foreach...`
  (golden names the typedef reference through the clone chain, ours bare); the example row is a UVM coin row, so the gdb
  pin (UHDM library DeepClone) is marked `db=DIFF, rank NOT verified`.
* 41 of the other 47 new ids come from ONE probe case, `r10v194repro/v194_a_explicit` (explicit-import function clones
  and the wildcard class method listing: golden `va194_explf::va_free`, ours `va194_wild::VA194::va_out`; spans 5 lines
  off), whose walk passes 176-181 unmasked past its old divergence (r11u185 section 5 reads the sibling case v194_e as an
  unmasking); `r10uvm171repro/g171_c_shapes`, `r10uvm193repro/g193_d_propfence` and `r10uvm198repro/g198_a_homes` hold
  the rest.

## 1. Method (map 9's pipeline re-based, [drivers/run10.sh](drivers/run10.sh))

1. **Input.** The reference sweep `/tmp/intr11u185` (= the committed baselines). The jobs are every `STRICT_NOTEQUAL`
   row-mode of results/golden_*.csv (84; `drivers/jobs.py`: 0 missing, 0 fenced, one binary). Each golden is the cache
   entry its `cmds.txt` names. Every probe case is a job too (4087); its golden is `scripts/check_probe.py`'s
   `cache_dir(rel)` (Surelog's identity + the case path + a hash of the case's files), its database
   `/tmp/intr11u185/probe/<rel with / -> __>.uhdm`.
2. **Strict runs.** `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job. All 84 corpus runs return rc=2;
   probe runs return rc=0 on 2895 cases and rc=2 on 1192, exactly the baseline split.
3. **Analysis.** `drivers/analyze.py` (map 3's alignment, the committed mode-4 rule) records EVERY differing object; its
   reimplementation of the tool's rule agrees with the tool's stdout on **1276 of 1276** rows at 2b97649e (0
   VERIFY-MISMATCH, 0 CELL-MISMATCH against the csv cells; [evidence/final10.txt](evidence/final10.txt)) and on 1129 of
   1129 rows of the r11u183 cross-section.
4. **Clusters.** `drivers/final10.py`: map 9's key; ids persist from map 9 (else the latest earlier map); new ids from
   N2416.
5. **Sites.** `drivers/pinmulti.py` ran one gdb session per example row (the `-g1` exporter stops at the example
   object's `Serializer::Make<type>` rank). It pinned the 102 clusters of [evidence/pinwant.txt](evidence/pinwant.txt): every
   cluster not in map 9 (54), and every cluster with >= 3 row-modes, first on a fail row, >= 40 probe cases or first on
   >= 10 probe cases whose example object changed since map 9 (46) or had no pin (2), except those whose only rows are
   UVM rows with no probe case (their gdb runs cannot reproduce the coin databases; they keep map 9's pin).
   * **A trap found here:** a probe database embeds the ABSOLUTE path of its `dut.sv`. The first pin run, from the
     worktree's `tests/probe` copies, wrote 99 of 100 databases differently from the reference sweep's (`db=DIFF`,
     [evidence/pins/pinmulti_worktree_cwd_DIFF.log](evidence/pins/pinmulti_worktree_cwd_DIFF.log)); the ranks are only
     valid on a byte-identical database, so the pins were re-run with the main tree's case directories as the cwd
     (read-only: the database goes to scratch). A map whose reference sweep was run from the main tree must pin there.
   * The final run: **99 of 100 `db=SAME`**, 1 `db=DIFF` (N2416 on MiniAmiq, the UVM coin; marked `rank NOT verified`);
     2 have no partner record (N0194, N0478: golden-only objects; they keep map 9's pin).
   * Of the 46 re-pinned clusters with a map-9 pin, 42 name the same mint as map 9's, 4 another (N0072 and N0103:
     TaskFuncEmit `emitTaskFuncs` near law classHandleRetTsNameUnlessSameHomeComponent156 where map 9 had TypeEmit
     `makeTypespec`; N0266: TypeEmit `aggImportCloneCopy32`; N0414: TypeEmit `namedElemPackedDimTs31`); map 9's pin rides
     beside the new one. Every other cluster keeps map 9's pin, marked `[r11u179map pin]`.
6. **Ground.** A = ExprEmit/EmitHelpers/StmtEmit/ParamEmit, B = TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/
   uhdm_main, by the pinned mint's file, overridden where a pass decoded the fix site elsewhere
   ([evidence/ground_override.json](evidence/ground_override.json): map 9's list, plus N0688 -> A (pass 178 R3 / r11u180 S4:
   ParamEmit `drainShareDefParamTs`, the reference's actual) and N0129 -> A (r11u180 S5: the explicit-assign
   substitution is ExprEmit's, law elabCaPortParamPaCopy64, not ModuleEmit `substNdaParamRefs`)).
7. **Coverage** ([evidence/routes.json](evidence/routes.json), `drivers/report10.py`):
   * **r11u183's two law patches, MEASURED**: a cluster gone under the law183 binary's full sweep reads
     `COVERED r11u183 (law patches, MEASURED ...)`;
   * **pair A r11u184, OPTIMISTIC**: its brief items mapped to clusters and rows; a covered cluster counts fixed whole; a
     named ROW covers a cluster only when every row of the cluster is a named row of that ground;
   * **pair B r11u186, OPTIMISTIC**: the same, plus the ground-B clusters of the UVM (MiniAmiq, SeqDriver, SimpleUVM,
     Scoreboard, BuildUVMPkg) and Earlgrey_0_1 rows' **first ten differing records** at the r11u183 cross-section whose
     rows are all UVM/Earlgrey rows (the brief's "UVM/Earlgrey first records");
   * **OPEN** otherwise, with map 9's routing where it had one (`map 9 gave it to r11u178/r11u176; passes 176-181 left
     it`, `map 9 listed it: ground-X step n`).
8. **Yields.** The law183 binary's full sweep is re-dumped and re-keyed, so r11u183 is MEASURED; the pairs are applied
   optimistically to that cross-section. The `alone` column is the rows a cluster clears alone on top of r11u183 and both
   pairs.

What the live pairs were mapped to (evidence/routes.json):

| pair | brief item | clusters | named rows |
|---|---|---|---|
| B r11u186 | r11u183 `law_typeemit.patch` (first) | MEASURED (with law_exprstmt) | |
| B | map 9's ground-B remainder: PreprocTest, StructParamPatternInitCast's B half, HierPathTypespec, ApbSlave's class_typespec | N0056, N0014, N1174, N0067 + N0068 | PreprocTest, HierPathTypespec t |
| B | pass 181's sister S1: a class member array's class_typespec (no file / span) | N0067 + N0068 (the same key: UhdmExporter `classElemVar`) | |
| B | the UVM/Earlgrey first records | the ground-B first-ten clusters (N0144, N0327: the other ground-B first-ten keys also carry non-UVM/Earlgrey rows, so they stay OPEN) | |
| B | pass 180's residues (two-package interface import order, enums cast to, the included-file typedef file, type-parameter groups with a winning typedef, the bareScalarTypedefVarTs determinism law), pass 181's S2 / S3 (definition-view `$root` column, digit separators outside the literal emitter and in range bounds), LogicTypespec (measured only) | none: evidence cases, or bytes only (section 8, the determinism control) | |
| A r11u184 | pass 181 R1 (FuncStructValSimple: the constant-function leftover read site, the package listing's element reference) | N0086 + N0087, N0131 | FuncStructValSimple |
| A | pass 181 R5: the evaluator's formal typespec on Scr1SvTests' call argument | N0965 | |
| A | pass 176's sister faces: ibex_multdiv_fast's generate-block enum constants, TypeParameterAsPortTypeWithEnum's enum copy | N0545 + N0546, N0012 + N0034 + N0638 + N0281 | ibex_multdiv_fast, TypeParameterAsPortTypeWithEnum(+OfParametrizedWidth) |
| A | the re-verifiers' residues: pass 178 R3 (iface_zero_width_field's unparented reference) | N0688 | iface_zero_width_field |
| A | map 9's ground-A remainder: N0131; the small joint rows' A halves (rsp_gen_minimal N0416 + N0022, jeras_union N0938, OutputSize N0191 + N0001, arb_idx_cast N0443 + N0684, Assert* N0299 + N0628, ParameterFromPkg* N0476 + N0477 + N0499); the UVM ground-A families (N0682, N0001, N0007, N0061, N0119, N0152, N0153, N0172, N0173, N0178, N0179, N0160, N2411); map 9's r11u178 routes pass 178 left (N0003, N0943, N0427, N0407, N0745, N1083, N0415, N0474, N0549, N0942, N0097) | 41 clusters with a key at 2b97649e | |
| A | pass 181 R2 / R3 / R4 / R6 / R7 (streaming and nested lvalue paths, call-as-index span, lvalue `$root` endcol, the unsized based literal as a whole CA value), the parenthesized member-select index, r11u185's PU/u02 | none: evidence cases (no gate row or probe case carries a cluster of its own) | |
| A (r11u187) | r11u183 `law_exprstmt.patch` | MEASURED (with law_typeemit) | |

## 2. Positive controls ([evidence/controls/](evidence/controls/))

| control | result |
|---|---|
| surelog/default/1364_2005 (CMP_EQUAL) | `STRICT_EQUAL 159 objects`, rc 0, record dumps identical (159 / 159) |
| surelog/default/HierPathInterfBlock (CMP_EQUAL) | `STRICT_EQUAL 226 objects`, rc 0, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray (CMP_EQUAL) | `STRICT_EQUAL 194 objects`, rc 0, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, lhsPath = rhsPath `design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL,decompile:` both modes |
| analyzer rule vs tool stdout | 1276 / 1276 at 2b97649e; 1129 / 1129 on the r11u183 cross-section |
| probe cells vs golden_probe.csv | 4087 / 4087 (probe.csv byte-identical); 1192 / 1192 rc=2 from the strict runs |
| pin validity | 99 / 100 `db=SAME`, 1 coin row (N2416), 2 no partner (map 9's pin kept) |
| byteverify self-check | 2559 / 2560 flagged with one side corrupted |

### The determinism control ([evidence/determinism/](evidence/determinism/), [drivers/det.sh](drivers/det.sh), [ob.sh](drivers/ob.sh))

The HEAD binary run three times CONCURRENTLY per row-mode (the reference sweep's command line, its cwd, output to
scratch), plus the reference sweep's own database as a fourth sample. Distinct md5s, and the order-blind `uhdm-dump`
difference (paths normalised, sorted, `comm -3` line count) of every pair; strict objects_differing per run:

| row-mode | distinct hashes (of 4) | order-blind lines per pair | the lines | strict cell (every run) |
|---|---|---|---|---|
| Earlgrey_0_1 default | **2** (runs 1+2 vs run 3 = HEAD) | 0 | order only | `col(102)` |
| Earlgrey_0_1 testflags | **2** (runs 1-3 vs HEAD) | 0 | order only | `col(102)` |
| MiniAmiq default | **4** | 4 on each of 6 pairs | one constant's `UINT:<n>` + `vpiDecompile:<n>` (e.g. MiniAmiq 1214 vs 547, SimpleUVM 0 vs 884) | `fullname(8)` |
| MiniAmiq testflags | **4** | 4 on each of 6 pairs | the same constant | `fullname(8)` |
| SeqDriver default | **4** | 4 on each pair | the same | `fullname(7)` |
| SeqDriver testflags | **3** | 4 on each pair | the same | `fullname(7)` |
| SimpleUVM default | **2** | 4 | the same | `fullname(23)` |
| SimpleUVM testflags | 1 | - | - | `fullname(23)` |
| Scoreboard default | **2** | **0** | order only | `fullname(23)` |
| BuildUVMPkg default / testflags | 1 / 1 | - | - | `fullname(23)` |

Scoreboard testflags is SLANG_REJECT (not run). Every variant reads uhdm-cmp 0 lines and the same strict cell and object
count as the committed baseline. So: **Earlgrey_0_1 is two-valued in BOTH modes** (pass 180's bareScalarTypedefVarTs
residue: order-only, confirmed); the UVM rows carry the known 0-or-4-line UINT / vpiDecompile coin (a constant whose
value differs between runs, not just its order: MiniAmiq and SeqDriver drew a different value on every run), and
Scoreboard default is ALSO two-valued order-only. Neither face reaches a strict cell. A map or verifier that compares
any of these rows byte for byte across two runs of one binary must attribute order-blind.

## 3. The gates (this map lands no binary; the law sweep measured)

| gate | pristine `78e0b9590a16` (`/tmp/intr11u185`) | law183 `f2b351c41efa` (`/tmp/r11u189_sL`) |
|---|---|---|
| (1) build | = the main tree's build | 2b97649e + the two r11u183 patches (rebased as above) |
| (2) probe vs golden_probe.csv | EQUAL 2895 / STRICT_NOTEQUAL 1192; probe.csv byte-identical to the baseline | EQUAL **3032** / 1055; `regressions=0 conversions=137 changes=92` |
| (3) surelog + uhdm2rtlil vs golden_*.csv | = the baselines, 480/3 + 474/3, 803/1/67 | surelog `regressions=0 conversions=4 changes=12`; uhdm2rtlil `regressions=0 conversions=6 changes=0`; judge-equal histograms unchanged |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; = results/downstream_uhdm2rtlil.csv | the same; `downstream.csv` byte-identical to the reference sweep's; not identical and not excused 0 |
| (5) uhdm-cmp | no row touched | every corpus row keeps its judge status; every probe case stays uhdm-cmp EQUAL (the fresh csv holds only EQUAL / STRICT_NOTEQUAL) |
| (6) byteverify (SELFCHECK=1, fence-free mirrors) | | **38 / 2560 movers, every one PREDICTED by name** by the firing census run before the law sweep (`R11U183_TRACE`, 46 predicted row-modes, [evidence/sweeps/census/predicted_movers.txt](evidence/sweeps/census/predicted_movers.txt), frozen `chmod 444`); 0 moved-not-predicted; 8 predicted-not-moved (ibex_wb_stage d/t and struct_param_pattern_packing d/t as at 80a1c2af; const_cast_signext d/t and struct_param_func_config d/t, where paramAggTdLastWriter183 fires but pass 180's modAggTfArgCloneFollows180 / pkgAggTfArgCloneFollows180 already write the same bytes) |
| canaries ([evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)) | surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS | surelog ok=41 changed=11 (exactly the 11 canary rows among the conversions and changes below); uhdm2rtlil ok=16 changed=0; ctcan2 PASS both |

The 38 movers: ApbSlave, ArrayMethodIterator, BuildUVMPkg, Earlgrey_0_1, LargeValue2Struct, MiniAmiq, SeqDriver,
SimpleUVM, StructUnsizedVal, SVSwitch, UnionCast (surelog, both modes), Rggen and Scoreboard (surelog default),
ParameterFromPkgInNestedModule, ParameterFromPkgOnParameterPortList, jeras_union, rp32_r5p_alu / bru / mdu / wbu
(uhdm2rtlil, both modes) ([evidence/sweeps/byteverify_law183_vs_head.txt](evidence/sweeps/byteverify_law183_vs_head.txt)):
the same set r11u183 measured at 80a1c2af minus const_cast_signext and struct_param_func_config. Earlgrey_0_1,
LargeValue2Struct, StructUnsizedVal, UnionCast and rp32_r5p_* keep their strict cells (law aliasOfTdSharedKeepsModName183
renames a shared alias reference neither walk reaches, as r11u183 found).

## 4. r11u183's two law patches, MEASURED at 2b97649e (the cross-section)

| stage | both patches (law183) | law_exprstmt alone (lawA) | law_typeemit alone (lawB) |
|---|---|---|---|
| probe | **137 conversions** (EQUAL 2895 -> 3032), 92 changes, 0 regressions | 7 / 13 / 0 | 127 / 84 / 0 |
| surelog | **4 conversions** (ApbSlave d/t, ArrayMethodIterator d/t), 12 changes | ArrayMethodIterator d/t convert; ApbSlave d/t `depth(1) -> file(4)` | 0 conversions |
| uhdm2rtlil | **6 conversions** (ParameterFromPkgInNestedModule d/t, ParameterFromPkgOnParameterPortList d/t, jeras_union d/t), 0 changes | jeras_union `fullname(75) -> fullname(15)` | ParameterFromPkg* d/t convert (4); jeras_union `-> file(60)` |
| downstream | 803 / 66 / 2 / 0, csv byte-identical | (not run) | (not run) |

(lawA / lawB: `drivers/attribution.sh`, the probe stage in full and the corpus stages filtered to the 22 tests the laws
move or fire on; [evidence/sweeps/attribution_lawA/](evidence/sweeps/attribution_lawA/), [attribution_lawB/](evidence/sweeps/attribution_lawB/).)

The fresh corpus rows of the law sweep (NOT written to results/):

    ApbSlave,default,CMP_EQUAL,,,equal                          was differ:depth(1)
    ApbSlave,testflags,CMP_EQUAL,,,equal                        was differ:depth(1)
    ArrayMethodIterator,default,CMP_EQUAL,,,equal               was differ:endcol(1)
    ArrayMethodIterator,testflags,CMP_EQUAL,,,equal             was differ:endcol(1)
    ParameterFromPkgInNestedModule,{default,testflags},CMP_EQUAL      was differ:fullname(7)
    ParameterFromPkgOnParameterPortList,{default,testflags},CMP_EQUAL was differ:fullname(7)
    jeras_union,{default,testflags},CMP_EQUAL                   was differ:fullname(75)

**Per patch.** Of the 137 probe conversions **7 need only law_exprstmt** (r10uvm153repro/g153_a_mech, r10uvm57repro/b2_shape
and v1_prodcell, r10uvm80repro/c2_autokinds and v5_edges80, r10uvm88repro/g88_a2_bound, r10v152repro/v152_e_pos), **127 only
law_typeemit**, **3 need both** (r10uvm151repro/g151_a_body, r10uvm21repro/t, r10uvm21repro/t32b_t); neither alone regresses
a case. Corpus: ArrayMethodIterator needs only law_exprstmt (law withClauseCloseParenEnd183: pass 180 already cleared the
class-typespec half r11u183 counted as ground B), the ParameterFromPkg pair only law_typeemit, **ApbSlave d/t and
jeras_union d/t need both**. Compared with r11u183's own measurement at 80a1c2af (+132 probe, +2 surelog, +6 uhdm2rtlil,
ApbSlave only on 804e3b75; different baselines): the patches now read 137 probe conversions and ApbSlave converts on top
of pass 176, as r11u183's composition sweep predicted.

The 12 surelog changes (fresh csv cells; each row stays judge-equal):

    BuildUVMPkg d/t  differ:fullname(23) -> differ:col(22)       (lawB alone: the same)
    MiniAmiq d/t     differ:fullname(8)  -> differ:file(29)      (lawA alone fullname(30), lawB alone file(7))
    SeqDriver d/t    differ:fullname(7)  -> differ:col(28)       (lawA fullname(29), lawB col(6))
    SimpleUVM d/t    differ:fullname(23) -> differ:fullname(56)  (lawA fullname(57), lawB fullname(22))
    Scoreboard d     differ:fullname(23) -> differ:fullname(56)
    SVSwitch d/t     differ:file(15)     -> differ:fullname(13)  (lawB alone: the same)
    Rggen d          differ:endcol(634)  -> differ:endcol(696)   (lawB alone: the same)

The UVM counts grow because the walk diverges later (r11u183 section 4 measured the same mechanism at 80a1c2af): the
order-blind distance of every one of these rows falls (section 11). Rggen's count grows likewise (its first record, the
N0127 interface-array port typespec end, is gone; 62 more records behind the new first record are exposed).

**Clusters.** 18 clusters are gone under the patches (N0112 N0162 N0475 N0491 N0536 N0640 N0679 N0680 N0701 N0938 N1190
N1224 N1983 N2012 N2013 N2220 N2287 N2376), 17 fall (N0142 12->3, N0264 8->2, N0203 9->3, N0031 15->9, N0083 6->2, N0151
7->3, N0067 / N0068 / N0042 13->9, N0164 9->5, N0289 7->4, N0343 7->4, N0428 6->4, N0248 9->7, N0097 11->9, N0061 12->11,
N0128 10->9), N0127 leaves every row (10->0; 6 probe cases left), and 3 grow (N0764 0->4 and N0974 2->6 on MiniAmiq / SeqDriver / BuildUVMPkg, N0928 2->3 on Rggen: exposures
behind the later divergence). Keys new under the patches: corpus 5 (the largest,
`fullname|ref_typespec|tok:id::id::id::id::->id.id::id.id.|under:bit_typespec` x358 on SimpleUVM d/t (179 each): law
memberBareTdAliasNamedByUse183's alias references named through a member reference whose own name is wrong at pristine,
r11u183's family 3f residue; `span|constant|col+endcol|under:indexed_part_select` x345: Rggen's newly exposed records),
probe 1.

## 5. The yield, and the fail list after r11u183 and both pairs

| | row-modes cleared | tests cleared (every NE mode) | probe cases cleared |
|---|---|---|---|
| r11u183's two law patches, MEASURED | **10** | 5 | **137** |
| pair A r11u184, optimistic, on top of r11u183 | **11**: FuncStructValSimple d/t, InterfArrayBind d, TypeParameterAsPortTypeWithEnum d/t, ...OfParametrizedWidth d/t, ibex_multdiv_fast d/t, iface_zero_width_field d/t | 6 | 67 |
| pair B r11u186, optimistic, on top of r11u183 | **3**: PreprocTest d/t, HierPathTypespec t | 2 | 10 |
| **everything** (r11u183 + both pairs) | **26** (the 24 above + StructParamPatternInitCast d/t, which needs both: A N0003, B N0014) | **14** | **220** |

| corpus | mode | 2b97649e | after r11u183 (measured) | + pair A | + pair B | + both pairs |
|---|---|---|---|---|---|---|
| surelog | default | 24 | 22 | 20 | 21 | 18 |
| surelog | testflags | 22 | 20 | 19 | 18 | 16 |
| uhdm2rtlil | default | 19 | 16 | 12 | 16 | 12 |
| uhdm2rtlil | testflags | 19 | 16 | 12 | 16 | 12 |
| **all** | | **84 / 44 tests** | **74 / 39** | | | **58 / 30 tests** |
| probe cases | | 1192 | 1055 | 988 | 1045 | **972** |

First fields after r11u183 (the law sweep's csvs): surelog 42: fullname 17, endcol 7, col 6, endline 5, file 5, type 2;
uhdm2rtlil 32: fullname 14, file 8, line 4, endcol 2, type 2, name 2; probe 1055: fullname 448, line 224, endcol 112,
type 73, file 60, name 59, depth 32, col 30, endline 11, value 5, decompile 1.

The pair yields are optimistic in two named ways: PreprocTest d/t is counted for pair B although pass 180 (its R8)
found the face (the `bit` keyword lexed as an identifier in a `.vh` file without `-sv`) not implementable on this
ground, and InterfArrayBind d is counted for pair A although pass 181 (its S4) found the ModuleEmit half (the
elaborated listing sharing the definition's continuous assignment) needed too. Without those two, everything clears 23
row-modes instead of 26.

## 6. Ranked OPEN clusters with sites (on top of r11u183 measured + both pairs optimistic)

Columns: `rows left` = row-modes the cluster still carries after r11u183 and the pairs (rows at 2b97649e in
parentheses); `first-open heads` = rows it is the first OPEN record of; `alone` = rows it clears alone on top of
everything; `probe` = its cases after r11u183. The whole list is cluster_index.csv.

**465 OPEN clusters still carry a row** (ground A 195, B 266, unpinned 4). The list by rows is dominated by the UVM
family (9 row-modes, 5 tests), so it is given three ways: T1 by all rows, T1b over the rows outside the big families
(UVM, Earlgrey_0_1, Rggen, BlackBePipeInt, Scr1SvTests, ApbSlave, SVSwitch), and T1c per ground.

### T1. Ranked OPEN clusters, all rows (top 30 of 465)

| # | cluster | rows left (2b97649e) | sl/u2r | tests | families | first-open heads | alone | probe (after r11u183) | ground | status | key | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0072 | 11 (11) | 11/0 | 6 | UVM | 0 | 0 | 2 | B | OPEN (map 9 ground-B step 6) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law classHandleRetTsNameUnlessSameHomeComponent156) < emitClassDefn (UhdmExpo |
| 2 | N0039 | 10 (10) | 10/0 | 6 | Rggen UVM | 0 | 0 | 156 | B | OPEN | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law splitPortIntRedeclLogicTs180) < emitTaskFuncs (TaskFuncEmit.cpp, law impCloneD |
| 3 | N0040 | 9 (9) | 7/2 | 5 | Earlgrey Rggen Scr1 | 3 | 2 | 34 | B | OPEN (map 9 ground-A+B step 14) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 4 | N0219 | 9 (9) | 7/2 | 5 | UVM ibex | 2 | 2 | 0 | B | OPEN (map 9 gave it to r11u176) | `file\|struct_typespec\|other-file+span\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInline |
| 5 | N0228 | 9 (9) | 9/0 | 5 | UVM | 7 | 0 | 0 | A | OPEN | `span\|hier_path\|endcol\|under:bit_select` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < em |
| 6 | N0215 | 9 (9) | 9/0 | 5 | UVM | 2 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124 |
| 7 | N0051 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 9 | B | OPEN | `span\|class_typespec\|endcol\|under:ref_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (UhdmExporter |
| 8 | N0031 | 9 (15) | 9/6 | 8 | UVM jeras | 0 | 0 | 7 | B | OPEN (map 9 ground-A+B step 8) [r11u183: rows 15->9] | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp,  |
| 9 | N0042 | 9 (13) | 9/4 | 7 | UVM | 0 | 0 | 7 | B | OPEN [r11u183: rows 13->9] | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExporter.cpp,  |
| 10 | N0132 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 7 | B | OPEN | `span\|int_typespec\|line+endline\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitClassParameters (UhdmExporter.cpp, law classTpT |
| 11 | N0161 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 6 | B | OPEN | `fullname\|ref_typespec\|tok:id::->\|under:class_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law sharedAliasNoStamp41) < makeTypespec (TypeEmit.cpp, law classTdLoca |
| 12 | N0170 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 5 | B | OPEN | `span\|class_var\|col+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitPackageClassMethodClon |
| 13 | N0171 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 5 | B | OPEN | `struct\|golden-only:fewer-copies\|bit_typespec\|under:ref_typespec` | namedElemPackedDimTs31 (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypeParamDefaultTs (TypeEmit.cpp, law  |
| 14 | N0757 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 4 | B | OPEN | `span\|typespec_member\|endcol\|under:struct_typespec` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTypedefs (TypeEmit.cpp, law bodyTypede |
| 15 | N0071 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | A | OPEN | `span\|hier_path\|endcol\|under:operation` | emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue1 |
| 16 | N0103 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 9 ground-B step 6) | `name\|class_typespec\|ours-empty\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law classHandleRetTsNameUnlessSameHomeComponent156) < emitClassDefn (UhdmExpo |
| 17 | N0175 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | A | OPEN (map 9 gave it to r11u178) | `fullname\|ref_obj\|tok:id[id].id::->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitMixedHierPath (ExprEmit.cpp, law hpMidSelIdxAtPath7 |
| 18 | N0180 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN | `fullname\|ref_typespec\|ours-empty\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListin |
| 19 | N0109 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | A | OPEN | `file\|string_typespec\|ours-empty\|under:ref_typespec` | operator() (StmtEmit.cpp, law classPropUnitImport21) < emitStmt (StmtEmit.cpp, law foreachLoopVarObjs9) < emit |
| 20 | N0110 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | A | OPEN | `span\|string_typespec\|ours-zero\|under:ref_typespec` | operator() (StmtEmit.cpp, law classPropUnitImport21) < emitStmt (StmtEmit.cpp, law foreachLoopVarObjs9) < emit |
| 21 | N0158 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `depth\|bit_typespec\|ref_typespec->ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDe |
| 22 | N0168 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `span\|int_typespec\|col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitClassParameters (UhdmExporter.cpp, law classTpT |
| 23 | N0177 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `struct\|ours-only:absent\|bit_typespec\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDe |
| 24 | N0184 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `span\|bit_var\|col+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law assocLocalArrayVar40) < emitPackage (ParamEmit.cpp, law LAW) < exportDesi |
| 25 | N0188 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `name\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecLis |
| 26 | N0185 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 1 | A | OPEN | `span\|constant\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < operator() (StmtEmit.cpp, law declInitWrittenNewNoStmt66) < emit |
| 27 | N0193 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 1 | A | OPEN | `span\|hier_path\|endcol\|under:return_stmt` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law shellCallKeepsItsSyntax167) < e |
| 28 | N0196 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 1 | A | OPEN | `fullname\|ref_obj\|tok:id.id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law cloneBuiltinMethodArgBind |
| 29 | N0199 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 1 | A | OPEN | `fullname\|bit_select\|tok:id.id::->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law cloneBuiltinMethodArgBindsRecei |
| 30 | N0207 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 1 | A | OPEN | `fullname\|ref_obj\|tok:::->.\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law genCaSysCallArgBinds22) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) |

### T1b. Ranked OPEN clusters on the rows outside the big families (top 25)

| # | cluster | rows outside the big families (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0627 | 4 (2) | 4 | 0 | 0 | B | OPEN (map 9 ground-A+B step 15) | `fullname\|property_decl\|tok:id.id.id->id\|under:module_inst` | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDesign (UhdmExporter.cpp, law im |
| 2 | N0040 | 4 (5) | 2 | 2 | 34 | B | OPEN (map 9 ground-A+B step 14) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law |
| 3 | N0133 | 4 (2) | 2 | 0 | 10 | B | OPEN (map 9 ground-B step 9) | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law unnam |
| 4 | N0090 | 4 (4) | 2 | 0 | 0 | B | OPEN (map 9 ground-A+B step 16) | `span\|logic_typespec\|endline+endcol\|under:ref_typespec` | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEm |
| 5 | N0487 | 4 (2) | 0 | 0 | 10 | B | OPEN (map 9 ground-B step 9) | `struct\|ours-only:absent\|constant\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgUnvaluedActualLitRetFold8) < emitInstance (ModuleEmit.cpp,  |
| 6 | N0431 | 4 (3) | 0 | 0 | 0 | B | OPEN (map 9 ground-A+B step 15) | `fullname\|assert_stmt\|tok:id.id.id->id\|under:module_inst` | emitAssertion (ModuleEmit.cpp, law genProcParamFold) < emitModuleDef (ModuleEmit.cpp, law shadowedIm |
| 7 | N0263 | 2 (3) | 2 | 0 | 59 | B | OPEN | `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec (TypeEmit.cpp, law typeParam |
| 8 | N0738 | 2 (1) | 2 | 0 | 36 | B | OPEN (map 9 ground-A+B step 11) | `name\|logic_typespec\|tok:id::->\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs (ParamEmit.cpp, law pkgParamOwn |
| 9 | N0129 | 2 (2) | 2 | 2 | 15 | A | OPEN (map 9 ground-B step 4) | `fullname\|ref_typespec\|tok:->.id\|under:constant` | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldN |
| 10 | N0448 | 2 (3) | 2 | 0 | 3 | B | OPEN (map 9 ground-A+B step 17) | `span\|constant\|endcol\|under:range` | operator() (TypeEmit.cpp, law shadowedImportParamFold) < makeTypespec (TypeEmit.cpp, law typedPkgBou |
| 11 | N0023 | 2 (1) | 2 | 2 | 1 | B | OPEN (map 9 ground-A+B step 18) | `struct\|ours-only:elsewhere\|logic_net\|under:ref_obj` | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law |
| 12 | N0820 | 2 (1) | 2 | 2 | 1 | A | OPEN (map 9 ground-A+B step 1) | `fullname\|ref_obj\|tok:id[id].id[n - id][n:n].id.->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 13 | N0219 | 2 (5) | 2 | 2 | 0 | B | OPEN (map 9 gave it to r11u176) | `file\|struct_typespec\|other-file+span\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRng |
| 14 | N0422 | 2 (1) | 2 | 0 | 0 | B | OPEN (map 9 ground-B step 12) | `span\|logic_typespec\|endline+endcol\|under:package` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage (ParamEmit.cpp, law aggRngSkipI |
| 15 | N0563 | 2 (2) | 2 | 0 | 0 | B | OPEN (map 9 ground-A+B step 23) | `fullname\|ref_typespec\|tok:::id::id::->.id::id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, l |
| 16 | N0817 | 2 (1) | 2 | 0 | 0 | B | OPEN | `fullname\|ref_typespec\|tok:->id.id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, l |
| 17 | N0912 | 2 (1) | 2 | 0 | 0 | B | OPEN | `fullname\|ref_obj\|ours-empty\|under:assignment` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < operator() (ModuleEmit.cpp, law genSynta |
| 18 | N1096 | 2 (1) | 2 | 0 | 0 | A | OPEN (map 9 gave it to r11u178) | `span\|ref_obj\|endcol\|under:tagged_pattern` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law r10fsv2) < emitPa |
| 19 | N1127 | 2 (1) | 2 | 0 | 0 | B | OPEN (map 9 ground-A+B step 20) | `fullname\|ref_typespec\|tok:->id@id.id.id.\|under:hier_path` | operator() (TypeEmit.cpp, law ovHopBareActualElabFold40) < operator() (TypeEmit.cpp, law ovHopBareAc |
| 20 | N1134 | 2 (1) | 2 | 0 | 0 | B | OPEN (map 9 ground-A+B step 24) | `fullname\|struct_net\|golden-empty\|under:io_decl` | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) < emitInstance (ModuleEmit.cpp, law modp |
| 21 | N1081 | 2 (1) | 1 | 0 | 0 | B | OPEN | `span\|class_typespec\|endline+endcol\|under:ref_typespec` | exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < main (uhdm_main.cpp, law genCaP |
| 22 | N0085 | 2 (2) | 0 | 0 | 31 | A | OPEN (map 9 ground-A+B step 11) | `struct\|ours-only:fewer-copies\|ref_typespec\|under:logic_typespec` | makeParamTs (ParamEmit.cpp, law pkgParamOwnDefRange) < drainDefParamTs (ParamEmit.cpp, law paramClon |
| 23 | N0083 | 2 (3) | 0 | 0 | 23 | B | OPEN (map 9 ground-B step 12) [r11u183: rows 6->2] | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typePara |
| 24 | N0484 | 2 (2) | 0 | 0 | 13 | B | OPEN (map 9 ground-B step 12) | `name\|logic_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |
| 25 | N0025 | 2 (4) | 0 | 0 | 10 | B | OPEN | `depth\|constant\|range->operation` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbol |

### T1c. Per ground, all rows (top 20 each)

Ground A (ExprEmit / EmitHelpers / StmtEmit / ParamEmit):

| # | cluster | rows (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0228 | 9 (5) | 7 | 0 | 0 | A | OPEN | `span\|hier_path\|endcol\|under:bit_select` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSynt |
| 2 | N0215 | 9 (5) | 2 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 3 | N0071 | 9 (5) | 0 | 0 | 3 | A | OPEN | `span\|hier_path\|endcol\|under:operation` | emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < emitExpr (ExprEmit.cpp, law incDecMemberPat |
| 4 | N0175 | 9 (5) | 0 | 0 | 3 | A | OPEN (map 9 gave it to r11u178) | `fullname\|ref_obj\|tok:id[id].id::->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitMixedHierPath (ExprEmit.cpp, law hpMidSel |
| 5 | N0109 | 9 (5) | 0 | 0 | 2 | A | OPEN | `file\|string_typespec\|ours-empty\|under:ref_typespec` | operator() (StmtEmit.cpp, law classPropUnitImport21) < emitStmt (StmtEmit.cpp, law foreachLoopVarObj |
| 6 | N0110 | 9 (5) | 0 | 0 | 2 | A | OPEN | `span\|string_typespec\|ours-zero\|under:ref_typespec` | operator() (StmtEmit.cpp, law classPropUnitImport21) < emitStmt (StmtEmit.cpp, law foreachLoopVarObj |
| 7 | N0185 | 9 (5) | 0 | 0 | 1 | A | OPEN | `span\|constant\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < operator() (StmtEmit.cpp, law declInitWrittenNewNoStmt |
| 8 | N0193 | 9 (5) | 0 | 0 | 1 | A | OPEN | `span\|hier_path\|endcol\|under:return_stmt` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law shellCallKeepsItsSynt |
| 9 | N0196 | 9 (5) | 0 | 0 | 1 | A | OPEN | `fullname\|ref_obj\|tok:id.id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law cloneBuiltinMet |
| 10 | N0199 | 9 (5) | 0 | 0 | 1 | A | OPEN | `fullname\|bit_select\|tok:id.id::->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law cloneBuiltinMethodArg |
| 11 | N0207 | 9 (5) | 0 | 0 | 1 | A | OPEN | `fullname\|ref_obj\|tok:::->.\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law genCaSysCallArgBinds22) < emitExpr (ExprEmit.cpp, law incDecMemberPathIs |
| 12 | N0054 | 9 (5) | 0 | 0 | 0 | A | OPEN | `span\|assignment\|endcol\|under:begin` | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCo |
| 13 | N0123 | 9 (5) | 0 | 0 | 0 | A | OPEN | `file\|int_typespec\|other-file+span\|under:ref_typespec` | makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator() (ParamEmit.cpp, law pkgUntyp |
| 14 | N0183 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id[id + n].id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 15 | N0192 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 16 | N0197 | 9 (5) | 0 | 0 | 0 | A | OPEN | `struct\|golden-only:fewer-copies\|string_typespec\|under:ref_typespec` | operator() (StmtEmit.cpp, law foreachAssocIdxAliasTs22) < emitStmt (StmtEmit.cpp, law foreachLoopVar |
| 17 | N0217 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id::->\|under:bit_select` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law dottedIdxRecvFrom |
| 18 | N0220 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id[id].id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 19 | N0222 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|bit_select\|tok:id - n->id-n\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) |
| 20 | N0224 | 9 (5) | 0 | 0 | 0 | A | OPEN | `span\|ref_obj\|col\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSynt |

Ground B (TypeEmit / ModuleEmit / UhdmExporter / TaskFuncEmit / uhdm_main):

| # | cluster | rows (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0072 | 11 (6) | 0 | 0 | 2 | B | OPEN (map 9 ground-B step 6) | `span\|class_typespec\|line+col+endline+endcol\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law classHandleRetTsNameUnlessSameHomeComponent156) < emitClassDefn |
| 2 | N0039 | 10 (6) | 0 | 0 | 156 | B | OPEN | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law splitPortIntRedeclLogicTs180) < emitTaskFuncs (TaskFuncEmit.cpp, law |
| 3 | N0040 | 9 (5) | 3 | 2 | 34 | B | OPEN (map 9 ground-A+B step 14) | `span\|logic_typespec\|endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law |
| 4 | N0219 | 9 (5) | 2 | 2 | 0 | B | OPEN (map 9 gave it to r11u176) | `file\|struct_typespec\|other-file+span\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRng |
| 5 | N0051 | 9 (5) | 0 | 0 | 9 | B | OPEN | `span\|class_typespec\|endcol\|under:ref_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < emitClassTypedefs (Uh |
| 6 | N0031 | 9 (8) | 0 | 0 | 7 | B | OPEN (map 9 ground-A+B step 8) [r11u183: rows 15->9] | `file\|constant\|ours-empty\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExpo |
| 7 | N0042 | 9 (7) | 0 | 0 | 7 | B | OPEN [r11u183: rows 13->9] | `span\|constant\|ours-zero\|under:range` | operator() (UhdmExporter.cpp, law classNestedClassTdGroupNoAnchor54) < emitClassParameters (UhdmExpo |
| 8 | N0132 | 9 (5) | 0 | 0 | 7 | B | OPEN | `span\|int_typespec\|line+endline\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitClassParameters (UhdmExporter.cpp, la |
| 9 | N0161 | 9 (5) | 0 | 0 | 6 | B | OPEN | `fullname\|ref_typespec\|tok:id::->\|under:class_typespec` | buildClassTypedefTs (UhdmExporter.cpp, law sharedAliasNoStamp41) < makeTypespec (TypeEmit.cpp, law c |
| 10 | N0170 | 9 (5) | 0 | 0 | 5 | B | OPEN | `span\|class_var\|col+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law qualifiedLifetimeMethodLosesNamePortsBody46) < emitPackageClass |
| 11 | N0171 | 9 (5) | 0 | 0 | 5 | B | OPEN | `struct\|golden-only:fewer-copies\|bit_typespec\|under:ref_typespec` | namedElemPackedDimTs31 (TypeEmit.cpp, law crossPkgRangeBoundFold) < makeTypeParamDefaultTs (TypeEmit |
| 12 | N0757 | 9 (5) | 0 | 0 | 4 | B | OPEN | `span\|typespec_member\|endcol\|under:struct_typespec` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitTypedefs (TypeEmit.cpp, law  |
| 13 | N0103 | 9 (5) | 0 | 0 | 3 | B | OPEN (map 9 ground-B step 6) | `name\|class_typespec\|ours-empty\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law classHandleRetTsNameUnlessSameHomeComponent156) < emitClassDefn |
| 14 | N0180 | 9 (5) | 0 | 0 | 3 | B | OPEN | `fullname\|ref_typespec\|ours-empty\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law classPkgGeneric |
| 15 | N0158 | 9 (5) | 0 | 0 | 2 | B | OPEN | `depth\|bit_typespec\|ref_typespec->ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |
| 16 | N0168 | 9 (5) | 0 | 0 | 2 | B | OPEN | `span\|int_typespec\|col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitClassParameters (UhdmExporter.cpp, la |
| 17 | N0177 | 9 (5) | 0 | 0 | 2 | B | OPEN | `struct\|ours-only:absent\|bit_typespec\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |
| 18 | N0184 | 9 (5) | 0 | 0 | 2 | B | OPEN | `span\|bit_var\|col+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law assocLocalArrayVar40) < emitPackage (ParamEmit.cpp, law LAW) <  |
| 19 | N0188 | 9 (5) | 0 | 0 | 2 | B | OPEN | `name\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGene |
| 20 | N0209 | 9 (5) | 0 | 0 | 1 | B | OPEN | `span\|int_typespec\|line+col+endline\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law shadowedImportBoundFold) < emitTaskFuncs (TaskFuncEmit.cpp, law impC |

Probe-only OPEN clusters with the most cases after r11u183: N1897 (119, B: `fullname|logic_net|tok:.id@id->|under:module_inst`,
laws caNestedModPortedDefShell101 / caTopNamesakeKeyAtEntry105), N1898 (92, B), N1899 (51, B), N0094 (51, B), N1900 (50, B),
N1901 (45, B), N1902 (37, A), N0739 (27, A), N1903 (21, A), N1904 (20, A), N1905 (17, B), N1907 (15, B), N1909 (14, A),
N1908 (14, B) ([evidence/report.txt](evidence/report.txt) section 4). Laws with the most NE cases: badConcatOperandsFromSyntax160
71/71, caNestedModPortedDefShell101 36/38, portViewRangeRecvParams 34/55, srlgCondOpInstValueTernFold9 32/140,
nestedParamActualTs6 29/41, tpPackedArrayTsVar108 29/73, caIfacePortDeclNetMint93 27/35, caTopNamesakeKeyAtEntry105 26/27.
The probe cases by first cluster:

| first cluster | probe cases it heads | clears (r11u183 / pairs) | ground | status | key | top laws |
|---|---|---|---|---|---|---|
| N1897 | 106 | no 106 | B | OPEN | `fullname\|logic_net\|tok:.id@id->\|under:module_inst` | caNestedModPortedDefShell101:36 caTopNamesakeKeyAtEntry105:26 caNested |
| N0127 | 79 | yes r11u183 64, no 15 | B | OPEN [r11u183: rows 10->0] | `span\|array_typespec\|endcol\|under:ref_typespec` | portViewRangeRecvParams:34 sizeDimOvrChain4:24 ifaceArrayElemViewFolds |
| N0039 | 78 | no 78 | B | OPEN | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | badConcatOperandsFromSyntax160:57 nestedParamActualTs6:22 classNestedT |
| N0151 | 69 | no 59, yes r11u183 10 | B | OPEN (map 9 gave it to r11u176) [r11u183: rows 7-> | `struct\|golden-only:fewer-copies\|ref_typespec\|under:parameter` | badConcatOperandsFromSyntax160:66 impFoldRhsMirrorsLhsTs201:7 unitImpo |
| N0263 | 54 | no 54 | B | OPEN | `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` | caIfacePortDeclNetMint93:26 tpPackedArrayTsVar108:5 tpPackedArrayTsVar |
| N0284 | 44 | no 44 | B | OPEN | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` | srlgUnvaluedActualLitRetFold8:19 loopCaParamReadKeepsLiteral116:10 caS |
| N0067 | 42 | yes r11u183 33, no 6, yes pair B 2, yes pair A 1 | B | COVERED r11u186 (map 9 ground-B remainder (ApbSlav | `file\|class_typespec\|ours-empty\|under:ref_typespec` | foreachLoopListStopsAtFirstSelect134:4 thisSuperNewAssignEmpty121:4 wi |
| N0003 | 30 | no 24, yes pairs A+B 6 | A | COVERED r11u184 (map 9 ground-A remainder (r11u178 | `fullname\|ref_typespec\|golden-empty\|under:operation` | patParamEvalFuncRead26:12 patParamLeftoverShare26:6 catParamLeftoverRe |
| N0040 | 29 | no 29 | B | OPEN (map 9 ground-A+B step 14) | `span\|logic_typespec\|endcol\|under:ref_typespec` | nestedParamActualTs6:18 caIfaceNdaNameFoldsToParamValue88:5 caIfaceEla |
| N0738 | 27 | no 27 | B | OPEN (map 9 ground-A+B step 11) | `name\|logic_typespec\|tok:id::->\|under:ref_typespec` | pkgTdQualParamCopiesListing111:11 defPkgMemberTdOfNamedShares108:8 tpP |
| N0739 | 26 | no 26 | A | OPEN | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | pkgRhsStructBareCopy111:14 defPkgMemberTdOfNamedShares108:11 tpPackedA |
| N0474 | 25 | yes pair A 25 | A | COVERED r11u184 (map 9 ground-A remainder (r11u178 | `fullname\|ref_typespec\|tok:->.id[n]\|under:constant` | genCaOpFoldElabTs115:16 caSysArgOpFoldTs115:5 genCaTopLoopParamPaCopy1 |
| N0264 | 24 | yes r11u183 18, no 6 | B | OPEN [r11u183: rows 8->2] | `span\|int_typespec\|endcol\|under:ref_typespec` | interfaceDefViewNeverLateBinds223v:6 importedFreeCallTakesFirstListing |
| N1169 | 23 | no 23 | B | OPEN | `file\|constant\|ours-empty\|under:cont_assign` | srlgCondOpInstValueTernFold9:22 caTernFillArmKeepsEncoding19:1 |
| N0443 | 15 | yes pair A 13, no 2 | A | COVERED r11u184 (map 9 ground-A remainder: arb_idx | `fullname\|ref_typespec\|tok:.id.id->\|under:constant` | genLpIdxOpOperandFold112:12 genCaParamFoldOneHopPool95:1 genElseArmCol |
| N0129 | 14 | no 14 | A | OPEN (map 9 ground-B step 4) | `fullname\|ref_typespec\|tok:->.id\|under:constant` | genCaOpFoldElabTs115:6 insideSetFirstRangeTruncates99:2 caSysArgOpFold |
| N1911 | 14 | no 14 | B | OPEN | `fullname\|type_parameter\|tok:->id::@in-typespec\|under:class_typespec` | classTdCloneSpecOverridesOwnArgs112:14 |
| N0682 | 12 | no 12 | A | COVERED r11u184 (map 9 ground-A remainder, UVM: th | `fullname\|ref_typespec\|tok:->id::\|under:parameter` | impFoldRhsMirrorsLhsTs201:7 impUnsizedBasedLhsNoTs199:3 unitImportHois |
| N1916 | 12 | no 12 | B | OPEN | `struct\|golden-only:fewer-copies\|logic_net\|under:cont_assign` | caIfaceNdaNameFoldsToParamValue88:9 caIfaceElabNetDeclAssignListing88: |
| N0485 | 11 | no 11 | B | OPEN | `fullname\|int_var\|tok:id->id\|under:function` | pkgVarInitCmViewClone111:5 cloneBodyIsAScopeEvenWithNoOwnLocals181:3 c |

## 7. The fail list with sites (fail_list.csv, probe_fail_list.csv)

Every STRICT_NOTEQUAL row-mode with its first cluster (at 2b97649e), that cluster's coverage, ground and site, all its
clusters, the strict cell after r11u183, its first OPEN cluster after the pairs, the open clusters left and whether it
clears (r11u183 measured / pair A / pair B / both, optimistic). probe_fail_list.csv is the same per probe case (1192).
By test, sorted by cluster count (a `-` mode is not NE):

| corpus | test | cell d / t | clusters d/t | first cluster (ground) | first site | after r11u183 | first open after the pairs | open after pairs | clears | downstream |
|---|---|---|---|---|---|---|---|---|---|---|
| sur | ArrayMethodIterator | differ:endcol(1) / differ:endcol(1) | 1/1 | N0097 (A) | emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) < emitExpr (E | equal (r11u183, measured) / equal (r11u183, measured) | - | 0/0 | yes (r11u183, measured) | - |
| sur | HierPathTypespec | - / differ:fullname(1) | -/1 | N1174 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | - | -/0 | yes (pair B, optimistic) | - |
| sur | InterfArrayBind | differ:fullname(3) / - | 1/- | N0427 (A) | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp, law genCaParamFo | same | - | 0/- | yes (pair A, optimistic) | - |
| sur | InterfaceModPort | differ:endcol(12) / differ:endcol(12) | 1/1 | N0040 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedP | same | N0040 | 1/1 | no | - |
| sur | PreprocTest | differ:endcol(2) / differ:endcol(2) | 1/1 | N0056 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (Para | same | - | 0/0 | yes (pair B, optimistic) | - |
| sur | StructParamPatternInitCast | differ:fullname(3) / differ:fullname(3) | 2/2 | N0003 (A) | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitIn | same | - | 0/0 | yes (pairs A+B, optimistic) | - |
| sur | UnitElabBlock | differ:endline(13) / differ:endline(12) | 3/2 | N0090 (B) | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduc | same | N0090 | 3/2 | no | - |
| sur | FuncStructValSimple | differ:file(39) / differ:file(59) | 3/3 | N0086 (A) | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) <  | same | - | 0/0 | yes (pair A, optimistic) | - |
| sur | ApbSlave | differ:depth(1) / differ:depth(1) | 4/4 | N0289 (B) | makeVar (TypeEmit.cpp, law tpPackedArrayTsVarInit110) < emitPackageVar | equal (r11u183, measured) / equal (r11u183, measured) | - | 0/0 | yes (r11u183, measured) | - |
| sur | AssertDelayError | differ:fullname(48) / differ:fullname(66) | 4/5 | N0627 (B) | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDe | same | N0627 | 2/3 | no | - |
| sur | AssertTempError | differ:fullname(28) / differ:fullname(38) | 4/5 | N0627 (B) | emitModuleDef (ModuleEmit.cpp, law shadowedImportParamFold) < exportDe | same | N0627 | 2/3 | no | - |
| sur | LogicTypespec | differ:endline(3) / differ:endline(3) | 4/4 | N0422 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage ( | same | N0422 | 4/4 | no | - |
| sur | InterfaceStructMemberPort | differ:fullname(6) / differ:fullname(6) | 5/5 | N1134 (B) | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) < emitInst | same | N1134 | 5/5 | no | - |
| sur | FuncStructVal | differ:endcol(95) / differ:endcol(165) | 7/8 | N1096 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprE | same | N1096 | 3/4 | no | - |
| sur | ClassTypeParam | differ:endline(17) / differ:file(30) | 8/10 | N1081 (B) | exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < m | same | N1081 | 8/10 | no | - |
| sur | SVSwitch | differ:file(15) / differ:file(15) | 12/12 | N0067 (B) | classElemVar (UhdmExporter.cpp, law sharedAliasNoStamp41) < emitClassD | differ:fullname(13) / differ:fullname(13) | N0090 | 8/8 | no | - |
| sur | Scr1SvTests | differ:type(1) / differ:type(1) | 22/22 | N0965 (A) | emitExpr (ExprEmit.cpp, law pkgQualParamPartSelName118) < emitExpr (Ex | same | N0448 | 19/19 | no | - |
| sur | BlackBePipeInt | differ:fullname(2) / differ:fullname(2) | 27/25 | N0923 (A) | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefModuleCopy) | same | N0923 | 26/24 | no | - |
| sur | Rggen | differ:endcol(634) / - | 48/- | N0127 (B) | makeIfaceArrayPortTs (ModuleEmit.cpp, law sizeDimOvrChain4) < emitPort | differ:endcol(696) / - | N0040 | 43/- | no | - |
| sur | Earlgrey_0_1 | differ:col(102) / differ:col(102) | 78/76 | N1082 (A) | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator( | same | N1082 | 66/65 | no | - |
| sur | BuildUVMPkg | differ:fullname(23) / differ:fullname(23) | 112/112 | N0164 (B) | bareScalarTdCopyOf (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52)  | differ:col(22) / differ:col(22) | N0215 | 92/92 | no | - |
| sur | Scoreboard | differ:fullname(23) / - | 129/- | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitPackage (P | differ:fullname(56) / - | N0228 | 104/- | no | - |
| sur | SimpleUVM | differ:fullname(23) / differ:fullname(23) | 136/136 | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitPackage (P | differ:fullname(56) / differ:fullname(56) | N0228 | 110/110 | no | - |
| sur | SeqDriver | differ:fullname(7) / differ:fullname(7) | 242/242 | N0164 (B) | bareScalarTdCopyOf (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52)  | differ:col(28) / differ:col(28) | N0228 | 218/218 | no | - |
| sur | MiniAmiq | differ:fullname(8) / differ:fullname(8) | 247/247 | N0164 (B) | bareScalarTdCopyOf (TypeEmit.cpp, law bodyTypedefElemBoundSymbolic52)  | differ:file(29) / differ:file(29) | N0228 | 221/221 | no | - |
| uhd | iface_zero_width_field | differ:fullname(3) / differ:fullname(3) | 1/1 | N0688 (A) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | - | 0/0 | yes (pair A, optimistic) | IDENTICAL |
| uhd | anon_struct_packed_dim | differ:fullname(43) / differ:fullname(43) | 2/2 | N0014 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | N0820 | 1/1 | no | IDENTICAL |
| uhd | const_cast_signext | differ:type(1) / differ:type(1) | 2/2 | N0133 (B) | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInsta | same | N0133 | 2/2 | no | IDENTICAL |
| uhd | func_typename_ret | differ:name(2) / differ:name(2) | 2/2 | N0738 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs ( | same | N0738 | 2/2 | no | IDENTICAL |
| uhd | ibex_multdiv_fast | differ:file(11) / differ:file(11) | 2/2 | N0545 (A) | emitExpr (ExprEmit.cpp, law uninstIfaceEnumConstNoActual221) < emitExp | same | - | 0/0 | yes (pair A, optimistic) | IDENTICAL |
| uhd | ibex_pmp | differ:file(5) / differ:file(5) | 2/2 | N0219 (B) | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPack | same | N0219 | 1/1 | no | IDENTICAL |
| uhd | jeras_union | differ:fullname(75) / differ:fullname(75) | 2/2 | N0938 (A) | emitPackage (ParamEmit.cpp, law aggRngSkipInlineBody124v) < exportDesi | equal (r11u183, measured) / equal (r11u183, measured) | - | 0/0 | yes (r11u183, measured) | IDENTICAL |
| uhd | TypeParameterAsPortTypeWithEnum | differ:file(8) / differ:file(8) | 3/3 | N0012 (A) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters | same | - | 0/0 | yes (pair A, optimistic) | IDENTICAL |
| uhd | rsp_gen_minimal | differ:fullname(2) / differ:fullname(2) | 3/3 | N0416 (A) | emitExpr (ExprEmit.cpp, law packageVarAutomaticIsDataDeclShape26) < em | same | N0023 | 1/1 | no | IDENTICAL |
| uhd | OutputSizeWithParameterOfInstanceInitializedByStructMember | differ:line(8) / differ:line(8) | 4/4 | N0191 (A) | emitDroppedCall14 (StmtEmit.cpp, law classArgBind12) < emitBadConcatFr | same | N1127 | 2/2 | no | IDENTICAL |
| uhd | TypeParameterAsPortTypeWithEnumOfParametrizedWidth | differ:file(6) / differ:file(6) | 4/4 | N0012 (A) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitParameters | same | - | 0/0 | yes (pair A, optimistic) | IDENTICAL |
| uhd | arb_idx_cast | differ:endcol(17) / differ:endcol(17) | 4/4 | N0448 (B) | operator() (TypeEmit.cpp, law shadowedImportParamFold) < makeTypespec  | same | N0448 | 2/2 | no | IDENTICAL |
| uhd | ibex_icache | differ:fullname(49) / differ:fullname(49) | 5/5 | N0415 (A) | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitExpr (ExprEmit | same | N0129 | 1/1 | no | IDENTICAL |
| uhd | ibex_tracer | differ:fullname(579) / differ:fullname(579) | 6/6 | N0563 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | N0563 | 5/5 | no | IDENTICAL |
| uhd | cfg_func_width_loop | differ:line(3) / differ:line(3) | 7/7 | N0263 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespe | same | N0263 | 7/7 | no | IDENTICAL |
| uhd | struct_param_func_config | differ:fullname(5) / differ:fullname(5) | 7/7 | N0817 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | N0817 | 7/7 | no | IDENTICAL |
| uhd | int_types | differ:fullname(82) / differ:fullname(82) | 8/8 | N0912 (B) | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < operator() | same | N0912 | 7/7 | no | IDENTICAL |
| uhd | ParameterFromPkgInNestedModule | differ:fullname(7) / differ:fullname(7) | 10/10 | N0536 (A) | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitContAssigns (M | equal (r11u183, measured) / equal (r11u183, measured) | - | 0/0 | yes (r11u183, measured) | IDENTICAL |
| uhd | ParameterFromPkgOnParameterPortList | differ:fullname(7) / differ:fullname(7) | 10/10 | N0536 (A) | emitExpr (ExprEmit.cpp, law caPartSelBoundFoldTs) < emitContAssigns (M | equal (r11u183, measured) / equal (r11u183, measured) | - | 0/0 | yes (r11u183, measured) | IDENTICAL |

## 8. Structural rows and downstream-visible faces

### 8a. Structural rows (first field depth / type / count)

| row | 2b97649e | after r11u183 | first cluster | what it needs |
|---|---|---|---|---|
| ApbSlave d/t | `depth(1)` | **CMP_EQUAL** | N0289 `struct\|ours-only:fewer-copies\|string_var\|under:ref_obj` | cleared by r11u183 (law defCloneRefsBindDefListing183 + law importNetTsToInitEnd183 on top of pass 176's extern-prototype law); both patches needed (lawA alone reads `file(4)`, lawB alone `depth(1)`) |
| Scr1SvTests d/t | `type(1)` | `type(1)` | N0965 `struct\|golden-only:fewer-copies\|ref_typespec\|under:indexed_part_select` (A) | pass 181 R5 decoded the producer: UHDM `ExprEval::evalFunc` mints a `ref_typespec` to the FORMAL's typespec on every argument of a function Surelog constant-evaluates, mutating the source object when `reduceExpr` returns it (`din[(i+1)*2-1-:2]` in `scr1_search_one_2`, called from `scr1_search_one_16`). Unlanded; pair A r11u184's brief. Behind it 18 more clusters (N0448 first, then N0284's `assign` constant, the `other-file` operations) |
| const_cast_signext d/t (u2r) | `type(1)` | `type(1)` | N0133 `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` (B pin; decode ExprEmit) | pass 180 S3: golden keeps `func_call sext(OP_F)` in the elaborated cont_assign where ours folds the constant function call; with N0487 (the folded constant ours adds). No landed or unlanded law covers it. Downstream IDENTICAL |

No row is `count` or `stage1`. The probe set holds 104 `depth` and 71 `type` first fields at 2b97649e, 32 `depth` and 73
`type` after r11u183 (r11u183's depth law and the typespec-copy laws move 72 depth heads on to their next field).

### 8b. Downstream-visible faces ([drivers/dsfaces.py](drivers/dsfaces.py): the gate's own `one()`, fresh `GOLDEN_CACHE`, both binaries; [evidence/sweeps/dsfaces_P.csv](evidence/sweeps/dsfaces_P.csv), [dsfaces_L.csv](evidence/sweeps/dsfaces_L.csv))

**No verdict differs between the pristine and the law183 binary on any of the 74 cases**, and no corpus row changes
verdict (section 3). Pristine verdicts: 54 IDENTICAL, 9 EQUIVALENT, 6 DIVERGENT, 5 STATUS_DIFF.

| face | cases | verdict at 2b97649e (= law183) | what it needs |
|---|---|---|---|
| r11u173 N1: a range query onto an implicit net in a generate-for (`assign ccc = $high(a)`) | r11u173verify/cases/rq/q08 (q03 the declared-net control) | **q08 DIVERGENT** (nohier); q03 IDENTICAL | ModuleEmit's generate-scope cont_assign emission has no sysFold branch (ground B); unchanged since map 8 |
| r11u173 N2: `g[S.a].x`, a hier path into a generate array indexed by a struct-parameter member | r11u173verify/cases/hw/w12, w13 | **w12, w13 DIVERGENT** (nohier; stage 1 as well) | the index fold of a struct-parameter member inside a hier_path (ExprEmit path builders, ground A); not decoded |
| pass 158: the size cast as a whole continuous-assign value | r11u158repro/cases/sc c1-c17 | 15 IDENTICAL; **c10, c12 EQUIVALENT** (nohier) | c10 = pass 158 S2 (gen-if `3'(-1)`, ModuleEmit emitBlock's gen-CA branch); c12 = S3 (instance-overridden width `W'(7)`, ModuleEmit emitContAssigns). Unchanged since map 8 |
| pass 160: the LogicTypespec Surelog-defect candidate | r11u160repro/evidence/residue/LT l01, l02 (run from scratch copies) | l01 IDENTICAL; **l02 DIVERGENT** (`$bits(x)` 2 on the Surelog lane, 32 on ours) | following golden changes a netlist toward a Surelog defect: a user decision (LogicTypespec d/t stay in the fail list, greedy B step 8 below) |
| pass 181: digit separators and unsized based literals outside the literal emitter | r11u181repro/cases/us u01-u08 | u01, u03-u07 IDENTICAL (u03: `logic [1_5:0]` range bound separators and parameter values: no netlist change); **u02, u08 EQUIVALENT** (nohier) | u02 / u08 are pass 181 R6: an unsized based literal as a WHOLE continuous-assign right side (`assign a = 'h1_0;` onto 16 bits): golden sizes it 16, ours -1 (stage 1); the separator text alone (S3) is not downstream-visible |
| r11u185: the generic ANSI interface port after an interface-typed port (typed by golden, generic in our definition view) | r11u185verify/cases/GV v01-v15, PG/p04 | **v07, v08, v09, v15, p04 STATUS_DIFF** (Surelog lane NO_GATES, ours READ_FAIL); v02, v11 EQUIVALENT; v01, v03, v04, v06, v12, v13, v14 IDENTICAL with both lanes READ_FAIL; v05, v10 IDENTICAL | r11u185 new 1: type such a port in the definition view like its predecessor (ModuleEmit, the definition port and LowConn), ground B. Stage 1 on every broken case, so the strict map does not see it |
| r11u185 PU/u06: a whole-value copy `C = B` beside `$bits(B)` and `B.D` | r11u185verify/cases/PU/u06 | **DIVERGENT** (nohier) | golden expands C's listing to tagged patterns, ours keeps a reference (ParamEmit, ground A); PU u01-u05, u07 IDENTICAL |
| r11u185 UD/u04: UDP-form instance arrays `ch a1 [1:0] (w1, w2, o)` | r11u185verify/cases/UD/u04 | **DIVERGENT** (nohier) | ModuleEmit instance-array UDP form (ground B); UD u01-u03, u05, u06 IDENTICAL |
| v11u171 R4: the UDP-form swallow on a non-lvalue first concatenation | v11u171repro/cases/Q c01-c14 | c02, c08, c14 EQUIVALENT; the other 11 IDENTICAL (**c07, c12 IDENTICAL: map 9 read them EQUIVALENT**; pass 176's law udpFormNetLvalueFirst176) | done for c07 / c12 |

## 9. The per-ground briefs (on top of r11u183 measured + both pairs optimistic)

The base is 26 row-modes / 14 tests cleared. **The remaining 58 row-modes carry**: by open-cluster count, 1: 10, 2: 11,
3: 4, 4: 3, 5: 4, 6 or more: 26; by ground, A only 4, B only 26, both 15, with a key new under the patches or an
unpinned cluster 13 (the UVM rows and their neighbours). Every OPEN cluster of ground A (195) clears 4 row-modes alone
(30 with the pairs); every OPEN cluster of ground B (266) clears 26 (52). **Most rows now end on ground B.** A candidate
is the whole open-cluster set of one remaining row (<= 4 clusters one ground, <= 6 joint); the greedy picks by row-modes
cleared per cluster added ([evidence/report.txt](evidence/report.txt) section 8, [evidence/greedy10.json](evidence/greedy10.json)).

**Ground A (the next pair-A refill, after r11u184 and r11u187).**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0129 | 2 | 28 | ibex_icache/d/u2r ibex_icache/t/u2r | A | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < |
| 2 | N0820 | 2 | 30 | anon_struct_packed_dim/d/u2r anon_struct_packed_dim/t/u2r | A | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124 |

**Ground B (the next pair-B refill, after r11u186).**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 28 | InterfaceModPort/d InterfaceModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 2 | N0219 | 2 | 30 | ibex_pmp/d/u2r ibex_pmp/t/u2r | B | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInline |
| 3 | N0023 | 2 | 32 | rsp_gen_minimal/d/u2r rsp_gen_minimal/t/u2r | B | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedC |
| 4 | N0431 + N0627 + N1047 | 4 | 36 | AssertDelayError/d AssertTempError/d AssertDelayError/t AssertTempError/t | B | emitAssertion (ModuleEmit.cpp, law genProcParamFold) < emitModuleDef (ModuleEmit.cpp, law shadowedImportParamF |
| 5 | N0090 + N0448 | 2 | 38 | arb_idx_cast/d/u2r arb_idx_cast/t/u2r | B | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, la |
| 6 | N0133 + N0487 | 2 | 40 | const_cast_signext/d/u2r const_cast_signext/t/u2r | B | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law unnamedConcatIf |
| 7 | N0853 + N1127 | 2 | 42 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | B | emitContAssigns (ModuleEmit.cpp, law caUnbasedFillPackedAggregateKeepsRaw43) < emitInstance (ModuleEmit.cpp, l |
| 8 | N0083 + N0422 + N0484 + N1149 | 2 | 44 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |

**Joint (both grounds), the order that converts the most rows per cluster.**

| step | clusters added | +row-modes | cum row-modes | rows | ground(s) | site of the first |
|---|---|---|---|---|---|---|
| 1 | N0040 | 2 | 28 | InterfaceModPort/d InterfaceModPort/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedPkgVarNets (ModuleEmit.cpp, law oobCtorLo |
| 2 | N0219 | 2 | 30 | ibex_pmp/d/u2r ibex_pmp/t/u2r | B | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPackage (ParamEmit.cpp, law aggRngSkipInline |
| 3 | N0129 | 2 | 32 | ibex_icache/d/u2r ibex_icache/t/u2r | A | emitExpr (ExprEmit.cpp, law elabCaPortParamPaCopy64) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < |
| 4 | N0820 | 2 | 34 | anon_struct_packed_dim/d/u2r anon_struct_packed_dim/t/u2r | A | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124 |
| 5 | N0023 | 2 | 36 | rsp_gen_minimal/d/u2r rsp_gen_minimal/t/u2r | B | emitModuleDef (ModuleEmit.cpp, law caNetDeclStrengthDropped90) < exportDesign (UhdmExporter.cpp, law importedC |
| 6 | N0431 + N0627 + N1047 | 4 | 40 | AssertDelayError/d AssertTempError/d AssertDelayError/t AssertTempError/t | B | emitAssertion (ModuleEmit.cpp, law genProcParamFold) < emitModuleDef (ModuleEmit.cpp, law shadowedImportParamF |
| 7 | N0090 + N0448 | 2 | 42 | arb_idx_cast/d/u2r arb_idx_cast/t/u2r | B | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitParameters (ParamEmit.cpp, la |
| 8 | N0133 + N0487 | 2 | 44 | const_cast_signext/d/u2r const_cast_signext/t/u2r | B | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law unnamedConcatIf |
| 9 | N0011 + N0016 | 2 | 46 | UnitElabBlock/d UnitElabBlock/t | A+B | thisImplicitNetBoth38 (TypeEmit.cpp, law hoistedThisRidesTheForwardedBlock219) < exportDesign (UhdmExporter.cp |
| 10 | N0085 + N0738 | 2 | 48 | func_typename_ret/d/u2r func_typename_ret/t/u2r | A+B | makeParamTs (ParamEmit.cpp, law pkgParamOwnDefRange) < drainDefParamTs (ParamEmit.cpp, law paramCloneImportedC |
| 11 | N0853 + N1127 | 2 | 50 | OutputSizeWithParameterOfInstanceInitializedByStructMember/d/u2r OutputSizeWithParameterOfInstanceInitializedByStructMember/t/u2r | B | emitContAssigns (ModuleEmit.cpp, law caUnbasedFillPackedAggregateKeepsRaw43) < emitInstance (ModuleEmit.cpp, l |
| 12 | N0083 + N0422 + N0484 + N1149 | 2 | 52 | LogicTypespec/d LogicTypespec/t | B | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorr |
| 13 | N0891 + N0980 + N1096 + N1946 | 2 | 54 | FuncStructVal/d FuncStructVal/t | A+B | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < emitPackage (ParamEmit.cpp, law aggRngSkip |
| 14 | N0519 + N1117 + N1126 + N1128 + N1134 | 2 | 56 | InterfaceStructMemberPort/d InterfaceStructMemberPort/t | B | UHDM library DeepClone < DeepClone < DeepCopy (--elabuhdm, testflags) run from main (uhdm_main.cpp) |
| 15 | N0563 + N0763 + N0957 + N0971 + N0979 | 2 | 58 | ibex_tracer/d/u2r ibex_tracer/t/u2r | A+B | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law tpAnonA |

In short:

* **Expression/parameter ground (after r11u184 + r11u187's law_exprstmt).**
  1. **N0129** (`fullname|ref_typespec|tok:->.id|under:constant`, ExprEmit emitExpr near law elabCaPortParamPaCopy64):
     ibex_icache d/t's last cluster; r11u180 S5 decoded it (the part-select bound constant substituted for the package
     parameter `IC_LINE_W` in an explicit `assign` is named `work@ibex_icache` in golden, ours through the selected object).
  2. **N0820** (anon_struct_packed_dim d/t's last, with pair B's N0014): the ref_obj full name through
     `id[id].id[n - id][n:n].id.`, ExprEmit.
  3. **The joint rows' A halves**: N0016 (UnitElabBlock, with N0011 B), N0085 (func_typename_ret, with N0738 B),
     N0891 + N0980 + N1096 (FuncStructVal's pattern-caller faces, with N1946 B), N0763 + N0957 + N0971 + N0979
     (ibex_tracer's case_item / logic_typespec names, with N0563 B).
  4. **The UVM heads after everything**: N0228 (`span|hier_path|endcol|under:bit_select`: `obj.get_type_name` as an
     index, golden 911:72-911:75, ours the whole call 911:72-911:91: pass 178 R2 / pass 181 R3, the call-as-index span;
     the first OPEN record of 7 UVM row-modes) and N0215 / N0229 (`uvm_report::verbosity::severity`: a formal's default
     expression named through the formal in golden), N0224, N0217 (`space.substr` index names: r11u183's N0175 residue),
     N0071, N0175, N0109 / N0110, N0185, N0193. Each carries 9 UVM row-modes and clears none alone.
  5. **Earlgrey_0_1's head**: N1082 (`span|constant|col|under:param_assign`: the `flash_phy_pkg.sv` 43:53 golden, 43:28
     ours, ExprEmit `tryFoldConst` near law srlgSizeCastUbShiftMask93); **BlackBePipeInt's head** N0923 (ParamEmit
     `stampParenCastWidthTs`).
* **Module/type ground (after r11u186).**
  1. **Singles**: N0040 (InterfaceModPort d/t's last cluster: the interface variables' logic_typespec end at the
     declarator where golden ends at the keyword; also Rggen's head; pass 176 residue 7 and pass 180 R11 could not
     isolate the use that stretches it), N0219 (ibex_pmp d/t's last: the import-parameter copy keeps the pre-move
     typedef object in golden, pass 176 residue 2 / r11u185 new 2, the one away-movement the landings still make:
     ModuleEmit `importParamCopy82` / ParamEmit), N0023 (rsp_gen_minimal d/t's last: ModuleEmit `emitModuleDef` near
     law caNetDeclStrengthDropped90).
  2. **Pairs and triples**: N0431 + N0627 + N1047 (AssertDelayError / AssertTempError: property and assertion full names
     `id.id.id->id`, ModuleEmit `emitModuleDef` / `emitAssertion`), N0090 + N0448 (arb_idx_cast; N0448 also Scr1SvTests'
     first open), N0133 + N0487 (const_cast_signext: the kept constant function call, section 8a), N0853 + N1127
     (OutputSize...), N0011 (UnitElabBlock with A's N0016).
  3. **LogicTypespec's four** (N0083 + N0422 + N0484 + N1149) are a user decision (section 8b).
  4. **The UVM ground-B families** (all open after pair B's optimistic first-ten): N0072 / N0103 (class_typespec spans /
     names of class-method return and formal typespecs, now pinned at TaskFuncEmit `emitTaskFuncs`), N0039 (int_typespec
     spans; 156 probe cases, the largest probe cluster with a row), N0051, N0031 / N0042 (a class-scoped queue typedef's
     `$` bound: r11u183 rank 10, grid a/r01-r04 judge-unequal), N0132, N0161, N0170, N0171, N0757.

## 10. Prediction audit of map 9 ([evidence/audit.txt](evidence/audit.txt); `drivers/audit10.py` reads the committed baselines at every landing)

**Since map 9 (98 row-modes at 5e8d08d9), 14 row-modes converted**: pass 178 1, 176 5, 181 4, 180 4 (the verifications
and the decode 0). **All 14 were predicted by map 9** (tally `predicted / converted` 14, `not predicted / converted` 0).

| map 9 predicted | row-modes | converted | by | still open |
|---|---|---|---|---|
| r11u175 (measured) + pairs r11u178 / r11u176 (optimistic) | 15 | **6** | 178 1 (LocalScopeHierPath t), 176 1 (UnsizedParam d), 181 4 (CovMacro d/t, YosysRiscv d/t) | 9: InterfArrayBind d, TypeParameterAsPortTypeWithEnum d/t, ...OfParametrizedWidth d/t, ibex_multdiv_fast d/t, ibex_pmp d/t |
| the named-row upper bound (FuncStructValSimple d/t, OneNetModPort d/t) | 4 | **2** | 176 2 (OneNetModPort d/t) | FuncStructValSimple d/t |
| section-9 ground-A list (1 step) | 2 | 0 | | FuncStructValSimple d/t (N0131) |
| section-9 ground-B list (12 steps) | 23 | **6** | 176 2 (OneNetModPort, step 10), 180 4 (PackedArrayHighConn step 3, mem_read_reg step 7) | 17 |
| section-9 joint list (24 steps) | 53 | **8** | 176 4 (OneNetModPort, OneNetModPortGeneric step 22), 180 4 | 45 |
| **any of them** | **68** | **14** | | 54 |
| not predicted | | **0** | | 30 open, never predicted: the UVM / Earlgrey / Rggen / Scr1 / BlackBePipeInt / SVSwitch rows and ClassTypeParam d/t, cfg_func_width_loop d/t, int_types d/t, struct_param_func_config d/t |

* **14 of 14 conversions were predicted (100%)**, 21% of what map 9 predicted converted. Every conversion's first cluster
  was one map 9 routed.
* **The recount of map 9's section-9 items at 2b97649e** ([evidence/audit.txt](evidence/audit.txt) F):

| item | clusters | rows 5e8d08d9 -> 2b97649e | target row at 2b97649e | converted by | under r11u183 (measured) |
|---|---|---|---|---|---|
| B1 | N0056 | 11 -> 11 | PreprocTest NE | - | open (pass 180 R8: not implementable here) |
| B2 | N0014 | 6 -> 6 | StructParamPatternInitCast NE | - | open (needs A's N0003 too) |
| B3 | N0163 | 5 -> 0 | PackedArrayHighConn CMP_EQUAL | pass 180 | |
| B4 | N0129 | 4 -> 4 | ibex_icache NE | - | open (re-grounded A, r11u180 S5) |
| B5 | N0688 | 2 -> 2 | iface_zero_width_field NE | - | open (re-grounded A, pass 178 R3) |
| B6 | N0072 + N0103 | 13 -> 11, 11 -> 9 | ArrayMethodIterator NE `endcol(1)` | pass 180 cleared this row's N0072 / N0103 (law classTpDefaultTsAtUse180) | **converts** (N0097, law withClauseCloseParenEnd183) |
| B7 | N0804 + N0805 | 2 -> 0 | mem_read_reg CMP_EQUAL | pass 180 | |
| B8 | N1174 | 1 -> 1 | HierPathTypespec t NE | - | open |
| B9 | N0043 + N0133 + N0487 | 14 -> 6, 4, 4 | const_cast_signext NE `type(1)` | pass 180 cleared N0043 on it (law modAggTfArgCloneFollows180), unmasking N0133 | open |
| B10 | N0268 + N0418 + N0419 | 8, 6, 6 -> 0 | OneNetModPort CMP_EQUAL | pass 176 | |
| B11 | N0067 + N0068 + N0162 + N0289 | 13, 13, 9, 7 -> same | ApbSlave NE `depth(1)` | - | **converts** (both patches) |
| B12 | LogicTypespec's four | unchanged | LogicTypespec NE | - (user decision) | open |
| A1 | N0131 | 10 -> 10 | FuncStructValSimple NE | - | open |
| A2 | rsp_gen_minimal / jeras_union / OutputSize / arb_idx_cast / Assert* / ParameterFromPkg* halves | unchanged (N0416 6, N0938 2, N0191 2, N0443 5, N0299 6, N0476 4 ...) | all NE | - | **jeras_union and ParameterFromPkg* convert** (r11u183 family 3a + N0938) |
| A3 | UVM N0682 / N0001 / N0007 / N0061 / N0119 / N0152-3 | N0119 11 -> 0, N0152 / N0153 9 -> 0 (pass 181: laws newLhsBitSelAtIndex181, invalidStmtAnchorSyntax181; probe 71 -> 1); N0682 3, N0001 14, N0007 11, N0061 12 unchanged | UVM NE | - | N0061 12 -> 11 |

* **Why 54 predicted rows did not convert.** Pair A r11u178 landed r11u175's expression laws and two of its own; it did
  not take map 9's pass-171 sister faces (ibex_multdiv_fast's enum constants, TypeParameterAsPortTypeWithEnum's enum
  copy), the map-8 ground-A leftovers (InterfArrayBind, ibex_icache's constant names, StructParamPatternInitCast's N0003)
  or the joint rows' A halves; its successor pass 181 took the $root / select-index / do-while / lvalue-path families
  and converted CovMacro and YosysRiscv (map 9's r11u178 routes) but none of those. Pair B r11u176 (pass 176) took the
  F3 relocation and the program-port family (OneNetModPort*, UnsizedParam) but left ibex_pmp on the import-parameter
  copy (its residue 2, the one away-movement); pass 180 took three ground-B list items (B3, B6's half, B7) and B9's
  N0043. The singles no brief took are the same as map 9 reported for map 8: PreprocTest (not implementable), N1174
  (naming context-dependent), LogicTypespec (user decision), and the joint rows whose halves sit in both grounds.
* **Map 8's predictions recounted.** Map 9 found 50 of map 8's 110 predicted row-modes converted by 5e8d08d9; by
  2b97649e 12 more of them converted (OneNetModPort d/t, UnsizedParam d, PackedArrayHighConn d/t, mem_read_reg d/t from
  its ground-B list; CovMacro d/t, YosysRiscv d/t, LocalScopeHierPath t from its ground-A list): **62 of 110 (56%)**. The
  other two conversions since map 9, OneNetModPortGeneric d/t, were above map 8's list cap.

**Clusters.** Map 9's covered set (145 clusters: r11u175 measured + the r11u178 / r11u176 optimistic routes): 105 gone,
2 lost every row (N0036 11->0, N0136), 7 fell (N0003 8->4, N0075 9->2, N0121 9->7, N0144 9->7, N0278 8->4, N0325 6->4,
N0775 2->1), 30 unchanged (the r11u178 routes pass 178 did not take: N0012, N0034, N0086, N0087, N0097, N0134, N0151,
N0175, N0182, N0219, N0262 ...), 1 grew (N1163 0->4, a UVM exposure). Map 9's section-9 lists (65 clusters): 9 gone,
1 lost every row (N0088), 4 fell (N0043 14->6, N0072 13->11, N0103 11->9, N0526 4->2), 51 unchanged. 36 clusters map 9
routed nowhere lost rows (N0119, N0152, N0153, N0172, N0173, N0187 9-11 -> 0, the keys of pass 181's lvalue bit-select,
body-anchor and call-in-index laws; N0116 11->2; seven UVM keys 7->0).

**Site pins** (map 9's pin of each converted row's first open cluster, against the files of the landing laws, read
from src by the section sign):

| landing | pin's mint file = a law's file | a law's file is a caller in the pin | pin misses |
|---|---|---|---|
| pass 176 (B) | 4 (OneNetModPort d/t, OneNetModPortGeneric d/t: ModuleEmit) | 1 (UnsizedParam d: ExprEmit pin N0457, law in ModuleEmit + UhdmExporter) | 0 |
| pass 178 (A) | 1 (LocalScopeHierPath t: ExprEmit) | 0 | 0 |
| pass 181 (A) | 4 (CovMacro d/t, YosysRiscv d/t: ExprEmit) | 0 | 0 |
| pass 180 (B) | 0 | 2 (PackedArrayHighConn d/t: TypeEmit `buildEnumTs` pin N0163, law in ModuleEmit + UhdmExporter) | 2 (mem_read_reg d/t: TypeEmit `buildStructTs` pin N0805, law ifaceWildcardTdNameOrder180 in ModuleEmit `emitImportArtifacts`) |
| **all 14** | **9** | **3** | **2** |

What it says: **the pin names a fix file in 12 of 14 (86%), 9 at the mint** (map 9 for map 8: 42 of 53, 79%). The
misses and the caller hits are again ORDER and PARENT decisions made upstream of the mint in another file (pass 180's
importer order and last-writer parent live in ModuleEmit's import walk, the objects are minted in TypeEmit). Map 8's
rule stands: read the first caller outside the mint's file, and check for a post-pass that re-parents or reorders.

## 11. The family view

| family | row-modes / tests | clusters per row at 2b97649e | after r11u183 (measured) | open per row after r11u183 + both pairs | distinct clusters: 2b97649e -> r11u183 -> + pairs | cleared |
|---|---|---|---|---|---|---|
| UVM (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg) | 9 / 5 | 112-247 | 103-237 | 92-221 | 296 -> 289 -> 272 | 0 |
| Earlgrey_0_1 | 2 / 1 | 76-78 | 76-78 | 65-66 | 88 -> 88 -> 76 | 0 |
| Rggen (default only) | 1 / 1 | 48 | 45 | 43 | 48 -> 45 -> 43 | 0 |
| BlackBePipeInt | 2 / 1 | 25-27 | 25-27 | 24-26 | 27 -> 27 -> 26 | 0 |
| Scr1SvTests | 2 / 1 | 22 | 22 | 19 | 22 -> 22 -> 19 | 0 |
| SVSwitch | 2 / 1 | 12 | 9 | 8 | 12 -> 9 -> 8 | 0 |
| ApbSlave | 2 / 1 | 4 | 0 | 0 | 4 -> 0 -> 0 | **2 (r11u183, measured)** |
| ibex (icache, multdiv_fast, pmp, tracer) | 8 / 4 | 2-6 | 2-6 | 0-5 | 15 -> 15 -> 7 | 2 (multdiv_fast d/t, pair A) |
| jeras (jeras_union) | 2 / 1 | 2 | 0 | 0 | 2 -> 0 -> 0 | **2 (r11u183, measured)** |

Per ibex test at 2b97649e: ibex_tracer 6 clusters, ibex_icache 5, ibex_pmp 2, ibex_multdiv_fast 2. The heads after
everything: UVM N0228 (A, 7 rows) / N0215 (A, 2); Earlgrey N1082 (A); Rggen N0040 (B); BlackBePipeInt N0923 (A);
Scr1SvTests N0448 (B); SVSwitch N0090 (B, then N0526 N0954 N0958 N1010 N1011 N1019 N1020).

**The near rows.** At 2b97649e, 10 row-modes in 6 tests are single-cluster: ArrayMethodIterator d/t N0097,
InterfArrayBind d N0427, InterfaceModPort d/t N0040, PreprocTest d/t N0056, HierPathTypespec t N1174,
iface_zero_width_field d/t N0688. After r11u183 and both pairs, 10 row-modes in 5 tests have one open cluster:

| row(s) | the open cluster |
|---|---|
| InterfaceModPort d/t | N0040 (B) |
| anon_struct_packed_dim d/t | N0820 (A; pair B's N0014 clears its other) |
| ibex_icache d/t | N0129 (A) |
| ibex_pmp d/t | N0219 (B; pair A's N0943 clears its other) |
| rsp_gen_minimal d/t | N0023 (B; pair A's N0416 + N0022 clear its others) |

11 more have two: AssertDelayError d / AssertTempError d N0431 + N0627, UnitElabBlock t N0016 + N0090,
OutputSize... d/t N0853 + N1127, arb_idx_cast d/t N0090 + N0448, const_cast_signext d/t N0133 + N0487,
func_typename_ret d/t N0085 + N0738.

**The UVM family: r11u175's census by family key** (its `uvmcensus.py` + `uvmfamilies.py` over map 8's cluster keys,
the five UVM rows' default databases; [evidence/uvm/](evidence/uvm/)):

| family | 5e8d08d9 (map 9) | 80a1c2af (r11u183 pristine) | 80a1c2af + r11u183 patches | **2b97649e** | **2b97649e + r11u183 patches** |
|---|---|---|---|---|---|
| F2 object multiplicity | 47,777 | 23,489 | 11,866 | **23,489** | **11,866** |
| F5 reference full names | 19,445 | 12,480 | 9,481 | **12,372** | **9,373** |
| F6 file facets | 8,180 | 8,306 | 7,508 | **3,914** | **3,118** |
| F4 formal / typespec / bound spans | 19,697 | 19,711 | 18,960 | **2,912** | **2,403** |
| F7 expression spans outside the pp model | 5,030 | 4,632 | 4,628 | **1,487** | **1,483** |
| F1 preprocessor location model | 720 | 720 | 720 | **720** | **720** |
| F8 names | 732 | 726 | 790 | **485** | **565** |
| F9 value / order / depth | 363 | 292 | 292 | **292** | **292** |
| F3 typedef relocation spans | 1,045 | 1,095 | 1,095 | **139** | **139** |
| **all** | 102,989 (426 clusters) | 71,451 | 55,340 | **45,810 (295)** | **29,959 (288)** |

Since r11u183's base (80a1c2af), passes 176, 181 and 180 took F4 19,711 -> 2,912, F3 1,095 -> 139, F6 8,306 -> 3,914
and F7 4,632 -> 1,487 (by family key: F4 / F3 are the class-method formal relocation and class type-parameter default
families of passes 176 and 180, F7 the expression spans of pass 181; not attributed per pass by switch here). Under the patches F2 and F5 land on exactly r11u183's deltas (-11,623,
-2,999), F6 falls 796 (r11u183: 798), F4 509, F8 grows 80 (r11u183: 64; the alias references law
memberBareTdAliasNamedByUse183 names through a member reference whose own name is wrong at pristine). After the patches
the largest UVM families are F2 (11,866: the importer clones' struct-keyed and property-array loop variables N0408 /
N0134, the import-parameter copies N0151 / N0262 / N0182), F5 (9,373) and F6 (3,118).

**Order-blind uhdm-dump distance to golden** (records ours-not-golden + golden-not-ours, depth dropped, multiset;
`drivers/uvmdist.sh`, [evidence/sweeps/uvm_orderblind_distance.txt](evidence/sweeps/uvm_orderblind_distance.txt)):

| row-mode | 5e8d08d9 (map 9) | 80a1c2af (r11u183 pristine -> law) | **2b97649e** | **2b97649e + r11u183 patches** |
|---|---|---|---|---|
| MiniAmiq d / t | 53,273 | 36,021 -> 26,247 | **26,585** | **16,799** (-37%) |
| SeqDriver d / t | 42,605 / 42,607 | 29,571 -> 23,251 | **19,521 / 19,523** | **13,189** (-32%) |
| SimpleUVM d / t | 20,344 | 17,226 -> 16,036 | **6,964** | **5,780** (-17%) |
| Scoreboard d | 18,002 | 15,462 -> 14,427 | **5,616** | **4,587** (-18%) |
| BuildUVMPkg d / t | 14,833 | 13,143 -> 12,663 | **3,293** | **2,819** (-14%) |
| ApbSlave d / t | 88 | 88 -> 76 | **12** | **0** (converts) |
| SVSwitch d / t | 127 | 123 -> 119 | **106** | **102** |

Passes 176-181 moved the UVM rows 50-78% toward golden since map 9 without converting one (MiniAmiq -50%, SeqDriver -54%,
SimpleUVM -66%, Scoreboard -69%, BuildUVMPkg -78%); the r11u183 patches take another 14-37%. The UVM rows still carry
103-237 clusters each after the patches and 92-221 after both pairs.

## 12. After the base: pass 184 landed while this map ran (`443933679`, measured from its committed baselines only)

Pair A r11u184 landed as pass 184 at `443933679` (15:37, after this map's sweeps started); this map's numbers stay at
2b97649e (no measurement here ran its binary). Its committed baselines against 2b97649e's:

| stage | pass 184 | this map's pair-A prediction (optimistic, section 5) |
|---|---|---|
| uhdm2rtlil | **6 conversions**: ibex_multdiv_fast d/t, TypeParameterAsPortTypeWithEnum d/t, ...OfParametrizedWidth d/t (N0545 + N0546; N0012 + N0034 + N0638 + N0281) | the same 6, plus iface_zero_width_field d/t (N0688) |
| surelog | 0 conversions; 9 changes (the UVM rows lose their two `seed_map.count[type_id]++` records: N0001 + N0061, law incDecMemberSelIsLvalue184) | FuncStructValSimple d/t (N0086 + N0087 + N0131) and InterfArrayBind d (N0427) |
| probe | 3 conversions, 3 changes | 67 |

So pass 184 delivered 6 of the 11 predicted row-modes, every one through the cluster the map routed to it; the five it
left are the next pair-A refill's first steps: **FuncStructValSimple d/t** (pass 184's README names its first record as
the sister's typedef relocation N0080: that was at pass 184's base 1eeff71d; at 2b97649e pass 180 has cleared it and the
row holds only N0086 + N0087 + N0131, all ground A, section 7), **iface_zero_width_field d/t** (N0688, pass 178 R3) and
**InterfArrayBind d** (N0427 + the ModuleEmit half, pass 181 S4). After pass 184 the fail list is **78 row-modes / 41
tests and 1189 probe cases**; with r11u183's patches (measured at 2b97649e; their 10 conversions are disjoint from pass 184's
6) 68 row-modes.

## 13. Files

* **cluster_index.csv**: one row per cluster (995), with rows / probe at 2b97649e, after r11u183 (`rows_after_law`),
  after both pairs (`rows_after_pairs`), `alone_on_top_of_pairs`, `first_in_after_pairs` (first OPEN record),
  `alone_on_pristine`, coverage, ground, site, map 9's rows and coverage (`map9_*`), families, probe laws, key, example.
* **clusters.csv**: row-mode x cluster with a `first` flag; **probe_clusters.csv** the same per probe case.
* **fail_list.csv**: every STRICT_NOTEQUAL row-mode (84) with its first cluster, that cluster's coverage / ground /
  site, cluster counts, family, downstream verdict, the strict cell after r11u183, the first OPEN cluster after the
  pairs, the open clusters left and `clears`. **probe_fail_list.csv**: the same for the 1192 probe cases.
* **evidence/**:
  * `clusters/`: record dumps, one example per cluster with a row or >= 3 probe cases (613); `objects.csv`: one
    example object for every cluster (995);
  * `report.txt` (drivers/report10.py), `audit.txt` (drivers/audit10.py), `final10.txt`, `pristine_index.csv`,
    `greedy10.json`;
  * `routes.json` (the live pairs' items), `ground_override.json`, `sites.json`, `pinwant.txt`, `pins/`;
  * `law183_scratch_2b97649e.patch`: the measured r11u183 binary's source (2b97649e + both patches), NOT applied;
    `law_exprstmt_on_2b97649e.patch` / `law_typeemit_rebased_on_2b97649e.patch`: the same split per ground (lawA / lawB),
    the second being the rebase pair B r11u186 needs at 2b97649e;
  * `controls/`; `determinism/` (det.log, ob.log, strict_counts.txt); `uvm/pristine_2b97649e`, `uvm/law183` (families,
    ranks, first ten);
  * `sweeps/`: `sweep_law183.txt`, `byteverify_law183_vs_head.txt`, `movers.txt`, `census/` (the prediction),
    `canaries.txt`, `attribution_lawA/`, `attribution_lawB/`, `uvm_orderblind_distance.txt`, `dsfaces_P.csv`,
    `dsfaces_L.csv`.
* **drivers/**: `run10.sh` (the pipeline as run), `env.sh`, `common.py` (key rewrite + the fence), `jobs.py`,
  `probejobs.py`, `probelaw.py`, `strict_runs.sh`, `run1.sh`, `cc.sh`, `strictcmp_x.cpp`, `objrank.cpp`, `analyze.py`,
  `final10.py`, `pinmulti.py`, `sites.py`, `mksites10.py`, `crosssection.sh`, `report10.py`, `audit10.py`, `tables10.py`,
  `evid.py`, `census.sh` + `censum.py` (r11u183's firing census), `bvmirror.sh`, `buildAB.sh` + `attribution.sh` (the
  per-patch binaries), `dsfaces.py`, `uvmcensus9.sh` (+ r11u175's `uvmcensus.py`, `uvmfamilies.py`), `uvmdist.sh`,
  `det.sh` + `ob.sh` (the determinism control).
