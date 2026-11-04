// § genEnumVarLocatedConst262 (a macro-born constant from an include in another root file)
`include "inc.svh"
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    e_t q;
    always_ff @(posedge clk) q <= t_i;
    assign o = (q == `CONST_C) | v_i;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
