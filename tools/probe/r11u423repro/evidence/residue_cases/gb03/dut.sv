// residue (no law landed): sister ground, see README
module top #(parameter W = 3) (output int y);
  logic [4:0] c;
  for (genvar i = 0; i < 1; i++)
    assign y = $bits(c) + i;
endmodule
