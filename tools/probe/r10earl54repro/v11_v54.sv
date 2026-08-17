// v54 VERIFIER ARM v11 — TRANSITIVE parameter initializers.
// foldConnReplNested54 visits the initializer of a parameter named DIRECTLY in
// the conn, one level only.  A replication reached through a SECOND parameter
// is therefore not in `reps`: the arm must ABSTAIN (a missed fold), never fold
// with some other node's value.
package pk11_54;
  parameter logic [3:0] PA = {4{1'b1}};
  parameter logic [7:0] PB = {PA, 4'h0};
  parameter logic [7:0] PC = {2{4'hA}};
endpackage
module snk11_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule
module v11_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w1, w2, w3;
  snk11_54 u_direct (.a(pk11_54::PC), .o(w1));            // one level
  snk11_54 u_trans  (.a(pk11_54::PB), .o(w2));            // TWO levels
  snk11_54 u_mixed  (.a({sel ? pk11_54::PB[7:4] : {4{1'b0}}, 4'h3}), .o(w3));
  assign q = w1 ^ w2 ^ w3;
endmodule
