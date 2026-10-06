// § genEnumVarLocatedConst262 (an anonymous enum variable declared in the generate block)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    enum logic [1:0] { X0, X1, X2 } q;
    always_ff @(posedge clk) q <= X0;
    assign o = (q == X2) | v_i;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
