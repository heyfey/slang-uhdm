# r11v61 — adversarial verification of r11u61, and the three fences it was missing

Base `2a4ac214` (v1.87 pass 59).  Pins per `SUPPORT_MATRIX.md`: slang
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 (`0445655ee7`, verified `git log -1` in
the pinned tree), uhdm2rtlil v0.68.  Every golden here is a real Surelog v1.87
run through `arm.sh`; every arm records `slrc` / `ourrc` / `slerr`; three
binaries were built in this session's own worktrees and frozen `chmod 555`
before any sweep.

**VERDICT: ACCEPT WITH FIX.**  Every headline number in the implementer's
report reproduces bit-for-bit, and the conversion is real.  But the law as
shipped sizes operands that golden leaves alone in three shapes its 6-arm grid
never carried, and two of them are *pristine-right → patched-wrong* on legal
SystemVerilog.  Three fences are added; the corpora are byte-identical with and
without them.

| binary | md5 | what |
|---|---|---|
| pristine | `9452577e1d0e0d64f87e78ad6e3b3cd6` | `2a4ac214`, byte-identical to the main tree's `build/slang-uhdm` |
| r11u61 | `7f8134d354a92dfe46c7381b7295557e` | the implementer's patch, unmodified — their claimed md5, hit exactly |
| r11v61 | `e2623a8b6ffeff31ef7276edae6951cd` | r11u61 + `§ elabUnpStructOperandBail61v` |

---

## 1. WHAT REPRODUCED

* **The head**, `iface_zero_width_field`, **both** modes, one head per run
  (`grep -c '^LHS:'` = 1), 18 cmp lines: golden `constant 8:37 |vpiSize:32
  |UINT:8` vs ours `|vpiSize:64` — the implementer's quote, character for
  character (`evidence/head.pris.{default,testflags}.cmp`).  After the law:
  **0 cmp lines, 0 heads, `uhdm-cmp` rc 0, both modes.**
* **The SIZE class of the residue.**  The order-blind whole-dump diff at the
  base carries exactly **24** `vpiSize` lines (12 golden `:32` / 12 ours `:64`)
  and **0** after the law; the delta is 24 in both modes.  (My total distance
  reads 645, not the implementer's 527, because my path normalisation leaves
  the golden-cache and source-path lines in.  The *class* and the *delta* are
  the load-bearing numbers and both reproduce.)
* **The conversion.**  uhdm2rtlil **785/19/67 → 786/18/67 in BOTH modes**, and
  the row-level diff against my own pristine sweep is exactly one row per mode:
  `iface_zero_width_field,<mode>,CMP_NOTEQUAL,decompile:,, → …,CMP_EQUAL,,,differ`.
  Nothing else moved.
* **The surelog baseline.**  474/9 default + 469/8 testflags, every bucket
  identical to my own pristine sweep (DEFERRED 5/5, SLANG_REJECT 285/286,
  SURELOG_FAIL 25/23, NO_DATABASE 3, NO_UHDM 1, TIMEOUT 1, UNTRANSLATABLE 2).
* **The grid.**  The implementer's `h1`–`h6`, re-run on my own three binaries,
  score **TO 23 / AWAY 0 / MOVED-WRONG 0 / STILL 9 / SAME 55 / MISSING 13** —
  their §3 table, cell for cell.
* **The movers.**  u2r byteverify `SELFCHECK=1`: **6 / 1608**, the predicted
  three rows × two modes; `iface_zero_width_field` is **12 `|vpiSize:64` →
  `|vpiSize:32` lines and nothing else**, both rp32 rows are **0 order-blind
  lines**.  `pred61.py` on my own pristine workdir reproduces **184 candidates
  → 14 cells on 6 tests**, the same six names, and every measured mover is
  inside it.
* **The producer.**  Read independently in the pinned trees:
  `NetlistElaboration.cpp:262-283` (clone + `substituteAssignedValue` +
  `expandPatternAssignment`), `CompileHelper.cpp:5409-5441` (the operand walk),
  `CompileHelper.cpp:5114-5158` (`adjustOpSize` writes `Bits(member)`).  The
  implementer's decode is correct.

---

## 2. WHAT DID NOT — THE BAIL IS BIGGER THAN THE LAW MODELS

The walk is

```cpp
uint64_t v = eval.get_uvalue(invalidValue, vexp);   // BEFORE the bail
int32_t csize = adjustOpSize(tps, cop, opIndex, rhs, ...);
if (invalidValue) { return result; }                // AFTER the size is written
```

so **the bailing operand is re-sized and every operand after it keeps its own
unsized 64**.  r11u61 fences three ways `get_uvalue` can set that flag (`real`,
`string`, a >64-bit member) because its `h5` arm carried those three values.
`UHDM/templates/ExprEval.cpp:2058-2160` — the producer's own table — has more
entries, and each of the following was measured on a REAL v1.87 golden:

| shape | golden | pristine | r11u61 | class |
|---|---|---|---|---|
| `'{a: -3, b: 2}'` (`byte`,`shortint`) | `INT:-3`@8 `UINT:2`@**64** | `op1` `UINT:2`@**64** | `UINT:253`@8 `UINT:2`@**16** | operand 2 was RIGHT, now WRONG |
| `'{a: 1, b: -2, c: 3}'` | 8 / 8 / **64** | `UINT:1`@8 `op1` `UINT:3`@**64** | 8 / 8 / **8** | operand 3 was RIGHT, now WRONG |
| `'{a: 1'bx, b: 2}'` (`logic[7:0]`,`shortint`) | `BIN:X`@8 `UINT:2`@**64** | **identical to golden** | `BIN:X`@8 `UINT:2`@**16** | **AWAY** |
| `'{a: byte'(7), b: 2}'` | **`op67`** `UINT:2`@**64** | **identical to golden** | `UINT:7`@8 `UINT:2`@16 | **AWAY**, both operands |

*Why*: `case vpiIntConst:` in `get_uvalue` calls `NumUtils::parseUint64` on the
text after `INT:`, so a reduce that produced a NEGATIVE `vpiIntConst` fails to
parse and sets `invalidValue`.  `parseBinary` is a `strtol`-shaped scan, so
`BIN:1x01` survives on its leading `1` while `BIN:X` has no valid digit and
fails.  And Surelog's reduce KEEPS a `byte'(…)` cast as the operand (it folds a
size cast `8'(7)` and an enum cast `e_t'(1)` — arms `v15` `K1`/`K3`), so the
cast operand never reduces and the walk bails there too.

A PASS-THROUGH LITERAL is *not* this case and must not be declined: `8'shFF`
and `32'hFFFFFFFF` are `HEX`-encoded, read unsigned, and golden sizes every
operand (`v11` `A1`/`A2`/`A3`, all TO GOLDEN under the fence).

**Scored over my 15 arms, on real goldens:**

```
r11u61 as shipped :  TO 42   AWAY 2   MOVED-WRONG 15   STILL  8   SAME 110
r11v61 with fences:  TO 38   AWAY 0   MOVED-WRONG  2   STILL 25   SAME 112
```

`evidence/GRID.r11u61.txt` and `evidence/GRID.r11v61.txt` are the full cell
listings.

---

## 3. THE FIX — `§ elabUnpStructOperandBail61v`

Three more disjuncts inside r11u61's own element walk, in `src/ParamEmit.cpp`,
each of which only ever turns the law OFF, so none can mint an AWAY cell:

1. an element that is an **explicit cast** (`ConversionExpression` with
   `!isImplicit()`);
2. an element whose own (pre-conversion) value has **any unknown bit** —
   deliberately broader than "leading digit unknown", which costs `v13`'s `X1`
   (a TO cell) and can never cost correctness;
3. an element that is **not an integer literal** and evaluates to a
   **signed-negative** value.

Cost, measured: 4 of my 42 TO cells (`v13 X1`, `v15 K1`, `v15 K3` and the
`v14 C1` half), **none of which exists in either corpus** — the r11v61 binary
produces databases **byte-identical to the r11u61 binary on all 1608
uhdm2rtlil files** and on all 960 surelog files except the UVM coin.  The
implementer's `h1`–`h6` grid is unchanged (TO 23 / AWAY 0 / MOVED-WRONG 0).

---

## 4. GATES ON THE SHIPPED BINARY (`e2623a8b6ffe`)

1. **Build** `-j 2`, 0 errors, md5 taken separately; pristine md5 matches the
   main tree at `2a4ac214`; the main tree is untouched (`git status` empty,
   binary still `9452577e…`).
2. **Goldens** 23 PASS / 0 FAIL on all three binaries; `SLANG_UHDM=/bin/false`
   0 PASS / 23 FAIL.
3. **uhdm2rtlil both modes** 786 / 18 / 67; `ct8rows.sh` against
   `results/gate_uhdm2rtlil.csv` and against my own pristine CSVs flags exactly
   the two conversion row-sides and no other row.
4. **Surelog `--mode both`** 474/9 + 469/8, bucket for bucket; `ct8rows.sh`
   against `results/golden_surelog.csv` flags only `Earlgrey_0_1`'s dump COLUMN
   (both modes) and the two `LowMem*` workdir PATH texts inside golden-side
   failure messages — **all three are present identically on my PRISTINE
   sweep**, so none is patch-caused.
5. **byteverify `SELFCHECK=1`** vs my own pristine workdirs: u2r **6 / 1608**
   (the three predicted rows × two modes, `iface` = 12 `vpiSize` lines TO
   GOLDEN, rp32 = 0 order-blind lines); surelog **5 / 960**, every one a UVM
   coin draw attributed by RE-DRAW and by order-blind class
   (`evidence/MOVERS.sl.txt`: four rows at the documented 4-line
   `UINT`/`vpiDecompile` class, `Scoreboard` at the documented 0-line order
   draw).  The re-draw control is decisive: `SimpleUVM` moved between the
   pristine and the r11u61 sweep, and the r11v61 binary produces the PRISTINE
   sweep's hash `d4f8cd018f2d`, while three isolated draws of the r11u61 binary
   on the sweep's own command line give `1ee9d46f1406`, `d4f8cd018f2d`,
   `d4f8cd018f2d` — three hashes across two binaries with the sets crossing.
   The differing object is `uvm_misc.svh:642`'s `typedef TYPE types_t[$]`
   queue-range bound, which no struct-pattern law writes.
6. **Protected databases** (`evidence/PROTECTED.{law,fix}.txt`) — every one
   SAME on BOTH binaries: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
   `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex e3e354129d5a` /
   `73a10e8217e5`, `YosysOldOr d68e0796d62c`, **`Earlgrey_0_1 8bdf25272e08` /
   `59d0ee6d10c3`**, `BlackBePipeInt 0754dbaa7154` / `85520d3442c4`.
7. **Canaries** vs my own pristine sweep: surelog `ok=52 changed=0`, u2r
   `ok=8 changed=0`; `ctcan2.sh` PASS on both corpora; `canaudit.sh canaries.sh
   ctcan2.sh` — audited 29, UNCOVERED 0, FENCE-BREACH 0.
8. **rowheads** on the patched surelog workdir: `SeqDriver`, `SimpleUVM`,
   `Scoreboard/default`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1`,
   `BlackBePipeInt` — all **0 cmp lines / 0 heads / rc 0** in both modes;
   `Rggen/default` 64 lines / 1 head, identical on the pristine sweep;
   `Scoreboard/testflags` and `Rggen/testflags` SKIP-NOFILE as expected.
9. **cmds.txt audited by binary PATH**: 1742 u2r + 1531 surelog lines per
   workdir naming the intended frozen binary, **0 main-tree paths in any of the
   six workdirs**.  `results/*.csv` untouched; `GOLDEN_DEFER` unset; no fenced
   test dispatched or named.

---

## 5. RESIDUES THIS VERIFICATION ADDS

* **RV0 — the INT-vs-UINT encoding of a folded operand.**  When Surelog's
  reduce replaces an operation with a fresh constant it sometimes writes
  `vpiIntConst` (`INT:9` for `3 ** 2`, `INT:6` for a constant function call,
  `INT:-3` for `2-5`) where this walk writes `vpiUIntConst`.  Judge-visible
  (`vpiConstType` and the value text).  **Pre-existing on the PACKED road**:
  arm `v9`'s `PN` / `PSW` carry it identically on the PRISTINE and on both
  patched binaries, which is the positive control that it is older than this
  law.  It is the 2 MOVED-WRONG cells left in my grid, and it is the same class
  as r11u61's own R4.  Closing it means decoding Surelog's constant-encoding
  table (`K+1` folds to `UINT`, `3**2` to `INT`) — its own pass.
* **RV1 — the cast table.**  Surelog folds `8'(7)` and `e_t'(1)` but keeps
  `byte'(7)`.  Fence 1 declines all three; decoding which casts reduce would
  recover two TO cells and is the natural companion to RV0.
* **RV2 — golden's `'{default: 7}` fans out to one operand per member and we
  emit a single operand** (`v4` `M2`, both binaries, unmoved by this law).
* r11u61's own R0 (the per-copy `struct_typespec` clone, judge-invisible) is
  confirmed: my order-blind diff of the witness leaves the clone class intact
  on both binaries, and the row is CMP_EQUAL anyway.

---

## 6. FILES

`v1`–`v15.sv` are the adversarial arms (enum edge cases; widths / signedness /
4-state; holders × copy counts × generate; pattern forms; the pass-59 package
face; function / class scopes; the AWAY hunt over shapes the pristine binary
already gets right; setter order and default mixes; negatives beside a PACKED
control; the negative bail isolated; where the bail starts; the fence boundary;
the `x`/`z` and >64-bit operand bails; operands Surelog may not fold; more
operand kinds).  `arm.sh`, `shape.py`, `score60.py` are r11u61's instruments,
unmodified.  `evidence/` holds the four cmp heads, both grid scorings, the two
mover attributions and the two protected-database tables.
