// § gateInBitSelIndexSpan402
module top(output o, input [3:0] i, input n, p);
  cmos c1 (o, i[2], n, p);
endmodule
