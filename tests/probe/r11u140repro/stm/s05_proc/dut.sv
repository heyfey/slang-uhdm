// § streamOperandBraceSpan140
module top(input logic [7:0] a, input logic [7:0] b, output logic [15:0] o, output logic [15:0] o2);
  always_comb o = { << 4 {  a, b  }};
endmodule
