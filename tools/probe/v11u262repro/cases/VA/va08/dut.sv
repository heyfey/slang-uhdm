// § genEnumVarLocatedConst262 (the constant as a part-select bound, a replication count and a case-equality operand)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    e_t q;
    logic [7:0] w;
    always_ff @(posedge clk) q <= t_i;
    assign w = {E_C{q == E_B}};
    assign o = w[E_B:E_A] === {E_C{v_i}};
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
