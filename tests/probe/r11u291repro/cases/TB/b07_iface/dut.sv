// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
interface ifc #(parameter type T = logic);
  T d;
endinterface
module dut (input logic [2:0] a, output logic [2:0] o);
  ifc #(.T(pk::w_t)) u ();
  assign u.d = a;
  assign o = u.d;
endmodule
