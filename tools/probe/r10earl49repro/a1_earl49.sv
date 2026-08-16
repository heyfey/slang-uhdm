// a1: the FIRST hypothesis of this pass -- "the range bound being a PACKAGE
// parameter is what makes sram2tlul special" -- REFUTED.  b1/b2 kill it
// two-sidedly (identical answers with an own-parameter bound); a1 is kept
// because it is also the witness for residue R2: golden carries an EXTRA
// weak-tail `int_typespec` for the package parameter the range names, bound
// back through the module parameter's ref_typespec, and we do not.
//   pristine AND patched: DUMP_DIFF content=12 hunks=2, cmp heads=0.
package a1p;
  parameter int W = 32;
endpackage
module a1_earl49 #(
  parameter logic [a1p::W-1:0] A = 'h0
) ();
endmodule
