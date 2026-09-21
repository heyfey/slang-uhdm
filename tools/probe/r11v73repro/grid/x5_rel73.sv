// r11v73 ADVERSARIAL arm x5 — THE REST OF THE RELATIONAL FAMILY.
// x4 measured `==`, `!=`, `<`, `>=` golden `const/1@3=BIN:1` (the producer
// writes a ONE-BIT binary constant, it does not MINT a 32-bit int) while
// `&&`, `||`, `!` and `+` are golden 32.  This arm closes the family: `>`,
// `<=`, the case-equality operators and a relational over a NAME chain.
package x5;
  localparam            GT  = (16'd9 >  16'd5);
  localparam            HGT = GT;
  localparam            LE  = (16'd5 <= 16'd9);
  localparam            HLE = LE;
  localparam            CE  = (16'd5 === 16'd5);
  localparam            HCE = CE;
  localparam            CN  = (16'd5 !== 16'd9);
  localparam            HCN = CN;
  localparam            WE  = (16'd5 ==? 16'd5);
  localparam            HWE = WE;
  localparam            H2  = HGT;               // TWO hops over a relational
  localparam            SH  = (16'd9 > 16'd5) << 1; // relational UNDER a shift
  localparam            HSH = SH;
  localparam            AD  = 16'd9 + 16'd1;     // control: golden 32
  localparam            HAD = AD;
  localparam int        K   = 6;
  typedef struct packed {
    logic [23:0] bail; // 8'hxA  GUARANTEED BAIL
    logic [23:0] a;    // HGT
    logic [23:0] b;    // HLE
    logic [23:0] c;    // HCE
    logic [23:0] d;    // HCN
    logic [23:0] e;    // HWE
    logic [23:0] f;    // H2    two hops
    logic [23:0] g;    // HSH   relational under a shift
    logic [23:0] h;    // HAD   control (golden 32)
    logic [23:0] i;    // K+1   plain control
  } x5_t;
  localparam x5_t A = '{bail: 8'hxA, a: HGT, b: HLE, c: HCE, d: HCN, e: HWE,
                        f: H2, g: HSH, h: HAD, i: K+1};
endpackage
module x5_rel73 #(parameter x5::x5_t CA = x5::A)
                 (output logic [23:0] z0, output logic [23:0] z1,
                  output logic [23:0] z2, output logic [23:0] z3,
                  output logic [23:0] z4, output logic [23:0] z5,
                  output logic [23:0] z6, output logic [23:0] z7,
                  output logic [23:0] z8, output logic [23:0] z9);
  assign z0 = CA.bail; assign z1 = CA.a; assign z2 = CA.b; assign z3 = CA.c;
  assign z4 = CA.d;    assign z5 = CA.e; assign z6 = CA.f; assign z7 = CA.g;
  assign z8 = CA.h;    assign z9 = CA.i;
endmodule
