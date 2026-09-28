// § genScopeRangeQueryFold216 — a bound made of a pasted token, and the query written inside a macro argument
`define HI(n) n``1
`define ID(x) x
module top();
  parameter [`HI(1):2] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign c1 = `ID($high(a));
  end
endmodule
