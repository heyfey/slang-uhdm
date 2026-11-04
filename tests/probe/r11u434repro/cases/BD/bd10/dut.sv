// § genBodyDefBitsKeepsCall434
module top (output [31:0] y);
  logic [4:0] x;
  if (1) begin: g
    wire [$bits(x)-1:0] w;
    assign w = x;
    assign y = w;
  end
endmodule
