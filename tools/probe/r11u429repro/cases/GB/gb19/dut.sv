// § genBodyBitsOuterNameKeeps429
module top (input [6:0] a, output logic [3:0] y);
  if (1) begin: g
    always_comb y = $bits(a);
  end
endmodule
