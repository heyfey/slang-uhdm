// § genEnumVarLocatedConst262 (enum var with an initializer, constant as unary and call argument)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic [1:0] o);
  function automatic logic [1:0] f(logic [1:0] a); return a + 1; endfunction
  if (P) begin : g
    e_t q = E_B; logic [1:0] d;
    always_ff @(posedge clk) q <= t_i;
    assign d = f(E_C) ^ ~E_A ^ q;
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic [1:0] o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
