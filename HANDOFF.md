# HANDOFF — slang-uhdm convergence campaign (r171 state)

## Small-DIFF pickoff r106-r109 (2026-07-19)

PASS 263->267, CMP_ONLY 17->18, all merged to main, zero regressions (goldens
23/23 + full corpus + manual PASS->CMP_ONLY demotion check each commit).
- r106 UnsizedConstantsParameterParsing PASS: elab-view unbased-unsized 'x/'z
  param default decompiles 'bX/'bZ (def view keeps bare 'X). ParamEmit.cpp.
- r107 BitsCallOnType PASS: fold $bits/$size/$clog2 type-query bounds to a
  constant ONLY inside a named typedef typespec (typedefTsContext flag); a
  variable's inline type keeps the sys_func_call. TypeEmit emitSyntaxExpr.
- r108 func_output_arg PASS: whole-ref -> select-object Actual binding. Rule
  (derived across corpus, base-type gated): bit-select write re-points only if
  base is io_decl; indexed-part-select write only if base is logic_net; simple
  part-select never; local logic_var never. Per-body track+backpatch
  (beginSelTrack/endSelTrack around process + function bodies).
- r109 multiple_blocking PASS: signed power (2**n) -> INT const; a param
  int-encoded from one propagates so net range bounds ([DINW:0]) emit INT.
  isIntEncoded Power case + emitBound binds bound syntax to check isIntEncoded.

**Near-DIFF triage (remaining, each now multi-issue / bespoke Surelog quirk):**
- sign_part_assign (10): signed based-literal (1'sb1) needs a signed
  int_typespec ref + weakly-tail int_typespec. Separate feature.
- unbased_unsized (26): ABANDONED — Surelog inconsistently uppercases 1'bx->
  1'bX but keeps 1'bz, 3'bxxx, 3'bzzz lowercase (x-only, 1-bit-only). Not a
  sane rule; global uppercase regresses (34 lines).
- Clog2OfSum.. / PatternAsFunctionArgument / BitsCallOnExpression / CastToSum..
  / CastInFunctionToParameterWidth: "missing int_typespec/ref_typespec on an
  expression (operation / $clog2 / cast)" cluster — Surelog attaches the
  assignment target's typespec to certain folded expressions. Clog2 ALSO has
  a port-LowConn int_var-vs-logic_net binding diff (3 issues).
- StructMemberAsModuleInput (19): hier_path inner-ref fullname should scope
  through the port-connection path (work@top.d.o.ping_p, not work@top.ping_p),
  plus a missing struct_typespec ref + struct_net vpiExpr. 3 issues.
- ImportParametrizedTypeAndDeclareParamWithTheSameName (10): package/module
  param structural mismatch.
Debugging aids still in scratchpad (finder/f2..f15, build cmd in the modport
section below).

## Modport tail-dup convergence (2026-07-18, branch `iface-modport-tail`)

iface_modport DIFF->CMP_ONLY (cmp now passes; 26-line dump diff is pure
weakly-tail typespec ORDERING, tolerated). CMP_ONLY 17->18, no regressions.
Decoded the full Surelog interface_inst reference topology:

- Two interface_inst STYLES per interface:
  - **Declaration-style (home)** e.g. `work@top.bus` @decl-line:col (25:5):
    HAS Instance/DefFile/DefLineNo; modport io_decl has NO vpiExpr; modport
    Interface_inst self-refs; loc shows endln.
  - **Reference-style** e.g. m0 port view `work@top.m0.bus` @instantiation
    line, col 0 (27:0) AND the home's col-0 **tail duplicate** `work@top.bus`
    (25:0): OMIT Instance/DefFile/DefLineNo; modport io_decl HAS vpiExpr;
    modport Interface_inst self-refs; NO endln. The tail dup SHARES the home
    view's variable objects (shown shallow in the dump) and is referenced only
    weakly (from the receiving module port's HighConn ref_obj) -> lands in the
    weaklyReferenced tail.
- A receiving module port's **Low_conn** ref_obj.Actual must point at the PORT
  VIEW's own modport (io_decl exprs + Interface_inst back-ptr), NOT the shared
  def modport. Repointed in the portIfaces loop after the port view is built.
- HighConn ref_obj.Actual -> the col-0 tail dup (ifaceTailDup map), not the
  home view. LowConn ref_obj loc = connection site, not port decl.

**Semantically redundant (future `--no-surelog-tail-dups` switch, default
OFF):** the col-0 tail duplicate (`makeIfaceRefDup` + the HighConn redirect to
it) carries zero semantic info beyond the home view — it exists only to match
Surelog's folded-UHDM dumper byte-for-byte. The modport `vpiExpr` on io_decls
and the modport `Interface_inst` self-ref are likewise dump-fidelity only
(the direction + name already fully specify the modport port). A switch can
skip makeIfaceRefDup, the ifaceTailDup HighConn redirect, and the io_decl
Expr / modport Interface_inst wiring without changing semantics.

Debugging aids (scratchpad): finder/f2..f15 — small UHDM-linked programs that
load two .uhdm files, run per-subobject `Compare`, and localize the first
mismatched scalar/vector (uhdm-cmp only reports the leaf pair, not the path).
Build: `g++ -std=c++17 -I$UHDM/include -I$UHDM/build/generated f.cpp
$UHDM/build/lib/libuhdm.a <capnp .a's> /usr/lib64/libz.so.1`. f8/f11/f12
bisect a module's/design's collections; f13-f15 dump nets+ref_modules.

**BLOCKED — iface_modport_out/conn/passthrough (still DIFF/CMP_FAIL).** Root
cause is the parent DEF view's connection-site NET + child-module ref_module,
which Surelog emits by an OPAQUE rule that does NOT reduce to any of: "parent
drives interface", net-present<=>refmod-present, or interface arity. Measured
golden top-def state (net = interface-named wire in parent; refmod = child
MODULE ref_module):
  - iface_modport:      net YES, module-refmod YES  (top drives bus.in)
  - iface_modport_out:  net NO,  module-refmod NO   (top reads bus.out only)
  - iface_modport_conn: net NO,  module-refmod YES  (top reads s.cnt only)
  - passthrough:        net YES, module-refmod YES  (top neither reads nor
                        writes bus — only forwards it to u_mid)
No single predicate fits all four; passthrough breaks "drives", conn breaks
net<=>refmod. Mine currently emits BOTH net+refmod unconditionally (correct
for modport/passthrough, wrong for out/conn). Do NOT gate these without a
rule validated across ALL interface tests — a wrong gate regresses the ones
that pass. Next: instrument what REFERENCES the connection-site net/refmod in
each golden (holders) to reverse the actual trigger, or defer as low-value.

## Session r166-r173 + interface feature (2026-07-18, this session)

PASS 256->263, DIFF 299->306, CMP_ONLY 8->17, UNSUP 98->75. All clean
(no regressions). Interface feature: simple+ported interface_inst (1 PASS +
8 CMP_ONLY), then the MODPORT feature EMISSION (23 tests UNSUP->DIFF) +
partial convergence (elab InterfacePort HighConn->interface_inst; a bare
logic_net per interface port). Modport DIFF->CMP_ONLY is now a large per-test
phase - fixes are small and TEST-SPECIFIC (e.g. suppressing the child def
ref_module helped iface_modport_out -35 but hurt iface_modport/passthrough,
so NOT a universal rule). See the MODPORT FEATURE + INTERFACE FEATURE
sections for status + remaining work. (r173)
Unbased-unsized param values handle 'x/'z (fixed a latent r172 BIN:1 bug);
elab RHS is value-dependent ('1 -> UINT all-ones). Next interface lever:
template emitPorts/emitContAssigns/emitProcess on the instance type to
support ported interfaces (InterfaceAssign/Initial/Always/WithPort).

MODPORT FEATURE — EMISSION DONE + PARTIAL CONVERGENCE (23 UNSUP->DIFF; UNSUP
98->75). All pieces emit (modports, interface_typespec, InterfacePort,
ArbitrarySymbol). Common-cause convergence done (each roughly halved the
modport diffs, no regressions): (a) a bare logic_net per interface port;
(b) elab InterfacePort HighConn->interface_inst (ifaceInstMap) + LowConn->
modport + vpiDirection; (c) elab interface_inst emits its own modports;
(d) makeIfacePortTs: interface_typespec is a modport ts (vpiIsModPort) parented
by the base interface ts, from the InterfacePortHeader; (e) a dotless
ArbitrarySymbol is a plain ref_obj (only sub.sig -> hier_path). RESULT:
(f) BREAKTHROUGH - the INSTANCE-SCOPED interface_inst view: a module instance
with an interface port exposes its OWN interface_inst (work@top.m0.bus) under
vpiInterface, reusing emitInterfaceInstance with the instance-scoped path
(emitInstance !isTop block, gated conn.first->kind==Instance). Aggregate modport
DIFF -597. RESULT: iface_modport_out 167->83, iface_modport ->82,
iface_passthrough ->99, OneNetModport ->192. NONE at CMP_ONLY yet.
REMAINING is REFERENCE-ORDER-DEPENDENT (weakly-tail): golden duplicates the
interface_inst (abbreviated, loc col 0) in the weaklyReferenced tail, and holds
a connection-site logic_net (work@top.iface, referenced by the child ref_module).
MEASURED ~7 incremental attempts (connection-site net gated on scalar Instance,
modport Interface_inst + io_decl Expr, child ref_module suppression) - ALL
net-worse on the modport aggregate EVEN WHEN golden-correct, because adding one
referenced object shifts the weakly-tail arena order (iface_modport_out 83->91
with the golden-correct connection net). NEXT needs the full weakly-tail
reference/duplication model (how UHDM collects weaklyReferenced objects and
their dump order), not incremental object additions. None is close to CMP_ONLY
(smallest 82).

CMP-BLOCKER DIAGNOSIS (verified by walking uhdm-cmp on iface_modport, a
ref_module-KEEP test): the KEEP tests reach a SINGLE cmp mismatch with these
FOUR correct structural additions (all reverted - they worsen the DUMP metric
and convert nothing while the weakly-tail wall stands, but they ARE golden-
correct and get cmp to one weak-reference; RE-APPLY them together with a
weakly-tail fix):
  1. Connection-site logic_net: in emitModuleDef, for each child InterfacePort
     whose getConnection().first is a scalar Instance, emit a logic_net named
     after the interface (work@top.bus) at the connection expr, with
     n->VpiNetType(vpiWire); store in ifaceConnNet[iface] AND info.nets[iface].
  2. ref_module port bind: in emitModuleDefPorts, for an InterfacePort
     connection whose ref_obj came from emitExpr, set VpiFullName
     work@top.child.port and Actual_group=ifaceConnNet[iface] (the NamedValue
     branch already binds via info.nets once (1) stores it there).
  3. Elab modport io_decl Expr: io->Expr(netMap[mpp.internalSymbol]).
  4. Elab modport Interface_inst: umod->Interface_inst(iface).
THE WALL: golden ALSO emits the interface_inst AGAIN in the weaklyReferenced
tail (loc col 0, abbreviated) with a full modport whose io_decls carry vpiExpr;
this makes golden reference bus.in 8x vs mine 7x, and uhdm-cmp fails on the
missing weak reference (NOT just ordering). Cracking this needs matching UHDM's
Serializer weaklyReferenced collection (which owned-but-also-weakly-referenced
objects it re-lists, and in what order).
WEAKLY-TAIL MECHANISM FULLY DECODED (UHDM/templates/vpi_visitor.cpp): the
dumper collects into m_weaklyReferenced1 any object visited SHALLOWLY (weak
ref) that is NEVER fully visited in the main tree; at the end it full-dumps
them sorted by UhdmId. visit_modport() visits its Interface_inst SHALLOWLY
(vpi_visitor line ~2426, shallowVisit=true). GOLDEN EXPLOITS THIS: it creates
DUPLICATE interface_inst objects at COLUMN 0 (e.g. work@top.bus at line:25:0,
distinct from the owned one at 25:5) - one per weak reference point (the
modport's vpiInterface, connection sites). iface_modport golden has 9 such
col-0 interface_inst dups; each carries its own logic_vars + a modport whose
io_decls have vpiExpr->logic_var and whose vpiInterface points back to the
col-0 dup (self-referential). These col-0 dups are ONLY weakly referenced, so
they land in the tail, and their extra io_decl vpiExpr->logic_var references
are what make golden reference bus.in 8x vs mine 7x -> uhdm-cmp fails.
TO MATCH (the actual remaining task): create a col-0 "reference" interface_inst
duplicate for each modport's Interface_inst (and interface-connection point),
with the same vars + a self-referential modport, owned by NOTHING (only pointed
at weakly). This is pure Surelog dump-artifact replication (no semantic value)
but is what byte-identical requires. It is DEEP (object duplication + a
self-referential fixed point) and was NOT attempted; the 4 structural adds
above are the prerequisite. Est: converts the ~6 ref_module-KEEP modport
tests to CMP_ONLY; the OMIT tests additionally need the child-ref_module rule.
--- older note --- The KEEP tests (iface_modport,
iface_passthrough, iface_sig_in_child_port, ...) would convert to CMP_ONLY once
1-4 + the tail duplicate land. The OMIT tests (iface_modport_out,
OneNetModport, iface_modport_conn - golden emits ZERO child-module ref_modules)
ALSO need the child ref_module suppressed, and the rule is unclear (KEEP tests
have a top-level `assign iface.sig = ...` driving the interface; OMIT tests do
not - PLAUSIBLE rule: keep the child ref_module only if the parent itself
drives/refs the interface via a cont_assign, else omit - UNVERIFIED).
All-or-nothing per test: ANY noteUnsupported -> exit 4 -> UNSUP, so a modport
test needs ALL pieces below before it moves from UNSUP even to DIFF. Golden
structure verified on iface_sig_in_child_port (dut->mid(myif.s sub)->child).
PIECES:
 (1) MODPORTS - DONE (committed): interface_inst gets a vpiModport per
     ModportSymbol (VpiName + one io_decl per ModportPortSymbol: VpiName +
     VpiDirection from mpp.direction). isSimpleInterfaceBody now allows
     Modport. Matches golden exactly.
 (2) interface_typespec - s.MakeInterface_typespec(), VpiName = modport name,
     loc at the port's modport-name span. Referenced by the InterfacePort's
     vpiTypedef ref_typespec.
 (3) InterfacePort - a module port of kind SymbolKind::InterfacePort
     (InterfacePortSymbol: .interfaceDef=DefinitionSymbol*, .modport=name,
     .getConnection()->pair<Symbol* ifaceInstance, ModportSymbol*>). GOLDEN:
     port(sub) with vpiLowConn ref_obj (work@mid.sub.sub) -> Actual = the
     MODPORT object (s); vpiTypedef ref_typespec -> interface_typespec(s). Do
     NOT bail at ModuleEmit.cpp:45 for InterfacePort; emit it in emitPorts
     (def), emitModuleDefPorts, and emitInstance's port loop (elab). Need a
     map (interface DefinitionSymbol*, modport name)->UHDM::modport* populated
     in the modport emission (piece 1).
 (4) Elab interface connection - the interface instance passed to the module
     port (HighConn -> the interface_inst / its signals).
 (5) ArbitrarySymbol - emitExpr default case bails on ExpressionKind::
     ArbitrarySymbol (interface-port member access s.sig / sub.clk). Emit as a
     ref_obj/hier_path resolving through the modport to the interface signal.
     Some tests also need "element select base" (s.d[1]) and "member access
     base" (struct fields on interface signals).
Recommended: implement 2->5 in one focused block on a branch; verify each
against the iface_sig_in_child_port golden; the test only leaves UNSUP once
all bail-outs are gone, then converge the ~500-line diff.

--- ported interfaces (DONE) ---
PORTED-INTERFACE STEP (DONE — 4 tests converted to CMP_ONLY) — the ported
interfaces (InterfaceWithPort/Assign/Initial/Always) now converge to CMP_ONLY
(only weakly-tail typespec ordering remains). Key folded-model quirks handled:
(1) def-view interface ports carry no typespec; def net recorded in info.nets
so def port LowConns bind. (2) elab port loop handles positional connections
(loc at the conn expr) + parents the HighConn constant. (3) a single-instance
interface's def cont-assign refs re-point to the instance's ELAB vars (rebind
after elab). (4) the elab cont-assign SHARES the def's RHS object with a fresh
unbound elab-prefixed LHS. (5) processes are emitted ONCE in the elab view
(binding elab vars) and the SAME object is shared into both interface_inst
views (Surelog folds one process into both). Remaining ported-interface tests
with child instances/generate still fall through to the module path.
--- earlier (infrastructure) notes ---
INFRASTRUCTURE BUILT, per-test convergence remaining —
Step A: emitPorts/emitContAssigns/emitProcess/emitGenScopes now take instance*
and dispatch their setter on m->UhdmType() (instSetPorts/ContAssigns/Process/
GenScopeArrays in EmitHelpers.h). Step C: isSimpleInterfaceBody broadened to
allow ports/cont-assigns/processes (still excludes child instances/generate/
modports); emitInterfaceDef reuses those helpers (def view), emitInterfaceInstance
adds elab cont-assigns/processes + a port loop (LowConn own var, HighConn parent
signal, needs parentNets/parentRefs). Interface def ports carry NO typespec.
RESULT: no regressions; big reductions (InterfaceAssign 91->16, InterfaceWithPort
43->12, InterfaceInitial 63->37, InterfaceAlways 63->45) but still CMP_FAIL.
REMAINING per-test blockers to reach CMP_ONLY/PASS:
- InterfaceAssign: the def-view cont_assign LHS ref_obj should bind vpiActual to
  the ELAB int_var (a def->elab forward reference; Surelog quirk).
- InterfaceWithPort: the parent def-view ref_module port (emitModuleDefPorts loop,
  ~line 355) doesn't bind its ref to the interface child's def net (null vs
  logic_net) and has a wrong loc for positional/input connections.
- weakly-tail int_typespec ordering (the usual CMP_ONLY residue).
Next after that: the 48 UNSUP modport tests (InterfacePort/ArbitrarySymbol) build
on this same interface_inst infrastructure.

--- original analysis (still accurate) ---
The next interface lever after simple interfaces. Golden verified on InterfaceAssign (`interface
sw_test_status_if(output int x); assign x=10; endinterface` + `... u_sw(.x(o))`):
the interface_inst carries a vpiPort (x, dir out, LowConn->its net/var), a
vpiContAssign, and the parent references it via ref_module (def, whose vpiPort
carries the .x(o) HighConn) and vpiInterface (elab, whose vpiPort has BOTH
HighConn->parent's o and LowConn->interface's x var, cross-referenced).
MECHANISM decided: NOT C++ templates - instead change emitContAssigns/
emitProcess/emitPorts/emitGenScopes signatures from module_inst* to instance*
and dispatch the final setter on m->UhdmType() (uhdmmodule_inst vs
uhdminterface_inst; enum + VectorOf* types confirmed present). Nets(instance)/
Variables/Param_assigns/Typespecs(scope) need no dispatch. THE BLOCKER: the
elab port HighConn (linking the interface port to the PARENT's signal) is
emitted INLINE in emitInstance's instance-view port loop (~line 786+), not in
the reusable emitPorts (which only does LowConn). So converting ported
interfaces needs EITHER making emitInstance interface-aware (create
interface_inst, DefInfo::mod -> instance*, route + if/dispatch the ~7
module_inst-only calls) OR duplicating the port-connection logic into
emitInterfaceInstance. Every ported-interface test (InterfaceAssign/Initial/
Always/WithPort) has this port-connection need - no incremental win without it.
This is a large careful refactor of the core emission (produces 263 PASS);
do it as a dedicated focused effort, testing the module path green at each step.

Eight code commits (r166-r173), all clean (no regressions):
- (r166) Assignment-pattern param defaults ('{0,1}): elab-view folded RHS
  decompiles as based-decimal (2'd1) w/ no typespec & no constType; def-view
  pattern-op elements keep vpiSize:64 UNparented. Converts 4 Negation/Pattern
  param tests.
- (r167) Parameter vpiSigned only when the declaration has an explicit
  `parameter`/`localparam` keyword (bare ANSI #(int x) omits it). CellNamed
  DIFF->CMP_ONLY.
- (r168) Unbased-unsized VAR initializers ('0/'1/'x/'z) each encode distinctly
  ('0->BIN:0 sized, '1->UINT all-ones sized, 'x/'z->BIN:X/Z size -1). Converts
  UnsizedConstantsParsing.
- (r169) Unified outermost assignment-pattern element sizing on
  suppressConstParent (var-init resizes to element type; func-arg/param-default
  keep 64 unparented). Subsumes r166 inParamInit case.
- (r170) Folded range-bound: only SUBTRACT (N-1) is INT; other ops (P+1) are
  UINT (counter WIDTH-1->INT:7, CastToSum P+1->UINT:2).
- (r171) Module vector/scalar typedef ranges UNFOLD param/$bits-dependent
  bounds (tfContext). BitsCallOnType 25->15, +3 others reduced.
- (r172) Unbased-unsized typed-param defaults ('0/'1): parameter VpiValue
  BIN:<bit>; elab RHS BIN + <width>'b<bit> decompile; def-view RHS carries
  the param typespec ref. Converts UnsizedConstantParameterInInstance.

Attempted-and-reverted this session:
- Sized-literal x/z uppercasing (1'bx -> 1'bX): Surelog's casing is
  INCONSISTENT (1'bx->X but 1'bz->z, 3'bxxx->xxx lowercase) - no clean rule,
  reverted (unbased_unsized got worse 26->34).

INTERFACE FEATURE — PARTIALLY IMPLEMENTED (branch interface-feature, then
merged). DONE: "simple" interfaces (only variables/nets/parameters, no
ports/processes/cont-assigns/child-instances/generate/modports - gated by
isSimpleInterfaceBody) are emitted as interface_inst in design->AllInterfaces,
referenced from a parent module via ref_module (Actual->interface_inst, def
view) and Interfaces() (vpiInterface, elab view). emitInterfaceDef/
emitInterfaceInstance in ModuleEmit.cpp; routing in exportDesign +
emitInstance child loop + emitModuleDefPorts ref. Def-net typespecs deferred
through pendingNetTs (arena order + init-span); def-net param-ranges unfold
via tfContext during materialization; elab var inits apply the unbased-unsized
width fill. CONVERTED: InterfaceVariable (PASS); InterfaceParameter,
InterfaceParameterSetValue, iface_param_set_value, iface_local_in_sub
(CMP_ONLY - residual is weakly-tail typespec ordering).

REMAINING interface work (complex interfaces still fall through to the
module_inst path, staying DIFF): processes (InterfaceInitial/Always),
cont_assigns (InterfaceAssign), ports (InterfaceWithPort), child instances.
These need emitContAssigns/emitProcess/emitPorts (currently typed
module_inst*) to serve interface_inst too - either TEMPLATE them on the
instance type (Cont_assigns/Process/Ports are parallel identical methods on
both classes, so `m->X()` resolves per-type; use explicit instantiation) OR
duplicate the vector-building subset for interface_inst. The 45 UNSUP
interface tests were unaffected (their UNSUP cause is elsewhere - triage
separately).

--- original plan (golden structure, still accurate) ---
Golden structure verified from Surelog on InterfaceVariable (the
minimal case: `interface sim_sram_if; int start_addr=...; endinterface` +
`sim_sram_if u(); ... u.start_addr`):

  design
   |uhdmallInterfaces -> interface_inst work@sim_sram_if (DEF view; parent=
   |   design; content like a module def: start_addr is a LOGIC_NET here)
   |uhdmallModules    -> module_inst work@top (DEF): net o, port o, cont_assign,
   |   and |vpiRefModule -> ref_module work@sim_sram_if (u) whose Actual_group
   |   -> the interface_inst DEF.  ** def-view child ref is STILL a ref_module,
   |   just Actual points at interface_inst -> def path barely changes **
   |uhdmtopModules    -> module_inst work@top (ELAB): int_var o, port o,
       |vpiInterface -> interface_inst work@sim_sram_if (work@top.u) — the
       ELABORATED iface (int_var start_addr + init constant + vpiInstance->top,
       vpiDefName/vpiDefFile/vpiDefLineNo).  Attached via module_inst::Interfaces().

Touch points (agent-verified file:line):
  - Detect: inst.isInterface() / getDefinition().definitionKind ==
    DefinitionKind::Interface (slang InstanceSymbols.h:112, SemanticFacts.h:45).
  - UhdmExporter.cpp:201-210 shell pre-create: interface defs ->
    s.MakeInterface_inst() into a NEW d->AllInterfaces() vec (design.h:83; there
    is NO TopInterfaces, only AllInterfaces).
  - ModuleEmit.cpp:472 elab object create: MakeInterface_inst for iface insts;
    VpiTop/VpiTopModule only for modules.
  - ModuleEmit.cpp:490-491,506-507: interface_inst has Instance() but NOT
    Module_inst() -> drop the Module_inst back-pointer for ifaces.
  - ModuleEmit.cpp:760-780 elab child loop: route interface children into a
    separate vec -> m->Interfaces(vec) (module_inst.h:152) instead of Modules().
  - ModuleEmit.cpp:329-392 def-view ref_module: unchanged; Actual_group takes
    BaseClass* so it points at interface_inst fine.
  - Interface content reuse: Nets(instance base), Variables/Parameters/
    Param_assigns/Typespecs(scope base), Cont_assigns/Process/Ports/
    Gen_scope_arrays(parallel identical sigs on interface_inst) -> a function
    templated on InstT resolves for both; OR duplicate the ~7 module_inst-only
    call sites.
  Coupling to widen: DefInfo::mod (module_inst* -> instance*), TopPending::m,
  ~18 module_inst* signatures, ~12 .mod refs, 7 module_inst-only call sites.
  Recommended: change DefInfo::mod to instance*, cast to module_inst* at the 7
  module_inst-only sites (guarded by !isInterface); widen emitModuleDef/
  emitInstance return + emitPorts/emitContAssigns/emitGenScopes params to a
  template or instance*/scope*. Build+goldens+corpus after each step; revertible.

FINDINGS / dead-ends this session:
- GENERIC-DEF PORT-RANGE UNFOLD (CastToSum*, ParameterOfSizeOfPort,
  ParameterPackedArray - ~5 tests): a NON-top module's AllModules def unfolds
  param-dim PORT bounds (P+1->operation) while a TOP def folds (counter
  WIDTH-1->7). Verified rule. BUT setting tfContext during non-top emitPorts
  swaps the arena order of the shared def-vs-elab port typespec (they're the
  SAME object). Needs SEPARATE def/elab port typespec objects first - deeper
  refactor. Reverted. No passing test has instantiated-param-width-port
  submodules, so the change is safe once typespecs are unshared.
- $bits(TYPE) in a TYPEDEF range wants fold->const 32 (BitsCallOnType), but in
  a plain range wants sys_func_call (BitsCallOnVar, r160). Context-dependent;
  needs sub-expression eval. Left at 15 lines.
- net-vs-var for typedef'd output ports (TypedefInModulePort: output pkg::word
  -> logic_VAR not logic_net) and struct-member port-conn hier-path scoping
  (StructMemberAsModuleInput) remain conditional/risky.
- isIntEncoded INT-vs-UINT for folded consts is genuinely context-dependent
  (multiple_blocking 2**SELW->INT elab; PatternAsFunctionArgument func result
  ->UINT). No universal rule found.

---
# HANDOFF — slang-uhdm convergence campaign (r163 state)

For a fresh session picking up this project. Read this, then NOTES.md
(quirk catalog — the accumulated ground truth), then PLAN.md Part II
(campaign strategy). Everything below is verified as of 2026-07-18.

## Mission (unchanged)

1. Converge the 710-test uhdm2rtlil corpus: slang-uhdm output byte-identical
   to Surelog's (`uhdm-dump` diff empty + `uhdm-cmp` exit 0) for all 661
   achievable tests (710 − 44 SLANG_REJECT − 5 SURELOG_FAIL).
   Remaining phases: B2, C2, C3, D, E, F (details in PLAN.md Part II §2).
2. Then the Surelog repo suite (~703 dirs, PLAN.md Part II §3).
3. Then sv-tests (~2346 files, PLAN.md Part II §4).

## Current scoreboard (r163 baseline, committed as results/baseline.csv)

PASS 256 · CMP_ONLY 8 · DIFF 299 · UNSUPPORTED 98 (r163). SESSION r138-r163
(this session): +18 PASS (238->256), UNSUP 109->98. LATE-STAGE STRATEGY: DIFF
classified 214 structural(a: wrong/missing objects) vs 78 attribute(b); prioritize
(a). No clean multi-test DIFF levers remain (packed_array_var/struct_var/vector-
typedef all proved per-test); reliable value = per-test pickoffs + a few real
features. (r158) SIGNED SIZE-CAST fold N'(signed_ref)->signed const + deferred
signed logic_typespec (pendingSignedCastTs), gated to signed non-literal operands
so 3'(31)/int'(x) don't regress - CastClog2 PASS. (r159) STRUCT-PREFIX WALL CRACKED
(leaf-vs-nested): module-level LEAF packed struct typedef -> prefixed member refs
(work@mod.T.m) + module parent; struct containing a nested struct/enum -> BARE;
file-level -> bare. (r160) $bits(TYPE) in an unfolded range bound -> sys_func_call
w/ ref_obj arg (emitSyntaxExpr SystemName branch) - BitsCallOnVar PASS. (r161)
typed packed-logic-VECTOR param (parameter logic [31:0] X) -> logic_typespec via
makeTypespec, gated to IntegerTypeSyntax (typedef'd stays int_typespec) - broad
(a) reduction across package-param tests. (r162/r163) PACKAGE TYPEDEFS: emitPackage
now emits vector (logic_typespec pkg::T) + struct/enum typedefs with pkg::pkg::T::m
DOUBLED member refs (buildStructTs memberSep param) + field-typespec vpiInstance=
package, populating typedefTs - BitsCallOnStructMember PASS, 8 pkg tests UNSUP->DIFF.
REMAINING pkg-typedef refinements (per-test): range-bound X-1 UNFOLD w/ ::-doubled
refs (needs emitSyntaxExpr :: separator + tfContext), typedef'd-signal logic_var-vs-
net, vpiNetType. GENERATE cluster (r153-r156):
(r153) emit gen-scope LOCAL NETS (wire tmp;) as logic_nets on the gen_scope, kept
out of netMap so refs stay weak - simple_generate PASS; (r154) gen_blk[N] index in
a HierarchicalValue path is a bit_select (name ref + bare UINT index), not one
ref_obj; (r155) bare-reference range bounds ([i:i]) fold to UINT not INT (only
operation bounds N-1 use INT-at-left-operand); (r156) gen-scope net-decl-assigns
(wire z = '1;) as gen_scope cont_assigns with a fresh Lhs net + deferred typespec,
unbased-unsized RHS folded to net width via tryEval, net-decl net loses its list
typespec parent, and genvar int_typespecs drain LAST (pendingGenvarTs) -
AssignGeneratedWireInAlways/CaseWithGeneratedWire PASS. Larger genblk tests
(blockrom/forgen02/genblk_order/MemoryInGenblock/BitSelectOf*InGenFor) still need
gen-scope VARS/memories, submodule instances in gen-for, nested generate.
(r152) function part-select
bound refs scope their fullname by the base name inside a task/function body
(currentSubSym gate; Surelog's doubled inp[A:B]->func.inp.A form) + task/function
params follow the source keyword for vpiLocalParam (like packages) - func_block
PASS. The PARAM cluster was the
richest vein: (r147) untyped ranged param int_typespec locates at its range span;
(r148) ranged untyped param carries its packed range (located, range-parented UINT
bounds) + parents to the parameter [isRangedUntypedParam helper] -> 3 counters PASS;
(r150) ranged untyped LOCALPARAMs are valued+typed like non-locals -> 2 more PASS;
(r151) untyped params carry a typespec ONLY for LITERAL inits (computed $clog2(W)/
2**S get none) - broad diff reduction. Also (r146) $signed/$unsigned sys_func_call
result typespec shares the LHS PORT typespec; (r149) inline anon enum bare base
ref_typespec (gated implicitBaseRef).
REMAINING DIFF are consistently: weakly-ref-actual (a ref's vpiActual resolves to a
later indexed_part_select/bit_select by fullname collision - func_output_arg,
sign_part_assign, multiple_blocking, CellNamedLikeModule); context-dependent
unbased-unsized encoding ('0/'1/'x/'z as typed-param/int-var values need a constant
typespec + BIN encoding - UnsizedConstants*, ParameterWithUnderscore); cast folds
(CastClog2/CastToSum multi-view signedness); big features (interface_inst refactor
per NOTES, top-view packed_array_var elaboration for DotMultirange). Clog2OfSum (17)
needs $clog2 result typespec [r146 shape] + fold-const unparented + top-view LHS
binds def net.
--- older session summary (r138-r149) below ---
PASS 247 · CMP_ONLY 8 · DIFF 300 · UNSUPPORTED 106 (r149). SESSION r138-r149
(this session): +9 PASS (238->247), UNSUP 109->106. Additional landings after r145:
(r146) $signed/$unsigned sys_func_call result typespec shares the LHS PORT's
typespec actual (search di->mod->Ports() by name after the write phase; port nets
don't carry n->Typespec(), so it lives on the port) - OneSysFunc PASS. (r147)
untyped ranged param int_typespec locates at its range span. (r148) untyped
ranged param (parameter [N:0] X) int_typespec carries its packed range with
located, range-parented UINT bounds AND parents to the parameter (isRangedUntyped
Param helper) - counter_ifelse_chain/counter_xpath/pico_count_cycle PASS. (r149)
inline anonymous enum (enum {..} v) carries a bare base ref_typespec (fullname
patched to the var by the var-emit path); gated on implicitBaseRef so typedef
anon-base enums (enum_values) stay unaffected - simple_enum PASS.
NEXT tractable leads: Clog2OfSum (17, needs $clog2 result typespec [same shape as
r146] + fold-constant unparented + top-view LHS binds def net); the ranged-param
typespec pattern may convert more param tests (UnsizedConstantsParameterParsing).
--- older session summary (r138-r145) below ---
PASS 242 · CMP_ONLY 8 · DIFF 305 · UNSUPPORTED 106 (r144). SESSION r138-r144
(this session): +4 PASS (238->242), UNSUP 109->106, plus several diff reductions.
Landed: (r139) 2D-array member access in hier_paths (base multi-dim element
select group_status[0][0].a - one bit_select per dim, simple dotted fullnames,
prior-selector loc chain, only-first-dim vpiName, unparented index consts,
full-dotted trailing member; DotMultirange/int_port_signed/
MemberSelectOf2DStructPackedArray UNSUP->DIFF, blocked on top-view
packed_array_var ELABORATION). (r140) unpacked-array net element typespec keeps
its packed ranges (descend past unpacked dims to the packed leaf before the
isPackedArray guard - mem_sub_plain, simple_memory_noreset). (r141) unpacked-array
range bounds fold non-literal to INT at left-operand span (MemorySlice). (r142)
size-style unpacked dim [N] emits right bound as unfolded N-1 operation opType 11
(ArraySize). (r143) anonymous-enum value refs bind their enum_const deferred
(simple_enum 35->15). (r144) constants parent to their immediate_assert
(simple_enum 15->11). (r145) $signed/$unsigned don't force a fresh top-view
cont_assign - shared like non-operation RHS (OneSysFunc 32->9; remaining:
sys_func_call result vpiTypespec = LHS net type, needs a SHARED deferred
actual - naive makeTypespec mints a tail duplicate, the top-def port-net
actual share is unresolved; Clog2OfSum needs the same).
INTRACTABLE THIS SESSION (documented in NOTES): weakly-tail net-typespec
parenting (27-regression), anon-enum base-typespec ref (enum_values regression -
typedef vs inline is subtle), interface_inst refactor (needs templating ~15 fns;
InterfaceVariable is a PURE interface_inst-vs-module_inst type diff, only ~3
port-less tests). Cast folds (CastClog2/CastToSum/CastInFunction) are each
distinct multi-view signedness/unfold quirks. Small-DIFF weakly-ref-actual
tests (func_output_arg, sign_part_assign, CellNamedLikeModule) resolve a ref's
vpiActual to a later bit_select/part_select by fullname collision - Surelog-
internal, hard to replicate.
PRIOR (r137): PASS 238 · CMP_ONLY 7 · DIFF 301 · UNSUPPORTED 115. r136-r137: replicated assignment patterns '{N{...}} (MultiAssignmentPatternOfConcat) and constant-driven integer-var cont_assign RHS fold (CppMacroNameAsVariableName; gated to predefined-integer vars via an lvalue write-scan - logic typedef vars stay shared). SESSION r109-r137: 204->238 PASS (+34), UNSUP 125->115, DIFF 326->301, CMP_ONLY 6->7. NB: run_corpus's regression check MISSES PASS->CMP_ONLY - after broad changes, manually diff PASS rows (join baseline r137, awk '$2==PASS && $4!=PASS'). r135: r133-r135: gen-scope process refs to outer signals left unbound (async_reset_partsel), block-local var typespecs keep UNFOLDED range bounds (local_var_in_always), block-local signed var signedness on typespec not var + based-literal attr values BIN/HEX (sincos). SESSION r109-r135: 204->236 PASS (+32), UNSUP 125->116, DIFF 326->302. NEXT tractable: OneSysFunc/Clog2OfSum need a $unsigned/$clog2 result vpiTypespec (= the cont_assign LHS type) + the top-view cont_assign SHARED (containsOperation forces re-emit for sys calls; $signed/$unsigned shouldn't). simple_enum: anonymous-enum value refs need vpiActual->enum_const but enumConstMap is populated in the write phase AFTER processes (ordering). Then the weakly-tail CMP_ONLY cluster, package typedefs, interfaces. r132: r131-r132: typed logic scalar params -> logic_typespec (NegationOfParameterInInstance), and DPI export/import attributes (DPI-exported sub -> function w/ AccessType 3 + DPICStr 2; import 'context' -> vpiDPIContext; TaskExportDPI). SESSION r109-r132: 204->233 PASS (+29), UNSUP 125->116, DIFF 326->305. r130: r130: system-call direct literal args parent to the call in every context (MultiplePrints). SESSION r109-r130: 204->231 PASS (+27), UNSUP 125->116, DIFF 326->307. Remaining: 7 CMP_ONLY + small-DIFF weakly-tail tests (partsel_simple, simple_struct, array-copy, UnsizedConst struct-member cont_assign, BindModuleWithInputPorts, sva_basic02, StringWithBackslash string-loc quirk) - net-typespec arena position/parent + dual-view ordering. Then package typedefs + packed_array_typespec (NOTES), then interfaces (45). r129: r129: the typed-param re-emit binds its LHS ref to the def-view net (like other literal/fold re-emits), fixing the weakly-tail LHS-actual for ParameterUnsignedInt (converged). SESSION r109-r129: 204->230 PASS (+26), UNSUP 125->116. NEXT: the 8 CMP_ONLY tests (partsel_simple, simple_struct, array-copy, BindModuleWithInputPorts, MultiplePrints, StringWithBackslash, sva_basic02, UnsizedConst) are DUMP_MATCH-or-near, blocked on the WEAKLY-TAIL arena-order + net-typespec-parent quirk (a net's def-view logic_typespec appears at a different arena position with a different parent - logic_net vs ref_typespec - than Surelog; materializeDefNetTs doesn't set ts VpiParent). Then package typedefs + packed_array_typespec (NOTES), then interfaces (45). r128: r128: typed non-overridden param cont_assign RHS folds to a constant + param-typespec ref (ParameterUnsignedInt 30->4, now blocked only by the weakly-tail LHS-actual quirk: ref resolves to int_var not the def logic_net). The 9 CMP_ONLY tests are now the highest-value cluster - all DUMP_MATCH, blocked on the recurring WEAKLY-TAIL arena-order / ref-actual resolution (same fullname, dump follows the pointer to the wrong dual-view object). Cracking the def-vs-top ref-actual resolution would convert several at once. r127: r126-r127: enum function returns (enum_var + unfolded enum base-typespec range bounds) and STRING TYPE support (string_var/string_typespec; StringWithBackslash 35->8, two string tests DIFF->CMP_ONLY). Converged FunctionReturnEnum. r125: r123-r125: port-with-logic-body-redecl -> logic_var, left-assoc event-or lists, and REAL SUPPORT (real/shortreal vars+typespecs, REAL constants, block-local var-init as a blocking assignment, module real-var no-typespec init-as-expr). Converged AluOps, fsm_using_always, RealValue, Shortreal, conditional_if_else, cdc_static_basic, UnitForLoop, hier_undriven_port + more. r122: r118-r122: multi-attribute groups with values (last (* *) group; STRING/REAL/INT for direct literals), implicit-return-type bare return var, reg-variable net-declaration assignments, implicit nets (bare wire, no typespec) + unsized-based-literal size context (-1 vs 0 by parent), and left-associative event-or lists. r109-r117: constant-sizing cluster (net/instance-view attributes; boolean-fold BIN; assignment-pattern element sizing with an outermost-vs-nested rule; net-decl bare-decimal RHS to net width; raw string constants), const-fold for-loops that return on the first iteration (terminal-flag propagation in constCallFold) + arg-less fold UINT encoding, function-body unbased-unsized RHS sizing, and emitMixedHierPath (b.a[0].x mixed member/element-select hier_paths; lvalue vs rvalue bit_select forms differ). NEXT ENABLER: PACKAGE STRUCT/ENUM TYPEDEFS - emitPackage (src/ParamEmit.cpp) emits only params+task_funcs; it must also emit vpiTypedef struct_typespec/enum_typespec AND populate typedefTs. Golden shape (PackedArray): struct_typespec VpiName=pkg::struct_a, VpiParent=package, VpiInstance=package, vpiPacked:1, member ref fullname DOUBLED as pkg::pkg::struct_a::x. Unblocks ~8 packed-array-of-struct DIFF tests (PackedArray, StructPackedOutput, hier_path, StructOfArrayOfStructs, ...) plus the packed-array-of-typedef cluster (EnumArray needs packed_array_typespec with Elem_typespec ref to the shared package enum) and BitsCallOnVar; watch the weakly-tail typespec ordering. THEN interfaces (45: AllInterfaces design relation, interface_inst def+inst views, InterfacePort, ArbitrarySymbol member access). r107-r108: struct-typed function returns (struct_var + canonical-matched typedef; conditional file-struct design parent), nested member-access selects (bar.l[2][1] -> hier_path var_select), and module end labels. Converged func_struct_repro, DotRange, struct_array. NEXT: PACKED-ARRAY-OF-TYPEDEF (EnumArray/DotMultirange/gen_struct_access) needs (1) package typedefs added to typedefTs - emitPackage does NOT call emitTypedefs today, so package enums/structs are built inline not shared - and (2) a packed_array_typespec {Ranges + Elem_typespec ref to the shared typedef} in makeTypespec (code sketched then reverted as dead until package typedefs land). Then interfaces (46+46). r105-r106: file-level packed struct design-parent (struct_array) and file-level typedef source-order build with name-sorted list (simple_struct 202->86). NEXT: struct member access on packed-array-of-struct + struct-typed function returns (struct_var) unblock the struct DIFF cluster; then interfaces (46+46). A recurring blocker on several CMP_ONLY tests (simple_struct/array-copy/partsel_simple/BindModule) is the weakly-tail TYPESPEC ORDER - same object set, different arena position; a general fix to typespec creation order would convert several at once. r103-r104: compound assignments (+=/<<= -> op-typed assignment) and FILE-LEVEL packed/unpacked struct typedefs (buildStructTs on the design). NEXT tractable: struct-typed function returns (struct_var, func_struct_repro), struct member access on packed-array-of-struct (DotMultirange/DotRange/gen_struct_access), then interfaces (46+46, biggest untouched). Also: \x-sizing in blocking-assign is context-dependent (function sizes, always block does not - unresolved, reverted). r99-r102 landed the full property-expression emitter (implications/until/throughout/sequence-concat/not), default clocking blocks, and NET-DECLARATION ASSIGNMENTS (wire x = expr -> cont_assign; literal/op RHS -> fresh Lhs net + deferred typespec; general x->X uppercase for unbased-unsized). Converged sva_not, sva_throughout, sva_value_change_*, signed_partsel_ext. r96-r98 landed the property-expression emitter (emitAssertionExpr: implication/until/throughout/sequence-concat/not ops), default clocking blocks, assume/cover/restrict, and typed localparams (integer/byte/... _typespec). Converged sva_basic00/01/03, sva_value_change_rose, sva_throughout, sva_not. r95 landed concurrent assertions (folded assert_stmt: label, clocking-only property_spec for assert-with-clocking; via instance Assertions()/vpiAssertion, shared across instances like processes). NEXT for assertions: a recursive property-expression emitter (emitAssertionExpr) + assume/cover kinds - the exact rule + operator/opType tables are in NOTES.md "Concurrent assertion property-expr rule". Also landed r93-r94: assignment-pattern fold to based constant + numeric-index integer_typespec tags (PatternDefault/PatternIndexes converge). Session 5 third
stretch (r82-r92) landed: var_select flattening (nested element selects,
range/part-select of element-select bases), array_var/array_typespec for
unpacked-array signals (element types, pattern inits, io_decl ranges),
range-select of member-access -> hier_path, multi-dim packed def-net span,
predefined integer types (shortint/longint/byte/time), while/do-while/
forever loops, and assignment-pattern default/index setters.
NEXT solo-blocker clusters (run the m91.txt-style triage to refresh):
- ConcurrentAssertion: 7 done; remaining need: net-decl-assign (NOTES r98, sva_value_change_changed - CAREFUL ts-extension condition), ##[*]/until precedence (sva_range - slang vs Surelog assoc), AssertionInstance/named property (sva_counter), package func (package_task_func), bind+assert (sva_basic02 CMP_ONLY).
- member access base (9) - mostly interface/struct (overlaps E4).
- assignment pattern setter kind: DONE for tags; remaining tests need the
  top-view pattern FOLD to a based constant + def value parenting under the
  orphan re-parent machinery (PatternDefault, PatternIndexes).
- PackedStructType typedef (7) + PackedUnionType (3): package/anon structs.
- LValueReference (5), Streaming (4), ProceduralAssign (2), parallel block.
- E4 INTERFACES (46 InterfacePort + 46 ArbitrarySymbol) - biggest overall,
  still untouched; needs interface instances, modports, virtual interfaces.
- Unpacked-array PORTS want array_net (not array_var) - AssignArraySelPlus.
Deferred: func_local_array (function-local unpacked array in begin blocks),
ImportFunction (package import deep-clone), macro-expansion locs (asym_ram_*),
BindModuleWithInputPorts (4-line ts arena position), F --elabuhdm, suites.

## Old scoreboard reference (r81)

PASS 169 · CMP_ONLY 1 · DIFF 291 · UNSUPPORTED 200 (r81). Session 5 second
half (r79-r81) landed: B2 parameter overrides (isOverriddenParam detection,
DEFAULT-derived values both views, vpiOverriden, folded override constants,
child CA override re-emits, unknown 'x defaults, untyped INT/-1 folds),
type casts (target-type ts, deferred re-emit variants, top-keeps/child-folds
rule), and the DEF CONTENT PRE-PASS architecture change (all defs' content
compiles name-sorted before any instance; only emitModuleDefPorts is
encounter-ordered — see NOTES r81 entry).
NEXT immediate targets:
1. Select-base cluster (~34 solo): unpacked-array element selects with
   non-NamedValue bases (nested pa[0][1]) — ExprEmit.cpp:772/797. Probe
   golden with a MINIMAL unpacked array select first (array_assign is big;
   try 2DUnpackedArray or func_local_array).
2. E4 interfaces (46 tests, InterfacePort+ArbitrarySymbol).
3. PackedStructType typedefs 17, ConcurrentAssertion 13, integer type kind.
4. BindModuleWithInputPorts CMP_ONLY: 4-line tail order — the bound
   instance's port pts (4:21) must come RIGHT AFTER its def's net-ts
   materialize, before rv_dm write ts; ours emits it later.
5. Known-hard/deferred: ImportFunction (package import deep-clone with
   half-reprefixed names), macro-expansion locations (asym_ram_*),
   rsp_gen_minimal (1549 lines), simple_package (package struct typedefs).

## Old scoreboard reference (r78)

PASS 163 · CMP_ONLY 1 · DIFF 297 · UNSUPPORTED 200 · CRASH 0
· SLANG_REJECT 44 · SURELOG_FAIL 5
Session 5 (r72-r78) landed: function-scope localparams + block-param
implicit nets, package task_funcs (:: fullnames, dual-view copies, ts
vpiInstance), function body begin wrappers + initialized locals, const-call
folds (literal chains, package-param-backed with ts clones, evaluable
calls), call arg formal-ts refs, module imports (import_typespec + hidden
Item constant + shared pkg fns in module Task_funcs), positional port
connections, gen-scope functions + def-view gen_if_else from syntax,
$unit (design-level) functions, type casts. The one CMP_ONLY:
BindModuleWithInputPorts (4-line ts arena position).
NEXT: B2 parameterized instances (param overrides: def view keeps DEFAULT
values incl. BIN:X for 'x, instance views carry override-site constants,
vpiOverriden:1 on overridden param_assigns, DEC:7_200 underscore-preserving
decompiles - see ParameterWithUnderscoreValue diff); then select bases
(~34 solo), interfaces (46), PackedStructType 17, ConcurrentAssertion 11.
Remaining known-hard: import deep-clones (ImportFunction), macro-expansion
locations (asym_ram_*), rsp_gen_minimal.

## Environment (this machine)

- This repo: ~/git-repos/slang-uhdm  (history: extracted from the
  slang fork's uhdm-export branch, which remains frozen as an archive)
- Build: `~/.local/bin/cmake -B build -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_PREFIX_PATH=$HOME/.local && ~/.local/bin/cmake --build build -j 4`
  (system cmake is too old; slang + UHDM installed in ~/.local prefix)
- Binary: build/slang-uhdm
- Reference producer: ~/git-repos/Surelog/build/bin/surelog  (v1.86-114)
  invoke: surelog -parse -nobuiltin -nocache <files> → slpp_all/surelog.uhdm
- Oracles: ~/git-repos/UHDM/build/bin/{uhdm-dump,uhdm-cmp,uhdm-hier,uhdm-lint}
  (UHDM 5523dfc — NEVER update these checkouts mid-campaign)
- Corpus: ~/git-repos/uhdm2rtlil/test/*/dut.sv (710 tests)
- Slang sources for API reference: ~/git-repos/slang (branch uhdm-export)
- DO NOT USE: any binary under ~/git-repos/sv-tests/third_party or
  ~/git-repos/UHDM-1.84 (v1.84, schema-incompatible)

## The dev loop (verified, fast)

1. `./scripts/triage.sh results/latest.csv` → pick the top blocker.
2. Write a minimal probe dut.sv exercising it; run
   `./scripts/converge.sh probe.sv` and read the golden via
   `uhdm-dump <workdir>/slpp_all/surelog.uhdm` to learn Surelog's shape.
3. Implement in src/; rebuild (`cmake --build build -j 4`, ~30s);
   re-run converge.sh until DUMP_MATCH + PASS_CMP.
4. `./tests/check_goldens.sh` (must stay 5/5), then
   `./scripts/run_corpus.sh ~/git-repos/uhdm2rtlil/test results/rN.csv
   results/baseline.csv` (~50s, parallel; FAILS on regressions).
5. Commit per converged feature; append every new quirk to NOTES.md;
   promote 1-2 representative tests to tests/golden/ per feature;
   update results/baseline.csv when a round improves.

Methodology hard rules (learned the expensive way):
- DUMP_MATCH alone is NOT success — uhdm-cmp checks fields the dump never
  prints (Module_inst, typespec Instance). Require both.
- When cmp fails but dump matches, bisect with a C++ probe against the
  installed UHDM lib (pattern in NOTES.md "Session 1"; probe compiles with
  g++ -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj).
- Weakly-tail dump order = object CREATION order per type. Fix content
  first, ordering second.
- Match Surelog bug-for-bug; document every replicated quirk in NOTES.md.

## DONE (session 3): Task 0 split, tail ordering, C2, D1, E2, D2, C3

The file layout now: src/{UhdmExporter,ModuleEmit,ParamEmit,StmtEmit,
TaskFuncEmit,ExprEmit,TypeEmit}.cpp + src/EmitHelpers.h. The arena-order
model (write-phase drains, def/top port ts swap, fullname freeze quirk)
is fully documented in NOTES.md sessions 3 — READ IT before touching
typespec ordering.

## Next phases (r32 triage: scripts/triage.sh results/baseline.csv)

1. Top remaining blockers (r65 triage): HierarchicalValue 57 (E1),
   InterfacePort 46 (E4), ArbitrarySymbol 46, member access base 37
   (remaining select-on-complex cases: lvalues, range selects on members),
   StructuredAssignmentPattern 35 + Simple 25 (D3), element select base 32
   (2D/array selects — D4 arrays), user function call 33 (package funcs),
   expression kind Invalid 33 (investigate: likely error-recovery exprs),
   range select base 24, PackedStructType typedef 17 (package contexts).
   DONE since r32: vector typedefs, bind, qualifiers, var inits, block/
   function locals, statement lists, member-base bit selects, cast-size
   exprs, $bits folds, select base-scoping, case query-call parents.
2. B2 parameterized instances: STUDY AdditionAsParameterInInstance golden
   first (folded specialized-def shape still unknown).
3. F: --elabuhdm mode (run UHDM ElaboratorListener + UhdmAdjuster
   in-process like Surelog's -elabuhdm; needed for Stage 2 and
   sv-pathfinder).

## Stages 2-3 (after corpus is mostly green)

- Surelog suite: tests/<Name>/<Name>.sl holds raw surelog args; write
  scripts/run_surelog_suite.sh mapping them to slang-uhdm args. Many use
  -elabuhdm → needs F first. Tiering + goals in PLAN.md Part II §3.
- sv-tests: metadata-driven runner (:tags:/:should_fail:), agreement matrix.
  PLAN.md Part II §4.

## Flow closure (deferred by user, do LAST)

Build uhdm2rtlil, run its test_uhdm_workflow.sh with slang-produced .uhdm;
rebuild sv-pathfinder's native addon against UHDM v1.86 (binding.gyp
UHDM_HOME change + node-gyp rebuild).
