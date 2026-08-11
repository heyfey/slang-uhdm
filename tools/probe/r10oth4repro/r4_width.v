// r10oth4 -- the WIDTH boundary of § readFoldUntypedSizedLitParam.
//
// The byte verifier caught this: the first cut of the law over-fired on
// `Surelog/tests/PartSelect4/dut.sv`, whose
//     parameter A = 68'h200000000000000;
//     parameter B = A[8*4+:4];
// keeps the LOCATED int_typespec in golden even though A IS read (by a select,
// which paramNameIsRead's own ablation says reaches getObject).  68 bits does
// not fit Surelog's 64-bit SValue, so `instance->getValue(name)` never yields a
// valid Value and the setRange mint path is never taken
// (`if (sval && sval->isValid())`, CompileExpression.cpp:972).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  Read with tsarm.py.

// i1 -- the PartSelect4 shape verbatim: 68 bits, read by a SELECT
module i1_w68_sel;
parameter A = 68'h200000000000000;
parameter B = A[8*4+:4];
endmodule

// i2 -- 68 bits, read as a WHOLE NAME by a cont-assign
module i2_w68_ca;
parameter A = 68'h2;
wire [67:0] w;
assign w = A;
endmodule

// i3 -- 40 bits (fits), read by a cont-assign
module i3_w40_ca;
parameter A = 40'h1;
wire [39:0] w;
assign w = A;
endmodule

// i4 -- exactly 64 bits, read by a cont-assign
module i4_w64_ca;
parameter A = 64'h1;
wire [63:0] w;
assign w = A;
endmodule

// i5 -- 65 bits, read by a cont-assign
module i5_w65_ca;
parameter A = 65'h1;
wire [64:0] w;
assign w = A;
endmodule

// i6 -- 31 bits, read by a SELECT (the PartSelect4 read shape at a width that
//       fits) -- separates "the width" from "the select"
module i6_w31_sel;
parameter A = 31'h1;
parameter B = A[3:0];
endmodule
