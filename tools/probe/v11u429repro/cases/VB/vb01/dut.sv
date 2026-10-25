// § genBodyBitsOuterNameKeeps429
module top (input logic [7:0] a, output logic [7:0] y);
  logic [4:0] x;
  if (1) begin: g
    always_comb begin
      y = 0;
      for (int i = 0; i < $bits(x); i++) y[i] = a[i];
    end
  end
endmodule
