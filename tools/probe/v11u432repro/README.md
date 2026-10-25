# v11u432 — adversarial verification of r11u432 (module/type ground, pass 432)

Base eb8c9b78d. Implementer's patch `/tmp/r11u432.patch` applied clean on a
fresh worktree `/tmp/wt_v11u432`. Pristine reading: the master's control
sweep `/tmp/intr11u430` (measurement budget: no pristine build, no pristine
sweep); pristine binary for case runs: the implementer's frozen base build,
copied to `/tmp/v11u432_bin/pristine` (md5 60d3ffba6f056d6d32b8c5230a29b9c9,
the base md5 of the brief).

Binaries (frozen read-only under `/tmp/v11u432_bin`, all link slang
12.0.0+545f88b2e):

| name | md5 | what |
|---|---|---|
| law | 71ad50bd424b739ea3ce17f1f565bf40 | the implementer's patch rebuilt once; equal to the implementer's law20 |
| ver1, ver2 | 2edfb6f6..., 47192b15... | intermediate verified builds, VC case runs only, never swept |
| ver3 | 8867f8aa81291549e5fe97f2e1531870 | the final verified build (this patch) |

## Verdict

The nine laws reproduce bit for bit: the implementer's 91 grid lines read the
same exit code, uhdm-cmp count and strict verdict on law and pristine (diff of
the normalized lines empty), the law sweep reads every number the implementer
reports, and byteverify against the control reads 0 movers; the implementer's
switch columns reproduce too (`R11U432_OFF` pristine on 91 of 91, each case's
own switch on 77 with 14 needing a co-firing switch), and the verified
binary writes the law's bytes on all 91. ONE BREAK found
by fresh cases, fixed behind its own switch:

**§ clsParamCallSymBind432v** (`R11V432_CLSCALLSYM_OFF`; src/TypeEmit.cpp
emitSyntaxExpr's call branch, the class scope set by src/UhdmExporter.cpp
emitClassParameters). THE BREAK: § clsParamCallArgPkgSel432 binds a call in a
class parameter's initializer to the FIRST function of that NAME in subMap.
When the class declares its own static method of that name beside a `$unit`
function (`function int f` at `$unit`; `class C; static function int f; localparam M = f(3);`),
slang and Surelog resolve the call to the class's method (golden vpiFunction
`work@C::f`), but the law wrote the `$unit` f: a binding golden does not have,
uhdm-cmp 117 -> 206 lines on VC/vc04 and vc11 (pristine wrote no binding).
The refinement: a callee name the class itself declares (Scope::find with the
member's parent scope the class) binds to that method's object when subMap has
one, else stays unbound as on pristine; a name the class only INHERITS keeps
the law's name match, since golden binds the `$unit` f there (VC/vc09, a
base-class static f: law STRICT_EQUAL, kept). vc04 and vc11 back to pristine's
uhdm-cmp count 117 with the law's location gains kept (dump distance 8 -> 4,
16 -> 4); vc09 STRICT_EQUAL as on law. The first form of the fix (ver1,
Lookup::unqualified from the class, which finds inherited members) undid vc09
and was narrowed before any sweep (ver2 used Scope::find, which also returns
the inherited member; ver3 checks the parent scope). It writes a second flag
across files: `classParamScope432v()`, defined in TypeEmit, set and cleared by
UhdmExporter's emitClassParameters beside `classParamRhs432()`, read only by
emitSyntaxExpr's call branch. `R11U432_OFF` still gives pristine (the call
branch is gated on the law's flag); `R11V432_OFF` gives the law's bytes on all
168 case dirs.

## Reproduced headline numbers (law binary, one five-stage sweep, `/tmp/v11u432sw1`, trace on)

- probe: EQUAL 4019 + STRICT_NOTEQUAL 68 of 4087, regressions=0 conversions=1
  changes=0; `CONVERSION r10uvm26repro/t36c STRICT_NOTEQUAL differ:fullname(6) -> EQUAL`,
  fresh row `r10uvm26repro/t36c,EQUAL,,equal`; the csv differs from the control in that row alone.
- surelog: default CMP_EQUAL 480, testflags 474, STRICT_NOTEQUAL 0, regressions=0
  conversions=0 changes=0; csv differs from the control only in the two LowMem
  log-path texts (Google testflags TIMEOUT is the control's row too).
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0, csv identical to the control.
  (The implementer swept this stage on law18 and reran it on law19; this is the
  first full-sweep reading of the final law on it.)
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871,
  csv identical to the control.
- sv-tests: EQUAL 1894, STRICT_NOTEQUAL 4, DIFFERENT 42, SURELOG_ONLY 75,
  BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions=0 conversions=3 changes=0; the csv differs from the control in
  exactly the three rows:
  - `generated/hdlconv_std2017/hdlconvertor_std2017_p193_2.sv,EQUAL,,equal` (was STRICT_NOTEQUAL differ:line(3))
  - `generated/hdlconv_std2017/hdlconvertor_std2017_p600.sv,EQUAL,,equal` (was STRICT_NOTEQUAL differ:fullname(6))
  - `generic/class/class_test_49.sv,EQUAL,,equal` (was DIFFERENT)
  generated/fx68k/fx68k.sv stays DIFFERENT (fires three laws, no status change).
  (The implementer's sv-tests stage ran on law18; this reading is on the final law.)
- byteverify (SELFCHECK=1) law against the control `/tmp/intr11u430`: 0 of 962,
  0 of 1608, 0 of 805, the self-checks flagging n-1 of n.
- canaries ok=52 (surelog) and ok=16 (uhdm2rtlil), changed 0; ctcan2 PASS with
  EXPECT_UNKNOWN=1 and 6.
- binary audit: surelog 1531 of 1581 cmds.txt name `/tmp/v11u432_bin/law`, the
  other 50 hold only a Surelog line (2 of them match `slang-uhdm` only through
  the UVM source path); uhdm2rtlil 1742 of 1742.
- trace census (evidence/trace_census_law.txt): exactly the databases the
  implementer names: probe t36c; uhdm2rtlil d/t and downstream
  TypedefedRangedFunctionArgument (one abstention line, bytes unchanged);
  sv-tests fx68k (§ unitParamShadowDefBind432 on CF, NF, VF, XF, ZF;
  § caCallConcatArgFormalTs432 on eaDecode; § unitParamSizeDimWide432 on
  NANO_DEPTH, UROM_DEPTH), p154_1 and p190 (the two `$unit` body laws, 0
  objects changed), p193_2, p600, class_test_49, and rsd (SURELOG_CRASH:
  § unitParamShadowDefBind432 on 14 references, unmeasurable since golden has
  no database).
- The corpus stages exit 1 on the stale law index alone (tests/LAWS.md
  regenerated last).

## The verified sweep (ver3, `/tmp/v11u432sw2`)

The five csvs identical to the law sweep's (surelog after the workdir name in
the two LowMem texts); byteverify verified against law and against the control
0 of 962, 0 of 1608, 0 of 805 with the self-checks passing; the trace lists
the same firing databases and § clsParamCallSymBind432v fires on none of them
(no corpus row, probe case or sv-tests row declares a class parameter calling
a same-named own-class method). Kept sv-tests databases: see the away census.

## The attack grid (77 fresh case dirs in VC, VD, VE, VF, VO, VT, VU; drivers/grid.sh, evidence/grid_all.txt)

Every case accepted by upstream slang (`~/.local/bin/slang dut.sv
--single-unit`, two first drafts rejected and rewritten: a `$unit` reference
inside a package, a non-positive dimension), every exit code 0 on all three
binaries. Pristine -> verified: 34 NOT_EQUAL -> STRICT_EQUAL, 5
STRICT_NOTEQUAL line -> STRICT_EQUAL, 3 STRICT_NOTEQUAL fullname ->
STRICT_EQUAL, 2 NOT_EQUAL -> STRICT_NOTEQUAL type (VF/vf03, vf14: the
elaborated fold, see residues), 3 STRICT_EQUAL controls byte-identical, 28
NOT_EQUAL on both, 1 STRICT_NOTEQUAL fullname on both (VE/ve08), 1
STRICT_NOTEQUAL fullname -> file (VE/ve11). By sorted path-normalized dump
distance every unequal case is closer to golden or unchanged on the verified
binary, none further (ve01 73 -> 65, ve08 90 -> 80, ve12 85 -> 69, vo03 22 ->
4, vo04 34 -> 6, vc04 8 -> 4, vc11 16 -> 4, vd01 6 -> 4, ...; unchanged:
vc02, vd07, vt01, vt02, vu01). `R11U432_OFF` gives pristine's bytes and exit
code on 168 of 168 case dirs (77 + the implementer's 91); `R11V432_OFF` on the
verified binary gives the law's bytes on 168 of 168; verified equals law on
166 of 168 (all but vc04, vc11). Each case's own switch restores pristine on
57 of 77 (the other 20 the co-firing EB/VE enum pair, the two `$unit` body
laws, and the relabeled vc04/vc09/vc11 whose law line names the refinement).

Downstream (drivers/dsgrid.sh) on the 47 class-free case dirs (VD less vd04,
VE, VF, VU): pristine -> law 44 IDENTICAL on both, VD/vd07 EQUIVALENT on both,
VE/ve10 EQUIVALENT on both, VU/vu01 DIVERGENT on both; law -> verified the
same 47 verdicts. None worse.

Per face (cases name their law in the first line):

- § unitParamShadowDefBind432 (VU/vu01 to vu14): a generate-if condition, a
  generate-for bound, an unpacked dimension, a task body, an always_ff and a
  concurrent assertion, a delay and a net-declaration initializer, a module
  port connection, a typedef's packed range: STRICT_EQUAL (vu02, vu03, vu05,
  vu06, vu08, vu11, vu12, vu13); a parameter override on an instance
  `#(.P(W))` control (vu04); an output-port range `[CF:0]` (vu01, unchanged,
  downstream DIVERGENT on both), a hierarchical `m.CF` (vu07), an interface
  (vu09, the law walks modules only), a function-local shadow plus an
  overridden parameter port (vu10), a `$unit` W in a port range (vu14):
  closer, residues.
- § caCallConcatArgFormalTs432 (VF/vf01 to vf14): named arguments out of
  order (vf01: the law indexes Tf_call_args by position and still reads
  STRICT_EQUAL, so ours lists the arguments in formal order), two concatenation arguments, a package-qualified and
  a wildcard-imported package function, a `$unit` function, a nested
  concatenation, a one-element concatenation, an int formal, a two-target
  assign, an instantiated module, a skipped default argument: STRICT_EQUAL;
  parameter-only operands `{P, Q}` and `{P, 3'd1}` (vf03, vf14) stamp as
  golden does in the definition view and are STRICT_NOTEQUAL type at the
  elaborated fold (golden keeps the call, ours folds: ExprEmit, the sister's).
- § pkgVarEnumBaseRefName432 / § impNetEnumSlotEnd432 (VE/ve01 to ve12):
  initialized members, two declarators, a package-imported-in-module copy:
  STRICT_EQUAL (ve03, ve05, ve07); explicit base types `logic [1:0]`, `bit`,
  `int unsigned`, a typedef base, a one-member enum with a base, a
  macro-written member list, a design with an interface and a child module:
  closer (the extra elaborated enum copy ours writes, pre-existing, now named
  like golden's one copy); a `$unit` inline enum and a module's own (ve09)
  control.
- § unitParamSizeDimWide432 (VD/vd01 to vd08): a class property and a module
  shadowing a child's parameter: STRICT_EQUAL (vd04, vd08); a `$unit` typedef
  (vd02) control; ports, struct members, generate blocks, function locals, a
  two-dimension array, an interface and a program, a based `'d3`, `[E+1]` and
  `$unit::G`: closer or unchanged (vd07), all NOT_EQUAL on pristine at other
  faces.
- § clsParamCallArgPkgSel432 (VC/vc01 to vc12): a bare `glb::arr[N]`
  initializer, a package function wildcard-imported, two arguments with a
  vector bit, a qualified package call, a package class: STRICT_EQUAL; the
  own-class static method (vc04, vc11): THE BREAK above; a `$clog2` argument
  (vc02) unchanged; a two-dimension select (vc07, the law abstains), a `$unit`
  array (vc06), a class nested in a module (vc12): closer.
- § tpProtoRetDefaultTs432 (VT/vt01 to vt07): a second type parameter, a
  package class, a class extending a specialization, a class in a module, two
  prototypes: STRICT_EQUAL; a struct default and a class default (vt01, vt02)
  byte-identical to pristine (the law abstains: no default typespec object).
- § unitOobBodyRefChainName432 / § unitOobBodyArgRefUnbound432 (VO/vo01 to
  vo10): a for-loop variable, foreach, nested named blocks, a struct argument,
  an output argument, the function-name return assignment: STRICT_EQUAL; a
  `$unit` parameter and variable read (vo03), recursion with a design-listed
  and an in-class static method (vo04), a class typedef return (vo10): closer.

## Away census

- Earlier-pass case census (evidence/census.txt): 4085 fence-filtered case dirs of
  passes 401 to 430 (every r11u4NN and v11u4NN repro below 432), each run on
  pristine, law and verified (evidence/census.txt): exit codes equal across the
  three binaries on all 4085 (4058 exit 0, 19 exit 4, 8 exit 3, the standing
  backlog shapes); verified byte-identical to law on all 4085; pristine
  differing from law on 20, all toward golden (evidence/census_movers.txt): 11
  to STRICT_EQUAL (r11u402 UO/uo05_member_ref, uo07_used; r11u410 OT/ot04;
  r11u414 TA/ta04; r11u424 TP/tp01; v11u402 VO/vo01_param_class; v11u413
  VR/vr01, VU/vu07; v11u417 VC/vc36; v11u424 VP/vp01, vp02), v11u402
  VO/vo02_static_used NOT_EQUAL -> STRICT_NOTEQUAL fullname, v11u424 VP/vp04
  STRICT_NOTEQUAL line -> fullname (dump distance 25 -> 21), and 7 NOT_EQUAL on
  both closer by dump distance (r11u424 TP/tp02 25 -> 16, v11u409 VW/vw06
  96 -> 94, v11u410 VO/vo01 70 -> 64, vo02 87 -> 77, vo04 25 -> 15, v11u424
  VP/vp06 132 -> 131, v11u426 VN/vn21 31 -> 19). No mover away.
- Kept sv-tests databases, law against verified by path-normalized dump:
  66 of 67 identical
  by path-normalized uhdm-dump (evidence/svdump.txt); tnoc's dump cut by the
  900 s timeout, its two databases the same size (230131612 bytes) and uhdm-cmp
  between them reading 0 lines.

## Goal 1

Reproduced: `results/golden_svtests.csv` holds 75 SURELOG_ONLY and 303
BOTH_REJECT, no SLANG_CRASH, and no detail names an exporter message; the
sweep reads the same 75 and 303. Nothing on this ground.

## Residues (all wrong on pristine too; none moved away on the verified binary)

1. The own-class static method golden binds (`work@C::f`, VC/vc04, vc11): ours
   has no object for it when the class parameters are written, so the call
   stays unbound as on pristine (uhdm-cmp 117 lines). Writing it needs the
   class's methods emitted before its parameters, or a late bind in final287.
2. § unitParamShadowDefBind432 not reaching interfaces (VU/vu09), port ranges
   (vu01, downstream DIVERGENT on both), hierarchical references (vu07) and
   a `$unit` parameter in a port range (vu14).
3. The elaborated fold of a call over parameter-only concatenations (VF/vf03,
   vf14; ExprEmit, the sister's), with the implementer's fa20.
4. The extra elaborated enum typespec copy ours writes for an imported inline
   enum with a base type (VE/ve01, ve02, ve04, ve06, ve12) and the interface
   and child-module copies (ve08).
5. The `$unit` body's reads of `$unit` parameters and variables (VO/vo03),
   recursion (vo04), class typedef returns (vo10).
6. The implementer's residues stand as listed in tools/probe/r11u432repro/README.md
   (fx68k's elaborated port-connection fold, the statically called `$unit`
   out-of-body function, the scoreboard rows, easyUVM, p719, CP/cp17 to cp19,
   UP/up12, UD/ud07, tp03, fa20, and the carried lists).

## Sister-ground faces (reported, not written)

- VF/vf03, vf14: the elaborated fold of `f({P, Q})` (ExprEmit's constant fold
  of the call; golden keeps the func_call).
- Unchanged from the implementer: tp03 (StmtEmit/ExprEmit), fa20 (ExprEmit),
  fx68k's port-connection fold (ExprEmit operands, ModuleEmit placement).

## Notes on the implementer's README

- Its grid heading says "82 case dirs"; the grid holds 91 (19 CP + 10 EB +
  21 FA + 13 TN + 8 TP + 8 UD + 8 UP + ... = 91 lines in evidence/grid.txt).
- Its probe, surelog and sv-tests stages ran on law18 and its uhdm2rtlil and
  downstream on law19; this verification swept the final law (= law20) on all
  five, with the same readings.

## Process

- One law build, three verified builds (ver1 and ver2 on VC case runs only,
  never swept; one build beyond the budget's one verified build), one
  five-stage sweep each on law and ver3, each launched after a quiet reading.
- Slips, none affecting a measurement: (1) the 168-case grid launched while the
  sister v11u429's sweep driver was in its own quiet-wait loop (no stage of it
  live; its stages started after the grid); (2) the earlier-pass census and the
  kept-database dump comparison ran for about 90 s beside the master's pass
  429 integration sweep `/tmp/intr11u429`, were stopped by task id, and resumed
  after a three-reading quiet check.
- The fence list was read by a program from canaudit.sh's FENCED= line into a
  file, never printed; the earlier-pass case list was filtered on it before
  any file was opened; no fenced test named, opened or run. No other agent's
  process touched.

## Files

drivers/run1.sh, grid.sh, dsgrid.sh (from the implementer's, keyed on the
full repro path), fullsweep.sh, quiet.sh, switches.txt; evidence/grid_all.txt
(168 lines), dsgrid_*.txt, trace_census_law.txt, census.txt, svdump.txt.
