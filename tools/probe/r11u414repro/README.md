# r11u414 — the module/type ground, sv-tests campaign pass 414 (implementer)

Base b94cdc046 (pass 412). Pristine binary = the main tree's build at the base
(md5 42190a8e4437a04efe2664fc6287574c; the worktree's pristine build is
byte-identical, frozen at /tmp/r11u414_bin/pristine). Pristine reading = the
master's control sweep /tmp/intr11u412 (its csvs equal the committed
results/*.csv). Ground: src/TypeEmit.cpp, src/ModuleEmit.cpp,
src/UhdmExporter.cpp, src/TaskFuncEmit.cpp (uhdm_main.cpp, include/ and the
sister's four files untouched).

Every law reads through src/LawSwitch.h: `lawOn(414, "R11U414_<LAW>_OFF")`,
`R11U414_OFF` drops the whole pass, `R11U414_TRACE=<dir>` logs each firing
through `lawTrace(414, ...)`. No src/R*.h, no LawState.h section, no getenv,
no reader function.

## Goal 1

Census of results/golden_svtests.csv at the base: 75 SURELOG_ONLY, 303
BOTH_REJECT, 0 SLANG_CRASH. Every SURELOG_ONLY detail is an upstream slang
front-end diagnostic (`<file>:<line>:<col>: error: ...`): none is an exporter
`unsupported constructs` message (grep of the detail column for `unsupported`
and `typedef target` reads 0), so no row on this ground (or the sister's) is
stuck at an exporter error. The probe-only exit-4 shapes carried from pass 410
(VY/vy02, VU/vu02, AQ/aq09) were not reached by this pass (residue).

## Laws (12, every § name414, one switch each)

| law | file | switch | statement |
|---|---|---|---|
| § varInitUintMask414 | ModuleEmit | R11U414_VARINITMASK_OFF | a bare-decimal UINT initializer of an integral variable (`logic a = 3;` -> UINT:1, `byte a = 300` -> 44) or a net declaration assignment (`wire a = 3;`, `reg r = 2;`) is masked to the target width, value and decompile: CompileHelper::adjustSize's UINT branch; a based literal keeps its value |
| § classArrElemVar414 | TypeEmit | R11U414_CLASSARRELEM_OFF | the element reg of a module-scope fixed array of class handles (`base_cls arr[3];`) is a class_var whose class_typespec keeps no parent (it fell to logic_var) |
| § classChandlePropNoTs414 | UhdmExporter | R11U414_CHANDLEPROP_OFF | a `chandle` class property is a chandle_var with no typespec (makeVar_'s paChandle_type fallback) |
| § classWildcardIdxRefTs414 | UhdmExporter | R11U414_CLSWILDCARDIDX_OFF | a wildcard associative class property (`Packet p [*];`) carries an index ref_typespec with no actual, the class half of § assocWildcardIdxRefTs412 |
| § unitFwdTypedefTwin414 | UhdmExporter | R11U414_FWDTDTWIN_OFF | the FIRST bare `$unit` forward typedef (`typedef t;`, before or after its definition; `typedef class` / `typedef enum` never count) lists a deep clone of `t`'s listing object named `t` with a Typedef_alias to it, ahead of the name-sorted design listing; later forward typedefs add nothing listed |
| § clsTdArgAliasTwin414 | TaskFuncEmit | R11U414_ARGALIASTWIN_OFF | a formal typed by a class- or module-scope typedef of an integer atom, scalar bit, string, real or time kind binds an unparented twin at the formal's type token, named like the typedef, Typedef_alias to the typedef's object; package / $unit typedefs and typedefs of a type parameter or another typedef abstain |
| § ifaceClsScopedArgUnsup414 | TaskFuncEmit | R11U414_IFCLSARG_OFF | a formal or return written `ic::T` with `ic` an interface class binds an unsupported_typespec named `ic::T`, spanned at `ic::` (the whole type when a direction keyword is written on a formal) |
| § realtimeVarIsTime414 | TypeEmit + ModuleEmit | R11U414_REALTIME_OFF | `realtime` is Surelog's time_typespec (makeTypespec and the array element typespec) and a realtime module variable / array element / class property a time_var; the elaborated module variable binds a fresh time_typespec at the data type |
| § structMemberDefault414 | TypeEmit | R11U414_MEMBERDEFAULT_OFF | an unpacked struct member written with a literal default (`int a = 3;`, `8'hAB`) carries it as vpiDefaultValue and spans through the default |
| § arrStringInitAtElem414 | TypeEmit | R11U414_ARRSTRINIT_OFF | a string literal initializing an unpacked byte array (`byte b[3:0] = "hi2";`) is the string constant parented at the element reg, sized at the element width, referenced by the array_var and the reg |
| § classPropBinOpInit414 | UhdmExporter | R11U414_CLSPROPBINOP_OFF | a binary-operation initializer of a scalar integral class property rides the variable unfolded, its direct bare-decimal operands at the property width (the module § varInitOpCastKept404 shape) |
| § structRandMemberVoid414 | TypeEmit | R11U414_RANDMEMBER_OFF | a struct member written with `rand`/`randc` is Surelog's unnamed member: span at the written type, reference named after the struct, bound to a void_typespec from the qualifier through the type, vpiRefFile only |

## Cases (tools/probe/r11u414repro/cases; each case's first line names its law)

Drivers: drivers/run1.sh (golden cached per case text under
/tmp/r11u414_scr/gold, ours, uhdm-cmp line count, uhdm-strictcmp verdict),
drivers/grid.sh <law> <pristine> (pristine, law, R11U414_OFF and the group's
own switch against pristine's bytes and exit code), drivers/ddiff.sh
(normalized dump diff), drivers/offrun.sh. The grid lines are
evidence/grid.txt.

- VM/vm01-vm08 — § varInitUintMask414 (vm06 a procedural-local control,
  vm07 `reg r = 2` keeps the pass-402 net-kind residue vpiNetType 36)
- CA/ca01-ca05 — § classArrElemVar414
- CH/ch01-ch03 — § classChandlePropNoTs414
- WC/wc01-wc04 — § classWildcardIdxRefTs414 (wc04 the non-wildcard control)
- FT/ft01-ft11 — § unitFwdTypedefTwin414 (ft05 the class/enum forward
  control; ft02 and ft08 residues)
- TA/ta01-ta08 — § clsTdArgAliasTwin414 (ta07 the package/$unit control,
  ta08 the type-parameter abstention; ta03, ta04, ta05 residues)
- IT/it01-it03 — § ifaceClsScopedArgUnsup414
- RT/rt01-rt05 — § realtimeVarIsTime414 (rt03 a sister-ground residue)
- SD/sd01-sd04 — § structMemberDefault414 (sd01, sd02 residues)
- AI/ai01-ai03 — § arrStringInitAtElem414
- CI/ci01-ci03 — § classPropBinOpInit414
- RM/rm01-rm03 — § structRandMemberVoid414 (rm02 a residue)

## Grid (evidence/grid.txt; pristine -> law, every exit 0)

60 case dirs in 12 groups (corrected by the verifier v11u414 from 62 and 47; the
grid has 60 lines). 45 NOT_EQUAL -> STRICT_EQUAL; 3 STRICT_EQUAL
controls with pristine's bytes (FT/ft05, TA/ta07, WC/wc04) and 1 procedural
control (VM/vm06); 11 NOT_EQUAL on both. `R11U414_OFF` restores pristine's
bytes and exit code on 60 of 60, each group's own switch on 60 of 60. No case
leaves an equal status. Away census on the 11 still unequal (normalized dump
lines to golden, pristine -> law): SD/sd02 18 -> 6, TA/ta04 54 -> 22, RM/rm02
39 -> 0 (uhdm-cmp still reads golden's default `unsupported_expr` the dump
does not print), FT/ft02 26 -> 11, RT/rt03 46 -> 16, TA/ta03 40 -> 17, TA/ta05
54 -> 44, VM/vm07 13 -> 1, SD/sd01 22 -> 22 (same bytes), FT/ft08 and TA/ta08
at pristine's bytes: 0 away. The uhdm-cmp line count grows on SD/sd02 (15 ->
41) and TA/ta04 (17 -> 29) because the first difference moves later in the
walk (sd02: `int a = 3` now matches, the head is the `1 + 2` default; ta04:
the prototype formals now match, the head is the out-of-body definition's
`C::g.a` reference naming, the sister's ExprEmit).

Downstream (scripts/downstream_uhdm2rtlil.py `one()`, class-free cases, both
binaries): VM vm01-vm05, vm07, vm08, AI ai01-ai03, RT rt01, rt02, FT ft01,
ft04, ft06, SD sd03 IDENTICAL on both; RT/rt05 EQUIVALENT -> IDENTICAL; none
worse (evidence/downstream_cases.txt).


## The sweep (one full five-stage sweep on the final law binary)

Law binary md5 8a94273621ee38e1d6dda1fc9f6c4018 (frozen /tmp/r11u414_bin/law),
pristine 42190a8e4437a04efe2664fc6287574c. The four corpus stages ran as
`tests/sweep.sh --jobs 3 --workdir /tmp/r11u414_sw --corpus "probe surelog
uhdm2rtlil downstream"` from the worktree; the sv-tests stage through the main
tree's scripts/check_svtests.py read-only (a worktree has no UVM tree) with the
worktree's results/golden_svtests.csv as baseline, after the sister pass
r11u411's own sv-tests stage had ended (waited by its PID). `R11U414_TRACE` was
set for the whole sweep.

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0 conversions=0
  changes=0; the csv identical to the control /tmp/intr11u412/probe.csv.
- surelog: default 480 CMP_EQUAL, testflags 474, regressions=0 conversions=0
  changes=0; the csv differs from the control only in the two LowMem
  log-path detail texts; Tnoc d/t CMP_NOTEQUAL standing.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; csv identical to the control.
- downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT,
  not identical and not excused 0; csv identical to the control.
- byteverify against the control (SELFCHECK=1, same-length roots): surelog 0
  of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805 (evidence/byteverify.txt).
- canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); both
  ctcan2 checks PASS.
- binary audit (fence-filtered cmds.txt): surelog 1523 of 1573 name the law
  binary, 50 hold no slang line, 0 another; uhdm2rtlil 1742 of 1742; sv-tests
  2346 of 2346.
- sv-tests: regressions=0 conversions=12 changes=0; EQUAL 1698 -> 1710,
  STRICT_NOTEQUAL 96, DIFFERENT 146 -> 134, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346.

### The 12 conversions, DIFFERENT -> EQUAL (fresh csv rows `<case>,EQUAL,,equal`)

| row | law |
|---|---|
| chapter-10/10.4.1--blocking-assignment.sv | § varInitUintMask414 |
| chapter-5/5.9-string-word-assignment.sv | § arrStringInitAtElem414 |
| chapter-6/6.12--realtime.sv | § realtimeVarIsTime414 |
| chapter-8/8.22--dynamic_method_lookup.sv | § classArrElemVar414 |
| chapter-8/8.26.3--type_access_implements.sv | § ifaceClsScopedArgUnsup414 |
| generated/hdlconv_std2012/hdlconvertor_std2012_p148.sv | § classPropBinOpInit414 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p184.sv | § classPropBinOpInit414 |
| generic/class/class_test_55.sv | § classWildcardIdxRefTs414 |
| generic/member/class_member_test_12.sv | § classChandlePropNoTs414 |
| generic/member/class_member_test_9.sv | § clsTdArgAliasTwin414 |
| generic/typedef/typedef_test_0.sv | § unitFwdTypedefTwin414 |
| generic/typedef/typedef_test_18.sv | § structRandMemberVoid414 |

### Movers and census

- Prediction before the sweep, by name: a fence-filtered grep of the corpus
  and probe sources (19739 files) for the shapes found `realtime` declarations
  only in Tnoc's tvip interfaces (Tnoc d/t CMP_NOTEQUAL; predicted a possible
  byte mover), class wildcard associatives only in UnitForeach (SLANG_REJECT)
  and an interface (r10v225 v2_mixed, not a class), chandle class properties
  in none (Chandle and the probe chandles are module variables and function
  locals), bare forward typedefs in no corpus row; a traced run of the law
  binary on uvm_pkg.sv alone showed the formal twin firing on uvm_imps.svh's
  `typedef IMP this_imp_type` formals (a typedef of a type parameter, the
  § classTypeParamTdGroupLastWins33c group), so the law was narrowed to
  typedefs of a non-alias type before the sweep (TA/ta08); the narrowed law
  fires nowhere in uvm_pkg.
- Trace census of the sweep: 0 firings in the probe, surelog, uhdm2rtlil and
  downstream stages; 12 sv-tests rows fire, exactly the 12 conversions
  (evidence/trace_census_svtests.txt). The realtime typespec sites in
  TypeEmit's makeTypespec carry no trace; the byte checks cover them: 0 corpus
  movers (Tnoc included), and on sv-tests the 251 databases both sweeps keep
  read identical normalized dumps on 250 (evidence/
  svtests_dump_compare_vs_control.txt) with generated/tnoc/tnoc.sv the one
  reading DIFF, an artefact of the 900 s dump timeout on its 887 MB dump:
  uhdm-cmp reads the law's and the control's tnoc databases equal (rc 0, 0 lines), no law fires on the row (trace), and none of its 47 :files: declares `realtime` (the one untraced site), so it is not a mover; a full untruncated dump of each side was stopped after 40 minutes.
- Away census: every firing row converted to EQUAL; no other sv-tests row
  moved; 0 away.

## Residues (ranked; all wrong on pristine too, none moved away)

1. About 65 UVM rows (chapter-16, chapter-18, the uvm tiers, testbenches)
   still DIFFERENT, headed on the sister's ground (module copies of imported
   parameters, macro-built expression spans) and the package / class listing
   orders; not reached.
2. The basejump rows (27 still DIFFERENT): first differences are expression
   decompiles of macro-built bounds (`(i+1)` ref_obj names, `$clog2` /
   `$bits` folds, indexed part-select widths: ExprEmit), the seven
   undefaulted definitions (§ undefaultedDefInvalidInst404's skips) and
   uninstantiated interfaces; not reached.
3. chapter-7/structures/unpacked/default-value.sv: the member default `= c`
   (a parameter) is folded `4'h5` in one of golden's two struct_typespec
   objects and an unbound ref_obj `c` in the other, where ours shares one
   object (SD/sd01); and non-literal defaults (`1 + 2`, SD/sd02).
4. hdlconvertor p827: `trireg (large) #(0,0,50) cap1;` is dropped by
   § caNetDeclStrengthDropped90 as golden drops it, but a gate terminal
   reference then mints golden's implicit wire (definition view at the last
   reference 7:60, elaborated at the first 5:13) and binds the references;
   ours mints nothing (ModuleEmit implicit-net emission).
5. Formal twins not reached: a class string typedef (TA/ta03: golden also
   lists the typedef in the class, pass 412's OR/or04), a class enum typedef
   (ta05), a typedef of a type parameter or of a typedef (ta08), out-of-body
   definitions' formals (ta04, golden unsupported_typespec per formal).
6. Forward typedefs: a forward typedef after its definition with none before
   leaves golden one more unlisted twin (FT/ft02); package and module scope
   forward typedefs (ft08).
7. realtime function locals and returns are golden logic_var (RT/rt03):
   EmitHelpers.h makeReturnVar and StmtEmit's local variables (sister ground).
8. A module-scope struct with a `rand` member: golden's default is an
   unsupported_expr holding the member's source line (RM/rm02).
9. `reg r = 2;` keeps vpiNetType 36 where golden has none (VM/vm07, pass
   402's net-kind residue).
10. typedef_test_9 ($unit unpacked typedef bounds `[k:0][j:0]` folded to the
    parameters' values with their typespec), class_test_49 (`parameter reg P
    = '1` typespec, `f(glb::arr[N])`), p179, p193_2, p203, p130, p88/p124,
    p292, p489, p488, p537, p599, p600, p719, p733, p737, p765, p770, p791,
    p884, scr1, fx68k, tnoc, utd-sv primitives, easyUVM: not decoded this pass.

## Sister-ground faces (reported, not written)

- ExprEmit / StmtEmit: chapter-8/8.12--shallow_copy.sv `test_obj1 = new
  test_obj0;` (golden's Lhs ref_obj parented at an unlisted hier_path, no
  actual); chapter-7/queues/delete_assign.sv `q = {};` (golden an array_var
  with an array_typespec, ours operation 33); the reference naming inside an
  out-of-body method body (`C::f.p`, p193_2, TA/ta04); the 8.8 typed
  constructor's implicit wire (carried).
- EmitHelpers.h makeReturnVar / StmtEmit: realtime returns and locals are
  logic_var with a time_typespec in golden (RT/rt03; this pass already gives
  them the time_typespec through TypeEmit's makeTypespec).
- ParamEmit: class_test_49's `parameter reg P = '1` typespec (golden
  logic_typespec at `reg`); the basejump macro-built expression heads.

## Process

One full sweep, on the final binary. The intermediate binaries (law1 to
law11) got only the grid runs and one targeted runner call on the 81 non-UVM
DIFFERENT rows (/tmp/r11u414_lw9, law9), plus one traced uvm_pkg.sv run on
law10 and law11. The sweep's sv-tests stage waited for the sister r11u411's
sv-tests stage to end (its PID, never touched). No other agent's process
touched; no pristine sweep, no pristine build beyond the worktree's own
(byte-identical to the main tree's). The fence list read into a file without
printing; every tree-wide list (corpus grep, cmds.txt audit, trace census)
filtered on it first; no fenced test named, opened or run. The README word
rule: one added comment reworded before the final build.

