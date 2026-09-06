// v107 adversarial arm v2 -- MEASUREMENT ONLY.
// ONE vs TWO vs THREE holders of the SAME package param operand, and the SAME
// param used as a port high_conn AND as a plain Rhs in the SAME design.
package pv2_107;
  typedef struct packed {
    logic [7:0] w8;
    logic [1:0] w2;
  } t2_t;
  parameter t2_t P_ONE = '{ w8: '1, w2: '0 };
endpackage

module chv2_107 (input pv2_107::t2_t p);
  logic u; assign u = ^p;
endmodule

module v2_hold107 (input logic clk, output logic o);
  // three holders of the same parameter at three ports
  chv2_107 u_a (.p(pv2_107::P_ONE));
  chv2_107 u_b (.p(pv2_107::P_ONE));
  chv2_107 u_c (.p(pv2_107::P_ONE));
  // the same parameter as a plain cont_assign Rhs in the same design
  pv2_107::t2_t rhs_copy;
  assign rhs_copy = pv2_107::P_ONE;
  // and as a variable declaration initializer
  pv2_107::t2_t var_copy = pv2_107::P_ONE;
  assign o = clk ^ (^rhs_copy) ^ (^var_copy);
endmodule
