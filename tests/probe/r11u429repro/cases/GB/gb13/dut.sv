// § genBodyBitsOuterNameKeeps429
module top (output [3:0] y);
  typedef logic [4:0] t_t;
  t_t x;
  if (1) begin: g
    assign y = $bits(x);
  end
endmodule
