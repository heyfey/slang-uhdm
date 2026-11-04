// § elabTpDefaultDefNamed163
package pk; parameter int PW = 6; endpackage
module child #(parameter type t_t = logic [pk::PW-1:0]) (input t_t i, output t_t o);
  assign o = i;
endmodule
module top(input logic [5:0] i, output logic [5:0] o);
  child u(.i(i), .o(o));
endmodule
