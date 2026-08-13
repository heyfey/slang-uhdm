// r10yoo1 VERIFIER ARM v2 -- does the NARROWING lose anything the SELECT rule
// used to carry?  `paramNameIsRead`'s syntax rule already records a SELECTED
// name in a cont-assign ternary's PREDICATE (collectSrlgReadNames recurses into
// the predicate with inGenCond=true), and the ablation table records that cell
// as `bare`.  A narrowed § caTernOperandRead1 (whole names only) must therefore
// still leave these cells EQ -- they are carried by the OTHER predicate.
//
//  w1  ranged untyped param, SELECT in the ternary condition
//  w2  untyped sized-literal param, SELECT in the ternary condition
module w1_sel_cond_ranged;
   parameter [30:0] P1 = 31'h7f800000;
   wire [30:0] n1, n2;
   wire [30:0] o1;
   assign o1 = P1[0] ? n1 : n2;
endmodule

module w2_sel_cond_lit;
   parameter A1 = 31'h7f800000;
   wire [30:0] n1, n2;
   wire [30:0] o2;
   assign o2 = A1[0] ? n1 : n2;
endmodule
