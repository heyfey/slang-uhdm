// § genEnumVarLocatedConst262 (top-level module generate without an instance, depth 0)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module top import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    e_t q; logic d;
    always_ff @(posedge clk) q <= t_i;
    assign d = (q == E_C) | v_i;
    assign o = d;
  end
endmodule
