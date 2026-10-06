// § genEnumVarLocatedConst262 (enum var at module level, gen-local LHS: control)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
  typedef enum logic [2:0] { F_A, F_B, F_C, F_D } f_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  e_t q;
  always_ff @(posedge clk) q <= t_i;
  if (P) begin : g
    logic d;
    assign d = (q == E_C) | v_i;
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
