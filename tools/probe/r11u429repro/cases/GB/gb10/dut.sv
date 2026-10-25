// § genBodyBitsOuterNameKeeps429
module top (output [3:0] y);
  logic [4:0] x;
  if (1) begin: g
    localparam int L = $bits(x);
    assign y = L;
  end
endmodule
