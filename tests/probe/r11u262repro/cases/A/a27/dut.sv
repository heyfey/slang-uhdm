// § genEnumVarLocatedConst262 (struct var holding an enum member: control)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  typedef struct packed { e_t k; logic b; } s_t;
  if (P) begin : g
    s_t q; logic d;
    always_ff @(posedge clk) q.k <= t_i;
    assign d = (q.k == E_C) | v_i;
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
