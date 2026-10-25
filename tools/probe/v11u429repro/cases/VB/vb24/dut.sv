// § genBodyBitsOuterNameKeeps429
logic [5:0] uv;
module top (output logic [7:0] y);
  if (1) begin: g
    always_comb y = $bits(uv);
  end
endmodule
