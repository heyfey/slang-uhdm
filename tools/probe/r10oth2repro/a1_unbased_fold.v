// r10oth2 ARM A1 -- purpose-built golden for DIRECTION A.
//
// Question: tryFoldConst (ExprEmit.cpp) refuses to fold ANY operation that
// CONTAINS an unbased-unsized literal ('0/'1/'x/'z).  BlackParrotComplex's
// localparam is a BinaryOp containing `'X` in the UNTAKEN arm of a ternary, and
// golden FOLDS it to UINT:5 in the ELABORATED view.  So the bail is too wide.
// This file varies ONLY the position/role of the unbased literal so the real
// gate can be read off golden.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
// Read the ELAB view (uhdmtopModules) AND the DEF view (uhdmallModules) for
// every row -- the 2x2 the pass is for.
module t ();
  localparam a = 1;
  localparam b = 2;

  // R1  the documented NO-FOLD case (an unbased literal shifted)
  localparam r1  = '0 << 8;
  // R2  unbased in the UNTAKEN arm of a ternary (the BlackParrotComplex shape)
  localparam r2  = (a < b) ? 1'b0 : 'X;
  // R3  unbased in the TAKEN arm of a ternary
  localparam r3  = (a > b) ? 1'b0 : 'X;
  // R4  R2 wrapped in arithmetic -- the exact BlackParrotComplex top shape
  localparam r4  = ((a < b) ? 1'b0 : 'X) + 5;
  // R5  unbased 'X as a direct operand of the operation
  localparam r5  = 'X + 1;
  // R6  unbased '0 as a direct operand
  localparam r6  = '0 + 1;
  // R7  unbased '1 as a direct operand
  localparam r7  = '1 + 1;
  // R8  '0 in the UNTAKEN arm of a ternary
  localparam r8  = (a < b) ? 1'b1 : '0;
  // R9  unary over an unbased literal
  localparam r9  = !'0;
  // R10 concatenation containing an unbased literal
  localparam r10 = {'0, 1'b1};
  // R11 control: the same ternary with NO unbased literal anywhere
  localparam r11 = ((a < b) ? 1'b0 : 1'b1) + 5;
  // R12 '0 in the TAKEN arm of a ternary
  localparam r12 = (a > b) ? 1'b1 : '0;

  initial $display("%d %d %d %d %d %d %d %d %d %d %d %d",
                   r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12);
endmodule
