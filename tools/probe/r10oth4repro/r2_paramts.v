// r10oth4 -- HEAD 2 of YosysOldOr, exposed once § srlgFoldNaturalWidth cleared
// HEAD 1.  Corpus witness `or1200_fpu_intfloat_conv.v:86-88`:
//
//     parameter INF  = 31'h7f800000,
//               QNAN = 31'h7fc00001,
//               SNAN = 31'h7f800001;
//
// The differing object is the param_assign RHS CONSTANT's ref_typespec ACTUAL:
//   LHS(golden):  INF -> locationless `logic_typespec` [30:0], bounds UINT:30/UINT:0
//                 QNAN-> the same, a SECOND fresh object
//                 SNAN-> `int_typespec , line:86:4, endln:88:24`, bounds INT:30/INT:0
//   RHS(ours):    ALL THREE -> `int_typespec , line:86:4, endln:88:24`
// so golden gives every NON-LAST declarator of a multi-declarator parameter
// declaration a fresh anonymous typespec and only the LAST one keeps the
// declaration's own.  The three `parameter` objects themselves point at the
// int_typespec on BOTH sides, in all three cases -- only the RHS constant moves.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  Read with rarm.sh (its
// replform.py prints every constant) plus `tsarm.sh`, which prints the ACTUAL
// typespec kind/span/bounds behind each param_assign RHS constant.

// f1 -- THREE declarators, sized literals: the witness shape
module f1_three;
parameter A = 31'h1, B = 31'h2, C = 31'h3;
endmodule

// f2 -- TWO declarators
module f2_two;
parameter A = 31'h1, B = 31'h2;
endmodule

// f3 -- ONE declarator: the control.  Both sides already agree here.
module f3_one;
parameter A = 31'h1;
endmodule

// f4 -- FOUR declarators: separates "all but the LAST" from "only the FIRST"
module f4_four;
parameter A = 31'h1, B = 31'h2, C = 31'h3, D = 31'h4;
endmodule

// f5 -- UNSIZED literals, three declarators
module f5_unsized;
parameter A = 5, B = 6, C = 7;
endmodule

// f6 -- DIFFERENT literal sizes per declarator: does each fresh typespec take
//       its OWN literal's width, or the declaration's?
module f6_mixed;
parameter A = 8'hFF, B = 16'hFFFF, C = 31'h3;
endmodule

// f7 -- EXPLICITLY TYPED declaration, three declarators
module f7_typed;
parameter [30:0] A = 31'h1, B = 31'h2, C = 31'h3;
endmodule

// f8 -- three declarators whose values are OPERATIONS, not literals
module f8_ops;
parameter A = 31'h1 + 1, B = 31'h2 + 1, C = 31'h3 + 1;
endmodule

// f9 -- localparam instead of parameter
module f9_localparam;
localparam A = 31'h1, B = 31'h2, C = 31'h3;
endmodule
