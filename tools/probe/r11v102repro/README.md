# r11v102 — the verifier of r11u102: ACCEPT-WITH-FIX

**Verdict: ACCEPT-WITH-FIX.** Every headline number in r11u102's report
reproduces bit for bit on binaries this verifier built itself. The three laws
move every one of the implementer's 800 grid fields to golden.

Break arms built on real Surelog v1.87 goldens found **eleven legal-SV faces**
where the law was wrong. In each, the pristine binary was right on at least one
scored field and the law binary moved it away (AWAY) or to a different wrong
value (MOVED-WRONG). All eleven are in LAW B (§ ndaCallFoldIsEvalFunc102) and
LAW C (§ unknownOperandDeclinesFold102). LAW A (§ cmpOperandUnderIntMint102) and
§ pkgCallMintIsTheReturnMint102 found nothing wrong: 86 new fields, all TO, none
AWAY.

The fix is seven gates, each behind its own flag. Six narrow the laws. The
seventh widens LAW B to nets wider than 64 bits, which golden measures in four
cells. With the fix, all 1414 fields score TO, AWAY is 0 and MOVED-WRONG is 0.
Every corpus gate is unchanged, and no row moves in either mode.

Deliverable: `/tmp/r11u102.verified.patch`, which is r11u102's patch plus this
fix and this directory. Base `f2e5ebc8`; pins per `SUPPORT_MATRIX.md`.

| binary | md5 | what |
|---|---|---|
| pristine | `cea7806d57a4afa1d21a15f5a938caa0` | built here; matches the ops brief |
| law | `9dc12cbbe5c80a4ab754523b67d12a8b` | `/tmp/r11u102.patch`; matches the implementer's claim |
| **fixed** | `9f80984e2cec410c4ec6eafb0ab705c8` | this verified patch |
| all 14 flags off | `0070efd98fe9344727a732567e518119` | on all 35 arms, byte-identical to pristine |

---

## 1. The implementer's numbers, reproduced

- **Arms:** 30 arms, 60 arm-runs, every one `slrc=0 ourrc=0 slerr=0`.
- **Grid, net-name scorer (`nda102.py`):** TO=800, AWAY=0, MOVED-WRONG=0. That
  is 770 from q1–q6 plus 30 from `p4_fence100`, `z3_cmpfam97` and `z4_xz97`.
  The other 21 control arms are byte-identical between pristine and law.
- **Grid, location scorer (`loc97v`):** TO=106, AWAY=0, MOVED-WRONG=0.
- **Census (`ct102cen`) over all 2568 pristine databases:** B1=122 (YosysRiscv
  `carry_save_add` ×57 and YosysOldOpen `bcd_add` ×4, per mode), B3=28, C=824,
  and A, B2 and C2 all 0.
- **Corpus sweeps:** match every number in §6 below.
- **Wide boundary:** 8463 arms give 8231 SAME, 8 DIFFERS and 224 NODB. The
  NODB split is 220 at rc=3 and 4 at rc=139, and prc equals lrc on all of
  them. The DIFFERS list is the same 8 arms the implementer names.

## 2. What broke, and the producer's reason

Arms `grid/b1_callbrk94.sv`, `b3_xhomes94.sv` and `b5_fixfaces94.sv`. Every
cell is quoted in `evidence/CELLS94.txt`.

### LAW B — `evalFunc` / `compileClog2` do not fold everything the gate admitted

| face | cell | golden | law |
|---|---|---|---|
| default argument | `fdef(3)` (`b = 2` default) | `func_call` | `INT:6` AWAY |
| empty / named-omitted slot | `fdef(3, )`, `fdef(.a(3))` | `INT:0` | `INT:6` MOVED-WRONG |
| module parameter in the body | `mws(3)` (`a + W`), `mlks(3)` (`a + LK`) | `func_call` | `UINT:7` / `UINT:8` AWAY |
| module parameter in the body | `mw(3)` (`a * W`) in an instance with `W=7` / `W=9` | `INT:12` (the **definition's** W=4) | `INT:21` / `INT:27` MOVED-WRONG |
| negative `$clog2` argument | `$clog2(-5)`, `(2-7)`, `(-1)`, a `-5` package parameter, a `-3` override | `sys_func_call` | `UINT:0` AWAY (six cells) |
| digit road of an actual | `fm(8'sb11111111)` | `INT:765` | `INT:-3` MOVED-WRONG |
| digit road of an actual | `flm(3000000000)` | `INT:9000000000000000000` | `INT:1676940297709551616` MOVED-WRONG |
| digit road of a `$clog2` argument | `$clog2(4294967296)` | `UINT:32` | `UINT:0` MOVED-WRONG |
| net wider than 64 bits | `wire [127:0] = fs(4)` / `fp(3)` / `$clog2(P5)`, `[95:0] = fp(3)` | `sz128` / `sz96` | `sz32` MOVED-WRONG on the size field |

Two cases need explaining:

- **Wide nets.** The implicit-conversion entry declined any width over 64. The
  bare-call entry then re-folded the call at the call's own 32-bit width. The
  fix lets the conversion entry fold at the net's width. Golden measures that
  width on all four cells, and none of them is masked.
- **Actuals.** An actual reaches `evalFunc` as the producer's reduced operand.
  For an unsized decimal or a based literal, that is the written digits
  (§ unsizedDecLeafWrittenDigits96, § redBasedLeafWrittenDigits76). The law read
  `red72Int64` without `inArm`, and slang's truncated store agreed with that
  reading, so the gate's equality check could not see the difference.

Three LAW B faces are **measured but not decoded**. The fix declines each one,
which is always a STILL cell, never an AWAY one:

- `evalFunc` with a defaulted formal.
- A module-scope parameter in a function body. The same shape folds for `*` and
  fails for `+`.
- A negative `$clog2` argument. `compileClog2`'s own loop at
  `~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:5013` would fold
  `UINT:0` for it.

### LAW C — the producer's miss is narrower than "any x/z under an operator"

**Based literals.** `get_value` parses a based value through `NumUtils::strToInt`
(`~/git-repos/UHDM/templates/NumUtils.h:56`), which calls `std::from_chars`.
That reads the valid PREFIX and fails only when no digit parses at all. So a
based literal is a miss only when its **leading** written digit is x, z or `?`:

| cell | golden | law |
|---|---|---|
| `4'b1x00 & 4'b0011` | `UINT:1` | `ref_obj` |
| `4'b0x00 \| 4'b0001` | `UINT:1` | `ref_obj` (pristine was fully right) |
| `8'h1x + 1` | `UINT:2` | `ref_obj` |
| `4'b1z00 + 0` | `UINT:1` | `ref_obj` |
| `6'o1x + 1` | `UINT:2` | `ref_obj` |
| `2 ** 4'b1x` | `INT:2` | `ref_obj` |
| `8'hx1 + 1`, `4'bx_100 & 1` | `ref_obj` | `ref_obj` (still TO) |

**Comparisons of two literals.** `reduceCompOp`
(`~/git-repos/UHDM/templates/ExprEval.cpp:1639`) falls back to a STRING compare
at `:1722` when both reduced operands are `BIN:`/`HEX:`/`OCT:`/`DEC:` strings
(`getStringVal`, `:1610`). That happens when both are based or unbased
literals, and it then folds for every comparison operator:

| cell | golden | law |
|---|---|---|
| `('x == 'x) ** 2` | `INT:1` | `ref_obj` |
| `('x != 'z) * 3` | `INT:3` | `ref_obj` |
| `('x < 4'b0001) + 1` | `UINT:1` | `ref_obj` |
| `(4'b0001 == 'x) + 1` | `UINT:1` | `ref_obj` |
| `(1'bx == 1'bx) * 2` | `INT:2` | `ref_obj` |
| `('x == 4'd1) + 1` | `UINT:1` | `ref_obj` |
| `('x >= 'z) + 1` | `UINT:1` | `ref_obj` |
| `('x == 1) + 1`, `((2 ** 'x) == 'x) + 1` | `ref_obj` | `ref_obj` (still TO) |

The first case in each table turned golden's constant into a `ref_obj`: a
VpiType flip, which is the first field `BaseClass::Compare` reads.

LAW C's other homes were checked against golden location by location, and every
one moves to golden. They are an `always_comb` right-hand side, a nonblocking
right-hand side, an unqualified read after an import, an `if` condition, a case
item, a function return, a port connection, a `$display` argument and an
indexed-part-select base (`b3_xhomes94`).

## 3. The fix — seven flags, each droppable alone

| flag | where | what it does |
|---|---|---|
| `defArg102v` | `EmitHelpers.h`, `red102CallFold102` | Declines when slang bound an argument from the formal's default (`aargs[i] == formal->getDefaultValue()`, the exact pointer slang's `CallExpression::bindArgs` stores). |
| `bodyPkg102v` | `red102RetEval102` | Declines unless every parameter the body reads is a PACKAGE parameter. |
| `argDigits102v` | `red102ArgDigitsAgree102v` | Requires the actual (or `$clog2` argument) read with `inArm` set to agree with the plain reading and with slang. |
| `clogNeg102v` | `red102Clog2Fold102` | Declines a negative argument. |
| `wideNet102v` | `ExprEmit.cpp`, `ndaCallFold102` | Allows nets wider than 64 bits, at the net's width. |
| `basedLead102v` | `red102XzUnderOp102` | Treats a based literal as a miss only when its leading written digit is x, z or `?`. |
| `strCmp102v` | `red102XzUnderOp102` | Does not walk into a comparison whose two operands are string-valued literals. |

`ParamEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `include/` and `results/`
are untouched. The production surface is still `src/EmitHelpers.h` plus
`src/ExprEmit.cpp`.

**Drops** (`evidence/DROP94.txt`), each run over all 35 arms:

- ALLOFF (all 14 flags off) is byte-identical to pristine on every arm.
- Each implementer flag, dropped alone, removes only its own cells, all of
  which were TO.
- Each verifier flag, dropped alone, brings back exactly its own AWAY and
  MOVED-WRONG cells.

**One coupling is not clean: `xRef102` is a sub-face of `xDecl102`.** Dropped
alone, it keeps the decline but writes the default `ref_obj` (named `CPX`,
unbound) instead of golden's `q3p::CPX` bound to the parameter. It still moves
the kind and value fields TO golden, but moves `nm` and `act` wrong: 53
MOVED-WRONG fields over six arms (`q3` 28, `b3` 13, `b5` 4, `q4` 3, `z4` 3,
`q5` 2), and AWAY stays 0.

The implementer's DROP102 scored each drop against the law binary, not against
pristine, so it could not see this. It does not affect the shipped binary,
where every flag is on. To make `xRef102` truly droppable alone, gate `xz102`
on `xDecl102 && xRef102`. That is left to the landing, as RV102-9.

## 4. The grid, per cell (`evidence/GRID94.score`)

Net-name scorer, golden vs pristine vs fixed:

| arms | TO | AWAY | MOVED-WRONG |
|---|---|---|---|
| the implementer's 30 | 800 | 0 | 0 |
| the verifier's b1–b5 | 614 | 0 | 0 |
| **total** | **1414** | **0** | **0** |
| positive control: all 35 with tags swapped | 0 | 1414 | 1414 |

On the law binary the b-arms read AWAY=164 and MOVED-WRONG=238.

The fix is byte-identical to the law binary on all 30 of the implementer's arms,
so every law cell the implementer measured stands. It differs only on
`b1`, `b3` and `b5`.

## 5. Census and movers

Both corpora, both modes, keyed on the sweeps' own databases:

- The census reproduces exactly (§1). The fix only narrows LAW B/C, apart from
  `wideNet102v`, whose superset (B1+B2 on nets of any width) is the same 122
  signal-argument cells that the gate declines.
- **Predicted movers: 0.**

**byteverify, `SELFCHECK=1`, against this verifier's own pristine workdirs:**

| comparison | uhdm2rtlil | Surelog | Surelog movers |
|---|---|---|---|
| law | 0/1608 | 4/960 | MiniAmiq ×2, SeqDriver ×2 |
| **fixed** | **0/1608** | **5/960** | MiniAmiq ×2, SeqDriver ×2, Scoreboard/default |

- Every law and fixed mover is the documented UVM coin. The order-blind diff is
  either one `|UINT:` / `|vpiDecompile:` pair (4 lines), or 0 lines for
  Scoreboard.
- **Positive control:** the pristine binary, run three times on
  MiniAmiq/default's own `cmds.txt` invocation, produced three different
  databases (`f29d9f8d`, `243b5f00`, `08726c3e`). The order-blind diff between
  two of them is the same `UINT` pair.

## 6. Gates — pristine / law / fixed

- **Goldens:** 23/0 on all three binaries. `/bin/false` gives 0/23.
- **uhdm2rtlil:** 788/16/67 in both modes on all three binaries.
  - `join87` against `results/golden_uhdm2rtlil.csv`: DIFF=0 on all three.
  - `ct8rows` against `gate_uhdm2rtlil.csv`: PASS on all three.
  - `cmds.txt`: 1742 per sweep name the frozen binary, and none name the main
    tree.
- **Surelog `--mode both`:** 474/9 default and 469/8 testflags on all three
  binaries, with an identical histogram. The whole-row join differs only in
  these fields:
  - `LowMemLib`/`LowMemPkg` testflags: the detail field holds the sweep's own
    workdir path.
  - `Earlgrey_0_1`'s DUMP column is blank. That is the uhdm-dump timeout draw:
    both modes on pristine and law, testflags only on fixed.
  - `cmds.txt`: 1531 per sweep name the frozen binary. The other 50 are Surelog
    rows with no slang invocation, and none name another slang binary.
- **Pins:** all three binaries match on both modes:
  - SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort
    `59a365f3ce2c`.
  - BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`, YosysOldOr
    `d68e0796d62c`.
  - Earlgrey_0_1 `8bdf25272e08` (default) / `59d0ee6d10c3` (testflags).
  - All seven conversion rows are CMP_EQUAL in both modes (Scoreboard/testflags
    is the documented SLANG_REJECT / SKIP-NOFILE).
- **Canaries:** `canaries.sh` gives ok=50–51 with only Earlgrey's dump column
  changed; u2r ok=8. `ctcan2` PASS on both corpora. `canaudit` PASS.
- **Wide boundary, pristine vs fixed (8463 arms):** the same 8 DIFFERS as the
  law.
  - Null boundary (pristine vs pristine) over those 8: 8 SAME.
  - Three are the page-boundary `UINT` class, law and fixed both +16384.
    Positive control: the all-flags-off binary moves the same three by +4096.
  - `v133_e_const` (re-cut `v133t` without the failing line, whose golden
    compiles): loc97v TO=2 AWAY=0.
  - `x4_syncross94v`: at 29:39 golden is `UINT:5` in every cell, and the one
    cell that moves goes `INT:5` to `UINT:5`, so it is TO. loc97v's
    MOVED-WRONG=2 comes from its location multiset.
  - `p4`/`z3`/`z4` are scored in the grid.

## 7. Residues (ranked)

- **RV102-1 (R0 candidate).** The same fold rules at ParamEmit's own
  `param_assign` sites (the implementer's R0/R1). Examples: `b2p::CGE` param
  golden `INT:-1` vs ours `INT:4294967295`; `b4p::QFS` `UINT:5` vs `INT:5`. This
  is line-sensitive ground with 0 corpus rows predicted.
- **RV102-2.** Actuals bound to an overridden or negative parameter. For example
  `fs(N)` with `.N(2*3)` is golden `INT:7`, and `fs(PNEG)` is `INT:-4`. The
  `+` mint follows the reduced operand's mint (§ addMintFollowsOperandMint97).
  The gate declines these (STILL).
- **RV102-3.** The digit-road faces the fix now declines. They need the
  producer's arithmetic on written digits:
  - `fm(8'sb11111111)` is `INT:765`.
  - `flm(3000000000)` is `INT:9000000000000000000`.
  - `$clog2(4294967296)` is `UINT:32`.
  - `fm('1)` is `INT:12884901885`.
  - `fs('1)` is `UINT:4294967296`.
- **RV102-4.** Measured, not decoded: `evalFunc` over a module parameter (the
  DEFINITION's value for `*`, a failure for `+`), a defaulted slot (`INT:0`
  for empty or named-omitted, `func_call` for trailing-omitted), and a negative
  `$clog2`.
- **RV102-5.** A `bit [7:0]` return is NOT masked (`fbit8(300)` is golden
  `UINT:301`), and a sized literal in the body mints INT (`a + 32'd1` is
  `INT:5`). Both are declined.
- **RV102-6.** LAW C's value faces that stay declined:
  - The based-prefix value (`4'b1x00 & 4'b0011` is `UINT:1`; ours stays
    pristine `UINT:0`).
  - The string compare (`('x=='x)**2` is `INT:1`).
  - `$bits('x) + 1` is `UINT:0`.
  - `int'('x) + 1` is a ref.
- **RV102-7.** Generate-scope homes of LAW B (the implementer's R2, ModuleEmit
  ground).
- **RV102-9.** `xRef102` cannot be dropped alone without MOVED-WRONG fields
  (§3). The fix is one token in the `xz102` predicate.
- **RV102-8.** The census's LAW C class reads only operations in our DEF
  listing. It is blind to a NAME hop onto an x-leaf parameter
  (`CXN = CX + 1`). The byteverify zero is what closes that gap here.

## 8. Reproducing

```bash
git worktree add /tmp/wt_v11u94pris f2e5ebc8; git worktree add /tmp/wt_v11u94 f2e5ebc8
(cd /tmp/wt_v11u94 && git apply -3 /tmp/r11u102.verified.patch)
# build both -j 2 (gcc-toolset-14, Release), md5, chmod 555 copies -> pris.bin / fixv.bin
# grid: copy grid/*.sv + r11u102repro/grid/*.sv into one dir, the 24 controls into another,
#   with grid94.sh + ../r11u102repro/nda102.py + ../r11u100repro/loc97v.py
bash grid94.sh <arm>.sv pris:<pris.bin> fixv:<fixv.bin>        # every arm slrc=0 ourrc=0 slerr=0
python3 nda102.py <arm>.g.dump <arm>.pris.dump <arm>.fixv.dump  # AWAY=0 MWRONG=0
python3 nda102.py <arm>.g.dump <arm>.fixv.dump <arm>.pris.dump  # the swap: every TO -> AWAY
TREE=/tmp/wt_v11u94pris WD=<dir> bash sweep94.sh fixv <fixv.bin>   # one pair at a time
PATCH=<production diff> BINDIR=<dir> bash drops94.sh <worktree> ALLOFF <flag>...   # ONE build at a time on 15 GB
BINDIR=<dir> GRIDS="<grid> <ctl>" bash droparms94.sh <flag>
bash pins94.sh <sweep workdir>
```
