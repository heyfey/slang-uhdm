# r10earl78 — § genCaReplWholeFold78

**BASE `b8bf669`.  Earlgrey_0_1, BOTH modes.  The head earl77 named as R0 is
CLEARED — 90 → 36 cmp lines, one head each, and the two AFTER logs are
BYTE-IDENTICAL (ids included).  The new head is decoded in `PREDICT_R0.txt`.**

Pristine binary md5 `33c79971f7e506652e55c89859aa8e25` (byte-identical to the
master's control `pris_33c7` at this BASE — the build reproduces),
patched binary md5 `ed52e2ea05421062350b24865c65d821`.
Golden caches (immutable, read-only): `00d4794526e44dc553f3` (default),
`d7348d2d2fe67abe767b` (testflags).

Production surface: **`src/ModuleEmit.cpp`, +99/−1 lines, ONE file, ONE new
`if (!rhs)` arm** in `emitGenScopes`'s cont_assign loop.  No new helper: the
fold reuses `tryFoldConst` (the module-body twin's own model) and the size rule
reuses earl68's `caLhsAdjustSize68` verbatim.

---

## 1. The head, decoded before any code

```
LHS: constant  id:999647   NO LOCATION AT ALL
     |vpiDecompile:111111111111111111111111111111111111111
     |vpiSize:39   |BIN:<39 ones>   |vpiConstType:3   (vpiBinaryConst)
     |vpiTypespec -> ref_typespec -> int_typespec  (loc-less)
RHS: operation  id:292129  171:24-171:42
     |vpiParent -> cont_assign 171:12-171:42
     |vpiOpType:34            (vpiMultiConcatOp)
     |vpiOperand -> constant 171:25-171:35  UINT:39 sz 32  (TotalWidth, folded)
     |vpiOperand -> operation 171:35-171:41 opType 33
                      |vpiOperand -> constant 1'b1 BIN:1 sz 1
```

`cont_assign::Compare` runs `VpiNetDeclAssign`, `VpiStrength0/1`, then the
**singular** `SafeCompare(lhs->Rhs(), rhs->Rhs(), context)`.  Both operands are
NON-NULL with **different `UhdmType`**, so `BaseClass::Compare`'s type test
fails first and BaseClass.h's `(lhs != nullptr) && (rhs != nullptr)` arm names
**both** sides in full — neither the `<null>` singular arm nor a vector size
mismatch.  Read the MK line, not the shape (RESUME §9).  Golden FOLDS, we do
not: this is an UNDER-fold, so the fix must perform a fold, not adjust an
encoding.

The owner is `prim_ram_2p_async_adv.sv:171`, inside a GENERATE-IF block:

```systemverilog
  localparam int TotalWidth = Width + ParWidth;        // :76  -> 39
  logic [TotalWidth-1:0]   a_wmask_q,  a_wmask_d ;     // :86  MODULE BODY
  ...
  if (EnableParity == 0 && EnableECC) begin : gen_secded     // :160
    assign a_wmask_d = {TotalWidth{1'b1}};                   // :171  <- the head
    assign b_wmask_d = {TotalWidth{1'b1}};                   // :172  <- its twin
```

in `work@top_earlgrey.u_spi_device.u_memory_2p.i_prim_ram_2p_async_adv
.gen_secded`.  **The Lhs is declared in the MODULE BODY, the cont_assign is in
a GEN SCOPE** — that pairing is the whole pass.

---

## 2. Where it comes from, decoded not guessed

**Surelog, three functions, all already in this campaign's decode.**

1. `UhdmWriter::writeCont_assign`
   (`Surelog/src/DesignCompile/UhdmWriter.cpp:2090`) walks
   `netlist->cont_assigns()` **for every instance**, and a GEN SCOPE is an
   instance like any other — that is why the two homes behave alike.  At
   :2120-2165, with a `ref_obj` Lhs and an `operation` Rhs, it clones the
   assign and runs `CompileHelper::reduceExpr` over the WHOLE Rhs, then
   `adjustSize`s the result and stores it back:

   ```cpp
   if (lhs->UhdmType() == uhdmref_obj) {
     UHDM::any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), …);
     if (var) { if (rhs->UhdmType() == uhdmoperation) { … clone_tree …
       any* rhstmp = m_helper.reduceExpr((expr*)rhs, invalidValue, …);
       … if (rhstmp->UhdmType() == uhdmconstant)
             rhstmp = m_helper.adjustSize(tps, …, (constant*)rhstmp, true);
           assign->Rhs((expr*)rhstmp);
   ```

2. `UHDM/templates/ExprEval.cpp:3797`, `case vpiMultiConcatOp` — the PRODUCER.
   It mints ONE constant:

   ```cpp
   int64_t n = get_value(invalidValue, reduceExpr(operands[0], …));
   if (n > 1000) n = 1000;  if (n < 0) n = 0;
   expr *cv = (expr *)(operands[1]);   // reduced if not already a constant
   constant *c = s.MakeConstant();
   int64_t width = cv->VpiSize();
   int32_t consttype = ((constant *)cv)->VpiConstType();
   c->VpiConstType(consttype);
   if (consttype == vpiBinaryConst) {            // ZERO-PAD to width, REPEAT n
     … c->VpiValue("BIN:" + res); c->VpiDecompile(res); }
   else if (HEX / OCT / STRING) { … repeat the RAW string, no padding … }
   else { res |= val << (i*width); … c->VpiConstType(vpiUIntConst); }
   c->VpiSize(static_cast<int32_t>(n * width));  // the NATURAL width
   if (width) {                                  // "Word size"
     int_typespec *ts = s.MakeInt_typespec();
     ts->VpiValue("UINT:" + std::to_string(width));
     ref_typespec *rt = s.MakeRef_typespec();
     rt->Actual_typespec(ts); rt->VpiParent(c); c->Typespec(rt); }
   ```

   For the head: `n = 39`, `cv = 1'b1` (`BIN:1`, width 1, ct 3), so
   `BIN:<39 ones>`, decompile the same bare digits, `VpiSize(39)`, plus a fresh
   loc-less `int_typespec` — **golden's LHS, field for field**.

3. `CompileHelper::adjustSize` (`CompileHelper.cpp:3949`) — the CONSUMER.  Its
   `vpiBinaryConst` arm **REPLACES `ts` with the constant's OWN typespec** when
   it has one, so the multiconcat mint always takes the `uhdmint_typespec`
   branch, whose only effect on a plain positive value is

   ```cpp
   c->VpiSize((orig_size < size) ? orig_size : size);
   ```

   — the size is CLAMPED to the Lhs width and **THE VALUE STRING IS NEVER
   TOUCHED**.  (The `uhdmlogic_typespec` branch, which a plain concat takes,
   DOES truncate the digits — that split is § srlgFoldNaturalWidth, r10oth4,
   and is why a concat and a replication differ.)

**THE ONE THING THAT DIFFERS BETWEEN THE TWO HOMES is the clamp, and it differs
because of `bindVariable`, not because of the fold.**  The scope-walking
overload (`CompileStmt.cpp:3089`) switches on
`function / task / begin / module_inst` ONLY.  A `gen_scope` hits `default:`
and falls through to `bindVariable(component, scope->VpiParent(), …)`, so it
walks past every gen-local declaration and lands on the enclosing
`module_inst` — where it DOES find module-body nets, variables and ports.  That
is earl68's decode, and `caLhsAdjustSize68` (r10earl68, amended by r10v68)
already implements exactly this predicate, returning 64 for "no bind, no
adjust".  It is REUSED here rather than re-derived.

---

## 3. The law

> **§ genCaReplWholeFold78** — the WHOLE Rhs of an ELABORATED **gen-scope**
> `cont_assign` that is a **replication** `{N{elem}}` whose count and element
> both fold to constants reduces to ONE **location-less** `vpiBinaryConst`
> carrying the producer's digits at the NATURAL width `N × width(elem)` and a
> fresh bare `int_typespec`, whose `vpiSize` is then
>
>     size = (natural > 64) ? natural : min(natural, adjust(Lhs))
>
> where `adjust(Lhs)` is `caLhsAdjustSize68` — the width of the Lhs declaration
> `bindVariable` can reach from the gen scope (a MODULE-BODY net/variable/port,
> never a gen-local one, never a select) and 64 when it reaches none.  **The
> digit string is the natural-width one in every case; it is never truncated.**

The `> 64` arm is `ExprEval::get_value` (`ExprEval.cpp:1967`,
`if (expr->VpiSize() > 64) invalidValue = true;`): `adjustSize`'s entire
`if (!invalidValue) { … }` body is then skipped and the producer's constant
survives untouched.

### Measured on golden — the whole ladder (`a2_bind78.sv`, `a3_wide78.sv`)

| Lhs | natural | target | golden `vpiSize` | arm |
|---|---:|---:|---:|---|
| module-body `logic [3:0]` | 6 | 4 | **4** | a2 B1 |
| module-body `logic [9:0]` | 6 | 10 | **6** | a2 B2 |
| module-body `logic [5:0]` | 6 | 6 | 6 | a2 B3 |
| module-body `logic [3:0]`, `{6{2'b10}}` | 12 | 4 | **4** | a2 B4 |
| module **PORT** `logic [3:0]` | 6 | 4 | **4** | a2 B5 |
| module **PORT** `logic [9:0]` | 6 | 10 | 6 | a2 B6 |
| a **part-select** Lhs | 6 | — | **6** (no bind) | a2 B7 |
| **GEN-LOCAL** `logic [3:0]` | 6 | 4 | **6** (no bind) | a2 B8 |
| **GEN-LOCAL** `logic [9:0]` | 6 | 10 | 6 | a2 B9 |
| module-body, **TWO gen scopes** out | 7 | 4 | **4** | a2 B11 |
| module-body `logic [9:0]` | **64** | 10 | **10** | a3 W2 |
| module-body `logic [63:0]` | 64 | 64 | 64 | a3 W3 |
| module-body `logic [9:0]` | **65** | 10 | **65** | a3 W4 |
| module-body `logic [9:0]` | **70** | 10 | **70** | a3 W5 |
| module-body `logic [79:0]` | **70** | 80 | **70** | a3 W6 |
| a `real` Lhs | 6 | 32 | 6 | a3 W7 |
| a bare `var d;` Lhs (no typespec) | 6 | — | 6 | a3 W8 |
| an unpacked-array ELEMENT Lhs | 6 | — | 6 | a3 W9 |
| an IMPLICIT net Lhs | 6 | — | 6 | a3 W10 |
| an **INTERFACE**-body Lhs, interface gen scope | 5 | 2 | **5** (no bind) | a3 W1 |

Two child instances of the same module (`a2` `u0`/`u1`) and two iterations of a
gen-for (`a1` `gen_f[1]`/`gen_f[2]`) fold identically, and a `gen-for` home, a
`gen-if` home and a `gen-if` nested in a `gen-for` all fold — the home shape is
not a feature.  `N` folds from a **localparam**, a **parameter**, an
**expression** (`{(TW+1){1'b1}}`) and a **genvar** alike (`a1` `gf_gv`, which
is § genvarWholeCaRhsFold68's own count position).

### What golden REFUSES, and this law therefore leaves alone

* **An element that is not a constant.**  `{16{signed_mult & imd_val_q_i[33]}}`
  — `ibex_multdiv_fast.sv:174`, a GEN-SCOPE replication **inside Earlgrey**
  that golden keeps as an operation.  This is the law's LIVE CORPUS FENCE, and
  `tryFoldConst` refuses it for free (`tryEval` cannot fold a signal).  It is
  one of only three gen-scope replication cells in the whole 2,314-database
  corpus, and it does not move.
* **X/Z elements** (R2 in `PREDICT_R0.txt`) — golden folds them, but with
  SURELOG'S OWN casing (`1'bx` → `BIN:XXXXX` UPPERCASE, `1'bz` → `BIN:zzzzz`
  lowercase, because the producer repeats the element constant's value
  STRING).  Our unknown path writes lowercase `x`, so folding would land WRONG
  digits; `tryFoldConst` refuses every unknown outside a concat, and those
  cells stay un-folded rather than folding wrong.  ZERO Earlgrey cells.
* **A concat containing a replication**, and a **zero-count replication inside
  a concat** (R3) — a different producer (`vpiConcatOp`, no decompile, no
  typespec).  ZERO Earlgrey cells; the gate stays on `Replication` only.

---

## 4. The code

ONE arm, in `emitGenScopes`'s cont_assign loop (`src/ModuleEmit.cpp`), placed
after the existing genvar / block-localparam / string-param arms and before the
const-call arm.  The whole behavioural change is these fourteen lines (the
other 85 are the decode comment above them):

```cpp
if (!rhs) {
    auto& rr78 = stripImplicitConv(ae.right());
    if (rr78.kind == ExpressionKind::Replication)
        if (auto* fc78 = tryFoldConst(rr78)) {
            if (fc78->UhdmType() == UHDM::uhdmconstant) {
                auto* c78 = (UHDM::constant*)fc78;
                int32_t nat78 = c78->VpiSize();
                int32_t adj78 = caLhsAdjustSize68(ae.left());
                if (nat78 > 0 && nat78 <= 64 && adj78 < nat78)
                    c78->VpiSize(adj78);
                c78->VpiParent(ca);
            }
            rhs = fc78;
        }
}
```

### Why each clause is necessary

**(1) `stripImplicitConv(ae.right())`, and `tryFoldConst(rr78)` on the STRIPPED
expression.**  The module-body twin calls `tryFoldConst(ae.right())` — the Rhs
*including* its implicit conversion to the Lhs type — so
`expr.type->getBitWidth()` is the TARGET width and `srlgNaturalFoldWidth`
models the clamp.  A gen scope must be able to land on the NATURAL width (the
`bindVariable` failure cases above), so the conversion is stripped:
`srlgNaturalFoldWidth` then returns `valid == false` (`&nat == &expr`) and both
the digits and the size land on the producer's own width, which the clamp below
re-decides from the Lhs DECLARATION rather than from slang's assignment type.
Passing the unstripped expression would give B8/B9/W1/W7-W10 the target width
and land them AWAY from golden.

**(2) `kind == ExpressionKind::Replication`, nothing wider.**  A
`Conversion(Replication)` and a `Concatenation` containing one are deliberately
excluded (R2/R3 above): they are different ExprEval producers with different
encodings, and their corpus reach is far larger (`fencescan78.sh` counts 277
gen-scope CAST cells against 6 replication cells).  Widening the gate without
its own census is exactly the mistake earl66's README warns about.

**(3) `nat78 <= 64`.**  Above 64 bits `get_value` bails and adjustSize does
nothing at all, so the clamp must NOT be applied — a3 `W4`/`W5`/`W6` are the
three-cell proof (65 and 70 survive against targets of 10 and 80).

**(4) `caLhsAdjustSize68`, reused verbatim.**  Its predicate — a `NamedValue`
Lhs naming a Net or Variable whose parent scope is a MODULE `InstanceBody`,
with the r10v68 carve-outs for implicit nets, bare `var`, `real`/`shortreal`/
`realtime` — is precisely `bindVariable`'s reach from a gen scope, and it was
already gate-verified by earl68 and corrected by its verifier.  Re-deriving it
here would have duplicated a rule the campaign has already paid for twice.

**(5) `c78->VpiParent(ca)`.**  The constant replaces the operation as the
cont_assign's Rhs; `vpiParent` is read by no generated `Compare`, so this is
exactness, not a judge field.  No `setLoc`: golden's constant is
LOCATION-LESS (the producer never calls `populateCoreMembers`), and
`tryFoldConst` mints without a location.

---

## 5. The census: the family is EXACTLY TWO CELLS, and nothing else moves

`cacen78.cpp` reads a `.uhdm` DIRECTLY (never `uhdm-dump`: Earlgrey's dump is
>1 GB — the earl61-77 rule) and emits ONE line per cont_assign in the DEF
listing and in the ELABORATED tree, tagged `MOD` (module_inst / interface_inst
home) or `GEN` (gen_scope home), keyed by owner chain + span, payload = the
whole-Rhs SHAPE plus the fields a generated `Compare` reads.  **No span rides in
the payload** (earl60's `attrv60.py` lesson).

**Calibration first (RESUME §9): the golden re-read is BYTE-IDENTICAL
(md5 `2d3ae034d9fff9405bd6b2d265e2cfc7` twice) and golden-vs-golden joins to 0
differing cells / 20,582.**

Whole-design cont_assign census, **20,582 cells per mode**, pristine binary:

| cells def / tf | our shape | golden | verdict |
|---:|---|---|---|
| **2 / 2** | `op34(c9:UINT:39:32, op33(c3:BIN:1:1))` | **CONSTANT** `BIN:<39 ones>` sz 39 ct 3 int_ts | **THIS PASS** |
| 1 / 0 | `op67(c5:HEX:3F:6)` (a size CAST) | CONSTANT `UINT:63` sz 8 | R1 — different producer |
| 32 / 32 | `op67(op33(ref:MioPeriphHasSleepMode,…))` | same op, a folded 32-bit BIN operand | a parameter-read family |
| 58 / 29 | `op75(hier_path,…)` | `op75(tagged_pattern,…)` | the pattern family |
| 14 / 16 | assorted MOD cells | — | span / cast families |

**The `op34` slice is TWO cells in each mode and golden folds both; there is no
third gen-scope replication cell anywhere in the design that golden folds.**
The MODULE-BODY twins are already correct on every judge field (`u_dm_top`
:235 `BIN:1111 sz 4`, `u_flash_ctrl` :316 `BIN:111111111 sz 9`, `sram2tlul`
:54) — see R4 in `PREDICT_R0.txt` for the one judge-INVISIBLE field they differ
on, which this pass deliberately does not touch.

### After the patch, 3-way scored (`score78.py`, JUDGE FIELDS ONLY)

```
EARLGREY default  cells=20592  TO-GOLDEN=2  AWAY-GOLDEN=0  MOVED-WRONG=0  STILL-RIGHT=20477  STILL-WRONG=113
EARLGREY testflags cells=20592  TO-GOLDEN=2  AWAY-GOLDEN=0  MOVED-WRONG=0  STILL-RIGHT=20506  STILL-WRONG=84
```

### And the WIDE expression census, every cell at every depth

`tscen78.cpp` (earl68's `tscen68.cpp` unchanged) censuses cont_assign Lhs/Rhs,
port `High_conn`, `param_assign` Rhs and variable declaration expressions at
EVERY operand depth — **162,259 cells (default) / 160,030 (testflags)**.
Pristine → patched, the multiset difference is **6 entries in each mode, all
four of them at the two head cont_assigns**: the two new whole-Rhs constants
appear, and the four operands of the two `op34`s disappear.  Cells matching
golden go **147,346 → 147,348** (default) and **145,852 → 145,854**
(testflags).  **Nothing else in the design changed, anywhere.**

---

## 6. The corpus fence, hunted BEFORE the patched sweep was gated

`replfence78.cpp` + `fencescan78.sh`, run over **all 2,314 pristine databases**
of this pass's own pristine sweep.  Every cell this law can move is a
gen-scope cont_assign whose whole Rhs is a `vpiMultiConcatOp`:

```
DATABASES_SCANNED=2314
GEN_REPL_DATABASES=2          <- Earlgrey_0_1 default + Earlgrey_0_1 testflags
GEN_REPL_CELLS=6              <- 3 per mode
MOD_REPL_CELLS=68             <- the CONTROL population, must not move
GEN_CAST_CELLS=277            <- R1's reach, measured for the next pass
```

The **six** movable-shaped cells, in full:

| database | owner | cell | verdict |
|---|---|---|---|
| Earlgrey_0_1 def+tf | `…i_prim_ram_2p_async_adv.gen_secded` | `ca=171:12` `a_wmask_d` | **FOLDS** |
| Earlgrey_0_1 def+tf | `…i_prim_ram_2p_async_adv.gen_secded` | `ca=172:12` `b_wmask_d` | **FOLDS** |
| Earlgrey_0_1 def+tf | `…multdiv_i.gen_multiv_single_cycle` | `ca=174:12` `accum[33:18]` | **DOES NOT** — element is a signal; golden keeps the operation too |

The 68 `MOD` cells are the negative control the law must not touch:
`sram2tlul` (Earlgrey), `or1200_ic_fsm` (**YosysOldOr**, a protected canary),
33 `lrotc_zero` cells (**YosysRiscv**) and `OneReplicate` (u2r).  All 68 are
byte-identical after the patch.

**PREDICTED MOVER SET, BY NAME, FROM THE PRISTINE DATABASES ALONE:
`Earlgrey_0_1` default + `Earlgrey_0_1` testflags AND NOTHING ELSE.**
Both corpora came back exactly that.

---

## 7. Arms, scored against golden

`score78.py` is a 3-way multiset join (golden / pristine / patched) carrying
**judge fields only**: the census column `tsval=` (the multiconcat producer's
`word size`, written on the `int_typespec`'s `VpiValue`) is DROPPED, because
`int_typespec::Compare`
(`UHDM/build/generated/src/int_typespec.cpp:97`) reads `Cast_to_expr`,
`VpiSigned` and `Ranges`, and through `typespec::Compare` the `VpiName`,
`Typedef_alias` and `Instance` — it never reads `VpiValue`.  Scoring it would
have manufactured 18 phantom `MOVED-WRONG` verdicts on cells that are
byte-equal to golden in every field the judge reads (earl65's lesson).

```
ARM a1_repl78  plain view  cells 58  TO-GOLDEN 18  AWAY 0  MOVED-WRONG 0  STILL-RIGHT 33  STILL-WRONG 7
ARM a1_repl78  elab  view  cells 58  TO-GOLDEN 18  AWAY 0  MOVED-WRONG 0  STILL-RIGHT 33  STILL-WRONG 7
ARM a2_bind78  plain view  cells 22  TO-GOLDEN 20  AWAY 0  MOVED-WRONG 0  STILL-RIGHT  2  STILL-WRONG 0
ARM a2_bind78  elab  view  cells 22  TO-GOLDEN 20  AWAY 0  MOVED-WRONG 0  STILL-RIGHT  2  STILL-WRONG 0
ARM a3_wide78  plain view  cells 11  TO-GOLDEN 11  AWAY 0  MOVED-WRONG 0  STILL-RIGHT  0  STILL-WRONG 0
ARM a3_wide78  elab  view  cells 11  TO-GOLDEN 11  AWAY 0  MOVED-WRONG 0  STILL-RIGHT  0  STILL-WRONG 0
```

**Zero AWAY-GOLDEN and zero MOVED-WRONG in every arm and every view.**  After
the patch **every** cell of `a2_bind78` and `a3_wide78` is byte-identical to
golden — the whole `bindVariable` ladder, the `>64` rule, the interface gen
scope, both child instances and the two-deep gen nest.

`a1_repl78`'s **7 STILL-WRONG** cells are exactly the three shapes §3 names as
refused, in both homes: `gi_x`/`gi_z1` and `mi_x`/`mi_z1` (X/Z, R2),
`gi_cat` (concat-of-replication, R3) and `gi_lp`/`mi_lp` (zero-count
replication in a concat, R3).  **Three of the seven are MODULE-BODY cells that
were already wrong before this pass and are untouched by it.**

`a1_repl78`'s DEF listing is identical to golden's on all 16 cells on BOTH
binaries — this fold is ELAB-only, as `writeCont_assign` says, and
`emitGenScopes` runs only in the elaborated emission.

---

## 8. Gates (all run in this worktree, both binaries frozen at 555)

| gate | result |
|---|---|
| build both, md5 | `33c79971…` pristine (== the master's control at BASE) / `ed52e2ea…` patched |
| `tests/check_goldens.sh` (SLANG_UHDM exported per binary) | **PASS 23 / FAIL 0** on BOTH binaries |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags + default, patched | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL (both modes) |
| `ct8rows` u2r tf vs **committed** `results/gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** |
| `ct8rows` u2r tf + def vs this pass's own pristine sweep | **PASS, 0 differing rows** (status AND dump) |
| `byteverify SELFCHECK=1` u2r (1358 DBs) | **MOVERS 0 / 1358**, selfcheck 1357/1358, PATH_SETS_IDENTICAL |
| surelog `--mode both` (1588 rows, 956 DBs) | status histogram **IDENTICAL** to pristine (471/466 CMP_EQUAL, 10/9 CMP_NOTEQUAL) |
| `ct8rows` surelog vs **committed** `results/golden_surelog.csv` | **PASS, 0 differing rows** (status AND dump, both modes) |
| `ct8rows` surelog vs this pass's own pristine sweep | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` surelog (956 DBs) | **MOVERS 2 / 956** = `Earlgrey_0_1` default + testflags — EXACTLY the predicted set, no order coin |
| Earlgrey both modes | head **CLEARED**, 90 → 36 lines, 1 head each; BEFORE logs identical mod ids, AFTER logs BYTE-identical |
| whole-design cont_assign census, both modes | **2 TO-GOLDEN, 0 AWAY-GOLDEN, 0 MOVED-WRONG** over 20,582 cells |
| whole-design EXPRESSION census (162,259 / 160,030 cells) | 6 multiset entries change, all four at the two head cells; golden-matching cells +2 |
| golden-vs-golden calibration | 0 differing cells / 20,582; golden re-read byte-identical |
| corpus fence scan (2,314 pristine DBs) | ONE database carries a movable cell (Earlgrey, both modes); every one read and named |
| `canaries.sh` surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| `ctcan2.sh` surelog / u2r | PASS / PASS |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected DBs by md5 (both modes) | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME**; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `rowheads.sh` | **only Earlgrey moved** (90 → 36); SeqDriver 47, SimpleUVM 56, Scoreboard 56, MiniAmiq 60, BuildUVMPkg 47, Rggen 0 all unchanged |
| WIDE boundary (3,493 `.sv`, PROCESSED == LISTED, both views, both binaries) | see §8b |
| per-DIRECTORY boundary (1,511 dirs, both views) | see §8b |

`cmds.txt` audited BY BINARY PATH in every arm — patched sweeps: 1523/1573
surelog and 1458/1462 u2r `cmds.txt` name `/tmp/r10earl78_patched.bin` and
**no other slang binary appears anywhere** (the remainder are golden-cache-hit
entries with no slang line); pristine sweeps the same for
`/tmp/r10earl78_pristine.bin`.  `SLANG_UHDM` exported explicitly per binary,
`GOLDEN_DEFER` UNSET, `results/*.csv` never written.  The 2 `rc=-11` rows in
the surelog sweep (`Tnoc` default + testflags, recorded as `SLANG_REJECT
rc=-11`) are present on BOTH binaries — pre-existing, not introduced.  The four
slang-fenced tests were NEVER dispatched: FENCED= (no file under
`tools/probe` matches any of the four names, so the wide list needed no
exclusion — verified, count 0).

---

## 9. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `cacen78.cpp` — **new**: the whole-Rhs cont_assign census.  One line per
  cont_assign, DEF and ELAB, `MOD`/`GEN` home tag, keyed by owner chain +
  span, payload = whole-Rhs shape + the fields `Compare` reads.  Direct
  `.uhdm` reader.
* `cajoin78.py` — **new**: the two-way multiset join and per-shape tally that
  found the family (2 cells) and ranked everything else.
* `replfence78.cpp` / `fencescan78.sh` — **new**: the corpus fence scanner.
  Reports every ELAB cont_assign whose whole Rhs is a `vpiMultiConcatOp`
  (`REPL`) or a `vpiCastOp` (`CASTCAND`, R1's reach), tagged GEN/MOD.
* `score78.py` — the 3-way JUDGE-FIELDS-ONLY scorer (see §7).
* `tscen78.cpp` — the whole-design expression census at every operand depth
  (earl68's `tscen68.cpp` unchanged), and `tsscore78`-style multiset delta.
* `runarm78.sh` — one arm, Surelog + one binary in BOTH views, **rc of every
  producer recorded** (`verify_golden.py` records rc=139 as `SLANG_REJECT`
  wearing a stderr warning — an arm must never hide one).
* `earl78.sh` — one Earlgrey run, one binary, md5 printed, golden from cache.
* `vwide78.sh` / `vdir78.sh` — the recursive and per-directory boundaries; list
  on fd 3, children `</dev/null`, PROCESSED asserted.
* `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`, `byteverify.sh`,
  `rowheads.sh` — the standard battery.
* `a1_repl78.sv` / `a2_bind78.sv` / `a3_wide78.sv` — the arms (§7).
* `HEAD_{BEFORE,AFTER}_{default,testflags}.cmp` — the four verbatim cmp logs.
* `PREDICT_R0.txt` — the next head, decoded, plus the four ranked residues.

---

## 8b. The boundaries — the only gate that sees a corpus-invisible regression

Both run with the two frozen binaries, the file/dir list read on **fd 3**, all
children `</dev/null`, `PROCESSED` asserted against the list length, and the
dumps workdir-normalised before the byte compare (earl60's two regressions were
invisible to both corpora and were convicted ONLY here).

```
WIDE (every .sv under a COPY of tools/probe, ANY depth, both views)
  PROCESSED=3493  (== LISTED 3493)  identical=6686  DIFFERING=12  no_output=288
PER-DIRECTORY (every probe directory holding .sv, compiled as ONE unit)
  PROCESSED=1511  (== LISTED 1511)  identical=2762  DIFFERING=12  no_output=248
```

**FENCED= (empty).**  The wide list was built by excluding, case-insensitively,
every path matching any of the four slang-fenced test names (the names
themselves are not spelled in this artifact; `canaudit.sh` carries them).  The
exclusion matched **0 of the 3,493 paths** — no file anywhere under
`tools/probe` carries one — so the list needed no trimming and none of the four
was dispatched by any driver in this pass (`canaudit.sh`: audited=29
UNCOVERED=0 FENCE-BREACH=0).

**Segfault symmetry.**  Both `.signal` files are exactly balanced —
WIDE `12 rc=139 A` / `12 rc=139 B`, DIR `12 rc=139` split 6 A + 6 B over the
same six units.  Every rc=139 occurs on BOTH binaries: pre-existing, not
introduced.

### WIDE: the 12 differing cells are 6 files × 2 views

| file | verdict |
|---|---|
| `r10earl78repro/a1_repl78.sv`, `a2_bind78.sv`, `a3_wide78.sv` | **this pass's own arms** (§7) |
| `r10earl_repro/pf19.sv` | EARLIER-PASS arm — re-measured against golden: **2 TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG** |
| `r10earl_repro/x.sv` | EARLIER-PASS arm — **1 TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG** |
| `r10v68repro/v1_pos68.sv` | EARLIER-PASS arm — **2 TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG** |

The three earlier arms and the exact cells that moved, scored against their own
Surelog goldens with `dirarm78.sh`/`runarm78.sh` + `score78.py`:

```
pf19.sv  work@m19.gen_body 48:12  assign cq = {p19::QA{1'b1}};
            golden BIN:111  sz 3 int_ts   was op34(UINT:3:32, …)   now = GOLDEN
pf19.sv  work@m19.gen_body 49:12  assign cw = {QB{1'b1}};
            golden BIN:1111 sz 4 int_ts   was op34(UINT:4:32, …)   now = GOLDEN
x.sv     work@xtop.u.gen_norm 22:12  assign r2 = {PW{1'b0}};
            golden BIN:00000 sz 5 int_ts  was op34(ref:PW, …)      now = GOLDEN
v1_pos68 work@v1_pos68.g_p0[1] 35:12  assign r_rep = {4{i[0]}};   (i a GENVAR)
            golden BIN:1111 sz 4 int_ts   was op34(UINT:4:64, …)   now = GOLDEN
v1_pos68 work@v1_pos68.g_p0[2] 35:12  same line, next iteration
            golden BIN:0000 sz 4 int_ts   was op34(UINT:4:64, …)   now = GOLDEN
```

Two of these are worth naming: `pf19.sv`'s `cq` is a **package-QUALIFIED**
count (`{p19::QA{1'b1}}`) and `v1_pos68`'s element is a **bit-select of a
GENVAR** — two origins the arms did not cover and the law handles anyway,
both landing byte-exact on golden.  `pf19.sv` also carries **7 STILL-WRONG**
cells (a gen-scope `W'(i)` cast of a genvar, R1's family) that are wrong on
BOTH binaries and unchanged by this pass; `v1_pos68` carries 39 of the same
kind.

### PER-DIRECTORY: 6 units × 2 views, and FOUR of them are the known COIN

| unit | verdict |
|---|---|
| `r10earl78repro` | this pass's own arms |
| `r10v68repro` | the `v1_pos68.sv` mover above (sorted diff 120/177 lines — a REAL change) |
| `r10uvm75repro`, `r10uvm76repro`, `r10uvm88repro`, `r10v109repro` | **the documented `vpiTaskFunc` list-ORDER coin, not movers** |

Proof, not assertion.  For all four, the ORDER-BLIND (sorted) diff between the
two binaries is **0 lines** while the raw diff is 6-27 lines, and the flip
reproduces **on ONE binary alone**: four consecutive invocations of the
PRISTINE binary over `r10uvm76repro` give four DIFFERENT dump hashes
(`5fa1b0f0…`, `0cec9cbd…`, `c888dafa…`, `03395a21…`) with a sorted diff of 0
against each other every time.  Their cont_assign census shows 0 changed cells.
This is RESUME §9's `vpiTaskFunc` ORDER flip (`\_function: (pkg::cls::f)`
entries permuting inside `|vpiTaskFunc:`), and it is why attribution here is
order-blind.
