// r11u72 arm t3 — BEYOND int64, AND THE >64-BIT LEAF.
// Two questions the value half must answer before it writes a digit:
//   (1) what does the producer write when its own int64 arithmetic overflows?
//   (2) what does it write when a LEAF cannot be read as int64 at all?
// `get_value` sets invalidValue for a BIN/HEX/OCT operand whose VpiSize()>64
// (ExprEval.cpp:1969, :1984, :1998), and the arm then falls to the `double`
// path; a >64-bit DECIMAL-encoded operand has NO size guard and is parsed by
// `parseIntLenient` straight into int64_t.  Each member read EXACTLY ONCE.
package q3;
  localparam int          BIG  = 2000000000;
  localparam longint      HUGE = 64'sd4000000000000000000;  // 4e18, fits int64
  localparam logic [95:0] W96H = 96'h1;                     // a >64b HEX leaf
  localparam logic [95:0] W96D = 96'd5;                     // a >64b DEC leaf
  localparam logic [64:0] W65  = 65'd1;                     // 65 bits, decimal
  localparam bit [63:0]   ONES = 64'hFFFFFFFFFFFFFFFF;
  localparam int          K    = 6;
  typedef struct packed {
    logic [31:0] a;   // K * 2        12   CONTROL, first so the walk starts clean
    logic [63:0] b;   // HUGE * 4     int64 OVERFLOW (1.6e19 > int64 max)
    logic [63:0] c;   // HUGE + HUGE  int64 OVERFLOW
    logic [31:0] d;   // 2 ** 64      the pow arm past int64
    logic [31:0] e;   // 2 ** 70      the pow arm far past int64
    logic [31:0] f;   // 3 ** 39      pow in DOUBLE vs exact int64 (4052555153018976267)
    logic [95:0] g;   // W96H - 1     a >64b HEX leaf inside an int64 arm
    logic [95:0] h;   // W96D * 2     a >64b DEC leaf inside an int64 arm
    logic [64:0] i;   // W65 - 2      a 65-bit decimal leaf
    logic [63:0] j;   // ONES * 2     the top of uint64 through the mult arm
    logic [31:0] k;   // BIG + 1      2000000001  CONTROL
  } c3_t;
  localparam c3_t A3 = '{a: K*2, b: HUGE*4, c: HUGE+HUGE, d: 2**64, e: 2**70,
                         f: 3**39, g: W96H-1, h: W96D*2, i: W65-2, j: ONES*2,
                         k: BIG+1};
endpackage
module t3_beyond72 #(parameter q3::c3_t C = q3::A3)
                   (output logic [31:0] y0, output logic [63:0] y1,
                    output logic [63:0] y2, output logic [31:0] y3,
                    output logic [31:0] y4, output logic [31:0] y5,
                    output logic [95:0] y6, output logic [95:0] y7,
                    output logic [64:0] y8, output logic [63:0] y9,
                    output logic [31:0] y10);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c; assign y3 = C.d;
  assign y4 = C.e; assign y5 = C.f; assign y6 = C.g; assign y7 = C.h;
  assign y8 = C.i; assign y9 = C.j; assign y10 = C.k;
endmodule
