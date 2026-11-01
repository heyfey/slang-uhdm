# r11u458 — the module/type ground, pass 458 (implementer)

The twenty-ninth pass of the sv-tests campaign on the module/type ground
(TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main), on base
2f99dba8f.  This patch touches only `src/UhdmExporter.cpp` and
`src/TaskFuncEmit.cpp` (plus this directory and the regenerated
`tests/LAWS.md`).

## Verdict per targeted row (pristine = the master's control at the base)

| row | before | after (law binary) |
|---|---|---|
| generated/uvm-examples/uvm_ef_vif_config_db.sv | STRICT_NOTEQUAL differ:fullname(427), uhdm-cmp EQUAL | **EQUAL** (uhdm-cmp 0 lines, STRICT_EQUAL 840299 objects, agreement IDENTICAL) |
| generated/uvm-examples/uvm_ac_config_db.sv | DIFFERENT (uhdm-cmp 64 lines) | DIFFERENT, same head (ParamEmit's `28'b000010101010101`, the sister's) |
| generated/uvm-examples/uvm_id_register.sv | DIFFERENT (85) | DIFFERENT, same head (class_typespec `apb_agent_pkg::apb_sequencer` with its REQ type_parameter under work@hvl_top) |
| generated/uvm-examples/uvm_many_to_one.sv | DIFFERENT (104) | DIFFERENT, same head (class_typespec `b_pkg::A_sequencer` under class_defn work@test) |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT (230) | DIFFERENT, same head (class_typespec `this_t` in sfr_config_object) |
| generated/uvm-examples/uvm_use_models_pipelined_get_put.sv | DIFFERENT (56) | DIFFERENT, same head (int_var loop variable of uvm_default_factory, the sister's StmtEmit) |

Runner csvs: `evidence/open_pris.csv` (pristine), `evidence/open_law1.csv`
(first law binary, already converting the row), `evidence/open_law7.csv`
(the final binary).  The conversion needs both naming laws: with
`R11U458_MEMBALIASNAME_OFF=1` the row reads STRICT_NOTEQUAL fullname, with
`R11U458_SUBRCOPYNAME_OFF=1` STRICT_NOTEQUAL fullname, with
`R11U458_CLONETWIN_OFF=1` still STRICT_EQUAL 840299 (the twin law does not
fire on the row), and `R11U458_OFF=1` gives pristine's dump (path-normalized
uhdm-dump identical to the pristine database).

## Decode of the 427 strict differences (evidence/efv_strict_pristine_summary.txt)

* 371 records: the Typedef_alias ref of a struct member's per-member typedef
  copy (`uvm_reg_bus_op.addr` / `.data` / `.byte_en`, `uvm_reg_map_addr_range.min`
  / `.max`), golden `work@hvl_top.uvm_pkg::uvm_reg_bus_op.addr.uvm_reg_addr_t`,
  ours `work@hdl_top...`.  Five objects of ours, re-expanded at every
  reference by the strict walk.  Surelog stores no full name there:
  BaseClass::ComputeFullName names it through the copy's parent (the
  typespec_member) and the shared struct's FINAL parent, which
  UhdmWriter::writeDataTypes(setParent) sets for every module listing in
  `m_design->getModuleDefinitions()` order — a
  `std::map<std::string, ModuleDefinition*, StringViewCompare>`
  (include/Surelog/Common/Containers.h ModuleNameModuleDefinitionMap), i.e.
  NAME order, so `work@hvl_top` writes after `work@hdl_top`.  Ours' member
  refs were already renamed by § typedefParentLastWriter134, but the alias of
  § memberBareTdAliasNamedByUse183's per-member copy was named from the member
  ref's name at emission time (when our listing order had hdl_top last) and
  the copy has no parent, so § 134's rename never reached it.
* 56 records: subroutine-local copies inside the importer copies
  (`sfr_agent_pkg::uvm_reg_map::do_bus_access::accesses::uvm_pkg::uvm_reg_bus_op::addr`,
  `sfr_agent_pkg::uvm_printer::print_object::recursion_policy::uvm_pkg::uvm_recursion_policy_enum`,
  and the sfr_test_pkg twins).  Golden's importer copy is UHDM's deep clone
  of the home subroutine; every aggregate a local or formal owns is its own
  object parented at the reference, and its member refs and enum base ref
  are named by ComputeFullName through that chain.  Ours held copies cloned
  from the shared typedef while a module listing parented it, so they kept
  that module's stored names (and, for a queue local's element struct and its
  struct_var element, § cloneOwnAggMemberChainName285 does not reach them).

## The laws (all through src/LawSwitch.h; `R11U458_OFF=1` drops the pass)

* **§ memberAliasFollowsMemberName458** (UhdmExporter `aggCopyNames458`,
  run design-final from `final287`; switch `R11U458_MEMBALIASNAME_OFF`) — the
  Typedef_alias ref of a struct or union member's per-member typedef copy (a
  bit or logic copy with no parent and one binder) whose stored name is a
  member-chain name for that member takes the member ref's final stored name
  and its separator: `<member ref name>.<typedef>` or `::`.
* **§ subrAggCopyNamesByChain458** (UhdmExporter `aggCopyNames458`; switch
  `R11U458_SUBRCOPYNAME_OFF`) — a named struct, union or enum typespec
  parented at a ref_typespec under a task or function (before any package,
  class, module, interface or program) names its member refs, its enum base
  ref and its members' typedef-copy alias refs through its parent chain
  (BaseClass::ComputeFullName, transcribed as § 285 did), when the stored
  name differs and ends with the object's own tail; a member typedef copy
  that another binder shares or that is parented elsewhere gets its own deep
  copy (clone_tree) under the member ref first.  Its first step, the STRAY
  COPY: a subroutine reference binding a struct or union parented at a
  module, interface or program whose own listing does not hold it (a copy
  taken from the shared typedef while that module listed it) takes its own
  deep copy parented at the reference.
* **§ cloneDeclOnlyTwinOwnObject458** (TaskFuncEmit's declaration-only body
  and UhdmExporter `final287`; switch `R11U458_CLONETWIN_OFF`) — in an
  importer copy, the repeated entries of § tfDeclOnlyBodyBegin412's twice
  listing and of § fnDeclOnlyFirstTwice412v's repeated first declarator are
  distinct deep copies parented at the subroutine (golden: UHDM DeepClone
  clones each vector entry; the home lists one object twice).  CROSS-FILE
  WRITE: TaskFuncEmit records (subroutine, position) in the side list
  `g_cloneTwin458` (membership/position only, never iterated during
  emission); `final287` in UhdmExporter takes the copies after every rebind
  of the first entry's typespecs (the first build cloned at emission time and
  the copy missed LAW S's later rebind of a packed struct member: MB/mb06 to
  mb08 went uhdm-cmp 0 -> 126 lines; found on the grid before any sweep,
  fixed by the design-final placement), and skips a position that no longer
  holds a repeated entry.

No src/R*.h, no getenv, no LawState.h section, no header change; every law
logs its firings through `lawTrace(458, ...)` (`R11U458_TRACE=<dir>`).

## Grid (tools/probe/r11u458repro/cases, 27 case dirs; drivers/runcase.sh)

Every case is accepted by upstream slang (`slang --single-unit`), every exit
code 0 on both binaries.  `evidence/grid_pristine.txt`, `evidence/grid_law7.txt`.

| case | law | pristine | law binary |
|---|---|---|---|
| MA/ma01 | memberAlias (hvl_top then hdl_top) | STRICT_NOTEQUAL fullname | STRICT_EQUAL 592 |
| MA/ma02 | control (hdl_top written first) | STRICT_EQUAL 1007 | byte-identical |
| MA/ma03 | control (one importer) | STRICT_EQUAL 677 | byte-identical |
| MA/ma04 | packed union member alias | STRICT_NOTEQUAL fullname | STRICT_EQUAL 947 |
| MA/ma05 | packed struct of aliases | STRICT_NOTEQUAL fullname | STRICT_EQUAL 967 |
| MA/ma06 | interface importer | NOT_EQUAL 591 (interface variable listing, pre-existing) | byte-identical |
| MA/ma07 | three modules zz, aa, mm | STRICT_NOTEQUAL fullname | STRICT_EQUAL 1337 |
| MA/ma08 | control (no importer) | STRICT_EQUAL 355 | byte-identical |
| MA/ma09 | explicit `import p::op_s` | STRICT_EQUAL 631 | STRICT_EQUAL 631, bytes toward golden (an unreached alias `p::p::op_s::addr::a_t` -> golden's `work@hvl_top.p::op_s.addr.a_t`) |
| MA/ma10 | nested struct member | STRICT_NOTEQUAL fullname | STRICT_EQUAL 1023 |
| MB/mb01 | queue + scalar struct locals, enum local in an importer copy | STRICT_NOTEQUAL fullname | STRICT_EQUAL 1414 |
| MB/mb02 | out-of-body function with enum and struct formals | NOT_EQUAL stage1 (pre-existing head, lhsPath package(p) / rhsPath package(ap)) | same head (uhdm-cmp prints 1580 -> 1602 lines of the same package objects), bytes moved |
| MB/mb03 | free package function, no importer package | STRICT_NOTEQUAL fullname | STRICT_EQUAL 1102 |
| MB/mb04 | module task locals | STRICT_NOTEQUAL fullname | STRICT_EQUAL 1286 |
| MB/mb05 | in-body class task | STRICT_NOTEQUAL fullname | STRICT_EQUAL 654 |
| MB/mb06 | free function + lone-declaration task, two importers | STRICT_NOTEQUAL fullname | STRICT_EQUAL 1710 |
| MB/mb07 | the same, module imports both | STRICT_NOTEQUAL depth | STRICT_EQUAL 1146 |
| MB/mb08 | the same, hdl_top first | STRICT_NOTEQUAL depth | STRICT_EQUAL 1304 |
| MB/mb09 | enum formal of an out-of-body function (the recursion_policy shape) | NOT_EQUAL 1270 (the mb02 head) | same head, bytes moved |
| LT/lt01 | lone `int un;` task in an importer copy | STRICT_NOTEQUAL depth | STRICT_EQUAL 153 |
| LT/lt02 | lone union local | NOT_EQUAL 149 (the union member instance, sister ground) | same head, bytes moved |
| LT/lt03 | `function void f(); int a, b;` | STRICT_NOTEQUAL depth | STRICT_EQUAL 171 |
| LT/lt04 | `function int g(); int a;` | STRICT_NOTEQUAL name | STRICT_EQUAL 171 |
| LT/lt05 | task `int a, b;` | STRICT_NOTEQUAL depth | STRICT_EQUAL 177 |
| LT/lt06 | union local, module imports only p | NOT_EQUAL 149 (union face) | same head, bytes moved |
| LT/lt07 | control (task with a statement) | STRICT_EQUAL 180 | byte-identical |
| LT/lt08 | control (module task, no copy) | STRICT_EQUAL 101 | byte-identical |

Tally: 16 case dirs to STRICT_EQUAL, 1 (ma09) STRICT_EQUAL on both with its
bytes moving toward golden, 6 byte-identical controls (ma02, ma03, ma06,
ma08, lt07, lt08), 4 at an unchanged pre-existing head (mb02, mb09, lt02,
lt06), none worse.  Switch check (`drivers/switchcheck.sh`,
`evidence/switchcheck_law7.txt`): `R11U458_OFF=1` gives pristine's bytes and
exit code on 27 of 27 case dirs; a single law's switch alone restores the
pre-law bytes on LT/lt01 to lt06 (`R11U458_CLONETWIN_OFF`), on every moving MA
case and on MB/mb03 to mb05 (`R11U458_MEMBALIASNAME_OFF`); MB/mb01, mb02 and
mb06 to mb09 move under two or three laws together (each law's part named by
its switch), `R11U458_OFF=1` restoring them.

## The sweep (one full five-stage sweep on the final binary law7)

`tests/sweep.sh --jobs 3 --workdir /tmp/r11u458sw1 --corpus "probe surelog
uhdm2rtlil downstream"` from the worktree with SLANG_UHDM=law7 and
R11U458_TRACE on, then the sv-tests stage through the main tree's
scripts/check_svtests.py (the worktree's UVM submodule is empty) against the
worktree's results/golden_svtests.csv; launched after three quiet readings
(the sister r11u459's census runner had been live and was waited out).
`evidence/sweep_corpora_summary.txt`, `evidence/sweep_svtests_summary.txt`.

* probe: EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, regressions=0
  conversions=0 changes=0; the csv identical to the control's.
* surelog: default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL
  standing), regressions=0 conversions=0 changes=0; the csv differs from the
  control only in the two LowMem log-path texts.
* uhdm2rtlil: 803 / 1 / 67 in both modes (stamped_gen_param d/t
  CMP_NOTEQUAL standing), regressions=0 conversions=0 changes=0; the csv
  identical to the control's.
* downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of
  871, not identical and not excused 0; the csv identical to the control's.
* sv-tests: EQUAL 1928, STRICT_NOTEQUAL 0, DIFFERENT 12, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions=0 conversions=1 changes=0.  THE CONVERSION, the fresh row:
  `generated/uvm-examples/uvm_ef_vif_config_db.sv,EQUAL,,equal` (control:
  `...,STRICT_NOTEQUAL,differ:fullname(427),differ:fullname(427)`),
  attributed above to § memberAliasFollowsMemberName458 together with
  § subrAggCopyNamesByChain458.  results/ untouched.
* byteverify (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, law
  sweep vs the master's control, equal-length workdir names;
  `evidence/byteverify.txt`): surelog 4 of 962 — MiniAmiq default and
  testflags, SeqDriver default and testflags, exactly the PREDICTED movers
  (`evidence/prediction.txt`, written from the census before the sweep);
  uhdm2rtlil 0 of 1608; downstream 0 of 805; self-checks 961/962, 1607/1608,
  804/805 (one file of each set is the fixed comparison file).  The four
  movers stay CMP_EQUAL with uhdm-cmp 0 lines and STRICT_EQUAL at 435559,
  435559, 475526 and 475538 objects; their move is toward golden (MiniAmiq
  default: the importer copy's alias name
  `svaunit_pkg::uvm_reg_map::do_bus_write::accesses::uvm_pkg::uvm_reg_bus_op::data::uvm_reg_data_t`
  occurs 24 times in golden, 6 on pristine, 24 on the law binary).  So the
  SeqDriver testflags sweep hash moves (d06eaeb7d1c2... against the control's
  4e6f3f81e983...) and is re-recorded at landing.
* probe databases by path-normalized uhdm-dump (`evidence/probe_movers.txt`):
  1 of 4087 moves, r10uvm180repro/g180_a_kinds, the predicted one (EQUAL on
  both; its enum copy's base ref
  `kx180_clone::howlite_fn::keel::kx180_home::howlite_et` 12 times in golden,
  0 on pristine, 6 on the law binary).
* trace (`evidence/sweep_trace.txt`): the four surelog movers (132 firings
  each), the one probe case (2), and 22 sv-tests rows (rsd and 21
  uvm-examples rows, 80 to 640 firings each, § memberAliasFollowsMemberName458
  5 times on ac_config_db, ef_vif_config_db and id_register), no status
  moving except the conversion; § cloneDeclOnlyTwinOwnObject458 fires on no
  corpus row, probe case or sv-tests row (its grid LT is its only evidence).
* canaries (`evidence/canaries.txt`): ok=52 changed=0 (surelog) and ok=16
  changed=0 (uhdm2rtlil); both ctcan2 checks PASS.
* binary audit (fence-filtered, `evidence/csv_vs_control.txt`): surelog
  1523 of 1573 cmds.txt name the law7 binary (the other 50 hold only a
  Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The five open uvm-examples rows, each at its pristine head (table above):
   id_register, many_to_one and param_vif_config_db at the class_typespec of
   a specialization or this_t listing (module/type ground, not decoded this
   pass), ac_config_db and pipelined_get_put at the sister's faces.
2. MB/mb02 and mb09: an out-of-body class method whose formal is typed by
   the home package's enum (and struct) in a design whose importer package
   copies it: uhdm-cmp's first difference compares golden's package p with
   our package ap (lhsPath `design > package(p)`, rhsPath
   `design > package(ap)`), the same on pristine; not decoded.
3. A task-local associative or dynamic array of a package struct (`op_s
   m[int]`, `op_s d[]` in an importer copy): golden's begin lists the
   struct_var element beside the array_var (TaskFuncEmit's local listing,
   the pass 454 residue family); measured on scratch variants of MB/mb02,
   not written.
4. MA/ma06: an interface importer's elaborated variable listing (pre-existing
   NOT_EQUAL 591).
5. The carried lists of passes 456 and earlier (see the brief's items (c) to
   ({)), unchanged.

## Sister-ground faces (reported, not written)

* ParamEmit's elaborated package typedef copy (`pkgTopTypedefTs`, the
  `stampSub` member walk before `typedefTs[&ta] = ts`): a PACKED UNION
  typedef's member typespecs carry no vpiInstance where golden has the home
  package (a struct's are stamped).  uhdm-cmp head on any package union
  typedef that another package imports (scratch case: package p with
  `typedef union packed {...} u_t;`, package ap importing p, top importing
  both: NOT_EQUAL 101 lines, the bit_typespec member's vpiInstance p in
  golden, null in ours); LT/lt02 and lt06 stop there.
* A free package function's `return q.size();` on a queue local in an
  importer copy read a vector mismatch at the function on a scratch variant
  of MB/mb02 (not decoded further; ExprEmit/StmtEmit).

## Process

* Measured within the budget: no pristine build of my own beyond the
  worktree's first build (md5 d0dfe22c35b7dc0c5d3ab323a4e7a34d, equal to the
  main tree's build/slang-uhdm, frozen at /tmp/r11u458_bin/pristine); law1 to
  law7 on case runs and targeted runner calls on the six open rows; one
  traced census (102 candidate surelog rows both modes, the uhdm2rtlil
  corpus both modes, 286 probe candidates) before the sweep; one full
  five-stage sweep on the final binary law7 (md5
  2bc868e0bde5fcc16f311b8b0d5cd30c), the sv-tests stage through the main
  tree's scripts/check_svtests.py with the worktree's results/golden_svtests.csv
  as the baseline (the worktree's UVM submodule is empty).
* The fence list was read into a file by a program without printing it;
  every tree-wide list (drivers/scan_cand.py, the probe scan) was filtered on
  it before any file was opened; no fenced test named, opened or run.
* Slip, affecting no measurement: one uhdm-dump call ran in a shell that had
  not sourced the environment file, so bash tried to execute two databases as
  scripts; both trees read clean afterwards (git status), no file written;
  every later dump went through a guarded wrapper.
* The first twin-law build (law3) cloned at emission time; the grid caught
  the uhdm-cmp break on MB/mb06 to mb08 before any sweep and law4 moved the
  copy design-final.

## Files

* `cases/MA`, `cases/MB`, `cases/LT`: 27 case dirs, each `dut.sv` naming its
  law on its first line.
* `drivers/runcase.sh` (Surelog golden + ours, exit code, uhdm-cmp lines,
  strict verdict, md5), `drivers/switchcheck.sh`, `drivers/aggrefs.cpp` (the
  decoding aid: every aggregate typespec of a name, its parent chain, its
  members' typedef copies and its binders), `drivers/scan_cand.py` (the
  census candidate scan).
* `evidence/`: prediction, grids, switch check, census, runner csvs, the
  strict summary at the base, sweep logs and byteverify.
