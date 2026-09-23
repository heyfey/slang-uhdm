# v11u116: adversarial verification of r11u116 (the two ibex heads)

**Verdict: ACCEPT WITH FIX.** One gate is narrowed; the fix is in `/tmp/r11u116.verified.patch`.

## What reproduces bit for bit

- **Binaries.** Pristine `59c4a296` (the pin). The implementer's law binary `56ef1b3c`.
- **Target rows, uhdm-cmp, both modes.**
  - `ibex_pmp` goes from 64 lines / 1 head to 0 / 0.
  - `ibex_icache` goes from 50 / 1 to 0 / 0.
  - Both heads match the brief on both sides: HEX `32'h00000FFF` ct 5 against UINT 4095 ct 9, and ref_obj + enum_const against a UINT:32 constant.
- **Order-blind whole-dump distance.** `ibex_pmp` 5800 → 5776, `ibex_icache` 7120 → 6784.
- **uhdm2rtlil.** 801/3/67 → 803/1/67 in both modes. The only rows that change are the four quoted in `evidence/GATES.txt`. **Both rows convert. `results/*.csv` is not edited.**
- **Surelog.** Status histograms are unchanged.
- **Byteverify.** u2r shows exactly the four databases the census predicted. Surelog shows only UVM movers, all order-blind 4 lines or 0.
- **Implementer grids.** Re-run with my binaries through their own `grid116.sh` / `cells116.py`:

  | grid | pristine EQ / NE | law EQ / NE |
  |---|---|---|
  | f1 | 1120 / 560 | 1190 / 490 |
  | f2 | 478 / 218 | 568 / 128 |
  | f3 | 20 / 110 | 80 / 50 |

  My own location-keyed scorer (`cells_v116.py`, which covers every located object) reads 224 cells moved TO golden and 0 away.
- **Controls.** 993 `dut.sv` arms from the pass-107..115 grids. 33 move, plus 8 that fail to compile on both binaries (rc=3). Scored per cell: 32 cells TO golden, 0 AWAY. Twelve arms are fullname-only movers, `p1::X` → `work@dut.X`, and that is what golden writes.
- **Switches.** `R11U116_OFF=1` gives the pristine bytes on all 191 of my arms. Each face switch reverts exactly its own family.

## Break found: F1 moves cells from one wrong value to another

The F1 gate admitted every predefined-integer home (`loopCaLit116Typed`: canonical `PredefinedIntegerType`). The mint beside the site builds an `int_typespec` for all of them, but golden's clone carries the declaration's own typespec:

- `byte_typespec`
- `short_int_typespec`
- `long_int_typespec`
- `integer_typespec`
- the named typedef object (`vpiName u32_t`)

So 21 arms moved from one wrong value to another. The encoding became right, the typespec stayed wrong, and the judge head moved from `decompile` to the typespec. The arms are `f1_{byteneg,shu,long,integ}_{hdr,body,lp}` and `f1t_{byts,bytu,shs,lgu,intg,intgu,tdint,tdbyte,tdpkg}`.

**Fix (KEYWORD FENCE, `EmitHelpers.h` `loopCaLit116Typed`).** The declared type syntax must be the `int` keyword (`IntType`: `int`, `int signed`, `int unsigned`).

Result of the fix:
- Those 21 arms return to pristine bytes.
- The other 170 of my arms, all 318 implementer grid arms and all 993 control arms are byte-identical to the law binary.
- The target rows are byte-identical to the law binary.
- Every gate is green again. Verified binary md5 `ec0789f5e21ada64200d331a246ecc6a`.

**Residue R1k.** Copy the encoding together with the declaration's typespec kind (or the typedef object). The arms are ready here.

## Other measured cells (none move away from golden)

- **`f2p_top1`.** A `begin : gb` inside a for-generate is a `named_begin` in golden. Golden keeps a ref there with no actual; the law writes ref + enum_const. This is closer to golden, the arm is already structurally 299 lines apart, and the RHS law-24 twin is unchanged.
- **`h1_sva`.** Golden drops the expression of `cover property`, a golden-side miss. Our extra constant becomes an extra ref.
- **`k3_sized`.** The head now lands on a pre-existing masked difference. The module's materialized param_assign copy reads `4'hF` where golden reads `8'hF` (ParamEmit ground, fenced).

## Files

| file | what it does |
|---|---|
| `grid_v116.sh ARMS OUT` | golden + pristine + law per arm; `PRIS` and `LAW` are required |
| `ctl_v116.sh ROOT OUT` | control grids; golden is built only for movers |
| `cells_v116.py OUT` | per-cell TO / AWAY / PARTIAL / OTHER, keyed on (section, five-field span) |
| `census_v116.py DIR...` | the C1..C4 law-shape census, golden vs pristine |
| `orderblind_v116.sh A B` | sorted, id- and path-normalised dump distance |

The arms are in `arms/`. The evidence is in `evidence/`.
