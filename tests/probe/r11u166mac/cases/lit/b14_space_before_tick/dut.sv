// § ppBasedLitWsAfter166
module top(input s, input [7:0] m, output logic [7:0] r);
  always_comb r = s ? 8 'h 1 : m;
endmodule
