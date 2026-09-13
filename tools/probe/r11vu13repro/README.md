# r11vu13 — adversarial verification of r11u13 (§ `asmEncFollowsRef`)

Everything here is MEASUREMENT-ONLY; the judge is `uhdm-cmp` through
`scripts/verify_golden.py`.  Base commit `74a6bfa2`, pins per `SUPPORT_MATRIX.md`
(slang upstream `7d61e0ad1`, UHDM v1.87, Surelog v1.87, uhdm2rtlil v0.68).
Both binaries were rebuilt from source in this verifier's own worktrees and
frozen before any sweep; every `cmds.txt` was audited by binary PATH.

## 1. What the implementer claimed, and what reproduced

Reproduced bit-for-bit: the pristine build's md5 `2ca79fb72247897ddc2983a1dc40696f`
(identical to the main tree at `74a6bfa2`), the implementer's patched md5
`5a303475d7a90b5c8cc40010aba6549b`, u2r **754/50/67 → 755/49/67 in BOTH modes**
with exactly one differing whole row per mode, the 12/1608 byte movers (six
tests × two modes, every one named a priori by `r11u13repro/predict.py`), and
every moved `param_assign` key TO-GOLDEN.

**THE ROW CONVERTS, both u2r modes:**

```
< struct_param_func_config,testflags,CMP_NOTEQUAL,decompile:,,
> struct_param_func_config,testflags,CMP_EQUAL,,,differ
< struct_param_func_config,default,CMP_NOTEQUAL,decompile:,,
> struct_param_func_config,default,CMP_EQUAL,,,differ
```

The Surelog suite keeps **468/15 (default) and 464/13 (testflags)** against the
committed baseline AND against this verifier's own pristine sweep.  The fixed
binary's 1608 uhdm2rtlil databases are **byte-identical to the implementer's
patched binary's** (0/1608 movers), so every corpus measurement above carries
over to the fix unchanged.

Surelog byte movers, fixed vs this verifier's own pristine: **6/960**
(`MiniAmiq`×2, `SeqDriver`×2, `SimpleUVM`, `Scoreboard`) — the proven UVM coin
family and nothing else, each attributed ORDER-BLIND to 4 sorted-dump lines of
the `UINT:<line>` / `vpiDecompile:<line>` LINE-NUMBER class, or 0 lines
(`Scoreboard`, a pure list-ORDER flip).  **POSITIVE CONTROL, pristine alone:**
the PRISTINE binary run twice on `MiniAmiq`'s and on `SeqDriver`'s own command
lines already differs in bytes, with the same order-blind class.  The count is a
per-run draw — the implementer measured 5 movers, this verifier 6; the NAMES and
the CLASS are the law.  The predictor's two Surelog names (`Ariane2024`,
`Verilator`) build NO database on either binary in either mode.

## 2. THE BREAK — R1 re-derived the value instead of reading the base's

`v3` and `v10` below are the arms that broke the law as implemented.  Surelog
answers a WHOLE read out of the assembled constant's own `Value` and does NOT
re-coerce it to the READING parameter's type: where the reader is declared at a
different packed width, golden still carries the BASE's bits at the BASE's size,
at the parameter and at the `param_assign`, in both module views.  R2 already
sourced the base constant that way; R1 re-derived the bits from `ps.getValue()`
at `slPackedWidth(reader)` and so only coincided when the two types had the same
width.

* `v3` `localparam p::ucfg_t Cut = p::C;` (34-bit reader, 66-bit base) —
  golden `BIN` 66 bits `…0111 1 0 …1110`; the implementer's patch wrote the
  34-bit truncation `1000…001110` at size 34, in BOTH views.
* `v10` the chain through a narrower hop (`M = p::C` at 34 bits, `D = M` at 66) —
  golden stamps the base's 66 bits at EVERY hop; the patch wrote the
  truncate-then-extend value `000…0001000…001110` at `D` as well.

Neither is a pristine-right → patched-wrong regression (pristine emitted the
unfolded `func_call` at both keys), so no corpus row could regress — but the
law's own site was writing a value golden never writes, and the value was wrong
in the direction that matters (a consumer reads a struct member out of it).

**The fix** (this verifier's, minimal and gated): the R1 drain reads `VpiValue`
and `VpiSize` off `asmRefBaseConst(base)` — the same object R2 already reads —
instead of the recorded reader-width bits; the record keeps the reader's width
only as the fold gate.  Nine of the eleven arms and all 1608 corpus databases
are bit-identical before and after the fix; `v3`/`v10` go TO-GOLDEN on the two
keys named above.

**MEASUREMENT TRAP, recorded:** `r11u13repro/pacen.py` clips values to 34 chars.
Two 66-bit BIN values that differ only in the middle then compare EQUAL — `v10`'s
`work@top.D` read TO-GOLDEN under the clipped census and MOVED-WRONG unclipped.
`pacmp.py` disables the clip; never score a wide BIN through it.

## 3. The arms (`grid.sh`, golden + both binaries per arm, every rc recorded)

All eleven: `slrc=0`, `[ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.

| arm | shape | result |
|---|---|---|
| `v1` | the OVERRIDE-CHAIN VALUE: `mid #(.Cfg(p::C2))` re-passing `Cfg` to a leaf | both hops carry **C2**, not the declared default — TO-GOLDEN 2, AWAY 0 |
| `v2` | WIDTH MISMATCH at the override (`narrow #(.Cfg(p::C))`, 34-bit formal) | golden keeps the base's 66 bits; patched matches — **arm CONVERTS, 1 head → 0** |
| `v3` | WIDTH MISMATCH at the default (`localparam ucfg_t Cut = p::C`) | **THE BREAK** (see §2); TO-GOLDEN after the fix |
| `v4` | def-listing SCOPE BOUNDARY + the sibling chain `E = D = p::C` | def view: `D` assembled, `E` stays `ref_obj` — exactly golden; elab view both prefixed; TO-GOLDEN 3, AWAY 0 |
| `v5` | two importing modules, one instantiated twice, plus a package-internal whole read | TO-GOLDEN 11, AWAY 0; confirms first-writer-wins stamps the PACKAGE's own object (pristine stamped the `u_b` import copy's) |
| `v6` | `v5`'s BAIL twin (members the builder never writes) | **databases BYTE-IDENTICAL** |
| `v7` | the MODULE holder (`localparam` built in the module, handed down) | TO-GOLDEN 1, AWAY 0 |
| `v8` | NEGATIVE CONTROLS: member select, cast, non-func-built base, INT localparam | **databases BYTE-IDENTICAL** |
| `v9` | explicit (non-wildcard) import, re-pass through a GRANDCHILD, two instances | TO-GOLDEN 6, AWAY 0 |
| `v10` | the chain through a NARROWER-typed hop | **THE BREAK's second face** (see §2) |
| `v11` | GENERATE-scope instantiation and an INTERFACE holder | TO-GOLDEN 4, AWAY 0 |
| `v12` | the POSITIONAL (ordered) override `leaf #(Cfg)` on the chain value | TO-GOLDEN 2, AWAY 0 — the re-passed actual is **C2**, the override, not the declared default |
| `v13` | `v5` with the PACKAGE declared AFTER every importing module | same verdicts as `v5` — the first-writer-wins mint is not emission-order fragile |

## 4. Residue found, not fixed (judge-invisible)

The R1 constant copies its span from the Rhs object it replaces, so the
ELABORATED copy of a wildcard-imported bare read gets the replaced object's span
(`v5` `work@top.u_b.Cfg`: ours `line:46:25, endln:47:2`, golden
`endln:46:26`).  `constant::Compare` reads no file/line/column, so this is
invisible to the judge and to every status gate; it is a fidelity residue.

## 5. Instruments

* `grid.sh` — carried from `r11u13repro`; golden + both binaries per arm, every rc.
* `pacmp.py` — the UNCLIPPED `param_assign` census, keyed
  `(section, Lhs fullname, occurrence#)` with the payload
  `constant::Compare` reads, joined golden × pristine × patched and scored
  TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG.  No dedup: the occurrence index keeps
  the multiset honest.
* `rowcen.sh` — the same census over a sweep row against that row's OWN golden.
* `dirline.sh` — the order-blind per-LINE multiset census, as a cross-check on
  the keyed one (it conflates families — read it beside `pacmp.py`, never alone).

## 6. Second verifier fix: the delivered directory failed its own audit

`canaudit.sh` excludes only `README*.md` records and itself from the
SLANG-FENCE scan, so `r11u13repro/GATES.r11u13.txt`, which spelled the four
fenced names in its fence-check record, read as **FENCE-BREACH=4, exit 6** on
the delivered tree — the implementer's reported `FENCE-BREACH=0` is not
reproducible from the patch as submitted.  The record now states the result
without spelling the names; re-measured **audited=29 UNCOVERED=0
FENCE-BREACH=0**.  The fenced tests were never dispatched by any driver: the
production diff has 0 hits on all four.

## 7. Gates, all re-measured by this verifier on its own builds and sweeps

| gate | result |
|---|---|
| pristine md5 vs the main tree at `74a6bfa2` | `2ca79fb72247897ddc2983a1dc40696f` — BYTE-IDENTICAL |
| implementer's patched md5, rebuilt from the patch | `5a303475d7a90b5c8cc40010aba6549b` — reproduced |
| this verifier's FIXED binary | `7b9ad4a4e719aedfa23ee8d7743077dd` |
| `tests/check_goldens.sh` (fixed) | 23 PASS / 0 FAIL |
| `SLANG_UHDM=/bin/false` | 0 PASS / 23 FAIL (negative control) |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | 1 differing ROW (the conversion) |
| u2r default vs `results/golden_uhdm2rtlil.csv` | 1 differing ROW (the conversion) |
| surelog vs `results/golden_surelog.csv` and vs own pristine | 0 status/dump moves; 2 rows differ only in the WORKDIR PATH inside a `SURELOG_FAIL` detail string (`LowMemLib`, `LowMemPkg`) |
| `byteverify SELFCHECK=1` u2r fixed vs pristine | 12/1608, selfcheck 1607/1608, every mover predicted BY NAME, every moved key TO-GOLDEN |
| `byteverify SELFCHECK=1` u2r fixed vs implementer-patched | **0/1608** |
| `byteverify SELFCHECK=1` surelog fixed vs pristine | 6/960, selfcheck 959/960, all four proven UVM coin names |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` (after the GATES record fix) | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` 4842211c4030, `YosysVerx` 6ccda350c24a — both modes |
| STATUS pins | `InterfaceModPort` 59a365f3ce2c, `BlackParrotComplex`, `YosysOldOr` — SAME |
| bail witnesses | `FuncStructVal` (CMP_EQUAL), `StructParamFuncBodyFieldCompare` (CMP_NOTEQUAL), `FuncStructValSimple` (CMP_EQUAL) — all BYTE-IDENTICAL both modes |
| `rowheads.sh` on the UVM/Earlgrey rows | identical pristine vs fixed |
| SHAPE LISTER | no row and no arm GREW a shape-differing `param_assign` key |
| every `cmds.txt` audited by binary PATH | u2rp/slp 1742/1581 → pristine, u2rf/slf 1742/1581 → fixed, 0 rows on any other binary |
| `results/*.csv` | UNTOUCHED |

## 8. The SISTER PASS landed mid-verification — re-measured at the new HEAD

`16fd43a8` (v1.87 pass 11, § `castElabFoldTargetKinds`) landed while this
verification ran, and it carries § `elabOvRefAsmBinConst`, which writes exactly
the four fields r11u13's **R2** writes, from exactly the same source (the
referenced parameter's elaborated `param_assign` Rhs when that is a
`vpiBinaryConst`), INLINE at the override site instead of in the drain.  The two
were re-measured together on this verifier's own builds of `16fd43a8`.

* **They compose; nothing double-moves.**  The two laws write IDENTICAL strings,
  and the serializer's symbol table deduplicates by content, so R2's second
  write costs no bytes — measured: at `16fd43a8` the three rows the sister
  already fixed (`def_ctx_struct_param`, `latch_decoder_partial`,
  `latch_tlb_napot`) are **byte-identical** with and without this patch, and the
  arms whose only family site is an override (`v2`, `v8`) are byte-identical
  too.  This is the r11u11 serializer-table lesson's boundary: a re-write with
  the SAME value is free; only a DIFFERENT value strands a table entry.
* **R2 is still not redundant.**  The inline site can only read a base whose
  `param_assign` Rhs is already assembled, so it misses every case where the
  base is emitted AFTER the reader — `v1`/`v12` (the chain through an overridden
  intermediate) and `v7` (the module holder) are still 1–2 keys TO-GOLDEN with
  this patch on top of the sister's.  The deferred drain is what makes the
  answer order-free.
* **u2r at `16fd43a8`: 756/48 → 757/47 in BOTH modes**, one differing whole row
  per mode (`struct_param_func_config`), and the sister's two conversions STAY
  `CMP_EQUAL`.  `byteverify SELFCHECK=1`: **6/1608** — `struct_param_func_config`,
  `param_nested_struct_field_width`, `struct_param_field_shift` × two modes, and
  each of those six databases has the SAME md5 it had when the patch was built
  on `74a6bfa2`.  Goldens 23/0; u2r canaries ok=8 changed=0; grid: 13 arms,
  AWAY-GOLDEN 0, MOVED-WRONG 0.
* **Surelog at `16fd43a8`, both binaries, both modes: 468/15 and 464/13 —
  unchanged**, the same two WORKDIR-PATH-only rows, `byteverify` 6/960 (the four
  proven coin names), and every HARD/STATUS pin and bail witness byte-identical
  at the SAME hashes measured at `74a6bfa2` (`SVSwitch` 4842211c4030,
  `YosysVerx` 6ccda350c24a, `InterfaceModPort` 59a365f3ce2c).
* HEAD pristine md5 `111c93e889c76d7c942cd4a6aea854b5` (identical to the main
  tree's build at `16fd43a8`); HEAD + this patch `aa22f942076295f56fd20551df1ee939`.

The deliverable's base stays `74a6bfa2` per the brief, and it applies clean on a
fresh `74a6bfa2` AND on `16fd43a8` (`git apply --check` rc 0, 0 conflict
markers).
