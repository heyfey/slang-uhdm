// § genBodyBitsOuterNameKeeps429
module top #(parameter W = 2) (output [3:0] y);
  if (1) begin: g
    assign y = $bits(W);
  end
endmodule
