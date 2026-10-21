// § genBlockBitsKeepsSelect200 (sister ground, ExprEmit: reported by r11u428)
module top (output [3:0] y);
  logic [4:0] x;
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = x[$bits(x)-1-i];
  end
endmodule
