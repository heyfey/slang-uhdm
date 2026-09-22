# r11u100 — the power arm mints an `int`, and the two digit roads meet a width this site cannot see

**ONE LAW LANDS, TWO ARE DECODED AND HELD.** § powTopIsIntReduce100 closes
r11u96's R1 and r11u97's R1 — the `**` arm at the TOP of a package parameter —
and it closes the § patPowCastArtefact73 VALUE face with it, measured on the
same grid, cell for cell, at every magnitude from `2 ** 0` to `10 ** 19`.
§ uintArmWrittenDigitsMasked100 (r11u96's R3, r11u97's R2, r11v96's RV96-5) and
§ bareUnsizedDecIsMaskedDigits100 (r11u96's R4) are fully decoded, fully
gridded, and **shipped with their flags FALSE**: their grid convicted them of a
class of AWAY cells that § powTopIsIntReduce100 is structurally immune to, and
the cure needs a width that reaches the exporter only in `ModuleEmit`, which is
the sister pass's ground. **That is this pass's R0, and it is named exactly.**

Base `65981255`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden here is a real Surelog v1.87 run through
the committed `r11u86repro/run66.sh`, and every arm records `slrc` / `ourrc` /
`slerr`: **all 24 grid arms read `0 0 0` on both binaries, all 48 arm-runs**
(`evidence/ARMS100.txt`).

| binary | md5 | what |
|---|---|---|
| pristine | `64699fe6f1399357c029e4962b07c84a` | built in this pass's own worktree — byte-identical to the main tree at `65981255` and to the ops-brief md5 |
| **law** | `534e12a3f3fa8831c761c20f5a92c418` | this patch |
| `powTop100` reverted | `0a54e8843f9b4eeb11b1159f8bef41ab` | its dumps are byte-identical (path-normalised) to PRISTINE's on all 14 arms re-run against it |

---

## 1. THE PRODUCER, LINE BY LINE

### 1.1 LAW A — `vpiPowerOp` is `vpiMultOp`'s body with one operator swapped

```cpp
case vpiPowerOp: {                 // ~/git-repos/UHDM/templates/ExprEval.cpp:3765
  int64_t val0 = get_value(invalidValueI, expr0);
  int64_t val1 = get_value(invalidValueI, expr1);
  val = static_cast<int64_t>(std::pow<int64_t>(val0, val1));
  c->VpiValue("INT:" + std::to_string(val));
  c->VpiDecompile(std::to_string(val));
  c->VpiSize(64);
  c->VpiConstType(vpiIntConst);
```

— identical, line for line, to the `vpiMultOp` arm at `:3479` that r11u96
landed, and to `vpiDivOp` (`:3803`) and `vpiModOp` (`:3709`). r11u96 held it
back and r11u97 held it back again for ONE reason, written down both times:
**its VALUE runs in `double`.** `std::pow<int64_t>` promotes both operands to
`double` (`__gnu_cxx::__promote_2<int64_t,int64_t>::__type` IS `double`), so
the arm is double arithmetic with ONE narrowing at the end, and
`red72Int64`'s own `Power` arm has carried that reading since r11u73 as
§ patPowCastArtefact73. **The two faces are measured here TOGETHER, on one
grid, before anything was transcribed, and they agree in every cell** (§3.1).

### 1.2 WHY THE `INT:` ROAD NEEDS NO READING WIDTH

`CompileHelper::adjustSize`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:4102-4155`) has a
branch for `vpiUIntConst` (mask to the target's width, re-render unsigned) and
a branch for `vpiBinaryConst` — **and none at all for `vpiIntConst`.** An
`INT:` constant is therefore never masked, at the parameter's declaration or at
any read. Measured, three ways:

* `int CPOW = 2 ** 3` is golden `INT:8` read by a 64-bit net, by a 32-bit net
  and by an **8-bit** net alike (`p4_fence100` `wCPW` / `wNCPW` / `w8CPW`);
* `logic [7:0] PU8 = 10 ** 3` is golden `INT:1000` — the declared byte never
  masks the answer (`p1_powtop100` `wPU8`, ours `UINT:232`);
* `byte PBY = 5 ** 3` is golden `INT:125`.

That is exactly what makes LAW A safe where LAWS B and C are not.

### 1.3 LAWS B AND C — the `vpiUIntConst` branch, and the mask that runs TWICE

Five arms read the WRITTEN DIGITS exactly as the `INT:`-minting five do and
then keep `UINT:` — `vpiAddOp`/`vpiPlusOp`'s `unsignedOperation` branch
(`ExprEval.cpp:3284-3294`), `vpiBitAndOp` (`:3350`), `vpiBitOrOp` (`:3329`) and
the two shift bodies (`:3149` / `:3236`) — and a BARE decimal leaf reaches the
same branch with no arm above it at all. `adjustSize` then does

```cpp
uint64_t mask = NumUtils::getMask(size);   uval = (uint64_t)val & mask;
c->VpiValue("UINT:" + std::to_string(uval));  c->VpiDecompile(std::to_string(uval));
```

**and it runs a SECOND time at the READ, with the READING target's width.**
Measured on `p4_fence100`:

| read | golden |
|---|---|
| `longint BLB = 9223372036854775807` by a 64-bit net | `UINT:9223372036854775807` |
| the same by a 32-bit net | `UINT:4294967295` |
| the same by an 8-bit net | `UINT:255` |
| `longint BADD = 4294967296 + 1` by a 64-bit net | `UINT:4294967297` |
| the same by a 32-bit or an 8-bit net | `UINT:1` |

`^` is NOT on this list and it is measured so: `reduceExpr` has **no
`vpiBitXorOp` arm at all** (`grep -n 'case vpiBitXorOp'` finds it only in the
DECOMPILE name table at `:1039` / `:1077`), and Surelog v1.87 leaves
`4294967296 ^ 1` UNFOLDED — golden writes a `ref_obj` and no constant
(`p2_uintdig100` `wCXOR`).

---

## 2. THE THREE § BLOCKS

### § powTopIsIntReduce100 — `src/EmitHelpers.h` + `src/ExprEmit.cpp` — **ON**

```
red100IntMintTop100(e, mul96, div96, mod96, add97, pow97, powTop100)
        the landed red97IntMintTop97 OR a binary `**` at the TOP of the
        initializer with only implicit conversions peeled.
the call site: red97IntMintTop97(*mi94, mul96, div96, mod96, add97, pow97)
            -> red100IntMintTop100(*mi94, …, powTop100)
```

ONE FLAG ON THE LANDED TABLE, not a second predicate: `red97IntMintTop97`
already carries `mul96`, `div96`, `mod96`, `add97` and the `pow97` CHILD flag,
and `powTop100` is its sixth entry. The VALUE comes off `red72Int64`'s landed
`Power` arm unchanged — **no arithmetic was written in this pass at all.**

### § uintArmWrittenDigitsMasked100 — `src/EmitHelpers.h` + `src/ExprEmit.cpp` — **OFF**

```
red100UintArmTop100(e, add100, and100, or100, shl100, shr100)
        the TOP operator is `+`, `&`, `|`, `<<`/`<<<` or `>>`/`>>>`.
red100UintDigits100(e, actx, depth, out)
        the producer's five UINT arms, recursed, every leaf and every NAME hop
        through `red72Int64` WITH `inArm` set (so the based-leaf, unsized-
        decimal and `'0`/`'1` digit arms and § chainStoreChecksTheInitializer97's
        widened name guard all sit under them exactly as they do for the
        producer).  `&` and `|` are computed HERE and NOT added to
        `red72Int64`'s table, for the reason § intCompareIsMinusOne97 gives.
red100MaskedUnsigned100(v, w)   `NumUtils::getMask` written once.
```

### § bareUnsizedDecIsMaskedDigits100 — `src/EmitHelpers.h` + `src/ExprEmit.cpp` — **OFF**

```
red100BareDecDigits100(e, actx, depth, out, name100)
        the landed red96UnsizedDecDigits96 at the TOP of the initializer, plus
        a NAME hop that masks at the inner parameter's own width and declines
        where the name is not its initializer's value (an override, a
        defaulted port) — red72Int64's NAME guard question, asked with slang's
        two evaluations.
```

Both write the same two fields — the masked unsigned digits, and the const
type, by suppressing the landed `neg91` gate (which fires on the sign of
slang's TRUNCATED store). **`ParamEmit.cpp`, `ModuleEmit.cpp`,
`UhdmExporter.cpp`, `include/` and `results/` are ALL ABSENT from this patch.**
The production surface is `src/EmitHelpers.h` and `src/ExprEmit.cpp`.

---

## 3. THE GOLDEN GRID — 24 arms, scored PER FIELD, PER VIEW

Four new arms (`p1_powtop100`, `p2_uintdig100`, `p3_bare100`, `p4_fence100`)
and twenty CONTROL arms from the r11u96, r11u97, r11v96 and r11v97 generations
re-run unchanged. TWO SCORERS, both committed: `nda97.py` reads the
net-decl-assign road per CELL and keys on the LHS net NAME; `loc97v.py` reads
the WHOLE DUMP per cell, per FIELD and PER VIEW, with the five-field split
(`vp`, `vd`, `ct`, `sz`, `d`) r11v97 restored — **RV97-2's lesson is obeyed:
every net-decl-assign face is read on BOTH keys**, because a golden constant
with no source range is invisible to a location-keyed scorer.

### 3.1 LAW A, per cell (`p1_powtop100`, `p4_fence100`, and the four controls)

| package declaration | golden | pristine | law |
|---|---|---|---|
| `int CPOW = 2 ** 3` | **`INT:8 ct7`** | `UINT:8 ct9` | golden |
| `int CPOW0 = 2 ** 0` | **`INT:1`** | `UINT:1` | golden |
| `int CPOW1 = 7 ** 1` | **`INT:7`** | `UINT:7` | golden |
| `int CPOWZ = 0 ** 3` | **`INT:0`** | `UINT:0` | golden |
| `int CPOWO = 1 ** 31` | **`INT:1`** | `UINT:1` | golden |
| `longint PBIG40 = 2 ** 40` | **`INT:1099511627776`** | `UINT:` same digits | golden |
| `longint PBIG62 = 2 ** 62` | **`INT:4611686018427387904`** | `UINT:` same | golden |
| `int PNARR = 100 ** 3` | **`INT:1000000`** | `UINT:1000000` | golden |
| `longint PNAME = CPOW ** 2` | **`INT:64`** | `UINT:64` | golden |
| `longint PPAR = (2 ** 3)` | **`INT:8`** | `UINT:8` | golden |
| `byte PBY = 5 ** 3` | **`INT:125`** | `UINT:125` | golden |
| `logic [7:0] PU8 = 10 ** 3` | **`INT:1000`** | `UINT:232` | golden — the `INT:` road is NEVER masked |
| **AND THE CAST ARTEFACT, THE WHOLE REASON IT WAITED** | | | |
| `longint P339 = 3 ** 39` | **`INT:4052555153018976256`** | `UINT:…267` | golden — the DOUBLE-ROUNDED value |
| `longint P527 = 5 ** 27` | **`INT:7450580596923828224`** | `UINT:…125` | golden |
| `longint PB63 = 2 ** 63` | **`INT:-9223372036854775808`** | `INT:` same | unchanged |
| `longint PB64 = 2 ** 64` | **`INT:-9223372036854775808`** | `UINT:0` | golden |
| `longint PB70 = 2 ** 70` | **`INT:-9223372036854775808`** | `UINT:0` | golden |
| `longint P340 = 3 ** 40` | **`INT:-9223372036854775808`** | `INT:-6289078614652622815` | golden |
| `longint P723 = 7 ** 23` | **`INT:-9223372036854775808`** | `UINT:8922003266371364727` | golden |
| `longint P1019 = 10 ** 19` | **`INT:-9223372036854775808`** | `INT:-8446744073709551616` | golden |
| `longint PNEG = (-3) ** 41` | **`INT:-9223372036854775808`** | `UINT:420491770248316829` | golden |
| `longint PNEG2 = (-2) ** 3` | `INT:-8` | `INT:-8` | unchanged |
| **AND THE READING WIDTHS — the same answer at every one** | | | |
| `p4p::CPW` read by a 64/32/**8**-bit net | **`INT:8 ct7`** at all three | `UINT:8 ct9` | golden |
| **AND THE LIVE NEGATIVE CONTROL — every one EQUAL, before and after** | | | |
| `int CPOWC = int'(2 ** 3)` | `UINT:8` | `UINT:8` | unchanged — an EXPLICIT cast at the top |
| `int APOWL = (2 ** 3) + 1` | `INT:9` | `INT:9` | unchanged — the landed `pow97` CHILD |
| `int CMUL = 2 * 3` / `CADD = 1 + 2` / `CLIT = 6` | `INT:6` / `UINT:3` / `UINT:6` | same | unchanged |

**THE VALUE FACE AND THE MINT FACE AGREE IN EVERY CELL.** Golden's answer in
all twelve magnitude cells is `red72Int64`'s landed `Power` arm verbatim,
including the double rounding within range (`3 ** 39`, `5 ** 27`) and the
`cvttsd2si` integer-indefinite pattern past it (`2 ** 64`, `3 ** 40`, `7 ** 23`,
`10 ** 19`, `(-3) ** 41`). **Not one line of arithmetic was written for this
law** — the reduce that r11u73 measured and r11u96 declined to trust is the one
the producer performs.

### 3.2 LAWS B AND C, per cell (`p2_uintdig100`, `p3_bare100`, `p4_fence100`)

Every cell below is MEASURED on real Surelog v1.87 and reproduced in
`evidence/CELLS100.txt`; none of them moves on the shipped binary, because the
flags are false.

| package declaration | golden | pristine (= law) |
|---|---|---|
| `longint BADDU = 4294967296 + 1` | `UINT:4294967297` | `UINT:1` |
| `longint BADD31 = 2147483648 + 1` | `UINT:2147483649` | `INT:-2147483647` |
| `longint BADDS = 9223372036854775807 + 1` | `UINT:9223372036854775808` | `UINT:0` |
| `longint BANDU = 4294967296 & 4294967296` | `UINT:4294967296` | `UINT:0` |
| `longint BAND31 = 2147483648 & 2147483648` | `UINT:2147483648` | `INT:-2147483648` |
| `longint BORU = 4294967296 \| 1` | `UINT:4294967297` | `UINT:1` |
| `longint BSHL = 2147483648 << 1` | `UINT:4294967296` | `INT:-4294967296` |
| `longint BSHR = 4294967296 >> 1` | `UINT:2147483648` | `UINT:0` |
| `longint BSHIFTC = 4294967296 >> 64` | `UINT:4294967296` | `UINT:0` — § redShiftIsUnsignedSixtyFour78's 6-bit count |
| `int U1ADD = '1 + 0` | `UINT:1` | `INT:-1` — r11u97's R2 |
| `int U1AND = '1 & 3` | `UINT:1` | `UINT:3` |
| `longint BLBARE = 9223372036854775807` | `UINT:9223372036854775807` | `INT:-1` — r11u96's R4 |
| `longint BLMAXU = 18446744073709551615` | `UINT:18446744073709551615` | `INT:-1` |
| `longint BL32 = 4294967296` | `UINT:4294967296` | `UINT:0` |
| `int IB31 = 2147483648` | `UINT:2147483648` | `INT:-2147483648` |
| `byte YB200 = 200` | `UINT:200` | `INT:-56` |
| `shortint SB40K = 40000` | `UINT:40000` | `INT:-25536` |
| `logic [63:0] U64BIG = 9223372036854775807` | `UINT:9223372036854775807` | `UINT:18446744073709551615` |
| `int CN32 = BLB` (a NAME hop) | `UINT:4294967295` | `INT:-1` |
| `byte CN8 = BLB` | `UINT:255` | `INT:-1` |
| **AND THE MASK AT THE DECLARATION, on both sides of it** | | |
| `int IADDU = 4294967296 + 1` | `UINT:1` | `UINT:1` — EQUAL already |
| `int IB32 = 4294967296` | `UINT:0` | `UINT:0` — EQUAL already |
| `logic [7:0] U8B300 = 300` | `UINT:44` | `UINT:44` — EQUAL already |
| **AND THE DECLINES, measured** | | |
| `longint CXOR = 4294967296 ^ 1` | **UNFOLDED — golden writes NO constant** | `UINT:1` |
| `int FADDS = fs(4) + 1` (a const CALL) | `UINT:6` | `INT:6` — the landed `callSigned9` gate |
| `longint CLAND = 4294967296 && 1` | `UINT:1` | `UINT:0` — a DIFFERENT body |
| `longint CTERN = 1 ? 4294967296 : 0` | `UINT:4294967296` | `UINT:0` — a DIFFERENT body |

### 3.3 WHY THE TWO FLAGS ARE FALSE — the grid's own verdict

Built with all seven flags TRUE, the same grid reads:

| arm | TO | AWAY | MOVED-WRONG |
|---|---|---|---|
| `p2_uintdig100` | 53 | **2** | **2** |
| `p3_bare100` | 52 | 0 | **2** |
| `p4_fence100` | 31 | **4** | **10** |

and **every one of those cells is a read NARROWER than the parameter**:

```
wNBADDU  g[UINT:1 sz32]      pristine[UINT:1]   law[UINT:4294967297]   AWAY
w8BADD   g[UINT:1 sz8]       pristine[UINT:1]   law[UINT:4294967297]   AWAY
wNBLB    g[UINT:4294967295]  pristine[INT:-1]   law[UINT:9223372036854775807]  MOVED-WRONG
w8BLB    g[UINT:255]         pristine[INT:-1]   law[UINT:9223372036854775807]  MOVED-WRONG
```

The AWAY cells are AWAY for a STRUCTURAL reason, not a lucky one: slang types
an unsized decimal `int` and truncates it to 32 bits, and `adjustSize`'s second
mask at a 32-bit read is that same truncation — so at a 32-bit reader the
PRISTINE binary is already golden, and a law that masks only at the
parameter's own width moves it off.

**The width is not reachable from this site.** It was tried and measured, not
assumed: a hook on `emitExpr`'s implicit-`ConversionExpression` branch records
**64** for a `longint` parameter read by a 32-bit AND by an 8-bit net alike
(SystemVerilog evaluates an assignment's RHS at the wider of the two widths and
truncates at the assignment, which is what slang models), and the
`cont_assign`'s `Lhs` is not set until after the RHS is emitted. The reading
net's type reaches the exporter in exactly one place — `ModuleEmit`'s
`dt->getType()`, beside the existing `implicitConvTargetSigned` hand-off and
the existing `VpiSize()==64 -> net width` resize — and `ModuleEmit.cpp` is the
sister pass's ground. **The hook was REMOVED from the deliverable rather than
shipped dead**, and both faces ship behind their flags. `GOLDEN WRITES NOTHING
ON A MISS`: declining is a STILL, never an AWAY.

### 3.4 THE SCORE, AND ITS POSITIVE CONTROL

| arm | TO (`loc97v`, 5 fields, per view) | TO (`nda97`) | AWAY | MOVED-WRONG |
|---|---|---|---|---|
| `p1_powtop100` | **58** | 51 | **0** | **0** |
| `p4_fence100` | **6** | 6 | **0** | **0** |
| `k2_chain94v` | **4** | 3 | **0** | **0** |
| `k4_unbop94v` | **4** | 4 | **0** | **0** |
| `y1_muldiv96` | **2** | 2 | **0** | **0** |
| `z2_addmint97` | **2** | 2 | **0** | **0** |
| the other EIGHTEEN arms | 0 | 0 | **0** | **0** |
| **all 24, tags swapped** | **0** | — | **76** | **76** |

`AWAY = 0` is a MEASUREMENT: swapping the two dumps turns every one of the 76
moved fields into an AWAY *and* a MOVED-WRONG (`evidence/SWAPCTL100.score`).
The eighteen unmoved arms are the live control — `z1_unbased97`, `z3_cmpfam97`,
`z5_chain97`, `z6_pahome97`, `y2_unsized96`, `y4_bail96`, `v1_amulbrk96v`,
`v5_unbased96v`, `k1_ctype94v`, `k7_cwidth94v` and the rest all read TO=0
AWAY=0 MWRONG=0, so **every landed law's cells stand exactly where its own pass
left them**: § pkgParamMulDivModIsIntReduce96, § unsizedDecLeafWrittenDigits96,
§ unbasedUnsizedIsOneDigit97, § addMintFollowsOperandMint97,
§ intCompareIsMinusOne97, § chainStoreChecksTheInitializer97 and
§ cmpBinIsTheWidthRenderingHome97v are unmoved, and the four cells
`k2_chain94v` gains are its OWN `2 ** 40` / `2 ** 63` power cells, which is
this law reaching a control arm r11v97 built for a different one.

---

## 4. CENSUS, A PRIORI, BY NAME

`census100.py` carries one class per law, each a strict superset of the gate,
with a POSITIVE control (this pass's four arms plus five earlier generations')
and a LIVE NEGATIVE one (`^`, `&&`, `||`, `!`, `?:`, `===`, `!==`, a unary `+`,
a comparison, a cast, a based literal, a minus — every one of which must be
UNSIGHTED).

```
AGREE100 8581  BARE100 3829  BNAM100 441  BWL100 23  POW100 22  POWW100 22
UAR100 264  UARW100 327  UDC100 310  UNBO100 40
--- candidate tests: 151                              SELFTEST PASS
  not sighted (2): k5_homes94v k7_cwidth94v            [the live negative control]
```

`BARE100` — every `localparam W = 4` in both corpora — is REPORTED and NOT used
for the prediction: the producer's digits and slang's store agree below 2^31,
so a bare decimal can only move where it meets a DIGIT SOURCE (`UDC100`,
`UNBO100` or `BWL100`). `POW100` needs no such meeting: the const type goes
9 -> 7 at every magnitude, which is what makes it the whole of the live
prediction.

`predict100.py` re-keys the census from the TEST DIRECTORY to the SWEEP ROW,
reading each row's own `cmds.txt` and its whole test tree:

```
predict100.py <u2r workdir>       0 rows   (loose class union: 64 rows)
predict100.py <surelog workdir>   3 rows   Ariane  BlackParrotMuteErrors  IncompTitan
                                           (loose class union: 107 rows)
```

and all three of those rows produce NO DATABASE at this pin (`SURELOG_FAIL`,
`SLANG_REJECT`, `SLANG_REJECT`), so the measured LAW-A mover set is **ZERO** and
is a subset of the prediction. The four Surelog byteverify movers are named and
attributed in `evidence/MOVERS100.txt`, and `predict100.py` names none of them.

---

## 5. GATES — ALL MANDATORY (`evidence/GATES100.txt`)

**5.1 BUILD.** `-j 2`, `md5sum` separately, every binary `chmod 555` BEFORE any
sweep. Pristine `64699fe6f1399357c029e4962b07c84a` — **byte-identical to the
main tree at `65981255` and to the ops brief's md5**. Law
`534e12a3f3fa8831c761c20f5a92c418`. 0 errors, 0 new warnings.

**5.2 GOLDENS.** `23 PASS / 0 FAIL` on pristine AND law; the negative control
`SLANG_UHDM=/bin/false` -> `0 PASS / 23 FAIL`.

**5.3 uhdm2rtlil, BOTH MODES, BOTH BINARIES.** `788 / 16 / 67` in all four
sweeps. Both-mode 1742-row whole-row join against
`results/golden_uhdm2rtlil.csv`: **DIFF=0 on both binaries**. Testflags gate
against `results/gate_uhdm2rtlil.csv`: `PASS: every row byte-identical` on both.
All 3484 `cmds.txt` audited BY ABSOLUTE BINARY PATH — 1742 name the frozen
pristine, 1742 the frozen law, **0 name the main tree**.

**5.4 Surelog `--mode both`, BOTH BINARIES.** `474 / 9` default and `469 / 8`
testflags on BOTH, every histogram cell identical to the committed baseline
(`SLANG_REJECT 285/286`, `SURELOG_FAIL 25/23`, `DEFERRED 5/5`,
`NO_DATABASE 3`, `NO_UHDM 1`, `TIMEOUT 1`, `UNTRANSLATABLE 2`). The whole-row
join against `results/golden_surelog.csv` names, on the LAW binary, exactly
three rows and no fourth:

```
LowMemLib     testflags  SURELOG_FAIL, DETAIL = the sweep's OWN workdir path
LowMemPkg     testflags  SURELOG_FAIL, DETAIL = the sweep's OWN workdir path
Earlgrey_0_1  default    CMP_EQUAL, the DUMP COLUMN blank
```

and the PRISTINE sweep names the first two plus `Earlgrey_0_1` in BOTH modes —
the documented `uhdm-dump` timeout draw, which lands on whichever sweep is
unlucky. Earlgrey's DATABASE, which is the pin, is byte-identical between the
two binaries in both modes and at its ops-brief md5. **No status moved, in
either direction, on any row of either corpus.**

**5.5 byteverify, SELFCHECK=1, both corpora, against this pass's own pristine
workdirs** (`evidence/MOVERS100.txt`).

* **uhdm2rtlil: `MOVERS 0 / 1608`, `PATH_SETS_IDENTICAL`, `SELFCHECK
  1607/1608`** — and `predict100.py` predicted 0 rows.
* **Surelog: `MOVERS 4 / 960`, `PATH_SETS_IDENTICAL`, `SELFCHECK 959/960`.**
  `MiniAmiq/default`, `SeqDriver/default`, `SimpleUVM/default` and
  `SeqDriver/testflags`, and **none of them is this pass's**. Attributed
  ORDER-BLIND on path-normalised SORTED dumps: each moves **exactly four lines,
  one `|UINT:` / `|vpiDecompile:` pair**, and across all four **`|INT:` 0,
  `vpiConstType` 0, `vpiSize` 0, `Typespec` 0, `|BIN:` 0** — none of the fields
  this law writes. **POSITIVE CONTROL, and no pad binary is needed: the
  PRISTINE binary run FOUR TIMES on MiniAmiq/default's own `cmds.txt`
  invocation produced FOUR DIFFERENT DATABASES** (`c18cc3882a26`,
  `d62aa6ff1801`, `9092c019b503`, `e388757e871d`), and the order-blind diff of
  two of them is the SAME single `|UINT:` / `|vpiDecompile:` pair. It is
  r11u96's R7 / r11v96's RV94-5 — the `uvm_pkg` 642:23 dynamic-array range
  bound our emitter prints from an uninitialized pointer-valued `UINT` — latent
  on every binary.

**5.6 CANARIES AND PINS.** Surelog `ok=51 changed=1` on the LAW binary and
`ok=50 changed=2` on the PRISTINE one. Every "changed" row on both is
`Earlgrey_0_1`'s DUMP COLUMN alone — `CMP_EQUAL/differ -> CMP_EQUAL/`, the
status untouched. u2r `ok=8 changed=0 absent=0` on both. `ctcan2` PASS on both
corpora and both binaries. `canaudit.sh canaries.sh ctcan2.sh` ->
`audited=29 UNCOVERED=0 FENCE-BREACH=0`. **Every protected database at its
ops-brief pin AND byte-identical between pristine and law, both modes:**

```
SVSwitch 4842211c4030   YosysVerx 6ccda350c24a   InterfaceModPort 59a365f3ce2c
BlackParrotComplex e3e354129d5a / 73a10e8217e5   YosysOldOr d68e0796d62c
Earlgrey_0_1 8bdf25272e08 (default) / 59d0ee6d10c3 (testflags)
```

**5.7 THE CONVERSION ROWS, official `uhdm-cmp`, golden as LHS.**
`measured=13 SKIP-NOFILE=1 UNKNOWN-NAME=0`, every one **0 cmp lines / 0 heads,
`cmp rc=0`** — BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
Earlgrey_0_1 and ParamOverloading, both modes. The one SKIP-NOFILE is the
documented `Scoreboard/testflags`.

**5.8 DROPPABLE ALONE** (`evidence/DROP100.txt`). One flag, `powTop100`, is
worth all 76 fields, and the binary built with it false has dumps
**byte-identical (path-normalised) to PRISTINE's on all 14 arms re-run against
it — 14 compared, 0 differ.** That is the direct proof that the two flags-off
faces compile to nothing and move nothing.

**5.9 THE WIDE BOUNDARY** (`evidence/BOUNDARY100.classes`), every `*.sv` under
`tools/probe`, not the grid glob: **8444 arms — 8205 SAME, 9 DIFFERS, 222
NODB**, and every NODB arm has `prc == lrc` (218 x `rc=3`, 4 x `rc=139`).
**NULL BOUNDARY** (the pristine binary against itself over all 9) reads
**9 SAME / 0 DIFFERS** — not one of them is a run-to-run coin. Six of the nine
are this pass's scored grid; the other three are scored per cell, per field and
PER VIEW against a FRESH Surelog v1.87 golden and are **`|UINT:` -> `|INT:`
with `vpiConstType` 9 -> 7 AND NOTHING ELSE** (`vpiSize` 0, `Typespec` 0):

* `r10earl76repro/g2_orig76.sv` — `UINT:8 ct9 -> INT:8 ct7`, TO=2 AWAY=0
  MWRONG=0, distance to golden 1324 -> **1320**;
* `r11u73repro/grid/w7_untw73.sv` — `localparam AP = 2 ** 64`,
  `UINT:0 ct9 -> INT:-9223372036854775808 ct7`, and **GOLDEN HOLDS
  `INT:-9223372036854775808`**; distance 1885 -> **1879**. The view-keyed
  scorer reads that key as a SKIP and it is reported as a SKIP, not claimed;
* `r10vearl71repro/v3_enc71.sv` — `parameter int B4 = 5 ** 2`,
  `UINT:25 ct9 -> INT:25 ct7` twice, and **golden holds `|INT:25` nine times
  and `|UINT:25` ZERO times**. This arm's GOLDEN COMPILE FAILS
  (`slrc=4 slerr=2`) — r11v97's RV97-3 unchanged — so it teaches error
  recovery, not golden, and nothing rests on it.

**5.10 `results/*.csv` UNTOUCHED.** None of the four slang-fenced names appears
in any file of this patch — a per-name `awk` over the deliverable reads 0 for
each — and no test of theirs was ever dispatched as an arm. **`ModuleEmit.cpp`,
`ParamEmit.cpp`, `UhdmExporter.cpp` and `include/` are ALL ABSENT.** The
production surface is `src/EmitHelpers.h` and `src/ExprEmit.cpp`, plus
`tools/probe/r11u100repro/`.

**5.11 THE SHIPPED SOURCE IS THE MEASURED SOURCE.** Checked, not assumed: the
deliverable patch applied to a FRESH `65981255` worktree with `git apply -3`
(rc 0, no conflict marker) and built there independently links to
**`534e12a3f3fa8831c761c20f5a92c418`, byte for byte** — the law binary every
measurement above was taken on.

---

## 6. RESIDUES

* **R1 — THE DIGIT ROAD WITHOUT THE CONST-TYPE ROAD NEEDS THE READING WIDTH.**
  § uintArmWrittenDigitsMasked100 and § bareUnsizedDecIsMaskedDigits100 are
  written, gridded and correct at the parameter's own width, and WRONG at a
  read narrower than it — 2 AWAY on `p2_uintdig100` and 4 AWAY / 10
  MOVED-WRONG on `p4_fence100` with their flags on. `adjustSize` masks a
  `vpiUIntConst` twice, once at the declaration and once at the READ, and the
  reading target's width reaches the exporter only in `ModuleEmit`'s
  `dt->getType()` — beside the `implicitConvTargetSigned` hand-off it already
  makes and the `VpiSize()==64 -> net width` resize it already performs. An
  implicit-`ConversionExpression` hook was BUILT and MEASURED and reads the
  SOURCE width (64 for a `longint` at a 32-bit and at an 8-bit net alike), so
  it is not the answer. Closing this wants the net's width carried to the
  pkg-param fold site — one hand-off in `ModuleEmit`, which is why it is not
  in this patch.
* **R2 — THE SIZE FACE.** Golden's size on the net-decl-assign road is the
  READING net's width where ours is the parameter's (`w8CPW` golden sz8 vs ours
  sz32). r11u91's R4 / r11u94's R3 / r11v94's RV94-4 / r11u96's R5 / r11u97's
  R6 verbatim, FENCED, and why the scorers are per-field. **It is the same
  missing hand-off as R1** — the value face and the size face of one law.
* **R3 — THE LOGICAL AND TERNARY ARMS READ THE DIGITS TOO.**
  `longint CLAND = 4294967296 && 1` is golden `UINT:1` where both binaries
  write `UINT:0`, and `longint CTERN = 1 ? 4294967296 : 0` is golden
  `UINT:4294967296` where both write `UINT:0` (`p2_uintdig100`). `vpiLogAndOp`
  (`:3369`), `vpiLogOrOp` (`:3387`) and the conditional arm read `get_value`
  off the written digits like the five this pass decoded, but at
  `VpiSize(64)` through a different body. They join R1's list when the width
  arrives.
* **R4 — A CONST FUNCTION CALL FOLDS `UINT:` AND WE WRITE `INT:`.**
  `int FBARE = fs(4)` is golden `UINT:5` and `int FADDS = fs(4) + 1` golden
  `UINT:6`, where both binaries write `INT:5` / `INT:6` — the landed
  `callSigned9` gate firing on slang's signed return. Measured on
  `p4_fence100`, PRE-EXISTING on both binaries, untouched here, and the reason
  the OFF laws decline a non-system call.
* **R5 — THE ELABORATED `param_assign` VIEW DOES NOT SEE THIS SITE.**
  `work@p4sub.P_BADD` is golden `UINT:4294967297` in the DEFINITION view and in
  the elaborated instance alike; with the OFF flags on, the definition view
  moves and `work@p4_fence100.u0.P_BADD` does not — a second emission road for
  the elaborated instance. r11u97's R5 one law over.
* **R6 — RV97-3 STANDS.** `r10vearl71repro/v3_enc71.sv` and
  `r10earl60repro/vfe_v60.sv` have goldens that do not compile (`slrc=4
  slerr=2`). `v3_enc71` is one of this pass's nine boundary DIFFERS and is
  reported as teaching error recovery, not golden. They should be re-cut or
  dropped from the scored set.
* **R7 — RV94-5, THE DYNAMIC ARRAY'S RANGE BOUND.** Our emitter prints an
  uninitialized pointer-valued `UINT:` constant as the right range of a dynamic
  array typespec (`uvm_pkg` 642:23). Latent on every binary, invisible to the
  judge, and the whole of this pass's Surelog byteverify flag list. r11u96's R7
  and r11u97's R7 unchanged; it deserves closing so that a byteverify stops
  flagging databases no law touched.

**R0 — the next pass.** R1 is the widest, the best-measured and the only one
that is BLOCKED rather than unwritten: carry the reading net's width to the
package-parameter fold site — `ModuleEmit`'s `dt->getType()`, beside the
`implicitConvTargetSigned` hand-off it already makes — and then flip
`add100`, `and100`, `or100`, `shl100`, `shr100`, `bare100` and `bname100`. The
laws, their helpers, their grid, their census classes and their measured cells
are all committed here; what is missing is one width. R3's three arms and R2's
size face come with it.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp 65981255 && git worktree add /tmp/wtl 65981255
(cd /tmp/wtl && git apply -3 /tmp/r11u100.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done            # 64699fe6f1399357…  and  534e12a3f3fa8831…
# ---- the grid ---------------------------------------------------------------
G=/tmp/g100 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u86repro/run66.sh $R/r11u100repro/{nda97.py,loc97v.py,cells100.py} $G/
cp $R/r11u100repro/grid/*.sv $G/grid/
cp $R/r11u97repro/grid/z*.sv $R/r11v97repro/grid/k*.sv $G/grid/
cp $R/r11v96repro/grid/{v1_amulbrk96v,v2_bdecbrk96v,v5_unbased96v}.sv $G/grid/
cp $R/r11u96repro/grid/{y1_muldiv96,y2_unsized96,y4_bail96}.sv $G/grid/
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/\.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm   # SAME-LENGTH
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wtl/build/slang-uhdm   # TAGS
done                                   # every arm must read slrc=0 ourrc=0 slerr=0
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/\.sv$//'); do
  python3 $G/loc97v.py $G/grid/$a.g.dump $G/grid/$a.pris.dump $G/grid/$a.lawx.dump
  python3 $G/nda97.py  $G/grid/$a.g.dump $G/grid/$a.pris.dump $G/grid/$a.lawx.dump
done                                   # TO=76 total  AWAY=0  MOVED-WRONG=0
# the positive control — every TO must become an AWAY:
#   the same calls with the last two arguments REVERSED -> TO=0 AWAY=76 MWRONG=76
# the OFF faces' own grid: flip add100/and100/or100/shl100/shr100/bare100/bname100
#   to true, rebuild, and re-score -> p2 AWAY=2, p4 AWAY=4 MWRONG=10, every cell a
#   read NARROWER than the parameter.  THAT IS THE MEASUREMENT, not a claim.
# ---- the census and the a-priori prediction ---------------------------------
python3 $R/r11u100repro/census100.py --selftest          # SELFTEST PASS
python3 $R/r11u100repro/census100.py                     # the roots are built in
python3 $R/r11u100repro/predict100.py <u2r workdir>      # 0 rows
python3 $R/r11u100repro/predict100.py <surelog workdir>  # 3 rows, all no-database
#   the byteverify's mover list must be a SUBSET of those two
# ---- the corpora, per binary, workdir names the SAME LENGTH -----------------
#   verify_golden.py --corpus uhdm2rtlil --mode {testflags,default} --jobs 3
#   verify_golden.py --corpus surelog    --mode both               --jobs 3
#   join87.py results/golden_uhdm2rtlil.csv <tf.csv> <def.csv>      # DIFF=0
#   ct8rows.sh results/golden_surelog.csv <sl.csv>
#   SELFCHECK=1 r11u91repro/byteverify.sh <lawx wd> <pris wd>
#   RUN THE SWEEPS ONE PAIR AT A TIME.
# ---- the surelog byteverify's coin control, no pad binary needed ------------
#   run ONE binary FOUR times on MiniAmiq/default's own cmds.txt invocation
#   -> four different databases; order-blind diff = one |UINT:/|vpiDecompile: pair
# ---- the drop: one flag ------------------------------------------------------
#   constexpr bool powTop100 = false  -> 0a54e8843f9b4eeb…, TO=0 on every arm and
#   dumps byte-identical (path-normalised) to PRISTINE's on all 14 arms
# ---- the wide boundary and its null control ---------------------------------
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wtl/tools/probe BND_OUT=/tmp/bnd100 \
#     xargs -P 3 -n 1 bash r11u91repro/bnd72.sh < armlist
#   NULL:  BND_LAW = BND_PRIS, over the DIFFERS list      -> 9 SAME / 0 DIFFERS
#   score each DIFFERS arm PER VIEW with r11u100repro/loc97v.py against a fresh
#   Surelog v1.87 golden, AND read the path-normalised order-blind diff.
```

Evidence: `evidence/{GRID100.score, SWAPCTL100.score, CELLS100.txt,
CENSUS100.txt, SELFTEST100.txt, PREDICT100.u2r.txt, PREDICT100.sl.txt,
ARMS100.txt, GATES100.txt, MOVERS100.txt, BOUNDARY100.arms,
BOUNDARY100.classes, DROP100.txt, BINARIES100.txt}`.
