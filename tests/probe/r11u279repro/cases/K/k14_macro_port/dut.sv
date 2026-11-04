// § inlineStructPortVarKwSpan279
module dut(input `define ST struct packed { logic [1:0] a; logic b; }
  `ST i, output logic [2:0] o);
  assign o = i;
endmodule
