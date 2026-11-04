// § genBodyDefBitsKeepsCall434
module child (output [31:0] y);
  logic [4:0] x;
  if (1) begin: g
    assign y = $bits(x);
  end
endmodule
module top (output [31:0] y);
  child u (.y(y));
endmodule
