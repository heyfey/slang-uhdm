// r11u73 arm w1 — THE `**` ARM ACROSS THE int64 BOUNDARY (LAW A, r11u72's R0).
// `ExprEval.cpp:3782` is `val = static_cast<int64_t>(std::pow<int64_t>(val0,
// val1))`.  `std::pow<int64_t>` promotes BOTH operands to `double`
// (__promote_2<int64_t,int64_t>::__type == double), so the arm runs in double
// and the cast back is the only narrowing.  Two faces to measure:
//   (1) WITHIN double-but-past-exact-int64 the cast keeps the DOUBLE-ROUNDED
//       value (3**39: exact 4052555153018976267, double 4052555153018976256);
//   (2) PAST int64 the cast is out-of-range, and on x86-64 `cvttsd2si` writes
//       the integer-indefinite pattern 0x8000000000000000.
// VALUE face: one struct, every member read EXACTLY ONCE, control FIRST.
package q1;
  localparam int K = 6;
  typedef struct packed {
    logic [31:0] a;   // K * 2       12                       CONTROL
    logic [63:0] b;   // 2 ** 40     1099511627776            in range, exact
    logic [63:0] c;   // 2 ** 62     4611686018427387904      in range, exact
    logic [63:0] d;   // 3 ** 39     ROUNDED in double
    logic [63:0] e;   // 5 ** 27     7450580596923828224      rounded in double
    logic [63:0] f;   // 2 ** 63     EXACTLY 2^63 -- out of range
    logic [63:0] g;   // 2 ** 64     past int64
    logic [63:0] h;   // 2 ** 70     far past int64
    logic [63:0] i;   // 3 ** 40     past int64
    logic [63:0] j;   // 7 ** 23     past int64
    logic [63:0] k;   // 10 ** 19    past int64 but inside uint64
    logic [63:0] l;   // (-3) ** 41  past int64, NEGATIVE double
    logic [63:0] m;   // (-2) ** 63  exactly -2^63 -- IN range
    logic [31:0] n;   // 2 ** 31     2147483648   slang int32 writes a MINUS
    logic [31:0] o;   // K + 1       7                        CONTROL
  } c1_t;
  localparam c1_t A1 = '{a: K*2, b: 2**40, c: 2**62, d: 3**39, e: 5**27,
                         f: 2**63, g: 2**64, h: 2**70, i: 3**40, j: 7**23,
                         k: 10**19, l: (-3)**41, m: (-2)**63, n: 2**31,
                         o: K+1};
endpackage
module w1_pow73 #(parameter q1::c1_t C = q1::A1)
                (output logic [31:0] y0,  output logic [63:0] y1,
                 output logic [63:0] y2,  output logic [63:0] y3,
                 output logic [63:0] y4,  output logic [63:0] y5,
                 output logic [63:0] y6,  output logic [63:0] y7,
                 output logic [63:0] y8,  output logic [63:0] y9,
                 output logic [63:0] y10, output logic [63:0] y11,
                 output logic [63:0] y12, output logic [31:0] y13,
                 output logic [31:0] y14);
  assign y0 = C.a;  assign y1 = C.b;  assign y2 = C.c;  assign y3 = C.d;
  assign y4 = C.e;  assign y5 = C.f;  assign y6 = C.g;  assign y7 = C.h;
  assign y8 = C.i;  assign y9 = C.j;  assign y10 = C.k; assign y11 = C.l;
  assign y12 = C.m; assign y13 = C.n; assign y14 = C.o;
endmodule
