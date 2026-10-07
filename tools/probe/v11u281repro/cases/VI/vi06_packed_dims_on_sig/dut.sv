// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T [1:0] d;
endinterface
module dut(input logic [7:0] i, output logic [7:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
