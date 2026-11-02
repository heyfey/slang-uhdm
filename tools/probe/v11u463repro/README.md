# v11u463: adversarial verification of r11u463

Pass 463 (expression/parameter ground, ParamEmit only), base 5d42effa. The law under test is
§ firstListerNamesClassTd463 (R11U463_FIRSTLISTER_OFF; R11U463_OFF drops the pass). It renames a
package class-specialization typedef object `<P>::<T>` to `<first lister>::<T>` when an earlier
package already lists the same object.

**Verdict: two breaks found and fixed.** The attack grid found two shapes of legal SV where pristine
was closer to golden and the law moved names away from it. Both shapes are fixed by abstaining,
behind their own switches in src/ParamEmit.cpp:
- § unitGroupAbstain463v (R11V463_UNITGRP_OFF);
- § tdChainAbstain463v (R11V463_TDCHAIN_OFF).

R11V463_OFF drops both fixes. Neither fix fires on any corpus row, probe case or sv-tests row, so all
five verified csvs are identical to the law sweep's. Deliverable: /tmp/r11u463.verified.patch.

## Binaries (frozen under /tmp/v11u463_bin)

| binary | md5 | source |
|---|---|---|
| pris | 77a3babefa0c97023405689e1ebec60c | the main tree's build/slang-uhdm at 5d42effa, copied; no pristine build of my own |
| law | 52ac6a553edc38ab6cd19ded4afdbf5e | rebuilt from /tmp/r11u463.patch; equal to the implementer's law2 |
| ver | 45e36af5778a500a9301e83c34fb8c9b | law plus the two fixes; the one verified build the budget allows |

All three report slang 12.0.0+545f88b2e.

## The implementer's grid, reproduced (evidence/implementer_grid_repro.txt)

All 9 MO cases reproduce on exit code, uhdm-cmp count, strict verdict and dump distance (mo01 109 -> 79, ..., mo09 100 -> 56; mo04 byte-identical).

## The breaks

The fixes target the law's assumption that the object ours lists first is golden's group base. Names below are counted in the uhdm-dump (evidence/name_tally.txt). "Overlap" is the sum over golden's names of min(golden count, ours count), in evidence/name_overlap.txt.

- **VG/vg06 and vg14 (§ unitGroupAbstain463v): a `$unit` typedef specializes the same generic class.**
  - Shapes: `typedef S #(ui) aa_unit_seqr;` declared before the packages (vg06) and `zz_unit_seqr` declared after them (vg14).
  - Golden's group base is that `$unit` typedef, named `b::aa_unit_seqr`. The declaring package's own object keeps `a::a_seqr`: golden has a::a_seqr 4 and a::a::a_seqr 13.
  - Ours leaves the `$unit` typedef out of the group, so b lists a's object first.
  - Pristine writes a::a_seqr 13 and a::a::a_seqr 5. The law renamed them to b::a_seqr 13 and a::b::a_seqr 5, two names golden does not have.
  - Overlap with golden: pristine 17, law 8.
  - The fix abstains when any compilation-unit typedef's canonical type is a specialization of the same generic class. vg06 and vg14 return to pristine's bytes, overlap 17.
- **VG/vg10 (§ tdChainAbstain463v): a typedef of a typedef in the declaring package.**
  - Shape: `typedef S #(a_item) a_seqr; typedef a_seqr a2_seqr;`.
  - Ours makes a2_seqr the group's object; golden keeps `a::a2_seqr` and bases the group on b's b_seqr.
  - The law renamed a::a2_seqr (pristine 7 + 1, golden 1 + 1) to b::a2_seqr (golden 0).
  - Overlap with golden: pristine 4, law 3.
  - The fix abstains when the typedef's declared target is itself a type alias. vg10 returns to pristine's bytes.
  - Controls for the same shape where the law is right and stays: vg15 (the base is the direct typedef, the alias named after it) and vg17 (the chain is in the earlier package).

The uhdm-cmp count and the dump distance are equal on pristine and law for all three cases (vg06 and vg14 168 / 234, vg10 104 / 118). The move away shows in the name cells only.

## Attack grid: 24 fresh case dirs in VG, VE and VU (evidence/grid3.txt)

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit, rc 0). Every exit code is 0 on all three binaries.

| group | cases | pris -> law -> ver |
|---|---|---|
| VG movers toward golden (law and ver one md5) | vg03 (an earlier package lists a late-named typedef) 172 -> 138, vg04 (four packages) 251 -> 209, vg07 (a class-nested typedef) 155 -> 121, vg08 (module and class variables through import) 148 -> 106, vg12 (two interleaved generic classes) 202 -> 142, vg13 (a module-local typedef) 171 -> 147, vg15 123 -> 91 (uhdm-cmp 168 -> 17), vg16 (a `$unit` typedef of an unrelated class) 217 -> 187, vg17 70 -> 40 | overlap 16->31, 24->43, 19->34, 9->28, 16->42, 21->32, 25->39, 16->29, 1->14 |
| VU movers toward golden | vu01 (module and interface) 137 -> 91, vu02 (program) 125 -> 105, vu03 (function return) 149 -> 121 | overlap 12->33, 8->17, 8->22 |
| breaks, fixed (ver = pris bytes) | vg06, vg14, vg10 | above |
| byte-identical controls on all three | vg01 (a non-parameterized class typedef), vg02 (the same specialization twice), vg05 (the generic class in the declaring package), vg09 (value-parameter specializations), vg11 (a scoped reference to the earlier package's typedef), VE/ve01 to ve04 (explicit or wildcard import plus export, a parameter type default) | the law does not fire |

- uhdm-cmp counts grow on the movers (168 -> 244 / 320 / 364 / 400 / 412). The head moved later in the walk to the next face, residue 1 below, as on the implementer's MO cases.
- Downstream: vg06, vg08, vu01 and vu03 read IDENTICAL (NO_GATES) on all three binaries (evidence/downstream.txt). Class typedefs reach no RTLIL.
- Switch check on the verified binary (evidence/switchcheck.txt, 33 dirs = 24 + the 9 MO):
  - R11U463_OFF and R11U463_FIRSTLISTER_OFF give pristine's bytes on 33 of 33.
  - R11V463_OFF gives the law's bytes on 33 of 33.
  - R11V463_UNITGRP_OFF alone restores the law's bytes on vg06 and vg14 only.
  - R11V463_TDCHAIN_OFF alone restores the law's bytes on vg10 only.

## Gates: one five-stage sweep each on law and ver

Workdirs are /tmp/v11u463law and /tmp/v11u463ver. The control is the master's /tmp/intr11u460.
- The worktree's tests/sweep.sh ran probe, surelog, uhdm2rtlil and downstream; rc 0, and the law index reads current.
- The sv-tests stage ran through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty. It exits 1 on the main tree's stale law index only.

| stage | law | ver |
|---|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64, 0/0/0 | same |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | same |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | same |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | same |
| sv-tests | EQUAL 1928, STRICT_NOTEQUAL 2, DIFFERENT 10, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, 0/0/0 | same |

- **CSV comparisons:**
  - Probe, surelog, uhdm2rtlil and downstream csvs equal the control's after path normalization, on both binaries.
  - svtests.csv is byte-identical to the control, to the implementer's and between law and ver.
- **byteverify (SELFCHECK=1):**
  - law vs control: surelog 0 / 962, uhdm2rtlil 0 / 1608, downstream 0 / 805. sv-tests 33 / 33 differ in raw bytes: under uhdm-strictcmp --no-canon, 32 read STRICT_EQUAL against the control (the serialization-order variance passes 455 to 461 recorded), and uvm_many_to_one is the law's mover.
  - ver vs law: 0 / 962, 0 / 1608, 0 / 805. In sv-tests, all 33 raw-byte movers read STRICT_EQUAL under --no-canon, uvm_many_to_one included (1085555 objects).
- **Canaries:** ok=52 and ok=16 with changed 0, and both ctcan2 checks PASS, on both binaries.
- **Binary audit** (fence-filtered path lists): surelog 1523 of 1573 records name the binary under test (the other 50 have no slang line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346, on both binaries. No record names another binary.

## The targeted row, re-measured (targeted runner calls on pris and ver)

generated/uvm-examples/uvm_many_to_one.sv stays DIFFERENT on both (`generated/uvm-examples/uvm_many_to_one.sv,DIFFERENT,decompile:,`).

- **Pristine head:** class_typespec b_pkg::A_sequencer at 88:9 under class_defn work@test; uhdm-cmp 168 lines.
- **Verified head:** module_inst work@top; uhdm-cmp 1428344 lines (the whole module_inst is printed).
- **Name tally:** b_pkg::A_sequencer golden 42 / pris 0 / ver 42, and a_pkg::A_sequencer 0 / 42 / 0.
- **Path-normalized dump distance:** 1484942 -> 1484872 (-70, the implementer's delta).

## Goal 1

Nothing on this ground changed. Every rejecting row is unchanged in both sweeps. The black-parrot size guard was not touched.

## Residues, ranked (all wrong on pristine too; none moved away on the verified binary)

1. **The cross-package group copy** (the implementer's residue 1): golden makes the earlier package's own typedef a copy of the base, with its span, alias and REQ listing. It is the next head on the movers.
2. **Golden's group base differs from ours when a `$unit` typedef joins the group** (vg06, vg14). Golden names the `$unit` typedef `b::aa_unit_seqr` and lists it from b; ours leaves it bare and unlisted. The fix abstains here.
3. **A typedef of a typedef as ours' group object** (vg10), where golden bases the group on b's direct typedef.
4. **Non-specialization and value-parameter class typedefs** (vg01, vg09) and the same specialization written twice (vg02). Golden renames them to the first lister (`b::a_ct`, `b::a_v`, `b::a_si`) but ours does not list them in b, so the law cannot fire.
5. **Re-export and parameter-type shapes** (VE/ve01 to ve04) at heads unrelated to the name.
6. The implementer's carried lists and the passes 461 and earlier lists, unchanged.

## Sister-ground faces (report only)

- The head of uvm_many_to_one after the law: module_inst work@top's typedef listing on the `$unit`-import route (ModuleEmit; the implementer's MO/mo09).
- The group listing that leaves a `$unit` typedef out of the cross-package group (residue 2). The object is ParamEmit's, but its listing reaches UhdmExporter's specialization-group passes (§ specGroupAliasFlatRoot460 site), so a writer must decide which ground owns it.

## Process

- **Builds:** two, the law and the verified binary, each at -j 2.
- **Sweeps:** two full sweeps, one per binary, each launched after a quiet reading (the sister r11u462's sv-tests stage had finished first).
- **Runner calls:** the targeted ones on uvm_many_to_one only.
- **Fence:** the fence list was read into a file by a program and never printed, and every tree-wide list was filtered on it. No fenced test was named, opened or run.
- **Other agents:** no process or file of another agent was touched.
- **Slip, affecting no measurement:** my first quiet-check script matched its own parent shell, whose command text held the pattern. It was rewritten to skip its parent, and the launcher was renamed so it cannot match.

## Files

- cases/VG (vg01 to vg17), VE (ve01 to ve04), VU (vu01 to vu03).
- drivers: runcase.sh, grid.sh, grid3.sh, switchcheck.sh, env.sh, launch_sw.sh, quiet.sh, audit.sh, mk.py and mk2.py (case generators).
- evidence/.
