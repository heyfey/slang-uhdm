// residue (no law landed): sister ground, see README
module top(input logic [7:0] a, output logic [3:0] c, output logic [7:0] d);
  assign c[3:0] = $countones(a);
  assign d[2] = $onehot(a);
  logic [7:0] v;
  assign v = $countones(a);
endmodule
