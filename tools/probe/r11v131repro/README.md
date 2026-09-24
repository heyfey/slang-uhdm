# r11v131 — adversarial verification of r11u131 (the expression/parameter ground of the strict axis)

Base `4e17c7ee` (branch matrix-1.87). Implementer's patch `r11u131.patch` (md5 `3f27a0cd…`) applied
clean on a fresh worktree; the pristine worktree is the bare base. System-deps config, `-j 2`.

VERDICT: **ACCEPT-WITH-FIX**. Every headline number of the implementer reproduces bit for bit; eight of
the nine laws survived every fresh instance; § paramIdxPartSelWholeSpan131 and § pkgQualCallQualSpan131
over-fire inside a CALL ARGUMENT and a conditional's THEN operand (three judge-equal cases move a strict
cell away from golden). The fix, § constCtxCallArgInner131v (switch `R11V131_ARGCTX_OFF`), is in
`src/EmitHelpers.h` (the law) and the two ExprEmit sites of the parent laws. It moves no corpus database,
no probe case and no downstream row (predicted by name first: none of the 35 law movers whose
indexed-part-select or package-call span changed sits in a call argument or a THEN operand).

| binary | md5 |
|---|---|
| pristine (worktree rebuild of the base; equals the main-tree build of the base) | `9767e18b4753a0562f90d27f919b01d8` |
| law (implementer patch, rebuilt here) | `f70fbe2e2b3207848d8cbf5950aa3c45` (equals the implementer's `final4`) |
| verified (law + § constCtxCallArgInner131v) | `b52374acf952445ea7700fbd3ea255dd` |
| `build/uhdm-strictcmp` | `70ddf0ad777735ff05ec8d89aee66627` |

All three were frozen (`chmod 555` copies) before any measurement. Every `cmds.txt` of every sweep names
its frozen binary: pristine 3273/3273, law 3273/3273, verified 3273/3273. The downstream lanes'
databases are byte-identical to the law / verified binary's own output (checked on `Disable`).

## Reproduction of the implementer's headline (pristine sweep vs law sweep, both run here)

| axis | pristine | law | implementer claimed |
|---|---|---|---|
| probe gate | EQUAL=4087 of 4087 | EQUAL=4087 of 4087 | same |
| probe strict-equal | 2068 | 2104 | 2068 → 2104 |
| surelog strict-equal (of 954 CMP_EQUAL row-modes) | 640 | 685 | 640 → 685 |
| uhdm2rtlil strict-equal (of 1606) | 1264 | 1280 | 1264 → 1280 |
| surelog scoreboard | 480/3 + 474/3, regressions=0 conversions=0 changes=0 | same | same |
| uhdm2rtlil scoreboard | 803/1/67 both modes, regressions=0 conversions=0 changes=0 | same | same |
| downstream (law) | — | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66; 0 of 871 rows change verdict vs `results/downstream_uhdm2rtlil.csv` | same |
| byteverify (SELFCHECK=1) | — | surelog MOVERS 81/960 (selfcheck 959/960), uhdm2rtlil 48/1608 (1607/1608) | same |
| strict row join surelog | — | TO_EQUAL 45, BETTER 10, FIELD_CHANGE 4, WORSE 0 | same |
| strict row join uhdm2rtlil | — | TO_EQUAL 16, BETTER 24, FIELD_CHANGE 6, WORSE 0 | same |

The pristine sweep's strict column equals `results/golden_*.csv` column 6 on every row (join: no row differs).
Every one of the 129 corpus byte movers was re-walked against its golden (drivers/firstdiff.py,
drivers/fieldworse.py): the first differing record moves LATER on 71, stays at the same record with
the same or fewer differing objects on 58, EARLIER on 0; no field of any aligned record that matched
golden under pristine differs under the law binary (FIELDOK 129/129). The ten FIELD_CHANGE row-modes
(IntegerConcat, PackStructField/default, SequenceInst/testflags, portsel_struct_param,
struct_member_cfg_width, sva_counter) are all LATER. Probe: 89 cases change their strict records
(the path-independent record walk, drivers/probe_movers2.py; raw bytes differ everywhere because the
two worktree paths differ in length), 36 turn equal, 53 LATER, 36 same-record, 0 WORSE, 0 field
worsenings. Canaries (law vs pristine csv): statuses identical; the changed strict cells all move
toward golden (Earlgrey_0_1 `line(1055)` → `line(1041)`, BuildUVMPkg `fullname(328)` → `(283)` at the
same record; PartSelect4, EvalFunc, BlackParrotSkipParam → equal); `ctcan2` against the committed csvs
reads every row CHANGED on the PRISTINE sweep too (the committed csvs are CRLF), so it was run
against the pristine sweep's csv: surelog ok=52 changed=6 (the six are the to-equal rows above),
uhdm2rtlil PASS.

Base heads quoted with `uhdm-strictcmp --max 1` on the pristine sweep (golden A, ours B):

    BlackParrotSkipParam/default  #128 col       A: constant dut.sv 4 31 4 52 UINT:10   B: 4 32 4 51
    CheckerInst/default           #101 file      A: logic_net req (no file) 6:22-6:25   B: dut.sv
    struct_param_func_arg/default #291 endcol    A: func_call p::build 16 39 16 42      B: 16 39 16 40
    ParamOverload2/default        #276 fullname  A: ref_typespec (empty)                B: work@top.u_keymgr
    LogicArrayParam/default       #11  fullname  A: alert_handler_reg_pkg::AsyncOn::NAlerts  B: ...::AsyncOn.NAlerts

Earlier passes' cases as byte controls (pristine vs law, and pristine vs verified: identical sets):
r11v11u118 0/56, r11u119 0/78, r11u120 0/44, r11v120 0/47, r11u123canon 0/22, r11u125 0/61,
r11v124 0/109 (its two string cases write no database on either binary), r11u118 1/56, r11u121 14/83,
v11u121 12/41, r11u124 9/81, r11v125 1/48: as the implementer reported. Each mover re-judged
(evidence/earlier_pass_controls_records.txt): the judge-equal ones are record-level OK (c13 q02 q05
q08 q09, r11v125 ct/t03 → equal); the stage-1 ones keep their uhdm-cmp head. On some stage-1 cases
(v11u121 B/b2 b4 b8 b9, r11u121 s01 s07 s15) the order-blind line count moves AWAY from golden by
3-5 lines: the package listing's pattern operation, where golden writes NO typespec (the uhdm-cmp
head `LHS: <null>`), keeps our typespec reference, now unparented. The operation is wrong on both
binaries. Only the lost parent lines count against the law. This is the implementer's "11 instead
of 17 lines" note; see residue V3.

Switches (verified binary, every case of this directory and of r11u131repro, 249): `R11U131_OFF=1`
gives pristine bytes on 249/249 (positive control: 135 differ from pristine without it); each single switch moves ONLY its own grid's cases (INETFILE 16 = inet, PAREN 10 = par,
QCALL 18 = qc, IPSSPAN 17 = ips, KWSYS 17 = sfc, OVRMD 20 = ovr, PATTS 26 = pat, PTSSEP 6 = pts,
CASTLOC 5 = ctp, and `R11V131_ARGCTX_OFF` 16 = the call-argument / THEN cases of ips and qc).
`R11U131_OFF=1` also turns § constCtxCallArgInner131v off (it guards only laws of this pass).

## The break: fresh instances per law (128 cases, 9 grids)

Judged by uhdm-cmp against the v1.87 pin, by uhdm-strictcmp record by record (drivers/worse.py,
drivers/fieldworse.py), and by an order-blind dump delta on stage-1 cases (drivers/dumpdelta.py).
Columns: pristine / law / verified verdict (`cmp=<uhdm-cmp lines>`), then pristine→law and
pristine→verified: SAME bytes, OK/FIELDOK (record-level: no record or field that matched golden stops
matching), WORSE/FIELDWORSE (a matched record stops matching), STAGE1 (uhdm-cmp NOT_EQUAL on both;
`P=`/`L=` count the lines off golden, `newbad`/`fixed` the lines each side gains or loses; one
`newbad` is always the dump header naming the file).

| grid | law | cases | pristine equal | verified equal | turned equal | stage-1 on both |
|---|---|---|---|---|---|---|
| inet | § implicitNetMintNoFile131 | 10 | 1 | 7 | 6 | 3 |
| par | § paramFoldParenSpan131 | 24 | 12 | 16 | 4 | 7 |
| qc | § pkgQualCallQualSpan131 / § constCtxCallArgInner131v | 22 | 0 | 1 | 1 | 20 |
| ips | § paramIdxPartSelWholeSpan131 / § constCtxCallArgInner131v | 19 | 4 | 4 | 0 (d03 d14 improve a record) | 6 |
| sfc | § sysCallKwTypeArgNameSpan131 | 9 | 0 | 6 | 6 | 3 |
| ovr | § ovrMultiDimConstUnparented131 | 17 | 1 | 15 | 14 | 2 |
| pat | § pkgPatReadTsNoParent131 | 17 | 0 | 4 | 4 | 9 |
| pts | § pkgParamTsRefColons131 | 5 | 0 | 0 | 0 | 5 |
| ctp | § castTsPushLaidOut131 | 5 | 2 | 3 | 1 | 0 |

Every law generalises except one face. § ovrMultiDimConstUnparented131 held on the untyped
parameter fed a 2-D value (a01 untouched, equal), reads in always_comb, operation operands, gen scopes,
port connections, localparams (the golden constant is unparented there too: a02 a06 a09 a16 a17 →
equal), `bit` 2-D, interface, gen-array, positional, pass-down, ternary / concat / cast overrides and a
packed struct array (a04 a05 a07 a08 a10 a12-a15 → equal). § implicitNetMintNoFile131 held on the
twice-used formal, `$dumpvars` of an instance, `disable` in a task, of an outer block, twice-dumped,
two instances (f03-f07 f09 → equal). § sysCallKwTypeArgNameSpan131 held on `bit`, `int unsigned`,
`longint`, `reg`, a procedural statement, `$clog2($bits(shortint))` and a task argument (→ equal); a
packed `logic [3:0]` keeps the whole call (e03, untouched). § paramFoldParenSpan131 held on double
parentheses, typed / signed / negative, interface, override-with-parentheses, two instances, a literal
default overridden, an interface port parameter (b07 b25 b30 b32 → equal) and did not touch a macro or
a gen-scope localparam (b24, residue V2).

**The one over-firing face**: a CALL ARGUMENT or a conditional's THEN operand. Golden (uhdm-dump, pin):

| case | written | golden span | law span |
|---|---|---|---|
| ips/d12_funcarg | `localparam int P = f(A[8 +: 8]);` | 5:26-32 (range) | 5:24-33 (whole) |
| ips/d13_clog2_port | `parameter int P = $clog2(A[4 +: 8])` | 2:78-84 | 2:76-85 |
| ips/d18_bits_arg | `$bits(A[8 +: 8])` | range | whole |
| ips/d01 d11 d15 | `$countones(A[8 +: 8])` (module, package) | 4:35-41 | 4:33-42 |
| ips/d16_ternary | `(W > 0) ? A[8 +: 8] : 8'h0` | 5:42-48 | 5:40-49 |
| qc/c02 c11 c12 c13 | `$clog2(p::f(5))` | 7:29-30 (`p`) | 7:29-32 (`p::`) |
| qc/c07 c14 | `p::g(p::f(1))`, the inner call | 7:27-28 | 7:27-30 |
| qc/c17 c18 | `lf(p::f(1))` | `p` | `p::` |
| qc/c19_ternary | `(W > 0) ? p::f(1) : 0` | 7:32-33 | 7:32-35 |

while the whole node is right in a binary / unary operand, a concatenation or replication element, a
cast operand, a conditional's predicate and its ELSE operand (golden, same probes: c01 c16 c20-c25,
d04 d19-d23). d12, d13 and d18 are judge-EQUAL and their strict first field moves from `file` to `col`
at an EARLIER record: pristine-right → law-wrong on legal SV.

§ constCtxCallArgInner131v (switch `R11V131_ARGCTX_OFF`; site: EmitHelpers.h `constCtxWholeNode131`,
called at the § pkgQualCallQualSpan131 and § paramIdxPartSelWholeSpan131 sites of ExprEmit.cpp) walks
the syntax parents from the select / call up to the initializer and keeps the pristine span when it
crosses an `ArgumentList` or enters a `ConditionalExpression` through its `left` (THEN) operand. With
it on, all 16 call-argument / THEN cases return to pristine bytes (the outer `p::g` of c07 / c14 keeps
the law's `p::` span, which is golden's) and every other case is byte-identical to the law binary.

## Gates (verified binary, from /tmp/wt_v11u131)

1. Build: md5s above.
2. `tests/sweep.sh --corpus probe`: `EQUAL=4087 (of 4087)`; probe strict equal=2104 (the law's tally, field by field).
3. `tests/sweep.sh --corpus "surelog uhdm2rtlil"`: `regressions=0 conversions=0 changes=0 only-fresh=0
   only-committed=0` in both corpora; strict join vs the law sweep: no row-mode changes; vs pristine:
   surelog TO_EQUAL 45 BETTER 10 FIELD_CHANGE 4 WORSE 0 (685 strict-equal), uhdm2rtlil TO_EQUAL 16
   BETTER 24 FIELD_CHANGE 6 WORSE 0 (1280).
4. `tests/sweep.sh --corpus downstream`: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not
   identical and not excused=0`; joined to `results/downstream_uhdm2rtlil.csv` on verdict AND differs:
   0 of 871 rows change. Targeted rows: `struct_param_func_arg,IDENTICAL,OK,OK,51,51,,`,
   `Disable,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `const_func_block_var,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `2DParameterOfInstance,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `BitSelectOfParameterPassedToSubmoduleInGenFor,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `BitSelectOfParameterPassedToSubmoduleInGenForOfSubmodule,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `PatternAssignmentOfStructParam,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `StructParameterInitializedWithPatternAndReferenced,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.
5. uhdm-cmp: every row-mode keeps its status (the scoreboard join), every probe case EQUAL.
6. Byteverify verified vs law (SELFCHECK=1): surelog `MOVERS: 5 / 960` (selfcheck 959/960) = the
   UVM coin: MiniAmiq, SeqDriver, SimpleUVM default and MiniAmiq, SeqDriver testflags each differ in exactly
   four dump lines (`vpiDecompile:872` / `UINT:872` ↔ `913`, the known 0-or-4-line order coin);
   uhdm2rtlil `MOVERS: 0 / 1608` (selfcheck 1607/1608); probe: 0 cases change strict records. PREDICTED
   before the sweep (evidence/argctx_prediction_candidates.txt): the 35 law movers whose
   indexed-part-select or package-call span changed were read at their source lines (ElabCParam,
   LargeHex, PartSelect4 `A[k*4+:4]`, EvalFunc, FuncStructVal(Simple), StructParam*, portsel_struct_param,
   struct_member_cfg_width, struct_param_func_arg, struct_param_func_loop, and the UVM `$bits` rows):
   every one is a whole initializer, none a call argument or THEN operand → 0 movers predicted, 0 seen
   outside the coin.

## Residues (ranked)

V1. The implementer's R1-R11 stand as reported; R1 (net binding, 25 single-cluster row-modes) is the
largest and sits in ModuleEmit (emitContAssigns, emitScopeClocking's caller, emitInstance).
V2. § paramFoldParenSpan131 misses a GENERATE-SCOPE localparam (par/b24: `localparam int L = (N * 2);`
in a gen-if: golden 5:24-31, ours 5:25-30; its param_assign is not written by emitParameters' loop).
V3. The package listing of a pattern parameter read only PROCEDURALLY (always_comb / always_ff / initial /
a variable initializer / an `if` condition: pat k06 k11-k13 k16 k17, r11u124 t06): golden writes no
typespec on the operation at all (uhdm-cmp NOT_EQUAL at the base); § pkgPatReadTsNoParent131 swaps our
parented reference for an unparented one. The operation is wrong on both binaries. A law that
suppresses the reference in this read set would clear stage 1 on these shapes.
V4. The gen-scope and call-argument faces of the indexed part-select in TypeEmit's emitSyntaxExpr
(implementer R4) keep the range span there too: the THEN / argument rule of § constCtxCallArgInner131v
must carry over when that site takes § paramIdxPartSelWholeSpan131.
V5. `$high(int)` / `$left(byte)` (sfc e04, s06): golden folds the call away (stage 1 at the base); the
name-only span of § sysCallKwTypeArgNameSpan131 is unjudgeable there.

## Case table (first line of every case names its law)

| case | law | pristine | law | verified | pristine→law | pristine→verified |
|---|---|---|---|---|---|---|
| ctp/h01_macro_arg_cast | § castTsPushLaidOut131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| ctp/h02_tab_before | § castTsPushLaidOut131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| ctp/h03_inc_midline | § castTsPushLaidOut131 | cmp=0 ne:file | cmp=0 ne:file | cmp=0 ne:file | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ctp/h04_macro_same_line_after | § castTsPushLaidOut131 | cmp=0 ne:col | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ctp/h05_multiline_macro | § castTsPushLaidOut131 | cmp=0 ne:line | cmp=0 ne:line | cmp=0 ne:line | PL=SAME | PF=SAME |
| inet/f01_iface_propformal | § implicitNetMintNoFile131 | cmp=305 stage1-NE | cmp=305 stage1-NE | cmp=305 stage1-NE | PL=SAME | PF=SAME |
| inet/f02_seq_formal | § implicitNetMintNoFile131 | cmp=341 stage1-NE | cmp=341 stage1-NE | cmp=341 stage1-NE | PL=SAME | PF=SAME |
| inet/f03_two_props_same_formal | § implicitNetMintNoFile131 | cmp=0 ne:file | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| inet/f04_dumpvars_inst | § implicitNetMintNoFile131 | cmp=0 ne:file | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| inet/f05_disable_in_task | § implicitNetMintNoFile131 | cmp=0 ne:file | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| inet/f06_disable_outer | § implicitNetMintNoFile131 | cmp=0 ne:file | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| inet/f07_dumpvars_twice | § implicitNetMintNoFile131 | cmp=0 ne:file | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| inet/f08_gen_propformal | § implicitNetMintNoFile131 | cmp=157 stage1-NE | cmp=157 stage1-NE | cmp=157 stage1-NE | PL=SAME | PF=SAME |
| inet/f09_sub_disable_two_inst | § implicitNetMintNoFile131 | cmp=0 ne:file | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| inet/f10_formal_named_like_port | § implicitNetMintNoFile131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| ips/d01_in_call | § constCtxCallArgInner131v | cmp=60 stage1-NE | cmp=60 stage1-NE | cmp=60 stage1-NE | PL=STAGE1:P=55,L=57,newbad=4,fixed=2 | PF=SAME |
| ips/d02_ca_ctl | § paramIdxPartSelWholeSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| ips/d03_param_base_var | § paramIdxPartSelWholeSpan131 | cmp=0 ne:col | cmp=0 ne:file | cmp=0 ne:file | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ips/d04_minus_pkg | § paramIdxPartSelWholeSpan131 | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=STAGE1:P=22,L=20,newbad=2,fixed=4 | PF=STAGE1:P=22,L=20,newbad=2,fixed=4 |
| ips/d05_proc_in_func | § paramIdxPartSelWholeSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| ips/d06_concat_override | § paramIdxPartSelWholeSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| ips/d11_sysarg_nouse | § constCtxCallArgInner131v | cmp=60 stage1-NE | cmp=60 stage1-NE | cmp=60 stage1-NE | PL=STAGE1:P=26,L=28,newbad=4,fixed=2 | PF=SAME |
| ips/d12_funcarg | § constCtxCallArgInner131v | cmp=0 ne:file | cmp=0 ne:col | cmp=0 ne:file | PL=WORSE/FIELDWORSE | PF=SAME |
| ips/d13_clog2_port | § constCtxCallArgInner131v | cmp=0 ne:file | cmp=0 ne:col | cmp=0 ne:file | PL=WORSE/FIELDWORSE | PF=SAME |
| ips/d14_top_nouse | § paramIdxPartSelWholeSpan131 | cmp=0 ne:col | cmp=0 ne:file | cmp=0 ne:file | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ips/d15_pkg_sysarg | § constCtxCallArgInner131v | cmp=60 stage1-NE | cmp=60 stage1-NE | cmp=60 stage1-NE | PL=STAGE1:P=27,L=29,newbad=4,fixed=2 | PF=SAME |
| ips/d16_ternary | § constCtxCallArgInner131v | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=STAGE1:P=25,L=27,newbad=4,fixed=2 | PF=SAME |
| ips/d17_modfunc_arg_ovr | § paramIdxPartSelWholeSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| ips/d18_bits_arg | § constCtxCallArgInner131v | cmp=0 ne:file | cmp=0 ne:col | cmp=0 ne:file | PL=WORSE/FIELDWORSE | PF=SAME |
| ips/d19_pred | § paramIdxPartSelWholeSpan131 | cmp=0 ne:col | cmp=0 ne:file | cmp=0 ne:file | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ips/d20_unary | § paramIdxPartSelWholeSpan131 | cmp=0 ne:col | cmp=0 ne:file | cmp=0 ne:file | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ips/d21_cast | § paramIdxPartSelWholeSpan131 | cmp=0 ne:col | cmp=0 ne:file | cmp=0 ne:file | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ips/d22_repl | § paramIdxPartSelWholeSpan131 | cmp=0 ne:col | cmp=0 ne:file | cmp=0 ne:file | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ips/d23_else_branch | § paramIdxPartSelWholeSpan131 | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=STAGE1:P=27,L=25,newbad=2,fixed=4 | PF=STAGE1:P=27,L=25,newbad=2,fixed=4 |
| ovr/a01_untyped_from2d | § ovrMultiDimConstUnparented131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| ovr/a02_read_always | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a03_read_select | § ovrMultiDimConstUnparented131 | cmp=48 stage1-NE | cmp=48 stage1-NE | cmp=48 stage1-NE | PL=STAGE1:P=23,L=20,newbad=1,fixed=4 | PF=STAGE1:P=23,L=20,newbad=1,fixed=4 |
| ovr/a04_bit2d | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a05_iface | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a06_read_opnd | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a07_gen | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a08_positional | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a09_localparam_from | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a10_passdown | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a11_defparam | § ovrMultiDimConstUnparented131 | cmp=32 stage1-NE | cmp=32 stage1-NE | cmp=32 stage1-NE | PL=SAME | PF=SAME |
| ovr/a12_ternary_ovr | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a13_concat_ovr | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a14_cast_ovr | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a15_struct_arr | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a16_gen_read | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| ovr/a17_port_read | § ovrMultiDimConstUnparented131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| par/b01_read_ca | § paramFoldParenSpan131 | cmp=17 stage1-NE | cmp=17 stage1-NE | cmp=17 stage1-NE | PL=SAME | PF=SAME |
| par/b02_double_paren | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b03_pkg_import_lit | § paramFoldParenSpan131 | cmp=22 stage1-NE | cmp=22 stage1-NE | cmp=22 stage1-NE | PL=STAGE1:P=16,L=12,newbad=0,fixed=4 | PF=STAGE1:P=16,L=12,newbad=0,fixed=4 |
| par/b04_localparam_body | § paramFoldParenSpan131 | cmp=17 stage1-NE | cmp=17 stage1-NE | cmp=17 stage1-NE | PL=SAME | PF=SAME |
| par/b05_gen_localparam | § paramFoldParenSpan131 | cmp=17 stage1-NE | cmp=17 stage1-NE | cmp=17 stage1-NE | PL=SAME | PF=SAME |
| par/b06_iface | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b07_override_paren | § paramFoldParenSpan131 | cmp=0 ne:col | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| par/b08_two_inst | § paramFoldParenSpan131 | cmp=36 stage1-NE | cmp=36 stage1-NE | cmp=36 stage1-NE | PL=STAGE1:P=6,L=4,newbad=0,fixed=2 | PF=STAGE1:P=6,L=4,newbad=0,fixed=2 |
| par/b09_typed_signed | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b10_pkg_qual_read | § paramFoldParenSpan131 | cmp=93 stage1-NE | cmp=93 stage1-NE | cmp=93 stage1-NE | PL=SAME | PF=SAME |
| par/b11_neg | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b12_sameinner | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b21_typed_read_ca | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b22_typed_pkg_import | § paramFoldParenSpan131 | cmp=28 stage1-NE | cmp=28 stage1-NE | cmp=28 stage1-NE | PL=STAGE1:P=14,L=10,newbad=0,fixed=4 | PF=STAGE1:P=14,L=10,newbad=0,fixed=4 |
| par/b23_typed_localparam_body | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b24_typed_gen_localparam | § paramFoldParenSpan131 | cmp=0 ne:col | cmp=0 ne:col | cmp=0 ne:col | PL=SAME | PF=SAME |
| par/b25_typed_two_inst | § paramFoldParenSpan131 | cmp=0 ne:col | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| par/b26_typed_pkg_qual | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b27_range_use | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b28_logic_vec | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b29_gen_for_use | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b30_paren_lit_override | § paramFoldParenSpan131 | cmp=0 ne:col | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| par/b31_macro_paren | § paramFoldParenSpan131 | cmp=0 equal | cmp=0 equal | cmp=0 equal | PL=SAME | PF=SAME |
| par/b32_iface_port_param | § paramFoldParenSpan131 | cmp=0 ne:col | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| pat/k01_import_unused | § pkgPatReadTsNoParent131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| pat/k02_explicit_import | § pkgPatReadTsNoParent131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| pat/k03_read_in_func | § pkgPatReadTsNoParent131 | cmp=11 stage1-NE | cmp=11 stage1-NE | cmp=11 stage1-NE | PL=STAGE1:P=139,L=142,newbad=4,fixed=1 | PF=STAGE1:P=139,L=142,newbad=4,fixed=1 |
| pat/k04_read_other_pkg | § pkgPatReadTsNoParent131 | cmp=54 stage1-NE | cmp=54 stage1-NE | cmp=54 stage1-NE | PL=SAME | PF=SAME |
| pat/k05_default_pattern_vec | § pkgPatReadTsNoParent131 | cmp=58 stage1-NE | cmp=58 stage1-NE | cmp=58 stage1-NE | PL=SAME | PF=SAME |
| pat/k06_proc_read | § pkgPatReadTsNoParent131 | cmp=17 stage1-NE | cmp=11 stage1-NE | cmp=11 stage1-NE | PL=STAGE1:P=25,L=28,newbad=4,fixed=1 | PF=STAGE1:P=25,L=28,newbad=4,fixed=1 |
| pat/k07_iface_import_read | § pkgPatReadTsNoParent131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| pat/k08_localparam_pkg | § pkgPatReadTsNoParent131 | cmp=0 ne:fullname | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| pat/k09_gen_read | § pkgPatReadTsNoParent131 | cmp=0 ne:fullname | cmp=0 ne:endcol | cmp=0 ne:endcol | PL=OK/FIELDOK | PF=OK/FIELDOK |
| pat/k10_port_default | § pkgPatReadTsNoParent131 | cmp=0 ne:endcol | cmp=0 ne:endcol | cmp=0 ne:endcol | PL=SAME | PF=SAME |
| pat/k11_initial | § pkgPatReadTsNoParent131 | cmp=17 stage1-NE | cmp=11 stage1-NE | cmp=11 stage1-NE | PL=STAGE1:P=25,L=28,newbad=4,fixed=1 | PF=STAGE1:P=25,L=28,newbad=4,fixed=1 |
| pat/k12_alwayscomb_member | § pkgPatReadTsNoParent131 | cmp=17 stage1-NE | cmp=11 stage1-NE | cmp=11 stage1-NE | PL=STAGE1:P=35,L=38,newbad=4,fixed=1 | PF=STAGE1:P=35,L=38,newbad=4,fixed=1 |
| pat/k13_ff | § pkgPatReadTsNoParent131 | cmp=17 stage1-NE | cmp=11 stage1-NE | cmp=11 stage1-NE | PL=STAGE1:P=25,L=28,newbad=4,fixed=1 | PF=STAGE1:P=25,L=28,newbad=4,fixed=1 |
| pat/k14_modfunc | § pkgPatReadTsNoParent131 | cmp=0 ne:fullname | cmp=0 ne:type | cmp=0 ne:type | PL=OK/FIELDOK | PF=OK/FIELDOK |
| pat/k15_genif | § pkgPatReadTsNoParent131 | cmp=0 ne:fullname | cmp=0 ne:endcol | cmp=0 ne:endcol | PL=OK/FIELDOK | PF=OK/FIELDOK |
| pat/k16_varinit | § pkgPatReadTsNoParent131 | cmp=17 stage1-NE | cmp=11 stage1-NE | cmp=11 stage1-NE | PL=STAGE1:P=114,L=115,newbad=3,fixed=2 | PF=STAGE1:P=114,L=115,newbad=3,fixed=2 |
| pat/k17_proc_if | § pkgPatReadTsNoParent131 | cmp=17 stage1-NE | cmp=11 stage1-NE | cmp=11 stage1-NE | PL=STAGE1:P=25,L=28,newbad=4,fixed=1 | PF=STAGE1:P=25,L=28,newbad=4,fixed=1 |
| pts/g01_class_in_pkg | § pkgParamTsRefColons131 | cmp=78 stage1-NE | cmp=78 stage1-NE | cmp=78 stage1-NE | PL=SAME | PF=SAME |
| pts/g02_other_pkg | § pkgParamTsRefColons131 | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=SAME | PF=SAME |
| pts/g03_unpacked | § pkgParamTsRefColons131 | cmp=32 stage1-NE | cmp=32 stage1-NE | cmp=32 stage1-NE | PL=SAME | PF=SAME |
| pts/g04_two_bounds | § pkgParamTsRefColons131 | cmp=50 stage1-NE | cmp=50 stage1-NE | cmp=50 stage1-NE | PL=STAGE1:P=244,L=236,newbad=0,fixed=8 | PF=STAGE1:P=244,L=236,newbad=0,fixed=8 |
| pts/g05_func_in_pkg | § pkgParamTsRefColons131 | cmp=143 stage1-NE | cmp=143 stage1-NE | cmp=143 stage1-NE | PL=SAME | PF=SAME |
| qc/c01_nested_op | § pkgQualCallQualSpan131 | cmp=118 stage1-NE | cmp=118 stage1-NE | cmp=118 stage1-NE | PL=STAGE1:P=53,L=49,newbad=2,fixed=6 | PF=STAGE1:P=53,L=49,newbad=2,fixed=6 |
| qc/c02_arg_of_sys | § constCtxCallArgInner131v | cmp=74 stage1-NE | cmp=74 stage1-NE | cmp=74 stage1-NE | PL=STAGE1:P=54,L=58,newbad=6,fixed=2 | PF=SAME |
| qc/c03_override | § pkgQualCallQualSpan131 | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=SAME | PF=SAME |
| qc/c04_gen_localparam | § pkgQualCallQualSpan131 | cmp=46 stage1-NE | cmp=46 stage1-NE | cmp=46 stage1-NE | PL=SAME | PF=SAME |
| qc/c05_pkg_localparam | § pkgQualCallQualSpan131 | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=STAGE1:P=25,L=21,newbad=0,fixed=4 | PF=STAGE1:P=25,L=21,newbad=0,fixed=4 |
| qc/c06_range_decl | § pkgQualCallQualSpan131 | cmp=0 ne:endcol | cmp=0 ne:endcol | cmp=0 ne:endcol | PL=SAME | PF=SAME |
| qc/c07_func_arg_param | § constCtxCallArgInner131v | cmp=17 stage1-NE | cmp=17 stage1-NE | cmp=17 stage1-NE | PL=STAGE1:P=13,L=13,newbad=5,fixed=5 | PF=STAGE1:P=13,L=9,newbad=0,fixed=4 |
| qc/c11_sysarg_nouse | § constCtxCallArgInner131v | cmp=74 stage1-NE | cmp=74 stage1-NE | cmp=74 stage1-NE | PL=STAGE1:P=27,L=31,newbad=6,fixed=2 | PF=SAME |
| qc/c12_sysarg_pkg | § constCtxCallArgInner131v | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=STAGE1:P=8,L=12,newbad=4,fixed=0 | PF=SAME |
| qc/c13_sysarg_port | § constCtxCallArgInner131v | cmp=74 stage1-NE | cmp=74 stage1-NE | cmp=74 stage1-NE | PL=STAGE1:P=23,L=27,newbad=6,fixed=2 | PF=SAME |
| qc/c14_callarg_nouse | § constCtxCallArgInner131v | cmp=17 stage1-NE | cmp=17 stage1-NE | cmp=17 stage1-NE | PL=STAGE1:P=17,L=17,newbad=5,fixed=5 | PF=STAGE1:P=17,L=13,newbad=0,fixed=4 |
| qc/c15_top_nouse | § pkgQualCallQualSpan131 | cmp=0 ne:endcol | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| qc/c16_op_nouse | § pkgQualCallQualSpan131 | cmp=118 stage1-NE | cmp=118 stage1-NE | cmp=118 stage1-NE | PL=STAGE1:P=45,L=41,newbad=2,fixed=6 | PF=STAGE1:P=45,L=41,newbad=2,fixed=6 |
| qc/c17_modfunc_arg | § constCtxCallArgInner131v | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=STAGE1:P=6,L=10,newbad=4,fixed=0 | PF=SAME |
| qc/c18_modfunc_arg_port | § constCtxCallArgInner131v | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=STAGE1:P=6,L=10,newbad=4,fixed=0 | PF=SAME |
| qc/c19_ternary | § constCtxCallArgInner131v | cmp=78 stage1-NE | cmp=78 stage1-NE | cmp=78 stage1-NE | PL=STAGE1:P=23,L=27,newbad=6,fixed=2 | PF=SAME |
| qc/c20_concat | § pkgQualCallQualSpan131 | cmp=17 stage1-NE | cmp=17 stage1-NE | cmp=17 stage1-NE | PL=STAGE1:P=52,L=44,newbad=4,fixed=12 | PF=STAGE1:P=52,L=44,newbad=4,fixed=12 |
| qc/c21_pred | § pkgQualCallQualSpan131 | cmp=17 stage1-NE | cmp=17 stage1-NE | cmp=17 stage1-NE | PL=STAGE1:P=15,L=11,newbad=0,fixed=4 | PF=STAGE1:P=15,L=11,newbad=0,fixed=4 |
| qc/c22_unary | § pkgQualCallQualSpan131 | cmp=102 stage1-NE | cmp=102 stage1-NE | cmp=102 stage1-NE | PL=STAGE1:P=37,L=33,newbad=2,fixed=6 | PF=STAGE1:P=37,L=33,newbad=2,fixed=6 |
| qc/c23_paren_op | § pkgQualCallQualSpan131 | cmp=118 stage1-NE | cmp=118 stage1-NE | cmp=118 stage1-NE | PL=STAGE1:P=45,L=41,newbad=2,fixed=6 | PF=STAGE1:P=45,L=41,newbad=2,fixed=6 |
| qc/c24_repl | § pkgQualCallQualSpan131 | cmp=114 stage1-NE | cmp=114 stage1-NE | cmp=114 stage1-NE | PL=STAGE1:P=49,L=45,newbad=2,fixed=6 | PF=STAGE1:P=49,L=45,newbad=2,fixed=6 |
| qc/c25_cast | § pkgQualCallQualSpan131 | cmp=102 stage1-NE | cmp=102 stage1-NE | cmp=102 stage1-NE | PL=STAGE1:P=39,L=35,newbad=2,fixed=6 | PF=STAGE1:P=39,L=35,newbad=2,fixed=6 |
| sfc/e01_bits_bit | § sysCallKwTypeArgNameSpan131 | cmp=0 ne:endcol | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| sfc/e02_bits_int_unsigned | § sysCallKwTypeArgNameSpan131 | cmp=0 ne:endcol | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| sfc/e03_bits_logic_vec | § sysCallKwTypeArgNameSpan131 | cmp=64 stage1-NE | cmp=64 stage1-NE | cmp=64 stage1-NE | PL=SAME | PF=SAME |
| sfc/e04_high_int | § sysCallKwTypeArgNameSpan131 | cmp=44 stage1-NE | cmp=44 stage1-NE | cmp=44 stage1-NE | PL=STAGE1:P=65,L=65,newbad=4,fixed=4 | PF=STAGE1:P=65,L=65,newbad=4,fixed=4 |
| sfc/e05_proc | § sysCallKwTypeArgNameSpan131 | cmp=0 ne:endcol | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| sfc/e06_bits_longint_reg | § sysCallKwTypeArgNameSpan131 | cmp=0 ne:endcol | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| sfc/e07_bits_real | § sysCallKwTypeArgNameSpan131 | cmp=54 stage1-NE | cmp=54 stage1-NE | cmp=54 stage1-NE | PL=SAME | PF=SAME |
| sfc/e08_clog2_of_bits | § sysCallKwTypeArgNameSpan131 | cmp=0 ne:endcol | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |
| sfc/e09_task_arg | § sysCallKwTypeArgNameSpan131 | cmp=0 ne:endcol | cmp=0 equal | cmp=0 equal | PL=OK/FIELDOK | PF=OK/FIELDOK |

## Files

* `ctp/ inet/ ips/ ovr/ par/ pat/ pts/ qc/ sfc/` — the cases (`dut.sv`, `ctp/h03_inc_midline/b.svh`).
* `drivers/` — `env.sh` (tool paths), `run_case.sh` (golden cached by content md5, ours, uhdm-cmp,
  strictcmp), `worse.py` / `fieldworse.py` / `firstdiff.py` (record-level judges), `dumpdelta.py`
  (order-blind stage-1 delta), `strictjoin.py` (strict column row join), `probe_movers2.py` +
  `probe_fd.sh` (probe record census across worktrees), `corpus_movers.sh`, `bytes.sh` (byte
  compare of two binaries with an environment for the second), `sweeps.sh` / `sweepsF.sh` (the sweeps).
* `evidence/` — grid_table.tsv, the strict joins, byteverify outputs, corpus / probe mover censuses,
  earlier-pass control records, the prediction candidates, sweep and downstream summaries.
