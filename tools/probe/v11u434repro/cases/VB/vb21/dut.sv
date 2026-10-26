// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y);
  logic [3:0][4:0] x;
  if (W > 1) begin : g
    assign y = $size(x, 2);
  end
endmodule
