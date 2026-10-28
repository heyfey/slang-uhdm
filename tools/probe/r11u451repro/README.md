# r11u451repro — pass 451 (expression/parameter ground), the sv-tests campaign

Base 57706919e. Production files: src/ParamEmit.cpp, src/EmitHelpers.h, src/ExprEmit.cpp.
StmtEmit.cpp is unchanged. Every law reads its switch through src/LawSwitch.h (`lawOn(451, ...)`).
`R11U451_OFF` drops every law of the pass. `R11U451_TRACE=<dir>` logs each firing through
`lawTrace(451, ...)`. There is no src/R*.h, no getenv and no reader function.

## Verdict

- **sv-tests:** no row changes status. Before the sweep the census named 14 rows where the
  listing laws fire: 11 DIFFERENT and 3 SLANG_ONLY uvm-examples rows. The sweep's trace found
  those 14 plus generated/rsd/rsd, a SURELOG_CRASH row the census filter had left out; no status
  moved (see "Gates").
- **The work is on the largest open cluster, the diamond-import listing.** That listing was the
  uhdm-cmp head on uvm_test_init and the three uvm_generation_seq rows. Pass 446's localizer
  reads, pristine -> law:
  - test_init: package failures 10 -> 0, whole-run localized failures 12 -> 0;
  - uvm_generation_seq_poly: package failures 4 -> 0.

  What is left on those rows is all on the sister ground (see "Sister-ground faces").
- **Goal 1:** two exit-4 shapes are written.
  - The nested-module read from pass 448's AD/ad07: 9 cases go from exit 4 to STRICT_EQUAL.
  - The task name read as a value from v11u448 VA/va23: 8 cases go to STRICT_EQUAL.

  No rejecting sv-tests row carries a message from the exporter itself.

## Laws (switch, sites, rule)

1. **§ diamondImportListsPerPath451** (`R11U451_DIAMONDVARS_OFF`; ParamEmit `impVars9`, and
   EmitHelpers.h `listing217` for the module copy)
   - `CompileHelper::importPackage` (CompileHelper.cpp 183-189) appends the imported package's
     whole signal vector. That vector already holds every clone the imported package
     materialized itself. So a package reached twice under one import item is listed once per
     import path.
   - The visited set that stopped a repeat inside one item is now a path guard: it still stops
     a cycle.
   - Golden test_lib_pkg (uvm_generation_seq_poly) lists uvm_pkg's 26 entries 4 times; ours
     listed them 3 times. Golden top_tb lists them 8 times; ours 7.
2. **§ diamondImportParamAssignsPerPath451** (`R11U451_DIAMONDPA_OFF`; ParamEmit
   `collectImportedParams` and the `emitParameters` loop)
   - The importer's Parameters come from `getParameterMap()`, a map with one entry per name.
   - Its Param_assigns come from `getParamAssignVec()`, a vector with one entry per path
     (CompileHelper.cpp 199-271).
   - The repeats ride as assign-only occurrences in the slot of the full walk. Their Parameters
     entries are dropped after the loop.
   - The law abstains when the first occurrences of the full walk do not reproduce the
     de-duplicated list (a cycle).
   - Golden test_lib_pkg: 123 parameters and 164 param_assigns (ours 123 and 123). Golden
     top_tb: 164 and 328 (ours 164 and 164).
3. **§ pkgDupSignalLeftoverNet451** (`R11U451_LEFTNET_OFF`; ParamEmit `emitOne9` through
   `left451`)
   - `NetlistElaboration::elaboratePackages` (NetlistElaboration.cpp 99-133) elaborates every
     entry of the package's signal vector, and each entry gives one vpiVariables entry. It then
     erases the entries that are not nets, once per distinct Signal: the set `notSignals`, with
     a `break` after the first match.
   - So every repeat of a variable stays in the vector, and `writePackage` lists it through
     `writeNets` as a logic_net, in vector order among the real nets.
   - The net takes writeNets' shape:
     - the element typespec over the type syntax, its end at the first unpacked dimension;
     - a class typespec named after the class;
     - `getVpiNetType` of the written keyword: logic 36, reg 48, any other type none.
   - Golden bus_seq_lib_pkg lists 26 such nets, test_lib_pkg 78. Ours listed none.
   - This law also fires across separate import items, which pristine already repeated: DI/di01.
4. **§ nestedModUndeclReadBare451** (`R11U451_NESTREAD_OFF`; ExprEmit Invalid branch, beside
   § undeclaredReadImplicitNet447)
   - A module defined inside a never-elaborated module is listed as `work@m::nest`. Its read of
     an undeclared name stays a bare ref_obj (`work@m.work@m::nest.undecl_x`) and no wire is
     minted. A net or variable declared later in the nested body binds by name.
   - scopeOk447 compared the def name with `work@nest` and abstained, so the run exited 4.
   - The law takes the same declared-name and nested-type abstentions as
     § undeclaredReadIfaceBare447.
5. **§ taskNameReadImplicitNet451** (`R11U451_TASKVAL_OFF`; ExprEmit Call case)
   - In a module slang never elaborates, a task name read as a value with no parentheses gets
     the § 447 implicit wire at the read: golden `logic_net (work@m.t)`, with the read bound to
     it. We wrote a task_call bound to the task.
   - The law does not fire for a call statement `t;` (TV/tv08), which golden keeps as a
     task_call. The read takes § 447's slot among the implicit wires.
   - An elaborated module never reaches the law, because slang rejects a task used as a value.

## Grid (cases/, 29 case dirs; drivers/run1.sh, drivers/switches.sh; evidence/grid_law9.txt, evidence/switches.txt)

Every case is accepted by upstream slang. The exit code is shown before -> after; every DI, DN,
NM and TV case exits 0 on the law binary.

| case | law (first line) | pristine -> law9 |
|---|---|---|
| DI/di01 | pkgDupSignalLeftoverNet451 (LEFTNET alone) | rc0 NOT_EQUAL 685 -> STRICT_EQUAL 251 |
| DI/di02 | pkgDupSignalLeftoverNet451 (+ DIAMONDPA) | NOT_EQUAL 383 -> NOT_EQUAL 35, residue IR (module initializer read) |
| DI/di03 | pkgDupSignalLeftoverNet451 | NOT_EQUAL 823 -> STRICT_EQUAL 353 |
| DI/di04 | pkgDupSignalLeftoverNet451 | NOT_EQUAL 904 -> 930, same head object package c (a nested explicit import's parameter, residue) |
| DI/di05 | pkgDupSignalLeftoverNet451 (+ DIAMONDPA) | NOT_EQUAL 850 -> 151, head moved later (unreferenced typespec Instance) |
| DI/di06 | diamondImportListsPerPath451 (all three listing laws) | NOT_EQUAL 351 -> STRICT_EQUAL 274 |
| DI/di07 | diamondImportParamAssignsPerPath451 (DIAMONDPA alone) | NOT_EQUAL 802 -> STRICT_EQUAL 380 |
| DI/di08 | diamondImportListsPerPath451 (+ LEFTNET) | NOT_EQUAL 203 -> STRICT_EQUAL 258 |
| DN/dn01 | pkgDupSignalLeftoverNet451, 27 types | NOT_EQUAL 126 -> 126, head in package a's own queue var (unchanged face) |
| DN/dn02 | pkgDupSignalLeftoverNet451 (+ DIAMONDVARS) | NOT_EQUAL 446 -> 472, same head package c: `import b::*` written twice, which our walk lists once (residue) |
| DN/dn03 | pkgDupSignalLeftoverNet451, a hoisted ctor local | NOT_EQUAL 319 -> STRICT_EQUAL 131 |
| NM/nm01-nm03, nm06, nm08-nm12 | nestedModUndeclReadBare451 | rc4 -> rc0 STRICT_EQUAL (9 cases) |
| NM/nm05 | nestedModUndeclReadBare451 (two levels) | STRICT_EQUAL, byte-identical (control) |
| TV/tv01-tv04, tv07-tv10 | taskNameReadImplicitNet451 | NOT_EQUAL -> STRICT_EQUAL (8 cases) |
| TV/tv05 | taskNameReadImplicitNet451 (a FUNCTION name, control) | byte-identical; golden lists the definition the admission refuses |

Switches:
- `R11U451_OFF` gives pristine's bytes and exit code on 29 of 29 case dirs.
- Each law's own switch restores pristine alone on every NM and TV mover, on DI/di01, di03,
  di04, DN/dn01, dn03 (LEFTNET) and DI/di07 (DIAMONDPA).
- The other DI and DN cases move under two or three of the listing laws and need all of them
  off.

## Census before the sweep (prediction by name)

- **probe:** drivers/probecen.sh with the law7 trace over the 4087 gate cases, fence-filtered.
  Every database was compared with the master's control /tmp/intr11u449/probe:
  - 0 firings, 0 byte movers;
  - positive control: cases/DI/di06 through the same driver writes its trace.
- **surelog and uhdm2rtlil:**
  - A fence-filtered text scan of the corpus trees for packages whose import closure repeats a
    package. Its judge-equal candidates were Earlgrey_0_1, EarlgreyPackParam and Tnoc d/t, and
    the 14 rp32 rows.
  - verify_golden on those rows with the law4 trace: 0 firings, and all 20 databases
    byte-identical to the control.
  - The prediction for the sweep was 0 movers in surelog, uhdm2rtlil and downstream.
- **sv-tests:**
  - The same scan over the control's command lines named 14 rows: 11 DIFFERENT and 3 SLANG_ONLY
    uvm-examples rows. The law4 traced runner fired on all 14; no status moved.
  - A second scan for nested modules and task definitions named 77 rows. The law7 traced runner
    gave 76 IDENTICAL with no firing, plus uvm_ac_config_db firing the listing law only.
  - Prediction: the sweep's sv-tests stage reads 0 regressions, 0 conversions and 0 changes,
    with these 14 rows the byte movers.

## Gates (the one five-stage sweep, law7, trace on; drivers/fullsweep.sh)

The full five-stage sweep ran once, on law7 (drivers/fullsweep.sh, trace on). The four corpus
stages ran from the worktree; the sv-tests stage ran through the main tree's check_svtests.py
against the worktree baseline.

**law7 sweep:**
- **probe:** EQUAL 4023 + STRICT_NOTEQUAL 64. regressions 0, conversions 0, changes 0.
- **surelog:** default CMP_EQUAL 480 / testflags 474. 0/0/0; Tnoc d/t stays CMP_NOTEQUAL.
- **uhdm2rtlil:** 803 / 1 / 67 in both modes. 0/0/0.
- **downstream:** IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0. The verdict diff
  against the control is empty.
- **sv-tests:** EQUAL 1916, STRICT_NOTEQUAL 3, DIFFERENT 21, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1. regressions 0, conversions 0, changes 0.

**The byteverify of law7 against the master's control found ONE UNPREDICTED MOVER.**
- The row is uhdm2rtlil struct_param_func_config, in the default mode (and its downstream twin).
  It stayed CMP_EQUAL / strict equal / IDENTICAL.
- No law fired on it, and `R11U451_OFF` did not restore pristine's bytes.
- What moved is the vpiParent of unreferenced (weaklyReferenced) typespec copies: which module's
  ref_typespec names them last. That is a heap-allocation-order effect.
- A bisect on source halves put it on the param-assign law's hunks: the new `assignOnly` field
  grew `ImpOcc9`, so every `std::vector<ImpOcc9>` allocation changed size.
- The fix (law9):
  - the repeat occurrences ride in a side list of indices instead of a field;
  - the full walk runs only when the de-duplicating walk met a package twice (`repeat451`);
  - the trace-only sets allocate only under `R11U451_TRACE`.
- On law9, struct_param_func_config reads pristine's bytes with the laws on and with
  `R11U451_OFF`. The 29 grid case dirs give law7's bytes on every case
  (evidence/switches.txt, evidence/grid_law9.txt).

**law9, the final binary** (md5 01804187a7028f357251db94512545f7). The narrowed change's stages
were rerun alone, never two at once, each after three quiet readings:
- **surelog, uhdm2rtlil and downstream** (tests/sweep.sh --corpus "surelog uhdm2rtlil
  downstream"):
  - every count as above, 0/0/0 in each;
  - byteverify against the master's control: surelog 0 of 962, uhdm2rtlil 0 of 1608,
    downstream 0 of 805. The self-checks flag 961, 1607 and 804;
  - canaries ok=52 and ok=16; ctcan2 PASS on both csvs.
- **probe:** drivers/probecen.sh. The 4087 gate databases are byte-identical to the control
  /tmp/intr11u449/probe, with 0 firings. That is the probe stage's reading.
- **sv-tests stage alone:**
  - the same counts, regressions 0, conversions 0, changes 0;
  - the status column is identical to the control's on all 2346 rows;
  - all 2346 cmds.txt name law9.
- **The trace census of that stage named 15 rows:**
  - the 14 predicted rows;
  - generated/rsd/rsd, which fires the two diamond laws (2866 + 114 lines). It is SURELOG_CRASH
    (Surelog dies first), so its status cannot move; the census filter had left it out because
    of that status.
- The law7 sweep's surelog and uhdm2rtlil cmds.txt name law7; law9's name law9.
- What the byte movers in the 14 rows mean, read on uvm_generation_seq_poly and uvm_test_init
  with pass 446's localizer (evidence/tools/clsloc.cpp, ALL top). Pristine -> law:
  - poly: package failures 4 -> 0 (bus_seq_lib_pkg and test_lib_pkg, both views);
  - test_init: package failures 10 -> 0 and module failures 2 -> 0. Its 3 class failures are
    the sister's face below.
  - What is left on poly: `rand_order_seq::body`, `module DEF` and `module TOP`, all sister
    faces.

## Residues (ranked; all wrong on pristine too)

1. **The diamond rows' remaining faces are the sister's**, listed under "Sister-ground faces".
2. **A module variable initializer reading an imported package variable** (`import c::*; int x
   = vc;`, evidence/residue/IR/ir01):
   - golden binds the elaborated read to the module's own import copy `work@top.vc`; ours leaves
     it unbound;
   - a process read (ir02) and a continuous assignment (ir03) are STRICT_EQUAL;
   - not decoded: the initializer is emitted by ModuleEmit, and which side misses the copy is
     open.
3. **A nested package's explicit import feeding an importer's parameter vectors** (DI/di04:
   `b` imports `a::PA`, `c` imports `b::*`):
   - golden lists PA under c's b item; collectPkgParams follows wildcard imports only.
4. **A wildcard import written twice** (`import b::*; ... import b::*;`, DN/dn02):
   - golden lists b's vector twice; our walk lists it once.
5. **A function name read as a value** in a placeholder definition (TV/tv05):
   - golden lists the definition; the admission (the sister's) refuses it.
6. **The goal-1 probe faces** C::mk().arr[1], u.mk(x).a[2] and this.mk().inner.s were not
   reached. The black-parrot size guard stands and was not measured this pass.
7. The carried lists of passes 449 and earlier (the brief's items (b) to ({)), not reached.

## Sister-ground faces (reported, not written)

- **UhdmExporter, the class copy of package variables** (class_defn Variables, built around the
  `MakeVariablesVec` near emitClassDefn). This is uvm_test_init's uhdm-cmp head after this pass:
  - golden's `enum_var m_uvm_core_state` in the classes of top_vseq_pkg binds the shared
    `uvm_core_state` enum_typespec object. Surelog's `writePackage` re-instances that object for
    every package listing it (`reInstanceTypespec`), so it carries vpiInstance test_top_pkg, the
    last package written;
  - ours binds a private copy with no vpiInstance;
  - pass 446's localizer reads it as class top_vseq_base, vseq_A1_B_A2_A1 and vseq_A1_B_C
    against package test_top_pkg: 3 failures on both binaries.
- **TaskFuncEmit, the subroutine-body local array of class handles** (`task body; bus_seq_base
  seq_array[4];`, the tf block-item array factory near TaskFuncEmit 7826):
  - the element reg's typespec is a logic_typespec where golden writes an unnamed class_typespec
    with vpiClassDefn;
  - this is the generation_seq rows' `rand_order_seq::body` failure;
  - evidence/sister/CA: ca03, ca04 and ca06 are wrong on both binaries, while the begin-block
    form ca07 and the $unit class ca05 are right.
- **TypeEmit, the elaborated associative-array index typespec** (`int memory[logic[31:0]];` in
  an elaborated module, near TypeEmit 33357):
  - golden's index logic_typespec carries the range [31:0]; ours carries none;
  - this is the generation_seq rows' `module TOP work@top_tb` failure;
  - evidence/sister/AX/ax01.
- **ModuleEmit / UhdmExporter, the order of top_tb's implicit wires** in the definition view.
  This is the generation_seq rows' `module DEF` failure:
  - golden lists the clone-body implicit wires (p 220:3, m_inst_id, ..., `this` 968:29, ...)
    and then the port-connection wire BUS 30:29 last;
  - ours puts BUS and `this` (§ thisImplicitNetBoth38) ahead of the clone wires.

## Process

- Laws were developed on law1 to law7. The intermediate binaries got only case runs and targeted
  runner calls on 2, 24, 14 and 77 rows.
- There was one full five-stage sweep, on law7.
- Its byteverify found the allocation-order mover. The fix went into law9, and the stages it
  could touch were rerun alone on law9 (surelog + uhdm2rtlil + downstream, the probe census, the
  sv-tests stage).
- The sv-tests rerun waited about 40 minutes for the sister's sweep to end.
- **Slip:** the scan that predicted the movers filtered on accepting statuses and so did not
  name rsd. Rows whose status cannot move should be traced too.
- The fence list was read into a file by a program and never printed. Every tree-wide list was
  filtered on it first. No fenced test was named, opened or run.
- No other agent's process was touched. Every launch waited for three quiet readings.
