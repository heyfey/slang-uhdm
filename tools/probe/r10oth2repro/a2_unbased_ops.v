// r10oth2 ARM A2 -- DIRECTION A, second cut.
//
// A1 measured that golden's ELAB view folds 10 of 12 unbased-literal operations
// and refuses exactly two:  `'0 << 8` (shift) and `'X + 1` (arithmetic over an
// UNKNOWN unbased literal).  A2 separates the two candidate causes:
//   * is it the SHIFT OPERATOR, or an unsized operand of a shift?
//   * is it UNKNOWN-ness ('x/'z) in an arithmetic/relational operand?
// One localparam per row, nothing else varied.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
module t ();
  localparam a = 1;
  localparam b = 2;

  // ---- shift family -------------------------------------------------------
  localparam s1 = 1'b0 << 8;      // sized literal shifted   (control)
  localparam s2 = a << 8;         // parameter shifted       (control)
  localparam s3 = '0 >> 1;        // unbased, right shift
  localparam s4 = '1 << 1;        // unbased KNOWN '1 shifted
  localparam s5 = 8 << '0;        // unbased as the SHIFT AMOUNT
  localparam s6 = '0 <<< 2;       // arithmetic left shift
  localparam s7 = ('0 << 8) + 0;  // the no-fold shift WRAPPED in arithmetic

  // ---- known-unbased arithmetic (all folded in A1; more operators) --------
  localparam k1 = '0 * 2;
  localparam k2 = '0 - 1;
  localparam k3 = '0 & 1;
  localparam k4 = '1 | 0;
  localparam k5 = '0 == 0;

  // ---- unknown-unbased family --------------------------------------------
  localparam u1 = 1 + 'X;         // 'X on the RIGHT of the add
  localparam u2 = 'Z + 1;         // 'Z instead of 'X
  localparam u3 = 'X & 1'b0;      // AND with 0 -- value knowable, operand X
  localparam u4 = !'X;
  localparam u5 = {'X, 1'b1};     // concat containing 'X
  localparam u6 = ('X == 'X);
  localparam u7 = 'X;             // bare 'X, not an operation at all
  localparam u8 = -'X;            // unary minus
  localparam u9 = ('X) + 1;       // parenthesised -- same tree as u2 family

  initial $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",
                   s1, s2, s3, s4, s5, s6, s7, k1, k2, k3, k4, k5,
                   u1, u2, u3, u4, u5, u6, u7, u8, u9);
endmodule
