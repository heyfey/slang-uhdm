// § elabTpDefaultDefNamed163
module child #(parameter int W = 4, parameter type t_t = bit [W:1]) (input t_t i, output t_t o);
  assign o = i;
endmodule
module top(input logic [4:0] i, output logic [4:0] o, input logic [3:0] j, output logic [3:0] p);
  child #(.W(5)) u(.i(i), .o(o));
  child #(.t_t(logic [3:0])) v(.i(j), .o(p));
endmodule
