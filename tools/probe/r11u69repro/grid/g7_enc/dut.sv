// r11u69 g7 — THE ENCODING AND FILL-WIDTH LAWS COMPOSE AT THE GENERATE SITE.
// § caSubstLeafEncReduceTable56 (reduce table + the `'d` abstention + the
// unbased-unsized fill) and pass 63's fill width, all read from inside a
// generate block.  The module-level twin of each row is the control.
package p;
  typedef struct packed {
    int unsigned  d;     // plain decimal literal      -> UINT
    logic [15:0]  h;     // sized hex                  -> HEX
    logic [7:0]   b;     // sized binary               -> BIN
    logic [15:0]  dc;    // sized decimal ('d)         -> DEC (abstain)
    int           neg;   // unary minus                -> INT
    int unsigned  expr;  // K + 1                      -> UINT, value reduced
    logic [7:0]   f1;    // '1 fill on an 8-bit member
    logic [31:0]  f0;    // '0 fill
  } cfg_t;
  localparam int K = 3;
  localparam cfg_t LIT = '{d: 300, h: 16'hBEEF, b: 8'b10100101, dc: 16'd4660,
                           neg: -5, expr: K + 1, f1: '1, f0: '0};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic a_i,
   output logic [31:0] t_d, t_neg, t_expr,
   output logic [15:0] t_h, t_dc,
   output logic [7:0]  t_b, t_f1,
   output logic [31:0] t_f0,
   output logic [31:0] g_d, g_neg, g_expr,
   output logic [15:0] g_h, g_dc,
   output logic [7:0]  g_b, g_f1,
   output logic [31:0] g_f0);

  // CONTROLS at module level (the landed laws' own ground).
  assign t_d = CFG.d;   assign t_h = CFG.h;   assign t_b = CFG.b;
  assign t_dc = CFG.dc; assign t_neg = CFG.neg; assign t_expr = CFG.expr;
  assign t_f1 = CFG.f1; assign t_f0 = CFG.f0;

  if (1) begin : gblk
    assign g_d = CFG.d;   assign g_h = CFG.h;   assign g_b = CFG.b;
    assign g_dc = CFG.dc; assign g_neg = CFG.neg; assign g_expr = CFG.expr;
    assign g_f1 = CFG.f1; assign g_f0 = CFG.f0;
  end
endmodule
