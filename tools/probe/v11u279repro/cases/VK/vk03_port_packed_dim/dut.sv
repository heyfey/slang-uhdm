// § inlineStructPortVarKwSpan279
module dut(input struct packed { logic [1:0] a; logic b; } [1:0] i, output logic [5:0] o);
  assign o = i;
endmodule
