// § genBodyBitsOuterNameKeeps429
module top (input logic [15:0] a, output logic [15:0] y);
  logic [3:0] x;
  if (1) begin: g
    always_comb y = a << $bits(x);
  end
endmodule
