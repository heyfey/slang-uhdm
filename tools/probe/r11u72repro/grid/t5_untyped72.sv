// r11u72 arm t5 — THE POST-BAIL SIZE OF AN UNTYPED LOCALPARAM NAME.
// § patRedSz68 answers a NAME with slang's declared width.  For an UNTYPED
// localparam slang's width is the INITIALIZER's (8 for `-8'd3`), and r11u68's
// own table says "an untyped localparam 32".  LAW A makes earlier operands
// bail where they did not before, so this size becomes observable on cells it
// never reached.  Operand 0 is a GUARANTEED refusal (`8'hxA`, r11u68 `b1`), so
// every operand after it prints `reduceExpr`'s OWN size against a member width
// that collides with nothing.  Each member read EXACTLY ONCE.
package q5;
  localparam        UM8  = -8'd3;      // untyped, unary minus over an 8-bit
  localparam        UM4  = -4'd3;      // untyped, unary minus over a 4-bit
  localparam        UH16 = 16'h28;     // untyped, based hex
  localparam        UD16 = 16'd9;      // untyped, based decimal
  localparam        UI   = 5;          // untyped, UNSIZED decimal
  localparam byte   TB   = 8'sd7;      // TYPED byte
  localparam int    K    = 6;
  typedef struct packed {
    logic [23:0] bail;  // 8'hxA   GUARANTEED BAIL (stamped, then the walk stops)
    logic [23:0] a;     // UM8     8 or 32?
    logic [23:0] b;     // UM4     4 or 32?
    logic [23:0] c;     // UH16    16 expected
    logic [23:0] d;     // UD16    16 or 32?
    logic [23:0] e;     // UI      32 or 64?
    logic [23:0] f;     // TB      8 expected
    logic [23:0] g;     // K       32 expected
    logic [23:0] h;     // -K      32 expected (the operand's size)
    logic [23:0] i;     // -UM8    the minus over an untyped name
  } c5_t;
  localparam c5_t A5 = '{bail: 8'hxA, a: UM8, b: UM4, c: UH16, d: UD16,
                         e: UI, f: TB, g: K, h: -K, i: -UM8};
endpackage
module t5_untyped72 #(parameter q5::c5_t C = q5::A5)
                    (output logic [23:0] y0, output logic [23:0] y1,
                     output logic [23:0] y2, output logic [23:0] y3,
                     output logic [23:0] y4, output logic [23:0] y5,
                     output logic [23:0] y6, output logic [23:0] y7,
                     output logic [23:0] y8, output logic [23:0] y9);
  assign y0 = C.bail; assign y1 = C.a; assign y2 = C.b; assign y3 = C.c;
  assign y4 = C.d; assign y5 = C.e; assign y6 = C.f; assign y7 = C.g;
  assign y8 = C.h; assign y9 = C.i;
endmodule
