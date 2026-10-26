// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y);
  logic [4:0] x;
  if (W > 1) begin : g
    logic [2:0] x;
    assign y = $bits(x);
  end
endmodule
