# r11u87 — the module route's signed store carries a typespec, and its `'d` hop keeps the literal's width

**THE OTHER TWO WRITES OF THE MINT r11u86 LANDED, ONE BATCH, EACH DROPPABLE
ALONE.  LAW A (r11v86's RV86-A): `CompileExpression.cpp:3032-3040` closes with
`if (sval->isSigned())` and hangs a BARE signed `int_typespec` on the constant
it has just minted — and we hang none.  LAW B (r11v86's RV86-C + r11u86's R0):
the same mint's `VpiSize(sval->getSize())` is the ELABORATED constant's width,
and `adjustSize` keeps a `vpiDecConst`'s WRITTEN width where it re-sizes every
other const type to the declaration's — so a `'d` hop is golden the literal's
width and ours reads the declared one.  Both are decoded to the producer line
that sets them, both are gated on the THREE discriminators that cost AWAY cells
when they are missing: the hop's HOME, the OVERRIDE, and
§ patBailStopsMemberStamp68's member stamp.**

Base `a4ecc5e5`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68).  Every golden here is a real Surelog v1.87 run
through the committed `r11u86repro/run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`: **all 42 grid arms read `0 0 0` on both binaries.**

| binary | md5 | what |
|---|---|---|
| pristine | `7a4c780d71aa71fd643b77e4314676b4` | built in this pass's own worktree at `a4ecc5e5` — **byte-identical to the main tree's `build/slang-uhdm`** |
| law | `1d7da4f02cf5b6dd77bf8702f9abdd02` | this patch |
| pad control | `7a0565097dc1a23e928a596f22ef9b68` | PRISTINE + a 16 KB `volatile char` and NO law code (§5b.8) |

All three frozen `chmod 555` before any sweep; every `cmds.txt` audited by
ABSOLUTE binary path, **0 naming the main tree** on either sweep.

---

## 1. THE PRODUCER, LINE BY LINE — WHICH STORE ANSWERS, AND WHAT IT CARRIES

r11u86 decoded the FORK (`CompileExpression.cpp:2876`, `sval =
instance->getValue(name)`, and the `else` at `:3027-3041` that mints when the
store is valid).  This pass decodes the STORE ITSELF, because both remaining
fields are properties of it and not of the mint.

### 1.1 `instance->getValue(name)` is the ONE-ARG lookup

`instance` is a `ValuedComponentI*` and the call has ONE argument, so it is
`ValuedComponentI::getValue(name)` — the instance's own `m_paramMap`, then the
DEFINITION's, then the parent scope's.  It is **not**
`ModuleInstance::getValue(name, exprBuilder)`, which takes two and rebuilds a
value off the netlist's `param_assigns`.  That matters: the two fill the store
by different routes and only one of them ever sets the signedness.

### 1.2 The MODULE road — `DesignElaboration.cpp:2505-2646`

```cpp
for (FileCNodeId param : module->getObjects(paParam_assignment)) {
  if (overridenParams.find(name) == overridenParams.end()) {     // :2510
    …
    UHDM::expr* expr = compileExpression(…, Reduce::Yes, …);
    if (expr->UhdmType() == uhdmconstant) {
      if (ts) { adjustSize(ts, …, c);                            // :2562
                if (c->Typespec() == nullptr) c->Typespec(ref(ts)); }
      value = m_exprBuilder.fromVpiValue(c->VpiValue(), c->VpiSize());  // :2578
      value->setTypespec(cts ? cts : ts);
      if (ts) valueRange(value, ts, cts ? cts : ts, …);           // :2585
    }
    …
    instance->setValue(name, value, …);                          // :2645
```

* `fromVpiValue` (`ExprBuilder.cpp:978-1061`) builds an `LValue` through
  `set(v, Type, size)` for every SIZED value — and that setter writes
  `m_signed = false` (`Value.h:497-506`).  **No store is signed when it is
  built.**
* `valueRange` (`CompileHelper.cpp:5502-5584`) is the only caller of
  `setSigned` in the whole producer.  It reads `VpiSigned` off an
  `int_typespec`, a `logic_typespec` or a `bit_typespec` — **and off nothing
  else**; every other typespec kind leaves `isSigned` false.  It runs only
  `if (ts)`, i.e. only when the parameter HAS a typespec.
* the OVERRIDDEN parameters never enter this loop at all (`:2510`), so their
  stores are built elsewhere and `valueRange` never touches them.

### 1.3 The PACKAGE / definition road — `CompileHelper.cpp:3754-3772`

```cpp
int32_t size = c->VpiSize();
if (ts) { sizetmp = Bits(ts, …); if (!invalidValue) size = sizetmp; }
adjustSize(ts, …, c);
if (size <= 64) { Value* val = fromVpiValue(c->VpiValue(), size);
                  component->setValue(the_name, val, m_exprBuilder); }
```

`Bits(ts)` overrides the width for EVERY const type, `'d` included, and there
is **no `setSigned` call anywhere on this road**.  So a package-homed hop is
golden unsigned and golden `Bits(ts)`-wide — which is what our own emission
already writes, and why both laws gate on the hop's home.

### 1.4 `adjustSize`'s one exception — `CompileHelper.cpp:4086-4088`

```cpp
int32_t size = orig_size;
if (c->VpiConstType() != vpiDecConst) { if (!invalidValue) size = sizetmp; }
```

and every arm of the switch below ends at `c->VpiSize(size)`.  A `vpiDecConst`
therefore keeps the width the LITERAL was written with, whatever the
declaration says; an `'o`/`'h`/`'b` constant is re-sized to `Bits(ts)`.

### 1.5 The mint's fifth line — `CompileExpression.cpp:3032-3040`

```cpp
if (sval->isSigned()) {
  int_typespec *ts = s.MakeInt_typespec();
  ts->VpiSigned(true);
  ref_typespec *rt = s.MakeRef_typespec();
  rt->VpiParent(c); rt->Actual_typespec(ts);
  c->Typespec(rt);
}
```

A **bare** `int_typespec`: no name, no ranges, and the same kind whatever the
declaration's own typespec was (a `logic signed [15:0]` hop is golden
`int_typespec/S`, measured).  `int_typespec::Compare` reads `VpiSigned` and the
dump prints no children under it, so `ts81probe`/`ts87probe` is the instrument.

---

## 2. THE TWO LAWS

### § modHopSignedStoreTs87 — `src/ParamEmit.cpp`, written after the encoding law

```
for each elaborated struct-pattern operand that is a constant:
  the pattern's home is NOT a package        (pkgPat81, the landed gate)
  the operand carries NO typespec            (ADD-ONLY)
  the cell holds one of the six integral const types the store can render
  the setter is a hop spelled as a BARE NAME (red87BareHop87 — no cast)
  the producer's reduce does not refuse      (patAstRefuses68 / red72Int64)
  red87StoreSigned87(hop):
      not overridden, home is an InstanceBody or a GenerateBlock,
      an EXPLICIT declared type, the type is SIGNED, and its canonical kind
      is a ScalarType / a packed array of one / `int`
  ->  Typespec(ref -> int_typespec with VpiSigned(true))
```

### § modHopStoreSizeIsTheLiteral87 — beside it, droppable alone

```
same pattern-home, hop, reduce and const-type gates, plus
  the operand index is PAST § patBailStopsMemberStamp68's bail
  red87StoreSize87(hop):
      not overridden, home is an InstanceBody or a GenerateBlock,
      the initializer is a `'d` literal          -> (DEC, its written width)
      the initializer is another hop             -> (not DEC, that hop's size)
      the declaration has an explicit type       -> keep it only when DEC
      the declaration is implicit                -> take it as it is
  ->  VpiSize(that width)
```

Both readers are new inlines in `src/EmitHelpers.h`
(`red87BareHop87`, `red87HopHomeIsInstance87`, `red87HopDeclaredType87`,
`red87StoreSigned87`, `red87StoreSize87`); everything else is r11u86's and
r11u81's.  The only other production edit is HOISTING r11u68's `bail68` out of
its own `if` block so the size law can read the same index.

---

## 3. THE GOLDEN GRID — 42 ARMS, EIGHT OF THEM NEW

Read with `ts87probe` (this pass's lister: `ts81probe` plus the INTERFACE,
GEN-SCOPE and instance-array homes r11v86's RV86-1 found it blind to) and
scored PER CELL with `score87v.py` (r11v86's alignment-aware `score86v.py`,
probe swapped).

### 3.1 `y1_sgnd87` — THE SIGNED TRUTH TABLE, DECLARATION BY DECLARATION

Sixteen declarations, three MODULE patterns, 24-bit members, operand 0 a
guaranteed bail.  Golden's operand typespec, and its size beside it:

| hop declaration | golden | ours (pristine) |
|---|---|---|
| `int YIN = 16'd5` | `16 INT:5 int_typespec/S` | `32 INT:5 ts=-` |
| `int signed YIS = 16'd5` | `16 /S` | `32 -` |
| `int unsigned YIU = 16'd5` | `16 ts=-` | `32 -` |
| `logic signed [15:0] YLS` | `16 /S` | `16 -` |
| `logic [15:0] YLU` | `16 ts=-` | `16 -` — EQUAL |
| `bit signed [15:0] YBS` | `16 /S` | `16 -` |
| `bit [15:0] YBU` | `16 ts=-` | EQUAL |
| `reg signed [15:0] YRS` | `16 /S` | `16 -` |
| `signed [15:0] YSG = 16'o17` | `16 UINT:15 /S` | `16 -` |
| `int YIO = 16'o17` | `32 UINT:15 /S` | `32 -` |
| `byte YBY = 8'd5` | `8 ts=-` | EQUAL |
| `shortint YSH = 16'd5` | `16 ts=-` | EQUAL |
| `integer YIG = 16'd5` | `16 ts=-` | `32 -` |
| `longint YLG = 16'd5` | `16 ts=-` | `64 -` |
| `typedef logic signed [15:0]` | `16 /S` | `16 -` |
| `typedef bit [15:0]` | `16 ts=-` | EQUAL |

**`byte`, `shortint`, `integer` and `longint` are SIGNED in SystemVerilog and
golden writes NOTHING on them** — the producer's switch names only
`int_typespec` / `logic_typespec` / `bit_typespec`, and those four have their
own typespec kinds.  That row is the whole reason this law reads the KIND and
not just `isSigned()`.  **TO=32, AWAY=0.**

### 3.2 `y3_home87` — THE HOME, AND THE EIGHT CELLS THAT MUST NOT MOVE

One package and one module carrying the SAME three declarations, read into two
patterns in the same module, bare and qualified:

```
   setter                  golden            ours (pristine)   this law
   PIN   package int       32   ts=-         32   ts=-         UNTOUCHED
   PSG   package signed    16   ts=-         16   ts=-         UNTOUCHED
   PDU   package untyped   16   ts=-         16   ts=-         UNTOUCHED
   PIO   package int 'o    32   ts=-         32   ts=-         UNTOUCHED
   PLS   package logic/S   16   ts=-         16   ts=-         UNTOUCHED
   y3p::PIN qualified      32   ts=-         32   ts=-         UNTOUCHED
   MIN   module  int       16   /S           32   ts=-         BOTH LAWS
   MSG   module  signed    16   /S           16   ts=-         LAW A
   MDU   module  untyped   16   ts=-         16   ts=-         UNTOUCHED
```

The `P` section is the home gate's positive control: **the package road's
`int PIN = 16'd5` is golden 32**, the declaration's width, because
`CompileHelper.cpp:3759` overrides the width for every const type.  Writing the
literal's 16 there would have been an AWAY cell on every one of its eight
operands.  **TO=10, AWAY=0.**

### 3.3 `y6_ovw87` — ONE MODULE, TWO INSTANCES, TWO ANSWERS

`y6_mid #(.P(32'd9), .Q(16'o21), .S(9), .T(8'd3))` beside a bare `y6_mid`, each
override written at a DIFFERENT width from its default:

```
   hop (declaration / override)        golden OVERRIDDEN   golden DEFAULT
   int P = 16'd5   <- 32'd9           32  ts=-            16  /S
   int Q = 32'o7   <- 16'o21          16  ts=-            32  /S
   int S = 16'd4   <- 9               64  ts=-            16  /S
   logic signed [15:0] T <- 8'd3       8  ts=-            16  /S
```

**The same declaration, signed on one instance and unsigned on the other** —
`overridenParams` at `DesignElaboration.cpp:2510`.  Both laws therefore decline
an overridden hop whole: LAW A because golden writes no typespec there, LAW B
because the width is the OVERRIDE's and this reader cannot name it (the
override's own expression is not the initializer it reads).  Four STILL cells
per section, zero AWAY.  **TO=14, AWAY=0.**

### 3.4 `y4_size87` — THE SIZE TABLE

| hop | golden | ours (pristine) | this law |
|---|---|---|---|
| `int YI8 = 8'd5` | `8` | `32` | **golden's** |
| `bit [31:0] YB8 = 8'd5` | `8` | `32` | **golden's** |
| `logic [3:0] YL32 = 32'd5` | `32` | `4` | **golden's** |
| `int YUN = 'd5` | `-1` | `32` | **golden's** |
| `int YOO = 16'o17` | `32` | `32` | EQUAL — `'o` takes the declaration |
| `bit [7:0] YO8 = 16'o777` | `8` | `8` | EQUAL |
| `int YPL = 5` | `32` | `32` | EQUAL |
| `logic [95:0] YW = 96'd12` | `96 INT:12` | `96 DEC:12` | untouched — R2 |
| `int YC2 = YC1` (`int YC1 = 16'd5`) | `32` | `32` | EQUAL — the CHAIN is re-sized |
| `bit [7:0] YT8 = 16'd300` | `16` | `8` | **golden's** |
| `shortint YTS = 32'd70000` | `32` | `16` | **golden's** |

The chain row is the reader's own fence: a hop over a hop is substituted by the
MINT, whose const type is `INT:`/`UINT:` and never `DEC:`, so the outer hop's
`adjustSize` DOES re-size it — and the same chain written WITHOUT a declared
type keeps the inner's width (`y2_face87` `YC2`, golden 16 where ours reads
32).  **TO=24, AWAY=0.**

### 3.5 `y8_nob87` — THE MEMBER STAMP, AND WHY THE TWO FIELDS OBEY DIFFERENT RULES

The same two signed hops read once from a pattern with NO bailing operand and
once from a pattern whose first operand is the usual unknown-digit bail:

```
   pattern                  golden          pristine        this law
   '{p: YIN, q: YSG, r: YDU}   24@7 /S       24@7 ts=-       24@7 /S   (LAW A only)
                               24@9 /S       24@9 ts=-       24@9 /S
                               24@7 ts=-     24@7 ts=-       24@7 ts=-
   '{p: 8'hxA, q: YIN, r: YSG} 24@5 ts=-     the same        the same
                               16@7 /S       32@7 ts=-       16@7 /S   (BOTH)
                               16@9 /S       16@9 ts=-       16@9 /S
```

**`expandPatternAssignment` stamps the MEMBER width on every operand and stops
at the first one its reduce refuses** (§ patBailStopsMemberStamp68, r11u68), so
in a pattern with no bail the store's WIDTH is gone from every cell — golden is
`24` on an `int` hop whose store is 16 wide — **but the TYPESPEC survives the
stamp**.  Two fields, two rules: LAW B rides the bail index, LAW A does not.
The first cut of LAW B did not, and the grid convicted it: five AWAY cells on
`z8_ctx86`'s `ZPK`/`ZAR` (both bail-free) where golden is the member width 24
and the law wrote the hop's 16.  **TO=8, AWAY=0.**

### 3.6 `y2_face87` / `y7_msc87` — THE FACES BESIDE THE BARE NAME

* a signedness CAST over a signed hop is golden the HOP's `int_typespec/S` when
  the store is `INT:` (`signed'(YIN)`, `$unsigned(YIN)`) and the `$signed`
  MINT's own `logic_typespec/S` when it is `UINT:` (`z6_sign86`'s
  `signed'(ZSO)`).  **Both laws decline the cast face whole** — the first cut
  did not and wrote the wrong KIND on two cells; the gate is `red87BareHop87`.
* an initializer that is an OPERATION, a NEGATION, `$clog2` or a type CAST
  under a signed declaration is golden `/S` and this law writes it
  (`y7_msc87` `XOP` / `XNG` / `XCL` / `XCS`, four cells): the typespec follows
  the DECLARATION, not the initializer's shape.
* `logic [15:0] YSL = 16'sd5` — declared UNSIGNED, `s`-marked literal — is
  golden `/S` and OURS ALREADY, because our literal path hung the literal's own
  signed `int_typespec`; the ADD-ONLY gate leaves it exactly as it was.
* a `16'h5` leaf under a signed declaration is golden `HEX:5` **with** `/S`
  (`y7_msc87` `XHX`) and this law writes it — the hex road takes the same mint,
  which r11u86 §1.1 mis-read as "no valid simple Value" (correction, §4).

### 3.7 THE SCORE, per cell, on every field the lister prints

```
  y1_sgnd87  TO=32 AWAY=0 STILL=0  EQ=16     y5_ovr87  TO=28 AWAY=0 STILL=7  EQ=5
  y4_size87  TO=24 AWAY=0 STILL=2  EQ=6      z7_trunc86 TO=18 AWAY=0 STILL=0 EQ=14
  y6_ovw87   TO=14 AWAY=0 STILL=10 EQ=8      y7_msc87  TO=14 AWAY=0 STILL=16 EQ=3
  z1_decl86  TO=14 AWAY=0 STILL=0  EQ=18     z6_sign86 TO=10 AWAY=0 STILL=8  EQ=14
  y3_home87  TO=10 AWAY=0 STILL=0  EQ=22     y8_nob87  TO=8  AWAY=0 STILL=3  EQ=4
  y2_face87  TO=4  AWAY=0 STILL=22 EQ=6      m2_enc86  TO=2  AWAY=0 STILL=20 EQ=18
  … the other 30 arms TO=0 AWAY=0 …
  TOTAL  TO=178  AWAY=0  STILL=180  WRONG2=0  EQ=456  SHAPE=9  MWRONG=0  UNPAIR=15
```

**AWAY = 0 and MOVED-WRONG = 0 on both fields this pass writes.**  THE
SCORER'S OWN POSITIVE CONTROL: scoring `y1_sgnd87` with the two tags SWAPPED
turns all 32 TO cells into AWAY and MOVED-WRONG (`TO=0 AWAY=32 MWRONG=32`), so
`AWAY=0` is a measurement, not a blind spot.

---

## 4. CORRECTIONS TO THE LANDED RECORD

* **r11u86 §1.1 — `'h` AND `'b` HOPS DO TAKE THE STORE.**  "`'h` and `'b` have
  no valid simple Value at all, so their cells take the clone" is wrong:
  `fromVpiValue` builds an `StValue` for them and `StValue::set` sets
  `m_valid = true`.  The mint's VALUE and SIZE happen to equal the clone's
  there, which is why the claim was untestable — but the TYPESPEC separates
  them, and `y7_msc87` `XHX` (`logic signed [15:0] XHX = 16'h5`) is golden
  `16@5 HEX:5` **with `int_typespec/S`**.  The store answers for hex.
* **r11u86's 64-BIT FENCE IS THE PACKAGE ROAD'S, NOT THE MODULE ROAD'S.**  The
  fence is real and stands — `m5_bnd86`'s `96'd12` and `65'd3` are
  PACKAGE-homed (`m5p::PW96`, `m5p::PW65`) and `CompileHelper.cpp:3770`'s
  `if (size <= 64)` is what keeps them out of the store.  A MODULE-homed
  `logic [95:0] YW = 96'd12` has no such guard and is golden `96@7 INT:12`
  where both our binaries read `96@1 DEC:12` (`y4_size87` B op1).  Recorded as
  R2; **not touched here, because the brief pins the fence**.
* **r11u86's R0 IS HALF EXPLAINED, NOT UNEXPLAINED.**  "No gate separating
  the two contexts that re-decide the size was found" — the gate is
  § patBailStopsMemberStamp68's bail index, and it is measured on `y8_nob87`.

---

## 5. CENSUS, A PRIORI, WITH ITS POSITIVE CONTROL

`census87.py` — the DECLARED-TYPE-AWARE lister (`census86.py` classifies by the
literal's base alone and cannot see LAW A, which fires on `'h`, `'b`, plain
decimals and operations too).  Population, taken through the committed
`census68_base` (r11u72repro) rather than a copy: EVERY element of EVERY
`'{...}` span in a parameter context.

```
  AGREE87  15160      SGN87  4      DEC87  0      UNR87  270
```

over `~/git-repos/uhdm2rtlil/tests`, `~/git-repos/Surelog/tests` and
`~/git-repos/Surelog/third_party/tests`.  `UNR87` is the superset-by-ignorance
class (a setter whose chain cannot be resolved IN FILE, or a declaration this
scanner will not classify); r11u86 resolved its 78 distinct names across all
three corpus roots and found them to be cross-file ENUM MEMBERS, not
parameters, and `red87BareHop87` requires `SymbolKind::Parameter`.

**THE POSITIVE CONTROL FOR THE ZERO** (a census zero needs one): the same
classifier run over this pass's own grid sights `y1_sgnd87`, `y4_size87`,
`y5_ovr87`, `y7_msc87`, `z1_decl86` and `z6_sign86` as `SGN87` and
`z7_trunc86` / `m2_enc86` as `DEC87`, while the NEGATIVE control leaves 20 arms
unsighted (`a1_hopts81`, `a2_castts81`, `a3_hopbnd81`, `a4_posmod81`,
`b1_pin86`, `m5_bnd86`, `v10`–`v14`, … — every one of them a package-homed or
literal-only pattern).  `SELFTEST PASS`.

**A PRIORI MOVER SET: FOUR NAMES, AND NOT ONE OF THEM CAN PRODUCE A DATABASE.**
The whole `SGN87` class is

```
  Earlgrey_Verilator_01_05_21   InfoSel            DEFERRED      both modes
  Earlgrey_nexysvideo           InfoSel            DEFERRED      both modes
  IncompTitan                   InfoSel            SLANG_REJECT  both modes
  Tnoc                          MAX_BYTE_LENGTH    SLANG_REJECT  both modes
```

and `Tnoc`'s is a real one — `localparam int MAX_BYTE_LENGTH = 4096;` in a
module, read into a pattern — which is exactly why the prediction is stated by
NAME rather than as a count.  All four rows are `DEFERRED` or `SLANG_REJECT` in
BOTH modes on BOTH binaries, and **no `slang.uhdm` exists for any of the eight
row-mode cells**, so no write of theirs can reach a byte.  No canary is in the
list: `SVSwitch`, `YosysVerx`, `InterfaceModPort`, `BlackParrotComplex`,
`YosysOldOr`, `ParamOverloading`, `Earlgrey_0_1` and every UVM row are absent.
**MEASURED MOVERS: 0 attributable on 2568 databases** — the six byteverify
movers are all UVM coin (§5b.5).  The prediction met exactly.

---

## 5b. GATES — ALL MANDATORY, ALL GREEN

**1. BUILD.**  `-j 2` in this pass's own worktree, md5 taken separately, both
binaries frozen `chmod 555` before any sweep.  Pristine
`7a4c780d71aa71fd643b77e4314676b4` — **byte-identical to the main tree's
`build/slang-uhdm` at `a4ecc5e5`**, the value the brief pins.  Law
`1d7da4f02cf5b6dd77bf8702f9abdd02`.  `ParamEmit.cpp` is `__LINE__`-sensitive,
so THE SHIPPED SOURCE IS THE MEASURED SOURCE was checked rather than assumed:
the deliverable patch applied to a FRESH `a4ecc5e5` worktree and built there
independently links to `1d7da4f02cf5b6dd77bf8702f9abdd02` byte for byte.

**2. GOLDENS.**  `23 PASS / 0 FAIL` on the law binary; `SLANG_UHDM=/bin/false`
gives `0 PASS / 23 FAIL` — the negative control.

**3. uhdm2rtlil, BOTH MODES.**  `788 / 16 / 67` in each mode on each binary.
The 1742-row BOTH-MODE join against the committed
`results/golden_uhdm2rtlil.csv` is **DIFF=0** on the law binary and DIFF=0 on
the pristine one; the 871 testflags rows against `results/gate_uhdm2rtlil.csv`
**DIFF=0**; law against pristine **DIFF=0**.

**4. Surelog, `--mode both`.**  `474 / 9` default + `469 / 8` testflags on EACH
binary, every other bucket at the committed count (`SLANG_REJECT` 285+286,
`SURELOG_FAIL` 25+23, `DEFERRED` 5+5, `NO_DATABASE` 3, `UNTRANSLATABLE` 2,
`TIMEOUT` 1, `NO_UHDM` 1).  Against `results/golden_surelog.csv`, **four rows
differ and not one is a status change, and the PRISTINE sweep draws the same
four**:

* `Earlgrey_0_1` default and testflags — the DUMP COLUMN reads blank where the
  baseline reads `differ`; the status is `CMP_EQUAL` in both modes and the
  database byte-compare (the actual pin) never moved.  The documented
  `uhdm-dump` TIMEOUT draw under load.
* `LowMemLib` and `LowMemPkg` testflags — both `SURELOG_FAIL` on both sides,
  the DETAIL string embedding the sweep's own workdir path.  Golden-side.

Law against pristine: only those two path strings.  `results/*.csv` untouched
(`git status --porcelain results/` empty).

**5. byteverify, BOTH CORPORA IN ONE WORKDIR PAIR** (`pris` / `lawx`, the same
length — r11u81's RV-7).  **MOVERS 6 / 2568**, `SELFCHECK` 2567/2568, path sets
identical.  All six are UVM rows and all six are the documented coin,
attributed ORDER-BLIND on path-normalised sorted dumps: `MiniAmiq` default and
testflags, `SeqDriver` default and testflags, `SimpleUVM` default move **exactly
4 sorted lines** — one `UINT`/`vpiDecompile` PAIR holding a LINE NUMBER
(`841↔1530`, `1418↔588`, `0↔1150`, `1492↔779`, `1008↔0`) — and
`Scoreboard`/default moves **0 sorted lines** (the order draw).  **Zero
`vpiSize`, zero `Typespec`, zero `vpiConstType` lines in any of them**, and
those are the two fields this pass writes.

**COIN POSITIVE CONTROL**: the PRISTINE binary ALONE, five runs of MiniAmiq's
own invocation in one directory writing one name, gives **five distinct
databases** (`ad03e4e81c67`, `cc56fc83ee7e`, `9035764ad630`, `44edca8d1f8f`,
`eb9145a353a2`).  A mover COUNT is a draw; the CLASS is the measurement.

**6. Canaries and pins.**  `canaries.sh` surelog `ok=50 changed=2` — the two
changed are the `Earlgrey_0_1` dump-column cells of gate 4, and the PRISTINE
sweep reports the same two; u2r `ok=8 changed=0`.  `ctcan2.sh` **PASS** on both
corpora (`ok=58` / `ok=1`, `changed=0`, with the documented
`EXPECT_UNKNOWN=1` / `6`).  `canaudit.sh` **PASS**, `audited=29 UNCOVERED=0
FENCE-BREACH=0`.  Every protected database **byte-identical between the two
binaries and at exactly the pinned md5s**: SVSwitch `4842211c4030`, YosysVerx
`6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 `8bdf25272e08`
(default) / `59d0ee6d10c3` (testflags), BlackParrotComplex `e3e354129d5a` /
`73a10e8217e5` and YosysOldOr `d68e0796d62c` SAME in both modes.

**7. The conversion rows, on the official `uhdm-cmp` with golden as LHS.**
BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM (both modes), Scoreboard (default;
testflags is the documented SKIP-NOFILE), `ParamOverloading` (both modes) and
`Earlgrey_0_1` (both modes) all read **0 cmp lines / 0 heads**.  Rggen/default
unchanged at 64/1.

**8. THE WIDE BOUNDARY.**  **4031 arms** (every `*/grid/*.sv` plus every
`dut.sv` and `design.sv` under `tools/probe`) plus this pass's own eight:
**3975 SAME, 13 DIFFERS, 51 NODB**, and every NODB arm has `prc == lrc` (one
segfaults identically on both binaries).  Twelve of the thirteen are this
pass's cells — `m2_enc86`, `z1_decl86`, `z6_sign86`, `z7_trunc86` and the eight
`y*` arms, every one of them named a priori by the grid score — and on all
twelve **every DELETED dump line is a `vpiSize:` line and every ADDED line
belongs to the size or the added typespec subtree: zero lines of any other
class.**

The thirteenth is `r10uvm185repro/grid185/g185_e_kinds.sv`, and it is **NOT
ours**: its moved field is an unsupported-typedef `range` bound emitted as an
ADDRESS-DERIVED `UINT:`, `23228761 → 23232857`, a delta of exactly **4096** —
one page, tracking the image size (pristine 23176744 B, law 23185128 B).  THE
16 KB-PAD POSITIVE CONTROL, required by the ops rules for a 4096-delta-only
UINT mover: a PRISTINE build carrying nothing but `volatile char
pad[16384]` and NO law code (md5 `7a0565097dc1a23e928a596f22ef9b68`, image
23193168 B) moves the SAME arm to `UINT:23245145` — **+16384, exactly the
pad**.  It is r11v11u8's documented residue, and no corpus row touches it.

**9. `results/*.csv` UNTOUCHED**; none of the four slang-fenced names appears
in any file of this patch (`canaudit.sh FENCE-BREACH=0`) and no test of theirs
was ever dispatched.  `ModuleEmit.cpp` — the sister pass's ground — is not in
the patch.  No metric in `RESUME.md` §3b or `GOLDEN_EQUIVALENCE.md` §3.3
changes: no corpus row converts, so no doc edit rides with this landing.

---

## 6. RESIDUES

* **R1 — THE `'{default: HOP}` AND ARRAY-ELEMENT ROADS ARE STILL UNWRITTEN, ON
  BOTH FIELDS.**  r11v86's RV86-B named the ENCODING gap; the TYPESPEC gap is
  the same cells.  `y8_nob87` `D` (`'{default: YIN}`) is golden `24@7 INT:5`
  **with `int_typespec/S`** on all three operands and ours is `24@1 DEC:5` with
  none, on BOTH binaries; `y7_msc87` `D` repeats it on eight.  The SIZE there
  is already golden (the member stamp), so only two of the three fields are
  open.  Unclaimed: the operand's source expression is not in `opSet68` on that
  road, which is why every law of this family abstains there.
* **R2 — THE MODULE ROUTE HAS NO 64-BIT FENCE.**  `logic [95:0] YW = 96'd12`
  in a MODULE is golden `96@7 INT:12 d=12` where both binaries read
  `96@1 DEC:12 d=96'd12` (`y4_size87`).  The landed fence is the PACKAGE road's
  `if (size <= 64)` and it is correct there (`m5_bnd86`, all package-homed).
  Relaxing it is an ENCODING write on r11u86's ground and the brief pins the
  fence, so it is recorded, not taken.
* **R3 — THE OVERRIDE'S OWN WIDTH.**  An overridden hop is golden the OVERRIDE
  literal's width (`y6_ovw87`: `32`, `16`, `64`, `8` against our uniform
  `32`/`32`/`32`/`16`), and a plain-decimal override is golden `64` — the
  `set(uint64_t)` hard-coded `m_size`.  Both laws decline the shape; the reader
  would need the override EXPRESSION, which is the instance's, not the
  parameter's initializer.  Four STILL cells per overridden section.
* **R4 — THE CAST FACE.**  `signed'(HOP)` over a `UINT:` store is golden the
  `$signed` mint's `logic_typespec/S` and over an `INT:` store the hop's own
  `int_typespec/S` (`y2_face87` A op1/op2/op4 against `z6_sign86` Z2 op3).
  `red87BareHop87` declines all of them: three STILL cells on `y2_face87`.  The
  mint's own hint is r11u81's ground (`red81HopPlan81` already writes it on the
  package road).
* **R5 — OUR GEN-SCOPE PATTERN EMITS NO `param_assign` AT ALL.**  `y5_ovr87`'s
  `gb` block is golden a full `TOPGEN G` section with `/S` on its signed hops;
  our database has no section there (measured with `ts87probe`, which walks
  gen scopes).  A SHAPE residue present on BOTH binaries, and the reason
  § modHopSignedStoreTs87's `GenerateBlock` home arm has no measured cell of
  its own — it is written for the hop DECLARED in a gen block and read from a
  module pattern.
* **R6 — `ts87probe` STILL KEYS ITS SECTIONS ON `VpiName`.**  r11u86's R4:
  several sink instances all name their parameter `R`.  The scorer aligns on
  the section LIST rather than a dict, so nothing is lost here, but a future
  generation should print the owner's full path (golden's and ours differ in
  naming, which is why this pass did not).

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp a4ecc5e5 && git worktree add /tmp/wtl a4ecc5e5
(cd /tmp/wtl && git apply -3 /tmp/r11u87.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done            # 7a4c780d71aa…  and  1d7da4f02cf5…
G=/tmp/g87 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u86repro/run66.sh $G/
cp $R/r11u87repro/{ts87probe.cpp,score87v.py,census87.py,join87.py} $G/
cp $R/r11u87repro/grid/*.sv $R/r11u86repro/grid/*.sv $R/r11v86repro/grid/*.sv \
   $R/r11u81repro/grid/*.sv $R/r11v81repro/grid/*.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts87probe.cpp -o ts87probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm   # TAGS THE SAME
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wtl/build/slang-uhdm   # LENGTH (RV-7)
done
python3 $G/score87v.py $G/grid pris lawx    # TO=178 AWAY=0 MWRONG=0 WRONG2=0
# the scorer's own positive control (TO must become AWAY):
cp -r $G/grid/o_y1_sgnd87_lawx $G/grid/o_y1_sgnd87_swpA
cp -r $G/grid/o_y1_sgnd87_pris $G/grid/o_y1_sgnd87_swpB
python3 $G/score87v.py $G/grid swpA swpB y1_sgnd87        # AWAY=32
# the census SELFTEST names arms from several repro dirs, so point it at the
# assembled grid; the scan itself takes ~2 s over all three corpus roots
GRID87=$G/grid python3 $R/r11u87repro/census87.py --selftest
python3 $R/r11u87repro/census87.py ~/git-repos/uhdm2rtlil/tests \
   ~/git-repos/Surelog/tests ~/git-repos/Surelog/third_party/tests
# the corpora, per binary, with SLANG_UHDM exported and the workdir names the
# SAME LENGTH:
#   verify_golden.py --corpus uhdm2rtlil --mode {testflags,default} --jobs 3
#   verify_golden.py --corpus surelog    --mode both               --jobs 3
#   join87.py results/golden_uhdm2rtlil.csv <tf.csv> <def.csv>     # DIFF=0
#   SELFCHECK=1 r11u86repro/byteverify.sh <lawx wd> <pris wd>      # 6 / 2568, all coin
# the wide boundary (every committed probe arm plus this pass's eight):
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wtl/tools/probe BND_OUT=/tmp/bnd87 \
#     xargs -P 3 -n 1 bash r11u86repro/bnd72.sh < armlist.txt
# the page-boundary control: a THIRD build, pristine + `volatile char
#   pad[16384]` appended to uhdm_main.cpp, must move g185_e_kinds by +16384.
```

Evidence: `evidence/{GRID87.score,CELLS87.txt,CENSUS87.txt,MOVERS87.txt,
BOUNDARY87.summary,BOUNDARY87.differs}`.
