# r10v110 — the ADVERSARIAL VERIFICATION of r10uvm110 (§ `dynArrayNewLvalueBaseOnly110`)

Base commit `28f373a`.  Everything here is MEASUREMENT-ONLY; the official
`uhdm-cmp` is the only judge.  The full reproduction log, gate by gate, is
`VERIFY.r10uvm110.txt`.

**Verdict: ACCEPT.**  Every headline number in the implementer's report was
reproduced bit-for-bit from binaries this verifier built itself (pristine
`f65953e2…`, shipped `2e26d5e5…`), and no arm, corpus row, canary, or boundary
cell moves AWAY from golden anywhere.  One committed residue paragraph
(R-static110) was measurably WRONG and is corrected in
`../r10uvm110repro/README.md`; the production source is untouched by this
verification.

## Instruments

* `vrun110.sh <arm.sv> [srcs…]` — three-way runner (golden Surelog / pristine /
  shipped) in BOTH views, rc per cell, children `</dev/null`, scratch keyed on
  the RELATIVE arm path.  Prints the OFFICIAL `uhdm-cmp` line count for
  golden-vs-pristine and golden-vs-shipped, plus an order-blind whole-dump
  multiset difference in both directions.
* `vcen110.py` — a VIEW-GENERAL assignment census read off the `uhdm-dump`
  TREE.  Key = (nearest named ancestor LEAF, assignment START LINE) so a cell
  can be NAMED in a report.  The value carries every judge-visible axis of the
  Lhs subtree that a generated `Compare` reads — object KIND, `VpiName` LEAF,
  `VpiDefName`, **`VpiDecompile`**, **`VpiSize`**, `VpiValue`/`VpiConstType`,
  and the ref's `vpiActual` (kind + leaf) — i.e. the decompile / size / typespec
  axes that `cen110.py`'s `PROJ=1` projection DROPS.  No span, no
  `VpiFullName`, no file (no generated `Compare` reads them).
* `vscore110.sh <arm.sv>` — TO_GOLDEN / AWAY / LATERAL / STILL per cell, both
  views, LHS always golden, multiset per key.

## Arms (11 files, ~130 assignment cells, all scored in BOTH views)

| arm | axis |
|---|---|
| `v1_prod.sv` | statement HOME: `always@` / `always_comb` / `final` / named block / nested `begin` / `repeat` / `forever` / `fork…join` / `join_any` / static task / automatic task / automatic function / `case` / `casex` / `while` / package task / package function / out-of-body TASK |
| `v2a_scope.sv` | `::`-scoped receivers: instance-qualified static property, CLASS-scoped static property, package-scoped handle, imported handle, undotted controls |
| `v2b_sel.sv` | selects around the dot: middle fixed / variable / queue / associative index, TRAILING index on the member, two dots, element-write controls |
| `v2c_formal.sv` | module variable, `input`/`ref`/`inout` formals, function formal, the module instantiated THREE times |
| `v2d_this.sv` | the `this.`/`super.` fences carrying SELECTS and deep chains |
| `v3_rhs.sv` | `new [n]` size = parameter / localparam / package parameter / METHOD CALL / expression / `$size` / `$bits` / ternary / cast / enum; the copy form; and 13 non-`new[]` controls in the SAME dotted shape |
| `v4_bind.sv` | the bind-window replay: formal DEFAULT, RETURN-NAME receiver, collection-arg + named-block local, control body, loop body, package handle through an instance |
| `v5_vif.sv` | hierarchical receivers: interface-port member, cross-instance array, cross-instance dotted, named-instance interface member |
| `v6_odd.sv` | `#1 h.a = new [4]`, `@(posedge c) h.b = new [5]`, static class method, STATIC local in an automatic task, size reading another member, two cells on one line |
| `v7_fence2.sv` | `this.`/`super.` under `#1` and `@(posedge)`, in a CONSTRUCTOR and an OUT-OF-BODY task; a SHADOWED base name; nested-struct receivers |
| `v8_unbound.sv` | a dotted `new [n]` onto a FIXED array — slang refuses the whole file on both binaries, so the predicate's syntax fallback is unreachable there |

**AWAY = 0 in every arm and every view**, including the pass's own four arms
re-scored with this stricter comparator.  Assignment-object counts are unchanged
between pristine and shipped everywhere except `a1_shapes.sv`/elab, where the
shipped binary emits 137 against the pristine 143 and golden's 136 — toward
golden.  The patch never adds or drops a statement.

`v2c_formal.sv` and `tools/probe/r10svs3repro/a1_newlhs.sv` (another pass's arm,
written for § `thisSuperNewAssignNoStmt3`) are judged **EQUAL to golden by the
official `uhdm-cmp` under the shipped binary in BOTH views**, and are NOT equal
under the pristine one.

## Boundary

The per-FILE half (3435 `.sv`/`.v`, 4 shards) reproduces the implementer's, and
this verification adds the per-DIRECTORY half (1519 directories, 2 shards) that
the pass did not run.  `LISTED == PROCESSED`, `RC_DIFF = 0`, `ASYM = 0` in all
six shards.  Every cell whose SORTED dumps differ is an arm of this pass, an arm
of this verifier, `r10svs3repro/a1_newlhs.sv`, or `r10buvm22repro/g22.sv` (the
pre-existing pointer-valued UINT, R-fuaCast110).  The per-directory half found
five further cells whose UNSORTED dumps differ and whose SORTED dumps are
IDENTICAL — pure emission ORDER, the documented parallel-parse nondeterminism.
