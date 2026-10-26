// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (input logic [6:0] x, output logic [31:0] y);
  if (W > 1) begin : g
    assign y = $bits(x) * 2;
  end
endmodule
