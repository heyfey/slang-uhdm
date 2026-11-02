# r11u462 — module/type ground, sv-tests campaign (pass 462)

Base 5d42effa5. Implementer pass on the module/type ground (TypeEmit, ModuleEmit,
UhdmExporter, TaskFuncEmit, uhdm_main). Seven laws, each behind its own switch read through
src/LawSwitch.h (`lawOn(462, ...)`). `R11U462_OFF` drops all seven, and
`R11U462_TRACE=<dir>` logs each firing through `lawTrace(462, ...)`. There is no src/R*.h, no
getenv and no header change. ModuleEmit, ExprEmit, StmtEmit, ParamEmit, EmitHelpers.h,
include/ and uhdm_main.cpp are unchanged.

## sv-tests rows (before -> after)

Both rows were measured by the one full five-stage sweep on the final law binary. Fresh csv
rows from /tmp/r11u462_wd/svtests.csv:

- generated/uvm-examples/uvm_ac_config_db.sv: STRICT_NOTEQUAL differ:fullname(1823) -> **EQUAL**
  `generated/uvm-examples/uvm_ac_config_db.sv,EQUAL,,equal`
  The row converts through § clsInModTdLastWriter462 plus § clsInModEnumLastWriter462. With the
  struct/union law alone (law1), the fullname count drops 1823 -> 660. The rest are the
  enum and class-typedef faces.
- generated/uvm-examples/uvm_id_register.sv: STRICT_NOTEQUAL differ:name(5) -> **EQUAL**
  `generated/uvm-examples/uvm_id_register.sv,EQUAL,,equal`
  The row converts through § cloneRetVarViaRefKeepsHome462.
- generated/uvm-examples/uvm_use_models_pipelined_get_put.sv stays DIFFERENT. Its head moves later
  through all three faces that pass 461 decoded, one law each:
  1. § enumBaseInstFollowsEnum462. The head moves from the mbus_types_pkg param_assign `$bits`
     pairing to the design parameter MBUS_SEQ_ITEM_NUM_BITS (evidence/rows/pipelined_head_law5.txt).
  2. § unitHoistBindsSysCallRhs462. The head moves to `dummy_response` (pipelined_head_law6.txt).
  3. § clsMethodOwnAutomatic462. The head moves to package mbus_pipelined_env_pkg's listing
     (pipelined_head_law7_first40.txt).

  pass 446's localizer (clsloc ALL top) reads 501 -> 500 failures. The `dummy_response` function
  and the mbus_types_pkg#DEF shallow failure are gone. The 500 that remain are the clone-body
  foreach loop-variable kinds (unsupported_typespec where golden has int_typespec,
  `uvm_default_factory::*`, `uvm_init`), which are StmtEmit and the sister's ground. One module
  listing face also remains: module top_hdl's interface instance mbus_pipelined_drv against null.
  Files: evidence/rows/pipelined_clsloc_{pristine,law}.txt and pipelined_law7_clsloc_shallow.txt.
  The uhdm-cmp line count grows 56 -> 1385354 because the new head object is a whole package. The
  head moved later in the walk and no localized failure is new.

The sweep reads `regressions=0 conversions=2 changes=0` with BOTH_REJECT=303 DIFFERENT=10
EQUAL=1930 SLANG_ONLY=19 SURELOG_CRASH=8 SURELOG_ONLY=75 TIMEOUT=1 of 2346. The csv differs from
the master's control /tmp/intr11u460/svtests.csv in the two converted rows only
(evidence/csvdiff_svtests.txt). Open both-accepted rows: 10 DIFFERENT and 0 STRICT_NOTEQUAL.

**Goal 1.** The rejecting rows were re-grepped at the base. Every SURELOG_ONLY, BOTH_REJECT or
SLANG_CRASH detail carries an upstream slang front-end diagnostic. The only details that name a
slang-uhdm path are the five uvm_pkg time-scale rows, which point at the checkout's UVM file. No
row on this ground is stuck at an exporter error. The ground's goal-1 face, the v11u460 case
VZ/vz05 (`class C; real r[] = '{'h1,'h2};`, exit 4 'class array property element'), is written
by § clsDynRealArrPropElem462. It now exits 0 and reads STRICT_EQUAL at 46 objects.

## Laws (switch; sites)

1. § clsInModTdLastWriter462 (`R11U462_CLSINMODTD_OFF`; UhdmExporter typedefParentModel134).
   A class declared in a module or program writes its typedef listing right after its
   definition. In Surelog's UhdmWriter, writeModule and writeProgram run
   writeDataTypes(mod, setParent=true) and then writeClasses over the definition's class
   multimap, by name. writeClass runs writeDataTypes(classDef, c, setParent=true) over the class's
   DataTypeMap, which holds the enclosing definition's imports, and then its nested classes
   (getClassMap). So when that definition is the last module writer, a package struct or union
   typedef the class lists is parented at the last such class. Its member references then read
   `work@m::C::p::s_t::a`, where ours read `work@m.p::s_t.a`.
   Interfaces write no classes, because writeInterface has no writeClasses (CM/cm09 does not move).
   Nested classes are found through the class's `Scopes()`.
2. § clsInModEnumLastWriter462 (`R11U462_CLSINMODENUM_OFF`; UhdmExporter enumTdLastWriter214).
   This is the same writer for enum and class-specialization typedefs. When the module writer that
   § enumImportParentLastWriter180 or § classTdAliasLastWriter214 chose has a class that lists the
   object, the last such class becomes the parent. The base and alias references then read
   ComputeFullName over it: `work@sfr_monitor_bfm::sfr_monitor_concrete::uvm_pkg::uvm_severity`.
3. § cloneRetVarViaRefKeepsHome462 (`R11U462_CLONERETVAR_OFF`; TypeEmit CloneBodyTdRebind180).
   § cloneBodyBareTdAlias180 already exempts a clone function's return variable when the listener
   reaches it right under the function. A clone body that writes its own function name reaches the
   variable first through the ref_obj's actual (`get_base_addr = m_parent_map.get_submap_offset(this);`
   in uvm_reg_map::get_base_addr). The listener's visited set then hands the return variable's ref
   to the rebind, which pointed it at the clone's bare `uvm_reg_addr_t` copy. Golden keeps the
   home's `uvm_pkg::uvm_reg_addr_t` there. The new rule: the return variable keeps the home's
   target whatever path reaches it, but only for a clone function's own Return().
4. § enumBaseInstFollowsEnum462 (`R11U462_ENUMBASEINST_OFF`; UhdmExporter final287, design-final).
   An enum copy's unnamed base typespec lives in the enum's view of its home package. Golden's
   transitive copy has its enum at the direct import package's definition view and its base at the
   home package's definition view. A direct elaborated copy has both at the elaborated view (EB/eb04).
   Ours handed the importer the elaborated listing's import clone, re-stamped the enum's instance
   and left the base at the elaborated home package (grid EB eb02, eb05; uhdm2rtlil
   BitSelectOfParameterPassedToSubmodule checked on golden: base `DEF:prim_pad_wrapper_pkg`).
   Only the measured direction moves: an enum at a definition-view package whose unnamed base sits
   at an elaborated package. The base goes to the definition view of the base's own package, and
   only when every enum sharing that base agrees.
5. § unitHoistBindsSysCallRhs462 (`R11U462_UNITHOISTSYSF_OFF`; UhdmExporter, the binding branch of
   § unitImportHoistsPkgParams146). Surelog's lateBinding reaches the design-level parameter
   hoisted by a `$unit` import before it reads the package param_assign's Rhs, whatever kind
   that Rhs is. So a `sys_func_call` Rhs (`$bits(...)`, `$clog2(...)`) is replaced like a
   constant or an operation. This was pass 459's residue 2, and its BE cases are reshaped as SB/sb_be*.
6. § clsMethodOwnAutomatic462 (`R11U462_CLSMETHODAUTO_OFF`; TaskFuncEmit). A class method, either
   in the body or as an out-of-body definition, written with its own `automatic` keyword carries
   vpiAutomatic:1. Before this law the class scope never got the flag, because slang reports every
   class method automatic. A method with a qualifier in front of `task`/`function` (static,
   virtual, local, protected) abstains: Surelog's class compile misnames those after the class and
   leaves them unmarked (TA/ta03, ta05).
7. § clsDynRealArrPropElem462 (`R11U462_CLSDYNREAL_OFF`; UhdmExporter classAssocElemVar). This is
   goal 1. The element of a dynamic, queue or associative class property of floating type gets
   golden's objects:
   - `real`: a real_var whose real_typespec sits at the keyword.
   - `shortreal`: a short_real_var with no typespec.
   - `realtime`: a time_var with a time_typespec.
   - A typedef or type parameter standing for `real`: a real_var.

   The old path exited 4.

All seven laws follow golden's behaviour: no object, field or binding is invented where Surelog's
database lacks it.

## Grid (49 case dirs; evidence/grid_pris_vs_law.txt)

All cases ran with drivers/runcase.sh: Surelog with check_probe.py's flags, ours with
`dut.sv --single-unit --nobuiltin`. Every exit code is recorded. Pristine is the main tree's
build, md5 77a3babefa0c97023405689e1ebec60c, equal to the worktree's own pristine build. The law
binary is /tmp/r11u462_law8.bin, md5 5764eb53e7e66e5a43aadcd24e58bc78.

- **CM (§ clsInModTdLastWriter462, 13 cases):**
  - cm01, cm04, cm05, cm08, cm10 (a nested class), cm11 (a parameterized class), cm12 (two modules
    with classes) and cm13: STRICT_NOTEQUAL fullname -> STRICT_EQUAL.
  - cm02 and cm03 (a later module is the last writer): byte-identical controls.
  - cm06 and cm07 (programs): NOT_EQUAL 344 on both binaries, the older program-listing face.
    cm07's class-member names now equal golden's.
  - cm09 (an interface class): a byte-identical control.
- **CE (§ clsInModEnumLastWriter462, 6 cases):**
  - ce01 (an enum), ce02 (an enum alias), ce03 (a class specialization typedef) and ce05 (a nested
    class): STRICT_NOTEQUAL fullname -> STRICT_EQUAL.
  - ce04 (a later module writer): a control.
  - ce06 (an interface class): NOT_EQUAL 105 on both, unchanged.
- **RV (§ cloneRetVarViaRefKeepsHome462, 5 cases):** all byte-identical and STRICT_EQUAL on both
  binaries. Toy packages do not mint the shared clone return that the UVM rows mint, as pass 460
  also found. The law is measured on the row (law4 runner: id_register EQUAL) and on the trace.
- **EB (§ enumBaseInstFollowsEnum462, 5 cases):**
  - eb02 and eb05 move bytes: the base instance goes TOP -> DEF as in golden, and both stay
    STRICT_EQUAL.
  - eb03 and eb04 are byte-identical controls.
  - eb01 is NOT_EQUAL 160 on both, a ParamEmit transitive-parameter face (sister).
- **SB (§ unitHoistBindsSysCallRhs462, 9 cases):**
  - sb_be14, be20, be21, be22, be25: NOT_EQUAL 56 -> STRICT_EQUAL.
  - sb04: 56 -> 50 lines, with the head moved from the `$bits` call to a package-function body fold
    that is ExprEmit's (sister).
  - sb01 moves bytes at the same head, a function-body fold (sister).
  - sb02 (a module-body import, no hoist) and sb03: byte-identical controls.
- **TA (§ clsMethodOwnAutomatic462, 5 cases):**
  - ta01, ta02 (out-of-body) and ta04 ($unit class): NOT_EQUAL -> STRICT_EQUAL.
  - ta03: 126 -> 128 at the same head, the qualifier misnaming face, with every vpiAutomatic now
    golden's.
  - ta05 (qualifiers only): a byte-identical control.
- **CR (§ clsDynRealArrPropElem462, 6 cases):**
  - cr01, cr02, cr04 and cr05: exit 4 -> exit 0 and STRICT_EQUAL.
  - cr06 (`typedef real r_t; r_t r[];`): exit 4 -> exit 0, NOT_EQUAL 36. Golden's per-use
    `r_t` copy aliases the class listing object.
  - cr03: still exit 4, because of `real m[2][]`, a fixed-of-dynamic class property, which is
    another goal-1 face.
- **The v11u460 case VZ/vz05:** exit 4 -> exit 0 and STRICT_EQUAL.

Switch checks (drivers/switchcheck.sh, evidence/switchcheck.txt): `R11U462_OFF` gives pristine's
md5 and exit code on 49 of 49 dirs. Each moved dir goes back to pristine under its own law's
switch. The exceptions are cm01 and cm12, which need both CLSINMOD switches: each alone gives a
third md5.

## Gates (the one full five-stage sweep, /tmp/r11u462_wd, final binary, trace on)

| stage | result |
|---|---|
| probe | EQUAL 4024, STRICT_NOTEQUAL 63; regressions=0 conversions=1 changes=0. **CONVERSION** `r10v136repro/v136_d_homes STRICT_NOTEQUAL differ:fullname(18) -> EQUAL`, fresh row `r10v136repro/v136_d_homes,EQUAL,,equal` (§ clsInModTdLastWriter462, traced) |
| surelog | default 480 + 4 CMP_NOTEQUAL, testflags 474 + 4; regressions=0 conversions=0 changes=0; the csv differs from the control only in the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 in both modes; 0/0/0; the csv is identical to the control |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not identical and not excused=0; the csv is identical to the control |
| svtests | regressions=0 conversions=2 changes=0 (above) |

The corpus command exited 0 and the law index is current. The sv-tests stage was run through the
main tree's tests/sweep.sh, because the worktree's UVM folder is empty. It exits 1 only on the
main tree's stale law index.

Canaries (evidence/canaries.txt): ok=52 changed=0 and ok=16 changed=0, and both ctcan2 checks PASS.
Binary audit, fence-filtered:
- surelog: 1523 of 1573 records name /tmp/r11u462_law8.bin; the other 50 hold only a Surelog line.
- uhdm2rtlil: 1740 of 1740.
- sv-tests: 2346 of 2346.

## Movers (predicted, then attributed)

The prediction was made before the sweep from the master's pristine control databases
(evidence/prediction_from_pristine_dbs.txt, tools/predict.cpp, fence-filtered list of 7484
databases). It listed the database signature of each law:

- ENUMBASE in 39 databases:
  - surelog BlackBePipeInt, GenScopeHierPath, HierPathOverride, IndexedSelectHex,
    MultiConcatValueSize and ParamElabMulti (d/t);
  - uhdm2rtlil and downstream BitSelectOfParameterPassedToSubmodule (+InGenFor,
    +InGenForOfSubmodule), ParameterPassedTo3TimesNestedSubmodule,
    ParameterPassedToSubmoduleInGenscopeOfSubmodule, ParameterPassedToSubmoduleOfSubmodule,
    rp32_r5p_wbu and SubmoduleInGenScopeWithGenScopeParametrizedByParameterFromTopModule (d/t);
  - probe t42a;
  - sv-tests rsd and pipelined_get_put.
- CLSINMOD in 3 probe cases plus ac_config_db.
- RETVAR in id_register.
- AUTO in probe t34e_t and pipelined_get_put.
- SYSF in rsd and pipelined_get_put.

byteverify against the control (evidence/byteverify.txt, SELFCHECK on):

- **surelog 14 of 962.** These are the 12 predicted ENUMBASE row-modes plus one fenced row in both
  modes. That fenced row was not in the prediction because the census list is fence-filtered. The
  trace attributes it to § enumBaseInstFollowsEnum462 and its status is unchanged. Every surelog
  mover keeps its csv row, so the strict column is unchanged. BlackBePipeInt d/t stays CMP_EQUAL
  at its recorded object counts.
- **uhdm2rtlil 16 of 1608** and **downstream 8 of 805.** These are exactly the predicted ENUMBASE
  rows, all firing § enumBaseInstFollowsEnum462 once, with unchanged verdicts.
- **MiniAmiq d/t** fires § cloneRetVarViaRefKeepsHome462 3 times and does NOT move bytes. Neither
  SeqDriver nor any other UVM corpus row moves.
- **probe:** comparing path-normalized uhdm-dumps of all 4087 databases against the control reads
  4086 same and 1 different: v136_d_homes, the conversion. t34e_t fires
  § clsMethodOwnAutomatic462 on the class's own `f1`, which golden and ours both drop from the
  listing, so no byte moves. The predicted candidates g97_a4, g97_a5 (CLSINMOD) and t42a
  (ENUMBASE) do not fire. The prediction reads each database's signature only, not the laws'
  guards; why each guard declines was not decoded.
- **sv-tests (evidence/trace_summary.txt, svtests_kept_movers_strict_nocanon.txt):**
  - Firing rows: ac_config_db (CLSINMOD 8 + ENUM 96), id_register and 16 other uvm-examples rows
    (§ cloneRetVarViaRefKeepsHome462; the EQUAL ones stay EQUAL), pipelined_get_put (four laws)
    and rsd (SURELOG_CRASH, no golden, status unchanged).
  - Of the master's 33 kept databases, 31 are re-kept and differ in raw bytes. 29 are
    STRICT_EQUAL to the control under `uhdm-strictcmp --no-canon`; this is the serialization-order
    variance passes 455 to 460 recorded. The other two are rsd and pipelined_get_put, which are
    law movers.
  - The two converted rows' databases are not kept by the harness.

## Residues (ranked; all wrong on pristine too, none moved away)

1. uvm_use_models_pipelined_get_put: about 500 clone-body foreach loop-variable kinds (StmtEmit,
   the sister's ground, report only), and module top_hdl's interface instance against null. The
   second face is ModuleEmit's elaborated listing on this ground, not decoded.
2. uvm_param_vif_config_db: golden's class-local `typedef sfr_config_object #(...) this_t` is a
   class_typespec named this_t. It aliases tb_params_pkg::SFR_cfg_t with instance tb_params_pkg,
   and its type_parameters named UVM_ALL_ON and UVM_CHECK_FIELDS are typed by unsupported_typespec
   SFR::sfr_addr_width. That is a Surelog specialization artefact. Ours is the plain
   class_typespec sfr_config_object under type_id.T. Not decoded to a rule.
3. uvm_many_to_one: at its ParamEmit head, the sister's ground.
4. easyUVM and the three uvm_scoreboard rows; p733, p737 and tnoc, which await the user's decision.
5. Faces the grid shows on this ground:
   - a class in an interface, which Surelog writes as a $unit-level class (CM/cm09, CE/ce06);
   - the program listing (CM/cm06, cm07);
   - qualifier-prefixed class methods, which Surelog misnames after the class (TA/ta03, ta05);
   - a typedef'd real element's per-use copy (CR/cr06);
   - the fixed-of-dynamic class property `real m[2][]`, still exit 4 (CR/cr03).
6. The carried lists of passes 460 and earlier.

## Sister-ground faces (reported, not written)

- **StmtEmit:** the clone-body foreach loop-variable typespec (golden int_typespec, ours
  unsupported_typespec) behind pipelined_get_put's 500 localized failures, and behind
  many_to_one's 1200.
- **ExprEmit:** golden folds a package parameter read inside a package function body to a constant
  where ours keeps the reference or operation (SB/sb01, sb04).
- **ParamEmit:** env_pkg's transitive listing of an imported package parameter (EB/eb01), and
  many_to_one's group base.

## Process

- The pristine reading is the master's control at /tmp/intr11u460. No pristine sweep was run, and
  the worktree's pristine build was used only to confirm its md5.
- Intermediate binaries law1 to law7 got only case runs and the targeted runner calls on the five
  uvm-examples rows (evidence/rows/runner_law*.csv), each after a quiet check.
- One full sweep was run, on law8.
- Two intermediate debugging builds carried a temporary stderr print behind an environment check.
  The print was removed before law8, and law8 is built from the patch's code.
- The fence list was read into a file by a program and never printed. Every tree-wide list was
  filtered on it, and fenced names are masked in the saved logs. No fenced test was opened, named
  or run outside the standard sweep.
- No other agent's process was touched.
