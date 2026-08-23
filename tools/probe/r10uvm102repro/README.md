# r10uvm102 — implicit unsized based parameter declarations

## Result

An untyped, unranged, non-overridden parameter initialized by a known unsized
binary, octal, or hexadecimal literal has no declaration `vpiTypespec` in
Surelog.  Sized literals, explicit types and ranges, explicit signing,
unknown-valued literals, function-local parameters, and overridden parameters
retain their previous behavior.

The change intentionally touches only the parameter declaration edge.  The
`param_assign` initializer is not rewritten: Surelog gives package/definition
copies and elaborated module copies different constant/reference shapes, so a
single synthesized RHS rule overmatches.  The positive grid confirms that all
53 RHS objects remain on their pristine paths while 38 parameter objects per
view move to golden.

## Surelog producer

`CompileHelper.cpp:3795-3840` derives an implicit parameter type from a reduced
constant.  For `vpiHexConst`, `vpiOctConst`, and `vpiBinaryConst`, it creates
and attaches the `int_typespec` only when `VpiSize() != -1`.  An unsized based
literal has size `-1`, so the parameter remains typespec-less.  The later
`rhs->Typespec()` block can still create a dangling RHS reference, explaining
why deleting the whole type-building path was too broad.

## Acceptance

The ship binary is MD5 `4e1d739b21bf097f2c21e66889b765b6`, built from base
`ecdded75`.  All 1,588 Surelog rows and both 731-row uhdm2rtlil modes match the
accepted controls exactly.  Surelog has the predicted nine database movers;
uhdm2rtlil has zero.  The fresh-pair exhaustive boundary has no return-code or
output-presence asymmetry and no semantic mover outside the positive sources.

The official SeqDriver head advances from 17 to 64 lines in both modes.  Its
new mismatch is the imported class string constant at the next depth; the
other protected heads remain unchanged.  See `GRID.txt`, `CENSUS.txt`,
`GATES.txt`, and `BOUNDARY.txt`.

