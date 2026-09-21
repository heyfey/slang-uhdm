# r11u78 — the cast carries its typespec, the unsigned arm carries its value, and `>>>` is a logical shift

**FOUR FACES OF ONE GROUND, AND NONE OF THEM IS A NEW MODEL: the producer hands
back the operand's own constant — typespec included; its unsigned arms mint from
the same written-digit int64 the signed ones do; and its `>>>` shares a body with
`>>` that never sign-fills.**

Base `7d0c7bf4`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden in this directory is a real Surelog
v1.87 run through the committed `run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`; **all of them read `0 0 0`**.

| binary | md5 | what |
|---|---|---|
| pristine | `963667a2299a360105d9677e3a065959` | built in this pass's own worktree at `7d0c7bf4` — byte-identical to the main tree's `build/slang-uhdm` |
| law | `11d069db9ddbeff921367ab3b426b853` | this patch |

Both frozen `chmod 555` before any sweep; every `cmds.txt` audited by absolute
binary path.

---

## 0. AN INSTRUMENT ADDITION — THE LISTER COULD NOT SEE THE FIELD THE JUDGE READS

`expr::Compare` (`~/git-repos/UHDM/build/generated/src/expr.cpp:83-103`) reads
`VpiDecompile`, `VpiSize` **and `Typespec`**. The committed r11u76 shape lister
prints the first two and not the third, so r11v76 could only record "the cast
constant is still judge-unequal on `Typespec`" without being able to say what
golden's shape was. `ts78.py` here is that lister with ONE addition — every
bare `constant` operand also prints its own `vpiTypespec` chain:

```
  const/<vpiSize>@<vpiConstType>=<VALUE>/ts=<actual-kind>(<name>)<S|U>
```

`ts=-` means no `vpiTypespec` at all. Nothing else moved: run beside
`shape.py`, the non-`ts` part of every cell is character-identical.
`score78.py` scores those cells TO / AWAY / STILL / WRONG2 / EQ and reports a
SHAPE mismatch (a different operand COUNT) separately instead of joining
across it.

---

## 1. THE HEAD, RE-MEASURED AT THE BASE (question 1)

`x9c_cast73` and `v3cast76` re-run unmodified at `7d0c7bf4` with the
typespec-aware lister, off the flat `op75` operand list of
`uhdmtopModules work@…`:

**`x9c_cast73`** — pass 75 closed its value/encoding half; the typespec half is
what is left, and it is on the CONTROLS too:

```
  member                        golden                              pristine
  op1 HC1 = 16'(5)              const/32@9=UINT:5/ts=int_typespec    ts=-
  op2 HCS = signed'(16'd5)      const/16@1=DEC:5/ts=logic_typespec   ts=-
  op3 HCU = unsigned'(16'sd5)   const/16@1=DEC:5/ts=int_typespec     ts=-
  op4 HAD = 16'd9 + 16'd1       const/32@7=INT:10/ts=int_typespec    ts=-
  op0 (the 8'hxA bail)          ts=-                                 ts=-   EQUAL
  op5 K+1                       ts=-                                 ts=-   EQUAL
```

**`v3cast76`** — seventeen of its nineteen operands carry a typespec in golden
and none in ours, and one of them also carries the wrong SIZE:

```
  op12 x12 = HQC = signed'(8'sd200)   golden const/8@1=DEC:200/ts=int_typespec
                                      ours   const/24@1=DEC:200/ts=-
  op5  x05 = HQ5 = unsigned'(8'sd200) golden const/8@1=DEC:200/ts=int_typespec
                                      ours   const/8@1=DEC:200/ts=-
```

— the same literal through the same kind of hop, and the SIGNED spelling alone
keeps the member's 24. That asymmetry is what convicts the digits guard rather
than the size table (§ 4, LAW B).

**`y2_digits76` / `y5_paren76`** carry the two value residues r11u76 recorded
as R0 and R1, re-read here unchanged: five `UINT:` cells where golden's digits
are the written ones (`2'b111 + 1` golden `UINT:8` ours `UINT:4`) and three
parenthesised cells encoded `@9 UINT` on both binaries where golden is
`@7 INT`.

**`8'sd200 >>> 1`** is golden `UINT:100` and ours `UINT:18446744073709551588`
on both binaries (r11v76 §4's fourth residue) — the arithmetic shift was not in
the reduce table at all.

---

## 2. THE PRODUCER, LINE BY LINE (question 2)

### 2.1 The typespec the cast hands on (`ExprEval.cpp:4682-4781`)

```
  $signed   + vpiIntConst / vpiDecConst
        if (!c->Typespec()) {                                    :4700-4710
            logic_typespec *lt = s.MakeLogic_typespec();
            lt->VpiSigned(true);
            ref_typespec  *rt = s.MakeRef_typespec();
            rt->VpiParent(c);  rt->Actual_typespec(lt);  c->Typespec(rt);
        }
        return c;                                                :4711
  $unsigned + vpiIntConst/vpiDecConst, value >= 0   return c     :4716
  $unsigned + UInt/Binary/Hex/Oct                   result = c   :4779
```

So on every `return c` face the typespec that comes out is the ARGUMENT's own,
and `$signed` fills an EMPTY one with a signed `logic_typespec` that has no
name and no source location. Which arguments have one is Surelog's literal
arm's business, and golden states it plainly — the DEF-view `sys_func_call`
arguments of `z2_hop78` and `z1_ts78`:

```
  8'sd200   DEC:200@8   vpiTypespec -> ref_typespec -> int_typespec (no location)
  4'sb1111  BIN:1111@4  vpiTypespec -> ref_typespec -> int_typespec
  3'so7     OCT:7@3     vpiTypespec -> ref_typespec -> int_typespec
  16'sd5    DEC:5@16    vpiTypespec -> ref_typespec -> int_typespec
  16'd5     DEC:5@16    NO vpiTypespec
```

**The `s` marker decides, in every base.** And the ELAB operand list agrees
cell for cell (`z1_ts78`, twenty operands read once each):

```
  written                        golden ts        what wrote it
  signed'(16'd5)                 logic_typespec   the $signed mint  (:4704)
  signed'(16'sd5)                int_typespec     the literal's own
  unsigned'(16'sd5)              int_typespec     the literal's own
  unsigned'(16'sh5) / (16'so5) / (16'sb101)
                                 int_typespec     the literal's own
  unsigned'(16'h5) DIRECT        NONE             the literal has none
  unsigned'(16'o5) DIRECT        NONE
  unsigned'(16'b101) DIRECT      NONE
  16'd5 / 16'h5 / 16'o5 VERBATIM NONE             (EQUAL on both binaries)
  16'sd5 VERBATIM                int_typespec     (EQUAL on both binaries —
                                                   our literal path writes it)
```

and TWO shapes that are NOT this cast's doing, both declined (§ 4):

```
  unsigned'(16'h5) / (16'o5) / (16'b101)  reached through a NAME HOP
        golden int_typespec LOCATED AT THE HOP PARAMETER'S DECLARATION
        (`z1_ts78` line:21:3-21:27 is `localparam HUH = UH;` itself)
  unsigned'(16'd5) through a hop, and `signed'(UD)` with `UD = 16'd5`
        golden a ref_typespec with NO vpiActual AT ALL
  signed'(TB) with `byte TB = 8'd5`
        golden byte_typespec (`v3cast76` op1)
```

### 2.2 The unsigned arms' value (`ExprEval.cpp:3167-3178`, `:1969-1998`)

`reduceExpr`'s `vpiAddOp` arm reads both operands with `get_value` /
`get_uvalue` and runs the addition in 64 bits, minting `UINT:` when neither
reduced operand is signed-ish. Those reads are the very `NumUtils::parse*`
calls § redBasedLeafWrittenDigits76 transcribes, so the LEAVES are the written
digits in their own base, and `adjustOpSize` afterwards writes only `VpiSize`.
Nothing masks the value to the member. Measured, `z3_uns78`:

```
  2'b111 + 1     golden UINT:8    ours UINT:4      (digits 111b = 7, not 3)
  3'o77 + 1      golden UINT:64   ours UINT:8      (digits 77o = 63, not 7)
  4'hFF + 1      golden UINT:256  ours UINT:16     (digits FF = 255, not 15)
  8'shC8 + 1     golden UINT:201  ours 18446744073709551561
  3'so7 + 1      golden UINT:8    ours UINT:0
  4'sb1111 + 1   golden UINT:16   ours UINT:0
  --- the CONTROLS, EQUAL on both binaries before and after ---
  8'hC8 + 1 (201)   16'hFFFF + 1 (65536)   2'b11 + 2'b11 (6)   1'b1 + 1'b1 (2)
  LA + 1 (8)        LH + 1 (41)            KU + 1 (7)
  4'd3 + 1 and K * 2 — the `vpiIntConst` face, untouched
```

### 2.3 `>>>` (`ExprEval.cpp:3149-3171`, `:3236-3255`)

```
  case vpiArithRShiftOp:
  case vpiRShiftOp: {                                            :3149
      int64_t val0 = get_value(invalidValue, arg0);              :3160
      int64_t val1 = get_value(invalidValue, reduceExpr(operands[1], …));
      if (invalidValue) break;
      uint64_t val = ((uint64_t)val0) >> ((uint64_t)val1);       :3164
      c->VpiValue("UINT:" + std::to_string(val));
      c->VpiSize(64);  c->VpiConstType(vpiUIntConst);
  }
```

**`>>>` AND `>>` ARE ONE BODY, AND IT IS THE LOGICAL SHIFT OF THE DIGIT
MAGNITUDE.** There is no sign fill anywhere on that path, `<<<`/`<<` are the
mirror at `:3251`, and both stamp `UINT:` at `VpiSize` 64. The arm also carries
two refusals: `if (c->VpiSize() == -1) invalidValue = true` on an unsized
argument (`:3157`) and `get_value`'s own guards on the leaves.

Golden says all of it out loud (`z4_shift78`, 64-bit members so nothing is
masked away, `K+1`/`K+2` probes):

```
  8'sd200 >>> 1    golden UINT:100    ours 18446744073709551588
  8'sd200 >>  1    golden UINT:100    ours  9223372036854775780
  8'sd200 <<< 1    golden UINT:400    ours 18446744073709551504
  8'sd200 <<  1    golden UINT:400    ours 18446744073709551504
  8'shC8  >>> 2    golden UINT:50     4'sb1111 >>> 1  golden UINT:7
  3'so7   >>> 1    golden UINT:3      4'hFF    >>> 2  golden UINT:63
  SD8 >>> 1 (a NAME hop)      golden UINT:100
  (8'sd200 >>> 1) + 1         golden UINT:101
  8'sd200 >>> 0               golden UINT:200
  --- THE COUNT IS MASKED TO SIX BITS, which is the host's shift instruction ---
  8'sd200 >>> 70   golden UINT:3       = 200 >> (70 & 63)
  8'sd200 <<  70   golden UINT:12800   = 200 << (70 & 63)
  --- THE REFUSALS ---
  W96 >>> 1  (`96'h123456789ABCDEF012345678`)  golden an UNFOLDED op42,
             probes 64/64 — the leaf's `get_value` bailed
  65'd36893488147419103232 >>> 1               golden an UNFOLDED op42
  --- THE CONTROLS, EQUAL on both binaries ---
  KU >> 1 (3)   K << 2 (24)   (K-1) << 1 (10)   KU >>> 1 (3)
```

The masked count is the same class as § patPowCastArtefact73's `cvttsd2si`
pattern: the producer's answer is an artefact of its host, and following the
goldens means writing it down. The mask is written explicitly so this build
performs no undefined shift of its own.

### 2.4 Parentheses in the ENCODING classifier

`Expression::create` (`~/git-repos/slang/source/ast/Expression.cpp:791-799`,
`:1002`) binds a `ParenthesizedExpression` by recursing into the inner syntax
and then OVERWRITING the result's `syntax` pointer with the parenthesized node,
so a bound `(8'sd200)` is an `IntegerLiteral` whose `syntax->kind` is
`ParenthesizedExpression`. The SYNTAX encoding table `dimRedCt79` has always
stripped that (`while (e->kind == ParenthesizedExpression)`); the BOUND table
`dimRedCtExpr79` beside it never did, and fell through to `vpiUIntConst`.

---

## 3. THE GOLDEN GRID (question 3)

Four new arms and five positive-control arms beside the sixteen committed ones
of passes 73/76, every operand read EXACTLY ONCE, scored by `score78.py` on the
judge's own fields plus the value byte
([evidence/GRID.25arms.txt](evidence/GRID.25arms.txt)).

| arm | what it grids | TO / AWAY / WRONG2 |
|---|---|---|
| `z1_ts78` | the TYPESPEC: `signed'`/`unsigned'` × base × signedness spelling × (one hop \| written directly), with the four VERBATIM literals as controls | 9 / 0 / 0 |
| `z2_hop78` | the one-hop SIZE: the same cast over `8'sd200` at one hop, TWO hops and written directly, against the `unsigned'` spelling that already passes, plus the h/b/o hops and the verbatim controls | 9 / 0 / 1 |
| `z3_uns78` | the unsigned arm's VALUE across all four bases × signed and unsigned spellings × widths, with seven name-only and agreeing-literal controls and the unknown-digit face | 6 / 0 / 0 |
| `z4_shift78` | `>>>` `>>` `<<<` `<<` × operand base × signedness × a NAME hop × nesting × count 0 and count > 63, with four name-only controls and three refusal faces | 17 / 0 / 0 |
| `y3_castenc76` | committed (r11u76) | 7 / 0 / 0 |
| `v3cast76` | committed (r11v76) | 6 / 0 / 0 |
| `y2_digits76` | committed (r11u76) | 5 / 0 / 0 |
| `y5_paren76` | committed (r11u76) | 4 / 0 / 1 |
| `x9c_cast73` | committed (r11v73) | 2 / 0 / 0 |
| `v4val76` | committed (r11v76) | 1 / 0 / 0 |
| `y1_sdval76`, `y4_pos76`, `x1_sdec73`, `x7_sdecpos73`, `v1unk76`, `v2par76` | committed — re-run BYTE-IDENTICAL | 0 / 0 / 0 |
| `cz_base78` … `cz_ts78` | the positive control, § 5 | 4 / 0 / 0 |

**Totals over all 25 arms: TO 71, AWAY 0, MOVED-WRONG 0, WRONG2 2, STILL 63,
EQ 2525.**

### The two WRONG2 cells, both already wrong before this pass

```
  z2_hop78 op5  `unsigned'(4'sb1111)` one hop
        golden const/32@7=INT:15/ts=int_typespec
        pris   const/4@3=BIN:1111/ts=-      law const/4@3=BIN:1111/ts=int_typespec
```
The TYPESPEC field moved TO golden's; the encoding and size stay pass 76's
(r11u76's R2 mint face — golden's operand there is a MINTED int constant at the
untyped-parameter width, not the literal's). No field moved away from golden.

```
  y5_paren76 CD  `(4'd99999999999999999999) + 1`
        golden an UNFOLDED op24 (the digit-overflow refusal)
        pris   const/64@9=UINT:16          law const/64@7=INT:16
```
Golden has no constant there at all, so neither reading is right: the refusal
itself already fires (the bail's probes are golden's), but our walk has folded
the operand and cannot un-fold it — r11u73's R2, unchanged. The encoding moved
to the one the producer's table WOULD answer.

---

## 4. THE FIVE GATED LAWS (question 4)

Each is droppable alone: they touch different predicates and different write
sites, and none reads another's result.

### LAW A — § castOperandCarriesItsTypespec78

`src/EmitHelpers.h` (`red76SignCastPassThru` gains two out-parameters and
`red78LitWrittenSigned` is new) and ONE write inside the existing cast
re-spelling loop in `src/ParamEmit.cpp`:

* the literal's base token carries the `s` marker → a signed `int_typespec`;
* else the cast is `$signed` → a signed `logic_typespec` (the producer's mint);
* else nothing.

**Two abstentions, each with golden proving it is needed** (§ 2.1): a NAME
between the cast and the literal (golden answers with the HOPPED symbol's
typespec — `byte_typespec`, or a ref_typespec with no actual at all), and an
unsigned spelling under `$unsigned` (written directly golden has none and so
have we — an EQUAL cell; through a hop golden carries the hop parameter's own
`int_typespec`, which is the untyped-parameter store's doing and not this
cast's). The write is gated on the operand having NO typespec, so it can only
ever ADD one. **THE ORDER IS UNCHANGED**: it sits in the loop that already runs
AFTER § patBailStopsMemberStamp68, and it touches neither size nor encoding.

### LAW B — § castHopSizeFollowsLiteral78

`src/ParamEmit.cpp`, one exemption in § patBailStopsMemberStamp68's size loop.
That loop's DIGITS guard asks "are the digits on this operand the producer's?"
by comparing what the mint wrote against `red72Int64`'s answer. On a cast
pass-thru the answer is NEITHER — the mint wrote the member-masked slang value
and the cast re-spell replaces it, but only AFTER this loop, because the landed
ORDER constraint puts the re-spell last. So the guard declines the size move,
and it declines it exactly where slang and the producer disagree about the
literal, i.e. on `signed'`. The exemption fires on the very same two calls the
re-spell fires on (`red76SignCastPassThru` + `red76SignCastConst`), so the size
it takes is the size of the constant the operand is about to become.
`patRedSz68` is NOT touched: it already answers 8 on all five `z2_hop78` cells.

### LAW C — § patOperandUnsignedArmValue78

`src/ParamEmit.cpp`, one `else if` beside the landed `vpiIntConst` writer, plus
`red78ArmBasedLeaf` in `src/EmitHelpers.h`. Gate: the reduce table encodes the
setter `vpiUIntConst`, the setter is an ARM, and it reaches a SIZED BASED
literal through parameter NAME hops. It writes `VpiValue` and `VpiDecompile`
and never the encoding or the size; `red72Int64` abstains on everything it does
not model, which leaves the landed branch standing. The based-leaf fence is
deliberate: it is the whole of the measured face (an arm of NAMES alone is
EQUAL on both binaries in every measured cell) and it is what makes the
a-priori census decidable from the sources.

### LAW D — § redShiftIsUnsignedSixtyFour78

`src/EmitHelpers.h`, four operators added to `red72Int64`'s accept list and two
compute arms, plus `red78ShiftCount` (the `& 63` the host applies). Because the
reduce table encodes every shift `vpiUIntConst`, LAW D is visible only through
LAW C's writer — and through the BAIL, which is the second half: a shift whose
leaf `get_value` refuses now answers `Red72::Refuses`, so the member stamp
stops where golden's does (`z4_shift78` `CQ` and `CT`, four probe cells).
`patRedSz68` is NOT touched, so `<<`/`<<<` keep their landed size abstention.

### R1 — § caSubstLeafCtSeesParens78

`src/TypeEmit.cpp`, `dimRedCtExpr79`'s `IntegerLiteral` arm reads the literal
through the committed paren-walking `red76VecSyntax` instead of its own
`syntax->kind` test. This is the bound walk catching up with the syntax walk
beside it, not a new rule (§ 2.4). It converts `y5_paren76` `CA`/`CB`/`CF`.

---

## 5. CENSUS, PREDICTION AND GATES (questions 5 and 6)

### The a-priori mover census, and its positive control

`census78.py` takes r11u66's setter population through the very
`census68_base` r11u73 and r11u76 import — **widened by one class**, because
LAW C writes on the reduce table's `vpiUIntConst` face, which `classify` calls
UINTISH. It re-subclassifies by this pass's divergence classes (UNSARM78,
SHIFT78, PAREN78, TSCAST78, SCAST) and is a superset by construction.
`--selftest` reads `SELFTEST PASS`, sighting every class on its own arm
([evidence/CENSUS.txt](evidence/CENSUS.txt)).

```
STRICT  AGG=785 BASED=6133 CAST=2223 INTISH=31 NAME=507 OTHER=5047
        PLAIN=1582 UINTISH=3701
        AGREE=4392  PAREN78=39  SCAST=21  SHIFT78=1503  UNSARM78=0
        CANDIDATES 13
LOOSE   AGG=1078 … UINTISH=3826
        AGREE=4613  PAREN78=39  SCAST=21  SHIFT78=1503  UNSARM78=0
        CANDIDATES 13
```

The base-class histogram reproduces r11u73's and r11u76's committed STRICT line
to the unit, which is the scanner's own regression check.

**`UNSARM78 = 0` in both corpora and both spans**: LAW C's gate is never
reached by a corpus setter. `SCAST`'s single candidate is still `cva6_equiv`,
which `discover_uhdm2rtlil` (`scripts/verify_golden.py:476-509`) does not
discover (no `project.f`, no `dut.sv`/`dut.v`), so LAW A and LAW B cannot move
a corpus byte either. What remains is SHIFT78 (13 tests, **every occurrence a
LEFT shift** — a `>>`/`>>>` pattern setter does not exist in either corpus, and
`patRedSz68` DELIBERATELY abstains on `<<`/`<<<`, so LAW D's size half cannot
fire there) and PAREN78 (39 occurrences, all of them a based literal inside a
TYPE CAST's parentheses, where the setter takes
§ patMemberCastNoDecomp's `Conversion` branch and the encoding classifier is
never consulted).

**THE PREDICTION IS THEREFORE: NO LAW MOVER IN EITHER CORPUS, IN EITHER MODE —
and it held.** `byteverify` reads **MOVERS 0 / 1608** on uhdm2rtlil and
**5 / 960** on surelog, and all five of those are the UVM coin, attributed
order-blind to the 4-line `UINT`/`vpiDecompile` line-number class with its own
positive control (§ 5 gate 5). Checked BY NAME against the two sweeps, every
candidate that PRODUCES a database produces the same one on both binaries —
`BlackBePipeInt`, `StructParamFuncBodyFieldCompare` and
`StructParamPatternInitCast` in both modes, and `Earlgrey_0_1` in both modes
(its four protected database pins included) — and the rest
(`Ariane2024`, `CastTypespec`, `cva6_equiv`, `Earlgrey_Verilator_01_05_21`,
`Earlgrey_Verilator_0_1`, `Earlgrey_nexysvideo`, `IncompTitan`, `Rp32`,
`rp32`) write no `slang.uhdm` in EITHER sweep — they are undiscovered or
rejected rows, so there is no byte of theirs to move. `byteverify`'s
`PATH_SETS_IDENTICAL` on both corpora is the same statement made over every
name at once.

**POSITIVE CONTROL** ([evidence/POSCTL.txt](evidence/POSCTL.txt)) — all four
faces sighted on a real corpus test's own sources
(`uhdm2rtlil/test/cva6_struct_param_field/dut.sv`, the r11u76 `cy76`
reproducer), one changed parameter per face, both binaries run in the SAME
directory writing the SAME output name because the serializer embeds the output
path:

```
  cz_base78   prc=0 lrc=0 SAME
  cz_shift78  prc=0 lrc=0 DIFFERS   (8'sd200 >>> 1)
  cz_uns78    prc=0 lrc=0 DIFFERS   (4'hFF + 1)
  cz_paren78  prc=0 lrc=0 DIFFERS   ((8'sd200) + 1)
  cz_ts78     prc=0 lrc=0 DIFFERS   (signed'(16'd5))
```

and on each face the cell CONVERTS to golden: `UINT:18446744073709551588 ->
UINT:100`, `UINT:16 -> UINT:256`, `@9 UINT:18446744073709551561 -> @7 INT:201`,
`ts=- -> ts=logic_typespec`. The corpus prediction is sighted, not assumed.

### Gates — all mandatory, all green

Full numbers in [evidence/GATES.txt](evidence/GATES.txt).

1. **Both binaries built `-j 2` in this pass's own worktree, md5s taken
   separately, frozen `chmod 555` before any sweep.** Pristine
   `963667a2299a360105d9677e3a065959`, byte-identical to the main tree's
   `build/slang-uhdm` at `7d0c7bf4`. Law `11d069db9ddbeff921367ab3b426b853`.
   Every `cmds.txt` audited by ABSOLUTE binary path; 0 name the main-tree
   binary.
2. **Goldens** `23 PASS / 0 FAIL` on the law binary AND on the pristine one;
   `SLANG_UHDM=/bin/false` gives `0 PASS / 23 FAIL`.
3. **uhdm2rtlil, both modes** `788 / 16 / 67` in each mode on each binary. The
   1742-row both-mode join against the committed `results/golden_uhdm2rtlil.csv`
   PASSES, the same join against this pass's OWN pristine sweep PASSES, and the
   testflags gate against `results/gate_uhdm2rtlil.csv` PASSES.
   `byteverify` u2r: **MOVERS 0 / 1608**, selfcheck 1607/1608.
4. **Surelog suite, `--mode both`** `474 CMP_EQUAL / 9 CMP_NOTEQUAL` default
   and `469 / 8` testflags, on BOTH binaries — the committed baseline, status
   histogram identical. Three rows differ from the committed CSV and all three
   are environment, on the PRISTINE sweep as much as on the law one:
   `Earlgrey_0_1/testflags`'s dump COLUMN reads blank on a `uhdm-dump` timeout
   draw under load (status stays `CMP_EQUAL`, and the DATABASE byte-compare —
   the actual pin — is IDENTICAL), and `LowMemLib`/`LowMemPkg`'s
   `SURELOG_FAIL` detail carries the workdir path. Against this pass's OWN
   pristine sweep only the two `LowMem*` path details differ at all.
5. **`byteverify` surelog, `SELFCHECK=1`**: **MOVERS 5 / 960**, selfcheck
   959/960. All five are the UVM coin, PREDICTED (the census predicts no LAW
   mover in either corpus) and attributed ORDER-BLIND
   ([evidence/MOVERS.txt](evidence/MOVERS.txt)): `MiniAmiq` ×2, `SeqDriver` ×2
   and `SimpleUVM` each move exactly **4 sorted lines**, every one a
   `UINT`/`vpiDecompile` PAIR whose value is a LINE NUMBER (1079→1231, 0→881,
   0→686, 618→0, 718→0) — the 0-or-4-line class the standing brief names.
   **Zero `vpiConstType` lines, zero `vpiSize` lines, zero `vpiTypespec`
   lines.** `Scoreboard/default` did not move at all on this draw.
   **COIN POSITIVE CONTROL**: the PRISTINE binary alone, three runs of
   `MiniAmiq/default` in one directory writing one name, gives three DIFFERENT
   databases (`94d5a6b85c5d` / `bce92816e69c` / `1fe8b718edbb`), and the
   order-blind diff of two of those pristine-only runs is the SAME 4-line
   `UINT`/`vpiDecompile` line-number class.
6. **Canaries.** `canaries.sh` surelog law `ok=51 changed=1` and PRISTINE
   `ok=51 changed=1` — the same row, Earlgrey's dump column; u2r
   `ok=8 changed=0`; `ctcan2.sh` PASS on surelog and on u2r; `canaudit.sh`
   PASS. Every protected DATABASE byte-identical between the two binaries, the
   brief's own pins included: SVSwitch `4842211c4030`, YosysVerx
   `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey
   `8bdf25272e08` / `59d0ee6d10c3`.
7. **The seven conversion rows** (`rowheads.sh`, the official `uhdm-cmp`, LHS
   golden) read `0 cmp lines / 0 heads` on the law binary: SeqDriver,
   SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg and Earlgrey_0_1 in both
   modes; Rggen/default unchanged at 64/1.
8. **The wide boundary** over **2161 committed probe arms** — every `.sv`
   carrying an assignment pattern, a signedness cast, a signed based literal or
   a parenthesised literal, where r11v76's own list was 1708 — path-neutral,
   both binaries
   ([evidence/BOUNDARY.2161arms.txt](evidence/BOUNDARY.2161arms.txt)):
   **2130 SAME, 16 DIFFERS, 15 NODB**. Fifteen of the sixteen are this pass's
   own nine grid and control arms plus the committed `y2_digits76`,
   `y3_castenc76`, `y5_paren76`, `cy_cast76`, `x9c_cast73`, `v3cast76` and
   `v4val76` witnesses, every one scored in §3 with **AWAY 0 and MOVED-WRONG
   0**. **No corpus-derived arm differs**, and every other pass-68/72/73/76
   grid arm and every landed encoding (49/55/65) and size (67) control re-runs
   BYTE-IDENTICAL.
   **THE SIXTEENTH IS THE COMMITTED LAYOUT PROOF.**
   `r10uvm154repro/l154_noenum.sv` contains no enum and no assignment pattern,
   so no law here can execute on it; its only moved bytes are one
   `UINT`/`vpiDecompile` pair `23179289 -> 23183385`, **delta exactly 4096**,
   sitting BELOW `\_weaklyReferenced:`. r10uvm154's own
   `layoutproof154.sh`, run on THIS binary pair, reads
   `JUDGE-VISIBLE HEAD IDENTICAL` / `TAIL DIFFERS with no enum in the source =>
   LAYOUT-DERIVED, not this law` / `LAYOUTPROOF OK`.
9. **`results/*.csv` untouched** — `git diff` vs `7d0c7bf4` over `results/` is
   empty.

---

## 6. RESIDUES

* **R0 — THE HOP PARAMETER'S OWN TYPESPEC, and it is not the cast's.**
  Every pattern operand reached through an untyped parameter NAME hop carries
  that parameter's `int_typespec` in golden and NOTHING in ours — and it is not
  a cast face at all: `x9c_cast73` op1 (`16'(5)`, a WIDTH cast) and op4
  (`16'd9 + 16'd1`, a plain ARM) both carry one located at the HOP's own
  declaration (`line:12:3-12:34` and `line:18:3-18:33` are `localparam HC1 =
  C16;` and `localparam HAD = AD;`). `z1_ts78` reproduces it on six more cells
  (`unsigned'(16'h5)` / `(16'o5)` / `(16'b101)` through a hop), where the SAME
  cast written DIRECTLY is golden NONE and EQUAL on both binaries — which is
  what proves the hop and not the cast is the author.
  `expr::Compare` reads `Typespec`, so every one of these is judge-visible.
  **This is the next pass's head**, and it is the widest typespec face left:
  its rule is "the constant reduceExpr hands back keeps the typespec of
  whatever produced it", and what produces it through a hop is the
  untyped-parameter store.
* **R1 — the DecConst hop's DANGLING ref_typespec.** `unsigned'(16'd5)` one hop
  up (`z1_ts78` op3) and `signed'(UD)` with `localparam UD = 16'd5`
  (`y3_castenc76` op6) are golden a `ref_typespec` with **no `vpiActual` at
  all**, where the same hop over a hex/octal/binary constant gets a proper
  `int_typespec`. Two cells, declined by construction (LAW A writes only where
  it measured a complete shape), and the rule behind the emptiness is
  Surelog's untyped-parameter typespec switch having no `vpiDecConst` arm.
* **R2 — the signedness cast's MINT face**, unchanged from r11u76's R2.
  `$signed` over a UInt/Binary/Hex/Oct operand and `$unsigned` over a NEGATIVE
  Int/Dec one mint at `ExprEval.cpp:4735-4770`, and the untyped-name rule then
  stores that at 32: `z2_hop78` op3 (`signed'(-8'sd100)` golden
  `const/32@7=INT:-100`) and op5 (`unsigned'(4'sb1111)` golden
  `const/32@7=INT:15`), `y3_castenc76` op3/op4/op7/op8/op9. The TYPESPEC on
  those cells is now golden's; the encoding, the value and the size are not.
* **R3 — a declared-type argument under a cast.** `signed'(TB)` over
  `byte TB = 8'd5` is golden `const/8@1=DEC:5` with a **`byte_typespec`**
  (`v3cast76` op1): reduceExpr hands back the declared parameter's own
  constant, typespec included. Our value and size are already golden's (r11v76
  measured the hop is right to follow); the typespec is declined here because
  writing the literal's answer over a declared type would be a guess. One cell
  per declared-type argument.
* **R4 — the UNKNOWN-digit operand is DROPPED, not folded.** `8'hAx + 1` is
  golden `UINT:11` at 64 and our walk emits NO OPERAND AT ALL for it
  (`z3_uns78` `CQ`, `v1unk76` ×6 — a SHAPE mismatch, three golden operands
  against our two). Unchanged on both binaries; this is the r11u73 R2/RV-2
  dropped-operand defect, recorded per the brief and not touched here.
* **R5 — the unfolded-operation SHAPE.** Where the producer's reduce refuses an
  arm golden keeps the OPERATION (`op11` / `op24` / `op42`) and our walk has
  already folded it to a constant. LAW D makes two more refusals visible to the
  BAIL — `z4_shift78` `CQ` and `CT` convert their four probe cells — but cannot
  un-fold the operand itself. `y5_paren76` `CD` is the one cell where R1's
  encoding fix therefore re-spells a constant golden does not have (§3).
* **R6 — a DIRECT width cast keeps the cast's target width.** `16'(5)` written
  as the member is golden `const/16@9=UINT:5` and ours `const/64`. One cell,
  r11u76's R5, untouched.
* **R7 — an UNSIZED based operand under a cast** is golden `const/-1@1=DEC:5`
  (`y5_paren76` `CZ` op5), `VpiSize` **-1**. Declined by construction;
  r11u76's R3, untouched.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wt 7d0c7bf4 && cd /tmp/wt && git apply -3 /tmp/r11u78.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2 && md5sum build/slang-uhdm      # 11d069db9ddb…
R=$PWD/tools/probe/r11u78repro
G=/tmp/g78 && mkdir -p $G/grid && cp $R/*.py $R/*.sh $G/ && cp $R/grid/*.sv $G/grid/
cp $PWD/tools/probe/r11u76repro/grid/*.sv $G/grid/
cp $PWD/tools/probe/r11v76repro/grid/*.sv $G/grid/
cp $PWD/tools/probe/r11v73repro/grid/{x1_sdec73,x7_sdecpos73,x9c_cast73}.sv $G/grid/
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris <pristine binary>   # rc for BOTH sides
  bash $G/run66.sh $G/grid/$a.sv law  $PWD/build/slang-uhdm
done
python3 $G/score78.py $G/grid pris law          # TO / AWAY / STILL / WRONG2
python3 $G/ts78.py    $G/grid/z1_ts78.{g,pris,law}.dump    # the typespec decode
python3 $R/census78.py --selftest && python3 $R/census78.py
# the positive control (five arms, same directory, same output name):
for a in cz_base78 cz_shift78 cz_uns78 cz_paren78 cz_ts78; do
  BND_PRIS=<pristine> BND_LAW=$PWD/build/slang-uhdm BND_ROOT=$G/grid \
    BND_OUT=/tmp/bndpc78 bash $G/bnd72.sh $a.sv; done
# the wide boundary (~25 min at -P 2):
cd tools/probe && grep -rlE "'\{|signed\s*'|\d+'s" $(find . -name '*.sv') \
  | sed 's#^\./##' | sort -u > /tmp/l78.txt
BND_PRIS=<pristine> BND_LAW=$PWD/../../build/slang-uhdm BND_ROOT=$PWD \
  BND_OUT=/tmp/bnd78 xargs -a /tmp/l78.txt -P 2 -I{} bash $R/bnd72.sh {}
```
