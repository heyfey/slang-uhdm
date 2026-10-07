// § ifaceTpUseBindsDefDefault281
package pk; typedef logic [5:0] w_t; endpackage
interface ifc #(parameter type T = pk::w_t);
  T d;
endinterface
module dut(input logic [5:0] i, output logic [5:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
