# r11u429 — the expression/parameter ground, fifteenth pass of the sv-tests campaign

Base 54e2aae2d (pass 427 on top of passes 428 and 430). Ground: src/ExprEmit.cpp,
src/EmitHelpers.h, src/StmtEmit.cpp, src/ParamEmit.cpp (this pass touches
src/ExprEmit.cpp only). Pristine = the worktree's build at the base, md5
7367e445066cacd63a0fb9e00c939e15 (equal to the main tree's build/slang-uhdm),
frozen as /tmp/r11u429_pris/slang-uhdm and used only for case runs and
targeted runner calls; the pristine sweep reading is the master's control at
the base, /tmp/intr11u427. FINAL law binary md5
a68b561e10c30ef8b8f1e9ad8bc58506 (/tmp/r11u429_law5/slang-uhdm, the worktree's
build/slang-uhdm at the patch).

## Laws

Both in src/ExprEmit.cpp, read through src/LawSwitch.h (`lawOn(429, ...)`);
`R11U429_OFF` drops both, `R11U429_TRACE=<dir>` logs each firing
(`lawTrace(429, ...)`). No src/R*.h, no getenv, no LawState.h section.

1. § unitClsCastPkgEnumTdTopListing429 (switch `R11U429_UNITCLSCAST_OFF`;
   ExprEmit's explicit-conversion branch, the typedefTs branch beside
   § pkgFnCastTopListing172). A cast to a PACKAGE enum typedef written in a
   subroutine of a class declared in the compilation unit reaches the
   package's ELABORATED typedef listing (pkgTopTypedefTs: the copy whose base
   range is folded), as that class's declarations typed by the typedef
   already do, not the definition listing. Surelog compiles a $unit class
   after the packages are elaborated and its cast branch binds the typedef's
   current typespec, the elaborated copy. THE RADIX-ENUM FACE of the 4
   testbenches rows (reported by passes 427 and 428): golden
   testbenches/uvm_agent_active.sv lists, under
   `packet_in::__m_uvm_execute_field_op`'s six `uvm_radix_enum'(...)` casts
   (uvm_object_defines.svh `m_uvm_field_radix`, through the
   uvm_comparer/uvm_recorder/uvm_printer field macros), the uvm_radix_enum
   copy located at uvm_recorder.svh 976:32 whose base `uvm_field_flag_t`
   range reads `INT:27`; we reached the definition listing's copy at
   uvm_printer.svh 1076:47 whose range is the operation
   `UVM_FIELD_FLAG_RESERVED_BITS-1` (uhdm-strictcmp `#205756 type`,
   `A: constant INT:27`, `B: operation`). Cases RC.

2. § genBodyBitsOuterNameKeeps429 (switch `R11U429_GENBITSNAME_OFF`;
   ExprEmit's `$bits` keep decision, after § genBlockBitsKeepsSelect200). In a
   PROCESS of a generate scope a `$bits` whose argument is a bare name of a
   net or variable keeps its sys_func_call (ref_obj named through the scope,
   e.g. `work@top.g.x`): in the definition's process (named_begin) for every
   such name, in the elaborated gen_scope's process for a name declared
   outside every generate block (a module-level signal or port); a name
   declared inside the block folds in the elaborated view (golden UINT:5 with
   its location), as before. Surelog compiles generate items unreduced and its
   compileBits finds no typespec for a name of the enclosing module from the
   generate scope, so it mints the call; a gen-scope process is copied, not
   re-reduced. Measured on initial, always, always_comb, always_ff, gen-if,
   gen-for, nested blocks, a port and a select index (cases GB). NOT this
   law: a continuous assignment's right side, which the elaboration reduces
   whole (golden: ONE constant with no location sized at the left side, gb01,
   gb02, gb05, gb12, gb14: residue), and its definition view, which TypeEmit
   writes (the sister's; below).

## Grid (tools/probe/r11u429repro/cases, drivers/grid.sh; evidence/grid_law5.txt)

39 case dirs, every exit code 0 on both binaries, `R11U429_OFF` and each
case's own switch giving pristine's bytes on 39 of 39:

- RC (13, § unitClsCastPkgEnumTdTopListing429): rc01 (import + cast in a $unit
  class method), rc04 (p::e_t'(...) qualified), rc10 (task), rc11
  (parameterized $unit class), rc12 (enum with an inline ranged base)
  STRICT_NOTEQUAL type -> STRICT_EQUAL; rc07 (int-based enum) STRICT_EQUAL on
  both with the other listing referenced; rc05 (a cast as a package-call
  argument in a derived class) and rc09 (out-of-body method) NOT_EQUAL on
  both (uhdm-cmp 29 lines, the io_decl head golden lacks), dump identical
  after id normalization; rc13 NOT_EQUAL on both (29 lines), sorted-dump
  distance 159 -> 155 toward golden; controls rc02 (vector typedef cast, the
  alias-clone path), rc03 (module function), rc06 (class in a module,
  STRICT_NOTEQUAL fullname), rc08 (class in another package, NOT_EQUAL 62)
  byte-identical.
- GB (26, § genBodyBitsOuterNameKeeps429): gb09 (always_comb), gb15
  (initial), gb16 (always_ff, `$bits(x) - 1`), gb17 (gen-for), gb18
  (block-local name, definition process), gb19 (a port), gb20 (nested gen
  blocks), gb21 (`$bits(x)` in a select index), gb24 (gen-for, block-local)
  NOT_EQUAL -> STRICT_EQUAL; controls byte-identical: gb11, gb22 (no generate),
  gb23 (process-local), gb25 (parameter-width signal), gb26 ($size); and the
  continuous-assignment residues gb01-gb08, gb10, gb12-gb14 byte-identical.
- Downstream (evidence/downstream_GB.txt): the 11 GB process cases IDENTICAL
  on both binaries.

## The one five-stage sweep (law5; drivers/fullsweep.sh, R11U429_TRACE set throughout)

Four corpus stages by tests/sweep.sh --jobs 3 from the worktree, the sv-tests
stage through the main tree's scripts/check_svtests.py with --baseline the
worktree's results/golden_svtests.csv (a worktree has no UVM tree); launched
after three quiet readings; workdir /tmp/r11u429sw1 (evidence/fullsweep_law5.log).

| stage | reading | vs baseline |
|---|---|---|
| probe | EQUAL 4018, STRICT_NOTEQUAL 69 of 4087 | regressions 0, conversions 0, changes 0; csv identical to the control |
| surelog | default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL standing) | 0 / 0 / 0; csv differs from the control only in the two LowMem log-path texts |
| uhdm2rtlil | 803 / 1 / 67 in both modes | 0 / 0 / 0; csv identical to the control |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | csv identical to the control |
| sv-tests | EQUAL 1892, STRICT_NOTEQUAL 6, DIFFERENT 42, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346 | regressions 0, conversions 0, CHANGES 4 (below); every other row identical to the control |

THE FOUR CHANGES (all § unitClsCastPkgEnumTdTopListing429; each row's strict
head moved later in the walk, from the radix-enum face of this ground to two
faces of the sister's ground; evidence/svtests_law5_vs_control.diff,
evidence/uvm_agent_active_strict_heads.txt):

- `testbenches/uvm_agent_active.sv,STRICT_NOTEQUAL,differ:file(2),differ:file(2)` (was `differ:type(1)`)
- `testbenches/uvm_agent_passive.sv,STRICT_NOTEQUAL,differ:file(2),differ:file(2)` (was `differ:type(1)`)
- `testbenches/uvm_driver_sequencer_env.sv,STRICT_NOTEQUAL,differ:file(2),differ:file(2)` (was `differ:type(1)`)
- `testbenches/uvm_monitor_env.sv,STRICT_NOTEQUAL,differ:file(2),differ:file(2)` (was `differ:type(1)`)

uhdm-strictcmp on uvm_agent_active at the base: `#205756 type` (golden the
elaborated uvm_radix_enum copy's `constant INT:27`, ours the definition
listing's `operation`), objects 444579 vs 444600; with the law: `#206401 file`
then `#219489 depth`, objects 444579 vs 444576 (the counts now 3 apart, were
21). The 16 uvm-examples rows' first difference is not this face (their
uhdm-cmp heads are package / interface / class listing vectors, the sister's
faces of passes 426 and 428); the law does not fire on them.

## Prediction before the sweep, trace census, byte census

Prediction (evidence/prediction_law5.txt; drivers/scan.py, map.py, svscan.py):
a fence-filtered source scan (20657 corpus and probe files listed, 20646 after
the fence; 2346 sv-tests rows with their :files: and include dirs) for casts
in files declaring a class or using the uvm_field macros (law 1) and for
`$bits(<name>)` beside a process keyword and a generate construct (law 2),
then traced targeted runs of the candidates on law5: 34 surelog rows (both
modes), 7 uhdm2rtlil rows (both modes), 64 probe cases, 534 sv-tests rows. No
corpus row or probe case fires (statuses and strict columns identical to the
control); on sv-tests law 1 fires on 8 rows and law 2 on none; the 4
testbenches rows predicted at `differ:file(2)`, easyUVM and the 3
uvm_scoreboard testbenches rows DIFFERENT with their uhdm-cmp line counts
unchanged (659635, 2200983, 2231211, 2216265 on both binaries).

Trace census of the sweep (evidence/trace_census_sweep.txt): exactly the
predicted 8 sv-tests databases (easyUVM/top 18 firings, the 7 testbenches
uvm_* rows 6 each), no corpus row, probe case or downstream row; law 2 fires on
no gate row (its grid is its evidence).

Byte census (evidence/byteverify_law5.txt, tools/probe/r11v75repro/byteverify.sh,
SELFCHECK=1, law workdir against the master's control /tmp/intr11u427, equal
workdir name lengths): surelog 0 of 962 (selfcheck 961/962), uhdm2rtlil 0 of
1608 (1607/1608), downstream 0 of 805 (804/805); probe 4087 of 4087 identical
by path-normalized uhdm-dump (the databases embed the worktree's source path).
Canaries (evidence/canaries_law5.txt): ok=52 and ok=16 with changed 0;
`EXPECT_UNKNOWN=1 ctcan2.sh` and `EXPECT_UNKNOWN=6 ctcan2.sh` PASS. Binary
audit (fence-filtered): 5609 of 5659 command records name
/tmp/r11u429_law5/slang-uhdm, the other 50 hold only a Surelog line. Law index:
`scripts/law_index.py --check` current at the sweep (the corpus stage rc 0) and
regenerated after this README.

## Goal 1

Nothing on this ground: the detail column of every SURELOG_ONLY, BOTH_REJECT
and SLANG_CRASH row of results/golden_svtests.csv names no exporter message;
all 75 SURELOG_ONLY rows carry an upstream slang front-end diagnostic (e.g. 5
"expected a declaration name", 2 "design element does not have a time scale
defined", 2 "use of undeclared identifier 'switch'", 2 "unknown module
'sparc_exu_aluor32'", 2 "expression type 'real' is not integral"). The probe
shapes C::mk().arr[1], u.mk(x).a[2] and this.mk().inner.s stay as passes 417
to 427 left them (Surelog rejects, upstream slang accepts; not forced). The
black-parrot guard (§ macroVecLitTokenText403) untouched, not remeasured (no
row of this pass reaches it); generated/rsd/rsd.sv SURELOG_CRASH, not ours.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The continuous-assignment half of the gen-scope `$bits` face (GB gb01,
   gb02, gb05, gb07, gb08, gb12, gb13, gb14): golden's ELABORATED gen_scope
   reduces the whole right side to ONE constant with no location, sized at
   the left side (`assign y = $bits(k)` -> UINT:32 size 32; `$bits(x) > i` ->
   size 1; `$bits(x) - 1` -> INT:4 size 4), where we fold the call alone to a
   located 64-bit constant; and its DEFINITION view keeps the call (TypeEmit,
   below). A block-local name in a continuous assignment (gb03, gb04) folds
   with its location in golden but at the reader's size (4) and parented at
   the cont_assign, ours size 64 unparented.
2. `$bits(W)` of a module parameter in a generate block (gb06): golden reads
   UINT:0 (a Surelog artefact), not written.
3. A generate-block localparam initialized by `$bits(x)` (gb10): elaborated
   param_assign head, not decoded.
4. Law 1 not reached: a class inside a module (RC rc06, STRICT_NOTEQUAL
   fullname: golden `work@top::C::p::e_t`, ours `work@top.p::e_t`), a class in
   another package (rc08, uhdm-cmp 62 lines), and the io_decl head of rc05,
   rc09, rc13 (golden lists no io_decl for a function's int argument there;
   uhdm-cmp 29 lines on both binaries).
5. The carried backlog of passes 427 and earlier (the brief's items (a) to
   (s)), untouched by this pass: pass 427's x / z parameter residues (VX/vx05,
   VD/vd04, vd11, vd13, vd14, VE/ve18, ve26, VS/vs09, VE/ve04, EB, XP, OT, OX,
   XO, TP/a07), pass 425's (UP/up05, ra04, OB, VB, VL, VQ, VN), pass 423's (CI,
   CO, US, UD, UO, VS), and the earlier lists; tnoc's 333:14 head (a Surelog
   artefact), fx68k's design-level CF parameter, p733's defparam.

## Sister-ground faces (reported, not written)

- The 4 testbenches rows' next strict head (`#206401 file`): the int_typespec
  of the `uvm_resource#(int)` specialization listed for a class-method local
  (`__tmp_rsrc__` in `uvm_resource_read`, uvm_resource_defines.svh 43:17,
  the `int` reaching it as a macro argument written in
  uvm_resource_specializations.svh) carries golden's file
  uvm_resource_defines.svh (the expanding macro's file) where ours carries
  uvm_resource_specializations.svh (the argument's spelling): UhdmExporter
  emitClassPropSpecParams163 (§ clsMethodLocalForeignPkgSpec428's builder)
  calling makeTypespec -> setLoc / fullFilePath (UhdmExporter.cpp).
- Their following head (`#219489 depth`): the class property
  `uvm_report_message_int_element::_val` typed `uvm_bitstream_t`: golden's
  per-use logic_typespec clone lists its own range (INT:4095 .. UINT:0) where
  ours lists none (the clone shares a range object already walked): TypeEmit
  tdVecNamedClone42 (the class-property typedef clone).
- The definition view of a generate block's continuous assignment
  (bsg_source_sync_channel_control_master 143:53 `$bits(out_calib_code)`;
  the r11u428 residue cases BB; GB gb01 to gb08): golden keeps every `$bits`
  call there, ours folds a module-level name: TypeEmit emitSyntaxExpr's
  `foldQuery` branch under ModuleEmit emitDefGenStmts (TypeEmit.cpp, the branch
  after § genBlockBitsKeepsSelect200's def half). The ExprEmit half (the
  processes) is § genBodyBitsOuterNameKeeps429 above.

## Process

The IMPLEMENTER within the budget: one pristine build (the base, md5 equal to
the main tree's), five intermediate law builds (law1 to law5) used on case
runs and targeted runner calls only, one full five-stage sweep on the final
law5 binary. Slip, none affecting a measurement: the first traced
prediction run (verify_golden.py --filter on the 34 surelog and 7 uhdm2rtlil
candidate rows) was chained after a process check that printed the sister
r11u432's live corpus sweep without waiting on it, so it overlapped that sweep
for its few minutes; every later run (the probe and sv-tests predictions, the
grid's downstream cases, the sweep) waited for a quiet machine. The fence
list was read into a file by a program without printing it and every
tree-wide list was filtered on it before any file was opened; no fenced test
named, opened or run; no other agent's process touched.
