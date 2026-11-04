// § genBodyBitsOuterNameKeeps429
module top (output [3:0] y);
  logic [4:0] x;
  if (1) begin: g
    logic [2:0] z;
    assign y = $bits(x) + $bits(z);
  end
endmodule
