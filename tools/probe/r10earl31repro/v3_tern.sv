// r10earl31 VERIFIER arm v3 — THE MINIMAL OVER-FIRE WITNESS.
//
// One module, one statement: a package-parameter read in the TRUE ARM of a
// ternary that sits inside a part_select's LEFT bound.  Golden leaves that fold
// BARE (it spans the whole `pk::DC`, the bare class of § psBoundPkgParamTs31's
// own span observation), while § psBoundPkgParamTs31 stamps it, because the
// operation-only walk cannot tell a ternary ARM from an arithmetic operand.
//
// If this arm is PASS_CMP before the patch and CMP_FAIL after it, the law
// over-fires in a way `uhdm-cmp` can see, and the grid never measured the cell.
package pk;
  localparam logic [3:0] DC = 4'h2;
endpackage

module v3 (
  input  logic [31:0] d,
  output logic [31:0] y
);
  logic [31:0] a1;
  always_comb begin : blk
    a1 = 32'(d[(1 ? pk::DC : 1)-1:0]);
  end
  assign y = a1;
endmodule
