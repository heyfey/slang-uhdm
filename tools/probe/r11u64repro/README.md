# r11u64 — § patFlatUnsizedMemberNoInstWidth64

**THE WIDTH AN UNSIZED PATTERN OPERAND TAKES ON THE `cont_assign` ROAD IS
`ExprEval::size` OF THE MEMBER TYPESPEC *WITH NO INSTANCE* — NOT THE MEMBER'S
ELABORATED WIDTH. A MEMBER WHOSE DECLARED BOUND NEEDS AN INSTANCE TO REDUCE
LENDS THE FILL ONE BIT, HOWEVER WIDE IT ELABORATES.**

Base `ecb98650`. One law, one override at one existing stamp, three golden
grids, one corpus mover pair, both mode columns scored, every gate green.

**`struct_member_cfg_width` CONVERTS in BOTH modes — `CMP_NOTEQUAL` ->
`CMP_EQUAL`, 0 cmp lines, 0 heads. u2r goes 786/18/67 -> `787 CMP_EQUAL / 17
CMP_NOTEQUAL / 67 SLANG_REJECT` in BOTH modes.** The rows to promote are quoted
in §7; **`results/*.csv` is UNTOUCHED by this pass.**

---

## 1. THE HEAD, RE-MEASURED AT `ecb98650`

r11u63's R0 named this head. Re-measured with a frozen pristine binary built in
this pass's own worktree (md5 `44a1172e38bf2ac198365a9b15aea810`, **the OPS pin,
byte-identical to the main tree at the base**), through the OFFICIAL `uhdm-cmp`
against each mode's own cached golden: **36 cmp lines, ONE head
(`grep -c '^LHS:'` = 1), in BOTH modes.**

```
LHS (golden)                                   RHS (pristine)
constant: , line:31:52, endln:31:54            constant: , line:31:52, endln:31:54
|vpiParent: \_operation: , line:31:24-31:64    |vpiParent: \_operation: , line:31:24-31:64
|vpiDecompile:0  |vpiSize:1                    |vpiDecompile:0  |vpiSize:64
|UINT:0          |vpiConstType:9               |UINT:0          |vpiConstType:9
```

`uhdm2rtlil/test/struct_member_cfg_width/dut.sv:31` is
`assign fu_data_i = '{operand_a: pa, operand_b: '0, tid: '0};` — an assignment
pattern as a `cont_assign` Rhs onto a struct VARIABLE whose type is a body
typedef with **parameter-dependent member bounds**
(`logic [CFG.XLEN-1:0] operand_a`, `logic [CFG.TID-1:0] tid`).
[evidence/HEAD.struct_member_cfg_width.testflags.pristine.cmp](evidence/HEAD.struct_member_cfg_width.testflags.pristine.cmp),
[evidence/HEAD.struct_member_cfg_width.default.pristine.cmp](evidence/HEAD.struct_member_cfg_width.default.pristine.cmp).

**Column 31:52-31:54 is `operand_b`'s `'0`, whose member is 64 bits wide.** The
head is the FIRST of TWO wrong operands: `tid`'s `'0` at 31:61-31:63 is ours
`vpiSize:3` against golden's `1`. Golden writes **1 on BOTH**, and the member
widths are 64 and 3 — so the answer to R0's own question ("is golden's `1` the
unsized literal's own size kept, or a member stamp?") is **NEITHER**: it is a
member stamp whose arithmetic came out as 1.

### ADVANCE vs CONVERT — I PREDICTED **ADVANCE**, AND THE PREDICTION WAS **WRONG**

Stated LOUDLY because it was wrong. Before the law I measured the witness's
order-blind whole-dump residue (both dumps workdir-normalised and sorted) and
read **123 golden-only / 528 ours-only lines**, including r11u62's six keyed
rows — the `typespec_member (XLEN)` / `(TID)` pairs on `cfg_pkg::cfg_t` and
their four `range` children, with their `constant` bounds at `6:34 / 6:37 /
6:53 / 6:56`. I sectioned the dump and confirmed those lines are NOT in the
`weaklyReferenced` tail; they are in the reachable part. I concluded ADVANCE.

**Measured after the law: the row CONVERTS.** `uhdm-cmp` returns **0 lines, 0
heads, rc=0 in both modes**
([evidence/HEAD.struct_member_cfg_width.testflags.law.cmp](evidence/HEAD.struct_member_cfg_width.testflags.law.cmp),
[evidence/HEAD.struct_member_cfg_width.default.law.cmp](evidence/HEAD.struct_member_cfg_width.default.law.cmp),
both empty files).

The lesson, recorded so the next pass does not repeat it: **a dump-visible
residue is not a Compare-visible one, and "not in the tail" does not make it
judge-visible.** `uhdm-cmp` walks the compared edges of each kind's generated
`Compare`; it never reads `VpiParent`, never reads `VpiFullName`/file/line, and
simply does not reach every object `uhdm-dump` prints from `AllObjects`. The
six keyed rows are real in the dump and invisible to the judge. Counting dump
lines to predict the judge over-counts, and it over-counted here.

---

## 2. THE PRODUCER, DECODED — AND THE TWO SIZERS THAT SIT ON ONE PATTERN

`UhdmWriter::writeCont_assign` (Surelog v1.87
`src/DesignCompile/UhdmWriter.cpp:2090`) takes the elaborated Rhs through, in
order, `reduceExpr`, `ExprEval::flattenPatternAssignments`,
`substituteAssignedValue`, `CompileHelper::expandPatternAssignment`,
`defaultPatternAssignment` and `reorderAssignmentPattern`. **TWO of those stamp
a width onto an operand, and they use DIFFERENT SIZERS.**

**(A) THE FLATTEN — NO INSTANCE.** `UHDM::ExprEval::flattenPatternAssignments`
(`~/git-repos/UHDM/templates/ExprEval.cpp:889-916`) is the ONLY place an
unsized member value is re-typed. Its gate is on the `tagged_pattern`'s
`Pattern()` alone — `constant && VpiSize() == -1` — and its width call passes a
**NULL instance**:

```cpp
if (c->VpiSize() == -1) {
  uint64_t uval = get_uvalue(invalidValue, c);
  if (uval == 1) {
    uint64_t size = ExprEval::size(fieldTypes[index], invalidValue,
                                   /*inst=*/nullptr, exp, true, true);
    uval = NumUtils::getMask(size);
    c->VpiValue("UINT:" + std::to_string(uval)); … c->VpiSize(size);
  } else if (uval == 0) {
    uint64_t size = ExprEval::size(fieldTypes[index], invalidValue,
                                   /*inst=*/nullptr, exp, true, true);
    c->VpiValue("UINT:0"); … c->VpiSize(size);
  }
}
```

`ExprEval::size` (`ExprEval.cpp:1271-1594`) starts a `logic_typespec` at ONE bit
and multiplies each range in by
`getValue(reduceExpr(bound, iv, inst, pexpr, muteError))`. With `inst ==
nullptr` a bound that needs the instance cannot be reduced, `getValue` of the
unreduced expression reads **0**, and `(0 - 0 + 1)` leaves the member **one bit
wide**. That is the whole law.

**(B) THE EXPAND — INSTANCE-AWARE.** `CompileHelper::expandPatternAssignment`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:5207`) sizes with
`Bits(member, invalidValue, component, compileDesign, Reduce::Yes,
/*instance=*/instance, …)` and DOES resolve `CFG.XLEN-1`. Its `adjustOpSize`
walk stops at the first operand its reduce cannot value (the landed
§ `patFlatAdjustStopsAtUnvaluable27`), so it stamps every leading valuable
operand plus the one that stopped it — and NOTHING after.

**THE TWO ARE SEPARATED INSIDE ONE PATTERN, IN GOLDEN, ON THE CORPUS WITNESS
ITSELF**: `operand_a`'s actual is `pa`, a `ref_obj` the reduce cannot value, so
the expand walk stamps it **64** (instance-aware) and stops; the two `'0`
beside it keep the flatten's **1** (no instance). Golden's own elaborated Rhs,
verbatim:

```
\_operation: , line:31:24, endln:31:64    |vpiOpType:75
  \_ref_obj: (work@tb.t.pa)     |vpiSize:64
  \_constant: , line:31:52      |vpiSize:1   |UINT:0  |vpiConstType:9
  \_constant: , line:31:61      |vpiSize:1   |UINT:0  |vpiConstType:9
```

**WHY OUR SIDE WAS WRONG, AND ONLY HERE.** Our flatten
([src/ExprEmit.cpp](../../../src/ExprEmit.cpp), § `patFlatUnsizedMemberWidth61`)
took its width from `surelogTsBits(fields9[i9]->getDeclaredType()->getType())` —
**slang's ELABORATED member width**, 64 and 3. That is the right answer at stamp
(B), which our own `patFlatAdjust` walk a few lines below still uses, and the
wrong answer at stamp (A). This pass does not add a stamp; it gives stamp (A)
the sizer its producer uses.

**WHAT THE JUDGE READS.** `constant::Compare`
(`~/git-repos/UHDM/build/generated/src/constant.cpp`) reads `VpiDecompile`,
`VpiSize`, `VpiValue` and `VpiConstType`; `VpiSize` is the field, and the
operand vector is reached through `operation::Compare`'s `Operands`.

---

## 3. THE GOLDEN GRID (Surelog v1.87 = golden; every arm's rc recorded)

Three grids, `surelog -parse -nobuiltin -nocache -sv -d uhdm` **rc=0, 0 `[ERR`**
on every one, both our binaries rc=0 on every one. Scored by the SHAPE LISTER
[pgrid64.cpp](pgrid64.cpp), which keys every `vpiAssignmentPatternOp` by
(elaborated owner, carrier kind + the carrier's own name, written line:col) and
prints the COMPARE-VISIBLE operand vector — per operand the UHDM kind,
`VpiSize`, `VpiConstType` and `VpiValue`. **DEF and ELAB rows are BOTH scored**
(the owner string separates them) and the payloads per key are a SORTED MULTISET
(see §6's instrument trap).
**CALIBRATION golden-vs-golden FIRST on every grid: g1 20 rows 0 DIFF, g2 18
rows 0 DIFF, g3 19 rows 0 DIFF.**

### g1 — [grid/g1_width64.sv](grid/g1_width64.sv), 20 rows: MEMBER WIDTH CLASSES x UNSIZED FORMS

Operand[0] of every pattern is deliberately UNVALUABLE (a port part-select), so
stamp (B) stops there and stamp (A)'s width is what the rest of the vector
carries. Golden first.

| cell | member | fill | golden | pristine | law |
|---|---|---|---|---|---|
| u1 | `logic [V-1:0]`, V a module PARAMETER | `'1` | **UINT:1 sz 1** | UINT:7 sz 3 | **converts** |
| u1 | same | `'x` | **UINT:0 sz 1** | sz 3 | **converts** |
| u1 | same | `'z` | **UINT:0 sz 1** | sz 3 | **converts** |
| u1 | operand[0] `pa[V-1:0]` | — | sz 3 (stamp B) | sz 3 | same |
| u2 | `logic [7:0]` | `'1` | UINT:255 sz 8 | same | same |
| u2 | `logic` (no range) | `'0` | sz 1 | same | same |
| u2 | `int` | `'0` | sz 32 | same | same |
| **u3** | **`logic [q64::CFG.XLEN-1:0]`, a `hier_path` bound — THE CORPUS WITNESS'S OWN** | `'0` | **sz 1** beside operand[0] at **sz 64** | sz 3 | **converts** |
| u4 | `logic [LP-1:0]`, LP a module LOCALPARAM | `'0` | **sz 1** | sz 6 | **converts** |
| u4 | `logic [q64::PW-1:0]`, a PACKAGE localparam | `'0` | sz 5 | sz 5 | same |
| u5 | `logic [$bits(q64::sub_t)-1:0]` | `'0` | sz 8 | sz 8 | same (**the fence that this cell built**) |
| u6 | `logic [1:0][7:0]` packed array | `'0` | sz 16 | same | same |
| u6 | a NESTED struct member | `'0` | sz 8 | same | same |
| **u7** | **`logic [V-1:0][7:0]`, symbolic OUTER range** | `'0` | **sz 8** (elem 8 x the lost range's 1) | sz 16 | **converts** |
| u8 | `logic [V-1:0]` | `3'b0` SIZED | **BIN:0 sz 3 UNTOUCHED** | same | same |
| u8 | `logic [3+1:0]` literal arithmetic | `'0` | sz 5 | sz 5 | same |
| **u9** | `logic [V-1:0]`, **operand[0] VALUABLE (`3'd2`)** | `'0` | **sz 3** — stamp (B) walks on and overwrites | sz 3 | same |
| u10 | `logic [V-1:0]` via `default: '0` | — | **sz 1** | sz 3 | **converts** |

**Pristine SAME 14/20 -> law SAME 19/20, five cells CONVERT, 0 MOVED-WRONG, 0
AWAY-GOLDEN.** The one remaining DIFF is u9's operand[0], `3'd2` as golden's
`DEC:2` `3'd2` against our `UINT:2` `2` — a PRE-EXISTING based-decimal encoding
residue, **byte-identical pristine and law** and a different family's road.
[evidence/GRID.g1.calib.txt](evidence/GRID.g1.calib.txt),
[evidence/GRID.g1.pristine.txt](evidence/GRID.g1.pristine.txt),
[evidence/GRID.g1.law.txt](evidence/GRID.g1.law.txt).

**u5 IS THE CELL THAT BUILT THE FENCE, and it was caught by the grid BEFORE any
sweep.** Golden FOLDS `$bits(q64::sub_t)-1` while building the typespec and
emits `8 - 1`, two constants, so its own no-instance read answers 8. OUR
typespec keeps a `sys_func_call ($bits)` in that bound — a PRE-EXISTING
divergence of the typespec itself. A first build of this law read our tree,
called the call unvaluable and moved u5 from pristine-RIGHT (8) to
patched-WRONG (1). The fence below is that measurement.

### g2 — [grid/g2_fence64.sv](grid/g2_fence64.sv), 18 rows: THE NEIGHBOUR ROADS AND THE BAIL FACES

Every cell holds a symbolic-bound member and varies only the carrier/scope.

| cell | shape | golden | pristine | law |
|---|---|---|---|---|
| **f1** | **the PARAMETER road — a struct parameter's pattern initializer, NAMED setter AND `default:` fill** | operands **sz 3** (the instance-aware width — pass 60's law) | same | **same: THIS LAW DOES NOT REACH IT** |
| f2 | an `always_comb` assignment | (no flattened elab op) | same | same |
| **f3** | an EXPLICIT CAST around the pattern | golden keeps TAGGED operands | we flatten, fill stays `sz -1` | unchanged (**R1**) |
| **f4** | a **SIGNED** symbolic member | **sz 1** | sz 3 | **converts — no signed bail here** |
| **f5** | a **65-BIT** symbolic member | **sz 1** | sz 65 | **converts — the >64 bail never engages, because the no-instance read makes it 1 bit** |
| **f6** | inside a GENERATE block | **sz 1** | sz 3 | **converts** |
| **f7** | a cont_assign feeding a port | **sz 1** | sz 3 | **converts** |
| f8 | an UNPACKED struct DECLARATION INITIALIZER | golden makes a `cont_assign(dv)` with operands `[3'd1, UINT:0 sz 3]` | we carry a `struct_var(dv)` Expr with the fill at `sz -1` | unchanged (**R2**) |
| **f9** | a module NEVER INSTANTIATED (the DEF view alone) | **sz 1** | sz 3 | **converts** |
| f10 | a package-localparam bound BESIDE a module-parameter one in ONE struct | `b` **sz 1**, `c` sz 5 | `b` sz 3, `c` sz 5 | **`b` converts, `c` untouched** |

**Pristine SAME 11/18 -> law SAME 16/18, five cells CONVERT, 0 MOVED-WRONG, 0
AWAY-GOLDEN.** The two that remain (f3, f8) are byte-identical pristine and law.
[evidence/GRID.g2.pristine.txt](evidence/GRID.g2.pristine.txt),
[evidence/GRID.g2.law.txt](evidence/GRID.g2.law.txt).

**f4 AND f5 ARE THE BRIEF'S QUESTION ANSWERED BY MEASUREMENT, NOT BY
INHERITANCE.** Pass 60's bail faces (explicit cast, unknown bit, signed
negative, >64 bit) were measured at the PARAMETER road. Here the signed member
and the 65-bit member are BOTH claimed by golden at width 1, the unknown fills
`'x`/`'z` are claimed too (g1 u1), and only the explicit CAST declines — and it
declines by keeping the TAGGED tree, which is a different mechanism and a
pre-existing residue on our side either way. **The same bails do NOT govern
here, and assuming they did would have fenced away four converting cells.**

### g3 — [grid/g3_road64.sv](grid/g3_road64.sv), 19 rows: THE ROAD BOUNDARY WITH PASS 60

| cell | shape | golden | pristine | law |
|---|---|---|---|---|
| h1 | an **UNPACKED** struct parameter, named setter and `default:` fill | sz 3 | same | **same — not reached** |
| h2 | a **PACKED** struct parameter, both forms | sz 3 | same | **same — not reached** |
| **h3** | a struct **NET** Lhs (`wire t_t`) | sz 1 | sz 3 | **converts** |
| **h4** | the witness's shape: a `hier_path` bound, struct handed on through a TYPE PARAMETER | sz 1 | sz 6 | **converts** |
| h5 | inside an INTERFACE | golden's elab copy keeps TAGGED operands; we emit no elab copy | same | unchanged (**R3**) |
| **h6** | an INSTANCE ARRAY, two elaborated copies | sz 1 on both | sz 3 on both | **both convert** |
| **h7** | **TWO INSTANCES, V=3 and V=7, of ONE written pattern** | **sz 1 on BOTH**, beside operand[0] at sz 3 and sz 7 | sz 3 and sz 7 | **both convert** |

**Pristine SAME 12/19 -> law SAME 18/19 with DIFF 0, six cells CONVERT, 0
MOVED-WRONG, 0 AWAY-GOLDEN.**

**h7 IS THE LAW'S SIGNATURE.** One written pattern, two instances with different
parameter values: golden's stamp (B) writes the per-instance widths 3 and 7 onto
operand[0], and golden's stamp (A) writes **1 on both** fills — because the
no-instance read is a property of the TYPESPEC, not of the instance. A law that
modelled stamp (A) with any instance-aware width could not produce that pair.

**COMBINED: 57 rows, pristine 37 SAME -> law 53 SAME, +16, DIFF 18 -> 2,
0 MOVED-WRONG, 0 AWAY-GOLDEN.**

---

## 4. WHAT WAS WRITTEN

One override at one existing stamp, in one file. **No line of behaviour
removed**; surface = [src/ExprEmit.cpp](../../../src/ExprEmit.cpp) +
`tools/probe/r11u64repro/`.

* `noInstTsBits64` and its two helpers, beside `surelogTsBits` — `ExprEval::size`
  transcribed over an EMITTED typespec for the kinds a struct member can carry
  (`logic`/`bit`/`int` with their range rule, `byte`/`shortint`/`longint`/
  `real`/`shortreal`, `enum` through its base, `struct` as a sum, `union` as a
  max, packed and unpacked array through their element). Any other kind BAILS.
* In § `patFlatUnsizedMemberWidth61`'s stamp, one gated override of `fw9`.
* The `patFlatAdjust` walk below it (stamp B) is **untouched** and keeps
  `surelogTsBits`.

### The fences, each a measured golden cell

| # | shape | why declined |
|---|---|---|
| F1 | a bound that IS a `constant` | valued exactly as `getValue` values it; the answer equals the pristine one, so nothing moves (g1 u2, u6) |
| F2 | a bound that is constant-FOLDABLE but not a bare constant | `reduceExpr` folds a tree of constants with no instance at all — g1 u4's `5 - 1` (a package localparam Surelog already folded), u5's `8 - 1`, u8's `3 + 1`. The law DECLINES and keeps `surelogTsBits` |
| F3 | a bound holding any node outside `{constant, operation, ref_obj, hier_path}` | g1 u5: our tree keeps a `sys_func_call` where golden's is folded constants. Declining is the only honest answer when the two producers' bound trees are not the same shape |
| F4 | a typespec kind the transcription does not cover, a null member typespec, a width <= 0 or > 4096 | bails to `surelogTsBits`, which is the pre-existing answer |
| F5 | a SIZED literal member value | `VpiSize() == -1` is the producer's own gate; g1 u8's `3'b0` is untouched on both sides |
| F6 | the operand the `patFlatAdjust` walk REACHES | stamp (B) runs after stamp (A) and overwrites it with the instance-aware width — g1 u9 keeps sz 3 under the law, unchanged |

**NO SIGNED FENCE, NO >64 FENCE, NO GENERATE FENCE, NO DEF/ELAB FENCE** — g2
f4, f5, f6, f9 are golden cells that say so, and every one of them CONVERTS.

---

## 5. CENSUS, PREDICTION AND GATES

### The a-priori mover prediction, from PRISTINE DATABASES, and its positive control

[predict64.cpp](predict64.cpp) opens PRISTINE databases only — it runs no binary
and reads no source — and carries **the law's own predicate, transcribed
byte-for-byte** from `src/ExprEmit.cpp`, so the prediction and the emitter
cannot disagree. A database is a CANDIDATE when it holds BOTH a
`typespec_member` the law could re-size (unvaluable-without-an-instance and not
bailed) AND an assignment-pattern operation carrying a `constant` operand. It is
a **SUPERSET three ways**: it ignores whether the operand came from an UNSIZED
literal, whether the pattern targets THAT struct, and whether the carrier is the
one the law fires on. It cannot MISS, because the law re-sizes no operand whose
member typespec the pristine binary did not already emit, and it touches no
typespec — [evidence/TSBITS.g1.golden.txt](evidence/TSBITS.g1.golden.txt) and
[evidence/TSBITS.g1.pristine.txt](evidence/TSBITS.g1.pristine.txt) are
**byte-identical files**: golden and our pristine read the same 18 SYM members
and the same per-member no-instance widths out of g1.

*Predicted, BEFORE the patched sweeps:*
**u2r — at most 18 arms of 1608** (9 tests x 2 modes):
`BitSelectOfParameterPassedToSubmoduleInGenFor`,
`BitSelectOfParameterPassedToSubmoduleInGenForOfSubmodule`,
`cva6_struct_param_field`, `iface_struct_field_param_width`,
`iface_zero_width_field`, `ModuleInstantiationAndIndirectParams`,
`struct_member_cfg_width`, `TypedefStructParamWithRangeInSubmodule`,
`UnionCustomTypeMultirange`
([evidence/PREDICT.u2r.txt](evidence/PREDICT.u2r.txt)).
**surelog — at most 20 arms of 960** (10 tests x 2 modes):
`AssignmentPatternInAssignmentPattern`, `BlackBePipeInt`, **`Earlgrey_0_1`**,
`GenScopeHierPath`, `IndexedSelectHex`, `MultiConcatValueSize`,
`ParamElabMulti`, `StructParamFieldRange`, `StructParamFuncBodyFieldCompare`,
`StructParamPatternInitCast`
([evidence/PREDICT.sl.txt](evidence/PREDICT.sl.txt)).
The other **1590 u2r + 940 surelog arms are predicted byte-identical**, and that
is not a vacuous zero: the same scanner, on the same corpora, names the 38 arms
above by name and prints their SYM members.

*Positive control on the grids:* the predictor names g1, g2 and g3 all
CANDIDATE and lists exactly the SYM members the grid moves — and **does NOT list
`t_t.c@50` (the folded `q64::PW-1`), `t_t.b@60` (the `$bits` call) or `t_t.k@94`
(`3+1`)**, the three cells the fences decline. The predicate under test is the
one that ships.

*Measured:* **u2r MOVERS 2 / 1608 — `struct_member_cfg_width`, both modes, and
nothing else.** **surelog MOVERS 6 / 960 — `MiniAmiq` (both modes), `SeqDriver`
(both modes), `Scoreboard`/default, `SimpleUVM`/default: the UVM family, NONE of
them a predicted candidate, and ALL SIX CONVICTED AS THE COIN.** `Earlgrey_0_1`
— a predicted candidate and a hard byte pin — did **not** move in either mode.

### The coin, convicted order-blind, with a positive control

Every one of the six is the OPS-documented class: an order-blind sorted-dump
diff of **0 or 4 lines**, and the four are a `UINT:`/`vpiDecompile` **LINE
NUMBER** pair moving in BOTH directions.

```
MiniAmiq/default    4 lines   UINT:790  <-> UINT:1012
SeqDriver/default   4 lines   UINT:1032 <-> UINT:1355
SimpleUVM/default   4 lines   UINT:0    <-> UINT:839
MiniAmiq/testflags  4 lines   UINT:1427 <-> UINT:1261
SeqDriver/testflags 4 lines   UINT:535  <-> UINT:811
Scoreboard/default  0 lines   (the 0-line order draw)
```

*The positive control, run on `SeqDriver` from its own source directory:*

```
PRISTINE binary, three runs      -> 2fb39f8b4130, 2fb39f8b4130, 2fb39f8b4130
LAW      binary, run 1           -> 2fb39f8b4130   (IDENTICAL to pristine)
LAW      binary, run 2           -> e39c4a9d4462   (a FOURTH hash)
PRISTINE binary, in the sweep    -> bcaad8df4f0e
LAW      binary, in the sweep    -> 3c746d5ab065
```

**The law binary reproduced the pristine binary's database EXACTLY, then drew a
different hash from itself on the next run.** Four distinct hashes across the
two binaries with no correlation to the code change. All five UVM-family rows
stay `CMP_EQUAL` and every rowhead reads `0 lines 0 heads`.

### Mover attribution (order-blind: `uhdm-dump` | workdir-normalised | sort)

**EXACTLY TWO LINES CHANGE PER DATABASE, and they are the law's two operands:**

```
testflags   < |vpiSize:3        default   < |vpiSize:3
            < |vpiSize:64                 < |vpiSize:64
            > |vpiSize:1                  > |vpiSize:1
            > |vpiSize:1                  > |vpiSize:1
```

`64 -> 1` is `operand_b`'s `'0` (the head) and `3 -> 1` is `tid`'s `'0` (the
second wrong operand). Nothing else moves.
[evidence/MOVERS.attribution.txt](evidence/MOVERS.attribution.txt).
The byte SIZE delta is **zero** (20241 -> 20241 testflags, 25273 -> 25273
default) because `VpiSize` is a serialized int32, not a string — so the MOVER
RULE's "nonzero proves real" does not apply and the hash change is carried by
the named diff instead, with the official cmp going **36 lines -> 0** in both
modes as the arbiter. No 4096-multiple is involved, so the page-boundary
positive control is not in play.

### The keyed census, with the SHAPE LISTER

[census64.sh](census64.sh) runs `pgrid64` over the predicted arm set,
**calibration golden-vs-golden FIRST on every arm**, reading each arm's golden
out of its OWN `cmds.txt`.

* **u2r, all 9 candidate tests, BOTH modes**
  ([evidence/CENSUS.u2r.txt](evidence/CENSUS.u2r.txt)):
  **9 scored per mode, calibration 0 DIFF on every one, TO-GOLDEN 1,
  AWAY-GOLDEN 0, UNCHANGED 8** in each mode. The one is
  `struct_member_cfg_width`, PRIS-DIFF 1 -> LAW-DIFF **0**.
* **surelog, all 10 candidate tests, BOTH modes**
  ([evidence/CENSUS.sl.txt](evidence/CENSUS.sl.txt)):
  **10 scored per mode, calibration 0 DIFF on every one, TO-GOLDEN 0,
  AWAY-GOLDEN 0, UNCHANGED 10** in each mode — `Earlgrey_0_1` at 525 keyed rows
  testflags / 516 default, `BlackBePipeInt` at 198, each with its PRIS and LAW
  columns identical.
* Shape listers: [evidence/SHAPES.g1.golden.txt](evidence/SHAPES.g1.golden.txt),
  g2, g3.

### The gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `44a1172e38bf2ac198365a9b15aea810` — **the OPS pin, byte-identical to the main tree at `ecb98650`**; law `8090e35ab1057cc7d4b3e0118a39ce47`. `ParamEmit.cpp` is untouched, so its `__LINE__` sensitivity is not in play |
| (2) goldens | law `PASS=23 FAIL=0`; pristine `PASS=23 FAIL=0`; `SLANG_UHDM=/bin/false` -> `PASS=0 FAIL=23` |
| (3) u2r both modes | **`787 CMP_EQUAL / 17 CMP_NOTEQUAL / 67 SLANG_REJECT` x2**. Joined against `results/golden_uhdm2rtlil.csv` (BOTH modes, 1742 rows, 0 missing, 0 extra): **exactly 2 differing rows, both the claimed conversion**, quoted in §7. `gate_uhdm2rtlil.csv`: the same one row. Law-vs-my-own-pristine: the same rows, both modes |
| (4) surelog `--mode both` | `474/9` default + `469/8` testflags — **identical to `results/golden_surelog.csv` and to my own pristine sweep**, status AND dump histograms. Law-vs-baseline and law-vs-pristine differ in exactly **two** row-sides each: the `SURELOG_FAIL` detail strings that quote the WORKDIR PATH (`LowMemLib`, `LowMemPkg`) |
| (5) byteverify SELFCHECK=1 | u2r `MOVERS 2/1608`, SELFCHECK `1607/1608` flagged; surelog `MOVERS 6/960`, SELFCHECK `959/960`; `PATH_SETS_IDENTICAL` both |
| cmds.txt audit | u2r **1742/1742** name the frozen binary by PATH; surelog **1531/1581**, and the other 50 hold NO `slang:` line at all (surelog produced no golden, so slang was never run) — no other binary is named anywhere |
| canaries | surelog `ok=52 changed=0 absent=0`, u2r `ok=8 changed=0 absent=0` — **identical to my own pristine sweep's reading on both corpora** |
| ctcan2 | PASS x2 (`ok=58` surelog, `ok=1` u2r, `changed=0`) |
| canaudit | `audited=29 UNCOVERED=0 FENCE-BREACH=0`; this pass's `canaries.sh`/`ctcan2.sh`/`canaudit.sh` are byte-IDENTICAL to `r10uvm221repro`'s |
| rowheads | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg / Earlgrey_0_1 all `0 lines 0 heads`; Rggen `64 lines 1 head` (unchanged). SKIP-NOFILE on Scoreboard/tf and Rggen/tf as expected |
| protected DBs | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`, `Earlgrey_0_1` default `8bdf25272e08` / testflags `59d0ee6d10c3`, `BlackParrotComplex`, `YosysOldOr` — **every one byte-identical pristine to law, every hard pin at its OPS value** |
| UVM family | BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard all still `CMP_EQUAL` (Scoreboard/testflags `SLANG_REJECT`, its baseline state) |
| landed conversions | `iface_zero_width_field`, `indexed_partsel_array`, `struct_param_pattern_packing` all `CMP_EQUAL` in both modes |
| `results/*.csv` | **UNTOUCHED** |

---

## 6. INSTRUMENT TRAPS MET AND FIXED (both caught by a calibration, not by luck)

* **The multiset trap, caught by golden-vs-golden.** `pgrid64`'s first version
  disambiguated two op75 sharing a key with a positional `#N` suffix.
  `Serializer::AllObjects` does NOT hand objects back in a stable order across
  two `Restore` calls of the SAME FILE, so `iface_zero_width_field` read **DIFF
  2 golden-against-itself**. Fixed by collecting a SORTED MULTISET per key. Every
  number in this README was produced after the fix, and every grid and census
  arm carries its own calibration.
* **The orphan trap.** Both producers leave op75 objects in the serializer whose
  operand vector was moved onto another op; the judge never sees them, and they
  made a first scoring read `ONLY-OURS 2` on a two-row file. `pgrid64` scores an
  op75 only when its carrier actually points AT it — the same edge `uhdm-cmp`
  walks.

---

## 7. THE CONVERSION — THE ROWS TO PROMOTE, QUOTED

**`struct_member_cfg_width` CONVERTS IN BOTH MODES.** `results/*.csv` is
untouched by this pass; the master promotes.

`results/golden_uhdm2rtlil.csv` (holds BOTH modes):

```
OLD: struct_member_cfg_width,default,CMP_NOTEQUAL,decompile:,,
NEW: struct_member_cfg_width,default,CMP_EQUAL,,,differ
OLD: struct_member_cfg_width,testflags,CMP_NOTEQUAL,decompile:,,
NEW: struct_member_cfg_width,testflags,CMP_EQUAL,,,differ
```

`results/gate_uhdm2rtlil.csv` (the testflags gate):

```
OLD: struct_member_cfg_width,testflags,CMP_NOTEQUAL,decompile:,,
NEW: struct_member_cfg_width,testflags,CMP_EQUAL,,,differ
```

Scoreboard: **u2r 786/18/67 -> 787/17/67 in BOTH modes**; surelog unchanged at
474/9 + 469/8. `CMP_EQUAL` with a `differ` dump column is an ordinary state —
504 of the committed baseline's `CMP_EQUAL` rows already carry it.

---

## 8. RESIDUES, and R0

* **R0 — THE NEXT HEAD IS NOT ON THIS ROW.** `struct_member_cfg_width` is
  judge-equal in both modes. The nearest unfinished work this pass measured, in
  rank order:
  * **R0a — the EXPLICIT-CAST pattern Rhs keeps its TAGGED tree in golden**
    (g2 f3). `assign v = t_t'('{…})`: golden's elaborated Rhs is two
    `tagged_pattern` operands and ours is a flattened vector whose fill is still
    `VpiSize -1`. Pre-existing, byte-identical pristine and law, and it composes
    with pass 55's cast fence — the cast is where BOTH the substitution and the
    flatten decline. No corpus row in either census holds it today; it needs its
    own grid and its own boundary.
  * **R0b — the based-DECIMAL operand encoding** (g1 u9): golden `DEC:2`
    decompile `3'd2` where we write `UINT:2` decompile `2`, on an operand the
    adjustOpSize walk stamped. Adjacent to § `patFlatEnumDecompileRenderV99`,
    which already fixed the enum half of the same rendering question.

* **R1 — THE EXPLICIT CAST (g2 f3).** As R0a.

* **R2 — THE UNPACKED DECLARATION INITIALIZER (g2 f8).** Golden models
  `u_t dv = '{a: 3'd1, b: '0};` as a `cont_assign` whose operands are
  `[3'd1, UINT:0 sz 3]` — the INSTANCE-AWARE width, because operand[0] is
  valuable and stamp (B) walks on. We carry it as the `struct_var`'s own Expr
  with the fill at `VpiSize -1`. This is the carrier r10earl61 fenced out of the
  named half and recorded as having no golden witness; **it now HAS one**, and
  the witness says the carrier itself is what differs, not the width. Untouched.

* **R3 — THE INTERFACE'S ELABORATED cont_assign (g3 h5).** Golden emits an
  elaborated copy under `work@tb.u5.i` carrying TAGGED operands; we emit none.
  Pre-existing, unchanged, a different family.

* **R4 — A GOLDEN-FOLDED / OURS-SYMBOLIC MEMBER BOUND, on the PARAMETER-carrier
  typespec copies** ([evidence/TSBITS.g2.golden-vs-ours.diff.txt](evidence/TSBITS.g2.golden-vs-ours.diff.txt),
  g3's too). On g2/g3 the ELABORATED parameter copies of a struct typespec carry
  FOLDED member bounds in golden (`nbits=3`) and SYMBOLIC ones in ours
  (`nbits=1 SYM`). It costs nothing today — both sides reach width 3 on that
  road, by different routes, and the grids score those cells SAME on both
  binaries — but it is the shape that could one day meet this law's stamp and
  read 1 where golden reads the folded width. Three grids and 38 census arms
  found no such cell; it is RANKED and recorded, not taken.

---

## 9. REPRODUCING

```bash
# the instruments
cd <scratch> && cp <repo>/tools/probe/r11u64repro/{pgrid64.cpp,tsbits64.cpp,predict64.cpp,census64.sh} .
for f in pgrid64 tsbits64 predict64; do
  g++ -O1 -std=c++17 $f.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
      -luhdm -lcapnp -lkj -o $f; done

# the grids (CALIBRATE golden-vs-golden FIRST; every arm's rc recorded)
cp <repo>/tools/probe/r11u64repro/grid/*.sv .
for g in g1_width64 g2_fence64 g3_road64; do
  mkdir -p run_$g && (cd run_$g && cp ../$g.sv . && \
    ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv -d uhdm $g.sv && \
    cp slpp_all/surelog.uhdm ../$g.golden.uhdm)
  $PRIS_BIN $g.sv --single-unit -o $g.pris.uhdm
  $LAW_BIN  $g.sv --single-unit -o $g.law.uhdm
  ./pgrid64 --rows $g.golden.uhdm $g.golden.uhdm | tail -1   # CALIBRATION: DIFF 0
  ./pgrid64 $g.golden.uhdm $g.pris.uhdm
  ./pgrid64 $g.golden.uhdm $g.law.uhdm
  ./pgrid64 $g.golden.uhdm                                   # the SHAPE LISTER
  ./tsbits64 $g.golden.uhdm; ./tsbits64 $g.pris.uhdm         # the no-instance widths
done

# the a-priori prediction (PRISTINE databases only; runs no binary)
for m in testflags default; do for d in <prisWorkdir>/$m/*/; do
  ./predict64 --tag="$m/$(basename $d)" $d/slang.uhdm; done; done | grep CANDIDATE

# the keyed census, both modes
bash census64.sh <prisWorkdir> <lawWorkdir> <mode> names.txt ./pgrid64
```

An arm whose slang compile fails teaches error recovery, not golden: g1's ENUM
cell (`e: '0` on an `e_t` member, slang rc=3 "no implicit conversion from
'bit[0:0]' to 'e_t'") was REMOVED for that reason and the removal is recorded in
[grid/g1_width64.sv](grid/g1_width64.sv).
