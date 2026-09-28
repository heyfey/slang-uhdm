// § genScopeRangeQueryFold216 — $left of a port bound 2*W-1 (a non-name left operand) onto a module output from a gen-if
module top #(parameter int W = 3) (input logic [2*W-1:0] i, output logic [3:0] o);
  if (1) begin : g
    assign o = $left(i);
  end
endmodule
