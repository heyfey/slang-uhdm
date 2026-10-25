// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  logic [3:0] x [3];
  if (1) begin: g
    always_comb y = $bits(x);
  end
endmodule
