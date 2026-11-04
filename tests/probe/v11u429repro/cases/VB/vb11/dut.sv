// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  int x;
  if (1) begin: g
    always_comb y = $bits(x);
  end
endmodule
