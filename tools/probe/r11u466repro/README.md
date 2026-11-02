# r11u466: module/type ground, pass 466 (sv-tests campaign)

Base e79fb32e4. The patch is a diff against that base. Production files: src/ModuleEmit.cpp and src/UhdmExporter.cpp only. TypeEmit, TaskFuncEmit, uhdm_main.cpp, include/, src/LawSwitch.h and the sister's four files are unchanged.

This was a restarted pass. The first run died on an API outage and left seven draft binaries, 27 case dirs and no sweep. Every number below was measured again on the final binary.

## How it was measured

- The main tree moved during the pass: pass 465 (1dd2079da) and pass 467 (fe1067e0c) landed, both in src/ParamEmit.cpp only, with no overlap with this pass's two files.
- So the measured binary is this pass's two files on top of HEAD fe1067e0c. The worktree took fe1067e0c's src/ParamEmit.cpp, results/golden_svtests.csv and tests/LAWS.md for the build and the sweep only. None of these are in the patch.
- Final binary: /tmp/r11u466_bin/meas7x467, md5 11abac36c079ceae2dbe699570e41fe6. A rebuild after a one-line comment fix gave the same md5. It links slang 12.0.0+545f88b2e.
- The same two files on the base alone: /tmp/r11u466_bin/law7, md5 3ab98c87f8d7755621306f352ec95569. Its grid bytes equal the final binary's on all 27 case dirs.
- Pristine:
  - /tmp/r11u466_bin/head_pristine, a copy of the main tree's HEAD build (md5 c9b2f893019899967f666555de7bc9e8);
  - the base pristine /tmp/r11u466_bin/pristine (md5 450798454c55b4a77ef33ecc1d731c07). Its grid bytes equal head_pristine's on all 27 dirs.
- The control is the master's HEAD sweep /tmp/intr11u467. No pristine sweep was run.
- Process fix: the first run's /tmp/r11u466_wait.sh matched its own launching shell, so chained measurements hung. It was replaced by drivers/quietwait.py, which reads /proc and skips its own pid, its ancestors, the session wrapper shells and itself. Tested standalone: it printed quiet in 19 s on an idle machine, and chained before a command it printed quiet. Every build, census, runner call and sweep stage of this run waited on it. Twice it held a launch until the sister r11u469 / v11u469 sweep had finished.

## Verdicts

| row | before (HEAD control /tmp/intr11u467) | after (final binary) |
|---|---|---|
| generated/uvm-examples/uvm_use_models_pipelined_get_put.sv | DIFFERENT (decompile:) | **EQUAL** (STRICT_EQUAL 838378 objects, uhdm-cmp 0 lines) — CONVERSION |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT, uhdm-cmp 230 lines | DIFFERENT, the same 230 uhdm-cmp lines; dump distance 961064 -> 955144 (toward golden) |
| generated/uvm-examples/uvm_many_to_one.sv | EQUAL | EQUAL (measured, not taken; pass 467 closed it) |

Fresh csv row (evidence/svtests_final.csv): `generated/uvm-examples/uvm_use_models_pipelined_get_put.sv,EQUAL,,equal`. Runner row (evidence/rows3_final.csv): cmp EQUAL, strict equal, agreement IDENTICAL.

Which laws the row needs (evidence/pipelined_get_put_switches.txt, the row's recorded command, judged against the cached golden):

| switch set | uhdm-cmp lines | strict |
|---|---|---|
| none (all laws on) | 0 | STRICT_EQUAL 838378 |
| R11U466_OFF | 1388336 | NOT_EQUAL |
| R11U466_TRANSCLSKEYS_OFF | 1388340 | NOT_EQUAL (the head pass 465 left: the interface typedef listing) |
| R11U466_UNITGRPORDER_OFF | 0 | STRICT_NOTEQUAL name |
| R11U466_IFCEVENT_OFF | 17 | NOT_EQUAL |
| R11U466_GENVIEWPA_OFF | 0 | STRICT_NOTEQUAL depth |
| R11U466_EMPTYLISTKEYS_OFF | 0 | STRICT_EQUAL (not needed by the row) |
| R11U466_IFCDEEPTRANS_OFF | 0 | STRICT_EQUAL (not needed by the row) |

So the row needs four faces, each found after the previous one was written: the class keys in the interface listing, the design subroutine order, the interface event and its late-binding wire, and the generic port view's param_assigns. The row also needs pass 465's two ParamEmit laws, which landed after the base.

Determinism: three concurrent draws of the row read one md5 (979e2a27c93b), each STRICT_EQUAL 838378 (evidence/determinism_pipelined_get_put.txt).

Goal 1: nothing on this ground. All 75 SURELOG_ONLY rows of the HEAD control carry an upstream slang `error:` diagnostic, and none carries the exporter's own message. There are no SLANG_CRASH rows.

## Laws

Six laws, in src/ModuleEmit.cpp and src/UhdmExporter.cpp. Each is read through src/LawSwitch.h as lawOn(466, "R11U466_<LAW>_OFF"). R11U466_OFF drops all six. R11U466_TRACE=<dir> logs each firing through lawTrace(466, ...). No src/R*.h, no getenv, no reader function, no header change. TypeEmit, TaskFuncEmit, uhdm_main.cpp, include/ and the sister's four files are unchanged.

1. § transImpClassKeys466 (R11U466_TRANSCLSKEYS_OFF; ModuleEmit: transClsKeyPkgs466 and the three class-key branches § 24 importPublishesPackageClasses24, § 45 modulePublishesPackageClasses45, § 206 fileUnitPublishesPackageClasses206)
   - An import publishes the class keys that the imported package's own DataTypeMap holds, not only the keys of its own classes.
   - Why: CompileHelper::importPackage inserts the imported package's class-name keys and then copies its whole DataTypeMap. That map already holds the class keys its own body imports inserted when it was compiled, and theirs, transitively.
   - Which packages count: the package's body wildcard imports in written order, each followed by what that package's map holds. An edge counts only when the imported package is declared before the importer, the ordering rule of § pkgLateTsEarlierPkgOnly454v. Keys go in through emplace, so the first key of a name wins.
   - The pipelined_get_put face: golden's typedef listing of interface work@mbus_pipelined_driver_bfm (file-scope `import mbus_pipelined_agent_pkg::*;`, that package importing uvm_pkg) has 131 entries, uvm_pkg's class keys among them (`mbus_pipelined_agent_pkg::this_type` x30, `this_subtype`, `type_id`, `cb_type`, `common_type`, `super_type`). Ours had 93.
   - Cases: IK/ik01, ik02, ik03, ik04, ik07, ik08, ik10.
2. § emptyListClassKeys466 (R11U466_EMPTYLISTKEYS_OFF; ModuleEmit § 45 branch and emitInterfaceInstance's registration)
   - A module or interface view with no typedef of its own still lists the class keys its imports publish. importPackage inserts them whatever else the map holds. The branch used to skip every view whose listing was empty.
   - The elaborated home view of a definition view that lists nothing yet is registered under the definition view's import set too, so both views get the keys (golden ik05: `this_type` and `a::this_type` in the interface, its instance and the module).
   - Cases: IK/ik05, ik06. Both need laws 1 and 2 together.
3. § ifcBodyImpDeepTrans466 (R11U466_IFCDEEPTRANS_OFF; UhdmExporter::emitImportArtifacts in ModuleEmit, the § ifcBodyImpTransitiveTds450 gate)
   - The gate of § 450 looked one package level down for a typedef. The typedefs can sit deeper: importPackage copies the imported package's map, which holds what its own imports' maps held.
   - So an interface that imports a, where a's import b declares no typedef but imports c, lists c's typedefs too (golden ik09: c::c_t in work@ifc; ours none).
   - Case: IK/ik09 (needs law 1 too).
4. § unitGroupKeepsHomeOrder466 (R11U466_UNITGRPORDER_OFF, read together with lawOn(446, "R11U446_IMPGRPORDER_OFF"); UhdmExporter::exportDesign)
   - The reorder446 pass that puts an import group into the home package's definition order now also runs on the design's own subroutine listing.
   - Why: that listing is the FileContent's list, which importPackage fills from the imported package's listing. So a group of clones that a file-scope import brings in keeps the home's order, as a module's listing does.
   - The pipelined_get_put face: golden lists uvm_packer's six macro-written get/set_packed_* clones at positions 227 to 233 of 979. Ours had them at 947 to 952, because the design's copy was taken before the package views were reordered.
   - Cases: UG/ug01, ug02, ug03.
5. § ifcEventTrigNet466 (R11U466_IFCEVENT_OFF; ModuleEmit emitInterfaceInstance)
   - An elaborated interface lists its `event` declarations as named_event objects (vpiNamedEvent, at the declarator, in declaration order), as a module instance does. The interface road dropped them, since makeVar declines an event.
   - Surelog's interface elaboration does not resolve a reference to such an event (`@ev`, `->ev`). Its late binding mints a wire on the elaborated instance, as for a $unit variable (§ ifcUnitVarRefMintsNet424):
     - logic_net work@<inst>.ev, vpiNetType 1, no file, at the event's first reference in source order (a task's `->ev` before the always's `@ev`);
     - after the instance's other nets, one per referenced event in first-reference order;
     - minted by the first elaborated instance only;
     - the shared processes' and tasks' `@ev` references bind it.
   - An event that no body statement reads mints nothing (EV/ev07).
   - The pipelined_get_put face: work@top_hdl.mbus_pipelined_drv.do_data_phase at mbus_pipelined_driver_bfm.sv 50:5 (`->do_data_phase;` in task begin_transfer), with the always's `@do_data_phase` bound to it. Ours listed neither the named_event nor the wire.
   - Cases: EV/ev01 to ev08 (ev03 is a byte-identical control).
6. § genIfcViewSharesParamAssigns466 (R11U466_GENVIEWPA_OFF; ModuleEmit genPlainViewDrain176)
   - A plain generic interface port view (`module s(interface bus, ...)`) lists the very param_assign objects of the connected instance: the header, body and package-imported ones alike.
   - Why: elab_interface_ hands a port copy `netl->param_assigns()` when it has none, and a plain generic view's netlist is the connected instance's.
   - Ours listed fresh objects elaborated at the definition's values. The pipelined_get_put face is work@top_hdl.dut.bus, the row's last strict difference: golden 838378 objects, ours 838392.
   - Cases: GP/gp01 to gp06 (gp02 and gp06 are byte-identical controls).

## Grid

27 case dirs: EV 8, GP 6, IK 10, UG 3. Every case's first line names its law. Files: evidence/grid_head_pristine.txt, grid_final.txt, dist.txt (path-normalized uhdm-dump distance, pristine -> law), switchcheck_final.txt.

- Every exit code is 0 on both binaries.
- 17 STRICT_EQUAL on the final binary against 3 on pristine, so 14 are new: EV/ev01, ev02, ev04 to ev08; GP/gp01, gp03, gp05; IK/ik05, ik06, ik09, ik10.
- 6 byte-identical controls: EV/ev03, GP/gp02, gp06, IK/ik03, ik07, UG/ug03.
- 7 move toward golden without reaching equality (dump distance pristine -> law):
  - GP/gp04 301 -> 251;
  - IK/ik01 45 -> 33 (uhdm-cmp 438 -> 17), ik02 53 -> 47, ik04 63 -> 33 (uhdm-cmp 418 -> 17), ik08 47 -> 41 (STRICT_NOTEQUAL type on both);
  - UG/ug01 132 -> 124 (STRICT_NOTEQUAL name on both), ug02 72 -> 68.
- None moves away.
- Switch check:
  - R11U466_OFF gives head_pristine's bytes and exit code on 27 of 27 dirs.
  - Each moved dir is restored by its own law's switch alone, with three exceptions that need two switches together: IK/ik05 and ik06 (TRANSCLSKEYS + EMPTYLISTKEYS) and ik09 (TRANSCLSKEYS + IFCDEEPTRANS).
  - IK/ik03 fires § transImpClassKeys466 with its bytes unchanged.

## Census and prediction (evidence/prediction.txt, written before the sweep)

A traced census ran the final binary's slang side with R11U466_TRACE and compared bytes with /tmp/intr11u467. Its scope: every non-fenced surelog and uhdm2rtlil row-mode (3313), every probe case (4087) and every sv-tests row (2346). Tools: evidence/tools/census.py, probecensus.py, svcensus.py.

- Corpora: no law mover. MiniAmiq default and testflags fire § transImpClassKeys466 with their bytes unchanged.
  - LowMemLib t, LowMemPkg d/t and PreProcMacro d/t differ from the control on head_pristine as well, with pristine's and the law's bytes identical. These are path-dependent bytes from the census's own output paths.
  - No uhdm2rtlil row fires, so 0 downstream movers were predicted.
- Probe: 0 movers. r10uvm212repro/grid_c7_cuclass_foreignpkg_and_pkgclass_design and r10uvm50repro/a7 fire § 1 with their bytes unchanged.
- sv-tests: 10 rows fire. Conversion predicted for pipelined_get_put, and no other status change.
  - param_vif_config_db moves bytes and stays DIFFERENT.
  - The five EQUAL firing rows stay STRICT_EQUAL with a raw walk equal to pristine's (`uhdm-strictcmp --no-canon` pristine vs law): ef_vif_config_db 751612, id_register 939074, bidir_get_put 617838, bidir_item_done 617801, unidirectional 616316 objects.
  - slave_agent, slave_agent_multi_seq_item and wait_for_signal are SLANG_ONLY, since Surelog rejects them.
- The prediction held exactly. The sweep's trace (evidence/sweep_trace_firings.txt) fired on the same 2 probe cases, the same 2 MiniAmiq row-modes and the same 10 sv-tests rows.

## Gates (one full five-stage sweep on the final binary, workdir /tmp/r11u466sw)

- The four corpus stages ran from the worktree (tests/sweep.sh --jobs 3) with exit 0 and a current law index (evidence/sweep_four_stages.log):
  - probe EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions=0 conversions=0 changes=0;
  - surelog default CMP_EQUAL 480 and testflags 474, 0/0/0;
  - uhdm2rtlil 803/1/67 in both modes, 0/0/0;
  - downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871, not excused 0.
- The probe, uhdm2rtlil and downstream csvs are byte-identical to the control. The surelog csv differs only in the two LowMem log-path texts.
- sv-tests ran through the main tree's tests/sweep.sh, since the worktree's UVM folder is empty (evidence/sweep_svtests.log):
  - EQUAL 1932, DIFFERENT 8, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  - regressions=0, conversions=1 (`CONVERSION generated/uvm-examples/uvm_use_models_pipelined_get_put.sv: DIFFERENT -> EQUAL`), changes=0;
  - the csv differs from the control on that row only;
  - the command exited 1 on the main tree's stale law index alone.
- byteverify against the control (SELFCHECK=1, evidence/byteverify.txt): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805, each self-check flagging n-1.
  - The sweep's probe databases differ in raw bytes on all 4087, because the worktree's tests/probe path is written into VpiFile.
  - The census, run with the main tree's probe paths, read 0 of 4087 movers on the same binary.
- sv-tests kept databases (evidence/svtests_kept_bytes.txt): 29 kept, all differing from the control in raw bytes.
  - 28 read STRICT_EQUAL to the control under --no-canon, the serialization-order variance.
  - The other one is uvm_param_vif_config_db, the predicted law mover: the same 230-line uhdm-cmp output, and dump distance 961064 -> 955144 toward golden.
- Canaries: ok=52 and ok=16. ctcan2 PASS on both (surelog ok=58 with 1 unknown pattern; uhdm2rtlil ok=2 with 6 unknown patterns).
- Binary audit (fence-filtered, evidence/binary_audit.txt):
  - surelog: 1523 of 1573 records name the final binary; the other 50 hold only a Surelog line;
  - uhdm2rtlil: 1740 of 1740;
  - sv-tests: 2346 of 2346;
  - no record names another slang-uhdm binary.
- Corpus UVM controls: MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg keep their bytes (byteverify 0 movers), so their STRICT_EQUAL object counts stand.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The 8 DIFFERENT sv-tests rows left, none reached by this pass:
   - uvm_param_vif_config_db: the class-local this_t that golden writes with a specialization alias and bogus type parameters, a Surelog artefact not decoded to a rule;
   - easyUVM and the three uvm_scoreboard testbench rows;
   - p733, p737 and tnoc, which await the user's decision.
2. The interface variable typed by a typedef that a file-scope import brings: the per-use copy's typedef-alias ref_typespec (IK/ik01, ik04 at 17 uhdm-cmp lines, golden ref_typespec a::a_t under the copy, ours none). Probably TypeEmit's per-use copy; not decoded.
3. A transitive class key against a later import's typedef of the same name: golden keeps the class key `kname` from b (via a) over z::kname (IK/ik08, STRICT_NOTEQUAL type). The precedence between the class-key branch and the typedef branch is not decoded.
4. Module-level and design-level listing heads in IK/ik02, ik03 and ik07 (module_inst, interface_inst and package a at the uhdm-cmp head), not decoded.
5. A generic interface port of a nested instance (GP/gp04, interface_inst work@top.u0.fi at the head, 111 uhdm-cmp lines).
6. Package group order with macro-written out-of-body definitions under the importing package (UG/ug01: golden K::f2 where ours lists K::f3 in package g; ug02 and ug03 at older heads). Not decoded.
7. The carried lists of passes 464 and earlier (the r11u464 and v11u464 READMEs).

## Sister-ground faces

None found this pass. Every face of the targeted row was on this ground once pass 465's ParamEmit laws were in.

## Process

- One build of the final binary plus one rebuild after a comment fix, with the same md5.
- One traced census, then one full five-stage sweep, one byteverify and one targeted runner call on the three UVM rows.
- The per-switch reading and the determinism draws ran on the slang side only, against the cached golden.
- The fence list was read from the earlier run's file by programs only and never printed. Every tree-wide list was filtered on it before any file was opened.
- No other agent's process was touched. The quiet check waited out the sister's live sweeps.

Files:
- cases/ (27 dirs);
- drivers/ (env.sh, runcase.sh, dist.sh, switchcheck.sh, bytecheck.sh, quietwait.py);
- evidence/ (grids, dist, switch checks, census and prediction, sweep logs, sv-tests csv and firings, byteverify, kept-database check, canaries, binary audit, determinism, binaries.md5, tools/census.py, tools/probecensus.py, tools/svcensus.py).
