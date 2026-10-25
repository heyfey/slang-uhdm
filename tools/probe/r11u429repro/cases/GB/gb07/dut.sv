// § genBodyBitsOuterNameKeeps429
module top #(parameter W = 2) (output [1:0] y);
  logic [4:0] x;
  if (W <= 4)
    assign y = x[($bits(x)-1)-:(W)];
endmodule
