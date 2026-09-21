// r11v73 ADVERSARIAL arm xa — LAW A AT THE INFINITIES AND THE SIGNS.
// LAW A writes INT64_MIN for every double outside the int64 interval.  Two
// faces it never tested: a result that overflows DOUBLE itself (`2 ** 1000` is
// `+inf`, `(-2) ** 1001` is `-inf`) and the negative-exponent edges.
package xa;
  localparam int K = 6;
  typedef struct packed {
    logic [31:0] ctl;  // K * 2         CONTROL
    logic [63:0] a;    // 2 ** 1000     +inf
    logic [63:0] b;    // (-2) ** 1001  -inf
    logic [63:0] c;    // (-2) ** 1000  +inf
    logic [63:0] d;    // 2 ** -3       0.125 -> 0
    logic [63:0] e;    // (-2) ** -3    -0.125 -> 0
    logic [63:0] f;    // (-1) ** 64    1
    logic [63:0] g;    // 9 ** 20       1.2e19 past int64
    logic [63:0] h;    // (-9) ** 20    the same, positive
    logic [63:0] i;    // 2 ** 62       exact, in range
    logic [31:0] j;    // K + 1         CONTROL
  } xa_t;
  localparam xa_t A = '{ctl: K*2, a: 2 ** 1000, b: (-2) ** 1001,
                        c: (-2) ** 1000, d: 2 ** -3, e: (-2) ** -3,
                        f: (-1) ** 64, g: 9 ** 20, h: (-9) ** 20,
                        i: 2 ** 62, j: K+1};
endpackage
module xa_powinf73 #(parameter xa::xa_t CA = xa::A)
                    (output logic [31:0] y0, output logic [63:0] y1,
                     output logic [63:0] y2, output logic [63:0] y3,
                     output logic [63:0] y4, output logic [63:0] y5,
                     output logic [63:0] y6, output logic [63:0] y7,
                     output logic [63:0] y8, output logic [63:0] y9,
                     output logic [31:0] y10);
  assign y0 = CA.ctl; assign y1 = CA.a; assign y2 = CA.b; assign y3 = CA.c;
  assign y4 = CA.d;   assign y5 = CA.e; assign y6 = CA.f; assign y7 = CA.g;
  assign y8 = CA.h;   assign y9 = CA.i; assign y10 = CA.j;
endmodule
