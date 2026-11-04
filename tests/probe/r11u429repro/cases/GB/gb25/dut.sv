// § genBodyBitsOuterNameKeeps429
module top #(parameter W = 3) (input clk, output logic [7:0] y);
  logic [W:0] x;
  if (W > 1) begin: g
    always @(posedge clk) y <= $bits(x);
  end
endmodule
