# r11vu3 — adversarial verification of r11u3 § `structParamMemberOvBinary`

Measurement-only. The judge is `uhdm-cmp` through `scripts/verify_golden.py`.
Every grid below was built from scratch against the pinned Surelog v1.87
(`[ERROR] : 0` on every arm) and run against BOTH binaries built by this
verifier from a fresh 821fe5cb worktree:

| binary | md5 |
|---|---|
| pristine | `3f6d690887219fc3b2aa46da8c4f30f6` (byte-identical to the main tree at 821fe5cb) |
| patched (`r11u3.patch`) | `2f28c372da15bec082e100bd0dfdea51` |

```bash
OUT=/tmp/r11vu3_out bash run.sh vE <binary> <tag>      # golden + ours + uhdm-cmp
python3 cells.py <golden.uhdm> <ours.uhdm>             # per-instance param_assign Rhs cells
```

`cells.py` reads the ELABORATED section of a `uhdm-dump` and prints, per
(instance, parameter), the Rhs constant's `VpiConstType` / `VpiSize` /
`VpiDecompile` — three of the four fields `constant::Compare` reads — with a
`<<< DIFF` marker. It is a cell-level instrument: it sees a converted cell
that a whole-design `uhdm-cmp` head hides behind an earlier one.

## The twelve grids and what each one breaks

| grid | shape under test | pristine | patched | verdict |
|---|---|---|---|---|
| `vA` | member that is itself a **packed struct**, and a **packed array** member | 5/5 cells wrong | `uhdm-cmp rc=0` | law generalises past scalar members |
| `vB` | the struct base is **itself overridden** one level up (`mid #(.C(8'hA5))`) | both leaf cells wrong | both right | `tryEval` sees the SPECIALIZED value, not the default |
| `vC` | **localparam** base, **positional** override, **packed-union** base | 3 wrong | 2 right, union unchanged | union base: golden emits a `hier_path`, not a constant — the `PackedStructType`-only fence is RIGHT, not merely conservative |
| `vD` | struct with an **80-bit member**, MSB-CLEAR member under `int` | `rc=0` | `rc=0` | the base-shape fence hands this back to the legacy `memBig8` arm with no change |
| `vE` | base **68 bits (>64)**, every member ≤64, MSB-SET members under `int` | `BIN 32'b1000…1` — **WRONG** | `INT:-2147483647` = golden, `rc=0` | the new arm does not merely preempt `memBig8`, it CORRECTS it (`memBig8` never runs `srlgAdjustSize`) |
| `vF` | **interface**, **program**, **genblock**, **defparam** instantiations | interface + genblock cells wrong | both right | the law DOES reach interface parameter overrides, and moves them toward golden; program instance and the defparam residue untouched; order-blind dump diff = exactly 2 cells, 1322→1322 lines |
| `vG` | base built by a **concat containing a param ref**; base is a **package parameter** (`pg::PC.g`) | 4 cells wrong | 4 right | neither shape escapes the law |
| `vH` | formals `real` / untyped-no-default / packed-array / `byte unsigned` | 4 wrong | 3 right, `real` unchanged | a `real` formal never reaches the arm (the actual arrives as a conversion) — ranked residue, unchanged by the patch |
| `vI` | struct with an **80-bit member**, MSB-**SET** member under `int` | `BIN 4'b1010` — wrong | `BIN 4'b1010` — wrong | **R1, correctly stated**: golden is `INT:-6`; we slice (via `memBig8`) but skip `adjustSize`. Pre-existing on BOTH binaries |
| `vJ` | the member select as a **declaration DEFAULT** (`parameter int Q = C.g`) | wrong | wrong (unchanged) | **R3 witness**: golden `BIN 1010` size 4 (bare decompile), ours `8'b10100101` size 8 |
| `vK` | **const-function** base, every member ≤64, incl. a **ternary-produced leftover** member | 3 wrong (one via `memLeftIntRead` → `INT:5`) | 3 right | the new arm correctly preempts `memLeftIntRead` when the base assembles; the fence hands the non-assembling case (`FuncStructVal`) back to it |
| `vL` | **re-pass through type-changing hops** (`int` hop then `logic[3:0]` leaf; `logic[7:0]` hop then `logic[3:0]` leaf) | 4 cells wrong | `uhdm-cmp rc=0` | the leaf takes the ORIGIN slice (`4'b1010`), not the hop's `INT:-6` |

Plus the implementer's own `g1` / `g2` / `g3`, rebuilt here: `g1` becomes
**byte-identical to golden** (`uhdm-dump` match), `g2` reaches `rc=0` with its
`.P(C.m_v4 + 0)` negative control still `UINT:10` size 32 on both sides, `g3`'s
sixteen override cells all converge while its two BASE cells (R0) stay put.

## What the verification found

* No shape was found where pristine is right and patched is wrong. Every
  changed cell in every grid moves TOWARD golden.
* Corpus directional census, all 16 uhdm2rtlil byte movers, order-blind
  path-normalised `uhdm-dump` distance to golden: **16/16 TO-GOLDEN, 0
  AWAY-GOLDEN, 0 NEUTRAL**; 8 of them reach distance 0 (byte-identical).
  Surelog side: 6/6 measurable law movers TO-GOLDEN (2 of the 8 belong to a
  slang-fenced row and were not armed).
* Object counts DROP in the converting grids (g2 5718→5270 dump lines, which
  is golden's own count). The drop is `constant` / `ref_typespec` /
  `param_assign` / typespec lines that the decimal-fold path used to mint;
  `g1` going byte-identical to golden is the proof of direction.

## Claim corrections for the record

1. The implementer's "Zero interface objects are touched" is false as a
   statement of the LAW — `vF` shows an interface instance's parameter
   override takes the new encoding (correctly). It is true as a MEASUREMENT:
   `InterfaceModPort` is byte-identical in both modes.
2. The implementer's R1 ("golden would slice it and the fence stops us") is
   mis-stated. `vI` measures it: we DO slice such a member — the legacy
   `memBig8` arm covers every fenced-out base, because a struct with a >64-bit
   member is always >64 bits wide — we just never run `srlgAdjustSize` on that
   slice. The residue is the missing adjust, not a missing slice.
