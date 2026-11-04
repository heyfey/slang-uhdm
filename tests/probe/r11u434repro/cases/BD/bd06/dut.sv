// § genBodyDefBitsKeepsCall434
module top (output [3:0] y);
  if (1) begin: g
    logic [4:0] z;
    assign y = z[$bits(z)-2 -: 4];
  end
endmodule
