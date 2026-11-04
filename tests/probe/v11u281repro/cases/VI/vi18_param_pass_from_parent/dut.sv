// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]);
  T d;
endinterface
module mid #(parameter int W = 2) (input logic [W-1:0] i, output logic [W-1:0] o);
  ifc #(.W(W)) u();
  assign u.d = i;
  assign o = u.d;
endmodule
module dut(input logic [5:0] i, output logic [5:0] o);
  mid #(.W(6)) m (.i(i), .o(o));
endmodule
