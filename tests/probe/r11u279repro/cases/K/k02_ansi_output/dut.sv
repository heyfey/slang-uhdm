// § inlineStructPortVarKwSpan279
module dut(input logic [2:0] i, output struct packed { logic [1:0] a; logic b; } o);
  assign o = i;
endmodule
