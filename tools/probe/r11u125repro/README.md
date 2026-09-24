# r11u125 — the module/type ground on the strict axis: genvar parameters, span copies, macro and include attribution

Pair B implementer pass. Base `7bd06f52` (branch matrix-1.87). Ground: `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp`, `src/UhdmExporter.cpp` (the patch touches no other source file;
`src/TaskFuncEmit.cpp` and `uhdm_main.cpp` needed nothing). Worktree `/tmp/wt_r11u125`, built with
the system-deps config at `-j 2`.

| binary | md5 | what |
|---|---|---|
| pristine | `cb7b39bd1fa880fa84d54d11d9ff8ce2` | base, byte-identical to the main tree's `build/slang-uhdm` |
| law | `9b9884b9c78b4bbb7c19bae450418a11` | this patch (all eight laws) |
| `uhdm-strictcmp` | `88bf7040c706f80686ea981e6a8650c8` | identical to the main tree's |
| census build | `6c2b1d2ded3d8aa91bada3757353f186` | MEASUREMENT ONLY: a marker VpiFile at every census site (drivers/census_mark.py), never landed |

Every binary was frozen (`chmod 555` copies under `/tmp/r11u125_bin/`) before it measured anything;
every sweep exported `SLANG_UHDM` and `STRICT_CMP` to the frozen copies, and every cmds.txt names the
frozen path. Sweeps: pristine `/tmp/r11u125_wdP`, law `/tmp/r11u125_wd8` (same-length names for the
byte verifier), downstream `/tmp/r11u125_dsP` / `/tmp/r11u125_ds8`.

## 1. Verdict per target

| target | before -> after | law |
|---|---|---|
| (1) C0001 genvar gen-scope parameter without VpiFile (example surelog/testflags/BlackBox `core_idx`) | BlackBox `differ:file(1)` -> `equal` both modes; 120 row-modes need this law to turn equal, 116 need nothing else | § genvarParamFile125 |
| (1) C0582 genvar parameter LINE (func_upto golden 63 / ours 64; DoubleLoop golden 9 / ours 10) | func_upto `differ:file(2477)` -> `equal` both modes; DoubleLoop `differ:file(30)` -> `equal` both modes | § genvarParamLoopVarLine125 |
| (1) downstream func_upto | EQUIVALENT -> EQUIVALENT (residue R1: not a field — the plugin's `std::map<RTLIL::Wire*,...>` in `import_initial_interpreted` orders the `sync init` updates by heap address; the slang-lane `_nohier.il` is byte-identical before and after, its sorted diff against golden's is 0 lines, and the strict walk is equal even with `--no-canon`) | — |
| (2) FILE-EMPTY census, my files | every census site that mints an object reaching a judged row has golden = a file (0 golden-empty objects at any site); 17 span-copy sites + 2 cast-drain sites landed; 34 row-modes turn equal on the cast drain, 15 on the span copies | § spanCopyCarriesFile125, § castTsDrainFile125 |
| (3) F10 macro/include buffer attribution | decoded (Surelog's per-LINE records, section 3); YosysOldSpi `differ:line(525)`/`differ:col(523)` -> `differ:fullname(1)` both modes (the remaining object is a hier_path fullname on the sister's ground); ibex_csr `file(16)` -> `line(12)`; YosysOldOr `file(2589)` -> `line(78)`; ApbSlave `line(59)` -> `line(30)` | § macroTokenFileFollowsLine125, § includeFirstLineColShift125, § macroBodyTrailingComment125 |
| (3) C0104 include_file_info line (YosysOldSpi) | decoded and landed: an empty-body REdefinition drops one flattened line; YosysOldSpi's include_file_info records equal in both modes | § includeInfoEmptyRedefineLine125 |
| (4) F04 our private typespec copies | after the canonicalisation the named examples (ExplicitPort, ImplicitPorts2) are already `equal` at the base; no content-differing private copy on this ground heads a row in the first-difference census of the law sweep (section 8) | none |
| (5) builtin package file | nothing to land: at the base the builtin classes read `builtin.sv` on both sides (DefaultPatternInt records 71ff golden = 72ff ours), and no row's first field is a builtin record | none |
| (F02) full name inside a typespec subtree | decoded; the double prefix `pa::pa::st_t` is written by the SISTER's ParamEmit package cases (section 8, R3) | none on this ground |
| (6) pass-120 residues | d05 (non-ANSI port) decoded to the emission road, not landed (R6); gB b02-b06 and gT t08 are ParamEmit/golden faces (R7) | none |

## 2. The laws (each droppable alone; `R11U125_OFF=1` drops all eight)

| law | switch | site (file + token) | rule |
|---|---|---|---|
| § genvarParamFile125 | `R11U125_GVFILE_OFF` | ModuleEmit.cpp emitGenScopes, the genvar localparam case | the loop-index parameter carries `VpiFile` = the file of the generate block the child instance is built on (Surelog `UhdmWriter.cpp` "Loop indexes": `p->VpiFile(fileSystem->toPath(instance->getFileId()))`, `ModuleInstance::getFileId` = file of the genBlock node) |
| § genvarParamLoopVarLine125 | `R11U125_GVLINE_OFF` | same case | its line is the genvar IDENTIFIER of the loop that iterates it (`DesignElaboration.cpp`: `child->setValue(name, ..., fC->Line(varId))`), which is slang's implicit genvar parameter location; the nearest-LoopGenerate walk picked the INNER loop when an outer loop's body is itself a loop, and the `for` line when the header spans lines |
| § spanCopyCarriesFile125 | `R11U125_SPANFILE_OFF` | `cpFile125` (ModuleEmit.cpp and its TypeEmit.cpp twin), called at foldBareParamBound, emitModuleArray, pkgVectorFoldTwin (3), foldVectorTsBounds, emitInstance (explicit-port interface: port + lowconn), materializeDefNetTs, the pendingCastAggTs `cpLoc` lambda (emitTopPorts), substNdaParamRefs, emitInterfaceInstance (3), TypeEmit buildStructTs / buildUnionTs / buildUnpackedArrayTypedefTs | an object that copies its span from another object copies its file too (Surelog's clones carry every location field) |
| § castTsDrainFile125 | `R11U125_CASTFILE_OFF` | ModuleEmit.cpp emitTopPorts, the pendingCastTs drain (type-cast case and size-cast case) | the deferred cast-target typespec takes the file of the cast operation it hangs off |
| § macroTokenFileFollowsLine125 | `R11U125_MACROFILE_OFF` | UhdmExporter.cpp fullFilePath (`macroFileLoc125`, `macroBodySpansLines125`) | a macro-expanded token's file follows Surelog's per-line records: an argument reads as its formal's position; a token of a body that spans lines reads the definition file; a token of a one-line body reads the invocation's file (recursively) |
| § includeFirstLineColShift125 | `R11U125_INCCOL_OFF` | UhdmExporter.cpp fileLineCol | the first line of an included file is read shifted right by the `include directive's column minus one (the preprocessor splices the text in place; the line records remap line and file, never the column) |
| § macroBodyTrailingComment125 | `R11U125_MACROCMT_OFF` | UhdmExporter.cpp buildMacroExpansions | the spliced length of a one-line body is the rest of the `define line with a trailing `//` comment cut off and everything before it kept (trailing whitespace, block comments) |
| § includeInfoEmptyRedefineLine125 | `R11U125_INCREDEF_OFF` | UhdmExporter.cpp emitIncludeFileInfos | every `define that redefines an already-defined macro with an EMPTY body drops one flattened output line; the include_file_info line (a flattened line) of every later directive in that root file moves up; per compilation unit (one syntax tree each) |

`R11U125_OFF=1` restores pristine bytes on all 61 grid cases (byte compare of the database; positive
control: the law binary without the switch differs from pristine on 51 of them), and the pristine strict
cell on every one of the 342 changed row-modes (attribution sweep, section 6).

## 3. Decode notes

* **Genvar parameter** (C0001/C0582): Surelog writes it from the instance's mapped value, not from a
  declaration: file = `instance->getFileId()` (the genBlock node's file), line =
  `fC->Line(varId)`, column 0, no end. `DoubleLoop`: `for (i..) for (j..) begin:W` — the `i`
  parameter of `genblk1[0]` is at line 9 (the `i` loop), ours said 10 (the inner loop found first).
* **Macro and include attribution** (F10): `SV3_1aPpTreeShapeListener.cpp` pushes a
  `IncludeFileInfo::Context::MACRO` record at each invocation (output line -> the macro's
  `m_startLine` in `m_fileId`) and pops back to the invocation file/line after the body. A body with
  no newline pushes and pops on the same output line, so the pop wins; a multi-line body keeps the
  definition file on every one of its lines, the FIRST line included, and even the text BEFORE the
  invocation on that line (grid g3 m13, m15: `assign o = b + \`K2;` with a two-line `K2` reads
  defs.svh line 1 for `b`). The file law lands the token-level part; the first-line LINE and the
  pre/post-text faces are residue R4.
* **Include column**: the `include line's indentation stays in the output line and the first line of the
  included text follows it (g1 a06, g3 m09).
* **Macro body length**: grid g4 k01-k08 read the column of a token after the invocation for eight
  bodies: `8 // c` -> 2, `8   // c` -> 4, `8   ` -> 4, `8 /* c */` -> 9, `8<tab>// tab` -> 2,
  `8 /* c */ // d` -> 10, `(4+4)  // paren` -> 7, `8` -> 1 (the law's rule reproduces all eight;
  ours counted the comment and trimmed the whitespace).
* **include_file_info**: bisecting YosysOldSpi's `spi_defines.v` over three inclusions located the
  loss at line 47, `\`define SPI_DIVIDER_LEN_16` (an empty body, a redefinition from the second
  inclusion on); g5 r01-r06 confirm (empty redefinition in the root file, bodied redefinition keeps its
  line, `undef` in between, nested includes). `-fileunit` rows are one compilation unit per file (the
  first version of the law leaked the macro set across units and moved SeqDriver/SimpleUVM/YosysOldOpen
  testflags the wrong way; fixed before the final sweep, measured).

## 4. Grids (cases under grid/, every case names its law in its first line)

Scored per cell against golden's records (drivers/case.sh: Surelog `-parse -nobuiltin -nocache -sv
dut.sv -mt 0 -mp 0`, ours `dut.sv --single-unit --nobuiltin`, strictcmp; drivers/fielddiff.py counts
differing objects per field). Full table: evidence/grid_scores.txt.

| grid | law | cells | strict-equal pristine | strict-equal law | cells whose differing-field counts grow |
|---|---|---|---|---|---|
| g1 a01-a18 (shapes x contexts: separate/inline genvar, nested no-begin, split headers, include, one- and multi-line macro, generate region, interface, if-generate, two parameterisations, if/else body, three nested loops, nested region) | § genvarParamFile125, § genvarParamLoopVarLine125 | 18 | 0 | 16 | 0 |
| g2 c01-c09, c11 (one case per census site family; drivers show which site marks each case with the census build) | § spanCopyCarriesFile125, § castTsDrainFile125 | 10 | 0 | 6 | 0 |
| g3 m01-m16 (macro defined in an include used in the main file; same file; multi-line body; argument on a later body line; argument on the first line; nested macro in a multi-line body; nested include; object spanning a macro; macro used inside an include; `$display` argument pasting; pre/post text) | § macroTokenFileFollowsLine125, § includeFirstLineColShift125 | 16 | 1 | 11 | 0 |
| g4 k01-k11 (macro body tails; k03's trailing blanks after `8` ARE the case, keep them) | § macroBodyTrailingComment125 | 11 | 2 | 10 | 0 |
| g5 r01-r06 (redefinition shapes) | § includeInfoEmptyRedefineLine125 | 6 | 2 | 6 | 0 |

Cells that stay unequal and why: g1 a06 (the def-view gen_for int_typespec of a loop inside an include
reads the INCLUDING file in golden: R5), g1 a10 (NOT_EQUAL under uhdm-cmp at the base, interface
gen scope: not this pass), g2 c04 / c07 / c11 (full name and value faces after the file cleared),
g2 c06 (the union cast clone `ucl` in ExprEmit.cpp copies its span without a file: R2), g3 m05 m10
m13 m14 m15 (first line / pre / post text of a multi-line body: R4), g4 k09 (a string typespec endcol
face unrelated to the law; the law's column is right there).

## 5. Census (section 8 of the map, re-run at the base; drivers/census_mark.py + drivers/census_an.py)

The census driver lists 22 span writes with no file on my files at the base (evidence/census_sites.txt).
A marker build stamped `CENSUS_<file>_<line>` at each; both corpora were swept and every marked object
was paired with golden's record (evidence/census_an.out, census_rows.tsv): golden has a FILE on every
marked object at every site that reaches a judged row (0 golden-empty); the file is the source object's
(or the cast operation's) file. Sites reached: 20; not reached by any judged row: 2
(ModuleEmit emitInstance `sv9` struct_var copy and the `op` pending-operation drain) — left unstamped,
no evidence. TaskFuncEmit's `pv9` gets its file later (pristine already has it): nothing to do.

## 6. Corpus census, strict column (law sweep vs pristine sweep, row by row)

| corpus | judge-equal row-modes | strict-equal pristine | strict-equal law |
|---|---|---|---|
| surelog | 954 | 521 | 576 |
| uhdm2rtlil | 1606 | 1072 | 1190 |

Row-modes changed: 342 = 173 `differ -> equal`, 133 fewer objects on the same first field, 36 first field
moved (30 with fewer objects; 6 with the same count — unpacked_struct_2d / unpacked_struct_dyn_read /
unpacked_struct_mixed, both modes, `file(13) -> endline(13)`: the endline differences were already on the
same 13 objects, the file ones cleared). 0 worse, 0 more, 0 status changes. evidence/cols_P_8.tsv.

Per-object check (drivers/objcheck.py): every CMP_EQUAL row-mode whose database bytes moved, pristine vs law
records paired to golden's; an object field is IMPROVED when law = golden != pristine, WORSENED when
pristine = golden != law. Result over all 2560 CMP_EQUAL row-modes: 2178 byte-identical, 382 moved (381 with the same walk,
1 walk change = Scoreboard/default, the UVM order coin); **improved 247542 object fields, worsened 0**,
neutral 2080 (a field that changed but differs from golden before and after: UVM `uvm_reg_byte_en_t`
endcol 41 -> 42 against golden 55 — a nested-macro body length, the rest of it R4 —, YosysOldOr if_stmt
endcol 160 -> 132 against 106, Scr1SvTests 8 operations whose golden file is a third file, and walk-unpaired
objects of the coin rows). evidence/objcheck_P_law.tsv (moved rows only).

Attribution (drivers: verify_golden per switch on the changed rows and the byte movers): each law switched off alone on the law binary over every changed row and every byte
mover (both modes; evidence/attribution_summary.txt, byte_movers_attributed.tsv).

| law | row-modes that stop being strict-equal when ONLY this law is off | ... of which this is the only law needed | byte movers the law touches |
|---|---|---|---|
| § genvarParamFile125 | 120 | 116 | 212 |
| § genvarParamLoopVarLine125 | 4 (func_upto, DoubleLoop, both modes; with GVFILE) | 0 | 9 |
| § castTsDrainFile125 | 34 | 34 | 89 |
| § spanCopyCarriesFile125 | 15 | 13 | 74 |
| § macroTokenFileFollowsLine125 | 4 | 2 | 53 |
| § includeFirstLineColShift125 | 2 | 2 | 7 |
| § macroBodyTrailingComment125 | 0 (fewer objects on 12 rows: YosysOldSpi 525/523 -> 1, YosysOldOr, YosysBigSimEllip, the UVM rows) | 0 | 12 |
| § includeInfoEmptyRedefineLine125 | 0 (YosysOldSpi default `line(3)` -> `fullname(1)`) | 0 | 7 |

All 173 turned rows are covered (combinations: GVFILE 116, CASTFILE 34, SPANFILE 13, GVLINE+GVFILE 4,
MACROFILE 2, INCCOL 2, MACROFILE+SPANFILE 2). `R11U125_OFF=1` gives back the pristine strict cell on
342/342 changed row-modes and pristine BYTES on 380/384 byte movers; the other 4 (MiniAmiq, SeqDriver,
both modes) differ from the pristine sweep by the known UVM order coin only (4 dump lines,
`vpiDecompile:0`/`UINT:0` vs `910`), and every single-law switch run of them differs the same way.

Probe cases (4087): strict-equal 1712 -> 1836; 124 cases turn equal, 165 fewer objects, 155 moved with
fewer, 2 moved with the same count (`r10earl_repro/pt23` file(19) -> endline(19),
`r11u109repro/grid/hp/h08_unpacked_base` file(3) -> endline(3): drivers/fielddiff.py shows only the file
diffs removed, the endline ones pre-existing); 0 worse (evidence/probe_cmp.txt).

## 7. Gates

1. build: pristine md5 `cb7b39bd1fa8` (= main tree), law `9b9884b9c78b`.
2. probe: EQUAL=4087 (of 4087) with the law binary; strict tally 1712 -> 1836.
3. corpora: surelog `[default] CMP_EQUAL=480 ... [testflags] CMP_EQUAL=474`, uhdm2rtlil 803/1/67 both
   modes; `regressions=0 conversions=0 changes=0` in both corpora.
4. downstream (law): `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not
   excused=0`; row-by-row identical verdicts and `differs` to the pristine run (func_upto
   `EQUIVALENT ... nohier`, matching_end_labels EQUIVALENT, arb_idx_cast IDENTICAL).
5. uhdm-cmp: 0 lines on every grid cell that was equal at the base, and every corpus row keeps its status.
6. byteverify: `SELFCHECK=1 byteverify.sh` law vs pristine: PATH_SETS_IDENTICAL (960 / 1608 paths), SELFCHECK
959/960 and 1607/1608 flagged; movers 141 (surelog) + 245 (uhdm2rtlil) = 386 databases (384 CMP_EQUAL
row-modes + stamped_gen_param both modes, the CMP_NOTEQUAL row whose genvar parameters gain their file).
PREDICTED from the pristine databases first (drivers/predict.py, evidence/predict_pristine.tsv): the 206
databases whose pristine records hold a file-less column-0 gen-scope `parameter` (the genvar predicate)
ALL moved; every mover but 4 is in the pristine-predicate set (a located object whose file or line-1
column differs from golden): the 4 are stamped_gen_param (CMP_NOTEQUAL, no strict dump; genvar law) and
BiasValue / BlackConst testflags (strict-equal / same line count before and after: their moved objects
are outside the strict walk; attribution SPANFILE, the census site of their default-mode rows).
Every mover is attributed by the switch runs (no mover without a law).
7. canaries: `canaries.sh` law vs pristine sweep: surelog ok=35 changed=17, uhdm2rtlil ok=6 changed=10 —
every change is a strict-column improvement (Scr1SvTests line(674) -> line(244), BasicOh fullname(89) ->
(52), YosysOldOr file(2589) -> line(78), YosysOldOpen line(186) -> line(19) / file(173) -> endcol(6),
SVSwitch endcol(46) -> (38), ApbSlave line(59) -> (30), SimpleUVM/SeqDriver/Scoreboard line -72,
EnumConcat / hier_path / genscope_cells / genvar_loop_decl_3 -> equal, MultirangesStartNotFromZero
file(3) -> file(2)); status column unchanged on all. `EXPECT_UNKNOWN=1 ctcan2.sh` vs the pristine sweep:
changed=9, all strict improvements (PartSelect4 col(9) -> col(1), BlackBox family file(1) -> equal,
BlackConst line(31) -> (29)); `EXPECT_UNKNOWN=6` uhdm2rtlil: PASS. Against results/golden_*.csv both
ctcan2 runs read every row CHANGED for the PRISTINE sweep too (the committed csvs check out with CRLF line
ends here): environment, calibrated.

## 8. Residues, ranked

First differences of the law sweep over its 794 strict-NE row-modes (both corpora, both modes), by the
first differing object's type: ref_typespec 187, ref_obj 134, parameter 110, struct_typespec 54,
logic_net 48, constant 33, enum_typespec 29, logic_typespec 27, func_call 20, packed_array_typespec 16,
include_file_info 14 (the UVM/Earlgrey/Scr1 rows: a flattened-line mechanism other than the empty
redefinition, golden MORE lines — not decoded), range 12. The parameter heads are the sister's C0003
(imported-parameter Lhs clone without a file, ParamEmit) and value faces; no genvar parameter heads a row.

* **R1 func_upto (and matching_end_labels) downstream EQUIVALENT**: not a database field. Both rows'
  `_nohier.il` differ only in the ORDER of `update` lines of a `sync init` rule (sorted diff 0 lines);
  the plugin builds that rule from `std::map<RTLIL::Wire*, ...> wire_to_value`
  (`process.cpp` `import_initial_interpreted`), keyed by Wire address. func_upto is now strict-equal with
  and without canonicalisation; the slang-lane netlist did not move with this pass.
* **R2 union cast clone file** (sister's ground): `ExprEmit.cpp` cast case, the `ucl` union clone of a
  package union cast (`castUnionClone`) copies line/col/endline/endcol from `cts` without the file (g2 c06,
  UnionCast, jeras_union).
* **R3 package typedef full names** (sister's ground, F02, about 45 first-field rows): `ParamEmit.cpp`
  package typedef cases build the enum base ref / union and struct member refs with `prefix + prefix +
  name` in BOTH views; golden doubles the package only in the listing view and writes `pa::st_t` in the
  TOP package view (case: two enum typedefs `st_t` in packages `pa`/`pb`, golden listing
  `pa::pa::st_t`, top `pa::st_t`; ours doubled in both). The other F02 shapes are use-site parent chains
  (`work@top.pkg::T` at one use, `pkg::T.m` at another): an identity residue.
* **R4 multi-line macro line model** (my ground, not landed): the first output line of a multi-line
  expansion reads the `define line (m05/m10: golden defs.svh 1, ours the invocation line), text before
  the invocation on that line reads the definition file/line (m13/m15), text after it reads the pop
  record (m14); macro bodies with `ifdef inside drop their inactive lines (ibex `ASSERT_ERROR`: golden
  29, ours 32; first field on 4 rows only).
* **R5** the def-view gen_for `int_typespec` of a loop written in an included file reads the including
  file in golden (g1 a06).
* **R6 d05 non-ANSI type-parameter port** (pass 120 V3): `tpVecLeafAlias120` DOES match the non-ANSI
  internal symbol (a debug build printed NamedType + PackedArrayType for `d_i`), but only the two
  elaborated-port calls reach it; the definition-view port of a non-ANSI declaration is emitted on a road
  that never asks it (ours mints a range-less `logic_typespec` 4:10-4:24, golden shares the default
  3:28-3:39). Also the elaborated `packed_array_var d_i` span (golden the header name 1:14, ours the
  declaration 4:25).
* **R7** gB b02-b06 (inline aggregate override on an interface instance: NOT_EQUAL at base, ParamEmit)
  and gT t08 (golden's own netlist is the broken one): reported by pass 120, unchanged.
* **Implicit nets still stamped** (C0042/C0057, 24 first-field row-modes: foreach variables, disable
  labels, property formals, `$dumpvars` scope names): the late-binding mints are the `implicitNetMap`
  cases in ExprEmit.cpp (emitPropFormalRef, the Iterator/block-parameter case, the system-call scope case)
  and StmtEmit.cpp (Disable); each should call `noteLateBindNet119` on the net it MINTS (not on a reused
  declared net: SimpleUVM's `$dumpvars(0, top)`). Sister's ground.

## 9. Files

* `grid/g1..g5/` — the cases. `evidence/` — census_sites.txt, census_an.out, census_rows.tsv,
  grid_scores.txt, cols_P_8.tsv, probe_cmp.txt, objcheck and attribution summaries, byteverify lists.
* `drivers/` — case.sh / grid.sh (one case, one grid), fielddiff.py, census_mark.py + census_an.py
  (the marker census), strictcmp_cols.py (row-by-row strict column), objcheck.py (per-object
  improved/worsened), probe_strict.py (per-case probe strict), heads.sh (first differences per row).
