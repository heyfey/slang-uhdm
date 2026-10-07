// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic signed [3:0]);
  T d;
endinterface
module dut(input logic signed [3:0] i, output logic signed [7:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
