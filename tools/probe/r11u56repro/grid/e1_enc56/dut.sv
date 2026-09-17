// r11u56 arm e1 — THE SETTER-KIND TABLE AT ONE Lhs WIDTH.  Every member is read
// EXACTLY ONCE (no cross-assign sharing confound), by a 32-bit plain-name Lhs,
// so each cell reads the producer's encoding for ONE setter kind.
package p;
  typedef enum logic [3:0] { E_A = 4'd2, E_B = 4'd9 } e_t;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  localparam DEC16 = 16'd40;
  localparam HEX16 = 16'h28;
  typedef struct packed {
    logic [31:0] plain;   // c01 plain decimal
    int          sneg;    // c02 -1 on a SIGNED member
    int unsigned uneg;    // c03 -1 on an UNSIGNED member
    int          nname;   // c04 unary minus over a NAME
    logic [31:0] addk;    // c05 K + 1      (add over a signed-ish name)
    logic [31:0] subk;    // c06 K - 1      (subtract -> INT)
    logic [31:0] shl;     // c07 KU << 1    (shift -> UINT)
    e_t          ev;      // c08 enum member
    logic [31:0] uu1;     // c09 '1
    logic [31:0] uu0;     // c10 '0
    logic [31:0] uux;     // c11 'x
    logic [15:0] hx;      // c12 16'hBEEF
    logic [15:0] bn;      // c13 16'b...
    logic [15:0] oc;      // c14 16'o...
    logic [15:0] dc;      // c15 16'd4660
    logic [15:0] refd;    // c16 a NAME whose init is a 'd literal
    logic [15:0] refh;    // c17 a NAME whose init is a 'h literal
    int          mdec;    // c18 -16'd5   (unary minus over a based decimal)
    logic [7:0]  sml8;   // c19 an 8-bit member, plain decimal, 32-bit Lhs
    logic [7:0]  sm1;     // c20 an 8-bit member set by '1
  } cfg_t;
  localparam cfg_t LIT = '{plain: 3,
                           sneg:  -1,
                           uneg:  -1,
                           nname: -K,
                           addk:  K + 1,
                           subk:  K - 1,
                           shl:   KU << 1,
                           ev:    E_B,
                           uu1:   '1,
                           uu0:   '0,
                           uux:   'x,
                           hx:    16'hBEEF,
                           bn:    16'b1010_0101_1100_0011,
                           oc:    16'o7654,
                           dc:    16'd4660,
                           refd:  DEC16,
                           refh:  HEX16,
                           mdec:  -16'd5,
                           sml8: 200,
                           sm1:   '1};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT)
           (output logic [31:0] o01, output logic signed [31:0] o02,
            output logic [31:0] o03, output logic signed [31:0] o04,
            output logic [31:0] o05, output logic [31:0] o06,
            output logic [31:0] o07, output logic [31:0] o08,
            output logic [31:0] o09, output logic [31:0] o10,
            output logic [31:0] o11, output logic [31:0] o12,
            output logic [31:0] o13, output logic [31:0] o14,
            output logic [31:0] o15, output logic [31:0] o16,
            output logic [31:0] o17, output logic signed [31:0] o18,
            output logic [31:0] o19, output logic [31:0] o20);
  assign o01 = CFG.plain;
  assign o02 = CFG.sneg;
  assign o03 = CFG.uneg;
  assign o04 = CFG.nname;
  assign o05 = CFG.addk;
  assign o06 = CFG.subk;
  assign o07 = CFG.shl;
  assign o08 = CFG.ev;
  assign o09 = CFG.uu1;
  assign o10 = CFG.uu0;
  assign o11 = CFG.uux;
  assign o12 = CFG.hx;
  assign o13 = CFG.bn;
  assign o14 = CFG.oc;
  assign o15 = CFG.dc;
  assign o16 = CFG.refd;
  assign o17 = CFG.refh;
  assign o18 = CFG.mdec;
  assign o19 = CFG.sml8;
  assign o20 = CFG.sm1;
endmodule
