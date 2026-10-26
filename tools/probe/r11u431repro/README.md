# r11u431 — the expression/parameter ground, sixteenth pass of the sv-tests campaign

Base bc18c5011 (pass 429). Ground: src/ExprEmit.cpp, src/EmitHelpers.h,
src/StmtEmit.cpp, src/ParamEmit.cpp (this pass touches src/ExprEmit.cpp and
src/ParamEmit.cpp only). Pristine = the main tree's build/slang-uhdm at the
base, md5 a68b561e10c30ef8b8f1e9ad8bc58506, frozen as
/tmp/r11u431_pris/slang-uhdm for case runs and targeted runner calls (the
worktree's own build at the base read the same md5); the pristine sweep
reading is the master's control at the base, /tmp/intr11u429. FINAL law
binary md5 303e6d85e43c76afb6e6c3787f5259cb (/tmp/r11u431_law9/slang-uhdm, the
worktree's build/slang-uhdm at the patch).

## sv-tests rows (before -> after, the one sweep)

- `generated/hdlconv_std2017/hdlconvertor_std2017_p130.sv` DIFFERENT -> **EQUAL**
  (fresh row `generated/hdlconv_std2017/hdlconvertor_std2017_p130.sv,EQUAL,,equal`),
  § bodyTypeParamDefKeepsDecl431.
- `generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_dpi_rom.sv` DIFFERENT -> **EQUAL**
  (fresh row `generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_dpi_rom.sv,EQUAL,,equal`),
  § modParamArrElemDefRangeSym431.
- `generated/fx68k/fx68k.sv` stays DIFFERENT, toward golden: its head moves
  from the design-level `CF` parameter (golden binds fx68kAlu's references to
  the compilation-unit `CF`) past four faces of this ground to TypeEmit's
  size-form dimension (sister ground, below); uhdm-cmp 31 -> 36 lines because
  the head moved later, sorted path-normalized dump distance 818 -> 709.
- `generated/rsd/rsd.sv` stays SURELOG_CRASH (no golden); § connOperandNonOvParamFold431
  fires 40 times there.

The sweep's sv-tests stage: EQUAL 1894, STRICT_NOTEQUAL 6, DIFFERENT 40,
SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of
2346; regressions 0, conversions 2 (the two rows above), changes 0; every
other row identical to the control (evidence/svtests_law9_vs_control.diff).

## Laws

All read through src/LawSwitch.h (`lawOn(431, ...)`); `R11U431_OFF` drops all
six, `R11U431_TRACE=<dir>` logs each firing (`lawTrace(431, ...)`). No
src/R*.h, no getenv, no LawState.h section, no header change.

1. § unitParamNameBindsDesign431 (`R11U431_UNITNAMEBIND_OFF`; ExprEmit, the
   NamedValue binding tail). In a module DEFINITION listing (and a definition
   ref_module connection), a read of a name declared directly in the
   definition body (a parameter, net or variable, ports included) that is
   also the name of a compilation-unit parameter binds the design-level
   parameter; in the ELABORATED copy of a continuous assignment the same
   holds for a parameter read as a bit-select index. Decoded from Surelog
   `UhdmWriter::lateBinding` (src/DesignCompile/UhdmWriter.cpp): the parent
   walk reaches the `design` object and matches `d->Parameters()` BY NAME
   before the module's `Nets()` are searched; only a begin, function or task
   that declares the name binds first. A definition-view read of a module's
   own parameter is otherwise left unbound by golden (UB/ub06), which ours
   already did. The fx68k face: fx68kAlu.sv 63 `localparam CF = 0, ...`
   shadows fx68k.sv 22's `$unit` `localparam CF = 0, ...`, and golden binds
   every fx68kAlu `ccrCore[ CF]` to the design's `CF` (49 firings on fx68k).
2. § bodyTypeParamDefKeepsDecl431 (`R11U431_BODYTPDEF_OFF`; ParamEmit, the
   type-parameter definition typespec). A type parameter declared in the module
   BODY is listed in the definition with its declaration default, as a header
   type parameter already is: the borrowed definition body is an instance's,
   and when that instance overrides the parameter its bound type is the
   override, which ours wrote. p130: `sub #(.t_3(t_6)) s1 ()` over
   `parameter type t_3 = int;` — golden `int_typespec 7:22`, ours a
   `logic_typespec` at the override's 14:12. The cloned body symbol has lost
   its declarator syntax, so the default is read from the module's own member
   syntax; the law fires only when the bound type is not that default.
3. § connBitSelIdxNonOvParamFold431 (`R11U431_CONNIDXNONOV_OFF`; ExprEmit, the
   ELABORATED port High_conn's bit-select index, beside
   § connBitSelIdxModParamFold81). The not-overridden half of pass 81's law: a
   module-scope parameter or localparam the instantiation does not override
   folds to the instance's stored Value, the parameter's own elaborated
   param_assign constant (value, size, decompile, const type), parented at
   the bit_select and located at the read, with a bare signed `int_typespec`
   exactly when the declared type is a signed int / bit / logic one (the
   valueRange split § connHpIpsBaseNonOvParamFold84 transcribes). Measured on
   untyped, int, int unsigned, ranged, logic, integer, byte, bit, signed and
   `signed [7:0]` localparams, a non-local parameter, an expression and a
   sized decimal default (golden sizes 32, 32, 32, 3, 8, 32, 8, 4, 8, 64, 4
   — every one equal to the param_assign constant). A hex / binary / octal
   Value abstains (golden writes that fold with no value: EC/ec12).
   fx68k: `aluCorf aluCorf(.cin( pswCcr[ XF]) ...)` in work@fx68k.excUnit.alu.
4. § connOperandNonOvParamFold431 (`R11U431_CONNOPNONOV_OFF`; ExprEmit, the
   NamedValue tail). The operand twin: in an ELABORATED port High_conn a
   module-scope parameter read as an operand of an operation (`x ^ XF`,
   `x + XI`, a concatenation operand, a conditional branch, inside a generate
   scope's connection too) is the instance's stored Value, from the same
   producer, and an overridden one with a bare decimal actual takes pass 81's
   producer (UINT at 64). An operation that is constant as a whole is reduced
   whole by golden (`.a(XF + 1)` -> UINT:5 size 64 at the first operand's
   span; `x[XF+1]`'s index): the law abstains there (EC/ec05 at pristine's
   bytes). Not in a part-select bound or a user-call argument.
5. § caFnArgConcatFormalTs431 (`R11U431_CAFNCONCAT_OFF`; ExprEmit, the
   call-argument formal typespec stamp). In a definition's continuous
   assignment, a function-call actual that is a concatenation holding a
   non-constant operand wears the formal's typespec, as every other operation
   actual does; only a concatenation of constants stays bare (the uhdm2rtlil
   row TypedefedRangedFunctionArgument's `{32'h1234, 32'h5678}`, FA/fa16, the
   measurement behind the older blanket rule). fx68k 1824
   `eaDecode( {opcode[ 8:6], opcode[ 11:9]} )`.
6. § modParamArrElemDefRangeSym431 (`R11U431_MODARRELEMSYM_OFF`; ParamEmit
   makeUnpackedArrayParamTs, beside § pkgParamUnpackedElemDefRange). An
   unpacked-array MODULE parameter keeps its element's packed bound symbolic
   when the bound reads a parameter of the module: the definition listing's
   element typespec holds the operation `width_p - 1` over a bare, unbound
   `ref_obj width_p` with no full name (golden bsg_nonsynth_dpi_rom.sv 31
   `parameter bit [width_p-1:0] arr_p [els_p-1:0]`), the elaborated clone the
   same with its reads named through the parameter (`work@top.r.arr_p.width_p`);
   ours folded both to UINT:0. Not on a materialized package-import copy.

## Grid (cases/, drivers/grid.sh; evidence/grid_law9.txt)

95 case dirs in EC, FA, PA, TP, UB and US, every exit code 0 on both
binaries, every one accepted by upstream slang; `R11U431_OFF` gives pristine's
bytes and exit code on 95 of 95; each case's own switch on 93 of 95, the other
two (UB/ub24, ub27) needing `R11U431_UNITNAMEBIND_OFF` together with
`R11U431_CONNIDXNONOV_OFF` (both fire there; with both set, pristine's bytes).

- 58 NOT_EQUAL -> STRICT_EQUAL, TP/tp12 STRICT_NOTEQUAL type -> STRICT_EQUAL;
- 18 STRICT_EQUAL controls byte-identical (UB/ub01-ub04, ub06, ub13, ub17,
  ub20 among them; EC/ec09, ec10; FA/fa03, fa04, fa10; TP/tp03, tp06; PA/pa04;
  US/us02, us04);
- 7 NOT_EQUAL on both and closer to golden by sorted path-normalized dump
  distance (evidence via drivers/dist.sh): PA/pa01 72 -> 31, pa02 134 -> 109,
  pa03 145 -> 112 (uhdm-cmp counts grow only because the head moved later, to
  the elaborated `'{default:0}` pattern face), TP/tp13 17 -> 11, UB/ub18,
  ub22 22 -> 18, ub23 20 -> 18;
- 11 unchanged (byte-identical): EC/ec05, ec06, ec12, ec20, ec26, FA/fa16,
  UB/ub11, ub15, ub26, US/us01, us03 (residues and controls below).
- Downstream on all 95 (drivers/dsgrid.sh, evidence/downstream_grid.txt):
  EC/ec21 and ec24 EQUIVALENT -> IDENTICAL, every other case's verdict
  unchanged (UB/ub15, ub18, ub22, ub23 DIVERGENT on both binaries; EC/ec05,
  ec26, PA/pa01-pa03 EQUIVALENT on both); none worse.

Cases by law: UB (§ unitParamNameBindsDesign431; ub25 § connBitSelIdxNonOvParamFold431),
TP (§ bodyTypeParamDefKeepsDecl431), EC ec01-ec10, ec12-ec20
(§ connBitSelIdxNonOvParamFold431), EC ec11, ec21-ec27
(§ connOperandNonOvParamFold431), FA (§ caFnArgConcatFormalTs431), PA
(§ modParamArrElemDefRangeSym431), US (residues of the sister's size-form
dimension, labelled under § unitParamNameBindsDesign431).

## The one five-stage sweep (law9; drivers/fullsweep.sh, R11U431_TRACE set)

Four corpus stages by tests/sweep.sh --jobs 3 from the worktree, the sv-tests
stage through the main tree's scripts/check_svtests.py with --baseline the
worktree's results/golden_svtests.csv; launched after three quiet readings;
workdir /tmp/r11u431sw1 (evidence/fullsweep_law9.log).

| stage | reading | vs baseline |
|---|---|---|
| probe | EQUAL 4018, STRICT_NOTEQUAL 69 of 4087 | 0 / 0 / 0; csv identical to the control |
| surelog | default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL standing) | 0 / 0 / 0; csv differs from the control only in the two LowMem log-path texts |
| uhdm2rtlil | 803 / 1 / 67 in both modes | 0 / 0 / 0; csv identical to the control |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | csv identical to the control |
| sv-tests | EQUAL 1894, STRICT_NOTEQUAL 6, DIFFERENT 40, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | 0 / 2 / 0 (the two conversions above) |

Byte census (evidence/byteverify_law9.txt; tools/probe/r11v75repro/byteverify.sh,
SELFCHECK=1, law workdir against the master's control /tmp/intr11u429, equal
name lengths): surelog 0 of 962 (selfcheck 961/962), uhdm2rtlil 0 of 1608
(1607/1608), downstream 0 of 805 (804/805); probe 4087 of 4087 identical by
path-normalized uhdm-dump (drivers/bytecmp.sh; positive control: a known
mover pair flagged). Canaries (evidence/canaries_law9.txt): ok=52 and
ok=16 with changed 0; `EXPECT_UNKNOWN=1 ctcan2.sh` and `EXPECT_UNKNOWN=6
ctcan2.sh` PASS. Binary audit (fence-filtered, evidence/binary_audit_law9.txt):
5609 of 5659 command records name /tmp/r11u431_law9/slang-uhdm, the other 50
hold only a Surelog line. Law index: `scripts/law_index.py --check` current
at the sweep (the corpus stages rc 0) and regenerated after this README.

## Prediction before the sweep, trace census

Prediction (evidence/prediction_law9.txt, made on law9 before the sweep):
drivers/scan.py over every fence-filtered pristine database of the master's
control (7453: surelog, uhdm2rtlil, probe, downstream) for the cells the
ExprEmit laws can reach (an elaborated High_conn bit-select index or operation
operand that is unbound or parameter-bound; a reference named like a
design-level parameter; a definition cont_assign call's concatenation
argument without a typespec), drivers/srcscan.py over the corpus sources for
body `parameter type` and unpacked-array parameters with a parameter-reading
packed bound, drivers/svscan.py over the sv-tests rows; then traced targeted
runs of every candidate: 273 probe cases, 38 surelog rows in both modes, 30
uhdm2rtlil rows in both modes and in the downstream lane, 764 sv-tests rows.
Predicted: no corpus row, probe case or downstream row fires or moves (the 90
written corpus databases byte-identical, the 273 probe databases identical by
dump, statuses identical); on sv-tests the laws fire on 4 databases (dpi_rom,
fx68k, p130, rsd), two converting. The sweep's trace census
(evidence/trace_census_sweep.txt) is exactly that: dpi_rom 1 firing
(§ modParamArrElemDefRangeSym431), p130 1 (§ bodyTypeParamDefKeepsDecl431),
fx68k 49 + 2 + 1 (§ unitParamNameBindsDesign431, § connBitSelIdxNonOvParamFold431,
§ caFnArgConcatFormalTs431), rsd 40 (§ connOperandNonOvParamFold431), and no
corpus row, probe case or downstream row.

## Goal 1

Nothing on this ground: no SURELOG_ONLY, BOTH_REJECT or SLANG_CRASH row's
detail names an exporter message; all 75 SURELOG_ONLY rows carry an upstream
slang front-end diagnostic (5 "expected a declaration name", 2 "cannot assign
to a net within a procedural context", 2 "use of undeclared identifier
'switch'", 2 "expression type 'real' is not integral", 2 "design element does
not have a time scale defined", ...). The probe shapes C::mk().arr[1],
u.mk(x).a[2] and this.mk().inner.s stay as earlier passes left them (Surelog
rejects, upstream slang accepts; not forced). Black-parrot: bp_unicore
measured alone on law9 with the guard on (§ macroVecLitTokenText403): exit 3
in 16.4 s at 782 MB peak RSS with the same substr error; no memory-bounded
export found, the guard stays. generated/rsd/rsd.sv SURELOG_CRASH, not ours.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The compilation-unit parameter read in a definition when the module
   declares a NET or a PORT of that name and the ELABORATED continuous
   assignment reads it whole: golden re-reads the `$unit` value there and
   folds `assign y = CF;` to the parameter's value sized at the left side
   (UB/ub18, ub22, ub23: closer, DIVERGENT downstream on both binaries).
2. The same binding in an INTERFACE definition (UB/ub11: golden binds; the
   definition flag this law reads is set by ModuleEmit for modules only).
3. An elaborated connection's operation that is constant as a whole, which
   golden reduces to one constant located at its first operand
   (`.a(XF + 1)`, `x[XF+1]`: EC/ec05); a part-select bound naming a
   parameter, where golden shares the param_assign's own constant (EC/ec06);
   a hex-valued parameter's fold, written by golden with no value (EC/ec12);
   a generate-block localparam in a connection (EC/ec26); a compilation-unit
   parameter in an elaborated connection index (UB/ub26: golden UINT at the
   unadjusted width, 64 for an untyped one); a call-argument index
   (EC/ec20, fullname).
4. The elaborated `'{default:0}` default of an unpacked-array parameter, an
   operation 75 with a tagged_pattern in golden where ours writes an
   array_expr, and its extra array_typespec copies (PA/pa01-pa03).
5. An elaborated variable typed by an overridden body type parameter, missing
   its ref_typespec in the second type parameter's position (TP/tp13).
6. A wildcard-imported package parameter shadowed by a module localparam,
   which Surelog resolves to the package value (UB/ub15, a Surelog artefact).
7. A literal concatenation as a function argument in an elaborated continuous
   assignment folded by golden to a BIN value (FA/fa16).
8. p733 (defparam from another top, which Surelog does not apply: golden
   folds `size-1` with the default `size`), tnoc's 333:14 head (a Surelog
   artefact), and the carried backlog of passes 429 and earlier (the brief's
   items (a) to (s)), untouched.

## Sister-ground faces (reported, not written)

- fx68k's next head: TypeEmit's size-form unpacked dimension `[N]`
  (TypeEmit.cpp, the "Size-style dim [N]" branch building the `N - 1`
  operation) folds a compilation-unit untyped parameter operand at 32 bits
  where golden keeps the parameter's unsized 64 (fx68k nanoRom
  `reg [NANO_WIDTH-1:0] nRam[ NANO_DEPTH]` 2483:29, golden UINT:336 size 64;
  cases US/us01, us03). Behind it, fx68k's parenting faces (case_item and
  begin parents of statements under `unique case`) remain.
- The six basejump rows whose head is the design's module list
  (source_sync_channel_control_slave, test_bsg_comm_link_checker,
  nonsynth_mem_1rw_sync_assoc, scheduler_dataflow, nonsynth_ascii_writer,
  dff_en_segmented): golden lists the uninstantiated definitions with
  `"inv"` (BSG_INV_PARAM) default-less parameters in allModules where ours
  lists none (UhdmExporter, the § undefaultedDefInvalidInst404 listing).
- bsg_source_sync_channel_control_master: its three definition-view `$bits`
  heads are TypeEmit emitSyntaxExpr's (the module is not instantiated, so no
  elaborated half exists there).
- round_robin_fifo_to_fifo, comm_link, mesh_stitch: typedef / port range
  heads keeping `inv`-placeholder expressions (TypeEmit / UhdmExporter).
- p203 (class parameter order under a positional override), p334 (a
  default-less generic class's method typespec ranges), p719 (nested-module
  implicit nets), p737 (the design name with a default-less type parameter),
  class_test_49, easyUVM and the 16 uvm-examples rows (package / class listing
  heads): module/type ground, as their heads read at this base
  (evidence/svtests_heads_base.txt).

## Process

The IMPLEMENTER within the budget: no pristine build of its own beyond the
worktree's base build (md5 equal to the main tree's), intermediate law builds
law1 to law9 used on case runs and targeted runner calls only (the 48
non-equal sv-tests rows twice, fx68k / p130 / dpi_rom / bp_unicore singly),
one traced prediction run on the candidate rows of law9, one full five-stage
sweep on law9. Every runner batch, the prediction and the sweep waited for
three quiet readings; the master's integration sweep of pass 432 was live
during the scans and the case grids and nothing of this pass's runner,
prediction or sweep overlapped it. Slips, none affecting a measurement: the
first database scan was stopped by its task id after a scanner bug (it
flagged every procedural concatenation argument) and rerun; the first probe
dump comparison normalized the worktree path after the generic /tmp rule and
flagged all 273 probe databases, rerun with the order fixed; a byteverify
invocation ran twice. The fence list was read into a file by a program
without printing it and every tree-wide list was filtered on it before any
file was opened; no fenced test named, opened or run; no other agent's
process touched.
