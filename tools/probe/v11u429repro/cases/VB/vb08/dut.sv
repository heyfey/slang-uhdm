// § genBodyBitsOuterNameKeeps429
module top (output logic [3:0] y);
  wire [6:0] x;
  if (1) begin: g
    always_comb y = $bits(x);
  end
endmodule
