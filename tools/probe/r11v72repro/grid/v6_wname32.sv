// v11u72 BREAK ARM 3 — THE WIDE-LEAF FACE IS POSITION-DEPENDENT AND
// `red72WideBasedLeaf(e, depth > 0)` READS "depth", NOT POSITION.  A NAME AT
// OPERAND 0 recurses into its initializer at depth 1, so the DECLARED-width
// rule fires on a leaf that is sitting AT operand 0, where r11u68's b2_faces68
// measured the VALUE rule (`96'b1` COMPLETES).  If golden completes here and
// the law bails, every probe size after it is pristine-right -> patched-wrong.
// Operand 0 is the candidate; `K+1`/`K+2` on 8-bit members are the probes
// (8 = the walk completed and stamped, 64 = it bailed).  Each member ONCE.
package p6;
  localparam int          K    = 6;
  localparam logic [95:0] W96H = 96'h1;   // wide DECLARED, narrow value, hex
  localparam logic [95:0] W96B = 96'b1;   // wide DECLARED, narrow value, bin
  localparam logic [95:0] W96X = 96'h123456789ABCDEF012345678;  // wide VALUE
  localparam logic [70:0] W71H = 71'h5;   // 71-bit declared, narrow value
  localparam logic [95:0] W96D = 96'd5;   // wide DECLARED, decimal
  typedef struct packed {
    logic [31:0] a;   // the candidate at OPERAND 0 (32-bit member: no >64 member bail)
    logic [7:0]  p1;  // K + 1
    logic [7:0]  p2;  // K + 2
  } w_t;
  localparam w_t A = '{a: W96H, p1: K+1, p2: K+2};  // NAME, hex, narrow value
  localparam w_t B = '{a: W96B, p1: K+1, p2: K+2};  // NAME, bin, narrow value
  localparam w_t C = '{a: W96X, p1: K+1, p2: K+2};  // NAME, hex, WIDE value
  localparam w_t D = '{a: W71H, p1: K+1, p2: K+2};  // NAME, 71-bit
  localparam w_t E = '{a: W96D, p1: K+1, p2: K+2};  // NAME, decimal
  localparam w_t F = '{a: 96'b1, p1: K+1, p2: K+2}; // LITERAL control (b2: completes)
  localparam w_t G = '{a: 96'h1, p1: K+1, p2: K+2}; // LITERAL hex, narrow value
  localparam w_t H = '{a: K,     p1: K+1, p2: K+2}; // no-bail CONTROL
endpackage
module v6_wname32 #(parameter p6::w_t CA = p6::A, parameter p6::w_t CB = p6::B,
                    parameter p6::w_t CC = p6::C, parameter p6::w_t CD = p6::D,
                    parameter p6::w_t CE = p6::E, parameter p6::w_t CF = p6::F,
                    parameter p6::w_t CG = p6::G, parameter p6::w_t CH = p6::H)
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
