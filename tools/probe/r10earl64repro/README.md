# r10earl64 — § elabCaPortParamPaCopy64 + § connIpsBareBaseUint64

**MEASUREMENT-ONLY directory** (the `.sv` under it are probe arms).  The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance
judge.  **BASE `315980a`.**  `results/*.csv` are READ-ONLY and untouched —
**no corpus row was converted by this pass** (`Earlgrey_0_1` is `CMP_NOTEQUAL`
before and after; BOTH its heads moved and the two modes CONVERGED onto one
object).

```
Earlgrey_0_1 / default    cmp 64 lines -> 17 lines   (1 head before and after)
Earlgrey_0_1 / testflags  cmp 28 lines -> 17 lines   (1 head before and after)
```

---

## 1. THE TWO LAWS

### § elabCaPortParamPaCopy64 (TARGET A — earl63's R0-default)

> **The ELAB copy of a bare PARAMETER READ inside a gen-scope cont_assign
> expression is that instance's OWN `param_assign` Rhs constant — value,
> `vpiConstType` and decompiled spelling verbatim — with only its `vpiSize`
> re-decided by `CompileHelper::adjustSize` against the parameter's DECLARED
> typespec.**  We already did this for a module LOCALPARAM (§ genCaLpPaCopy);
> an OVERRIDDEN PORT PARAMETER was fenced out of that arm
> (`!elabParamConst.count(&sym)`) and fell through to a flat
> `UINT`-at-the-declared-width decimal.

**THE CENSUS THAT PROVED IT** (`excen64`, a direct `.uhdm` reader — Earlgrey's
`uhdm-dump` is > 1 GB, earl61/62/63's lesson).  Golden top_earlgrey holds
**127** copies of `prim_fifo_sync.sv:72:53` — the folded `Depth` operand of
`DepthW'(Depth)` inside `gen_normal_fifo` — one per instance whose `Depth != 0`.
Keyed on the instance, golden's encodings are **not** one shape:

| golden fold at 72:53 | n | instances | that instance's own `Depth` `param_assign` Rhs |
|---|---|---|---|
| `BIN:0010` size 4 `4'b0010` | 64 | `reqfifo` / `rspfifo` (`.ReqDepth(HReqDepth[i*4+:4])`) | `BIN:0010` size 4 `4'b0010` |
| `HEX:2` size 32 `4'h2` | 22 | `reqfifo` / `rspfifo` (`.ReqDepth(DReqDepth)`) | `HEX:2` size 32 `4'h2` |
| `UINT:1` size 32 | 20 | `u_maskfifo`, `u_reqfifo`, … | `UINT:1` size 32 |
| `UINT:2` size 32 | 14 | `i_fifo`, `i_slice`, … | `UINT:2` size 32 |
| `UINT:16` / `UINT:32` / `UINT:4` | 6 | `u_rd_fifo`, `u_uart_txfifo`, `u_req_fifo` | the same |
| **`INT:2` size 32** | **1** | **`u_flash_eflash.i_bank_sequence_fifo`** (`.Depth(SeqFifoDepth)`, `localparam int SeqFifoDepth = FlashMacroOustanding * NumBanks`) | **`INT:2` size 32** |

i.e. **the fold EQUALS the parameter's own elaborated `param_assign` Rhs, cell
for cell, in 127 of 127** — and our pristine build wrote one flat `UINT:2`
size 32 `"2"` for **all 127**.  earl63's PREDICT called the INSTANCE (not the
span) the discriminator; the census says the discriminator is the instance's
OVERRIDE, carried through its own `param_assign`.

**THE CONSUMER IS `adjustSize`, NOT A VERBATIM SIZE COPY.**  `gA_earl64.sv`
separates them: `parameter int unsigned P` overridden six ways, read from a
gen-if cont_assign ternary arm —

| override | its `param_assign` Rhs (golden) | golden's FOLD |
|---|---|---|
| `#(.P(SX))`, `localparam int SX = 1*2` | `INT:2` size **4** | `INT:2` size **32** |
| `#(.P(4'h2))` | `HEX:2` size **4** | `HEX:2` size **32** |
| `#(.P(4'b0010))` | `BIN:0010` size **4** | `BIN:0010` size **4** |
| `#(.P(2))` | `UINT:2` size 32 | `UINT:2` size 32 |
| not overridden | `UINT:4` size 32 | `UINT:4` size 32 |

which is exactly `srlgAdjustSize` (§ constCallFoldAdjustSize63's CONSUMER):
`UINT` masked to the target width, `INT`/`HEX`/`OCT` keeping their digits and
TAKING the target width, `BIN` untouched under a predefined-integer target.
`gA2_earl64.sv` runs the consumer over **12 declared types × 8 override
spellings** (609 cells) and the shipped arm reproduces golden in every
`bit`/`byte`/`shortint`/`longint`/`logic [N]`/`logic signed [N]` row too.

### § connIpsBareBaseUint64 (TARGET B — earl63's R0-testflags)

> **The ELAB gen-scope port-connection fold of an indexed part select keeps
> Surelog's UNSIZED-DECIMAL-LITERAL encoding for a BASE written as a bare
> decimal (`vpiUIntConst`, size 64); only a COMPUTED base goes through the
> reduce and comes back `vpiIntConst`.**  This is the exact MIRROR of the
> `bareW9` rule the WIDTH arm four lines below already carried.

`gB_earl64.sv` is the four-row matrix, both `.b`-shaped homes:

| base written as | golden | ours (pristine) | ours (patched) |
|---|---|---|---|
| `bus[0 +: BW]` | `UINT:0` ct 9 size 64 | `INT:0` ct 7 size 64 ✗ | `UINT:0` ✓ |
| `bus[i*4 +: BW]` | `INT:0` / `INT:4` ct 7 size 64 | same ✓ | unchanged ✓ |
| `bus[32'd0 +: BW]` | `DEC:0` ct 1 size 32 `32'd0` | same ✓ (arm never fires) | unchanged ✓ |
| `bus['h0 +: BW]` | `HEX:0` ct 5 size −1 `'h0` | same ✓ | unchanged ✓ |
| module-body home (no gen scope) | `UINT:0` size 64 | same ✓ | unchanged ✓ |

Corpus reach measured on golden top_earlgrey: **exactly 4 cells**, all four
wrong before and all four right after —
`gen_flash_banks[{0,1}].i_core` `.host_addr_i(host_addr_i[0 +: BankAddrW])`
(flash_phy.sv:128, the head) and
`…gen_secded.gen_secded_39_32.u_dec_{a,b}` `.d_o(…[0 +: …])`.

---

## 2. FENCES

* **F-A1 TYPED ONLY.**  `adjustCopiedParamConst64` refuses an UNTYPED or
  ranged-untyped parameter, so an untyped port param keeps the pre-existing
  generic arm.  (`clsParam8`'s untyped branch needs the DEFAULT INITIALIZER
  expression, which the read site does not hold.)
* **F-A2 NO ENUM / STRUCT / UNION / REAL / > 64-BIT.**  Their own arms own the
  encoding — the same fence F3 § constCallFoldAdjustSize63 carries.
* **F-A3 THE ADJUST RUNS ONLY ON THE NEW PORT-PARAM PATH.**  A module
  localparam's `param_assign` Rhs has already been through the same consumer
  at its declaration, so re-running it there would be a no-op this pass
  declines to prove; the localparam arm is byte-identical.
* **F-A4 THE OLD ARM SURVIVES A REFUSAL.**  When the fence rejects the target
  the copy is not taken at all (no stray `MakeConstant` reaches the
  serializer) and the generic `UINT`-at-width mint runs exactly as before.
* **F-B1 BARE UNSIZED DECIMAL ONLY.**  Any `'`-bearing spelling keeps
  `vpiIntConst`; the sized forms never reach the arm.

---

## 3. THE GRIDS (1,650 keyed cells, golden-vs-pristine-vs-patched)

`excen64.cpp` emits one keyed line per LEAF of every `cont_assign` expression
and every port `High_conn`, keyed on the POSITIONAL route (`op<type>[i]`,
`/b`, `/w`, `/idx`, `/l`, `/r`, `/hp[i]`, `/arg[i]`) — no span, no fullname —
with the instance fullname as the owner, so every elaborated copy of one
definition is its own cell.  A `ref_obj` leaf is printed too, because "golden
keeps a reference where we mint a constant" is the other half of every fold
measurement.  `score64.py` joins three censuses as a MULTISET.

| grid | cells | TO-GOLDEN | **AWAY-GOLDEN** | MOVED-WRONG | STILL-RIGHT | STILL-WRONG |
|---|---|---|---|---|---|---|
| `gA_earl64` (6 homes × 15 positions × 6 overrides) | 786 | **18** | **0** | 6 | 695 | 67 |
| `gA2_earl64` (12 declared types × 8 overrides) | 609 | **122** | **0** | 20 | 451 | 16 |
| `gB_earl64` (4 select shapes × 3 homes × 2 widths) | 255 | **8** | **0** | 0 | 221 | 26 |
| Earlgrey_0_1 / default (whole design) | 136,700 | **134** | **0** | 44 | 131,379 | 5,143 |
| Earlgrey_0_1 / testflags (whole design) | 133,617 | **4** | **0** | 0 | 129,932 | 3,681 |
| **`param_assign` census** (`pacen64`, both modes) | 27,626 | 0 | **0** | 0 | 27,506 | 120 |

**0 AWAY-GOLDEN cells anywhere**, and the `param_assign` table is BYTE-STILL
in both modes — this pass moves READ SITES only.

**EVERY MOVED-WRONG CELL IS FIELD-WISE BETTER** (`fieldscore64.py`, which
counts how many of the four Compare-visible fields match golden before and
after): `gA` 24 BETTER / 0 WORSE, `gA2` 142 / 0, `gB` 8 / 0, Earlgrey default
178 / 0, testflags 4 / 0.  They fall into two pre-existing residue families
that the copy now faithfully propagates:

* our own `param_assign` Rhs **decompile** for a based override is `32'h2`
  where golden writes `4'h2` (44 Earlgrey cells) and `0010` where golden
  writes `4'b0010` (6 `gA` cells) — `ct` and `vpiSize` are now right, the
  spelling still is not (R1 below);
* our own `param_assign` Rhs **value** for a NEGATIVE override is the
  malformed `UINT:-3` / a masked `UINT:13` where golden is `INT:-3`
  (20 `gA2` cells) — but the patched cells now carry the parameter's OWN
  typespec (`byte_typespec`, `logic_typespec`) where the old arm forced an
  `int_typespec`, which is golden's, so they gain a field and lose none.

---

## 4. GATES (all mandatory legs, both binaries, frozen before any sweep)

Worktree `/tmp/wt_r10earl64` at `315980a`; both builds `-j 2`, `md5` taken only
after `Built target slang_uhdm`, then frozen `chmod 555` under
`/tmp/r10earl64_bin/` BEFORE any sweep; `SLANG_UHDM` exported explicitly per
binary and **every `cmds.txt` audited by binary PATH** (`/tmp/r10earl64_bin/pris`
and `/tmp/r10earl64_bin/pat1`, 1,458 + 1,458 for u2r and 956 + 956 for surelog,
nothing else; the only 4 `cmds.txt` without a binary are the 2 `SURELOG_FAIL`
tests, symmetric on both sides).

| leg | result |
|---|---|
| pristine binary md5 | `8b517a26897fe03b5073146ba00305f0` |
| patched binary md5 | `4c8f746b97c20c0cf7f42fe7aea84a59` |
| goldens, pristine / patched / `/bin/false` | 23-0 / 23-0 / **0-23** |
| u2r testflags + default, BOTH binaries | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** |
| u2r `ct8rows` vs committed baseline (testflags) | **PASS, 0 differing rows** |
| u2r `ct8rows` patched vs pristine sweep, both modes | **PASS, 0 differing rows** |
| u2r `byteverify SELFCHECK=1` | **MOVERS 0 / 1358**, selfcheck 1357/1358, PATH_SETS_IDENTICAL |
| surelog `--mode both`, BOTH binaries | 936 CMP_EQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / **20 CMP_NOTEQUAL** / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM — identical histograms |
| surelog `ct8rows` vs committed baseline | **PASS, 0 differing rows over 1588** |
| surelog `ct8rows` patched vs pristine sweep | **PASS, 0 differing rows** |
| surelog `byteverify SELFCHECK=1` | **MOVERS 2 / 956 — `default/Earlgrey_0_1` and `testflags/Earlgrey_0_1`, EXACTLY THE PREDICTED SET**, selfcheck 955/956 |
| named-row heads (`rowheads.sh`), pristine → patched | only `Earlgrey_0_1` moves: default 64 → 17, testflags 28 → 17; SeqDriver/SimpleUVM/Scoreboard/MiniAmiq 164, BuildUVMPkg 84, Rggen 64 unchanged |
| canaries | `ok=52 changed=0` (surelog), `ok=8 changed=0` (u2r) |
| `ctcan2` | `ok=58 changed=0` / `ok=1 changed=0`, both **PASS** |
| `canaudit.sh canaries.sh ctcan2.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| byte pins | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`; `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` byte-identical to pristine in BOTH modes |

**The mover set was PREDICTED BY NAME before the sweep** (`Earlgrey_0_1`, both
modes, and nothing else — the two laws are gated on an ELAB gen-scope
cont-assign operand and an ELAB gen-scope conn indexed-part-select base, and
the whole-design census had already named every cell that could move).  The
byte verifier found exactly that set; Earlgrey both modes are byte-deterministic
per binary, so both movers are real.

---

## 5. BOUNDARY (both shapes, both views, both binaries, EVERY mover SCORED)

`vwide64.sh` — EVERY `.sv` under `tools/probe/` at ANY depth (list on fd 3,
children `</dev/null`, `PROCESSED` asserted), plain and `--elabuhdm`:

```
PROCESSED=2869 identical=5453 DIFFERING=21 no_output=264
signal rows: 8 patched / 8 pristine on the SAME 8 arms (pre-existing rc=139)
```

`vdir64.sh` — every probe directory holding `.sv` compiled as ONE unit:

```
PROCESSED=1344 identical=2432 DIFFERING=13 no_output=243
signal rows: 5 patched / 5 pristine on the SAME 5 arms (symmetric)
```

Every differing arm was then **SCORED AGAINST GOLDEN** (`armscore64.sh`,
`dirscore64.sh` — Surelog + both binaries + `excen64` + `score64.py`):

| boundary | arms scored | cells | TO-GOLDEN | **AWAY-GOLDEN** | MOVED-WRONG | STILL-RIGHT | STILL-WRONG |
|---|---|---|---|---|---|---|---|
| per-file | 11 | 2,561 | **154** | **0** | 29 | 2,229 | 149 |
| per-directory | 6 | 4,036 | **153** | **0** | 28 | 3,671 | 184 |

**0 pristine-right → patched-wrong cells in either boundary.**  Every non-`r10earl64`
mover is a gen-scope cont-assign parameter-read arm, i.e. the law's own family;
the three MOVED-WRONG cells outside the pass's own grids
(`r10earl59repro/v59w2_shapes59`, `r10rgg9repro/cells/c_gen`,
`r10vrgg9repro/cells/v_genif`) all sit at a POSITIONAL KEY GOLDEN DOES NOT
HAVE — golden folds the WHOLE cont_assign Rhs to one constant there while both
our builds keep the operation — so the cell was structurally wrong before and
after and only the typespec of an operand golden never emits changed
(`int_typespec` → the parameter's own `bit_typespec` / `logic_typespec`).
Two arms (`r10earl57repro/a1_earl57`, `r10earl59repro/v59w3_ports59`) differ
ONLY by the disappearance of an orphan `int_typespec` the copy path no longer
mints — no constant field moves, and no generated `Compare` reads `VpiParent`.

**One listed mover is an INSTRUMENT ARTEFACT and is refuted here** (the same
refutation earl63 wrote).  `vdir64` reported `elab r10uvm88repro` as DIFFERING:
the retained staging pair has FOUR diff lines that are a `vpiTaskFunc`
LIST-ORDER flip of `p3::base3::oob_base` — the known nondeterminism coin
(RESUME §9).  Sorted (order-blind) the two dumps differ by **0 lines**, and six
runs (3 per binary) of that arm give ONE order-blind md5
(`8ed715c753d146ba`).  It is not a mover.

---

## 6. FILES

| file | what |
|---|---|
| `excen64.cpp` | EXPRESSION-CONSTANT ENCODING CENSUS, read straight from a `.uhdm` (never `uhdm-dump`); one keyed line per leaf of every `cont_assign` expression and every port `High_conn`, keyed on the POSITIONAL route, owner = instance fullname with `R64_INST=1` |
| `pacen64.cpp` | `param_assign` Rhs ENCODING census (earl63's `pacen63`, carried forward) — the fence census that proves this pass moves READ SITES only |
| `cfind64.cpp` | locates a cmp HEAD by span in a database too large to dump (earl63's `cfind63`) |
| `score64.py` | 3-way keyed MULTISET join (golden / pristine / patched) with the TO-GOLDEN / AWAY-GOLDEN buckets |
| `fieldscore64.py` | scores every MOVED cell FIELD BY FIELD against golden (BETTER / WORSE / EQUAL) — the instrument that shows a MOVED-WRONG bucket is still a gain |
| `gA_earl64.sv` | GRID A — 3 homes (module body / if-generate / for-generate) × 15 operand positions × 6 override spellings |
| `genA2_64.py`, `gA2_earl64.sv` | GRID A2 — the CONSUMER matrix, 12 declared types × 8 override spellings, read from a gen-scope ternary arm |
| `gB_earl64.sv` | GRID B — port connections with literal-based selects (`[0 +: W]`, `[W-1:0]`, `[3]`, `{a,1'b0}`, `8'd0`), module scope vs for-generate vs if-generate, two widths |
| `earl64.sh` | Earlgrey_0_1 in either mode with ONE binary → `{slang.uhdm, cmp.log}` against the immutable golden cache |
| `vwide64.sh`, `vdir64.sh` | the recursive per-file and the per-directory boundary sweeps |
| `armscore64.sh`, `dirscore64.sh` | score every boundary mover AGAINST GOLDEN |
| `HEAD_R0_{BEFORE,AFTER}_{default,testflags}.cmp` | the four `uhdm-cmp` head logs |
| `BOUNDARY_*` | the boundary tallies, diff lists, signal lists and scores |
| `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the standard gate battery, carried forward unchanged |
| `PREDICT_R0.txt` | the NEW head (one object, BOTH modes) plus the ranked residue list |
