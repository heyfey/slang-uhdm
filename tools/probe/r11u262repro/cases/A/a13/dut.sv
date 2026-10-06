// § genEnumVarLocatedConst262 (constant slots: replication count and indexed part-select width, gen-local enum var)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
  typedef enum logic [2:0] { F_A, F_B, F_C, F_D } f_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic [7:0] v_i, output logic [3:0] o);
  if (P) begin : g
    e_t q; logic [3:0] d;
    always_ff @(posedge clk) q <= t_i;
    assign d = {{E_C{q == E_A}}, v_i[0+:E_B]} | v_i[3:E_C];
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic [7:0] v, output logic [3:0] o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
