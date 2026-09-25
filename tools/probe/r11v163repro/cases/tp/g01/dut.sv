// § elabTpDefaultDefNamed163
module child #(parameter int W = 8, parameter int D = 2, parameter type t_t = logic [W-1:0][D-1:0])
  (input t_t i, output t_t o);
  assign o = i;
endmodule
module top(input logic [15:0] i, output logic [15:0] o, input logic [5:0] j, output logic [5:0] p);
  child u(.i(i), .o(o));
  child #(.W(3)) v(.i(j), .o(p));
endmodule
