// § portExprOperandAtExpr146 § portExprElabDefNets146
module c(.a({b, c}), .d({e, f}));
  input b, c, e, f;
endmodule
module top(input logic [1:0] x, y);
  c ci(.a(x), .d(y));
endmodule
