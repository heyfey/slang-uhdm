# r11u464: module/type ground, pass 464 (sv-tests campaign)

Base dbf4f9529. Production file: src/UhdmExporter.cpp only (TypeEmit, ModuleEmit, TaskFuncEmit, uhdm_main.cpp, the sister's four files, include/ and src/LawSwitch.h unchanged). Six laws, each read through src/LawSwitch.h as lawOn(464, "R11U464_<LAW>_OFF"); R11U464_OFF drops all six; R11U464_TRACE=<dir> logs each firing through lawTrace(464, ...). No src/R*.h, no getenv, no reader function.

Binaries (frozen, chmod 555): pristine /tmp/r11u464_bin/pristine (md5 d59c9ff65c1b72790be68a21e7794397, byte-identical to the main tree's build/slang-uhdm and to this worktree's first build); law /tmp/r11u464_bin/law7 (md5 in evidence/binaries.md5). Builds: pristine, law1, law2, law3, dbg4, dbg5 (two trace-detail builds of the same law), law6, law7.

## Verdicts

| row | before (base) | after (law7) |
|---|---|---|
| generated/uvm-examples/uvm_many_to_one.sv | DIFFERENT (decompile:; head: module work@top typedef listing 128 vs golden 130) | **STRICT_NOTEQUAL differ:type(1)**, uhdm-cmp 0 lines (CONVERSION) |

Fresh csv row (evidence/svtests_law7.csv): `generated/uvm-examples/uvm_many_to_one.sv,STRICT_NOTEQUAL,differ:type(1),differ:type(1)`.

The row needed three faces in turn, each found after the previous one was written:
1. module top's typedef listing missing b_pkg::B_sequencer and c_pkg::C_sequencer (law 1, module and design listings);
2. the design's vpiTaskFunc listing: 2937 entries where golden has 979 (law 2);
3. the parent of the specialization base b_pkg::A_sequencer: golden class `test`, ours module `top`, seen on its type parameter's full name (law 3).

What remains on the row: a first strict difference at record #67925, where golden has class_typespec uvm_object_wrapper and ours has unsupported_typespec idx. This is the foreach loop variable in b_pkg's clone of uvm_pkg::uvm_init (uvm_globals.svh 373:29). All 687 differing strict records are foreach loop-variable typespecs in clone bodies (golden int_typespec or the class/array element typespec, ours unsupported_typespec or a different kind). That is the sister's StmtEmit face (see Sister-ground faces).

## Laws

1. § unitImpTransitiveTds464 (R11U464_UNITIMPTRANS_OFF; UhdmExporter fileScopeImportTypedefs and the design typedef listing)
   - A compilation-unit-scope `import p::*` lists p's transitive typedefs at the module and at the design.
   - Why: CompileModule replays the file's import items through importPackage, which copies p's whole DataTypeMap. A package's map already holds what its own body imports copied in. The design listing is the union of the FileContents' maps.
   - Order rule, as in § pkgLateTsEarlierPkgOnly454v: an import edge counts only when the imported package is declared before the importer. Only body imports count.
   - Cases: UT/ut01 to ut08. ut02 is the order control: golden lists neither a_t nor b_t at top.
2. § unitImpTfNameDedup464 (R11U464_UNITTFDEDUP_OFF; the design vpiTaskFunc listing)
   - importPackage appends a subroutine to the FileContent's list only when no entry has its VpiName yet. So within one file, the first import's subroutine of a name wins.
   - The key is Surelog's VpiName: the bare name, or `C::m` for an out-of-body method. Ours reads it off the full name below the package.
   - Applied only when every compilation-unit wildcard import sits in one root file.
   - Cases: UF/uf01 to uf05. On uf05 the law's part is golden's; the head is a class-method face elsewhere.
3. § unitClsListsSpecBase464 (R11U464_UNITCLSBASE_OFF; enumTdLastWriter214's class writer)
   - The $unit class writer, which writes after every module, also takes a package class typedef with no typedef-alias ref (the specialization group's base). § classTdAliasLastWriter214 left that typedef out.
   - The base's own type and value parameters' stored full names move to the class chain `<class>::<pkg>::<T>::<P>`.
   - Only the class cell is added.
   - Cases: UB/ub01 to ub06. ub03 (a class inside a module) and ub05 (no $unit class) are controls.
4. § clsShortRealAliasElem464 (R11U464_CLSSRALIAS_OFF; classAssocElemVar)
   - Goal 1. The element of a dynamic, queue or associative class property typed by an alias:
     - an alias of shortreal is golden's bare logic_var with no typespec;
     - an alias of realtime is a time_var with the typedef's typespec.
   - Cases: CS/cs01 to cs06 (cs06 is the control); v11u462 VR/vr06.
5. § clsNestedUnsizedDims464 (R11U464_CLSNESTUNSIZED_OFF; the § classBoundedQueueMultiDim410 gate and its hook)
   - Goal 1. A leading unsized dim followed by more unsized dims is one array_var. Its kind is the leading dim's kind, and each later dim is a range:
     - `[]` gives [UINT:0 : STRING:unsized] (vpiStringConst, both constants at the `[`, the range over the brackets);
     - `[$]` gives [UINT:0 (no location) : STRING:$ size 1, vpiUnboundedConst] at the `$`;
     - fixed dims are written as before.
   - The innermost element goes under vpiReg.
   - Cases: CN/cn01 to cn08 (cn07, a bounded inner queue, was already equal); v11u462 VR/vr09.
6. § clsInnerUnsizedAnyElem464 (R11U464_CLSINNERELEM_OFF; the same gate)
   - Goal 1. The inner-unsized no-element array_var (`T m[2][]`) also takes these elements: floating (real, shortreal, realtime, an alias of real), string and logic vector.
   - The array_typespec's inner element typespec is bare: unsupported_typespec for floating, string_typespec for string, and logic_typespec with no range for a logic vector.
   - Cases: CM/cm01 to cm04; r11u462 CR/cr03 (exit 4 -> 0; its remaining 36 lines are cr06's class-local typedef copy face).

## Grid (evidence/grid.txt; pristine -> law7; the last column is the path-normalized uhdm-dump distance to golden)

- 43 case dirs: the 38 in UT, UF, UB, CS, CN and CM, plus MO/mo06 and mo09 (r11u463) and VR/vr06, vr09 and CR/cr03 (pass 462). Every exit code on law7 is 0.
- 30 reach STRICT_EQUAL on law7. 27 of them were not STRICT_EQUAL on pristine:
  - CM 4, CN 6, CS 3, UT 6, UF 4, UB 2;
  - mo09, vr06 and vr09.
- 17 dirs went from exit 4 to exit 0. 14 of them reach STRICT_EQUAL (cm01 to cm04, cn01 to cn06, cs01 to cs03, vr06, vr09). Three stay NOT_EQUAL with the head later:
  - CN/cn08 and CS/cs05: the $unit typedef's vpiInstance (the same face with one dim: a scratch control, `n_t t[];`, is NOT_EQUAL on pristine);
  - CS/cs04: a class-scope shortreal typedef that ours does not list in the class.
- Not converting, but moving closer: CR/cr03 (exit 4 -> 0), mo06 (105 -> 91), uf05 (52 -> 48).
- Byte-identical controls: ut02, ut05, ut06, ub03, ub05, cn07, cs06.
- No case moved away from golden.

Switch checks (evidence/switchcheck.txt):
- R11U464_OFF gives pristine's bytes and exit code on 43 of 43 dirs.
- Every moved dir is restored by its own law's switch alone, except mo09, which needs both UNITIMPTRANS and UNITCLSBASE.

Byte check on earlier cases (evidence/bytecheck_earlier_cases.txt): 8256 fence-filtered case dirs of every r11u4xx and v11u4xx repro, pristine against law7.
- 8215 identical.
- 26 dirs whose exit code is 3 on both binaries also move pristine against pristine (evidence/bytecheck_rc3_pristine_vs_pristine.txt). They are error-path variance, not movers.
- 15 movers, all closer to golden:
  - to STRICT_EQUAL: r11u459 BE/be11 (162 -> 130), r11u460 SQ/sq06, v11u412 VF/vf05 (pass 412's design-level $unit import listing residue), v11u456 VR/vr08 (pass 456's file-level import into an interface residue), r11u463 MO/mo09, v11u462 VR/vr06 and vr09;
  - closer: r11u409 IM/im16 561 -> 553, v11u408 VU/vu04 754 -> 748, v11u409 VI/vi12 1323 -> 1315, v11u429 VC/vc07 98 -> 92, v11u463 VG/vg06 and vg14 232 -> 230, MO/mo06 105 -> 91, CR/cr03 (exit 4 -> 0).

Downstream sample (evidence/downstream_sample.txt): ut01, ut04, ut07, uf01 and ub01 read IDENTICAL on both binaries.

## Census and prediction (evidence/prediction.txt, written before the sweep)

The traced census ran law7's slang side over every non-fenced surelog and uhdm2rtlil row-mode (3313) and every probe case (4087), and compared bytes with the master's control /tmp/intr11u462 (tools/census.py, tools/probecensus.py).
- Positive control: uvm_many_to_one and mo09 fire.
- Laws 4 to 6 fire nowhere in the corpora or the probe.
- Law 3 fires on Scoreboard default and SimpleUVM default and testflags (14 objects each) and on probe r10uvm49repro/a6. In all four, the moved objects' parent goes from the module to the $unit class golden names: 14 of 14 per row, and a6's base.
- Laws 1 and 2 fire nowhere in the corpora or the probe.

The sweep confirmed the prediction exactly:
- byteverify surelog 3 of 962 (Scoreboard default, SimpleUVM default and testflags);
- uhdm2rtlil 0 of 1608;
- downstream 0 of 805;
- selfchecks 961, 1607 and 804 flagged.

A fenced row cannot be predicted from a fence-filtered list, and none moved.

## The sweep (one, on law7; logs in evidence/)

Run as tests/sweep.sh --jobs 3 --workdir /tmp/r11u464sw7: the four corpus stages from the worktree (rc 0), then the svtests stage through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty. That svtests run exited 1 on the main tree's law index alone ("law index STALE").

| stage | result |
|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63; regressions 0, conversions 0, changes 0; csv identical to the control (a6 stays EQUAL) |
| surelog | default 480 + 0, testflags 474 + 0; 0/0/0; csv equal to the control after path normalization |
| uhdm2rtlil | 803 / 1 / 67 in both modes; 0/0/0; csv identical |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0; csv identical |
| svtests | EQUAL 1930, STRICT_NOTEQUAL 1, DIFFERENT 9, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions 0, conversions 1 (uvm_many_to_one), changes 0; csv identical to the control except that row |

Other checks:
- Canaries ok=52 and ok=16; both ctcan2 checks PASS.
- Binary audit, fence-filtered: the surelog stage has 1523 of 1573 records naming law7, and the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.
- sv-tests firings (evidence/r11u464_svfires.txt): law 3 on 133 UVM rows, with every status kept; laws 1 and 2 on uvm_many_to_one; law 1 on pipelined_get_put (stays DIFFERENT) and on rsd (SURELOG_CRASH, no golden).
- Determinism: three concurrent law7 draws of SimpleUVM default plus the sweep's database give one hash, 4 of 4: d5640b2350a86246ebb01e0f9b2b9532. **This is a new SimpleUVM default hash, moved by law 3**, so the master should re-record it.

## Goal 1

- Every one of the 75 SURELOG_ONLY rows at the base carries a slang front-end `error:`, so none of them is an exporter error. No BOTH_REJECT or SLANG_CRASH row carries an exporter message.
- This pass's goal-1 laws (4 to 6) clear these probe shapes: pass 462's VR/vr06, vr09 and CR/cr03.
- Still exiting 4 on law7:
  - r11u426 AC/ac05 (an alias of an element-typedef array);
  - r11u442 PA/pa04 and pa05 (a $unit alias of a package array typedef);
  - r11u442 AQ/aq03 and aq04 (a parameter-bounded queue typedef);
  - v11u450 VA/va04 (an associative dim next to another dim; golden decoded in this pass: `[assoc][2]` is size 2 with a range for the [2] and a reg, `[2][assoc]` is size 2 with no range and a reg);
  - v11u451 VN/vn05 (the admission's later-declared parameter).

## Residues (ranked)

1. uvm_many_to_one: StmtEmit's foreach loop-variable typespec in clone bodies (687 strict records). This is the sister's ground.
2. uvm_use_models_pipelined_get_put: the uhdm-cmp head is the whole package mbus_pipelined_env_pkg (a pairing artefact); not decoded in this pass.
3. uvm_param_vif_config_db: golden's class-local this_t carries type_parameters UVM_ALL_ON and UVM_CHECK_FIELDS, typed by unsupported_typespec SFR::sfr_addr_width and SFR::sfr_data_width, with param_assigns. This is a Surelog specialization artefact, not decoded to a rule.
4. easyUVM (class_defn work@sequencer) and the three uvm_scoreboard testbench rows: unchanged.
5. The goal-1 shapes in the Goal 1 section.
6. Next faces left on the grid:
   - cn08 and cs05: a $unit typedef's vpiInstance on the element typespec;
   - cs04: the class-scope shortreal typedef is not listed in the class (TypeEmit's class typedef listing);
   - uf05: a class method face;
   - ut02: the package listing of a package that imports later-declared packages;
   - mo06: the cross-package group copy (pass 463's residue).
7. p733, p737 and tnoc (await the user's decision), and the carried lists of passes 462 and earlier.

## Sister-ground faces (report only)

- StmtEmit, the foreach loop-variable typespec in import-clone bodies: uvm_many_to_one's only remaining strict face. The first record is b_pkg's clone of uvm_pkg::uvm_init, `foreach (uvm_deferred_init[idx])` at uvm_globals.svh 373:29: golden class_typespec uvm_object_wrapper, ours unsupported_typespec idx. Then uvm_factory.svh's index and i loop variables, where golden has int_typespec and ours unsupported_typespec.

## Process

- The pristine reading is the master's control /tmp/intr11u462. No pristine sweep was run.
- One full five-stage sweep, on the final binary law7.
- Targeted runner calls on uvm_many_to_one (pristine, law1, law2, law3, law6), on pipelined_get_put and param_vif_config_db (law6), and on easyUVM and uvm_scoreboard_env (law6).
- One targeted verify_golden call on Scoreboard, SimpleUVM, PreProcMacro, LowMemLib and LowMemPkg (law6) and one targeted check_probe call on a6 (law6).
- Before every runner call and before the sweep, pgrep showed no sister sweep running.
- The fence list was read into a file by a program and never printed. Every tree-wide list was filtered on it first. No fenced test was named, opened or run.
- No other agent's process was touched.

Files: cases/ (38 dirs), drivers/ (env.sh, runcase.sh, dist.sh, bytecheck.sh, switchcheck.sh), evidence/ (grid, switch check, prediction, census, byteverify, sweep logs, sv-tests csv and firings, canaries, binary audit, determinism, downstream sample, earlier-case byte checks, tools/census.py and tools/probecensus.py).
