// § genEnumVarLocatedConst262 (enum var typed by a typedef alias of the enum)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  typedef e_t e2_t;
  if (P) begin : g
    e2_t q; logic d;
    always_ff @(posedge clk) q <= t_i;
    assign d = (q == E_C) | v_i;
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
