// r10yoo1 ARM a1 -- DECLARATOR COUNT AND POSITION.
//
// The witness is ONE statement with THREE declarators, and golden gave the
// first two a SPANLESS logic_typespec and the third the declaration's
// int_typespec.  "All but the last" is only one of several rules that fit a
// single 3-cell observation; it could equally be "the first two", "not the
// third", or "only when there are exactly three".  These cells separate them.
//
// Every module here is UNINSTANTIATED so it appears in topModules and the
// ELABORATED view -- which is the only view the law was observed in.
//
// c1  ONE declarator          -> the control.  If this moves, the rule is not
//                               about declarator lists at all.
// c2  TWO declarators         -> "all but last" predicts logic,int
// c3  THREE declarators       -> the witness shape: logic,logic,int
// c4  FOUR declarators        -> "all but last" predicts logic,logic,logic,int
// c5  MIXED WIDTHS            -> does each declarator carry its OWN width, or
//                               does one shared typespec win?

module c1_one;
   parameter A1 = 31'h7f800000;
endmodule

module c2_two;
   parameter B1 = 31'h7f800000,
	     B2 = 31'h7fc00001;
endmodule

module c3_three;
   parameter C1 = 31'h7f800000,
	     C2 = 31'h7fc00001,
	     C3 = 31'h7f800001;
endmodule

module c4_four;
   parameter D1 = 31'h7f800000,
	     D2 = 31'h7fc00001,
	     D3 = 31'h7f800001,
	     D4 = 31'h7f800002;
endmodule

module c5_mixedwidth;
   parameter E1 = 8'hab,
	     E2 = 16'hcdef,
	     E3 = 31'h7f800000;
endmodule
