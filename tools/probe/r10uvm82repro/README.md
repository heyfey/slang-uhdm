# r10uvm82 — § classImportParamStamped82

**MEASUREMENT-ONLY.**  Nothing here is an acceptance judge; `uhdm-cmp`
(`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the authorities.

## The law

A CLASS that inherits its container's package imports
(`§ classInheritsContainerImports23`, `src/ModuleEmit.cpp`) was handed the
imported package's `vpiParameter` and `vpiParamAssign` objects **BY POINTER**.
Surelog does not share: `importPackage` materialises a fresh `parameter` per
listing entry and stamps it `vpiImported = <the immediately-imported package>`.
`parameter::Compare` reads `vpiImported` as its **last** field, so the shared
object disagreed with golden on every inherited entry, in **two** arms:

* the class's `vpiParameter` listing, and
* the **Lhs of the class's `vpiParamAssign`** — which in golden is a *third*
  object set, not the entries of `vpiParameter` (`ct82pa`: `adpcm_driver`
  `LhsIN=0 LhsOUT=45`).

## The instruments (all MEASUREMENT-ONLY; build line in each header)

    g++ -O2 -std=c++17 <tool>.cpp -I ~/.local/include \
        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <tool>

| tool | what it answers |
|---|---|
| `ct82imp.cpp`  | per-database tally of `vpiImported` over every scope's `vpiParameter` (`--per-class` for the per-scope breakdown) |
| `ct82pa.cpp`   | is a class's `vpiParamAssign` Lhs set the same objects as its `vpiParameter` set?  (`LhsIN`/`LhsOUT`) |
| `ct82pa2.cpp`  | prints a named class's first parameters and param_assigns with `vpiImported`, id and parent |
| `ct82pkg.cpp`  | the same question for PACKAGE scopes |
| `ct82pred.cpp` | the **mover predictor**, run on PRISTINE databases only: counts class listing entries whose `vpiParent` is a `package` — exactly the objects this law replaces |

## The census that fixed the law (goldens, `ct82imp`)

| row | golden class_defn `<EMPTY>` / `uvm_pkg` | ours BEFORE | ours AFTER |
|---|---|---|---|
| SeqDriver default+testflags | 275 / **225** (5 classes x 45) | 500 / 0 | 275 / 225 |
| SimpleUVM default+testflags | 275 / **90** (1 class, `$unit` import counts x2) | 365 / 0 | 275 / 90 |
| Scoreboard default          | 275 / **90** | 365 / 0 | 275 / 90 |
| BuildUVMPkg default+testflags | 280 / **0** | 280 / 0 | 280 / 0 |

`BuildUVMPkg` is the NEGATIVE CONTROL: no class inherits a parameter there, its
golden tally is zero, and the family has no rung in its ladder.

## The shape of the fix, and why the copy is provably compare-neutral

`parameter::Compare` reads, in order: `VpiType`, `VpiName`, `VpiDefName`
(BaseClass) -> `VpiDecompile`, `VpiSize`, `Typespec` (expr) -> `VpiConstType`,
`VpiSigned`, `Expr`, `Ranges`, `Left_range`, `Right_range`, `VpiLocalParam`,
`VpiName`, **`VpiImported` (LAST)**.  The pre-law head is the LAST field, which
is a proof that every earlier field of the SHARED object already equals golden's
copy.  The copy therefore reuses the same child pointers (`Typespec`, `Expr`,
`Ranges`, `Left_range`, `Right_range`, `VpiUses`) and copies every scalar; the
only field that can move is the one being fixed.  `VpiParent` is not compared
(BaseClass::Compare), so the copy's re-parenting is inert.

The ASSIGN arm needs the same treatment for a reason that is easy to get wrong:
`m_visited` is keyed on the **LHS (golden)**, and golden's class `vpiParamAssign`
Lhs is a *third* object set, so it is NOT already visited when the
`vpiParameter` pass finishes.  Fixing only the listing leaves 82 rungs per row
firing at `KINDP=param_assign`.

## What did NOT change, and is recorded as residue

* the copy's `vpiTypespec` `ref_typespec` is **SHARED** with the package's, so
  its `vpiFullName` reads the package chain where golden reads the class chain.
  `VpiFullName` is **never compared** (`comparescope.sh` law) and
  `ref_typespec::Compare` reads only `VpiName` / `VpiDefName` /
  `Actual_typespec` — all three already equal on this very object before the
  pass.  A dump-axis residue, deliberately not chased.
* `type_parameter` also carries `vpiImported`, and this law leaves it SHARED.
  All 902 rungs of the family are `KINDL=parameter`; no package in either corpus
  exports a `type_parameter` through this path.  Residue.
* the MODULE / PACKAGE arms of the import-copy law (`§ impOcc` in
  `src/ParamEmit.cpp`) were already correct and are untouched: golden and ours
  agree on `module_inst|adpcm_pkg 90`, `module_inst|uvm_pkg 90`,
  `package|uvm_pkg 90` before AND after.

## The official judge moved NOTHING, and that is the honest headline

`uhdm-cmp`'s output is **BYTE-IDENTICAL** before and after on all seven UVM
row-modes (`SeqDriver`/`SimpleUVM` x default+testflags, `Scoreboard`/default,
`BuildUVMPkg` x default+testflags): same head object, same line count
(1450011 / 1405511 / 1399779 / 29).  Nothing converted and nothing was expected
to: the official head on the three big rows is the **design-level
`package uvm_pkg` container** (`package|<rhs-null>|MISSING-OURS` on SeqDriver,
`package|~Typespecs|VEC:G>O 125 vs 91` on SimpleUVM/Scoreboard), and this whole
902-rung family sits BEHIND that wall.  The ladder is therefore the ONLY
instrument that can see this pass, which is exactly what it was built for.

## THE LADDER, before and after — the family is GONE, 902 -> 0

`ctladder` (r10ladder1repro, unmodified), MAX=20000 BUDGET=1800, inputs pinned
by sha256 in `INPUTS.r10uvm82.{BEFORE,AFTER}.txt`.

| row | rungs BEFORE -> AFTER | family BEFORE -> AFTER | maxvis BEFORE -> AFTER | stop |
|---|---|---|---|---|
| default SeqDriver    | 385 -> **506** | **164 -> 0** | 15910 -> **43092** | FIXPOINT |
| default SimpleUVM    | 392 -> **228** | **164 -> 0** | 40573 -> 40573 | ROOT-BLOCKED |
| default Scoreboard   | 392 -> **228** | **164 -> 0** | 43415 -> 43415 | ROOT-BLOCKED |
| testflags SeqDriver  | 514 -> **268** | **246 -> 0** | 26308 -> 26062 | FIXPOINT |
| testflags SimpleUVM  | 392 -> **228** | **164 -> 0** | 40585 -> 40585 | ROOT-BLOCKED |
| default BuildUVMPkg  | 258 -> 258 | 0 -> 0 | 42973 -> 42973 | FIXPOINT (NEG CONTROL) |
| testflags BuildUVMPkg| 258 -> 258 | 0 -> 0 | 42973 -> 42973 | FIXPOINT (NEG CONTROL) |

**902 -> 0**, and `FIELD=VpiImported` of ANY shape is now absent from all seven
ladders.  The two `BuildUVMPkg` ladders are **BYTE-IDENTICAL** before and after
(the only differing line is the `# OURS (RHS)` input-path header) — the negative
control the census predicted, met exactly.

`default SeqDriver` grew from 385 to 506 rungs.  That is not a regression: the
164 family rungs each carried a MASK, and removing them un-hides what those
masks were cascade-suppressing.  Its `maxvis` — golden objects PROVEN EQUAL —
went 15910 -> 43092, nearly triple.

R1..R3 are UNCHANGED on every row (the `uvm_pkg` container wall, then the
pre-existing `constant>hier_path` at `uvm_sequencer_base.svh:1576:23` and
`method_func_call this|sequences` at `:1578:12`).  The new family tops beneath
the cleared wall, with their first rung index:

* `default SeqDriver`  `<null>|<lhs-null>|EXTRA-OURS` x165 [R7] · `constant|VpiSize|INT:G<O` x28 [R65] · `ref_typespec|<rhs-null>|MISSING-OURS` x25 [R10] · `typespec_member|<rhs-null>|MISSING-OURS` x16 [R339] · `struct_var|<rhs-null>|MISSING-OURS` x16 [R338]
* `SimpleUVM` / `Scoreboard`  `<null>|<lhs-null>|EXTRA-OURS` x68/70 [R7] · `parameter|VpiType|KIND:parameter>constant` x21/22 [R26/R65] · `sys_func_call|VpiType|KIND:sys_func_call>constant` x16 [R100/R117]
* `testflags SeqDriver`  `<null>|<lhs-null>|EXTRA-OURS` x103 [R7] · `constant|VpiSize|INT:G<O` x20 [R68] · `constant|VpiDecompile|TEXT:#|int` x14 [R109]
