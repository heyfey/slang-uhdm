// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
module dut(input logic [7:0] i, output logic [7:0] o, output logic [3:0] p);
  ifc #(.T(logic [7:0])) u();
  ifc v();
  assign u.d = i;
  assign v.d = i[3:0];
  assign o = u.d;
  assign p = v.d;
endmodule
