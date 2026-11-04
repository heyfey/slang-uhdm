// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = struct packed { logic [3:0] a; logic b; });
  logic [4:0] d;
endinterface
module dut(input logic [4:0] i, output logic [4:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
