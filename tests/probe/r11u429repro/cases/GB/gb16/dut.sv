// § genBodyBitsOuterNameKeeps429
module top (input clk, output logic [3:0] y);
  logic [4:0] x;
  if (1) begin: g
    always_ff @(posedge clk) y <= $bits(x) - 1;
  end
endmodule
