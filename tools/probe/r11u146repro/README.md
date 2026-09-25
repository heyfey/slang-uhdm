# r11u146: the module/type ground on the strict axis (pair B, refill after pass 144)

Base `b2199096` (branch matrix-1.87). Files of the ground: `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`src/UhdmExporter.cpp` (no header, no `ExprEmit.cpp` / `EmitHelpers.h` / `StmtEmit.cpp` / `ParamEmit.cpp`
line). The pass also LANDS the analyst pass r11u148's `law.patch` (`tools/probe/r11u148share`, committed at
1d0c82ef after this base; its README's numbers are re-verified below). The slang-fenced tests are written
`FENCED=` here; every driver that reads corpus sources or databases refuses to run without `$FENCED` and
skips those names (word match).

Resume note: this is the second run of the brief. The first run (cut off by an API outage) had written
eight laws. Two of them (its own E and E2 sharing-class laws, `callReadsUnpackedElemNoFold146` and
`genCaBlockLpConstCopy146`) were superseded by r11u148's decoded laws and were dropped; the other six were
re-measured on their grids and kept. Everything below was measured in this run.

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u146_bin/pris.bin` | `6820ba5daec69a13d1ff66dca5fcb356` | worktree at b2199096, system-deps config, `-j 2`; byte-identical to the brief's pristine |
| `/tmp/r11u146_bin/law.final.bin` | `55fd4489e609ab6115060171e2235fe0` | b2199096 + this patch (the final build) |
| `/tmp/r11u146_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator (worktree build = main tree build) |

Every `cmds.txt` of the two sweeps names its binary by path (`/tmp/r11u146_bin/{pris,law.final}.bin`).
Workdirs: `/tmp/r11u146_swP` (pristine) and `/tmp/r11u146_swL` (law), same length.

## 2. Laws (each behind its own switch; `R11U146_OFF=1` drops every law of the pass, r11u148's included)

| law | switch | site | statement |
|---|---|---|---|
| § evalFuncSelectKeepsCall148 | `R11U148_E_OFF` (cases `R11U148_EP_OFF`, `R11U148_EV_OFF`) | ModuleEmit.cpp emitContAssigns + the gen-scope cont_assign emitter | r11u148 class E: a callee body evalFunc cannot reduce (a select of a module parameter in a straight-line body; a select-of-select on a local, read or written with a variable index) keeps the call; the definition share takes the row |
| § genLpUintCaRhsOwnCopy148 | `R11U148_E2_OFF` | ModuleEmit.cpp gen-scope cont_assign | r11u148 class E2: a UINT block-localparam read whole by a plain module-level Lhs gets its own constant copy (adjustSize's `uniquify` clone) |
| § pkgTfSigRangeTopViewConst148 | `R11U148_I_OFF` | TypeEmit.cpp emitSyntaxExpr tfTypeScope | r11u148 class I: an elaborated-package subroutine's signature range binds that listing's parameter constant |
| § modArrayBoundRefArrayPath146 | `R11U146_MODARRBOUND_OFF` | ModuleEmit.cpp emitModuleArray | a reference in a module/interface array's dimension bound is named through the array (`work@dut.m.N`); compileInstantiation hands compileRanges the module_array as parent (map N0030's module_array face) |
| § portInitAssignAtHeader146 | `R11U146_PORTINIT_OFF` | ModuleEmit.cpp emitInstance (both initializer cases) | the synthesized port-initializer assignment and its Lhs sit at the port-list name, not the body declaration (non-ANSI `module dut (b); output reg b = 0;`: golden 1:13) |
| § typeParamStructAtKeyword146 | `R11U146_TPSTRUCTKW_OFF` | TypeEmit.cpp makeTypespec | a type parameter's inline struct default is located at the bare `struct` keyword (compileTypeParameter -> compileTypespec's struct case; no writeNets end-only move); map N0044 |
| § tpDefaultCaLhsUnparented146 | `R11U146_TPCALHS_OFF` | TypeEmit.cpp typeParamDefaultBound20 | writeCont_assign ends with `tps->VpiParent(nullptr)` on the typespec bindVariable finds for a plain-name Lhs: the type-parameter default object of a non-overriding instance loses its parent, so its bound references read no full name (map N0274). Declined when the default is written over another type parameter (`localparam type rt_t = id_t [D-1:0]`: re-resolved per instance) |
| § classTdStructMemberPkgPath146 | `R11U146_CLSTDPKG_OFF` | UhdmExporter.cpp buildClassTypedefTs | a struct typedef declared in a class that a package holds names its member references from the class's full name (`uvm_pkg::uvm_resource_types::access_t::read_count`); map N0096 |
| § castKeyElabNetNoFile146 | `R11U146_CASTKEYFILE_OFF` | UhdmExporter.cpp exportDesign | the elaborated twin of a `T'{key: v}` pattern's leaked key wire has no file (UhdmWriter late-binding mint, as § implicitNetNoFile119's definition twin); map N0011 |
| § escIdPpColumnShift146 | `R11U146_ESCCOL_OFF` | UhdmExporter.cpp ppFold119Line / fileLineCol / nameSpan | Surelog's preprocessor rewrites a space-terminated escaped identifier `\name ` as `#~@name#~@` (SV3_1aPpTreeShapeListener::enterEscaped_identifier) and remaps lines only: the token spans col..col+6+len, every later column on the line reads +4, and a token end inside the swallowed space run reads the column after it. Not on a line that starts inside a continued string literal (`"...\` newline) |
| § portExprOperandAtExpr146 | `R11U146_PORTEXPRLOC_OFF` | ModuleEmit.cpp emitPortExprPort | the operand references of an explicit port expression (`.a({b, c})`) are located at their tokens in the expression |
| § portExprElabDefNets146 | `R11U146_PORTEXPRDEF_OFF` | ModuleEmit.cpp portExprDefRebind146 (elab MultiPort LowConn, its concatenation HighConn, the top's LowConn) | every operand of those concatenations names the DEFINITION's net (a concatenation has no leftmost leaf under § connLeftmostLeafElab139's rule) |
| § unnamedConcatIfaceAnchor146 | `R11U146_UCPLOC_OFF` | ModuleEmit.cpp (both port writers of the unnamed-concat reading) | `module f({a, b}); input a, b;` (read by Surelog as interface port `a b`): signal `b`'s net, port and definition LowConn sit at the header's second identifier; the elaborated LowConn at the positional actual |
| § ucpIfaceInstElabShape146 | `R11U146_UCPIF_OFF` | ModuleEmit.cpp (the unnamed-concat interface_inst) | that interface_inst carries the instantiation's file and line only, and each of its ports' LowConn binds a net the interface mints from the definition port (no full name) |
| § constPathBaseAnyKind146 | `R11U146_PATHBASE_OFF` | TypeEmit.cpp emitSyntaxExpr (hier_path) | § structParamPathBaseAtMember137's placement (base at the next component's token, leaf with no scoped name) holds for ANY non-value base in a typespec range bound or an if-generate condition: interface port, interface instance, package parameter read in its own package, an interface's own parameter. A variable/net base (`$bits(hw2reg.x.d)`) keeps its own token |
| § tfArgTypedefLastWriter146 | `R11U146_TFARGTD_OFF` | UhdmExporter.cpp exportDesign (tail) | compileTfPortList runs `populateCoreMembers(type, type, ts)` on every ANSI argument's typespec, and an enum typedef name answers the shared typedef object: the typedef's span becomes the LAST such argument's type token. A writer outside the typedef's package moves only the elaborated package's object. Declined for a package-qualified argument type, a method of a class inside a package (the UVM enums keep their spans), writers in more than one container, a struct typedef (golden unmoved) |

## 3. Targeted rows (fresh law-sweep csv rows; all `name,mode,status,detail,blocked_by,strict`)

**32 corpus row-modes STRICT_NOTEQUAL -> CMP_EQUAL (strict `equal`), 0 regressions.**

| row-mode(s) | before | after | law(s) (switch attribution, section 6) |
|---|---|---|---|
| ExplictiPorts d / t | differ:line(8) / differ:line(15) | `ExplictiPorts,default,CMP_EQUAL,,,equal` / `...testflags,CMP_EQUAL,,,equal` | portExprOperandAtExpr146 + portExprElabDefNets146 + unnamedConcatIfaceAnchor146 + ucpIfaceInstElabShape146 |
| PortExpr d / t | differ:endline(14) | `PortExpr,default,CMP_EQUAL,,,equal`, same testflags | escIdPpColumnShift146 + portExprOperandAtExpr146 + portExprElabDefNets146 |
| FuncCase d / t | differ:line(8) | `FuncCase,default,CMP_EQUAL,,,equal`, same testflags | tfArgTypedefLastWriter146 |
| IOClassStruct d / t | differ:fullname(3) / (5) | `IOClassStruct,default,CMP_EQUAL,,,equal`, same testflags | classTdStructMemberPkgPath146 |
| InterfArrayBind t | differ:fullname(1) | `InterfArrayBind,testflags,CMP_EQUAL,,,equal` | modArrayBoundRefArrayPath146 |
| PortInitVal d, PortInitVal2 d / t | differ:line(2) | `PortInitVal,default,CMP_EQUAL,,,equal`, `PortInitVal2,{default,testflags},CMP_EQUAL,,,equal` | portInitAssignAtHeader146 |
| FunctionParam, SelectGivenBySelectOnParameterInFunction, func_local_array (d / t) | differ:type(1) | `...,CMP_EQUAL,,,equal` (6 rows) | evalFuncSelectKeepsCall148 |
| SumOfParametersInNestedForLoops d / t | differ:type(1) | `...,CMP_EQUAL,,,equal` | genLpUintCaRhsOwnCopy148 |
| simple_package d / t | differ:depth(1) | `simple_package,{default,testflags},CMP_EQUAL,,,equal` | pkgTfSigRangeTopViewConst148 |
| genvar_iface_struct d / t | differ:fullname(1) | `...,CMP_EQUAL,,,equal` | modArrayBoundRefArrayPath146 |
| param_name_collision_typeparam d / t | differ:fullname(8) | `...,CMP_EQUAL,,,equal` | tpDefaultCaLhsUnparented146 |
| port_chained_type_param d / t | differ:endcol(2) | `...,CMP_EQUAL,,,equal` | typeParamStructAtKeyword146 |
| sat_asserts_seq d / t | differ:line(18) | `...,CMP_EQUAL,,,equal` | portInitAssignAtHeader146 |
| typed_named_pattern d / t | differ:file(5) | `...,CMP_EQUAL,,,equal` | castKeyElabNetNoFile146 |

Surelog 12 (default CMP_EQUAL 399 -> 405, testflags 397 -> 403), uhdm2rtlil 20 (702 -> 712 per mode).
r11u148's README claimed 10 uhdm2rtlil conversions at 0024d365; all 10 re-verified here.

**Downstream rows of the converted uhdm2rtlil tests (fresh, all IDENTICAL, `differs` empty):**
`FunctionParam,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `SelectGivenBySelectOnParameterInFunction,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`SumOfParametersInNestedForLoops,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `func_local_array,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`genvar_iface_struct,IDENTICAL,OK,OK,20,20,,` `param_name_collision_typeparam,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`port_chained_type_param,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `sat_asserts_seq,IDENTICAL,OK,OK,4,4,,`
`simple_package,IDENTICAL,OK,OK,180,180,,` `typed_named_pattern,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.

## 4. Gates (`tests/sweep.sh --jobs 3`, `evidence/sweep_{pristine,law}.txt`)

| gate | pristine | law |
|---|---|---|
| law index | current | current (tests/LAWS.md regenerated) |
| probe vs golden_probe.csv | EQUAL 2308, STRICT_NOTEQUAL 1779; 0/0/0 | EQUAL 2346, STRICT_NOTEQUAL 1741; regressions 0, conversions 38, changes 66 |
| surelog vs golden_surelog.csv | 0/0/0 | regressions 0, conversions 12, changes 18 |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 0/0/0 | regressions 0, conversions 20, changes 28 |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2 | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2; the verdict column equals pristine on all 871 rows |

uhdm-cmp: every mover and every probe case keeps its judge status (no row left judge-equal; every probe
case uhdm-cmp equal).

**Every CHANGE attributed** (`evidence/corpus_changes_firstdiff.txt`, `evidence/probe_changes_firstdiff.tsv`,
drivers `corpcmp.sh` / `probecmp.py`): each changed row's first differing record, pristine vs law.
- Corpus (46 row-modes): 22 have their first difference LATER in the walk (the old head fixed, an unmasking:
  StructParamFieldRange and cva6_struct_param_field `endcol(5) -> fullname(4)` #157 -> #159, SimpleConstraint
  `line(7) -> endcol(4)` #95 -> #184, Rggen `file(9) -> fullname(7)` #101 -> #111, the iface_* PATHBASE rows,
  pkg_nested_struct_param_width #49 -> #194, iface_cfg_mem #256 -> #461); 24 keep the same first record with a
  SMALLER count; none grows, none moves earlier.
- Probe (66 cases): 54 LATER, 12 SAME; the only count that grows is `r10v200repro/v200_5_modmat`
  `fullname(2) -> fullname(3)`, r11u148's documented class-I unmasking: pristine's walk diverged at #66
  (depth), the law's at #77, the first record (#59) unchanged.

**Canaries** (`evidence/canaries_*.txt`, `evidence/ctcan2.txt`): canaries.sh surelog ok=42 changed=10
(the 10 are BasicOh, BuildUVMPkg, Earlgrey_0_1, Scr1SvTests, SimpleConstraint, both modes: exactly the
attributed strict improvements above; pristine reads ok=52), uhdm2rtlil ok=16 changed=0; ctcan2
`EXPECT_UNKNOWN=1` surelog PASS (ok=58), `EXPECT_UNKNOWN=6` uhdm2rtlil PASS.

## 5. Grids (`grid/`, 99 cases; every `dut.sv` names its law in its first line; `evidence/grid_table.txt`)

Goldens from the pinned Surelog with check_probe's arguments (`drivers/grid.sh`). Converted = pristine
STRICT_NOTEQUAL -> law STRICT_EQUAL.

| family | law | cases | converted | notes |
|---|---|---|---|---|
| ma | § modArrayBoundRefArrayPath146 | 7 | 4 | a4/a5/a6 stage-1 (pre-existing) |
| pi | § portInitAssignAtHeader146 | 6 | 3 | p2 ANSI control equal both; p4/p5 stage-1 |
| tp | § typeParamStructAtKeyword146 | 8 | 3 | t4/t5/t7: member ref names (N0084 family, R4 below) |
| tn | § tpDefaultCaLhsUnparented146 | 10 | 6 | k2/k3/k5 controls equal both; k10 `fullname -> line` (next face) |
| ct | § classTdStructMemberPkgPath146 | 7 | 3 | c2 `$unit` control equal both |
| ck | § castKeyElabNetNoFile146 | 3 | 2 | c2 sub-module: a naming residue |
| esc | § escIdPpColumnShift146 | 8 | 4 | e3 (newline), e5 (tab), e7 (macro): Surelog fails, out of the pp rule; e8: a continued string, law == pristine bytes (positive control: an unsuppressed build moved it) |
| pe | § portExprOperandAtExpr146, § portExprElabDefNets146 | 5 | 4 | p3 select operand: stage-1 |
| ucp | § unnamedConcatIfaceAnchor146, § ucpIfaceInstElabShape146 | 3 | 2 | u2 (f as top): stage-1 |
| hp | § constPathBaseAnyKind146 | 9 | 2 | g7 generate-block statement and g10 variable base: controls, unchanged; g4 `col -> fullname` (the package parameter's typespec ref name, ParamEmit) |
| fa | § tfArgTypedefLastWriter146 | 16 | 7 | f13 body-declared input, f14 struct, f6 return type: golden unmoved, law unmoved; f11 package-qualified writer (declined; golden moves only the elaborated copy with the `p::` span); f17 importer module: elaborated-only move |
| ig | (residue of § defNetTypedefEndWrite134) | 17 | 0 | the distinguisher map of IfGenTypeBinding (residue R3) |

Totals: 99 cases, 40 converted, 57 unchanged, 2 changed to a later face; 0 regressed.
r11u148's 49 cases (`tools/probe/r11u148share/cases`, run read-only): 31 movers, each owned by exactly one of
`R11U148_E_OFF` (14), `R11U148_E2_OFF` (9), `R11U148_I_OFF` (8) (`evidence/switches_r11u148_cases.tsv`).

## 6. Movers: prediction, byte verification, attribution

**Prediction** (`drivers/predict.py`, run on the pristine workdir before the byte comparison, fail-closed on
`$FENCED`; `evidence/predict_pristine.tsv`): per-file memoized regexes, one per law face. 2029 of 3315
row-modes carry a face (over-prediction by design).

**byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`): surelog 43 / 960 movers (selfcheck
959 / 960 flagged), uhdm2rtlil 51 / 1608 movers (selfcheck 1607 / 1608), path sets identical
(`evidence/byteverify_*.txt`). Probe: the sweep's 38 conversions + 66 changes.

**Predicted by name**: 90 of the 92 movers (`evidence/movers_predicted.tsv`). The two misses are
Earlgrey_0_1 default and testflags: its sources are reached through a `-f` file list the predictor does not
open (a predictor gap, not a law gap); attributed below to § tfArgTypedefLastWriter146.

**Attribution** (`drivers/attrib.py`, `evidence/attribution.tsv`): each mover re-run from its own cmds.txt
with the law binary under `R11U146_OFF` and under every single switch.
- 83 movers: exactly one switch returns the pristine bytes, and `R11U146_OFF` returns them too. Owners:
  `R11U146_PATHBASE_OFF` 20, `R11U146_TPSTRUCTKW_OFF` 12, `R11U146_TFARGTD_OFF` 9 (FuncCase d/t,
  SimpleConstraint d/t, Scr1SvTests d/t, Earlgrey_0_1 d/t, Rggen d), `R11U146_MODARRBOUND_OFF` 8,
  `R11U146_TPCALHS_OFF` 8, `R11U146_CLSTDPKG_OFF` 6 (IOClassStruct d/t, BuildUVMPkg d/t, Scoreboard d,
  SimpleUVM d), `R11U146_PORTINIT_OFF` 6, `R11U148_E_OFF` 6, `R11U148_E2_OFF` 4, `R11U146_CASTKEYFILE_OFF` 2,
  `R11U148_I_OFF` 2.
- ExplictiPorts and PortExpr (4): multi-law rows; `R11U146_OFF` returns the pristine bytes, each law's
  switch alone moves them (the grid's multi-law cases likewise: the switch SET restores pristine).
- The UVM coin rows (MiniAmiq d/t, SeqDriver d/t, SimpleUVM t): not byte-reproducible run to run. Attributed
  order-blind (`drivers/orderblind.sh`: sorted, path-normalised uhdm-dump): the law lines are the 24
  `uvm_pkg::`-prefixed member reference names of § classTdStructMemberPkgPath146
  (`uvm_component::m_verbosity_setting::*`, `uvm_cmdline_parsed_arg_t::*`, `uvm_resource_types::access_t::*`)
  plus the known 0-or-4-line UINT / vpiDecompile coin (`evidence/uvm_orderblind.txt`: 48 law lines on each
  row, and exactly the 4 coin lines on MiniAmiq d/t and SeqDriver d/t). (An interim build also moved svaunit's multi-line
  `$sformatf` template spans through § escIdPpColumnShift146; the continued-string rule removed it and the
  final sweep confirms.)

**Switch check on the grid** (`drivers/swcheck.sh`, `evidence/switches_grid.tsv`): 58 grid movers; every one
of the 99 cases returns to the pristine bytes under `R11U146_OFF=1`; 50 movers are owned by a single switch,
the 8 multi-law cases (esc/e1, pe/p1-p5, ucp/u1, ucp/u3) by their switch set, each switch of the set moving
them alone. 41 cases do not move.

## 7. Residues, ranked

**Module/type ground (decoded, not landed):**
* **R1 the N0139 member-name family in parameter typespecs** (InterfaceParamOverrideProp d/t,
  iface_nested_param_field, iface_scalar_localparam, iface_struct_field_param_width,
  iface_struct_field_partsel, each d/t: 12 row-modes): golden stores no name on the member's ref_typespec
  inside the parameter's `p::cfg_t` copy (the VPI computes `p::p::cfg_t::HSK`), ours stores the use scope
  `work@tif.CFG.p::cfg_t.HSK`. The prefix is passed to TypeEmit.cpp buildStructTs by ParamEmit.cpp makeParamTs
  (sister's call site; the law would be "the parameter typespec copy's members store no name").
* **R2 hier_path base placement outside TypeEmit** (ComplexHierPath d/t: a generate-block `assign B.x`;
  mem_ff_partial_rsp d/t: a procedural `m[sub.adr]`; portsel_struct_param d/t: a part-select bound on a
  port HighConn; expr_width_cast d/t: a cast typespec in a procedural block): golden puts the first
  component at the second's span there too. ExprEmit.cpp emitExpr's hier_path emission, the ExprEmit
  counterpart of § constPathBaseAnyKind146 (8 row-modes).
* **R3 IfGenTypeBinding d/t**: § defNetTypedefEndWrite134 over-fires. Grid `ig`: golden moves an IMPORTED
  package typedef's end only when the module has NO port list (i5, i7, i10, i12 move; i11 `()`, i14 ANSI,
  i15 non-ANSI keep); a local typedef keeps it under `()` (i13) and moves under an ANSI list (i16). Not
  decoded to a Surelog site; not landed.
* **R4 the type-parameter default's member references** (grid tp t4/t5/t7, pass 144 R4, the N0084 family).
* **R5 tfArgTypedefLastWriter146's declined shapes**: a package-qualified argument writes the ELABORATED
  package's object with the `p::` span (grid fa/f11); package-held class methods write some listings
  (probe r10uvm114repro/g114_f_twopkg, r10buvm27repro/g27_a0_head: the elaborated copies only).
* **R6** the unnamed-concat port as the top (grid ucp/u2, stage-1), a select operand in a port expression
  (grid pe/p3, stage-1), escaped identifiers ended by a tab or a line end (Surelog fails).

**Sister's ground (ExprEmit.cpp / ParamEmit.cpp; call sites named, not touched):**
* **S1 references in select bounds named through the select** (BasicOh, comb_dyn_2d_packed_sel,
  mriscv_bind_sva, packed_struct_array_fifo, YosysBigSimEllip, jeras_tcb_gpio, packed_struct_array_shift,
  mem_packed_2d_byte_write, unpacked_elem_partsel_comb; about 18 row-modes, N0030's remainder): golden
  names `work@x.wr_addr.AW` / `work@dut.wdata.wdata.i` (the select's name inserted, doubled under a
  var_select) where ours names the scope. ExprEmit.cpp emitExpr's part_select / bit_select /
  indexed_part_select bound emission.
* **S2 the imported-package typedef clone's file** (rp32_r5p_alu/bru/mdu/wbu d/t, 8 row-modes): golden
  stamps the importing package's file on the clone (`riscv_isa_i_pkg.sv` with riscv_isa_pkg's line);
  ParamEmit.cpp emitPackage's import clone (pkgImportTsTopFixups).
* **S3** r11u148's D2 (6 row-modes: the two listings' cast targets swapped, `pkgTypedefCastTargetTs140`'s
  drain), G and D (2 each, ParamEmit), ARR (2, procedural binding), C3 leftovers (4): unchanged.
* **S4** the package parameter's typespec reference name in its own package (`ref_typespec` `p` vs empty,
  grid hp/g4 after the base fix): ParamEmit.cpp.

## 8. Fence and ops notes

* While listing the pristine sweep's STRICT_NOTEQUAL heads, `drivers/heads.sh` (then without a fence
  check) ran uhdm-strictcmp on the pristine sweep's databases of every STRICT_NOTEQUAL row, which included
  one fenced test's databases (the sweep itself had produced them). No source of a fenced test was read or
  run; the head line was discarded from `evidence/heads_pristine.txt`, and heads.sh was made fail-closed on
  `$FENCED` before any further use. Reported for the integrator.
* `R11U146_OFF` also drops r11u148's laws (their own `R11U148_OFF` still works alone).

## 9. Files

* `grid/{ma,pi,tp,tn,ct,ck,esc,pe,ucp,hp,fa,ig}/` - the cases.
* `drivers/` - grid.sh (golden + ours + uhdm-cmp + strictcmp per case), swcheck.sh (switch attribution on
  cases), predict.py (mover prediction), attrib.py (mover attribution by switches), orderblind.sh (the UVM
  coin rows), heads.sh / ctx.py / corpcmp.sh / probecmp.py / newdiffs.sh (heads, ancestor chains, first-diff
  classification).
* `evidence/` - sweep_pristine.txt, sweep_law.txt, conversions_changes.txt, corpus_changes_firstdiff.txt,
  probe_changes_firstdiff.tsv, grid_table.txt, switches_grid.tsv, switches_r11u148_cases.tsv,
  predict_pristine.tsv, movers_predicted.tsv, byteverify_surelog.txt, byteverify_uhdm2rtlil.txt,
  attribution.tsv, canaries_surelog.txt, canaries_uhdm2rtlil.txt, ctcan2.txt, heads_pristine.txt.
