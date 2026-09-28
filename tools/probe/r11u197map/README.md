# r11u197map: the strict ground map, eleventh edition (measurement only)

**Base.** Measured at `4a65840e` (branch matrix-1.87), HEAD of the branch for the whole pass: `git log 4a65840e..HEAD`
reads empty in the main tree when the map was written, so no landing followed. The base sits after map 10
(`tools/probe/r11u189map`, measured at `2b97649e`, committed as `8e3153a2`), pass 184 (`44393367`), pass 186
(`c168c209`), the verification r11u190 (`1a91673d`), pass 187 (`a1c89c1a`), pass 188 (`6ab9f4fb`), the decode r11u191
(`706ab521`: `tools/probe/r11u191dec/law_exprstmt.patch` and `law_typeemit.patch`, NOT in src), pass 192 (`b6344400`)
and the verification r11u194 (`4a65840e` itself).

**The reference sweep.** `/tmp/intr11u194` (the r11u194 landing sweep of 4a65840e, read-only here). Its csvs equal the
committed baselines cell for cell: 1596 of 1596 surelog rows and 1742 of 1742 uhdm2rtlil rows (status and strict), and
its `probe.csv` is byte-identical to `results/golden_probe.csv`. All 3273 `slang:` lines of its `cmds.txt` files name
the main tree's `build/slang-uhdm`, whose md5 `14dc35040e6a` equals this worktree's build. It is therefore the
pristine side of every comparison below.

Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited; this directory is the whole patch.
Law names are written `law <name>` (no section sign) so `scripts/law_index.py` does not read this directory as a pass.
A probe case is called a case throughout.

**The fence.** No fenced row is STRICT_NOTEQUAL at 4a65840e (`drivers/jobs.py`: `fenced_skipped=0`), so none is in the
fail list; their rows are counted from the csv verdicts only. Every driver here that reads a database or a source takes
the four names from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` (`drivers/common.py fenced()`,
`drivers/env.sh`; fail closed; never RESUME.md by line number) and refuses them by word boundary: `jobs.py`,
`pinmulti.py`, `dsfaces.py`, `uvmcensus9.sh`, `uvmdist.sh`, `census.sh` (the firing census ran
`--filter '^(?!(<fenced>)$)'`), `bvmirror.sh` (the byte comparison ran on hard-link mirrors that leave the 8 fenced
row-mode databases out, `fenced_skipped=8`), `attribution.sh` (its filter lists the 61 mover tests, checked against the
fence when written). The gate sweep of the law binary dispatched every row, as the gate mandates. **No binary, gdb run
or script touched a fenced test's sources or databases outside that sweep.** A grep of this directory for the four names
reads 0.

## Binaries (frozen `chmod 555` in `/tmp/r11u197_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `14dc35040e6a961ca3b4b06f9ce73289` | worktree `/tmp/wt_r11u197` at 4a65840e, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` (the reference sweep's binary) |
| `slang-uhdm.law191` | `a26ee82b086581f579084283ad86ac81` | MEASUREMENT ONLY: 4a65840e + [evidence/law191_both_on_4a65840e.patch](evidence/law191_both_on_4a65840e.patch) = r11u191's `law_exprstmt.patch` rebased over passes 192 and 194 + `law_typeemit.patch` (applies with offsets over pass 188). The one conflict: pass 194's § incDecSelCallArgRead194v guard (`lhsGuard194`) and law idxCallPathAtDots191's wrapper both open `emitExpr`; resolved by keeping pass 194's guard first and the 191 wrapper after it (496 added and 1 deleted line, the same multiset as r11u191's patch). Scratch worktree `/tmp/wt_r11u197L` |
| `slang-uhdm.lawA` | `5e85033f7f5ec5230a8e655db997af42` | 4a65840e + [evidence/law_exprstmt_on_4a65840e.patch](evidence/law_exprstmt_on_4a65840e.patch) alone (pair A r11u195's first item) |
| `slang-uhdm.lawB` | `9a6c3283b0fc3619c291806f9c53b6dc` | 4a65840e + [evidence/law_typeemit_on_4a65840e.patch](evidence/law_typeemit_on_4a65840e.patch) alone (pair B's next refill r11u196) |
| `slang-uhdm.g1` | `cb1b854657a19136aa313abd295e3527` | 4a65840e with `-DCMAKE_CXX_FLAGS=-g1`; gdb pins only (its database of r10buvm21repro/g21b is byte-identical to the reference sweep's) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | [drivers/strictcmp_x.cpp](drivers/strictcmp_x.cpp) = the tool at 4a65840e (with r11u190's raw full-name print) + maps 7-10's variant (escaped record dumps, `--dump-ids`), built by `drivers/cc.sh`. Map 10's variant predates r11u190's change; the change is output-only, and this variant's verdict equals the tool's on 992 of 992 rows (section 1) |
| `objrank` | `3e213a154aab7f619443de5f11646f0a` | [drivers/objrank.cpp](drivers/objrank.cpp) |

Sweeps: the reference `/tmp/intr11u194` (pristine) and this map's `/tmp/r11u197_sL` (law191, `tests/sweep.sh --jobs 3`,
all four stages; the two workdir names have the same length). All 3273 `slang:` lines of the law sweep's `cmds.txt`
files name `/tmp/r11u197_bin/slang-uhdm.law191`. The sweep exits 1 for one reason only, `law index STALE:
tests/LAWS.md`, which the main tree at 4a65840e reads too (`python3 scripts/law_index.py --check`, rc 1, measured in
the main tree). The attribution runs name `slang-uhdm.lawA` / `.lawB` in 126 of 126 `cmds.txt` each.

## 0. Where we stand (4a65840e; the committed baselines are the fail list)

| corpus | mode | judge-equal | strict-equal | `STRICT_NOTEQUAL` |
|---|---|---|---|---|
| surelog | default | 480 | 460 | 20 |
| surelog | testflags | 474 | 456 | 18 |
| uhdm2rtlil | default | 803 | 792 | 11 |
| uhdm2rtlil | testflags | 803 | 792 | 11 |
| probe cases | | 4087 | 3155 | 932 |

**The fail list is 60 row-modes (38 surelog + 22 uhdm2rtlil) in 32 tests, plus 932 probe cases.** All 60 row-modes and
all 4087 probe cases were dispatched to the strict comparator; none is fenced. The strict runs return rc=2 on all 60
row-modes and, on the cases, rc=0 on 3155 and rc=2 on 932, exactly the baseline split.

First fields, tallied from the `strict` column of results/golden_*.csv (= the reference sweep's):
* surelog 38: fullname 15, file 7, endcol 7, endline 5, col 2, type 2;
* uhdm2rtlil 22: fullname 10, line 4, endcol 2, type 2, name 2, file 2;
* probe 932: fullname 431, line 113, endcol 109, type 73, file 66, name 61, depth 33, col 29, endline 11, value 5,
  decompile 1.

Mode asymmetries (the default row is the map's row; these differ in testflags):
* NE in default only: InterfArrayBind (testflags CMP_EQUAL), Rggen (testflags SURELOG_FAIL), Scoreboard (testflags
  SLANG_REJECT);
* NE in testflags only: HierPathTypespec (default CMP_EQUAL);
* a different cell per mode: ClassTypeParam `endline(17)` / `file(30)`, FuncStructVal `endcol(95)` / `(165)`,
  FuncStructValSimple `file(39)` / `(59)`, UnitElabBlock `endline(13)` / `(12)`;
* every uhdm2rtlil fail test is NE in both modes with the same cell, and **every uhdm2rtlil fail row-mode is downstream
  IDENTICAL** (22 of 22).

**Since map 10.** Map 10 counted 84 row-modes and 1192 probe cases at 2b97649e. Since then **24 row-modes and 260 probe
cases converted and none entered** (committed baselines at each landing, [evidence/audit.txt](evidence/audit.txt) A):

| landing | row-modes | tests | probe cases | strict-cell changes |
|---|---|---|---|---|
| pass 184 (`44393367`) | 6 (ibex_multdiv_fast d/t, TypeParameterAsPortTypeWithEnum d/t, ...OfParametrizedWidth d/t) | 3 | 3 | 9 |
| map 10 (`8e3153a2`) | 0 | 0 | 0 | 0 |
| pass 186 (`c168c209`) | 4 (ParameterFromPkgInNestedModule d/t, ParameterFromPkgOnParameterPortList d/t) | 2 | 128 | 14 |
| r11u190 verification (`1a91673d`) | 0 | 0 | 0 | 0 |
| pass 187 (`a1c89c1a`) | 6 (ApbSlave d/t, ArrayMethodIterator d/t, jeras_union d/t) | 3 | 13 | 7 |
| pass 188 (`6ab9f4fb`) | 4 (AssertDelayError d/t, AssertTempError d/t) | 2 | 98 | 2 |
| r11u191 decode (`706ab521`) | 0 | 0 | 0 | 0 |
| pass 192 (`b6344400`) | 4 (ibex_icache d/t, iface_zero_width_field d/t) | 2 | 18 | 2 |
| r11u194 verification (`4a65840e`) | 0 | 0 | 0 | 0 |

**Clusters.** Map 10 had 995 clusters; this map has **956** (499 carry a corpus row, 652 a probe case). The key is maps
4-10's (`facet|type|shape|under:<walk parent type>` + `@builtin` / `@in-typespec`), so a persisting key keeps its id:
945 keep map 10's id, 8 reappear under an earlier map's id, **3 are new, N2464-N2466**; 50 map-10 clusters are gone.
The 11 not in map 10:

| cluster | rows (after r11u191) | probe | ground | key | example | site |
|---|---|---|---|---|---|---|
| N0272 | 0 -> 0 | 1 -> 1 | A | `fullname\|bit_select\|tok:id.id.->\|under:operation` | r10earl29repro/v8_sites2 #276/276 bit_select 'k' golden=work@v8_sites2.u.a.q.autoexecprogbuf[{1'b1,}].autoexec | emitExpr (ExprEmit.cpp, law ifaceMemberTrailIdxNamesByPath147) < emitExpr (ExprEmit.cpp, law negLitPkgRetFoldNested30) < |
| N0594 | 2 -> 2 | 0 -> 0 | B | `fullname\|ref_typespec\|tok:id::id::id::id::->id@id.\|under:enum_typespec` | surelog/default/SeqDriver #84137/83764 ref_typespec '' golden=adpcm_pkg::uvm_component::set_report_severity_id | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp, law importCopyAggFormalOwnCopy32) < exp |
| N0616 | 2 -> 2 | 0 -> 0 | B | `fullname\|ref_typespec\|tok:id::id::id::->id@id.\|under:enum_typespec` | surelog/default/SeqDriver #88333/87989 ref_typespec '' golden=adpcm_pkg::uvm_report_enabled::severity::uvm_pkg | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp, law importCopyAggFormalOwnCopy32) < exp |
| N0991 | 2 -> 2 | 0 -> 0 | B | `fullname\|ref_typespec\|tok:id::id::id::id::id::->\|under:bit_typespec` | surelog/default/MiniAmiq #105388/104954 ref_typespec '' golden=svaunit_pkg::uvm_reg::do_write::pre_write_callb | operator() (TypeEmit.cpp, law pkgTdRangeViewFold18) < operator() (TypeEmit.cpp, law pkgTdRangeViewFold18) < importCloneB |
| N1211 | 1 -> 0 | 0 -> 0 | B | `struct\|golden-only:elsewhere\|function\|under:design` | surelog/default/Scoreboard #268525/-1 function 'get_name' golden=9 objs ours= | exportDesign (UhdmExporter.cpp, law compoundLitWriteBackSat2) < realMain (uhdm_main.cpp, law genCaPatKeepTagDefView121)  |
| N1212 | 1 -> 0 | 0 -> 0 | B | `struct\|ours-only:elsewhere\|function\|under:design` | surelog/default/Scoreboard #-1/205246 function 'get_name' golden= ours=9 objs | emitTaskFuncs (TaskFuncEmit.cpp, law dpiExportListedAtExportItem216) < emitClassDefn (UhdmExporter.cpp, law externProtoI |
| N1438 | 1 -> 0 | 0 -> 0 | B | `struct\|golden-only:elsewhere\|task\|under:design` | surelog/default/Scoreboard #268561/-1 task 'wait_for_error' golden=4 objs ours= | exportDesign (UhdmExporter.cpp, law compoundLitWriteBackSat2) < realMain (uhdm_main.cpp, law genCaPatKeepTagDefView121)  |
| N1439 | 1 -> 0 | 0 -> 0 | B | `struct\|ours-only:elsewhere\|task\|under:design` | surelog/default/Scoreboard #-1/205282 task 'wait_for_error' golden= ours=4 objs | emitTaskFuncs (TaskFuncEmit.cpp, law dpiExportListedAtExportItem216) < emitClassDefn (UhdmExporter.cpp, law externProtoI |
| N2464 | 2 -> 2 | 0 -> 0 | B | `fullname\|ref_typespec\|tok:id::id::id::id::->id.id::id.id.\|under:bit_typespec` | surelog/default/SimpleUVM #63886/63872 ref_typespec '' golden=work@env::uvm_pkg::uvm_reg_bus_op::addr::uvm_reg | bareScalarTypedefVarTs (TypeEmit.cpp, law memberBareTdAliasNamedByUse183) < exportDesign (UhdmExporter.cpp, law pkgParam |
| N2465 | 2 -> 2 | 0 -> 0 | A | `struct\|golden-only:elsewhere\|ref_typespec\|under:class_typespec` | surelog/default/BuildUVMPkg #11992/-1 ref_typespec '' golden=2 objs ours= | emitPackage (ParamEmit.cpp, law atomTdListing44) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) < real |
| N2466 | 0 -> 0 | 1 -> 1 | B | `struct\|ours-only:fewer-copies\|ref_typespec\|under:enum_typespec` | r10v160repro/x10_enum #-1/128 ref_typespec '' golden= ours=1 objs | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law classVarInitSpan152) < makeTypespec |

* N1211 / N1212 / N1438 / N1439 (Scoreboard default only, 796 objects: svunit's `get_name` / `wait_for_error` listed
  elsewhere under `design`) are **Scoreboard's svunit listing-order coin** (RESUME section 9: a per-invocation flip of
  svunit_pkg's `vpiTaskFunc` order): the reference sweep drew the other order from the one the law sweep drew; they are
  not a law's effect (they read "gone under the patches" in section 4 only because of the draw).
* N0594 / N0616 / N0991 / N2464 / N2465 are UVM clone-chain names and copies uncovered where the walk now diverges
  later; N0272 and N2466 are single probe cases.

## 1. Method (map 10's pipeline re-based, [drivers/run11.sh](drivers/run11.sh))

1. **Input.** The reference sweep `/tmp/intr11u194` (= the committed baselines). The jobs are every `STRICT_NOTEQUAL`
   row-mode of results/golden_*.csv (60; `drivers/jobs.py`: 0 missing, 0 fenced, one binary). Each golden is the cache
   entry its `cmds.txt` names. Every probe case is a job too (4087); its golden is `scripts/check_probe.py`'s
   `cache_dir(rel)` (Surelog's identity + the case path + a hash of the case's files; 0 missing), its database
   `/tmp/intr11u194/probe/<rel with / -> __>.uhdm`.
2. **Strict runs.** `strictcmp_x --max 50 --dump-a --dump-b golden ours` on every job (`drivers/strict_runs.sh`).
3. **Analysis.** `drivers/analyze.py` (map 3's alignment, the committed mode-4 rule) records EVERY differing object; its
   reimplementation of the tool's rule agrees with the tool's stdout on **992 of 992** rows at 4a65840e (0
   VERIFY-MISMATCH, 0 CELL-MISMATCH against the csv cells; [evidence/final11.txt](evidence/final11.txt)) and on 988 of
   988 rows of the r11u191 cross-section.
4. **Clusters.** `drivers/final11.py`: map 10's key; ids persist from map 10 (else the latest earlier map); new ids from
   N2464.
5. **Sites.** `drivers/pinmulti.py` ran one gdb session per example row (the `-g1` exporter stops at the example
   object's `Serializer::Make<type>` rank), with the MAIN tree's case directories as the probe cwd (read-only; the
   database goes to scratch), because a probe database embeds the absolute path of its `dut.sv` (map 10's trap). It
   pinned the 29 clusters of [evidence/pinwant.txt](evidence/pinwant.txt): every cluster not in map 10 (11), the one
   cluster with >= 3 row-modes and no pin (N0478), and every cluster with >= 3 row-modes, first on a fail row or >= 40
   probe cases whose example object changed since map 10 **ignoring the record indices** (17; map 10's rule compared the
   example text with its `#golden/ours` indices, which shift on every UVM row whenever any earlier record moves: 201
   clusters read "changed" that way, 176 of them only by index), except those whose only rows are the four coin-prone
   UVM rows with no case (8; their gdb runs cannot reproduce the coin databases; they keep map 10's pin).
   * **20 of 28 `db=SAME`**, 8 `db=DIFF` (all eight on MiniAmiq / SeqDriver / SimpleUVM / Scoreboard: the coin rows;
     every one a cluster with no map-10 pin, marked `rank NOT verified`); 1 has no partner record (N0478: a
     golden-only object; unpinned).
   * Of the 17 re-pinned clusters with a map-10 pin, 12 name the same mint as map 10's, 5 another (N0039:
     ExprEmit `emitExpr` near law castTargetKeywordTypespecKind96, the example moved from a class type parameter pass 188
     cleared to BuildUVMPkg's `uvm_action` int_typespec; N0067 / N0068: TypeEmit `makeTypespec` < ModuleEmit
     `drainFuncRet`, the example moved from ApbSlave, converted, to a UVM function return; N0164: TypeEmit
     `pkgTdRangeViewFold18`'s operator; N0289: TaskFuncEmit `emitTaskFuncs`); map 10's pin rides beside the new one.
     Every other cluster keeps map 10's pin, marked `[r11u189map pin]`.
6. **Ground.** A = ExprEmit/EmitHelpers/StmtEmit/ParamEmit, B = TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/
   uhdm_main, by the pinned mint's file, overridden where a pass decoded the fix site elsewhere
   ([evidence/ground_override.json](evidence/ground_override.json): map 10's list, plus r11u191's decodes: N0215 / N0229
   -> B (law formalDefaultNamedThroughFormal191, TaskFuncEmit's call site hands the scope), N0133 / N0487 -> B (law
   evalFuncCastMemberKeepsCall191, ModuleEmit), N0228 / N0224 / N1082 -> A; and four unpinned clusters by their key:
   N0478 -> B (a class specialization's type_parameter), N0915 / N0928 / N0951 -> A (a bit_select name and an
   indexed_part_select span in a hier_path, a parameter bound by a ref_obj)).
7. **Coverage** ([evidence/routes.json](evidence/routes.json), `drivers/report11.py`):
   * **r11u191's two law patches, MEASURED**: the law191 binary's full gate sweep re-dumped and re-keyed; a cluster
     gone under it reads `COVERED r11u191 (law patches, MEASURED ...)`;
   * **pair A r11u195, OPTIMISTIC**: its brief items mapped to clusters and rows; a covered cluster counts fixed whole;
     a named ROW covers a cluster only when every row of the cluster is a named row of that ground;
   * **pair B r11u193, OPTIMISTIC**: the same, plus the ground-B clusters of the UVM (MiniAmiq, SeqDriver, SimpleUVM,
     Scoreboard, BuildUVMPkg) and Earlgrey_0_1 rows' **first ten differing records** at the r11u191 cross-section
     whose rows are all UVM/Earlgrey rows (the brief's "UVM/Earlgrey first records": N0072, N0144, N0327);
   * **OPEN** otherwise, with map 10's routing where it had one (`map 10 gave it to r11u184/r11u186; passes 184-192
     left it`, `map 10 listed it: ground-X step n`).
8. **Yields.** The law191 binary's full sweep is re-dumped and re-keyed (`drivers/crosssection.sh`), so r11u191 is
   MEASURED; the pairs are applied optimistically to that cross-section. The `alone` column is the rows a cluster
   clears alone on top of r11u191 and both pairs.

What the live pairs were mapped to ([evidence/routes.json](evidence/routes.json)):

| pair | brief item | clusters | named rows |
|---|---|---|---|
| A r11u195 | r11u191 `law_exprstmt.patch` (first) | MEASURED (with law_typeemit) | |
| A | pass 192's residues: R1 anon_struct_packed_dim (N0820), R2 the nested path in an index (N0224), R3 StructParamPatternInitCast (N0003), R6 FuncStructValSimple / FuncStructVal leftovers (N0086 N0087 N0131, N0407 N0891 N0980 N1096), R7 InterfArrayBind (N0427; needs the ModuleEmit half too) | 11 | FuncStructValSimple |
| A | r11u191's ground-A residues: R1 the F5 names through a method-call path and an index's select (N0175 N0217 N0220 N0192 N0196 N0199 N0183), R5 Earlgrey's remaining N1082 record | 8 | |
| A | the sister faces of pass 188 (ibex_pmp's var_select typespec N0943, arb_idx_cast's generate-scope names N0443 N0684, OutputSize's `Info.x` spans and `'1` constant N0191 N0001, InterfArrayBind's index names N0427); of pass 193: not landed, unknown | 5 | |
| A | map 10's ground-A remainder: N0016 (UnitElabBlock), N0085 (func_typename_ret), N0763 N0957 N0971 N0979 (ibex_tracer), N0416 N0022 (rsp_gen_minimal), the UVM heads N0228 N0071 N0109 N0110 N0185 N0193 | 13 | |
| A | the UVM ground-A families (map 10's list): N0682 N0007 N0061 N0119 N0152 N0153 N0172 N0173 N0178 N0179 N0160 N2411 | 12 | |
| B r11u193 | map 10's ground-B list remainder: N0040 (InterfaceModPort, Rggen), N0219 (ibex_pmp), N0023 (rsp_gen_minimal), N0090 + N0448 (arb_idx_cast), N0853 + N1127 (OutputSize), N0011 (UnitElabBlock); the joint list's B halves N0738, N1946, N0519 N1117 N1126 N1128 N1134, N0563; the remainder N0014, N1174; the UVM ground-B families N0072 N0103 N0039 N0051 N0031 N0042 N0132 N0161 N0170 N0171 N0757 | 31 | |
| B | pass 188's residues: R2 N0219, R3 (MEASURED in law_typeemit), R4 N0039, R5 N0448, R6 N0023, R7 ClassTypeParam and UnitElabBlock (read, not attempted), R8 MiniAmiq's `uvm_severity` enum file N0144 and the `uvm_bitstream_t` writer order N0327 | 2 + named | ClassTypeParam, UnitElabBlock |
| B | the sister faces of passes 184 and 187 (184 S1-S4, 187 R2 / R3): N0448 above; the rest are evidence cases | | |
| B | the UVM/Earlgrey first records at the r11u191 cross-section | N0072 N0144 N0327 | |
| not routed | PreprocTest N0056 (pass 186 R5: not implementable on this ground), LogicTypespec (a user decision), BlackBePipeInt N0923 (r11u191 R2: an identity family, no law), pass 192 R4 / R5, r11u191 R3 / R4 / R6-R9, r11u194 N1-N4 (evidence cases) | | |

## 2. Positive controls ([evidence/controls/](evidence/controls/))

| control | result |
|---|---|
| surelog/default/1364_2005 (CMP_EQUAL) | `STRICT_EQUAL 159 objects`, rc 0, record dumps identical (159 / 159) |
| surelog/default/HierPathInterfBlock (CMP_EQUAL) | `STRICT_EQUAL 226 objects`, rc 0, dumps identical (226 / 226) |
| uhdm2rtlil/default/1DUnpackedArray (CMP_EQUAL) | `STRICT_EQUAL 194 objects`, rc 0, dumps identical (194 / 194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, lhsPath `design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant`; baseline `CMP_NOTEQUAL,decompile:` both modes |
| analyzer rule vs tool stdout | 992 / 992 at 4a65840e; 988 / 988 on the r11u191 cross-section |
| probe cells vs golden_probe.csv | 4087 / 4087 (probe.csv byte-identical); 932 / 932 rc=2 from the strict runs, every first field equal to the csv's |
| pin validity | 20 / 28 `db=SAME`, 8 coin rows (new clusters, `rank NOT verified`), 1 no partner (N0478) |
| byteverify self-check | 2559 / 2560 flagged with one side corrupted |

### The determinism control ([evidence/determinism/](evidence/determinism/), [drivers/det.sh](drivers/det.sh), [ob.sh](drivers/ob.sh))

Each binary run three times CONCURRENTLY per row-mode (the reference sweep's command line and cwd, output to scratch);
for the HEAD binary the reference sweep's own database is a fourth sample. Distinct md5s, and the order-blind
`uhdm-dump` difference (paths normalised, sorted, `comm -3` line count) of every pair; every variant reads uhdm-cmp 0
lines and the committed strict first field.

| row-mode | HEAD `14dc3504`: distinct hashes (of 4) | order-blind lines per pair | law191 `a26ee82b`: distinct hashes (of 3) | order-blind lines |
|---|---|---|---|---|
| Earlgrey_0_1 default | **1** (3 runs = the sweep's `ac973fbf3db9`) | - | 1 | - |
| Earlgrey_0_1 testflags | **1** (`c3a93ddf134c`) | - | 1 | - |
| MiniAmiq default | **4** | 4 on each of 6 pairs | **1** (`e10939513fbb`) | - |
| MiniAmiq testflags | **4** | 4 on each of 6 pairs | **1** (the same `e10939513fbb` as default) | - |
| SeqDriver default | **3** | 4 on each of 3 pairs | 2 | **0** (order only) |
| SeqDriver testflags | **3** | 4 on each of 3 pairs | **1** | - |
| SimpleUVM default | **2** | 4 | **1** | - |
| SimpleUVM testflags | 1 | - | 1 | - |
| Scoreboard default | 2 | **0** (the svunit listing order) | 2 | **0** |
| BuildUVMPkg default | **2** (runs 2-3 vs run 1 = the sweep's) | **0** (order only; map 10 read 1 hash) | **1** (= testflags' hash) | - |
| BuildUVMPkg testflags | 1 (= default's run-2 hash `e4f8e660c7d5`) | - | 1 | - |

Scoreboard testflags is SLANG_REJECT (not run). ([evidence/determinism/](evidence/determinism/): `det_head.log`,
`ob_head.log`, `det_law.log`, `ob_law.log`, `coin_lines.txt`.)

* **Earlgrey_0_1 is one-valued in both modes at HEAD** (4 samples each), as r11u194 measured after law
  lawSCopyIdOrder186: the order coin map 10 recorded is closed.
* **The UVM one-constant coin stands at HEAD**: every MiniAmiq / SeqDriver / SimpleUVM default pair differs by the same
  4 order-blind lines, the right bound of `types_t`'s `range` (uvm_misc.svh 642:23-642:26): `vpiDecompile:0` /
  `UINT:0` against `1452` in one MiniAmiq pair (r11u194 read 519: the value is the uninitialized read, any number).
* **r11u191's law_typeemit.patch closes it** (law queueRetTwinDynShape191): under law191 MiniAmiq, SeqDriver testflags,
  SimpleUVM and BuildUVMPkg are one-valued, and the two rows with two hashes (SeqDriver default, Scoreboard default)
  differ by 0 order-blind lines. After the patch **no UVM or Earlgrey row carries a value coin; two order-only coins
  remain** (Scoreboard's svunit listing order, and a SeqDriver / BuildUVMPkg order draw that the HEAD binary shows on
  BuildUVMPkg default too). Neither reaches a strict cell. A map or verifier that compares these rows byte for byte
  across two runs of one binary must still attribute order-blind.

## 3. The gates of the law191 sweep (this map lands no binary)

| gate | pristine `14dc35040e6a` (`/tmp/intr11u194`) | law191 `a26ee82b0865` (`/tmp/r11u197_sL`) |
|---|---|---|
| (1) build | = the main tree's build | 4a65840e + the two r11u191 patches (rebased as above) |
| (2) probe vs golden_probe.csv | EQUAL 3155 / STRICT_NOTEQUAL 932; probe.csv byte-identical to the baseline | EQUAL **3157** / 930; `regressions=0 conversions=2 changes=2` |
| (3) surelog + uhdm2rtlil vs golden_*.csv | = the baselines, 480/3 + 474/3, 803/1/67 | surelog `regressions=0 conversions=0 changes=13`; uhdm2rtlil `regressions=0 conversions=2 changes=0`; judge-equal histograms unchanged (surelog 460+20 / 456+18, uhdm2rtlil 793+10 per mode) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; not identical and not excused 0 |
| (5) uhdm-cmp | no row touched | every corpus row keeps its judge status; every probe case stays uhdm-cmp EQUAL |
| (6) byteverify (SELFCHECK=1, fence-free mirrors) | | **123 / 2560 movers, every one PREDICTED by name** by the firing census run before the law sweep (`R11U191_TRACE`, 131 predicted corpus row-modes, [evidence/sweeps/census/predicted_movers.txt](evidence/sweeps/census/predicted_movers.txt), frozen `chmod 444` before the sweep started); 0 moved-not-predicted; 8 predicted-not-moved (EnumInPackage, func_struct_repro, nested_cast_repro, union_param_repro, uhdm2rtlil both modes: law evalFuncCastMemberKeepsCall191 fires and decides as the pristine fold did) |
| canaries ([evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)) | surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 `EXPECT_UNKNOWN=1` PASS, `EXPECT_UNKNOWN=6` PASS | surelog ok=41 changed=11 (exactly the 11 canary rows among the changes below); uhdm2rtlil ok=16 changed=0; ctcan2 PASS both |

The 123 movers ([evidence/sweeps/movers.txt](evidence/sweeps/movers.txt)) are r11u191's own 123 (its section 0): law
enumDefOwnerNotInstance191 alone moves vpiParent bytes on most of them, with no strict cell and no RTLIL byte.

## 4. r11u191's two law patches, MEASURED at 4a65840e (the cross-section)

| stage | both patches (law191) | law_exprstmt alone (lawA) | law_typeemit alone (lawB) |
|---|---|---|---|
| probe | **2 conversions** (EQUAL 3155 -> 3157), 2 changes, 0 regressions | 1 (r10fiot_repro/a9) / 0 / 0 | 1 (v11u114repro/grid/set3/g13) / 2 / 0 |
| surelog | 0 conversions, **13 changes** | 11 changes (Earlgrey d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d, Scr1SvTests d/t) | 2 changes (BuildUVMPkg d/t) |
| uhdm2rtlil | **2 conversions** (const_cast_signext d/t), 0 changes | 0 | 2 conversions (const_cast_signext d/t) |
| downstream | 803 / 66 / 2 / 0 | (not run) | (not run) |

(lawA / lawB: `drivers/attribution.sh`, the probe stage in full and the corpus stages filtered to the 61 tests the law
sweep moves; [evidence/sweeps/attribution_lawA/](evidence/sweeps/attribution_lawA/),
[attribution_lawB/](evidence/sweeps/attribution_lawB/).) **The per-patch split is exactly r11u191's own at a1c89c1a**
(its section 5): the patches touch disjoint files, and passes 188, 192 and 194 in between change none of their cells.

The fresh corpus rows of the law sweep (NOT written to results/):

    const_cast_signext,default,CMP_EQUAL,,,equal       was differ:type(1)    law evalFuncCastMemberKeepsCall191
    const_cast_signext,testflags,CMP_EQUAL,,,equal     was differ:type(1)

The 13 surelog changes (each row stays judge-equal):

    BuildUVMPkg d/t    differ:fullname(20) -> differ:line(11)     (lawB: law formalDefaultNamedThroughFormal191)
    Earlgrey_0_1 d/t   differ:col(91)      -> differ:fullname(90) (lawA: law pkgFoldAtLeadingLeaf191)
    MiniAmiq d/t       differ:file(27)     -> differ:file(25)     (lawA: law idxCallPathAtDots191)
    SeqDriver d/t      differ:file(26)     -> differ:file(24)
    SimpleUVM d/t      differ:fullname(54) -> differ:fullname(52)
    Scoreboard d       differ:fullname(54) -> differ:fullname(52)
    Scr1SvTests d/t    differ:type(1)      -> differ:endcol(29)   (lawA: law evalFuncExecCallArgTs191; the structural head gone)

**Clusters.** Gone under the patches: N0224, N0228 (the UVM method-call index paths, law idxCallPathAtDots191), N0229
(law formalDefaultNamedThroughFormal191), N0128 + N0249 (the queue typedef's `$` bound value and span, law
queueRetTwinDynShape191: the UVM value coin's object), N0965 (Scr1SvTests' formal typespec), N0780 / N1985 / N2359
(single probe cases), and the Scoreboard coin's N1211 / N1212 / N1438 / N1439 (a draw, section 0). Fell: N0215 9 -> 4
rows, N0133 / N0487 4 -> 2 (cfg_func_width_loop keeps them), N0318 7 -> 6, and N0031 / N0042 9 -> 0 rows (the queue
bound's file and span; 7 cases stay). Grew: N0164 4 -> 5, N0203 4 -> 5 (exposures on BuildUVMPkg behind the moved first
record). No key is new under the patches.

## 5. The yield, and the fail list after r11u191 and both pairs

| | row-modes cleared | tests cleared (every NE mode) | probe cases cleared |
|---|---|---|---|
| r11u191's two law patches, MEASURED | **2** (const_cast_signext d/t) | 1 | **2** |
| pair A r11u195, optimistic, on top of r11u191 | **4**: FuncStructValSimple d/t, FuncStructVal d, InterfArrayBind d | 2 | 40 |
| pair B r11u193, optimistic, on top of r11u191 | **7**: ClassTypeParam d/t, InterfaceModPort d/t, InterfaceStructMemberPort d/t, HierPathTypespec t | 4 | 88 |
| **everything** (r11u191 + both pairs) | **32** (the 13 above + 19 that need both pairs: StructParamPatternInitCast d/t, UnitElabBlock d/t, FuncStructVal t, anon_struct_packed_dim d/t, arb_idx_cast d/t, func_typename_ret d/t, ibex_pmp d/t, ibex_tracer d/t, OutputSize... d/t, rsp_gen_minimal d/t) | **17** | **145** |

| corpus | mode | 4a65840e | after r11u191 (measured) | + pair A | + pair B | + both pairs |
|---|---|---|---|---|---|---|
| surelog | default | 20 | 20 | 17 | 17 | 12 |
| surelog | testflags | 18 | 18 | 17 | 14 | 10 |
| uhdm2rtlil | default | 11 | 10 | 10 | 10 | 3 |
| uhdm2rtlil | testflags | 11 | 10 | 10 | 10 | 3 |
| **all** | | **60 / 32 tests** | **58 / 31** | | | **28 / 15 tests** |
| probe cases | | 932 | 930 | 890 | 842 | **787** |

First fields after r11u191 (the law sweep's csvs): surelog 38: fullname 15, endcol 9, file 7, endline 5, line 2;
uhdm2rtlil 20: fullname 10, line 4, endcol 2, name 2, file 2; probe 930: fullname 431, line 113, endcol 109, type 71,
file 66, name 61, depth 33, col 29, endline 11, value 5, decompile 1.

**The pair yields are optimistic in five named ways** (every one a route the brief names, but a pass already found the
row out of the ground's reach or never decoded it): InterfaceModPort d/t converts only once the harness passes
`--sverilog` (pass 188 R1: law svModeAllFiles188 is landed, the gate never passes the flag; an operator decision),
InterfArrayBind d needs the ModuleEmit half as well as pair A's ExprEmit one (pass 181 S4, pass 192 R7), ClassTypeParam
d/t is counted through named rows (pass 188 R7: read, not attempted; 8-10 clusters none decoded), FuncStructVal d/t's
first record is judge-unequal in every small shape (pass 187 R5: no grid can gate a law), HierPathTypespec t is the
naming-context-dependent face every map carries (N1174). **Without those 8 row-modes, everything clears 24 row-modes
and 36 remain.**

## 6. Ranked OPEN clusters with sites (on top of r11u191 measured + both pairs optimistic)

Columns: `rows left` = row-modes the cluster still carries after r11u191 and the pairs (rows at 4a65840e in
parentheses); `first-open heads` = rows it is the first OPEN record of; `alone` = rows it clears alone on top of
everything; `probe` = its cases after r11u191. The whole list is cluster_index.csv.

**407 OPEN clusters still carry a row** (ground A 175, B 232). The list by rows is dominated by the UVM family (9
row-modes, 5 tests), so it is given three ways: T1 by all rows, T1b over the rows outside the big families (UVM,
Earlgrey_0_1, Rggen, BlackBePipeInt, Scr1SvTests, ApbSlave, SVSwitch), and T1c per ground.

**The new UVM head: N0056** (`span|bit_typespec|endcol|under:ref_typespec`, ground B). After r11u191 and both pairs
it is the first OPEN record of 7 UVM row-modes (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d; BuildUVMPkg's
is N0189) and of PreprocTest d/t, and int_types d/t carries it too. The UVM face is NOT PreprocTest's (pass 186 R5: `bit`
lexed as an identifier in a `.vh` file): it is the signing keyword. `function bit unsigned uvm_packer::get_bit(...)`
(uvm-1.2 uvm_packer.svh 603): golden's return bit_typespec spans `bit` alone (603:10-603:13), ours `bit unsigned`
(603:10-603:22); int_types' macro-built `typ x = -1;` with `typ` = a signed / unsigned integer atom reads the same (golden
3:9-3:12, ours 3:9-3:21). This is law suSigningNotInSpan130's rule (TypeEmit `makeTypespec`: the signing keyword is not in
the span) missed on a function's return variable and on a macro-argument type. Map 10 routed N0056 to pair B r11u186
for PreprocTest only; the key hides a second, implementable face.

### T1. Ranked OPEN clusters, all rows (top 30 of 407)

| # | cluster | rows left (4a65840e) | sl/u2r | tests | families | first-open heads | alone | probe (after r11u191) | ground | status | key | site (mint < caller < caller) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N0056 | 11 (11) | 9/2 | 6 | UVM | 9 | 2 | 1 | B | OPEN (map 10 gave it to r11u186) | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter. |
| 2 | N0097 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 9 | A | OPEN (map 10 gave it to r11u184) | `span\|hier_path\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitSt |
| 3 | N0012 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | A | OPEN (map 10 gave it to r11u184) | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classVarInitSpan152) < |
| 4 | N0034 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | A | OPEN (map 10 gave it to r11u184) | `span\|enum_typespec\|ours-zero\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classVarInitSpan152) < |
| 5 | N0067 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 10 gave it to r11u186) | `file\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law unsupportedTsInitEnd152) < makeTypespec (TypeEmit.cpp, law tpFormalIncludeOrde |
| 6 | N0068 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN (map 10 gave it to r11u186) | `span\|class_typespec\|ours-zero\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law unsupportedTsInitEnd152) < makeTypespec (TypeEmit.cpp, law tpFormalIncludeOrde |
| 7 | N0180 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 3 | B | OPEN | `fullname\|ref_typespec\|ours-empty\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecListin |
| 8 | N0158 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `depth\|bit_typespec\|ref_typespec->ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDe |
| 9 | N0177 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `struct\|ours-only:absent\|bit_typespec\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law mergedPortDe |
| 10 | N0184 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `span\|bit_var\|col+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law assocLocalArrayVar40) < emitPackage (ParamEmit.cpp, law LAW) < exportDesi |
| 11 | N0188 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 2 | B | OPEN | `name\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGenericSpecLis |
| 12 | N0207 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 1 | A | OPEN | `fullname\|ref_obj\|tok:::->.\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law genCaSysCallArgBinds22) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) |
| 13 | N0423 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 1 | B | OPEN | `struct\|golden-only:fewer-copies\|enum_typespec\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law blockLocalTdDeclIsRefVarUnsupported155) < emitClassDefn (UhdmExporter.cpp |
| 14 | N0054 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `span\|assignment\|endcol\|under:begin` | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCollapsesStm |
| 15 | N0117 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN | `span\|unsupported_typespec\|endcol\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law classScopedTdFormalUnsupported34) < emitClassDefn (UhdmExporter.cpp, law  |
| 16 | N0120 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN | `span\|enum_var\|line+col+endline+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitClassDefn (UhdmExporter.cpp, law exter |
| 17 | N0197 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `struct\|golden-only:fewer-copies\|string_typespec\|under:ref_typespec` | operator() (StmtEmit.cpp, law foreachAssocIdxAliasTs22) < emitStmt (StmtEmit.cpp, law foreachLoopVarObjs9) < e |
| 18 | N0213 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN | `struct\|golden-only:absent\|enum_typespec\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExporter.cpp,  |
| 19 | N0222 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|bit_select\|tok:id - n->id-n\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStm |
| 20 | N0225 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|bit_select\|tok:id + n->id+n\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitStm |
| 21 | N0227 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id[id - n].id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124 |
| 22 | N0230 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN | `span\|class_typespec\|line+endline\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < sharedTypespec (TypeEmit.cpp, law typeParamDefaultBoundN |
| 23 | N0232 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | B | OPEN | `struct\|ours-only:elsewhere\|ref_typespec\|under:array_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law modTdRetCloneSymbolic20) < emitClassDefn (UhdmExporter.cpp, law externPro |
| 24 | N0234 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id[id].id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) <  |
| 25 | N0235 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id.id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124 |
| 26 | N0237 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `span\|bit_select\|endcol\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124) <  |
| 27 | N0238 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|bit_select\|tok:id[id].id::->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitEx |
| 28 | N0247 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id[id * n+:n]::id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLvalue124 |
| 29 | N0252 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id.id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law cloneBuiltinMethodArgBind |
| 30 | N0253 | 9 (9) | 9/0 | 5 | UVM | 0 | 0 | 0 | A | OPEN | `fullname\|ref_typespec\|tok:::id[id].id->\|under:operation` | emitExpr (ExprEmit.cpp, law packageVarAutomaticIsDataDeclShape26) < emitExpr (ExprEmit.cpp, law emptyArgSlotIn |

### T1b. Ranked OPEN clusters on the rows outside the big families (top 25)

| # | cluster | rows outside the big families (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0056 | 4 (6) | 2 | 2 | 1 | B | OPEN (map 10 gave it to r11u186) | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (Uhd |
| 2 | N0263 | 2 (3) | 2 | 0 | 59 | B | OPEN | `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespec (TypeEmit.cpp, law typeParam |
| 3 | N0422 | 2 (1) | 2 | 0 | 0 | B | OPEN (map 10 ground-B step 8) | `span\|logic_typespec\|endline+endcol\|under:package` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage (ParamEmit.cpp, law aggRngSkipI |
| 4 | N0817 | 2 (1) | 2 | 0 | 0 | B | OPEN | `fullname\|ref_typespec\|tok:->id.id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, l |
| 5 | N0912 | 2 (1) | 2 | 0 | 0 | B | OPEN | `fullname\|ref_obj\|ours-empty\|under:assignment` | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < operator() (ModuleEmit.cpp, law genSynta |
| 6 | N0083 | 2 (1) | 0 | 0 | 22 | B | OPEN (map 10 ground-B step 8) | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typePara |
| 7 | N0484 | 2 (2) | 0 | 0 | 13 | B | OPEN (map 10 ground-B step 8) | `name\|logic_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |
| 8 | N0025 | 2 (4) | 0 | 0 | 10 | B | OPEN | `depth\|constant\|range->operation` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbol |
| 9 | N0033 | 2 (4) | 0 | 0 | 10 | B | OPEN | `struct\|ours-only:fewer-copies\|operation\|under:range` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCall |
| 10 | N0487 | 2 (2) | 0 | 0 | 8 | B | OPEN (map 10 ground-B step 6) [r11u191: rows 4->2] | `struct\|ours-only:absent\|constant\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law srlgUnvaluedActualLitRetFold8) < emitInstance (ModuleEmit.cpp,  |
| 11 | N0133 | 2 (2) | 0 | 0 | 6 | B | OPEN (map 10 ground-B step 6) [r11u191: rows 4->2] | `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInstance (ModuleEmit.cpp, law unnam |
| 12 | N0754 | 2 (1) | 0 | 0 | 5 | A | OPEN | `fullname\|ref_obj\|tok:id->id.id\|under:cont_assign` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitContAssigns (ModuleEmit.cpp, law caUnbase |
| 13 | N0761 | 2 (1) | 0 | 0 | 3 | B | OPEN | `fullname\|ref_typespec\|tok:->id@id.id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, l |
| 14 | N0045 | 2 (1) | 0 | 0 | 2 | A | OPEN | `struct\|golden-only:fewer-copies\|constant\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduce20) < exportDesign (UhdmExporter.cpp,  |
| 15 | N0794 | 2 (1) | 0 | 0 | 2 | A | OPEN | `fullname\|ref_typespec\|tok:->id@id.id.\|under:logic_typespec` | makeParamTs (ParamEmit.cpp, law pkgParamOwnDefRange) < drainDefParamTs (ParamEmit.cpp, law paramClon |
| 16 | N0852 | 2 (1) | 0 | 0 | 1 | B | OPEN | `span\|int_var\|endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitModuleDef (ModuleEmit.cpp, l |
| 17 | N0028 | 2 (2) | 0 | 0 | 0 | B | OPEN | `fullname\|ref_typespec\|tok:->id.\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, l |
| 18 | N0552 | 2 (1) | 0 | 0 | 0 | B | OPEN | `fullname\|ref_typespec\|tok:id->id.id\|under:typespec_member` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, l |
| 19 | N0675 | 2 (1) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_typespec\|tok:id->id.id\|under:constant` | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law |
| 20 | N1137 | 2 (1) | 0 | 0 | 0 | B | OPEN | `span\|byte_var\|endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < operator() (ModuleEmit.cpp, law  |
| 21 | N1147 | 2 (1) | 0 | 0 | 0 | B | OPEN | `span\|integer_var\|endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < operator() (ModuleEmit.cpp, law  |
| 22 | N1149 | 2 (1) | 0 | 0 | 0 | B | OPEN (map 10 ground-B step 8) | `span\|logic_typespec\|line+col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |
| 23 | N1150 | 2 (1) | 0 | 0 | 0 | B | OPEN | `span\|long_int_var\|endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < operator() (ModuleEmit.cpp, law  |
| 24 | N1155 | 2 (1) | 0 | 0 | 0 | B | OPEN | `span\|short_int_var\|endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < operator() (ModuleEmit.cpp, law  |
| 25 | N2412 | 2 (1) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_typespec\|tok:->id@id.id.\|under:constant` | leftRefFix174 (ParamEmit.cpp, law evalFuncBodyRhsStampClone167) < leftRefWalk174 (ParamEmit.cpp, law |

### T1c. Per ground, all rows (top 20 each)

Ground A (ExprEmit / EmitHelpers / StmtEmit / ParamEmit):

| # | cluster | rows (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0097 | 9 (5) | 0 | 0 | 9 | A | OPEN (map 10 gave it to r11u184) | `span\|hier_path\|endcol\|under:assignment` | emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69 |
| 2 | N0012 | 9 (5) | 0 | 0 | 3 | A | OPEN (map 10 gave it to r11u184) | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classVarInit |
| 3 | N0034 | 9 (5) | 0 | 0 | 3 | A | OPEN (map 10 gave it to r11u184) | `span\|enum_typespec\|ours-zero\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classVarInit |
| 4 | N0207 | 9 (5) | 0 | 0 | 1 | A | OPEN | `fullname\|ref_obj\|tok:::->.\|under:sys_func_call` | emitExpr (ExprEmit.cpp, law genCaSysCallArgBinds22) < emitExpr (ExprEmit.cpp, law incDecMemberPathIs |
| 5 | N0054 | 9 (5) | 0 | 0 | 0 | A | OPEN | `span\|assignment\|endcol\|under:begin` | emitExpr (ExprEmit.cpp, law outArgConvLvalue125) < emitStmt (StmtEmit.cpp, law recvNamesSubroutineCo |
| 6 | N0197 | 9 (5) | 0 | 0 | 0 | A | OPEN | `struct\|golden-only:fewer-copies\|string_typespec\|under:ref_typespec` | operator() (StmtEmit.cpp, law foreachAssocIdxAliasTs22) < emitStmt (StmtEmit.cpp, law foreachLoopVar |
| 7 | N0222 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|bit_select\|tok:id - n->id-n\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) |
| 8 | N0225 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|bit_select\|tok:id + n->id+n\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpIdxOpPrettyPrint92) < emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) |
| 9 | N0227 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id[id - n].id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 10 | N0234 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id[id].id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law emptyArgSlotInt |
| 11 | N0235 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id.id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 12 | N0237 | 9 (5) | 0 | 0 | 0 | A | OPEN | `span\|bit_select\|endcol\|under:operation` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLva |
| 13 | N0238 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|bit_select\|tok:id[id].id::->\|under:method_func_call` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24 |
| 14 | N0247 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id[id * n+:n]::id::->\|under:operation` | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law incDecMemberPathI |
| 15 | N0252 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id.id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law cloneBuiltinMet |
| 16 | N0253 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_typespec\|tok:::id[id].id->\|under:operation` | emitExpr (ExprEmit.cpp, law packageVarAutomaticIsDataDeclShape26) < emitExpr (ExprEmit.cpp, law empt |
| 17 | N2400 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id[]::id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNa |
| 18 | N2401 | 9 (5) | 0 | 0 | 0 | A | OPEN | `fullname\|ref_obj\|tok:id.id.id[]::id::->\|under:hier_path` | emitExpr (ExprEmit.cpp, law vifClockingPathComponent5) < emitExpr (ExprEmit.cpp, law hpTrailSelIdxNa |
| 19 | N0290 | 7 (4) | 0 | 0 | 2 | A | OPEN | `span\|method_func_call\|endline+endcol\|under:hier_path` | emitExpr (ExprEmit.cpp, law hpNameBareIdxFold69) < emitExpr (ExprEmit.cpp, law incDecMemberPathIsLva |
| 20 | N0098 | 7 (4) | 0 | 0 | 1 | A | OPEN | `file\|ref_obj\|ours-empty\|under:hier_path` | emitExpr (ExprEmit.cpp, law dottedIdxRecvFromSyntax23) < emitExpr (ExprEmit.cpp, law incDecMemberPat |

Ground B (TypeEmit / ModuleEmit / UhdmExporter / TaskFuncEmit / uhdm_main):

| # | cluster | rows (tests) | first-open heads | alone | probe | ground | status | key | site |
|---|---|---|---|---|---|---|---|---|---|
| 1 | N0056 | 11 (6) | 9 | 2 | 1 | B | OPEN (map 10 gave it to r11u186) | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (Uhd |
| 2 | N0067 | 9 (5) | 0 | 0 | 3 | B | OPEN (map 10 gave it to r11u186) | `file\|class_typespec\|ours-empty\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law unsupportedTsInitEnd152) < makeTypespec (TypeEmit.cpp, law tpFormalI |
| 3 | N0068 | 9 (5) | 0 | 0 | 3 | B | OPEN (map 10 gave it to r11u186) | `span\|class_typespec\|ours-zero\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law unsupportedTsInitEnd152) < makeTypespec (TypeEmit.cpp, law tpFormalI |
| 4 | N0180 | 9 (5) | 0 | 0 | 3 | B | OPEN | `fullname\|ref_typespec\|ours-empty\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < makeTypespec (TypeEmit.cpp, law classPkgGeneric |
| 5 | N0158 | 9 (5) | 0 | 0 | 2 | B | OPEN | `depth\|bit_typespec\|ref_typespec->ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |
| 6 | N0177 | 9 (5) | 0 | 0 | 2 | B | OPEN | `struct\|ours-only:absent\|bit_typespec\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < materializeDefNetTs (ModuleEmit.cpp, law me |
| 7 | N0184 | 9 (5) | 0 | 0 | 2 | B | OPEN | `span\|bit_var\|col+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law assocLocalArrayVar40) < emitPackage (ParamEmit.cpp, law LAW) <  |
| 8 | N0188 | 9 (5) | 0 | 0 | 2 | B | OPEN | `name\|enum_typespec\|ours-empty\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classPkgGene |
| 9 | N0423 | 9 (5) | 0 | 0 | 1 | B | OPEN | `struct\|golden-only:fewer-copies\|enum_typespec\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law blockLocalTdDeclIsRefVarUnsupported155) < emitClassDefn (UhdmEx |
| 10 | N0117 | 9 (5) | 0 | 0 | 0 | B | OPEN | `span\|unsupported_typespec\|endcol\|under:ref_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law classScopedTdFormalUnsupported34) < emitClassDefn (UhdmExporter |
| 11 | N0120 | 9 (5) | 0 | 0 | 0 | B | OPEN | `span\|enum_var\|line+col+endline+endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitClassDefn (UhdmExporter.cpp, |
| 12 | N0213 | 9 (5) | 0 | 0 | 0 | B | OPEN | `struct\|golden-only:absent\|enum_typespec\|under:ref_typespec` | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < buildClassTypedefTs (UhdmExpo |
| 13 | N0230 | 9 (5) | 0 | 0 | 0 | B | OPEN | `span\|class_typespec\|line+endline\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law arrayElemTdClone42) < sharedTypespec (TypeEmit.cpp, law typeParamDef |
| 14 | N0232 | 9 (5) | 0 | 0 | 0 | B | OPEN | `struct\|ours-only:elsewhere\|ref_typespec\|under:array_typespec` | emitTaskFuncs (TaskFuncEmit.cpp, law modTdRetCloneSymbolic20) < emitClassDefn (UhdmExporter.cpp, law |
| 15 | N0254 | 9 (5) | 0 | 0 | 0 | B | OPEN | `fullname\|ref_typespec\|tok:id::id::->\|under:enum_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < buildClassTypedefTs (UhdmExporter.cpp, law clas |
| 16 | N0255 | 9 (5) | 0 | 0 | 0 | B | OPEN | `span\|class_typespec\|line+col+endline+endcol\|under:class_defn` | buildClassTypedefTs (UhdmExporter.cpp, law classTpTdGroupNonClsRootShared91) < classElemVar (UhdmExp |
| 17 | N0256 | 9 (5) | 0 | 0 | 0 | B | OPEN | `span\|class_var\|endcol\|under:function` | emitTaskFuncs (TaskFuncEmit.cpp, law implicitRetSigningIsIntVar70) < emitClassDefn (UhdmExporter.cpp |
| 18 | N0025 | 7 (4) | 0 | 0 | 10 | B | OPEN | `depth\|constant\|range->operation` | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbol |
| 19 | N0033 | 7 (4) | 0 | 0 | 10 | B | OPEN | `struct\|ours-only:fewer-copies\|operation\|under:range` | emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarRangeCall |
| 20 | N0288 | 7 (4) | 0 | 0 | 4 | B | OPEN | `fullname\|ref_typespec\|golden-empty\|under:array_typespec` | importVarCopy5 (ModuleEmit.cpp, law importCopyTsSubtreeNoInstance7) < classInheritsContainerImports2 |

Probe-only OPEN clusters with the most cases after r11u191: N1897 (119, B: `fullname|logic_net|tok:.id@id->|under:module_inst`,
laws caNestedModPortedDefShell101 / caTopNamesakeKeyAtEntry105), N1898 (92, B), N1899 (51, B), N0094 (51, B), N1900
(50, B), N1901 (45, B), N1902 (37, A), N0739 (27, A), N1903 (21, A), N0476 (20, A), N1904 (20, A), N0477 (20, A), N1905
(17, B), N1907 (15, B) ([evidence/report.txt](evidence/report.txt) section 4). Laws with the most NE cases:
caNestedModPortedDefShell101 36/38, srlgCondOpInstValueTernFold9 32/140, nestedParamActualTs6 29/41,
tpPackedArrayTsVar108 28/73, caIfacePortDeclNetMint93 27/35, caTopNamesakeKeyAtEntry105 26/27,
srlgUnvaluedActualLitRetFold8 23/98, defPkgMemberTdOfNamedShares108 22/42. The probe cases by first cluster:

| first cluster | probe cases it heads | clears (r11u191 / pairs) | ground | status | key | top laws |
|---|---|---|---|---|---|---|
| N1897 | 106 | no 106 | B | OPEN | `fullname\|logic_net\|tok:.id@id->\|under:module_inst` | caNestedModPortedDefShell101:36 caTopNamesakeKeyAtEntry105:26 caNested |
| N0263 | 54 | no 54 | B | OPEN | `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` | caIfacePortDeclNetMint93:26 tpPackedArrayTsVar108:5 srlgUnvaluedActual |
| N0284 | 44 | no 44 | B | OPEN | `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` | srlgUnvaluedActualLitRetFold8:19 loopCaParamReadKeepsLiteral116:10 caS |
| N0039 | 31 | yes pair B 25, no 6 | A | COVERED r11u193 (map 10 ground-B list, the UVM gro | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | nestedParamActualTs6:22 genIfUnvaluedFuncParam7:4 satArrArgFirstElem5: |
| N0003 | 30 | no 24, yes pairs A+B 6 | A | COVERED r11u195 (pass 192 R3 (decoded): StructPara | `fullname\|ref_typespec\|golden-empty\|under:operation` | patParamEvalFuncRead26:12 patParamLeftoverShare26:6 memLeftStampOwnTyp |
| N0040 | 29 | yes pair B 27, no 2 | B | COVERED r11u193 (map 10 ground-B step 1: Interface | `span\|logic_typespec\|endcol\|under:ref_typespec` | nestedParamActualTs6:18 caIfaceNdaNameFoldsToParamValue88:5 caIfaceEla |
| N0738 | 27 | no 18, yes pairs A+B 7, yes pair B 2 | B | COVERED r11u193 (map 10 joint step 10: func_typena | `name\|logic_typespec\|tok:id::->\|under:ref_typespec` | pkgTdQualParamCopiesListing111:11 defPkgMemberTdOfNamedShares108:8 tpP |
| N0739 | 26 | no 26 | A | OPEN | `struct\|ours-only:fewer-copies\|ref_obj\|under:cont_assign` | pkgRhsStructBareCopy111:14 defPkgMemberTdOfNamedShares108:11 tpPackedA |
| N1169 | 23 | no 23 | B | OPEN | `file\|constant\|ours-empty\|under:cont_assign` | srlgCondOpInstValueTernFold9:22 caTernFillArmKeepsEncoding19:1 |
| N0443 | 15 | yes pair A 13, no 2 | A | COVERED r11u195 (pass 188 sister face / map 10 A r | `fullname\|ref_typespec\|tok:.id.id->\|under:constant` | genLpIdxOpOperandFold112:12 genElseArmCollapse48:1 genCaParamFoldOneHo |
| N0129 | 14 | no 14 | A | OPEN (map 10 ground-A step 1) | `fullname\|ref_typespec\|tok:->.id\|under:constant` | genCaOpFoldElabTs115:6 insideSetFirstRangeTruncates99:2 caSysArgOpFold |
| N1911 | 14 | no 14 | B | OPEN | `fullname\|type_parameter\|tok:->id::@in-typespec\|under:class_typespec` | classTdCloneSpecOverridesOwnArgs112:14 |
| N0485 | 12 | no 12 | B | OPEN | `fullname\|int_var\|tok:id->id\|under:function` | pkgVarInitCmViewClone111:5 cloneBodyIsAScopeEvenWithNoOwnLocals181:3 c |
| N0682 | 12 | no 12 | A | COVERED r11u195 (map 10 A remainder, the UVM groun | `fullname\|ref_typespec\|tok:->id::\|under:parameter` | impFoldRhsMirrorsLhsTs201:7 unitImportHoistsPkgParams146:3 impUnsizedB |
| N1916 | 12 | no 12 | B | OPEN | `struct\|golden-only:fewer-copies\|logic_net\|under:cont_assign` | caIfaceNdaNameFoldsToParamValue88:9 caIfaceElabNetDeclAssignListing88: |
| N0474 | 10 | no 10 | A | OPEN (map 10 gave it to r11u184) | `fullname\|ref_typespec\|tok:->.id[n]\|under:constant` | caSysArgOpFoldTs115:5 genCaTopLoopParamPaCopy105:2 genCaOpFoldElabTs11 |
| N1921 | 9 | no 9 | B | OPEN | `span\|int_var\|col+endcol\|under:function` | tfItemLocalInitHoistsNoStatement145:4 tfItemTaskParamBreaksTheWalk145v |
| N1922 | 9 | no 9 | A | OPEN | `fullname\|parameter\|tok:.id@id->\|under:module_inst` | caNestedModPortedDefShell101:7 caNestedModDeclNoRefNoInst99:2 caNested |
| N0084 | 9 | no 9 | A | OPEN | `fullname\|ref_typespec\|tok:id@id.id.->\|under:typespec_member` | tpAnonAggParamTsNoStamp47:7 typeParamChainBorrow45:1 typeParamAnonAggD |
| N0097 | 8 | no 8 | A | OPEN (map 10 gave it to r11u184) | `span\|hier_path\|endcol\|under:assignment` | shellCallKeepsItsSyntax167:2 parensLessFuncRefIsRefObj:2 covergroupBui |

## 7. The fail list with sites (fail_list.csv, probe_fail_list.csv)

Every STRICT_NOTEQUAL row-mode with its first cluster (at 4a65840e), that cluster's coverage, ground and site, all its
clusters, the strict cell after r11u191, its first OPEN cluster after the pairs, the open clusters left and whether it
clears (r11u191 measured / pair A / pair B / both, optimistic). probe_fail_list.csv is the same per probe case (932).
By test, sorted by cluster count (a `-` mode is not NE):

| corpus | test | cell d / t | clusters d/t | first cluster (ground) | first site | after r11u191 | first open after the pairs | open after pairs | clears | downstream |
|---|---|---|---|---|---|---|---|---|---|---|
| sur | HierPathTypespec | - / differ:fullname(1) | -/1 | N1174 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | - | -/0 | yes (pair B, optimistic) | - |
| sur | InterfArrayBind | differ:fullname(3) / - | 1/- | N0427 (A) | emitExpr (ExprEmit.cpp) < operator() (ModuleEmit.cpp, law genCaParamFo | same | - | 0/- | yes (pair A, optimistic) | - |
| sur | InterfaceModPort | differ:endcol(12) / differ:endcol(12) | 1/1 | N0040 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedP | same | - | 0/0 | yes (pair B, optimistic) | - |
| sur | PreprocTest | differ:endcol(2) / differ:endcol(2) | 1/1 | N0056 (B) | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (Para | same | N0056 | 1/1 | no | - |
| sur | StructParamPatternInitCast | differ:fullname(3) / differ:fullname(3) | 2/2 | N0003 (A) | emitParameters (ParamEmit.cpp, law elabPatQualRefQualSpan133) < emitIn | same | - | 0/0 | yes (pairs A+B, optimistic) | - |
| sur | UnitElabBlock | differ:endline(13) / differ:endline(12) | 3/2 | N0090 (B) | makeTypeParamDefaultTs (TypeEmit.cpp, law typeParamDefaultBoundNoReduc | same | - | 0/0 | yes (pairs A+B, optimistic) | - |
| sur | FuncStructValSimple | differ:file(39) / differ:file(59) | 3/3 | N0086 (A) | makeMemLeftConst (ParamEmit.cpp, law pkgStructFuncAssembleNested24) <  | same | - | 0/0 | yes (pair A, optimistic) | - |
| sur | LogicTypespec | differ:endline(3) / differ:endline(3) | 4/4 | N0422 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitPackage ( | same | N0422 | 4/4 | no | - |
| sur | InterfaceStructMemberPort | differ:fullname(6) / differ:fullname(6) | 5/5 | N1134 (B) | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) < emitInst | same | - | 0/0 | yes (pair B, optimistic) | - |
| sur | FuncStructVal | differ:endcol(95) / differ:endcol(165) | 7/8 | N1096 (A) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprE | same | - | 0/0 | yes (pair A, optimistic); yes (pairs A+B, optimistic) | - |
| sur | ClassTypeParam | differ:endline(17) / differ:file(30) | 8/10 | N1081 (B) | exportDesign (UhdmExporter.cpp, law unitImportHoistsPkgParams146v) < m | same | - | 0/0 | yes (pair B, optimistic) | - |
| sur | SVSwitch | differ:fullname(13) / differ:fullname(13) | 9/9 | N0007 (A) | emitExpr (ExprEmit.cpp, law parensLessCallIsPathRefObj) < emitExpr (Ex | same | N1011 | 7/7 | no | - |
| sur | Scr1SvTests | differ:type(1) / differ:type(1) | 22/22 | N0965 (A) | emitExpr (ExprEmit.cpp, law pkgQualParamPartSelName118) < emitExpr (Ex | differ:endcol(29) / differ:endcol(29) | N1139 | 17/17 | no | - |
| sur | BlackBePipeInt | differ:fullname(2) / differ:fullname(2) | 27/25 | N0923 (A) | stampParenCastWidthTs (ParamEmit.cpp, law parenCastWidthRefModuleCopy) | same | N0923 | 25/23 | no | - |
| sur | Rggen | differ:endcol(144) / - | 43/- | N0040 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitImportedP | same | N0145 | 38/- | no | - |
| sur | Earlgrey_0_1 | differ:col(91) / differ:col(91) | 73/69 | N1082 (A) | tryFoldConst (ExprEmit.cpp, law srlgSizeCastUbShiftMask93) < operator( | differ:fullname(90) / differ:fullname(90) | N0941 | 62/59 | no | - |
| sur | BuildUVMPkg | differ:fullname(20) / differ:fullname(20) | 97/97 | N0215 (B) | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprE | differ:line(11) / differ:line(11) | N0189 | 64/64 | no | - |
| sur | Scoreboard | differ:fullname(54) / - | 118/- | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitPackage (P | differ:fullname(52) / - | N0056 | 77/- | no | - |
| sur | SimpleUVM | differ:fullname(54) / differ:fullname(54) | 121/121 | N0682 (A) | emitParameters (ParamEmit.cpp, law modDefImportShape) < emitPackage (P | differ:fullname(52) / differ:fullname(52) | N0056 | 82/82 | no | - |
| sur | SeqDriver | differ:file(26) / differ:file(26) | 230/230 | N0327 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitTaskFuncs | differ:file(24) / differ:file(24) | N0056 | 192/192 | no | - |
| sur | MiniAmiq | differ:file(27) / differ:file(27) | 234/234 | N0144 (B) | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < emitPackage (P | differ:file(25) / differ:file(25) | N0056 | 197/197 | no | - |
| uhd | anon_struct_packed_dim | differ:fullname(43) / differ:fullname(43) | 2/2 | N0014 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | const_cast_signext | differ:type(1) / differ:type(1) | 2/2 | N0133 (B) | emitContAssigns (ModuleEmit.cpp, law caAsmMemberSliceFold) < emitInsta | equal (r11u191, measured) / equal (r11u191, measured) | - | 0/0 | yes (r11u191, measured) | IDENTICAL |
| uhd | func_typename_ret | differ:name(2) / differ:name(2) | 2/2 | N0738 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < makeParamTs ( | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | ibex_pmp | differ:file(5) / differ:file(5) | 2/2 | N0219 (B) | buildStructTs (TypeEmit.cpp, law anonMemberRefChainName134) < emitPack | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | rsp_gen_minimal | differ:fullname(2) / differ:fullname(2) | 3/3 | N0416 (A) | emitExpr (ExprEmit.cpp, law packageVarAutomaticIsDataDeclShape26) < em | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | OutputSizeWithParameterOfInstanceInitializedByStructMember | differ:line(8) / differ:line(8) | 4/4 | N0191 (A) | emitDroppedCall14 (StmtEmit.cpp, law classArgBind12) < emitBadConcatFr | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | arb_idx_cast | differ:endcol(17) / differ:endcol(17) | 4/4 | N0448 (B) | operator() (TypeEmit.cpp, law shadowedImportParamFold) < makeTypespec  | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | ibex_tracer | differ:fullname(579) / differ:fullname(579) | 6/6 | N0563 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | - | 0/0 | yes (pairs A+B, optimistic) | IDENTICAL |
| uhd | cfg_func_width_loop | differ:line(3) / differ:line(3) | 7/7 | N0263 (B) | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < sharedTypespe | same | N0263 | 7/7 | no | IDENTICAL |
| uhd | struct_param_func_config | differ:fullname(5) / differ:fullname(5) | 7/7 | N0817 (B) | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < | same | N0817 | 7/7 | no | IDENTICAL |
| uhd | int_types | differ:fullname(82) / differ:fullname(82) | 8/8 | N0912 (B) | emitSyntaxExpr (TypeEmit.cpp, law modStructMemberPkgFold) < operator() | same | N0912 | 7/7 | no | IDENTICAL |

**The count after them: 60 row-modes / 32 tests -> 58 / 31 after r11u191 (measured) -> 28 / 15 after both pairs
(optimistic; 36 / 20 without the five named optimisms of section 5); probe 932 -> 930 -> 787.**

## 8. Structural rows and downstream-visible faces

### 8a. Structural rows (first field depth / type / count)

| row | 4a65840e | after r11u191 | first cluster | what it needs |
|---|---|---|---|---|
| Scr1SvTests d/t | `type(1)` | `endcol(29)` | N0965 `struct\|golden-only:fewer-copies\|ref_typespec\|under:indexed_part_select` (A) | **cleared by r11u191's law evalFuncExecCallArgTs191** (unlanded; pair A r11u195's first item): UHDM `ExprEval::evalFunc` stamps the formal's typespec on each argument it binds, mutating the source part-select. Behind it 17 open clusters (5 A, 12 B), first N1139 (`span\|constant\|col+endline+endcol\|under:param_assign`, scr1_reset_and3_cell 118:47-125:63 golden, 118:48-118:64 ours; UhdmExporter pin) |
| const_cast_signext d/t (u2r) | `type(1)` | **CMP_EQUAL** | N0133 `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign` (B) | **converted by r11u191's law evalFuncCastMemberKeepsCall191** (unlanded; pair B's next refill r11u196): the constant call is kept when the body casts to logic / reg / byte / a packed struct or reads a struct member. Downstream IDENTICAL before and after |

No row is `count` or `stage1`, and after r11u191 no corpus row is structural. The probe set holds 33 `depth` and 73
`type` first fields at 4a65840e, 33 and 71 after r11u191.

### 8b. Downstream-visible faces ([drivers/dsfaces.py](drivers/dsfaces.py): the gate's own `one()`, a fresh `GOLDEN_CACHE`, both binaries; [evidence/downstream/dsfaces_P.csv](evidence/downstream/dsfaces_P.csv), [dsfaces_L.csv](evidence/downstream/dsfaces_L.csv))

106 cases. Pristine: 68 IDENTICAL, 20 EQUIVALENT, 10 DIVERGENT, 8 STATUS_DIFF; law191: 80 IDENTICAL, 12 EQUIVALENT, 6
DIVERGENT, 8 STATUS_DIFF. **Every verdict the law binary changes moves toward IDENTICAL, and all are r11u191's own
cases; no carried face moves.**

| face | cases | verdict at 4a65840e | law191 | what it needs |
|---|---|---|---|---|
| r11u173 N1: a range query onto an implicit net in a generate-for (`assign ccc = $high(a)`) | r11u173verify/cases/rq/q08 (q03 the declared-net control) | **q08 DIVERGENT** (nohier, il, synth); q03 IDENTICAL | same | ModuleEmit's generate-scope cont_assign emission has no sysFold branch (ground B); unchanged since map 8 |
| r11u173 N2: `g[S.a].x`, a hier path into a generate array indexed by a struct-parameter member | r11u173verify/cases/hw/w12, w13 | **w12, w13 DIVERGENT** | same | the index fold of a struct-parameter member inside a hier_path (ExprEmit path builders, ground A); not decoded |
| pass 158: the size cast as a whole continuous-assign value | r11u158repro/cases/sc c1-c17 | 15 IDENTICAL; **c10, c12 EQUIVALENT** (nohier) | same | c10 = pass 158 S2 (gen-if `3'(-1)`, ModuleEmit emitBlock's gen-CA branch); c12 = S3 (instance-overridden width `W'(7)`, ModuleEmit emitContAssigns) |
| pass 160: the LogicTypespec Surelog-defect candidate | r11u160repro/evidence/residue/LT l01, l02 (scratch copies) | l01 IDENTICAL; **l02 DIVERGENT** (`$bits(x)` 2 on the Surelog lane, 32 on ours) | same | following golden changes a netlist toward a Surelog defect: a user decision (LogicTypespec d/t stay in the fail list) |
| pass 181: digit separators and unsized based literals outside the literal emitter | r11u181repro/cases/us u01-u08 | u01, u03-u07 IDENTICAL; **u02, u08 EQUIVALENT** (nohier, il) | same | u02 / u08: an unsized based literal as a WHOLE continuous-assign right side (golden sizes it to the target; pass 184 R7 decoded the clone in Surelog's cont_assign writer). r11u191's law elabCaConstLhsSized191 does not reach them (its U grid is the package-parameter fold) |
| r11u185: the generic ANSI interface port after an interface-typed port | r11u185verify/cases/GV v01-v15, PG/p04 | **v07, v08, v09, v15, p04 STATUS_DIFF** (Surelog lane NO_GATES, ours READ_FAIL); v02, v11 EQUIVALENT; the rest IDENTICAL | same | type such a port in the definition view like its predecessor (ModuleEmit, ground B); stage 1 on every broken case, so the strict map does not see it |
| r11u185 PU/u06: a whole-value copy `C = B` beside `$bits(B)` and `B.D` | r11u185verify/cases/PU/u06 | **DIVERGENT** | same | golden expands C's listing to tagged patterns, ours keeps a reference (ParamEmit, ground A); PU u01-u05, u07 IDENTICAL |
| r11u185 UD/u04: UDP-form instance arrays `ch a1 [1:0] (w1, w2, o)` | r11u185verify/cases/UD/u04 | **DIVERGENT** | same | ModuleEmit instance-array UDP form (ground B); UD u01-u03, u05, u06 IDENTICAL |
| v11u171 R4: the UDP-form swallow on a non-lvalue first concatenation | v11u171repro/cases/Q c01-c14 | c02, c08, c14 EQUIVALENT; the other 11 IDENTICAL | same | unchanged since map 10 |
| **r11u194 N1**: a parameterized class declared inside a module and specialized there | r11u194verify/cases/Z/z01, X/x01 | **STATUS_DIFF**: Surelog lane NO_GATES, **slang lane CRASH** (the downstream plugin reading OUR definition-view database dies after listing `work@sub (v)`); `slang-uhdm --elabuhdm` rc 139 on both cases, the definition view rc 0 ([evidence/downstream/n1_elabuhdm_crash.txt](evidence/downstream/n1_elabuhdm_crash.txt)) | same (rc 139 under `--elabuhdm`, CRASH downstream) | **new here: N1 is downstream-visible without `--elabuhdm`** - our definition view of a module-local class specialization crashes uhdm2rtlil's reader. No corpus row carries it (the corpora's 803 IDENTICAL rows are unaffected); the fix site is UhdmExporter's class emission inside a module (ground B) |
| r11u190 N5: a split port redeclared `real` | r11u190verify/cases/R/r01; r11u191dec/cases/R r01-r04 | **r11u190 R/r01, r11u191 R/r01, r02 DIVERGENT**; r03 EQUIVALENT; r04 IDENTICAL | **all IDENTICAL** | law splitPortRealRedeclLogicTs191 (law_typeemit.patch, unlanded): the netlist follows golden |
| r11u190 N6: a 70-bit localparam with digit separators | r11u190verify/cases/US u01-u04 | **u01 STATUS_DIFF** (the plugin cannot parse `INT:100000000000000000000`); u02-u04 IDENTICAL | same | not decoded |
| pass 186's P face: the elaborated constant sized to the LHS | r11u191dec/cases/U (19 cases) | 8 EQUIVALENT (u02 u05 u09 u10 u_p01 u_p03 u_p06 u_p08), 2 more EQUIVALENT (u_p02 u_p07), **u08 DIVERGENT**, 8 IDENTICAL | the 8 **IDENTICAL**; u08 **EQUIVALENT**; u_p02, u_p07 EQUIVALENT | law elabCaConstLhsSized191 (law_typeemit.patch, unlanded): netlists move toward golden; u08 (a negative int, r11u191 R6) and u_p02 / u_p07 stay |

## 9. The per-ground briefs (on top of r11u191 measured + both pairs optimistic)

The base is 32 row-modes / 17 tests cleared. **The remaining 28 row-modes carry**: by open-cluster count, 1: 2
(PreprocTest), 4: 2 (LogicTypespec), 6 or more: 24; by ground, B only 8 (PreprocTest, LogicTypespec, int_types,
SVSwitch), both 20. Every OPEN cluster of ground A (175) clears 0 row-modes alone; every OPEN cluster of ground B (232)
clears 8. **No remaining row ends on ground A alone.** A candidate is the whole open-cluster set of one remaining row
(<= 4 clusters one ground, <= 6 joint, map 10's caps), and the **deep** lists take a row's whole open set whatever its
size; the greedy picks by row-modes cleared per cluster added ([evidence/report.txt](evidence/report.txt) section 8,
[evidence/greedy11.json](evidence/greedy11.json)).

**Ground A.** The capped and deep lists are empty: every remaining row needs ground B too.

**Ground B, capped (map 10's shape).**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0056 | 2 | 34 | 18 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 2 | N0083 + N0422 + N0484 + N1149 | 2 | 36 | 19 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`; `name\|logic_typespec\|ours-empty\|under:ref_typespec`; `span\|logic_typespec\|line+col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |

**Ground B, deep (whole rows).**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0056 | 2 | 34 | 18 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 2 | N0083 + N0422 + N0484 + N1149 | 2 | 36 | 19 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`; `name\|logic_typespec\|ours-empty\|under:ref_typespec`; `span\|logic_typespec\|line+col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |
| 3 | N0852 + N0912 + N1137 + N1147 + N1150 + N1155 | 2 | 38 | 20 | int_types/d/u2r int_types/t/u2r | `span\|int_var\|endcol\|under:function`; `fullname\|ref_obj\|ours-empty\|under:assignment`; `span\|byte_var\|endcol\|under:function`; `span\|integer_var\|endcol\|under:function` ... | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitModuleDef (ModuleEmit.cpp, law thisImplicitNetBoth38) < exportDesign (UhdmExpo |
| 4 | N0526 + N0954 + N0958 + N1010 + N1011 + N1019 + N1020 | 2 | 40 | 21 | SVSwitch/d SVSwitch/t | `struct\|ours-only:fewer-copies\|logic_net\|under:io_decl`; `fullname\|logic_var\|tok:id->id@id.id\|under:interface_inst`; `fullname\|ref_typespec\|tok:id->id@id.id\|under:logic_var`; `fullname\|bit_var\|tok:id->id@id.id\|under:interface... | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFallback215v) < emitIns |

**Joint (both grounds), deep: the order that converts the most rows per cluster.**

| step | clusters added | +row-modes | cum row-modes | cum tests | rows | key(s) | site of the first |
|---|---|---|---|---|---|---|---|
| 1 | N0056 | 2 | 34 | 18 | PreprocTest/d PreprocTest/t | `span\|bit_typespec\|endcol\|under:ref_typespec` | buildEnumTs (TypeEmit.cpp, law bareScalarTdCopyOf) < emitPackage (ParamEmit.cpp) < exportDesign (UhdmExporter.cpp, law caUnelabBodyChildPorts103) [r11 |
| 2 | N0083 + N0422 + N0484 + N1149 | 2 | 36 | 19 | LogicTypespec/d LogicTypespec/t | `struct\|golden-only:fewer-copies\|range\|under:logic_typespec`; `span\|logic_typespec\|endline+endcol\|under:package`; `name\|logic_typespec\|ours-empty\|under:ref_typespec`; `span\|logic_typespec\|line+col+endcol\|under:ref_typespec` | makeTypespec (TypeEmit.cpp, law suSigningNotInSpan130) < emitParameters (ParamEmit.cpp, law typeParamChainBorrow45) < emitInterfaceInstance (ModuleEmi |
| 3 | N0852 + N0912 + N1137 + N1147 + N1150 + N1155 | 2 | 38 | 20 | int_types/d/u2r int_types/t/u2r | `span\|int_var\|endcol\|under:function`; `fullname\|ref_obj\|ours-empty\|under:assignment`; `span\|byte_var\|endcol\|under:function`; `span\|integer_var\|endcol\|under:function` ... | emitTaskFuncs (TaskFuncEmit.cpp, law ownNamedAliasRetIsRefVar177) < emitModuleDef (ModuleEmit.cpp, law thisImplicitNetBoth38) < exportDesign (UhdmExpo |
| 4 | N0025 + N0033 + N0133 + N0263 + N0487 + N0754 + N0794 | 2 | 40 | 21 | cfg_func_width_loop/d/u2r cfg_func_width_loop/t/u2r | `depth\|constant\|range->operation`; `struct\|ours-only:fewer-copies\|operation\|under:range`; `struct\|golden-only:fewer-copies\|func_call\|under:cont_assign`; `span\|logic_typespec\|line+col+endline+endcol\|under:ref_typespec` ... | emitSyntaxExpr (TypeEmit.cpp, law fnLocalParamRangeNet) < emitSyntaxExpr (TypeEmit.cpp, law hpSymbolicSelect) < operator() (TypeEmit.cpp, law elabVarR |
| 5 | N0028 + N0045 + N0552 + N0675 + N0761 + N0817 + N2412 | 2 | 42 | 22 | struct_param_func_config/d/u2r struct_param_func_config/t/u2r | `fullname\|ref_typespec\|tok:->id.\|under:typespec_member`; `struct\|golden-only:fewer-copies\|constant\|under:typespec_member`; `fullname\|ref_typespec\|tok:id->id.id\|under:typespec_member`; `fullname\|ref_typespec\|tok:id->id.id\|unde... | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeParamTs (ParamEmit.cpp, law defPkgStructParamMemberNames154) < patchParamTy |
| 6 | N0526 + N0954 + N0958 + N1010 + N1011 + N1019 + N1020 | 2 | 44 | 23 | SVSwitch/d SVSwitch/t | `struct\|ours-only:fewer-copies\|logic_net\|under:io_decl`; `fullname\|logic_var\|tok:id->id@id.id\|under:interface_inst`; `fullname\|ref_typespec\|tok:id->id@id.id\|under:logic_var`; `fullname\|bit_var\|tok:id->id@id.id\|under:interface... | emitInterfaceInstance (ModuleEmit.cpp, law modportExprPort) < emitInstance (ModuleEmit.cpp, law modportNeedsSimplePortNoGenericFallback215v) < emitIns |
| 7 | N0021 + N0030 + N0078 + N0284 + N0426 + N0741 + N0779 + N0791 + N0836 + N0921 + N1009 + N1069 + N1112 + N1113 + N1119 + N1139 + N2405 | 2 | 46 | 24 | Scr1SvTests/d Scr1SvTests/t | `fullname\|ref_obj\|tok:id.id.->\|under:operation`; `fullname\|ref_obj\|tok:id.->\|under:operation`; `fullname\|ref_obj\|ours-empty@in-typespec\|under:operation`; `struct\|ours-only:fewer-copies\|constant\|under:cont_assign` ... | cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, law unitRefSubst) < cloneUnitParamRhs (UhdmExporter.cpp, |
| 8 | N0063 + N0073 + N0118 + N0286 + N0413 + N0790 + N0800 + N0864 + N0868 + N0873 + N0893 + N0897 + N0905 + N0907 + N0908 + N0917 + N0923 + N0936 + N0951 + N0964 + N1125 + N1179 + N1780 + N1815 | 2 | 48 | 25 | BlackBePipeInt/d BlackBePipeInt/t | `fullname\|ref_typespec\|ours-empty\|under:operation`; `span\|constant\|endcol\|under:operation`; `span\|constant\|line+col+endline+endcol\|under:operation`; `struct\|ours-only:fewer-copies\|ref_obj\|under:int_typespec` ... | emitExpr (ExprEmit.cpp, law caTernaryArmPatternFlatten99) < emitExpr (ExprEmit.cpp, law patCaGenIdxValueRender112) < emitExpr (ExprEmit.cpp, law conca |
| 9 | N0012 + N0017 + N0034 + N0043 + N0054 + N0067 + N0068 + N0075 + N0097 + N0100 + N0117 + N0120 + N0158 + N0177 + N0180 + N0184 + N0188 + N0189 + N0197 + N0198 + N0203 + N0207 + N0213 + N0222 + N0225 + N0227 + N0230 + N0232 + N0234 + N0235... | 2 | 50 | 26 | BuildUVMPkg/d BuildUVMPkg/t | `file\|enum_typespec\|ours-empty\|under:ref_typespec`; `span\|constant\|endline+endcol\|under:sys_func_call`; `span\|enum_typespec\|ours-zero\|under:ref_typespec`; `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` ... | buildEnumTs (TypeEmit.cpp, law pkgTdCloneRefNoBind18) < makeTypespec (TypeEmit.cpp, law classVarInitSpan152) < makeTypespec (TypeEmit.cpp, law tpForma |
| 10 | N0008 + N0050 + N0098 + N0121 + N0151 + N0248 + N0262 + N0288 + N0290 + N0297 + N0303 + N0304 + N0305 + N0306 + N0314 + N0318 + N0321 + N0325 + N0326 + N0337 + N0342 + N0352 + N0374 + N0375 + N0387 + N0390 + N0392 + N0397 + N0399 + N0408... | 2 | 52 | 27 | SimpleUVM/d SimpleUVM/t | `fullname\|ref_typespec\|golden-empty\|under:constant`; `span\|operation\|col+endcol\|under:assignment`; `file\|ref_obj\|ours-empty\|under:hier_path`; `file\|enum_typespec\|other-file+span\|under:ref_typespec` ... | emitParameters (ParamEmit.cpp, law timeLitParamIntTs) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsPerView79) < exportDesign (UhdmExporter.c |
| 11 | N0123 + N0164 + N0447 + N0459 + N1424 | 1 | 53 | 28 | Scoreboard/d | `file\|int_typespec\|other-file+span\|under:ref_typespec`; `fullname\|ref_typespec\|tok:id::id::id::id::->\|under:bit_typespec`; `file\|param_assign\|golden-empty\|under:class_typespec`; `fullname\|ref_typespec\|tok:id::id::id::->\|under... | makeParamTs (ParamEmit.cpp, law tpAnonAggParamTsNoStamp47) < operator() (ParamEmit.cpp, law pkgUntypedYNoStamp60) < emitParameters (ParamEmit.cpp, law |
| 12 | N0089 + N0141 + N0142 + N0145 + N0273 + N0451 + N0523 + N0681 + N0683 + N0690 + N0696 + N0697 + N0699 + N0727 + N0772 + N0775 + N0863 + N0883 + N0903 + N0914 + N0961 + N1169 + N1170 + N1172 + N1177 + N1183 + N1195 + N1249 + N1276 + N1338... | 1 | 54 | 29 | Rggen/d | `fullname\|ref_obj\|tok:id.id->id\|under:operation`; `file\|logic_typespec\|other-file+span\|under:ref_typespec`; `struct\|golden-only:fewer-copies\|range\|under:array_typespec`; `name\|indexed_part_select\|ours-empty\|under:hier_path` ... | emitExpr (ExprEmit.cpp, law staticScopedLvalueBad48) < emitExpr (ExprEmit.cpp, law memberActualLeak) < emitContAssigns (ModuleEmit.cpp, law elabCaTern |
| 13 | N0005 + N0018 + N0077 + N0129 + N0182 + N0415 + N0417 + N0446 + N0449 + N0474 + N0525 + N0687 + N0742 + N0746 + N0747 + N0807 + N0812 + N0815 + N0829 + N0834 + N0835 + N0846 + N0915 + N0924 + N0928 + N0941 + N0945 + N0956 + N0976 + N0978... | 1 | 55 | 29 | Earlgrey_0_1/t | `span\|constant\|endcol\|under:param_assign`; `fullname\|ref_obj\|ours-empty\|under:hier_path`; `fullname\|ref_obj\|tok:id.id[id].->\|under:bit_select`; `fullname\|ref_typespec\|tok:->.id\|under:constant` ... | emitExpr (ExprEmit.cpp, law srlgTimeLitVal) < emitParameters (ParamEmit.cpp, law foldSigned9) < emitPackage (ParamEmit.cpp, law caPkgListingNetTypeIsP |
| 14 | N0454 + N0545 + N0546 + N1173 + N1181 + N1184 + N1194 + N1302 + N1381 + N1529 + N1539 + N1753 | 1 | 56 | 30 | Earlgrey_0_1/d | `fullname\|ref_typespec\|tok:id@id.id.id.id.->\|under:typespec_member`; `file\|enum_const\|ours-empty\|under:ref_obj`; `span\|enum_const\|ours-zero\|under:ref_obj`; `struct\|ours-only:fewer-copies\|hier_path\|under:cont_assign` ... | buildStructTs (TypeEmit.cpp, law structMemberWrittenQueueArrayTs149) < makeTypespec (TypeEmit.cpp, law memberAnonUnionAtKeyword134) < emitParameters ( |
| 15 | N0024 + N0134 + N0215 + N0278 + N0289 + N0340 + N0341 + N0343 + N0414 + N0420 + N0428 + N0452 + N0461 + N0478 + N0479 + N0480 + N0481 + N0485 + N0490 + N0492 + N0495 + N0496 + N0503 + N0504 + N0505 + N0507 + N0510 + N0511 + N0512 + N0513... | 2 | 58 | 31 | SeqDriver/d SeqDriver/t | `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec`; `struct\|golden-only:fewer-copies\|array_typespec\|under:ref_typespec`; `fullname\|ref_obj\|tok:id::->\|under:operation`; `fullname\|ref_obj\|tok:id.id[id].id::->\|... | emitInterfaceInstance (ModuleEmit.cpp, law defNetEndOnlyLoc130) < emitInstance (ModuleEmit.cpp, law caNestedModDeclNoRefNoInst99) < exportDesign (Uhdm |
| 16 | N0370 + N0384 + N0424 + N0509 + N0703 + N0991 + N1035 + N1131 + N1154 + N1158 | 2 | 60 | 32 | MiniAmiq/d MiniAmiq/t | `span\|sys_func_call\|endcol\|under:func_call`; `span\|method_func_call\|col+endcol\|under:hier_path`; `span\|sys_func_call\|endcol\|under:assignment`; `fullname\|ref_typespec\|tok:id@id.id::id.id.->\|under:bit_typespec` ... | emitExpr (ExprEmit.cpp, law sysCallKwTypeArgNameSpan131) < emitExpr (ExprEmit.cpp, law emptyArgSlotIntZero24) < emitStmt (StmtEmit.cpp, law recvNamesS |

In short:

* **Expression/parameter ground (the next pair-A refill, after r11u195).**
  1. **The joint rows' A halves**, smallest first: struct_param_func_config (N0045, N0675, N2412: the ParamEmit
     `leftRefFix174` names of a struct parameter's function-computed members; with 4 B clusters), cfg_func_width_loop
     (N0754, N0794; with 5 B), Scr1SvTests (N0741, N0779, N0836, N1069, N1119; with 12 B).
  2. **The heads the pairs leave**: Earlgrey_0_1's N0941 (`reg2hw.key[i].q` bit_select full name
     `work@aes_core.key_init_get.reg2hw.key[i].q.key` where golden stores `reg2hw.key[i]`: ExprEmit `emitMixedHierPath`
     near law hpMidSelIdxDecompiled79), Rggen's N0145 (an `indexed_part_select` inside `bit_field_if.read_data[0+:4]`
     named in golden, empty in ours: ExprEmit `emitExpr` near law everyPartSelIsConstSel78), BuildUVMPkg's N0189 (a
     constant argument of `m_matches_type_override` located at another call: ExprEmit near law namedTfArgsFormalSlots4).
  3. **The UVM ground-A families the pairs leave** (each 9 row-modes, none alone): N0097 (a with-clause / method
     hier_path end, the UVM shape pass 187 did not take), N0012 + N0034 (class-scoped enum copies, the UVM shape of pass
     184's law), N0207, N0054, N0197, N0222 / N0225 (index operation pretty-print names), N0227, N0234, N0235, N0237,
     N0238, N0247, N0252, N0253, N2400, N2401 (F5 names through paths).
  4. **BlackBePipeInt's head** N0923 stays an identity family (r11u191 R2: needs per-use copies); 20 A and 5 B
     clusters behind it.
* **Module/type ground (the next pair-B refill, r11u196, after r11u193).**
  1. **r11u191's law_typeemit.patch** (measured here: const_cast_signext d/t, BuildUVMPkg's first record, the UVM value
     coin, five downstream cases to IDENTICAL).
  2. **N0056's UVM / int_types face** (the signing keyword kept out of a function return's and a macro-argument
     type's span, law suSigningNotInSpan130's rule): the first OPEN record of 7 UVM row-modes; with int_types' other
     six (N0852, N0912, N1137, N1147, N1150, N1155: task/function local variable spans and a `ref_obj` name, TaskFuncEmit
     `emitTaskFuncs` near law ownNamedAliasRetIsRefVar177) it clears **int_types d/t** (a ground-B-only row).
  3. **SVSwitch d/t** (ground B only, 7 clusters: N0526, N0954, N0958, N1010, N1011, N1019, N1020: interface
     instance and interface-array member full names `id->id@id.id`, ModuleEmit `emitInterfaceInstance`).
  4. **The joint rows' B halves**: cfg_func_width_loop (N0025, N0033, N0133, N0263, N0487: the function-local
     parameter range operation and the kept call), struct_param_func_config (N0028, N0552, N0761, N0817: member
     reference full names in the parameter's struct copies, TypeEmit `buildStructTs`), Scr1SvTests (12, first N1139).
  5. **LogicTypespec's four** (N0083 + N0422 + N0484 + N1149) stay a user decision; **PreprocTest** (N0056's `.vh`
     face) is not implementable on this ground.
  6. **The UVM ground-B families the pairs leave** (each 9 row-modes): N0067 / N0068 (a function return's
     class_typespec file and span, now pinned at ModuleEmit `drainFuncRet`), N0180, N0158, N0177, N0184, N0188, N0423,
     N0117, N0120, N0213, N0230, N0232, N0254, N0255, N0256.

## 10. Prediction audit of map 10 ([evidence/audit.txt](evidence/audit.txt); `drivers/audit11.py` reads the committed baselines at every landing)

**Since map 10 (84 row-modes at 2b97649e), 24 row-modes converted**: pass 184 6, 186 4, 187 6, 188 4, 192 4 (the
verifications, map 10 and the decode 0). **All 24 were predicted by map 10** (tally `predicted / converted` 24, `not
predicted / converted` 0).

| map 10 predicted | row-modes | converted | by | still open |
|---|---|---|---|---|
| r11u183 (measured) + pairs r11u184 / r11u186 (optimistic) | 26 | **18** | 184 6, 186 4, 187 6, 192 2 (iface_zero_width_field d/t) | 8: FuncStructValSimple d/t, InterfArrayBind d, PreprocTest d/t, StructParamPatternInitCast d/t, HierPathTypespec t |
| section-9 ground-A list (2 steps) | 4 | **2** | 192 2 (ibex_icache d/t) | anon_struct_packed_dim d/t |
| section-9 ground-B list (8 steps) | 18 | **4** | 188 4 (AssertDelayError / AssertTempError, step 4) | 14: InterfaceModPort, ibex_pmp, rsp_gen_minimal, arb_idx_cast, const_cast_signext, OutputSize..., LogicTypespec (d/t each) |
| section-9 joint list (15 steps) | 32 | **6** | 188 4 (step 6), 192 2 (step 3) | 26 |
| **any of them** | **58** | **24 (41%)** | | 34 |
| not predicted | | **0** | | 26 open, never predicted: the UVM / Earlgrey / Rggen / Scr1 / BlackBePipeInt / SVSwitch rows and ClassTypeParam d/t, cfg_func_width_loop d/t, int_types d/t, struct_param_func_config d/t |

**Probe cases.** Map 10 predicted 220 cases (137 r11u183 measured + 83 pair-optimistic). Of the 260 cases that
converted since, **157 were predicted** (137 of the r11u183 cases, landed by passes 186 and 187, and 20 of pair A's
optimistic ones) and **103 were not**: pass 188's 98 (N0151 55 and N0039 40 cases, the keyword-default class type
parameters of law classTpKeywordTsAtDefault188, which map 10 counted as an OPEN UVM ground-B family, plus N0100, N0132,
N0686 one each), and 5 more (N1948 2 and N2063 1 via pass 187's trailing-select laws, N0187 via pass 186, N0073 via
pass 192). 63 predicted cases did not convert (47 of pair A
r11u184's optimistic 67, 10 of pair B's, 6 needing both).

**Why 34 predicted row-modes did not convert.**
* **r11u183 + pairs (8 open):** FuncStructValSimple d/t: pass 184 (pair A) found its first record was the sister's
  typedef relocation (N0080, since cleared) and left the INT:N leftovers (pass 184 R1, pass 192 R6: not reached);
  InterfArrayBind d: needs the ModuleEmit half (pass 181 S4, pass 192 R7); PreprocTest d/t: not implementable (pass
  186 R5); StructParamPatternInitCast d/t: decoded (pass 192 R3), not landed; HierPathTypespec t: naming
  context-dependent, never attempted.
* **The ground-B list (14 open):** pass 186 landed the r11u183 decode and its own laws, pass 188 took step 4 (Assert*)
  and decoded steps 1-3 and 5-6 as residues (InterfaceModPort needs the harness flag, ibex_pmp's import-parameter copy
  plus a sister face, rsp_gen_minimal not decoded, arb_idx_cast's two halves, const_cast_signext's call-keeping rule,
  which r11u191 then decoded and drafted); LogicTypespec is a user decision.
* **The joint list (26 open):** only the single-cluster ground-A step (N0129, ibex_icache) and the Assert triple
  landed; every other step needs both grounds in the same landing, and the pairs work one ground each.

**The recount of map 10's section-9 items and pair routes at 4a65840e** ([evidence/audit.txt](evidence/audit.txt) F):

| item | clusters | rows 2b97649e -> 4a65840e | target row at 4a65840e | converted by |
|---|---|---|---|---|
| A1 | N0129 | 4 -> 2 | ibex_icache CMP_EQUAL | pass 192 |
| A2 | N0820 | 2 -> 2 | anon_struct_packed_dim NE | - |
| A3a-d | N0016 N0011; N0085 N0738; N0891 N0980 N1096 N1946; N0563 N0763 N0957 N0971 N0979 | unchanged | UnitElabBlock, func_typename_ret, FuncStructVal, ibex_tracer NE | - |
| A4 | the UVM heads N0228 N0224 N0215 N0229 N0217 N0071 N0175 N0109 N0110 N0185 N0193 | 9 -> 9 each | UVM NE | - (r11u191's law idxCallPathAtDots191 / formalDefaultNamedThroughFormal191 clear N0228, N0224, N0229 and N0215 on 5 rows: measured here, unlanded) |
| A5 | N1082; N0923 | 2 -> 2; 2 -> 2 | Earlgrey_0_1, BlackBePipeInt NE | - |
| B1 | N0040; N0219; N0023 | 9 -> 9; 9 -> 9; 2 -> 2 | InterfaceModPort, ibex_pmp, rsp_gen_minimal NE | - |
| B2a | N0431 N0627 N1047 | 6, 4, 2 -> 0 | AssertDelayError / AssertTempError CMP_EQUAL | pass 188 |
| B2b-d | N0090 N0448; N0133 N0487; N0853 N1127 | unchanged | arb_idx_cast, const_cast_signext, OutputSize NE | - (const_cast_signext converts under r11u191's law_typeemit, measured here) |
| B3 | LogicTypespec's four | N0083 6 -> 2, the rest unchanged | LogicTypespec NE | - (user decision) |
| B4 | the UVM ground-B families N0072 N0103 N0039 N0051 N0031 N0042 N0132 N0161 N0170 N0171 N0757 | N0132 9 -> 0 (pass 188), N0031 / N0042 15 / 13 -> 9 (-> 0 under r11u191), N0039 156 -> 45 cases (pass 188); the rest unchanged | UVM NE | - |
| pair A routes | N0086 N0087 N0131; N0427; N0688; N0545 N0546; N0012 N0034 N0638 N0281 | N0688 2 -> 0, N0545 / N0546 4 -> 1, N0638 / N0281 -> 0, N0012 / N0034 13 -> 9; the others unchanged | FuncStructValSimple NE, InterfArrayBind d NE, iface_zero_width_field / ibex_multdiv_fast / TypeParameter* CMP_EQUAL | passes 192, 184 |
| pair B routes | N0056; N1174; N0003 N0014 | unchanged | PreprocTest, HierPathTypespec t, StructParamPatternInitCast NE | - |

**Map 9's and map 8's predictions recounted at 4a65840e.** Map 10 found 14 of map 9's 68 predicted row-modes converted
by 2b97649e; by 4a65840e **34 of 68 (50%)**. Map 8's 110 predicted row-modes: 62 by 2b97649e, **80 by 4a65840e (73%)**.
So a prediction keeps converting for several landings after its map: map 8's rate went 45% -> 56% -> 73% over three
maps, map 9's 21% -> 50% over two.

**Site pins** (map 10's pin of each converted row's first open cluster, against the files of the landing laws, read
from src by the section sign):

| landing | pin's mint file = a law's file | a law's file is a caller in the pin | pin misses |
|---|---|---|---|
| pass 184 (A) | 2 (ibex_multdiv_fast d/t: ExprEmit) | 4 (TypeParameter* d/t: TypeEmit `buildEnumTs` pin N0012, law tpEnumCopyAtTypedef184 in ParamEmit) | 0 |
| pass 186 (B) | 0 | 4 (ParameterFromPkg* d/t: ExprEmit pin N0536, laws in ModuleEmit) | 0 |
| pass 187 (A) | 4 (ArrayMethodIterator d/t: ExprEmit; jeras_union d/t: ParamEmit) | 2 (ApbSlave d/t: TypeEmit pin N0289, laws in ModuleEmit + ParamEmit + UhdmExporter) | 0 |
| pass 188 (B) | 4 (Assert* d/t: ModuleEmit) | 0 | 0 |
| pass 192 (A) | 2 (ibex_icache d/t: ExprEmit) | 2 (iface_zero_width_field d/t: TypeEmit pin N0688, law in ParamEmit) | 0 |
| **all 24** | **12** | **12** | **0** |

What it says: **the pin names a fix file in 24 of 24 (100%), 12 at the mint** (map 10 for map 9: 12 of 14, 86%; map 9
for map 8: 42 of 53, 79%). The caller hits are again decisions made upstream of the mint in another file (the enum copy
minted in TypeEmit, located by ParamEmit's type-parameter emission; the elaborated fold built by ModuleEmit around an
ExprEmit mint). Map 8's rule stands: read the first caller outside the mint's file, and check for a post-pass that
re-parents or reorders.

**Clusters.** Map 10's covered set (66 clusters): 23 gone, 2 lost every row (N0299, N0549), 7 fell (N0012 / N0034
13 -> 9, N0061 11 -> 2, N0415 / N0474 4 -> 2, N0545 / N0546 4 -> 1), 34 unchanged (the pair routes passes 184 and 186
did not take: N0001, N0003, N0007, N0014, N0056, N0067, N0068, N0086, N0087, N0097, N0131, N0144, N0160, N0178, N0179,
N0327, N0416, N0427, N0443, N0682, N0684, N0943, N0965 ...). Map 10's section-9 lists (36 clusters): 3 gone (the Assert
triple), 1 fell (N0129 4 -> 2), 32 unchanged. 12 clusters map 10 routed nowhere lost rows (N0132, N0168, N0209 9 -> 0,
pass 188's class type-parameter laws; N0686, N0847, N1056, N1068, N1070 2 -> 0; N0123 9 -> 7, N0018 4 -> 2, N0928 3 ->
2, N0164 5 -> 4).

## 11. The family view

| family | row-modes / tests | clusters per row at 4a65840e | after r11u191 (measured) | open per row after r11u191 + both pairs | distinct clusters: 4a65840e -> r11u191 -> + pairs | cleared |
|---|---|---|---|---|---|---|
| UVM (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard d, BuildUVMPkg) | 9 / 5 | 97-234 | 89-227 | 64-197 | 287 -> 276 -> 244 | 0 |
| Earlgrey_0_1 | 2 / 1 | 69-73 | 69-73 | 59-62 | 83 -> 83 -> 72 | 0 |
| Rggen (default only) | 1 / 1 | 43 | 43 | 38 | 43 -> 43 -> 38 | 0 |
| BlackBePipeInt | 2 / 1 | 25-27 | 25-27 | 23-25 | 27 -> 27 -> 25 | 0 |
| Scr1SvTests | 2 / 1 | 22 | 21 | 17 | 22 -> 21 -> 17 | 0 |
| SVSwitch | 2 / 1 | 9 | 9 | 7 | 9 -> 9 -> 7 | 0 |
| ibex (pmp, tracer) | 4 / 2 | 2-6 | 2-6 | 0 | 8 -> 8 -> 0 | 4 (pairs A+B, optimistic) |
| jeras, ApbSlave | 0 | - | - | - | - | converted by pass 187 |

Per ibex test at 4a65840e: ibex_tracer 6 clusters, ibex_pmp 2 (ibex_icache and ibex_multdiv_fast converted). The heads
after everything: UVM N0056 (B, 7 rows) / N0189 (A, BuildUVMPkg); Earlgrey N0941 (A); Rggen N0145 (A); BlackBePipeInt
N0923 (A); Scr1SvTests N1139 (B); SVSwitch N1011 (B).

**The near rows.** At 4a65840e, 6 row-modes in 4 tests are single-cluster: InterfArrayBind d N0427, InterfaceModPort
d/t N0040, PreprocTest d/t N0056, HierPathTypespec t N1174. After r11u191 and both pairs only PreprocTest d/t (N0056,
not implementable) has one open cluster, LogicTypespec d/t four (a user decision); every other remaining row has six or
more. **The near rows are exhausted: what remains is the big families plus five mid-size rows (int_types,
SVSwitch, cfg_func_width_loop, struct_param_func_config, Scr1SvTests; 6-17 open clusters each).**

**The UVM family: r11u175's census by family key** (its `uvmcensus.py` + `uvmfamilies.py` over map 8's cluster keys,
the five UVM rows' default databases; [evidence/uvm/](evidence/uvm/)):

| family | 2b97649e (map 10) | 2b97649e + r11u183 patches (map 10) | **4a65840e** | **4a65840e + r11u191 patches** |
|---|---|---|---|---|
| F2 object multiplicity | 23,489 | 11,866 | **12,666** | **11,862** |
| F5 reference full names | 12,372 | 9,373 | **10,153** | **9,544** |
| F6 file facets | 3,914 | 3,118 | **2,627** | **2,467** |
| F7 expression spans outside the pp model | 1,487 | 1,483 | **1,399** | **1,182** |
| F4 formal / typespec / bound spans | 2,912 | 2,403 | **1,059** | **1,050** |
| F1 preprocessor location model | 720 | 720 | **720** | **720** |
| F8 names | 485 | 565 | **565** | **565** |
| F9 value / order / depth | 292 | 292 | **292** | **283** |
| F3 typedef relocation spans | 139 | 139 | **139** | **139** |
| **all** | 45,810 (295 clusters) | 29,959 (288) | **29,620 (286)** | **27,812 (275)** |

Since map 10's base, passes 186 and 187 landed r11u183's patches (F2 23,489 -> ~11,870, F5 -> ~10,200) and pass 188
took F4 2,403 -> 1,059 (the keyword-default class type parameters). **Scoreboard's F2 at 4a65840e carries 796 objects
of the svunit order coin** (N1211 / N1212 / N1438 / N1439, section 0): without the draw F2 reads ~11,870, and r11u191's
own F2 effect is -8, as r11u191 measured. Under the r11u191 patches F5 falls 609, F7 217, F6 160, F9 9 (r11u191 at
a1c89c1a: 687, 217, 160, 9). After the patches the largest UVM families are still F2 (11,862: the importer clones'
struct-keyed and property-array loop variables N0408 / N0134, the import-parameter copies N0151 / N0262 / N0182) and F5
(9,544).

**Order-blind uhdm-dump distance to golden** (records ours-not-golden + golden-not-ours, depth dropped, multiset;
`drivers/uvmdist.sh`, [evidence/uvm/uvm_orderblind_distance.txt](evidence/uvm/uvm_orderblind_distance.txt)):

| row-mode | 2b97649e (map 10) | 2b97649e + r11u183 (map 10) | **4a65840e** | **4a65840e + r11u191** |
|---|---|---|---|---|
| MiniAmiq d / t | 26,585 | 16,799 | **16,071** | **15,835** (-236) |
| SeqDriver d / t | 19,521 / 19,523 | 13,189 | **12,461** | **12,191** (-270) |
| SimpleUVM d / t | 6,964 | 5,780 | **5,070** | **4,876** (-194) |
| Scoreboard d | 5,616 | 4,587 | **3,877** | **3,721** (-156) |
| BuildUVMPkg d / t | 3,293 | 2,819 | **2,071** | **1,963** (-108) |
| ApbSlave d / t | 12 | 0 | **0** (converted) | 0 |
| SVSwitch d / t | 106 | 102 | **102** | **102** |

Passes 184-192 moved the UVM rows another 29-40% toward golden since map 10's base (MiniAmiq -40%, SeqDriver -36%,
SimpleUVM -27%, Scoreboard -31%, BuildUVMPkg -37%) without converting one; the r11u191 patches take exactly r11u191's
measured deltas (-236, -270, -194, -156, -108). The UVM rows still carry 89-227 clusters each after the patches and
64-197 after both pairs.

## 12. Files

* **cluster_index.csv**: one row per cluster (956), with rows / probe at 4a65840e, after r11u191 (`rows_after_law`),
  after both pairs (`rows_after_pairs`), `alone_on_top_of_pairs`, `first_in_after_pairs` (first OPEN record),
  `alone_on_pristine`, coverage, ground, site, map 10's rows and coverage (`map10_*`), families, probe laws, key, example.
* **clusters.csv**: row-mode x cluster with a `first` flag; **probe_clusters.csv** the same per probe case.
* **fail_list.csv**: every STRICT_NOTEQUAL row-mode (60) with its first cluster, that cluster's coverage / ground /
  site, cluster counts, family, downstream verdict, the strict cell after r11u191, the first OPEN cluster after the
  pairs, the open clusters left and `clears`. **probe_fail_list.csv**: the same for the 932 probe cases.
* **evidence/**:
  * `clusters/`: record dumps, one example per cluster with a row or >= 3 probe cases (588); `objects.csv`: one
    example object for every cluster (956);
  * `report.txt` (drivers/report11.py), `audit.txt` (drivers/audit11.py), `final11.txt`, `pristine_index.csv`,
    `greedy11.json`;
  * `routes.json` (the live pairs' items), `ground_override.json`, `sites.json`, `pinwant.txt`, `pins/`;
  * `law191_both_on_4a65840e.patch`: the measured r11u191 binary's source (4a65840e + both patches), NOT applied;
    `law_exprstmt_on_4a65840e.patch` / `law_typeemit_on_4a65840e.patch`: the same split per ground (lawA / lawB), the
    first being the rebase pair A r11u195 needs at 4a65840e (the lhsGuard194 conflict resolved);
  * `controls/`; `determinism/`; `uvm/` (families and ranks at 4a65840e and under law191, the order-blind distance);
  * `sweeps/`: `sweep_law191.txt`, `byteverify_law191_vs_head.txt`, `movers.txt`, `census/` (the prediction),
    `canaries.txt`, `attribution_lawA/`, `attribution_lawB/`;
  * `downstream/`: `dsfaces_P.csv`, `dsfaces_L.csv`, `n1_elabuhdm_crash.txt`.
* **drivers/**: `run11.sh` (the pipeline as run), `env.sh`, `common.py` (key rewrite + the fence), `jobs.py`,
  `probejobs.py`, `probelaw.py`, `strict_runs.sh`, `run1.sh`, `cc.sh`, `strictcmp_x.cpp`, `objrank.cpp`, `analyze.py`,
  `final11.py`, `pinmulti.py`, `sites.py`, `mksites11.py`, `crosssection.sh`, `report11.py`, `audit11.py`,
  `tables11.py`, `evid.py`, `census.sh` + `censum.py` (r11u191's firing census), `bvmirror.sh`, `attribution.sh`,
  `dsfaces.py`, `uvmcensus9.sh` (+ r11u175's `uvmcensus.py`, `uvmfamilies.py`), `uvmdist.sh`, `det.sh` + `ob.sh` (the
  determinism control).
