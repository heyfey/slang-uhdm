// VERIFIER arm v1 — UNKNOWN DIGITS *INSIDE A REDUCE ARM*.
// r11u68's three committed unknown cells (b2 M_xtail, b3 N_xmid, v1 L_unkhx2)
// all sit at OPERAND 0.  The patch routes the inArm refusal through
// red76BasedLeafDigits, which returns FALSE on hasUnknown -> REFUSES, where
// the base returned false (NOT a refusal) and fell through to tryEval.
package v1;
  localparam int K = 6;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } v1_t;
  localparam v1_t A = '{a: 8'b1000000x + 1, p1: K+1, p2: K+2};
  localparam v1_t B = '{a: 8'b1x000001 + 1, p1: K+1, p2: K+2};
  localparam v1_t C = '{a: 8'hAx + 1,       p1: K+1, p2: K+2};
  localparam v1_t D = '{a: 8'b1000000z + 1, p1: K+1, p2: K+2};
  localparam v1_t E = '{a: 8'o7x + 1,       p1: K+1, p2: K+2};
  localparam v1_t F = '{a: 8'b10000001 + 1, p1: K+1, p2: K+2}; // CONTROL 130
  localparam v1_t G = '{a: 8'b1000000x,     p1: K+1, p2: K+2}; // op0 CONTROL
  localparam v1_t H = '{a: 8'hAx,           p1: K+1, p2: K+2}; // op0 CONTROL
  localparam v1_t I = '{a: K * 2,           p1: K+1, p2: K+2}; // no-bail CONTROL
  localparam v1_t J = '{a: 8'b1x000001 * 2, p1: K+1, p2: K+2};
endpackage
module v1unk76 #(parameter v1::v1_t CA = v1::A, parameter v1::v1_t CB = v1::B,
                 parameter v1::v1_t CC = v1::C, parameter v1::v1_t CD = v1::D,
                 parameter v1::v1_t CE = v1::E, parameter v1::v1_t CF = v1::F,
                 parameter v1::v1_t CG = v1::G, parameter v1::v1_t CH = v1::H,
                 parameter v1::v1_t CI = v1::I, parameter v1::v1_t CJ = v1::J)
                (output logic [63:0] a1, output logic [7:0] b1, output logic [7:0] c1,
                 output logic [63:0] a2, output logic [7:0] b2, output logic [7:0] c2,
                 output logic [63:0] a3, output logic [7:0] b3, output logic [7:0] c3,
                 output logic [63:0] a4, output logic [7:0] b4, output logic [7:0] c4,
                 output logic [63:0] a5, output logic [7:0] b5, output logic [7:0] c5,
                 output logic [63:0] a6, output logic [7:0] b6, output logic [7:0] c6,
                 output logic [63:0] a7, output logic [7:0] b7, output logic [7:0] c7,
                 output logic [63:0] a8, output logic [7:0] b8, output logic [7:0] c8,
                 output logic [63:0] a9, output logic [7:0] b9, output logic [7:0] c9,
                 output logic [63:0] a10,output logic [7:0] b10,output logic [7:0] c10);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign a7 = CG.a; assign b7 = CG.p1; assign c7 = CG.p2;
  assign a8 = CH.a; assign b8 = CH.p1; assign c8 = CH.p2;
  assign a9 = CI.a; assign b9 = CI.p1; assign c9 = CI.p2;
  assign a10= CJ.a; assign b10= CJ.p1; assign c10= CJ.p2;
endmodule
