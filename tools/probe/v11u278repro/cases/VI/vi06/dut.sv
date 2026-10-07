// § ifaceElabTypeParamIsDefObj278
package pk; typedef logic [2:0] t3_t; endpackage
interface ifc #(parameter int W = 2, parameter type T = pk::t3_t) ();
  T v;
  logic [W-1:0] z;
  assign v = '1;
  assign z = '0;
endinterface
module top(output logic [7:0] o);
  ifc #(.W(4)) u();
  assign o = {u.z, u.v};
endmodule
