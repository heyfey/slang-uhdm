// r11v78 VERIFIER arm w5 — the CONT_ASSIGN substitution road under
// § caSubstLeafCtSeesParens78.  `caSubstLeafCt56` consults `basedLitOrigin56`
// FIRST, and that walk is STILL paren-blind, so a PARENTHESISED sized based
// literal escapes the landed § pkgSubstEncBasedLitAbstain50v-shaped
// abstention and reaches the table.  r11u69's g7 shape with parentheses.
package p;
  typedef struct packed {
    logic [15:0]  dc;    // sized decimal            -> golden DEC (abstain)
    logic [15:0]  pdc;   // PARENTHESISED sized decimal
    logic [15:0]  ppdc;  // doubly parenthesised
    logic [15:0]  psdc;  // parenthesised SIGNED decimal
    logic [15:0]  ph;    // parenthesised HEX
    int unsigned  parm;  // an ARM over a parenthesised literal
    int unsigned  expr;  // K + 1 control
  } cfg_t;
  localparam int K = 3;
  localparam cfg_t LIT = '{dc: 16'd4660, pdc: (16'd4660), ppdc: ((16'd4660)),
                           psdc: (16'sd4660), ph: (16'h1234),
                           parm: (16'd4660) + 1, expr: K + 1};
endpackage

module w5_contparen78v #(parameter p::cfg_t CFG = p::LIT)
  (input  logic a_i,
   output logic [15:0] t_dc, t_pdc, t_ppdc, t_psdc, t_ph,
   output logic [31:0] t_parm, t_expr,
   output logic [15:0] g_dc, g_pdc, g_ppdc, g_psdc, g_ph,
   output logic [31:0] g_parm, g_expr);
  assign t_dc = CFG.dc; assign t_pdc = CFG.pdc; assign t_ppdc = CFG.ppdc;
  assign t_psdc = CFG.psdc; assign t_ph = CFG.ph;
  assign t_parm = CFG.parm; assign t_expr = CFG.expr;
  if (1) begin : gblk
    assign g_dc = CFG.dc; assign g_pdc = CFG.pdc; assign g_ppdc = CFG.ppdc;
    assign g_psdc = CFG.psdc; assign g_ph = CFG.ph;
    assign g_parm = CFG.parm; assign g_expr = CFG.expr;
  end
endmodule
