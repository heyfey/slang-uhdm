// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y [2]);
  logic [4:0] x;
  if (W > 1) begin : g
    for (genvar i = 0; i < 2; i++) begin : h
      assign y[i] = $bits(x) - i;
    end
  end
endmodule
