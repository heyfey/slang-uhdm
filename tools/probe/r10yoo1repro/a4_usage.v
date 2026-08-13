// r10yoo1 ARM a4 -- USAGE x DECLARATOR COUNT.
//
// Arm a1 killed "multi-declarator alone" (c3_three, the exact witness shape,
// came back int_typespec on all three cells).  The witness's OTHER asymmetry is
// that INF and QNAN are READ at or1200_fpu_intfloat_conv.v:284
// (`out_fixed = ... ? QNAN : INF;`) while SNAN is read NOWHERE -- and the
// golden split is exactly {INF,QNAN}=logic, {SNAN}=int.
//
// But usage ALONE cannot be the rule either: or1200_fpu_post_norm_div.v reads
// QNAN and INF at :273/:275 and or1200_fpu_arith.v reads QNAN and SNAN at
// :428/:429, and golden gives every one of those a RANGED int_typespec -- those
// files declare each parameter in its OWN single-declarator statement.
//
// So this arm crosses the two axes to decide between:
//   H-A  used  =>  logic                       (predicts w1 cells move)
//   H-B  multi-declarator AND used  =>  logic  (predicts w2/w3 move, w1 not)
//   H-C  neither; something else entirely      (predicts nothing moves)
//
// w1  ONE declarator,   USED           -> separates H-A from H-B
// w2  THREE declarators, first two USED -> the witness shape exactly
// w3  THREE declarators, ALL three USED -> does the last one move too?
// w4  THREE declarators, only the LAST USED -> is it position, or usage?
// w5  TWO declarators,  first USED
//
// Every read is a plain net assignment so nothing but the read itself differs.

module w1_one_used;
   parameter S1 = 31'h7f800000;
   wire [30:0] o1;
   assign o1 = S1;
endmodule

module w2_three_firsttwo_used;
   parameter T1 = 31'h7f800000,
	     T2 = 31'h7fc00001,
	     T3 = 31'h7f800001;
   wire [30:0] o2;
   assign o2 = 1'b1 ? T2 : T1;
endmodule

module w3_three_all_used;
   parameter U1 = 31'h7f800000,
	     U2 = 31'h7fc00001,
	     U3 = 31'h7f800001;
   wire [30:0] o3a, o3b, o3c;
   assign o3a = U1;
   assign o3b = U2;
   assign o3c = U3;
endmodule

module w4_three_last_used;
   parameter V1 = 31'h7f800000,
	     V2 = 31'h7fc00001,
	     V3 = 31'h7f800001;
   wire [30:0] o4;
   assign o4 = V3;
endmodule

module w5_two_first_used;
   parameter W1 = 31'h7f800000,
	     W2 = 31'h7fc00001;
   wire [30:0] o5;
   assign o5 = W1;
endmodule
