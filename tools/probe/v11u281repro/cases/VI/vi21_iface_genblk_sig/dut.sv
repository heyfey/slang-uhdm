// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d;
  if (1) begin : gb
    T e;
  end
endinterface
module dut(input logic [3:0] i, output logic [3:0] o, output logic [3:0] p);
  ifc u();
  assign u.d = i;
  assign u.gb.e = i;
  assign o = u.d;
  assign p = u.gb.e;
endmodule
