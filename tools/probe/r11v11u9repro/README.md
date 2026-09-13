# r11v11u9 — adversarial verification of r11u9 (§ pkgStructFuncAssembleBin)

Everything here is MEASUREMENT-ONLY; the judge is `uhdm-cmp` through
`scripts/verify_golden.py`. Base commit 1b26ea91, pins per `SUPPORT_MATRIX.md`.

## 1. What was reproduced bit-for-bit

| headline | claimed | measured here |
|---|---|---|
| pristine binary md5 | `6f95f155f2cdeb7cf24b3f8aa473246f` | same |
| patched binary md5 | `1da12c5a1845bb5222aaa743d4bb2619` | same |
| goldens | 23 PASS / 0 FAIL, `/bin/false` 23 FAIL | same |
| u2r pristine | 743 / 61 / 67 both modes | same, 0 rows differ from the committed baselines |
| u2r patched | 745 / 59 / 67 both modes | same |
| conversions | `pkg_nested_struct_param_width`, `portsel_struct_param` × 2 modes | same, and they are the ONLY differing rows |
| u2r byteverify | 22 / 1608, SELFCHECK 1607/1608 | same, same 11 tests × 2 modes |
| u2r direction | 22/22 TO-GOLDEN | same (independent order-blind dump-distance scorer) |
| u2r shape lister | 0 rows GREW | same (independent per-`param_assign` Rhs-kind lister) |

## 2. The producer decode is CORRECT — and the brief's 64-bit fence is REFUTED

`UHDM/templates/ExprEval.cpp` `reduceExpr`'s `uhdmstruct_var` arm (4835–5005)
reads member by member, first declared member at the MSBs, and mints
`BIN:<bits>` / bare decompile / `VpiSize(bits.size())` / `vpiBinaryConst` /
ts ref → the struct_typespec. There is **no `mw > 64` test in the arm**: the
brief's "any member beyond sixty-four bits stays unassembled" describes
`hierarchicalSelector`'s member-slice fence, not this one. `g4` (a
`logic [15:0][63:0]` member) assembles in golden; measured.

`assemble()` returns false — and the Rhs then STAYS the `struct_var` — when a
member's size is invalid/0, or it has no `Actual_value`/`Default_value`, or
that value neither reduces to a constant nor matches one of the pattern /
concat / replication / single-operand-cast shapes the arm folds itself.

## 3. The golden grid (22 arms, every arm's rc recorded)

`vgrid.sh` builds golden + both binaries per arm; `vdist.sh` scores the
order-blind path-normalised dump distance to golden; `vpacen.py` lists every
`param_assign`'s section, Lhs name and Rhs object KIND + constant fields —
it is the SHAPE LISTER (the r11v7 lesson: a value scorer reads clean across a
shape break).

Golden's split, confirmed on every assembling arm:

| view | golden Rhs |
|---|---|
| `uhdmallPackages` (DEF) | the unfolded `func_call`, typespec CLEAN |
| `uhdmtopPackages` | assembled BIN, **bare** decompile |
| `uhdmallModules` import copy | assembled BIN, bare |
| `uhdmtopModules` | assembled BIN, `<w>'b` PREFIXED decompile |

Arms: `g1` wildcard import, `g2` explicit import, `g3` no import (qualified
reference), `g4` >64-bit member, `g6`/`g17` non-constant leftovers golden
still folds, `g7` module holder, `g8` nested struct, `g9` typed enum member,
`g10` parameter-read member, `g11` whole-formal read, `g12` three instances,
`g13` module parameter defaulted to the package localparam, `g15` a member the
function never assigns, `g16` BASE-LESS enum member, `g18` nested call,
`g6m`/`g17m` the module-holder twins of `g6`/`g17`, plus the two break arms
below.  The `FuncStructVal` control is the upstream test dir itself
(`~/git-repos/Surelog/tests/FuncStructVal`, run through `vgrid.sh` with `G=`
pointing at it): 0 heads / 0 cmp lines on BOTH binaries — it stays equal.

## 4. THE BREAK — a PACKAGE-held bail, pristine-RIGHT → patched-WRONG

`b1` = `FuncStructVal`'s own design with its holder moved from `module top`'s
parameter to a package localparam plus `import hold_pkg::*` (same single
`config_pkg::WT` ERROR the corpus test itself carries, rc=4 both).
`b2` = `StructParamFuncBodyFieldCompare`'s design with the same move, clean
compile (rc=0).

Golden BAILS in both: `uhdmtopPackages`, the `uhdmallModules` import copy and
`uhdmtopModules` all keep the `struct_var`. The **pristine** binary already
matched golden's `uhdmtopModules` struct_var. The patch replaced it with an
assembled BIN:

| arm | dist pristine | dist patched | dist FIXED | verdict on the patch |
|---|---|---|---|---|
| `b1` | 18193 | 18200 | 18186 | **AWAY-GOLDEN** |
| `b2` | 614 | 625 | 611 | **AWAY-GOLDEN** |
| `b3` (`b2` × 2 instances) | 918 | 938 | 915 | **AWAY-GOLDEN** |

`b3` also proves the fix's per-view stamp pinning: both instance copies AND the
elaborated package listing go back to the `struct_var`.

Cause: § `pkgStructFuncAssembleBin` assembles EAGERLY at the param site with no
bail rule, while its module-holder sibling § `modStructFuncAssembleBin` applies
the producer's bail in the drain. The two corpus bail witnesses are both
module-held, so the corpus cannot see this; only the wide boundary can.

## 5. THE FIX — § `pkgStructFuncAssembleBinBail`

`src/ParamEmit.cpp` only (plus the record struct in `include/UhdmExporter.h`).
The package arm still mints eagerly — a later parameter in the same scope
shares the constant through `elabParamConst` (`localparam cfg_t L =
CfgDefault`), so the mint cannot move — and the DRAIN puts the `struct_var`
back when this view's stamp did not survive, restoring the parameter's prior
`VpiValue`. `stampIdx` pins THIS view's stamp: the package view and every
importing module view push their own stamp for the same `ParameterSymbol`.

The bail predicate mirrors `assemble()`'s own acceptance set, not a plain
"all constants": a null value bails (FuncStructVal's face), a logical /
comparison operation bails (`b2`), and a pattern / concat / replication /
single-operand cast does NOT (`g17` — golden assembles that one). The module
arm's plain all-constants check is left exactly as it was: it is validated by
`StructParamFuncBodyFieldCompare` and `FuncStructVal` staying CMP_EQUAL, and
`g6m`/`g17m` show its conservatism is pre-existing and identical on both
binaries.

## 6. Gates on the FIXED binary

* goldens 23 PASS / 0 FAIL; `/bin/false` 23 FAIL.
* u2r 745 / 59 / 67 both modes — the two conversions preserved.
* `byteverify SELFCHECK=1` FIXED vs PATCHED on u2r: **0 / 1608 movers**
  (1607/1608 on the selfcheck control) — the fix is CORPUS-NEUTRAL; its only
  effect is on the package-held bail, which no corpus row takes.
* FIXED vs PRISTINE on u2r: the same 22 / 1608, the same 11 tests × 2 modes.
* surelog on the FIXED binary: 467 / 16 (default) and 463 / 14 (testflags) —
  the committed baseline, identical to both other binaries.  `byteverify`
  FIXED vs PATCHED: 3 / 960, and all three are the UVM coin family
  (`MiniAmiq` ×2, `SeqDriver`) — `FuncStructValSimple` and
  `StructParamPatternInitCast`, the law's own surelog movers, are
  BYTE-IDENTICAL between the two.  Coin positive control on the PRISTINE
  binary ALONE, two sweeps of those rows with the sweep's own `--jobs 2`:
  MiniAmiq `7adcb4fbe060`/`779579bcf7e1`, SeqDriver `561c0379f7a3`/`68cc3d64d0ec`,
  Scoreboard `89c1b4e51d8e`/`61ee9cb4f6c1`, and SimpleUVM's sweep hash
  `ff8342bce870` against `cbec4d608b72` from three serial pristine re-runs.
  Order-blind attribution: 4 lines per coin row, all of the line-number class
  (`UINT:1509` vs `UINT:521` and the matching `vpiDecompile`).
* `ct8rows` on the FIXED binary: the same two conversions, nothing else; the
  surelog side only the two `LowMem*` SURELOG_FAIL detail strings that embed
  the workdir path, which the PRISTINE sweep shows identically.
* canaries `ok=52` (surelog) / `ok=8` (u2r), `changed=0` on the fixed binary.
* Every `cmds.txt` audited by binary PATH in all three workdir sets.
* Canary byte pins hold on the fixed binary too: SVSwitch `4842211c4030`,
  YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
  BlackParrotComplex and YosysOldOr SAME as both other binaries.

## 7. Residues found, ranked (all pre-existing or newly exposed, none a regression)

* **V1 — the `uhdmallModules` import copy's Rhs.** Golden's `work@child.C`
  import copy is the assembled BIN; ours stays the `INT:<decimal>` struct-width
  fold on BOTH binaries (`g1`, `g5`, `g10`, `g11`, `g16`, `g18`). r11u9's own
  README table lists that view as fixed; measured, the law fixes the ELAB
  PACKAGE and ELAB MODULE views, not the import copy's own `param_assign`.
  It is the head that replaced the leftover head on `g1`/`g2`/`g3`.
* **V2 — the `<w>'b` prefix in `uhdmtopModules` for a PACKAGE-held param.**
  Golden prefixes the elaborated module view's decompile (`72'b…`) and leaves
  the package view bare; the package arm mints ONE bare constant and it reaches
  both (`g11`, `g16`, `g18`, and the elision in `g11` shows it is literally the
  same object). § `modStructFuncAssembleBin` gets the prefix right for a
  module-held parameter; the package holder's module view does not.
* **V3 — `slPackedWidth` vs the assembler's bit sum on a BASE-LESS enum
  member.** `slPackedWidth` drops such a member (0 bits, per its own comment);
  `assemble()` falls back to 32 bits for it. `g16` golden: `vpiSize:8` with a
  40-character BIN string; ours: an 8-character BIN at size 8 — the width and
  const type now match golden, the decompile and value do not.
* **V4 — the § r10fsv3 S2 leftover predicate misfires on a reducible
  comparison.** `g6` golden stamps `Flag` with `UINT:0`; we stamp the body's
  `vpiLogAndOp`, and the assembled value then differs (`…1011` vs golden
  `…1010`). Same on both binaries.
* **V5 — g6 keeps the fix's conservatism.** With the fix, a package-held
  builder whose member is a comparison our § r10fsv3 S2 rule calls unreduced
  bails where golden assembles (`g6`: 734 → 721, still TO-GOLDEN, but the
  patch alone reached 703 with the right SHAPE and the wrong value). The
  module-holder twins `g6m`/`g17m` show the module arm is already this
  conservative on the identical shape, on BOTH binaries — the root cause is V4,
  not the bail.
