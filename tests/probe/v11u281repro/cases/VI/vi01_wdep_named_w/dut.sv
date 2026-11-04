// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]);
  T d;
endinterface
module dut(input logic [7:0] i, output logic [7:0] o);
  ifc #(.W(8)) u();
  assign u.d = i;
  assign o = u.d;
endmodule
