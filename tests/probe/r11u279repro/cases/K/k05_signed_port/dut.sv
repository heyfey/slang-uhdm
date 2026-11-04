// § inlineStructPortVarKwSpan279
module dut(input struct packed signed { logic [1:0] a; logic b; } i, output logic [2:0] o);
  assign o = i;
endmodule
