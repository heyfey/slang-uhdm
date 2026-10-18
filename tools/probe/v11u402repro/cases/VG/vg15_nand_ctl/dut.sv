// § gateInBitSelIndexSpan402
module top(output o, input a, b);
  nand g (o, a, b);
  xor (o, a, b);
endmodule
