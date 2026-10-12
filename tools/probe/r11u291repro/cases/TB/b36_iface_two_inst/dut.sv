// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; typedef logic [4:0] x_t; endpackage
interface ifc #(parameter type T = logic);
  T d;
endinterface
module dut (input logic [7:0] a, output logic [7:0] o);
  ifc #(.T(pk::w_t)) u ();
  ifc #(.T(pk::x_t)) v ();
  assign u.d = a[2:0];
  assign v.d = a[7:3];
  assign o = {v.d, u.d};
endmodule
