// v54 VERIFIER ARM v12 — SHAPES THAT COULD MAKE tryEval SUCCEED WHERE GOLDEN'S
// REDUCER FAILS (or vice versa), and the recursion/aliasing limits.
//   * a replication whose body is a FUNCTION CALL of a constant function:
//     slang's tryEval evaluates it, Surelog's reduceExpr may not.
//   * a replication whose count comes from $clog2 / $bits.
//   * a replication whose body reads a LOCALPARAM of the CHILD (not visible in
//     the parent's scope) -- the ASTContext is the ROOT, so a lookup-scope bug
//     would show here.
//   * 12 nested concats/replications: the walk is recursive with no depth cap.
package pk12_54;
  parameter int K = 4;
  function automatic int f12(int x); return x + 1; endfunction
endpackage
module snk12_54 #(parameter int WD = 8) (input [WD-1:0] a, output [WD-1:0] o);
  localparam logic [3:0] CHILD_ONLY = 4'hC;
  assign o = ~a;
endmodule
module v12_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w1, w2, w3, w4;
  // constant FUNCTION CALL in the count
  snk12_54 #(.WD(8)) u_fn (.a({sel ? d[3:0] : {pk12_54::f12(3){1'b1}}, 4'h1}), .o(w1));
  // $clog2 / $bits in the count
  snk12_54 #(.WD(8)) u_cl (.a({sel ? d[3:0] : {$clog2(16){1'b0}}, 4'h2}), .o(w2));
  snk12_54 #(.WD(8)) u_bt (.a({sel ? d[3:0] : {$bits(pk12_54::K)/8{1'b1}}, 4'h3}), .o(w3));
  // DEEP nesting: 6 replications, each inside the previous one's concat
  snk12_54 #(.WD(8)) u_dp (.a({sel ? d[3:0] :
      {1{ {1{ {1{ {1{ {1{ {4{1'b1}} }} }} }} }} }}, 4'h4}), .o(w4));
  assign q = w1 ^ w2 ^ w3 ^ w4;
endmodule
