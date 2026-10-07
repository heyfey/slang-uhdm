// § ifaceTpUseBindsDefDefault281
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
interface ifc #(parameter type T = u_t);
  T d;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d.b;
endmodule
