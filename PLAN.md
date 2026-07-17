# slang → UHDM Exporter: Implementation Plan

Status: PLANNED (research complete, implementation not started)
Date: 2026-07-17
Owner: heyfey

This document is self-contained: it captures the goal, all survey findings it
depends on, the design, the test/convergence strategy, and the day-to-day dev
flow. A fresh session (human or agent) should be able to pick up the work from
this file alone.

---

## 1. Goal

Make slang able to export UHDM databases (`.uhdm` files) equivalent to what
Surelog produces, so that slang can drive any downstream UHDM consumer.

Target flow:

```
slang ──(new: slang-uhdm exporter)──► design.uhdm ──► uhdm2rtlil ──► yosys
                                            └────────► sv-pathfinder navigation (followup)
```

**Success criterion (v1):** for a growing subset of the uhdm2rtlil test corpus,
the UHDM produced by `slang-uhdm` is *structurally identical* to the UHDM
produced by Surelog on the same source — verified by `uhdm-cmp` (exit 0) and an
empty normalized `uhdm-dump` diff. Identity with Surelog's output implies
uhdm2rtlil (and other consumers) work without testing yosys in the loop.

**Non-goals (for now):**
- Running uhdm2rtlil / yosys equivalence checks (deferred; identity with
  Surelog makes it redundant for correctness).
- Rebuilding sv-pathfinder's native addon against UHDM v1.86 (trivial
  `binding.gyp` change + `node-gyp rebuild`; deliberately the last step).
- Full Surelog parity (164 object types incl. classes/UVM/assertions);
  coverage is corpus-driven, synthesizable subset first.

## 2. Survey results (condensed)

Research performed 2026-07-17 across slang, Surelog, UHDM, uhdm2rtlil,
sv-pathfinder repos plus web prior-art.

### 2.1 Prior art
- No slang→UHDM producer exists anywhere. Proposed in
  [slang #304](https://github.com/MikePopoloski/slang/issues/304) (2020),
  closed unimplemented ("quite a huge undertaking").
- [yosys-slang / sv-elab](https://github.com/povik/yosys-slang) does
  slang→RTLIL directly (bundled in yosys ≥ v0.67) — the alternative when only
  RTLIL is needed. UHDM export is uniquely valuable for the *database*
  (navigation, interchange, non-yosys consumers).
- [synlig](https://github.com/chipsalliance/synlig) and
  [uhdm2rtlil](https://github.com/alainmarcel/uhdm2rtlil) are the UHDM→yosys
  consumers; both are written against Surelog-shaped UHDM.

### 2.2 Version matrix — THE interop constraint

UHDM's on-disk format is packed Cap'n Proto. The embedded version check is
coarse (`Serializer::kVersion == 1` strict equality), but the capnp schema is
regenerated whenever `model/*.yaml` changes → **a `.uhdm` file is only safely
readable by the same UHDM commit that wrote it.** Everything must link one
UHDM commit.

| Component | Commit/version | State |
|---|---|---|
| **UHDM (anchor)** | `5523dfc` = v1.86-31, `~/git-repos/UHDM` | built: `build/bin/{uhdm-dump,uhdm-cmp,uhdm-hier,uhdm-lint}`, `build/lib*.a` |
| Surelog (reference producer) | `cbdbea458c` = v1.86-114, pins UHDM `5523dfc`, `~/git-repos/Surelog` | built: `build/bin/surelog` |
| uhdm2rtlil | pins Surelog `cbdbea458c` (same!) + yosys v0.66 fork, `~/git-repos/uhdm2rtlil` | cloned, not built (not needed yet) |
| slang | `~/git-repos/slang` (this repo), master | built: `build/bin/slang` |
| sv-pathfinder addon | statically links UHDM **v1.84** (`~/git-repos/UHDM-1.84`) | mismatch; rebuild deferred to last step |
| stale v1.84 tools | `surelog`/`uhdm-dump`/`uhdm-cmp` under `~/git-repos/sv-tests/third_party/...` and `~/git-repos/UHDM-1.84/build/bin` | DO NOT USE — wrong version |

### 2.3 UHDM producer API (what the exporter calls)

- Umbrella header `#include <uhdm/uhdm.h>`; everything hangs off
  `UHDM::Serializer`.
- Factories per concrete type: `MakeDesign()`, `MakeModule_inst()`,
  `MakePort()`, `MakeLogic_net()`, `MakeConstant()`, `MakeOperation()`,
  `MakeRange()`, `MakeParameter()`, `MakeParam_assign()`,
  `MakeLogic_typespec()`, `MakeRef_typespec()`, … plus vector factories
  `Make<T>Vec()` / `MakeAnyVec()`. Objects are arena-owned by the Serializer.
- Setters named after VPI tags: `VpiName`, `VpiDefName`, `VpiFullName`,
  `VpiDirection`, `VpiOpType`, `VpiConstType`, `VpiValue`, `VpiFile`,
  `VpiLineNo/ColumnNo/EndLineNo/EndColumnNo`, `VpiSigned`, `VpiSize`, `VpiTop`,
  `VpiTopModule`, `VpiNetType`, … Parent links: `child->VpiParent(parent)`.
- Save: `serializer.Save(path)`. **GC caveat:** Save garbage-collects objects
  unreachable from a registered design — call
  `serializer.MakeUhdmHandle(uhdmdesign, design)` before `Save()`.
- `VpiValue()` string grammar (consumers parse the prefix — mandatory):
  `"INT:-3"`, `"UINT:42"`, `"BIN:1010"`, `"HEX:AA"`, `"OCT:7"`, `"DEC:12"`,
  `"REAL:1.5"`, `"STRING:foo"`. Unbased-unsized (`'0/'1/'x/'z`) =
  `VpiSize(-1)` + e.g. `"BIN:1"`.
- **`ref_typespec` indirection is mandatory:** objects never point at a
  `typespec` directly; they hold `ref_typespec` whose `Actual_typespec()`
  points to the real typespec.
- Two design views on `design`: `AllModules()` (+ `AllPackages`,
  `AllInterfaces`, `AllPrograms`, `AllClasses`, `Typespecs`, `Task_funcs`) =
  folded definitions; `TopModules()` (+ `TopPackages`) = instance tree. UHDM
  ships `ElaboratorContext`/`ElaboratorListener` that expands folded →
  fully-elaborated in-process (that is exactly what `surelog -elabuhdm` and
  sv-pathfinder's addon run).
- vpi tag/opcode definitions: `~/git-repos/UHDM/include/vpi_user.h`
  (`vpiAddOp` … at lines ~438-494), `sv_vpi_user.h` (SV extensions),
  `templates/uhdm_vpi_user.h` (UHDM-private: `vpiDesign=3000`,
  `vpiColumnNo=3015`, `vpiUnsupportedExpr/Stmt=400x`).
- Reference producer examples: `~/git-repos/UHDM/tests/module-port_test.cpp`
  (design→module→ports→save→restore), `tests/expr_reduce_test.cpp`
  (constants/operations/param_assigns), `tests/expr_prettyPrint_test.cpp`
  (ranges/typespecs/selects).

### 2.4 How Surelog produces UHDM (the reference)

- Assembler: `Surelog/src/DesignCompile/UhdmWriter.cpp` (5.3 KLOC), but object
  construction is spread over the whole pipeline: ~1223 `Make*` call-sites
  across `CompileExpression/CompileType/CompileHelper/NetlistElaboration/
  CompileStmt/ElaborationStep`, emitting **164 distinct object types**.
- Default `surelog -parse` output = **folded** model at
  `slpp_all/surelog.uhdm` (`uhdm-dump` prints "Restored design Pre-Elab").
- `-elabuhdm` additionally runs UHDM's own `ElaboratorListener`
  (`uniquifyTypespec(false)`, `listenDesigns`) + `UhdmAdjuster`; `UhdmLint`
  runs always. I.e. Surelog itself only ever *writes* the folded model;
  elaboration is shared library code.
- Naming convention: `work@<name>` on def names and as prefix of
  `vpiFullName` paths (e.g. `work@mux2.S`).

### 2.5 slang side (what the exporter reads)

- `slang::driver::Driver` gives standard CLI/compilation setup
  (`addStandardArgs`, `parseAllSources`, `createCompilation`); model:
  `tools/hier/hier.cpp`, `tools/reflect/`.
- Elaborated design: `Compilation::getRoot()` → `RootSymbol.topInstances`
  (instance tree), `Compilation::getDefinitions()` / `getPackages()`
  (definitions). Traversal via `ASTVisitor` / `makeVisitor`
  (`include/slang/ast/ASTVisitor.h`); every node kind dispatches through
  `Symbol::visit` / `Expression::visit` / `Statement::visit`.
- **The field-by-field spec of slang's AST is `ASTSerializer`**
  (`source/ast/ASTSerializer.cpp`, backs `--ast-json`): each node's
  `serializeTo` shows exactly what data exists. Use `slang --ast-json` output
  as the slang-side view when debugging a mapping.
- Instance dedup: identical instances share one `InstanceBodySymbol`;
  `InstanceSymbol::getCanonicalBody()`, `VisitFlags::Canonical` walks each
  unique body once. Disable-able via
  `CompilationFlags::DisableInstanceCaching` if it ever fights us.
- Source loc: `SourceManager` (`getFileName/getLineNumber/getColumnNumber`,
  `getFullyExpandedLoc`) → `VpiFile/VpiLineNo/...`. Full names:
  `Symbol::getHierarchicalPath()` (prepend `work@`). Attributes:
  `Compilation::getAttributes(...)`. Param values:
  `ParameterSymbol::getValue()` → `ConstantValue`.
- Types: `Type` hierarchy (`include/slang/ast/types/AllTypes.h`) —
  `ScalarType/PackedArrayType/FixedSizeUnpackedArrayType/EnumType/
  PackedStructType/UnpackedStructType/...`, `getCanonicalType()`,
  `getFixedRange()`, `isSigned()`, `isFourState()` → UHDM typespecs.
- CMake: tools live in `tools/`, one `add_subdirectory` in
  `tools/CMakeLists.txt`; object-lib pattern from `tools/reflect/CMakeLists.txt`;
  third-party deps via `external/CMakeLists.txt` (FetchContent w/
  `FIND_PACKAGE_ARGS`).

### 2.6 uhdm2rtlil consumption contract (why identity matters)

uhdm2rtlil (yosys plugin: `read_uhdm`, `read_sv`) requires effectively
**elaborated** UHDM: `TopModules()` with `VpiTop()==true`, hierarchy via
`module_inst->Modules()`; it distrusts `AllModules` types; if
`vpiElaborated` is unset it runs UHDM's `ElaboratorListener` itself. It
hard-codes Surelog conventions: `work@` prefix stripping, `VpiValue` prefix
grammar, `VpiSize(-1)` fill literals, `VpiAlwaysType`, sequential blocks as
`event_control` whose condition is `operation(vpiPosedgeOp/vpiNegedgeOp/
vpiEventOrOp)`, typespecs resolvable by UHDM `ExprEval::size()`. It handles
~50 `vpiOpType` codes and ~60 object types. Producing output *identical to
Surelog's* satisfies all of this by construction — that is the core strategy.

### 2.7 sv-pathfinder (followup context)

Two independent prongs: navigation (`.uhdm` via native addon:
`Restore()` + UHDM `ElaboratorContext` + VPI walk — no Surelog-specific
coupling) and schematic (always yosys+`read_slang`+`write_json`, never UHDM).
A slang-produced `.uhdm` drops into the navigation prong once the addon is
rebuilt against UHDM v1.86.

## 3. Design

### 3.1 Emission strategy: folded-first, reuse UHDM's elaborator

Match `surelog -parse` default output — the **folded** model — and treat
elaboration exactly as Surelog does: an optional post-pass running UHDM's own
`ElaboratorContext`/`ElaboratorListener` (+`UhdmAdjuster`) behind a
`--elabuhdm`-style flag.

Rationale: the convergence oracle is byte-level identity with Surelog. Surelog
never hand-writes the elaborated model; if our folded output is identical,
running the same shared elaborator code yields identical elaborated output for
free. This cuts the surface we must replicate roughly in half.

Consequence: for parameterized/generate-heavy designs the folded "definition"
view must match Surelog's shape (definitions with default/unresolved bits).
slang's AST is already per-parameterization, so building the folded view means
emitting from canonical bodies + `DefinitionSymbol` info. Expect this to be
the trickiest translation; study Surelog dumps of parameterized corpus tests
before designing that part (see §5 iteration loop — the corpus drives it).

### 3.2 Tool structure

New `tools/uhdm/` in this repo (binary `slang-uhdm`), object-lib CMake pattern:

```
tools/uhdm/
  CMakeLists.txt          # slang_uhdm_obj_lib + slang-uhdm exe, links slang::slang + uhdm
  uhdm_main.cpp           # Driver setup, flags: positional sources, -o out.uhdm, --elabuhdm, -d dump
  src/UhdmExporter.h/.cpp # top-level: design object, AllModules/TopModules assembly
  src/ModuleEmit.cpp      # module bodies: ports, nets, cont_assigns, instances
  src/StmtEmit.cpp        # processes, statements, event_control
  src/ExprEmit.cpp        # expressions, constants (VpiValue encoding), selects
  src/TypeEmit.cpp        # typespecs (+ ref_typespec wrapping, dedup map)
  scripts/converge.sh     # one-test compare harness (see §4)
  scripts/run_corpus.sh   # corpus scoreboard
  PLAN.md                 # this file
  NOTES.md                # running log: quirks replicated, known diffs, decisions
```

Core pattern: a visitor (modeled on `ASTSerializer`) + `SymbolMap`
(`slang::ast::Symbol*`/`Type*` → `UHDM::any*`) so cross-references (nets in
`ref_obj->Actual_group`, typespec sharing, port low-conns) resolve to the
one emitted object. Emit in **declaration/source order** everywhere —
`uhdm-cmp` and dump-diff are both order-sensitive.

### 3.3 Linking UHDM

Install the anchor UHDM once:

```bash
~/.local/bin/cmake --install ~/git-repos/UHDM/build --prefix ~/.local
```

Then in `tools/uhdm/CMakeLists.txt`: `find_package(UHDM CONFIG)` (provides
`uhdm::uhdm`; config lands in `~/.local/lib/cmake/UHDM`), with
`CMAKE_PREFIX_PATH=~/.local`. Gate the whole tool on `UHDM_FOUND` (or a
`SLANG_INCLUDE_UHDM` option) so the slang build never breaks for people
without UHDM. Do not FetchContent-build UHDM inside slang: the anchor commit
must stay the single source of truth. Record the commit (`5523dfc`) in the
CMake as a comment and in NOTES.md.

### 3.4 Core mapping table (folded model)

| slang | UHDM | Notes |
|---|---|---|
| `Compilation` | `design` | `VpiName("work@<top>")`; `MakeUhdmHandle` before Save |
| `DefinitionSymbol`+canonical `InstanceBodySymbol` | `module_inst` in `AllModules` | `VpiDefName("work@<name>")`, `VpiFullName`, file/line |
| top `InstanceSymbol`s (`RootSymbol.topInstances`) | `module_inst` in `TopModules` | `VpiTopModule(true)`/`VpiTop(true)` |
| child `InstanceSymbol` | `ref_module` / child `module_inst` | match Surelog's folded shape (observe dumps) |
| `PortSymbol` | `port` | `VpiDirection` 1/2/3, `VpiLowConn`→`ref_obj`→actual net, `VpiTypedef`→`ref_typespec` |
| `NetSymbol`/`VariableSymbol` | `logic_net`/`logic_var`/`int_var`/… | `VpiFullName` = `work@` path; `vpiNetType` (e.g. 48 for output reg — copy Surelog) |
| `ContinuousAssignSymbol` | `cont_assign` | Lhs/Rhs exprs |
| `ProceduralBlockSymbol` | `always`/`initial` | `VpiAlwaysType` (2=comb, 3=ff) |
| `TimedStatement`+`SignalEventControl` | `event_control` | condition = `operation(vpiPosedgeOp/vpiNegedgeOp/vpiEventOrOp)`, operand[0]=signal ref |
| `ExpressionStatement`/`BlockStatement`/`ConditionalStatement`/`CaseStatement`/`ForLoopStatement` | `assignment`/`begin`·`named_begin`/`if_stmt`·`if_else`/`case_stmt`+`case_item`/`for_stmt` | |
| `BinaryExpression`/`UnaryExpression`/`ConditionalExpression`/`ConcatenationExpression` | `operation` | op map below |
| `NamedValueExpression` | `ref_obj` | `Actual_group` → net/var/param |
| `IntegerLiteral` etc. | `constant` | `VpiConstType` + `VpiValue` prefix grammar + `VpiSize` |
| `ElementSelect`/`RangeSelect`/member access chains | `bit_select`/`part_select`/`indexed_part_select`/`hier_path` | |
| `ParameterSymbol` | `parameter` + `param_assign` | `Lhs`=parameter, `Rhs`=expr; resolved value in `VpiValue` |
| `Type` (via `getCanonicalType()`) | `logic/int/bit/enum/struct/union/packed_array/array_typespec` | always behind `ref_typespec`; ranges as `range{Left_expr,Right_expr}` |
| `GenerateBlockSymbol`(+array) | `gen_scope_array`→`gen_scope` | folded: outside-genblk logic in def |
| `PackageSymbol` | `package` in `AllPackages`/`TopPackages` | `work@<pkg>` |

Operator map (slang `BinaryOperator`/`UnaryOperator` → `vpiOpType`):
Add→`vpiAddOp`, Subtract→`vpiSubOp`, Multiply→`vpiMultOp`, Divide→`vpiDivOp`,
Mod→`vpiModOp`, Power→`vpiPowerOp`, BinaryAnd/Or/Xor/Xnor→`vpiBitAnd/Or/Xor/XnorOp`,
LogicalAnd/Or→`vpiLogAnd/OrOp`, Equality/Inequality→`vpiEq/NeqOp`,
CaseEquality/CaseInequality→`vpiCaseEq/CaseNeqOp`, WildcardEquality→`vpiWildEqOp`,
GreaterThan/GreaterThanEqual/LessThan/LessThanEqual→`vpiGt/Ge/Lt/LeOp`,
LogicalShiftLeft/Right→`vpiLShift/RShiftOp`,
ArithmeticShiftLeft/Right→`vpiArithLShift/ArithRShiftOp`;
unary Plus/Minus→`vpiPlus/MinusOp`, BitwiseNot→`vpiBitNegOp`,
LogicalNot→`vpiNotOp`, reductions→`vpiUnaryAnd/Nand/Or/Nor/Xor/XNorOp`;
ternary→`vpiConditionOp`, concat→`vpiConcatOp`, replication→`vpiMultiConcatOp`,
inside→`vpiInsideOp`, cast→`vpiCastOp`, assignment-pattern→`vpiAssignmentPatternOp`.
(Authoritative list: `~/git-repos/UHDM/include/vpi_user.h` + observe dumps.)

## 4. Test plan

### 4.1 Oracles (in escalating strictness)

1. **Loadability:** `uhdm-dump out.uhdm` exits 0 (implies `Restore()` works).
2. **Dump diff:** `diff <(uhdm-dump surelog.uhdm) <(uhdm-dump slang.uhdm)`
   after trivial normalization (strip the first "Restored design" banner
   line). File paths are identical because both compile the same source file.
   This is the *development* signal — diffs localize the missing/wrong object.
3. **`uhdm-cmp a.uhdm b.uhdm`** — structural (topographic) equality, exit 0 =
   pass. The *strict* per-test verdict.
4. **`uhdm-lint`** clean on our output (sanity, not identity).
5. Later (`--elabuhdm` mode): same 2+3 on elaborated outputs
   (`surelog -parse -elabuhdm` vs `slang-uhdm --elabuhdm`).

### 4.2 Corpus tiers

- **T0 (bring-up, ~20 tests):** `mux2`, `flipflop`, `simple_counter`, then
  hand-picked combinational/sequential singles from
  `~/git-repos/uhdm2rtlil/test/*/dut.sv`.
- **T1:** all single-module uhdm2rtlil tests without parameters, generate,
  interfaces, memories, packages.
- **T2:** full uhdm2rtlil corpus (710 `dut.sv` tests).
- **T3 (stretch):** `~/git-repos/Surelog/tests/` (703 designs),
  `~/git-repos/sv-tests/` (2346 files) for robustness (no-crash + loadable,
  not necessarily identical).

Surelog reference command (matches uhdm2rtlil's harness):
`surelog -parse -nobuiltin -nocache <files>` → `slpp_all/surelog.uhdm`.

### 4.3 Harness

- `tools/uhdm/scripts/converge.sh <dut.sv>`: runs both producers into a temp
  dir, prints the dump diff and the `uhdm-cmp` verdict. The inner-loop tool.
- `tools/uhdm/scripts/run_corpus.sh <corpus-glob>`: loops tests, classifies
  each as `PASS_CMP` / `PASS_DUMP` (diff empty but cmp≠0 — investigate) /
  `DIFF` / `CRASH` / `UNSUPPORTED` (exporter said so explicitly), writes
  `results.csv` + per-test artifacts. **The pass-rate over T2 is the
  convergence metric; track it in NOTES.md per milestone.**
- Regression guard: commit golden `uhdm-dump` outputs for a handful of T0
  tests under `tools/uhdm/tests/golden/`; CI-style script re-checks them so
  later features can't silently break earlier ones.
- On any `PASS_DUMP`-but-not-`PASS_CMP` disagreement, or suspected dump
  blind spots, spot-check with `uhdm-hier` and `--elabuhdm` dumps.

## 5. Dev flow: iterate & converge

### 5.1 Build commands (this machine)

- System cmake 3.26.5 is too old for slang — use `~/.local/bin/cmake`
  (3.31.10), parallelism `-j 4`.
- slang + exporter:
  `~/.local/bin/cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local && ~/.local/bin/cmake --build build -j 4 --target slang_uhdm`
  (incremental exporter-only rebuilds are fast; full slang lib builds once).
- Everything else is prebuilt (see §2.2 table). UHDM install to `~/.local`
  once (see §3.3).

### 5.2 The loop

1. Pick the simplest currently-failing corpus test (scoreboard sorts by dump
   diff size — small diff = one missing feature).
2. Read the dump diff; identify the missing/mis-shaped UHDM objects.
3. Consult: Surelog's emission for that construct (grep
   `Surelog/src/DesignCompile/` for the object type), the slang-side data
   (`build/bin/slang --ast-json -` on the test), and UHDM's model yaml
   (`~/git-repos/UHDM/model/<type>.yaml`) for available fields.
4. Implement the mapping; rebuild `slang_uhdm` only; rerun
   `converge.sh` on that test.
5. When `uhdm-cmp` passes: rerun the T0/T1 scoreboard (regressions!), commit
   with the test name in the message, update NOTES.md if a Surelog quirk was
   replicated (each quirk gets one NOTES.md line: what, why, where).
6. Every few features, rerun the full T2 scoreboard and record the pass-rate.

Debugging aids: `surelog -d uhdm` (textual writer debug), `uhdm-dump --elab`,
`slang --ast-json`, UHDM `visit_designs`, and `uhdm-cmp`'s object-type stats.

### 5.3 Milestones

- **M0 — scaffold:** `tools/uhdm` builds; emits an empty-but-valid design
  (`design` + handle + `Save`); `uhdm-dump` loads it. (≈1 day)
- **M1 — mux2 identical:** module, ports (+low_conn ref_obj, ref_typespec),
  logic nets, always block, event_control `@(*)`, ternary operation,
  assignment. Zero dump diff + `uhdm-cmp` pass vs Surelog. (the hard first
  climb — establishes naming, ordering, typespec shape, value encoding)
- **M2 — T0 green:** ~20 basic combinational/sequential tests `PASS_CMP`.
- **M3 — T1 ≥ 90%:** expressions/statements/processes broadly covered.
- **M4 — params, generate, structs/enums, packages, memories:** T2 pass-rate
  as the metric; expect a long tail.
- **M5 — `--elabuhdm` mode:** run UHDM `ElaboratorListener`+`UhdmAdjuster`
  in-process like Surelog; verify identity on elaborated dumps too.
- **M6 — flow closure (followups):** build uhdm2rtlil and run its
  `test_uhdm_workflow.sh` with slang-produced `.uhdm` (should be a formality
  given identity); rebuild sv-pathfinder addon against UHDM v1.86 and load a
  slang-produced navigation DB.

### 5.4 Risks & mitigations

- **Ordering mismatches** dominate early diffs → always emit in
  source/declaration order; fix ordering before content.
- **Surelog quirks/bugs** may need bug-for-bug replication for `uhdm-cmp`
  identity (e.g. odd typespec placement, `vpiNetType` choices). Replicate,
  and log each in NOTES.md. If a quirk is unreplicable-in-good-conscience,
  a documented normalization in the dump-diff (never in `uhdm-cmp`) is the
  fallback — keep the list short.
- **Folded-view reconstruction for parameterized designs** is the largest
  design unknown (slang is post-elaboration). Mitigation: corpus-driven —
  study Surelog dumps of parameterized tests before designing; M1–M3 don't
  need it.
- **GC eats objects** → single design root, `MakeUhdmHandle` before `Save`,
  and `uhdm-dump` loadability check in every converge.sh run.
- **Version drift** → never update `~/git-repos/UHDM` / `~/git-repos/Surelog`
  checkouts mid-project; anchor is UHDM `5523dfc` + Surelog `cbdbea458c`.
  Re-converge deliberately when bumping.
- **Scale** (Surelog: 1223 call-sites/164 types) → bounded by corpus-driven
  scope; `vpiUnsupportedExpr/Stmt` + explicit `UNSUPPORTED` exit for
  constructs beyond current coverage, so the scoreboard stays honest.
