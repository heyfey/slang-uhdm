# r11u72 — § patOperandIntSixtyFour72 and § redTableOneHome72

**THE REDUCE TABLE'S VALUE HALF IS THE PRODUCER'S int64 ARITHMETIC, AND THE
TWO PROVEN-FOLD PREDICATES MERGE INTO ONE HOME.**

Base `9637b9fd`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil v0.68). Every golden in this directory is a real Surelog v1.87 run
through `run66.sh`, and every arm records `slrc` / `ourrc` / `slerr`; all of
them read `0 0 0`.

| binary | md5 | what |
|---|---|---|
| pristine | `d7d16dbc92e585c323223489a790ad76` | byte-identical to the main tree at `9637b9fd` |
| law | `8794860fd835afa68733006ee62a7438` | this patch |
| nf (experiment, NOT shipped) | `54dd19826ab4e56e7b573c02c60f69f6` | the law with § patBailNegCorroborated68v removed (§4) |

Both frozen `chmod 555` before any sweep; every `cmds.txt` audited by absolute
binary path.

---

## 1. THE HEAD, RE-MEASURED AT THE BASE (question 1)

`a2_uwrap66` and `a7_arith66` are committed r11v66 arms, re-run here
unmodified. `uhdmtopModules work@…​.C`, the flat `op75` operand list:

```
a2_uwrap66  (KU,IU,BU,LU are UNSIGNED 32/32/8/64 holding 3)
  setter      golden                      pristine (9637b9fd)
  KU - 5      const/32 ct7 INT:-2         const/32 ct7 INT:4294967294
  IU - 5      const/64 ct7 INT:-2         const/32 ct7 INT:4294967294
  BU - 5      const/64 ct7 INT:-2         const/8  ct7 INT:4294967294
  LU - 5      const/64 ct7 INT:-2         const/64 ct7 INT:0
  3 - 5       const/64 ct7 INT:-2         const/32 ct7 INT:-2
  KU * 2      const/64 ct7 INT:6          const/64 ct7 INT:6
  64'hF…F - 1 const/64 ct7 INT:-2         const/64 ct7 INT:0

a7_arith66  (BIG = int 2000000000)
  BIG * 2     const/32 ct7 INT:4000000000 const/32 ct7 INT:-294967296   <- the one
  BIG + BIG   const/64 ct9 UINT:4000000000    equal                        regressed
  SB * SB     const/32 ct7 INT:10000          equal                        field cell
  SH * SH     const/32 ct7 INT:900000000      equal
  SB - 200    const/32 ct7 INT:-100           equal
  K * K       const/64 ct7 INT:36             equal
```

`x1_optable` (r11v56) reads golden and pristine EQUAL on every value cell —
its two differing cells are the `^` and comparison SHAPE residues (`bxr`
golden `op30`, `cmp` golden `BIN:1`@1), which this pass does not touch.
`x3_names` differs on exactly one cell: `localparam MD = -16'd5` read as a
member is golden `INT:-5`@32 and pristine `INT:65531`@16.

The `LU - 5` and `64'hF…F - 1` cells print `INT:0` because we wrote
`INT:18446744073709551614`, a digit string UHDM re-renders through
`parseInt64` as 0. On the cont_assign road the same class prints the raw
string: `t1_arith72` `y8` is pristine `vpiDecompile:18446744073709551614` and
`y12` is pristine `vpiDecompile:-18446744073414584320`.

---

## 2. THE PRODUCER'S int64 ARMS, LINE BY LINE (question 2)

`~/git-repos/UHDM/templates/ExprEval.cpp`, `reduceExpr`. Each arm reduces its
operands, reads each one with `get_value` **as `int64_t`**, and computes in
`int64_t` — the result width never enters:

```
:3301  vpiAddOp  (signed arm)  int64_t val = val0 + val1      VpiSize = max(l,r)
:3415  vpiMinusOp             int64_t val = -val0             VpiSize = operand's
:3454  vpiSubOp               int64_t val = val0 - val1       VpiSize = 64
:3490  vpiMultOp              int64_t val = val0 * val1       VpiSize = 64
:3726  vpiModOp               int64_t val = val0 % val1       (val1 != 0)
:3782  vpiPowerOp   val = static_cast<int64_t>(std::pow<int64_t>(val0, val1))
:3822  vpiDivOp               int64_t val = num / divisor     (divisor != 0)
```

each writing `INT:<val>` and `VpiDecompile(<val>)` — and `expr::Compare`
(`~/git-repos/UHDM/build/generated/src/expr.cpp:90`) reads `VpiDecompile`.

`get_value` (`:1947-2056`) is where the leaf is read. It parses the reduced
operand's own VALUE STRING: `parseInt64` for `INT:`/`DEC:` (range-strict),
`parseIntLenient` for `UINT:` (signed first, then unsigned reinterpreted as
`int64_t` — `NumUtils.h:56-82`), `parseBinary`/`parseHex`/`parseOctal` for the
based encodings **behind a `VpiSize() > 64` refusal** (`:1969`, `:1984`,
`:1998`). A DECIMAL-encoded operand has no size guard at all.

**The no-wrap fact, measured.** `t1_arith72`, golden vs pristine:

| setter | int64 | slang's own width | golden | pristine |
|---|---|---|---|---|
| `BIG * 2` | 4000000000 | int32 wrap | `INT:4000000000` | `INT:-294967296` |
| `2 ** 40` | 1099511627776 | int32 wrap | `INT:1099511627776` | `INT:0` |
| `KU - 5` | −2 | unsigned 32 | `INT:-2` | `INT:4294967294` |
| `BU - 5` | −2 | unsigned 8 | `INT:-2` | `INT:4294967294` |
| `LU - 5` | −2 | unsigned 64 | `INT:-2` | `INT:0` |
| `-(BIG*2)` | −4000000000 | int32 wrap | `INT:-4000000000` | `INT:294967296` |

**The leaf is the parameter's STORED value, not slang's typing of the name.**
`localparam MD = -16'd5` is stored by the producer's own `vpiMinusOp` arm as
`INT:-5`; slang types the untyped name 16 bits unsigned and evaluates 65531.
`t2_leaf72` measures six such cells (`MD`, `MD + 0`, `MB`, `OVF`, `TWOHOP`,
`ONES - 1`) and every one is golden the int64 answer.

**BEYOND int64 — measured before touching it (`t3_beyond72`).**

* `+ - *` **WRAP** and golden writes the wrapped value: `longint HUGE = 4e18`,
  `HUGE * 4` is golden `INT:-2446744073709551616` and `HUGE + HUGE` is golden
  `INT:8000000000000000000` — both of which our 64-bit evaluation already
  matched. So those arms are transcribed with the wrap (computed through
  `uint64_t` so our own build is not signed-overflow UB).
* `**` is computed in `double` and cast back. `3 ** 39` is golden
  `INT:4052555153018976256`, the DOUBLE-rounded value (the exact int64 is
  …267), and `2 ** 64` / `2 ** 70` are golden `INT:-9223372036854775808`, the
  cast's own out-of-range artefact. The table reproduces the double rounding
  and **ABSTAINS** past int64 rather than transcribe the artefact — never
  writing a 0 in its place (§6 R2).
* A **>64-bit BIN/HEX/OCT leaf inside an arm makes the whole arm refuse**:
  `logic [95:0] W96H = 96'h1; … W96H - 1` is golden an unfolded `op11`, while
  the decimal `96'd5 * 2` is golden `INT:10`.

---

## 3. THE GOLDEN GRID (question 3)

Six new arms, every member read EXACTLY ONCE, plus fourteen committed arms
re-run as controls. Scored by `ord66v.py` on the JUDGE's own fields
(`vpiConstType` + `vpiValue` for ENC, plus `vpiSize` for FULL) through the
value-aware shape lister, and by `caread55.py` on the cont_assign road.

| arm | what it grids | FULL / ENC |
|---|---|---|
| `t1_arith72` | every int64 arm × overflow, unsigned wrap and agreement controls (14 members) | TO 7 / 6, AWAY 0 |
| `t2_leaf72` | the leaf read: untyped-minus names, an overflowing initializer, a two-hop chain, 64-bit all-ones, an enum member | TO 6 / 6, AWAY 0 |
| `t3_beyond72` | beyond int64 on `+ - * **`, the >64-bit HEX / DEC / 65-bit leaves | TO 3 / 3, AWAY 0 |
| `t4_pred72` | LAW B: six structs whose operand 0 is a candidate refusal and whose `K+1` probes on 8-bit members read golden's bail directly | TO 5 / 2, AWAY 0 |
| `t5_untyped72` | the post-bail size of an untyped localparam, against 24-bit members that collide with nothing | TO 3 / 3, AWAY 0 |
| `t6_wide72` | which wide leaf refuses and WHERE: literal vs name, hex vs bin vs decimal, inside an arm vs at the operand | TO 12 / 0, AWAY 0 |
| `t7_fence72` | whether the corroboration fence still separates anything: `**` past int64, where LAW A abstains and slang's own answer can carry a minus | TO 2 / 2, AWAY 0 |
| controls | `a1 a3 a5 a6 g3_neg66 x1_optable b3_ops68 v1_ofire68` | TO 0, AWAY 0 — unchanged or STILL |
| earlier-pass movers | `a2 a4 a7 a8 b2_faces68 x3_names` | TO 13 total, AWAY 0 |

**Totals over all twenty-one arms: FULL TO 51, ENC TO 31, AWAY 0,
MOVED-WRONG 0, WRONG2 1**
([evidence/GRID.allarms.txt](evidence/GRID.allarms.txt)). The one
`WRONG2` is `a4_wide66` op1, whose VALUE converts (`INT:-5`, golden's) while
its size stays 96 against golden's 64 — wrong→wrong on the size, a
§ patRedSz68 residue this pass does not claim.

### The two decisive tables

**t4_pred72 — the bail read off golden's own probe sizes** (8 = the walk
completed and stamped; 64 = it bailed at operand 0):

```
  operand 0        golden op0            golden probes   pristine   law
  BIG * 2          INT:4000000000        8  COMPLETES    8  (ok)    8
  KU - 5           INT:-2                64 REFUSES      8  WRONG   64  TO x3
  SB - 200         INT:-100              64 REFUSES      64 (ok)    64
  K * 2            INT:12                8  COMPLETES    8  (ok)    8
  KU ^ 3           op30 (unfolded)       64 REFUSES      64 (ok)    64
  8'hxA            HEX:xA                64 REFUSES      64 (ok)    64
```

**t6_wide72 — the wide-leaf refusal, and it is POSITION-DEPENDENT:**

```
  operand 0                        golden       golden probes
  96'h123456789ABCDEF012345678 - 1 op11         64   REFUSES
  96'h1 - 1                        op11         64   REFUSES
  96'b1 - 1                        op11         64   REFUSES
  W96H - 1   (name, hex, 96b)      op11         64   REFUSES
  W96B - 1   (name, bin, 96b)      op11         64   REFUSES
  W96X - 1   (name, hex, 96b val)  op11         64   REFUSES
  W96D * 2   (name, DECIMAL, 96b)  INT:10       8    COMPLETES
  K * 2      (control)             INT:12       8    COMPLETES
```

so **inside an arm the DECLARED width decides and the value does not** —
while at operand 0 itself Surelog has already narrowed the literal by VALUE,
which is r11u68's §6 R2 and is measured by `b2_faces68`: `96'h123456789ABC…`
bails (probes 64) and `96'b1` does not (probes 8). The first cut of this face
ignored the distinction and the wide boundary convicted it on 16 cells; §4
records that.

---

## 4. THE TWO GATED LAWS (question 4)

### LAW A — § patOperandIntSixtyFour72, the value half

`red72Int64` in [src/EmitHelpers.h](../../../src/EmitHelpers.h) is the
producer's arm table over the REDUCED operands, answering one of three
states: `Value` (the producer's int64 answer), `Refuses` (a leaf the reduce
cannot read, so the operation survives) and `Unknown`. Both value writers call
it FIRST and fall back to their landed pass-55/65 digit rule when it does not
answer, so an unmodelled face is a STILL cell and never an AWAY one:

* the packed-parameter road — `src/ParamEmit.cpp`, the flat `op75` walk's
  folded-operand mint, inside § patOperandEncReduceTable66's `if`, so the
  admission gate (`caSubstLeafCt56(*se) == vpiIntConst`, the `ifaceArrayDefFold`
  abstention, the based-literal / enum / concat / cast / call fences) is
  unchanged and this law only re-spells digits that law already claimed;
* the cont_assign road — `src/ModuleEmit.cpp`, inside
  § caSubstLeafEncReduceTable56's F2, under the same gate.

`Value` is produced for `+ - * / % **` and unary `-`, with a NAME hop followed
into its initializer and DECLINED when the name's own value is not that
initializer's value modulo the name's width (an overridden parameter is what
that guard turns away). Division and modulo by zero, `INT64_MIN / -1`, an
unknown value, a non-integer leaf and a pow result outside int64 all abstain.

Two consequences ride the landed size machinery rather than adding to it: the
operand whose value is now the producer's own is the operand § patBailStops-
MemberStamp68 reads, so the bail lands where golden's does (`t4_pred72` W2,
`a2_uwrap66`, `t1_arith72`), and § patBailStopsMemberStamp68's own
"are these digits the producer's?" guard is computed from the SAME table —
without that it stops matching on every cell the value law converts and the
size move is silently lost (measured on `t5_untyped72` `a`/`b`/`i`,
`a2_uwrap66` `b`/`c`, `t1_arith72` `h`/`m`).

**§ redUntypedIntNameSz72**, one fence LAW A needs: an IMPLICITLY typed
parameter with no dimensions whose initializer is a unary minus is stored by
the producer at the untyped default 32, not at slang's inferred literal width.
`t5_untyped72` measures `-8'd3` and `-4'd3` both golden 32 against slang's 8
and 4, with `16'h28` / `16'd9` (based, 16), `5` (unsized, 32) and a typed
`byte` (8) as the negative half. Without it LAW A's new bails expose slang's
width as a pristine-right → patched-wrong cell.

### LAW B — § redTableOneHome72, the predicate merge

r11v68's RV3 asked for the merge once the value half closed. Five faces of the
producer's boundary now live in ONE home, `src/EmitHelpers.h`, and each road
reads the same transcription:

| face | was | now |
|---|---|---|
| the based-literal FIRST-DIGIT scan | inline in `caSetterProvenFolds68v` | `red72LitDigitOk` / `red72LitBase` |
| `get_uvalue` read off the OBJECT | `patUvalueRefuses68` (ParamEmit) | `red72UvalueRefusesObj` |
| the operators `reduceExpr` leaves | `patAstRefuses68` (ParamEmit) | `red72ReduceLeavesOp` |
| the leaf `get_value` cannot read | — (new, measured `t6_wide72`) | `red72WideBasedLeaf` |
| PROOF the walk still stamps | `caSetterProvenFolds68v` (ModuleEmit) | `red72SetterCompletes` |
| the int64 value / corroboration | `patInt64Val68v` (ParamEmit), a SECOND transcription | `red72Int64` |

`caSetterProvenFolds68v`, `patUvalueRefuses68`, `patAstRefuses68` and
`patInt64Val68v` are now one-line calls; not one measured fence moved, and
every landed cell of r11u68 and r11v68 is scored unchanged above.

**The corroboration fence: KEPT, and the experiment says why.**
§ patBailNegCorroborated68v exists because a leading minus in OUR operand's
string might be a value WE wrapped. With LAW A the fence is a read of the SAME
table that writes the value, so wherever that table ANSWERS it is a tautology.
A third binary, `nf` (md5 `54dd19826ab4e56e7b573c02c60f69f6`, built in its own
worktree at `9637b9fd` and configured from scratch), is the law with the fence
deleted, and its databases are **byte-identical to the law's on all fifteen
arms scored** ([evidence/NFENCE.txt](evidence/NFENCE.txt)) — `t4_pred72` W1 is
the cell the fence was built for and the law writes `INT:4000000000` there, so
the refusal does not fire with or without it.

It does NOT follow that the fence is dead, and `t7_fence72` is why. The class
it guards is "LAW A abstains AND slang's own evaluation writes a minus", and
LAW A abstains past int64 on the `**` arm (§6 R0). `t7_fence72` `A` shows the
mechanism live in the PRISTINE world: `2 ** 31` is golden `INT:2147483648`,
COMPLETING (its `K+1` probes read 8), while pristine writes
`INT:-2147483648` — a leading minus golden does not have — and the pristine
binary does not bail there only because the fence stopped it. LAW A now
answers that particular cell (`2 ** 31` fits int64, and the law writes
golden's own digits: a TO cell), and `3 ** 40`, `2 ** 63` and `7 ** 23` — the
cells LAW A does abstain on — happen to wrap POSITIVE in slang. So the grid
shows the fence separating nothing TODAY without showing that nothing can
reach it. It only ever DECLINES a bail, which is a STILL cell and never an
AWAY one, and it is no longer a second transcription of anything. It stays
(§6 R1).

---

## 5. CENSUS, PREDICTION AND GATES (questions 5 and 6)

### The a-priori mover prediction, and its positive control

`census72.py` is r11u66's INTISH population — the setters where the encoding
law fires at all — sub-classified by which divergence class could reach them
(WRAP, OVF, NAMEHOP, WIDE, AGREE). It reads SOURCES only and is a superset by
construction; `--selftest` is the positive half (it must find OVF in
`t1_arith72`, NAMEHOP in `t2_leaf72` and `t5_untyped72`, WIDE in
`t3_beyond72`) and reads `SELFTEST PASS`.

```
STRICT  AGG=785 BASED=6133 CAST=2223 INTISH=31 NAME=507 OTHER=5047
        PLAIN=1582 UINTISH=3701        AGREE=20 OVF=2 WRAP=9   CANDIDATES 5
LOOSE   INTISH=50                      AGREE=21 OVF=17 WRAP=12 CANDIDATES 12
```

The five strict candidates are `Earlgrey_Verilator_01_05_21`,
`Earlgrey_nexysvideo`, `IncompTitan` (all three `InfoTypeSize[n] - 1`), `Tnoc`
(`32 * (64 / 8)`) and `Verilator` (`(twentyone / 8) + 1`); the loose set adds
`Ariane2024`, `AzadiRTL`, `CrossFunc`, `Zachjs`, `ariane`, `cva6_equiv` and
`struct_pattern_procedural` (`2**(MAN_BITS-1)`, `2*i`, `3 - i`). Every one of
them is a small value that int64 and the expression's own width agree on, so
the prediction is **NO MOVERS IN EITHER CORPUS**, and `NAMEHOP` and `WIDE` are
0 everywhere.

**POSITIVE CONTROL** ([evidence/POSCTL.txt](evidence/POSCTL.txt)) — the u2r
corpus test `cva6_struct_param_field`'s own sources give byte-identical
databases from the two binaries; the SAME sources with ONE setter changed from
`32'd64` to `32'd64 - 100` differ on exactly `UINT:4294967260`→`INT:-36` and
`vpiDecompile:4294967260`→`-36`, and Surelog v1.87 on those sources writes
`INT:-36`. Both binaries run in the SAME directory writing the SAME output
name, because the serializer embeds the output path. The corpus zero is
sighted.

### The wide boundary

`bnd72.sh` over **all 1068 committed probe arms that contain an assignment
pattern**, path-neutral, both binaries:
[evidence/BOUNDARY.1068arms.txt](evidence/BOUNDARY.1068arms.txt). **1048 SAME,
14 DIFFERS, 6 NODB** (arms both binaries reject identically, `prc=lrc=3`).
Six of the fourteen are this pass's own grid. The other eight —
`r11u66repro/grid/g3_neg66`, `r11u68repro/grid/b2_faces68`,
`r11v56repro/grid/x3_names`, `r11v66repro/grid/{a2_uwrap66, a4_wide66,
a6_misc66, a7_arith66, a8_real66}` — were each re-run against a real Surelog
v1.87 golden and scored in all four listings: **AWAY 0, MOVED-WRONG 0**.
`g3_neg66` and `a6_misc66` move on the cont_assign road only, where the
scoring is [evidence/CAROAD.txt](evidence/CAROAD.txt):

```
 g3_neg66  o12   golden 5      pristine -18446744073709551611   law 5
 a6_misc66 y7    golden 3      pristine -18446744073709551613   law 3
 a8_real66 y1    golden 1099511627776   pristine 0              law 1099511627776
```

and `t1_arith72` and `t2_leaf72`'s cont_assign listings are **identical to
golden's, line for line**, on the law binary.

**The boundary is what convicted this pass's own first two cuts**, and both
are recorded in the code: 16 pristine-right → patched-wrong size cells when
the wide-leaf refusal ignored WHERE the leaf sat (`b3_ops68` `C_b70` / `C_d96`
/ `C_h65` / `C_h70` / `C_o96`, `b2_faces68` `C_wb96`, `v1_ofire68` `C_wide70`
/ `C_wide96`), and 6 more when it treated an unknown digit as a wide value
(`C_xtail`, `C_xmid`, `C_unkhx2`).

### Gates — all mandatory, all green

1. **Both binaries built `-j 2`, md5s taken separately, frozen `chmod 555`
   before any sweep.** The pristine build in this pass's own worktree is
   `d7d16dbc92e585c323223489a790ad76` — byte-identical to the main tree's
   `build/slang-uhdm` at `9637b9fd`. The law is
   `8794860fd835afa68733006ee62a7438`.
2. **Goldens** `23 PASS / 0 FAIL` on the law binary and on the pristine one;
   `SLANG_UHDM=/bin/false` gives `0 PASS / 23 FAIL` (the negative control).
3. **uhdm2rtlil, both modes** `788 CMP_EQUAL / 16 CMP_NOTEQUAL / 67
   SLANG_REJECT`. The whole-row join of the 1742-row both-mode CSV against the
   committed `results/golden_uhdm2rtlil.csv` reads **0 differing ROWS**, and
   the same join against this pass's OWN pristine sweep reads 0; the testflags
   gate against `results/gate_uhdm2rtlil.csv` PASSES.
4. **Surelog suite, `--mode both`** `474 CMP_EQUAL / 9 CMP_NOTEQUAL` default
   and `469 / 8` testflags, bucket for bucket against the committed
   `results/golden_surelog.csv`. Three rows differ from the baseline row-text
   and all three are environment, each quoted:
   `Earlgrey_0_1,default,CMP_EQUAL,,,differ` → `CMP_EQUAL,,,` — the dump
   COLUMN only, the documented uhdm-dump timeout draw (this pass's PRISTINE
   sweep drew the same blank on the testflags row instead), and the STATUS is
   `CMP_EQUAL` in both modes on both binaries; and `LowMemLib,testflags` and
   `LowMemPkg,testflags`, `SURELOG_FAIL` in every listing, whose detail string
   is the `[INF:CM0023] Creating log file "<workdir>/…"` path.
5. **byteverify `SELFCHECK=1` against this pass's own pristine workdirs.**
   uhdm2rtlil: `PATH_SETS_IDENTICAL (1608 paths)`, **MOVERS 0 / 1608**,
   selfcheck sights 1607/1608 — exactly the a-priori prediction of no corpus
   movers. Surelog: `PATH_SETS_IDENTICAL (960 paths)`, **MOVERS 4 / 960**,
   selfcheck 959/960, and all four are the documented UVM coin:

   ```
   default/Scoreboard      0 substantive lines (the 0-line order draw)
   default/MiniAmiq        4 lines: UINT:1046 <-> UINT:866   + the vpiDecompile pair
   testflags/MiniAmiq      4 lines: UINT:1481 <-> UINT:0     + the vpiDecompile pair
   testflags/SeqDriver     4 lines: UINT:607  <-> UINT:1448  + the vpiDecompile pair
   ```

   order-blind and workdir-normalised: one `UINT`/`vpiDecompile` LINE-NUMBER
   pair each and **not one `vpiConstType` line**, which is what this law's
   signature would have to contain — it writes `VpiConstType`, `VpiValue` and
   `VpiDecompile` together and never a bare `UINT:` line number.
   **POSITIVE CONTROL for that attribution:** the SAME frozen PRISTINE binary
   on `MiniAmiq/default`'s own command line, three invocations, three DISTINCT
   database hashes (`4de695126a50`, `47e75ecdb83f`, `3819d72ea406`).
6. **Canaries.** `canaries.sh` reads `ok=51 changed=1` on the surelog CSV —
   the one change is `Earlgrey_0_1 default CMP_EQUAL/differ -> CMP_EQUAL/`,
   the dump column of §4 — and `ok=8 changed=0` on the u2r gate CSV; both
   `ctcan2.sh` runs PASS; `canaudit.sh` reads `audited=29 UNCOVERED=0
   FENCE-BREACH=0`. Every protected database is on its pin and identical
   between the two binaries in BOTH modes: SVSwitch `4842211c4030`, YosysVerx
   `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 default
   `8bdf25272e08` / testflags `59d0ee6d10c3`, BlackParrotComplex
   `e3e354129d5a` / `73a10e8217e5`, YosysOldOr `d68e0796d62c`. The UVM family
   rows (BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard) are
   `CMP_EQUAL` on both binaries in both modes, Scoreboard/testflags
   `SLANG_REJECT` in both as committed.
7. `results/*.csv` **untouched**; the fence check over the patch reads
   `0 0 0 0`; every one of the 1742 + 1742 + 1528 + 1581 `cmds.txt` files
   names the frozen binary by absolute path and **0** name the main tree.

---

## 6. RESIDUES

* **R0 — the `**` arm past int64.** Golden writes
  `INT:-9223372036854775808` for `2 ** 64` and `2 ** 70`, which is
  `static_cast<int64_t>` of an out-of-range `double` and nothing more. The
  table abstains there; two cells, `t3_beyond72` `d` and `e`, STILL.
* **R1 — the corroboration fence is a tautology where LAW A answers, and the
  `nf` binary measures it as separating nothing on fifteen arms.** It is kept
  because the abstention class of R0 still exists; close R0 and the fence is
  unconditionally redundant and should go. `t7_fence72` `A` is the standing
  witness that the class is not imaginary (`2 ** 31`: golden
  `INT:2147483648`, pristine `INT:-2147483648`).
* **R2 — § patRedSz68 has no `**` arm.** The producer's power arm writes
  `VpiSize(64)`; `t3_beyond72` `f` is golden 64 and ours 32. One cell, not
  claimed here because our own bail does not reach it.
* **R3 — the >64-bit member shapes.** `t3_beyond72` `g`/`h`/`i` are golden an
  unfolded operation or a constant our walk cannot reproduce on the
  cont_assign road; `a4_wide66` op1's size stays 96 against golden's 64. Older
  than this pass.
* **R4 — `t6_wide72` op0 shapes.** Where golden keeps the unfolded `op11` our
  walk has already folded the operand to a constant; only the SIZE of the
  operands after it converges. A § ifaceArrayDefFold-class shape residue.
* **R5 — r11v66's R-V2 stands.** `a8_real66` `d` (`$rtoi(R) * 2`) is golden an
  unfolded `op25` where our walk folds and this table now spells the constant.
  Harmless (the judge fails there either way) but the principle is unchanged.

---

## 7. REPRODUCING

```bash
git worktree add /tmp/wt 9637b9fd && cd /tmp/wt && git apply -3 /tmp/r11u72.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2 && md5sum build/slang-uhdm      # 8794860fd835…
R=$PWD/tools/probe/r11u72repro
G=/tmp/g72 && mkdir -p $G && cp $R/grid/*.sv $R/run66.sh $R/shape.py \
   $R/ord66v.py $R/caread55.py $G/
for a in t1_arith72 t2_leaf72 t3_beyond72 t4_pred72 t5_untyped72 t6_wide72; do
  bash $G/run66.sh $G/$a.sv pris <pristine binary>     # rc for BOTH sides
  bash $G/run66.sh $G/$a.sv law  $PWD/build/slang-uhdm
  python3 $G/ord66v.py $G/$a.g.dump $G/$a.pris.dump $G/$a.law.dump $a
  diff <(python3 $G/caread55.py $G/$a.g.dump ELAB) \
       <(python3 $G/caread55.py $G/$a.law.dump ELAB)
done
python3 $R/census72.py --selftest && python3 $R/census72.py
# the wide boundary (1068 arms, ~10 min at -P 4):
cd tools/probe && grep -rl "'{" $(find . -name '*.sv') | sed 's#^\./##' > /tmp/l.txt
BND_PRIS=<pristine> BND_LAW=$PWD/../../build/slang-uhdm BND_ROOT=$PWD \
  BND_OUT=/tmp/bnd xargs -a /tmp/l.txt -P 4 -I{} bash $R/bnd72.sh {}
```
