// r10yoo1 ARM a5 -- THE READ SHAPE, inside a NON-FOLDABLE continuous assign.
//
// This is the arm that decides the pass.  The law is already implemented
// (ParamEmit.cpp:16123 binds makeBareVecParamTs when `caReadFold9 &&
// srlgUntypedSizedLitParam`), and it already NAMES this witness -- but its read
// test, `paramCaFoldRead`, requires slang's `ctx.tryEval(rhs)` to SUCCEED on the
// whole cont-assign RHS.  The witness's RHS is
//     assign out_fixed = ((qnan_d | snan_d) | ind_d) ? QNAN : INF;
// whose condition reads NETS, so it folds nowhere, so INF/QNAN are never
// harvested -- while arm a4's `assign o2 = 1'b1 ? T2 : T1` folds completely and
// DID fire.  That is the whole discrepancy between "my arms pass" and "the
// witness fails".
//
// The existing ablation table (src/ParamEmit.cpp:13972) covers SELECTS in many
// positions and two whole-name positions:
//     whole name in a ternary CONDITION     assign w = P ? n1 : n2   -> LOCATED
//     whole name in a non-foldable CA       assign o = a & P         -> LOCATED
// It has NO cell for a whole name in a ternary BRANCH, which is exactly the
// witness.  These cells fill that hole and fence the fix.
//
// EVERY condition/operand here is a NET, so nothing in this file folds; a cell
// that comes back BARE therefore proves the rule does not need foldability.
//
// y1 witness shape   both branches are params, condition is nets  -> ?
// y2 AND operand     the table says LOCATED; must NOT move
// y3 condition only  the table says LOCATED; must NOT move
// y4 one branch      only the true-branch is a param
// y5 nested ternary  branch of an INNER ternary -- how deep does it go?
// y6 concat          param inside a concat beside a net
// y7 procedural      the same ternary in an always block -> must stay LOCATED
// y8 never read      the in-file control that must stay LOCATED

module y1_tern_branches;
   parameter A1 = 31'h7f800000,
	     A2 = 31'h7fc00001;
   wire n1, n2;
   wire [30:0] o1;
   assign o1 = (n1 | n2) ? A2 : A1;
endmodule

module y2_and_operand;
   parameter B1 = 31'h7f800000;
   wire [30:0] nb;
   wire [30:0] o2;
   assign o2 = nb & B1;
endmodule

module y3_tern_cond;
   parameter C1 = 31'h7f800000;
   wire [30:0] nc1, nc2;
   wire [30:0] o3;
   assign o3 = C1 ? nc1 : nc2;
endmodule

module y4_one_branch;
   parameter D1 = 31'h7f800000;
   wire nd;
   wire [30:0] nd2;
   wire [30:0] o4;
   assign o4 = nd ? D1 : nd2;
endmodule

module y5_nested_tern;
   parameter E1 = 31'h7f800000,
	     E2 = 31'h7fc00001;
   wire ne1, ne2;
   wire [30:0] ne3;
   wire [30:0] o5;
   assign o5 = ne1 ? (ne2 ? E1 : E2) : ne3;
endmodule

module y6_concat;
   parameter F1 = 31'h7f800000;
   wire nf;
   wire [31:0] o6;
   assign o6 = {nf, F1};
endmodule

module y7_procedural;
   parameter G1 = 31'h7f800000,
	     G2 = 31'h7fc00001;
   wire ng;
   reg [30:0] o7;
   always @(*) o7 = ng ? G2 : G1;
endmodule

module y8_neverread;
   parameter H1 = 31'h7f800000,
	     H2 = 31'h7fc00001;
endmodule
