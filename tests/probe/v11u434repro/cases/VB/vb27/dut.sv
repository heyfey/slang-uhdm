// § genBodyDefBitsKeepsCall434
module top #(parameter W = 0) (output logic [31:0] y [1]);
  logic [4:0] x;
  for (genvar i = 0; i < W; i++) begin : g
    assign y[i] = $bits(x);
  end
endmodule
