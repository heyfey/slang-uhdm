// residue (no law landed): a parenthesized gate-terminal index bit_select span (ModuleEmit, sister ground), see README
module top;
  wire [7:0] a, y;
  for (genvar i = 1; i < 4; i++) begin : g
    buf b1 (y[i], a[(i % 3)]);
  end
endmodule
