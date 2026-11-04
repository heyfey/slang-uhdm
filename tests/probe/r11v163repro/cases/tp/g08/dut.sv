// § elabTpDefaultDefNamed163
module child #(parameter int W = 4, parameter type a_t = logic [W-1:0], parameter type b_t = a_t [1:0])
  (input b_t i, output b_t o);
  assign o = i;
endmodule
module top(input logic [9:0] i, output logic [9:0] o);
  child #(.W(5)) u(.i(i), .o(o));
endmodule
