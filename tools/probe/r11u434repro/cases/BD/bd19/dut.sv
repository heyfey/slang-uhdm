// § genBodyDefBitsKeepsCall434
module top (output [31:0] y);
  logic [4:0] x;
  if (1) begin: g
    wire [31:0] w = $bits(x);
    assign y = w;
  end
endmodule
