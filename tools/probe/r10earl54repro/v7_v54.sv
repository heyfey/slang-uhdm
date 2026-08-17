// v54 VERIFIER ARM v7 — IMPLICIT WIDTH CONTEXTS (the R4 hazard, one step over).
// replBinConst54 takes the width from the REPLICATION'S OWN type.  Where the
// context widens the operand (a ternary whose other arm is wider, a binary
// operator, an explicit cast, a sign cast) golden's reducer may mint a
// DIFFERENT width — which would be a wrong VALUE, not a wrong kind, and the
// worst class this law can produce.
module snkv7_54 #(parameter int WD = 8) (input [WD-1:0] a, output [WD-1:0] o);
  assign o = ~a;
endmodule
module v7_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w1, w2, w3, w4, w5;
  // ternary arms of DIFFERENT width: the 4-bit replication is widened to 8
  snkv7_54 #(.WD(8)) u_wid  (.a(sel ? d : {4{1'b1}}), .o(w1));
  // replication as a context-determined BINARY operand of a wider expression
  snkv7_54 #(.WD(8)) u_add  (.a(d + {4{1'b1}}), .o(w2));
  // replication under an EXPLICIT SIZE CAST
  snkv7_54 #(.WD(8)) u_cast (.a({ 4'({2{1'b1}}), 4'h5 }), .o(w3));
  // replication under a SIGN cast
  snkv7_54 #(.WD(8)) u_sgn  (.a({ signed'({4{1'b1}}), 4'h6 }), .o(w4));
  // replication whose body is itself a widened sub-expression
  snkv7_54 #(.WD(8)) u_bod  (.a({ {4{sel ? 1'b1 : 1'b1}}, 4'h7 }), .o(w5));
  assign q = w1 ^ w2 ^ w3 ^ w4 ^ w5;
endmodule
