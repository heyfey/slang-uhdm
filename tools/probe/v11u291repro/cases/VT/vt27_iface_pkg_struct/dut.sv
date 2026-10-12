// § tpUseSigBindsTpObj291
package pk; typedef struct packed { logic [1:0] a; logic b; } s_t; endpackage
interface ifc #(parameter type T = logic);
  T d;
endinterface
module dut (input pk::s_t a, output logic o);
  ifc #(.T(pk::s_t)) u ();
  assign u.d = a;
  assign o = u.d.b;
endmodule
