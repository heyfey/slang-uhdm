// § inlineStructPortVarKwSpan279
module dut(input logic [1:0] i, output logic [1:0] o);
  var union packed { logic [1:0] a; logic [1:0] b; } x;
  assign x = i;
  assign o = x;
endmodule
