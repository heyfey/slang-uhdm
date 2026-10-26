// § genBodyDefBitsKeepsCall434
module top (input [7:0] a, output [4:0] y);
  logic [4:0] x;
  if (1) begin: g
    assign y = $bits(x)'(a);
  end
endmodule
