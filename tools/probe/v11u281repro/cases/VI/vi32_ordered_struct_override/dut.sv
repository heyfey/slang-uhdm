// § ifaceTpUseBindsDefDefault281
typedef struct packed { logic [5:0] a; logic [1:0] b; } s_t;
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
module dut(input logic [7:0] i, output logic [7:0] o);
  ifc #(s_t) u();
  assign u.d = i;
  assign o = u.d;
endmodule
