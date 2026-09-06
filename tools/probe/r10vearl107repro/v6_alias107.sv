// v107 adversarial arm v6 -- MEASUREMENT ONLY.
// PARAMETERISED package widths (the Earlgrey shape), a 2-STATE member with
// 'x/'z, an ALIAS formal typedef, an UNPACKED struct param at a port, and the
// same param at ports of TWO DIFFERENT child modules.
package pv6_107;
  parameter int WA = 16;
  parameter int WB = 2;
  typedef struct packed {
    logic [WA-1:0] wide;
    logic [WB-1:0] narrow;
  } par_t;
  typedef par_t par_alias_t;
  parameter par_t P_PAR = '{ wide: WA'(1'b1), narrow: '0 };

  typedef struct packed { bit [7:0] b8; bit [1:0] b2; } two_t;
  parameter two_t P_TWO_X = '{ b8: 'x, b2: 'z };
  parameter two_t P_TWO_1 = '{ b8: '1, b2: '1 };

  typedef struct { logic [7:0] u8; logic [1:0] u2; } unp_t;
  parameter unp_t P_UNP = '{ u8: '1, u2: '0 };
endpackage

module chv6a_107 (input pv6_107::par_t a, input pv6_107::two_t b,
                  input pv6_107::two_t c);
  logic u; assign u = ^{a, b, c};
endmodule

module chv6b_107 (input pv6_107::par_alias_t a);
  logic u; assign u = ^a;
endmodule

module chv6c_107 (input pv6_107::unp_t z);
  logic u; assign u = ^{z.u8, z.u2};
endmodule

module v6_alias107 (input logic clk, output logic o);
  chv6a_107 u_a (.a(pv6_107::P_PAR), .b(pv6_107::P_TWO_X), .c(pv6_107::P_TWO_1));
  chv6b_107 u_b (.a(pv6_107::P_PAR));
  chv6c_107 u_c (.z(pv6_107::P_UNP));
  assign o = clk;
endmodule
