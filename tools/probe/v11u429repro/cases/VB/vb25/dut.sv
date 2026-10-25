// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y [2]);
  for (genvar k = 0; k < 2; k++) begin: g
    always_comb begin
      y[k] = 0;
      for (int i = 0; i < 2; i++) y[k] = y[k] + $bits(i);
    end
  end
endmodule
