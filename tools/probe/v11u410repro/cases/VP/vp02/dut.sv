// § parenCastNameUnsupTs410
module top #(parameter W = 4) (input logic [7:0] x, output logic [7:0] y);
  if (W > 1) begin : g
    always_comb y = ((W))'(x);
  end
endmodule
