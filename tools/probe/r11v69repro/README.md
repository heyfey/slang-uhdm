# r11v69 — adversarial verification of r11u69 (`§ caStructParamGenScopeSubst69`)

Base `c69f6ec7`. Worktrees `/tmp/wt_v11u69pris` (pristine) and `/tmp/wt_v11u69`
(patched). Frozen binaries `/tmp/v11u69_pris.bin` (md5
`6c5ffa96f18afef53d6f390fd9daefab`, the OPS pin) and `/tmp/v11u69_pat.bin`
(`907291f20f19eb59fe4497ecf5821e4a`). Both rebuilt from their own trees and
confirmed up to date (`cmake --build` recompiled nothing). The patched tree's
`git diff` is byte-identical to the production surface of `/tmp/r11u69.patch`.

## Verdict

ACCEPT. MOVED-WRONG 0 and AWAY 0 over 515 `cont_assign` cells in 30 arms; both
corpora byte-clean; no landed row, canary or byte pin moved.

## What this directory holds

* `grid/v1..v10` — the arms inherited from the first (dead) verifier run,
  re-measured here from scratch; nothing in their write-up was trusted.
* `grid/w1..w10` — this run's own arms:
  * `w1_netlhs` module NET / VAR / PORT Lhs — golden clones for all three,
    including a NET, and masks a narrow one (`UINT:44 sz=8`). CONVERTS.
  * `w2_lpqual` module localparam and package-qualified (`p::LIT.n`) bases.
  * `w3_widthcross` member width x Lhs width, 9 rows plus module twins.
  * `w4_xz` X/Z members, a 96-bit based literal, a 96-bit `'1` fill. CONVERTS.
  * `w5_ovr` three overrides plus a default — per-instance clone. CONVERTS.
  * `w6_declorder` target declared after the block, comma-list inside a block.
  * `w7_unreduced` THE REGRESSION PROBE: pattern setters the producer might
    refuse (`$clog2`, a user function call, `$bits`, arithmetic, a cast).
    Golden folds every one, so there is no cell where pristine was right.
  * `w8_unitname` `$unit` and package namesakes.
  * `w9_sharehead` / `w10_sharesize` isolate a declined "share" cell.
* `vrun.sh` — grid runner (golden + one binary per arm, rc recorded for both).
* `shapes69v.py` — the SHAPE LISTER. Keys every `cont_assign` by
  (section, ca span, Lhs span) and scores its Rhs by kind/value/size/consttype/
  decompile. Two things it does that a naive lister does not:
  * it RESOLVES shared objects — `uhdm-dump` prints a revisited object as a
    bare header, so a cell whose Rhs golden shares reads empty and the census
    silently over-reports;
  * `NOSPAN=1` drops the Rhs span from the signature, because no generated
    `Compare` reads `VpiFile`/line/col.
  Calibration golden-vs-golden: 463 cells, 0 differing. Positive control: a
  single `UINT:44` -> `UINT:45` flip inside one cont_assign Rhs is caught.

## Reproduce

```bash
GRID=<writable copy of grid> bash vrun.sh /tmp/v11u69_pris.bin pris
GRID=<writable copy of grid> bash vrun.sh /tmp/v11u69_pat.bin  pat
NOSPAN=1 python3 shapes69v.py cmp <arm>/gold.pat.dump <arm>/ours.pat.dump
```

## Measured findings the implementer's report does not carry

1. **The size of a namesake clone comes from the NAMESAKE, not the target**
   (`v1_namesake`, `v2_ancnamesake`). `bindVariable` binds BY NAME, so when a
   gen-local shadows a module-body (or ancestor-instance) signal of a DIFFERENT
   width, golden's `tps` is the namesake's. `g10_lhsbind` gave both sides 32
   bits and could not see it. Golden `UINT:44 sz=8`, patched `UINT:300 sz=32`.
   Wrong->wrong, not a regression, but the law's W3 width source is wrong on
   this face.
2. **The declined "share" half is a constant at the MEMBER's own width**,
   parented to the cont_assign — not the shared param operand. `w10_sharesize`
   measures it in both directions: member 8 / Lhs 32 -> `HEX:A5 sz=8`; member
   64 / Lhs 32 -> `DEC:70000 sz=64`; member 32 / Lhs 64 -> `UINT:300 sz=32`.
   The Lhs is never consulted, which is `adjustSize` returning at once on a
   null `tps`. Sharing itself is invisible to the judge (no generated Compare
   reads `VpiParent`), so these cells are convertible by the machinery the
   patch already ships.
3. **A package-imported namesake IS found by `bindVariable`; a `$unit` one is
   not** (`w8_unitname`: `gp` golden clones at the package signal's 16 bits,
   `gu` and `gc` golden shares). Our `genCaLhsGenLocal113` declines all three —
   correct twice, one missed conversion.
4. **The interface fence declines one cell golden clones** (`v7_ifacemix`):
   an interface gen-scope target whose name is also declared in the
   instantiating module is found by `bindVariable`'s recursion past the
   interface; golden clones at the module signal's 16 bits.
5. **The lift is byte-neutral.** `R11U69_OFF=1` on the shipped binary
   reproduces the pristine database byte for byte on all 30 arms, and the law
   ON already reproduces it on all 1608 u2r databases — so moving the
   module-level decision and emission into `caStructParamSetter55` /
   `emitCaStructParamSubst55` changed nothing at the module level.
