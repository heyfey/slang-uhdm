# r11v96 — the adversarial verification of r11u96, and the one AWAY it closes

**VERDICT: ACCEPT WITH FIX.** Every headline number in the r11u96 report
reproduces bit-for-bit on binaries this verifier built itself. One class of
**pristine-right → patched-wrong** cells survived the implementer's grid, was
found by two verifier arms, and is closed here by a fourth-and-a-half § block
of nine lines. `/tmp/r11u96.verified.patch` is what ships.

| binary | md5 | what |
|---|---|---|
| pristine | `8b04ca25ae24cab79525249c4e5390a5` | built in `/tmp/wt_v11u94pris` at `5a20468f` — the ops-brief md5 |
| law, AS DELIVERED | `125983deb62fe102bd64fe260e22d83a` | `/tmp/r11u96.patch` applied to a fresh `5a20468f` — the implementer's md5, reproduced |
| **law, VERIFIED** | `54d56dd004635a3c0a59112c3f88e571` | the same patch plus § kind1ConcatMustReachTheConstant96v |

---

## 1. THE DEFECT

`§ kind1ConcatKeepsNoTs96` (LAW C) routes a kind-1 package-parameter read back
to the READER's declaration whenever `red94InitHasConcat94` sights a
concatenation **anywhere in the initializer's syntax**. That scan descends into
a CALL'S ARGUMENT LIST. A concatenation standing only there never reaches the
elaborated constant: the call folds at compile time and golden hangs the
parameter's WRITTEN typespec on the answer exactly as it does over a plain
literal. On an UNSIGNED reader the reader's declaration votes for nothing, so
the law writes nothing where golden — and the PRISTINE binary — write
`int_typespec/S`.

Measured (real Surelog v1.87, arms `v3_ctsbrk96v` and `v4_callcat96v`, every
cell `slrc=0 ourrc=0 slerr=0`), reader `logic [7:0]`:

| package declaration | golden | pristine | r11u96 | verified |
|---|---|---|---|---|
| `int CBIT = $bits({4'd1,4'd2})` | `/S` | `/S` | **`-`** | `/S` |
| `int CCLG = $clog2({4'd1,4'd2})` | `/S` | `/S` | **`-`** | `/S` |
| `int FFUNC = v4f({4'd1,4'd2})` (a USER function) | `/S` | `/S` | **`-`** | `/S` |
| `int FBREP = $bits({2{4'd3}})` | `/S` | `/S` | **`-`** | `/S` |
| `int FMIX = $bits({4'd1,4'd2}) + 4` | `/S` | `/S` | **`-`** | `/S` |

and the shapes that must still decline, none of them moved by the gate:
`FOUT = $bits(8'd18) + {4'd0,4'd1}` (the concatenation is an OPERAND, golden
`-`), `CCST = int'({4'd1,4'd2})`, `CCMP = ({4'd1,4'd2}==8'd18)?7:9`,
`KRCT = int'({2{4'd3}})`, and every cell of `y3_kind1cat96`, `y5_replic96`
and `x6_concatvote94v`.

**Scored per cell on the `ts` field over all five pattern arms:**

| binary | TO | AWAY | MOVED-WRONG |
|---|---|---|---|
| r11u96 as delivered | 74 | **16** | **16** |
| verified | **74** | **0** | **0** |
| verified, tags swapped (positive control) | 0 | 74 | 74 |

The fix is `§ kind1ConcatMustReachTheConstant96v`: a kind-1-only concat scan
that does not descend into `SyntaxKind::ArgumentList` and answers `false` at an
`ExpressionKind::Call`. The LANDED kind-2 road (`§ pkgSynConcatKeepsNoTs94v`)
still reads `red94InitHasConcat94` unchanged, so no landed law moves.

## 2. WHAT REPRODUCED, EXACTLY

* **both md5s** — pristine `8b04ca25…` byte-identical to the ops brief, law
  `125983de…` byte-identical to the implementer's claim.
* **the base cells** — `x2` `wBMOD` golden `INT:3 ct7 sz32` / pristine
  `UINT:3 ct9`; `x2` `wBLMIN` golden `INT:-9223372036854775807 sz64` /
  pristine `INT:1`; `x6` `O6` golden `ts=-` / pristine `int_typespec/S`.
* **all 7 implementer arms** — `slrc=0 ourrc=0 slerr=0` and every `gdump=` /
  `odump=` line equal to `ARMS96.txt` to the digit.
* **the grid scores** — net-decl-assign per field `40 / 26 / 3 / 4` TO with
  `AWAY=0 MWRONG=0`; `ts` `24 / 22 / 2` = 48 TO with `AWAY=0 STILL=0
  MWRONG=0 UNPAIR=0`. Reversing the tags turns every one into AWAY.
* **census** `AGREE96 11857  K1C96 1153  MDM96 150  MDMW96 191  UDC96 310
  UDC96W 10`, 64 candidates, `SELFTEST PASS` with the same three unsighted
  negative controls. `predict96.py` names 31 u2r rows including `ibex_icache`.
* **gates** — goldens 23/0 on all three binaries and 0/23 on `/bin/false`;
  u2r `788/16/67` in six sweeps with both-mode `DIFF=0`; surelog `474/9` +
  `469/8` with every histogram cell identical; 5226 `cmds.txt` audited by
  absolute path, 0 naming the main tree.
* **byteverify** — u2r `MOVERS 2/1608` (`ibex_icache`, both modes, 40 diff
  lines each: 10 `|UINT:2`→`|INT:2` + 10 `|vpiConstType:9`→`:7`), and
  **golden reads `INT:2 vpiConstType:7` at every one of those cells** — the
  mover is TO GOLDEN, row stays `CMP_NOTEQUAL,decompile:`.
* **canary pins** — every protected database at its ops-brief md5 and
  byte-identical across all three binaries, both modes.
* **conversion rows** — `measured=13 SKIP-NOFILE=1`, every one 0 cmp lines /
  0 heads / rc=0, on the as-delivered AND the verified binary.
* **wide boundary** — 8294 arms (the implementer's "8302" is a miscount; their
  own class breakdown sums to 8294): `8053 SAME / 21 DIFFERS / 220 NODB`,
  every NODB `prc == lrc` (216 × rc=3, 4 × rc=139). The same 21, unchanged by
  the fix, and the NULL boundary (the pristine binary against itself over those
  21) reads **21 SAME / 0 DIFFERS** — not one of them is a run-to-run coin.

## 3. WHAT THE VERIFIER MEASURED THAT THE IMPLEMENTER DID NOT

* **The surelog byteverify list is a COIN, proven directly.** The PRISTINE
  binary, run four times on MiniAmiq/default's own invocation, produced FOUR
  DIFFERENT databases; the order-blind diff of two of them is the same single
  `|UINT:` / `|vpiDecompile:` pair (`618` vs `0`) that the byteverify flags.
  This verifier drew 5 movers where the implementer drew 4 (`SimpleUVM/default`
  additionally), and the law-vs-verified comparison draws 3 — all of them the
  same pair at `uvm_pkg` 642:23, with `|INT:` 0, `vpiConstType` 0, `vpiSize` 0
  and `Typespec` 0 across every one. No pad binary is needed to convict it.
* **The three "static-address false movers" are the PAGE-BOUNDARY class the
  ops brief names.** `g185_e_kinds` prints `|UINT:23298809` on pristine and
  `|UINT:23302905` on BOTH law binaries — a delta of exactly **4096**, one
  page — and pristine-vs-pristine on all three arms is SAME.
* **The 12 committed boundary arms, scored PER CELL by SOURCE LOCATION**
  (`loc96v.py`, keyed on each constant's `line:col`, three fields):
  `d1_earl71` TO=20, `g2_orig76` TO=14, `q5_negedge94` TO=4, `a5_origin75`
  TO=4, `a4_val76` TO=2, `we` TO=2, the rest TO=0 — and **AWAY=0,
  MOVED-WRONG=0 on every one of the twelve**. (A count-keyed distance reads
  `vpiConstType:7` as overshooting on `d1_earl71`; it is an artefact of
  constants our dump holds at locations golden has none — the location-keyed
  read is the arbiter.)
* **Each law still drops alone.** Rebuilt with `mul96`/`div96`/`mod96` set to
  `false` (md5 `919fcc1c5c70c9f9f851ce77b4fb2868`), the net-decl-assign score
  reads `y1` 40→**0**, `y2` 26→**20**, `y4` 3→**0**, `x2` 4→**2**, AWAY 0 and
  MOVED-WRONG 0 throughout — the implementer's own `DROP96` row for LAW A,
  cell for cell.
* **The mint is a PACKAGE fact and nothing at the module home moved**
  (`v6_modhome96v`): a module `localparam int MMUL = 2 * 3` is golden `INT:6`
  and BOTH binaries already write `INT:6`; a parameter PORT and an overridden
  `#(.SP(6*7))` are golden `INT:42` and unmoved; the one moved cell of that arm
  is the package read. TO=2 AWAY=0.
* **LAW B does not disturb the `'{…}` PATTERN road** (`v7_bigpat96v`): eight
  package hops carrying `4294967296`-class decimals under `-`, `/`, `*`, `+`,
  a unary minus, a based leaf and no operator at all, read through a packed
  struct pattern — **TO 0 / AWAY 0 / MOVED-WRONG 0 over all five fields**, 38
  cells still disagreeing with golden exactly as they do on pristine.
* **LAW A and LAW B hold on shapes the implementer's grid does not carry**
  (`v1_amulbrk96v`, `v2_bdecbrk96v`, `v6_modhome96v`): chained `*` and `/`, a `*` under an add
  and under a subtract, `$clog2` and enum operands, signed-narrow declarations
  whose store has already wrapped (`logic signed [3:0] MSN4 = 3*3` golden
  `INT:9`), a negative divisor, `int'`-cast reals, 2^63 and uint64-max
  decimals, underscores, parentheses, leading zeros, `byte`/`int` declared
  types — **TO 20 + 21, AWAY 0 on both**.

## 4. THE RESIDUES THIS VERIFICATION ADDS (ranked)

* **RV96-1 — `'1` IS WORTH 1 TO THE PRODUCER AND 4294967295 TO US, AND THE
  LANDED MINUS LAW ALREADY SAYS SO.** `v5_unbased96v`, on PRISTINE:
  `int UMIN = '1 - 0` golden `INT:1`, pristine `INT:4294967295`;
  `int USUB = '1 - 1` golden `INT:0`, pristine `INT:4294967294`;
  `int UNEG = -'1` golden `INT:-1`, pristine `INT:-4294967295`. r11u96's LAW A
  widens that pre-existing misreading to three more operators — `'1 * 2` is
  golden `INT:2`, pristine `INT:-2`, patched `INT:8589934590`. **AWAY 0** (no
  cell was ever right), 5 MOVED-WRONG fields. The cure is one arm in
  `red72Int64` reading an `UnbasedUnsizedIntegerLiteral` as the producer does;
  it belongs with its own census because `red72Int64` is shared.
* **RV96-2 — THE INT MINT PROPAGATES THROUGH THE PARENT OPERATOR.**
  `int MMIX = 2 * 3 + 1` is golden `INT:7` where `int CADD = 1 + 2` is golden
  `UINT:3`: `vpiAddOp` mints `UINT:` only when both reduced operands are
  unsigned, so an INT-minting sub-expression carries the mint upward. This
  pass's gate reads the TOP operator only and leaves `MMIX` / `MMIX2` at
  `UINT:7` — two missed TOs per shape, no AWAY. Measured on `v1_amulbrk96v`.
* **RV96-3 — A COMPARISON IS `INT:-1`.** `int CCMP = (3 < 4)` is golden
  `INT:-1 ct7` where both binaries write `UINT:1 ct9` (`v1_amulbrk96v`).
  Untouched by this pass and by the landed ones.
* **RV96-4 — A CHAIN DOES NOT CARRY THE WRITTEN DIGITS.**
  `longint CHAIN = SEP - 0` over `longint SEP = 4_294_967_296 - 0` is golden
  `INT:4294967296` and both binaries write `INT:0` (`v2_bdecbrk96v`): LAW B
  reads the literal, not the name that holds it. No AWAY.
* **RV96-5 — the `&` and `<<` arms carry the digits too.**
  `longint AND = 4294967296 & 4294967296` golden `UINT:4294967296` and
  `longint SHL = 2147483648 << 1` golden `UINT:4294967296`, both binaries `0`
  and `-4294967296`: the value road is LAW B's but the const-type road is not,
  so neither is reached. The implementer's R3 one operator wider.
* **The kind-2 and kind-0 call-wrapped shapes are NOT closed here.**
  `signed FSB = $bits({4'd1,4'd2})` read unsigned is golden `/S` where both
  binaries write nothing, and `unsigned FUB` / implicit `FIMP` read signed are
  golden `-` where both write `/S` (`v4_callcat96v`, 6 STILL cells). The
  landed `§ pkgSynConcatKeepsNoTs94v` has the same argument-list hole on the
  kind-2 road; it is PRE-EXISTING, it is not an AWAY, and closing it wants its
  own census.

## 5. REPRODUCING

```bash
git worktree add /tmp/wt_v11u94pris 5a20468f && git worktree add /tmp/wt_v11u94 5a20468f
(cd /tmp/wt_v11u94 && git apply -3 /tmp/r11u96.verified.patch)
for d in /tmp/wt_v11u94pris /tmp/wt_v11u94; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
        -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done                      # 8b04ca25ae24cab7…  and  54d56dd004635a3c…
# the arms: r11u96repro/grid/*.sv + r11v94repro/grid/{x2_minusedge94v,x6_concatvote94v}.sv
#           + r11v96repro/grid/v{1,2,3,4,5}_*.sv, through r11u86repro/run66.sh,
#           tags pris / fixd (SAME LENGTH), scored with r11u94repro/nda94.py and
#           r11u96repro/score96f.py --field ts; swap the last two arguments for
#           the positive control.
# the corpora: verify_golden.py --corpus {uhdm2rtlil,surelog} --jobs 3, own workdirs,
#           SLANG_UHDM exported per binary; join87.py / ct8rows.sh / byteverify.sh.
# the boundary: BND_PRIS / BND_LAW / BND_ROOT=<worktree>/tools/probe / BND_OUT,
#           xargs -P 3 -n 1 bash r11u91repro/bnd72.sh < the *.sv list;
#           score the DIFFERS arms per cell with r11v96repro/loc96v.py.
# the coin control: run ONE binary four times on MiniAmiq's own cmds.txt invocation.
```

Evidence: `evidence/{ARMS96V.txt, GRID96V.score, TS96V.score, GATES96V.txt,
MOVERS96V.txt, BOUNDARY96V.arms, NULLBND96V.arms, BOUNDARY96V.classes, PINS96V.txt}`.
