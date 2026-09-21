// r11u78 arm z2 — THE ONE-HOP CAST'S SIZE (r11v76 §4's second residue).
// `signed'(8'sd200)` reached through ONE NAME hop keeps the member's 24 where
// golden reads the operand's 8, while `unsigned'(8'sd200)` through the SAME
// hop already reads 8.  The asymmetry is § patBailStopsMemberStamp68's DIGITS
// guard: it compares the digits we WROTE (still the member-masked mint at that
// point — the cast re-spell runs AFTER it, by the landed ORDER constraint)
// against `red72Int64`'s answer, and for the SIGNED cast slang's `tryEval`
// says -56 where the producer says 200.  Operand 0 bails; members 24 bits.
package z2;
  localparam int K = 6;
  localparam      QS  = signed'(8'sd200);   // hop: golden size 8
  localparam      HQS = QS;
  localparam      QU  = unsigned'(8'sd200); // hop: golden size 8 (already ours)
  localparam      HQU = QU;
  localparam      QN  = signed'(-8'sd100);  // hop over a NEGATIVE
  localparam      HQN = QN;
  localparam      QH  = unsigned'(8'shC8);  // hop, HEX
  localparam      HQH = QH;
  localparam      QB  = unsigned'(4'sb1111);// hop, BIN
  localparam      HQB = QB;
  localparam      QO  = unsigned'(3'so7);   // hop, OCT
  localparam      HQO = QO;
  localparam      QD  = signed'(16'd5);     // hop, small positive DEC
  localparam      HQD = QD;
  localparam      Q2  = HQS;                // TWO hops above the cast
  localparam      HQ2 = Q2;
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] h01; logic [23:0] h02; logic [23:0] h03; logic [23:0] h04;
    logic [23:0] h05; logic [23:0] h06; logic [23:0] h07; logic [23:0] h08;
    logic [23:0] d01; logic [23:0] d02; logic [23:0] d03;
    logic [23:0] v01; logic [23:0] v02;
    logic [23:0] e01;
  } z2_t;
  localparam z2_t A = '{bail: 8'hxA,
                        h01: HQS, h02: HQU, h03: HQN, h04: HQH,
                        h05: HQB, h06: HQO, h07: HQD, h08: HQ2,
                        d01: signed'(8'sd200), d02: unsigned'(8'sd200),
                        d03: signed'(16'd5),
                        v01: 8'sd200, v02: 8'shC8,
                        e01: K+1};
endpackage
module z2_hop78 #(parameter z2::z2_t CA = z2::A)
                 (output logic [23:0] z00, output logic [23:0] z01,
                  output logic [23:0] z02, output logic [23:0] z03,
                  output logic [23:0] z04, output logic [23:0] z05,
                  output logic [23:0] z06, output logic [23:0] z07,
                  output logic [23:0] z08, output logic [23:0] z09,
                  output logic [23:0] z10, output logic [23:0] z11,
                  output logic [23:0] z12, output logic [23:0] z13,
                  output logic [23:0] z14);
  assign z00 = CA.bail;
  assign z01 = CA.h01; assign z02 = CA.h02; assign z03 = CA.h03;
  assign z04 = CA.h04; assign z05 = CA.h05; assign z06 = CA.h06;
  assign z07 = CA.h07; assign z08 = CA.h08;
  assign z09 = CA.d01; assign z10 = CA.d02; assign z11 = CA.d03;
  assign z12 = CA.v01; assign z13 = CA.v02; assign z14 = CA.e01;
endmodule
