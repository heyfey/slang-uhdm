// § genEnumVarLocatedConst262 (enum declared by a macro from an included header, gen-local enum var)
`include "pkg.svh"
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input H_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    H_t q; logic d;
    always_ff @(posedge clk) q <= t_i;
    assign d = (q == H_C) | v_i;
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::H_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
