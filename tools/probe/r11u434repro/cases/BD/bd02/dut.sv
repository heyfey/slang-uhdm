// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output [31:0] y);
  logic [4:0] x;
  if (W <= 4)
    assign y = $bits(x);
endmodule
