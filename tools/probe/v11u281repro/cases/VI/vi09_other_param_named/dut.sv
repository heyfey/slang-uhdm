// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter int N = 1, parameter type T = logic [3:0]);
  T d;
  logic [N-1:0] e;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o, output logic [1:0] p);
  ifc #(.N(2)) u();
  assign u.d = i;
  assign u.e = i[1:0];
  assign o = u.d;
  assign p = u.e;
endmodule
