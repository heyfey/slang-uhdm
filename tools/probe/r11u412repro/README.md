# r11u412 — the module/type ground, sv-tests campaign pass 412 (implementer)

Base f90a5af1e (pass 410). Pristine binary = the main tree's build at the base
(md5 90a4636688930e71fba0fbcc9777e82a, frozen copy rebuilt in the worktree,
equal). Pristine reading = the master's control sweep /tmp/intr11u410 (its
csvs equal the committed results/*.csv). Ground: src/TypeEmit.cpp,
src/ModuleEmit.cpp, src/UhdmExporter.cpp, src/TaskFuncEmit.cpp (uhdm_main.cpp,
include/ and the sister's four files untouched).

Every law reads through src/LawSwitch.h: `lawOn(412, "R11U412_<LAW>_OFF")`,
`R11U412_OFF` drops the whole pass, `R11U412_TRACE=<dir>` logs each firing
through `lawTrace(412, ...)`. No src/R*.h, no LawState.h section, no getenv.

## Goal 1

Census of the 75 SURELOG_ONLY rows of results/golden_svtests.csv at the base,
by message: every detail is an upstream slang front-end diagnostic
(`error: ...` with a source location: the should_fail tests, the hdlconvertor
and utd-sv redefinitions/unknown modules, the five basejump clock-gen
time-scale rows, uvm_pkg's own diagnostic); none is an exporter `unsupported
constructs` message, none is on this ground. No BOTH_REJECT or SLANG_CRASH row
carries an exporter message either. The probe-only goal-1 faces carried from
pass 410 (VY/vy02 a typedef of a cloned associative typedef, VU/vu02 a queue
typedef of a real typedef, AQ/aq09 a parameter-bounded queue typedef: all
still `typedef target: ...` exit 4 on pristine and on this pass) were decoded
for aq09 (golden: the bound is a ref_obj `P`, full name `work@top.q_t.P`, no
actual, the typedef listed in both views) but not written: residue.

## Laws (23, every § name412, one switch each)

| law | file | switch | statement |
|---|---|---|---|
| § bitSignedElabVar412 | TypeEmit | R11U412_BITSIGNED_OFF | a `bit signed` variable written with the keyword is a bit_var with vpiSigned in the elaborated listing (`var bit signed` and typedef'd bit abstain) |
| § assocWildcardIdxRefTs412 | TypeEmit | R11U412_WILDCARDIDX_OFF | `int arr [*];` — the instance-level array_typespec carries an index ref_typespec with no actual |
| § extScopedParamBaseName412 | UhdmExporter | R11U412_EXTSCOPEDPARAM_OFF | `extends Package::Bar #(x,y,z)` names the base class_typespec `Package::Bar` |
| § unitParamBasedLitFold412 | UhdmExporter | R11U412_UNITLITFOLD_OFF | a $unit parameter's `1'B0` decompiles `1'b0` (the ONE_TICK token), a signed binary literal with its top bit set folds to INT (int -1, other types unsigned) |
| § unpStructArrElemVar412 | TypeEmit | R11U412_UNPSTRUCTELEM_OFF | the element reg of a module array of an unpacked struct is a struct_var |
| § classTdRetVarAtTypeToken412 | TaskFuncEmit | R11U412_CLSTDRETLOC_OFF | a return typed by a class typedef of a scalar/atom kind: the return var at the written return type |
| § tdAtomRetAliasTwin412 | TaskFuncEmit | R11U412_RETALIASTWIN_OFF | a return typed by a class/module typedef of an atom/string/real/time kind binds, once per function, a typedef-aliased twin typespec |
| § oobScopedClsTdRetUnsup412 | TaskFuncEmit | R11U412_OOBSCOPEDRET_OFF | a $unit class's out-of-body `function C::T C::f()` binds an unsupported_typespec `C::T` at `C::` |
| § builtinMailboxSpecBare412 | TypeEmit | R11U412_MAILBOXSPEC_OFF | `mailbox #(string) m;` — the builtin mailbox class_typespec spans the name, no specialization listing |
| § enumRangedMemberSurelogVal412 | TypeEmit | R11U412_ENUMRANGED_OFF | a ranged enum member `step[10]` is one enum_const named `step`; unwritten members take Surelog's counter (typedef: explicit values reset it; inline enum: the index) |
| § enumXzReplInitZero412 | TypeEmit | R11U412_ENUMXZREPL_OFF | `b={32{1'bx}}` — INT:0 at 64 bits, decompile `{32{{1'bX}}}` |
| § modNettypeTypedef412 | TypeEmit + UhdmExporter | R11U412_MODNETTYPE_OFF | a module-body `nettype real n [with f];` is a module typedef in both views, vpiFunction bound design-final |
| § tfDeclOnlyBodyBegin412 | TaskFuncEmit | R11U412_DECLONLYBODY_OFF | a declaration-only block-item body: 2+ items -> synthesized begin at the 2nd item holding the locals; 1 item (task / void function) -> locals listed twice |
| § genericIfacePosConnNoDouble412 | ModuleEmit | R11U412_GENPOSNODBL_OFF | an interface handed POSITIONALLY to an unbound generic port lists its variables once |
| § elabVarSysCallInit412 | ModuleEmit | R11U412_VARSYSCALL_OFF | an argument-less system call initializer (`= $random()`) is the elaborated var's vpiExpr |
| § classKwParamsLast412 | UhdmExporter | R11U412_CLSKWPARAMLAST_OFF | class parameters written without `parameter`/`localparam` list before the keyword ones (Parameters and Param_assigns) |
| § propLocalVarListed412 | ModuleEmit | R11U412_PROPLOCALVAR_OFF | a property's local variable is listed under the property_decl, parented at an unlisted blocking assignment |
| § assocClassIdxNet412 | TypeEmit + ModuleEmit | R11U412_ASSOCCLASSIDX_OFF | `int arr [ C ];` — index class_typespec `C`, and the definition mints an implicit wire `C` |
| § modKwlessTypeParamDropped412 | UhdmExporter | R11U412_KWLESSTP_OFF | a module header's keyword-less `type T = ...` is no parameter of the module (design-final filter) |
| § interconnectNetNone412 | TypeEmit + ModuleEmit | R11U412_INTERCONNECT_OFF | `interconnect bus;` — vpiNetType 12, the implicit typespec zero-width at the declarator (or the packed dims) |
| § importFnNameFirstWins412 | ModuleEmit | R11U412_IMPFNNAME_OFF | two wildcard-imported packages' FREE functions of one name: the earlier import's is listed, the later one drops |
| § udpSeqStarTwoSpaces412 | UhdmExporter | R11U412_UDPSTAR_OFF | a sequential UDP row's `*` edge is written `*  ` |
| § udpInitTickValEmpty412 | UhdmExporter | R11U412_UDPINITTICK_OFF | a UDP `initial q = 1'b1;` value is `UINT:@@BAD_SYMBOL@@`, no decompile |

Each law has its own switch (23 names, 23 switches; the two-file laws use one
switch in both files).

## Cases (tools/probe/r11u412repro/cases, first line names the law)

AC ac01-02 § assocClassIdxNet412; BS bs01-06 § bitSignedElabVar412; CP cp01-03
§ classKwParamsLast412; EP ep01-03 § extScopedParamBaseName412; ER er01-06
§ enumRangedMemberSurelogVal412, er07 § enumXzReplInitZero412; GI gi01-06
§ genericIfacePosConnNoDouble412; IC ic01-02 § interconnectNetNone412; IF
if01-02 § importFnNameFirstWins412; MB mb01-03 § builtinMailboxSpecBare412;
NT nt01-03 § modNettypeTypedef412; OR or01-03 § oobScopedClsTdRetUnsup412,
or04 § classTdRetVarAtTypeToken412, or05 § tdAtomRetAliasTwin412; PL pl01-02
§ propLocalVarListed412; TB tb01-04 § tfDeclOnlyBodyBegin412; TP tp01-03
§ modKwlessTypeParamDropped412; UD ud01 § udpSeqStarTwoSpaces412, ud02
§ udpInitTickValEmpty412; UP up01-07 § unitParamBasedLitFold412; US us01-04
§ unpStructArrElemVar412; VI vi01 § elabVarSysCallInit412; WI wi01-03
§ assocWildcardIdxRefTs412.

Drivers: drivers/run1.sh (Surelog -parse -nobuiltin vs ours --nobuiltin, cmp
line count + strictcmp + md5), drivers/run1b.sh (builtin classes on both
sides; MB and AC), drivers/grid.sh <law> <pristine> (the evidence grid:
pristine, law, R11U412_OFF == pristine, own switch == pristine),
drivers/one.sh (rerun a control sv-tests row with a binary), drivers/dd.sh,
ddiff.sh, ddiffb.sh (normalized dump diffs). Evidence under evidence/.


## Measurements

### Binaries
pristine 90a4636688930e71fba0fbcc9777e82a (= main tree build at the base);
final law binary a29f6b4c554369ce3a75752906467e7a (/tmp/r11u412_bin/final,
links slang 12.0.0+545f88b2e).

### The sweep (tests/sweep.sh --jobs 3 from the worktree, corpus stages;
sv-tests stage through the main tree's scripts/check_svtests.py read-only with
--baseline the worktree's results/golden_svtests.csv, a worktree has no UVM
tree), R11U412_TRACE set — evidence/sweep_corpus.log, sweep_svtests.log
- probe: EQUAL 4018 STRICT_NOTEQUAL 69 of 4087, regressions=0 conversions=0
  changes=0; probe.csv identical to the control's.
- surelog: default CMP_EQUAL 480 + 0, testflags 474 + 0 (Tnoc d/t CMP_NOTEQUAL
  standing), regressions=0 conversions=0 changes=0; csv identical to the
  control except the two LowMem log-path detail texts.
- uhdm2rtlil: 803/1/67 both modes, 0/0/0; csv identical.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  not identical and not excused 0; csv identical.
- sv-tests: EQUAL 1666 -> 1696, DIFFERENT 253 -> 223, STRICT_NOTEQUAL 21,
  BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1
  of 2346; regressions=0 conversions=30 changes=0.
- byteverify (SELFCHECK=1) against the master's control /tmp/intr11u410:
  surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805 movers.
- canaries: canaries.sh ok=52 (surelog) and ok=16 (uhdm2rtlil), changed 0;
  ctcan2 surelog ok=58 unknown=1 PASS, uhdm2rtlil ok=2 unknown=6 PASS.
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the final
  binary, 0 another, 50 hold no slang line; uhdm2rtlil 1742 of 1742; sv-tests
  2346 of 2346.
- trace census (evidence/trace_census.txt): probe 2 firings of
  § genericIfacePosConnNoDouble412 (r10imex_repro t2, t4: the positional-port
  branch taken where the instance has no variable to un-double; both
  databases byte-identical on pristine and final), surelog 18 firings of
  § builtinMailboxSpecBare412 (the UVM rows' `mailbox #(uvm_phase)`
  declarations, 0 byte movers: their span and listing were already golden's),
  uhdm2rtlil and downstream 0; sv-tests 193 rows fire.
- sv-tests away census: of the 161 firing rows not EQUAL, 156 have a
  normalized dump identical to the control's (the UVM mailbox firings); the 5
  that move (evidence/svtests_away.txt): p203 130 -> 104, p600 154 -> 150,
  p737 159 -> 145, p884 133 -> 125 dump lines to golden, and
  chapter-16/16.10--property-local-var-uvm, whose only change is the
  property's local variable listing golden has (3 occurrences of the
  `int_var (x)` record in golden and in ours, 0 before; the line count over
  the 1.1M-line dumps grows by diff alignment only). 0 away.

PROCESS NOTE (over budget by one sweep): the first full sweep ran on an
earlier law binary (ba252b66.../58f168d9..., /tmp/r11u412_lwd) and read 6 probe
and 9 surelog regressions (BuildUVMPkg, MiniAmiq, Scoreboard, SeqDriver,
SimpleUVM; differ:name(2) / CMP_NOTEQUAL) plus 8 sv-tests CHANGEs on the
uvm_classes_2 rows: § classTdRetVarAtTypeToken412 and § tdAtomRetAliasTwin412
fired on a TYPE PARAMETER return (slang models `type T` as a class
TypeAliasType; probe r10uvm52repro/a1 c3_typeparam), and
§ importFnNameFirstWins412 dropped a class method's out-of-body definition
(`uvm_pkg::uvm_root::run_test`) sharing a free function's name.  Both were
narrowed (a typedef declaration only; free `pkg::f` functions only), the 6
probe cases and the 5 UVM rows re-measured CMP_EQUAL/STRICT_EQUAL with the
fixed binary by targeted runs, and the full five-stage sweep was rerun once on
the final binary (the numbers above).

### Grid (evidence/grid.txt; drivers/grid.sh final pristine)
68 case dirs in 19 groups. Pristine -> final: 34 cases NOT_EQUAL ->
STRICT_EQUAL; the 5 pristine-STRICT_EQUAL controls (cp02, gi03, gi04, if02,
mb02) keep pristine's bytes; of the 29 still not equal, 24 move toward golden
by dump lines (evidence/away.txt, 0 away) and 5 keep pristine's bytes as the
abstaining controls (bs06 an array element var, gi05 a named generic
connection, up03 and up06 the sister's module-parameter and expression
`1'B0`, us04 an inline unpacked-struct variable); every exit code 0 on both.
R11U412_OFF gives pristine's bytes and exit code on 68 of 68; each case's own
switch on 61 — the 7 others carry a second law of this pass: or01, or02, or04,
or05 (the return trio § classTdRetVarAtTypeToken412 /
§ tdAtomRetAliasTwin412 / § oobScopedClsTdRetUnsup412), ud01 and ud02 (the
two UDP laws), wi03 (its void function's single declaration takes
§ tfDeclOnlyBodyBegin412).

## sv-tests rows converted (30, all DIFFERENT -> EQUAL), by law
(evidence/conversions_by_law.txt)
- § builtinMailboxSpecBare412: chapter-15/15.4--mailbox-blocking.sv,
  15.4--mailbox-non-blocking.sv
- § propLocalVarListed412: chapter-16/16.10--property-local-var.sv,
  16.10--property-local-var-fail.sv
- § unpStructArrElemVar412: chapter-5/5.10-structure-arrays.sv
- § enumXzReplInitZero412: chapter-6/6.19--enum_xx.sv
- § enumRangedMemberSurelogVal412: chapter-6/6.19.2--enum_sequence.sv,
  6.19.2--enum_sequence_range.sv
- § modKwlessTypeParamDropped412: chapter-6/6.20.3--parameter_type.sv
- § modNettypeTypedef412: chapter-6/6.6.7--nettype.sv,
  6.6.7--nettype_resolution_fn.sv
- § interconnectNetNone412: chapter-6/6.6.8--interconnect.sv,
  generated/hdlconv_std2017/hdlconvertor_std2017_p718.sv
- § assocClassIdxNet412: chapter-7/arrays/associative/class.sv
- § assocWildcardIdxRefTs412: chapter-7/arrays/associative/wildcard.sv
- § classTdRetVarAtTypeToken412 + § tdAtomRetAliasTwin412 +
  § oobScopedClsTdRetUnsup412: hdlconvertor_std2012_p154_1.sv,
  hdlconvertor_std2017_p190.sv
- § tfDeclOnlyBodyBegin412: hdlconvertor_std2012_p90.sv,
  hdlconvertor_std2017_p126.sv, generic/member/class_member_test_27.sv
- § classKwParamsLast412: hdlconvertor_std2017_p174.sv
- § genericIfacePosConnNoDouble412: hdlconvertor_std2017_p761.sv; with
  § elabVarSysCallInit412: hdlconvertor_std2017_p762.sv
- § importFnNameFirstWins412: hdlconvertor_std2017_p780.sv
- § udpSeqStarTwoSpaces412 + § udpInitTickValEmpty412: hdlconvertor_std2017_p835.sv
- § bitSignedElabVar412: generated/integers/6.11--integer_signed_bit.sv
- § extScopedParamBaseName412: generic/class/class_test_19.sv, class_test_21.sv
- § unitParamBasedLitFold412: generic/number/number_test_7.sv, number_test_15.sv

## Residues (ranked; all wrong on pristine too, none moved away)
1. About 143 UVM rows (chapter-18 and the uvm tier): head at the sister's
   ParamEmit module copy of `UVM_ALL_ON` (`parameter (UVM_ALL_ON) >
   ref_typespec > bit_typespec(uvm_field_flag_t)` vs our int_typespec).
2. hdlconvertor p203: a $unit generic class specialized at module scope
   `C#(1, real) v2`: golden spans `C` alone and pairs the first written
   argument with the formal `p` as a type_parameter (golden's own bug);
   p884: an unnamed UDP instance named `work@posdff_udp` and an implicit wire
   `enable`; chapter-5/5.10-structure-replication (an inline unpacked-struct
   module variable with an initializer is a struct_var in the elaborated
   view, ours a struct_net; US us04).
3. chapter-8/8.8--typed_constructor(_param): `test_cls::new` mints an
   implicit wire `test_cls` passed as the new call's argument (ExprEmit).
4. chapter-6/6.12--realtime (time_typespec/time_var over three sites).
5. Probe-only: module type parameter USES after § modKwlessTypeParamDropped412
   (golden unsupported_typespec + logic_net, TP tp02/tp03); the longint
   signed-literal 64-bit BIN quirk (UP up07); an array element bit_var's
   signing (BS bs06); class string/real/enum typedefs not listed in the class
   (OR or04, ER er06); a reference to an expanded ranged enum member `S1`
   (golden an implicit net, ER er05); a single initialised declaration body
   (TB tb03 t3, golden an assignment statement); a non-void function's
   multi-declarator single item (TB tb02 f2); nets of a nettype (NT nt03);
   a packed interconnect net in the elaborated view (IC ic02); a wildcard
   associative in packages, interfaces, generate blocks and functions
   (WI wi03); mixed `[K][2]` / `[*][2]` associative ranges (AC ac02, WI wi02);
   the goal-1 faces aq09 (decoded: the bound a ref_obj `P`), vy02, vu02.

## Sister-ground faces (reported, not written)
- ExprEmit / ParamEmit: `1'B0`, `1'B1`, `1'Bx` are Surelog's ONE_TICK tokens
  and decompile `1'b0`, `1'b1`, `1'bX` in every expression and module
  parameter (UP up03, up06; the $unit parameter half is this pass's law).
- ParamEmit: the module type parameter written without `parameter` is not
  emitted by Surelog at all; this pass filters the listing design-final in
  UhdmExporter (§ modKwlessTypeParamDropped412) — the parameter emitter could
  skip it at the source and write its uses as unsupported_typespec.
- ExprEmit: `cls::new` (8.8) as an implicit-wire argument; the (i)'(x) genvar
  cast exit 4 (VP/vp05, carried).
- ParamEmit: the UVM_ALL_ON module copy (residue 1).

## Process
No other agent's process touched; the sister's verifier sweep was waited out
by its PID before each of this pass's sweeps; a Monitor wait loop whose pgrep
pattern could self-match was stopped by task id before it ran a check.
No fenced test named, opened or run (the binary audit filtered on the fence
regex before reading any cmds.txt; this directory scanned clean).
