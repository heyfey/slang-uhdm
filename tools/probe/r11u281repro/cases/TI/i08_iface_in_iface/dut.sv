// § ifaceInstTypeParamSharesDef281
interface inner #(parameter type T = logic [3:0]);
  T d;
endinterface
interface outer;
  inner n();
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  outer u();
  assign u.n.d = i;
  assign o = u.n.d;
endmodule
