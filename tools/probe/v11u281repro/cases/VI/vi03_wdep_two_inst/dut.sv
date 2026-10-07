// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]);
  T d;
endinterface
module dut(input logic [7:0] i, output logic [7:0] o, output logic [3:0] p);
  ifc #(.W(8)) u();
  ifc v();
  assign u.d = i;
  assign v.d = i[3:0];
  assign o = u.d;
  assign p = v.d;
endmodule
