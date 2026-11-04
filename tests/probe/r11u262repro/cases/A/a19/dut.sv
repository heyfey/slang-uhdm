// § genEnumVarLocatedConst262 (interface body gen scope, gen-local enum var)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
interface ifc import ip::*; #(parameter bit P = 1) (input logic clk);
  e_t t; logic v; logic o;
  if (P) begin : g
    e_t q; logic d;
    always_ff @(posedge clk) q <= t;
    assign d = (q == E_C) | v;
    assign o = d;
  end
endinterface
module top(input logic clk, output logic o);
  ifc i(.clk(clk));
  assign o = i.o;
endmodule
