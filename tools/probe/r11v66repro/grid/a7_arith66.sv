// v11u66 adversarial arm a7 — WHOSE ARITHMETIC?
// ExprEval does every INT arm in int64 over the REDUCED OPERAND VALUES
// (ExprEval.cpp:3443 `int64_t val = val0 - val1`, :3479 `val0 * val1`), so it
// never wraps at the result width.  The patch takes slang's own result in the
// expression's SELF-DETERMINED type, which does wrap.  These cells separate
// the two, and the last two ask whether a STRUCT-PATTERN OVERRIDE ACTUAL
// (the r11u61/62 road) is disturbed.
package qa7;
  localparam int          BIG = 2000000000;   // 2e9, fits int, 2*BIG does not
  localparam byte         SB  = 8'sd100;      // a NARROW signed parameter
  localparam shortint     SH  = 16'sd30000;
  localparam int          K   = 6;
  typedef struct packed {
    logic [31:0] a;   // BIG * 2     int64 4000000000 vs int32 wrap -294967296
    logic [63:0] b;   // BIG + BIG   the + arm, same question
    logic [31:0] c;   // SB * SB     10000 either way (control)
    logic [31:0] d;   // SH * SH     900000000 fits (control)
    logic [31:0] e;   // SB - 200    -100 (control)
    logic [31:0] f;   // K * K       36 (control)
  } ca7_t;
  localparam ca7_t A7 = '{a: BIG*2, b: BIG+BIG, c: SB*SB, d: SH*SH,
                          e: SB-200, f: K*K};
  typedef struct packed { logic [31:0] p; logic [31:0] q; } ov7_t;
endpackage
module a7child #(parameter qa7::ov7_t OV = '{p: 1, q: 2}) (output logic [31:0] o);
  assign o = OV.p;
endmodule
module a7_arith66 #(parameter qa7::ca7_t C = qa7::A7)
                  (output logic [31:0] y0, output logic [63:0] y1,
                   output logic [31:0] y2, output logic [31:0] y3,
                   output logic [31:0] y4, output logic [31:0] y5,
                   output logic [31:0] y6, output logic [31:0] y7);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c; assign y3 = C.d;
  assign y4 = C.e; assign y5 = C.f;
  // a STRUCT-PATTERN OVERRIDE ACTUAL with an INT-arm setter
  a7child #(.OV('{p: 2 - 5, q: 3 * 4})) uo (.o(y6));
  a7child                                ud (.o(y7));
endmodule
