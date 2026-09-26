# r11u171: the module/type ground, pair B (refill after pass 168): r11u172's TypeEmit laws landed, seven laws of its own

Base `f34d9d7c` (branch matrix-1.87). Files of the ground touched: `src/TypeEmit.cpp`, `src/ModuleEmit.cpp`,
`src/UhdmExporter.cpp`. `src/TaskFuncEmit.cpp` and `uhdm_main.cpp` needed nothing. No line of the sister's files
(`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`) and nothing under `results/`,
`tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated (`python3 scripts/law_index.py`).

Switches: r11u172's three TypeEmit laws keep their delivered switches (`R11U172_VALUE_OFF`, `R11U172_FILE_OFF`,
`R11U172_SPAN_OFF`; `R11U172_OFF` drops them). Every law of this pass reads its own `R11U171_<LAW>_OFF` through
`r11u171Law` (UhdmExporter.cpp, beside `r11u168Law`), and `R11U171_OFF=1` drops all of them. With
`R11U171_OFF=1 R11U172_OFF=1` every one of the 69 cases here and the 52 r11u172 cases gives the pristine bytes
(section 5). `R11U171_TRACE=1` prints one `R11U171 <LAW> <detail>` line per firing branch (the attribution below).

The slang-fenced tests are written `FENCED=` here and never spelled. Every driver that reads corpus sources or
databases (`drivers/predict171.py`, `drivers/bvmirror.sh`, `drivers/attrib.sh`, `drivers/uvmdist.sh`,
`drivers/boundary.sh`, `drivers/case.sh`, `drivers/rowrec.sh`, `drivers/dscase.py`) fails closed on `$FENCED` and
skips a fenced test by word boundary; the byte comparison ran on hard-link mirrors that leave the 8 fenced row-mode
databases out (`fenced_skipped=8`). No fenced test was run, read or decoded outside the gate sweeps, which dispatch
every row themselves; gdb ran on this pass's own case `evidence/residue/T/t01_row_shape` (`dut.sv.txt`) only.

## 1. Binaries (frozen `chmod 555` before any measurement, `/tmp/r11u171_bin/`)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `348259b71247518263d3efe929e5e3aa` | worktree build of f34d9d7c (system deps, `-j 2`) = the main tree's `build/slang-uhdm` |
| `l172.bin` | `54a8c126db3b17431af85dd15449f236` | + r11u172 `law_typeemit.patch` alone (section 3a) |
| `d1`..`d8` | (development builds, one law each) | |
| `law.bin` | `b01c9b9f16be1e3050aeb5a12a35deae` | + the first six laws of this pass; the law sweep `swL` |
| `final.bin` | `02fbc6be01e329311b6744489ab40197` | **the final build of the patch** (+ § genElseIfGateTermPath171, the traces); the final sweep `swF` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs): `/tmp/r11u171_swP` (pristine),
`/tmp/r11u171_swL` (law.bin), `/tmp/r11u171_swF` (final.bin). In `swF` all 3273 `slang:` lines of the corpus
`cmds.txt` files read `/tmp/r11u171_bin/final.bin` (in `swP` all read `pris.bin`). Every sweep exits 1 for one reason
only, `law index STALE: tests/LAWS.md`, which the main tree reads at f34d9d7c too (`scripts/law_index.py --check`,
rc 1); the patch carries the regenerated `tests/LAWS.md`. Logs: `evidence/sweeps/sweep_sw{P,L,F}.log`.

## 2. Verdict per targeted row (fresh csv rows of `/tmp/r11u171_swF`; results/ untouched)

**7 corpus row-modes STRICT_NOTEQUAL -> CMP_EQUAL, 0 regressions, loudly:**

    GenerateUnnamed,default,CMP_EQUAL,,,equal       § genElseIfGateTermPath171                          (was differ:fullname(9))
    GenerateUnnamed,testflags,CMP_EQUAL,,,equal     (same)                                              (was differ:fullname(9))
    UnionCast,default,CMP_EQUAL,,,equal             § boundLitWrittenDigits172 + § castUnionCloneFile171 (was differ:value(26))
    UnionCast,testflags,CMP_EQUAL,,,equal           (same)                                              (was differ:value(28))
    YosysBigSimEllip,default,CMP_EQUAL,,,equal      § selLhsBareDecRhsShared171 + § udpFormConcatSwallowSpans171 (was differ:type(1))
    YosysOldOr,default,CMP_EQUAL,,,equal            § splitPortTsKeyOnPortDecl171                       (was differ:line(1))
    YosysOldOr,testflags,CMP_EQUAL,,,equal          (same)                                              (was differ:line(1))

**13 probe cases STRICT_NOTEQUAL -> EQUAL** (all § sysSignNameSpanSyntax172, exactly the 13 r11u172 measured):
`r10earl_repro/qf22`, `r11u17repro/grid/{c07_lhsmod_sysfunc_genlocal, c08_multdiv_shape, c24_multdiv_onesigned,
c25_unsignedlhs_signedop, c26_child_multdiv_modlhs, c27_child_multdiv_genlocallhs}`, `r11u25repro/grid/q15_ctl_mul`,
`r11v17repro/grid/{w03_syscall_concatarg_op, w04_syscall_barearg_op, w07_syscall_addop_arg_op,
w08_syscall_castinop_arg, w09_syscall_castinconcat_arg}`.

Downstream rows of the touched uhdm2rtlil tests (unchanged, and the whole `downstream.csv` of `swF` is byte-identical
to the pristine sweep's, pass 120's eight rows included): `rp32_r5p_alu,IDENTICAL,OK,OK,1332,1332,,`
`rp32_r5p_bru,IDENTICAL,OK,OK,174,174,,` `rp32_r5p_mdu,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`rp32_r5p_wbu,IDENTICAL,OK,OK,320,320,,` `jeras_union,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`ibex_multdiv_fast,IDENTICAL,OK,OK,3906,3906,,`.

**Improved, still STRICT_NOTEQUAL** (compare_results CHANGE lines, every one attributed in section 4):

| row (modes) | base | final | law(s) | the first record now |
|---|---|---|---|---|
| rp32_r5p_{alu,bru,mdu,wbu} d/t (u2r) | file(46) | type(1) | § tdMoveCarriesFile172 + § boundLitWrittenDigits172 (+ § sysSignNameSpanSyntax172 on alu) | the DEPTH face, sister: `riscv_isa_i_pkg.sv 144:27` golden `constant INT:31`, ours `operation` (`32-1` kept): § pkgFnCastTopListing172 (r11u172's `law_exprEmit.patch`), the ExprEmit named-typedef cast branch. With it r11u172 measured the 8 conversions |
| jeras_union d/t (u2r) | fullname(54) | fullname(36) | VALUE172 + § castUnionCloneFile171 | the range constants without a file (`riscv_isa_pkg.sv 132:23`, 28 file facets) behind the DEPTH face |
| ibex_multdiv_fast d/t (u2r) | endcol(26) | file(11) | SPAN172 | 11 enum_const loc-less (sister, residue 2) |
| Scr1SvTests d/t | file(143) | type(1) | § tsMemberRootFile171 (141 members) + § defNetEndOutputCol171 (the `q_data` typespec 173:52) | #16033 `indexed_part_select din` golden carries a ref_typespec (the called function formal's `logic [1:0]` 90:13), ours none: the walk diverged there in the pristine walk too (pristine `fields: type=1 ... file=142 ... (walk diverged)`, the same record #16033); sister, residue 3 |
| MiniAmiq d/t, SeqDriver d/t | file(46) | file(29) | § tsMemberRootFile171 | #573 `uvm_pkg::uvm_check_e` golden `uvm_reg_block.svh 1671:35` (a class-method formal's relocation), ours the declaration `uvm_reg_model.svh 180:4` (residue 5) |
| SimpleUVM d/t, Scoreboard d | fullname(62) | fullname(45) | § tsMemberRootFile171 | #458 ref_typespec golden `UVM_MACRO_NUMFLAGS`, ours `uvm_pkg::UVM_MACRO_NUMFLAGS` (reference full names) |
| Earlgrey_0_1 d/t | fullname(511) | fullname(436) | § tdMoveCarriesFile172 + § sysSignNameSpanSyntax172 (r11u172 measured 1686 -> 1611 on its base) | #25840 `ref_typespec <in>ibex_pkg::csr_op_e` full names (the identity family) |

Every changed row keeps its judge status (uhdm-cmp 0 lines: each is judge-equal in both sweeps, stage 1 of the strict
comparator being uhdm-cmp's own Compare). Scr1SvTests is the only row whose count went from a large number to 1 on a
different first field: the pristine walk already diverged at #16033 (quoted above), the laws removed the 142 facets
before it.

**Rows of the brief not converted** (current strict column at f34d9d7c checked first): HighLow d/t, GenForStructParamBound
d/t and ibex_register_file_ff d/t are already CMP_EQUAL at the base (passes 164/168 converted them: nothing remains).
The rest are in section 7.

## 3. The laws

### 3a. r11u172's decode, landed (tools/probe/r11u172rp/README.md has the decode)

`law_typeemit.patch` applies on f34d9d7c without a conflict (`git apply --check`, rc 0; pass 168's `mkBound` edits
touch no hunk of it). § tdMoveCarriesFile172 lands in the delivered **TypeEmit design-final form** (the block at the end
of `pkgImportCloneLastWriter32`): the one-line alternative at the movers sits at ParamEmit's emitPackage last-writer
loop (the sister's file) and at UhdmExporter's `pendingPkgTsStretch` end write; the TypeEmit form covers both movers
and needs no sister line. On the r11u172 grid (`tools/probe/r11u172rp/cases/{F,S,V}`, 42 cases) the landed form gives
exactly r11u172's law verdicts, case by case (`evidence/r11u172grid_verdicts.txt`); the D axis needs the sister's
§ pkgFnCastTopListing172 and reads pristine verdicts, as expected. Switch matrix: every F / S / V mover is restored by
its own axis switch alone (`evidence/switches_r11u172grid.txt`); F/f06 (the include-file typedef, r11u172's R3) moves
under both § tdMoveCarriesFile172 and § tsMemberRootFile171 and is now **STRICT_EQUAL** (pristine file(27), r11u172 alone
file(18)).

| law | switch | site | rule (r11u172's decode) |
|---|---|---|---|
| § tdMoveCarriesFile172 | `R11U172_FILE_OFF` | TypeEmit.cpp `pkgImportCloneLastWriter32` (design-final) | a typedef object Surelog MOVES to a use site (subroutine formal, a net's unpacked-dimension end) takes that site's file (populateCoreMembers writes vpiFile on every call) |
| § boundLitWrittenDigits172 | `R11U172_VALUE_OFF` | TypeEmit.cpp `makeBoundConst` | a bound written as an unsized decimal keeps its written digits (`[11:00]` -> `UINT:00`) |
| § sysSignNameSpanSyntax172 | `R11U172_SPAN_OFF` | TypeEmit.cpp `emitSyntaxExpr` | `$signed` / `$unsigned` take the name-token span in every syntax-view position |

### 3b. The laws of this pass

| law | switch | site | statement (decode) |
|---|---|---|---|
| § castUnionCloneFile171 | `R11U171_CASTUNIONFILE_OFF` | TypeEmit.cpp `pkgImportCloneLastWriter32` (design-final, beside the r11u172 block) | Map N0430. The fresh union clone a cast to a package union typedef binds (`op32_t'(ins)`, ExprEmit's `castUnionClone` branch) copied the listing object's span and left the FILE empty; Surelog re-elaborates the cast target through compileTypespec on the typedef, whose populateCoreMembers writes the file with the span. The file is the listing object's when the spans agree, else the typedef declaration's. (The one-line alternative, `ucl->VpiFile(cts->VpiFile())` beside the span copy, is ExprEmit's.) |
| § tsMemberRootFile171 | `R11U171_MEMBERROOTFILE_OFF` | TypeEmit.cpp `buildStructTs` / `buildUnionTs` member mint (helper `memberRootFile171`) | Map N0210, r11u172's R3. A struct/union `typespec_member` is filed at the ROOT source file of the compilation: Surelog's `CompileHelper::buildTypespecMember` (DesignCompile/CompileType.cpp) is handed `fC->getFileId()` (the FileContent's own file, one per file named on the command line) beside `fC->Line(node)` (the line in the included file), and `VpiRefFile(fC->getFileId())` likewise; every other object reaches populateCoreMembers, which reads the node's own file. Scr1SvTests' members declared in `scr1_hdu.svh` read `scr1_pipe_hdu.sv 76:41` in golden. A macro token climbs from its expansion point, the root is the top of the include chain. |
| § splitPortTsKeyOnPortDecl171 | `R11U171_SPLITPORTKEY_OFF` | TypeEmit.cpp `sharedTypespec` (the cache key) | Map N0661. A SPLIT (Verilog-95) port whose variable the body re-declares (`output opa_dn; output opb_dn;` then `reg opa_dn, opb_dn;`) takes its typespec from its PORT declaration (makeTypespec's mergedPort branch), so the objects are shared by port declaration: keyed on the body's `reg`, every later port of `reg a, b;` reused the first port's object and its location (golden or1200_fpu_intfloat_conv_except `opb_dn` 51:12, ours 50:12). Ports of one port declaration (`output x, y;`) still share. |
| § selLhsBareDecRhsShared171 | `R11U171_SELDECSHARE_OFF` | ModuleEmit.cpp `emitContAssigns`, the def-constant reuse block (beside § selBareDec144) | YosysBigSimEllip's structural head. A bare decimal onto a bit-select or part-select Lhs keeps the DEFINITION's constant object in every elaborated cell: UhdmWriter::writeCont_assign (UhdmWriter.cpp, the `reduceExpr` branch) clones the cont_assign (clone_tree: `constant::DeepClone` hands back `this` for a sized constant), runs `adjustSize(tps, ...)` with `tps = lhs->Typespec()`, which a select Lhs does not carry (no uniquifying clone), then `res->VpiParent(assign)`, `assign->Rhs(res)`: one object, re-parented at the last cell (the walk visits it once). A whole-net Lhs has a typespec and clones (`C = 0` stays fresh); a sized or based literal already shared (the existing rule). Pinned with an object-identity census (`drivers/carhs.cpp`) on grid Y. |
| § udpFormConcatSwallowSpans171 | `R11U171_UDPSWALLOW_OFF` | ModuleEmit.cpp `emitInstance`, the HighConn emission (the UDP-form swallow built before the connection naming) | YosysBigSimEllip's head after the previous law. The UDP-form swallow (a fully positional instantiation whose FIRST actual is a concatenation: port[0]'s HighConn is a concat holding that concat and the remaining actuals) is one expression compiled under the port, so it is built before the naming and binding: the swallowed actuals are named `<parent>.<instance>.<formal>.<name>` and bound like every reference inside an operation actual (§ connLeftmostLeafElab139), where the late wrap left them parent-named and unbound; the inner concatenation spans its FIRST element, and a bit-select element spans the whole select (golden f3m.v:725 `f3_add a142 ({w13[0], w13[1]}, w135, w141)`: inner concat 725:32-38, `w13[0]` 32-38, `w13[1]` 40-46, `w135` `...a142.A.w135`). |
| § defNetEndOutputCol171 (+ its paste guard) | `R11U171_NETENDCOL_OFF` (`R11U171_NETENDPASTE_OFF` drops the guard) | ModuleEmit.cpp `materializeDefNetTs`, the def-view net typespec end stretches | Scr1SvTests' next face. The end stretches (to the first unpacked dimension, or the first packed dimension of a multi-dimension packed net) are PREPROCESSOR OUTPUT coordinates like every location (the r11u166 model, § ppOutputCol166): writeNets' populateCoreMembers reads the end node's column in the preprocessed text. The stretches wrote the raw column (`logic [`SCR1_IMEM_DWIDTH/2-1:0] q_data [N];` ends 173:52 in golden, 173:67 in ours); the end now goes through setLoc's end query. The model does not align a token PASTE (r11u166's listed limit): a declaration any of whose tokens comes from a macro whose body pastes keeps the raw column (case K/k07, where the raw column is golden's). |
| § genElseIfGateTermPath171 | `R11U171_GENELSEIF_OFF` | ModuleEmit.cpp `emitGates` (the elaborated terminal scope) | GenerateUnnamed (pass 164's residue 2). A gate terminal's reference inside a generate block is named by the generate path Surelog's elaboration built, where the UNNAMED body of an `else if` stands for two levels (the else branch's own conditional and its block, both `genblkN`); the generate scope tree flattens them as ours does; only the terminal names keep the path: golden `work@test1.genblk1.genblk1.u1.a` (ours `work@test1.u1.a`). The innermost block keeps the producer's number our scope naming already computes (GenerateUnnamed's `if (1)` block is `genblk1` there, slang's LRM name `genblk2`); a named else-if body, a plain `else` body, a first branch and loop generates are untouched. |

## 4. Gates (final binary, sweep `/tmp/r11u171_swF`, against the committed baselines)

| gate | pristine `swP` | final `swF` |
|---|---|---|
| (1) build | `pris.bin` = main tree md5 `348259b7` | `final.bin` `02fbc6be` |
| (2) probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2697, STRICT_NOTEQUAL 1390) | **regressions 0**, conversions 13, changes 5 (EQUAL 2710, STRICT_NOTEQUAL 1377) |
| (3) surelog vs golden_surelog.csv | 0 / 0 / 0 | **regressions 0**, conversions 7, changes 11 |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | **regressions 0**, conversions 0, changes 12 |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | 803 / 66 / 2 / 0, not excused 0; `downstream.csv` byte-identical to the pristine sweep's |

Judge-equal scoreboards unchanged: surelog 480/3 + 474/3 (CMP_EQUAL+STRICT_NOTEQUAL 450+30 default, 446+28 testflags),
uhdm2rtlil 803/1 both modes. (5) uhdm-cmp: no row moves between judge-equal and anything else in either corpus; every
converted and changed row is judge-equal before and after (0 uhdm-cmp lines); the probe stage has no NOT_EQUAL case.

Probe changes (5, all § sysSignNameSpanSyntax172, each one sys_func_call endcol facet fewer, the next face showing, as
r11u172 measured): `r10earl59repro/v59v2_earl59` endcol(4) -> fullname(3), `r10earl98repro/g3_rhs98` endcol(5) ->
line(4), `r11v46repro/grid7` endcol(2) -> fullname(1), `v11u115repro/grid/f1/a01_gf_signed` endcol(3) -> fullname(2),
`a20_gf_unsigned_W` endcol(3) -> fullname(2).

**(6) Byte movers, corpora** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fence-clean mirrors
`/tmp/r11u171_mF` / `mP`: 2560 databases each, 8 fenced skipped; PATH_SETS_IDENTICAL; SELFCHECK 2559 / 2560 flagged):
**42 movers**. Attribution (`drivers/attrib.sh`: each mover re-exported with the pristine binary twice (determinism),
the final binary with `R11U171_TRACE=1`, with `R11U171_OFF=1 R11U172_OFF=1`, and with every single switch;
`evidence/sweeps/attrib_*.txt`):

| mover (row-modes) | law(s) (the switch that restores the pristine bytes, or moves them) |
|---|---|
| GenerateUnnamed d/t | GENELSEIF (restores) |
| UnionCast d/t | VALUE172 + CASTUNIONFILE |
| YosysBigSimEllip d | SELDECSHARE + UDPSWALLOW |
| YosysOldOr d/t | SPLITPORTKEY + SELDECSHARE |
| ImplicitPorts2 d/t (CMP_EQUAL both) | SPLITPORTKEY (restores): `output q, q_bar; reg q;` now shares the port declaration's object (identity only) |
| YosysOldUsb d/t (CMP_EQUAL both) | SPLITPORTKEY (restores; identity only) |
| IndexAssign d/t (CMP_EQUAL both) | SELDECSHARE (restores; identity only: `sig[I-7] = 3` shares the definition constant) |
| mem2reg_test4 d/t, mem2reg_test5 d/t (u2r, CMP_EQUAL both; downstream IDENTICAL both) | SELDECSHARE (restores; identity only) |
| Scr1SvTests d/t | MEMBERROOTFILE + NETENDCOL |
| rp32_r5p_{bru,mdu,wbu} d/t | VALUE172 + FILE172; alu adds SPAN172 |
| jeras_union d/t | VALUE172 + CASTUNIONFILE |
| ibex_multdiv_fast d/t | SPAN172 (restores) |
| Earlgrey_0_1 d/t | FILE172 + SPAN172 (byte-deterministic; `alloff` reproduces the pristine bytes) |
| BuildUVMPkg d/t (strict line(94) unchanged) | MEMBERROOTFILE (restores) |
| SimpleUVM d/t, Scoreboard d, MiniAmiq d/t, SeqDriver d/t | MEMBERROOTFILE (SimpleUVM d/t and SeqDriver/d restore it alone; the other switches that "move" these rows move the order coin); the rest carry the known UVM `UINT`/`vpiDecompile` order coin (two pristine runs differ): order-blind, the only record differences between the pristine and the final database are `typespec_member` records differing in the FILE column alone (MiniAmiq 1035, SeqDriver 1155, Scoreboard 666) plus the one coin constant (`evidence/sweeps/uvm_coin_orderblind.txt`) |

**Prediction** (`drivers/predict171.py` over the PRISTINE sweep's databases with `drivers/cen171.cpp`, a trigger census
per law, fail-closed on `$FENCED`; `evidence/prediction/`). `pred_P.tsv` (the first nine laws) was written before the
law sweep `swL` (20:42, the sweep started 20:49), `pred_F.tsv` (+ the GENELSEIF trigger) before the final sweep
(21:08, the sweep started 21:08:45). It predicts a superset (1757 row/case keys, FILE172's relocated-span trigger being
the broad one). **41 of the 42 corpus movers are predicted by name; the miss is ImplicitPorts2 (both modes as
SPLITPORTKEY)**: the SPT trigger asked for a typespec object two ports SHARE in the pristine database, while the law
also merges objects the pristine database kept apart (a port declaration listing a re-declared and a plain port);
ImplicitPorts2/default was predicted, but under FILE172, not its law. Said here as it happened; not widened post hoc.
The probe: 18 byte movers of 4087, all SPAN172 (the 13 conversions and 5 changes above), all predicted (SGN trigger).

**UVM order-blind distance and file facets** (`drivers/uvmdist.sh`, strict records as multisets, ours-not-in-golden;
`evidence/sweeps/uvm_file_facets.txt`): MiniAmiq d/t 16872 -> 15847, SeqDriver d/t 15771 -> 14629, SimpleUVM d/t
10672 -> 9810, Scoreboard d 9306 -> 8649; file facets away (type, name, file) 4867 -> 3832, 5190 -> 4035,
3714 -> 2841, 3001 -> 2335; the method_func_call file facets stay at 15 (pass 168's figure). The distance never rises.

**Canaries** (`evidence/sweeps/canaries.txt`): `r11u107repro/canaries.sh` surelog ok=41 changed=11 (exactly the
attributed CONVERSION/CHANGE rows: Scr1SvTests, Earlgrey_0_1, YosysOldOr, SimpleUVM, SeqDriver d/t, Scoreboard/d),
uhdm2rtlil ok=16 changed=0 (pristine control: ok=52 / ok=16, changed 0); `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` ok=58
changed=0 PASS, uhdm2rtlil `EXPECT_UNKNOWN=6` ok=2 changed=0 PASS.

**Boundary and landed-law byte controls** (`drivers/boundary.sh`: every `tools/probe/**/dut.sv` and
`tests/probe/**/dut.sv` outside this pass, both binaries, `dut.sv --single-unit --nobuiltin`, children on
`</dev/null`, fenced paths refused; this covers every case of the landed-law grids the brief names: r11u118..r11u168,
their verifiers, r11u166mac, r11u172rp): **listed 12687, processed 12687: 12497 SAME, 98 MOVER, 92 NODB** (no database
from either binary: the same 3 segfaults and the same rejections on both). Every mover judged against its pinned-Surelog
golden with both binaries (`drivers/judge.sh`, `evidence/boundary_movers.txt`): 34 converted to STRICT_EQUAL, 24 equal on
both (identity moves: the SELDECSHARE sharing, r11u172's DEPTH-free identity moves), 7 strict-NE on both with fewer
differing objects (the first field moved on), 2 strict-NE with the same count and first field, 31 judge-NE on both with
the same uhdm-cmp line count; for the 33 judge-NE / same-count cases the order-blind dump distance to golden goes down
on 13 and stays on 20 (`evidence/boundary_obdist.txt`). **No case moves away from golden.** No case of passes
118/119/120/124/125/130/131/152/155/160/164/168 moves except toward golden (their movers are all in the table).

## 5. The grid (`cases/`, 69 cases, first line `// § <law>`; `drivers/case.sh`: goldens from the pinned Surelog with
check_probe's arguments, cached by the md5 of every file of the case; a `files` list names several root files)

Pristine strict-equal **24 -> 57 of 69** (`evidence/grid.txt`). `R11U171_OFF=1 R11U172_OFF=1` gives the pristine bytes
on **69 of 69** (and on the 52 r11u172 cases), and each switch alone restores exactly its own dir's movers
(`evidence/switches.txt`). No case pristine read strict-equal reads otherwise; no case's uhdm-cmp line count grows.

| dir | law | cases | converted (pristine -> final) | controls / residue |
|---|---|---|---|---|
| U | castUnionCloneFile171 | 3 | u01 (pkg union cast), u03 (the union in an included header; with § tsMemberRootFile171) | u02 (two instances: stage 1 on both, same cmp text) |
| M | tsMemberRootFile171 | 14 | m01 (pkg struct in a header), m02 (module struct), m03 (nested include), m06 (two root files), m08 (class struct), m09 (a header macro in the member), m11 (inactive `ifdef` branch picks the header) | m04, m05, m14 (macro bodies expanded in the root file: equal on both), m07 (same-file control); m10 (a pasted member name: file right now, the paste end face left, the r11u166 limit), m12 (multi-line macro argument: stage 1 on both), m13 (a header opening with two `define lines: golden's lines one lower, the location model's include face) |
| N | splitPortTsKeyOnPortDecl171 | 5 | n02 (`reg x, y;` re-declaring two one-name output declarations), n04 (three) | n01 (no body re-declaration), n03 (one body declaration per port), n05 (`output x, y;` + `reg x, y;`) |
| Y | selLhsBareDecRhsShared171 | 12 | y01 (two instances), y02 (nested), y12 (three instances, part- and bit-select) | y03 (one instance: identity-only mover), y04 (whole-net Lhs clones), y05 (sized), y06 (`'0`), y07 (operation), y08 (parameter), y09 (hex whole net), y11 (net declaration assignment); y10 (generate scope: stage 1 on both) |
| Q | udpFormConcatSwallowSpans171 | 10 | q01 (the YosysBigSimEllip shape), q02 (nested instance), q03 (whole references), q04 (part-select element), q08 (select actuals), q10 (two instances) | q05 (a parameter override: no swallow), q06 (named), q07 (concat not first); q09 (an operation actual: stage 1 on both, same cmp text, downstream EQUIVALENT on both) |
| K | defNetEndOutputCol171 | 13 | k01 (the Scr1SvTests shape), k02 (multi-dim packed), k03 (macro in the unpacked dim), k05 (elaborated instance), k06 (implicit 2-D net), k09 (multi-line macro argument), k11 (the whole declaration from a macro), k13 (a call inside a macro argument) | k04 (no macro), k10 (inactive branch); k07 (a pasted dimension: the guard keeps the pristine bytes, the model's paste limit), k08 (nested calls: stage 1 on both), k12 (a stringified neighbour: its own `string_typespec` endcol face on both) |
| G | genElseIfGateTermPath171 | 12 | g01 (unnamed else-if body), g04 (nested unnamed and named blocks), g05 (three-way chain), g08 (inside a named block), g12 (the GenerateUnnamed shape) | g02 (named body), g03 (first branch), g06 (plain else), g11 (else after a named else-if); g07 and g09 stage 1 on both (a module instance in the body; a second generate construct: slang's genblk numbering), g10 (selected terminals: the select's own col face on both, one full-name facet fewer) |

The location-model shapes the brief requires for a file or location change (pasted tokens, stringified formals, nested
calls, multi-line arguments, inactive branches, calls inside macro arguments) are K/k07, k12, k08, k09, k10, k13 and
M/m10, m12, m05, m11: no case moves away; the paste face is guarded (K/k07 was a break the first cut made: the model
read 4:35 where the raw column is golden's 4:28; fixed behind `R11U171_NETENDPASTE_OFF`).

Downstream through the harness's own `one()` (`drivers/dscase.py`, fresh `GOLDEN_CACHE`, `evidence/downstream/`):
pristine -> final on every case of the grid: 67 IDENTICAL -> IDENTICAL, Q/q09 EQUIVALENT on both (same differs),
M/m06 SLANG_REJECT on both (a two-file case run as `dut.sv` alone). No case leaves IDENTICAL.

## 6. Development notes (breaks found before the final sweep)

* § defNetEndOutputCol171's first cut routed every stretched end through the model; K/k07 (a pasted dimension) moved
  from golden's raw column to the model's 4:35: the paste guard was added (above).
* A law for TypeParameterAsPortTypeWithEnum (the type-parameter enum copy's location, in TypeEmit's makeTypespec enum
  branch) was written first and never fired: gdb on `evidence/residue/T/t01_row_shape` pins the mint to ParamEmit
  `emitParameters` (`buildEnumTs < emitParameters < emitInstance`); the code was removed (residue 4).
* § genElseIfGateTermPath171's first cut used slang's external names for the whole chain: GenerateUnnamed's `if (1)`
  block is `genblk2` in slang, `genblk1` in Surelog and in our scope tree; the innermost name now comes from the scope.

## 7. Residues, ranked (decoded, not landed)

1. **rp32_r5p_{alu,bru,mdu,wbu} d/t (8 row-modes), type(1)**: the DEPTH face, § pkgFnCastTopListing172 on the sister's
   ground (ExprEmit, the named-typedef cast branch `cts = typedefTs[expr.type]`; r11u172's `law_exprEmit.patch`). With
   it and this patch r11u172 measured all 8 conversions.
2. **ibex_multdiv_fast d/t file(11)** (sister): the enum constants of a typedef declared INSIDE the generate block
   (`gen_mult_fast`'s `mult_fsm_e`) are bound loc-less by ExprEmit's NamedValue branch (the lateBinding mint beside
   § genCaEnumBindsSelectOnly22 / § uninstIfaceEnumConstNoActual221); golden binds the located shared constant (the
   generate scope's own typedef is found before the `getValue` mint). Case `evidence/residue/E/e01_genblk_enum_case`.
3. **Scr1SvTests d/t type(1)** (sister): a call argument `din[(i+1)*2-1-:2]` carries the called function formal's
   typespec in golden (the formal binding while compiling the call: compileTfCallArgs), ExprEmit/StmtEmit.
4. **TypeParameterAsPortTypeWithEnum d/t, ...OfParametrizedWidth d/t (4 u2r row-modes)** (sister): the enum copy the
   type parameter hands the port variable (`enum_var state_i`) is minted by ParamEmit `emitParameters` (gdb) with no
   location or file; golden locates it at the typedef (`dut.sv 9:3-11:16`), and names the base range's reference
   through the enum (`<in>state_e.StateWidth`). Cases `evidence/residue/T`.
5. **MiniAmiq, SeqDriver (file(29)), SimpleUVM, Scoreboard (fullname(45))**: first ten records at the final binary:
   MiniAmiq/SeqDriver 6 enum_typespec + 1 struct_typespec relocations to class-method formals (`uvm_check_e` golden
   `uvm_reg_block.svh 1671:35`, ours the declaration: § tfArgTypedefLastWriter146 declines every method of a class inside
   a package, measured on the UVM verbosity enums; the reg-model methods move in golden: this ground, UhdmExporter, the
   next law), then the include face; SimpleUVM/Scoreboard: 9 ref_typespec full names `UVM_MACRO_NUMFLAGS` (golden) vs
   `uvm_pkg::UVM_MACRO_NUMFLAGS` (reference full names), 1 enum relocation. At the base the first ten were 3
   typespec_member file facets (now § tsMemberRootFile171) and 7 relocations (MiniAmiq/SeqDriver). The file rows'
   first differing record is the typedef move of § tdMoveCarriesFile172's family (a relocation ours does not perform,
   so the file law has nothing to write), not the include face of § ppOutputFile166 nor the macro-argument face of
   § ppFileCallArgBody168.
6. **ibex_pmp d/t file(16)** (this ground): a PACKAGE-QUALIFIED module-function formal (`ibex_pkg::pmp_cfg_t`)
   relocates the elaborated package's object to the QUALIFIER span (golden `ibex_pmp.sv 114:47-114:57`, `ibex_pkg::`):
   § tfArgTypedefLastWriter146's documented unmodelled branch (its grid fa/f11).
7. **Earlgrey_0_1 d/t fullname(436)**: the first ten are ref_typespec full names inside package enum listings
   (`<in>ibex_pkg::csr_op_e`: the typespec identity family), 1 struct_typespec file.
8. **UnsizedParam d fullname(2)**: UhdmWriter::writeCont_assign's `lhs ref_obj` branch (bindVariable answers the implicit
   net, the right side is an operation) CLONES the cont_assign per instance (`u_sub_default`'s `a` named
   `work@top.u_sub_default.a`); for `u_sub_5` the reduce of `int'(Y)` with Y = '1 at 5 bits leaves a cast with no
   operand. ModuleEmit `emitContAssigns` (the elaborated view shares the definition's object): not reached.
9. **OneNetModPort d/t file(3), OneNetModPortGeneric d/t line(2)**: the program's interface port low connection is
   unlocated in golden's definition view (ours `tb.v 1:34`), and the elaborated one sits at the program header
   (`1:31`, ours the instantiation `18:17`); then the modport io_decl walk divergence (pass 164's residue 1).
10. Report only: **LogicTypespec** d/t endline(3) unchanged (pass 160's Surelog-defect candidate); **PreprocTest** d/t
    endcol(2) unchanged (the language-mode face: the harness gives `-sv` to Surelog only); **HierPathTypespec** t
    fullname(1) (`pkg::pkg::b::pkg::a::x`, naming context-dependent); **ClassTypeParam** d/t unchanged (N0072);
    **cfg_func_width_loop**, **const_cast_signext**, **mem_read_reg** unchanged (the evaluator-stamp and identity-copy
    families, ParamEmit halves); the location model's paste and define-line faces (K/k07, M/m10, M/m13).

## 8. Files

* `cases/{U,M,N,Y,Q,K,G}/`: 69 law cases (first line `// § <law>`; `M/m06` carries a `files` list).
* `drivers/`: `env.sh` (pins, `$FENCED` from RESUME.md, fail closed), `case.sh`, `grid.sh`, `switches.sh`,
  `rowrec.sh` (a sweep row's strict records), `carhs.cpp` (cont_assign Lhs/Rhs identity census), `cen171.cpp` +
  `predict171.py` (the mover predictor), `bvmirror.sh` (fence-clean mirrors), `attrib.sh` (mover attribution),
  `obrec.sh` (order-blind record differences), `uvmdist.sh`, `boundary.sh`, `judge.sh`, `obdist.sh`, `dscase.py`.
* `evidence/`: `grid.txt`, `switches.txt`, `switches_r11u172grid.txt`, `r11u172grid_verdicts.txt`, `rows/` (first
  records per targeted row, base and final), `prediction/`, `sweeps/` (sweep logs, byteverify, attributions, canaries,
  UVM facets and coin), `boundary_movers.txt`, `boundary_obdist.txt`, `downstream/`, `residue/` (the sister-ground repros
  E and T, stored as `dut.sv.txt` so the law index does not read them as cases of this pass's laws; rename to run).

## 9. On the moved main tree

The main tree moved to `31739f79` (pass 169 on the expression ground and r11u173's verification of passes 164 and 167)
while this pass ran; every gate above is measured against the f34d9d7c baselines, as the brief requires. On `31739f79`
every file of this patch applies clean (`git apply --cached --check --exclude=tests/LAWS.md` against a scratch index)
except the generated `tests/LAWS.md`, which must be regenerated there (`python3 scripts/law_index.py`). Pass 169 did not
land § pkgFnCastTopListing172 (the rp32 DEPTH face, residue 1). The integrated tree still needs its own sweep.
