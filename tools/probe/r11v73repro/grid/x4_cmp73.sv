// r11v73 ADVERSARIAL arm x4 — THE COMPARISON INITIALIZER (LAW D over-fire).
// x2 measured `HEQ = (16'd5 == 16'd5)` golden `const/1@3=BIN:1` while the law
// stamps 32: the producer does NOT mint a 32-bit int for a COMPARISON, it
// writes a ONE-BIT constant.  `red73MintsUntypedInt` answers TRUE for every
// BinaryOp and `red72Int64` returns Unknown (not Refuses) for the relational
// and logical operators, so the gate is wide open on all of them.
// Operand 0 is a guaranteed bail (`8'hxA`); 24-bit members; each read ONCE.
package x4;
  localparam            EQ  = (16'd5 == 16'd5);
  localparam            HEQ = EQ;
  localparam            NE  = (16'd5 != 16'd9);
  localparam            HNE = NE;
  localparam            LT  = (16'd5 <  16'd9);
  localparam            HLT = LT;
  localparam            GE  = (16'd9 >= 16'd5);
  localparam            HGE = GE;
  localparam            AN  = (1'b1 && 1'b0);
  localparam            HAN = AN;
  localparam            OR  = (1'b1 || 1'b0);
  localparam            HOR = OR;
  localparam            NT  = !16'd5;             // x2 control: golden 32
  localparam            HNT = NT;
  localparam            AD  = 16'd9 + 16'd1;      // x2 control: golden 32
  localparam            HAD = AD;
  localparam int        K   = 6;
  typedef struct packed {
    logic [23:0] bail; // 8'hxA  GUARANTEED BAIL
    logic [23:0] a;    // HEQ
    logic [23:0] b;    // HNE
    logic [23:0] c;    // HLT
    logic [23:0] d;    // HGE
    logic [23:0] e;    // HAN
    logic [23:0] f;    // HOR
    logic [23:0] g;    // HNT   control (golden 32)
    logic [23:0] h;    // HAD   control (golden 32)
    logic [23:0] i;    // K+1   plain control
  } x4_t;
  localparam x4_t A = '{bail: 8'hxA, a: HEQ, b: HNE, c: HLT, d: HGE, e: HAN,
                        f: HOR, g: HNT, h: HAD, i: K+1};
endpackage
module x4_cmp73 #(parameter x4::x4_t CA = x4::A)
                 (output logic [23:0] z0, output logic [23:0] z1,
                  output logic [23:0] z2, output logic [23:0] z3,
                  output logic [23:0] z4, output logic [23:0] z5,
                  output logic [23:0] z6, output logic [23:0] z7,
                  output logic [23:0] z8, output logic [23:0] z9);
  assign z0 = CA.bail; assign z1 = CA.a; assign z2 = CA.b; assign z3 = CA.c;
  assign z4 = CA.d;    assign z5 = CA.e; assign z6 = CA.f; assign z7 = CA.g;
  assign z8 = CA.h;    assign z9 = CA.i;
endmodule
