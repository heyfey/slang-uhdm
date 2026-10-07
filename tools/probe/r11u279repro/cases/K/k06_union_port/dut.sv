// § inlineStructPortVarKwSpan279
module dut(input union packed { logic [2:0] a; logic [2:0] b; } i, output logic [2:0] o);
  assign o = i;
endmodule
