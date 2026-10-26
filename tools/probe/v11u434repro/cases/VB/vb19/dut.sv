// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (input logic [4:0] x, output logic [4:0] y);
  if (W > 1) begin : g
    assign y[$bits(x)-1:0] = x;
  end
endmodule
