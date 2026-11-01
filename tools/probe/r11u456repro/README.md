# r11u456: module/type ground, sv-tests campaign (pass 456)

Implementer pass on base 7b76f0685 (pass 454). Pass 455 (the sister, ground A)
landed while this pass ran, at e8b7d96d3. This patch is cut against
7b76f0685 and touches none of pass 455's files.

No sv-tests row converts on this base. The three laws close faces that sit
behind pass 455's cs-clone head on the sfr rows, plus one sister-reported face:

| row | base 7b76f0685 | law8 alone | law8 + pass 455 (experiment exp2) |
|---|---|---|---|
| generated/uvm-examples/uvm_ef_vif_config_db.sv | DIFFERENT (cs clone, 29 lines) | DIFFERENT (same head) | uhdm-cmp EQUAL, STRICT_NOTEQUAL differ:fullname(427) |
| generated/uvm-examples/uvm_ac_config_db.sv | DIFFERENT (cs clone, 29 lines) | DIFFERENT (same head) | DIFFERENT, head moved later (17 -> 64 lines) |
| generated/uvm-examples/uvm_vif_config_db.sv | DIFFERENT | DIFFERENT | EQUAL (pass 455's conversion, unchanged) |

Before these laws, pass 455's binary read ef_vif at the unbound `reset` head
(29 lines). Pass 455's own experiment read differ:fullname(1048), and
ac_config_db at the extra this wire (17 lines).

## Laws (switches through src/LawSwitch.h; R11U456_OFF restores pristine's bytes on all 20 case dirs)

1. § ifcTaskFixupWalksWait456 (ModuleEmit, the instantiated interface's
   subroutine binding walk; R11U456_IFCWAIT_OFF). The walk now also enters
   these statements:
   * `wait` (its condition and its statement);
   * `fork` branches;
   * immediate assertions (expression, pass and else statements);
   * foreach bodies;
   * the arguments of system and user task and function calls;
   * the index of a bit select and the expressions of a var select.

   A name the interface does not declare binds the innermost enclosing foreach
   loop variable. An interface variable of the same name wins, as in golden.

   Decoded from pass 455's report: Surelog binds the shared definition-view body
   of an instantiated interface's subroutine during elaboration, whatever
   statement holds the reference. sfr_master_bfm::execute's `wait(reset == 0)`
   reads `reset`. Golden binds it to work@hdl_top.SFR_MASTER.reset. Ours left it
   unbound.

   Trace: `<iface> <stmt kind> line:col`, plus `loopvar <name> line:col`.
2. § thisFirstGroupOrigToo456 (TypeEmit, the late `this` wire;
   R11U456_THISFIRSTORIG_OFF). The clone-to-original rule of
   § thisNetPerListingModule452 applied only to the second and later
   definitions. It now applies to the first one as well. When the first
   definition that lists a hit lists an import-group clone (an out-of-body
   method that its import forwards), golden binds the class-parented original
   at the same location to that definition's wire and leaves the clone
   unbound. A later definition that lists the original directly then finds it
   bound and mints no wire.

   sv-tests uvm_ac_config_db is the example. hdl_top lists no hit. hvl_top's
   `this@968:29` binds sfr_agent_pkg's sfr_monitor::build_phase `this@56:18`,
   and sfr_test_pkg's clone stays unbound. Ours bound the clone to hvl_top's
   wire and the original to a second wire, work@sfr_master_bfm.this, minted at
   56:18. Golden has no such wire (pass 455's report).

   The same rule holds when the first definition is the only one listing a hit
   (TF/tf04). Its wire is then placed with the stream rank of § 452. Only the
   first group's listed hits are replaced, never the unlisted remainder.

   Trace: `<def> file:line:col`, `skip <def> file:line`, and
   `single <def> file:line:col`.
3. § ifcTransTdWriterRank456 (ModuleEmit, the module branch of the import
   listing; R11U456_IFCTDRANK_OFF). An interface that § ifcBodyImpTransitiveTds450
   routes through the module branch now records its
   § enumImportParentLastWriter180 writes with the interface rank 0, not the
   module rank 1.

   The ranks follow Surelog's write order: UhdmWriter::write runs
   writeInterface over every definition before writeModule. So a module that
   imports the package always re-parents the shared enum object last. With
   rank 1, an interface whose name sorts after every importing module won the
   drain.

   Example: uvm_ef_vif_config_db behind the two faces above. 1048
   ref_typespecs read work@sfr_monitor_bfm.uvm_pkg::UVM_SEQ_ARB_TYPE where
   golden writes work@hvl_top.uvm_pkg::UVM_SEQ_ARB_TYPE. On exp2 this goes
   from 1048 to 427 strict objects.

   The file-scope import route of § 418 keeps rank 1 (not measured).
   Trace: `<iface> <typedef>`.

No src/R*.h, no getenv, no reader function, no header change. Only
src/ModuleEmit.cpp and src/TypeEmit.cpp change.

## Grid (cases/, every case's first line names its law; drivers/runcase.sh)

pristine -> law8 (exit code, uhdm-cmp lines, strict verdict). Every exit code is 0 on both binaries.

§ ifcTaskFixupWalksWait456 (WT):
- WT/wt01 (wait inside an if and at top level, ef_vif's shape): 31 -> 0, STRICT_EQUAL 256
- WT/wt02 (wait with statement and block bodies, two instances): 31 -> 0, STRICT_EQUAL 336.
  Golden binds the shared body to the first instance u1.
- WT/wt03 (uninstantiated interface, control): STRICT_EQUAL 127 on both, byte-identical
- WT/wt04 ($display argument, event trigger, foreach, fork, ++, assert, while/wait): 31 -> 811, NOT_EQUAL.
  Every ref binding now equals golden's (drivers/refbind.py). The head moved later, to the elaborated
  interface's missing named_event `ev` and queue variable `q` (residue 3).
- WT/wt05 (foreach over a 2-D array whose loop variable `i` is also an interface int): 56 -> 56, NOT_EQUAL.
  Every ref binding now equals golden's. The head is unchanged: golden's loop variable is a ref_var over the
  interface int where ours writes a logic_var. That is the foreach loop-variable writer (StmtEmit, sister-ground face 1).
- WT/wt06 (function call argument in an assignment, $display/$write arguments, fork/join_none): 31 -> 0, STRICT_EQUAL 325
- WT/wt07 (assert with else $error, assert expression, foreach with wait over arr[k]): 31 -> 0, STRICT_EQUAL 281
- WT/wt08 (module task, control): STRICT_EQUAL 170 on both, byte-identical
- WT/wt09 (array element and bit selects indexed by an interface port): 31 -> 0, STRICT_EQUAL 327

§ thisFirstGroupOrigToo456 (TF):
- TF/tf01 (m1 imports a, which imports u; m2 imports u): 17 -> 0, STRICT_EQUAL 176
- TF/tf02 (first module lists nothing; m1 clone and m2/m3 original): 17 -> 0, STRICT_EQUAL 175
- TF/tf03 (original listed first, the v11u452 VT/vt04 shape, control): STRICT_EQUAL 179 on both, byte-identical
- TF/tf04 (a single listing module holding the clone): 17 -> 0, STRICT_EQUAL 161
- TF/tf05 (two importing packages, one with its own out-of-body method): 17 -> 0, STRICT_EQUAL 195
- TF/tf06 (three-level chain u <- a <- b): 17 -> 0, STRICT_EQUAL 191
- TF/tf07 (an in-body class method in the importer, three modules): 17 -> 0, STRICT_EQUAL 171

§ ifcTransTdWriterRank456 (IR):
- IR/ir01 (interface zif and module hv both import mid, which imports u): STRICT_NOTEQUAL fullname -> STRICT_EQUAL 262
- IR/ir02 (the module sorts after the interface, control): STRICT_EQUAL 175 on both, byte-identical
- IR/ir03 (interface only, control): STRICT_EQUAL 156 on both, byte-identical
- IR/ir04 (modules bm importing u and cm importing mid): STRICT_EQUAL 188 on both.
  The bytes move toward golden: u::e_t's parent goes from work@zif to work@cm, as in golden. That field is not read by strict.

R11U456_OFF gives pristine's bytes on 20 of 20 case dirs. Each law's own switch alone does too, on its own group
(evidence/switches.txt).

## Gates

One full five-stage sweep on the final binary law8 (md5 c24fb0c78f778827e09489cd96815ff7,
slang 12.0.0+545f88b2e), workdir /tmp/r11u456sw, with R11U456_TRACE on. The four corpus stages ran from the
worktree with tests/sweep.sh --jobs 3. The worktree's UVM submodule is empty, so the sv-tests stage ran
through the main tree's scripts/check_svtests.py with --baseline set to the worktree's
results/golden_svtests.csv, the base 7b76f0685's. The main tree had moved to pass 455 meanwhile.

- probe: EQUAL=4023 STRICT_NOTEQUAL=64 of 4087, regressions=0 conversions=0 changes=0. probe.csv is
  identical to the control's. The 5 probe cases the trace names are identical to the control by
  path-normalized dump.
- surelog: default CMP_EQUAL 480, testflags 474, regressions=0 conversions=0 changes=0. The csv differs
  from the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0. The csv is identical to the control's.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0. The csv is
  identical to the control's.
- sv-tests: EQUAL 1926, DIFFERENT 14, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8,
  TIMEOUT 1 of 2346. regressions=0 conversions=0 changes=0. svtests.csv is identical to the control's.
- byteverify (SELFCHECK=1), law8 sweep against the master's control /tmp/intr11u454: surelog 0 of 962
  (self-check 961), uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804).
- canaries: ok=52 changed=0. ctcan2 surelog ok=58 PASS (EXPECT_UNKNOWN=1). ctcan2 uhdm2rtlil ok=2 PASS
  (EXPECT_UNKNOWN=6).
- binary audit (cmds.txt, fence-filtered list): surelog 1523 of 1573 name law8 (the other 50 hold only a
  Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346. No record names another slang-uhdm binary.
- prediction and trace census: evidence/prediction.txt. Before the sweep, the census named Tnoc d/t as
  the only corpus firing rows and the 5 probe cases. The sweep's trace names exactly those. Tnoc's bytes do
  not move, so byteverify reads 0 movers.
- the law-index stage: tests/LAWS.md regenerated in the worktree; the sweep printed "law index current".

Experiment (not a gate; it measures the faces behind pass 455): the worktree's src plus pass 455's src
diff (7b76f0685..e8b7d96d3, ExprEmit and ParamEmit), built as exp2 (md5
5ffe806fe6459c34257c8ba965e82f23). The diff was then reverted, and the rebuild reproduced law8's md5.
The runner on the three sfr rows gave:
- uvm_vif_config_db: EQUAL.
- uvm_ef_vif_config_db: JUDGE_EQUAL, strict differ:fullname(427).
- uvm_ac_config_db: DIFFERENT at 64 lines, head the sfr_master_bfm parameter-copy decompile.

The earlier exp455 binary (law7, before § ifcTransTdWriterRank456) read ef_vif differ:fullname(1048).
With R11U456_THISFIRSTORIG_OFF it read ac_config_db at the extra this wire (17 lines, rhs
logic_net work@hvl_top.this 968:29), so § thisFirstGroupOrigToo456 is the law that moves that head.

## Goal 1

No rejecting sv-tests row carries an exporter message at the base. The 75 SURELOG_ONLY and 303 BOTH_REJECT rows
were checked. The five rows whose detail names a path under slang-uhdm's tree carry the uvm_pkg time-scale
diagnostic ("design element does not have a time scale"), which is upstream slang's. Nothing on this ground.

## Decodes (not written)

1. uvm_use_models_pipelined_get_put, the head pass 454 left: golden writes the uvm_default_factory foreach loop
   variables as int_var, ours as array_var. The whole decode is below; the fix is on the SISTER's ground
   (StmtEmit, sister-ground face 1).
   * UhdmWriter::write runs lateTypedefBinding over every FileContent (the `$unit` scope, scope nullptr)
     before the package pass (UhdmWriter.cpp, the FileContent loop ahead of "Packages" and "FileContent Late
     Binding after Packages"). swapForSpecifiedVar's decodeHierPath of the array name m_type_overrides
     resolves to nothing there, so the loop variable falls back to int_var.
   * The FileContent holds uvm_pkg's late list because mbus_pipelined_driver_bfm.sv opens with a file-level
     `import mbus_pipelined_agent_pkg::*;`, and that package's body imports uvm_pkg. importPackage copies the
     whole list, transitively.
   * StmtEmit's § classPropUnitImport21 (UhdmExporter::pkgImportedByUnit21) asks only whether a compilation
     unit imports uvm_pkg DIRECTLY. It needs the transitive closure of pass 454's model: package body imports
     only, earlier-declared packages only.
2. uvm_many_to_one and uvm_id_register: the importer copies of uvm_pkg::uvm_default_sequencer_type.
   * Surelog's copy aliases the user's sequencer specialization at that specialization's location: a_pkg's
     A_sequencer at a.sv 88:9, apb_sequencer at 30:9. Ours has that too.
   * In golden, exactly ONE of the 13 listings carries the specialization's vpiParameter REQ (the user item
     class) and its vpiParamAssign: module hvl_top in id_register, `$unit` class test in many_to_one, both
     with instance the package that imports the agent package. Ours carries none.
   * many_to_one's golden also names the alias target b_pkg::A_sequencer under class_defn work@test, where
     ours writes a_pkg::A_sequencer under module_inst work@top.
   * Not decoded further. It is the first difference of both rows (uhdm-cmp 104 and 85 lines).
3. uvm_param_vif_config_db: class_typespec this_t, the same family (230 lines), not reached.

## Residues, ranked

1. uvm_ef_vif_config_db with pass 455: 427 strict fullname objects are left, all module-scoped names golden
   gives to work@hvl_top. 371 of them are struct typedef member refs (uvm_reg_bus_op.addr/data/byte_en,
   uvm_reg_map_addr_range.min/max) that ours names work@hdl_top, which is § typedefParentLastWriter134's model
   in UhdmExporter. The other 56 are subroutine-local copies (sfr_agent_pkg::...::recursion_policy::...)
   that golden names through the subroutine and ours names work@hdl_top. Not decoded.
2. uvm_ac_config_db with pass 455: the next head is the decompile of a uvm_pkg parameter's import copy in
   sfr_master_bfm (uvm_field_flag_t constant at 195:46). Golden writes 'b000010101010101, ours
   28'b000010101010101. This is the parameter import copy (ParamEmit, sister-ground face 2).
3. An instantiated interface's named event and queue variable are not listed in the elaborated
   interface_inst (WT/wt04, golden `work@top.u.ev` and array_var `work@top.u.q`; ModuleEmit). This is the
   case's next head now that its bindings are equal.
4. The decodes above: pipelined_get_put (sister), many_to_one and id_register (this ground, not written),
   param_vif_config_db.
5. The carried lists of passes 454 and earlier (the r11u454 README residues): import chains LT/lt02;
   based-literal bounds; generic interface ports; GI/gi01; the class-method local fixed array; easyUVM;
   the 3 uvm_scoreboard rows; p733, p737 and tnoc (awaiting the user's decision).

## Sister-ground faces (reported, not written)

1. StmtEmit, § classPropUnitImport21 (UhdmExporter::pkgImportedByUnit21): a compilation unit's import must
   count the packages reached through a package's own body imports (earlier-declared packages only, pass
   454's model). Example: uvm_use_models_pipelined_get_put's `index` int_var at uvm_factory.svh 1109:29.
   Also the foreach loop variable named like an interface variable, which golden writes as a ref_var over
   the interface variable's typespec (WT/wt05; the foreach branch).
2. ParamEmit: the import copy of a uvm_pkg parameter in a module (sfr_master_bfm) writes its constant's
   decompile with the size prefix (28'b...) where golden writes 'b... (uvm_ac_config_db's next head with
   pass 455 and this pass).

## Process

Within the budget: no pristine build of my own (the worktree's first build, md5
61990b658b183290f4b48a414a72a435, equals the main tree's binary and was frozen as /tmp/r11u456_bin/pristine
before any measurement) and no pristine sweep. The master's control /tmp/intr11u454 is the pristine reading.

- Intermediate binaries law1 to law7 were used only for case runs, one 14-row runner call on pristine
  (the open rows), one 30-row runner call on law7 (the both-accepting uvm-examples and testbenches rows,
  every status unchanged), and the candidate trace census on law7 and law8.
- Two experiment builds (exp455, exp2) added pass 455's src diff to measure the sfr rows. Each was
  followed by a revert and a rebuild to the law binary's md5.
- One full five-stage sweep was run, on law8. byteverify was run once.

Slips, none affecting a measurement:
- Two background waiters matched their own command lines (a pgrep -f pattern inside the same shell's
  text) and waited on themselves. Both were stopped by task id before they ran anything. The waiter
  script then excluded the agent's own shells.
- A scratch diff named after the sister's pass number was removed from /tmp by the master's landing
  prune while it was in use. It was re-made under another name, and the worktree's src was verified
  against the base diff before the rebuild.
- The prediction named Tnoc d/t as movers, and they did not move (the firings reach already-bound
  references).
- A Tnoc binding-diff helper was too slow on the full dump and was stopped by task id. It is not needed,
  since byteverify reads Tnoc unmoved.

The fence list was read into a file by a program and never printed. Every tree-wide scan
(drivers/scan_*.py) filters on it before opening a file. No fenced test was named, opened or run.
No other agent's process was touched. The pristine runner call, the law4 and law8 builds, the exp455 build, the census calls and the sweep
started after three quiet readings. The exp2 build, its 3-row runner call, the law5 to law7 builds and
the case runs were not preceded by a quiet check (a slip, timing only).
