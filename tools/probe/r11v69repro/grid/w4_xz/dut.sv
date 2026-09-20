// r11v69 w4 — NON-2-STATE AND OVER-64-BIT MEMBER VALUES in a generate block.
// The fold arm requires `!hasUnknown()` and `getBitWidth() <= 64`; the F3 arm
// handles unbased-unsized.  An X/Z member, a 96-bit member set from a based
// literal and a 96-bit `'1` fill each say whether declining or folding is
// golden's answer here, with module-level twins.
package p;
  typedef struct packed {
    logic [7:0]  xb;
    logic [7:0]  zb;
    logic [95:0] w96;
    logic [95:0] o96;
  } cfg_t;
  localparam cfg_t LIT = '{xb: 8'hxx, zb: 8'hzz, w96: 96'hDEAD_BEEF_0000_0001,
                           o96: '1};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i,
   output logic [7:0]  t_x, g_x,
   output logic [7:0]  t_z, g_z,
   output logic [95:0] t_w, g_w,
   output logic [95:0] t_o, g_o);

  assign t_x = CFG.xb;
  assign t_z = CFG.zb;
  assign t_w = CFG.w96;
  assign t_o = CFG.o96;

  if (1) begin : gx
    assign g_x = CFG.xb;
    assign g_z = CFG.zb;
    assign g_w = CFG.w96;
    assign g_o = CFG.o96;
  end
endmodule
