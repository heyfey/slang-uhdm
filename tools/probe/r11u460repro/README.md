# r11u460 — pass 460, module/type ground (implementer)

Base 8acef805 (pass 458). Ground: src/UhdmExporter.cpp, src/ModuleEmit.cpp, src/TypeEmit.cpp.
TaskFuncEmit.cpp, uhdm_main.cpp and every sister file (ExprEmit, EmitHelpers.h, StmtEmit,
ParamEmit) are unchanged. No src/R*.h, no getenv, no header change. Each law is read through
src/LawSwitch.h as `lawOn(460, "R11U460_<LAW>_OFF")`. `R11U460_OFF=1` drops the whole pass, and
`R11U460_TRACE=<dir>` logs every firing through `lawTrace(460, ...)`.

## Verdict per targeted row (sv-tests, fresh rows from the one sweep on law12)

| row | base | law12 |
|---|---|---|
| generated/uvm-examples/uvm_id_register.sv | DIFFERENT (uhdm-cmp 85 lines) | **STRICT_NOTEQUAL differ:name(5)**, uhdm-cmp EQUAL (CONVERSION) |
| generated/uvm-examples/uvm_many_to_one.sv | DIFFERENT (104) | DIFFERENT, same head object (now printed with its REQ listing, 168 lines); localized failures 1250 -> 1250 |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT (230) | DIFFERENT (230); localized 1576 -> 1574 |
| generated/uvm-examples/uvm_ac_config_db.sv (sister's) | DIFFERENT (64) | DIFFERENT (64); localized 2 -> 0 |
| uvm_use_models_pipelined_get_put (sister's) | DIFFERENT (56) | DIFFERENT (56), unchanged |

The fresh row: `generated/uvm-examples/uvm_id_register.sv,STRICT_NOTEQUAL,differ:name(5),differ:name(5)`.

The sv-tests stage was run against the base's golden (results/golden_svtests.csv at 8acef805). It
reads `regressions=0 conversions=1 changes=0`: BOTH_REJECT 303, DIFFERENT 11, EQUAL 1928,
SLANG_ONLY 19, STRICT_NOTEQUAL 1, SURELOG_CRASH 8, SURELOG_ONLY 75, TIMEOUT 1 of 2346. The main
tree has since landed pass 459, which promoted uvm_ac_config_db to STRICT_NOTEQUAL. That row is
DIFFERENT on this base binary, which lacks pass 459, so the sweep used the base golden as its
baseline (evidence/sweep_svtests.log).

## Goal 1

There is nothing on this ground. The fresh csv has 75 SURELOG_ONLY rows, and every one carries a
slang front-end `error:`. Five rejecting rows mention a slang-uhdm path: biquad_example,
uvm_c_stimulus_bl_example, uvm_register_mem_example, uvm_register_spi_bl_tb and
uvm_tb_build_bl_tb. Each of those carries upstream slang's uvm_pkg time-scale diagnostic. No row
carries the exporter's own unsupported text.

## The laws (all in the one sweep binary law12, md5 53869f80635c0d3470cf7ac0da0b1dbc)

1. **§ pkgTdForeignSpecParams460** (UhdmExporter, design-final; R11U460_PKGTDSPEC_OFF).
   - A PACKAGE typedef of a specialization of a generic class declared outside that package
     carries the written specialization: one type_parameter and one param_assign per ORDERED
     argument, built by emitClassPropSpecParams163's transcription of
     compileDatastructureTypespec's ClassDefinition branch. Examples are apb_agent_pkg's
     `typedef uvm_sequencer #(apb_seq_item) apb_sequencer;` and the case `package a; typedef
     S #(a_item) a_seqr;`.
   - Why: Surelog reaches that branch only when getClassDefinition misses typeName,
     <component>::typeName and <parent>::typeName. For a package typedef, the component probe
     hits only for the package's own class. That is the r10sd1 grid's disclosed b4/b15/b16 face.
   - The typedefs that ParamEmit's base/alias passes made clones of this object are Surelog's
     copies of the written object, so each one takes a deep copy of the listing. This covers the
     same-package and importer clones, uvm_default_sequencer_type and the class-nested this_type.
     The copied param_assign sides are copies too (UHDM's param_assign::DeepClone), and their
     full names are left to the parent chain.
   - This was id_register's uhdm-cmp head: golden's apb_agent_pkg::apb_sequencer has REQ ->
     class_typespec apb_seq_item, and ours had no listing.
   - Cases SQ/sq02 to sq05: NOT_EQUAL -> STRICT_EQUAL. sq06: NOT_EQUAL 121 -> STRICT_NOTEQUAL
     fullname, behind a parent face that is not this law's. sq01: 85 -> 17 lines; its rest is
     ParamEmit's import-clone alias, a sister-ground face.
2. **§ clsNestedSpecCloneHomeInst460** (R11U460_NESTCLONEINST_OFF).
   - A class-nested typedef that joined that group keeps the declaring package's TOP view as its
     vpiInstance. The example is uvm_sequencer's `typedef uvm_sequencer #(REQ,RSP) this_type`,
     which golden puts at 30:9 with instance apb_agent_pkg TOP. Ours copied the base's instance
     after the importers had re-stamped it to uvm_tb_pkg.
   - The join is § classNestedClassTdJoinsPkgGroup50.
   - Only unqualified (class-nested) names are covered. A listing copy that a class holds
     (b_pkg::B_sequencer under class test) keeps its own instance. law11 got that wrong on
     many_to_one, and law12 fixed it before the sweep. Case SQ/sq06 is the control.
   - Cases: sq05 and the strict walk on id_register.
3. **§ specGroupAliasFlatRoot460** (R11U460_SPECALIASROOT_OFF).
   - In such a group every member aliases the base itself. ParamEmit chained the importer's
     name-later clone to its name-first one: uvm_virtual_sequencer -> uvm_default_sequencer_type
     -> apb_sequencer. Golden points each one at apb_sequencer.
   - Without this law, id_register's strict walk diverged at uvm_virtual_sequencer's REQ.
   - Only for roots that law 1 listed.
4. **§ oobCopyCallBindsBodyHomeClone460** (UhdmExporter, inside § cloneBodyCallBindsHomeTopTf446;
   R11U460_OOBCOPYCALL_OFF).
   - An importer's copy of an OUT-OF-BODY class method whose class lives in another package than
     the callee's home binds the class-home package's TOP clone of the callee. That is what the
     method binds at home (§ oobInheritedCallBindsOwnPkgClone455).
   - Golden: uvm_tb_pkg's copies of apb_seq_item::do_copy, do_compare and
     apb_agent_config::get_config bind apb_agent_pkg TOP's uvm_report_enabled, the one holding
     class_var cs. § 446 had re-pointed them to uvm_pkg TOP.
   - This is pass 455's reported face: "§ 446 relink deciding by the target's package group
     rather than the body's class home". The v11u455 case VG/vg01 and the residue OC/oc07 are
     the same face.
   - Effect: r11u455 OC/oc07's s-copies now bind q#TOP exactly as golden does (link census). OB:
     ob01 is that shape, STRICT_EQUAL on both binaries with bytes moving toward golden; ob03 (a
     task callee) goes 756 -> STRICT_EQUAL. ob02, ob04 and ob05 are controls whose copies golden
     does not write, unequal on both binaries at the same head. uvm_slave_agent's env_pkg copies
     of apb_slave_seq_item::do_copy and do_compare go uvm_pkg#TOP -> apb_slave_agent_pkg#TOP,
     which is golden's target.
5. **§ ifcOwnTdTransitiveTds460** (ModuleEmit; R11U460_IFCOWNTRANS_OFF).
   - Covers § ifcBodyImpTransitiveTds450's abstention, the r11u450 residue IT/it02: an interface
     whose body wildcard-imports a package with typedefs of its OWN as well as transitive ones
     lists both in one name-sorted walk, as a module does.
   - Golden apb_monitor_bfm, which imports apb_agent_pkg only, lists 129 typedefs. Ours listed
     apb_sequencer plus the import_typespec.
   - This interface takes the module branch instead of the per-package interface branch.
   - Cases: IF/if01 (= it02) 336 -> STRICT_EQUAL; if03 388 -> STRICT_NOTEQUAL fullname (residue 3).
6. **§ ifcOwnTdTransitiveTfOrder460** (R11U460_IFCTFORDER_OFF).
   - The same interface lists its imported packages' subroutine groups as a module does: the
     module's hoist of materialized groups, in order.
   - Golden apb_driver_bfm has uvm_pkg's free functions, then uvm_pkg's out-of-body methods, then
     apb_agent_pkg's group. Ours placed apb_agent_pkg's group between uvm_pkg's two runs, and the
     strict walk diverged at get_uvm_seeding against do_copy.
   - Case IF/if02: STRICT_NOTEQUAL name -> STRICT_EQUAL.
7. **§ clsArrPatBasedLitElemW460** (UhdmExporter: the dynamic/queue/assoc/concat carrier of
   § assocPropPatternInitRidesElem31 and the fixed-array pattern) and **§ modArrPatBasedLitElemW460**
   (TypeEmit: the module fixed-pattern, concatenation and dynamic carriers). Both use
   R11U460_PATBASEDW_OFF.
   - These are the based-literal half of clause (3). CompileHelper::adjustSize sets
     `size = Bits(element)` for every non-DEC constant.
     - A HEX or OCT literal takes the element width, sized or not: golden 'ha0, 8'h1, 64'h9 and
       4'hf are 32 in an int array; 32'hff and 'o3 are 8 in a byte array.
     - An UNSIZED binary literal also takes it ('b11 is 8).
     - A DEC literal keeps its own width ('d5 stays -1, 16'd3 stays 16).
     - A sized binary literal keeps its own typespec's width (4'b1 stays 4).
     - Not modelled, so the law abstains: x/z values ('hx is measured unchanged at -1), and an
       unsized binary worth 1, which adjustSize re-encodes as a mask.
   - On id_register: regmodel_pkg.sv 45 (class property) and reg_dut.sv 39 (module variable)
     `int id_register_value[] = '{'ha0, ...}`.
   - Cases: UZ/uz01 to uz06 all go 28 -> STRICT_EQUAL.
   - Helper: basedLitTakesElemW460, defined in UhdmExporter.cpp and declared in TypeEmit.cpp.
8. **§ implicitNetAfterForwarded460** (ModuleEmit, beside § ifaceConnNetAfterForwarded452;
   R11U460_IMPNETAFTER_OFF).
   - A definition's IMPLICIT wire is a lateBinding mint. This covers a port connection's
     `.b(y)` and a continuous assignment's `assign z = c;`.
   - Such a wire follows the forwarded block of imported packages' unresolved names, keeping the
     implicit wires in their own order.
   - Golden hdl_top lists PWRITE 38:21 after m_check_on_read. Ours listed it after PSLVERR.
   - It fires only when the forwarded block is non-empty, which is § 452's gate. Ports never move.
   - Cases: IC/ic01, ic02 and ic05 go 32 -> STRICT_EQUAL. ic04 (no forwarded block) is a
     byte-identical control. ic03 goes 32 -> 2230: the head moved later, to the elaborated
     instance array's missing implicit net y3, which pristine also lacks (residue 4).

Switch check (evidence/switchcheck.txt): R11U460_OFF gives pristine's bytes and exit code on 25 of
25 case directories. Each law's own switch restores pristine on its own cases. NESTCLONEINST moves
only sq05 and sq06.

## Gates (one full five-stage sweep on law12, workdir /tmp/r11u460_sw, trace on)

- **probe**: EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087. regressions=0 conversions=0 changes=0, and
  the csv is identical to the control.
- **surelog**: default 480 / testflags 474 CMP_EQUAL. 0/0/0. The csv differs from the control
  only in the two LowMem log-path texts.
- **uhdm2rtlil**: 803/1/67 in both modes, 0/0/0, csv identical.
- **downstream**: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0. The csv is
  identical to the control.
- **svtests**: as above. regressions=0, conversions=1 (uvm_id_register), changes=0.
- The corpus stage exited 1 on the law index alone (tests/LAWS.md was stale while case dirs were
  being added). The index is regenerated in the patch.
- **canaries**: ok=52 (surelog) and ok=16 (u2r). ctcan2 PASS on both (surelog ok=58 with
  EXPECT_UNKNOWN=1, u2r with EXPECT_UNKNOWN=6).
- **byteverify** (law workdir against the master's control /tmp/intr11u458, evidence/byteverify.txt):
  35 movers of 3408.
  - Self-check flags 3406 of 3408. The harness wants all, but two control databases are
    byte-identical to each other in the control itself (the known duplicate pair, as in pass 457).
  - **MiniAmiq default and testflags** move bytes under § ifcOwnTdTransitiveTds460 and
    § ifcOwnTdTransitiveTfOrder460: interface svaunit_vpi_interface takes the module branch. The
    path-normalized uhdm-dump of law and control is IDENTICAL (1974352 lines). The interface's
    typedef and task_func name listings equal golden's on both binaries. The move is object
    creation order only. Both rows stay CMP_EQUAL and strict equal, so **the MiniAmiq determinism
    hashes must be re-recorded at landing**.
  - The 33 sv-tests movers split two ways:
    - 6 fire the trace and move: id_register (conversion), many_to_one, param_vif_config_db,
      ac_config_db, slave_agent and slave_agent_multi_seq_item. The two slave rows stay EQUAL,
      moving the env_pkg copies' uvm_report_enabled links toward golden.
    - 27 do not fire. 25 of them are dump-identical to the control after path normalization
      (evidence/svtests_nonfiring_movers_dumpcheck.txt): the serialization-order variance pass
      457 recorded. rsd (SURELOG_CRASH) and tnoc (DIFFERENT) were not dumped because their dumps
      are too large. Neither fires a law, and their statuses are unchanged.
  - uvm_ef_vif_config_db and uvm_vif_config_db fire § oobCopyCallBindsBodyHomeClone460 but their
    bytes do not move (the link was already the target).
- **Trace** (evidence/trace_sweep.txt): firings only on MiniAmiq d/t (the two interface laws), the
  8 sv-tests uvm-examples rows named above, and nothing in probe, uhdm2rtlil or downstream.
- **Prediction**: the probe census before the sweep covered the 51 probe dirs holding a
  `typedef C #(` spelling. It ran law12 against R11U460_OFF=1, with SQ/sq03 as the positive
  control, and found 0 movers. The sweep's probe stage agrees. MiniAmiq was NOT predicted: no
  interface-shape census was run before the sweep. The trace named it, and it moved only object
  order.

## Process notes (slips, none affecting a measurement)

- One single-row runner call (law2, uvm_id_register) started while the sister verifier v11u459's
  sv-tests stage was live, before this pass had a quiet check. Timing only.
- My first quiet-check waiter matched its own parent shell's command line and never released. I
  stopped it by task id and rewrote it to skip its own ancestors (drivers/quiet.sh).
- Two OB case directories were edited after their Surelog golden was built. The runner keys the
  golden on the directory, so the stale goldens were evicted and rebuilt before any reading in
  this README.
- The fence list was read into a file by a program and never printed. Every tree-wide file list
  was filtered on it before opening. No fenced test was named, opened or run.

## Residues, ranked

1. **uvm_id_register differ:name(5)**: one object.
   - The class view of uvm_reg_map::get_base_addr (class_defn uvm_reg_map in uvm_pkg TOP) has a
     return bit_var whose per-use bit_typespec uvm_reg_addr_t aliases an unparented copy named
     bare `uvm_reg_addr_t`. Golden aliases the listing object named `uvm_pkg::uvm_reg_addr_t`
     (hvl_top's).
   - Ours shares that per-use copy with importer-clone locals (apb_agent_pkg's
     uvm_vreg_field::write segoff, uvm_vreg::read addr, ...). Golden deep-copies those, and their
     bare names match ours.
   - Only get_base_addr is affected, whose body assigns to the function name. set_coverage's
     class view is right.
   - Not decoded to its writer: R11U446/449/450/452/453/455/457/458_OFF each leave it as is.
     The toy BT shape (class method returning a package typedef, body assigning to the function
     name, importer package) does not reproduce it.
2. **uvm_many_to_one**: the head is golden's naming and parenting of the group base,
   `b_pkg::A_sequencer` under class_defn work@test (ParamEmit's import-clone base naming,
   sister ground).
   - This pass made the listing right: REQ, the param_assign and the flat aliases.
   - Behind it sit about 1200 foreach loop-variable typespec failures (int_typespec against
     class_typespec): the swapForSpecifiedVar face on StmtEmit, sister ground.
   - The same parent face makes SQ/sq06 STRICT_NOTEQUAL fullname.
3. **§ ifcOwnTdTransitiveTds460's interface re-scope**: the module branch does not write the
   interface branch's `work@<iface>.<pkg>::<typedef>` full name on an own typedef's alias
   reference (IF/if03: golden work@mon.a::wrap_t, ours work@top.a::wrap_t; strict fullname(7),
   judge-equal).
4. **IC/ic03**: an instance array's implicit connection net y3 is missing from the elaborated
   module (pristine too). The cmp head moved there from the net order.
5. **uvm_param_vif_config_db**: 368 localized `cs` failures. These are uvm_report_enabled clones
   in sfr_agent_pkg / tb_params_pkg copies, which this law binds only for out-of-body copies.
   Also this_t (65+21), hdl_top enum copies UVM_MEDIUM/UVM_NONE (76) and others.
6. **UZ/uz03's extra `*` STRING constant**: an associative `'{"k": ...}` initializer (ours lists
   two, golden one; judge-equal).
7. The carried lists of passes 458 and earlier (r11u458 README residues), unchanged.

## Sister-ground faces (report only)

- ParamEmit's import-clone group (pkgImportClassTd50) does two things here:
  - It names the base of a cross-package specialization group by the importer
    (golden b_pkg::A_sequencer, ours a_pkg::A_sequencer) and parents it at the module where golden
    parents it at the $unit class.
  - It does not alias the module's direct-import copy of a group (SQ/sq01: golden u::dflt_t at
    12:11 aliasing a::a_seqr, ours at 7:11 with no alias).
- StmtEmit: many_to_one's foreach loop variables (the int_var / class_typespec kinds of pass
  456's decode).

## Files

- cases/SQ (6), OB (5), IF (3), UZ (6), IC (5). Each case's first line names its law.
- drivers/runcase.sh: golden + ours per case, printing rc, cmp lines and the strict verdict.
- drivers/switchcheck.sh, runrow.sh, quiet.sh, sweep.sh.
- evidence/: grid.txt, switchcheck.txt, sweep_corpus.log, sweep_svtests.log, byteverify.txt,
  svtests_nonfiring_movers_dumpcheck.txt, trace_sweep.txt, uvm_id_register_strict_law11.txt,
  open_rows_before_after.txt, and tools/*.cpp (the localizer helpers used here: prm, lst, tsc,
  who, alias, bare2, instd, cdc, ifl, mnets, consts).
