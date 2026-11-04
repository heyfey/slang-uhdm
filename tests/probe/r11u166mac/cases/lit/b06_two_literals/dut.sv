// § ppBasedLitWsAfter166
module top(input s, output logic [3:0] r);
  always_comb r = s ? 4'b 1010 : 4'b 0101;
endmodule
