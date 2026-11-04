// § genBodyDefBitsKeepsCall434
module top (output [31:0] y);
  logic [4:0] x;
  if (1) begin: g
    assign y = $clog2($bits(x));
  end
endmodule
