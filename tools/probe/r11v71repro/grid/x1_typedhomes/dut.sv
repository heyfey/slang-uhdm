// v11u71 x1 — THE NAMESAKE'S DECLARED TYPE.  One member (32 bits, 300) onto a
// gen-local 32-bit target whose NAME also exists in the module body with a
// declaration type that `adjustSize` may or may not be able to size with.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  typedef struct packed { logic [3:0] a; logic [5:0] b; } sub_t;   // 10 bits
  typedef enum logic [4:0] { E0 = 0, E1 = 1 } en_t;                // 5 bits
  localparam cfg_t LIT = '{n: 300};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o);
  p::sub_t          st;      // packed struct namesake, 10 bits
  p::en_t           en;      // enum namesake, 5 bits
  logic signed [5:0] sg;     // SIGNED namesake, 6 bits
  real              rl;      // real namesake
  time              tm;      // time namesake
  logic [7:0]       ua [0:1];// UNPACKED array namesake
  int               iv;      // 2-state int namesake, 32 bits
  shortint          sh;      // 16-bit 2-state namesake
  byte              by;      // 8-bit 2-state namesake
  if (1) begin : g_st  logic [31:0] st;  assign st = CFG.n; end
  if (1) begin : g_en  logic [31:0] en;  assign en = CFG.n; end
  if (1) begin : g_sg  logic [31:0] sg;  assign sg = CFG.n; end
  if (1) begin : g_rl  logic [31:0] rl;  assign rl = CFG.n; end
  if (1) begin : g_tm  logic [31:0] tm;  assign tm = CFG.n; end
  if (1) begin : g_ua  logic [31:0] ua;  assign ua = CFG.n; end
  if (1) begin : g_iv  logic [31:0] iv;  assign iv = CFG.n; end
  if (1) begin : g_sh  logic [31:0] sh;  assign sh = CFG.n; end
  if (1) begin : g_by  logic [31:0] by;  assign by = CFG.n; end
  assign o = {32'd0, g_st.st} ^ {32'd0, g_en.en} ^ {32'd0, g_sg.sg}
           ^ {32'd0, g_rl.rl} ^ {32'd0, g_tm.tm} ^ {32'd0, g_ua.ua}
           ^ {32'd0, g_iv.iv} ^ {32'd0, g_sh.sh} ^ {32'd0, g_by.by};
  assign st = '0; assign en = p::E0; assign sg = '0; assign iv = 0;
  assign sh = 0; assign by = 0;
endmodule
