// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = struct packed { logic [2:0] a; logic b; });
  T d;
endinterface
module dut(input logic [3:0] i, output logic [2:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d.a;
endmodule
