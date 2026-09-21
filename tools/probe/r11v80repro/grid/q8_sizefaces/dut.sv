// v11u80 q8 -- THE SIZE-STYLE DIMENSION'S FOLD.  Surelog's compileRanges takes
// the "specified by size" branch through `m_exprBuilder.evalExpr` and
// multiplies ONLY when that evaluation is valid (CompileExpression.cpp:4058-
// 4075); a package parameter is not resolvable there, so the dim contributes
// ONE.  The "specified by range" branch instead reduces both bounds and does
// resolve parameters.  This arm separates literal folds from parameter reads
// on both branches.
package pq8;
  parameter  int PN = 3;
  localparam int LN = 5;
  localparam int LM = 2;

  logic [7:0] s_lit   [4];        // literal          -> 4
  logic [7:0] s_fold  [2*2];      // folded literals  -> 4
  logic [7:0] s_fold2 [3+1];      // folded literals  -> 4
  logic [7:0] s_paren [(4)];      // parenthesised    -> 4
  logic [7:0] s_par   [PN];       // parameter        -> ?
  logic [7:0] s_lpar  [LN];       // localparam       -> ?
  logic [7:0] s_pexp  [PN*2];     // param expression -> ?
  logic [7:0] s_pmix  [LM*2];     // localparam expr  -> ?
  logic [7:0] r_lit   [0:3];      // range, literals  -> 4
  logic [7:0] r_par   [PN-1:0];   // range, parameter -> 3
  logic [7:0] r_lpar  [LN-1:0];   // range, localparam-> 5
  logic [7:0] m_pl    [PN][0:1];  // param x literal
  logic [7:0] m_lp    [0:1][PN];  // literal x param
  logic [7:0] m_pp    [PN][LN];   // param x param
  wire  [7:0] n_par   [PN];       // the NET side of the same
  wire  [7:0] n_mix   [PN][0:1];
endpackage

module dut (output logic [31:0] o);
  import pq8::*;
  assign o = {24'd0, s_lit[0]} ^ {24'd0, s_fold[0]} ^ {24'd0, s_fold2[0]}
           ^ {24'd0, s_paren[0]} ^ {24'd0, s_par[0]} ^ {24'd0, s_lpar[0]}
           ^ {24'd0, s_pexp[0]} ^ {24'd0, s_pmix[0]}
           ^ {24'd0, r_lit[0]} ^ {24'd0, r_par[0]} ^ {24'd0, r_lpar[0]}
           ^ {24'd0, m_pl[0][0]} ^ {24'd0, m_lp[0][0]} ^ {24'd0, m_pp[0][0]}
           ^ {24'd0, n_par[0]} ^ {24'd0, n_mix[0][0]};
endmodule
