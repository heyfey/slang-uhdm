# r11u485 — expression/parameter ground: what Surelog writes when it cannot value an override, defparam-over-override values, and the late binder's implicit-net kinds

Pass 485 of the sv-tests campaign on the expression/parameter ground (src/ParamEmit.cpp,
src/ExprEmit.cpp and src/EmitHelpers.h; StmtEmit.cpp and every sister file unchanged), on base
b20e61b5c (pass 476). Measured under the measurement budget: the pristine reading is the
master's control /tmp/intr11u476; no pristine sweep; the worktree's pristine build is
byte-identical to the main tree's build/slang-uhdm (md5 9aaf4570aa8c469640569b4ba37b874d);
one full five-stage sweep on the final binary (law8, md5 3cea9c1e8e880dbd38368f67653b4b52,
slang 12.0.0+545f88b2e); byteverify against the control.

## Verdict

- THE TARGET ROW: `generated/uvm-examples/uvm_param_vif_config_db.sv` re-measured at the base
  with the runner and the strict comparator on the kept pair (evidence/row_pvc_base_pristine.txt):
  STRICT_NOTEQUAL `differ:fullname(3)`, uhdm-cmp 0 lines, the three strict objects all on the
  sister's ground (#93329 and #165115 the per-clone `UVM_SEQ_ARB_TYPE` ref_typespec under
  `set_arbitration`'s formal `val`, named through `sfr_test_pkg` where golden names
  `sfr_agent_pkg` and `tb_params_pkg`; #201344 the walk diverging at golden's typespec_member
  `data` (uvm_pkg.sv 255) where ours has an operation at uvm_reg_map.svh 2034). No head on this
  ground; no law of this pass fires on the row; it stays STRICT_NOTEQUAL `differ:fullname(3)`.
- This ground has no open sv-tests row head, so the pass worked the backlog: pass 483's
  residues (OV/ov06, ov16, ov23, v11u483 VO/vo07, vo12, vo13, vo20, IV/iv08, VI/vi14).
  Six laws. The grid has 76 case dirs (DP 28, EA 13, SE 9, DF 8, NT 11, NN 7): pristine
  STRICT_EQUAL 5, STRICT_NOTEQUAL 4, NOT_EQUAL 67; law8 STRICT_EQUAL 72, NOT_EQUAL 4
  (67 dirs to STRICT_EQUAL, the 4 left all closer or byte-identical). The away census over 399
  fence-filtered earlier case dirs moves 11, all toward golden, 5 of them to STRICT_EQUAL
  (v11u483 VI/vi14, VO/vo07, vo13, vo20, IV/iv08), no exit code moving.
- Corpora unchanged: probe 4025 + 62, surelog 954 + 0, uhdm2rtlil 1606 + 0, downstream
  803/66/2/0, sv-tests 1936/1/3 with every stage regressions=0 conversions=0 changes=0; no
  corpus mover (byteverify 0 of 962, 1608 and 805; probe dumps 0 of 4087), as predicted.

## Laws (each read through src/LawSwitch.h; R11U485_OFF drops them all)

### § clsOvDepParamOpTree485 (ParamEmit; R11U485_DEPPARAM_OFF; cases DP)

A parameter of an instance whose initializer READS a parameter A that
§ clsScopedOvRhsRefObj483 (or § clsOvExprActualOpTree485 below) left unvalued. Surelog's
DesignElaboration compiles each such initializer with Reduce::Yes in the instance (the
paParam_assignment loop): a reference to A inside an operation is replaced by A's COMPLEX value
— the very object of A's param_assign Rhs, shared, not copied — the reduction fails and the
operation is kept as the instance's complex value, which NetlistElaboration::elab_parameters_
writes whole as the elaborated Rhs. Golden, measured:

- the Rhs is the written operation tree, parentheses dropped (dp19), each operation at its own
  span; an unsized decimal literal is UINT:<v> size 64 (const type 9), a sized 'd literal
  DEC:<v> of its width (const type 1, dp25), the name of another parameter of the instance whose
  Rhs is already a constant a copy of that constant at the name's span with no typespec (dp26);
- every reference to A is A's object itself (dp07 `A + A` lists it twice); a binary or
  conditional operation re-parents its direct operands (the shared ref_obj's parent is the LAST
  such operation, dp18), a unary one does not (dp15, dp28);
- a parameter read whose own value is complex (`B = A + 1; C = B + 1`) is that parameter's
  operation itself (dp11, dp24), and a bare `C = B` is B's operation as C's whole Rhs, not
  re-parented (dp27);
- a BARE `B = A` or `B = (A)` reduces to A's VALUE, still its declaration default: UINT:<default>
  size 64 with no typespec, or, for a declared `int B`, size 32 with B's typespec (dp03, dp04,
  dp06, dp21, dp23); an unsized `'hF` default gives HEX:F size -1 (dp22);
- a declared `int B` types the operation with B's typespec (dp13), an implicit type leaves it
  untyped;
- A's object gains a ref_typespec to A's own typespec once a reader compiled it (dp01, dp03;
  none when A has no typespec), named after the ref_obj, or after the instance when A's value is
  an operation (EA/ea11). The actual is bound design-final (end of drainPaNameCopySrc38) since an
  elaborated parameter's typespec actual is bound after emitParameters.

Ours wrote slang's folded value. Abstains (pristine kept): any other leaf — a call (`$clog2(A)`,
dp09: golden writes a different, partly cloned shape), a based literal other than 'd, a name of
a later or non-constant parameter — an overridden reader, and a reader typed other than
implicit or `int`.

### § clsOvExprActualOpTree485 (ParamEmit; R11U485_EXPRACTUAL_OFF; cases EA)

A NAMED override actual that is an operation tree over class-scoped names, `.A(K::w + 1)`,
cannot be valued by Surelog for the same reason as a bare `K::w`, so elab_parameters_ keeps the
unreduced actual as the elaborated Rhs: the written tree, parentheses dropped, each operation at
its own span (an operation whose left operand is parenthesized starts at that parenthesis,
ea05; `((K::w + 1))` starts inside, ea06), every class-scoped leaf a ref_obj named and spanned as
§ clsScopedOvRhsRefObj483's with the full name `<instance>.<name>` (ea04 lists two distinct
objects for `K::w + K::w`), an unsized decimal UINT:<v> size 64, a sized 'd literal DEC:<v> of
its width (ea08), no typespec anywhere; a parameter of the instance reading it then sees this
operation as A's complex value (ea11). Shapes: + * - comparisons, unary - ~, the conditional
(ea07), nested (ea02, ea10), interfaces (ea12), a second parameter overridden by a literal (ea13).
clsOvExprActual485 decides the shape (binary, unary - ~ ! and conditional over class-scoped
names, unsized decimals and sized 'd literals, at least one class-scoped leaf); a defparam on the
parameter abstains as § clsOvDefparamAbstain483v does. Pass 483's OV/ov16 moves to its next
head, the body bound (TypeEmit's).

### § clsOvSpanSepEnd485 (ParamEmit; R11U485_SEPEND_OFF; cases SE, v11u483 VO/vo07)

The class-scope span of § clsScopedOvRhsRefObj483's ref_obj ends where the LAST `::` token
ends, not where the member name starts: `K :: w` is 4:35-4:39 in golden. The two agree when
nothing separates them (se03, se06 to se08 byte-identical); spaces after `::` (se01, se02, se04,
se05) move to golden; the same rule spans the leaves of § clsOvExprActualOpTree485 (se09).

### § ovDefparamWinsValue485 (ParamEmit; R11U485_DEFPARAMVAL_OFF; cases DF, v11u483 VO/vo13, vo20)

A parameter overridden BOTH by its instantiation (`#(.A(5))`, `#(5)`, `#(.A(p::W))`,
`#(.A(K::w))`) and by a defparam: Surelog's elaborated param_assign Rhs is the DEFPARAM's value
(the defparam table is applied on top of the instance's override), the constant keeping its
shape (int typespec, size, location at the declaration default); ours wrote the instantiation
actual's folded value. The law re-values that constant from the defparam's written unsized
decimal or sized 'd literal (UINT or INT as the constant had it; decompile the value's digits,
`4'd6` reading 6, df05), through the instance body's hierarchyOverrideNode entry for the
parameter (the defparam syntax slang records). Shapes: named and ordered overrides, a package
actual, a defparam through a level (df06, vo20), a second parameter (df07), two instances with
the defparam on one (df08); df04 (defparam alone) is a control, already STRICT_EQUAL. Any other
defparam value, or a non-constant Rhs, abstains.

### § implicitNetDefaultType485 (EmitHelpers mintImplicitNet403 + ParamEmit drain; R11U485_NETTYPE_OFF; cases NT, v11u483 VI/vi14)

The wire the late binder mints for an unresolved name (UhdmWriter::lateBinding, the lookup-miss
branch) is stamped `getVpiNetType(elem->m_defaultNetType)`: the `default_nettype in force where the
HOLDING definition is declared, so under `default_nettype tri the wire is vpiNetType 4 (vi14),
wand 2, wor 3, tri0 5, tri1 6, uwire 13 (nt01 to nt06), where mintImplicitNet403 wrote a flat 1.
mintImplicitNet403 records every wire it mints in a side list; the design-final drain finds each
wire's holding definition by name (abstaining on an unknown or ambiguous name) and re-stamps
the type when that definition's default is neither wire nor none. Reaches every mint site of
the helper: the interface instance read as a value (nt01 to nt07, a sub module declared under
tri while top is under wire nt07), the ref_var local's wire of § vifTdRefVarLocalImplicitNet481
(nt08), the task name read as a value (nt09, § taskNameReadImplicitNet451), the undeclared read
of § undeclaredReadImplicitNet447 (nt10). The continuous-assignment implicit wire is not this
helper's (nt11, ModuleEmit's, below).

### § ifaceValNoneBindsInst485 (ExprEmit record + ParamEmit drain; R11U485_NONEBIND_OFF; cases NN, IV/iv08)

Under `default_nettype none the late binder mints nothing for an interface instance read as a
value (§ ifaceInstValueImplicitNet483's abstention) and golden's reference keeps what its
instance lookup found: the ELABORATED interface_inst of the first instance of the holding module
in design order (nn03 work@top.s1.u, nn06 work@top.zb.u with zb written first, nn07
work@top.m1.s.u). ExprEmit records the reference with the instance symbol it read (the body the
definition view is emitted from); the drain binds it through ifaceInstMap once the elaborated
tree exists. On every grid dir that symbol's interface_inst is golden's.

## Grid (76 case dirs; evidence/grid_pristine.txt, grid_law8.txt, grid_switches.txt)

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit, real exit code 0;
two drafts it rejected were dropped before the grid). Every exit code is 0 on both binaries.

| group | law | pristine | law8 |
|---|---|---|---|
| DP dp01-dp08, dp10-dp21, dp23-dp28 | clsOvDepParamOpTree485 | NOT_EQUAL 17 | STRICT_EQUAL (26) |
| DP dp09 ($clog2(A)) | (abstain) | NOT_EQUAL 17 | byte-identical |
| DP dp22 (A = 'hF) | clsOvDepParamOpTree485 | NOT_EQUAL 17, distance 26 | NOT_EQUAL 17, distance 25 (older face: A's own typespec) |
| EA ea01-ea13 | clsOvExprActualOpTree485 | NOT_EQUAL 56 to 114 | STRICT_EQUAL (13) |
| SE se01, se02, se04, se05 | clsOvSpanSepEnd485 | STRICT_NOTEQUAL endcol | STRICT_EQUAL |
| SE se09 (`K :: w + 1`) | both | NOT_EQUAL 72 | STRICT_EQUAL |
| SE se03, se06-se08 | (controls) | STRICT_EQUAL | byte-identical |
| DF df01-df03, df06-df08 | ovDefparamWinsValue485 | NOT_EQUAL 64 | STRICT_EQUAL (6) |
| DF df05 (defparam 4'd6) | ovDefparamWinsValue485 | NOT_EQUAL 64, distance 6 | NOT_EQUAL 64, distance 2 (the continuous assignment's size, below) |
| DF df04 | (control) | STRICT_EQUAL | byte-identical |
| NT nt01-nt10 | implicitNetDefaultType485 | NOT_EQUAL 32 | STRICT_EQUAL (10) |
| NT nt11 | implicitNetDefaultType485 | NOT_EQUAL 32, distance 4 | NOT_EQUAL 32, distance 2 (ModuleEmit's wire) |
| NN nn01-nn07 | ifaceValNoneBindsInst485 | NOT_EQUAL 139 | STRICT_EQUAL (7) |

Tally: pristine STRICT_EQUAL 5, STRICT_NOTEQUAL 4, NOT_EQUAL 67; law8 STRICT_EQUAL 72,
STRICT_NOTEQUAL 0, NOT_EQUAL 4; no dump distance growing.

Switches (evidence/grid_switches.txt, 76 dirs; each run deletes its output first):
R11U485_OFF gives pristine's bytes and exit code on 76 of 76. Of the 70 movers, 68 are restored
to pristine by exactly their own law's switch (DEPPARAM 27, EXPRACTUAL 12, SEPEND 4,
DEFPARAMVAL 7, NETTYPE 11, NONEBIND 7, with no other switch moving them); the two needing two
laws: EA/ea11 (EXPRACTUAL_OFF gives pristine, DEPPARAM_OFF the actual's tree alone) and SE/se09
(EXPRACTUAL_OFF gives pristine, SEPEND_OFF the tree with the old leaf span). 6 dirs are
byte-identical on every binary.

## Pass 483's residues (evidence/away_census_bytes.txt; uhdm-cmp lines / path-normalised dump distance)

- v11u483 VO/vo07 STRICT_NOTEQUAL endcol -> STRICT_EQUAL; VO/vo13, vo20 NOT_EQUAL 64 ->
  STRICT_EQUAL; IV/iv08 NOT_EQUAL 139 -> STRICT_EQUAL; VI/vi14 NOT_EQUAL 32 -> STRICT_EQUAL.
- OV/ov06 98 / 78 -> 98 / 46, OV/ov23 98 / 72 -> 98 / 46, OV/ov16 98 / 69 -> 98 / 43: the
  param_assigns are golden's; the head is the body bound reading B or A (TypeEmit's, below).
- VO/vo12 (port `localparam B = A`) 17 / 27 -> 50 / 14: B's param_assign and A's ref_obj
  typespec are golden's; the head moved later, to the continuous assignment `assign o = B;`
  (golden UINT:4 size 8 no typespec, ours UINT:3 with a typespec), so uhdm-cmp prints the
  whole module for it — a count growth with the head later in the walk and the distance down.
- r11u474 CS/cs06 36 / 78 -> 36 / 52 and v11u474 VP/vp06 36 / 19 -> 36 / 6: closer, the same
  body-bound head.

## Away census (evidence/away_census_list.txt, away_census_bytes.txt)

399 earlier case dirs under tools/probe (39329 dut.sv paths fence-filtered by path and then by
content before any other read; kept: a defparam, a `default_nettype or a named override with a
scoped actual), run on pristine and law8: no exit code moves (392 exit 0, 7 exit 3 on both), 388
byte-identical, 11 movers, all toward golden (the nine of the section above plus cs06 and vp06).

## Prediction and census (evidence/prediction.txt, census_*.txt)

Written before the sweep from a traced census of law8 (R11U485_TRACE on): probe (all 4087
through scripts/check_probe.py: EQUAL 4025 + 62, csv equal to the control, all 4087 dumps equal
to the control's after path normalisation, negative control 99 of 99 flagged), surelog and
uhdm2rtlil both modes (verify_golden: csvs equal to the control except the two LowMem log-path
texts; byteverify 0 of 962 and 0 of 1608 with SELFCHECK 961/962 and 1607/1608), and the 20
sv-tests rows whose sources hold a defparam, a non-wire `default_nettype or a scoped named
override (every status equal to golden; positive control R11U483_TRACE in the same runs logging
the four § clsScopedOvRhsRefObj483 firings of uvm_param_vif_config_db). No R11U485 trace line in
any corpus process. Predicted movers: NONE in any stage.

## Sweep (law8, the final binary)

One full five-stage sweep on law8 (`tests/sweep.sh --jobs 3 --workdir /tmp/r11u485swp`, the
probe, surelog, uhdm2rtlil and downstream stages from the worktree, the sv-tests stage through
the main tree's tests/sweep.sh since the worktree's UVM folder is empty; that call exits 1 on
the main tree's stale law index alone, its comparison reading regressions=0), launched on a
quiet machine after the sister r11u478's sweep had finished, R11U485_TRACE on
(evidence/sweep_corpus.log, sweep_svtests.log):

- probe: EQUAL 4025, STRICT_NOTEQUAL 62 of 4087; regressions=0 conversions=0 changes=0.
- surelog both modes: regressions=0 conversions=0 changes=0 (default CMP_EQUAL 480, testflags
  474; 954 + 0 judge-equal row-modes, Tnoc d/t CMP_NOTEQUAL standing).
- uhdm2rtlil both modes: CMP_EQUAL 803, CMP_NOTEQUAL 1 (stamped_gen_param), SLANG_REJECT 67 in
  each mode; regressions=0 conversions=0 changes=0.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871; not identical and
  not excused 0.
- sv-tests: EQUAL 1936, STRICT_NOTEQUAL 1, DIFFERENT 3, SURELOG_ONLY 75, BOTH_REJECT 303,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=0 changes=0.
  uvm_param_vif_config_db reads, as at the base:

      generated/uvm-examples/uvm_param_vif_config_db.sv,STRICT_NOTEQUAL,differ:fullname(3),differ:fullname(3)

- Every csv equals the master's control /tmp/intr11u476 row for row (probe 4087 of 4087,
  uhdm2rtlil 1742 of 1742, downstream 871 of 871, sv-tests 2346 of 2346; surelog 1594 of 1596,
  the other two the LowMemLib and LowMemPkg testflags log-path texts).
- The sweep's trace directory stayed empty: no law of this pass fired in any process, as
  predicted.
- byteverify against the control (SELFCHECK=1, same-length workdir names;
  evidence/byteverify_law8_vs_control.txt): surelog 0 of 962 (selfcheck 961/962), uhdm2rtlil 0
  of 1608 (1607/1608), downstream 0 of 805 (804/805). The probe databases were compared by dump
  in the census (above): 0 of 4087.
- canaries (evidence/canaries.txt): ok=52 changed=0 (surelog) and ok=16 changed=0
  (uhdm2rtlil); ctcan2 EXPECT_UNKNOWN=1 on surelog and EXPECT_UNKNOWN=6 on uhdm2rtlil both PASS.
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name /tmp/r11u485_bin/law8 (the
  other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346; no record
  names another slang-uhdm binary.
- NO MOVER in any stage, exactly the prediction.

## Goal 1 (re-measured on law8)

- The probe faces: `C::mk().arr[1]` (r11u423 evidence/residue_cases/g1a) and `u.mk(3).a[2]`
  (g1b) exit 4 in ours, 0 in upstream slang, 3 in Surelog; `this.mk().inner.s` (v11u415 VT/vt03)
  exits 0 in ours and upstream slang, 3 in Surelog. Surelog rejects all three, so golden has no
  shape to write: not forced.
- All 75 SURELOG_ONLY details are front-end `error:` diagnostics of slang (none the exporter's
  unsupported-shape message).
- bp_unicore alone with the size guard on (§ macroVecLitTokenText403), on law8 after the sweep:
  exit 3 in 14.4 s at 814 MB maximum resident (`basic_string::substr`, the guarded crash text):
  no memory-bounded export, the guard stays; the six black-parrot rows stay SURELOG_CRASH.
- generated/rsd/rsd.sv stays SURELOG_CRASH (Surelog dies first): not this ground.

## Residues (all wrong on pristine too; none moved away)

1. uvm_param_vif_config_db: the sister's faces above (pass 478's brief).
2. The elaborated body bound reading a dependent parameter or an expression actual
   (OV/ov06, ov16, ov23, r11u474 CS/cs06, v11u474 VP/vp06): golden substitutes the operation
   tree into the range (`[B-1:0]` with A's ref_obj cloned per use), TypeEmit's
   § elabParamClsScopedSubst474 (sister's ground).
3. The continuous assignment reading a dependent parameter (VO/vo12 `assign o = B;`: golden
   UINT:4 size 8 and no typespec, ours UINT:3 with B's typespec) and a defparam'd sized value
   (DF/df05: golden size 8, ours 4): the folded parameter read of an elaborated continuous
   assignment, not decoded on this pass.
4. `$clog2(A)` as the dependent initializer (DP/dp09): golden writes a sys_func_call whose
   argument is a ref_obj at A's position parented to A's param_assign while A's own Rhs becomes a
   ref_obj named `K::w` without a full name: not written.
5. An untyped parameter with an unsized hex default carrying an int_typespec in ours where golden
   has none (DP/dp22's head, an older face).
6. v11u483 VI/vi12, vi23 (arrays and queues of virtual interfaces in the module listing),
   IV/iv12 (an interface instance in a generate block), VO/vo10 (Surelog's generate branch
   from the default), IV/iv21 (interface_typespec span): the sister's grounds as pass 483
   reported; v11u481 VA/va56 unchanged; r11u476 CC/cc12 STRICT_EQUAL at the base, its remaining
   difference the shared loop variable's parent in the dump only.
7. The carried lists of passes 483 and earlier (their READMEs).

## Sister-ground faces (reported, not written)

- TypeEmit § elabParamClsScopedSubst474: the body bound reading a dependent parameter
  (`localparam B = A + 1; logic [B-1:0] d;`) or an expression actual (`.A(K::w + 1)`), golden
  writing the substituted operation tree (OV/ov06, ov16, ov23).
- ModuleEmit's continuous-assignment implicit wire under a non-wire `default_nettype (NT/nt11:
  `assign w2 = clk;` under tri, golden vpiNetType 4, ours 1 in the elaborated listing).
- uvm_param_vif_config_db's faces (UhdmExporter / TypeEmit, pass 478's brief).

## Process

The IMPLEMENTER within the budget: no pristine build of its own beyond the worktree build that
had to match the main tree (md5 equal), no pristine sweep (the master's control read instead);
law1 to law8 on case runs (law1 the dependent-parameter law alone, law2 and law3 its typespec
deferral and hex default, law4 the expression actual and the separator end, law5 the net type,
law6 and law7 the defparam value, law8 the none binding), one targeted runner call on the target
row on pristine, one traced census (probe, surelog and uhdm2rtlil in full through the harness
scripts, sv-tests on the 20 text-census rows through the runner), one full five-stage sweep on
law8 and one byteverify. ITS SLIP, affecting no measurement of this pass: its first sweep launch
ran its quiet check and the launch in the same shell command, so it started while the sister
r11u478's surelog stage was live; it stopped its own processes by their recorded PIDs within a
minute (its probe stage had not finished; the stray continuation into its sv-tests stage was
stopped the same way), deleted that workdir and relaunched only after the sister's sweep had
ended, with the quiet check inside the launcher; the guard's first version matched its own
launcher's name (r11u485_sweep.sh) and refused to start, so the launcher was renamed. The fence
list was read into a file by a program and never printed; every tree-wide list (the away census
over 39329 case paths, the text census over 19873 corpus and sv-tests sources, the binary
audit) was fence-filtered before any file was opened, and the repro folder scans clean. No other
agent's process was touched. Every tool variable was checked with `[ -x ]` by drivers/env.sh
before use.

## Files

- cases/DP (28, § clsOvDepParamOpTree485), cases/EA (13, § clsOvExprActualOpTree485),
  cases/SE (9, § clsOvSpanSepEnd485), cases/DF (8, § ovDefparamWinsValue485), cases/NT (11,
  § implicitNetDefaultType485), cases/NN (7, § ifaceValNoneBindsInst485); every dut.sv names its
  law on its first line.
- drivers: env.sh, runcase.sh (Surelog golden + ours, rc, uhdm-cmp lines, strict verdict, md5),
  grid.sh, switches.sh, away.sh, dist.sh (path-normalised dump distance), ddiff.sh, gpas.sh and
  pas.py (the elaborated param_assigns of a dump).
- evidence: prediction.txt, census_*.txt, grid_*.txt, away_census_*.txt,
  row_pvc_base_pristine.txt, sweep and byteverify logs.
