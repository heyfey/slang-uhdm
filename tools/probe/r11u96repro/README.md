# r11u96 — three operators mint an `int`, the written digits outlive the store, and a replication asks nobody

**THREE FOLD-ENCODING FACES IN ONE BATCH, EACH DROPPABLE ALONE, ALL THREE OF
THEM r11v94's OWN RESIDUES — plus the ONE regression LAW C's own grid found,
closed in the same patch.**

**LAW A (RV94-1).** `reduceExpr`'s `vpiMultOp`, `vpiDivOp` and `vpiModOp` arms
are `vpiSubOp`'s body with one operator swapped: they mint `"INT:" +
std::to_string(val)` with `vpiIntConst` and an `int64_t` the declared type
never masks. `int XMUL = 2 * 3` is golden `INT:6 ct7`, `int XDIV = 6 / 2`
golden `INT:3 ct7` and `int BMOD = 7 % 4` golden `INT:3 ct7`, where both
binaries write `UINT: ct9`; and `logic [7:0] MU8 = 100 * 3` is golden
`INT:300` where the store has already wrapped to 44.

**LAW B (RV94-2).** An UNSIZED DECIMAL leaf is worth its WRITTEN DIGITS.
Surelog builds a bare decimal as a `vpiUIntConst` carrying the digits as
written and `get_value` reads that string; slang, obeying the LRM, types the
literal `int` and truncates it to 32 SIGNED bits — so the two readings part
company at **2^31**, not at 2^32. `longint BLMIN = -9223372036854775807` is
golden `INT:-9223372036854775807` where both binaries write `1`.

**LAW C (RV94-3).** The concatenation class under an EXPLICIT declared type.
A WRITTEN type is no different from a synthesized one: where the initializer
holds a concatenation the typespec never reaches the elaborated constant, the
clone is bare, and the READER votes. `int JC = {4'd1,4'd2}` read by
`logic [7:0]` is golden `ts=-` where both binaries write `int_typespec/S`.

**§ pkgBareReplicWritesNoTs96 — THE REGRESSION LAW C ALONE CAUSES.** LAW C's
own grid arm `y5_replic96` found a shape r11v94's kind-2 table never held: a
package parameter whose OWN initializer is a **BARE top-level REPLICATION** is
read with **no typespec at all** — not the package's and not the reader's —
whatever the declaration kind and whatever the reader's sign. LAW C alone
routes such a read back to the reader's declaration and writes the reader's
`/S` on a PRISTINE-BARE cell: an AWAY. Nine golden cells say the site must
write nothing; the fix is one predicate and two lines at the call site, and it
is the only binary in §6 with `AWAY != 0` when it is reverted.

Base `5a20468f`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden here is a real Surelog v1.87 run
through the committed `r11u86repro/run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`: **all 7 grid arms read `0 0 0` on all six binaries, all 42
arm-runs.**

| binary | md5 | what |
|---|---|---|
| pristine | `8b04ca25ae24cab79525249c4e5390a5` | built in this pass's own worktree — byte-identical to the main tree at `5a20468f` and to the ops-brief md5 |
| **law** | `125983deb62fe102bd64fe260e22d83a` | this patch |
| LAW A reverted | `c97ee2a8b1c9fe780bb751d9222e3dcf` | |
| LAW B reverted | `5015c5be2aa54b9e99b322842d1db64b` | |
| LAW C reverted | `0c4e692515f75c244b17aa95a2ced4f5` | the kind-1 arm alone; the replication face kept |
| replication face reverted | `9f398adf9e5ebe5b55edcf3074e01653` | LAW C kept — **the only binary with AWAY != 0** |
| 16 KB pad control | `52e58ddc97ad2e1f21183ede6e94ad3f` | PRISTINE source + an inert 16384-byte array |

---

## 1. THE PRODUCER, LINE BY LINE

### 1.1 LAW A — three arms, one body

```cpp
case vpiMultOp: {                 // ExprEval.cpp:3479, TWO operands
  int64_t val = val0 * val1;
  c->VpiValue("INT:" + std::to_string(val));
  c->VpiDecompile(std::to_string(val));
  c->VpiSize(64);
  c->VpiConstType(vpiIntConst);
case vpiModOp: {                  // :3709   `if (val1 && …) val = val0 % val1;`
case vpiDivOp: {                  // :3803   `if (divisor && …) val = num / divisor;`
```

— identical, line for line, to the landed `vpiSubOp` arm at `:3443`, and
against the control `vpiAddOp` at `:3260`, which reads `get_uvalue` and mints
`UINT:` whenever both reduced operands are unsigned constants.

The two guards matter and are transcribed: `vpiDivOp` mints only when the
divisor is nonzero and `vpiModOp` only when `val1` is nonzero, and Surelog
v1.87 answers a named-zero divisor with `[ERR:UH0722] Division by zero`
rather than a constant — **that shape has no golden at all** (measured,
`y4_bail96`'s first cut, `slrc=4 slerr=2`, recorded in `evidence/ARMS96.txt`).
`red72Int64` already answers `Unknown` on `r == 0`, so the gate declines.

### 1.2 LAW B — `get_value` reads the string, not the store

`get_value` (`~/git-repos/UHDM/templates/ExprEval.cpp:1946`) parses the
constant's `VpiValue` DIGIT STRING with the lenient `NumUtils` pair (int64
first, then uint64 cast down). That road is already in this file: it is the
no-tick arm of `srlgNegLitGetValue30`, which r11u76 uses for every BASED leaf.
The unsized decimal is the other half of the same string, and **no second
parser is written** — `red96UnsizedDecDigits96` hands the literal's own raw
text to that one call.

### 1.3 LAW C and the replication — `CompileHelper.cpp:3744-3750` and `DesignElaboration.cpp:2568`

The typespec is hung on the elaborated constant only when the compile produced
one; where the initializer holds a concatenation it does not reach the
constant, `DesignElaboration.cpp:2568`'s fill-in runs and `valueRange`'s third
argument is the READER's. r11v94 landed that for the SYNTHESIZED (kind 2)
typespec and left the WRITTEN (kind 1) road alone; this is that road. **A bare
replication is a third case**: neither typespec reaches the read, so the site
writes nothing — which is what golden writes on a miss.

---

## 2. THE FOUR § BLOCKS

### § pkgParamMulDivModIsIntReduce96 — `src/EmitHelpers.h` + `src/ExprEmit.cpp`

```
red96IntMintTop96(init, mul96, div96, mod96)
        the landed red94MinusTop94 (unary `-`, binary `a - b`) OR, each
        behind its own flag, a binary `*`, `/` or `%` at the TOP of the
        initializer with only implicit conversions peeled.
the call site: red94MinusTop94(*mi94)  ->  red96IntMintTop96(*mi94, …)
        with three `constexpr bool` flags, so each operator drops alone.
```

`**` is NOT on this law although `vpiPowerOp` (`:3760`) mints `INT:` in the
same three lines: its value face is the `double` artefact
§ patPowCastArtefact73 already carries, so it is MEASURED (`int CPOW = 2 ** 3`
golden `INT:8`, both binaries `UINT:8`) and recorded as residue **R1**.
`~` cannot be reached in either direction — the gate reads the WRITTEN
OPERATOR and never the sign of a value.

### § unsizedDecLeafWrittenDigits96 — `src/EmitHelpers.h`

```
red96UnsizedDecDigits96(e, out)  an `IntegerLiteral` whose syntax (parentheses
        walked, as r11u76's reader does) is an `IntegerLiteralExpression`
        whose raw text carries no `'` and only digits, valued through
        `srlgNegLitGetValue30`'s no-tick arm — `get_value`'s own read.
red72Int64: one `if (inArm)` block after the landed based-leaf one.
```

Confined to `inArm` for r11u76's reason: at operand 0 the literal path already
emits the leaf verbatim. Digits that fit neither `int64` nor `uint64` make the
call return false, which is the same refusal golden takes —
`longint OVF = 99999999999999999999 - 1` is left UNFOLDED by Surelog v1.87
(`y4_bail96`, no net-decl-assign constant at all).

### § kind1ConcatKeepsNoTs96 — `src/EmitHelpers.h`

```
red91PkgCloneHasTs91:  dk91 == 1  ->  !red94InitHasConcat94(ps91, 0)
```

One line, on the predicate r11v94 already wrote and verified for kind 2.
`red91PkgStoreSize91` needs no change — a concatenation is neither a `'d`
vector leaf nor a name, so its existing gate already declines.

### § pkgBareReplicWritesNoTs96 — `src/EmitHelpers.h` + `src/ParamEmit.cpp`

```
red96TopIsReplic96(ps96)  the parameter's OWN initializer, implicit
        conversions peeled, is an ExpressionKind::Replication.
the call site: `if (pi91 && red96TopIsReplic96(*pi91)) continue;`
        two lines, BEFORE the has-a-typespec gate, so it covers all three
        declaration kinds.
```

A replication reached through a CHAIN, nested inside a concatenation, or
standing under an operation is NOT this shape — measured, all three golden
`/S` on a signed reader and all three unmoved.

`ParamEmit.cpp` is touched by these two lines and nothing else; its
`__LINE__`-sensitivity is the reason the surface is exactly that.

---

## 3. THE GOLDEN GRID — 7 arms, scored PER FIELD

Five new arms (`y1_muldiv96`, `y2_unsized96`, `y3_kind1cat96`, `y4_bail96`,
`y5_replic96`) and the two r11v94-generation CONTROL arms (`x2_minusedge94v`,
`x6_concatvote94v`) re-run unchanged. The net-decl-assign road is read with
the committed `r11u94repro/nda94.py`; the `'{…}` pattern road with
`score96f.py`, this pass's PER-FIELD rescoring of `score87v.py` (LAW C writes
exactly ONE of a cell's five fields, and the concatenation cells carry a
SECOND, older disagreement on `ct`/`v`/`d`, so a whole-tuple score reads every
one of them `WRONG2` and shows nothing).

### 3.1 LAW A, per cell (`y1_muldiv96`, and `x2`'s `wBMOD`)

| package declaration | golden | pristine | law |
|---|---|---|---|
| `int XMUL = 2 * 3` | **`INT:6 ct7`** | `UINT:6 ct9` | `INT:6 ct7` |
| `int XDIV = 6 / 2` | **`INT:3 ct7`** | `UINT:3 ct9` | `INT:3 ct7` |
| `int XMOD = 7 % 4` | **`INT:3 ct7`** | `UINT:3 ct9` | `INT:3 ct7` |
| `int BMOD = 7 % 4` (`x2`) | **`INT:3 ct7`** | `UINT:3 ct9` | `INT:3 ct7` |
| `int MZERO = 0 * 5` | `INT:0 ct7` | `UINT:0 ct9` | `INT:0 ct7` |
| `int MONE = 1 * 1` | `INT:1 ct7` | `UINT:1 ct9` | `INT:1 ct7` |
| `int DTRUN = 7 / 2` | `INT:3 ct7` | `UINT:3 ct9` | `INT:3 ct7` |
| `int MODZ = 4 % 4` | `INT:0 ct7` | `UINT:0 ct9` | `INT:0 ct7` |
| `int MNEST = 2 * (3-1)` | `INT:4 ct7` | `UINT:4 ct9` | `INT:4 ct7` |
| `int MCHN = XMUL * 2` | `INT:12 ct7` | `UINT:12 ct9` | `INT:12 ct7` |
| `int DCHN = XMUL / 2` | `INT:3 ct7` | `UINT:3 ct9` | `INT:3 ct7` |
| `logic [7:0] MHEX = 8'h10 * 2` | `INT:32` | `UINT:32` | `INT:32` |
| `logic [7:0] MU8 = 100 * 3` | **`INT:300`** | `UINT:44` | `INT:300` |
| `byte MBY = 100 * 3` | **`INT:300`** | `UINT:44` | `INT:300` |
| `bit [3:0] MB4 = 5 * 5` | **`INT:25`** | `UINT:9` | `INT:25` |
| `int MBIG = 100000 * 100000` | **`INT:10000000000`** | `UINT:1410065408` | `INT:10000000000` |
| `logic [7:0] DU8 = 6 / (-2)` | `INT:-3` | `UINT:253` | `INT:-3` |
| `logic [7:0] MODU8 = (-7) % 4` | `INT:-3` | `UINT:253` | `INT:-3` |
| **AND THE LIVE CONTROLS** | | | |
| `int CADD = 1 + 2` | `UINT:3` | `UINT:3` | unchanged |
| `int CSHL = 1 << 3` | `UINT:8` | `UINT:8` | unchanged |
| `int CCAST = int'(2 * 3)` | `UINT:6` | `UINT:6` | unchanged |
| `int CLIT = 6` | `UINT:6` | `UINT:6` | unchanged |
| `logic [7:0] CHEX = 8'hff` | `HEX:ff` | `HEX:ff` | unchanged |
| `int CSUB = 8 - 1` | `INT:7` | `INT:7` | unchanged (landed) |
| `int MNEG = (-2) * 3` | `INT:-6` | `INT:-6` | unchanged |
| `int DNEG = (-6) / 2` | `INT:-3` | `INT:-3` | unchanged |
| `int MODN = (-7) % 4` | `INT:-3` | `INT:-3` | unchanged |
| **`int CPOW = 2 ** 3`** | `INT:8` | `UINT:8` | **STILL — R1, fenced** |
| **`int CNOT = ~0`** | `UINT:4294967295` | `INT:-1` | **STILL — R2, fenced** |

**A NEGATIVE ANSWER IS NOT THE AXIS AND NEVER WAS.** `MNEG`, `DNEG` and
`MODN` already write `INT:` through the landed `neg91` gate, which reads the
sign of slang's stored value; `MZERO`, `MONE` and `MODZ` are golden `INT:` at
a ZERO and a ONE, which no sign of any value can produce. The gate is the
WRITTEN OPERATOR.

### 3.2 LAW B, per cell (`y2_unsized96`, `y4_bail96`, and `x2`'s `wBLMIN`)

| package declaration | golden | pristine | law |
|---|---|---|---|
| `longint BLMIN = -9223372036854775807` | **`INT:-9223372036854775807`** | `INT:1` | golden |
| `longint BLMAX = 9223372036854775807 - 0` | **`INT:9223372036854775807`** | `INT:-1` | golden |
| `longint B31 = 2147483648 - 0` | **`INT:2147483648`** | `INT:-2147483648` | golden |
| `longint B31M = -2147483648` | **`INT:-2147483648`** | `INT:2147483648` | golden |
| `longint B32 = 4294967296 - 0` | `INT:4294967296` | `INT:0` | golden |
| `longint B33 = 8589934592 - 0` | `INT:8589934592` | `INT:0` | golden |
| `longint B33M = -8589934592` | `INT:-8589934592` | `INT:0` | golden |
| `longint BMULU = 4294967296 * 2` | `INT:8589934592 ct7` | `UINT:0 ct9` | golden (A+B) |
| `longint BDIVU = 8589934592 / 2` | `INT:4294967296 ct7` | `UINT:0 ct9` | golden (A+B) |
| `longint DMIN = -92233…807 / 1` (`y4`) | `INT:-9223372036854775807 ct7` | `UINT:1 ct9` | golden (A+B) |
| the same `B33` read by `wire [63:0]` | `INT:8589934592` | `INT:0` | golden |
| the same `B33` read by `wire signed [31:0]` | `INT:8589934592` | `INT:0` | golden |
| **AND THE CONTROLS** | | | |
| `longint B30 = 1073741824 - 0` | `INT:1073741824` | `INT:1073741824` | unchanged — 31 bits, FITS |
| `longint BSMALL = 6 - 1` | `INT:5` | `INT:5` | unchanged |
| `longint BHEXW = 64'h1_0000_0000 - 0` | `INT:4294967296` | `INT:4294967296` | unchanged — a BASED leaf, r11u76's |
| `longint MMAX = 92233…807 * 2` (`y4`) | `INT:-2` | `INT:-2` | unchanged — the int64 WRAP agrees |
| **`longint BADDU = 4294967296 + 1`** | `UINT:4294967297` | `UINT:1` | **STILL — R3, the `+` arm** |
| **`longint BLBARE = 9223372036854775807`** | `UINT:92233…807 ct9` | `INT:-1 ct7` | **STILL — R4, no operator at all** |

**THE THRESHOLD IS 2^31, MEASURED.** `B30` at 2^30 is EQUAL on both binaries
and `B31` at exactly 2^31 is already `-2147483648` in the store, so the
boundary is the SIGNED 32-bit one and not the unsigned. `MMAX` is the other
edge: golden's own `int64_t` wraps to `-2` and our reduce wraps the same way,
so the law leaves it where it is.

### 3.3 LAW C and the replication, per cell — the `ts` field (`y3`, `y5`, `x6`)

| package declaration | reader | golden | pristine | law |
|---|---|---|---|---|
| `int JC = {4'd1,4'd2}` | `logic [7:0]` | **`ts=-`** | `/S` | `ts=-` |
| `int JC` | `logic signed [15:0]` | `/S` | `/S` | `/S` |
| `logic [7:0] JU = {4'd1,4'd2}` | `logic signed [15:0]` | **`/S`** | `ts=-` | `/S` |
| `logic [7:0] JU` | `logic [7:0]` | `ts=-` | `ts=-` | `ts=-` |
| `logic signed [15:0] JS = {..}` | `logic [7:0]` | **`ts=-`** | `/S` | `ts=-` |
| `int JN = {4'd1,4'd2} + 0` | `logic [7:0]` | **`ts=-`** | `/S` | `ts=-` |
| `int JTC = 1 ? {..} : 8'd0` | `logic [7:0]` | **`ts=-`** | `/S` | `ts=-` |
| `int JSC = {..} >> 1` | `logic [7:0]` | **`ts=-`** | `/S` | `ts=-` |
| `int JCH = JC` (a CHAIN) | `logic [7:0]` | **`ts=-`** | `/S` | `ts=-` |
| `int JC` (`x6`'s `O6`, RV94-3) | `logic [7:0]` | **`ts=-`** | `/S` | `ts=-` |
| **THE BARE REPLICATION — NOBODY VOTES** | | | | |
| `int KR = {2{4'd3}}` (k1) | `logic [7:0]` | **`ts=-`** | `/S` | `ts=-` |
| `int KR` | `logic signed [15:0]` | **`ts=-`** | `/S` | `ts=-` |
| `logic [7:0] KRU = {2{4'd3}}` (k1) | `logic [7:0]` | `ts=-` | `ts=-` | `ts=-` |
| `logic [7:0] KRU` | `logic signed [15:0]` | `ts=-` | **`ts=-`** | `ts=-` ← THE AWAY |
| `signed KR2 = {2{4'd3}}` (k2) | `logic [7:0]` | `ts=-` | `ts=-` | `ts=-` |
| `signed KR2` | `logic signed [15:0]` | **`ts=-`** | `/S` | `ts=-` |
| `unsigned KRU2 = {2{4'd3}}` (k2) | `logic signed [15:0]` | **`ts=-`** | `/S` | `ts=-` |
| `(implicit) KRIM = {2{4'd3}}` (k0) | `logic [7:0]` | `ts=-` | `ts=-` | `ts=-` |
| `(implicit) KRIM` | `logic signed [15:0]` | **`ts=-`** | `/S` | `ts=-` |
| **AND WHAT IS NOT A BARE REPLICATION** | | | | |
| `int KRC = KR` (a CHAIN) | `logic signed [15:0]` | `/S` | `/S` | `/S` |
| `int KRN = {2{4'd3}} + 0` | `logic signed [15:0]` | `/S` | `/S` | `/S` |
| `int KRR = {{2{2'd1}},4'd2}` | `logic signed [15:0]` | `/S` | `/S` | `/S` |
| **AND THE KIND-1 CONTROLS** | | | | |
| `int JLIT = 8'd18` | `logic [7:0]` | `32 INT:18 /S` | same | unchanged |
| `int JOP = 3 + 4` | `logic [7:0]` | `UINT:7 /S` | same | unchanged |
| `int JHX = 8'h1A` | `logic [7:0]` | `HEX:1A /S` | same | unchanged |
| `logic [7:0] JDU = 8'd18` | `logic signed [15:0]` | `ts=-` | same | unchanged |

**THE `KRU` ROW IS THE REGRESSION.** `logic [7:0] KRU = {2{4'd3}}` read by
`logic signed [15:0]` is golden BARE and PRISTINE-BARE; LAW C alone wrote the
reader's `/S` there. `JDU` is the control that proves the LANDED replacement
still holds without a concatenation — a SIGNED reader over an UNSIGNED kind-1
package is golden BARE.

### 3.4 THE SCORE, AND ITS POSITIVE CONTROL

| scoring | TO | AWAY | MOVED-WRONG |
|---|---|---|---|
| net-decl-assign, per FIELD (`y1` 40, `y2` 26, `y4` 3, `x2` 4) | **73** | **0** | **0** |
| the same, tags reversed | 0 | **73** | 0 |
| pattern cells, the `ts` field (`y3` 24, `y5` 22, `x6` 2) | **48** | **0** | **0** |
| the same, tags swapped | 0 | **48** | **48** |
| pattern cells, all five fields | 48 | **0** | **0** |

`AWAY = 0` is a MEASUREMENT: swapping the two tags turns every one of the 121
moved fields into AWAY, and every one of the 48 `ts` cells into AWAY *and*
MOVED-WRONG. `UNPAIR = 0` on all three pattern arms and `MISSING = 0` on all
four net-decl-assign arms.

---

## 4. CENSUS, A PRIORI, BY NAME

`census96.py` carries one class per law, each a strict superset of the gate
that lands, with a POSITIVE control (this pass's own arms plus the two
r11v94 ones) and a LIVE NEGATIVE control (`**`, `+`, `<<`, a bare `-`, a
kind-2 concat, a `'{…}` pattern, and a decimal below 2^31 — every one of which
must be UNSIGHTED).

```
AGREE96 11857   K1C96 1153   MDM96 150   MDMW96 191   UDC96 310   UDC96W 10
--- candidate tests: 64                              SELFTEST PASS
  not sighted (3): p1_pkgin91 q4_negpkg94 y1_sgnd87   [the live negative control]
```

`UDC96` is deliberately NOT parameter-keyed: LAW B changes `red72Int64`, which
ParamEmit, ModuleEmit and ExprEmit all read, so the superset is "does this
file contain an unsized decimal the two readings disagree on at all". `UDC96W`
is the calibration band from 2^30 — literals that MUST be sighted and MUST NOT
move, and none did.

`predict96.py` re-keys the census from the TEST DIRECTORY to the SWEEP ROW,
reading each row's own `cmds.txt` and its whole test tree (r11u94's R5 root
fix carried forward — `verify_golden.py:50` reads `~/git-repos/uhdm2rtlil/test`,
SINGULAR):

```
predict96.py <u2r workdir>       31 rows   (20 of them ibex_*, incl. ibex_icache)
predict96.py <surelog workdir>   46 rows
```

**The measured mover set is a SUBSET of that**, and the one u2r mover —
`ibex_icache` — is named in it BY NAME with both of the classes that reach it.

---

## 5. GATES — ALL MANDATORY

**5.1 BUILD.** `-j 2`, `md5sum` separately, every binary `chmod 555` BEFORE
any sweep. Pristine `8b04ca25ae24cab79525249c4e5390a5` — **byte-identical to
the main tree at `5a20468f`, the md5 the ops brief names**. Law
`125983deb62fe102bd64fe260e22d83a`.

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
join against `results/golden_surelog.csv` names, on the LAW binary, **exactly
two rows and no third**:

```
LowMemLib   testflags   SURELOG_FAIL, DETAIL = the sweep's OWN workdir path
LowMemPkg   testflags   SURELOG_FAIL, DETAIL = the sweep's OWN workdir path
```

and the PRISTINE sweep names those two plus `Earlgrey_0_1` default AND
testflags, whose DUMP COLUMN read blank — the documented `uhdm-dump` timeout
draw, on the PRISTINE binary, on BOTH modes. **No status moved, in either
direction, on any row of either corpus.**

**5.5 byteverify, SELFCHECK=1, both corpora, against this pass's own pristine
workdirs.** `evidence/MOVERS96.txt`.

* **uhdm2rtlil: `MOVERS 2 / 1608`, `PATH_SETS_IDENTICAL`, `SELFCHECK
  1607/1608`.** Both are `ibex_icache`, one per mode, PREDICTED BY NAME. The
  whole path-normalised dump diff is **40 lines per mode — 10 `|UINT:2` ->
  `|INT:2` and 10 `|vpiConstType:9` -> `:7`, and nothing else; `vpiSize` 0,
  `Typespec` 0, `vpiDecompile` 0.** The cells are the module-side reads of
  `ibex_pkg::IC_LINE_BEATS` (`IC_LINE_BYTES / BUS_BYTES`) and
  `IC_OUTPUT_BEATS` (`(BUS_BYTES / 2)`) at `ibex_icache.sv`
  942/1020/1044/1050/1171/1180 — **LAW A's DIVIDE arm** — and **GOLDEN AT
  EVERY ONE OF THOSE CELLS READS `|INT:2 |vpiConstType:7`**, so the mover is
  TO GOLDEN. The row is `ibex_icache,{default,testflags},CMP_NOTEQUAL,
  decompile:` in the committed baseline and STAYS so.
* **Surelog: `MOVERS 4 / 960`, `PATH_SETS_IDENTICAL`, `SELFCHECK 959/960`.**
  `MiniAmiq` and `SeqDriver`, both modes, and **none of them is this pass's**.
  Attributed ORDER-BLIND on path-normalised, id-stripped, SORTED dumps: each
  moves **exactly four lines, one `|UINT:` / `|vpiDecompile:` pair**
  (`825->1451`, `866->0`, `1132->740`, `968->0`), and across all four
  **`|INT:` 0, `vpiConstType` 0, `vpiSize` 0, `Typespec` 0, `int_typespec`
  0** — none of the fields these laws write. The cell is the SAME one in all
  four: the `vpiRightRange` constant of the `types_t` `array_typespec` at
  `uvm_pkg` 642:23, a DYNAMIC array whose bound our emitter prints from an
  uninitialized pointer-valued `UINT` — **r11v94's RV94-5**, latent on every
  binary. **POSITIVE CONTROL: the 16 KB-pad binary — PRISTINE SOURCE plus an
  inert 16384-byte array, no behaviour change whatever — run on MiniAmiq's own
  invocation moves that same `|UINT:825` / `|vpiDecompile:825` pair** (and 120
  `class_defn` lines the law does not touch at all). An inert code-size change
  alone reproduces the whole class. `predict96.py` does not name either row,
  and it is right not to.

**5.6 CANARIES AND PINS.** Surelog `ok=52 changed=0` on the LAW binary and
`ok=50 changed=2` on the PRISTINE one (the two are `Earlgrey_0_1`'s dump
column — the draw is the pristine sweep's). u2r `ok=8 changed=0 absent=0` on
both. `ctcan2` PASS on both corpora. `canaudit.sh canaries.sh ctcan2.sh` ->
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

**5.8 EACH LAW DROPPABLE ALONE**, four further binaries built from this
patch's own hunks in their own fresh `5a20468f` worktrees
(`evidence/DROP96.txt`):

| binary | `y1` A | `y2` B | `y4` | `x2` | `ts` (y3+y5+x6) |
|---|---|---|---|---|---|
| full law | 40 / 0 | 26 / 0 | 3 / 0 | 4 / 0 | 48 / 0 |
| LAW A reverted | **0 / 0** | 20 / 0 | **0 / 0** | 2 / 0 | 48 / 0 |
| LAW B reverted | 40 / 0 | **2 / 0** | 1 / 0 | 2 / 0 | 48 / 0 |
| LAW C reverted | 40 / 0 | 26 / 0 | 3 / 0 | 4 / 0 | **16 / 0** |
| replication face reverted | 40 / 0 | 26 / 0 | 3 / 0 | 4 / 0 | **38 / 2** |

(TO / AWAY.) LAW A is worth 51 fields, LAW B 28, LAW C's kind-1 arm 32 `ts`
cells and the replication face 10 more — **and the replication face is the
only one whose removal produces an AWAY at all**, which is what makes it part
of this patch rather than a residue.

**5.9 THE WIDE BOUNDARY**, every `*.sv` under `tools/probe`, not the grid
glob: **8302 arms — 8053 SAME, 21 DIFFERS, 220 NODB**, and every NODB arm has
`prc == lrc` (216 x `rc=3`, 4 x `rc=139`). **NULL BOUNDARY** (the pristine
binary against itself over all 21) reads **DIFFERS 0 / 21** — not one of them
is a run-to-run coin. The 21 are **THREE CLASSES AND NO FOURTH**
(`evidence/BOUNDARY96.classes`):

* **LAWS A/B, 15 arms** — `|UINT:` <-> `|INT:`, `vpiConstType` 9 <-> 7,
  `vpiDecompile`.
* **LAW C and the replication face, 3 arms** (`y3`, `y5`, `x6`) — the
  `int_typespec` / `ref_typespec` / `vpiTypespec` / `vpiActual` / `vpiSigned`
  / `vpiFullName` / `vpiParent` / `constant` scaffolding.
* **THREE STATIC-ADDRESS FALSE MOVERS** (`g22.sv`, `l154_noenum.sv`,
  `g185_e_kinds.sv`) — `|UINT:` + `|vpiDecompile:` only, no `vpiConstType`,
  the three arms r11v94 names in RV94-5 — and the **16 KB-PAD CONTROL, run on
  PRISTINE SOURCE ALONE over the same 21 arms, moves EXACTLY those three and
  nothing else** (`evidence/PAD96.arms`).

Four committed boundary arms were re-measured against FRESH Surelog v1.87
goldens and every move is TOWARD golden with AWAY 0:
`d1_earl71` (56 cells toward), `g2_orig76` (14), `a4_val76` (4) and
`g7_add66` (1). `g7_add66` is worth naming because its own header calls it a
fence witness for "any arithmetic is INT": its one moved cell is the `q7::LM`
operand of an add golden FOLDS and we do not, and **golden's own elaborated
`q7::LM` — `localparam int LM = N * 2` — reads `INT:16 vpiConstType:7`**, so
the move is to golden's reading, not away from it. The `+`, shift, `**` and
based-leaf cells of that arm are all unmoved.

**5.10 `results/*.csv` UNTOUCHED.** None of the four slang-fenced names
appears in any file of this patch — a per-name `awk` over the deliverable
reads 0 for each — and no test of theirs was ever dispatched as an arm.
**`ModuleEmit.cpp` — the sister pass's ground — is ABSENT from the patch.**
The production surface is `src/EmitHelpers.h`, `src/ExprEmit.cpp` and two
lines of `src/ParamEmit.cpp`, plus `tools/probe/r11u96repro/`.

**5.11 THE SHIPPED SOURCE IS THE MEASURED SOURCE.** Checked, not assumed: the
deliverable patch applied to a FRESH `5a20468f` worktree with `git apply -3`
(rc 0, no conflict marker) and built there independently links to
**`125983deb62fe102bd64fe260e22d83a`, byte for byte** — the law binary every
measurement above was taken on.

---

## 6. RESIDUES

* **R1 — `vpiPowerOp` MINTS `INT:` TOO.** `int CPOW = 2 ** 3` is golden
  `INT:8` where both binaries write `UINT:8` (`y1_muldiv96` `wCPOW`).
  `ExprEval.cpp:3760` mints `INT:` in the same three lines as `vpiMultOp`,
  but its VALUE face runs in `double` and past-`int64` renders the cast's own
  out-of-range artefact — § patPowCastArtefact73's ground — so the two faces
  want measuring together, in their own pass. One flag on
  `red96IntMintTop96`.
* **R2 — `~0` IS A `UINT:` AND WE WRITE AN `INT:`.** `int CNOT = ~0` is
  golden `UINT:4294967295` (`vpiBitNegOp`, `ExprEval.cpp:3515`, reads
  `(uint64_t)get_value`) and BOTH binaries write `INT:-1`: the landed `neg91`
  gate fires on the sign of slang's value. r11u94's R2 verbatim, unchanged
  here, still wrong on both binaries in the same way.
* **R3 — THE `+` ARM'S OWN UNMASKED VALUE.** `longint BADDU = 4294967296 + 1`
  is golden `UINT:4294967297` and both binaries write `UINT:1`
  (`y2_unsized96`). `vpiAddOp` reads `get_uvalue` — the WRITTEN DIGITS — and
  keeps `UINT:`, so the VALUE is wrong on this road while the CONST TYPE is
  right. LAW B does not reach it because the ExprEmit gate only takes the
  reduce's digits when the top operator is one of the INT-minting five. The
  cure is the digit road without the const-type road; unmeasured beyond this
  one cell.
* **R4 — THE BARE UNSIZED DECIMAL, NO OPERATOR AT ALL.** `longint BLBARE =
  9223372036854775807` is golden `UINT:9223372036854775807 ct9` and both
  binaries write `INT:-1 ct7` (`y2_unsized96`). Two fields wrong at once: the
  value is slang's 32-bit truncation and the const type comes from `neg91`
  firing on that truncation's sign. LAW B is confined to the reduce road for
  r11u76's reason, so it cannot see this cell; closing it wants the written
  digits AND the `neg91` gate re-read on them, together.
* **R5 — THE SIZE FACE.** Golden's size on the net-decl-assign road is 32 or
  64 where ours is the reader's or the parameter's declared width (`wMBIG` 64
  vs 32, `wMU8` 32 vs 8, `wMB4` 32 vs 4, `wCHEX` 32 vs 8). r11u91's R4 /
  r11u94's R3 / r11v94's RV94-4 verbatim, FENCED, and why the scorers are
  per-field.
* **R6 — THE CONCATENATION'S OWN ENCODING.** Golden renders a package
  parameter initialised by a concatenation `BIN:00010010 ct3` where we write
  `UINT:18 ct9` (every concat cell of `y3`/`y5`/`x6`). Identical on both
  binaries, untouched by LAW C, which writes only the typespec. It is why the
  pattern score is per FIELD, and it is the neighbourhood of r11v94's RV94-6.
* **R7 — RV94-5, THE DYNAMIC ARRAY'S RANGE BOUND.** Our emitter prints an
  uninitialized pointer-valued `UINT:` constant as the right range of a
  dynamic array typespec (`uvm_pkg` 642:23, `g22.sv`, `l154_noenum.sv`,
  `g185_e_kinds.sv`). Latent on every binary, invisible to the judge today,
  and the whole of this pass's surelog byteverify flag list. The 16 KB-pad
  control in §5.5 and §5.9 is its positive control; it deserves closing so
  that a byteverify stops flagging five databases that no law touched.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp 5a20468f && git worktree add /tmp/wtl 5a20468f
(cd /tmp/wtl && git apply -3 /tmp/r11u96.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done            # 8b04ca25ae24cab7…  and  125983deb62fe102…
# ---- the grid ---------------------------------------------------------------
G=/tmp/g96 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u86repro/run66.sh $R/r11u87repro/{ts87probe.cpp,score87v.py,join87.py} $G/
cp $R/r11u94repro/{cells94.py,nda94.py} $R/r11u96repro/score96f.py $G/
cp $R/r11u96repro/grid/*.sv $R/r11v94repro/grid/{x2_minusedge94v,x6_concatvote94v}.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts87probe.cpp -o ts87probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/\.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm   # SAME-LENGTH
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wtl/build/slang-uhdm   # TAGS
done                                   # every arm must read slrc=0 ourrc=0 slerr=0
for a in y1_muldiv96 y2_unsized96 y4_bail96 x2_minusedge94v; do
  python3 $G/nda94.py $G/grid/$a.g.dump $G/grid/$a.pris.dump $G/grid/$a.lawx.dump
done                                   # PER-FIELD TO=40/26/3/4  AWAY=0  MWRONG=0
TS87PROBE=$G/ts87probe python3 $G/score96f.py --field ts $G/grid pris lawx \
    y3_kind1cat96 y5_replic96 x6_concatvote94v      # TO=48 AWAY=0 STILL=0 MWRONG=0
# the positive controls — every TO must become AWAY:
#   nda94.py with the last two arguments reversed  ->  TO=0 AWAY=73
#   score96f.py on copies of the two output trees with the TAGS SWAPPED
#      ->  TO=0 AWAY=48 MWRONG=48
# ---- the census and the a-priori prediction ---------------------------------
python3 $R/r11u96repro/census96.py --selftest          # SELFTEST PASS
python3 $R/r11u96repro/census96.py                     # the roots are built in
python3 $R/r11u96repro/predict96.py <u2r workdir>      # 31 rows, ibex_icache named
python3 $R/r11u96repro/predict96.py <surelog workdir>  # 46 rows
#   the byteverify's mover list must be a SUBSET of those two
# ---- the corpora, per binary, workdir names the SAME LENGTH -----------------
#   verify_golden.py --corpus uhdm2rtlil --mode {testflags,default} --jobs 3
#   verify_golden.py --corpus surelog    --mode both               --jobs 3
#   join87.py results/golden_uhdm2rtlil.csv <tf.csv> <def.csv>      # DIFF=0
#   ct8rows.sh results/golden_surelog.csv <sl.csv>
#   SELFCHECK=1 r11u91repro/byteverify.sh <lawx wd> <pris wd>
#   RUN THE SWEEPS ONE PAIR AT A TIME.
# ---- each law droppable alone: four more binaries in their own worktrees ----
#   LAW A reverted  — the three `constexpr bool mul96/div96/mod96` flags to false
#   LAW B reverted  — the `red96UnsizedDecDigits96` block removed from red72Int64
#   LAW C reverted  — `dk91 == 1` back to `return true`
#   REPLIC reverted — the two-line `red96TopIsReplic96` continue removed
# ---- the wide boundary, its null control and its 16 KB pad ------------------
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wtl/tools/probe BND_OUT=/tmp/bnd96 \
#     xargs -P 2 -n 1 bash r11u91repro/bnd72.sh < armlist
#   NULL:  BND_LAW = BND_PRIS, over the DIFFERS list      -> 21 SAME / 0 DIFFERS
#   PAD:   BND_LAW = pristine source + `volatile const char pad96control[16384]`
#          over the same list -> DIFFERS on exactly g22 / l154_noenum / g185_e_kinds
```

Evidence: `evidence/{GRID96.score, SWAPCTL96.score, NDA96.txt, CELLS96.txt,
CENSUS96.txt, PREDICT96.u2r.txt, PREDICT96.sl.txt, ARMS96.txt, GOLDENS96.txt,
MOVERS96.txt, BOUNDARY96.arms, BOUNDARY96.classes, NULLBND96.arms,
PAD96.arms, DROP96.txt, BINARIES96.txt}`.
