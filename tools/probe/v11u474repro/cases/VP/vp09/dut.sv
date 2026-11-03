// § elabParamClsScopedSubst474 (attack: generate-block body net and the instance in a generate loop)
package p; class S; localparam w = 16; endclass endpackage
module sub #(A = 8) ();
  logic [A-1:0] d;
  if (1) begin : g
    logic [A-1:0] e;
  end
endmodule
module top; import p::*;
  for (genvar k = 0; k < 2; k++) begin : gl
    sub #(.A(S::w)) u();
  end
endmodule
