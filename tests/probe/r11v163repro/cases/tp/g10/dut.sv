// § elabTpDefaultDefNamed163
module child #(parameter int W = 4, parameter type t_t = logic signed [2*W-1:W]) (input t_t i, output t_t o);
  assign o = i;
endmodule
module top(input logic [4:0] i, output logic [4:0] o);
  child #(.W(5)) u(.i(i), .o(o));
endmodule
