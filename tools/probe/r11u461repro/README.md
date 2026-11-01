# r11u461 — package union import clones and nested anonymous aggregates (expression/parameter ground)

Pass 461 of the sv-tests campaign on the expression/parameter ground (ParamEmit only),
base 64a77889.  Two laws, both on the vpiInstance of member typespecs that Surelog mints in
the home package and this exporter left unstamped:

| law | site | switch |
|---|---|---|
| § pkgImportUnionCloneHomeInst461 | ParamEmit, the importing package's typedef clone loop (the `makeTypespec` branch after `bindImportCloneMembers`) and the struct clone's `stampHome` walk | `R11U461_UNIONCLONE_OFF` |
| § pkgNestedAnonAggMemberInst461 | ParamEmit, the package listing's struct branch (after the one-level nested-struct stamp) and union branch; helper `stampNestedAnonAgg461` | `R11U461_NESTEDAGG_OFF` |

`R11U461_OFF=1` drops both; `R11U461_TRACE=<dir>` logs each firing through `lawTrace(461, ...)`
(a firing line carries the number of objects whose vpiInstance changed; the struct clone's
nested-union entry is logged as `nested-union-walk` whether or not it changes anything).
No src/R*.h, no getenv, no reader function, no header change; only src/ParamEmit.cpp changes.

## Law statements

**§ pkgImportUnionCloneHomeInst461.**  A package that imports a package holding a union typedef
lists a clone of that union (Surelog's `importPackage` copies the home package's datatype map).
The clone's own vpiInstance is the importing package, but its fresh (unnamed) member typespecs,
and the members of an anonymous struct or union member at any depth, keep the HOME package's
definition view as vpiInstance, as they were compiled there.  The struct clone already did this
(`stampHome`, reaching struct members only); the union clone left them null, and so did the
struct clone for an anonymous union member.  A named member keeps the binding
`bindImportCloneMembers` gave it.  Witness: package p `typedef union packed {bit [7:0] x; bit
[7:0] y;} u_t;`, package ap importing p, a module importing ap: golden's module listing copy of
u_t has its bit_typespec members at p's definition view, ours had none (uhdm-cmp NOT_EQUAL 101
lines, head `package p` vs `<null>`): the sister pass 458's reported face (its LT/lt02, lt06,
here UN/un19, un20).

**§ pkgNestedAnonAggMemberInst461.**  In the package's own typedef listing, the leaf member
typespecs of an ANONYMOUS struct or union nested in a package struct or union carry that
package's vpiInstance in both views (definition view: the definition package; elaborated view:
the elaborated package, which is also the copy a module importing the package directly lists).
The existing nested rule stamped one level of struct-in-struct only; a union member of a struct,
a struct or union member of a union, and any deeper level stayed null.  Only typespecs with no
vpiInstance yet are stamped.

## Grid (tools/probe/r11u461repro/cases/UN, evidence/grid.txt; pristine = main-tree build md5 bfd62d46124c88c7e3e9a68c58f80d3f, law = law3 md5 4ab1f3deaa31cdec702d8021bd9c2d15)

Every case exits 0 on both binaries.  Goldens from the pinned Surelog (`-parse -nobuiltin -nocache -sv`).

| case | law | shape | pristine | law3 |
|---|---|---|---|---|
| un01 | UNIONCLONE | module imports p and ap (ap imports p) | NOT_EQUAL 101 | STRICT_EQUAL 109 |
| un02 | control | module imports p only | STRICT_EQUAL | same bytes |
| un03 | control | struct instead of union | STRICT_EQUAL | same bytes |
| un04 | UNIONCLONE | module imports ap only | NOT_EQUAL 101 | STRICT_EQUAL 105 |
| un05 | control | direct import, variable of u_t | STRICT_EQUAL | same bytes |
| un06 | UNIONCLONE | enum member (named, rebound) + logic member | NOT_EQUAL 161 | STRICT_EQUAL 165 |
| un07 | both | union with anonymous struct member, via ap | NOT_EQUAL 101 | STRICT_NOTEQUAL fullname (10 objects) |
| un08 | both | struct with anonymous union member, via ap | NOT_EQUAL 101 | STRICT_EQUAL 147 |
| un10 | UNIONCLONE | int / int unsigned members | NOT_EQUAL 101 | STRICT_EQUAL 57 |
| un11 | UNIONCLONE | two-hop: bp imports ap imports p | NOT_EQUAL 101 | STRICT_EQUAL 125 |
| un12 | UNIONCLONE | unpacked union | NOT_EQUAL 99 | STRICT_EQUAL 75 |
| un13 | UNIONCLONE | explicit `import p::u_t` in ap | NOT_EQUAL 101 | NOT_EQUAL 120 (next head, see residues) |
| un14 | UNIONCLONE | typedef'd vector member b_t + bit member | NOT_EQUAL 155 | STRICT_EQUAL 147 |
| un15 | UNIONCLONE | ap declares a variable of u_t | NOT_EQUAL 101 | STRICT_EQUAL 153 |
| un16 | control | struct-in-struct (already stamped) | STRICT_EQUAL | same bytes |
| un17 | NESTEDAGG | struct with anonymous union member, direct import | NOT_EQUAL 101 | STRICT_EQUAL 97 |
| un18 | NESTEDAGG | union with anonymous struct member, direct import | NOT_EQUAL 101 | STRICT_EQUAL 97 |
| un19 | UNIONCLONE | r11u458 LT/lt02 (out-of-body task local of u_t) | NOT_EQUAL 149 | NOT_EQUAL 386, head later |
| un20 | UNIONCLONE | r11u458 LT/lt06 | NOT_EQUAL 149 | NOT_EQUAL 386, head later |
| un21 | NESTEDAGG | struct > struct > union | NOT_EQUAL 101 | STRICT_NOTEQUAL fullname (2) |
| un22 | NESTEDAGG | union > union | NOT_EQUAL 101 | STRICT_EQUAL 97 |
| un23 | NESTEDAGG | unpacked union > unpacked struct | NOT_EQUAL 99 | STRICT_EQUAL 73 |
| un24 | NESTEDAGG | struct > union, module variable and assign | NOT_EQUAL 101 | STRICT_EQUAL 175 |
| un25 | NESTEDAGG | union > struct, package parameter of u_t read in a module | NOT_EQUAL 171 | NOT_EQUAL 173 (closer, see below) |
| un26 | NESTEDAGG | struct > struct > struct | NOT_EQUAL 101 | STRICT_NOTEQUAL fullname (2) |

Tally: 25 case dirs, 21 moved (16 to STRICT_EQUAL, 3 NOT_EQUAL -> STRICT_NOTEQUAL on a
fullname, 2 + 1 NOT_EQUAL at a later head or closer), 4 byte-identical controls (un02, un03,
un05, un16).  None moves away: the vpiInstance census (evidence/tools/rtinst.cpp, multiset of
ref_typespec owner path -> actual kind + vpiInstance, golden vs ours, `>ref_typespec()` hops
removed) reads un19 28 -> 24, un20 28 -> 24, un25 30 -> 22 lines from golden; un13 4 -> 4
(its next face is a listing parent, below).  un19/un20: the pristine head (golden p's definition
view against `<null>`) is in the AllPackages walk; the law's head is golden's elaborated `p`
against ours `ap` at the out-of-body task's local union copy (TopPackages, later in the walk).

Switch checks (evidence/switchcheck.txt, switchcheck_summary.txt): `R11U461_OFF=1` gives the
pristine md5 on 25 of 25; every moved dir is restored by exactly its own law's switch
(UNIONCLONE: un01, un04, un06, un10-un15, un19, un20; NESTEDAGG: un17, un18, un21-un26), un07
and un08 need both (each switch alone gives a third md5).

Downstream (`ds.one` on un04, un07, un17): IDENTICAL on both binaries (NO_GATES).

## The targeted sv-tests row: uvm_use_models_pipelined_get_put (decoded, sister ground)

The brief's item (a) named its head as this ground's.  Decoded at the base (evidence/decode/
README_decode.txt, tools evidence/tools/*.cpp, simulations on database copies only):

- uhdm-cmp pairs golden's mbus_types_pkg DEFINITION-view param_assign (Rhs `$bits(...)`) with
  our ELABORATED-view one (Rhs UINT:100).  UHDM's Compare visits each golden object once, so the
  pair is made where golden reaches the DEF package through a pointer that reaches the TOP
  package in ours.  The only pointers to golden's DEF mbus_types_pkg are vpiInstance links
  (whopoints.cpp).  Bisecting over every TOP-instanced typespec of ours (blanket2.cpp): the
  culprit is the unparented `logic [2:0]` BASE typespec of the enum `mbus_resp_e` copies — module
  top_tb's transitive copy (top_tb imports env_pkg imports agent_pkg imports types_pkg) and
  interface MBUS's enum_var copy SHARE one base object in ours, instanced at the elaborated
  package; golden's transitive copy's base is at the definition package (cases
  evidence/decode/EB/eb06-eb08 reproduce it: STRICT_EQUAL on both binaries since the
  comparator reaches the definition package first there).  The enum base typespec is built in
  TypeEmit (`Base_typespec` setters) and UhdmExporter: the sister's ground.
- With that base re-pointed (simulation), the head becomes golden's design-level parameter
  `MBUS_SEQ_ITEM_NUM_BITS` (hoisted by the `$unit` import in mbus_pipelined_driver_bfm.sv)
  against our `$bits` call: UhdmExporter's § unitImportHoistsPkgParams146 binding branch, which
  accepts only constant, operation and pooled ref_obj actuals (pass 459's residue 2).
- With both re-pointed, the head becomes `mbus_pipelined_check_seq::dummy_response`'s variable
  listing (a class_var `req` under the task's begin), on the sister's ground too.
- The importing packages' param_assign typespec vpiInstance (golden: the home DEFINITION view,
  ours: the elaborated view; pass 457's ts02/xp05/vo07 decode, simdef.cpp) differs as well but is
  not this row's head: re-pointing it alone leaves the head unchanged, the DEF package being
  visited first through AllPackages.  Not written (it would move bytes on every package re-export
  row and no row's head needs it).

So no open sv-tests row has its first difference on this ground at the base; this pass
therefore wrote the largest concrete backlog face the brief lists on this ground (item (b), the
sister pass 458's union face).

## sv-tests rows (before -> after)

No sv-tests row moves: the law sweep's svtests.csv is byte-identical to the master's control
(/tmp/intr11u459/svtests.csv) and reads EQUAL 1928, STRICT_NOTEQUAL 1, DIFFERENT 11,
SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346 with
regressions=0 conversions=0 changes=0.  The 12 open both-accepted rows keep their heads; none is
on this ground (above for pipelined_get_put; at the base easyUVM, the 3 scoreboard rows, p737
head at the design or class listing, p733 and tnoc at their awaiting-decision constants,
id_register, many_to_one and param_vif_config_db at class_typespec listings,
uvm_ac_config_db STRICT_NOTEQUAL differ:fullname(1823): all the sister's ground or Surelog
artefacts).  Goal 1: no change on this ground (every SURELOG_ONLY / BOTH_REJECT detail stays an
upstream slang diagnostic or the black-parrot size guard; bp rows exit 3 under the guard as
before, the two laws firing in them without moving any status).

## Gates (law3, one full five-stage sweep `tests/sweep.sh --jobs 3 --workdir /tmp/r11u461_sw`)

- probe: EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, regressions=0 conversions=0 changes=0; csv
  identical to the control; all 4087 databases identical to the control by path-normalized
  uhdm-dump (evidence/probedump.txt, drivers/probedump.sh).
- surelog: default CMP_EQUAL 480 + 0, testflags 474 + 0, regressions=0 conversions=0 changes=0;
  the csv differs from the control only in the two LowMem log-path texts; Tnoc d/t CMP_NOTEQUAL
  standing.
- uhdm2rtlil: 803 / 1 / 67 in both modes, 0 / 0 / 0; csv identical to the control
  (stamped_gen_param d/t CMP_NOTEQUAL standing).
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871; csv identical.
- sv-tests: above (0 / 0 / 0, csv identical).  The worktree's UVM submodule is empty, so the
  five-stage command skipped this stage (no sv-tests checkout next to the worktree); it was run
  alone through the main tree's tests/sweep.sh (main tree at the same base 64a77889, its baseline
  byte-identical to the worktree's) with SLANG_UHDM=law3 and the same workdir, exiting 1 on the
  main tree's law index alone.
- byteverify (SELFCHECK=1) law3 vs the master's control: surelog 0 of 962 (selfcheck 961 of
  962), uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804).  NO MOVER, as predicted.
- canaries: ok=52 (surelog) and ok=16 (uhdm2rtlil), ctcan2 PASS on both (ok=58, unknown 1;
  ok=2, unknown 6).
- binary audit (fence-filtered cmds.txt): surelog 1523 of 1573 records name law3 (the other 50
  hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346; no other binary.
- the sweep's trace (evidence/trace_sweep.txt) equals the census trace: BlackBePipeInt d/t one
  no-change walk each, the 6 black-parrot rows 4 lines each; nothing else.

## Prediction and census (written before the sweep: evidence/prediction.txt, evidence/census/)

A fence-filtered list of 22082 corpus, probe and sv-tests files; 119 name `union`, 153 hold a
typedef struct/union with a nested struct/union (evidence/census/nestscan.py, svcand.py); mapped
to 24 probe cases, 84 surelog row-modes, 40 uhdm2rtlil row-modes and 30 sv-tests rows; law3 run
traced over all of them (verify_golden --filter, svtests_matrix --paths-file, the probe cases
directly; positive control UN/un04 fires).  Firings (evidence/census/trace_law3.txt): BlackBePipeInt
default and testflags, one `nested-union-walk` each changing no instance (law1's database
byte-identical to the control's); the 6 generated/black-parrot sv-tests rows (§
pkgNestedAnonAggMemberInst461 sets 1 instance in bp_me_pkg's bp_cce_inst_pushq_s.way_or_size, the
union clone walk changing nothing), rows that are SURELOG_CRASH with the slang side exiting 3 under
the size guard; nothing else.  Every candidate row's status equal to the committed baseline.
Prediction: no byte mover in probe, surelog, uhdm2rtlil or downstream; no sv-tests status change.

## Residues (all wrong on pristine too, none moved away)

1. uvm_use_models_pipelined_get_put: the chain above, both faces on the sister's ground.
2. un07, un21, un26: the full name of a nested anonymous aggregate's member reference
   (golden `p::u_t.s.a` / `p::s_t.v.w.a`, ours `s.a` / `p::p::s_t::v::w.a`), the member
   typespec naming in TypeEmit's struct and union builders (sister's ground).
3. un13: with `import p::u_t;` golden parents the union clone at the importing MODULE's listing,
   ours at package ap; un15's ap variable of u_t binds golden's clone (instance ap) where ours
   binds the home object (both judges blind there).
4. un19/un20: an out-of-body task local of the union in an importer copy: golden's local union
   copy instanced at the elaborated home package, ours at ap (the 458 subroutine-copy family;
   TaskFuncEmit/UhdmExporter, sister's ground).
5. un25: the per-reference union copies under a package parameter's typespec in the module
   listing (golden `ref_typespec > union_typespec > ... ` copies with the elaborated home
   instance on every leaf) keep null leaves in ours; the copy is made outside the package listing.
6. The carried lists of passes 459 and earlier (the brief's items (a) to ({)), unchanged.

## Sister-ground faces (reported, not written)

- TypeEmit / UhdmExporter: the transitive module copy of a package enum shares its unparented
  base typespec with a direct importer's copy, instanced at the elaborated package; golden's
  transitive copy's base is at the definition package (pipelined_get_put's first face; the
  `Base_typespec` setters in TypeEmit and UhdmExporter).
- UhdmExporter § unitImportHoistsPkgParams146's binding branch skipping a `sys_func_call` actual
  (pipelined_get_put's second face; pass 459's residue 2).
- The class task variable listing at mbus_pipelined_check_seq::dummy_response (third face).
- TypeEmit's nested member reference full names (residue 2).

## Process

- Within the budget: no pristine build of my own beyond the worktree's first build (md5
  bfd62d46124c88c7e3e9a68c58f80d3f, equal to the main tree's build/slang-uhdm, frozen at
  /tmp/r11u461_bin/pristine); law1 to law3 on case runs (law2 = law1 plus change-counting
  traces, byte-identical on the grid; law3 widens § pkgNestedAnonAggMemberInst461 from union
  members to any anonymous aggregate); two traced census runs on candidate rows only
  (verify_golden --filter, svtests_matrix --paths-file, probe cases directly), each after the
  machine read quiet; ONE full five-stage sweep on law3 (the final binary); the sv-tests stage
  rerun alone because the first command skipped it (no sv-tests checkout next to the worktree),
  not a second sweep; one byteverify against the master's control.
- The pipelined_get_put decode ran only on copies of databases (tools in evidence/tools); no
  sister file was edited or built.
- The fence list was read into a file by a program and never printed; every tree-wide list was
  filtered on it before any file was opened; no fenced test named, opened or run; no other
  agent's process touched (waits by a script file reading ps, never matching its own name).
- Slips: the first quiet-waiter's sweep launch waited about 25 minutes behind the sister's sweep
  (by design); none affecting a measurement.
