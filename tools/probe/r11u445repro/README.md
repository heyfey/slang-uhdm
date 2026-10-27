# r11u445 — foreach loop variables named like a declaration (expression/parameter ground)

Pass 445, the twenty-third pass of the sv-tests campaign on the expression /
parameter ground (StmtEmit, ExprEmit, EmitHelpers.h; ParamEmit unchanged).
Base 3b825bc59 (pass 443). Pristine reading: the master's control sweep at
the base (/tmp/intr11u443, whose csvs equal the committed results/*.csv). No
pristine build and no pristine sweep: the worktree's base build (md5
8b728ab5166adfa3a8f77d8a35558391, equal to the main tree's build/slang-uhdm)
was frozen for case runs. Final law binary law5, md5
685e64471b6aff5cb6e1fd77a1f0c883 (links slang 12.0.0+545f88b2e).

## Heads at the base (question 1)

The 27 DIFFERENT sv-tests rows at the base are those pass 443 re-measured on
the control pairs, and no landing since has touched them: the 16 uvm-examples
rows at a package listing, the 3 scoreboard rows and easyUVM at the design or
class listing, control_slave, nonsynth_mem_1rw_sync_assoc and
scheduler_dataflow at UhdmExporter's admission of never-instantiated modules
(the abstain-unbound after § undefaultedPlaceholderRetry440, read in
UhdmExporter.cpp: the admission test is the Bad404 visitor over the
placeholder body, so no writer on this ground can list those definitions
before the sister admits them), and p733, p737 and tnoc as reported before.
None of these heads is on this ground. So this pass took the largest
probe-backlog cluster on the ground, carried by passes 439 and 443 as their
residues: a foreach loop variable named like a declaration (r11u443 PF/pf20,
pf33, IF/if11, if12; r11u439 LM/lm11, lm13; v11u439 VL/vl02, and VL/vl01
found by the census).

Goal 1: nothing on this ground. In the control csv no rejecting row
(303 BOTH_REJECT, 75 SURELOG_ONLY, 0 SLANG_CRASH) has an exporter
message in its detail, so all 75 SURELOG_ONLY rows carry an upstream slang
front-end diagnostic, as pass 443 found. The black-parrot size guard, rsd and
the probe shapes C::mk().arr[1], u.mk(x).a[2], this.mk().inner.s were not
re-measured: no law of this pass reaches them (the trace census below fires
on no corpus row).

## Decode (question 2)

Surelog's foreach (CompileStmt.cpp paFOREACH) lists each loop variable as a
ref_var over an unsupported_typespec named for it and registers it for
lateTypedefBinding. UhdmWriter::lateTypedefBinding walks the ref_var's parent
chain looking for a declaration of that name: function (io_decls, variables,
parameters, the package's variables when its Instance() is a package), task,
for_stmt init, enclosing foreach (non-ref_var loop variables), module_inst
(Variables, then Parameters (parameter and type_parameter), then Ports, then
Nets), begin and named_begin (variables; a block parameter sets the typespec
without `found`), fork and named_fork. When it finds one the loop variable
STAYS the ref_var and its ref_typespec points at the declaration's own
typespec (a parameter without a typespec leaves the ref_var without one).
Only when nothing is found does the foreach fixup run swapForSpecifiedVar
(the int_var / array_var / element swap the earlier passes wrote).
UhdmWriter::lateBinding's foreach branch then skips a ref_var loop variable
when it binds a read of the name, so the read goes on up the walk and binds
the declaration: a variable, net or formal found there is bound, a parameter
leaves the read bare (and, the netlist finding a declaration, no implicit
net is minted).

The walk has no program and no interface branch. Measured on golden: a
program's or an interface's own variable is still found (SP/sp03, SI/si02;
the elaborated instance runs lateTypedefBinding, lateBinding,
lateTypedefBinding), but its own parameter is not (SP/sp04, SI/si04: the
placeholder is swapped as if nothing were declared and the read binds the
swapped loop variable).

What ours did: StmtEmit's loop-variable branch already wrote the ref_var over the
declaration's typespec, but looked the name up from the scope OUTSIDE every
statement block (lvScope9 skips all StatementBlocks), so a begin, fork or
task-body local was never found, and a parameter has no netMap object; the
reads were then bound only in modules (§ loopVarReadBindsModuleDecl439),
not in an interface process or a package subroutine; a module parameter's
read minted the implicit wire; and pass 443's program and interface laws
abstained on every shadow, a body parameter included.

## Laws (StmtEmit / ExprEmit / EmitHelpers.h, read through src/LawSwitch.h)

- § foreachLoopVarShadowDeclTs445 (R11U445_SHADOWBLK_OFF; StmtEmit's
  declLoopVar, helper loopVarShadowBlockSym445 in EmitHelpers.h). A loop
  variable named like a local of a begin, named begin, fork, named fork or
  subroutine body enclosing the foreach is the ref_var over that local's own
  typespec (golden SM/sm01 `begin int i; foreach (arr[i])`: ref_var i over
  the int_typespec 4:15-4:18; ours an int_var over the array's element
  int_typespec 3:1-3:4). Modules, instantiated programs and interfaces, package
  subroutines (elaborated listing) and generate blocks alike; it abstains
  where the earlier branches write the placeholder (class methods, the package
  definition listing, uninstantiated interface subroutines), on an enclosing
  foreach's loop variable (the nested relist), and where the local has no
  object or no typespec reference.
- § foreachLoopVarModParamTs445 (R11U445_MODPARAM_OFF; StmtEmit's
  declLoopVar). A loop variable named like a parameter or type parameter of a
  module is the ref_var over that parameter's typespec, read from the
  module's own Parameters() listing by name (golden SM/sm03 `parameter int i
  = 2;`: ref_var i over the int_typespec 3:11-3:14; SM/sm30 `parameter type
  i = int`: the type parameter's int_typespec 4:20-4:23; an untyped
  parameter its listing's typespec, SM/sm27).
- § loopVarParamReadUnbound445 (R11U445_PARAMREAD_OFF; ExprEmit's implicit-net
  branch, helper loopVarFirstDecl445). A read of a loop variable whose name a
  module parameter declares first on the walk is left bare and mints no
  implicit wire (golden SM/sm03's two reads of i; ours bound a logic_net
  work@top.i minted at the first read and listed it). The same holds for an
  array method's `with` iterator named like a module parameter (SW/sw01 `q.sum()
  with (item * 2)` beside `parameter int item`), which golden also leaves bare.
- § progIfaceParamNoShadow445 (R11U445_PARAMNOSHADOW_OFF; StmtEmit's
  lvShadow443 and ExprEmit's § elabProgLoopVarReadBinds443 branch, helper
  loopVarShadowIsBodyParam445). A program's or interface's own parameter
  does not shadow the loop variable for pass 443's laws, so
  § elabProgMemberArrLoopVar443, § elabProgLoopVarReadBinds443 and
  § elabIfaceLoopVarReadBinds443 fire as for an undeclared name (golden SP/sp04
  array_var i with the read bound to it; SI/si04 the logic_var bound).
- § ifaceLoopVarReadBindsDecl445 (R11U445_IFACELVDECL_OFF; ExprEmit). In a
  process of an instantiated interface a read of a loop variable that pass
  443 did not register binds the variable, net or formal the walk finds
  first (loopVarModuleDecl439's walk): a block local (SI/si01 int_var
  work@ifc.i at 5:19) or an interface variable or net (SI/si02 int_var
  work@top.u.i; si07 a wire, si08 a logic vector); nothing where the walk
  finds none. An array-method iterator named like an interface variable binds
  it too (SW/sw03, closer).
- § pkgSubLoopVarReadBindsDecl445 (R11U445_PKGLVDECL_OFF; ExprEmit, helper
  loopVarInPkgSub445). In a function or task declared in a package, a read of
  a loop variable named like a formal, a subroutine local or a block local
  binds that declaration, in both package listings (golden SK/sk01 `int i;`
  beside `foreach (arr[i]) s = s + i;` in `function automatic int f()` of
  `package pk`: the read binds int_var pk::f::i at 3:52 in both views; ours
  left it bare). An array-method iterator named like a local binds it too
  (SW/sw02, closer).

Every firing logs through lawTrace(445, ...); a module loop variable whose
declaration has an object but no typespec reference yet (a port) logs
`abstain-nots`. R11U445_OFF drops every law. No src/R*.h, no LawState.h
section, no getenv, no reader function; ParamEmit, TypeEmit, ModuleEmit,
UhdmExporter, TaskFuncEmit, include/ and uhdm_main.cpp unchanged.

The implementer's own break found before the sweep (law6, not kept): a guard
that restricted the ExprEmit laws to foreach loop variables (an iterator that
is a member of its foreach block) made the three `with`-iterator cases SW/sw01
to sw03 byte-identical to pristine where law5 had moved them toward golden
(sw01 to STRICT_EQUAL, sw02 dist 8 -> 4, sw03 76 -> 74): golden binds a
`with` iterator's read by name exactly like a loop variable's, since Surelog
does not declare the iterator. The guard was reverted; the rebuilt binary is
byte-identical to law5.

## Grid (cases/, 75 case dirs in SC, SG, SI, SK, SM, SP, SU, SW)

drivers/grid.sh (goldens: Surelog -parse -nobuiltin -nocache -sv dut.sv;
ours: dut.sv --single-unit --nobuiltin), evidence/r11u445_grid_law5.tsv.
Every exit code is 0 on both binaries; every case is accepted by upstream
slang (~/.local/bin/slang --single-unit).

Pristine -> law5: 15 STRICT_EQUAL -> 59 STRICT_EQUAL.

- 44 NOT_EQUAL -> STRICT_EQUAL: SM/sm01 to sm04, sm12 to sm15, sm21 to sm27
  (sm28 already equal), sm29 to sm35, sm37 to sm39, SG/sg03, SI/si01 to si04,
  si06 to si09, SK/sk01 to sk04, sk07, SP/sp04, sp08, sp09, SW/sw01, sw04.
- 8 NOT_EQUAL on both and closer by dump distance: SG/sg01 28 -> 14, sg02
  40 -> 18 (both at the generate block's definition view, below), SM/sm18
  37 -> 29 (the typedef listing, below), SP/sp01 27 -> 19, sp02 27 -> 19,
  sp07 27 -> 19 (the program listing, below; their uhdm-cmp counts grow 56
  -> 682, 738 and 774 because the first difference moved later, to golden's
  program Variables listing, which uhdm-cmp prints whole), SW/sw02 8 -> 4,
  sw03 76 -> 74.
- 8 NOT_EQUAL and byte-identical (residues): SM/sm05, sm06, sm07 (ports),
  sm20 (generate definition view), SI/si05 (interface function body), SK/sk05
  (a package variable), SP/sp05, sp06 (program subroutine faces).
- 15 STRICT_EQUAL controls byte-identical: SC/sc01, SK/sk06, sk08, SM/sm08 to
  sm11, sm16, sm17, sm19, sm28, sm36, SP/sp03, SU/su01, su02.
- R11U445_OFF gives pristine's bytes and exit code on 75 of 75
  (drivers/switches.sh). Each case's own switch (evidence/r11u445_perlaw_law5.tsv,
  drivers/perlaw.sh): one switch restores pristine on 38 of the 52 byte
  movers; SI/si01 and si03 need R11U445_SHADOWBLK_OFF with
  R11U445_IFACELVDECL_OFF, SK/sk02, sk04 and sk07 R11U445_SHADOWBLK_OFF with
  R11U445_PKGLVDECL_OFF, SM/sm03, sm04, sm27, sm29, sm31, sm32, sm38 and sm39
  R11U445_MODPARAM_OFF with R11U445_PARAMREAD_OFF (each pair measured to give
  pristine's bytes), and SM/sm37 (a block local shadowing a module parameter)
  falls to § foreachLoopVarModParamTs445 when only R11U445_SHADOWBLK_OFF is
  set, all three switches giving pristine.
- Downstream (drivers/dsgrid.py, the class-free 72 case dirs):
  71 IDENTICAL and 1 EQUIVALENT on both binaries, no verdict changing
  (evidence/r11u445_ds_pristine_law5.tsv).

Earlier passes' cases (the residues named in the brief), pristine -> law5:
r11u439 LM/lm11 and lm13, r11u443 IF/if11 and if12, v11u439 VL/vl01 NOT_EQUAL
-> STRICT_EQUAL; r11u443 PF/pf20 27 -> 19 and pf33 46 -> 19 closer (the
program listing face); v11u439 VL/vl02 and vl08, v11u443 VA/va16
byte-identical.

## Census before the sweep (by name)

- Away census, drivers/census.sh: every fence-filtered tools/probe and
  tests/probe .sv file holding `foreach` (1191 files) and every other one
  holding the word `with` (3266 files), pristine and law5 (traced) on each.
  Exit codes equal on all 4457. Byte movers: 7, all in the foreach list and
  all named above (lm11, lm13, if11, if12, pf20, pf33 and vl01); firings on 9
  files (those 7 plus VL/vl02 and vl08, which log only `abstain-nots`); no
  tests/probe case fires or moves. evidence/r11u445_census_foreach.tsv,
  r11u445_census_with.tsv.
- Corpus byte census, drivers/corpus_census.py: law5 traced over every
  fence-filtered cmds.txt slang line of the master's control sweep, in the
  test's own directory, md5 against the control's slang.uhdm: surelog 1573
  records, 0 movers, 0 firings (50 records hold only a Surelog line);
  uhdm2rtlil 1740 records, 0 movers, 0 firings (the 134 reject records equal
  too). evidence/r11u445_corpus_census_{surelog,u2r}.tsv.
- sv-tests trace census, drivers/sv_trace.py: law5 traced over the 621
  accepted rows whose sources hold `foreach` or `with` and the UVM row
  chapter-16/16.10--property-local-var-uvm.sv (uvm_pkg): 0 firings, every
  exit code 0. evidence/r11u445_svtests_trace.tsv.
- Positive controls: the grid's traced runs fire on every mover (SM/sm01
  `foreachLoopVarShadowDeclTs445 block i`, LM/lm13 `foreachLoopVarModParamTs445`
  and two `loopVarParamReadUnbound445`, SW/sw02 `pkgSubLoopVarReadBindsDecl445`).
- The prediction (evidence/r11u445_prediction.txt, written before the
  sweep): 0 movers and 0 conversions in all five stages, no firing line in
  the sweep trace.

## Gates (law5; one full five-stage sweep, after three quiet readings)

The sweep (drivers/fullsweep.sh: tests/sweep.sh --jobs 3 --workdir
/tmp/r11u445_sw from the worktree, SLANG_UHDM=law5, R11U445_TRACE set) ran
probe, surelog, uhdm2rtlil and downstream; its sv-tests stage skipped itself
since the worktree has no ../sv-tests and an empty UVM submodule, so that
stage was run alone through the main tree's tests/sweep.sh --corpus svtests
with the same binary, workdir and trace (drivers/svstage.sh), the main tree's
scripts and results/golden_svtests.csv being the base's. Logs:
evidence/r11u445_sweep_corpus.log, r11u445_sweep_svtests.log. The corpus
stages' rc 1 is the stale law index alone (README edited after the index was
generated; regenerated afterwards, `scripts/law_index.py --check` reads
current).

- probe: EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0
  changes=0; the csv identical to the control's; the 4087 databases
  identical to the control's by path-normalized dump (drivers/probedump.sh,
  4087 of 4087; positive control: two different databases differ by 659
  lines).
- surelog: default CMP_EQUAL 480, testflags 474 (+0 STRICT_NOTEQUAL),
  regressions=0 conversions=0 changes=0; the csv differs from the control's
  only in the two LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes, regressions=0 conversions=0
  changes=0; csv identical to the control's.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; csv
  identical to the control's.
- svtests: EQUAL 1913, STRICT_NOTEQUAL 0, DIFFERENT 27, SURELOG_ONLY 75,
  BOTH_REJECT 303, SLANG_ONLY 19, SLANG_CRASH 0, SURELOG_CRASH 8, TIMEOUT 1 of
  2346, regressions=0 conversions=0 changes=0; the csv byte-identical to the
  control's. No sv-tests row converts.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) against
  the control /tmp/intr11u443: surelog 0 of 962, uhdm2rtlil 0 of 1608,
  downstream 0 of 805 movers, the self-checks flagging 961, 1607 and 804.
- canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); both
  ctcan2 checks PASS (EXPECT_UNKNOWN=1 and 6).
- binary audit (fence-filtered cmds.txt): surelog 1523 of 1573 records name
  /tmp/r11u445_bin/law5 (the other 50 hold only a Surelog line), uhdm2rtlil
  1740 of 1740, sv-tests 2346 of 2346; no record names another binary.
- trace census: the sweep's trace directory is empty in all five stages, as
  predicted.
- Determinism: no law iterates a container for emission order (each reads
  one symbol's own declaration); three concurrent law5 runs of SM/sm01, sm03,
  SI/si01, SK/sk01 and SW/sw02 each read one hash, equal to the grid's.

## Residues (ranked; all wrong on pristine too, none moved away)

1. Ports (SM/sm05 `output int i`, sm06 `input logic [3:0] i`, sm07 a
   non-ANSI port, v11u439 VL/vl02): golden's ref_var takes the port's
   typespec (module_inst branch, Ports before Nets); ours lists the int_var.
   The port objects do not exist when the process is emitted (the traced
   `abstain-nots` line: netMap holds the definition's logic_net with no
   typespec reference, and the module's Ports() is still empty), so the
   typespec can only be bound in a later drain: sister-ground face below.
2. The program listing (SP/sp01, sp02, sp07, r11u443 PF/pf20, pf33): the
   loop variable and its reads are now right; golden then lists the block
   local as a program variable (ModuleEmit's program hoist, pass 444's).
3. The generate block's definition view (SG/sg01, sg02, SM/sm20): golden
   keeps the foreach placeholders there (unsupported_typespec arr and i);
   the elaborated view is right with this pass (pass 439's LS/ls22, LM/lm07
   face).
4. A package variable named like the loop variable (SK/sk05): golden's
   function branch finds the package's Variables() through Instance() and
   keeps the ref_var over its typespec, binding the read to pk::i; ours swaps
   to array_var. The package listing's object map (pkgViewVarObjs9) would
   have to be read from declLoopVar.
5. SM/sm18, a block local typed by a module typedef: the loop variable is
   now right; golden then lists the typedef's alias typespec where ours does
   not (TypeEmit's typedef listing, the sister's).
6. SI/si05 (an interface function's formal), SP/sp05, sp06 (program task and
   function bodies): the interface task body face (v11u443 VI/vi12) and the
   program-net listing face, both pre-existing.
7. SW/sw02, sw03: the with-iterator's own declaration reference in the call
   arguments q.find(x) is a different object in golden (closer, not equal).
8. v11u443 VA/va16 (a nested same-name foreach in a program) and v11u439
   VL/vl08 (an interface port): untouched.

## Sister-ground faces (reported, not written)

- ModuleEmit's emission order for module ports: a foreach in a module
  process that names a port as its loop variable needs the port's typespec,
  which golden reads from Ports() (UhdmWriter::lateTypedefBinding's
  module_inst branch); the ports are listed after the processes, so a
  deferred bind is needed there or in UhdmExporter's pendingLoopVarTs9 drain
  (r11u445 SM/sm05 to sm07, v11u439 VL/vl02, r11u443 PV/pv04).
- ModuleEmit's program hoist of block locals (SP/sp01, sp02, sp07, PF/pf20,
  pf33), pass 444's.
- TypeEmit's typedef listing under a typedef-typed block local (SM/sm18).
- UhdmExporter's admission of never-instantiated modules for the three
  basejump rows (as pass 443 reported).

## Files

- cases/<GROUP>/<case>/dut.sv, first line `// § <law>`.
- drivers/: gencases.py (writes the cases), grid.sh, switches.sh, perlaw.sh,
  dsgrid.py, census.sh, corpus_census.py, sv_trace.py, fullsweep.sh,
  env.sh.
- evidence/: the grid, per-law, downstream, census and prediction files named
  above, and the sweep logs.
