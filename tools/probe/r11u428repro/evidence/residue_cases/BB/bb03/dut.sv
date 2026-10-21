// § genBlockBitsKeepsSelect200 (sister ground, ExprEmit: reported by r11u428)
module top #(parameter W = 6) (output [W:0] y);
  logic [4:0] x;
  logic [7:0] p;
  wire a;
  if (W <= 4)
    assign y = x[($bits(x)-1)-:(1+W)];
  else
    assign y = { x, p[W+1-$bits(x)-1:0] ^ { (W+1-$bits(x)) { a } } };
endmodule
