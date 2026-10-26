// § genBodyDefBitsKeepsCall434
module top (input [3:0] a, output [31:0] y);
  if (1) begin: g
    assign y = $bits(a) + 1;
  end
endmodule
