// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = logic [3:0]);
  T d;
  modport m(input d);
endinterface
module sub(ifc.m p, output logic [3:0] o);
  assign o = p.d;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  sub s(.p(u), .o(o));
endmodule
