// § ifaceTpUseBindsDefDefault281
typedef struct packed { logic [2:0] a; logic b; } s_t;
interface ifc #(parameter type T = s_t);
  T d;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
