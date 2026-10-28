# r11u454 — module/type ground, sv-tests campaign (pass 454)

Implementer pass on base 7f271bbb6.  Two sv-tests rows convert, DIFFERENT -> EQUAL
(uhdm-cmp EQUAL, uhdm-strictcmp STRICT_EQUAL, agreement IDENTICAL):

| row | before (base) | after (law6) |
|---|---|---|
| generated/uvm-examples/uvm_use_models_bidir_get_put.sv | DIFFERENT,decompile: | EQUAL,,equal |
| generated/uvm-examples/uvm_use_models_bidir_item_done.sv | DIFFERENT,decompile: | EQUAL,,equal |

Both rows needed all four laws: each law cleared one uhdm-cmp head and exposed the next one.

## Laws (switches through src/LawSwitch.h; R11U454_OFF restores pristine's bytes on all 10 case dirs)

1. § pkgLateTsTransitiveImport454 (UhdmExporter, inside § pkgLateTsNetCapture420;
   R11U454_LATETRANS_OFF). Surelog's importPackage copies the imported package's
   whole late-typedef list into the importer, and a package that imports other packages
   already holds their lists. So a definition that imports bidirect_bus_pkg, which
   imports uvm_pkg, also carries uvm_pkg's foreach names. The definition import sets
   that pass 420 uses are closed over the packages' own import items (file-level and
   body, nested class/module declarations excluded). First head on the bidir rows:
   uvm_mem::get_addresses's `foreach (addr[i])` binds the interface net
   work@top_hdl.bidirect_bus_drv.addr's logic_typespec (top_hdl.sv 100:11), where ours
   bound the formal's uvm_reg_addr_t. Trace: `capture <pkg|name> <instance>` when a
   capture depends on the closure, and `lvmodule` for the loop-variable binding module.
2. § unpackedDimBasedLitKept454 (TypeEmit buildUnpackedRanges' mkBound;
   R11U454_DIMBASEDLIT_OFF). When an unpacked dimension bound is written as a based
   literal, the bound stays that literal: radix kind, written size (-1 when unsized),
   digits with the separators removed, and the literal's own span. A signed literal also
   gets compileConst's location-less signed int_typespec. Second head:
   bus_seq's `logic[31:0] mem[32'h0100_0000:32'h0100_001C]`. Golden writes HEX:01000000,
   size 32, at 164:17-164:30. Ours wrote INT:16777216, size 64, at 164:17-164:19.
3. § ifcTaskFixupWalksAllStmts454 (ModuleEmit, the instantiated interface's
   subroutine-binding walk; R11U454_IFCWALKALL_OFF). The walk now also enters
   `if` without else, the condition of an if/else, a case selector and its items,
   forever, do-while and `return` values. Third head:
   bidirect_bus_driver_bfm::drive's `if (...) begin write_data <= ...; end`. Golden binds
   it to work@top_hdl.bidirect_bus_drv.write_data; ours left it unbound.
4. § genericIfcPortRunSharedTs454 (ModuleEmit; R11U454_GENRUNTS_OFF). A generic
   `interface` port that follows another generic port, in a run that opens the ANSI port
   list, shares the run head's unsupported_typespec (the head's name and span). This
   applies to the definition port, the elaborated port, the elaborated net and the
   generic-root hier_path typespec. Last head:
   bidirect_bus_slave(interface bus, interface gpio). Golden's gpio refers to
   unsupported_typespec `bus` at 152:37; ours referred to `gpio` at 152:52.

## Grid (cases/, every case's first line names its law; drivers/runcase.sh)

pristine -> law6 (exit code, uhdm-cmp lines, strict verdict):
- LT/lt01 (§ pkgLateTsTransitiveImport454, interface importing mid importing u): rc 0/0; cmp 62 -> 0; STRICT_EQUAL 312
- LT/lt02 (same law, two-level chain top2 -> mid -> u in a module): 62 -> 24, closer. The new head is the loop variable i in mid's import clone of u::C::f (residue)
- LT/lt03 (same law, plain non-importing interface plus an importing module): 62 -> 0; STRICT_EQUAL 325
- BL/bl01 (§ unpackedDimBasedLitKept454, class property and module variable): 36 -> 0; STRICT_EQUAL 139
- BL/bl02 (same law, package, interface, class signed and octal, unsized module bounds): 36 -> 0; STRICT_EQUAL 194
- IF/if01 (§ ifcTaskFixupWalksAllStmts454, if, if/else condition, case, forever, do-while): 31 -> 0; STRICT_EQUAL 492
- IF/if02 (same law, two instances plus an uninstantiated interface control): 31 -> 0; STRICT_EQUAL 298
- IF/if03 (same law, function with `return` of an interface net, unique case): 31 -> 0; STRICT_EQUAL 257
- GI/gi02 (§ genericIfcPortRunSharedTs454, two generic ports, named and positional, two modules): 16 -> 0; STRICT_EQUAL 229
- GI/gi01 (same law, abstention control: a generic port after `input logic c`): 30 -> 30, byte-identical.
  Golden gives that port c's logic_typespec and input direction. That face is not written.

Every exit code is 0 on both binaries. On every mover, the law's own switch alone restores pristine's bytes.

## Gates (one full five-stage sweep on the final binary law6, md5 dbd76f862b3cf0fbe1c5029789b364d3, slang 12.0.0+545f88b2e; workdir /tmp/r11u454_sw)

- probe: EQUAL=4023 STRICT_NOTEQUAL=64 of 4087, regressions=0 conversions=0 changes=0.
  Compared by path-normalized dump against the master's control /tmp/intr11u452,
  0 of 4087 databases moved (a positive control is flagged).
- surelog: default 480 + 0, testflags 474 + 0, 0/0/0. Status and strict columns are
  identical to the control.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0. Status and strict columns are identical.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0.
  The csv is identical to the control.
- sv-tests: EQUAL 1926, STRICT_NOTEQUAL 0, DIFFERENT 14, SURELOG_ONLY 75, BOTH_REJECT 303,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346. regressions=0 conversions=2 changes=0
  (the two rows above). The stage ran through the main tree's tests/sweep.sh with
  SLANG_UHDM=law6, because the worktree's UVM submodule is empty. Its rc=1 comes only from
  the main tree's own law-index staleness line; the worktree index is current.
- byteverify (SELFCHECK=1) of law against control: surelog 2 of 962 (self-check 961),
  uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804).
- canaries: ok=52 and ok=16. Both ctcan2 checks PASS.
- binary audit: surelog 1531 of 1581 cmds.txt name law6 (the other 50 hold only a
  Surelog line), uhdm2rtlil 1742 of 1742, sv-tests 2346 of 2346. No record names
  another slang-uhdm binary.

### Movers by law

- Surelog Tnoc default and testflags (CMP_NOTEQUAL standing, uhdm-cmp 28 lines before and
  after) move bytes because of § ifcTaskFixupWalksAllStmts454's `return` branch.
  tbcm_mux's interface function get_ack `return valid && ready` now binds `valid` and
  `ready` to receiver_if[0]'s variables. Both new bindings appear verbatim in golden's
  binding list (evidence/tnoc_default_binding_diff.txt). The prediction
  (evidence/prediction.txt) named 0 corpus movers, so this mover was not predicted. It is
  attributed here, and it moves toward golden.
- The trace census confirms it: the corpus stages log only the interface walk. It logs on
  9 probe cases and on FuncDeclScope, HierPathInterfBlock, InterfaceFuncCall and Tnoc in
  both modes. Only Tnoc changes bytes. The other three laws log nowhere in the corpora.
- In sv-tests, the laws fire on the two converted rows. They also fire on rows whose status
  does not move: pipelined_get_put, id_register, param_vif_config_db, ef_vif_config_db
  and tnoc (DIFFERENT), uvm_slave_agent and uvm_slave_agent_multi_seq_item (EQUAL), and
  uvm_wait_for_signal (SLANG_ONLY).

## Goal 1

All 75 SURELOG_ONLY rows at the base still carry a slang front-end diagnostic. The 5
rejecting rows whose detail names a slang-uhdm path carry the uvm_pkg time-scale error
("design element does not have a time scale"), which is upstream slang's. Nothing on this
ground.

## Residues, ranked

1. uvm_use_models_pipelined_get_put (DIFFERENT). Head: loop variables of the elaborated
   uvm_default_factory foreach statements (set_type_override_by_type 1109:29 and 9 more).
   Golden writes int_var over a location-less int_typespec; ours writes array_var.
   Decoded as far as UhdmWriter::swapForSpecifiedVar: decodeHierPath of the array name in
   the first component that processes the late entry resolves to null in this design
   (giving int_var), where in the bidir rows it resolves to the queue's array_typespec
   (giving array_var). Which component goes first was not decoded.
2. uvm_many_to_one, uvm_id_register (DIFFERENT): the specialization/this_type listing
   (pass 426's family). Golden's class_typespec b_pkg::A_sequencer sits under class_defn
   work@test with vpiInstance env_pkg; ours sits under the module instance.
   uvm_param_vif_config_db: class_typespec this_t under sfr_config_object, where ours
   reaches the type_id specialization argument. Not decoded.
3. LT/lt02: an import clone's foreach loop variable in a two-level import chain.
4. GI/gi01: a generic interface port after a non-interface port takes that port's data
   type and direction.
5. A class-method local fixed unpacked array: golden lists both an element int_var and the
   array_var under the function (scratch case, pristine too; TaskFuncEmit).
6. The three sfr_scoreboard rows (ParamEmit, the sister's), easyUVM, the 3 scoreboard
   rows, p733, p737, tnoc and the carried lists of passes 452 and earlier.

## Sister-ground faces

None new. The sfr_scoreboard uvm_report_enabled cs clone pairing stays with ParamEmit.

## Process

- Intermediate binaries law1 to law6 were used for case runs and targeted runner calls on
  the six rows. One full sweep was run, on law6.
- Slip (timing only): one 2-row runner call on law5 overlapped the sister r11u455's census
  runner.
- Slip: a background wait loop matched its own command line with pgrep -f. It was stopped
  by task id before it ran anything.
- Slip: a pkill -f pattern on two of my own uhdm-dump processes also matched my own shell
  and ended that shell. No other process matched.
- The fence list was read into a file by a program and never printed. Every tree-wide scan
  was filtered on it before any file was opened.
