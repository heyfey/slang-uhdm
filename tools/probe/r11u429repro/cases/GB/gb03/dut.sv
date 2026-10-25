// § genBodyBitsOuterNameKeeps429
module top (output [3:0] y);
  if (1) begin: g
    logic [4:0] z;
    assign y = $bits(z);
  end
endmodule
