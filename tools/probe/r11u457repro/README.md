# r11u457 — pass 457, expression/parameter ground (implementer)

Base e8b7d96d (pass 455 on top of pass 454). Ground: src/ExprEmit.cpp and
src/StmtEmit.cpp (ParamEmit.cpp and EmitHelpers.h untouched). Four laws, each
behind its own switch read through src/LawSwitch.h (`lawOn(457, ...)`);
`R11U457_OFF` drops all four; `R11U457_TRACE=<dir>` logs each firing and each
abstention through `lawTrace(457, ...)`. No src/R*.h, no getenv, no reader
function, no header change.

Binaries: pristine = the main tree's build/slang-uhdm at the base (md5
4a384194392779cfff4f9d9ab48a83de; the worktree's own first build is
byte-identical), frozen at /tmp/r11u457_bin/pristine; final law binary law9
(md5 59a7e5b331028dd241e69343e6ee509a, links slang 12.0.0+545f88b2e).
law1 to law8 were case-run binaries only.

## Sweep (law9, one full five-stage run, `R11U457_TRACE` on)

tests/sweep.sh --jobs 3 --workdir /tmp/r11u457_sw from the worktree for probe,
surelog, uhdm2rtlil and downstream; the sv-tests stage through the main
tree's tests/sweep.sh on the same workdir and binary (the worktree's UVM
submodule is empty), that run exiting 1 on the main tree's law-index check
alone. Readings:

- probe: EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0
  changes=0; csv identical to the master's control.
- surelog: default CMP_EQUAL 480, testflags 474, regressions=0 conversions=0
  changes=0; csv equal to the control except the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not identical and
  not excused 0; csv identical to the control.
- sv-tests: EQUAL 1927, DIFFERENT 13, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions=0
  conversions=0 changes=0; csv identical to the control. No sv-tests row
  converts: none of the 13 open rows heads on this ground (table below).
- byteverify (SELFCHECK=1) law sweep vs the control: surelog 0 of 962,
  uhdm2rtlil 0 of 1608, downstream 0 of 805 movers, path sets identical,
  self-checks flagged (evidence/census/byteverify.txt). The prediction (no
  mover anywhere) held.
- canaries ok=52 and ok=16, changed=0; both ctcan2 checks PASS
  (evidence/census/canaries.txt). Binary audit: 3273 of 3323 surelog and
  uhdm2rtlil records name /tmp/r11u457_bin/law9 (the other 50 hold only a
  Surelog line), every sv-tests record names it.
- the sweep's trace (evidence/census/sweep_trace_law9.txt): no firing in any
  stage; 38 abstentions (the three probe cases above; MiniAmiq, SeqDriver,
  SimpleUVM and Scoreboard on the uvm-1.2 clone and class-copy bodies
  adjust_name -> uvm_leaf_scope and uvm_vector_to_string ->
  uvm_bitstream_to_string, callee body not one return; sv-tests rsd
  LSQ_ToBlockWordEnable -> LSQ_SelectBits, actual not a local). Abstentions
  write nothing.

## Goal 1

Nothing on this ground. No row of results/golden_svtests.csv in SURELOG_ONLY,
BOTH_REJECT or SLANG_CRASH carries the exporter's own `unsupported` text: all
75 SURELOG_ONLY details are slang front-end diagnostics (`error:` lines from
the sv-tests sources, the uvm_pkg time-scale error on the five rows whose
detail names a slang-uhdm path), so none is this ground's. The goal-1 probe
faces stay as the earlier passes left them: `C::mk().arr[1]` and
`u.mk(x).a[2]` (exit 4 here, 0 in upstream slang, Surelog a syntax error) and
`this.mk().inner.s` (v11u415 VT/vt03): golden has no shape to follow, so they
are not forced. The black-parrot size guard (§ macroVecLitTokenText403) was
not re-measured this pass: no change touches it. generated/rsd stays
SURELOG_CRASH (Surelog dies first).

## The 13 open sv-tests rows at the base (re-measured)

`scripts/svtests/svtests_matrix.py --paths-file` on pristine with
`--keep-golden`, uhdm-cmp and uhdm-strictcmp on each pair (lines = uhdm-cmp
output lines):

| row | uhdm-cmp | head | ground |
|---|---|---|---|
| uvm_ac_config_db | 17 | extra logic_net work@hvl_top.this 968:29 | sister (ModuleEmit, § thisNetPerListingModule452 family) |
| uvm_ef_vif_config_db | 29 | logic_net work@hdl_top.SFR_MASTER.reset unbound | sister (ModuleEmit interface task walk, wait_stmt) |
| uvm_id_register | 85 | class_typespec apb_agent_pkg::apb_sequencer under the module instance | sister |
| uvm_many_to_one | 104 | class_typespec b_pkg::A_sequencer under class_defn work@test in golden | sister |
| uvm_param_vif_config_db | 230 | class_typespec this_t 50:9 | sister |
| uvm_use_models_pipelined_get_put | 56 | int_var vs array_var foreach loop variable (below) | sister |
| easyUVM | 659635 | class_defn work@sequencer | sister |
| uvm_scoreboard_env, _monitor_env, _monitor_agent_env | 2.2M | design-level vector (LHS null) | sister |
| hdlconvertor_std2017_p733 | 36 | defparam constant 16:10 | awaits the user's decision |
| hdlconvertor_std2017_p737 | 2386 | design work@M (type parameter of a class default) | awaits the user's decision |
| tnoc | 28 | constant 241 at tnoc_pkg.sv 333:14 | awaits the user's decision |

None heads on this ground, so the pass took the probe backlog (brief item
(a), pass 455's residues: the out-of-body class-view calls golden folds).

uvm_use_models_pipelined_get_put, decoded further for the sister: golden's
uvm_pkg holds 105 more foreach loop-variable objects than ours, all `int_var`
over a location-less int_typespec, under `uvm_component` methods (do_flush,
get_children, get_depth, the set_report_*_hier family, ...) besides the
uvm_default_factory ones; in uvm_use_models_bidir_get_put (EQUAL) the same
uvm_default_factory variables are `array_var`. The loop variables come from
`UhdmWriter::swapForSpecifiedVar`, which re-swaps the loop variable each time
a component's `lateTypedefBinding` list holding the original `ref_var` is
processed (the swap reads the original ref, never the swapped object), so the
LAST component processing it decides: decodeHierPath of the array name in a
component where it does not resolve gives `int_var`. The extra objects say the
class is listed in more places in that design (a class-listing count, the
module/type ground), so the row is reported, not written.

## The face (pass 455's residue, item (a))

pass 455 left "class-view calls golden folds" (v11u455 VB/vb02, VK/vk01,
r11u455 OC/oc06) and pass 446 left CB/cb04 and CG/cg01 to cg03 NOT_EQUAL with
"golden writes no call objects in the clone bodies". The fresh grid shows
what golden writes instead. uhdm-strictcmp on CG/cg02 at the base:

    lhsPath: design(work@top) > package(p) > function(rep) > return_stmt > operation
    rhsPath: design(work@top) > package(p) > class_defn(C) > function(f) > return_stmt > func_call(rep)

i.e. the class_defn's copy of `function int C::f(int a); return rep(a);
endfunction` returns rep's OWN operation object `v + 1` (its parent is rep's
return_stmt), and the importer q's two listings of the clone return a COPY of
it (`ref_obj q::C::f::v`, unbound, parented in the copy).

Decode. Surelog (third_party/Surelog/src/DesignCompile/CompileExpression.cpp,
the `paSubroutine_call` branch): under `Reduce::Yes` a user call is handed to
`CompileHelper::EvalFunc` (EvalFunc.cpp) -> UHDM `ExprEval::evalFunc`
(third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp): the formals are
bound to the reduced actuals, the body's `return E` stores `reduceExpr(E)` as
the function's value, and unless `invalidValue` is set the func_call is
discarded and that object returned. With the actuals unvalued, `reduceExpr`
gives E back unchanged for `a + 1` (pass 300's kind 1), the constant itself
for a literal, and the bound actual for a bare formal. `compileStmt`'s
`paRETURN` branch is the only statement branch that passes the inherited reduce, and
`compileFunction` hands it the PACKAGE's reduce for a package-level
`paFunction_declaration`, which an out-of-body `C::f` is
(CompilePackage.cpp:213-218): the class copy of the body is compiled
Reduce::Yes in the elaborated package, an in-body method (CompileClass,
Reduce::No), a $unit or module class (Reduce::No) is not. `importPackage`
(CompileHelper.cpp:319-325) clone_trees the ELABORATED home's task_funcs, so
the importer's listings of a clone hold a clone_tree of the already-shared
expression, references re-bound by name in the copy.

pass 300 (§ pkgRetCallFoldSharesCalleeRet300) wrote this share for the home
package's own free functions only (kind 1, `a + 1`; kind 2, `$urandom`), and
excluded the class copy and the clones.

## Laws

1. **§ oobClsRetCallSharesCalleeRet457** (`R11U457_OOBCLSRETSHARE_OFF`;
   ExprEmit, at § pkgRetCallFoldSharesCalleeRet300's site) — the same share
   in the class_defn's own copy of an out-of-body method body whose class is
   declared in a package (`inClassBodyEmit && classBodyHomePkg75`, an
   out-of-block subroutine). The caller is read as the package the
   definition is written in: its declaration order is `outOfBlockIndex`
   (§ 300's callee-declared-earlier gate, OR/or16 against or17), its
   parameter-name lookups (§ retShareActualFoldAbstain300v) run from there.
   A class property passed as an actual abstains (OR/or08, or09: golden also
   hoists the unresolved name as an implicit net in every importing module,
   not modelled). Grid OR.
2. **§ importCloneRetCallCopiesShare457** (`R11U457_CLONERETCOPY_OFF`;
   ExprEmit) — in both listings of a wildcard-import clone (a free package
   function or an out-of-body method, `pkgImportCloneEmit`) a COPY of the
   share: the callee's `a + 1` rebuilt as an operation parented at the copy's
   return statement, each reference named under the copy and bound by name to
   the copy's own formal or local of that name, else unbound (IC/ic01 binds
   q::wrap::v to the clone's io_decl, ic02 leaves q::C::f::v unbound, ic03
   binds a local); a literal (law 3) copied as a constant. Grid IC.
3. **§ pkgRetCallSharesConstRet457** (`R11U457_CONSTRETSHARE_OFF`; ExprEmit
   in retShareKind300 and StmtEmit's constant-call branch) — kind 4: the callee's
   one statement is `return <decimal literal>` (unbased, or `'d` / `'sd`,
   sized or not) and its return type is a predefined integer type or a 2-state
   packed type: the call is replaced by the callee's own constant object.
   Reaches the home package functions too, where the call was minted as a
   second constant by the constant-call fold (KC/kc04 `rep()`, kc10
   `rep(2)`) or kept (kc01). Fences, each a measured cell: a hex, binary or
   octal literal keeps the call (kc08 `'h3`, kc16 `4'h3`, kc19 `4'b1x`); a
   4-state packed return type (logic / reg, written or implicit) is evalFunc's
   cloning and truncating branch (kc03, kc22); under an operator the constant is
   reduced with the operator into one constant (kc02, kc09, kc14, kc20), so
   only a call that is the whole return expression shares; a literal actual is
   accepted (kc23).
4. **§ pkgRetCallPassArgShare457** (`R11U457_PASSRETSHARE_OFF`; ExprEmit) —
   kind 3: the callee's one statement is `return v` with v one of its own
   formals: the call is built as usual and its ACTUAL for that formal is
   returned in its place, still parented at the discarded call and carrying
   the formal's typespec (PA/pa01, pa02 the second formal, pa03 under a unary
   minus, pa09 a logic vector formal; OR-context pa11, clone ic08). Every
   formal written positionally (pa05 default, pa06 named: abstain), a bare
   local actual (pa07 a literal, pa08 a package parameter, pa10 an operation:
   abstain), not under a binary operator (pa04, the reference would need late
   binding).

## Grid

64 case dirs under cases/ (OR 20, IC 9, KC 24, PA 11), every first line
`// § <law>`. evidence/grid_pristine_vs_law9.txt (run1.sh: exit code,
uhdm-cmp lines, strict verdict; md5 compared): every exit code 0 on both
binaries; 40 moved, 39 of them to STRICT_EQUAL (from uhdm-cmp NOT_EQUAL or
STRICT_NOTEQUAL depth/type), OR/or18 closer (uhdm-cmp 90 -> 44, its second
method's re-parented share left, residue); 24 byte-identical controls. No
case worse. Pass 446's CB/cb04, CG/cg01 to cg03, v11u446 VC/vc07 and r11u455
OC/oc06 also read STRICT_EQUAL on law9 (the 1110 case dirs of the r/v
445-455 repro grids rerun: those 7 move, all to STRICT_EQUAL, every other dir
byte-identical).

Switches (evidence/switches_law9.txt): `R11U457_OFF` gives pristine's bytes
and exit code on 64 of 64 dirs; each mover's own law switch alone restores
pristine, except the measured pairs (ic02, ic07, pa11: the class-copy law
with the clone copy; ic08 the clone copy with the pass-through; kc24 the
constant with the clone copy), which need both.

## Census (before the sweep)

- The probe gate: law9 traced over all 4087 tests/probe cases
  (drivers/cenprobe.sh): 0 firings, 3 abstentions (r10buvm8repro/v6ctx8,
  r10uvm180repro/g180_a_kinds, r10v180repro/v180_a_share), all 4087
  databases byte-identical to the master's control
  (evidence/census/probe_law9.txt).
- The corpora: a fence-filtered text scan (drivers/scan.py over the 4048
  package-holding sources of the Surelog, uhdm2rtlil, probe and sv-tests trees,
  evidence/census/scan_hits.txt) for a free function whose one statement is
  `return` of a decimal literal, a name or `name + x`; the candidate rows run
  traced on law9: surelog PackFuncParent, SplitFile, FilePackageImport,
  ClassFuncTask, SimpleClass1 (both modes), uhdm2rtlil simple_package,
  FunctionCallsFunctionWithIndexedPartSelectAsArgument,
  ImportedFunctionUsesAnotherFunction (both modes), sv-tests 26.2, 26.3,
  class_test_49, p779, p780, fusesoc ibex-sim, uvm_messaging_example: no trace
  line, statuses as golden. UVM's only free-function callee of these shapes
  (`uvm_dpi_regexec`, `return 0`) sits under `UVM_NO_DPI` and has no package
  caller.
- Positive control: the same trace on the grid (evidence/census/
  positive_control_law9.txt) names every law.
- PREDICTION, written before the sweep: no mover in any of the five stages;
  every csv equal to the control.

## Residues (all wrong on pristine too, none moved away)

1. A share re-parented under a binary operator whose expression holds a
   reference (OR/or05 `rep(a) + 1`, IC/ic04, KC kc02 / kc09 / kc14 / kc20
   where the constant folds with its operator, PA/pa04): golden's late
   binding renames the reference under the caller and mints an implicit net
   in the importing module (OR/or18's second method). Not modelled.
2. A class property as an actual (OR/or08, or09, v11u455 VW/vw01, VK/vk01):
   golden shares and hoists the property name as a module net.
3. The out-of-body return's OTHER reductions (the k grid kept in
   /tmp only, shapes for the next pass): `return a + 2*3`, `return P + 1`,
   `return a + P`, `return 2*3`, `return $clog2(P)` reduce in golden's class
   copy (constants at the first operand's location, size 64), the multi-
   statement callee (`t = v + 1; return t;` returns the assignment's
   operation), a callee called with a valued actual (`rep(3)` -> a new
   constant at the call); the explicit `import p::wrap` clone (IC/ic06).
4. pass 453's residue ts02 / xp05 / vo07 (a typedef-typed package parameter
   re-exported through a second package, uhdm-cmp at a constant's size 4 vs
   64), DECODED this pass, not written: it is the param_assign typespec's
   vpiInstance. In an importing package's DEFINITION listing golden's
   re-exported param_assign (Rhs constant and Lhs parameter) points at the
   home package's DEFINITION view (Surelog importPackage clone_trees the
   home's ParamAssign objects, built in its unelaborated compile), while its
   Parameter points at the elaborated view; ours points every one at the
   elaborated view (§ stampPkgTsInst, ParamEmit). Typespec::Compare follows
   vpiInstance into the two package views, whose param_assign sizes differ
   (64 unelaborated, 4 elaborated) only when the type is a typedef. Golden
   also gives each alias copy its owner's instance and the module definition
   view's Lhs the elaborated view. Measured on BlackBePipeInt (golden 7741
   references from bp_be_pkg's definition listing to bp_common_pkg's
   definition view, ours 108 to the elaborated one), so writing it moves
   bytes on every corpus row with a package re-export: left for a pass that
   can afford that mover census. Tool: evidence/tools/rtinst.cpp,
   drivers/rtdiff.sh.
5. v11u453 VR/vr11 and the twin grid pc01, pc02, pc04 (kept in /tmp): see
   sister-ground faces.
6. The carried lists of passes 455 and earlier.

## Sister-ground faces (reported, not written)

- ModuleEmit's elaborated port connection (the § modConnSelWholeLeafElab319 /
  § modConnLeafVarSel317 rename in emitInstance): `.i(q[1][3:2])` renames the
  var_select to work@top.u.i.q but leaves its trailing part_select at
  work@top.q.q where golden writes work@top.u.i.q.q (the definition view is
  already right). v11u453 VR/vr11 STRICT_NOTEQUAL on fullname, also for
  `q[1][3-:2]`.
- uvm_use_models_pipelined_get_put: the class-listing count behind the
  foreach loop-variable kinds (above).

## Process

Within the budget: law1 to law9 on case runs and targeted traced runner calls
(5 surelog rows, 3 uhdm2rtlil rows, 7 sv-tests rows, the probe set by
exporter-only replay against the control), one full five-stage sweep on law9.
The fence list was read into a file by a program and every tree-wide list
filtered on it before any file was opened. Slip: one comparison command ran
with `$UHDM_CMP` unset (the shell had not sourced the env file), so the shell
executed a golden database as a script; it printed errors and wrote no file
(both trees' `git status` clean); every later command sourced the guarded env
file.
