// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
module dut(input logic [7:0] i, output logic [7:0] o);
  ifc #(logic [7:0]) u();
  assign u.d = i;
  assign o = u.d;
endmodule
