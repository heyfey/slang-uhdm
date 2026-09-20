// r11u72 arm t6 — WHICH WIDE LEAF THE REDUCE REFUSES, AND WHERE.
// `get_value` sets invalidValue for a BIN/HEX/OCT operand whose `VpiSize()`
// exceeds 64, but the size it tests is the REDUCE PRODUCT's, not the source
// literal's declared width (r11u68 §6 R2).  r11u68's `b2_faces68` separates
// the two at operand 0: `96'h123456789ABCDEF012345678` BAILS while `96'b1`
// does NOT.  This arm asks the same question one level down — inside an
// int64 arm, and through a NAME, where the reduced object is the parameter's
// stored constant and carries the DECLARED width.
// Operand 0 is the candidate; operands 1..2 are `K+1` size probes on 8-bit
// members, so golden's SIZE reads the refusal directly (8 = completed and
// stamped, 64 = bailed at operand 0).  Each member read EXACTLY ONCE.
package q6;
  localparam int          K    = 6;
  localparam logic [95:0] W96H = 96'h1;     // wide DECLARED, narrow value, hex
  localparam logic [95:0] W96D = 96'd5;     // wide DECLARED, decimal
  localparam logic [95:0] W96B = 96'b1;     // wide DECLARED, narrow value, bin
  localparam logic [95:0] W96X = 96'h123456789ABCDEF012345678;  // wide VALUE
  typedef struct packed {
    logic [31:0] a;   // the candidate
    logic [7:0]  p1;  // K + 1
    logic [7:0]  p2;  // K + 2
  } w_t;
  localparam w_t A = '{a: 96'h123456789ABCDEF012345678 - 1, p1: K+1, p2: K+2};
  localparam w_t B = '{a: 96'h1 - 1,  p1: K+1, p2: K+2};
  localparam w_t C = '{a: 96'b1 - 1,  p1: K+1, p2: K+2};
  localparam w_t D = '{a: W96H - 1,   p1: K+1, p2: K+2};
  localparam w_t E = '{a: W96D * 2,   p1: K+1, p2: K+2};
  localparam w_t F = '{a: W96B - 1,   p1: K+1, p2: K+2};
  localparam w_t G = '{a: W96X - 1,   p1: K+1, p2: K+2};
  localparam w_t H = '{a: K * 2,      p1: K+1, p2: K+2};   // no-bail CONTROL
endpackage
module t6_wide72 #(parameter q6::w_t CA = q6::A, parameter q6::w_t CB = q6::B,
                   parameter q6::w_t CC = q6::C, parameter q6::w_t CD = q6::D,
                   parameter q6::w_t CE = q6::E, parameter q6::w_t CF = q6::F,
                   parameter q6::w_t CG = q6::G, parameter q6::w_t CH = q6::H)
                  (output logic [31:0] a1, output logic [7:0] b1,
                   output logic [7:0] c1, output logic [31:0] a2,
                   output logic [7:0] b2, output logic [7:0] c2,
                   output logic [31:0] a3, output logic [7:0] b3,
                   output logic [7:0] c3, output logic [31:0] a4,
                   output logic [7:0] b4, output logic [7:0] c4,
                   output logic [31:0] a5, output logic [7:0] b5,
                   output logic [7:0] c5, output logic [31:0] a6,
                   output logic [7:0] b6, output logic [7:0] c6,
                   output logic [31:0] a7, output logic [7:0] b7,
                   output logic [7:0] c7, output logic [31:0] a8,
                   output logic [7:0] b8, output logic [7:0] c8);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign a7 = CG.a; assign b7 = CG.p1; assign c7 = CG.p2;
  assign a8 = CH.a; assign b8 = CH.p1; assign c8 = CH.p2;
endmodule
