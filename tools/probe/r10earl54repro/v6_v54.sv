// v54 VERIFIER ARM v6 — MACRO SPANS AND THE AMBIG PATH.
// The match key is (line,col,endline,endcol) via locLineCol, which maps macro
// locations.  Two distinct ReplicationExpressions that map to ONE key must make
// the arm DECLINE BOTH (the `ambig` set); a key that maps to the WRONG node
// folds the wrong value into a cmp-visible field.  Macro bodies are the only
// place two source nodes can share a virtual span.
`define REP4 {4{1'b1}}
`define TWO  {`REP4, `REP4}
`define RN(N) {N{1'b0}}
module snkv6_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule
module v6_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w1, w2, w3, w4;
  snkv6_54 u_m1 (.a({sel ? d[3:0] : `REP4, 4'h1}), .o(w1));
  // ONE macro body, TWO replications -> two nodes whose virtual spans are both
  // derived from the same invocation site
  snkv6_54 u_m2 (.a(`TWO), .o(w2));
  // the SAME macro invoked twice on ONE line
  snkv6_54 u_m3 (.a({`RN(4), `RN(4)}), .o(w3));
  // macro invocation inside a ternary arm, twice
  snkv6_54 u_m4 (.a({sel ? `RN(4) : `RN(4), 4'h2}), .o(w4));
  assign q = w1 ^ w2 ^ w3 ^ w4;
endmodule
