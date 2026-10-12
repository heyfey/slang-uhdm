// § scopedTdMemberCopyAbstains305v
package pk; typedef logic [2:0] w_t; endpackage
interface ifc #(parameter type T = logic);
  T d;
endinterface
module dut (output logic o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  ifc #(.T(s_t)) u ();
  assign o = u.d.b;
endmodule
