// residue (no law landed): sister ground, see README
module top(input logic [7:0] a, output logic [3:0] c);
  assign c = $clog2(a);
  wire [3:0] w = $clog2(8);
endmodule
