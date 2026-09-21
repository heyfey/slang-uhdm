// r11v78 VERIFIER arm w1 — BREAK LAW A (§ castOperandCarriesItsTypespec78).
// Faces the implementer's z1/z2 do NOT cover: the system-call spelling, a
// PARENTHESISED cast argument, an underscored digit run, a NESTED cast, an
// s-marked NON-decimal under $signed (the mint face the pass-thru declines),
// a cast over an UNSIZED based literal, and a cast whose operand our own
// literal path already gave a typespec to.  Operand 0 is a guaranteed bail.
package w1;
  localparam int K = 6;
  localparam      B1 = $signed(16'sd5);       // system-call spelling, s-dec
  localparam      HB1= B1;
  localparam      B2 = $unsigned(16'd5);      // system-call spelling, plain
  localparam      HB2= B2;
  localparam      B3 = signed'((8'sd200));    // PARENTHESISED argument
  localparam      HB3= B3;
  localparam      B4 = signed'(8'sd2_00);     // UNDERSCORED digits
  localparam      HB4= B4;
  localparam      B5 = signed'(signed'(8'sd200)); // NESTED cast
  localparam      HB5= B5;
  localparam      B6 = signed'(16'sh1F);      // s-marked HEX under $signed
  localparam      HB6= B6;
  localparam      B7 = signed'('sd5);         // UNSIZED based literal
  localparam      HB7= B7;
  localparam      B8 = unsigned'(4'sb1111);   // s-marked BIN under $unsigned
  localparam      HB8= B8;
  localparam      B9 = unsigned'(3'so7);      // s-marked OCT under $unsigned
  localparam      HB9= B9;
  localparam      BA = signed'(16'sd5);       // the DIRECT control
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] h01; logic [23:0] h02; logic [23:0] h03; logic [23:0] h04;
    logic [23:0] h05; logic [23:0] h06; logic [23:0] h07; logic [23:0] h08;
    logic [23:0] h09;
    logic [23:0] d01; logic [23:0] d02; logic [23:0] d03; logic [23:0] d04;
    logic [23:0] v01; logic [23:0] v02;
    logic [23:0] e01;
  } w1_t;
  localparam w1_t A = '{bail: 8'hxA,
                        h01: HB1, h02: HB2, h03: HB3, h04: HB4,
                        h05: HB5, h06: HB6, h07: HB7, h08: HB8, h09: HB9,
                        d01: $signed(16'sd5),  d02: signed'((8'sd200)),
                        d03: signed'(8'sd2_00), d04: unsigned'(4'sb1111),
                        v01: 16'sd5, v02: 8'sd200,
                        e01: K+1};
endpackage
module w1_ts78v #(parameter w1::w1_t CA = w1::A)
                 (output logic [23:0] z00, output logic [23:0] z01,
                  output logic [23:0] z02, output logic [23:0] z03,
                  output logic [23:0] z04, output logic [23:0] z05,
                  output logic [23:0] z06, output logic [23:0] z07,
                  output logic [23:0] z08, output logic [23:0] z09,
                  output logic [23:0] z10, output logic [23:0] z11,
                  output logic [23:0] z12, output logic [23:0] z13,
                  output logic [23:0] z14, output logic [23:0] z15,
                  output logic [23:0] z16);
  assign z00 = CA.bail;
  assign z01 = CA.h01; assign z02 = CA.h02; assign z03 = CA.h03;
  assign z04 = CA.h04; assign z05 = CA.h05; assign z06 = CA.h06;
  assign z07 = CA.h07; assign z08 = CA.h08; assign z09 = CA.h09;
  assign z10 = CA.d01; assign z11 = CA.d02; assign z12 = CA.d03;
  assign z13 = CA.d04; assign z14 = CA.v01; assign z15 = CA.v02;
  assign z16 = CA.e01;
endmodule
