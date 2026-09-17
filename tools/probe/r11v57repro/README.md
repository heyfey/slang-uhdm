# r11v57 — adversarial verification of r11u57 (`§ bitsOfTypeParamInExpr57`)

Base `9cc6957a` (matrix-1.87). Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`0445655ee7`, the golden producer), uhdm2rtlil v0.68.

**VERDICT: ACCEPT WITH FIX.** The decoded law is correct and independently
reproduced against real v1.87 goldens; the gate as submitted was one face too
wide and regressed a shape the pristine binary had right. The fix is
`§ assignPatternInExpr57`, a pure reduction of the widened gate. Ship
`/tmp/r11u57.verified.patch`.

## What was reproduced bit-for-bit

Both binaries were built by the verifier from its own fresh `9cc6957a`
worktrees (`/tmp/wt_v11u57pris`, `/tmp/wt_v11u57`) and frozen `555`:

| binary | md5 | note |
|---|---|---|
| pristine | `a5c8b3e869a33e96fb9bf481ee4eb415` | byte-identical to the main tree at the base |
| implementer's law | `bf7b1b3841621ffe005194bcd9baaf19` | the claimed md5, reproduced exactly |
| shipped (law + fix) | `2fa585e9ec9f6ccea23c8fee77b6fa7f` | |

Reproduced independently: both witness heads and their cmp line counts
(30 / 23, `packed_array_var @8:22` and `logic_typespec @32:17 / RHS: <null>`);
the KEEP-COUNT cells (ELAB 4/2 `KEEP-COUNT-DIFFERS` -> 4/4 `OK`);
the whole of `e8_reduce57`'s reachability table, cell for cell; the Surelog
producer citations (`compileBits` at `CompileExpression.cpp:4686`, the
self-upgrade verbatim at `:4750-4756`, `reduce` a by-value parameter, the
two-map lookup at `:4534`/`:4541-4544`); and every gate. See
[evidence/GATES.txt](evidence/GATES.txt).

## The regression, and why the pass's own scorer missed it

[evidence/REGRESSION.txt](evidence/REGRESSION.txt). On
`grid/b1_aggpat57`, a localparam whose initializer is an ASSIGNMENT PATTERN
holding the buried call, the ungated law drops the operation's `Typespec`
(golden and the pristine binary both carry it) and wraps the operands in
`tagged_pattern` + `string_typespec` objects golden does not carry. `uhdm-cmp`
gives it a NEW head EARLIER in the walk — `ref_typespec … / RHS: <null>` — on
a field the pristine binary had right, **while the cmp line count FALLS from
25 to 8 and the order-blind residue falls too**. A count-based direction
scorer reads that arm as progress; only the head and set containment name it.

Cause: an assignment-pattern initializer never reaches the elaborated fold
chain's constant arm. The generic tail at the end of `emitParameters` emits
it, and the pattern machinery downstream of that emission is what stamps the
`Typespec` and substitutes each element. Setting `rhs` at the r11u57 hook
preempts that tail.

## The fix

`src/EmitHelpers.h`, `§ assignPatternInExpr57`: `bitsOfTypeParamInExpr57`
returns null when a `SimpleAssignmentPattern` / `StructuredAssignmentPattern` /
`ReplicatedAssignmentPattern` stands anywhere in the claimed expression. It is
a pure REDUCTION of the widened gate, so it cannot reach r11u53's landed
whole-Rhs arm (a `$bits` call is not a pattern) nor either corpus witness
(`(1 << $bits(<type param>))` is an operation). Measured after: `b1_aggpat57`
back to the pristine head and line count with `A1`/`A3` byte-restored, and the
pass loses NOTHING — `e1..e8` cmp line counts are identical under the ungated
law and the fix, and `byteverify` fix-vs-ungated over the whole uhdm2rtlil
corpus reads `MOVERS 0 / 1608`.

## The break grid — 10 arms, all `golden_rc=0 ours_rc=0` on all three binaries

`grid/b1..b10`, scored with the official judge in
[evidence/BREAKGRID.txt](evidence/BREAKGRID.txt). Beyond b1 the law survives
every face: assignment patterns (b1, the regression), explicit/sized/sign
casts at the root (b2 — one cell now matches golden exactly), operand-dropping
shapes (b3), user-function and system-call arguments (b4), a conditional whose
condition is an OVERRIDDEN value parameter so `knownSide()` answers
differently PER INSTANCE and Surelog's per-instance reduce agrees (b5), class
localparams (b6, out of reach, unchanged), a call inside another `$bits`'s
DataType argument (b7, unchanged), reducible sibling operands (b8 — the new
head IS the implementer's residue R1, confirmed), a four-shape conditional
chain against the fence (b9 — two matches, two conservative refusals, no
regression), and an override ACTUAL holding the call (b10, unchanged).

Run: `GRID=<this dir>/grid bash ../r11u57repro/run57.sh <binary> <tag>`, then
`bash away57.sh <this dir>/grid` (strict SET CONTAINMENT over the
judge-reachable dump; the `weaklyReferenced` tail is excluded by construction,
not by subtraction, and the dump's own database-name header is normalised — an
un-normalised header reports one phantom mover on every arm).

## Ranked residues

- **R1 (the next cell on this road, confirmed by measurement).** A REDUCIBLE
  operand beside the surviving call still reduces in golden's ELAB view while
  we re-render the syntax. `grid/b8_sibreduce57` makes it the head:
  golden `constant @11:23-11:26` against our `ref_obj: (work@dut.WID)`.
  Out of the corpus's reach — both witnesses' surviving operand is the
  literal `1`.
- **R2.** A kept operation Rhs on a RANGED holder carries no `ref_typespec`;
  an `int` holder's does (the witnesses are `int`, and their `param_assign`
  trees are byte-identical to golden). Measured on `b3_zerorep57` (a concat on
  `logic [7:0]`), `b1_aggpat57`'s `A5`, and `e1_inexpr57`'s `S4` — each one's
  head is exactly this missing field. Grid-only.
- **R3, sharpened.** The interior-conditional fence refuses more than `e8`'s
  T6. `b9_deepcond57` D3 (a collapsible conditional inside the TAKEN branch)
  and D4 (the condition holds the call, a collapsible conditional sits in a
  branch) are both golden-keeps that we still fold. Base behaviour, no
  regression, but the fence is wider than the residue as filed.
- **R4.** `b3_zerorep57` Z1: golden's reduce DROPS a zero replication
  (`{{0{$bits(TP)}}, 8'd1}` -> a concat with one operand); we re-render it.
- **R5.** Census reach: `census57.py`'s declaration regex requires
  `parameter|localparam type` and misses the bare `type T = ...` form legal in
  a parameter port list and a class parameter list. One directory
  (`sl3p/Google`) is missed; it is SLANG_REJECT/TIMEOUT and produces no
  database, so the predicted mover set stands.
- **R6.** Class localparams (`b6_class57`) and override ACTUALS
  (`b10_ovract57`) are out of the hook's reach entirely — both arms
  byte-unchanged under every binary.

## Discrepancies with the implementer's report (none blocking)

- Surelog movers are **6, not 5**: `Scoreboard/default` also draws. It is the
  documented coin — the positive control (the unchanged pristine binary run
  twice) moves it to the very hash the law and the fix produce.
- Surelog canaries read `ok=51 changed=1`, not `ok=52 changed=0`. The changed
  row is `Earlgrey_0_1/testflags`'s blank dump column, and the PRISTINE control
  reads the same. Draw-dependent, not a law effect.
- The report's "the only two differing rows are LowMemLib/LowMemPkg" omits
  that same Earlgrey dump-column draw, which also differs against the
  committed CSV on both binaries.
