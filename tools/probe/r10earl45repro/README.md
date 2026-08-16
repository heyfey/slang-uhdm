# r10earl45 — § elabPatternFirstRowElemSize45

**THE HEADLINE: the 186-line Earlgrey head is CLEARED and the row ADVANCES to a
new 64-line head in the same file.** The design-wide census, run on the pristine
pair before a line of code was written, said that **exactly TWO of the 50 972
span-matched `operation` objects in Earlgrey diverge on ANY cmp-visible field**,
named both of them, and predicted the patched dump line-for-line. The
measurement: **ADDED 1 shape / 2 instances, REMOVED 0 shapes / 0 instances, in a
4.65-million-line dump**, `MULTISET DISTANCE 308686 -> 308684`, database
`+8 bytes` (NONZERO, so the mover is real).

**The pass's most useful product is TWO MEASURED CORRECTIONS OF ITS OWN LAW,
both caught by instruments inside this pass and both fixed BEFORE landing.**

* **Arm 1** (`c50eb2fc571720750394c754a0dd3dd4`) cleared the head and 17 probe
  cells and still left `m45_one` (`int T [1][3]`, a ONE-ROW table) wrong — the
  block this law lives in carried an `operands->size() > 1` entry gate that a
  one-row table cannot pass. **A law stated over "the FIRST operand" may not
  have a row count in its code gate.** Arm 2 removes it and flips exactly that
  one cell.
* **Arm 2** (`50812f675f0c2ff55c7a2e519eef3d85`) passed gates 1-4 and the whole
  grid — and **GATE 5 reported FIVE movers where the census predicted ONE.**
  `Kmac` and `BlackBePipeInt` moved in both modes with byte-identical dumps.
  Their cause: `stamp45` tested only "is the first operand an `operation`", and
  `Surelog/tests/Kmac/sha3_pkg.sv:20` is `parameter int unsigned KeccakRate [5]
  = '{1344/MsgWidth, ...}` — a ONE-DIMENSIONAL unpacked array whose operands are
  DIVISIONS. **Golden emits no object there at all**, so the stamp was landing
  on an object the law does not describe. `v45_expr.sv` is the probe that says
  so, on four shapes (`/`, `{,}`, mixed, reversed). **Arm 3**
  (`3fa0e6b3e9e5c89252a7fee88c61c4b7`) requires the stamped operand to BE an
  assignment pattern, removes all four stamps, and leaves the Earlgrey database
  **byte-identical to arm 2's**.

**The byte verifier found a defect no grid, no census and no corpus row could
see** — five real byte movers, four of them invisible to `uhdm-dump` and
`uhdm-cmp` alike, detectable only as `+4 bytes per stamp` in the database.

---

## 0. THE LAW

> **§ elabPatternFirstRowElemSize45 — in the ELABORATED module listing
> (`topModules`), the `vpiSize` of a nested unpacked-array assignment-pattern
> operation is stamped BY THE OUTERMOST PATTERN ON ITS OWN FIRST OPERAND. It is
> not a property a nested op can decide about itself.**
>
> * **value** = the bit width of the type left after stripping EVERY UNPACKED
>   dimension: `int`->32, `byte`->8, `logic [11:0]`->12, `logic [3:0][7:0]`->32,
>   a 16-bit packed struct ->16. (Not "32", and not the element type of the
>   outer array, which for `int [5][5]` would be `int [5]` = 160 bits.)
> * **placement, ASCENDING outer range** = the FIRST operand ONLY — whatever the
>   row count (`a45o_asc3`: rows 1 and 2 carry nothing) and whatever the nesting
>   depth below it (`g45_four`: the four depth-2 ops carry nothing).
> * **placement, DESCENDING outer range** = the operand list is REVERSED, and
>   BOTH ENDS carry the stamp: the STORED-first row and the SOURCE-first row
>   (`b45o_desc3`, `c45o_desc4`: the two ends, never a middle). In code this is
>   `front()`, plus `back()` when `VpiReordered()` is set.
> * **the stamped operand must ITSELF BE AN ASSIGNMENT PATTERN.** "The first
>   operand is an operation" is a DIFFERENT and WRONG predicate: a 1-D unpacked
>   array whose elements are EXPRESSIONS (`int T [5] = '{1344/64, ...}`) has
>   arithmetic operations as operands, and golden emits **no object at all**
>   there — it folds them (`v45_expr` A, C, D, E).
> * **NOTHING ELSE is stamped**: not the outermost op, not a 1-D array whose
>   operands are constants (`h45o_flat`), not the DEF listing (`allModules`,
>   golden carries no size there and we already matched), not the PACKAGE
>   listing (`topPackages`, § pkgVecPatternNoSize), not a variable initializer
>   (`o45_var`), not a CONT-ASSIGN Rhs (`l45o_ca`, and Earlgrey's own
>   `top_earlgrey.sv:64:23`), and not a function argument (`m45o_arg`).
>
> **The row count is NOT in the gate.** A one-row table (`m45_one`,
> `int T [1][3]`) is stamped exactly as the first row of a five-row one.

### THE FIELD THAT ACTUALLY FAILS — stated, because the brief asked

`uhdm-cmp` compares an `operation` through three generated bodies, and I read
all three rather than inferring from the dump:

| body | fields compared |
|---|---|
| `BaseClass::Compare` (`build/generated/src/BaseClass.cpp`) | `VpiType`, `VpiName`, `VpiDefName` |
| `expr::Compare` (`build/generated/src/expr.cpp`) | `VpiDecompile`, **`VpiSize`**, `Typespec` |
| `operation::Compare` (`build/generated/src/operation.cpp`) | `VpiOpType`, `VpiReordered`, `VpiFlattened`, `VpiOpStrong`, `Operands`, `Attributes` |

**A brace-counting `awk` that extracts the BODY of every function matching
`::Compare(const BaseClass` in `~/git-repos/UHDM/build/generated/src/*.cpp` —
232 of them, `BaseClass::Compare` included — reports ZERO bodies containing
`VpiParent`.** So of the two axes the
brief named, **only `vpiSize` is cmp-load-bearing**; the shared-constant
re-parenting at `52:10`..`52:31` is **dump display only**, and this pass
deliberately does not chase it (§ 6 R-4 decodes it anyway, because it is the
mechanism that explains the whole cell).

### STATED GATE == CODE GATE

| § | file, site | the gate, verbatim |
|---|---|---|
| `elabPatternFirstRowElemSize45` | `src/ExprEmit.cpp`, `emitExpr`, `case ExpressionKind::SimpleAssignmentPattern`, inside the existing `if (inParamInit && !paramInitDef && ...)` / `if (isUnpackedArr)` block | `if (!wasInPattern && !paramInitPkg && leaf->isIntegral() && !operands->empty())` then `stamp45(operands->front())` and `if (op->VpiReordered()) stamp45(operands->back())` |
| (the stamp itself, arm 3) | the `stamp45` lambda | `if (o45 && o45->UhdmType() == UHDM::uhdmoperation && ((UHDM::operation*)o45)->VpiOpType() == vpiAssignmentPatternOp) ((UHDM::expr*)o45)->VpiSize(lw45);` — `lw45 = (int32_t)leaf->getBitWidth()` |
| (the row count, arm 2) | same function, the block's entry condition | `(operands->size() > 1 \|\| nestedOpsPre9)` — was `(operands->size() > 1 \|\| (nestedOpsPre9 && !isUnpackedArr))` |

`leaf` is the existing local: `elemT` with every `FixedSizeUnpackedArrayType`
peeled off. `!wasInPattern` is "this op IS the outermost pattern".
`inParamInit && !paramInitDef` is the pre-existing enclosing gate and is what
keeps the law out of cont-assigns, function arguments and the def listing.

`git diff --stat` reads **`1 file changed, 67 insertions(+), 13 deletions(-)`**
in ONE file: the deleted lines are the refuted rule, its comment, and the
`operands->size() > 1` half of the entry condition; `elemIsArray`, whose only
use was the refuted rule, is deleted with it. No new member, no new helper, no
call-site change anywhere else.

Four deliberate choices, each measured rather than reasoned:

* **The stamp is applied BY THE PARENT, not by the child.** A nested op cannot
  see its own operand index, and the index is the whole discriminator: in
  `a45_keccak` five sibling ops with identical shape, identical type and
  identical element kind differ ONLY in position, and golden stamps one.
* **`front()`/`back()` are read AFTER the reverse**, and the second stamp is
  gated on `op->VpiReordered()` — the flag the reverse itself sets — not on
  `descUnpacked` recomputed. Same value today; the flag is the fact.
* **`!paramInitPkg`** is in the gate because golden stamps NOTHING in a package
  listing (`n45_pkg`, both rows `sz=None` on both sides) while it stamps the
  importing module's own copy (`n45_use`, `sz=32`). Without it the law would
  have over-fired into § pkgVecPatternNoSize's territory.
* **The stamped operand is tested for `vpiAssignmentPatternOp`, not for "is an
  operation".** The looser test cost 4 stamps on 2 corpus tests and was found by
  GATE 5, not by the grid — the cells it fires on are ones where golden has NO
  OBJECT, so no MATCH/DIFFER verdict anywhere changes and only the database
  bytes move. § 4.3 has the counterfactual.

---

## 1. THE CENSUS, BOTH SIDES, DESIGN-WIDE, SPAN-KEYED, BEFORE ANY CODE

`census45.py` is not `census44.py`: pass 44 keyed PORT `vpiHighConn` actuals,
which cannot see an operation inside a localparam's pattern at all. This census
keys **every `operation` object in the design** on
`(section, scope path, span, ordinal)` and compares `vpiOpType`, `vpiSize` and
`vpiReordered`, additionally keyed on **PATTERN NESTING DEPTH** (the number of
enclosing op75 frames) — because depth is what the refuted rule turned on.

> **A PARSER DEFECT FOUND AND FIXED BEFORE THE FIRST NUMBER WAS QUOTED.** The
> first `census45.py` closed the object stack at `ind + 1` on a field line. A
> dump field sits at the SAME indent as its owner's CHILDREN, so `ind + 1` left
> the previous sibling on the stack and filed `|vpiOpType:75` on the preceding
> `ref_typespec`: every nested pattern op then reported `depth=0`. The
> divergence count was right by luck; the structure was wrong. Fixed to
> `close_to(ind)` (which is what `census44.py` always did), re-run, and only
> then quoted.

```
Q1  operation objects, PRISTINE (d8055b92)     golden 51646   ours 51473
Q2  SPAN-KEYED JOIN  common 50972   golden-only 674   ours-only 501
      44 of the 45 (opType, gSize, oSize) rows are ON THE DIAGONAL, including
        75  None  None   558      <- every OTHER assignment pattern in Earlgrey
        28  32    32       9      32  2  2       9   (sizes that already agree)
      the ONE row that differs:
        75  32    None     2  <<<
Q3  op75 cells by (depth, gSize, oSize)
      depth=0  None  None   533
      depth=1  None  None    25
      depth=1  32    None     2  <<<
Q5  DIVERGENT operations of ANY opType, ANY field:  2   (both `SIZE(32->None)`)
```

**In the whole of Earlgrey — 51 646 operations, 4.8 million dump lines — exactly
TWO operation objects diverge on any field `uhdm-cmp` reads, and both are the
head's family:**

```
topModules  work@prim_keccak  52:5-52:32    depth=1 idx=0  g=32 o=None
topModules  work@prim_keccak  193:5-193:32  depth=1 idx=0  g=32 o=None
```

They are the FIRST ROW of `prim_keccak.sv`'s two `int [5][5]` tables
(`RhoOffset` at 50:14 and `PiRotate` at 191:14). Rows 2-5 of each table
(`53:5`..`56:5`, `194:5`..`197:5`) carry NO size on EITHER side — which is why
"every nested row is sized" was never a candidate.

### THE OVER-FIRE QUESTION, ASKED OF THE DESIGN BEFORE THE EDIT

The dump-side proxy for the new law is *"a depth-1 op75 at operand index 0 of a
depth-0 op75, in `topModules`"*. Design-wide that population is **THREE**, on
BOTH sides:

```
work@prim_keccak    52:5-52:32     g=32    o=None    <- head
work@prim_keccak    193:5-193:32   g=32    o=None    <- twin
work@top_earlgrey   64:23-64:79    g=None  o=None    <- rv_timer.sv:64, a CONT_ASSIGN Rhs
```

The third cell is `assign mtimecmp = '{'{{reg2hw.compare_upper0_0.q,
reg2hw.compare_lower0_0.q}}};` — a **cont-assign**, not a param init, and golden
leaves it UNSIZED. **The CODE gate (`inParamInit && !paramInitDef`) is narrower
than the dump proxy**, so the prediction was 2 movers and not 3, and
`v45_order`'s `l45o_ca` cell was added to the probe to make that claim testable
outside Earlgrey.

### THE PREDICTION, from the pristine artifacts alone

1. exactly **TWO** objects change, in `topModules` only, both in
   `work@prim_keccak`; each gains `|vpiSize:32`;
2. census Q5 (divergent operations, any opType, any field) goes **2 -> 0**;
3. our dump grows by exactly **2** lines: `4655214 -> 4655216`;
4. `msdist`: the exact line `        |vpiSize:32` occurs **1018** times in
   golden and **1016** in ours, so golden-only goes `238460 -> 238458`,
   ours-only stays `70226`, MULTISET DISTANCE `308686 -> 308684`;
5. per-shape multiset: **ADDED shapes=1 instances=2** (`        |vpiSize:32`),
   **REMOVED shapes=0 instances=0**;
6. `work@top_earlgrey 64:23-64:79` does **NOT** move;
7. no `allModules` and no `topPackages` cell moves.

### THE MEASUREMENT, after the edit (`50812f67`)

```
                                       PRISTINE    PATCHED   delta   PREDICTED
census Q5 divergent operation cells            2         0      -2       0
o.dump lines                             4655214   4655216      +2      +2
golden-only line instances                238460    238458      -2  238458
ours-only   line instances                 70226     70226       0   70226
MULTISET DISTANCE                         308686    308684      -2  308684
slang.uhdm bytes                        49940578  49940586      +8   NONZERO
```

`shapes45.sh` (multiset, ADDED and REMOVED **separately**, never a diff
alignment):

```
ADDED        2  [        |vpiSize:32]
ADDED shapes=1 instances=2   REMOVED shapes=0 instances=0   NET=+2
```

**One shape. Two instances. Nothing else moved in 4 655 216 lines.** All seven
predictions land, including the negative one: the three-cell dump proxy produced
two movers, and `work@top_earlgrey 64:23-64:79` reads `size=None` on the patched
binary exactly as golden does.

---

## 2. THE GRID, CELL FOR CELL

`grid45.py` prints, for every operation, **every field a `Compare` body reads**
— `vpiOpType`, `vpiSize`, `vpiDecompile`, `vpiReordered`, `Typespec` presence,
`vpiName` — plus `depth` and the operand index `i`, which are STRUCTURE rather
than fields and are what the law keys on. `vpiParent` is printed and labelled
INERT. A row is MATCH only when every compared field agrees. **LHS is ALWAYS
golden.**

### `a1_earl45.sv` — 17 cells, `topModules` rows (the `allModules` rows are all MATCH on both binaries and are omitted)

| cell | what it is | golden | pristine | arm 1 | arm 2 |
|---|---|---|---|---|---|
| `a45_keccak` 16:5 | **the head reproduced**: `int [5][5]` read through a doubly-nested genvar select | `sz=32` on row 0 only | none ❌ | ✔ | ✔ |
| `a45_keccak` 17:5..20:5 | rows 1-4 of the same table | **no size** | ✔ | ✔ | ✔ |
| `b45_nouse` 34:5 | the same table with **NO use site anywhere** | `sz=32` | ❌ | ✔ | ✔ |
| `c45_two` 45:31 | two rows, no use | `sz=32` (row 0) | ❌ | ✔ | ✔ |
| `d45_userow1` 51:31 | a use that reads a cell of the **LAST** row | `sz=32` on **row 0** | ❌ | ✔ | ✔ |
| `e45_userow0` 57:31 | a use that reads a cell of the **FIRST** row | `sz=32` on row 0 | ❌ | ✔ | ✔ |
| `f45_three` 65:34 | **3 levels**, depth-1 row 0 | `sz=32` | ✔ | ✔ | ✔ |
| `f45_three` 65:51 | **3 levels**, depth-1 row 1 | **no size** | `sz=32` ❌ | ✔ | ✔ |
| `f45_three` 65:36/43/53/60 | the four depth-2 ops | **no size** | ✔ | ✔ | ✔ |
| `g45_four` 72:9 | **4 levels**, depth-1 row 0 | `sz=32` | ✔ | ✔ | ✔ |
| `g45_four` 73:9 | **4 levels**, depth-1 row 1 | **no size** | `sz=32` ❌ | ✔ | ✔ |
| `g45_four` 72:11 / 72:28 / 73:11 / 73:31 | the four **depth-2** ops | **no size** | `sz=32` ❌ ×4 | ✔ | ✔ |
| `h45_byte` 79:32 | element type **`byte`** | **`sz=8`** | none ❌ | ✔ | ✔ |
| `i45_vec12` 84:40 | element type **`logic [11:0]`** | **`sz=12`** | none ❌ | ✔ | ✔ |
| `j45_param` 88:47 | a module **`parameter`**, not a localparam | `sz=32` | ❌ | ✔ | ✔ |
| `k45_desc` 93:35 **and** 93:44 | **DESCENDING** outer range: **BOTH** ends | `sz=32` ×2 | ❌ ×2 | ✔ ✔ | ✔ ✔ |
| `n45_use` 109:31 | a **package** table read from a module | `sz=32` | ❌ | ✔ | ✔ |
| `n45_pkg` 109:31/109:40 | the **package's own** listing (`topPackages`) | **no size** | ✔ | **✔ DID NOT MOVE** | ✔ |
| `o45_var` 118:20/29 | a **variable** initializer | **no size** | ✔ | **✔ DID NOT MOVE** | ✔ |
| `l45_packed` 99:35 | a **packed** 2-D pattern | (no elab op either side) | ✔ | ✔ | ✔ |
| `m45_one` 104:31 | **ONE-ROW** table `int [1][3]` | `sz=32` | none ❌ | **none ❌ (arm 1 MISSES IT)** | **✔** |
| `p45_arrofvec` 124:41 | unpacked `[2]` of packed `logic [3:0][7:0]` | `sz=32`, `reord` unset | ❌ size, ❌ reord | size ✔, reord ❌ | size ✔, **reord ❌ R2** |
| `p45_arrofvec` 125:41 | its row 1 | no size, `reord` unset | size ✔, reord ❌ | ✔/❌ | **reord ❌ R2** |

`a1_earl45` whole grid: **ROWS 136, non-MATCH 20 -> 3 (arm 1) -> 2 (arm 2)**.
The verdict diff pristine->arm1 is **17 one-line changes, all `DIFFER`->`MATCH`,
and NOT ONE regression**; arm1->arm2 is **exactly one line** (`m45_one`).

### `v45_order.sv` — the ORDER / OVER-FIRE probe

| cell | what it is | golden | pristine | patched |
|---|---|---|---|---|
| `a45o_asc3` | 3 rows, **ascending** | row 0 only | ❌ | ✔ |
| `b45o_desc3` | 3 rows, **descending** | the two ENDS (stored `i=0` and `i=2`), **never the middle** | ❌ ×2 | ✔ ✔ |
| `c45o_desc4` | 4 rows, **descending** | the two ENDS (`i=0`, `i=3`), middles bare | ❌ ×2 | ✔ ✔ |
| `d45o_descasc` | outer desc, inner asc | the two ends | ❌ ×2 | ✔ ✔ |
| `e45o_ascdesc` | outer **asc**, inner desc | row 0 only — **the inner direction is not in the rule** | ❌ | ✔ |
| `f45o_top` | the table in an **INSTANTIATED** module | row 0 only | ❌ | ✔ |
| `g45o_struct` | element is a 16-bit **packed struct** | **`sz=16`** | ❌ | ✔ (size) / ❌ ts **R3** |
| `h45o_flat` | **1-D** `int [3]` — no nested op at all | nothing | ✔ | **✔ DID NOT MOVE** |
| `i45o_concat` | nested patterns under a **concat** | (no cell) | ✔ | ✔ |
| `j45o_default` | `'{default:7}` | golden emits **no op** | ❌ | **❌ DID NOT MOVE — R4** |
| `k45o_repl` | `'{2{'{1,2,3}}}` | no size | ✔ | **✔ DID NOT MOVE** |
| `l45o_ca` | **CONT-ASSIGN** Rhs `'{'{{hi,lo}}}` — Earlgrey's third proxy cell | golden emits **no op** | ❌ | **❌ DID NOT MOVE — the `inParamInit` control** |
| `m45o_arg` | pattern as a **function argument** | folded on both sides in elab; MATCH in def | ✔ | **✔ DID NOT MOVE** |

`v45_order` whole grid: **ROWS 77, non-MATCH 14 -> 4**; **10 rows flipped to
MATCH and NOT ONE regressed**, and the four survivors are the four cells this
law explicitly does not claim.

**`h45o_flat`, `k45o_repl`, `l45o_ca`, `m45o_arg`, `o45_var`, `n45_pkg` and
`l45_packed` are the positive controls this pass exists to survive.** Every one
is byte-identical between the pristine and the patched binary.

### `v45_expr.sv` — the OVER-FIRE probe GATE 5 forced into existence

The `topModules` rows, all three binaries. Every cell here is a `DIFFER` on
BOTH sides for a PRE-EXISTING reason — **golden emits no operand object at all,
because it FOLDS the expression** — so the MATCH/DIFFER verdict is blind to the
defect, and only the `sz=` column shows it:

| cell | the pattern | golden | pristine | arm 2 | arm 3 |
|---|---|---|---|---|---|
| `a45x_exprflat` 24:28 | `int T [5] = '{1344/64, ...}` — the Kmac shape | **no object** | `op=12 sz=None` | `op=12` **`sz=32`** ❌ | `op=12 sz=None` ✔ |
| `c45x_concat` 42:36 | `logic [7:0] T [2] = '{{4'h1,4'h2}, ...}` | **no object** | `op=33 sz=None` | `op=33` **`sz=8`** ❌ | `op=33 sz=None` ✔ |
| `d45x_mixed` 48:28 | first element an expression, rest constants | **no object** | `op=12 sz=None` | `op=12` **`sz=32`** ❌ | `op=12 sz=None` ✔ |
| `e45x_descexpr` 55:36 | descending range, the expression lands at `front()` | **no object** | `op=12 sz=None` | `op=12` **`sz=32`** ❌ | `op=12 sz=None` ✔ |
| `f45x_flatconst` | 1-D, all CONSTANTS — the control that already existed and proved nothing | no size | ✔ | ✔ | ✔ |
| `b45x_use` / `b45x_pkg` | the Kmac shape as a PACKAGE parameter, read from a module | no size | ✔ | ✔ | ✔ |
| `g45x_table` 66:31 | the law's OWN shape, in the same file | `sz=32` | ❌ | ✔ | ✔ |

`v45_expr` whole grid (`--all`, every operation, not just op75): **ROWS 71,
non-MATCH 13 -> 12 on all three patched binaries** — the count is IDENTICAL
across arm 2 and arm 3 and the verdict diff between them is **EMPTY**. That is
the point: **this defect is invisible to the verdict, invisible to `uhdm-cmp`,
invisible to the corpus row, and invisible to the dump distance of the tests
that carry it. The only instrument that saw it is the byte verifier.**

---

## 3. THE HEAD

Pristine, **byte-identical to the committed witness
`tools/probe/r10earl44repro/r6_nexthead44.cmp`** — asserted by `diff` BEFORE any
code was written, 186 lines, the only proof that this pass stands on the base
the brief describes:

```
LHS: operation 52:5-52:32  |vpiSize:32  |vpiOpType:75   (5 UINT operands)
RHS: operation 52:5-52:32  (NO vpiSize) |vpiOpType:75   (the same 5 operands)
```

Patched, the row **ADVANCES to a NEW head of 64 lines**, committed here as
`r6_nexthead45.cmp`. It is a DIFFERENT FAMILY — no longer an operation, no
longer a pattern, and no longer in the localparam:

```
LHS: constant 60:31-60:48  |vpiDecompile:0 |vpiSize:32 |INT:0  |vpiConstType:7
RHS: constant 60:31-60:48  |vpiDecompile:0 |vpiSize:32 |UINT:0 |vpiConstType:9
     (work@prim_keccak.gen_rho_x[0].gen_rho_y[0], the folded `localparam int
      Offset = RhoOffset[x][y]%W`)
```

The next defect, stated: **the fold of an `int`-typed gen-scope localparam is
SIGNED on golden (`INT`, `vpiConstType:7` = `vpiIntConst`) and UNSIGNED on ours
(`UINT`, `vpiConstType:9` = `vpiUIntConst`)** — both fields are read by
`constant::Compare`. The `int_typespec` behind it is the same object on both
sides; only the constant's own value tag differs.

---

## 4. THE FIVE GATES

Binary under test **`/tmp/wt_r10earl45/build/slang-uhdm` md5
`3fa0e6b3e9e5c89252a7fee88c61c4b7`** (arm 3, the FINAL binary; every gate below
was re-run on it end to end -- goldens, both corpora, both modes, both byte
verifier halves, every canary -- and the md5 was re-asserted UNCHANGED after the
last gate); PRISTINE `dcf67d7`, built by me in a clean
worktree, **`/tmp/wt_r10earl45pris/build/slang-uhdm` md5
`d8055b9293cceed38956d86d157caf7c`**. Both bases printed and grep-checked
(`git log --oneline -1` = `dcf67d7` in each; the patched tree's `git status`
shows `M src/ExprEmit.cpp` and the probe dir, nothing else; the pristine tree's
is EMPTY). The delivered patch `/tmp/r10earl45.patch` was verified to
`git apply --check` clean in a THIRD throwaway worktree at `dcf67d7`. **Its md5
is reported in the pass's final message and deliberately NOT written here**: the
patch contains this file, so any md5 printed inside it is stale the moment it is
written.

| gate | result |
|---|---|
| 1 BUILD | `~/.local/bin/cmake --build /tmp/wt_r10earl45/build -j 2`, ABSOLUTE path; waited for `Linking CXX executable slang-uhdm` on every one of the three arms; **0** lines matching ` error:` on every one; md5 asserted SEPARATELY afterwards (32 hex each). Final: `ExprEmit.cpp` mtime `18:54:33`, binary mtime `18:55:17` — no gate stands on a stale binary, and every gate below was re-run on the FINAL binary |
| 2 GOLDENS | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` -> `PASS=0 FAIL=23` |
| 3 u2r | `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in BOTH modes and on BOTH binaries; testflags dump `496 match / 183 differ / 52 blank`; `ct8rows.sh` vs committed `results/gate_uhdm2rtlil.csv`: **0 differing ROWS (0 diff row-sides)**; `diff` of the sorted pat/pris CSVs EMPTY in BOTH modes |
| 4 surelog both modes | see § 4.1 |
| 5 BYTE VERIFIER | see § 4.2 |

`GOLDEN_DEFER` was left UNSET throughout (`sweeps45.sh` unsets it explicitly so
an inherited value cannot leak in). `verify_golden.py` SILENTLY DEFAULTS
`SLANG_UHDM`, so every sweep EXPORTED it and the binary each sweep ACTUALLY
invoked was read back out of that sweep's own `cmds.txt`:

```
pat : /tmp/wt_r10earl45/build/slang-uhdm
pris: /tmp/wt_r10earl45pris/build/slang-uhdm
```

### 4.1 GATE 4 — surelog corpus, BOTH modes, ONE INVOCATION PER MODE

Eight sweeps for the arm-2 measurement and four more for arm 3, strictly
sequential, `--jobs 2`, one `verify_golden.py` invocation per (corpus, mode,
binary), so the documented SURELOG_FAIL detail-row race under concurrent sweeps
cannot fire. `sweeps45.sh` is the driver.

```
[default]   794 tests  CMP_EQUAL 469  CMP_NOTEQUAL 11  SURELOG_FAIL 25  DEFERRED 5  -> 469/11 EXPECTED
[testflags] 794 tests  CMP_EQUAL 465  CMP_NOTEQUAL  8  SURELOG_FAIL 23  DEFERRED 5  -> 465/8  EXPECTED
```

`ct8rows.sh` against the committed `results/golden_surelog.csv` (both modes
concatenated, header taken once), FINAL binary:

```
baseline: 1589 lines = 1588 ROWS      fresh: 1589 lines = 1588 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
---- per-mode STATUS histogram (baseline -> fresh)
  default   base/fresh: 469 CMP_EQUAL  11 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
  testflags base/fresh: 465 CMP_EQUAL   8 CMP_NOTEQUAL  5 DEFERRED    3 NO_DATABASE   1 NO_UHDM
                        286 SLANG_REJECT 23 SURELOG_FAIL 1 TIMEOUT    2 UNTRANSLATABLE
---- per-mode DUMP-column histogram (baseline -> fresh)
  default   base/fresh: 325 blank  244 differ  225 match
  testflags base/fresh: 329 blank  300 differ  165 match
PASS: every row byte-identical to the committed baseline
```

Both histograms UNCHANGED, 0 rows moved, and `diff` of the sorted pat/pris CSVs
is **empty** in both corpora and both modes -- the same four sweeps run with the
pristine binary produce byte-identical CSVs. The target's own rows are
byte-identical to the baseline -- **its ROW does not move, its BYTES do**:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
```

### 4.2 GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs PRISTINE

```
uhdm2rtlil : databases patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
             SELFCHECK=1 -> 1357 / 1358 flagged    SELFCHECK1=1 -> 1
```

```
surelog    : databases patched= 953 pristine= 953  PATH_SETS_IDENTICAL  MOVERS: 2 /  953
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=30f3697ed591 pristine=115906084178
  MOVER ./default/Scoreboard-59431470/slang.uhdm    patched=15c2f6dbcf23 pristine=7ec9925c250e
             SELFCHECK=1 ->  952 /  953 flagged    SELFCHECK1=1 -> 3
```

`SELFCHECK1 = 3 = the one corrupted file + the two movers`, and `= 1` on the
uhdm2rtlil half where there is no mover -- exactly what that control's own
message says to expect. Both controls fire on both corpora. The uhdm2rtlil half
covers BOTH modes (679 x 2 = 1358 databases).

**MOVER RULE APPLIED TO EACH MOVER SEPARATELY.**

```
SIZE Earlgrey_0_1/default  patched 49940586  pristine 49940578  ->  +8   NONZERO
SIZE Scoreboard/default    patched 11123420  pristine 11123420  ->   0   PROVES NOTHING
```

* **Earlgrey: +8 B, NONZERO, so by the stated rule the mover is REAL** -- and
  the per-shape multiset in § 1 accounts for it object-for-object: two
  `|vpiSize:32` lines added and nothing else, at 4 bytes per stamp.
* **Scoreboard: size delta ZERO, so it proves nothing and was ARBITRATED, not
  assumed.** Running the SAME test alone, three times per binary:

```
PRISTINE run1 9e81eef41804   run2 9e81eef41804   run3 15c2f6dbcf23
PATCHED  run1 15c2f6dbcf23   run2 c5bff137b702   run3 9e81eef41804     (sweep: 15c2f6dbcf23)
```

**The two distributions OVERLAP IN BOTH DIRECTIONS**: `15c2f6dbcf23` -- the very
hash the sweep flagged as the PATCHED side of the mover -- is produced by the
PRISTINE binary on its third run, and `9e81eef41804`, a pristine hash, is
produced by the PATCHED binary on its third run. Every run is 11 123 420 bytes.
This is the documented emitter nondeterminism (`SourceLocation` compares across
macro buffers flip per run under parallel parse), the same canary that flaked in
r10earl42 and r10earl44 and is clean or not by luck of the run.

**ONE REAL MOVER IN 2 311 DATABASES, and the verifier names it as the target.**
Arm 2's five movers (§ 4.4) are down to one plus one arbitrated flake.

### 4.3 THE COUNTERFACTUAL — arm 1, the build that cleared the head and was still wrong

`c50eb2fc571720750394c754a0dd3dd4` is this pass's law WITHOUT the arm-2 gate
change. It clears the Earlgrey head, moves 17 `a1_earl45` cells and 10
`v45_order` cells, and produces an Earlgrey database **byte-identical to arm 2's**
(`cmp -s` on the two 4 655 216-line dumps: identical; both `slang.uhdm` files
49 940 586 bytes). Its single defect is `m45_one`: a ONE-ROW unpacked table
never enters the block, because the block's entry condition read

```cpp
(operands->size() > 1 || (nestedOpsPre9 && !isUnpackedArr))
```

— the single-operand escape hatch existed for PACKED patterns only. Golden
stamps a one-row table exactly as it stamps the first row of a five-row one, so
a law stated over "the FIRST operand" cannot carry a row count in its code gate.
**Arm 2 is the correction, and its Earlgrey population is measured to be ZERO
rather than argued to be:** the two databases are byte-identical, so the whole
of the arm-2 delta lives in `m45_one`'s shape and nowhere in the corpus.

### 4.4 THE SECOND COUNTERFACTUAL — arm 2, the build GATE 5 rejected

`50812f675f0c2ff55c7a2e519eef3d85` passed gates 1, 2, 3 and 4 **completely
clean** — 23/0 goldens, `679/50/2` on both u2r modes, `469/11` and `465/8` on
surelog, `0 differing ROWS` against both committed baselines, every histogram
unchanged, all canaries green — and its `a1_earl45` / `v45_order` grids are
IDENTICAL to arm 3's, row for row and verdict for verdict.

**GATE 5 rejected it**, and it is the only gate that could have:

```
surelog  MOVERS: 5 / 953        (the census predicted ONE)
  ./default/BlackBePipeInt-2987e0d2   patched 9007037  pristine 9007025   +12
  ./default/Earlgrey_0_1-71da2fd7     patched 49940586 pristine 49941... +8   <- the target
  ./default/Kmac-937a7db9             patched 26829    pristine 26825     +4
  ./testflags/BlackBePipeInt-2987e0d2 patched 9020028  pristine 9020016   +12
  ./testflags/Kmac-937a7db9           patched 25568    pristine 25564     +4
```

**Every delta is NONZERO, so by the MOVER RULE all five are REAL** — and then
each was arbitrated separately rather than assumed:

* the four non-Earlgrey movers' **dumps are BYTE-IDENTICAL** (`shapes45.sh`:
  `ADDED shapes=0 instances=0  REMOVED shapes=0 instances=0` on all four pairs)
  and `uhdm-cmp patched pristine` is **CMP_EQUAL** on both. So neither of the
  campaign's two normal instruments can see them at all;
* the deltas are `+4`, `+4`, `+12`, `+12` against Earlgrey's `+8` for its **two
  known stamps** — i.e. **4 bytes per stamp**, so the arithmetic names the
  population before the source does: 1 stamp in Kmac, 3 in BlackBePipeInt;
* `Surelog/tests/Kmac/sha3_pkg.sv:20` is `parameter int unsigned KeccakRate [5]
  = '{1344/MsgWidth, ...}` — 1-D, unpacked, operands are `/` operations. The
  arm-2 `stamp45` accepted any `operation`.

`v45_expr.sv` then asked golden directly, on four shapes, and golden's answer is
that **there is no object there to size**: it folds the expression. Arm 3 tests
the operand for `vpiAssignmentPatternOp` and the four stamps disappear, with the
Earlgrey database **byte-identical to arm 2's** (`cmp -s` on the two 49 940 586
byte files: identical).

**This is why "size delta ZERO proves nothing" has a twin that is easy to miss:
a dump distance of zero proves nothing either.** Kmac's two dumps are the same
file and its database is not.

---

## 5. CANARIES

```
canaries.sh  u2r (testflags projection) : rows ok=8  changed=0 absent=0 unknown-names=25
canaries.sh  SL  (both modes)           : rows ok=52 changed=0 absent=0 unknown-names=7
ctcan2.sh    u2r  EXPECT_UNKNOWN=6      : rows ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh    SL   EXPECT_UNKNOWN=1      : rows ok=58 changed=0 absent=0 unknown-patterns=1  PASS
canaudit.sh                             : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
```

Both `ctcan2` runs take the COMMITTED baseline as their FIRST argument and are
mode-matched to the corpus. **Its guard was EXERCISED on BOTH corpora, not
assumed**: re-running each with `EXPECT_UNKNOWN=0` exits **6**, so an
unaccounted unmatched pattern can never read as green. `canaudit.sh` re-asserts
that the four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) are dispatched by NO driver in this directory.

The four named canaries are `CMP_EQUAL`+`differ` rows, i.e. **their ROWS are
BLIND to byte changes**, so the DATABASES were compared BY NAME, byte for byte:

```
InterfaceModPort     default / testflags   BYTE-IDENTICAL (38003 B)
BlackParrotComplex   default / testflags   BYTE-IDENTICAL (48433 / 50584 B)
YosysOldOr           default / testflags   BYTE-IDENTICAL (14783104 B)
SVSwitch             default / testflags   BYTE-IDENTICAL (247237 B)
Earlgrey_0_1         default               DIFFERS  49940586 vs 49940578  (the target)
Earlgrey_0_1         testflags             no database (SLANG_REJECT at baseline)
```

**PROTECTED genscope canaries, BY NAME, u2r testflags, patched vs pristine
DATABASES -- all BYTE-IDENTICAL** (they are also inside gate 3's `0 differing
ROWS` and gate 5's `MOVERS: 0 / 1358`):

```
gen_test9  genvar_loop_decl_2  genvar_loop_decl_3  paramod_genscope_child
genscope_cells  gen_test4  indexed_partsel_array  EnumConcat
```

**BOUNDARIES held.** The diff touches `src/ExprEmit.cpp` and nothing else.

* **§ importedConcatNoMdimReorder42 (ParamEmit) owns concat ORDER.** This law
  writes NO order and touches NO concat: `v45_expr c45x_concat`, whose operands
  ARE concats, is byte-identical on arm 3 and pristine, and the only
  `vpiReordered` this pass reads is the flag the pre-existing reverse already
  set (it is read, never written). `i45o_concat` -- nested patterns under a
  concat -- has no cell on either side and did not move.
* **§ scopedConnPkgParamSubst44 + § defConnPkgParamFold43 (ModuleEmit conn
  loop) own connection substitution.** Nothing in `ModuleEmit.cpp` is touched;
  the pass-44 head this pass STARTS from is byte-identical to its committed
  witness, and their design-wide population (the ten `pkg::*_DEFAULT` cells) is
  inside gate 5's Earlgrey mover, whose per-shape multiset is `ADDED 1 shape /
  2 instances, REMOVED 0` -- i.e. not one of their objects moved.
* **The ancestor/re-parenting warning in the brief was HONOURED BY NOT ACTING
  ON IT.** § 6 R-4 decodes the sharing mechanism and shows it is cmp-inert
  (0 of 232 Compare bodies read `VpiParent`) and that golden's `%` operations
  live in the `weaklyReferenced` tail. No object is shared, re-parented or
  re-used by this change; the only field written is `vpiSize`, on an object
  this emitter created moments earlier.
* **The vpiSize:32 axis the brief named was CENSUSED FIRST**, both sides,
  span-keyed, before any code -- § 1. The answer ("32 = the element width after
  stripping unpacked dimensions, on the first row only") is one of the three
  candidate readings the brief listed, and the other two are refuted in § 6 R-5.
* **`r10uvm73` (class-property kind) works in `ParamEmit`/`TypeEmit`;
  `r10sd5` (ModuleEmit ~4097 clone) is a `ModuleEmit.cpp` pass. This change is
  entirely inside ONE block of `ExprEmit.cpp`'s
  `SimpleAssignmentPattern` case. **No collision to report as of this
  writing.**

---

## 6. REFUTATIONS, STATED PLAINLY

**R-1. "The stamp is a side effect of folding the use site." REFUTED BY
MEASUREMENT, and it was the first hypothesis the head suggested.** Golden's five
row-0 constants are RE-PARENTED onto the five `RhoOffset[x][y]%W` operations at
`60:31-60:48`, so "the size arrives when the select is folded" is exactly what
the dump looks like. `b45_nouse` is the same five-row table **with no use site
anywhere in the file** and golden stamps row 0 identically; `d45_userow1` reads
a cell of the LAST row and golden still stamps row 0. The stamp is a property
of the PATTERN, not of any reader of it.

**R-2. "A nested pattern op whose elements are sub-arrays gets the leaf width."
REFUTED IN BOTH DIRECTIONS — this was the code's own previous rule and it is
wrong twice.** It stamps NOTHING on a 2-level table (its depth-1 ops have leaf
constants, not sub-arrays) — that is the Earlgrey head, missed. And it stamps
EVERY deep op of a 3- or 4-level table: on `g45_four` it produced six stamps
where golden has one. The rule survived until now because the only shape ever
measured (`int P [1:0][2:0][3:0]`, commit `6f04dd8`) has exactly TWO depth-1 ops
and the ONLY-FIRST rule and the ALL-MIDDLES rule agree on... nothing, in fact:
`f45_three`'s second row was ALREADY wrong on the pristine binary, and no probe
in the tree looked at it.

**R-3. "First and last, like the packed rule." REFUTED for the ASCENDING case,
CONFIRMED-BY-ACCIDENT for the descending one.** `a45o_asc3` (three ascending
rows) stamps row 0 and NOT row 2; `c45o_desc4` (four descending rows) stamps the
two ends. The two are the same statement — `front()` plus, when the list was
reversed, `back()` — and they only *look* like "first and last" because a
reversed list's source-first row IS its stored-last.

**R-4. "The re-parenting is part of the head." NO — it is dump display, and I
checked rather than assumed.** I did not grep the files, I extracted the
BODIES: a brace-counting `awk` over
`~/git-repos/UHDM/build/generated/src/*.cpp` walks every function matching
`::Compare(const BaseClass` — **232 of them, `BaseClass::Compare` included** —
and reports any whose body text contains `VpiParent`. **HITS: 0.** What the parent lines record is real and worth
writing down: golden's elaborator, folding `RhoOffset[x][y]` at each of the 25
gen-scope instances, **hands back the pattern's own constant object** instead of
cloning it, and the `%` operation it builds around that object stamps itself as
the object's parent. Each table cell is read exactly once, so the parent field
ends up naming the unique reader — which is why the head's five constants point
at five DIFFERENT operations instead of one.

**Where those `%` operations live was CHECKED, and my first reading of it was
wrong.** `\_operation: , line:60:31, endln:60:48` occurs **75** times in
golden's dump; **50** are `|vpiParent:` back-references and the other **25 are
real objects printed at INDENT 0 inside the `weaklyReferenced` tail**
(`\_weaklyReferenced:` at line 3 840 020; the operations run from 4 058 295).
Each is `vpiOpType:13` (`%`) over `constant 52:10` — the SHARED table cell —
and `constant 60:47` (the literal 64). So they are not "never printed": they are
printed as UNREFERENCED objects, and **weaklyReferenced content is cmp-INERT by
this campaign's own measurement law**. Ours emits **zero** such objects and
parents each pattern constant at the containing pattern. `uhdm-cmp` reads none
of it and no part of this pass touches it.

**R-4b. "The first operand is an operation" is the right predicate. REFUTED BY
THE BYTE VERIFIER, on cells no grid verdict can see.** A 1-D unpacked array
whose elements are EXPRESSIONS has operations as operands and golden has **no
object at all** in that slot — it folds. Stamping one is a stamp on something
the law does not describe, and it moved `Kmac` and `BlackBePipeInt` in both
modes. The correct predicate is `VpiOpType() == vpiAssignmentPatternOp`: the law
is about ROWS, and a row is a pattern. § 4.4 and `v45_expr.sv`.

**R-5. "The value is 32." NO — it is the width after stripping unpacked
dimensions**, which happens to be 32 four times over in Earlgrey and in most of
the grid. `h45_byte` -> 8, `i45_vec12` -> 12, `g45o_struct` -> 16 are the three
cells that make the difference measurable, and the naive "element type of the
outer array" reading would have given `int [5]` = 160 for the head itself.

**R-6. "The def view will move too." NO — checked, not assumed.** Golden carries
no `vpiSize` on ANY `allModules` pattern op and neither do we: **`a1_earl45`
`allModules` 64 rows / 0 non-match and `v45_order` `allModules` 40 rows / 0
non-match, on BOTH binaries** — every non-match in either grid is a
`topModules` row. The enclosing `!paramInitDef` gate is why, and it was already
there. The `topPackages` section is the same story from the other side: 3 rows
in `a1_earl45`, all MATCH on both binaries, and `!paramInitPkg` is what keeps
them that way.

---

## 7. RANKED RESIDUES

**R1 — the NEW HEAD: an `int`-typed gen-scope localparam folds to an UNSIGNED
constant where golden folds to a SIGNED one.** `prim_keccak.sv:60:31`,
`work@prim_keccak.gen_rho_x[0].gen_rho_y[0]`: golden `INT:0` / `vpiConstType:7`,
ours `UINT:0` / `vpiConstType:9`, everything else (span, parent, size 32,
decompile, the `int_typespec` behind the `ref_typespec`) identical. Both fields
are read by `constant::Compare`. This is the whole 64-line head and the next
pass's target; `r6_nexthead45.cmp` is the witness.

**R2 — a spurious `vpiReordered` on the nested ops of an unpacked array of
PACKED arrays.** `a1_earl45 p45_arrofvec` (`logic [3:0][7:0] T [2]`): golden
carries no `vpiReordered` on either row, we carry it on both. PRE-EXISTING on
the pristine binary, untouched by this pass, and now the ONLY defect left on
those two cells (their sizes are golden-exact). The reverse is fired by the
element's own DESCENDING packed range at a level golden does not reorder.
Earlgrey population 0.

**R3 — the outermost pattern op of a STRUCT-element array carries no
`ref_typespec`.** `v45_order g45o_struct` 66:30: golden `ts=yes`, ours
`ts=None`. PRE-EXISTING, one cell, orthogonal to size (the size on the row below
it is now golden-exact). Earlgrey population 0.

**R4 — `'{default:N}` on an unpacked array emits an operation golden folds
away.** `v45_order j45o_default`: golden has NO object at 84:29 in the elab
listing; we emit an op75 with a typespec. PRE-EXISTING. Same shape as
`l45o_ca`'s two rows (golden emits nothing for the cont-assign pattern in the
elab listing either) — **two cells that are "we emit an object golden does not",
which is the opposite of the campaign's usual direction and therefore cheap to
find and cheap to fix.**

**R5 — the constant SHARING / re-parenting mechanism, decoded and deliberately
not implemented.** § 6 R-4 above. cmp-inert today; it becomes load-bearing the
moment a pass makes the folded `Offset` constants themselves comparable, so it
is written down here rather than lost.

**R6 — `golden-only line instances: 238458` still dwarfs `ours-only: 70226`.**
Earlgrey's remaining 308 684 multiset distance is overwhelmingly *things golden
has that we do not emit*. Unchanged as a conclusion; this pass moved 2 of it,
which is the correct size for a 2-object fix and says nothing about the ladder.

---

## 8. FILES

| file | what it is |
|---|---|
| `census45.py` | design-wide, span-keyed, section-separated census of EVERY `operation`, BOTH sides, keyed additionally on PATTERN NESTING DEPTH and compared on the fields `expr::Compare` / `operation::Compare` actually read |
| `census45_pristine.txt` | that census's verbatim output on the PRISTINE pair — the artifact the prediction was made from |
| `grid45.py` | per-operation grid, BOTH sides, printing `op=` / `sz=` / `dec=` / `reord=` / `ts=` SEPARATELY and ALWAYS, plus `depth` and the operand index `i` |
| `a1_earl45.sv` | the 17-cell size grid: nesting depth × row count × element type × range direction × use site × param/localparam/var × module/package |
| `v45_order.sv` | the ORDER and OVER-FIRE probe: ascending vs descending at both levels, instantiated vs top, struct elements, and the four cells the law must NOT claim (`h45o_flat`, `k45o_repl`, `l45o_ca`, `m45o_arg`) |
| `v45_expr.sv` | the probe GATE 5 forced into existence: a 1-D unpacked array whose elements are EXPRESSIONS (`/`, `{,}`, mixed, reversed), the Kmac shape in both module and package form, beside the law's own 2-D shape |
| `shapes45.sh` | per-shape MULTISET movers between two OURS dumps, ADDED and REMOVED separately, never a diff alignment |
| `sweeps45.sh` | the eight corpus sweeps, strictly sequential, `--jobs 2`, `SLANG_UHDM` exported and read back from each sweep's own `cmds.txt`, `GOLDEN_DEFER` explicitly unset |
| `arm45.sh` | single-file arm driver (carried forward; `SLANG_UHDM` has no default, md5 printed, `sed 1d` both dumps) |
| `earl45.sh` | Earlgrey_0_1 default-mode driver against the immutable golden cache |
| `msdist.sh` | resync-immune multiset dump distance (carried forward) |
| `byteverify45.sh` | GATE 5 comparator with both mandatory negative controls |
| `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the row gate and the canary set (carried forward verbatim) |
| `r6_nexthead45.cmp` | the patched binary's Earlgrey `cmp.log` verbatim (64 lines), the witness for the NEXT pass |

`README.verifier.md` is the VERIFIER's to author. It is deliberately not
written here.

---

## 9. THE NEW HEAD, COMMITTED AS A WITNESS

`r6_nexthead45.cmp` is the patched binary's Earlgrey `cmp.log` verbatim (64
lines), so the NEXT pass can assert byte-identity against it exactly as this
pass asserted byte-identity against `r10earl44repro/r6_nexthead44.cmp` (186
lines) before starting. That assertion is not a formality: it is the only proof
that the pass is standing on the base the brief describes.
