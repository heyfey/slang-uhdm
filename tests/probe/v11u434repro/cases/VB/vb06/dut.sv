// § genBodyDefBitsKeepsCall434
module child #(parameter W = 2) (output logic [31:0] y);
  logic [4:0] x;
  if (W > 1) begin : g
    assign y = $bits(x);
  end
endmodule
module top;
endmodule
