# r11u463: the first-lister name of a cross-package class-specialization typedef

Pass 463, expression/parameter ground (ParamEmit only), on base 5d42effa.
One law, § firstListerNamesClassTd463 (R11U463_FIRSTLISTER_OFF; R11U463_OFF drops
the pass; R11U463_TRACE=<dir> logs each firing).

## The targeted row

| row | base (control /tmp/intr11u460) | law2 sweep |
|---|---|---|
| generated/uvm-examples/uvm_many_to_one.sv | DIFFERENT, uhdm-cmp 168 lines, head the class_typespec name `b_pkg::A_sequencer` (golden) vs `a_pkg::A_sequencer` (ours) | DIFFERENT, the name now golden's at all 42 occurrences (golden 42 / pristine 0 / law 42 of `b_pkg::A_sequencer`), the head moved later in the walk to module_inst work@top's vpiTypedef listing (golden 130 entries, ours 128: golden also lists `b_pkg::B_sequencer` and `c_pkg::C_sequencer` at 88:9, the sister's ground); path-normalized dump distance to golden 1471780 -> 1471710 |

Fresh csv row: `generated/uvm-examples/uvm_many_to_one.sv,DIFFERENT,decompile:,` (no status move).
Evidence: evidence/many_to_one_head_pristine.txt, evidence/many_to_one_head_law.txt.

## The decode

Surelog's `UhdmWriter::writeDataTypes` (third_party/Surelog/src/DesignCompile/UhdmWriter.cpp)
renames a package listing's typespec to `<writer package>::<name>` only while the
name holds no `::`. `UhdmWriter::write` calls `writePackage` over the elaborated
packages first (TopPackages) and then over the definition packages (AllPackages),
each in compile order. So a typespec object that several packages list is named
by the FIRST package that lists it, not by the package that declares it.

The object several packages list is the base of a cross-package class-specialization
group: the typedefs of one generic class across packages (`typedef uvm_sequencer
#(A_item) A_sequencer;` in a_pkg, `B_sequencer` in b_pkg, `C_sequencer` in c_pkg,
and uvm_pkg's own group). Every package with a member lists the base object.
Ours already lists it in every such package, in both views, and parents it as golden does.
Ours names the base `<declaring package>::<typedef>` when the typedef is made,
so on uvm_many_to_one (b.sv compiled before a.sv) ours wrote `a_pkg::A_sequencer`
where golden writes `b_pkg::A_sequencer`.

## The law

§ firstListerNamesClassTd463 (ParamEmit, a static function called at the end of
`drainPaNameCopySrc38`, after every listing is complete). It walks
TopPackages and then AllPackages, records the first package that lists each
class_typespec, and renames `<P>::<T>` to `<first lister>::<T>` under these conditions:

- the name has exactly one `::`;
- P is a package that declares a typedef T;
- P itself lists the object, so it is P's own object (an import clone that carries
  the home name is never listed by the home, and is never renamed);
- the first lister is not P.

Switch R11U463_FIRSTLISTER_OFF. There is no src/R*.h, no getenv and no
header change. The only production file changed is src/ParamEmit.cpp.

## Grid: cases/MO (every case's first line names the law)

Runs used drivers/grid.sh, with Surelog given the probe arguments and ours given
`dut.sv --single-unit --nobuiltin`. "dist" is the path-normalized uhdm-dump
distance to golden. Golden's full name for each base is the same as the law's.

| case | shape | pristine | law2 | dist |
|---|---|---|---|---|
| mo01 | u::S; b then a specialize it | rc=0 cmp=168 NOT_EQUAL (head the name) | rc=0 cmp=244 NOT_EQUAL, head later (b's top clone) | 109 -> 79 |
| mo02 | mo01 + a module importing a | rc=0 168 | rc=0 244 | 117 -> 79 |
| mo03 | b, a, c | rc=0 168 | rc=0 244 | 178 -> 154 |
| mo04 | CONTROL: a then b (the declaring package lists first) | rc=0 244 | byte-identical | 93 -> 93 |
| mo05 | u also has `typedef S #(item) dflt_t` | rc=0 168 | rc=0 17 (head: a's import clone dflt_t alias) | 185 -> 155 |
| mo06 | $unit class and a package class use a_seqr | rc=0 168 | rc=0 17 | 147 -> 107 |
| mo07 | b declares a_seqr, a declares z_seqr (golden's base is a's z_seqr, named b::z_seqr) | rc=0 168 | rc=0 244 | 109 -> 79 |
| mo08 | c, b, a; a module imports b | rc=0 168 | rc=0 244 | 192 -> 168 |
| mo09 | many_to_one's shape: e imports abc (which imports a and b), with $unit imports of e and a | rc=0 168 | rc=0 466, head module top's listing (golden lists b::B_seqr, ours does not) | 100 -> 56 |

- Exit codes: every exit code is 0 on both binaries.
- Movers: 8 of 9 cases move, and every one moves closer to golden. mo04 is byte-identical.
- Switch check: R11U463_OFF and R11U463_FIRSTLISTER_OFF each give pristine's md5 and exit code on 9 of 9 (evidence/switchcheck.txt).
- Name check: in every moved case, golden's tally of the base name equals the law's (e.g. mo08 golden `c::a_seqr`, law `c::a_seqr`, pristine `a::a_seqr`).
- Remaining differences (dump diff) are another face: b's top-view `b_seqr` in golden is a copy of the cross-package base (the base's span, a vpiTypedefAlias to it and the base's REQ listing). Ours keeps b_seqr's own span and REQ (residue 1).
- mo09 reproduces many_to_one's next head exactly.

## Gates: one five-stage sweep on law2

law2 md5 52ac6a553edc38ab6cd19ded4afdbf5e. The pristine binary is the main tree's
build, md5 77a3babefa0c97023405689e1ebec60c; my worktree's first build was
byte-identical to it. The pristine sweep reading is the master's control /tmp/intr11u460.

- Probe: EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0 changes=0.
- Surelog: default CMP_EQUAL 480 + 0, testflags 474 + 0, 0/0/0. Tnoc d/t stays CMP_NOTEQUAL.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
- Downstream: IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0; not identical and not excused 0.
- sv-tests: EQUAL 1928, STRICT_NOTEQUAL 2, DIFFERENT 10, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions=0 conversions=0 changes=0.
- CSV diffs: all five csvs equal the control's after path normalization (probe, surelog, uhdm2rtlil and downstream line for line; svtests.csv byte-identical).
- How the stages ran:
  - The worktree's tests/sweep.sh ran the four corpus stages (rc 0).
  - The sv-tests stage ran through the main tree's tests/sweep.sh at the same base, because the worktree's UVM folder is empty. That stage exited 1 only on the main tree's stale law index, which is the same reading passes 459 to 461 recorded.
- byteverify (SELFCHECK=1) against the control:
  - Surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805; each self-check flags all but one.
  - The probe stage keeps no databases.
  - sv-tests: 33 of 33 kept databases differ in raw bytes. uhdm-strictcmp --no-canon reads 32 of them STRICT_EQUAL against the control; that is the serialization-order variance passes 455 to 461 recorded. The one that is NOT_EQUAL is uvm_many_to_one, the law's mover (evidence/svtests_movers_strictcmp.txt).
- Canaries: ok=52 and ok=16 with changed=0; both ctcan2 checks PASS.
- Binary audit (fence-filtered): surelog 1523 of 1573 records name law2 (the other 50 hold no slang line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346. No record names another slang-uhdm binary.
- Trace: exactly 1 firing in the whole sweep, `firstListerNamesClassTd463 a_pkg::A_sequencer -> b_pkg::A_sequencer` on uvm_many_to_one.

## Prediction (written before the sweep, evidence/prediction.txt) and how it held

The prediction came from a traced census of law2, using MO/mo01 as the positive control.

| corpus | census run | predicted firings | sweep result |
|---|---|---|---|
| probe | all 4087 cases | 0 | held |
| surelog | the 26 candidate rows of a text census, both modes (statuses equal to the baseline) | 0 | held |
| uhdm2rtlil and downstream | text census | no candidate | held |
| sv-tests | the 106 uvm / testbenches / easyUVM rows | 1 (uvm_many_to_one) | held |

Movers predicted by name: uvm_many_to_one only. That held exactly, with 0 corpus movers.

## Goal 1 on this ground

Nothing new. The sweep's rejecting rows are unchanged, and every SURELOG_ONLY row
carries an upstream slang diagnostic, as passes 407 to 461 recorded.
- The black-parrot rows stay SURELOG_CRASH under § macroVecLitTokenText403's size guard.
- No memory-bounded export was attempted. The guard was not lifted.
- The probe goal-1 faces C::mk().arr[1], u.mk(x).a[2] and this.mk().inner.s were not reached.

## Residues, ranked

1. **This ground (ParamEmit, not written): the cross-package group copy.**
   - Golden: in the top view, the earlier package's own typedef of the same generic class is a copy of the cross-package base. It has the base's span, a vpiTypedefAlias to the base, and the base's REQ listing (mo01 b::b_seqr at 16:11 aliasing b::a_seqr with REQ -> a_item).
   - Ours resolves the base/alias pass (pkgClassTd9 in emitPackage) per package, so b_seqr keeps its own span and REQ.
   - The uvm row does not show it, because its members already join uvm_pkg's import group. It is the next head of mo01 to mo08 only.
2. **mo05: the import clone of a home typedef of the same generic class.**
   - In golden, a's clone of u::dflt_t aliases the cross-package base. Ours has no alias.
   - Same family as residue 1 (pkgImportClassTd50's per-package base pick).
3. The carried lists of passes 461 and earlier (r11u461, r11u459, r11u457, r11u455, r11u453 READMEs and their verifier twins), unchanged by this pass. None of them is reached by the law.

## Sister-ground faces (report only)

- **ModuleEmit: a module's typedef listing on the $unit-import route.**
  - This is the head of uvm_many_to_one after this law.
  - Golden: module work@top lists `b_pkg::B_sequencer` and `c_pkg::C_sequencer` (88:9) in addition to the base. They reach it through the $unit import of env_pkg, whose DataTypeMap holds what abc_pkg imported from b_pkg and c_pkg.
  - Ours lists the base only (130 vs 128 entries).
  - Case MO/mo09 reproduces it. In golden, module top and class test list b::A_seqr and b::B_seqr. In ours, class test lists both and module top lists only b::A_seqr.
- Unchanged from pass 461: pipelined_get_put's chain (TypeEmit/UhdmExporter), id_register's and ac_config_db's strict faces, param_vif_config_db.

## Process

- Builds: law1 and law2, plus two instrumentation builds (dbg1, dbg2) of ParamEmit only, used to locate where the cross-package listing is complete. Their prints were removed, and the file was restored from a saved copy before law1.
- Runs: targeted runner calls on uvm_many_to_one (law2), one traced census, and one full five-stage sweep on law2.
- No pristine build or sweep of my own, and no sweep or runner overlapped another (quiet checks before each launch).
- Fence: the fence list was read into a file by a program, never printed, and every tree-wide path list was filtered on it before use. No fenced test was named, opened or run.
- I touched no other agent's process or file. A localizer binary in the sister's scratch was found and NOT used.

## Files

- cases/MO/mo01 to mo09.
- drivers/runcase.sh, grid.sh, env.sh.
- evidence/: grid.txt, switchcheck.txt, prediction.txt, sweep_corpus.log, sweep_svtests.log,
  trace_sweep.txt, byteverify.txt, svtests_movers_strictcmp.txt, canaries.txt, binary_audit.txt,
  many_to_one_head_pristine.txt, many_to_one_head_law.txt.
