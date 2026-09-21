// r11u76 arm y5 — PARENTHESES, AND THE CAST'S NEIGHBOURS.
// `Expression::create` overwrites a bound literal's `syntax` pointer with the
// PARENTHESIZED node, so every written-spelling read has to walk through it —
// and `signed'(X)`'s operand is parenthesized by grammar.  These cells are the
// direct measurement of that walk, plus the `$signed`/`$unsigned` faces the
// pass-thru law must DECLINE.
package y5;
  localparam int K = 6;
  localparam     UD = 16'd5;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } y5_t;
  localparam y5_t A = '{a: (8'sd200) + 1,      p1: K+1, p2: K+2}; // g 201
  localparam y5_t B = '{a: (4'd20) + 1,        p1: K+1, p2: K+2}; // g 21
  localparam y5_t C = '{a: ((8'shC8)) * 2,     p1: K+1, p2: K+2}; // g 400
  localparam y5_t D = '{a: (4'd99999999999999999999) + 1,
                                               p1: K+1, p2: K+2}; // g op24
  localparam y5_t E = '{a: (K) * 2,            p1: K+1, p2: K+2}; // CONTROL 12
  localparam y5_t F = '{a: (8'd7) + 1,         p1: K+1, p2: K+2}; // CONTROL 8
endpackage
// a SECOND package so the cast faces sit in their own 24-bit detector row
package y5b;
  localparam int  K   = 6;
  localparam      UD  = 16'd5;
  localparam      P1  = signed'((16'd5));    // DOUBLE parens
  localparam      HP1 = P1;
  localparam      P2  = $unsigned(16'h5);    // $unsigned over HEX: pass-thru
  localparam      HP2 = P2;
  localparam      P3  = $unsigned(16'b101);  // $unsigned over BIN: pass-thru
  localparam      HP3 = P3;
  localparam      P4  = $signed(16'o5);      // $signed over OCT: MINTS
  localparam      HP4 = P4;
  localparam      P5  = signed'('d5);        // UNSIZED operand: declined
  localparam      HP5 = P5;
  localparam      P6  = unsigned'(16'd5) + 0;// the cast inside an arm
  localparam      HP6 = P6;
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] q1;
    logic [23:0] q2;
    logic [23:0] q3;
    logic [23:0] q4;
    logic [23:0] q5;
    logic [23:0] q6;
    logic [23:0] q7;
  } y5b_t;
  localparam y5b_t A = '{bail: 8'hxA, q1: HP1, q2: HP2, q3: HP3, q4: HP4,
                         q5: HP5, q6: HP6, q7: K+1};
endpackage
module y5_paren76 #(parameter y5::y5_t CA = y5::A, parameter y5::y5_t CB = y5::B,
                    parameter y5::y5_t CC = y5::C, parameter y5::y5_t CD = y5::D,
                    parameter y5::y5_t CE = y5::E, parameter y5::y5_t CF = y5::F,
                    parameter y5b::y5b_t CZ = y5b::A)
                   (output logic [63:0] a1,  output logic [7:0] b1,
                    output logic [7:0]  c1,  output logic [63:0] a2,
                    output logic [7:0]  b2,  output logic [7:0] c2,
                    output logic [63:0] a3,  output logic [7:0] b3,
                    output logic [7:0]  c3,  output logic [63:0] a4,
                    output logic [7:0]  b4,  output logic [7:0] c4,
                    output logic [63:0] a5,  output logic [7:0] b5,
                    output logic [7:0]  c5,  output logic [63:0] a6,
                    output logic [7:0]  b6,  output logic [7:0] c6,
                    output logic [23:0] z0,  output logic [23:0] z1,
                    output logic [23:0] z2,  output logic [23:0] z3,
                    output logic [23:0] z4,  output logic [23:0] z5,
                    output logic [23:0] z6,  output logic [23:0] z7);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign z0 = CZ.bail; assign z1 = CZ.q1; assign z2 = CZ.q2;
  assign z3 = CZ.q3;   assign z4 = CZ.q4; assign z5 = CZ.q5;
  assign z6 = CZ.q6;   assign z7 = CZ.q7;
endmodule
