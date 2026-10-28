# v11u455 — adversarial verification of r11u455

Pass 455, expression/parameter ground. Base 7f271bbb (pass 452 on top of pass 453).
Verdict: CONFIRMED WITH ONE BREAK FIXED. The implementer's single law
§ oobInheritedCallBindsOwnPkgClone455 (R11U455_OOBPKGCLONE_OFF) reproduces bit for bit and converts
generated/uvm-examples/uvm_vif_config_db.sv DIFFERENT -> EQUAL. The attack grid found one break on legal
SV, a call link where pristine agreed with golden and the law did not. Neither judge reads that link. The
verifier fixes it as § oobCloneViewKeepsPristine455v (R11V455_CLONEVIEW_OFF, ExprEmit, read through
`fixOn(455, ...)`).

## Binaries

* pristine: the main tree's build/slang-uhdm at the base, md5 b14a8513b3c466ce49608d70120e8f0b, frozen
  at /tmp/v11u455_bin/pristine. No pristine build and no pristine sweep (measurement budget). The pristine
  sweep reading is the master's control /tmp/intr11u452.
* law: /tmp/r11u455.patch applied on a fresh 7f271bbb worktree, built once with -j 2: md5
  f0435d98ed5777c0eb475f56bb1cbb75. This equals the implementer's law2. It links slang 12.0.0+545f88b2e.
* ver: law + the fix, built once: md5 27f6c181d45a5583719df850eaaf6bc6.

## The break and the fix

Shape: package q imports p::*. q's class C has an out-of-body method that calls p's free function f. A
package s imports q only, not p. The law also fires while s's import-group copy of q::C::g is being
emitted (pkgImportCloneEmit; trace lines ending in " clone"). It links q's clone of f. The design-final
relink § cloneBodyCallBindsHomeTopTf446 (UhdmExporter) then sees a call whose target is a member of q's
import group, sitting in a body that is a member of s's group. It re-points the call to the callee's home
package p.

Pristine links s's own clone at emission, and that relink moves it to q's clone, which is golden's link.

* cases/VG/vg01: in s's copies (ALL and TOP), golden and pristine link `f in package:q[TOP]`; the law
  links `f in package:p[TOP]`. Both judges read STRICT_EQUAL on every binary.
* The same face in the gate: sv-tests uvm_param_vif_config_db. tb_params_pkg imports sfr_agent_pkg
  only, and its copy of `sfr_agent::build_phase` links `uvm_report_error`. Golden and pristine link
  sfr_agent_pkg's TOP clone; the law links uvm_pkg's function. The link census reads lost=2 on law,
  lost=0 on ver.

§ oobCloneViewKeepsPristine455v (R11V455_CLONEVIEW_OFF): the law abstains inside an import-group copy,
for both the function half and the task half. lawTrace logs OOBPKGCLONE_CLONEVIEW_ABSTAIN /
OOBPKGCLONE_TASK_CLONEVIEW_ABSTAIN.

The law gains nothing in that context:
* On every firing sv-tests row, the matched links it gained equal its non-clone firings: vif 10, ef 12,
  ac 12, id_register 6, param_vif 12.
* On oc07 (s imports p and q), the relink already undid the law's clone link, so law and ver are
  byte-identical there.

Switches:
* R11V455_OFF and R11V455_CLONEVIEW_OFF each give the law's bytes.
* R11U455_OFF and R11U455_OOBPKGCLONE_OFF each give pristine's bytes.
* Checked on VG/vg01 to vg05, OC/oc01, OC/oc07 and VT/vt01 (evidence/switches.txt).

## Grid (evidence/grid.txt; drivers/vgrid.sh)

Every line carries the exit code. Each line also carries uhdm-cmp's line count, the strict verdict and
the call-link census, which is the multiset of (call parent chain, linked subroutine owner and view)
from drivers/links.cpp. The census gives golden-only links, and the matched links lost and gained
against pristine.

### The implementer's 10 OC cases

Reproduced on rc, uhdm-cmp count, strict verdict, moved/same and link census:
* oc04: 556 -> STRICT_EQUAL 97.
* oc06: STRICT_NOTEQUAL type on both binaries.
* oc03, oc05 and oc08: byte-identical controls.
* The link-census table is equal to the implementer's.
* ver is byte-identical to law on all 10.

### 26 fresh case dirs

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit), and every exit code is 0
on all three binaries.

Law control cases (first line § oobInheritedCallBindsOwnPkgClone455):

| case | shape | pristine -> law = ver |
|---|---|---|
| VB/vb01 | base class in a third package, free f in p | g-only 2 -> 1, STRICT_EQUAL 174 |
| VB/vb02 | inherited method with no free twin, plus a free k | 1 -> 1, bytes move (the class-view call golden does not list) |
| VC/vc01 | outer class OOB plus a nested class's in-class call | 2 -> 1 |
| VD/vd01 | imported call as an OOB default argument | same bytes (not reached) |
| VE/ve01 | explicit import p::f | 2 -> 1 |
| VE/ve02 | explicit plus wildcard import | 3 -> 2 |
| VI/vi01 | OOB virtual override, calls in an if | 6 -> 3, STRICT_EQUAL |
| VK/vk01 | two imported packages, base class from one | 2 -> 2, bytes move in a class view golden folds; STRICT_NOTEQUAL type on both, oc06's face |
| VL/vl01 | local initializer, named block, task with an output | 6 -> 3 |
| VM/vm01 | two classes and a package function | 7 -> 4 |
| VM/vm02 | two importing modules | 2 -> 1 |
| VN/vn01 | OOB constructor | 2 -> 1 |
| VP/vp01 | parameterized class | 2 -> 1 |
| VR/vr01 | void call, foreach and for bodies | 6 -> 3 |
| VR/vr02 | OOB constraint and randomize-with | same bytes (not reached) |
| VS/vs01 | OOB static function | 2 -> 1 |
| VT/vt01 | fork with imported task and function | 6 -> 3 |
| VT/vt02 | task in fork join_none inside an OOB function | 2 -> 1 |
| VU/vu01 | $unit class beside a package class | 2 -> 1 |
| VW/vw01 | synthesizable module importing q | bytes move, 1 -> 1; downstream IDENTICAL on both binaries (14 gates) |
| VX/vx01 | export p::* chain | 5 -> 4 |
| VG/vg04 | s imports p and q | 4 -> 3, law = ver |

Break cases (first line § oobCloneViewKeepsPristine455v), as golden-only links pristine / law / ver:

| case | shape | pristine | law | ver |
|---|---|---|---|---|
| VG/vg01 | the break | 2 | 3 (lost 2) | 1 (lost 0) |
| VG/vg02 | the param_vif shape: parameterized C, s typedefs C#(4) | 2 | 3 (lost 2) | 1 (lost 0); uhdm-cmp 546 on all three |
| VG/vg03 | LAW C fall-back plus a task, s imports q only | 4 | 6 (lost 4) | 2 (lost 0) |
| VG/vg05 | two-level importer chain | 4 | 5 (lost 2) | 3 (lost 0) |

On VG/vg03 uhdm-cmp also moves: 1152 lines -> STRICT_EQUAL 258 objects, on both law and ver.

Summary:
* No case gets worse on uhdm-cmp or on the strict verdict on any binary.
* On ver, no matched link is lost on any case.
* Downstream verdicts on VW/vw01, VM/vm02 and VB/vb01 are IDENTICAL on both binaries.

## Gates

There is one five-stage sweep on each of law and ver, run from the worktree, each after three quiet
readings and never overlapping another sweep. The sv-tests stage runs through the main tree's
check_svtests.py because the worktree's UVM submodule is empty.

### Law sweep (/tmp/v11u455swp)

| Stage | Result |
|---|---|
| probe | 4023 + 64, 0/0/0 |
| surelog | 480 + 0 / 474 + 0, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 |
| downstream | 803/66/2/0, not excused 0 |
| sv-tests | EQUAL 1925, DIFFERENT 15, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions 0, conversions 1, changes 0 |

* Every csv is identical to the control apart from the conversion row
  (`generated/uvm-examples/uvm_vif_config_db.sv,EQUAL,,equal`), after path normalization.
* Every csv is identical to the implementer's sweep.
* byteverify against /tmp/intr11u452: 0 of 962, 0 of 1608 and 0 of 805, with the self-checks flagging
  961, 1607 and 804.
* Canaries: ok=52 and ok=16; ctcan2 surelog ok=58 PASS; ctcan2 uhdm2rtlil ok=2 PASS.
* Trace census: 7 firing processes and 128 firings, all in the sv-tests stage, on uvm_vif_config_db,
  uvm_ef_vif_config_db, uvm_ac_config_db, uvm_id_register, uvm_param_vif_config_db, uvm_slave_agent
  and uvm_slave_agent_multi_seq_item. These are exactly the implementer's rows and count.
* Binary audit, fence-filtered:
  * surelog: 1523 of 1573 records name the law binary; the other 50 hold only a Surelog line.
  * uhdm2rtlil: 1740 of 1740.
  * sv-tests: 2346 of 2346.

### Verified sweep (/tmp/v11u455vsw)

The prediction (evidence/prediction.txt) was written before this sweep, and it held:
* Every csv is identical to the law sweep's.
* byteverify against the law sweep is 0 of 962, 0 of 1608 and 0 of 805, and against the control the
  same.
* The trace has the same 7 processes and 128 firings, 44 of them now CLONEVIEW_ABSTAIN.
* The 6 firing kept sv-tests databases move bytes, and no status moves.
* The other 30 kept sv-tests databases also differ in raw bytes, but they differ between any two runs:
  the control, the law and ver each draw different hashes with identical uhdm-dump output (checked on
  6.23 type_op_compare, p58 and 16.15). This is pre-existing serialization-order variance, not a mover.

sv-tests: check_svtests.py printed `regressions=2` on ver. Both lines are uvm_use_models_bidir_get_put
and uvm_use_models_bidir_item_done EQUAL -> DIFFERENT, an artefact of the main tree's
results/golden_svtests.csv. Pass 454 (7b76f0685) landed during this verification and promoted those two
rows. This binary is at 7f271bbb, without pass 454. Recomputed against 7f271bbb's golden, both the law
sweep and the ver sweep read regressions 0, conversions 1 (uvm_vif_config_db), changes 0, and the ver
svtests.csv equals the law's.

### Rows rerun alone

Runner on 7 rows, pristine -> law (uhdm-cmp lines on the kept pair; link census matched lost/gained):

| row | uhdm-cmp | link census |
|---|---|---|
| uvm_vif_config_db | 29 -> 0, STRICT_EQUAL 632717 objects (law and ver) | lost 0, gained 10 |
| uvm_ef_vif_config_db | 29 -> 29 | 0 / 12 |
| uvm_ac_config_db | 29 -> 17 | 0 / 12 |
| uvm_id_register | 85 -> 85 | 0 / 6 |
| uvm_param_vif_config_db | 230 -> 230 | law 2 / 12, ver 0 / 12 |
| uvm_slave_agent, uvm_slave_agent_multi_seq_item | SLANG_ONLY on both binaries | |

## Goal 1

* bp_unicore alone on ver with the size guard on: exit 3 (the substr error), 16.8 s, 774 MB maximum
  resident set. The guard stays.
* The other goal-1 readings are the implementer's, reproduced by the sweep's sv-tests stage: 75
  SURELOG_ONLY rows unchanged.

## Residues (ranked; all wrong on pristine too)

1. The DEF-view listing link: a package's own definition-view body links its TOP clone where golden links
   the DEF clone (oc01 and the OC family, the bulk of the remaining golden-only links on the sv-tests
   rows). Neither judge reads it.
2. The importer copy when the importer also imports the callee's home (oc07, VG/vg04): golden keeps the
   class-home package's clone, and the § cloneBodyCallBindsHomeTopTf446 relink (UhdmExporter, the
   sister's ground) re-points to the home. Reported, not written.
3. An OOB method's default-argument call (VD/vd01) is not reached, and its call objects are unparented in
   ours. A class-view call golden folds or does not list (VB/vb02, VK/vk01, oc06). The OOB constraint and
   randomize-with calls golden links (VR/vr02, 2 golden-only links on every binary).
4. The implementer's residues stand: oc05 ($unit class) and the 15 open sv-tests rows.

## Sister-ground faces (reported, not written)

* UhdmExporter § cloneBodyCallBindsHomeTopTf446 keys the re-point on the target's group, not on the
  body's class home (residue 2).
* The implementer's two faces stand: the ModuleEmit interface-task binding walk on uvm_ef_vif_config_db,
  and the extra `this` wire on uvm_ac_config_db (§ thisNetPerListingModule452 family).

## Process

Within the budget:
* One law build and one verified build (a production fix).
* One five-stage sweep on each.
* byteverify once against the control and once against the law sweep.
* One 7-row runner call per binary on pristine and law, plus the vif row regenerated by hand on ver
  because the runner removes the database of an EQUAL row.

The attack grid's VR/vr02, VL/vl01 and VK/vk01 ran at nice 19 while the sister verifier's sweep was
live; this affected timing only. The fence list was read into a file by a program and never printed,
and every tree-wide list was filtered on it before any file was opened. No other agent's process was
touched. No fenced test was named, opened or run.

Drivers: drivers/run1.sh (implementer's, paths moved), grid.sh, vgrid.sh, links.cpp, linkdiff.sh and
run_all.sh (the sweep launcher). Build links.cpp with g++ -std=c++17 -I$HOME/.local/include links.cpp
-L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread.
