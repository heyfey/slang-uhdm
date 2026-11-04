// § genEnumVarLocatedConst262 (two-level generate: the outer block declares the variable, the inner reads the constant; and the reverse)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o, output logic p);
  if (P) begin : g
    e_t q;
    always_ff @(posedge clk) q <= t_i;
    if (P) begin : h
      e_t r;
      assign r = t_i;
      assign o = (q == E_C) | v_i;
      assign p = (r == E_A);
    end
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o, output logic p);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o), .p(p));
endmodule
