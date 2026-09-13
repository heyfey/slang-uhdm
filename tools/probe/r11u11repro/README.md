# r11u11 — the member select of an ASSEMBLED base takes the member's bit slice

§ `memSelAsmBaseOv`.  Everything here is MEASUREMENT-ONLY; the judge is
`uhdm-cmp` through `scripts/verify_golden.py`.  Base commit `d23a8d3f`, pins per
`SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`, UHDM v1.87, Surelog v1.87,
uhdm2rtlil v0.68).

## 1. The producer, decoded from UHDM v1.87 itself

Two arms of `UHDM/templates/ExprEval.cpp` decide this cell, and they are in
series:

1. `reduceExpr`'s `uhdmstruct_var` arm (~4835) — THE ASSEMBLER.  A struct value
   computed by a member-by-member const function arrives as a `struct_var`; the
   arm reads the EvalFunc leftovers back off the shared struct typespec's
   `typespec_member`s and either mints ONE packed `BIN` constant at the struct's
   packed width, or BAILS and hands the `struct_var` straight back (a member
   with an invalid/0 size, or with no `Actual_value`/`Default_value`, or with a
   value that does not reduce to a constant).  **There is no width test in that
   arm** — a 1024-bit member assembles fine (r11u9/r11v11u9 measured it; the
   `mw > 64` rule belongs to `hierarchicalSelector`, not here).
2. `hierarchicalSelector`'s member-NAME arm — THE SLICER.  It slices a member's
   bits out of **a constant base** and mints `BIN:<bits>` / `vpiBinaryConst` at
   the MEMBER's declared width (§ `structParamMemberOvBinary`, r11u3).

So the override actual `.INPUT_WIDTH(CVA6Cfg.INSTR_PER_FETCH)` has exactly two
possible answers, and arm 1 picks which:

* the base **ASSEMBLED** → the slicer has a constant to slice → the member's
  own bit slice, `BIN`, at the member's width, then
  `CompileHelper::adjustSize` against the formal;
* the base **BAILED** → there is nothing to slice; Surelog answers the read out
  of the EvalFunc member leftover stamped on the `typespec_member`, and the
  override inherits THAT constant's encoding.

## 2. The corpus carries BOTH sides on ONE override spelling

Measured golden, Surelog v1.87, `-parse -nobuiltin -nocache -sv dut.sv`,
`[ERROR] : 0` / `: 1` as noted:

| test | `work@top.CVA6Cfg` elab Rhs | `.INPUT_WIDTH(CVA6Cfg.INSTR_PER_FETCH)` |
|---|---|---|
| `FuncStructValSimple` | the assembled **1088-bit BIN**, ct 3 | **BIN `32'b…010`, vpiSize 32, ct 3** |
| `FuncStructVal` | a **`struct_var`** (one member of 97 never folds) | **INT:2, vpiSize 32, ct 7** |

Same formal (`int unsigned INPUT_WIDTH`), same member (`int unsigned
INSTR_PER_FETCH`), same leftover encoding (a ternary body → `Int`), same
1024-bit sibling member (`logic [15:0][63:0] PMPCfgRstVal`), same instantiated
module.  **The base's assemble/bail is the whole distinguisher** — which is the
KEEPING SHAPE the r11u9 residue named, now measured on both sides.

Pristine head on `FuncStructValSimple` (1 head, 32 cmp lines), field
`decompile:`: golden `vpiDecompile:32'b…010` / `BIN:…010` / `vpiConstType:3`
against ours `vpiDecompile:2` / `INT:2` / `vpiConstType:7`.  `vpiSize:32` and
the `ref_typespec → int_typespec` already agreed — the row was ONE head and
THREE FIELDS from equal.

## 3. THE GOLDEN GRID — 12 arms, every arm's rc recorded

`grid.sh` builds golden + both binaries per arm and records `slrc`, the
Surelog `[ERROR]` count, and each binary's rc.  All 12 arms: `slrc=0`,
`[ERROR] : 0`, `pris_rc=0`, `pat_rc=0`.

| arm | shape | golden `C.<member>` override | PRIS | PAT |
|---|---|---|---|---|
| `a1` | PACKAGE holder, ASSEMBLES, wildcard import, 1024-bit member | BIN `32'b…010` | INT:2 | **BIN ✔** |
| `a2` | `a1`'s BAIL twin (a member the function never assigns) | INT:2 | BIN | BIN (unchanged) |
| `a3` | MODULE holder, ASSEMBLES, every member ≤ 64 bits | BIN `32'b…010` | BIN ✔ | BIN ✔ (BYTE-IDENTICAL) |
| `a4` | `a3`'s BAIL twin | INT:2 / UINT:32 | BIN | BIN (unchanged) |
| `a5` | MODULE holder, ASSEMBLES, 1024-bit member | BIN `32'b…010` + `32'b…100000` | INT:2 / UINT:32 | **BIN / BIN ✔** |
| `a6` | `a5`'s BAIL twin | INT:2 / UINT:32 | BIN | BIN (unchanged) |
| `a7` | `a1` with an EXPLICIT import | BIN `32'b…010` | INT:2 | **BIN ✔** |
| `a8` | `a1` with NO import (qualified `p::C.B`) | BIN `32'b…010` | INT:2 | **BIN ✔** |
| `a9` | NEGATIVE CONTROLS on an assembled base | see below | = PAT | = PRIS (BYTE-IDENTICAL) |
| `a10` | base NOT function-built (plain pattern localparam) | UINT:2 | BIN | BIN (BYTE-IDENTICAL) |
| `a11` | the RE-PASS (child hands its formal to a grandchild) | BIN `4'b1010` ×2 hops | INT:10 ×2 | **BIN ✔ / INT:10** |
| `a12` | the FORMAL × MEMBER matrix on an assembled base | 9 cells | 0/9 | **9/9 ✔** |

**`a12`, the adjust-size matrix** — PAT is golden-exact on every cell, pristine
on none:

| formal | member | golden = PAT | PRIS |
|---|---|---|---|
| `int` | `logic [3:0]` | INT:-6 sz 32 | INT:10 sz 32 |
| `int` | `logic` | INT:-1 sz 32 | UINT:1 sz 32 |
| `int` | `enum logic [1:0]` | BIN `2'b01` sz 2 | UINT:1 sz 32 |
| `logic [3:0]` | `logic [3:0]` | BIN `4'b1010` sz 4 | INT:10 sz 4 |
| `logic [1:0]` | `logic [3:0]` | BIN `10` **bare** sz 2 | INT:2 sz 2 |
| untyped | `logic [3:0]` | BIN `4'b1010` sz 4 | INT:10 sz 4 |
| `bit` | `logic` | BIN `1'b1` sz 1 | UINT:1 sz 1 |
| `logic [31:0]` | `logic [7:0]` | BIN `8'b11001100` sz 8 | UINT:204 sz 32 |
| `int unsigned` | `int unsigned` | BIN `32'b…100000` sz 32 | UINT:32 sz 32 |

That is `srlgAdjustSize`'s existing model, unchanged, fed by one new encoder —
the same two-stage shape r11u3's g2 grid pinned for the immediate arm.

**`a9`, the negative controls** (all three BYTE-IDENTICAL on both binaries):
`.W(C.B + 0)` — a member select inside an OPERATION — is golden UINT:2 and ours
UINT:2 on both; `.H(C)` — a WHOLE-parameter actual — is untouched; `.W(C.N.X)`
— a member OF a member — is untouched.  The select must be the WHOLE actual and
one level deep, exactly as § `structParamMemberOvBinary` already required.

**`a10`, the boundary the law must not cross**: a base that is NOT
function-built never passes through the assembler, so § `structParamMemberOvBinary`'s
own `asmOk8` path owns it — byte-identical on both binaries.

## 4. The law

`src/ParamEmit.cpp` + the record struct in `include/UhdmExporter.h`.  Nothing
else is touched.

1. **The override site** records, it does not write.  When the immediate
   § `structParamMemberOvBinary` arm has DECLINED the actual (`!srcBaseOv8` —
   which for this family means `asmOk8` turned the base away) and the actual is
   a bare one-level member select of a struct-typed parameter whose initializer
   is a `memLeftInitCall`, the arm evaluates the member, renders the slice
   through `srlgOvRender` + `srlgAdjustSize` exactly as the immediate arm does,
   and pushes `{constant, base symbol, value, decompile, size, constType}` onto
   `memSelAsmOv`.  It writes NO field and mints NO object.
2. **The drain** (`stampEvalFuncLeftovers`, last loop, after BOTH assemble arms
   have applied the producer's bail rule) reads the answer off the base itself:
   the base's elaborated `param_assign` Rhs is a `vpiBinaryConst` constant when
   it assembled and a `struct_var` when it did not.  Only then are the four
   fields `constant::Compare` reads — `VpiValue`, `VpiConstType`, `VpiSize`,
   `VpiDecompile` — written over.
3. **The carve-out is NOT deleted.**  `memLeftIntRead` / `!memLeftReadEnc` ARE
   the bail answer: they stand wherever the base did not assemble, and the
   re-key is done by PRECEDENCE — the drain out-ranks them where the base
   assembled and is silent where it did not.  `FuncStructVal` proves it: 0
   heads and a BYTE-IDENTICAL database on both binaries.

**Why the deferred arm runs only where the immediate one declined.**  Writing
the same four fields twice is not free: the discarded strings stay in the
serializer's table and MOVE THE DATABASE'S BYTES while `uhdm-dump` and
`uhdm-cmp` read identical.  Measured: the first form of this law, which took
every function-built base away from the immediate arm and answered them all in
the drain, left grid `a3` with every cell agreeing on both binaries and a
DIFFERENT file md5 (dump diff: 2 lines, both the tool's own banner).  The
shipped form leaves `a3` byte-identical.  Same lesson as r11u9's
minted-then-discarded constant, one level down.

## 5. Instruments

* `predict.py <corpus-root> [names...]` — the A-PRIORI mover predictor, from the
  SOURCES alone: names every test carrying a bare member select of a
  builder-fed struct parameter as the whole actual of an instantiation
  override.  It over-names by design (the sources cannot know whether the
  assembler bailed — that is what the drain decides), so the measured movers
  must be a SUBSET of what it names.
  * POSITIVE CONTROL: it names BOTH `FuncStructVal` and `FuncStructValSimple`.
    A predictor that named only the converting row would be keyed on the answer,
    not on the shape.
  * NEGATIVE CONTROL: it does NOT name r11u9's two conversions
    (`pkg_nested_struct_param_width`, `portsel_struct_param`) — they carry the
    builder but no member-select override actual.
* `grid.sh` — the golden grid driver (golden + both binaries per arm, every rc).
* `pacen.py` / `stamps.py` / `shapes.py` / `shapecmp.sh` / `dirscore.sh` /
  `arm.sh` — carried from `tools/probe/r11u9repro`; `shapes.py` is THE SHAPE
  LISTER (the r11v7 lesson) and `dirscore.sh` the order-blind directional
  census.
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` — the current-generation canary
  battery.

## 6. What moved

**THE ROW CONVERTS — one test, two row-modes, CMP_NOTEQUAL → CMP_EQUAL:**

* **Surelog suite, BOTH modes: `FuncStructValSimple`.**
  **default 467 → 468 equal, 16 → 15 not-equal; testflags 463 → 464 equal,
  14 → 13 not-equal.**

uhdm2rtlil keeps 748 / 56 / 67 in both modes — no status moves either way, and
`byteverify SELFCHECK=1` reports **0 movers / 1608** (selfcheck 1607/1608), the
a-priori prediction exactly: the predictor names no uhdm2rtlil row.

Movers on the Surelog corpus, PREDICTED BY NAME before any patched sweep ran:

* **`FuncStructValSimple` × 2 modes — the law's own movers, both TO-GOLDEN and
  both now CMP_EQUAL.**
* `FuncStructVal` — the BAIL witness the predictor also named: **BYTE-IDENTICAL**
  in both modes, and still CMP_EQUAL.  `StructParamFuncBodyFieldCompare`, the
  other bail witness (CMP_NOTEQUAL at this base, 1 head / 36 cmp lines in both
  modes, head elsewhere), is BYTE-IDENTICAL too and its head count is unmoved.
* the rest are `MiniAmiq` / `SeqDriver` / `Scoreboard`, the proven UVM coin
  family — attributed order-blind, with the pristine-alone positive control in
  §7.

`shapes.py` across the whole grid: **0 arms GREW** a shape-differing
`param_assign` key; `a1`/`a7`/`a8` improve nothing shape-wise (their 2
shape-differing keys are R3, below) and no arm regresses.

RESULTS CSVs ARE NOT EDITED BY THIS PASS.  `FuncStructValSimple` is still
recorded as CMP_NOTEQUAL in `results/golden_surelog.csv`; the promotion belongs
to the landing commit.

## 7. Residues, ranked (all pre-existing or newly exposed; none a regression)

* **R1 — a module parameter DEFAULTED to a package localparam of this family.**
  `parameter cfg_t D = p::C` is golden the assembled constant in BOTH the
  `uhdmallModules` (bare decompile) and `uhdmtopModules` (`<w>'b` prefixed)
  views; we re-emit the unfolded `func_call` in both.  Grid `a1`/`a7`/`a8`
  (`work@top.D`, the only two shape-differing keys there) and the corpus row
  `struct_param_func_config`, whose head it is (golden BIN size 66 ct 3 against
  our `func_call`).  Identical on both binaries.
* **R2 — an override actual that is a BARE REFERENCE to a parameter of this
  family.**  `holder #(.H(p::C))` is golden the assembled `1088'b…` BIN ct 3 and
  ours `HEX:…` ct 5 (grid `a1`); `child #(.Cfg(Cfg))` in
  `struct_param_func_config` is golden `66'b…` ct 3 and ours `HEX:1e0000000e`
  ct 5.  The same inheritance § `elabOvRefIntConst` already models for an
  INT-valued localparam, one encoding out.
* **R3 — the `uhdmallModules` import copy's Rhs** (r11v11u9's V1, re-measured
  and STILL OPEN): golden's `work@top.C` import copy is the assembled BIN with a
  BARE decompile; ours is the decimal fold at struct width (`INT:0` on `a1`).
  Identical on both binaries.
* **R4 — the RE-PASS hop.**  Grid `a11`: golden gives the grandchild's
  `.V(W)` the SAME `BIN 4'b1010` the first hop got; with this law the first hop
  is golden-exact and the second still re-folds to `INT:10`.  A bare parameter
  reference one instance down does not inherit the slice encoding.  Newly
  exposed by this pass (the first hop had to be right before the second could be
  seen).
* **R5 — our leftover machinery declines a struct with an UNWRITTEN member.**
  Grid `a2`/`a4`/`a6`: the builder writes 3 of 4 members, golden stamps the
  three it wrote and BAILS the assemble, and every member read then answers out
  of the leftover (INT:2 / UINT:32).  We record no stamp at all for such a
  builder, so the read falls through to the `memBig8` / decimal arms and we
  answer `BIN` where golden answers the leftover encoding.  Identical on both
  binaries, and the reason those three arms cannot test this pass's bail branch
  — `FuncStructVal` is the arm that does.
* **R6 — `asmOk8` over-fires for a PLAIN PATTERN base.**  Grid `a10`: golden
  answers `p::S.B` and `p::G.B` with `UINT:2` ct 9 on a pattern-valued package
  localparam, where we slice `BIN 32'b…010` on both.  Pre-existing, identical on
  both binaries, and deliberately untouched: § `structParamMemberOvBinary`'s
  non-function path is pinned by r11u3's own measured witnesses and is outside
  this law.
* **R7 — the member OF a member.**  Grid `a9` `n3`: golden's `.W(C.N.X)` is
  `BIN 32'b…000` (value 0) where ours is `UINT:5`; both the encoding and the
  value differ, on both binaries.
