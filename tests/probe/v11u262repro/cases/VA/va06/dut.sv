// § genEnumVarLocatedConst262 (a compilation-unit enum typedef, the generate variable of it)
typedef enum logic [1:0] { U_A, U_B, U_C } u_t;
module wb #(parameter bit P = 1) (input logic clk, input u_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    u_t q;
    always_ff @(posedge clk) q <= t_i;
    assign o = (q == U_C) | v_i;
  end
endmodule
module top(input logic clk, input u_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
