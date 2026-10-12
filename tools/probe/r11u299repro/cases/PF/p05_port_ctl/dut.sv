// § inlineAggFormalTypeSpan299
module dut(input struct packed { logic a; logic b; } [1:0] i, output logic [3:0] o);
  assign o = i;
endmodule
