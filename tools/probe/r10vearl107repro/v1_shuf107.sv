// v107 adversarial arm v1 -- MEASUREMENT ONLY.
// THE LOCKSTEP ARM: a named pattern written in NON-DECLARATION order, mixing
// SIZED and UNSIZED member values, substituted at a child port.
package pv1_107;
  typedef struct packed {
    logic [7:0] m8;
    logic [1:0] m2;
    logic [3:0] m4;
  } t3_t;
  parameter t3_t P_SHUF  = '{ m2: '0,  m8: 8'hA5, m4: '1 };
  parameter t3_t P_SHUF2 = '{ m4: '1,  m2: 2'b10, m8: '0 };
  parameter t3_t P_DECL  = '{ m8: 8'hA5, m2: '0,  m4: '1 };
endpackage

module chv1_107 (
  input pv1_107::t3_t a,
  input pv1_107::t3_t b,
  input pv1_107::t3_t c
);
  logic u; assign u = ^{a, b, c};
endmodule

module v1_shuf107 (input logic clk, output logic o);
  chv1_107 u_c (.a(pv1_107::P_SHUF), .b(pv1_107::P_SHUF2), .c(pv1_107::P_DECL));
  assign o = clk;
endmodule
