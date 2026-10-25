// § genBodyBitsOuterNameKeeps429
module top (output logic [3:0] y [2]);
  logic [4:0] x;
  for (genvar i = 0; i < 2; i++) begin: g
    always_comb y[i] = $bits(x) + i;
  end
endmodule
