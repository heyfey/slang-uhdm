# r11u94 — the implicit package declaration is an `int`, and a minus writes its own answer

**THREE FACES IN ONE BATCH, EACH DROPPABLE ALONE, ALL THREE OF THEM r11u91's
OWN RESIDUES.**

**LAW A (r11u91's R1, pass-88's R0).** A package parameter declared with an
IMPLICIT type that wears a SIGNING KEYWORD or a PACKED DIMENSION does not go
typespec-less: `compileTypespec`
(`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:1395-1437`) is called
for a parameter with `isVariable = false` and its `paSigning_Signed` /
`paSigning_Unsigned` / `paPacked_dimension` arms all SYNTHESIZE an
`int_typespec` — signed exactly when the `signed` keyword is written, carrying
the written dimension as its ranges and nothing when none is written.
`Bits(ts)` is therefore the dimension's width, or the `int` default **32**, and
never the initializer literal's own width.  `localparam signed QSI = 16'd5`
read by a `logic [7:0]` hop is golden `32 INT:5 int_typespec/S`, where slang's
`getBitWidth()` answers 16 and the pristine binary writes the reader's 8 —
neither candidate.  `red91PkgDeclKind91`'s `-1` REFUSAL is replaced by a kind
`2` that answers on both faces and on the has-a-typespec gate that decides
whether the reader keeps its vote.

**LAW B (r11u91's R2) and LAW C (r11u91's R3)** are one decoded rule with two
droppable faces.  `reduceExpr`'s `vpiMinusOp` (unary,
`~/git-repos/UHDM/templates/ExprEval.cpp:3407-3440`) and `vpiSubOp`
(`:3443-3477`) arms BOTH mint `"INT:" + std::to_string(val)` with
`vpiIntConst`, and compute `val` in `int64_t` with NO mask by the declared
type; `vpiAddOp` (`:3260-3300`) is the control and mints `UINT:` whenever both
operands are unsigned.  So `logic [7:0] PNU = -3` is golden `INT:-3` where our
store has already wrapped to `UINT:253` (LAW B, the VALUE), and `int PNZ = -0`,
`-(-3)`, `8 - 1` and `3 - 3` are all golden `vpiConstType 7` where the landed
value gate, which can only see the sign of the RESULT, writes 9 (LAW C, the
CONST TYPE).

Base `80c9a2f5`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68).  Every golden here is a real Surelog v1.87 run
through the committed `r11u86repro/run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`: **all 18 grid arms read `0 0 0` on both binaries, all 36
arm-runs.**

| binary | md5 | what |
|---|---|---|
| pristine | `f8ea201098701fd023fe53946c621514` | built in this pass's own worktree — byte-identical to the main tree at `80c9a2f5` |
| **law** | `9e4189217a70f8e0ac1707d564e5c4ab` | this patch |

---

## 1. THE PRODUCER, LINE BY LINE

### 1.1 LAW A — the parameter's implicit type is an `int`, and the synthesiser says so

`CompileHelper.cpp:3651` compiles a regular parameter's declared type with

```cpp
ts = compileTypespec(component, fC, fC->Child(Data_type_or_implicit),
                     compileDesign, reduce, nullptr, instance, false);
```

— the last argument is `isVariable`, and it is **false** for a parameter.
`CompileType.cpp:1395-1437` then reads, for the three implicit shapes:

```cpp
case VObjectType::paSigning_Signed: {
  if (isVariable) { … logic_typespec … }
  else {
    // Parameter implicit type is int
    int_typespec* tps = s.MakeInt_typespec();
    tps->VpiSigned(true);
    if (ranges) { tps->Ranges(ranges); for (auto r : *ranges) r->VpiParent(tps); }
    result = tps;
  }
```

and the `paSigning_Unsigned` and `paPacked_dimension` arms are the same
without `VpiSigned(true)`.  `compileRanges` at `:1294` has already skipped the
signing token (`:1286-1289`), so `signed [7:0]` carries the `[7:0]` range and
`signed` alone carries none.

From there the road is r11u91's, unchanged: `CompileHelper.cpp:3744-3750`
hangs that typespec on the package parameter's elaborated constant,
`CompileExpression.cpp:2729-2751` CLONES the constant typespec and all,
`DesignElaboration.cpp:2568`'s fill-in cannot run, and `valueRange` reads the
signedness off the PACKAGE's typespec while `adjustSize` keeps a
`vpiDecConst`'s own width.  **Two fields and the reader's vote, all three
decided by the synthesiser.**

### 1.2 LAWS B and C — a minus mints an `INT:` and an unmasked `int64_t`

```cpp
case vpiMinusOp: {                       // ExprEval.cpp:3407, ONE operand
  int64_t val0 = get_value(invalidValueI, expr0);
  int64_t val = -val0;
  c->VpiValue("INT:" + std::to_string(val));
  c->VpiDecompile(std::to_string(val));
  c->VpiConstType(vpiIntConst);
case vpiSubOp: {                         // :3443, TWO operands
  int64_t val = val0 - val1;
  c->VpiValue("INT:" + std::to_string(val));            // and VpiSize(64)
```

against

```cpp
case vpiAddOp: {                         // :3260
  bool unsignedOperation = true;                        // … unless an operand
  if (unsignedOperation) { uint64_t val = val0 + val1;  //   is INT/DEC/REAL
    c->VpiValue("UINT:" + std::to_string(val));
```

Our own site, `src/ExprEmit.cpp` `§ pkgParamFoldWidthAlways`, takes its digits
from `psym.getValue()` — slang's value AFTER conversion to the declared type —
and its `INT:`/`UINT:` from the SIGN OF THAT VALUE.  Both readings are wrong on
the same shapes and for the same reason: the producer never converts and never
looks at the sign.

---

## 2. THE THREE LAWS

### § pkgImplicitSynIsAnInt94 — `src/EmitHelpers.h`, LAW A, no call site moved

```
red91PkgDeclKind91(Q) gains kind 2 — an IMPLICIT declaration wearing a
  signing keyword or a dimension.  -1 is left for "no type syntax at all".

red94PkgSynSigned94(Q)  the WRITTEN keyword: `signed` -> true, `unsigned` and
                        a bare dimension -> false.  NOT slang's typing.
red94PkgSynBits94(Q)    no dimension -> 32 (`Bits` of a range-less
                        int_typespec); a dimension -> getBitWidth().

the SIGN face  (red91PkgStoreSigned91): dk==2 -> red94PkgSynSigned94(Q).
the WIDTH face (red91PkgStoreSize91):   dk==2 -> red94PkgSynBits94(Q), behind
                        the SAME `'d`-leaf gate the landed law already carries.
the VOTE gate  (red91PkgCloneHasTs91):  dk>=1 -> the clone CARRIES a typespec,
                        so the package replaces the reader's declaration read.
```

`src/ParamEmit.cpp` is **not touched**: all three faces are the readers the
landed call sites already consult, so the `__LINE__`-sensitive file keeps its
bytes.

### § pkgParamMinusIsIntReduce94 — `src/ExprEmit.cpp` + one predicate, LAWS B and C

```
red94MinusTop94(init):  the initializer, with IMPLICIT conversions peeled and
                        nothing else, is a unary `-` or a binary `a - b`.
mrv94 = red72Int64(init)        the landed 64-bit reduce, the producer's own
                                table (r11u72/r11u78's ground), reused whole.

LAW B   negRed94 = minus94 && mrv94 <  0   -> the digits ARE the reduce
LAW C   zpsRed94 = minus94 && mrv94 >= 0   -> `INT:` although the answer is not
                                              negative
c->VpiValue((callSigned9 || neg91 || negRed94 || zpsRed94) ? "INT:" : "UINT:")
```

An OR, not a replacement: the landed `callSigned9` and `neg91` predicates keep
every cell they already had.  The SIZE is untouched by both faces — golden's
size on this road is the READER's width, which is r11u91's R4 and its own
pass's ground.

---

## 3. THE GOLDEN GRID

Read with the committed `r11u87repro/ts87probe` and scored PER CELL with the
committed `r11u87repro/score87v.py`; the net-decl-assign arms are read with
`nda94.py`, this pass's PER-FIELD rescoring of r11v91's `nda91v.py` (the laws
write two of a cell's four fields by design, so a whole-tuple score would read
as if nothing had happened).  **18 arms — the 13 landed ones from r11u91 and
r11v91 re-run unchanged beside this pass's five** (`q7` was added after the
first score and is included below).

### 3.1 LAW A, per cell (`q1` / `q2` / `q3` / `q7`, and `p4`'s `U3`)

| package declaration | reader | golden | pristine | law |
|---|---|---|---|---|
| `int QI = 16'd5` | `logic [7:0]` | `32 /S` | `32 /S` | `32 /S` — the landed control |
| `signed QSI = 16'd5` | `logic [7:0]` | **`32 /S`** | `8 ts=-` | `32 /S` |
| `unsigned QUI = 16'd5` | `logic [7:0]` | **`32 ts=-`** | `8 ts=-` | `32 ts=-` |
| `signed [7:0] QSD = 16'd5` | `logic [7:0]` | **`8 /S`** | `8 ts=-` | `8 /S` |
| `[7:0] QPD = 16'd5` | `logic [7:0]` | `8 ts=-` | `8 ts=-` | `8 ts=-` — EQUAL |
| `unsigned [15:0] QUD = 8'd5` | `logic [7:0]` | **`16 ts=-`** | `8 ts=-` | `16 ts=-` |
| `signed QS8 = 8'd5` | `logic [7:0]` | **`32 /S`** | `8 ts=-` | `32 /S` |
| `signed [15:0] QSW = 8'd5` | `logic [7:0]` | **`16 /S`** | `8 ts=-` | `16 /S` |
| `signed RSH = 8'h1A` | `logic [7:0]` | `8 HEX:1A /S` | `8 ts=-` | `8 HEX:1A /S` |
| `signed RSB = 8'b1010` | `logic [7:0]` | `8 BIN ts=-` | `24 BIN ts=-` | unchanged — DECLINED |
| `signed RSO = 8'o17` | `logic [7:0]` | `8 UINT:15 /S` | `8 ts=-` | `8 UINT:15 /S` |
| `signed RSN = 5` | `logic [7:0]` | `8 UINT:5 /S` | `8 ts=-` | `8 UINT:5 /S` |
| `signed RSC = RI` | `logic [7:0]` | **`32 /S`** | `8 ts=-` | `32 /S` |
| `signed [7:0] RSDC = RI` | `logic [7:0]` | **`8 /S`** | `8 ts=-` | `8 /S` |
| `unsigned RUC = RI` | `logic [7:0]` | **`32 ts=-`** | `8 ts=-` | `32 ts=-` |
| `signed TSI = 16'd5` | `logic signed [7:0]` | `32 /S` | `8 /S` | `32 /S` |
| `unsigned TUI = 16'd5` | **`logic signed [31:0]`** | **`32 ts=-`** | `32 int_typespec/S` | `32 ts=-` |
| `[11:0] TPD = 16'd6` | **`logic signed [31:0]`** | **`12 ts=-`** | `32 int_typespec/S` | `12 ts=-` |
| `signed [11:0] TSD = 16'd6` | `logic [3:0]` | **`12 /S`** | `4 ts=-` | `12 /S` |
| `signed TSI` **imported** | `logic [7:0]` | `8 ts=-` | `8 ts=-` | `8 ts=-` — EQUAL |
| `(implicit) Z1 = Y1` over `signed Y1` | `logic [7:0]` | **`32 /S`** | `8 ts=-` | `32 /S` |
| `(implicit) Z3 = Y3` over `[11:0] Y3` | `logic [7:0]` | **`12 ts=-`** | `8 ts=-` | `12 ts=-` |

**THE TWO ROWS IN BOLD READERS ARE WHY THE PACKAGE REPLACES THE DECLARATION
READ ON THIS SHAPE TOO.**  A `logic signed [31:0]` reader over an `unsigned` or
dimension-only package hop is golden BARE and at the PACKAGE's width; the
pristine binary writes the reader's `32 int_typespec/S` on both fields.  They
are `q3_pkgread94` `V2` and `V3`, the mirror of r11u91's `R8`, and they are
what `red91PkgCloneHasTs91` had to be told about.

The IMPORTED read (`V7`) is r11v91's scoped-name gate doing its job: the same
symbol, no `pkg::` written, golden the reader's own `8 ts=-`, EQUAL on both
binaries.  The BINARY leaf (`W2`) stays declined whole — our member stamp
zero-pads its digit string to the member width, which is a VALUE field
(r11u91's R5).

### 3.2 LAWS B and C, per cell (`q4` / `q5` / `q6`, and `v3` re-run)

| package declaration | golden | pristine | law |
|---|---|---|---|
| `logic [7:0] NU8 = -3` | `INT:-3 ct7` | `UINT:253 ct9` | `INT:-3 ct7` |
| `logic [15:0] NU16 = -3` | `INT:-3` | `UINT:65533` | `INT:-3` |
| `bit [3:0] NUB4 = -3` | `INT:-3` | `UINT:13` | `INT:-3` |
| `logic [31:0] NU32 = -3` | `INT:-3` | `UINT:4294967293` | `INT:-3` |
| `logic [7:0] NUH = -8'h3` | `INT:-3` | `UINT:253` | `INT:-3` |
| `logic [7:0] NUOP = 0 - 3` | `INT:-3` | `UINT:253` | `INT:-3` |
| `logic [7:0] XSUB = 5 - 8` | `INT:-3` | `UINT:253` | `INT:-3` |
| `logic [7:0] XBIG = -300` | **`INT:-300`** | `UINT:212` | `INT:-300` |
| `logic [7:0] XWRAP = -259` | **`INT:-259`** | `UINT:253` | `INT:-259` |
| `byte XBY = -300` | **`INT:-300`** | `INT:-44` | `INT:-300` |
| `logic signed [7:0] XSN = -300` | `INT:-300` | `INT:-44` | `INT:-300` |
| `shortint XSH2 = -70000` | `INT:-70000` | `INT:-4464` | `INT:-70000` |
| `logic [7:0] XNAME = XSUBP - 9` | `INT:-2` | `UINT:254` | `INT:-2` |
| `logic [7:0] XNEGN = -XSUBP` | `INT:-7` | `UINT:249` | `INT:-7` |
| `int NZ = -0` | `INT:0 ct7` | `UINT:0 ct9` | `INT:0 ct7` |
| `logic [7:0] NUZ = -0` | `INT:0 ct7` | `UINT:0 ct9` | `INT:0 ct7` |
| `int NDBL = -(-3)` | `INT:3 ct7` | `UINT:3 ct9` | `INT:3 ct7` |
| `logic [7:0] XNEGP = -(-3)` | `INT:3` | `UINT:3` | `INT:3` |
| `int XSUBP = 8 - 1` | `INT:7 ct7` | `UINT:7 ct9` | `INT:7 ct7` |
| `logic [15:0] XM1 = 16 - 1` | `INT:15 ct7` | `UINT:15 ct9` | `INT:15 ct7` |
| `int XSUBZ = 3 - 3` | `INT:0 ct7` | `UINT:0 ct9` | `INT:0 ct7` |
| **AND THE DECLINES** | | | |
| `logic [7:0] XFF = 8'hff` | `HEX:ff` | `HEX:ff` | unchanged |
| `logic [7:0] XD = 253` | `UINT:253` | `UINT:253` | unchanged |
| `logic [7:0] XB = 8'b11111101` | `BIN:…` | `BIN:…` | unchanged |
| `int XADD = 1 + 2` | `UINT:3` | `UINT:3` | unchanged |
| `logic [7:0] XADDU = 1 + 2` | `UINT:3` | `UINT:3` | unchanged |
| `logic [7:0] XSHL = -1 <<< 1` | `UINT:254` | `UINT:254` | unchanged |
| `logic [7:0] XCAST = 8'(5 - 8)` | `UINT:253` | `UINT:253` | unchanged |
| `int NZP = 0` / `logic [7:0] PU8 = 3` | `UINT:` | `UINT:` | unchanged |

**THE STORED VALUE IS NOT THE AXIS.**  `XD = 253` and `NU8 = -3` hold the SAME
253 in slang's store and golden renders them `UINT:253` and `INT:-3`, so no
value-based gate — not the sign of the result, not a sign-extension of the
declared width — can separate them.  `XBIG` and `XWRAP` then refute
sign-extension outright: `-300` under a `logic [7:0]` declaration is golden
`INT:-300`, not the `-44` a width-masked reading gives.  The gate is the
WRITTEN SHAPE and the value is the producer's own unmasked `int64_t`.

### 3.3 THE SCORE, AND ITS POSITIVE CONTROL

| scoring | TO | AWAY | MOVED-WRONG | WRONG2 |
|---|---|---|---|---|
| LAW A, 18 arms, per cell | **88** | **0** | **0** | **0** |
| LAW A, the SAME databases with the tags SWAPPED | 0 | **88** | **88** | 0 |
| LAWS B+C, 4 arms, per FIELD | **62** | **0** | **0** | — |
| LAWS B+C, tags swapped | 0 | **62** | 0 | — |

Per moving arm: `p4 2  q1 22  q2 24  q3 26  q7 14` (LAW A) and
`v3 5  q4 24  q5 13  q6 20` fields (LAWS B+C).  **Every landed arm keeps its
count to the unit** — `p1 32 EQ`, `p3 16 EQ`, `v1 16 EQ`, `v6 40 EQ`,
`v5 14 EQ + 2 SHAPE` (the `$unit::` `ref_obj`, r11v91's RV91-1, unmoved) —
and `AWAY = 0` is a measurement, not an absence: swapping the two tags turns
every one of the 88 cells into AWAY *and* MOVED-WRONG.

`UNPAIR=4` is four golden `'{…}` sections our binary does not emit at all
(a gen-block's own DEF-view pattern); it is 4 on BOTH binaries and 1 of them
is `p4_pkghome91`'s, i.e. pre-existing and landed.

---

## 4. CENSUS, A PRIORI, AND THE ROOT THAT WAS NEVER THERE

`census94.py` carries one class per law, each a strict superset of the gate
that lands, with a positive control (this pass's own arms plus `p4_pkghome91`)
and a LIVE negative control (a written data type, a `+`, an explicit cast).

```
AGREE94 12861   MIN94 68   MINW94 120   PKS94 219      SELFTEST PASS
--- candidate tests: 22
```

**THE INSTRUMENT FINDING.**  The first run of this census reported 20
candidates and did NOT name `ibex`, and the byteverify then found a mover
there.  The cause is not this pass's: `verify_golden.py:50` reads
`UHDM2RTLIL_TESTS = ~/git-repos/uhdm2rtlil/test` — **singular** — and
`~/git-repos/uhdm2rtlil/tests` **does not exist**.  Every census from
`census87.py` through `census91.py` carries that plural as its default root,
and the invocation printed in `r11u91repro/README.md` §7 passes it explicitly,
so each of them walked an empty path for the whole uhdm2rtlil corpus and
reported the Surelog corpus alone.  `census94.py` uses the sweep's own roots
and sights `ibex IC_INDEX_HI = IC_INDEX_W + IC_LINE_W - 1` — the mover.  It is
recorded as residue **R5** and it is why this pass's prediction is a superset
and the earlier ones were not.

`predict94.py` re-keys the census from the TEST DIRECTORY to the SWEEP ROW,
reading each row's own `cmds.txt` and its test tree:

```
predict94.py <u2r workdir>        20 rows, every one ibex_*        (MIN94)
predict94.py <surelog workdir>    14 rows                          (see §5.5)
```

The measured mover set must be a SUBSET of that, and it is.

---

## 5. GATES — ALL MANDATORY

**5.1 BUILD.**  `-j 2`, `md5sum` separately, both binaries `chmod 555` BEFORE
any sweep.  Pristine `f8ea201098701fd023fe53946c621514` — **byte-identical to
the main tree at `80c9a2f5`, the md5 the ops brief names**.  Law
`9e4189217a70f8e0ac1707d564e5c4ab`.  The deliverable patch applies to a FRESH
`80c9a2f5` worktree with `git apply -3` rc 0, `Applied patch to
'src/EmitHelpers.h' / 'src/ExprEmit.cpp' cleanly`, no conflict marker.

**5.2 GOLDENS.**  `23 PASS / 0 FAIL`; the negative control
`SLANG_UHDM=/bin/false` -> `0 PASS / 23 FAIL`.

**5.3 uhdm2rtlil, BOTH MODES, BOTH BINARIES.**  `788 / 16 / 67` in all four
sweeps.  Both-mode 1742-row join against `results/golden_uhdm2rtlil.csv`:
**DIFF=0 on both binaries**.  Testflags gate against
`results/gate_uhdm2rtlil.csv`: `PASS: every row byte-identical`.  All 1742
`cmds.txt` audited BY ABSOLUTE BINARY PATH — 1742 name the frozen pristine in
the `pris` workdir and 1742 the frozen law in `lawx`, **0 name the main tree**.

**5.4 Surelog `--mode both`, BOTH BINARIES.**  `474 / 9` default and
`469 / 8` testflags on BOTH, histograms identical to the committed baseline to
the unit (`SLANG_REJECT 285/286`, `SURELOG_FAIL 25/23`, `DEFERRED 5/5`,
`NO_DATABASE 3`, `TIMEOUT 1`).  The whole-row join names **exactly the four
documented environment rows and no fifth**:

```
Earlgrey_0_1  default  + testflags   CMP_EQUAL/differ -> CMP_EQUAL/   (the DUMP COLUMN)
LowMemLib     testflags              SURELOG_FAIL, DETAIL = the sweep's OWN workdir
LowMemPkg     testflags              SURELOG_FAIL, DETAIL = the sweep's OWN workdir
```

and the Earlgrey dump-column draw appears on **BOTH** modes of the PRISTINE
sweep and only one mode of the law sweep, which is the documented `uhdm-dump`
timeout draw and not this patch.  **No status moved, in either direction, on
any row of either corpus.**

**5.5 byteverify, SELFCHECK=1, both corpora, against this pass's own pristine
workdirs.**

* **uhdm2rtlil: `MOVERS 2 / 1608`, `PATH_SETS_IDENTICAL`, `SELFCHECK 1607/1608`
  flagged.**  Both are `ibex_icache`, one per mode, and both were PREDICTED BY
  NAME: `predict94.py` lists 20 `ibex_*` rows as MIN94 candidates and the
  measured set is a subset of them.  The whole path-normalised dump diff is
  **30 lines — 7 `|UINT:10` -> `|INT:10` and 14 `|vpiConstType:9` -> `:7`,
  plus the dump's own header; `vpiSize` 0, `Typespec` 0, `vpiDecompile` 0.**
  It is LAW C on `ibex_pkg.sv:395`,
  `parameter int unsigned IC_INDEX_HI = IC_INDEX_W + IC_LINE_W - 1` — a
  top-level binary minus — and **GOLDEN AT THAT CELL READS `INT:10`
  `vpiConstType 7`**, so the mover is TO GOLDEN.  The row is `CMP_NOTEQUAL`
  in the committed baseline on a `decompile:` head elsewhere and stays
  `CMP_NOTEQUAL`.
* **Surelog: `MOVERS 3 / 960`, `PATH_SETS_IDENTICAL`, `SELFCHECK 959/960`.**
  `MiniAmiq` both modes and `SeqDriver` default — the UVM coin family.
  Attributed ORDER-BLIND on path-normalised, id-stripped, SORTED dumps: each
  moves **exactly four lines, one `|UINT:` / `|vpiDecompile:` pair holding a
  LINE NUMBER** (`1062->1396`, `0->1259`, `1322->1454`).  Across all three:
  **`|INT:` 0, `vpiSize` 0, `vpiConstType` 0, `Typespec` 0, `int_typespec` 0**
  — none of the fields these laws write.  **COIN POSITIVE CONTROL:** the
  PRISTINE binary alone, five runs of MiniAmiq's own invocation writing to
  this pass's own `-o` path, gives **three distinct databases**
  (`16eff8f5901a`, `27419f6011b4` x3, `6f2bffe6edd3`).  No sweep database was
  overwritten.

**5.6 CANARIES AND PINS.**  Surelog `ok=51 changed=1`, and the one changed row
is `Earlgrey_0_1/testflags`'s DUMP COLUMN — the PRISTINE sweep changes **two**
of them, so the draw is the environment's.  u2r `ok=8 changed=0 absent=0`.
`ctcan2` PASS on both corpora.  `canaudit.sh canaries.sh ctcan2.sh` ->
`audited=29 UNCOVERED=0 FENCE-BREACH=0`.  **Every protected database at its
pin AND byte-identical between pristine and law, both modes:**

```
SVSwitch 4842211c4030   YosysVerx 6ccda350c24a   InterfaceModPort 59a365f3ce2c
BlackParrotComplex e3e354129d5a / 73a10e8217e5   YosysOldOr d68e0796d62c
Earlgrey_0_1 8bdf25272e08 (default) / 59d0ee6d10c3 (testflags)
```

**5.7 THE CONVERSION ROWS, official `uhdm-cmp`, golden as LHS.**
`measured=12 SKIP-NOFILE=2 UNKNOWN-NAME=0`, every one **0 cmp lines / 0 heads,
`cmp rc=0`** — BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
Earlgrey_0_1 (and ParamOverloading `CMP_EQUAL` both modes in the CSV).  The
two SKIP-NOFILE are the documented `Scoreboard/testflags` and `Rggen/testflags`.

**5.8 EACH LAW DROPPABLE ALONE**, three further binaries built from this
patch's own hunks in their own fresh `80c9a2f5` worktrees:

| binary | md5 | LAW A grid (5 arms, 88 cells) | LAWS B+C (4 arms, per field) |
|---|---|---|---|
| full law | `9e4189217a70f8e0…` | TO=88 AWAY=0 MWRONG=0 | TO=62 AWAY=0 |
| LAW A reverted | `7094ed730ea79f7c…` | **TO=0** AWAY=0 MWRONG=0 | TO=62 AWAY=0 |
| LAWS B+C reverted | `0b351f0d7f9afd5b…` | TO=88 AWAY=0 MWRONG=0 | **TO=0** AWAY=0 |
| LAW C reverted | `4a389a1223544702…` | TO=88 AWAY=0 MWRONG=0 | **TO=42** AWAY=0 |

LAW C alone therefore accounts for `62 - 42 = 20` fields and LAW B for 42, and
LAW A's 88 cells are untouched by either.

**5.9 THE WIDE BOUNDARY**, every `*.sv` under `tools/probe`, not the grid glob:
**8211 arms — 7962 SAME, 33 DIFFERS, 216 NODB**, and every NODB arm has
`prc == lrc` (212 x `rc=3`, 4 x `rc=139`, identical on both binaries).  The 33
are **TWO CLASSES AND NO THIRD**:

* **LAWS B/C, 28 arms** — `|UINT:` <-> `|INT:`, `vpiConstType` 9 <-> 7,
  `vpiDecompile`.
* **LAW A, 5 arms** (`p4_pkghome91` and this pass's `q1`/`q2`/`q3`/`q7`) —
  `vpiSize` plus the `int_typespec` / `ref_typespec` / `vpiTypespec` /
  `vpiActual` / `vpiSigned` / `vpiFullName` / `vpiParent` / `\_constant`
  scaffolding.

The histogram over all 1216 differing lines is
`216 vpiConstType, 126 vpiSize, 118 INT, 106 UINT, 96 int_typespec,
88 vpiDecompile, 84 constant, 56 vpiParent, 52 vpiTypespec, 52 vpiFullName,
52 vpiActual, 52 ref_typespec, 44 vpiSigned, 4 vpiOperand, 4 operation` — and
the last two are **ALIGNMENT SHIFT inside `q3_pkgread94`, not new objects**:
both dumps hold `vpiOperand` 57 and `operation` 77, and the `\_constant` count
moves 443 -> 445, which is the two parent back-references the dump prints
inside the two ADDED `ref_typespec` sub-trees.

**TYPESPEC WRITES ARE ADD-ONLY** — `int_typespec` 92 added / 4 removed,
`ref_typespec` 48 added / 4 removed — and **UNEXPLAINED-REMOVALS = 0**: the
only removals in the whole boundary are the four lines in `q3_pkgread94` at the
`V2`/`V3` cells, where golden writes no typespec at all.

**NO PAGE-BOUNDARY CLASS.**  Every consecutive value delta in the
`|UINT:`/`|INT:` lines is a two's-complement wrap of the declared width —
`-2^64, -2^40, -2^32, -2^16, -2^9, -2^8, -2^4, 0` — and **no delta is 4096**.
The ops rule's 16 KB-pad positive control attaches to a 4096-delta-only `UINT`
mover; there is none here, so it is not required and was not run.  No arm has
identical DUMPS with differing bytes either, so pass-91's dead-string class
does not arise.

**5.10 `results/*.csv` UNTOUCHED.**  None of the four slang-fenced names appears
in any file of this patch — a per-name `awk` over the deliverable reads 0 for
each — and no test of theirs was ever dispatched.  **`ModuleEmit.cpp` — the
sister pass's ground — and `ParamEmit.cpp` — the `__LINE__`-sensitive one —
are BOTH absent from the patch**; the production surface is `src/EmitHelpers.h`
and `src/ExprEmit.cpp`, two files, plus `tools/probe/r11u94repro/`.

**5.11 THE SHIPPED SOURCE IS THE MEASURED SOURCE.**  Checked, not assumed: the
deliverable patch applied to a FRESH `80c9a2f5` worktree with `git apply -3`
(rc 0, `Applied patch to 'src/EmitHelpers.h' / 'src/ExprEmit.cpp' cleanly`, no
conflict marker) and built there independently links to
**`9e4189217a70f8e0ac1707d564e5c4ab`, byte for byte** — the law binary every
measurement above was taken on.

**5.12 ONE DEVIATION, RECORDED.**  The Surelog sweeps ran `--jobs 2`, not the
brief's `--jobs 3`: a first `--jobs 3` attempt was KILLED at 775/798 while a
SISTER PASS was running two `--jobs 3` Surelog sweeps of its own on the same
machine.  `--jobs` is a throughput setting and changes no measurement; both
binaries were swept at the same setting, one pair at a time.

---

## 6. RESIDUES

* **R1 — THE OTHER INT-MINTING ARMS.** `vpiMultOp` (`ExprEval.cpp:3479`) and
  `vpiDivOp` (`:3803`) mint `INT:` exactly as `vpiSubOp` does, and
  `int XMUL = 2 * 3` / `int XDIV = 6 / 2` are golden `INT:6` / `INT:3` where
  both binaries write `UINT:`.  Measured (`q5_negedge94`), unmoved here: `*`
  and `/` in a package parameter are far commoner in the corpus than a minus
  and the two would want their own census, their own prediction and their own
  sweep pair.  The predicate is the same one line.
* **R2 — `~0` IS A `UINT:` AND WE WRITE AN `INT:`.** `int XCMP = ~0` is golden
  `UINT:4294967295` (`vpiBitNegOp`, `ExprEval.cpp:3515`, reads
  `(uint64_t)get_value`) and BOTH binaries write `INT:-1`: the landed `neg91`
  gate fires on the sign of slang's value, which for `~0` under an `int`
  declaration is negative.  Pre-existing, unchanged by this pass, and the
  cell is wrong on both binaries in the same way, so it is STILL and not
  MOVED-WRONG.  Closing it wants the same operator-keyed reading these laws
  use, from the other side.
* **R3 — THE NET-DECL-ASSIGN WIDTH.** Every cell of `q4`/`q5`/`q6` that does
  not read TO on all four fields is the same one: golden's size on this road
  is the READING NET's width (`wire signed [31:0]` -> 32) and ours is the
  package parameter's own.  That is r11u91's R4 verbatim, FENCED for its own
  pass, and it is why the per-field scorer exists.
* **R4 — `bit signed [3:0] PB4 = 4'd3`.** Golden `INT:3 sz32`, ours
  `DEC:3 ct1 sz4` (`v3_negfold91` `wPB4`): a based literal keeps its base
  encoding through our fold where golden's reduce re-renders it.  Unmoved on
  both binaries, a different road from either law here.
* **R5 — THE CENSUS ROOT.** `~/git-repos/uhdm2rtlil/tests` does not exist and
  every landed census defaults to it (§4).  `census94.py` is fixed; the
  committed `census87/89/91.py` are not touched by this pass, and any future
  a-priori prediction taken from them is HALF-BLIND until they are.
* **R6 — THE GEN-BLOCK DEF-VIEW PATTERN SECTION.** Four golden `'{…}`
  sections across the grid (`q3`, `q7`'s neighbours, `p4`, `v4`, `v6`) have no
  counterpart in our databases at all — a generate block's own DEF-view
  pattern.  Identical on both binaries, pre-existing, reported as `UNPAIR` so
  no cell is ever scored against the wrong golden section.
* **R7 — `$unit::KUNIT`.** r11v91's RV91-1 stands: golden leaves the
  `$unit`-scoped read a `ref_obj` where both binaries fold a constant
  (`v5_road2way91` `G6`, the two `SHAPE` cells in the score).

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wtp 80c9a2f5 && git worktree add /tmp/wtl 80c9a2f5
(cd /tmp/wtl && git apply -3 /tmp/r11u94.patch)
for d in /tmp/wtp /tmp/wtl; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done            # f8ea201098701fd0…  and  9e4189217a70f8e0…
# ---- the grid ---------------------------------------------------------------
G=/tmp/g94 && mkdir -p $G/grid && R=/tmp/wtl/tools/probe
cp $R/r11u86repro/run66.sh $R/r11u87repro/{ts87probe.cpp,score87v.py,join87.py} $G/
cp $R/r11u94repro/{cells94.py,nda94.py} $R/r11v91repro/nda91v.py $G/
cp $R/r11u94repro/grid/*.sv $R/r11v91repro/grid/*.sv $R/r11v91repro/v3_negfold91.sv \
   $R/r11u91repro/grid/*.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts87probe.cpp -o ts87probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/\.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wtp/build/slang-uhdm    # SAME-LENGTH
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wtl/build/slang-uhdm    # TAGS
done                                   # every arm must read slrc=0 ourrc=0 slerr=0
TS87PROBE=$G/ts87probe python3 $G/score87v.py $G/grid pris lawx
#   TO=88 AWAY=0 WRONG2=0 MWRONG=0   (p4 2, q1 22, q2 24, q3 26, q7 14)
# the scorer's positive control — every TO must become AWAY *and* MOVED-WRONG:
for a in p4_pkghome91 q1_pkgsyn94 q2_pkgbase94 q3_pkgread94 q7_pkgchain94; do
  cp -r $G/grid/o_${a}_lawx $G/grid/o_${a}_swpA
  cp -r $G/grid/o_${a}_pris $G/grid/o_${a}_swpB
done; TS87PROBE=$G/ts87probe python3 $G/score87v.py $G/grid swpA swpB \
        p4_pkghome91 q1_pkgsyn94 q2_pkgbase94 q3_pkgread94 q7_pkgchain94
#   TO=0 AWAY=88 MWRONG=88
for a in v3_negfold91 q4_negpkg94 q5_negedge94 q6_negwid94; do
  python3 $G/nda94.py $G/grid/$a.g.dump $G/grid/$a.pris.dump $G/grid/$a.lawx.dump
done                                   # PER-FIELD TO=5/24/13/20  AWAY=0  MWRONG=0
#   (swap the last two arguments for the control: TO=0 AWAY=62)
# ---- the census and the a-priori prediction ---------------------------------
python3 $R/r11u94repro/census94.py --selftest          # SELFTEST PASS
python3 $R/r11u94repro/census94.py                     # the roots are built in
python3 $R/r11u94repro/predict94.py <u2r workdir>      # 20 rows, all ibex_*
python3 $R/r11u94repro/predict94.py <surelog workdir>  # 14 rows
#   the byteverify's mover list must be a SUBSET of those two
# ---- the corpora, per binary, workdir names the SAME LENGTH (pris / lawx) ---
#   verify_golden.py --corpus uhdm2rtlil --mode {testflags,default} --jobs 3
#   verify_golden.py --corpus surelog    --mode both               --jobs 3
#   join87.py results/golden_uhdm2rtlil.csv <tf.csv> <def.csv>      # DIFF=0
#   ct8rows.sh results/golden_surelog.csv <sl.csv>
#   SELFCHECK=1 r11u91repro/byteverify.sh <lawx wd> <pris wd>
#   RUN THE SWEEPS ONE PAIR AT A TIME.
# ---- each law droppable alone: three more binaries in their own worktrees ---
#   LAW A reverted   — kind 2 back to -1, the two dk==2 arms and the `>= 1`
#                      vote gate reverted; ExprEmit.cpp kept
#   LAWS B+C reverted— ExprEmit.cpp and `red94MinusTop94` reverted; the
#                      EmitHelpers.h LAW-A hunks kept
#   LAW C reverted   — `zpsRed94` forced false, everything else kept
# ---- the wide boundary, every *.sv under tools/probe ------------------------
#   BND_PRIS=… BND_LAW=… BND_ROOT=/tmp/wtl/tools/probe BND_OUT=/tmp/bnd94 \
#     xargs -P 2 -n 1 bash r11u91repro/bnd72.sh < armlist
```

Evidence: `evidence/{GRID94.score, SWAPCTL94.score, CELLS94.txt,
NEGCELLS94.txt, CENSUS94.txt, PREDICT94.u2r.txt, PREDICT94.sl.txt,
ARMS94.txt, GOLDENS94.txt, MOVERS94.txt, BOUNDARY94.summary, DROP94.txt}`.
