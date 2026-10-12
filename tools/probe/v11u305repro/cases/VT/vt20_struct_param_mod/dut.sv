// § scopedTdMemberCopyAbstains305v
package pk; typedef logic [2:0] w_t; endpackage
module sub #(parameter type T = logic) (output logic o); assign o = 1'b0; endmodule
module dut (output logic o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  sub #(.T(s_t)) u (o);
endmodule
