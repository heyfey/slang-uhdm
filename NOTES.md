# slang-uhdm development notes

Running log of Surelog-shape observations, replicated quirks, and decisions.
See PLAN.md for the overall strategy. Anchor versions: UHDM `5523dfc`
(v1.86-31, installed to ~/.local), Surelog `cbdbea458c` (v1.86-114).

## Golden-dump observations (mux2, `surelog -parse -nobuiltin -nocache`)

Source of truth: `uhdm-dump` of `slpp_all/surelog.uhdm` for
`~/git-repos/uhdm2rtlil/test/mux2/dut.sv`.

- Design: `VpiName = "work@<first-top>"`. No vpiElaborated flag in folded
  output.
- **Folded model shares process objects**: `uhdmtopModules` module contains
  the *same* `always` object as `uhdmallModules` (dump prints a stub on
  revisit). Nets and ports, however, are **separate objects** in each view.
- Module def (allModules): has `VpiDefName` + `VpiFullName` (no `VpiName`);
  top module (topModules): `VpiName` + `VpiDefName` + `VpiFullName` +
  `VpiTop(1)` + `VpiTopModule(1)`. (dump prints vpiFullName only when it
  differs from vpiName, so def shows FullName and top shows Name)
- Net objects for port-connected signals take the **port-list location**
  (line 1), not the declaration location (line 2). `output reg Y` becomes a
  `logic_net` with `VpiNetType = 48` (vpiReg) — not a variable.
- Port `Low_conn` ref_obj naming differs between views:
  def view `work@mux2.S.S` (port-scoped), top view `work@mux2.S`.
- Typespecs: def-view nets carry **no** typespec; top-view nets carry
  `Typespec -> ref_typespec -> logic_typespec` (ts parent = the net). Ports in
  both views carry `Typespec` (dumped as `vpiTypedef`) `ref_typespec` with
  `VpiFullName = work@mod.<port>`.
- Typespec location = the declared type syntax; for implicit types a
  zero-width range at the declaration identifier (e.g. `input S;` ->
  2:11-2:11); for `reg Y` the `reg` keyword range (4:12-4:15).
- mux2 has **10** logic_typespec objects in the weaklyReferenced dump
  section: 3 unparented (one per declaration?), 3 parented to top nets S/B/Y
  (not A!), 4 unparented (port typedefs). Creation-order dependent; not yet
  replicated exactly — see Open questions.
- always block: `VpiAlwaysType(1)`; `@(*)` = `event_control` with **no**
  condition; assignment carries `VpiOpType(82)` (vpiAssignmentOp) +
  `VpiBlocking(1)`; ternary = `operation VpiOpType(32)` with operands
  [cond, true, false]; expression `ref_obj`s point (`Actual_group`) at the
  **def-view** nets.
- Locations are name-span based for named objects (`S` at 1:14 -> 1:14-1:15);
  end column is one past the last character.

## Replicated quirks

- `work@` prefix on def names, full names, and design name.
- Port-list location used for port-connected nets.
- `VpiNetType(48)` for variables that back ports (output reg).
- Def/top low_conn naming difference (`.S.S` vs `.S`).

## Open questions / not yet replicated

- Exact typespec object count/creation order (weaklyReferenced section
  order). May need a documented sort-normalization in converge.sh, or
  replicate Surelog's per-declaration + per-net typespec cloning rules
  (see Surelog NetlistElaboration.cpp / CompileType.cpp).
- Whether Surelog sets VpiFile on every object or only module_inst
  (dump only prints it on modules; uhdm-cmp will reveal).
- Design VpiName for multi-top designs (first top? all tops?).

## Status log

- 2026-07-17: M0/M1 scaffold written (tools/uhdm; CMake gated on
  find_package(UHDM)); UHDM installed to ~/.local; slang build reconfigured
  with CMAKE_PREFIX_PATH=~/.local. Building.

## Hierarchy quirks (AssignSumOfConstantsInSubmodule, 2026-07-17)

- AllModules = ALL used definitions, name-sorted; def content is filled
  LAZILY as the instance tree first reaches each definition. Per-instance
  creation order: def fill -> instance vars/nets -> children (recursive) ->
  instance ports -> cont_assigns/processes. weaklyReferenced dump order
  depends on this exactly.
- Def view: children appear as ref_module (name, defName, Actual_group->def
  module, loc=instance name span) with ports carrying only High_conn
  ref_objs named work@<mod>.<inst>.<formal>.<actual> pointing at def nets.
- Top view: children are full module_inst objects: VpiName/VpiFullName
  (instance path), VpiDefName, VpiDefFile+VpiDefLineNo, Instance(parent) AND
  Module_inst(parent) back-refs (Module_inst is invisible in uhdm-dump but
  checked by uhdm-cmp!), loc = whole instantiation statement. Contents are
  re-emitted per instance (instance-path fullnames); only TOP modules share
  the def's process objects (their prefix equals the def prefix).
- Child ports: loc = def port loc; LowConn ref at the formal name in the
  connection (.a -> `a` token), full = instpath.formal, actual = child
  net/var. HighConn = plain expression ref bound in PARENT scope (parent
  netmap, parent prefix, actual = parent net/var).
- When a parent signal feeds a child HighConn, the signal's typespec gets
  VpiParent(re-set) to the signal (source of the mux2 {S,B,Y}-style parent
  pattern for vars; nets always get ts parent at creation).
- Top-view cont_assign Rhs is CONSTANT-FOLDED when the expression is
  constant and not a plain literal: constant with decimal decompile,
  UINT:<val>, vpiSize = expr type width, no loc/parent. Def view keeps the
  unfolded expression.
- Bare unsized decimal literals: UINT:<digits>, vpiSize 64, vpiConstType 9.
  Sized/based literals: BIN/HEX/OCT/DEC:<digits>, vpiSize = literal size,
  vpiDecompile = source text. Constants get VpiParent only as operation
  operands (and in typespec range bounds, where they're 64-bit UINT).
- `int` ports: def view = plain logic_net (no netType); top view = int_var
  (Signed, Visibility 1) in Variables; int_typespec (VpiSigned) everywhere.
- uhdm-cmp compares fields the dump never prints (Module_inst, typespec
  Instance) — DUMP_MATCH alone is not sufficient; always require PASS_CMP.

## Session 1 later findings (2026-07-17)

- Local (non-port) declarations: def view = logic_net with typespec
  (ref_typespec parent=net) AND vpiNetType (wire=1, logic=36, reg=48);
  implicit-typed net decls anchor the typespec at the net keyword ("wire").
  Top view: 4-state variables (logic/reg, non-port) become logic_var
  (Visibility 1, Signed if signed) in Variables; explicit nets stay
  logic_net. Port-backed `output logic` stays a net (flipflop).
- Top modules SHARE the def's cont_assign objects unless constant folding
  changes the Rhs (then a fresh cont_assign with folded constant).
  Processes: shared for top modules, re-emitted for child instances.
- bit_select: name/fullname of base signal, loc = the INDEX expression
  span, VpiIndex = index expr; its index constants ARE parented.
- part_select: name + VpiDefName(= name) + fullname, loc = whole select
  expr, VpiConstantSelect(1) for constant bounds, Left_range/Right_range
  constants NOT parented.
- Unbased-unsized literals ('0/'1/'x/'z): VpiSize(-1), BIN:<digit>,
  vpiConstType 3, decompile = source text.
- Constant parenting rule (current best model): parent set when the
  constant is an operation operand or bit_select index; NOT set for
  assignment/cont_assign sides or part_select ranges (typespec range
  bounds get parents explicitly as 64-bit UINTs).
- OPEN: exact conditions for typespec VpiParent on top-view port-backed
  nets. mux2 (non-ANSI, shared decls) and flipflop (ANSI, always-block
  usage) have parents (my always-set rule matches); a synthetic ANSI test
  with cont_assign-driven outputs shows Surelog leaving o/y typespecs
  unparented while my code parents them (weakly-tail diff only, cmp still
  passes). Revisit with corpus data — grep results-rN.csv for CMP_ONLY
  tests with small diffs.
- Scoreboard classes: PASS (dump+cmp), DUMP_ONLY (dump match, cmp fail —
  invisible-field mismatch), CMP_ONLY (cmp pass, dump diff — usually
  weakly-tail ordering), DIFF, UNSUPPORTED (exporter said so), CRASH,
  SLANG_REJECT (slang refuses non-LRM code Surelog accepts), SURELOG_FAIL.
- Corpus history: r1 (M1 only): 4 PASS. r2 (hierarchy): 9 PASS, 136 DIFF,
  516 UNSUPPORTED, 0 crash. r3: after local decls + selects + sharing.
- Next features by corpus frequency: for loops, case statements,
  member access (structs), function calls, parameters/paramod, generate.
- r3 (local decls + selects + sharing): 11 PASS, 15 CMP_ONLY, 135 DIFF,
  497 UNSUPPORTED, 0 CRASH. Case statements landed after r3; r4 running.
- Case shapes: case_stmt VpiCaseType (1 exact / 2 casex / 3 casez),
  condition parented at enclosing scope (same quirk as if), case_item loc
  from the case-item syntax (through ';'), item constants parented,
  multi-expr comma items in one case_item, default = case_item w/o exprs.
- for loops: for_stmt loc = "for" keyword only, VpiFullName = scope prefix;
  init/inc go in the PLURAL VpiForInitStmts/VpiForIncStmts vectors (the
  singular fields print in a different order and fail cmp); inline loop var
  = int_var (Signed, NO Visibility) as the init assignment's Lhs (init
  assignment has no opType/blocking; its constant Rhs IS parented);
  condition parents at the for_stmt (unlike if/case). slang's implicit
  wrapper block around for-with-decl is skipped (no begin in Surelog).
- Lvalue bit_selects span the whole select expr; rvalue ones anchor at the
  index expression. Replication count constants: unparented in def view,
  parented in re-elaborated context.
- r4: 12 PASS + 15 CMP_ONLY. r5 (concat/replication + reparent rules):
  13 PASS + 16 CMP_ONLY, 484 UNSUPPORTED, 0 crash.
- r6 (for loops, lvalue selects, golden suite): 14 PASS + 15 CMP_ONLY, 483 UNSUPPORTED, 0 crash. Session 1 ends here.

## Phase A-B-E3 quirks (session 2, 2026-07-17)

- ANSI multi-port headers ("input clk, clr"): shared-group typespecs anchor
  at the FIRST port of the group (the one with direction/type tokens).
- ANSI net-port headers ("input wire x"): vpiNetType from the keyword token;
  implicit-dims typespec spans keyword..dims ("wire [31:0]"). Port decls
  with implicit dims ("input [3:0] a") anchor at the dims alone.
- Non-ANSI modules: local declarations BEFORE port nets in Nets vectors
  (ANSI: ports first).
- reg-declared locals stay logic_nets (netType 48); only `logic` locals
  become logic_vars.
- Event lists: comma-separated -> vpiListOp(37); `or` -> vpiEventOrOp(35)
  (AST doesn't keep the separator; peek at source text between events).
- for_stmt: PLURAL VpiForInitStmts/VpiForIncStmts vectors (singular fields
  print elsewhere and fail cmp); loop var = int_var(Signed, no Visibility)
  as init-assignment Lhs; slang's implicit wrapper block is skipped.
- named_begin: loc = block-name token; inner refs use blockpath fullnames.
- indexed_part_select: vpiIndexedPartSelectType 1(+:)/2(-:), Base/Width
  exprs unparented. Lvalue selects span whole expr; rvalue anchor at index.
- repeat: loc = "repeat" keyword; count constant unparented.
- Parameters: untyped -> int_typespec spanning the whole declaration (no
  Signed); typed -> ts at type syntax + Signed on ts AND parameter object.
  Def ts inline (typed: parent=param), top ts deferred until after ports
  (parent=its ref). Rhs literal const carries ts ref w/ module-prefix
  fullname. Top rhs: literal re-emitted size=param width; else folded
  (INT if division/INT-encoded param refs involved, else UINT; size 64).
  Local params: only vpiLocalParam flag, no value/ts.
- sys_func_call: name incl. $, loc = name token only; args don't reparent
  typespecs. Size casts: operation(67) + integer_typespec(INT:<size>, at
  the size literal, unsigned); re-emitted context parents cast ts at ref.
- Packages: VpiFullName "pkg::" (trailing colons), AllPackages+TopPackages
  (top has VpiTop:1), param fullnames pkg::name, package `parameter`
  keyword => NON-local (ignore slang's LRM-correct local marking).
  Module-side refs to package params fold inline to UINT constants at the
  reference's source range. Package typedefs (vpiTypedef list w/ named
  typespecs, unfolded range exprs, refs Actual->param rhs const) NOT yet
  implemented.
- Corpus: r7 21+17, r8 31+9, r9 33+10, r10 33+13, r11 36+22 (PASS+CMP_ONLY).
- r12 36+22, r13 36+33 (PASS+CMP_ONLY = 69 of 661 achievable), UNSUP 349,
  0 crash. Session 2 ends here (phases: harness done; A done; B done except
  paramod-instances; C sys-calls done (user funcs TODO); E3 packages
  params-only. NEXT best levers: (1) weakly-tail ordering polish flips the
  33 CMP_ONLY to PASS; (2) user function calls C2 (~100 tests); (3) enums +
  typedefs D1 (many package/DIFF tests); (4) generate E2 (16+); (5) member
  access D2 (70). Use scripts/triage.sh results-rN.csv for live priorities.

## Session 3: CMP_ONLY polish round 1 (2026-07-17)

- SOLVED the top-view net typespec parent rule (NOTES open question): at
  net creation Surelog always sets ts->VpiParent(net) (elabSignal,
  NetlistElaboration.cpp:2389 etc.); shared decl-group ts ends parented at
  the group's LAST net (mux2 S/B/Y = last-of-each-group). EXCEPTION: any net
  referenced on a top-view cont_assign LHS ends UNPARENTED (LHS elaboration
  re-points the parent at a temp that Save() GC-collects). Variables (not
  nets) keep the old refs-based reparent rule (processRefs/instRefs).
- Re-emitted top-view cont_assign RHS refs bind DEF-view nets, not the
  instance nets (visible only when types differ: unary_op_plus int port ->
  Surelog Actual = logic_net, not int_var). LHS refs bind instance objects.
- cont_assign literal RHS: NOT shared with def; fresh top cont_assign whose
  Rhs REUSES the def's constant object for sized/based literals (Surelog
  expression cache) but is re-emitted fresh for bare decimals. The literal
  constant carries VpiParent = the cont_assign in BOTH views (unlike
  procedural assignment sides, which stay unparented).
- tryFoldConst must strip implicit conversions before the literal check:
  evaluating Conversion(IntegerLiteral) truncates >32-bit values through
  slang's 32-bit unsized-literal type (ConstSizes).
- Direct literal operands of concats: unparented in module-compile context,
  parented when re-elaborated. NESTED constants (bit_select indices etc.)
  keep normal parent rules (constmsk_test vs concat_lhs_signext).
- Statement-context sys calls ($display/$monitor as a statement): loc spans
  the WHOLE call incl. args/parens, and direct literal args get
  VpiParent = the call. Expression-context calls keep name-token-only loc
  and unparented literal args ($signed({1'b0,a}) operands, wreduce_test0).
- break_stmt/continue_stmt: loc = keyword only (no semicolon).
- event_control loc: use the timing-control SYNTAX node range ("@(...)" incl
  both parens) — the +1 heuristic broke on "@( posedge clk )" (dffs).
- Implicit type with signing keyword ("input signed [3:0] x"): ts anchors at
  the signing token ALONE (beats the dims range; signed_ext_case,
  OneArithShift).
- r15: 56 PASS + 13 CMP_ONLY (69 of 661), UNSUP 349, 0 crash. Remaining
  CMP_ONLY: asicworld_serial_crc AssignSumWithParameterInSubmodule
  blocking_temp_ff blocking_temp_select BreakNested
  code_hdl_models_parallel_crc ContinueNested counters_repeat escape_id
  fsm2 IndexedPartSelect MonitorInputPort PartSelect.

## Session 3 round 2: arena-order model (2026-07-17)

The weakly-tail creation-order model, now fully replicated (r17: ALL former
CMP_ONLY are PASS — 69 PASS, 0 CMP_ONLY):

1. Module-compile phase: every def's PARAMETER typespecs (defs name-sorted),
   before any elaboration typespec. (Package params still precede modules.)
2. Per def (filled lazily on first instance reach): local-net objects carry
   a ref_typespec whose ACTUAL is deferred (created in the write phase);
   def cont_assigns, then def processes (module items -> their typespecs:
   for-loop vars, casts), then def-port typespecs (TypespecCache shared per
   declaration).
3. Netlist phase per TOP instance (all tops in order): top nets/vars ts
   (non-ANSI: locals first), children recursively (child ports inline).
4. Write phase per TOP instance (all tops in order, AFTER every top's
   netlist phase): top ports (fresh ts each), then that top tree's deferred
   instance-param typespecs, then deferred def-local-net typespecs (FIFO).
   Implemented as a two-pass over topInstances with pending-vector ranges.

More quirks nailed this round:
- Escaped identifiers: every named object/ref location spans
  name.size() + 6 columns from the backslash (probed: a*, x~, w#3, bc$de!
  all +6 over the name — Surelog measures its internal "\name " + 2).
- cont_assign sharing rule refined: top view re-emits ONLY whole-net-LHS
  assigns (RHS ops or literal); select-LHS assigns stay shared even with
  operation RHS (code_hdl_models_parallel_crc). The CA-LHS net-ts-parent
  clear likewise applies only to whole-net-LHS assigns.
- BreakNested proved def statement typespecs precede def port typespecs;
  MonitorInputPort proved stmt-context sys call args DO reparent var ts.
- r17 = 69 PASS + 0 CMP_ONLY + 0 DUMP_ONLY of 661; UNSUP 349; DIFF 243;
  0 crash. Goldens now 13. Next: C2 user functions (~100 tests), D1 enums.
