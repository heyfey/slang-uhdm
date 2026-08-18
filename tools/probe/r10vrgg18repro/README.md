# r10vrgg18 — ADVERSARIAL VERIFICATION of r10rgg18 (§ genLpFoldDigitsMathValue18)

VERDICT: **ACCEPT WITH A FIX**.  Every headline number in the implementer's
report reproduces bit-for-bit from a fresh `944257e` worktree, including both
binary md5s and the row conversion.  The LAW, however, is stated one clause too
wide, and two shapes of legal SystemVerilog are **pristine-right ->
patched-wrong** under it.  Both are fixed here, minimally and gated; the fix is
corpus-invisible (0 byte movers against the implementer's binary on BOTH
corpora) and the converted row stays converted.

## 1. What reproduced, measured here

| claim | implementer | this verifier |
|---|---|---|
| base binary md5 | `25800a0f4ddabd0e5e67b33ac532cd28` | **same** |
| patched binary md5 | `8b6530321e3b03f0c813a166a5b5f2d1` | **same** |
| goldens base / patched / `/bin/false` | 23/0, 23/0, 0/23 | **same** |
| u2r both modes | 679/50/2 | **same**, base AND patched |
| u2r rows base-vs-patched | 0 / 1462 | **same** (status AND dump) |
| surelog rows base-vs-patched | 1 / 1588 | **same**, and it is the conversion |
| the conversion | `Rggen,default,CMP_NOTEQUAL,decompile:,,` -> `Rggen,default,CMP_EQUAL,,,differ` | **same** |
| surelog base vs committed baseline | 0 differing rows | **same** |
| `HEAD_R0_BEFORE_default_Rggen.cmp` | 64 lines, LHS dec 64/`UINT:64`, RHS dec -64/`UINT:0` | **byte-reproduced** (id-normalised) from my own base sweep |
| rowheads, base | SeqDriver 50/1 SimpleUVM 108/1 Scoreboard 108/1 MiniAmiq 50/1 BuildUVMPkg 32/1 Earlgrey 216/1 Rggen 64/1 | **same** |
| rowheads, patched | `Rggen default 0 cmp lines 0 heads cmp rc=0` | **same** |
| canaries / ctcan2 / canaudit | 52 ok, 16 ok, 58+2 ok, audited=29 UNCOVERED=0 FENCE-BREACH=0 | **same** |
| Rggen census, base-vs-patched | 7 TO GOLDEN, 0 AWAY, 0 STILL | **same** (independent extractor, whole design: 7 / 0 / 0, 18660 unmoved-right) |
| byteverify u2r | 0 movers / 1358 | **same** |
| byteverify surelog | reported "3 / 956" | **4 mover FILES / 956** — `default/Rggen`, `default/Scoreboard`, and `LogicArrayParam` in **BOTH** modes.  The three row-IDENTITIES are right; the file COUNT in the report is one short. |

`LogicArrayParam` is dump-identical in both modes (0 differing lines of 3305 /
3556), 7 bytes smaller, row unchanged — the abandoned-symbol-table decode is
correct.  `Scoreboard/default` is the documented coin and its row is unchanged.

## 2. WHERE THE LAW BREAKS — two families, both AWAY-FROM-GOLDEN

Grid `cells/v1..v4` (gen-scope carriers only; module-scope twins as controls;
`.sv` and `.v`; DEF and ELAB alike), scored GOLDEN vs BASE vs PATCHED per slot
with a Compare-visible payload (`vpiValue`, `vpiDecompile`, `vpiSize`,
`vpiConstType`, `vpiSigned`, RHS object KIND) and **no span**.

**BREAK A — the fold does not fit Surelog's 64-bit word.**
`mathFold46` computes in `__int128` and never wraps; Surelog's `Value` IS a
64-bit word.

```
localparam bit [63:0] OVM = 64'h8000_0000_0000_0000 * 64'd2 + 64'(g);
   golden  vpiDecompile 0     base  0   (RIGHT)   patched 18446744073709551616
localparam bit [63:0] OVS = 64'h4000_0000_0000_0000 * 64'd4 + 64'(g);
   golden  vpiDecompile 0     base  0   (RIGHT)   patched 18446744073709551616
localparam bit [63:0] OV  = 64'hFFFF_FFFF_FFFF_FFFF + 64'd1 + 64'(g);   (v4, .v)
   golden  vpiDecompile 0     base  0   (RIGHT)   patched 18446744073709551616
```
`vpiDecompile` is the FIRST field `expr::Compare` reads.

**BREAK B — a parameter reference is folded from its INITIALIZER, not its
value.**  `mathFold46`'s `NamedValue` arm recurses into the referenced
parameter's initializer; that is sound for a SIGN oracle and wrong for a VALUE
whenever the parameter's own declaration truncated it.

```
localparam bit [7:0] T8  = 16'h1234;          // stored value 8'h34 = 52
localparam bit [7:0] TRD = T8 + 8'(g);        // gen scope
   golden 52 / 53      base 52 / 53 (RIGHT)      patched 4660 / 4661
```

Whole-cell score, base -> patched: v1 **6 AWAY-FROM-GOLDEN** records (2 on the
`parameter` object, 4 on the `param_assign` RHS constant), v4 two more on
`vpiDecompile` alone.  v2 (type zoo: enum, typedef'd vector, packed struct,
unpacked array, real, string, X/Z, based literals, casts, package-homed ref,
66-bit width) and v3 (gen-if both arms, nested gen-for, interface-homed
generate) show **0 AWAY**.

## 3. THE FIX (two guards, `src/ModuleEmit.cpp`)

* **§ genLpFoldWordFits18v** — at the rgg18 call site, drop the walk's answer
  when it is outside `[-2^63, 2^64-1]`.  The window is exactly the 64-bit word;
  golden's own largest measured fold, `UINT:13835058055282163712` (v1 `SGE`,
  a1 `H`), is inside it.  This RESTORES the pristine rendering on Break A —
  it is a refusal, not a second model.
* **§ genLpFoldRefValueNotInitializer18v** — a new default-off `strictRef18`
  parameter on `mathFold46`, passed `true` ONLY by the rgg18 call site, makes
  the `NamedValue`->Parameter arm refuse when the parameter's stored
  `ConstantValue` is not the value its initializer folds to.  Agreement is
  checked against BOTH readings of the stored bits, which is what keeps a
  signed `int` holding `32'hC0000000` folding (v1 `SGA`/`SGB`, both TO GOLDEN).
  Every other caller of `mathFold46` (earl46's sign oracle, the F-1 arm) is
  byte-for-byte unchanged: the default argument is `false`.

Cost of the fix, measured: v1 loses ONE improvement (`TRC`, a 4-bit-declared
parameter whose 8-bit initializer golden does NOT truncate — it returns to the
pristine, wrong, rendering) and gains back six AWAY cells.  **AWAY-FROM-GOLDEN
is 0 on all four adversarial cells and on a1/b1.**

## 4. The fix is corpus-invisible and keeps the conversion

* fixed binary md5 `8492f0b748082a8dacab01aa346ca8f1`; goldens 23/0.
* u2r both modes 679/50/2; rows base-vs-fixed **0 / 1462**; byte movers **0 / 1358**.
* surelog rows base-vs-fixed **1 / 1588** — the same conversion, quoted above;
  rows patched-vs-fixed **0 / 1588**.
* byte movers patched-vs-fixed: **0 / 956** (surelog) and **0 / 1358** (u2r).
* `rowheads.sh` on the fixed workdir: `Rggen default 0 cmp lines 0 heads rc=0`;
  every other named row identical to base.
* canaries 52 ok / 0 changed, u2r 16 ok / 0 changed, ctcan2 58+2 ok / 0 changed,
  `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0.
* a1/b1 grids: patched and fixed are IDENTICAL key-for-key (0 moved slots).

## 5. Instruments in this directory

* `vcen18.py` — view-general census from a `uhdm-dump` text: one record per
  (`parameter` declaration | `param_assign` RHS) with a Compare-visible payload
  only, paths normalised, NO span.  Independent of the implementer's C++ reader.
* `vscore18.py` — 3-way GOLDEN/BASE/PATCHED scorer:
  TO_GOLDEN / AWAY_GOLDEN / MOVED_STILL_WRONG / UNMOVED_RIGHT / UNMOVED_WRONG.
* `vcell18.sh` — one cell: golden (`verify_golden.py`'s DEFAULT argv) + both
  binaries + both censuses.
* `vboundary18.sh` — WIDE 3-WAY boundary over a COPY of the whole `tools/probe`
  tree (`.sv` and `.v`, subdirectories included, no path filter): file list on
  fd 3, children `</dev/null`, PROCESSED asserted == LISTED, rc recorded per
  cell for all three binaries, a planted positive control.
  TRAP FIXED HERE: the dumper prints the DATABASE PATH, so the per-binary
  `.a/.b/.c` output suffix must be normalised out — without it the gate
  reported 2270 false movers.
* `cells/v1..v4` — the adversarial grid.
