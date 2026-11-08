# v11u493 — adversarial verification of r11u493 (§ enumCastChainKeepsInnerCast493)

Base dd23f8004 + slang v12.1 (42710c788) + the r11u493 patch, own worktree, one in-tree build
(`slang-uhdm --version`: slang 12.1.0+42710c788). Producers: the main checkout's pinned
Surelog v1.87, uhdm-cmp, uhdm-dump. Cases run through scripts/check_probe.py (the gate's flags).
No full sweep was run (the implementer's gate sweep held the machine).

## Verdict: VERIFIED WITH FIXES

## Reproduction

- The 20 gate cases of r11u493 + r11u246repro/cases/X/x04_dpiunit read EQUAL (strict equal)
  with the law; with `R11U493_CASTCHAIN_OFF=1` they read NOT_EQUAL except e03, s04, s05
  (EQUAL, the no-fold controls). Reproduced exactly.
- Switch identity: `R11U493_CASTCHAIN_OFF=1` on the fixed binary is byte-identical to the
  implementer's binary with the same switch on all 68 cases run (implementer's 22 + x04 +
  this pass's 45 at the time); `R11V493_CASTHOME_OFF=1` on the fixed binary is byte-identical
  to the implementer's law binary on the same 68. The implementer's two residues (e08, s07) are
  byte-identical between the implementer's binary and the fixed one.

## Defect found and fixed: the inner target was bound in the operand's scope

The implementer bound the inner cast's target in the scope of the operand's first value
symbol (else the outer target type's scope). That scope is not where the cast is written:

- hierarchical operand `int'(t32'(u.a))`, package variable `int'(t32'(p::pv))`: the bind
  failed (abstain, NOT_EQUAL: p01, p07), or found ANOTHER typedef of the same name in the
  child instance or the package (p02: sub's 64-bit `t32`; p08: p's) and wrote a wrong typespec;
- operand without a value symbol (call `g(a)`, ternary, streaming `{<<8{a}}`) with a builtin
  or sized outer target: no scope, abstain (p04, p04b, p06, p06b, t12, d04, d05).

Fix (§ enumCastChainKeepsInnerCast493, v11u493 fix, helper castChainHome493, switch
`R11V493_CASTHOME_OFF`): the bind scope is the scope whose declaration syntax is the nearest
syntactic ancestor of the written inner cast. Each candidate start (operand scope, then the
emitter's castSiteScope57, currentScope, castBindScope, then the outer type's scope) is walked
up its scope parents to a scope that encloses the cast syntax, then down through enclosing
member scopes (subroutine, generate block/array, statement block); the nearest home wins, the
operand's scope on a tie; a start that never encloses the cast (a stale site scope, another
module) is dropped. Converts p01, p02, p04, p04b, p06, p06b, p07, p08, t12, d04, d05.

## Attack grid (status pristine / implementer law / fixed law)

Pristine = the law binary with R11U493_CASTCHAIN_OFF=1. NE = NOT_EQUAL. Gate cases:
tests/probe/v11u493repro/cases (40); residues: tools/probe/v11u493repro/cases (10).
Evidence: evidence/probe_{pristine,law,law_fixed}.csv (the residue rows carry their
pre-move tests/probe paths).

| case | shape | pristine | law | fixed |
|---|---|---|---|---|
| O/o01..o03 | chain in arith, compare, concat | NE | EQUAL | EQUAL |
| C/c01..c04 | case item, if condition, return (typedef inner), for bound | NE | EQUAL | EQUAL |
| D/d01_four | four-deep chain | NE | EQUAL | EQUAL |
| D/d02_twoinst, d03_twoinst_enum | param module, two instances (typedef, enum) | NE | EQUAL | EQUAL |
| D/d04_twoinst_call | `W'(W'(g(a)))`, two instances | NE | NE | EQUAL |
| D/d05_twomods_call | the same in two modules (different W) | NE | NE | EQUAL |
| P/p01_hier_fn, p02_hiershadow_fn | `t32'(u.a)`; child declares its own t32 | NE | NE | EQUAL |
| P/p03_member, p05_concat | member access, concatenation operand | NE | EQUAL | EQUAL |
| P/p04_call, p04b_call_td_fn | call operand (builtin, typedef inner) | NE | NE | EQUAL |
| P/p06_ternary, p06b_ternary_td_fn | ternary operand | NE | NE | EQUAL |
| P/p07_pkgvar_fn, p08_pkgvarshadow_fn | `t32'(p::pv)`; package declares t32 | NE | NE | EQUAL |
| P/p09_genblk_hier_fn | `t32'(gb.x)`, gen-block operand | NE | EQUAL | EQUAL |
| T/t01_pkgqual | `p::t32'` inner | NE | EQUAL | EQUAL |
| T/t03..t05 | `W'` parameter width, 1-bit, 64-bit | NE | EQUAL | EQUAL |
| T/t07_int_realinner, t08_shortreal_real_fn | `int'(real'(r))`, `shortreal'(real'(r))` fold | NE | EQUAL | EQUAL |
| T/t06_real_intinner | `real'(int'(x))` (no fold) | EQUAL | EQUAL | EQUAL |
| T/t09, t10 | `int'(signed'(a))`, `signed'(int'(a))` (no CastExpression fold) | EQUAL | EQUAL | EQUAL |
| T/t11_chain_signed | `int'(int'(unsigned'(a)))` | NE | EQUAL | EQUAL |
| T/t12_stream | streaming operand | NE | NE | EQUAL |
| Z/z01_genif, z05_program, z09_paramclass | generate-if, program, `PC#(8)` static method | NE | EQUAL | EQUAL |
| N/n01..n03 | wider outer, generic `T::get()` (§ 292), narrower inner: must not fire | EQUAL | EQUAL | EQUAL |
| residue K/k01_ctl_single_td | single `t32'(a)` at module scope (control) | NE | NE | NE |
| residue T/t02_classqual_fn | `C::t32'` inner | NE | NE | NE |
| residue Z/z02_genfor, z03_genshadow_fn, z04_iface | gen-for, gen-block typedef, interface | NE | NE | NE |
| residue Z/z06_pkgfn, z07_unit_fn, z08_classstatic | package fn typedef, $unit typedef, class typedef | NE | NE | NE |
| residue Z/z10_fnshadow, z11_fnshadow_modvar | function-local typedef shadowing the module's | NE | NE (z11 EQUAL) | NE |

## Residues (each reproduced by a control without the fold)

Every residue was checked against a control: the same file with the outer cast removed (a
single written cast), or with a non-folding nested cast (`int'(16'(x))`). Each control read
NOT_EQUAL with the same first differences, so none is this law's.

- Module-scope typedef as a cast target (k01, and every module-scope typedef chain): golden
  lists the typedef's int_typespec with vpiTypedefAlias at top level; ours does not (the
  implementer's s07 ground). This pass's module-scope context cases therefore use a builtin
  inner (`int'(int'(x))`), and the typedef cases sit in functions.
- t02 `C::t32'(s)`: class-scoped cast-target typespec (single cast reproduces).
- z02 nested cast in a gen-for scope: the inner ref_typespec and operand ref_obj are named
  `work@top.g[0]...` (golden unnamed / bare `a`); reproduced by `int'(16'(a + i))`.
- z03 gen-block-local typedef cast target: single `t_t'(a)` reproduces.
- z04 interface cont_assign cast: `int'(16'(a))` in the interface reproduces it byte for byte.
- z06, z07, z08 package / $unit / class typedef listing for a cast target: single cast reproduces.
- z10, z11 function-local typedef shadowing a module typedef: Surelog resolves the cast target
  to the MODULE's `t_t`, ours writes the integer_typespec fallback; single `t_t'(s)`
  reproduces. z11 read EQUAL with the implementer's law only because it bound `t_t` in the
  operand's (module) scope — the type slang did not use; the fixed law binds the written
  scope's `t_t` as slang does and z11 joins z10's ground.

## Notes

- Memoisation per folded node is kept; the bind candidates are the first emission's.
- The fix reads only scopes the emitter already tracks; no new header, no getenv.
