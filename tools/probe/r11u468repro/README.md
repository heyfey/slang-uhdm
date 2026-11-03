# r11u468: module/type ground, pass 468 (sv-tests campaign)

Base 770304e1. The patch is a diff against that base. Production files: src/ModuleEmit.cpp and src/UhdmExporter.cpp only. TypeEmit, TaskFuncEmit, uhdm_main.cpp, include/, src/LawSwitch.h and the sister's four files (ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit) are unchanged.

## How it was measured

- Pristine: /tmp/r11u468_bin/pristine, a copy of the main tree's build at the base (md5 1c992b8a6ef274d7f4fba9c55be2cf69). The worktree's own first build gave the same md5. No pristine sweep: the control is the master's sweep /tmp/intr11u466.
- Final law binary: /tmp/r11u468_bin/law13, md5 0581ecaad93bf3cf6f1039f47e53b733, linking slang 12.0.0+545f88b2e. law1 to law12 were case and row runs only.
- One full five-stage sweep on law13 with R11U468_TRACE on (workdir /tmp/r11u468_sw). Probe, surelog, uhdm2rtlil and downstream ran through the worktree's tests/sweep.sh. The sv-tests stage ran through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty. The main tree had moved to pass 471 (01d7233b5), which changed no results/ file and none of this pass's two files.
- Case runs: drivers/runcase.sh (the probe recipe `-parse -nobuiltin -nocache -sv`, and `dut.sv --single-unit --nobuiltin` for ours; a FILES file lists more than one source) and drivers/runuvm.sh (the sv-tests uvm recipe with Surelog's bundled 1800.2-2017 UVM). drivers/switchcheck.sh checks the switches, drivers/dist.sh gives the dump distance.
- Row heads: evidence/tools/headwalk.cpp (pass 469's walk) against the cached goldens. Listing tools: evidence/tools/tflist.cpp (subroutine listings and formal bindings), ctsparams.cpp (law 2's predicate), pchain.cpp (parameter typespec chains and range identity), palhs.cpp (specialization Lhs identity), ctsdump.cpp (a listed class typespec's specialization).

## Verdicts

| row | before (control /tmp/intr11u466) | after (law13) |
|---|---|---|
| testbenches/uvm_scoreboard_env.sv | DIFFERENT | **EQUAL** (STRICT_EQUAL 432906 objects) — CONVERSION |
| testbenches/uvm_scoreboard_monitor_env.sv | DIFFERENT | **EQUAL** (STRICT_EQUAL 435854 objects) — CONVERSION |
| testbenches/uvm_scoreboard_monitor_agent_env.sv | DIFFERENT | **EQUAL** (STRICT_EQUAL 438766 objects) — CONVERSION |
| generated/easyUVM/top.sv | DIFFERENT | DIFFERENT. Its old head is written. The next heads are on the sister's ground (see below). |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT, uhdm-cmp 230 lines | DIFFERENT, uhdm-cmp 230 lines. No law fires. Decoded; not written. |

Fresh csv rows (evidence/sweep/svtests_target_rows.csv, from /tmp/r11u468_sw/svtests.csv):

    testbenches/uvm_scoreboard_env.sv,EQUAL,,equal
    testbenches/uvm_scoreboard_monitor_agent_env.sv,EQUAL,,equal
    testbenches/uvm_scoreboard_monitor_env.sv,EQUAL,,equal
    generated/easyUVM/top.sv,DIFFERENT,decompile:,
    generated/uvm-examples/uvm_param_vif_config_db.sv,DIFFERENT,decompile:,

- easyUVM moves toward golden on the law binary: uhdm-cmp 659635 -> 60 lines and dump distance 1775405 -> 410299 (golden from the cache, ours from the control and the sweep).
- Which laws a conversion needs: uvm_scoreboard_env's recorded command with each switch, against the cached golden (evidence/scoreboard_env_switches.txt):

| switch | uhdm-cmp lines | strict |
|---|---|---|
| none | 0 | STRICT_EQUAL 432906 |
| R11U468_OFF | 2200983 | NOT_EQUAL |
| R11U468_UNITINCLCLS_OFF | 0 | STRICT_EQUAL (law 1 not needed) |
| R11U468_SPECIMPFORMAL_OFF | 56 | NOT_EQUAL |
| R11U468_PROPSPECFULL_OFF | 0 | STRICT_NOTEQUAL fullname |
| R11U468_OOBIMPCLS_OFF | 2200983 | NOT_EQUAL (the m_check face, uhdm-cmp's first head) |
| R11U468_SPECARGTD_OFF | 0 | STRICT_NOTEQUAL name |

- Determinism: three concurrent draws of uvm_scoreboard_env with law13 read one md5 (c48dbd22cb81), each STRICT_EQUAL 432906. These draws overlapped the sister r11u473's runner, which affects timing only.

## The sweep (law13, /tmp/r11u468_sw, R11U468_TRACE on)

| stage | result |
|---|---|
| probe | EQUAL 4024, STRICT_NOTEQUAL 63 of 4087; regressions=0 conversions=0 changes=0; csv identical to the control |
| surelog | regressions=0 conversions=0 changes=0 (default 480 + 0, testflags 474 + 0); csv differs from the control only in the two LowMem log-path texts |
| uhdm2rtlil | regressions=0 conversions=0 changes=0 (803/1/67 both modes); csv identical to the control |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; verdict diff 0; csv identical to the control |
| svtests | EQUAL 1935, STRICT_NOTEQUAL 0, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; **regressions=0 conversions=3 changes=0** |

- Both sweep commands exit 1, on the stale law index alone (tests/LAWS.md is regenerated last, below).
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) against the control:
  - surelog 1 of 962: Scoreboard default, the known coin. No law fires on it, and its dump, sorted and unsorted, is identical to the control's (0 lines).
  - uhdm2rtlil 0 of 1608; downstream 0 of 805.
- The probe databases carry the worktree's tests/probe path, so the probe stage is judged by its csv (identical) and the trace (no firing).
- The re-kept sv-tests databases: 26 in both sweeps, all differing in raw bytes. Under uhdm-strictcmp --no-canon, 25 are STRICT_EQUAL to the control (the serialization-order variance). The other one is easyUVM, the predicted law mover.
- The trace (evidence/sweep/trace_firings.txt) fires on exactly the four predicted rows and nowhere else.
- Canaries: ok=52 (surelog) and ok=16 (uhdm2rtlil); EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 ctcan2 both PASS.
- Binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt records name law13, and the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346. The downstream harness takes the exported SLANG_UHDM, so it writes no per-row record.
- The five corpus UVM rows (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg) keep their verdicts, and no law fires on them.

Goal 1: nothing on this ground. All 75 SURELOG_ONLY rows of results/golden_svtests.csv carry a slang front-end `error:` diagnostic in their detail. None carries the exporter's own message, and there is no SLANG_CRASH row.

## Laws

Five laws, in src/ModuleEmit.cpp and src/UhdmExporter.cpp. Each is read through src/LawSwitch.h as lawOn(468, "R11U468_<LAW>_OFF"). R11U468_OFF drops all five. R11U468_TRACE=<dir> logs each firing through lawTrace(468, ...). No src/R*.h, no getenv, no reader function, no LawState.h section, no header change. New bookkeeping lives in side lists: two function-local static vectors in UhdmExporter.cpp, filled only when the law fires and cleared by the drain.

1. § unitInclClassImports468 (R11U468_UNITINCLCLS_OFF; ModuleEmit, inside § classInheritsContainerImports23)
   - A class written in an included file belongs, in Surelog, to the root file's FileContent, because the preprocessor folds every `` `include `` into the including file. So the root file's compilation-unit imports reach it exactly as they reach a class written in the root file itself.
   - § 23 compared the import's raw buffer with the class's (or its module container's) raw buffer, so a class in an included file got no import copies.
   - The test now compares the ROOT file of each include chain. Macro locations are first mapped to their original text.
   - The easyUVM face (pass 469's EU/eu01): golden's `work@sequencer` (sequencer.sv, included from top.sv under `import uvm_pkg::*;`) lists 82 parameters, 129 typedefs and 984 subroutines. Ours listed none.
   - Cases: IU/iu01 to iu04 and iu08 reach STRICT_EQUAL. iu06 and iu07 move toward golden (dump distance 684 -> 422 and 502 -> 366): their remaining head is a module listing, on the sister's ground. iu05 is the byte-identical control.
2. § specArgPairsImportedFormal468 (R11U468_SPECIMPFORMAL_OFF; UhdmExporter, design-final after § 23; with its range half freshRangesRepaired468 in the finish241 drain)
   - A class specialization pairs its ORDERED arguments with the target class's ordered parameter list. That list starts with the parameters the class's imports brought in.
   - Decoded from CompileType.cpp (the ClassDefinition branch of compileDatastructureTypespec) and CompileHelper::importPackage:
     - The ClassDefinition branch reads `classDefn->getOrderedParameters().at(index)` for the index-th written argument. It names the type_parameter after that formal and points the param_assign's Lhs at the formal's object.
     - importPackage calls `scope->insertParameter(clone)` for every parameter of the imported package, in the package's name-sorted getParameterMap order. It does this once per import item, before the class's own formals are inserted.
   - So under `import uvm_pkg::*;` the first argument pairs with UVM_ALL_ON and the second with UVM_CHECK_FIELDS. UVM_ABSTRACT, which would sort first, exists only under UVM_ENABLE_DEPRECATED_API.
   - This is THE "BOGUS UVM_ALL_ON" ARTEFACT pass 469 reported. It is deterministic: the class_defn's own vpiParameter listing, read by position. It is written as a law.
   - Design-final rule: each specialization pair whose Lhs is the target's own formal at own position j is re-paired with the target class_defn's listing entry j, when that listing starts with imported entries.
     - The type_parameter takes that entry's name, and its stored full name follows.
     - The param_assign's Lhs becomes the entry's object.
     - A located type_parameter (a data-type argument) takes the entry's file and span, and its param_assign the entry's line and column. Surelog locates it at the formal's declaration.
   - The second half: Surelog's import copy is a clone_tree, so the range objects under the re-paired copy's typespec chain (the copy and its alias target) are its own. Ours were shared with the other classes' copies. Once the specialization reaches comparator's copy first, the strict walk listed the ranges there and not under work@env's own copy (uvm_scoreboard_env, differ:depth).
     - The re-paired copy gets fresh range objects. This runs in finish241 because the chain's ranges are filled after the pairing pass.
   - Cases: SP/sp02, sp05 (with law 3) and sp08 reach STRICT_EQUAL. sp07 goes NOT_EQUAL -> STRICT_NOTEQUAL depth, moving toward golden (dump distance 174 -> 156). sp01's change is in unlisted typespecs at the dump tail (distance unchanged). sp03, sp04 and sp06 are byte-identical controls.
3. § clsPropSpecTpFullName468 (R11U468_PROPSPECFULL_OFF; UhdmExporter, design-final with law 2)
   - The type_parameter of a specialization written as a CLASS PROPERTY's type, and its ref_typespec, carry their parent chain's full name: golden `work@env::comp::C::T`.
   - emitClassTsParams's variable site stored `C.T`. That is right for a module variable, whose elaborated chain reads that way.
   - The rule only rewrites a stored `<class name>.<formal>`. It predates this pass: SP/sp09 and TA/ta03, with no import, read STRICT_NOTEQUAL fullname on pristine. Law 2's conversions exposed it on the scoreboard rows (differ:fullname(3)).
   - Cases: SP/sp09 and TA/ta03 reach STRICT_EQUAL.
4. § oobClassTdImporterClass468 (R11U468_OOBIMPCLS_OFF; UhdmExporter, after § oobClassTdFirstClassKey231)
   - Golden's DEFINITION object of an out-of-body method can bind a class-scoped typedef formal to a class other than § 231's first-key winner. This is the object the method's class, the $unit classes and the design list, not the package listing's copy.
   - The face: `function bit uvm_sequence_library::m_check(uvm_object_wrapper seq_type, this_type lib);`. Golden binds `this_type` to the user's `typedef comparator #(T) this_type;` (the sv file's 52:13). Ours bound uvm_abstract_component_registry's 292:11. This was the first head of all three scoreboard rows and of easyUVM.
   - Measured rule (the golden grid OU and OV):
     - Candidates: a class outside the method's package that imports that package (a $unit class under a file-scope import, a module-local class, a class of another package whose body imports it), lives in another file than the package, and declares a class-scoped typedef of the formal's name.
     - When candidates exist, the definition object's formal binds that class's typedef. The package listing's copy keeps § 231's winner.
     - One file holding package and class keeps § 231's winner (ou01 to ou04, ou08 to ou10).
     - A second file binds the importing class (ou11, ou13 module-local, ou14 another package; UVM ov01, ov03, ov04).
     - A class that does not import the package is no candidate (ou15, ou16's a.sv).
     - Of two $unit candidates the smaller name wins, in either source order (ou12, ou17).
     - The law abstains on candidates of mixed kinds.
   - Surelog's mechanism, read from the source but not single-stepped: the out-of-body formal stays on the package's late-typedef-binding list. importPackage hands that list to every importer (`scope->needLateTypedefBinding(var)`), and the importer that resolves it first finds its own typedef in its own scope.
   - The bound object is the winner class_defn's listed typedef (same kind, name, file and span), else the smallest-id object.
   - Cases: OU/ou11 to ou14, ou16, ou17 and OV/ov01, ov03, ov04 reach STRICT_EQUAL. The UVM ones go from uhdm-cmp 2072133, 2072077 and 2081927 lines. ou05 to ou07, ou15 and ov02 are byte-identical controls. ou01 to ou04 and ou08 to ou10 are byte-identical and stay at an older face.
5. § specArgTypedefNameShares468 (R11U468_SPECARGTD_OFF; UhdmExporter, recorded in emitClassTsParams and emitClassPropSpecParams163, drained after law 4)
   - A specialization argument written as a TYPEDEF's name is a ref_obj in Surelog's ordered-argument loop. compileDatastructureTypespec returns that typedef's own typespec object (the scope's DataType -> TypeDef -> getTypespec()), shared, not a new class_typespec of the target class.
   - The face: `uvm_analysis_imp #(T, this_type) from_dut;` in class comparator. Golden's type_parameter IMP reaches the class's own `this_type` object at 52:13. Ours built a fresh class_typespec named `comparator`.
   - This was the scoreboard rows' last head (differ:name). After it the walk lists the `this_type` object at the reference first, and at comparator's own listing not again, as golden's does.
   - Design-final: the reference takes the typedef's object. That is the class_defn's listed typedef when the typedef is class-scoped. A specialization's own typedef symbol has no object of its own, so the listed typedef of that name on that line of that file is taken.
   - Cases: TA/ta01 and ta04 reach STRICT_EQUAL. ta02 moves toward golden (distance 80 -> 35) but stays at 224 uhdm-cmp lines: its head is an older face, emitClassTsParams listing a formal whose argument names the referencing class's own type parameter, which golden pushes nothing for. ta03 (the class name itself) is the control for law 5 and moves by law 3 only.

## Grid

42 case dirs in IU (8), SP (9), OU (17), TA (4) and OV (4). Every exit code is 0 on both binaries. evidence/grid_pristine.txt, evidence/grid_law.txt, evidence/switch_check.txt.

- STRICT_EQUAL: 7 on pristine, 28 on law13 (21 newly). 26 dirs move bytes.
- Movers that do not convert, all toward golden by dump distance: iu06 684 -> 422, iu07 502 -> 366, sp07 174 -> 156 (NOT_EQUAL -> STRICT_NOTEQUAL depth), ta02 80 -> 35. sp01 is at the same distance; its change is in unlisted dump-tail typespecs only.
- Byte-identical: 16 dirs.
- None moves away.
- Switches: R11U468_OFF gives pristine's bytes and exit code on 42 of 42 dirs. Each moved dir is restored by its own law's switch alone, except SP/sp05 (laws 2 and 3 together) and TA/ta01, ta02, ta04 (laws 3 and 5 together).

## Census and prediction (evidence/prediction.txt, written before the sweep)

- Traced census with the final binary (evidence/census):
  - verify_golden over the uhdm2rtlil corpus (1742 row-modes) and the fence-filtered surelog corpus (1588 row-modes);
  - check_probe over 4087 cases;
  - the runner over 247 sv-tests candidate rows: every uvm-tier row, plus every row whose sources hold a class together with an import, an include or a second file.
- Result: no law fires on any corpus row or probe case, and the corpus and probe csvs equal the committed baselines row for row.
- The laws fire on exactly four sv-tests rows: the three scoreboard rows and easyUVM.
- Law 2's predicate (evidence/tools/ctsparams.cpp, positive control SP/sp05 and the scoreboard rows) over the 7480 fence-filtered slang-side control databases of /tmp/intr11u466 holds on exactly the three scoreboard databases.

The sweep matched the prediction exactly: 3 conversions, easyUVM moving and staying DIFFERENT, no corpus, probe or downstream mover except the Scoreboard default coin, and the trace on the same four rows.

## Away census (evidence/away_bytecheck.txt, drivers/bytecheck.sh)

- Scope: 2865 fence-filtered case dirs under tools/probe/r11u44*..r11u46*repro and v11u44*..v11u46*repro, which include this pass's own 42 and pass 469's sister cases. Pristine against law13, exit code and raw bytes, absolute paths.
- 2796 exit-0 dirs and 25 exit-4 dirs are byte-identical.
- 20 exit-3 dirs differ, as they do between two pristine runs (checked: the same 20 differ pristine against pristine).
- 24 exit-0 movers. 23 are this pass's own grid dirs. The other one is pass 469's r11u469repro/evidence/sister/EU/eu01, the easyUVM shape, which goes NOT_EQUAL 420 lines -> STRICT_EQUAL 142 on law 1; its control eu02 is byte-identical.
- No exit code moves, and nothing moves away.

## Residues (ranked; all wrong on pristine too, none moved away)

1. generated/easyUVM/top.sv. Its first head was law 4's face and is written. The next heads in walk order:
   - a call `exp.compare(rec)` through a type-parameter handle, where ours writes the default argument (`uvm_comparer comparer = null`) as a third argument and golden writes two (comparator.sv 63:14; ExprEmit's call arguments, the sister's ground);
   - the string constants of `uvm_report_info` / `uvm_report_error` calls at 119:104 and 155:113 (not decoded);
   - the interfaces and modules written in included files (input_if.sv, output_if.sv, adder.sv). Golden gives them top.sv's `import uvm_pkg::*;` and ours nothing. This is the same root-file rule as law 1, but at EmitHelpers.h collectMaterializedPkgs, the sister's ground (IU/iu06, iu07).
2. generated/uvm-examples/uvm_param_vif_config_db.sv (230 uhdm-cmp lines, unchanged).
   - The head (evidence/tools/ctsdump.cpp): golden's class-local `this_t` in sfr_config_object, the clone of `tb_params_pkg::SFR_cfg_t = sfr_config_object #(SFR::sfr_addr_width, SFR::sfr_data_width)`, lists type_parameters UVM_ALL_ON and UVM_CHECK_FIELDS, each with an unsupported_typespec named `SFR::sfr_addr_width` / `SFR::sfr_data_width` at 50:27-50:70. Their param_assign's Lhs is a parameter copy parented at the param_assign.
   - That is law 2's pairing applied to package-scoped VALUE arguments, which Surelog compiles through the ref_obj branch into unsupported typespecs. Ours writes no specialization for value arguments at all ("Value parameters of a specialization have no observed Surelog form" in emitClassTsParams).
   - The next writer: a value-argument branch in emitClassTsParams / emitClassPropSpecParams163 / the typedef clone path, building the scoped name's unsupported_typespec, Lhs a fresh copy parented at the param_assign.
3. The tnoc, p733 and p737 rows (await the user's decision).
4. Law 2 and law 5 shapes not taken:
   - emitClassTsParams lists a formal whose argument names the referencing class's own type parameter (TA/ta02, `C #(P, this_type)` inside D #(P)). Golden pushes nothing for it, as emitClassPropSpecParams163 and § classTdSpecParamsForeignHome1 already model.
   - A specialization written as a module variable's type (SP/sp01, sp04, sp06): golden lists the module variable as a logic_net. Older face.
   - A $unit typedef of a specialization used as a module variable (SP/sp07): STRICT_NOTEQUAL depth, typespec copies at the dump tail.
   - Named-argument specializations are left as they were. Surelog's loop reads ordered arguments only, so golden writes none.
5. Law 4: candidates of mixed kinds (a $unit class and a module-local or package class in another file) abstain, since their order was not measured. The single-file face (ou01 to ou04, ou08 to ou10): golden reparents the package's class typedef objects under the importing $unit class, and lists the method's class formal with the package's `this_type` at a different parent. Not decoded.
6. Law 1 at module listings (IU/iu06 a module in an included file declaring a class, iu07 an import in an included file): EmitHelpers.h collectMaterializedPkgs, the sister's ground.
7. The carried lists of passes 466 and earlier (their READMEs).

## Sister-ground faces (reported, not written)

- EmitHelpers.h collectMaterializedPkgs compares the module definition's raw buffer with the file-scope import's raw buffer (`m.location.buffer() == modLoc.buffer()`). Surelog folds includes into the root file, so a module or interface written in an included file, or a file-scope import written in an included file, is in the same FileContent. The fix is law 1's root-file comparison at that site (IU/iu06, iu07; easyUVM's input_if, output_if, adder).
- ExprEmit's call arguments: `exp.compare(rec)` through a handle typed by a class type parameter gets the formal's default `null` appended where golden writes the two written arguments (easyUVM comparator.sv 63:14).

## Process

- The first build started before the sister v11u471's first sweep was seen live. It overlapped about five minutes of that sweep's probe stage; timing only.
- The OU/OV case runs and the UVM OV Surelog runs between 16:15 and 16:35 overlapped the sister's second sweep (/tmp/v11u471_vw), which had started after a quiet check; timing only, no measurement in a sweep.
- Every later build, the census, the runner calls and the sweep waited on drivers/quietwait.py (pass 466's, unchanged).
- The fence list was read into a file by a program and never printed. The census's surelog and uhdm2rtlil runs exclude the fenced names by a regex built from that file. No fenced test was named, opened or run by this pass's own tools; the gate sweep runs the harness as committed.
- No other agent's process was touched. No relative redirect.
- The auxiliary sources of the IU and OU cases (c.sv, a.sv, m.sv, i.sv, p.sv) got their `// § <law>` first line after the first grid run. Their goldens were evicted and IU and OU were rerun on both binaries, with the same verdicts, counts and distances (the grid files are the rerun).
- One slip affecting no measurement: an ad hoc rerun helper replaced the binary path by a pattern that did not match /tmp/r11u468_bin/law*, so four interim reruns (law6 to law9) ran law5. It was found by a trace that did not fire, and fixed in /tmp/r11u468_scratch/rerow.sh. No number in this README comes from those four runs.
