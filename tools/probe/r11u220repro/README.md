# r11u220 — the expression/parameter ground: the r11u218 decode's four laws landed; a path's trailing var_select names its element indices through itself (anon_struct_packed_dim d/t CMP_EQUAL); string-literal spans; `new[...]` call arguments unnamed; an importer clone's path-select indices named by their chain; the landing-205 switch reach

Base: `57ce3ae8` (pass 215). Ground: src/ExprEmit.cpp, src/ParamEmit.cpp, src/EmitHelpers.h, and two new headers:
src/R218.h (the r11u218 decode's, landed as delivered with R11U220_OFF added) and src/R220.h (this pass's switches
and trace). Nothing under results/, third_party/ or tests/ changes except the regenerated tests/LAWS.md. The patch is
`/tmp/r11u220.patch` (git diff against `57ce3ae8`, this directory included).

## 0. Verdicts

| target (brief item) | before -> after (fresh csv rows, `evidence/sweeps/`) | law(s) |
|---|---|---|
| (0) tools/probe/r11u218dec/law_exprstmt.patch | landed: applies clean at `57ce3ae8` (pass 215 landed) and converts as r11u218 measured: probe `r10earl_repro/i` and 7 clone-return cases EQUAL, Earlgrey_0_1 d/t `endcol(45)` -> `fullname(25)` | § pkgQualOperandSpanInParam218, § lvIdxPathRangeTailIsRead218, § hpTrailIpsNamesByPath218, § importCloneSharesHomeReturn218 (switches kept) |
| (3) **anon_struct_packed_dim d/t (uhdm2rtlil)** | **`STRICT_NOTEQUAL differ:fullname(4)` -> `CMP_EQUAL`, both modes** (a CONVERSION: results/ untouched) | § hpVarSelRangeIdxNamesByPath220 |
| (3) InterfArrayBind d `fullname(1)` | unchanged: decoded, the fix is the sister's (section 6.1) | none |
| (3) OutputSize…StructMember d/t `line(8)` | unchanged: decoded, TypeEmit + ModuleEmit sites (section 6.2) | none |
| (3) struct_param_func_config, cfg_func_width_loop | unchanged (their heads are TypeEmit's, section 6.3) | none |
| (4) the UVM A families | the largest ground-A ref_obj family of MiniAmiq / SeqDriver (the svaunit_pkg clone bodies' select indices, 712 references per row-mode) closed; order-blind distance MiniAmiq 6266 -> **2786**, SeqDriver 4969 -> **2493**, BuildUVMPkg 673 -> 648, SimpleUVM 1903 -> 1894, Scoreboard 1393 -> 1386; BuildUVMPkg d/t `line(31)` -> `line(19)`, SimpleUVM d/t `fullname(185)` -> `fullname(183)`, Scoreboard d `fullname(137)` -> `fullname(135)` | § cloneHpIdxNamesByChain220, § strLitShiftNeedsBacktick220, § strLitContLineSpan220, § newArrayCallArgStripped220, § newArrayBitSelIdxStripped220, § hpVarSelColumnJoin220 |
| (1) pass 215's nested-class writers | decoded (golden: the last nested class in ClassMap name order writes last), **not landed**: the stamp's class-writer result is overwritten by the sister's drain (section 6.4) | none (grid TN kept as decode) |
| (1) r11u214 vs pass 215 writer rule | r11u219 had not landed at this pass's start (HEAD was `57ce3ae8`); it landed (`896ec643`) while this pass ran: the composition is measured (section 3), the stamp-versus-writer comparison is not | none |
| (5) landing 205's switch reach | R11U220_LANDING205A_OFF drops this ground's half alone (section 7) | § landingSwitchReach220 |

The fresh rows:

    anon_struct_packed_dim,default,CMP_EQUAL,,,equal           (baseline: STRICT_NOTEQUAL,differ:fullname(4))
    anon_struct_packed_dim,testflags,CMP_EQUAL,,,equal         (baseline: STRICT_NOTEQUAL,differ:fullname(4))

**Gates (law.bin against the committed baselines, `tests/sweep.sh --jobs 3`):** probe **0 regressions**, 11
conversions, 11 changes; surelog **0 regressions**, 0 conversions, 7 changes; uhdm2rtlil **0 regressions**,
2 conversions (anon_struct_packed_dim d/t), 0 changes; downstream **803 / 66 / 2 / 0**, the csv byte-identical to
the pristine sweep's, every row IDENTICAL or its baseline verdict. EXIT=1 in every sweep is only the tests/LAWS.md
staleness (this directory's `§` names; the patch carries the regenerated index).

## 1. Binaries (frozen `chmod 555` under the pass's scratch bin directory before any measurement)

| name | md5 | what |
|---|---|---|
| pristine.bin | `de9af7b93a576744d480028edeee07ed` | `57ce3ae8` built in this worktree (`-DSLANG_UHDM_USE_SYSTEM_DEPS=ON`), equal to the main tree's build/slang-uhdm |
| l218.bin | `0d02c1f9faa8b5669949d145a1861839` | pristine + tools/probe/r11u218dec/law_exprstmt.patch alone (applied clean at `57ce3ae8`; R11U220_OFF added to src/R218.h) |
| **law.bin (law16)** | **`0c0c5c4dc782b8265c226971d7585f85`** | the delivered source |
| law2.bin | `a032144f6942f600e25e23ad0a8d5797` | an early round (r11u218 + the two var_select laws; `evidence/sweeps/sweep_law2.log`) |
| law10.bin | `eb61f538e45ef81952f041f645db1f8d` | the first full round, before § cloneIdxOwnCopyOnly220 and § hpVarSelColumnJoin220 (`sweep_law10.log`) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's build (unchanged tool) |
| strictcmp_x | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant (tools/probe/r11u211map/drivers/cc.sh), for the chain-keyed away census |

The patch applied to a fresh worktree at `57ce3ae8` rebuilds law.bin byte for byte (md5
`0c0c5c4dc782b8265c226971d7585f85`). Every `slang:` line of every corpus `cmds.txt` names its sweep's binary: 3273 of 3273 law.bin, 3273 of 3273
pristine.bin ([evidence/sweeps/cmds_binary_audit.txt](evidence/sweeps/cmds_binary_audit.txt)).

## 2. The laws

Every law reads its own switch; **R11U220_OFF drops every law of this pass and the four landed r11u218 laws** (src/R218.h
reads it too), restoring the base's bytes: on all 300 grid case-views the law binary under R11U220_OFF writes the
pristine binary's bytes (`OFF=pristine` on every line of [evidence/grid/grid_law.tsv](evidence/grid/grid_law.tsv)).
R11U220_TRACE=<dir> (and R11U218_TRACE for the r11u218 laws) names every firing, one file per process whose first
line is `OUT <-o path>`: the firing census that predicted the movers (section 4).

| law | switch | site (anchor) |
|---|---|---|
| § pkgQualOperandSpanInParam218 (r11u218) | R11U218_QUALSPAN_OFF | ExprEmit, `qualOperandInParamDef218` and the `paPackage_scope` parameter and enum branches |
| § lvIdxPathRangeTailIsRead218 (r11u218) | R11U218_LVIDXPS_OFF | ExprEmit, `lvIdxRangeTailRead218` |
| § hpTrailIpsNamesByPath218 (r11u218) | R11U218_HPIPSNAME_OFF | ExprEmit, `hpTrailIpsNames218` |
| § importCloneSharesHomeReturn218 (r11u218) | R11U218_CLONERET_OFF | ParamEmit, emitImportedPkgClassMethodClones |
| § hpVarSelRangeIdxNamesByPath220 | R11U220_HPVSIDX_OFF | ExprEmit, `hpVsRangeIdxPrefix220` (the hier_path's trailing var_select) |
| § hpVarSelIpsDirectRefSkipsSelect220 | R11U220_HPVSIPS_OFF | ExprEmit, `hpVsIpsDirectRefs220` |
| § hpVarSelColumnJoin220 | R11U220_HPVSCOL_OFF | ExprEmit, `hpVsJoin220` |
| § strLitShiftNeedsBacktick220 | R11U220_STRSHIFT_OFF | ExprEmit, the StringLiteral branch (`strLitBackslashShift220`) |
| § strLitContLineSpan220 | R11U220_STRCONT_OFF | ExprEmit, `strLitContLineEnd220` + the design-final `strLitContEndDrain220` (run from ParamEmit's drainPaNameCopySrc38) |
| § newArrayCallArgStripped220 | R11U220_NEWARRCALL_OFF | ExprEmit, `stripRefFullNames11` (§ newArray11's strip) |
| § newArrayBitSelIdxStripped220 | R11U220_NEWARRIDX_OFF | ExprEmit, `stripRefFullNames11` |
| § cloneHpIdxNamesByChain220, refined by § cloneIdxOwnCopyOnly220 | R11U220_CLONEIDX_OFF | ParamEmit emitImportedPkgClassMethodClones (`noteCloneHpIdx220`), ExprEmit `cloneHpIdxDrain220` (run last in drainPaNameCopySrc38) |
| § landingSwitchReach220 | R11U220_LANDING205A_OFF (new; R11U220_OFF does NOT read it: the base keeps landing 205) | EmitHelpers.h, `r11u205aOn` |

### 2.1 § hpVarSelRangeIdxNamesByPath220 (anon_struct_packed_dim's `gx` records)

Head at the base (uhdm2rtlil anon_struct_packed_dim d/t `fullname(4)`, dut.sv:75 in the generate scope
`g_i[*].g_x[*]`): `assign o_pm[gi*2+gx-1] = &(tq[gi].is_page[2-gx][0:0] | (~en[0]));`

    golden  ref_obj gx  work@anon_struct_packed_dim.g_i[0].g_x[1].tq[gi].is_page[2 - gx][0:0].is_page.gx  75:51-53
    ours    ref_obj gx  work@anon_struct_packed_dim.g_i[0].g_x[1].gx                                     75:51-53

Surelog compiles the path's trailing member with more than one select as a `var_select` named after the member
(compileSelectExpression) and stores no full name on the index references; the writer's ComputeFullName walks the
chain ref -> operation -> var_select (a var_select parent is not one of the skipped kinds, UHDM BaseClass.cpp) ->
hier_path. The plain-variable twin (`a[i][3:0]`, ExprEmit's element-select branch) already scoped its indices through
the base; the hier_path branch passed the scope. Pairwise grid ([cases/GX](cases/GX)): the rule holds when the var_select's
LAST select is a range (g02 localparam, g05 net, g10 direct index, g11 always_comb, g13 `-:`, g14 function body,
g17 net-declaration initializer, g18 three selects, g26 generate-local net, g28/g29 parameter bounds, g30 for loop,
g33 implicit net), and the all-bit-select form is already EQUAL at the base (g06, g07, g09).

### 2.2 § hpVarSelIpsDirectRefSkipsSelect220

The trailing `[ix+:2]` of that var_select is an indexed_part_select named with the member (the doubled
`...pg.pg`); ComputeFullName skips an indexed_part_select directly above a ref_obj, so a reference that IS the base
or the width takes the var_select's name (`work@top.tq[1].pg[ix][ix+:2].pg.ix`), where a reference under an
operation keeps the doubled name (g13, already ours). GX g12 g23 g29.

### 2.3 § hpVarSelColumnJoin220

ComputeFullName uses ONE separator for the whole chain, `::` as soon as a package or class is on it: golden
BuildUVMPkg uvm_pkg.sv:76967 `uvm_pkg::uvm_reg_map::do_bus_access::rw.value[idx][8 * i+:8]::value` (the var_select),
`...::value::value` (its trailing indexed part select), `...::value::idx`; ours joined the member with `.`. The
joint is the one joinRef chose for the path itself. GX g35 (class method, EQUAL), g36 (package function, stage 1,
6 records toward, 0 away).

### 2.4 § strLitShiftNeedsBacktick220 (BuildUVMPkg #42260 / #42261)

`convert2string = "Allocated memory regions:\n";` (uvm_pkg.sv:70758): golden constant and assignment `21-50` (the
source span), ours `-52`. The existing end-column rule (+2 per source backslash on an assignment's right side) was
measured on uhdm2rtlil StringWithBackslash alone, `"\\/ _| __| | '_ \\ / _` / "`, whose text holds a backtick
followed by a blank; every literal without one keeps the source span in golden ([cases/SL](cases/SL) s01 s03-s07
s09-s11 s13-s25 s27-s29, s53 interface body, s54 macro-born). With a backtick-blank the old rule stays (s08, s26
EQUAL at the base and untouched); s30-s39 read another shift (a residue, decode-only cases: s30 `"a\nb` c"` +4 with
one backslash, s35 `"a\\\\b` c"` +4 with four).

### 2.5 § strLitContLineSpan220 (BuildUVMPkg #55520, #55559, #55593, #55621)

A string literal continued over lines (backslash-newline) ends on its START line at the start column plus the whole
raw text's length: golden `$sformatf("this version of UVM does not properly support memories with \<nl>...")`
76494:54-331, ours 76494:54-76496:102. An assignment, continuous assignment or parameter assignment whose right
side is such a literal ends at the literal's computed end too (Surelog spans a statement to its last token's end):
a design-final drain, keyed on the literal's start, applies it only where the object's own end is the literal's
source end. SL s02 (system-call argument) s40 s41 (assignment, with `\n` and `\\` inside) s42 (localparam) s43
(two arguments) s45 (concatenation) s46 (return) s49 (case item) s55 (interface) s56 (named task argument): EQUAL;
s44 (continuous assignment) unmasks a `size` record present at the same index in the pristine walk; s47 s52 (CRLF)
stage 1 on both, 0 away; residues: s48 (a class property initializer, emitted by another path), s50 (a variable
declaration's initializer: the string_var and its string_typespec end at the literal too, the sister's ModuleEmit /
TypeEmit).

### 2.6 § newArrayCallArgStripped220 and § newArrayBitSelIdxStripped220 (BuildUVMPkg #54397 / #54398)

`local_addr= new[ceil(n_bytes,bus_width)];` (uvm_pkg.sv:76197): golden leaves both references unnamed, ours
`uvm_pkg::uvm_reg_map::get_physical_addresses_to_map::n_bytes`. § newArray11 strips the references under the
unparented `new` call but did not descend into a user or system call's arguments; the same call outside `new[...]`
keeps the scoped names (NW w05, EQUAL). [cases/NW](cases/NW): w01 w08 (operation argument) w09 (with a copy source)
w10 (`$clog2`) w11 (bit select argument) w12 (nested calls) w13 (`this.` argument) w14 (module-local class) w15
w18 (named arguments, extern method below the class) EQUAL; w19 (pure virtual base, `this.g(n)`) EQUAL on both.
A reference that IS a bit_select's index under `new` is unnamed too (ComputeFullName skips the bit_select): w16
`new[arr[k]]`, w11. Residue: w17 `new[arr[k+1] + 2]` (golden `arr.k`, the chain through the bit_select; not
written). The `--elabuhdm` views of w01 w10 w11 w13-w16 move bytes only (dumps identical: the class bodies of the
package are not reached by the elaborated walk).

### 2.7 § cloneHpIdxNamesByChain220 + § cloneIdxOwnCopyOnly220 (the MiniAmiq / SeqDriver clone-index family)

The largest ground-A ref_obj family on MiniAmiq and SeqDriver (order-blind, law2 sweep: 240 records in
uvm_factory.svh, 177 uvm_reg.svh, 114 uvm_sequencer_base.svh, 81 uvm_message_defines.svh, 48 uvm_component.svh, 42
uvm_mem.svh, 39 uvm_root.svh, 36 uvm_reg_field.svh per row-mode, [evidence/decode/uvm_family_law2.txt](evidence/decode/uvm_family_law2.txt)):

    golden svaunit_pkg::uvm_default_factory::register::m_inst_override_queues[obj].queue::obj   (the importer clone)
    golden uvm_pkg::uvm_default_factory::register::obj                                           (the home listing)
    ours   svaunit_pkg::uvm_default_factory::register::obj

Surelog's importer clone (UHDM function::DeepClone, the clone_tree of § importCloneSharesHomeReturn218) stores no
full name on these references and hangs a select's index off the select, so the writer's chain runs ref -> bit_select
(skipped directly above a ref_obj) -> hier_path (`m_inst_override_queues[obj].queue`); an index operation stays
under the select, so its references keep the select's name (`::arr::i`). The law marks the hier_paths of each clone's
OWN body when the clone is emitted (a downward walk over owned objects), and design-final re-parents each select's
index at the select and drops its stored name (UHDM's MakeSymbol maps `""` to the unset id), so the writer computes
golden's name in the package listing and in every later copy. The first draft stored the computed name and so broke
the `--elabuhdm` view: the UHDM elaborator's copy of a module's import of the method (`work@top.c::f`) copied the
stored package name where golden (and pristine) compute `work@top.c::f.arr[i].m.i` (CI c01 c03-c05 c10 c11
`--elabuhdm`: 1 record away each); dropping the name instead is exactly Surelog's mechanism and all of them are
EQUAL now. [cases/CI](cases/CI): c01 (return), c02 (method receiver), c03 (lvalue), c04 (operation index), c05
(mid-path select), c08 (`this.` path), c10 (task) EQUAL in both views; c11 (for loop) EQUAL in the elaborated view,
the parse view unmasking a `depth` record present at the same index in the pristine walk; c06 (in-body method) and
c07 (package function) controls untouched; c09 (a call as the index) is stage 1 on both and moved only by
§ importCloneSharesHomeReturn218 (chain-keyed 0 away).

## 3. The gates (law.bin against pristine.bin, both at `57ce3ae8`; workdirs of equal name length)

| stage | pristine.bin | law.bin |
|---|---|---|
| probe vs golden_probe.csv | 3422 + 665, 0 / 0 / 0 | **3433 + 654: 0 regressions, 11 conversions, 11 changes** |
| surelog vs golden_surelog.csv | 929 + 25, 0 / 0 / 0 | **0 regressions, 0 conversions, 7 changes** |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 1598 + 8, 0 / 0 / 0 | **1600 + 6: 0 regressions, 2 conversions, 0 changes** |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0 (csv byte-identical to pristine's) |

**Probe conversions** (11): r10earl_repro/i (§ pkgQualOperandSpanInParam218); r10uvm111repro/g111_a,
r10uvm127repro/g127_c_import, r10v111repro/v111_b1 v111_b2 v111_b7, r10v184repro/gv184_h_retpin,
r10v194repro/v194_e_explclone (§ importCloneSharesHomeReturn218, as r11u218 measured); r10uvm226repro/grid226/a11_nested
(§ strLitShiftNeedsBacktick220); r10v147repro/v147_i (§ hpVarSelColumnJoin220 with § hpVarSelRangeIdxNamesByPath220);
r11u109repro/grid/hp/h03_gen (§ hpVarSelRangeIdxNamesByPath220).

**Probe changes** (11): r10earl_repro/vo fullname(6) -> fullname(2), r10uvm94repro/g94_a0_head fullname(5) ->
fullname(2) (§ hpTrailIpsNamesByPath218); r10uvm147repro/g147_a fullname(118) -> col(14) (118 -> 14 objects; the col
record #123 is at the same index in the pristine walk: an unmasking; § hpVarSelColumnJoin220 +
§ hpVarSelRangeIdxNamesByPath220 + § hpTrailIpsNamesByPath218); r10uvm208repro/g208_e_head fullname(6) -> fullname(4);
r10uvm193repro/g193_c_argface fullname(94) -> fullname(102) and r10uvm207repro/g207_e_head fullname(13) ->
fullname(32): the SAME first record (#561, #119), the pristine walk diverged (3 surplus records, `walk diverged`) and
the law's walk is aligned with golden's (4180 = 4180, 840 = 840 records), so the comparator counts over the whole
walk; the chain-keyed census reads 0 away and 2 / 6 toward; r10uvm194repro/g194_c_clone -> depth(1),
r10v111repro/v111_b6 -> type(1), r10v181repro/v181_e_idxbase and v181_f_mixed -> type(1), v181_h_nofe -> name(7):
unmaskings of a structural record already present at the same index in the pristine walk (r11u218's reading,
reproduced); all these are § importCloneSharesHomeReturn218's, v181_e and v181_f also § cloneHpIdxNamesByChain220's.

**Surelog changes** (7): BuildUVMPkg d/t `line(31)` -> `line(19)` [line -12] (the head #26855 `this_type`
class_typespec location is TypeEmit's, unchanged; the string, `new[...]` and var_select records leave);
Earlgrey_0_1 d/t `endcol(45)` -> `fullname(25)` (r11u218's reading: the new first record #106660 is a ref_typespec
full name inside flash_ctrl's `region_cfgs[8]` typespec copy); SimpleUVM d/t `fullname(185)` -> `fullname(183)`,
Scoreboard d `fullname(137)` -> `fullname(135)` (one `hpTrailIpsNamesByPath218` rename and one string span each).
MiniAmiq d/t and SeqDriver d/t keep `endline(59)` (their first 59 records are the sister's macro method-call spans;
2328 / 1313 records toward golden past them).

Canaries ([evidence/sweeps/canaries.txt](evidence/sweeps/canaries.txt)): canaries.sh surelog ok=45 changed=7 (exactly
the seven claimed changes; pristine ok=52), uhdm2rtlil ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 surelog PASS (ok=58),
EXPECT_UNKNOWN=6 uhdm2rtlil PASS. uhdm-cmp reads 0 lines on every touched row-mode and probe case (all judge-equal).

**Composition with the current main (`896ec643`, pass 219 and the r11u221 verification landed while this pass ran).**
The patch applies there with a 3-way merge, the sources cleanly and tests/LAWS.md by regeneration; built
(md5 `2510f4fe44619abb4eae492a1a0e737f`) and swept with `tests/sweep.sh --jobs 3` against that commit's baselines
([evidence/sweeps/sweep_head896ec64_composition.log](evidence/sweeps/sweep_head896ec64_composition.log)): **EXIT=0**;
probe 0 regressions with the same 11 conversions and 11 changes; surelog 0 regressions and 7 changes (BuildUVMPkg d/t
`line(31)` -> `line(19)`, Earlgrey_0_1 d/t `endcol(39)` -> `fullname(19)`, SimpleUVM d/t `file(56)` -> `file(54)`,
Scoreboard d `file(32)` -> `file(30)`); uhdm2rtlil 0 regressions, anon_struct_packed_dim d/t converting; downstream
803 / 66 / 2 / 0. r11u219's own laws and this pass's compose: pass 219's § modStructMemberQualSpan214 takes the
TypeEmit N0073 records and § pkgQualOperandSpanInParam218 the ExprEmit ones, Earlgrey's first field moving on from
`endcol` as at the base.

## 4. Movers, predicted by name before the law sweep

The firing census (drivers/census.sh: every corpus row-mode but the four fenced ones through a negative `--filter`
built from the FENCED= line of tools/probe/r11u107repro/canaudit.sh, and every probe case, with R11U218_TRACE and
R11U220_TRACE set; drivers/dscensus.py: every downstream lane's translated command line, no Yosys) ran on law.bin;
drivers/predict.py froze [evidence/census/predict_final.txt](evidence/census/predict_final.txt) (md5
`3da1adc3d33257c4d9a3c3c29f718384`, stamped 2026-09-29 00:56:19 with law.bin's md5, before the gate sweep started at
00:56:29; [predict_final.stamp](evidence/census/predict_final.stamp)): 13 corpus row-modes, 26 probe cases, 1 lane.

* **corpus**: byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on hard-link mirrors without the 8
  fenced row-mode databases, drivers/bvmirror.sh; path sets identical): **13 of 2560 movers, exactly the 13
  predicted** ([evidence/movers/byteverify_corpus.txt](evidence/movers/byteverify_corpus.txt)). SELFCHECK reads 2559 of
  2560: the self-check compares every file against ONE fixed file of the set, and that file against itself is the
  one path it cannot flag; the comparator saw the other 2559.
* **probe**: **26 of 4087 movers, exactly the 26 predicted** ([evidence/movers/probe_movers.txt](evidence/movers/probe_movers.txt)).
* **downstream lanes**: **1 of 805 (anon_struct_packed_dim), the one predicted**; its RTLIL (`.il`, `_nohier.il`,
  `_synth.v`) is byte-identical to the pristine lane's, the verdict IDENTICAL on both.

The chain-keyed away census (drivers/awayrows.py, map 13's census on strictcmp_x records, raw full names) over the 39
moving databases: **away 0, toward 7730** ([evidence/away/awayrows_law.txt](evidence/away/awayrows_law.txt)); the
reversed positive control reads away 7730 ([awayrows_reversed_control.txt](evidence/away/awayrows_reversed_control.txt)).
Its flat (unkeyed) column reads 598 away, all on MiniAmiq d/t (154 each), SeqDriver d/t (143 each) and
r10uvm208repro/g208_e_head (4), **all § importCloneSharesHomeReturn218's**: with R11U218_CLONERET_OFF the same law
binary reads 0 flat away on MiniAmiq and SeqDriver and on g208 ([evidence/away/flat_attribution.txt](evidence/away/flat_attribution.txt));
they are the typespec subtrees (constants, ranges, enum constants, ref_typespecs) of the 710 minted return variables
the law leaves unreferenced, which the walk no longer visits; the chain-keyed census, which places each record at
its ancestors, reads 0 away on them (r11u218 section 2.4 read the same).

## 5. Grid and controls ([evidence/grid/](evidence/grid/))

150 case directories x 2 views (the parse form, and `--elabuhdm` / `-elabuhdm`) = 300 case-views, judged by
drivers/grid.sh (pristine.bin, law.bin, law.bin under R11U220_OFF), goldens built by the pinned Surelog per case text:

| group | cases | converting | moved, verdict kept | untouched | verdict changed (not to EQUAL) |
|---|---|---|---|---|---|
| GX (var_select laws) | 36 | 35 | 20 | 16 | 1 (g17 -> depth: unmasking) |
| SL (string laws) | 56 | 72 | 6 | 32 | 2 (s44 d/t -> size: unmasking) |
| NW (`new[...]` laws) | 19 | 11 | 13 | 14 | 0 |
| CI (clone-index law) | 11 | 15 | 2 | 4 | 1 (c11 -> depth: unmasking) |
| R218 (fresh cases of the landed r11u218 laws) | 9 | 11 | 7 | 0 | 0 |
| IA (InterfArrayBind decode) | 8 | 0 | 0 | 16 | 0 |
| TN (nested-class decode) | 11 | 0 | 0 | 22 | 0 |
| **total** | **150** | **144** | **48** | **104** | **4** |

**0 case-views leave EQUAL; R11U220_OFF writes the pristine bytes on all 300.** Every moved case-view that does not
convert was censused ([gridaway.txt](evidence/grid/gridaway.txt)): records lost 0 on every judge-equal one; the
stage-1 ones lose 0 dump lines except CI c09 and R218 r01 (both views), moved only by § importCloneSharesHomeReturn218
(the shared return object printed once by uhdm-dump), whose chain-keyed census reads away 0, toward 6
([caseaway_stage1.txt](evidence/grid/caseaway_stage1.txt)); 8 case-views move bytes with identical dumps
([same_verdict_moved_dumpdiff.txt](evidence/grid/same_verdict_moved_dumpdiff.txt)).

Switch reach per case ([switch_reach.txt](evidence/grid/switch_reach.txt), [switch_pairs.txt](evidence/grid/switch_pairs.txt)):
every one of the 196 moved case-views is restored by exactly its own law's switch (163) or, where two laws fire, by
exactly the pair (33: CLONERET + CLONEIDX 9, HPVSIDX + HPVSIPS 10, STRCONT + STRSHIFT 10, HPVSIDX + HPVSCOL 4).

Fresh cases per the brief's list: implicit nets (GX g33), interface bodies (GX g31, SL s53 s55), a class
specialization in a bound (GX g32), `this.` paths (GX g34, CI c08, NW w13 w19), named calls (NW w18, CI c09, SL s56),
extern and pure virtual prototypes above and below the caller (CI c01-c11, NW w18 w19, R218 r02), two-level generates
and instance depth 3 (GX g01 g15 g16 g26), if/else generate scopes (GX g15), for loops and processes (GX g11 g23 g30,
CI c11), literal widths, bases and escapes (SL s01-s39); for the landed r11u218 laws 2-3 each (R218: q01-q03, h01 h02,
x01 x02, r01 r02: 11 of 18 case-views converting, the rest stage 1 with 0 away).

## 6. Decoded, not landed (the sister's sites)

### 6.1 InterfArrayBind d `fullname(1)` (#183)

`assign peripheral_io_bus[IO_ONES].write_en = 32'hffffffff;` at module scope, the parse form's elaborated listing:
golden `work@soc_tb.peripheral_io_bus[IO_ONES].write_en.IO_ONES`, ours `work@soc_tb.IO_ONES`. § elabIfArrIdxChainName205's
branch (ExprEmit) already writes golden's name, but it runs only once here, in the definition view
(`moduleDefEmit`, traced): **ModuleEmit emitContAssigns SHARES the definition cont_assign with the elaborated listing**
(its share branch, `cas->push_back(defInfo->contAssigns[myIdx])`, for a non-plain, non-dotted left side), where golden
holds two objects. The sister's fix: re-emit that cont_assign for the elaborated listing when its left side is an
interface-array element member and its right side a literal (the gen-scope version, r11u205's a02, already re-emits
and converts); the ExprEmit branch then names it. Grid [cases/IA](cases/IA) i01 i02 i04 i06 (parse view,
STRICT_NOTEQUAL on both binaries), i03 i07 (reading right sides) and all `-elabuhdm` views EQUAL, i05 i08 other faces.

### 6.2 OutputSizeWithParameterOfInstanceInitializedByStructMember d/t `line(8)`

Records #170/#173, #221/#224, #235/#238: `localparam int NumScrmblBlocks = Info.x;` substituted into
`logic [NumScrmblBlocks-1:0] data` and the child's `[Depth-1:0]`: golden's substituted hier_path `Info.x` spans the
REFERENCE it replaces (`NumScrmblBlocks` 17:11-26, `Depth` 4:18-23) and both of its elements the member token
(`Info` and `x` at 15:42-43); ours keeps the initializer's own spans. The site is **TypeEmit's `emitInitHier`**
(the member-init substitution after `emitExpr`), the sister's. #243 (`assign a = '1;` in the instance: golden keeps
the fill literal `'1` BIN, size -1; ours `UINT:65535`, size 16) is ModuleEmit's instance cont_assign.

### 6.3 struct_param_func_config, cfg_func_width_loop

struct_param_func_config d/t: 4 raw full names inside a typespec copy (`work@struct_param_func_config.p::cfg_t.u`
where ours `...u_c.Cfg.p::cfg_t.u`), then the structural #1364 (TypeEmit buildStructTs). cfg_func_width_loop d/t:
#464 (TypeEmit, r11u216's decode) then the kept call #472 (structural). No ground-A record precedes the sister's.

### 6.4 Pass 215's nested-class writers ([cases/TN](cases/TN), decode)

UhdmWriter::writeClass writes a class, then each nested class in its ClassMap (a std::map on the name) order,
recursively (UhdmWriter.cpp, writeClass's `for (auto& nested : classDef->getClassMap())`), each re-parenting the
imported typedef: golden `work@m::lc::inner::p::alias_t` (n01), `work@outer::inner::` (n02), `work@m::zz::b::` with
nested `b` declared before `a` (n03), `work@outer::zeta::` (n05). A descent in § pkgTdAliasLastWriter215's writer walk
was written and **withdrawn**: every class-writer name the stamp writes is overwritten later (the sister's
§ enumImportParentLastWriter180 drain for modules and `$unit`, and for a design with no module, n11, another later
writer keeps `p::p::`), so it moved bytes with no record (even n06, a module class with no nesting, is wrong on the
base: `work@m.p::alias_t` for golden's `work@m::lc::p::alias_t`). The rule is the sister's to apply in
`enumImportParentDrain180` together with pass 215's residue 1.

### 6.5 Other faces seen

* BuildUVMPkg #26855 (`this_type` class_typespec location) and Earlgrey #106660 (typespec-copy names): TypeEmit.
* MiniAmiq / SeqDriver heads (the macro method-call spans, `phase_state_change` 168:11-29, `get_full_name` 116:13):
  UhdmExporter's preprocessor model (r11u218 section 5).
* SimpleUVM #458 / Scoreboard #466 (`UVM_MACRO_NUMFLAGS`): UhdmExporter designImportParamCopy146 (pass 215 residue 2).
* The remaining clone-listing families of MiniAmiq: uvm_reg_map.svh `n` (golden keeps a clone-scoped name in a
  `new[...]` argument of the clone, § cloneNewArrayArgBindsOwnDecl186's R-FULLNAME, deliberately not taken there),
  uvm_phase.svh `<in>uvm_phase`, uvm_reg_block.svh `::` vs `.` on a typedef reference.

## 7. The switch reach of landing 205 (§ landingSwitchReach220)

| switch | drops | measured ([evidence/grid/reach205.txt](evidence/grid/reach205.txt): every case of tools/probe/r11u205dec and this pass's IA, both views, 154 case-views) |
|---|---|---|
| `R11U205_OFF` (unchanged) | all four r11u205 laws: § ifacePortDeclTsAtPortDecl205, § genConnTrailSelChain205 (ModuleEmit / UhdmExporter), § defGenTargetIpsDefName205 (TypeEmit), landed by pass 209; § elabIfArrIdxChainName205 (ExprEmit), landed by pass 210 | moves 34 case-views (GS 22, IP 10, IA 2) |
| `R11U220_LANDING205A_OFF` (**new**) | this ground's half alone: § elabIfArrIdxChainName205 | moves exactly 2 (r11u205dec IA a02, a05, both parse views), byte-identical to `R11U205_IFARRIDX_OFF` on all 154 |
| `R11U205_IFARRIDX_OFF`, `R11U210_OFF` (unchanged) | § elabIfArrIdxChainName205 (and pass 210's laws) | – |

The sister's half has no per-landing switch of its own (`R11U209_OFF` drops pass 209's landing, the sister's files);
reported, not changed.

## 8. Determinism ([evidence/det/det_law.txt](evidence/det/det_law.txt))

drivers/det.sh (three concurrent harness runs of law.bin on Earlgrey_0_1 and the five UVM rows, both modes): one hash
per row-mode for Earlgrey_0_1, SeqDriver, SimpleUVM and BuildUVMPkg; MiniAmiq d/t two binary hashes whose uhdm-dumps
are identical unsorted (storage order only, as r11u218 read); Scoreboard d two hashes, 92 unsorted / 0 sorted dump
lines (the known svunit listing-order coin). The clone-index drain sorts its hier_paths by id before renaming (a
rename interns a symbol). No new reader-visible coin.

## 9. UVM order-blind distance (drivers/uvmdist.sh; [evidence/uvm/](evidence/uvm/))

| row-mode | pristine dist / total | law dist / total |
|---|---|---|
| MiniAmiq d/t | 6266 / 14256 | **2786 / 8615** |
| SeqDriver d/t | 4969 / 10724 | **2493 / 7091** |
| SimpleUVM d/t | 1903 / 3652 | 1894 / 3634 |
| Scoreboard d | 1393 / 2709 | 1386 / 2695 |
| BuildUVMPkg d/t | 673 / 1291 | 648 / 1241 |

## 10. Fence and process

* Every driver that reads corpus sources or databases reads the four names from the FENCED= line of
  tools/probe/r11u107repro/canaudit.sh and fails closed: env.sh (case.sh, grid.sh, switches.sh, pairs.sh, reach205.sh,
  gridaway.sh, det.sh source it), census.sh (negative `--filter`), dscensus.py, predict.py (refuses a fenced row),
  bvmirror.sh (8 fenced databases skipped unread), awayrows.py, dumpaway.py, uvmdist.sh (through r11u211map's
  common.py). The gate sweeps dispatched every row as the gate mandates; no binary, gdb or script ran on a fenced
  test's sources or databases outside them. No fenced name appears in this directory.
* Drivers resolve paths from the checkout; the binaries' directory ($B) and scratch root ($S) come from the caller.
* The prediction was frozen (md5 + time stamp) before the final gate sweep; the pristine binary was frozen before the
  first source edit; every source edit was followed by a fresh build frozen under a new name.
* Two law rounds were refined before delivery on this pass's own grid: § cloneIdxOwnCopyOnly220 (the `--elabuhdm`
  copies) and the trace of three laws narrowed to the firings that can move a byte (so the prediction is exact).

## 11. Residues, ranked

1. The sister's halves: InterfArrayBind d (6.1: ModuleEmit's shared cont_assign), OutputSize d/t (6.2: TypeEmit
   `emitInitHier` spans, ModuleEmit's `'1`), the nested-class writers (6.4: `enumImportParentDrain180`), the UVM heads
   (6.5).
2. The backtick-blank string shift (SL s30-s39: +4 where the old rule gives +2 per backslash; undecoded).
3. A string literal's end reaching a class property initializer (SL s48) and a variable declaration (s50, sister).
4. `new[...]`: an index under an operation named through its bit_select (NW w17, golden `arr.k`).
5. The remaining MiniAmiq clone-listing families (6.5) and a call as a clone's select index (CI c09, stage 1).
6. Carried from the brief, not attempted: BlackBePipeInt #66 (§ pcwElabKeepsClaim207v's claim) and #15272, FuncStructVal
   #747 and the read-site leftovers, N0008, the value encodings, the r11u213 / pass 209 hand-offs, map 13's N0739 N1903
   N1904 N0476 N0477, § opIdxRecvPlainElab215's declines.

## 12. Files

* `drivers/`: env.sh case.sh grid.sh gridaway.sh switches.sh pairs.sh reach205.sh caseaway.py dumpaway.py census.sh
  dscensus.py predict.py bvmirror.sh awayrows.py uvmdist.sh det.sh (copied from r11u218dec's where noted in their
  headers).
* `cases/`: GX SL NW CI (this pass's laws; the first line of each dut.sv names its law, or `r11u220 decode` for a
  control or residue without one), R218 (fresh cases of the landed r11u218 laws), IA and TN (decode only).
* `evidence/`: grid/ census/ sweeps/ movers/ away/ uvm/ det/ decode/. The law sweep's surelog csv is kept without the
  eight fenced row-modes (evidence/sweeps/law_surelog.csv, 1588 of 1596 rows); their verdicts are the gate's and read
  regressions 0 in evidence/sweeps/sweep_law.log.
