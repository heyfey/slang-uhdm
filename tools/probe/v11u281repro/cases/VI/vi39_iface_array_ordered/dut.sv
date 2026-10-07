// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
module dut(input logic [7:0] i, output logic [7:0] o);
  ifc #(logic [7:0]) u [2] ();
  assign u[0].d = i;
  assign u[1].d = i;
  assign o = u[1].d;
endmodule
