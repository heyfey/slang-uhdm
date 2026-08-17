# r10rgg2 — the five gates, exactly as run

Binaries (both built in `/tmp/wt_r10rgg2` at `-j 2`, md5 taken separately):

| binary | md5 | what |
|---|---|---|
| `/tmp/r10rgg2_slang_base` | `8e90e5e318029d1336b1c447d9f8356e` | BASE `5c132aa` |
| `/tmp/r10rgg2_slang_patched` | `a3be4c6ccd7aab268a5cd64ca89b31fb` | § compoundLitWriteBackSat2 |

Five intermediate binaries were built and discarded; each answered a question
and each is recorded because a binary that answers a question is evidence:
`e06b07b2…` (the rule did not fire — the parameter initializer is CONVERSION-
wrapped, so the call was never found), `4c3741e6…` (found the site; the replay
bailed on `return list;`, a whole packed ARRAY that `eval` cannot produce),
`3fc8a0da…`/`0…` (bail-line instrumentation), `4c37…`→`p6` (the real bug: slang
spells `bit [15:0]` PackedArrayType too, so `current_n = 16'(n)` read as a
whole-ARRAY assignment; element width 1 is the discriminator).

## Gate 1 — build both, md5 separately
`~/.local/bin/cmake --build build -j 2`, rc=0 both, `md5sum` after. Above.

## Gate 2 — goldens 23/0 and the `/bin/false` negative control 0/23
```
SLANG_UHDM=<patched>  ./tests/check_goldens.sh   -> PASS=23 FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh   -> PASS=0  FAIL=23
```

## Gate 3 — uhdm2rtlil, both modes, BASELINE FIRST
`verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2`, own `--out`/`--workdir`.
**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in both modes, both binaries.**
`ct8rows.sh` three ways, all **0 differing ROWS**:

| comparison | rows | differing |
|---|---|---|
| BASE testflags slice vs committed `results/gate_uhdm2rtlil.csv` | 731 | **0** |
| PATCHED testflags slice vs the same committed CSV | 731 | **0** |
| PATCHED vs BASE, all rows both modes | 1462 | **0** |

## Gate 4 — surelog corpus, both modes
`verify_golden.py --corpus surelog --mode both --jobs 2`.
Both sweeps reproduce the committed `results/golden_surelog.csv` with
**0 differing ROWS over 1588** — status column AND dump column — and
PATCHED vs BASE is also **0 / 1588**.

| row | mode | status | note |
|---|---|---|---|
| `YosysVerx` | both | `CMP_EQUAL,,match` | the judge is clean, AT THE PIN |
| `Rggen` | default | `CMP_NOTEQUAL,decompile:` | predicted: the head MOVES, the row text does not |
| `FuncInModule` | both | `CMP_EQUAL` | the law's canary — same function, N=4 |
| `LogicArrayParam` | both | `CMP_EQUAL` | the law's canary |

`results/*.csv` was READ-ONLY throughout; **nothing was promoted.**

## Gate 5 — byteverify, `SELFCHECK=1`, every mover named and attributed
```
SELFCHECK=1 byteverify.sh /tmp/r10rgg2_wd_p_u2r /tmp/r10rgg2_wd_base_u2r
  databases: patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
  SELFCHECK: 1357 / 1358 flagged
SELFCHECK=1 byteverify.sh /tmp/r10rgg2_wd_p_sl  /tmp/r10rgg2_wd_base_sl
  databases: patched=953 pristine=953     PATH_SETS_IDENTICAL  MOVERS: 2 / 953
  SELFCHECK: 952 / 953 flagged
```

| mover | verdict |
|---|---|
| `./default/Rggen-50ccbd70/slang.uhdm` `188d8fc3c1cf` -> `3605f43ee469` | **MINE, PREDICTED.** The dump diff is **8 lines / 2 changed field lines on ONE object**: `constant@rggen_or_reducer.sv:30:22` `vpiDecompile:1`->`0` and `UINT:1`->`UINT:0`. Nothing else in 1.58M dump lines. |
| `./default/Scoreboard-59431470/slang.uhdm` `66db58c3ff12` -> `95516c83d036` | **NOT MINE — nondeterminism, PROVEN BY THE BASE BINARY.** The delta is a pure ORDER move of 46 design-level `vpiTaskFunc` entries (`svunit_pkg` class methods): the two dumps are the SAME MULTISET of lines (`sort`-identical). CONTROL: 10 runs of the **BASE** binary in the same `--mode both --jobs 2` shape gave `66db58c3ff12` x8 and **`95516c83d036` x2** — the base produces the "patched" hash. 6 patched runs gave 4/2 the other way. Row status and dump column unchanged either way. MEMORY.md "emitter nondeterminism". |

## Canaries — every one at its pin, base and patched, both modes

| row | md5(12) default | md5(12) testflags |
|---|---|---|
| InterfaceModPort | `59a365f3ce2c` | `59a365f3ce2c` |
| BlackParrotComplex | `e3e354129d5a` | `73a10e8217e5` |
| YosysOldOr | `d68e0796d62c` | `d68e0796d62c` |
| SVSwitch | **`4842211c4030`** AT THE PIN | `4842211c4030` |
| YosysVerx | **`6ccda350c24a`** AT THE PIN, `CMP_EQUAL,match` | `6ccda350c24a` |
| Earlgrey_0_1 | `7d55ccc8f53e` | (SLANG_REJECT, unchanged) |
| FuncInModule | `97892e5af8f2` | `384896878f65` |
| LogicArrayParam | `3ed17cfce239` | `17bbf767bb83` |

byteverify's 0-movers-except-two result is the strong form of this table: every
other database in both corpora is byte-identical.

## Ladder — before and after (r10ladder1, MEASUREMENT-ONLY)

```
ctladder built from tools/probe/r10ladder1repro/ctladder.cpp, unmodified UHDM
BEFORE  default:Rggen   70 rungs  FIXPOINT   (= r10rgg1's committed ladder)
AFTER   default:Rggen   69 rungs  FIXPOINT
```
Family histogram delta: `constant|VpiDecompile|DIGITS-ONLY` **8 -> 7**.  Every
other one of the 16 families is UNCHANGED and **no new family appears**; the
`diff` of the two ladders is a pure renumbering after rung 1 is removed.
Committed here as `ladder_BEFORE_default_Rggen.txt` /
`ladder_AFTER_default_Rggen.txt`, with the official heads as
`HEAD_R0_BEFORE_default_Rggen.cmp` / `HEAD_R0_AFTER_default_Rggen.cmp`
(`grep -c '^LHS:'` = 1 in both).

## Boundaries

* The five committed r10rgg1 arms and every earlier fold grid are untouched by
  construction: byteverify says every corpus database except Rggen is
  byte-identical, and the four r10rgg2 arms are byte-identical between the
  binaries too (`/tmp/r10rgg2_armdiff.sh`).
* `real/` and `vsweep/` are the pass's OWN boundary grids and are the only place
  the law fires outside Rggen — 5 of 5 real cells and 5 of 12 vsweep cells exact,
  one over-saturation residue named in README § 7.1, zero pristine-right cells
  broken.
