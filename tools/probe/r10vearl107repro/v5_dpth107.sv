// v107 adversarial arm v5 -- MEASUREMENT ONLY.
// DEPTH / CARRIER faces the law must NOT reach: an array-of-struct package
// param at a port, a struct param whose pattern has a default: fill AND named
// setters, a type-key setter, and a param used through a parameter OVERRIDE.
package pv5_107;
  typedef struct packed { logic [7:0] a8; logic [1:0] b2; logic c1; } s_t;
  parameter s_t P_DEFMIX = '{ a8: 8'hA5, default: '0 };
  typedef logic [7:0] b8_t;
  parameter s_t P_TYPEK  = '{ b8_t: '1, default: '0 };
  parameter s_t P_PLAIN  = '{ a8: '1, b2: '0, c1: '1 };
  parameter s_t P_ARR [0:1] = '{ '{ a8: '1, b2: '0, c1: '1 },
                                 '{ a8: '0, b2: '1, c1: '0 } };
endpackage

module chv5_107 #(parameter pv5_107::s_t OVR = '{ a8: 0, b2: 0, c1: 0 })
  (input pv5_107::s_t a, input pv5_107::s_t b, input pv5_107::s_t c);
  logic u; assign u = ^{a, b, c, OVR};
endmodule

module chv5arr_107 (input pv5_107::s_t z [0:1]);
  logic u; assign u = ^{z[0], z[1]};
endmodule

module v5_dpth107 (input logic clk, output logic o);
  chv5_107 #(.OVR(pv5_107::P_PLAIN)) u_o (
    .a(pv5_107::P_DEFMIX), .b(pv5_107::P_TYPEK), .c(pv5_107::P_PLAIN));
  chv5arr_107 u_arr (.z(pv5_107::P_ARR));
  assign o = clk;
endmodule
