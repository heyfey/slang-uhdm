// v54 VERIFIER ARM v9 — THE MIS-PAIR TEST WITH DISTINGUISHABLE VALUES.
// Span keying is only safe if the span identifies the RIGHT slang node.  Every
// earlier arm replicated the SAME value in every cell, so a mis-pair would have
// been INVISIBLE.  Here the sibling replications differ in value AND width, so
// a wrong pairing prints a wrong BIN and a wrong vpiSize.
`define ONES2 {2{1'b1}}
`define ZERO4 {4{1'b0}}
`define TWOARM(A,B) {sel ? {A{1'b1}} : {B{1'b0}}, 4'h4}
module snkv9_54 #(parameter int WD = 8) (input [WD-1:0] a, output [WD-1:0] o);
  assign o = ~a;
endmodule
module v9_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w1, w2, w3, w4;
  // two sibling replications, DIFFERENT value and width, non-constant selector
  snkv9_54 #(.WD(8)) u_mix (.a({sel ? {`ONES2, 2'b00} : `ZERO4, 4'h3}), .o(w1));
  // the same, written out, values distinct: 1s (2 wide) vs 0s (4 wide)
  snkv9_54 #(.WD(8)) u_plain (.a({sel ? {{2{1'b1}}, 2'b00} : {4{1'b0}}, 4'h5}), .o(w2));
  // a MACRO with two argument-substituted replications of different width/value
  snkv9_54 #(.WD(8)) u_mac (.a(`TWOARM(4,4)), .o(w3));
  // three siblings, three distinct widths/values in one actual
  snkv9_54 #(.WD(8)) u_tri (.a({sel ? {1{1'b1}} : 1'b0, sel ? {3{1'b0}} : 3'h7,
                                sel ? 4'h1 : {4{1'b1}}}), .o(w4));
  assign q = w1 ^ w2 ^ w3 ^ w4;
endmodule
