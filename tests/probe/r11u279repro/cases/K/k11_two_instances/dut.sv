// § inlineStructPortVarKwSpan279
module sub(input struct packed { logic [1:0] a; logic b; } i, output logic [2:0] o);
  assign o = i;
endmodule
module dut(input logic [2:0] i, output logic [2:0] o1, o2);
  sub u1(.i(i), .o(o1));
  sub u2(.i(i), .o(o2));
endmodule
