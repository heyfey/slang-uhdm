// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  logic [4:0] x;
  if (1) begin: g
    always_comb y = $bits(x[3:0]) + $bits(x);
  end
endmodule
