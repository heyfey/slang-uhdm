// § genBodyBitsOuterNameKeeps429
module top (output [31:0] y);
  int k;
  if (1) begin: g
    assign y = $bits(k);
  end
endmodule
