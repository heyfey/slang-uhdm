// r11u76 arm y4 — THE POSITION FACE AND THE BEYOND-int64 DIGITS.
// (a) a BARE based literal AT the member (no arm): does the written-digits
//     read apply there, or only inside a reduce arm?
// (b) a literal whose WRITTEN DIGITS exceed INT64_MAX while its stored bit
//     pattern is tiny: § redDecLeafRangeStrict73's refusal reads the `DEC:`
//     string, so it must refuse on the DIGITS.
// (c) the committed w3_dec73 faces restated against the digits read, so the
//     refusal and the value cannot drift apart.
package y4;
  localparam int K = 6;
  localparam bit [63:0] DU = 64'd18446744073709551614;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } y4_t;
  // (a) BARE literals AT operand 0
  localparam y4_t A = '{a: 8'sd200,             p1: K+1, p2: K+2};
  localparam y4_t B = '{a: 4'd20,               p1: K+1, p2: K+2};
  localparam y4_t C = '{a: 8'shC8,              p1: K+1, p2: K+2};
  localparam y4_t D = '{a: 4'sb1111,            p1: K+1, p2: K+2};
  // (b) digits past int64, pattern tiny
  localparam y4_t E = '{a: 4'd99999999999999999999 + 1, p1: K+1, p2: K+2};
  localparam y4_t F = '{a: 4'd9223372036854775807 + 1,  p1: K+1, p2: K+2};
  localparam y4_t G = '{a: 4'h1FFFFFFFFFFFFFFFFFF + 1,  p1: K+1, p2: K+2};
  // (c) the committed refusal faces
  localparam y4_t H = '{a: DU - 1,              p1: K+1, p2: K+2}; // op11
  localparam y4_t I = '{a: 96'd5 * 2,           p1: K+1, p2: K+2}; // INT:10
  localparam y4_t J = '{a: 64'hFFFFFFFFFFFFFFFE - 1, p1: K+1, p2: K+2}; // INT:-3
  localparam y4_t L = '{a: 96'h1 + 1,           p1: K+1, p2: K+2}; // >64 hex
  // controls
  localparam y4_t M = '{a: K * 2,               p1: K+1, p2: K+2};
  localparam y4_t N = '{a: 8'd7,                p1: K+1, p2: K+2};
endpackage
module y4_pos76 #(parameter y4::y4_t CA = y4::A, parameter y4::y4_t CB = y4::B,
                  parameter y4::y4_t CC = y4::C, parameter y4::y4_t CD = y4::D,
                  parameter y4::y4_t CE = y4::E, parameter y4::y4_t CF = y4::F,
                  parameter y4::y4_t CG = y4::G, parameter y4::y4_t CH = y4::H,
                  parameter y4::y4_t CI = y4::I, parameter y4::y4_t CJ = y4::J,
                  parameter y4::y4_t CL = y4::L, parameter y4::y4_t CM = y4::M,
                  parameter y4::y4_t CN = y4::N)
                 (output logic [63:0] a1,  output logic [7:0] b1,
                  output logic [7:0]  c1,  output logic [63:0] a2,
                  output logic [7:0]  b2,  output logic [7:0] c2,
                  output logic [63:0] a3,  output logic [7:0] b3,
                  output logic [7:0]  c3,  output logic [63:0] a4,
                  output logic [7:0]  b4,  output logic [7:0] c4,
                  output logic [63:0] a5,  output logic [7:0] b5,
                  output logic [7:0]  c5,  output logic [63:0] a6,
                  output logic [7:0]  b6,  output logic [7:0] c6,
                  output logic [63:0] a7,  output logic [7:0] b7,
                  output logic [7:0]  c7,  output logic [63:0] a8,
                  output logic [7:0]  b8,  output logic [7:0] c8,
                  output logic [63:0] a9,  output logic [7:0] b9,
                  output logic [7:0]  c9,  output logic [63:0] a10,
                  output logic [7:0]  b10, output logic [7:0] c10,
                  output logic [63:0] a11, output logic [7:0] b11,
                  output logic [7:0]  c11, output logic [63:0] a12,
                  output logic [7:0]  b12, output logic [7:0] c12,
                  output logic [63:0] a13, output logic [7:0] b13,
                  output logic [7:0]  c13);
  assign a1  = CA.a; assign b1  = CA.p1; assign c1  = CA.p2;
  assign a2  = CB.a; assign b2  = CB.p1; assign c2  = CB.p2;
  assign a3  = CC.a; assign b3  = CC.p1; assign c3  = CC.p2;
  assign a4  = CD.a; assign b4  = CD.p1; assign c4  = CD.p2;
  assign a5  = CE.a; assign b5  = CE.p1; assign c5  = CE.p2;
  assign a6  = CF.a; assign b6  = CF.p1; assign c6  = CF.p2;
  assign a7  = CG.a; assign b7  = CG.p1; assign c7  = CG.p2;
  assign a8  = CH.a; assign b8  = CH.p1; assign c8  = CH.p2;
  assign a9  = CI.a; assign b9  = CI.p1; assign c9  = CI.p2;
  assign a10 = CJ.a; assign b10 = CJ.p1; assign c10 = CJ.p2;
  assign a11 = CL.a; assign b11 = CL.p1; assign c11 = CL.p2;
  assign a12 = CM.a; assign b12 = CM.p1; assign c12 = CM.p2;
  assign a13 = CN.a; assign b13 = CN.p1; assign c13 = CN.p2;
endmodule
