// § genBodyDefBitsKeepsCall434
module top #(parameter W = 4) (output [31:0] y);
  logic [W-1:0] x;
  if (1) begin: g
    assign y = $bits(x);
  end
endmodule
