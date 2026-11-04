// § genEnumVarLocatedConst262 (two gen-local enum vars, the first of another enum type)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
  typedef enum logic [2:0] { F_A, F_B, F_C, F_D } f_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    f_t r; e_t q; logic d;
    always_ff @(posedge clk) begin q <= t_i; r <= F_C; end
    assign d = (q == E_C) | v_i | (r == F_D);
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
