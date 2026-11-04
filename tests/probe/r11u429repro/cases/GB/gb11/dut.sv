// § genBodyBitsOuterNameKeeps429
module top (output [3:0] y);
  logic [4:0] x;
  assign y = $bits(x);
endmodule
