// § scopedTdMemberCopyAbstains305v
package pk; typedef logic [2:0] w_t; endpackage
module sub #(parameter type T = logic) (input T i, output T o); assign o = i; endmodule
module dut (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  s_t x, y;
  assign x = i;
  sub #(.T(s_t)) u (x, y);
  assign o = y;
endmodule
