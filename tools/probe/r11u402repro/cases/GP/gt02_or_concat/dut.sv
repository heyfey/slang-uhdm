// § gateInBitSelIndexSpan402
module top(input [3:0] in, input en, output [1:0] out);
  xor x1 (out[1], {in[0], en}, in[1]);
endmodule
