// § genBodyBitsOuterNameKeeps429
module top (input clk, input logic [5:0] a, output logic [7:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin: g
    always_ff @(posedge clk) y[i] <= $bits(a) + i;
  end
endmodule
