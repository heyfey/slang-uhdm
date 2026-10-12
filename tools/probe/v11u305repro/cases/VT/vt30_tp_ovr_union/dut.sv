// § scopedTdMemberCopyAbstains305v
package pk; typedef logic [2:0] w_t; endpackage
module sub #(parameter type T = logic) (output logic o); T v; assign v = '0; assign o = v[0]; endmodule
module dut (output logic o);
  typedef union packed { pk::w_t a; logic [2:0] b; } u_t;
  sub #(.T(u_t)) u (o);
endmodule
