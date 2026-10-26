// § genBodyDefBitsKeepsCall434
module top (output [31:0] y);
  logic [4:0] x;
  if (1) begin: g
    assign y = {27'b0, x} + $bits(x) * 2;
  end
endmodule
