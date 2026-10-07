// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d = '0;
endinterface
module dut(output logic [3:0] o);
  ifc u();
  assign o = u.d;
endmodule
