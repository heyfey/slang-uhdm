// § ppBasedLitWsAfter166
module top(input s, input [31:0] a, output logic [31:0] r);
  always_comb r = s ? 32'h 8000_0000 : a;
endmodule
