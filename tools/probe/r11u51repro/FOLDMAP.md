# FOLDMAP — the fold DECISION, road by road

TRIAGE2's C2 (`tools/probe/r11u44repro/TRIAGE2.md:179`) held five tests
together on the claim that they share "one producer DECISION — when Surelog's
constant reducer runs". This map measures that claim and **refutes the
single-switch reading**: there is no one switch. There are **five producer
sites**, each with its own gate, and they fail in two different directions for
two different reasons.

What the five DO share is one principle, and it is the thing to implement
against:

> **The producer reduces WHOLE EXPRESSIONS at a small, named set of sites and
> substitutes the reduced OBJECT. It never rewrites a leaf inside an
> expression that survives.** Our emitter has no site model: it folds
> bottom-up, per node, wherever slang has a value.

Every one of the ten rows is a consequence of that mismatch. Our OVER-folds
(roads A, B-leaf, C) are nodes we reduced where no reduce site exists or where
the site's reduce refused. Our UNDER-folds (roads D, E) are reduce sites we do
not run at all.

All ten rows are `CMP_NOTEQUAL` in both modes at 24f51df9, one head each; the
per-row measurement is in [README.md](README.md) §2.

---

## The five roads at a glance

| road | corpus row(s) | producer site | golden | ours | class |
|---|---|---|---|---|---|
| **A** `$bits` of a type parameter | `bits_of_type_param` | `CompileHelper::compileBits`, `CompileExpression.cpp:4686` | KEEPS the `sys_func_call`, both views | folds `UINT:97` | **fold-to-remove** |
| **B** a leaf inside a package parameter's kept expression | `ibex_tracer` | package double-compile, `CompilePackage.cpp:63`/`:68` | keeps the `ref_obj` (+`vpiActual`) | substitutes the constant | **fold-to-remove** (leaf) |
| **C** a body typedef's ELEMENT bound | `mem_packed_2d_byte_write` | `CompileModule.cpp:653`/`:1130` → `CompileHelper.cpp:2278` → `:1060` | keeps `op11(ref_obj,1)` in every copy | folds, `vpiDecompile:"NDATA-1"` | **fold-to-remove** |
| **D** an elaborated pattern element's size | `StructParamFuncBodyFieldCompare` | the elaborated PACKAGE copy's `adjustSize` | re-sizes to the member width (32) | keeps the def-view size (64) | **fold-to-install** (size) |
| **E** an elaborated cont_assign's `hier_path` Rhs | `struct_param_pattern_packing` | `UhdmWriter::writeCont_assign`, `UhdmWriter.cpp:2090`, the `simplified == false` branch at `:2245` | substitutes the pattern element OBJECT | shares the def `hier_path` | **substitute-object** |

Four of the five heads are reproduced EXACTLY by a grid arm — blinded of ids,
locations and identifiers, the arm's `uhdm-cmp` head and the corpus row's are
the same md5 ([evidence/HEADID.txt](evidence/HEADID.txt)):

```
44b61f4b1117  a1_bits_argkind        == bits_of_type_param
6b045787b03a  b1_leafsubst_pkg       == ibex_tracer
ae8f00dab551  c1_typedef_mod         == mem_packed_2d_byte_write
4168f893816f  e1_ca_rhskind          == struct_param_pattern_packing
```

Road D's head is a constant-vs-constant `VpiSize` pair; `d1_cast_pkg`
reproduces the CELL (the 32-vs-64 size in the elaborated package) but a
different law — the pattern operation's missing `ref_typespec`, TRIAGE2's C5 —
fires first in that arm, so its head is its own. The cell table below is road
D's evidence.

---

## ROAD A — `$bits()` whose argument is a TYPE PARAMETER

### The producer, read line by line

`CompileHelper::compileBits` (`CompileExpression.cpp:4686`) is the only thing
that folds `$bits`. It does NOT obey the caller's `Reduce` flag: at
`:4752` it **upgrades itself**

```cpp
    tps = getTypespec(component, fC, typeSpecId, compileDesign, reduce, instance);
    if (m_elabMode && (reduce == Reduce::No) && tps) {
      UHDM::ExprEval eval;
      if (eval.isFullySpecified(tps)) {
        reduce = Reduce::Yes;
      }
    }
```

and mints the constant at `:4779-4785` — `UINT:<bits>`, decompile the bare
number, `vpiUIntConst`, **`VpiSize(64)`**. Everything therefore turns on
`getTypespec` (`CompileExpression.cpp:4414`). For a bare name it fills
`basename` and then, at `:4541`, looks in exactly two places:

```cpp
  if (dtype == nullptr) {
    if (component) dtype = component->getDataType(basename);   // the TYPEDEF map
  }
  if ((dtype == nullptr) && component) {                       // …then PORTS and SIGNALS
```

A **type parameter** and a **`localparam type`** are in neither map — they live
in the parameter table — so `tps` stays null, the upgrade cannot fire, `Bits()`
is never called, and the final `else` at `:4805` emits a `sys_func_call
($bits)`. That is true in the definition compile AND in the elaborated one,
which is why golden keeps the call in both views.

### The golden grid (`a1_bits_argkind`, `a2_bits_holder`, `a3_bits_iface`)

Argument kind, one holder (a body localparam), both views. The last three
cells are the POSITIVE CONTROL — same construct, same holder, same view, and
there golden and ours agree byte for byte.

| argument | golden DEF | golden ELAB | ours DEF | ours ELAB |
|---|---|---|---|---|
| `$bits(TP)`, `parameter type TP` | **KEEP** | **KEEP** | fold | fold |
| `$bits(TL)`, `localparam type TL` | **KEEP** | **KEEP** | fold | fold |
| `$bits(loc_t)`, module-local `typedef pk::req_t loc_t` | **KEEP** | fold | fold | fold |
| `$bits(pk::req_t)`, package struct typedef | fold | fold | fold | fold |
| `$bits(pk::byte_t)`, package scalar typedef | fold | fold | fold | fold |
| `$bits(logic [9:0])`, built-in keyword | fold | fold | fold | fold |
| `$bits(TP)` in an INTERFACE body | **KEEP** | **KEEP** | fold | fold |

Holder is **not** a gate. `a2_bits_holder` puts the same `$bits(TP)` in five
holders — parameter-port-list Rhs, port range bound, body localparam Rhs, net
range bound, function-body `return` — and golden keeps the `sys_func_call` in
all five; we fold in all five.

`bits_of_type_param`'s own source carries the control in the same module:
`parameter int DATA_WIDTH = $bits(req_t)` (type parameter) vs `localparam int
DIRECT = $bits(pk::req_t)` (package typedef). Golden keeps the first in both
views and folds the second in both — `UINT:97` at **64** in the definition
listing (compileBits' own mint) and at **32** in the elaborated one (the
parameter's `int` width). Our DIRECT matches golden in both views, field for
field including the `ref_typespec -> int_typespec`; only DATA_WIDTH differs.

### Our side

[src/ExprEmit.cpp:3840](src/ExprEmit.cpp#L3840) `UhdmExporter::srlgBitsFoldArg`
already models this producer — its own comment says "folds only when
`getTypespec()` resolves the argument to a FULLY SPECIFIED typespec, and
`getTypespec` looks in exactly three places: the built-in type keywords, the
component's DATA TYPES (typedefs), and its PORTS and SIGNALS." The
TYPE-PARAMETER case is the hole: the very first branch,

```cpp
    if (arg.kind == ExpressionKind::DataType)
        return srlgFullySpecType(*arg.type, 0);
```

answers on the RESOLVED type. slang resolves `TP` to `pk::req_t`, the struct is
fully specified, and the call folds. The call sites that consult it are
[src/ExprEmit.cpp:27402](src/ExprEmit.cpp#L27402) and
[src/TypeEmit.cpp:16082](src/TypeEmit.cpp#L16082).

**Brief.** In `srlgBitsFoldArg`'s `DataType` branch, refuse when the argument's
SYNTAX names a type parameter or a `localparam type` of the enclosing scope
(slang: a `TypeParameterSymbol`, or a `TypeAliasType` whose declaring symbol is
one) — the name the producer would have to find in `component->getDataType`
and cannot. Do NOT decide on the resolved type. The grid's W3 cell
(`typedef pk::req_t loc_t` — golden keeps in the DEF view and folds in the
ELAB view) is a second, view-dependent cell on the same road; `srlgBitsFoldArg`
already takes an `elabView` argument, so it has somewhere to put it, but it is
a separate cell and wants its own arm before it is written.

**Blast radius.** Seven test directories in the two corpora declare a
`parameter type`/`localparam type` and call `$bits`: `bits_of_type_param` (the
NE row), `cva6_equiv`, `ibex`, `param_type_logic_width`,
`type_param_override_elem_sel`, `type_param_packed_dim` and Surelog's
`ClassScope`. Six of those are the boundary.

---

## ROAD B — a leaf inside a package parameter's SURVIVING expression

### The producer

`FunctorCompilePackage::operator()` (`CompilePackage.cpp:61-71`) compiles every
package **twice**:

```cpp
  instance->compile(Reduce::Yes);                       // the ELABORATED copy  -> uhdmtopPackages
  instance = new CompilePackage(…, m_package->getUnElabPackage(), …);
  instance->compile(Reduce::No);                        // the DEFINITION copy  -> uhdmallPackages
```

and `CompilePackage::compile` sets `m_helper.setElabMode(reduce ==
Reduce::Yes)` at `:80` — the same `m_elabMode` road A's `compileBits` consults.

The measured behaviour of the `Reduce::Yes` pass is **all-or-nothing on the
whole Rhs**.

### The golden grid (`b1_leafsubst_pkg`, `b2_leafsubst_mod`, `b3_leafsubst_ca`)

`b1` — four package parameters reading `pk::C0`/`pk::C3` from INSIDE the
package:

| package parameter | golden DEF | golden ELAB | ours DEF | ours ELAB |
|---|---|---|---|---|
| `R = {3'b000, 11'b0, {C0}}` (whole expr reducible) | `ref_obj` | **`ref_obj`** | `ref_obj` | constant |
| `X = {3'b000, 11'h?, {C0}}` (not reducible) | `ref_obj` | **`ref_obj`** | `ref_obj` | constant |
| `Y = {3'b010, 11'h?, C0}` (not reducible) | `ref_obj` | **`ref_obj`** | `ref_obj` | constant |
| `S = C3` (the whole Rhs IS the reference) | `ref_obj` | **constant** `2'b11`@2 | `ref_obj` | constant |

So golden replaces the Rhs only when the WHOLE Rhs collapses to one constant,
and it keeps the leaf `ref_obj` — with its `vpiActual` pointing at the
referenced parameter's own constant — inside every expression that survives.
`R` proves the rule is not "reducible or not": `R` reduces perfectly well and
golden still keeps the operation and the leaf.

`b2` (the same shapes as MODULE-BODY localparams) and `b3` (as cont_assign
Rhss) both show the asymmetry vanishing: at module scope both producers fold
the whole concat, and on a cont_assign both producers already have a constant
at the leaf in both views (`b3` is `cmp_rc=0`, judge-equal). **Road B is
specific to a package parameter read from inside its own package.**

`ibex_tracer`'s head is exactly `b1`'s: `parameter logic [15:0] INSN_CADDI4SPN
= { 3'b000, 11'h?, {OPCODE_C0} };` — golden's elaborated package keeps
`ref_obj (ibex_tracer_pkg::OPCODE_C0)` with `vpiActual -> constant 9:37`; we
put `BIN 2'b00`@2 there. Golden keeps the `ref_obj` in all four of its copies
(unelab package, elab package, and the module's two imported copies); we keep
it only in the unelab package.

### Our side

The package parameter emitter is
[src/ParamEmit.cpp:24213](src/ParamEmit.cpp#L24213) `emitPackage(pkg, topView)`
over [src/ParamEmit.cpp:5173](src/ParamEmit.cpp#L5173) `emitParams(…, topView,
…, inPackage, …)`; `inPackage && topView` is the elaborated copy. That is where
the leaf substitution happens.

**Brief.** In the `inPackage && topView` arm, substitute a constant for a
parameter reference **only when the reference is the whole Rhs**. A reference
that is an operand of an operation that survives must stay a `ref_obj` with its
`vpiActual` bound to the referenced parameter's constant. Note the shape golden
writes for the whole-Rhs case (`b1`'s `S`): the constant carries a
`ref_typespec` to the declaration's own `logic_typespec`, which the existing
`pkgElabComputed` machinery at
[src/ParamEmit.cpp:5963](src/ParamEmit.cpp#L5963) already builds.

**Warning — this closes a head, not a row.** `ibex_tracer`'s order-blind
whole-dump residue is **17389 golden-only / 4148 ours-only** lines, dominated by
families that have nothing to do with the fold (948 golden-only `range`s, 744
`logic_typespec`s, 437 ours-only `tagged_pattern`s, 276 ours-only `enum_const`
lines). The leaf substitution accounts for 326 of the golden-only lines. Road B
moves `ibex_tracer` to a new head; it does not convert it.

---

## ROAD C — a body typedef's ELEMENT typespec bound

### The producer

```
CompileModule.cpp:653   paData_declaration, module body     -> compileDataDeclaration(…, Reduce::No, …)
CompileModule.cpp:1130  paData_declaration, interface body  -> compileDataDeclaration(…, Reduce::No, …)
CompileHelper.cpp:2263  compileDataDeclaration(…, Reduce reduce, …)
CompileHelper.cpp:2278    case paType_declaration: compileTypeDef(…, reduce, nullptr)
CompileHelper.cpp:501     compileTypeDef
CompileHelper.cpp:1060      compileTypespec(scope, fC, stype, compileDesign, reduce, array_tps, …)
```

The `Reduce::No` is **hard-coded** — it is not `m_instance != nullptr ?
Reduce::Yes : Reduce::No` the way the parameter cases two dozen lines below it
are. So the ELEMENT typespec's bounds never reduce, in any copy. The wrapper
`array_typespec`'s own unpacked bound is a different object built per instance
and DOES fold there.

### The golden grid (`c1_typedef_mod`, `c2_typedef_pkg`, `c3_typedef_iface`)

`c1` puts five shapes in one module body:

| declaration | golden | ours |
|---|---|---|
| `typedef logic [NDATA-1:0][DATA_SIZE-1:0] mem_t [DEPTH];` | keeps `op11(ref_obj,1)` at BOTH packed bounds, 3 copies each | folds all 6 |
| `typedef logic [NDATA-1:0] up1_t [DEPTH];` | keeps, 3 copies | folds |
| `typedef logic [NDATA-1:0] pk1_t;` (no unpacked dim) | keeps | **keeps** |
| `struct packed { logic [NDATA-1:0] f; } st_t` | keeps | **keeps** |
| `logic [NDATA-1:0] plain;` (net declaration) | keeps | **keeps** |
| `input logic [NDATA-1:0][DATA_SIZE-1:0] wdata` (port) | keeps | **keeps** |

The trigger is therefore narrow and exact: **a typedef that carries an UNPACKED
dimension**, whose element becomes a separate typespec object under the
`array_typespec` wrapper. `c3_typedef_iface` reproduces it on the interface-body
twin (`CompileModule.cpp:1130`): golden keeps `NDATA` on `pk1_t`'s element
bound, we fold; the plain `pl1_t` beside it agrees.

`c1`'s head is `mem_packed_2d_byte_write`'s head, md5-identical blinded — same
`vpiDecompile:"NDATA-1"` carrying `UINT:1` at 64 on our side.

### Our side

[src/TypeEmit.cpp:12538](src/TypeEmit.cpp#L12538) and
[src/TypeEmit.cpp:13295](src/TypeEmit.cpp#L13295) already have the symbolic
path, behind the flag `unfoldedTypedefDims`:

```cpp
                if (unfoldedTypedefDims && hi9 && lo9) {
                    …
                    r9->Left_expr((UHDM::expr*)emitSyntaxExpr(*hi9, r9));
                    r9->Right_expr((UHDM::expr*)emitSyntaxExpr(*lo9, r9));
```

otherwise the local `mk9` lambda mints the folded `UINT` constant. The flag is
set in exactly one place —
[src/UhdmExporter.cpp:4178](src/UhdmExporter.cpp#L4178) — and only for a
**class** typedef.

**Brief.** Set `unfoldedTypedefDims` (with the same `syntaxRefPrefix` /
`bypassTypedefShare` save-and-restore the class arm uses) for a
MODULE-BODY or INTERFACE-BODY typedef whose declared type carries an unpacked
dimension, i.e. on the `buildUnpackedArrayTypedefTs` route at instance scope.
The name-prefix cell has to be measured, not guessed: golden writes the element
bound's `ref_obj` as bare `NDATA` in one copy and `mem_t.NDATA` in the other two
(`c1` golden, `evidence/GRID.txt` ROAD C).

**Blast radius: three test directories** in the two corpora match
`typedef … ] <name> [` — the smallest surface of the five roads.

**Warning — this closes a head, not a row.** `mem_packed_2d_byte_write`'s
residue is 120 golden-only / 35 ours-only lines. About 110 of the 120 are the
fold. The rest is:
  * `|vpiNetType:36` missing from our `logic_net (work@dut.mem)` — golden
    stamps it on all eight nets, we stamp seven (`net::Compare` reads
    `VpiNetType`, so this is judged);
  * a doubled hier-path segment: golden `work@dut.mem.mem.i` /
    `work@dut.wdata.wdata.i`, ours `work@dut.mem.i` / `work@dut.wdata.i` (the
    loop index under the memory select at 27:49 and 27:71);
  * one extra golden copy of the array's own `[DEPTH]` bound operation.

---

## ROAD D — an elaborated PACKAGE pattern element's size

### What it is NOT

TRIAGE2's C2 table reads "golden DROPS the `unsigned'()` wrapper, constant
under an `operation` at size 32 / we keep `sys_func_call ($unsigned)`, size
64". **That framing is wrong and the grid says so.** Both databases carry the
`sys_func_call`; both databases have the tagged pattern's `Pattern` pointing at
the CONSTANT, not at the call (the call survives only as the constant's stale
`vpiParent`, which no generated `Compare` reads). The head is
`expr::Compare`'s `VpiSize` — golden 32, ours 64 — on the elaborated package
copy of `cfg_pkg::Base`:

```
LHS (golden, elab package)              RHS (ours, elab package)
\_constant: , line:30:23                \_constant: , line:30:23
  |vpiParent: \_operation: 29:32..32:37   |vpiParent: \_sys_func_call: ($unsigned)
  |vpiDecompile:64                        |vpiDecompile:64
  |vpiSize:32                             |vpiSize:64
```

The DEFINITION package copy is identical on both sides (64 and 64).

### The golden grid (`d1_cast_pkg`, `d2_cast_mod`)

`d1` — four wrapper kinds as elements of one package `localparam four_t Q`,
every member `int unsigned` (32 bits):

| element | golden DEF | golden ELAB | ours DEF | ours ELAB |
|---|---|---|---|---|
| `A: unsigned'(64)` | 64 | **32** | 64 | **64** |
| `B: $unsigned(64)` | 64 | **32** | 64 | **64** |
| `C: 32'(64)` | 32 | 32 | 32 | 32 |
| `D: 64` (bare literal, control) | 64 | **32** | 64 | **64** |

The wrapper is irrelevant: the BARE LITERAL moves too. What the elaborated
package copy does is **re-stamp every pattern element to the struct member's
width and re-parent it to the pattern operation**. `C` agrees only because
`32'(64)` was already 32.

`d2` puts the same four elements in a MODULE-BODY localparam — and there both
producers re-stamp to 32 in the elaborated view. **Road D is a package-scope
gap in our emitter, not a missing law.** The only residual difference in `d2`
is the constants' SPANS (golden spans the literal `9:20`, we span the whole
call `9:10`), which no `Compare` reads.

`e3_ca_structparam`'s head is the same law one notch along: a pattern element
written as an EXPRESSION (`n: K + 1`) is a folded `constant 4`@64 in golden's
elaborated package where we still carry the `operation`.

### Our side

Same home as road B: [src/ParamEmit.cpp:5173](src/ParamEmit.cpp#L5173)
`emitParams`, the `inPackage && topView` arm. The module-scope path already
does the adjust; the package path does not.

**Brief.** In the elaborated PACKAGE copy, walk the assignment-pattern
operation's operands and re-stamp each element constant to its
`typespec_member`'s width (and re-parent it to the operation), exactly as the
module-body path already does. A pattern element that is still an `operation`
must be reduced first (`e3`).

**Warning — this closes a head, not a row.**
`StructParamFuncBodyFieldCompare`'s residue is **345 golden-only / 339
ours-only** lines and the bulk of it is TRIAGE2's C3: the anonymous
`localparam type it_t = struct packed {…}` — golden's `struct_typespec` spans
`42:26..42:32` and is UNNAMED, ours spans `42:26..45:4`. Ten ours-only
`hier_path (Cfg.XLEN)` lines per copy are road E's law at module scope inside
the `INT` localparam. Road D alone moves this row's head to C3.

---

## ROAD E — the elaborated cont_assign's Rhs

### The producer

`compileContinuousAssignment` (`CompileHelper.cpp:2418`) compiles the Rhs with a
**hard `Reduce::No`** at `:2499`, so the definition listing always carries the
written expression — on both sides, and ours already agrees there.

The fold is in `UhdmWriter::writeCont_assign` (`UhdmWriter.cpp:2090`), which
runs over `netlist->cont_assigns()` — i.e. **per elaborated instance**. After
the pattern-flatten attempts, at `:2245`:

```cpp
      if (simplified == false) {
        …
        any* res = m_helper.reduceExpr((expr*)rhs, invalidValue, mod, …, assign, true);
        if (invalidValue == false) {
          if (res && (res->UhdmType() == uhdmconstant)) {
            …clone the assign…
            res = m_helper.adjustSize(tps, mod, …, (constant*)res, true);
            …
            assign->Rhs((constant*)res);
```

Three facts fall out of the code and the grid confirms each:
1. this block is **outside** the `lhs->UhdmType() == uhdmref_obj` test above it,
   so the LHS kind is not a gate;
2. it does not inspect the Rhs kind either — a `hier_path` goes in like
   anything else;
3. `reduceExpr` RETURNS the object the value came from, which is why golden's
   substituted constant is stamped with the LITERAL's source location.

### The golden grid (`e1_ca_rhskind`, `e2_ca_lhskind`, `e3_ca_structparam`)

`e1` — one holder, five Rhs kinds, elaborated view:

| Rhs | golden | ours |
|---|---|---|
| `CFG.n` — `hier_path` over a struct parameter | **constant** `3`@32, loc = the package literal | shares the def `hier_path` |
| `CFG.base` — `hier_path`, 64-bit member | **constant** | shares the def `hier_path` |
| `PW` — `ref_obj` to a scalar parameter | constant `7`@32 | **constant, identical** |
| `PW + 1` — operation | constant `8`@32 | **constant, identical** |
| `a_i[31:0]` — non-constant (control) | keeps | keeps |

**The distinguisher is the `hier_path` Rhs, nothing else.**

`e2` — one Rhs (`CFG.n`), five LHS kinds: plain named net, bit-select,
part-select, unpacked-array element, signed net. **Golden folds all five.** We
fold one (the unpacked-array element, and with a location-less constant). This
also settles [tools/probe/r11u27repro/README.md:407](tools/probe/r11u27repro/README.md#L407)
R0's open question the other way: our `caLhsAdjustBind106` NamedValue fence has
no counterpart in the producer for THIS block — `writeCont_assign` fills `tps`
from a whole-name Lhs only, but the reduce itself runs regardless and
`adjustSize` with a null `tps` simply leaves the size alone.

`e3` — which object: golden's substituted constant for `CFG.n` carries
`line:8:32`, the literal `3` inside `localparam cfg_t LIT = '{n: 3, …}`, and
for `CFG2.n` (written `n: K + 1`) it carries `line:9:32`, the start of that
element's expression, with the value already reduced to 4. Each cont_assign
gets its OWN clone of that constant (`clone_tree` at `:2270`), so this is
substitution of the source object's clone, not sharing.

### Our side

[src/ModuleEmit.cpp:25883](src/ModuleEmit.cpp#L25883)
`UhdmExporter::emitContAssigns(…, bool topView, …)`, and the SHARE decision at
[src/ModuleEmit.cpp:27574](src/ModuleEmit.cpp#L27574): when the Lhs is a plain
NamedValue and none of `containsOperation / literalRhs / enumRhs / cfr /
callFold / ovParamRhs / typedParamRhs / constVarRhs / pkgParamSel /
unpackedParamSel / noDefOvRhs / paramPartSelRhs / structParamSetter` fires, the
elaborated listing pushes `defInfo->contAssigns[myIdx]` — the DEFINITION
object, `hier_path` and all. A struct-parameter field read sets none of them.

**Brief.** Add a predicate for "the Rhs is a constant-valued read of a
parameter's FIELD (a `MemberAccessExpression` chain bottoming on a
`SymbolKind::Parameter`)" to that list, so the elaborated view emits a fresh
cont_assign; the Rhs is then the folded constant, sized by `adjustSize` against
the Lhs declaration's width (the existing `caLhsAdjustBind106` width, 32 for
`logic [31:0] o_n`) and located at the source of the value —
which for a struct parameter bound to a package localparam is the pattern
element's own literal, a location our emitter must therefore carry from the
parameter's pattern, not from the read. `e2` says the LHS-kind fence must NOT
be applied here; that is the widening this road needs and the one that makes it
risky.

**Blast radius: 20 test directories** in the two corpora declare a struct-typed
parameter and read a dotted name on a cont_assign (15 in uhdm2rtlil, 5 in the
Surelog suite); 18 of them are currently judge-equal. This is the widest
boundary of the five roads and the reason road E is ranked below C and A
despite being the cleanest law.

**Warning — this closes a head, not a row.**
`struct_param_pattern_packing`'s residue is **303 golden-only / 19 ours-only**
lines, and the golden-only bulk is a `struct_typespec (p::cfg_t)` at
`21:38..21:43` — the FUNCTION ARGUMENT `cfg_t C` of `p::in_region` — carried
with seven copies, its `typespec_member`s, its `param_assign`s and its
`vpiRefFile` stamps, none of which we emit. The fold is a small fraction of
that row.

---

## Ranking — tests per fix, and what each one actually buys

Ranked by (rows the head clears) ÷ (boundary risk × residue behind it).

| rank | road | rows at the head | boundary dirs | residue behind the head | verdict |
|---|---|---|---|---|---|
| 1 | **C** — body typedef element bound | 2 | **3** | 10 lines + 1 `vpiNetType` + a doubled hier-path segment | smallest surface, flag already exists, one site |
| 2 | **A** — `$bits` of a type parameter | 2 | 7 | ~35 lines (`type_parameter` objects, the `data_t` typespec triple) | one predicate in a function written for this producer |
| 3 | **D** — elaborated package pattern element size | 2 | package-scope struct localparams | C3 (60 lines, shared with two more tests) | the module path already does it; port it to the package path |
| 4 | **E** — elaborated cont_assign `hier_path` Rhs | 2 | **20** | 300 lines (a whole missing function-argument typespec family) | cleanest law, widest boundary, largest residue |
| 5 | **B** — package-parameter leaf substitution | 2 | 10 | **17389 lines** | closes a head on the corpus's most distant row |

**Dispatch order.** C first (three directories can be swept exhaustively, and
the emitter already has the switch). A second (the predicate is local and the
control is in the same source file as the failure). D third — and D and B share
one home (`emitParams`' `inPackage && topView` arm), so whoever takes D should
read B's brief at the same time. E last of the reducible four: its law is the
best understood of the five and its boundary is the one most likely to move 18
equal rows.

**None of the five converts its row on its own.** Every row carries a second
family behind the head; the residue paragraph under each road quotes it. The
honest expected yield of all five roads landed is *five heads cleared and zero
to two conversions* — `bits_of_type_param` (83 ours-only lines, ~35 of them not
the fold) and `mem_packed_2d_byte_write` (35 ours-only lines, 3 residues) are
the only two within reach of a second small pass.

---

# VERIFIER CORRECTION BLOCK (r11v51)

*Adversarial verification of this map at `24f51df9`. The verifier built its own
pristine binary from a fresh worktree — `cmake --build build -j 2`, md5
`9be297f87ce752ca318a4d32b204ebe9`, identical to the main tree's — re-measured
all ten corpus heads, re-ran all fifteen arms, and then cut **eight new arms /
about fifty new cells** on roads the pass did not reach. Everything below was
measured on real v1.87 goldens (pinned Surelog `0445655ee7`), every arm's rc
recorded on both sides.*

## V0. What reproduced, bit for bit

* **The ten heads.** `bits_of_type_param` 56/56, `ibex_tracer` 36/36,
  `mem_packed_2d_byte_write` 56/56, `struct_param_pattern_packing` 52/52,
  `StructParamFuncBodyFieldCompare` 36/36 cmp lines, ONE head each, `cmp rc=255`
  each, both modes — and each of the five committed `evidence/heads/*.cmp` files
  is byte-identical (workdir-normalised) to the verifier's own re-measurement.
* **All fifteen arms.** Every `golden_rc`, `ours_rc`, `cmp_rc`, head count and
  cmp-line count in README §4 reproduced exactly, and every committed
  `grid/*/cmp.base.err` is byte-identical to the verifier's regenerated
  `cmp.v.err` after the same `<GRID>/` path rewrite. `b3_leafsubst_ca` really is
  `cmp_rc=0` / `heads=0`.
* **All four head identities.** `44b61f4b1117`, `6b045787b03a`, `ae8f00dab551`,
  `4168f893816f` recomputed from the verifier's own dumps.
* **All five residue totals.** 1398/1461/20/83, 181873/168632/17389/4148,
  2445/2360/120/35, 3204/2920/303/19, 3061/3055/345/339.
* **The producer citations.** `compileBits` at `CompileExpression.cpp:4686`, the
  self-upgrade `if (m_elabMode && (reduce == Reduce::No) && tps)` at `:4752`,
  the mint at `:4779-4785` with `VpiSize(64)`, `getTypespec` at `:4414` with the
  typedef-map lookup at `:4541-4542`; `CompilePackage.cpp:63`/`:68`/`:80`;
  `CompileModule.cpp:653` and `:1130`, `CompileHelper.cpp:2263` → `:2278` →
  `:1060`; `UhdmWriter.cpp:2090` and the `simplified == false` branch at `:2245`
  (verified to sit OUTSIDE the `lhs->UhdmType() == uhdmref_obj` block, which
  closes at `:2177`), `clone_tree` at `:2270`,
  `CompileHelper::compileContinuousAssignment` at `:2418`.
* **The judged fields.** `expr::Compare` reads `VpiDecompile` then `VpiSize`
  (`UHDM/build/generated/src/expr.cpp:90` and `:95`) — so correction 1 in
  README §6 is right that `StructParamFuncBodyFieldCompare`'s head is a SIZE.
  The missing `vpiNetType:36` is judged: `nets::Compare` reads `VpiNetType`
  (`UHDM/build/generated/src/nets.cpp:277`) — note the class is `nets`, not
  `net`.

## V1. FINDING — ROAD B's GATE IS THE CONCATENATION, NOT "THE WHOLE Rhs IS THE REFERENCE"

**This is a refutation, and it is the one correction that must land before any
pass implements road B.** `b1` contains only concatenations and one bare
reference, so it cannot separate *"golden substitutes only a bare reference"*
from *"golden substitutes everything except a concatenation"*. Two new arms
separate them, and the second reading wins.

`grid/vb1_pkg_oper` — nine package-parameter Rhs kinds, elaborated package copy:

| package parameter | map PREDICTS | MEASURED golden ELAB |
|---|---|---|
| `P1 = C0 + 2'b01` (binary op) | keep op + `ref_obj` leaf | **`constant`** — MISPREDICTED |
| `P2 = ~C0` (unary op) | keep op + leaf | **`constant`** — MISPREDICTED |
| `P3 = C0 ? C3 : C0` (conditional) | keep op + leaf | **`constant`**, stamped `12:40` (the SELECTED branch's object) — MISPREDICTED |
| `P4 = {C0}` (1-element concat) | keep op + leaf | keep `operation` + `ref_obj` ✓ |
| `P5 = (C3)` (parenthesised reference) | substitute | `constant` ✓ |
| `P6 = 2'(C3)` (width cast) | keep op + leaf | **`constant`** — MISPREDICTED |
| `P7 = C3 + 1` (int holder) | keep op + leaf | **`constant`** — MISPREDICTED |
| `Q0 = pk::C3` (bare ref ACROSS packages) | substitute | `constant` ✓ |
| `Q1 = pk::C3 + 2'b01` (op across packages) | keep op + leaf | **`constant`** — MISPREDICTED |

`grid/vb2_concat_bound` — six concat shapes, elaborated package copy:

| package parameter | golden ELAB | ours ELAB |
|---|---|---|
| `K1 = {C0, C3}` | `operation` + 2 `ref_obj` | `operation` + 2 **constants** (leaf over-fold) |
| `K2 = {2'b01, 2'b10}` (no reference) | `operation` + 2 constants | identical ✓ |
| `K3 = {2{C0}}` (replication) | outer `operation` + inner `operation` + `ref_obj` | **one `constant`** (WHOLE-expression over-fold) |
| `K4 = {C0} + 4'b0001` (concat INSIDE a binary op) | `operation` tree + `ref_obj` | **one `constant`** (WHOLE-expression over-fold) |
| `K6 = {C0, C3}` as a `localparam` | `operation` + 2 `ref_obj` | `operation` + 2 constants |
| `K7 = {{C0}, {C3}}` (nested concats) | all operations + 2 `ref_obj` | operations + 2 constants |

**Corrected road-B law.** In the elaborated PACKAGE copy the producer replaces
the whole Rhs with its reduced object *unless the Rhs tree CONTAINS a
concatenation or a replication anywhere* — in which case the entire expression
is left exactly as compiled, `ref_obj` leaves and their `vpiActual` intact. The
substituted object carries the SOURCE object's location (`P3` is stamped at the
selected branch, `12:40`). `parameter` and `localparam` behave alike (`K6`).
The exception is package-elaboration-specific: at module scope golden folds the
same concats whole (`b2`, re-verified — both sides constant at 7:31, 8:31, 9:32,
10:31).

The map's PRINCIPLE ("the producer never rewrites a leaf inside a surviving
expression") survives untouched. What was wrong was the rule for *which
expressions survive*.

**Producer site, found while checking this.**
`CompileHelper::substituteAssignedValue`, `CompileExpression.cpp:83-105`:

```cpp
    if (opType == vpiAssignmentPatternOp || opType == vpiConcatOp) {
      substitute = compileDesign->getCompiler()
                       ->getCommandLineParser()
                       ->getParametersSubstitution();
    }
    for (auto operand : *op->Operands()) {
      if (!substituteAssignedValue(operand, compileDesign)) {
        return false;
      }
    }
```

— a concat or assignment-pattern ANYWHERE in the tree refuses substitution
(the recursion is why `K4`, an addition, is refused), unless the
`-parametersubstitution` command-line flag is given, which our sweeps never
pass. This is the gate `b1` could see the shadow of but not name.

**What this does to the brief.** Road B's brief as written ("substitute a
constant for a parameter reference only when the reference is the whole Rhs")
mispredicts six of the nine `vb1` cells, and those six are cells where **our
emitter currently AGREES with golden**. An implementer following it literally
would stop folding `C0 + 2'b01`, `~C0`, `C0 ? C3 : C0`, `2'(C3)`, `C3 + 1` and
`pk::C3 + 2'b01` and turn six matching cells into mismatches. Replace the brief
with: *in the `inPackage && topView` arm, fold the whole Rhs to a constant when
its syntax tree contains no concatenation or replication; when it does, emit
the expression verbatim with `ref_obj` leaves bound to their `vpiActual`.*

**And road B is bidirectional, which the map does not say.** `K3` and `K4` are
over-folds of the WHOLE expression, not of a leaf: golden keeps the entire tree
and we produce a single constant. Any road-B fix has to close both directions
or `K3`/`K4`-shaped rows move the wrong way.

## V2. FINDING — ROAD E HAS THREE MORE DIVERGENT CELLS, AND ONE OF ITS ARMS DOES NOT HOLD ITS VARIABLE FIXED

`e2_ca_lhskind` is described as "one Rhs (`CFG.n`), five LHS kinds", but two of
its five cells change the Rhs as well: `assign o_bit[0] = CFG.n[0]` and
`assign o_part[3:0] = CFG.n[3:0]` are a bit-select and a part-select OVER the
hier_path, not the hier_path. `grid/ve1_ca_lhs_fixedrhs` re-cuts it with the
Rhs held at exactly `CFG.n` across seven LHS kinds — and **the map's conclusion
survives**: golden substitutes a `constant` stamped `8:31` (the package
literal) under all seven, we emit a fresh cont_assign under one (the
unpacked-array element). Two facts the map did not have:

* the substituted constant's `VpiSize` follows the **LHS declaration's own
  width** — 32 for `logic [31:0]`, **8** for `logic [7:0] o_narrow`, **64** for
  `logic [63:0] o_wide`. It is not a fixed 32;
* for a **bit-select or part-select LHS** the size is left **unset** — exactly
  what `UhdmWriter.cpp:2245` predicts, since `tps` is filled only from
  `lhs->Typespec()` on a whole-name Lhs and `adjustSize` with a null `tps`
  leaves the size alone.

`grid/ve2_ca_rhs_more` — seven Rhs kinds the pass did not cut:

| cont_assign Rhs | golden ELAB | ours ELAB | |
|---|---|---|---|
| `CFG.n + 1` (operation CONTAINING a field read) | `constant` | `constant` | agree |
| `OC.sub.n` (TWO-level field read) | `constant` @`12:41` | **shares the def object** | **NEW divergence** |
| `AP[0]` (unpacked-ARRAY parameter element) | `constant` @`14:29` | `constant`, no location | agree in kind |
| `{16'h0, CFG.n[15:0]}` (concat containing a field read) | **`constant`** | `operation` | **NEW divergence** |
| `CFG.n` inside a **generate block** | `constant` @`11:34` | `hier_path` | **NEW divergence** |
| `CFG.n + a_i` (non-constant) | `operation` | `operation` | agree (control) |
| `a_i` (non-constant) | shared | shared | agree (control) |

Road E's brief names one predicate — *"the Rhs is a constant-valued read of a
parameter's FIELD (a `MemberAccessExpression` chain bottoming on a
`SymbolKind::Parameter`)"*. It covers `OC.sub.n`; it does **not** cover the
concat cell or the unpacked-array element, and nothing in it says the share
decision at `ModuleEmit.cpp:27574` must also run for cont_assigns inside a
GENERATE block. The producer site is blind to the Rhs kind, so the honest
predicate is *"the Rhs reduces to a constant"*, fenced by whatever our emitter
needs to stay safe — and the generate-scope cell must be in the fix.

Note also that the concat cell settles a cross-road question: the
concatenation exception of road B does **not** apply here. `writeCont_assign`'s
`reduceExpr` folds a concat containing a field read; the elaborated package's
substitution refuses one. Two sites, two gates — further evidence for the map's
"five roads, not one switch" verdict.

## V3. FINDING — ROAD C's CONSTRUCT CARRIES TWO RESIDUES BIGGER THAN ITS FOLD

`grid/vc1_typedef_shapes`, one module body, four typedef shapes:

* `typedef logic [NDATA-1:0] two_t [DEPTH][2];` — **two** unpacked dimensions.
  The arm's head is `array_typespec (two_t)` itself: golden carries **two**
  `vpiRange` children (`[DEPTH]` at `14:36` and `[2]` at `14:43`) plus a
  `vpiElemTypespec` pointing at the element `logic_typespec`; **we carry one
  range and no element typespec at all**, and our span ends `14:45` where
  golden's ends `14:42`. That is a Ranges vector-size mismatch, not a fold —
  flipping `unfoldedTypedefDims` does not touch it.
* `typedef logic [NDATA-1:0] gen_t [DEPTH];` **inside a generate block** —
  golden's dump names `gen_t` 18 times (the `array_typespec`, its
  `logic_typespec` element, the `[DEPTH]` bound with
  `ref_obj (work@dut.g.gen_t.DEPTH)`); **our dump names it 0 times.** The whole
  typedef is absent.
* `typedef sp_t sarr_t [DEPTH];` (struct element + unpacked dim) — both sides
  keep the bound symbolic; the copy counts differ (golden 3 / ours 2).
* `typedef logic [NDATA-1:0][DATA_SIZE-1:0] pk2_t;` (packed 2-D, no unpacked
  dim) — agrees cell for cell, the positive control.

Road C is still ranked first — its corpus row is the closest to conversion —
but "the smallest surface of the five roads" is only true of the FOLD. Any pass
sweeping the `typedef … ] <name> [` construct will meet these two first.

## V4. FINDING — ROAD D's LAW IS RIGHT AND SHARPER THAN d1 COULD SHOW

`d1_cast_pkg` uses four members that are all `int unsigned`, so "re-stamp to the
member width" and "re-stamp to 32" are the same claim there.
`grid/vd1_pattern_width` gives the members different widths:

| package `localparam mix_t L = '{A: 64, B: 64, C: 32'd7, D: 64}` | member | golden DEF | golden ELAB | ours ELAB |
|---|---|---|---|---|
| `A` | `logic [7:0]` | 64 | **8** | 64 |
| `B` | `logic [15:0]` | 64 | **16** | 64 |
| `C` | `logic [63:0]` | 32 | **64** (widened; `vpiDecompile:32'd7`, `DEC:7`, constType 1 all preserved) | 32 |
| `D` | `int unsigned` | 64 | **32** | 64 |

So it is the MEMBER's width in both directions, the decompile and const-type
survive the re-stamp, and a package `parameter` behaves exactly like a package
`localparam` (`P`, same four sizes). The brief is correct; implement it against
the `typespec_member` width, never against 32.

The arm's own head is a different, NEW residue on the same package-scope
construct: for `localparam barr_t U = '{8'd1, 8'd2}` (an unpacked-ARRAY
pattern) golden's `parameter (pk::U)` carries no `VpiSize` and a
`ref_typespec` to the NAMED `array_typespec (barr_t)` at `15:11`; ours carries
`vpiSize:1` and an ANONYMOUS `array_typespec` at `16:14`. Same family as
README's R2.

## V5. FINDING — ROAD A's RULE PREDICTS EVERY NEW CELL, AND ONE NEW CELL STRENGTHENS THE BRIEF

`grid/va1_bits_signal` cuts the half of `getTypespec` the pass never reached —
the PORTS-and-SIGNALS lookup at `CompileExpression.cpp:4544-4557`:

| `$bits(...)` argument | predicted | golden DEF/ELAB | ours |
|---|---|---|---|
| a PORT name | fold | fold / fold | fold ✓ |
| a SIGNAL name | fold | fold / fold | fold ✓ |
| a signal of a struct typedef type | fold | fold / fold | fold ✓ |
| a MEMBER of a signal (`v.d`) | fold | fold / fold | fold ✓ |
| **a type parameter bound to a BUILT-IN keyword** (`parameter type TB = logic [9:0]`) | keep | **KEEP / KEEP** | fold |
| a type parameter bound to a package struct | keep | KEEP / KEEP | fold |

Seven for seven. The fifth row is the one worth having: the argument resolves
to a fully specified built-in type and golden STILL keeps the call — which is
independent proof for the brief's instruction *"decide on the argument's
SYNTAX naming a type parameter, never on the resolved type"*.

One precision correction to `a2_bits_holder`. Of its five holders only three
(parameter-port-list Rhs, body localparam Rhs, function-body `return`) produce
an object in a judged view. For holder 2 (port range bound, `10:19`) and
holder 4 (net range bound, `13:10`) the `sys_func_call` appears **only in
`weaklyReferenced`, on BOTH sides** — the reachable views carry identical
`logic_typespec`/`port`/`logic_net` structure. So "golden keeps in all five and
we fold in all five" should read: *holder is not a gate among the three holders
that reach a judged view; the other two produce no judged cell at all.*

## V6. SMALLER CORRECTIONS (all re-measurable)

1. **Blast radii are undercounts, but the RANKING ORDER survives.** Counting
   TEST DIRECTORIES across both corpora (`uhdm2rtlil/test/*`,
   `Surelog/tests/*`, `Surelog/third_party/tests/*`): road A **14** (map says
   7 — it misses the third-party trees entirely), road C **6** (map says 3),
   road E **40** (map says 20). C < A < E still holds, so the dispatch order
   stands; the risk numbers do not.
2. **`ibex_tracer`'s family census.** Golden-only `range` 948 ✓ and
   `vpiInstance` 619 ✓ and ours-only `tagged_pattern` 437 ✓ reproduce; but
   golden-only `logic_typespec` is **849**, not 744, and ours-only `enum_const`
   is **326**, not 276. The claim "the leaf substitution accounts for 326 of
   the golden-only lines" is not reproducible under any definition the verifier
   could find — golden-only lines naming an `OPCODE_` reference number **378**,
   and 326 is exactly the ours-only `enum_const` count, so the two look
   transposed.
3. **`StructParamFuncBodyFieldCompare`'s C3 span.** Ours carries TWO spans for
   that `struct_typespec`, not one: `42:26..42:39` (8 lines) and
   `42:26..45:4` (12 lines), against golden's single `42:26..42:32` (18 lines).
4. **`bits_of_type_param`'s `type_parameter` residue** is a multiset count, not
   two missing objects: golden 7 `type_parameter` lines, ours **10** — we emit
   three EXTRA `type_parameter: (work@dut.req_t)` lines, one golden-only
   `(work@dut.req_t)` line and one golden-only `(work@dut.data_t)` line. The
   three ours-only `logic_typespec`/`range`/`operation` triples reproduce ✓.
5. **Citation precision.** `compileBits`' final `else` that emits the
   `sys_func_call ($bits)` opens at `CompileExpression.cpp:4802` (the map says
   `:4805`); `compileContinuousAssignment`'s hard `Reduce::No` is the argument
   on `CompileHelper.cpp:2500` (the call opens at `:2498`); the generated
   comparator that reads `VpiNetType` is `nets::Compare`, not `net::Compare`.
6. **An ours-side hole found by the grid, recorded with its rc.**
   `grid/vb3_concat_sel`: a PART-SELECT of a concatenation as a package
   parameter Rhs (`parameter logic [1:0] K5 = {C0}[1:0];`) makes our binary
   exit **4** — "unsupported constructs encountered: range select base" —
   while golden compiles it (`golden_rc=0`). The arm is kept as an ERROR CELL,
   not as a golden claim; road B's implementer should know the construct is a
   hole before touching the elaborated-package arm.

## V7. Verifier arms and how to re-run them

`va1_bits_signal`, `vb1_pkg_oper`, `vb2_concat_bound`, `vb3_concat_sel`,
`vc1_typedef_shapes`, `vd1_pattern_width`, `ve1_ca_lhs_fixedrhs`,
`ve2_ca_rhs_more` — eight arms, ~51 cells, same runner:

```
bash run51.sh <pristine binary> base va1_bits_signal vb1_pkg_oper vb2_concat_bound \
     vb3_concat_sel vc1_typedef_shapes vd1_pattern_width ve1_ca_lhs_fixedrhs ve2_ca_rhs_more
```

Measured rcs (verifier's own pristine build, md5
`9be297f87ce752ca318a4d32b204ebe9`):

```
va1_bits_signal     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=28
vb1_pkg_oper        golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=29
vb2_concat_bound    golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=45
vb3_concat_sel      golden_rc=0 ours_rc=4  cmp_rc=255 heads=1 cmplines=15   (ERROR CELL)
vc1_typedef_shapes  golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=109
vd1_pattern_width   golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=31
ve1_ca_lhs_fixedrhs golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=26
ve2_ca_rhs_more     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=31
```

Cells are read site-keyed and view-sectioned from the two dumps, the same way
`cell51.sh` reads them; `evidence/VGRID.txt` carries the scored output.

## V8. VERDICT

**ACCEPT-WITH-FIX.** The census is honest and completely reproducible: ten
heads, fifteen arms, four head identities, five residue totals and every
producer citation stand up to an independent rebuild. Its central verdict —
**C2 is five producer sites with five disjoint gates, not one switch** — is
confirmed and, with the concat gate of V1 and the cont_assign concat cell of
V2, strengthened.

But **one of the five road LAWS is wrong (B) and two more are incomplete (C,
E)**, and road B's brief would cause a regression if implemented as written.
The corrections above must ride with the map. With them, the dispatch order
C → A → (D with B read alongside) → E is unchanged, and so is the honest yield:
five heads cleared, zero to two conversions.
