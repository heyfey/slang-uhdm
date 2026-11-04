// § genBlockBitsKeepsSelect200 (sister ground, ExprEmit: reported by r11u428)
module top #(parameter W = 2) (output [1:0] y);
  logic [4:0] x;
  assign y = x[$bits(x)-1 -: 2];
endmodule
