// v11u72 BREAK ARM 2 — § redUntypedIntNameSz72 SAYS "AN IMPLICITLY TYPED
// PARAMETER WITH A UNARY-MINUS INITIALIZER IS 32", MEASURED ONLY ON `-8'd3`
// AND `-4'd3`.  The producer's `vpiMinusOp` arm takes the OPERAND's own size
// (ExprEval.cpp:3415-3425), so a WIDER operand should not read 32.  Operand 0
// is a guaranteed bail (`8'hxA`), so every operand after it prints the
// producer's own size against 24-bit members that collide with nothing.
// Each member read EXACTLY ONCE.
package p2;
  localparam       UM64 = -64'd3;    // minus over a 64-bit operand
  localparam       UM40 = -40'd3;    // minus over a 40-bit operand
  localparam       UM32 = -32'd3;    // minus over a 32-bit operand
  localparam       UMU  = -3;        // minus over an UNSIZED decimal
  localparam       UMH  = -8'h3;     // minus over a HEX operand
  localparam       UMX  = -(8'd3+1); // minus over an EXPRESSION
  localparam signed UMS = -8'd3;     // implicit type WITH a signing keyword
  localparam       UM8  = -8'd3;     // the measured control
  typedef struct packed {
    logic [23:0] bail, a, b, c, d, e, f, g, h;
  } c_t;
  localparam c_t A = '{bail: 8'hxA, a: UM64, b: UM40, c: UM32, d: UMU,
                       e: UMH, f: UMX, g: UMS, h: UM8};
endpackage
module v2_usz72 #(parameter p2::c_t C = p2::A)
                (output logic [23:0] y0, output logic [23:0] y1,
                 output logic [23:0] y2, output logic [23:0] y3,
                 output logic [23:0] y4, output logic [23:0] y5,
                 output logic [23:0] y6, output logic [23:0] y7,
                 output logic [23:0] y8);
  assign y0 = C.bail; assign y1 = C.a; assign y2 = C.b; assign y3 = C.c;
  assign y4 = C.d; assign y5 = C.e; assign y6 = C.f; assign y7 = C.g;
  assign y8 = C.h;
endmodule
