// § genEnumVarLocatedConst262 (the constant as a function-call argument, the enum variable with an initializer)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  function automatic logic eq(input e_t a, input e_t b); return a == b; endfunction
  if (P) begin : g
    e_t q = E_A;
    always_ff @(posedge clk) q <= t_i;
    assign o = eq(q, E_C) | v_i;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
