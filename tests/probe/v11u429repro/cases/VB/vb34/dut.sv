// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  logic signed [4:0] x;
  if (1) begin: g
    always_comb y = $signed($bits(x));
  end
endmodule
