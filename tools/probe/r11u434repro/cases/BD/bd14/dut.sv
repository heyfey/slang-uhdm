// § genBodyDefBitsKeepsCall434
module top (output [31:0] y);
  logic [4:0] x;
  if (1) begin: g
    logic [2:0] z;
    assign y = $bits(x) + $bits(z);
  end
endmodule
