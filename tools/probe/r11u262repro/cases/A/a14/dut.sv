// § genEnumVarLocatedConst262 (two instances at depth 1 and 2)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
  typedef enum logic [2:0] { F_A, F_B, F_C, F_D } f_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    e_t q; logic d;
    always_ff @(posedge clk) q <= t_i;
    assign d = (q != E_B) & v_i;
    assign o = d;
  end
endmodule
module mid(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u2(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic [1:0] o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o[0]));
  mid m(.clk(clk), .t(t), .v(v), .o(o[1]));
endmodule
