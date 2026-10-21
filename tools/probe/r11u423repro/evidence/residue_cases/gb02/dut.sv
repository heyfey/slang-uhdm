// residue (no law landed): sister ground, see README
module top #(parameter W = 3) (output int y);
  logic [4:0] c;
  if (W <= 4)
    assign y = $bits(c);
endmodule
