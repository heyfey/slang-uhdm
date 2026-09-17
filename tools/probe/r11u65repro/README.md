# r11u65 — § unpackedAliasNetType65

**AN UNPACKED DIMENSION IS TRANSPARENT TO THE DEF-VIEW NET TYPE. THE STAMP IS
THE RESOLVED TYPEDEF'S OWN BASE KEYWORD — `logic` → 36, `reg` → 48 — AND
NEITHER THE TYPEDEF'S OWN UNPACKED DIMENSION NOR THE DECLARATOR'S IS PART OF
THE RULE.**

Base `785fb3e7` (matrix-1.87). Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`, the golden producer),
uhdm2rtlil v0.68. Two binaries, both frozen `555` before any sweep: the
pristine worktree build, md5 `8090e35ab1057cc7d4b3e0118a39ce47` — **the OPS
pin, byte-identical to the main tree at the base** — and the law build, md5
`7dadad859cc42db4887c5658077384c8`. Every `cmds.txt` in every sweep was audited
by binary PATH.

**THE ROW ADVANCES, IT DOES NOT CONVERT — PREDICTED BEFORE THE LAW WAS
WRITTEN, AND THE PREDICTION HOLDS.** `mem_packed_2d_byte_write` stays
`CMP_NOTEQUAL` in both modes; its head moves off `vpiNetType` and its cmp goes
**29 lines → 24**. `results/*.csv` is UNTOUCHED and nothing in it needs
promoting: **u2r stays 787/17/67 in both modes, surelog stays 474/9 + 469/8.**

---

## 1. THE HEAD, RE-MEASURED AT `785fb3e7`, BOTH MODES

r11u52's R0 named this head. Re-measured with this pass's own frozen pristine
binary through the OFFICIAL `uhdm-cmp` against each mode's own cached golden:
**29 cmp lines, ONE head (`grep -c '^LHS:'` = 1), in BOTH modes**, and the two
sides differ by exactly one line —
[evidence/HEAD.base.testflags.cmp](evidence/HEAD.base.testflags.cmp),
[evidence/HEAD.base.default.cmp](evidence/HEAD.base.default.cmp) (the two files
differ only in object ids):

```
LHS (golden)                                RHS (pristine)
logic_net: (work@dut.mem), line:20:9        logic_net: (work@dut.mem), line:20:9
|vpiTypespec: … array_typespec: (mem_t)     |vpiTypespec: … array_typespec: (mem_t)
|vpiName:mem  |vpiFullName:work@dut.mem     |vpiName:mem  |vpiFullName:work@dut.mem
|vpiNetType:36                              <absent>
```

`uhdm2rtlil/test/mem_packed_2d_byte_write/dut.sv:19-20` is
`typedef logic [NDATA-1:0][DATA_SIZE-1:0] mem_t [DEPTH]; mem_t mem;`.
**`nets::Compare` reads `VpiNetType`** — `~/git-repos/UHDM/build/generated/src/nets.cpp:277`,
`if ((r = lhs->VpiNetType() - rhs->VpiNetType()) != 0)` — so the field is
judged, in the same `Compare` that reads `VpiName` and `VpiNetDeclAssign`.

### ADVANCE vs CONVERT — PREDICTED **ADVANCE**, AND IT IS AN ADVANCE

Before the law, the witness's order-blind whole-dump residue (both dumps
path-normalised, ids stripped, sorted) reads **26 golden-only / 5 ours-only
lines** — every one enumerated in
[evidence/RESIDUE.base.diff](evidence/RESIDUE.base.diff):

* **1 line** is this pass's head: `|vpiNetType:36`.
* **4 golden-only + 4 ours-only** are r11u52's **R1**, the doubled hier-path
  segment: golden `work@dut.mem.mem.i` / `work@dut.wdata.wdata.i` at 27:49 and
  27:71 against our single-segment `work@dut.mem.i` / `work@dut.wdata.i`, with
  their `vpiFullName` twins. `ref_obj::Compare` reads `VpiName`, so it is
  judged.
* **the remaining 21 golden-only / 1 ours-only** are r11u52's **R2**, one extra
  GOLDEN copy of the array's own `[DEPTH]` bound, FOLDED (`constant`
  `vpiDecompile:3` `INT:3`) where ours is symbolic — its `range`, `operation`,
  two `constant`s, `ref_obj (mem_t.DEPTH)` and their fields.

One judged line of thirty-one, with two judged residues standing behind it:
**ADVANCE**. Measured after the law
([evidence/HEAD.law.testflags.cmp](evidence/HEAD.law.testflags.cmp),
[evidence/HEAD.law.default.cmp](evidence/HEAD.law.default.cmp)): the row is
`CMP_NOTEQUAL`, **24 cmp lines, 1 head, in both modes**, and the head is now
R2 — golden's folded `constant 3` against our
`operation (work@dut.mem_t.DEPTH - 1)`. The residue goes **26/5 → 25/5** and
the string `vpiNetType` no longer appears in the diff at all
([evidence/RESIDUE.law.diff](evidence/RESIDUE.law.diff)).

---

## 2. THE CENSUS — GOLDEN-vs-GOLDEN FIRST, THEN OURS-vs-GOLDEN

This face waited eleven passes because its blast radius is every net in both
corpora. So it was censused before it was touched, with
[netcen65.cpp](netcen65.cpp): one line per NET object reachable from the design
root, keyed on **view** (`DEF` = `AllModules`/`AllInterfaces`/`AllPackages`,
`ELAB` = `TopModules`, both walked recursively through child instances,
instance arrays and generate scopes) **x scope path x net name x net UHDM
kind**, carrying the compare-visible `VpiNetType` beside the shape that decides
it. It reads databases only.

### (a) GOLDEN-vs-GOLDEN: which shapes carry which values

[evidence/SHAPES.golden.txt](evidence/SHAPES.golden.txt) aggregates every
golden database of BOTH corpora (1742 + 1581 arms) into **72 distinct shape
cells**. The cells that matter, verbatim:

```
DEF |module_inst   |logic_net|array_typespec       |logic_typespec |named   NT36=2
DEF |module_inst   |logic_net|array_typespec       |struct_typespec|named   NT0=8
DEF |module_inst   |logic_net|array_typespec       |int_typespec   |named   NT0=2
DEF |module_inst   |logic_net|logic_typespec       |-              |named   NT0=63 NT36=817 NT48=2
DEF |module_inst   |logic_net|packed_array_typespec|struct_typespec|-       NT0=189 NT1=69
ELAB|module_inst   |array_net|-                    |-              |-       NT0=1247
```

**The law's target cell holds exactly TWO nets in the whole of both corpora,
and both carry 36.** Its two sibling cells — a struct element and an `int`
element under the same `array_typespec` — carry NOTHING, in 10 nets. The `ELAB`
half of the census is why the law is DEF-view only: an unpacked-array signal is
a VARIABLE in the elaborated view, and neither producer emits a net for it
(golden's 1247 elaborated `array_net`s all read 0).

### (b) OURS-vs-GOLDEN: the exact population where we diverge, BY NAME

[census65.sh](census65.sh) `join` runs the same census against each arm's own
pristine database and joins on (view, scope path, net name, net kind) as a
MULTISET (a key repeats when two copies of one net exist; a last-writer map
would drop rows). Over **both corpora at the base**
([evidence/JOIN.u2r.txt](evidence/JOIN.u2r.txt),
[evidence/JOIN.sl.txt](evidence/JOIN.sl.txt)):

| corpus | arms joined | golden keys | ours keys | MATCH | **NT-DIFF** | ONLY-GOLDEN | ONLY-OURS |
|---|---|---|---|---|---|---|---|
| uhdm2rtlil | 1608 | 21352 | 21332 | 21330 | **2** | 20 | 0 |
| surelog | 960 | 134094 | 134088 | 134088 | **0** | 6 | 0 |

(the arms joined are those with BOTH a golden and a pristine database — the
same 1608 / 960 `byteverify` compares.)

**AFTER THE LAW the same join reads `NT-DIFF=0` on BOTH corpora**, with
`MATCH` rising by exactly 2 on uhdm2rtlil and unchanged on surelog, and
`ONLY-GOLDEN` / `ONLY-OURS` untouched
([evidence/JOIN.law.u2r.txt](evidence/JOIN.law.u2r.txt),
[evidence/JOIN.law.sl.txt](evidence/JOIN.law.sl.txt)). **`vpiNetType` now
agrees on every one of the 155 446 net keys in both corpora, in both views** —
that is the pass's AWAY-GOLDEN 0 stated by an instrument independent of
`byteverify`.

**THE ENTIRE DIVERGENT POPULATION IN BOTH CORPORA IS TWO NET INSTANCES**, and
the census names them:

```
NT-DIFF default/mem_packed_2d_byte_write   DEF|work@dut|mem|logic_net golden=[36] ours=[0] shape=array_typespec/logic_typespec tsname=mem_t
NT-DIFF testflags/mem_packed_2d_byte_write DEF|work@dut|mem|logic_net golden=[36] ours=[0] shape=array_typespec/logic_typespec tsname=mem_t
```

The blast radius the brief warned about is real — **155 446 golden net keys
were compared** — and the answer it returns is that every one of the other
155 444 already agrees, or is a missing-object row of a different class.

The 26 ONLY-GOLDEN rows are a separate, pre-existing class (nets golden emits
and we do not): `typed_named_pattern` x5, `anon_struct_packed_dim` x3,
`packed_array_struct` x2 and surelog's `SequenceInst` x3, per mode. They are
recorded as R3 and untouched.

---

## 3. THE PRODUCER'S STAMP RULE, CONFIRMED AT THE PINNED SOURCES

Two steps, both read, neither of which looks at a dimension.

**(A) THE REWRITE.** `ElaborationStep.cpp:1487-1500` (Surelog v1.87): a signal
whose written type name resolves to a `DataType` whose **actual** category is
`SIMPLE_TYPEDEF` has its `Signal::m_type` REWRITTEN to that typedef's own base
`VObjectType`:

```cpp
const DataType* def = type->getActual();
if (def->getCategory() == DataType::Category::SIMPLE_TYPEDEF) {
  VObjectType t = def->getType();
  if      (t == VObjectType::paIntVec_TypeLogic) signal->setType(VObjectType::paIntVec_TypeLogic);
  else if (t == VObjectType::paIntVec_TypeReg)   signal->setType(VObjectType::paIntVec_TypeReg);
  else if (t == VObjectType::paNetType_Wire)     signal->setType(VObjectType::paNetType_Wire);
}
```

Every other actual — `bit`, `int`, a struct, an enum, a type parameter — leaves
`m_type` alone.

**(B) THE STAMP.** `UhdmWriter::writeNets` (`UhdmWriter.cpp:891`) then writes
the DEFINITION-view net's type from that field and nothing else:

```cpp
dest_net->VpiNetType(UhdmWriter::getVpiNetType(orig_net->getType()));
```

and `getVpiNetType` (`UhdmWriter.cpp:572`) maps `paIntVec_TypeLogic` →
`vpiLogicNet` **36**, `paIntVec_TypeReg` → `vpiReg` **48**, `paNetType_Wire` →
`vpiWire` **1**, and everything else to 0.

A typedef's unpacked dimension lives on its DECLARATOR, not on its data type,
so it never reaches (A); and (B) reads a single `VObjectType`, so a declarator
dimension at the USE site never reaches it either. **That is the whole law**,
and the golden grid below confirms it cell by cell rather than by inheritance.

The ELAB view answers differently for a reason that is also in the sources:
`NetlistElaboration::elabSignal` (`NetlistElaboration.cpp:2090`) reads the SAME
rewritten `m_type` and, on `(!sig->isVar()) && subnettype ==
paIntVec_TypeLogic` with no port direction, sets `isNet = false` — the
elaborated object is a variable, not a net, and there is nothing to stamp.

---

## 4. THE GOLDEN GRID — 13 ARMS, `surelog -parse -nobuiltin -nocache -sv`
rc=0 and **0 `[ERR`** on every scored arm, both our binaries rc=0 on every
scored arm. Scored by [score65.py](score65.py) with **golden-vs-golden
CALIBRATION FIRST on every arm (CALIB-OK, 13/13)**;
[evidence/GRID.score.txt](evidence/GRID.score.txt).

### The element-kind and dimension-form cells (n1, x1)

| cell | declaration | golden | pristine | law |
|---|---|---|---|---|
| a | `typedef logic [N-1:0] a_t [D]; a_t a;` | **36** | 0 | **36** |
| **r** | `typedef reg [N-1:0] r_t [D]; r_t r;` | **48** | 0 | **48** |
| b | `typedef bit [N-1:0] b_t [D]; b_t b;` | **0** | 0 | 0 — control |
| i | `typedef int i_t [D]; i_t i;` | **0** | 0 | 0 — control |
| ea | `typedef en_t ea_t [D]; ea_t ea;` (ENUM element) | **0** | 0 | 0 — control |
| sa | `typedef sp_t sa_t [D]; sa_t sa;` (STRUCT element) | **0** | 0 | 0 — control |
| l | `typedef logic l_t [D];` (SCALAR element) | 36 | 0 | **36** |
| sg | `typedef logic signed [N-1:0] sg_t [D];` | 36 | 0 | **36** |
| tw | `typedef logic [N-1:0][7:0] tw_t [D];` (packed 2-D element) | 36 | 0 | **36** |
| nm | `typedef v_t nm_t [D];` (NAMED element) | 36 | 0 | **36** |
| rg | `typedef logic [N-1:0] rg_t [D-1:0];` (RANGED dim) | 36 | 0 | **36** |
| d2 | `typedef logic [N-1:0] d2_t [D][2];` (TWO dims) | 36 | 0 | **36** |
| **ad** | `a_t ad [2];` (typedef dim **+** declarator dim) | 36 | 0 | **36** |
| **vd** | `v_t vd [D];` (PACKED typedef + declarator dim) | 36 | 0 | **36** |
| pl | `logic [N-1:0] pl [D];` (no typedef at all) | 36 | 36 | 36 — control |
| li | `typedef logic [3:0] li_t [D];` (LITERAL bound) | 36 | 0 | **36** |

### The written-form cells (n2, c2) — the gate is the WRITTEN NAME, not the home

| cell | declaration | golden | pristine | law |
|---|---|---|---|---|
| **w1** | `import pk::*;` then `pa_t w1;` | **36** | 0 | **36** |
| **e1** | `import pk::pa_t;` then `pa_t e1;` | **36** | 0 | **36** |
| s1 | `pk::pa_t s1;` (EXPLICITLY QUALIFIED) | **0** | 0 | 0 — control |
| sd | `pk7::pv_t sd [4];` (scoped packed typedef + dim) | **0** | 0 | 0 — control |
| sq | `pk7::pa_t sq [2];` (scoped unpacked typedef + dim) | **0** | 0 | 0 — control |
| c2 arm | the whole `pk::mem_t` / `pk::pk1_t` package twin | 0 | 0 | 0 — **byte-unchanged arm** |

**The package home is NOT the gate, and that was measured, not assumed.** The
same package typedef reads 36 through a wildcard OR an explicit import and 0
when written `pk::`. `netTypeFor`'s existing def-view arm keys on the alias's
PARENT SCOPE; transcribing that here would have left `w1` and `e1` at 0.

> **CORRECTED BY THE VERIFIER (r11v65).** The sentence above holds only for an
> element that carries NO alias — which is the only kind this arm measures
> (`pa_t`'s element is written `logic [N-1:0]`). As soon as the element IS or
> CONTAINS an alias, the home of THAT alias IS a gate: a LOCAL alias element
> reads 36 and the same shape with a PACKAGE-homed alias element reads 0
> (r11v65 `v8_alias2` `d04` against `d10`, `d03` against `d09`). The shipped
> clause stamped 36 on eight such golden cells where golden and our pristine
> emission both read 0; the ELEMENT-REACH FENCE in `unpackedAliasNetType65`
> removes all eight and keeps every cell in this file's tables. See
> [../r11v65repro/README.md](../r11v65repro/README.md) §2.

### The guard cells (n7) — what must NOT move

| cell | declaration | golden | pristine | law |
|---|---|---|---|---|
| t1 | `parameter type T; T t1;` | 0 | 0 | 0 |
| **t2** | `T t2 [2];` — a TYPE PARAMETER **with a dimension** | **0** | 0 | **0** |
| **t3** | `parameter type TA = a_t; TA t3;` — a type param BOUND TO the unpacked typedef | **0** | 0 | **0** |
| ed | `en_t ed [4];` (local enum typedef + dim) | 0 | 0 | 0 |
| sdl | `sp_t sdl [4];` (local struct typedef + dim) | 0 | 0 | 0 |
| ss | `pk7::ps_t ss [2];` (scoped packed-struct + dim) | **1** | 0 | 0 — **STILL-WRONG, R2** |

### The net-keyword cells (n3, n7) — the law fires BEFORE the keyword switch

| cell | declaration | golden | pristine | law |
|---|---|---|---|---|
| wv (n3) | `wire v_t wv;` | 36 | 36 | 36 |
| **wa** | `wire a_t wa;` | **36** | **1** | **36** |
| **wv (n7)** | `wire v_t wv [2];` | **36** | **1** | **36** |
| wp | `wire [N-1:0] wp [D];` (no typedef) | 1 | 1 | 1 — control |

### The scope cells (n4, n8) and the PORT cells (n3, n8)

| cell | shape | golden | pristine | law |
|---|---|---|---|---|
| top | module body | 36 | 0 | **36** |
| la | an INSTANTIATED child module's body | 36 | 0 | **36** |
| **na** | a module that is **NEVER INSTANTIATED** | **36** | 0 | **36** |
| body | a module body beside a port | 36 | 0 | **36** |
| **ai** | a NON-ANSI **PORT** declared `input a_t ai;` | **36** | 0 | **36** |
| local2 | the body twin in the same module | 36 | 0 | **36** |
| pin/pout | `input logic [N-1:0] pin [D]` (no typedef) | 36 | 36 | 36 — control |
| sb | a child module body reached through a port | 36 | 0 | **36** |

**For MODULES, instantiation is NOT the discriminator** — `never_inst` reads 36
in golden with no instance anywhere.

### The interface cells (n5, n8, c3) — where instantiation IS the discriminator

| cell | shape | golden | pristine | law |
|---|---|---|---|---|
| **ia** | `a_t ia;` in an **INSTANTIATED** interface | **36** | 0 | **36** |
| **ta** | the same in another instantiated interface | **36** | 0 | **36** |
| **vd** | `v_t vd [D];` in an instantiated interface | **36** | 0 | **36** |
| iv / vp | `v_t iv;` packed typedef, instantiated | 36 | 36 | 36 |
| ib | `b_t ib;` bit element, instantiated | 0 | 0 | 0 — control |
| ip | `logic [N-1:0] ip [D];` (no typedef) | 36 | 36 | 36 — control |
| **ua** | `a_t ua;` in an **UNINSTANTIATED** interface | **0** | 0 | **0** |
| uv | `v_t uv;` in an UNINSTANTIATED interface | **0** | **36** | 36 — **STILL-WRONG, R1** |

`ua` is why the interface road carries the `ifaceInstantiated225` gate: without
it, the law would have moved a cell that already agreed. `uv` is r10v225's own
R1, pre-existing, byte-identical pristine and law, and NOT taken here.

### The fence arm (n6) — containers our exporter rejects

`typedef logic [N-1:0] q_t [$] / [] / [string]` — `slang-uhdm` exits **rc=3**
with `typedef target: QueueType / DynamicArrayType / AssociativeArrayType`, so
no net of these shapes exists in any database of ours and none can move. The
arm is kept as a measured fence, not scored (an arm whose compile fails teaches
error-recovery, not golden).

### THE SCORE

**TO-GOLDEN 35, AWAY-GOLDEN 0, MOVED-WRONG 0, STILL-WRONG 2, ONLY-OURS 0,
KEYSET-MOVED 0, SAME 108, calibration OK on 13/13 arms.** The two STILL-WRONG
are `uv` (R1) and `ss` (R2), both byte-identical pristine and law. The 3
ONLY-GOLDEN are golden `array_var` objects in the ELAB view that we do not
emit, present identically at base and after.

Per-arm cmp line counts, base → law: c1 72→72, c2 350→350 (**the package fence
arm, byte-unchanged**), c3 15→**45**, n1 66→66, n2 280→280, n3 29→**27**,
n4 29→**164**, n5 66→66, n7 164→164, n8 15→**16**, x1 66→66, x2 57→57. In
every arm whose count MOVED, the **head object CHANGED** — it stepped off the
net onto a pre-existing divergence (c3 an `array_var` we do not emit, n4 a
`named_begin`, n3 and n8 a range-bound `operation`) — so the new count is the
new head's decompile size, not a regression. A rising count with a changed head
is the ADVANCE signature.

---

## 5. WHAT WAS WRITTEN

Surface = [src/EmitHelpers.h](../../../src/EmitHelpers.h) +
[src/ModuleEmit.cpp](../../../src/ModuleEmit.cpp) + `tools/probe/r11u65repro/`.
**No line of behaviour removed.** `ParamEmit.cpp` is untouched, so its
`__LINE__` sensitivity is not in play.

* `EmitHelpers.h`, new `unpackedAliasNetType65(const Symbol&)` — the whole
  decision in one function, beside `aliasVectorKeyword`.
* `EmitHelpers.h`, `netTypeFor` — **one call, gated on `defView`**, placed
  after the `portTypeParam` guard so it answers before the net-keyword switch
  (the `wa` / `wv` cells).
* `ModuleEmit.cpp`, the INTERFACE def-view net loop — the same call, gated on
  `ifaceInstantiated225`, because that road hands `netTypeFor` no def-view
  flag and because the interface's own answer IS instantiation-dependent.

### ONE CORRECTION TO THE INHERITED FRAMING, MEASURED NOT REMEMBERED

r11u52's R0 (and this pass's brief) names the site as *"`netTypeFor`'s def-view
arm, whose module-local-typedef test admits `PackedArrayType` and `ScalarType`
and lets `FixedSizeUnpackedArrayType` fall through."* That description of the
arm is accurate, **but the arm is not the site for the witness**: the whole
def-view block sits inside `if (internal.kind == SymbolKind::Net)`, and slang
models `mem_t mem;` — a data declaration with an explicit four-state type — as
a **`VariableSymbol`**, not a `NetSymbol`. The witness never reaches that arm;
it falls out of the GENERAL `NamedType` arm below, whose
`ct.kind == PackedArrayType || ScalarType` test the unpacked canonical fails.
The arm r11u52 named IS the site for the `wire a_t wa;` cell (n7), which is a
real net and which this pass also moves, 1 → 36. Placing the clause at the top
of `netTypeFor` under `defView` covers both, and the grid scores both.

### The gate, structurally

The clause requires **at least one unpacked level**, which makes it DISJOINT
from the def-view alias arm below it (that arm answers only shapes with none).
It is DEF-VIEW ONLY, so every elaborated road — `netTypeFor(sym)` at
`ModuleEmit.cpp` 10109 / 18286 / 33592 / 35573 / 36050 and `TypeEmit.cpp`
21657 — is untouched.

### The fences, each a measured golden cell

| # | shape | why declined | cell |
|---|---|---|---|
| F1 | a written name that is SCOPED (`pk::T`) | golden prints none | n2 s1, n7 sd/sq/ss, c2 |
| F2 | a TYPE PARAMETER (a `TypeAssignment` syntax) | golden prints none in every cell, dimension or not | n7 t1/t2/t3 |
| F3 | a TWO-STATE element (`bit`) | `getVpiNetType` has no `paIntVec_TypeBit` case | n1 b, n5 ib, x1 bt |
| F4 | an element that is not a packed vector or scalar — `int`, `enum`, `struct` | same | n1 i/ea/sa, x1 it |
| F5 | no unpacked level at all | the existing arm already owns it; the clause never sees it | n1 v_t, c1 p1 |
| F6 | the ELABORATED view | the signal is a VARIABLE there, and a net-keyword declaration answers its keyword | n1/n3 ELAB rows |
| F7 | an UNINSTANTIATED interface | golden prints none | n5 ua |
| F8 | a queue / dynamic / associative container | our exporter rejects the typedef outright | n6 |

**NO SIGNED FENCE, NO LITERAL-BOUND FENCE, NO GENERATE FENCE, NO
UNINSTANTIATED-MODULE FENCE** — n1 `sg`, x1 `li`, n4 `na` are golden cells that
say so, and every one of them CONVERTS.

---

## 6. THE A-PRIORI MOVER PREDICTION, AND ITS POSITIVE CONTROL

A pristine DATABASE cannot discriminate this population on its own, and that is
a measurement, not a guess: the grid shows our pristine emission of the very
same construct as an `array_typespec`, a NAMED `logic_typespec`, an UNNAMED
`logic_typespec` and **no typespec at all**, in different cells — the same four
shapes every other net already wears. The discriminator is the WRITTEN FORM.
So the prediction is made **two ways**, both from pristine material only, and
both BEFORE the patched sweeps were read.

### (i) The construct scan, intersected with the pristine databases' own nets

[predict65.py](predict65.py) is a deliberate SUPERSET of the law's reach: every
`typedef <…> NAME [dims];` contributes NAME (whatever the element kind), every
`<Name> <ident> [dims]` declaration contributes `<ident>` (whatever `<Name>`
resolves to), and every `<T> <ident>` use of a name from the first set
contributes `<ident>`. The names are then intersected with the DEF-view net
names the arm's own PRISTINE database carries
([netnames65.sh](netnames65.sh)) — a name the pristine database does not hold
as a def-view net cannot move.

*Predicted, by name, before the patched sweeps:*
**u2r — at most 46 arms of 1742** (23 tests x 2 modes), each with its candidate
net names: `IndexedPartSelectOfArrayElement`, `NestedPatternPassedAsPort`,
`NestedStructArrayParameterInitializedByPatternPassedAsPort`, `OneStruct`,
`StructArrayParameterInitializedByPatternPassedAsPort`,
`TypedefVariableDimensions`, `gen_test2`, `hier_path`, `ibex_pmp`,
`iface_arr_struct_field_partsel`, `iface_arr_struct_whole_field`,
`iface_gen_delay_struct`, `iface_unpacked_struct_array`, `indexed_partsel_array`,
`latch_axi_adapter`, `latch_fifo_dynfield`, **`mem_packed_2d_byte_write`**,
`struct_member_trailing_index`, `type_param_unpacked_port`,
`unpacked_struct_2d`, `unpacked_struct_array_typedef`,
`unpacked_struct_dyn_read`, `unpacked_struct_mixed`
([evidence/PREDICT.u2r.txt](evidence/PREDICT.u2r.txt)).
**surelog — at most 28 arms of 1581** (14 tests x 2 modes):
`HierPathVarArray`, `IfGenTypeBinding`, `InterfaceUnpackedStructArrayDim`,
`MiniAmiq`, `PackStructVar`, `RangeSelect`, `SelectHierPath`, `StructAccess`,
`TypedefUnpacked`, `UnpackPort`, `UnpackedTypespec`, `VirtualClass`,
**`YosysOldOr`**, `YosysOldSpi`
([evidence/PREDICT.sl.txt](evidence/PREDICT.sl.txt)). The other 1696 u2r and
1553 surelog arms are predicted byte-identical.

*Positive control* ([evidence/PREDICT.control.txt](evidence/PREDICT.control.txt)):
the same scanner run over the 13 grid arms names **every net the grid moves** —
c1 `mem,u1`; x1 `a,li,nm,rr,sg,tw`; x2 `u`; c3 `a`; n1 `a,ad,d2,l,nm,r,rg,sg,tw,vd`;
n2 `w1,e1`; n3 `ai,body,local2`; n4 `la,na,top`; n5 `ia`; n7 `ch,wa,wv`;
n8 `sb,ta,vd` — and is not silently empty on any arm that moves.

### (ii) The census join, which BOUNDS the TO-GOLDEN half exactly

§2(b) is the same prediction read from the other side: **only two net instances
in either corpus disagree with golden today**, so at most two arms can move
TOWARD golden and every other arm the law touches would be moving AWAY. That
is the sharper bound, and it is why the two predictions together make the
measured result falsifiable in both directions.

### MEASURED

* **u2r byte census: MOVERS 2 / 1608** — `mem_packed_2d_byte_write`, default
  and testflags, **and nothing else**. Both are in the predicted set and both
  are the census's two NT-DIFF rows. Positive control (`SELFCHECK=1`):
  **1607 / 1608** flagged. `PATH_SETS_IDENTICAL`.
* **Mover attribution, order-blind** (`uhdm-dump`, path-normalised, ids
  stripped, `sort`): **EXACTLY ONE LINE changes per database, and it is the
  law's own:**

```
testflags   > |vpiNetType:36        (1 line)   17051 -> 17053 bytes
default     > |vpiNetType:36        (1 line)   22132 -> 22134 bytes
```

  The byte size delta is **+2, nonzero** — the MOVER RULE's "nonzero proves
  real" applies and this is a real mover; no 4096 multiple is involved, so the
  page-boundary positive control is not in play.

* **surelog byte census: MOVERS 2 / 960** — `MiniAmiq` in both modes, **and
  nothing else**. Positive control (`SELFCHECK=1`): **959 / 960** flagged.
  `PATH_SETS_IDENTICAL`. `MiniAmiq` WAS in the predicted set, so it is
  convicted, not assumed:

  * its order-blind sorted-dump diff is the OPS-documented **4-line
    `UINT:`/`vpiDecompile:` LINE-NUMBER class**, moving in both directions
    (`default` `UINT:1318` ↔ `UINT:844`; `testflags` `UINT:1388` ↔ `UINT:1139`);
  * **the string `vpiNetType` does not occur ANYWHERE in MiniAmiq's dump** —
    `grep -c` reads **0** on both binaries' databases — so the law cannot have
    written a line of it;
  * **the PRISTINE binary alone draws THREE DIFFERENT DATABASES in three
    consecutive runs** from MiniAmiq's own command line (`689c888b9e45`,
    `effb6c80c2d7`, `6cda10a61fb3`), and the law binary two more
    (`3e03bee789b8`, `17b10a57429c`): five distinct hashes with no correlation
    to the code change, and a pristine-vs-pristine order-blind diff that is the
    SAME 4-line class (`UINT:1394` ↔ `UINT:1177`).

* **`YosysOldOr` and `Earlgrey_0_1` were both PREDICTED candidates and neither
  moved**, in either mode.

---

## 7. THE GATES

| gate | result |
|---|---|
| (1) build both, md5 | pristine `8090e35ab1057cc7d4b3e0118a39ce47` — **the OPS pin**; law `7dadad859cc42db4887c5658077384c8` |
| (2) goldens | law `PASS=23 FAIL=0`; pristine `PASS=23 FAIL=0`; `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| (3) u2r both modes | `787 CMP_EQUAL / 17 CMP_NOTEQUAL / 67 SLANG_REJECT` x2. Joined against `results/golden_uhdm2rtlil.csv` (BOTH modes, 1742 rows): **0 missing, 0 extra, 0 differing rows.** `gate_uhdm2rtlil.csv` and law-vs-my-own-pristine, both modes: `ct8rows` PASS |
| (4) surelog `--mode both` | `474/9` default + `469/8` testflags — **status AND dump histograms identical to `results/golden_surelog.csv` and to my own pristine sweep**. Law-vs-baseline and law-vs-pristine differ in exactly **two** rows each: `LowMemLib` / `LowMemPkg`, whose `SURELOG_FAIL` detail string quotes the WORKDIR PATH |
| (5) byteverify `SELFCHECK=1` | u2r `MOVERS 2/1608`, SELFCHECK `1607/1608`; surelog `MOVERS 2/960` (MiniAmiq, the coin), SELFCHECK `959/960`; `PATH_SETS_IDENTICAL` both |
| cmds.txt audit | u2r **1742/1742** name the frozen binary by PATH; surelog **1531/1581**, the other 50 hold no `slang:` line at all (surelog produced no golden, so slang never ran). Pristine and law sweeps audited separately; no other binary is named anywhere |
| canaries | u2r `ok=8 changed=0 absent=0`; surelog `ok=52 changed=0 absent=0` — **identical to my own pristine sweep's reading on both corpora** |
| ctcan2 | PASS x2 (`EXPECT_UNKNOWN=1` surelog, `EXPECT_UNKNOWN=6` u2r) |
| canaudit | `audited=29 UNCOVERED=0 FENCE-BREACH=0`; this pass's `canaries.sh`/`ctcan2.sh`/`canaudit.sh` are byte-IDENTICAL to `r10uvm221repro`'s |
| rowheads | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg / Earlgrey_0_1 all `0 lines 0 heads` in both modes; Rggen `64 lines 1 head` (unchanged). SKIP-NOFILE on Scoreboard/tf and Rggen/tf as expected |
| protected DBs | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`, `Earlgrey_0_1` default `8bdf25272e08` / testflags `59d0ee6d10c3`, `BlackParrotComplex`, `YosysOldOr` — **every one byte-identical pristine to law, in BOTH modes, every hard pin at its OPS value** |
| UVM family | BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard all still `CMP_EQUAL` (Scoreboard/testflags `SLANG_REJECT`, its baseline state) |
| landed conversions | `struct_member_cfg_width`, `iface_zero_width_field`, `indexed_partsel_array`, `struct_param_pattern_packing` all still `CMP_EQUAL` in both modes |
| census closure | ours-vs-golden `NT-DIFF` **2 → 0** on uhdm2rtlil, **0 → 0** on surelog: **MOVED-WRONG 0, AWAY-GOLDEN 0, both mode columns scored** |
| `results/*.csv` | **READ, NEVER WRITTEN** |
| fenced tests | never dispatched |

---

## 8. RESIDUES, and R0

* **R0 — THE NEXT HEAD, on the same row.** `mem_packed_2d_byte_write` is now
  headed by **r11u52's R2**: golden carries one MORE copy of the array
  typedef's own `[DEPTH]` bound than we do, and golden's copy is FOLDED to a
  `constant` (`vpiDecompile:3`, `INT:3`, `vpiConstType:7`) where ours is the
  symbolic `operation (work@dut.mem_t.DEPTH - 1)`. 24 cmp lines, 1 head, both
  modes. Two questions in one: the typespec-pool COPY COUNT (r11u35 R4) and
  which copy folds. Behind it stands **R1**.
* **R1 — the doubled hier-path segment** (r11u52 R1, unchanged and judged):
  golden `work@dut.mem.mem.i` / `work@dut.wdata.wdata.i` at 27:49 / 27:71
  against our single-segment names — the loop index under a memory select.
  8 of the row's remaining 30 residue lines.
* **R2 — a SCOPED package packed-struct typedef with a DECLARATOR unpacked
  dimension nets as `vpiWire`** (n7 `ss`: `pk7::ps_t ss [2];` golden **1**,
  ours **0**). The `isPkgStructType && isExplicitPkgQualified` wire arm in
  `ModuleEmit`'s def-view net loop does not descend a declarator dimension.
  Pre-existing, byte-identical pristine and law, no corpus row carries it
  (the census join reads 0 NT-DIFF outside the witness).
* **R3 — nets golden emits and we do not** (26 ONLY-GOLDEN rows in the census
  join): `typed_named_pattern` five DEF `logic_net`s at `NT=1`,
  `anon_struct_packed_dim` three ELAB `struct_net`s, `packed_array_struct` an
  ELAB `packed_array_net` + `struct_net`, surelog's `SequenceInst` three DEF
  `logic_net`s at `NT=1` — per mode. A MISSING-OBJECT class, not a net-type
  one.
* **R4 — the UNINSTANTIATED interface stamps nothing** (n5 `uv`: golden 0,
  ours 36). r10v225's own R1, re-measured here and explicitly fenced OUT of
  this law by the `ifaceInstantiated225` gate. Our interface road gives a
  packed vector typedef 36 unconditionally; golden gives it 36 only when the
  interface is instantiated.
* **R5 — an `array_var` in the ELABORATED view** (n1 `r`, n3 `ai`, n7 `wa`):
  golden emits an elaborated `array_var` for a signal declared with an
  unpacked-array typedef; we emit none. Three grid cells, ONLY-GOLDEN at base
  and after.
* **R6 — a package-scoped unpacked-array typedef loses its `array_typespec` on
  our side** (n2 `w1`/`e1`/`s1`, c2 `mem`: golden `array_typespec (pk::pa_t)`,
  ours a bare `logic_typespec` with no name). r11u51's R2, unchanged. The net
  TYPE now agrees on all four; the typespec does not.

## 9. REPRODUCING

```bash
g++ -O2 -std=c++17 netcen65.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o netcen65
GRID=$PWD/grid bash run65.sh <binary> <tag>        # golden + binary per arm, both rcs
GRID=$PWD/grid python3 score65.py                  # calibration + TO/AWAY/STILL per arm
bash census65.sh shape <workdir>                   # golden-vs-golden shape census
bash census65.sh join  <workdir>                   # ours-vs-golden join, NT-DIFF by name
bash netnames65.sh <workdir> > names.txt
python3 predict65.py <workdir> --names names.txt   # the a-priori mover prediction
python3 ctrl65.py                                  # the predictor's positive control
```

`canaries.sh`, `ctcan2.sh` and `canaudit.sh` are the current-generation battery
(`r10uvm221repro`), carried here byte-unmodified so the audit runs in this
directory.
