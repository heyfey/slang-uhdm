# r10uvm106 — § unsizedBasedParamRhsSize106

## Result

The `param_assign` **Rhs constant** of an UNTYPED, UNRANGED, non-explicitly-
signed parameter whose default is an UNSIZED BASED literal (`'h` `'b` `'o` `'d`,
known or `x`/`z`) carries **`vpiSize` -1 in every view**, and its typespec
REFERENCE is left unresolved: a `ref_typespec` with **no `vpiActual`** in every
definition-view listing, and **no typespec at all** in an elaborated instance.

That constant was the SeqDriver head in both modes:

    LHS (golden): constant @99:23-99:32  vpiDecompile 'hf000000  vpiSize -1
                  HEX:f000000  vpiTypespec -> ref_typespec with NO vpiActual
    RHS (ours):   the same constant, vpiSize 32,
                  vpiTypespec -> ref_typespec -> int_typespec @99:1-99:32

`expr::Compare` reads `VpiDecompile` (equal), then `VpiSize` (-1 vs 32 — the
failing field), then `SafeCompare(Typespec())`, which would have failed next
inside `ref_typespec::Compare` on `Actual_typespec` (golden null, ours an
`int_typespec`).  Both halves therefore had to move together.  The owner is
`uvm_pkg::UVM_RADIX`, uvm-1.2 `src/base/uvm_object_globals.svh:99`

    parameter UVM_RADIX = 'hf000000;

the same declaration whose PARAMETER-side typespec r10uvm102 removed
(§ implicitUnsizedBasedNoTs102); this pass is the initializer side r10uvm102
deliberately left, which its README named R2.

SeqDriver goes **60 -> 29** cmp lines in both modes, one head each.  116 census
cells across the nine moved databases go to golden, 0 away.

## Surelog producer

`CompileHelper::compileParameterDeclaration`, `CompileHelper.cpp:3786-3910`.
The default is compiled into a REDUCED CONSTANT first and the parameter's
implicit type is derived from it afterwards:

```cpp
if (rhs && (rhs->UhdmType() == uhdmconstant)) {
  constant* c = (constant*)rhs;
  if (ts == nullptr) {
    switch (c->VpiConstType()) {
      ...
      case vpiHexConst: case vpiOctConst: case vpiBinaryConst: {
        int_typespec* its = s.MakeInt_typespec();
        ...
        if (c->VpiSize() != -1) {   // <- Unsized
          ... ts = its; p->setTypespec(ts);
          param->Typespec()->Actual_typespec(ts);
        }
        break;                       // UNSIZED: ts stays nullptr
      }
      case vpiDecConst: { break; }   // 'd NEVER derives a type at all
      ...
    }
  }
  ...
  int32_t size = c->VpiSize();                       // -1 for an unsized literal
  if (ts) { ... size = Bits(ts, ...); }              // never taken here
  if (rhs->Typespec() == nullptr) {
    ref_typespec* tsRef = s.MakeRef_typespec();
    tsRef->VpiParent(rhs);
    rhs->Typespec(tsRef);
    rhs->Typespec()->Actual_typespec(ts);            // ts is NULL -> DANGLING
  }
  c->VpiSize(size);                                  // stays -1
}
```

So the two halves are one mechanism: with no derived typespec the width is never
re-derived (`size` keeps the literal's own -1) and the reference minted for the
constant is handed a null actual.  The ELABORATED copies do not run this path at
all — the netlist elaborator rebuilds the instance's `param_assign` from the
value and attaches nothing — which is why golden's elaborated copy has the same
-1 with NO typespec.  Generate-block and function-local parameters are rebuilt
the same way.

## Model

`UhdmExporter::drainUnsizedBasedRhs106` (`src/ParamEmit.cpp`, declared in
`include/UhdmExporter.h`), called DESIGN-FINAL from `exportDesign`.

1. `emitParameters` RECORDS the Rhs constant when the DECLARATION has the shape:
   untyped (`ImplicitType`), unranged (`!isRangedUntypedParam`), no explicit
   `signed`/`unsigned` keyword (`!implicitSigning102`), and a default whose raw
   text is an unsized based literal — `'` at offset 0, an optional `s`, then one
   of `b o h d`.  Along with it: whether this listing wants the reference
   dropped entirely (`(!defViewOrig9 && !inPackage) || funcScope` — the
   elaborated instance and function-local copies) and the scope prefix used for
   the dump-only `vpiFullName` of a minted reference.  `defViewOrig9`, not
   `topView`, because § modDefImportShape FLIPS `topView` true for materialized
   import rows in the DEF listing, where golden still wants the dangling
   reference.
2. The DRAIN runs after every per-view width and typespec path has had its say
   (that is why it is design-final rather than local): it re-checks that the
   EMITTED constant still renders as an unsized based literal, sets `VpiSize(-1)`
   and then either clears the typespec or clears the reference's actual, minting
   the reference when there is none (`'hx` / `'ox` / `'hz` had none in pristine
   and golden gives them the dangling one like every other base).

## Fences (each measured on golden, each costing a draft)

* **SIZED literals** (`32'hf000000`, `3'b101`, `3'bx`) — they have a typespec, so
  Surelog's `Bits(ts)` re-sizes them.  Never recorded: the raw text must start
  with the tick.
* **`'b0` / `'b1` / `'B0` / `'B1`** — the pp grammar gives these dedicated tokens
  with `VpiSize` **0**, not -1, so Surelog's `!= -1` arm DOES mint their
  `int_typespec` and they behave like sized literals.  Measured on golden
  (`a6_edge.sv`): size 0 and a real `int_typespec` in every view.  Excluded by
  name at record time and by `VpiSize() == 0` in the drain.
* **TYPED / RANGED declarations** (`parameter int`, `logic [7:0]`, `byte`,
  `bit signed [15:0]`, `[3:0]`, `integer`, `string`) — `a2_typed.sv` is
  BYTE-IDENTICAL in both views.
* **`parameter signed` / `parameter unsigned`** — an explicit signing keyword is
  a declared type for this purpose (already `implicitSigning102`).
* **SIGNED-BASED literals** (`'sh1a` `'sb101` `'so7` `'sd13`) — fenced off
  ENTIRELY, both halves.  This is the one unsized shape whose constant carries a
  typespec of its OWN (Surelog mints a signed `int_typespec` on the literal), so
  `if (ts)` DOES fire and the elaborated copy IS re-sized.  `a8_toponly.sv`
  proves it on golden: in the elaborated copy of a top module, `parameter P_HEX
  = 'h1a` gets vpiSize -1 while its neighbour `parameter P_SHEX = 'sh1a` gets 32.
  The first draft, which applied the size half to signed literals, moved three
  cells AWAY from golden on `r10v102repro/b01_shapes.sv` in both views.
* **A FOLDED default** — an override actual (`#(.O_P('hF))` -> `15`), an
  expression (`'hf000000 + 1`), a concatenation: the recorded predicate is the
  declaration's, but the drain re-reads the constant it is about to touch and
  leaves anything that no longer renders as an unsized based literal exactly
  where pristine put it.  `a4_over.sv` shows those cells unchanged.

## Cells and movers

Nine surelog databases move, all nine predicted BY NAME from the pristine sweep
before the patched sweep ran (`scan106.py` + `pred106.py`, GATES.txt):
`BuildUVMPkg` `MiniAmiq` `Scoreboard` `SeqDriver` `SimpleUVM` in default and
`BuildUVMPkg` `MiniAmiq` `SeqDriver` `SimpleUVM` in testflags.  uhdm2rtlil has
**zero** sources with the shape and **zero** movers over 1358 databases.  No row
converts; `results/*.csv` is untouched.

## Acceptance

All five gates green (GATES.txt).  GRID.txt is the nine-arm x two-view golden
grid (golden-vs-golden calibrated at 0 cells over 92 keys); CENSUS.txt the keyed
multiset census (TO-GOLDEN 116, AWAY 0) and the per-view shape table;
BOUNDARY.txt both halves of the wide boundary and the three-way scoring of every
one of its movers; ATTRIB.txt the order-blind whole-dump attribution of all nine
moved databases.

## Residues

* **R0 (the new SeqDriver head, 29 cmp lines, both modes)** — `@waiter.trigger;`
  at uvm-1.2 `src/base/uvm_config_db.svh:294`.  Golden binds the event control's
  `ref_obj` named `waiter` to the local `m_uvm_waiter waiter` class_var declared
  at :273; we emit the reference with a name and no `vpiActual`.  The failing
  field is the SINGULAR `ref_obj::Actual_group` (buvm13/15's shape), which is why
  the head prints the golden class_var as LHS and `RHS: <null>`.  Both sides
  agree on the task's four `vpiVariables` and on the sibling reference to the
  same variable at :289 — only the event-control one is unbound.
* **R1-import (uvm102's R1, narrowed by this pass's census)** — the parameter
  DECLARATION's typespec is still emitted on materialized IMPORT copies in a
  module's definition listing, on class parameters, on generate-block and
  function-local parameters, where golden has none.  Every one of those cells is
  visible in GRID.txt as a LATERAL.
* **R-class106** — a class's own `param_assign` Rhs constant (`uhdmallClasses`)
  keeps `ref_typespec -> int_typespec` where golden has the dangling reference;
  class parameters are not emitted through `emitParameters`, so this pass does
  not reach them.  Golden also lists `param_assign`s for imported package
  parameters INSIDE each class (20 such cells in SeqDriver alone) that we do not
  emit at all — GOLD-ONLY keys in the census.
* **R-func106** — golden is not self-consistent (to our current model) about the
  function-local Rhs reference: `a3_homes.sv`'s `function automatic int f();`
  gives NO typespec, while `r10v102repro/c03_func.sv`'s `function automatic int
  f03;` gives the DANGLING one.  The pass takes "none" for every function-local
  copy, which moves a3's cell to golden and leaves c03's wrong-differently
  (LATERAL, never a regression).  The distinguisher is undecoded.
* **R-ovsize** — an OVERRIDDEN untyped parameter's elaborated Rhs keeps golden's
  override LITERAL (`'hF`, size -1, no typespec) where we fold it to a plain
  decimal (`15`, size 32, `int_typespec`); a `defparam`'d one is `INT:14` with no
  size in golden and `UINT:14` size 32 in ours.  Pre-existing, deliberately not
  modelled here (the drain's re-read leaves those cells alone).
* **R-signdec** — the elaborated re-render of `parameter signed P = 'h5` /
  `parameter unsigned` decompiles `32'h5` in golden and `'h5` in ours, and a
  signed-based literal's elaborated decompile drops its `s` in golden (`'h1a`)
  but not in ours (`'sh1a`).  Pre-existing, both binaries.
* uvm104's **R-args / R-esc / R-assoc** (`src/TypeEmit.cpp:10359`) and
  MiniAmiq's 348-line head are unchanged by this pass.

## Files

`run106.sh` (three-way arm runner, rc per cell, both views), `tab106.py`
(per-cell table), `score106.py` (TO_GOLDEN / AWAY / LATERAL classifier, `PROJ=szts`
projects onto this pass's axes), `cen106.py` (keyed multiset census),
`scan106.py` (the a-priori source scan), `pred106.py` (the transitive-include
mover predictor), `attr106.sh` (order-blind per-database attribution),
`bnd106.sh` (the wide boundary, both halves), `a1_bases.sv` .. `a8_toponly.sv`
and `a7v_more.v` (the arms), `head_{before,after}_SeqDriver_{default,testflags}.cmp`.
