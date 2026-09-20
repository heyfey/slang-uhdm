# r11v66 — adversarial verification of § patOperandEncReduceTable66 (r11u66)

**VERDICT: ACCEPT.** Every headline number reproduced bit-for-bit from my own
build, at base `12c6de50`, with independently written scorers. Eight new
adversarial arms and a 977-arm wide boundary found **AWAY 0 / MOVED-WRONG 0**,
and one ranked residue that the pass's own write-up states wrongly.

## What I rebuilt and froze

| binary | md5 | note |
|---|---|---|
| pristine (`12c6de50`, no patch) | `40563d03c6a4c68ed7192f6bd5657f5e` | byte-identical to the main tree's `build/slang-uhdm` |
| law (`/tmp/r11u66.patch` applied) | `82111bbd435be0d05af1580b2222a687` | the implementer's shipped hash, reproduced |

`-j 2`, 0 errors, md5 taken separately, both `chmod 555` before any sweep.
Patch surface: `src/ParamEmit.cpp` (+163/-0), `RESUME.md` (+19 §3b), and
`tools/probe/r11u66repro/`. `results/*.csv` untouched; fence check over the
patch `0 0 0 0`; `git apply -3` on a fresh worktree rc 0, 0 conflict markers.

## The instrument this verification adds

The implementer's `cmp66.py` scores `vpiConstType + VpiValue (+ vpiSize)`.
**The judge does not read `VpiValue` at all.** The generated
`constant::Compare` (`~/git-repos/UHDM/build/generated/src/constant.cpp:66`)
reads `VpiConstType` and then `expr::Compare` (`expr.cpp:90` `VpiDecompile`,
`:95` `VpiSize`, then `Typespec`). So `ord66v.py`/`shapej.py` score the
JUDGE's own fields — `vpiConstType + vpiSize + vpiDecompile` — and that is the
scoring reported below. `loc66v.py` re-keys operands by source range for the
arms where our walk emits a different NUMBER of operands than golden
(`e1_enc56` 20 vs 19, `e2_width56` 9 vs 7, `e5_deffill56` 2 vs 0), where an
ordinal key silently compares the wrong pair.

## Reproduced, bit-for-bit

* v9 `PN`/`PSW` and the 20 `x1_optable` faces at `12c6de50` — every cell as the
  pass quotes it (`PN` op0 golden `const/8@7=INT:-3` vs pristine
  `const/8@9=UINT:253`; `bxr` golden `op30`; `cmp` golden `BIN:1`@1).
* grid, all nine committed arms: **FULL TO 46, ENC TO 60, AWAY 0,
  MOVED-WRONG 0** — the same 46 and 60 the pass reports, from an independent
  scorer, on the judge's fields.
* byte level: **274 order-blind lines, 61 `UINT:`→`INT:`, 61
  `vpiConstType:9`→`:7`, 15 `vpiDecompile`, and NOT ONE `vpiSize` line**;
  `g2_fncall66` 0 lines.
* census: `SELFTEST PASS`; strict `AGG=785 BASED=6133 CAST=2223 INTISH=31
  NAME=507 OTHER=5047 PLAIN=1582 UINTISH=3701`, `CANDIDATES 6`; loose
  `INTISH=50`, `CANDIDATES 14`; only `Kmac`, `CrossFunc`,
  `struct_pattern_procedural` can move a byte, all three `CMP_EQUAL`.
* gates: goldens 23/0 on both binaries and 0/23 on `/bin/false`; u2r
  787/17/67 ×2 on both binaries with a keyed both-mode join of 1742 rows
  showing **0 differing rows**; surelog 474/9 + 469/8 on both, bucket for
  bucket; u2r `byteverify SELFCHECK=1` **MOVERS 0/1608**; every protected
  database SAME and on its pin; 1531 + 1742 `slang:` lines per workdir, all
  naming the frozen binary, **0 main-tree references**.

## My own positive control, and my own mover attribution

`evidence/POSCTL.independent.txt` — the u2r corpus test
`cva6_struct_param_field`'s own sources give **0 substantive lines** between
the two binaries; the same sources with ONE setter changed from `32'd64` to
`128 - 64` give exactly `UINT:64`→`INT:64` and `vpiConstType:9`→`:7` and
nothing else. The corpus zero is sighted.

My surelog sweep drew **5** movers (the implementer's drew 4, a different
subset): `MiniAmiq` both modes, `SeqDriver` both modes, `Scoreboard/default`.
Order-blind, each is the documented UVM coin — `Scoreboard/default` **0
substantive lines**, the other four **one `UINT:`/`vpiDecompile` LINE-NUMBER
pair** (`1407`↔`0`, `1127`↔`0`, `705`↔`1520`, `936`↔`891`) and **never a
`vpiConstType`**, which is what this law's signature would have to contain.
Control: the SAME frozen pristine binary re-run twice on `MiniAmiq/default`'s
own command line drew two MORE distinct hashes (`220734d3e89b`,
`67449e0a9275`), four across four invocations.

## The wide boundary (the gate the pass did not report)

`bnd66v.sh` over **all 977 committed probe arms that contain an assignment
pattern**, both binaries run in the SAME directory with the SAME output name
so the serializer's embedded path is identical: **957 unchanged, 20 movers**
(`evidence/BOUNDARY.977arms.txt`). Eight are this pass's own grid. The other
**12 are earlier-pass arms** — `r11v61repro/v9,v15`, `r11u56repro/grid/{e1_enc56,
e2_width56,e4_share56,e5_deffill56}`, `r11v56repro/grid/{x1_optable,x2_enum,
x3_names,x4_nest,x5_scope}`, `r11v55repro/grid/vv3_default` — and every one was
re-run against a real Surelog v1.87 golden (`evidence/BOUNDARY.regolden.txt`,
all `slrc=0 ourrc=0 slerr=0`): **AWAY 0, MOVED-WRONG 0**, every changed cell
moves TOWARD golden on `vpiConstType` + `vpiDecompile`. The three
count-mismatched arms were hand-aligned: `e1_enc56` is 5 changed cells, 5 TO
(`INT:-1`, `INT:-1`, `INT:-6`, `INT:5`, `INT:-5`, each matching golden's ct and
decompile); `e2_width56`'s changed cell is the `sn: -1` setter reaching golden's
`ct 7 / "-1"`; `e5_deffill56` is 2 cells, 2 TO.

## The eight adversarial arms (`grid/`)

| arm | what it attacks | judge-field result |
|---|---|---|
| `a1_ovf66` | the digit rule, DISAMBIGUATED: every cell of `g3_neg66` is consistent with BOTH "the setter's own value" and "the member-masked value read as signed", because every value it measured FITS the member | golden writes `INT:400` onto an 8-bit member, `INT:21` onto a 4-bit one, `INT:-300` onto an 8-bit one — **the full value, no masking**; law matches all six; **TO 5, AWAY 0** |
| `a2_uwrap66` | the UNSIGNED WRAP: `KU - 5` with `KU` a `bit [31:0]` | golden `INT:-2` for all of `KU-5`, `IU-5`, `BU-5`, `LU-5`; the law writes `INT:4294967294` / `INT:0`. **wrong→wrong, AWAY 0** — residue R-V1 |
| `a3_inst66` | PER-INSTANCE: is `ectx.tryEval` the instance's context? | `u1` `INT:10`/`INT:-95`, `u2` `INT:14`/`INT:-93`, `u3` `INT:6`/`INT:-97` — all six exactly golden. **TO 6** |
| `a4_wide66` | >64-bit values, `int64` MIN−1, x-values | the >64-bit cells ABSTAIN (no garbage digits); `96'd5 * 2` and `64'sh8000…-1` match golden exactly. **TO 2, AWAY 0** |
| `a5_nest66` | the nested-pattern and packed-array-member roads | the law does not enter them; the pre-existing flat-fold of a packed array member is left alone. **AWAY 0** |
| `a6_misc66` | cast-under-subtract, enum-under-add, two-hop chains, shift-feeding-subtract, the `KU + 1` fence | `KU + 1` is golden `UINT:7` and stays `UINT:7`; `int'(K)-1` and `E_A+1` abstain (STILL). **TO 5, AWAY 0** |
| `a7_arith66` | WHOSE ARITHMETIC — `BIG * 2` with `BIG = 2000000000` | **the one field-level regression**, below |
| `a8_real66` | `K ** -1`, `2 ** 40`, `$rtoi(R) * 2` | `K ** -1` is golden `INT:0` and converges exactly; `2 ** 40` is golden `INT:1099511627776` where slang truncates to 0 (R-V1 again) |

## R-V1 — THE VALUE RULE IS THE PRODUCER'S int64 ARITHMETIC OVER THE REDUCED OPERANDS, NOT THE SETTER'S OWN TYPE

The pass's F2 says the law "writes the setter's own value in its
self-determined type". Golden does not. `ExprEval::reduceExpr` reduces each
operand to a constant, reads it with `get_value` as `int64_t`, and applies the
arm in `int64_t` (`templates/ExprEval.cpp:3454` `int64_t val = val0 - val1`,
`:3490` `val0 * val1`, `:3415` `-val0`, `:3301` the signed `+`) — it never
wraps at the expression's
own width. slang's evaluation does. The two coincide on every cell the pass
measured and diverge on two classes, both measured here on real v1.87 goldens:

* **the unsigned wrap** (`a2_uwrap66`): `bit [31:0] KU = 3; … KU - 5` is golden
  `INT:-2`; the law writes `INT:4294967294`. `bit [63:0] LU = 3; … LU - 5` is
  golden `INT:-2`; the law writes a value string UHDM re-renders as **`INT:0`**
  while pristine carried the right bits. Five cells, all wrong→wrong.
* **the width overflow** (`a7_arith66` `a`, `a8_real66` `b`): `BIG * 2` with
  `BIG = 2000000000` is golden `INT:4000000000`; **pristine's `vpiDecompile`
  was `4000000000`, exactly golden's, and the law's is `-294967296`** — and
  `vpiDecompile` IS a field the judge reads. It is the only such cell in 29
  arms and ~700 scored cells (`DECOMPILE field: TO=24 REGRESSED=1`).

**Why it does not block the landing.** The cell was NOT judge-equal before the
patch and is not after (pristine failed on `vpiConstType`, the law fails on
`vpiDecompile`), so no cell, row or gate verdict moves; corpus movement is 0
in both corpora and both modes, and the census bounds the reachable population
at three `CMP_EQUAL` names none of which moved a byte. The fix is an
EXTENSION of the shared table's value half — the same "extend `dimRedCtExpr79`,
a pass of its own" the implementer fences as R1 — and re-deriving the
producer's arithmetic inside a verifier's minimal fix is exactly what this
pass's reuse mandate forbids. **What the landing should carry instead is the
corrected statement of F2**, and a guard is the natural first line of the
successor pass: the digits are the int64 chain, not `ectx.tryEval`'s
width-wrapped answer.

## R-V2 — re-spelling inside a shape the producer does not have, beyond `ifaceArrayDefFold`

The pass fences `ifaceArrayDefFold` on exactly this principle. The same
situation exists on at least one more face and is NOT fenced: `a8_real66` `d`
(`$rtoi(R) * 2`) is golden an **unfolded `op25`**, where our walk folds it to a
constant and the law now spells that constant `INT:4`. `x1_optable`'s `bxr`
(`KU ^ 3`, golden `op30`) is the same situation and is saved only by the
table's refusal of `^`. Harmless today (the object does not exist in golden, so
the judge fails there either way), but the principle the pass states is not
applied uniformly.

## Residues confirmed as stated

R0 (the bail model's SIZE half — 14 `ENC-TO` cells, and my arms add more: `a1`
`ctl` golden 64 vs ours 32), R1 (the call arm follows the SIGN of the evaluated
result), R2 (`$signed(N)+1` golden `INT:9`, table says UINT), R3–R7 all
re-measured as described. `g7_add66`'s fences hold cell for cell: `pp` `UINT:11`,
`pa` `UINT:10`, `ph` `UINT:41`, `pz` `UINT:11`, `pl` `UINT:18`, `px` `UINT:14`,
`pv` `UINT:4` — golden, pristine and law all agree.

## Reproducing

```bash
git worktree add /tmp/wt 12c6de50 && cd /tmp/wt && git apply -3 /tmp/r11u66.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2 && md5sum build/slang-uhdm     # 82111bbd435b…
G=/tmp/g66v && mkdir -p $G && cp tools/probe/r11v66repro/grid/*.sv $G/
cp tools/probe/r11u66repro/run66.sh $G/
cp tools/probe/r11v66repro/{shapej.py,ord66v.py} $G/
for a in a1_ovf66 a2_uwrap66 a3_inst66 a4_wide66 a5_nest66 a6_misc66 \
         a7_arith66 a8_real66; do
  bash $G/run66.sh $G/$a.sv pris <pristine binary>     # rc for BOTH sides
  bash $G/run66.sh $G/$a.sv law  <law binary>
  python3 $G/ord66v.py $G/$a.g.dump $G/$a.pris.dump $G/$a.law.dump $a
done
# the wide boundary (977 arms, ~20 min at -P 2):
cd tools/probe && grep -l "'{" $(find . -name '*.sv') | sed 's#^\./##' > /tmp/list.txt
xargs -a /tmp/list.txt -P 2 -I{} bash <this dir>/bnd66v.sh {}
```

`bnd66v.sh` reads the two frozen binaries from `/tmp/v11u66_bin/{pris,law}.bin`
and the arms from `/tmp/wt_v11u66/tools/probe`; point those two at your own
paths before running it.
