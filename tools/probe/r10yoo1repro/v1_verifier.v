// r10yoo1 VERIFIER ARM v1 -- the positions § caTernOperandRead1 FIRES IN that
// the pass's own seven arms never measured against golden.
//
// The implemented rule harvests EVERY parameter name reachable inside the
// condition subtree (when the condition folds) and inside BOTH branch subtrees
// (when both fold).  Arms a5/a6/a7 only ever put a BARE WHOLE NAME in those
// positions.  So the rule's actual reach is wider than its evidence, in four
// ways this arm measures:
//
//   v1  param inside a COMPOUND foldable condition   (P == const) ? n : n
//   v2  param inside a compound condition, witness population
//   v3  param inside COMPOUND foldable BRANCHES      n ? (B1|c) : (B2|c)
//   v4  NESTED FOLDABLE ternary branches             n ? (1?C1:C2) : (0?C3:C4)
//   v5  a NET-DECLARATION assignment's ternary       wire w = (n1|n2) ? D2 : D1
//   v6  CONTROL: condition mixes a param with a NET -- folds nowhere, must not move
module v1_compound_cond;
   parameter [30:0] P1 = 31'h7f800000;
   wire [30:0] n1, n2;
   wire [30:0] o1;
   assign o1 = (P1 == 31'h7f800000) ? n1 : n2;
endmodule

module v2_compound_cond_lit;
   parameter A1 = 31'h7f800000;
   wire [30:0] n1, n2;
   wire [30:0] o2;
   assign o2 = (A1 != 31'h0) ? n1 : n2;
endmodule

module v3_compound_branches;
   parameter B1 = 31'h7f800000,
	     B2 = 31'h7fc00001;
   wire nb;
   wire [30:0] o3;
   assign o3 = nb ? (B1 | 31'h1) : (B2 | 31'h1);
endmodule

module v4_nested_foldable;
   parameter C1 = 31'h7f800000,
	     C2 = 31'h7fc00001,
	     C3 = 31'h7f800002,
	     C4 = 31'h7f800003;
   wire nc;
   wire [30:0] o4;
   assign o4 = nc ? (1'b1 ? C1 : C2) : (1'b0 ? C3 : C4);
endmodule

module v5_netdecl_tern;
   parameter D1 = 31'h7f800000,
	     D2 = 31'h7fc00001;
   wire n1, n2;
   wire [30:0] w5 = (n1 | n2) ? D2 : D1;
endmodule

module v6_param_and_net_cond;
   parameter E1 = 31'h7f800000;
   wire ne;
   wire [30:0] n1, n2;
   wire [30:0] o6;
   assign o6 = (E1 & ne) ? n1 : n2;
endmodule
