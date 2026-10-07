// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d [2];
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d[0] = i;
  assign u.d[1] = i;
  assign o = u.d[1];
endmodule
