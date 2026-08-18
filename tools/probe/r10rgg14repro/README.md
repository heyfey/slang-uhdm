# r10rgg14 — § genvarIdxFoldRerender14: a PORT-CONNECTION bit-select index that reads a GENVAR is folded and its `vpiDecompile` RE-RENDERED from the value

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge.  **BASE `3b318d6`.**  `results/*.csv` was READ ONLY and is
untouched.  **Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS
CONVERTED** — this pass says so up front.

Target: `default:Rggen`'s official head after r10rgg13 (36 cmp lines, 1 head) —
the `bit_select` INDEX constant of `.register_if (register_if[10+i])` at
`rggen-sample/block_0.sv:1748:36`, inside
`for (genvar i = …) begin : g_register_10`:

```
golden : constant  UINT:10  sz 64  ct 9  vpiDecompile "10"     span 1748:36-1748:38
ours   : constant  UINT:10  sz 64  ct 9  vpiDecompile "10+i"   span 1748:36-1748:40
```

**RESULT.  THE HEAD IS CLEARED, and the whole 30-object family with it.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): the head object moves to a
  **DIFFERENT FAMILY** (§ 9, R0) — 36 → 64 cmp lines.  A cmp line count is the
  head OBJECT's decompile size, so that number is **not** a progress metric and
  is not reported as one.  The arbiters are the whole-dump diff and the census.
* **The whole-dump path-normalised diff of Rggen, base vs patched, is 109
  removed / 109 added lines over 1,580,844 dump lines a side — the THIRTY head
  constants' span, `vpiDecompile`, `vpiValue` and `vpiConstType`, and NOTHING
  ELSE** (`DUMPDIFF_rggen_base_vs_pat.txt`).
* **All thirty are now BYTE-IDENTICAL to golden** on every field the dump prints
  (span, decompile, size, value, const type) — checked site by site (§ 5).
* Census of every `bit_select` index constant in the whole Rggen database
  (4,153 keys / 2,523 owner keys, both views + the package view):
  **FIXED 30, BROKEN 0, MOVED-STILL-WRONG 0**; golden-vs-golden calibration
  2,933 / 2,933 OK (`CENSUS_rggen_3way.txt`).
* **The positive-control cell `cells/pc1` goes from 36 cmp lines / 1 head to
  0 cmp lines / 0 heads — it PASSES the official `uhdm-cmp` outright.**
* Corpus: **0 movers over 1,358 uhdm2rtlil databases** (predicted 0 from the
  pristine databases BEFORE the run); **2 movers over 956 surelog databases —
  `default/Rggen` (the target, predicted) and `default/Scoreboard`, which is THE
  DOCUMENTED COIN and is PROVED so here** (`COIN_scoreboard.txt`).
* **0 differing ROWS** in either corpus, either mode, status AND dump column,
  against the committed baselines AND against my own base sweeps.

---

## 1. THE HEAD, decoded from the PRISTINE cmp LOG

`HEAD_R0_BEFORE_default_Rggen.cmp`, verbatim (LHS is ALWAYS golden):

```
LHS: constant, id:89211, line:1748:36, endln:1748:38
     |vpiParent: \_bit_select: (work@rggen.u_block_0.g_register_10.g[0].u_register.register_if)
     |vpiDecompile:10   |vpiSize:64   |UINT:10   |vpiConstType:9
RHS: constant, id:62381, line:1748:36, endln:1748:40
     |vpiParent: \_bit_select: (work@rggen.u_block_0.g_register_10.g[0].u_register.register_if)
     |vpiDecompile:10+i |vpiSize:64   |UINT:10   |vpiConstType:9
```

**THE FAILING FIELD IS `VpiDecompile`, AND NOTHING ELSE.**  Read the order off
the generated code, not off the dump.  `constant::Compare`
(`UHDM/build/generated/src/constant.cpp`) calls `expr::Compare` FIRST
(`expr.cpp:83`), which reads **`VpiDecompile`** (`"10"` vs `"10+i"` → FAIL),
then `VpiSize` (64 == 64), then `SafeCompare(Typespec())`; only after that does
`constant::Compare` read `VpiConstType` (9 == 9 here).  The OWNER is reached
through `bit_select::Compare` → `VpiConstantSelect` → `SafeCompare(VpiIndex())`
(`bit_select.cpp`), which is why the head is reported ON THE CONSTANT.
**`VpiValue` is never read by any generated `Compare`; nor is the SPAN** — both
are used below only as census WITNESSES and as dump-fidelity targets.

**DEF vs ELAB.**  The DEF listing (`uhdmallModules`, lines 1–64,380 of golden's
dump) contains NO object at `block_0.sv:1748` at all, on either side — a
generate-for body's instance port connections exist only in the ELABORATED
copies.  There is therefore no DEF twin of this law and none was written.

## 2. THE FAMILY IS 30 OBJECTS, NOT 1

Multiset diff of every `|vpiDecompile:` line in the two Rggen dumps: golden has
**zero** decompiles carrying a genvar name; ours has exactly six texts:

| text | count | site | golden's ELAB decompiles |
|---|---|---|---|
| `10+i` | 4 | `block_0.sv:1748:36` | `10 11 12 13` |
| `14+4*i+j` | 8 | `block_0.sv:1861:42` | `14 … 21` |
| `2+i` | 2 | `block_1.sv:173:42` | `2 3` |
| `4+i` | 2 | `block_1.sv:225:42` | `4 5` |
| `6+7*i+3*j+k` | 12 | `block_1.sv:280:44` | `6 … 11 13 … 18` |
| `6+7*i+6` | 2 | `block_1.sv:385:40` | `12 19` |

Every one of the 30 is the `vpiIndex` of a `bit_select` that is a port
connection's `vpiHighConn` — `.register_if (register_if[<expr>])` on an
INTERFACE INSTANCE ARRAY.  **Ours emitted the SAME text AND the SAME number in
every unrolling** (`14+4*i+j` → `UINT:14` in all eight copies, `6+7*i+6` →
`UINT:6` in both) because the "value" was the leading integer of the source
text, which is all `vpi_get_value` can recover from `"UINT:6+7*i+6"`.

## 3. THE LAW

> **§ genvarIdxFoldRerender14.**  In the **ELABORATED** view, an instance PORT
> CONNECTION actual that is a bit-select of an array — a net array or an
> INTERFACE INSTANCE array — whose INDEX expression READS A GENVAR collapses to
> ONE `constant` carrying the REDUCTION, not the source text:
>
> * **`VpiDecompile` and `VpiValue` are RE-RENDERED FROM THE FOLDED VALUE**
>   (`std::to_string`), per unrolling;
> * **`VpiSize` = 64**;
> * **`VpiConstType` is the reduction's own type**: `vpiMultOp` / `vpiDivOp` /
>   `vpiSubOp` / `vpiMinusOp` always give `vpiIntConst` (7); `vpiAddOp` gives
>   `vpiIntConst` iff a reduced operand's own type is one of
>   {`vpiIntConst`, `vpiStringConst`, `vpiRealConst`, `vpiDecConst`}, else
>   `vpiUIntConst` (9); shifts and bitwise ops give `vpiUIntConst`;
> * **the SPAN is the expression node's FIRST CHILD** — for a binary operation,
>   its LEFT OPERAND (`14+4*i+j` takes the span of `14+4*i`).
>
> **SURELOG'S MECHANISM** is `ExprEval::reduceExpr`
> (`UHDM/templates/ExprEval.cpp`), read row by row:
> ```
> case vpiAddOp: case vpiPlusOp:                                   // :3159
>   expr0 = reduceExpr(op0); expr1 = reduceExpr(op1);
>   unsignedOperation = true;
>   for (exp : {expr0, expr1})
>     if (exp is constant && ct in {vpiIntConst, vpiStringConst,
>                                   vpiRealConst, vpiDecConst})
>        unsignedOperation = false;                                 // :3167-78
>   if (unsignedOperation) { c->VpiValue("UINT:"+to_string(v0+v1));
>                            c->VpiDecompile(std::to_string(v0+v1));
>                            c->VpiSize(max(sz0,sz1));
>                            c->VpiConstType(vpiUIntConst); }
>   else                   { ... "INT:" ... vpiIntConst; }
> case vpiMultOp:                                                   // :3379
>   c->VpiValue("INT:"+to_string(v0*v1)); c->VpiDecompile(to_string(...));
>   c->VpiSize(64); c->VpiConstType(vpiIntConst);      // ALWAYS SIGNED, sz 64
> case vpiDivOp:                                                    // :3703
>   ... same shape, vpiIntConst
> ```
> **THE DECOMPILE IS ALWAYS `std::to_string(val)` — never source text.**  That
> single fact is the whole law; the const-type rows are what make the 22
> mult-bearing corpus objects land on `vpiIntConst`.  The span comes from the
> `populateCoreMembers(child, child, result)` idiom that re-spans a reduced
> expression on the parse node's FIRST CHILD (the same idiom r10rgg11 and
> r10rgg13 decoded on `CompileExpression.cpp:2856-2910`).
>
> **A GENVAR reduces to `UINT:<n>` / `vpiUIntConst` / size 64** (r10rgg11's
> § genLpPortConnValue11 already had the bare-genvar case), and that is what
> makes `10+i` come out UNSIGNED while `14+4*i+j` comes out SIGNED.
>
> **THE POSITION IS THE AXIS, NOT THE GENVAR.**  Golden does NOT substitute a
> genvar outside a port connection.  Measured on the CORPUS, in the ELABORATED
> view, inside unrolled generate bodies:
> * `rggen_adapter_common.sv:107` — `assign register_if[i].write_data = …`
>   inside `gen_scope (…u_adapter_common.g_request[0])` keeps
>   `bit_select (register_if[i])` with a **`ref_obj` to `i`** as its index, and
>   its `hier_path` NAME keeps the text `register_if[i].write_data` (45 objects
>   in golden, 45 in ours — we already agree);
> * the `rggen_connect_bit_field_if` macro's cont-assigns keep
>   `bit_field_if.value[8 + 16 * k+:8]` with an unfolded `operation` base and a
>   `ref_obj` to `k` (32 objects, equal on both sides);
> * grid `g3` reproduces both on golden outside any macro.
>
> **A PARAMETER IN THE SAME INDEX IS FOLDED TOO** — golden gives `arr[P+i]`
> `UINT:5` sz 64 ct 9 (grid `g1`/`g2` cell `ue`), so the genvar/parameter
> discriminator the brief asked for is **NOT** "genvar folds, parameter stays
> symbolic" at this position.  What differs is the BARE-parameter index
> `arr[P]`: golden gives it the parameter's OWN declaration constant, `VpiSize`
> **32** included (r10rgg11's § genLpPortConnValue11) — a different law with a
> different size, so **this pass ABSTAINS on it** and leaves those cells byte
> for byte as they were (arm `cells/pc2`, residue R-B).
>
> r10rgg12's R-A (`op11[ref(WIDTH), UINT:1]` kept symbolic in a gen-scope RANGE
> BOUND) is untouched and is not contradicted: that is a range bound, not a port
> actual.

## 4. THE GRIDS (all measured on GOLDEN first)

`cells/g1` interface instance array, `cells/g2` net array, `cells/g3` the other
positions; `run` them with `cell14.sh`, score with `idxcen14.py`
(`GOLDEN_SHAPES_grid.txt` carries the full tables).

| index expression | golden ELAB | sz | ct | span | ours BEFORE | ours AFTER |
|---|---|---|---|---|---|---|
| `arr[i]` | `0` / `1` | 64 | 9 | the `i` | `i`, `UINT:0` twice | **golden** |
| `arr[3+i]` | `3` / `4` | 64 | 9 | the `3` | `3+i`, `UINT:3` twice | **golden** |
| `arr[2+4*i]` | `2` / `6` | 64 | **7** | the `2` | `2+4*i`, `UINT:2` | **golden** |
| `arr[i*2+1]` | `1` / `3` | 64 | **7** | the **`i*2`** | `i*2+1`, `UINT:0` | **golden** |
| `arr[2+4*i+6]` | `8` / `12` | 64 | **7** | the **`2+4*i`** | `2+4*i+6`, `UINT:2` | **golden** |
| `arr[1+2*i+j]` | `1 2 3 4` | 64 | **7** | the **`1+2*i`** | `1+2*i+j`, `UINT:1` | **golden** |
| `arr[i+j]` | `0 1 1 2` | 64 | 9 | the `i` | `i+j`, `UINT:0` | **golden** |
| `arr[P+i]` | `5` / `6` | 64 | 9 | the `P` | `P+i`, `UINT:0` | **golden** |
| `arr[P]` | `5` | **32** | 9 | the `P` | `P`, `UINT:0` | **UNCHANGED (abstain)** |
| `arr[7]` | `7` | 64 | 9 | the `7` | equal | **UNCHANGED** |

Scores: **g1 (interface array) 22 DIFF → 2**, **g2 (net array) 12 DIFF → 2**,
**g3 6 DIFF → 4**.  Every remaining cell is a NAMED OTHER FAMILY (§ 9).

The net-array arm (`ExprEmit`'s pre-existing `genvarConnFold`) already folded
the VALUE correctly; g2 shows what it got wrong and this pass fixes: the
`vpiConstType` (12 of 32 cells) and the SPAN.

## 5. THE THIRTY CORPUS OBJECTS, SITE BY SITE

`diff` of golden's and our patched constant fields at each of the six sites
(span / decompile / size / value / const type) — **IDENTICAL at all six**:

```
1748:36  UINT:10..13  sz64 ct9   1861:42  INT:14..21  sz64 ct7
 173:42  UINT:2,3     sz64 ct9    280:44  INT:6..18   sz64 ct7
 225:42  UINT:4,5     sz64 ct9    385:40  INT:12,19   sz64 ct7
```

The UNSIGNED/SIGNED split is exactly the presence of a `*` on the spine, which
is the `vpiAddOp` rule reading the `vpiMultOp` row's `vpiIntConst`.

## 6. THE PREDICTED MOVER SET (from PRISTINE databases, BEFORE byteverify)

`predict14.py` walks the BASE workdir and flags a database when either
(A) our pristine dump has a HighConn `bit_select` index constant whose decompile
is not a plain decimal (the interface raw-text arm — a CERTAIN mover), or
(B) the GOLDEN database stamps `vpiConstType 7` on such a constant where ours
stamps 9 (the mult-bearing net-array arm).  Both sides are pristine.

* **uhdm2rtlil: scanned 1358, predicted 0** (`PREDICT_db_uhdm2rtlil.txt`).
* **surelog: scanned 956, predicted 5** (`PREDICT_db_surelog.txt`) —
  `default/Rggen` (both criteria) plus `PackedArrayHighConn` and `YosysOldOr`
  in both modes on criterion (A) alone.
* Instrument REACH on uhdm2rtlil (`reach14.py`, `REACH_uhdm2rtlil.txt`):
  **28 of the 1358 databases DO carry the object shape, 710 objects in all** —
  none of them raw-text, none of them `ct 7` on golden.  The 0 is a
  measurement, not an instrument that reached nothing.
* Positive control for the instrument: on Rggen it finds **145** such constants,
  **30** raw-text on our side and **22** `ct 7` on golden's — both criteria fire,
  so a 0 elsewhere is a measurement and not a reach failure.
* Measured movers: **uhdm2rtlil 0 / 1358**, **surelog 2 / 956** —
  `default/Rggen` and `default/Scoreboard`.

**THE PREDICTED SET IS A STRICT SUPERSET, and every predicted non-mover is
explained — THIS IS THE FENCE the brief asked for.**  The only CMP_EQUAL rows in
either corpus whose HighConn `bit_select` index decompile is not a plain decimal
carry **BASED LITERALS**, not genvar arithmetic:

```
PackedArrayHighConn   2 such constants, 1 non-decimal:  "1'b0"  ct 3  sz 1
YosysOldOr        18198 such constants, 20 non-decimal: "5'd00" ct 1  sz 5 …
```
Golden keeps that text because **no reduction ever ran there**: the index is
already a constant, so `compileConst` — not `ExprEval::reduceExpr` — produced it,
and `compileConst` keeps the literal's own spelling and its own size.  This
pass abstains on them TWICE over: `srlgIdxHasGenvar14` is false (no genvar), and
the `ExprEmit` arm's pre-existing `isLiteralExpr` guard already excluded them.
`YosysOldOr` is one of the NAMED BYTE-IDENTICAL CANARIES and is measured
byte-identical in both modes (§ 8), which is the fence holding under the judge.

**`default/Scoreboard` is the documented COIN, and this pass PROVES it rather
than asserting it** (`COIN_scoreboard.txt`): six runs of the **BASE** binary on
the identical command line give `e651aa64…` (runs 1, 2, 4) and `e7b0c9b4…`
(runs 3, 5, 6); six runs of the PATCHED binary give the SAME TWO FACES.  The
mover is nondeterminism, not the patch.

## 7. THE BOUNDARY

`boundary14.sh` compiles EVERY source arm (subdirectories included) of the named
precedent repro directories with both binaries and compares byte-wise.

| arms | files | compiled | MOVERS |
|---|---|---|---|
| `r10rgg1…13repro`, `r10rggen6…9repro` | 568 | 521 | **0** |
| `r10earl40…63repro` | 213 | 212 | **0** |
| `r10uvm90…94repro`, `r10buvm1…18repro` | 97 | 96 | **0** |
| **POSITIVE CONTROL** `r10rgg14repro` | 7 | 7 | **4** (`g1 g2 g3 pc1`) |

The positive control proves the gate can SEE: the three grids and `pc1` move,
and `pc2` / `pc4` / `pc5` — the three ABSTAIN clauses — do not.

Which shapes the neighbours own, and why they cannot move:
`genLpPortConnValue11` / `genLpPortConnRead10` own a port actual that IS a bare
parameter name (no bit-select), `genLpPaCallArgCopy13` a call argument inside a
`param_assign` Rhs, rgg8's `constCallFold` a folded user call, rgg9's
`ternFold9` a ternary, earl47/56/58 gen-scope localparam declarations, earl60
package-homed typespecs, uvm92/94 `decompileHelper`'s hier_path bracket TEXT.
None of them is a `bit_select`'s `vpiIndex` inside a `vpiHighConn`, which is the
only object this patch writes.

## 8. THE GATES

| gate | result |
|---|---|
| build both, `-j 2`, md5 after `Built target` | base `44f9087d5a1700a69ea4c0cd6053179c`, patched `794d7741ad65972a59bfd66bb93a68d4` |
| goldens (base / patched) | **23 PASS / 0 FAIL** each |
| goldens with `SLANG_UHDM=/bin/false` | **0 PASS / 23 FAIL** |
| uhdm2rtlil, both modes | **1358 CMP_EQUAL / 100 SLANG_REJECT / 4 SURELOG_FAIL** (= 679/50/2 per mode), base and patched IDENTICAL |
| `ct14rows` u2r base vs patched | **0 differing rows** of 1462 (status AND dump) |
| `tfslice14` u2r testflags vs COMMITTED `results/gate_uhdm2rtlil.csv` | **0 differing rows** of 731 |
| surelog, both modes | 936 CMP_EQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / **20 CMP_NOTEQUAL** / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM — base and patched IDENTICAL |
| `ct14rows` surelog vs COMMITTED `results/golden_surelog.csv` | **0 differing rows** of 1588 |
| `byteverify SELFCHECK=1` | u2r 1358 identical / **0 movers**; surelog 954 identical / **2 movers**, both named and attributed (§ 6) |
| canaries / ctcan2 / canaudit | `ok=52 changed=0`, `ok=58 changed=0`, `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| canary byte pins | `InterfaceModPort` `BlackParrotComplex` `YosysOldOr` byte-identical; `SVSwitch` **4842211c4030**; `YosysVerx` **6ccda350c24a** |
| `rowheads.sh` on the seven named rows, base vs patched | identical everywhere except `Rggen/default` 36 → 64 |

Every `cmds.txt` in both sweeps was audited BY BINARY PATH: 1458/1462 u2r and
1523/1573 surelog carry the intended binary; every file without it has NO
`slang:` line at all (SURELOG_FAIL / NO_DATABASE — slang never ran).

## 9. RESIDUES AND THE NEXT HEAD

**R0 — THE NEW HEAD of `default:Rggen` (64 cmp lines, 1 head).  A DIFFERENT
FAMILY, and one r10rgg13 already named**: a gen-scope `param_assign` Rhs
constant whose `VpiSize` is 64 where golden's is 2.

```
rggen-sv-rtl/rggen_bit_field.sv:5:61, in
work@rggen.u_block_0.g_register_13.g_bit_field_1.u_bit_field
  golden : constant  BIN:0  vpiSize 2   ct 3  vpiDecompile "'b0"   (spanned 5:61-5:63)
  ours   : constant  BIN:0  vpiSize 64  ct 3  vpiDecompile "'b0"   (NO SPAN AT ALL)
```
`expr::Compare` passes `VpiDecompile` (`'b0` == `'b0`) and fails on **`VpiSize`**
(2 vs 64) — the width of an unbased-unsized `'b0` written as a parameter
override default, taken from the FORMAL's declared width in golden.  This is
r10rgg13's R-B item 3 ("1 `BIN:0` whose size is 64 where golden's is 2"),
promoted to R0 by this pass.

**R-A — still the biggest Rggen family, 810 census rows, untouched.**  Golden's
ELAB view keeps `op11[ref(WIDTH), UINT:1]` in gen-scope interface variable RANGE
BOUNDS where we fold to `const INT:<n>`.  Re-checked against this pass's grids:
it is a RANGE BOUND, not a port actual, and grid `g3` confirms golden keeps the
genvar reference outside port connections — the two laws do not touch.

**R-B — the BARE-PARAMETER index, `arr[P]`, deliberately abstained.**  Golden
gives the parameter's OWN declaration constant (`UINT:5` at `vpiSize` **32** for
an `int P`), i.e. r10rgg11's § genLpPortConnValue11 extended to a bit-select
INDEX.  We emit `vpiDecompile "P"` / `UINT:0` / sz 64 in the interface arm and a
bare `ref_obj` in the net arm.  Zero corpus reach today (the predictor found no
u2r or Rggen row of this shape), which is why it was left; `cells/pc2` is the
arm it should be developed on, and it must carry the parameter's OWN size.

**R-C — the 24 `hier_path` port rows, the R0 family's SIBLING, now the largest
untaken piece of this law.**  `block_1.sv:356`'s
`.i_sw_write_enable (register_if[6+7*i+6].value[0+1*l+:1])`:

```
golden : hier_path (register_if[19].value[1+:1])
           elem0 = bit_select (register_if[19]), vpiName "register_if",
                   vpiIndex = constant INT:19 sz64 ct7 @356:54-356:59
           elem1 = indexed_part_select, Base = constant INT:1 sz64 ct7
ours   : hier_path (register_if[6+7*i+6].value[0 + 1 * l+:1])
           elem0 = ref_obj  vpiName "register_if[6+7*i+6]"     <- not a bit_select
           elem1 = indexed_part_select, Base = an UNFOLDED operation tree
```
The SAME law (a port-connection index that reads a genvar folds and re-renders)
applies to a hier_path ELEMENT and to an indexed-part-select BASE, but the fix
is structural — the first element has to become a `bit_select` with a folded
`vpiIndex` — not a constant re-encoding, so it is a separate pass.  It is 48
objects on our side (24 + 24), 24 on golden's.

**R-D — `decompileHelper` SPACING in a kept-symbolic hier_path name.**  Grid
`g3`: golden renders a cont-assign hier_path name as
`sarr[2 + 3 * i].v[1 + 2 * i+:1]` (ExprEval's `prettyPrint` spacing) where we
render the raw source `sarr[2+3*i].v[...]`.  uvm92/94's family; unrelated to the
fold.

**R-E — a gen-scope LOCALPARAM index in a cont_assign IS folded by golden**
(grid `g3`: `arr[LP]` → `INT:4` / `INT:6` at `vpiSize` **32**, the localparam's
own declaration constant) while a GENVAR index in the same position is NOT.
That is the mirror image of the port-actual rule and is a clean next target.

## 10. THE INSTRUMENTS

| file | what it measures |
|---|---|
| `cen14.py` | THE CENSUS: every `bit_select` index constant with its four Compare-relevant fields + the value witness; `--score` is the golden/base/patched three-way over a MULTISET join |
| `idxcen14.py` | the per-cell golden-vs-ours index table used for the grids |
| `predict14.py` | the database-level mover PREDICTION of § 6, with its own positive control |
| `cell14.sh` | the single-cell driver (default mode, Surelog `-parse` + slang `--single-unit`) |
| `boundary14.sh` + `BOUNDARY_*.txt` | the precedent-arm boundary and its positive control |
| `gates14.sh`, `ct14rows.sh`, `tfslice14.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the mandatory gates |
| `cells/` | `pc1` (the law in miniature — it PASSES `uhdm-cmp`), `g1`/`g2`/`g3` (the golden grids), `pc2`/`pc4`/`pc5` (one per ABSTAIN clause, all must NOT move) |

`tfslice14.sh` exists because the committed `results/gate_uhdm2rtlil.csv` is
TESTFLAGS-ONLY and python's `csv.writer` defaults to `\r\n`; it reads both files
with the `csv` module, never by line.

## 11. WHAT THIS PASS DOES **NOT** CLAIM

* Rggen does **not** pass `uhdm-cmp`.  **NO CORPUS ROW WAS CONVERTED** in either
  corpus, in either mode, and `results/*.csv` was never written.
* 36 → 64 cmp lines is **not** a regression and **not** progress: it is the next
  head object's decompile size.  The claims that rest on evidence are the
  109-line whole-dump diff, the 30-FIXED / 0-BROKEN census, the six site-by-site
  identities with golden, the `pc1` cell passing the official judge, and the two
  0-differing-row corpus gates.
* The law is implemented for a PORT-CONNECTION bit-select whose index reads a
  GENVAR, on an arithmetic tree of `+ - * /`, shifts and bitwise ops.  Every
  other node ABSTAINS and the pre-existing bytes are kept (`cells/pc4`).  The
  bare-parameter index (`cells/pc2`), the non-port positions (`cells/pc5`) and
  the DEF view are untouched by construction and measured to be byte-identical.

## 12. HOW TO REPRODUCE

```sh
git worktree add /tmp/wt_r10rgg14 3b318d6 && git apply /tmp/r10rgg14.patch   # in it
cmake -S /tmp/wt_r10rgg14 -B /tmp/r10rgg14_build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build /tmp/r10rgg14_build -j 2
bash tools/probe/r10rgg14repro/cell14.sh <celldir> <binary> [.sfx]
python3 tools/probe/r10rgg14repro/cen14.py <dump> > x.tsv
python3 tools/probe/r10rgg14repro/cen14.py --score g.tsv base.tsv pat.tsv
bash tools/probe/r10rgg14repro/gates14.sh {gold|goldneg|u2r|sl} {base|pat}
bash tools/probe/r10rgg14repro/rowheads.sh <workdir> <outdir> Rggen
```
