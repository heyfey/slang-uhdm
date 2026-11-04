// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]) (input T din);
  T d;
  assign d = din;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u(.din(i));
  assign o = u.d;
endmodule
