// § genScopeRangeQueryFold216 — $high of a ranged parameter onto a module output inside a gen-if
module top(output logic [7:0] o);
  parameter [9:2] a = 3;
  if (1) begin : g
    assign o = $high(a);
  end
endmodule
