// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
interface outer;
  ifc u();
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  outer w();
  assign w.u.d = i;
  assign o = w.u.d;
endmodule
