// § ppBasedLitWsAfter166
module top(input [1:0] s, output logic r);
  always_comb case (s) 2'b 01: r = 1'b1; default: r = 1'b0; endcase
endmodule
