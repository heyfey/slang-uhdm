// § ifaceTpUseBindsDefDefault281
package pk; typedef struct packed { logic [2:0] a; logic b; } s_t; endpackage
interface ifc #(parameter type T = pk::s_t);
  T d;
endinterface
module dut(input logic [3:0] i, output logic [2:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d.a;
endmodule
