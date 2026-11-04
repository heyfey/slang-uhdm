// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type A = logic [3:0], parameter type B = logic [1:0]);
  A d;
  B e;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o, output logic [1:0] p);
  ifc #(.B(logic [5:0])) u();
  assign u.d = i;
  assign u.e = i;
  assign o = u.d;
  assign p = u.e;
endmodule
