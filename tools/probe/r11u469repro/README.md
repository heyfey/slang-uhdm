# r11u469 — import-copy typespec instances by role (expression/parameter ground, pass 469)

Base fe1067e0c (pass 467). Ground: src/ParamEmit.cpp only. Laws read through
src/LawSwitch.h: `lawOn(469, "R11U469_<LAW>_OFF")`. `R11U469_OFF=1` drops both laws.
`R11U469_TRACE=<dir>` logs each firing through `lawTrace(469, ...)`. There is no src/R*.h, no getenv and no header change.
Binaries (frozen): pristine `/tmp/r11u469_bin/pristine` md5 c9b2f893019899967f666555de7bc9e8
(= main tree build/slang-uhdm); law `/tmp/r11u469_bin/law4` md5 914aca3fab82ab18ffce129b445c3537,
linking slang 12.0.0+545f88b2e. law1 to law3 were intermediate binaries, used only for case runs.

## Goal 2, item (a): the census of the four unreached rows plus the sister ground's two rows (first deliverable)

The runner on pristine at the base (evidence/census/runner_pristine_9rows.csv) gives the same statuses
as results/golden_svtests.csv: all 9 open rows are DIFFERENT. The first differences come from the head
walk (evidence/tools/headwalk.cpp, evidence/census/headwalk_*.txt) plus the listing tools
(clsvars, clsparams, ctsparams). **None of them is on this ground.**

- testbenches/uvm_scoreboard_env.sv, uvm_scoreboard_monitor_env.sv, uvm_scoreboard_monitor_agent_env.sv
  (evidence/census/headwalk_scoreboards.txt, scoreboard_env_faces.txt). Face 1: golden types the formal
  `lib` of uvm_pkg's uvm_sequence_library::m_check with the user class comparator's `this_type`
  (class_typespec this_type @52:13 parented under work@comparator). Ours types it with
  uvm_abstract_component_registry's own this_type. Face 2: the class_typespec `comparator` of
  `comparator comp;` (an unparameterized use of a generic class) carries golden's bogus
  type_parameter UVM_ALL_ON and a param_assign whose Lhs is uvm_pkg's parameter UVM_ALL_ON @196:28.
  Ours writes type_parameter T. This is the same Surelog specialization artefact as
  param_vif_config_db's this_t. It is on the sister's ground: UhdmExporter's class-typespec and specialization writers
  and TypeEmit. Skipping these faces, the head walk reaches EQUAL after 3 heads on all three rows.
- generated/easyUVM/top.sv (evidence/census/easyuvm_sequencer_listing.txt, headwalk_uvm_param_easy.txt).
  The $unit classes declared in the included file sequencer.sv: golden lists the $unit import copies of
  uvm_pkg in each class (vars=52 tds=129 tf=984 params=82 pa=82). Ours lists none (tds=1 tf=5). This is
  reproduced by evidence/sister/EU/eu01 (the class in an included file) against the control eu02 (the same class
  in the importing file, STRICT_EQUAL on pristine). It is the sister's ground: the class listing of
  § classInheritsContainerImports23 in UhdmExporter, which does not reach a class from an included file.
- uvm_use_models_pipelined_get_put: the head is top_tb's interface_inst at 26:1 (ModuleEmit, the sister's).
  The walk finds no further culprit on this ground.
- uvm_param_vif_config_db: the head is class_typespec this_t @50:9 in sfr_config_object, where golden writes
  the specialization alias with the bogus parameters (UhdmExporter, the sister's).
- p733, p737, tnoc: unchanged, awaiting the user's decision.

No head of an open row is on this ground, so the pass took the largest probe-backlog face that is: pass 453's
TS/ts02 / XP/xp05 / VO/vo07 face, which pass 457 decoded and left unwritten and which pass 467 lists as residue
uc02 / VU/vu11.

## Decode

Surelog CompileHelper::importPackage (third_party/Surelog/src/DesignCompile/CompileHelper.cpp) imports in two
separate loops. (1) It clone_tree's the home package's Parameters. The clone is taken after the home package
is elaborated, so every typespec hop is Instanced at the home's ELABORATED package. (2) It clones the param_assigns
of the package being compiled, in each view, so the importer's definition listing carries the home's
DEFINITION view and its elaborated listing carries the home's ELABORATED view. Each hop is a fresh clone, including
the Typedef_alias target. Pristine instanced the first hop at the elaborated home in both roles, and left the alias
target shared with the home's own listing (definition view). uhdm-cmp then paired the home package's two views
(the definition view's UINT:1 size 64 against the elaborated view's size 4: the TS/ts02 face).
An enum import clone that our listing instanced at the importer itself follows the same rule: its home is the
name's qualifier, else vpiImported.

## Laws (src/ParamEmit.cpp, design-final at the end of drainPaNameCopySrc38)

- **§ importCopyTsInstByRole469** (`R11U469_IMPTSINST_OFF`): in an importing package's listing (both views),
  each hop of the typespec chain of a wildcard- or explicitly-imported copy of a typedef-typed package parameter
  (the typespec and its Typedef_alias target) is Instanced by role:
  - the vpiParameter entry: at the home's elaborated view;
  - the param_assign's Lhs and Rhs constant: at the home's view that matches the importer's view.

  The law touches only the exact shape: one or two hops, both Instanced at a view of the home, the qualifier
  naming the home, and no third hop. A hop whose instance must change is replaced by a clone, one per
  (object, wanted instance). A reference shared by roles that want different instances is split.
- **§ importEnumCloneHomeInst469** (`R11U469_IMPENUMINST_OFF`): an enum import clone instanced at the importer
  is re-instanced at the home package, by the same roles.

## Grid (evidence/grid_law4.txt; drivers/grid.sh; every exit code 0 on both binaries)

The `roles` column counts golden-vs-ours per-hop instance-view mismatches (evidence/tools/rolecmp.cpp).

| case | law | pristine | law4 |
|---|---|---|---|
| IR/ir01 typedef param, wildcard (ts02) | 469 | 64 NOT_EQUAL roles 6 | STRICT_EQUAL roles 0 |
| IR/ir02 bit-vector, two params | 469 | 64 NE r8 | STRICT_EQUAL r0 |
| IR/ir03 explicit import | 469 | 64 NE r6 | STRICT_EQUAL r0 |
| IR/ir04 int typedef | 469 | 64 NE r6 | STRICT_EQUAL r0 |
| IR/ir05 untyped/int/ranged (one hop) | 469 | STRICT_EQUAL r4 | STRICT_EQUAL r0 (bytes move) |
| IR/ir06 struct-typed | 469 | STRICT_EQUAL r1 | STRICT_EQUAL r0 (bytes move) |
| IR/ir07 two importers + module | 469 | 312 NE r12 | 0 STRICT_NOTEQUAL r0 |
| IR/ir08 importer's own param of the typedef + home localparam | 469 | 64 NE r12 | 112 NE r0, head later (module top's PB) |
| IR/ir09 signed negative, function read | 469 | 56 NE r6 | 50 NE r0 |
| IR/ir10 range reads another home param | 469 | 62 NE r8 | STRICT_EQUAL r0 |
| IR/ir11 chain c<-b<-a | 469 | 414 NE r18 | STRICT_EQUAL r0 |
| IR/ir12 CONTROL typedef of typedef (3 hops) | abstains | 86 NE | byte-identical |
| IR/ir13 CONTROL typedef from a third package | abstains | 242 NE | byte-identical |
| IR/ir14 CONTROL no importing package | not firing | STRICT_NOTEQUAL | byte-identical |
| IE/ie01 enum param wildcard | enum469 | 358 NE r5 | STRICT_EQUAL r0 |
| IE/ie02 bit-base enum, two params | enum469 | 494 NE r10 | STRICT_EQUAL r0 |
| IE/ie03 importer function + module read | enum469 | 420 NE r5 | 50 NE r0 |
| IE/ie04 explicit import | enum469 | 322 NE r5 | 292 NE r0 |
| IE/ie05 anonymous enum | 469 (bytes move, restored by R11U469_IMPTSINST_OFF) | 72 NE r6 | 72 NE r6 (first difference unchanged) |
| IA/ia01 unpacked-array typedef | abstains | 58 NE | byte-identical |
| IA/ia02 packed 2-D typedef | 469 | 362 NE r6 | STRICT_EQUAL r0 |
| IA/ia03 string/real/integer | 469 | 64 NE r6 | 64 NE r0 |
| IA/ia04 importer localparam + override | 469 | 64 NE r6 | 50 NE r0 |
| IA/ia05 two homes with typedef t | 469 | 64 NE r12 | STRICT_EQUAL r0 |
| IA/ia06 struct with typedef'd member | 469 | 271 NE r1 | 271 NE r0 |
| IA/ia07 $unit import of the importer | 469 | 64 NE r6 | STRICT_EQUAL r0 |
| IA/ia08 class in the importer | 469 | 64 NE r6 | 46 NE r0 |
| IA/ia09 interface + program | 469 | 64 NE r6 | 17 NE r0 |
| IA/ia10 home declared after use | 469 | 64 NE r12 | 50 NE r0 |
| IA/ia11 byte/shortint | 469 | 48 NE r12 | 48 NE r6 (first difference unchanged) |
| IA/ia12 home localparam + param from it | 469 | 50 NE r12 | 64 NE r0, head later (module top's w initializer) |

Tally (from evidence/grid_law4.txt): 31 case dirs. 11 go from NOT_EQUAL to STRICT_EQUAL (ir01 to ir04, ir10, ir11, ie01, ie02, ia02, ia05, ia07), and ir07 goes from NOT_EQUAL to STRICT_NOTEQUAL. ir05 and ir06 stay STRICT_EQUAL with their bytes moving toward golden's instances. 4 controls are byte-identical (ir12, ir13, ir14, ia01).
None moved away: in ir08 and ia12, uhdm-cmp grows only because the head moved later in the walk.
Switches (evidence/switch_check.txt, switch_check_IA.txt): `R11U469_OFF=1` gives pristine's md5 on 31 of 31.
Each law's own switch restores pristine's bytes on its own movers.

## Prediction (written before the sweep; evidence/prediction)

Prediction method:
- The predicate (evidence/tools/pred469.cpp, law4 semantics) ran over 7481 fence-filtered control databases
  of /tmp/intr11u467 (probe 4087, surelog 954, uhdm2rtlil 1606, downstream 804, svtests 30 kept).
- A traced law4 runner census ran over 541 sv-tests candidate rows (sv_candidates.txt). It fires on 21 UVM rows
  (sv_trace_firing_rows.txt), the user packages' copies of uvm_pkg's uvm_field_flag_t parameters. Every one of
  the 541 rows keeps its golden status on law4.

Predicted byte movers (predicted_movers.txt):
- probe: 72 (66 r10v160repro, 2 r11u114repro, and r10uvm114, r10uvm23, r10uvm82, r10v169 one each);
- surelog: BlackBePipeInt, HierPathOverride, MiniAmiq, SeqDriver, each in both modes;
- uhdm2rtlil: ibex_tracer and BitSelectOfParameterPassedToSubmodule, each in both modes;
- downstream: the same two rows.

Every predicted mover must keep its verdict. Instance pointers and clone identity are read by neither uhdm-cmp
on these rows nor by strictcmp's canonical walk.

## Gates (one five-stage sweep on law4, workdir /tmp/r11u469_sw, R11U469_TRACE on)
All five stages pass with regressions=0. Logs are in evidence/sweep/.
- probe: EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions=0 conversions=0 changes=0. The csv is byte-identical to
  the control /tmp/intr11u467/probe.csv. A path-normalized dump comparison of all 4087 databases against the control
  (drivers/r11u469_pdump.sh) finds 72 DIFF and 4015 SAME. The 72 movers are **exactly the 72 predicted by name**, and
  every one stays EQUAL.
- surelog: default 480 + 0, testflags 474 + 0, regressions=0 conversions=0 changes=0. The csv equals the control
  except for the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, regressions=0 conversions=0 changes=0. The csv is identical to the control.
- downstream: IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 of 871. The csv is identical to the control, so
  ibex_tracer and BitSelectOfParameterPassedToSubmodule stay IDENTICAL.
- svtests (run through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty; it exits 1 only
  because the main tree's law index is stale): EQUAL 1931, STRICT_NOTEQUAL 0, DIFFERENT 9, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions=0 conversions=0 changes=0. The csv is byte-identical
  to the control. **No sv-tests row converts.**
- byteverify (SELFCHECK=1, law workdir against the control /tmp/intr11u467; evidence/byteverify/):
  - surelog: 8 of 962 move (BlackBePipeInt, HierPathOverride, MiniAmiq, SeqDriver, each in both modes);
  - uhdm2rtlil: 4 of 1608 move (ibex_tracer and BitSelectOfParameterPassedToSubmodule, each in both modes);
  - downstream: 2 of 805 move (the same two rows).

  These are **exactly the 14 predicted**. Each self-check flags n-1 of n. Every mover keeps its csv status, so uhdm-cmp
  still reads 0 lines on each. The determinism hashes move by law: MiniAmiq default 8be0993ea71f3c2aae3fba92a18513b3 and
  SeqDriver testflags 06ced7e4bceff729dfba35fe99bd77ed, one draw from the sweep, to be re-recorded at landing.
- sv-tests databases: 30 are kept and all 30 differ from the control in raw bytes. Under uhdm-strictcmp --no-canon,
  24 read STRICT_EQUAL (the serialization-order variance). The other 6 are exactly the 6 predicted movers: overriding,
  param_vif_config_db, slave_agent, slave_agent_multi_seq_item, pipelined_get_put and wait_for_signal. They read
  STRICT_NOTEQUAL on depth under the raw walk, because the clone identity changes, and STRICT_EQUAL against the control
  under the canonical walk (evidence/byteverify/svtests_canon_movers.txt).
- trace: the sweep fires on exactly 107 databases (evidence/sweep/trace_firing_per_db.txt): the 72 probe, 8 surelog,
  4 uhdm2rtlil and 2 downstream movers, plus the 21 sv-tests rows of the census with the same per-row counts.
- canaries: ok=52 and ok=16. Both ctcan2 checks pass (ok=58, unknown 1; ok=2, unknown 6).
- binary audit (fence-filtered cmds.txt):
  - surelog: 1523 of 1573 records name law4; the other 50 hold only a Surelog line;
  - uhdm2rtlil: 1740 of 1740;
  - sv-tests: 2346 of 2346;
  - no record names any other slang-uhdm binary.

## Residues (ranked; all wrong on pristine too, none moved away)
1. The four unreached rows and the sister ground's two rows: every head is on the sister's ground (see the census above).
2. ia11 (byte/shortint typedef): the first difference is unchanged, in the home's own listing (an older face).
3. IE/ie05: the anonymous-enum typed parameter; golden writes no typedef hop and the role census is unchanged.
4. ir12: a typedef of a typedef (3 hops). ir13: a typedef from a third package. The law abstains on both by design;
   golden instances the third hop the same way, not written.
5. ir08 / ia12: the next heads in module top (the importer's own parameter of an imported typedef, and a module
   variable initializer reading a home parameter defined from a localparam).
6. ia03, ia06, ia08 to ia10, ir09, IE/ie03, ie04: closer, at later or older faces (class, interface, program
   readers, string/real, struct members).
7. The carried lists of passes 467 and earlier (vu19, the union cases LT/lt02, lt06, VB/vb13, the 465/463 residues).

## Sister-ground faces (reported, not written)
- UhdmExporter class listing (§ classInheritsContainerImports23 family): a $unit class from an included file
  lists no $unit import copies (easyUVM; EU/eu01 vs eu02).
- UhdmExporter / TypeEmit class specialization: golden's bogus UVM_ALL_ON type parameter on an unparameterized
  generic class typespec, and the m_check formal typed by the user's this_type (the 3 scoreboard rows);
  param_vif_config_db's this_t.
- ModuleEmit: pipelined_get_put's top_tb interface_inst.

## Process
One build per law binary. Case runs ran on law1 to law4. One full five-stage sweep ran on law4 and one byteverify against the
master's control /tmp/intr11u467. There was no pristine build or sweep. The first launcher of this restarted run was named
`*sweep.sh`, which matched its own wait pattern (the sister's lesson). Before any stage ran, it was stopped by
its task id and renamed. The wait script now skips every r11u469_ process and the sister's waiter.
The fence list was read into a file by a program and never printed. No fenced test was named, opened or run.
