# r10yos1 — measured results

Every number below was predicted in `PREDICTION.txt` **before** it was measured.

## YosysVerx CONVERTS on BOTH modes

`results/golden_surelog.csv` is READ-ONLY here — the master promotes. The two
rows, quoted exactly:

```
< YosysVerx,default,CMP_NOTEQUAL,decompile:,,
< YosysVerx,testflags,CMP_NOTEQUAL,decompile:,,
> YosysVerx,default,CMP_EQUAL,,,match
> YosysVerx,testflags,CMP_EQUAL,,,match
```

Not merely `CMP_EQUAL` — `dump match`, i.e. **byte-identical to Surelog's
golden**: 147,657 dump lines, 24,205 objects, identical on both sides including
the `weaklyReferenced` tail's 1,733 entries and their order.

Per-mode histograms, committed baseline -> fresh:

| mode | CMP_EQUAL | CMP_NOTEQUAL | dump match |
|---|---|---|---|
| default | 469 -> **470** | 11 -> **10** | 225 -> **226** |
| testflags | 465 -> **466** | 8 -> **7** | 165 -> **166** |

Nothing else in the 1,588 rows moved (`ct8rows.sh`: 2 differing ROWS, and those
are the two above).

## Ladder, before and after

| mode | rungs | ours_objs | golden_objs |
|---|---|---|---|
| default BEFORE | 1 (FIXPOINT) | 36,089 | 24,205 |
| default AFTER | **0** (FIXPOINT) | **24,205** | 24,205 |
| testflags BEFORE | 1 (FIXPOINT) | 36,089 | 24,205 |
| testflags AFTER | **0** (FIXPOINT) | **24,205** | 24,205 |

The BEFORE ladders reproduce the committed
`r10ladder1repro/ladder_{default,testflags}_YosysVerx.txt` rung for rung.

## The five gates

1. **Both binaries built `-j 2`, md5 separately** — base
   `4220e4f818406b3c91323967eb59db89` (byte-identical to the repo's own build at
   4df4bab), final `c4831e67ff24a6433043ede119729997`.
2. **Goldens** 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` negative control
   0 PASS / 23 FAIL.
3. **uhdm2rtlil, both modes** 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL,
   both binaries. `ct8rows.sh` **0 differing rows** three ways: baseline
   testflags vs committed `gate_uhdm2rtlil.csv`, patched testflags vs the same,
   and patched vs baseline over all 1,462 rows.
4. **surelog, both modes** — the baseline sweep reproduces committed
   `golden_surelog.csv` with **0 differing rows over 1,588**, so the two moved
   rows are this pass's effect and nothing else's.
5. **byteverify `SELFCHECK=1`**
   * uhdm2rtlil: **0 movers / 1,358** databases, selfcheck 1,357/1,358 flagged.
   * surelog: **2 movers / 953**, both named —
     `./default/YosysVerx-3c02adf6/slang.uhdm` and
     `./testflags/YosysVerx-3c02adf6/slang.uhdm` (both
     `d25dce77fe22 -> 6ccda350c24a`); selfcheck 952/953 flagged.

## Canaries

`canaries.sh`: 52 ok / **0 changed** / 0 absent on the surelog CSV (7
unknown-names, the expected u2r-only set); 16 ok / 0 changed on the u2r CSV.
`ctcan2.sh`: 58 ok / **0 changed** (surelog, EXPECT_UNKNOWN=1) and 2 ok / 0
changed (u2r, EXPECT_UNKNOWN=6).

Named byte canaries, patched surelog workdir:

| test | default | testflags |
|---|---|---|
| SVSwitch | `4842211c4030` | `4842211c4030` |
| InterfaceModPort | `59a365f3ce2c` | `59a365f3ce2c` |
| BlackParrotComplex | `e3e354129d5a` | `73a10e8217e5` |
| YosysOldOr | `d68e0796d62c` | `d68e0796d62c` |

SVSwitch is on its pin (`4842211c4030`), and byteverify already proves all 951
non-YosysVerx databases are byte-identical to baseline, which covers these.
