// § genEnumVarLocatedConst262 (enum typedef declared inside the gen block, var of it, gen-local LHS)
module wb #(parameter bit P = 1) (input logic clk, input logic [1:0] t_i, input logic v_i, output logic o);
  if (P) begin : g
    typedef enum logic [1:0] { G_A, G_B, G_C } g_t;
    g_t q; logic d;
    always_ff @(posedge clk) q <= g_t'(t_i);
    assign d = (q == G_C) | v_i;
    assign o = d;
  end
endmodule
module top(input logic clk, input logic [1:0] t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
