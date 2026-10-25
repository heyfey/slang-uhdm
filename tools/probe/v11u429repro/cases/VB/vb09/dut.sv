// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  typedef logic [4:0] t_t;
  t_t x;
  if (1) begin: g
    always_comb y = $bits(x);
  end
endmodule
