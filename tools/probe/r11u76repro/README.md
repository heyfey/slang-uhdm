# r11u76 — § redBasedLeafWrittenDigits76 and § castSignednessReturnsOperand76

**THE PRODUCER NEVER SEES A VALUE. IT READS THE DIGITS IT WAS HANDED — AND A
SIGNEDNESS CAST HANDS BACK THE OPERAND'S OWN CONSTANT.**

Base `2f728c97`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden in this directory is a real Surelog
v1.87 run through the committed `run66.sh`, and every arm records `slrc` /
`ourrc` / `slerr`; **all of them read `0 0 0`**.

| binary | md5 | what |
|---|---|---|
| pristine | `ca45217f2ac9f7766fc232a8be0ee319` | built in this pass's own worktree at `2f728c97` — byte-identical to the main tree's `build/slang-uhdm` |
| law | `7833a385a271030c33f8314403482bfc` | this patch |

Both frozen `chmod 555` before any sweep; every `cmds.txt` audited by absolute
binary path.

---

## 0. AN INSTRUMENT FIX THAT CHANGES THE STARTING POSITION

r11v73's **RV-6** recorded golden writing `signed'(16'd5)` as `const/16@1=`
with an **EMPTY value string**. There is no empty string. The committed shape
lister's value regex lists `UINT|INT|BIN|HEX|OCT|STRING|REAL|SCALAR` and **not
`DEC`**, so every `vpiDecConst` payload in every census and every ord66v/
sizeaxis tuple since r11u49 has printed as blank. `shape.py` here adds `DEC`
and `TIME`; the same cell reads

```
  golden  const/16@1=DEC:5      ours  const/16@9=UINT:5
```

and the law below follows from what is actually there. Nothing else about the
lister moved, and every landed arm re-scores identically under it (§5).

---

## 1. THE HEAD, RE-MEASURED AT THE BASE (question 1)

The three named witnesses, re-run unmodified at `2f728c97`. Cells are
`const/<VpiSize>@<VpiConstType>=<VpiValue>` off the flat `op75` operand list of
`uhdmtopModules work@…`, read by the DEC-aware `shape.py`.

**`x1_sdec73`** — r11v73's RV-1, the signed based-decimal VALUE. Operand 0 is
the candidate at a 64-bit member; `K+1`/`K+2` are 8-bit probes (8 = the walk
stamped the member width, 64 = it bailed at operand 0):

```
  member                    golden                    pristine
  CA 1'sd1 - 1              INT:0        probes 8/8   INT:-2   probes 64/64
  CB 4'sd15 - 1             INT:14       probes 8/8   INT:-2   probes 64/64
  CC 8'sd200 + 1            INT:201      probes 8/8   INT:-55  probes 64/64
  CD 16'sd40000 + 1         INT:40001    probes 8/8   INT:-25535 probes 64/64
  CI 2'sd2 * 2              INT:4        probes 8/8   INT:-4   probes 64/64
  CJ 32'sd4294967295 - 1    INT:4294967294 probes 8/8 INT:-2   probes 64/64
  CE/CF/CG (controls)       EQUAL
  CH DU - 1                 op11 (unfolded) probes 64/64  — EQUAL probes, the
                            shape residue r11u73 R2 already carries
```

**EIGHTEEN FULL cells STILL** — six candidates × (value + two probes) — exactly
the count the brief names. Our negative value also bails the member stamp, so
every one of these costs three cells and not one.

**`x7_sdecpos73`** — the hard controls, where the two readings agree on the
VALUE and the pristine binary is RIGHT:

```
  CA 1'sd1 * 1'sd1                      golden INT:1   pristine INT:1   EQUAL
  CC 1'sd1*1'sd1*1'sd1*1'sd1            golden INT:1   pristine INT:1   EQUAL
  CE 1'sd1 - 1'sd1                      golden INT:0   pristine INT:0   EQUAL
  CF K * 2                              golden INT:12  pristine INT:12  EQUAL
  CB 4'sd15 * 4'sd15                    golden INT:225           ours INT:1
  CD 2'sd3 * 2'sd3                      golden INT:9             ours INT:1
  CG 32'sd4294967295 * same             golden INT:-8589934591   ours INT:1
                                        golden probes 64/64  ours 8/8
```

**`x9c_cast73`** — r11v73's RV-6, the signedness-cast ENCODING, read with the
fixed lister:

```
  op1 HC1 = 16'(5)          golden const/32@9=UINT:5   EQUAL     (control)
  op2 HCS = signed'(16'd5)  golden const/16@1=DEC:5    ours const/16@9=UINT:5
  op3 HCU = unsigned'(16'sd5) golden const/16@1=DEC:5  ours const/16@9=UINT:5
  op4 HAD = 16'd9 + 16'd1   golden const/32@7=INT:10   EQUAL     (control)
```

The SIZE is already right on both cast cells (pass 72's
§ redSignCastMintsNothing73v); the `vpiConstType` and the `vpiDecompile` are
not, and both are fields `Compare` reads.

---

## 2. THE PRODUCER, LINE BY LINE (question 2)

### Where the `DEC:` string enters `get_value`

`ExprEval::get_value` (`~/git-repos/UHDM/templates/ExprEval.cpp:1947-2056`)
never receives a value. It receives a `constant*` and reads its `VpiValue`
STRING:

```
  :1978 vpiDecConst   sv.remove_prefix("DEC:"); NumUtils::parseInt64(sv, ...)
  :1969 vpiBinaryConst  if (expr->VpiSize() > 64) invalid; else parseBinary
  :1984 vpiHexConst     if (expr->VpiSize() > 64) invalid; else parseHex
  :1998 vpiOctConst     if (expr->VpiSize() > 64) invalid; else parseOctal
```

and the string was written by Surelog's literal arm
(`Surelog/src/DesignCompile/CompileExpression.cpp:543-563`) from the SOURCE
SPELLING: `8'sd200` is `DEC:200`, `8'shC8` is `HEX:C8`, `4'sb1111` is
`BIN:1111`, `4'd20` is `DEC:20`. **No truncation to the declared width and no
sign anywhere in the path.** `NumUtils::parse*` then reads those digits in
their own base, decimal STRICTLY into an `int64_t` and b/o/h LENIENTLY (signed
first, then unsigned cast down).

We read slang's stored `SVInt` instead — which IS truncated to the declared
width and IS sign-extended (`SVInt::as<uint64_t>`,
`~/.local/include/slang/numeric/SVInt.h:251-267`). The two readings differ on
exactly two classes: an `s` marker with the top bit set, and digits that
overflow the declared width. Measured, `y1_sdval76` / `y2_digits76`:

```
  setter                  golden              ours (slang's SVInt)
  8'sd200 + 1             INT:201             INT:-55
  4'sd15 - 1              INT:14              INT:-2
  16'sd40000 + 1          INT:40001           INT:-25535
  -8'sd200                INT:-200            INT:56
  8'sd200 / 8'sd2         INT:100             INT:-28
  8'sd200 % 8'sd7         INT:4               INT:0
  2'sd3 ** 2              INT:9               INT:1
  4'd20 + 1               INT:21              INT:5
  2'b111 + 1              UINT:8              UINT:4
  3'o77 + 1               UINT:64             UINT:8
  4'hFF + 1               UINT:256            UINT:16
  8'shC8 * 8'shC8         INT:40000           INT:3136
  4'sb1111 * 4'sb1111     INT:225             INT:1
  3'so7 + 1               UINT:8              UINT:0
```

and it decides the REFUSAL as well, because it is the same `parse*` call:

```
  4'd99999999999999999999 + 1   golden an UNFOLDED op24  (the digits overflow
  4'h1FFFFFFFFFFFFFFFFFF + 1    golden an UNFOLDED op24   int64/uint64 at FOUR
  4'd9223372036854775807 + 1    golden INT:-9223372036854775808  declared bits)
```

`4'd9223372036854775807 + 1` is the decisive one: INT64_MAX parses, so the arm
folds and WRAPS, where the stored 4-bit pattern would have folded to 16.

The parser is **not transcribed a second time**. `srlgNegLitGetValue30`
(`src/EmitHelpers.h`, § negLitPkgRetFoldNested30, measured on r10vbuvm30's own
goldens — `-4'd20` folds to `-20` and `-4'hFF` to `-255`) already IS
`get_value`'s decimal/binary/octal/hex matrix with its width guard. This pass
calls it. The literal's spelling is rebuilt from its own three tokens (size,
base, value), which is what `rawTextLit` reassembles for a macro-crossing
literal.

### Parentheses

`Expression::create` (`~/git-repos/slang/source/ast/Expression.cpp:791-799`
and `:1002`) binds a `ParenthesizedExpression` by recursing into the inner
syntax and then **overwrites** the result's `syntax` pointer with the
parenthesized node. A bound `(16'd5)` is therefore an `IntegerLiteral` whose
`syntax->kind` is `ParenthesizedExpression`, and every reader of a written
spelling has to walk through that. `signed'(X)`'s operand is parenthesized BY
GRAMMAR (`SignedCastExpressionSyntax` holds a `ParenthesizedExpressionSyntax&
inner`), so LAW B cannot see its own literal without the walk. Measured,
`y5_paren76`: `(8'sd200) + 1` is golden `INT:201` and `((8'shC8)) * 2` golden
`INT:400`, exactly as the unparenthesised spellings.

### What the cast arm stores

Surelog rewrites `signed'(X)` / `unsigned'(X)` into a `$signed` / `$unsigned`
`sys_func_call` — our DEF view already emits exactly that, byte-identical to
golden's. `ExprEval::reduceExpr`'s arm for that call
(`~/git-repos/UHDM/templates/ExprEval.cpp:4682-4781`) reduces the argument and
branches on the reduced constant's OWN `VpiConstType`:

```
  $signed   + vpiIntConst / vpiDecConst          ->  return c          (:4712)
  $signed   + UInt/Binary/Hex/Oct                ->  MINT INT:<res>    (:4763)
  $unsigned + vpiIntConst/vpiDecConst, value>=0  ->  return c          (:4716)
  $unsigned + vpiIntConst/vpiDecConst, value<0   ->  MINT UINT:<masked>(:4721)
  $unsigned + UInt/Binary/Hex/Oct                ->  result = c        (:4779)
```

On a `return c` face **nothing is created**: the constant that leaves the call
IS the argument's, with its own `VpiSize`, `VpiConstType`, `VpiValue` and
`VpiDecompile` (the literal's source spelling). `$signed` additionally hangs a
signed `logic_typespec` hint on it when it had no typespec, and that is the
whole of the difference.

**THE JUDGE READS THE MOVE.** `constant::Compare`
(`~/git-repos/UHDM/build/generated/src/constant.cpp:58-71`) compares
`VpiConstType` and nothing else of its own; `expr::Compare` (`expr.cpp:83-103`)
compares `VpiDecompile`, `VpiSize` and `Typespec`. `VpiValue` is NOT compared.
So of the four fields LAW B moves, **three are judge-visible** — the answer to
the brief's "wrong-to-wrong on the judge?" is NO on this shape.

---

## 3. THE GOLDEN GRID (question 3)

Five new arms and three committed ones, every member read EXACTLY ONCE, scored
by the committed `ord66v.py` on the JUDGE's own fields (`vpiConstType` +
`vpiValue` for ENC, plus `vpiSize` for FULL) and by `sizeaxis.py` on the size
field alone ([evidence/GRID.8arms.txt](evidence/GRID.8arms.txt)).

| arm | what it grids | FULL TO / STILL |
|---|---|---|
| `y1_sdval76` | the signed based-decimal VALUE × widths 1/2/4/8/16/32/64 × `+ - * / % **` × unary minus × NAME hop × TYPED name × nesting, with positive, unsigned and int64max controls | 33 / 0 |
| `y2_digits76` | digits vs stored pattern across ALL FOUR BASES, and whether a signed `h`/`b`/`o` literal sign-extends for the producer | 10 / 5 |
| `y3_castenc76` | the cast: `signed'` / `unsigned'` / `$signed` / `$unsigned` × operand kind (based `d`/`h`/`b`/`o`, a NAME, an ARM, a MINTED name, an unsized decimal) × position (one hop above vs written DIRECTLY as the member), with the width-cast and arithmetic controls | 9 / 7 |
| `y4_pos76` | the POSITION face (a bare based literal AT operand 0, all four bases) and the beyond-int64 DIGITS refusal, plus the committed `w3_dec73` faces | 7 / 4 |
| `y5_paren76` | parentheses on the value and refusal faces, and the cast faces the pass-thru law must DECLINE (`$signed` over octal, an UNSIZED operand, a cast inside an arm) | 8 / 7 |
| `x1_sdec73` | committed (r11v73), RV-1's eighteen cells | 18 / 1 |
| `x7_sdecpos73` | committed (r11v73), the hard controls | 5 / 0 |
| `x9c_cast73` | committed (r11v73), RV-6's two cells | 2 / 0 |

**Totals over the eight arms: FULL TO 92, AWAY 0, MOVED-WRONG 0, STILL 24,
WRONG2 0. SIZE-AXIS TO 51, AWAY 0.**

### The three decisive tables

**`y1_sdval76` — the value face, and the bail rides with it.** Nineteen
members, every one converted (FULL TO 33, STILL 0). The four cells that decide
the shape of the law:

```
  member                     golden       what it rules out
  CD 2'sd3 + 1               INT:4        "negate the stored value": 2'sd3 is
                                          -1 to slang and 3 to the producer
  CG SD8 + 1, SD8 = 8'sd200  INT:201      a NAME hop carries the digits too
  CI -8'sd200                INT:-200     the unary minus negates the DIGITS
  CN TSD + 1, byte TSD=8'sd7 INT:8        a TYPED name is not this face (EQUAL
                                          on both binaries)
```

**`y2_digits76` — it is the digits in EVERY base, not just decimal.**

```
  4'd20 + 1        golden INT:21    (digits 20, not the 4-bit pattern 4)
  2'b111 + 1       golden UINT:8    (digits 111b = 7, not the 2-bit pattern 3)
  3'o77 + 1        golden UINT:64   (digits 77o = 63, not 7)
  4'hFF + 1        golden UINT:256  (digits FF = 255, not 15)
  8'shC8 + 1       golden UINT:201  (digits C8 = 200, not -56)
  4'sb1111 - 1     golden INT:14    (digits 1111b = 15, not -1)
  3'so7 + 1        golden UINT:8    (digits 7, not -1)
  4'd3+1 / 8'hC8+1 / 8'sh7F+1 / K*2   EQUAL on both binaries  (controls)
```

**`y3_castenc76` + `y5_paren76` — which cast faces hand the operand back.**
Operand 0 is a guaranteed bail (`8'hxA`) and the members are 24 bits wide, so
every operand after it prints `reduceExpr`'s own answer:

```
  member                        golden                pristine          law
  signed'(16'd5)          hop   const/16@1=DEC:5      @9 UINT:5    ->  golden
  unsigned'(16'sd5)       hop   const/16@1=DEC:5      @9 UINT:5    ->  golden
  unsigned'(16'o5)        hop   const/16@4=OCT:5      @9 UINT:5    ->  golden
  signed'(UD), UD=16'd5   hop   const/16@1=DEC:5      @9 UINT:5    ->  golden
  $signed(16'd5)          hop   const/16@1=DEC:5      @9 UINT:5    ->  golden
  $unsigned(16'sd5)       hop   const/16@1=DEC:5      @9 UINT:5    ->  golden
  signed'(16'd5)       DIRECT   const/16@1=DEC:5      const/64@9=UINT:5 -> golden
  unsigned'(16'sd5)    DIRECT   const/16@1=DEC:5      const/64@9=UINT:5 -> golden
  $signed(16'd5)       DIRECT   const/16@1=DEC:5      const/64@9=UINT:5 -> golden
  $unsigned(16'h5)        hop   const/16@5=HEX:5      @9 UINT:5    ->  golden
  $unsigned(16'b101)      hop   const/16@3=BIN:101    @9 UINT:5    ->  golden
  signed'((16'd5))        hop   const/16@1=DEC:5      @9 UINT:5    ->  golden
  --- DECLINED, and golden proves each one has to be ---
  signed'(16'h5)                const/32@7=INT:5      const/16@9=UINT:5   STILL
  signed'(16'b101)              const/32@7=INT:5      const/16@9=UINT:5   STILL
  $signed(16'o5)                const/32@7=INT:5      const/16@9=UINT:5   STILL
  signed'(16'd9 + 16'd1)        const/32@7=INT:10     const/16@9=UINT:10  STILL
  signed'(MN), MN = -16'd5      const/32@7=INT:-5     const/24@9=UINT:…   STILL
  signed'(5)  (unsized)         const/32@7=INT:5      const/32@9=UINT:5   STILL
  signed'('d5) (unsized based)  const/-1@1=DEC:5      const/32@9=UINT:5   STILL
  unsigned'(16'd5) + 0          const/32@7=INT:5      const/32@9=UINT:5   STILL
  16'd5 / 16'h5 written DIRECTLY  EQUAL on both binaries      (controls)
  16'(5) hop / 16'd9+16'd1 hop    EQUAL on both binaries      (controls)
```

`signed'('d5)` is the cell that proves the UNSIZED decline is not timidity:
golden's `VpiSize` there is **-1**, which is the producer's own answer for an
unsized based literal and a different measurement from this law's.

### The cont_assign road

`caread55.py` `ELAB` listings diffed against golden's, line for line
([evidence/CAROAD.txt](evidence/CAROAD.txt)):

```
  arm             pristine   law
  y1_sdval76        26        0     <- identical to golden
  x7_sdecpos73       6        0     <- identical to golden
  x1_sdec73         14        2
  y2_digits76       22       10
  y4_pos76          12       10
  y5_paren76        22       20
  y3_castenc76 / x9c_cast73   unchanged
```

No arm gets worse on that road, and two become identical to golden's.

---

## 4. THE TWO GATED LAWS (question 4)

Each is droppable alone: they touch different predicates and different write
sites, and neither reads the other's result.

### LAW A — § redBasedLeafWrittenDigits76

`src/EmitHelpers.h`. One new reader, `red76BasedLeafDigits`, which rebuilds the
literal's spelling from its own tokens and hands it to the committed
`srlgNegLitGetValue30`. It is used TWICE, and that is the point:

* in `red72WideBasedLeaf`'s `inArm` branch, as the REFUSAL — subsuming the old
  `base != 'd' -> width > 64` clause (`srlgNegLitGetValue30` carries
  `get_value`'s own size guard on b/o/h and none on `d`) and adding the
  digit-overflow face the width test could not see;
* in `red72Int64`, immediately after that refusal, as the VALUE.

Two faces of one string, one call, so they cannot drift apart — which is
exactly how r11v73's finding 1 arose (a refusal on the sign-extended pattern
beside a value from somewhere else). The syntax read walks parentheses.

**CONFINED TO `inArm`.** At operand 0 a based literal is emitted VERBATIM by
the literal path and already byte-matches golden on all four bases
(`y4_pos76` `A`-`D`: `8'sd200` is `const/64@1=DEC:200`, `8'shC8` `@5=HEX:C8`,
`4'sb1111` `@3=BIN:1111`, `4'd20` `@1=DEC:20` — identical on both binaries), so
the table must not re-read it there. An UNKNOWN digit keeps its landed
abstention, ahead of the new read.

### LAW B — § castSignednessReturnsOperand76

`src/EmitHelpers.h` (`red76SignCastPassThru` + `red76SignCastConst`) and two
sites in `src/ParamEmit.cpp`:

* `patRedSz68`'s `Conversion`/`Call` arm answers the ARGUMENT literal's width
  instead of `reduceExpr`'s 64, because on a `return c` face no constant is
  created to re-size;
* one loop over the finished operand list re-spells `VpiConstType` /
  `VpiValue` / `VpiDecompile` from the literal's own tokens.

**THE ORDER IS LOAD-BEARING.** That loop runs AFTER
§ patBailStopsMemberStamp68, because that law's size move is gated on the
operand still carrying a `vpiUIntConst`/`vpiIntConst` — which is what the
branches above wrote. Re-spelling the encoding first would silently withdraw
the size move and take `y3_castenc76` op1/op2/op5/op6/op10/op11 from golden's
16 to the member's 24: **six AWAY cells, measured**, which is why the write is
where it is. The SIZE is never touched by the re-spelling.

The predicate declines everything the producer MINTS, and § 3 shows golden
proving each decline. `red73MintsUntypedInt`'s `SignedCastExpression`
abstention (r11v73) is left exactly as landed; its § block now records WHY it
is right and which cells it leaves STILL.

---

## 5. CENSUS, PREDICTION AND GATES (questions 5 and 6)

### The a-priori mover prediction, and its positive control

`census76.py` re-subclassifies r11u66's INTISH+CAST population by this pass's
divergence classes — SDECVAL (a based literal whose written digits are worth
something other than slang's `SVInt`: an `s` marker with the top bit set, or
digits overflowing the declared width), SDECREF (the same divergence on the
refusal side) and SCAST (a signedness cast whose argument, through NAME hops,
is a SIZED based literal on the producer's `return c` face). It reads SOURCES
only and is a superset by construction. `--selftest` is the positive half and
reads `SELFTEST PASS`, sighting SDECVAL in `y1_sdval76` / `y2_digits76` /
`x1_sdec73` / `x7_sdecpos73`, SDECREF in `y4_pos76` and SCAST in
`y3_castenc76`.

```
STRICT  AGG=785 BASED=6133 CAST=2223 INTISH=31 NAME=507 OTHER=5047
        PLAIN=1582 UINTISH=3701     AGREE=2233 SCAST=21     CANDIDATES 1
LOOSE   AGG=1078 … INTISH=50        AGREE=2329 SCAST=21     CANDIDATES 1
        SDECVAL=0 and SDECREF=0 EVERYWHERE, in both corpora, in both spans
```

The base-class histogram reproduces r11u73's committed STRICT line to the unit,
which is the scanner's own regression check.

The single SCAST candidate is `cva6_equiv`
(`unsigned'(CVA6ConfigDcacheFlushOnFence)` and two siblings, over
`localparam … = 1'b0`), and **`cva6_equiv` is not a discovered row**:
`discover_uhdm2rtlil` (`scripts/verify_golden.py:476-509`) takes `project.f`
or `dut.sv`/`dut.v` per directory and that directory has none of the three. So
the prediction is **NO MOVERS IN EITHER CORPUS, IN EITHER MODE**.

**POSITIVE CONTROL** ([evidence/POSCTL.txt](evidence/POSCTL.txt)) — all three
faces sighted on a real corpus test's own sources
(`uhdm2rtlil/test/cva6_struct_param_field/dut.sv`), one changed parameter per
face, both binaries run in the SAME directory writing the SAME output name
because the serializer embeds the output path:

```
  cy_base76  prc=0 lrc=0 SAME
  cy_sdec76  prc=0 lrc=0 DIFFERS   (8'sd200 + 1 in a 64-bit struct field)
  cy_ref76   prc=0 lrc=0 DIFFERS   (4'd99999999999999999999 + 1)
  cy_cast76  prc=0 lrc=0 DIFFERS   (unsigned'(16'sd5))
```

and on each face the cell CONVERTS to golden: `cy_sdec76` `PA` op0
`INT:-55 -> INT:201`, `cy_ref76`'s two probes `const/8 -> const/64` (golden's
64/64), `cy_cast76` `PA` op0 `@9 UINT:5 -> @1 DEC:5`. The corpus zero is
sighted, not assumed.

### The wide boundary

`bnd72.sh` over **all 1122 probe arms that contain an assignment pattern** —
the 1113 committed at `2f728c97` plus this pass's nine; path-neutral, both
binaries ([evidence/BOUNDARY.1122arms.txt](evidence/BOUNDARY.1122arms.txt)):
**1105 SAME, 11 DIFFERS, 6 NODB** (arms both binaries reject identically,
`prc=lrc=3`). The eleven are this pass's own eight grid and control arms
(`y1`–`y5`, `cy_sdec76`, `cy_ref76`, `cy_cast76` — `cy_base76` reads SAME,
which is the control stated as bytes) and the three committed r11v73 witnesses
(`x1_sdec73`, `x7_sdecpos73`, `x9c_cast73`), each scored in §3 against a real
Surelog v1.87 golden with **AWAY 0 and MOVED-WRONG 0**. **No corpus-derived
arm differs, and no earlier pass's arm differs** — every pass-72/73 grid arm
(`x2`, `x3`, `x4`, `x5`, `x6b`, `xa_powinf73`, `w1`–`w7`, `t3`, `t7`, `v1`,
`v4`, `v7`) and every landed encoding (49/55/65) and size (67) control re-runs
BYTE-IDENTICAL.

### Gates — all mandatory, all green

Full numbers in [evidence/GATES.txt](evidence/GATES.txt).

1. **Both binaries built `-j 2` in this pass's own worktree, md5s taken
   separately, frozen `chmod 555` before any sweep.** Pristine
   `ca45217f2ac9f7766fc232a8be0ee319`, byte-identical to the main tree's
   `build/slang-uhdm` at `2f728c97`. Law `7833a385a271030c33f8314403482bfc`.
   All 6646 `cmds.txt` audited by ABSOLUTE binary path; 0 name the main-tree
   binary.
2. **Goldens** `23 PASS / 0 FAIL` on the law binary AND on the pristine one;
   `SLANG_UHDM=/bin/false` gives `0 PASS / 23 FAIL`.
3. **uhdm2rtlil, both modes** `788 / 16 / 67` in each mode on each binary. The
   1742-row both-mode join against the committed `results/golden_uhdm2rtlil.csv`
   reads **0 differing ROWS**, the same join against this pass's OWN pristine
   sweep reads 0, and the testflags gate against `results/gate_uhdm2rtlil.csv`
   PASSES. `byteverify` u2r: **MOVERS 0 / 1608**, selfcheck 1607/1608.
4. **Surelog suite, `--mode both`** `474 CMP_EQUAL / 9 CMP_NOTEQUAL` default
   and `469 / 8` testflags, on BOTH binaries — the committed baseline. Three
   rows differ from the committed CSV and all three are environment, on the
   PRISTINE sweep as much as on the law one: `Earlgrey_0_1`'s dump COLUMN
   reads blank on a `uhdm-dump` timeout draw under load (status stays
   `CMP_EQUAL`, and the DATABASE byte-compare — the actual pin — is
   IDENTICAL), and `LowMemLib`/`LowMemPkg`'s `SURELOG_FAIL` detail carries the
   workdir path.
5. **`byteverify` surelog, `SELFCHECK=1`**: **MOVERS 4 / 960**, selfcheck
   959/960. All four are the UVM coin, PREDICTED (the census predicts zero LAW
   movers) and attributed ORDER-BLIND: `Scoreboard/default` reads **0** sorted
   lines (92 unsorted — the pure `svunit_pkg` `vpiTaskFunc` order flip), and
   `MiniAmiq` ×2 and `SeqDriver` read **4** sorted lines each, every one a
   `UINT`/`vpiDecompile` pair whose value is a LINE NUMBER — the 0-or-4-line
   class the standing brief names. Zero `vpiConstType` lines, zero `vpiSize`
   lines. **COIN POSITIVE CONTROL**: the PRISTINE binary alone, three runs of
   `MiniAmiq/default`, gives three DIFFERENT databases
   (`3d3d9aaec5ef` / `8d96a0cdaa94` / `a40d164d30ae`), and the order-blind
   diff of two of those pristine-only runs is the SAME 4-line
   `UINT`/`vpiDecompile` line-number class.
6. **Canaries.** `canaries.sh` surelog law `ok=51 changed=1` (Earlgrey's dump
   column) against pristine `ok=50 changed=2` (the same class, both modes);
   u2r `ok=8 changed=0`; `ctcan2.sh` `ok=58 changed=0` PASS on surelog and
   `ok=1 changed=0` PASS on u2r; `canaudit.sh` `audited=29 UNCOVERED=0
   FENCE-BREACH=0`. Every protected DATABASE byte-identical between the two
   binaries, the brief's own pins included: SVSwitch `4842211c4030`, YosysVerx
   `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey
   `8bdf25272e08` / `59d0ee6d10c3`.
7. **The seven conversion rows** (`rowheads.sh`, the official `uhdm-cmp`, LHS
   golden) read `0 cmp lines / 0 heads` on the law binary exactly as on the
   pristine one: SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg and
   Earlgrey_0_1 in both modes; Rggen/default unchanged at 64/1.
8. **`results/*.csv` untouched** — `git diff` vs `2f728c97` over `results/` is
   empty.

---

## 6. RESIDUES

* **R0 — the UNSIGNED arm's value half.** Five cells on `y2_digits76`
  (`2'b111 + 1` golden `UINT:8` ours `UINT:4`, `3'o77 + 1` golden `UINT:64`,
  `4'hFF + 1` golden `UINT:256`, `8'shC8 + 1` golden `UINT:201`, `3'so7 + 1`
  golden `UINT:8`). The producer's digits reach only the `vpiIntConst` writer,
  which is gated on `caSubstLeafCt56(setter) == vpiIntConst`; an operand golden
  encodes `vpiUIntConst` keeps the generic branch's member-masked slang value.
  The VALUE is now known for every one of them — it is the same
  `red72Int64` answer — and what is missing is a writer on the unsigned arm.
  **This is the next pass's head.**
* **R1 — `caSubstLeafCt56` is PARENTHESIS-BLIND.** `(8'sd200) + 1`,
  `(4'd20) + 1` and even the control `(8'd7) + 1` are golden `@7 INT` and ours
  `@9 UINT` on BOTH binaries (`y5_paren76` `CA`/`CB`/`CF`): the encoding
  classifier reads the setter's syntax and a parenthesized INTISH setter falls
  out of its INTISH branch. Three cells, orthogonal to both laws here, and the
  same `red76VecSyntax` walk fixes it.
* **R2 — the signedness cast's MINT face.** `$signed` over a UInt/Binary/Hex/
  Oct operand and `$unsigned` over a NEGATIVE Int/Dec one mint `INT:<res>` /
  `UINT:<masked>` at the OPERAND's size (`ExprEval.cpp:4735-4770`), and the
  untyped-name rule then stores that at 32. Six cells (`y3_castenc76`
  op3/op4/op7/op8/op9, `y5_paren76` `CZ` op4). Modelling it needs the sign-
  extension arithmetic and a `red73MintsUntypedInt` cast arm that answers TRUE
  there — both measured above, neither transcribed here.
* **R3 — an UNSIZED based operand under a cast** is golden `const/-1@1=DEC:5`
  (`y5_paren76` `CZ` op5): `VpiSize` **-1**, the producer's own answer for an
  unsized based literal. Declined by construction; one arm would settle whether
  the -1 survives every stamp.
* **R4 — a cast INSIDE an arm** (`unsigned'(16'd5) + 0`, `signed'(16'd5) + 0`)
  is golden `@7 INT` and ours `@9 UINT`: the encoding classifier declines a
  `Conversion` operand. Two cells.
* **R5 — a DIRECT width cast keeps the cast's target width.** `16'(5)` written
  as the member is golden `const/16@9=UINT:5` and ours `const/64` — the same
  "`reduceExpr` answers 64 for a cast" answer LAW B corrected for the
  signedness faces, still standing for the width face. One cell.
* **R6 — the unfolded-operation SHAPE, five cells.** Where the producer's
  reduce refuses an arm golden keeps the OPERATION (`op11` / `op24`) and our
  walk has already folded it to a constant. LAW A makes the refusal visible to
  the bail — which is where all the probe conversions come from — but cannot
  un-fold the operand. r11u73's R2, unchanged.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wt 2f728c97 && cd /tmp/wt && git apply -3 /tmp/r11u76.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2 && md5sum build/slang-uhdm      # 7833a385a271…
R=$PWD/tools/probe/r11u76repro
G=/tmp/g76 && mkdir -p $G/grid && cp $R/*.py $R/*.sh $G/ && cp $R/grid/*.sv $G/grid/
cp $PWD/tools/probe/r11v73repro/grid/{x1_sdec73,x7_sdecpos73,x9c_cast73}.sv $G/grid/
for a in y1_sdval76 y2_digits76 y3_castenc76 y4_pos76 y5_paren76 \
         x1_sdec73 x7_sdecpos73 x9c_cast73; do
  bash $G/run66.sh $G/grid/$a.sv pris <pristine binary>   # rc for BOTH sides
  bash $G/run66.sh $G/grid/$a.sv law  $PWD/build/slang-uhdm
  python3 $G/ord66v.py  $G/grid/$a.{g,pris,law}.dump $a
  python3 $G/sizeaxis.py $G/grid/$a.{g,pris,law}.dump $a
  python3 $G/list76.py  $a law $G/grid
  diff <(python3 $G/caread55.py $G/grid/$a.g.dump ELAB) \
       <(python3 $G/caread55.py $G/grid/$a.law.dump ELAB)
done
python3 $R/census76.py --selftest && python3 $R/census76.py
# the positive control (four arms, same directory, same output name):
for a in cy_base76 cy_sdec76 cy_ref76 cy_cast76; do
  BND_PRIS=<pristine> BND_LAW=$PWD/build/slang-uhdm BND_ROOT=$G/grid \
    BND_OUT=/tmp/bndpc bash $G/bnd72.sh $a.sv; done
# the wide boundary (1122 arms, ~25 min at -P 2):
cd tools/probe && grep -rl "'{" $(find . -name '*.sv') | sed 's#^\./##' | sort -u > /tmp/l.txt
BND_PRIS=<pristine> BND_LAW=$PWD/../../build/slang-uhdm BND_ROOT=$PWD \
  BND_OUT=/tmp/bnd xargs -a /tmp/l.txt -P 2 -I{} bash $R/bnd72.sh {}
```
