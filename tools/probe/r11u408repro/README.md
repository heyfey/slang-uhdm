# r11u408 — module/type ground, the sv-tests campaign's fourth pass on this ground

Base e748204c (pass 406). The pristine reading is the master's control sweep at
the base (the measurement budget: no pristine sweep). The pristine binary built
in the worktree is byte-identical to the main tree's (md5
cd23107a552e7e853195ee4a4923716f). The law binary's md5 is
aa17501c936ae1e9bdd790be09149b36.

## Laws (all read through src/LawSwitch.h; `R11U408_OFF` drops all five; `R11U408_TRACE=<dir>` logs each firing)

| law | switch | file | statement |
|---|---|---|---|
| § ifaceClassNotListed408 | R11U408_IFACECLASS_OFF | UhdmExporter (design + package listings), ModuleEmit (module listing) | An `interface class` is not in Surelog's database: no class_defn in allClasses, in a package or in a module, and a class that `implements` it lists no link to it. |
| § unitTaskNotListed408 | R11U408_UNITTASK_OFF | TaskFuncEmit (emitTaskFuncs, the design listing) | A `$unit` task is not on the design's vpiTaskFunc. `$unit` functions are listed. The task object is still built, so a call to it keeps its link. |
| § classBoundedQueueStatic408 | R11U408_CLSBOUNDEDQ_OFF | UhdmExporter (the class-property array_var) | The class-property twin of § boundedQueueVarStatic406. A bounded queue property is a vpiArrayType 1 array_var with its written range `[$:max]`. The left bound is the `$` constant. The right bound is the folded maximum (size 64) at its tokens, and its type follows ExprEval::reduceExpr: UINT for a literal, a parameter, or a `+` of such operands. It is INT for `-`, `*` or `/`, and then it spans the leftmost token. A bound that names a parameter carries a reference, named after the property, to an int_typespec at the parameter's `int` keyword. |
| § genericClassNoDefaultListed408 | R11U408_GENCLSNODEF_OFF | UhdmExporter (design + package listings, emitClassParameters) | A parameterized class with a parameter that has no default is still in allClasses (or the package listing), built from slang's invalid specialization. The default-less parameter keeps its written `int` typespec and has no value, and its param_assign holds the Lhs alone at the parameter name. The law does not fire on a type parameter or on a property whose type is in error (GC gc04, gc05 keep pristine's bytes). |
| § classImpTdParamTsClone408 | R11U408_CLSIMPTSCHAIN_OFF | ModuleEmit (importParamCopy82 / importPaCopy82); UhdmExporter (impTsChain402 made non-static, with a separator argument) | A class's copy of a `$unit`-imported package parameter whose type is a typedef gets its own copied alias chain, like the design copy (§ unitImpTdParamTsClone402). The right-hand constant's reference gets one too. Golden: `work@a::UVM_ALL_ON -> uvm_field_flag_t -> work@a::UVM_ALL_ON::uvm_field_flag_t -> uvm_field_flag_t`. Ours shared the package's chain, whose alias target is `uvm_pkg::uvm_field_flag_t`. |

There is no src/R*.h, no getenv and no reader function. include/ is unchanged.

## Grid (cases/, 34 case dirs; each case's first line names its law)

`evidence/grid.txt` has one line per case: the pristine and law exit code, the uhdm-cmp line count, the strict verdict, the md5, and whether `R11U408_OFF` restores pristine's bytes and exit code. Golden comes from `surelog -parse -nobuiltin -nocache -sv dut.sv`, and ours from `dut.sv --single-unit --nobuiltin` (drivers/run1.sh).

- IC (§ ifaceClassNotListed408): ic01-ic05, ic07, ic08 go NOT_EQUAL -> STRICT_EQUAL. ic06 moves 638 -> 16 cmp lines. Its residue is a variable typed by an interface class: golden writes a logic_net with an unsupported_typespec named `ib`, where we write a class_var.
- UT (§ unitTaskNotListed408): ut01, ut04 and ut05 go NOT_EQUAL -> STRICT_EQUAL. ut03 and ut06 (functions) are STRICT_EQUAL controls with unchanged bytes. ut02 (a module calls the `$unit` task) stays NOT_EQUAL with 60 lines on both binaries and exit 0 on both. Its remaining difference is the call: golden writes an unlinked func_call. That is the expression ground (sister-ground face below).
- CQ (§ classBoundedQueueStatic408): cq01-cq08 all go NOT_EQUAL -> STRICT_EQUAL (cq06 is the uninstantiated p158 shape, `[$:DEPTH-1]` with DEPTH 1).
- GC (§ genericClassNoDefaultListed408): gc01, gc02, gc03 and gc06 go NOT_EQUAL -> STRICT_EQUAL. gc04 (type parameter) and gc05 (an error-typed property) abstain with pristine's bytes.
- UC (§ classImpTdParamTsClone408): uc03 goes NOT_EQUAL -> STRICT_EQUAL. uc01 moves 112 -> 80 lines, and its head moves to the module copy (sister-ground face below). uc02 (typedef of a typedef), uc05 (a class inside a module) and uc06 (a class in an importing package) change bytes at the same cmp count. uc04 (an untyped vector parameter) is a STRICT_EQUAL control with unchanged bytes.
- R11U408_OFF gives pristine's bytes and exit code on 34 of 34. Each group's own switch (CQ CLSBOUNDEDQ, GC GENCLSNODEF, IC IFACECLASS, UC CLSIMPTSCHAIN, UT UNITTASK) gives pristine's bytes on 34 of 34.
- Downstream (drivers: ds.one) on the class-free UT cases ut01, ut03, ut04, ut05 and ut06 reads IDENTICAL on both binaries.
- No case went from an equal status to a worse one. No case changed its exit code.

## Census before the sweep (by name)

- Probe: the law binary ran with a trace on all 4087 tests/probe cases (fence-filtered list). There were 0 firings of any law. The positive control (GC gc01, UC uc01) wrote its trace lines.
- Corpus: the trace over the full sweep (surelog, uhdm2rtlil and downstream command lines) records 0 firings. Every trace file in the trace dir comes from the sv-tests stage.

## Gate (one five-stage sweep on the law binary, workdir /tmp/r11u408_lw)

One five-stage sweep: `tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil downstream"` from the worktree with `SLANG_UHDM` set to the frozen law binary, then the sv-tests stage through the main tree's scripts/check_svtests.py, read-only. Each stage was scored against the committed baselines at the base.

- probe: EQUAL 4018, STRICT_NOTEQUAL 69 of 4087; regressions=0 conversions=0 changes=0.
- surelog: default CMP_EQUAL 480, testflags CMP_EQUAL 474 (954 + 0); regressions=0 conversions=0 changes=0.
- uhdm2rtlil: 803/1/67 in both modes (1606 + 0); regressions=0 conversions=0 changes=0.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871. Not identical and not excused: 0.
- sv-tests: EQUAL 1569 -> 1598, STRICT_NOTEQUAL 9 -> 16, DIFFERENT 361 -> 325, BOTH_REJECT 303, SURELOG_ONLY 76, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; **regressions=0 conversions=36 changes=0**. On rows whose status stayed the same, no strict column changed.
- byteverify of the law workdir against the master's control /tmp/intr11u406, with SELFCHECK: surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805 movers. The probe compare is by normalised dump, because the raw bytes carry the worktree path: 4087 of 4087 are identical, and a negative control on two different databases sees the difference.
- Canaries: ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil). Both ctcan2 checks pass (EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6).
- Binary audit: 3315 fence-filtered cmds.txt. 3265 name the law binary and none names another binary. The other 50 hold no slang line.
- Trace census on the sv-tests stage: 190 rows with a firing (classImpTdParamTsClone408 153, ifaceClassNotListed408 28, genericClassNoDefaultListed408 6, unitTaskNotListed408 5, classBoundedQueueStatic408 4). There are 0 firings in the four corpus stages.
- Away census (evidence/away_census.txt): each fired row's sorted, normalised dump, control vs law, measured by distance to golden. 154 rows are toward golden, including every UVM row still DIFFERENT. 2 are the same (class_test_26 and _27, EQUAL on both binaries). 34 read "AWAY" only because nothing could be compared: 29 are this pass's conversions to EQUAL, whose databases the stage does not keep, and 5 are SLANG_ONLY rows with no Surelog golden (18.5.11--static-constraint-blocks_1 and the four uvm-examples rows uvm_overriding, uvm_slave_agent, uvm_slave_agent_multi_seq_item, uvm_wait_for_signal). 0 rows moved away from golden.

## sv-tests rows before -> after

The 36 conversions are in evidence/svtests_conversions.txt, all attributed by trace:

- § ifaceClassNotListed408, DIFFERENT -> EQUAL: chapter-8/8.26.2--implements.sv, 8.26.2--implements_extends.sv, 8.26.2--implements_multiple.sv, 8.26.3--type_access_extends.sv, 8.26.6.1--name_conflict_resolved.sv, 8.26.6.2--parameter_type_conflict.sv, 8.26.6.3--diamond_relationship.sv, 8.26.7--partial_implementation.sv, generic/iface/iface_class_test_0.sv, _1, _2, _9, _10, generic/class/class_test_25.sv, class_test_28.sv, class_test_29.sv, and generated/hdlconv_std2017/hdlconvertor_std2017_p199.sv, p200_2.sv, p202.sv.
- § ifaceClassNotListed408 + § classBoundedQueueStatic408, DIFFERENT -> EQUAL: hdlconvertor_std2012_p158.sv, p160_1.sv, hdlconvertor_std2017_p194.sv, p196.sv.
- § unitTaskNotListed408, DIFFERENT -> EQUAL: hdlconvertor_std2017_p230.sv, p332.sv, p530.sv and p728.sv. p728's head was the `$unit` task listing, after pass 403's § unitFwdCallNoLink403.
- § genericClassNoDefaultListed408, DIFFERENT -> EQUAL: generic/class/class_test_9.sv, class_test_11.sv. p334 moves its head to a function return typespec (residue 4).
- § classImpTdParamTsClone408, DIFFERENT -> STRICT_NOTEQUAL (col): generated/uvm_classes_2/uvm_agent_class_2.sv, uvm_driver_class_2.sv, uvm_env_class_2.sv, uvm_monitor_class_2.sv, uvm_scoreboard_class_2.sv, uvm_sequencer_class_2.sv, uvm_test_class_2.sv. The 4 objects that still differ are col/endcol inside uvm_pkg, on the expression ground.

## Residues (ranked by rows)

1. THE UVM ROWS (about 107 rows headed at the class copy of UVM_ALL_ON). § classImpTdParamTsClone408 moves their head past the class copy. The next head is on the sister's ground: the ELABORATED MODULE copy of a `$unit`-imported typedef-typed bit-vector parameter (`work@top.UVM_ALL_ON`) is written as an int_typespec at the type name's tokens. Golden writes the cloned `bit_typespec uvm_field_flag_t` chain there. The writer is ParamEmit makeParamTs / patchParamTypespecs (pendingParamTs). UC uc01 shows the same face in 13 lines. A logic-typed vector (uc03) is already right. Once that face is written, the generated/uvm_classes rows show what follows: four col/endcol differences inside uvm_pkg, on macro-built operations (uvm_packer_defines.svh:211) and on the begin of __m_uvm_execute_field_op (uvm_object_defines.svh:804). Those are on the expression ground.
2. The chapter-16 UVM interface rows (11 rows: 16.12-*, 16.14, 16.17, 16.7-uvm, 16.2-*-uvm). The head is the interface port net's logic_typespec, reached through uhdm-cmp's visited map against our `uvm_mem::get_addresses` `ref uvm_reg_addr_t addr[]` typespec (and `b` for the 16.2 rows). This was not decoded.
3. A variable typed by an interface class (IC ic06). Golden writes a logic_net with an unsupported_typespec named after the type. chapter-8/8.26.3--type_access_implements is the same face: `ihello::int_t` is an unsupported_typespec in golden.
4. A default-less generic class with a type parameter, or with a property sized by the unset parameter (GC gc04, gc05: golden lists the class unfolded). Also the function return typespec in p334: golden keeps the unfolded `[ENCODE_W-1:0]` range.
5. Forward typedefs at `$unit` (generic/typedef/typedef_test_0). Golden lists two typedef entries, one an alias of the other. We list none.
6. The basejump rows: about 36 of them are the sister pass 405's. The remaining rows on this ground are those named in the brief (the seven skipped definitions, the macro-struct lines). They were not reached.

## Sister-ground faces (reported, not written)

- ParamEmit makeParamTs / patchParamTypespecs: the elaborated module copy of a `$unit`-imported typedef'd 2-state vector parameter is an int_typespec where golden has the cloned chain. This is the next head of about 100 UVM rows (UC uc01).
- ExprEmit / StmtEmit: a module's call to a `$unit` task. Golden writes an unlinked func_call named after the task (UT ut02). With § unitTaskNotListed408 our task_call still links to the unlisted task object.
- ExprEmit: col/endcol of macro-built operations and of begin blocks inside uvm_pkg (uvm_packer_defines.svh:211, uvm_object_defines.svh:804). This is the only difference left on generated/uvm_classes_2/uvm_agent_class_2.

## Goal-1 census at the base

Every SURELOG_ONLY detail of results/golden_svtests.csv is an upstream slang diagnostic (the should_fail tests, the time-scale error of the five basejump clock rows and the biquad UVM row, unknown modules in utd-sv, duplicate definitions), except tnoc's `expression kind: Invalid`, which is the sister's. BOTH_REJECT, SLANG_ONLY and SURELOG_CRASH hold no exporter message on this ground: uvm_alu_config_analysis is a missing file, and the black-parrot, rsd and p612 rows are Surelog crashes. No row of this ground is at an exporter error.

## Process

- The pass ran targeted runner calls (scripts/svtests/svtests_matrix.py --paths-file, 1 or 2 jobs) on the 134 non-UVM rows and on single rows while the sister verifier's sweep was live. They were light, and none of them was a sweep.
- The one full sweep started after `pgrep` read no sweep process. The sv-tests stage ran through the main tree's scripts/check_svtests.py, read-only, because a worktree has no UVM tree.
- While reading tests/FENCED.md to learn where the machine-readable fence line lives, the pass printed that file's header table to its own terminal. No fenced source, database or command record was opened, and no fenced test was run. Every tree-wide list was filtered on the `FENCED=` line first.
- Nothing was written outside the worktree and /tmp/r11u408_*.
