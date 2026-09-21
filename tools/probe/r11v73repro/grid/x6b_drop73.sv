// r11v73 ADVERSARIAL arm x6 — A DROPPED OPERAND, NOT A LAW.
// `x3_pow73` showed our side emitting THIRTEEN operands where golden emits
// FOURTEEN: the member initialised `0 ** -1` is missing from the pattern
// entirely, on BOTH binaries.  This arm isolates it: three members, the
// middle one `0 ** -1`, and controls either side.  A missing operand is a
// VECTOR size mismatch to the judge, so it is a residue worth a name — and it
// is PRE-EXISTING, which this arm proves by scoring pristine and law alike.
package x6;
  localparam int K = 6;
  typedef struct packed {
    logic [31:0] a;   // K * 2      CONTROL
    logic [63:0] b;   // 0 ** -1    pow -> +inf
    logic [31:0] c;   // K + 1      CONTROL
  } x6_t;
  localparam x6_t A = '{a: K*2, b: 0 ** -1, c: K+1};
  typedef struct packed {
    logic [31:0] a;   // K * 2      CONTROL
    logic [63:0] b;   // 1 / 0      another producer-defined edge
    logic [31:0] c;   // K + 1      CONTROL
  } x6b_t;
  localparam x6b_t B = '{a: K*2, b: 64'sd1 / 64'sd2, c: K+1};
endpackage
module x6b_drop73 #(parameter x6::x6_t CA = x6::A, parameter x6::x6b_t CB = x6::B)
                  (output logic [31:0] p0, output logic [63:0] p1,
                   output logic [31:0] p2, output logic [31:0] q0,
                   output logic [63:0] q1, output logic [31:0] q2);
  assign p0 = CA.a; assign p1 = CA.b; assign p2 = CA.c;
  assign q0 = CB.a; assign q1 = CB.b; assign q2 = CB.c;
endmodule
