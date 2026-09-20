// r11u72 arm t4 — LAW B, THE PREDICATE MERGE, AND THE CORROBORATION FENCE.
// § patUvalueRefuses68 reads the producer's `get_uvalue` refusal off OUR
// emitted operand; § patBailNegCorroborated68v (r11v68) exists ONLY because
// that operand's VALUE might be one WE wrapped.  Once the value half is the
// producer's own int64 answer the corroboration is a read of the SAME table,
// so this arm asks whether the merged predicate reads the refusal directly.
// Operand 0 is the CANDIDATE; operands 1..3 are size probes on 8-bit members,
// so golden's SIZE reads the refusal directly (8 = the walk completed and
// stamped, 64/other = it bailed at operand 0).  Each member read ONCE.
package q4;
  localparam int        BIG = 2000000000;
  localparam bit [31:0] KU  = 3;
  localparam int        K   = 6;
  localparam byte       SB  = 8'sd100;
  // W1: operand 0 is an int32 OVERFLOW that is POSITIVE in int64
  typedef struct packed {
    logic [31:0] a;  // BIG * 2   producer +4000000000 -> COMPLETES; ours wrapped negative
    logic [7:0]  p1; // K + 1
    logic [7:0]  p2; // K + 2
    logic [7:0]  p3; // K + 3
  } w1_t;
  // W2: operand 0 is an unsigned wrap that is NEGATIVE in int64
  typedef struct packed {
    logic [31:0] a;  // KU - 5    producer -2 -> REFUSES; ours 4294967294
    logic [7:0]  p1; // K + 1
    logic [7:0]  p2; // K + 2
    logic [7:0]  p3; // K + 3
  } w2_t;
  // W3: operand 0 is negative in BOTH arithmetics (the uncontested refusal)
  typedef struct packed {
    logic [31:0] a;  // SB - 200  -100 both ways -> REFUSES
    logic [7:0]  p1; // K + 1
    logic [7:0]  p2; // K + 2
    logic [7:0]  p3; // K + 3
  } w3_t;
  // W4: operand 0 completes in both (the no-bail POSITIVE CONTROL)
  typedef struct packed {
    logic [31:0] a;  // K * 2     12 -> COMPLETES
    logic [7:0]  p1; // K + 1
    logic [7:0]  p2; // K + 2
    logic [7:0]  p3; // K + 3
  } w4_t;
  // W5: operand 0 is an operator the reduce LEAVES (the AST face)
  typedef struct packed {
    logic [31:0] a;  // KU ^ 3    op30 survives -> REFUSES
    logic [7:0]  p1; // K + 1
    logic [7:0]  p2; // K + 2
    logic [7:0]  p3; // K + 3
  } w5_t;
  // W6: operand 0 is a based literal with a BAD first digit (the object face)
  typedef struct packed {
    logic [31:0] a;  // 8'hxA     REFUSES
    logic [7:0]  p1; // K + 1
    logic [7:0]  p2; // K + 2
    logic [7:0]  p3; // K + 3
  } w6_t;
  localparam w1_t W1 = '{a: BIG*2, p1: K+1, p2: K+2, p3: K+3};
  localparam w2_t W2 = '{a: KU-5,  p1: K+1, p2: K+2, p3: K+3};
  localparam w3_t W3 = '{a: SB-200, p1: K+1, p2: K+2, p3: K+3};
  localparam w4_t W4 = '{a: K*2,   p1: K+1, p2: K+2, p3: K+3};
  localparam w5_t W5 = '{a: KU^3,  p1: K+1, p2: K+2, p3: K+3};
  localparam w6_t W6 = '{a: 8'hxA, p1: K+1, p2: K+2, p3: K+3};
endpackage
module t4_pred72 #(parameter q4::w1_t C1 = q4::W1,
                   parameter q4::w2_t C2 = q4::W2,
                   parameter q4::w3_t C3 = q4::W3,
                   parameter q4::w4_t C4 = q4::W4,
                   parameter q4::w5_t C5 = q4::W5,
                   parameter q4::w6_t C6 = q4::W6)
                  (output logic [31:0] a1, output logic [7:0] b1,
                   output logic [7:0] c1, output logic [7:0] d1,
                   output logic [31:0] a2, output logic [7:0] b2,
                   output logic [7:0] c2, output logic [7:0] d2,
                   output logic [31:0] a3, output logic [7:0] b3,
                   output logic [7:0] c3, output logic [7:0] d3,
                   output logic [31:0] a4, output logic [7:0] b4,
                   output logic [7:0] c4, output logic [7:0] d4,
                   output logic [31:0] a5, output logic [7:0] b5,
                   output logic [7:0] c5, output logic [7:0] d5,
                   output logic [31:0] a6, output logic [7:0] b6,
                   output logic [7:0] c6, output logic [7:0] d6);
  assign a1 = C1.a; assign b1 = C1.p1; assign c1 = C1.p2; assign d1 = C1.p3;
  assign a2 = C2.a; assign b2 = C2.p1; assign c2 = C2.p2; assign d2 = C2.p3;
  assign a3 = C3.a; assign b3 = C3.p1; assign c3 = C3.p2; assign d3 = C3.p3;
  assign a4 = C4.a; assign b4 = C4.p1; assign c4 = C4.p2; assign d4 = C4.p3;
  assign a5 = C5.a; assign b5 = C5.p1; assign c5 = C5.p2; assign d5 = C5.p3;
  assign a6 = C6.a; assign b6 = C6.p1; assign c6 = C6.p2; assign d6 = C6.p3;
endmodule
