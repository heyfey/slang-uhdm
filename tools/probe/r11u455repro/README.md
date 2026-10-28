# r11u455 — pass 455, expression/parameter ground (implementer)

Base 7f271bbb (pass 452 on top of pass 453). Ground: src/ExprEmit.cpp and
src/ParamEmit.cpp (EmitHelpers.h and StmtEmit.cpp untouched). One law behind
its own switch read through src/LawSwitch.h (`lawOn(455, ...)`); `R11U455_OFF`
drops it; `R11U455_TRACE=<dir>` logs each firing through `lawTrace(455, ...)`
(with the caller, the package view being emitted and whether the body is an
import-group copy). No src/R*.h, no getenv, no header change.

Binaries: pristine = the main tree's build/slang-uhdm at the base (md5
b14a8513b3c466ce49608d70120e8f0b; the worktree's own first build is
byte-identical), frozen at /tmp/r11u455_bin/pristine; final law binary law2
(md5 f0435d98ed5777c0eb475f56bb1cbb75, links slang 12.0.0+545f88b2e). law1
differs from law2 only in the trace text.

## The head (sv-tests uvm_vif_config_db, uvm_ef_vif_config_db, uvm_ac_config_db)

uhdm-strictcmp on the kept pair at the base (all three rows the same head):

    LHS: class_var (uvm_pkg::uvm_report_enabled::cs) 87:21   RHS: <null>
    lhsPath: design(work@hdl_top) > package(uvm_pkg) > function(uvm_report_enabled) > begin > class_var(cs)

The multiset of `cs` bindings is identical on both sides
(drivers/refs.cpp, 256 lines each); the difference is WHICH function object a
`uvm_report_enabled(...)` call links: Compare walks golden's linked clone body
(where the `cs.get_root()` reference binds the home class_var) against ours
(the home's own body, where it is unbound). drivers/fcalls.cpp and
drivers/links.cpp on the pair: in every OUT-OF-BODY method of a class in a
user package (`function void sfr_agent::build_phase(...)`, its `uvm_error`
macro), golden links the call to the user package's OWN top-view clone of
`uvm_pkg::uvm_report_enabled` (sfr_agent_pkg's, sfr_test_pkg's); ours linked
uvm_pkg's object. pass 446's localizer (r11u446repro/evidence/tools/clsloc.cpp)
named the same failure in sfr_agent_pkg and sfr_test_pkg (build_phase,
report_phase).

Decode: Surelog compiles an out-of-body definition in its package's scope
(LAW C, § inheritedNameBindsPkgFn72's comment). `CompileHelper::getTaskFunc`
(third_party/Surelog/src/DesignCompile/CompileExpression.cpp) scans the
component's own `getTask_funcs()` first, and a package's listing already holds
the wildcard-import clone of every imported subroutine (§ collectPkgTfListing),
so the out-of-body call finds the importer's clone before
`getFuncFromPackage` ever reaches the home. A method written inside the class
compiles with the class as component, misses, and reaches the home through the
access packages (cases/OC/oc03: golden binds p's object).

## Law

§ oobInheritedCallBindsOwnPkgClone455 (R11U455_OOBPKGCLONE_OFF; ExprEmit, at
the vpiFunction / vpiTask link of emitExpr's call case, helper
`oobOwnPkg455`; the task twin of `importCopyFunc` recorded in ParamEmit next
to it, `topTaskClone455Find`) — an unqualified call in an out-of-body
class-method definition whose class sits in package P links P's own top-view
wildcard-import clone of the free subroutine when that subroutine is homed in
another package, whether slang resolved the name to the free subroutine
itself (oc02) or to an inherited or own-class method that LAW C falls back
from (oc01, oc10); functions and tasks (oc04). The link only: the call's name,
span and argument stamping are unchanged. Not reached and left alone: a method
written inside the class (oc03), a class in a module (oc08) or in $unit (oc05),
a qualified call, a call LAW C leaves unbound.

## Grid (cases/OC, 10 case dirs; drivers/grid.sh pristine law2)

| case | shape | pristine | law2 |
|---|---|---|---|
| oc01 § oobInheritedCallBindsOwnPkgClone455 | OOB call f(v), B::f inherited, p::f imported (the vif shape) | rc=0 cmp=0 STRICT_EQUAL 181 objects md5=11675697 | rc=0 cmp=0 STRICT_EQUAL 181 objects md5=e13eea4a (MOVED) |
| oc02 § oobInheritedCallBindsOwnPkgClone455 | OOB call of the imported free p::f, no method of that name | rc=0 cmp=0 STRICT_EQUAL 153 objects md5=62e769ae | rc=0 cmp=0 STRICT_EQUAL 153 objects md5=a4a69473 (MOVED) |
| oc03 § oobInheritedCallBindsOwnPkgClone455 | in-class method calling imported p::f (control: home object) | rc=0 cmp=0 STRICT_EQUAL 116 objects md5=4b401994 | rc=0 cmp=0 STRICT_EQUAL 116 objects md5=4b401994 (same) |
| oc04 § oobInheritedCallBindsOwnPkgClone455 | task twin: OOB t(2), B::t inherited, p::t imported | rc=0 cmp=556 NOT_EQUAL stage1 md5=c990e730 | rc=0 cmp=0 STRICT_EQUAL 97 objects md5=faf39d7e (MOVED) |
| oc05 § oobInheritedCallBindsOwnPkgClone455 | $unit class under import p::* (control: no package) | rc=0 cmp=212 NOT_EQUAL stage1 md5=081356bb | rc=0 cmp=212 NOT_EQUAL stage1 md5=081356bb (same) |
| oc06 § oobInheritedCallBindsOwnPkgClone455 | class in r importing q and p; f(v) + k() (q::k) | rc=0 cmp=0 STRICT_NOTEQUAL type md5=289b4f81 | rc=0 cmp=0 STRICT_NOTEQUAL type md5=c41015f1 (MOVED) |
| oc07 § oobInheritedCallBindsOwnPkgClone455 | OOB in q, class re-listed in importer s | rc=0 cmp=0 STRICT_EQUAL 220 objects md5=c727cc29 | rc=0 cmp=0 STRICT_EQUAL 220 objects md5=735f98c0 (MOVED) |
| oc08 § oobInheritedCallBindsOwnPkgClone455 | class inside a module (control) | rc=0 cmp=0 STRICT_EQUAL 123 objects md5=9b09e187 | rc=0 cmp=0 STRICT_EQUAL 123 objects md5=9b09e187 (same) |
| oc09 § oobInheritedCallBindsOwnPkgClone455 | calls in an if condition and a call argument | rc=0 cmp=0 STRICT_EQUAL 241 objects md5=b02670e6 | rc=0 cmp=0 STRICT_EQUAL 241 objects md5=a06e7c98 (MOVED) |
| oc10 § oobInheritedCallBindsOwnPkgClone455 | OOB calling its own class method f declared below, p::f imported | rc=0 cmp=0 STRICT_EQUAL 153 objects md5=1e4d7ef6 | rc=0 cmp=0 STRICT_EQUAL 153 objects md5=8dc31a49 (MOVED) |

Every exit code 0 on both binaries. Except on oc04, uhdm-cmp and uhdm-strictcmp are blind to
the link on these small cases (the visited set pairs golden's clone with ours
before the call is reached), so each case is scored by the call-link census
drivers/linkdiff.sh (golden-only / ours-only links, keyed by the call's
parent chain and the linked subroutine's package and view):

| case | pristine | law2 |
|---|---|---|
| oc01 | golden-only=2 ours-only=2 | golden-only=1 ours-only=1 |
| oc02 | golden-only=2 ours-only=2 | golden-only=1 ours-only=1 |
| oc03 | golden-only=0 ours-only=0 | golden-only=0 ours-only=0 |
| oc04 | golden-only=2 ours-only=2 | golden-only=1 ours-only=1 |
| oc05 | golden-only=1 ours-only=1 | golden-only=1 ours-only=1 |
| oc06 | golden-only=3 ours-only=4 | golden-only=2 ours-only=3 |
| oc07 | golden-only=4 ours-only=4 | golden-only=3 ours-only=3 |
| oc08 | golden-only=0 ours-only=0 | golden-only=0 ours-only=0 |
| oc09 | golden-only=4 ours-only=4 | golden-only=2 ours-only=2 |
| oc10 | golden-only=2 ours-only=2 | golden-only=1 ours-only=1 |

oc04 also moves uhdm-cmp: NOT_EQUAL (556 lines) -> STRICT_EQUAL 97 objects.
oc03, oc05 and oc08 are byte-identical controls. R11U455_OFF and
R11U455_OOBPKGCLONE_OFF each give pristine's bytes on all 10 case dirs
(evidence/switches.txt).

The remaining golden-only links after the law are the package's own
definition-view listing (`q::C::g` in q's DEF view links q's DEF clone in
golden and q's top clone in ours, structurally identical, pre-existing) and,
on oc07, the import-group copy in package s (see sister-ground faces).

## sv-tests

Runner (scripts/svtests/svtests_matrix.py --keep-golden) on the three sfr rows,
pristine -> law2:

    generated/uvm-examples/uvm_vif_config_db.sv     DIFFERENT -> EQUAL (uhdm-cmp EQUAL, strict equal)
    generated/uvm-examples/uvm_ef_vif_config_db.sv  DIFFERENT -> DIFFERENT, head moved later (uhdm-cmp 29 -> 29 lines)
    generated/uvm-examples/uvm_ac_config_db.sv      DIFFERENT -> DIFFERENT, head moved later (uhdm-cmp 29 -> 17 lines)

The fresh sweep row: `generated/uvm-examples/uvm_vif_config_db.sv,EQUAL,,equal`
(was `DIFFERENT,decompile:,`).

The next heads (both on the module/type ground):
* uvm_ef_vif_config_db: `logic_net work@hdl_top.SFR_MASTER.reset` 40:32
  (LHS golden, RHS null). The interface task `sfr_master_bfm::execute`
  (`if(reset == 1) begin wait(reset == 0); end`) in the definition view binds
  its `reset` reads to the instance's net in golden; ours leaves them unbound.
* uvm_ac_config_db: an extra `logic_net work@hvl_top.this` 968:29 in ours
  (rhsPath design > module_inst > logic_net(this)), § thisNetPerListingModule452's
  family.

uvm_id_register and uvm_param_vif_config_db also fire the law and keep their
pristine heads (class_typespec listings; uhdm-cmp 85 -> 85 and 230 -> 230 lines).
uvm_slave_agent and uvm_slave_agent_multi_seq_item fire and stay EQUAL.

## Prediction and census (evidence/prediction.txt, written before the sweep)

Candidate scan (drivers/scan.py, fence-filtered before any file is opened;
widened once to sibling-directory includes, no new candidate): probe 148
cases, surelog 14 rows, uhdm2rtlil 0, sv-tests 231 rows. Trace census on the
candidates with law2: probe 148 of 148 byte-identical to the master's control
with 0 firings (positive control: cases/OC/oc01 under the same script reads
fire=1 MOVED); the 14 surelog rows are SLANG_REJECT at the base; sv-tests: 7
rows fire (uvm_vif_config_db, uvm_ef_vif_config_db, uvm_ac_config_db,
uvm_id_register, uvm_param_vif_config_db, uvm_slave_agent,
uvm_slave_agent_multi_seq_item), one status moves (uvm_vif_config_db
DIFFERENT -> EQUAL). The sweep's trace names exactly the same 7 rows (128
firings) and nothing in probe, surelog, uhdm2rtlil or downstream: the
prediction held.

## Gates

One full five-stage sweep on law2 (workdir /tmp/r11u455swp, started after
three quiet readings; the four corpus stages from the worktree, the sv-tests
stage through the main tree's tests/sweep.sh since the worktree's UVM
submodule is empty):

* probe: EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, regressions=0
  conversions=0 changes=0; probe.csv identical to the control; the 4087
  databases identical to the control by path-normalized dump (raw bytes
  differ only by the source path, worktree vs main tree).
* surelog: default CMP_EQUAL 480, testflags 474, regressions=0
  conversions=0 changes=0; the csv differs from the control only in the two
  LowMem log-path texts.
* uhdm2rtlil: 803/1/67 in both modes, regressions=0 conversions=0
  changes=0; csv identical to the control.
* downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  not identical and not excused 0; csv identical to the control.
* sv-tests: EQUAL 1925, STRICT_NOTEQUAL 0, DIFFERENT 15, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions=0 conversions=1 changes=0 (CONVERSION
  generated/uvm-examples/uvm_vif_config_db.sv: DIFFERENT -> EQUAL); the csv
  differs from the control in that row only. That stage's exit code 1 comes
  from the main tree's law-index check (the main tree's tests/LAWS.md read
  stale there); the worktree's own check reads current.
* byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) law sweep
  vs the master's control /tmp/intr11u452: surelog 0 of 962 (selfcheck 961),
  uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804). No mover, as
  predicted.
* canaries: ctcan2 surelog ok=58 changed=0 (EXPECT_UNKNOWN=1) PASS; ctcan2
  uhdm2rtlil ok=2 changed=0 (EXPECT_UNKNOWN=6) PASS. canaries.sh printed only
  its usage note on these csvs.

## Goal 1

No rejecting sv-tests row carries an exporter message: the six rows whose
detail names a path under slang-uhdm's tree carry the uvm_pkg time-scale
diagnostic or a keyword parse error, upstream slang diagnostics. The goal-1
probe faces C::mk().arr[1], u.mk(x).a[2] and this.mk().inner.s were not
reached. black-parrot bp_unicore measured alone on law2 with the size guard
on: exit 3 (the substr error behind the guard), 13 s, 830 MB maximum resident
set; the guard stays.

## Residues (ranked)

1. The definition-view listing link: in package q's own DEF-view listing,
   `q::C::g`'s call links q's top-view clone where golden links q's DEF-view
   clone (oc01, oc02, oc04, oc06, oc09, oc10). Pre-existing, structurally
   identical, read by neither judge; not written.
2. oc06: in the class view of an out-of-body method Surelog folds a call to
   a constant function with constant arguments (`k()` returning 3) to a
   constant (STRICT_NOTEQUAL type on both binaries); the first version of
   oc02 (f(2) with `return a`) showed the same fold. Not decoded further.
3. oc05: a $unit class under `import p::*` stays NOT_EQUAL (212 lines) at
   another face on both binaries.
4. The 15 open sv-tests rows: uvm_ef_vif_config_db and uvm_ac_config_db
   (sister faces below), the six undecoded uvm-examples rows (the sister's
   first item; id_register and param_vif_config_db at their class_typespec
   heads), the 3 scoreboard rows and easyUVM, p733, p737 and tnoc (await the
   user's decision), and the carried lists of passes 453 and earlier.

## Sister-ground faces (reported, not written)

1. ModuleEmit, the interface task binding fixup (`walk9` in the interface
   definition emitter, where § ifcTaskFixupWalksStmts450 sits): the walk does
   not enter an if_else's or if_stmt's condition nor a wait_stmt, so
   `if(reset == 1)` and `wait(reset == 0)` in sfr_master_bfm::execute stay
   unbound (uvm_ef_vif_config_db's head). Measured with a local experiment
   binary (never delivered, the edit reverted and the worktree rebuilt to
   law2's md5): walking those three makes uvm_ef_vif_config_db uhdm-cmp
   EQUAL, STRICT_NOTEQUAL fullname (1048 objects), the first
   `ref_typespec uvm_pkg::UVM_SEQ_ARB_TYPE` named
   work@sfr_monitor_bfm.uvm_pkg::UVM_SEQ_ARB_TYPE where golden writes
   work@hvl_top.uvm_pkg::UVM_SEQ_ARB_TYPE; uvm_ac_config_db does not move
   under the experiment.
2. uvm_ac_config_db's extra `this` wire in hvl_top (968:29), the
   § thisNetPerListingModule452 family (ModuleEmit / TaskFuncEmit).
3. UhdmExporter § cloneBodyCallBindsHomeTopTf446: in an import-group copy of
   an out-of-body method (sfr_test_pkg's copy of sfr_agent::build_phase;
   oc07's copies in s), golden keeps the class-home package's clone
   (sfr_agent_pkg's, q's), and this law now binds it there at emission, but
   the design-final relink re-points it to the callee group's home (uvm_pkg,
   p) because it keys on the target's group rather than on the body's.
   Invisible to uhdm-cmp on the vif row; the link census
   (drivers/linkdiff.sh) shows it.

## Process

Within the budget: no pristine build of its own beyond the worktree's first
build (byte-identical to the main tree's), no pristine sweep (the master's
control /tmp/intr11u452 is the pristine reading); intermediate binaries law1
and law2 on case runs, one 3-row runner call each on pristine and law2, one
candidate-row census call on law2 (231 sv-tests rows, 148 probe cases, 14
surelog rows), one full five-stage sweep on law2, byteverify once. Slips, none
affecting a measurement: the first sweep launcher's quiet check matched its
own script name (`r11u455_sweep.sh` against the `sweep.sh` pattern) and was
stopped by its task id before it ran anything, then relaunched under another
name; the second grid pass and the switch check ran at nice 19 while the
sister's sweep was live; one experiment binary (`exp_sister`) was built with a
temporary ModuleEmit edit to measure the sister face, the file restored and
the worktree rebuilt to law2's md5 before the sweep, nothing of it in the
patch. The fence list was read into a file by a program and never printed;
every tree-wide list was filtered on it before any file was opened; no fenced
test named, opened or run; no other agent's process touched.

Drivers: drivers/run1.sh, grid.sh, goldpath.sh, env.sh (from r11u453repro,
paths renamed), scan.py (the candidate scan), cenprobe.sh (the probe census),
linkdiff.sh / linkkey.sh with links.cpp, fcalls.cpp, tcalls.cpp, refs.cpp,
pk.cpp (UHDM readers compiled against ~/.local's libuhdm), pnorm.sh (the
path-normalized probe comparison). Evidence: prediction.txt, grid.txt,
links.txt, switches.txt.
