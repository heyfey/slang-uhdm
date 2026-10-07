// § inlineStructPortVarKwSpan279
interface ifc(input struct packed { logic [1:0] a; logic b; } i);
endinterface
module dut(input logic [2:0] i);
  ifc u(.i(i));
endmodule
