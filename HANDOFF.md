# HANDOFF — slang-uhdm convergence campaign (r108 state)

For a fresh session picking up this project. Read this, then NOTES.md
(quirk catalog — the accumulated ground truth), then PLAN.md Part II
(campaign strategy). Everything below is verified as of 2026-07-17.

## Mission (unchanged)

1. Converge the 710-test uhdm2rtlil corpus: slang-uhdm output byte-identical
   to Surelog's (`uhdm-dump` diff empty + `uhdm-cmp` exit 0) for all 661
   achievable tests (710 − 44 SLANG_REJECT − 5 SURELOG_FAIL).
   Remaining phases: B2, C2, C3, D, E, F (details in PLAN.md Part II §2).
2. Then the Surelog repo suite (~703 dirs, PLAN.md Part II §3).
3. Then sv-tests (~2346 files, PLAN.md Part II §4).

## Current scoreboard (r117 baseline, committed as results/baseline.csv)

PASS 217 · CMP_ONLY 6 · DIFF 321 · UNSUPPORTED 117 (r117). r109-r117: constant-sizing cluster (net/instance-view attributes; boolean-fold BIN; assignment-pattern element sizing with an outermost-vs-nested rule; net-decl bare-decimal RHS to net width; raw string constants), const-fold for-loops that return on the first iteration (terminal-flag propagation in constCallFold) + arg-less fold UINT encoding, function-body unbased-unsized RHS sizing, and emitMixedHierPath (b.a[0].x mixed member/element-select hier_paths; lvalue vs rvalue bit_select forms differ). NEXT ENABLER: PACKAGE STRUCT/ENUM TYPEDEFS - emitPackage (src/ParamEmit.cpp) emits only params+task_funcs; it must also emit vpiTypedef struct_typespec/enum_typespec AND populate typedefTs. Golden shape (PackedArray): struct_typespec VpiName=pkg::struct_a, VpiParent=package, VpiInstance=package, vpiPacked:1, member ref fullname DOUBLED as pkg::pkg::struct_a::x. Unblocks ~8 packed-array-of-struct DIFF tests (PackedArray, StructPackedOutput, hier_path, StructOfArrayOfStructs, ...) plus the packed-array-of-typedef cluster (EnumArray needs packed_array_typespec with Elem_typespec ref to the shared package enum) and BitsCallOnVar; watch the weakly-tail typespec ordering. THEN interfaces (45: AllInterfaces design relation, interface_inst def+inst views, InterfacePort, ArbitrarySymbol member access). r107-r108: struct-typed function returns (struct_var + canonical-matched typedef; conditional file-struct design parent), nested member-access selects (bar.l[2][1] -> hier_path var_select), and module end labels. Converged func_struct_repro, DotRange, struct_array. NEXT: PACKED-ARRAY-OF-TYPEDEF (EnumArray/DotMultirange/gen_struct_access) needs (1) package typedefs added to typedefTs - emitPackage does NOT call emitTypedefs today, so package enums/structs are built inline not shared - and (2) a packed_array_typespec {Ranges + Elem_typespec ref to the shared typedef} in makeTypespec (code sketched then reverted as dead until package typedefs land). Then interfaces (46+46). r105-r106: file-level packed struct design-parent (struct_array) and file-level typedef source-order build with name-sorted list (simple_struct 202->86). NEXT: struct member access on packed-array-of-struct + struct-typed function returns (struct_var) unblock the struct DIFF cluster; then interfaces (46+46). A recurring blocker on several CMP_ONLY tests (simple_struct/array-copy/partsel_simple/BindModule) is the weakly-tail TYPESPEC ORDER - same object set, different arena position; a general fix to typespec creation order would convert several at once. r103-r104: compound assignments (+=/<<= -> op-typed assignment) and FILE-LEVEL packed/unpacked struct typedefs (buildStructTs on the design). NEXT tractable: struct-typed function returns (struct_var, func_struct_repro), struct member access on packed-array-of-struct (DotMultirange/DotRange/gen_struct_access), then interfaces (46+46, biggest untouched). Also: \x-sizing in blocking-assign is context-dependent (function sizes, always block does not - unresolved, reverted). r99-r102 landed the full property-expression emitter (implications/until/throughout/sequence-concat/not), default clocking blocks, and NET-DECLARATION ASSIGNMENTS (wire x = expr -> cont_assign; literal/op RHS -> fresh Lhs net + deferred typespec; general x->X uppercase for unbased-unsized). Converged sva_not, sva_throughout, sva_value_change_*, signed_partsel_ext. r96-r98 landed the property-expression emitter (emitAssertionExpr: implication/until/throughout/sequence-concat/not ops), default clocking blocks, assume/cover/restrict, and typed localparams (integer/byte/... _typespec). Converged sva_basic00/01/03, sva_value_change_rose, sva_throughout, sva_not. r95 landed concurrent assertions (folded assert_stmt: label, clocking-only property_spec for assert-with-clocking; via instance Assertions()/vpiAssertion, shared across instances like processes). NEXT for assertions: a recursive property-expression emitter (emitAssertionExpr) + assume/cover kinds - the exact rule + operator/opType tables are in NOTES.md "Concurrent assertion property-expr rule". Also landed r93-r94: assignment-pattern fold to based constant + numeric-index integer_typespec tags (PatternDefault/PatternIndexes converge). Session 5 third
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
