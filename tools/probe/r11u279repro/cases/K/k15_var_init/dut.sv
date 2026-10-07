// § inlineStructPortVarKwSpan279
module dut(output logic [1:0] o);
  var struct packed { logic a; logic b; } x = 2'b10;
  assign o = x;
endmodule
