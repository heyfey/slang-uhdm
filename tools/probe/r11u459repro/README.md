# r11u459 — pass 459, expression/parameter ground (implementer)

Base 2f99dba8 (pass 456 on top of pass 457). Ground: src/ParamEmit.cpp,
src/StmtEmit.cpp, src/ExprEmit.cpp and src/EmitHelpers.h. Three laws, each
behind its own switch read through src/LawSwitch.h (`lawOn(459, ...)`);
`R11U459_OFF` drops all three; `R11U459_TRACE=<dir>` logs each firing through
`lawTrace(459, ...)`. No src/R*.h, no getenv, no reader function, no header
change (StmtEmit.cpp gains one `#include "slang/syntax/SyntaxTree.h"`).

Binaries: pristine = the main tree's build/slang-uhdm at the base (md5
d0dfe22c35b7dc0c5d3ab323a4e7a34d; the worktree's own first build is
byte-identical), frozen at /tmp/r11u459_bin/pristine. Final law binary law7
(md5 efb75a40b10e27254abfe1eabf4e72e6, links slang 12.0.0+545f88b2e). law6
(md5 7ae64b3a79ea5489a4e1b37927b2e4ae) is the binary of the one full sweep;
law7 adds one call site to § pkgBitsTypeEnumZero459 (the importer package's
typedef re-listing, the case BE/be10) and was measured on the stage it can
move (sv-tests, rerun alone) plus a traced census of every corpus row the
widened scan names (below). law1 to law5 were case-run binaries only.

## The laws

### § defFlipUnszBasedRaw459 (ParamEmit, `R11U459_DEFFLIPRAW_OFF`)

A module's DEFINITION listing reached through § modDefImportShape's flip
(an imported typed parameter in a module or interface WITH a parameter port
list takes the elaborated shape in the def listing) keeps an unsized based
literal default as written: § unsizedBasedTypedParamElab's respell
(`'b0101` -> `28'b0101` at the declared width) is the elaborator's and
applies to the instance listing only. The law keys on `defViewOrig9` (the
physical view) beside the flipped `topView`.

Head of sv-tests uvm_ac_config_db at the base: `sfr_master_bfm #(ADDR_WIDTH,
DATA_WIDTH)` imports uvm_pkg; golden's AllModules copy of `parameter
uvm_field_flag_t UVM_DEFAULT = 'b000010101010101` reads `'b000010101010101`
where ours read `28'b000010101010101` (the sister pass 456's reported face).
Decoded on the UD grid: the face needs a parameter port list (ud03/ud04
without one are STRICT_EQUAL on pristine), overridden or not (ud05), typedef
or plain vector (ud06), interface too (ud10), explicit imports (ud18), the
ANSI header import `module m import p::*; #(...)` (ud17).

### § unitImpTransLateList459 (StmtEmit, `R11U459_UNITTRANS_OFF`)

§ classPropUnitImport21's `pkgImportedByUnit21` asked only whether a
compilation-unit import names the class's home package DIRECTLY. Surelog's
importPackage copies the imported package's whole late-binding list, and a
package whose BODY imports another already holds that package's list, so a
`$unit` import of a package that imports the home package (directly or
through a chain) hands the FileContent pass the home package's class-property
foreach names too, and golden writes the int_var fallback. Pass 454's two
breaks are kept: only import declarations written in the package body count
(§ pkgLateTsBodyImportsOnly454v) and only an edge to a package declared
EARLIER in the syntax trees' member order (§ pkgLateTsEarlierPkgOnly454v).

Head of sv-tests uvm_use_models_pipelined_get_put at the base:
uvm_default_factory::set_type_override_by_type's foreach loop variable
`index` int_var in golden, array_var in ours; mbus_pipelined_driver_bfm.sv
writes `import mbus_pipelined_agent_pkg::*;` at file scope and that package
imports uvm_pkg.

### § pkgBitsTypeEnumZero459 (EmitHelpers.h helpers, ExprEmit + ParamEmit sites, `R11U459_ZEROENUMBITS_OFF`)

Surelog's `ExprEval::size` gives a base-less enum (`typedef enum { A, B }
e`) zero bits (§ enumNoBaseTypespecZeroBits28), and a PARAMETER initialized
by `$bits(<type>)` over such a type keeps that value; every reader that folds
through the parameter computes from it. The helpers in EmitHelpers.h
(`srlgZeroEnumBits459`, `srlgZeroEnumReaches459`, `srlgZeroEnumEval459`)
re-evaluate an integral constant expression under that rule (literals,
implicit and explicit conversions, + - * / %, unary +/-, non-overridden
parameter reads, `$bits` of a type or a plain name; anything else on a
reaching path abstains). The substitution happens only when the walk meets
such an enum, at four sites: tryFoldConst (ExprEmit), the parameter's own
value inside emitParameters (`psValue459`, ParamEmit; the defparam test at
§ hierdefparam keeps slang's own value since it compares slang against
slang), the elaborated encoding re-render after `srlgAdjustSize`
(ParamEmit), and the folded packed bound of a typedef listing in the
package's elaborated listing and in an importer package's re-listing
(`zeroEnumBoundFix459`, ParamEmit).

Head of sv-tests uvm_use_models_pipelined_get_put once the loop-variable
face is cleared: mbus_types_pkg's `parameter int MBUS_SEQ_ITEM_NUM_BITS =
$bits(mbus_seq_item_s)` (the struct holds the base-less `mbus_opcode_e`)
UINT:100 in golden, 132 in ours; `MBUS_SEQ_ITEM_NUM_BYTES = (N+7)/8` 13 and
17; `typedef bit [N-1:0] mbus_seq_item_vector_t` bound 99 and 131.

## sv-tests rows (before -> after)

| row | base (control) | law sweep |
|---|---|---|
| generated/uvm-examples/uvm_ac_config_db.sv | DIFFERENT (uhdm-cmp 64 lines, head UVM_DEFAULT decompile) | **STRICT_NOTEQUAL differ:fullname(1863)**, uhdm-cmp EQUAL — CONVERSION |
| generated/uvm-examples/uvm_use_models_pipelined_get_put.sv | DIFFERENT (head foreach loop-variable kind, 56 lines) | DIFFERENT (56 lines; head moved later, see residues) |
| generated/uvm-examples/uvm_param_vif_config_db.sv | DIFFERENT | DIFFERENT, bytes move (§ defFlipUnszBasedRaw459 fires in sfr_master_bfm and sfr_monitor_bfm), head unchanged at class_typespec this_t (the sister's) |

The converted row's fresh csv line (law sweep, /tmp/sw_r11u459/svtests.csv):

    generated/uvm-examples/uvm_ac_config_db.sv,STRICT_NOTEQUAL,differ:fullname(1863),differ:fullname(1863)

Its 1863 fullname objects are typedef ref_typespecs named under the class
inside the module in golden (`work@sfr_monitor_bfm::sfr_monitor_concrete::
uvm_pkg::uvm_event_pool`) and under the module in ours
(`work@sfr_monitor_bfm.uvm_pkg::uvm_event_pool`): § typedefParentLastWriter134
(UhdmExporter), the sister's ground, the same family as uvm_ef_vif_config_db's
427.

## Sweep (law6, one full five-stage run, `R11U459_TRACE` on)

tests/sweep.sh --jobs 3 --workdir /tmp/sw_r11u459 from the worktree for
probe, surelog, uhdm2rtlil and downstream; the sv-tests stage through the
main tree's tests/sweep.sh on the same workdir and binary (the worktree's UVM
submodule is empty); both commands exit 1 on the law-index check alone.

- probe: EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0 changes=0;
  all 4087 databases identical to the control's by path-normalized dump
  (drivers/probedump.sh; raw bytes embed the workdir).
- surelog: default CMP_EQUAL 480, testflags 474, regressions=0 conversions=0 changes=0.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not identical and
  not excused 0; the csv identical to results/downstream_uhdm2rtlil.csv.
- svtests: EQUAL 1927, STRICT_NOTEQUAL 2, DIFFERENT 11, SURELOG_ONLY 75,
  BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions=0 conversions=1 (uvm_ac_config_db, above) changes=0; the csv
  differs from results/golden_svtests.csv in that one line only.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) against
  the master's control /tmp/intr11u456: surelog 0 of 962, uhdm2rtlil 0 of
  1608, downstream 0 of 805 (self-checks 961/962, 1607/1608, 804/805).
- canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); ctcan2
  EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 PASS.
- binary audit (fence-filtered): surelog 1523 of 1573 cmds.txt name law6
  (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests
  2346 of 2346.
- trace (evidence/trace_law6): firings on exactly the three predicted sv-tests
  rows (ac_config_db and param_vif_config_db § defFlipUnszBasedRaw459;
  pipelined_get_put § unitImpTransLateList459 once and
  § pkgBitsTypeEnumZero459 76 times) AND on the six generated/black-parrot
  rows (§ pkgBitsTypeEnumZero459, `icache_pkt_width_lp` 72 -> 40 in
  bp_fe_controller and bp_fe_icache), which the text census missed (the
  declaration is macro-built); those rows are SURELOG_CRASH, no golden
  exists, the status column cannot move, and none moved; nothing fired in
  the probe, surelog, uhdm2rtlil or downstream stages.

## law7: the widened site, measured where it can move

law7 adds `zeroEnumBoundFix459`'s second call site (an importer package's
re-listing of a typedef whose bound reads such a parameter; BE/be10 36 lines
-> STRICT_EQUAL, and be11, be23, be24 bytes moving at the same head). It was
measured where it can move, after three quiet readings:

- a widened text census (drivers/census_scan_wideC.py: law C on ANY `$bits(`
  beside a base-less enum) named 66 surelog rows, 2 uhdm2rtlil rows, 2 probe
  cases and 320 sv-tests rows; law7 with the trace on over the corpus ones
  (verify_golden.py --filter both modes, check_probe.py --filter): 0
  firings; regressions=0 conversions=0 changes=0 against the golden csvs; the
  27 surelog and 2 uhdm2rtlil databases byte-identical to the law6 sweep's,
  the 2 probe databases identical by path-normalized dump;
- the sv-tests stage alone (main tree tests/sweep.sh --corpus svtests,
  workdir /tmp/sv_r11u459): EQUAL 1927, STRICT_NOTEQUAL 2, DIFFERENT 11,
  regressions=0 conversions=1 (uvm_ac_config_db) changes=0, the csv
  byte-identical to the law6 sweep's; the trace the same rows as law6's plus
  the one new firing `bound mbus_seq_item_vector_t INT:131 -> 99` in
  pipelined_get_put (whose head stays as in residue 1; evidence/
  sweep_law7_svtests.csv, trace_law7/). Raw sv-tests database bytes differ
  between any two runs with the same csv (the serialization-order variance
  passes 455 and 457 recorded), so no byte census is claimed there.

## Prediction (evidence/prediction.txt, written before the sweep)

The text census (drivers/census_scan.py, every path list fence-filtered
before a file is opened) named 66 surelog rows, 0 uhdm2rtlil rows, 1 probe
case and 679 sv-tests rows as candidates; traced law6 runs on them read 0
firings on the surelog rows (both modes, 0/0/0 against the golden csv), the
probe case byte-identical to pristine, and firings on exactly 3 sv-tests rows
(the 680-row run also covering the 13 open rows). Predicted: no mover in the
four corpus stages, the 3 sv-tests rows moving bytes, one conversion
(ac_config_db to STRICT_NOTEQUAL fullname(1863)). It held, except the six
black-parrot firings named above (no status, no golden).

## Grid (58 case dirs, evidence/grid_law7.txt; pristine -> law7, every exit code 0 on both)

Goldens: Surelog `-parse -nobuiltin -nocache -sv`, ours `--single-unit
--nobuiltin` (drivers/run1.sh). Every case's first line names its law.

UD — § defFlipUnszBasedRaw459:
- to STRICT_EQUAL from uhdm-cmp 64 lines: ud01, ud02, ud05, ud06, ud09,
  ud10 (interface), ud11 (three instances), ud12 ($unit import), ud15 (hex
  and octal), ud17 (header import), ud18 (explicit imports).
- ud19 (program) 64 -> STRICT_NOTEQUAL depth (uhdm-cmp 0).
- closer, head moved later to the elaborated view: ud07 64 -> 17 (a
  continuous assignment reading the parameter), ud08 64 -> 64 (the
  single-digit `'b1` at a 16-bit typedef, golden `16'b1` in the instance copy
  where § unsizedBasedTypedParamElab writes `1'b1`), ud16 64 -> 66 (a port
  parameter typed by the package typedef).
- byte-identical controls: ud03, ud04 (no parameter port list), ud13 (sized
  literals), ud14 (the module's own parameter).

FT — § unitImpTransLateList459:
- ft06 (`import pk::Cel` explicitly in the importer) 56 -> STRICT_EQUAL;
  ft14 (x.sv pk.sv dut.sv: x declared after pk) 56 -> STRICT_NOTEQUAL type.
- head moved later, 12 -> 18 lines: ft01, ft04 (two-level chain), ft08,
  ft10 (`import x::g` explicit); the loop variables now golden's int_var, the
  next head the clone `x::C::run`'s actual ref_var typespec (golden
  int_typespec, ours unsupported_typespec), the same face the direct-import
  shape ft02/ft15 carries on both binaries.
- byte-identical controls: ft02, ft15 (direct $unit import, pristine path),
  ft03 (module-scope import), ft05 (import inside a package function),
  ft07 (no import), ft11 ($unit import of an unrelated package), ft12, ft13
  (x.sv first: x imports pk declared later, the earlier-only rule).

BE — § pkgBitsTypeEnumZero459:
- to STRICT_EQUAL: be01, be03 ($bits of the enum itself), be05 ($unit types,
  module parameter and localparam), be06 (untyped parameter), be09 (with
  (N+7)/8 and the typedef bound), be10 (importer package; law7's site),
  be12 (module importer), be13 (interface importer), be17 (module port
  parameters, an overridden instance abstaining).
- bytes move, head unchanged or later, still NOT_EQUAL: be02 (64 -> 76, the
  module-variable typedef face be07 also carries on both binaries), be11,
  be14, be20, be21, be23, be24, be25 (56: the § 146 design-parameter binding
  face, below), be18 (31: `-$bits(s)` written as an operation by both), be19
  (64: a conditional over $bits, the evaluator abstains).
- byte-identical controls: be04 (sized enum base), be07, be08, be15, be16,
  be22 (sized enum base).

Switches (evidence/switchcheck_law7.txt, switchtable_law7.txt): `R11U459_OFF`
gives pristine's bytes and exit code on 58 of 58; every moved case is
restored by exactly one law's own switch (UD by `R11U459_DEFFLIPRAW_OFF`, FT
by `R11U459_UNITTRANS_OFF`, BE by `R11U459_ZEROENUMBITS_OFF`).

Earlier grids (evidence/earlier_grids_bytecheck_law6.txt, drivers/bytecheck.sh):
1535 case dirs of r11u409, r11u411, r11u445 to r11u457 and their v11u twins,
pristine against law6: 0 moved, every exit code equal (1517 exit 0, 15 exit
4, 3 exit 3 on both).

## Goal 1 on this ground

No rejecting row of results/golden_svtests.csv carries an exporter error on
this ground at the base: the five rows whose detail names a slang-uhdm path
carry upstream slang's uvm_pkg time-scale diagnostic, and the SURELOG_ONLY
details are upstream slang diagnostics (unchanged since pass 457's census;
the law sweep moved no rejecting row). The goal-1 probe faces C::mk().arr[1],
u.mk(x).a[2] and this.mk().inner.s stay as pass 457 left them (not reached).
black-parrot: not measured again (the guard stays; this pass's law fires in
those rows' bp_fe_controller and bp_fe_icache without changing any status).

## Residues (all wrong on pristine too, none moved away)

1. uvm_use_models_pipelined_get_put: after the two laws the values agree with
   golden (UINT:100, 13, bound 99) and the loop variables are golden's
   int_var; uhdm-cmp still reads 56 lines with the head pairing golden's
   definition-listing `param_assign` Rhs `$bits(mbus_seq_item_s)` (39:41)
   against an elaborated UINT:100 constant of ours. Not decoded. Its mini
   repro BE/be14 (a `$unit` import of the package) is the § 146 face below
   and closes with it; the row does not (an experiment binary with that
   change read the same head).
2. A `$unit`-imported package's definition listing binds a reference to a
   parameter whose initializer is a system call (`M = (N+7)/8` with N =
   $bits(...)) to that call in ours, to the design-level hoisted parameter
   in golden (BE/be11, be14, be20, be21, be23 to be25; pristine 56 lines,
   law 56): UhdmExporter's § unitImportHoistsPkgParams146 binding branch
   accepts only constant, operation and pooled ref_obj actuals. An
   experiment binary (not in the patch, the edit reverted, the rebuild
   byte-identical to law6) accepting a sys_func_call actual there read
   be14, be20, be21, be22, be25 STRICT_EQUAL. Sister ground.
3. ud08: the instance copy of an imported 16-bit typedef parameter `'b1`
   golden `16'b1`, ours `1'b1` (the single-digit branch of
   § unsizedBasedTypedParamElab measured on module parameters, not imports).
4. ud07, ud16, ud19 at later heads (a continuous assignment reading the
   copy, a port parameter typed by the package typedef, the program listing).
5. be02/be07: a module variable typed by an imported package typedef whose
   bound reads a package parameter: golden folds the alias copy's bound
   (INT:9), ours keeps the operation; TypeEmit makeTypespec, sister ground.
6. be18 (`-$bits(s)`), be19 (`$bits(s) > 8 ? 1 : 2`): shapes the evaluator
   abstains on.
7. FT ft01/ft04/ft08/ft10 and the direct shape ft02/ft15: the clone's actual
   ref_var typespec (golden the int fallback's int_typespec) — StmtEmit's
   clone listing, not decoded; ft02/ft15 also carry a class_defn listing
   head (1652 lines) on both binaries.
8. The carried lists of passes 457 and earlier (the brief's items (b) to
   ({)), not reached by this pass.

## Sister-ground faces (reported, not written)

- UhdmExporter § unitImportHoistsPkgParams146's binding branch (the
  `at146 != uhdmconstant && != uhdmoperation` test): a sys_func_call actual
  is excluded where golden binds the design parameter (residue 2).
- UhdmExporter § typedefParentLastWriter134: uvm_ac_config_db's 1863 strict
  fullname objects (typedef ref_typespecs under a class declared inside a
  module, golden `work@sfr_monitor_bfm::sfr_monitor_concrete::uvm_pkg::...`).
- TypeEmit makeTypespec: the alias copy's folded bound for a module variable
  typed by an imported typedef (be07, residue 5).
- The open rows' heads on law6 (evidence/heads_law6.txt): easyUVM and the
  three testbenches/uvm_scoreboard rows at the class listing; id_register,
  many_to_one and param_vif_config_db at class_typespec; p733, p737 and tnoc
  as before.

## Process

- Within the budget: law1 to law5 on case runs; targeted runner calls on the
  two target rows (pristine and law1, law6, law7) and one traced 680-row
  sv-tests census run plus one traced 66-row surelog census run on law6; one
  full five-stage sweep on law6; the sv-tests stage alone plus a traced
  census of the widened candidates on law7; one byteverify against the
  master's control; no pristine build or pristine sweep.
- Slips, none affecting a measurement: one dump command ran with the tool
  variable unset, so the shell executed a golden database as a script,
  writing nothing (both trees checked clean; every later command sources the
  guarded environment file); the law6 one-row runner call and the 66-row
  surelog census overlapped the sister r11u458's sweep (timing only); three
  background waiters matched their own command line and one quiet check
  matched the command that launched it, all stopped by their recorded PID;
  an experiment build edited UhdmExporter.cpp in this worktree for residue
  2's measurement and the file was restored (the following rebuild is
  byte-identical to law6), the file is not in the patch.
- The fence list was read into a file by a program without printing it;
  every tree-wide list was filtered on it before a file was opened; no
  fenced test was named, opened or run; no other agent's process touched.

Drivers: drivers/run1.sh, grid.sh, dump.sh, head1.sh, goldpath.sh (from
r11u457repro), switchcheck.sh, bytecheck.sh, probedump.sh, census_scan.py,
census_scan_wideC.py.
