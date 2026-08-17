# r10rgg1 — § ifaceDotEnumConstFold1 + § enumTernTakenLeafEnc1

The FIRST pass on the `default:Rggen` NE row.  BASE `039295a`.

**Rggen does NOT convert, and this pass says so up front.**  Its official
`uhdm-cmp` head is ladder rung 1, and rung 1 is not a fold-law defect at all —
it is a **Surelog constant-evaluation SIDE EFFECT that mutates the source
literal in place** (§ 1 below, characterized here for the first time in this
campaign).  What this pass does convert is **28 of the row's 98 ladder rungs**
— the two largest families after the head — with the ladder re-measured to
FIXPOINT at **70 rungs** and rung 1 byte-identical before and after.

---

## 1. THE HEAD (R0), CHARACTERIZED — and why it is a WALL, not a fold law

`uhdm-cmp` head, `default:Rggen`, base and patched, byte-identical:

```
LHS golden: constant  line:30:22-30:23  vpiDecompile:0  vpiSize:64  UINT:0   ct=9
RHS ours  : constant  line:30:22-30:23  vpiDecompile:1  vpiSize:64  UINT:1   ct=9
```

Source, `rggen_or_reducer.sv:30`, inside `function automatic bit [N-1:0][15:0]
get_sub_n_list(int n)`:

```systemverilog
      list_index  += 1;          //  <-- col 22 is the `1`
```

Golden's Rhs of that `+=` is **0**.  Ours is the literal, `1`.  Both sides sit
in the DEF view under `assignment vpiOpType:24`, same span, same size, same
const type: the ONLY difference is the value, and golden's value is not in the
source.

### The mechanism (transcribed, not guessed)

`localparam bit [N-1:0][15:0] SUB_N_LIST = get_sub_n_list(N);` makes that
function a CONSTANT-EVALUATED function.  Surelog evaluates it with
`UHDM::ExprEval::evalStmt` → `setValueInInstance`
(`UHDM/templates/ExprEval.cpp:5021`), and that function does this:

```cpp
constant *c = any_cast<constant *>(rhsexp);      // THE Rhs OBJECT ITSELF
if (c == nullptr) { c = s.MakeConstant(); ... }
...
if (opType == vpiAddOp) {
  uint64_t prevVal = get_uvalue(invalidValue, (expr *)prevRhs);   // lhs's value
  uint64_t newVal  = valUI + prevVal;                             // rhs + lhs
  c->VpiValue("UINT:" + std::to_string(newVal));                  // WRITE-BACK
  c->VpiDecompile(std::to_string(newVal));
  c->VpiConstType(vpiUIntConst);
}
```

When the Rhs of a compound assignment already IS a constant, `c` is that very
UHDM object: **the evaluator writes the new variable value back over the
function body's literal**, and the variable's own new value becomes that same
object (`pa->Rhs(c)`), so the NEXT iteration reads the MUTATED literal.  The
literal therefore *doubles* per iteration (`L := L + L`) once the first
iteration has aliased them, across every evaluation of the function in the
design; `uint64` doubling reaches 0 after 65 doublings and 0 is a fixpoint
(`0 + 0 = 0`).  Golden's `0` is that fixpoint.

### Measured, on purpose-built arms against real Surelog (`a1_rgg1.sv`, `b1_rgg1.sv`)

| cell | shape | golden literal AFTER compile |
|---|---|---|
| a1 `a += 1` in a plain function, never const-called | untouched | `1` sz 64 |
| a1 `b += 3 / -= 2 / *= 4` never const-called | untouched | `3 / 2 / 4` |
| a1 `g += 1` in a `while`, never const-called | untouched | `1` |
| a1 `h += 1` in an `initial` | untouched | `1` |
| b1 `i += 1`, function NOT const-called | untouched | `1` sz 64 |
| b1 `j += 1`, function const-called `f(3)` | **MUTATED** | `4` sz 32 |
| b1 `k += 7`, const-called `f(20)` | **MUTATED** | `28` sz 32 |
| b1 `m += 2` in a `for`, const-called `f(3)` | **MUTATED** | `8` sz 32 |
| b1 `s = 9` (PLAIN assign) in a const-called function | value kept, **size 64→32** | `9` sz 32 |

The doubling model predicts every mutated cell (`j`: 0→1→2→4; `k`: 7→14→28;
`m`: 2→4→8) and the plain-assign cell shows the write-back is compound-op-only
(no `opType` arm ⇒ no value change), while its size still moves because the
enclosing `reduceExpr` re-stamps it.

### Why this pass does not ship it

Reproducing the value requires REPLAYING Surelog's whole constant-evaluation
schedule — how many times each const-called function is evaluated over the
elaborated design, with the aliasing feedback between the literal and the
variable — not a syntactic rule.  A wrong emulation would move every corpus
test with a const-called function.  It is named, mechanised and gridded here so
the next pass can attack it with an eval-count model instead of re-deriving it.
**Rggen cannot pass `uhdm-cmp` until it is modelled.**

---

## 2. THE LADDER, clustered (98 rungs, FIXPOINT, committed by r10ladder1)

| rungs | family | mechanism | this pass |
|---|---|---|---|
| 26 | `constant\|VpiType\|KIND:constant>ref_obj` | ALL 26 are the ONE shared object `ref_obj(RGGEN_OKAY)@104:35` — `assign register_if.status = RGGEN_OKAY;` in `rggen_register_common.sv`, compared once per register instance | **FIXED (L1)** |
| 24 | `hier_path\|VpiName\|register_if[#].value[#+:#]` | golden's elab hier_path NAME carries FOLDED indices; ours keeps the genvar expression | open |
| 11 + 2 + 2 + 1 | `constant\|VpiDecompile\|TEXT:#\|#+#*i+#*j+k` etc. | same root: unfolded genvar arithmetic in a bit_select index | open |
| 8 | `constant\|VpiDecompile\|DIGITS-ONLY` | interface `logic_var` declared RANGE bounds (`rggen_register_if.sv:10/17`, `rggen_apb_if.sv:7`) fold to different values | open |
| 6 | `constant\|VpiDecompile\|TEXT:#\|-#` | param_assign fold sign/encoding | open |
| 3 | `<null>\|<lhs-null>\|EXTRA-OURS` | an EXTRA `ref_typespec` under a `func_call` in a param_assign (CASCADE rungs) | open |
| 2 | `constant\|VpiDecompile\|G-EXTRA-PREFIX(#'b#)` | `rggen_adapter_common.sv:128` `DEFAULT_STATUS` localparam: golden `2'b00`, ours `0` | **FIXED (L2)** |
| 2 | `operation\|VpiType\|KIND:operation>constant` | `rggen_or_reducer.sv:66` range bound | open |
| 2 | `constant\|VpiType\|KIND:constant>operation` | elab cont_assign ternary fold (`write_data[0]`, select Lhs) | open (see R3) |
| 2 | `constant\|VpiType\|KIND:constant>func_call` | elab cont_assign CONSTANT-CALL fold (`inside_range = pre_decode(...)`, plain net Lhs) | open |
| 2 | `constant\|VpiSize\|INT:G>O` | `rggen_adapter_common.sv:18` operation operand width | open |
| 1 + 1 + 1 | singletons | | open |

AFTER: **70 rungs, FIXPOINT**.  The two fixed families are at **0**; every other
family's count is UNCHANGED; **no new family appears**; rung 1 is
byte-identical.

---

## 3. THE LAWS

> **§ ifaceDotEnumConstFold1.**  In the ELABORATED view a cont_assign whose Lhs
> is an INTERFACE-MEMBER reference (a `hier_path`) and whose Rhs is a BARE
> ENUM-CONSTANT name re-emits a FRESH cont_assign whose Rhs is a **LOC-LESS
> constant in that enum member's OWN literal form** — `2'b00` → `BIN:00`
> size 2 `vpiBinaryConst`, `4'h6` → `HEX:6` size **4** even onto a 2-bit
> interface member — parented at the fresh cont_assign, with no typespec ref.
>
> MECHANISM, transcribed from Surelog's `UhdmWriter::writeCont_assign`
> (`src/DesignCompile/UhdmWriter.cpp:2244`): the trailing
> `if (simplified == false)` arm `reduceExpr`s EVERY Rhs it has not already
> simplified and, when the reduce yields a **constant**, clones the cont_assign
> and installs it.  `tps` comes from `lhs->Typespec()`, which a `hier_path` Lhs
> never has, so the `adjustSize(tps, …)` on the next line is a NO-OP: the
> constant rides out with the REDUCER's width and encoding, never the
> interface member's.  The carrier is **REDUCIBILITY of the Rhs, not its
> literalness** — which is what the previous reading of this site
> (`ifaceDotFresh`, "only when the RHS is a LITERAL") was missing.

> **§ enumTernTakenLeafEnc1.**  `§ enumConstOvEnc`'s encoding rewrite reaches
> the enum member THROUGH a constant-condition TERNARY's **taken branch**
> (earl49's `§ caOperandScanRead49` reducer rule: the condition folds, then
> exactly ONE branch).  `localparam rggen_status DEFAULT_STATUS = (ERROR_STATUS)
> ? RGGEN_SLAVE_ERROR : RGGEN_OKAY` therefore carries `2'b00` / `BIN:00` /
> `vpiBinaryConst` at the parameter's own width, not the generic `UINT:0` the
> folding arm produced.  A bare reference is depth 0 of the same walk, so the
> original arm is covered unchanged.

## 4. THE GRID — `c1_rgg1.sv`, 13 cells, one read position each, golden = real Surelog

Interface-member Lhs (`vif.<m> = …`) in the ELABORATED view unless noted.

| cell | Rhs | golden | pristine | patched |
|---|---|---|---|---|
| C1 | `L_OKAY` module-local enum const | FRESH, loc-less `2'b00` BIN sz2 ct3 | SHARED ✗ | **✓** |
| C9 | `PK_OKAY` package enum const | FRESH, loc-less `2'b00` BIN sz2 ct3 | SHARED ✗ | **✓** |
| C10 | `PK_H` = `4'h6`, member WIDER than the target | FRESH, loc-less `4'h6` HEX **sz4** ct5 | SHARED ✗ | **✓** |
| C3 | `2'b01` literal | FRESH, def constant at 30:18 | ✓ | ✓ |
| C4 | `n1` net ref | SHARED | ✓ | ✓ |
| C8 | `n1 \| P` net in the operands | SHARED | ✓ | ✓ |
| C12 | `w1` internal net ref | SHARED | ✓ | ✓ |
| C7 | `f_const(2)` constant call | FRESH, loc-less `UINT:2` sz2 | ✓ | ✓ |
| D1 | plain-signal Lhs `w1 = L_ERR` | FRESH, loc-less `2'b10` BIN sz2 | ✓ | ✓ |
| **R1** C2 | `P` param ref | FRESH, REUSES the parameter's own constant object | SHARED ✗ | SHARED ✗ |
| **R2** C11 | `LE_SEL` enum-typed localparam ref | FRESH, REUSES the localparam's fold constant (which itself carries `2'b00` — L2's shape) | SHARED ✗ | SHARED ✗ |
| **R3** C5 | `(BZ) ? L_ERR : L_OKAY` | FRESH, loc-less **`INT:0` sz64 ct7** — the enum form is LOST in a cont_assign ternary fold (contrast L2's param_assign, which KEEPS it) | SHARED ✗ | SHARED ✗ |
| **R4** C6 | `P + 1` | FRESH, loc-less `UINT:2` **sz64** (unadjusted — the null-`tps` proof) | SHARED ✗ | SHARED ✗ |

R1–R4 are the same arm-2 reduce and are **named, not claimed**: each needs its
own Rhs-object policy (reuse-the-param-constant vs fresh-loc-less) and R3
proves the enum encoding does NOT survive a cont_assign ternary, so a single
"fold anything reducible" edit would have been wrong.  The grid's own
`uhdm-cmp` head moved C11 → C5, i.e. off every cell this pass claims.

Also validated on the grid: L2 turned our `LE_SEL` param_assign constant from
`0`/`UINT:0` into `2'b00`/`BIN:00`, matching golden exactly.

## 5. CENSUS — predicted before the build, measured after

Predicted: 26 + 2 rungs, 98 → 70, head unchanged, Earlgrey unchanged.
Measured: 98 → **70** FIXPOINT, head byte-identical, Earlgrey **byte-identical**.

Object census of the Rggen database delta (base → patched dump diff, 1172
lines):

| objects | what |
|---|---|
| 44 | fresh elab `cont_assign` with `hier_path(register_if.status)` Lhs + loc-less `2'b00` Rhs (L1) — golden has exactly **44** at that site, ours now **44** (was 0) |
| 2 | `DEFAULT_STATUS` param_assign constants `0`/`UINT:0`/ct9 → `2'b00`/`BIN:00`/ct3 (L2) — the ONLY removed lines in the whole diff |
| 0 | anything else |

Remaining `2'b00` gap after the pass: golden 60 occurrences, ours 58 — the two
missing ones are **`enum_const` DECLARATION copies** (golden emits the
`rggen_status` enum_const set 6 times, we emit it 4), a pre-existing
typespec-copy-count difference, not a fold.

## 6. REFUTED — the brief's shared-family premise

The census that ordered this pass said Rggen's bulk shares the
`constant|VpiType|KIND:constant>ref_obj` family with Earlgrey (1,330 objects
combined) and asked for the movement to be predicted on both rows.  **The FAM
label is shared; the mechanism is not.**  Measured on Earlgrey's own before
ladder: its 34 rungs in that family are `PTR_WIDTH` (14, `prim_fifo_sync.sv:131`
— inside an `always` block's `assignment`, under a `part_select` under a
`bit_select`), `N` (4, `tlul_socket_1n.sv:215/216`) and
`FwMode{Tx,Rx}Fifo` (16, `spi_device.sv:427-465` — a `bit_select` INDEX inside
a PORT connection).  Not one of them is a cont_assign Rhs, and not one is an
enum constant.  Prediction written before the measurement: *Earlgrey does not
move*.  Measured: `Earlgrey_0_1` `slang.uhdm` **byte-identical**
(`7d55ccc8f53e9b928d6fa87009575b26` both binaries), ladder unchanged.
