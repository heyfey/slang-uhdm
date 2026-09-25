# r11u168: the module/type ground, pair B (refill after pass 164): the r11u166 preprocessor location model landed with its FILE move fixed, and six laws of its own

Base `35ed4056` (branch matrix-1.87). Files of the ground touched: `src/UhdmExporter.cpp`, `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp`; plus, for `law_litall.patch` ONLY and exactly as delivered (the brief's (1c) exception), the
compaction sites it names in `src/EmitHelpers.h`, `src/ExprEmit.cpp` and `src/StmtEmit.cpp`. No other line of the
sister files is edited. `uhdm_main.cpp` and `src/TaskFuncEmit.cpp` needed nothing.

Switches: every r11u166 law keeps its delivered `R11U166_*` switch (`R11U166_OFF=1` drops them all); every law of this
pass reads its own `R11U168_<LAW>_OFF` through `r11u168Law` (UhdmExporter.cpp, beside `r11u164Law`), and
`R11U168_OFF=1` drops all of them. With `R11U166_OFF=1 R11U168_OFF=1` every one of the 63 cases here and the 69
r11u166 cases give the pristine bytes (section 5).

The slang-fenced tests are written `FENCED=` here and never spelled. Every driver that reads corpus sources or
databases (`drivers/predict168.py`, `drivers/bvmirror.sh`, `drivers/uvmdist.sh`, `drivers/attrib.py`,
`drivers/orderblind.sh`) fails closed on `$FENCED` and skips a fenced test by word boundary; byte comparisons ran on
hard-link mirrors that leave out the 8 fenced row-mode databases. No fenced test was run, read or decoded outside the
gate sweeps, which dispatch every row themselves.

## 1. Binaries (frozen `chmod 555` before any measurement, `/tmp/r11u168_bin/`)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `c44c82a6e8ea26acdcb20e08215f67f4` | worktree build of 35ed4056 (system deps, `-j 2`) = the main tree's `build/slang-uhdm` |
| `dec0.bin` | `c05f46239af7987074fe26420a2c372a` | + r11u166 `law_on_d48f8f8a8.patch` + `law_macroconn.patch` + `law_litall.patch` as delivered |
| `dec1.bin` | `58f7ff37b67515d1377bc2fae45e29ee` | + § ppFileCallArgBody168 (the FILE move fixed); the decode sweep `swD` |
| `dec2`..`dec5`, `dec7` | `68365d0b`, `05050225`, `afca6bd0`, `e1b502e0`, `7157f48d` | development builds (one law each) |
| `dec6.bin` | `4d6510a8f2747ff7a0c2b1f676a54b9c` | + UNDEFXROOT, PSBOUNDTS, HCIDXNAME; the law sweep `swL` |
| `dec8.bin` | `ffa0d8101cf14fc3e6e3aeb88172a6db` | **the final build of the patch**; the final sweep `swF` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs): `/tmp/r11u168_swP` (pristine),
`/tmp/r11u168_swD` (dec1), `/tmp/r11u168_swL` (dec6), `/tmp/r11u168_swF` (dec8). In `swF` all 3273 `slang:` lines of
the corpus `cmds.txt` files read `/tmp/r11u168_bin/dec8.bin` (in `swP` all read `pris.bin`). Every sweep exits 1 for
one reason only, `law index STALE: tests/LAWS.md`, which the main tree reads at 35ed4056 too (`scripts/law_index.py
--check`); the patch carries the regenerated `tests/LAWS.md`. Logs: `evidence/sweeps/sweep_sw{P,D,L,F}.log`.

## 2. Verdict per targeted row (fresh csv rows of `/tmp/r11u168_swF`; results/ untouched)

**10 corpus row-modes STRICT_NOTEQUAL -> CMP_EQUAL, 0 regressions, loudly:**

    GenForStructParamBound,default,CMP_EQUAL,,,equal        § structParamBoundAtPatternLeaf168 + § rangeHierPathNoFullName168   (was differ:fullname(3))
    GenForStructParamBound,testflags,CMP_EQUAL,,,equal      (same)                                                              (was differ:fullname(3))
    StructArrayNet,default,CMP_EQUAL,,,equal                § hcSelIdxInstName168                                               (was differ:fullname(2))
    StructArrayNet,testflags,CMP_EQUAL,,,equal              (same)                                                              (was differ:fullname(2))
    YosysMarlann,default,CMP_EQUAL,,,equal                  § ppBasedLitWsAfter166 (r11u166 law_litall)                         (was differ:endcol(24))
    YosysMarlann,testflags,CMP_EQUAL,,,equal                (same)                                                              (was differ:endcol(24))
    YosysOldOpen,default,CMP_EQUAL,,,equal                  § undefKeepsOtherRootMacro168 + § paramBaseSelTsInstName168         (was differ:line(17))
    YosysOldOpen,testflags,CMP_EQUAL,,,equal                § paramBaseSelTsInstName168                                         (was differ:fullname(4))
    ibex_load_store_unit,default,CMP_EQUAL,,,equal          § ppOutputLine166 (r11u166 law)                                     (was differ:endline(142))
    ibex_load_store_unit,testflags,CMP_EQUAL,,,equal        (same)                                                              (was differ:endline(142))

Downstream row of the converted uhdm2rtlil test: `ibex_load_store_unit,IDENTICAL,OK,OK,736,736,,` (unchanged; the
whole downstream csv of `swF` is identical to the pristine sweep's, row by row, pass 120's eight rows included).

**Improved, still STRICT_NOTEQUAL** (compare_results CHANGE lines, attributed in section 4):

| row (modes) | pristine | final | law | what is left |
|---|---|---|---|---|
| PackedArrayHighConn d/t | fullname(6) | fullname(5) | hcSelIdxInstName168 (the high connection's `DioPadBank` bit_select) | the enum base ref_typespec names in the import copies (ParamEmit, sister) |
| Earlgrey_0_1 d/t | line(1686) | fullname(511) | r11u166 (1686 lines cleared, map 8 measured `fullname(520)`) + hcSelIdxInstName168 (520 -> 511) | full names (pair A clusters) |
| ibex_pmp d/t (u2r) | file(52) | file(16) | r11u166 | the typespec located at its use (identity residue) |
| MiniAmiq d/t, SeqDriver d/t | line(183), line(167) | file(46) | r11u166 | uvm_reg typespec located at its use (`uvm_reg_block.svh 1671:35`) |
| SimpleUVM d/t, Scoreboard d | line(183), line(187) | fullname(62) | r11u166 | hier_path/ref_obj full names (pair A) |
| Scr1SvTests d/t | line(219) | file(143) | r11u166 | typespec_member of an included typedef, golden's root file (TypeEmit) |
| YosysOldOr d/t | line(75) | line(1) | r11u166 | the non-ANSI port typespec line (`opb_dn` 51:12 vs ours 50:12) |
| YosysRiscv d/t | endcol(86) | col(40) | r11u166 (litall) | the index span (pair A, N0036) |
| CovMacro d/t | endcol(118) | fullname(8) | r11u166 | `$root.top` hier_path (pair A, N0977) |
| ApbSlave d/t | line(26) | depth(1) | r11u166 | the pre-existing svunit_pkg walk divergence (#372, in the pristine walk too) |

Every one of these first-field moves is exactly the decode cross-section map 8 measured (tools/probe/r11u165map
section 3a) except the two rows this pass moved further (PackedArrayHighConn, Earlgrey 520 -> 511).

**Rows of the brief not converted** (current strict column at 35ed4056 checked first): ComplexHierPath d/t is already
CMP_EQUAL at the base (pass 164). The rest are in section 8 (decoded, with their sites).

## 3. The laws

### 3a. r11u166's decode, landed (tools/probe/r11u166mac/README.md has the decode)

`law_on_d48f8f8a8.patch`, `law_macroconn.patch` and `law_litall.patch` apply on 35ed4056 without a conflict (passes
163 and 164 touched no hunk of them; `git apply` without `--whitespace=fix`); nothing had to be rebased by hand. Their
switches and § names are as delivered: § ppOutputLine166 (`R11U166_LINE_OFF`), § ppOutputCol166 (`R11U166_COL_OFF`,
`R11U166_ONELINE_OFF`), § ppOutputFile166 (`R11U166_FILE_OFF`), § ppOutputInclLine166 (`R11U166_INCL_OFF`),
§ ppReincludeSplice166 (`R11U166_INCL_REINC_OFF`), § macroConnInRange166 (`R11U166_MACROCONN_OFF`),
§ ppBasedLitWsAfter166 (`R11U166_COL_LIT_OFF`; the 13 emitter compaction sites retired in the same change, landed as
ONE change). The r11u166 grid (69 cases) reads on this base: pristine 21 strict-equal -> 63 with the decode (the same
63 r11u166 measured), identical bytes with dec0 and dec8 on all 69.

### 3b. The laws of this pass

| law | switch | site | statement (decode) |
|---|---|---|---|
| § ppFileCallArgBody168 | `R11U168_PPFILECALL_OFF` | UhdmExporter.cpp `fullFilePath`, the § ppOutputFile166 fallback (a macro token the model did not align) | Map 8's FILE move away from golden. A token the model does not align inside a MULTI-LINE expansion has no known output line, so the invocation's first output line (kBase: the caller's file for UVM's `UVM_PH_TRACE`) is the wrong record; the file stays the pristine rule's. The token that falls there is a method call whose receiver is a formal's text passed on to a nested call (`PH.get_full_name()` in `uvm_info`'s MSG): its start location is not a token at all but `recv.sourceRange.end() + 1` walked as a raw offset off the one-token `this` argument buffer (ExprEmit, section 8 S1), so no location model can align it. Golden files it where the nested body placed it (`uvm_message_defines.svh 116:13`). |
| § undefKeepsOtherRootMacro168 | `R11U168_UNDEFXROOT_OFF` | UhdmExporter.cpp `emitIncludeFileInfos`, the § includeInfoEmptyRedefineLine125 walk | Surelog's `` `undef `` (`PreprocessFile::deleteMacro`, PreprocessFile.cpp) searches only the current ROOT file's include tree (the file, its includes, its includer); a macro an EARLIER root file of the compilation unit defined stays in the compilation unit, so a later bare `` `define `` of it is a redefinition and drops its output line (`exitDefine_directive` records a bare macro only when `getMacro` misses). YosysOldOpen default: the command line lists `openMSP430_defines.v` first; every later file's `` `include "openMSP430_defines.v" `` undefines everything through `openMSP430_undefines.v` and redefines 12 bare switches: every later include_file_info line reads 12 lower. A bare redefinition keeps the definition's root; any other definition is the current root's. `-fileunit` rows (one syntax tree per file) are unaffected. |
| § paramBaseSelTsInstName168 | `R11U168_PSBOUNDTS_OFF` | ModuleEmit.cpp `substNdaParamRefs`, the substituted constant's ref_typespec name | Pass 163's S1 (N0129). A constant substituted for a parameter reference that IS a part-select bound (`v[I+3:I]`'s `I`, openmsp430 `BASE_ADDR[14:DEC_WD]`) keeps the value's own instance-named ref (`work@top.s`) whatever the select's base (a parameter or a net); a reference nested in a bound OPERATION (`per_addr[13:DEC_WD-1]`) and a bit-select index stay named after the selected object. The distinguisher is the slot, not the base kind (grid P: p04's net base `v[I+3:I]` reads the instance name in golden too). |
| § hcSelIdxInstName168 | `R11U168_HCIDXNAME_OFF` | ModuleEmit.cpp: `emitModuleDefPorts`' definition-view HighConn (the bit_select doubling through the child) and `emitInstance`'s elaborated HighConn (the same doubling); helper `hcSelIdxRescope168` | Pass 163's S2 / S5 half (N0525 + N0562, N1115). The references inside a bit_select HighConn's INDEX are named through the child INSTANCE, exactly like the select: a direct index `.a(v[sel])` -> `work@dut.m.sel`, a nested one `.a(v[i+j])` -> `work@dut.m.v.i`, `.pok_i(pad_pok[DioPadBank[0]])` -> `work@dut.u_dio_pad.pad_pok.DioPadBank`, in the definition view (ours: the port's scope `work@dut.m.a.sel`, a name UHDM computes through the port at write time, so the law writes it) and the elaborated view (ours: the parent's `work@dut.sel`), generate scopes included (`work@dut.G[0].m.i`). |
| § structParamBoundAtPatternLeaf168 | `R11U168_SPLEAF_OFF` | TypeEmit.cpp `buildUnpackedRanges` `mkBound`, the ELAB interface array bound fold; helper `structParamLeaf168` | Pass 164's residue 3 (N1058). A range bound that reads a STRUCT PARAMETER FIELD (`logic dly [0:CFG.HSK.DLY]`) folds to the constant Surelog's reduceExpr finds inside the parameter's value pattern: the folded constant is located at the member's own value expression, followed through an override and through a parameter-to-parameter read (`bus_if #(CFG_DEF)` locates it at the package localparam's `'{HSK: '{1, 1'b0}, ...}` `1`, 10:39). A FLAT pattern's leaf carries its member's width (named or positional: `'{W: 3, ...}` with `int unsigned W` reads 32, `logic [7:0] W` reads 8); a pattern holding a nested pattern keeps 64. Only an UNSIZED integer literal leaf (a sized `4'd2` keeps its own literal shape in golden: DEC, size 4; not modelled, the pristine location stays). |
| § rangeHierPathNoFullName168 | `R11U168_RNGHPNAME_OFF` | TypeEmit.cpp `mkBound`, the definition-view array_net bound's hier_path (`dottedNameBound`) | Pass 164's residue 3 (N0094). Golden stores no full name on the hier_path of a definition-view array_net bound `[0:CFG.HSK.DLY]`; UHDM otherwise computes `work@bus_if.dly.CFG.HSK.DLY` through the range at write time: the no-fullname idiom (`VpiFullName(name)`). |

## 4. Gates (final binary `dec8.bin`, sweep `/tmp/r11u168_swF`, against the committed baselines)

| gate | pristine `swP` | final `swF` |
|---|---|---|
| (1) build | `pris.bin` = main tree md5 `c44c82a6` | `dec8.bin` `ffa0d810` |
| (2) probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2647, STRICT_NOTEQUAL 1440) | **regressions 0**, conversions 21, changes 5 (EQUAL 2668, STRICT_NOTEQUAL 1419) |
| (3) surelog vs golden_surelog.csv | 0 / 0 / 0 | **regressions 0**, conversions 8, changes 21 |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | **regressions 0**, conversions 2, changes 2 |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | 803 / 66 / 2 / 0, not excused 0; `downstream.csv` identical to the pristine sweep's, row by row |

(5) uhdm-cmp: every row keeps its judge status (surelog 1596 rows, uhdm2rtlil 1742: 0 rows move between judge-equal
and anything else); every converted and changed row is judge-equal before and after (0 uhdm-cmp lines); the probe stage
has no NOT_EQUAL case.

**Probe conversions (21)**: r11u166's 19 (`r10earl42repro/v42_overfire`, `r10earl43repro/v43_h1_order`,
`r10earl54repro/v10step1`, `r10earl_repro/a`, `mm` by litall; `r10uvm60repro/b7_multiline`, `r11u8repro/{b5,b8,gA,gB}`,
`r11v11u8repro/{v1,v2,v4,v5,v8,v10,v11,v12,v13}` by the location model) and 2 of this pass,
`r10earl81repro/g3_norm81` and `r10v81repro/v6_edge81` (§ hcSelIdxInstName168). Changes (5, all r11u166, all fewer
objects or the next face): `r10uvm104repro/g104_a1_sep` endcol(48) -> (44), `r10uvm160repro/g160_f_witness` line(11)
-> (2), `r10v104repro/v1_pastecount` endcol(8) -> (4), `r10v132repro/v4_home` file(50) -> (48), `r11v11u8repro/v9`
line(6) -> col(6).

**(6) Byte movers, corpora** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fence-clean mirrors
`/tmp/r11u168_mP` / `mF`: 2560 databases each, 8 fenced skipped; PATH_SETS_IDENTICAL; `evidence/sweeps/byteverify_*.txt`):
surelog **30 / 952** (SELFCHECK 951 / 952), uhdm2rtlil **4 / 1608** (SELFCHECK 1607 / 1608). Attribution
(`drivers/attrib.py`, `evidence/sweeps/mover_attribution.txt`: each mover re-run with `R11U168_OFF=1`, with
`R11U166_OFF=1` and with both):

* r11u166 alone: ApbSlave, CovMacro, Scr1SvTests, YosysMarlann, YosysOldOr, YosysRiscv (d/t), Rggen/d, ibex_pmp and
  ibex_load_store_unit (d/t, u2r);
* r11u168 alone: GenForStructParamBound, StructArrayNet, YosysOldOpen, PackedArrayHighConn (d/t);
* both: Earlgrey_0_1 d/t (hcSelIdxInstName168 520 -> 511), and the UVM family MiniAmiq d/t, SeqDriver d/t, SimpleUVM
  d/t, Scoreboard/d (the location model + ppFileCallArgBody168's file facets);
* with both switch sets off every mover returns to the pristine bytes, except the UVM family, which returns
  order-blind: MiniAmiq d/t, SeqDriver d/t, SimpleUVM/t differ from pristine by exactly the known 4-line
  `UINT`/`vpiDecompile` coin, SimpleUVM/d and Scoreboard/d by 0 lines (`evidence/sweeps/uvm_alloff_orderblind.txt`).

**Prediction** (`drivers/predict168.py`, extending r11u166's `predict.py` with this pass's triggers PF, UX, HC, PS, SP;
over the PRISTINE sweep's sources, `` `include `` followed through the incdirs, macros outside the test directory
included; fail-closed on `$FENCED`; `evidence/prediction/`). `pred_*.tsv` was written before the law sweep `swL`,
`pred2_*.tsv` (+ SP) before the final sweep. The files keep only the rows that hold a trigger (a row with none is not a candidate). Result (`predcmp_final.txt`): **32 of the 34 corpus movers predicted by
name; the 2 misses are PackedArrayHighConn d/t**: the HC regex refused a nested bracket in the index
(`pad_pok[DioPadBank[0]]`). Widened after the sweep (`pred3_posthoc_*.tsv`, `predcmp_posthoc.txt`: 34 of 34), and
said here as it happened. The probe: **27 byte movers of 4087, all 27 predicted** by `pred2_probe.tsv`
(`evidence/sweeps/probe_movers.txt`: 21 conversions, 5 changes, and `r10v212repro/gridv_v7_macro_clone_design`, one
byte outside the strict walk, EQUAL before and after, as r11u166 measured).

**UVM file facets** (the brief's (1a) proof, `drivers/uvmdist.sh`, `evidence/sweeps/uvm_file_facets.txt`): order-blind
distance of each database to its golden (strictcmp records as multisets, ours-not-in-golden), and the method_func_call
`(name, file)` facets ours holds more often than golden:

| row | pristine dist / mfc file away | decode as delivered (dec0) | final (dec8) |
|---|---|---|---|
| MiniAmiq d, t | 28599 / 15 | 16872 / **215** | 16872 / **15** |
| SeqDriver d, t | 29455 / 15 | 15772 / **255** | 15771 / **15** |
| SimpleUVM d, t | 20221 / 15 | 10672 / **175** | 10672 / **15** |
| Scoreboard d | 16921 / 15 | 9306 / **135** | 9306 / **15** |

The distance to golden never rises; the 120 to 240 method_func_call file facets the delivered decode moved away
(map 8: 121 to 241) are back at pristine's.

**Canaries** (`evidence/sweeps/canaries.txt`): `r11u107repro/canaries.sh` surelog ok=37 changed=15 (exactly the
attributed CONVERSION/CHANGE rows: Scr1SvTests, Earlgrey_0_1, YosysOldOr, YosysOldOpen, ApbSlave, SimpleUVM, SeqDriver
d/t, Scoreboard/d), uhdm2rtlil ok=16 changed=0 (pristine control: ok=52 / ok=16, changed 0); `ctcan2.sh` surelog
`EXPECT_UNKNOWN=1` ok=58 changed=0 PASS, uhdm2rtlil `EXPECT_UNKNOWN=6` ok=2 changed=0 PASS.

**Landed-law byte controls** (`drivers/controls.sh` over every case of r11u118repro, r11v11u118repro, r11u119repro,
r11u120repro, r11v120repro, r11u124repro, r11v124repro, r11u125repro, r11v125repro, r11u130repro, r11v130repro,
r11u131repro, r11v131repro, r11u152repro, v11u152repro, r11u155repro, v11u155repro, r11u160repro, v11u160repro,
r11u164repro, v11u164repro; `evidence/controls/movers.txt`): **1832 cases, 24 byte movers, every one toward golden**:
19 go STRICT_NOTEQUAL -> STRICT_EQUAL (pass 125's g3 m05 m10 m13 m14 m15, r11v125 mf w04 w05 w11, pass 130's g9
r07, r11v130 adv h09, r11v131 ctp h05, v11u160 MA o09, MM p03 p05 q01 q04 q20 r03, PA c5: the macro-body and
include line faces r11u166 decoded); v11u160 MM q21 endcol(4) -> endcol(2); four stage-1 cases keep their uhdm-cmp
line counts and move toward golden order-blind (r11u119 g3 n_dir_lits and n_nodir_lits 22 -> 6 lines, v11u160 MA o06
49 -> 33, MM q11 80 -> 52). No case moves away. (Two Surelog aborts in the control dirs are the same cases on both
binaries: no golden, no comparison.)

## 5. The grid (`cases/`, 63 cases, first line `// § <law>`; `drivers/case.sh`: goldens from the pinned Surelog with
check_probe's arguments, cached by the md5 of every file of the case; a `dut.v` case runs Surelog without `-sv`, an
`args` case lists several root files of one compilation unit)

Pristine strict-equal **9 -> 38 of 63** (`evidence/grid/switches.txt`). `R11U166_OFF=1 R11U168_OFF=1` gives the
pristine bytes on **63 of 63** (and on the 69 r11u166 cases). No case pristine read strict-equal reads otherwise; no
case's uhdm-cmp line count grows (three stage-1 cases go to 0: R/h01, r11, r12).

| dir | law | cases | converted | controls / residue |
|---|---|---|---|---|
| F | ppFileCallArgBody168 (and r11u166's model) | 9 | f01 f03 f04 f09 (r11u166) | f02 f05 f06 f07 f08: the call through a formal-supplied receiver (`PH.get_full_name()` in a nested call's actual, a pasted name, a stringified formal beside it, an inactive branch before it, a one-line actual): the file is golden's now (the delivered decode wrote the caller's), the span is ExprEmit's (S1) |
| U | undefKeepsOtherRootMacro168 | 10 | u01 u04 u05 u07 u09 (cross-root undef then bare define; a bodied first definition; a double undef; the define in the first root's include; the YosysOldOpen shape through an include) | u02 (same-root undef), u03 (plain redefinition), u06 (the undef in the first root), u08 (a bodied redefinition in the current root, then undef), u10 (a `// c` define keeps its line) |
| P | paramBaseSelTsInstName168 | 8 | p01 (openmsp430), p04 (net and parameter bases, direct bound), p05 (top module), p07 (left bound) | p06 (bit-select index), p08 (explicit `assign`: no substitution); p02 p03 stage 1 on both (a bit / indexed part select of a parameter in a net declaration: another face) |
| H | hcSelIdxInstName168 | 18 | h01 h02 h03 h04 h05 h07 h08 h09 h10 h14 h17 | h12 (index inside an operation of the actual) control; h06 (`sa[sel].x`) and h11 (`v[sel+:2]`) untouched shapes; h15 h16 names right, now at a binding face (golden binds only the LAST index operand's net, and an ordered connection's index); h13 h18 stage 1 on both |
| R | structParamBoundAtPatternLeaf168, rangeHierPathNoFullName168 | 18 | R/h01 (stage 1 -> equal), r01, r05, r11, r12 | h02 control; r03 r04 (the packed bound's fold: another site, still `line`); r07 r13 (nested named pattern: now at the value pattern's constants, ParamEmit); r08 (sized leaf); r09 r10 (instance-override pattern: stage 1 on the param_assign operation); r02 r06 h03-h05 stage 1 on both (module array bounds, net arrays) |

Downstream through the harness's own `one()` (`drivers/dscase.py`, fresh GOLDEN_CACHE, `evidence/downstream/`):
pristine -> final: 60 IDENTICAL -> IDENTICAL, F/f01 EQUIVALENT -> **IDENTICAL**, R/r06 DIVERGENT on both, R/r09
EQUIVALENT on both. No case leaves IDENTICAL.

## 6. Development notes (breaks found before the final sweep)

* § hcSelIdxInstName168's first cut renamed only STORED names: the definition-view index keeps its full name unset
  (UHDM computes it through the port), so the law writes it; a second cut guarded against re-renaming a name already
  under the child scope, which is a prefix of the port scope (`work@dut.m.` of `work@dut.m.a.sel`): the guard was wrong
  and was dropped.
* § structParamBoundAtPatternLeaf168's first cut gave a named member its width everywhere; r07 (nested named) and r13
  (top-level named in a nested pattern) read 64 in golden, r11 (top-level positional in a flat pattern) reads 32: the
  rule is FLAT vs nested pattern, not named vs positional.
* The prediction miss (PackedArrayHighConn, section 4).

## 7. Decodes stopped at the sister ground (the fix sits in a file this pass does not own)

* **S1, the method call through a formal-supplied receiver** (UVM: `UVM_PH_TRACE`'s `PH.get_full_name()` in
  `uvm_info`'s MSG; cases F/f02 f05-f08; 120-240 method_func_call objects per UVM row): ExprEmit.cpp starts the call's
  span at `recv.sourceRange.end() + 1` walked as a raw offset (the `nameSpan(recv.sourceRange.end() + 1, ...)` sites
  under § macroPasteRecvMisreadIsAstChain132 / § macroSplitRecvIsAstChain128), off the end of the one-token `this`
  argument buffer (the location lands at buffer offset 5 of a 4-byte buffer). Golden: the method-name token
  (`uvm_message_defines.svh 116:13-116:26`). Fix: locate the call at its name token (`MemberAccessExpression` /
  the invocation's name syntax), which the location model then maps.
* **N0092 UnionCast**: `UINT:00` vs our `UINT:0` (the literal value text) is ExprEmit's IntegerLiteral (pass 160's
  decode); the rp32 `UINT:00` shape is the same text face.
* **PackedArrayHighConn**'s last 5: the enum base ref_typespec names in the import copies (ParamEmit).
* **StructParamPattern values** reached by R/r07, r13: the nested named value pattern's constants (ParamEmit).

## 8. Residues on this ground, ranked (decoded, not landed)

1. **N0056 PreprocTest d/t endcol(2): a LANGUAGE-MODE face, not a span.** The default-mode Surelog command line holds
   `.vh` files and no `-sv`, so ParseFile.cpp sets `m_lexer->sverilog = false` and the lexer's `BIT: 'bit' { sverilog }?`
   rule does not fire: `bit` is an IDENTIFIER, the enum base is a type identifier plus a packed dimension, and the
   bit_typespec spans the name alone (5:14-5:17) with the range beside it. Reproduced by
   `evidence/decode/E/v01_dut.v.txt` (the same enum in a `.v` file without `-sv`); e01-e07 (`.sv`, or `-sv`) read the
   whole `bit [2:0]` in golden. **Not implementable from our side**: the harness gives `-sv` to Surelog only
   (`scripts/verify_golden.py` `location_args`: "Surelog-only"), so slang-uhdm cannot know a file's parse mode. A law
   needs the harness to pass the mode (out of this ground). v02-v04 (a `.v` file declaring `logic`/`bit` variables)
   are stage 1: the same lexer rule makes every SV-only keyword type an identifier in Verilog mode; no corpus row
   reaches it today.
2. **UnsizedParam d fullname(2) (N0136 + N0457 + N0775)**: two elaborated cont_assign faces in `emitContAssigns`.
   Default mode (no `-elabuhdm`): golden's `u_sub_default` lists its OWN clone of the definition cont_assign
   (`ref_obj a` `work@top.u_sub_default.a` bound to the definition's `logic_net a`, the cast's ref_typespec named by the
   instance, `ref_obj Y` keeping `work@submodule.Y`), ours shares the definition's; and golden's `u_sub_5` (X
   overridden) lists a cont_assign whose cast operation has NO operand (Y's `'1` at a 5-bit type), ours none (249 vs
   244 objects). The testflags row (`-elabuhdm`) is CMP_EQUAL.
3. **GenerateUnnamed d/t fullname(9)** (pass 164's residue 2, unchanged): Surelog's per-scope `genblk` numbering and
   its else-if walk (`DesignElaboration.cpp`, `If-Else stmt`); not reached.
4. **OneNetModPort d/t file(3), OneNetModPortGeneric d/t line(2)** (pass 164's residue 1, repros in
   `tools/probe/r11u164repro/evidence/residue/PP`): not reached.
5. **ClassTypeParam d endline(17) / t file(30) (N0072)**: a typedef of a class specialization
   (`typedef uvm_config_db#(uvm_object, string) m_uvm_config_obj_misc;`): golden's class_typespec spans from the
   typedef to its USE (20:9-24:36, the variable declaration at 24), the type_parameter formals and their param_assigns
   are unlocated, and the actuals' class_typespec spans the `#(...)` list (20:22-20:43). Decoded from the row, not
   gridded.
6. **ibex_register_file_ff d/t fullname(31) (N0078)**: the elaborated gen-scope copy of the port typespec reached
   through a sized constant's ref_typespec (`rf_reg_q <= '0` -> `32'b0` -> `logic [DataWidth-1:0]`) holds a
   `DataWidth` ref with no full name; the definition listing's object names it. The copy's mint (emitSyntaxExpr).
7. **mem_read_reg d/t name(5), const_cast_signext d/t line(5)**: walk divergences in the package struct typespec
   order / a struct typespec located at its cast use (`op_t` 19:42-19:46): the identity-copy family.
8. **rp32 (bru, mdu, wbu, alu) file(46)**: the package struct typespec's file (`riscv_isa_i_pkg.sv` in golden, the
   including file), then the `UINT:00` value text (S1 of section 7).
9. **YosysBigSimEllip d type(1)**: golden holds a `part_select C` where ours holds a folded `constant` (f3m.v 592),
   in the elaborated cont_assign; not decoded further.
10. **LogicTypespec d/t endline(3)** (report only, pass 160's Surelog-defect candidate): unchanged at endline(3); not
    re-decoded.
11. The model limits r11u166 listed (token paste, a key two tokens claim, a define inside a body, line/pragma
    directives in bodies) stand; ApbSlave's svunit walk divergence (depth(1), in the pristine walk too); the typespec
    located at its use (ibex_pmp file(16), SeqDriver/MiniAmiq file(46), Scr1SvTests file(143)): the identity-copy
    residue.

R0 (next): section 7 S1 on the expression ground (the method call's name token), then residue 2 (UnsizedParam's
elaborated cont_assign clone) on this ground.

## 9. Files

* `cases/{F,U,P,H,R}/`: 63 law cases (first line `// § <law>`; `U/` cases carry `args` + several files).
* `evidence/decode/E/`: the N0056 language-mode repros (decode only, `.txt`).
* `drivers/`: `case.sh`, `grid.sh`, `switches.sh` (the switch matrix), `dscase.py` (the downstream harness per
  case), `controls.sh` (landed-law byte controls), `predict168.py` + `predcmp.sh` (the mover predictor and its
  check), `bvmirror.sh` (fence-clean mirrors), `attrib.py` (mover attribution), `orderblind.sh`, `uvmdist.sh`
  (UVM order-blind distance and file facets).
* `evidence/`: `grid/`, `downstream/`, `controls/`, `prediction/`, `sweeps/` (sweep logs, byteverify, attribution,
  canaries, probe movers, UVM facets).

## 10. On the moved main tree

The main tree moved to `45b8e774` (pass 167 on the expression ground and r11u170's verification landed) while this
pass ran; every gate above is measured against the 35ed4056 baselines, as the brief requires. On `45b8e774` every
file of this patch applies clean (`git apply --cached --check` against a scratch index) except the generated
`tests/LAWS.md`, which must be regenerated there (`python3 scripts/law_index.py`). Pass 167 touched
`src/EmitHelpers.h`, `src/ExprEmit.cpp`, `src/ModuleEmit.cpp` and `src/ParamEmit.cpp`; the `law_litall.patch`
compaction sites and this pass's ModuleEmit hunks do not overlap its hunks. The integrated tree still needs its
own sweep.
