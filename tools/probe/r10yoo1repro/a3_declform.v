// r10yoo1 ARM a3 -- WHICH DECLARATION FORMS CARRY THE RULE.
//
// This arm is the OVER-FIRE arm.  makeParamTs serves parameter AND localparam,
// untyped AND ranged-untyped AND typed, and the boundary note names
// makeParamTs / predefIntTypespec as the owners of typespec-kind minting.  A
// rule stated only as "multi-declarator" would reach every one of these forms.
// Each cell says whether it may.
//
// m1  localparam, multi, based    -> same as parameter?
// m2  RANGED untyped, multi       -> `parameter [30:0] A = .., B = ..;`  These
//                                   already take the explicitRange path, which
//                                   the new rule must not steal.
// m3  TYPED logic vector, multi   -> typedParam; must be untouched
// m4  SIGNED untyped, multi       -> the signing keyword owns the span today
// m5  a module INSTANTIATED once  -> the law was seen only in the elaborated
//                                   view of an UNINSTANTIATED module; an
//                                   instantiated def has a different TOP path
// m6  the instantiator for m5

module m1_localparam;
   localparam L1 = 31'h7f800000,
	      L2 = 31'h7fc00001,
	      L3 = 31'h7f800001;
endmodule

module m2_ranged;
   parameter [30:0] N1 = 31'h7f800000,
		    N2 = 31'h7fc00001,
		    N3 = 31'h7f800001;
endmodule

module m3_typed;
   parameter logic [30:0] P1 = 31'h7f800000,
			  P2 = 31'h7fc00001,
			  P3 = 31'h7f800001;
endmodule

module m4_signed;
   parameter signed Q1 = 31'h7f800000,
		    Q2 = 31'h7fc00001,
		    Q3 = 31'h7f800001;
endmodule

module m5_child;
   parameter R1 = 31'h7f800000,
	     R2 = 31'h7fc00001,
	     R3 = 31'h7f800001;
endmodule

module m6_parent;
   m5_child u5 ();
endmodule
