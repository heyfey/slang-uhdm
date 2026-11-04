// § elabTpDefaultDefNamed163
module child #(parameter int W = 4, parameter type t_t = logic [W-1:0][1:0]) (input t_t i, output t_t o);
  assign o = i;
endmodule
module top(input logic [9:0] i, output logic [9:0] o);
  child #(.W(5)) u(.i(i), .o(o));
endmodule
