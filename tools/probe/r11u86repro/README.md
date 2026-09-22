# r11u86 — the module route reads the Value store, and the qualified route is pinned to the branch that never hands on

**TWO FACES OF THE PARAMETER SUBSTITUTION ROUTES, ONE BATCH.  LAW A (r11v81's
RV81-2): golden's MODULE-route hop constants are the producer's simple VALUE
STORE rendered — a `'d`-spelled hop comes out `vpiIntConst`/`INT:`/bare decimal
digits and an `'o`-spelled one `vpiUIntConst`/`UINT:`/bare decimal, where ours
keeps the literal's own `DEC:`/`OCT:` with its written decompile.  LAW B
(r11v81's RV81-1): the producer's qualified-name branch IS
`CompileExpression.cpp:2723`, `childType == VObjectType::paPackage_scope` — it
clones the stored Rhs and BREAKS, and the typespec hand-on is in the two
UNQUALIFIED blocks it never reaches.  The pinned rule agrees with the landed
lexical fences on every measurable cell, so the fences stand UNCHANGED and the
pin is the deliverable.**

Base `85da93e6`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68).  Every golden in this directory is a real Surelog
v1.87 run through the committed `run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`; **all 33 grid arms read `0 0 0` on both binaries**.

| binary | md5 | what |
|---|---|---|
| pristine | `23aace417bcebd92ef0afde8a20a8a1e` | built in this pass's own worktree at `85da93e6` — **byte-identical to the main tree's `build/slang-uhdm`** |
| law | `7a4c780d71aa71fd643b77e4314676b4` | this patch |

Both frozen `chmod 555` before any sweep; every `cmds.txt` audited by absolute
binary path, **0 naming the main tree** on either binary.

---

## 0. AN INSTRUMENT FIX — THE LISTER'S KEY COLLIDED

r11v81's RV81-3: `ts81probe` is read through a scorer that keys on (section,
LHS name, op type), so several instances of one sink module — all of whose
parameters are named `R` — overwrite each other and only the LAST is scored.
`score86.py` replaces that key with (section ORDINAL, operand index), so every
cell of every section is scored; `m3_gate86` has three same-named sink sections
and `m4_ctx86` two, and both would have been read as one.  The probe binary
itself is the committed `ts81probe.cpp`, unchanged.

**THE SCORER'S OWN POSITIVE CONTROL.**  Scoring `m1_route86` with the two tags
SWAPPED turns all four of its TO cells into AWAY and TO to 0.  `AWAY=0` below
is a measurement, not a blind spot.

---

## 1. THE PRODUCER, LINE BY LINE

### 1.1 LAW A — which store answers, and what it renders

`compileExpression`'s `slStringConst` case
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:2720`) resolves a
setter that is a NAME.  For an UNQUALIFIED spelling it falls to the `else` at
`:2806`, appends any `.`/`::` tail, and at **`:2877-2878`** asks the instance's
simple Value store:

```cpp
if ((reduce == Reduce::Yes) && instance) sval = instance->getValue(name);
```

The next line decides everything:

```cpp
if (sval == nullptr || (sval && !sval->isValid())) {
    … the netlist param_assign CLONE   (:2886-2933, with the typespec hand-on)
    … the component param_assign CLONE (:2941-3004, with the typespec hand-on)
    … else a ref_obj
} else {
    UHDM::constant *c = s.MakeConstant();          // :3027-3041
    c->VpiValue(sval->uhdmValue());
    c->VpiDecompile(sval->decompiledValue());
    c->VpiConstType(sval->vpiValType());
    c->VpiSize(sval->getSize());
    if (sval->isSigned()) { … a signed int_typespec … }
    result = c;
}
```

**A VALID simple Value wins over the clone.**  r11u81 read the same pair at
`getValue()`'s own `::` branch (`:912-921` against `:929-955`) and named it the
module road; this is the same fork on the road compileExpression itself walks,
and it is the one the grid's cells come out of.

The three renderers are `~/git-repos/Surelog/src/Expression/Value.cpp`:

| store | `uhdmValue()` | `vpiValType()` | `decompiledValue()` |
|---|---|---|---|
| `Type::Integer` | `"INT:" + to_string(s_int)` (`:283-284`) | `vpiIntConst` (`:342`) | `to_string(s_int)` (`:317`) |
| `Type::Unsigned` | `"UINT:" + to_string(u_int)` (`:287-288`) | `vpiUIntConst` (`:345`) | `to_string(u_int)` (`:320`) |

— **plain decimal digits, no width and no base, for both.**  A `'d`-spelled
parameter's stored value is `Type::Integer`; an `'o`-spelled one's is
`Type::Unsigned` (`LValue::vpiValType`'s octal arm at `:964-966` has its
`vpiOctConst` COMMENTED OUT, and neither `uhdmValue` switch has an octal case
at all — the octal spelling never survives as octal past the store).  `'h` and `'b` have no valid simple
Value, so their cells take the clone and keep `HEX:`/`BIN:` with the written
decompile — which is why `16'h5` one hop up is golden and ours already
byte-identical.

The sizes come from the same store (`Value.h:200` / `Value.cpp:872`), and
`SValue(uint64_t)`'s constructor (`Value.h:178-181`) is where r11v81's
`UINT:5@64` comes from: `m_size` is hard-coded 64 for an unsized decimal.
**That face is NOT landed here — see §6 R0.**

### 1.2 LAW B — the branch that chooses on a qualified name

`CompileExpression.cpp:2723`:

```cpp
case VObjectType::slStringConst: {
  std::string name; Value *sval = nullptr;
  if (childType == VObjectType::paPackage_scope) {            // :2723
    … const std::string_view n = fC->SymName(paramId);
    if (m_elabMode) {
      Package *pack = …getPackage(packageName);
      if (pack) {
        for (param_assign *param : *pack->getParam_assigns())
          if (param->Lhs()->VpiName() == n)
            if (substituteAssignedValue(param->Rhs(), compileDesign)) {
              result = UHDM::clone_tree(param->Rhs(), &elaboratorContext);  // :2745
              result->VpiParent(pexpr);
              fC->populateCoreMembers(child, child, result);
            }
        if (result == nullptr) sval = pack->getValue(n);       // :2764
      }
    }
  } else if (childType == VObjectType::paClass_type) {        // :2767 — the twin
```

**THE PIN.**  This branch CLONES and there is no `tps`/`Actual_typespec` block
in it at all; `if (result) break;` at `:2880` then leaves the case before
either of the two blocks that DO hand on (`:2905-2927` and `:2967-2993`, both
reached only from the `else` at `:2806`).  So a package-qualified setter is
golden BARE not because of a decision about typespecs but because the qualified
route is a SHORTER function that was never given the hand-on.  `paClass_type`
at `:2767` is the same shape for `cls::PARAM`.

**THE PIN AGREES WITH THE LANDED FENCES ON EVERY MEASURABLE CELL**, so
§ `hopSpellingIsUnqualified81v` and § `patternHomeIsAPackage81v` stand exactly
as landed — see §4.

### 1.3 What the pin explains that the transcription could not

* WHY the qualified route also mints different VALUES (`:2764`'s
  `pack->getValue(n)` is the same simple Value store as `:2878`'s) — the
  typespec and the encoding are TWO CONSEQUENCES OF ONE FORK, which is why
  r11v81 saw `UINT:5@64` and `INT:5` beside the missing typespec.
* WHY a hop's own qualified INITIALIZER does not matter (`v5_chain81` op2):
  the setter's spelling is what `childType` reads, and the hop's declaration
  text was consumed when the hop's own value was computed.
* WHY a cast over a qualified name still abstains: compileExpression descends
  into the cast's argument and meets the same `paPackage_scope` child.

---

## 2. THE LAW

### § modPatHopValueStoreEnc86 — `src/ParamEmit.cpp`, written LAST

A loop beside § `hopStoreHandsOnItsTypespec81`'s, under the INVERSE of its
`pkgPat81` gate, so the two laws are disjoint by construction and each is
droppable alone.  It writes THREE fields and no object:

```
for each elaborated struct-pattern operand that is a constant:
  the cell must already hold vpiDecConst or vpiOctConst   (the class measured)
  the setter must be a HOP (red86HopName86: a NAME to a parameter, read
      through the signedness casts that hand their operand back)
  the producer's reduce must not refuse (patAstRefuses68 / red72Int64)
  the reduced value must fit a signed 64-bit read          (>= 0)
  the hop chain's literal leaf must be <= 64 bits written  (unsized is IN)
  the leaf's base must be the class the cell holds
    'd  ->  VpiConstType(vpiIntConst)   VpiValue("INT:"+dec)   VpiDecompile(dec)
    'o  ->  VpiConstType(vpiUIntConst)  VpiValue("UINT:"+dec)  VpiDecompile(dec)
```

`red86HopName86` is one new inline reader in `src/EmitHelpers.h`; everything
else is r11u81's own (`red81StoreCt81` for the leaf's base and written width,
`red81SignCastArg81` for the cast face, `patAstRefuses68` + `red72Int64` for
the refusal).

### THE GATES, each with the golden cell that demands it

| gate | the cell |
|---|---|
| the PATTERN's home is not a package | `m3_gate86`'s `.R(m3p::PKGCTL3)` — a PACKAGE-homed pattern read into a module keeps `DEC:5`/`OCT:5` with r11u81's typespecs on all eight operands, golden and BOTH binaries byte-identical |
| the setter must be a HOP | `m3_gate86` op1/op3 and `m5_bnd86` op10 — `a: 16'd5` written DIRECTLY is golden `16@1 DEC:5 d=16'd5` where `b: MD` one hop up is golden `16@7 INT:5 d=5`; one spelling, two answers |
| 64 bits | `m5_bnd86` op5/op6 — `96'd12` is golden `96@1 DEC:12 d=96'd12` and `65'd3` is golden `65@1 DEC:3 d=65'd3`: past the word boundary there is no simple Value and the clone answers |
| a negative read | `m5_bnd86` op7 — `64'd18446744073709551614` is golden `64@7 INT:0 d=0`: the producer's own word overflowed and the digits are LOST, so a value that does not fit a signed 64-bit read is refused rather than transcribed wrong |
| the producer's reduce | the two refusal readers r11u68/r11u81 already use — where golden keeps the OPERATION or the tagged tree there is no constant of golden's to agree with |
| the cell already holds the class | every measured cell does; a cell that does not was produced by some other road and this law has measured nothing about it |

### WHAT IT DOES NOT TOUCH

`VpiSize` (§6 R0) and `Typespec` (r11u81's ground; §6 R1).  `'h`, `'b`, a plain
decimal, an operation and `$clog2` are golden and ours ALREADY — the law never
sees them.

---

## 3. THE GOLDEN GRID

Eight new arms beside every committed r11u81 / r11v81 arm — **33 arms, 27 of
them carrying operand cells** (`m7_if86` carries none: golden keeps its tagged
tree, and it is read with `diff` on the dumps instead) read with `ts81probe` on the real databases and scored with
`score86.py`.

### 3.1 `m1_route86` — THE AXES SEPARATED

Four MODULE patterns, hop home × typespec home, 24-bit members:

| pattern | hops | typespec | golden op1 `5` | golden op2 `16'h5` | golden op3 `16'd5` |
|---|---|---|---|---|---|
| `A_PP` | package | package | `64@9 UINT:5` | `16@5 HEX:5 d=16'h5` | `16@7 INT:5 d=5` |
| `A_PM` | package | module | `64@9 UINT:5` | the same | the same |
| `A_MP` | module | package | `32@9 UINT:5` | the same | the same |
| `A_MM` | module | module | `32@9 UINT:5` | the same | the same |

**The typespec home is IRRELEVANT** (PP ≡ PM, MP ≡ MM); the hop's home moves
only the SIZE; and the `'d` encoding moves on BOTH homes.  Two axes, cleanly
separated, on one arm.

### 3.2 `m2_enc86` — THE ENCODING TABLE

Nineteen spellings × two hop homes, one MODULE pattern each, 24-bit members:

| spelling | golden | ours (pristine) | this law |
|---|---|---|---|
| `16'd5` | `16@7 INT:5 d=5` | `16@1 DEC:5 d=16'd5` | **golden's** |
| `32'd5` | `32@7 INT:5 d=5` | `32@1 DEC:5 d=32'd5` | **golden's** |
| `64'd5` | `64@7 INT:5 d=5` | `64@1 DEC:5 d=64'd5` | **golden's** |
| `'d5` | `-1@7 INT:5 d=5` | `32@1 DEC:5 d='d5` | ct+decompile golden's, SIZE is R0 |
| `16'sd5` | `16@7 INT:5 d=5` | `16@1 DEC:5 d=16'sd5` +`int_typespec/S` | ct+decompile golden's, the typespec is R1 |
| `16'o5` | `16@9 UINT:5 d=5` | `16@4 OCT:5 d=16'o5` | **golden's** |
| `logic [15:0] = 16'd5` | `16@7 INT:5 d=5` | `16@1 DEC:5 d=16'd5` | **golden's** |
| a depth-2 `'d` chain | `16@7 INT:5 d=5` | `16@1 DEC:5 d=16'd5` | **golden's** |
| `16'h5` | `16@5 HEX:5 d=16'h5` | the same | **unchanged — EQ on both binaries** |
| `16'b101` | `16@3 BIN:101 d=16'b101` | `24@3` re-encoded | unchanged — r11u66's residue |
| `5` (pkg hop) | `64@9 UINT:5 d=5` | `32@9` | unchanged — R0 |
| `5` (module hop) | `32@9 UINT:5 d=5` | the same | **unchanged — EQ** |
| `-5` / `5+1` / `$clog2(8)` | `64@7`/`64@9` | `32@…`, ct EQUAL | unchanged — R0 |
| `-16'd5` / `16'd9+16'd1` | `16@7 INT:…` | `32@7`, ct EQUAL | unchanged — R0 |
| `int TI = 5` | `32@9 UINT:5 d=5` | the same | **unchanged — EQ** |
| `'h5` | `-1@5 HEX:5 d='h5` | `32@5` | unchanged — R0 |

### 3.3 `m3_gate86` — DIRECT AGAINST ONE HOP UP

One MODULE pattern carrying both faces of the same spelling, plus the PACKAGE
control read into the same module:

```
   member        golden (module pattern)    golden (.R(m3p::PKGCTL3))
   a: 16'd5      16@1 DEC:5 d=16'd5         16@1 DEC:5 d=16'd5
   b: MD         16@7 INT:5 d=5             16@1 DEC:5 ts=ref()/NOACTUAL
   c: 16'o5      16@4 OCT:5 d=16'o5         16@4 OCT:5 d=16'o5
   d: MO         16@9 UINT:5 d=5            16@4 OCT:5 ts=int_typespec/U[15:0]
   e: MSD        16@7 INT:5 d=5             16@1 DEC:5 d=16'sd5 ts=/S
   f: a depth-3 chain     16@7 INT:5 d=5    16@1 DEC:5 ts=ref()/NOACTUAL
   g: unsigned'(MD)       16@7 INT:5 d=5    16@1 DEC:5 ts=ref()/NOACTUAL
```

The PACKAGE column is byte-identical between golden and BOTH our binaries —
it is the gate's own positive control, and it is r11u81's landed law standing
untouched under this one.

### 3.4 `m4_ctx86` — THE CONTEXT AXIS

The same three spellings read from a module localparam, a module parameter
DEFAULT, an instance override, a nested pattern, a `'{default: …}` pattern, a
packed ARRAY pattern and a generate-block home.  **GOLDEN's encoding is uniform
across all of them** (`'d`→INT, `'o`→UINT, plain decimal untouched).  **THE LAW
IS NOT** — corrected at verification (r11v86): it writes on the NAMED-setter
roads and the generate-block home and ABSTAINS on `'{default: HOP}` and on
packed-array-pattern ELEMENTS, whose cells stay `DEC:`/`OCT:` on BOTH binaries
(`m4_ctx86` `DFLT` 4 cells + `AR` 2 cells; `r11v86repro/grid/z8_ctx86.sv`
repeats it for `'o`, 3 + 3).  That coverage gap is r11v86's RV86-2; R0 below
names only the SIZE face of those two roads.  **The SIZE is not**: `'{default: m4p::PD}`
is golden `24@7` (the MEMBER width) and the array `'{m4p::PU, m4p::PD,
m4p::PO}` is golden `24@…` (the ELEMENT width) where the named struct setters
keep the hop's own `16`/`64`.  Two of six contexts re-decide the size — R0.

### 3.5 `m5_bnd86` — THE BOUNDARIES

| member | golden | this law |
|---|---|---|
| `16'o17` | `16@9 UINT:15 d=15` | **golden's** — the digits are CONVERTED, not relabelled |
| `16'o777` | `16@9 UINT:511 d=511` | **golden's** |
| `16'd10` / `16'd0` | `16@7 INT:10 d=10` / `INT:0 d=0` | **golden's** |
| `96'd12` | `96@1 DEC:12 d=96'd12` | **untouched** |
| `65'd3` | `65@1 DEC:3 d=65'd3` | **untouched** |
| `64'd18446744073709551614` | `64@7 INT:0 d=0` | **untouched** (the overflow fence) |
| `16'dx` / `16'ox` | `16@7 INT:0` / `16@9 UINT:0` | our operand list DROPS them (r11u78's R4) |
| DIRECT `16'sd5` | `16@1 DEC:5 d=16'sd5 ts=int_typespec/S` | **untouched — byte-identical to golden on both binaries** |

The two octal cells are the law's own positive control: `16'o17` is golden
`15` and `16'o777` is golden `511`, so the write cannot be a relabelling of
digits we already hold.

### 3.6 `m6_ov86` — THE OVERRIDE

`m6_mid #(.P(16'o21), .Q(m6p::PD))`: golden's `P` cell is `16@9 UINT:17 d=17`
— the OVERRIDE's octal spelling, not the `16'd5` default's.  Our reader takes
the same answer off `getInitializer()` on both binaries, so the law follows the
override with no extra code.  **4 TO, 0 AWAY.**

### 3.7 `b1_pin86` — LAW B's ARM

One PACKAGE pattern, one spelling (`16'h5`), five setters, so the SPELLING is
the only variable:

```
   a: LH        same package, UNQUALIFIED     golden int_typespec/U[15:0]
   b: b1b::LH   same package, QUALIFIED       golden ts=-
   c: BH        other package, IMPORTED bare  golden int_typespec/U[15:0]
   d: b1a::BH   other package, QUALIFIED      golden ts=-
   e: c1::CH    a CLASS scope                 golden a REF_OBJ — no constant
```

Cells a–d are byte-identical between golden and BOTH our binaries: the pinned
branch and the landed lexical fence give the same answer on every one.  Cell e
is a construction fence the pin explains — `paClass_type` (`:2767`) reaches the
same hand-on-less clone, but with no `param_assign` match golden falls through
to the `ref_obj` at `:3005-3025` and never makes a constant at all.  (Ours
makes one; the operand KINDS already differ there, and the ScopedName fence
abstains on that spelling anyway, so no law of ours writes on it.)

### 3.8 `m7_if86` — THE INTERFACE HOME, WHERE THE LAW FIRES

**CORRECTED AT VERIFICATION (r11v86).**  This section first read "WHERE THE LAW
IS INERT", on the DEF-view `tagged_pattern` listing alone.  The ELABORATED
interface instance is a second listing and the law writes on it: § `patternHome-
IsAPackage81v` answers NO for an interface, the gate lets it through, and
`ts81probe` does not walk `interface_inst`, so the arm scored zero cells and the
write was never seen.  Read on the dumps instead
(`work@m7_if86.u.IFP` / `.IFM`, both patterns):

```
   setter        golden          pristine          law
   m7p::PU (5)   64@9  UINT:5    32@9  UINT:5      32@9  UINT:5   (R0, size)
   m7p::PD ('d)  16@7  INT:5     16@1  DEC:5       16@7  INT:5    TO
   m7p::PO ('o)  16@9  UINT:15   16@4  OCT:17      16@9  UINT:15  TO
```

**4 TO cells, 0 AWAY** — the interface home takes the SAME Value-store route the
module home does, and the law's answer is golden's on every cell it writes.  The
DEF view keeps its 24 `tagged_pattern`s on golden and on both binaries, and every
write on every arm of this pass lands AFTER the `uhdmtopModules` boundary (r11v86
measured it on all 34 arms), so the clone route the def view walks is untouched.

The sister pass's ground is `ModuleEmit.cpp`, which this patch does not edit —
but the claim that the interface-emission OBJECTS are untouched was wrong: this
law rewrites three fields on `interface_inst` `param_assign` operand constants.
`InterfaceModPort` is byte-pinned through the battery and does not move.

### 3.9 THE SCORE, per cell, on every field `ts81probe` prints

```
  m1_route86  TO=4  AWAY=0 STILL=2  WRONG2=0 EQ=10    m2_enc86   TO=12 AWAY=0 STILL=18 WRONG2=4 EQ=6
  m3_gate86   TO=12 AWAY=0 STILL=0  WRONG2=3 EQ=17    m4_ctx86   TO=8  AWAY=0 STILL=10 WRONG2=0 EQ=6
  m5_bnd86    TO=4  AWAY=0 STILL=4  WRONG2=0 EQ=1     m6_ov86    TO=4  AWAY=0 STILL=0  WRONG2=0 EQ=1
  v1_qualhop81 TO=4 AWAY=0 STILL=7  WRONG2=0 EQ=13    v12_home81 TO=1  AWAY=0 STILL=3  WRONG2=0 EQ=4
  b1_pin86    TO=0  AWAY=0 STILL=0  WRONG2=0 EQ=5  SHAPE=1                              
  m7_if86     TO=0  AWAY=0 STILL=0  WRONG2=0 EQ=0     … the other 18 arms TO=0 AWAY=0 …
  TOTAL  TO=49  AWAY=0  STILL=95  WRONG2=7  EQ=195  SHAPE=14   (27 arms carry cells)
```

**AWAY = 0 and MOVED-WRONG on the three fields this law writes = 0.**  All 7
WRONG2 cells are conversions on the law's own axis whose SIZE was already
non-golden (R0) or whose typespec is R1; scored on `VpiConstType` +
`VpiDecompile` alone, all 7 read TO.  Every one of the 14 SHAPE cells is a
kind mismatch present on BOTH binaries (a `tagged_pattern` against a constant,
the dropped unknown-digit operands, `b1_pin86`'s `ref_obj`).

---

## 4. LAW B LANDS AS A PIN, AND THE FENCES DO NOT MOVE

The brief allows either.  The measurement says the fences already ARE the
pinned rule:

| the pinned mechanism | the landed fence | agree? |
|---|---|---|
| `childType == paPackage_scope` on the setter's own name → the clone with no hand-on | `outer81 && e.syntax->kind == ScopedName` → abstain | **yes**, `b1_pin86` b/d and `v13_scope81` b/d |
| the same branch entered through a cast's argument | casts pass `outer81` through | **yes**, r11u81's `a2_castts81` |
| a hop's own declaration text is consumed before the setter is read | a hop's initializer clears `outer81` | **yes**, `v5_chain81` op2 |
| `paClass_type` (`:2767`) is the same shape | `ScopedName` covers `cls::X` too | **yes**, `b1_pin86` e |
| a DOTTED hierarchical name takes the `else` at `:2806`, not `:2723` | the fence is inside a `NamedValue`-only arm, and slang spells a dotted name `HierarchicalValueExpression` | **yes — the fence cannot mis-fire on one** |

**A pin that widens nothing costs nothing.**  No fence is refined, no line of
the typespec law is touched, and RV81-1 is CLOSED: the branch is named, quoted
and reproduced on a five-cell arm.

---

## 5. CENSUS, A PRIORI, WITH ITS POSITIVE CONTROL

`census86.py` — the DEC-AWARE lister r11u81's `census81.py` could not be
(it classified every bare-NAME setter as a candidate and sighted 89 of them;
this law writes on a strict subset of those, the ones whose hop chain ends at a
`'d`- or `'o`-based literal).  Population, taken through the committed
`census68_base` (r11u72repro) rather than a copy: EVERY element of EVERY
`'{...}` span in a parameter context.

```
  AGREE86  15198      HOP86D  0      HOP86O  0      HOP86U  236
  candidate tests (all HOP86U): 20
  ariane  Ariane2024  ArianeElab  ArianeElab2
  AssignmentPatternInAssignmentPattern  AzadiRTL  BadScope  BlackBePipeInt
  black-parrot  Earlgrey_0_1  Earlgrey_nexysvideo  Earlgrey_Verilator_0_1
  Earlgrey_Verilator_01_05_21  EnumConstElab  FuncStructVal  IncompTitan
  Opentitan  Rp32  Verilator  wav-lpddr-hw
```

**THE CENSUS IS ZERO ON BOTH WRITE CLASSES**, across
`~/git-repos/uhdm2rtlil/tests`, `~/git-repos/Surelog/tests` and
`~/git-repos/Surelog/third_party/tests` — not one corpus setter in 15434
resolves to a `'d`- or `'o`-spelled hop.  `HOP86U` is the superset-by-ignorance
class: a NAME setter whose chain cannot be resolved IN FILE.  Sampling it by
hand shows why it is not a write population — `dm::DataAddr = 1'b1`,
`PRIV_LVL_U = 2'b00`, `DBG_CAUSE_NONE = 3'h0`, `AES_128`, `FlashPartData` and
the rest are ENUM MEMBERS in cross-file packages, not parameters at all, and
`red86HopName86` requires `SymbolKind::Parameter`; their spellings are `'b`/`'h`
besides.

**THE POSITIVE CONTROL FOR THE ZERO** (a census zero needs one): the same
classifier run over this pass's own grid sights `m1_route86` as HOP86D and
`m2_enc86` / `m3_gate86` / `m4_ctx86` / `m5_bnd86` / `m6_ov86` as HOP86D **and**
HOP86O, while the NEGATIVE control leaves six arms unsighted
(`a4_posmod81`, `b1_pin86`, `v13_scope81`, `v2_store81`, `v3_real81`,
`v4_xdig81` — every one of them a pattern with no `'d`/`'o` name setter).
`SELFTEST PASS`.

**THE CROSS-FILE CONFIRMATION.**  `HOP86U` is resolved IN FILE only, so the
zero was re-tested without that limit: each of the **78 distinct** HOP86U names
was searched across all three corpus roots for a
`parameter|localparam <name> = <'d or 'o literal>` declaration in ANY file.
**0 hits.**  The census zero is not an artefact of single-file resolution.

**A PRIORI MOVER SET: EMPTY.**  No canary is in the candidate set — `SVSwitch`,
`YosysVerx`, `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`,
`ParamOverloading` and every UVM row are absent; `Earlgrey_0_1` appears only
through the two cross-file ENUM names above.  **MEASURED MOVERS: 0 on 1608 u2r
databases and 0 attributable movers on the surelog ones** — the prediction met
exactly.

---

## 5b. GATES — ALL MANDATORY, ALL GREEN

**1. BUILD.**  `-j 2` in this pass's own worktree, md5 taken separately, both
binaries frozen `chmod 555` before any sweep.  Pristine
`23aace417bcebd92ef0afde8a20a8a1e` — **byte-identical to the main tree's
`build/slang-uhdm` at `85da93e6`**, the value the brief pins.  Law
`7a4c780d71aa71fd643b77e4314676b4`.  Every `cmds.txt` audited by ABSOLUTE
binary path: **0 name the main tree** on either binary (the handful with no
`slang:` line at all are the `SURELOG_FAIL`/`UNTRANSLATABLE` rows).

**2. GOLDENS.**  `23 PASS / 0 FAIL` on the law binary; `SLANG_UHDM=/bin/false`
gives `0 PASS / 23 FAIL` — the negative control.

**3. uhdm2rtlil, BOTH MODES.**  `788 / 16 / 67` in each mode on each binary.
The 1742-row BOTH-MODE join against the committed
`results/golden_uhdm2rtlil.csv` is **DIFF=0** — no field, no `ONLY-NEW`, no
`ONLY-BASE`; the testflags rows against `results/gate_uhdm2rtlil.csv` PASS; and
the join against this pass's own pristine sweep PASSes in both modes.
`byteverify` **MOVERS 0 / 1608**, selfcheck 1607/1608 — the a-priori EMPTY
mover set met exactly, with the selfcheck proving the comparator can see.

**4. Surelog, `--mode both`.**  `474 / 9` default + `469 / 8` testflags on EACH
binary, and every other bucket at the committed count (`DEFERRED` 5+5,
`SLANG_REJECT` 285+286, `SURELOG_FAIL` 25+23, `NO_DATABASE` 3, `NO_UHDM` 1,
`TIMEOUT` 1, `UNTRANSLATABLE` 2).  Against the committed
`results/golden_surelog.csv`, **four rows differ and not one is a status
change**:

* `Earlgrey_0_1` default and testflags — the DUMP COLUMN reads blank where the
  baseline reads `differ`; the status is `CMP_EQUAL` in both modes, the
  PRISTINE sweep drew the SAME blank, and the actual pin (the database
  byte-compare) never moved.  The documented `uhdm-dump` TIMEOUT draw under
  load.
* `LowMemLib` and `LowMemPkg` testflags — both `SURELOG_FAIL` on both sides;
  the DETAIL string embeds the sweep's own workdir path, so the rows differ by
  `/tmp/m187base/sl/wd` against `/tmp/r11u86_wd/...`.  GOLDEN-side, our binary
  not implicated.

Against this pass's own PRISTINE sweep only the two `LowMem` path strings
differ, and `results/*.csv` is untouched (`git status --porcelain results/` is
empty).

**5. byteverify surelog.**  **MOVERS 3 / 960**, selfcheck 959/960, and all
three are the UVM coin, attributed ORDER-BLIND on path-normalised sorted dumps:
`MiniAmiq`/default, `MiniAmiq`/testflags and `SeqDriver`/testflags each move
**exactly 4 sorted lines**, one `UINT`/`vpiDecompile` PAIR holding a LINE
NUMBER (`890↔980`, `1319↔774`, `933↔1136`).  **Zero `vpiConstType`, zero
`vpiSize`, zero `vpiTypespec` lines in any of them** — the three fields this
law writes appear in none.

**COIN POSITIVE CONTROL**: the PRISTINE binary ALONE, five runs of MiniAmiq's
own invocation in one directory writing one name, gives **five distinct
databases** (`78e5b80de859`, `f0448d2eb18c`, `6b5f988d737b`, `c7f04205883b`,
`3a54c6fa9bba`), and two of them differ by exactly that 4-line
`UINT`/`vpiDecompile` line-number class (`1314 ↔ 1118`).  A mover COUNT is a
draw; the CLASS is the measurement.

**6. Canaries and pins.**  `canaries.sh` surelog `ok=50 changed=2` — the two
changed are the `Earlgrey_0_1` dump-column cells of gate 4, status unchanged
and identical on the pristine sweep; u2r `ok=8 changed=0`.  `ctcan2.sh` **PASS**
on both corpora (`ok=58` / `ok=1`, `changed=0`).  `canaudit.sh` **PASS**,
`audited=29 UNCOVERED=0 FENCE-BREACH=0`.  Every protected database
**byte-identical between the two binaries and at exactly the pinned md5s**:
SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort
`59a365f3ce2c`, Earlgrey_0_1 `8bdf25272e08` (default) / `59d0ee6d10c3`
(testflags), plus BlackParrotComplex and YosysOldOr SAME in both modes.

**7. The conversion rows, on the official `uhdm-cmp` with golden as LHS.**
BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM (both modes), Scoreboard (default;
testflags is SLANG_REJECT, no database), `ParamOverloading` (both modes — the
row r11u81's first cut regressed) and `Earlgrey_0_1` (both modes) all read
**0 cmp lines / 0 heads**.  Rggen/default unchanged at 64/1.

**8. THE WIDE BOUNDARY.**  **3384 arms** (every `*/grid/*.sv` plus every
`dut.sv` and `design.sv` under `tools/probe`, this pass's eight included):
**3336 SAME, 9 DIFFERS, 39 NODB**, and every NODB arm has `prc == lrc` (one arm
segfaults identically on both binaries).  **CORRECTED AT VERIFICATION
(r11v86)**: this pass first reported 3383 arms and 8 DIFFERS, having lost
`m7_if86` — the arm §3.8 wrongly called inert.  The nine are `m1_route86`,
`m2_enc86`, `m3_gate86`, `m4_ctx86`, `m5_bnd86`, `m6_ov86`, **`m7_if86`**, and
the two committed arms whose module-route cells the grid already scored,
`v1_qualhop81` (TO=4) and `v12_home81` (TO=1).  Eight were named a priori, the
ninth was not; every one of the nine moves only `vpiConstType`/`vpiValue`/
`vpiDecompile` and every moved cell reads golden's value.  Across all 34 arms
the whole pristine→law dump delta is confined to those three field classes —
**zero lines of any other class** (r11v86).  The wide boundary is the gate that
alone convicts a corpus-invisible regression, and it is the gate that caught
this mis-report.

**9. `results/*.csv` UNTOUCHED**; fence check: none of the four slang-fenced
names appears in any driver or record here (`canaudit.sh FENCE-BREACH=0`), and
no test of theirs was ever dispatched.  `ModuleEmit.cpp` — the sister pass's
ground — is not in the patch.

---

## 6. RESIDUES

* **R0 — THE MODULE ROUTE'S SIZE FACE IS MEASURED AND NOT LANDED.**  The other
  half of r11v81's RV81-2.  Golden's module-route `VpiSize` is the simple Value
  store's (`Value.h:200` / `:872`), and `SValue(uint64_t)`'s hard-coded
  `m_size = 64` (`Value.h:176-179`) is where the `UINT:5@64` comes from:

  ```
    hop spelling       golden        ours    where
    5   (pkg hop)      64            32      m1 A_PP/A_PM, m2, v1 QM/IM, v12, m4
    5   (module hop)   32            32      EQUAL — the module's own store
    'd5 / 'h5          -1            32      unsized: the producer never sized it
    -5 / 5+1 / $clog2  64            32      an unsized operand's reduced word
    -16'd5 / 16'd9+16'd1  16         32      a SIZED operand's reduced word
    16'b101            16            24      r11u66's binary re-encoding residue
  ```

  It is NOT landed because `m4_ctx86` measures the size being RE-DECIDED after
  the substitution in two of six contexts — `'{default: m4p::PD}` is golden the
  MEMBER width `24` and a packed-array pattern is golden the ELEMENT width `24`,
  where the named struct setters keep the hop's own — and no gate separating
  those from the four that keep it was found.  Writing 64 on the `default:`
  road would have cost an AWAY cell on an already-correct size.  ~6 cells per
  module-route arm, all of them STILL on both binaries.

* **R1 — THE `16'sd5` HOP'S LEFTOVER SIGNED TYPESPEC.**  `m2_enc86` op12 and
  `m3_gate86` op5: golden's module-route `'sd` hop is `16@7 INT:5 d=5` with
  **ts=-**, and our literal path has already hung the literal's signed
  `int_typespec`.  This law moves the three value fields to golden and leaves
  the typespec, because REMOVING one is r11u81's ground and a replace, not an
  add.  The direct spelling is the control that says our write is right where
  it belongs: `m5_bnd86` op10, a DIRECT `16'sd5`, is golden `DEC:5 d=16'sd5`
  WITH the signed typespec and byte-identical on both binaries.  r11u81's RV-4
  family.

* **R2 — THE CLASS-SCOPE SPELLING MINTS NOTHING.**  `b1_pin86` op e: golden's
  `c1::CH` setter is a `ref_obj`, ours a constant.  The pin explains it
  (`paClass_type` at `:2767` finds no `param_assign` for a class-scoped
  localparam and falls to the `ref_obj` at `:3005-3025`), the operand KINDS
  already differ so no verdict of ours moves, and the ScopedName fence abstains
  on that spelling regardless.  Unclaimed, one cell.

* **R3 — OUR OPERAND LIST IS SHORTER ON TWO ARMS.**  `m5_bnd86` drops the two
  unknown-digit hops golden keeps as `INT:0`/`UINT:0` (r11u78's R4) and
  `m4_ctx86` emits one sink section fewer than golden.  Both are present on
  BOTH binaries and neither is this law's ground; they are why `SHAPE` is
  nonzero and why the scorer reports it separately.

* **R4 — `ts81probe`'s KEY, FIXED IN THE SCORER AND NOT IN THE PROBE.**
  r11v81's RV81-3.  `score86.py` keys on the section ORDINAL; the probe binary
  still prints a colliding name and a future generation should key its OUTPUT
  on the parameter's full path.

* r11u81's RV-1 … RV-8 and r11v81's RV81-1 … RV81-4 were re-read here.  RV81-1
  is CLOSED by §1.2's pin.  RV81-2 is HALF closed: the encoding face is this
  law, the size face is R0.  RV81-3 is worked around (R4).  None of the others
  is contradicted.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp 85da93e6 && git worktree add /tmp/wtl 85da93e6
(cd /tmp/wtl && git apply -3 /tmp/r11u86.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm
done            # 23aace417bce…  and  7a4c780d71aa…
G=/tmp/g86 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u86repro/{score86.py,census86.py,run66.sh,ts81probe.cpp} $G/
cp $R/r11u86repro/grid/*.sv $R/r11u81repro/grid/*.sv $R/r11v81repro/grid/*.sv $G/grid/
#   (m7_if86 is read with `diff` on the dumps, not the scorer — it has no cells)
(cd $G && g++ -O1 -std=c++20 ts81probe.cpp -o ts81probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm   # TAGS THE SAME
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wtl/build/slang-uhdm   # LENGTH (RV-7)
done
python3 $G/score86.py $G/grid pris lawx   # TO=49 AWAY=0 WRONG2=7 EQ=195 SHAPE=14
# the scorer's own positive control (TO must become AWAY):
cp -r $G/grid/o_m1_route86_lawx $G/grid/o_m1_route86_swpA
cp -r $G/grid/o_m1_route86_pris $G/grid/o_m1_route86_swpB
python3 $G/score86.py $G/grid swpA swpB m1_route86        # AWAY=4
python3 $G/census86.py --selftest && python3 $G/census86.py \
   ~/git-repos/uhdm2rtlil/tests ~/git-repos/Surelog/tests \
   ~/git-repos/Surelog/third_party/tests
# the corpora, per binary, with SLANG_UHDM exported and the workdir names the
# SAME LENGTH (the database embeds the workdir — r11u81's RV-7):
#   verify_golden.py --corpus uhdm2rtlil --mode {testflags,default} --jobs 3
#   verify_golden.py --corpus surelog    --mode both               --jobs 3
# the wide boundary (every committed probe arm plus this pass's seven):
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wtl/tools/probe BND_OUT=/tmp/bnd86 \
#     xargs -P 3 -n 1 bash $R/r11u86repro/bnd72.sh < armlist.txt
```
