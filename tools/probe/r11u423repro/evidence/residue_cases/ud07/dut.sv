// residue (no law landed): see README
module top(output int y);
  localparam T = 'd12;
  wire [7:0] w = T;
  assign y = w;
endmodule
