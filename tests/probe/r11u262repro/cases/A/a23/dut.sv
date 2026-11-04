// § genEnumVarLocatedConst262 (two-level generate, var and assign in the inner scope)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic [1:0] v_i, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : f
    if (P) begin : g
      e_t q; logic d;
      always_ff @(posedge clk) q <= t_i;
      assign d = (q == E_C) | v_i[i];
      assign o[i] = d;
    end
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic [1:0] v, output logic [1:0] o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
