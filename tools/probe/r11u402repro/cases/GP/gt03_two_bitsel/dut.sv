// § gateInBitSelIndexSpan402
module top(input [3:0] in, input en, output [3:0] out);
  or o1 (out[1], in[0], in[3+0], en);
endmodule
