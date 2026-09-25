// § portExprElabDefNets146
module c(.a({b, cc}), .d(e));
  input b; input cc; output e;
  assign e = b & cc;
endmodule
module top(input [1:0] x, output z);
  c u({x[1], x[0]}, z);
endmodule
