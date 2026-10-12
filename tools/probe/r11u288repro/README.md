# r11u288: pass 288, the expression/parameter ground (ExprEmit, StmtEmit, ParamEmit)

Base fc30ffe8 (pass 290 on top of pass 291).  Five laws behind src/R288.h.  Each law has its own switch
`R11U288_<LAW>_OFF`, `R11U288_OFF` drops all five, and `R11U288_TRACE=<dir>` logs every firing, abstention
(a tag ending in `_ABSTAIN`) and switched-off firing (detail `off`) to `<dir>/<pid>.288`, whose first line is
`OUT <-o path>`.

**Result: SIX PROBE CONVERSIONS, no probe change.  No corpus row changes status.  0 of 2560 corpus databases,
0 of 805 downstream databases and exactly the 6 converted probe databases move in bytes.**

Binaries were built in the worktree with the system-deps config at -j 2 and frozen with `chmod 555` before any
measurement:
- pristine `834660b326d9b8dd22fc4d8e3ec6bc8a`, byte-identical to the main tree's build/slang-uhdm
- law `42fb9061ac0c2d943b52fb020aae65f6`

Both binaries report slang 12.0.0+545f88b2e.

## The probe conversions (fresh law-sweep rows; results/ is untouched)

| case | base | law sweep row | law |
|---|---|---|---|
| r10uvm158repro/g158_a_shape | differ:file(1) | `r10uvm158repro/g158_a_shape,EQUAL,,equal` | § badItemLocThroughInvalid288 |
| r10v158repro/v158_d | differ:file(1) | `r10v158repro/v158_d,EQUAL,,equal` | § badItemLocThroughInvalid288 |
| r10vrgg9repro/cells/v_pred_cast | differ:file(1) | `r10vrgg9repro/cells/v_pred_cast,EQUAL,,equal` | § parenCastReadsCastSyntax288 |
| r10uvm116repro/g116_f | differ:fullname(2) | `r10uvm116repro/g116_f,EQUAL,,equal` | § randWithCallParentByConsumer288 |
| r10buvm29repro/g29_d_fence | differ:fullname(2) | `r10buvm29repro/g29_d_fence,EQUAL,,equal` | § streamPartSelLazyName288 |
| r10buvm21repro/g21b | differ:col(1) | `r10buvm21repro/g21b,EQUAL,,equal` | § incDecIpsWholeSpan288 |

Probe totals: base EQUAL 3929 + STRICT_NOTEQUAL 158 -> law EQUAL 3935 + STRICT_NOTEQUAL 152.  The compare against
results/golden_probe.csv reads `regressions=0 conversions=6 changes=0`.

## The laws

### § badItemLocThroughInvalid288 (`R11U288_BADITEMLOC_OFF`, StmtEmit, the case statement's `itemLoc`)

slang returns a case item whose body it rejected as an InvalidStatement.  Examples are a bad block such as
`begin SS v; v = SS::born("v"); end` over a class type parameter whose default is `int`, or a single rejected
statement.  The InvalidStatement has no syntax and an empty range, and its child BlockStatement has no syntax
either, so `itemLoc` stamped no location on the case_item.  Surelog locates every case item at its own syntax
whatever its body compiles to (golden v158_d 52:9-55:15).

The law finds the item syntax in two ways:
- a standard item: from its first expression, read through any implicit conversion slang wrapped around it
  (a string item against a string case expression) up to the StandardCaseItem
- the default branch: from the DefaultCaseItem of the case statement's syntax, reached from the case condition's
  syntax when the statement holds none

It abstains (`BADITEMLOC_ABSTAIN no-item-syntax`) when neither route finds the syntax.  An item whose statement
has syntax or a range is untouched.

### § parenCastReadsCastSyntax288 (`R11U288_PARENCAST_OFF`, ExprEmit, the Conversion branch)

slang gives a parenthesized expression the parentheses node as its syntax.  So a written cast inside
parentheses, such as `(int'(P)) ? 42 : 7` or `s u1(.i((int'(x))))`, reached the cast branch with a
ParenthesizedExpression.  The cast branch then never saw the CastExpression: the target typespec was minted with
no location, and for many target kinds the cast was built in a form uhdm-cmp rejects.  Grid PC/pc01 measured
these kinds at stage 1 on pristine: shortint, longint, integer, a module typedef, a size cast `4'(x)` and a
parameter width `W'(x)`.

The law reads the cast through any number of parentheses, just before the main CastExpression branch.  It
follows the same model as § withCallParenSyntax286.  The checks above that point (string, stream and port
casts) keep pristine's reading, and § 115's typedef-parenthesis branch already unwraps its own shape.

**Refinement inside the law (grid PC/pc01 v13):** a cast to a TYPE PARAMETER, `(T'(x))`, abstains
(`PARENCAST_ABSTAIN type-parameter-target`).  The bare `T'(x)` is a standing residue: exit 4 and strict `type`
on every binary.  The first draft therefore traded pristine's location-only difference for exit 4.

### § randWithCallParentByConsumer288 (`R11U288_RZPARENT_OFF`; record in ExprEmit at § scopeRandomizeIsBareCall116, sites in StmtEmit, drain in ExprEmit rzWithParentDrain288 called from ParamEmit's design-final drain list)

Surelog's `compileRandomizeCall` never parents the with-form `method_func_call`.  This is
§ scopeRandomizeIsBareCall116's parentless regime.  The consumers of the call do parent it, decoded from
third_party/Surelog/src:
- `compileConditionalStmt` sets `cond_exp->VpiParent(cond_stmt)` when the condition has no parent (if and if-else).
- The immediate assertion, assumption and cover set `expr->VpiParent(astmt)`.
- The binary and ternary branch of compileExpression re-parents every operand at the operation
  (`opL->VpiParent(operation)`, `opR->VpiParent(operation)`).  The LEFT operand is compiled before the operation
  exists, with the operation's own pexpr.  Its constraint, which `compileConstraintBlock` parents at that pexpr,
  therefore hangs at the operation's parent.
- A unary operand, an assignment's right side, a while condition and a return value stay parentless (measured:
  rz01's while, return and `!( )` cells, and golden g116_f cells one, three and four).

With a parent, the identifier-list arguments are named by the parent chain (golden `work@picker_f::two::slot_f`),
so the bare name that bareArgName116 stored is cleared.  The drain abstains (`RZPARENT_ABSTAIN`) when:
- the call's emission parent is not an operation (`parent-not-operation`)
- the call is not among the operation's operands (`not-an-operand`)
- the operation is unary (`unary`)

These are the abstentions the census lists on the UVM rows and g116_a/g/h.

### § streamPartSelLazyName288 (`R11U288_STREAMPS_OFF`, ExprEmit, the simple part-select's full name)

The simple part-select freezes its full name from the parent chain at creation.  Inside a streaming
concatenation the operands are emitted under the inner concat before that concat and the stream operation are
parented, so the freeze read a chain cut at the concat and stored the bare name.  Surelog's part_select name is
the lazy walk over the FINAL chain:

| home | golden name |
|---|---|
| module | `work@d29.i` |
| module function | `work@d29.mf.v` |
| class method | `work@sc::cf::v` |
| package function | `sp::pf::v` |

Inside a stream the name is left unfrozen (trace `STREAMPS <name>`), so the walk reads the completed chain.  The
explicit branches above it are untouched: the package-qualified name, the parameter initializer, the
generate-array prefix, the definition-view generate process and § genScopeProcPsNamedByScope154.

### § incDecIpsWholeSpan288 (`R11U288_INCDECIPS_OFF`, ExprEmit, the indexed part-select's span)

An indexed part-select that IS an increment or decrement operand (`pvec[s+:2]++`, `--q[k-:2]`) is an lvalue in
Surelog's grammar: `inc_or_dec_expression` over a `variable_lvalue`.  So it spans the whole select like any
assignment target (golden g21b 29:43-53).  This emitter reaches it as a unary operand with `inLhs` false and
spanned the selector alone (29:48-52).  The law applies only to the operand itself
(`incDecOperand124() == &expr`): a select nested in the operand's index stays an rvalue (grid ID/id02
`r[idx[k][1 +: 2]]++`, equal on both binaries).

## The grid (evidence/grid.txt, grid_summary.txt, grid_attrib.txt, grid_away.txt; every line carries rc)

There are 29 case dirs under cases/, each run in both views, for 58 case-views.  Every case names its law in
its own first line.

| family | cases | law |
|---|---|---|
| CI | 11 | § badItemLocThroughInvalid288 |
| PC | 8 | § parenCastReadsCastSyntax288 |
| RZ | 3 | § randWithCallParentByConsumer288 |
| SP | 4 | § streamPartSelLazyName288 |
| ID | 3 | § incDecIpsWholeSpan288 |

Each case-view was run with pristine, the law, the law under R11U288_OFF and the law with each single switch.
`drivers/gridall.sh` runs it and `drivers/case.sh` builds the goldens with the pinned Surelog.

**Movers: 52 of 58.**
- 31 enter STRICT_EQUAL and none leave.
- No exit code changes.
- R11U288_OFF gives pristine's bytes on 58 of 58.
- Each mover goes back to pristine under exactly ONE switch: BADITEMLOC 18, PARENCAST 14, STREAMPS 8,
  RZPARENT 6, INCDECIPS 6.

**uhdm-cmp line changes: 8 case-views.**
- PC/pc05 76 -> 0 and PC/pc06 12 -> 0, both views.
- PC/pc01 16 -> 70 and PC/pc02 16 -> 46, both views.  These grow because the first head moves LATER:
  - pc01's pristine head was the shortint cast.  The new head is `(signed'(x))`, where golden emits a
    `$signed` sys_func_call and both binaries differ.
  - pc02's new head is the task-call argument `t(y)`, also wrong on pristine.

**Away census (chain-keyed, drivers/awaygrid.sh with drivers/awaychain.py):** away 0 on all 52 movers, with 698
records moving toward golden.  The positive control swaps the two binaries (evidence/away_poscontrol.txt) and
reads away 1 to 10 on 12 of 12 sampled movers.

**Downstream on the fresh module cases** (evidence/downstream_cases.txt, `scripts/downstream_uhdm2rtlil.py`'s
`one()` through drivers/dscases.py):
- No verdict is worse.
- Six cases improve:

| case | pristine | law |
|---|---|---|
| PC/pc01 | STATUS_DIFF | IDENTICAL |
| PC/pc07 | DIVERGENT | IDENTICAL |
| PC/pc05 | EQUIVALENT | IDENTICAL |
| PC/pc06 | EQUIVALENT | IDENTICAL |
| ID/id02 | EQUIVALENT | IDENTICAL |
| ID/id03 | EQUIVALENT | IDENTICAL |

  The located cast typespec reaches the plugin's width and src attributes.

## Byte controls (drivers/controls.sh, path lists filtered by $FENCED first; evidence/controls.txt, controls_summary.txt)

The controls cover 28 earlier repro dirs:
- r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131
- r11u181, r11u184, r11v184, r11u244, r11u115, r11u121, r11u246, r11u258
- r11u270, v11u270, r11u282, v11u282, r11u284, v11u284, r11u286, v11u286, r11u290, v11u290, r11u21

That is 2907 case dirs and 5814 case-views, with both binaries on each.  **2 move**: r11u181repro/cases/bx/b15
d and e (`din[(int'(i))]`, a parenthesized cast as a select index).  Both enter STRICT_EQUAL under PARENCAST
(R11U288_PARENCAST_OFF gives pristine's bytes), with chain away 0 and 2 records toward golden.  Nothing leaves
STRICT_EQUAL, and no exit code or uhdm-cmp line count changes.

## Gates (worktree sweeps, SLANG_UHDM exported, workdirs /tmp/r11u288_wP and /tmp/r11u288_wL)

**Firing census, frozen BEFORE the law sweep** (drivers/tracecensus.sh; evidence/predict.txt, md5 f17c9310):
- It fires on exactly the 6 probe conversions.
- It records abstentions only on the probe cases g116_a/g/h and v116_q/r/u/w, the UVM rows (MiniAmiq d/t,
  SeqDriver d/t, SimpleUVM d/t, Scoreboard d; RZPARENT_ABSTAIN) and uhdm2rtlil static_cast_simple d/t
  (PARENCAST_ABSTAIN).
- It predicts 0 corpus movers and 0 downstream movers.

**Probe:** EQUAL 3935 + STRICT_NOTEQUAL 152.  regressions=0, conversions=6 (above), changes=0.

**Surelog:** default CMP_EQUAL 480 + 0 and testflags 474 + 0, the 954 of 954 judge-equal row-modes unchanged.
regressions=0, conversions=0, changes=0.  The csv is row-identical to the pristine sweep's except the LowMemLib
and LowMemPkg testflags detail text, which carries the workdir path.

**uhdm2rtlil:** 803 / 1 / 67 in both modes (1606 + 0).  regressions=0, conversions=0, changes=0, with
stamped_gen_param d/t staying CMP_NOTEQUAL.

**Downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT.  The csv is byte-identical to the
pristine sweep's, and 0 of 805 slang-lane databases differ.

**Byteverify on fence-filtered mirrors** (drivers/mirror.sh; tools/probe/r11v75repro/byteverify.sh;
evidence/byteverify_*.txt):
- corpus: PATH_SETS_IDENTICAL, MOVERS 0 / 2560
- probe: exactly the 6 predicted databases
- SELFCHECK reads 2559 of 2560.  This is the comparator's self-check artifact (pass 201): every file is compared
  against one fixed file, and that file is not flagged against itself.  It is not a mover.

The away census on corpus movers was not needed: there were 0 movers.

**Canaries:**
- surelog ok=52 changed=0
- uhdm2rtlil ok=16 changed=0
- ctcan2 (EXPECT_UNKNOWN=1 surelog, EXPECT_UNKNOWN=6 uhdm2rtlil) PASS on both

**Binary-path audit:** 3273 of 3323 cmds.txt name each sweep's own binary, on both sweeps.  The other 50 carry
no slang line.

**Determinism** (drivers/det.sh; evidence/determinism.txt): three concurrent draws of the law binary on
Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes give one hash per
row-mode, each equal to the law sweep's.  Scoreboard/testflags and Rggen/testflags write no database on either
binary.

Both sweeps exited 1 on the law-index check alone.  tests/LAWS.md was regenerated last for the patch.

## The probe residue at the base (evidence/residue_first_records_base.txt: first records of all 158)

Ranked by ground, with the probe cases still open after this pass:

**This ground, decoded and not written (each one case, a separate face):**
- r10uvm193 g193_c_argface: an index reference inside a method-call receiver path `fleet193[kink193].rub193(..)`
  in a wildcard-import clone.  Golden names it through the hier_path because the home parents it at the
  hier_path, and the clone's DeepClone then walks that chain.  Ours parents it at the bit_select.
- r10uvm48 t67e: `arr[base67::stat.hval] = 3`.  Our stored name carries `arr::`.
- t67d: `h2.q67::` against golden `h2::q67::`.
- r10uvm175 g175_c_tail: the `holds[berth].randomize() with` receiver select located at its index (Surelog quirk).
- r10uvm79 c2_idxkind, v92_b2_varsel, b1_sites, b3_edges, v8_sites2: the select-naming leftovers that earlier
  passes named.
- r11u21 t9 and r11u24 n1: the member-path select element spans.
- r11u117 t12: a package-qualified member path `q2::IMPL.m` returned from a module function.  Golden leaves the
  hier_path parentless; ours parents it at the return_stmt.
- r10svs8 a3_builtins: a coverpoint `get_coverage()` path end column.  Ours exits 4 there.
- r10uvm59 c05_cast: `int'(T::get())` in a generic class.
- The ID grid's member-path inc/dec `sv.f[k+:2]++` (defname and col, wrong on both binaries).

**Sister ground (REPORT):**
- r10earl115 p1_pos115 and r10earl121 a1_axis121.  The definition-view generate cont_assign pattern members
  span only the first token: the hier_path `three_i[i].lo.f0` 59:32-39 against golden 32-48, and the enum
  constant `p115p::OpA` 32-39 against 32-42.  The writer is TypeEmit emitSyntaxExpr under ModuleEmit
  emitDefGenStmts.
- r11v46 grid7: the `$unsigned(MM)` genvar initializer, same writer.
- The type-parameter struct full names: r11u47 g2, g10 and g12, r11v47 v12 and v28, r11u112 k14, r11u107 t13
  (TypeEmit).
- The import clones of package functions: the depth(1) cluster r10uvm171 a/b/c, r10uvm194 c, r10uvm227 a9,
  r10uvm52 a1, r11v48 va8, r10buvm8 v9fold8 and r10buvm13 v3_clone13, plus g122_f_clone and q6clone.  These are
  TaskFuncEmit and UhdmExporter clone sites.
- The class struct-member typespec in SP/sp04 (`struct packed {...} st;` in a class, endcol plus the member
  ref_typespec name, TypeEmit).
- The PC residues:

| case | residue | wrong on pristine too | owner |
|---|---|---|---|
| pc01 | `(signed'(x))`: golden's `$signed` sys_func_call | yes | this ground |
| pc03 | the parameter default `(byte'(9))` fold | yes | ParamEmit |
| pc04 | the port array typespec of `o[4], q` | yes | ModuleEmit |
| pc05 | `T'(a)` over a class type parameter: golden locates the int at the parameter default 7:22-25 | yes | type-parameter abstention |
| pc07 | `string'("ab")` cast operation | yes | this ground |

**Not copied:** the r11u109 64-bit cast values (a Surelog defect).

**The brief's items (2) to (7):** not attempted beyond the faces above.

## Process

- Every corpus path list was built first and filtered by `$FENCED` (read fail-closed from
  tools/probe/r11u107repro/canaudit.sh) before any file was opened.  No fenced source or database was read or
  run.
- No other agent's process was listed or signalled, and the main tree was not written.
- **The IMPLEMENTER'S SLIPS:**
  - A background waiter used `pgrep -f` with a pattern that matched its own command line.  It was stopped by its
    own task id before it signalled anything, and was replaced by a file-existence waiter.
  - The probe and downstream byte comparisons filtered their path lists with the four fenced names spelled in a
    grep pattern instead of `$FENCERE`.  This was a path filter only, and nothing fenced was opened.
  - The first two pristine builds raced in one build tree.  The link failed and was redone, and the frozen
    pristine binary's md5 equals the main tree's.
- Draft fixes before freezing:
  - BADITEMLOC: first did not reach the default branch and the string item.
  - PARENCAST: the type-parameter abstention.
  - RZPARENT: the assertion site.
