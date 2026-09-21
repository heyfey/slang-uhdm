// r11u76 arm y2 — IS IT THE WRITTEN DIGITS OR THE STORED BIT PATTERN, AND DO
// THE OTHER BASES CARRY A SIGN?
// § negLitPkgRetFoldNested30 measured `-4'd20` folding to -20 and `-4'hFF` to
// -255, i.e. the producer reads the digits UNTRUNCATED.  If that holds inside
// a reduce ARM too, LAW A must read the written digits and not the SVInt.
// The `_s*` rows ask the mirror question for HEX / OCT / BIN: does a SIGNED
// based literal in those bases sign-extend for the producer, or does its
// `parse*` read the magnitude?
package y2;
  localparam int K = 6;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } y2_t;
  // --- digits vs pattern (unsigned bases) -------------------------------
  localparam y2_t A = '{a: 4'd20 + 1,    p1: K+1, p2: K+2}; // digits 21 / pat 5
  localparam y2_t B = '{a: 2'b111 + 1,   p1: K+1, p2: K+2}; // digits 8  / pat 4
  localparam y2_t C = '{a: 3'o77 + 1,    p1: K+1, p2: K+2}; // digits 64 / pat 8
  localparam y2_t D = '{a: 4'hFF + 1,    p1: K+1, p2: K+2}; // digits 256/ pat 16
  localparam y2_t E = '{a: 4'd3 + 1,     p1: K+1, p2: K+2}; // CONTROL 4
  // --- digits vs pattern (SIGNED decimal, overflowing its width) --------
  localparam y2_t F = '{a: 4'sd20 + 1,   p1: K+1, p2: K+2}; // digits 21 / pat 5
  localparam y2_t G = '{a: 4'sd9 + 1,    p1: K+1, p2: K+2}; // digits 10 / -7+1
  // --- SIGNED non-decimal bases -----------------------------------------
  localparam y2_t H = '{a: 8'shC8 + 1,   p1: K+1, p2: K+2}; // 201 or -55
  localparam y2_t I = '{a: 4'sb1111 - 1, p1: K+1, p2: K+2}; // 14 or -2
  localparam y2_t J = '{a: 3'so7 + 1,    p1: K+1, p2: K+2}; // 8 or 0
  localparam y2_t L = '{a: 8'hC8 + 1,    p1: K+1, p2: K+2}; // UNSIGNED ctl 201
  localparam y2_t M = '{a: 8'shC8 * 8'shC8, p1: K+1, p2: K+2}; // 40000 or 3136
  localparam y2_t N = '{a: 4'sb1111 * 4'sb1111, p1: K+1, p2: K+2}; // 225 or 1
  // --- controls ----------------------------------------------------------
  localparam y2_t O = '{a: K * 2,        p1: K+1, p2: K+2}; // no-bail CTL
  localparam y2_t P = '{a: 8'sh7F + 1,   p1: K+1, p2: K+2}; // POS signed hex 128
endpackage
module y2_digits76 #(parameter y2::y2_t CA = y2::A, parameter y2::y2_t CB = y2::B,
                     parameter y2::y2_t CC = y2::C, parameter y2::y2_t CD = y2::D,
                     parameter y2::y2_t CE = y2::E, parameter y2::y2_t CF = y2::F,
                     parameter y2::y2_t CG = y2::G, parameter y2::y2_t CH = y2::H,
                     parameter y2::y2_t CI = y2::I, parameter y2::y2_t CJ = y2::J,
                     parameter y2::y2_t CL = y2::L, parameter y2::y2_t CM = y2::M,
                     parameter y2::y2_t CN = y2::N, parameter y2::y2_t CO = y2::O,
                     parameter y2::y2_t CP = y2::P)
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
                     output logic [7:0]  c13, output logic [63:0] a14,
                     output logic [7:0]  b14, output logic [7:0] c14,
                     output logic [63:0] a15, output logic [7:0] b15,
                     output logic [7:0]  c15);
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
  assign a14 = CO.a; assign b14 = CO.p1; assign c14 = CO.p2;
  assign a15 = CP.a; assign b15 = CP.p1; assign c15 = CP.p2;
endmodule
