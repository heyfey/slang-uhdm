// residue (no law landed): sister ground, see README
module top(input logic [7:0] a);
  wire [7:0] n = $signed(a);
  wire [7:0] m = $unsigned(a);
endmodule
