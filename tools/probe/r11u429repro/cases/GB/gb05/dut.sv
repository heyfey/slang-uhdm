// § genBodyBitsOuterNameKeeps429
module top (output [3:0] y);
  if (1) begin: g
    assign y = $bits(y);
  end
endmodule
