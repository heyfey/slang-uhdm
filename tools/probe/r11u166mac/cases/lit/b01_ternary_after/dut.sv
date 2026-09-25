// § ppBasedLitWsAfter166
module top(input s, input [9:0] m, output logic [9:0] r);
  always_comb r = s ? 10'b 0 : m;
endmodule
