// § genEnumVarLocatedConst262 (a packed array of the enum declared before an enum variable)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    e_t [1:0] qa;
    e_t q;
    always_ff @(posedge clk) begin q <= t_i; qa <= {t_i, t_i}; end
    assign o = (q == E_C) | (qa[0] == E_B) | v_i;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
