// § genBodyDefBitsKeepsCall434
module top (output [31:0] y, output [31:0] z);
  logic [4:0] x;
  assign z = $bits(x);
  if (1) begin: g
    assign y = $bits(x);
  end
endmodule
