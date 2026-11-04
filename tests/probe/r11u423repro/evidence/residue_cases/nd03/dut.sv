// residue (no law landed): sister ground, see README
module top(input logic [7:0] a);
  wire [7:0] n = $countones(a);
  wire n2 = $onehot(a);
endmodule
