// VERIFIER arm v2 — PARENTHESES AT OPERAND 0 (the NON-inArm face the patch
// also moved).  Base red72WideBasedLeaf required syntax->kind ==
// IntegerVectorExpression DIRECTLY; the patch walks parens for BOTH faces.
package v2;
  localparam int K = 6;
  typedef struct packed {
    logic [7:0] p;
    logic [7:0] c1;
    logic [7:0] c2;
  } v2_t;
  localparam v2_t A = '{p: (96'h123456789ABCDEF012345678), c1: K+1, c2: K+1};
  localparam v2_t B = '{p: 96'h123456789ABCDEF012345678,   c1: K+1, c2: K+1}; // CTL
  localparam v2_t C = '{p: (96'b1),                        c1: K+1, c2: K+1};
  localparam v2_t D = '{p: 96'b1,                          c1: K+1, c2: K+1}; // CTL
  localparam v2_t E = '{p: ((8'd7)),                       c1: K+1, c2: K+1};
  localparam v2_t F = '{p: (8'b1000000x),                  c1: K+1, c2: K+1};
  localparam v2_t G = '{p: 8'b1000000x,                    c1: K+1, c2: K+1}; // CTL
  localparam v2_t H = '{p: (65'd1),                        c1: K+1, c2: K+1};
  localparam v2_t I = '{p: 3,                              c1: K+1, c2: K+1}; // NO-BAIL
endpackage
module v2par76 #(parameter v2::v2_t CA = v2::A, parameter v2::v2_t CB = v2::B,
                 parameter v2::v2_t CC = v2::C, parameter v2::v2_t CD = v2::D,
                 parameter v2::v2_t CE = v2::E, parameter v2::v2_t CF = v2::F,
                 parameter v2::v2_t CG = v2::G, parameter v2::v2_t CH = v2::H,
                 parameter v2::v2_t CI = v2::I)
                (output logic [7:0] a1, output logic [7:0] b1, output logic [7:0] c1,
                 output logic [7:0] a2, output logic [7:0] b2, output logic [7:0] c2,
                 output logic [7:0] a3, output logic [7:0] b3, output logic [7:0] c3,
                 output logic [7:0] a4, output logic [7:0] b4, output logic [7:0] c4,
                 output logic [7:0] a5, output logic [7:0] b5, output logic [7:0] c5,
                 output logic [7:0] a6, output logic [7:0] b6, output logic [7:0] c6,
                 output logic [7:0] a7, output logic [7:0] b7, output logic [7:0] c7,
                 output logic [7:0] a8, output logic [7:0] b8, output logic [7:0] c8,
                 output logic [7:0] a9, output logic [7:0] b9, output logic [7:0] c9);
  assign a1 = CA.p; assign b1 = CA.c1; assign c1 = CA.c2;
  assign a2 = CB.p; assign b2 = CB.c1; assign c2 = CB.c2;
  assign a3 = CC.p; assign b3 = CC.c1; assign c3 = CC.c2;
  assign a4 = CD.p; assign b4 = CD.c1; assign c4 = CD.c2;
  assign a5 = CE.p; assign b5 = CE.c1; assign c5 = CE.c2;
  assign a6 = CF.p; assign b6 = CF.c1; assign c6 = CF.c2;
  assign a7 = CG.p; assign b7 = CG.c1; assign c7 = CG.c2;
  assign a8 = CH.p; assign b8 = CH.c1; assign c8 = CH.c2;
  assign a9 = CI.p; assign b9 = CI.c1; assign c9 = CI.c2;
endmodule
