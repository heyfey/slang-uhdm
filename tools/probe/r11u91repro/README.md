# r11u91 — the package answers for the hop it feeds, a negative package parameter is an INT, and the census keys on the gate's own read

**THREE FACES OF THE PARAMETER STORE IN ONE BATCH, EACH DROPPABLE ALONE.
LAW A (pass-88's R0): a hop whose initializer is a BARE NAME naming a
PACKAGE parameter takes the CLONE road — `CompileExpression.cpp:2729-2751`
copies the package's elaborated constant, typespec and all — so
`valueRange`'s third argument is the PACKAGE parameter's own typespec and
`adjustSize` keeps a `vpiDecConst`'s own width: the reader's declaration gets
no vote on either field.  `logic [7:0] N = pkg::PI` over `int PI = 16'd5` is
golden `32 INT:5 int_typespec/S` where the pristine binary reads `8 INT:5
ts=-`, and `int N = pkg::PU` over `logic [15:0] PU = 16'd7` is golden
`16 INT:7 ts=-` where the pristine binary reads `32 /S` — WRONG ON BOTH
FIELDS, which is why the package REPLACES the landed declaration read rather
than adding to it.  LAW B (pass-87's R3): the package-parameter fold writes
`"UINT:" + digits`, and `UINT:-3` SERIALIZES AS ZERO — `q12_ndaparamenc`'s
only head.  A negative signed value is an `INT:`, exactly as our own general
constant encoder already says in so many words.  LAW C (r11v89's RV89-3, an
INSTRUMENT law, no production bytes): census89's wide class asks the
LITERAL's home while the landed gate reads the IMMEDIATE hop's, so a
package-fed chain was invisible to the census and visible to the law; the
re-keyed census sights it and the a-priori mover set is a strict superset
again.**

Base `0522e347`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68).  Every golden here is a real Surelog v1.87 run
through the committed `r11u86repro/run66.sh` (or `r11u88repro/rr88.sh` for the
`cont_assign` arms), and every arm records `slrc` / `ourrc` / `slerr`:
**all 58 grid arms read `0 0 0` on both binaries, all 116 arm-runs.**

| binary | md5 | what |
|---|---|---|
| pristine | `bf80949e9090df504e2cfbcf8520e1b3` | built in this pass's own worktree at `0522e347` — **byte-identical to the main tree's `build/slang-uhdm`**, the value the brief pins |
| law | `b082887a90d6b36b04792aaa2c78a2bd` | this patch |
| LAW B alone (LAW A reverted) | `689381e90a61f472603164e8668c41c8` | the drop-one control (§5.8) |
| LAW A alone (LAW B reverted) | `c43d9ba9f039ab137a77680c1f871cd9` | the drop-one control (§5.8) |
| pad control | `18582daec83498949ce50da2742d553f` | PRISTINE + a 16 KB `volatile char` and NO law code (§5.10) |

All frozen `chmod 555` before any sweep; every `cmds.txt` audited by ABSOLUTE
binary path, **0 naming the main tree** on any sweep.

**A CORRECTION TO THE BRIEF, FIRST.**  The brief says of LAW B that "the VALUE
half is the package parameter's own emitted constant, upstream of this pass's
builder", quoting r11u88's R3.  IT IS NOT.  Our own package `param_assign`
emitter writes `INT:-3 vpiSize 32 vpiConstType 7` for `localparam int P_NEG =
-3` — **byte-identical to golden at the base** — and so does the
parameter-read road (`n1_pkgneg91` `work@dut.L_PN`, golden on both binaries).
The one site that gets it wrong is `§ pkgParamFoldWidthAlways`
(`src/ExprEmit.cpp`), the fold a package-parameter READ goes through, and it
writes `"UINT:" + "-3"`, which the serializer reads back as `UINT:0`.  The
residue's decode was right about the cell and wrong about the producer.

---

## 1. THE PRODUCER, LINE BY LINE

### 1.1 LAW A — the package read is a CLONE, and the clone brings its own typespec and its own width

`CompileExpression.cpp:2717-2753`, the `paPackage_scope` arm, in `m_elabMode`:

```cpp
Package *pack = …->getPackage(packageName);
for (param_assign *param : *pack->getParam_assigns())
  if (param->Lhs()->VpiName() == n) {
    if (substituteAssignedValue(param->Rhs(), compileDesign)) {
      ElaboratorContext elaboratorContext(&s, false, true);
      result = UHDM::clone_tree(param->Rhs(), &elaboratorContext);
      …
```

so the read carries the package constant's `VpiValue`, `VpiDecompile`,
`VpiConstType`, `VpiSize` **and its `ref_typespec`** — which
`CompileHelper.cpp:3744-3750` had already filled in on the package road with
the package parameter's own declared typespec:

```cpp
UHDM::constant* c = (UHDM::constant*)expr;
if (c->Typespec() == nullptr) { … tsRef->Actual_typespec(ts); c->Typespec(tsRef); }
int32_t size = c->VpiSize();
if (ts) { sizetmp = Bits(ts, …); if (!invalidValue) size = sizetmp; }
adjustSize(ts, component, compileDesign, instance, c);
```

Back in the module, `DesignElaboration.cpp:2561-2587`:

```cpp
if (ts) { if (ts->UhdmType() != uhdmunsupported_typespec) {
    m_helper.adjustSize(ts, …, c);                       // the READER's ts
    if (c->Typespec() == nullptr) { … Actual_typespec(ts); } } }
value = m_exprBuilder.fromVpiValue(c->VpiValue(), c->VpiSize());
const UHDM::typespec* cts = nullptr;
if (const UHDM::ref_typespec* rt = c->Typespec()) cts = rt->Actual_typespec();
value->setTypespec(cts ? cts : ts);
if (ts) m_helper.valueRange(value, ts, cts ? cts : ts, …);
```

and the `:2568` fill-in **cannot run** — the clone already has a typespec — so
`valueRange` (`CompileHelper.cpp:5548-5566`) reads its signedness off the
PACKAGE's typespec, and `adjustSize` (`CompileHelper.cpp:4086-4088`) leaves a
`vpiDecConst`'s width alone:

```cpp
int32_t size = orig_size;
if (c->VpiConstType() != vpiDecConst) { if (!invalidValue) size = sizetmp; }
```

TWO FIELDS, ONE ROAD.  `NetlistElaboration.cpp:513-578` then re-renders the
ELABORATED `param_assign` Rhs from that store (`c->VpiValue(value->uhdmValue())`
… `adjustSize`), which is why the corpus-visible `param_assign` cell of a
package-fed hop is *already* the reader's width while the STRUCT-PATTERN
operand — minted from the store by `CompileExpression.cpp:3028-3040` — is the
package's.  The pattern operand is what this pass writes.

### 1.2 LAW B — `UINT:` + a minus sign is zero

`src/ExprEmit.cpp`, `§ pkgParamFoldWidthAlways`, at the base:

```cpp
c->VpiValue((callSigned9 ? "INT:" : "UINT:") + digits);
c->VpiConstType(callSigned9 ? vpiIntConst : vpiUIntConst);
```

`digits` is `cv.integer().toString(LiteralBase::Decimal, false)`, so a
negative package parameter produces the string `UINT:-3`, and the UHDM
serializer's unsigned reader yields **0**.  Our own general constant encoder
(`src/ExprEmit.cpp`, the `§` block around the `isIntEncoded` arm) carries the
rule already: *"A NEGATIVE signed result always encodes as a signed INT
(Surelog): integer y = -1 -> INT:-1, never UINT:-1 (which serializes as 0)."*
This law is that sentence applied at the one site that had not heard it.

### 1.3 LAW C — the census key

`red86HopName86` resolves the IMMEDIATE hop, and the landed gate is
`if (sz86 > 64 && !red87HopHomeIsInstance87(*hw86)) continue;` — the home of
THAT symbol.  `census89.classify89` walks the chain and asks `not inpkg` at
the hop whose INITIALIZER is the literal.  On `x5_pkgchn89` the two readings
disagree on FIVE setters (measured, §4).

---

## 2. THE THREE LAWS

### § modPkgFedHopStore91 — `src/EmitHelpers.h` + two call sites in `src/ParamEmit.cpp`

```
red91PkgFedInner91(P):
    not overridden, home is an InstanceBody or a GenerateBlock, an EXPLICIT
    declared type, and the initializer is a BARE NAME whose symbol is a
    parameter homed in a Package or the CompilationUnit   ->  that parameter Q

red91PkgDeclKind91(Q):   1 a written data type | 0 a plain implicit
                        -1 an implicit declaration wearing a signing keyword
                           or a dimension  ->  REFUSED on both faces

the SIGN face (the loop that writes the bare signed `int_typespec`):
    Q answers, and only Q:   dk(Q)==1 -> Q's declared type is a SIGNED
    logic/bit/int; dk(Q)==0 -> recurse into Q's own bare-name initializer
    (depth <= 8).  The BINARY const type is declined whole.

the WIDTH face (the loop past the bail):
    Q's chain must end at a `'d` vector literal (depth <= 8); the answer is
    Bits(Q's declared type) where dk(Q)==1 and the inner answer where
    dk(Q)==0.  The BINARY const type is declined whole.

AND THE LANDED CHAIN RECURSION gains one arm: `red87StoreSigned87` asks the
package-fed question at every hop, so a chain THROUGH a package-fed hop is
signed too (`p1_pkgin91` `R10`).  An OR, not a replacement.
```

### § pkgParamNegFoldIsInt91 — `src/ExprEmit.cpp`, one predicate

```
-  c->VpiValue((callSigned9 ? "INT:" : "UINT:") + digits);
+  const bool neg91 = cv.integer().isSigned() && cv.integer().isNegative();
+  c->VpiValue(((callSigned9 || neg91) ? "INT:" : "UINT:") + digits);
```

(and the same predicate on `VpiConstType`).  Nothing else about the fold —
not its width, not its typespec, not its decompile — is touched.

### census91.py — `tools/probe/r11u91repro/census91.py`, NO production bytes

`WID91` is pass-88's wide class keyed on the IMMEDIATE hop's home; `WIDL89`
is the old literal-keyed reading, reported beside it so the hole is a number.
`PKI91` is LAW A's class and `NEG91` / `NEGW91` are LAW B's (the wide key is
the superset: a constant expression reaches a negative signed value through a
minus, a `~` or an explicit `signed`).  `--selftest` is the positive control
and carries a live NEGATIVE control.

---

## 3. THE GOLDEN GRID

Read with the committed `r11u87repro/ts87probe` and scored PER CELL with the
committed `r11u87repro/score87v.py` (r11v86's alignment-aware scorer); the
`cont_assign` arms are read with `r11u88repro/cacell88.py`, the per-cell
arbiter, and judged by the official `uhdm-cmp`.  **58 arms — the 54 landed
ones re-run unchanged beside four new `p*` arms — plus two `cont_assign`
arms.**

### 3.1 `p1_pkgin91` — THE READER'S DECLARATION HAS NO VOTE (LAW A)

Twelve readers over eight package shapes, two 24-bit patterns, operand 0 a
guaranteed bail:

| reader | package inner | golden | ours (pristine) | this law |
|---|---|---|---|---|
| `logic [7:0] R1` | `int PI = 16'd5` | `32 INT:5 /S` | `8 INT:5 ts=-` | **golden's** |
| `logic [7:0] R2` | `logic [15:0] PU = 16'd7` | `16 INT:7 ts=-` | `8 INT:7 ts=-` | **golden's** |
| `logic [7:0] R3` | `logic signed [15:0] PS` | `16 INT:9 /S` | `8 INT:9 ts=-` | **golden's** |
| `logic [7:0] R4` | `bit signed [7:0] PBS = 8'd3` | `8 INT:3 /S` | `8 INT:3 ts=-` | **golden's** |
| `logic [7:0] R5` | *(implicit)* `PIMP = 16'd11` | `16 INT:11 ts=-` | `8 INT:11 ts=-` | **golden's** |
| `logic [7:0] R6` | `int PH = 8'hA` | `8 HEX:A /S` | `8 HEX:A ts=-` | **golden's** |
| `logic [7:0] R7` | `shortint PSH = 16'd4` | `16 INT:4 ts=-` | `8 INT:4 ts=-` | **golden's** |
| `int R8` | `logic [15:0] PU = 16'd7` | `16 INT:7 ts=-` | **`32 INT:7 /S`** | **golden's** |
| `int R9` | `int PI` | `32 INT:5 /S` | the same — EQUAL | untouched |
| `logic [7:0] R10` | `= R1` (a chain THROUGH the package-fed hop) | `8 INT:5 /S` | `8 INT:5 ts=-` | **golden's** |
| `localparam R11` | `= p1p::PI`, NO declared type | `32 INT:5 ts=-` | the same — EQUAL | untouched — the `if (ts)` control |
| `logic [7:0] R12` | `int PNG = -3` | `8 INT:-3 /S` | `8 INT:-3 ts=-` | **golden's** |

**`R8` IS THE LAW.**  A SIGNED reader over an UNSIGNED package inner is golden
BARE and at the PACKAGE's width; the pristine binary writes the reader's own
`32 /S` on both fields.  The package answers, or nothing does — which is why
this REPLACES the landed declaration read instead of OR-ing with it.
**`R11` KEEPS THE `if (ts)` GATE HONEST**: with no declared type
`valueRange` is never called and `adjustSize` never runs, the store keeps the
clone verbatim, and both binaries already write it.
**TO=24, AWAY=0, WRONG2=0, MWRONG=0.**

### 3.2 `p3_pkgsize91` — WHICH WIDTH THE `vpiDecConst` CLONE CARRIES

Every reader is `logic [15:0]`, so the answer is the PACKAGE's or nothing:

```
   package hop                golden   what it is        ours    this law
   logic [7:0]  QD  = 16'd5     8      Bits, NOT 16      16      golden's
   int          QDL = 8'd5     32 /S   Bits, NOT 8       16      golden's
   (implicit)   QIM = 8'd5      8      the literal's     16      golden's
   logic [7:0]  QC8  = QI       8      Bits of the OUTER 16      golden's
   logic [63:0] QC64 = QI      64      Bits of the OUTER 16      golden's
   (implicit)   QCIM = QI      32 /S   the INNER's       16      golden's
   bit [11:0]   QB12 = 16'd5   12      Bits              16      golden's
```

The chain rows are what pin the recursion: `QC8` and `QC64` are the SAME inner
`int QI = 16'd5` and are golden 8 and 64, so the width belongs to the hop the
reader names and not to the literal; `QCIM` has no declaration of its own and
is golden the inner's 32.  **TO=14, AWAY=0.**

### 3.3 `p2_pkgedge91` — THE EDGES, AND THE THREE SHAPES DECLINED

```
   reader / package hop                    golden        ours     this law
   logic [7:0] S1 = p2p::QC (a pkg chain)  32 INT:5 /S   8 ts=-   golden's
   logic [7:0] S2 = p2p::QZ (plain `5`)    8 UINT:5 /S   8 ts=-   golden's (ts only)
   logic [7:0] S4 = p2p::QO (an `'o` leaf) 8 UINT:15 -   the same EQUAL
   logic [7:0] S5 = p2p::QE (`2 + 3`)      8 UINT:5 /S   8 ts=-   golden's (ts only)
   logic [63:0] S6 = p2p::QW (32'd21)      32 INT:21 -   64       golden's
   bit [3:0]   S7 = p2p::QI                32 INT:5 /S   4 ts=-   golden's
   int unsigned S8 = p2p::QUN              32 INT:6 -    the same EQUAL
   logic [7:0] S10 = p2p::QI + 0           8 INT:5 -     the same EQUAL — an operation
   logic [7:0] S11 = 16'd5                 16 INT:5 -    the same EQUAL — a literal
   a DIRECT `p2p::QI` operand              32 INT:5 -    the same EQUAL — y3_home87's control
   logic [7:0] S3 = p2p::QB (`8'b1010`)    8 BIN:1010 -  24 BIN:0000…1010  DECLINED
   logic [7:0] S9 = signed'(p2p::QI)       32 INT:5 /S   8 UINT:5 ts=-     DECLINED
```

**THE `'d`-ONLY WIDTH RULE IS MEASURED AND NOT ASSUMED**: `S2`, `S4` and `S5`
are `vpiUIntConst` cells whose width `adjustSize` re-sizes to the READER's,
and our emission already writes it — the law adds the typespec there and
nothing else.  **THE BINARY FACE IS DECLINED WHOLE** because our member stamp
zero-pads a `'b` hop's digit string to the member width: the cell cannot reach
golden on the typespec alone, and a half-golden cell is worse than none
(r11u89 LAW C's own rule).  **THE CAST FACE IS r11u81's** and untouched.
**TO=10, AWAY=0, STILL=6.**

### 3.4 `p4_pkghome91` — THE OTHER HOMES, THE OVERRIDE GATE, AND ONE REFUSAL

One package read from a MODULE body, an `if`-GENERATE block, an INTERFACE
body and a module instantiated with `#(.O(32'd9))`.  **The rule is the same in
all four homes** — `32 INT:5 int_typespec/S` for the `int` hop and
`8 HEX:1A int_typespec/S` for the signed `'h` hop, golden and ours alike after
this law — and the OVERRIDDEN parameter `O` is golden `32 INT:9 ts=-` on both
binaries before and after (the override gate's positive control, four cells
per section).  **TO=28, AWAY=0.**

**THE REFUSAL, `U3`**: `localparam signed QSI = 16'd5` — an IMPLICIT package
declaration wearing a signing keyword — is golden `32 INT:5 /S`, the pristine
binary writes `8`, and slang's `getBitWidth()` for it is **16**.  Writing 16
would be a MOVED-WRONG cell, so `red91PkgDeclKind91` returns `-1` and BOTH
faces refuse the shape.  Recorded as R1.

### 3.5 `q12_ndaparamenc` and `n1_pkgneg91` — LAW B, on the official judge

`q12_ndaparamenc` is r11u88's own committed arm and **CONVERTS**:
`cmp_rc 255 -> 0`, `heads 1 -> 0`, cells `MATCH 15 / DIFF 1` -> `MATCH 16 /
DIFF 0`.  Its only head was `wire signed [31:0] w_pneg = pk::P_NEG;` —
golden `INT:-3 vpiSize 32 vpiConstType 7`, ours `UINT:0 … 9`.

`n1_pkgneg91`, ten written forms x three reading homes, `MATCH 3 / DIFF 12`
-> `MATCH 10 / DIFF 4`, **no cell leaves MATCH**:

```
   package declaration          read as                golden      pristine  law
   int      PN    = -3          a net-decl-assign      INT:-3 @32  UINT:0    golden's
   int      PP    = 3           the POSITIVE control   UINT:3      the same  EQUAL
   logic signed [7:0] PN8 = -3                         INT:-3 @32  UINT:0    golden's
   byte     PNB   = -3                                 INT:-3 @32  UINT:0    golden's
   longint  PNL   = -3          a 64-bit net           INT:-3 @64  UINT:0    golden's
   (implicit) PNIM = -3                                INT:-3 @32  UINT:0    golden's
   int      PNE   = 0 - 3       an operation           INT:-3 @32  UINT:0    golden's
   int      PNMIN = -2147483647                        INT:-2…7    UINT:0    golden's
   int      PN    = -3          a MODULE net-decl      INT:-3 @32  UINT:0    golden's
   logic [7:0] PNU = -3         an UNSIGNED type       INT:-3 @32  UINT:253  DECLINED — R2
   int      PNZ   = -0          negative zero          INT:0 ct 7  UINT:0    DECLINED — R3
   byte     PNB   = -3          a WRITTEN `assign`     INT:-3 @32  UINT:0 @8 R4
```

The last row is the one named WRONG2 a priori: the written-assign's Rhs width
is `8` on both binaries where golden writes the NET's `32`, and our own DEF
view already read `INT:-3 @8` at the base — so the law moves the ELAB view
onto the DEF view's answer and the pre-existing width residue stands alone.
The whole-dump diff of the two `n1_pkgneg91` databases is **19 changed lines,
every one a `UINT:0` -> `INT:-<n>` or a `vpiConstType:9` -> `7`** — the law's
two fields and nothing else.

### 3.6 THE SCORE, per cell, on every field the lister prints

```
  p4_pkghome91 TO=28 AWAY=0 STILL=6 WRONG2=0 EQ=14
  p1_pkgin91   TO=24 AWAY=0 STILL=0 WRONG2=0 EQ=8
  p3_pkgsize91 TO=14 AWAY=0 STILL=0 WRONG2=0 EQ=2
  p2_pkgedge91 TO=10 AWAY=0 STILL=6 WRONG2=0 EQ=16
  w4_chnn89    TO=4  AWAY=0 STILL=8 WRONG2=0 EQ=36   (r11u89's R1, its own arm)
  … the other 53 arms TO=0 AWAY=0 WRONG2=0 …
  TOTAL  TO=80  AWAY=0  STILL=225  WRONG2=0  EQ=1157  SHAPE=9  MWRONG=0  UNPAIR=18
```

**EVERY MOVER ON A LANDED ARM IS NAMED AND THERE IS EXACTLY ONE**:
`w4_chnn89` `N1` (4 cells across two sections) is r11u89's R1 verbatim.  No
other landed arm moves a byte — `w3_chain87`, `w5_ovr87`, `w9_wide89`,
`w6_dfp89`, `x1`–`x7`, `y1`–`y8`, `z1`–`z8`, `a1`–`a4`, `b1`, `m5`, `v9` all
score `TO=0 AWAY=0 WRONG2=0`.

**THE SCORER'S OWN POSITIVE CONTROL, PER ARM.**  Scoring each moving arm with
the two tags SWAPPED turns **every one of the 80 TO cells into AWAY *and*
MOVED-WRONG**: `p1 24`, `p2 10`, `p3 14`, `p4 28`, `w4 4`, `TOTAL TO=0
AWAY=80 MWRONG=80`.  `AWAY=0` is a measurement on all five arms separately,
not a blind spot.

---

## 4. CENSUS, A PRIORI, RE-KEYED, WITH ITS POSITIVE CONTROL

`census91.py` — `census89.py` with `WID89` re-keyed on the GATE's own read and
two classes added.  Population taken through the committed `census68_base`:
EVERY element of EVERY `'{…}` span in a parameter context, over
`~/git-repos/uhdm2rtlil/tests`, `~/git-repos/Surelog/tests` and
`~/git-repos/Surelog/third_party/tests`, plus a FILE-keyed scan for LAW B
(whose population is not a `'{…}` span at all).

```
  AGREE91 15154   OVR89 17   SGN87 4   UNR87 270
  CHN89 0   WID91 0   WIDL89 0   PKI91 0   NEG91 4   NEGW91 74
```

**THE LANDED CLASSES ARE UNMOVED BY THE RE-KEY** — `AGREE 15154`, `OVR89 17`,
`SGN87 4`, `UNR87 270` are r11u89's committed numbers to the unit, so the
re-key changed the KEY and not the population.  **LAW A'S CLASS IS
CORPUS-INVISIBLE: `PKI91` 0 cells.**  `WID91` is zero too — the hole RV89-3
named was real and empty.

**THE POSITIVE CONTROL FOR THE ZEROS** (`--selftest`, a census zero needs
one).  Over this pass's own grid the classifier sights `p1`/`p2`/`p3`/`p4` as
`PKI91`, `x5_pkgchn89` as `PKI91`+`WID91`, `w9_wide89` as `WID91`,
`w3_chain87` as `CHN89`, `w5_ovr87` as `OVR89`, `y1_sgnd87` as `SGN87` and
`n1_pkgneg91` as `NEG91`+`NEGW91`, while the NEGATIVE control leaves
`b1_pin86` **unsighted**.  `SELFTEST PASS`.

**AND THE RE-KEY IS ITSELF MEASURED, PER SETTER.**  `x5_pkgchn89` holds BOTH
a package-fed wide hop and a direct module-homed one, so an arm-level tag set
proves nothing; the selftest counts setters: **5 carry `WID91` and NOT
`WIDL89`** (RV89-3's hole, now sighted) **and 2 carry both** (the direct hop,
which the old key already saw).  The old key is not merely a subset by
assertion.

**A PRIORI MOVER SET — THE NAMES, AND WHY THE SET IS EMPTY.**  `PKI91` and
`WID91` sight nothing at all.  `NEGW91`, the WIDE superset of LAW B, sights
74 package parameters in 17 tests; fifteen of them produce NO database
(`ariane` is not a row; `Ariane2024` `SLANG_REJECT`/`NO_DATABASE`;
`ArianeElab`, `ArianeElab2`, `BlackParrotMuteErrors`, `ClassScope`,
`Earlgrey_Verilator_0_1`, `IncompTitan`, `NyuziProcessor`, `Opentitan`,
`PackageParam`, `Zachjs` `SLANG_REJECT` both modes; `Earlgrey_nexysvideo`,
`Earlgrey_Verilator_01_05_21`, `Rsd` `DEFERRED` both modes).  **TWO DO**, and
both are named here:

```
  Earlgrey_0_1             NEGW91: PrimFlashAddrW   CMP_EQUAL both modes (a HARD PIN)
  HierPathStructTypespec   NEGW91: BufferCycles     CMP_EQUAL both modes
                           NEGW91: MsgFifoDepth
```

All three are POSITIVE-valued: `parameter int PrimFlashAddrW = BankAddrW -
LsbAddrBit;`, `parameter int BufferCycles = (Sha3Latency + RegLatency -
1)/RegLatency;`, `parameter int MsgFifoDepth = 2 + ((BufferSizeBits +
MsgWidth - 1)/MsgWidth);` — they are in the class because the SUPERSET keys on
a `-` anywhere in the initializer, and the law's own gate is
`isSigned() && isNegative()`.  **The prediction is therefore the EMPTY mover
set, with those two tests named as the only places it could have been wrong**,
and byteverify is what checks it.  No canary is in the `PKI91`/`WID91`
classes at all; `Earlgrey_0_1` is in `NEGW91` and its two database md5s are
gated below.

---

## 5. GATES — ALL MANDATORY

**1. BUILD.**  `-j 2` in this pass's own worktree, md5 taken separately, every
binary frozen `chmod 555` before any sweep.  Pristine
`bf80949e9090df504e2cfbcf8520e1b3` — **byte-identical to the main tree's
`build/slang-uhdm` at `0522e347`**, the value the brief pins.  Law
`b082887a90d6b36b04792aaa2c78a2bd`.  `ParamEmit.cpp` is `__LINE__`-sensitive,
so the shipped source's identity with the measured one is a CHECK and not an
assumption (§5.9).

**2. GOLDENS.**  `23 PASS / 0 FAIL` on the law binary; `SLANG_UHDM=/bin/false`
gives `0 PASS / 23 FAIL` — the negative control.

**3. uhdm2rtlil, BOTH MODES, BOTH BINARIES.**  `788 / 16 / 67` in each of the
four sweeps.  The 1742-row BOTH-MODE join against the committed
`results/golden_uhdm2rtlil.csv` is **DIFF=0** on the law binary and DIFF=0 on
the pristine one; the 871 testflags rows against `results/gate_uhdm2rtlil.csv`
read `PASS: every row byte-identical to the committed baseline` on both.

**4. Surelog, `--mode both`, BOTH BINARIES.**  `474 / 9` default + `469 / 8`
testflags on each binary.  The PRISTINE sweep's bucket histogram is the
committed one to the unit (`SLANG_REJECT` 285+286, `SURELOG_FAIL` 25+23,
`DEFERRED` 5+5, `NO_DATABASE` 3, `UNTRANSLATABLE` 2, `TIMEOUT` 1, `NO_UHDM`
1), and against `results/golden_surelog.csv` it draws **exactly the four
documented environment rows**: `Earlgrey_0_1` default and testflags (the DUMP
COLUMN blank where the baseline reads `differ`; the status is `CMP_EQUAL` in
both modes and the database byte-compare — the actual pin — never moved), and
`LowMemLib` / `LowMemPkg` testflags (`SURELOG_FAIL` on both sides, the DETAIL
string embedding the sweep's own workdir path).

The LAW sweep draws those same four **plus one, and it is golden-side**:
`YosysOpenSparc,default` reads `TIMEOUT / surelog timeout` where the baseline
reads `SLANG_REJECT`.  **PROVEN ENVIRONMENT**: four concurrent `--jobs 3`
surelog sweeps were running on this machine (this pass's two and a sister
pass's two), and re-running that single row alone on the LAW binary
(`--filter YosysOpenSparc --jobs 1`) returns
`YosysOpenSparc,default,SLANG_REJECT,…t2.v:269093:6: error: expected a
declaration name` — the baseline row, byte for byte.  `surelog timeout` is the
PRODUCER timing out; our binary is never reached on such a row.

`results/*.csv` untouched (`git status --porcelain results/` empty).

**5. byteverify, BOTH CORPORA IN ONE WORKDIR PAIR** (`pris` / `lawx`, the same
length — r11u81's RV-7).  **MOVERS 5 / 2568**, `SELFCHECK` 2567/2568,
`PATH_SETS_IDENTICAL`.  The a-priori prediction was the EMPTY set (§4) and all
five are the documented UVM coin, attributed ORDER-BLIND on path-normalised
sorted dumps — each moves **exactly four real sorted lines, one
`UINT`/`vpiDecompile` PAIR holding a LINE NUMBER**:

```
  default/MiniAmiq     UINT:0    <-> UINT:1321     vpiDecompile 0 <-> 1321
  default/SeqDriver    UINT:1096 <-> UINT:605      vpiDecompile 1096 <-> 605
  default/SimpleUVM    UINT:1318 <-> UINT:0        vpiDecompile 1318 <-> 0
  testflags/MiniAmiq   UINT:1071 <-> UINT:922      vpiDecompile 1071 <-> 922
  testflags/SeqDriver  UINT:742  <-> UINT:0        vpiDecompile 742 <-> 0
```

**Zero `vpiSize`, zero `Typespec`, zero `vpiConstType` lines in any of them**,
and those are exactly the three fields this pass writes.  No `Earlgrey_0_1`,
no `HierPathStructTypespec` — the two names §4 put at risk — and no canary.

**COIN POSITIVE CONTROL**: the PRISTINE binary ALONE, five runs of MiniAmiq's
own invocation in ONE directory writing ONE name, gives **five distinct
databases** (`2d12f2f0a8e6`, `2c6b4fe9268e`, `d748e531aecb`, `5272fa4c2678`,
`417ef11b1f65`).  A mover COUNT is a draw; the CLASS is the measurement.
**A DISCLOSURE**: the first attempt at that control re-ran MiniAmiq's command
verbatim, whose `-o` names the sweep workdir, so it overwrote the PRISTINE
`default/MiniAmiq` database once.  byteverify was re-run afterwards: the mover
SET is the same five names, and only that file's pristine hash moved
(`27419f6011b4` -> `6845b7d664c1`) — which is the coin, demonstrated by
accident.  Both readings are `MOVERS 5 / 2568`.

**6. Canaries and pins.**  `canaries.sh` surelog `ok=50 changed=2` — the two
changed are the `Earlgrey_0_1` dump-column cells of gate 4, and the PRISTINE
sweep reports the same two; u2r `ok=8 changed=0`.  `ctcan2.sh` **PASS** on
both corpora (`ok=58` / `ok=1`, `changed=0`, with the documented
`EXPECT_UNKNOWN=1` / `6`).  `canaudit.sh` **PASS**, `audited=29 UNCOVERED=0
FENCE-BREACH=0`.  Every protected database **at exactly the pinned md5 on the
law binary, and identical to the pristine sweep's**: SVSwitch `4842211c4030`,
YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1
`8bdf25272e08` (default) / `59d0ee6d10c3` (testflags), BlackParrotComplex
`e3e354129d5a` / `73a10e8217e5`, YosysOldOr `d68e0796d62c` both modes.

**7. The conversion rows, on the official `uhdm-cmp` with golden as LHS.**
BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM (both modes), Scoreboard (default;
testflags is the documented SKIP-NOFILE), `ParamOverloading` (both modes) and
`Earlgrey_0_1` (both modes) all read **0 cmp lines / 0 heads**:
`measured=13 SKIP-NOFILE=1 UNKNOWN-NAME=0`.

**8. THE TWO LAWS ARE DROPPABLE ALONE.**  Two further binaries were built in
their own fresh `0522e347` worktrees, each carrying exactly one law:

| binary | md5 | `p1`/`p2`/`p3`/`p4`/`w4` (LAW A) | `q12_ndaparamenc` (LAW B) |
|---|---|---|---|
| full patch | `b082887a90d6…` | TO=24/10/14/28/4 | `cmp_rc 0`, heads 0 |
| LAW A reverted (ExprEmit only) | `689381e90a61f472603164e8668c41c8` | **TO=0** on all five, `AWAY=0` | `cmp_rc 0`, heads 0 |
| LAW B reverted (EmitHelpers+ParamEmit only) | `c43d9ba9f039ab137a77680c1f871cd9` | TO=24/10/14/28/4 | **`cmp_rc 255`, heads 1, 16 cmp lines** |

`AWAY=0` and `MWRONG=0` in every cell of every row.  The two laws are disjoint
by construction as well as by measurement: LAW A writes only a struct-pattern
operand's `Typespec` and `VpiSize` from `ParamEmit.cpp`, LAW B only a
`cont_assign`-road constant's `VpiValue` and `VpiConstType` from
`ExprEmit.cpp`, and neither reader can reach the other's site.  LAW C is an
instrument and ships no production bytes at all, so dropping it is deleting a
file.

---

## 6. RESIDUES

* **R1 — THE IMPLICIT PACKAGE DECLARATION WEARING A SIGNING KEYWORD.**
  `localparam signed QSI = 16'd5` in a package, read by a `logic [7:0]` hop,
  is golden `32 INT:5 int_typespec/S` (`p4_pkghome91` `U3`): the producer
  SYNTHESIZES an `int_typespec` for it, so `Bits(ts)` is 32.  slang's
  `getBitWidth()` for the same symbol is **16** and the pristine binary
  writes the reader's **8**, so neither the declared width nor the literal's
  is golden's answer and writing either would be a MOVED-WRONG cell.
  `red91PkgDeclKind91` returns `-1` and BOTH faces refuse the shape; the
  typespec half is refused with it rather than left half-golden.  The decode
  (which of Surelog's implicit-typespec synthesisers runs, and at what width)
  is not taken here.  One cell, corpus-invisible.
* **R2 — THE UNSIGNED PACKAGE DECLARATION OVER A NEGATIVE INITIALIZER.**
  `localparam logic [7:0] PNU = -3` is golden `INT:-3` — Surelog's reduce does
  NOT apply the declared type's unsignedness — where our own package
  `param_assign` writes `UINT:253` and the read folds the same 253
  (`n1_pkgneg91` `w_pnu`).  The VALUE differs, not just the encoding, so LAW
  B's `isSigned() && isNegative()` gate declines it: the cell is wrong on both
  binaries and a const-type write alone would not reach golden.  It is the
  PACKAGE PARAMETER EMITTER's ground, not this fold's.
* **R3 — NEGATIVE ZERO.**  `localparam int PNZ = -0` is golden `INT:0
  vpiConstType 7` and ours is `UINT:0 … 9` (`n1_pkgneg91` `w_pnz`): the
  producer's INT comes from the NEGATION's own reduce and not from the sign of
  the result, so a value-based gate cannot see it.  One field, one cell,
  unchanged on both binaries.  Closing it wants the initializer's SHAPE
  (`isIntEncoded`'s road), which is r11u83's ground.
* **R4 — THE WRITTEN ASSIGN'S PACKAGE-PARAM WIDTH.**  `assign m_pnb =
  np::PNB;` over a `byte` package parameter is golden `INT:-3 vpiSize 32` —
  the NET's width — and ours is `vpiSize 8`, the parameter's own, on BOTH
  binaries and in BOTH views.  `§ pkgParamFoldWidthAlways` sizes by
  `psym.getType().getBitWidth()` unconditionally, and the landed comment there
  records that the unconditional form was measured byte-identical over both
  corpora.  This law moves the ELAB view's value and const type onto the DEF
  view's, leaving that one width residue standing alone — named a priori as
  the pass's only WRONG2 cell, and it is r11u88's LAW C ground (the net's
  width belongs to the SUBSTITUTED copy).
* **R5 — THE BINARY PACKAGE HOP.**  `logic [7:0] N = pkg::QBS` over
  `logic signed [7:0] QBS = 8'b1010` is golden `8 BIN:1010 int_typespec/S` and
  ours is `24 BIN:000000000000000000001010 ts=-` on both binaries: our member
  stamp zero-pads the digit string to the member width, and that is a VALUE
  field.  Both faces of LAW A decline `vpiBinaryConst` whole for that reason
  (`p2_pkgedge91` `S3`, `p4_pkghome91` `U1`).  It is the same class r11u89's
  R3 recorded for the binary OVERRIDE.
* **R6 — THE CAST OVER A PACKAGE HOP.**  `logic [7:0] S9 = signed'(p2p::QI)`
  is golden `32 INT:5 int_typespec/S` where both binaries read `8 UINT:5 ts=-`
  — three fields.  `red87BareHop87` declines the cast face whole (r11u87's R4,
  r11u89's R4) and this pass does not widen it; the `UINT:`-vs-`INT:` half is
  the encoding law's ground and the three must move together.
* **R7 — THE PACKAGE-FED CHAIN'S WIDTH FACE, one hop deeper.**  LAW A's SIGN
  face reaches a chain THROUGH a package-fed hop (`p1_pkgin91` `R10`, golden
  and ours `8 INT:5 /S`); its WIDTH face does not need to, because the inner
  hop's store re-mints as `INT:`/`UINT:` and `adjustSize` re-sizes it — every
  measured chain cell is golden on the width already.  If a shape is ever
  found where the `vpiDecConst` survives two hops, the width recursion is the
  same one `red91PkgStoreSize91` already carries and would only need the outer
  call site.  No cell measured here wants it.

**9. THE SHIPPED SOURCE IS THE MEASURED SOURCE.**  `ParamEmit.cpp` is
`__LINE__`-sensitive, so this was CHECKED and not assumed: the deliverable
patch applied to a FRESH `0522e347` worktree and built there independently
links to **`b082887a90d6b36b04792aaa2c78a2bd`, byte for byte** — the law
binary every measurement above was taken on.  `git apply -3` on that fresh
worktree reports `Applied patch to 'src/EmitHelpers.h' / 'src/ExprEmit.cpp' /
'src/ParamEmit.cpp' cleanly` and leaves no conflict marker.

**10. THE WIDE BOUNDARY — EVERY `*.sv` UNDER `tools/probe`, NOT THE GRID
GLOB.**  **8185 arms: 7919 SAME, 44 DIFFERS, 222 NODB**, and every NODB arm
has `prc == lrc` (212 x `rc=3`, 6 x `rc=2`, 4 x `rc=139`, identical on both
binaries).  The 44 split into three classes and NOTHING ELSE:

* **34 arms with real dump lines.**  Across all of them the differing lines
  are `162 vpiConstType`, `116 vpiSize`, `97 UINT`, `85 INT`,
  `44 vpiDecompile` and `120 int_typespec` + their `ref_typespec` /
  `vpiTypespec` / `vpiParent` / `vpiFullName` / `vpiActual` / `constant` /
  `58 vpiSigned` scaffolding — **the law's three classes and no fourth line
  of any other kind**.  The typespec class is ADD-only (`118` added
  `int_typespec` lines against `2` removed) and
  **UNEXPLAINED-REMOVALS = 0**: the ONLY typespec removal in the whole
  boundary is four lines in `p1_pkgin91` at `41:43`, the `R8` cell where a
  SIGNED reader sits over an UNSIGNED package inner and **golden writes no
  typespec at all** — the deliberate suppression of §3.1, in the module's own
  pattern and in the sink instance's copy.
* **10 arms whose DUMPS ARE IDENTICAL and whose BYTES differ.**  The whole
  difference is the serializer's STRING TABLE: the pristine database carries
  `UINT:-3` / `UINT:-4` / `UINT:-5` / `UINT:-1` / `UINT:-56` entries that NO
  dumped object references, because `UINT:-<n>` deserializes to `UINT:0`.
  The law binary stops minting those dead strings (and in two arms interns an
  equally unreferenced `INT:-<n>` instead), so the file shrinks by a few
  bytes and every object in it is unchanged.  This is the ops brief's own
  "writing the same fields twice leaves discarded strings in the serializer's
  table" class, read from the other side: LAW B REMOVES two dead strings per
  arm.  `uhdm-cmp` reads objects, not the string table, so the class is
  judge-invisible — and it is measured, not asserted: `strings | sort | diff`
  on each of the ten names the exact entries above.
* **3 arms carry the documented PAGE-BOUNDARY `UINT`** —
  `r10buvm22repro/g22.sv` (a both-binaries-`rc=4` arm), `r10uvm154repro/
  l154_noenum.sv` and `r10uvm185repro/grid185/g185_e_kinds.sv` — an
  unsupported-typedef `range` bound emitted as an ADDRESS-DERIVED `UINT:`,
  moving `23249433 -> 23253529`, **exactly 4096, one page**.  THE 16 KB-PAD
  POSITIVE CONTROL, required by the ops rules for a 4096-delta-only `UINT`
  mover: a PRISTINE build carrying nothing but `volatile char v91pad[16384]`
  appended to `uhdm_main.cpp` and NO law code (`18582daec834…`) moves the SAME
  three arms `23249433 -> 23265849`, **+16416 — the pad's 16384 bytes plus its
  32-byte alignment**, four times the law binary's page.  The value tracks the
  LOADED IMAGE, not the emitter's semantics.  It is
  r11v11u8's documented residue and no corpus row touches any of the three.

(The boundary ran before two duplicate copies of `a1_hopts81.sv` /
`a3_hopbnd81.sv` were dropped from this pass's own `grid/`, so its arm count
is two higher than the shipped tree's; both names appear in the list twice,
once from `r11u81repro/grid/` — the committed original, which is what the
shipped census selftest now reads — and once from the copy.  Their diffs are
identical.)

**11. `results/*.csv` UNTOUCHED**; none of the four slang-fenced names appears
in any file of this patch (`canaudit.sh FENCE-BREACH=0`, and a per-name `awk`
over the patch reads 0 for each) and no test of theirs was ever dispatched.
`ModuleEmit.cpp` — the sister pass's ground — **is not in the patch**; the
production surface is `src/EmitHelpers.h`, `src/ParamEmit.cpp` and
`src/ExprEmit.cpp`, three files.  ONE CORPUS ROW WOULD CONVERT IF IT EXISTED
— none does — so no metric in `RESUME.md` §3b or `GOLDEN_EQUIVALENCE.md` §3.3
changes and no doc edit rides with this landing.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp 0522e347 && git worktree add /tmp/wtl 0522e347
(cd /tmp/wtl && git apply -3 /tmp/r11u91.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done            # bf80949e9090…  and  b082887a90d6…
# ---- the parameter grid (LAW A) --------------------------------------------
G=/tmp/g91 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u86repro/run66.sh $R/r11u87repro/{ts87probe.cpp,score87v.py,join87.py} $G/
cp $R/r11u91repro/grid/*.sv $R/r11v89repro/grid/*.sv $R/r11u89repro/grid/*.sv \
   $R/r11u87repro/grid/*.sv $R/r11u86repro/grid/*.sv $R/r11v86repro/grid/*.sv \
   $R/r11u81repro/grid/*.sv $R/r11v81repro/grid/*.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts87probe.cpp -o ts87probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/\.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm   # SAME-LENGTH
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wtl/build/slang-uhdm   # TAGS (RV-7)
done                                   # every arm must read slrc=0 ourrc=0 slerr=0
TS87PROBE=$G/ts87probe python3 $G/score87v.py $G/grid pris lawx
#   TO=80 AWAY=0 WRONG2=0 MWRONG=0  (p1 24, p2 10, p3 14, p4 28, w4_chnn89 4)
# the scorer's positive control, PER ARM — every TO must become AWAY+MWRONG:
for a in p1_pkgin91 p2_pkgedge91 p3_pkgsize91 p4_pkghome91 w4_chnn89; do
  cp -r $G/grid/o_${a}_lawx $G/grid/o_${a}_swpA; cp $G/grid/$a.lawx.dump $G/grid/$a.swpA.dump
  cp -r $G/grid/o_${a}_pris $G/grid/o_${a}_swpB; cp $G/grid/$a.pris.dump $G/grid/$a.swpB.dump
done; TS87PROBE=$G/ts87probe python3 $G/score87v.py $G/grid swpA swpB \
        p1_pkgin91 p2_pkgedge91 p3_pkgsize91 p4_pkghome91 w4_chnn89   # AWAY=80 MWRONG=80
# ---- the cont_assign arms (LAW B), judged by uhdm-cmp ----------------------
H=/tmp/g91n && mkdir -p $H/grid && cp -r $R/r11u91repro/grid88/n1_pkgneg91 \
   $R/r11u88repro/grid/q12_ndaparamenc $H/grid/
cp $R/r11u88repro/{rr88.sh,cacell88.py,away88.py} $H/
(cd $H && GRID=$H/grid bash rr88.sh /tmp/wtp/build/slang-uhdm pris)
(cd $H && GRID=$H/grid bash rr88.sh /tmp/wtl/build/slang-uhdm lawx)
#   q12_ndaparamenc  cmp_rc 255 -> 0, heads 1 -> 0          (a CONVERSION)
#   n1_pkgneg91      cells MATCH 3/DIFF 12 -> MATCH 10/DIFF 4, no cell leaves MATCH
python3 $H/cacell88.py $H/grid/<arm>/gold.<tag>.dump $H/grid/<arm>/ours.<tag>.dump
#   (away88.py is a LINE-multiset reader and reports the ubiquitous `|UINT:0`
#    line as both CONVERTED and AWAY — the multiset trap; cacell88.py is the
#    per-cell arbiter and the one that decides.)
# ---- the census (LAW C), and its positive control --------------------------
python3 $R/r11u91repro/census91.py --selftest          # SELFTEST PASS, hole 5 / kept 2
python3 $R/r11u91repro/census91.py ~/git-repos/uhdm2rtlil/tests \
   ~/git-repos/Surelog/tests ~/git-repos/Surelog/third_party/tests
#   PKI91 0   WID91 0   WIDL89 0   CHN89 0   NEG91 4   NEGW91 74
#   AGREE91 15154  OVR89 17  SGN87 4  UNR87 270   (r11u89's numbers, unmoved)
# ---- the corpora, per binary, workdir names the SAME LENGTH (pris / lawx) --
#   verify_golden.py --corpus uhdm2rtlil --mode {testflags,default} --jobs 3
#   verify_golden.py --corpus surelog    --mode both               --jobs 3
#   join87.py results/golden_uhdm2rtlil.csv <tf.csv> <def.csv>      # DIFF=0
#   ct8rows.sh results/golden_surelog.csv <sl.csv>                  # the four env rows
#   SELFCHECK=1 r11u91repro/byteverify.sh <lawx wd> <pris wd>       # MOVERS 5, the coin
#   RUN THE SWEEPS ONE PAIR AT A TIME: four concurrent `--jobs 3` surelog
#   sweeps made the GOLDEN side time out on YosysOpenSparc (§5.4).
# ---- the wide boundary, every *.sv under tools/probe -----------------------
#   (cd /tmp/wtl/tools/probe && find . -name '*.sv' | sed 's|^\./||' | sort > armlist)
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wtl/tools/probe BND_OUT=/tmp/bnd91 \
#     xargs -P 2 -n 1 bash r11u91repro/bnd72.sh < armlist
#   then, per DIFFERS arm: uhdm-dump both, `sed 's/, id:[0-9]*//'`, diff — and
#   where the DUMPS are identical, `strings | sort | diff` (the dead-string
#   class of §5.10).
# ---- the page-boundary control ---------------------------------------------
#   a FOURTH build, PRISTINE + `volatile char v91pad[16384]` appended to
#   uhdm_main.cpp and NO law code, must move the same three arms by 16384+32
#   where the law binary moves them by exactly 4096.
```

Evidence: `evidence/{GRID91.score,SWAPCTL91.score,CELLS91.txt,CELLS91.nda.txt,PAD91.txt,
CENSUS91.txt,ARMS91.txt,GOLDENS91.txt,BOUNDARY91.summary,MOVERS91.txt}`.
