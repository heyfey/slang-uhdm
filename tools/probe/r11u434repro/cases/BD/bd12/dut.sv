// § genBodyDefBitsKeepsCall434
module top (output [31:0] y);
  logic [4:0] x;
  assign y = $bits(x);
endmodule
