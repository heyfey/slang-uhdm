// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
