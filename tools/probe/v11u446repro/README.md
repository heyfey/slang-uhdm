# v11u446 — adversarial verification of r11u446

Base e316b93a6 (pass 444). Verifier of pass 446 (module/type ground: src/ModuleEmit.cpp,
src/UhdmExporter.cpp, src/TaskFuncEmit.cpp). The implementer's patch /tmp/r11u446.patch
applies clean on a fresh e316b93a6; its source diff holds no src/R*.h, no getenv and no
reader definition, and every one of the seven laws reads through lawOn(446, ...) with a
lawTrace(446, ...) call.

## Verdict

CONFIRMED, no break found, no production change. The verified patch is the implementer's
source unchanged plus this directory and the regenerated tests/LAWS.md.

- Law binary rebuilt once in /tmp/wt_v11u446: md5 c56b0919304427814e2877f4a85aa234, equal to
  the implementer's law7, linking slang 12.0.0+545f88b2e. Frozen at /tmp/v11u446_bin/law.
- Pristine for case runs: the frozen copy of the base build, md5
  0ff84699b281f8ee9eb87dff63772efb (/tmp/v11u446_bin/pristine). No pristine build and no
  pristine sweep: the pristine reading is the master's control /tmp/intr11u444.
- No sv-tests row converts. All 26 DIFFERENT rows stay DIFFERENT; the sv-tests csv is
  identical to the control on all 2346 rows.

## The one full five-stage sweep, on the law binary (evidence/sweep_law.txt)

tests/sweep.sh --jobs 3 --workdir /tmp/v11u446swL, the trace on (R11U446_TRACE), started
after three quiet readings; the sv-tests stage through the main tree's
scripts/check_svtests.py against this worktree's results/golden_svtests.csv (the worktree's
UVM submodule is empty; the scripts and the golden csv are identical to the base's).

| stage | reading |
|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64, regressions 0, conversions 0, changes 0 |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0, not identical and not excused 0 |
| sv-tests | EQUAL 1914, DIFFERENT 26, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; 0/0/0 |

Every csv equals the control's (and the implementer's law7 sweep's) apart from the two LowMem
log-path texts in surelog.csv. The corpus stages exited 1 on the stale law index alone (this
directory's cases were not yet indexed); tests/LAWS.md is regenerated in the patch.

- byteverify (SELFCHECK=1) law against the control (evidence/byteverify_law_vs_control.txt):
  surelog 4 of 962 (MiniAmiq d/t, SeqDriver d/t, predicted by name), uhdm2rtlil 0 of 1608,
  downstream 0 of 805; self-checks flag 961, 1607 and 804. Law sweep against the
  implementer's law7 sweep: 0 of 962, 0 of 1608, 0 of 805.
- Canaries ok=52 and ok=16; ctcan2 PASS on both (ok=58 / ok=2).
- Binary audit, fence-filtered: surelog 1523 of 1573 records name /tmp/v11u446_bin/law and
  the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346; none
  names another binary.
- Trace census (evidence/trace_census_sweep.txt): probe the 9 cases the implementer
  predicted; surelog MiniAmiq d/t and SeqDriver d/t (8 x § clsLocalTdTopHomeInst446,
  1 x § clsBodyCallBindsHomeTopTf446, 1 x § cloneBodyCallBindsHomeTopTf446 each); sv-tests
  the 17 uvm-examples DIFFERENT rows plus 4 rows; uhdm2rtlil and downstream none.
- CORRECTION to the implementer's report: the 4 further sv-tests rows the laws fire on
  (uvm_overriding, uvm_slave_agent, uvm_slave_agent_multi_seq_item, uvm_wait_for_signal)
  are SLANG_ONLY rows (Surelog reports 2 errors), not EQUAL rows. They stay SLANG_ONLY; the
  partial golden is not comparable.
- Probe movers by path-normalized uhdm-dump, control -> law, over the 9 traced cases: 5 move
  (r10uvm127 g127_c_import 4 lines, r10uvm172 g172_b_name 4, g172_d_scope 2, r10uvm227
  a9_class_holder 2, r10v169 v169_g_control 4), 4 byte-equal in dump; the un-normalized
  first comparison flagging all 9 is the positive control. All stay EQUAL (a9 stays
  STRICT_NOTEQUAL depth, its baseline).

## Toward golden on the fields the strict walk does not read (evidence/uvm_rows_instance_binding.txt)

The laws write vpiInstance and call bindings, which uhdm-strictcmp does not compare, so each
mover was judged by two extra instruments against golden: the canon-walk records with each
typespec's vpiInstance (the implementer's sc2, FORCE2) and a call-binding multiset
(drivers/bind.cpp: each call's name, location, owner view, and its target's owner view).

- MiniAmiq d/t and SeqDriver d/t stay STRICT_EQUAL at 435559, 475526 and 475538 objects;
  instance records 36 closer, 0 away; bindings 3020 (MiniAmiq) and 2886 (SeqDriver) closer,
  0 away (the binding distance falls from 4222 to 54 and from 4044 to 54).
- The 8 probe movers with bindings: all closer or unchanged, 0 away, except a9_class_holder,
  where golden binds the call through the FIRST wildcard-imported package that lists the
  name (p2's clone, p2 TOP); pristine bound p3 TOP and the law binds p1 TOP. Wrong on both
  binaries (residue below).
- sv-tests localizer (the implementer's clsloc, ALL) on kept pairs from
  svtests_matrix.py --keep-golden on both binaries: uvm_messaging_example 1607 -> 18,
  uvm_priority_arbitration 1601 -> 18, as the implementer reported. The 16 function
  failures left on messaging_example are uvm_init, get/set_packed_ints and longints,
  perform_accesses, get_blocks and uvm_root::new in both views of messaging_pkg, the
  sister-ground faces the implementer names.
- Determinism: three concurrent law runs read one hash with the sweep's database on
  MiniAmiq default and SeqDriver testflags (4 of 4 each), and with the runner's database on
  uvm_messaging_example (4 of 4).

## The implementer's grid, reproduced (evidence/impl_grid_*.txt)

All 27 case dirs reproduce exactly on exit code (0 everywhere), uhdm-cmp line count, strict
verdict and record distance, against fresh goldens. R11U446_OFF gives pristine's bytes on 27
of 27.

## Attack grid (tools/probe/v11u446repro/cases, 48 case dirs, evidence/attack_grid.txt)

Every case is accepted by upstream slang (~/.local/bin/slang dut.sv --single-unit) and every
exit code is 0 on all three binaries (pristine, law, law with R11U446_OFF). Goldens by
Surelog v1.87 (-parse -nobuiltin -nocache -sv). Faces, per law:

- § clsLocalTdTopHomeInst446 (VT): vt01 a specialization typedef in p of a class from
  another package r; vt02 two importer packages; vt03 a module importer only, two
  specializations; vt04 a nested specialization pool#(pool#(int)); vt05 the specialization
  re-aliased in the importer and in a module; vt06 a class of the home package using it.
- § aggCopyClassMemberHomeInst446 (VS): vs01 a module variable only; vs02 two class members
  and a struct nesting the struct; vs03 a class from a third package r::C; vs04 free
  functions in both packages with per-use copies; vs05 a member typed by a class typedef
  c_t; vs06 a specialized class member C#(8); vs07 a $unit struct (control); vs08 the home
  package's own class (control); vs09 an importer-package struct nesting the home struct,
  fixed and queue arrays of it.
- § enumBaseAliasCopyBare446 (VE): ve01 a logic base typedef; ve02 a base typedef of a
  typedef (must abstain); ve03 a module port of the enum; ve04 a base typedef imported from a
  third package r (must abstain); ve05 three enums, one int-based; ve06 a signed base in a
  free function of the importer.
- § importGroupKeepsHomeOrder446 (VG): vg01 two importer packages; vg02 macro-written free
  functions; vg03 two classes' macro methods, the importer importing another package first;
  vg04 a module importer only; vg05 an export p::* chain r -> q -> p; vg06 an import after
  the importer's own function.
- § clsBodyCallBindsHomeTopTf446 (VC): vc01 a task call; vc02 the importer declaring its own
  function of the same name; vc03 two home packages; vc05 a struct argument typed by the
  home typedef; vc06 a default argument and a property initializer; vc08 a derived class in
  a third package; vc09 a scoped p::rep beside the bare call; vc11 a nested class and the
  importer's own function; vc12 a parameterized class; vc13 import order p1 then p2.
- § cloneBodyCallBindsHomeTopTf446 (VC): vc04 a task wrapper and recursion; vc07 the home's
  out-of-body method; vc10 a module importing both; vc14 import order p2 (a re-importer)
  then p1.
- § clsTdQueueLocalCloneUnsupported446 (VQ): vq01 an enum class typedef; vq02 scalar class
  typedefs in a dynamic array and a queue; vq03 a scoped F::al_t (must abstain); vq04 a
  typedef inherited from a base class; vq05 an associative array and a bounded queue beside
  an in-class method; vq06 a class typedef of a package typedef; vq07 a static method called
  from the importer.

Pristine -> law:

| outcome | n | cases |
|---|---|---|
| to STRICT_EQUAL | 11 | VE ve01, ve05; VG vg01, vg06; VQ vq04, vq07; VS vs02, vs03, vs04; VT vt02, vt04 |
| to STRICT_NOTEQUAL | 2 | VE ve06 (name; eb03's face), VS vs06 (endcol: the C #(8) member span, both binaries) |
| closer, unequal | 7 | VG vg02 (cmp 248 -> 17), vg05 (236 -> 60); VQ vq01, vq02, vq05, vq06 (record distance 85 -> 45, 350 -> 70, 304 -> 204, 239 -> 139); VT vt05 (174 -> 17) |
| STRICT_EQUAL on both, bytes moved (bindings) | 10 | VC vc01, vc03, vc04, vc05, vc06, vc08, vc09, vc11, vc12, vc13 |
| same distance, bytes moved | 5 | VC vc02, vc07, vc14; VE ve04; VS vs05 |
| byte-identical | 13 | VC vc10; VE ve02, ve03; VG vg03, vg04; VQ vq03; VS vs01, vs07, vs08, vs09; VT vt01, vt03, vt06 |
| further | 0 | |

No case moves away. Per object (evidence/call_bindings_distance.txt and the record
multisets): no record and no call binding that pristine had right is wrong on the law. The
same-distance movers are wrong on both binaries:

- vc02: golden binds the class's call `rep` to p TOP although the importer declares its own
  rep (a Surelog lookup that prefers the import); pristine and the law bind q's own rep. The
  law moves the other call (oth) to golden.
- vc07: golden lists the home's out-of-body method body only in p's DEF view; ours writes
  clone bodies in q that golden does not have, their call now bound to p TOP.
- vc14: golden binds g through the FIRST wildcard-imported package that lists it (p2's
  clone); pristine p3 TOP, law p1 TOP. Same face as probe a9_class_holder.
- ve04: the class call moves to golden (p TOP); the first uhdm-cmp difference is elsewhere.
- vs05: the member typed by the class typedef c_t; golden writes the c_t typedef object
  (listed in the importer, instance q), ours an unnamed C copy with instance null on
  pristine and p on the law.

Switches (evidence/attack_switches.txt, attack_trace.txt): R11U446_OFF gives pristine's bytes
on 48 of 48. On the 35 movers, the firing law's own switch alone restores pristine on 31;
ve01 and ve05 fire § enumBaseAliasCopyBare446 and § clsBodyCallBindsHomeTopTf446 and need
both switches, each switch dropping its own law's bytes only. On vc07 and vg05 the trace of
§ clsBodyCallBindsHomeTopTf446 fires (it logs when it swaps a takeover entry) but the bytes do
not depend on it (no class-body call reads a swapped entry); the other firing law's switch
alone restores pristine. Every switch that changes bytes belongs to a law the trace names.

Downstream (evidence/downstream_classfree.txt) on the 8 class-free cases of both grids (CG
cg01, IG ig02, EB eb03, VC vc04, vc10, VE ve03, ve06, VG vg02): 6 IDENTICAL and 2 DIVERGENT
(vc10, vg02: a constant value mismatch from `initial o = wrap(1)`, a function-call fold) on
both pristine and law; no verdict changes.

## Residues (all wrong on pristine too, none moved away)

1. Call lookup through the first wildcard-imported package that lists the name: golden
   binds the clone in the earlier importer (p2's clone of p1::f, p2 TOP) where the law binds
   the home (probe r10uvm227 a9_class_holder, VC vc14). § clsBodyCallBindsHomeTopTf446
   should pick the first import statement's provider, not the home.
2. A class call resolving to an import over the importer's own same-named function (VC
   vc02): golden binds the imported one.
3. A struct member typed by a class typedef (VS vs05): golden reuses the typedef object
   listed in the importer.
4. A home struct member nested in an importer-package struct (VS vs09): the class member
   carries the importer q where golden carries p; non-null, so the law does not touch it.
5. Task calls in clone bodies bound to the home's DEF view where golden binds TOP (VC vc04
   tk, both binaries).
6. The out-of-body method clone bodies golden does not write (VC vc07, CB cb04).
7. The implementer's residues stand: ct02, sm03, eb03 (and ve06, the same reference-typespec
   face), the remaining uvm-examples faces (the sister-ground list below), easyUVM, the 3
   uvm_scoreboard rows, bsg_nonsynth_mem_1rw_sync_assoc, bsg_scheduler_dataflow, p733,
   p737, tnoc and the carried lists of pass 444 and earlier.

## Sister-ground faces (reported, not written)

As the implementer reports: StmtEmit's foreach loop variables in import-group clones
(get/set_packed_ints and longints, uvm_init's idx, get_blocks's blk_, perform_accesses's i),
the constructor clone's rh binding (ExprEmit/StmtEmit), collectPkgTfListing's group order
(EmitHelpers.h; § importGroupKeepsHomeOrder446 repairs its output), and ParamEmit
emitPackage's subMap takeover (§ clsBodyCallBindsHomeTopTf446 and
§ cloneBodyCallBindsHomeTopTf446 repair its bindings).

## Process

- Within the budget: one law build (no verified build: no refinement), one full five-stage
  sweep, no pristine build, no pristine sweep.
- The sweep started after three quiet readings at 09:56 and ended at 10:19. My first quiet
  waiter exited 1 on its own last test and did not chain into the sweep; the sweep was then
  launched by hand on a quiet reading.
- Slips, none affecting a measurement:
  - The second attack batch (10 cases, one process at a time at nice 19) ran beside my own
    sweep's corpus stages.
  - The two targeted runner calls (uvm_messaging_example and uvm_priority_arbitration on
    both binaries, --jobs 2) were launched on a quiet reading of 3 live processes that I
    misread, and overlapped the first minute of the sister verifier v11u447's law sweep
    (its probe stage); timing only for both.
  - My first downstream case batch passed relative case paths to a driver that changes
    directory, so every call failed before running anything; rerun with absolute paths.
- The fence list was read into a file by a program and never printed; every cmds.txt list
  was filtered on it first. No fenced test was named, opened or run. No other agent's
  process was touched.

## Files

- cases/<GROUP>/<case>/dut.sv, each first line `// § <law>`: VT (§ clsLocalTdTopHomeInst446),
  VS (§ aggCopyClassMemberHomeInst446), VE (§ enumBaseAliasCopyBare446), VG
  (§ importGroupKeepsHomeOrder446), VC (§ clsBodyCallBindsHomeTopTf446 and, for vc04, vc07,
  vc10, vc14, § cloneBodyCallBindsHomeTopTf446), VQ (§ clsTdQueueLocalCloneUnsupported446).
- drivers/run1.sh (golden + ours + uhdm-cmp + strict + record distance, keyed on the full
  repro path), drivers/switches.sh, drivers/ds1.sh (downstream verdict per case),
  drivers/bind.cpp (call-binding lister), drivers/bindcmp.sh, drivers/msaway.py (per-record
  away/closer multiset count).
- evidence/: the measurements above.
