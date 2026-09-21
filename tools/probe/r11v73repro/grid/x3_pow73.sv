// r11v73 ADVERSARIAL arm x3 — THE `**` ARM'S UNMEASURED EDGES (breaks LAW A?).
// LAW A writes INT64_MIN whenever `std::pow((double)l,(double)r)` leaves the
// int64 interval.  The producer writes `static_cast<int64_t>(...)` of the same
// double, so the two agree only if EVERY out-of-range double lands on the
// x86-64 indefinite pattern — infinities included — and only if the producer
// takes the INT branch at all (`ExprEval.cpp:3766-3790` falls to `get_double`
// and a `REAL:` constant when either operand's `get_value` refuses).
// Faces: infinity, a negative exponent, exact -2^63, far-past, zero powers,
// and a `**` over a leaf the DECIMAL refusal owns.
package x3;
  localparam int K = 6;
  typedef struct packed {
    logic [31:0] ctl;  // K * 2         CONTROL
    logic [63:0] a;    // 0 ** -1       pow -> +inf
    logic [63:0] b;    // 2 ** -1       pow -> 0.5   (in range)
    logic [63:0] c;    // (-2) ** 63    EXACTLY -2^63 (in range)
    logic [63:0] d;    // (-2) ** 64    +2^64        (out of range)
    logic [63:0] e;    // 1 ** 100      1
    logic [63:0] f;    // 0 ** 0        1
    logic [63:0] g;    // (-1) ** 65    -1
    logic [63:0] h;    // 2 ** 100      far past
    logic [63:0] i;    // 6 ** 24       4.738e18 in range, EXACT
    logic [63:0] j;    // 7 ** 22       3.909e18 in range, ROUNDED
    logic [63:0] k;    // (-7) ** 23    past int64, NEGATIVE
    logic [63:0] l;    // (-2) ** 65    -2^65        (out of range)
    logic [31:0] m;    // K + 1         CONTROL
  } x3_t;
  localparam x3_t A = '{ctl: K*2, a: 0 ** -1, b: 2 ** -1, c: (-2) ** 63,
                        d: (-2) ** 64, e: 1 ** 100, f: 0 ** 0, g: (-1) ** 65,
                        h: 2 ** 100, i: 6 ** 24, j: 7 ** 22, k: (-7) ** 23,
                        l: (-2) ** 65, m: K+1};
  // a `**` whose LEFT operand is the range-strict decimal LAW C now refuses
  localparam bit [63:0] DU = 64'd18446744073709551614;
  typedef struct packed {
    logic [63:0] a;    // DU ** 1
    logic [63:0] b;    // 2 ** DU       (a refusing EXPONENT)
    logic [7:0]  p1;
    logic [7:0]  p2;
  } x3b_t;
  localparam x3b_t B = '{a: DU ** 1, b: 2 ** DU, p1: K+1, p2: K+2};
endpackage
module x3_pow73 #(parameter x3::x3_t CA = x3::A, parameter x3::x3b_t CB = x3::B)
                 (output logic [31:0] y0, output logic [63:0] y1,
                  output logic [63:0] y2, output logic [63:0] y3,
                  output logic [63:0] y4, output logic [63:0] y5,
                  output logic [63:0] y6, output logic [63:0] y7,
                  output logic [63:0] y8, output logic [63:0] y9,
                  output logic [63:0] y10, output logic [63:0] y11,
                  output logic [63:0] y12, output logic [31:0] y13,
                  output logic [63:0] z0, output logic [63:0] z1,
                  output logic [7:0] z2, output logic [7:0] z3);
  assign y0 = CA.ctl; assign y1 = CA.a; assign y2 = CA.b; assign y3 = CA.c;
  assign y4 = CA.d;   assign y5 = CA.e; assign y6 = CA.f; assign y7 = CA.g;
  assign y8 = CA.h;   assign y9 = CA.i; assign y10 = CA.j; assign y11 = CA.k;
  assign y12 = CA.l;  assign y13 = CA.m;
  assign z0 = CB.a; assign z1 = CB.b; assign z2 = CB.p1; assign z3 = CB.p2;
endmodule
