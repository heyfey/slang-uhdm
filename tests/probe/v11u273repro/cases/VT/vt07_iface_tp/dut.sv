// § typeParamStructLastNetParent273
interface ifc #(parameter type T = struct packed { logic [3:0] a; logic b; });
  T s;
endinterface
module dut (input logic [4:0] i, output logic [4:0] o);
  ifc i0();
  assign i0.s = i;
  assign o = i0.s;
endmodule
