# r11u114 — pair P of the fold ground, second round: the package pattern's concat member and the case-item parameter ref

**ONE ROW CONVERTS, BOTH MODES: `ibex_tracer`.** With the law binary it reads 0
uhdm-cmp lines and 0 heads, and the law sweep writes `CMP_EQUAL`:

```
results/golden_uhdm2rtlil.csv:329:  ibex_tracer,default,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv:1200: ibex_tracer,testflags,CMP_NOTEQUAL,decompile:,,
results/gate_uhdm2rtlil.csv:329:    ibex_tracer,testflags,CMP_NOTEQUAL,decompile:,,
LAW sweep:                          ibex_tracer,default,CMP_EQUAL,,,differ
                                    ibex_tracer,testflags,CMP_EQUAL,,,differ
```

* uhdm2rtlil: 799/5/67 → **800/4/67** in both modes.
* Surelog: 479/4 (default) and 474/3 (testflags) are unchanged.
* `results/*.csv` were NOT edited. The master promotes the row.

`stamped_gen_param` moves from 96 lines to **11 lines** in both modes. It does
not convert. Its next head is the TOP package flatten (residue R2).

Base `a81eb328`. Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

| binary | md5 | what |
|---|---|---|
| pristine | `e2ae9bd546d27ae8d37dd939675e9412` | own worktree at `a81eb328`, `-j 2`; equals the OPS pin |
| **LAW** | `e67a68ed307cbe8efdeb4c5bef51a76e` | this patch; the same md5 when the patch is applied to a FRESH `a81eb328` and rebuilt |

**Surface.** Three production files, all in this pass's fence:

* `src/EmitHelpers.h` holds every § block, helper and switch. It is appended
  before the closing namespace.
* `src/ParamEmit.cpp` has three call sites. Each one **appends to or edits an
  existing line**. The file stays at 33717 lines, and all 30 `__LINE__` sites
  keep their line numbers (checked against `a81eb328`).
* `src/StmtEmit.cpp` has one block in the case-item loop.

`TypeEmit.cpp`, `UhdmExporter.cpp`, `ModuleEmit.cpp`, `ExprEmit.cpp`,
`include/` and `results/` are absent from the patch.

**Switches.** `R11U114_OFF=1` turns every law off. With it, the law binary is
byte-identical to pristine on all 49 grid arms. Each face also drops alone:
`R11U114_F1_OFF`, `R11U114_F2_OFF`, `R11U114_F2Q_OFF` and `R11U114_F3_OFF`.
Each switch reverts exactly its own face's arms and no others
(`evidence/SWITCH.txt`).

---

## Q1. The two rows at `a81eb328`

Measured with uhdm-cmp, LHS golden, on this pass's own control workdirs. There
is one head per row, and both modes give the same count. The full heads are in
`evidence/HEADS_base.txt`.

| row | lines | golden (LHS) | ours (RHS) |
|---|---|---|---|
| stamped_gen_param | 96 / 1 | `constant` 19:16-19:58, no parent, `vpiSize:12`, `BIN:010101101010`, ct 3, no decompile | `operation` op33 19:16-19:58, parented at the pattern op 17:28-21:4, with six 2-bit `BIN` operands |
| ibex_tracer | 28 / 1 | `ref_obj (work@ibex_tracer.INSN_ECALL)` 1035:9-1035:19, parent `begin` 970:14-1209:8, name `INSN_ECALL`, no actual | `constant` 1035:9-1035:19, `UINT:115`, size 32, ct 9 |

The stamped head sits in the **DEF** package listing (`uhdmallPackages`).

## Q2. Decodes, and where our emission happens

### FACE 1 — § pkgPatCatMemberFold114 (LANDED; call site in `ParamEmit.cpp` at the package/import-copy Rhs emission, line 18269)

**Producer.**

1. `compileAssignmentPattern` forces `Reduce::Yes` for a Package component
   (Surelog `src/DesignCompile/CompileExpression.cpp:3709-3713`).
2. Every pattern element is compiled through `compileExpression(..., reduce)`.
   The tail of that function runs `reduceExpr` (`:3671-3678`).
3. UHDM's `ExprEval` `vpiConcatOp` arm (`templates/ExprEval.cpp:3993-4183`)
   joins the operand constants' bits into `BIN:<bits>`. The size is the SUM of
   the operand sizes. It writes no decompile and sets no parent.
4. It gives up on an `INT`/`UINT` operand of size 64 in a multi-operand
   concat.

A parameter leaf is the substituted param_assign Rhs constant. It therefore
contributes its LITERAL's size.

The parent really is absent. The folded constant is minted without one, and
golden's DEF-listing member constants print no `vpiParent`. The judge never
reads a parent anyway.

**Our site.** The tagged-pattern member is emitted in `ExprEmit.cpp` (lines
34001-34494), which is fenced. That code has keyed-member fold arms for the TOP
view (`paramInitElabFold`) and for arithmetic members, but none for a concat in
the DEF view. The law therefore runs on the EMITTED op75 in `ParamEmit.cpp`,
right after `rhs = emitExpr(*emitInit9, ...)`. It walks the pattern: tagged
members, `default:`, positional elements and nested patterns. It matches each
`vpiConcatOp` to its slang element by five-field span, then replaces the
operation with the producer's folded constant. It computes that constant leaf
by leaf from the slang AST.

**Golden grid** (`grid/f1`, a01-a30; `evidence/GRID.txt`):

| shape | golden, DEF listing | law |
|---|---|---|
| typedef'd 2-D array member (a01, a02), plain vector (a03, a13, a16), struct member (a08), single operand (a09), positional (a11), `default:` (a23), nested pattern (a19), two members (a25) | folded BIN, concat width | folded |
| nested concat (a05), replication operand (a20), enum leaf (a12), explicit size cast `4'(3)` (a14), mixed bases (a07), 72-bit (a18) | folded | folded |
| binary literal with an `x` digit (a21) | folded, `BIN:10x10010` | folded, x kept verbatim |
| package parameter leaf with a sized literal init (a06); declared wider than its literal (a22) | folded at the LITERAL size (12, not 16) | folded at the literal size |
| parameter leaf with an unsized init (a24 `= 90`); `int` param leaf (a15) | **NOT folded** (UINT size 64) | declined |
| hex literal with an `x` digit (a27) | folded to zeros (`hexToBin`) | declined (residue R4) |
| unpacked-array parameter (a26) | folded, `BIN:00010010` size 8 | declined; see below |
| MODULE home (a10) | DEF keeps the op33 | untouched (the law requires `inPackage || isImported`) |
| an importing module's copy (a17, a25, a28) | folded in the DEF copy too | folded |
| replication as the whole member (a04) | already equal at the base | untouched |

The a26 fence exists for this reason: a later pass re-sizes an unpacked-array
listing's elements to 64 bits. Our fold would only move one wrong cell to
another wrong cell (`BIN` size 64), so the law declines it.

### FACE 2 — § imppCopyOpReadIsRef114 + § pkgQualOpReadIsRef114 (LANDED; the case-item loop in `StmtEmit.cpp`, ~4934)

**Producer.**

* A case-item expression is compiled with `Reduce::No`
  (`CompileStmt.cpp:1505-1506`).
* The component arm in `compileExpression` (`CompileExpression.cpp:2945-2966`)
  substitutes an imported parameter only under
  `reduce == Yes || (paramFromPackage && Rhs is uhdmconstant)`. With
  `Reduce::No`, only a CONSTANT module copy substitutes.

The consequences:

* **Unqualified read.** A module's materialized copy of a concat-bearing
  parameter is an OPERATION (§ impCopyConcatUnbound111). Every read of it stays
  the module-scoped, actual-less `ref_obj`. A literal-valued or arithmetic-valued
  copy is a constant and folds.
* **Qualified `pkg::P` read.** The read stays `ref_obj (pkg::P)`. Its name is
  `pkg::P`, it is bound to the package parameter, and it spans the qualifier
  `pkg::`. This happens exactly when the package's Rhs holds a concat or pattern
  (b03, b12). `100 + 100` and `8'hF0 | 8'h0F` fold (b12, and pass 104's
  `a3_nonnda94`). This is a MEASURED rule. The producer road is the
  package-scope arm (`CompileExpression.cpp:2717-2765`), but the exact line
  that keeps a concat-valued read as a ref is not pinned. It is not
  `substituteAssignedValue`: `parametersubstitution` defaults ON
  (`CommandLineParser.cpp:387`).

**Golden grid** (`grid/f2`, b01-b13):

* **Which initializer.** The rule does not depend on it: an enum-leaf concat,
  an all-literal concat, a `?` wildcard concat and a localparam all give a ref.
  A literal or an `int` initializer is substituted, and we already match that.
* **Which position.** The rule does not depend on position either. It holds in
  a case item (b01, b02, b09), an `if` condition, an assignment Rhs and a
  continuous assign (b05), a function's case item (b07), a multi-expression
  item (b08), an explicit import (b06) and a DEF-view generate block (b13).
* **Module-local parameters.** They were already refs (b04).

**Our site.** The fold of a module read sits in `ExprEmit.cpp`'s NamedValue
parameter arm (`auto& cv = psym.getValue();`, ExprEmit.cpp:16161 at `a81eb328`).
That file is FENCED to this pass. **Only the StmtEmit half lands**: a
case-item-specific arm. It reads the module copy's Rhs kind from the UHDM parent
chain (qualified: from `pkgDefMap`) and swaps the emitted constant for the ref.
Every other position is residue **R1** (b05: `x == P_CAT`, `z = P_CAT`,
`assign w = P_LCAT`).

### FACE 3 — § leakCopyOpNoTs114 (LANDED; `ParamEmit.cpp` 19423-19427 and 19926). This was ibex_tracer's NEXT head after faces 1 and 2.

After faces 1 and 2, `ibex_tracer` read 17 lines. The head was `LHS: <null>`
against our `ref_typespec (work@ibex_tracer)` on the op33 of
`CSR_MARCHID_VALUE = {1'b0, 31'd22}`, in the module's ELABORATED copy
(`evidence/HEADS_law.txt`).

**Golden grid** (`grid/f3`):

* A package parameter that reaches a module ONLY through another package's
  wildcard import is the producer's transitive leak. `ibex_tracer` imports
  `ibex_tracer_pkg::*`, which imports `ibex_pkg::*`.
* Such a copy has an **untyped** elaborated Rhs operation in these cases:
  a concat (c01, c03), a packed-array-typedef concat (c04 `PermDef`, c06
  `MCAT`), and an unpacked-array pattern (c04 `CfgRst`, `AddrRst`).
* A one-hop import keeps the module-named ref (c02).
* A packed-struct pattern keeps its flatten ref (c04 `OneCfg`).
* A diamond, where the module also imports the home package directly (c05), is
  judge-equal at the base. The law declines it.

In ibex, the four golden-untyped copies (`CSR_MARCHID_VALUE`,
`RndCnstLfsrPermDefault`, `PmpCfgRst`, `PmpAddrRst`) are exactly the four leaked
ones. The other 218 typed copies stay typed.

**Our site.** `ImpOcc9::src` is set exactly when the home package lies deeper
than the imported item. The gate additionally requires that no occurrence of the
same symbol arrives one hop. It then withholds the op ref at the two sites that
mint it: the `importedConcatOp`/`unpackedArrayTs9`/`mdimConcatOp9`/
`unpArrConcatTs9` arm, and the `hasParamArrTs` array-of-struct arm.
`packedArrayOp`, `structOp`, `anyUnknown` and the other triggers are
unmeasured, so they are untouched.

### FACE 4 (DECODED, DROPPED) — stamped_gen_param's next head

* **The head.** The next head is a missing bare `ref_typespec -> struct_typespec
  (q2::impl_t)`: golden FLATTENS `q2::IMPL`'s elaborated package listing.
* **The trigger.** A package-QUALIFIED member select `q2::IMPL.UnitTypes[grp]`
  written inside a MODULE parameter declaration triggers the flatten (grid f1
  a01, a29 plain vector, a30 literal member).
* **Why ours misses it.** Our member-select rule counts only selects written in
  the package (r11u49 b1). An UNQUALIFIED module-param select keeps the tags.
* **What a trigger did.** A trigger was built and measured. It flattened a29
  (48 → 11 lines, a later hier_path head). a01 and a30 still stayed tagged
  because a second gate blocks them.
* **Size.** Golden's flattened `UnitTypes` operand is size **36**, not 12.
  Surelog appears to multiply the typedef'd element's ranges twice
  (2·3·3·2 = 36).

The face does not reach the target row, and the second gate plus the size law
are not decoded. It was **dropped** (residue R2).

## Q3. The golden grid

The grid is in `grid/f1` (a01-a30), `grid/f2` (b01-b13) and `grid/f3`
(c01-c06): 49 arms. The golden side is the pinned Surelog in the testflags
form, via `grid114.sh`, with every rc recorded.

Pristine → law, in cmp lines/heads (`evidence/GRID.txt`):

* **Converted to 0.** a02 a03 a05-a09 a11-a14 a17-a23 a25 a28, b02 b03 b09
  b12 b13.
* **Moved to the next head.**
  * a01 (96 → 11) and a29 (48 → 11): the face-4 flatten.
  * a16 (48 → 34): a TOP module read of the folded member, ExprEmit.
  * b01, b06-b08, b10 (28 → 17): the next head is the P_LIT substitution
    constant's missing ref_typespec, an ExprEmit site.
* **Unchanged.**
  * Controls: a04, a10, a15, a24, b04, c05.
  * Residues: a26, a27, a30, b05, b11 (our copy of `{..} + 1` is already
    wrong: pre-existing).
  * The f3 arms, whose first head sits elsewhere.

Per cell, with `cells114.py`: the cells are keyed by section, kind, name,
five-field span and compare-visible props, with parent and fullname left out.
The golden×3 calibration reads 0 on every arm. Law against pristine:
**TO 187 / AWAY 0 / MOVED-WRONG 0** over 49 arms (`evidence/GRIDCELLS.txt`).

The landed controls are the committed grids of passes 104-112 plus every other
committed arm, covered by the boundary in Q6.

## Q4. The laws, each gated, each droppable alone

| § | switch | file:site | arms it alone reverts |
|---|---|---|---|
| pkgPatCatMemberFold114 | `R11U114_F1_OFF` | ParamEmit 18269 → EmitHelpers `pkgPatCatFold114` | 23 f1 arms |
| imppCopyOpReadIsRef114 | `R11U114_F2_OFF` | StmtEmit case-item loop | b01 b02 b06-b10 b13 |
| pkgQualOpReadIsRef114 | `R11U114_F2Q_OFF` | StmtEmit case-item loop | b03 b12 |
| leakCopyOpNoTs114 | `R11U114_F3_OFF` | ParamEmit 19423-19427, 19926 | c01 c03 c04 c06 |

## Q5. Census and prediction, made BEFORE the law sweep

The census binary is the law tree plus `census114.diff`: stderr fire logs only.
It is byte-identical to the law binary on all 49 arms, which serve as the
positive controls. It ran over both corpora in both modes through `wrap114.sh`:
1742 uhdm2rtlil and 1531 Surelog slang invocations (`evidence/PREDICT.txt`).

It fired **only** in these places:

* `ibex_tracer`, both modes: F2 ×6 (case items 1035, 1036, 1037, 1038, 1039,
  1054) and F3 on `CSR_MARCHID_VALUE`, `RndCnstLfsrPermDefault`, `PmpCfgRst`
  and `PmpAddrRst`.
* `stamped_gen_param`, both modes: F1 ×1 (19:16).

It fired nowhere in the Surelog corpus.

**Predicted movers:** those 4 uhdm2rtlil databases and no Surelog database. That
excludes the documented pristine-nondeterministic UVM rows.

A golden-side census is covered this way: the per-cell scorer calibrates
golden-vs-golden at 0 on every arm, row and boundary database it scores.

## Q6. Gates (`evidence/GATES.txt`)

1. **Builds.** Both binaries were built `-j 2` and frozen before any sweep.
   Pristine equals the pin. Every `cmds.txt` names the frozen binary: 1742 + 1531
   per sweep.
2. **Goldens.** 23/0 with the law binary; `/bin/false` gives 0/23.
3. **uhdm2rtlil, row-join.** Against `results/gate_uhdm2rtlil.csv` (testflags)
   and against the default rows of `results/golden_uhdm2rtlil.csv`, the ONLY
   differing row is `ibex_tracer` (CMP_NOTEQUAL → CMP_EQUAL, quoted above).
4. **Surelog, row-join.** Against `results/golden_surelog.csv`, the only
   differences are environment: the LowMemLib/LowMemPkg log path. Against this
   pass's own pristine sweep there is also the Earlgrey_0_1/default dump
   column, which read blank in the PRISTINE sweep (a uhdm-dump timeout draw).
   The law sweep's value equals the committed baseline.
5. **Byteverify, SELFCHECK=1, against own pristine workdirs.**
   * **uhdm2rtlil: MOVERS 4/1608**, exactly the predicted four. `ibex_tracer`
     scores TO 20 / AWAY 0 per mode. `stamped_gen_param` scores TO 8 / AWAY 0.
     The sectioned whole-dump distance for ibex falls in DEF (994 → 934) and
     TOP (301 → 273). Only the judge-unreachable weaklyReferenced tail grows
     (`evidence/ROWS.txt`).
   * **Surelog: MOVERS 3/960**: MiniAmiq/default and SeqDriver in both modes.
     Order-blind, each one is the documented 4-line `UINT`/`vpiDecompile` class.
     The census fired nowhere there. As a positive control, the PRISTINE binary
     alone flips SeqDriver between two hashes across four runs with the same
     4-line class. The law binary reproduces pristine's modal bytes 3 runs out
     of 4. All statuses are unchanged (`evidence/ATTRIB_surelog.txt`).
6. **Canaries.** `canaries.sh` gives ok=52 changed=0 and ok=8 changed=0.
   `ctcan2.sh` gives PASS ×2 and `canaudit.sh` PASS. The pins hold:
   * SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a`, both modes.
   * InterfaceModPort `59a365f3ce2c`, both modes.
   * BlackParrotComplex and YosysOldOr: SAME.
   * Earlgrey_0_1: default `8bdf25272e08`, testflags `59d0ee6d10c3`.

   `cfg_func_width_loop` and `LargeValue2Struct` stay `CMP_EQUAL` in both
   modes, and so do the other 21 conversion rows (the row-joins show no other
   status change).
7. **Wide boundary** (`bnd114.sh`, 9613 committed probe arms). Nothing changed
   rc or output presence. **31 MOVED**, every one scored against real Surelog
   (`evidence/BOUNDARY.txt`) and attributed by the census binary
   (`evidence/BOUNDARY_ATTR.txt`). The result is **AWAY 0 / MOVED-WRONG 0**:
   * 24 F1 arms move TO golden (one of them, r11v54 `xb2`, is also F3), and 4
     F3-only arms move TO golden. The F1 arms include the landed controls
     r11u108 `k13`/`k14`, r11u111 `f3/*` and v11u108 `brk/f2/*`, which moved
     only at their F1 cells.
   * The other 3 arms (`g22`, `l154_noenum`, `g185_e_kinds`) have zero cell
     change. They are the documented binary-LAYOUT tail constant. The positive
     control `r10uvm154repro/layoutproof154.sh` gives: judge-visible head
     identical, tail `UINT:23562649` → `UINT:23579097` on a source that no law
     can touch.

   A first build's qualified-read rule (Rhs is not a constant) moved pass 104's
   `a3_nonnda94` AWAY, because `a3p::YADD = 100 + 100` folds in golden. The rule
   was then measured again on b12 and rebuilt as the concat/pattern rule.

**Row counts, before → after, both modes:**

* `ibex_tracer`: 28/1 → **0/0 — CONVERTS**.
* `stamped_gen_param`: 96/1 → **11/1**. The next head is `LHS: ref_typespec`
  (no name) → `struct_typespec (q2::impl_t)` 12:11-16:4, `RHS: <null>`: the
  missing TOP flatten of `q2::IMPL`.

## Residues

* **R0 — stamped_gen_param's next head (R2).** The TOP package flatten
  triggered by a qualified member select in a module parameter declaration. The
  select trigger is decoded (a29). A second gate keeps typedef'd-array members
  (a01, a30) tagged, and golden sizes the flattened `UnitTypes` operand 36.
  The site is ParamEmit's member-select / SCOPED-REFERENCE rules (~14360-14412).
* **R1 — face 2 outside case items.** An `if` condition, an assignment Rhs, a
  continuous assign or an operand reading a concat-bearing imported parameter
  must stay a `ref_obj` (grid b05). The site is `ExprEmit.cpp:16161`, the
  sister pass's file.
* **R3 — the substituted literal's typespec.** A literal-valued imported
  parameter substituted into a module read carries golden's ref_typespec
  (`work@top` → the parameter's `logic_typespec`); ours has none. This is the
  next head of b01/b06-b08/b10. The site is ExprEmit.
* **R4 — declined fold shapes.** F1 declines a hex/oct/dec literal with an
  x/z digit (a27: golden maps a hex `x` to zeros) and an unpacked-array
  parameter's element (a26: a later pass re-sizes it to 64).
* **R5 — a wrong module copy.** Our module copy of an imported
  `{..} + 1` parameter is a constant where golden keeps the op24 (b11,
  pre-existing), so F2 cannot see that one.
