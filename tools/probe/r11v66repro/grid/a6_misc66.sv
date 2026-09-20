// v11u66 adversarial arm a6 — THE ARMS AROUND THE TABLE'S EDGE.
// An explicit CAST under a subtract, an ENUM member under an add, a
// parameter-of-parameter hop under a multiply, a shift feeding a subtract,
// a `+` whose signed-ish operand is a NAME two hops down, a modulo by a
// name, and a genuinely UNSIGNED `+` control.
package qa6;
  localparam int K  = 6;
  localparam int unsigned KU = 6;
  typedef enum logic [3:0] { E_A = 4'd9, E_B = 4'd2 } e6_t;
  localparam int M1 = K * 2;      // an INT-ish hop
  localparam int M2 = M1 + 1;     // two hops
  typedef struct packed {
    logic [31:0] a;   // int'(K) - 1        an explicit cast under a subtract
    logic [31:0] b;   // E_A + 1            an enum member under an add
    logic [31:0] c;   // M2 * 2             two parameter hops under a multiply
    logic [31:0] d;   // (KU >> 1) - 1      a shift feeding a subtract
    logic [31:0] e;   // M1 + 1             one hop, signed-ish under +
    logic [31:0] f;   // K % 4              a modulo
    logic [31:0] g;   // KU + 1             an UNSIGNED + control
    logic [31:0] h;   // -(K - 9)           unary minus over a negative
  } ca6_t;
  localparam ca6_t A6 = '{a: int'(K) - 1, b: E_A + 1, c: M2 * 2,
                          d: (KU >> 1) - 1, e: M1 + 1, f: K % 4,
                          g: KU + 1, h: -(K - 9)};
endpackage
module a6_misc66 #(parameter qa6::ca6_t C = qa6::A6)
                 (output logic [31:0] y0, output logic [31:0] y1,
                  output logic [31:0] y2, output logic [31:0] y3,
                  output logic [31:0] y4, output logic [31:0] y5,
                  output logic [31:0] y6, output logic [31:0] y7);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c; assign y3 = C.d;
  assign y4 = C.e; assign y5 = C.f; assign y6 = C.g; assign y7 = C.h;
endmodule
