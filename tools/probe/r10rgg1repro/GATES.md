# r10rgg1 — the five gates, exactly as run

Binaries (both built `-j 2` in `/tmp/wt_r10rgg1`, md5 taken separately):

| binary | md5 | what |
|---|---|---|
| `/tmp/r10rgg1_slang_base` | `46ec7c0bc45b1db39ad166958072c784` | BASE 039295a |
| `/tmp/r10rgg1_slang_patched` | `20d8a03b9c1ecbea5cccdedad856cc33` | § ifaceDotEnumConstFold1 + § enumTernTakenLeafEnc1 |

One intermediate binary was built and discarded: `d002655119822fb33c1eae4568d1661b`
— the first placement of L1's Rhs arm, AFTER the `ifaceDotFresh` early-continue
block, i.e. dead code.  It converted the CA to fresh but left a field-less
Rhs constant; the grid caught it (C1 `loc 28:18`, no value) and the arm moved
INSIDE the early block.  Recorded because a binary that answers a question is
evidence, not noise.

## Gate 1 — build both, md5 separately
`~/.local/bin/cmake --build build -j 2`, rc=0, `md5sum` after.  Above.

## Gate 2 — goldens 23/0 and the /bin/false negative control 0/23
```sh
SLANG_UHDM=/tmp/r10rgg1_slang_patched ./tests/check_goldens.sh   # PASS=23 FAIL=0
SLANG_UHDM=/bin/false                 ./tests/check_goldens.sh   # PASS=0  FAIL=23
```

## Gate 3 — uhdm2rtlil, both modes, BASELINE FIRST
```sh
SLANG_UHDM=<base>    verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2 \
    --out /tmp/r10rgg1_base_u2r.csv --workdir /tmp/r10rgg1_wd_base_u2r
SLANG_UHDM=<patched> verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2 \
    --out /tmp/r10rgg1_p_u2r.csv    --workdir /tmp/r10rgg1_wd_p_u2r
```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in **both** modes, **both**
binaries.  `ct8rows.sh` three ways, all `0 differing ROWS`:
baseline testflags slice vs the committed `results/gate_uhdm2rtlil.csv`
(this is what makes the baseline authoritative), patched testflags slice vs the
same committed CSV, and patched-vs-baseline over all 1462 rows.  Dump-column
histograms identical (default 187 differ / 492 match; testflags 183 / 496).

## Gate 4 — surelog corpus, both modes
```sh
SLANG_UHDM=<base>    verify_golden.py --corpus surelog --mode both --jobs 2 \
    --out /tmp/r10rgg1_base_sl.csv --workdir /tmp/r10rgg1_wd_base_sl
SLANG_UHDM=<patched> verify_golden.py --corpus surelog --mode both --jobs 2 \
    --out /tmp/r10rgg1_p_sl.csv    --workdir /tmp/r10rgg1_wd_p_sl
```
BOTH sweeps reproduce the committed `results/golden_surelog.csv` with
**0 differing ROWS over 1588** — status column AND dump column.  The baseline
carries YosysVerx `CMP_EQUAL,match` in both modes and so does the patched
sweep, so the judge is clean.  `default:Rggen` stays `CMP_NOTEQUAL,decompile:`
exactly as predicted (its head is rung 1, untouched).
`results/*.csv` was READ-ONLY here; nothing was promoted.

## Gate 5 — byteverify, `SELFCHECK=1`, movers named and attributed
```sh
SELFCHECK=1 byteverify.sh /tmp/r10rgg1_wd_p_u2r /tmp/r10rgg1_wd_base_u2r
  databases: patched=1358 pristine=1358   PATH_SETS_IDENTICAL   MOVERS: 0 / 1358
  SELFCHECK: 1357 / 1358 flagged
SELFCHECK=1 byteverify.sh /tmp/r10rgg1_wd_p_sl  /tmp/r10rgg1_wd_base_sl
  databases: patched=953 pristine=953     PATH_SETS_IDENTICAL   MOVERS: 2 / 953
  SELFCHECK: 952 / 953 flagged
```

| mover | verdict |
|---|---|
| `./default/Rggen-50ccbd70/slang.uhdm` `455caa7c2e60` → `188d8fc3c1cf` | **MINE, predicted.** Dump diff = 44 fresh elab cont_assigns (L1) + 2 param_assign constant encodings (L2) and NOTHING else (see README §5). |
| `./default/Scoreboard-59431470/slang.uhdm` `c347da7b9a4a` → `0b350a340611` | **NOT MINE — base-binary nondeterminism, proven.** The delta is a pure ORDER move of 46 design-level `vpiTaskFunc` entries (`svunit_pkg` class methods), identical content. CONTROL: the BASE binary run on Scoreboard alone twice, and the BASE binary in a full default-mode sweep, all THREE give `0b350a340611` — the patched value; only the base's both-modes sweep gave `c347da7b9a4a`. 4 base runs, 3 hashes one way. Known class: MEMORY.md "emitter nondeterminism". Row status and dump column unchanged either way. |

## Canaries — every one byte-identical, base vs patched, both modes

| row | md5 (12) | note |
|---|---|---|
| InterfaceModPort | `59a365f3ce2c` | both modes |
| BlackParrotComplex | `e3e354129d5a` / `73a10e8217e5` | default / testflags |
| YosysOldOr | `d68e0796d62c` | both modes |
| SVSwitch | `4842211c4030` | AT THE PIN |
| YosysVerx | `6ccda350c24a` | AT THE PIN, BOTH modes, still `CMP_EQUAL,match` |
| Earlgrey_0_1 | `7d55ccc8f53e9b928d6fa87009575b26` | full md5 — the shared-family prediction |

## Ladder, before and after (r10ladder1, MEASUREMENT-ONLY)
```sh
g++ -O2 -std=c++17 ctladder.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10rgg1_ctladder2   # md5 1ca5be11bf71
CTLADDER=/tmp/r10rgg1_ctladder2 BUDGET=1800 rowladders.sh <workdir> <out> default:Rggen
```
* `default:Rggen` **98 → 70 rungs, FIXPOINT** (before-ladder reproduces the
  committed `ladder_default_Rggen.txt` rung-for-rung, which pins the base).
  Rung 1 byte-identical before and after.
* `default:Earlgrey_0_1` — database byte-identical, so the measurement cannot
  move; rungs 1–394 re-taken on the patched database are byte-identical to the
  before ladder.  (The committed/before Earlgrey ladder is a TRUNCATED artifact
  of a killed process — it ends mid-rung at 395 — so it is not a fixpoint and is
  not quoted as one.)
