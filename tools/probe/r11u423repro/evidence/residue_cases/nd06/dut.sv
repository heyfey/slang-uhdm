// residue (no law landed): sister ground, see README
module top;
  real r;
  wire [63:0] n = $realtobits(r) + 1;
  wire [63:0] k = $rtoi(r);
endmodule
