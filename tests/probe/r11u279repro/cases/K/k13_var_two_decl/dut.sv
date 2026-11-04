// § inlineStructPortVarKwSpan279
module dut(input logic [1:0] i, output logic [1:0] o);
  var struct packed { logic a; logic b; } x, y;
  assign x = i;
  assign y = x;
  assign o = y;
endmodule
