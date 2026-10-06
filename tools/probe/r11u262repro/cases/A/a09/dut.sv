// § genEnumVarLocatedConst262 (for-generate, gen-local enum var)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
  typedef enum logic [2:0] { F_A, F_B, F_C, F_D } f_t;
endpackage
module wb import ip::*; (input logic clk, input e_t t_i, input logic [1:0] v_i, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    e_t q; logic d;
    always_ff @(posedge clk) q <= t_i;
    assign d = (q == E_C) | v_i[i];
    assign o[i] = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic [1:0] v, output logic [1:0] o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
