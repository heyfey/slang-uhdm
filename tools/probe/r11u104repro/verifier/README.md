# v11u94 — adversarial verification of r11u104 (ACCEPT-WITH-FIX)

Base `63dfc6fc`. Pins per `SUPPORT_MATRIX.md`. Every golden here is a real Surelog v1.87 run.
All 61 arms (the 51 in r11u104's grid plus the 10 below) read `slrc=0 ourrc=0 slerr=0` on every binary.

| binary | md5 |
|---|---|
| pristine | `3c74f9e404ec5a3d56b951c905e15069` (matches the brief) |
| r11u104 as shipped | `05698a590b36ef354872669983ba99a8` (reproduced bit-for-bit) |
| **r11u104 + this fix** | `4b67e534a6eaafb5b5e007ffbe1a0a71` |
| exploration (the 16 gates read from `R104OFF`) | `24968f12264f189ddcac0d4258bcc9b0`, byte-identical to the fixed binary on all 61 arms with every gate on, and to pristine with every gate off |

## What broke

The second `adjustSize` treated our constant as if it were golden's own encoding. In three shapes it is
a STAND-IN for a different golden encoding, and the resize moved fields wrong. On the 10 verifier arms the
shipped law scores AWAY 16 fields / MOVED-WRONG 131 fields over 72 cells on the net-name key, with the same
numbers on the location key (`CELLS.v11u94.r11u104-wrong.txt`).

1. **A name hop over a based-literal leaf** (`logic [7:0] TUD = UD`, where `UD = 8'd200` / `8'b10000001` / `8'hA5`
   / an untyped `8'sb…`). Golden carries the LEAF's encoding through the hop and resizes that; we write
   `cv`'s `UINT:`.
   * Pristine-right to patched-wrong: `a9_hops94` `wTUD_n4` golden `INT:200`, pristine `UINT:200`, law `UINT:8`
     (the value and decompile digits).
   * `wTUB_n16` golden `BIN:… sz8`, pristine `sz8`, law `sz16`. Golden's BIN keeps its own size at a wider reader.
   * `a8_fixctl94` `hHN4` golden `INT:170`, pristine `UINT:170`, law `UINT:10`.
   * 11 AWAY cells in all. **Fix `hopLit104v`: the resize declines, so the cell stays exactly as pristine wrote it.**
2. **A direct read of a signed based binary literal whose top bit is set, under a typed declaration**
   (`logic signed [7:0] SB8 = 8'sb10101010`, `logic [7:0] = 4'sb1010`, `[7:0]` / `signed` implicit types, `bit signed`).
   * The literal's `int_typespec` sends the declaration's `adjustSize` down the int branch
     (`CompileHelper.cpp:4131-4213`), so golden's value is `INT:-86` / `INT:170` / `INT:175` / `INT:255`.
     Our `BIN:` value is the stand-in for that.
   * The shipped law truncated the BIN digits and rewrote the decompile, moving them wrong-to-wrong.
   * A bare implicit declaration (`localparam IS8N = 8'sb…`) stays `BIN:` in golden, and the truncation is right there (TO).
   * **Fix `sgnBin104v`: golden's INT branch, which sets the size only.**
3. **A binary literal WIDER than its declaration** (`logic [3:0] W8 = 8'b10101010`). Golden truncates at the
   DECLARATION (`BIN:1010 sz4`), while our digits stay the literal's eight, so the read cut the wrong digits
   (`a10_binw94` `wW8_n2` golden `BIN:10`, law `BIN:101010`).
   **Fix `binWide104v`: declined, so the cell stays as pristine wrote it.**

## Score (net-name key / location key, TO / AWAY / MOVED-WRONG, against pristine)

| binary | 51 committed arms | 10 verifier arms |
|---|---|---|
| r11u104 | 833/0/0 · 925/0/0 | 1167/16/131 · 1204/16/131 |
| **fixed** | **833/0/0 · 925/0/0** | **1104/0/0 · 1141/0/0** |

On the 51 committed arms the fixed binary is byte-identical to r11u104. Dropping each of the 16 gates alone
(`DROPS.v11u94.txt`) gives AWAY 0 / MOVED-WRONG 0 on every one of the 13 original gates, and the 13 original TO
counts reproduce r11u104's table exactly. Each of the three new gates, dropped alone, brings back its
own regression, which is the positive control: `hopLit104v` AWAY 16 / MW 60, `sgnBin104v` MW 61,
`binWide104v` MW 8. Turning the seven digit flags on one at a time gives 405/379/377/411/367/613/669, with
AWAY 0 on each.

## Reproduce

Copy `verifier/*.sv` next to the grid, then run `run104.sh <arm> pris=<pristine> lawx=<law>` and
`score104.py` / `../r11u100repro/loc97v.py` exactly as in `../README.md` §8. For the exploration build, replace
each `constexpr bool <gate> = true;` with `const bool <gate> = !off("<gate>")`, reading a comma list from
`R104OFF`.
