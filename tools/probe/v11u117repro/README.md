# v11u117: adversarial verification of r11u117 (package-qualified member select flattens the package struct pattern)

**Verdict: ACCEPT-WITH-FIX.** L1 § pkgQualSelParamFlat117 fired on a parameter
default that Surelog never compiles, which is legal SV, and the result was
pristine-right → patched-wrong. The fix is § pkgQselOverride117v, in
`src/TypeEmit.cpp`, inside L1's liveness walk. Its switch is
`R11U117_OVR_OFF`, which restores the implementer's walk.

No row converts. `stamped_gen_param` goes from 11/1 to 64/1 in both modes,
with and without the fix.

## The break

The liveness walk noted every parameter of a live body, overridden or not.
When a port parameter (or an overridable body parameter) is overridden in every
live instance, Surelog never compiles its `pkg::NAME.member` default, and golden
keeps the tagged tree. L1 flattened it anyway.

Grid arms, each 85 contextual cells AWAY and 0 TO under the implementer's law:

| arm | shape |
|---|---|
| b01 | named override |
| b44 | ordered override |
| b46 | body `parameter` overridden |
| b49 | instance array |
| b50 | generate-loop instances |
| b52 | fpnew-like `UT = q2::IMPL.m[0]` default, always overridden |

The judge's head moved EARLIER in every one of them: from 68/1 or 100/1 (a
module-side head) to 11/1 (the package listing, `LHS: <null>` against our
nameless ref).

A second defect in the same walk made it dedupe on the shared module SYNTAX.
So a localparam that is live only in a later parameterization of a module was
missed. In b48, `P=0` is visited first and `P=1` second, and golden flattens.
This is under-application, pristine-equal.

## The fix, § pkgQselOverride117v

* The walk skips a `ParameterSymbol` whose `isOverridden()` is true.
* It dedupes on the instance BODY symbol instead of the syntax.

Measured with the fix:

* The six overridden-default arms are dump-identical to pristine.
* b48 moves 85 cells toward golden (TO), none away.
* b10 and b51 still flatten, in both instance orders.

## Drops

`drops117v.sh`, 104 arms (the implementer's 67 plus 37 here), 208 arm-forms,
compared as dump text. Every run has rc 0.

| switch | result |
|---|---|
| `R11U117_OFF` | pristine on 208/208 |
| `R11U117_OVR_OFF` | the implementer's law on 208/208, and 14 arm-forms (7 arms) away from the verified build |
| each of `QSEL_OFF`, `BITS_OFF`, `QSELREF_OFF` | moves its own subset |

## Break grid, per cell

Evidence is in `evidence/BRK117V.txt`. It uses r11u117repro's `grid117.sh`,
`dist117.sh` and `cells117.py`.

| build | TO | AWAY |
|---|---|---|
| implementer law | 2606 | 514 |
| verified | 2691 | 4 |

The 4 remaining AWAY cells are not moved-wrong. Pristine had no correct
counterpart for any of them:

* **b38, 1 cell.** The module-side reader of a whole doubled member. Pristine
  had a `hier_path`; now it is a constant whose decompile is `12'h56A`, where
  golden has `18'h56A`. This is the implementer's R1, on the expression ground.
* **b18, 1 cell.** The interface `param_assign` constant takes the
  param_assign as its parent, where golden takes the cont_assign. Pristine had a
  `hier_path`. The judge does not read the parent.
* **b06, 2 cells.** The member value is `'1`. L2 re-sizes the operand to 36
  but keeps the 12-bit mask `UINT:4095`. Surelog's `adjustUnsized` (Surelog
  `src/DesignCompile/CompileHelper.cpp:5091`) writes the 36-bit mask. The object
  is newly flat; pristine had the tagged tree.

Moved toward golden, each head advancing:

* b03, b04, b09, b17-b21, b25, b31, b34, b35, b37, b39, b40;
* b02 converts (36 → 0 lines);
* b33 and b24 move on existing roads, which is L2.

Other arms:

* b05 (a select inside another package's localparam) gets golden rc=4
  (EL0514). That is error recovery, not golden.
* b13, b14 and b15 (bit, signed and reg element typedefs) move TO. Their heads
  are earlier typespec heads and stay unchanged.

## Reproduced headline numbers (bit-for-bit)

* **Binaries.** Pristine `59c4a296…` equals the main tree. The implementer's law is `b49a4e60…`. The verified build is `d938af1f…`.
* **The implementer's grid** (67 arms):
  * cmp counts are identical for pristine and law;
  * per cell: g1 3458/0, g2 779/2 (k14 ×2, the R1 decompile), g3 0/0;
  * the verified build is byte-identical to the law on all 67 arms.
* **Controls.** 993 arms, 1986 arm-forms. SAME 1966, DIFF 20 (the implementer's set), RCDIFF 0, for both the law and the verified build. Law and verified are byte-identical on all of them.
* **Gates.** See `evidence/GATES117V.txt`. Goldens 23/0, and 0/23 with `/bin/false`. u2r reads 801/3/67 per mode and surelog 480/3 + 474/3 for all three binaries. Every row-join PASSes. byteverify finds u2r `stamped_gen_param` ×2 plus the UVM line-number class. Every pin holds.
* **The target row.** Next head, both modes, at `dut.sv` 44:31-44:54 (`gen_grps[0]` localparam `UT`): golden `constant 1'b0` size 1, ours `6'b010101` size 6.
* **R0 confirmed.** The golden generate structure is `gen_grps[0].u.g[0..2].inv` and `gen_grps[1].u.g[0].keep`, `g[1..2].inv`. slang's is `gen_grps[0]` all `keep` and `gen_grps[1]` all `inv`.

## Residues, ranked

* **R0.** stamped_gen_param cannot convert against the pinned producer. Surelog's bit-select garbage decides its generate structure.
* **R1.** The module-side reader of a whole flattened member (k14, b38, b18): the decompile and the missing typespec ref. This is on the expression ground (fenced).
* **R-new-a.** L2 does not re-apply `adjustUnsized` to an unbased `'1` member (b06). The fix site is TypeEmit (`pkgFlatSurelogBits117`), with a mask at the Surelog width.
* **R-new-b.** L2's clone replaces the operand in the vector and leaves the old constant in the serializer. When no reader shares that constant, it is an unreachable object. Neither the judge nor the dump sees it. This is the same hygiene class as face-3 R6.
* **Not landed by the implementer.** face 2 (a10, w04/w05, s10, f05) and face 3 (R4, R5 dropped, R6).

## Files

* `grid/b*`: 37 break arms.
* `drops117v.sh`: `OUT=… P=… L=… V=… drops117v.sh <grid dirs…>`.
* `evidence/`: the files cited above.
