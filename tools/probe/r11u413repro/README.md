# r11u413 — the sv-tests campaign's seventh pass on the expression/parameter ground

Implementer pass on base c64f995f (passes 401, 402, 404, 403, 406, 405, 408,
407, 410, 409, 412 and 411 landed), ground src/ExprEmit.cpp, src/EmitHelpers.h,
src/StmtEmit.cpp, src/ParamEmit.cpp.  Every law is `§ <name>413` read through
`lawOn(413, "R11U413_<LAW>_OFF")` (src/LawSwitch.h); `R11U413_OFF` drops all of
them; `R11U413_TRACE=<dir>` logs each firing through `lawTrace(413, ...)`.  No
src/R*.h, no getenv, no reader function; the patch touches src/ExprEmit.cpp and
src/ParamEmit.cpp (EmitHelpers.h, StmtEmit.cpp, include/ unchanged).

Binaries: pristine 91430e8d41d50b5bb4445fae97e61b69 (the main tree's
build/slang-uhdm at the base, frozen; no pristine build, no pristine sweep: the
pristine reading is the master's control /tmp/intr11u411), final law binary
87836b5db413c10d58c1aabdc4bd9c78 (`law5`, swept once in full).  Intermediate
binaries law1-law4 ran only the case grids, targeted runner calls on the
non-UVM DIFFERENT rows (pristine and law3, evidence/svtests_targeted_law3.csv)
and two corpus rows (ThisHier, SVSwitch) for the prediction.  Every case line
carries the exit code.

## Verdict per targeted row (sv-tests, results/golden_svtests.csv -> the law sweep)

| row | before | after | law |
|---|---|---|---|
| chapter-7/queues/delete_assign.sv | DIFFERENT | **EQUAL** | § emptyConcatArrayVar413 |
| chapter-8/8.12--shallow_copy.sv | DIFFERENT | **EQUAL** | § shallowCopyLhsUnbound413 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p181_2.sv | DIFFERENT | **EQUAL** | § superMemberHierPath413 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p537.sv | DIFFERENT | **EQUAL** | § stdRandomizeFuncCall413 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p770.sv | DIFFERENT | **EQUAL** | § ifaceArrElemArgBitSel413 |

Fresh rows (/tmp/r11u413_w5/svtests.csv):

    chapter-7/queues/delete_assign.sv,EQUAL,,equal
    chapter-8/8.12--shallow_copy.sv,EQUAL,,equal
    generated/hdlconv_std2017/hdlconvertor_std2017_p181_2.sv,EQUAL,,equal
    generated/hdlconv_std2017/hdlconvertor_std2017_p537.sv,EQUAL,,equal
    generated/hdlconv_std2017/hdlconvertor_std2017_p770.sv,EQUAL,,equal

The sv-tests stage reads `regressions=0 conversions=5 changes=0`; status
counts EQUAL 1700 -> 1705, STRICT_NOTEQUAL 97, DIFFERENT 143 -> 138,
BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1
of 2346.

Probe residues of earlier passes this pass closes (tools/probe, not gate cases):

| case | pristine | final |
|---|---|---|
| v11u411repro/cases/VM/vm04 (goal 1) | rc=4 NOT_EQUAL | rc=0 **STRICT_EQUAL** |
| v11u411repro/cases/VM/vm06 | rc=0 NOT_EQUAL (cmp 120) | rc=0 **STRICT_EQUAL** |
| v11u409repro/cases/VI/vi20 | rc=0 NOT_EQUAL (cmp 76) | rc=0 STRICT_NOTEQUAL fullname |

## Goal 1 (what upstream slang accepts, slang-uhdm must accept)

- (a) THE PROBE FACES: `C::mk().s` (VM/vm04) exits 0 and is STRICT_EQUAL
  (§ classCallResultMemberRef413); `u.mk(x).a` (VM/vm06) STRICT_EQUAL
  (§ ifaceCallResultMemberElem413).  Two more goal-1 shapes found and written
  on the way: a member of a call through a class HANDLE (`h.mk().s`,
  `other.mk().s`, CM/cm08, cm10, cm11, exit 4 "member access base" on
  pristine) and the unscoped call inside the class (`mk().s`, cm05).  The
  package cast outside a parameter declaration (the narrowing of pass 411's
  two package-cast laws) was NOT widened: its only measured firing outside a
  parameter is uvm_pkg's `uvm_severity'(UVM_ERROR)` default argument, which
  already exports (exit 0) and moved 9 surelog databases in a typespec identity
  only; no exit-4 shape outside a parameter declaration was found.
- (b) BLACK-PARROT: not lifted.  bp_unicore alone on law5 with the guard on:
  exit 3 (`basic_string::substr`, the guarded crash) in 13.1 s at 821 MB max
  RSS (runner row: surelog CRASH -11, slang REJECT 3, 12.9 s).  No
  memory-bounded export found; the six rows stay SURELOG_CRASH behind
  § macroVecLitTokenText403's size guard.
- (c) generated/rsd/rsd.sv: SURELOG_CRASH, not this ground.
- (d) The 75 SURELOG_ONLY details all carry an upstream slang `error:` line
  (75 of 75; 0 BOTH_REJECT / SURELOG_ONLY / SLANG_CRASH details name an
  exporter "unsupported" message; positive control: CM/cm01 on pristine
  writes "member access base" in its log).  None is this ground's.


## Laws (switch; cases)

- § classCallResultMemberRef413 — `R11U413_CLSCALLMEMBER_OFF` (ExprEmit, the
  member-access branch, ahead of § callResultMemberDropped411).  GOAL 1.  A member
  of a CLASS method call's result written with a class scope (`C::mk().s`,
  `C#(2)::mk().s`, `pk::C::mk().s`) is golden's bare, unbound ref_obj named by
  the scope's FIRST name and the method name (`C::mk`, `pk::mk`), spanning the
  written scope through its last `::` (cm01 `C::` 10:15-10:18, cm02 `Abcd::`,
  cm03 `pk::C::` 12:15-12:22 named `pk::mk`, cm06 `C#(2)::` 10:15-10:22), no
  implicit net, arguments and member dropped; the same call written unscoped
  inside the class (`mk().s`, cm05) is a func_call spanning the whole access,
  linked to the method (§ callResultMemberDropped411's shape, which excluded
  class subroutines); through a HANDLE (`h.mk().s`, `h.mk(3).s`,
  `other.mk().s`, cm08, cm10, cm11) the hier_path of
  § ifaceCallResultMemberElem413 below (that branch reads
  `R11U413_IFCALLMEMBER_OFF` as well).  The exporter rejected the base
  ("member access base", exit 4) where upstream slang accepts (v11u411
  VM/vm04).  Cases CM/cm01-cm12 (cm12 the control: a scoped call read whole).
- § ifaceCallResultMemberElem413 — `R11U413_IFCALLMEMBER_OFF` (ExprEmit, in
  § callResultMemberDropped411's branch).  `u.mk(x).a` through an INTERFACE
  instance is golden's hier_path `u.mk` spanning the whole member access, with
  a THIRD path element: a nameless method_func_call at the member name carrying
  a copy of the call's arguments (mi01 16:22-16:23 over `.a`); every argument
  of both call elements is named through the call path (`work@top.u.mk.x`,
  as a plain `u.mk(x)` already reads, mi06).  The copy covers ref_obj,
  constant and operation trees without a typespec (mi02 two arguments, mi03 a
  constant, mi04 none, mi05 an operation); anything else abstains.  Cases
  MI/mi01-mi06 (mi06 the control), CM/cm08, cm10, cm11 (handles); v11u411
  VM/vm06.
- § ifaceArrElemArgBitSel413 — `R11U413_IFARRELEM_OFF` (ExprEmit, the
  ArbitrarySymbol branch).  An element of an interface instance ARRAY written
  with one literal or simple-name index (`s[1]`, `s[P]`) read as a call or
  constructor argument or an assignment's operand is golden's bit_select named
  by the array, full name `<scope>.s`, spanning the INDEX alone, its index a
  UINT constant at size 64 (a name: an unbound ref_obj) at the same span,
  where ours was a ref_obj named `s[1]`.  A port connection (r11u4repro/g2,
  v11u412 VG/vg04: measured movers of a first draft, abstaining now) and a
  system call's argument keep their own rules.  Cases AI/ai01-ai05 (ai05 the
  dotted control); sv-tests hdlconvertor std2017 p770.
- § shallowCopyLhsUnbound413 — `R11U413_COPYLHS_OFF` (ExprEmit, the
  assignment branch's `= new` Lhs re-parent).  A SHALLOW COPY `y = new x;` takes
  the class `new`'s Lhs shape: the ref_obj unbound under the artifact
  hier_path `y` (sc01, sc03, sc04 in module processes and functions; sc02 in a
  class method, bytes only), where ours bound it to the module net.  Cases
  SC/sc01-sc05 (sc05 the handle-copy control); sv-tests chapter-8/8.12.
- § emptyConcatArrayVar413 — `R11U413_EMPTYCONCAT_OFF` (ExprEmit, the
  concatenation branch).  The empty queue `{}` is golden's unnamed, unparented
  array_var at the braces, vpiArrayType 4 whatever the target, typed through
  an unnamed ref_typespec onto an empty array_typespec, where ours was an
  operand-less concat operation.  Cases EQ/eq01-eq06 (eq06 the non-empty
  control); sv-tests chapter-7/queues/delete_assign.sv.
- § superMemberHierPath413 — `R11U413_SUPERMEMBER_OFF` (ExprEmit, the
  NamedValue branch).  A base-class property read through `super.` is golden's
  hier_path `super.value` spanning the written chain, both elements bare
  ref_objs `super` and `value` at the MEMBER token; written as an lvalue the
  hier_path spans `super` alone and its member element is the unlocated scoped
  ref.  Cases SU/su01-su04; sv-tests hdlconvertor std2017 p181_2.
- § stdRandomizeFuncCall413 — `R11U413_UNQRAND_OFF` (ExprEmit, the Call branch,
  beside § stdRandomizeIsScopeRef403).  The UNQUALIFIED scope randomize
  `randomize(a, b)` outside a class is golden's func_call `randomize` over the
  whole call with every argument an ordinary bound reference, where ours made
  the first argument a receiver (`hier_path addr.randomize`).  A `with` block,
  a class body (the syntax ancestors) and `std::` abstain.  Cases
  RZ/rz01-rz04 (rz02, rz04 the `std::` controls); sv-tests hdlconvertor
  std2017 p537.
- § unitTdCloneNoPrefixBit413 — `R11U413_UNITBITCLONE_OFF` (ParamEmit, inside
  § modImpTdParamTsClone409, narrowing § tdCloneNoPrefixAbstain409v).  The
  verifier's abstention no longer covers a `$unit` BIT-VECTOR typedef
  (`typedef bit [7:0] i_t`): there pristine's copy is uhdm-cmp unequal and the
  law's clone judge-equal with one alias-ref full name left (golden
  `work@top.u.i_t`, ours `i_t`).  The int and byte twins keep the abstention
  (STRICT_EQUAL on pristine, nu02, nu04), a scalar `bit` keeps it (no gain,
  nu03).  Cases NU/nu01-nu06; v11u409 VI/vi20.

## Grid (cases/, 48 case dirs; evidence/grid_law5.txt)

`drivers/grid.sh /tmp/r11u413_bin/pristine /tmp/r11u413_bin/law5 <out>`: per
case pristine and final (exit code, uhdm-cmp lines, dump distance, md5, strict
verdict), R11U413_OFF and the group's own switch against pristine's bytes.

- 35 cases reach STRICT_EQUAL from NOT_EQUAL: AI/ai01-ai04, CM/cm01-cm05,
  cm07-cm11, EQ/eq01-eq05, MI/mi01-mi05, RZ/rz01, rz03, SC/sc01, sc03, sc04,
  SU/su01-su04 (12 of them CM cases moving exit 4 -> exit 0).
- CM/cm06 (`C#(2)::mk().s`) exit 4 -> exit 0, still NOT_EQUAL at 19 cmp
  lines: its head is the parameterized class's own parameter typespec ref
  (`C.W.W`, the class listing, sister ground), the call face itself golden's.
- NU/nu01 NOT_EQUAL (cmp 76) -> STRICT_NOTEQUAL fullname (the alias ref
  `i_t` where golden writes `work@top.u.i_t`); NU/nu05 (two instances, one
  default) NOT_EQUAL on both, 118 -> 104 dump lines toward golden.
- 11 controls byte-identical: AI/ai05, CM/cm12, EQ/eq06, MI/mi06, NU/nu02,
  nu03, nu04, nu06, RZ/rz02, rz04, SC/sc05.  SC/sc02 (a class method, the ref
  already unbound) STRICT_EQUAL on both, bytes moved to golden's hier_path
  parent (dump distance 10 -> 2).
- R11U413_OFF gives pristine's bytes and exit code on 48 of 48; each case's
  own switch on 48 of 48 (the handle cases cm08, cm10, cm11 through
  R11U413_IFCALLMEMBER_OFF, which their branch reads with the class switch).
- Downstream on the class-free cases (evidence/downstream_cases.txt):
  MI/mi01, mi05 STATUS_DIFF -> IDENTICAL, mi02-mi04 EQUIVALENT -> IDENTICAL,
  mi06, NU/nu01, nu02, nu04, nu06, EQ/eq01, eq06 IDENTICAL on both, NU/nu05
  EQUIVALENT on both, NU/nu03 DIVERGENT on both (pristine's bytes).

Byte controls on earlier passes' grids: every `dut.sv` under tools/probe/
r11u4*repro and v11u4*repro (1712 case dirs, fence-filtered, pass 4's
r11u4repro included by the glob; drivers/md5run.sh;
evidence/earlier_pass_cases_md5_pristine_vs_law5.txt): the same exit code and
bytes on 1709; the 3 movers are the targeted residues v11u409 VI/vi20,
v11u411 VM/vm04 and VM/vm06 (evidence/earlier_pass_movers_law5.txt).  A
first draft of § ifaceArrElemArgBitSel413 also moved r11u4repro/g2 (an
interface-array element as a PORT actual, away by 6 dump lines) and v11u412
VG/vg04 (bytes only); the law was fenced to call arguments and assignments
before the sweep and both are back at pristine's bytes.

## Gates (the measurement budget: one full sweep, on law5)

drivers/sweep.sh: the four corpus stages through the worktree's
tests/sweep.sh, the sv-tests stage through the main tree's
scripts/check_svtests.py read-only (identical to the base's) with the
worktree's baseline, a worktree having no UVM tree; R11U413_TRACE on;
evidence/sweep_law5.

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0
  conversions=0 changes=0.
- surelog: default CMP_EQUAL 480 (CMP_NOTEQUAL 4), testflags 474 (4),
  regressions=0 conversions=0 changes=0.
- uhdm2rtlil: 803/1/67 in both modes, regressions=0 conversions=0 changes=0.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not
  identical and not excused 0.
- sv-tests: regressions=0 conversions=5 changes=0 (the five rows above).
- canaries ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil);
  ctcan2 PASS on both.
- byteverify against the master's control /tmp/intr11u411 (same-length
  workdir names): uhdm2rtlil 0 of 1608, downstream 0 of 805, surelog 2 of 962:
  SVSwitch default and testflags, PREDICTED BY NAME before the sweep (a
  targeted pristine/law3 run of SVSwitch and ThisHier from the source scan's
  hits, evidence/prediction_scan_*.txt): § shallowCopyLhsUnbound413 on
  Driver.sv:38 `pkt = new gpkt;` in a class method, the ref already unbound,
  its parent now golden's hier_path `pkt` (the golden dump's line 407, both
  modes); status CMP_EQUAL / equal unchanged.  SELFCHECK 961 of 962 flagged.
- the trace census (evidence/sweep_law5/trace_census.txt): probe,
  uhdm2rtlil and downstream no firing; surelog: SVSwitch d/t (above) and
  § stdRandomizeFuncCall413 twice per UVM design (BuildUVMPkg, MiniAmiq,
  Scoreboard, SeqDriver, SimpleUVM), uvm_sequence_library's
  `randomize(select_rand)`, byte-neutral (byteverify 0 movers there: the
  bound output equals pristine's call); sv-tests: the five converted rows,
  p179 (§ shallowCopyLhsUnbound413, `base3 = new ...`; DIFFERENT on both,
  58 cmp lines on both, 49 -> 41 dump lines toward golden) and the same
  byte-neutral uvm_sequence_library firing on 156 (UVM-library) rows besides p537 UVM rows; the
  path-normalized dumps of the firing rows kept by both the control and the
  law sweep: 155 of 157 identical to the control; the two movers p179 (above) and generated/uvm-examples/uvm_many_to_one (§ emptyConcatArrayVar413 on its own `= {}` at line 92:18, now golden's array_var there; DIFFERENT on both, the head elsewhere) (evidence/sweep_law5/
  svtests_firing_rows_normdump_ctl_vs_law5.txt, drivers/svnorm.sh).
- the binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name law5,
  0 another, 50 hold no slang line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of
  2346.
- the away census: every sv-tests row the laws fired on that is not EQUAL is
  identical to the control by normalized dump except p179 and
  uvm_many_to_one, both moved toward golden; no corpus status moved.


## Residues (ranked; all wrong on pristine too)

1. A foreach over a local array whose name is also a `$unit` class or
   typedef (the head of chapter-18/18.5.9--global-constraints_1,
   18.5.13--constraint-guards_1 and 18.14--random-stability_1:
   uvm_reg_block::find_blocks' `foreach (b[idx])` against the test's
   `class b`): Surelog's late typedef binding resolves the iterated
   placeholder by NAME, so golden writes an unnamed class_var (full name the
   subroutine's) typed by a class_typespec `b` (instance the home package,
   class_defn the $unit class), an int_var over the typedef's own typespec for
   `typedef int b`, and in the elaborated listing the loop variable falls back
   to an int_var; ours keeps the ref_var over the unsupported placeholder
   (StmtEmit's foreach array branch).  Decoded, cases
   evidence/residue_cases/FB fb01-fb05, not written (both views and the loop
   variable's fallback would move together).
2. NU/nu01's alias-ref full name (`work@top.u.i_t`): the no-prefix copy
   has no instance path in makeParamTs; and the bit typedef with two
   instances (nu05).
3. CM/cm06 and VT/vt05-style class-parameter faces (sister ground).
4. scr1 (generated/scr1/scr1.sv): an unsized `'d2000_000` localparam's
   elaborated constant is `INT:2000000` at size -1 in golden where ours has
   32; a module localparam alone reproduces golden's 32
   (evidence/residue_cases/UD ud01-ud05; ud03 the `'o17` decompile, ud05 an
   overridden `'d` parameter's INT/UINT), so the distinguisher is still open.
5. fx68k: the `$unit` localparams listed at design level (UhdmExporter, sister
   ground); tnoc at 333:14; p733 (a cross-top defparam golden ignores: the
   whole instance would need re-elaboration without it); p765 (an extern
   interface task called as a func_call, plus a labeled statement); p292 (a
   let call); class_test_51 (UhdmExporter's class parameters, below).
6. The backlog of passes 401 to 411 not reached (the residue lists of their
   READMEs), and the 69 probe STRICT_NOTEQUAL residues.

## Sister-ground faces (reported, not written)

- ModuleEmit, the elaborated variable listing's "Bare-decimal inits size at
  the var type width" (`((UHDM::constant*)e)->VpiSize(dt->getType()
  .getBitWidth())` after `emitExpr` in the struct/var initializer branch): a
  variable typed by an OVERRIDDEN type parameter (`p2 j = 0;` with `p2 =
  shortint` overridden to `int`) is sized by the parameter's DEFAULT type in
  golden (16; `byte` default -> 8 for a `longint` override, `logic [7:0]`
  default -> 8 for `int`), a sized literal keeps its own size
  (evidence/residue_cases/TP tp01-tp06; hdlconvertor std2012 p88, std2017
  p124).
- ModuleEmit's gate terminal (`setLoc(e, aloc)` / the `sel307->selector`
  respan in the primitive terminal loop): a gate terminal's bit_select whose
  index is wholly parenthesized (`a[(i % 3)]`, `a[((i+1))]`, `a[( i+1 )]`) is
  spanned over the parentheses in golden, ours over their content
  (evidence/residue_cases/GP gp01-gp06; gp07, gp08 the continuous-assign
  controls, equal); v11u411 VD/vd09.
- TypeEmit's enum_const emission: `P = -4'sd3` is `INT:-3` (decompile `-3` in
  the elaborated typespec) in golden, ours `BIN:1101` / `-4'sd3`; the
  substituted constant copies it (v11u411 VF/vf03).
- TypeEmit `emitSyntaxExpr` in the definition listing: the basejump
  macro-built bounds (`(width_p-1)`, `` `BSG_MAX(...) ``, `(i`, `1)` written
  as ref_objs named by raw text in a ref_module port's high_conn and in
  part-select bounds: bsg_async_fifo, launch_sync_sync, sync_sync, bsg_cache,
  mem_1r1w/1rw_sync_mask_write_var, mul_array, nonsynth_dramsim3,
  mask_write_byte_assoc), the hier_path name `8 * 2 *  * i` for `8*(2**i)`
  (cache_non_blocking_data_mem), and § genBlockBitsKeepsSelect200's
  definition half keeping `$bits(<name>)` in a generate-if body
  (bsg_source_sync_channel_control_master).
- TypeEmit's module typedef ranges in the elaborated module (`$clog2` kept,
  `(x)>(y)` kept: bsg_comm_link, bsg_round_robin_fifo_to_fifo) and a
  parameter's unpacked-array element range kept unfolded
  (bsg_nonsynth_dpi_rom, `bit [width_p-1:0] arr_p [..]`).
- UhdmExporter's class parameters (`$bits(int)` folded at the `$bits` span,
  generic/class/class_test_51.sv; the class listing's emitSyntaxExpr reads
  `int` as a ref_obj), the `$unit` localparams at design level (fx68k).

## Process

- One full five-stage sweep on law5.  THE IMPLEMENTER'S SLIP: the first
  launch of that sweep overlapped a live targeted runner of the sister pass
  r11u416 (the launch's own pgrep printed it); the sweep was stopped by its
  recorded PIDs within a minute (its probe stage only), its workdir deleted,
  and relaunched once the machine read quiet for a minute (drivers'
  quiet.sh-style wait excluding itself).  Two earlier background waiters
  self-matched their own pgrep pattern and were stopped by task id.  No other
  agent's process touched.
- One edit to src/ExprEmit.cpp landed while a law build was compiling; the
  file was touched and rebuilt before that binary was used.
- Pristine runner calls on the non-UVM DIFFERENT rows and on fx68k, scr1 and
  easyUVM read the heads; the cache served the Surelog side.  The fence list
  was written to a file by a program and never printed; every tree-wide list
  (the 43313-file source scan, the 1712 earlier-pass cases, the cmds.txt
  audits) was filtered on it before any file was opened.
- No fenced test named, opened or run.

