// § bareDecUnderscoreDropped181 — underscores in an instance's parameter override and a port actual
module sub #(parameter int W = 1) (input logic [W-1:0] i, output logic [W-1:0] o); assign o = i; endmodule
module top(output logic [9:0] o);
  sub #(.W(1_0)) u(.i(1_0), .o(o));
endmodule
