// § gateInBitSelIndexSpan402
module top(output o, input logic [1:0][1:0] a, input b);
  and g1 (o, a[1][0], b);
endmodule
