// § inlineStructPortVarKwSpan279
module dut(input logic [1:0] i, output logic [1:0] o);
  var struct { logic a; logic b; } x;
  assign x.a = i[0];
  assign x.b = i[1];
  assign o = {x.b, x.a};
endmodule
