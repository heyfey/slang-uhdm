// r11v73 ADVERSARIAL arm x1 — THE SIGNED BASED-DECIMAL LEAF (breaks LAW C?).
// LAW C's predicate is `SVInt::as<uint64_t>() > INT64_MAX || !fits`, but the
// producer's refusal is `NumUtils::parseInt64(the DEC string)`.  A SIGNED
// based-decimal literal whose value is NEGATIVE (`1'sd1` is -1, `4'sd15` is
// -1, `8'sd200` is -56) sign-extends to a uint64 above INT64_MAX and would be
// REFUSED by the law, while `DEC:-1` parses into an int64 without complaint.
// Operand 0 is the candidate; `K+1`/`K+2` on 8-bit members are the probes.
package x1;
  localparam int         K    = 6;
  localparam bit  [63:0] DU   = 64'd18446744073709551614; // the landed face
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } x_t;
  localparam x_t A = '{a: 1'sd1 - 1,           p1: K+1, p2: K+2}; // -1 at 1 bit
  localparam x_t B = '{a: 4'sd15 - 1,          p1: K+1, p2: K+2}; // -1 at 4 bits
  localparam x_t C = '{a: 8'sd200 + 1,         p1: K+1, p2: K+2}; // -56 at 8
  localparam x_t D = '{a: 16'sd40000 + 1,      p1: K+1, p2: K+2}; // -25536 at 16
  localparam x_t E = '{a: 8'sd7 + 1,           p1: K+1, p2: K+2}; // +7 CONTROL
  localparam x_t F = '{a: 64'sd9223372036854775807 - 1,
                                               p1: K+1, p2: K+2}; // int64max
  localparam x_t G = '{a: K * 2,               p1: K+1, p2: K+2}; // no-bail CTL
  localparam x_t H = '{a: DU - 1,              p1: K+1, p2: K+2}; // landed face
  localparam x_t I = '{a: 2'sd2 * 2,           p1: K+1, p2: K+2}; // -2 at 2 bits
  localparam x_t J = '{a: 32'sd4294967295 - 1, p1: K+1, p2: K+2}; // -1 at 32
endpackage
module x1_sdec73 #(parameter x1::x_t CA = x1::A, parameter x1::x_t CB = x1::B,
                   parameter x1::x_t CC = x1::C, parameter x1::x_t CD = x1::D,
                   parameter x1::x_t CE = x1::E, parameter x1::x_t CF = x1::F,
                   parameter x1::x_t CG = x1::G, parameter x1::x_t CH = x1::H,
                   parameter x1::x_t CI = x1::I, parameter x1::x_t CJ = x1::J)
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
                   output logic [7:0] b8, output logic [7:0] c8,
                   output logic [63:0] a9, output logic [7:0] b9,
                   output logic [7:0] c9, output logic [63:0] a10,
                   output logic [7:0] b10, output logic [7:0] c10);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign a7 = CG.a; assign b7 = CG.p1; assign c7 = CG.p2;
  assign a8 = CH.a; assign b8 = CH.p1; assign c8 = CH.p2;
  assign a9 = CI.a; assign b9 = CI.p1; assign c9 = CI.p2;
  assign a10 = CJ.a; assign b10 = CJ.p1; assign c10 = CJ.p2;
endmodule
