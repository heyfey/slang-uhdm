# r10v64 — ADVERSARIAL VERIFICATION of r10earl64

**MEASUREMENT ONLY.** BASE `315980a`. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge. This
directory carries the VERIFIER's own arms, instruments and results; it changes
no production file and converts no `results/*.csv` row.

**VERDICT: ACCEPT `/tmp/r10earl64.patch` AS-IS** (md5 `d5647effebf4241967661e799fc57359`).
Every headline number reproduced bit-for-bit, including both binary md5s.
**0 pristine-right -> patched-wrong cells** in 2,681 keyed arm cells, in the
whole-design Earlgrey census (both modes), and in both boundaries.

## 1. Reproduction (independent build, independent sweeps)

| leg | implementer | verifier |
|---|---|---|
| pristine md5 | `8b517a26897fe03b5073146ba00305f0` | **same** |
| patched md5 | `4c8f746b97c20c0cf7f42fe7aea84a59` | **same** |
| goldens pris / pat / `/bin/false` | 23-0 / 23-0 / 0-23 | **same** |
| u2r tf+def, both binaries | 679 / 50 / 2 | **same** |
| surelog `--mode both`, both binaries | 936 EQ / 20 NE / 567 REJ / 48 SLFAIL / 10 DEF / 3 NODB / 2 UNTR / 1 TO / 1 NOUHDM | **same** |
| ct8rows vs committed baselines, both corpora, both modes | PASS | **PASS** |
| ct8rows patched-vs-pristine | PASS | **PASS** |
| u2r byteverify | MOVERS 0/1358 | **MOVERS 0/1358**, PATH_SETS_IDENTICAL |
| surelog byteverify | MOVERS 2/956 | **MOVERS 3/956** — the 2 predicted `Earlgrey_0_1` rows **plus** `Scoreboard/default`, which is the known ORDER COIN (raw diff 78 lines, **sorted diff 0**) |
| heads (`rowheads.sh`) | Earlgrey 64->17 / 28->17, all others still | **same**; the two AFTER logs are byte-identical and match the committed `HEAD_R0_AFTER_*.cmp` byte for byte |
| canaries / ctcan2 / canaudit | 52-0 / 8-0 / PASS / PASS / audited=29 UNCOVERED=0 FENCE-BREACH=0 | **same** |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort / BlackParrotComplex / YosysOldOr identical | **same, both modes** |
| cmds.txt audit by binary PATH | 1458+1458 u2r, symmetric surelog | **same**, 0 main-tree-binary leaks |

## 2. The two laws, re-derived on the verifier's own arms

`v5_conn64.sv` is the complete TARGET-B truth table (11 base spellings x 3
homes x 3 widths). Every cell the new arm moves agrees with golden:
bare `0`/`1`/`8`, `-:` as well as `+:`, a PARENTHESISED bare literal `(0)`,
bare width `4` and sized width `32'd4` — all `UINT` ct 9. Every `'`-bearing
spelling (`32'd0`, `'h0`, `4'd0`, `8'h01`), every parameter-derived base
(`PZ`, `PH`) and the computed `i*4` base are **byte-unchanged**.

`v1`/`v2`/`v3`/`v4`/`v7`/`v10` are the TARGET-A cross product: 13 override
spellings x 20 declared types x 21 read positions x 7 homes x 4 instance
shapes. The fences hold EXACTLY — `tEnum`, `tStru`, `tReal`, `tUnty`,
`tRUnt`, `logic [127:0]` and `logic [64:0]` move **0 cells**, while
`logic [63:0]` (the fence's last legal width) moves TO-GOLDEN.

## 3. Two findings the pass did not report

**F1 — the F-B1 fence misclassifies a TOKEN-PASTED sized literal (`v8_paste64.sv`).**
`` `define PASTE(n) `W32``'d``n `` gives a base whose `rawText` no longer
carries the apostrophe, so `bareB9` reads BARE and mints `UINT` where the
written form would keep `INT`. It is **not a regression**: golden wants
`DEC:0` ct 1 size 32 there and BOTH builds are 0-of-4 fields right, so the
cell is field-wise EQUAL before and after. `v9_pastew64.sv` proves the same
idiom ALREADY misfires in the PRISTINE binary on the WIDTH arm (`bareW9`,
landed earlier): a pasted `32'd4` width gets size 64 on both sides. The
defect is the pre-existing `rawText`-across-macro-buffers idiom, inherited,
not introduced — but it becomes live the day the sized-base encoding is fixed.

**F2 — `srlgAdjustSize` takes the TOTAL width where golden takes the ELEMENT
width for a packed array of a typedef'd vector** (`v10_exotic64.sv`, `tPArr`
`pv10::pair_t [1:0]`): golden `HEX:2` **size 2**, ours size 4 before and
after. Pre-existing (the size field never moves); the pass's copy makes the
other three fields right, so the cells are field-wise BETTER.

## 4. The new R0 is PRE-EXISTING — proved directly, not inherited

`tsfind64.cpp` reads the three Earlgrey databases and prints every constant at
a span with its typespec:

```
flash_phy.sv 133:38-133:47   GOLDEN  ct=9 sz=32 UINT:16 dec=16  TS=NO
                             PRIST   ct=9 sz=32 UINT:16 dec=16  TS=yes -> int_typespec
                             PATCH   ct=9 sz=32 UINT:16 dec=16  TS=yes -> int_typespec
```

Identical in pristine and patched: the head is UNMASKED, not introduced. The
emitting arm (`stampFoldedPkgParamTs` on the hier_path WIDTH) is untouched by
the patch.

## 5. Whole-design Earlgrey, both modes, independent instrument

`allc64.cpp` + `msjoin64.py` — every constant in the design, keyed on span,
payload = ct / size / value / decompile / typespec-kind, scored as a MULTISET:

```
Earlgrey/default    KEYS_TOGOLDEN=5 (268 cells)  KEYS_AWAY=0 (0 cells)
Earlgrey/testflags  KEYS_TOGOLDEN=5 (268 cells)  KEYS_AWAY=0 (0 cells)
```

The five keys are `prim_fifo_sync 72:53` and `74:29` (174 wrong -> 44, the
residue being exactly the 22+22 `32'h2`-vs-`4'h2` decompiles) and the three
conn-base spans `128:32`, `178:32`, `185:32` (4 cells, all cleared).
Golden's encoding histogram at `72:53` is reproduced EXACTLY by the patched
build: 64 `BIN:0010`/4, 22 `HEX:2`/32, 20 `UINT:1`, 14 `UINT:2`, 9
`UINT:63`/64, 3 `UINT:16`, 2 `UINT:32`, 1 `UINT:4`, 1 `INT:2`.

## 6. Boundaries (the verifier's own, from a COPY of `tools/probe`)

```
vwide_v64.sh  PROCESSED=2877 (LISTED=2877) identical=5453 DIFFERING=37 no_output=264
              -> 21 differing arms outside r10v64repro = the committed
                 BOUNDARY_wide.diff, LINE FOR LINE
              -> 8 rc=139 SIGNAL rows, all SYMMETRIC (same arms on both binaries)
vdir_v64.sh   PROCESSED=1345 (LISTED=1345) identical=2443 DIFFERING=18 no_output=229
```

`r10rgg11repro` (14 arms), `r10rgg12repro` (4), `r10earl63repro` (10),
`r10earl60repro` (12), `r10earl62repro` (3), `r10vrgg11repro` (25),
`r10v62repro` (13), `r10v63repro` (8) are **byte-identical in both views** —
earl63's `constCallFoldAdjustSize63`, rgg11's copy-only re-cut and rgg12's
symbolic-call arms all hold. `r10earl61repro/v1_v61.sv` DIFFERS but scores
**TO-GOLDEN 1 / AWAY 0**: TARGET B firing on that arm's `[2 +: W]` conn base
and agreeing with golden. § connOperandOwnScopeBind61 is not broken.

Every differing arm SCORED against a rebuilt golden with `cen64.py`/`sc64.py`
(`armscore_v64.sh`, `dirscore_v64.sh`): **AWAY-GOLDEN = 0, OURS-ONLY-NEW = 0**
in all 32 scored cells.

`r10uvm75repro` and `r10uvm76repro` appear in the per-directory list here and
did NOT in the pass's. Both are the ORDER COIN, not movers: sorted diff = 0,
and four PRISTINE runs of `r10uvm75repro` give four different raw md5s but ONE
order-blind md5 `cdc7b198f62e`, which the patched runs also give.

## 7. Files

`v1_srcs64.sv` override sources · `v2_types64.sv` declared types + every fence ·
`v3_pos64.sv` read positions · `v4_homes64.sv` homes incl. interface ·
`v5_conn64.sv` TARGET-B truth table · `v6_macro64.sv` macro literals ·
`v7_inst64.sv` per-instance copies · `v8_paste64.sv` token-paste trap ·
`v9_pastew64.sv` the same trap on the PRE-EXISTING width arm ·
`v10_exotic64.sv` packed-array / enum-array / 64-vs-65-bit fence edges ·
`varm64.sh` per-arm runner · `cen64.py` positional constant census ·
`sc64.py` 3-way multiset score · `msdiff64.py` whole-dump multiset distance ·
`allc64.cpp` whole-design span census · `tsfind64.cpp` typespec-presence probe ·
`msjoin64.py` span-keyed multiset score · `vwide_v64.sh` / `vdir_v64.sh`
boundaries · `armscore_v64.sh` / `dirscore_v64.sh` mover scorers ·
`GRIDS_v64.txt` the grid table · `BOUNDARY_*_v64.*` · `HEAD_v64_*.cmp`.
