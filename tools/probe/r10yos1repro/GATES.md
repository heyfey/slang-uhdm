# r10yos1 — the five gates, exactly as run

Binaries (both built `-j 2`, md5 taken separately):

| binary | md5 | what |
|---|---|---|
| `/tmp/r10yos1_slang_base` | `4220e4f818406b3c91323967eb59db89` | BASE 4df4bab, byte-identical to the repo's own build at HEAD |
| `/tmp/r10yos1_slang_final` | `c4831e67ff24a6433043ede119729997` | § dottedTopNameBareElab |

Two intermediate binaries were built and discarded after they answered a
question (both recorded in the README): `70deeb4bb245de0f327324ed43b906ab`
(def-fill in the top loop — converted the row but left `dump differ`) and
`43b183d25fb4a0f73435436030048b0b` (the `tfContext` predicate behind a switch —
proved inert).

## Gate 1 — build both, md5 separately
Above. `cmake --build build -j 2` in `/tmp/wt_r10yos1`, `md5sum` after.

## Gate 2 — goldens 23/0 and the /bin/false negative control 0/23
```sh
SLANG_UHDM=/tmp/r10yos1_slang_final ./tests/check_goldens.sh   # PASS=23 FAIL=0
SLANG_UHDM=/bin/false               ./tests/check_goldens.sh   # PASS=0  FAIL=23
```

## Gate 3 — uhdm2rtlil, both modes, BASELINE FIRST
```sh
SLANG_UHDM=<base>  verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2 \
    --out /tmp/r10yos1_base_u2r.csv --workdir /tmp/r10yos1_wd_base_u2r
SLANG_UHDM=<final> verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2 \
    --out /tmp/r10yos1_p_u2r.csv    --workdir /tmp/r10yos1_wd_p_u2r
```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in **both** modes, **both**
binaries. `ct8rows.sh` three ways, all `0 differing ROWS`:
the baseline's testflags slice vs the committed `results/gate_uhdm2rtlil.csv`
(this is what makes the baseline authoritative), the patched testflags slice vs
the same committed CSV, and patched-vs-baseline over all 1462 rows.

## Gate 4 — surelog corpus, both modes
```sh
SLANG_UHDM=<base>  verify_golden.py --corpus surelog --mode both --jobs 2 \
    --out /tmp/r10yos1_base_sl.csv --workdir /tmp/r10yos1_wd_base_sl
SLANG_UHDM=<final> verify_golden.py --corpus surelog --mode both --jobs 2 \
    --out /tmp/r10yos1_p_sl.csv    --workdir /tmp/r10yos1_wd_p_sl
```
The baseline sweep reproduces the committed `results/golden_surelog.csv` with
**0 differing rows over 1588** — so the two YosysVerx rows the patched sweep
moves are the pass's own effect and nothing else's. See PREDICTION.txt (written
before the measurement) and the report for the exact rows.

`results/*.csv` is READ-ONLY here; the master promotes, with the rows quoted.

## Gate 5 — byteverify, `SELFCHECK=1`
```sh
SELFCHECK=1 byteverify.sh /tmp/r10yos1_wd_p_u2r /tmp/r10yos1_wd_base_u2r
SELFCHECK=1 byteverify.sh /tmp/r10yos1_wd_p_sl  /tmp/r10yos1_wd_base_sl
```
Every mover is named. The prediction was written down FIRST (PREDICTION.txt).

## Ladder, before and after
```sh
g++ -O2 -std=c++17 ctladder.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10yos1_ctladder
CTLADDER=/tmp/r10yos1_ctladder rowladders.sh <workdir> <out> \
    default:YosysVerx testflags:YosysVerx
```
