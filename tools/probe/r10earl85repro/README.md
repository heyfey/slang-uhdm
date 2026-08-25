# r10earl85 — § `srlgUnsizedBasedShiftBail85` + § `paOvFoldedRangeNoStamp85` + § `elabParamOpLeafValueFold85`

**THE EARLGREY HEAD CLEARED IN BOTH MODES** (`flash_erase_ctrl.sv:41`
`PageAddrMask`, the same object in `default` and `testflags` since r10earl84),
and every other named row's head **byte-identical**.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `d6bb922`, branch `auto5h`.** `results/*.csv` was **READ ONLY** and is
untouched — **NO ROW WAS CONVERTED** (`Earlgrey_0_1` stays `CMP_NOTEQUAL` in
both modes; its head is cleared, the design has more — see `PREDICT_R0.txt`).
slang was **NOT** patched. Production surface: **`src/ExprEmit.cpp`,
`src/ParamEmit.cpp` and `include/UhdmExporter.h` only.**

Kill switch: `R10E85_OFF=1` restores the pre-pass path exactly, in all three
laws. It is the neutral binary the Earlgrey A/B attribution scores against
(Earlgrey is never whole-dump diffed — its dump is >1 GB).

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_Earlgrey_{default,testflags}.cmp` are the verbatim pristine logs
from this pass's own build of `d6bb922`; they reproduce r10earl84's committed
`HEAD_AFTER_*` logs line for line modulo object ids.

```systemverilog
// hw/ip/flash_ctrl/rtl/flash_erase_ctrl.sv:41, in
// top_earlgrey.u_flash_ctrl.u_flash_erase_ctrl
localparam logic[AddrW-1:0] PageAddrMask = ~(('h1 << WordsBitWidth) - 1'b1);
```

| | LHS (golden) | RHS (ours, pristine) |
|---|---|---|
| `vpiOverriden` | *(unset)* | **`1`** |
| `vpiRhs` | `operation` `vpiOpType:4` (`~`) | `constant` `UINT:4294967040` `vpiSize:17` `ct:9` |
| its `vpiTypespec` | `ref_typespec -> logic_typespec 41:14-41:30` | *(on the constant)* |
| its operand, **default** mode | `operation 11` over `operation 22` over `constant 'h1 vpiSize:-1 HEX:1 ct:5` and `constant UINT:8 sz32 ct9 + bare signed int_typespec`, then `constant 1'b1 sz1 BIN:1 ct3` | — |
| its operand, **testflags** mode | `constant INT:255 vpiSize:64 ct:7` | — |

**Which field — read the generated `Compare`, not the shape.**
`param_assign::Compare`
(`~/git-repos/UHDM/build/generated/src/param_assign.cpp:94`) reads, in order,
`VpiConnByName`, **`VpiOverriden`**, `Rhs`, `Lhs`, `Attributes`. So the head
field is **`vpiOverriden`**, decided BEFORE the `Rhs` is ever looked at; the
`Rhs` kind mismatch is a SECOND disagreement on the SAME object, and the
214/144 printed lines are the whole `param_assign` printing, not 214 cells.
Clearing one without the other only exposes the other. A THIRD field waits
behind them: `operation` derives from `expr`, and `expr::Compare`
(`expr.cpp:100`) reads `Typespec` — measured, not assumed (§4, arm `g4`).

**Why the two modes differ.** `Earlgrey_0_1`'s own command line carries
`-elabuhdm` (`sim-icarus/Earlgrey_0_1.sl`), so the testflags golden has run
`UHDM::ElaboratorContext` + `UHDM::UhdmAdjuster` over the same database.
`UhdmAdjuster::leaveOperation` (`templates/UhdmAdjuster.cpp:461`) reduces every
operation into its parent with
`reduceExceptions({vpiAssignmentPatternOp, vpiMultiAssignmentPatternOp,
vpiConcatOp, vpiMultiConcatOp, vpiBitNegOp})` — the outer `~` is EXEMPT, its
operand is not. That is the ONLY difference between the two goldens: the
object ids of the `param_assign`, the `operation` and its `ref_typespec` are
IDENTICAL in the two logs (401986 / 401944 / 401952) and only the operand slot
differs. `uhdm_main.cpp:481-491` already runs the same two passes under
`--elabuhdm`, so **one law gives both modes** — confirmed on arms
`g1`/`g2_earl85`/`g4`, each built twice (plain and `-elabuhdm`).

---

## 2. Question 1 — DECODING SURELOG: when the reducer abstains

`UHDM::ExprEval::reduceExpr`'s **`vpiBitNegOp` arm folds** (`templates/
ExprEval.cpp:3415`): it reads `get_value(operand)`, masks to the operand's
size and mints a `UINT` constant. The unary operators are NOT where the
abstention lives. It lives two levels down, in the **shifts**:

```cpp
case vpiArithLShiftOp: case vpiLShiftOp:            // ExprEval.cpp:3137
  expr *arg0 = reduceExpr(operands[0], invalidValue, inst, pexpr, muteError);
  if (arg0 && arg0->UhdmType() == uhdmconstant)
      if (((constant *)arg0)->VpiSize() == -1) invalidValue = true;
```
(the `vpiArithRShiftOp`/`vpiRShiftOp` arm at `:3050` is identical).
`'h1` is an **UNSIZED BASED literal**, and Surelog gives it `VpiSize() == -1`
— the same size an UNBASED `'0`/`'1`/`'x`/`'z` gets, which is why
§ `unsizedBasedParamRhsSize106` already models that size on our side and why
our DEF listing emits `vpiSize:-1 HEX:1 vpiConstType:5` byte for byte with
golden. The bail then propagates: `vpiSubOp` (`:3343`) guards every branch on
`(invalidValue == false)`, `vpiBitNegOp` opens `if (invalidValue) break;`, and
`CompileExpression.cpp:3648-3655` keeps the ORIGINAL tree —
`if (any *tmp = reduceExpr(...)) { if (!invalidValue) result = tmp; }`.
`DesignElaboration::collectParams_` (`DesignElaboration.cpp:2493-2560`) then
sees an `operation`, calls `instance->setComplexValue(name, expr)` and stores
NO Value; `NetlistElaboration::elab_parameters_` (`NetlistElaboration.cpp:465`)
finds `getValue` invalid, takes `getComplexValue`, re-runs `reduceExpr`, gets
the same abstention and writes the operation into the elaborated
`param_assign`.

**THE GRID that pins it** (`g1_neg85.sv`, one `localparam
logic[AddrW-1:0]` per row, `AddrW`=17, `WordsBitWidth`=8, golden = Surelog):

| cell | initializer | golden ELAB Rhs |
|---|---|---|
| u08 | `'h1 << W` | **operation 22** — rule (1) fires |
| u07 | `('h1 << W) - 1'b1` | **operation 11** — propagates |
| u01 | `~(('h1 << W) - 1'b1)` | **operation 4** — *the head* |
| u09..u13 | `-` `!` `\|` `&` `^` over the same | **operation 1 / 3 / 7 / 5 / 9** |
| u14 | `~('h1 << W)` | **operation 4** |
| u15 / u16 | the same init at `int` / untyped | **operation 4** |
| u02 | `~((32'h1 << W) - 1'b1)` | constant — a **SIZED** left operand folds |
| u06 | `~((1 << W) - 1)` | constant — an unbased DECIMAL is sized |
| u04 | `~('h ff)` | constant — **no shift, no bail** |
| u05 | `~WordsBitWidth` | constant |

u04 is the negative control that keeps the law honest: `get_value` parses a
HEX constant fine, so rule (2) of § `srlgUnbasedReduceBail` (the X/Z
`parseBinary` failure) does NOT extend to this family. Only the SHIFT does.

**`vpiOverriden` for a `param_assign`** is not the override path at all.
`NetlistElaboration::elab_parameters_` writes it three times
(`NetlistElaboration.cpp:327`, `:556`, `:565`): from
`instance->isOverridenParam(paramName)` — false for any localparam — and from
`CompileHelper::isOverloaded(...)` applied to the Rhs and to the **declared
typespec**. `isOverloaded` (`CompileType.cpp:2230-2330`) walks the
ALREADY-COMPILED typespec's RANGE OBJECTS and returns true only when a
surviving `ref_obj`/`parameter` there names a parameter this instance
overrode. **Where the bound has FOLDED, no name survives and no stamp is
made.** Our rule read the DECLARATION SOURCE TEXT instead, so it fired on a
range whose emitted form has no reference left.

---

## 3. Question 2 — THE CENSUS, both corpora

`pacen85.cpp` reads a `.uhdm` **DIRECTLY** (never a whole-dump diff — Earlgrey's
dump is >1 GB; earl61's direct-reader pattern) and enumerates **EVERY**
`param_assign`, not only the unary ones, so a cell moved BY ACCIDENT is still
visible (earl66's lesson). KEY = `SPAN + VIEW + HOME + PNAME (+ INST)`;
PAYLOAD = only fields a generated `Compare` reads, and **no span-derived
field** (earl60/earl69: a span-carrying payload hides a real flip).
`cen85.sh` joins ours against the golden named by each test's OWN `cmds.txt`
(the immutable golden-cache path) as a MULTISET, and `cencount85.py` buckets
every cell.

### The corpus census, PRISTINE (`d6bb922`) vs golden, both corpora

| | uhdm2rtlil (1358 DBs read, 504 hold a `param_assign`) | surelog (956 DBs read, 461 hold one) |
|---|---|---|
| cells joined | 68 714 BOTH-SAME | 45 438 BOTH-SAME |
| **FAMILY-OPKEPT** — golden's ELAB Rhs is an OPERATION, ours a CONSTANT | **0** | **6** |
| **FAMILY-OVSTAMP** — `vpiOverriden` the ONLY disagreement | **0** | **16** |
| other payload disagreement | 6 | 1824 |

Both families are **`Earlgrey_0_1` and nothing else**, once per mode:

* FAMILY-OPKEPT, 3 sites × 2 modes
  * `flash_erase_ctrl.sv:41` `PageAddrMask` — **the head**, `~(('h1 << WordsBitWidth) - 1'b1)`
  * `flash_erase_ctrl.sv:42` `BankAddrMask` — the same shape one operator deeper
  * `prim_flop_2sync.sv:9` `ResetValue` in `u_pwrmgr.i_cdc.i_ast_sync` — **NOT this
    law**: golden's Rhs is an `operation` `vpiOpType:75`
    (`vpiAssignmentPatternOp`) with a `struct_typespec`, an assignment-pattern
    override actual landing on a `bit` formal. Left alone; see R3.
* FAMILY-OVSTAMP, 8 sites × 2 modes, all in the OPPOSITE direction (golden
  stamps, we do not) on wildcard-IMPORTED package parameters materialized into
  a module instance (`flash_ctrl_pkg` / `rstmgr_pkg` spans 7:18 / 11:18 / 12:18
  / 13:18 / 18:18 / 22:18 / 28:18). This law only ever REMOVES a stamp, so it
  cannot touch them; see R1.

The two head cells are FAMILY-OPKEPT and not FAMILY-OVSTAMP because on them
`vpiOverriden` is **not** the only disagreement — the Rhs differs too. That is
the coupling §1 describes.

---

## 4. The laws

### § `srlgUnsizedBasedShiftBail85` (`src/ExprEmit.cpp`)

An **unsized BASED** literal (`'h1`, `'d13`, `'o7`, `'b1010` — a base with no
width) is a Surelog `constant` with `VpiSize() == -1`, exactly like an unbased
`'0`/`'1`/`'x`/`'z`. `ExprEval::reduceExpr`'s SHIFT arms reject a size(-1)
LEFT operand, and the refusal propagates through every enclosing operator, so
golden's elaborated `param_assign` Rhs keeps the whole expression as an
`operation`. Implemented as a strict EXTENSION of § `srlgUnbasedReduceBail`
(r10oth2): the same walk, the same rule (1), one more literal family in the
`unsized` set. Every bail in that model that is NOT rule (1) still asks the
UNBASED question, so the change can only ADD rule-(1) refusals — never remove
a fold, never bail on a shape the model does not cover.

### § `paOvFoldedRangeNoStamp85` (`src/ParamEmit.cpp`)

The `vpiOverriden` stamp follows the EMITTED range, not the declaration text.
When a body-scope WILDCARD IMPORT also declares the name the packed range
reads, § `shadowedImportBoundFold` folds that bound to the package member's
constant on BOTH sides, no `ref_obj` survives, `isOverloaded` finds nothing and
golden leaves `vpiOverriden` unset. Fenced with the existing measured helper
`wildcardPkgParamNamed9`, and only when that package member has a known
integer value (the condition the fold itself requires).

### § `elabParamOpLeafValueFold85` (`src/ExprEmit.cpp`)

Inside an operation the bail kept, the ELABORATED re-compile still answers
every IDENTIFIER from the instance's stored Value, so each `ref_obj` leaf
naming a parameter of the body becomes that parameter's own constant —
value/decompile/constType/size copied from its own elaborated `param_assign`
Rhs, size forced to 64 for an OVERRIDDEN parameter, and a bare
`int_typespec(VpiSigned)` exactly when `CompileHelper::valueRange`'s
three-kind switch captured signedness. Package members are left to the
producers that already own them. The 18-row `g2_leaf85.sv` grid is the
decode.

And the operation itself needs the parameter's declared typespec ref: an
`operation` IS an `expr`, and `expr::Compare` (`expr.cpp:100`) reads
`Typespec`. The existing elab-op stamp refused a PACKED-ARRAY target; it now
accepts one for a bail-kept Rhs.

---

## 5. The grids — unary operators x operand shapes x widths x homes x views

Every arm is built by `arm85.sh` with **Surelog** (golden) and with the TWO
FROZEN binaries, **twice**: plain and `-elabuhdm` / `--elabuhdm`.  Every child
gets `</dev/null` and its rc is recorded.  `score85.py` joins the three
`pacen85` row files as a MULTISET on the key and buckets every cell.

| arm | what it varies | plain | elab |
|---|---|---|---|
| `g1_neg85.sv` | 16 unary/mixed initializers over `('h1<<W)-1'b1`, sized/unsized/decimal operands, `logic[AddrW-1:0]` / `int` / untyped targets | SAME 23 **W2R 11** R2W 0 W2O 0 STILL 2 | identical |
| `g2_leaf85.sv` | 18 leaf-parameter declared types (int / byte / bit[7:0] / logic[7:0] / untyped / signed[7:0] / integer / shortint / longint / $clog2 / OVERRIDDEN / not-overridden / package bare / package qualified / sub-expression / operand position / no-unary / one-operator) | SAME 46 **W2R 18** R2W 0 W2O 0 STILL 0 | identical |
| `g2_earl85.sv` | the head's home shape: package params through a parameterless middle module | SAME 24 **W2R 2** R2W 0 W2O 0 STILL 0 | identical |
| `g3_ov85.sv` | the same over a DERIVED package (`$clog2` localparams off a base package), Earlgrey's real chain | SAME 46 **W2R 2** R2W 0 W2O 0 STILL 0 | identical |
| `g4_shadow85.sv` | the OV half POSITIVE: body wildcard import declaring the same name as the overridden module parameter — reproduces the Earlgrey head EXACTLY (golden OV=0, range folded) | SAME 15 **W2R 1** R2W 0 W2O 0 STILL 4 | identical |
| `g5_noshadow85.sv` | the OV half NEGATIVE CONTROL: same file, package name CHANGED — golden OV=**1**, range keeps the `ref_obj`, and the stamp must SURVIVE | SAME 17 **W2R 1** R2W 0 W2O 0 STILL 2 | identical |
| `g6_parentimp85.sv` | second negative control: the import is in the PARENT only — golden OV=**1** again | SAME 15 **W2R 1** R2W 0 W2O 0 STILL 0 | identical |

**RIGHT->WRONG 0 and WRONG->OTHER 0 in all 14 runs**, 72 cells moved
WRONG->RIGHT.  `g5`/`g6` are the arms that would convict an over-fire of
§ `paOvFoldedRangeNoStamp85`: they differ from `g4` only in whether a
same-named wildcard-imported package parameter exists, golden keeps
`vpiOverriden:1` on both, and so do we.

The STILL-WRONG rows are named residues, not moves (pristine == patched, both
!= golden): `g1` 7:31 / 9:31 are R2 (the unmasked `~` fold value), `g4`/`g5`
1:29 / 1:56 / 2:31 / 2:57 / 1:57 are R1 (the materialized-import OV stamp).
`g1`'s ONLY-GOLDEN 2 / ONLY-OURS 2 is a PRE-EXISTING span residue on
`~('h ff)` (end column 44 vs 45), identical in both binaries.

---

## 6. The gates — all green (`GATES.r10earl85.txt` has the full battery)

Both binaries were FROZEN at immutable paths before any sweep and every
`cmds.txt` was audited BY BINARY PATH:
`pristine acb3029f2f7456c13be41ce88185d4cd`, `patched
3e8c14f93ca128fe962fd1dedebabdde`.

* golden dumps **23 PASS / 0 FAIL**, `/bin/false` **0 / 23** (negative control)
* uhdm2rtlil, testflags vs the committed baseline AND both modes vs this
  pass's own pristine: **0 differing ROWS** (status AND dump column);
  byte movers **0 / 1358**
* surelog, both modes vs the committed baseline AND vs this pass's own
  pristine: **0 differing ROWS / 1588**, status and dump histograms unchanged.
  **NO ROW CONVERTED** — `results/*.csv` untouched.
  byte movers **3 / 956**: the two PREDICTED `Earlgrey_0_1` databases, plus
  `MiniAmiq`/testflags, which is the documented emitter ORDER COIN and is
  attributed rather than assumed (order-blind sorted-dump diff **0 lines**;
  re-run outside the sweep both binaries give the identical database on 3 runs
  each).
* **EARLGREY A/B**: the patched binary with `R10E85_OFF=1` reproduces the
  PRISTINE database byte for byte in BOTH modes, so 100 % of each mover's byte
  delta is this law.
* canaries `ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS/PASS; `canaudit` PASS;
  `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` byte-identical,
  `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` pins matched.

### The corpus re-score, fixed universe

| | before | after |
|---|---|---|
| BOTH-SAME | 45 438 | **45 442** |
| FAMILY-OPKEPT | 6 | **2** (both `ResetValue`, R3) |
| FAMILY-OVSTAMP | 16 | 16 (R1) |
| OTHER-DIFF | 1824 | 1824 |
| ONLY-GOLDEN / ONLY-OURS | 8898 / 9628 | 8898 / 9628 |

Per-cell 3-way: **WRONG->RIGHT 4, RIGHT->WRONG 0, WRONG->OTHER 0.**
MOVED-WRONG 0 / AWAY 0.

## 7. The wide boundary — it is the gate that convicts what the corpus cannot

`vwide85.sh` over a COPY of `tools/probe` at ANY depth, both views, both frozen
binaries, workdir-normalised dump byte-compare; the file list is read on **fd
3**, children get `</dev/null`, and **PROCESSED is asserted equal to LISTED**.

```
PROCESSED=3813 (== LISTED)  identical=7314  DIFFERING=18  no_output=294
rc histogram: rc=0 14066   rc=3 560   rc=4 598   rc=139 28
```

All 18 are accounted for, and two of them are NOT this pass's own arms:

* **14** — this pass's seven arms x two views (the law's cells).
* **2** — `r10v84repro/v7_more84.sv`, another pass's verifier arm, which
  happens to carry `localparam int Op = ~(('h1 << 3) - 1'b1) & 32'h7`. Scored
  against GOLDEN it is **WRONG->RIGHT 1, RIGHT->WRONG 0**: golden keeps
  `operation 28` (`vpiBitAndOp`) over the bail-kept `~`, pristine folded the
  whole thing to `UINT:0`. An independent author's file confirming the law.
* **2** — `r10buvm22repro/g22.sv`, and **NOT this law**: `R10E85_OFF=1`
  reproduces the **PATCHED** hash (`6ea30a425791`), not the pristine one. That
  is exactly earl84's **R5** — a database value derived from an address that
  tracks the binary's code layout — reproduced here from a second binary pair.

The 28 `rc=139` are 14 files x 2 sides, SYMMETRIC under both binaries and
pre-existing (earl82 R6 / earl83 R6 / earl84 R6); a boundary walk that does not
say so reads as if it compared them.

## 8. Residues

Ranked, with corpus cell counts, in `PREDICT_R0.txt`: **R1** the OTHER
direction of the OV stamp (16 corpus cells, and the testflags R0), **R2** the
`~` fold not masked to the declared width, **R3** an assignment-pattern
override actual on a scalar formal (the 2 remaining FAMILY-OPKEPT cells),
**R4** shared-vs-cloned elab operation typespec, **R5** the 28 pre-existing
probe segfaults.

## 9. The files

| file | what it is |
|---|---|
| `pacen85.cpp` | the direct-reader `param_assign` census (build line in its header) |
| `cen85.sh` / `cencount85.py` | the corpus census driver and its classifier |
| `arm85.sh` / `score85.py` | one arm, both views, three databases; the 3-way scorer |
| `g1_neg85.sv` .. `g6_parentimp85.sv` | the grids (§5) |
| `g7_v84cell85.sv` | the r10v84repro cell the wide boundary moved (copy, for the record) |
| `vwide85.sh` | the wide boundary walk |
| `HEAD_BEFORE_*` / `HEAD_AFTER_*` | the verbatim `uhdm-cmp` head logs |
| `CENSUS.before/after.*` | the corpus census, pristine and patched |
| `ARMS.r10earl85.txt` | every arm run verbatim (rc lines included) |
| `GATES.r10earl85.txt` | the full gate battery |
| `PREDICT_R0.txt` | the mover prediction, the new head and the ranked residues |
| `BOUNDARY_WIDE.*` | tally / rc histogram / differing list / signals |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | copies of the shared gate scripts, so this directory runs standalone |
