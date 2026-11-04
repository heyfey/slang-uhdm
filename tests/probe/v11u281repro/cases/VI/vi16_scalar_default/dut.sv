// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic);
  T d;
endinterface
module dut(input logic i, output logic o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
