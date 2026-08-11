// r10oth4 -- HEAD 2 of YosysOldOr, second hypothesis.  r2_paramts.v REFUTED the
// first one ("a non-LAST declarator of a multi-declarator parameter declaration
// gets a fresh typespec"): that arm is PASS_CMP + DUMP_MATCH, and golden gives
// all three declarators the SAME shared int_typespec there.
//
// The corpus distinguisher is USE, not position.  In
// or1200_fpu_intfloat_conv.v only INF (86) and QNAN (87) are REFERENCED --
// line 284 `… ? QNAN : INF;` -- and SNAN (88) is referenced NOWHERE.  Golden
// gives INF and QNAN a locationless `logic_typespec` [30:0] with UINT bounds and
// leaves SNAN on the shared `int_typespec , line:86:4, endln:88:24`.
//
// The PRODUCER of that shape is `CompileHelper::setRange`
// (Surelog/src/DesignCompile/CompileHelper.cpp:5417) — it makes a
// `logic_typespec` + one `range` whose bounds are bare `UINT:<lr>` / `UINT:<rr>`
// constants and NO location, and it is called ONLY from the name-resolution
// paths in CompileExpression.cpp (lines 320, 913, 968, 977, 1065, 1084, 1142),
// each of which MINTS a constant out of a stored `Value` when a parameter is
// referenced by name.  `setRange` is a no-op unless the Value carries a range
// (`if (lr || rr)`), which for a parameter means it was written as a SIZED
// literal with no explicit type.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  Read with
// `tsarm.py --expect N` on g.dump / o.dump.

// g1 -- sized-literal parameter, REFERENCED in a cont_assign
module g1_ref;
parameter A = 31'h1;
wire [30:0] w;
assign w = A;
endmodule

// g2 -- the same parameter, referenced NOWHERE.  The control.
module g2_noref;
parameter A = 31'h1;
endmodule

// g3 -- the WITNESS SHAPE: one declaration, three declarators, the first two
//       referenced and the third not.
module g3_mixed;
parameter A = 31'h1, B = 31'h2, C = 31'h3;
wire [30:0] w;
assign w = 1'b1 ? B : A;
endmodule

// g4 -- referenced, but UNSIZED literal (the Value carries no range, so
//       setRange is a no-op)
module g4_unsized;
parameter A = 5;
wire [30:0] w;
assign w = A;
endmodule

// g5 -- referenced from a PROCEDURAL block only
module g5_proc;
parameter A = 31'h1;
reg [30:0] w;
always @(*) w = A;
endmodule

// g6 -- referenced only as an INSTANCE PARAMETER OVERRIDE value
module g6_child #(parameter P = 0) ();
endmodule
module g6_top;
parameter A = 31'h1;
g6_child #(.P(A)) u();
endmodule

// g7 -- referenced twice
module g7_twice;
parameter A = 31'h1;
wire [30:0] w, x;
assign w = A;
assign x = A;
endmodule

// g8 -- explicitly TYPED and referenced (an explicit type should mean the
//       declaration typespec, not a setRange one)
module g8_typed;
parameter [30:0] A = 31'h1;
wire [30:0] w;
assign w = A;
endmodule

// g9 -- untyped, referenced, value is an OPERATION over sized literals
module g9_op;
parameter A = 31'h1 + 1;
wire [30:0] w;
assign w = A;
endmodule

// g10 -- untyped, referenced, value is a CONCAT (packed, sized)
module g10_cat;
parameter A = {2'b10, 2'b01};
wire [3:0] w;
assign w = A;
endmodule

// g11 -- untyped, referenced, value is another sized-literal PARAMETER
module g11_paramref;
parameter A = 31'h1;
parameter B = A;
wire [30:0] w;
assign w = B;
endmodule

// g12 -- untyped, referenced, DECIMAL literal WITH a size (`31'd5`) -- a sized
//        base-10 literal still gives the Value a range
module g12_sizeddec;
parameter A = 31'd5;
wire [30:0] w;
assign w = A;
endmodule

// ---- THE READ RULE.  § readFoldUntypedSizedLitParam fired on g1/g3/g7 and
// ---- REACHED NOTHING on the corpus, because the corpus read
// ---- (`assign inf = (…) ? QNAN : INF;`, or1200_fpu_intfloat_conv.v:284) has
// ---- NET operands and therefore does NOT fold -- so neither paramNameIsRead
// ---- (which wants a SELECT, or a whole name that IS the entire RHS) nor
// ---- paramCaFoldRead (which wants the RHS to reduce to a constant) sees it.
// ---- The suspect is UhdmWriter.cpp:2199
// ----   `if (opType == vpiAssignmentPatternOp || opType == vpiConditionOp)`
// ----     `if (m_helper.substituteAssignedValue(rhs, …))`
// ---- i.e. a CONDITION OP has its names substituted whether or not the whole
// ---- RHS can fold.  These four cells decide it.

// h1 -- the CORPUS SHAPE: a NON-foldable condition op (net condition) reading
//       two untyped sized-literal params
module h1_condnet;
parameter A = 31'h1, B = 31'h2;
wire nn;
wire [30:0] w;
assign w = nn ? A : B;
endmodule

// h2 -- CONTROL from the earlier r9hilo ablation: a param beside a net in a
//       BINARY op stays LOCATED
module h2_binnet;
parameter A = 31'h1;
wire nn;
wire [30:0] w;
assign w = nn == A;
endmodule

// h3 -- ONE param in a non-foldable condition op, the other arm a literal
module h3_condone;
parameter A = 31'h1;
wire nn;
wire [30:0] w;
assign w = nn ? A : 31'h0;
endmodule

// h4 -- the same non-foldable condition op with a TYPED param
module h4_condtyped;
parameter [30:0] A = 31'h1;
wire nn;
wire [30:0] w;
assign w = nn ? A : 31'h0;
endmodule

// h5 -- non-foldable condition op, param read only in the CONDITION position
module h5_condpos;
parameter A = 31'h1;
wire nn;
wire [30:0] w;
assign w = A ? nn : 1'b0;
endmodule
