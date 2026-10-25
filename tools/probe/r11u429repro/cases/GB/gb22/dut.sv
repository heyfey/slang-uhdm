// § genBodyBitsOuterNameKeeps429
module top (output logic [3:0] y);
  logic [4:0] x;
  always_comb y = $bits(x);
endmodule
