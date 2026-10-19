// § parenCastNameUnsupTs410
module m #(parameter W = 4) (input logic [7:0] i, output logic [7:0] o);
  if (W > 2) begin : g
    assign o = (W)'(i);
  end
endmodule
module top;
  logic [7:0] a, b;
  m u(.i(a), .o(b));
endmodule
