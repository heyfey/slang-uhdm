// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y);
  logic [4:0] x;
  if (W > 4) begin : g
    assign y = $bits(x);
  end
  else begin : h
    assign y = 0;
  end
endmodule
