// § genEnumVarLocatedConst262 (gen-scope continuous assignment of an enum constant under a macro from an included header)
`include "e.svh"
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    e_t q; logic d;
    always_ff @(posedge clk) q <= t_i;
    assign d = `IS_C(q) | v_i;
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
