// § inlineStructPortVarKwSpan279
program prg(input struct packed { logic [1:0] a; logic b; } i);
endprogram
module dut(input logic [2:0] i);
  prg u(.i(i));
endmodule
