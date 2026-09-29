# r11u218dec: the ground-A hand-offs of the r11u214 decode and map 13, decoded and scratch-verified (analyst pass, measurement only)

Base: `c4f26079` (pass 216 landed on `0a682d73` while this pass started; every measurement below is at `c4f26079`,
and the law patch applies clean there). Ground: ExprEmit, StmtEmit, EmitHelpers, ParamEmit. Deliverable: this
directory. The laws are in [law_exprstmt.patch](law_exprstmt.patch) (ExprEmit.cpp, ParamEmit.cpp and one new
header src/R218.h, as r11u217 added src/R217.h) for pair A to land; nothing under src/, results/, tests/ or
third_party/ is changed by the deliverable. No law_typeemit.patch: no ground-B half was needed.

## 0. Verdicts (per cluster family)

| family (brief item) | rule golden follows | law, switch | corpus rows (before -> after) | cases |
|---|---|---|---|---|
| (a) Earlgrey N0073's twelve ExprEmit/ParamEmit objects | a package-qualified name folded as an OPERAND of a module or interface parameter's initializer (a sum, a product, a cast, a concatenation, a replication, parentheses, or the whole initializer written in parentheses) spans `pkg::` | **pkgQualOperandSpanInParam218**, R11U218_QUALSPAN_OFF | Earlgrey_0_1 d/t: the 12 records leave (N0073 72 -> 60, the 60 left are the TypeEmit struct-member bounds of r11u214's ground-B law) | QS: 25 cases, 50 case-views, 20 converting |
| (j)/(i) Earlgrey N0001 / N1012 / N1023 | a dotted path ending in a part select or an indexed part select, written INSIDE an lvalue select's index, is a read: base ref at its own token, the trailing select bare with the path text as its full name | **lvIdxPathRangeTailIsRead218**, R11U218_LVIDXPS_OFF | Earlgrey d/t dm_csrs.sv:362 and :417 (4 records) | HX: 8 cases, 16 views, 10 converting |
| (i) Earlgrey N0807 / N0956 (+ one record on each UVM row) | a reference in the base or width of a dotted path's trailing INDEXED part select is named through the path (`<scope>.<path>.<ref>`, through operations `<scope>.<path>.<select>.<ref>`) | **hpTrailIpsNamesByPath218**, R11U218_HPIPSNAME_OFF | Earlgrey d/t (32 firings), BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d (1 record each) | IX: 13 cases, 26 views, 18 converting |
| (d) the svaunit clone return-variable names (the "544 / 597 split") | the importer's clone of a class method SHARES the home method's return variable (UHDM function::DeepClone copies vpiReturn by pointer); all 600 of svaunit_pkg's listings hold the uvm_pkg object; the "split" counted locals of void methods | **importCloneSharesHomeReturn218**, R11U218_CLONERET_OFF | MiniAmiq d/t and SeqDriver d/t (710 firings each; MiniAmiq's order-blind distance 6339 -> 3766, SeqDriver's 5071 -> 3197) | CR: 14 cases, 28 views, 17 converting |
| (f) ibex_tracer's last 13 records | first copy of an imported pattern parameter per listing unparented, later copies parented | independently decoded as **r11u215's § impPatCopyFirstListingUnparented215** (delivered in /tmp/r11u215.patch while this pass ran): WITHDRAWN here, see section 7 | (r11u215: ibex_tracer d/t CMP_EQUAL) | IP: 12 cases (r11u215's binary converts 14 of 24 views) |
| BuildUVMPkg R5 (`fields[fld_idx-1].get_lsb_pos()`) | the operation index of a method-call receiver element sits under the hier_path, its refs unstored; the element's name is the path so far with the decompiled index | independently decoded as **r11u215's § opIdxRecvElemFollowsPath215 / § opIdxRecvPlainElab215**: WITHDRAWN here | | MS: 8 cases (r11u215 converts 9 of 16 views) |
| BuildUVMPkg #26067 (`f(sequence_ptr.m_next_transaction_id++)`) | the operand of `++`/`--` keeps the lvalue shape in a call's argument too | independently decoded as **r11u215's § incDecOperandKeepsLvalueForm215**: WITHDRAWN here | | ID: 8 cases (r11u215 converts 10 of 16 views) |
| (b) MiniAmiq #899 | closed by pass 216 (§ tfArgOutsideClassOrder216, MiniAmiq d/t file(75) -> fullname(61)); BuildUVMPkg #3245 stays excused by the comparator | none (landed) | | |
| (c) UVM macro method-call spans | golden spans a method call whose name arrives through a macro argument at the parameter's place in the macro BODY for the length of the NAME (`phase_state_change` 168:11-29); ours for the length of the whole call, wrapping lines | not written: the single-file macro shapes (MC, 4 cases) are EQUAL at the base; the face needs the included macro file (UhdmExporter's pp166 model, the sister's) | | MC: 4 cases, all EQUAL |
| (e) N0008, (h) value encodings, (j) r11u213/pass 209 hand-offs | not attempted (section 6) | | | |
| (f) FuncStructVal #747 and the four read-site leftovers | decoded partially (section 5) | not written | | FW 8, RS 8 cases |
| (g) BlackBePipeInt's head #15272 | golden writes NO value for a pattern member whose conditional compares an int member with a string (`"inv"`); ours folds it (section 5) | not written | | |

**Gates (final binary law13, section 3):** probe 0 regressions, 8 conversions, 11 changes; surelog 0 / 0 / 2
(Earlgrey d/t `endcol(45)` -> `fullname(25)`); uhdm2rtlil 0 / 0 / 0; downstream 803 / 66 / 2 / 0 with 0 of 805
lanes moving and every verdict identical; byte movers 11 of 2560 corpus databases and 23 probe databases, exactly
the frozen prediction; chain-keyed away census 0 records lost on all 34 movers (4511 toward golden, the reversed
positive control reading 4511 lost); R11U218_OFF gives the base's bytes on every case-view and on every corpus
mover (two known coin draws, section 4).

No corpus row-mode converts under the four laws of the patch. The rows they move: **Earlgrey_0_1 d/t
`endcol(45)` -> `fullname(25)`** (the 14 differing records before #106660 at the base are gone in the default database; the
first record is now #106660, a ref_typespec full name inside flash_ctrl's `region_cfgs[8]`, a typespec copy), MiniAmiq d/t and SeqDriver d/t
(first field unchanged `fullname(61)`, 1421 / 711 records toward golden), and one record each on BuildUVMPkg,
Scoreboard and SimpleUVM.

## 1. Binaries (frozen `chmod 555` under the pass's scratch bin directory before any measurement)

| name | md5 | what |
|---|---|---|
| pristine216 | `00cd5d712fb76282ba92c898efb8812c` | `c4f26079` in this worktree with the system-deps config; equal to the main tree's build/slang-uhdm |
| law13 | `4861740f09cb67ba171ffadc557ecaf2` | pristine + law_exprstmt.patch (the four laws); a fresh worktree at `c4f26079` with the patch applied rebuilds it byte for byte (as it did law7 for the first round) |
| law7 | `76147ad9425ba956f4d12ce2dcdda11d` | the first round: the four laws + the withdrawn ibex law |
| law12 | `e07078bdd4e7ac99538779e420f6b361` | the round with all seven laws (three withdrawn before delivery) |
| r215onHEAD | `163d48993c33f324469ec0f2751529e5` | `c4f26079` + /tmp/r11u215.patch (src only; its StmtEmit hunk re-deciding landed § caseItemWildConcatOnly217v resolved to the landed text) |
| comp215_218 | `5e3b48056405c67c54eb049162ae1821` | r215onHEAD + law_exprstmt.patch (applies clean on top) |
| law4.g1 | (debug-info build, `-g1`) | gdb pins on this pass's own cases only |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build; unchanged tool |
| strictcmp_x | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant, built by tools/probe/r11u211map/drivers/cc.sh |

Every `slang:` line of every corpus `cmds.txt` names its sweep's binary: 3273 of 3273 law13, 3273 of 3273
pristine216 ([evidence/sweeps/cmds_binary_audit_*.txt](evidence/sweeps/)).

## 2. The decodes and the laws

### 2.1 pkgQualOperandSpanInParam218 (item (a))

Head at the base: Earlgrey_0_1 d/t `endcol(45)`, records `dm_csrs.sv 91:52-56` (golden) against `91:52-61` (ours)
for `dm::dm_csr_e'((dm::Data0 + {4'b0, dm::DataCount}))`, and dm_mem.sv:64-67 (`(dm::DataAddr)`,
`(dm::DataAddr + 4*dm::DataCount)`, `(dm::DataAddr - 4*dm::ProgBufSize)`, `(dm::DataAddr - 1)`). Surelog compiles a
parameter's value in elaboration mode; CompileExpression's `paPackage_scope` branch clones the package parameter's
value and locates it with `fC->populateCoreMembers(child, child, result)` on the Package_scope node, which spans
`pkg::` (CompileExpression.cpp, the `case VObjectType::paPackage_scope` branch under the Primary switch). Laws
pkgQualFoldSpanByView124 and enumQualDefaultDefSpan147 wrote that span only when the ScopedName IS the whole
initializer; the same branch runs for every operand under the initializer's operations and for a parenthesized whole
initializer. The walk from the folded constant to the param_assign passes operations only and stops at a
conditional (q06 is stage 1) and at an assignment pattern (the first census found MultiConcatValueSize d/t,
ParamElabMulti d/t, BitSelectOfParameterPassedToSubmoduleInGenForOfSubmodule d/t and probe r11u88repro x6 reading
the whole name inside a pattern member: refined before the final census, controls q23-q25). A call's or a system
call's argument and a part select's base keep the whole name (q07, q12, q13 EQUAL at the base and untouched). A
package's own parameters are not reached. Grid [cases/QS](cases/QS): 25 cases x 2 views, 20 converting, 32 moving,
0 leaving EQUAL; the stage-1 movers (q05, q10, q19, q21, q22) lose 0 dump lines and gain 2 each
([evidence/grid/dumpaway_law13.txt](evidence/grid/dumpaway_law13.txt)).

### 2.2 lvIdxPathRangeTailIsRead218 (Earlgrey N0001 / N1012 / N1023)

`data_d[dmi_req_i.addr[$clog2(dm::DataCount)-1:0]] = dmi_req_i.data;` (dm_csrs.sv:362, :417): golden base ref
`dmi_req_i` 362:20-29 and the part_select bare with full name `dmi_req_i.addr[$clog2(4'h2) - 1:0]`; ours 362:30-39
and `defname addr`, `work@dm_csrs.csr_read_write.data_d.dmi_req_i.addr[...].addr`. Pinned with gdb (law4.g1, case
HX/h03): the part_select is minted by ExprEmit's MemberAccess chain builder (the Simple range branch) under
`inLhs`. Law lvIdxPathIsRead154 already made the bit-select tail and the plain member of a path inside an lvalue
select's index a read (its gate lvIdxParent154); the range-select tail's base span and the simple part select's
naming were left on `inLhs`. Surelog compiles a select's index through compileSelectExpression's Bit_select loop,
i.e. compileExpression like any read. Grid [cases/HX](cases/HX): 8 cases x 2 views, 10 converting (both views of
h01 h03 h06 h07 h08), the bit-select tail, the plain member and the right-side controls EQUAL and untouched.

### 2.3 hpTrailIpsNamesByPath218 (Earlgrey N0807 / N0956)

`tl_i.a_address[DataBitWidth+:SramAw]` (tlul_adapter_sram.sv:153), `tl_i.a_data[8*i+:8]` (:163),
`.op_addr_i(reg2hw.addr.q[DataBitWidth +: AddrW])` (flash_ctrl.sv:171): golden names a reference that is the base
or the width `work@tlul_adapter_sram.tl_i.a_address[DataBitWidth+:SramAw].DataBitWidth` and a reference under an
operation `work@tlul_adapter_sram.tl_i.a_data[8 * i+:8].a_data.i`, which is ComputeFullName over the chain
ref -> (operation) -> indexed_part_select (skipped only as a ref's direct parent) -> hier_path; ours kept the
scope's name. The simple part-select twin is law hpPartSelBoundNamesBySelect154, the bit-select twin law
hpTrailSelIdxNamesByPath133; the written path's base stays law lvPathSelNamedByChain154's. Grid
[cases/IX](cases/IX): 13 cases x 2 views, 18 converting (continuous assignments, a conditional, a for-loop
variable, a port connection, `-:`, a three-member path, a function body, a variable base); x07 (simple part
select) and x13 (package parameter base, folded) are EQUAL controls; x10 (generate scope) and x11 (`$clog2` base,
stage 1: golden's decompile drops the call) move nothing.

### 2.4 importCloneSharesHomeReturn218 (item (d))

The r11u214 split is not a naming rule. Golden MiniAmiq: every one of the 600 package-level subroutine listings of
svaunit_pkg holds, as vpiReturn, the uvm_pkg object itself (parent `uvm_pkg::<class>::<method>`), for bit, byte,
chandle, class, enum, int, integer, logic, long_int, real, ref, string and time returns alike; ours shared it for
the free subroutines (law pkgCloneRetFixups9's caller) and minted a clone-parented variable for every class method
(544 of 600) ([evidence/decode/cloneret_miniamiq_census.txt](evidence/decode/cloneret_miniamiq_census.txt);
r11u214's "597 svaunit_pkg" count took the first variable child, a local of a void method). Surelog's importer
clone is UHDM `function::DeepClone`, whose generated body copies Return by pointer (`clone->Return((variables*)obj)`,
templates/clone_tree.cpp; `task::DeepClone` clones it), so the shared object is the home CLASS's definition entry in
the elaborated view: identity map of case CR/c01 ([evidence/decode/cloneret_identity_c01.txt](evidence/decode/cloneret_identity_c01.txt),
drivers/retshare.cpp): golden and law both read `p2::c::f` (both views) and `top p1/c` 6:3 sharing ret#2 while the
home listing `all p1::c::f` keeps ret#1; pristine had four distinct objects. The comment in ParamEmit ("Surelog
mints a fresh one — r10uvm3 repro 1") measured typespec instances, not the variable. The law (ParamEmit
emitImportedPkgClassMethodClones, after the clone is emitted) points the clone's Return at the class_defn's
task_func of the method's name at the clone's own span; the minted variable is left unreferenced, as the
free-subroutine half leaves its own. Grid [cases/CR](cases/CR): 14 cases x 2 views, 17 converting, 0 leaving; the
controls (void method, task, in-body method, package function) untouched; c08's elaborated view keeps one
record (a function listed under the importer's class `d`, golden's home object `p1::c::f`, ours `p2::d::f`: another face) and c03 is stage 1 (Surelog's implicit net `this` in
the top module); their whole-dump diffs to golden shrink 94 -> 40, 133 -> 71, 46 -> 8 lines
([evidence/grid/cr_stage1_dumpdiff.txt](evidence/grid/cr_stage1_dumpdiff.txt)): the "lost" dump lines of
[dumpaway_law13.txt](evidence/grid/dumpaway_law13.txt) on these three are uhdm-dump printing a shared object's
subtree once and the weaklyReferenced tail, not records (the chain-keyed census reads 0).

## 3. The gates (final round: law13 against pristine216, both at `c4f26079`)

`tests/sweep.sh --jobs 3` with SLANG_UHDM exported, workdirs of equal name length
([evidence/sweeps/](evidence/sweeps/)):

| stage | pristine216 | law13 |
|---|---|---|
| probe vs golden_probe.csv | 0 / 0 / 0 | **0 regressions, 8 conversions, 11 changes** |
| surelog vs golden_surelog.csv | 0 / 0 / 0 | **0 regressions, 0 conversions, 2 changes** |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | 0 / 0 / 0 (csv byte-identical) |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0 (csv byte-identical) |

EXIT=1 in both is the tests/LAWS.md staleness from this directory's `§` lines (the landing regenerates the index).

The fresh rows ([evidence/sweeps/rows_law13_vs_baseline.txt](evidence/sweeps/rows_law13_vs_baseline.txt)):

    Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(25),,differ:fullname(25)     was differ:endcol(45)
    Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(25),,differ:fullname(25)   was differ:endcol(45)

Probe conversions (all importCloneSharesHomeReturn218 but r10earl_repro/i, pkgQualOperandSpanInParam218):
r10earl_repro/i, r10uvm111repro/g111_a, r10uvm127repro/g127_c_import, r10v111repro/v111_b1, v111_b2, v111_b7,
r10v184repro/gv184_h_retpin, r10v194repro/v194_e_explclone. Probe changes: r10earl_repro/vo fullname(6) ->
fullname(2), r10uvm94repro/g94_a0_head fullname(5) -> fullname(2), r10uvm147repro/g147_a fullname(118) ->
fullname(116) (hpTrailIpsNamesByPath218); r10uvm208repro/g208_e_head fullname(6) -> fullname(4); r10uvm193repro/
g193_c_argface fullname(94) -> fullname(102) and r10uvm207repro/g207_e_head fullname(13) -> fullname(32) (the
pristine walk diverged at #397 / earlier, the law's walk stays aligned further: the chain-keyed census reads 0
lost and 2 / 6 toward); r10uvm194repro/g194_c_clone -> depth(1), r10v111repro/v111_b6 -> type(1),
r10v181repro/v181_e_idxbase and v181_f_mixed -> type(1), v181_h_nofe -> name(7): unmaskings, the structural
record already present at the same index in the pristine database (v181_e #74 `array_typespec` vs
`unsupported_typespec wickyard` in both).

uhdm-cmp reads 0 lines on all 11 corpus movers. Canaries: canaries.sh surelog ok=50 changed=2 (the two claimed
Earlgrey rows; pristine ok=52), uhdm2rtlil ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 surelog PASS (ok=58),
EXPECT_UNKNOWN=6 uhdm2rtlil PASS.

## 4. Movers, predicted by name before the law sweep

The firing census (drivers/census.sh: every corpus row-mode but the four fenced ones via a negative `--filter`
built from the FENCED= line, every probe case, R11U218_TRACE) ran on law6; law7 refined one law, so its census
re-ran on law6's predicted rows (drivers/census_rows.sh, a refinement only narrows a gate); law13 is law7 without
one law and its census ran on law7's rows. [evidence/census/predict_law13.txt](evidence/census/predict_law13.txt)
(md5 `a818fd60e4cc161bcbbac81328c4bbf9`, stamped 2026-09-28 21:28:52 with law13's md5, before the sweep started at
21:29:01): 34 databases, 11 corpus + 23 probe. byteverify (tools/probe/r11v75repro/byteverify.sh on hard-link
mirrors without the 8 fenced row-mode databases, SELFCHECK 2559 / 2560 flagged, path sets identical): **11 of 2560
corpus movers, exactly the 11 predicted; 23 probe movers, exactly the 23 predicted**
([evidence/movers/byteverify_law13.txt](evidence/movers/byteverify_law13.txt)). Scoreboard default's mover is the
law's one rename (sorted dumps differ by the two lines of `rw.data[i * 8+:8]::data::i`), not the coin.

Finding of the first round (law7, [byteverify_law7.txt](evidence/movers/byteverify_law7.txt)): NoReducTypespec
d/t moved with 0 dump lines and no firing: the withdrawn ibex law skipped law131's re-mint of an already
unparented reference, one orphan object fewer. It was refined to replay law131 exactly where law131's key holds
before being withdrawn; no law of the patch has an untraced effect (every mover of the final round is predicted).

R11U218_OFF on law13 restores the base's bytes on all 216 case-views and on the corpus movers
(BuildUVMPkg, Earlgrey, SeqDriver, SimpleUVM both modes, MiniAmiq default); MiniAmiq testflags and Scoreboard
default read another binary hash with an identical dump (MiniAmiq storage order) and a 92-line unsorted / 0-line
sorted dump difference (Scoreboard's svunit listing-order coin).

## 5. Decoded without a law

* **FuncStructVal #747** (`NOCType: config_pkg::NOC_TYPE_AXI4_ATOP` in cva6_config_pkg, a package declared BEFORE
  config_pkg): golden keeps an unresolved `ref_obj` spanning `config_pkg::` (106:16-28), ours the whole name. The
  forward whole initializer (FW/f04) spans the whole name in golden and ours; every pattern shape (FW f01-f03,
  f05-f08) is stage 1 at the base on package listing order, so no strict grid exists; not written.
* **FuncStructVal's four INSTR_PER_FETCH leftovers** located by golden at the read site 618:22-45: eight shapes
  built on pass 210's m04 ([cases/RS](cases/RS): a child localparam `$clog2(N)+1`, a port sized by it, both, a body
  use, the parameter named as the function's formal `CVA6Cfg`, the member read again in the function, both) are
  EQUAL at the base with golden leaving the leftover unlocated; the located face is FuncStructVal-specific and
  undecoded.
* **BlackBePipeInt #15272** (default; testflags `depth(1)`): `bp_unicore_megaparrot_cfg_p`'s members
  `cc_x_dim: (bp_unicore_megaparrot_override_p.cc_x_dim == "inv") ? bp_unicore_cfg_p.cc_x_dim : ...` (dut.sv
  2602): golden's tagged_pattern holds NO value (the member's Pattern is null, only the ref_typespec and the
  string_typespec), ours a UINT:1 constant located at `bp_default_cfg_p`'s 2047:16. The override parameter's
  pattern defaults its members to the string `"inv"` (2597); presumably ExprEval does not reduce the comparison of
  that member with the string (not pinned), and golden writes nothing on the miss. A law would drop the member value in ParamEmit's pattern-member fold when the
  condition compares against a string literal; not written (no grid built in this pass).
* **(c) the macro method-call spans**: golden `method_func_call phase_state_change` 168:11-29 in
  uvm_callback_defines.svh (the `cb.METHOD;` line of `uvm_do_obj_callbacks`: the METHOD parameter's column, for
  the length of the method NAME), ours to 169:9 (the length of the whole call laid over the body lines). Four
  single-file shapes ([cases/MC](cases/MC)) with the macro in the same file are EQUAL at the base; the face needs
  the macro defined in an included file, i.e. UhdmExporter's pp166 model (ground B). Not written.

## 6. Not attempted

(e) N0008 (Scoreboard's design-level param_assign right side), (h) the value encodings (r11u204's B3 omitted named
argument, INT / UINT / BIN on parameter and enum values), (j) r11u213's ground-A residues and pass 209's ground-A
hand-offs (the foreach ref_var spans, the call-argument constants, the unfolded `[k + 1]` generate-connection
index text), map 13 item 5's four-row UVM A families beyond the clusters listed in section 8.

## 7. Overlap with r11u215 (pair A, delivered /tmp/r11u215.patch at 20:21, not landed)

Three of this pass's laws re-derived r11u215's: the ibex_tracer first-copy rule (§ impPatCopyFirstListingUnparented215),
the method-receiver operation index (§ opIdxRecvElemFollowsPath215, § opIdxRecvPlainElab215) and the inc/dec
operand in a call argument (§ incDecOperandKeepsLvalueForm215). They were withdrawn from the patch before the
final census (the seven-law patch is kept as [evidence/decode/law12_with_r11u215_duplicates.patch](evidence/decode/law12_with_r11u215_duplicates.patch)).
Their grids stay as independent cases of r11u215's laws, relabelled with its law names: r11u215's binary on
`c4f26079` converts 33 of the 56 case-views and leaves none EQUAL-to-worse (IP 14/24, MS 9/16, ID 10/16; the rest
are EQUAL controls or stage 1) ([evidence/grid/grid_dup_r215.tsv](evidence/grid/grid_dup_r215.tsv)). Composition:
law_exprstmt.patch applies clean on top of r11u215's src; on that binary this pass's four families convert
exactly as on the base (QS 20, HX 10, IX 18, CR 17 of 120 case-views, 0 leaving) and the r11u215 families do
not move ([evidence/grid/grid_comp.tsv](evidence/grid/grid_comp.tsv)). r11u215's src applies to `c4f26079` with
one conflict in StmtEmit: its § caseItemWildConcatOnly215 re-decides the landed § caseItemWildConcatOnly217v.

## 8. The UVM rows and the families

Order-blind distance (drivers/uvmdist.sh, canonical records; [evidence/uvm/](evidence/uvm/)):

| row-mode | pristine216 dist / total | law13 dist / total |
|---|---|---|
| MiniAmiq d/t | 6339 / 14402 | **3766 / 10575** |
| SeqDriver d/t | 5071 / 10928 | **3197 / 8499** |
| SimpleUVM d/t | 1983 / 3812 | 1982 / 3810 |
| Scoreboard d | 1453 / 2829 | 1452 / 2827 |
| BuildUVMPkg d/t | 713 / 1371 | 712 / 1369 |

Map 13's analyzer on the first 50 differing records per default row-mode (drivers/an.sh;
[cluster_delta.txt](evidence/uvm/cluster_delta.txt)): Earlgrey N0073 72 -> 60, N0807 20 -> 0, N0956 16 -> 0,
N0001 / N1012 / N1023 4 -> 0 each, N0005 N1033 N1104 -> 0; MiniAmiq 2756 -> 16 objects over its changed clusters
(N0480 N0485 N0510-N0514 N0520 N0537 N0539 ... -> 0, the clone return-variable family), SeqDriver 2041 -> 11;
N0247 2 -> 1 on BuildUVMPkg, MiniAmiq and Scoreboard (the ips name). Scoreboard's NEW 817 -> 21 is its svunit
listing-order draw between the two sweeps. The first records after the laws: MiniAmiq / SeqDriver #10107 /
#10090 (uvm_event_pool, r11u214's § classTdAliasLastWriter214, being landed by pair B), SimpleUVM / Scoreboard
#458 / #466 (UVM_MACRO_NUMFLAGS, r11u214's § unitImportCopyOwnTsRef214), BuildUVMPkg #26067 (r11u215's
§ incDecOperandKeepsLvalueForm215), Earlgrey #106660.

## 9. Determinism and downstream

drivers/det.sh (three concurrent harness runs per binary, [evidence/det/](evidence/det/)): every row-mode one hash
per binary equal to the gate sweep's, except Scoreboard default (law13: three binary hashes, one dump; pristine216:
two dump orders, the svunit coin) and MiniAmiq testflags (one hash per binary, differing from the sweep's with an
identical dump: storage order, in both binaries). No new reader-visible coin.

Downstream: 0 of 805 lane databases move (no law fires on a uhdm2rtlil test after the ibex law's withdrawal);
verdicts identical row for row. The 60 law cases (QS HX IX CR) through the downstream machinery
(drivers/dscases.py): IDENTICAL on both binaries ([evidence/downstream/](evidence/downstream/)).

## 10. Fence and process

* Every driver reading corpus sources or databases reads the four names from the FENCED= line of
  tools/probe/r11u107repro/canaudit.sh and fails closed: env.sh, case.sh, census.sh, census_rows.sh (refuses a
  prediction file holding a fenced name), predict.py, awayrows.py, bvmirror.sh (8 fenced databases skipped unread),
  det.sh, an.sh, dscases.py, dumpaway.py, retvar.py; uvmdist.sh through r11u211map's common.py. The gate sweeps
  dispatched every row as the gate mandates; no binary, gdb or script ran on a fenced test's sources or databases
  outside them. gdb ran only on this pass's own cases (HX/h03, ID/d01, ID/d03). No fenced name appears in this
  directory.
* Drivers resolve paths from the checkout; the binaries' directory ($B) and scratch root ($S) come from the caller.
* The pass was resumed from an earlier instance's worktree (two laws drafted at `0a682d73`): its src diff was
  re-applied on `c4f26079` and every figure here was re-measured on binaries built in this session.
* Prediction frozen with md5 and time stamp before each law sweep (section 4).

## 11. Residues, ranked

1. Earlgrey_0_1 d/t's first records now: #106660 (ref_typespec full names inside flash_ctrl's `region_cfgs[8]`
   copy), then the tlul_adapter_sram struct-member bounds (r11u214's TypeEmit law, pair B), #121994 `host_req_i.bank` name through a gen scope, #122230 a folded constant's column
   (flash_phy_pkg.sv:43), #123519 a logic_typespec end column, #123586 a generate-scope `N` reference full name.
2. The UVM rows: the r11u214 / r11u215 heads above; after them the macro method-call spans (section 5).
3. BlackBePipeInt's null pattern member (section 5), FuncStructVal's #747 and read-site leftovers (section 5).
4. The CR residue: a method listed under the importer's own class (`p2::d::f` where golden holds `p1::c::f`, c08 elaborated view).
5. Items not attempted (section 6).

## 12. Files

law_exprstmt.patch; cases/ (QS HX IX CR: the laws; IP MS ID: r11u215's laws; FW RS MC: decode-only, no LAW file,
first line `r11u218 decode`); drivers/ (env.sh case.sh grid.sh switches.sh census.sh census_rows.sh predict.py
awayrows.py bvmirror.sh uvmdist.sh det.sh an.sh clusters.py dscases.py dumpaway.py retvar.py retshare.cpp patref.py
pin1.sh); evidence/ (grid, census, sweeps, movers, away, uvm, det, downstream, decode).
