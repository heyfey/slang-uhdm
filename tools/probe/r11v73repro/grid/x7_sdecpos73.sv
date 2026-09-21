// r11v73 ADVERSARIAL arm x7 — THE DECISIVE SIGNED-DECIMAL CELL.
// `x1_sdec73` could not separate LAW C's predicate from our own pre-existing
// sign-extension residue: every cell there is already wrong on BOTH binaries
// (golden reads a signed based-decimal by its WRITTEN MAGNITUDE — `8'sd200+1`
// is golden `INT:201` — while we sign-extend to -56), and a negative value of
// ours bails the member stamp anyway.
// `1'sd1 * 1'sd1` is the cell that separates them: golden reads 1*1 = 1 and we
// read (-1)*(-1) = 1, so the PRISTINE binary is RIGHT, the probes complete on
// both sides, and a leaf refusal introduced by LAW C would be an AWAY.
package x7;
  localparam int K = 6;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } x7_t;
  localparam x7_t A = '{a: 1'sd1  * 1'sd1,  p1: K+1, p2: K+2}; // g 1  / us 1
  localparam x7_t B = '{a: 4'sd15 * 4'sd15, p1: K+1, p2: K+2}; // g 225/ us 1
  localparam x7_t C = '{a: 1'sd1  * 1'sd1 * 1'sd1 * 1'sd1,
                                            p1: K+1, p2: K+2}; // g 1  / us 1
  localparam x7_t D = '{a: 2'sd3  * 2'sd3,  p1: K+1, p2: K+2}; // g 9  / us 1
  localparam x7_t E = '{a: 1'sd1  - 1'sd1,  p1: K+1, p2: K+2}; // g 0  / us 0
  localparam x7_t F = '{a: K * 2,           p1: K+1, p2: K+2}; // no-bail CTL
  localparam x7_t G = '{a: 32'sd4294967295 * 32'sd4294967295,
                                            p1: K+1, p2: K+2}; // g big / us 1
endpackage
module x7_sdecpos73 #(parameter x7::x7_t CA = x7::A, parameter x7::x7_t CB = x7::B,
                      parameter x7::x7_t CC = x7::C, parameter x7::x7_t CD = x7::D,
                      parameter x7::x7_t CE = x7::E, parameter x7::x7_t CF = x7::F,
                      parameter x7::x7_t CG = x7::G)
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
                      output logic [7:0] c7);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign a7 = CG.a; assign b7 = CG.p1; assign c7 = CG.p2;
endmodule
