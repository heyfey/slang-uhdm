// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d;
  modport mp (input d);
endinterface
module sink(ifc.mp m, output logic [3:0] o);
  assign o = m.d;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  sink s (.m(u), .o(o));
endmodule
