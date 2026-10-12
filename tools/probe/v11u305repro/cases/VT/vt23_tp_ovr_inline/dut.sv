// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module sub #(parameter type T = logic) (output logic o); T v; assign v = '0; assign o = v[0]; endmodule
module dut (output logic o);
  sub #(.T(struct packed { pk::w_t a; logic b; })) u (o);
endmodule
