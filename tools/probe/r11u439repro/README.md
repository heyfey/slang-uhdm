# r11u439 — expression/parameter ground, sv-tests campaign pass 439 (implementer)

Base db1d84d3 (pass 437). Production files: src/StmtEmit.cpp and
src/ExprEmit.cpp (EmitHelpers.h and ParamEmit.cpp unchanged). Five laws, every
one read through src/LawSwitch.h (`lawOn(439, "R11U439_<LAW>_OFF")`,
`R11U439_OFF` drops the pass, `R11U439_TRACE=<dir>` logs each firing through
`lawTrace(439, ...)`); no src/R*.h, no LawState.h section, no getenv, no
reader function, nothing in include/.

## Verdict per targeted row

No sv-tests row is on this ground at the base, so none is targeted (see "Heads
at the base"). The pass works the probe backlog on this ground: pass 437's
residues FC/fc06 (a program's covergroup array) and FC/fc11 (a loop variable
named like a module variable), pass 417's residue "program scope where Surelog
leaves the foreach loop variable unresolved and we write an int variable"
(v11u417 VC/vc04, vc24, VT/vt19) and pass 437's "skipped slot cs[, j]" residue,
each one generalised to the face it belongs to.

The law sweep's sv-tests stage reads `sv-tests: BOTH_REJECT=303 DIFFERENT=32
EQUAL=1908 SLANG_ONLY=19 SURELOG_CRASH=8 SURELOG_ONLY=75 TIMEOUT=1 (of 2346)`,
`regressions=0 conversions=0 changes=0`, its csv identical to the master's
control on all 2346 rows: no sv-tests row moves, as predicted (no law fires on
any sv-tests row). The pass's movement is on the probe backlog (the grid below
and the earlier-pass census: 36 earlier case dirs to STRICT_EQUAL, among them
r11u437 FC/fc06 and fc11 and v11u417 VC/vc04 and VT/vt19); no gate row moves.

## Heads at the base

The runner (scripts/svtests/svtests_matrix.py, --keep-golden, the pristine
binary = the main tree's build, md5 24441d076ca367d92ef9d24c2ea0f9a4) on the 32
DIFFERENT rows of results/golden_svtests.csv, then uhdm-cmp on each kept pair
(evidence/heads_base.txt):

| rows | first differing object (golden / ours) | ground |
|---|---|---|
| 16 uvm-examples, easyUVM | package listing (uvm_pkg vs the test package first; test_lib_pkg, env_pkg, test_top_pkg vector sizes), class_defn work@sequencer vs null | module/type (sister) |
| 3 uvm_scoreboard testbenches | design: golden null handle | Surelog artefact |
| 6 basejump (channel_control_slave, comm_link_checker, 1rw_sync_assoc, dff_en_segmented, scheduler_dataflow, ascii_writer) | design vector size (module listing) | module/type (sister) |
| bsg_round_robin_fifo_to_fifo | operation 339:19 (width_p*num_out_p-1 kept) vs our constant | TypeEmit (sister) |
| bsg_mesh_stitch | logic_typespec 18:14 range `y_max_p-1` vs ours null | TypeEmit (sister) |
| p733 | constant 16:10 (the cross-top defparam) | report only |
| p737 | design work@M vs unnamed | module/type (sister) |
| tnoc | constant 333:14 (241, Surelog evaluating the function) | Surelog artefact |

None lands on ExprEmit, StmtEmit, ParamEmit or EmitHelpers.h.

## The laws

- § uninstProgBodyAsUninstIface439 (StmtEmit, UhdmExporter::emitProcess;
  switch R11U439_UNINSTPROG_OFF). A file-scope program no module instantiates
  is never elaborated by Surelog (golden lists it in uhdmallPrograms only, no
  top), and its one writer, UhdmWriter::writeProgram, calls neither
  lateBinding nor lateTypedefBinding; only writeElabProgram, the instantiated
  road, does. Those are the holder facts of UhdmWriter::writeInterface that
  § uninstIfaceBodyBindsInMethodWindow218, § uninstIfaceForeachHdrUnresolved220
  and § ifaceDefListsItsOwnProcesses226 encode for an interface no instance
  elaborates, so such a program's process body is now emitted under the same
  three flags (suppressRefActual, uninstIfaceSubBody218,
  uninstIfaceProcBody226): every reference CompileHelper::bindVariable does not
  bind at compile time stays bare (golden `x = y` with no vpiActual; a foreach
  loop variable's reads unbound and no implicit net minted), the binding window
  of § 218/§ 226 still binds an unnamed-block local in a condition column, and
  a foreach keeps paFOREACH's placeholders (the iterated reference a ref_var
  over a fresh unsupported_typespec named after the array at its name, each
  loop variable a ref_var over an unsupported_typespec named for it). Golden
  UP/up01 `program prg; int arr[4]; initial foreach (arr[i]) arr[i] = i;`:
  ref_var arr over unsupported_typespec arr 4:18-4:21, ref_var i over
  unsupported_typespec i 4:22-4:23, both reads of i bare; ours wrote an
  array_typespec, an int_var and a logic_net work@prg.i bound by both reads.
  The program is recognised by its definition being in `uninstProgDefs` (the
  set UhdmExporter fills from the progTops partition).
- § uninstProgSubBodyAsUninstIface439 (StmtEmit, UhdmExporter::emitStmt;
  R11U439_UNINSTPROGSUB_OFF). The subroutine half: a task or function declared
  in such a program has its body emitted under suppressRefActual and
  uninstIfaceSubBody218, the two flags ModuleEmit raises around an
  uninstantiated interface's emitTaskFuncs. Raised at the body's first
  emitStmt (currentSubSym set, the flag still down) for the whole statement
  tree; a method of a class declared in the program is left alone (the walk
  stops at the class). Golden UP/up04 `task automatic fill(); foreach (arr[k])
  arr[k] = k; endtask`: placeholders as above, the reads of k bare, where ours
  bound them to an int_var loop variable.
- § foreachLeadSkipPlaceholder439 (StmtEmit, the foreach loop-variable list;
  R11U439_LEADSKIP_OFF). paFOREACH (CompileStmt.cpp) takes the Loop_variables
  node's first child as the first loop variable whatever its type, so in
  `foreach (a[, j])` that child is the comma: it mints the ref_var placeholder
  over an unsupported_typespec named by SymName(comma), i.e. empty, located at
  the comma; its comma lookahead then reads the next comma as a separator, so
  a second leading empty slot (`[, , k]`) leaves nothing, and a third and later
  one get the vpiNullOp operation every other empty slot gets. The placeholder
  is swapped or kept exactly as a named loop variable is (module: int_var over
  the element typespec; uninstantiated program or interface, class method: the
  ref_var placeholder), with no name and the scope's own full name (golden
  LS/ls01 `int_var (work@top)` 4:23-4:24; LS/ls18 `ref_var (work@prg)` then
  `ref_var k`; ours wrote an unlocated vpiNullOp). Where the placeholder is
  resolved (late binding ran), UhdmWriter::lateTypedefBinding's foreach branch
  looks its empty name up among the loop variables, skips ref_var and ref_obj
  entries, finds the first vpiNullOp operation (whose name is empty too) and
  writes that object over the placeholder's slot, so the list holds that
  operation twice (golden LS/ls07 `[, j, , m]`: operation 4:26, j, the same
  operation, m; LS/ls03 `[, , , l]`). A nested foreach with its own leading
  empty slot re-lists the enclosing placeholder object (LS/ls14), as a named
  loop variable re-lists. Abstains with slang-folded leading index groups.
- § foreachTrailSkipDropped439 (StmtEmit, same site; R11U439_TRAILSKIP_OFF).
  The same walk reads a comma with no following sibling as a separator and
  stops, so the last empty slot of a list that ends empty is not listed:
  `foreach (a[i, ])` lists `i` alone and `[i, , ]` lists `i` and one vpiNullOp
  at the first comma (golden LS/ls09, ls08; ours added a located vpiNullOp for
  the last slot). Abstains when every slot is empty.
- § loopVarReadBindsModuleDecl439 (ExprEmit, the Iterator branch of the implicit
  net mint, with its scope walk loopVarModuleDecl439 at the top of the file;
  R11U439_LVMODDECL_OFF). UhdmWriter::lateBinding resolves an unbound read by
  NAME, walking the reference's parents (begin and named_begin Variables(),
  function and task Io_decls() and Variables(), then the module's Variables(),
  Parameters(), Ports() and Nets()) before its last resort mints the implicit
  wire. So a foreach loop variable read binds the first declaration of its name
  on that walk: a block local (LM/lm05 `begin int i;` binds that int_var), a
  module task's formal or local (lm10, lm12), the module's variable or net
  (the definition view lists a module variable as a logic_net: lm01 `int i;`
  beside `foreach (arr[i]) arr[i] = i;` binds both reads to logic_net
  work@top.i 3:5-3:6 where ours minted work@top.i at the first read).
  Abstains through a generate block or a class, on a parameter of the name and
  where the declaration has no object in netMap. Pass 437's FC/fc11 face, which
  holds for any element type.

## Grid (cases/, 65 case dirs; evidence/grid_final.tsv, grid_switches.tsv)

Every case's first line names its law. Columns: Surelog exit, then per binary
(p = pristine, l = law7) exit code, uhdm-cmp line count, path-normalized dump
distance to golden and the strict verdict. Every exit code 0 on both binaries
(Surelog exits 4 on LM/lm14, the module covergroup case, and still writes its
database).

- UP (26 case dirs, the program laws): 19 to STRICT_EQUAL from NOT_EQUAL
  (up01 to up11, up13, up14, up17, up18, up23 to up26: process bodies with
  foreach over int, 2-D, queue, dynamic and logic-vector arrays, nested loops,
  a final block, two programs, a program beside a module, a program variable
  named like the loop variable, enum and case reads, an event control on a
  port, a condition-column block local that still binds through the § 226
  window and a named-block local that stays bare, a task and a function
  called from the body; up23 is r11u437 FC/fc06, the covergroup array in a
  program); 3 NOT_EQUAL on both and closer by dump distance (up12 38 -> 15 and
  up15 31 -> 15: the bodies right, the next head a subroutine local Surelog
  also lists as a program net; up20 52 -> 41: the reads right, the next head a
  block localparam Surelog hoists into the program's parameter listing); 4
  byte-identical (up16 a class method in a program, up19 an instantiated
  program, up21 an uninstantiated interface, up22 a module).
- LS (25 case dirs, the skip laws): 21 to STRICT_EQUAL (ls01 to ls19, ls23,
  ls24; ls07 from STRICT_NOTEQUAL file, the rest from NOT_EQUAL: leading
  skips in modules, always_comb, module functions, classes, uninstantiated and
  instantiated interfaces and programs, one to three leading empties, a middle
  empty after a leading one, trailing empties, nested loops); 3 NOT_EQUAL on
  both and closer (ls21 package function 63 -> 42 with the uhdm-cmp count
  34 -> 52 because the first difference moved later to the package loop
  variable's kind; ls22 generate block 57 -> 47; ls25 queue of arrays 70 -> 40,
  its next head the `[2]` range golden writes `2-1`); 1 byte-identical control
  (ls20, a middle empty only).
- LM (14 case dirs, § loopVarReadBindsModuleDecl439): 11 to STRICT_EQUAL
  (lm01 to lm06, lm08 to lm10, lm12, lm14: int, integer, wire, two loop
  variables, two instances, a module task and function, its formal, a block
  local; lm14 is r11u437 FC/fc11); 1 NOT_EQUAL closer (lm11 named-block local
  19 -> 8, the reads right, the loop-variable declaration still differs); 2
  byte-identical (lm07 generate block, lm13 a parameter of the name).
- Totals: 51 to STRICT_EQUAL, 7 closer, 7 byte-identical, none further from
  golden; every exit code equal on both binaries.

Switches (drivers/switches.sh, every run writing the same output path since the
database embeds it): R11U439_OFF gives pristine's bytes and exit code on 65 of
65; each case's own switch gives pristine's bytes on 57; the other 8 fire a
second law of this pass and the two switches together give pristine's bytes
on all 8 (evidence/grid_switches_pairs.txt: UP/up11 with
R11U439_LVMODDECL_OFF, the program `int i;` binding once the program law is
off; UP/up15 and up26 with R11U439_UNINSTPROG_OFF; LS/ls06 with
R11U439_LEADSKIP_OFF; LS/ls17, ls18, ls19, ls23 with R11U439_UNINSTPROG_OFF).

Downstream (drivers/dsgrid.py through downstream_uhdm2rtlil.one, the 30
class-, program- and interface-free case dirs of LS and LM;
evidence/grid_downstream_pristine.txt and grid_downstream_law7.txt): IDENTICAL on both binaries for all 30, no verdict
changes (the shapes are simulation-only initial and task bodies).

## Prediction by name (before the sweep; evidence/prediction.txt)

Every branch traces. A fence-filtered scan of 41721 corpus, probe and sv-tests
sources (the fence list read by a program into a file, never printed, every
path list filtered on it before a file was opened):

- program laws: 242 files declare a program; their rows are 112 probe cases,
  the surelog rows InterfaceModPort, OneNetInterf, OneNetModPort,
  OneNetModPortGeneric, OneNetRange, SimpleConstraint and SVSwitch (the other
  program-holding surelog rows SLANG_REJECT), and the sv-tests rows
  chapter-24/24.3--program, p371, p454, p745 and p759; no uhdm2rtlil test.
  Traced law runs: the 112 probe cases all EQUAL with the laws firing on 9
  (r10svs10 c1_scopetop, r10uvm217 g217_d_importer, r10uvm62 c2_neighbours,
  r10v121 v121_e2, r10v141 v141_d_owners, r10v199 v199_d_ifprog, r11u95
  a19_progtopgeninit and a21_progtopgentask, r11v95 x20_progtopgenclass) and
  all 112 databases identical to the master's control by path-normalized dump;
  the seven surelog rows CMP_EQUAL in both modes with the laws firing on
  SimpleConstraint default and testflags only and every database
  byte-identical to the control's (InterfaceModPort and SVSwitch, the
  protected databases, included); the five sv-tests rows at their baseline
  status with no firing. Predicted: no byte or status mover.
- skip laws: no source has a leading or trailing empty foreach slot (a scan of
  the 1205 files holding `foreach`). Predicted: no firing.
- § loopVarReadBindsModuleDecl439: 488 files where a foreach loop-variable name
  is also declared somewhere in the file (a loose superset); their rows (13
  surelog rows, the uhdm2rtlil cva6_equiv row, 5 probe cases, 13 sv-tests rows
  including the four 9.7 process_cls rows and apb_protocol_monitor) traced
  with law7, plus the whole uhdm2rtlil corpus in both modes and all 4087 probe
  cases traced: no firing anywhere, every status at its baseline (probe csv
  identical to results/golden_probe.csv). Predicted: no firing.

The sweep's trace census (R11U439_TRACE over all five stages) reads exactly
the predicted set: § uninstProgBodyAsUninstIface439 and
§ uninstProgSubBodyAsUninstIface439 on SimpleConstraint default and testflags
and the 9 named probe databases, no other law anywhere, and no byte or status
mover (below).

## Gates (law binary law7, md5 e41a0fda1c966879a1f3164b9604df62; pristine = the master's control /tmp/intr11u437, not rebuilt)

One full five-stage reading on the final binary law7: tests/sweep.sh --jobs
3 --workdir /tmp/r11u439_LW --corpus 'probe surelog uhdm2rtlil downstream' from
the worktree with SLANG_UHDM exported, then the svtests stage through the main
tree's scripts/check_svtests.py with `--baseline` the worktree's
results/golden_svtests.csv on the same workdir (the worktree's UVM submodule
is empty; scripts/ and tests/sweep.sh identical between db1d84d3 and the main
tree's HEAD). Each half launched after three quiet readings a minute apart.
evidence/sweep_summary.txt.

- probe: EQUAL=4023 STRICT_NOTEQUAL=64, regressions=0 conversions=0
  changes=0; csv identical to the control; the 4087 databases identical to
  the control's by path-normalized dump (positive control: two different
  databases 785 lines apart).
- surelog: default CMP_EQUAL=480, testflags 474, regressions=0 conversions=0
  changes=0; the csv differs from the control only in the two LowMem log-path
  texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0, csv identical.
- downstream: IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2, csv identical.
- svtests: EQUAL 1908, STRICT_NOTEQUAL 0, DIFFERENT 32, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, 0/0/0, csv
  identical to the control.
- byteverify (SELFCHECK=1) law7 against the master's control: 0 of 962,
  0 of 1608, 0 of 805 movers, self-checks 961/962, 1607/1608, 804/805
  flagged.
- canaries ok=52 (surelog) and ok=16 (uhdm2rtlil) changed=0; both ctcan2
  checks PASS (EXPECT_UNKNOWN=1 and 6).
- binary audit, fence-filtered: surelog 1523 of 1573 cmds records name law7,
  the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests
  2346 of 2346.
- trace census: the program laws on SimpleConstraint d/t and 9 probe
  databases, all byte- or dump-identical to the control; the skip laws and
  § loopVarReadBindsModuleDecl439 fire nowhere in the five stages (positive
  control: the LS and LM grids, a traced run of LM/lm01 logging both reads).
- earlier-pass census (drivers/census1.bash; evidence/earlier_pass_census.txt,
  earlier_pass_movers.tsv): 6614 fence-filtered case dirs (every
  tools/probe/r11u4* and v11u4* case and every tools/probe case holding
  `foreach` or `program`, this pass's own excluded) on pristine and law7, each
  binary writing the same output path: exit codes equal everywhere; 56
  movers, every one compared with a fresh Surelog golden: 36 to STRICT_EQUAL
  (among them r10uvm223 a7_prog, r10uvm226 a3_holders, r10v226 b01_holders,
  r11u105 k15, k23, k26, the six r11u162verify itp/iad program cases,
  r11u204verify M/m3, r11u268 m53_program, r11u270 i23, r11u312 md07,
  r11u421 residue rp01 and rp02, r11u437 FC/fc06 and fc11, r11v105 k15, k23
  and the two v11 prog_class_func cases, v11u155 IT/k11 to k13, v11u266 vs16,
  v11u286 vz09, v11u413 VR/vr04, v11u414 VV/vv20, v11u417 VC/vc04 and VT/vt19,
  v11u421 VE/ve11, v11u437 VD/vd09 and VF/vf03); 18 NOT_EQUAL on both and
  closer by dump distance with no new difference line except the unreferenced
  tail's order (r10uvm218 a3, r10uvm220 a4_prog, r10uvm221 a3, r10v221 v3,
  r11u185 TW/w10, r11u213 FT/t01 at exit 4 on both, r11u226 W/w01, r11u229
  E/e04, r11u291 CS/c25, r11u304 TD/t38, r11u314 NB/nb10, v11u134 pa08,
  v11u155 IT/k06 and TE/h10, v11u180 E/e02, v11u209 LV/v20, v11u254 F/vf05,
  v11u417 VC/vc24; several uhdm-cmp counts grow, 29 -> 538 for vf05, only
  because the first difference moved later in the walk); 2 with no golden
  (r11u162verify tds t01 and t07, Surelog exit 3).

## Goal 1

Nothing on this ground. All 75 SURELOG_ONLY rows carry an upstream slang
front-end diagnostic (no detail names an exporter message; `grep -ci
'unsupported|slang-uhdm:'` over their details and the SLANG_CRASH rows reads
0). The probe shapes on law7 (upstream slang = ~/.local/bin/slang dut.sv
--single-unit): v11u415 VT/vt03 (`this.mk().inner.s`) slang 0, ours 0;
v11u413 VC/vc04 (`C::mk().arr[1]`) slang 0, ours 4; v11u413 VI/vi06
(`u.mk(x).a[2]`) slang 0, ours 4; Surelog rejects all three with a syntax
error (pass 437's reading), so golden has no shape to copy and none is
forced. bp_unicore measured alone on law7 (drivers/memrun.py, rusage of the
child): exit 3 (`basic_string::substr: __pos (which is 18) > this->size()
(which is 17)` under pass 403's size guard) in 14.3 s at 806 MB maximum
resident; no memory-bounded export, the guard stands. generated/rsd/rsd.sv
stays SURELOG_CRASH (Surelog dies first).

## Residues (ranked; all wrong on pristine too, none moved away)

1. An INSTANTIATED program's foreach (UP/up19): writeElabProgram runs
   lateTypedefBinding, and golden lists the loop variable as an array_var
   over the array's array_typespec with every read bound to it and the
   iterated reference over the same array_typespec, where ours writes the
   int_var fallback and binds the reads to a minted implicit net; not decoded
   to the swap that yields array_var.
2. Generate-block foreach (LS/ls22, LM/lm07): golden's definition view keeps
   paFOREACH's placeholders (ref_var over unsupported_typespec) and the
   elaborated view an array_var loop variable; ours writes int_var in both.
3. A package function's foreach (LS/ls21): golden array_var loop variables
   (pk::f, pk::f::j) over array_typespec, ours int_var.
4. A loop variable named like a named-block local (LM/lm11): golden's loop
   variable is a ref_var over the local's int_typespec (the
   already-resolves branch of declLoopVar does not see named-block locals); the
   reads are right. A loop variable named like a parameter (LM/lm13): golden
   ref_var over the parameter's typespec with the reads bare, ours int_var
   and a minted net.
5. The program faces of the sister's ground below (subroutine locals listed as
   program nets, the hoisted block localparam).
6. The carried lists of passes 437 and earlier (the brief's items (a) to (z)),
   untouched by this pass except the faces written: r11u437 FC/fc06 and fc11
   and v11u417 VC/vc04, VT/vt19 now STRICT_EQUAL, VC/vc24 closer (its next
   head the program net listing below).

## Sister-ground faces (reported, not written)

- A task or function local of an uninstantiated program is also listed by
  golden as a program net (`logic_net work@prg.s` 5:7 under the program's
  vpiNet, with its int_typespec; UP/up12, up15, v11u417 VC/vc24): the program
  definition's net listing (ModuleEmit's program road, with TaskFuncEmit's
  locals).
- A block localparam in an uninstantiated program's process is hoisted by
  golden into the program's own vpiParameter and vpiParamAssign listing
  (`parameter work@prg.K` UINT:2 and its param_assign; UP/up20): the program
  definition's parameter listing (ModuleEmit).
- `logic [3:0] q[$][2]`: the `[2]` unpacked range written by golden as the
  operation `2-1` where ours folds UINT:1 (LS/ls25; TypeEmit's range builder,
  the face pass 437 reported for `int d[2][]`).

## Process

- Builds in the worktree: the first build equal to the main tree's
  (24441d076ca367d92ef9d24c2ea0f9a4), then law1 to law7, every intermediate
  binary used on case runs only. Pristine = the main tree's build frozen at
  /tmp/r11u439_pris.bin, no pristine sweep (the master's control
  /tmp/intr11u437 is the pristine reading).
- Prediction runs before the sweep (evidence/prediction.txt): law5 on the
  program candidates (112 probe cases, 7 surelog rows, 5 sv-tests rows) and
  law7 traced on the loop-variable candidates (13 surelog rows, 13 sv-tests
  rows), the whole uhdm2rtlil corpus in both modes and all 4087 probe cases;
  the last two are stage-sized runs made to predict by name, not gate
  readings.
- One full five-stage sweep, on law7. The svtests half ran through the main
  tree's script while the main tree held the master's pass 440 integration
  (src/ModuleEmit.cpp, TypeEmit.cpp, UhdmExporter.cpp, tests/LAWS.md
  modified; scripts/ untouched) and finished after it landed at 4899f5c73;
  the stage reads my binary and the worktree's baseline, so neither matters.
- Slips, none affecting a measurement: my first case grids (single
  sequential runs, about 40 cases) and the law1 to law5 builds ran from 14:11
  to 14:18 while the sister r11u440's sweep (started 14:10) was live; a
  background quiet-waiter of mine matched its own launching shell's command
  line and never saw quiet, stopped by its recorded PIDs and relaunched as a
  script; the first sweep launcher was stopped by its PID before any stage
  ran (to point the svtests half at the worktree's baseline) and its
  relaunch, named sweep.sh, was stopped the same way because its own quiet
  check matched that name, then relaunched under another name; no stage of
  mine overlapped another agent's sweep (my corpora stages ended 16:26:04,
  the master's pass 440 sweep started 16:26:43; my svtests stage started
  16:53:05 after three quiet readings).
- The fence list was read by a program into a file and never printed; every
  tree-wide list was filtered on it before any file was opened; no fenced
  test named, opened or run; no other agent's process touched.
