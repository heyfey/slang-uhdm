// r10yoo1 ARM a6 -- THE OVER-FIRE FENCE, and the honest re-test of the existing
// ablation table's disputed cell.
//
// The gate this pass must edit (src/ParamEmit.cpp:16123) reads
//     (typedParam || (readFold9 && isRangedUntypedParam) ||
//      (caReadFold9 && srlgUntypedSizedLitParam))
// so ANY widening of the read predicate widens THREE populations at once, not
// just the witness's.  Before touching it, each population needs its own golden
// answer in the witness's read shape.
//
// z1  UNTYPED SIZED-LITERAL, both branches   the witness population   -> BARE (a5 y1)
// z2  RANGED UNTYPED, both branches          `parameter [30:0] A = ..`
// z3  TYPED logic vector, both branches      `parameter logic [30:0] A = ..`
// z4  RANGED UNTYPED, whole name in COND     the table's disputed cell, but
//                                            with the table's OWN param shape
// z5  the table's EXACT shape                `parameter [4:0] P = 7` read as a
//                                            whole name in a ternary condition.
//                                            The table says LOCATED; arm a5's y3
//                                            said BARE for a SIZED-LITERAL param.
//                                            If z5 comes back LOCATED then BOTH
//                                            are right and the table is simply
//                                            silent about my population -- which
//                                            is the difference between "the table
//                                            is wrong" and "the table is narrow".
// z6  RANGED UNTYPED, one branch only        the y4 control for population z2
// z7  UNTYPED SIZED-LITERAL, unsized-decimal init, both branches -- no [w-1:0]
//                                            range exists, so nothing can move

module z1_untyped_sized;
   parameter A1 = 31'h7f800000,
	     A2 = 31'h7fc00001;
   wire n1, n2;
   wire [30:0] o1;
   assign o1 = (n1 | n2) ? A2 : A1;
endmodule

module z2_ranged_untyped;
   parameter [30:0] B1 = 31'h7f800000,
		    B2 = 31'h7fc00001;
   wire n1, n2;
   wire [30:0] o2;
   assign o2 = (n1 | n2) ? B2 : B1;
endmodule

module z3_typed_logic;
   parameter logic [30:0] C1 = 31'h7f800000,
			  C2 = 31'h7fc00001;
   wire n1, n2;
   wire [30:0] o3;
   assign o3 = (n1 | n2) ? C2 : C1;
endmodule

module z4_ranged_cond;
   parameter [30:0] D1 = 31'h7f800000;
   wire [30:0] nd1, nd2;
   wire [30:0] o4;
   assign o4 = D1 ? nd1 : nd2;
endmodule

module z5_tabletshape;
   parameter [4:0] P1 = 7;
   wire [4:0] np1, np2;
   wire [4:0] o5;
   assign o5 = P1 ? np1 : np2;
endmodule

module z6_ranged_onebranch;
   parameter [30:0] E1 = 31'h7f800000;
   wire ne;
   wire [30:0] ne2;
   wire [30:0] o6;
   assign o6 = ne ? E1 : ne2;
endmodule

module z7_unsized_dec;
   parameter F1 = 5,
	     F2 = 6;
   wire n1, n2;
   wire [30:0] o7;
   assign o7 = (n1 | n2) ? F2 : F1;
endmodule
