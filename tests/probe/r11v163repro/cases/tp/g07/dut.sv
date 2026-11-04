// § elabTpDefaultDefNamed163
module child #(parameter int W = 8, parameter type t_t = logic [W-1:0]) (input t_t i, output t_t o);
  localparam int L = $bits(t_t);
  t_t r;
  assign r = i;
  assign o = r;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    child u(.i(i), .o());
  end
  assign o = i;
endmodule
