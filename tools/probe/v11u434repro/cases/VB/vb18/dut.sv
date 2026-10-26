// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y);
  logic [4:0] x;
  if (W > 1) begin : g
    wire [31:0] w = $bits(x);
    assign y = w;
  end
endmodule
