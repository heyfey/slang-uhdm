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

---

# Part II: Convergence campaign

Goal: converge ALL uhdm2rtlil tests (710), then the Surelog repo suite
(~703 dirs), then sv-tests (~2346 files). Written 2026-07-17 after session 1
(r6 scoreboard: 14 PASS + 15 CMP_ONLY / 149 DIFF / 483 UNSUPPORTED /
44 SLANG_REJECT / 5 SURELOG_FAIL).

**Achievable universe: 661** = 710 minus SLANG_REJECT (44, slang correctly
refuses non-LRM code — terminal N/A) minus SURELOG_FAIL (5, no reference
golden — revisit only via functional uhdm2rtlil checks).
Definition of done per test: PASS (dump+cmp identical), CMP_ONLY accepted
only with a NOTES-documented ordering waiver, or a documented waiver for
Surelog defects we choose not to replicate.

## 0. Measured blockers (r6, full telemetry over all 483 UNSUPPORTED)

| Tests blocked | Feature |
|---|---|
| 182 | typespec generalization gap (OUR bug: implicit type with packed dims — `wire [7:0]` — plus typedef/named types) |
| 117 | function/system calls |
| 70 | member access (structs) |
| 53 | explicit conversions / casts |
| 49+9 | immediate + concurrent assertions |
| 47 | hierarchical references (hier_path) |
| 46 | interface ports |
| 46 | ArbitrarySymbol refs (genvars, package refs) |
| 31+30 | indexed/complex range selects; selects on non-simple bases |
| 24 | named blocks |
| ~20 | assignment patterns |
| <10 each | repeat, block-local decls, strings, byte/shortint/longint, break/continue, real, final |

DIFF class (149) sampling shows: parameters/param_assigns (`vpiParameter`
missing — parameter|generate appear in 253 dut.sv files), comma-separated
event lists (vpiListOp 37 vs our vpiEventOrOp), non-ANSI split
port+reg declarations, enums, unpacked arrays/memories.

## 1. Harness upgrades first (~half day, pays for itself immediately)

- Parallelize run_corpus.sh (xargs -P $(nproc/2)): round time ~25min → ~6min.
- Auto-triage script: cluster DIFF tests by first-divergence dump line +
  UNSUPPORTED tests by full feature list (the analysis done manually for
  this plan); emit a per-round priority table. Priorities then always come
  from data, not guesses.
- No-regression gate: run_corpus compares the PASS/CMP_ONLY set against the
  previous round's CSV; nonzero exit + named regressions.
- Golden suite growth: promote 1–2 representative tests per landed feature
  (target ~30 goldens); run tests/check_goldens.sh before every commit.

## 2. Feature phases (ordered by unlock count; recalibrate each round)

- **A. Mechanical unblocks** (~1 session, expected largest single jump):
  A1 typespec generalization — implicit-with-dims + typedefs via canonical
  type (182 tests); A2 comma event lists → vpiListOp; A3 non-ANSI split
  declarations; A4 named_begin (24); A5 indexed_part_select `+:`/`-:` (31)
  + general select bases (30); A6 small statements (repeat, empty,
  break/continue, block-local decls incl. begin-scope Variables, strings,
  remaining integer var kinds).
- **B. Parameters & casts** (~1 session, unlocks most of DIFF):
  B1 parameter/localparam + Param_assigns in both views, refs with
  Actual→parameter; B2 parameterized instances — STUDY FIRST: dump goldens
  of AdditionAsParameterInInstance etc. to learn Surelog's folded shape for
  specialized defs (the known design unknown; slang's per-parameterization
  bodies should actually help); B3 explicit conversions → vpiCastOp (53).
- **C. Calls & assertions** (~1 session): C1 system calls ($clog2, $bits,
  $signed/$unsigned, $display, $readmem*) → sys_func_call; C2 user
  functions/tasks (module Task_funcs + func_call/task_call, compile-time
  eval NOT needed — Surelog folded view keeps calls); C3 assert shapes.
- **D. Composite data** (~1 session): D1 enums (enum_typespec/const/var);
  D2 packed/unpacked structs + MemberAccess; D3 assignment patterns;
  D4 unpacked arrays/memories (array_net/array_var + Ranges).
- **E. Hierarchy+** (~1-2 sessions): E1 hier_path (47); E2 generate
  (gen_scope_array, genvars = most ArbitrarySymbol refs, genblk naming);
  E3 packages (All/TopPackages, pkg:: refs); E4 interfaces + modports +
  interface ports (46) — deepest feature, deliberately last.
- **F. Closure**: F1 weakly-tail ordering polish to flip CMP_ONLY → PASS;
  F2 remaining-DIFF triage + waiver list; F3 `--elabuhdm` mode (run UHDM
  ElaboratorListener + UhdmAdjuster in-process like Surelog, verify
  elaborated dumps too) — prerequisite for Stage 2 and sv-pathfinder.

Milestone targets (PASS+CMP_ONLY of 661): A → ≥200; +B → ≥350; +C → ≥450;
+D → ≥520; +E → ≥600; +F → ≥640 with a short waiver list.

## 3. Stage 2: Surelog repo suite (~703 dirs)

- Layout: tests/<Name>/ with <Name>.sl (raw surelog CLI args), dut.sv or
  multiple sources; many use `-elabuhdm` (needs F3) and `-d` debug flags
  (ignore). Runner `scripts/run_surelog_suite.sh`: parse .sl → surelog
  reference invocation as-is; map to slang-uhdm args (-D/-I/file lists/
  --top; ignore -mt/-d/cache flags), same classification as run_corpus.
- Tiers: T1 = single-file, non-UVM, surelog-exit-0 (target: ≥80% identical,
  100% no-crash); T2 = multi-file/libraries; T3 = UVM/class-heavy →
  classified N/A-UVM (outside the exporter's synthesizable mission; these
  exercise Surelog's bundled UVM, not the flow the user needs).
- Expect new shape territory: classes, UDPs/primitives, specify blocks,
  defparam/bind/config. Budget a larger waiver list; every waiver goes in
  NOTES with the golden evidence.

## 4. Stage 3: sv-tests (~2346 files)

- Metadata-driven runner: extract :name:/:tags:/:type:/:should_fail: from
  headers. Exclude should_fail (verify agreement instead: BOTH_REJECT
  when slang and surelog both error → counts as agreement) and UVM tags.
- Goals: (1) zero exporter crashes on everything slang accepts; (2) dump
  identity wherever surelog also succeeds; (3) publish an agreement matrix
  (slang vs surelog accept/reject/identical) — doubles as a compliance
  cross-check and will surface slang/Surelog discrepancies worth upstream
  reports.

### 4.1 Status 2026-10-14: measured agreement matrix

Measured on 2026-10-14 against the local sv-tests checkout at 579f6484
(2026-06-05), with slang-uhdm at 35ef17dcc (slang v12.0 545f88b2e) and the
pinned Surelog v1.87 0445655ee7 with its UHDM.  Runner and helpers:
`scripts/svtests/` (`svtests_matrix.py` runs and classifies,
`svtests_decode.py` and `svtests_firstdiff.py` cluster the non-identical rows,
`svtests_diff.sh` shows one row's dump diff).  Rows: `results/svtests/matrix.csv`
(one per test), `results/svtests/decode.csv` and `results/svtests/firstdiff.csv`
(the DIFFERENT rows' first differing object and first changed dump lines).

Method: every `tests/**/*.sv` (2346) is run through Surelog with sv-tests' own
`tools/runners/Surelog.py` recipe (`-nopython -parse -nonote -noinfo
-nowarning`, `-sverilog` for the black-parrot, basejump and ivtest tags,
`-lowmem` for black-parrot and rsd, `--top-module`, `-D`, `-I`, the `:files:`
list, the `uvm` tag prepending sv-tests' `third_party/tests/uvm/src/uvm_pkg.sv`)
with two changes: `-noelab` is dropped (a `-noelab` database is unelaborated
and never comparable with an exporter output, so parsing and preprocessing
tests are run elaborated like the rest) and `-noprecompiledcache` is added
whenever `uvm_pkg.sv` is a source (as `scripts/verify_golden.py` does; without
it Surelog substitutes its bundled 1800.2-2017 package, whose include records
point at a different tree, and the UVM rows compare two different libraries).
slang-uhdm gets the same sources, `-I`, `-D`, `--top`, `--sverilog` when
Surelog got `-sverilog`, and `--single-unit`.  Both write into the same work
directory, as the sweep harness lays it out.  A pair is IDENTICAL when
`uhdm-cmp` reads it equal and `uhdm-strictcmp` reads STRICT_EQUAL (the gate of
`tests/sweep.sh`), JUDGE_EQUAL when only `uhdm-cmp` does.  "Accept" is sv-tests'
own criterion for Surelog (`rc & 7 == 0` and a database) and rc 0 plus a
database for slang-uhdm.  The fence filter of the corpus campaign was applied
to every path (0 hits).  Wall time: about 50 minutes for the plain and UVM
tiers at 4 jobs, 15 minutes for the cores tier at 1 job.

| tier  |    n | IDENTICAL | JUDGE_EQUAL | DIFFERENT | BOTH_REJECT | SURELOG_ONLY | SLANG_ONLY | SLANG_CRASH | SURELOG_CRASH | TIMEOUT |
|-------|-----:|----------:|------------:|----------:|------------:|-------------:|-----------:|------------:|--------------:|--------:|
| plain | 1798 |      1153 |          23 |       203 |         287 |          121 |         10 |           0 |             1 |       0 |
| uvm   |  172 |       0 |         0 |       0 |        22 |          0 |      149 |           0 |             0 |       1 |
| cores |  376 |         0 |           0 |       356 |           6 |            6 |          0 |           1 |             7 |       0 |
| all   | 2346 |    1153 |        23 |     559 |       315 |        127 |      159 |           1 |             8 |       1 |

SURELOG_ONLY = Surelog accepted, slang-uhdm did not; SLANG_ONLY the reverse.

**Plain tier (1798 single-file tests, no cores, no UVM).**  On the 1469 tests
the suite marks legal, both tools accept 1376: 1151 IDENTICAL (83.6 %), 23
JUDGE_EQUAL (85.3 % together) and 202 DIFFERENT.  The 23 JUDGE_EQUAL rows
differ only in a location field (`col` 18, `line` 3, `endline` 2).  On the 329
tests the suite marks illegal, slang rejects 325 and Surelog 280: both accept
`chapter-6/6.5--variable_multiple_assignments.sv`,
`chapter-6/6.5--variable_mixed_assignments.sv` and
`chapter-16/16.10--sequence-local-var-fail.sv`, Surelog alone accepts 46 and
slang alone one.  The 121 SURELOG_ONLY rows split three ways: 44 illegal tests
Surelog accepts and slang rejects (the suite sides with slang), 31 legal tests
slang's front end rejects (3 the timescale rule "design element does not have a
time scale defined but others in the design do", 2 undeclared identifiers, 2
duplicate definitions, 2 method-argument types, the rest single type, port,
checker and hierarchical-name diagnostics; slang strictness, not the
exporter's), and 56 legal tests where the exporter wrote a database but exited
nonzero on an unsupported shape: `randsequence` 11, unpacked union typedef 8,
`<->` logical equivalence 6, procedural `deassign` 4, `randcase` 4,
associative-array typedef target 4, sequence `within`/match items 2, covergroup
class property 2, `bufif0` gate 2, and one each of a range-select base, blocking
and nonblocking event triggers, a timing control, an edge kind and a procedural
checker.  The 10 SLANG_ONLY rows are Surelog errors on legal SV (property
`disable iff`, static constraint blocks, interface-class casts and handles,
`$coverage` system calls, five hdlconvertor and two UVM-example tests).  8 legal
tests are rejected by both (`randsequence` and `type()` compare, four
hdlconvertor and two UVM-example tests, mostly test-setup faults).  Surelog
crashes (exit on signal 11) on `generated/hdlconv_std2017/hdlconvertor_std2017_p612.sv`.

The 203 DIFFERENT rows of the plain tier, by the first changed dump line
(`results/svtests/firstdiff.csv`; 96 fall in the clusters below, the rest are
singletons):

| rows | first difference (golden minus ours) |
|-----:|--------------------------------------|
|   12 | a macro-expanded or folded constant Surelog keeps in a system-call argument, dropped by us |
|   10 | class methods we list that Surelog omits (out-of-block or extern bodies) |
|    9 | interface or parameterized classes we list under the module that Surelog omits |
|    8 | classes we list in `allClasses` that Surelog omits |
|    4 | classes we list under the design that Surelog omits |
|    7 | sequence declarations not emitted |
|    6 | a deferred final assertion emitted as a process that Surelog omits |
|    6 | an initializer expression Surelog keeps, dropped by us |
|    5 | associative-array method calls as `hier_path` (`s.unique` vs `s` + `method_func_call`) |
|    5 | an intra-assignment delay or event control dropped |
|    4 | queue or array type and range attributes missing |
|    4 | the `process` class handle: `ref_var`/`unsupported_typespec` in Surelog, `class_var`/`class_typespec` in ours |
|   10 | `vpiNetType` missing on non-`wire` nets (scalared/vectored 3, `tri`/`wand`/`wor`/`supply` family 7) |
|    3 | a design-level task or function we list that Surelog omits |
|    3 | `x`/`z` letter case in binary constants (`1'bX` vs `1'bx`) |
|    3 | nets Surelog lists that we do not |
|    2 | clocking blocks not emitted |
|    2 | a `$display` call Surelog keeps, dropped by us |
|    3 | `string` typespec on a variable missing; 3 `time` typespec; 5 `int` typespec |

**Cores tier (376 tests built from `third_party/cores`).**  basejump_stl (360):
354 DIFFERENT with ONE cause, a package-qualified enum member used in a package
parameter (`bsg_dramsim3_pkg::e_ro_ra_bg_ba_ch_co` in the prepended
`bsg_dramsim3_*_pkg` files) that Surelog folds to a constant with the enum
typespec and we keep as a `ref_obj`, plus an `INT` value field on a parameter
constant; one fix clears the tier.  The other 6 basejump rows are slang-side
rejects (4 the timescale rule, 1 a `continuous assign form` the exporter does
not handle, 1 undeclared).  black-parrot (6) and rsd (1): Surelog v1.87 exits on
signal 11 within 0.1 s with the recipe's `-lowmem` (it runs without it); on the
same designs slang-uhdm fails with `basic_string::substr: __pos (which is 18) >
this->size() (which is 17)` on black-parrot (an exporter bug on a full SoC
design) and `member access base` on rsd.  tnoc (1): Surelog accepts, slang-uhdm
exits on signal 11 (an exporter crash).  ariane (5): both reject, the test's
include dirs miss `hpdcache_typedef.svh`.  rggen (1): both write a database
with errors (ours `expression kind: Invalid`).  fx68k and scr1: DIFFERENT, one
`hier_path` head each.

**UVM tier (172 tests on sv-tests' uvm-2020 fork).**  With `-noprecompiledcache` Surelog v1.87 does not compile sv-tests' uvm-2020 fork: 166 of the 172 runs write a database with errors (`EL0514` undefined variable 229 times over the logs, `CP0317` undefined type 61, `CP0332` a method not defined on the built-in `semaphore` 58, `UH0701` unsupported statement 20), 5 stop on a syntax error and 1 times out at 300 s single-threaded, so by sv-tests' own criterion no UVM pair is comparable.  slang-uhdm accepts 149 of the 172 and rejects 23 (6 the timescale rule, 4 `randcase`, 3 overrides of a built-in method, the rest single shapes or test-setup faults such as a missing file).  A first run without the guard let Surelog substitute its bundled 1800.2-2017 package: all 146 pairs both tools accepted then differed from the first include-file record on, a library mismatch and not an exporter result, which is why the guard is part of the recipe.  The corpus campaign's UVM rows (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg) give Surelog's bundled 1800.2-2017 UVM to both tools and are STRICT_EQUAL at HEAD.

**Tool-failure summary.**  slang-uhdm: 1 crash (tnoc), 1 `substr` exception
(black-parrot, 6 rows), 58 unsupported shapes with a database still written,
31 front-end rejects on suite-legal tests.  Surelog v1.87: 8 crashes (7 with
`-lowmem`, 1 on hdlconvertor p612), 1 timeout (`uvm_tb_build_ss_tb`, 300 s
single-threaded), 46 illegal tests accepted.

**Not covered by this measurement.**  The sv-tests expectation is only
accept/reject, so "identical" is measured against Surelog, not against the
standard; parsing and preprocessing tests ran elaborated (see Method); the
downstream gate (uhdm2rtlil) was not run on sv-tests; no test was excluded
except by the fence filter (0 hits).  Reproduce with:

```
scripts/svtests/svtests_matrix.py --svtests <sv-tests> --out matrix.csv \
    --workroot <work> --jobs 4 --tier plain,uvm --keep-golden
scripts/svtests/svtests_matrix.py --svtests <sv-tests> --out cores.csv \
    --workroot <work> --jobs 1 --tier cores --keep-golden
scripts/svtests/svtests_decode.py --svtests <sv-tests> --csv matrix.csv cores.csv \
    --workroot <work> --out decode.csv
scripts/svtests/svtests_firstdiff.py matrix.csv plain,cores firstdiff.csv <work>
```

## 5. After convergence (flow closure, from Part I)

Build uhdm2rtlil and run its test_uhdm_workflow.sh + triage_cosim.py with
slang-produced .uhdm on the converged corpus (expected formality); rebuild
sv-pathfinder's addon against UHDM v1.86 and load a slang-produced
navigation DB (the deliberately-last step).

## 6. Risks

- B2 parameterized-def folded shape may be the largest quirk cluster —
  study goldens before implementing.
- E4 interfaces are intricate in UHDM; uhdm2rtlil's importer tolerances
  may allow a waiver-first approach there.
- Some DIFFs will be genuine Surelog defects; the waiver policy keeps the
  "converged" claim honest without chasing bug-for-bug absurdities.
