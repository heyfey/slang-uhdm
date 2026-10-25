// § genBodyBitsOuterNameKeeps429
module top (output logic [3:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin: g
    logic [4:0] z;
    always_comb y[i] = $bits(z);
  end
endmodule
