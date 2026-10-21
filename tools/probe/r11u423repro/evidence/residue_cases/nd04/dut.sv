// residue (no law landed): sister ground, see README
module top;
  real r;
  wire [63:0] n;
  assign n = $realtobits(r);
endmodule
