// § parenCastReadsCastSyntax288 — a parenthesized cast born in a macro body, and parentheses written around a macro cast
`define CI(v) (int'(v))
`define CB(v) byte'(v)
module top(input logic [7:0] x, output int o, o2, o3);
  assign o = `CI(x) + 1;
  assign o2 = (`CB(x)) + 1;
  assign o3 = (`CI(x));
endmodule
