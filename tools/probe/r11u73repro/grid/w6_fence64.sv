// r11u73 arm w6 — THE CORROBORATION FENCE'S LIVE CLASS AT A 64-BIT MEMBER.
// `w5_fence73` shows that at a 32-BIT member the fold re-encodes an
// overflowing value UNSIGNED (`UINT:4000000000`), so no leading minus ever
// reaches `patUvalueRefuses68` and the fence cannot engage there.  The class
// the fence guards needs OUR string to carry a MINUS while the producer's own
// int64 answer is POSITIVE — a NARROW slang expression stored into a WIDE
// member, on an operator `red72Int64` does NOT model (`<<`, `<<<`, `|`, `&`,
// `?:`), so the table ABSTAINS and cannot corroborate.
// `reduceExpr` runs every one of those arms in `int64_t` over the reduced
// operands, so golden's value is the unwrapped one and golden does NOT bail.
// Operand 0 is the candidate; `K+1`/`K+2` on 8-bit members are the probes
// (8 = golden completed, 64 = golden bailed).  Each member read EXACTLY ONCE.
package q6;
  localparam int K   = 6;
  localparam int BIG = 2000000000;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } g_t;
  localparam g_t A = '{a: BIG << 1,                  p1: K+1, p2: K+2};
  localparam g_t B = '{a: BIG <<< 1,                 p1: K+1, p2: K+2};
  localparam g_t C = '{a: (BIG * 2) | 32'sd0,        p1: K+1, p2: K+2};
  localparam g_t D = '{a: (K > 0) ? BIG * 2 : 32'sd0, p1: K+1, p2: K+2};
  localparam g_t E = '{a: (BIG * 2) & -32'sd1,       p1: K+1, p2: K+2};
  localparam g_t F = '{a: BIG * 2,                   p1: K+1, p2: K+2}; // table ANSWERS
  localparam g_t G = '{a: K * 2,                     p1: K+1, p2: K+2}; // CONTROL
  localparam g_t H = '{a: 0 - 32'sd100,              p1: K+1, p2: K+2}; // HONEST minus
endpackage
module w6_fence64 #(parameter q6::g_t CA = q6::A, parameter q6::g_t CB = q6::B,
                    parameter q6::g_t CC = q6::C, parameter q6::g_t CD = q6::D,
                    parameter q6::g_t CE = q6::E, parameter q6::g_t CF = q6::F,
                    parameter q6::g_t CG = q6::G, parameter q6::g_t CH = q6::H)
                   (output logic [63:0] a1, output logic [7:0] b1,
                    output logic [7:0] c1, output logic [63:0] a2,
                    output logic [7:0] b2, output logic [7:0] c2,
                    output logic [63:0] a3, output logic [7:0] b3,
                    output logic [7:0] c3, output logic [63:0] a4,
                    output logic [7:0] b4, output logic [7:0] c4,
                    output logic [63:0] a5, output logic [7:0] b5,
                    output logic [7:0] c5, output logic [63:0] a6,
                    output logic [7:0] b6, output logic [7:0] c6,
                    output logic [63:0] a7, output logic [7:0] b7,
                    output logic [7:0] c7, output logic [63:0] a8,
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
