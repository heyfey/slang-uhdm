// § parenCastNameUnsupTs410
module m #(parameter W = 4) (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 1; k++) begin : g
    assign o = ((W))'(i);
  end
endmodule
module top;
endmodule
