// r11v73 ADVERSARIAL arm x2 — WHICH INITIALIZERS "MINT" (breaks LAW D?).
// `red73MintsUntypedInt` answers TRUE for ANY UnaryOp, ANY BinaryOp and ANY
// Conversion, and the gate is `red72Int64(...) != Refuses` — but that table
// returns Unknown (NOT Refuses) for every operator it does not model, so the
// gate is OPEN on `~`, `!`, reductions, comparisons, shifts and `>>`.  Only
// `-`, `+`(add), `**`, `<<` and a cast were measured.  This arm asks golden
// what it stores for the UNMEASURED ones, one hop above.
// Operand 0 is a guaranteed bail (`8'hxA`); 24-bit members collide with
// nothing; every member is read EXACTLY ONCE.
package x2;
  localparam            UN  = ~16'd5;            // bitwise NOT
  localparam            HUN = UN;
  localparam            LN  = !16'd5;            // logical NOT   (1 bit)
  localparam            HLN = LN;
  localparam            RD  = &4'hF;             // reduction AND (1 bit)
  localparam            HRD = RD;
  localparam            EQ  = (16'd5 == 16'd5);  // comparison    (1 bit)
  localparam            HEQ = EQ;
  localparam            SR  = 16'd32 >> 1;       // shift RIGHT
  localparam            HSR = SR;
  localparam            TR  = 1 ? 16'd9 : 16'd3; // conditional
  localparam            HTR = TR;
  localparam            CT  = {8'd1, 8'd2};      // concatenation
  localparam            HCT = CT;
  localparam            XR  = 16'd9 ^ 16'd1;     // bitwise XOR
  localparam            HXR = XR;
  localparam bit [7:0]  TW  = 8'd3 + 8'd1;       // TYPED 8, ARITHMETIC init
  localparam            HTW = TW;
  localparam            AD  = 16'd9 + 16'd1;     // the MEASURED control
  localparam            HAD = AD;
  localparam int        K   = 6;
  typedef struct packed {
    logic [23:0] bail; // 8'hxA  GUARANTEED BAIL
    logic [23:0] a;    // HUN
    logic [23:0] b;    // HLN
    logic [23:0] c;    // HRD
    logic [23:0] d;    // HEQ
    logic [23:0] e;    // HSR
    logic [23:0] f;    // HTR
    logic [23:0] g;    // HCT
    logic [23:0] h;    // HXR
    logic [23:0] i;    // HTW
    logic [23:0] j;    // HAD   measured control (golden 32)
    logic [23:0] k;    // K+1   plain control
  } x2_t;
  localparam x2_t A = '{bail: 8'hxA, a: HUN, b: HLN, c: HRD, d: HEQ, e: HSR,
                        f: HTR, g: HCT, h: HXR, i: HTW, j: HAD, k: K+1};
endpackage
module x2_mint73 #(parameter x2::x2_t CA = x2::A)
                  (output logic [23:0] z0, output logic [23:0] z1,
                   output logic [23:0] z2, output logic [23:0] z3,
                   output logic [23:0] z4, output logic [23:0] z5,
                   output logic [23:0] z6, output logic [23:0] z7,
                   output logic [23:0] z8, output logic [23:0] z9,
                   output logic [23:0] z10, output logic [23:0] z11);
  assign z0 = CA.bail; assign z1 = CA.a; assign z2 = CA.b; assign z3 = CA.c;
  assign z4 = CA.d;    assign z5 = CA.e; assign z6 = CA.f; assign z7 = CA.g;
  assign z8 = CA.h;    assign z9 = CA.i; assign z10 = CA.j; assign z11 = CA.k;
endmodule
