// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  logic [4:0] x;
  if (1) begin: g
    always_comb begin
      int k = $bits(x);
      y = k;
    end
  end
endmodule
