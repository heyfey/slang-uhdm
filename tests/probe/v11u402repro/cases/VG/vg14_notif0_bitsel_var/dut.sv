// § gateInBitSelIndexSpan402
module top(output o, input [3:0] a, input [1:0] s);
  notif0 n1 (o, a[s], s[0]);
endmodule
