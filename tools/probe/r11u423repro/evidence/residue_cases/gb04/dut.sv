// residue (no law landed): sister ground, see README
module top #(parameter W = 3) (output int y);
  logic [4:0] c;
  if (W <= 4) begin : g
    assign y = $bits(logic [7:0]) + $bits(W);
  end
endmodule
