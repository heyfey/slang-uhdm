// § genEnumVarLocatedConst262 (the top module's own if-generate)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
module top import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t, output logic o);
  if (P) begin : g
    e_t q;
    always_ff @(posedge clk) q <= t;
    assign o = (q != E_B);
  end
endmodule
