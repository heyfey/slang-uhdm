# HANDOFF — slang-uhdm convergence campaign (r156 state)

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

## Current scoreboard (r156 baseline, committed as results/baseline.csv)

PASS 253 · CMP_ONLY 8 · DIFF 294 · UNSUPPORTED 106 (r156). SESSION r138-r156
(this session): +15 PASS (238->253), UNSUP 109->106. GENERATE cluster (r153-r156):
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
