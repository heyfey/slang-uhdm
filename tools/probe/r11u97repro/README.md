# r11u97 — `'1` is the digit one, the mint climbs the add, and a comparison answers minus one

**THREE FOLD-ENCODING SIBLINGS IN ONE BATCH, EACH DROPPABLE ALONE, ALL THREE
OF THEM r11v96's OWN RESIDUES — plus the ONE regression LAW A's own grid found
and the ONE AWAY the wide boundary found, both closed in the same patch.**

**LAW A (RV96-1).** Surelog compiles `'1` to a constant carrying `BIN:1`,
`VpiSize(-1)` and the decompile `'1`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:610-618`,
`paNumber_Tick1`), and `'0` to the same three lines with `BIN:0`, so
`get_value` — which parses the VpiValue STRING — reads the digit 1 or 0
whatever the context width. slang, obeying the LRM, types the literal at the
context's width and FILLS it, so our reduce reads 4294967295 in an `int`
context. `int UMIN = '1 - 0` is golden `INT:1` where we wrote
`INT:4294967295`, `-'1` golden `INT:-1` where we wrote `INT:-4294967295`, and
the landed mult law widened the misreading: `'1 * 2` golden `INT:2`, ours
`INT:8589934590`. Never-right cells: no AWAY was possible.

**LAW B (RV96-2).** `reduceExpr`'s `vpiAddOp`/`vpiPlusOp` arm
(`~/git-repos/UHDM/templates/ExprEval.cpp:3260-3329`) is the ONLY arm in the
producer's whole table that reads its REDUCED OPERANDS' const types: it mints
`UINT:` off `get_uvalue` only when NEITHER operand reduced to a `vpiIntConst`,
`vpiStringConst`, `vpiRealConst` or `vpiDecConst`. So the mint climbs:
`int MMIX = 2 * 3 + 1` is golden `INT:7` while `int CADD = 1 + 2` is golden
`UINT:3`. The landed gate read the TOP operator only.

**LAW C (RV96-3).** `reduceCompOp` (`:3173-3182` -> `:1639-1746`) reads both
operands with `get_uvalue` INTO AN `int64_t` and compares them SIGNED, then
mints `BIN:<0|1>` at `VpiSize(1)`; `CompileHelper::adjustSize`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:4147-4190`)
re-renders that one bit at the declaration's width, and its `int_typespec`
branch — reached only for a SIGNED `int_typespec` with the bit set — takes the
two's complement and writes `INT:` + a negated value, which for one bit is
-1. `int CCMP = (3 < 4)` is golden `INT:-1 ct7` where both binaries wrote
`UINT:1 ct9`; every other declared type is golden `BIN:<0|1>` at its own width.

**§ chainStoreChecksTheInitializer97 — THE REGRESSION LAW A ALONE CAUSES.**
`red72Int64`'s NAME guard asks "is this store the initializer's value, or an
override?" by comparing the store against OUR OWN REDUCE — sound only while
the two readings agree, which is exactly what the digit arms break. With LAW A
in, `int U1MUL = '1 * 2` reduces to 2 while slang's store holds 0xFFFFFFFE,
the guard declines, and the chain `int U1CHN = U1MUL * 2` falls back to the
STORE: `INT:-4` where PRISTINE wrote `INT:17179869180` and golden writes
`INT:4`. LAW A's own grid arm found it (`z1_unbased97` `wU1CHN`), the cure asks
the guard's question a second way, and it is the only face in §6 whose removal
produces MOVED-WRONG cells at all. **It closes r11v96's RV96-4 with it.**

**THE `param_assign` FENCE — THE ONE AWAY THE WIDE BOUNDARY FOUND.** LAW C's
first cut wrote its encoding into the module DEFINITION's `param_assign`,
where golden decompiles a one-bit `BIN:` as the BARE digit `1` (each
ELABORATED instance writes `<width>'b1`) and **the pristine binary is already
golden**. Three cells of `r11v38repro/arms/v2_paenc.sv` and
`r11u38repro/grid/g2_paenc38.sv` went pristine-right -> patched-wrong. Arm
`z6_pahome97` exists to hold that shape; the fence is one predicate at the
call site and it costs nothing — all 120 `z3_cmpfam97` cells and all 12
`z6_pahome97` ones still move.

Base `fdaccc06`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden here is a real Surelog v1.87 run
through the committed `r11u86repro/run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`: **all 11 grid arms read `0 0 0` on both binaries, all 22
arm-runs** (`evidence/ARMS97.txt`).

| binary | md5 | what |
|---|---|---|
| pristine | `54d56dd004635a3c0a59112c3f88e571` | built in this pass's own worktree — byte-identical to the main tree at `fdaccc06` and to the ops-brief md5 |
| **law** | `457297442d61fd7c085ec369c46e3ad2` | this patch |
| LAW A reverted | `aef9f864008880f6d5e5b1edf7e6ffbd` | |
| LAW B reverted | `d94bf2e2a32e306157b3c4d9542236f3` | |
| LAW C reverted | `522a036444c7134de3d774b0fbd2c591` | |
| power child reverted | `4f46d42e4bbd76b947e9dccc023463a6` | LAW B's `pow97` flag alone |
| chain widening reverted | `f0bace529e70e6bacef573703365a08c` | **the only binary with MOVED-WRONG != 0** |

---

## 1. THE PRODUCER, LINE BY LINE

### 1.1 LAW A — the literal never gets wide

```cpp
case VObjectType::paNumber_Tick1: {        // CompileExpression.cpp:610
  UHDM::constant *c = s.MakeConstant();
  c->VpiValue("BIN:1");  c->VpiConstType(vpiBinaryConst);
  c->VpiSize(-1);        c->VpiDecompile("'1");
```

and `get_value` (`~/git-repos/UHDM/templates/ExprEval.cpp:1946`) parses that
string. `'x` and `'z` are a DIFFERENT object type —
`exitUnbased_unsized_literal` (`SV3_1aTreeShapeListener.cpp:874`) maps them to
`paX` / `paZ` — and Surelog v1.87 leaves `'x - 0`, `'z - 0` and `'x * 2`
UNFOLDED, writing a `ref_obj` and NO CONSTANT (arm `z4_xz97`). The BARE
literal is not on the reduce road either: `int U1BARE = '1` is golden
`UINT:4294967295` (`adjustSize`'s own `(orig_size == -1) && (val == 1)` branch
at `CompileHelper.cpp:4196` fills the mask) and `int U0BARE = '0` is golden
`BIN:0`. That is why the arm is confined to `inArm`, as r11u76's based-leaf and
r11u96's unsized-decimal arms are.

The `VpiSize(-1)` also explains a DECLINE that costs nothing: the shift arm
(`ExprEval.cpp:3236`) tests `if (c->VpiSize() == -1) invalidValue = true`, so
`int U1SHL = '1 << 1` has NO GOLDEN AT ALL — measured, golden writes a
`ref_obj` (`z1_unbased97`).

### 1.2 LAW B — `unsignedOperation`, the one arm that asks

```cpp
bool unsignedOperation = true;                       // :3267
for (auto exp : {expr0, expr1})
  if (exp && exp->UhdmType() == uhdmconstant) {
    constant *c = (constant *)exp;
    if (c->VpiConstType() == vpiIntConst || … vpiStringConst ||
        … vpiRealConst || … vpiDecConst) unsignedOperation = false; }
```

`grep -n unsignedOperation` over that file returns exactly those three lines:
no other operator reads an operand's const type. The `INT:`-minting children
are therefore `-` (binary and unary), `*`, `/`, `%`, `**`, an `+` that itself
minted `INT:`, a NAME whose own initializer did, and a based DECIMAL leaf
(`vpiDecConst`). The base letter is the axis, measured: `8'd10`, `8'sd10` and
`40'd10` all mint `INT:` on the parent while `8'h10`, `4'b1010` and `8'o12`
leave it `UINT:`.

### 1.3 LAW C — one bit, and `adjustSize`'s two's complement

`reduceCompOp` assigns `get_uvalue`'s `uint64_t` into `int64_t v0` / `v1`
(`:1669-1670`) and compares SIGNED. That is not incidental and it is measured:
`int DU64 = (64'hFFFF_FFFF_FFFF_FFFF > 1)` is golden FALSE and
`DU64E = (… < 1)` golden TRUE, where slang — reading the same literal as
2^64-1 — answers the other way round on both. The comparison is therefore
computed on this file's own `int64_t` road and never taken from slang's store,
and `int EU1 = ('1 < 2)` is golden `INT:-1` only because LAW A reads `'1` as
the digit 1 on that same road.

---

## 2. THE FIVE § BLOCKS

### § unbasedUnsizedIsOneDigit97 — `src/EmitHelpers.h`

```
red97UnbasedDigit97(e, out)   an UnbasedUnsizedIntegerLiteral whose
        getLiteralValue() is a KNOWN bit: 1 -> 1, 0 -> 0, x/z -> refuse.
red72Int64: one `if (inArm)` block after the landed unsized-decimal one.
```

### § addMintFollowsOperandMint97 — `src/EmitHelpers.h` + `src/ExprEmit.cpp`

```
red97OperandMintsInt97(e, pow97)   does the producer's reduce of `e` yield a
        vpiIntConst / vpiDecConst?  unary `-`; binary `-`, `*`, `/`, `%`;
        `**` behind its own flag; an `+` recursively; a based leaf whose base
        letter is `d`; a NAME through its parameter's initializer.
red97IntMintTop97(...)  the landed red96IntMintTop96 OR an `+` at the TOP
        whose left or right operand mints.
the call site: red96IntMintTop96(*mi94, mul96, div96, mod96)
            -> red97IntMintTop97(*mi94, mul96, div96, mod96, add97, pow97)
```

### § intCompareIsMinusOne97 — `src/EmitHelpers.h` + `src/ExprEmit.cpp`

```
red97CompTop97(e)                  the TOP operator is one of the six.
red97CompValue97(e, actx, out)     both operands through red72Int64 WITH
        `inArm` set, compared SIGNED over int64 — reduceCompOp's own six lines.
the call site, AFTER every other encoder and gated on the reading home:
        a signed `int` declaration and a TRUE comparison -> INT:-1 / ct7 / -1
        anything else                                    -> BIN:<v> / ct3 /
                                                            <VpiSize>'b<v>
```

`&&`, `||` and `!` are NOT on this road — `vpiLogAndOp` (`:3387`),
`vpiLogOrOp` (`:3369`) and `vpiNotOp` mint `UINT:` at `VpiSize(64)` — and
`===` / `!==` are not reduced at all. Every one of their cells is EQUAL on
both binaries (`z3_cmpfam97`: `CAND`, `CANDF`, `COR`, `CNOT`, `CNOTT`;
`CCEQ` / `CCNE` golden-UNFOLDED). **The comparison arm is deliberately NOT in
`red72Int64`**: that function is read by ParamEmit, ModuleEmit and ExprEmit for
widths, ranges and selects, and an arm there would move cells no
declaration-keyed census could name in advance. It stays one call site wide,
which is what makes the census class `CMP97` a superset of the gate.

### § chainStoreChecksTheInitializer97 — `src/EmitHelpers.h`

```
red72Int64's NAME guard: accept when the store matches OUR REDUCE at the
        name's width (as before) OR when it matches SLANG'S OWN EVALUATION
        of the initializer at that width.  A pure WIDENING: every name the
        guard accepted before, it still accepts; an overridden parameter and
        a defaulted port fail both tests and still decline.
```

### the `param_assign` fence — `src/ExprEmit.cpp`

```
paHome97 = parent && parent->UhdmType() == uhdmparam_assign  ->  LAW C declines
```

**`ParamEmit.cpp` and `ModuleEmit.cpp` are ABSENT from this patch.** The
production surface is `src/EmitHelpers.h` and `src/ExprEmit.cpp` and nothing
else.

---

## 3. THE GOLDEN GRID — 11 arms, scored PER FIELD, PER VIEW

Six new arms (`z1_unbased97`, `z2_addmint97`, `z3_cmpfam97`, `z4_xz97`,
`z5_chain97`, `z6_pahome97`) and five CONTROL arms from the r11v96 and r11u96
generations (`v1_amulbrk96v`, `v5_unbased96v`, `y1_muldiv96`, `y2_unsized96`,
`y4_bail96`) re-run unchanged.

**TWO SCORERS, AND THE SECOND ONE IS THE ARBITER.** `nda97.py` reads the
net-decl-assign road per CELL; `loc97v.py` reads the WHOLE DUMP per cell,
per FIELD, **and per VIEW**. Both are new, and both are new because the
inherited readers are blind in ways this pass's cells fall into:

* `nda94.py` reads a fixed 40-line window after each `vpiNetDeclAssign:1` and
  takes the first constant it finds there. Where golden DECLINES TO FOLD — and
  it declines on `'1 << 1`, `(12 ^ 10) + 1`, `(+5) + 1`, `'x - 0`, `'z - 0`,
  `'x * 2`, `3 === 3` and `3 !== 3`, every one of them measured — that window
  runs on into the next cell and the scorer attributes the NEIGHBOUR's
  constant to the absent one. `nda97.py` walks the `cont_assign` blocks
  themselves, keys on the `vpiLhs` net NAME, records the RHS's OBJECT KIND, and
  scores a golden-NOFOLD cell on NO FIELD AT ALL.
* `loc96v.py` keys a constant on its SOURCE LOCATION alone. A parameter
  written once is emitted three times — once in `uhdmallModules` and once per
  `uhdmtopModules` instance — all three at the SAME location, and our
  `param_assign` constants carry a different END COLUMN from golden's
  (`20:38..20:47` against `20:38..20:43`), so a location-keyed multiset read
  **AWAY=0 over nine real AWAY cells it had never compared**. `loc97v.py` keys
  on (section, enclosing instance, line, start-col) and splits the value into
  its PREFIX and its DIGITS, because these laws write the prefix while the
  digits sit on a fenced residue.

### 3.1 LAW A, per cell (`z1_unbased97`, `z4_xz97`, and `v5_unbased96v`)

| package declaration | golden | pristine | law |
|---|---|---|---|
| `int U1MIN  = '1 - 0` | **`INT:1`** | `INT:4294967295` | `INT:1` |
| `int U1SUB  = '1 - 1` | **`INT:0`** | `INT:4294967294` | `INT:0` |
| `int U1NEG  = -'1` | **`INT:-1`** | `INT:-4294967295` | `INT:-1` |
| `int U1MUL  = '1 * 2` | **`INT:2`** | `INT:8589934590` | `INT:2` |
| `int U1MULR = 2 * '1` | **`INT:2`** | `INT:8589934590` | `INT:2` |
| `int U1DIV  = '1 / 1` | **`INT:1`** | `INT:4294967295` | `INT:1` |
| `int U1DIVR = 6 / '1` | **`INT:6`** | `INT:0` | `INT:6` |
| `int U1MOD  = '1 % 7` | **`INT:1`** | `INT:3` | `INT:1` |
| `int U1SUBR = 5 - '1` | **`INT:4`** | `INT:-4294967290` | `INT:4` |
| `int U1DEEP = ('1*2)*3` | **`INT:6`** | `INT:25769803770` | `INT:6` |
| `int U1PAR  = (('1)) - 0` | **`INT:1`** | `INT:4294967295` | `INT:1` |
| `int U1CHN  = U1MUL * 2` | **`INT:4`** | `INT:17179869180` | `INT:4` |
| `longint U1L = '1 - 0` | **`INT:1`** | `INT:-1` | `INT:1` |
| `logic [7:0] U1U8 = '1 - 0` | **`INT:1`** | `INT:4294967295` | `INT:1` |
| `logic signed [3:0] U1S4` | **`INT:1`** | `INT:4294967295` | `INT:1` |
| the same `U1MIN` read `[31:0]` | **`INT:1`** | `INT:4294967295` | `INT:1` |
| the same `U1MIN` read `[63:0]` | **`INT:1`** | `INT:4294967295` | `INT:1` |
| **AND THE `'0` FACE AND THE LIVE CONTROLS** | | | |
| `int U0SUB = '0 - 0` | `INT:0` | `INT:0` | unchanged |
| `int U0MUL = '0 * 5` | `INT:0` | `INT:0` | unchanged |
| `int U0NEG = -'0` | `INT:0` | `INT:0` | unchanged |
| `int U0SUBR = 5 - '0` | `INT:5` | `INT:5` | unchanged |
| `int CB1S = 1'b1 - 0` | `INT:1` | `INT:1` | unchanged — a BASED leaf |
| `int CB1M = 1'b1 * 2` | `INT:2` | `INT:2` | unchanged |
| `int CSUB / CMUL / CDIV / CMOD` | `INT:7/6/3/3` | same | unchanged (landed) |
| `int CADD = 1 + 2` | `UINT:3` | `UINT:3` | unchanged |
| `longint CDEC = 4294967296 - 0` | `INT:4294967296` | same | unchanged (landed) |
| **AND WHAT GOLDEN DOES NOT WRITE** | | | |
| `int U1SHL = '1 << 1` | **UNFOLDED** | `INT:-2` | unchanged |
| `int U1AND = '1 & 3` | `UINT:1` | `UINT:3` | **STILL — R2** |
| `int U1ADD = '1 + 0` | `UINT:1` | `INT:-1` | **STILL — R2** |
| `int U1BARE = '1` | `UINT:4294967295` | `INT:-1` | **STILL — R3** |
| `int U0BARE = '0` | `BIN:0` | `UINT:0` | **STILL — R3** |
| `int UXS = 'x - 0`, `UZS`, `UXM` | **UNFOLDED** | `UINT:0` | unchanged |

### 3.2 LAW B, per cell (`z2_addmint97`, and `v1`'s `MMIX`/`MMIX2`)

| package declaration | golden | pristine | law |
|---|---|---|---|
| `int MMIX   = 2 * 3 + 1` | **`INT:7 ct7`** | `UINT:7 ct9` | `INT:7 ct7` |
| `int MMIX2  = 1 + 2 * 3` | **`INT:7 ct7`** | `UINT:7 ct9` | `INT:7 ct7` |
| `int ASUBL  = (8 - 1) + 1` | **`INT:8 ct7`** | `UINT:8 ct9` | `INT:8 ct7` |
| `int ASUBR  = 1 + (8 - 1)` | **`INT:8 ct7`** | `UINT:8 ct9` | `INT:8 ct7` |
| `int ADIVL  = (6 / 2) + 1` | **`INT:4 ct7`** | `UINT:4 ct9` | `INT:4 ct7` |
| `int AMODL  = (7 % 4) + 1` | **`INT:4 ct7`** | `UINT:4 ct9` | `INT:4 ct7` |
| `int APOWL  = (2 ** 3) + 1` | **`INT:9 ct7`** | `UINT:9 ct9` | `INT:9 ct7` |
| `int ADEEP2 = ((2*3)+1)+1` | **`INT:8 ct7`** | `UINT:8 ct9` | `INT:8 ct7` |
| `int ADEEP3 = (((2*3)+1)+1)+1` | **`INT:9 ct7`** | `UINT:9 ct9` | `INT:9 ct7` |
| `int ANEST  = (1 + (2*3)) + 1` | **`INT:8 ct7`** | `UINT:8 ct9` | `INT:8 ct7` |
| `int APARL  = ((2 * 3)) + 1` | **`INT:7 ct7`** | `UINT:7 ct9` | `INT:7 ct7` |
| `int ATWO   = (2*3) + (4-1)` | **`INT:9 ct7`** | `UINT:9 ct9` | `INT:9 ct7` |
| `int AZERO  = (0 - 0) + 1` | **`INT:1 ct7`** | `UINT:1 ct9` | `INT:1 ct7` |
| `int ANAMEL = XMUL + 1` | **`INT:7 ct7`** | `UINT:7 ct9` | `INT:7 ct7` |
| `int ANAMER = 1 + XMUL` | **`INT:7 ct7`** | `UINT:7 ct9` | `INT:7 ct7` |
| `int ANAMES = XSUB + 1` | **`INT:8 ct7`** | `UINT:8 ct9` | `INT:8 ct7` |
| `int ANAMEP = XPOW + 1` | **`INT:9 ct7`** | `UINT:9 ct9` | `INT:9 ct7` |
| `int ADECL  = 8'd10 + 1` | **`INT:11 ct7`** | `UINT:11 ct9` | `INT:11 ct7` |
| `int ADECS  = 8'sd10 + 1` | **`INT:11 ct7`** | `UINT:11 ct9` | `INT:11 ct7` |
| `int ADECW  = 40'd10 + 1` | **`INT:11 ct7`** | `UINT:11 ct9` | `INT:11 ct7` |
| **AND THE LIVE NEGATIVE CONTROL — every one EQUAL, before and after** | | | |
| `int CADD = 1 + 2` | `UINT:3` | `UINT:3` | unchanged |
| `int CLITA = 4 + 1` | `UINT:5` | `UINT:5` | unchanged |
| `int CADD3 = (1 + 2) + 3` | `UINT:6` | `UINT:6` | unchanged |
| `int ANAME2 = XADD + 1` | `UINT:4` | `UINT:4` | unchanged |
| `int CSHLA = (1 << 3) + 1` | `UINT:9` | `UINT:9` | unchanged |
| `int CSHRA = (32 >> 2) + 1` | `UINT:9` | `UINT:9` | unchanged |
| `int CANDA = (12 & 10) + 1` | `UINT:9` | `UINT:9` | unchanged |
| `int CORA  = (12 \| 3) + 1` | `UINT:16` | `UINT:16` | unchanged |
| `int CLGA  = (1 && 1) + 1` | `UINT:2` | `UINT:2` | unchanged |
| `int CADDC = (3 < 4) + 1` | `UINT:2` | `UINT:2` | unchanged |
| `int CHEXA = 8'h10 + 1` | `UINT:17` | `UINT:17` | unchanged |
| `int ADECB = 4'b1010 + 1` | `UINT:11` | `UINT:11` | unchanged |
| `int ADECO = 8'o12 + 1` | `UINT:11` | `UINT:11` | unchanged |
| `int CSYSA = $clog2(16) + 1` | `UINT:5` | `UINT:5` | unchanged |
| `int CCNDA = (1 ? 2 : 3) + 1` | `UINT:3` | `UINT:3` | unchanged |
| `int AENUM = EA + 1` | `UINT:4` | `UINT:4` | unchanged |
| `int APLUSU = (+5) + 1` | **UNFOLDED** | `UINT:6` | unchanged |
| `int CXORA = (12 ^ 10) + 1` | **UNFOLDED** | `UINT:7` | unchanged |
| `int XPOW = 2 ** 3` | `INT:8` | `UINT:8` | **STILL — R1, fenced** |

**A ZERO-VALUED CHILD STILL MINTS.** `AZERO = (0 - 0) + 1` is golden `INT:1`,
so the axis is the child's WRITTEN OPERATOR and not the sign or the size of
any value — the same proof r11u96's `MZERO` gave for its own law.

### 3.3 LAW C, per cell (`z3_cmpfam97`, `z6_pahome97`, `v1`'s `CCMP`)

| package declaration | golden | pristine | law |
|---|---|---|---|
| `int CLT = (3 < 4)` | **`INT:-1 ct7 d -1`** | `UINT:1 ct9 d 1` | golden |
| `int CGT = (4 > 3)` | **`INT:-1`** | `UINT:1` | golden |
| `int CLE = (3 <= 3)` | **`INT:-1`** | `UINT:1` | golden |
| `int CGE = (3 >= 3)` | **`INT:-1`** | `UINT:1` | golden |
| `int CEQ = (3 == 3)` | **`INT:-1`** | `UINT:1` | golden |
| `int CNE = (3 != 4)` | **`INT:-1`** | `UINT:1` | golden |
| `int CLTN = (-1 < 0)` | **`INT:-1`** | `UINT:1` | golden |
| `int CLTC = (CLT < 2)` | **`INT:-1`** | `UINT:1` | golden |
| `int CLTX = (2 * 3 < 7)` | **`INT:-1`** | `UINT:1` | golden |
| `int EU1  = ('1 < 2)` | **`INT:-1`** | `UINT:0` | golden — LAW A inside LAW C |
| `td_int_t DTD = (3 < 4)` | **`INT:-1`** | `UINT:1` | golden — a TYPEDEF of int |
| `int CLTF = (4 < 3)` | **`BIN:0 ct3 d 32'b0`** | `UINT:0 ct9 d 0` | golden |
| `int CGTF / CLEF / CGEF / CEQF / CNEF` | **`BIN:0`** | `UINT:0` | golden |
| `longint QLT64` | **`BIN:1 sz64 d 64'b1`** | `UINT:1 ct9 d 1` | golden |
| `logic [7:0] QLTU8` | **`BIN:1 sz8 d 8'b1`** | `UINT:1` | golden |
| `logic signed [7:0] QLTS8` | **`BIN:1 sz8`** | `UINT:1` | golden |
| `byte QLTBY` | **`BIN:1 sz8`** | `UINT:1` | golden |
| `bit QLTB1` / `logic QLTL1` | **`BIN:1 sz1 d 1'b1`** | `UINT:1` | golden |
| `integer DINTG` | **`BIN:1 d 32'b1`** | `UINT:1` | golden |
| `int unsigned DIU` | **`BIN:1`** | `UINT:1` | golden |
| `logic signed [31:0] DLS32` | **`BIN:1`** | `UINT:1` | golden |
| `bit signed [31:0] DBS32` | **`BIN:1`** | `UINT:1` | golden |
| `logic [31:0] DL32` / `bit [31:0] DB32` | **`BIN:1`** | `UINT:1` | golden |
| `(implicit) DIMP` | **`BIN:1 sz1 d 1'b1`** | `UINT:1 sz1` | golden |
| `int DU64 = (64'hFF..FF > 1)` | **`BIN:0`** | `UINT:1` | golden — SIGNED |
| `int DU64E = (64'hFF..FF < 1)` | **`INT:-1`** | `UINT:0` | golden — SIGNED |
| `int EMUL = (3 < 4) * 2` | **`INT:2 ct7`** | `UINT:2 ct9` | golden |
| `int ESUB = (3 < 4) - 1` | **`INT:0 ct7`** | `UINT:0 ct9` | golden |
| **AND THE LIVE CONTROLS — none on `reduceCompOp`'s road** | | | |
| `int CAND = (1 && 1)` / `CANDF` | `UINT:1` / `UINT:0` | same | unchanged |
| `int COR = (0 \|\| 1)` | `UINT:1` | same | unchanged |
| `int CNOT = (!0)` / `CNOTT = (!3)` | `UINT:1` / `UINT:0` | same | unchanged |
| `int CTERN = (3<4) ? 5 : 6` | `UINT:5` | same | unchanged |
| `int CADDC = (3<4) + 1` | `UINT:2` | same | unchanged |
| `int ENEG = -(3 < 4)` | `INT:-1` | `INT:-1` | unchanged |
| `int CCEQ = (3 === 3)` / `CCNE` | **UNFOLDED** | `UINT:1` / `UINT:0` | unchanged |
| `int CCHN = CLT` (a CHAIN) | `BIN:1 d 32'b1` | `UINT:1` | **STILL — R4** |
| **AND THE `param_assign` READING HOME — THE FENCE** | | | |
| `parameter int P_CINT = z6p::CINT` (DEF view) | `BIN:1 d 1` | `BIN:1 d 1` | unchanged |
| the same, each ELABORATED instance | `BIN:1 d 32'b1` | `BIN:1 d 1` | **STILL** |
| `localparam int L_CINT` (DEF view) | `BIN:1 d 1` | `BIN:1 d 1` | unchanged |

### 3.4 § chainStoreChecksTheInitializer97, per cell (`z5_chain97`)

| package declaration | golden | pristine | law |
|---|---|---|---|
| `int U1CHN = U1MUL * 2` over `U1MUL = '1 * 2` | **`INT:4`** | `INT:17179869180` | `INT:4` |
| `int U1CH2 = U1CHN - 1` (two hops) | **`INT:3`** | `INT:17179869179` | `INT:3` |
| `int U1CHS = U1MUL - 1` | **`INT:1`** | `INT:8589934589` | `INT:1` |
| `longint CHAIN = SEP - 0` (RV96-4) | **`INT:4294967296`** | `INT:0` | golden |
| `longint CHMUL = SEP * 2` | **`INT:8589934592`** | `INT:0` | golden |
| **AND THE LIVE CONTROLS** | | | |
| `int PLAIN = 2 * 3` / `PCHN = PLAIN * 2` | `INT:6` / `INT:12` | same | unchanged |
| `int ADDC = 1 + 2` / `ACHN = ADDC + 1` | `UINT:3` / `UINT:4` | same | unchanged |
| `int WB = 4'd12 - 0` / `WBCHN = WB - 0` | `INT:12` / `INT:12` | same | unchanged |
| an OVERRIDDEN port parameter `#(.SP(U1MUL))` | — | — | still declines |
| the DEFAULT port parameter `SP = 7` | — | — | still declines |

### 3.5 THE SCORE, AND ITS POSITIVE CONTROL

| arm | TO | AWAY | MOVED-WRONG |
|---|---|---|---|
| `z1_unbased97` | **34** | **0** | **0** |
| `z2_addmint97` | **40** | **0** | **0** |
| `z3_cmpfam97` | **120** | **0** | **0** |
| `z4_xz97` | **2** | **0** | **0** |
| `z5_chain97` | **12** | **0** | **0** |
| `z6_pahome97` | **13** | **0** | **0** |
| `v1_amulbrk96v` | **10** | **0** | **0** |
| `v5_unbased96v` | **12** | **0** | **0** |
| `y1_muldiv96` / `y2_unsized96` / `y4_bail96` (landed) | **0** | **0** | **0** |
| **the same eight, tags swapped** | **0** | **243** | **243** |

(View-keyed, five fields, `loc97v.py`.) `AWAY = 0` is a MEASUREMENT: swapping
the two dumps turns every one of the 243 moved fields into an AWAY *and* a
MOVED-WRONG. The net-decl-assign per-cell reading agrees: `nda97.py` reads
`TO=34/40/105/2/12/12/9/12`, `AWAY=0 MWRONG=0 MISSING=0 SHAPE=0` on all
eleven arms, with `NOFOLD` naming the eleven cells golden declines to fold.

---

## 4. CENSUS, A PRIORI, BY NAME

`census97.py` carries one class per law, each a strict superset of the gate
that lands, with a POSITIVE control (this pass's own arms plus four earlier
generations') and a LIVE NEGATIVE control (`'x`, `'z`, `**`, `<<`, `&&`, `||`,
`===`, `!==`, a unary `+`, a cast tick, a based leaf's tick, a bare decimal,
a ternary and an `int'()` cast — every one of which must be UNSIGHTED).

```
ADD97 120   ADDW97 178   AGREE97 12795   BWL97 23   CMP97 19
CMPF97 7922   UDC97 310   UNB97 208   UNBF97 28327   UNBO97 40
--- candidate tests: 57                              SELFTEST PASS
  not sighted (2): p1_pkgin91 q4_negpkg94     [the live negative control]
```

`UNBF97` — every `'0`/`'1` anywhere, 28 327 of them — is reported and NOT
used for the prediction: LAW A's arm is confined to `inArm`, so a literal
written as a bare assignment or a port connection (`q <= '0;`, `.rst('1)`) can
move nothing. `UNBO97` is the OPERAND face, 40 corpus-wide, and it is what the
prediction keys on; the live control proves it sights `'1 - 0` and `2 * '1`
and leaves `q <= '0`, `.a('0)` and `('1)` alone. `UDC97` and `BWL97` are the
other two digit arms, because the widened chain guard can only change a cell
where the store and our reduce disagree and those are the only three ways they
can.

`predict97.py` re-keys the census from the TEST DIRECTORY to the SWEEP ROW,
reading each row's own `cmds.txt` and its whole test tree:

```
predict97.py <u2r workdir>       27 rows   (18 of them ibex_*, incl. ibex_icache)
predict97.py <surelog workdir>   26 rows
```

**The measured mover set is a SUBSET of that**, and the one u2r mover —
`ibex_icache` — is named in it BY NAME with the class that reaches it.

---

## 5. GATES — ALL MANDATORY (`evidence/GATES97.txt`)

**5.1 BUILD.** `-j 2`, `md5sum` separately, every binary `chmod 555` BEFORE
any sweep. Pristine `54d56dd004635a3c0a59112c3f88e571` — **byte-identical to
the main tree at `fdaccc06`, the md5 the ops brief names**. Law
`457297442d61fd7c085ec369c46e3ad2`.

**5.2 GOLDENS.** `23 PASS / 0 FAIL` on pristine AND law; the negative control
`SLANG_UHDM=/bin/false` -> `0 PASS / 23 FAIL`.

**5.3 uhdm2rtlil, BOTH MODES, BOTH BINARIES.** `788 / 16 / 67` in all four
sweeps. Both-mode 1742-row whole-row join against
`results/golden_uhdm2rtlil.csv`: **DIFF=0 on both binaries**. Testflags gate
against `results/gate_uhdm2rtlil.csv`: `PASS: every row byte-identical` on
both. All 3484 `cmds.txt` audited BY ABSOLUTE BINARY PATH — 1742 name the
frozen pristine, 1742 the frozen law, **0 name the main tree**.

**5.4 Surelog `--mode both`, BOTH BINARIES.** `474 / 9` default and `469 / 8`
testflags on BOTH, every histogram cell identical to the committed baseline
(`SLANG_REJECT 285/286`, `SURELOG_FAIL 25/23`, `DEFERRED 5/5`,
`NO_DATABASE 3`, `NO_UHDM 1`, `TIMEOUT 1`, `UNTRANSLATABLE 2`). The whole-row
join against `results/golden_surelog.csv` names, on the LAW binary, exactly
four rows and no fifth:

```
LowMemLib     testflags  SURELOG_FAIL, DETAIL = the sweep's OWN workdir path
LowMemPkg     testflags  SURELOG_FAIL, DETAIL = the sweep's OWN workdir path
Earlgrey_0_1  default    CMP_EQUAL, the DUMP COLUMN blank
Earlgrey_0_1  testflags  CMP_EQUAL, the DUMP COLUMN blank
```

and the PRISTINE sweep names the first two plus `Earlgrey_0_1` **testflags**,
whose dump column read blank on that run instead — the documented `uhdm-dump`
timeout draw, which lands on whichever sweep is unlucky. Earlgrey's DATABASE,
which is the pin, is byte-identical between the two binaries in both modes and
at its ops-brief md5. **No status moved, in either direction, on any row of
either corpus.**

**5.5 byteverify, SELFCHECK=1, both corpora, against this pass's own pristine
workdirs.** `evidence/MOVERS97.txt`.

* **uhdm2rtlil: `MOVERS 2 / 1608`, `PATH_SETS_IDENTICAL`, `SELFCHECK
  1607/1608`.** Both are `ibex_icache`, one per mode, PREDICTED BY NAME. The
  whole path-normalised dump diff is **20 lines per mode — 5 `|UINT:22` ->
  `|INT:22` and 5 `|vpiConstType:9` -> `:7`, and nothing else; `vpiSize` 0,
  `Typespec` 0, `vpiDecompile` 0.** The cell is `ibex_pkg.sv:17`,
  `parameter int unsigned IC_TAG_SIZE = ADDR_W - IC_INDEX_W - IC_LINE_W + 1`
  — a `+` whose LEFT operand is a subtraction, which is **LAW B exactly** —
  and **GOLDEN holds `|INT:22` 19 times against `|UINT:22` 3 times where
  pristine holds 8/13 and the law 13/8**, so the mover is TO GOLDEN. The row
  is `ibex_icache,{default,testflags},CMP_NOTEQUAL,decompile:` in the
  committed baseline and STAYS so.
* **Surelog: `MOVERS 5 / 960`, `PATH_SETS_IDENTICAL`, `SELFCHECK 959/960`.**
  `MiniAmiq`, `SeqDriver` and `SimpleUVM`, and **none of them is this pass's**.
  Attributed ORDER-BLIND on path-normalised SORTED dumps: each moves **exactly
  four lines, one `|UINT:` / `|vpiDecompile:` pair**, and across all five
  **`|INT:` 0, `vpiConstType` 0, `vpiSize` 0, `Typespec` 0, `|BIN:` 0** — none
  of the fields these laws write. **POSITIVE CONTROL, and no pad binary is
  needed: the PRISTINE binary run FOUR TIMES on MiniAmiq/default's own
  `cmds.txt` invocation produced FOUR DIFFERENT DATABASES**
  (`98abb96d…`, `ebd2d3d2…`, `590246cb…`, `c30c2bc6…`), and the order-blind
  diff of two of them is the SAME single `|UINT:` / `|vpiDecompile:` pair with
  `|INT:` 0, `vpiConstType` 0, `vpiSize` 0 and `Typespec` 0. It is r11u96's R7
  / r11v96's RV94-5 — the `uvm_pkg` 642:23 dynamic-array range bound our
  emitter prints from an uninitialized pointer-valued `UINT` — latent on every
  binary. `predict97.py` does not name any of the three, and it is right not
  to.

**5.6 CANARIES AND PINS.** Surelog `ok=50 changed=2` on the LAW binary and
`ok=51 changed=1` on the PRISTINE one. Every "changed" row on both is
`Earlgrey_0_1`'s DUMP COLUMN alone — `CMP_EQUAL/differ -> CMP_EQUAL/`, the
status untouched — and it is the documented `uhdm-dump` timeout draw, which
fell on the law sweep's two modes and on the pristine sweep's testflags. u2r
`ok=8 changed=0 absent=0` on both. `ctcan2` PASS on both corpora.
`canaudit.sh canaries.sh ctcan2.sh` -> `audited=29 UNCOVERED=0
FENCE-BREACH=0`. **Every protected database at its ops-brief pin AND
byte-identical between pristine and law, both modes:**

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

**5.8 EACH FACE DROPPABLE ALONE**, five further binaries built from this
patch's own flags (`evidence/DROP97.txt`):

| binary | `z1` | `z2` | `z3` | `z4` | `z5` | `z6` | `v1` | `v5` | AWAY | MWRONG |
|---|---|---|---|---|---|---|---|---|---|---|
| full law | 34 | 40 | 120 | 2 | 12 | 13 | 10 | 12 | **0** | **0** |
| LAW A reverted | **0** | 40 | 116 | **0** | **4** | 13 | 8 | **0** | 0 | **3** |
| LAW B reverted | 34 | **0** | 120 | 2 | 12 | 13 | **6** | 12 | 0 | 0 |
| LAW C reverted | 34 | 40 | **0** | 2 | 12 | **0** | **6** | 12 | 0 | 0 |
| power child reverted | 34 | **36** | 120 | 2 | 12 | 13 | 10 | 12 | 0 | 0 |
| chain reverted | **32** | 40 | 120 | 2 | **2** | 13 | 10 | 12 | 0 | **8** |

LAW A is worth 60 fields, LAW B 44, LAW C 127, the power child 4 and the chain
widening 10 — **and the chain widening is the only one whose removal produces
MOVED-WRONG cells**, which is what makes it part of this patch rather than a
residue. LAW A's own three MOVED-WRONG cells on the drop binary are `z3`'s
`EU1 = ('1 < 2)`: LAW C reads `'1` through LAW A's arm, so without it the
comparison answers false and writes `BIN:0` where golden writes `INT:-1`. That
is a measured DEPENDENCY between two faces of one patch, recorded here, and it
is why `z3_cmpfam97` carries that cell.

**5.9 THE WIDE BOUNDARY**, every `*.sv` under `tools/probe`, not the grid
glob: **8307 arms — 8059 SAME, 28 DIFFERS, 220 NODB**, and every NODB arm has
`prc == lrc` (216 x `rc=3`, 4 x `rc=139`).  (8306 of them ran in one sweep and
`z6_pahome97`, added to the grid after that list was built, ran on its own:
`prc=0 lrc=0 DIFFERS`.)  **NULL BOUNDARY** (the pristine binary against itself
over all 28) reads **DIFFERS 0 / 28** — not one of them is a run-to-run coin. Every one of the 22 COMMITTED arms among them is scored
per cell, per field, PER VIEW against a FRESH Surelog v1.87 golden:

```
TO=50 across the 22   AWAY=0 on every one   MOVED-WRONG=0 on every one
```

and the three classes are (`evidence/BOUNDARY97.classes`):

* **LAWS A/B/C and the chain, 24 arms** — `|UINT:` <-> `|INT:` <-> `|BIN:`,
  `vpiConstType` 9 <-> 7 <-> 3, `vpiDecompile`. Five are this pass's own grid.
* **THREE PAGE-BOUNDARY FALSE MOVERS** (`g22.sv`, `l154_noenum.sv`,
  `g185_e_kinds.sv`) — `|UINT:` + `|vpiDecompile:` only, **delta exactly
  4096, one page**, with `|INT:` 0, `vpiConstType` 0, `vpiSize` 0 and
  `Typespec` 0. r11u96's R7 again, and the page arithmetic is its own control.
* **`r11v38repro/arms/v2_paenc.sv` LEFT THE LIST.** It differed before the
  `param_assign` fence and does not differ after it — the boundary's own proof
  that the AWAY is closed.

Two committed arms deserve naming because a whole-string value score reads
them as moved-wrong and a per-field one does not: `g7_add66` 32:42 and
`a6_misc66` 22:58 are golden `INT:18` / `INT:26` where pristine wrote
`UINT:17` / `UINT:13` and the law writes `INT:17` / `INT:13`. The CONST-TYPE
and the value PREFIX reach golden; the DIGITS never move, and they were
already wrong — golden folds an operand there that we do not. That is why
`loc97v.py` scores the prefix and the digits apart.

**5.10 `results/*.csv` UNTOUCHED.** None of the four slang-fenced names
appears in any file of this patch — a per-name `awk` over the deliverable
reads 0 for each — and no test of theirs was ever dispatched as an arm.
**`ModuleEmit.cpp` — the sister pass's ground — and `ParamEmit.cpp` are both
ABSENT from the patch.** The production surface is `src/EmitHelpers.h` and
`src/ExprEmit.cpp`, plus `tools/probe/r11u97repro/`.

**5.11 THE SHIPPED SOURCE IS THE MEASURED SOURCE.** Checked, not assumed: the
deliverable patch applied to a FRESH `fdaccc06` worktree with `git apply -3`
(rc 0, no conflict marker) and built there independently links to
**`457297442d61fd7c085ec369c46e3ad2`, byte for byte** — the law binary every
measurement above was taken on.

---

## 6. RESIDUES

* **R1 — `vpiPowerOp` AT THE TOP STILL MINTS `INT:`.** `int XPOW = 2 ** 3` is
  golden `INT:8` where both binaries write `UINT:8`. r11u96's R1 verbatim: the
  CHILD face is closed here (`APOWL`, `ANAMEP`), the TOP face is not, because
  its value runs in `double` and past-`int64` renders § patPowCastArtefact73's
  cast artefact. One flag on `red97IntMintTop97` when that pass comes.
* **R2 — THE UINT-MINTING ARMS' OWN VALUES.** `int U1ADD = '1 + 0` is golden
  `UINT:1` where pristine writes `INT:-1`, and `int U1AND = '1 & 3` golden
  `UINT:1` where both write `UINT:3`. The producer's `+`, `&`, `|`, `<<` and
  `>>` arms read the DIGITS through `get_value`/`get_uvalue` exactly as the
  INT-minting five do, but they keep `UINT:`, so the VALUE is wrong on those
  roads while the const type is right. This pass's ExprEmit gate only takes
  the reduce's digits when the top operator is one of the INT-minting five, so
  it cannot reach them. r11u96's R3 and r11v96's RV96-5 one operator wider,
  now with the `'0`/`'1` face on the same list. The cure is the digit road
  without the const-type road; it wants its own census.
* **R3 — THE BARE LITERAL, NO OPERATOR AT ALL.** `int U1BARE = '1` is golden
  `UINT:4294967295` and `int U0BARE = '0` golden `BIN:0`, where we write
  `INT:-1` and `UINT:0`. `adjustSize`'s `(orig_size == -1)` branch is a
  different producer road from the reduce, LAW A is confined to `inArm` for
  r11u76's reason, and the `INT:` here comes from the landed `neg91` gate
  firing on slang's filled store. Closing it wants the bare-literal road and
  `neg91` re-read together — r11u96's R4, one literal kind over.
* **R4 — A CHAIN OVER A COMPARISON DOES NOT CARRY THE ENCODING.**
  `int CCHN = CLT` over `int CLT = (3 < 4)` is golden `BIN:1` with the
  decompile `32'b1` and both binaries write `UINT:1`. LAW C's gate reads the
  TOP operator and a NAME is not a comparison — correctly so, because golden
  itself writes `BIN:1` there and not `INT:-1`, so the chain inherits the
  source parameter's own encoding rather than re-deriving it. Closing it wants
  the name road, not this gate.
* **R5 — THE `param_assign` READING HOME'S ELABORATED VIEW.** Golden
  decompiles a one-bit `BIN:` as `<width>'b<v>` in every `uhdmtopModules`
  instance of a parameter default and as the bare digit in the definition; we
  write the bare digit in both (`z6_pahome97` u0/u1, 8 STILL cells). PRE-
  EXISTING on the pristine binary, fenced here by the `param_assign` gate
  precisely because this site cannot tell the views apart. It wants the
  emitter's own view flag.
* **R6 — THE SIZE FACE.** Golden's size on the net-decl-assign road is 32 or
  64 where ours is the parameter's declared width (`wU1MINW` 64 vs 32).
  r11u91's R4 / r11u94's R3 / r11v94's RV94-4 / r11u96's R5 verbatim, FENCED,
  and why the scorers are per-field.
* **R7 — RV94-5, THE DYNAMIC ARRAY'S RANGE BOUND.** Our emitter prints an
  uninitialized pointer-valued `UINT:` constant as the right range of a
  dynamic array typespec (`uvm_pkg` 642:23, `g22.sv`, `l154_noenum.sv`,
  `g185_e_kinds.sv`). Latent on every binary, invisible to the judge, and the
  whole of this pass's surelog byteverify flag list and of its three
  page-boundary boundary arms. r11u96's R7 unchanged; it deserves closing so
  that a byteverify stops flagging databases no law touched.

**R0 — the next pass.** R2 is the widest and the best-measured: the digit road
without the const-type road, over `+`, `&`, `|`, `^`, `<<` and `>>`, with the
`'0`/`'1`, unsized-decimal and based-leaf arms already in place underneath it
and `red97OperandMintsInt97` already naming which operators keep `UINT:`.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp fdaccc06 && git worktree add /tmp/wtl fdaccc06
(cd /tmp/wtl && git apply -3 /tmp/r11u97.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done            # 54d56dd004635a3c…  and  457297442d61fd7c…
# ---- the grid ---------------------------------------------------------------
G=/tmp/g97 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u86repro/run66.sh $R/r11u97repro/{nda97.py,loc97v.py,cmp97.py} $G/
cp $R/r11u97repro/grid/*.sv $G/grid/
cp $R/r11v96repro/grid/{v1_amulbrk96v,v5_unbased96v}.sv $G/grid/
cp $R/r11u96repro/grid/{y1_muldiv96,y2_unsized96,y4_bail96}.sv $G/grid/
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/\.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm   # SAME-LENGTH
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wtl/build/slang-uhdm   # TAGS
done                                   # every arm must read slrc=0 ourrc=0 slerr=0
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/\.sv$//'); do
  python3 $G/loc97v.py $G/grid/$a.g.dump $G/grid/$a.pris.dump $G/grid/$a.lawx.dump
  python3 $G/nda97.py  $G/grid/$a.g.dump $G/grid/$a.pris.dump $G/grid/$a.lawx.dump
done                                   # TO=243 total  AWAY=0  MOVED-WRONG=0
# the positive control — every TO must become an AWAY:
#   the same calls with the last two arguments REVERSED -> TO=0 AWAY=243 MWRONG=243
# ---- the census and the a-priori prediction ---------------------------------
python3 $R/r11u97repro/census97.py --selftest          # SELFTEST PASS
python3 $R/r11u97repro/census97.py                     # the roots are built in
python3 $R/r11u97repro/predict97.py <u2r workdir>      # 27 rows, ibex_icache named
python3 $R/r11u97repro/predict97.py <surelog workdir>  # 26 rows
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
# ---- each face droppable alone: five more binaries --------------------------
#   LAW A reverted  — the `red97UnbasedDigit97` block removed from red72Int64
#   LAW B reverted  — `constexpr bool add97 = false`
#   LAW C reverted  — `constexpr bool cmpInt97 = cmpBin97 = false`
#   power child     — `constexpr bool pow97 = false`
#   chain reverted  — `constexpr bool chn97 = false`
# ---- the wide boundary and its null control ---------------------------------
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wtl/tools/probe BND_OUT=/tmp/bnd97 \
#     xargs -P 3 -n 1 bash r11u91repro/bnd72.sh < armlist
#   NULL:  BND_LAW = BND_PRIS, over the DIFFERS list      -> 27 SAME / 0 DIFFERS
#   score each DIFFERS arm PER VIEW with r11u97repro/loc97v.py against a fresh
#   Surelog v1.87 golden — a LOCATION-ONLY key reads AWAY=0 over real AWAY cells
```

Evidence: `evidence/{GRID97.score, SWAPCTL97.score, CELLS97.txt, CENSUS97.txt,
PREDICT97.u2r.txt, PREDICT97.sl.txt, ARMS97.txt, GATES97.txt, MOVERS97.txt,
BOUNDARY97.arms, BOUNDARY97.classes, DROP97.txt, BINARIES97.txt}`.
