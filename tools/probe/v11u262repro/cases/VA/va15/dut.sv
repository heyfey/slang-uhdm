// § genEnumVarLocatedConst262 (the constant in a for-generate's nested if-generate with its own enum variable, instance depth 2)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  logic [1:0] r;
  for (genvar i = 0; i < 2; i++) begin : gf
    if (P) begin : g
      e_t q;
      always_ff @(posedge clk) q <= t_i;
      assign r[i] = (q == E_C);
    end
  end
  assign o = |r | v_i;
endmodule
module mid(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  mid m(.clk(clk), .t(t), .v(v), .o(o));
endmodule
