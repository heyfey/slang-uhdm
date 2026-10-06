// § genEnumVarLocatedConst262 (a module-body enum typedef, the generate variable of it)
module wb #(parameter bit P = 1) (input logic clk, input logic [1:0] t_i, input logic v_i, output logic o);
  typedef enum logic [1:0] { M_A, M_B, M_C } m_t;
  if (P) begin : g
    m_t q;
    always_ff @(posedge clk) q <= m_t'(t_i);
    assign o = (q == M_C) | v_i;
  end
endmodule
module top(input logic clk, input logic [1:0] t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
