// r10yoo1 ARM a2 -- WHICH INITIALISER FORMS CARRY THE RULE.
//
// The existing production rule ("untyped params with based-literal inits gain a
// bare [w-1:0] range") already keys on the initialiser being a BASED literal,
// and the corpus witnesses it was built from (Scr1SvTests) are SINGLE-declarator
// statements.  So the new law must be stated over the SAME initialiser
// population, or it will fire where no range exists at all.
//
// f1  unsized DECIMAL inits      -> no [w-1:0] range exists; expect NO logic ts
// f2  DECIMAL-BASED inits ('d)   -> the production comment says a decimal-based
//                                  default carries NO typespec; check it
// f3  BINARY-BASED inits ('b)    -> the sibling or1200 files' spelling
// f4  EXPRESSION inits           -> not a literal; expect no range, no logic ts
// f5  MIXED literal / non-literal in ONE list -> does a non-literal declarator
//                                  break the run, or is position all that counts?

module f1_dec;
   parameter G1 = 5,
	     G2 = 6,
	     G3 = 7;
endmodule

module f2_decbased;
   parameter H1 = 31'd5,
	     H2 = 31'd6,
	     H3 = 31'd7;
endmodule

module f3_binbased;
   parameter I1 = 31'b1111111100000000000000000000000,
	     I2 = 31'b1111111110000000000000000000000,
	     I3 = 31'b1111111100000000000000000000001;
endmodule

module f4_expr;
   parameter J1 = 31'h7f800000 + 1,
	     J2 = 31'h7fc00001 + 2,
	     J3 = 31'h7f800001 + 3;
endmodule

module f5_mixed;
   parameter K1 = 31'h7f800000,
	     K2 = 12,
	     K3 = 31'h7f800001;
endmodule
