# r11v59 — ADVERSARIAL VERIFICATION of `§ patElabNoMask59`

VERDICT: **ACCEPT**.  Every headline number in the implementer's report is
reproduced bit-for-bit from binaries built here; seven new arms cut the faces
the implementer's grid does not, and **AWAY-GOLDEN is 0 on every one**.  Six
evidence-quality corrections and one new ranked residue are recorded below.

Both worktrees at `4c5747e2`.  Pristine built here reads
`6c1de538ed7301d71a3d704c392123f3` — **byte-identical to the main tree** —
and patched reads `fd9480af20aeb844dce0fe2ec7d8fee1`; both frozen `chmod 555`
before any sweep, and every one of the 1531 surelog and 1742 uhdm2rtlil
`cmds.txt` files was audited by BINARY PATH (1531 / 1742 exact, no leakage to
the main-tree binary).  The patch applies **strictly** clean on a fresh
`4c5747e2` (`git apply --check` rc 0, no `-3` fallback), 23 files, 1870
insertions / 8 deletions, reproducing `src/ParamEmit.cpp`
`870e61f85f60fd0d2c9398885a0490b8`.  Surface is `src/ParamEmit.cpp` plus
`tools/probe/r11u59repro/` only.

---

## 1. The producer and the judge, re-read at the pins

Surelog v1.87 (`0445655ee7`).  `CompileHelper::adjustUnsized`
(`src/DesignCompile/CompileHelper.cpp:5091`) opens `int32_t csize =
c->VpiSize(); if (csize == -1) {` and rewrites a value only when
`get_uvalue` reads 1 — so for every SIZED constant it returns at once.
`CompileHelper::adjustOpSize` (`:5114`) ends each of its four typespec arms in
the same pair, at **`:5154-5155`, `:5170-5171`, `:5190-5191`, `:5200-5201`**:

```cpp
      adjustUnsized(any_cast<constant*>(cop), ncsize);
      cop->VpiSize(ncsize);
```

**There is no mask.**  The law is correct at the producer.

The judge: `expr::Compare` reads `VpiDecompile` then `VpiSize`
(`~/git-repos/UHDM/build/generated/src/expr.cpp:90`, `:95`); `constant::Compare`
reads `VpiConstType` (`constant.cpp:66`); **no generated `Compare` reads
`VpiValue`**.  So the removed `VpiValue` write was judge-invisible and the
removed `VpiDecompile(masked)` was the whole of the damage, on the field read
FIRST.

The bail, re-read: the positional loop (`:5409-5440`) declares `invalidValue`
OUTSIDE itself and never resets it per operand; `if (invalidValue) return
result;` sits at `:5424`, AFTER `adjustOpSize`, and `if (shift < 0 || shift >=
64) return result;` at `:5434`.  The flatten write is at **`:5486-5492`** and
the struct arm's `result = rhs` at `:5495-5497`.

---

## 2. Seven new arms — every changed cell scored against golden BY NAME

`score59v.py` joins by member name + ordinal and compares the THREE judged
fields.  `golden_rc=0 ours_rc=0` on every arm under both binaries; every arm's
cmp line count AND its whole `^LHS:` head BLOCK are byte-identical
pristine↔patched (no falling-count, no earlier head).

| arm | what it cuts | result |
|---|---|---|
| `xv1_fitenc` | THE DECOMPILE FACE on values that FIT (hex/bin/sized/enum-sourced references) | arm demonstrably FIRES (five cells re-sized 32/16 → 8) and **0 lines change**: our substituted element is always bare-decimal `UINT`, so the removed decompile write was the identity wherever a value fits |
| `xv6_boundary` | 2**w vs 2**w−1 at widths 8 / 4 / 1 | `G8`/`G4`/`G1` go from the masked **0** to golden's exact **256 / 16 / 2** on all three judged fields; `E8`/`E4`/`E1` byte-identical |
| `xv2_w63` | the gate's width boundary 63 / 64 / 65 | `A63` 5 → 9223372036854775813 (golden's number); `A64`/`A65` byte-identical — the `>= 64` skip holds |
| `xv5_deadinst` | a dead generate branch, two instances | only the live package cell moves; shape counts unchanged |
| `xv7_overridepkg` | the identical pattern held by a MODULE | untouched under both binaries — the `inPackage` gate holds — and already golden |
| `xv4_evalleft` | the SHARED OBJECT (`patElabElems` → EvalFunc member leftover) | the leftover's value moves 44 → 300 = golden's number; nothing else moves |
| `xv3_flat` | the completed-walk (FLAT) state | the arm does not fire (`structWidePkg` false); 0 change |

**TO-GOLDEN 20 cells / AWAY-GOLDEN 0 / CHANGED-STILL-WRONG 5** over all 15 arms
run here (the implementer's 8 + `va14`/`va15` + these 7).  The 5 still-wrong are
`wa2`'s four base cells and `xv2`'s `A63` — all the encoding residue, all wrong
BEFORE the change too, and scored as still-wrong, not as movement.

### The multiset trap, proved by count

Three arms report a `NEW-golden-only` line and all three are the trap.  Counting
the exact line `          |UINT:0` at its indent:

| arm | golden | pristine | patched |
|---|---|---|---|
| `wa1_widths` | 2 | 1 | 0 |
| `xv2_w63` | 2 | 1 | 0 |
| `xv6_boundary` | 2 | 3 | 0 |

Golden's `UINT:0` lines belong to the 128-bit `W` constant, which we emit as an
OPERATION; our accidental zeros were the masked cells.  By NAME, every one of
those cells goes TO golden.

### The one shape that could have made a cell worse, and does not occur

Removing `VpiDecompile(...)` regresses a cell only where our element carries an
EMPTY decompile that the write used to fill.  Census over both corpora, over the
arm's reachable class (TAGGED `elabpkg` element, `vpiConstType` 9, `0 < vpiSize
< 64`): **6100 cells in surelog + 2 in uhdm2rtlil, ZERO with an empty
decompile.**  The only two corpus cells with that shape are Earlgrey's
`pwrmgr_pkg::PWR_PERI_DEFAULT #0`, which are POSITIONAL (untagged) and therefore
unreachable by an arm that `continue`s on anything but a `tagged_pattern`.

### Coherence

`§ pkgElabPatMemberStamp58` (pass 57) writes **only** `e58->VpiSize(w58)`.
Before this patch the two sites on the same ground contradicted each other; after
it they agree.

---

## 3. Census, reproduced independently

Built `cen59` here and ran `cenrun59.sh` over MY OWN patched workdirs:

```
surelog       GOLDEN-CENSUS cells=92081 overwide=8 overwide_elab=8 rows_overwide=2
uhdm2rtlil    GOLDEN-CENSUS cells=17287 overwide=0 overwide_elab=0 rows_overwide=0
              PREDICT rows=0 cells=0   (candidate_rows 38 surelog / 32 u2r)
```

All 8 OVERWIDE cells are `elabmod`, all `DefaultTag` (4 cells × 2 modes).
**`elabpkg` OVERWIDE = 0 in BOTH corpora** — and `elabpkg` is the only listing
this arm reaches, which is why the corpus mover set is empty.  Read cell by cell
off the golden database directly: golden's `work@top::X` is `FLAT n=4` with
`UINT:15 @ size 2`, `UINT:10 @ 3`, `UINT:15 @ 3`, `UINT:20 @ 3`, **and ours
matches every cell**; `DefaultTag` is `CMP_EQUAL` in both modes.  The corpus
carries the law's own face on a live row the law PROTECTS.

**A census zero needs a positive control**: the same detector on the same binary
reads 5 OVERWIDE cells on `wa1_widths`'s golden, 3 on `xv6_boundary`'s, and
**0** on `wa5_fitctl`'s.

Flatten direction, computed independently (`revflat59v.py`):
`GOLD-TAGGED / OURS-FLAT = 0` and `GOLD-FLAT / OURS-TAGGED = 2` in BOTH corpora —
we never over-flatten, as claimed.

---

## 4. Gates, all re-run here

1. Builds: pristine `6c1de538…` = main tree, patched `fd9480af…`; both frozen.
2. Goldens **23 PASS / 0 FAIL** on BOTH binaries; `SLANG_UHDM=/bin/false`
   **0 PASS / 23 FAIL**.
3. uhdm2rtlil **785 / 19 / 67 in both modes on both binaries**; whole-row joins
   PASS against `results/gate_uhdm2rtlil.csv`, against
   `results/golden_uhdm2rtlil.csv` (both modes), and pristine-vs-patched.
   byteverify **MOVERS 0 / 1608**, selfcheck 1607/1608.
4. surelog **474/9 default + 469/8 testflags on both binaries**.  Against my own
   pristine the ONLY differing rows are the two workdir-path echoes, quoted:
   `LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "…/sl/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,`
   and the same for `LowMemPkg` — status and every histogram identical.
5. surelog byteverify **MOVERS 4 / 960**: `default/MiniAmiq`,
   `default/SimpleUVM`, `testflags/MiniAmiq`, `testflags/SeqDriver` — each
   **exactly 4 order-blind lines**, all `|UINT:<n>` + `|vpiDecompile:<n>` on
   line-number values, the documented UVM class.  **POSITIVE CONTROL:** two
   CONCURRENT sweeps of the PRISTINE binary alone draw `e1f4340a6f09` and
   `d4f8cd018f2d` for `default/SimpleUVM` and `0b755255a716` / `7cfe2e2a8e49`
   for `default/MiniAmiq`; the pristine binary has now produced **five** distinct
   `default/MiniAmiq` hashes and **three** distinct `testflags/SeqDriver`
   hashes, and the PATCHED binary draws the pristine `d4f8cd018f2d` in 3 of 3
   isolated `default/SimpleUVM` runs.  All four stay `CMP_EQUAL`.
   **MOVED-WRONG 0.**
6. Containment over the arm's whole reach: **all 38 arm-reachable surelog
   row-modes byte-identical pristine↔patched with unchanged status**, including
   `FuncStructVal`, `NoReducTypespec`, `ReorderPatt`, `DefaultTag`,
   `ParamComplex`, `Earlgrey_0_1` and `StructParamFuncBodyFieldCompare`.
7. Heads: all 14 measured named-row cmp head blocks byte-identical;
   `StructParamFuncBodyFieldCompare` **74 lines / 1 head in both modes**.
8. Canaries: u2r `ok=8 changed=0`; `ctcan2` PASS on both corpora; `canaudit`
   **audited=29 UNCOVERED=0 FENCE-BREACH=0**; the pass's canary script copies are
   byte-identical to the canonical `r10uvm52repro`/`r10uvm67repro`/`r10sd4repro`
   originals.  Protected databases all at their pins: SVSwitch
   `4842211c4030` (both modes), YosysVerx `6ccda350c24a`, InterfaceModPort
   `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`,
   YosysOldOr `d68e0796d62c`, Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`.
9. Boundary over every committed arm of passes 55 / 56 / 57 / 58 — **27 arms,
   MOVED 0** — and `xd1`…`xd8` reproduce r11u58's published cmp counts exactly
   (14 / 8 / 38 / 5 / 74 / 14 / 5 / 5).
10. `results/*.csv` untouched; fence-name scan over the four slang-fenced names
    0/0/0/0; no fenced test dispatched; `GOLDEN_DEFER` unset.

---

## 5. Corrections the master should apply at integration (none blocking)

1. **Line citations drift.**  The four `adjustUnsized` / `VpiSize` pairs are at
   `5154-5155` / `5170-5171` / `5190-5191` / `5200-5201`, not
   `5153-5154` / `5170-5171` / `5188-5189` / `5199-5200`; the flatten write is at
   `5486-5492`, not `5494-5497`.  The quoted CODE is exact — only the numbers.
   They appear in the landed law comment in `src/ParamEmit.cpp` and in
   `r11u59repro/README.md` §2a and §2c.
2. **`CENSUS.surelog.txt` was generated with `--quiet`**, so the eight
   `GOLD-OVERWIDE` cells are not NAMED in the committed artifact and the
   `DefaultTag` attribution cannot be checked from the evidence as shipped.
   Re-run without `--quiet`; the eight lines are correct.
3. **`pred59.py` says MULTISET, implements a last-writer `dict`**
   (`cells[key] = d`) — the trap RESUME §9 names.  It does not touch the
   OVERWIDE census (that re-scans raw lines) nor the verdict (byteverify is the
   ground truth), but a key collision would silently hide a predicted mover.
4. **README §3c's `PAT SN=8/UINT:-5/-5`** is the raw stored string; the DATABASE
   renders `|UINT:0` with `vpiDecompile:-5`.  The stored `UINT:<negative>` is
   PRE-EXISTING in the DEF view at `4c5747e2`, is judge-invisible, and reaches
   no corpus cell — but the cell notation reads as a database fact.
5. **The R0 flatten census is a LOWER BOUND, not a corpus-wide count.**  It joins
   607 of 1150 golden elaborated patterns (surelog) and 768 of 1657 (u2r);
   restricted to rows with a database on both sides, surelog golden carries 733,
   so coverage is ~83% of the joinable ground and the rest are `SLANG_REJECT`
   rows.  Dispatch the next pass on "2 known, lower bound", not "2 corpus-wide".
6. **Canaries read `ok=51 changed=1` here**, not `ok=52 changed=0`.  The changed
   row is `Earlgrey_0_1 testflags CMP_EQUAL/differ -> CMP_EQUAL/` — the blank
   dump column — and it reads identically under my own PRISTINE binary, so it is
   binary-independent: the ops-documented `uhdm-dump` timeout draw.  Status stays
   `CMP_EQUAL` and the database pin `59d0ee6d10c3` holds.

---

## 6. NEW RESIDUE — rank it above the flatten

**RV1 — `§ patElabUintResize` does not model the producer's STOP, and the STOP
has three causes, not one.**  `adjustOpSize` is called per operand and
`expandPatternAssignment` RETURNS at the first operand that trips
`shift >= 64` (`CompileHelper.cpp:5434`) or `invalidValue` (`:5424`); every
element AFTER that point keeps its SUBSTITUTED size.  Our arm stamps every
reachable member unconditionally.  Measured here:

* `xv2_w63` — the walk returns at `A65` (csize 65), so golden leaves `A1` at its
  substituted **32** while we write **1**.  (The width bail: a NEW face.)
* `wa3_signed` — a negative ends the walk, so golden leaves `UN`/`SW` at **32**
  while we write 8 and 16.  (The implementer recorded this one as §2d.)
* `xv4_evalleft` — the producer's stamp never runs at all (the pattern is read
  by a package `localparam` call, not a parameter default), so golden leaves
  `M8`/`M4`/`M16` at **32 / 32 / 32** while we write 8 / 4 / 16.

`§ pkgElabPatMemberStamp58` already models two of the three breaks
(`if (w58 > 64) break;` and the nested-pattern break).  The two sites should
share that logic.  This is a SIZE-side law on `vpiSize` — the second field
`expr::Compare` reads — it is pre-existing and untouched by this pass, and it is
the sharpest next cut on this ground.

Standing residues, re-measured and confirmed: **RV2** the encoding residue
(golden keeps `HEX:12C`/`32'h12C`, `BIN`, `OCT`, `DEC:300`/`16'd300`, `INT:-5`
where we write decimal `UINT` — two judged fields on every non-decimal element,
the widest thing the grid finds); **RV3** `adjustUnsized`'s `'1 → UINT:255` at
the member width, missing rather than wrong, with no corpus cell; **RV4** slang
truncating `5000000000` into a 32-bit member upstream of the arm (`wa1 M32`);
**RV5** the flatten, bounded as in §5.5.

---

## 7. Instruments (measurement only; the judge is `uhdm-cmp`)

* `cells59v.py` — SHAPE LISTER + per-cell reader for the elaborated package
  listing; prints `SHAPE tagged_patterns=N` beside every census.
* `score59v.py` — scores each changed cell TO-GOLDEN / AWAY-GOLDEN /
  CHANGED-STILL-WRONG on the three judged fields, joined by member name.
* `revflat59v.py` — the flatten census in BOTH directions.
* `delta59v.sh` — the order-blind away-move test, printing every
  `NEW-golden-only` line for the multiset check.
* `grid/xv1…xv7` — the seven arms above; run with
  `GRID=<dir> bash tools/probe/r11u58repro/run54.sh <binary> <tag>`.
