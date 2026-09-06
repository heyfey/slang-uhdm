// r10earl110 arm g5 -- THE NEGATIVE CONTROLS.  Every cell here must be
// BYTE-IDENTICAL between the pristine and the patched binary; a gate that can
// see is proved by g1/g2 converting in the same run.
package pk5_110;
  typedef struct packed { logic [31:0] val; } n_t;
endpackage

module g5_neg110 #(parameter int unsigned NN = 2) (
  input  pk5_110::n_t narr [NN],
  output logic [31:0] nres
);
  localparam int unsigned NA = 6;
  logic [31:0] n1, n2, n3, n4, n5, n6;
  for (genvar g5 = 0; g5 < NN; g5++) begin : blk_g5
    // n1 both halves literal
    assign n1 = { 26'b0, narr[g5].val[0+:6] };
    // n2 a literal arithmetic half, no parameter anywhere
    assign n2 = { 26'b0, narr[g5].val[0+:(8-2)] };
    // n3 a GENVAR-only arithmetic half (no parameter leaf)
    assign n3 = { 27'b0, narr[g5].val[(g5+1)+:5] };
    // n4 a bare parameter width -- the PRE-EXISTING law, must not move
    assign n4 = { 26'b0, narr[g5].val[0+:NA] };
    // n5 a simple part select with literal bounds
    assign n5 = { 26'b0, narr[g5].val[5:0] };
    // n6 a plain bit select
    assign n6 = { 31'b0, narr[g5].val[NA] };
  end
  assign nres = n1 ^ n2 ^ n3 ^ n4 ^ n5 ^ n6;
endmodule
