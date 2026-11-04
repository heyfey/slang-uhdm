// § elabTpDefaultDefNamed163
module leaf #(parameter int W = 4, parameter type t_t = logic [W-1:0]) (input t_t i, output t_t o);
  assign o = i;
endmodule
module mid #(parameter int W = 4) (input logic [W-1:0] i, output logic [W-1:0] o);
  leaf #(.W(W)) l(.i(i), .o(o));
endmodule
module top(input logic [6:0] i, output logic [6:0] o);
  mid #(.W(7)) m(.i(i), .o(o));
endmodule
