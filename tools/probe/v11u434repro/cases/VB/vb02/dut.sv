// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y [2]);
  logic [4:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = $bits(x) + i;
  end
endmodule
