# r11u66 — § patOperandEncReduceTable66

**A FOLDED PATTERN OPERAND IN THE ELABORATED VIEW CARRIES THE PRODUCER'S OWN
ENCODING, AND IT IS THE SAME `ExprEval::reduceExpr` OPERATOR TABLE
§ pkgSubstEncIsReduceTable50 AND § caSubstLeafEncReduceTable56 ALREADY READ —
A THIRD SITE, NOT A THIRD TABLE.**

Base `12c6de50` (v1.87 pass 64). Pins per `SUPPORT_MATRIX.md`: slang
`7d61e0ad1`, UHDM v1.87 (`18837c10ed3d`, verified `git log -1` in the pinned
tree), Surelog v1.87 (`0445655ee703`, likewise), uhdm2rtlil v0.68. Every
golden here is a real Surelog v1.87 run through `run66.sh`; every arm records
`slrc` / `ourrc` / `slerr`, and three binaries were built in this pass's own
worktree and frozen `chmod 555` before any sweep (the pristine, the law, and the
law plus §4's one abstention, which is what ships).

**447 grid cells, 0 DIFF golden-vs-golden; 434 of them scored on both binaries:
FULL pristine 349 right → law 395 right (+46), ENCODING half pristine 356 right
→ law 416 right (+60), AWAY 0, MOVED-WRONG 0. Corpus movement ZERO in both
corpora and both modes, predicted BY NAME before the sweeps and proved sighted
by a positive control.** This is CORRECTNESS GROUNDWORK: no corpus row is at
the head of this defect today.

---

## 1. THE RESIDUE, RE-MEASURED AT `12c6de50` (question 1)

r11v61's **RV0** ([tools/probe/r11v61repro/README.md:180](../r11v61repro/README.md#L180))
reproduces on the frozen pristine binary
(`md5 40563d03c6a4c68ed7192f6bd5657f5e`, byte-identical to the main tree's
`build/slang-uhdm` at `12c6de50`, which is the hash the brief states), and its
**PACKED-road claim is exactly right**.

**The v9 arm's `PN` / `PSW` cells** (`grid/v9.sv`, re-run here unmodified —
`slrc=0 ourrc=0 slerr=0`), read out of `uhdmtopModules` with the
encoding-visible shape lister:

| cell | source | golden | pristine |
|---|---|---|---|
| `PN` op0 | `struct packed {byte a; byte b;} '{a: -3, b: -4}` | `const/8@7=INT:-3` | `const/8@9=UINT:253` |
| `PN` op1 | | `const/64@7=INT:-4` | `const/8@9=UINT:252` |
| `PSW` op0 | `struct packed {shortint a; int b;} '{a: -1, b: -1}` | `const/16@7=INT:-1` | `const/16@9=UINT:65535` |
| `PSW` op1 | | `const/64@7=INT:-1` | `const/32@9=UINT:4294967295` |

Both are PACKED structs and both reach the flat `op75` walk on the PRISTINE
binary — no r11u61/r11v61 law is involved — so the defect is older than that
law, as RV0 says.

**The `x1_optable` faces** (`grid/x1_optable.sv`, r11v56's operator-table arm,
re-run here unmodified) put the whole table at this site in one row.
`uhdmtopModules work@dut.C`, 20 operands, golden vs pristine:

```
       setter          golden                 pristine
mul    K * 2           const/32@7=INT:12      const/32@9=UINT:12
dvd    K / 2           const/32@7=INT:3       const/32@9=UINT:3
mod    K % 4           const/32@7=INT:2       const/32@9=UINT:2
pwr    K ** 2          const/32@7=INT:36      const/32@9=UINT:36
shr    KU >> 1         const/32@9=UINT:3      same
asr    K >>> 1         const/32@9=UINT:3      same
ban    KU & 3          const/32@9=UINT:2      same
bor    KU | 8          const/32@9=UINT:14     same
bxr    KU ^ 3          op30 (UNFOLDED)        const/32@9=UINT:5
cmp    K > 2           const/1@3=BIN:1        const/32@9=UINT:1
cat    {8'd1, 8'd2}    const/16@3=BIN:0000000100000010   same
ter    K ? 3 : 4       const/64@9=UINT:3      const/32@9=UINT:3
cst    int'(K)         const/64@9=UINT:6      const/32@9=UINT:6
clg    $clog2(40)      const/64@9=UINT:6      const/32@9=UINT:6
nmul   -(K * 2)        const/64@7=INT:-12     const/32@9=UINT:4294967284
negs   2 - 5           const/64@7=INT:-3      const/32@9=UINT:4294967293
zsub   K - K           const/64@7=INT:0       const/32@9=UINT:0
nzer   -0              const/64@7=INT:0       const/32@9=UINT:0
bigs   KU << 40        const/64@9=UINT:6597069766656    same
notu   ~KU             const/32@9=UINT:4294967289       same
```

Two facts are visible here and both matter below. **(a)** The encoding is
per-operator, not per-value: `K - K` is `INT:0` and `KU & 3` is `UINT:2`.
**(b)** From `bxr` onward golden's sizes are 64 / 1 / 16 / 64 …, i.e. the
operands' OWN sizes — golden's walk BAILED at `bxr`, the operand `reduceExpr`
refused to fold, and `adjustOpSize` stopped stamping the member width. That
SIZE half is a standing residue of the bail model (§6 R0) and **this law does
not touch it**.

---

## 2. THE PRODUCER, DECODED AT THIS SITE (question 2)

Read independently in the pinned trees, not carried forward:

* `NetlistElaboration.cpp:262-283` — an instance's parameter whose value is an
  assignment pattern is deep-cloned per instance, `substituteAssignedValue`d
  and handed to `expandPatternAssignment`.
* `CompileHelper.cpp:5207` `expandPatternAssignment` — flattens the
  `tagged_pattern` wrappers, then `:5409-5441` walks the operands:
  `reduceExpr` each one, `get_uvalue` it, `adjustOpSize` it, bail on
  `invalidValue`.
* `CompileHelper.cpp:5114-5158` `adjustOpSize` — writes `cop->VpiSize(Bits(member))`
  **and nothing else**. It never touches `VpiValue` or `VpiConstType`.

So the encoding on the operand is whatever `reduceExpr`'s own per-operator arm
stamped, and those arms were read line by line in UHDM v1.87:

| arm | `~/git-repos/UHDM/templates/ExprEval.cpp` | writes |
|---|---|---|
| `vpiAddOp` / `vpiPlusOp` | `:3260-3300` | `UINT:` at `max(size0,size1)` — **unless** a reduced operand is `vpiIntConst` / `vpiStringConst` / `vpiRealConst` / `vpiDecConst`, and then `INT:` at the same size |
| `vpiSubOp` | `:3443` | `INT:` unconditionally |
| `vpiMinusOp` (unary) | `:3407-3426` | `INT:<-val0>` — **the OPERAND's magnitude negated** — at the OPERAND's own size |
| `*` / `/` / `%` / `**` | same table | `INT:` |
| shifts, bitwise, `$` calls | same table | `UINT:` |
| `^`, comparisons, concat, ternary, cast | — | not this table's arms |

**WHERE `ct 7` vs `ct 9` COMES FROM AT THIS SITE** is therefore the identical
question § pkgSubstEncIsReduceTable50 answered for a substituted package
parameter and § caSubstLeafEncReduceTable56 for a `cont_assign` Rhs. The table
is ALREADY TRANSCRIBED as `dimRedCtExpr79`
([src/TypeEmit.cpp:18687](src/TypeEmit.cpp#L18687)), and pass 55
wrapped it with the enum arm and pass 49's based-literal abstention as
`caSubstLeafCt56` ([src/ModuleEmit.cpp:26196](src/ModuleEmit.cpp#L26196)).
**This pass CALLS that wrapper. It does not re-derive, re-transcribe or copy
one line of it.**

---

## 3. THE GOLDEN GRID (question 3)

Nine arms, `grid/`. Every arm compiles clean on BOTH sides (`surelog rc=0`,
0 `[ERR`, our binary `rc=0`); `v9.sv` and `x1_optable.sv` are the committed
r11v61 / r11v56 arms re-run unmodified, the other seven are this pass's. Every
`op75` `param_assign` in EVERY listing is scored — the DEFINITION listings
(`uhdmallModules` / `uhdmallPackages` / `uhdmallInterfaces`) ride as shape
controls beside the elaborated ones, which is how the one abstention in §4 was
found.
**CALIBRATION GOLDEN-VS-GOLDEN FIRST: 447 cells, 0 DIFF on all nine arms**
(`score66.py <g.dump> <g.dump>`).

| arm | what it cuts | cells |
|---|---|---|
| `v9` | r11v61's negatives beside a PACKED control (the RV0 witness) | 24 |
| `x1_optable` | r11v56's 20 operator kinds at one packed-struct package parameter | 80 |
| `g2_fncall66` | CONSTANT FUNCTION CALLS: `f(6)`, `f(K)`, an unsigned-returning `f`, an `f` returning a negative, a call under `+` and under `-`, `$bits`, `$clog2`, a plain literal control | 36 |
| `g3_neg66` | THE VALUE HALF: `-16'd5`, `-K`, `2 - 5`, `-0`, `-(-K)`, `K - KU`, each onto SIGNED and UNSIGNED members at 8 / 16 / 32 / 64 bits, plus the module-local UNPACKED twin | 58 |
| `g4_base66` | THE FOUR BASES and the `'d` abstention: each base bare, through a NAME, and under a subtract; the `'s` forms; plain controls | 72 |
| `g5_width66` | THE WIDTH CONTROLS: one INT-answering and one UINT-answering setter at 4 / 8 / 16 / 32 / 64-bit members, plus concat / replication / based-literal controls | 52 |
| `g6_hold66` | THE HOLDERS: package DEF + ELAB, module localparam, imported, parameter PORT, OVERRIDDEN port, interface parameter and localparam, generate-block localparam, POSITIONAL form, pure `default:` fill, UNPACKED twin | 53 |
| `g7_add66` | THE DISCRIMINATING `+` ARM and the NAME hop: `LM+1` (INT) vs `LA+1` (UINT) vs `LH+1` (HEX) vs `LD+1` (DEC), two-hop chains, a subtract under a shift, `$signed(N)+1` | 56 |
| `g8_face66` | THE TWO NON-`topView` FACES of this same walk: § modDefImportPkgSelFlat60's import copy and `ifaceArrayDefFold`'s interface-array definition view | 16 |
| **TOTAL** | | **447** (13 of them in rows NEITHER binary emits — §6 R5 — so 434 are scored) |

The `.patch` also applies clean on a FRESH `12c6de50` worktree (`git apply -3`,
rc 0, no conflict markers), and the fence check for the four slang-fenced test
names over the patch prints `0 0 0 0`.

### The score, cell by cell, on the two frozen binaries

`cmp66.py` scores every cell twice — FULL (kind + size + constType + value) and
ENC (constType + value alone, the half this law owns; the SIZE half belongs to
the landed width laws and rides as a control):

```
FULL  TO 46   ENC-TO 14   AWAY 0   MOVED-WRONG 0   STILL 25   SAME 349
ENC   TO 60   ENC-TO  0   AWAY 0   MOVED-WRONG 0   STILL 18   SAME 356
```

**`ENC-TO` is not a regression and the scorer proves it per cell**: it is a
cell whose ENCODING converged on golden while its `vpiSize` is
**byte-unchanged** between the two binaries — all 14 are operands PAST golden's
own bail, where golden carries 64 and both our binaries carry the member width
(§6 R0, the size residue this law does not own). `AWAY 0` and `MOVED-WRONG 0`
are the load-bearing numbers. Per-arm listings at
[evidence/GRID.*.txt](evidence/).

### The fence cells — the ones a blanket "arithmetic is INT" law would break

Every one is golden `UINT`, pristine `UINT`, law `UINT`, measured on a real
v1.87 golden:

| cell | setter | golden | why the table declines |
|---|---|---|---|
| `g7` `pa` | `LA + 1`, `LA = N + 1` | `UINT:10` | the `+` arm over two UINT-ish operands |
| `g7` `ph` | `LH + 1`, `LH = 32'h28` | `UINT:41` | `vpiHexConst` is not signed-ish |
| `g7` `pz` | `LZ + 1`, `LZ = LA + 1` | `UINT:11` | the same, two hops down |
| `g7` `px` | `(N - 1) << 1` | `UINT:14` | the SHIFT arm stamps `UINT` whatever it reduced |
| `g7` `pp` | `8 + 3` | `UINT:11` | plain + plain |
| `x1` `shr`/`asr`/`ban`/`bor`/`bigs` | shifts and bitwise | `UINT` | the same arms |
| `x1` `bxr` | `KU ^ 3` | `op30`, UNFOLDED | the table REFUSES `^` (returns 0) |
| `x1` `cmp` | `K > 2` | `BIN:1`@1 | the table refuses comparisons |
| `x1` `cst` | `int'(K)` | `UINT:6` | a Conversion is not an arm of this table |
| `g4` `bh`/`bb`/`bo` | bare `32'h28` / `32'b…` / `32'o50` | `HEX`/`BIN`/`OCT` | the `IntegerLiteral` branch never reaches this mint |
| `g4` `bd`/`nd`/`ns` | `32'd40`, and a NAME onto it | **`DEC:` ct 1** | pass 49's `'d` abstention — a THIRD encoding this decimal writer cannot spell |

**THE LANDED FENCES ARE UNTOUCHED, and the grid says so cell by cell.**
§ elabUnpStructOperandBail61v declines the UNPACKED road wherever an element
reduces to a signed negative, so `v9`'s `UN` / `N2` / `N3` and `g3_neg66`'s
module-local `U3` keep the pristine `op1` / `op25` / `ref_obj` operands on BOTH
binaries — `STILL` in every one of those cells, never `AWAY`. This law adds no
element to the flat walk and removes none: it re-spells only the constants that
walk already minted.

The law is **MONOTONE by construction**: it only ever re-spells a
`vpiUIntConst` that the line above it has just written, and only when the table
answers `vpiIntConst`. A `vpiUIntConst` answer or an abstention (0) is a
no-op, so no cell can move AWAY. The grid's `AWAY 0` is the measurement of
that argument, not a substitute for it.

### The value half (caution (d)), measured HERE and not carried forward

`g3_neg66` decides which value rule this site uses, and it is pass 55's F2:

| setter | member | golden | pristine |
|---|---|---|---|
| `-16'd5` | `logic signed [31:0]` | `INT:-5` | `UINT:4294967291` |
| `-16'd5` | `logic [31:0]` (UNSIGNED) | `INT:-5` | `UINT:4294967291` |
| `2 - 5` | `logic [7:0]` | `INT:-3` | `UINT:253` |
| `2 - 5` | `logic [15:0]` | `INT:-3` | `UINT:65533` |
| `2 - 5` | `logic signed [63:0]` | `INT:-3` | `UINT:18446744073709551613` |
| `-(-K)`, `K = 5` | `logic [31:0]` | `INT:5` | `UINT:5` |
| `-0` | `logic signed [31:0]` | `INT:0` | `UINT:0` |

So: **the member's own signedness and width are irrelevant to the VALUE** — it
is the reduce's own arithmetic in the setter's self-determined type, which is
why the digits must come from the STRIPPED setter and never from the
member-masked `uvm` the mint has already forced unsigned. And a unary `-`
writes the NEGATED OPERAND MAGNITUDE (`-16'd5` → `-5`, not 65531), which is the
`vpiMinusOp` arm at `ExprEval.cpp:3407-3426` reading `-val0` off the operand.
`-(-K)` is the cell that separates "negate the operand" from "print the
operand's bits with a minus in front": golden is `INT:5`.

### The width controls (caution (b))

`g5_width66` carries one INT-answering and one UINT-answering setter at every
member width. Golden sizes each at the member width (`INT:4`@4, `INT:12`@8,
`INT:3`@16, `INT:36`@32, `INT:2`@64) and **the law leaves every one of those
`vpiSize` values exactly as the landed width stamps wrote them** — the
byte-level proof is below. The concat (`BIN:101001010011`@12), replication
(`BIN:101010101010`@12) and widening-based-literal (`BIN:1111`@5) controls in
the same arm are byte-unchanged.

### The byte-level signature of the whole grid

Order-blind, workdir-normalised `uhdm-dump` diff, pristine vs the shipped
binary, summed over all nine arms: **274 lines, and they are only ever these
three classes** ([evidence/BYTES.grid.txt](evidence/BYTES.grid.txt)) —

```
  61  |UINT:…         ->  |INT:…
  61  |vpiConstType:9  -> |vpiConstType:7
  15  |vpiDecompile:<unsigned digits> -> |vpiDecompile:<signed digits>
```

**61** encoding cells changed and the ENC score says **60** cells moved TO
golden. The one extra is not collateral — it is a TO cell the op75-row-keyed
scorer structurally cannot see, and the byte diff is what found it:
`g8_face66`'s `localparam int PICK = SEL.a` is a MEMBER READ of the
flat-folded struct parameter, which § elabStructMemberFold answers with the
very constant this walk minted. `work@g8_face66.PICK`'s elaborated
`param_assign` Rhs is golden `INT:5` ct 7, pristine `UINT:5` ct 9 and the law
`INT:5` ct 7. (Its PACKAGE sibling `q8::PICK` is golden `INT:5` and stays
`UINT:5` on both binaries — a different path, §6 R7.) So: **61 CELLS changed,
61 of them TO golden, zero collateral.** Not one `vpiSize` line moved.
`g2_fncall66`'s dump is **byte-identical** between the two binaries (0 lines) —
the call-arm abstention proved at the byte level, not only per cell, and
`law` vs the shipped `law2` differs on `g8_face66` alone (4 lines, the §4
abstention) and nowhere else in the grid.

---

## 4. THE LAW (question 4)

[src/ParamEmit.cpp](src/ParamEmit.cpp), inside the flat `op75` walk's
FOLDED-OPERAND mint — the final `else` of the setter chain, the one that writes
`UINT:<decimal>` for every value it evaluates. **163 added lines, zero
deletions, one production file, no new helper and no new table.**

* **F1 — the constant type.** `caSubstLeafCt56(*se) == vpiIntConst` re-spells
  the `vpiUIntConst` the mint has just written. Anything else — a
  `vpiUIntConst` answer, an abstention on `^` / a comparison / a ternary / a
  cast / a non-system call, or pass 49's `'d` refusal through bare NAME hops —
  leaves the mint's own answer standing.
* **F2 — the value (WORDING CORRECTED at the landing, per r11v66 R-V1).**
  The producer's value rule is `reduceExpr`'s own int64 arithmetic over the
  REDUCED operands — `int64_t val = val0 - val1` and its siblings — which
  never wraps at the expression's own width (golden writes `INT:400` onto an
  8-bit member, `INT:-2` for a 32-bit unsigned subtraction, `INT:4000000000`
  for an int product). The rule as first written here ("the setter's own
  value in its self-determined type") is REFUTED by those golden cells; the
  code matches golden on every cell that fits int64 and diverges wrong->wrong
  on the two measured overflow/wrap classes (r11v66 a2_uwrap66 / a7_arith66).
  A value that does not fit 64 bits leaves the digits empty and the law
  abstains.
* **THE SIZE IS NOT TOUCHED.** `VpiSize` is written by the line above and by
  the landed width rules; this law writes only `VpiConstType`, `VpiValue` and
  `VpiDecompile`.

**WHICH MINT THIS PASS CLAIMS, AND THE ONES IT FENCES** (caution (e)). The
flat `op75` walk has eight places that can produce an operand, and this law
lives in exactly one of them:

| mint | owner | this pass |
|---|---|---|
| `IntegerLiteral` setter | the producer's own base letter, landed | untouched |
| `StringLiteral` setter | landed (BlackBePipeInt) | untouched |
| enum member substitution | § enumMemberSubstConst / § elabModOwnEnumBinFold61 | untouched |
| concat-with-an-operation (`op33`) | RULE 4 (r9psc) | untouched |
| Replication → `BIN` | landed | untouched |
| Concatenation → `BIN` | landed | untouched |
| bare parameter reference → the referenced param's literal form | RULE 2 (r9psc) | untouched |
| CAST setter → `UINT`, no decompile | § patMemberCastNoDecomp | untouched |
| **the generic folded-expression `else`** | **nothing, until now** | **CLAIMED** |

**AND ONE FACE OF THE CLAIMED MINT ITSELF ABSTAINS.** The law copies what
`expandPatternAssignment`'s operand walk STAMPED, so where the producer never
ran that walk there is no encoding to copy. `g8_face66` measures exactly one
such face: an interface instantiated as an ARRAY **with no override**
(`bus8 arr[1:0] ()`) keeps its DEFINITION listing's parameter default as a
`tagged_pattern` TREE in golden, while `ifaceArrayDefFold` already flat-folds it
on the PRISTINE binary (`uhdmallInterfaces work@bus8.CFG` op0: golden
`tagged_pattern`, pristine `const/32@9=UINT:5`). That SHAPE residue belongs to
`ifaceArrayDefFold`, whose corpus witness `iface_array_elem_cfg_param`
instantiates the array **with** an override (`bus_if #(C16) arr[2-1:0] ()`) and
does flat-fold in golden; re-spelling a byte inside a shape the producer does
not have would be a MOVED-WRONG cell dressed as progress. Without the
abstention the grid scores `MOVED-WRONG 1`; with it, `0`. It costs **zero TO
cells** — every TO cell of `g8_face66` lives in `uhdmtopModules` /
`uhdmtopPackages` or on § modDefImportPkgSelFlat60's import-copy face
(`uhdmallModules work@g8_face66.SEL`, golden `INT:5`) — and zero corpus bytes.

The three roads that are landed ground elsewhere stay where they are: the
package/dimension road is § pkgSubstEncIsReduceTable50 (`TypeEmit.cpp`), the
`cont_assign` road is § caSubstLeafEncReduceTable56 (`ModuleEmit.cpp`), and the
override-actual road is r11u61/r11u62's. `g6_hold66` measures that the law
reaches every HOLDER of the claimed mint uniformly — package ELAB, module
localparam, unpacked twin, positional form, `default:` fill, parameter port,
interface parameter and localparam, generate-block localparam — 12 TO cells, 0
AWAY.

---

## 5. CENSUS, PREDICTION AND GATES (questions 5 and 6)

### The a-priori mover prediction, and its positive control

[census66.py](census66.py) reads SOURCES only. It finds every `'{ … }` span in
both pinned corpora, splits it into setters, and classifies each one by the
mint branch it would take — `BASED` / `PLAIN` / `NAME` / `AGG` / `CAST` /
`UINTISH` (all no-ops) versus `INTISH` (the law can fire). It is a **SUPERSET
by construction**: it never asks whether the pattern's parameter is
struct-typed, whether the elaborated copy flat-folds, or whether the setter
survives the admission fences.

*Positive control* (`--selftest`,
[evidence/CENSUS.selftest.txt](evidence/CENSUS.selftest.txt)): it runs over
this pass's own grid, asserts that all eight INT-carrying arms classify
`INTISH`, and then checks **31 individual setters whose golden cell was
measured above**, both halves — `K * 2`, `2 - 5`, `-16'd5`, `LM + 1`,
`LD + 1`, `(N - 1) + 0` must be `INTISH`; `KU >> 1`, `KU & 3`, `K > 2`,
`K ? 3 : 4`, `$clog2(40)`, `LA + 1`, `LH + 1`, `(N - 1) << 1` must NOT be;
`32'd40` is `BASED`, `int'(K)` is `CAST`, `{3{4'b1010}}` is `AGG`. Prints
`SELFTEST PASS`.

*The corpus scan*, over 20 009 classified setters in both corpora
([evidence/CENSUS.candidates.txt](evidence/CENSUS.candidates.txt),
[evidence/CENSUS.loose.txt](evidence/CENSUS.loose.txt)):

```
strict (the span is inside a parameter/localparam declaration):
  SETTERS AGG=785 BASED=6133 CAST=2223 INTISH=31 NAME=507 OTHER=5047 PLAIN=1582 UINTISH=3701
  CANDIDATES 6 — Earlgrey_Verilator_01_05_21, Earlgrey_nexysvideo, IncompTitan,
                 Kmac, Tnoc, Verilator
loose (EVERY '{…} span, procedural ones included — a strict superset):
  SETTERS ... INTISH=50 ...
  CANDIDATES 14 — the six above plus Ariane2024, AzadiRTL, CrossFunc, Zachjs,
                  and uhdm2rtlil's ariane, black-parrot, cva6_equiv,
                  struct_pattern_procedural
```

*Why the candidates cannot move a comparable row*, read off the committed
baselines BEFORE the sweeps: `Ariane2024` is `SLANG_REJECT`/`NO_DATABASE`;
`AzadiRTL`, `IncompTitan`, `Tnoc`, `Verilator`, `Zachjs` are `SLANG_REJECT`
both modes; `Earlgrey_Verilator_01_05_21` and `Earlgrey_nexysvideo` are
`DEFERRED` both modes; `ariane`, `black-parrot` and `cva6_equiv` are not
discovered uhdm2rtlil tests (no row in `results/golden_uhdm2rtlil.csv`). That
leaves **exactly three names that could move a byte — `Kmac`, `CrossFunc`
(surelog) and `struct_pattern_procedural` (uhdm2rtlil), all three `CMP_EQUAL`
in both modes** — and the prediction written down before the sweeps was that
the measured movers are a SUBSET of those three.

*Measured:* **u2r `MOVERS 0 / 1608`. surelog `MOVERS 4 / 960` — `MiniAmiq/default`,
`SeqDriver` both modes and `SimpleUVM/default`, every one the documented
per-invocation UVM coin (attributed below).** `Kmac`, `CrossFunc` and
`struct_pattern_procedural` did not move a byte, and all three stay
`CMP_EQUAL`. The measured set is a subset of the prediction, and it is empty
of this law's own signature.

*The zero is SIGHTED, not blind*
([evidence/POSCTL.census.txt](evidence/POSCTL.census.txt)): the uhdm2rtlil test
`iface_zero_width_field`'s own sources, UNMODIFIED, give an order-blind,
workdir-normalised dump diff of **0 lines** between the two binaries; the SAME
sources with ONE setter changed from `DAT: 8` to `DAT: 10 - 2` give **40
lines**, and every one of them is the law's own class (20 × `UINT:8` → `INT:8`
and `vpiConstType:9` → `:7`, nothing else). A gate that can see that can see
a corpus mover.

### The gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `40563d03c6a4c68ed7192f6bd5657f5e` = the main tree's `build/slang-uhdm` at `12c6de50`, byte-identical, and the hash the brief states; **shipped law `82111bbd435be0d05af1580b2222a687`**; `-j 2`, 0 errors, md5 taken separately, both frozen `chmod 555` before any sweep. (An intermediate build `97e1e07d…` — the law WITHOUT §4's `ifaceArrayDefFold` abstention — was measured, scored `MOVED-WRONG 1` on `g8_face66`, and is NOT what ships.) |
| (2) goldens | `PASS=23 FAIL=0` on BOTH binaries; `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| (3) u2r both modes | `787 CMP_EQUAL / 17 CMP_NOTEQUAL / 67 SLANG_REJECT` ×2; `ct8rows.sh` against `results/gate_uhdm2rtlil.csv` and against my own pristine sweep: PASS, every row byte-identical; a keyed both-mode row join against `results/golden_uhdm2rtlil.csv` (1742 rows each side): **0 differing rows** |
| (4) surelog `--mode both` | `474/9` default + `469/8` testflags on BOTH binaries, bucket for bucket (`DEFERRED 5/5, SLANG_REJECT 285/286, SURELOG_FAIL 25/23, NO_DATABASE 3, NO_UHDM 1, TIMEOUT 1, UNTRANSLATABLE 2`). Shipped binary vs `results/golden_surelog.csv`, whole-row: **exactly 2 differing rows, both the `LowMem*` `SURELOG_FAIL` detail string that quotes the WORKDIR PATH** — nothing else, `Earlgrey_0_1` included. Shipped vs my own PRISTINE sweep: those two plus `Earlgrey_0_1`'s dump COLUMN in both modes, and there it is the PRISTINE side that reads blank (the documented `uhdm-dump` timeout draw; the status is `CMP_EQUAL` on both and the DATABASE byte-compare is the pin, held below) |
| (5) byteverify `SELFCHECK=1` | u2r **`MOVERS 0 / 1608`**, SELFCHECK `1607/1608` flagged, `PATH_SETS_IDENTICAL`; surelog **`MOVERS 4 / 960`**, SELFCHECK `959/960` flagged, `PATH_SETS_IDENTICAL` — `MiniAmiq/default`, `SeqDriver` both modes and `SimpleUVM/default`, every one attributed below |
| canaries | surelog `ok=52 changed=0 absent=0` against the COMMITTED baseline (and `ok=50 changed=2` against my own pristine, the two being `Earlgrey_0_1`'s dump column above); u2r `ok=8 changed=0 absent=0`; `ctcan2` PASS on both corpora; `canaudit.sh canaries.sh ctcan2.sh` — audited 29, UNCOVERED 0, FENCE-BREACH 0 |
| rowheads | on the shipped surelog workdir: `SeqDriver`, `SimpleUVM`, `Scoreboard/default`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1` — all **0 cmp lines / 0 heads / rc 0** in both modes; `Rggen/default` 64 lines / 1 head, identical on the pristine sweep; `Scoreboard/testflags` and `Rggen/testflags` SKIP-NOFILE as expected |
| protected DBs | ([evidence/PROTECTED.txt](evidence/PROTECTED.txt)) every one SAME between the pristine and the shipped binary, and on its pin: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex e3e354129d5a` / `73a10e8217e5`, `YosysOldOr d68e0796d62c`, **`Earlgrey_0_1 8bdf25272e08` / `59d0ee6d10c3`**, `BlackBePipeInt 0754dbaa7154` / `85520d3442c4` |
| UVM family | BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard all still `CMP_EQUAL` in both modes |
| `cmds.txt` audited by binary PATH | 1742 u2r + 1531 surelog `slang:` lines per workdir, **every one naming the intended frozen binary; 0 references to the main tree's `build/slang-uhdm` in any of the four workdirs** |

### The four surelog movers, attributed — and the control is decisive

All four are the documented per-invocation UVM coin, and the proof is not a
shrug: the **SAME frozen PRISTINE binary, run TWICE on each sweep's own command
line from the test's own source directory**, draws a different hash every time,
and one of its own draws IS the shipped binary's
([evidence/MOVERS.attribution.txt](evidence/MOVERS.attribution.txt)):

```
database            sweep pristine  sweep law2    pristine re-draw 1  pristine re-draw 2
default/MiniAmiq    cb8571e719cb    3d93f0e9964d  b4d3b8aa38a8        c72869e2c07d
default/SeqDriver   2fb39f8b4130    e02ac8e66710  ef0ca17741a3        599eae646fa2
default/SimpleUVM   1207b8357060  **d4f8cd018f2d**  16767df42667    **d4f8cd018f2d**
testflags/SeqDriver 5df9344e26c2    12774e3a3a86  05df6c25a21b        47199dd18a1a
```

`SimpleUVM/default` shows THREE distinct hashes across four invocations on two
binaries, with the sets CROSSING — the pristine binary's own second re-draw IS
the shipped binary's sweep hash. `MiniAmiq/default` shows FOUR distinct hashes
across four invocations (`cb8571e719cb`, `3d93f0e9964d`, `b4d3b8aa38a8`,
`c72869e2c07d`), two of them from the same frozen pristine binary. And the
mover SET ITSELF varies: `testflags/MiniAmiq` moved on the intermediate law
binary's sweep and did NOT move on the shipped one.

The order-blind class agrees on every one: the sorted, workdir-normalised
`uhdm-dump` diff is **4 lines — ONE `UINT:` / `vpiDecompile` LINE-NUMBER pair**
in each of the four (`1317`↔`616`, `0`↔`978`, `650`↔`0`, `1362`↔`798`) — never
a `vpiConstType` and never an encoding, which is exactly what this law's own
signature would look like.

`results/*.csv` untouched. `GOLDEN_DEFER` unset. No fenced test dispatched or
named. Every arm's `rc` recorded on both sides.

---

## 6. RESIDUES, and R0

* **R0 — THE BAIL MODEL'S SIZE HALF, AND IT IS THE NEXT ONE-LINER.** Golden's
  operand walk stops stamping the member width at the FIRST operand
  `reduceExpr` refuses to fold or `get_uvalue` refuses to read, and every
  operand after it keeps its OWN size. Our walk models only the
  NESTED-PATTERN bail (`nestBailK`), so it keeps stamping the member width
  past every other kind of bail. Measured here, on real v1.87 goldens, 14
  cells in four arms: `x1_optable` bails at `KU ^ 3` (golden 64 / 1 / 16 / 64 …
  from there on, ours 32 throughout); `g2_fncall66` bails at the first
  NEGATIVE reduced operand (`f_neg(6)` → `INT:-6`, golden 64 from there on);
  `g3_neg66` and `v9` bail at their first negative likewise. r11v61 already
  decoded the negative bail and used it as a FENCE on the unpacked road
  (`bailElem61`); turning that same predicate into the SIZE model on the
  packed road is the natural companion, and it needs no new decode —
  `CompileHelper.cpp:5409-5441` and `ExprEval.cpp:2058-2160` are quoted above.
  It is the 14 `ENC-TO` cells of this pass's grid.

* **R1 — THE FUNCTION-CALL ARM OF THE TABLE, and RV0's example was the special
  case.** RV0 reads "a constant function call → `INT:6` ct 7". Measured at
  THIS site (`g2_fncall66`, real v1.87 goldens, every arm `rc=0`):

  | setter | golden |
  |---|---|
  | `f_id(6)`, `f_id(K)` (`function int`) | **`UINT:6` ct 9** |
  | `f_uid(6)` (`function int unsigned`) | `UINT:6` ct 9 |
  | `f_neg(6)` (returns `-6`) | **`INT:-6` ct 7** |
  | `f_id(6) + 1` | `UINT:7` ct 9 |
  | `f_id(6) - 1` | **`INT:5` ct 7** |

  So the call arm is not "always INT": it looks like the stored `Value`'s type,
  which follows the SIGN of the evaluated result, and the declared return type
  does not decide it. `dimRedCtExpr79` answers 0 for a non-system call, which
  also poisons the `-` above it (`f_id(6) - 1` abstains although golden writes
  `INT:5`). Both are **STILL** cells, never AWAY, and closing them means
  EXTENDING the shared table — a re-derivation this pass deliberately declines,
  per the brief's reuse mandate. The arm is measured and committed here so the
  pass that claims it starts from goldens.

* **R2 — `$signed(N) + 1` is golden `INT:9` and the table says UINT.**
  `g7_add66` `pw`. `$signed` reduces to a `vpiIntConst`, which makes the
  enclosing `+` take the signed arm, but `dimRedCtExpr79`'s `Call` arm answers
  `vpiUIntConst` for EVERY system call. One cell, a STILL, and the same
  "extend the shared table" question as R1. `$clog2(N) + 1` (golden `UINT:4`)
  is the control that says the blanket answer is right for the other system
  calls.

* **R3 — the bare NAME onto a based-DECIMAL parameter.** `g4_base66` `nd` /
  `ns`: `32'd40` read through a name is golden `DEC:` ct 1 and we write `UINT`.
  Not this mint (RULE 2's literal-form arm owns it) and the same missing
  `DEC:`/`HEX:` renderer pass 49 declined as its R1. Deliberately untouched.

* **R4 — `x1_optable`'s two unfolded/re-encoded cells.** `KU ^ 3` stays an
  `op30` in golden where we fold it to a constant, and `K > 2` is golden
  `BIN:1`@1 where we write `UINT:1`@32. Both are FOLD and
  comparison-encoding questions, not this table's; both are byte-unchanged by
  this law (the table refuses `^` and the comparisons).

* **R5 — `g6_hold66`'s two rows our binaries do not emit at all.** The
  OVERRIDDEN child parameter (`c2.PP`) and the generate-block localparam
  (`gblk.GL`) have an elaborated `param_assign` in golden and none in ours.
  The override half is r11u61's own documented pre-existing gap (golden's
  elaborated copy carries the OVERRIDE values); both are ABSENT on BOTH
  binaries, so this law neither creates nor closes them.

* **R6 — `g4_base66`'s zero-padded `BIN` through a NAME.** `nb: BB` with
  `BB = 32'b101000` is golden `BIN:101000` and we write
  `BIN:00000000000000000000000000101000` at the same size — RULE 2's
  BIN-restamp writing the padded bit string where the producer keeps the
  reduce's raw digits. The same class r11u61 recorded for its concat /
  replication operands. Untouched by this law.

* **R7 — the PACKAGE's own member read.** `g8_face66`'s
  `localparam int PICK = SEL.a` is golden `INT:5` in EVERY listing. The
  MODULE-scope copy (`work@g8_face66.PICK`) follows this mint and converts;
  the PACKAGE copy (`q8::PICK`, in `uhdmallPackages` and `uhdmtopPackages`)
  is answered by a different path and stays `UINT:5` on both binaries — a
  STILL, never an AWAY. It is the package-side twin of what
  § elabStructMemberFold already gives the module side, and it is the second
  natural companion to R0.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wt 12c6de50 && cd /tmp/wt && git apply -3 /tmp/r11u66.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2 && md5sum build/slang-uhdm

G=/tmp/g66 && mkdir -p $G && cp tools/probe/r11u66repro/grid/*.sv $G/
cp tools/probe/r11u66repro/{run66.sh,score66.py,cmp66.py,shape.py} $G/
for a in v9 x1_optable g2_fncall66 g3_neg66 g4_base66 g5_width66 g6_hold66 \
         g7_add66 g8_face66; do
  bash $G/run66.sh $G/$a.sv pris <pristine binary>      # rc for BOTH sides
  bash $G/run66.sh $G/$a.sv law  <law binary>
  python3 $G/score66.py $G/$a.g.dump $G/$a.g.dump CALIB   # CALIBRATION: DIFF 0
  python3 $G/cmp66.py  $G/$a.g.dump $G/$a.pris.dump $G/$a.law.dump $a
done

python3 tools/probe/r11u66repro/census66.py --selftest   # the positive control
python3 tools/probe/r11u66repro/census66.py              # the candidate list
python3 tools/probe/r11u66repro/census66.py --loose      # the wider superset
```

`run66.sh` drives Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog` with
`uhdm-dump` from `~/git-repos/UHDM/build/bin` and prints BOTH `rc` values and
the golden's `[ERR` count; it says so out loud when either side fails, because
an arm whose compile fails teaches error recovery and not golden.
`score66.py` and `cmp66.py` exit 4 on a golden dump that yields no elaborated
`op75` row at all — a scorer that reaches nothing can never read as agreement.
