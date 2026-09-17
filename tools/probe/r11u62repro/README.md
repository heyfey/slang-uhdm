# r11u62 — § ovStructActualOwnEnc62

**AN OVERRIDDEN STRUCT- OR PACKED-UNION-TYPED PARAMETER'S ELABORATED
`param_assign` Rhs CARRIES THE OVERRIDE ACTUAL'S OWN ENCODING — THE ASSEMBLED
`BIN:` BITS WHEN THE ACTUAL IS A MEMBER-ASSEMBLING CALL, THE LITERAL'S OWN BASE
LETTER AND DIGITS WHEN IT IS A BASED LITERAL — AND ONLY `VpiSize` IS RE-RENDERED
AT THE FORMAL.**

Base `05a6c144`. One law, one new file-local producer helper, one arm at one
site, three golden grids, one corpus mover pair, both mode columns scored,
every gate green. **`struct_member_cfg_width` ADVANCES 64 -> 17 cmp lines.**

---

## 1. THE WITNESS HEAD, RE-MEASURED AT `05a6c144`

r11u50's R0 named this head. It is **unchanged by passes 57–60**: re-measured
with a frozen pristine binary built in this pass's own worktree
(md5 `e2623a8b6ffeff31ef7276edae6951cd`, byte-identical to the main tree at the
base), one head each (`grep -c '^LHS:'` = 1), **64 cmp lines in BOTH modes**:

```
LHS (golden)                                    RHS (pristine)
constant  21:65-21:88                           constant  21:65-21:88
|vpiParent -> param_assign 21:59-21:88          |vpiParent -> param_assign 21:59-21:88
|vpiDecompile:64'b000…00100000…011              |vpiDecompile:274877906947
|vpiSize:64                                     |vpiSize:64
|BIN:000…00100000…011                           |UINT:274877906947
|vpiTypespec -> ref_typespec (work@tb.t)        |vpiTypespec -> ref_typespec (work@tb.t)
  |vpiActual -> struct_typespec (cfg_pkg::cfg_t)  |vpiActual -> struct_typespec (cfg_pkg::cfg_t)
|vpiConstType:3                                 |vpiConstType:9
```

`uhdm2rtlil/test/struct_member_cfg_width/dut.sv:36` is
`struct_member_cfg_width #(.CFG(cfg_pkg::build_config())) t (...)` over the
formal at `:21` — the g3 `u3` shape exactly. Full head at
[evidence/HEAD.struct_member_cfg_width.pristine.cmp](evidence/HEAD.struct_member_cfg_width.pristine.cmp).

**THE CELLS OF THIS LAW, AND WHERE THEY SIT.** r11u50's g3 grid, re-cut inside
this base with the pinned Surelog v1.87 (`rc=0`, 0 `[ERR`; calibration
golden-vs-golden **11 rows 0 DIFF**), reproduces its reading exactly — **9 SAME,
2 DIFF**, and both DIFFs are the OVERRIDDEN holders:

| holder | golden | pristine at `05a6c144` |
|---|---|---|
| `r50::CFG` package localparam | `BIN` ct 3, decompile BARE | same |
| `work@tb52.u2.P` module parameter, NOT overridden | `BIN` ct 3, `64'b…` | same |
| `work@tb52.u5.L` localparam reading the package one | `BIN` ct 3, `64'b…` | same |
| `work@tb52.u6.M` module localparam calling it | `BIN` ct 3, `64'b…` | same |
| **`work@tb52.u3.P` OVERRIDDEN with the same call** | **`BIN` ct 3, `64'b…`** | `UINT:274877906947` ct 9 |
| **`work@tb52.u4.P` OVERRIDDEN with `64'h0000_0020_0000_0005`** | **`HEX:0000002000000005` ct 5, `64'h…`** | `UINT:137438953477` ct 9 |

### ADVANCE vs CONVERT — predicted BEFORE the sweep, from the keyed arithmetic

**PREDICTED: ADVANCE, NOT CONVERT — LOUDLY.** The keyed constant census on the
witness (calibration golden-vs-golden **LINES 0**, `lhs_const 85`) reads **8
differing keyed shape rows** at the base, and this law owns exactly ONE of them:

```
PRISTINE lhs=2 rhs=1  owner=param_assign ts=struct_typespec size=64 tag=BIN  ct=3   <- the law's
PRISTINE lhs=0 rhs=1  owner=param_assign ts=struct_typespec size=64 tag=UINT ct=9   <- the law's
PRISTINE lhs=2 rhs=0  owner=operation    ts=NONE            size=1  tag=UINT ct=9
PRISTINE lhs=0 rhs=1  owner=operation    ts=NONE            size=3  tag=UINT ct=9
PRISTINE lhs=6 rhs=7  owner=operation    ts=NONE            size=64 tag=UINT ct=9
PRISTINE lhs=54 rhs=50 owner=range       ts=NONE            size=64 tag=UINT ct=9
PRISTINE lhs=4 rhs=2  owner=typespec_member ts=NONE         size=-
PRISTINE lhs=4 rhs=2  owner=typespec_member ts=NONE         size=32 tag=DEC  ct=1
```

Golden carries 85 constants against our 77 — **eight constants we do not have at
all**, across six rows this law does not touch. One cell cannot close that.

**MEASURED AFTER THE LAW — the prediction holds exactly.** The census drops
from 8 rows to **6**, and the two rows that vanish are the law's own pair
(BIN 1->2 = golden's 2, UINT 1->0); the other six are byte-for-byte unchanged
([evidence/CENSUS.witness.txt](evidence/CENSUS.witness.txt)). The row ADVANCES:
**64 cmp lines -> 17, both modes**, and the head moves off the encoding to a
`ref_typespec` the RHS does not have at all —

```
LHS: ref_typespec (work@tb.t.m.c.a_i.fu_data_i.operand_a)
     |vpiParent -> hier_path (fu_data_i.operand_a) 19:19-19:38
     |vpiActual -> struct_typespec (fu_data_t) 25:13-29:6
RHS: <null>
```

([evidence/HEAD.struct_member_cfg_width.law.cmp](evidence/HEAD.struct_member_cfg_width.law.cmp);
the singular-overload `RHS: <null>` names OUR missing value — RESUME §9's head
decoding.) The row stays `CMP_NOTEQUAL` in both modes and **no baseline row is
promoted**.

---

## 2. THE PRODUCER, DECODED LINE BY LINE

All four judged fields of the child's elaborated Rhs come from **one stored
`Value`**, and that Value is built from the **override actual's own compiled
constant**.

**(a) `~/git-repos/Surelog/src/DesignCompile/DesignElaboration.cpp:2163`** —
the actual is compiled in the PARENT instance with `Reduce::Yes`:

```cpp
UHDM::expr* complexV = (UHDM::expr*)m_helper.compileExpression(
    parentDefinition, parentFile, expr, m_compileDesign, Reduce::Yes,
    nullptr, parentInstance, false);
```

and at **`:2187-2188`**, when that fold is a constant, its OWN tagged value
string — not its integer — becomes the Value:

```cpp
const std::string_view v = c->VpiValue();
value = m_exprBuilder.fromVpiValue(v, c->VpiSize());
```

stored on the child at `:2271` / `:2284` / `:2328`
(`instance->setValue(name, value, ...)`).

**(b) `src/Expression/ExprBuilder.cpp:978` `fromVpiValue`** is the whole
encoding table, and it is NOT symmetric:

| tag | Value built | `vpiValType()` | `decompiledValue()` |
|---|---|---|---|
| `BIN:` | StValue `Binary` | `vpiBinaryConst` 3 | `<size>'b<bits>` |
| `HEX:` | StValue `Hexadecimal` | `vpiHexConst` 5 | `<size>'h<digits>` |
| `OCT:` | LValue **`Unsigned`** (`:1051` — there is NO Octal arm) | `vpiUIntConst` 9 | decimal |
| `DEC:` | LValue `Integer` | `vpiIntConst` 7 | decimal |
| `UINT:` / `INT:` | LValue `Unsigned` / `Integer` | 9 / 7 | decimal |

**(c) `src/Expression/Value.cpp` `StValue::decompiledValue`** renders the size
prefix itself, guarded by `(m_size && (m_size != -1))` — so an UNSIZED literal
prints its base bare (`'h1F`) and a sized one prints `64'h…`. **The `64'b…`
prefix is the Value's, not `adjustSize`'s.**

**(d) `src/DesignCompile/NetlistElaboration.cpp:514-568`** — the
`(overriden == false) && (!isMultidimensional)` arm — reads it back:

```cpp
Value* value = instance->getValue(paramName, m_exprBuilder);
...
c->VpiValue(value->uhdmValue());
c->VpiDecompile(value->decompiledValue());
c->VpiSize(value->getSize());
c->VpiConstType(value->vpiValType());
...
assign->getFileContent()->populateCoreMembers(assign->getAssignId(),
                                              assign->getAssignId(), c);
m_helper.adjustSize(tps, instance->getDefinition(), m_compileDesign,
                    instance, c);
```

`populateCoreMembers(assign->getAssignId(), ...)` is why golden's constant sits
at the DEFINITION's default-initializer span (`dut.sv:21:65-21:88`) and not at
the actual's — a location the judge does not read, and a fact that misleads if
you try to infer the producer from the span.

**(e) `src/DesignCompile/CompileHelper.cpp:4065` `adjustSize`** against a
`struct_typespec` is `SrlgTsK::Other`: the `vpiUIntConst` arm (`:4109`) masks
and re-sizes; the `vpiBinaryConst` arm finds neither a `logic_typespec` nor an
`int_typespec` target and changes nothing but the size, and its
`orig_size == -1` tail (`:4218-4241`) gives an unsized binary the target width;
everything else falls to **`:4242 c->VpiSize(size)`**. The landed
`srlgAdjustSize` already models all of that.

**(f) the literal producer, `src/DesignCompile/CompileExpression.cpp:465-565`
`compileConst`** — "*Do not evaluate the constant, keep it as in the source
text*": the base letter after the tick picks `HEX:`/`BIN:`/`OCT:`/`DEC:`, the
text before it becomes `VpiSize` (or `-1` when empty), `_` is stripped, and a
no-tick text starting with `-` is stamped `INT:` at 64 (`:554`).

**WHY THE SCALAR HALF ALREADY AGREED — and why the corpus is not full of
movers.** `clsParam8` ([src/ParamEmit.cpp:8018](../../../src/ParamEmit.cpp#L8018))
ends with `else w8 = 0; // struct/union/typedef vector: other arms own it`, and
the `ovEnc8` + `srlgAdjustSize` pipeline is gated on `tw8 > 0`. So the whole
law was already implemented for every scalar formal and switched OFF for
exactly this one formal kind, where the actual then fell to
[src/ParamEmit.cpp:10377](../../../src/ParamEmit.cpp#L10377)'s
`UINT:<digits>` at the struct width. **This pass does not invent the law; it
lifts the fence, for struct and packed-union formals only.**

---

## 3. THE GOLDEN GRID (Surelog v1.87 = golden; every arm's rc recorded)

Three grids, all `surelog rc=0`, 0 `[ERR`, our binary `rc=0`.
**Calibration golden-vs-golden FIRST: g3 11 rows 0 DIFF, g4 52 rows 0 DIFF,
g5 32 rows 0 DIFF.** Every row is one `param_assign` Rhs keyed by its Lhs
parameter's full name, so the DEF listing (`work@<mod>.P`) and the ELABORATED
listing (`work@tb.<inst>.P`) are BOTH scored — the def rows stay `func_call` on
both sides throughout and none of them moves.

### g3 — [grid/g3_asm50.sv](grid/g3_asm50.sv), r11u50's own R0 grid, 11 rows

**Pristine 9/11 -> law 11/11. BOTH overridden holders CONVERT, 0 MOVED-WRONG,
0 AWAY.** [evidence/GRID.g3.pristine.txt](evidence/GRID.g3.pristine.txt),
[evidence/GRID.g3.law.txt](evidence/GRID.g3.law.txt).

### g4 — [grid/g4_ovenc62.sv](grid/g4_ovenc62.sv), actual kind x formal kind, 52 rows

The struct half — one holder module per actual kind, so each cell is its own
elaborated `param_assign`:

| cell | override actual | golden | pristine | law |
|---|---|---|---|---|
| **u01** | `r62::build_config()` | **`BIN` ct 3 `64'b…0011` sz 64** | `UINT:274877906947` ct 9 | **converts** |
| **u02** | `64'h0000_0020_0000_0005` | **`HEX` ct 5 `64'h0000002000000005`** | `UINT` ct 9 | **converts** |
| **u03** | `64'b0…0111` | **`BIN` ct 3 `64'b…0111`** | `UINT` ct 9 | **converts** |
| u04 | `64'o…07` | `UINT:274877906951` ct 9 | same | same |
| **u05** | `64'd274877906951` | **`INT` ct 7 sz 64** | `UINT` ct 9 | **converts** |
| **u06** | `274877906953` (bare decimal) | **`UINT:274877906953`** | `UINT:9` (slang truncates >32 bits) | **converts** |
| u07 | `r62::CFG` (bare ref) | `BIN` ct 3 `64'b…` | same | same |
| u08 | `r62::CFG \| 64'h1` | `UINT` ct 9 | same | same |
| **u09** | `{32'd64, 32'd9}` | **`BIN` ct 3 `64'b…1001`** | `UINT` ct 9 | **converts** |
| u10 | `r62::cfg_t'(64'h…)` (CAST) | an **unfolded `operation`** | `UINT` ct 9 | unchanged (F3) |
| u11 | `'{XLEN:…, TID:…}` (PATTERN) | an **unfolded `operation`** | `UINT` ct 9 | unchanged (F3) |
| **u12** | `32'h15` (NARROW) | **`HEX:15` ct 5 sz 64 dec `32'h15`** | `UINT:21` ct 9 | **converts** |
| **u13** | `'h17` (UNSIZED) | **`HEX:17` ct 5 sz 64 dec `'h17`** | `UINT:23` ct 9 | **converts** |
| **u14** | `64'h…0019`, depth 1 | **`HEX` ct 5** | `UINT` ct 9 | **converts** |
| **u14.g** | the SAME re-passed `.P(P)` one deeper | **`HEX` ct 5** | `UINT` ct 9 | **converts** |
| **u16** | `64'h…001B` on a no-builder default | **`HEX` ct 5** | `UINT` ct 9 | **converts** |

u12/u13 are the cells that pin the model's two stages apart: the VALUE and
DECOMPILE are the literal's own (`32'h15`, `'h17` — the Value's rendering at
the literal's own size, or none), while `VpiSize` alone is re-rendered at the
formal's 64.

The SCALAR half — the control that says the law is a FENCE lift, not a new
rule. **All nine already agree on both sides, before and after:**

| cell | formal | actual | golden = pristine = law |
|---|---|---|---|
| v01 | `int` | `32'h20` | `HEX:20` ct 5 sz 32 `32'h20` |
| v02 | `int` | `32'd33` | `INT:33` ct 7 sz 32 |
| v03 | `logic [63:0]` | `64'h21` | `HEX:21` ct 5 sz 64 |
| v04 | untyped | `32'h22` | `HEX:22` ct 5 sz 32 |
| v05 | untyped | `35` | `UINT:35` ct 9 sz 32 |
| v06 | `int` | `r62::OPW` (an operation) | `INT:56` ct 7 sz 32 |
| v07 | `int` | `36` | `UINT:36` ct 9 sz 32 |
| v08 | `logic [1:0][31:0]` | `{32'd64, 32'd37}` | `BIN` ct 3 sz 64 |
| v09 | `logic [1:0][31:0]` | `64'h…0027` | `HEX` ct 5 sz 64 |

**Pristine 39/52 -> law 50/52, eleven cells CONVERT, 0 MOVED-WRONG, 0 AWAY.**
The two survivors are u10 and u11, both deliberate (F3).

### g5 — [grid/g5_edge62.sv](grid/g5_edge62.sv), THE FENCES, 32 rows

| cell | shape | golden | pristine | law |
|---|---|---|---|---|
| **x01** | `'b101` UNSIZED bin | **`BIN:101` ct 3 sz 64 dec `'b101`** | `UINT:5` | **converts** |
| x02 | `'o27` UNSIZED oct | `UINT:23` ct 9 sz 64 | same | same |
| **x03** | `'d29` UNSIZED 'd | **`INT:29` ct 7 sz 64** | `UINT:29` ct 9 | **converts** |
| **x04** | `'h1F` UNSIZED hex | **`HEX:1F` ct 5 sz 64 dec `'h1F`** | `UINT:31` | **converts** |
| **x05** | `64'sh…0031` SIGNED base | **`HEX` ct 5** | `UINT` ct 9 | **converts** |
| x06 | `128'h…` on a **128-bit** struct | `HEX` ct 5 sz 128, the LITERAL's digits | `HEX` sz 128, digits re-rendered | unchanged (F5 / R1) |
| x07 | `31` bare decimal | `UINT:31` ct 9 sz 64 | same | same |
| **x08** | `-1` | **`INT:-1` ct 7 sz 64** | `UINT:18446744073709551615` | **converts** |
| **x09** | `build_arg(32'd35)` (builder WITH an argument) | **`BIN` ct 3** | `UINT` ct 9 | **converts** |
| **x10** | `64'h…003D` inside a **GENERATE block** | **`HEX` ct 5** | `UINT` ct 9 | **converts** |
| **x12** | `32'h1000_0037` on a struct with an **ENUM member** | **`HEX` ct 5 sz 32** | `UINT` ct 9 | **converts** |
| **x13** | `32'h39` on a **packed UNION** formal | **`HEX` ct 5 sz 32**, ts `union_typespec` | `UINT` ct 9 | **converts** |
| x14 | `r62e::CFG` bare ref | `BIN` ct 3 | same | same |
| x15 | `LC`, a LOCALPARAM hop to it | `BIN` ct 3 | same | same |
| **x16** | `64'h…003B` plain control | **`HEX` ct 5** | `UINT` ct 9 | **converts** |

**Pristine 21/32 -> law 31/32, ten cells CONVERT, 0 MOVED-WRONG, 0 AWAY.** The
one survivor is x06 (F5 / R1).

**COMBINED: 95 rows, pristine 69 right -> law 92 right, +23, 0 MOVED-WRONG,
0 AWAY-GOLDEN.** Scores at [evidence/GRID.g4.*.txt](evidence/) and
[evidence/GRID.g5.*.txt](evidence/), read by the ENCODING-AWARE lister
(`shape62.py --rows` prints `ct`, the FULL value and the decompile — the r11u61
lesson; the r11u50 reader truncates at 24 characters and would have hidden
x06's digit difference entirely).

---

## 4. WHAT WAS WRITTEN

One file-local helper, one arm at one site, **no line of behaviour removed**.

* [src/ParamEmit.cpp](../../../src/ParamEmit.cpp) — `ovActualLitEnc62`, the
  producer stage, placed directly below `srlgLitEnc`. It DEFERS to `srlgLitEnc`
  (which is shared by every scalar override site and is not touched) and adds
  only the two spellings that one deliberately refuses: the UNSIZED based
  literal and the NEGATIVE bare decimal.
* [src/ParamEmit.cpp](../../../src/ParamEmit.cpp) — the arm, immediately after
  the `tw8 > 0` `ovEnc8` block, gated on a PackedStruct/PackedUnion formal of
  1..64 bits under `overridden && boundInit && typedParam`. It admits four
  actual shapes and hands each to the LANDED `srlgAdjustSize` at
  `SrlgTsK::Other`, then applies `adjustSize`'s `orig_size == -1` tail (which
  `srlgAdjustSize` does not carry). It sets `srcBaseOv8`, the flag the rest of
  the chain already reads as "already stamped".
* [include/UhdmExporter.h](../../../include/UhdmExporter.h) — the declaration
  block's law paragraph.

**The composition with the landed encoding laws is by DEFERRAL, not by
argument.** Pass 49's `'d` abstention and the pass-55/56 encoding laws live on
the substituted-package-parameter side (`pkgSubstIntEnc50` and friends), which
this arm never reaches; here the `'d` answer is `INT` ct 7 and it is measured
on golden four times (g4 u05, g5 x03, plus the scalar controls v02 and
`srlgLitEnc`'s own landed `8'd5 -> INT:5` cell). The reduce-table calls are not
fought: `ovRedIsInt73`'s operator arm still owns every BinaryOp/UnaryOp actual
and this arm declines them (F4).

### The fences, each a measured golden cell

| # | shape | why declined |
|---|---|---|
| F1 | a NamedValue actual (bare ref, localparam hop) | § elabOvRefAsmBinConst / § asmEncFollowsRef already golden (g5 x14/x15) — EXCEPT the one encoding nobody owned, a `vpiHexConst` source, which this arm claims for the re-pass (g4 u14.g) |
| F2 | a MemberAccess actual | § structParamMemberOvBinary's BIN slice at the MEMBER's width |
| F3 | an explicit CAST, an ASSIGNMENT PATTERN | golden leaves an UNFOLDED `operation` (g4 u10/u11); folding our constant there moves a wrong cell to a DIFFERENTLY wrong one — the r11u50 R1 refusal |
| F4 | a BinaryOp / UnaryOp actual | already golden `UINT` (g4 u08) |
| F5 | a formal wider than 64 bits | golden wants the literal's own digits; the existing wide arm re-renders from the value (g5 x06). Same law, different renderer — R1, not claimed |

---

## 5. CENSUS, PREDICTION AND GATES

### The a-priori mover prediction, and the subset argument

[predict62.py](predict62.py) reads only SOURCES. A test is a candidate when it
declares a module parameter whose TYPE is a user-defined name (the only way to
spell a packed struct/union formal) AND that parameter is overridden anywhere.
It is a SUPERSET three ways over: it never checks that the named typedef really
is a packed struct, never checks the ACTUAL's shape (a bare-decimal or
NamedValue actual is already golden and cannot move), and never checks that the
override is reached by elaboration.

*Positive control:* run on the three grids it names **every** module whose cell
moves — `h3`, `h4` (g3); `s01`–`s16` (g4); `e01`–`e16` (g5) — and does not name
the package localparam holders `r50::CFG` / `r62::CFG` or the module-localparam
holders `h5`/`h6`, whose cells do not move.

*Predicted, BEFORE the sweeps:*
**u2r — a subset of 34 tests**, `struct_member_cfg_width` among them
([evidence/PREDICT.u2r.txt](evidence/PREDICT.u2r.txt)).
**surelog — a subset of 39 tests**, the canary **`Earlgrey_0_1` among them**
(`flash_ctrl_pkg` parameters of typedef'd types, overridden), so its hard byte
pin was the risk this pass carried
([evidence/PREDICT.sl.txt](evidence/PREDICT.sl.txt); one fenced name the scan
matched is REDACTED by the predictor itself, which reads the fence list out of
`canaudit.sh` — the auditor is the one file licensed to hold it. Nothing is
dispatched by this script: it opens no database and runs no binary).

*Measured:*
**u2r MOVERS 2 / 1608 — `struct_member_cfg_width`, both modes, and nothing
else. surelog MOVERS 3 databases / 4 arms out of 960 — `MiniAmiq` (both modes),
`Scoreboard/default`, `SeqDriver/default`, none of them a predicted candidate.**
Both are subsets. **`Earlgrey_0_1` did not move a byte in either mode.**

### Mover attribution (order-blind: `uhdm-dump` | workdir-normalised | sort)

Both `struct_member_cfg_width` databases carry a **nonzero size delta**
(25108 -> 25184 default, 20197 -> 20273 testflags), so the MOVER RULE convicts
them as real; no 4096-multiple is involved and the page-boundary control is not
needed. The sorted diff is **three lines each**, and they are the law's own
cell:

```
<  |UINT:274877906947           >  |BIN:0000…0100000…0011
<  |vpiConstType:9              >  |vpiConstType:3
<  |vpiDecompile:274877906947   >  |vpiDecompile:64'b0000…0100000…0011
```

which is golden's cell exactly. **TO-GOLDEN 2, AWAY-GOLDEN 0, STILL-WRONG 0.**

The four surelog arms are the documented per-invocation UVM coin: a 0-or-4-line
`UINT`/`vpiDecompile` **LINE-NUMBER** pair moving BOTH ways (1449<->933,
0<->710, 838<->0) plus `Scoreboard`'s 0-line draw.
**POSITIVE CONTROL, and it is decisive:** the same frozen pristine binary, run a
second time from each sweep's own `cmds.txt`, lands `default/Scoreboard` on
`1621aec6c9f3` — **the very hash the LAW binary produced** — and both `MiniAmiq`
arms on hashes NEITHER sweep produced (`3f0f8ce7c3de`, `d85b9562a0a2`), while
`default/SeqDriver` returns to the pristine sweep's `2fb39f8b4130`. Full tables
at [evidence/MOVERS.attribution.txt](evidence/MOVERS.attribution.txt) and
[evidence/POSCTL.coin.txt](evidence/POSCTL.coin.txt).

### The keyed census, and the SHAPE LISTER beside it

[shape62.py](shape62.py) keys every `constant` by (owner kind, the typespec it
refers to, `vpiSize`, value tag, `vpiConstType`) — the five fields
`constant::Compare` turns on here — and its `--shape` mode prints, for every
key, a representative **FULL value AND decompile** beside the count.
[census62.sh](census62.sh) runs it over a named candidate set, **calibration
golden-vs-golden first on every test**, then golden-vs-pristine and
golden-vs-law.

* **u2r, all 34 predicted candidates, BOTH modes**
  ([evidence/CENSUS.u2r.testflags.txt](evidence/CENSUS.u2r.testflags.txt),
  [evidence/CENSUS.u2r.default.txt](evidence/CENSUS.u2r.default.txt)):
  **29 scored, calibration 0 on every one, TO-GOLDEN 1, AWAY-GOLDEN 0**; the
  one is `struct_member_cfg_width` at −2 keyed shape rows. The 5 skipped are
  pre-existing `SLANG_REJECT` rows whose CSV detail strings are byte-identical
  on both binaries.
* **surelog:** 956 of the 960 databases are **byte-identical** under the law, so
  every keyed census over them is identically zero by construction; the four
  that are not are named, attributed and positive-controlled above.
* Shape listers: [evidence/SHAPES.struct_member_cfg_width.golden.txt](evidence/SHAPES.struct_member_cfg_width.golden.txt),
  [evidence/SHAPES.g4.golden.txt](evidence/SHAPES.g4.golden.txt).

### The gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `e2623a8b6ffeff31ef7276edae6951cd` — **byte-identical to the main tree at `05a6c144`**; law `5fc453cd3a119cc5de0debfa68714d63`. (`ParamEmit.cpp`'s `__LINE__` uses are `doBail(__LINE__)`, read back only by a `dbg9`-gated `fprintf`, so the shifted values never reach a database; the header's comment-only edit left the law md5 unchanged, so every gate below describes exactly the patch's binary.) |
| (2) goldens | `PASS=23 FAIL=0`; `SLANG_UHDM=/bin/false` -> `PASS=0 FAIL=23` |
| (3) u2r both modes | `786 CMP_EQUAL / 18 CMP_NOTEQUAL / 67 SLANG_REJECT` x2, every row **byte-identical** to `results/gate_uhdm2rtlil.csv`, to `results/golden_uhdm2rtlil.csv` (both modes — its extra half is the only thing the single-mode join calls "moved", and my PRISTINE sweep's join output is byte-identical to the law's) and to my own pristine sweep in both modes |
| (4) surelog `--mode both` | `474/9` default + `469/8` testflags, status histograms identical to `results/golden_surelog.csv` and to my pristine sweep. Law-vs-pristine differs in exactly **two** row-sides: the `SURELOG_FAIL` detail strings that quote the WORKDIR PATH (`LowMemLib`, `LowMemPkg`). Against the committed baseline there are two more: `Earlgrey_0_1`'s DUMP COLUMN reads blank in both modes — the documented `uhdm-dump` timeout draw, which **my pristine sweep reads identically**; status stays `CMP_EQUAL` and the DATABASE byte pins hold |
| (5) byteverify SELFCHECK=1 | u2r `MOVERS 2/1608`, SELFCHECK `1607/1608` flagged; surelog `MOVERS 4/960`, SELFCHECK `959/960`; `PATH_SETS_IDENTICAL` both |
| canaries | `ok=8 changed=0 absent=0` (u2r); `ok=50 changed=2` (surelog) where the two are `Earlgrey_0_1`'s blank dump column and **my pristine sweep scores `ok=50 changed=2` too**; `ctcan2` PASS x2; `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| rowheads | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg / Earlgrey_0_1 all `0 lines 0 heads`; Rggen `64 lines 1 head` (unchanged) |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 default `8bdf25272e08` / testflags `59d0ee6d10c3`, BlackParrotComplex and YosysOldOr — every one identical to pristine, and every hard pin at its OPS value |
| UVM family | BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard all still `CMP_EQUAL` |
| landed conversions | `iface_zero_width_field` still `CMP_EQUAL` in both modes |

`results/*.csv` untouched. **No row converts, so no baseline row is promoted.**

---

## 6. RESIDUES, and R0

* **R0 — THE WITNESS'S NEW HEAD: A `hier_path`'S MISSING `ref_typespec`.**
  `struct_member_cfg_width` `dut.sv:19` `inner c (.a_i(fu_data_i.operand_a))`.
  Golden's elaborated `hier_path (fu_data_i.operand_a)` carries a
  `ref_typespec (work@tb.t.m.c.a_i.fu_data_i.operand_a)` whose `vpiActual` is
  the **`struct_typespec (fu_data_t)`** declared at `:25`; ours carries none at
  all (`RHS: <null>`, the singular-overload form). 17 cmp lines, one head, both
  modes. It is the test's stated subject — "*struct member access where
  fu_data_t fields have function-computed CVA6Cfg.FIELD widths*" — and the row's
  remaining six keyed census rows (4 `range` and 2 `typespec_member` pairs
  golden has and we do not, plus three `operation` rows) live under it, so this
  is the next question and probably most of the rest of the row.

* **R1 — THE >64-BIT FORMAL'S DIGITS (g5 x06), the SAME law one width up.**
  `128'h0000_0000_0000_0040_0000_0000_0000_0033` on a 128-bit packed-struct
  formal is golden `HEX` ct 5 size 128 with the LITERAL'S OWN digits
  (`00000000000000400000000000000033`); the existing `typedParam &&
  iv.getBitWidth() > 64` arm at
  [src/ParamEmit.cpp:10238](../../../src/ParamEmit.cpp#L10238) re-renders from
  the value and drops the leading zeros (`400000000000000033`). The decode is
  the same `compileConst` rule already written above — what is missing is
  letting that arm read the literal's text, which the landed `wideBaseOv8`
  already does for UNTYPED formals. Deliberately declined this pass: the arm is
  shared with every non-struct >64-bit typed formal (`LargeHexString`), so it
  needs its own grid and its own boundary.

* **R2 — THE CAST AND THE PATTERN GOLDEN DOES NOT FOLD (g4 u10, u11).**
  `#(.P(cfg_t'(64'h…)))` and `#(.P('{XLEN:…, TID:…}))` keep an UNFOLDED
  `operation` in golden's elaborated `param_assign` where we substitute a
  constant. That is a FOLD question, not an encoding one — the same shape
  pass 57/58/60 have been working from the other side — and it is pre-existing,
  untouched, and a different family's road.

* **R3 — `srlgLitEnc`'s unsized refusal is now split across two helpers.**
  `ovActualLitEnc62` models the unsized based literal for the struct site only,
  because the SCALAR sites' unsized behaviour (`adjustSize`'s `orig_size == -1`
  tail under a `logic` / `int` target, and the `'1` mask rewrite) is not
  measured. Not a residue of this law's cells — a note for whoever widens it.

---

## 7. REPRODUCING

```bash
# the grids (CALIBRATE golden-vs-golden FIRST; every arm's rc recorded)
cd <scratch> && cp <repo>/tools/probe/r11u62repro/grid/g4_ovenc62.sv .
cp <repo>/tools/probe/r11u62repro/{shape62.py,asmread50.py,cenc50.py} .
~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv -d uhdm g4_ovenc62.sv
$SLANG_UHDM g4_ovenc62.sv --single-unit -o ours.uhdm
uhdm-dump slpp_all/surelog.uhdm > g.raw; uhdm-dump ours.uhdm > o.raw
python3 shape62.py --rows g.raw g.raw | tail -1      # CALIBRATION: DIFF 0
python3 shape62.py --rows g.raw o.raw                # the grid, FULL values
# g3 and g5 are the same; g3 is r11u50's own R0 grid, carried forward unchanged

# the keyed census + the SHAPE LISTER
python3 shape62.py g.raw g.raw CALIB        # must print LINES 0
python3 shape62.py g.raw o.raw <test>
python3 shape62.py --shape g.raw

# the census over a named candidate set, both modes
bash census62.sh testflags <lawWorkdir> <prisWorkdir> names.txt <outdir>

# the a-priori prediction and its positive control
python3 predict62.py ~/git-repos/uhdm2rtlil/test
python3 predict62.py --files grid/g3_asm50.sv grid/g4_ovenc62.sv grid/g5_edge62.sv
```
