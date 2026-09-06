// v107 adversarial arm v7 -- MEASUREMENT ONLY.
// EDGE WIDTHS: 63 / 64 / 4096 / 4097 (the loop's own mw7>4096 skip), and a
// member written '1 next to one written with a SIZED literal of the same width.
package pv7_107;
  typedef struct packed {
    logic [62:0]   w63;
    logic [63:0]   w64;
    logic [4095:0] w4096;
    logic [4096:0] w4097;
  } e_t;
  parameter e_t P_E1 = '{ w63: '1, w64: '1, w4096: '1, w4097: '1 };
  parameter e_t P_E0 = '{ w63: '0, w64: '0, w4096: '0, w4097: '0 };
endpackage

module chv7_107 (input pv7_107::e_t a, input pv7_107::e_t b);
  logic u; assign u = ^{a, b};
endmodule

module v7_edge107 (input logic clk, output logic o);
  chv7_107 u_e (.a(pv7_107::P_E1), .b(pv7_107::P_E0));
  assign o = clk;
endmodule
