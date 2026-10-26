// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (input logic [4:0] a, output logic [31:0] y);
  logic [4:0] x;
  if (W > 1) begin : g
    assign y = ($bits(x) > 3) ? a : 0;
  end
endmodule
