// § genBodyDefBitsKeepsCall434
module top (output [31:0] y);
  logic [4:0] x [3];
  if (1) begin: g
    assign y = $size(x);
  end
endmodule
