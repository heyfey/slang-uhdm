# r11v76 — adversarial verification of r11u76, and two gated verifier fixes

Base `2f728c97`, pins per `SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`,
uhdm2rtlil corpus v0.68). Every golden here is a real Surelog v1.87 run
through the committed `run66.sh`; every arm records `slrc` / `ourrc` /
`slerr`.

| binary | md5 | what |
|---|---|---|
| pristine | `ca45217f2ac9f7766fc232a8be0ee319` | built in THIS verifier's own worktree at `2f728c97`; byte-identical to the main tree |
| law (implementer) | `7833a385a271030c33f8314403482bfc` | `/tmp/r11u76.patch` unmodified — reproduced bit-for-bit |
| verified | `e9b87a87c00163abbb950adf8b6bb988` | law + the two fixes in §3 |

## 1. The headline numbers, reproduced

Both md5s reproduce exactly. The three committed witnesses re-run at the base
give the claimed cells to the character (`x1_sdec73` 18 FULL cells still + the
`CH` `op11` shape residue, `x7_sdecpos73` 5, `x9c_cast73` 2), and the law
binary converts all of them but the shape one. Over the implementer's eight
scored arms: **FULL TO 92, AWAY 0, MOVED-WRONG 0, STILL 24, WRONG2 0** — the
claimed totals. Over ALL 51 grid arms of passes 72/73/76 plus this verifier's
four: law **FULL 124 / AWAY 0 / WRONG2 5**, verified **FULL 127 / AWAY 0 /
WRONG2 1** (`evidence/GRID.51arms.txt`).

The committed `shape.py` value regex really does omit `DEC`, so r11v73's
"EMPTY value" on `signed'(16'd5)` was the lister's blind spot; the DEC-aware
lister reads `golden const/16@1=DEC:5` vs `ours const/16@9=UINT:5`.

## 2. The break grid (four new arms, all `slrc=0 ourrc=0 slerr=0`)

* **`v1unk76` — an UNKNOWN-digit based literal INSIDE a reduce arm.** The
  patch routes the `inArm` refusal through `red76BasedLeafDigits`, which
  returns FALSE on `hasUnknown` and therefore REFUSES, where the base returned
  false (no refusal) and fell through to `tryEval`. All three committed
  unknown cells (`b2_faces68 M_xtail`, `b3_ops68 N_xmid`, `v1_ofire68
  L_unkhx2`) sit at OPERAND 0, so the arm face was unmeasured. Result:
  **INERT** — the two databases differ only in the embedded workdir path, and
  both binaries drop the candidate operand entirely on `8'b1000000x + 1`
  (golden folds it to `UINT:65` — a pre-existing residue of ours, unchanged).
* **`v2par76` — parentheses at OPERAND 0**, the NON-`inArm` face the paren
  walk also moved. **2 cells CONVERT, 0 away**: `(96'h123456789ABCDEF012345678)`
  at operand 0 is golden a bail (probes `const/64`), pristine stamped
  `const/8`, the law bails. `(96'b1)`, `((8'd7))`, `(65'd1)` and
  `(8'b1000000x)` are unchanged and right. An unclaimed conversion.
* **`v3cast76` — the cast pass-thru's unmeasured faces.** 13 cells convert
  under the verified binary, 0 away. It found both defects in §3, and it
  refutes the suspected over-fire: `signed'(TB)` over a DECLARED-TYPE
  `byte TB = 8'd5` is golden `const/8@1=DEC:5`, so following that hop is
  correct.
* **`v4val76` — the value face's corners.** 14 cells convert, 0 away.
  Golden CONFIRMS the digit-overflow refusal at a narrow declared width in
  every base (`4'h1FFF…FFF + 1`, a 67-digit `4'b…`, a 22-digit `4'o…` and
  `65'd36893488147419103232 + 1` are all golden UNFOLDED `op24`s), the lenient
  hex wrap (`64'hFFFFFFFFFFFFFFFF + 1` golden `UINT:0`), and the law on the
  operand at the RIGHT of the arm (`2 * 8'sd200` golden `INT:400`).

## 3. Two gated verifier fixes (each droppable alone)

### § castSignCaseIsWritten76v — the digits are COPIED, not CASED

`red76SignCastConst` upper-cased hex digits. Surelog's literal arm
(`CompileExpression.cpp:474-507`) assigns `v` the SOURCE SPELLING and strips
only `#` and `_`; there is no case conversion on that path. Measured,
`v3cast76`: `unsigned'(16'hab)` is golden `const/16@5=HEX:ab` at one hop and
written directly, and the verbatim control `16'hab` beside it reads `HEX:ab`
on BOTH binaries — our own literal path already copies the spelling. The law
binary wrote `HEX:AB` beside its own `vpiDecompile:16'hab`, which no golden
constant ever does. Three cells (`v3cast76` op2/op3/op14), each WRONG2 under
the law and FULL under the fix. `VpiValue` is not judge-read, so this is
byte-truth.

### § castSignCastNeedsAValidRead76v — the producer must have READ the operand

The `$signed`/`$unsigned` arm calls `get_value` (`ExprEval.cpp:4695`) or
`get_uvalue` (`:4733`) on the reduced argument BEFORE it decides anything, and
both carry a `VpiSize() > 64` outright bail on b/o/h (`:1969/:1984/:1998` and
`:2077/:2094/:2106`) and a range-strict `parseInt64` on decimal (`:1978`).
When either sets `invalidValue` the CALLER abandons the fold and golden keeps
the whole `sys_func_call`. Measured, `v3cast76` `HQ8`:
`unsigned'(96'hFFFFFFFFFFFFFFFFFFFFFFFF)` is golden a `sys_func_call($unsigned)`,
UNFOLDED, where the ungated pass-thru wrote a 24-bit constant carrying
twenty-four hex digits. The gate reuses `srlgNegLitGetValue30` — the same
reader LAW A calls — so the cell returns to the landed behaviour (a STILL, not
an AWAY) and every measured pass-thru cell is untouched.

### An evidence fix

`census76.py --selftest` reads only `r11u76repro/grid`, but two of its six
control arms (`x1_sdec73`, `x7_sdecpos73`) are committed in `r11v73repro`, so
the positive control printed `SELFTEST FAIL` from the committed tree although
the scanner is fine. It now reads both grids and prints `SELFTEST PASS`.

## 4. Residues this pass leaves open (not regressions)

* **The cast constant is still judge-UNEQUAL on `Typespec`.** `$signed` over a
  `vpiDecConst` hangs a signed `logic_typespec` on the constant it hands back
  (`ExprEval.cpp:4700-4711`) and `unsigned'(16'sd5)`'s operand carries the
  literal's own `int_typespec`; `expr::Compare` READS `Typespec`. Golden's
  `signed'(16'd5)` operand has `vpiTypespec -> ref_typespec -> logic_typespec`
  and ours has none, on BOTH binaries. Three of four VALUE-side fields moved;
  the fourth judge-read field on this shape did not.
* **A one-hop `signed'(8'sd200)`** (`v3cast76` op12) takes the value and the
  `vpiConstType` to golden's but keeps the member's size 24 where golden reads
  8 — `patRedSz68`'s cast arm only fires on the DIRECT spelling.
* **An unknown-digit based literal inside an arm** never reaches our walk at
  all: golden folds `8'b1000000x + 1` to `UINT:65`, we drop the operand. Both
  binaries, pre-existing.
* `8'sd200 >>> 1` is golden `UINT:100` and ours `UINT:18446744073709551588` on
  both binaries — the arithmetic shift is not in the reduce table.

## 5. Gates (the verified binary unless stated)

Goldens 23/0 on pristine and verified, `/bin/false` 0/23. uhdm2rtlil both
modes `788/16/67` on both binaries; the 1742-row both-mode join against
`results/golden_uhdm2rtlil.csv` and against this verifier's own pristine sweep
both PASS, tf gate PASS; byteverify u2r **MOVERS 0/1608**, selfcheck
1607/1608. Surelog `--mode both` `474/9` default + `469/8` testflags on the
law binary, the verified binary AND the pristine one; the only rows differing
from the committed CSV are the environment classes, and the pristine sweep
carries the SAME ones: `Earlgrey_0_1/testflags`'s dump COLUMN blank on a
`uhdm-dump` timeout draw (status stays `CMP_EQUAL`, the DATABASE pins
`8bdf25272e08` / `59d0ee6d10c3` are byte-identical) and `LowMemLib` /
`LowMemPkg`'s `SURELOG_FAIL` detail carrying the workdir path. Verified
against this verifier's OWN pristine sweep, only the two `LowMem*` path
details differ at all. byteverify surelog **MOVERS 6/960**, selfcheck
959/960, every one the UVM coin: five arms move 4 sorted lines that are a
`UINT`/`vpiDecompile` pair holding a LINE NUMBER and `Scoreboard/default`
moves 0 sorted lines (94 unsorted — the `vpiTaskFunc` order flip); ZERO
`vpiConstType` and ZERO `vpiSize` lines. COIN POSITIVE CONTROL: the PRISTINE
binary alone, three runs of `MiniAmiq/default` in one directory writing one
name, gives three different databases (`2755563dc14b` / `f51fc409fd3e` /
`7901c2f4bacd`) and two pristine-only runs differ by the SAME 4-line class.
All seven conversion rows read `0 cmp lines / 0 heads` (Rggen/default 64/1
unchanged), and every protected database is byte-identical. Wide boundary
over **1708 arms** — the implementer's 1122 plus **586 more that the
assignment-pattern filter missed but that contain a signedness cast, a signed
based literal or a parenthesised literal — 1687 SAME, 11 DIFFERS, 10 NODB, the
eleven being this pass's own arms and the three committed witnesses.** No
corpus-derived arm and no earlier pass's arm differs, for the law binary or
the verified one. `results/*.csv` untouched.

## 6. Reproducing

```bash
G=<this dir>; cp $G/../r11v73repro/grid/{x1_sdec73,x7_sdecpos73,x9c_cast73}.sv $G/grid/
cp $G/../r11u76repro/grid/*.sv $G/grid/
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris <pristine>; bash $G/run66.sh $G/grid/$a.sv fix <verified>
done
V76GRID=$G python3 $G/score.py          # FULL/AWAY/STILL/WRONG2 against golden
```
