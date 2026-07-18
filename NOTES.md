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

## Session 3: C2 user functions/tasks + typespec generalization (2026-07-17)

Function/task shapes (probed add4/doinc goldens):
- function/task in module Task_funcs (def emits; top SHARES objects), loc =
  whole decl syntax; VpiVisibility 1; VpiAutomatic for automatic; Instance
  link to module. Return: variable classed by return type (logic_var/
  int_var/integer_var), FullName = func fullname, NO name, loc = return
  type range; ts anchored likewise. io_decls: name-span loc, direction,
  Typedef ref -> ts at arg type syntax (shared per decl group); BARE
  implicit args ("input x;") get an UNLOCATED ts created at the END of the
  write phase (shared per decl). Body refs bind io_decls; refs to the
  function name bind per-ref write-phase local vars (name+fullname
  func.func, parent = the ref, own unfolded-ranged ts whose parent = the
  ref_typespec) — return-style functions have none of these.
- func_call/task_call: whole-call loc in ALL contexts (unlike sys calls),
  Function/Task link; FUNCTION call args that are refs carry a Typespec ref
  to the formal's ts (task args don't); direct literal args parented at the
  call. Output args arrive as Assignment(lval, EmptyArgument) - unwrap.
  User func_call RHS does NOT force cont_assign re-emission (sys calls do).
- return_stmt: keyword-only loc, expr in VpiCondition.
- Case-item EXPR refs parent at the enclosing scope (constants stay at the
  case_item). Var-ts reparenting in shared processes: only call-arg refs
  and LVALUE refs count (plain rvalue refs don't).
- Intra-assignment delays: delay_control "#1" on the assignment.

Typespec range-expression model (THE big one, probed + C++ attach probe):
- Module-compile-context typespecs keep UNFOLDED range exprs (operation
  tree from syntax; refs name-only): function returns/io_decls, def-view
  LOCAL-net ts (write-phase deferred), and the write-phase DEF-PORT ts.
- Elaboration-context typespecs FOLD param-dim bounds to INT:<val> 64-bit
  constants anchored at the bound's first token: def-view port ts (initial),
  top-view net ts, instance param ts.
- WRITE-PHASE SWAP (C++ probe, counter): the write phase creates a fresh
  UNFOLDED ts and re-points the DEF PORT's ref to it; the TOP PORT inherits
  the def port's original folded object. Top net keeps its own folded ts.
- Write-phase drain order per top: def-local-net ts -> per-ref func locals
  -> instance param ts (parented range bounds) -> bare io ts. Top instances
  and their own params: params still fresh per view; instance param ts of
  the TOP module drain here too (AFTER func locals).
- dump vpiFullName on name-only refs can be DERIVED by uhdm-dump from the
  VpiParent chain — a parented ts makes its range refs print scoped names.
  Don't chase those; check attachments with a C++ probe.

Net collection order rework:
- Nets with explicit declarations (net/data decls AND ANSI headers) sort by
  declaration location; port-decl-only nets append in port-list order.
  Merged ports ("input clock; wire clock;"): net loc = the re-declaration
  name span; port ts anchors at the PORT declaration group's first
  declarator (its dims if present, dims-range only); def low_conn has no
  name and single-level fullname.
- Param values keep based-literal encoding (BIN:001); untyped based-literal
  params gain a loc-less [w-1:0] range on their int_typespec (value-only
  INT constants; parented only in write-phase instances).
- r22 78 PASS; r23 91 PASS + 0 CMP_ONLY (91 of 661), UNSUP 341, DIFF 229,
  0 crash. Goldens 17.

## Session 3: D1 enums/typedefs + E2 generate (2026-07-17)

Enums (probed enum_simple/AnonymousEnum/enum_values goldens):
- typedef enum -> enum_typespec in module Typespecs: name, whole-decl loc
  (incl. semicolon), module parent+Instance, SHARED across views and all
  declarations. Base_typespec ref (fullname mod.alias) -> logic ts at base
  syntax — only when an explicit base type is declared. File-level
  (compilation-unit) typedefs attach to design Typespecs NAME-SORTED with
  design as parent/Instance (cast into the instance field).
- enum_const values: based literal init -> literal encoding + literal size;
  bare-decimal init -> UINT size 64; implicit -> INT at base width (64 if
  no explicit base). No ConstType. Loc = declarator span.
- Anonymous enums: unnamed/unlocated enum_typespec; instance view shares
  per decl-group, parent + base-ref fullname = LAST user; def view gets a
  FRESH unparented one per net (empty base-ref fullname), drained in
  name-sorted def order. Enum vars = enum_var (Visibility 1); refs to enum
  values bind enum_consts; top CA with enum-const RHS re-emits a loc-less
  constant clone; top var initializers appear as vpiExpr refs scoped by
  the var fullname.
- (* attributes *): Surelog keeps only the LAST spec; the attribute object
  is created on the def net and SHARED with the top var. Loc = spec syntax.
- Built-in method calls (e.first) come without '$' from slang and need
  hier_path shapes — flagged unsupported for now.

Generate (probed 4-iter for-generate + gen_test6):
- Instance view ONLY: per unrolled iteration one gen_scope_array + one
  gen_scope (both named g[N], loc = block syntax). Genvar = localparam
  UINT:<iter>, loc = line of the loop with COLUMN 0 and no end, ts ref ->
  unlocated int_typespec created at the END of the write phase. Genvar
  refs in exprs stay UNBOUND (no Actual). Contents use gen-scoped
  fullname prefixes but bind module nets; literal CA RHS constants are
  parented at the cont_assign.
- Def view: only a gen_region placeholder per generate construct with an
  unlocated begin naming the module scope.
- r25 95, r26 95 (+gen DIFF 215->205), r27 96 PASS + 0 CMP_ONLY of 661.
  UNSUP rose to 360 (gen scopes surface inner unsupported constructs
  honestly). Goldens 20.

## Session 3: D2 structs + member access (2026-07-17)

- struct_typespec (typedef): VpiPacked, loc = the struct TYPE syntax (not
  the whole typedef), UNPARENTED but Instance=module; typespec_members:
  name-span loc, ts ref fullname "<alias>.<member>", fresh member ts
  parented at the member, Ref* fields = the member type syntax range.
  Canonical struct fields lose their type-syntax link — recover through
  the StructUnionMember syntax walk. UNPACKED struct typedefs differ:
  module parent + module-scoped ("work@mod.alias.member") member refs.
  A struct typedef referenced from ANOTHER typedef's member is upgraded
  the same way (post-pass). Packed-struct signals = struct_net in the
  instance view (skip both the ts creation-parent and the reparent loop).
- MemberAccess -> hier_path: name = fullname = dotted path; path elems are
  unbound ref_objs. CRITICAL QUIRK: ref_obj::VpiFullName() lazily COMPUTES
  from the parent chain and CACHES — Surelog's elems freeze name-only
  fullnames because the getter ran before parenting. Replicate by calling
  the getter right after VpiName, before VpiParent. Rvalue paths: only the
  LAST member gets the module-scoped fullname; all elems anchor at their
  own token spans. Lvalue paths: no fullnames at all, and the BASE ref
  anchors at the FIRST member's token span.
- r28 96 (UNSUP 360->338), r30 98 PASS + 0 CMP_ONLY of 661, DIFF 225,
  0 crash. Goldens 21.

## Session 3 wrap: vector typedefs WIP (2026-07-17)

- typedef logic [7:0] byte_t decoded so far: module Typespecs holds the
  NAMED main ts (parent+Instance=module, ranges at the target syntax).
  Def-view nets bind a fresh NAMED clone (per net, via bypassTypedefShare
  + the alias target syntax). Instance-view signals bind a LATE named
  wrapper (write phase, Instance set, TypedefAlias ref -> the main ts).
  netTypeFor: NamedType aliases of 4-state vectors/scalars -> vpiNet(36).
- RESOLVED (C++ probe on ids/attachments): the INSTANCE-view signal binds
  a plain NAMED clone built at net-emission time (ranges, no alias, no
  Instance); the DEF net binds the write-phase clone carrying Instance and
  TypedefAlias -> the module typedef ts. probe-vtd converges.
- r34 = 100 PASS + 0 CMP_ONLY of 661; DIFF 258; UNSUP 303; 0 crash;
  goldens 23. Session 3 ends here.

## Session 3 summary (start r14 -> end r34)

36 -> 100 PASS of 661 achievable; CMP_ONLY 33 -> 0; UNSUPPORTED 349 -> 303;
0 crashes throughout; goldens 5 -> 23. Features landed: file split, the
complete arena-order model, C2 functions/tasks, D1 enums/typedefs/attrs,
E2 generate scopes, D2 structs + hier_path member access, C3 immediate
assertions, vector typedefs (WIP). Next levers by triage: E1 hierarchical
refs (56), E4 interface ports (46), D3 assignment patterns (35+25),
select-on-complex-base (35+24), statement List 34, package user functions
(33), B2 parameterized instances, then F --elabuhdm.

## Session 4: small-DIFF mining (2026-07-17, r35->r54)

Rules landed (each probed against goldens):
- unique/priority -> vpiQualifier(1/2) on case/if. Unsized based literals
  ('h1) size -1. (* attrs *) on case stmts anchor the loc at the case
  keyword and attach attribute objects.
- Var initializers: vpiExpr on top vars (literals parented at the var,
  bare decimals sized at the var type width); initialized plain vars span
  declarator..init and the DEF-view ts extends through the init.
- Vars creation-parent their ts exactly like nets (last-of-group,
  CA-LHS clear, typedef/enum/struct ts excluded) — the refs-based var
  reparent rule was an artifact and is gone.
- part_select fullnames FROZEN from the parent chain (doubled under
  bit_select indices). Select scoping: refs nested in index/bound
  OPERATIONS scope by the base name (direct refs stay module-scoped);
  applies to bit_select indices, part_select bounds, ips base/width.
  ips: lvalue whole-span, ConstantSelect from evaluable width;
  part_select ConstantSelect from evaluable bounds.
- Suppress-const-parent applies only to DIRECT literals (concat operands,
  replication counts, ips bounds); nested operation constants keep
  normal parents. Re-emitted part_select bounds get parents.
- Re-emitted size-cast typespecs created at the very END of the write
  phase (pendingCastTs).
- Sys call spans: name-token-only ONLY for $signed/$unsigned; everything
  else whole-call. Function-call arg-ts refs only outside processes.
- Params: value string only for LITERAL inits; typed-param folds size at
  the type width and carry a ts ref to the param typespec.
- External-var for loops: plural init/inc vectors; init assignment has
  no opType/blocking and an UNBOUND ref_var Lhs.
- bind: def view skips bound instances; the bound instance displays as
  work@<top>.<name> (VpiName/FullName) while content keeps real paths;
  high conns emit TOP-scoped names but bind parent nets; the instance's
  re-emitted content (CAs/processes) binds DEF nets.
- r54 = 120 PASS + 1 CMP_ONLY (BindModuleWithInputPorts, 4-line ts
  position) of 661; DIFF 237; UNSUP 303; 0 crash.

## Session 4 continued (r54->r60)

- Non-ANSI port net headers ("input wire signed x;") reuse the
  ansiNetHeader rule via PortDeclaration walk: keyword ts anchor,
  netType, and keyword-anchored ts DROP the Signed flag.
- $bits calls fold to UINT:64 constants everywhere; as a DIRECT CA RHS
  they behave like literals (def parented fold at the call span; top
  re-emit sized at the LHS width, def-bound LHS).
- Cast sizes: parenthesized exprs anchor at the inner expr; non-literal
  sizes bind fresh via Expression::bind(currentScope) and produce an
  integer_typespec with the expr as vpiExpr (parented at the ts in the
  drain, at the cast op inline; name-only call spans via inCastSize).
  Re-emitted contexts DEFER these to the end of the write phase
  (pendingCastTs extended with the bound expr).
- Folded range bounds anchor at the top operator's LEFT operand span
  ((M+N)-1 -> "M+N"), not the first token.
- r60 = 134 PASS + 2 CMP_ONLY (BindModuleWithInputPorts 4-line ts
  position; case_expr_query 26-line nested-case locs) of 661; DIFF 208;
  UNSUP 317; 0 crash.

## Session 4: E1 hierarchical refs + sharing/ordering corrections (2026-07-17)

- HierarchicalValue (u1.cnt) -> hier_path with the member-access shape:
  elements from the dotted source text at their own token spans, frozen
  name-only fullnames, last rvalue element gets the module-scoped
  fullname. Same lvalue rules as member access.
- ALL instances (children too) SHARE the def's process objects — the
  "re-emitted per child" belief was never validated for processes (child
  tests with always blocks were all still blocked). Child cont_assigns
  now share like tops (fold/literal/whole-net-LHS rules unchanged).
- Def-local net typespec deferral refined again: the WRITE phase walks
  defs NAME-SORTED; a top def writes its ports + deferred typespecs
  (emitTopPorts), a non-top def materializes just its local-net
  typespecs at its sort position (probe-hier2: sub's local ts before
  top's write-phase port clones; AnonymousEnum: dut's after d2's netlist
  objects).
- r68 = 138 PASS + 1 CMP_ONLY (BindModuleWithInputPorts) of 661;
  UNSUP 277; DIFF 245; 0 crash.

## Session 4: D3 assignment patterns + GC-off discovery (2026-07-17)

- '{...} -> operation vpiAssignmentPatternOp(75). Def view structured
  patterns wrap members in tagged_pattern (loc = value span, value parents
  at the OPERATION, Typespec ref fullname = module prefix -> a
  string_typespec named by the tag at the key token, parented at the
  tagged_pattern). Simple patterns are plain operand lists.
- Instance view re-emits patterns (containsOperation true): tags DROPPED
  (raw values as operands), FIRST operand carries VpiSize = its width.
- The recompile abandons an ORPHAN first-compile op: opType 75, parent =
  the DEF cont_assign, Typespec ref -> the pattern's typedef ts, operands
  = the DEF op's VALUES (tagged_patterns unwrapped) RE-PARENTED at the
  orphan. Created at the very END of the write phase.
- CRITICAL: Surelog writes with Serializer GC DISABLED (SetGCEnabled from
  the -gc CLI flag, default off) — stale compile artifacts like the
  orphan survive in the file. slang-uhdm now also saves with GC off.
  An object appears in the dump's weaklyReferenced tail ONLY if some
  visited object shallow-references it (e.g. via a vpiParent print) —
  wholly unreferenced objects are IN the file but INVISIBLE to uhdm-dump
  (use Serializer::ObjectStats in a C++ probe to count them).
- r69 = 138 PASS; UNSUP 277->252 (patterns unblocked into DIFF 270).

## Function-scope parameters (r72)
- Function-level `localparam` → function Parameters/Param_assigns like module
  params, EXCEPT: value+typespec emitted even though vpiLocalParam:1, and the
  parameter's vpiParent is its param_assign (not the function).
- Arena order inside a function: return ts, io ts, param ts, block var ts.
- Block-scoped localparams (inside named begin) → inline param_assign STMTS:
  bare parameter (LocalParam, declarator span, no value/ts), Rhs = folded
  unparented constant (UINT/size 64/type 9, loc = init span), no typespecs.
- Surelog CANNOT resolve refs to block-scoped localparams: it mints an
  implicit module-level wire (vpiNetType:1, loc = FIRST ref span, fullname
  <module>.<name>) appended to the def-view Nets; refs bind that net. Top
  view does not re-list the implicit net.
- Param-init user func_call: name-token-only span. Top view does NOT fold
  initializers containing user calls (keeps the func_call). In param context
  a top-view constant arg carries ref_typespec fullname=<module> → formal's
  io typespec; def view (shell, argTs empty) has no arg ts.
- Calls seen before the def fill (param inits) get a shell task_func created
  at the call site; emitTaskFuncs reuses it (subMap hit) and fills it.

## Package functions + function body lists (r73)
- Package task_funcs: emitted in BOTH package views (def + top copies, own ts
  objects each); call sites bind the def copy (subMap keep-first). Fullname
  separators are :: all the way down (my_pkg::incr::x), including body refs
  (joinRef helper: prefix containing :: joins with ::).
- Package-context return/io typespecs carry vpiInstance -> the package.
- Io arg ts with explicit keyword+dims anchors at the KEYWORD token only
  (logic [7:0] x -> ts loc = "logic"); return ts keeps the whole span.
- Arena: BOTH package views build before any module (top packages moved up).
- Packages listed in SOURCE order (slang name-sorts; stable_sort by location).
- Qualified pkg calls: vpiName "pkg::fn", span = package-name token only.
  Unqualified imported calls: plain name, name-token span.
- Top-view CA whose RHS is an argument-less user call returning a literal:
  re-emitted with the call FOLDED to that literal (literal's own loc/shape).
- Function body bare stmt lists with >= 2 effective stmts (decl inits count):
  unnamed begin wrapper (fullname = scope, loc = first..last real stmt).
  Initialized locals: name-span loc, NO automatic flag, re-parented at their
  init assignment (op 82, blocking, declarator span, Lhs = the var object,
  literal Rhs unparented / ref Rhs parented); vars listed in BOTH function
  and begin Variables.
- Package import (import pkg::fn) DEEP-CLONES the function into the importing
  package with half-reprefixed names - NOT implemented yet (ImportFunction).

## Const function folds + call arg typespecs (r74)
- Top-view CA with user-call RHS:
  - argless call reducing (straight-line, first-return-wins, nested calls
    followed, name-assignments accumulate) to a LITERAL: re-emit with the
    literal's own shape and loc (constCallLiteral).
  - call WITH args that tryEval's: re-emit with a LOC-LESS constant shaped by
    the result type (signed -> INT:/vpiIntConst, size = type width).
  - both re-emits bind BOTH sides to def-view objects (Lhs = def net, even
    when the top signal is a variable).
- Top PACKAGE copies also fold constant calls inside return stmts (same
  literal rule); def copies keep the call.
- Call arg formal-ts refs: attach when formal ts is known (shell -> unknown
  mirrors Surelog compile order), for ref/constant/func_call args. Refs name
  themselves; constants and calls name the enclosing scope. In function
  BODIES: def emission never attaches, top package re-emission attaches at
  ALL call depths; outside bodies only the outermost call's args get them.
- Unqualified (imported) pkg calls keep the normal whole-expr span; qualified
  ones anchor at the package-name token.
- Recursive calls: subMap registered BEFORE body emission (else a stray
  name-only shell function leaks into the arena - fib tests).
- Begin wrapper loc = LAST real stmt's span. Package funcret locals drain at
  the START of emitTopPorts (before the write-phase port ts).

## Imports, param-backed folds, positional conns (r75)
- Module with imports: each import item -> import_typespec in module Typespecs
  (name = package, loc = the import item span) carrying a DUMP-INVISIBLE Item
  constant {STRING:<name-or-*>, decompile, size = len*8, ConstType 8, no
  parent, loc = name token for explicit imports, loc-less for wildcard}.
  Import-called (unqualified) package functions are listed (shared def
  objects) in the module's Task_funcs. Both views.
- Package-param-backed call folds (return PARAM chains):
  - def pkg body: ref_obj bound to the param's def Rhs constant.
  - top pkg copy: constant at the REF site, size = param width, UINT, parent
    = def param_assign, ts ref fullname = package name -> param-ts CLONE
    (Instance = def package) that Surelog creates during the DEF compile.
    Chained functions REUSE the same constant object (foldedRet cache).
  - top module CA: fresh constant (ref-site loc, param width, UINT, parent =
    ca), ts ref fullname = module prefix -> ANOTHER clone created at the very
    END of the write phase (pendingParamCloneTs, after cast ts).
- Package param typespecs carry vpiInstance -> the package (both views).
- Package fn locals: name-span loc, NO automatic, re-parented at the begin
  wrapper (uninit) or init assignment; body ts (for vars, block vars) carry
  vpiInstance. Module fn locals keep type-span + automatic.
- Begin wrapper loc = the SECOND source item's span (decls count as items).
- Bare (directionless) formal ts anchors at the type keyword only; formals
  with a direction keyword keep the whole type span.
- Positional instance conns: nameless port anchored at the actual, high-conn
  ref fullname skips the port segment, top low_conn anchored at the actual.
- Arg formal-ts refs extend to bit/part/indexed selects (own fullname).
- ref_var/for-var/bit_select/indexed_part_select fullnames in package scopes
  join with :: (joinRef).

## Gen-scope functions + def-view gen_if_else (r76)
- Functions declared in generate blocks: TOP-view gen_scope carries them in
  its Task_funcs (dot-separated fullnames, NO vpiInstance). gen_scope is a
  UHDM scope, NOT an instance (emitTaskFuncs dispatches the attach).
- DEF-view if-generates: gen_if_else (no loc) {Condition = unfolded syntax
  expr (module-prefixed unbound refs), Stmt/ElseStmt = branch bodies emitted
  from SYNTAX: labeled -> named_begin (no loc), bare/unlabeled -> anonymous
  begin (module fullname); cont_assigns with unbound refs; calls emitted
  name-only and UNLINKED (no vpiFunction)}. For-generates keep the empty
  gen_region placeholder.
- Def-view calls to gen-scoped functions: name-only unlinked func_call (the
  function object exists only in the top view).
- Top gen-scope CAs: constant user calls fold like module CAs (source
  literal, sized at LHS width). WHOLE-NET gen CA LHS strips the signal's ts
  parent (select LHS keeps it) - same rule as module CAs.
- emitSyntaxExpr gained comparison/logical/bitwise binary ops and name-only
  InvocationExpression.

## Design-level ($unit) functions (r77)
- Compilation-unit functions attach to the DESIGN object's Task_funcs: bare
  name as fullname, vpiMethod:1, no vpiInstance, emitted once (before any
  module), normal linked call sites.

## Type casts (r78)
- TYPE casts (logic', int', struct'...) map to vpiCastOp with the
  target-type typespec (int -> int_typespec signed, else logic_typespec) at
  the type-syntax span. Def view creates it inline; RE-EMITTED (top) casts
  defer creation to the very end of the write phase (pendingCastTs gained a
  castType variant), like size-cast integer_typespecs.
- Top view NEVER folds type casts (keeps the op); SIZE casts still fold.

## B2 core: parameter overrides (r79)
- Override detection: the bound initializer's SYNTAX pointer differs from
  the declaration-default initializer syntax (paramDefaultSyn /
  isOverriddenParam in EmitHelpers).
- BOTH views keep DEFAULT-derived param values (value string, wantTs); the
  def-view param_assign Rhs is ALWAYS the default (bind the default syntax
  in the def scope when overridden).
- Instance-view param_assign: vpiOverriden:1; Rhs = folded override constant
  {literal override -> base-encoded raw (DEC:7_200 keeps underscores) at the
  OVERRIDE site; expression override -> UINT digits at the DEFAULT-init
  site}, size = folded width, ts ref (instance path) patched to the shared
  param ts (pendingParamTs rhsRt).
- Child CAs whose RHS refs an overridden param: instance-view re-emit with a
  folded UINT constant at the DEFAULT-init site, ts ref -> FRESH param-ts
  clone at the very end of the write phase (pendingParamCloneTs), Lhs bound
  to def nets.

## B2 refinements (r80)
- Override detection falls back to source-range comparison (bound init range
  vs declaration-default range) when syntax pointers don't differ.
- Instance override Rhs: ALWAYS anchored at the DEFAULT initializer's site.
  Typed -> UINT digits/type 9/width/ts-ref; untyped -> INT digits/type 7/
  size -1/no ts. (No base-encoding of the override literal.)
- Unknown ('x/'z) defaults: param value BIN:<UPPERCASE digits>, wantTs
  false; the def Rhs constant uppercases its BIN value/decompile and carries
  a BARE never-patched ts ref (fullname only, no actual).
- Child-instance CA re-emission FOLDS type casts (loc-less typed constant);
  only TOP-module CAs keep the cast op (foldTypeCasts flag).
- Def-view type-cast typespecs are MODULE-COMPILE artifacts: pre-created for
  all defs (name-sorted) right after the def param pre-pass, before any
  def fill (castTsCache keyed by cast-type syntax).

## Def content pre-pass (r81) - ARCHITECTURE CHANGE
- Surelog compiles EVERY def's content before elaborating any instance:
  typedefs, net objects, task_funcs, cont_assigns (incl. their cast ts),
  processes, generate placeholders all precede the first top module's ts.
  Only the PORT phase (emitPorts, ref_modules, imports - emitModuleDefPorts)
  is encounter-ordered. exportDesign now runs emitModuleDef (content) for
  all defs name-sorted right after the def-param pre-pass; emitInstance
  runs the port phase on first encounter. (Evidence: FWOP/PWUV child fn &
  cast ts before top's def ts; fib both-tops pattern.) The r80 castTsCache
  pre-scan became redundant (kept as harmless cache).
- Child instance views ALSO list def task_funcs (isTop gate removed).
- Function-local var typespecs keep UNFOLDED range bounds (tfContext),
  refs BARE (name only, no fullname).

## Unpacked arrays + var_select (decoded from func_local_array golden, WIP)
- Unpacked-array function local `reg [3:0] state[4]`:
  array_var {loc=name span, vpiArrayType:1, ts ref -> array_typespec
  (loc = name..dim span 7:15-7:22), vpiReg: inner logic_var (same name-span
  loc, ts ref (fullname = the array's) -> logic_typespec of the ELEMENT
  type span `reg [3:0]` 7:5-7:14)}. Listed in function/begin Variables.
- Single element select state[i] -> plain bit_select (name=state) even on
  unpacked arrays.
- NESTED selects state[i][j] -> var_select {name/fullname of the base,
  loc = whole select span, MULTIPLE vpiIndex entries left-to-right; each
  index ref fullname = <base fullname>.<ref name> (selectBasePrefix quirk),
  Actual bound normally}.
- TODO: array_typespec construction (makeTypespec), array_var in
  TaskFuncEmit/StmtEmit var paths, var_select flattening in ExprEmit
  ElementSelect when base is itself a select.

## var_select indices + concat var inits (r83)
- var_select index expressions parent at the var_select (forceConstParent
  around index emission); index refs already parent normally.
- Top-var concatenation initializers ({a,b}) emit as vpiExpr (concat op,
  self-parenting at the var); operands stay UNparented (don't force-parent
  concat inits, only bare literals).

## array_var for unpacked-array signals (r84)
- Module-level unpacked array (logic a[1:0][2:0]): INSTANCE view emits an
  array_var (loc=name span) {vpiSize=product of dim widths, vpiRandType:1,
  vpiVisibility:1, vpiArrayType:1, ts ref -> array_typespec (NO loc/children),
  one Range per unpacked dim (bounds = ConstantRange UINT consts parented at
  the range, loc from the declarator dimension syntax + left/right expr
  spans), Variables = one inner logic_var (the "vpiReg", loc=name span) whose
  ts ref -> the ELEMENT logic_typespec (element-only span), and the element
  ts parents at the INNER LOGIC_VAR (not its ref).
- DEF view keeps `a` as a plain logic_net; its typespec span reaches the END
  OF THE FIRST unpacked dimension (element-span + first dim close), not the
  whole decl (materializeDefNetTs extends VpiEndLine/Col).
- emitArrayVar (TypeEmit) reuses the shared net ts as the element ts.

## Unpacked arrays: element types + pattern inits (r85)
- makeTypespec unwraps FixedSizeUnpackedArrayType to the LEAF element type
  for the typespec class (int n[...] -> int_typespec, loc = type syntax).
- array_var: vpiSigned when the leaf element is signed; inner reg is typed by
  the leaf element (int_var/integer_var/logic_var).
- Array-pattern initializer ('{'{0,1,2},'{4,4,4}}): emitted as an
  assignment-pattern op tree (opType 75, nested one level per dim) attached
  as vpiExpr to BOTH the array_var and the inner reg, PARENTED at the inner
  reg. Nested pattern OPERATIONS self-parent, but leaf constants stay
  UNPARENTED (suppressConstParent around the emit).
- Def-view unpacked-array net ts keeps its first-dim span even when the decl
  has an initializer (the init-extension is skipped for unpacked arrays).

## Unpacked-array function args (r86)
- Unpacked-array formals (int arg[1:0][0:0]): the io_decl carries one vpiRange
  per unpacked dimension (buildUnpackedRanges helper, shared with array_var),
  in addition to the element typespec.

## Range/part select of element select + '1 var inits (r87)
- x[0][1:0] (range select of an element select) flattens to a var_select
  whose leading indices are the element selectors (const/ref, force-parented)
  and whose FINAL index is a part_select (Simple) or indexed_part_select
  (+:/-:). The final select: name/defName = base sym, fullname = base
  fullname + "." + name (doubled), vpiConstantSelect when evaluable, loc =
  left-bound-start .. right-bound-end, bound constants UNPARENTED.
- Unbased-unsized ('1/'0) var initializers fold to a UINT constant at the var
  width (parented at the var, loc = literal span).
- TODO: unpacked-array PORTS want array_net (not array_var) + array_typespec
  port ts (AssignArraySelPlus). Currently emits array_var -> CMP_ONLY.

## Multi-dim packed nets + nested-select parenting (r88)
- Multi-dim PACKED-array DEF nets truncate the typespec span to the first
  dim end (materializeDefNetTs); the TOP net keeps the whole-type span.
- var_select element indices force-parent ONLY when the index is a literal
  (isLiteralExpr per index); a part_select/select index keeps its own bound
  rules (its bound constants stay unparented).

## Range select of member access (r89)
- a.b[0+:8] (range select of member access) -> hier_path {name/fullname =
  dotted text incl. [sel], elems = base ref_obj + intermediate member
  ref_objs + a final (indexed_)part_select for the range}. The final elem:
  name = member, loc = member-name-start .. selector-close, vpiConstantSelect
  when evaluable, IndexedPartSelectType for +:/-:. Unblocks the
  IndexedPartSelectOf* tests (most still need anonymous packed struct
  support to fully converge).

## Predefined integer types (r90)
- makeTypespec + makeVar now handle ShortInt/LongInt/Byte/Time (was only
  Int/Integer): short_int/long_int/byte/time _typespec and _var. Signed
  types set VpiSigned on both ts and var (via the variables base accessor);
  time is unsigned. Unblocks Shortint, Longint (+ partial int_types/ports).

## While/do-while/forever loops (r91)
- while_stmt (keyword-span loc, 5 chars), do_while (2 chars), forever_stmt
  (7 chars). Condition + body; the condition follows normal const-parenting
  (direct constant condition unparented, operation-operand constants
  parented -> do NOT suppressConstParent the condition).

## Assignment-pattern default/index setters (r92)
- StructuredAssignmentPattern now emits defaultSetter and indexSetters (was
  rejected). default: -> tagged_pattern with string_typespec named "default"
  at the keyword span; index (N:v) -> string_typespec named by the index
  source text at the index span. Values suppress const-parenting.
- REMAINING for full pattern convergence (PatternDefault etc.): the top-view
  CA FOLD of a pattern to a based constant (decompile "8'd255", implicit
  constType) and the def tagged_pattern value parenting under the
  pattern-orphan re-parent machinery. Setter tags alone move these tests
  UNSUPPORTED -> DIFF.

## Pattern fold to based constant (r93)
- Top-view CA with an assignment-pattern RHS that evaluates to a constant
  folds to a BASED-DECIMAL constant: decompile "<w>'d<digits>", size = LHS
  width, value UINT, NO constType (VpiConstType(0) so the dumper omits it),
  loc = pattern span.
- A pattern that FOLDS leaves NO orphan first-compile op (orphan only when
  the top RE-EMITS the pattern). Guard: skip pendingPatternOrphans when the
  top rhs is a constant. (PatternDefault now fully converges; PatternIndexes/
  array/union patterns still need more - index/array fold shapes.)

## Numeric index pattern tags (r94)
- Numeric index setters (N:v) use an INTEGER_TYPESPEC tag (INT:<value>, loc =
  index span, UNPARENTED) - only default: uses a string_typespec. Both feed
  the tagged_pattern's ref_typespec. PatternIndexes converges.

## Concurrent assertions (r95)
- Module-level `label: assert property(@(posedge clk) ...)` is a
  ProceduralBlock (kind Always) with syntax ConcurrentAssertionMember, body a
  Block whose blockSymbol->name = the label, inner stmt = ConcurrentAssertion.
- Surelog's FOLDED pre-elab form is minimal: assert_stmt {VpiName/FullName =
  label, loc = assertion stmt span, Stmt = the else action (ifFalse), Property
  = property_spec}. The property_spec keeps ONLY the clocking event as
  VpiPropertyExpr (a posedge operation, opType 39) - the disable-iff/sequence
  /implication body is DROPPED.
- Attaches via instance-base Assertions() (VectorOfany, dumps as vpiAssertion)
  NOT scope-base Concurrent_assertions() (vpiConcurrentAssertions). Emitted in
  the def process loop (after nets); ALL instances SHARE the def assertion
  objects like processes (DefInfo.assertions).
- Only AssertionKind::Assert -> assert_stmt so far.

## Concurrent assertion property-expr rule (r95 investigation, for next session)
The FOLDED property_spec content depends on kind + whether a clocking event
is present:
- ASSERT with @(clocking): VpiPropertyExpr = the clocking operation ONLY
  (posedge=opType 39); the sequence/implication/disable-iff body is DROPPED.
  (sva_basic00, sva_basic01 - DONE.)
- ASSERT without clocking: VpiPropertyExpr = the full property expression
  (operations). (sva_range assert.)
- ASSUME (assume obj) with clocking: VpiClockingEvent = the clocking op AND
  VpiPropertyExpr = the full property body. (sva_not/sva_range assumes.)
- ASSUME without clocking: VpiPropertyExpr = the body.
So: emit clocking-only ONLY for `assert` WITH a clocking event; otherwise
emit VpiClockingEvent (if clocked) + a full property-expr tree.
NEXT: a recursive emitAssertionExpr(AssertionExpr) -> operation. slang enums:
  UnaryAssertionOperator, BinaryAssertionOperator {And,Or,Intersect,
  Throughout,Within,Iff,Until,SUntil,UntilWith,SUntilWith,Implies,
  OverlappedImplication(|->),NonOverlappedImplication(|=>),
  OverlappedFollowedBy(#-#),NonOverlappedFollowedBy(#=#)}.
  AssertionExprKind {Simple(->emitExpr(.expr)),SequenceConcat(## delay),
  SequenceWithMatch,Unary,Binary,FirstMatch,Clocking(.clocking/.expr),
  StrongWeak,Abort,Conditional,Case,DisableIff(.condition/.expr)}.
  vpi opTypes: 51 NonOverlapImply(|=>), 52 OverlapImply(|->), 53
  UnaryCycleDelay(##), 54 CycleDelay, 60 ConsecutiveRepeat([*]), 90 Always,
  91 Eventually, 92 Until, 93 UntilWith, 94 Implies. Spans from ae.syntax->
  sourceRange(); operand parenting per golden (iterate each test).
- assume/cover/restrict/expect map to Make{Assume,Cover,Restrict,
  Expect_stmt}() (all extend concurrent_assertions: VpiName/FullName/Stmt/
  VpiProperty). Unlabeled asserts: fullname = module prefix, no VpiName.
- sva_basic02 (CMP_ONLY) = assertions in a BOUND module (bind interaction).

## Property-expression emitter + default clocking (r96)
- emitAssertionExpr: Simple -> emitExpr(.expr); Binary/Unary -> operation with
  mapped op (mapAssertBinOp/mapAssertUnaryOp: |->=52, |=>=51, implies=94,
  until=92, until_with=93, intersect=55, throughout=57, within=58, iff=68,
  followed_by=87/88, and/or=79/80; nexttime=89, always=90, eventually=91),
  operands = recursive emitAssertionExpr, parented at the op, loc from
  ae.syntax->sourceRange(). Clocking -> recurse .expr.
- property_spec loc = the WHOLE propertySpec syntax (incl. clocking), NOT the
  unwrapped inner expr. assert-WITH-clocking still keeps clocking-only
  PropertyExpr; otherwise ClockingEvent (if clocked) + full PropertyExpr.
- assertionKind -> Make{Assert_stmt,Assume,Cover,Restrict}. Unlabeled: no
  VpiName, VpiFullName = module prefix.
- `default clocking @(posedge clk); endclocking` -> clocking_block
  {VpiName=blockName or "unnamed_clocking_block", loc = decl span,
  Clocking_event = event_control (loc = @..event span) whose VpiCondition =
  the posedge op}. Set as module Default_clocking. NOT shared across views -
  emitDefaultClocking runs fresh in BOTH def and top (unlike processes/
  assertions which share).
- Converged: sva_basic00/01/03, sva_value_change_rose. Remaining sva tests
  need more forms ($rose/$past sampling, ## delays, repetition, disable iff
  in assumes, cover).

## Sequence concat (##) + throughout parenting (r97)
- SequenceConcat (a ##N b ##M c) -> operation(vpiCycleDelayOp 54), operands
  [a, N, b, M, c]: delay constants (UINT, loc = "##N" span = delayRange
  extended 2 chars left) BETWEEN elements. Op span = first-elem-start ..
  last-elem-end (strips enclosing parens), NOT ae.syntax.
- `throughout` (op 57): its LEFT operand keeps the GRANDPARENT as vpiParent
  (Surelog builds it in the enclosing context) - pass `parent` not `op`.
  Other binary ops parent both operands at themselves.
- Converged: sva_throughout, sva_value_change_rose (+ earlier basics).

## Property not + typed localparams (r98)
- Property `not` -> operation opType 15 (Surelog's encoding, NOT vpiNotOp 3);
  unary, one operand. (sva_not converges.)
- Explicitly-TYPED localparams (localparam integer/int/byte X = ...) get a
  value + typespec like non-local params (gate: !isLocal || funcScope ||
  typedParam). makeParamTs picks the typespec CLASS from the integer kind
  (integer->integer_typespec, shortint/longint/byte/time -> their _typespec,
  else int_typespec); ranges only on the int_typespec (untyped) path.

## Net-declaration assignments (r99 - landed)
- `wire x = expr;` -> a cont_assign {vpiNetDeclAssign:1, loc = net-name span,
  Rhs = the init constant ('x/'z uppercase to BIN:X size -1), Lhs = the net
  object (net STAYS parented at the module, NOT the cont_assign)}. Emitted
  BEFORE the explicit continuous assigns in Cont_assigns. Only for NET-kind
  syms with initializers (not vars).
- CAUTION: the net-keyword net (`wire x`) keeps its net-keyword ts span (no
  init-extension), but a NAIVE removal of the materializeDefNetTs init-
  extension regressed 11 PASS->CMP_ONLY (other initialized decls DO extend).
  The extension must be skipped ONLY for explicit-net-keyword (netKeyword
  anchored) nets, not all initialized nets. Reverted; needs the narrower
  condition. Blocks sva_value_change_changed(_wide) and likely other
  `wire x = ...` tests.

## Net-decl-assign landed (r99)
- Emitted in the TOP view only (topView guard), before explicit cont_assigns.
- ts-extension skip: hasExplicitNetKeyword() (wire/tri body nets keep the
  net-keyword span; implicit initialized decls still extend).
- Lhs is a FRESH logic_net (parent = cont_assign, own ref_typespec ->
  makeTypespec) - Surelog does NOT reuse the module-list net object.
- REMAINING for full PASS (currently CMP_ONLY): the Lhs's fresh logic_typespec
  must be created LAST in the arena (it prints at the very end of the
  weakly-referenced tail). Today it's created during emitContAssigns (too
  early). DEFER it to the end of the write phase (like pendingCastTs) to
  match the tail order. Affects sva_value_change_changed(_wide) + 1.
