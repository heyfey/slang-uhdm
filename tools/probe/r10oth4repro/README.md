# r10oth4 — state transfer

**Pass result: NO CONVERSION. THREE laws landed in two families. YosysOldOr's
HEAD 1 — residue R1 from r10oth3, the replication digit string — IS CLEARED, and
the same law family also fixed FIVE neighbouring shapes the arm exposed
(concat-narrower-than-target, concat past 64 bits, x/z concat width, and the
`vpiDecompile` a truncated concat gains). The test stays CMP_NOTEQUAL in both
modes on a NEW HEAD one position behind, and that head is DECODED but NOT
shallow: my own model for it was REFUTED by its own arm and is recorded as such.
The third law (§ readFoldUntypedSizedLitParam) is correct on a 17-cell arm and
REACHES NOTHING on YosysOldOr — I say so loudly below rather than claim it as
progress.**

Base commit `0a8dec2`, branch `auto5h`, worktree
a build of 0a8dec2 + this patch, md5 `e3fb63dcacf5afef67909012ca951119` (the implementing agent's worktree path was hard-coded here and vanishes on cleanup).

Direction convention used in this file and in every note comment the patch adds:
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.

Binaries. All numbers below name which one produced them.
* pristine `0a8dec2` — md5 **`fd1d6d7cbf3e6ba0139768f08a9ef469`**
* patched, FINAL — md5 **`e3fb63dcacf5afef67909012ca951119`**
* patched, INTERMEDIATE — md5 `ee4e4cd263012b7e513a2fac8692b261`. This one had the
  over-wide first cut of § readFoldUntypedSizedLitParam. It passed goldens, both
  row gates and the u2r byte verifier, and was caught ONLY by the surelog byte
  verifier (PartSelect4, §2). **Every gate figure below is from the FINAL binary
  and every sweep was re-run on it from scratch**; the intermediate numbers are
  named here so nobody mistakes one set for the other.

The md5 was printed before and after every sweep and never changed within a
sweep; no build ran concurrently with any sweep.

---

## 0. WHERE THE HEAD IS NOW — read this first

`uhdm-cmp <golden> <ours>` on YosysOldOr, **both modes, one shared ours-database**
(the harness passes the same slang argv in both, re-verified this pass):

| | cmp lines | heads (`grep -c '^LHS:'` at col 0) | what the head is |
|---|---|---|---|
| pristine `0a8dec2` | 52 | 1 | **R1**: replication constant, golden 21 digits vs ours 20 |
| patched | 52 | 1 | **NEW**: a param_assign RHS constant's typespec KIND |

The new head, verbatim:

```
LHS(golden):  logic_typespec: , id:198740          <- NO location
              |vpiRange: \_range: , id:198742
                |vpiLeftRange:  constant id:198743 |UINT:30
                |vpiRightRange: constant id:198744 |UINT:0
RHS(ours):    int_typespec: , id:591, line:86:4, endln:88:24
              |vpiRange: \_range: , id:592
                |vpiLeftRange:  constant id:593 |INT:30
                |vpiRightRange: constant id:594 |INT:0
```

Located by ancestor walk (not by grep — 24 objects in our dump carry that span):
`or1200_fpu_intfloat_conv.v:86-88`,

```
   parameter	INF  = 31'h7f800000,      <- golden: BARE loc-less logic_typespec
		  QNAN = 31'h7fc00001,      <- golden: BARE, a SECOND fresh object
		  SNAN = 31'h7f800001;      <- golden: the LOCATED int_typespec, like ours
```

and it is the `param_assign -> vpiRhs constant -> vpiTypespec ref_typespec ->
vpiActual` edge, in the **uhdmtopModules (ELAB)** copy only; the `uhdmallModules`
(DEF) copy is byte-identical on both sides, and the three `parameter` objects
themselves point at the located `int_typespec` on both sides in all three cases.
Only the RHS constant's typespec moves.

**Depth: NOT SHALLOW, and my model for it is REFUTED — see §3.**

The dump residue is unchanged at **34,669 content lines / 2,060 hunks** (content =
`grep -c '^[-+]'` on `diff -u` minus the two file-header lines). Do not read
"one cmp head" as "nearly equal".

---

## 1. THE LAW FAMILY THAT CLEARED HEAD 1

### `§ srlgFoldNaturalWidth` — DIRECTION: REPLACE. src/ExprEmit.cpp

Three call sites, all inside `UhdmExporter::tryFoldConst` (src/ExprEmit.cpp:1462),
plus one new file-local helper `srlgNaturalFoldWidth` immediately above it:

1. the X/Z-concat arm (`if (iv.hasUnknown())`);
2. the clean concat arm (`Concatenation || (paramCtx && Replication)`);
3. the non-parameter **replication** arm (`!paramCtx && Replication && sizedElem9`)
   — this is the one that carried YosysOldOr's head.

**THE LAW.** Surelog's reduce builds the folded constant at the expression's
**NATURAL (self-determined) width** and only then clamps it against the
assignment target in `CompileHelper::adjustSize`
(`Surelog/src/DesignCompile/CompileHelper.cpp:3949`). The width it lands on is

```
    w = (natural > 64) ? natural : min(natural, target)
```

and the two operator families differ ONLY in whether the DIGIT STRING is
truncated with it:

| top-level operator | vpiSize | digit string | vpiDecompile |
|---|---|---|---|
| **replication** `{N{e}}` | `w` above | ALWAYS `natural` | the natural digits (producer writes it) |
| **plain concat** `{a,b}` | `w` above | `w` above | NONE, unless truncated (§ srlgConcatTruncDecompile) |

Transcribed from Surelog, every claim with its line:

* `case vpiMultiConcatOp` (`UHDM/templates/ExprEval.cpp:3797`) sets
  `c->VpiSize(n * width)`, the full digit string, **and attaches an
  `int_typespec` "word size"**. `case vpiConcatOp` sums operand sizes and
  attaches **no typespec and no decompile**.
* In `adjustSize`, the `vpiBinaryConst` arm REPLACES its `ts` with the
  constant's own typespec if it has one. So a replication lands in the
  `uhdmint_typespec` branch, whose only effect is
  `c->VpiSize((orig_size < size) ? orig_size : size)` — the value string is never
  touched. A plain concat keeps the LHS `logic_typespec` and lands in the
  `uhdmlogic_typespec` branch, which is `if (orig_size > size) { … remove_prefix
  … VpiValue … VpiDecompile(v) … VpiSize(size) }` — i.e. it TRUNCATES, and does
  **nothing at all** when `natural <= target`.
* The `> 64` arm is UHDM's `ExprEval::get_value`
  (`UHDM/templates/ExprEval.cpp:1967`, `if (expr->VpiSize() > 64) invalidValue =
  true;`). **A correction to my own first reading:** the trailing
  `else { c->VpiSize(size); }` in `adjustSize` belongs to the
  `vpiUIntConst / else if vpiBinaryConst` chain, NOT to the `if (!invalidValue)`
  test — so when `get_value` bails, `adjustSize` does nothing whatsoever and the
  producer's natural constant survives intact. That is why the 65/70/80-bit rows
  keep their natural size instead of the clamp, and it is measured, not inferred:
  `a11_b64` (natural 64, clamped) vs `a12_b65` (natural 65, unclamped) pins the
  boundary at exactly `> 64`.

### `§ srlgConcatTruncDecompile` — DIRECTION: ADD. src/ExprEmit.cpp, same arms

A non-parameter plain-concat fold normally has **no** `vpiDecompile` (its producer
writes none) — which we already matched. But `adjustSize`'s truncating arm ADDS
one, equal to the **truncated** bit string and **bare** (no `<w>'b` prefix).
THE GATE is therefore "the digits were actually truncated", i.e.
`natural > target && natural <= 64`.

This law also **removes** a decompile we were emitting: the X/Z-concat arm wrote
`<w>'b<bits>` unconditionally, and golden has none unless truncated
(`b8_cat_x` dc=`<NONE>` vs `b9_cat_x_nar` dc=`0000`). The `paramCtx` spelling is
untouched.

### THE ARM AND BOTH SIDES OF EVERY CELL

`tools/probe/r10oth4repro/r1_repl.v`, read with `rarm.sh` + `replform.py` +
`rtab.sh`. All rows are the ELAB (`uhdmtopModules`) `cont_assign` RHS; the DEF
view keeps the unfolded operation on both sides in every cell. `nat` = natural
width, `tgt` = target width, `sz` = vpiSize, `nd` = digit count, `dc` = decompile.

| cell | source | nat | tgt | golden(LHS) | ours BEFORE (RHS) | ours AFTER |
|---|---|---|---|---|---|---|
| `a1_narrow` | `{dw-1{1'b0}}` dw=22 -> `[19:0]` | 21 | 20 | sz20 **nd21** | sz20 nd20 | sz20 nd21 ✓ |
| `a2_wide` | the same -> `[31:0]` | 21 | 32 | **sz21** nd21 | sz32 nd32 | sz21 nd21 ✓ |
| `a3_exact` | dw=21 -> `[19:0]` | 20 | 20 | sz20 nd20 | sz20 nd20 — **already equal** | unchanged ✓ |
| `a4_ones` | `{dw-1{1'b1}}` -> `[19:0]` | 21 | 20 | sz20 nd21 (ones) | sz20 nd20 | sz20 nd21 ✓ |
| `a5_lit` | `{21{1'b0}}`, no parameter | 21 | 20 | sz20 nd21 | sz20 nd20 | sz20 nd21 ✓ |
| `a6_melem` | `{3{2'b10}}` -> `[19:0]` | 6 | 20 | **sz6 nd6** `101010` | sz20 nd20 | sz6 nd6 ✓ |
| `a7_melem_nar` | `{3{2'b10}}` -> `[3:0]` | 6 | 4 | sz4 **nd6** `101010` | sz4 nd4 `1010` | sz4 nd6 ✓ |
| `a8_big` | `{70{1'b1}}` -> `[19:0]` | 70 | 20 | **sz70 nd70** | sz20 nd20 | sz70 nd70 ✓ |
| `a9_big_wide` | `{70{1'b1}}` -> `[95:0]` | 70 | 96 | sz70 nd70 | sz96 nd96 | sz70 nd70 ✓ |
| `a10_scalar` | `{2{1'b1}}` -> scalar `wire` | 2 | 1 | sz1 **nd2** `11` | sz1 nd1 `1` | sz1 nd2 ✓ |
| `a11_b64` | `{64{1'b1}}` -> `[19:0]` | 64 | 20 | **sz20 nd64** | sz20 nd20 | sz20 nd64 ✓ |
| `a12_b65` | `{65{1'b1}}` -> `[19:0]` | 65 | 20 | **sz65 nd65** | sz20 nd20 | sz65 nd65 ✓ |
| `a13_b64_wide` | `{64{1'b1}}` -> `[95:0]` | 64 | 96 | sz64 nd64 | sz96 nd96 | sz64 nd64 ✓ |
| `b1_cat_wide` | `{2'b10,2'b01}` -> `[19:0]` | 4 | 20 | **sz4 nd4** dc=`<NONE>` | sz20 nd20 | sz4 nd4 ✓ |
| `b2_cat_nar` | `{8'hF5,8'h0F}` -> `[7:0]` | 16 | 8 | sz8 nd8 **dc=`00001111`** | sz8 nd8 dc=`<NONE>` | + dc ✓ |
| `b3_cat_exact` | `{2'b10,2'b01}` -> `[3:0]` | 4 | 4 | sz4 nd4 dc=`<NONE>` | equal | unchanged ✓ |
| `b4_cat_repl` | `{1'b1,{3{1'b0}}}` -> `[19:0]` | 4 | 20 | sz4 nd4 | sz20 nd20 | sz4 nd4 ✓ |
| `b5_cat_b80` | 80-bit concat -> `[19:0]` | 80 | 20 | **sz80 nd80** dc=`<NONE>` | sz20 nd20 | sz80 nd80 ✓ |
| `b6_cat_b80_wide` | 80-bit concat -> `[95:0]` | 80 | 96 | sz80 nd80 | sz96 nd96 | sz80 nd80 ✓ |
| `b7_cat_repl_nar` | `{1'b1,{8{1'b1}}}` -> `[3:0]` | 9 | 4 | sz4 **nd4** dc=`1111` | sz4 nd4 dc=`<NONE>` | + dc ✓ |
| `b8_cat_x` | `{4'b001x,4'b0000}` -> `[19:0]` | 8 | 20 | **sz8 nd8** dc=`<NONE>` | sz20 nd20 dc=`20'b…` | sz8 nd8, dc DROPPED ✓ |
| `b9_cat_x_nar` | `{4'b001x,4'b0000}` -> `[3:0]` | 8 | 4 | sz4 nd4 **dc=`0000`** | sz4 nd4 dc=`<NONE>` | + dc ✓ |

**All 22 cells now agree on value, size AND decompile.** The arm's remaining
`CMP_FAIL` is entirely the unrelated `c3/d1/d2` cells (§4 residue R1).

#### How each part of the gate was proved NECESSARY

* **`b7_cat_repl_nar` is why the split is by TOP-LEVEL OPERATOR.** A concat that
  *contains* a replication truncates like a concat (nd4, not nd9), so the
  int_typespec that exempts the digits comes from the outermost
  `vpiMultiConcatOp` only. Without that cell the natural reading — "anything with
  a replication in it keeps natural digits" — is 1 cell away and wrong.
* **`a11_b64` vs `a12_b65` is why the boundary is `> 64`, not `>= 64`.**
* **`a3_exact` / `b3_cat_exact` are the EQUAL controls**: `natural == target`
  leaves the pre-existing path untouched, which is what `srlgNaturalFoldWidth`'s
  `natW == tgtW -> return {valid=false}` guarantees.
* **`a6_melem` is why "natural" is `count * elemwidth`, not `count`.**
* **`paramCtx` is excluded at every one of the three sites**, and cell `c3_param`
  is the control for that: § `replFoldParamInt32` (the pre-existing law, same
  function) clamps against the replication's own `int` result type rather than the
  declared parameter type, and this pass must not disturb it.
* **Contexts that do NOT get this treatment, measured so the blast radius is
  bounded, not assumed:** a PROCEDURAL assignment (`c1_proc`, `a14_int`) and an
  INSTANCE PORT CONNECTION (`c2_top`) are unfolded in golden AND in ours — golden
  keeps the operation, so the law cannot over-fire there. VARIABLE INITIALIZERS
  (`e1`–`e4`, the other `tryFoldConst` consumer at
  `src/ModuleEmit.cpp:17246`) are also unfolded by golden, so that consumer is
  not exercised by any concat/replication fold in this arm.

#### REFUTATION recorded here because it cost a rebuild

r10oth3's residue R1 stated the law as "vpiSize = min(count, target) but the
digits are count long". That is right for the replication and **wrong for the
plain concat and wrong above 64 bits**, and it says nothing about the decompile —
three of the five extra shapes this pass fixed. Its five-cell table is correct as
far as it goes; its *stated law* is a third of the real one.

---

## 2. THE THIRD LAW, AND IT REACHES NOTHING ON THE TARGET

### `§ readFoldUntypedSizedLitParam` — DIRECTION: ADD. src/ParamEmit.cpp

Two sites: the new file-local `srlgUntypedSizedLitParam` right after
`UhdmExporter::isRangedUntypedParam` (src/ParamEmit.cpp:13744), and a third
spelling added to the gate of the bare-typespec rewrite in the ELAB param_assign
path (the `else if ((unbasedSharedActive || readFold9) && …)` arm).

**THE PREDICATE.** Surelog's `CompileHelper::setRange`
(`CompileHelper.cpp:5417`) replaces a value constant's typespec with a FRESH
loc-less `logic_typespec` whose single range is the Value's `[lr:rr]` as BARE
`UINT` constants — and it fires `if (lr || rr)`, where `lr/rr` were copied off the
parameter's DECLARATION typespec's first packed range (`CompileHelper.cpp:5410`).
An **untyped parameter with NO declared dimensions** still has such a range when
its value is a **sized literal** (`parameter INF = 31'h7f800000` gets
`int_typespec [30:0]`), so it takes the rewrite too. Our
`isRangedUntypedParam` insists on non-empty `ImplicitType` dimensions and
therefore refused exactly that shape.

**ARM `r3_setrange.v`, golden and ours, ELAB param_assign RHS constant typespec.**
`BARE` = loc-less `logic_typespec` with `[UINT:30,UINT:0]`; `LOCATED` = the
declaration's `int_typespec` with `[INT:30,INT:0]`.

| cell | shape | golden(LHS) | ours BEFORE | ours AFTER |
|---|---|---|---|---|
| `g1_ref` | `parameter A=31'h1` + `assign w=A` | **BARE** | LOCATED | **BARE** ✓ |
| `g2_noref` | the same, read NOWHERE | LOCATED | LOCATED | unchanged ✓ |
| `g3_mixed` | `A,B,C` in ONE declaration, A and B read | **BARE, BARE, LOCATED** | LOCATED x3 | BARE, BARE, LOCATED ✓ |
| `g4_unsized` | `parameter A=5`, read | LOCATED (no range: setRange no-op) | LOCATED | unchanged ✓ |
| `g5_proc` | read from an `always` block only | LOCATED | LOCATED | unchanged ✓ |
| `g6_top` | read only as an instance param override | LOCATED | LOCATED | unchanged ✓ |
| `g7_twice` | read by two cont-assigns | **BARE** | LOCATED | **BARE** ✓ |
| `g8_typed` | `parameter [30:0] A`, read | BARE | BARE — **already right** | unchanged ✓ |
| `g9_op` | `parameter A=31'h1+1`, read | constant carries NO typespec | (see residue R2) | unchanged |
| `g10_cat` | `parameter A={2'b10,2'b01}`, read | NO typespec | NO typespec | unchanged ✓ |
| `g11_paramref` | `A` unread, `B=A` read | A LOCATED, B no typespec | same | unchanged ✓ |
| `g12_sizeddec` | `parameter A=31'd5`, read | NO typespec (INT-valued) | NO typespec | unchanged ✓ |

`g2_noref` / `g5_proc` / `g6_top` are what prove the READ half of the gate
necessary; `g4_unsized` and `g12_sizeddec` are why the predicate is narrowed to a
SIZED INTEGER LITERAL rather than "any untyped packed-array param"; `g8_typed`
shows the machinery already existed and only its gate was too narrow.

#### THE BYTE VERIFIER CAUGHT THIS LAW OVER-FIRING, and the fix REFUTED my second model too

The first cut of the law used `readFold9` — i.e. `paramNameIsRead ||
paramCaFoldRead` — like the ranged-untyped spelling does. The byte verifier then
reported an unexplained mover on **`PartSelect4`** (both modes; the row is
`CMP_EQUAL` + dump `differ` in the baseline, so the whole-row CSV diff is BLIND
there), and `mover.sh` showed it going the WRONG WAY: dump-diff
**58 -> 71 content lines, 7 -> 8 hunks**. Its source is

```
    parameter A = 68'h200000000000000;
    parameter B = A[8*4+:4];
```

and golden keeps A's constant on the LOCATED `int_typespec` even though A IS read.

I hypothesised the extra gate was the WIDTH — 68 bits does not fit Surelog's
64-bit `SValue`, so `instance->getValue(name)` would yield nothing valid and the
`if (sval && sval->isValid())` mint path (CompileExpression.cpp:972) would not be
taken. **Arm `r4_width.v` REFUTES that outright:**

| cell | shape | golden(LHS) | ours now |
|---|---|---|---|
| `i1_w68_sel` | 68 bits, read by a SELECT in another param's initializer | **LOCATED** | LOCATED ✓ |
| `i2_w68_ca` | 68 bits, read as a whole name by `assign w = A` | **BARE** | BARE ✓ |
| `i3_w40_ca` | 40 bits, cont-assign read | BARE | BARE ✓ |
| `i4_w64_ca` | exactly 64 bits, cont-assign read | BARE | BARE ✓ |
| `i5_w65_ca` | 65 bits, cont-assign read | BARE | BARE ✓ |
| `i6_w31_sel` | **31 bits**, read by a SELECT in another param's initializer | **LOCATED** | LOCATED ✓ |

`i2` and `i5` kill the width model (68 and 65 bits both take the rewrite);
`i6` isolates the real gate at a width that fits. **The distinguisher is the READ
SHAPE: a CONT-ASSIGN read rewrites, a SELECT read inside another parameter's
initializer does not** — so this spelling takes `paramCaFoldRead` ALONE, never
`paramNameIsRead`'s select rule. That is what the shipped code does
(`caReadFold9` at the site), and after it PartSelect4 is byte-identical to
pristine again (dump-diff 58 / 7 hunks on both binaries, same md5
`437f15b30dcf`).

**A METHOD NOTE worth more than the law**: arm `r4_width.v` is **PASS_CMP with 0
heads on BOTH the over-firing and the fixed binary.** `uhdm-cmp` never saw the
defect — `Compare`'s `m_visited` short-circuit reached golden's object first —
and only `diff -u g.dump o.dump` and the corpus byte verifier did. This is the
third pass in a row that hazard has bitten; judge arms on the dump.

### AND NOW THE HONEST PART: **IT REACHES NOTHING ON YosysOldOr.**

I re-measured after building it: the head, the `cmp` output, and the dump-diff
(34,669 / 2,060) are **bit-for-bit what they were before the law**, and our
YosysOldOr database is byte-identical across the two builds. Proof that the code
ran at all is the arm: `g1/g3/g7` moved from LOCATED to BARE on the same binary.

**Why it does not reach the corpus, and this REFUTES my own model of the head.**
The corpus read is

```
   assign out_fixed = ((qnan_d | snan_d) | (ind_d)) ? QNAN : INF;   // :283-284
```

whose operands are NETS, so the RHS does not reduce and neither
`paramNameIsRead` (which wants a SELECT, or a whole name that IS the entire RHS)
nor `paramCaFoldRead` (which wants the RHS to fold) sees it. I hypothesised that
`UhdmWriter.cpp:2199` — `if (opType == vpiAssignmentPatternOp || opType ==
vpiConditionOp) if (substituteAssignedValue(...))` — substitutes names in a
condition op whether or not it folds, which would open the gate for the corpus
shape. **Cells h1–h5 REFUTE that:**

| cell | shape | golden(LHS) |
|---|---|---|
| `h1_condnet` | `assign w = nn ? A : B;` — the CORPUS SHAPE, net condition | **LOCATED** (both params!) |
| `h2_binnet` | `assign w = nn == A;` (the r9hilo ablation's control) | LOCATED |
| `h3_condone` | `assign w = nn ? A : 31'h0;` | LOCATED |
| `h4_condtyped` | the same with `parameter [30:0] A` | LOCATED |
| `h5_condpos` | `assign w = A ? nn : 1'b0;` — param in the CONDITION | **BARE** |

So a non-foldable ternary reading the parameter in a VALUE arm does **not**
trigger the rewrite in a one-module arm, while the *same* shape does in the
corpus — and a parameter in the CONDITION position triggers it even when nothing
folds (`h5`, a NEW read spelling nobody has modelled, filed as residue R3).
Whatever distinguishes the corpus site from `h1_condnet` is still unknown; the
next pass should bisect it with r10oth3's `b5_addfiles.sh`, because it is
evidently a whole-compilation property and not a property of the statement. That
is the same shape of answer as the Rggen finding, which is why I stopped rather
than guess a fourth spelling.

**Should the law stay?** It is measured on both sides of 17 cells, it moves us
toward golden in 4 of them, it is gated by an ablation, and it changed **zero
rows and zero bytes** on both corpora (§5). It buys the target nothing. I kept it
and said so; a master who prefers a minimal patch can drop the two
`srlgUntypedSizedLitParam` hunks without touching the family that cleared HEAD 1.

---

## 3. THE NEW HEAD — what is known, what is not

* **What it is**: §0. The `param_assign` RHS constant's `vpiActual` typespec, in
  the ELAB view of `or1200_fpu_intfloat_conv`, for the two of three declarators
  that are read.
* **What produces golden's object**: `CompileHelper::setRange`, positively
  identified (its shape — `logic_typespec` + one `range` + two bounds that print
  only `UINT:<n>`, no location, no parent — is unique in the codebase).
* **What we already have**: the whole rewrite machinery
  (`makeBareVecParamTs`, `paramNameIsRead`, `paramCaFoldRead`,
  `isRangedUntypedParam`) plus, as of this pass, the untyped-sized-literal
  spelling of the TYPE half of the gate. **The missing piece is the READ half.**
* **What is REFUTED**: "multi-declarator parameter declarations split their
  typespecs" (arm `r2_paramts.v` is PASS_CMP + DUMP_MATCH: golden gives all three
  declarators the same shared `int_typespec`); and "a condition-op read is enough"
  (arm cells `h1`–`h4`).
* **Depth: NOT SHALLOW.** It needs the distinguisher between the corpus's
  non-foldable ternary and `h1_condnet`'s, which is a whole-compilation property.
  Ranked R3 below with a method.

---

## 4. RANKED RESIDUE (most reachable first)

### R1. The ELAB cont_assign Rhs must REUSE the parameter's own value-constant object. DIRECTION: REPLACE (reuse, NOT a bail). Depth: shallow. NEWLY EXPOSED, honestly NOT DONE.

> **THIS ENTRY WAS REWRITTEN AT INTEGRATION. THE ORIGINAL INVERTED THE DIRECTION
> VIA A VIEW CONFLATION, and it would have sent the next pass to add a bail that
> produces an object golden does not have.** The original text claimed
> `LHS(golden): cont_assign vpiRhs = ref_obj (…Q)` against
> `RHS(ours): constant UINT:5`. Re-measured on cell `d1_paramref`, BOTH sides,
> BOTH views:
> * **DEF view** — both sides are `ref_obj (work@d1_paramref.Q) 204:12-204:13`.
>   **ALREADY EQUAL.** The quoted `ref_obj` is the DEF row; the only `ref_obj` in
>   the ELAB cont_assign is its *vpiLhs* (`t`).
> * **ELAB, golden** — the cont_assign's vpiRhs is a **CONSTANT**, and it is the
>   SAME OBJECT as the param_assign's Rhs: printed in full under the param_assign
>   carrying `vpiParent: cont_assign 204:8-204:13`, `vpiDecompile:20'h5`,
>   `vpiSize:20`, `HEX:5`, `vpiConstType:5`, ref_typespec -> a **LOCATIONLESS**
>   `logic_typespec`; then printed BY REFERENCE under the cont_assign.
> * **ELAB, ours** — our param_assign constant is ALREADY byte-identical to
>   golden's; we then mint a **SECOND** constant at the same span for the
>   cont_assign with `vpiDecompile:5`, `UINT:5`, `vpiConstType:9`, ref_typespec ->
>   a **LOCATED** `int_typespec`.
> * Counts: `constant , line:202:22, endln:202:27` golden **5** / ours **6**;
>   `vpiDecompile:20'h5` **2** both; `      |vpiDecompile:5` golden **0** / ours **1**.
>
> So the fold is RIGHT and the OBJECT IDENTITY and ENCODING are wrong. The fix is
> to REUSE the parameter's own value-constant (HEX/`vpiHexConst`, loc-less
> `logic_typespec`) as the ELAB cont_assign Rhs instead of minting a fresh decimal
> UINT one. This also dissolves the original's worry that "some other guard must
> already be suppressing the fold in most real rows" — **there is no such guard to
> find.**
>
> **ROOT CAUSE OF THE MIS-STATEMENT, and it is this campaign's most repeated
> failure class:** `replform.py` deliberately skips BACK-REFERENCE subtrees (it
> documents this at its own lines 15-19 and implements it via `BACKREF` +
> `skip_indent` — I confirmed both), so golden's by-reference row is INVISIBLE to
> it, `rtab.sh` renders the cell as `G| ct? sz? ?:? nd=- dc=<NONE>`, and the
> write-up filled that empty cell in with a guess. **AN ARM ROW ASSERTED FROM ONE
> SIDE.** An instrument that cannot see a side must make the write-up say
> UNMEASURED, not let it infer.
Arm `r1_repl.v` cells `d1_paramref`, `d2_paramref_repl`, `c3_param`. Measure with
`rarm.sh r1_repl.v` + `rtab.sh` — but see the blockquote ABOVE for what to
measure, not the struck text below.

> ~~**THE ORIGINAL BODY OF THIS RESIDUE IS STRUCK AND KEPT ONLY AS A WARNING.**
> It said: golden's cont_assign vpiRhs is a `ref_obj` NOT folded against our
> folded `constant UINT:5`; that this is a KIND difference; that the fix "is a
> bail"; and that "some other guard must already be suppressing the fold in most
> real rows — find that guard before widening this one".~~
>
> **EVERY ONE OF THOSE CLAIMS IS WRONG, and the direction is INVERTED.** The
> `ref_obj` is the **DEF** row, where both sides are ALREADY EQUAL. In the ELAB
> view golden's Rhs IS a constant — the parameter's own value-constant, reached
> BY REFERENCE — and the fix is to REUSE that object, not to stop folding. THERE
> IS NO SUPPRESSING GUARD TO FIND. This was confirmed independently THREE times
> (the pass-51-era verifier, the r10oth5 implementer, and the r10oth5 verifier,
> each off the dumps in both views).
>
> **The struck text was left standing below the correction at the previous
> integration — MY error.** A reader who skipped the blockquote got exactly the
> direction that had already been wrong twice. Deleting a superseded claim is
> part of applying a correction; appending the right answer above the wrong one
> is not enough.

### R2. `h5_condpos` — a parameter read in the CONDITION POSITION of a cont-assign ternary takes the bare setRange rewrite even when NOTHING folds. DIRECTION: ADD a read spelling. Depth: shallow. NEWLY MEASURED, honestly NOT DONE.
Arm `r3_setrange.v` cell `h5_condpos`, `assign w = A ? nn : 1'b0;` with `nn` a
net, so the RHS cannot reduce: golden gives A the **BARE** loc-less
logic_typespec, ours keeps the LOCATED one. Cells `h1`–`h4` are the controls —
the same non-foldable ternary reading the parameter in a VALUE arm does NOT
rewrite, at either width and with or without an explicit type. So the CONDITION
position is a read position `paramNameIsRead` and `paramCaFoldRead` both miss.
This is independent of the YosysOldOr mystery (R3) and is worth a row on its own.

### R2b. `g9_op` — an untyped param whose value is an OPERATION carries a ref_typespec on our side and NONE in golden. DIRECTION: REPLACE (drop it). Depth: shallow. Measured, not fixed.
Arm `r3_setrange.v` cell `g9_op` (`parameter A = 31'h1 + 1`, read):
golden's elab constant has **no** `vpiTypespec` at all; ours has
`ref_typespec -> int_typespec@86:1-86:24`. It is the arm's current cmp head
(`LHS: <null>`), it predates this pass (the pristine binary shows it too), and it
is one `rhsRt` suppression away. `g10_cat` and `g12_sizeddec` are the same
"golden has no typespec" family and already agree, so the gate is narrow.

### R3. YosysOldOr's NEW head: the READ HALF of the setRange rewrite. DIRECTION: ADD a fourth read spelling. Depth: NOT shallow — a whole-compilation property.
Everything known is in §2/§3. Two concrete next steps, in order:
1. **Bisect the file list** with r10oth3's `tools/probe/r10oth3repro/b5_addfiles.sh`
   (it already carries `--ignore-unknown-modules` and a PROBE_BLIND control),
   using `tsarm.py` as the counter, to find the minimal file set in which
   `or1200_fpu_intfloat_conv`'s INF/QNAN take the bare rewrite. `h1_condnet`
   proves one module alone does NOT, so the trigger is elsewhere in the compile.
2. **Model `h5_condpos`** first regardless: "a parameter read in the CONDITION
   position of a cont-assign ternary takes the bare rewrite even when nothing
   folds" is a NEW spelling, measured on both sides, that no current predicate
   covers. It is independent of the corpus mystery and is worth a row of its own.

### R4. `materializeDefNetTs` still has no port context outside § mergedPortDefRangeSymbolic's gate. DIRECTION: ADD. Depth: shallow. INHERITED from r10oth3 R2, untouched this pass.

### R5. NAMED-type split port declarations are refused by that gate rather than guessed. DIRECTION: ADD. Depth: shallow. INHERITED from r10oth3 R5, untouched.

### R6. Rggen / Surelog's self-modifying compound-assignment RHS. DIRECTION: REPLACE. Depth: DEEP. INHERITED from r10oth3 R3 with its closed form; still ranked LAST among reachable work, and this pass did not touch it.

### R7. Golden's mutated constants also change SIZE and ENCODING. INHERITED from r10oth3 R4, untouched.

### R8. YosysOldOr is still 34,669 dump-diff content lines in 2,060 hunks. DIRECTION: mixed. Depth: not shallow.
Unchanged by this pass: the three laws move cmp-visible FIELDS, and the residue is
dominated by weak-tail `logic_typespec` ordering. The pool diverges at col-0
object index **272 of 29,922** and the two sides carry a different NUMBER of
objects (golden 29,922 / ours 29,919), so a DUMP_MATCH here is a different and
much larger project than a CMP_EQUAL.

---

## 5. GATES

All five ran, on binary **`e3fb63dcacf5afef67909012ca951119`** — the FINAL one.
(CORRECTED at integration: this said `ee4e4cd263012b7e513a2fac8692b261`, which is
the INTERMEDIATE binary this same README describes as carrying the over-wide first
cut caught on PartSelect4, and it contradicted the item immediately below it. Every
figure in this section is the final binary's; the pass verifier reproduced them all
on `e3fb63dc…`.)

1. **Build** — `cmake --build build -j 3` in this worktree: `Built target
   slang_uhdm`, no errors, no new warnings. One in-code comment was corrected
   AFTER the sweeps (it overclaimed that § readFoldUntypedSizedLitParam reaches
   YosysOldOr's head); the rebuild produced the **same md5
   `e3fb63dcacf5afef67909012ca951119`**, which is the control that every gate
   figure below still describes the shipped source.
2. **Goldens** — `bash tests/check_goldens.sh` with `SLANG_UHDM` exported to this
   worktree's build: **PASS 23 / FAIL 0**. Negative control
   `SLANG_UHDM=/bin/false`: **PASS 0 / FAIL 23**, so the export is real and the
   `verify_golden.py:52` / `check_goldens.sh:5` main-tree default is not what got
   measured.
3. **uhdm2rtlil, mode `testflags`, `--jobs 2`, own `--out`** — **731 rows** (the
   committed CSV is 732 LINES including its header): **679 CMP_EQUAL / 50
   SLANG_REJECT / 2 SURELOG_FAIL**, dump **496 match / 183 differ / 52 blank**.
   Whole-row diff against `results/gate_uhdm2rtlil.csv`, status *and* dump
   column: **0 lines — BYTE-IDENTICAL.** `default` was NOT run (no committed
   baseline) and nothing here implies it was row-checked.
4. **surelog, `--mode both`, `--jobs 2`, own `--out`** — **1588 rows** (the
   committed CSV is 1589 LINES including its header):
   * `default` **467 CMP_EQUAL** / **13 CMP_NOTEQUAL** / 5 DEFERRED / 284
     SLANG_REJECT / 25 SURELOG_FAIL; dump **match 225** / differ 242.
   * `testflags` **463 CMP_EQUAL** / **10 CMP_NOTEQUAL** / 5 DEFERRED / 286
     SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1
     TIMEOUT / 1 NO_UHDM; dump **match 165** / differ 298.
   * Every cell equals the brief's `0a8dec2` baseline exactly and **the dump
     match counts did NOT fall.**
   * Whole-row diff against `results/golden_surelog.csv`, all 1588 rows:
     **0 lines — BYTE-IDENTICAL.** No conversion and no regression.
   * The known `Google,testflags` golden-side environment flake did NOT differ
     this run. Named, not filtered.
   * `results/golden_surelog.csv`'s `LowMemPkg,testflags` row embeds an absolute
     SESSION-SCRATCHPAD path; it reproduced identically here (the row diff is
     empty), so the judge is sound. Not "fixed", per the standing instruction.
5. **BYTE VERIFIER on BOTH corpora** — `byteverify.sh`, patched vs pristine, both
   sweeps run at `--jobs 2` into separate roots whose relative path sets the
   script ASSERTS are identical before reporting anything:
   * **uhdm2rtlil: 679 databases, PATH_SETS_IDENTICAL, 0 MOVERS.** Comparator
     negative control (`SELFCHECK=1`, every file compared against one fixed
     file): **678 / 679 flagged** — the one unflagged path is the fixed file
     compared with itself, so the comparator is provably live.
   * **surelog: 953 databases, PATH_SETS_IDENTICAL, 2 MOVERS — OR 3** when the
     known intermittent `Scoreboard default` coin-flip lands the other way. A
     verifier reproduced 3 and PROVED the third with
     `r10oth2repro/scoreboard_nondet.sh`: 4 runs per binary, each binary disagrees
     with ITSELF, and both emit the same two md5s (`693cc0255c0f`/`795fdb72b4d8`).
     Neither count is a regression.
     Comparator negative control: **952 / 953 flagged.**
   * As a POSITIVE CONTROL on the harness invocation itself, the PRISTINE sweeps
     reproduced BOTH committed baseline CSVs exactly (empty whole-row diffs), so
     a zero-change reading is a real measurement and not a driver that cannot
     see its probe.

### 5.1 The two byte movers, both explained

| mover | explanation |
|---|---|
| `default/YosysOldOr` | **the intended target.** Row is CMP_NOTEQUAL before and after, so the CSV sees nothing; measured with `tools/probe/r10oth3repro/mover.sh`: dump-diff **34,673 -> 34,669 content lines, 2,061 -> 2,060 hunks**, i.e. it moved TOWARD golden. HEAD 1 cleared. |
| `testflags/YosysOldOr` | **the SAME database counted twice** — md5 `392b0d3b16c9` patched / `e695a0b12197` pristine, IDENTICAL across the two modes, which re-verifies the brief's scoring note (the harness passes the same slang argv in both modes). One defect, two rows. |

`PartSelect4` (both modes) was a mover on the intermediate binary and is
**byte-identical on the final one** — same md5 `437f15b30dcf` as pristine, dump-diff
58 / 7 hunks on both. `Scoreboard default`, which r10oth3 proved intermittently
nondeterministic on every binary, did NOT differ in this run; I am not citing that
as evidence of anything in either direction, per the standing instruction never to
judge it from one run each.

### 5.2 Canaries, checked individually as rows, not as an aggregate

Every canary row equals the committed baseline — guaranteed by the empty whole-row
diffs, and spot-checked by name besides:
* **`InterfaceModPort`** (the `b33d11b` conversion): CMP_EQUAL both modes ✓
* **`BlackParrotComplex`** (the `ed653b4` conversion, the fragile one): CMP_EQUAL
  both modes, dump `differ`, and a NON-mover in the byte verifier — so the
  traversal-order hazard its CMP_EQUAL depends on was not disturbed ✓
* `YosysBigSimReed`, `YosysOldOpen`: CMP_EQUAL + `differ`, both **NON-movers**, so
  r10oth3's improvements to them are intact and this pass neither helped nor hurt ✓
* `InterfaceBinding` / `InterfaceModExp` / `BindHierPath` / `EnumConcat` /
  `LowMemPkg (default)`: CMP_EQUAL + dump **`match`** — the strongest control
  available, since any byte change there flips the dump column ✓
* `Earlgrey_0_1` (default CMP_NOTEQUAL / testflags SLANG_REJECT), `Scr1SvTests`,
  `BasicOh`, `ClassExtends`, `FuncStruct`, `FuncStructVal`, `FuncIoTypespec`,
  the `EvalFunc*` / `ParamFile*` / `Black*` families (52 rows), and the u2r
  canaries `paramod_genscope_child`, `issue326_packed_mem`, `assignment-pattern`,
  `hier_path`, `MultirangesStartNotFromZero`, `genscope_cells`,
  `genvar_loop_decl_3`: all unchanged ✓
* The four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) were never dispatched as targets; they are ordinary corpus rows and
  match the baseline ✓

### 5.3 Assets in this directory

| file | what it is |
|---|---|
| `rarm.sh` | the one-source arm driver r10oth3's residue R1 lacked: Surelog + ours, cmp with a column-0 head count, dump diff, and the constant table. **REQUIRES `SLANG_UHDM`**, guards `[ -f slang.uhdm ]` because `uhdm-cmp` exits 0 on a missing input, and passes `EXPECT` through to the instrument's positive control. |
| `replform.py` | prints `{view, module, edge path, span, constType, size, TAG:value, digit count, decompile}` for every constant DEFINITION. Carries an indentation stack and skips BACK-REFERENCE subtrees, whose payload header sits at the SAME indent as its edge — the trap that made the first cut of this file triple-count and mis-attribute. `--expect N` exits 3. |
| `rtab.sh` | joins the two sides of an `rarm.sh` workdir into one `***`-marked table and prints DIFFERING CELLS. Exits 3 if either side yields no rows. |
| `tsarm.py` | the HEAD-2 instrument: for every `param_assign`, the RHS constant AND the ACTUAL typespec behind its ref_typespec, with the typespec's range bounds resolved by indexing typespec DEFINITIONS (a dump prints a `vpiActual` payload as a bare header, so the bounds are not available at the reference site). Reports `AMBIG` rather than guessing when a (kind, span) key resolves to several bound pairs. |
| `headdump.sh` | dumps a golden/ours pair into one workdir with the head count and dump-diff size, for decoding a corpus head by ancestor walk. |
| `byteverify.sh` | the byte verifier: PATH-SET ASSERTION plus a comparator negative control (`SELFCHECK=1` must flag all but one path). |
| `r1_repl.v` | § srlgFoldNaturalWidth / § srlgConcatTruncDecompile: 22 replication/concat cells (widths 2..80, targets narrower/equal/wider, multi-bit replicands, x/z, concat-of-replication) plus the procedural, port-connection, parameter and variable-initializer CONTEXT controls, and the `d1/d2` cells that exposed residue R1. |
| `r2_paramts.v` | the REFUTED multi-declarator model for HEAD 2 (9 cells; PASS_CMP + DUMP_MATCH, i.e. it reproduces nothing). |
| `r3_setrange.v` | § readFoldUntypedSizedLitParam's gate arm: 12 read/type spellings plus the 5 `h*` cells that REFUTE the condition-op read model and expose residue R3's `h5_condpos`. |
| `r4_width.v` | the 6 cells that REFUTE the width model for PartSelect4 and pin the real gate on the READ SHAPE. |

`mover.sh` and `scoreboard_nondet.sh` were reused from `tools/probe/r10oth3repro/`
and `r10oth2repro/` unchanged.

### 5.4 Reading conventions, stated once
* Dump-diff figures are **content lines** = `grep -c '^[-+]'` on `diff -u` **minus
  the two file-header lines**. `rarm.sh` prints the header-inclusive number and
  says so on the line it prints.
* Row counts are CSV **lines minus one** for the header: 732 lines = 731 rows,
  1589 = 1588.
* Head counts are `grep -c '^LHS:'` at **column 0**.

Neither baseline CSV was rebuilt, edited, or included in the patch. `git stash`
was never used. Every probe wrote under `/tmp/r10oth4_*`.


## Corrections applied at integration by the master (pass verifier's C1-C9)

C1 and C2 are in place above and were the two the verifier marked MUST-APPLY. The
rest:

**C4 — mis-stated reach of a cited site.** `r1_repl.v` cites
`src/ModuleEmit.cpp:17246 tryFoldConst(*dt->getInitializer())` as the consumer the
`e1`-`e4` variable-initializer cells exercise. That line IS the call, but it is
gated at `ModuleEmit.cpp:17243-17245` on
`pat.kind == SimpleAssignmentPattern || StructuredAssignmentPattern ||
ReplicatedAssignmentPattern`, so `logic [19:0] v = {2'b10,2'b01};` cannot reach it.
The cells remain valid blast-radius controls (patched vs pristine = 0 rows changed)
but the citation does not describe the path they take.

**C5 — TWO ARM CELLS ARE LIVE DIFFERENCES RECORDED NOWHERE, because no instrument
prints them.** `rtab.sh` emits NO rows for `e1_varinit`-`e4_varinit_repl` or
`c2_child`. Read directly, both sides, and IDENTICAL on pristine — so pre-existing
and untouched by this patch, but newly measured and now filed:
* `e3_varinit_trunc` (`logic [3:0] v = {8'hF5, 8'h0F};`): golden's two operand
  constants carry `vpiSize:4`, ours `vpiSize:8`.
* `e4_varinit_repl` (`logic [19:0] v = {21{1'b1}};`): golden's ELAB `logic_var`
  carries `vpiExpr` = the **UNFOLDED** replication operation (opType 34 over
  `constant UINT:21 sz20`, opType 33 over `BIN:1 sz1`); ours emits the `logic_var`
  with **NO `vpiExpr` AT ALL**, plus an extra `vpiVisibility:1`. A **MISSING
  SUBTREE**, not a value difference — a different and larger class than the width
  residues around it.

**C7 — instrument limitation, stated where it matters.** `tsarm.py` reports `AMBIG`
on OUR side for 2 of `r3_setrange`'s 17 cells (`g1_ref`, `g7_twice` **DEF** rows)
and for 4 of `r4_width`'s DEF rows (`i2`-`i5`), because a `(kind, span)` key
resolves to several bound pairs. Flagging rather than guessing is the RIGHT design
— but "correct on 17 cells" must note that 2 of those DEF rows are UNRESOLVED on
our side. The ELAB rows, which are what the law is about, all resolve and all match.

**C9 — figures the verifier checked and found RIGHT**, recorded so nobody spends
time re-checking them: the `grep -c '^\_'` object totals are exactly golden 29922 /
ours 29919, and the first col-0 divergence is at golden index 273 (ours matches
through 272), so "diverges at index 272" is right read as LAST MATCHING INDEX. "24
objects carry that span" is exactly 24 dump lines including back-references — which
is precisely why the ancestor walk was needed. The "22 cells", "17 cells", "9 cells"
and "6 cells" counts are all accurate (`r3_setrange.v` has 18 modules because `g6`
is a `g6_child`/`g6_top` pair).

### THE GATE LESSON OF THIS PASS, and it is why the byte verifier is mandatory
An INTERMEDIATE binary passed the goldens, **BOTH row gates AND the uhdm2rtlil byte
verifier** while carrying an over-wide first cut (visible on `PartSelect4` as
58 -> 71 dump lines). **ONLY the surelog byte verifier caught it.** The row gates
are structurally blind inside the `CMP_EQUAL + dump differ` population, and u2r
alone was not enough. Both-corpora byte verification is not belt-and-braces; it is
the only instrument that saw this defect.

### AND THE m_visited HAZARD, THIRD PASS RUNNING
Arm `r4_width.v` is `PASS_CMP` with 0 heads on the BROKEN binary and on the fixed
one. `Compare`'s `m_visited` short-circuit hid the difference entirely; only
`diff -u` on the dumps and the corpus byte verifier saw it. Judge arms on the DUMP.
