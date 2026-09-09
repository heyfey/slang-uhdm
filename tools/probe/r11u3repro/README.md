# r11u3 — a struct-parameter member select folds BINARY at the override site

§ `structParamMemberOvBinary`. Everything here is MEASUREMENT-ONLY; the judge
is `uhdm-cmp` through `scripts/verify_golden.py`.

## 1. The producer change (decoded from the v1.86 → v1.87 bump itself)

Two commits move it, one on each side of the Surelog/UHDM pair:

* UHDM `7817d9f` "ExprEval: assemble struct_var constants; member-select into
  packed constants" (chipsalliance/UHDM#1141, pulled by Surelog `45e9e417c5`)
  taught `ExprEval::hierarchicalSelector` member-NAME selection into a PACKED
  CONSTANT that carries a `struct_typespec`. It slices the member's bits (first
  declared member at the MSBs) and mints

  ```cpp
  c->VpiValue("BIN:" + mbits);
  c->VpiDecompile(mbits);
  c->VpiSize(mbits.size());
  c->VpiConstType(vpiBinaryConst);
  // + the MEMBER's typespec on the constant
  ```

  Only a FULLY-DEFINED slice satisfies the select.

* Surelog `abce474afa` "Guard the 64-bit Value engine against dotted member
  paths and wide values" then took the OLD answer away.
  `ExprBuilder::evalExpr`'s `paHierarchical_identifier` arm used to evaluate
  `CFG.u.sidWidth` by looking up the BASE identifier alone — the whole packed
  struct value came back AS the member's value, through `strtoull` into an
  `LValue`, and that is the plain unsigned integer that used to reach the
  override site. The new `isDottedMemberTail()` guard leaves a dotted path
  INVALID for the 64-bit engine, so the BIN slice above is now the only value
  an override actual of that shape ever sees.

Net effect on the golden: **an instance parameter override whose actual is a
BARE MEMBER SELECT of a struct-typed parameter is a `vpiBinaryConst` of the
MEMBER's width, not a `vpiUIntConst` at the formal's width** — and everything
downstream of that mint is the PRE-EXISTING pipeline
(`CompileHelper::adjustSize` against the formal's typespec), which our
`srlgAdjustSize` already models line for line.

`uhdm-cmp` reads `VpiDecompile` before `VpiSize` before `VpiConstType`
(generated `expr::Compare` then `constant::Compare`; `VpiValue` is NOT
compared), so the head every corpus row wore was the decompile: golden
`1'b1` / `32'b…010` against our `1` / `2`.

## 2. The golden grids (real Surelog v1.87, `[ERROR] : 0` on every arm)

Reproduce any grid with

```bash
cd g2 && ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv dut.sv
~/git-repos/UHDM/build/bin/uhdm-dump slpp_all/surelog.uhdm > g2_gold.dump
python3 ../pacen.py g2_gold.dump | grep 'work@top\.' | sort -u
```

### g2 — (member kind/width) × (formal type), one struct, five members

`GRID.g2.golden.txt` / `.patched.txt` / `.pristine.txt`. Sixteen override cells:

| formal | member | golden |
|---|---|---|
| `int` | `enum logic[1:0]` | BIN `2'b01` sz 2 |
| `int` | `enum int` | BIN `32'b…0101` sz 32 |
| `int` | `logic [3:0]` | INT `-6` sz 32 |
| `int` | `logic [7:0]` | INT `-52` sz 32 |
| `int` | `logic` | INT `-1` sz 32 |
| `logic [3:0]` | `logic [3:0]` | BIN `4'b1010` sz 4 |
| `logic [3:0]` | `enum logic[1:0]` | BIN `2'b01` sz 2 |
| `logic [1:0]` | `logic [3:0]` | BIN `10` — BARE decompile — sz 2 |
| `logic [1:0]` | `enum logic[1:0]` | BIN `2'b01` sz 2 |
| `enum logic[1:0]` | `enum logic[1:0]` | BIN `2'b01` sz 2 |
| `enum int` | `enum int` | BIN `32'b…0101` sz 32 |
| untyped | `logic [3:0]` | BIN `4'b1010` sz 4 |
| untyped | `enum int` | BIN `32'b…0101` sz 32 |
| `bit` | `logic` | BIN `1'b1` sz 1 |
| `logic [31:0]` | `enum int` | BIN `32'b…0101` sz 32 |
| `logic [31:0]` | `logic [7:0]` | BIN `8'b11001100` sz 8 |

Read three ways:

1. **The member's width wins.** The slice is never padded UP to the formal
   (`int` ← a 2-bit enum stays size 2; `logic [31:0]` ← an 8-bit member stays
   size 8). It is truncated DOWN only through `adjustSize`'s logic arm, which
   also drops the `<w>'b` prefix — the one BARE-decompile cell.
2. **The `int` formal's signed arm** is the only place a BIN turns into
   something else: a member whose MSB is set, under a SIGNED predefined `int`,
   becomes `INT:-<twos complement>` at the formal's width. `int unsigned`
   does not (g3), and `bit`/`byte`/`shortint`/`longint` have no arm at all.
3. **NEGATIVE CONTROL, same grid**: `.P(C.m_v4 + 0)` — the same member select
   inside an OPERATION — is `UINT:10` size 32 on BOTH sides. The member select
   must be the WHOLE actual.

### g3 — the member-TYPE axis and the function-computed base

`GRID.g3.*.txt`. Adds `int unsigned` / `int` / `byte` / `shortint` members and
runs every one of them twice: once from a base built by a CONCATENATION
literal (`L`) and once from a base built by a CONSTANT FUNCTION (`F`).

* `int unsigned` formal ← `int unsigned` member is BIN `32'b…10`, NOT `INT:2`;
  `int` formal ← `int` member `-3` is `INT:-3`; `int unsigned` ← `int` `-3`
  stays BIN — the signed arm needs BOTH a signed formal and a set MSB.
* `logic [3:0]` ← a 32-bit member truncates to a BARE `0010`.
* The FUNCTION-built base `F` reads **exactly** like the literal base `L` in
  all five shared cells.

### The BASE-SHAPE FENCE (why g3's `F` is BIN and the corpus's CVA6Cfg is not)

The slice exists only when the base reaches `hierarchicalSelector` AS A
CONSTANT. A function-computed struct arrives as a `struct_var` and is turned
into one by v1.87's `reduceExpr(struct_var)` assembler, which gives up the
moment ANY member is wider than 64 bits or has no width
(`if (tmpInvalid || mw == 0 || mw > 64) return false`, recursing into
struct-valued members). When it gives up, the base stays a `struct_var`, the
selector's OTHER arm answers, and the override takes the MEMBER'S OWN value in
the member's own encoding.

THE CORPUS MEASURES BOTH SIDES:

* `FuncStructVal` — `config_pkg::cva6_cfg_t` carries
  `logic [15:0][63:0] PMPCfgRstVal` (1024 bits). Golden's `work@top.CVA6Cfg`
  elaborated Rhs IS a `struct_var` (uhdm-dump, line 27581), and its
  `.INPUT_WIDTH(CVA6Cfg.INSTR_PER_FETCH)` override is golden `INT:2` size 32.
  That row is CMP_EQUAL in the baseline and stays byte-identical here.
  Without the fence it became CMP_NOTEQUAL — measured, then fenced.
* `g3`'s `F = mk3()` is the same function-computed shape with every member
  inside 64 bits, and golden slices it.

## 3. Instruments

* `pacen.py <dump>` — per-`param_assign` census out of a `uhdm-dump` text:
  instance, Lhs name, and the Rhs constant's `decompile` / `size` / value /
  `constType`. The four fields `uhdm-cmp` reads on a constant, plus the value
  string it does not.
* `heads.sh <workdir/mode> <outdir> <names…>` — runs the OFFICIAL `uhdm-cmp`
  (golden LHS out of that row's own `cmds.txt`, ours RHS) and prints one line
  per test: cmp rc, `grep -c '^LHS:'` head count, cmp line count, first head
  line.
* `arm.sh <workdir/mode> <binary> <outdir> <names…>` — re-runs ONE sweep row
  with a chosen binary (the row's own slang command line, our binary, our
  output path) and judges it with `uhdm-cmp`. This is how every claim below
  was made on BOTH binaries before the sweeps ran.
* `predict.py <workdir/mode> [names…]` — the A-PRIORI MOVER PREDICTOR, from the
  PRISTINE side alone. A test is named iff BOTH halves hold: (a) its SOURCES
  carry a `.FORMAL(BASE.MEMBER)` (or positional `(BASE.MEMBER)`) actual whose
  whole text is the dotted path, and (b) its PRISTINE database has a
  `parameter` whose typespec resolves to a `struct_typespec` and whose name is
  one of those BASEs. Output: `PREDICT.all.txt` (the four sweep arms; the four
  slang-fenced names are masked `<FENCED>`).
  * POSITIVE CONTROLS: `ParameterPassedToSubmoduleOfSubmodule` and
    `ParameterInitializedInTopOf5LevelHierarchy` read `True TargetCfg` — both
    move and both convert.
  * NEGATIVE CONTROLS: `iface_param_2level` (dotted actuals whose base is an
    interface, not a struct parameter) reads `False`; `struct_param_dim`
    (`pt.t` used as an ARRAY DIMENSION, not an override actual) reads
    `False (no dotted actual)` — and neither moves a byte.
  * It deliberately OVER-predicts (it cannot see the base-shape fence or which
    arm already owns a row): fourteen u2r + seven surelog names, of which the
    movers are eight u2r + three surelog. Every mover is inside the prediction;
    the six over-predicted rows were each armed on both binaries and are
    byte-identical (`ImportedDoubleCastedParameter`, `assert_wide_const_cond`,
    `ff_dead_both_branches`, `ff_dead_guarded_reset`, `def_ctx_struct_param`,
    `latch_decoder_partial`, plus `FuncStructVal`, `FuncStructValSimple`,
    `LargeValue2Struct`).
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` — the current-generation canary
  battery, copied verbatim from `tools/probe/r10uvm221repro`.

## 4. The law

`src/ParamEmit.cpp`, inside `emitParameters`' instantiation-override fold —
ONE new encoder feeding the pre-existing adjust model:

1. **`ovEnc8`'s member-select arm** (opt-in through `memSelArm8`, so the ONLY
   caller that sees it is the override site): a bare `MemberAccess` whose base
   is a `Parameter` of packed-struct type, whose own type is integral and
   1…64 bits wide, and whose struct type passes the BASE-SHAPE FENCE
   (`asmOk8`: every member, recursively, 1…64 bits) encodes as
   `SrlgOvEnc{ct=vpiBinaryConst, dg=<mw bits MSB-first>, size=mw}` rendered by
   `srlgOvRender` to `<mw>'b<bits>`. `memSelHit8` records that it fired.
2. **The driver**, right after the existing `ovEnc8` override arm and with the
   same guards plus `overridden`: it runs `ovEnc8` with the arm open, and only
   when the arm actually fired writes `srlgAdjustSize`'s four fields onto the
   constant and sets the block's `srcBaseOv8` flag, so every downstream arm
   keeps its existing `!srcBaseOv8` guard with no edit.
   * It carries NO `tw8 > 0` gate (unlike the arm above it) because an ENUM or
     UNTYPED formal classifies as width 0 — which is exactly where a RE-PASSED
     member select lands — and `srlgAdjustSize` is a no-op at width 0, which
     is the golden answer there.
   * Going through `ovEnc8` rather than reading the actual directly is what
     makes the RE-PASS work: `.P(P)` one level down recurses through
     `ovEnc8`'s NamedValue arm into the overridden parameter's own actual
     (§ `ovHopOverriddenKeepsValue80` passes an overridden hop through
     untouched), so the deep instance takes the same BIN. g1 is that shape and
     converts; without it g1 kept a UINT at the leaf.

The gate is deliberately the BARE member select of a PARAMETER of
PACKED-STRUCT type at an OVERRIDE site. An element select, an operation around
the select, a member of a member, and a non-overridden declaration default all
keep the arms they already have.

## 5. What moved

THE ROWS CONVERT — twelve tests, twenty-four row-modes, all
CMP_NOTEQUAL → CMP_EQUAL:

* uhdm2rtlil, BOTH modes, 733 → **741** equal and 71 → **63** not-equal:
  `ParameterInitializedInSubModuleOfTopOf5LevelHierarchy`,
  `ParameterInitializedInTopOf5LevelHierarchy`,
  `ParameterInitializedInTopOf5LevelHierarchyWithUnusedParamInTheMiddle`,
  `ParameterInitializedInTopOf5LevelHierarchyWithUnusedParamOfDifferentTypeInTheMiddle`,
  `ParameterPassedTo3TimesNestedSubmodule`,
  `ParameterPassedToSubmoduleInGenscopeOfSubmodule`,
  `ParameterPassedToSubmoduleOfSubmodule`,
  `SubmoduleInGenScopeWithGenScopeParametrizedByParameterFromTopModule`.
* surelog, BOTH modes, default 459 → **463** equal / 24 → **20** not-equal and
  testflags 455 → **459** / 22 → **18**: `ComplexParamOverload`,
  `ComplexParamOverload2`, `StructUnsizedVal` — **plus one of the four
  slang-fenced tests**, which the a-priori predictor named by itself and which
  this pass never dispatched, armed or wrote a probe for. Its two row-modes are
  the fourth converting pair in the surelog row diff; the master decides what
  to do with a fenced row that has gone CMP_EQUAL.

The mover set is EXACTLY the prediction: `byteverify.sh` reports **16 / 1608**
on uhdm2rtlil (`MOVERS.u2r.r11u3.txt`) and **12 / 960** on surelog
(`MOVERS.surelog.r11u3.txt`), of which 8 are the four converting tests × 2
modes and 4 are `MiniAmiq` + `SeqDriver` × 2 modes — the UVM family's own
PRISTINE nondeterminism, not this law:

* the order-blind path-normalised dump diff of each is **4 lines** — one `UINT`
  constant and its `vpiDecompile`, the line-number-class signature this family
  has carried since r10;
* POSITIVE CONTROL: three runs of `MiniAmiq`/default with the PRISTINE binary
  alone give three DISTINCT database md5s (`494b4840…`, `d788d8aa…`,
  `094c94ac…`), and three of `SeqDriver`/default likewise (`d37536dd…`,
  `74d42a85…`, `68cc3d64…`);
* neither row's STATUS moved, and `rowheads.sh` reads BYTE-IDENTICAL on the
  pristine and patched sweeps for all seven families
  (`ROWHEADS.r11u3.txt`).

Zero unpredicted movers, zero missed. Full gate log: `GATES.r11u3.txt`.

RESULTS CSVs ARE NOT EDITED BY THIS PASS. The rows this pass CONVERTS are still
recorded as CMP_NOTEQUAL in `results/gate_uhdm2rtlil.csv` and
`results/golden_surelog.csv`; the promotions belong to the landing commit.

## 6. Residues

* **R0 — the base's own value.** g3 still fails whole-design `uhdm-cmp`
  although its sixteen override cells are byte-identical to golden: golden's
  `work@top.L` / `work@top.F` elaborated Rhs is the ASSEMBLED 94-bit packed
  constant, ours is the concatenation operation / an unfolded value. That is
  v1.87's `reduceExpr(struct_var)` + `evalFunc` assembler, the SAME family that
  owns `FuncStructValSimple` (golden a 1088-bit BIN constant, ours a
  `struct_var`) — the next law in this family, and the one that would also
  retire the base-shape fence's other half.
* **R1 — a >64-bit member under a CONSTANT base.** The fence is written as
  "every member 1…64 bits", which is the assembler's rule. A base whose value
  is a plain constant EXPRESSION (no function) with a member wider than 64 bits
  reaches the selector as a constant anyway, so golden would slice it and we
  would not. No corpus witness; no grid cell; ranked, not fixed.
* **R2 — the shared constant object.** Golden emits ONE constant object for the
  leaf's `param_assign` Rhs and the `cont_assign` that reads the parameter; we
  mint two. `uhdm-cmp` never sees it (the `m_visited` short circuit skips the
  second visit), which is why four of the eight converted u2r rows still read
  dump `differ` while the judge reads equal.
* **R3 — the member-select DECLARATION DEFAULT.** `parameter int P =
  Cfg.field` (not an override) is a different arm and was not touched or
  measured here.
