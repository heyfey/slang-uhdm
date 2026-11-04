// § genEnumVarLocatedConst262 (module-local enum, gen-local enum var)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
  typedef enum logic [2:0] { F_A, F_B, F_C, F_D } f_t;
endpackage
module wb #(parameter bit P = 1) (input logic clk, input logic [1:0] t_i, input logic v_i, output logic o);
  typedef enum logic [1:0] { M_A, M_B, M_C } m_t;
  if (P) begin : g
    m_t q; logic d;
    always_ff @(posedge clk) q <= m_t'(t_i);
    assign d = (q == M_C) | v_i;
    assign o = d;
  end
endmodule
module top(input logic clk, input logic [1:0] t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
