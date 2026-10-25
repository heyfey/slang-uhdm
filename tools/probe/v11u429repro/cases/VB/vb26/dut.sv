// § genBodyBitsOuterNameKeeps429
module top (input logic [3:0] a, output logic [7:0] y);
  logic [4:0] x;
  if (1) begin: g
    always_latch if (a[0]) y = $bits(x);
  end
endmodule
