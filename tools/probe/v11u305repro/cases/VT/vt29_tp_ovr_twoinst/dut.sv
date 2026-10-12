// § scopedTdMemberCopyAbstains305v
package pk; typedef logic [2:0] w_t; endpackage
module sub #(parameter type T = logic) (output logic o); T v; assign v = '0; assign o = v[0]; endmodule
module dut (output logic [1:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  sub #(.T(s_t)) u0 (o[0]);
  sub #(.T(s_t)) u1 (o[1]);
endmodule
