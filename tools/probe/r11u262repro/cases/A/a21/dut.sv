// § genEnumVarLocatedConst262 (unpacked array of enum in the gen scope: control)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    e_t q [2]; logic d;
    always_ff @(posedge clk) q[0] <= t_i;
    assign d = (q[0] == E_C) | v_i;
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
