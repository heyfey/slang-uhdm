# r11u409 — the sv-tests campaign's fifth pass on the expression/parameter ground

Implementer pass on base 09e0c3a9 (passes 401, 402, 404, 403, 406, 405, 408 and
407 landed), ground src/ExprEmit.cpp, src/EmitHelpers.h, src/StmtEmit.cpp,
src/ParamEmit.cpp.  Every law is `§ <name>409` read through
`lawOn(409, "R11U409_<LAW>_OFF")` (src/LawSwitch.h); `R11U409_OFF` drops all of
them; `R11U409_TRACE=<dir>` logs each firing through `lawTrace(409, ...)`.  No
src/R*.h, no getenv, no reader function; include/ and EmitHelpers.h unchanged.

Binaries: pristine 03558f16f8e60eb82098892f0ba8d17d (the worktree's build at the
base, equal to the main tree's build/slang-uhdm), final law binary
bf7324a61d231ac1c7cbdeabf71aa4d9 (/tmp/r11u409_bin/law.bin, frozen before the
sweep).  The pristine reading is the master's control sweep at the base
(/tmp/intr11u407, its csvs equal to the committed results/*.csv); no pristine
sweep was run.  Every case line carries the exit code.

## Verdict per targeted row (sv-tests, results/golden_svtests.csv -> the law sweep)

| row | before | after | laws |
|---|---|---|---|
| generated/hdlconv_std2012/hdlconvertor_std2012_p753_2.sv | DIFFERENT | **EQUAL** | § genGateTermGenvarFold409 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p790.sv | DIFFERENT | **EQUAL** | § genGateTermGenvarFold409 |
| 75 UVM rows (listed below) | DIFFERENT | **STRICT_NOTEQUAL** (72 `differ:col(2)`, 3 `differ:col(9)`) | § modImpTdParamTsClone409 + § defImpArithSize32_409 + § impEnumParamRefNoSize409 + § oobEventTrigHoistNet409 (all four needed), § streamBraceParenMacro409 (col count) |
| generated/uvm_classes_2/uvm_{agent,driver,env,monitor,scoreboard,sequencer,test}_class_2.sv, uvm/uvm_files.sv | STRICT_NOTEQUAL differ:col(4) | STRICT_NOTEQUAL differ:col(2) (CHANGE) | § streamBraceParenMacro409 |

The 75 UVM conversions, DIFFERENT -> STRICT_NOTEQUAL (fresh rows in evidence/svtests_moves.txt):

- `chapter-18/18.10--dynamic-constraint-modification_0.sv` (differ:col(2))
- `chapter-18/18.11--in-line-random-variable-control_0.sv` (differ:col(2))
- `chapter-18/18.11--in-line-random-variable-control_1.sv` (differ:col(2))
- `chapter-18/18.11.1--in-line-constraint-checker_0.sv` (differ:col(2))
- `chapter-18/18.11.1--in-line-constraint-checker_1.sv` (differ:col(2))
- `chapter-18/18.12--randomization-of-scope-variables_1.sv` (differ:col(2))
- `chapter-18/18.12.1--adding-constraints-to-scope-variables_1.sv` (differ:col(2))
- `chapter-18/18.13.1--urandom_1.sv` (differ:col(2))
- `chapter-18/18.13.1--urandom_3.sv` (differ:col(2))
- `chapter-18/18.13.2--urandom_range_1.sv` (differ:col(2))
- `chapter-18/18.13.2--urandom_range_2.sv` (differ:col(2))
- `chapter-18/18.13.2--urandom_range_3.sv` (differ:col(2))
- `chapter-18/18.13.3--srandom_0.sv` (differ:col(2))
- `chapter-18/18.13.4--get_randstate_0.sv` (differ:col(2))
- `chapter-18/18.13.5--set_randstate_0.sv` (differ:col(2))
- `chapter-18/18.14--random-stability_0.sv` (differ:col(2))
- `chapter-18/18.14--random-stability_2.sv` (differ:col(2))
- `chapter-18/18.14--random-stability_3.sv` (differ:col(2))
- `chapter-18/18.14.2--thread-stability_0.sv` (differ:col(2))
- `chapter-18/18.14.2--thread-stability_1.sv` (differ:col(2))
- `chapter-18/18.14.3--object-stability_0.sv` (differ:col(2))
- `chapter-18/18.14.3--object-stability_1.sv` (differ:col(2))
- `chapter-18/18.15--manually-seeding-randomize_1.sv` (differ:col(2))
- `chapter-18/18.5--constraint-blocks_1.sv` (differ:col(2))
- `chapter-18/18.5.1--explicit-external-constraint_2.sv` (differ:col(2))
- `chapter-18/18.5.1--implicit-external-constraint_2.sv` (differ:col(2))
- `chapter-18/18.5.12--functions-in-constraint_1.sv` (differ:col(2))
- `chapter-18/18.5.14--soft-constraints_1.sv` (differ:col(2))
- `chapter-18/18.5.14.1--soft-constraint-priorities_1.sv` (differ:col(2))
- `chapter-18/18.5.14.1--soft-constraint-priorities_3.sv` (differ:col(2))
- `chapter-18/18.5.14.1--soft-constraint-priorities_4.sv` (differ:col(2))
- `chapter-18/18.5.14.2--discarding-soft-constraints_1.sv` (differ:col(2))
- `chapter-18/18.5.14.2--discarding-soft-constraints_3.sv` (differ:col(2))
- `chapter-18/18.5.14.2--discarding-soft-constraints_5.sv` (differ:col(2))
- `chapter-18/18.5.2--constraint-inheritance_1.sv` (differ:col(2))
- `chapter-18/18.5.2--pure-constraint_1.sv` (differ:col(2))
- `chapter-18/18.5.3--set-membership_1.sv` (differ:col(2))
- `chapter-18/18.5.4--distribution_1.sv` (differ:col(2))
- `chapter-18/18.5.5--uniqueness-constraints_1.sv` (differ:col(2))
- `chapter-18/18.5.6--implication_1.sv` (differ:col(2))
- `chapter-18/18.5.7--if-else-constraints_4.sv` (differ:col(2))
- `chapter-18/18.5.8.1--foreach-iterative-constraints_1.sv` (differ:col(2))
- `chapter-18/18.5.8.2--array-reduction-iterative-constraints_1.sv` (differ:col(2))
- `chapter-18/18.6.1--randomize-method_0.sv` (differ:col(2))
- `chapter-18/18.6.2--post-randomize_method_1.sv` (differ:col(2))
- `chapter-18/18.6.2--pre-randomize-method_1.sv` (differ:col(2))
- `chapter-18/18.6.3--behavior-of-randomization-methods_1.sv` (differ:col(2))
- `chapter-18/18.6.3--behavior-of-randomization-methods_2.sv` (differ:col(2))
- `chapter-18/18.6.3--behavior-of-randomization-methods_3.sv` (differ:col(2))
- `chapter-18/18.7--in-line-constraints--randomize_0.sv` (differ:col(2))
- `chapter-18/18.7--in-line-constraints--randomize_2.sv` (differ:col(2))
- `chapter-18/18.7--in-line-constraints--randomize_4.sv` (differ:col(9))
- `chapter-18/18.7--in-line-constraints--randomize_6.sv` (differ:col(9))
- `chapter-18/18.7.1--local-scope-resolution_1.sv` (differ:col(9))
- `chapter-18/18.8--disabling-random-variables-with-rand_mode_0.sv` (differ:col(2))
- `chapter-18/18.8--disabling-random-variables-with-rand_mode_1.sv` (differ:col(2))
- `chapter-18/18.8--disabling-random-variables-with-rand_mode_2.sv` (differ:col(2))
- `chapter-18/18.8--disabling-random-variables-with-rand_mode_3.sv` (differ:col(2))
- `chapter-18/18.9--controlling-constraints-with-constraint_mode_0.sv` (differ:col(2))
- `generated/uvm_classes_0/uvm_agent_class_0.sv` (differ:col(2))
- `generated/uvm_classes_0/uvm_driver_class_0.sv` (differ:col(2))
- `generated/uvm_classes_0/uvm_env_class_0.sv` (differ:col(2))
- `generated/uvm_classes_0/uvm_monitor_class_0.sv` (differ:col(2))
- `generated/uvm_classes_0/uvm_scoreboard_class_0.sv` (differ:col(2))
- `generated/uvm_classes_0/uvm_sequencer_class_0.sv` (differ:col(2))
- `generated/uvm_classes_0/uvm_test_class_0.sv` (differ:col(2))
- `generated/uvm_classes_3/uvm_agent_class_3.sv` (differ:col(2))
- `generated/uvm_classes_3/uvm_driver_class_3.sv` (differ:col(2))
- `generated/uvm_classes_3/uvm_env_class_3.sv` (differ:col(2))
- `generated/uvm_classes_3/uvm_monitor_class_3.sv` (differ:col(2))
- `generated/uvm_classes_3/uvm_scoreboard_class_3.sv` (differ:col(2))
- `generated/uvm_classes_3/uvm_sequencer_class_3.sv` (differ:col(2))
- `generated/uvm_classes_3/uvm_test_class_3.sv` (differ:col(2))
- `testbenches/uvm_resource_db_read_by_name.sv` (differ:col(2))
- `testbenches/uvm_test_run_test.sv` (differ:col(2))

Fresh csv rows quoted from /tmp/r11u409_wd/svtests.csv:

    generated/hdlconv_std2012/hdlconvertor_std2012_p753_2.sv,EQUAL,,equal
    generated/hdlconv_std2017/hdlconvertor_std2017_p790.sv,EQUAL,,equal
    generated/uvm_classes_0/uvm_agent_class_0.sv,STRICT_NOTEQUAL,differ:col(2),differ:col(2)
    generated/uvm_classes_2/uvm_agent_class_2.sv,STRICT_NOTEQUAL,differ:col(2),differ:col(2)


## Laws

| law | switch | site | statement |
|---|---|---|---|
| § modImpTdParamTsClone409 | R11U409_TDPARAMCLONE_OFF | ParamEmit makeParamTs (after § pkgParamBareTdNamedClone18) | A parameter declared with a typedef of a 2-state integral type (`typedef bit [3:0] ft_t`, `typedef int i_t`, `typedef byte b_t`, `typedef bit ft_t`) takes the per-declaration NAMED clone the vector branch already writes for a LOGIC typedef: the clone named by the typedef's bare name, its Typedef_alias reference `<ref prefix>.<typedef>` reaching this view's typedef object (a materialized wildcard-import copy reaching a second bare clone instanced at the home package), every module-context clone instanced at the home package, located at the typedef's target type.  Ours wrote the untyped int_typespec at the type name (bit vector, int) or an unnamed scalar typespec (bit, byte).  The module's own typedef (im07), a parameter typed by an imported typedef (im06), the `$unit`- or module-imported copy of a package parameter (im01, im02: the UVM rows' module copy of `parameter uvm_field_flag_t UVM_ALL_ON`, the v11u408 VU/vu05 and r11u408 UC/uc01 face), an interface (im15).  The package's own listing keeps § pkgParamBareTdNamedClone18; a parameter listed in its own package abstains. |
| § defImpArithSize32_409 | R11U409_DEFIMPARITH_OFF | ParamEmit, the definition-view import copy (after the DEF-view untyped-import sizing) | The definition listing's copy of an imported UNTYPED package parameter (no type, range or signing written) whose default is an arithmetic or resolved-ternary reduction is the package elaboration's constant at size 32, as both elaborated listings already write it; ours took the operation's own width.  Golden `parameter UVM_RECURSION = (UVM_DEEP|UVM_SHALLOW|UVM_REFERENCE)` (enum operands over `bit [27:0]`) is size 32 in every importing module's definition listing where ours wrote 28; 8-, 40- and 64-bit operands are 32 too. |
| § impEnumParamRefNoSize409 | R11U409_IMPENUMSIZE_OFF | ParamEmit, after the typed definition-view import copy sizing | The definition listing's import copy of a parameter typed by a BASE-LESS enum (`typedef enum { ... } e_t`) carries no vpiSize (Surelog has no packed width for it, the § r10fsv3 S5 re-size the elaborated listings already take); ours wrote 32.  Golden uvm_pkg `parameter uvm_core_state UVM_CORE_POST_INIT = UVM_CORE_INITIALIZED`. |
| § oobEventTrigHoistNet409 | R11U409_OOBEVTRIG_OFF | StmtEmit EventTrigger | Inside an OUT-OF-BODY class method a bare trigger of the class's own event (`-> m_uvm_lock_model_complete;` in `uvm_reg_block::lock_model`) falls into the late-binding pool like every bare property read there (classPropRefs, § oobRefVarLocalHoistNet107): the hoisting module mints the implicit wire at the trigger's name, in emission order, and the event_stmt stays unbound.  A ref-less pool entry mints and binds nothing.  An in-body method binds its property and mints none (oe02). |
| § streamBraceParenMacro409 | R11U409_STREAMPAREN_OFF | ExprEmit Streaming (the § streamBraceInMacroBody246 syntax branch) | A stream written as a cast operand inside a macro body, `TYPE'({ << bit { __array }})`, carries the PARENTHESIZED syntax (slang strips the parentheses from the bound expression but keeps their node), so § streamBraceInMacroBody246 saw no streaming syntax and the stream operation kept the operands' range +-1 (uvm_unpack_enumN, uvm_packer_defines.svh 211: golden 211:45-56, ours 46-55).  The parentheses are looked through. |
| § genGateTermGenvarFold409 | R11U409_GATEGENVAR_OFF | ExprEmit, the bit_select and var_select index sites (helper gateGenvarIdxFold409) | A gate, udp or switch terminal inside an ELABORATED generate scope (Surelog lists such primitives only in the elaborated instance) has every select index naming the loop's genvar substituted: `UINT:<n>`, size 64, vpiUIntConst, decimal decompile, at the genvar token (the § genvarConnFold encoding); an index that is arithmetic over the genvar and literals folds whole, UINT for `+` and INT once `-` or `*` takes part, at the top operation's LEFT operand (`2*i` for `2*i+1`).  Ours kept a ref_obj named `i` (or the operation). |

## How the UVM head moved (uvm_classes_0/uvm_agent_class_0, uhdm-cmp on the kept pair)

1. Base: the elaborated module copy `work@top.UVM_ALL_ON` of `parameter uvm_field_flag_t UVM_ALL_ON` was an int_typespec at the type name where golden has the cloned `bit_typespec uvm_field_flag_t` chain (the r11u408 UC/uc01 face).  § modImpTdParamTsClone409 writes the clone; cases IM.
2. Next head: `parameter UVM_RECURSION = (UVM_DEEP|UVM_SHALLOW|UVM_REFERENCE)` (uvm_object_globals.svh 153) in the module's definition listing, golden size 32, ours 28.  § defImpArithSize32_409; cases EW.
3. Next head: `parameter uvm_core_state UVM_CORE_POST_INIT = UVM_CORE_INITIALIZED` (714), golden no vpiSize, ours 32.  § impEnumParamRefNoSize409; cases EN.
4. Next head: the module's net vector, size mismatch: golden mints `logic_net work@top.m_uvm_lock_model_complete` (uvm_reg_block.svh 1164:10-35, the `->` trigger in the out-of-body `uvm_reg_block::lock_model`), ours none.  § oobEventTrigHoistNet409; cases OE.
5. uhdm-cmp reads 0 lines; uhdm-strictcmp reads `differ:col(4)`: two stream operations at uvm_packer_defines.svh 211 (§ streamBraceParenMacro409, cases SP) and two begin blocks at uvm_object_defines.svh 804 (a sister-ground face, below).  After the five laws the row reads `differ:col(2)`.

Attribution measured on that row with each switch alone on the law binary: R11U409_TDPARAMCLONE_OFF uhdm-cmp 80 lines, R11U409_DEFIMPARITH_OFF 64, R11U409_IMPENUMSIZE_OFF 62, R11U409_OOBEVTRIG_OFF 1321222 (the module_inst), R11U409_STREAMPAREN_OFF 0 lines with STRICT_NOTEQUAL col (the col(4) reading).

## Gates (one five-stage sweep on the final law binary, workdir /tmp/r11u409_wd, quiet machine after the master's r11u410 integration sweep)

* probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0 conversions=0 changes=0; probe.csv byte-identical to results/golden_probe.csv.
* surelog: default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL standing), regressions=0 conversions=0 changes=0; the csv equal to the control's apart from the two LowMem log-path detail texts.
* uhdm2rtlil: 803 CMP_EQUAL + 1 CMP_NOTEQUAL (stamped_gen_param) + 67 SLANG_REJECT in both modes, regressions=0 conversions=0 changes=0; csv identical to the control.
* downstream: IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 of 871, not identical and not excused 0; csv identical to the control.
* sv-tests (the worktree has no UVM tree, so the stage ran through the main tree's scripts/check_svtests.py read-only, with `--baseline` the worktree's results/golden_svtests.csv, the main tree at the base 09e0c3a9): EQUAL 1644 -> 1646, STRICT_NOTEQUAL 20 -> 95, DIFFERENT 276 -> 199, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; **regressions=0 conversions=77 changes=8** (every one named above).
* sweep exit code: corpus stages 1 on the stale law index alone (cases added; tests/LAWS.md regenerated in the patch), sv-tests stage 0.
* canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); ctcan2 PASS on both csvs (EXPECT_UNKNOWN=1 / 6).
* binary audit: 3315 fence-filtered corpus cmds.txt, 3265 name /tmp/r11u409_bin/law.bin, 0 another binary, 50 hold no slang line; 2346 of 2346 sv-tests cmds.txt name the law binary.
* byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law workdir against the master's control /tmp/intr11u407, same-length names): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805; the self-checks flag 961/962, 1607/1608, 804/805.
* trace census (R11U409_TRACE over the whole sweep, evidence/trace_rows.tsv): 0 firings in the probe, uhdm2rtlil and downstream stages; in the surelog stage only § oobEventTrigHoistNet409 on BuildUVMPkg default and testflags (`m_uvm_lock_model_complete`: the row compiles the 1800.2 uvm_pkg with no importing module, so the ref-less pool entry finds no hoisting module and mints nothing; both databases byte-identical to the control, as byteverify reads); 161 sv-tests rows fire (§ oobEventTrigHoistNet409 158, § streamBraceParenMacro409 156, § modImpTdParamTsClone409 146, § defImpArithSize32_409 146, § impEnumParamRefNoSize409 146, § genGateTermGenvarFold409 3: p753_2, p790, p791).
* prediction before the sweep (evidence/prediction_scan.py, a fence-filtered SOURCE scan of the two corpora for each law's syntactic trigger, evidence/prediction_scan.txt): § modImpTdParamTsClone409 0 test directories, § streamBraceParenMacro409 0, § genGateTermGenvarFold409 6, § oobEventTrigHoistNet409 19, § impEnumParamRefNoSize409 83, § defImpArithSize32_409 413 (supersets); no byte mover predicted because a CMP_EQUAL row cannot hold any of the six shapes in a judged position (each shape is a uhdm-cmp difference on its own).  The scan did not cover the UVM library trees, so BuildUVMPkg's firing was found by the trace census, not predicted; it moved no byte.
* away census on the 82 sv-tests rows where a law fired and the status did not change (evidence/away.py, normalised dump line-multiset distance to golden, control database vs law database): 82 of 82 toward golden, 0 at the same distance, 0 away (69 DIFFERENT rows, the 8 STRICT_NOTEQUAL col(4) -> col(2) rows, and 5 SLANG_ONLY uvm rows measured against the cached Surelog database; evidence/away.tsv).  The heads quoted in evidence/heads_uvm.txt and heads_non.txt were read with an intermediate binary carrying the four UVM laws and § streamBraceParenMacro409 (before § genGateTermGenvarFold409 and the typed gate on § impEnumParamRefNoSize409), on the 296 DIFFERENT and STRICT_NOTEQUAL rows run through drivers/run.sh on a quiet machine.

## The case grid (tools/probe/r11u409repro/cases, drivers/grid.sh, evidence/grid.txt)

71 case dirs in EN, EW, GV, IM, OE and SP: 33 NOT_EQUAL -> STRICT_EQUAL, 2 STRICT_NOTEQUAL -> STRICT_EQUAL (SP/sp03 col, sp05 line), 23 STRICT_EQUAL controls byte-identical on both binaries, 15 NOT_EQUAL on both (10 moving toward golden by dump distance, 5 at pristine's bytes: ew10, ew13, im11, im13, oe05; none away), every exit 0; each group's own switch restores pristine's bytes and exit code on 71 of 71 and R11U409_OFF on 71 of 71.

| group | law | cases |
|---|---|---|
| IM | § modImpTdParamTsClone409 | im01 `$unit` import, im02 module import, im04 `typedef int`, im05 `bit [W-1:0]` with a computed parameter, im06 module parameter typed by an imported typedef, im07 module's own typedef, im12 `typedef bit`, im15 interface, im18 module typedef also used as a type override: NOT_EQUAL -> STRICT_EQUAL; im03 (logic, the existing branch) control; im08 (byte: the `$unit` design copy is the sister's impTsCopy402, no byte branch), im09 (a signed bit vector: the Rhs INT constant's typespec), im10/im11 (the folded read of the imported parameter in a cont_assign carries a select-named ref_typespec: not written), im13 (class parameter), im14 (function parameter), im16 (typedef from another package), im17 (`p::ft_t` written qualified) stay NOT_EQUAL, toward or at pristine's distance |
| EW | § defImpArithSize32_409 | ew01 (enum OR, the UVM shape), ew05 (40-bit), ew06 (8-bit `+`), ew11 (module import), ew12 (64-bit `-`): NOT_EQUAL -> STRICT_EQUAL; ew02, ew03, ew04, ew08 (typed), ew14 (`$bits`) controls; ew07 (ternary: the elaborated listings write 64 where golden 32), ew09 (a 40-bit value: golden truncates to 32 bits), ew10 (`[27:0]` ranged: elaborated listings), ew13 (ternary over a sized literal) stay NOT_EQUAL |
| EN | § impEnumParamRefNoSize409 | en01, en05, en06, en07, en10, en12 NOT_EQUAL -> STRICT_EQUAL; en02 (no import), en03 (module enum), en04 and en11 (`bit [1:0]`/`logic [3:0]` base), en08 (`int` base), en09 (`byte` base) controls |
| OE | § oobEventTrigHoistNet409 | oe01, oe07 (two methods share one wire), oe08 (an inherited event) NOT_EQUAL -> STRICT_EQUAL; oe02 (in-body method), oe03 (`@e` then `->> e`), oe06 (a method-local event), oe09 (no importing module), oe10 (the module declares `e`) controls; oe04 (`$unit` import: the class listing's extra vpiMethod, sister) and oe05 (`-> this.e`) stay NOT_EQUAL |
| SP | § streamBraceParenMacro409 | sp03, sp05 STRICT_NOTEQUAL -> STRICT_EQUAL; sp01, sp02, sp04 (no macro), sp06 (sliced, double parentheses), sp08 (no macro, parentheses) controls; sp07 (a `byte` stream cast to a typedef) NOT_EQUAL on both |
| GV | § genGateTermGenvarFold409 | gv01, gv03, gv04 (`c[i+1]`), gv05 (udp), gv06 (nested if-generate), gv07 (the p753_2 module), gv10 (tran, bufif1), gv11 (`i*2`, `i-1`, `2*i+1`: INT) NOT_EQUAL -> STRICT_EQUAL; gv02 (cont_assign) control |

Residue cases with no law (first line `// residue`): evidence/residue_cases/TP (the begin after a token paste, sister ground), CR (an imported parameter read folded in a cont_assign), GV (gv08, gv09: a gate terminal index naming a parameter).

## Goal 1

No SURELOG_ONLY, BOTH_REJECT or SLANG_CRASH row of results/golden_svtests.csv carries an exporter error: every detail is an upstream slang diagnostic (the UVM 1800.2 `design element does not have a time scale` rows, the should_fail tests), unchanged from pass 407's census.  Black-parrot stays behind pass 403's size guard and SURELOG_CRASH; rsd is SURELOG_CRASH.  Neither was measured again in this pass (no change on that path).

## Residues (ranked by rows; all wrong on pristine too, none moved away)

1. The 72 converted UVM rows' `differ:col(2)` and the eight uvm_classes_2/uvm_files rows: the begin of `__m_uvm_execute_field_op` at uvm_object_defines.svh 804 (`m_uvm_field_op_begin`, `if (!((FLAG)&UVM_NO``OP)) begin`): golden's column is 3 (COMPARE) or 1 (PRINT) to the right of ours.  Decoded on residue cases TP: a begin after a token paste in a macro body is 3 columns right of ours for both `COPY` and `COMPARE` with a literal flag (tp01, tp03, tp04), and matches with no paste (tp02, tp05, tp06).  The column comes from setLoc's macro layout model (UhdmExporter locLineCol / pp166): sister ground.  This is the last strict difference on those 80 rows.
2. 67 UVM rows still DIFFERENT, heads (uhdm-cmp, evidence/heads_uvm.txt): 17 rows headed at a package (12 at uvm_pkg, 5 at a user package; on uvm-examples/uvm_ac_config_db the listing order differs: golden lists uvm_pkg first, ours the user package sfr_test_pkg; UhdmExporter/ModuleEmit), about 24 interface rows (clk_gen_if, input_if, mod_if: the chapter-16 interface port nets, pass 408's residue 2), 11 logic_typespec heads in the chapter-16 interface rows, class listings (uvm_agent, uvm_sequence_library, packet_out), 2 class_var `find_blocks` heads; all sister ground.
3. Non-UVM DIFFERENT heads on this ground left: the basejump macro-built bounds (bsg_async_fifo 99:34 `(width_p-1)`, bsg_mem_1r1w/1rw_sync_mask_write_var `(i+1)*mask_width_p`, bsg_round_robin_fifo_to_fifo, bsg_nonsynth_dpi_rom, bsg_cache 766:25, bsg_sync_sync's `` `bss_max_block `` macro name), bsg_wormhole_router_decoder_dor (`3'd0` decompile), typedef_test_9 (a range bound `k` folded by golden), class_test_51 (`$bits` in a class parameter), tnoc 333:14, the 3 bsg_cache wormhole rows (`$bits` of an enum in a macro-declared struct, TypeEmit), p835 (a udp `initial`), p600, p733.
4. The gate terminal index naming a parameter (residue GV gv08, gv09: UINT size 32 with a select-named ref_typespec) and p791's gen-scope net listing (its next head after § genGateTermGenvarFold409).
5. IM residues above (byte design copy, signed vector Rhs, class and function parameters, qualified typedef), EW ew07/ew09/ew10/ew13 (elaborated-listing sizes), OE oe05.
6. Not reached: passes 401, 403, 405 and 407 residue lists, class_test_56 to 58, p292, p770, fx68k, scr1, the 70 probe residues.

## Sister-ground faces (reported, not written)

- UhdmExporter setLoc / locLineCol (pp166 macro layout): a begin after a token paste in a macro body sits 1 to 3 columns right in golden (uvm_object_defines.svh 804; residue TP).  The last strict field of 80 UVM rows.
- UhdmExporter impTsCopy402 has no byte_typespec branch, so the `$unit` design copy of a `typedef byte` parameter shares (IM/im08).
- TypeEmit thisImplicitNetBoth38: the `this` implicit net is listed earlier than golden in the module's net vector (uhdm-cmp does not read the order; strict canonicalises it).
- TypeEmit/ModuleEmit class_typespec spans in the module listing (uvm_object_wrapper 717:1-40 golden, ours 717:1-19).
- Package listing order in the uvm-examples rows (user packages before uvm_pkg).
- The `$unit` design function listing order (chapter-18 18.7 rows' col(9): uvm_hdl_check_path vs the test's F).
- The class listing's extra out-of-body vpiMethod under a `$unit` import (OE/oe04).
- The chapter-16 interface rows and the class listings named in residue 2.

## Process

- The IMPLEMENTER'S SLIPS, none affecting a measurement: three light runner calls on three UVM rows ran at 07:4x while the sister verifier's sweep was in its sv-tests stage; every later runner call and the sweep waited for a quiet machine (the master's r11u410 integration sweep ran 07:55-08:54 and this pass's sweep started after it).  Temporary fprintf and watchpoint instrumentation was added to ExprEmit, ParamEmit, UhdmExporter, ModuleEmit, TypeEmit, StmtEmit and TaskFuncEmit in the worktree to locate size writers and restored from saved copies before every law build (the sister files are byte-identical to the base: `git diff --stat` names only ExprEmit, ParamEmit and StmtEmit).  While reading tests/FENCED.md to find the fence line, its table row was printed with the name masked by a camel-case filter; no fenced source, database or command record was opened or run, every tree-wide reader filtered on the `FENCED=` line of tools/probe/r11u107repro/canaudit.sh first.
- No other agent's process touched; nothing written outside the worktree and /tmp/r11u409_*.

