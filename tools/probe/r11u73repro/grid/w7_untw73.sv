// r11u73 arm w7 — THE WIDTH BOUNDARY OF THE UNTYPED-ARITHMETIC SIZE (LAW D).
// `w4_hop73` measures that an IMPLICITLY typed parameter whose initializer is
// an OPERATOR the producer's reduce mints as `INT:` reads 32 — the unary minus
// (`MD`, `NB`, `MU`) and the binary arithmetic (`AR = 16'd9 + 16'd1`) alike —
// while one whose initializer is a BASED LITERAL keeps that literal's width.
// The question left open is WIDTH: does a WIDE arithmetic initializer still
// read 32, and does an arithmetic the reduce REFUSES (a >64-bit BIN/HEX leaf,
// a beyond-int64 DECIMAL leaf) read 32 as well, or does the refusal leave the
// declared width standing?
// Operand 0 is a guaranteed bail (`8'hxA`), so every operand after it prints
// `reduceExpr`'s OWN size against 24-bit members.  Each member read ONCE.
package q7;
  localparam            AW   = 96'd5 + 96'd1;                  // WIDE arithmetic
  localparam            AH   = 96'h1 + 96'h1;                  // WIDE hex arithmetic
  localparam            AD   = 64'd18446744073709551614 - 64'd1; // beyond-int64 DEC
  localparam            A64  = 64'd5 + 64'd1;                   // 64-bit arithmetic
  localparam            AP   = 2 ** 64;                         // the pow artefact
  localparam            AC   = 16'(5);                          // a CAST, not an arm
  localparam            AS   = 16'd9 << 1;                      // a shift
  localparam            HAW  = AW;                              // 1 hop onto AW
  localparam int        K    = 6;
  typedef struct packed {
    logic [23:0] bail;  // 8'hxA   GUARANTEED BAIL
    logic [23:0] a;     // AW      32 or 96?
    logic [23:0] b;     // AH      32 or 96?
    logic [23:0] c;     // AD      32 or 64?
    logic [23:0] d;     // A64     32 or 64?
    logic [23:0] e;     // AP      32 or 64?
    logic [23:0] f;     // AC      16 or 32?
    logic [23:0] g;     // AS      16 or 32?
    logic [23:0] h;     // HAW     32 or 96?
    logic [23:0] i;     // K       32 expected  CONTROL
  } c7_t;
  localparam c7_t A7 = '{bail: 8'hxA, a: AW, b: AH, c: AD, d: A64, e: AP,
                         f: AC, g: AS, h: HAW, i: K};
endpackage
module w7_untw73 #(parameter q7::c7_t C = q7::A7)
                 (output logic [23:0] y0, output logic [23:0] y1,
                  output logic [23:0] y2, output logic [23:0] y3,
                  output logic [23:0] y4, output logic [23:0] y5,
                  output logic [23:0] y6, output logic [23:0] y7,
                  output logic [23:0] y8, output logic [23:0] y9);
  assign y0 = C.bail; assign y1 = C.a; assign y2 = C.b; assign y3 = C.c;
  assign y4 = C.d; assign y5 = C.e; assign y6 = C.f; assign y7 = C.g;
  assign y8 = C.h; assign y9 = C.i;
endmodule
