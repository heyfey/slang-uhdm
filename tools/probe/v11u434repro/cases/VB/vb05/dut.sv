// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y, output logic [31:0] z);
  logic [3:0] x [5];
  if (W > 1) begin : g
    assign y = $size(x);
    assign z = $bits(x);
  end
endmodule
