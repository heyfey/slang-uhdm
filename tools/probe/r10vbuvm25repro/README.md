# r10vbuvm25 — independent verification of § foreachPkgClassArrayVar25

**VERIFIER VERDICT: ACCEPT-WITH-FIX.**  The implementer patch had two
adversarial overmatches.  This verifier narrowed the production predicate,
then repeated the complete battery.  The final patch clears the 56-line
BuildUVMPkg head in both modes and exposes the same 72-line next head.  No
corpus row converts.  Official `uhdm-cmp` is the acceptance judge.

BASE: `551c0c4899a8335ebcf92d80ddf5e2eff6214fb9`.

## Independent build and reproduction

Fresh pristine and patched worktrees were configured separately and built
with `-j 2`.  Frozen binary md5s were:

* pristine `fc895cc8a86aea2fdee0d952693f94d3`
* implementer patch `3c54685b8c8289c786f3a75078ead3ea`
* verifier-fixed final `563dea6c67dd56ee5029bbd9d71a2ed5`

The first two hashes reproduce the implementer's independent-build hashes
exactly.  Rebuilding after the verifier's explanatory comment left the final
hash unchanged.

The implementer grid reproduced exactly: golden-vs-golden calibration is
clean, and agreement is `109 -> 125` over the two database views, exactly 16
objects to golden and zero away.  The nine-row UVM census also reproduces
bit-for-bit: `9301 agree / 64 differ -> 9303 / 62`; BuildUVMPkg is `769/4 ->
770/3` in each mode and every other row is unchanged.

## Adversarial break and fix

`vg25.sv` varies direct and typedef'd queues/dynamic/fixed arrays, direct and
typedef'd class elements, a parameterized class specialization, an abstract
class, multi-dimensional arrays and an omitted foreach dimension; package,
foreign-package, task, class, compilation-unit, module, interface and program
homes; bare and package-qualified references; and both def/elab databases.

It found two newly introduced wrong edges:

1. A typedef of the whole container is not treated as an anonymous array by
   Surelog.  Its late-bound loop variable is a `class_var` whose class typespec
   names the typedef.  Canonicalizing the declared type erased that decider and
   changed pristine-right cells to patched-wrong.
2. A package-qualified written reference does not take the bare-name
   late-binding path.  Surelog falls back to `int_var`; the implementer patch
   changed an already-wrong `class_var` to another wrong `array_var`, a move
   away from the measured law.

The fix requires the written array syntax to be an `IdentifierName` and the
declared container type itself not to be `TypeAlias`.  Element typedefs remain
in-law because the outer queue/array declaration is still direct.  The fixed
adversarial grid has six distinct source movers, all toward golden and none
away: default agreement `27/43 -> 33/43`; elab object agreement `56 -> 72`.
All typedef-container, qualified-reference, multidimensional and non-package
controls retain their pristine shapes.

## Gates and next head

Build, 23 goldens plus negative control, both full corpora and modes, exact row
and byte attribution, canaries and protected pins, and the four-way full probe
boundary are green.  The only corpus byte movers are BuildUVMPkg/default and
BuildUVMPkg/testflags; uhdm2rtlil moves 0/1358.  Full details are in
`GATES.txt`, `GRID.txt`, and `BOUNDARY.txt`.

The next head is unchanged from the implementer report: at `uvm_pkg.sv:45158`
in `uvm_port_component::get_connected_to`, `list[name] =
list1[name].get_comp();`.  Golden LHS is a `hier_path` containing
`bit_select(list1[name])` followed by `method_func_call(get_comp)`; ours loses
the method-call suffix.  Both modes have one 72-line official head.
