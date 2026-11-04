// § portExprElabDefNets146
module c(.a({b, cc}), e);
  input [1:0] b; input cc; output e;
  assign e = ^b ^ cc;
endmodule
module top(input [1:0] x, input y, output o1, output o2);
  c u1(.a({x, y}), .e(o1));
  c u2(.a({y, x}), .e(o2));
endmodule
