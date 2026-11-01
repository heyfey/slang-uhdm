# v11u461 — adversarial verification of r11u461

Verifier of pass 461 (expression/parameter ground, ParamEmit only), base 64a77889.
VERDICT: CONFIRMED, no break, no production change. The verified patch's src diff is
byte-identical to the implementer's `/tmp/r11u461.patch`; this directory adds 35 attack
case dirs and the evidence.

Laws under test (both in src/ParamEmit.cpp, read through src/LawSwitch.h):
- § pkgImportUnionCloneHomeInst461 (`R11U461_UNIONCLONE_OFF`): a package's import clone of a
  union typedef gets its unnamed member typespecs at the home package's definition view, at any
  depth. The struct clone's stampHome walk now also enters an anonymous union member.
- § pkgNestedAnonAggMemberInst461 (`R11U461_NESTEDAGG_OFF`): in a package's own struct or union
  listing, the leaf members of an anonymous struct or union nested at any depth get that package
  as their vpiInstance, in both views.
- `R11U461_OFF` drops both. No src/R*.h, no getenv, no reader function, no header change.

## Binaries (frozen)

| role | path | md5 |
|---|---|---|
| pristine (main tree build/slang-uhdm, not rebuilt: budget) | /tmp/v11u461_bin/pristine | bfd62d46124c88c7e3e9a68c58f80d3f |
| law (built once in /tmp/wt_v11u461, -j 2) | /tmp/v11u461_bin/law | 4ab1f3deaa31cdec702d8021bd9c2d15 (= the implementer's law3) |

The law binary links slang 12.0.0+545f88b2e and UHDM 1.87.

## Implementer's grid reproduced (evidence/implementer_grid_repro.txt)

All 25 UN dirs reproduce on exit code (0 everywhere), uhdm-cmp line count, strict verdict
and moved/same: 16 STRICT_EQUAL, un07/un21/un26 STRICT_NOTEQUAL fullname, un13/un19/un20/un25
NOT_EQUAL at 120/386/386/173, 4 byte-identical controls (un02, un03, un05, un16). The md5s
differ from the implementer's file because output paths are embedded in the database; the
pristine-vs-law same/moved split is identical.

## Attack grid (cases/VC, VN, VX: 35 dirs; evidence/grid.txt, instcensus.txt, switchcheck.txt)

Every case was accepted by upstream slang (~/.local/bin/slang --single-unit, exit 0). VC/vc04
was first written with `export p::*` over an unreferenced name, which upstream slang rejects. It
was rewritten in place as `export p::u_t`. Every exit code is 0 on both binaries. "inst" is the
vpiInstance census distance from golden (evidence/tools rtinst, the implementer's tool), pristine -> law.

| case | law | shape | pristine | law | inst |
|---|---|---|---|---|---|
| VC/vc01 | § pkgImportUnionCloneHomeInst461 | anonymous enum member in a union, via ap | NOT_EQUAL 90 | NOT_EQUAL 90, same head | 8 -> 6 |
| VC/vc02 | § pkgImportUnionCloneHomeInst461 | member typed by a third package's typedef | NOT_EQUAL 101 | STRICT_EQUAL 103 | 6 -> 4 |
| VC/vc03 | § pkgImportUnionCloneHomeInst461 | members ranged by a package parameter W | NOT_EQUAL 62 | NOT_EQUAL 62, same head | 8 -> 4 |
| VC/vc04 | § pkgImportUnionCloneHomeInst461 | ap re-exports p::u_t, module variable | NOT_EQUAL 101 | STRICT_EQUAL 123 | 4 -> 0 |
| VC/vc05 | § pkgImportUnionCloneHomeInst461 | interface importer | NOT_EQUAL 101 | STRICT_EQUAL 121 | 4 -> 0 |
| VC/vc06 | § pkgImportUnionCloneHomeInst461 | module ports and assigns through the union | NOT_EQUAL 101 | STRICT_EQUAL 203 | 4 -> 0 |
| VC/vc07 | § pkgImportUnionCloneHomeInst461 | class property of u_t in ap | NOT_EQUAL 101 | STRICT_EQUAL 122 | 4 -> 0 |
| VC/vc08 | both | struct > struct > union clone | NOT_EQUAL 101 | STRICT_NOTEQUAL fullname | 8 -> 0 |
| VC/vc09 | both | struct > union holding a named enum e_t | NOT_EQUAL 177 | STRICT_EQUAL 231 | 4 -> 0 |
| VC/vc10 | § pkgImportUnionCloneHomeInst461 | 2-D packed member | NOT_EQUAL 101 | STRICT_EQUAL 111 | 4 -> 0 |
| VC/vc11 | § pkgImportUnionCloneHomeInst461 | two importing packages ap and bp | NOT_EQUAL 101 | STRICT_EQUAL 129 | 4 -> 0 |
| VC/vc12 | both | union of a named struct and an anonymous struct | NOT_EQUAL 185 | STRICT_NOTEQUAL fullname | 10 -> 0 |
| VC/vc13 | § pkgImportUnionCloneHomeInst461 | function formal of u_t in ap | NOT_EQUAL 101 | STRICT_EQUAL 125 | 4 -> 0 |
| VC/vc14 | § pkgImportUnionCloneHomeInst461 | program importer | NOT_EQUAL 133 | NOT_EQUAL 172, head later (program listing) | 4 -> 4 |
| VC/vc15 | § pkgImportUnionCloneHomeInst461 | parameter u_t P in ap read by a module | NOT_EQUAL 101 | NOT_EQUAL 46, head later | 23 -> 19 |
| VC/vc16 | § pkgImportUnionCloneHomeInst461 | unpacked and packed array typedefs of u_t in ap | NOT_EQUAL 101 | NOT_EQUAL 17, head later | 17 -> 13 |
| VC/vc17 | § pkgImportUnionCloneHomeInst461 | unpacked union with a named a_t member | NOT_EQUAL 153 | STRICT_EQUAL 167 | 6 -> 4 (tool noise on the named member) |
| VC/vc18 | § pkgImportUnionCloneHomeInst461 | packed twin of vc17 | NOT_EQUAL 155 | STRICT_EQUAL 191 | 6 -> 4 (same) |
| VN/vn01 | § pkgNestedAnonAggMemberInst461 | struct > union > anonymous enum | NOT_EQUAL 70 | NOT_EQUAL 74, same head | 10 -> 6 |
| VN/vn02 | § pkgNestedAnonAggMemberInst461 | qualified p::s_t, no import | NOT_EQUAL 101 | STRICT_EQUAL 97 | 8 -> 0 |
| VN/vn03 | § pkgNestedAnonAggMemberInst461 | four levels, struct > union > struct > union | NOT_EQUAL 101 | STRICT_NOTEQUAL fullname | 24 -> 0 |
| VN/vn04 | § pkgNestedAnonAggMemberInst461 | package function returning the union | NOT_EQUAL 293 | STRICT_EQUAL 349 | 8 -> 0 |
| VN/vn05 | § pkgNestedAnonAggMemberInst461 | package class property | NOT_EQUAL 101 | STRICT_EQUAL 122 | 8 -> 0 |
| VN/vn06 | § pkgNestedAnonAggMemberInst461 | named n_t member inside the nested union | NOT_EQUAL 155 | STRICT_NOTEQUAL fullname | 8 -> 2 |
| VN/vn07 | § pkgNestedAnonAggMemberInst461 | unpacked struct > unpacked union of int | NOT_EQUAL 99 | STRICT_NOTEQUAL endcol | 8 -> 0 |
| VN/vn08 | § pkgNestedAnonAggMemberInst461 | module input port of p::s_t | NOT_EQUAL 101 | NOT_EQUAL 30, head later (port net) | 8 -> 0 |
| VN/vn09 | control | $unit typedef | STRICT_EQUAL 73 | same bytes | 0 -> 0 |
| VN/vn10 | control | class typedef | STRICT_EQUAL 50 | same bytes | 0 -> 0 |
| VN/vn11 | control | module typedef | STRICT_EQUAL 95 | same bytes | 0 -> 0 |
| VN/vn12 | § pkgNestedAnonAggMemberInst461 | package parameter of s_t read by a module | NOT_EQUAL 171 | NOT_EQUAL 173, same head (un25's family) | 37 -> 29 |
| VN/vn13 | both | union > union and union > struct via ap | NOT_EQUAL 101 | STRICT_NOTEQUAL fullname | 20 -> 0 |
| VN/vn14 | § pkgNestedAnonAggMemberInst461 | interface variable of s_t | NOT_EQUAL 101 | NOT_EQUAL 141, head later (interface variable) | 10 -> 2 |
| VN/vn15 | both | ap function formal of s_t, module calls it | NOT_EQUAL 101 | STRICT_EQUAL 389 | 8 -> 0 |
| VX/vx01 | both | synthesizable union through the ap clone | NOT_EQUAL 101 | STRICT_NOTEQUAL fullname | 12 -> 0 |
| VX/vx02 | § pkgNestedAnonAggMemberInst461 | synthesizable always_comb over a nested struct and union | NOT_EQUAL 101 | STRICT_EQUAL 332 | 8 -> 0 |

Tally: 35 dirs, 32 moved, 3 byte-identical controls (vn09 to vn11). 19 moved to STRICT_EQUAL and
7 to STRICT_NOTEQUAL. The other 6 stay NOT_EQUAL: vc14, vc15, vc16, vn08 and vn14 with their head
later in the walk, and vc01, vc03, vn01 and vn12 at the same head. None moved away: no instance
census grew. Every census line the law changed moves toward golden.

On vc01 and vn01 the law stamps an instance that golden also has on the anonymous enum. The
head stays where it was: we write that member as logic_typespec, golden as enum_typespec.

Switches (evidence/switchcheck.txt): `R11U461_OFF=1` restores pristine bytes on 60 of 60 dirs
(the 35 attack dirs plus the implementer's 25). By switch, the moved dirs split as follows:
- 26 are restored by `R11U461_UNIONCLONE_OFF` alone.
- 19 are restored by `R11U461_NESTEDAGG_OFF` alone.
- 8 need both switches: un07, un08, vc08, vc09, vc12, vn13, vx01 and vn15. On each, either
  switch alone gives a third md5.
- 7 dirs are byte-identical controls.

Downstream (evidence/downstream.txt): vc06, vc15, vn08, vn15, vx01 and vx02 all read IDENTICAL on both binaries.

## Earlier grids byte-checked (evidence/earlier_bytecheck.txt, drivers/v11u461_bytecheck.sh)

I byte-checked 786 earlier case dirs from r11u451 to r11u459 and v11u451 to v11u459, pristine
against law. 783 are identical, with equal exit codes (3 dirs exit 3 on both and 1 exits 4 on
both). Exactly 3 moved, and they are the sister's union cases this pass targets:
- r11u458 LT/lt02: 149 -> 386 lines, inst 28 -> 24.
- r11u458 LT/lt06: 149 -> 386 lines, inst 28 -> 24.
- v11u458 VB/vb13: 309 -> 746 lines, inst 120 -> 118.

On vb13 uhdm-cmp's first difference moves from golden's top-view p to golden's definition-view
p, now paired with our ap. The census shows the only change is member `y` of the union copies
gaining the home instance. The module listing's copy now matches golden. The task-local copies
in ap's class task go from `-` to `p/ALL` where golden has its own per-copy objects, so their
distance is unchanged. The pairing moved, but no field moved away. The task-local copies are
pass 458's subroutine-copy family (sister's ground, the same residue as un19 and un20).

## Gates (one five-stage sweep on law, workdir /tmp/v11u461_sw)

The four corpus stages ran from the worktree. The sv-tests stage ran through the main tree's
tests/sweep.sh at the same base with SVTESTS_ROOT=../sv-tests and the same workdir, because the
worktree's UVM submodule is empty. Both commands exited 1 on the law index alone: my new case
files made the worktree's index stale, and the main tree's index is stale against the patch.
- probe: EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0 changes=0; csv identical to the control.
- surelog: default CMP_EQUAL 480 + 0, testflags 474 + 0, 0/0/0; the csv differs from the
  control only in the two LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes, 0/0/0; csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0; csv identical.
- sv-tests: EQUAL 1928, STRICT_NOTEQUAL 1, DIFFERENT 11, SURELOG_ONLY 75, BOTH_REJECT 303,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=0 changes=0; csv
  byte-identical to the control and to the implementer's.
- The probe, uhdm2rtlil, downstream and svtests csvs are byte-identical to the implementer's.
  The surelog csv differs from the implementer's only in the two LowMem path texts.
- byteverify (SELFCHECK=1) law against the master's control /tmp/intr11u459:
  - surelog, uhdm2rtlil and downstream: 0 movers.
  - sv-tests: 33 raw-byte movers (evidence/byteverify.txt). All 33 read STRICT_EQUAL against the
    control under `uhdm-strictcmp --no-canon` (evidence/svtests_rawmovers_strict.txt).
  - The first 19 have a path-normalized uhdm-dump equal to the control's (evidence/svtests_dump.txt).
    uhdm-dump took more than 20 minutes per database on rsd and tnoc, so I stopped it. The other 14
    (rsd, tnoc, ten uvm-examples rows and the three scoreboard rows) went instead through one traced
    runner call with `R11U461_TRACE` (evidence/trace_svtests_movers.lst and .txt), with bp_unicore
    as the positive control. Only bp_unicore fires: 2 `nested-union-walk` lines in bp_fe_pkg and 2
    § pkgNestedAnonAggMemberInst461 lines on bp_me_pkg's way_or_size. The 14 rows fire nothing, so
    the law cannot be what moved their bytes. Their runner statuses equal results/golden_svtests.csv.
  - These are the serialization-order variance passes 455 and 457 recorded, not movers.
  - The self-check flags 3406 of 3408 because pairs of identical databases exist in the control too.
- canaries: ok=52 (surelog) and ok=16 (uhdm2rtlil). ctcan2 PASS on both: ok=58 with 1 unknown, and ok=2 with 6 unknown.
- binary audit, fence-filtered: surelog 1523 of 1573 records name the law binary; the other 50
  hold only a Surelog line, and the two that mention a slang-uhdm path name only the UVM source.
  uhdm2rtlil 1742 of 1742 and sv-tests 2346 of 2346 name the law binary.
- trace: a traced law run on BlackBePipeInt (evidence/trace_BlackBePipeInt.txt) logs the one
  `nested-union-walk` on bp_be_pkg / bp_common_pkg::rv64_instr_s. That matches the implementer's
  census, and the database is byte-identical to the control's.

## Residues (all wrong on pristine too, none moved away)

1. A union clone listed under a program importer, where ours lists it under package ap (VC/vc14),
   and under a module with an explicit `import p::u_t` (the implementer's un13). This is a
   listing-parent face.
2. An anonymous enum member of a union, or of a nested union, written as logic_typespec where
   golden writes enum_typespec (VC/vc01, VN/vn01). This is the member builder, not this law.
3. A union member ranged by a package parameter: the range's ref_obj name (VC/vc03, head unchanged).
4. A package parameter of an aggregate type whose per-reference copies keep null leaves (VN/vn12,
   un25), and a union-typed parameter in ap read by a module (VC/vc15, head at the module's
   cont_assign constant typespec).
5. The array typedef of a union clone in ap (VC/vc16, head at a ref_typespec of p::u_t).
6. Port and interface variable shapes:
   - vn08: input port net of a nested-union struct.
   - vn14: interface variable listed as struct_net in ours where golden has struct_var.
   - vn06: named member n_t in the module copy, golden p/TOP against ours p/ALL.
7. Full names of nested anonymous member references: vc08, vc12, vn03, vn06, vn13, vx01, and the
   implementer's un07, un21 and un26. This is TypeEmit naming, the sister's ground. vn07 has one end column.
8. The task-local union copies in an importer copy (r11u458 LT/lt02, lt06, v11u458 VB/vb13,
   un19, un20). This is the 458 subroutine-copy family, on the sister's ground.
9. The implementer's pipelined_get_put chain (enum base typespec instance, then § 146's binding
   branch, then the dummy_response listing), all on the sister's ground. I did not re-decode it.

## Sister-ground faces (reported, not written)

- TypeEmit / UhdmExporter: full names of member references inside nested anonymous aggregates (residue 7).
- ModuleEmit: a program's listing of an imported union clone (vc14); an interface variable of a
  package struct listed as struct_net (vn14).
- TaskFuncEmit / UhdmExporter: the task-local union copies in importer copies (residue 8).

## Process

- Within the budget:
  - no pristine build: the pristine is the main tree's binary, the sweep reading is the master's control;
  - one law build, at -j 2;
  - one five-stage sweep, launched after a quiet check;
  - no verified build, since nothing changed.
- My grids, switch checks and byte checks ran at nice 19. Some overlapped the sister verifier
  v11u460's corpus sweep, which affects timing only.
- The traced runner call on 15 rows ran only after a quiet check read 0 sweep or runner processes.
- I stopped my own uhdm-dump processes on rsd and tnoc by their PIDs, once their run time made the
  dump check impractical. The traced run replaced it for those rows.
- The fence list was read into a file by a program and never printed, and the surelog cmds list
  was filtered on it before the audit. No fenced test was named, opened or run, and no other
  agent's process was touched.
- Slip: one downstream call ran without the tool environment exported and failed at startup with
  FileNotFoundError, writing nothing. It was rerun with the environment.
