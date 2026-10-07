// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  typedef T my_t;
  my_t d;
  T e;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o, output logic [3:0] p);
  ifc u();
  assign u.d = i;
  assign u.e = i;
  assign o = u.d;
  assign p = u.e;
endmodule
