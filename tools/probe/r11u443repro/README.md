# r11u443 — foreach loop variables in instantiated programs and interfaces, and the iterated reference of a packed foreach (expression/parameter ground)

Pass 443, the twenty-second pass of the sv-tests campaign on the expression /
parameter ground (StmtEmit, ExprEmit, EmitHelpers.h; ParamEmit unchanged).
Base 3dcbb0b9 (pass 441). Pristine reading: the master's control sweep at the
base (/tmp/intr11u441, whose csvs equal the committed results/*.csv); no
pristine build or sweep of this pass beyond the worktree's base build (md5
c4efdfa2c713ab09d9d8aada0ba7da74, equal to the main tree's), frozen for case
runs.

## Heads at the base (question 1)

uhdm-cmp over the control's 27 DIFFERENT sv-tests pairs (the cached Surelog
golden against the control's slang.uhdm; evidence: none kept, the command is in
drivers/): every head is off this ground or a Surelog artefact, as pass 441
reported: the 16 uvm-examples rows head at the uvm_pkg / test_lib_pkg /
env_pkg / test_top_pkg package listing (sister's), the 3 uvm_scoreboard rows
and easyUVM at the design or class_defn listing (sister's), control_slave,
bsg_nonsynth_mem_1rw_sync_assoc and bsg_scheduler_dataflow at the design
level, golden listing the never-instantiated definition as a module_inst that
ours drops (UhdmExporter's admission, sister's: control_slave's dump diff
starts at golden's `module_inst work@bsg_source_sync_channel_control_slave`
with its `lg_token_width_p` STRING:inv), p733 at the 16:10 constant (cross-top
defparam), p737 at the design, tnoc at tnoc_pkg.sv 333:14 (constant 241, a
Surelog artefact). So this pass took the largest probe-backlog cluster on the
ground: pass 439's residue "a foreach in a program a module instantiates,
where golden writes the loop variable as an array_var with reads bound to it"
(UP/up19, VP/vp09, VS/vs09), which on decoding is three faces, plus a fourth
general face found while gridding it.

Goal 1: nothing on this ground. All 75 SURELOG_ONLY rows of the control csv
carry an upstream slang front-end diagnostic (no exporter message; the one
grep hit, biquad_example, is uvm_pkg.sv's `design element does not have a time
scale` whose path contains the repo name). The black-parrot guard, rsd and
the probe shapes C::mk().arr[1], u.mk(x).a[2], this.mk().inner.s are as pass
441 left them (not re-measured: no law of this pass touches them).

## Decode (question 2)

Surelog's foreach (CompileStmt.cpp paFOREACH) lists each loop variable as a
ref_var over an unsupported_typespec named for it and registers it for
lateTypedefBinding; UhdmWriter::lateTypedefBinding's foreach fixup calls
swapForSpecifiedVar, which hands the iterated name to decodeHierPath and
replaces the placeholder by getSimpleVarFromTypespec(<the typespec found>)
(CompileType.cpp: an array_typespec without Index_typespec makes an array_var,
with one it recurses into the index typespec, a logic / string / int typespec
makes that kind); lateBinding's foreach branch then binds a read of the name to
any vpiLoopVars entry that is not a ref_var or ref_obj. writeModule runs
lateBinding only (a module's loop variable is typed by the netlist
elaboration, element-wise, and its reads bind the implicit net the netlist
mints first), but writeElabProgram (an instantiated program) runs
lateTypedefBinding and then lateBinding on the elaborated program, whose
Variables() listing carries the member's whole array_typespec.

## Laws (all StmtEmit / ExprEmit / EmitHelpers.h, read through src/LawSwitch.h)

- § elabProgMemberArrLoopVar443 (R11U443_PROGFEVAR_OFF; StmtEmit, the
  foreach loop-variable branch). In a process of a program some module
  instantiates, a foreach over a program member that is a fixed, dynamic or
  queue array has an array_var loop variable over the member's own
  array_typespec (a fresh one when it has none); an associative member's loop
  variable is getSimpleVarFromTypespec of the declaration's index typespec
  object (the § foreachAssocIndexVar19 / § foreachAssocLoopVarIdxTs183 branches
  widened to this home). Golden up19 `foreach (arr[i])` over `int arr[4]` in
  `program prg` under `top`: array_var work@top.p.i over array_typespec where
  ours wrote int_var over the int_typespec; pf10 `int aa[string]`: string_var
  k over the index string_typespec 4:8-4:14. Abstains on a process-local
  array, a subroutine body (a program task's foreach keeps the element form in
  golden, pf05), a dotted or scoped name, and a loop variable named like a
  declaration (below).
- § elabProgLoopVarReadBinds443 (R11U443_PROGLVBIND_OFF; StmtEmit's
  loop-variable registration and ExprEmit's iterator read). In the same
  processes a read of the loop variable binds the loop-variable object,
  whatever its kind, and no implicit net is minted (golden up19: both reads
  bind array_var work@top.p.i; ours bound and listed logic_net work@top.p.i).
- § elabIfaceLoopVarReadBinds443 (R11U443_IFACELVBIND_OFF; StmtEmit's
  registration). In a process of an interface some module instantiates a
  resolved loop variable of every kind binds its reads (golden if02 `foreach
  (sig[i]) s = s + i;` over `logic [3:0] sig`: the read binds logic_var
  work@ifc.i; an int_var already bound, if01). The interface's loop variables
  keep the element typing (if01 int_var in golden), so only the binding
  widens.
- § foreachPackedRefDeclTs443 (R11U443_FEPACKEDTS_OFF; StmtEmit, the
  iterated reference's typespec). The iterated reference of a foreach over a
  packed or string variable, net or (where the declaration has its typespec
  reference) port binds that declaration's own typespec, in every home that
  reached the deferred drain: golden pv09 `foreach (v[i])` over `logic [7:0]
  v` in a module: ref_var v over the declaration's logic_typespec 3:1-3:12
  (bit_typespec for `bit [7:0]`, string_typespec for `string`, the typedef's
  logic_typespec for a typedef'd vector, the net's logic_typespec for a wire);
  ours minted a fresh unlocated array_typespec in UhdmExporter's
  pendingForeachArrayTs drain (which knows array variables and array ports
  only). Abstains when the declaration has an array typespec, no object in
  netMap or no typespec reference (so an ANSI input port, pv04, is not
  reached).

The three program / interface laws abstain when the loop variable's name is
declared in a scope between the foreach and the instance body (a block local,
a member, a formal): Surelog resolves it to that declaration
(`loopVarNameShadows443`, EmitHelpers.h). This narrowing came from the grid
before the sweep: law3 bound pf20's `begin int i; foreach (arr[i]) s = i;`
read to the loop variable where pristine and golden bind the block local
(pristine right, law3 wrong, uhdm-cmp 56 lines both, dump distance 27 -> 28);
law4 leaves pf20 byte-identical to pristine.

R11U443_OFF drops all four (65 of 65 grid case dirs give pristine's bytes and
exit code); each law's own switch is listed per case in
evidence/r11u443_switches4.tsv; lawTrace(443, ...) logs each firing to
R11U443_TRACE. No src/R*.h, no LawState.h section, no getenv, no reader
function: two flags (elabProgProc443, elabIfaceProc443, raised by StmtEmit
emitProcess for the body only) and two predicates (progMemberSym443,
loopVarNameShadows443) in EmitHelpers.h. ParamEmit, include/, uhdm_main.cpp
and every sister file unchanged.

## Grid (cases/, drivers/grid.sh, evidence/r11u443_grid_law4.tsv)

65 case dirs in PF (33, program processes), PV (20, packed / string foreach
in modules, interfaces, classes, packages) and IF (12, interfaces), every one
accepted by upstream slang, every exit code 0 on pristine and law4,
pristine -> law4:

- 39 to STRICT_EQUAL: IF/if02, if04, if05, if06, if10; PF/pf01, pf02, pf03,
  pf06, pf07, pf09, pf10, pf11, pf12, pf13, pf14, pf15, pf16, pf18, pf19,
  pf21, pf22, pf23, pf24, pf26, pf28, pf29, pf31; PV/pv01, pv02, pv09, pv10,
  pv13 (from STRICT_NOTEQUAL type), pv14, pv15, pv16, pv18, pv19, pv20.
- 2 NOT_EQUAL -> STRICT_NOTEQUAL: PF/pf08 (two program instances: the
  shared process's bit_select is named work@top.p1.arr where golden names
  the last instance p2, fullname; pre-existing), PV/pv03 (`logic [3:0][1:0]`:
  golden's reference binds a logic_typespec 3:1-3:17 that is not the
  variable's own 3:1-3:12, endcol).
- 9 NOT_EQUAL on both and closer by dump distance: IF/if11 36 -> 33, if12
  5 -> 2, PF/pf04 85 -> 78, pf17 46 -> 32, pf25 23 -> 15, pf27 36 -> 25,
  pf33 49 -> 46, PV/pv08 34 -> 31 (uhdm-cmp 54 -> 17), pv12 62 -> 59.
- 15 byte-identical: residues IF/if03, if09, PF/pf20, PV/pv04, pv11 and the
  controls IF/if01, if07 (uninstantiated interface), if08 (uninstantiated
  program), PF/pf05 (program task), pf30 (module), pf32 (loop variable named
  like a program member), PV/pv05 (task local), pv06 (formal), pv07 (package
  variable), pv17 (class property).
- none further.

Downstream (drivers/dsgrid.py, evidence/r11u443_ds_*.tsv): the 63 case dirs
without a class, pristine and law4: 61 IDENTICAL and 2 EQUIVALENT (IF/if03,
if09) on both, no verdict changing.

## Earlier-case census (drivers/census.sh, evidence/r11u443_census4.tsv)

763 fence-filtered tools/probe case files holding `foreach`, pristine and
law4 traced: exit codes equal on all 763, 8 byte movers, each firing a law of
this pass and each judged against a fresh Surelog golden
(evidence/r11u443_cenmov.tsv): r11u131repro inet/n03_foreach and
n07_sub_foreach NOT_EQUAL -> STRICT_EQUAL (§ foreachPackedRefDeclTs443),
r11u439repro UP/up19, v11u439repro VP/vp09 and VS/vs09 NOT_EQUAL ->
STRICT_EQUAL (pass 439's residues, the program laws), r11u238repro F/f03
NOT_EQUAL -> STRICT_NOTEQUAL endcol, v11u280repro VA/va21_foreach_fork
closer (dump distance 71 -> 68; its uhdm-cmp count grows 56 -> 156 only
because the first difference moved later, to pass 280's hier_path name
z.g[i][k[0]] which golden folds to z.g[i][0]), v11u439repro VP/vp08 closer
(251 -> 246). None away.

## By-name prediction before the sweep, and the sweep

Prediction (law2 / law3 traced; law4 only adds the shadow abstention):
probe: 0 firings over the 46 probe cases holding `foreach`
(evidence/r11u443_probe_fe.csv, the two STRICT_NOTEQUAL rows at their
baseline detail) with the positive control up19 / pv01 firing; surelog: 0
firings over the 43 candidate tests (every corpus test whose sources hold
`foreach`, plus every UVM / OVM user), both modes, every row's status and
strict column equal to the control (evidence/r11u443_slcand.csv);
uhdm2rtlil and downstream: no test source holds `foreach` (cva6_equiv's
are not a corpus row); sv-tests: 0 firings over the 35 candidate rows (the
10 test files holding `foreach`, tnoc, the uvm-examples and hdlconvertor rows
whose sources hold it), every row equal to the control matrix
(evidence/r11u443_svcand.csv). Exit-code movers predicted: none. So the
prediction was 0 byte movers and 0 exit-code movers in all five stages.

The one five-stage sweep (drivers/fullsweep.sh, law4, md5
aa7960111f51c88854d70e8d2280d100, R11U443_TRACE set throughout, launched
after three quiet readings at 01:27:08 once the master's pass 442 integration
sweep had ended; workdir /tmp/r11u443sw1, the control's length):

- probe: EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0
  changes=0; csv identical to the control; the 4087 databases identical to
  the control by path-normalized dump (drivers/probedump.sh,
  evidence/r11u443_probedump.txt) with a positive control (a different
  database under the same name reads DIFF).
- surelog: default 480 CMP_EQUAL, testflags 474, regressions=0
  conversions=0 changes=0; the csv differs from the control only in the two
  LowMem log-path texts; Tnoc d/t CMP_NOTEQUAL standing.
- uhdm2rtlil: 803 / 1 / 67 in both modes, 0 / 0 / 0, csv identical to the
  control; stamped_gen_param d/t CMP_NOTEQUAL standing.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0,
  csv identical to the control.
- sv-tests: EQUAL 1913, DIFFERENT 27, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions=0
  conversions=0 changes=0; csv identical to the control. NO SV-TESTS ROW
  MOVES (no sv-tests row holds these shapes).
- byteverify (SELFCHECK=1) against the control: surelog 0 of 962,
  uhdm2rtlil 0 of 1608, downstream 0 of 805, the self-checks flagging 961,
  1607 and 804.
- canaries ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil);
  ctcan2 PASS on both.
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt naming law4
  (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests
  2346 of 2346.
- trace census: no firing anywhere in the sweep, as predicted.
- The corpus stages exited 1 on the stale law index alone (the four shadow
  case dirs added after the index was regenerated); tests/LAWS.md was
  regenerated afterwards and reads current.

## Residues (ranked; all wrong on pristine too, none moved away)

1. A foreach over a typedef'd unpacked array (PF/pf17, `a_t ta;`): golden's
   iterated reference and loop variable both bind the typedef's array_typespec
   (a_t) 4:9-4:20; ours binds unlocated array_typespecs (the reference through
   UhdmExporter's pendingForeachArrayTs drain, the arrayVarArrayTs entry
   being unlocated): the drain is the sister's file, the entry is filled by
   ModuleEmit.
2. A loop variable named like a block local, a member or a formal in a program
   or interface process (PF/pf20, pf33, IF/if11, if12, and pass 439's lm11,
   vl02 twins): golden lists a ref_var over the declaration's typespec and
   binds the reads to the declaration; ours an int_var (the laws abstain).
3. An ANSI input port iterated by a foreach (PV/pv04): the declaration's
   object carries no typespec reference when the process is emitted, so
   § foreachPackedRefDeclTs443 abstains.
4. A two-dimensional packed variable (PV/pv03): golden's reference binds a
   logic_typespec spanning 3:1-3:17, not the variable's 3:1-3:12.
5. A program instantiated twice (PF/pf08): the shared process's select names
   the first instance where golden names the last (StmtEmit's select
   back-patch across instances; not decoded).
6. A process-local array in a program (PF/pf04): golden lists the local as a
   program variable (ModuleEmit's program listing, sister's) and the loop
   variable over the local's located array_typespec.
7. Interface processes over a queue or associative array (IF/if03, if09),
   a class-keyed associative program member (PF/pf25, an implicit net K
   minted), a hierarchical foreach top.marr from a program (PF/pf27), a
   generate-block packed foreach (PV/pv12), a dotted interface member
   (PV/pv11), a typedef'd packed vector's listing (PV/pv08): each first
   differs at another face.
8. The carried lists of passes 441 and earlier (the brief's items (a) to
   (|)), untouched.

## Sister-ground faces (reported, not written)

- UhdmExporter's never-instantiated definition admission (control_slave,
  bsg_nonsynth_mem_1rw_sync_assoc, bsg_scheduler_dataflow: golden lists each
  as a module_inst); the 16 uvm-examples, 3 uvm_scoreboard and easyUVM
  listings (UhdmExporter / ModuleEmit / TypeEmit), as at pass 441.
- UhdmExporter's pendingForeachArrayTs drain minting a fresh unlocated
  array_typespec where golden binds the declaration's typedef'd array_typespec
  (PF/pf17), and ModuleEmit's program listing of a process-local variable
  (PF/pf04: golden lists `la` under the elaborated program's vpiVariables).

## Process

The IMPLEMENTER within the budget: one base build (md5 equal to the main
tree's), law1 to law4 on case runs and targeted traced runner calls only
(law2: the probe and surelog candidate runs; law3: the sv-tests and
uhdm2rtlil candidate runs and the first switch check), one full five-stage
sweep on the final law4. Slips, none affecting a measurement: a first sweep
launcher started on law3 was stopped by its recorded PID while it was still
waiting for quiet (no stage had run) when the grid found pf20's break; two
background waiters of mine matched their own command lines and were stopped
by task id; the targeted candidate runs and the 61-case switch check ran
while the master's pass 442 integration sweep was live (one process each, at
nice 19 for the switch check). The fence list was read into a file by a
program without printing it and every tree-wide list was filtered on it
before any file was opened; no other agent's process was touched; no fenced
test was named, opened or run.

## Files

- cases/PF, cases/PV, cases/IF: 65 case dirs, each dut.sv naming its law in
  its first line.
- drivers/: grid.sh, census.sh, switches.sh, dsgrid.py, probedump.sh,
  fullsweep.sh, scan.py (the fence-filtered `foreach` / `program` scan),
  env.sh.
- evidence/: the grid, switch, census, census-mover, downstream, candidate
  and probe-dump tables; the sweep logs.
