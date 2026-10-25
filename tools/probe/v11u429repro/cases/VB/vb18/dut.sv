// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    logic [i+3:0] z;
    if (i == 1) begin: h
      always_comb y = $bits(z);
    end
  end
endmodule
