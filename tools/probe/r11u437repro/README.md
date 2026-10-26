# r11u437 — expression/parameter ground, sv-tests campaign pass 437 (implementer)

Base 535fde87 (pass 435). Production files: src/ExprEmit.cpp, src/StmtEmit.cpp
(EmitHelpers.h and ParamEmit.cpp unchanged). Five laws, every one read through
src/LawSwitch.h (`lawOn(437, "R11U437_<LAW>_OFF")`, `R11U437_OFF` drops the
pass, `R11U437_TRACE=<dir>` logs each firing through `lawTrace(437, ...)`); no
src/R*.h, no LawState.h section, no getenv, no reader function.

## Verdict per targeted row

| row | before (golden_svtests.csv) | after (law sweep) |
|---|---|---|
| generated/uvm-examples/apb_protocol_monitor.sv | STRICT_NOTEQUAL differ:col(1) | **EQUAL** (`generated/uvm-examples/apb_protocol_monitor.sv,EQUAL,,equal`) |

The svtests stage reads `CONVERSION generated/uvm-examples/apb_protocol_monitor.sv:
STRICT_NOTEQUAL -> EQUAL`, `sv-tests: BOTH_REJECT=303 DIFFERENT=32 EQUAL=1907
SLANG_ONLY=19 STRICT_NOTEQUAL=1 SURELOG_CRASH=8 SURELOG_ONLY=75 TIMEOUT=1 (of 2346)`,
`regressions=0 conversions=1 changes=0`. The one STRICT_NOTEQUAL row left is
fx68k (the sister's ModuleEmit clone gate, pass 438).

## The laws

- § newLhsSelCgCopyAtIndex437 (ExprEmit, the `= new` arming site of
  § newLhsBitSelAtIndex181; switch R11U437_NEWLHSKIND_OFF). Surelog's
  blocking_assignment has one grammar alternative for every `class_new` right
  side (`new`, `new(args)`, the copy `new src`), and the parser does not know
  whether the target is a class or a covergroup handle; the `= new ...` branch of
  CompileHelper::compileBlockingAssignment builds the left side from the name
  node, so a one-index element select takes the rvalue anchor, its index.
  § newLhsBitSelAtIndex181 gated on sourceIsNewClassExpr55, which slang's
  NewCovergroup and CopyClass bound kinds miss: `APB_protocol_cg[i] = new();`
  (apb_monitor.sv 145, golden bit_select 145:21-145:22, ours 145:5-145:23) and
  `c[1] = new c[0];`. The apb row's last strict field.
- § newLhsVarSelNameSpan437 (ExprEmit; R11U437_NEWLHSVS_OFF). A multi-index
  element left side of a class-new assignment, `c[0][1] = new;`, is a
  var_select that golden spans over the NAME alone (5:15-5:16) where ours
  spanned the whole select (5:15-5:22). Class, covergroup and copy forms.
- § newLhsHpSelFirstSpan437 (ExprEmit; R11U437_NEWLHSHP_OFF). A dotted left
  side ending in an element select, `h.c[0] = new(2);`, `h.d.c[1] = new;`:
  golden's hier_path ends at its first name (`h`, 6:32-6:33) as
  § hpLvNewClassFirstElemSpan224 already wrote for member chains; that law
  read a MemberAccess top only.
- § foreachCgArrLoopVarRef437 (StmtEmit, the foreach emitter;
  R11U437_FECGREF_OFF). A foreach over an array of covergroup handles leaves
  its loop variables unresolved: paFOREACH (CompileStmt.cpp) mints every loop
  variable as a ref_var over an unsupported_typespec named for it, and
  UhdmWriter::swapForSpecifiedVar replaces it only with what
  CompileHelper::getSimpleVarFromTypespec makes of the array's element
  typespec; a covergroup type is an unsupported_typespec, which that switch
  has no branch for, so it returns null and the placeholder stays. Golden
  `ref_var i` over `unsupported_typespec i` where ours wrote the int_var
  fallback (v11u436 VC/vc05, the sister's reported StmtEmit face). The
  iterated reference binds the declaration's own unsupported_typespec (the
  definition net's `cg cs[3]` object, 4:1-4:9) where ours minted an
  array_typespec; the bind is deferred through pendingLoopVarTs9 when the
  net's typespec is still unbound, and abstains when it is anything other
  than the unsupported_typespec (a dynamic array or queue of covergroups
  whose variable carries an array_typespec, an instantiated interface).
- § dynArrNewElemLvalueBase437 (ExprEmit, dynArrayNewLvalueBase110;
  R11U437_DYNNEWELEM_OFF). The grammar alternative `nonrange_variable_lvalue =
  dynamic_array_new` collapses the lvalue to its base identifier with the
  whole lvalue's span whether or not it is dotted: `int d[2][]; d[0] =
  new[3];` golden ref_obj `d` 4:15-4:19 bound to the module's net, ours a
  bit_select with its index. § dynArrayNewLvalueBaseOnly110 required a dot;
  element selects (one or more) now take the same collapse, a range select
  does not.

## Grid (tools/probe/r11u437repro/cases, 40 case dirs; evidence/grid_final.tsv)

Every case's first line names its law. Columns: Surelog exit, pristine, law
(exit code, uhdm-cmp lines, strict verdict) and the path-normalized dump
distance to golden (unsorted u, sorted s).

- 17 to STRICT_EQUAL: NS/ns04, ns13, ns19 (§ newLhsVarSelNameSpan437),
  NS/ns05, ns18 (§ newLhsHpSelFirstSpan437; ns05 and ns18 STRICT_NOTEQUAL
  endcol), NS/ns06, ns11, ns16, ns20 (§ newLhsSelCgCopyAtIndex437; covergroup
  in an interface, copy in a module and in a class method), NS/ns15, FC/fc01,
  fc02, fc03, fc07, fc08, fc09 (§ foreachCgArrLoopVarRef437 with
  § newLhsSelCgCopyAtIndex437; NOT_EQUAL -> STRICT_EQUAL: module covergroup
  arrays, with arguments, 2-D `foreach (c[i,j])`, beside an int foreach, in a
  module task, twice), DN/dn05 (§ dynArrNewElemLvalueBase437, a class
  property `d[0] = new[3]`, NOT_EQUAL -> STRICT_EQUAL).
- 15 NOT_EQUAL on both binaries and closer by dump distance, none further:
  NS/ns07 and DN/dn01, dn02, dn03, dn08 (the collapse right; the next head the
  `int d[2][]` typespec range, golden `2-1` as an operation: TypeEmit, the
  sister's), DN/dn04, dn07 (subroutine locals; a typespec head), dn06 (queue
  and associative: an elaborated array_var golden does not list), NS/ns14 (the
  hier_path span right; the next head `foreach (h.c[i])` over a module class
  handle, golden int_var where ours writes array_var), NS/ns22 (exit 4 on both,
  a class property covergroup array), FC/fc04, fc10 (dynamic and queue
  covergroup arrays: loop variable right, the reference abstains; uhdm-cmp
  count up only because the head moved later to an extra elaborated array_var
  ours lists, dump distance 87 -> 70 and 90 -> 73), FC/fc05 (instantiated
  interface: golden's reference typespec is a fresh unsupported_typespec named
  after the array at the reference, residue), fc06 (program, 490 lines on
  both), fc11 (`int i` shadowing the loop variable).
- 8 byte-identical controls: NS/ns01, ns02, ns03, ns08, ns09, ns12 (one-index
  class new, § newLhsBitSelAtIndex181's own, and a plain element write), ns10,
  ns17 (unrelated faces).
- Every exit code equal on both binaries (0, ns22 4 on both). Surelog exits 4
  on the module covergroup cases with `Undefined type "cg"` and still writes
  its database (the golden used).
- Switches (evidence/grid_switches.txt): R11U437_OFF gives pristine's bytes
  and exit code on 40 of 40; each case's own switch restores pristine on 28,
  the 12 foreach cases needing R11U437_FECGREF_OFF together with
  R11U437_NEWLHSKIND_OFF since each also assigns `cs[i] = new`.
- Downstream (evidence/grid_downstream.tsv, the 22 class-free cases):
  NS/ns07, DN/dn01, dn02, dn08 DIVERGENT -> IDENTICAL, dn03 EQUIVALENT ->
  IDENTICAL; none leaves IDENTICAL, the rest unchanged.

## Gates (law binary law3, md5 c98178f96356a1857de530783a24f19b; pristine = main tree build fd1a6e97920597b5c8c497956b4e6f1a, not rebuilt)

One full five-stage reading on the final binary: tests/sweep.sh --jobs 3
--workdir /tmp/r11u437_LW --corpus 'probe surelog uhdm2rtlil downstream' from
the worktree, then the svtests stage through the main tree's tests/sweep.sh
--corpus svtests on the same workdir (the worktree's UVM submodule is empty;
the main tree at the same base 535fde87, clean; that run's exit 1 is its law
index check reading the main tree's tests/LAWS.md stale, the stage itself
reads regressions=0).

- probe: EQUAL=4023 STRICT_NOTEQUAL=64, regressions=0 conversions=0 changes=0;
  the 4087 databases identical to the master's control /tmp/intr11u435 by
  path-normalized dump (4087 SAME; positive control two different databases
  3180 lines apart).
- surelog: default CMP_EQUAL=480, testflags 474, regressions=0 conversions=0
  changes=0; the csv differs from the control only in the two LowMem log-path
  texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0, csv identical to the control.
- downstream: IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2, csv identical.
- svtests: as above, the one conversion.
- byteverify (SELFCHECK=1) law against the master's control: 0 of 962, 0 of
  1608, 0 of 805, self-checks 961/962, 1607/1608, 804/805 flagged.
- canaries ok=52 (surelog) and ok=16 (uhdm2rtlil) changed=0; both ctcan2
  checks PASS.
- binary audit, fence-filtered: surelog 1531 of 1581 cmds records name law3,
  the other 50 hold only a Surelog line; uhdm2rtlil 1742 of 1742; sv-tests
  2346 of 2346.
- trace census (evidence/trace_census.txt): the laws fire on ONE database of
  all five stages, sv-tests apb_protocol_monitor (§ foreachCgArrLoopVarRef437
  on APB_protocol_cg, § newLhsSelCgCopyAtIndex437); no corpus row, no probe
  case. Predicted by name before the sweep from a fence-filtered scan of 43302
  corpus, probe and sv-tests sources: the `]= new` scan found the class-new
  shapes of § 181 (unchanged), two var_select shapes in the tnoc and
  rv_timer verification environments, which no corpus row and no sv-tests row
  compiles (Tnoc.sl and the sv-tests tnoc row list RTL only), copy-into-element
  shapes only in ovm macros and the ariane verification tree (compiled by no
  row), no undotted `x[i] = new[...]`; covergroup arrays under foreach in
  apb_monitor.sv (apb_protocol_monitor; uart_example also lists it and is
  BOTH_REJECT). The prediction (apb only) matched the trace.
- earlier-pass census: 5428 fence-filtered case dirs of tools/probe/r11u4* and
  v11u4* (passes 401 to 436 and this pass's 40) on pristine and
  law3: exit codes equal everywhere; 11 dirs exit 3 on both with no database;
  movers outside this pass's grid: 5, all to STRICT_EQUAL (r11u436
  IU/iu12 STRICT_NOTEQUAL col -> STRICT_EQUAL, iu13 NOT_EQUAL -> STRICT_EQUAL,
  v11u436 VC/vc03 STRICT_NOTEQUAL col -> STRICT_EQUAL, vc05 NOT_EQUAL ->
  STRICT_EQUAL, v11u413 VS/vs04 STRICT_NOTEQUAL col -> STRICT_EQUAL;
  evidence/earlier_pass_movers.tsv).

## Goal 1

Nothing on this ground. All 75 SURELOG_ONLY rows of the law sweep carry an
upstream slang front-end diagnostic (no detail names an exporter message;
`grep -ci 'unsupported|slang-uhdm:'` over their details reads 0); no
SLANG_CRASH row. The probe shapes, measured on law3 on a quiet machine
(upstream slang = ~/.local/bin/slang dut.sv --single-unit):

| case | upstream slang | Surelog | ours |
|---|---|---|---|
| v11u415 VT/vt03 (`this.mk().inner.s`) | 0 | 3 | 0 |
| v11u413 VC/vc04 (`C::mk().arr[1]`) | 0 | 3 | 4 |
| v11u413 VI/vi06 (`u.mk(x).a[2]`) | 0 | 3 | 4 |

Surelog rejects all three with a syntax error, so golden has no shape to copy
and none is forced. bp_unicore measured alone on law3: exit 3 (the
`basic_string::substr` message under pass 403's size guard) in 13.6 s at
835 MB maximum resident; no memory-bounded export, the guard stands.
generated/rsd/rsd.sv stays SURELOG_CRASH (Surelog dies first).

## Residues (ranked; all wrong on pristine too, none moved away)

1. The covergroup-array foreach in an INSTANTIATED interface (FC/fc05): golden's
   iterated reference carries a fresh unsupported_typespec named after the
   array at the reference, and the body's `i` binds an implicit net
   `work@top.u.i` in golden; the law's loop variable is right there, the
   reference abstains.
2. Dynamic and queue covergroup arrays (FC/fc04, fc10): golden's reference
   binds the declaration's unsupported_typespec, ours the array_var's
   array_typespec; and ours lists an elaborated array_var golden does not.
3. `foreach (h.c[i])` over a module-scope class handle's array property
   (NS/ns14): golden int_var, ours array_var (the dotted-root resolution of
   § foreachHierPathAlwaysRes21 is not Surelog's for a module handle).
4. The `int d[2][]` unpacked size range written `2-1` in golden (DN/dn01 to
   dn03, dn08, NS/ns07): TypeEmit, the sister's ground.
5. A program's covergroup array (FC/fc06) and a loop variable shadowing a
   module `int i` (fc11): unchanged heads elsewhere.
6. The carried lists of passes 435, 433, 431 and earlier (the brief's items
   (a), (c) to (x)), untouched by this pass.

## Sister-ground faces (reported, not written)

- `int d[2][]`: the unpacked size dimension's range, golden an operation
  `2 - 1` at 3:7-3:8 where ours folds UINT:1 at 3:6-3:9 (TypeEmit's range
  builder; DN/dn01).
- FC/fc04 and fc10: the elaborated module lists an array_var for a dynamic or
  queue covergroup array that golden does not list (ModuleEmit's variable
  listing).
- FC/fc05: an instantiated interface's ref_module and port listing beside the
  foreach (ModuleEmit).

## Process

- The implementer built once at the base in the worktree (the build raced an
  edit of ExprEmit, so the pristine reading is the main tree's build, frozen
  at /tmp/r11u437_bin/pristine, md5 equal to the brief's), then law1, law2 and
  law3 (the final). Intermediate binaries ran case grids only.
- Slips, none affecting a measurement: the first NS grid (21 cases, single
  sequential process) and the law2 build ran while the sister verifier
  v11u438's sweep was live (its svtests stage); later grids waited for quiet
  readings. The first quiet-waiter used a pgrep pattern that matched its own
  command line and was stopped by task id. The first sweep launch used a
  14-character workdir that byteverify cannot pair with the 15-character
  control; it was stopped by its recorded PID about a minute in (probe
  stage) and relaunched at /tmp/r11u437_LW. The earlier-pass census (case
  runs, three at a time) ran while the master's pass 438 integration sweep
  was live. The quiet check before the sweep matched the launching shell's
  own command line, which was the only match.
- The main tree was clean at 535fde87 when the svtests stage was launched
  through it; the master's pass 438 integration (ModuleEmit, tests/LAWS.md,
  results/golden_svtests.csv) appeared in the main tree afterwards. The stage
  read the base baseline (its one conversion is apb, every other row equal
  to the control csv).
- The fence list was read by a program into a file and never printed; every
  tree-wide list was filtered on it before any file was opened; no fenced
  test named, opened or run; no other agent's process touched.
