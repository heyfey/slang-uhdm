# r11u81 — the hop parameter hands on its own typespec, and where it has none it hands on an empty ref

**FOUR TYPESPEC FACES, ONE LAW, AND NONE OF THEM IS THE CAST: a pattern
operand that is a reference to an UNTYPED PACKAGE parameter carries that
parameter's typespec — the untyped switch's answer on its stored value's
ENCODING — a signedness cast on its `return c` face hands whatever rode out of
its argument straight on, and where the switch has no arm and nothing rode up
golden still hangs a `ref_typespec` with NO actual.**

Base `f25df07e`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden in this directory is a real Surelog
v1.87 run through the committed `run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`; **all 34 grid arms and all 22 boundary arms read `0 0 0`
on both binaries**.

| binary | md5 | what |
|---|---|---|
| pristine | `87f32e6a31b52cd5b7766f0b8bcc731a` | built in this pass's own worktree at `f25df07e` — **byte-identical to the main tree's `build/slang-uhdm`** |
| law | `213d8d6a3e321e72f8d09d8a7a56c796` | this patch |

Both frozen `chmod 555` before any sweep; every `cmds.txt` audited by absolute
binary path (1742 u2r + 1531 surelog per binary, **0 naming the main tree**).

---

## 0. AN INSTRUMENT ADDITION — THE LISTER IS BLIND ON THE FIELDS THIS LAW WRITES

r11v78's RV-3 recorded it and this pass is the one that trips over it:
**`uhdm-dump` prints NO children under an `int_typespec` on the constant-operand
visitor path**, so neither `vpiSigned` nor `Ranges` is visible there — while
`int_typespec::Compare`
(`~/git-repos/UHDM/build/generated/src/int_typespec.cpp:97-113`) READS
`Cast_to_expr`, `VpiSigned` **and** `Ranges`. The committed `ts78.py` renders
golden's unsigned unranged `int_typespec` and a signed ranged one identically.
A grid scored from the dump alone would have called this pass's writes
conversions without ever reading the two fields that decide them.

`ts81probe.cpp` closes that. It opens a database through the UHDM library and
prints, per `param_assign` whose Rhs is an operation, one line per operand with
`vpiSize` / `vpiConstType` / `VpiValue` / `VpiDecompile` **and** the typespec
chain — the actual's kind, its `VpiSigned`, and its `Ranges` with each bound
constant's own `VpiValue` / `vpiConstType` / `vpiSize` / `VpiDecompile`.
`score81.py` scores TO / AWAY / STILL / WRONG2 / EQ off those strings and
reports a SHAPE mismatch separately. MEASUREMENT ONLY; the acceptance judge
stays `uhdm-cmp`.

```
  build: g++ -O1 -std=c++20 ts81probe.cpp -o ts81probe \
             -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
```

**THE SCORER'S OWN POSITIVE CONTROL.** Scoring `a1_hopts81` with the two
binaries SWAPPED turns all ten of its TO cells into AWAY cells and TO to 0.
`AWAY=0` below is a measurement, not a blind spot.

---

## 1. THE PRODUCER, LINE BY LINE

### 1.1 Who hands the typespec on

`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:2973-2995` (and
its ModuleInstance twin at `:2919-2930`) substitutes a reference to a parameter
with a clone of that parameter's stored `Rhs` and then:

```cpp
typespec *tps = nullptr;
const any *lhs = param_ass->Lhs();
... if (lhs->UhdmType() == UHDM::uhdmparameter) {
      if (ref_typespec *lhs_rt = ((UHDM::parameter *)lhs)->Typespec())
        tps = lhs_rt->Actual_typespec();
    }
expr *res = (expr *)result;
if (tps && (res->Typespec() == nullptr)) {
  ref_typespec *tps_rt = s.MakeRef_typespec();
  tps_rt->VpiParent(res);  tps_rt->Actual_typespec(tps);  res->Typespec(tps_rt);
}
```

Two facts this law is built on: the hand-on is **gated on the constant having
no typespec of its own**, and the `ref_typespec` it makes carries no `VpiName`
and no `VpiDefName` — the two fields `ref_typespec::Compare` reads before
recursing into the actual. Our write is field-for-field that object.

### 1.2 What an UNTYPED parameter's typespec is

`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3904-3995`, reached
only when the declaration had no type (`if (ts == nullptr)`), switches on the
reduced value's `VpiConstType`:

| arm | line | what it makes |
|---|---|---|
| `vpiDecConst` | `:3922-3924` | **nothing** — an empty `case` that breaks |
| `vpiIntConst` | `:3925-3941` | `int_typespec`, `VpiSigned(false)`, no ranges |
| `vpiHex/Oct/Binary` | `:3942-3968` | the same **plus a `[VpiSize-1:0]` RANGE**, and ONLY when `c->VpiSize() != -1` |
| `vpiUIntConst` | `:3969-3982` | `int_typespec`, `VpiSigned(false)`, no ranges |

The `vpiIntConst` arm looks as if it signs a negative value:

```cpp
its->VpiSigned(false);
const std::string_view v = c->VpiValue();
if (v.front() == '-') its->VpiSigned(true);
```

but `VpiValue()` is the whole `"INT:-5"` string, so `front()` is `'I'` and the
test **never fires**. `VpiSigned` is `false` on every arm — a producer quirk
the judge reads and the dump cannot show, and `ts81probe` confirms it directly
on golden: `a1_hopts81` op8 is `localparam PN = -5` one hop up, golden
`INT:-5` with `int_typespec/U`.

The range's two bound constants carry **only** `VpiValue` (`"INT:<size-1>"` and
`"INT:0"`) — no `vpiConstType`, no `vpiSize`, no `VpiDecompile` — and the
`range` itself no `VpiSize`. `range::Compare` reads `VpiSize` + `Left_expr` +
`Right_expr`, and `expr`/`constant::Compare` under it read `VpiDecompile`,
`VpiSize`, `Typespec` and `vpiConstType`, so those unset fields are judge-read
and must stay unset. `ts81probe` prints golden's as
`[INT:15/ct0/sz0:INT:0/ct0/sz0@sz0]`, and the law's identically.

### 1.3 What a signedness cast does to it

`~/git-repos/UHDM/templates/ExprEval.cpp:4682-4781`. On the `return c` /
`result = c` faces nothing is created and the argument's constant — typespec
included — comes out. On the `$signed` faces the arm attaches a signed
`logic_typespec` behind a `ref_typespec`: at `:4700-4711` **only when
`!c->Typespec()`**, and at `:4763-4770` unconditionally to a constant it has
just minted. `$unsigned` attaches nothing on either face, and its negative
`vpiIntConst`/`vpiDecConst` arm at `:4713-4731` mints a bare `UINT:`.

That `!c->Typespec()` gate is what makes `signed'(16'd5)` and `signed'(UD)`
different golden answers: the literal's constant has no typespec so the hint is
minted (`z1_ts78` op1/op11, `logic_typespec/S`), while the NAME's substitution
already left a `ref_typespec` behind — empty or not — so the mint refuses
(`a2_castts81` op8/op18, `ref()/NOACTUAL`).

### 1.4 Which casts the producer folds at all

`reduceExpr`'s `vpiCastOp` arm (`ExprEval.cpp:4185-4306`) answers **five**
target typespecs — `int`, `long_int`, `bit`, `short_int`, `integer` — and
Surelog gives a SIZE cast an `integer_typespec` carrying the width, which is
one of them. `byte` is not: measured, `a3_hopbnd81` op4,
`localparam WC4 = byte'(5)` is golden an **unfolded `op67`** where `int'(3)`
beside it is golden `const/32@9=UINT:3` carrying the hop's `int_typespec`.

### 1.5 Which SCOPE the hop must live in

Surelog reaches a parameter's value by two different routes. A PACKAGE
parameter goes through `CompileExpression.cpp:920-955`, whose
`pack->getParam_assigns()` loop CLONES the stored `param_assign` Rhs and
carries its typespec; a MODULE instance parameter goes through the simple
Value store at `:962-985`, which MINTS a fresh constant and attaches a
typespec only when `sval->isSigned()`.

MEASURED, arm `a4_posmod81`, eight patterns over the same two spellings `1`
and `4'h5`:

| hop home | pattern | keyword | golden |
|---|---|---|---|
| module | POSITIONAL | `parameter` | `ts=-` on all four operands |
| module | NAMED | `parameter` | `ts=-` |
| module | POSITIONAL | `localparam` | `ts=-` |
| module | NAMED | `localparam` | `ts=-` |
| package | NAMED | `localparam` | `int_typespec` (+range on the hex) |
| package | POSITIONAL | `localparam` | `int_typespec` (+range on the hex) |

— and the four module instances that RECEIVE those six as `.R(...)` carry
exactly what their source carried. So the discriminator is the HOP'S HOME,
not the pattern's form and not the `parameter`/`localparam` keyword.

**THE COST OF NOT HAVING THIS GATE WAS MEASURED, NOT ARGUED.** The first cut
of this law took the surelog row `ParamOverloading`
(`parameter v1 = 1; … '{v1, v2}` in a module) from CMP_EQUAL to CMP_NOTEQUAL
in BOTH modes, with `uhdm-cmp`'s head reading `LHS: <null>` against our added
`int_typespec`. With the gate it reads `0 cmp lines / 0 heads` in both modes
again.

### 1.6 The one thing NOT settled from the sources

The empty `ref_typespec` itself. Its CONTENT is settled (there is nothing to
point at: `:3922`'s empty case, `:3946`'s unsized guard), and its SHAPE is
measured on eight golden cells across four arms — but the exact line that mints
the actual-less container was not found in the pinned trees: both substitution
sites are gated on `tps` being non-null. It is transcribed from measurement,
with the rule ("a package NAME always leaves a `ref_typespec` behind") holding
on every cell in §3 and refuted by none. **Residue RV-1.**

---

## 2. THE LAW

### § hopStoreHandsOnItsTypespec81 — `src/ParamEmit.cpp`, written LAST

A walk over the setter expression of each elaborated struct-pattern operand,
plus one write:

```
walk(e):
  a signedness cast   -> r = walk(its argument)
                         r != NOTHING -> r          (the `return c` face)
                         $signed      -> ANSWER logic_typespec/S   (the mint hint)
                         $unsigned    -> NOTHING
  an `s`-marked based literal -> ANSWER int_typespec/S  (the literal's own)
  any other literal / operation -> NOTHING
  a NAME to a parameter ->
        s = that parameter's OWN store      (PACKAGE + implicit type only)
        s answered        -> s
        s has no arm      -> r = walk(its initializer)
                             r is an ANSWER -> r
                             otherwise      -> ANSWER Ts81Empty (a ref, no actual)
  anything else -> ABSTAIN
```

and the write, gated on the operand being a `constant` that **carries no
typespec** — the producer's own gate — and on the producer's reduce having
produced a constant at all:

```cpp
if (c81->Typespec()) continue;                       // ADD-ONLY
int64_t rf81 = 0;                                    // golden must have a CONSTANT here
if (patAstRefuses68(*sx81) ||
    red72Int64(*sx81, ectx, 0, rf81) == Red72::Refuses) continue;
if (red81HopPlan81(*sx81, 0, k81, a81) != 1) continue;
auto* rt81 = s.MakeRef_typespec();  rt81->VpiParent(c81);
if (UHDM::typespec* at81 = red81MakeStoreTs81(k81, a81))
    rt81->Actual_typespec(at81);
c81->Typespec(rt81);
```

The two refusal readers are § `patBailStopsMemberStamp68`'s own, reused rather
than copied: where the producer's reduce refuses, golden keeps the OPERATION
and our walk has already folded a constant into the slot (r11u78's R5), and a
typespec written there would decorate a cell whose very KIND golden disagrees
with. Measured, `w7_untw73` `C` op2/op3 (`96'h1 + 96'h1` and
`64'd18446744073709551614 - 64'd1`, golden unfolded `operation`s) — three
such cells the wide boundary caught and this guard withdrew.

**THE ORDER INSIDE A NAME IS MEASURED, NOT ASSUMED.** The hop's own store is
asked FIRST: `localparam SH = 16'sh5` one hop up is golden the HOP's
**unsigned, ranged** `int_typespec` and not the `s`-marked literal's signed one
(`a3_hopbnd81` op8, `z1_ts78` op6/op8/op10), while `localparam PSD = 16'sd5`,
whose `vpiDecConst` arm is empty, IS the literal's (`a1_hopts81` op2). Both
readings are byte-identical between golden and BOTH our binaries already —
which is this order's positive control, because our own literal path writes
that object.

**THE POSITION IN THE FILE.** The loop runs AFTER
§ `patBailStopsMemberStamp68` (which reads `vpiConstType` and never `Typespec`)
and AFTER § `castOperandCarriesItsTypespec78`, under the same `!Typespec()`
gate. Where both laws would fire, the cast's answer is golden's:
`signed'(16'd5)` one hop up is golden the cast's `logic_typespec`, not the
hop's. Running second transcribes that.

### THE ABSTENTIONS, each with a golden cell proving it is needed

| abstention | the cell |
|---|---|
| a MODULE-homed hop | §1.5 — four `a4_posmod81` patterns, and the `ParamOverloading` regression |
| a DECLARED type, **every one of them** | §2.1 below |
| an implicit parameter WITH a packed dimension | `a3_hopbnd81` op14, `[7:0] PDIM` is golden `int_typespec/U` whose `Ranges` bounds are FULLY formed constants (`UINT:7/ct9/sz64/d7`) — a different range shape from the untyped switch's bare `INT:7/ct0/sz0` |
| a `$signed` MINT over b/o/h/UInt | `a2_castts81` op13 vs op1: `signed'(16'h5)` written DIRECTLY is golden `logic_typespec/S` and one hop up is golden the hop's `int_typespec/U` — one spelling, two answers, and the hop's is covered by the store arm |
| a cast the producer does not FOLD | `a3_hopbnd81` op4, `byte'(5)` is golden an operation |
| a cast whose argument `get_value` cannot read | `v3cast76` op8, `unsigned'(96'hFFFFFFFFFFFFFFFFFFFFFFFF)` is golden an unfolded `sys_func_call` (§ `castSignCastNeedsAValidRead76v`, `ExprEval.cpp:1969/:1984/:1998`) |
| an operand the producer's reduce refuses | `w7_untw73` `C` op2/op3 |

### 2.1 LAW C IS DROPPED WHOLE

r11u78's R3 — a declared-type argument under a cast — is real:
`signed'(TB)` over `localparam byte TB = 8'd5` is golden `byte_typespec`
(signed), and a bare `localparam int TI = 5` one hop up is golden
`int_typespec` (signed); both measured here, `a2_castts81`
op10/op19/op21/op22. But the wide boundary measured three more declared-type
faces that answer DIFFERENTLY, and no rule this pass can cite separates them:

```
  `localparam int PK = 11`,  '{p: qq::PK, …}  in the same package
      -> golden NOTHING                        (v1_ofire68 C_pkgref op0)
  `localparam int unsigned BIG = 300`, '{M: pk::BIG, …} in a MODULE
      -> golden NOTHING                        (xv7_overridepkg MBASE op0)
  `localparam int K = 6`,    '{p: signed'(K), …}
      -> golden the $signed MINT's logic_typespec, NOT K's
                                               (b2_faces68 C_csgn/C_dssgn op0)
  `localparam logic [95:0] PW = 96'd12`, '{p: qq::PW, …}
      -> golden PW's logic_typespec WITH its ranges
                                               (v1_ofire68 C_pkgparm op0)
```

A package-QUALIFIED spelling and a cast between the name and the member each
flip the answer, and a `logic` vector flips it back. Writing here cost **two
AWAY cells** on the wide boundary, so LAW C is dropped — and it is droppable
alone: `red81ParamStore81`'s declared-type tail is the only place it wrote.
Cost: four TO cells. **Residue RV-2.**

---

## 3. THE GOLDEN GRID

Four new arms (`a1_hopts81` hop-encoding × depth, `a2_castts81` cast × hop ×
declared type, `a3_hopbnd81` the boundaries, `a4_posmod81` the scope
discriminator) beside every committed r11u73 / r11u76 / r11v76 / r11u78 /
r11v78 arm — 34 arms, 1576 operand cells. Read with `ts81probe` on the real
databases.

`a1_hopts81` — golden ↔ pristine ↔ law (24-bit members, operand 0 a
guaranteed bail):

| # | member | golden | pristine | law |
|---|---|---|---|---|
| 1 | `PD = 16'd5` | `DEC:5@16` **`ref()/NOACTUAL`** | `ts=-` | **golden's** |
| 2 | `PSD = 16'sd5` | `DEC:5@16` `int_typespec/S` | the same | unchanged — EQ on both binaries |
| 3 | `PH = 16'h5` | `HEX:5@16` `int_typespec/U[INT:15:INT:0]` | `ts=-` | **golden's** |
| 4 | `PO = 16'o5` | `OCT:5@16` `int_typespec/U[INT:15:INT:0]` | `ts=-` | **golden's** |
| 5 | `PB = 16'b101` | `BIN:101@16` `int_typespec/U[…]` | `@24` re-encoded, `ts=-` | typespec golden's, the value still r11u66's residue |
| 6 | `PU = 5` | `UINT:5@32` `int_typespec/U` | `ts=-` | **golden's** |
| 7 | `PA = 16'd9+16'd1` | `INT:10@32` `int_typespec/U` | `ts=-` | **golden's** |
| 8 | `PN = -5` | `INT:-5@32` `int_typespec/U` | `ts=-` | **golden's** (`/U`, not `/S` — §1.2) |
| 9 | `PC = 16'(5)` | `UINT:5@32` `int_typespec/U` | `ts=-` | **golden's** |
| 10 | `PUN = 'h5` | `HEX:5@-1` **`ref()/NOACTUAL`** | `@32`, `ts=-` | typespec golden's |
| 11 | `PH2 = PH` (depth 2) | `HEX:5@16` `int_typespec/U[…]` | `ts=-` | **golden's** |
| 12 | `PD2 = PD` (depth 2) | `DEC:5@16` **`ref()/NOACTUAL`** | `ts=-` | **golden's** |
| 13 | `PA2 = PA` (depth 2) | `INT:10@32` `int_typespec/U` | `ts=-` | **golden's** |
| 14-17 | `16'd5` / `16'h5` / `16'(5)` / `16'd9+16'd1` DIRECT | `ts=-` | `ts=-` | **unchanged — no hop, no store, nothing to hand on** |

`a2_castts81` — the cast faces:

| member | golden | law |
|---|---|---|
| `unsigned'(16'd5)` one hop up | `ref()/NOACTUAL` | **golden's** (r11u78's R1) |
| `signed'(UD)` one hop up, and written DIRECTLY | `ref()/NOACTUAL` | **golden's** |
| `unsigned'(UH)` one hop up | `int_typespec/U[INT:15:INT:0]` | **golden's** |
| `signed'(TI)` one hop up | `int_typespec/U` (the hop's store over the MINT) | **golden's** |
| `unsigned'(TS)` one hop up | `int_typespec/U` (the hop's store, NOT `short_int`) | **golden's** |
| `signed'(TB)` / `TB` / `TI` (declared types) | `byte_typespec/S` / `int_typespec/S` | **declined — §2.1** |
| `signed'(16'h5)` / `signed'(5)` DIRECT | `logic_typespec/S` | unchanged — § castOperandCarriesItsTypespec78 already writes it |
| `unsigned'(-8'sd100)` / `unsigned'(16'd5)` DIRECT | `ts=-` | **unchanged** |

`a3_hopbnd81` — the boundaries: `16'(5)`, `int'(3)`, `PH+1`, `8'h5`
(`[INT:7:INT:0]`), `64'hF` (`[INT:63:INT:0]`), a depth-3 chain and
`signed SG` (`int_typespec/S`) all convert; `'d5`'s empty ref converts;
`16'sh5`, `logic [7:0]`, `bit`, `[7:0] PDIM` and `byte'(5)` are the
abstentions above.

`a4_posmod81` — the scope grid: all 12 PACKAGE-homed operand cells convert,
all 16 MODULE-homed ones are EQ and untouched.

### THE SCORE, on every judge-read field including the two the dump hides

```
  a1_hopts81   TO=10 AWAY=0 STILL=1  WRONG2=2  EQ=25    a2_castts81 TO=4 AWAY=0 STILL=6 WRONG2=11 EQ=29
  a3_hopbnd81  TO=7  AWAY=0 STILL=5  WRONG2=3  EQ=20    a4_posmod81 TO=12 AWAY=0 STILL=0 WRONG2=0 EQ=16
  v3cast76     TO=5  AWAY=0 STILL=3  WRONG2=1  EQ=29    x9c_cast73  TO=2 AWAY=0 STILL=0 WRONG2=0  EQ=10
  z1_ts78      TO=4  AWAY=0 STILL=3  WRONG2=0  EQ=37    y3_castenc76 TO=4 AWAY=0 STILL=2 WRONG2=5 EQ=33
  y5_paren76   TO=2  AWAY=0 STILL=2  WRONG2=2  EQ=43    w1_ts78v    TO=1 AWAY=0 STILL=3 WRONG2=2  EQ=28
  … the other 24 arms TO=0 AWAY=0 WRONG2=0 …
  TOTAL  TO=51  AWAY=0  STILL=61  WRONG2=27  EQ=1429  SHAPE=8
```

**`x9c_cast73` op1 and op4 — the two cells r11u78's R0 named as the head of
this pass — both convert**, whole-cell, on every field.

**AND EVERY ONE OF THE 27 WRONG2 CELLS IS A TYPESPEC CONVERSION.** Scored on
the typespec axis alone, all 27 read TO: the cell's value or size was already
non-golden (r11u66's binary re-encoding, r11u73's mint sizes, r11u76's R2),
this law moved its typespec to exactly golden's, and **MOVED-WRONG on the
field this law writes is 0**.

---

## 4. CENSUS, A PRIORI, WITH ITS POSITIVE CONTROL

`census81.py`. Population: EVERY element of EVERY `'{...}` span in a parameter
context — taken through the committed `census68_base` (r11u72repro) and
deliberately NOT filtered by `classify`, because this law does not live on the
encoding table's faces and an encoding class would hide exactly the bare-NAME
setters it writes on. `HOP81` = the setter, after outer parentheses and any
number of signedness casts are stripped, is a bare (possibly
package-qualified) NAME.

```
  AGREE81  3407      HOP81  89      candidate tests: 13
  ArianeElab  ArianeElab2  AssignmentPatternInAssignmentPattern  BadScope
  BlackBePipeInt  BlackParrotConf  BlackParrotParam  EnumConstElab
  FuncStructVal  NegParam  ParamOverloading  ParamSubstituteComplex  PatAssignOp
```

SUPERSET BY CONSTRUCTION: no check that the name is a parameter, that it lives
in a PACKAGE, that the pattern's parameter is struct-typed, that the flat fold
happens, that the operand lacks a typespec already, or that the plan walk
answers rather than abstains.

**SELFTEST PASS** — the scanner sights `a1_hopts81`, `a2_castts81`,
`a3_hopbnd81`, `x9c_cast73`, `z1_ts78`, `z2_hop78`, `v3cast76` and
`y3_castenc76` as HOP81, and does NOT sight the 23 arms with no name setter.

**No canary is in the candidate set** — `SVSwitch`, `YosysVerx`,
`InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr` and `Earlgrey_0_1` are
all absent. **`ParamOverloading` IS**, and it is the name the prediction earned
its keep on: the census sighted it before any sweep, the first cut of the law
regressed it, and §1.5's gate withdrew the move.

MEASURED MOVERS ⊂ PREDICTED: `byteverify` reports **0 movers on 1608 u2r
databases** and 4 on 960 surelog ones, every one of the four the UVM coin
(§5.5) and none of them a HOP81 name.

---

## 5. GATES

**1. BUILD.** `-j 2` in this pass's own worktree, md5 taken separately, both
binaries frozen `chmod 555` before any sweep. Pristine
`87f32e6a31b52cd5b7766f0b8bcc731a` — **byte-identical to the main tree's
`build/slang-uhdm` at `f25df07e`**. Law `213d8d6a3e321e72f8d09d8a7a56c796`.
Every `cmds.txt` audited by absolute path: u2r 1742/1742 name this binary,
surelog 1531/1581 (the other 50 are SURELOG_FAIL/UNTRANSLATABLE rows with no
slang invocation), and **0 name the main tree** on either binary.

**2. GOLDENS.** `23 PASS / 0 FAIL` on the law binary;
`SLANG_UHDM=/bin/false` gives `0 PASS / 23 FAIL`.

**3. uhdm2rtlil, both modes.** `788 / 16 / 67` in each mode. The 1742-row
both-mode join against the committed `results/golden_uhdm2rtlil.csv`
**DIFF=0**, against this pass's own pristine sweep **DIFF=0**, and the
testflags rows against `results/gate_uhdm2rtlil.csv` **DIFF=0** — status AND
dump column, no ONLY-NEW, no ONLY-BASE. `byteverify` **MOVERS 0 / 1608**,
selfcheck 1607/1608.

**4. Surelog, `--mode both`.** `474 / 9` default + `469 / 8` testflags —
`CMP_EQUAL=943`, `CMP_NOTEQUAL=17`, and every other bucket at the committed
count. Against this pass's own pristine sweep **DIFF=0**. Against the
committed `results/golden_surelog.csv`, **two rows** differ and both are
`Earlgrey_0_1`'s DUMP COLUMN reading blank where the baseline reads `differ`:
the status is `CMP_EQUAL` in both modes on both binaries, the PRISTINE sweep
drew the same blank (which is why the own-pristine join is clean), and the
actual pin — the DATABASE byte-compare — never moved (§5.6). It is the
documented `uhdm-dump` TIMEOUT draw under load.

**5. byteverify surelog.** **MOVERS 4 / 960**, selfcheck 959/960, and all four
the UVM coin, attributed ORDER-BLIND: `Scoreboard/default` moves **0 sorted
lines** (the pure ORDER draw) and `SeqDriver` ×2 and `MiniAmiq` each move
exactly **4 sorted lines**, one `UINT`/`vpiDecompile` PAIR holding a LINE
NUMBER (`820↔913`, `0↔657`, `986↔0`). **Zero `vpiConstType`, zero `vpiSize`,
zero `vpiTypespec` lines in any of them.**

**COIN POSITIVE CONTROL**: the PRISTINE binary alone, three runs of MiniAmiq's
own invocation in one directory writing one name, gives **three distinct
databases** (`2ac6c6740dc6`, `b0b83e0d0099`, `fda0d9c64739`), and two further
pristine-only runs (`cb366eeb71d5`, `fdeb3137bbf9`) differ by exactly the same
4-line `UINT`/`vpiDecompile` line-number class (`1293 ↔ 1345`). A mover COUNT
is a draw; the CLASS is the measurement.

**6. Canaries.** `canaries.sh` surelog `ok=50 changed=2` — the two
`Earlgrey_0_1` dump-column rows of §4, status unchanged; u2r `ok=16
changed=0`. `ctcan2.sh` **PASS** on both corpora (`ok=58` / `ok=2`,
`changed=0`). `canaudit.sh` **PASS**, `audited=29 UNCOVERED=0
FENCE-BREACH=0`. Every protected database **byte-identical between the two
binaries and at exactly the pinned md5s**: SVSwitch `4842211c4030`, YosysVerx
`6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1
`8bdf25272e08` (default) / `59d0ee6d10c3` (testflags), plus
BlackParrotComplex and YosysOldOr.

**7. The conversion rows.** On the official `uhdm-cmp` with golden as LHS:
BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM (both modes) and Scoreboard
(default; testflags is SLANG_REJECT, no database) all read **0 cmp lines /
0 heads**. `ParamOverloading` reads **0 / 0 in both modes** — restored.
Rggen/default unchanged at 64/1.

**8. Wide boundary.** **3275 arms** (every `*/grid/*.sv` plus every `dut.sv`
and `design.sv` under `tools/probe`, this pass's four included):
**3214 SAME, 22 DIFFERS, 39 NODB**, and every NODB arm has `prc == lrc`. All
22 DIFFERS arms were then run against real Surelog v1.87 goldens and scored:
**TO=73, AWAY=0, STILL=67, WRONG2=14, EQ=510** — 13 of the 14 WRONG2 cells are
typespec conversions on cells whose value was already non-golden, and the
fourteenth is RV-3. The committed layout proof reads `JUDGE-VISIBLE HEAD
IDENTICAL` / `LAYOUTPROOF OK` on this binary pair, tail delta
`23212217 → 23216313` = exactly 4096.

**9. `results/*.csv` untouched** (`git status --porcelain results/` is empty);
fence check: none of the four slang-fenced names appears in any driver here
(`canaudit.sh` FENCE-BREACH=0).

---

## 6. RESIDUES

* **RV-1 — the empty `ref_typespec`'s birthplace is not pinned.** §1.6. The
  shape is measured on eight cells; the line that mints an actual-less
  container was not found, because both substitution sites are gated on `tps`
  being non-null. A future pass that needs to REASON about that container
  (rather than transcribe it) should find it first.
* **RV-2 — LAW C, the DECLARED-type hop, is dropped whole.** §2.1. Four golden
  cells say a declared type hands its typespec on and four say it does not, and
  the flips follow a package-qualified spelling, an intervening cast and the
  `logic` vector. Four TO cells left on the table, and two AWAY cells avoided.
* **RV-3 — one cell where golden keeps the TAGGED TREE.** `cvc_unt` `PDD` op1:
  golden's operand is a `tagged_pattern`, ours a constant, and the law
  decorates ours. The operand lists already differ in KIND at that index so no
  judge verdict moves, and the refusal guard cannot see it (the refusal is the
  whole pattern's, not this operand's). r11u73's R2 family.
* **RV-4 — `16'sh5` one hop up is a HIDDEN not-equal this law cannot fix.**
  Golden hangs the HOP's unsigned, `[15:0]`-ranged `int_typespec`; our literal
  path has already hung the literal's SIGNED, unranged one; the judge reads
  both fields and the dump prints neither. Fixing it means REPLACING a
  typespec, which this law does not do. `a3_hopbnd81` op8, `z1_ts78`
  op6/op8/op10 — and every one of those cells is already non-equal on SIZE or
  VALUE too, so no corpus row waits on it.
* **RV-5 — r11u78's R2 stands.** The `$signed` MINT's value, size and encoding
  (`signed'(16'h5)` is golden `const/16@7=INT:5`, ours `const/64@9=UINT:5`) are
  not this pass's ground; only their typespec is now golden's where the hop's
  store supplies it.
* **RV-6 — a DECLARED vector or an implicit parameter with a packed dimension
  is unmeasured beyond its kind.** `logic [7:0]` and `[7:0] PDIM` carry
  `Ranges` whose bounds are fully formed constants (`UINT:7/ct9/sz64/d7`), a
  DIFFERENT shape from the untyped switch's bare `INT:7/ct0/sz0`. Two cells,
  convertible in principle; declined because `logic_typespec::Compare` reads
  seven fields and only two were read.
* **RV-7 — the workdir is IN the database.** The same pristine binary run
  under tags `aaa` and `ccc` gives files differing in exactly three bytes, and
  under `aaa` and `bbbb` the sizes differ by one. Any `byteverify.sh` reading
  is meaningless unless the two workdir paths are the SAME LENGTH; this pass
  used `pris` and `lawx` for that reason and `gates81.sh` says so.
* **RV-8 — the a-priori census population is right but its CLASS is coarse.**
  `census81.py` does not know about the package gate, so 89 HOP81 setters in 13
  tests are predicted where the law can write on far fewer. The prediction held
  (movers ⊂ HOP81) but a future scope-sensitive law should teach the scanner
  the scope.
* r11u78's R4 (the unknown-digit operand DROP), R5, R6 and R7 were re-read here
  and none is contradicted.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp f25df07e && git worktree add /tmp/wtl f25df07e
(cd /tmp/wtl && git apply -3 /tmp/r11u81.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm
done            # 87f32e6a31b5…  and  213d8d6a3e32…
G=/tmp/g81 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u81repro/*.py $R/r11u81repro/*.sh $R/r11u81repro/ts81probe.cpp $G/
cp $R/r11u81repro/grid/*.sv $R/r11u78repro/grid/*.sv $R/r11v78repro/grid/*.sv \
   $R/r11u76repro/grid/*.sv $R/r11v76repro/grid/*.sv $G/grid/
cp $R/r11v73repro/grid/{x1_sdec73,x7_sdecpos73,x9c_cast73}.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts81probe.cpp -o ts81probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm
  bash $G/run66.sh $G/grid/$a.sv law  /tmp/wtl/build/slang-uhdm
done
python3 $G/score81.py $G/grid pris law          # TO 51 AWAY 0 WRONG2 27
# the scorer's own positive control (TO must become AWAY):
cp -r $G/grid/o_a1_hopts81_law  $G/grid/o_a1_hopts81_swapA
cp -r $G/grid/o_a1_hopts81_pris $G/grid/o_a1_hopts81_swapB
python3 $G/score81.py $G/grid swapA swapB a1_hopts81
python3 $G/census81.py --selftest && python3 $G/census81.py
# THE TAGS MUST BE THE SAME LENGTH — the database embeds the workdir (RV-7)
bash $G/gates81.sh pris /tmp/wtp/build/slang-uhdm
bash $G/gates81.sh lawx /tmp/wtl/build/slang-uhdm
bash $G/post81.sh
```
