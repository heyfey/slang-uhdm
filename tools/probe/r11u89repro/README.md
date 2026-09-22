# r11u89 — three faces of the module route's store: the flag propagates, the word fence is the package road's, and an override sets its own width

**THE THREE RESIDUES r11u87 RECORDED BESIDE ITS OWN LANDING, TAKEN IN ONE
BATCH, EACH DROPPABLE ALONE.  LAW A (r11u87's R0): `valueRange`'s signedness
is read off the ELABORATED constant's typespec (`cts`) BEFORE the
declaration's (`ts`), so a hop over a signed hop is golden `int_typespec/S`
although its own declaration is unsigned — `logic [7:0] C5 = C1` over
`int C1 = 16'd5` is golden `8 INT:5 /S`.  LAW B (R2): the `if (size <= 64)`
fence is the PACKAGE road's; the MODULE road's `instance->setValue` has none,
so `logic [95:0] YW = 96'd12` is golden `96@7 INT:12` where ours keeps `DEC`.
LAW C (R3): an overridden hop's store is sized by the OVERRIDE expression —
`#(.P(16'd5))` over `int P = 32'd1` is golden `16` where ours reads the
declaration's `32` — and beside it the DEFPARAM, measured and FENCED OUT as
the pre-existing value bug it is.**

Base `55af075f`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68).  Every golden here is a real Surelog v1.87 run
through the committed `r11u86repro/run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`: **all 47 grid arms read `0 0 0` on both binaries.**

| binary | md5 | what |
|---|---|---|
| pristine | `9096140bb63d1d277f5b060b2f5a5b58` | built in this pass's own worktree at `55af075f` — **byte-identical to the main tree's `build/slang-uhdm`**, the value the brief pins |
| law | `422938349d8030e68b7704e2faf448a5` | this patch |
| pad control | (§5b.8) | PRISTINE + a 16 KB `volatile char` and NO law code |

All frozen `chmod 555` before any sweep; every `cmds.txt` audited by ABSOLUTE
binary path, **0 naming the main tree** on any sweep.

**A CORRECTION TO THE BRIEF, FIRST.**  The brief names `w3_chain87` and
`w5_ovr87` as "committed at the base".  They are not: `git grep` at `55af075f`
finds neither string anywhere in the tree, and there is no `r11v87repro`
directory (the verifier generations that landed are `r11v84repro` and
`r11v86repro`).  Both arms were rebuilt from the residue text and are
committed here, with three more beside them.

---

## 1. THE PRODUCER, LINE BY LINE — THREE READS OF ONE STORE

### 1.1 LAW A — `valueRange`'s RHS is the CONSTANT's typespec, not the declaration's

`DesignElaboration.cpp:2576-2587`, the module road, in full:

```cpp
const std::string_view v = c->VpiValue();
value = m_exprBuilder.fromVpiValue(v, c->VpiSize());
const UHDM::typespec* cts = nullptr;
if (const UHDM::ref_typespec* rt = c->Typespec()) cts = rt->Actual_typespec();
value->setTypespec(cts ? cts : ts);
if (ts) m_helper.valueRange(value, ts, cts ? cts : ts, …);
```

and `valueRange` (`CompileHelper.cpp:5502-5584`) takes its RANGE off the FIRST
typespec and its SIGNEDNESS off the **THIRD** — `cts ? cts : ts`:

```cpp
bool isSigned = false;
type = rhstps->UhdmType();
switch (type) {
  case uhdmlogic_typespec: isSigned = ((logic_typespec*)rhstps)->VpiSigned(); break;
  case uhdmbit_typespec:   isSigned = ((bit_typespec*)rhstps)->VpiSigned();   break;
  case uhdmint_typespec:   isSigned = ((int_typespec*)rhstps)->VpiSigned();   break;
  default: break;
}
…
val->setSigned(isSigned);
```

r11u87 transcribed the `ts` branch.  The `cts` branch is the other half, and it
fires exactly when the initializer was a HOP whose own store is signed:
`CompileExpression.cpp:3032-3040` hangs a bare signed `int_typespec` on the
constant it mints, so `c->Typespec()` is non-null, the `:2562` fill-in
`if (c->Typespec() == nullptr) c->Typespec(ref(ts))` cannot run, and the
reader's own declaration never gets a vote.  Unsigned inner, no typespec, and
the declaration answers as before.

**`if (ts)` IS STILL THE OUTER GATE.**  `valueRange` is not called at all when
the parameter has no typespec, so the chain does NOT make an implicit
declaration signed — measured, `w3_chain87` `C` op1: `localparam I2 = C1` is
golden `16 INT:5 ts=-` and ours reads the same.

### 1.2 LAW B — the word fence belongs to the package road

`CompileHelper.cpp:3754-3772` (the package / definition road) ends

```cpp
if (size <= 64) {
  Value* val = m_exprBuilder.fromVpiValue(c->VpiValue(), size);
  component->setValue(the_name, val, m_exprBuilder);
}
```

with its own comment about `strtoull` saturation.  The MODULE road's
`instance->setValue(name, value, …)` at `DesignElaboration.cpp:2645` has no
such guard, and `fromVpiValue` (`ExprBuilder.cpp:978-1010`) calls
`val->set(v, Type::Integer|Unsigned, size)` with whatever `c->VpiSize()` is.
So a MODULE-homed 65-, 96- or 128-bit `'d`/`'o` hop DOES enter the store and
IS re-encoded by the mint, and a PACKAGE-homed one of the same width is not.
r11u86's landed `sz86 > 64` gate read the width; the discriminator is the
HOP's HOME.

### 1.3 LAW C — the override road never sees `adjustSize`

The named-override arm, `DesignElaboration.cpp:2185-2187`:

```cpp
UHDM::constant* c = (UHDM::constant*)complexV;   // compiled in the PARENT
const std::string_view v = c->VpiValue();
value = m_exprBuilder.fromVpiValue(v, c->VpiSize());
```

and the positional arm at `:2376-2378` identically.  No `ts`, no `adjustSize`,
no `valueRange` — which is why an overridden hop is golden BARE (landed) and
golden the OVERRIDE literal's own width (this law).  When `complexV` is not a
constant the road falls through to `evalExpr`, whose `Value::set(uint64_t)`
hard-codes `m_size = 64`: that is the unsized-plain-decimal answer.

### 1.4 THE DEFPARAM IS A FOURTH ROAD, AND IT IS FENCED OUT

slang's `ParameterBuilder.cpp:249` sets
`DeclaredTypeFlags::InitializerOverridden` only for a `#()` / config override;
a defparam takes the early `param->setValue(comp, it->second.cv, …); return;`
at `:283-287`, so `ParameterSymbol::isOverridden()` reads **FALSE** and the
symbol keeps its DEFAULT initializer.  All three laws therefore see a
defparam'd hop as an ordinary one and read its default — which is what golden
does too (`DesignElaboration.cpp:2490`'s `addDefParam` is a separate road that
does not reach this store).  Measured on `w6_dfp89` below.

---

## 2. THE THREE LAWS

### § modHopSignedStoreChain89 — `src/EmitHelpers.h`, inside `red87StoreSigned87`

```
red87StoreSigned87(P, depth):
  not overridden, home is an InstanceBody or a GenerateBlock,
  an EXPLICIT declared type                       (all three landed, unchanged)
  NEW: if the initializer is a BARE NAME naming a parameter Q
       and red87StoreSigned87(Q, depth+1)  ->  TRUE          (depth <= 8)
  else the landed declaration read, unchanged
```

ADD-ONLY twice over: the call site still requires the operand to carry NO
typespec, and the new arm can only turn `false` into `true`.

### § modWideModuleStoreEnc89 — `src/ParamEmit.cpp`, one line of § modPatHopValueStoreEnc86

```
-  if (sz86 > 64) continue;
+  if (sz86 > 64 && !red87HopHomeIsInstance87(*hw86)) continue;
```

(`hw86` is the hop `red86HopName86` already resolved; the call was `if (!…)`
and now binds it.)  Everything else about the encoding law is untouched,
including the negative-read gate and `red72WideBasedLeaf`, which is what keeps
the overflowing `96'd79228162514264337593543950335` out.

### § modOvrStoreSizeIsTheOverride89 — beside § modHopStoreSizeIsTheLiteral87

```
when red87StoreSize87 declines AND the operand carries no typespec:
  red89OvrStoreSize89(P):
      P.isOverridden(), home is an InstanceBody or a GenerateBlock,
      the initializer (= the OVERRIDE expression) is an IntegerLiteral
        with no unknown digit, and
        a `'d`/`'o`/`'h` vector literal   -> its WRITTEN width (-1 if unsized)
        a plain unsized decimal           -> 64
  ->  VpiSize(that width)
```

`red89OvrStoreSize89` is the only new inline besides the recursion;
everything else is r11u87's, r11u86's and r11u81's.

---

## 3. THE GOLDEN GRID — 47 ARMS, FIVE OF THEM NEW

Read with the committed `r11u87repro/ts87probe` and scored PER CELL with the
committed `r11u87repro/score87v.py` (r11v86's alignment-aware scorer).  The 42
landed arms are re-run unchanged beside the five new ones.

### 3.1 `w3_chain87` — THE CHAIN, DEPTH BY DEPTH (LAW A)

Sixteen declarations over `int C1 = 16'd5` / `logic [15:0] U1 = 16'd7` /
`bit signed [15:0] S1 = 16'd9`, three MODULE patterns, 24-bit members, operand
0 a guaranteed bail:

| hop | golden | ours (pristine) |
|---|---|---|
| `int C1 = 16'd5` | `16 INT:5 int_typespec/S` | the same — EQUAL (landed) |
| `logic [7:0] C5 = C1` | `8 /S` | `8 ts=-` |
| `logic [15:0] C2 = C1` | `16 /S` | `16 ts=-` |
| `int unsigned C3 = C1` | `32 /S` | `32 ts=-` |
| `bit [15:0] C4 = C1` | `16 /S` | `16 ts=-` |
| `logic [15:0] U1 = 16'd7` | `16 ts=-` | EQUAL |
| `logic [7:0] D2 = U1` | `8 ts=-` | EQUAL — the unsigned inner |
| `int unsigned D3 = U1` | `32 ts=-` | EQUAL |
| `logic [7:0] E3 = C5` | `8 /S` | `8 ts=-` — depth 3 |
| `logic [3:0] E4 = E3` | `4 /S` | `4 ts=-` — depth 4 |
| `bit signed [15:0] S1` | `16 /S` | EQUAL (landed) |
| `logic [7:0] S2 = S1` | `8 /S` | `8 ts=-` |
| `logic [23:0] S3 = S2` | `24 /S` | `24 ts=-` |
| `localparam I2 = C1` | `16 ts=-` | EQUAL — the `if (ts)` control |
| `localparam signed I3 = C1` | `32 /S` | EQUAL (landed) |

**`int unsigned C3 = C1` IS THE LAW.**  A declaration that says `unsigned` in
so many words is golden SIGNED, because the mint's typespec is read first.
**THE SIZE IS GOLDEN ALREADY ON EVERY ROW** — the mint's const type is `INT:`
and never `DEC:`, so the reader's own `adjustSize` re-sizes to the
declaration, which is what our emission writes.  This is a pure typespec ADD.
**TO=24, AWAY=0, WRONG2=0.**

### 3.2 `w4_chnn89` — THE CHAIN'S FOUR NEGATIVE CONTROLS

```
   hop                               golden        pristine      this law
   logic [7:0] N3 = A1  (shortint A1)  8 ts=-       8 ts=-        UNTOUCHED
   logic [7:0] N5 = B1 + 0             8 ts=-       8 ts=-        UNTOUCHED
   logic [7:0] M1 = O   (O OVERRIDDEN) 8 ts=-       8 ts=-        UNTOUCHED
   logic [7:0] D2 = U1  (w3, unsigned) 8 ts=-       8 ts=-        UNTOUCHED
   logic [7:0] N2 = PIN2 (int PIN2)    8 /S         8 ts=-        LAW A
   logic [7:0] N1 = w4p::PIN           32 /S        8 ts=-        DECLINED — R1
   logic [7:0] N4 = signed'(B1)        8 INT:5 /S   8 UINT:5 ts=- DECLINED — R4
   logic [7:0] N6 = $unsigned(B1)      8 INT:5 /S   8 UINT:5 ts=- DECLINED — R4
```

The recursion is the SAME reader applied to the inner hop, gates and all, not
a "the initializer mentions a signed name" test: `shortint` is signed in
SystemVerilog and `valueRange`'s switch does not name its typespec kind, so
the inner store is unsigned and the outer stays bare.  The whole `D` section
(an OVERRIDDEN inner, `w4_mid #(.O(32'd9))`) reads golden EQUAL on all eight
operands on BOTH binaries — the override gate's positive control.
**TO=2, AWAY=0.**

### 3.3 `w9_wide89` — ACROSS THE WORD BOUNDARY, MODULE BESIDE PACKAGE (LAW B)

One module pattern holding both homes at the same widths:

| hop | golden | ours (pristine) | this law |
|---|---|---|---|
| `logic [63:0] = 64'd12` | `64@7 INT:12` | the same | EQUAL (landed) |
| `logic [64:0] = 65'd3` | `65@7 INT:3` | `65@1 DEC:3` | **golden's** |
| `logic [95:0] = 96'd12` | `96@7 INT:12` | `96@1 DEC:12` | **golden's** |
| `logic [127:0] = 128'd21` | `128@7 INT:21` | `128@1 DEC:21` | **golden's** |
| `logic [95:0] = 96'o17` | `96@9 UINT:15` | `96@4 OCT:17` | **golden's** |
| `int signed = 96'd12` | `96@7 INT:12 /S` | `96@1 DEC:12 /S` | **golden's** |
| `logic [95:0] = 96'h5` | `96@5 HEX:5` | the same | EQUAL |
| an OVERRIDDEN `96'd7` hop | `96@7 INT:7` | `96@1 DEC:7` | **golden's** |
| `logic [95:0] = 96'd792…335` | `96@7 INT:0 d=0` | `96@1 DEC:792…` | untouched — R2 |
| `w9p::PW96 = 96'd12` | `96@1 DEC:96'd12` | the same | UNTOUCHED |
| `w9p::PW65 = 65'd3` | `65@1 DEC:65'd3` | the same | UNTOUCHED |
| `w9p::PW128 = 128'd21` | `128@1 DEC:128'd21` | the same | UNTOUCHED |
| `w9p::PO96 = 96'o17` | `96@4 OCT:96'o17` | the same | UNTOUCHED |

The four PACKAGE twins sit in the SAME pattern as the module hops and are the
home gate's own positive control: relaxing the fence for them would be eight
AWAY cells.  **THE OVERFLOW ROW IS THE OTHER ONE**: golden's own `parseInt64`
failed and it wrote `INT:0` — the digits are LOST — and
`red72WideBasedLeaf`'s `as<uint64_t>()` refuses that leaf outright, so this
law transcribes nothing there.  GOLDEN WRITING ZERO IS NOT A LICENCE TO
INVENT ONE.  **TO=42, AWAY=0.**

### 3.4 `w5_ovr87` — ONE MODULE, SIX INSTANTIATIONS (LAW C)

Every cell below differs from golden in the SIZE FIELD ALONE — `ct`, `v`, `d`
and `ts` are equal already:

```
   declaration              override   golden  ours   this law
   int            P = 32'd1   16'd5      16      32   golden's
   logic [15:0]   Q = 16'd2   8'd6       8       16   golden's
   int            S = 32'o3   24'o17     24      32   golden's
   logic [11:0]   T = 12'h4   4'h3       4       12   golden's
   int            U = 32'd5   7          64      32   golden's
   logic signed [15:0] V      40'd9      40      16   golden's
   logic [3:0]    W = 4'd1    7          64       4   golden's
   positional 12'd4/20'd6/9'o17/5'h3/8/33'd9
                              12/20/9/5/64/33 vs 32/16/32/12/32/16  golden's
   int            P = 32'd1   'd5        -1      32   golden's
   int            S = 32'o3   64'd5      64      32   golden's
   the SAME module left at its defaults  all eight operands EQUAL — STILL
   int            P          w5p::PSRC   32      32   EQUAL — declined
   logic [15:0]   Q          16'd6+16'd0 16      16   EQUAL — declined
   logic [11:0]   T          -5          64      12   declined — R3
   logic [15:0]   Q          8'b1010   8 BIN:1010  24 BIN:0000…1010  declined — R3
   logic signed [15:0] V     1'b1      1 BIN:1     24 BIN:0000…1     declined — R3
   int            U          16'sd7    16 ts=-     32 ts=int_typespec/S  declined
```

**THE UNSIZED PLAIN DECIMAL IS 64 WHATEVER THE DECLARATION**: `.U(7)` against
a 32-bit `int` and `.W(7)` against a 4-bit `logic [3:0]` are BOTH golden
`64@9 UINT:7`.  **THE `16'sd7` ROW IS WHY THE CALL SITE GATES ON THE OPERAND
CARRYING NO TYPESPEC**: our literal path has already hung the literal's own
signed `int_typespec` where golden's override road hung none, so the cell
cannot reach golden on the size alone and the law declines it whole rather
than leave a half-golden cell.  **THE BINARY FACE IS DECLINED FOR THE SAME
REASON** — our member stamp zero-pads the digit string to the member width and
that is a VALUE field, not a size one.  **TO=42, AWAY=0, WRONG2=0.**

### 3.5 `w6_dfp89` — THE DEFPARAM, MEASURED AND FENCED

Two instances of one module, one carrying three defparams, the other clean.
**Golden's two sections are IDENTICAL** — golden keeps the DEFAULT on every
one:

```
   declaration                  defparam   golden        ours (pristine)
   int P = 32'd1                16'd5      32 INT:1 /S   32 INT:5 /S
   logic [15:0] Q = 16'o3       8'o17      16 UINT:3     16 UINT:15
   logic signed [15:0] V = 16'd6 16'd9     16 INT:6 /S   16 INT:9 /S
   logic [7:0] H = P (a chain)  —          8 INT:1 /S    8 INT:5 ts=-
```

**THE VALUE IS WRONG ON BOTH BINARIES AND THE OTHER THREE FIELDS ARE GOLDEN
ALREADY** — `32`/`16`/`16` and `/S`,`-`,`/S`.  That is r11u87's R3 caution
measured: a pre-existing VALUE bug with its own decode, NOT touched here.  The
fence is structural rather than written: `isOverridden()` is FALSE for a
defparam, so LAW C never sees it, and LAW A/B read the DEFAULT initializer and
the DEFAULT declaration — which is what golden reads.  On the CLEAN instance
LAW A takes `H` to golden exactly (`TO`); on the defparam'd one it fixes the
typespec and leaves the value face alone (`WRONG2`, the pass's only two).
**TO=2, AWAY=0, MOVED-WRONG=0, WRONG2=2 — both named a priori.**

### 3.6 THE SCORE, per cell, on every field the lister prints

```
  w3_chain87 TO=24 AWAY=0 STILL=0  WRONG2=0 EQ=24    w5_ovr87  TO=42 AWAY=0 STILL=8  EQ=62
  w9_wide89  TO=42 AWAY=0 STILL=10 WRONG2=0 EQ=12    y2_face87 TO=14 AWAY=0 STILL=8  EQ=10
  y6_ovw87   TO=10 AWAY=0 STILL=0  WRONG2=0 EQ=22    y5_ovr87  TO=7  AWAY=0 STILL=0  EQ=33
  w4_chnn89  TO=2  AWAY=0 STILL=12 WRONG2=0 EQ=34    y4_size87 TO=2  AWAY=0 STILL=0  EQ=30
  w6_dfp89   TO=2  AWAY=0 STILL=12 WRONG2=2 EQ=16
  … the other 38 arms TO=0 AWAY=0 WRONG2=0 …
  TOTAL  TO=145  AWAY=0  STILL=189  WRONG2=2  EQ=782  SHAPE=9  MWRONG=0  UNPAIR=15
```

**EVERY MOVER ON A LANDED ARM IS NAMED**: `y4_size87` `YW` (2 cells) is
r11u87's R2 exactly, and `y2_face87` B/R (14), `y5_ovr87` B/R (7) and
`y6_ovw87` (10) are its R3 — all three of those arms carry a `#()` override
section, and the landed README records each of those cells as a STILL one.
No other landed arm moves a byte.

**THE SCORER'S OWN POSITIVE CONTROL, RUN PER LAW.**  Scoring each new arm with
the two tags SWAPPED turns every TO cell into AWAY and MOVED-WRONG:
`w3_chain87` `TO=0 AWAY=24 MWRONG=24`, `w5_ovr87` `TO=0 AWAY=42 MWRONG=42`,
`w9_wide89` `TO=0 AWAY=42 MWRONG=42`.  `AWAY=0` is a measurement, not a blind
spot, on all three laws separately.

---

## 4. CENSUS, A PRIORI, WITH ITS POSITIVE CONTROL

`census89.py` — `census87.py` extended per law, returning a SET of tags
because a setter can belong to several.  `CHN89` is LAW A's chain face (a
signed hop reached THROUGH a further hop, so the landed declaration read is
not what sights it), `WID89` is LAW B (a non-package hop whose chain ends at a
`'d`/`'o` literal written wider than 64 bits), `OVR89` is LAW C (the setter
names a PORT parameter — the only kind a `#()` override can reach).  Population
taken through the committed `census68_base`: EVERY element of EVERY `'{…}`
span in a parameter context, over `~/git-repos/uhdm2rtlil/tests`,
`~/git-repos/Surelog/tests` and `~/git-repos/Surelog/third_party/tests`.

```
  AGREE89 15154    OVR89 17    SGN87 4    UNR87 270    CHN89 0    WID89 0
```

**LAW A'S CHAIN FACE AND LAW B'S WIDE FACE ARE CORPUS-INVISIBLE: ZERO CELLS.**

**THE POSITIVE CONTROL FOR THE TWO ZEROS** (a census zero needs one): the same
classifier run over this pass's own grid sights `w3_chain87` and `w6_dfp89` as
`CHN89`, `w9_wide89` as `WID89` and `w5_ovr87` / `w6_dfp89` / `w9_wide89` as
`OVR89`, while the NEGATIVE control leaves **20 landed arms unsighted**
(`a1_hopts81`, `a2_castts81`, `a3_hopbnd81`, `a4_posmod81`, `b1_pin86`,
`m5_bnd86`, `v10`–`v14`, …).  `SELFTEST PASS`.

**A PRIORI MOVER SET: FIVE NAMES, AND NOT ONE OF THEM PRODUCES A DATABASE.**
The `OVR89` class is 17 setters in four tests and the `SGN87` class is r11u87's
same four:

```
  ariane (= the `Ariane` row)    OVR89 x17      SURELOG_FAIL  both modes
  Earlgrey_Verilator_01_05_21    OVR89+SGN87    DEFERRED      both modes
  Earlgrey_nexysvideo            OVR89+SGN87    DEFERRED      both modes
  IncompTitan                    OVR89+SGN87    SLANG_REJECT  both modes
  Tnoc                           SGN87          SLANG_REJECT  both modes
```

`ariane` is the only name r11u87 did not already carry, and it is the
`third_party/tests/ariane` directory — the `Ariane` row, `SURELOG_FAIL` in both
modes on both binaries, so the golden side never produces a reference and our
side never writes a database.  **No canary is in the list**: `SVSwitch`,
`YosysVerx`, `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`,
`ParamOverloading`, `Earlgrey_0_1` and every UVM row are absent.  The
prediction is therefore **the EMPTY mover set, stated by name**.

---

## 5. GATES — ALL MANDATORY, ALL GREEN

**1. BUILD.**  `-j 2` in this pass's own worktree, md5 taken separately, all
three binaries frozen `chmod 555` before any sweep.  Pristine
`9096140bb63d1d277f5b060b2f5a5b58` — **byte-identical to the main tree's
`build/slang-uhdm` at `55af075f`**, the value the brief pins.  Law
`422938349d8030e68b7704e2faf448a5`.  `ParamEmit.cpp` is `__LINE__`-sensitive,
so THE SHIPPED SOURCE IS THE MEASURED SOURCE was checked rather than assumed:
the deliverable patch applied to a FRESH `55af075f` worktree and built there
independently links to `422938349d8030e68b7704e2faf448a5` **byte for byte**.

**2. GOLDENS.**  `23 PASS / 0 FAIL` on the law binary; `SLANG_UHDM=/bin/false`
gives `0 PASS / 23 FAIL` — the negative control.

**3. uhdm2rtlil, BOTH MODES, BOTH BINARIES.**  `788 / 16 / 67` in each of the
four sweeps.  The 1742-row BOTH-MODE join against the committed
`results/golden_uhdm2rtlil.csv` is **DIFF=0** on the law binary and DIFF=0 on
the pristine one; the 871 testflags rows against `results/gate_uhdm2rtlil.csv`
read `PASS: every row byte-identical to the committed baseline`.

**4. Surelog, `--mode both`, BOTH BINARIES.**  `474 / 9` default + `469 / 8`
testflags on each binary, every other bucket at the committed count
(`SLANG_REJECT` 285+286, `SURELOG_FAIL` 25+23, `DEFERRED` 5+5,
`NO_DATABASE` 3, `UNTRANSLATABLE` 2, `TIMEOUT` 1, `NO_UHDM` 1); the per-mode
STATUS histogram is identical baseline → fresh.  Against
`results/golden_surelog.csv`, **four rows differ and not one is a status
change, and the PRISTINE sweep draws the same four**:

* `Earlgrey_0_1` default and testflags — the DUMP COLUMN reads blank where the
  baseline reads `differ`; the status is `CMP_EQUAL` in both modes and the
  database byte-compare (the actual pin) never moved.  The documented
  `uhdm-dump` TIMEOUT draw under load, and this sweep ran under exactly that:
  one `uhdm-dump` of `YosysOpenSparc` held a core for minutes beside it.
* `LowMemLib` and `LowMemPkg` testflags — both `SURELOG_FAIL` on both sides,
  the DETAIL string embedding the sweep's own workdir path.  Golden-side.

`results/*.csv` untouched (`git status --porcelain results/` empty).

**5. byteverify, BOTH CORPORA IN ONE WORKDIR PAIR** (`pris` / `lawx`, the same
length — r11u81's RV-7).  **MOVERS 6 / 2568**, `SELFCHECK` 2567/2568,
`PATH_SETS_IDENTICAL`.  The a-priori prediction was the EMPTY set and all six
are the documented UVM coin, attributed ORDER-BLIND on path-normalised sorted
dumps: `MiniAmiq` default and testflags, `SeqDriver` default and testflags and
`SimpleUVM` default each move **exactly four real sorted lines** — one
`UINT`/`vpiDecompile` PAIR holding a LINE NUMBER (`0↔519`, `1209↔1534`,
`952↔1003`, `1523↔769`, `740↔1185`) — and `Scoreboard`/default moves **zero**
(the order draw).  **Zero `vpiSize`, zero `Typespec`, zero `vpiConstType`
lines in any of them**, and those are exactly the three fields this pass
writes.

**COIN POSITIVE CONTROL**: the PRISTINE binary ALONE, five runs of MiniAmiq's
own invocation in one directory writing one name, gives **five distinct
databases** (`9ccb8777b4ae`, `8c6e49eedaf8`, `c09474787f40`, `0f596cbfce76`,
`7e0c2d7ae554`).  A mover COUNT is a draw; the CLASS is the measurement.

**6. Canaries and pins.**  `canaries.sh` surelog `ok=50 changed=2` — the two
changed are the `Earlgrey_0_1` dump-column cells of gate 4, and the PRISTINE
sweep reports the same two; u2r `ok=8 changed=0`.  `ctcan2.sh` **PASS** on both
corpora (`ok=58` / `ok=1`, `changed=0`, with the documented
`EXPECT_UNKNOWN=1` / `6`).  `canaudit.sh` **PASS**, `audited=29 UNCOVERED=0
FENCE-BREACH=0`.  Every protected database **at exactly the pinned md5 on the
law binary**: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 `8bdf25272e08` (default) /
`59d0ee6d10c3` (testflags), BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`
and YosysOldOr `d68e0796d62c` in both modes.

**7. The conversion rows, on the official `uhdm-cmp` with golden as LHS.**
BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM (both modes), Scoreboard (default;
testflags is the documented SKIP-NOFILE), `ParamOverloading` (both modes) and
`Earlgrey_0_1` (both modes) all read **0 cmp lines / 0 heads**:
`measured=13 SKIP-NOFILE=1 UNKNOWN-NAME=0`.

**8. THE WIDE BOUNDARY — EVERY `*.sv` UNDER `tools/probe`, NOT THE GRID GLOB**
(r11u87's own closing note: two of its writer cells sat outside the glob).
**7993 arms: 7769 SAME, 12 DIFFERS, 212 NODB**, and every NODB arm has
`prc == lrc` (208 × `rc=3`, 4 × `rc=139`, identical on both binaries).  Nine of
the twelve are this pass's own cells — the five new `w*` arms and the four
`y*` arms the grid score named a priori — and on all nine **every diff line
belongs to one of three classes: a `vpiSize` write, a
`vpiConstType`+`vpiValue`+`vpiDecompile` triple, or an ADDED
`ref_typespec → int_typespec` subtree with `vpiSigned`.  Zero lines of any
other class**, and the typespec lines are ADD-only (`>` with no `<`
counterpart).

The other three — `r10buvm22repro/g22.sv` (a both-binaries-`rc=4` arm),
`r10uvm154repro/l154_noenum.sv` and `r10uvm185repro/grid185/g185_e_kinds.sv` —
move an unsupported-typedef `range` bound emitted as an ADDRESS-DERIVED
`UINT:` by exactly **4096**, one page.  THE 16 KB-PAD POSITIVE CONTROL,
required by the ops rules for a 4096-delta-only UINT mover: a PRISTINE build
carrying nothing but `volatile char pad[16384]` and NO law code moves the SAME
three arms `23237017 → 23253433`, **+16416 — the pad's 16384 bytes plus its
32-byte alignment**, four times the law binary's page.  The value tracks the
LOADED IMAGE, not the emitter's semantics.  It is r11v11u8's documented
residue and no corpus row touches any of the three.

**9. `results/*.csv` UNTOUCHED**; none of the four slang-fenced names appears
in any file of this patch (`canaudit.sh FENCE-BREACH=0`, and a per-name `awk`
over the patch reads 0 for each) and no test of theirs was ever dispatched.
`ModuleEmit.cpp` — the sister pass's ground — is not in the patch.  No corpus
row converts, so no metric in `RESUME.md` §3b or `GOLDEN_EQUIVALENCE.md` §3.3
changes and no doc edit rides with this landing.

---

## 6. RESIDUES

* **R1 — A PACKAGE-HOMED INNER IS GOLDEN SIGNED TOO, AND AT A WIDTH WE DO NOT
  WRITE.**  `logic [7:0] N1 = w4p::PIN` over a package `localparam int PIN =
  16'd5` is golden `32 INT:5 int_typespec/S` where both binaries read
  `8 INT:5 ts=-` (`w4_chnn89` A op1).  The signedness is explained — the
  package road's `c->Typespec(ref(ts))` hands an `int` parameter's own SIGNED
  `int_typespec` in as `cts` — but the **32** is not: the reader's own
  `adjustSize` should have re-sized a non-`DEC` constant to the declaration's
  8.  Writing the typespec alone would leave a half-golden cell, so the
  recursion keeps `red87HopHomeIsInstance87` on the INNER hop and declines.
  Two fields, one undecoded road.
* **R2 — THE OVERFLOWING WIDE DECIMAL.**  `logic [95:0] YW =
  96'd79228162514264337593543950335` is golden `96@7 INT:0 d=0` — Surelog's
  `parseInt64` failed and `fromVpiValue` stored zero — where both binaries keep
  `96@1 DEC:79228…`.  `red72WideBasedLeaf` refuses the leaf, so this law writes
  nothing.  Transcribing a producer's overflow artefact is r11u73's ground
  (`patPowCastArtefact73` did it for `**` after measuring the exact bit
  pattern); it is not taken here because the digits golden lost are not
  recoverable from the refusal.
* **R3 — THE OVERRIDE SHAPES LAW C DECLINES, ALL FOUR MEASURED.**  A BINARY
  override (`8'b1010` golden `8@3 BIN:1010`, ours `24@3 BIN:0000…1010` — the
  VALUE field is wrong on both binaries, our member stamp zero-pads the digit
  string); a NEGATION (`-5` golden `64`, the reducer's unsized-arithmetic
  width); an `s`-marked literal (`16'sd7` golden `16 ts=-`, ours `32 ts=/S` —
  two wrong fields); and an `#()` override that is a HOP or an OPERATION
  (`w5p::PSRC` golden 32, `16'd6 + 16'd0` golden 16, both EQUAL to ours
  already, declined and correctly so).
* **R4 — THE CAST FACE, STILL r11u81's.**  `logic [7:0] N4 = signed'(B1)` and
  `N6 = $unsigned(B1)` over a signed `int B1` are golden `8 INT:5 /S` where
  both binaries read `8 UINT:5 ts=-` — TWO fields, a const type and a typespec.
  `red87BareHop87` declines the cast face whole (r11u87's R4) and this pass
  does not widen it, because the `UINT:`-vs-`INT:` half is the encoding law's
  ground and the two must move together.
* **R5 — THE DEFPARAM'S VALUE, UNCHANGED AND NOW MEASURED.**  Our pattern
  reaches the defparam'd value (5, 15, 9) where golden keeps the default
  (1, 3, 6), on all three declarations of `w6_dfp89` and on both binaries; the
  `sz`, `ct` and `ts` fields are golden already.  The decode is slang's
  `ParameterBuilder.cpp:283-287` early return against Surelog's
  `DesignElaboration.cpp:2437+` defparam road, and it is a VALUE pass of its
  own.  This pass fenced its three laws away from it and left the face exactly
  as it stood.
* **R6 — THE PAGE-BOUNDARY UINT ARMS ARE NOW THREE.**  `r10buvm22repro/g22.sv`
  (a both-binaries-`rc=4` arm), `r10uvm154repro/l154_noenum.sv` and
  `r10uvm185repro/grid185/g185_e_kinds.sv` all move an unsupported-typedef
  `range` bound emitted as an ADDRESS-DERIVED `UINT:` by exactly 4096.  It is
  r11v11u8's documented residue and the wide boundary now names all three; no
  corpus row touches any of them.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp 55af075f && git worktree add /tmp/wtl 55af075f
(cd /tmp/wtl && git apply -3 /tmp/r11u89.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done            # 9096140bb63d…  and  422938349d80…
G=/tmp/g89 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u86repro/run66.sh $R/r11u87repro/{ts87probe.cpp,score87v.py,join87.py} $G/
cp $R/r11u89repro/grid/*.sv $R/r11u87repro/grid/*.sv $R/r11u86repro/grid/*.sv \
   $R/r11v86repro/grid/*.sv $R/r11u81repro/grid/*.sv $R/r11v81repro/grid/*.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts87probe.cpp -o ts87probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm   # TAGS THE SAME
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wtl/build/slang-uhdm   # LENGTH (RV-7)
done
TS87PROBE=$G/ts87probe python3 $G/score87v.py $G/grid pris lawx
#   TO=145 AWAY=0 MWRONG=0 WRONG2=2
# the scorer's own positive control, PER LAW (TO must become AWAY):
for a in w3_chain87 w5_ovr87 w9_wide89; do
  cp -r $G/grid/o_${a}_lawx $G/grid/o_${a}_swpA
  cp -r $G/grid/o_${a}_pris $G/grid/o_${a}_swpB
  TS87PROBE=$G/ts87probe python3 $G/score87v.py $G/grid swpA swpB $a
done                                     # AWAY=24 / 42 / 42
GRID89=$G/grid python3 $R/r11u89repro/census89.py --selftest      # SELFTEST PASS
python3 $R/r11u89repro/census89.py ~/git-repos/uhdm2rtlil/tests \
   ~/git-repos/Surelog/tests ~/git-repos/Surelog/third_party/tests
#   CHN89 0   WID89 0   OVR89 17   SGN87 4
# the corpora, per binary, with SLANG_UHDM exported and the workdir names the
# SAME LENGTH (pris / lawx):
#   verify_golden.py --corpus uhdm2rtlil --mode {testflags,default} --jobs 3
#   verify_golden.py --corpus surelog    --mode both               --jobs 3
#   join87.py results/golden_uhdm2rtlil.csv <tf.csv> <def.csv>     # DIFF=0
#   SELFCHECK=1 r11u86repro/byteverify.sh <lawx wd> <pris wd>
# the WIDE boundary — EVERY `*.sv` under tools/probe, not the grid glob:
#   (cd /tmp/wtl/tools/probe && find . -name '*.sv' | sed 's|^\./||' | sort > armlist)
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wtl/tools/probe BND_OUT=/tmp/bnd89 \
#     xargs -P 2 -n 1 bash r11u86repro/bnd72.sh < armlist
# the page-boundary control: a THIRD build, pristine + `volatile char
#   pad[16384]` appended to uhdm_main.cpp, must move the three UINT arms by
#   +16384 where this patch moves them by +4096.
```

Evidence: `evidence/{GRID89.score,CELLS89.txt,CENSUS89.txt,MOVERS89.txt,
BOUNDARY89.summary,BOUNDARY89.differs}`.
