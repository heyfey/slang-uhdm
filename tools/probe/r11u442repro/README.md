# r11u442 — module/type ground, goal 1: the exit-4 typedef and class-property shapes

The twenty-first pass of the sv-tests campaign on the module/type ground
(src/TypeEmit.cpp, src/UhdmExporter.cpp), implementer phase, on base 4899f5c73.
Fourteen laws, every one behind its own switch, all read through
src/LawSwitch.h (`lawOn(442, "R11U442_<LAW>_OFF")`, `R11U442_OFF` drops the
whole pass, `R11U442_TRACE=<dir>` logs every firing through
`lawTrace(442, ...)`). No src/R*.h, no getenv, no reader function, no
LawState.h section; ModuleEmit, TaskFuncEmit, uhdm_main.cpp, include/ and the
sister's files (ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit) unchanged.

## Verdict

- sv-tests: **no row moves** (regressions 0, conversions 0, changes 0; the
  sweep's csv equals results/golden_svtests.csv and the control's on all 2346
  rows). The laws fire on no sv-tests row: every open both-accepted row first
  differs elsewhere (below), and every SURELOG_ONLY row carries an upstream
  slang front-end diagnostic (goal-1 census below).
- Goal 1 on the probe backlog: **the exit-4 shapes the brief lists move to exit
  0**: v11u414 VH/vh04 and VC/vc13, v11u402 VE/ve02, v11u410 VY/vy02, r11u426
  AC/ac04, r11u410 AQ/aq09, v11u426 VA/va09 to STRICT_EQUAL; v11u410 VU/vu02
  to exit 0 (NOT_EQUAL on a pre-existing enum-element face); v11u436 VS/vs06
  and v11u440 VN/vn10 (both carrying a module class typedef) to exit 0
  (vn10 STRICT_EQUAL). r11u426 AC/ac05 stays exit 4 (residue 3).
- Goal 2 residues of earlier passes written on the way: r11u406 AT/at18
  (NOT_EQUAL -> STRICT_EQUAL), r11u426 AC/ac03 (STRICT_NOTEQUAL type ->
  STRICT_EQUAL), r11u249 M/m01 to m03 and N/n04, r11u402 AA/aa08 and VY/vy02,
  r11u410 AQ/aq05 and VU/vu03, r11u293 CA/ca08, r11u202 CT/c11 to STRICT_EQUAL.
- Every corpus gate unchanged (below); no corpus row, probe case or sv-tests
  row is touched (the sweep's trace is empty in all five stages).

## Goal-1 census (results/golden_svtests.csv at the base)

All 75 SURELOG_ONLY rows carry an upstream slang front-end diagnostic in
their detail (`<file>:<line>:<col>: error: ...`; no `unsupported constructs`
message); the one BOTH_REJECT detail without `error:` is a missing source
path (`.../uvm_alu_config_analysis/a: No such file or directory`, the
Surelog side); no SLANG_CRASH row. Nothing on this ground is stuck at an
exporter error in sv-tests, as passes 406 to 440 found. The exporter's own
exit-4 messages (`noteUnsupported`) live on in the probe backlog only, which
this pass worked (the brief's items 1a to 1c).

## Laws

| law | switch | file | what |
|---|---|---|---|
| § modClassTdListing442 | R11U442_MODCLSTD_OFF | TypeEmit, UhdmExporter | a module-body `typedef C c_t;` (had `typedef target: ClassType`, exit 4) is listed as the $unit branch lists it: one class_typespec named after the typedef, vpiClassDefn the class, at the class name (a scoped `p::C` from its first token to the START of the last identifier: golden 7:11-7:14; a specialization `C#(8)` at the name alone), parented and Instanced at the module, specialization parameters named `<module>.<typedef>.<param>`. Every typedef of one class shares the location of the FIRST such typedef Surelog compiles (packages, then $unit, then module and interface definitions in name order, each in source order) and a later one carries a vpiTypedefAlias reference named by its own full name onto the first one (a package first: also the package as vpiInstance). Its END is moved by the module's own variable declarators typed by it, the last in source order winning: an unpacked dimension ends it at the first dimension's `]`, an initializer alone at the initializer's end; subroutine and procedural locals never move it |
| § modDynArrClsTdElemClassVar442 | R11U442_DYNCLSTDELEM_OFF | TypeEmit | the element of a module variable's dynamic, queue or associative array of a class TYPEDEF is a class_var (§ aliasClassRefVar10's module-scope half), and the typedef's listed class_typespec keeps its parent |
| § unitClassTdEndAtDim442 | R11U442_UNITCLSTDDIMEND_OFF | UhdmExporter | inside § unitClassTdEndAtInit202's writer: a module declarator with an unpacked dimension writes the $unit class typedef's end too, at the first dimension's `]` |
| § unitClassTdScopedSpan442 | R11U442_UNITCLSTDSCOPED_OFF | UhdmExporter | a $unit typedef of a scoped class name ends at the start of the last identifier (`typedef pkg_a::Cls#(3) u_t;` 6:9-6:16) |
| § classEventDynArrNamedEvent442 | R11U442_CLSEVENTDYN_OFF | UhdmExporter | the dynamic/queue/associative twin of § classEventArrElem402: a class property written with the `event` keyword and any unpacked dimension is one named_event (had `class array property element`, exit 4) |
| § classChandleTdArrElem442 | R11U442_CLSCHANDLEARR_OFF | UhdmExporter | a class array property's chandle element under a dynamic, queue or associative dimension is a chandle_var with no typespec (had exit 4); a chandle or event element written through a TYPEDEF is a bare logic_var with no typespec under every dimension kind (the fixed branch wrote chandle_var) |
| § unitEventTd442 | R11U442_UNITEVENTTD_OFF | UhdmExporter | a $unit `typedef event ev_t;` lists an event_typespec at the keyword (had `typedef target: EventType`, exit 4) |
| § unitArrTdAliasChain442 | R11U442_UNITARRTDCHAIN_OFF | UhdmExporter | a $unit typedef naming a typedef that is itself an alias clone (`typedef ua_t ub_t; typedef ub_t uc_t;`, fixed, dynamic, queue or associative) lists one more clone of the ROOT listing, its vpiTypedefAlias reaching the named typedef's listing directly (had exit 4) |
| § unitPkgArrTdAliasClone442 | R11U442_UNITPKGARRTD_OFF | UhdmExporter | a $unit typedef naming a PACKAGE fixed-size array typedef (`typedef p::ua_t ub_t;`) lists a clone of the package listing aliasing it, Instanced at the package, its element typespec too (had exit 4) |
| § unitArrTdAliasVarBindsListing442 | R11U442_UNITALIASVAR_OFF | UhdmExporter | an elaborated variable typed by a $unit fixed-array ALIAS-clone listing (426, 442 chain, 442 package) binds that listing, where ours bound a bare unaliased copy (STRICT_NOTEQUAL type) |
| § paramBoundQTd442 | R11U442_PARAMBOUNDQTD_OFF | TypeEmit | a module-body bounded queue typedef whose bound names a parameter (`typedef int q_t [$:P];`) is listed as the literal form is, the bound a reference `work@top.q_t.P` with no actual (had exit 4); the elaborated copy's bound is the instance's param_assign value object |
| § modDynTdDefNetCopy442 | R11U442_MODDYNTDDEFNET_OFF | TypeEmit, UhdmExporter | a definition net typed by a module-body dynamic, queue, bounded-queue or associative typedef binds its own copy of the listing (references named after the bare typedef, unparented, Instanced at the definition, vpiTypedefAlias onto the listing); the elaborated array_var binds another copy with neither alias nor Instance; not for a listing whose innermost element is a typedef (406's alias-element shape binds the listing itself) |
| § unitDynQRealTdElem442 | R11U442_REALTDELEM_OFF | TypeEmit | a `real` typedef element (`typedef r_t rq_t[$];`, `[]`, `[$:3]`) is listed by 406's alias-element and 410's bounded-queue writers (had exit 4) |

Flags written across files (each written in TypeEmit, read in
UhdmExporter's end-of-design pass; looked up by key, never iterated for
emission order): `g442ClsTdBySyn` (map syntax -> module class_typespec),
`g442ClsTdAliasPending` (vector, iterated in insertion order to add the
aliases), `g442ModDynTd` (map listing -> typedef, looked up while walking
ref_typespecs in UhdmId order). The alias resolution falls back to
`typedefTs` and `pkgTopTypedefTs` by declaration syntax (one symbol per
$unit or package typedef).

## Measurements

Binaries: pristine = the main tree's build/slang-uhdm at the base, md5
9c2f5e28fcfc2802c710420b7d6ec655 (frozen copy; the worktree's base build
read the same md5); law19 md5 9bbb204e4039d68f6da77b14827193a7 (swept);
FINAL law20 md5 4774f1a2b30c0a09c72529a446ae47ef = law19 plus the module
specialization parameter prefix inside § modClassTdListing442's branch (see
the sweep note). Both link slang 12.0.0+545f88b2e (~/.local).

### The one full sweep (law19, trace on; /tmp/r11u442_LW, sweep log in evidence)

tests/sweep.sh --jobs 3, corpora probe, surelog, uhdm2rtlil, downstream, and
the sv-tests stage through the main tree's scripts/check_svtests.py (the
worktree has no UVM tree; scripts/ and tests/sweep.sh equal at the base):

- probe EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, regressions 0, conversions
  0, changes 0; the csv identical to the control /tmp/intr11u440; the 4087
  databases identical to the control's by path-normalized dump
  (drivers/probe_dumpcmp.sh; a positive control comparing two different
  cases flagged).
- surelog default CMP_EQUAL 480, testflags 474, 0/0/0; the csv differs from
  the control only in the two LowMem log-path texts.
- uhdm2rtlil 803/1/67 in both modes, 0/0/0; csv identical to the control.
- downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  csv identical to the control.
- sv-tests EQUAL 1912, STRICT_NOTEQUAL 1, DIFFERENT 27, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions 0, conversions 0, changes 0; the csv identical to
  results/golden_svtests.csv and to the control.
- byteverify against the control (SELFCHECK=1): surelog 0 of 962 (self-check
  961), uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804)
  (evidence/byteverify.txt).
- canaries ok=52 (surelog) and ok=16 (uhdm2rtlil), both ctcan2 checks PASS.
- the trace census: R11U442_TRACE was set for all five stages and the trace
  directory is EMPTY (no law fired on any corpus row, probe case or sv-tests
  row); predicted beforehand by a traced run of law10 over all 4087 probe
  cases with 0 firings (positive control: the same driver on r11u406
  AT/at18 logs two `modDynTdDefNetCopy442` lines).
- binary audit, fence-filtered: surelog 1523 of 1573 records naming law19,
  the other 50 holding only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests
  2346 of 2346; no record names another binary.

Sweep note (law20): the one change after the sweep sits inside
§ modClassTdListing442's branch (the specialization parameters' name
prefix, `prefix + "." + typedef` for the $unit-style bare name), a branch
whose trace line the sweep proves was reached in no stage; law19 against
law20 is byte-identical on all 6046 case dirs of the census list and the grid
but r11u202 CT/c11 (STRICT_NOTEQUAL fullname -> STRICT_EQUAL) and v11u436
VS/vs06 (NOT_EQUAL on both, 56 lines); the probe stage alone was rerun on
law20: EQUAL 4023 + 64, 0/0/0, csv identical to the baseline, trace empty.

### Grid (cases/, 74 case dirs; evidence/grid_law19.txt, drivers/grid.sh)

pristine -> law; every case's first line names its law. R11U442_OFF gives
pristine's bytes and exit code on 74 of 74. Each case's own switch restores
pristine on 68; the other six need a second switch because two laws fire:
AC/ac05 (+ R11U442_UNITALIASVAR_OFF), CE/ce04 (+ R11U442_CLSCHANDLEARR_OFF),
MC/mc09 and mc34 (+ R11U442_MODCLSTD_OFF), mc31 (+
R11U442_UNITCLSTDDIMEND_OFF), MC/mc22 (+ R11U442_MODCLSTD_OFF); each pair
measured on law20 to give pristine's bytes and exit code. Totals: 47 exit 4 -> STRICT_EQUAL, 5 exit 4
-> exit 0 NOT_EQUAL, 4 exit 4 on both (residues), 6 NOT_EQUAL ->
STRICT_EQUAL, 3 STRICT_NOTEQUAL -> STRICT_EQUAL, 6 NOT_EQUAL on both, 3
STRICT_EQUAL controls byte-identical. Upstream slang accepts every case.

    AC/ac01:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  56
    AC/ac02:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  202
    AC/ac03:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  231
    AC/ac04:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  153
    AC/ac05:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  202
    AC/ac06:  rc=0  STRICT_NOTEQUAL  ->  ->    rc=0          STRICT_EQUAL
    AQ/aq01:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  29
    AQ/aq02:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  54
    AQ/aq03:  rc=4  NOT_EQUAL        ->  rc=4  NOT_EQUAL     stage1
    AQ/aq04:  rc=4  NOT_EQUAL        ->  rc=4  NOT_EQUAL     stage1
    AQ/aq05:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  75
    AQ/aq06:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  57
    AQ/aq07:  rc=0  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  52
    CE/ce01:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  6
    CE/ce02:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  16
    CE/ce03:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  6
    CE/ce04:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  10
    CE/ce05:  rc=4  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    CE/ce06:  rc=0  STRICT_EQUAL     ->  ->    rc=0          STRICT_EQUAL
    CH/ch01:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  23
    CH/ch02:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  27
    CH/ch03:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  18
    CH/ch04:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  13
    DQ/dq01:  rc=0  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    DQ/dq02:  rc=0  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  41
    DQ/dq03:  rc=0  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  106
    DQ/dq04:  rc=0  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  63
    DQ/dq05:  rc=0  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    DQ/dq06:  rc=0  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  61
    MC/mc01:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  20
    MC/mc02:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  12
    MC/mc03:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  6
    MC/mc04:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  37
    MC/mc05:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  21
    MC/mc06:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  25
    MC/mc07:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  26
    MC/mc08:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  14
    MC/mc09:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  24
    MC/mc10:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  20
    MC/mc11:  rc=0  STRICT_NOTEQUAL  ->  ->    rc=0          STRICT_EQUAL
    MC/mc12:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  26
    MC/mc13:  rc=4  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    MC/mc14:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  40
    MC/mc15:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  13
    MC/mc16:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  27
    MC/mc17:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  27
    MC/mc18:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  50
    MC/mc19:  rc=4  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    MC/mc20:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  32
    MC/mc21:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  14
    MC/mc22:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  30
    MC/mc23:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  24
    MC/mc24:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  24
    MC/mc25:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  33
    MC/mc26:  rc=4  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    MC/mc27:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  28
    MC/mc28:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  34
    MC/mc29:  rc=0  STRICT_EQUAL     ->  ->    rc=0          STRICT_EQUAL
    MC/mc30:  rc=0  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    MC/mc31:  rc=0  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  34
    MC/mc32:  rc=0  STRICT_EQUAL     ->  ->    rc=0          STRICT_EQUAL
    MC/mc33:  rc=0  STRICT_NOTEQUAL  ->  ->    rc=0          STRICT_EQUAL
    MC/mc34:  rc=4  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    MC/mc35:  rc=0  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    PA/pa01:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  100
    PA/pa02:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  30
    PA/pa03:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  138
    PA/pa04:  rc=4  NOT_EQUAL        ->  rc=4  NOT_EQUAL     stage1
    PA/pa05:  rc=4  NOT_EQUAL        ->  rc=4  NOT_EQUAL     stage1
    UQ/uq01:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  14
    UQ/uq02:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  38
    UQ/uq03:  rc=4  NOT_EQUAL        ->  rc=0  STRICT_EQUAL  72
    UQ/uq04:  rc=0  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1
    UQ/uq05:  rc=0  NOT_EQUAL        ->  rc=0  NOT_EQUAL     stage1


Downstream (evidence/downstream_grid.txt, drivers/dsgrid.sh) on the 29
class-free case dirs (AC, AQ, DQ, PA, UQ): 9 EQUIVALENT -> IDENTICAL, AC/ac04
STATUS_DIFF -> IDENTICAL, 14 IDENTICAL on both, 5 EQUIVALENT on both (aq03,
aq04, dq05, pa04, pa05: the residues); none leaves IDENTICAL.

Determinism (evidence/determinism.txt): three concurrent law19 runs of MC/mc23,
mc25, AQ/aq02, r11u406 AT/at18, AC/ac05 and PA/pa03 read one hash each.

### Earlier-pass census (evidence/earlier_pass_census_law18.txt, earlier_pass_movers_law19.txt)

5972 fence-filtered case dirs (tools/probe r11u4*/v11u4* plus r11u249, r11u245,
v11u245, r11u202, r11u206, r11u293), pristine against law18 (law19 is law18 plus
two trace calls: byte-identical on all 33 movers). Exit codes: 12 change, all 4
-> 0. 33 movers, none further from golden:

- to STRICT_EQUAL: r11u249 M/m01_q, m02_dyn, m03_assoc, N/n04_modlocal; r11u293
  CA/ca08_typedef_ctl (exit 4); r11u402 AA/aa08_mod_wild; r11u406 AT/at18;
  r11u410 AQ/aq05, AQ/aq09 (exit 4); r11u426 AC/ac03 (from STRICT_NOTEQUAL
  type), AC/ac04 (exit 4); v11u402 VE/ve02 (exit 4), VY/vy02_mod_logic_idx;
  v11u410 VU/vu03, VY/vy02 (exit 4); v11u414 VC/vc13, VH/vh04 (exit 4);
  v11u422 VC/vc04; v11u426 VA/va09 (exit 4); v11u440 VN/vn10 (exit 4); and on
  law20 r11u202 CT/c11 (exit 4).
- NOT_EQUAL -> STRICT_NOTEQUAL fullname: v11u406 VA/va12_mod_localparam_bound
  (the module localparam bound's reference naming, 406's residue).
- exit 4 -> exit 0 NOT_EQUAL: v11u410 VU/vu02 (residue 4), v11u436 VS/vs06
  (residue 5).
- NOT_EQUAL on both and closer by dump distance (unsorted / sorted lines):
  v11u426 VA/va01 94/60 -> 62/18, va02 45/45 -> 11/9, va06 60/58 -> 60/18,
  va07 95/49 -> 49/7, va08 98/96 -> 54/12, va10 153/107 -> 101/59 (the elaborated
  alias-clone binding; each still first different at 426's residues); r11u249
  M/m05_two_mods 185/183 -> 84/74 (uhdm-cmp count 17 -> 90 because the first
  instance now matches and the head moved to the second instance, residue 2);
  v11u412 VW/vw03 125/113 -> 122/50 (the head moved later, from the typedef
  `wa_t` to the variable `int b [*][2]`); v11u426 VA/va04 STRICT_NOTEQUAL line on
  both, 47/43 -> 24/20.

A BREAK found and fixed before the sweep: law17's § modDynTdDefNetCopy442
copied a listing whose innermost element is a typedef too, moving r11u406
AY/ay01, ay04, r11u402 AA/aa07 and v11u402 VY/vy08 STRICT_EQUAL ->
STRICT_NOTEQUAL type (golden binds those listings themselves at the net and
the variable); law18 excludes that shape and all four are byte-identical to
pristine again.

### sv-tests targeted runner (evidence/runner_base_open28.csv, runner_law13_open28.csv)

The 28 open rows (27 DIFFERENT, 1 STRICT_NOTEQUAL) on pristine and law13 with
--keep-golden: verdicts identical, the kept databases identical by
path-normalized dump. The 12-row uvm-examples family's heads at the base
(evidence/uvm_messaging_heads_base.txt, the head tracer of
tools/probe/r11u426repro/evidence/tools/cmptrace2.cpp built here against
~/.local's UHDM), uvm_messaging_example, 36 seeded heads: #0 pass 426's face A
(uvm_pool's class-local `this_type`, golden vpiInstance uvm_pkg's TOP view,
ours messaging_pkg); #1 the m_uvm_factory_type_pair_t member's
class_typespec (golden TOP uvm_pkg, ours null); #2 to #4 the radix enum's
uvm_field_flag_t alias naming; #5 to #9 `m_inst_typename_alias_t` locals
(golden an unsupported_typespec, ours the struct_typespec); #10 to #35 one
family: an unsupported_typespec of a foreach loop variable, a body local, an
io_decl or a cast in uvm_pkg code (m_override_info, m_type_overrides,
m_inst_overrides, uvm_deferred_init, process, uvm_hdl_data_t, ...) whose
golden vpiInstance is uvm_pkg where ours is null, many of them in the
wildcard-import clones under messaging_pkg. Not written (see residue 1).

## Residues (ranked; all wrong on pristine too, none moved away)

1. THE 12-ROW UVM-EXAMPLES FAMILY (the largest open sv-tests cluster on this
   ground): the 36 heads above; the decisive family is #10 to #35 (an
   unsupported_typespec in uvm_pkg code Instanced at uvm_pkg when a user
   package imports uvm_pkg), then face A and the struct-member instance; the
   5-row family (generation_seq_persistence, _poly, _randomization,
   many_to_one, test_init) heads at the importing package's variable listing
   (pass 440's reading). Not written: the five corpus UVM rows must stay
   STRICT_EQUAL and none of their designs has a user package importing the
   1800.2 uvm_pkg the same way, so each family needs its own grid first.
2. The second instance of a definition holding a module-body dynamic typedef
   variable (r11u249 M/m05, DQ/dq01, v11u406 VA/va16): ours writes the second
   instance's array_var with an unnamed array_typespec and an element reg
   bound to the listing; golden binds the unaliased copy (the first instance
   now matches).
3. Fixed-array typedef shapes still at exit 4: an alias of an array whose
   ELEMENT is a typedef (r11u426 AC/ac05: golden nests clones of the element
   chain, names `nb_t.nib_t.nib_t`), a package array typedef sized by a
   package parameter or with two dimensions aliased at $unit (PA/pa04,
   pa05: the package listing is not an array_typespec in typedefTs), a $unit
   bounded queue bound naming a $unit parameter (AQ/aq03: golden folds it to
   a UINT with the parameter's int_typespec) and an expression bound
   `[$:P-1]` (aq04: golden keeps the operation in the listing and folds in
   the elaborated copy).
4. An enum-typedef element of a $unit queue (v11u410 VU/vu02, UQ/uq04, uq05):
   golden's element is an unparented aliased copy of the enum listing, ours
   binds the listing (§ arrTdAliasElemClone402 makes no enum clone).
5. A module typedef of a class specialization with value and type arguments
   (v11u436 VS/vs06): golden names the type parameter after the value formal
   (`work@top.ct.p` with the real typespec), the 436 pairing face.
6. A module variable typed by a $unit event typedef (CE/ce05): golden a
   logic_var in the elaborated view plus the definition net's aliased copy,
   ours a named_event.
7. A declaration-only module function body with a dynamic array local
   (MC/mc13, mc34, mc35): golden also lists the element variable in the
   function's variables (Surelog's lone-declaration body quirk; with any
   statement the bodies agree); `'{null, null}` initializer sizes (MC/mc19,
   mc30); a package-scoped class typedef use `p::pc_t g` written as an
   unsupported_typespec in golden (MC/mc26); a generate-block variable of a
   module dynamic typedef (DQ/dq05, its copy not reached).
8. bsg_source_sync_channel_control_slave (its defaulted `"inv"` parameter,
   pass 440's decode), easyUVM, the 3 uvm_scoreboard rows, p733, p737 and tnoc
   (await the user's decision) and the carried lists of passes 440 and
   earlier stand.

## Sister-ground faces (reported, not written)

None new. The checker row's empty system-call argument (ExprEmit) and the
placeholder bodies of bsg_scheduler_dataflow and
bsg_nonsynth_mem_1rw_sync_assoc (ExprEmit, StmtEmit) stand as pass 440
reported them.

## Process

Within the measurement budget: no pristine sweep (the pristine reading is the
master's control /tmp/intr11u440), no pristine build (the main tree's binary
frozen; the worktree's base build read the same md5), intermediate binaries
law1 to law18 on case runs and one targeted runner call only, ONE full
five-stage sweep (law19), the probe stage alone rerun on the final law20.

Slips, none affecting a measurement:
- one uhdm-cmp call ran with its tool variable unset (a shell that had not
  sourced the env file), so the shell tried a cached golden database as a
  script: nothing written (the worktree and main tree checked clean); every
  later call sources the env file, which guards the tools, and run1.sh now
  refuses an unexecutable binary.
- one census command ran `cat` on `ls -d $c/*` with `$c` empty after a failed
  link step (it listed the root directory's entries, all directories): nothing
  read, nothing written.
- the post-sweep binary audit first ran an unfiltered find/grep over my own
  sweep workdir's cmds.txt records (command lines, not sources), touching 10
  records under fenced test names before the fence filter was applied; redone
  fence-filtered (the numbers above). No fenced test was named, dispatched,
  opened or run.
- the sister verifier v11u439's corpus stages (about 18:22 to 18:28) overlapped
  my law14 to law18 builds, grid runs and the earlier-pass census, and its
  sv-tests stage (from 19:09) overlapped my law20 build tail, the law19/law20
  census and the law20 probe-stage rerun; my one full sweep waited for three
  quiet readings and overlapped nothing.
- the fence list was read into a file by a program without printing it.

No other agent's process touched.

## Files

- cases/<GROUP>/<case>/dut.sv — the grid (AC, AQ, CE, CH, DQ, MC, PA, UQ), first
  line `// § <law>`.
- drivers/: run1.sh (one case: golden cached by case text, ours, uhdm-cmp lines,
  strict verdict), grid.sh, switches.txt, gd.sh, ddiff.sh, sdiff.sh, head.sh
  (cmphead), dist.sh, dsgrid.sh, bytecensus2.sh, probe_trace.sh,
  probe_dumpcmp.sh, quiet.sh, fullsweep.sh (adapted from r11u440repro).
- evidence/: grid_law15.txt, grid_law19.txt, downstream_grid.txt,
  determinism.txt, byteverify.txt, earlier_pass_census_law18.txt,
  earlier_pass_movers_law17.txt (before the break fix), earlier_pass_movers_law19.txt,
  runner_base_open28.csv, runner_law13_open28.csv, uvm_messaging_heads_base.txt,
  sweep_law19.log, svtests_law19.log, tools/ (insts.cpp, refs.cpp: typespec
  and ref_typespec listers used to read Instance and alias placement).
