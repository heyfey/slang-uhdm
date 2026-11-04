// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = int);
  T d;
endinterface
module dut(input int i, output int o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
