// v107 adversarial arm v3 -- MEASUREMENT ONLY.
// FILL x MEMBER-WIDTH matrix on a struct that FITS IN A WORD (so golden does
// not keep tagged_pattern operands): widths 1,2,8,16,32 and every fill face.
package pv3_107;
  typedef struct packed {
    logic [31:0] a32;
    logic [15:0] b16;
    logic [7:0]  c8;
    logic [1:0]  d2;
    logic        e1;
  } w_t;
  parameter w_t P_ONES  = '{ a32: '1, b16: '1, c8: '1, d2: '1, e1: '1 };
  parameter w_t P_ZERO  = '{ a32: '0, b16: '0, c8: '0, d2: '0, e1: '0 };
  parameter w_t P_X     = '{ a32: 'x, b16: 'x, c8: 'x, d2: 'x, e1: 'x };
  parameter w_t P_Z     = '{ a32: 'z, b16: 'z, c8: 'z, d2: 'z, e1: 'z };
  parameter w_t P_SIZED = '{ a32: 32'd7, b16: 16'hBEEF, c8: 8'hA5, d2: 2'b10, e1: 1'b1 };
  parameter w_t P_DEC   = '{ a32: 7, b16: 5, c8: 165, d2: 1, e1: 1 };
endpackage

module chv3_107 (
  input pv3_107::w_t a, input pv3_107::w_t b, input pv3_107::w_t c,
  input pv3_107::w_t d, input pv3_107::w_t e, input pv3_107::w_t f
);
  logic u; assign u = ^{a,b,c,d,e,f};
endmodule

module v3_width107 (input logic clk, output logic o);
  chv3_107 u_w (
    .a(pv3_107::P_ONES), .b(pv3_107::P_ZERO), .c(pv3_107::P_X),
    .d(pv3_107::P_Z),    .e(pv3_107::P_SIZED), .f(pv3_107::P_DEC));
  assign o = clk;
endmodule
