# r11u73 — § patPowCastArtefact73, § redDecLeafRangeStrict73 and § redUntypedIntNameChain73

**THE VALUE TABLE'S LAST THREE FACES: THE `**` ARM'S OUT-OF-RANGE CAST IS A
VALUE, THE DECIMAL LEAF REFUSES ON ITS MAGNITUDE, AND THE UNTYPED SIZE IS
"THE PRODUCER MINTED THIS" FOLLOWED ALONG A NAME CHAIN.**

Base `71490354`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil v0.68). Every golden in this directory is a real Surelog v1.87 run
through the committed `run66.sh`, and every arm records `slrc` / `ourrc` /
`slerr`; **all of them read `0 0 0`**.

| binary | md5 | what |
|---|---|---|
| pristine | `598195b29a98fb7ee3263d01d53861e6` | built in this pass's own worktree at `71490354` — byte-identical to the main tree's `build/slang-uhdm` |
| law | `f7e288e08efb587e4a2b8c9dcfd11752` | this patch |

Both frozen `chmod 555` before any sweep; every `cmds.txt` audited by absolute
binary path.

---

## 1. THE HEAD, RE-MEASURED AT THE BASE (question 1)

The four named witnesses, re-run unmodified at `71490354`. Cells are
`const/<VpiSize>@<VpiConstType>=<VpiValue>` off the flat `op75` operand list of
`uhdmtopModules work@…`, read by the committed `shape.py`.

**`t3_beyond72`** (r11u72's R0) — the `**` arm past int64:

```
  member            golden                              pristine
  d: 2 ** 64        const/64@7 INT:-9223372036854775808 const/64@7 INT:0          <- R0
  e: 2 ** 70        const/64@7 INT:-9223372036854775808 const/64@7 INT:0          <- R0
  f: 3 ** 39        const/64@7 INT:4052555153018976256  EQUAL  (size 64 EQUAL)    <- R2 already closed
  g: W96H - 1       op11 (unfolded)                     const/64@7 INT:0          (R3/R4)
```

**`t7_fence72`** (r11u72's R1, the fence witness) — `A` (`2 ** 31`) is golden
`INT:2147483648` and **pristine now writes the same**: the cell r11u72 kept the
corroboration fence for is already healed at this base. `B` / `C` / `D` are the
live R0 cells, and their `K+1`/`K+2` probes read golden's refusal directly
(8 = the walk stamped the member width, 64 = it bailed at operand 0):

```
  operand 0    golden                              golden probes  pristine        probes
  2 ** 31      const/32@7 INT:2147483648           8  COMPLETES   EQUAL           8
  3 ** 40      const/32@7 INT:-9223372036854775808 64 REFUSES     INT:689956897   8
  2 ** 63      const/32@7 INT:-9223372036854775808 64 REFUSES     INT:0           8
  7 ** 23      const/32@7 INT:-9223372036854775808 64 REFUSES     INT:821077879   8
  2 ** 40      const/32@7 INT:1099511627776        8  COMPLETES   EQUAL           8
  K * 2        const/32@7 INT:12                   8  COMPLETES   EQUAL           8
```

**`v7_decwide72`** (r11v72's RV-2) — `A` (`DU - 1`) is golden an unfolded
`op11` and `E` (`DU % 3`) an unfolded `op13`, where pristine folds to
`INT:-3` / `INT:-2`. Their probes already read 64 on both sides, so the
refusal costs no size **here** — `w3_dec73` below finds the cells where it does.

**`v4_hop72`** (r11v72's RV-3) — `c` (`HOP2 = HOP1 = MD`, `MD = -16'd5`) is
golden `const/32@7 INT:-5` and pristine `const/16@7 INT:-5`: the value is right
and the SIZE is not.

---

## 2. THE PRODUCER, LINE BY LINE (question 2)

### The `**` arm and its cast (`~/git-repos/UHDM/templates/ExprEval.cpp:3782`)

```cpp
val = static_cast<int64_t>(std::pow<int64_t>(val0, val1));
constant *c = s.MakeConstant();
c->VpiValue("INT:" + std::to_string(val));
c->VpiDecompile(std::to_string(val));
c->VpiSize(64);
c->VpiConstType(vpiIntConst);
```

`std::pow<int64_t>` is the two-argument template whose return type is
`__gnu_cxx::__promote_2<int64_t,int64_t>::__type` — **`double`**. So the arm
is DOUBLE arithmetic with exactly one narrowing at the end, and the two faces
of that narrowing are both values:

* **within range** the cast keeps the double-ROUNDED result. `3 ** 39` is
  golden `INT:4052555153018976256` where the exact integer is
  `4052555153018976267`, and `5 ** 27` is golden `INT:7450580596923828224`.
  (r11u72 already modelled this half.)
* **past range** `static_cast<int64_t>` of an out-of-range `double` compiles to
  x86-64 `cvttsd2si`, which writes the integer-indefinite pattern
  `0x8000000000000000`. Measured golden for **every** past-range cell:
  `2 ** 63`, `2 ** 64`, `2 ** 70`, `3 ** 40`, `7 ** 23`, `10 ** 19` and
  `(-3) ** 41` are all `INT:-9223372036854775808`.

`(-2) ** 63` is the one cell where the artefact and the true value coincide
(`-2^63` is representable), and it is golden the same string either way — so it
is a control, not a distinguisher.

The artefact's SIGN is the second half of the law: it is negative, so
`get_uvalue` refuses it (`NumUtils::parseUint64` is `std::from_chars` into an
UNSIGNED and a leading minus fails), `expandPatternAssignment` stops stamping
at that operand, and every operand after it prints `reduceExpr`'s own size.
That is why the past-range cells move THREE cells each and not one.

### The decimal leaf in `get_value` (`ExprEval.cpp:1947-2056`)

```
  :1969 vpiBinaryConst   if (expr->VpiSize() > 64) invalidValue = true; else parseBinary
  :1978 vpiDecConst      sv.remove_prefix("DEC:"); parseInt64            <- NO size guard
  :1984 vpiHexConst      if (expr->VpiSize() > 64) invalidValue = true; else parseHex
  :1998 vpiOctConst      if (expr->VpiSize() > 64) invalidValue = true; else parseOctal
  :2008 vpiIntConst      sv.remove_prefix("INT:"); parseInt64
  :2015 vpiUIntConst     sv.remove_prefix("UINT:"); parseIntLenient      <- signed then unsigned
```

`NumUtils::parseInt64` is `std::from_chars` into an `int64_t` and is therefore
RANGE-STRICT, while `parseIntLenient` retries as `uint64_t`. So a DECIMAL leaf
refuses on its **magnitude** and not on its width — `96'd5` completes and
`64'd18446744073709551614` does not — while the HEX leaf beside it holding the
SAME BITS (`64'hFFFFFFFFFFFFFFFE`) parses happily into `-2`. And the refusal
only exists where a reduce ARM calls `get_value`: a bare decimal leaf standing
AT operand 0 is never read that way, and only the >64-BIT-VALUE rule of
r11u68's `b2_faces68` applies there. Both halves are measured in §3.

### The untyped parameter's stored size

There is no single line for this one; it is read off golden. An implicitly
typed parameter with no dimensions stores its initializer's REDUCED constant,
and that constant is either a BASED LITERAL carried verbatim with its own
width or one a reduce arm MINTED (`"INT:" + std::to_string(val)`, `VpiSize`
64 or `max(l,r)`). A minted one comes back at the untyped default **32**
whatever the arm's own `VpiSize` was — `AP = 2 ** 64` is golden 32 although
the `**` arm writes `VpiSize(64)`, and `A64 = 64'd5 + 64'd1` and
`AW = 96'd5 + 96'd1` are golden 32 as well. A verbatim one keeps its width.
The chain follows: what a NAME hop carries is not the target's WIDTH but
whether what it holds is verbatim.

---

## 3. THE GOLDEN GRID (question 3)

Seven new arms and five committed ones, every member read EXACTLY ONCE, scored
by the committed `ord66v.py` on the JUDGE's own fields (`vpiConstType` +
`vpiValue` for ENC, plus `vpiSize` for FULL) through the value-aware shape
lister ([evidence/GRID.12arms.txt](evidence/GRID.12arms.txt)).

| arm | what it grids | FULL / ENC |
|---|---|---|
| `w1_pow73` | the pow boundary × signedness × width: in-range exact, in-range ROUNDED, exactly 2^63, past, far past, negative base, and the 32-bit `2 ** 31` | TO 6 / 6, AWAY 0 |
| `w2_powbail73` | whether each pow cell BAILS (probes on 8-bit members) and what the post-bail `**` size is | TO 5 / 1, AWAY 0 |
| `w3_dec73` | the decimal leaf: name vs literal, inside an arm vs at operand 0, > int64 vs > uint64 vs inside, the same bits in HEX, a 96-bit SMALL decimal | TO 6 / 0, AWAY 0, WRONG2 3 |
| `w4_hop73` | the untyped chain: hop depth 1/2/3, chains onto hex / decimal / TYPED-byte / TYPED-16-minus origins, a minus over a name | TO 10 / 0, AWAY 0 |
| `w5_fence73` | the corroboration fence at a **32-bit** member on `<<`, `<<<`, `\|`, `&`, `?:` | TO 0, AWAY 0 |
| `w6_fence64` | the same five at a **64-bit** member, plus the honest minus | TO 0, AWAY 0 |
| `w7_untw73` | the WIDTH boundary of the untyped face, and the refusal gate | TO 6 / 1, AWAY 0, WRONG2 1 |
| `t3_beyond72` | committed (r11u72), R0's two cells | TO 2 / 2, AWAY 0 |
| `t7_fence72` | committed (r11u72), the fence witness | TO 9 / 3, AWAY 0 |
| `v1_uadd72` | committed (r11v72), the `+` arm's unsigned half — RV-5 | TO 0, AWAY 0, WRONG2 3 |
| `v4_hop72` | committed (r11v72), RV-3's one cell | TO 1 / 0, AWAY 0 |
| `v7_decwide72` | committed (r11v72), RV-2's two cells | TO 0, AWAY 0, WRONG2 2 |

**Totals over the twelve arms: FULL TO 45, ENC TO 13, AWAY 0,
MOVED-WRONG 0, STILL 9, WRONG2 9.** Every WRONG2 is one class and §4 names it.

### The three decisive tables

**`w1_pow73` — the value face.** Golden and the law agree on all fifteen
members; pristine is wrong on six:

```
  member         golden                              pristine
  2 ** 40        INT:1099511627776                   EQUAL
  2 ** 62        INT:4611686018427387904             EQUAL
  3 ** 39        INT:4052555153018976256  (ROUNDED)  EQUAL
  5 ** 27        INT:7450580596923828224  (rounded)  EQUAL
  2 ** 63        INT:-9223372036854775808            EQUAL   (slang's own 64-bit answer coincides)
  2 ** 64        INT:-9223372036854775808            INT:0                        TO
  2 ** 70        INT:-9223372036854775808            INT:0                        TO
  3 ** 40        INT:-9223372036854775808            INT:-6289078614652622815     TO
  7 ** 23        INT:-9223372036854775808            INT:8922003266371364727      TO
  10 ** 19       INT:-9223372036854775808            INT:-8446744073709551616     TO
  (-3) ** 41     INT:-9223372036854775808            INT:420491770248316829       TO
  (-2) ** 63     INT:-9223372036854775808            EQUAL   (artefact == true value)
  2 ** 31        INT:2147483648                      EQUAL
```

**`w3_dec73` — the decimal refusal, and it is POSITION-DEPENDENT** (`K+1`/`K+2`
probes on 8-bit members; 8 = golden completed, 64 = golden bailed):

```
  operand 0                             golden        g.probes  pristine probes  law
  DU - 1        (name, 64'd…614)        op11 unfolded  64        64               64
  DU            (the name ALONE)        the leaf       8         8                8
  64'd…614 - 1  (literal in an arm)     op11 unfolded  64        64               64
  64'd…614      (the literal ALONE)     the leaf       8         8                8
  DU % 3                                op13 unfolded  64        64               64
  DS + 1        (DS = 64'd…807 = max)   INT:-92233…    64        64               64
  DS - 1                                INT:92233…806  8         8                8
  D96 * 2       (96'd5 — WIDE, small)   INT:10         8         8                8
  HU - 1        (the SAME bits, HEX)    INT:-3         64        64               64
  D96W - 1      (96'd 2^64, in an arm)  op11 unfolded  64        **8**            64  TO x2
  D96W          (96'd 2^64, ALONE)      the leaf       64        **8**            64  TO x2
  96'd 2^64     (the literal, ALONE)    the leaf       64        **8**            64  TO x2
  K * 2         (CONTROL)               INT:12         8         8                8
```

so **inside an arm the decimal leaf's MAGNITUDE decides and its width does
not**, while at operand 0 the >64-BIT-VALUE rule of the based faces applies
unchanged. `HU - 1` against `DU - 1` is the line that rules out "wide bits":
the same 64 bits refuse as `DEC:` and fold as `HEX:`.

**`w4_hop73` + `w7_untw73` — what the untyped chain carries** (operand 0 is a
guaranteed bail `8'hxA`, so every operand after it prints `reduceExpr`'s own
size against 24-bit members that collide with nothing):

```
  parameter                          slang  golden  pristine  law
  MD   = -16'd5                        16     32      32       32   (landed)
  HOP1 = MD / HOP2 = HOP1 / HOP3       16     32      16       32   TO x3
  UH16 = 16'h28                        16     16      16       16
  HH1  = UH16 / HH2 = HH1              16     16      16       16   verbatim, ABSTAINS
  UD16 = 16'd9 / HD1 = UD16            16     16      16       16   verbatim, ABSTAINS
  byte TB = 8'sd7 / HT1 = TB            8      8       8        8   verbatim THROUGH a typed name
  bit [15:0] WD = -16'd5               16     16      16       16   TYPED: keeps its width
  HW1  = WD                            16     32      16       32   TO   <- the decisive cell
  -HOP2                                16     32      16       32   TO
  AR   = 16'd9 + 16'd1 / HA1 = AR      16     32      16       32   TO x2
  NB   = -8'd3                          8     32      32       32   (landed)
  HN1  = NB / HN2 = HN1                 8     32       8       32   TO x2
  MU   = -UH16 / HU1 = MU              16     32   32 / 16      32   TO
  A64  = 64'd5 + 64'd1                 64     32      64       32   TO
  AW   = 96'd5 + 96'd1 / HAW = AW      96     32      96       32   TO x2
  AP   = 2 ** 64                       32     32      32       32   (the `**` VpiSize is 64)
  AC   = 16'(5)     (a CAST)           16     32      16       32   TO
  AS   = 16'd9 << 1 (a SHIFT)          16     32      16       32   TO
  AH   = 96'h1 + 96'h1                 96   op24 unfolded  96     96   STILL — the gate stands down
  AD   = 64'd…614 - 64'd1              64   op11 unfolded  64     64   STILL — the gate stands down
  K    = 6   (typed, CONTROL)          32     32      32       32
```

`HW1` is the cell that rules out "inherit the target's width": `WD` is TYPED
and golden stores IT at 16, yet the untyped name one hop above reads **32**,
because what `WD` holds is a MINTED `INT:-5` and not `16'd5`. `HT1` is its
mirror: the chain runs THROUGH a typed name and still reads the verbatim
literal's 8.

### The cont_assign road

[evidence/CAROAD.txt](evidence/CAROAD.txt), `caread55.py` `ELAB` listings
diffed against golden's, line for line:

```
  arm             pristine   law
  w1_pow73          12        0     <- identical to golden
  w2_powbail73       2        0     <- identical to golden
  t7_fence72         6        0     <- identical to golden
  t3_beyond72       10        6
  w7_untw73          6        4
  w3_dec73 / w4_hop73 / v1_uadd72 / v4_hop72 / v7_decwide72   unchanged
```

No arm gets worse on that road, and three become identical to golden's.

---

## 4. THE FOUR GATED LAWS (question 4)

Each one is droppable alone: they touch three separate predicates and one
switch case, and none reads another's result.

### LAW A — § patPowCastArtefact73 (r11u72's R0)

One `case` in `red72Int64` ([src/EmitHelpers.h](../../../src/EmitHelpers.h)).
The abstention becomes the producer's own render:

```cpp
double d = std::pow((double)l, (double)r);
if (!(d >= -9223372036854775808.0) || !(d < 9223372036854775808.0))
    out = INT64_MIN;          // the cast's out-of-range artefact, MEASURED
else
    out = (int64_t)d;
return Red72::Value;
```

The narrowing is never PERFORMED on an out-of-range double, so this build has
no signed-conversion UB and the answer does not depend on our own compiler's
choice — it is the measured string, written as a constant. The NaN and
infinity cases (`0 ** -1`) fall into the same branch, which is also what
`cvttsd2si` does.

Closing it costs no new size machinery: the artefact is negative, so the
operand § patBailStopsMemberStamp68 reads now refuses where golden's does, and
its "are these digits the producer's?" guard reads the SAME table
(§ redTableOneHome72, unchanged).

### LAW B — § patRedSz68's `**` arm: ALREADY LANDED, MEASURED, NOT RE-ADDED

r11u72's R2 recorded "`patRedSz68` has no `**` arm — `t3_beyond72` `f` is
golden 64 and ours 32". At `71490354` that is no longer true in either half:
`BinaryOperator::Power` has been in `patRedSz68`'s 64 group since pass 67
(`3e392403`), and both `t3_beyond72` `f` and `w2_powbail73`'s dedicated size
struct read golden's 64 on the PRISTINE binary:

```
  w2_powbail73 CS   golden              pristine   law
  3 ** 39           const/64@7 INT:405…  EQUAL      EQUAL
  2 ** 62           const/64@7 INT:461…  EQUAL      EQUAL
  K * 2             const/64@7 INT:12    EQUAL      EQUAL
  K + 1             const/64@9 UINT:7    EQUAL      EQUAL   (max(l,r))
  K                 const/32@9 UINT:6    EQUAL      EQUAL   (the declared width)
```

`t3_beyond72` `f` reads 64 on pristine because the walk already bails at `b`
(`HUGE * 4`, a negative the table corroborates), so the size the residue
described was being reached by a different route. **R2 is CLOSED by
measurement, and this patch adds nothing for it.** Saying so is the law.

### LAW C — § redDecLeafRangeStrict73 (r11v72's RV-2)

`red72WideBasedLeaf` gains the `'d` base, in ONE home beside the three it
already carries, and the pass-70 position law (§ redWideLeafPositionNotDepth72v)
does the rest — `inArm` is a POSITION, so the two measured rules select
themselves:

```cpp
if (base != 'b' && base != 'h' && base != 'o' && base != 'd') return false;
if (inArm && base != 'd') return e.type->getBitWidth() > 64;
auto iv = e.as<IntegerLiteral>().getValue();
if (inArm) {                       // parseInt64 is RANGE-STRICT
    if (iv.hasUnknown()) return false;
    auto du = iv.as<uint64_t>();
    return !du || *du > (uint64_t)INT64_MAX;
}
…                                   // the !inArm >64-BIT-VALUE rule, unchanged
```

**Its price, stated:** where the table now answers `Refuses` the VALUE writer
falls back to the landed pass-55/65 digit rule, so nine cells move from one
wrong constant to another — `w3_dec73` `CA`/`CC`/`CE`, `v7_decwide72` `A`/`E`,
`v1_uadd72` `b`/`c`/`f`, `w7_untw73` `AD`. **Every one of them is a cell where
golden keeps the operation UNFOLDED** (`op11` / `op13` / `op24`) and our walk
has already folded it, so no spelling of the constant can be right and none of
them can become an AWAY: an AWAY needs pristine to equal golden, and golden has
no constant there at all. They are WRONG2, never MOVED-WRONG. The honest
alternative — refusing only on a >64-BIT value, which would leave those nine
untouched — would buy quiet by mis-transcribing `parseInt64`, and the table's
whole claim is that it is the producer's.

### LAW D — § redUntypedIntNameChain73 (r11v72's RV-3)

`red72UntypedMinusName` keeps its outer gate (an IMPLICITLY typed parameter
with no dimensions) and replaces its one-hop "is the initializer a unary
minus?" with `red73MintsUntypedInt`, a chain walk with an explicit ALLOW-list:
a UnaryOp, a BinaryOp, a Conversion or an UNSIZED integer literal MINTS; a
BASED literal does not; a NAME onto a parameter recurses. A string, a real,
`'0`/`'1`, a concatenation, an enum member and a call are unmeasured and
ABSTAIN.

The gate: when `red72Int64` answers `Refuses` for the initializer the producer
minted nothing at all — golden keeps the whole operation unfolded — so the face
stands down and today's width stays (`w7_untw73` `AH`/`AD`, both STILL). That
is why the predicate now takes the `ASTContext`: the refusal is read from the
ONE home and never transcribed a second time. `patRedSz68` carries the context
through in one added parameter and three recursive call sites; nothing else
about it moved.

### The corroboration fence: KEPT, and the grid says why

r11u72 kept § patBailNegCorroborated68v because LAW A abstained past int64 and
`t7_fence72` `A` was the standing witness. **Both halves of that are gone at
this base**: `A` (`2 ** 31`) is already golden-equal on the pristine binary,
and LAW A now answers on every `**` cell. So the question is whether ANY
abstention class remains that slang evaluates with a leading MINUS while the
producer's own reduce is POSITIVE. `w5_fence73` and `w6_fence64` grid the five
operators `red72Int64` does not model (`<<`, `<<<`, `|`, `&`, `?:`) at a 32-bit
and at a 64-bit member, against an honest-minus control:

```
  operand 0                 golden                 pristine        law    probes (g/p/l)
  BIG << 1        (32-bit)  const/32@9 UINT:4e9    EQUAL           EQUAL   8/8/8
  BIG <<< 1       (32-bit)  const/32@9 UINT:4e9    EQUAL           EQUAL   8/8/8
  (BIG*2) | 0     (32-bit)  const/32@9 UINT:4e9    EQUAL           EQUAL   8/8/8
  (BIG*2) & …     (32-bit)  const/32@9 UINT:4e9    EQUAL           EQUAL   8/8/8
  K>0 ? BIG*2 : 0 (32-bit)  const/32@7 INT:4e9     const/32@9 UINT:4e9 =law 8/8/8
  0 - 32'd100     (32-bit)  const/32@7 INT:-100    EQUAL           EQUAL  64/64/64
  the same six at a 64-bit member                                  identical verdicts
```

**The fold re-encodes at the member width UNSIGNED, so no leading minus ever
reaches `patUvalueRefuses68` on any of them** — the fence is not engaged and
cannot be shown separating anything today. It is NOT retired, and the reason is
precise: retiring it requires the merged predicate to read the producer's
refusal DIRECTLY on every fence witness, and on these five operators the table
does not read the producer at all — it ABSTAINS, and the fence then merely
DECLINES a bail. A decline is a STILL cell and never an AWAY one, so keeping it
costs nothing measurable, while removing it would rest on "I could not build
the witness" rather than on a proof. **r11u72's R1 is therefore re-stated, not
closed** (§6 R1), and the two new arms are the standing record of the search.

---

## 5. CENSUS, PREDICTION AND GATES (questions 5 and 6)

### The a-priori mover prediction, and its positive control

`census73.py` re-subclassifies r11u66's INTISH population (the setters where
the encoding law fires at all) by THIS pass's divergence classes — POW (a `**`
that can leave int64), DECWIDE (a based-decimal leaf beyond INT64_MAX through
NAME hops) and UNTCHAIN (an untyped parameter whose initializer is an operator
or a cast, or a NAME chain onto one). It reads SOURCES only and is a superset
by construction. `--selftest` is the positive half — it must sight POW in
`w1_pow73` / `w2_powbail73` / `t7_fence72`, DECWIDE in `w3_dec73` and UNTCHAIN
in `w4_hop73` / `w7_untw73` — and reads `SELFTEST PASS`.

```
STRICT  AGG=785 BASED=6133 CAST=2223 INTISH=31 NAME=507 OTHER=5047
        PLAIN=1582 UINTISH=3701          AGREE=31                    CANDIDATES 0
LOOSE   INTISH=50                        AGREE=37 POW=13             CANDIDATES 5
        DECWIDE=0 and UNTCHAIN=0 EVERYWHERE, in both corpora, in both spans
```

The five LOOSE candidates are `Ariane2024`, `AzadiRTL`, `ariane`, `cva6_equiv`
(all `2**(MAN_BITS-1)`) and `struct_pattern_procedural` (`2**(23-1)`) — small
powers int64 and the expression's own width agree on, and all of them in
PROCEDURAL spans the admission gate fences. r11u72's own scanner, re-run
unchanged in the same file, reproduces its committed numbers to the unit
(`STRICT AGREE=20 OVF=2 WRAP=9`, 5 candidates; `LOOSE AGREE=21 OVF=17 WRAP=12`,
12 candidates). **The prediction is NO MOVERS IN EITHER CORPUS.**

**POSITIVE CONTROL** ([evidence/POSCTL.txt](evidence/POSCTL.txt)) — all three
faces sighted on a real corpus test's own sources
(`uhdm2rtlil/test/cva6_struct_param_field/dut.sv`), one added parameter per
face, both binaries run in the SAME directory writing the SAME output name
because the serializer embeds the output path:

```
  cvb_base  SAME     cvb_pow  DIFFERS    (2 ** 64 in a 64-bit struct field)
  cvc_base  SAME     cvc_unt  DIFFERS    (an untyped name chain after a bail)
  cve_base  SAME     cve_dec  DIFFERS    (96'd 2^64 at operand 0, 8-bit probes)
```

every one `prc=0 lrc=0`, and on `cve_dec` the two probe cells CONVERT to golden
(`const/8@9 UINT:7/8` → `const/64@9 UINT:7/8`). On `cvb_pow` golden's dump
carries the artefact six times, the law's twice and pristine's not at all. The
corpus zero is sighted, not assumed.

### The wide boundary

`bnd72.sh` over **all 1095 probe arms that contain an assignment pattern** —
the 1088 committed at `71490354` plus this pass's seven `w*` arms; the six
`cv*` positive-control sources were written after the list was taken and are
scored in [evidence/POSCTL.txt](evidence/POSCTL.txt) instead — path-neutral,
both binaries
([evidence/BOUNDARY.1095arms.txt](evidence/BOUNDARY.1095arms.txt)):
**1079 SAME, 10 DIFFERS, 6 NODB** (arms both binaries reject identically,
`prc=lrc=3`). The ten are the five of this pass's own grid that move
(`w1_pow73`, `w2_powbail73`, `w3_dec73`, `w4_hop73`, `w7_untw73` — `w5_fence73`
and `w6_fence64` read SAME, which is the fence result stated as bytes) and the
five committed arms named in §3 (`t3_beyond72`, `t7_fence72`, `v1_uadd72`,
`v4_hop72`, `v7_decwide72`), each scored above against a real Surelog v1.87
golden with **AWAY 0 and MOVED-WRONG 0**. All 49 pass-70 and pass-71 arms are
inside that sweep: **48 SAME and 1 NODB** (`r11u70repro/c4.sv`, `prc=lrc=3` on
both binaries), so the pass-70 value/size ground and the landed encoding
controls re-run BYTE-IDENTICAL.

### Gates — all mandatory, all green

1. **Both binaries built `-j 2` in this pass's own worktree, md5s taken
   separately, frozen `chmod 555` before any sweep.** Pristine
   `598195b29a98fb7ee3263d01d53861e6`, byte-identical to the main tree's
   `build/slang-uhdm` at `71490354`. Law `f7e288e08efb587e4a2b8c9dcfd11752`.
2. **Goldens** `23 PASS / 0 FAIL` on the law binary AND on the pristine one;
   `SLANG_UHDM=/bin/false` gives `0 PASS / 23 FAIL` (the negative control).
3. **uhdm2rtlil, both modes** `788 CMP_EQUAL / 16 CMP_NOTEQUAL / 67
   SLANG_REJECT` in each mode. The 1742-row both-mode join against the
   committed `results/golden_uhdm2rtlil.csv` reads **0 differing ROWS**, the
   same join against this pass's OWN pristine sweep reads 0, and the testflags
   gate against `results/gate_uhdm2rtlil.csv` PASSES.
4. **Surelog suite, `--mode both`** `474 CMP_EQUAL / 9 CMP_NOTEQUAL` default
   and `469 / 8` testflags on the law binary, and the SAME four numbers on
   this pass's own pristine sweep, bucket for bucket against the committed
   `results/golden_surelog.csv` (`5 DEFERRED / 285 SLANG_REJECT / 25
   SURELOG_FAIL` default, `5 / 3 NO_DATABASE / 1 NO_UHDM / 286 / 23 / 1
   TIMEOUT / 2 UNTRANSLATABLE` testflags — every bucket identical). FOUR rows
   differ from the committed row text and all four are environment, quoted:

   ```
   Earlgrey_0_1,default,CMP_EQUAL,,,differ    -> CMP_EQUAL,,,
   Earlgrey_0_1,testflags,CMP_EQUAL,,,differ  -> CMP_EQUAL,,,
   LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "<workdir>/…"
   LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "<workdir>/…"
   ```

   The Earlgrey pair is the documented uhdm-dump timeout draw and it happens
   on the PRISTINE sweep too, in both modes; the STATUS is `CMP_EQUAL` in both
   modes on both binaries and the DATABASE is on its pin (below). The
   law-vs-own-pristine whole-row join over all 1596 rows differs on **exactly
   the two `LowMem*` workdir strings** and nothing else, with identical
   per-mode dump-column histograms.
5. **byteverify `SELFCHECK=1` against this pass's own pristine workdirs.**
   uhdm2rtlil: `PATH_SETS_IDENTICAL (1608 paths)`, **MOVERS 0 / 1608**,
   selfcheck sights 1607/1608 — exactly the a-priori prediction of no corpus
   movers. Surelog: `PATH_SETS_IDENTICAL (960 paths)`, **MOVERS 4 / 960**,
   selfcheck 959/960, and all four are the documented UVM coin, attributed
   order-blind (sorted dumps, workdir-normalised):

   ```
   default/MiniAmiq     4 lines:  UINT:1137 <-> UINT:572   + the vpiDecompile pair
   default/SeqDriver    4 lines:  UINT:0    <-> UINT:781   + the vpiDecompile pair
   testflags/MiniAmiq   4 lines:  UINT:0    <-> UINT:589   + the vpiDecompile pair
   testflags/SeqDriver  4 lines:  UINT:1188 <-> UINT:1298  + the vpiDecompile pair
   ```

   one `UINT` / `vpiDecompile` LINE-NUMBER pair each and **not one
   `vpiConstType` line** on any of the four — which is what these laws'
   signature would have to contain, since the value writer sets
   `VpiConstType`, `VpiValue` and `VpiDecompile` together and never a bare
   `UINT:` line number, and `patRedSz68` sets `VpiSize`.
   **POSITIVE CONTROL for that attribution:** the SAME frozen PRISTINE binary
   on `MiniAmiq/default`'s own command line, three invocations, three DISTINCT
   database hashes (`7f0352c5930f`, `26db02f9efd9`, `93c118335e6a`). (That
   control was run AFTER byteverify and the four attributions were taken; its
   first attempt inherited the command line's absolute `-o` and overwrote the
   pristine workdir's `MiniAmiq/default` database, so that one path in
   `/tmp/r11u73_wdp` no longer holds its sweep bytes. Every number above was
   measured before it.)
6. **Canaries.** `canaries.sh` reads `ok=50 changed=2` on the surelog CSV —
   the two changes are the Earlgrey dump column of gate 4, and the PRISTINE
   sweep reads `ok=50 changed=2` with the same two rows — and `ok=8
   changed=0` on the u2r gate CSV. Both `ctcan2.sh` runs PASS (`ok=58` and
   `ok=1`, `changed=0`); `canaudit.sh` reads `audited=29 UNCOVERED=0
   FENCE-BREACH=0`. Every protected database is on its pin and BYTE-IDENTICAL
   between the two binaries in BOTH modes: SVSwitch `4842211c4030`, YosysVerx
   `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 default
   `8bdf25272e08` / testflags `59d0ee6d10c3`, BlackParrotComplex
   `e3e354129d5a` / `73a10e8217e5`, YosysOldOr `d68e0796d62c`. The UVM family
   rows are `CMP_EQUAL` on both binaries in both modes (BuildUVMPkg, MiniAmiq,
   SeqDriver, SimpleUVM default+testflags; Scoreboard default `CMP_EQUAL`,
   testflags `SLANG_REJECT`) exactly as committed.
7. `results/*.csv` **untouched**; the fence check over the patch reads
   `0 0 0 0`; every `cmds.txt` names the frozen binary by absolute path —
   u2r **1742 / 1742**, surelog **1531 / 1581** (the remaining 50 are rows
   where Surelog failed and slang never ran) — and **0** name the main tree in
   either sweep.

---

## 6. RESIDUES

* **R0 — the corroboration fence's live class is still unexhibited.** LAW A
  removes the abstention r11u72 kept § patBailNegCorroborated68v for, and
  `w5_fence73` / `w6_fence64` show the five unmodelled operators re-encoding
  UNSIGNED at both member widths, so no leading minus reaches the refusal. The
  fence is kept because it only ever DECLINES a bail; retiring it needs a proof
  that the merged predicate reads the producer's refusal on every witness, and
  on those five operators the table abstains instead. Two arms, 0 cells.
* **R1 — the `+` arm's UNSIGNED half (r11v72's RV-5) is still unmodelled.**
  `ExprEval.cpp:3267-3296` picks `get_uvalue` + `UINT:` unless one reduced
  operand is `vpiIntConst` / `vpiStringConst` / `vpiRealConst` / `vpiDecConst`;
  `red72Int64` applies the signed arm unconditionally. Still fenced by
  `caSubstLeafCt56 == vpiIntConst`; `v1_uadd72` `a`/`d` are golden-equal on both
  binaries and no LAW here forces the gate open. RECORDED, not modelled.
* **R2 — the unfolded-operation SHAPE, nine cells.** Where the producer's
  reduce refuses an arm golden keeps the OPERATION (`op11` / `op13` / `op24`)
  and our walk has already folded it to a constant. LAW C makes the refusal
  visible to the bail but cannot un-fold the operand, so those nine cells stay
  wrong and this pass re-spells them (§4). A § ifaceArrayDefFold-class residue,
  older than this pass (r11u72's R4, r11v72's RV-4, `CompileHelper.cpp:5432`).
* **R3 — the untyped-parameter size has faces the ALLOW-list declines.** A
  string, a real, `'0`/`'1`, a concatenation, an enum member and a constant
  function call as an untyped initializer are unmeasured; `red73MintsUntypedInt`
  abstains on all of them and today's width stands. One arm would settle them.
* **R4 — `t3_beyond72` `g`/`h`/`i` and `a4_wide66` op1** are unchanged:
  >64-bit member shapes and a size our own bail does not reach (r11u72's R3).

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wt 71490354 && cd /tmp/wt && git apply -3 /tmp/r11u73.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2 && md5sum build/slang-uhdm      # f7e288e08efb…
R=$PWD/tools/probe/r11u73repro
G=/tmp/g73 && mkdir -p $G && cp $R/grid/*.sv $R/run66.sh $R/shape.py \
   $R/ord66v.py $R/caread55.py $G/
cp $PWD/tools/probe/r11u72repro/grid/{t3_beyond72,t7_fence72}.sv $G/
cp $PWD/tools/probe/r11v72repro/grid/{v1_uadd72,v4_hop72,v7_decwide72}.sv $G/
for a in w1_pow73 w2_powbail73 w3_dec73 w4_hop73 w5_fence73 w6_fence64 \
         w7_untw73 t3_beyond72 t7_fence72 v1_uadd72 v4_hop72 v7_decwide72; do
  bash $G/run66.sh $G/$a.sv pris <pristine binary>     # rc for BOTH sides
  bash $G/run66.sh $G/$a.sv law  $PWD/build/slang-uhdm
  python3 $G/ord66v.py $G/$a.g.dump $G/$a.pris.dump $G/$a.law.dump $a
  diff <(python3 $G/caread55.py $G/$a.g.dump ELAB) \
       <(python3 $G/caread55.py $G/$a.law.dump ELAB)
done
python3 $R/census73.py --selftest && python3 $R/census73.py
# the wide boundary (1095 arms, ~20 min at -P 2):
cd tools/probe && grep -rl "'{" $(find . -name '*.sv') | sed 's#^\./##' | sort -u > /tmp/l.txt
BND_PRIS=<pristine> BND_LAW=$PWD/../../build/slang-uhdm BND_ROOT=$PWD \
  BND_OUT=/tmp/bnd xargs -a /tmp/l.txt -P 2 -I{} bash $R/bnd72.sh {}
```
