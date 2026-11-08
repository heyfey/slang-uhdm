# r11u493 — the cast chain slang folds into one node (§ enumCastChainKeepsInnerCast493)

Base dd23f8004 (v0.12.0) with the slang pin moved from v12.0 (545f88b2e) to v12.1 (42710c788).
Target: tests/probe/r11u246repro/cases/X/x04_dpiunit, the one row the slang bump moved
(EQUAL -> NOT_EQUAL in the bump sweep against the v0.12.0 baselines; every corpus, downstream
and sv-tests row kept its status). Production surface: src/ExprEmit.cpp only (no other header,
no getenv; the switch through src/law/LawSwitch.h). Worked in the Orca worktree of the bump
branch. Verified adversarially by v11u493repro (tools/probe/v11u493repro/README.md), which
found and fixed one defect: the inner target's binding scope (switch R11V493_CASTHOME_OFF
returns the implementer's binding). The landed law is the verified one.

## Verdict

x04_dpiunit reads EQUAL again (uhdm-cmp equal and STRICT_EQUAL). One law, decoded from slang's
source (the fold) and Surelog's (one operation per written cast) and measured on a golden grid
of 22 new cases: 20 read EQUAL with the law, 2 are residues of other laws.

## The law

§ enumCastChainKeepsInnerCast493 (switch R11U493_CASTCHAIN_OFF; ExprEmit, the Conversion arm
of emitExpr, helper foldedCastChain493). A static cast whose written operand is itself a static
cast, but whose AST operand is not an explicit conversion, is a chain slang folded into one
node; the inner cast is rebuilt from the written operand and the chain is emitted as two cast
operations, nested as written.

- slang: `ConversionExpression::fromSyntax` (source/ast/expressions/ConversionExpression.cpp,
  v12.1 lines 383-401) binds a static cast whose target and operand are both numeric in the
  assignment-like context of the target ([10.8]). The propagated type is
  `OpInfo::binaryType(target, operand)`; when that type is equivalent to the operand's own type
  no implicit conversion is inserted, and an operand that is an explicit conversion is re-typed
  to the outer target and returned in place of a new node (`operand->sourceRange = outer;
  operand->type = type; return *operand;`). The result is ONE ConversionExpression whose
  `syntax` is the outer CastExpression and whose operand is the inner cast's operand. v12.0
  folded only when the target was assignment compatible (`int'(int'(x))`, `4'(4'(x))`,
  `4'(8'(x))`); v12.1 adds the numeric-cast condition, so the enum target folds too
  ("Fixed sizing of the operand of a cast to an enum type", CHANGELOG v12.1), which is x04's
  `sev_e'(st_e'(severity))`.
- Surelog: `CompileExpression.cpp:2660` (`case VObjectType::paCast`) compiles every written cast
  into its own vpiCastOp (67) operation with a ref_typespec to the written target, and compiles
  the operand recursively, so a chain is nested as written. Golden x04: cast(sev_e) ->
  cast(st_e) -> ref_obj severity, in the definition copy (placeholder typespecs, § 170) and the
  elaborated copy (resolved typespecs, § 246) alike.
- Ours (pristine, slang v12.1): cast(sev_e) -> ref_obj severity; the inner cast and its
  typespec are absent from the database.
- The rebuild: the outer cast's parenthesised operand syntax is unwrapped to the inner
  CastExpression; its target is bound as slang binds a cast target (`Expression::bind` of the
  written target with AllowDataType: a data-type name gives the type, a positive constant gives
  `getType(width, operand flags)`), in the scope of the operand's first value symbol (a
  select, member access, unary, binary or concatenation operand is walked to it), else the
  outer target's own scope. Two ConversionExpression nodes are placed in the compilation (the
  inner with the inner syntax and span, the outer with the folded node's syntax and span) and
  the outer is emitted in place of the folded node, so every cast law downstream (170, 246,
  93, 292, the nested-cast syntax hand-down) sees the v12.0 shape. The rebuild is memoised per
  folded node, so the definition and elaborated emissions of one node see one object identity.
  A chain folded twice (`e'(s'(t'(x)))`) rebuilds in two steps, since the rebuilt inner is
  itself a folded node (E/e06).
- Abstains (trace `CASTCHAIN_ABSTAIN`): no scope found, or a target that does not bind to a
  type or a positive width. Neither fired on the grid or in the bump sweep.
- Fires on the fold only: an operand that is an explicit conversion (slang kept the inner node,
  `sev_e'(oth_e'(x))` E/e03, `8'(4'(x))` S/s05) or an Invalid operand (§ 292's ground) is left
  to the existing paths.

With `R11U493_CASTCHAIN_OFF=1` the law binary's output is byte-identical to the pristine
binary on all 23 grid cases (20 gate cases, 2 residues, x04).

## Grid

Goldens built by the pinned Surelog (v1.87) through scripts/check_probe.py, the gate's flags.
Evidence: evidence/probe_pristine.csv (law off), evidence/probe_law.csv (law on).

| group | shape | cases | pristine EQUAL / NOT_EQUAL | law EQUAL |
|---|---|---|---|---|
| E (enum target, new fold in v12.1) | struct, vector typedef, int, sized and three-deep inner; in a function, a cont_assign, an initial, a class method, a call argument, a package function; package-qualified inner; literal and bit-select operands; enum inner (control, no fold) | 15 | 1 / 14 | 14 (e08 residue) |
| S (non-enum same-or-wider inner, folded since v12.0) | `int'(int'(x))`, `int'(t32'(x))`, `4'(4'(x))`, `two_t'(st_e'(x))`, `8'(4'(x))` (control), `4'(8'(x))`, `byte'(b_t'(x))` | 7 | 2 / 5 | 6 (s07 residue) |

The gate cases are tests/probe/r11u493repro/cases/{E,S}. The S group shows the same fold was
already in slang v12.0 for a non-enum target and was never covered by a gate case; those five
conversions are the law's, not the bump's.

## Residues (tools/probe/r11u493repro/cases)

- E/e08_localparam `localparam sev_e P = sev_e'(st_e'(2'b01))`: golden keeps the cast chain
  as the parameter's expression and reads `v = P` as a ref_obj; ours folds the parameter to a
  constant (both views). Parameter-fold policy for an enum-typed localparam with a cast RHS,
  not this law; the chain itself is emitted nested.
- S/s07_byte_td `byte'(b_t'(x))` with `typedef byte b_t` used only as a cast target: golden
  lists a top-level `byte_typespec b_t` (the typedef's listing object); ours has none. A
  typedef-listing law, not this law; the chain itself is equal.

## Landing gate

The full gate with the verified binary (tests/sweep.sh, cached goldens) read regressions=0 on
all five stages: probe EQUAL 30006, STRICT_NOTEQUAL 2033 of 32039 (the 60 new cases
only-fresh, all EQUAL; x04 EQUAL), surelog and uhdm2rtlil rows unchanged, sv-tests unchanged
(EQUAL 1937, DIFFERENT 3), downstream IDENTICAL 803 + EQUIVALENT 2 of 871 from the main checkout, the baseline exactly (the two
worktree-path EQUIVALENT rows read IDENTICAL there). Byte comparison against the pristine
v12.1 sweep (same worktree): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805
movers; probe movers x04 (the law) and six order-only flips (r11u199verify N/n05_gen_inside,
r11u307repro NR/r09_inner_twice_each, v11u257repro G/vg07_concat_lhs, v11u297repro
VN/vn05_inner_uses_iface_port, v11u307repro VD/vd23_genfor_local_op and VD/vd25_second_body_op:
order-blind dumps identical, the law binary and the pristine binary byte-identical on each
outside the parallel sweep, no law trace fired).

## Bump context

The slang v12.1 sweep against the v0.12.0 baselines (tests/sweep.sh, cached goldens) read:
probe regressions=1 (x04), surelog 0, uhdm2rtlil 0, sv-tests 0 changes (EQUAL 1937,
DIFFERENT 3), downstream IDENTICAL 802 of 871 with two EQUIVALENT rows (BreakContinue,
iface_struct_field_partsel) that reproduce with the slang v12.0 binary in the same worktree and
read IDENTICAL from the main checkout with the v12.1 binary: a checkout-path effect of the
uhdm2rtlil plugin's pre-hierarchy output order (see the per-checkout note in
scripts/downstream_uhdm2rtlil.py), not the pin.
