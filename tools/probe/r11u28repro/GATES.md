# r11u28 — the gate table

Base `bb194df5`.  Both binaries frozen `chmod 555` at immutable paths BEFORE
any sweep; every sweep `scripts/verify_golden.py --jobs 2` into this pass's
OWN `--out`/`--workdir`, with `SLANG_UHDM` exported explicitly.

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `bb194df5` | `12cabf91599980e7325679310a7b22f6` — BYTE-IDENTICAL (the value the brief pins) |
| patched build md5 | `c12e72e928077bc454d7c818a21057fa` |
| `tests/check_goldens.sh` pristine / patched | 23 PASS / 0 FAIL on BOTH |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r scoreboard, both modes, both binaries | 768 CMP_EQUAL / 36 CMP_NOTEQUAL / 67 SLANG_REJECT — the committed baseline |
| surelog scoreboard, both binaries | 469/14 default + 465/12 testflags — the committed baseline |
| `ct8rows` u2r testflags vs `results/gate_uhdm2rtlil.csv` | PASS — every row byte-identical |
| `ct8rows` u2r testflags / default, patched vs this pass's own pristine | PASS in each mode |
| `ct8rows` surelog vs `results/golden_surelog.csv` | THREE differing rows, **0 status moves**: `LowMemLib`/tf and `LowMemPkg`/tf differ only in the WORKDIR PATH inside a `SURELOG_FAIL` detail string, and `Earlgrey_0_1`/tf's DUMP COLUMN (`differ` → blank) |
| `ct8rows` surelog patched vs own pristine | the same two workdir-path rows plus `Earlgrey_0_1`/**default**'s dump column (blank → `differ`) — the coin landing the other way on the other mode |
| `Earlgrey_0_1` | `CMP_EQUAL` both modes on both binaries; the DATABASE is BYTE-IDENTICAL across the two binaries — `8bdf25272e08e21c5e3f565612b5f6fe` default, `59d0ee6d10c350970cd9f8960ebedc56` testflags, the exact r11u26 values.  The dump column is the `uhdm-dump` timeout coin |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1608**, selfcheck 1607 / 1608, path sets identical |
| `byteverify SELFCHECK=1` surelog | **MOVERS 4 / 960** — `MiniAmiq` × 2 modes and `SeqDriver` × 2 modes, both in the PROVEN UVM COIN FAMILY and both named a priori by L2.  **No law mover on either corpus** |
| coin attribution, ORDER-BLIND (`coin.sh`: path- and id-normalised, sorted dumps) | every one of the four: **exactly 4 delta lines**, one `UINT:<n>` plus its `vpiDecompile:<n>` — the line-number class, nothing else — and the sign runs BOTH ways across the four, which a law mover cannot do |
| coin POSITIVE CONTROL | the PRISTINE binary, re-invoked on `MiniAmiq`/default with the harness's own command and cwd, produced a DIFFERENT database each time: the sweep's draw `a5c442dc6030`, then `1d04aa612f18`; four further invocations into a private output directory gave `ddfe23aed595`, `87be01bf2648`, `58e33775df41`, `8e963f345a0d`, none equal to another.  The patched draw is `4c7602112176`.  The family is pinned by NAME and by the coin CLASS, never by a hash or a count |
| `canaries.sh` u2r / surelog | u2r ok=8 changed=0; surelog ok=51 changed=1 — the one change is `Earlgrey_0_1`/tf's dump column, and the PRISTINE sweep changes the SAME column on BOTH modes against the same baseline (ok=50 changed=2) |
| `ctcan2.sh` u2r / surelog | PASS both — surelog ok=58 changed=0, u2r ok=1 changed=0 |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a`, both modes, both binaries — the exact brief values.  `SVSwitch` is one of the eight L2-flagged surelog names and it did not move |
| STATUS pins | `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex e3e354129d5a` default / `73a10e8217e5` testflags, `YosysOldOr d68e0796d62c` — byte-identical across binaries, both modes |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched, line for line (measured=12, SKIP-NOFILE=2 as expected).  `Earlgrey_0_1` 0 heads / 0 cmp lines in both modes |
| every `cmds.txt` audited BY BINARY PATH | 1531 surelog + 1742 u2r pristine rows name `/tmp/r11u28_pris.bin`, 1531 + 1742 patched rows name `/tmp/r11u28_law.bin`, and across all 6646 rows there is NO `slang-uhdm` path outside the golden cache |
| grid arms | 20 arms, every one `slrc=0 [ERROR] : 0`, `pris_rc=0`, `pat_rc=0` |
| grid census | TO-GOLDEN 41, **AWAY-GOLDEN 0, MOVED-WRONG 0**, calibrated golden-vs-golden first (SAME only) |
| grid shape lister | patched vs pristine: NOT ONE operand tree changed on any arm |
| fence check (the four slang-fenced tests) | 0 hits in the production diff; the only hits in `tools/probe/r11u28repro/` are inside `canaudit.sh`, the fence auditor itself; no driver dispatches them |
| `results/*.csv` | UNTOUCHED |

## One ops note, recorded because it happened

While building the coin's positive control, the first three replay invocations
were run with the harness's own `-o` argument still pointing at the PRISTINE
SWEEP's `MiniAmiq`/default database, and overwrote it (three fresh pristine
draws, one after another).  The binary is the same one the sweep used, so the
MOVER SET is unaffected; the file was then regenerated from the sweep's exact
command and cwd (`1d04aa612f18`) and `byteverify` re-run, which is the table's
value above.  It is written down rather than smoothed over because a reader
comparing the sweep's first reported pristine hash for that one path
(`a5c442dc6030`) with the table would otherwise see a mismatch and have no way
to know why.
