# v11u462 — adversarial verification of r11u462

Base 5d42effa5, the implementer's patch /tmp/r11u462.patch applied clean on a fresh worktree.

**Verdict: CONFIRMED, no break, no production change.** The verified patch's src diff is
byte-identical to the implementer's. The only changes to the implementer's tree are documentation:
its README said "eight laws" where the patch has seven (three places corrected), and
tests/LAWS.md is regenerated to include this directory's cases.

## Binaries (within the measurement budget)

- Law binary rebuilt from the patch in /tmp/wt_v11u462 (`cmake --build build -j 2`), frozen as
  /tmp/v11u462_bin/law.bin, md5 5764eb53e7e66e5a43aadcd24e58bc78, equal to the implementer's
  /tmp/r11u462_law8.bin. It reports slang 12.0.0+545f88b2e.
- Pristine: no pristine build. The main tree's build/slang-uhdm (md5
  77a3babefa0c97023405689e1ebec60c) is frozen as /tmp/v11u462_bin/pris.bin for case runs, and the
  master's control /tmp/intr11u460 is the pristine sweep reading.
- No verified build, because nothing in production changed.

## The one five-stage sweep (law binary, trace on; drivers/sweep_run.sh)

The sweep was launched after three quiet readings (drivers/quiet.sh), once the sister verifier
v11u463's sweeps had ended. The four corpus stages ran from the worktree. The sv-tests stage ran
through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty. Both commands
exit 1 only on the law-index staleness check. For the worktree command, this directory's new cases
had not yet been indexed when the sweep ran; the delivered patch carries the regenerated index, and
`scripts/law_index.py --check` passes on a fresh 5d42effa with the patch applied. For the
main-tree command it is the main tree's own index check, as the implementer also recorded.

| stage | result |
|---|---|
| probe | EQUAL 4024, STRICT_NOTEQUAL 63; regressions=0 conversions=1 changes=0. The conversion: `r10v136repro/v136_d_homes STRICT_NOTEQUAL differ:fullname(18) -> EQUAL`, fresh row `r10v136repro/v136_d_homes,EQUAL,,equal` (§ clsInModTdLastWriter462 in the trace). The csv differs from the control in that row only. |
| surelog | default CMP_EQUAL 480, testflags 474; 0/0/0; the csv equals the control's after work-dir path normalisation |
| uhdm2rtlil | 803/1/67 in both modes; 0/0/0; the csv equals the control's |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not identical and not excused=0; the csv equals the control's |
| svtests | regressions=0 conversions=2 changes=0; BOTH_REJECT 303, DIFFERENT 10, EQUAL 1930, SLANG_ONLY 19, SURELOG_CRASH 8, SURELOG_ONLY 75, TIMEOUT 1 of 2346. The csv is byte-identical to the implementer's /tmp/r11u462_wd/svtests.csv and differs from the control in the two converted rows only. |

sv-tests rows, before -> after (fresh csv rows):

- generated/uvm-examples/uvm_ac_config_db.sv: STRICT_NOTEQUAL differ:fullname(1823) -> EQUAL,
  `generated/uvm-examples/uvm_ac_config_db.sv,EQUAL,,equal`
- generated/uvm-examples/uvm_id_register.sv: STRICT_NOTEQUAL differ:name(5) -> EQUAL,
  `generated/uvm-examples/uvm_id_register.sv,EQUAL,,equal`
- generated/uvm-examples/uvm_use_models_pipelined_get_put.sv: DIFFERENT on both binaries.

The three rows were also rerun alone through scripts/svtests/svtests_matrix.py on both binaries
(drivers/rows.sh; evidence/rows_pris.csv, rows_law.csv). Pristine reads JUDGE_EQUAL
differ:fullname(1823), JUDGE_EQUAL differ:name(5) and NOTEQUAL. Law reads EQUAL equal, EQUAL equal
and NOTEQUAL.

Other checks (evidence/):

- **byteverify** (SELFCHECK=1) against the control finds exactly the implementer's movers, with the
  same hashes: surelog 14 of 962, uhdm2rtlil 16 of 1608 and downstream 8 of 805.
- **Prediction.** My sweep's movers were predicted to be the implementer's byteverify list, since
  the binary is the same. That held exactly.
- **Away census on the movers.** § enumBaseInstFollowsEnum462 changes only a vpiInstance, which
  neither uhdm-dump nor strict reads, so evidence/tools/ebcensus.cpp lists every enum with an
  unnamed base as (enum, enum instance view, base instance view). Against golden, every non-fenced
  surelog and uhdm2rtlil mover is 2 lines closer and none is further away
  (evidence/ebcensus_corpus_movers.txt). For example, BlackBePipeInt goes 5 -> 3 and rp32_r5p_wbu
  128 -> 126. The fenced row was not opened.
- **Trace** (evidence/trace_summary.txt). The firing set is identical to the implementer's, per
  database and per law:
  - cloneRetVar 120, clsInModEnum 96, clsInModTd 9, clsMethodAuto 2, enumBase 55 and
    unitHoistSysf 56;
  - 67 database-law pairs: probe 2, surelog 16, uhdm2rtlil 16, downstream 8 and sv-tests 25.
- **Canaries:** ok=52 and ok=16, both ctcan2 checks PASS.
- **Binary audit**, fence-filtered:
  - surelog: 1523 of 1573 records name /tmp/v11u462_bin/law.bin; the other 50 hold only a Surelog
    line, and no record names another binary;
  - uhdm2rtlil: 1740 of 1740;
  - sv-tests: 2346 of 2346.

## The implementer's grid reproduced

All 49 case dirs were rerun on both binaries. Exit code, uhdm-cmp line count and strict verdict
equal evidence/grid_pris_vs_law.txt of r11u462repro on every line, and the moved/same set is the
same.

The implementer's summary miscounts its grid. By md5, 32 dirs move and 17 are byte-identical; it
reports 35 and 14 (12 controls plus eb01 and cr03). cr03 does move, and ce06, cm06, cm09, eb01, the
five RV cases, sb02, sb03 and ta05 are byte-identical.

Every implementer mover that does not convert is closer to golden by id-stripped uhdm-dump
distance (evidence/distances.txt):

| case | distance to golden, pristine -> law |
|---|---|
| TA/ta03 | 9 -> 8 |
| CR/cr03 | 111 -> 83 |
| CR/cr06 | 47 -> 19 |
| SB/sb01 | 94 -> 92 |
| SB/sb04 | 180 -> 174 |
| CM/cm07 | 12 -> 2 |

## Attack grid: 75 fresh case dirs (cases/, every first line names its law)

Every case is accepted by upstream slang (~/.local/bin/slang dut.sv --single-unit). Three were
first written in shapes that a tool rejected and were rewritten in place:

- VA/va03 had `function static`, which upstream slang rejects;
- VB/vb04 had an `export a::*` that exported nothing;
- VA/va01's `extern function automatic` and VA/va06's `function automatic new` were rejected by
  Surelog's parser, so neither had a golden.

Results (evidence/grid_pris.txt, grid_law.txt, grid_pris_vs_law.txt):

- 49 dirs move and 26 are byte-identical controls.
- 39 movers become STRICT_EQUAL, 7 of them from exit 4 to exit 0.
- No case moves away from golden.
- Every exit code is 0 on both binaries except VR/vr06 and vr09, which exit 4 on both.

Per law:

- **VM (§ clsInModTdLastWriter462, 21 cases).** A class in a module that is the last writer, in
  these shapes: two classes where the alphabetically last class is not the one using the typedef
  (vm02); a nested class (vm03); a union inside a struct (vm04, vm17); a parameterized class
  (vm05); an explicit import (vm06); an uninstantiated module (vm11); a class extending a package
  class (vm13); two instances (vm15); a derived class in the same module (vm16); a module named
  after top (vm20); instances in a generate loop (vm21); a z-named module above the class module
  (vm10).
  - 13 cases go STRICT_NOTEQUAL fullname -> STRICT_EQUAL: vm02 to vm06, vm10, vm11, vm13, vm15 to
    vm17, vm20 and vm21.
  - Controls, byte-identical: a later module or top as the last writer (vm01, vm09, vm18); a
    package-scoped p::s_t with no import (vm07); a module-local typedef (vm08); an interface class
    (vm14).
  - Programs (vm12) and an interface writer next to the class module (vm19) move bytes at an
    unchanged uhdm-cmp head. Their distance to golden goes 14 -> 4 and 31 -> 21.
- **VE (§ clsInModEnumLastWriter462, 10 cases).** ve01, ve03, ve04 (a class specialization over
  the enum), ve07, ve08 (an interface writer beside the module), ve09 (an enum alias across two
  modules with classes) and ve10 go STRICT_NOTEQUAL -> STRICT_EQUAL. ve02 and ve06 (a later
  writer) and ve05 (a program, NOT_EQUAL 296) are byte-identical.
- **VA (§ clsMethodOwnAutomatic462, 12 cases).** Eight go NOT_EQUAL -> STRICT_EQUAL:
  - va02, a package class imported into a module;
  - va04, a parameterized class;
  - va07, a class in a module;
  - va08, an out-of-body automatic task in a package whose class is extended in another package;
  - va09, a class in an interface;
  - va10, a nested class;
  - va11, a virtual class beside a pure virtual task;
  - va12, formals and locals.

  The controls are byte-identical: va01 (an out-of-body `task automatic C::t()` at $unit, already
  STRICT_EQUAL on pristine), va03 (only qualified methods) and va06 (an interface-class
  implementation). va05, a class in a program, has its head moved later: pristine stops at the
  task's vpiAutomatic, the law at the older program-instance variable listing. Its distance goes
  27 -> 26.
- **VR (§ clsDynRealArrPropElem462, 10 cases).** Seven go from exit 4 to exit 0 and STRICT_EQUAL:
  - vr01, a queue, associative and dynamic array of real, shortreal and realtime;
  - vr02, a type parameter defaulting to real;
  - vr03, a package class;
  - vr04, static, local and protected properties and a bounded queue;
  - vr05, an initializer in a module class;
  - vr07, method reads;
  - vr08, push_back and new[].

  vr10, specializations C#(real) and C#(shortreal) of a default-int queue, is byte-identical and
  STRICT_EQUAL on both. vr06 (`typedef shortreal sr_t; sr_t d[];`) still exits 4, since the law
  takes only aliases of real. vr09 (`p::r_t d[]` plus `real dd[][]`) still exits 4 on the
  dynamic-of-dynamic property, with its distance going 84 -> 55.
- **VB (§ enumBaseInstFollowsEnum462, 8 cases).** vb01, vb02, vb04 and vb07 move bytes. In every
  one, the ebcensus line `a::e_t | DEF:b | TOP:a` becomes golden's `a::e_t | DEF:b | DEF:a`
  (evidence/ebcensus_cases.txt). The controls are byte-identical: vb03 (a typedef'd base, which
  the law skips as named), vb05 (a package class) and vb06 (a three-level chain).
- **VS (§ unitHoistBindsSysCallRhs462, 13 cases).** Four go NOT_EQUAL -> STRICT_EQUAL: vs07
  ($clog2), vs11 ($bits with a body import), vs12 (nested $clog2) and vs13 (a port range).
  - vs08 has its head moved later, from the design parameter to a typedef range fold that golden
    folds (ParamEmit/ExprEmit, the sister's). Its uhdm-cmp line count goes 56 -> 76 but the
    distance goes 141 -> 137.
  - vs10, `$size` over a parameter array, moves bytes at the same head, with distance
    1511 -> 1509.
  - The rest are byte-identical controls: the module-scope uses vs01 to vs06 and a transitive
    package parameter vs09.
- **VC (§ cloneRetVarViaRefKeepsHome462, 2 cases).** Both byte-identical. As the implementer and
  pass 460 found, toy packages do not mint the shared clone return.

**Switch checks** (evidence/switchcheck.txt):

- `R11U462_OFF=1` on the law binary gives pristine's md5 and exit code on 75 of 75 dirs.
- On every moved dir, its group's own law switch alone gives pristine's md5.

**Downstream:** 11 sampled cases (vm04, vm17, vs07, vs11, vs12, vs13, vr05, va12, vb04, vb07,
ve09) read IDENTICAL on both binaries. Two of them build gates: vb07 with 2 and vs13 with 10.

## Residues (all wrong on pristine too, none moved away)

1. uvm_use_models_pipelined_get_put stays DIFFERENT. Its clone-body foreach loop-variable kinds are
   StmtEmit's, the sister's. The top_hdl interface-instance face is on this ground and not decoded.
2. uvm_param_vif_config_db: the class-local this_t specialization artefact, not decoded.
   uvm_many_to_one: its head is ParamEmit's, the sister's.
3. Goal-1 faces still at exit 4 on this ground:
   - a shortreal alias as the element of a dynamic class property (VR/vr06; the law takes only
     aliases of real);
   - a dynamic-of-dynamic `real dd[][]` and a fixed-of-dynamic `real m[2][]` class property
     (VR/vr09, r11u462 CR/cr03).
4. A typedef'd real element's per-use copy (r11u462 CR/cr06, exit 0, NOT_EQUAL).
5. Program listings: VM/vm12, VE/ve05, VA/va05 and r11u462 CM/cm06 and cm07. The program class
   laws move these toward golden, but the program-instance listing face stands.
6. An interface writer beside a class module (VM/vm19, closer but NOT_EQUAL 139).
7. `$size` over a package parameter array (VS/vs10) and a transitive package parameter (VS/vs09):
   the next face is ParamEmit's.
8. The carried lists of passes 460 and earlier, as in r11u462repro.

## Sister-ground faces (reported, not written)

- **ParamEmit/ExprEmit:** the package typedef range [N-1:0] over a $bits parameter, which golden
  folds to a constant where ours keeps the operation (VS/vs08's next head). The transitive
  package-parameter listing (VS/vs09; r11u462 EB/eb01).
- **ExprEmit:** the package-function body folds behind r11u462 SB/sb01 and sb04.
- **StmtEmit:** the clone-body foreach loop-variable typespec behind pipelined_get_put.

## Process

- Measurements stayed within the budget: one law build, one five-stage sweep and no pristine sweep.
  The targeted runner call on three rows ran per binary.
- Every build, grid batch and runner call started after three quiet readings. The attack grids that
  overlapped my own sweep ran at nice 19. None overlapped another agent's sweep.
- The fence list was read into a file by a program and never printed. Every tree-wide list (the
  cmds audit, trace summaries, byteverify, the census) was filtered on it, and fenced names are
  masked in the saved evidence. No fenced test was named, opened or run.
- No other agent's process was touched.
