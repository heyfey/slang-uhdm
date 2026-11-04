// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
module dut(input logic [3:0] i, output logic o, output logic [1:0] p);
  ifc u();
  assign u.d = i;
  assign o = u.d[2];
  assign p = u.d[3:2];
endmodule
