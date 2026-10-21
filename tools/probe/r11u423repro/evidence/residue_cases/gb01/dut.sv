// residue (no law landed): sister ground, see README
module top #(parameter W = 3) (output logic [W:0] y);
  logic [4:0] c;
  if (W <= 4)
    assign y = c[($bits(c)-1)-:(1+W)];
endmodule
