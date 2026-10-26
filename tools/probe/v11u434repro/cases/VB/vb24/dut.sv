// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y, output logic [31:0] z);
  int x;
  byte b;
  if (W > 1) begin : g
    assign y = $bits(x);
    assign z = $bits(b);
  end
endmodule
